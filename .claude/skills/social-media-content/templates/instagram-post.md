# Instagram Post Template

## Post Configuration

```yaml
post_type: ""  # carousel | reel | story | feed_image
pillar: ""     # educational | behind-the-scenes | promotional | community | testimonial
locale: ""     # en | pt-BR
campaign: ""   # campaign name or standalone
publish_date: ""
publish_time: ""  # in locale timezone
```

---

## Carousel Template

### Slide Structure (5-7 slides recommended)

**Slide 1 — Hook**

> [en] {{ hook_en }}
> [pt-BR] {{ hook_ptbr }}

Visual: {{ image_prompt_slide_1 }}

**Slide 2-N — Body**

> [en] {{ body_point_en }}
> [pt-BR] {{ body_point_ptbr }}

Visual: {{ image_prompt_slide_n }}

**Final Slide — CTA**

> [en] {{ cta_en }}
> [pt-BR] {{ cta_ptbr }}

Visual: {{ image_prompt_cta }}

### Caption

```
[en]
{{ hook_line_en }}

{{ body_caption_en }}

{{ cta_caption_en }}

{{ hashtags_en }}
```

```
[pt-BR]
{{ hook_line_ptbr }}

{{ body_caption_ptbr }}

{{ cta_caption_ptbr }}

{{ hashtags_ptbr }}
```

---

## Reel Template

### Script

```yaml
duration: ""  # 15s | 30s | 60s | 90s
aspect_ratio: "9:16"
audio: ""  # trending audio name or original
```

**Hook (0-3 seconds)**

> [en] {{ reel_hook_en }}
> [pt-BR] {{ reel_hook_ptbr }}

Visual direction: {{ visual_direction_hook }}

**Body (3-25 seconds)**

> [en] {{ reel_body_en }}
> [pt-BR] {{ reel_body_ptbr }}

Visual direction: {{ visual_direction_body }}

**CTA (final 3-5 seconds)**

> [en] {{ reel_cta_en }}
> [pt-BR] {{ reel_cta_ptbr }}

Visual direction: {{ visual_direction_cta }}

### Reel Caption

```
[en]
{{ reel_caption_en }}

{{ hashtags_en }}
```

```
[pt-BR]
{{ reel_caption_ptbr }}

{{ hashtags_ptbr }}
```

### Cover Image Prompt

```yaml
image_prompt:
  format: "reel_cover"
  style: ""
  subject: ""
  text_overlay_en: ""
  text_overlay_ptbr: ""
  aspect_ratio: "9:16"
```

---

## Story Template

### Story Sequence (1-5 frames)

**Frame {{ n }}**

```yaml
type: ""  # image | video | text | poll | quiz | question | countdown | link
duration: ""  # seconds or "auto"
```

> [en] {{ story_text_en }}
> [pt-BR] {{ story_text_ptbr }}

Interactive element:

```yaml
sticker_type: ""  # poll | quiz | question | emoji_slider | countdown | link
sticker_config:
  # For poll:
  question_en: ""
  question_ptbr: ""
  option_a_en: ""
  option_a_ptbr: ""
  option_b_en: ""
  option_b_ptbr: ""
  # For quiz:
  question_en: ""
  question_ptbr: ""
  correct_answer: ""
  # For countdown:
  event_name_en: ""
  event_name_ptbr: ""
  end_date: ""
  # For link:
  url: ""
  label_en: ""
  label_ptbr: ""
```

Visual: {{ image_prompt_story }}

---

## Feed Image Post Template

### Single Image

```yaml
aspect_ratio: ""  # 1:1 | 4:5
```

Visual: {{ image_prompt_feed }}

### Caption

```
[en]
{{ feed_caption_en }}

{{ hashtags_en }}
```

```
[pt-BR]
{{ feed_caption_ptbr }}

{{ hashtags_ptbr }}
```

---

## Hashtag Block

```yaml
hashtags:
  en:
    branded: ["#{{ brand_hashtag }}"]
    niche: []    # 5-10 hashtags, 10K-100K volume
    mid: []      # 3-5 hashtags, 100K-1M volume
    mega: []     # 1-2 hashtags, 1M+ volume
    total_count: 0  # aim for 8-15 total
  pt_br:
    branded: ["#{{ brand_hashtag }}"]
    niche: []
    mid: []
    mega: []
    total_count: 0
```

---

## AI Image Prompt Block

```yaml
image_prompt:
  platform: "instagram"
  format: ""  # carousel_slide | reel_cover | story | feed_post
  style: ""   # editorial photography | flat illustration | 3d render | lifestyle | hand-drawn
  subject: ""
  action: ""
  setting: ""
  mood: ""
  color_palette: []
  text_overlay_en: ""
  text_overlay_ptbr: ""
  aspect_ratio: ""  # 1:1 | 4:5 | 9:16
  negative_prompts: ["watermark", "text artifacts", "low quality", "blurry"]
```
