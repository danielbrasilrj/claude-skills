# OWASP Mobile Top 10 2024 -- Detailed Guidance

## M1: Improper Credential Usage

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

## M2: Inadequate Supply Chain Security

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

## M3: Insecure Authentication/Authorization

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

## M4: Insufficient Input/Output Validation

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

## M5: Insecure Communication

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

## M6: Inadequate Privacy Controls

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

## M7: Insufficient Binary Protections

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

## M8: Security Misconfiguration

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

## M9: Insecure Data Storage

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

## M10: Insufficient Cryptography

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
