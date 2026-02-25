---
name: notification-system
description: Push notifications and in-app messaging — FCM, APNs, deep linking, scheduling, analytics. i18n templates (en, pt-BR).
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

| Provider  | Best For                      | Cost                | Payload Limit |
| --------- | ----------------------------- | ------------------- | ------------- |
| FCM       | Universal (Android, iOS, Web) | Free                | 4 KB          |
| APNs      | iOS-only apps                 | Free                | 4 KB          |
| OneSignal | Multi-platform orchestration  | Free tier available | 4 KB          |

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

| Chain With               | Purpose                                  |
| ------------------------ | ---------------------------------------- |
| `conversion-copywriting` | Optimize notification copy               |
| `ab-test-generator`      | Design notification experiments          |
| `email-marketing`        | Coordinate push + email campaigns        |
| `ci-cd-pipeline`         | Automate notification service deployment |

## Expo Push — Gotchas & Lessons Learned

### Token Registration

- **Register at app root**, gated by `isAuthenticated` — NOT only in settings/profile screens
- Re-register on auth state change (useEffect dep on `isAuthenticated`)
- `getExpoPushTokenAsync` requires `projectId` from `Constants.expoConfig.extra.eas.projectId`
- Expo Push API **silently accepts fake/expired tokens** — no error returned

### clearToken with null

- Sending `{ token: null }` fails if DTO uses `@IsString() @Matches()` without `@IsOptional()` + `@ValidateIf`
- Backend must handle null explicitly → clear push_token on user record
- Use `@ValidateIf((o) => o.token !== null)` to skip string validation when null

### Deep Link Fallback

- Always add a fallback route when `data.screen` is missing/unknown
- Users tap notifications expecting something to happen — navigate to Notifications screen at minimum

### Debugging on Preview Builds

- Silent `try/catch` makes push issues impossible to debug on device
- During dev: add temporary visible alerts (`Alert.alert`) for token registration success/failure
- Remove debug alerts before shipping — use `__DEV__` guard or temporary commits

### OTA & Push Tokens

- OTA updates need **double app restart** (download → apply) before new code runs
- `EXPO_PUBLIC_*` env vars from `eas.json` are only set during `eas build`, NOT `eas update`
- Never rely on `EXPO_PUBLIC_*` for API URLs — hardcode in source

### CLI Testing

- zsh escapes `!` in strings — use file payloads (`-d @payload.json`) for UTF-8 notifications
- Always test with real device, not just Expo Go (token format differs)

## References

- [provider-setup.md](provider-setup.md) -- FCM, APNs, OneSignal, Expo setup with code samples
- [channels-categories.md](channels-categories.md) -- Android channels and iOS categories configuration
- [deep-linking.md](deep-linking.md) -- Universal Links, App Links, custom URL schemes, UTM attribution
- [scheduling-patterns.md](scheduling-patterns.md) -- Timezone scheduling, rate limiting, recurring notifications
- [analytics-tracking.md](analytics-tracking.md) -- Event schema, tracking implementation, key metrics SQL
- [advanced-patterns.md](advanced-patterns.md) -- In-app center, frequency capping, quiet hours, rich notifications, A/B testing
- [platform-setup.md](platform-setup.md) -- React Native, Expo managed, and Web service worker setup

## Troubleshooting

| Problem                        | Solution                                                      |
| ------------------------------ | ------------------------------------------------------------- |
| Notifications not delivered    | Check token validity; verify provider credentials             |
| Low opt-in rate                | Ask at contextual moment, not on first launch                 |
| Deep link not opening          | Verify URL scheme registered in app config                    |
| OneSignal missing language     | English fallback always required in payload                   |
| Token not registering          | Ensure registration runs at app root, not just profile screen |
| clearToken 400 error           | DTO needs `@IsOptional()` + `@ValidateIf` for null tokens     |
| Can't debug on device          | Add temporary `Alert.alert` calls, guard with `__DEV__`       |
| Push works locally but not OTA | Double restart needed; check hardcoded API URL                |
