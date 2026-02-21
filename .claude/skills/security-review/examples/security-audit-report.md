# Security Audit Report

## Executive Summary

| Field | Value |
|-------|-------|
| **Project** | Acme Mobile Banking App |
| **Version** | 2.4.1 |
| **Platforms** | iOS 16+, Android 12+ |
| **Audit Date** | 2025-01-15 |
| **Auditor** | Security Team |
| **Regulations** | LGPD, GDPR |
| **Audit Type** | Full |

### Risk Summary

| Severity | Count |
|----------|-------|
| Critical | 1 |
| High | 2 |
| Medium | 3 |
| Low | 2 |
| Informational | 4 |
| **Total** | **12** |

### Overall Risk Rating: **HIGH**

Two critical/high findings require immediate remediation before the next release.

---

## Findings

### FINDING-001: Hardcoded API Key in Source Code [CRITICAL]

**Category**: M1 -- Improper Credential Usage
**CVSS**: 9.1 (Critical)
**Location**: `src/services/analytics.ts:14`

**Description**:
A third-party analytics API key is hardcoded directly in the source code. This key has write access to the analytics platform and can be extracted from the compiled binary.

**Evidence**:
```typescript
// src/services/analytics.ts:14
const ANALYTICS_KEY = "ak_live_7f3d2a1b9e4c8f6d5a2b1c3e4f5a6b7c";
```

**Impact**:
An attacker can extract this key from the APK/IPA and use it to inject false analytics data, access analytics dashboards, or exhaust API quotas.

**Remediation**:
1. Remove the hardcoded key immediately
2. Rotate the API key in the analytics platform
3. Store the key in environment configuration, injected at build time
4. Add Semgrep rule to prevent future hardcoded secrets
5. Scan git history for any other committed secrets

**Status**: Open

---

### FINDING-002: Refresh Token Not Rotated [HIGH]

**Category**: M3 -- Insecure Authentication/Authorization
**CVSS**: 7.5 (High)
**Location**: `src/auth/token-manager.ts`

**Description**:
The refresh token is reusable. When exchanging a refresh token for a new access token, the same refresh token is returned. This means a stolen refresh token provides indefinite access.

**Evidence**:
Token refresh response returns the same `refresh_token` value on every call. No `rotate_refresh_token: true` parameter in the OAuth configuration.

**Impact**:
If a refresh token is compromised (e.g., via device theft, backup extraction), the attacker maintains persistent access until the user explicitly revokes the session.

**Remediation**:
1. Enable refresh token rotation on the authorization server
2. Implement one-time-use refresh tokens
3. Detect reuse of rotated tokens (automatic session revocation)
4. Set absolute expiry on refresh tokens (30 days maximum)

**Status**: Open

---

### FINDING-003: Missing Certificate Pinning [HIGH]

**Category**: M5 -- Insecure Communication
**CVSS**: 7.4 (High)
**Location**: Network configuration (both platforms)

**Description**:
No certificate pinning is implemented for API communications. While TLS 1.2+ is enforced, the absence of pinning allows interception by an attacker with a trusted CA certificate installed on the device.

**Remediation**:
1. Implement public key pinning for production API domains
2. iOS: Configure via `Info.plist` or `TrustKit`
3. Android: Configure via `network_security_config.xml`
4. Include backup pins for key rotation
5. Implement pin failure reporting

**Status**: Open

---

### FINDING-004: Excessive Android Permissions [MEDIUM]

**Category**: M8 -- Security Misconfiguration
**CVSS**: 5.3 (Medium)
**Location**: `android/app/src/main/AndroidManifest.xml`

**Description**:
The app requests `READ_PHONE_STATE` and `ACCESS_FINE_LOCATION` permissions that are not required for core banking functionality.

**Remediation**:
1. Remove unnecessary permissions from manifest
2. Implement runtime permission requests only when needed
3. Document justification for each permission

**Status**: Open

---

### FINDING-005: LGPD DSAR Process Incomplete [MEDIUM]

**Category**: Privacy Compliance
**Location**: Backend API

**Description**:
The data subject access request (DSAR) endpoint (`/api/v1/user/data-export`) does not include data from the analytics and logging subsystems. The 15-day LGPD response window is at risk due to manual steps required to gather this data.

**Remediation**:
1. Integrate analytics and logging data into the DSAR export
2. Automate the full data export pipeline
3. Test end-to-end DSAR flow and verify 15-day compliance
4. Document all data sources in the processing activity register

**Status**: Open

---

### FINDING-006: Sensitive Data in Android Logs [MEDIUM]

**Category**: M9 -- Insecure Data Storage
**CVSS**: 5.0 (Medium)
**Location**: `src/utils/logger.ts`

**Description**:
The logging utility includes user email addresses and partial account numbers in debug-level log output. On Android, these are visible via logcat to other apps with `READ_LOGS` permission on older API levels.

**Remediation**:
1. Implement log sanitization for PII
2. Disable debug logging in release builds
3. Review all log statements for sensitive data

**Status**: Open

---

### FINDING-007: Password Policy Allows Weak Passwords [LOW]

**Category**: M3 -- Insecure Authentication
**Location**: `src/auth/password-validator.ts`

**Description**:
Password policy requires only 6 characters minimum with no complexity requirements. No check against breached password databases (HaveIBeenPwned).

**Remediation**:
1. Increase minimum length to 8 characters
2. Check against HaveIBeenPwned API (k-anonymity model)
3. Implement zxcvbn for password strength estimation

**Status**: Open

---

### FINDING-008: Missing Security Headers [LOW]

**Category**: M8 -- Security Misconfiguration
**Location**: API gateway configuration

**Description**:
Several recommended security headers are missing from API responses: `Strict-Transport-Security`, `Content-Security-Policy`, `Permissions-Policy`.

**Remediation**:
Add headers to API gateway/reverse proxy configuration.

**Status**: Open

---

## Informational Findings

1. **INFO-001**: Consider implementing device binding for high-value transactions
2. **INFO-002**: App allows screenshots on sensitive screens (balance, transactions)
3. **INFO-003**: No jailbreak/root detection implemented
4. **INFO-004**: Consider adding biometric authentication as MFA option

---

## Recommendations Summary

| Priority | Action | Finding | Effort |
|----------|--------|---------|--------|
| Immediate | Remove hardcoded API key and rotate | FINDING-001 | Low |
| Immediate | Enable refresh token rotation | FINDING-002 | Medium |
| Before release | Implement certificate pinning | FINDING-003 | Medium |
| Next sprint | Remove excess permissions | FINDING-004 | Low |
| Next sprint | Complete DSAR automation | FINDING-005 | High |
| Next sprint | Sanitize logs | FINDING-006 | Medium |
| Backlog | Strengthen password policy | FINDING-007 | Low |
| Backlog | Add security headers | FINDING-008 | Low |

---

## Follow-Up

- **Re-audit date**: 2025-04-15 (quarterly)
- **Critical findings re-test**: 2025-02-01
- **Next full audit**: 2025-07-15
