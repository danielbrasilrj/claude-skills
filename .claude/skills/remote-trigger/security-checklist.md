# Security Hardening Checklist

- [ ] Bind handler to `127.0.0.1` only (never `0.0.0.0`)
- [ ] HMAC-SHA256 verification enabled on all endpoints
- [ ] Webhook secrets stored in environment variables, not code
- [ ] Allowlist enforced for all commands
- [ ] Deny list blocks destructive patterns (`rm -rf`, `sudo`, piped curls)
- [ ] Request timestamps validated (reject > 5 min old)
- [ ] Rate limiting in place (per-user and global)
- [ ] Container isolation enabled for command execution
- [ ] Containers run with `--network=none` and `--read-only`
- [ ] Non-root user in Dockerfile
- [ ] systemd service hardened (`NoNewPrivileges`, `ProtectSystem`)
- [ ] TLS terminated at tunnel (Cloudflare/Tailscale)
- [ ] Logs do not contain secrets or tokens
- [ ] Bot tokens rotated on a schedule
- [ ] Audit log retained for 90+ days
