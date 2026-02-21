# Example: Adding User Profiles Table with Full-Text Search

This example demonstrates a complete migration workflow for adding a `user_profiles` table to a Supabase PostgreSQL database, including full-text search support, RLS policies, and proper indexing.

---

## Migration Context

**Migration ID:** `20260221_143000_add_user_profiles_table`  
**Author:** Development Team  
**Date:** 2026-02-21  
**Database:** Production (Supabase)  
**Estimated Duration:** 2-3 minutes for initial setup (no data to migrate)

**Description:**
Add a `user_profiles` table to store user profile information (display name, bio, avatar) with full-text search capabilities. This enables users to search for other users by name or bio content.

**Tables Affected:**
- New table: `user_profiles`
- References: `auth.users` (foreign key)

---

## Pre-Migration Phase

### 1. Backup Verification

```bash
# Create backup using Supabase CLI
supabase db dump -f backup_20260221_143000.sql

# Verify backup file
ls -lh backup_20260221_143000.sql
# -rw-r--r-- 1 user user 45M Feb 21 14:30 backup_20260221_143000.sql

# Test restore on local database
createdb test_restore
psql -d test_restore -f backup_20260221_143000.sql

# Verify row count for auth.users
psql -d test_restore -c "SELECT COUNT(*) FROM auth.users;"
#  count
# -------
#   1247
# (1 row)

# Cleanup test database
dropdb test_restore
```

**Backup Status:** ✅ Verified  
**Backup Size:** 45MB  
**Auth users count:** 1,247 rows

### 2. UP Migration Script

Create file: `migrations/20260221_143000_add_user_profiles_table_up.sql`

```sql
-- UP: Apply migration
-- Migration: add_user_profiles_table
-- Date: 2026-02-21
-- Author: Development Team
-- Description: Create user_profiles table with full-text search support

BEGIN;

-- Create updated_at trigger function (if not exists)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    
    -- Full-text search vector (auto-generated)
    search_vector tsvector GENERATED ALWAYS AS (
        to_tsvector('english', coalesce(display_name, '') || ' ' || coalesce(bio, ''))
    ) STORED,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT user_profiles_user_id_key UNIQUE(user_id),
    CONSTRAINT display_name_length CHECK (char_length(display_name) >= 2),
    CONSTRAINT bio_length CHECK (char_length(bio) <= 500)
);

-- Create indexes
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_search ON user_profiles USING GIN(search_vector);

-- Create updated_at trigger
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can read all profiles
CREATE POLICY "Public profiles are viewable"
ON user_profiles FOR SELECT
USING (true);

-- RLS Policy: Users can insert own profile
CREATE POLICY "Users can insert own profile"
ON user_profiles FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update own profile
CREATE POLICY "Users can update own profile"
ON user_profiles FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete own profile
CREATE POLICY "Users can delete own profile"
ON user_profiles FOR DELETE
USING (auth.uid() = user_id);

-- Grant permissions
GRANT SELECT ON user_profiles TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON user_profiles TO authenticated;

COMMIT;

-- Post-migration verification
DO $$
DECLARE
    table_exists BOOLEAN;
    index_count INTEGER;
    policy_count INTEGER;
BEGIN
    -- Check table exists
    SELECT EXISTS (
        SELECT FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename = 'user_profiles'
    ) INTO table_exists;
    
    IF NOT table_exists THEN
        RAISE EXCEPTION 'Table user_profiles was not created';
    END IF;
    
    -- Check indexes
    SELECT COUNT(*) INTO index_count
    FROM pg_indexes
    WHERE tablename = 'user_profiles';
    
    IF index_count < 2 THEN
        RAISE EXCEPTION 'Expected at least 2 indexes, found %', index_count;
    END IF;
    
    -- Check policies
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE tablename = 'user_profiles';
    
    IF policy_count < 4 THEN
        RAISE EXCEPTION 'Expected 4 RLS policies, found %', policy_count;
    END IF;
    
    RAISE NOTICE 'Migration verification passed: table, indexes, and policies created successfully';
END $$;
```

### 3. DOWN Migration Script

Create file: `migrations/20260221_143000_add_user_profiles_table_down.sql`

```sql
-- DOWN: Rollback migration
-- Migration: add_user_profiles_table
-- Date: 2026-02-21
-- Author: Development Team

BEGIN;

-- Drop trigger
DROP TRIGGER IF EXISTS set_updated_at ON user_profiles;

-- Drop indexes (automatic when table is dropped, but explicit for clarity)
DROP INDEX IF EXISTS idx_user_profiles_search;
DROP INDEX IF EXISTS idx_user_profiles_user_id;

-- Drop policies (automatic when table is dropped, but explicit for clarity)
DROP POLICY IF EXISTS "Users can delete own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Public profiles are viewable" ON user_profiles;

-- Drop table (CASCADE will drop foreign key constraints)
DROP TABLE IF EXISTS user_profiles CASCADE;

COMMIT;

-- Post-rollback verification
DO $$
DECLARE
    table_exists BOOLEAN;
BEGIN
    -- Check table does not exist
    SELECT EXISTS (
        SELECT FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename = 'user_profiles'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE EXCEPTION 'Table user_profiles still exists after rollback';
    END IF;
    
    RAISE NOTICE 'Rollback verification passed: table dropped successfully';
END $$;
```

### 4. Test on Staging

```bash
# Apply UP migration to staging
psql -h db.staging.supabase.co -U postgres -d postgres \
  -f migrations/20260221_143000_add_user_profiles_table_up.sql

# Output:
# BEGIN
# CREATE FUNCTION
# CREATE TABLE
# CREATE INDEX
# CREATE INDEX
# CREATE TRIGGER
# ALTER TABLE
# CREATE POLICY
# CREATE POLICY
# CREATE POLICY
# CREATE POLICY
# GRANT
# COMMIT
# NOTICE:  Migration verification passed: table, indexes, and policies created successfully
# DO

# Verify table structure
psql -h db.staging.supabase.co -U postgres -d postgres -c "
  SELECT column_name, data_type, is_nullable
  FROM information_schema.columns
  WHERE table_name = 'user_profiles'
  ORDER BY ordinal_position;
"

# Output:
#   column_name  |     data_type          | is_nullable
# ---------------+------------------------+-------------
#  id            | uuid                   | NO
#  user_id       | uuid                   | NO
#  display_name  | text                   | NO
#  bio           | text                   | YES
#  avatar_url    | text                   | YES
#  search_vector | tsvector               | YES
#  created_at    | timestamp with time zone | NO
#  updated_at    | timestamp with time zone | NO

# Test RLS policies by creating a profile
psql -h db.staging.supabase.co -U postgres -d postgres -c "
  INSERT INTO user_profiles (user_id, display_name, bio)
  VALUES (
    (SELECT id FROM auth.users LIMIT 1),
    'Test User',
    'This is a test bio for search functionality'
  );
"

# Test full-text search
psql -h db.staging.supabase.co -U postgres -d postgres -c "
  SELECT display_name, bio
  FROM user_profiles
  WHERE search_vector @@ to_tsquery('english', 'test');
"

# Output:
#  display_name |                    bio
# --------------+-------------------------------------------
#  Test User    | This is a test bio for search functionality

# Test DOWN migration (rollback)
psql -h db.staging.supabase.co -U postgres -d postgres \
  -f migrations/20260221_143000_add_user_profiles_table_down.sql

# Output:
# BEGIN
# DROP TRIGGER
# DROP INDEX
# DROP INDEX
# DROP POLICY
# DROP POLICY
# DROP POLICY
# DROP POLICY
# DROP TABLE
# COMMIT
# NOTICE:  Rollback verification passed: table dropped successfully
# DO

# Verify table is gone
psql -h db.staging.supabase.co -U postgres -d postgres -c "
  SELECT tablename FROM pg_tables WHERE tablename = 'user_profiles';
"

# Output:
#  tablename
# -----------
# (0 rows)

# Re-apply UP migration for production deployment
psql -h db.staging.supabase.co -U postgres -d postgres \
  -f migrations/20260221_143000_add_user_profiles_table_up.sql
```

**Staging Test Result:** ✅ Passed  
**UP migration:** Success  
**DOWN migration:** Success  
**Re-applied UP:** Success

---

## Migration Execution Phase

### 5. Production Execution

**Start Time:** 2026-02-21 14:45:00 UTC  
**Database:** Production (Supabase)

```bash
# Double-check database connection
echo $DATABASE_URL
# postgresql://postgres:[REDACTED]@db.xxx.supabase.co:5432/postgres

# Apply migration
psql $DATABASE_URL -f migrations/20260221_143000_add_user_profiles_table_up.sql

# Output:
# BEGIN
# CREATE FUNCTION
# CREATE TABLE
# CREATE INDEX
# CREATE INDEX
# CREATE TRIGGER
# ALTER TABLE
# CREATE POLICY
# CREATE POLICY
# CREATE POLICY
# CREATE POLICY
# GRANT
# COMMIT
# NOTICE:  Migration verification passed: table, indexes, and policies created successfully
# DO
```

**End Time:** 2026-02-21 14:45:03 UTC  
**Duration:** 3 seconds  
**Status:** ✅ SUCCESS

### 6. Post-Execution Verification

```sql
-- Verify table exists
SELECT tablename FROM pg_tables WHERE tablename = 'user_profiles';
--  tablename
-- ---------------
--  user_profiles

-- Verify indexes
SELECT indexname FROM pg_indexes WHERE tablename = 'user_profiles';
--              indexname
-- -----------------------------------
--  user_profiles_pkey
--  user_profiles_user_id_key
--  idx_user_profiles_user_id
--  idx_user_profiles_search

-- Verify RLS enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'user_profiles';
--  tablename      | rowsecurity
-- ----------------+-------------
--  user_profiles  | t

-- Verify policies
SELECT policyname FROM pg_policies WHERE tablename = 'user_profiles';
--          policyname
-- ------------------------------
--  Public profiles are viewable
--  Users can insert own profile
--  Users can update own profile
--  Users can delete own profile

-- Verify constraints
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'user_profiles';
--       constraint_name       | constraint_type
-- ----------------------------+-----------------
--  user_profiles_pkey         | PRIMARY KEY
--  user_profiles_user_id_key  | UNIQUE
--  user_profiles_user_id_fkey | FOREIGN KEY
--  display_name_length        | CHECK
--  bio_length                 | CHECK

-- Test insert (using service_role key)
INSERT INTO user_profiles (
    user_id, 
    display_name, 
    bio, 
    avatar_url
) 
SELECT 
    id,
    COALESCE(raw_user_meta_data->>'name', 'User'),
    NULL,
    raw_user_meta_data->>'avatar_url'
FROM auth.users
WHERE id = '123e4567-e89b-12d3-a456-426614174000'
ON CONFLICT (user_id) DO NOTHING;

-- Result: INSERT 0 1

-- Test search functionality
SELECT display_name, LEFT(bio, 50) as bio_preview
FROM user_profiles
WHERE search_vector @@ to_tsquery('english', 'developer | engineer')
LIMIT 5;

--  display_name  |                bio_preview
-- ---------------+--------------------------------------------
--  John Doe      | Senior software developer with 10 years...
--  Jane Smith    | Full-stack engineer passionate about...
```

**Verification Result:** ✅ All checks passed

### 7. Performance Verification

```sql
-- Test query performance
EXPLAIN ANALYZE
SELECT * FROM user_profiles WHERE user_id = '123e4567-e89b-12d3-a456-426614174000';

-- Result:
-- Index Scan using idx_user_profiles_user_id on user_profiles  
--   (cost=0.15..8.17 rows=1 width=120) (actual time=0.023..0.024 rows=1 loops=1)
--   Index Cond: (user_id = '123e4567-e89b-12d3-a456-426614174000'::uuid)
-- Planning Time: 0.142 ms
-- Execution Time: 0.048 ms

-- Test full-text search performance
EXPLAIN ANALYZE
SELECT * FROM user_profiles 
WHERE search_vector @@ to_tsquery('english', 'developer')
LIMIT 10;

-- Result:
-- Limit  (cost=12.00..20.10 rows=10 width=120) (actual time=0.312..0.318 rows=10 loops=1)
--   ->  Bitmap Heap Scan on user_profiles  (cost=12.00..44.50 rows=40 width=120) 
--                                           (actual time=0.311..0.316 rows=10 loops=1)
--         Recheck Cond: (search_vector @@ to_tsquery('english'::regconfig, 'developer'::text))
--         Heap Blocks: exact=10
--         ->  Bitmap Index Scan on idx_user_profiles_search  (cost=0.00..11.99 rows=40 width=0) 
--                                                             (actual time=0.298..0.298 rows=47 loops=1)
--               Index Cond: (search_vector @@ to_tsquery('english'::regconfig, 'developer'::text))
-- Planning Time: 0.234 ms
-- Execution Time: 0.354 ms
```

**Performance Result:** ✅ Sub-millisecond queries with proper index usage

---

## Post-Migration Phase

### 8. Application Integration

**Update TypeScript types:**

```typescript
// types/database.ts
export interface UserProfile {
  id: string;
  user_id: string;
  display_name: string;
  bio: string | null;
  avatar_url: string | null;
  created_at: string;
  updated_at: string;
}

// API function to create profile
import { supabase } from './supabase';

export async function createUserProfile(
  userId: string,
  displayName: string,
  bio?: string,
  avatarUrl?: string
) {
  const { data, error } = await supabase
    .from('user_profiles')
    .insert({
      user_id: userId,
      display_name: displayName,
      bio,
      avatar_url: avatarUrl,
    })
    .select()
    .single();

  if (error) throw error;
  return data;
}

// Full-text search function
export async function searchUserProfiles(query: string) {
  const { data, error } = await supabase
    .rpc('search_user_profiles', { search_query: query });

  if (error) throw error;
  return data;
}
```

**Create search function:**

```sql
-- Add to migration or run separately
CREATE OR REPLACE FUNCTION search_user_profiles(search_query TEXT)
RETURNS SETOF user_profiles
LANGUAGE sql
STABLE
AS $$
  SELECT *
  FROM user_profiles
  WHERE search_vector @@ plainto_tsquery('english', search_query)
  ORDER BY ts_rank(search_vector, plainto_tsquery('english', search_query)) DESC
  LIMIT 50;
$$;
```

### 9. Monitoring (24 hours)

**Metrics tracked:**
- Database CPU: Normal (15-20%)
- Database memory: Normal (35%)
- Query performance: All queries < 100ms
- Application errors: No increase
- User-reported issues: None

**Result:** ✅ Migration stable after 24 hours

---

## Lessons Learned

### What Went Well
- Comprehensive testing on staging prevented production issues
- Generated `search_vector` column simplified full-text search implementation
- RLS policies worked correctly on first deployment
- Transaction wrapping ensured atomic migration
- Verification queries caught potential issues early

### What Could Be Improved
- Should have created search function in initial migration (added after)
- Could have added more example data to staging for realistic search testing
- Should document common search query patterns for developers

### Action Items for Future Migrations
- Always include helper functions (like search functions) in initial migration
- Add more realistic test data to staging environment
- Create API usage examples as part of migration documentation
- Consider adding migration to CI/CD pipeline for automatic staging deployment
