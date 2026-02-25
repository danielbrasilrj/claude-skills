---
name: remote-trigger
description: Remote automation via Telegram/Slack bots triggering Claude Code. Webhooks, HMAC verification, secure tunneling.
---

# Remote Trigger

## Purpose

Enable remote command execution of Claude Code workflows through messaging
platforms (Telegram, Slack) and generic webhooks. This skill provides
battle-tested patterns for binding to localhost, exposing services securely
through tunnels, verifying request authenticity via HMAC-SHA256, and
sandboxing execution inside containers.

## When to Use

- You need to trigger deployments, scripts, or Claude Code sessions from a
  mobile device or chat interface.
- You want a Telegram or Slack bot that kicks off CI/CD, data pipelines, or
  ad-hoc tasks on a remote dev machine.
- You need webhook endpoints that accept external events (GitHub, Stripe,
  custom services) and route them to Claude Code.
- You want to enforce strict security (HMAC verification, IP allowlisting,
  container isolation) on remote triggers.

## Prerequisites

| Requirement              | Details                                    |
| ------------------------ | ------------------------------------------ |
| Node.js >= 18            | Webhook handler runtime                    |
| Python >= 3.10           | Alternative handler runtime                |
| Tailscale or cloudflared | Secure tunnel to localhost                 |
| Docker (optional)        | Container isolation for triggered commands |
| Telegram Bot Token       | From @BotFather                            |
| Slack App credentials    | Bot token + signing secret from Slack API  |
| `claude` CLI             | Installed and authenticated                |

## Procedures

### 1. Architecture Overview

```
[Telegram/Slack/Webhook] --> [Tunnel (Tailscale/CF)] --> [localhost:PORT]
    --> [Webhook Handler] --> [Auth + Verify] --> [Claude Code CLI]
```

All traffic binds to `127.0.0.1`. External access is provided exclusively
through an encrypted tunnel. Never expose the handler port directly.

### 2. Secure Tunnel Setup

#### Tailscale (recommended for private networks)

```bash
# Install and authenticate
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey=tskey-auth-XXXXX

# Access your machine via Tailscale IP (100.x.y.z)
# No port forwarding needed; traffic stays on WireGuard mesh
```

#### Cloudflare Tunnel (recommended for public webhooks)

```bash
# Install cloudflared
brew install cloudflared  # macOS

# Create tunnel
cloudflared tunnel create remote-trigger
cloudflared tunnel route dns remote-trigger trigger.yourdomain.com

# Run tunnel pointing to local handler
cloudflared tunnel run --url http://127.0.0.1:3400 remote-trigger
```

### 3. Webhook Handler Implementation

The handler receives HTTP requests, verifies authenticity, and dispatches
commands to Claude Code. See [webhook-handler.md](webhook-handler.md) for the
full implementation (Node.js Express + Python FastAPI).

**Core verification flow:**

```javascript
const crypto = require('crypto');

function verifyHMAC(payload, signature, secret) {
  const expected = crypto.createHmac('sha256', secret).update(payload, 'utf8').digest('hex');
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected));
}
```

### 4. Permission Allowlisting

Create an allowlist configuration to restrict which commands can be triggered:

```yaml
# allowlist.yml
allowed_commands:
  - name: deploy
    pattern: "^deploy\\s+(staging|production)$"
    requires_approval: true
    allowed_users:
      - 'U12345' # Slack user ID
      - '87654321' # Telegram user ID

  - name: run-tests
    pattern: "^test\\s+\\S+$"
    requires_approval: false
    allowed_users: ['*']

  - name: status
    pattern: '^status$'
    requires_approval: false
    allowed_users: ['*']

denied_patterns:
  - "rm\\s+-rf"
  - "sudo\\s+"
  - "curl.*\\|.*sh"
```

### 5. Container Isolation

Wrap triggered commands in Docker containers to prevent lateral movement:

```bash
docker run --rm \
  --network=none \
  --memory=512m \
  --cpus=1 \
  --read-only \
  --tmpfs /tmp:size=100m \
  -v "$(pwd)/workspace:/workspace:ro" \
  -e CLAUDE_API_KEY="$CLAUDE_API_KEY" \
  claude-runner:latest \
  claude -p "Run tests for the auth module"
```

Key isolation flags:

- `--network=none`: No network access from container
- `--read-only`: Immutable filesystem
- `--memory` / `--cpus`: Resource limits
- Mount workspace as read-only

### 6. Telegram Bot Setup

See `templates/telegram-bot-setup.md` for the complete guide. Summary:

1. Create bot via @BotFather, save token.
2. Set webhook URL to your tunnel endpoint.
3. Handler parses `message.text`, checks `message.from.id` against allowlist.
4. Dispatches to Claude Code, streams response back via `sendMessage`.

### 7. Slack Bot Setup

See `templates/slack-bot-setup.md` for the complete guide. Summary:

1. Create Slack App at api.slack.com, enable Event Subscriptions.
2. Subscribe to `app_mention` and `message.im` events.
3. Verify requests using Slack signing secret (HMAC-SHA256 with `v0=` prefix).
4. Parse command from mention text, check user ID against allowlist.
5. Respond in thread using `chat.postMessage`.

## Templates

| Template                          | Purpose                                |
| --------------------------------- | -------------------------------------- |
| `templates/telegram-bot-setup.md` | Full Telegram bot configuration guide  |
| `templates/slack-bot-setup.md`    | Full Slack app configuration guide     |
| `templates/webhook-handler.md`    | Generic webhook handler implementation |

## Examples

| Example                              | Description                            |
| ------------------------------------ | -------------------------------------- |
| `examples/deploy-trigger-example.md` | End-to-end deploy trigger via Telegram |

## Chaining

- **ci-cd-pipeline**: Trigger CI/CD pipelines remotely via bot commands.
- **secret-management**: Store bot tokens and signing secrets securely.
- **security-review**: Audit the webhook handler for vulnerabilities.
- **notification-system**: Send push notifications on trigger completion.

## References

| File                                           | Topic                                      |
| ---------------------------------------------- | ------------------------------------------ |
| [webhook-handler.md](webhook-handler.md)       | Full webhook handler (Node.js + Python)    |
| [hmac-verification.md](hmac-verification.md)   | HMAC-SHA256 verification deep dive         |
| [tunnel-config.md](tunnel-config.md)           | Cloudflare, Tailscale, ngrok tunnel setup  |
| [platform-webhooks.md](platform-webhooks.md)   | Telegram and Slack webhook payload formats |
| [container-runner.md](container-runner.md)     | Docker container runner Dockerfile         |
| [systemd-services.md](systemd-services.md)     | Systemd service units for handler + tunnel |
| [monitoring.md](monitoring.md)                 | Health checks, logging, metrics            |
| [security-checklist.md](security-checklist.md) | Security hardening checklist               |

## Troubleshooting

| Issue                             | Resolution                                                                     |
| --------------------------------- | ------------------------------------------------------------------------------ |
| Webhook not receiving requests    | Verify tunnel is running; check `cloudflared tunnel info` or Tailscale status. |
| HMAC verification fails           | Ensure raw body is used (not parsed JSON). Check secret encoding matches.      |
| Telegram webhook 401              | Token mismatch. Re-register webhook with correct bot token.                    |
| Slack challenge fails             | Handler must respond to `url_verification` with the challenge value.           |
| Container command hangs           | Add `--timeout` flag to Docker run. Check resource limits.                     |
| Permission denied                 | User ID not in allowlist. Verify IDs match platform format.                    |
| Claude CLI not found in container | Ensure `claude` is installed in the Docker image. Mount the binary if needed.  |
