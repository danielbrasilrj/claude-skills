# Secret Management Setup Example

Complete walkthrough of setting up secret management for a new Node.js/React project from scratch.

**Project:** TaskFlow - A task management SaaS application  
**Stack:** Next.js, PostgreSQL, Redis, Stripe payments  
**Environments:** Development, Staging, Production

---

## Step 1: Initialize Project Structure

```bash
# Create project
npx create-next-app@latest taskflow
cd taskflow

# Install dependencies
npm install dotenv envalid
npm install --save-dev @types/node
```

---

## Step 2: Set Up Environment Files

### Create .env.example

```bash
# .env.example
# Copy to .env.local and fill in values

# === APPLICATION ===
NODE_ENV=development
PORT=3000

# === DATABASE ===
DATABASE_URL=postgresql://user:password@localhost:5432/taskflow

# === REDIS ===
REDIS_URL=redis://localhost:6379

# === AUTHENTICATION ===
JWT_SECRET=                                    # Generate: openssl rand -base64 32
SESSION_SECRET=                                # Generate: openssl rand -base64 32

# === STRIPE ===
STRIPE_SECRET_KEY=                             # From: https://dashboard.stripe.com/apikeys
STRIPE_WEBHOOK_SECRET=                         # From: https://dashboard.stripe.com/webhooks
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=            # From: https://dashboard.stripe.com/apikeys

# === EMAIL (SendGrid) ===
SENDGRID_API_KEY=                              # From: https://app.sendgrid.com/settings/api_keys
SENDGRID_FROM_EMAIL=noreply@taskflow.com

# === CLIENT-SIDE ===
NEXT_PUBLIC_API_URL=http://localhost:3000/api
```

### Create .env (committed defaults)

```bash
# .env
NODE_ENV=development
PORT=3000
SENDGRID_FROM_EMAIL=noreply@taskflow.com
NEXT_PUBLIC_API_URL=http://localhost:3000/api
```

### Create .env.local (developer secrets)

```bash
# Generate secrets
openssl rand -base64 32  # For JWT_SECRET
openssl rand -base64 32  # For SESSION_SECRET

# .env.local
DATABASE_URL=postgresql://admin:devpass123@localhost:5432/taskflow_dev
REDIS_URL=redis://localhost:6379

JWT_SECRET=Kx8f3mP9qR2tY5wZ7bN4jL1hG6dA0sC3
SESSION_SECRET=P9mT7kL2fG5hJ8qR3nB6wY1zA4sD0xC7

STRIPE_SECRET_KEY=sk_test_51Abc123...xyz
STRIPE_WEBHOOK_SECRET=whsec_123...xyz
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_51Abc123...xyz

SENDGRID_API_KEY=SG.abc123def456...xyz
```

---

## Step 3: Update .gitignore

```bash
# .gitignore
# Environment files with secrets
.env.local
.env*.local
.env.staging
.env.production

# Keep committed
!.env
!.env.example
```

---

## Step 4: Create Environment Validation

```javascript
// lib/env.js
const { cleanEnv, str, port, url, email } = require('envalid');

const env = cleanEnv(process.env, {
  NODE_ENV: str({ choices: ['development', 'test', 'staging', 'production'] }),
  PORT: port({ default: 3000 }),
  
  // Database
  DATABASE_URL: url(),
  REDIS_URL: url(),
  
  // Authentication
  JWT_SECRET: str({ minLength: 32 }),
  SESSION_SECRET: str({ minLength: 32 }),
  
  // Stripe
  STRIPE_SECRET_KEY: str({ devDefault: 'sk_test_mock' }),
  STRIPE_WEBHOOK_SECRET: str({ devDefault: 'whsec_mock' }),
  NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY: str({ devDefault: 'pk_test_mock' }),
  
  // SendGrid
  SENDGRID_API_KEY: str({ devDefault: 'SG.mock' }),
  SENDGRID_FROM_EMAIL: email(),
  
  // Client-side
  NEXT_PUBLIC_API_URL: url(),
});

module.exports = env;
```

**Usage in application:**
```javascript
// pages/api/auth/login.js
const env = require('../../../lib/env');
const jwt = require('jsonwebtoken');

export default async function handler(req, res) {
  // Use validated env vars
  const token = jwt.sign({ userId: user.id }, env.JWT_SECRET, {
    expiresIn: '1h'
  });
  
  res.json({ token });
}
```

---

## Step 5: Set Up Secret Scanning (gitleaks)

```bash
# Install gitleaks
brew install gitleaks

# Install pre-commit
pip install pre-commit

# Create pre-commit config
cat > .pre-commit-config.yaml <<EOF
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
EOF

# Install hooks
pre-commit install

# Test (should pass)
git add .
git commit -m "Initial setup"
```

**Create .gitleaks.toml (custom config):**
```toml
[extend]
useDefault = true

[allowlist]
description = "Allowlist for test files"
paths = [
  '''.*\.example''',
  '''.*\.test\.js''',
  '''.*\.spec\.js'''
]

[[allowlist.regexes]]
description = "Ignore placeholder values"
regex = '''(YOUR_|REPLACE_|EXAMPLE_|TODO_|MOCK_)'''
```

---

## Step 6: Set Up HashiCorp Vault (Staging/Production)

### Install and Initialize Vault

```bash
# Install Vault
brew install vault

# Start Vault in dev mode (for testing)
vault server -dev

# In another terminal, set VAULT_ADDR
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'  # Use root token from server output

# Enable KV secrets engine
vault secrets enable -path=taskflow kv-v2

# Store staging secrets
vault kv put taskflow/staging \
  database_url='postgresql://appuser:STAGING_PASS@staging-db.example.com:5432/taskflow' \
  jwt_secret='$(openssl rand -base64 32)' \
  session_secret='$(openssl rand -base64 32)' \
  stripe_secret_key='sk_test_STAGING_KEY' \
  stripe_webhook_secret='whsec_STAGING_SECRET' \
  sendgrid_api_key='SG.STAGING_KEY'

# Store production secrets
vault kv put taskflow/production \
  database_url='postgresql://appuser:PROD_PASS@prod-db.example.com:5432/taskflow' \
  jwt_secret='$(openssl rand -base64 32)' \
  session_secret='$(openssl rand -base64 32)' \
  stripe_secret_key='sk_live_PROD_KEY' \
  stripe_webhook_secret='whsec_PROD_SECRET' \
  sendgrid_api_key='SG.PROD_KEY'
```

### Create AppRole for CI/CD

```bash
# Enable AppRole auth
vault auth enable approle

# Create policy
vault policy write taskflow-policy - <<EOF
path "taskflow/data/staging" {
  capabilities = ["read"]
}
path "taskflow/data/production" {
  capabilities = ["read"]
}
EOF

# Create AppRole
vault write auth/approle/role/taskflow \
  token_policies="taskflow-policy" \
  token_ttl=1h \
  token_max_ttl=4h

# Get Role ID (store in GitHub Secrets as VAULT_ROLE_ID)
vault read auth/approle/role/taskflow/role-id

# Generate Secret ID (store in GitHub Secrets as VAULT_SECRET_ID)
vault write -f auth/approle/role/taskflow/secret-id
```

---

## Step 7: Set Up GitHub Actions (CI/CD)

### Add GitHub Secrets

Go to GitHub repo → Settings → Secrets and variables → Actions → New repository secret:

- `VAULT_ADDR`: `https://vault.example.com:8200`
- `VAULT_ROLE_ID`: `(from step 6)`
- `VAULT_SECRET_ID`: `(from step 6)`

### Create Deployment Workflow

```yaml
# .github/workflows/deploy-staging.yml
name: Deploy to Staging

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Vault CLI
        run: |
          wget https://releases.hashicorp.com/vault/1.14.0/vault_1.14.0_linux_amd64.zip
          unzip vault_1.14.0_linux_amd64.zip
          sudo mv vault /usr/local/bin/
      
      - name: Fetch secrets from Vault
        env:
          VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
          VAULT_ROLE_ID: ${{ secrets.VAULT_ROLE_ID }}
          VAULT_SECRET_ID: ${{ secrets.VAULT_SECRET_ID }}
        run: |
          # Login to Vault
          export VAULT_TOKEN=$(vault write -field=token auth/approle/login \
            role_id="${VAULT_ROLE_ID}" \
            secret_id="${VAULT_SECRET_ID}")
          
          # Fetch secrets and create .env.staging
          vault kv get -format=json taskflow/staging | jq -r '.data.data | to_entries[] | "\(.key | ascii_upcase)=\(.value)"' > .env.staging
          
          # Add public env vars
          echo "NODE_ENV=staging" >> .env.staging
          echo "NEXT_PUBLIC_API_URL=https://api-staging.taskflow.com" >> .env.staging
          echo "NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_staging..." >> .env.staging
      
      - name: Build application
        run: npm run build
      
      - name: Deploy to staging
        run: |
          # Deploy to your hosting platform (Vercel, AWS, etc.)
          echo "Deploying to staging..."
```

---

## Step 8: Set Up Mobile App Secret Storage (React Native)

### iOS (Keychain)

```bash
# Install expo-secure-store
npx expo install expo-secure-store
```

```javascript
// lib/secureStorage.js
import * as SecureStore from 'expo-secure-store';

export async function saveToken(token) {
  await SecureStore.setItemAsync('auth_token', token);
}

export async function getToken() {
  return await SecureStore.getItemAsync('auth_token');
}

export async function removeToken() {
  await SecureStore.deleteItemAsync('auth_token');
}

// Usage in login
import { saveToken } from './lib/secureStorage';

async function handleLogin(email, password) {
  const response = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });
  
  const { token } = await response.json();
  await saveToken(token);
}
```

### Android (EncryptedSharedPreferences)

Already handled by `expo-secure-store` on Android.

---

## Step 9: Implement Secret Rotation

### Database Password Rotation Script

```bash
#!/bin/bash
# scripts/rotate-db-password.sh

set -euo pipefail

ENVIRONMENT="$1"  # staging or production
VAULT_PATH="taskflow/${ENVIRONMENT}"

echo "🔄 Rotating database password for ${ENVIRONMENT}"

# Fetch current config from Vault
CURRENT=$(vault kv get -format=json "${VAULT_PATH}" | jq -r '.data.data')
DB_URL=$(echo "${CURRENT}" | jq -r '.database_url')
DB_USER=$(echo "${DB_URL}" | sed -n 's|postgresql://\([^:]*\):.*|\1|p')
DB_HOST=$(echo "${DB_URL}" | sed -n 's|.*@\([^:]*\):.*|\1|p')
DB_NAME=$(echo "${DB_URL}" | sed -n 's|.*/\([^?]*\).*|\1|p')

# Generate new password
NEW_PASSWORD=$(openssl rand -base64 32)

# Update in database
PGPASSWORD="${OLD_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" <<EOF
ALTER USER ${DB_USER} WITH PASSWORD '${NEW_PASSWORD}';
EOF

# Update in Vault
NEW_DB_URL="postgresql://${DB_USER}:${NEW_PASSWORD}@${DB_HOST}:5432/${DB_NAME}"
vault kv patch "${VAULT_PATH}" database_url="${NEW_DB_URL}"

# Test new credentials
PGPASSWORD="${NEW_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT 1;" > /dev/null

echo "✅ Password rotated successfully"
echo "📅 Next rotation: $(date -d '+90 days' '+%Y-%m-%d')"

# Trigger redeployment to pick up new credentials
echo "🚀 Triggering redeployment..."
curl -X POST "https://api.github.com/repos/myorg/taskflow/actions/workflows/deploy-${ENVIRONMENT}.yml/dispatches" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"ref\":\"main\"}"
```

**Schedule with cron:**
```bash
# crontab -e
# Rotate staging DB password every 30 days
0 2 1 * * /opt/taskflow/scripts/rotate-db-password.sh staging >> /var/log/rotation.log 2>&1

# Rotate production DB password every 90 days
0 2 1 */3 * /opt/taskflow/scripts/rotate-db-password.sh production >> /var/log/rotation.log 2>&1
```

---

## Step 10: Audit and Monitoring

### Secret Access Audit (Vault)

```bash
# Enable audit logging
vault audit enable file file_path=/var/log/vault-audit.log

# View recent secret access
tail -f /var/log/vault-audit.log | jq 'select(.request.path | contains("taskflow"))'
```

### Monitor for Leaked Secrets (GitHub)

Enable GitHub secret scanning:
1. Go to repo Settings → Code security and analysis
2. Enable "Secret scanning"
3. Enable "Push protection"

### Set Up Alerts

```javascript
// lib/secretMonitoring.js
const Sentry = require('@sentry/node');

function validateSecretPresence() {
  const requiredSecrets = [
    'DATABASE_URL',
    'JWT_SECRET',
    'SESSION_SECRET',
    'STRIPE_SECRET_KEY'
  ];
  
  const missing = requiredSecrets.filter(key => !process.env[key]);
  
  if (missing.length > 0) {
    const error = new Error(`Missing required secrets: ${missing.join(', ')}`);
    Sentry.captureException(error);
    throw error;
  }
}

// Call on application startup
validateSecretPresence();
```

---

## Step 11: Documentation for Team

### Create README section

```markdown
## Environment Setup

### New Developer Setup

1. Copy environment template:
   ```bash
   cp .env.example .env.local
   ```

2. Fill in secrets:
   - Database: Start local PostgreSQL or get credentials from team lead
   - Stripe: Use test keys from https://dashboard.stripe.com/test/apikeys
   - SendGrid: Get API key from team lead or create test account

3. Generate auth secrets:
   ```bash
   openssl rand -base64 32  # JWT_SECRET
   openssl rand -base64 32  # SESSION_SECRET
   ```

4. Start development server:
   ```bash
   npm run dev
   ```

### Accessing Staging/Production Secrets

Secrets are stored in HashiCorp Vault. Contact DevOps team for access.

**DO NOT commit secrets to git.** The pre-commit hook will block commits with secrets.

### Rotating Secrets

See `docs/secret-rotation.md` for rotation procedures.
```

---

## Step 12: Testing the Setup

### Test secret validation

```javascript
// __tests__/env.test.js
describe('Environment validation', () => {
  it('should fail if JWT_SECRET is missing', () => {
    delete process.env.JWT_SECRET;
    expect(() => require('../lib/env')).toThrow('Missing required secrets');
  });
  
  it('should fail if JWT_SECRET is too short', () => {
    process.env.JWT_SECRET = 'short';
    expect(() => require('../lib/env')).toThrow();
  });
});
```

### Test secret scanning

```bash
# Intentionally add a fake secret to test gitleaks
echo "STRIPE_SECRET_KEY=sk_live_12345678901234567890" > test-secret.txt
git add test-secret.txt
git commit -m "Test secret scanning"

# Should be blocked by pre-commit hook
# Output: ○ ․ ․ Gitleaks................Passed
```

---

## Summary

You've now set up complete secret management for TaskFlow:

✅ Environment file structure (.env.example, .env.local, etc.)  
✅ Secret validation with envalid  
✅ Secret scanning with gitleaks + pre-commit hooks  
✅ HashiCorp Vault for staging/production secrets  
✅ GitHub Actions CI/CD with Vault integration  
✅ Mobile app secure storage (Keychain/KeyStore)  
✅ Automated secret rotation scripts  
✅ Audit logging and monitoring  
✅ Team documentation  

**Next Steps:**
- Set up Vault HA cluster for production
- Implement secret rotation for all third-party API keys
- Add secret expiry monitoring and alerts
- Train team on secret management best practices

---

## Troubleshooting

**Issue:** "Missing required secrets" error on startup  
**Fix:** Verify .env.local exists and contains all required variables from .env.example

**Issue:** Pre-commit hook not running  
**Fix:** Run `pre-commit install` to reinstall hooks

**Issue:** Vault connection timeout in CI/CD  
**Fix:** Check VAULT_ADDR is correct and Vault is accessible from GitHub Actions runners

**Issue:** Database password rotation failed  
**Fix:** Verify current password is correct in Vault, check database user has ALTER USER permission
