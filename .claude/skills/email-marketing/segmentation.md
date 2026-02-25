# Segmentation Strategies

## Behavioral Segmentation

### Activity-Based

| Segment     | Criteria                     | Content Strategy               |
| ----------- | ---------------------------- | ------------------------------ |
| New users   | Signed up in last 7 days     | Welcome series, onboarding     |
| Active      | Used app in last 30 days     | Feature tips, upgrades         |
| At-risk     | No activity in 14-30 days    | Re-engagement, value reminders |
| Inactive    | No activity in 30+ days      | Reactivation, incentives       |
| Power users | Daily usage, high engagement | Loyalty, referral programs     |

### Engagement-Based

| Segment      | Criteria                   | Content Strategy                       |
| ------------ | -------------------------- | -------------------------------------- |
| High openers | Opens 50%+ of emails       | Test new features, ask for feedback    |
| Clickers     | Clicks in 20%+ of emails   | Product-focused, deep dives            |
| Non-openers  | Opens <10% in last 90 days | Change subject lines, reduce frequency |
| Unengaged    | Never opened in 6 months   | Re-engagement or remove                |

---

## Demographic Segmentation

### Locale-Based

| Segment                      | Content Adaptation                                    |
| ---------------------------- | ----------------------------------------------------- |
| English (en)                 | Default content                                       |
| Brazilian Portuguese (pt-BR) | Transcreated copy, local formatting, BRL currency     |
| Spanish (es)                 | Transcreated copy, cultural nuances (Mexico vs Spain) |

**Send time optimization by locale:**

- **USA (EST):** Tuesday-Thursday 10am-2pm
- **Brazil (BRT):** Tuesday-Thursday 9am-12pm (3 hours ahead of EST)
- **Europe (CET):** Wednesday 8am-11am

---

### Industry-Based

| Segment               | Content Focus                                  |
| --------------------- | ---------------------------------------------- |
| Healthcare            | Compliance, HIPAA, patient outcomes            |
| SaaS                  | ROI, integrations, product updates             |
| E-commerce            | Sales, abandoned cart, product recommendations |
| Professional services | Case studies, thought leadership               |

---

## Lifecycle Segmentation

| Stage         | Definition                  | Content Goals                 |
| ------------- | --------------------------- | ----------------------------- |
| Trial         | Free trial active           | Feature education, activation |
| Paying        | Paid subscription           | Retention, upsell, referrals  |
| Churned       | Canceled subscription       | Win-back, feedback            |
| Expired trial | Trial ended, didn't convert | Conversion nudge, incentive   |

---

## RFM Segmentation (Recency, Frequency, Monetary)

**For e-commerce or repeat-purchase businesses:**

| Segment             | Criteria                              | Strategy                           |
| ------------------- | ------------------------------------- | ---------------------------------- |
| Champions           | Recent purchase, frequent, high spend | VIP perks, early access, referrals |
| Loyal               | Frequent purchases, moderate spend    | Loyalty program, exclusive content |
| Potential loyalists | Recent purchase, low frequency        | Encourage repeat purchase          |
| At-risk             | Haven't purchased in 60+ days         | Win-back offer, incentive          |
| Lost                | No purchase in 120+ days              | Survey, deep discount, or remove   |

---

## Personalization Strategies

### Basic Personalization

- `{{first_name}}` in subject or greeting
- `{{company_name}}` for B2B
- `{{last_purchase_date}}` for e-commerce

### Advanced Personalization

- **Content blocks based on behavior** -- Show different features based on usage
- **Send time optimization** -- AI-determined best time per user
- **Dynamic product recommendations** -- Based on browsing/purchase history
- **Geo-targeted content** -- Weather, local events, regional offers

**Example:**

```
Subject: {{first_name}}, your {{product_category}} order ships tomorrow

Hi {{first_name}},

Great news! Your order (#{{order_number}}) ships tomorrow and will arrive by {{estimated_delivery_date}}.

[Dynamic: If order includes shoes]
Pro tip: Pair your new {{shoe_name}} with our best-selling {{recommended_product}}.

[Dynamic: If first-time buyer]
As a first-time customer, here's 15% off your next order: {{unique_coupon_code}}
```

---

## Preference Center

**Allow users to control:**

- Email frequency (daily, weekly, monthly)
- Content types (product updates, promotions, tips)
- Preferred language (en, pt-BR, etc.)
- Preferred format (text, HTML)

**Example preference center:**

```
Email Preferences

Frequency:
[ ] Daily digest
[x] Weekly roundup (default)
[ ] Monthly only

Content types:
[x] Product updates
[x] Educational content
[ ] Promotional offers

Language:
[x] English
[ ] Portugues (Brasil)

[Save Preferences]
```
