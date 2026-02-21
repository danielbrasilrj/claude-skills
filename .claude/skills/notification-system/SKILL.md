---
name: notification-system
description: |
  Push notification and in-app messaging skill. Covers setup for FCM, APNs, and OneSignal,
  notification scheduling, deep linking, A/B testing copy, and analytics tracking. Includes
  i18n-ready templates for common notification types (default: en, pt-BR). Backend-agnostic.
  Use when setting up push notifications, creating notification templates, implementing deep
  linking, or optimizing notification engagement.
---

## Purpose

Notification System provides procedures for implementing push notifications and in-app messaging across mobile and web platforms. It covers provider setup, template creation with i18n support, deep linking, and optimization through A/B testing.

## When to Use

- Setting up push notification infrastructure
- Creating notification templates for different user journeys
- Implementing deep linking from notifications
- A/B testing notification copy and timing
- Managing notification permissions and token lifecycle

## Prerequisites

- Push notification provider (FCM, APNs, OneSignal, or equivalent)
- `domain-intelligence` config for platform targets
- Server-side notification service (for scheduling and templating)

## Procedures

### 1. Provider Selection

| Provider | Best For | Cost | Payload Limit |
|---|---|---|---|
| FCM | Universal (Android, iOS, Web) | Free | 4 KB |
| APNs | iOS-only apps | Free | 4 KB |
| OneSignal | Multi-platform orchestration | Free tier available | 4 KB |

### 2. Notification Templates (i18n)

```yaml
# Welcome notification
type: welcome
locale: en
title: "Welcome to {{app_name}}!"
body: "Tap to complete your profile and get started."
deep_link: "app://profile/setup"
cta: "Set Up Profile"

locale: pt-BR
title: "Bem-vindo(a) ao {{app_name}}!"
body: "Toque para completar seu perfil e começar."
deep_link: "app://profile/setup"
cta: "Configurar Perfil"

# Reminder notification
type: appointment_reminder
locale: en
title: "Reminder: {{service_name}} tomorrow"
body: "Your appointment is at {{time}} with {{provider_name}}."
deep_link: "app://appointments/{{appointment_id}}"

locale: pt-BR
title: "Lembrete: {{service_name}} amanhã"
body: "Seu agendamento é às {{time}} com {{provider_name}}."
deep_link: "app://appointments/{{appointment_id}}"
```

### 3. Deep Linking

Every notification should include a deep link:
- In-app: `app://[screen]/[id]`
- Fallback: web URL if app not installed
- Track: add UTM params for attribution

### 4. Token Lifecycle Management

- Register token on app launch
- Refresh on each app open
- Remove stale tokens (failed delivery 3+ times)
- Handle permission denied gracefully

### 5. A/B Testing

Test one variable at a time:
- Title copy (emotional vs informational)
- Send time (morning vs evening)
- Emoji in title (with vs without)
- CTA wording

### 6. Rate Limiting

Never send all notifications at once. Spread delivery:
- < 10K users: send immediately
- 10K-100K: spread over 5 minutes
- 100K+: spread over 15-30 minutes

## Templates

- `templates/notification-templates.md` — i18n templates for common types
- `templates/notification-config.yml` — Provider configuration template

## Examples

- `examples/welcome-notification-flow.md` — Complete welcome flow

## Chaining

| Chain With | Purpose |
|---|---|
| `conversion-copywriting` | Optimize notification copy |
| `ab-test-generator` | Design notification experiments |
| `email-marketing` | Coordinate push + email campaigns |
| `ci-cd-pipeline` | Automate notification service deployment |

## Troubleshooting

| Problem | Solution |
|---|---|
| Notifications not delivered | Check token validity; verify provider credentials |
| Low opt-in rate | Ask at contextual moment, not on first launch |
| Deep link not opening | Verify URL scheme registered in app config |
| OneSignal missing language | English fallback always required in payload |
