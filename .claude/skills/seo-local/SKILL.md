---
name: seo-local
description: |
  Local SEO optimization skill. Covers Google Business Profile optimization, local keyword
  research, review response templates, citation building, and hreflang implementation for
  multilingual sites. Market-agnostic with configurable locale and target market. Templates
  support multi-language output (default: en, pt-BR). Use when optimizing local search
  presence, managing Google Business Profile, responding to reviews, or implementing
  multilingual SEO.
---

## Purpose

SEO Local provides procedures for optimizing local search visibility across any market. It centers on Google Business Profile as the primary local search asset, with supporting procedures for citations, reviews, keywords, and multilingual implementation.

## When to Use

- Optimizing a Google Business Profile listing
- Researching local keywords for a service area
- Responding to customer reviews (positive and negative)
- Building local citations across directories
- Implementing hreflang for multilingual sites
- Auditing local SEO performance

## Prerequisites

- Google Business Profile access
- Target market and locale defined
- Website with local landing pages (if applicable)

## Procedures

### 1. Google Business Profile Optimization

Complete every field — incomplete profiles let Google fill gaps with AI-generated content you don't control.

**Must-have fields:**
- [ ] Business name (exact legal name, no keyword stuffing)
- [ ] Primary + secondary categories (be specific)
- [ ] Address and service area
- [ ] Phone number (local number preferred)
- [ ] Website URL
- [ ] Business hours (including holidays)
- [ ] Business description (750 chars, keyword-rich)
- [ ] Services/menu with descriptions
- [ ] Geotagged photos (minimum 10, updated quarterly)

### 2. NAP Consistency Audit

Name, Address, Phone must be identical across all listings:
- Google Business Profile
- Apple Maps / Yelp / industry directories
- Website footer and contact page
- Social media profiles

80% of consumers don't trust businesses with inconsistent contact details.

### 3. Local Keyword Research

```
Pattern: [service] + [location]
Examples:
  "dentista em São Paulo" (pt-BR)
  "dentist in São Paulo" (en)
  "dentista perto de mim" (pt-BR near-me)
```

Target conversational long-tail keywords with geographic modifiers.

### 4. Review Management

**Respond to ALL reviews within 24-48 hours.**

```yaml
# Positive Review Response
locale: en
template: "Thank you {{name}} for your kind words! We're glad [specific mention]. We look forward to seeing you again."

locale: pt-BR
template: "Obrigado(a) {{name}} pelas palavras gentis! Ficamos felizes que [menção específica]. Esperamos vê-lo(a) novamente."

# Negative Review Response
locale: en
template: "{{name}}, we're sorry about your experience. We take this seriously and would like to make it right. Please contact us at [phone/email] so we can resolve this."

locale: pt-BR
template: "{{name}}, lamentamos pela sua experiência. Levamos isso a sério e gostaríamos de resolver. Por favor, entre em contato pelo [telefone/email] para que possamos ajudar."
```

### 5. Hreflang Implementation

```html
<link rel="alternate" hreflang="en" href="https://example.com/en/" />
<link rel="alternate" hreflang="pt-BR" href="https://example.com/pt-br/" />
<link rel="alternate" hreflang="x-default" href="https://example.com/" />
```

Rules: Tags must be bidirectional. Use correct ISO codes (`en-GB` not `en-UK`). One language per page.

## Templates

- `templates/gbp-optimization-checklist.md` — GBP audit checklist
- `templates/review-response.md` — Review response templates (en + pt-BR)
- `templates/local-keyword-research.md` — Keyword research template

## Examples

- `examples/local-seo-audit.md` — Complete local SEO audit for a service business

## Chaining

| Chain With | Purpose |
|---|---|
| `conversion-copywriting` | Optimize GBP description and posts |
| `social-media-content` | Coordinate local content across channels |
| `deep-research` | Research local competitors |
| `domain-intelligence` | Check target market and locale config |

## Troubleshooting

| Problem | Solution |
|---|---|
| GBP listing suspended | Check for policy violations; verify business legitimacy |
| Low review volume | Implement systematic review request after positive interactions |
| Hreflang not working | Verify bidirectional tags; check for non-reciprocal links |
| NAP inconsistencies | Audit all directories; use a citation management tool |
