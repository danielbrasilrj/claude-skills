# HMAC-SHA256 Verification Deep Dive

## Why HMAC-SHA256

- Ensures the request body has not been tampered with.
- Proves the sender possesses the shared secret.
- Timing-safe comparison prevents timing attacks.

## Implementation Rules

1. **Always use the raw body.** If you parse JSON first, re-serialization may
   differ from the original bytes.
2. **Use `crypto.timingSafeEqual`** (Node) or `hmac.compare_digest` (Python).
   Never use `===` or `==` for signature comparison.
3. **Include a timestamp** in the signed payload when possible to prevent replay
   attacks. Slack includes `X-Slack-Request-Timestamp`; for custom webhooks,
   add an `X-Timestamp` header and reject requests older than 5 minutes.

## Generating Secrets

```bash
# Generate a 256-bit secret
openssl rand -hex 32
```

Store the secret in environment variables or a secrets manager. Never commit
secrets to source control.
