---
name: social-media-content
description: >
  Creates multi-platform social media content for Instagram, TikTok, WhatsApp Business,
  and Google Business Profile. Use when building content calendars, drafting posts,
  writing video scripts, generating AI image prompts, or ensuring GDPR/LGPD privacy
  compliance for social campaigns. i18n-ready with locale-aware templates.
---

## Purpose

Generate publication-ready social media content across Instagram, TikTok, WhatsApp Business, and Google Business Profile. All output is i18n-aware (default: en + pt-BR), privacy-compliant (GDPR + LGPD), and structured for content pillars and editorial calendars.

## When to Use

- Planning a content calendar for one or more social platforms
- Drafting Instagram carousel, Reels, or Stories content
- Writing TikTok video scripts with hooks and CTAs
- Creating WhatsApp Business message templates (Meta-approved format)
- Composing Google Business Profile posts (updates, offers, events)
- Generating AI image prompts for social media visuals
- Auditing content for GDPR/LGPD privacy compliance
- Localizing existing content from one locale to another

## Prerequisites

- **Brand brief**: business name, industry, tone of voice, target audience
- **Locale config**: primary and secondary locales (e.g., `en`, `pt-BR`)
- **Platform accounts**: which platforms the business uses
- **Content pillars**: 3-5 recurring themes (e.g., educational, behind-the-scenes, promotional)
- **Privacy context**: whether the business collects user data, runs ads, or uses pixel tracking

## Procedures

### 1. Gather Brand Context

Collect the following before generating any content:

```yaml
brand:
  name: ""
  industry: ""
  tone: ""  # e.g., professional, casual, playful, authoritative
  audience:
    primary: ""
    age_range: ""
    interests: []
  locales:
    primary: "en"
    secondary: "pt-BR"
  platforms:
    - instagram
    - tiktok
    - whatsapp-business
    - google-business-profile
  content_pillars:
    - educational
    - behind-the-scenes
    - promotional
    - community
    - testimonial
```

### 2. Content Calendar Planning

For each locale and platform:

1. Map content pillars to a weekly posting schedule
2. Assign platform-specific formats (carousel, reel, story, post, script)
3. Set publishing times based on locale timezone
4. Tag each piece with its pillar and campaign

Weekly cadence recommendation:

| Day       | Instagram        | TikTok          | WhatsApp Business | GBP           |
|-----------|------------------|-----------------|-------------------|---------------|
| Monday    | Carousel (edu)   | Script (edu)    | —                 | Update        |
| Tuesday   | Story (BTS)      | —               | —                 | —             |
| Wednesday | Reel (promo)     | Script (promo)  | Broadcast (promo) | Offer         |
| Thursday  | Carousel (social)| Script (BTS)    | —                 | —             |
| Friday    | Reel (community) | Script (community)| —              | Event         |
| Saturday  | Story (testimonial)| —             | —                 | —             |

### 3. Generate Platform Content

Use the templates in `templates/` for each platform:

- `templates/instagram-post.md` — carousels, reels, stories
- `templates/tiktok-script.md` — short-form video scripts
- `templates/whatsapp-business.md` — Meta-approved message templates
- `templates/google-business-post.md` — updates, offers, events

### 4. AI Image Prompt Generation

For each visual content piece, generate a structured image prompt:

```yaml
image_prompt:
  platform: "instagram"
  format: "carousel_slide"  # carousel_slide | reel_cover | story | post
  style: "flat illustration"  # photography | flat illustration | 3d render | watercolor
  subject: "person using laptop in a cozy cafe"
  mood: "warm, inviting, productive"
  color_palette: ["#F5A623", "#4A90D9", "#FFFFFF"]
  text_overlay: "5 Tips for Remote Work"
  aspect_ratio: "1:1"  # 1:1 | 4:5 | 9:16 | 16:9
  negative_prompts: ["text", "watermark", "low quality"]
  locale_notes: "If pt-BR, adapt text overlay to Portuguese"
```

### 5. Privacy Compliance Check

Before publishing, run every piece through the checklist at `templates/privacy-compliance-checklist.md`. Key rules:

- **GDPR (EU)**: explicit opt-in for data collection, right to erasure, DPO contact visible
- **LGPD (Brazil)**: explicit consent, 15-day DSAR response window, legal basis documented
- **WhatsApp Business**: message templates must be pre-approved by Meta per language
- **Tracking pixels**: disclose in privacy policy, honor opt-out
- **User-generated content**: written permission before reposting
- **Minor data**: never target or collect data from users under 13 (COPPA) / 18 (LGPD stricter)

### 6. Localization Workflow

For each content piece, follow this progression:

1. **Translation**: literal language conversion
2. **Localization**: adapt dates, currency, measurements, cultural references
3. **Transcreation**: rewrite for cultural resonance (idioms, humor, local trends)

Always produce content in all configured locales simultaneously, not as an afterthought.

## Templates

All templates are in the `templates/` directory:

| Template | Purpose |
|----------|---------|
| `instagram-post.md` | Instagram carousel, reel, story formats |
| `tiktok-script.md` | TikTok video script with hook-body-CTA |
| `whatsapp-business.md` | WhatsApp Business approved message templates |
| `google-business-post.md` | GBP update, offer, and event posts |
| `privacy-compliance-checklist.md` | GDPR/LGPD compliance audit for content |

## Examples

See `examples/service-business-campaign.md` for a complete multi-platform campaign example for a service business with en + pt-BR localization.

## Chaining

- **Before**: Use `prd-driven-development` to define campaign goals and KPIs
- **With**: Use `ab-test-generator` to create A/B variants of posts
- **With**: Use `conversion-copywriting` for high-converting ad copy
- **After**: Use `deep-research` to analyze competitor content strategies
- **After**: Use `data-analysis` to evaluate campaign performance metrics

## Troubleshooting

| Problem | Solution |
|---------|----------|
| WhatsApp template rejected by Meta | Check template follows exact variable format `{{1}}`, avoid promotional language in utility templates, submit each language variant separately |
| Content feels unnatural in pt-BR | Move from translation to transcreation — adapt idioms, use local slang appropriate to tone |
| Low engagement on Instagram carousels | Lead with a hook slide (question or bold stat), keep to 5-7 slides, end with clear CTA |
| TikTok script too long | Target 15-30 seconds for maximum retention; cut to one core idea per video |
| GBP post not showing | Verify business is verified, post is under 1500 chars, no banned keywords |
| LGPD compliance unclear | Document legal basis for each data processing activity, ensure 15-day DSAR response process exists |
