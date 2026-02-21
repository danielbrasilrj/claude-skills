# Secret Rotation Procedure Checklist

Use this checklist when rotating secrets to ensure zero downtime and complete coverage.

**Secret Name:** `___________________________`  
**Secret Type:** `[ ] Database Credential  [ ] API Key  [ ] JWT Signing Key  [ ] Certificate  [ ] Other: ________`  
**Rotation Date:** `___________________________`  
**Rotated By:** `___________________________`  
**Next Rotation Due:** `___________________________`

---

## Pre-Rotation Checklist

- [ ] **Identify all consumers** — List all applications, services, and environments that use this secret
  - Consumer 1: ___________________________
  - Consumer 2: ___________________________
  - Consumer 3: ___________________________
  - Consumer 4: ___________________________

- [ ] **Check rotation strategy** — Determine if zero-downtime rotation is required
  - [ ] Can support dual-key (new + old active simultaneously) → Zero-downtime
  - [ ] Cannot support dual-key → Requires maintenance window
  
- [ ] **Schedule maintenance window** (if required)
  - Date/Time: ___________________________
  - Duration: ___________________________
  - Stakeholders notified: [ ] Yes [ ] No

- [ ] **Backup current secret** — Store securely for rollback
  - Backup location: ___________________________
  - Backup verification: [ ] Confirmed

- [ ] **Test rotation in staging** — Verify procedure in non-production environment
  - Staging rotation completed: [ ] Yes [ ] No
  - Issues encountered: ___________________________

- [ ] **Notify team** — Alert team members of upcoming rotation
  - Notification sent: [ ] Yes [ ] No
  - Response received: [ ] Yes [ ] No

---

## Rotation Procedure

### Phase 1: Generate New Secret

- [ ] **Generate new secret value**
  - Method: [ ] Auto-generated [ ] Manual [ ] Provider API
  - New secret stored in vault: [ ] Yes [ ] No
  - Vault path: ___________________________

- [ ] **Validate new secret format**
  - Meets complexity requirements: [ ] Yes [ ] No
  - No special characters that break configs: [ ] Yes [ ] No

### Phase 2: Deploy New Secret (Dual-Key Phase)

**For dual-key support:**
- [ ] **Store new secret as secondary** — Add to vault/secrets manager with "secondary" label
- [ ] **Deploy to all consumers** — Update applications to accept both old and new secrets
  - Consumer 1 updated: [ ] Yes [ ] No
  - Consumer 2 updated: [ ] Yes [ ] No
  - Consumer 3 updated: [ ] Yes [ ] No
  - Consumer 4 updated: [ ] Yes [ ] No
- [ ] **Wait for deployment propagation** — Allow time for all instances to reload config
  - Wait duration: _____ minutes (recommended: 5-10 minutes)
  - All instances updated: [ ] Yes [ ] No

**For non-dual-key (maintenance window):**
- [ ] **Start maintenance window**
- [ ] **Stop all consumers**
- [ ] **Update secret in vault/secrets manager**
- [ ] **Deploy new secret to all consumers**
- [ ] **Restart all consumers**

### Phase 3: Promote New Secret to Primary

- [ ] **Update primary secret** — Swap new secret to primary position in vault
- [ ] **Verify all consumers use new secret** — Check logs/metrics for authentication with new secret
  - Consumer 1 verified: [ ] Yes [ ] No
  - Consumer 2 verified: [ ] Yes [ ] No
  - Consumer 3 verified: [ ] Yes [ ] No
  - Consumer 4 verified: [ ] Yes [ ] No
- [ ] **Wait for verification period** — Monitor for errors (recommended: 5-10 minutes)
  - No errors detected: [ ] Yes [ ] No

### Phase 4: Revoke Old Secret

- [ ] **Remove old secret from consumers** — Update config to only accept new secret
  - Consumer 1 updated: [ ] Yes [ ] No
  - Consumer 2 updated: [ ] Yes [ ] No
  - Consumer 3 updated: [ ] Yes [ ] No
  - Consumer 4 updated: [ ] Yes [ ] No
- [ ] **Revoke old secret** — Disable/delete old secret from provider
  - Method: [ ] Database ALTER USER [ ] API revoke [ ] Delete from vault [ ] Other: ________
  - Old secret revoked: [ ] Yes [ ] No
- [ ] **Verify old secret no longer works** — Attempt authentication with old secret (should fail)
  - Verification completed: [ ] Yes [ ] No

---

## Post-Rotation Verification

- [ ] **Test all consumers** — Verify each consumer can authenticate and perform operations
  - Consumer 1 test: [ ] Pass [ ] Fail
  - Consumer 2 test: [ ] Pass [ ] Fail
  - Consumer 3 test: [ ] Pass [ ] Fail
  - Consumer 4 test: [ ] Pass [ ] Fail

- [ ] **Check monitoring/alerts** — Confirm no authentication errors or anomalies
  - Error rate: ___________________________
  - Latency impact: ___________________________

- [ ] **Update documentation** — Record rotation in logs and update runbooks
  - Rotation logged: [ ] Yes [ ] No
  - Log location: ___________________________

- [ ] **Schedule next rotation** — Set reminder for next rotation cycle
  - Next rotation date: ___________________________
  - Calendar reminder created: [ ] Yes [ ] No

- [ ] **Notify team of completion** — Confirm rotation was successful
  - Notification sent: [ ] Yes [ ] No

---

## Rollback Procedure (If Issues Detected)

- [ ] **Restore old secret** — Immediately revert to previous secret value
  - Old secret restored to primary: [ ] Yes [ ] No

- [ ] **Redeploy old secret to all consumers** — Ensure all consumers use old secret
  - Consumer 1 reverted: [ ] Yes [ ] No
  - Consumer 2 reverted: [ ] Yes [ ] No
  - Consumer 3 reverted: [ ] Yes [ ] No
  - Consumer 4 reverted: [ ] Yes [ ] No

- [ ] **Verify services restored** — Confirm all consumers functioning normally
  - All services operational: [ ] Yes [ ] No

- [ ] **Document rollback reason** — Record why rotation failed
  - Reason: ___________________________
  - Root cause: ___________________________

- [ ] **Schedule retry** — Plan corrective actions and retry rotation
  - Corrective actions: ___________________________
  - Retry date: ___________________________

---

## Secret-Specific Instructions

### Database Credentials

```bash
# PostgreSQL
ALTER USER myuser WITH PASSWORD 'new_password';

# MySQL
ALTER USER 'myuser'@'%' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;

# MongoDB
db.updateUser("myuser", { pwd: "new_password" });
```

**Dual-key not supported** — Use maintenance window or create temporary user:
```bash
# Create temporary user with same permissions
CREATE USER myuser_new WITH PASSWORD 'new_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO myuser_new;

# Update consumers to use myuser_new
# After verification, drop old user
DROP USER myuser;
RENAME USER myuser_new TO myuser;
```

### API Keys

**If provider supports dual-key:**
1. Generate new key
2. Add new key to vault as secondary
3. Deploy to all consumers
4. Revoke old key after verification

**If provider does NOT support dual-key:**
1. Schedule maintenance window
2. Generate new key
3. Update vault
4. Deploy to all consumers
5. Revoke old key immediately

### JWT Signing Keys

**Dual-key supported** (using key IDs):
1. Generate new key pair
2. Add new key to JWKS endpoint with new `kid` (key ID)
3. Start signing new tokens with new key
4. Old key remains in JWKS for token verification
5. After token TTL expires (e.g., 1 hour), remove old key from JWKS

```javascript
// JWKS with multiple keys
{
  "keys": [
    {
      "kid": "key-2024-01",
      "kty": "RSA",
      "use": "sig",
      "alg": "RS256",
      "n": "...",
      "e": "AQAB"
    },
    {
      "kid": "key-2024-02", // New key
      "kty": "RSA",
      "use": "sig",
      "alg": "RS256",
      "n": "...",
      "e": "AQAB"
    }
  ]
}
```

### TLS Certificates

**Zero-downtime rotation:**
1. Generate new certificate
2. Configure server to present both certificates (SNI or dual-cert)
3. Wait for clients to receive new certificate
4. Remove old certificate after grace period (24-48 hours)

```bash
# Generate new certificate
openssl req -x509 -newkey rsa:4096 -keyout new_key.pem -out new_cert.pem -days 365

# Nginx: serve both certificates
ssl_certificate /etc/ssl/certs/new_cert.pem;
ssl_certificate_key /etc/ssl/private/new_key.pem;
ssl_certificate /etc/ssl/certs/old_cert.pem;
ssl_certificate_key /etc/ssl/private/old_key.pem;
```

---

## Automation Script Template

```bash
#!/bin/bash
# rotate-secret.sh

set -euo pipefail

SECRET_NAME="$1"
VAULT_PATH="secret/data/myapp/${SECRET_NAME}"

echo "🔄 Starting rotation for ${SECRET_NAME}"

# Phase 1: Generate new secret
NEW_VALUE=$(openssl rand -base64 32)
echo "✅ Generated new secret"

# Phase 2: Store as secondary
vault kv patch "${VAULT_PATH}" secondary="${NEW_VALUE}"
echo "✅ Stored new secret as secondary"

# Phase 3: Wait for deployment
echo "⏳ Waiting 5 minutes for consumers to reload..."
sleep 300

# Phase 4: Promote to primary
vault kv patch "${VAULT_PATH}" primary="${NEW_VALUE}"
vault kv patch "${VAULT_PATH}" secondary=""
echo "✅ Promoted new secret to primary"

# Phase 5: Wait for verification
echo "⏳ Waiting 5 minutes for verification..."
sleep 300

echo "✅ Rotation complete for ${SECRET_NAME}"
echo "📅 Next rotation due: $(date -d '+90 days' '+%Y-%m-%d')"
```

---

## Rotation Frequencies (Recommended)

| Secret Type | Frequency | Automation | Priority |
|---|---|---|---|
| Database credentials | 90 days | Recommended | High |
| API keys (external services) | 90 days | Recommended | High |
| JWT signing keys | 180 days | Recommended | Medium |
| TLS certificates | 365 days (30 days before expiry) | Required | High |
| Service account keys | 90 days or use OIDC | Required | High |
| CI/CD secrets | 90 days | Recommended | Medium |
| Encryption keys | 1 year | Recommended | Medium |

---

## Notes

- **Always test in staging first**
- **Never rotate all secrets at once** — Rotate one at a time to isolate issues
- **Monitor closely during and after rotation** — Watch for authentication errors
- **Document every rotation** — Keep audit log for compliance
- **Automate when possible** — Reduce human error with scripts

---

**Rotation Status:** `[ ] Not Started  [ ] In Progress  [ ] Completed  [ ] Rolled Back`  
**Sign-off:** ___________________________  
**Date:** ___________________________
