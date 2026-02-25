# HashiCorp Vault Patterns

## Setup and Configuration

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

## Key-Value Secrets Engine

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

## Dynamic Database Credentials

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
  token: process.env.VAULT_TOKEN,
});

async function getDatabaseCredentials() {
  const result = await vault.read('database/creds/readonly');
  return {
    username: result.data.username,
    password: result.data.password,
    lease_id: result.lease_id,
    lease_duration: result.lease_duration,
  };
}

// Renew lease before it expires
async function renewLease(leaseId) {
  await vault.write('sys/leases/renew', {
    lease_id: leaseId,
    increment: 3600, // 1 hour
  });
}

// Usage
const creds = await getDatabaseCredentials();
const db = createDatabaseConnection(creds.username, creds.password);

// Renew lease every 50 minutes (before 1 hour expiry)
setInterval(() => renewLease(creds.lease_id), 50 * 60 * 1000);
```

## AppRole Authentication (for applications)

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
    secret_id: process.env.VAULT_SECRET_ID,
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

## Transit Secrets Engine (Encryption as a Service)

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
