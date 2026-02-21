# Social Media Content — Reference

## Platform Specifications

### Instagram

| Format | Aspect Ratio | Max Duration | Character Limits | Best Practices |
|--------|-------------|-------------|-----------------|----------------|
| Feed Post (image) | 1:1, 4:5 | — | Caption: 2200 chars, 30 hashtags | 4:5 gets most screen real estate |
| Carousel | 1:1, 4:5 | — | Up to 20 slides | 5-7 slides optimal, hook on slide 1 |
| Reel | 9:16 | 90 sec | Caption: 2200 chars | 15-30 sec for reach, 60-90 for depth |
| Story | 9:16 | 60 sec | — | Interactive stickers boost engagement 15-25% |

### TikTok

| Format | Aspect Ratio | Duration | Notes |
|--------|-------------|----------|-------|
| Standard video | 9:16 | 15s-10min | 15-30s highest completion rate |
| Photo carousel | 9:16 | — | Up to 35 images |
| LIVE | 9:16 | 60 min max | Requires 1000+ followers |

**Hook window**: First 1-3 seconds determine watch-through rate. Open with a pattern interrupt, bold claim, or direct question.

### WhatsApp Business

| Template Category | Use Case | Approval | Notes |
|-------------------|----------|----------|-------|
| Utility | Order updates, receipts, appointment reminders | Faster approval | No promotional language |
| Authentication | OTP, verification codes | Fast approval | Must include security disclaimer |
| Marketing | Promotions, offers, newsletters | Stricter review | Requires opt-in, each language separate |

**Variable format**: `{{1}}`, `{{2}}`, etc. No dynamic URLs in body (only buttons).

**Language handling**: Submit separate templates for each language. Template names must be unique per language. Meta reviews each independently.

**Opt-in requirements**:
- Must collect explicit opt-in per message category
- Must provide clear opt-out mechanism in every marketing message
- Must honor opt-out within 24 hours

### Google Business Profile

| Post Type | Character Limit | Image | CTA Options |
|-----------|----------------|-------|-------------|
| Update | 1500 chars | 1 photo/video | Book, Order, Learn More, Sign Up, Call |
| Offer | 1500 chars | 1 photo | Offer code, link, terms |
| Event | 1500 chars | 1 photo | Start/end date required |

**Posting frequency**: 1-3 times per week. Posts expire after 6 months (offers expire on end date).

**Local SEO impact**: Regular GBP posts signal activity to Google, contributing to local pack ranking.

## Content Pillar Framework

### Pillar Definitions

| Pillar | Goal | Content Ratio | Example Topics |
|--------|------|---------------|----------------|
| Educational | Build authority | 30-40% | Tips, how-tos, industry insights |
| Behind-the-scenes | Build trust | 15-20% | Team, process, workspace |
| Promotional | Drive sales | 15-20% | Offers, launches, features |
| Community | Build loyalty | 15-20% | UGC, polls, Q&A, shoutouts |
| Testimonial | Social proof | 10-15% | Reviews, case studies, before/after |

### Pillar-to-Platform Mapping

Each pillar performs differently across platforms:

| Pillar | Instagram | TikTok | WhatsApp | GBP |
|--------|-----------|--------|----------|-----|
| Educational | Carousel, Reel | Script | — | Update |
| BTS | Story, Reel | Script | — | — |
| Promotional | Feed Post, Reel | Script | Broadcast | Offer |
| Community | Story (polls) | Duet/Stitch | — | — |
| Testimonial | Carousel, Story | Script | — | Update |

## Hashtag Strategy

### Instagram Hashtag Tiers

| Tier | Post Volume | Strategy |
|------|------------|----------|
| Mega (1M+) | Very high | Use 1-2 max for discoverability |
| Mid (100K-1M) | High | Use 3-5 for balanced reach |
| Niche (10K-100K) | Moderate | Use 5-10 for targeted audience |
| Branded (<10K) | Low | Use 1-2 for brand tracking |

**Total**: 8-15 hashtags per post (not 30). Place in caption, not first comment.

### TikTok Hashtag Strategy

- 3-5 hashtags maximum
- Mix trending + niche
- Use platform-suggested hashtags from search
- Avoid banned/shadow-banned hashtags

## Privacy Compliance Deep Reference

### GDPR Summary (EU/EEA)

| Requirement | Implementation |
|-------------|---------------|
| Lawful basis | Document for each processing activity (consent, legitimate interest, contract) |
| Consent | Must be freely given, specific, informed, unambiguous; pre-ticked boxes invalid |
| Right to erasure | Must delete within 30 days of request |
| Data portability | Provide data in machine-readable format on request |
| DPO | Required for large-scale processing of personal data |
| Breach notification | 72 hours to supervisory authority |
| Cross-border transfers | Adequacy decision, SCCs, or BCRs required |

### LGPD Summary (Brazil)

| Requirement | Implementation |
|-------------|---------------|
| Legal basis | 10 legal bases (similar to GDPR but includes credit protection) |
| Consent | Must be free, informed, unambiguous; written must be in highlighted clause |
| DSAR response | 15 days (shorter than GDPR's 30) |
| DPO (Encarregado) | Required for all controllers (no size exemption in original law) |
| ANPD | National Data Protection Authority — can impose fines up to 2% of revenue |
| International transfers | Adequacy, contractual clauses, or specific consent |

### Platform-Specific Privacy Rules

**Instagram/Meta Ads**:
- Custom Audiences require consent documentation
- Pixel tracking must be disclosed in privacy policy
- iOS 14.5+ App Tracking Transparency reduces targeting
- Use Conversions API as server-side complement

**TikTok**:
- TikTok Pixel similar rules to Meta Pixel
- Restricted data processing mode for CCPA compliance
- No targeting of users under 13

**WhatsApp Business**:
- End-to-end encryption does NOT apply to Business API (messages pass through BSP)
- Must disclose data sharing with Meta in privacy policy
- Template messages reviewed for compliance per language
- Opt-out must be processed within 24 hours

## AI Image Prompt Engineering

### Style Reference Guide

| Style | Best For | Prompt Keywords |
|-------|----------|-----------------|
| Editorial photography | Professional services, B2B | "editorial photo, natural lighting, professional setting" |
| Flat illustration | Tech, SaaS, education | "flat vector illustration, minimal, clean lines" |
| 3D render | Products, e-commerce | "3D render, product shot, studio lighting, white background" |
| Lifestyle photography | Fitness, food, travel | "lifestyle photo, candid, warm tones, shallow depth of field" |
| Hand-drawn | Creative, artisan, children | "hand-drawn illustration, watercolor, organic shapes" |

### Prompt Structure

```
[Subject] + [Action/Pose] + [Setting/Background] + [Style] + [Lighting] + [Color palette] + [Mood] + [Technical specs]
```

### Platform-Specific Image Specs

| Platform | Format | Resolution | File Size |
|----------|--------|-----------|-----------|
| Instagram Feed | JPG/PNG | 1080x1080 (1:1) or 1080x1350 (4:5) | <8MB |
| Instagram Story/Reel cover | JPG/PNG | 1080x1920 (9:16) | <8MB |
| TikTok cover | JPG/PNG | 1080x1920 (9:16) | <10MB |
| WhatsApp (media message) | JPG/PNG | 800x800 recommended | <5MB |
| GBP | JPG/PNG | 1200x900 (4:3) | <5MB |

## Locale-Specific Considerations

### English (en) — US/UK/AU

- Date format: Month Day, Year (US) / Day Month Year (UK/AU)
- Currency: $USD / GBP / AUD
- Tone: direct, concise, action-oriented CTAs
- Humor: sarcasm, wordplay common
- Hashtags: English dominates global discovery

### Portuguese — Brazil (pt-BR)

- Date format: DD/MM/AAAA
- Currency: R$ (BRL), thousands separator: `.`, decimal: `,`
- Tone: warmer, more personal, relationship-first
- Formality: tu (informal, regional) vs. voce (standard)
- WhatsApp: primary communication channel in Brazil (99% smartphone penetration)
- Instagram: second largest market globally
- Cultural dates: Carnaval, Festas Juninas, Black Friday (massive in Brazil), Dia das Maes (second Sunday of May)
- Hashtags: mix of Portuguese and English hashtags for reach

### Transcreation Examples

| English | Literal Translation | Transcreation (pt-BR) |
|---------|--------------------|-----------------------|
| "Get started today!" | "Comece hoje!" | "Bora comecar agora!" |
| "Limited time offer" | "Oferta por tempo limitado" | "Corre que e por tempo limitado!" |
| "Join our community" | "Junte-se a nossa comunidade" | "Faz parte da nossa comunidade!" |
| "Book a free consultation" | "Agende uma consulta gratuita" | "Agenda sua consultoria gratis!" |
