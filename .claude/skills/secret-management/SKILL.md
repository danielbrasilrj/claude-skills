---
name: secret-management
description: |
  Procedures for managing secrets across environments. Covers .env file conventions, platform
  secure storage (Keychain, KeyStore, SecureStore), CI/CD secrets (GitHub Secrets, OIDC federation),
  and secret rotation procedures. Use when setting up environment variables, configuring secure
  storage for mobile apps, managing CI/CD secrets, or implementing secret rotation policies.
---

## Purpose

Secret Management provides procedures for securely handling credentials, API keys, tokens, and other secrets across development, CI/CD, and production environments. It enforces zero-hardcoded-credentials and implements defense-in-depth through centralized vaults, automated rotation, and pre-commit scanning.

## When to Use

- Setting up environment variables for a new project
- Configuring secrets for CI/CD pipelines
- Implementing secure storage in mobile apps
- Establishing secret rotation procedures
- Auditing for leaked credentials

## Prerequisites

- Git repository with `.gitignore` configured
- CI/CD platform (GitHub Actions recommended)
- Optional: HashiCorp Vault, AWS Secrets Manager, or 1Password

## Procedures

### 1. .env File Convention

```bash
# .env.example (committed — shows structure, no values)
DATABASE_URL=
API_KEY=
STRIPE_SECRET_KEY=

# .env.local (NOT committed — actual values)
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
API_KEY=sk_live_xxxxx
STRIPE_SECRET_KEY=sk_live_xxxxx
```

**Naming convention:**
- `PUBLIC_*` or `NEXT_PUBLIC_*` — safe for client-side
- Everything else — server-side only

**File hierarchy:**
```
.env                 # Shared defaults (committed, no secrets)
.env.local           # Local overrides (NOT committed)
.env.development     # Dev environment
.env.staging         # Staging environment
.env.production      # Production (NOT committed, use vault)
```

### 2. Platform Secure Storage (Mobile)

| Platform | Storage | Use For |
|---|---|---|
| iOS | Keychain (`SecItemAdd`) | Auth tokens, user credentials |
| Android | KeyStore + EncryptedSharedPreferences | Auth tokens, user credentials |
| React Native | expo-secure-store | Cross-platform secure storage |
| Web | httpOnly cookies (server-set) | Session tokens |

**Never store secrets in:** AsyncStorage, SharedPreferences, localStorage, or app bundle.

### 3. CI/CD Secrets

**GitHub Actions:**
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

**OIDC Federation (preferred over stored keys):**
```yaml
permissions:
  id-token: write
  contents: read
steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-arn: arn:aws:iam::123456:role/deploy
      aws-region: us-east-1
```

### 4. Pre-Commit Secret Scanning

```bash
# Install gitleaks
brew install gitleaks

# Add to pre-commit
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
```

### 5. Secret Rotation

| Secret Type | Rotation Frequency | Method |
|---|---|---|
| Database credentials | 90 days | Vault auto-rotation |
| API keys | 90 days | Generate new, update, revoke old |
| JWT signing keys | 6 months | Key pair rotation with overlap |
| Service account keys | 90 days | OIDC federation (no static keys) |

**Rotation procedure:**
1. Generate new secret
2. Deploy to all consumers
3. Verify all consumers use new secret
4. Revoke old secret
5. Log the rotation event

## Templates

- `templates/env-file-convention.md` — .env structure template
- `templates/secret-rotation-checklist.md` — Rotation procedure checklist

## Examples

- `examples/secret-management-setup.md` — Complete setup walkthrough

## Chaining

| Chain With | Purpose |
|---|---|
| `ci-cd-pipeline` | Configure secrets in CI/CD |
| `security-review` | Audit for leaked or weak secrets |
| `domain-intelligence` | Define secret management policy |
| `database-ops` | Secure database credentials |

## Troubleshooting

| Problem | Solution |
|---|---|
| Secret committed to git | Rotate immediately; use `git filter-repo` to purge history |
| CI can't access secrets | Check secret name spelling; PRs from forks can't access secrets |
| gitleaks false positive | Add to `.gitleaksignore` with justification comment |
| Env var not available at runtime | Check if it needs to be prefixed (NEXT_PUBLIC_, EXPO_PUBLIC_) |
