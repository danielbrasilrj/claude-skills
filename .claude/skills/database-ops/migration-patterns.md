# Migration Patterns

## Up/Down Migration Structure

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

## Migration Best Practices

**Pre-Migration Checklist:**

- Always test on a staging environment with production-like data volume
- Estimate migration duration (1M rows ~ 1-5 minutes depending on complexity)
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

## Zero-Downtime Migrations

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
