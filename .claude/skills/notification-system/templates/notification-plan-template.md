# Notification Strategy Template

Project: `[Your Project Name]`  
Created: `[Date]`  
Owner: `[Team/Person]`

---

## 1. Notification Channels

Define all notification channels your app will use.

| Channel ID | Name | Description | Importance (Android) | Category (iOS) | User Control |
|---|---|---|---|---|---|
| `transactional` | Order Updates | Order confirmations, shipping, delivery | HIGH | ORDER_UPDATE | Cannot disable |
| `reminders` | Reminders | Appointment reminders, task due dates | HIGH | REMINDER | Can customize frequency |
| `marketing` | Promotions | Sales, new products, exclusive offers | DEFAULT | MARKETING | Can disable |
| `social` | Social | New followers, mentions, comments | DEFAULT | SOCIAL | Can disable |
| `system` | System Alerts | Security alerts, password changes | MAX | SYSTEM | Cannot disable |

**Notes:**
- Transactional and system channels should not be disableable (user safety/experience).
- Marketing channels must always be opt-in and easily disableable.
- Use Android importance levels: MAX, HIGH, DEFAULT, LOW, MIN.

---

## 2. Notification Types

Define each notification type with triggers, content, and targeting.

### Welcome Notification

**Trigger:** User completes signup  
**Channel:** `transactional`  
**Delay:** Immediate  
**Frequency Cap:** Once per user  
**Deep Link:** `app://profile/setup`

**Content (i18n):**
```yaml
en:
  title: "Welcome to {{app_name}}!"
  body: "Complete your profile to get personalized recommendations."
  cta: "Set Up Profile"

es:
  title: "¡Bienvenido(a) a {{app_name}}!"
  body: "Completa tu perfil para obtener recomendaciones personalizadas."
  cta: "Configurar Perfil"

pt-BR:
  title: "Bem-vindo(a) ao {{app_name}}!"
  body: "Complete seu perfil para receber recomendações personalizadas."
  cta: "Configurar Perfil"
```

**Target Audience:** All new users  
**A/B Test Ideas:**
- Title: Formal vs. friendly tone
- Send time: Immediate vs. 1 hour delay
- Emoji: With vs. without

---

### Order Confirmation

**Trigger:** Order placed successfully  
**Channel:** `transactional`  
**Delay:** Immediate  
**Frequency Cap:** Unlimited  
**Deep Link:** `app://orders/{{order_id}}`

**Content (i18n):**
```yaml
en:
  title: "Order confirmed! 🎉"
  body: "Order #{{order_number}} will arrive by {{delivery_date}}."
  cta: "View Order"

es:
  title: "¡Pedido confirmado! 🎉"
  body: "El pedido #{{order_number}} llegará el {{delivery_date}}."
  cta: "Ver Pedido"

pt-BR:
  title: "Pedido confirmado! 🎉"
  body: "O pedido #{{order_number}} chegará até {{delivery_date}}."
  cta: "Ver Pedido"
```

**Target Audience:** All users who place an order  
**Rich Media:** Include product thumbnail (iOS/Android rich notifications)

---

### Abandoned Cart Reminder

**Trigger:** User adds item to cart, doesn't complete purchase for 2 hours  
**Channel:** `marketing`  
**Delay:** 2 hours after cart abandonment  
**Frequency Cap:** 1 per day  
**Deep Link:** `app://cart`

**Content (i18n):**
```yaml
en:
  title: "Don't forget your items!"
  body: "{{item_count}} items are waiting in your cart. Complete your purchase now!"
  cta: "View Cart"

es:
  title: "¡No olvides tus artículos!"
  body: "{{item_count}} artículos te esperan en tu carrito. ¡Completa tu compra ahora!"
  cta: "Ver Carrito"

pt-BR:
  title: "Não esqueça seus itens!"
  body: "{{item_count}} itens estão esperando no seu carrinho. Finalize sua compra agora!"
  cta: "Ver Carrinho"
```

**Target Audience:** Users with items in cart (exclude users who opted out of marketing)  
**A/B Test Ideas:**
- Include discount code in variant B
- Send time: 2 hours vs. 24 hours
- Urgency messaging: "Limited stock" vs. neutral

---

### Daily Reminder

**Trigger:** Daily at user's preferred time (default: 9 AM local time)  
**Channel:** `reminders`  
**Delay:** Daily  
**Frequency Cap:** 1 per day  
**Deep Link:** `app://today`

**Content (i18n):**
```yaml
en:
  title: "Good morning! ☀️"
  body: "You have {{task_count}} tasks for today."
  cta: "View Tasks"

es:
  title: "¡Buenos días! ☀️"
  body: "Tienes {{task_count}} tareas para hoy."
  cta: "Ver Tareas"

pt-BR:
  title: "Bom dia! ☀️"
  body: "Você tem {{task_count}} tarefas para hoje."
  cta: "Ver Tarefas"
```

**Target Audience:** Users who enabled daily reminders  
**Quiet Hours:** Skip if between 10 PM - 8 AM user's local time

---

### Flash Sale Alert

**Trigger:** Admin triggers flash sale campaign  
**Channel:** `marketing`  
**Delay:** Immediate  
**Frequency Cap:** 2 per week  
**Deep Link:** `app://sale/{{sale_id}}?utm_source=push&utm_campaign=flash_sale`

**Content (i18n):**
```yaml
en:
  title: "⚡ Flash Sale! 50% off everything"
  body: "Limited time only. Shop now before it's gone!"
  cta: "Shop Sale"

es:
  title: "⚡ ¡Oferta Relámpago! 50% de descuento en todo"
  body: "Solo por tiempo limitado. ¡Compra ahora antes de que termine!"
  cta: "Ver Ofertas"

pt-BR:
  title: "⚡ Oferta Relâmpago! 50% de desconto em tudo"
  body: "Por tempo limitado. Compre agora antes que acabe!"
  cta: "Ver Ofertas"
```

**Target Audience:** Segmented (users who purchased in last 30 days OR high engagement)  
**Rate Limiting:** Send to 10k users, then spread remaining sends over 10 minutes

---

## 3. Frequency Caps

Global frequency caps to prevent notification fatigue.

| Channel | Cap | Period |
|---|---|---|
| Transactional | 10 | per hour |
| Reminders | 5 | per day |
| Marketing | 2 | per day |
| Social | 10 | per day |

**Quiet Hours (per user timezone):**
- Default: 10 PM - 8 AM
- User can customize in app settings

---

## 4. Permission Strategy

### Initial Permission Request

**Platform:** iOS only (Android grants permission by default)  
**Timing:** DO NOT ask on first app launch. Ask at contextual moment:
- After user completes first meaningful action (e.g., creates account, makes first order)
- After user browses 3+ products
- When user enables a feature that requires notifications (e.g., reminders)

**Pre-permission Dialog (iOS):**
Before calling system permission prompt, show custom alert:
```
Stay Updated!

Get notified about:
- Order updates and delivery status
- Exclusive deals and sales
- Reminders for saved items

[Allow Notifications] [Not Now]
```

### Permission Denied Handling

If user denies permission:
1. Do NOT repeatedly ask
2. Gracefully degrade: show in-app notifications only
3. Add a prompt in settings: "Enable notifications to get delivery updates"

---

## 5. A/B Testing Roadmap

| Experiment | Variants | Metric | Duration |
|---|---|---|---|
| Welcome notification timing | A: Immediate, B: 1 hour delay | Profile completion rate | 2 weeks |
| Cart reminder discount | A: No discount, B: 10% off | Cart conversion rate | 2 weeks |
| Flash sale emoji | A: With emoji, B: Without | Open rate | 1 week |
| Reminder send time | A: 9 AM, B: 6 PM | Task completion rate | 2 weeks |

**Test one variable at a time.** Run tests for minimum 1 week or until statistical significance.

---

## 6. Analytics Tracking

Track these events for every notification:

- `NOTIFICATION_SENT` — When notification is sent
- `NOTIFICATION_DELIVERED` — When device receives notification
- `NOTIFICATION_OPENED` — When user taps notification
- `NOTIFICATION_DISMISSED` — When user swipes away notification
- `NOTIFICATION_ACTION` — When user taps action button (iOS)
- `NOTIFICATION_CONVERSION` — When user completes target action (e.g., purchases after cart reminder)

**Key Metrics:**
- Delivery Rate: `delivered / sent`
- Open Rate: `opened / delivered`
- Conversion Rate: `conversions / opened`
- Time to Open: Median time from delivery to open

**Dashboards:**
- Daily notification performance (by channel)
- Notification funnel (sent → delivered → opened → converted)
- A/B test results

---

## 7. Localization

All notifications must support at least:
- English (`en`)
- Spanish (`es`)
- Portuguese (`pt-BR`)

**Fallback Strategy:**
1. Try user's preferred language
2. Try device language
3. Fallback to English

**Translation Checklist:**
- [ ] All notification titles translated
- [ ] All notification bodies translated
- [ ] All CTA button text translated
- [ ] Variable placeholders preserved (e.g., `{{order_number}}`)
- [ ] Character limits respected (title: 50 chars, body: 150 chars)

---

## 8. Implementation Checklist

- [ ] Notification channels/categories created (Android/iOS)
- [ ] Token registration implemented
- [ ] Token refresh on app launch implemented
- [ ] Stale token cleanup implemented (remove after 3 failed deliveries)
- [ ] Deep linking configured (URL schemes + universal links)
- [ ] Pre-permission dialog implemented (iOS)
- [ ] Permission denied handling implemented
- [ ] In-app notification center implemented
- [ ] Notification templates created with i18n support
- [ ] Rate limiting and frequency caps implemented
- [ ] Quiet hours implemented
- [ ] Analytics tracking implemented
- [ ] A/B testing framework integrated
- [ ] Notification settings UI added to app
- [ ] Provider credentials configured (FCM/APNs)
- [ ] Server-side notification service deployed

---

## 9. Rollout Plan

### Phase 1: Transactional Notifications Only
**Duration:** 2 weeks  
**Notifications:** Order confirmation, shipping updates  
**Goal:** Validate delivery infrastructure and deep linking

### Phase 2: Add Reminders
**Duration:** 2 weeks  
**Notifications:** Daily reminders, appointment reminders  
**Goal:** Test scheduling and timezone handling

### Phase 3: Add Marketing (Limited)
**Duration:** 2 weeks  
**Notifications:** Abandoned cart only (1 per day cap)  
**Goal:** Test opt-in flow and frequency capping

### Phase 4: Full Rollout
**Duration:** Ongoing  
**Notifications:** All notification types enabled  
**Goal:** Monitor engagement and iterate

---

## 10. Optimization Strategy

### Month 1
- Monitor open rates by notification type
- Identify lowest-performing notifications
- Run A/B test on worst-performing notification

### Month 2
- Implement quiet hours if not already done
- Add rich media (images) to top notifications
- Test send time optimization for reminders

### Month 3
- Implement in-app notification center
- Add notification actions (iOS quick replies, Android action buttons)
- Test segmentation strategies (high-value users vs. all users)

### Ongoing
- Weekly review of notification metrics
- Monthly A/B test rotation
- Quarterly user survey on notification preferences

---

## Notes

**Legal Compliance:**
- GDPR: Users can opt out of marketing notifications at any time
- CCPA: Provide clear disclosure of notification data collection
- CAN-SPAM: Do not send marketing notifications to users who opted out

**Best Practices:**
- Always include an unsubscribe option in app settings
- Never send promotional notifications after user opts out
- Transactional notifications (order updates) are exempt from opt-out
- Include UTM parameters in all deep links for attribution

---

**Next Steps:**
1. Fill in all notification types for your app
2. Review with product and engineering teams
3. Implement in phases
4. Monitor metrics and iterate
