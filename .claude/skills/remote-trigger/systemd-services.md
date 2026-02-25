# Systemd Service Units

## Webhook Handler Service

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

## Cloudflare Tunnel Service

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
