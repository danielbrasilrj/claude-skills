# Platform-Specific Webhook Formats

## Telegram Update Object

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

## Slack Event Payload

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
