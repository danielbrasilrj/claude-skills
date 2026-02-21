# E-Commerce Notification Strategy Example

This is a complete, production-ready notification strategy for a fictional e-commerce app called "ShopNow".

---

## App Overview

**App Name:** ShopNow  
**Platforms:** iOS, Android, Web  
**Push Provider:** Firebase Cloud Messaging (FCM)  
**Languages:** English, Spanish, Portuguese (Brazil)  
**Target Users:** 100K+ active users  
**Key Features:** Product browsing, cart, orders, wishlist, reviews

---

## Notification Channels

| Channel ID | Name | Description | Importance | User Control |
|---|---|---|---|---|
| `orders` | Order Updates | Order confirmations, shipping, delivery | HIGH | Cannot disable |
| `price_drops` | Price Alerts | Price drop on wishlisted items | DEFAULT | Can disable |
| `promotions` | Deals & Offers | Flash sales, exclusive discounts | DEFAULT | Can disable |
| `cart` | Shopping Cart | Abandoned cart reminders | DEFAULT | Can disable |
| `reviews` | Review Reminders | Request reviews after delivery | LOW | Can disable |

---

## Notification Types

### 1. Order Confirmed

**Trigger:** User completes checkout  
**Channel:** `orders`  
**Delay:** Immediate  
**Deep Link:** `shopnow://orders/{{order_id}}`

```yaml
en:
  title: "Order confirmed! 🎉"
  body: "Order #{{order_number}} will arrive by {{delivery_date}}."
  image_url: "https://cdn.shopnow.com/orders/{{order_id}}/thumb.jpg"

es:
  title: "¡Pedido confirmado! 🎉"
  body: "El pedido #{{order_number}} llegará el {{delivery_date}}."
  image_url: "https://cdn.shopnow.com/orders/{{order_id}}/thumb.jpg"

pt-BR:
  title: "Pedido confirmado! 🎉"
  body: "O pedido #{{order_number}} chegará até {{delivery_date}}."
  image_url: "https://cdn.shopnow.com/orders/{{order_id}}/thumb.jpg"
```

**Analytics:**
- Track: `ORDER_NOTIFICATION_SENT`, `ORDER_NOTIFICATION_OPENED`
- Conversion: User views order details within 1 hour

---

### 2. Order Shipped

**Trigger:** Order status changes to "shipped"  
**Channel:** `orders`  
**Delay:** Immediate  
**Deep Link:** `shopnow://orders/{{order_id}}/tracking`

```yaml
en:
  title: "Your order has shipped! 📦"
  body: "Track your package in real-time. Arriving {{delivery_date}}."
  actions:
    - id: "TRACK"
      title: "Track Package"
    - id: "VIEW_ORDER"
      title: "View Order"

es:
  title: "¡Tu pedido ha sido enviado! 📦"
  body: "Rastrea tu paquete en tiempo real. Llega el {{delivery_date}}."
  actions:
    - id: "TRACK"
      title: "Rastrear Paquete"
    - id: "VIEW_ORDER"
      title: "Ver Pedido"

pt-BR:
  title: "Seu pedido foi enviado! 📦"
  body: "Rastreie seu pacote em tempo real. Chega em {{delivery_date}}."
  actions:
    - id: "TRACK"
      title: "Rastrear Pacote"
    - id: "VIEW_ORDER"
      title: "Ver Pedido"
```

**Analytics:**
- Track: `SHIPMENT_NOTIFICATION_SENT`, `SHIPMENT_NOTIFICATION_OPENED`, `TRACKING_CLICKED`

---

### 3. Order Out for Delivery

**Trigger:** Order status changes to "out_for_delivery"  
**Channel:** `orders`  
**Delay:** Immediate  
**Deep Link:** `shopnow://orders/{{order_id}}/tracking`

```yaml
en:
  title: "Your order arrives today! 🚚"
  body: "Your package is out for delivery. Expected by {{delivery_time}}."

es:
  title: "¡Tu pedido llega hoy! 🚚"
  body: "Tu paquete está en camino. Llegará a las {{delivery_time}}."

pt-BR:
  title: "Seu pedido chega hoje! 🚚"
  body: "Seu pacote está a caminho. Previsão de entrega às {{delivery_time}}."
```

---

### 4. Order Delivered

**Trigger:** Order status changes to "delivered"  
**Channel:** `orders`  
**Delay:** Immediate  
**Deep Link:** `shopnow://orders/{{order_id}}`

```yaml
en:
  title: "Your order has been delivered! ✅"
  body: "Hope you love it! Leave a review to help others."
  actions:
    - id: "REVIEW"
      title: "Write Review"
    - id: "VIEW_ORDER"
      title: "View Order"

es:
  title: "¡Tu pedido ha sido entregado! ✅"
  body: "¡Esperamos que te encante! Deja una reseña para ayudar a otros."
  actions:
    - id: "REVIEW"
      title: "Escribir Reseña"
    - id: "VIEW_ORDER"
      title: "Ver Pedido"

pt-BR:
  title: "Seu pedido foi entregado! ✅"
  body: "Esperamos que você adore! Deixe uma avaliação para ajudar outros."
  actions:
    - id: "REVIEW"
      title: "Avaliar"
    - id: "VIEW_ORDER"
      title: "Ver Pedido"
```

**Analytics:**
- Track: `DELIVERY_NOTIFICATION_SENT`, `REVIEW_CTA_CLICKED`
- Conversion: User submits review within 7 days

---

### 5. Abandoned Cart (2 hours)

**Trigger:** User adds item to cart, no checkout for 2 hours  
**Channel:** `cart`  
**Delay:** 2 hours  
**Frequency Cap:** 1 per day  
**Deep Link:** `shopnow://cart?utm_source=push&utm_campaign=cart_2h`

```yaml
en:
  title: "Your cart is waiting! 🛒"
  body: "{{item_count}} items • Complete your order now."
  image_url: "https://cdn.shopnow.com/carts/{{user_id}}/thumb.jpg"

es:
  title: "¡Tu carrito te espera! 🛒"
  body: "{{item_count}} artículos • Completa tu pedido ahora."
  image_url: "https://cdn.shopnow.com/carts/{{user_id}}/thumb.jpg"

pt-BR:
  title: "Seu carrinho está esperando! 🛒"
  body: "{{item_count}} itens • Finalize seu pedido agora."
  image_url: "https://cdn.shopnow.com/carts/{{user_id}}/thumb.jpg"
```

**Target:** Users with cart value > $10 who have not opted out of marketing  
**A/B Test:** Variant B includes 10% discount code

---

### 6. Abandoned Cart (24 hours with discount)

**Trigger:** User still has cart after 24 hours  
**Channel:** `cart`  
**Delay:** 24 hours  
**Frequency Cap:** 1 per week  
**Deep Link:** `shopnow://cart?discount=SAVE10&utm_source=push&utm_campaign=cart_24h`

```yaml
en:
  title: "10% off your cart! 🎁"
  body: "Use code SAVE10 at checkout. Expires in 24 hours."
  
es:
  title: "¡10% de descuento en tu carrito! 🎁"
  body: "Usa el código SAVE10 al pagar. Expira en 24 horas."

pt-BR:
  title: "10% de desconto no seu carrinho! 🎁"
  body: "Use o código SAVE10 no checkout. Expira em 24 horas."
```

**Target:** Users with cart value > $50 who did not convert after first cart reminder

---

### 7. Price Drop Alert

**Trigger:** Price drops on wishlisted item  
**Channel:** `price_drops`  
**Delay:** Immediate  
**Deep Link:** `shopnow://products/{{product_id}}?utm_source=push&utm_campaign=price_drop`

```yaml
en:
  title: "Price drop! {{product_name}}"
  body: "Now ${{new_price}} (was ${{old_price}}). Save {{discount_percent}}%!"
  image_url: "https://cdn.shopnow.com/products/{{product_id}}/thumb.jpg"

es:
  title: "¡Bajó el precio! {{product_name}}"
  body: "Ahora ${{new_price}} (antes ${{old_price}}). ¡Ahorra {{discount_percent}}%!"
  image_url: "https://cdn.shopnow.com/products/{{product_id}}/thumb.jpg"

pt-BR:
  title: "Preço caiu! {{product_name}}"
  body: "Agora ${{new_price}} (era ${{old_price}}). Economize {{discount_percent}}%!"
  image_url: "https://cdn.shopnow.com/products/{{product_id}}/thumb.jpg"
```

**Target:** Users who wishlisted the product  
**Frequency Cap:** 3 per day (max 3 price drop alerts per day across all products)

---

### 8. Flash Sale

**Trigger:** Admin triggers flash sale campaign  
**Channel:** `promotions`  
**Delay:** Immediate  
**Frequency Cap:** 2 per week  
**Deep Link:** `shopnow://sale/flash?utm_source=push&utm_campaign=flash_sale`

```yaml
en:
  title: "⚡ Flash Sale! 50% off sitewide"
  body: "Next 3 hours only. Shop now before it's gone!"

es:
  title: "⚡ ¡Oferta Relámpago! 50% en todo"
  body: "Solo las próximas 3 horas. ¡Compra ya antes de que termine!"

pt-BR:
  title: "⚡ Oferta Relâmpago! 50% em tudo"
  body: "Apenas nas próximas 3 horas. Compre agora antes que acabe!"
```

**Target:** Segmented users (purchased in last 30 days OR high engagement score)  
**Rate Limiting:** Send to first 10k users immediately, then spread remaining sends over 10 minutes

---

### 9. New Arrival (Personalized)

**Trigger:** New products added in user's favorite categories  
**Channel:** `promotions`  
**Delay:** Weekly digest (Thursdays at 10 AM local time)  
**Deep Link:** `shopnow://products/new?category={{category_id}}`

```yaml
en:
  title: "New in {{category_name}}! 🆕"
  body: "{{product_count}} new items just added. Check them out!"

es:
  title: "¡Novedades en {{category_name}}! 🆕"
  body: "{{product_count}} artículos nuevos agregados. ¡Échales un vistazo!"

pt-BR:
  title: "Novidades em {{category_name}}! 🆕"
  body: "{{product_count}} novos itens adicionados. Confira!"
```

**Target:** Users who browsed or purchased from category in last 30 days

---

### 10. Review Request

**Trigger:** 3 days after order delivered  
**Channel:** `reviews`  
**Delay:** 3 days  
**Deep Link:** `shopnow://orders/{{order_id}}/review`

```yaml
en:
  title: "How was your order? ⭐"
  body: "Share your experience with {{product_name}}."

es:
  title: "¿Qué tal tu pedido? ⭐"
  body: "Comparte tu experiencia con {{product_name}}."

pt-BR:
  title: "Como foi seu pedido? ⭐"
  body: "Compartilhe sua experiência com {{product_name}}."
```

**Target:** Users who received order (only if review channel is enabled)  
**Frequency Cap:** 1 per week (don't spam users with multiple review requests)

---

## Frequency Caps

| Channel | Cap | Period | Notes |
|---|---|---|---|
| Orders | 10 | per hour | Transactional, no daily cap |
| Price Drops | 3 | per day | Per user |
| Promotions | 2 | per day | Per user |
| Cart | 2 | per day | Max 1 per cart session |
| Reviews | 1 | per week | Per user |

**Global Cap:** Max 5 notifications per day per user (excluding orders)

**Quiet Hours:** 10 PM - 8 AM user's local time (exclude orders, allow price drops)

---

## Permission Strategy

### iOS Permission Flow

1. User browses products (no prompt)
2. User adds first item to cart → Show pre-permission dialog
3. User confirms → Request system permission

**Pre-Permission Dialog:**
```
Stay Updated on Your Orders

Get notified about:
✅ Order confirmations & delivery updates
💰 Price drops on items you love
🎁 Exclusive deals & flash sales

[Enable Notifications] [Maybe Later]
```

**If "Maybe Later":** Do not ask again for 7 days. Add reminder in app settings.

### Android (Auto-granted)

Notifications are enabled by default. Add in-app settings to manage channels.

---

## Deep Linking Configuration

### URL Schemes

- `shopnow://` — Custom URL scheme
- `https://shopnow.com/app/` — Universal Links (iOS) / App Links (Android)

### URL Structure

| Route | Deep Link | Fallback Web URL |
|---|---|---|
| Order Details | `shopnow://orders/12345` | `https://shopnow.com/app/orders/12345` |
| Product Page | `shopnow://products/67890` | `https://shopnow.com/app/products/67890` |
| Cart | `shopnow://cart` | `https://shopnow.com/app/cart` |
| Flash Sale | `shopnow://sale/flash` | `https://shopnow.com/app/sale/flash` |
| Tracking | `shopnow://orders/12345/tracking` | `https://shopnow.com/app/orders/12345/tracking` |

**UTM Parameters:** Always append `?utm_source=push&utm_campaign={{campaign_name}}`

---

## Implementation Plan

### Phase 1: Week 1-2 (Transactional Only)
- [ ] Set up FCM (iOS + Android)
- [ ] Implement token registration and refresh
- [ ] Create notification channels (Android) and categories (iOS)
- [ ] Implement deep linking
- [ ] Deploy: Order confirmed, Order shipped, Order delivered

**Success Metric:** 95%+ delivery rate, 20%+ open rate

### Phase 2: Week 3-4 (Add Cart Reminders)
- [ ] Implement abandoned cart tracking (2h, 24h)
- [ ] Implement frequency capping
- [ ] Deploy: Abandoned cart notifications

**Success Metric:** 5%+ cart recovery rate

### Phase 3: Week 5-6 (Add Price Alerts)
- [ ] Implement wishlist price tracking
- [ ] Deploy: Price drop alerts

**Success Metric:** 30%+ open rate on price drops

### Phase 4: Week 7-8 (Full Rollout)
- [ ] Deploy: Flash sale, new arrivals, review requests
- [ ] Implement in-app notification center
- [ ] Launch first A/B test (abandoned cart with/without discount)

**Success Metric:** Overall engagement increase of 10%+

---

## A/B Testing Roadmap

### Test 1: Abandoned Cart Discount (Week 5-6)
- **Variants:** A: No discount, B: 10% off code
- **Metric:** Cart conversion rate
- **Duration:** 2 weeks
- **Expected Result:** Variant B converts 2-3x higher

### Test 2: Flash Sale Emoji (Week 7)
- **Variants:** A: With emoji (⚡), B: Without emoji
- **Metric:** Open rate
- **Duration:** 1 week
- **Expected Result:** Variant A has 5-10% higher open rate

### Test 3: Order Shipped Timing (Week 9-10)
- **Variants:** A: Immediate, B: 2 hours after shipment
- **Metric:** Tracking link click rate
- **Duration:** 2 weeks
- **Expected Result:** No significant difference (keep immediate)

### Test 4: Review Request Copy (Week 11-12)
- **Variants:** A: "How was your order?", B: "Help others decide"
- **Metric:** Review submission rate
- **Duration:** 2 weeks
- **Expected Result:** Variant B appeals to altruism, higher submission rate

---

## Analytics Dashboard

### Daily Metrics (by channel)
- Notifications sent
- Delivery rate
- Open rate
- Conversion rate

### Funnel Visualization
```
100% Sent
 ↓
95% Delivered
 ↓
22% Opened
 ↓
8% Converted (completed target action)
```

### Key Events to Track
- `NOTIFICATION_SENT` (server-side)
- `NOTIFICATION_DELIVERED` (client-side)
- `NOTIFICATION_OPENED` (client-side)
- `NOTIFICATION_DISMISSED` (client-side)
- `CART_RECOVERED` (user completes checkout after cart notification)
- `PRODUCT_PURCHASED` (user purchases after price drop notification)
- `REVIEW_SUBMITTED` (user submits review after review notification)

---

## Notification Settings UI

Users can manage notification preferences in-app:

```
Notification Settings

Order Updates                    [Always On]
Price Alerts                     [Toggle]
Deals & Offers                   [Toggle]
Shopping Cart Reminders          [Toggle]
Review Requests                  [Toggle]

Quiet Hours                      [10 PM - 8 AM]

[Save Preferences]
```

**Note:** "Order Updates" cannot be disabled (required for transactional notifications).

---

## Expected Results (After 3 Months)

| Metric | Target | Actual (TBD) |
|---|---|---|
| Push notification opt-in rate | 40% | - |
| Average open rate (all notifications) | 20% | - |
| Cart recovery rate (from abandoned cart notifications) | 5% | - |
| Price drop notification open rate | 30% | - |
| Flash sale conversion rate | 10% | - |
| Review submission rate (from review notifications) | 15% | - |

---

## Maintenance Plan

### Weekly
- Review notification metrics dashboard
- Identify lowest-performing notification types
- Check for delivery failures and stale tokens

### Monthly
- Run new A/B test
- Review frequency caps and adjust if needed
- Analyze quiet hours effectiveness

### Quarterly
- User survey: "How do you feel about our notifications?"
- Review and update notification copy (refresh seasonal language)
- Evaluate new notification types based on product roadmap

---

This example demonstrates a complete, scalable notification strategy for an e-commerce app. Adapt the channels, notification types, and frequency caps to your specific app and user behavior.
