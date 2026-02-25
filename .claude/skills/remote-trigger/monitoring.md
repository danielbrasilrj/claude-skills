# Monitoring and Alerting

## Health Check Endpoint

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

## Log Format

Use structured JSON logging:

```javascript
function log(level, message, meta = {}) {
  console.log(
    JSON.stringify({
      timestamp: new Date().toISOString(),
      level,
      message,
      ...meta,
    }),
  );
}

// Usage
log('info', 'Command executed', {
  platform: 'telegram',
  user: '87654321',
  command: 'deploy staging',
  duration_ms: 4500,
});
```

## Metrics to Track

| Metric                 | Alert Threshold             |
| ---------------------- | --------------------------- |
| Request rate           | > 100/min (potential abuse) |
| HMAC failure rate      | > 5/min                     |
| Command execution time | > 120s                      |
| Error rate             | > 10%                       |
| Handler uptime         | < 99.9%                     |
