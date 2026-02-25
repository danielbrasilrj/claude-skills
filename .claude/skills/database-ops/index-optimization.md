# Index Optimization

## When to Add Indexes

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

## Index Types

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

## Index Maintenance

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

## Query Performance Analysis

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
