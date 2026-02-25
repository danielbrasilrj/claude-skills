# Backup Procedures

## 3-2-1 Backup Strategy

- **3** total copies of your data
- **2** different storage media/formats
- **1** copy offsite (different geographic region)

## PostgreSQL Backup Methods

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

## Supabase Backup

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

## Backup Verification Checklist

- [ ] Backup completed without errors
- [ ] Backup file size is reasonable (not 0 bytes, not suspiciously small)
- [ ] Test restore in isolated environment monthly
- [ ] Verify row counts match source database
- [ ] Verify backup is encrypted at rest
- [ ] Confirm backup is in offsite location
- [ ] Document restore procedure and test annually

## Backup Retention Policy

```
Daily backups: Keep 7 days
Weekly backups: Keep 4 weeks
Monthly backups: Keep 12 months
Yearly backups: Keep 7 years (compliance-dependent)
```

## Backup Verification Script

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

echo "Backup verified successfully"
```

## Emergency Rollback Procedures

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
