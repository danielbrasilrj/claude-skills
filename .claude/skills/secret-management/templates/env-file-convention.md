# Environment File Convention Template

Standardized structure for managing environment variables across projects.

---

## File Hierarchy

```
.env                   # Shared defaults (committed) — NO SECRETS
.env.local             # Local overrides (NOT committed) — Secrets OK
.env.development       # Development environment (committed) — NO SECRETS
.env.staging           # Staging environment (NOT committed) — Secrets in vault
.env.production        # Production environment (NOT committed) — Secrets in vault
.env.test              # Test environment (committed) — Mock values only
.env.example           # Template for new developers (committed) — Shows structure
```

---

## .gitignore Configuration

```bash
# Environment files
.env.local
.env.*.local
.env.staging
.env.production

# Keep these committed (no secrets):
!.env
!.env.example
!.env.development
!.env.test
```

---

## Naming Conventions

### Client-Side Variables (Exposed to Browser)

These are safe to expose in client-side JavaScript bundles.

| Framework | Prefix | Example |
|---|---|---|
| Next.js | `NEXT_PUBLIC_` | `NEXT_PUBLIC_API_URL` |
| Vite | `VITE_` | `VITE_API_URL` |
| Create React App | `REACT_APP_` | `REACT_APP_API_URL` |
| Expo | `EXPO_PUBLIC_` | `EXPO_PUBLIC_API_URL` |
| Nuxt | `NUXT_PUBLIC_` | `NUXT_PUBLIC_API_URL` |

**Important:** NEVER use public prefixes for secrets!

### Server-Side Variables (Private)

No prefix required. Never exposed to client.

Examples:
- `DATABASE_URL`
- `API_SECRET_KEY`
- `STRIPE_SECRET_KEY`
- `JWT_SECRET`

---

## Template Structure

### .env.example (Committed)

This file shows the structure without real values. New developers copy this to `.env.local`.

```bash
# .env.example
# Copy this file to .env.local and fill in the values

# === APPLICATION ===
NODE_ENV=development
PORT=3000
APP_NAME=MyApp

# === DATABASE ===
DATABASE_URL=postgresql://user:password@localhost:5432/myapp
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=10

# === REDIS ===
REDIS_URL=redis://localhost:6379

# === AUTHENTICATION ===
JWT_SECRET=                                    # Generate with: openssl rand -base64 32
JWT_EXPIRY=1h
SESSION_SECRET=                                # Generate with: openssl rand -base64 32

# === THIRD-PARTY APIs ===
STRIPE_SECRET_KEY=                             # Get from: https://dashboard.stripe.com/apikeys
STRIPE_WEBHOOK_SECRET=                         # Get from: https://dashboard.stripe.com/webhooks
SENDGRID_API_KEY=                              # Get from: https://app.sendgrid.com/settings/api_keys
AWS_ACCESS_KEY_ID=                             # Get from: AWS IAM Console
AWS_SECRET_ACCESS_KEY=                         # Get from: AWS IAM Console
AWS_REGION=us-east-1

# === EXTERNAL SERVICES ===
SENTRY_DSN=                                    # Get from: https://sentry.io/settings/projects/
GOOGLE_ANALYTICS_ID=                           # Get from: https://analytics.google.com/

# === CLIENT-SIDE (Public) ===
NEXT_PUBLIC_API_URL=http://localhost:3000/api
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=            # Get from: https://dashboard.stripe.com/apikeys
NEXT_PUBLIC_GOOGLE_MAPS_KEY=                   # Get from: https://console.cloud.google.com/

# === FEATURE FLAGS ===
FEATURE_NEW_DASHBOARD=false
FEATURE_BETA_CHECKOUT=false
```

---

### .env (Committed — Shared Defaults)

Non-sensitive defaults that apply to all environments.

```bash
# .env
# Shared defaults (non-sensitive only)

NODE_ENV=development
PORT=3000
APP_NAME=MyApp

# Database
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=10

# Redis
REDIS_MAX_RETRIES=3

# JWT
JWT_EXPIRY=1h

# AWS
AWS_REGION=us-east-1

# Client-side
NEXT_PUBLIC_API_URL=http://localhost:3000/api
```

---

### .env.local (NOT Committed — Local Secrets)

Developer's personal secrets for local development.

```bash
# .env.local
# Local development secrets (NOT committed)

# Database
DATABASE_URL=postgresql://admin:localpass123@localhost:5432/myapp_dev

# Redis
REDIS_URL=redis://localhost:6379

# Authentication
JWT_SECRET=8f7a3c4e9b2d1a6f0e5c8b3a9d2f1e6c
SESSION_SECRET=3e9a7c2f8b4d1a5f0e6c9b2a8d3f1e7c

# Stripe (test keys)
STRIPE_SECRET_KEY=sk_test_51Abc...xyz
STRIPE_WEBHOOK_SECRET=whsec_123...xyz
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_51Abc...xyz

# SendGrid
SENDGRID_API_KEY=SG.abc123...xyz

# AWS (dev account)
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# Sentry (optional for local dev)
# SENTRY_DSN=https://abc@o123.ingest.sentry.io/456

# Feature flags (local overrides)
FEATURE_NEW_DASHBOARD=true
FEATURE_BETA_CHECKOUT=true
```

---

### .env.development (Committed — Shared Dev Config)

Shared development configuration (no secrets).

```bash
# .env.development
# Shared development config (committed, no secrets)

NODE_ENV=development
LOG_LEVEL=debug

# Use local services
NEXT_PUBLIC_API_URL=http://localhost:3000/api

# Feature flags (default for dev)
FEATURE_NEW_DASHBOARD=true
FEATURE_BETA_CHECKOUT=false
```

---

### .env.staging (NOT Committed — Retrieved from Vault)

Staging environment secrets (stored in vault, not in git).

```bash
# .env.staging
# Staging environment (NOT committed — stored in vault)

NODE_ENV=staging
LOG_LEVEL=info

# Database
DATABASE_URL=postgresql://appuser:VAULT_SECRET@staging-db.example.com:5432/myapp_staging

# Redis
REDIS_URL=redis://staging-redis.example.com:6379

# Authentication
JWT_SECRET=VAULT_SECRET
SESSION_SECRET=VAULT_SECRET

# Stripe (test mode)
STRIPE_SECRET_KEY=sk_test_VAULT_SECRET
STRIPE_WEBHOOK_SECRET=whsec_VAULT_SECRET
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_abc...xyz

# SendGrid
SENDGRID_API_KEY=SG.VAULT_SECRET

# AWS
AWS_ACCESS_KEY_ID=VAULT_SECRET
AWS_SECRET_ACCESS_KEY=VAULT_SECRET

# Sentry
SENTRY_DSN=https://VAULT_SECRET@o123.ingest.sentry.io/456

# Client-side
NEXT_PUBLIC_API_URL=https://api-staging.example.com

# Feature flags
FEATURE_NEW_DASHBOARD=true
FEATURE_BETA_CHECKOUT=true
```

---

### .env.production (NOT Committed — Retrieved from Vault)

Production environment secrets (stored in vault, not in git).

```bash
# .env.production
# Production environment (NOT committed — stored in vault)

NODE_ENV=production
LOG_LEVEL=warn

# Database
DATABASE_URL=postgresql://appuser:VAULT_SECRET@prod-db.example.com:5432/myapp_production

# Redis
REDIS_URL=redis://prod-redis.example.com:6379

# Authentication
JWT_SECRET=VAULT_SECRET
SESSION_SECRET=VAULT_SECRET

# Stripe (live mode)
STRIPE_SECRET_KEY=sk_live_VAULT_SECRET
STRIPE_WEBHOOK_SECRET=whsec_VAULT_SECRET
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_abc...xyz

# SendGrid
SENDGRID_API_KEY=SG.VAULT_SECRET

# AWS
AWS_ACCESS_KEY_ID=VAULT_SECRET
AWS_SECRET_ACCESS_KEY=VAULT_SECRET

# Sentry
SENTRY_DSN=https://VAULT_SECRET@o123.ingest.sentry.io/456

# Client-side
NEXT_PUBLIC_API_URL=https://api.example.com

# Feature flags
FEATURE_NEW_DASHBOARD=false
FEATURE_BETA_CHECKOUT=false
```

---

### .env.test (Committed — Mock Values)

Test environment with mock/dummy values.

```bash
# .env.test
# Test environment (committed — mock values only)

NODE_ENV=test
LOG_LEVEL=error

# Database (in-memory or test DB)
DATABASE_URL=postgresql://test:test@localhost:5433/myapp_test

# Redis (mock)
REDIS_URL=redis://localhost:6380

# Authentication (fixed test secrets)
JWT_SECRET=test_secret_for_unit_tests_only
SESSION_SECRET=test_session_secret_for_unit_tests_only

# Stripe (mock)
STRIPE_SECRET_KEY=sk_test_mock
STRIPE_WEBHOOK_SECRET=whsec_mock
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_mock

# SendGrid (mock)
SENDGRID_API_KEY=SG.mock

# AWS (mock)
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test

# Client-side
NEXT_PUBLIC_API_URL=http://localhost:3000/api

# Feature flags (all enabled for testing)
FEATURE_NEW_DASHBOARD=true
FEATURE_BETA_CHECKOUT=true
```

---

## Usage Patterns

### Loading Environment Variables

**Node.js (dotenv):**
```javascript
require('dotenv').config({ path: '.env.local' });
require('dotenv').config(); // Fallback to .env

// Access variables
const dbUrl = process.env.DATABASE_URL;
const jwtSecret = process.env.JWT_SECRET;
```

**Load based on NODE_ENV:**
```javascript
const envFile = process.env.NODE_ENV === 'production' 
  ? '.env.production' 
  : process.env.NODE_ENV === 'staging'
  ? '.env.staging'
  : '.env.local';

require('dotenv').config({ path: envFile });
require('dotenv').config(); // Fallback to .env
```

### Validation (Recommended)

Use a library like `envalid` to validate required variables at startup:

```javascript
const { cleanEnv, str, port, url } = require('envalid');

const env = cleanEnv(process.env, {
  NODE_ENV: str({ choices: ['development', 'test', 'staging', 'production'] }),
  PORT: port({ default: 3000 }),
  DATABASE_URL: url(),
  JWT_SECRET: str({ minLength: 32 }),
  STRIPE_SECRET_KEY: str({ devDefault: 'sk_test_mock' }),
});

module.exports = env;
```

**Usage:**
```javascript
const env = require('./config/env');

const app = express();
app.listen(env.PORT, () => {
  console.log(`Server running on port ${env.PORT}`);
});
```

---

## CI/CD Integration

### GitHub Actions (Secrets)

```yaml
name: Deploy
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Create .env.production
        run: |
          echo "DATABASE_URL=${{ secrets.DATABASE_URL }}" >> .env.production
          echo "JWT_SECRET=${{ secrets.JWT_SECRET }}" >> .env.production
          echo "STRIPE_SECRET_KEY=${{ secrets.STRIPE_SECRET_KEY }}" >> .env.production
      
      - name: Deploy
        run: ./deploy.sh
```

### Docker

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy only necessary env files
COPY .env .env
# .env.production is mounted as secret or volume at runtime

COPY package*.json ./
RUN npm ci --production

COPY . .

CMD ["node", "server.js"]
```

**Docker Compose:**
```yaml
services:
  app:
    build: .
    env_file:
      - .env
      - .env.production
    environment:
      - NODE_ENV=production
```

**Kubernetes (Secrets):**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  DATABASE_URL: "postgresql://user:pass@db:5432/myapp"
  JWT_SECRET: "abc123..."
  STRIPE_SECRET_KEY: "sk_live_..."
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:latest
        envFrom:
        - secretRef:
            name: app-secrets
```
API Error: Claude's response exceeded the 32000 output token maximum. To configure this behavior, set the CLAUDE_CODE_MAX_OUTPUT_TOKENS environment variable.
I'll continue generating the remaining files from where I left off.

===FILE: /Users/danielcarmo/Env/Projects/personal/claude_skills/claude_skills/.claude/skills/secret-management/examples/secret-management-setup-example.md===
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
