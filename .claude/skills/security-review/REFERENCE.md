# Security Review -- Reference

## OWASP Mobile Top 10 2024 -- Detailed Guidance

### M1: Improper Credential Usage

**Risk**: Hardcoded API keys, passwords, or tokens in source code, configuration files, or logs.

**Detection patterns (Semgrep/grep)**:
```
# Common patterns to search for
api[_-]?key\s*[:=]
password\s*[:=]
secret\s*[:=]
token\s*[:=]
private[_-]?key
-----BEGIN (RSA |EC )?PRIVATE KEY-----
AWS[_-]?(ACCESS|SECRET)
AKIA[0-9A-Z]{16}
```

**Remediation**:
1. Remove all hardcoded credentials from source code
2. Use environment variables or platform secure storage
3. Implement secret scanning in CI/CD pipeline (gitleaks, trufflehog)
4. Rotate any credentials that were committed to version control
5. Add `.env` and credential files to `.gitignore`

### M2: Inadequate Supply Chain Security

**Risk**: Vulnerable or malicious third-party dependencies.

**Checks**:
- Run `npm audit` / `pip audit` / `bundle audit` for dependency vulnerabilities
- Verify SDK publishers and review changelogs before updates
- Pin dependency versions (use lockfiles)
- Monitor for CVEs with Dependabot, Snyk, or Renovate
- Evaluate SDK permissions and data collection practices

**Remediation**:
1. Update vulnerable dependencies to patched versions
2. Replace abandoned libraries with maintained alternatives
3. Implement Software Bill of Materials (SBOM) tracking
4. Use dependency lockfiles and verify integrity hashes

### M3: Insecure Authentication/Authorization

**Risk**: Weak authentication flows, insufficient session management, missing authorization checks.

**OAuth 2.0 / OIDC Security Checklist**:
```
Token Security:
- Access tokens: JWT, short-lived (5-15 min), audience-restricted
- Refresh tokens: opaque, long-lived (7-30 days), one-time use with rotation
- ID tokens: validated for issuer, audience, expiry, nonce, signature
- Token storage: platform Keychain (iOS) / EncryptedSharedPreferences (Android)

Flow Security:
- Authorization Code + PKCE (code_verifier: 43-128 chars, S256 method)
- No implicit grant flow for mobile or SPA
- State parameter for CSRF protection
- Redirect URI validation (exact match, no wildcards)
- HTTPS required for all token endpoints

Session Security:
- Server-side session validation on every API call
- Session timeout after inactivity (15-30 min for sensitive apps)
- Forced re-authentication for sensitive operations
- Session invalidation on password change, MFA change, or logout
- Concurrent session limits where appropriate
```

### M4: Insufficient Input/Output Validation

**Risk**: Injection attacks, XSS, path traversal, deep link abuse.

**Validation rules**:
```
Input Validation:
- Allowlist validation preferred over denylist
- Server-side validation mandatory (client-side is supplementary)
- Parameterized queries for all database operations
- HTML encoding for all user-generated content in output
- Deep link / universal link schemes validated against allowlist

Output Encoding:
- HTML context: HTML entity encoding
- JavaScript context: JavaScript encoding
- URL context: URL encoding
- CSS context: CSS encoding
- JSON context: proper serialization (no string concatenation)
```

### M5: Insecure Communication

**Risk**: Data interception via man-in-the-middle attacks.

**TLS Configuration**:
```
Minimum Requirements:
- TLS 1.2 minimum (TLS 1.3 preferred)
- Strong cipher suites only (AES-256-GCM, ChaCha20-Poly1305)
- HSTS header with min 1 year max-age, includeSubDomains
- Certificate pinning for critical API endpoints
- No mixed content (HTTP resources on HTTPS pages)

iOS (App Transport Security):
- ATS enabled (default in iOS 9+)
- No NSAllowsArbitraryLoads exceptions in production
- Pin public keys, not certificates (for rotation flexibility)

Android (Network Security Config):
- Custom network_security_config.xml
- Pin certificates for production domains
- No cleartext traffic allowed (cleartextTrafficPermitted=false)
- Trust only system CAs in production (no user-added CAs)
```

### M6: Inadequate Privacy Controls

**Data classification**:
```
Level 1 -- Public: Marketing content, public profiles
Level 2 -- Internal: User preferences, app settings
Level 3 -- Confidential: Email, phone, address, purchase history
Level 4 -- Restricted: Passwords, payment data, health data, biometrics, government IDs
```

**Privacy by design principles**:
1. Data minimization: collect only what is necessary
2. Purpose limitation: use data only for stated purposes
3. Storage limitation: define retention periods, auto-delete
4. Consent management: granular, revocable, documented
5. Transparency: clear privacy notices at point of collection
6. Data portability: export in machine-readable format

### M7: Insufficient Binary Protections

**Checks**:
```
iOS:
- Bitcode enabled (if supported)
- Symbol stripping in release builds
- No debug symbols in production binary
- Jailbreak detection implemented

Android:
- ProGuard/R8 obfuscation enabled
- Root detection implemented
- Debuggable flag false in release manifest
- APK signature scheme v2/v3
- Integrity checks (Play Integrity API)
```

### M8: Security Misconfiguration

**Common misconfigurations**:
```
General:
- [ ] Debug mode disabled in production
- [ ] Verbose error messages suppressed
- [ ] Default credentials changed
- [ ] Unnecessary services/endpoints disabled
- [ ] CORS policy restrictive (no wildcard origins)
- [ ] Security headers configured (CSP, X-Frame-Options, etc.)

Mobile-specific:
- [ ] Backup flag disabled for sensitive data (android:allowBackup="false")
- [ ] Exported components require permissions (android:exported="false")
- [ ] iOS Keychain accessibility set to kSecAttrAccessibleWhenUnlockedThisDeviceOnly
- [ ] No sensitive data in clipboard (UIPasteboardNameGeneral)
- [ ] Screenshots disabled for sensitive screens
```

### M9: Insecure Data Storage

**Secure storage by platform**:
```
iOS:
- Keychain Services for credentials and tokens
- Data Protection API (NSFileProtectionComplete)
- Exclude from backups: URLResourceValues.isExcludedFromBackup = true
- No sensitive data in UserDefaults, plist, or Core Data without encryption

Android:
- EncryptedSharedPreferences for key-value data
- AndroidKeyStore for cryptographic keys
- EncryptedFile for file-level encryption
- No sensitive data in SharedPreferences, SQLite, or external storage without encryption
- Room database with SQLCipher for encrypted database

Web:
- HttpOnly, Secure, SameSite cookies for session tokens
- No sensitive data in localStorage or sessionStorage
- Use server-side sessions where possible
```

### M10: Insufficient Cryptography

**Approved algorithms**:
```
Symmetric encryption: AES-256-GCM (preferred), AES-256-CBC + HMAC-SHA256
Asymmetric encryption: RSA-2048+ (prefer RSA-4096), ECDSA P-256+
Hashing: SHA-256, SHA-384, SHA-512
Password hashing: Argon2id (preferred), bcrypt (cost 12+), scrypt
Key derivation: HKDF, PBKDF2-SHA256 (600k+ iterations)
Random generation: Platform CSPRNG only (SecureRandom, SecRandomCopyBytes)

DEPRECATED (must not use):
- MD5, SHA-1 (for security purposes)
- DES, 3DES, RC4, Blowfish
- RSA-1024
- ECB mode
- Custom/homebrew cryptography
```

## Privacy Regulation Deep Dive

### LGPD (Lei Geral de Protecao de Dados) -- Brazil

**Key requirements**:
- **Legal basis** (Art. 7): consent, legitimate interest, contract, legal obligation, research, public policy, health protection, credit protection, life protection
- **Data subject rights** (Art. 18): access, correction, anonymization, portability, deletion, consent revocation, information about sharing
- **DSAR timeline**: 15 days from request
- **DPO**: mandatory (Encarregado de Protecao de Dados)
- **International transfer**: adequate country, standard contractual clauses, binding corporate rules, or consent
- **Breach notification**: reasonable time to ANPD and data subjects
- **Penalties**: warning, fine up to 2% of revenue (max R$50M per violation), daily fine, data blocking/deletion

### GDPR (General Data Protection Regulation) -- EU/EEA

**Key requirements**:
- **Lawful basis** (Art. 6): consent, contract, legal obligation, vital interests, public task, legitimate interests
- **Data subject rights**: access (Art. 15), rectification (Art. 16), erasure (Art. 17), portability (Art. 20), objection (Art. 21), restriction (Art. 18)
- **DSAR timeline**: 30 days (extendable by 60 days for complex requests)
- **DPO**: required for public authorities, large-scale systematic monitoring, or large-scale special category processing
- **Breach notification**: 72 hours to supervisory authority, without undue delay to data subjects (if high risk)
- **DPIA**: required for high-risk processing (Art. 35)
- **Penalties**: up to EUR 20M or 4% of annual global turnover (whichever is higher)

### CCPA (California Consumer Privacy Act) / CPRA

**Key requirements**:
- **Consumer rights**: know, delete, opt-out of sale/sharing, non-discrimination, correct, limit use of sensitive PI
- **Response timeline**: 45 days (extendable by 45 days)
- **Applicability**: businesses with >$25M revenue, or 100k+ consumers/households, or 50%+ revenue from selling PI
- **Do Not Sell/Share**: prominent link required on website
- **Privacy policy**: updated at least every 12 months
- **Penalties**: $2,500 per unintentional violation, $7,500 per intentional violation
- **Private right of action**: for data breaches (statutory damages $100-$750 per consumer per incident)

## Tool Configuration

### Semgrep

```yaml
# .semgrep.yml -- security-focused configuration
rules:
  - id: hardcoded-secret
    patterns:
      - pattern: $KEY = "..."
      - metavariable-regex:
          metavariable: $KEY
          regex: (?i)(password|secret|token|api.?key|private.?key)
    message: Potential hardcoded secret found
    severity: ERROR

  - id: sql-injection
    pattern: |
      $QUERY = "..." + $INPUT
    message: Potential SQL injection via string concatenation
    severity: ERROR
```

### gitleaks

```toml
# .gitleaks.toml
[allowlist]
  paths = [
    '''test/''',
    '''.*_test\.go''',
    '''.*\.test\.(ts|js)''',
  ]

[[rules]]
  id = "generic-api-key"
  description = "Generic API Key"
  regex = '''(?i)(api[_-]?key|apikey)\s*[:=]\s*['"][a-zA-Z0-9]{16,}['"]'''
  severity = "high"
```

### MobSF Docker Setup

```bash
# Pull and run MobSF
docker pull opensecurity/mobile-security-framework-mobsf:latest
docker run -it --rm -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest

# Access at http://localhost:8000
# Default API key displayed in console output
```

### Frida Scripts

```javascript
// bypass-ssl-pinning.js -- For testing only
Java.perform(function () {
    var TrustManagerImpl = Java.use('com.android.org.conscrypt.TrustManagerImpl');
    TrustManagerImpl.verifyChain.implementation = function () {
        return Java.use('java.util.ArrayList').$new();
    };
});

// detect-root.js -- Check root detection implementation
Java.perform(function () {
    var RootBeer = Java.use('com.scottyab.rootbeer.RootBeer');
    RootBeer.isRooted.implementation = function () {
        console.log('[*] RootBeer.isRooted() called');
        return this.isRooted();
    };
});
```

## Security Headers Reference

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 0  (deprecated, rely on CSP)
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
Cache-Control: no-store (for sensitive responses)
```

## API Security Checklist

```
Authentication:
- [ ] API keys are not the sole authentication mechanism
- [ ] JWT signature algorithm is RS256 or ES256 (not HS256 with weak secret)
- [ ] JWT contains minimal claims (no sensitive data in payload)
- [ ] API versioning implemented
- [ ] Rate limiting per user/IP/endpoint

Authorization:
- [ ] Object-level authorization (IDOR prevention)
- [ ] Function-level authorization (admin endpoint protection)
- [ ] Field-level authorization (sensitive field filtering)
- [ ] Broken Object Property Level Authorization checked

Input:
- [ ] Request size limits configured
- [ ] Content-Type validation enforced
- [ ] GraphQL: query depth and complexity limits
- [ ] File upload: type validation, size limits, virus scanning
- [ ] Pagination limits enforced

Logging:
- [ ] Authentication events logged
- [ ] Authorization failures logged
- [ ] No sensitive data in logs (PII, tokens, passwords)
- [ ] Log integrity protection (append-only, centralized)
```
