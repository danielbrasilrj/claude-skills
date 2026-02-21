# Database Migration Checklist

## Migration Information

**Migration ID:** `YYYYMMDD_HHMMSS_description`  
**Author:** `[Your Name]`  
**Date:** `[YYYY-MM-DD]`  
**Database:** `[dev/staging/production]`  
**Estimated Duration:** `[X minutes for Y rows]`

**Description:**
[Brief description of what this migration does and why]

**Tables Affected:**
- [ ] `table_name_1` - [what changes]
- [ ] `table_name_2` - [what changes]

---

## Pre-Migration Phase

### 1. Code Review
- [ ] Migration follows up/down pattern
- [ ] Both UP and DOWN scripts are present and tested
- [ ] All SQL statements are wrapped in transactions
- [ ] No raw DELETE/DROP without WHERE clauses
- [ ] Foreign key constraints verified
- [ ] Index names follow convention: `idx_tablename_columnname`

### 2. Testing on Staging
- [ ] Staging database has production-like data volume
- [ ] UP migration runs successfully on staging
- [ ] Application still works after migration
- [ ] DOWN migration (rollback) tested successfully
- [ ] Application works after rollback
- [ ] Performance impact measured (query execution time)

### 3. Backup Verification
- [ ] Recent backup exists (< 24 hours old)
- [ ] Backup file size is reasonable (not 0 bytes)
- [ ] Test restore completed successfully
- [ ] Backup stored in offsite location
- [ ] Backup retention policy confirmed

**Backup Details:**
```bash
Backup file: [path/to/backup.dump]
Backup size: [XXX MB]
Backup date: [YYYY-MM-DD HH:MM:SS]
Row counts verified: [YES/NO]
```

### 4. Impact Analysis
- [ ] Estimated number of affected rows documented
- [ ] Cascading deletes analyzed (if applicable)
- [ ] Locking behavior understood
- [ ] Estimated downtime calculated
- [ ] Peak traffic time avoided (schedule off-peak)

**Affected Rows Estimate:**
```sql
-- Run on production (read-only query)
SELECT 'table_name', COUNT(*) FROM table_name WHERE [conditions];
```

**Result:** `[X rows will be affected]`

### 5. Rollback Plan
- [ ] DOWN script tested on staging
- [ ] Rollback steps documented below
- [ ] Team trained on rollback procedure
- [ ] Rollback triggers identified (what indicates failure)

**Rollback Triggers:**
- Application errors increase > X%
- Database CPU/memory spikes > X%
- Query time exceeds X seconds
- Foreign key violations detected

---

## Migration Execution Phase

### 6. Pre-Execution Checks
- [ ] Correct database connection verified (dev/staging/production)
- [ ] Database version confirmed: `SELECT version();`
- [ ] Current schema version noted: `[version number]`
- [ ] All team members notified of migration window
- [ ] Monitoring dashboards open (database CPU, memory, connections)

### 7. Execution
**Start Time:** `[YYYY-MM-DD HH:MM:SS]`

```bash
# Run migration
psql -h [host] -U [user] -d [database] -f up_migration.sql

# Or using migration tool
npx prisma migrate deploy
# or
npx drizzle-kit push:pg
```

**Execution Log:**
```
[Paste command output here]
```

**End Time:** `[YYYY-MM-DD HH:MM:SS]`  
**Duration:** `[X minutes Y seconds]`

### 8. Post-Execution Verification
- [ ] Migration completed without errors
- [ ] Transaction committed successfully
- [ ] Row counts match expectations
- [ ] Indexes created successfully
- [ ] Foreign key constraints validated
- [ ] Application starts without errors
- [ ] Critical user flows tested (manual smoke test)
- [ ] No error spikes in monitoring

**Row Count Verification:**
```sql
-- Expected vs Actual
SELECT 
    'table_name' AS table_name,
    COUNT(*) AS actual_count,
    [expected_count] AS expected_count
FROM table_name;
```

**Result:** `[PASS/FAIL - explanation]`

### 9. Performance Verification
- [ ] Query performance unchanged or improved
- [ ] No slow query alerts triggered
- [ ] Database CPU/memory within normal range
- [ ] Connection pool not exhausted

**Performance Check:**
```sql
-- Run key queries and compare execution time to baseline
EXPLAIN ANALYZE
SELECT * FROM [table] WHERE [conditions];
```

**Baseline:** `[X ms]`  
**After Migration:** `[X ms]`  
**Result:** `[PASS/FAIL]`

---

## Post-Migration Phase

### 10. RLS Policy Updates (Supabase only)
- [ ] RLS policies updated for new schema
- [ ] New columns indexed if used in policies
- [ ] Policy performance tested
- [ ] Policies validated with test users

### 11. Application Deployment
- [ ] Application code updated to use new schema
- [ ] Environment variables updated (if needed)
- [ ] Application deployed to production
- [ ] Health checks passing
- [ ] No 500 errors in logs

### 12. Monitoring (24-48 hours)
- [ ] Database metrics monitored (CPU, memory, connections)
- [ ] Application error rates monitored
- [ ] Slow query logs reviewed
- [ ] User-reported issues tracked

**Monitoring Period:** `[Date range]`  
**Issues Found:** `[None / List issues]`

### 13. Cleanup (if applicable)
- [ ] Old indexes dropped (if replaced)
- [ ] Old columns dropped (after grace period)
- [ ] Temporary tables/functions removed
- [ ] Migration logs archived

---

## Rollback Procedure (if needed)

### When to Rollback
Rollback immediately if:
- Application error rate increases > 10%
- Database CPU/memory > 80% sustained
- Foreign key violations detected
- Data integrity issues found
- User-facing features broken

### Rollback Steps

**Step 1: Stop Application Writes**
```bash
# Scale down application or enable maintenance mode
[Commands specific to your deployment]
```

**Step 2: Run DOWN Migration**
```bash
psql -h [host] -U [user] -d [database] -f down_migration.sql
```

**Step 3: Verify Rollback**
```sql
-- Verify schema reverted
SELECT column_name FROM information_schema.columns 
WHERE table_name = '[table]';

-- Verify row counts
SELECT COUNT(*) FROM [table];
```

**Step 4: Restart Application**
```bash
# Deploy previous application version
[Commands specific to your deployment]
```

**Step 5: Verify Application**
- [ ] Application starts successfully
- [ ] Critical user flows working
- [ ] No error spikes in monitoring

---

## Sign-Off

**Migration executed by:** `[Name]`  
**Reviewed by:** `[Name]`  
**Status:** `[SUCCESS / ROLLED BACK / FAILED]`  
**Notes:**
```
[Any additional notes, lessons learned, or issues encountered]
```

**Final Row Counts (for audit trail):**
```sql
-- Run after migration or rollback
SELECT 
    schemaname,
    tablename,
    n_live_tup AS row_count
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

**Result:**
```
[Paste output here]
```

---

## Lessons Learned

**What went well:**
- [List]

**What could be improved:**
- [List]

**Action items for future migrations:**
- [List]
