# Tunnel Configuration Reference

## Cloudflare Tunnel Config File

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

## Tailscale Funnel (public access via Tailscale)

```bash
# Expose a local port publicly via Tailscale Funnel
tailscale funnel 3400

# Or restrict to Tailscale network only (default)
# Access via https://your-machine.tail12345.ts.net:3400
```

## ngrok (development only, not for production)

```bash
ngrok http 3400 --authtoken=$NGROK_TOKEN
```
