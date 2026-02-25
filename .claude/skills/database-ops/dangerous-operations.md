# Dangerous Operation Safeguards

## Pre-Flight Checklist for Destructive Operations

Before running DELETE, DROP, TRUNCATE, or ALTER operations:

```
DESTRUCTIVE OPERATION DETECTED
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

Type "CONFIRM DELETE" to proceed: _______
```

## Safe Deletion Pattern

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

## Cascading Delete Prevention

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

## Transaction Timeout Protection

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
