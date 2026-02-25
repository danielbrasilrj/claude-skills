---
name: conversion-copywriting
description: Reviews and improves app store listings, landing pages, and in-app copy using AIDA/PAS frameworks. i18n-ready (en, pt-BR).
---

## Purpose

Conversion Copywriting applies proven persuasion frameworks (AIDA, PAS) to review and improve marketing copy across all customer touchpoints. It scores existing copy, provides actionable before/after improvements, and generates i18n-ready templates for app stores, landing pages, and notifications.

## When to Use

- Reviewing or writing App Store / Google Play listings
- Optimizing landing page copy for conversions
- Writing push notification copy
- Creating email marketing copy
- Reviewing in-app onboarding text
- Any marketing copy that needs to convert

## Prerequisites

- The copy to be reviewed (text, screenshot, or URL)
- Target audience description
- Primary conversion goal (download, signup, purchase, etc.)
- Target locales (default: en, pt-BR)

## Procedures

### 1. Assess Current Copy (Scoring Rubric)

Score each dimension 1-10:

| Dimension              | What to Evaluate                                           |
| ---------------------- | ---------------------------------------------------------- |
| **Headline Impact**    | Does it stop the scroll? Specific benefit? Curiosity gap?  |
| **CTA Clarity**        | Is the next action obvious? Single clear CTA? Action verb? |
| **Social Proof**       | Reviews, testimonials, user counts, trust badges?          |
| **Urgency/Scarcity**   | Time limits, limited availability, FOMO triggers?          |
| **Mobile Readability** | Short paragraphs, scannable, emoji use, bullet points?     |
| **Benefit Clarity**    | Features vs benefits? "So what?" test passed?              |
| **Emotional Hook**     | Does it connect to a pain point or aspiration?             |
| **Trust Signals**      | Professional tone, error-free, credible claims?            |

**Overall Score** = average of all dimensions.

### 2. Choose Framework

See [frameworks.md](frameworks.md) for full framework details including BAB and 4Ps.

**Use PAS (Problem → Agitate → Solution) when:**

- Short-form copy (ads, push notifications, social posts)
- Pain-point-driven products
- Audience is problem-aware

**Use AIDA (Attention → Interest → Desire → Action) when:**

- Long-form copy (landing pages, app store descriptions)
- Structured sales flow needed
- Audience needs education

### 3. Rewrite with Framework

Apply the chosen framework and produce before/after for each section. Every rewrite must:

- Lead with the strongest benefit
- Use active voice and second person ("you")
- Include specific numbers where possible
- Pass the "so what?" test for every sentence

### 4. Localize (i18n)

For detailed pt-BR cultural adaptation rules, see [pt-br-adaptation.md](pt-br-adaptation.md). For each piece of copy, provide versions in all target locales:

```yaml
locale: en
headline: "Book your appointment in 30 seconds"
cta: "Get Started Free"

locale: pt-BR
headline: "Agende sua consulta em 30 segundos"
cta: "Comece Grátis"
```

**Localization rules:**

- Transcreate, don't translate — adapt emotional triggers per culture
- pt-BR is typically 20-30% longer than English — design for expansion
- Adapt formality level (pt-BR: use "você" not "o senhor")
- Localize numbers, currency, dates per locale

## References

- [frameworks.md](frameworks.md) — PAS, AIDA, BAB, 4Ps frameworks with examples and best practices
- [cta-optimization.md](cta-optimization.md) — CTA anatomy, high-converting patterns, testing checklist
- [headline-formulas.md](headline-formulas.md) — 8 headline formulas + A/B test copy variant guide
- [pt-br-adaptation.md](pt-br-adaptation.md) — Brazilian Portuguese transcreation, cultural triggers, formatting
- [copy-review-checklist.md](copy-review-checklist.md) — Pre-publish checklist (clarity, conversion, localization, testing)

## Templates

- `templates/app-store-listing.md` — i18n App Store/Play Store template
- `templates/landing-page-review.md` — Landing page scoring template
- `templates/push-notification-copy.md` — i18n push notification copy

## Examples

- `examples/app-store-before-after.md` — Complete before/after optimization

## Chaining

| Chain With             | Purpose                                 |
| ---------------------- | --------------------------------------- |
| `ab-test-generator`    | Test copy variants with ICE scoring     |
| `social-media-content` | Extend copy to social channels          |
| `email-marketing`      | Apply frameworks to email sequences     |
| `seo-local`            | Optimize copy for local search keywords |
| `figma-handoff`        | Ensure copy fits design constraints     |

## Troubleshooting

| Problem                              | Solution                                                        |
| ------------------------------------ | --------------------------------------------------------------- |
| Copy scores well but doesn't convert | Test with real users; score may miss audience-specific issues   |
| pt-BR copy too long for UI           | Rephrase more concisely; Portuguese allows compact forms        |
| Client wants "creative" copy         | Ground creativity in framework; test against structured version |
| App store keyword stuffing           | Balance keywords with readability; front-load important terms   |
