# Secret Management Reference

Comprehensive reference for managing secrets, credentials, and sensitive configuration across all environments.

## Table of Contents

- [HashiCorp Vault Patterns](#hashicorp-vault-patterns)
- [AWS Secrets Manager](#aws-secrets-manager)
- [1Password CLI Integration](#1password-cli-integration)
- [Secret Rotation Automation](#secret-rotation-automation)
- [OIDC Federation Deep Dive](#oidc-federation-deep-dive)
- [Secret Scanning Tools Comparison](#secret-scanning-tools-comparison)
- [Platform-Specific Secure Storage](#platform-specific-secure-storage)

---

## HashiCorp Vault Patterns

### Setup and Configuration

**Install Vault:**
```bash
# macOS
brew install vault

# Linux
wget https://releases.hashicorp.com/vault/1.14.0/vault_1.14.0_linux_amd64.zip
unzip vault_1.14.0_linux_amd64.zip
sudo mv vault /usr/local/bin/

# Docker (dev mode)
docker run --cap-add=IPC_LOCK -d --name=vault -p 8200:8200 vault
```

**Initialize Vault (production):**
```bash
# Start Vault server
vault server -config=vault-config.hcl

# Initialize (first time only)
vault operator init -key-shares=5 -key-threshold=3

# Save the unseal keys and root token securely!
# Unseal keys: Used to unseal Vault after restart
# Root token: Used for initial configuration

# Unseal Vault (requires 3 of 5 keys)
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>

# Login with root token
vault login <root_token>
```

**Vault Configuration (vault-config.hcl):**
```hcl
storage "raft" {
  path    = "/vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "false"
  tls_cert_file = "/vault/tls/cert.pem"
  tls_key_file  = "/vault/tls/key.pem"
}

api_addr = "https://vault.example.com:8200"
cluster_addr = "https://vault.example.com:8201"
ui = true

seal "awskms" {
  region     = "us-east-1"
  kms_key_id = "12345678-1234-1234-1234-123456789012"
}
```

### Key-Value Secrets Engine

```bash
# Enable KV v2 secrets engine
vault secrets enable -path=secret kv-v2

# Write a secret
vault kv put secret/myapp/config \
  db_password=super_secret_password \
  api_key=sk_live_123456789

# Read a secret
vault kv get secret/myapp/config
vault kv get -field=db_password secret/myapp/config

# List secrets
vault kv list secret/myapp

# Delete a secret (soft delete, can be recovered)
vault kv delete secret/myapp/config

# Permanently delete (including all versions)
vault kv metadata delete secret/myapp/config

# Read specific version
vault kv get -version=2 secret/myapp/config
```

### Dynamic Database Credentials

**Enable and configure database secrets engine:**
```bash
# Enable database secrets engine
vault secrets enable database

# Configure PostgreSQL connection
vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  allowed_roles="readonly,readwrite" \
  connection_url="postgresql://{{username}}:{{password}}@localhost:5432/mydb" \
  username="vault_admin" \
  password="vault_admin_password"

# Create a role that generates readonly credentials
vault write database/roles/readonly \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="1h" \
  max_ttl="24h"

# Generate credentials
vault read database/creds/readonly
# Output:
# Key                Value
# ---                -----
# lease_id           database/creds/readonly/abc123
# lease_duration     1h
# username           v-root-readonly-abc123def456
# password           A1a-xyz789randompassword
```

**Use dynamic credentials in application:**
```javascript
const vault = require('node-vault')({
  endpoint: 'https://vault.example.com:8200',
  token: process.env.VAULT_TOKEN
});

async function getDatabaseCredentials() {
  const result = await vault.read('database/creds/readonly');
  return {
    username: result.data.username,
    password: result.data.password,
    lease_id: result.lease_id,
    lease_duration: result.lease_duration
  };
}

// Renew lease before it expires
async function renewLease(leaseId) {
  await vault.write('sys/leases/renew', {
    lease_id: leaseId,
    increment: 3600 // 1 hour
  });
}

// Usage
const creds = await getDatabaseCredentials();
const db = createDatabaseConnection(creds.username, creds.password);

// Renew lease every 50 minutes (before 1 hour expiry)
setInterval(() => renewLease(creds.lease_id), 50 * 60 * 1000);
```

### AppRole Authentication (for applications)

```bash
# Enable AppRole auth method
vault auth enable approle

# Create a policy
vault policy write myapp-policy - <<EOF
path "secret/data/myapp/*" {
  capabilities = ["read"]
}
path "database/creds/readonly" {
  capabilities = ["read"]
}
EOF

# Create an AppRole
vault write auth/approle/role/myapp \
  token_policies="myapp-policy" \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_ttl=0

# Get Role ID (store in CI/CD variable)
vault read auth/approle/role/myapp/role-id
# Output: role_id = 12345678-1234-1234-1234-123456789012

# Generate Secret ID (store in CI/CD variable, rotate regularly)
vault write -f auth/approle/role/myapp/secret-id
# Output: secret_id = abcdef12-3456-7890-abcd-ef1234567890
```

**Application login:**
```javascript
const vault = require('node-vault')();

async function loginToVault() {
  const result = await vault.approleLogin({
    role_id: process.env.VAULT_ROLE_ID,
    secret_id: process.env.VAULT_SECRET_ID
  });
  
  // Store token for future requests
  vault.token = result.auth.client_token;
  return result.auth;
}

// Usage
await loginToVault();
const secret = await vault.read('secret/data/myapp/config');
console.log(secret.data.data);
```

### Transit Secrets Engine (Encryption as a Service)

```bash
# Enable transit engine
vault secrets enable transit

# Create encryption key
vault write -f transit/keys/myapp-key

# Encrypt data
vault write transit/encrypt/myapp-key plaintext=$(echo "sensitive data" | base64)
# Output: ciphertext = vault:v1:abc123...

# Decrypt data
vault write transit/decrypt/myapp-key ciphertext="vault:v1:abc123..."
# Output: plaintext = c2Vuc2l0aXZlIGRhdGE= (base64)

# Rotate encryption key
vault write -f transit/keys/myapp-key/rotate

# Rewrap data with new key version
vault write transit/rewrap/myapp-key ciphertext="vault:v1:abc123..."
# Output: ciphertext = vault:v2:def456... (new version)
```

---

## AWS Secrets Manager

### Setup and Basic Usage

**Create a secret:**
```bash
aws secretsmanager create-secret \
  --name myapp/production/db \
  --description "Production database credentials" \
  --secret-string '{
    "username":"admin",
    "password":"SuperSecretPassword123!",
    "engine":"postgres",
    "host":"db.example.com",
    "port":5432,
    "dbname":"production"
  }'
```

**Retrieve a secret:**
```bash
aws secretsmanager get-secret-value \
  --secret-id myapp/production/db \
  --query SecretString \
  --output text
```

**Update a secret:**
```bash
aws secretsmanager update-secret \
  --secret-id myapp/production/db \
  --secret-string '{
    "username":"admin",
    "password":"NewSuperSecretPassword456!",
    "engine":"postgres",
    "host":"db.example.com",
    "port":5432,
    "dbname":"production"
  }'
```

### Automatic Rotation

**Enable rotation with Lambda:**
```bash
# Create rotation function (AWS provides templates)
aws lambda create-function \
  --function-name RotateMyAppDBSecret \
  --runtime python3.9 \
  --role arn:aws:iam::123456789012:role/LambdaSecretsManagerRole \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://rotation-function.zip \
  --timeout 30

# Enable automatic rotation
aws secretsmanager rotate-secret \
  --secret-id myapp/production/db \
  --rotation-lambda-arn arn:aws:lambda:us-east-1:123456789012:function:RotateMyAppDBSecret \
  --rotation-rules AutomaticallyAfterDays=30
```

**Rotation Lambda (PostgreSQL example):**
```python
import boto3
import psycopg2
import json
import os

secrets_manager = boto3.client('secretsmanager')

def lambda_handler(event, context):
    secret_arn = event['SecretId']
    token = event['ClientRequestToken']
    step = event['Step']
    
    if step == "createSecret":
        create_secret(secret_arn, token)
    elif step == "setSecret":
        set_secret(secret_arn, token)
    elif step == "testSecret":
        test_secret(secret_arn, token)
    elif step == "finishSecret":
        finish_secret(secret_arn, token)

def create_secret(arn, token):
    # Get current secret
    current = secrets_manager.get_secret_value(SecretId=arn)
    current_dict = json.loads(current['SecretString'])
    
    # Generate new password
    new_password = secrets_manager.get_random_password(
        PasswordLength=32,
        ExcludeCharacters='"@/\\'
    )['RandomPassword']
    
    # Create new secret version
    current_dict['password'] = new_password
    secrets_manager.put_secret_value(
        SecretId=arn,
        ClientRequestToken=token,
        SecretString=json.dumps(current_dict),
        VersionStages=['AWSPENDING']
    )

def set_secret(arn, token):
    # Get pending secret
    pending = secrets_manager.get_secret_value(
        SecretId=arn,
        VersionId=token,
        VersionStage='AWSPENDING'
    )
    pending_dict = json.loads(pending['SecretString'])
    
    # Get current secret for connection
    current = secrets_manager.get_secret_value(
        SecretId=arn,
        VersionStage='AWSCURRENT'
    )
    current_dict = json.loads(current['SecretString'])
    
    # Connect with current credentials and update password
    conn = psycopg2.connect(
        host=current_dict['host'],
        port=current_dict['port'],
        user=current_dict['username'],
        password=current_dict['password'],
        database=current_dict['dbname']
    )
    cursor = conn.cursor()
    cursor.execute(
        f"ALTER USER {pending_dict['username']} WITH PASSWORD %s",
        (pending_dict['password'],)
    )
    conn.commit()
    conn.close()

def test_secret(arn, token):
    # Test pending credentials
    pending = secrets_manager.get_secret_value(
        SecretId=arn,
        VersionId=token,
        VersionStage='AWSPENDING'
    )
    pending_dict = json.loads(pending['SecretString'])
    
    # Attempt connection with new credentials
    conn = psycopg2.connect(
        host=pending_dict['host'],
        port=pending_dict['port'],
        user=pending_dict['username'],
        password=pending_dict['password'],
        database=pending_dict['dbname']
    )
    conn.close()

def finish_secret(arn, token):
    # Move AWSPENDING to AWSCURRENT
    secrets_manager.update_secret_version_stage(
        SecretId=arn,
        VersionStage='AWSCURRENT',
        MoveToVersionId=token,
        RemoveFromVersionId=secrets_manager.describe_secret(SecretId=arn)['VersionIdsToStages'].keys()[0]
    )
```

### Application Integration

**Node.js SDK:**
```javascript
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager({ region: 'us-east-1' });

async function getSecret(secretName) {
  try {
    const data = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
    if ('SecretString' in data) {
      return JSON.parse(data.SecretString);
    }
    // Binary secret
    const buff = Buffer.from(data.SecretBinary, 'base64');
    return buff.toString('ascii');
  } catch (error) {
    throw error;
  }
}

// Usage
const dbConfig = await getSecret('myapp/production/db');
const connection = createDatabaseConnection(dbConfig);
```

**With caching (recommended):**
```javascript
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const NodeCache = require("node-cache");

const client = new SecretsManagerClient({ region: "us-east-1" });
const cache = new NodeCache({ stdTTL: 300 }); // 5 minute cache

async function getSecretCached(secretName) {
  // Check cache first
  const cached = cache.get(secretName);
  if (cached) return cached;
  
  // Fetch from Secrets Manager
  const command = new GetSecretValueCommand({ SecretId: secretName });
  const response = await client.send(command);
  const secret = JSON.parse(response.SecretString);
  
  // Store in cache
  cache.set(secretName, secret);
  return secret;
}
```

---

## 1Password CLI Integration

### Setup

```bash
# Install 1Password CLI
brew install --cask 1password-cli

# Sign in
op signin

# Create a service account (for CI/CD)
op service-account create "GitHub Actions" --vault "Infrastructure"
# Save the token: ops_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Development Workflow

**Inject secrets into environment:**
```bash
# Store .env template in repository
# .env.template
DATABASE_URL="op://Infrastructure/Production DB/url"
API_KEY="op://Infrastructure/External API/api_key"
STRIPE_SECRET="op://Infrastructure/Stripe/secret_key"

# Load secrets and run app
op run --env-file=.env.template -- npm start

# Or export to shell
eval $(op signin)
export DATABASE_URL=$(op read "op://Infrastructure/Production DB/url")
export API_KEY=$(op read "op://Infrastructure/External API/api_key")
```

### CI/CD Integration

**GitHub Actions:**
```yaml
name: Deploy
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Load secrets from 1Password
        uses: 1password/load-secrets-action@v1
        with:
          export-env: true
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
          DATABASE_URL: "op://Infrastructure/Production DB/url"
          API_KEY: "op://Infrastructure/External API/api_key"
      
      - name: Deploy
        run: |
          echo "DATABASE_URL is available as env var"
          ./deploy.sh
```

### Secret References Format

```
op://[vault]/[item]/[field]
op://[vault]/[item]/[section]/[field]

Examples:
op://Infrastructure/AWS Prod/access_key_id
op://Infrastructure/Database/credentials/password
op://Infrastructure/API Keys/stripe/secret_key
```

### Create and Manage Secrets

```bash
# Create a new item
op item create --category=login \
  --vault=Infrastructure \
  --title="Production DB" \
  --url="postgres://db.example.com:5432" \
  username=admin \
  password=$(op generate-password --letters=20 --digits=5 --symbols=5)

# Read a secret
op read "op://Infrastructure/Production DB/password"

# Update a secret
op item edit "Production DB" password=$(op generate-password)

# List items in vault
op item list --vault=Infrastructure

# Delete an item
op item delete "Production DB" --vault=Infrastructure
```

---

## Secret Rotation Automation

### Database Credential Rotation Script

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

echo "✅ Password rotated successfully"

# Notify team
curl -X POST https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK \
  -H 'Content-Type: application/json' \
  -d "{\"text\":\"🔑 Database password rotated for ${DB_USER}@${DB_HOST}\"}"
```

### API Key Rotation (Zero-Downtime)

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

echo "⏳ Waiting for deployment to pick up secondary key (5 minutes)..."
sleep 300

# Promote secondary to primary
vault kv put "${VAULT_PATH}" \
  primary="${NEW_KEY}" \
  secondary="${PRIMARY_KEY}"

echo "⏳ Waiting for all instances to use new primary key (5 minutes)..."
sleep 300

# Revoke old key
if [ -n "${PRIMARY_KEY}" ]; then
  curl -X DELETE "https://api.external-service.com/keys/${PRIMARY_KEY}" \
    -H "Authorization: Bearer ${NEW_KEY}"
fi

# Remove secondary (old key)
vault kv put "${VAULT_PATH}" primary="${NEW_KEY}"

echo "✅ API key rotated successfully"
```

### Automated Rotation with Cron

```bash
# crontab -e
# Rotate database password every 90 days at 2 AM
0 2 1 */3 * /opt/scripts/rotate-db-password.sh >> /var/log/rotation.log 2>&1

# Rotate API keys every 30 days at 3 AM
0 3 1 * * /opt/scripts/rotate-api-key.sh >> /var/log/rotation.log 2>&1
```

---

## OIDC Federation Deep Dive

### GitHub Actions → AWS

**AWS IAM Setup:**
```bash
# Create OIDC provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Create IAM role
aws iam create-role \
  --role-name GitHubActionsRole \
  --assume-role-policy-document file://trust-policy.json

# trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:myorg/myrepo:*"
        }
      }
    }
  ]
}

# Attach permissions
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

**GitHub Actions Workflow:**
```yaml
name: Deploy to AWS
on: push

permissions:
  id-token: write   # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
          aws-region: us-east-1
      
      - name: Deploy
        run: |
          aws s3 sync ./build s3://my-bucket/
```

### GitHub Actions → Google Cloud

**GCP Setup:**
```bash
# Create Workload Identity Pool
gcloud iam workload-identity-pools create "github-pool" \
  --location="global" \
  --description="GitHub Actions pool"

# Create provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --attribute-condition="assertion.repository_owner=='myorg'"

# Bind service account
gcloud iam service-accounts add-iam-policy-binding "github-actions@my-project.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/123456789/locations/global/workloadIdentityPools/github-pool/attribute.repository/myorg/myrepo"
```

**GitHub Actions Workflow:**
```yaml
name: Deploy to GCP
on: push

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v1
        with:
          workload_identity_provider: 'projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
          service_account: 'github-actions@my-project.iam.gserviceaccount.com'
      
      - name: Deploy
        run: |
          gcloud app deploy
```

---

## Secret Scanning Tools Comparison

| Tool | Detection Method | Pre-commit Hook | CI/CD | Cost | Best For |
|---|---|---|---|---|---|
| **gitleaks** | Regex + entropy | ✅ | ✅ | Free | General purpose, fast |
| **truffleHog** | Regex + git history | ✅ | ✅ | Free | Deep git history scanning |
| **detect-secrets** | Entropy + plugins | ✅ | ✅ | Free | Python projects, low false positives |
| **git-secrets** | Regex patterns | ✅ | ❌ | Free | AWS credentials specifically |
| **GitHub Secret Scanning** | Platform-native | N/A | ✅ | Free (public repos) | GitHub-hosted repos |
| **GitGuardian** | AI + regex | ✅ | ✅ | Paid | Enterprise, dashboards |

### Gitleaks Setup (Recommended)

```bash
# Install
brew install gitleaks

# Scan repository
gitleaks detect --source . --verbose

# Scan git history
gitleaks detect --source . --log-opts="--all"

# Pre-commit hook
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks

# Install hooks
pre-commit install

# CI/CD (GitHub Actions)
# .github/workflows/gitleaks.yml
name: Secret Scanning
on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Custom configuration (.gitleaks.toml):**
```toml
[extend]
useDefault = true

[[rules]]
id = "custom-api-key"
description = "Custom API Key Pattern"
regex = '''(?i)(api[_-]?key|apikey)[[:space:]]*[:=][[:space:]]*['"][a-z0-9]{32}['"]'''

[allowlist]
description = "Allowlist for test files"
paths = [
  '''.*_test\.go''',
  '''.*\.example'''
]

[[allowlist.regexes]]
description = "Ignore placeholder values"
regex = '''(YOUR|REPLACE|EXAMPLE|TODO)'''
```

### TruffleHog Setup

```bash
# Install
brew install trufflesecurity/trufflehog/trufflehog

# Scan repository
trufflehog git file://. --only-verified

# Scan git history with JSON output
trufflehog git file://. --json > secrets.json

# Scan GitHub repository
trufflehog github --org=myorg --repo=myrepo

# Pre-commit hook
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/trufflesecurity/trufflehog
    rev: v3.63.0
    hooks:
      - id: trufflehog
        args: ['git', 'file://.', '--only-verified']
```

---

## Platform-Specific Secure Storage

### iOS Keychain (Swift)

```swift
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // Delete existing item if present
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

// Usage
KeychainManager.shared.save(key: "auth_token", value: "sk_live_12345")
let token = KeychainManager.shared.get(key: "auth_token")
```

### Android KeyStore (Kotlin)

```kotlin
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import android.util.Base64

class SecureStorage(private val context: Context) {
    private val keyStore: KeyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
    private val KEY_ALIAS = "MyAppKey"
    
    init {
        if (!keyStore.containsAlias(KEY_ALIAS)) {
            createKey()
        }
    }
    
    private fun createKey() {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            "AndroidKeyStore"
        )
        
        val spec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setRandomizedEncryptionRequired(true)
            .build()
        
        keyGenerator.init(spec)
        keyGenerator.generateKey()
    }
    
    fun encrypt(plainText: String): String {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        val secretKey = keyStore.getKey(KEY_ALIAS, null) as SecretKey
        cipher.init(Cipher.ENCRYPT_MODE, secretKey)
        
        val iv = cipher.iv
        val encrypted = cipher.doFinal(plainText.toByteArray(Charsets.UTF_8))
        
        // Combine IV and encrypted data
        val combined = iv + encrypted
        return Base64.encodeToString(combined, Base64.DEFAULT)
    }
    
    fun decrypt(encryptedText: String): String {
        val combined = Base64.decode(encryptedText, Base64.DEFAULT)
        val iv = combined.sliceArray(0 until 12)
        val encrypted = combined.sliceArray(12 until combined.size)
        
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        val secretKey = keyStore.getKey(KEY_ALIAS, null) as SecretKey
        val spec = GCMParameterSpec(128, iv)
        cipher.init(Cipher.DECRYPT_MODE, secretKey, spec)
        
        val decrypted = cipher.doFinal(encrypted)
        return String(decrypted, Charsets.UTF_8)
    }
}

// Usage
val secureStorage = SecureStorage(context)
val encrypted = secureStorage.encrypt("my_secret_token")
// Store encrypted value in SharedPreferences
sharedPreferences.edit().putString("token", encrypted).apply()

// Retrieve and decrypt
val encryptedToken = sharedPreferences.getString("token", null)
val token = secureStorage.decrypt(encryptedToken!!)
```

### React Native (expo-secure-store)

```javascript
import * as SecureStore from 'expo-secure-store';

async function save(key, value) {
  await SecureStore.setItemAsync(key, value);
}

async function get(key) {
  return await SecureStore.getItemAsync(key);
}

async function remove(key) {
  await SecureStore.deleteItemAsync(key);
}

// Usage
await save('auth_token', 'sk_live_12345');
const token = await get('auth_token');
await remove('auth_token');
```

---

This reference provides comprehensive implementation details for all major secret management systems, rotation strategies, and platform-specific secure storage solutions. Refer to SKILL.md for high-level procedures and use this document for deep technical implementation guidance.
