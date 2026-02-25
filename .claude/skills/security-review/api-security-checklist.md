# API Security Checklist

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
