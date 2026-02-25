# Secret Rotation Automation

## Database Credential Rotation Script

```bash
#!/bin/bash
# rotate-db-password.sh

set -euo pipefail

DB_USER="app_user"
DB_HOST="db.example.com"
DB_NAME="production"
VAULT_PATH="secret/data/myapp/db"

# Generate new password
NEW_PASSWORD=$(openssl rand -base64 32)

# Connect to database and update password
PGPASSWORD="${OLD_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" <<EOF
ALTER USER ${DB_USER} WITH PASSWORD '${NEW_PASSWORD}';
EOF

# Update in Vault
vault kv put "${VAULT_PATH}" \
  username="${DB_USER}" \
  password="${NEW_PASSWORD}" \
  host="${DB_HOST}" \
  port=5432 \
  database="${DB_NAME}"

# Test new credentials
PGPASSWORD="${NEW_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT 1;" > /dev/null

echo "Password rotated successfully"

# Notify team
curl -X POST https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK \
  -H 'Content-Type: application/json' \
  -d "{\"text\":\"Database password rotated for ${DB_USER}@${DB_HOST}\"}"
```

## API Key Rotation (Zero-Downtime)

```bash
#!/bin/bash
# rotate-api-key.sh - Zero-downtime rotation with dual-key support

set -euo pipefail

SERVICE_NAME="external-api"
VAULT_PATH="secret/data/myapp/api-keys/${SERVICE_NAME}"

# Read current keys
CURRENT=$(vault kv get -format=json "${VAULT_PATH}")
PRIMARY_KEY=$(echo "${CURRENT}" | jq -r '.data.data.primary')
SECONDARY_KEY=$(echo "${CURRENT}" | jq -r '.data.data.secondary // empty')

# Generate new key
NEW_KEY=$(curl -X POST https://api.external-service.com/keys \
  -H "Authorization: Bearer ${PRIMARY_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"name":"'"${SERVICE_NAME}-$(date +%Y%m%d)"'"}' | jq -r '.api_key')

# Store new key as secondary
vault kv put "${VAULT_PATH}" \
  primary="${PRIMARY_KEY}" \
  secondary="${NEW_KEY}"

echo "Waiting for deployment to pick up secondary key (5 minutes)..."
sleep 300

# Promote secondary to primary
vault kv put "${VAULT_PATH}" \
  primary="${NEW_KEY}" \
  secondary="${PRIMARY_KEY}"

echo "Waiting for all instances to use new primary key (5 minutes)..."
sleep 300

# Revoke old key
if [ -n "${PRIMARY_KEY}" ]; then
  curl -X DELETE "https://api.external-service.com/keys/${PRIMARY_KEY}" \
    -H "Authorization: Bearer ${NEW_KEY}"
fi

# Remove secondary (old key)
vault kv put "${VAULT_PATH}" primary="${NEW_KEY}"

echo "API key rotated successfully"
```

## Automated Rotation with Cron

```bash
# crontab -e
# Rotate database password every 90 days at 2 AM
0 2 1 */3 * /opt/scripts/rotate-db-password.sh >> /var/log/rotation.log 2>&1

# Rotate API keys every 30 days at 3 AM
0 3 1 * * /opt/scripts/rotate-api-key.sh >> /var/log/rotation.log 2>&1
```
