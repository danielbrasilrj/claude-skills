---
name: database-ops
description: Safe database operations — migrations, backups, RLS review, index optimization. Never destructive without confirmation.
---

## Purpose

Database Ops provides safe, structured procedures for all database operations. It enforces a safety-first approach where destructive operations always require confirmation and backup verification. Covers the full lifecycle from schema design through migrations, security rules, performance tuning, and disaster recovery.

## When to Use

- Writing or reviewing database migration scripts
- Reviewing database security rules or RLS policies
- Optimizing slow queries or adding indexes
- Setting up backup and recovery procedures
- Auditing database permissions and access patterns
- Any destructive database operation (DELETE, DROP, TRUNCATE)

## Prerequisites

- Database access credentials (via environment variables, never hardcoded)
- `domain-intelligence` config to know which database is in use
- Backup verification before any destructive operation

## Procedures

### 1. Safety Protocol (ALWAYS FOLLOW)

**Before ANY destructive operation:**

1. Verify you have a recent backup
2. Test the operation on a non-production environment first
3. Get explicit user confirmation with a description of what will change
4. Log the operation with timestamp and operator

```
⚠️  DESTRUCTIVE OPERATION DETECTED
Action: [DELETE/DROP/TRUNCATE/ALTER]
Target: [table/collection/index]
Affected rows (estimate): [count]
Backup verified: [YES/NO]
Environment: [dev/staging/production]

Proceed? [Requires explicit user confirmation]
```

### 2. Migration Workflow

Every migration follows the up/down pattern. See [migration-patterns.md](migration-patterns.md) for detailed examples including zero-downtime migrations and safe column/constraint additions.

```sql
-- UP: Apply migration
-- Migration: [description]
-- Date: [YYYY-MM-DD]
-- Author: [name]

BEGIN;
-- Schema changes here
COMMIT;

-- DOWN: Rollback migration
BEGIN;
-- Reverse changes here
COMMIT;
```

**Migration checklist:**

- [ ] Both UP and DOWN scripts written and tested
- [ ] Full backup taken before running
- [ ] Tested on staging first
- [ ] Row counts verified after migration
- [ ] Indexes recreated if needed
- [ ] RLS policies updated if schema changed

### 3. Security Rules Review

See [platform-guides.md](platform-guides.md) for full RLS patterns, Prisma/Drizzle schemas, and Firebase security rules.

**Supabase (RLS):**

- [ ] RLS enabled on ALL tables containing user data
- [ ] `anon` key only used on client (safe with RLS)
- [ ] `service_role` key NEVER exposed to client
- [ ] Policies use indexed columns for performance
- [ ] No policies with joins (use arrays/IN instead)

**Firebase:**

- [ ] Test mode REMOVED before production (the #1 breach cause)
- [ ] Rules validate authentication state
- [ ] Rules validate data structure and types
- [ ] Rules enforce authorization (user can only access own data)

### 4. Indexing Optimization

See [index-optimization.md](index-optimization.md) for index types (B-tree, GIN, GiST, partial, composite), maintenance queries, and performance analysis.

```sql
-- Find slow queries (PostgreSQL)
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Analyze a specific query
EXPLAIN ANALYZE SELECT ...;

-- Add indexes for frequently filtered columns
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

**Index decision guide:**

- Add index if: column appears in WHERE, JOIN, or ORDER BY frequently
- Skip index if: table has < 1000 rows, column has low cardinality
- Always index: foreign keys, RLS policy columns

### 5. Backup Strategy (3-2-1 Rule)

- **3** copies of data
- **2** different storage media
- **1** offsite/different cloud region

Test restores regularly — a backup that has never been restored is not a backup. See [backup-procedures.md](backup-procedures.md) for pg_dump/PITR commands, verification scripts, and emergency rollback procedures.

## Templates

- `templates/migration-template.sql` — Up/down migration template
- `templates/security-rules-checklist.md` — Security review checklist

## Examples

- `examples/supabase-rls-example.md` — Supabase RLS setup example

## Chaining

| Chain With                 | Purpose                                      |
| -------------------------- | -------------------------------------------- |
| `domain-intelligence`      | Determine which database is in use           |
| `security-review`          | Full security audit including database layer |
| `performance-optimization` | Query optimization and profiling             |
| `ci-cd-pipeline`           | Automate migrations in deployment pipeline   |

## References

- [migration-patterns.md](migration-patterns.md) -- Up/down migrations, zero-downtime patterns, safe alterations
- [backup-procedures.md](backup-procedures.md) -- pg_dump/PITR, Supabase backup, verification scripts, emergency rollback
- [index-optimization.md](index-optimization.md) -- Index types, maintenance queries, query performance analysis
- [connection-pooling.md](connection-pooling.md) -- PgBouncer, Prisma/Drizzle pool config, when to use pooled vs direct
- [platform-guides.md](platform-guides.md) -- Supabase RLS, Prisma, Drizzle, Firebase Firestore patterns
- [dangerous-operations.md](dangerous-operations.md) -- Pre-flight checklists, safe deletion, cascade prevention, transaction timeouts

## Troubleshooting

| Problem                              | Solution                                                          |
| ------------------------------------ | ----------------------------------------------------------------- |
| Migration fails halfway              | Use transactions; run DOWN script to rollback                     |
| RLS policy too slow                  | Index all columns referenced in policies; avoid joins in policies |
| Firebase rules reject valid requests | Test in Rules Playground; check auth token claims                 |
| Backup restore fails                 | Test restores in non-prod regularly; verify backup integrity      |
