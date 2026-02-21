# Database Operations Reference Guide

## Table of Contents
1. [Migration Patterns](#migration-patterns)
2. [Backup Procedures](#backup-procedures)
3. [Index Optimization](#index-optimization)
4. [Connection Pooling](#connection-pooling)
5. [Platform-Specific Guides](#platform-specific-guides)
6. [Dangerous Operation Safeguards](#dangerous-operation-safeguards)

---

## Migration Patterns

### Up/Down Migration Structure

Every migration must include both UP and DOWN scripts to enable rollback:

```sql
-- UP: Apply migration
-- Migration: add_user_profiles_table
-- Date: 2026-02-21
-- Author: Development Team
-- Description: Create user_profiles table with full-text search support

BEGIN;

CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    search_vector tsvector GENERATED ALWAYS AS (
        to_tsvector('english', coalesce(display_name, '') || ' ' || coalesce(bio, ''))
    ) STORED,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_search ON user_profiles USING GIN(search_vector);

-- Add updated_at trigger
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMIT;

-- DOWN: Rollback migration
BEGIN;

DROP TRIGGER IF EXISTS set_updated_at ON user_profiles;
DROP INDEX IF EXISTS idx_user_profiles_search;
DROP INDEX IF EXISTS idx_user_profiles_user_id;
DROP TABLE IF EXISTS user_profiles;

COMMIT;
```

### Migration Best Practices

**Pre-Migration Checklist:**
- Always test on a staging environment with production-like data volume
- Estimate migration duration (1M rows ≈ 1-5 minutes depending on complexity)
- For tables > 10M rows, consider online migration strategies
- Lock analysis: identify tables that will be locked during migration
- Plan maintenance window for production migrations

**Safe Column Additions:**
```sql
-- Safe: Adding nullable column (no table rewrite)
ALTER TABLE users ADD COLUMN phone_number TEXT;

-- Safe: Adding column with default (PostgreSQL 11+)
ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT false;

-- Unsafe: Adding NOT NULL without default requires table rewrite
-- Do this in two steps instead:
ALTER TABLE users ADD COLUMN required_field TEXT;
UPDATE users SET required_field = 'default_value';
ALTER TABLE users ALTER COLUMN required_field SET NOT NULL;
```

**Safe Constraint Additions:**
```sql
-- Unsafe: Adding NOT VALID constraint locks table
ALTER TABLE users ADD CONSTRAINT check_age CHECK (age >= 18);

-- Safe: Add constraint without validation, then validate separately
ALTER TABLE users ADD CONSTRAINT check_age CHECK (age >= 18) NOT VALID;
-- Later, during low-traffic period:
ALTER TABLE users VALIDATE CONSTRAINT check_age;
```

### Zero-Downtime Migrations

**Expanding Columns (requires multi-step deployment):**

Step 1 - Add new column:
```sql
ALTER TABLE users ADD COLUMN email_new VARCHAR(255);
```

Step 2 - Dual-write from application (deploy app code that writes to both columns)

Step 3 - Backfill old data:
```sql
UPDATE users SET email_new = email WHERE email_new IS NULL;
```

Step 4 - Add constraint:
```sql
ALTER TABLE users ALTER COLUMN email_new SET NOT NULL;
```

Step 5 - Switch reads to new column (deploy app code)

Step 6 - Drop old column:
```sql
ALTER TABLE users DROP COLUMN email;
ALTER TABLE users RENAME COLUMN email_new TO email;
```

---

## Backup Procedures

### 3-2-1 Backup Strategy

- **3** total copies of your data
- **2** different storage media/formats
- **1** copy offsite (different geographic region)

### PostgreSQL Backup Methods

**Logical Backup (pg_dump):**
```bash
# Full database backup
pg_dump -h localhost -U postgres -d mydb -F c -f backup_$(date +%Y%m%d_%H%M%S).dump

# Schema-only backup
pg_dump -h localhost -U postgres -d mydb --schema-only -f schema_backup.sql

# Data-only backup
pg_dump -h localhost -U postgres -d mydb --data-only -f data_backup.sql

# Specific table backup
pg_dump -h localhost -U postgres -d mydb -t users -F c -f users_backup.dump
```

**Restore from logical backup:**
```bash
# Restore full database
pg_restore -h localhost -U postgres -d mydb -c backup_20260221_120000.dump

# Restore specific table
pg_restore -h localhost -U postgres -d mydb -t users backup.dump
```

**Physical Backup (PITR - Point In Time Recovery):**
```bash
# Enable WAL archiving in postgresql.conf
wal_level = replica
archive_mode = on
archive_command = 'cp %p /archive_dir/%f'

# Take base backup
pg_basebackup -h localhost -U postgres -D /backup/base -F tar -z -P

# Restore to specific point in time
# 1. Restore base backup
# 2. Create recovery.conf with target time
# 3. Start PostgreSQL
```

### Supabase Backup

**Automated backups (included in paid plans):**
- Daily backups retained for 7 days (Pro plan)
- Point-in-time recovery available (Enterprise plan)

**Manual backup via CLI:**
```bash
# Export via pg_dump
supabase db dump -f backup.sql

# Restore
psql -h db.xxx.supabase.co -U postgres -d postgres -f backup.sql
```

### Backup Verification Checklist

- [ ] Backup completed without errors
- [ ] Backup file size is reasonable (not 0 bytes, not suspiciously small)
- [ ] Test restore in isolated environment monthly
- [ ] Verify row counts match source database
- [ ] Verify backup is encrypted at rest
- [ ] Confirm backup is in offsite location
- [ ] Document restore procedure and test annually

### Backup Retention Policy

```
Daily backups: Keep 7 days
Weekly backups: Keep 4 weeks
Monthly backups: Keep 12 months
Yearly backups: Keep 7 years (compliance-dependent)
```

---

## Index Optimization

### When to Add Indexes

**Always index:**
- Primary keys (automatic)
- Foreign keys (not automatic in PostgreSQL)
- Columns used in WHERE clauses frequently
- Columns used in JOIN conditions
- Columns used in ORDER BY frequently
- Columns referenced in RLS policies (Supabase)

**Skip indexing when:**
- Table has < 1,000 rows (sequential scan is faster)
- Column has very low cardinality (few distinct values)
- Column is updated very frequently and rarely queried
- Write performance is more critical than read performance

### Index Types

**B-tree (default):**
```sql
-- Standard index for equality and range queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_created_at ON orders(created_at);
```

**Composite index (order matters):**
```sql
-- Good for: WHERE tenant_id = X AND created_at > Y
CREATE INDEX idx_orders_tenant_created ON orders(tenant_id, created_at);

-- Rule: Most selective column first for equality, range column last
```

**Partial index (filtered):**
```sql
-- Only index active records
CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';

-- Only index recent orders
CREATE INDEX idx_recent_orders ON orders(created_at) 
WHERE created_at > '2025-01-01';
```

**GIN index (full-text search, arrays, JSONB):**
```sql
-- Full-text search
CREATE INDEX idx_posts_search ON posts USING GIN(to_tsvector('english', content));

-- JSONB queries
CREATE INDEX idx_metadata ON users USING GIN(metadata);

-- Array contains queries
CREATE INDEX idx_tags ON posts USING GIN(tags);
```

**GiST index (geometric data, full-text):**
```sql
-- Geographic queries
CREATE INDEX idx_locations ON stores USING GIST(location);
```

### Index Maintenance

**Find unused indexes:**
```sql
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    idx_scan AS index_scans
FROM pg_stat_user_indexes
WHERE idx_scan = 0
    AND indexrelname NOT LIKE 'pg_toast%'
ORDER BY pg_relation_size(indexrelid) DESC;
```

**Find duplicate indexes:**
```sql
SELECT
    pg_size_pretty(SUM(pg_relation_size(idx))::BIGINT) AS size,
    (array_agg(idx))[1] AS idx1,
    (array_agg(idx))[2] AS idx2,
    (array_agg(idx))[3] AS idx3,
    (array_agg(idx))[4] AS idx4
FROM (
    SELECT
        indexrelid::regclass AS idx,
        (indrelid::text || E'\n' || indclass::text || E'\n' ||
         indkey::text || E'\n' || COALESCE(indexprs::text, '') || E'\n' ||
         COALESCE(indpred::text, '')) AS key
    FROM pg_index
) sub
GROUP BY key
HAVING COUNT(*) > 1
ORDER BY SUM(pg_relation_size(idx)) DESC;
```

**Reindex when needed:**
```sql
-- Reindex specific index (locks table)
REINDEX INDEX idx_users_email;

-- Reindex concurrently (PostgreSQL 12+, no lock)
REINDEX INDEX CONCURRENTLY idx_users_email;

-- Reindex entire table
REINDEX TABLE users;
```

### Query Performance Analysis

```sql
-- Enable query stats (run once)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Find slowest queries
SELECT
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Analyze specific query
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'test@example.com';

-- Look for:
-- - Seq Scan (should be Index Scan for large tables)
-- - High cost estimates
-- - Actual time vs estimated time discrepancies
```

---

## Connection Pooling

### Why Connection Pooling Matters

Database connections are expensive:
- Each connection consumes ~10MB RAM on PostgreSQL
- Connection establishment takes 50-100ms
- Most databases limit connections (Supabase Free: 60 connections)

### PgBouncer Configuration

**Pool modes:**
- **Session pooling:** Client gets dedicated connection for entire session (default, safest)
- **Transaction pooling:** Connection returned after each transaction (recommended for serverless)
- **Statement pooling:** Connection returned after each statement (rarely used)

**Supabase connection strings:**
```bash
# Direct connection (limited to 60 concurrent on free tier)
postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres

# Pooled connection (supports up to 200 concurrent)
postgresql://postgres:[password]@db.[project-ref].supabase.co:6543/postgres?pgbouncer=true
```

**When to use pooled connection:**
- Serverless functions (AWS Lambda, Vercel)
- High-concurrency applications
- Short-lived connections

**When to use direct connection:**
- Long-running processes
- Migration scripts
- When using prepared statements
- When using LISTEN/NOTIFY

### Prisma Connection Pooling

```prisma
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  directUrl = env("DIRECT_DATABASE_URL") // For migrations
}
```

```bash
# .env
DATABASE_URL="postgresql://postgres:[password]@db.xxx.supabase.co:6543/postgres?pgbouncer=true"
DIRECT_DATABASE_URL="postgresql://postgres:[password]@db.xxx.supabase.co:5432/postgres"
```

```typescript
// Configure connection pool
const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
  // Connection pool settings
  connection: {
    pool_timeout: 5,
    connect_timeout: 10,
  },
});
```

### Drizzle Connection Pooling

```typescript
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';

// Pooled connection for queries
const queryClient = postgres(process.env.DATABASE_URL!, { 
  max: 10, // Max connections in pool
  idle_timeout: 20, // Close idle connections after 20s
  connect_timeout: 10, // Connection timeout
});

const db = drizzle(queryClient);

// Direct connection for migrations
const migrationClient = postgres(process.env.DIRECT_DATABASE_URL!, { 
  max: 1 
});
```

---

## Platform-Specific Guides

### Supabase

**Row Level Security (RLS) Patterns:**

```sql
-- Enable RLS on table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read own posts
CREATE POLICY "Users can read own posts"
ON posts FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert own posts
CREATE POLICY "Users can insert own posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update own posts
CREATE POLICY "Users can update own posts"
ON posts FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Public read access
CREATE POLICY "Public posts are viewable"
ON posts FOR SELECT
USING (is_public = true);

-- Policy: Admin full access
CREATE POLICY "Admins have full access"
ON posts FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = auth.uid()
        AND role = 'admin'
    )
);
```

**RLS Performance Tips:**
- Always index columns used in policies: `CREATE INDEX idx_posts_user_id ON posts(user_id);`
- Avoid joins in policies (use arrays with `ANY` instead)
- Cache role checks in JWT claims when possible
- Use `SECURITY DEFINER` functions for complex authorization logic

**Supabase Realtime:**
```sql
-- Enable realtime on table
ALTER PUBLICATION supabase_realtime ADD TABLE posts;

-- Realtime respects RLS policies automatically
```

### Prisma

**Schema definition:**
```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
}

model Post {
  id        String   @id @default(uuid())
  title     String
  content   String?
  published Boolean  @default(false)
  authorId  String
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
  @@index([published, createdAt])
}
```

**Migration workflow:**
```bash
# Create migration from schema changes
npx prisma migrate dev --name add_posts_table

# Apply migration to production
npx prisma migrate deploy

# Resolve migration conflicts
npx prisma migrate resolve --applied "20260221120000_migration_name"

# Reset database (DESTRUCTIVE - dev only)
npx prisma migrate reset
```

**Common Prisma pitfalls:**
- Always use `directUrl` for migrations with PgBouncer
- Use `@updatedAt` for automatic timestamp updates
- Remember `onDelete: Cascade` for foreign keys
- Use raw SQL for complex queries: `prisma.$queryRaw`

### Drizzle

**Schema definition:**
```typescript
import { pgTable, uuid, text, timestamp, boolean, index } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: text('email').notNull().unique(),
  name: text('name'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
}, (table) => ({
  emailIdx: index('idx_users_email').on(table.email),
}));

export const posts = pgTable('posts', {
  id: uuid('id').primaryKey().defaultRandom(),
  title: text('title').notNull(),
  content: text('content'),
  published: boolean('published').notNull().default(false),
  authorId: uuid('author_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
}, (table) => ({
  authorIdx: index('idx_posts_author_id').on(table.authorId),
  publishedCreatedIdx: index('idx_posts_published_created').on(table.published, table.createdAt),
}));
```

**Migration workflow:**
```bash
# Generate migration from schema
npx drizzle-kit generate:pg

# Apply migrations
npx drizzle-kit push:pg

# Studio for database exploration
npx drizzle-kit studio
```

### Firebase Firestore

**Security Rules patterns:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can only read/write own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public read, authenticated write
    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null 
        && resource.data.authorId == request.auth.uid;
    }
    
    // Role-based access
    match /admin/{document=**} {
      allow read, write: if request.auth != null 
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Validate data structure
    match /posts/{postId} {
      allow create: if request.auth != null
        && request.resource.data.keys().hasAll(['title', 'content', 'authorId'])
        && request.resource.data.title is string
        && request.resource.data.title.size() > 0
        && request.resource.data.authorId == request.auth.uid;
    }
  }
}
```

**CRITICAL: Remove test mode before production:**
```javascript
// DANGEROUS - NEVER use in production
match /{document=**} {
  allow read, write: if true; // ← This is test mode, remove it!
}
```

---

## Dangerous Operation Safeguards

### Pre-Flight Checklist for Destructive Operations

Before running DELETE, DROP, TRUNCATE, or ALTER operations:

```
⚠️  DESTRUCTIVE OPERATION DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Operation:      [DELETE FROM users WHERE ...]
Target:         [users table]
Affected rows:  [~1,234 rows (estimated)]
Database:       [production]
Backup status:  [ ] Verified (required)
Test run:       [ ] Completed on staging
Rollback plan:  [ ] Documented

Irreversible consequences:
- User data will be permanently deleted
- Foreign key constraints will cascade deletes to:
  - user_profiles (1,234 rows)
  - posts (5,678 rows)
  - comments (12,345 rows)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Type "CONFIRM DELETE" to proceed: _______
```

### Safe Deletion Pattern

**Step 1: Soft delete first (add deleted_at column)**
```sql
-- Add column for soft deletes
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMPTZ;

-- Soft delete
UPDATE users SET deleted_at = NOW() WHERE id = 'xxx';

-- Query excludes soft-deleted
SELECT * FROM users WHERE deleted_at IS NULL;
```

**Step 2: Wait period (7-30 days)**
- Monitor for recovery requests
- Verify no dependent systems are broken

**Step 3: Hard delete with transaction**
```sql
BEGIN;

-- Verify count before deletion
SELECT COUNT(*) FROM users WHERE deleted_at < NOW() - INTERVAL '30 days';
-- Expected: 123

-- Delete with limit for safety
DELETE FROM users 
WHERE deleted_at < NOW() - INTERVAL '30 days'
LIMIT 1000;
-- Returns: 123 rows deleted

-- Verify counts match
-- If counts don't match, ROLLBACK
COMMIT;
```

### Cascading Delete Prevention

**Check cascade impact before deleting:**
```sql
-- Find what will be cascade-deleted
SELECT
    tc.table_name AS child_table,
    kcu.column_name AS child_column,
    ccu.table_name AS parent_table,
    ccu.column_name AS parent_column,
    rc.delete_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON tc.constraint_name = rc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'users'
  AND rc.delete_rule = 'CASCADE';
```

**Count cascade impact:**
```sql
-- Before deleting user_id = 'xxx'
SELECT 'posts' AS table_name, COUNT(*) FROM posts WHERE user_id = 'xxx'
UNION ALL
SELECT 'comments', COUNT(*) FROM comments WHERE user_id = 'xxx'
UNION ALL
SELECT 'likes', COUNT(*) FROM likes WHERE user_id = 'xxx';
```

### Transaction Timeout Protection

```sql
-- Set statement timeout to prevent runaway queries
SET statement_timeout = '30s';

BEGIN;
-- Your destructive operation here
DELETE FROM old_logs WHERE created_at < NOW() - INTERVAL '90 days';
COMMIT;

-- Reset timeout
RESET statement_timeout;
```

### Backup Verification Script

```bash
#!/bin/bash
# verify-backup.sh

set -e

BACKUP_FILE="$1"
DB_NAME="$2"

echo "Verifying backup: $BACKUP_FILE"

# Check file exists and is not empty
if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found"
    exit 1
fi

if [ ! -s "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file is empty"
    exit 1
fi

# Attempt test restore to temporary database
TEST_DB="${DB_NAME}_verify_$(date +%s)"

echo "Creating test database: $TEST_DB"
createdb "$TEST_DB"

echo "Restoring backup to test database..."
pg_restore -d "$TEST_DB" "$BACKUP_FILE" 2>/dev/null

# Verify row counts
echo "Verifying table counts..."
TABLES=$(psql -d "$TEST_DB" -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public'")

for table in $TABLES; do
    COUNT=$(psql -d "$TEST_DB" -t -c "SELECT COUNT(*) FROM $table")
    echo "  $table: $COUNT rows"
done

# Cleanup
dropdb "$TEST_DB"

echo "✅ Backup verified successfully"
```

### Emergency Rollback Procedures

**If migration fails mid-execution:**

1. Don't panic
2. Check if wrapped in transaction (should rollback automatically)
3. If not in transaction and partially applied:
   ```sql
   -- Manually run DOWN script
   -- Check migration file for rollback instructions
   ```
4. Verify data integrity:
   ```sql
   -- Compare row counts before/after
   SELECT schemaname, tablename, n_live_tup 
   FROM pg_stat_user_tables
   ORDER BY schemaname, tablename;
   ```

**If data was deleted accidentally:**

1. Immediately stop all writes to database
2. Restore from most recent backup:
   ```bash
   # Create restore database
   createdb mydb_restore
   
   # Restore backup
   pg_restore -d mydb_restore backup_20260221_120000.dump
   
   # Extract deleted data
   pg_dump -d mydb_restore -t deleted_table -a > recovered_data.sql
   
   # Import recovered data to production
   psql -d mydb < recovered_data.sql
   ```
3. If no recent backup exists, check if you have PITR enabled (restore to point before deletion)
