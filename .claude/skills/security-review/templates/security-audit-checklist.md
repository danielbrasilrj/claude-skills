# Security Audit Checklist

## Project Information

| Field | Value |
|-------|-------|
| Project Name | |
| Audit Date | |
| Auditor | |
| Platforms | iOS / Android / Web / API |
| Regulations | LGPD / GDPR / CCPA / None |
| Audit Type | Full / Targeted / Follow-up |

---

## 1. Credential and Secret Management

- [ ] No hardcoded API keys, passwords, or tokens in source code
- [ ] No secrets in build scripts, CI configs, or Dockerfiles
- [ ] No credentials in application logs or error messages
- [ ] `.env` and credential files listed in `.gitignore`
- [ ] Git history scanned for previously committed secrets
- [ ] Secret scanning tool (gitleaks/trufflehog) configured in CI
- [ ] All secrets stored in a vault or environment-specific config

**Findings**: <!-- Document any issues found -->

---

## 2. Authentication

- [ ] OAuth 2.0 Authorization Code + PKCE used for mobile/SPA
- [ ] No use of implicit grant or resource owner password flow
- [ ] Access tokens are short-lived (max 15 minutes)
- [ ] Refresh tokens use rotation (one-time use)
- [ ] Tokens stored in platform secure storage (Keychain/Keystore)
- [ ] Server validates token signature, issuer, audience, expiry
- [ ] Brute-force protection (rate limiting, progressive delay, lockout)
- [ ] MFA available for user accounts
- [ ] MFA enforced for admin/privileged operations
- [ ] Password policy enforced (min 8 chars, complexity, not breached)

**Findings**:

---

## 3. Authorization

- [ ] Server-side authorization on every API endpoint
- [ ] Role-based access control (RBAC) implemented
- [ ] Object-level authorization (no IDOR vulnerabilities)
- [ ] Function-level authorization (admin endpoints protected)
- [ ] Field-level authorization (sensitive data filtered by role)
- [ ] Horizontal privilege escalation tested
- [ ] Vertical privilege escalation tested

**Findings**:

---

## 4. Data Encryption

- [ ] TLS 1.2+ enforced for all communications
- [ ] Certificate pinning for critical API endpoints
- [ ] No mixed content (HTTP on HTTPS pages)
- [ ] AES-256 used for data at rest encryption
- [ ] No deprecated algorithms (MD5, SHA-1, DES, RC4)
- [ ] Password hashing uses bcrypt/scrypt/Argon2id
- [ ] Cryptographic keys stored in platform Keystore/Keychain
- [ ] Key rotation policy defined and implemented
- [ ] Database encryption enabled for sensitive data

**Findings**:

---

## 5. Data Storage

### iOS
- [ ] Sensitive data in Keychain with appropriate accessibility
- [ ] `isExcludedFromBackup` set for sensitive files
- [ ] No sensitive data in UserDefaults or plist
- [ ] No sensitive data in clipboard or screenshots
- [ ] Data Protection API enabled (NSFileProtectionComplete)

### Android
- [ ] EncryptedSharedPreferences for sensitive key-value data
- [ ] AndroidKeyStore for cryptographic keys
- [ ] `android:allowBackup="false"` for sensitive apps
- [ ] No sensitive data in external storage
- [ ] No sensitive data in logs (logcat)

### Web
- [ ] Session tokens in HttpOnly, Secure, SameSite cookies
- [ ] No sensitive data in localStorage/sessionStorage
- [ ] Cache-Control: no-store for sensitive responses

**Findings**:

---

## 6. Input Validation

- [ ] Server-side validation on all inputs
- [ ] Parameterized queries (no SQL string concatenation)
- [ ] Output encoding applied (HTML, JS, URL, CSS contexts)
- [ ] File uploads: type validation, size limits, virus scan
- [ ] Deep links / universal links validated against allowlist
- [ ] GraphQL: query depth and complexity limits set
- [ ] Request size limits configured
- [ ] Content-Type validation enforced

**Findings**:

---

## 7. Network Security

- [ ] HSTS header configured (1 year, includeSubDomains)
- [ ] Content-Security-Policy header configured
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY (or CSP frame-ancestors)
- [ ] Referrer-Policy configured
- [ ] CORS policy restrictive (no wildcard origins for credentialed requests)
- [ ] API rate limiting implemented
- [ ] WebSocket connections authenticated and authorized

**Findings**:

---

## 8. Binary and Runtime Protection

- [ ] Debug mode disabled in production builds
- [ ] Code obfuscation enabled (ProGuard/R8 for Android)
- [ ] Symbol stripping in release builds (iOS)
- [ ] Root/jailbreak detection implemented
- [ ] Integrity verification (tamper detection)
- [ ] No sensitive data in crash reports
- [ ] Anti-debugging measures (production only)

**Findings**:

---

## 9. Third-Party Dependencies

- [ ] All dependencies at latest stable versions
- [ ] Known vulnerabilities scanned (npm audit, Snyk, Dependabot)
- [ ] No abandoned or unmaintained libraries
- [ ] SDK privacy and data collection policies reviewed
- [ ] Dependency lockfiles committed to version control
- [ ] SBOM (Software Bill of Materials) maintained

**Findings**:

---

## 10. Privacy Compliance

- [ ] Privacy policy accessible and up to date
- [ ] Consent collection mechanism implemented
- [ ] Data subject rights endpoints functional (access, delete, export)
- [ ] Data retention periods defined and enforced
- [ ] Data processing activities documented
- [ ] DPO/Encarregado designated (if required)
- [ ] Cross-border data transfer safeguards in place
- [ ] Cookie/tracking consent banner (if applicable)

**Findings**:

---

## 11. Logging and Monitoring

- [ ] Authentication events logged (login, logout, failures)
- [ ] Authorization failures logged
- [ ] No PII or secrets in log output
- [ ] Log integrity protection (centralized, append-only)
- [ ] Alerting configured for suspicious activity
- [ ] Incident response plan documented

**Findings**:

---

## Summary

| Category | Status | Critical | High | Medium | Low | Info |
|----------|--------|----------|------|--------|-----|------|
| Credentials | | | | | | |
| Authentication | | | | | | |
| Authorization | | | | | | |
| Encryption | | | | | | |
| Data Storage | | | | | | |
| Input Validation | | | | | | |
| Network | | | | | | |
| Binary Protection | | | | | | |
| Dependencies | | | | | | |
| Privacy | | | | | | |
| Logging | | | | | | |
| **Total** | | | | | | |

## Next Steps

1. <!-- Priority remediation items -->
2. <!-- Follow-up audit date -->
3. <!-- Training or process improvements -->
