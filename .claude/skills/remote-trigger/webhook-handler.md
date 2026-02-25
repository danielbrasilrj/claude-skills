# Webhook Handler Full Implementation

## Node.js (Express)

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
    .then((result) => res.json({ status: 'ok', result }))
    .catch((err) => res.status(500).json({ error: err.message }));
});

// --- Telegram endpoint ---
app.post('/telegram', (req, res) => {
  const message = req.body.message;
  if (!message || !message.text) return res.sendStatus(200);

  const userId = String(message.from.id);
  const chatId = message.chat.id;
  const command = message.text.replace(/^\//, '').trim();

  handleCommand(command, userId, 'telegram')
    .then((result) => sendTelegramReply(chatId, result))
    .catch((err) => sendTelegramReply(chatId, `Error: ${err.message}`));

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
      .then((result) => sendSlackReply(channel, threadTs, result))
      .catch((err) => sendSlackReply(channel, threadTs, `Error: ${err.message}`));
  }

  res.sendStatus(200);
});

// --- Core functions ---

function verifyHMAC(payload, signature, secret) {
  if (!signature || !secret) return false;
  const expected = crypto.createHmac('sha256', secret).update(payload, 'utf8').digest('hex');
  try {
    return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected));
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
  const expected =
    'v0=' + crypto.createHmac('sha256', secret).update(baseString, 'utf8').digest('hex');

  try {
    return crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(signature));
  } catch {
    return false;
  }
}

async function handleCommand(commandStr, userId, platform) {
  // Match against allowlist
  const matched = allowlist.allowed_commands.find((cmd) => {
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
  if (!matched.allowed_users.includes('*') && !matched.allowed_users.includes(userId)) {
    throw new Error(`User ${userId} not authorized for ${matched.name}`);
  }

  console.log(`[${platform}] User ${userId} executing: ${matched.name}`);

  return new Promise((resolve, reject) => {
    const args = ['-p', `Execute: ${commandStr}`, '--output-format', 'text'];
    execFile(
      'claude',
      args,
      {
        timeout: 120000,
        maxBuffer: 1024 * 1024,
      },
      (err, stdout, stderr) => {
        if (err) return reject(new Error(stderr || err.message));
        resolve(stdout.trim());
      },
    );
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
      Authorization: `Bearer ${token}`,
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

## Python (FastAPI alternative)

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
