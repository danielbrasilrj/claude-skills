# Remote Trigger -- Reference

## Table of Contents

1. [Webhook Handler Full Implementation](#webhook-handler-full-implementation)
2. [HMAC-SHA256 Verification Deep Dive](#hmac-sha256-verification-deep-dive)
3. [Tunnel Configuration Reference](#tunnel-configuration-reference)
4. [Platform-Specific Webhook Formats](#platform-specific-webhook-formats)
5. [Container Runner Dockerfile](#container-runner-dockerfile)
6. [Systemd Service Units](#systemd-service-units)
7. [Monitoring and Alerting](#monitoring-and-alerting)
8. [Security Hardening Checklist](#security-hardening-checklist)

---

## Webhook Handler Full Implementation

### Node.js (Express)

```javascript
const express = require('express');
const crypto = require('crypto');
const { execFile } = require('child_process');
const yaml = require('js-yaml');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3400;
const BIND_HOST = '127.0.0.1';

// Load allowlist
const allowlist = yaml.load(fs.readFileSync('./allowlist.yml', 'utf8'));

// Raw body middleware for HMAC verification
app.use('/webhook', express.raw({ type: '*/*' }));
app.use('/telegram', express.json());
app.use('/slack', express.raw({ type: '*/*' }));

// --- Generic webhook endpoint ---
app.post('/webhook', (req, res) => {
  const signature = req.headers['x-signature-256'];
  const secret = process.env.WEBHOOK_SECRET;

  if (!verifyHMAC(req.body.toString(), signature, secret)) {
    console.error('HMAC verification failed');
    return res.status(401).json({ error: 'Invalid signature' });
  }

  const payload = JSON.parse(req.body.toString());
  handleCommand(payload.command, payload.user_id, 'webhook')
    .then(result => res.json({ status: 'ok', result }))
    .catch(err => res.status(500).json({ error: err.message }));
});

// --- Telegram endpoint ---
app.post('/telegram', (req, res) => {
  const message = req.body.message;
  if (!message || !message.text) return res.sendStatus(200);

  const userId = String(message.from.id);
  const chatId = message.chat.id;
  const command = message.text.replace(/^\//, '').trim();

  handleCommand(command, userId, 'telegram')
    .then(result => sendTelegramReply(chatId, result))
    .catch(err => sendTelegramReply(chatId, `Error: ${err.message}`));

  res.sendStatus(200);
});

// --- Slack endpoint ---
app.post('/slack', (req, res) => {
  const rawBody = req.body.toString();
  const timestamp = req.headers['x-slack-request-timestamp'];
  const slackSignature = req.headers['x-slack-signature'];

  if (!verifySlackSignature(rawBody, timestamp, slackSignature)) {
    return res.status(401).json({ error: 'Invalid Slack signature' });
  }

  const payload = JSON.parse(rawBody);

  // Handle URL verification challenge
  if (payload.type === 'url_verification') {
    return res.json({ challenge: payload.challenge });
  }

  if (payload.event && payload.event.type === 'app_mention') {
    const text = payload.event.text.replace(/<@[A-Z0-9]+>/g, '').trim();
    const userId = payload.event.user;
    const channel = payload.event.channel;
    const threadTs = payload.event.ts;

    handleCommand(text, userId, 'slack')
      .then(result => sendSlackReply(channel, threadTs, result))
      .catch(err => sendSlackReply(channel, threadTs, `Error: ${err.message}`));
  }

  res.sendStatus(200);
});

// --- Core functions ---

function verifyHMAC(payload, signature, secret) {
  if (!signature || !secret) return false;
  const expected = crypto
    .createHmac('sha256', secret)
    .update(payload, 'utf8')
    .digest('hex');
  try {
    return crypto.timingSafeEqual(
      Buffer.from(signature),
      Buffer.from(expected)
    );
  } catch {
    return false;
  }
}

function verifySlackSignature(body, timestamp, signature) {
  const secret = process.env.SLACK_SIGNING_SECRET;
  if (!secret || !timestamp || !signature) return false;

  // Reject requests older than 5 minutes
  const now = Math.floor(Date.now() / 1000);
  if (Math.abs(now - parseInt(timestamp)) > 300) return false;

  const baseString = `v0:${timestamp}:${body}`;
  const expected = 'v0=' + crypto
    .createHmac('sha256', secret)
    .update(baseString, 'utf8')
    .digest('hex');

  try {
    return crypto.timingSafeEqual(
      Buffer.from(expected),
      Buffer.from(signature)
    );
  } catch {
    return false;
  }
}

async function handleCommand(commandStr, userId, platform) {
  // Match against allowlist
  const matched = allowlist.allowed_commands.find(cmd => {
    const regex = new RegExp(cmd.pattern);
    return regex.test(commandStr);
  });

  if (!matched) {
    throw new Error(`Command not in allowlist: ${commandStr}`);
  }

  // Check denied patterns
  for (const denied of allowlist.denied_patterns || []) {
    if (new RegExp(denied).test(commandStr)) {
      throw new Error(`Command matches denied pattern`);
    }
  }

  // Check user permission
  if (!matched.allowed_users.includes('*') &&
      !matched.allowed_users.includes(userId)) {
    throw new Error(`User ${userId} not authorized for ${matched.name}`);
  }

  console.log(`[${platform}] User ${userId} executing: ${matched.name}`);

  return new Promise((resolve, reject) => {
    const args = ['-p', `Execute: ${commandStr}`, '--output-format', 'text'];
    execFile('claude', args, {
      timeout: 120000,
      maxBuffer: 1024 * 1024,
    }, (err, stdout, stderr) => {
      if (err) return reject(new Error(stderr || err.message));
      resolve(stdout.trim());
    });
  });
}

async function sendTelegramReply(chatId, text) {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  const url = `https://api.telegram.org/bot${token}/sendMessage`;
  await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      chat_id: chatId,
      text: text.substring(0, 4096), // Telegram message limit
      parse_mode: 'Markdown',
    }),
  });
}

async function sendSlackReply(channel, threadTs, text) {
  const token = process.env.SLACK_BOT_TOKEN;
  await fetch('https://slack.com/api/chat.postMessage', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    },
    body: JSON.stringify({
      channel,
      thread_ts: threadTs,
      text: text.substring(0, 4000),
    }),
  });
}

app.listen(PORT, BIND_HOST, () => {
  console.log(`Webhook handler listening on ${BIND_HOST}:${PORT}`);
});
```

### Python (FastAPI alternative)

```python
import hashlib
import hmac
import json
import os
import subprocess
import time
from fastapi import FastAPI, Request, HTTPException

app = FastAPI()
WEBHOOK_SECRET = os.environ["WEBHOOK_SECRET"]

def verify_hmac(payload: bytes, signature: str, secret: str) -> bool:
    expected = hmac.new(
        secret.encode(), payload, hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, signature)

@app.post("/webhook")
async def webhook(request: Request):
    body = await request.body()
    sig = request.headers.get("x-signature-256", "")

    if not verify_hmac(body, sig, WEBHOOK_SECRET):
        raise HTTPException(401, "Invalid signature")

    data = json.loads(body)
    result = subprocess.run(
        ["claude", "-p", f"Execute: {data['command']}",
         "--output-format", "text"],
        capture_output=True, text=True, timeout=120,
    )

    if result.returncode != 0:
        raise HTTPException(500, result.stderr)

    return {"status": "ok", "result": result.stdout.strip()}
```

---

## HMAC-SHA256 Verification Deep Dive

### Why HMAC-SHA256

- Ensures the request body has not been tampered with.
- Proves the sender possesses the shared secret.
- Timing-safe comparison prevents timing attacks.

### Implementation Rules

1. **Always use the raw body.** If you parse JSON first, re-serialization may
   differ from the original bytes.
2. **Use `crypto.timingSafeEqual`** (Node) or `hmac.compare_digest` (Python).
   Never use `===` or `==` for signature comparison.
3. **Include a timestamp** in the signed payload when possible to prevent replay
   attacks. Slack includes `X-Slack-Request-Timestamp`; for custom webhooks,
   add an `X-Timestamp` header and reject requests older than 5 minutes.

### Generating Secrets

```bash
# Generate a 256-bit secret
openssl rand -hex 32
```

Store the secret in environment variables or a secrets manager. Never commit
secrets to source control.

---

## Tunnel Configuration Reference

### Cloudflare Tunnel Config File

```yaml
# ~/.cloudflared/config.yml
tunnel: <TUNNEL_UUID>
credentials-file: /home/user/.cloudflared/<TUNNEL_UUID>.json

ingress:
  - hostname: trigger.yourdomain.com
    service: http://127.0.0.1:3400
    originRequest:
      noTLSVerify: false
      connectTimeout: 30s
  - service: http_status:404
```

### Tailscale Funnel (public access via Tailscale)

```bash
# Expose a local port publicly via Tailscale Funnel
tailscale funnel 3400

# Or restrict to Tailscale network only (default)
# Access via https://your-machine.tail12345.ts.net:3400
```

### ngrok (development only, not for production)

```bash
ngrok http 3400 --authtoken=$NGROK_TOKEN
```

---

## Platform-Specific Webhook Formats

### Telegram Update Object

```json
{
  "update_id": 123456789,
  "message": {
    "message_id": 42,
    "from": {
      "id": 87654321,
      "is_bot": false,
      "first_name": "Daniel",
      "username": "danielcarmo"
    },
    "chat": { "id": 87654321, "type": "private" },
    "date": 1700000000,
    "text": "/deploy staging"
  }
}
```

### Slack Event Payload

```json
{
  "type": "event_callback",
  "event": {
    "type": "app_mention",
    "user": "U12345ABC",
    "text": "<@UBOTID> deploy staging",
    "channel": "C67890DEF",
    "ts": "1700000000.000100"
  }
}
```

---

## Container Runner Dockerfile

```dockerfile
FROM node:20-slim

RUN npm install -g @anthropic-ai/claude-code

RUN useradd -m runner
USER runner
WORKDIR /workspace

ENTRYPOINT ["claude"]
```

Build and use:

```bash
docker build -t claude-runner:latest .

# Run with isolation
docker run --rm \
  --network=none \
  --memory=512m \
  --cpus=1 \
  --read-only \
  --tmpfs /tmp:size=100m \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  claude-runner:latest \
  -p "Run the test suite" --output-format text
```

---

## Systemd Service Units

### Webhook Handler Service

```ini
# /etc/systemd/system/remote-trigger.service
[Unit]
Description=Remote Trigger Webhook Handler
After=network.target

[Service]
Type=simple
User=webhook
WorkingDirectory=/opt/remote-trigger
ExecStart=/usr/bin/node handler.js
Restart=on-failure
RestartSec=5
EnvironmentFile=/opt/remote-trigger/.env

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ReadWritePaths=/opt/remote-trigger/logs

[Install]
WantedBy=multi-user.target
```

### Cloudflare Tunnel Service

```ini
# /etc/systemd/system/cloudflared.service
[Unit]
Description=Cloudflare Tunnel for Remote Trigger
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=cloudflared
ExecStart=/usr/local/bin/cloudflared tunnel run remote-trigger
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

---

## Monitoring and Alerting

### Health Check Endpoint

Add to the handler:

```javascript
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});
```

### Log Format

Use structured JSON logging:

```javascript
function log(level, message, meta = {}) {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    level,
    message,
    ...meta,
  }));
}

// Usage
log('info', 'Command executed', {
  platform: 'telegram',
  user: '87654321',
  command: 'deploy staging',
  duration_ms: 4500,
});
```

### Metrics to Track

| Metric                    | Alert Threshold        |
|---------------------------|------------------------|
| Request rate              | > 100/min (potential abuse) |
| HMAC failure rate         | > 5/min                |
| Command execution time    | > 120s                 |
| Error rate                | > 10%                  |
| Handler uptime            | < 99.9%                |

---

## Security Hardening Checklist

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
