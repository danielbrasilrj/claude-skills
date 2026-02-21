---
name: security-review
description: Run a security audit on backend rules, authentication flows, encryption, and privacy compliance (LGPD/GDPR/CCPA). Covers OWASP Mobile Top 10 2024, OAuth 2.0/OIDC, platform-specific secure storage, and static/dynamic analysis tooling.
---

# Security Review

## Purpose

Perform structured security audits for mobile and web applications. Identify vulnerabilities across authentication, data storage, network communication, and privacy compliance. Produce actionable reports with severity ratings and remediation guidance.

## When to Use

- Before a major release or app store submission
- After adding authentication, payments, or sensitive data handling
- When onboarding a new third-party SDK or API integration
- During periodic security reviews (quarterly recommended)
- When preparing for LGPD, GDPR, or CCPA compliance audits
- After a security incident or penetration test finding

## Prerequisites

- Access to the application source code
- Knowledge of target platforms (iOS, Android, Web, API)
- Understanding of which privacy regulations apply
- Optional: MobSF, Frida, Semgrep, gitleaks installed for automated scanning

## Procedures

### 1. Scope Definition

Determine audit boundaries before starting.

```
Audit Scope Checklist:
- [ ] Target platforms identified (iOS / Android / Web / API)
- [ ] Privacy regulations identified (LGPD / GDPR / CCPA / none)
- [ ] Authentication method documented (OAuth 2.0 / OIDC / custom)
- [ ] Third-party SDKs inventoried
- [ ] Data flow diagram available or to be created
- [ ] Previous audit findings reviewed (if any)
```

### 2. OWASP Mobile Top 10 2024 Review

Evaluate each category systematically.

| # | Category | Key Checks |
|---|----------|------------|
| M1 | Improper Credential Usage | Hardcoded keys, credentials in code/logs |
| M2 | Inadequate Supply Chain Security | SDK versions, dependency vulnerabilities |
| M3 | Insecure Authentication/Authorization | Token validation, session management |
| M4 | Insufficient Input/Output Validation | Injection, XSS, deep link validation |
| M5 | Insecure Communication | TLS 1.2+ enforcement, certificate pinning |
| M6 | Inadequate Privacy Controls | Data minimization, consent, retention |
| M7 | Insufficient Binary Protections | Obfuscation, anti-tampering, debug flags |
| M8 | Security Misconfiguration | Debug mode, default credentials, permissions |
| M9 | Insecure Data Storage | Keychain/Keystore usage, plaintext data |
| M10 | Insufficient Cryptography | AES-256, no deprecated algorithms, key management |

### 3. Authentication and Authorization Audit

```
Auth Checklist:
- [ ] OAuth 2.0 PKCE flow used for mobile (no implicit grant)
- [ ] Access tokens are short-lived (5-15 min recommended)
- [ ] Refresh tokens stored in platform secure storage
- [ ] Token refresh uses rotation (one-time use refresh tokens)
- [ ] Server validates tokens on every request (no client-only auth)
- [ ] OIDC ID tokens validated: issuer, audience, expiry, signature
- [ ] MFA available and enforced for sensitive operations
- [ ] Brute-force protection: rate limiting, account lockout
- [ ] Session invalidation on password change / logout
- [ ] Role-based access control (RBAC) enforced server-side
```

### 4. Encryption and Data Protection Audit

```
Encryption Standards:
- At rest:  AES-256-GCM (or AES-256-CBC with HMAC)
- In transit: TLS 1.2+ (prefer TLS 1.3)
- Hashing:  bcrypt/scrypt/Argon2 for passwords, SHA-256+ for integrity
- Keys:     Stored in platform Keychain (iOS) / Keystore (Android)
- Secrets:  Never in source code, build artifacts, or logs

Checks:
- [ ] No use of deprecated algorithms (MD5, SHA-1, DES, RC4)
- [ ] Cryptographic keys not hardcoded in source
- [ ] Key rotation policy defined and implemented
- [ ] Certificate pinning implemented for critical endpoints
- [ ] Sensitive data wiped from memory after use
- [ ] Database encryption enabled (SQLCipher or equivalent)
- [ ] Backup exclusion for sensitive files (iOS: isExcludedFromBackup)
```

### 5. Privacy Compliance Review

Select applicable regulation(s) and verify requirements.

**LGPD (Brazil):**
- Legal basis documented for each data processing activity
- DSAR response within 15 days
- DPO (Encarregado) appointed and contactable
- Data Processing Impact Assessment (RIPD) completed
- Penalties: up to R$50M per violation or 2% of revenue

**GDPR (EU/EEA):**
- Lawful basis for processing documented (Art. 6)
- Data breach notification within 72 hours to authority
- Right to erasure (Art. 17) implemented
- Data Protection Impact Assessment (DPIA) for high-risk processing
- Penalties: up to 4% of annual global turnover or EUR 20M

**CCPA (California):**
- "Do Not Sell My Personal Information" link present
- Consumer request response within 45 days
- Privacy policy updated within 12 months
- Penalties: $2,500 per violation, $7,500 per intentional violation

See `templates/privacy-compliance-matrix.md` for full comparison.

### 6. Static and Dynamic Analysis

```bash
# Static analysis with Semgrep
semgrep --config=auto --config=p/owasp-top-ten ./src/

# Secret detection with gitleaks
gitleaks detect --source=. --report-path=gitleaks-report.json

# Mobile security analysis with MobSF
# Upload APK/IPA to MobSF instance for automated scanning

# Dynamic analysis with Frida (runtime)
frida -U -f com.app.target -l hooks.js --no-pause
```

### 7. Report Generation

Structure findings using the template at `examples/security-audit-report.md`.

Severity levels:
- **Critical**: Immediate exploitation possible, data breach risk
- **High**: Significant vulnerability, exploitation requires minimal effort
- **Medium**: Vulnerability present, exploitation requires specific conditions
- **Low**: Minor issue, defense-in-depth improvement
- **Informational**: Best practice recommendation

## Templates

- `templates/security-audit-checklist.md` -- Full checklist for comprehensive audits
- `templates/privacy-compliance-matrix.md` -- LGPD vs GDPR vs CCPA comparison

## Examples

- `examples/security-audit-report.md` -- Sample audit report with findings

## Chaining

- Use **secret-management** after identifying hardcoded secrets or weak key storage
- Use **code-review** for deeper analysis of specific vulnerable code paths
- Use **testing-strategy** to add security-focused test cases
- Use **ci-cd-pipeline** to integrate Semgrep/gitleaks into CI

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Semgrep too many false positives | Use `--severity ERROR` or custom rule sets |
| MobSF fails on large APK | Increase Docker memory, try CLI mode |
| Certificate pinning blocks proxy | Use Frida to bypass pinning during testing |
| Unclear which regulation applies | Check data subject residency, not company location |
| Team pushes back on security fixes | Prioritize by severity, provide exploitation scenarios |
