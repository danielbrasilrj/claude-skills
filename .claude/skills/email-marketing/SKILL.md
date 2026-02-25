---
name: email-marketing
description: i18n-ready email sequences — welcome, reminders, reactivation, seasonal. Segmentation, A/B subjects, send optimization (en, pt-BR).
---

## Purpose

Email Marketing provides templates and procedures for creating high-converting email sequences with built-in internationalization. It covers the full email lifecycle from segmentation through content creation, A/B testing, and performance optimization.

## When to Use

- Creating a welcome email sequence for new users
- Building reactivation campaigns for inactive users
- Planning seasonal or promotional email campaigns
- Optimizing email subject lines and send times
- Setting up email automation workflows

## Prerequisites

- Email service provider (Klaviyo, HubSpot, MailerLite, or equivalent)
- User segments defined (new, active, inactive, etc.)
- Target locales configured (default: en, pt-BR)

## Procedures

### 1. Segment Your Audience

See [segmentation.md](segmentation.md) for behavioral, demographic, lifecycle, and RFM segmentation strategies plus personalization patterns.

| Segment     | Criteria                     | Content Strategy               |
| ----------- | ---------------------------- | ------------------------------ |
| New users   | Signed up in last 7 days     | Welcome series, onboarding     |
| Active      | Used app in last 30 days     | Feature tips, upgrades         |
| At-risk     | No activity in 14-30 days    | Re-engagement, value reminders |
| Inactive    | No activity in 30+ days      | Reactivation, incentives       |
| Power users | Daily usage, high engagement | Loyalty, referral programs     |

### 2. Build Welcome Series

See [email-sequences.md](email-sequences.md) for detailed welcome, nurture, re-engagement, reactivation, and transactional sequence templates.

**Email 1 (Day 0):** Welcome + brand story
**Email 2 (Day 3):** Educational content / quick wins
**Email 3 (Day 7):** Feature highlight + social proof
**Email 4 (Day 14):** Conversion nudge (upgrade/complete profile)

### 3. Write Email Content (i18n)

Every email uses locale-aware structure:

```yaml
# Welcome Email
locale: en
subject: "Welcome to {{app_name}}, {{first_name}}!"
preview: "Here's how to get started in 2 minutes"
cta: "Get Started"
greeting: "Hi {{first_name}},"

locale: pt-BR
subject: "Bem-vindo(a) ao {{app_name}}, {{first_name}}!"
preview: "Veja como começar em 2 minutos"
cta: "Começar Agora"
greeting: "Oi {{first_name}},"
```

**Locale formatting rules:**

- Dates: `March 15, 2025` (en) → `15 de março de 2025` (pt-BR)
- Time: `3:45 PM` (en) → `15:45` (pt-BR)
- Currency: `$49.99` (en) → `R$ 49,99` (pt-BR)
- Numbers: `1,234.56` (en) → `1.234,56` (pt-BR)

### 4. A/B Test Subject Lines

See [subject-line-optimization.md](subject-line-optimization.md) for formulas, emoji usage, and A/B testing methodology.

Test one variable at a time:

- Personalization (with name vs without)
- Length (short < 40 chars vs descriptive)
- Urgency (deadline vs no deadline)
- Emoji (with vs without)

Minimum sample: 1,000 per variant. Run for 2-4 hours before selecting winner.

### 5. Optimize Send Times

- Test send times by segment and locale
- Common patterns: B2B → Tuesday-Thursday 10am. B2C → evenings and weekends
- Account for timezone differences (Brazil is UTC-3)

## Templates

- `templates/welcome-series.md` — 4-email welcome sequence (en + pt-BR)
- `templates/reactivation-campaign.md` — Win-back campaign template
- `templates/seasonal-promotion.md` — Holiday/seasonal email template

## Examples

- `examples/welcome-series-example.md` — Complete welcome series with both locales

## Chaining

| Chain With               | Purpose                             |
| ------------------------ | ----------------------------------- |
| `conversion-copywriting` | Apply AIDA/PAS to email copy        |
| `ab-test-generator`      | Design email experiments            |
| `social-media-content`   | Coordinate email + social campaigns |
| `data-analysis`          | Analyze email performance metrics   |

## References

- [email-sequences.md](email-sequences.md) -- Welcome, nurture, re-engagement, reactivation, and transactional sequence templates
- [subject-line-optimization.md](subject-line-optimization.md) -- Subject line formulas, best practices, emoji usage, A/B testing
- [deliverability.md](deliverability.md) -- SPF/DKIM/DMARC setup, list hygiene, spam triggers, sender reputation, IP warming, metrics benchmarks
- [compliance.md](compliance.md) -- CAN-SPAM and LGPD requirements, double opt-in, unsubscribe best practices
- [segmentation.md](segmentation.md) -- Behavioral, demographic, lifecycle, RFM segmentation, personalization, preference center

## Troubleshooting

| Problem                | Solution                                                       |
| ---------------------- | -------------------------------------------------------------- |
| Low open rates         | Test subject lines; check send time; verify deliverability     |
| High unsubscribe rate  | Reduce frequency; improve segmentation; check relevance        |
| pt-BR formatting wrong | Use Intl APIs for dates/currency; test with real pt-BR content |
| Emails going to spam   | Check SPF/DKIM/DMARC; avoid spam trigger words                 |
