# TikTok Script Template

## Script Configuration

```yaml
video_type: ""     # educational | entertainment | promotional | storytelling | trend
pillar: ""         # educational | behind-the-scenes | promotional | community | testimonial
target_duration: "" # 15s | 30s | 60s | 3min
locale: ""         # en | pt-BR
campaign: ""
publish_date: ""
trending_audio: "" # name of trending sound or "original"
```

---

## Script Structure

### Hook (0-3 seconds)

**Goal**: Stop the scroll. Pattern interrupt. Create curiosity gap.

**Hook type**: {{ hook_type }}
<!-- Options: question | bold_claim | controversy | before_after | pov | story_opener | list_tease -->

> [en] {{ hook_en }}

> [pt-BR] {{ hook_ptbr }}

**Visual direction**: {{ hook_visual }}
**On-screen text**:
- [en] {{ hook_text_en }}
- [pt-BR] {{ hook_text_ptbr }}

---

### Body (3s to {{ end_body_time }})

**Key points** (1-3 maximum for short-form):

**Point 1** ({{ timestamp_start }} - {{ timestamp_end }})

> [en] {{ point_1_en }}

> [pt-BR] {{ point_1_ptbr }}

Visual direction: {{ point_1_visual }}
On-screen text:
- [en] {{ point_1_text_en }}
- [pt-BR] {{ point_1_text_ptbr }}

**Point 2** ({{ timestamp_start }} - {{ timestamp_end }})

> [en] {{ point_2_en }}

> [pt-BR] {{ point_2_ptbr }}

Visual direction: {{ point_2_visual }}
On-screen text:
- [en] {{ point_2_text_en }}
- [pt-BR] {{ point_2_text_ptbr }}

**Point 3** ({{ timestamp_start }} - {{ timestamp_end }})

> [en] {{ point_3_en }}

> [pt-BR] {{ point_3_ptbr }}

Visual direction: {{ point_3_visual }}
On-screen text:
- [en] {{ point_3_text_en }}
- [pt-BR] {{ point_3_text_ptbr }}

---

### CTA (final 2-5 seconds)

**CTA type**: {{ cta_type }}
<!-- Options: follow | comment | share | visit_link | save | duet | part_2_tease -->

> [en] {{ cta_en }}

> [pt-BR] {{ cta_ptbr }}

Visual direction: {{ cta_visual }}
On-screen text:
- [en] {{ cta_text_en }}
- [pt-BR] {{ cta_text_ptbr }}

---

## Caption

```
[en]
{{ caption_en }}

{{ hashtags_en }}
```

```
[pt-BR]
{{ caption_ptbr }}

{{ hashtags_ptbr }}
```

---

## Hashtags

```yaml
hashtags:
  en:
    trending: []    # 1-2 currently trending
    niche: []       # 2-3 niche community
    branded: []     # 1 brand hashtag
    total_count: 0  # aim for 3-5 total
  pt_br:
    trending: []
    niche: []
    branded: []
    total_count: 0
```

---

## Production Notes

```yaml
production:
  filming_setup: ""     # smartphone | camera | screen_record | mixed
  lighting: ""          # natural | ring_light | studio | none
  audio_source: ""      # voiceover | on_camera | trending_audio | text_to_speech
  editing_style: ""     # fast_cuts | continuous | transitions | green_screen
  text_style: ""        # bold_overlay | subtitle | minimal | none
  captions: true        # always include captions for accessibility
  b_roll_needed: []     # list of supplementary footage
  props_needed: []      # physical props for the shoot
```

---

## Hook Formula Reference

Use these proven hook formulas adapted per locale:

| Formula | English Example | pt-BR Example |
|---------|----------------|---------------|
| Question | "Did you know most people get this wrong?" | "Voce sabia que a maioria erra nisso?" |
| Bold claim | "This one trick doubled our sales" | "Esse truque dobrou nossas vendas" |
| POV | "POV: You just discovered the easiest way to..." | "POV: Voce acabou de descobrir o jeito mais facil de..." |
| List tease | "3 things nobody tells you about..." | "3 coisas que ninguem te conta sobre..." |
| Before/After | "Watch what happens when..." | "Olha o que acontece quando..." |
| Controversy | "Unpopular opinion: ..." | "Opiniao impopular: ..." |
| Story opener | "So this happened to me yesterday..." | "Entao isso aconteceu comigo ontem..." |

---

## TikTok-Specific Best Practices

- **Duration**: 15-30 seconds for maximum completion rate and algorithmic boost
- **First frame**: must be visually compelling (no blank intros)
- **Captions**: always add — 80%+ viewers watch with sound off initially
- **Trending audio**: use within first 48 hours of trend emerging for maximum reach
- **Loop potential**: design the ending to flow into the beginning for repeat views
- **Reply to comments**: creates new content opportunities and boosts original video
- **Post frequency**: 1-3 times per day for growth phase, 3-5 per week for maintenance
