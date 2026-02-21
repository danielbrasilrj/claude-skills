# Google Business Profile Post Template

## Post Configuration

```yaml
post_type: ""    # update | offer | event
locale: ""       # en | pt-BR
business_name: ""
business_category: ""
publish_date: ""
```

---

## Update Post

Standard update to share news, tips, or announcements.

### Content

```
[en]
{{ update_body_en }}
```

```
[pt-BR]
{{ update_body_ptbr }}
```

**Character limit**: 1500 characters (aim for 150-300 for best engagement).

### Media

```yaml
media:
  type: "photo"  # photo | video
  file: ""
  alt_text_en: ""
  alt_text_ptbr: ""
  geotagged: true  # geotag photos for local SEO boost
```

### CTA Button

```yaml
cta:
  type: ""  # book | order | learn_more | sign_up | call | none
  url: ""   # required for book, order, learn_more, sign_up
```

---

## Offer Post

Promote a special deal, discount, or coupon.

### Content

```
[en]
{{ offer_title_en }}

{{ offer_description_en }}
```

```
[pt-BR]
{{ offer_title_ptbr }}

{{ offer_description_ptbr }}
```

### Offer Details

```yaml
offer:
  title_en: ""          # max 58 characters
  title_ptbr: ""
  start_date: ""        # YYYY-MM-DD
  end_date: ""          # YYYY-MM-DD
  coupon_code: ""       # optional
  redeem_url: ""        # optional
  terms_en: ""          # terms and conditions
  terms_ptbr: ""
```

### Media

```yaml
media:
  type: "photo"
  file: ""
  alt_text_en: ""
  alt_text_ptbr: ""
  geotagged: true
```

---

## Event Post

Promote an upcoming event at the business location or online.

### Content

```
[en]
{{ event_title_en }}

{{ event_description_en }}
```

```
[pt-BR]
{{ event_title_ptbr }}

{{ event_description_ptbr }}
```

### Event Details

```yaml
event:
  title_en: ""          # max 58 characters
  title_ptbr: ""
  start_date: ""        # YYYY-MM-DD
  start_time: ""        # HH:MM (24h format)
  end_date: ""          # YYYY-MM-DD
  end_time: ""          # HH:MM
  timezone: ""          # e.g., America/New_York, America/Sao_Paulo
```

### CTA Button

```yaml
cta:
  type: ""  # book | order | learn_more | sign_up | call
  url: ""
```

### Media

```yaml
media:
  type: "photo"
  file: ""
  alt_text_en: ""
  alt_text_ptbr: ""
  geotagged: true
```

---

## AI Image Prompt for GBP Posts

```yaml
image_prompt:
  platform: "google-business-profile"
  format: "post_image"
  style: ""   # editorial photography | lifestyle | product shot
  subject: ""
  setting: ""  # ideally at or near the business location
  mood: ""
  color_palette: []
  text_overlay_en: ""   # keep minimal — image should work without text
  text_overlay_ptbr: ""
  aspect_ratio: "4:3"   # GBP recommended
  resolution: "1200x900"
  geotag: true
  negative_prompts: ["watermark", "stock photo feel", "low quality"]
```

---

## GBP Post Best Practices

- **Posting frequency**: 1-3 posts per week signals active business to Google
- **Post lifespan**: update and event posts remain visible for 6 months; offers expire on end date
- **Keywords**: include local keywords naturally (city, neighborhood, service type)
- **Photos**: use original photos, geotagged at the business location
- **CTA**: always include a call-to-action button for conversion tracking
- **Response**: monitor and respond to post comments within 24 hours
- **Consistency**: post in all languages your business serves; each post is one language

### Locale-Specific Formatting

| Element | English (en) | Portuguese (pt-BR) |
|---------|-------------|-------------------|
| Date | January 15, 2026 | 15 de janeiro de 2026 |
| Time | 2:00 PM | 14:00 |
| Currency | $49.99 | R$ 49,99 |
| Phone | (555) 123-4567 | (11) 9 1234-5678 |
| Address | 123 Main St, Suite 100 | Rua Principal, 123 - Sala 100 |

---

## Content Calendar Integration

```yaml
gbp_calendar:
  week_of: ""
  posts:
    - day: "Monday"
      type: "update"
      pillar: "educational"
      locale: "en"
      topic: ""
    - day: "Monday"
      type: "update"
      pillar: "educational"
      locale: "pt-BR"
      topic: ""
    - day: "Wednesday"
      type: "offer"
      pillar: "promotional"
      locale: "en"
      topic: ""
    - day: "Wednesday"
      type: "offer"
      pillar: "promotional"
      locale: "pt-BR"
      topic: ""
    - day: "Friday"
      type: "event"
      pillar: "community"
      locale: "en"
      topic: ""
    - day: "Friday"
      type: "event"
      pillar: "community"
      locale: "pt-BR"
      topic: ""
```
