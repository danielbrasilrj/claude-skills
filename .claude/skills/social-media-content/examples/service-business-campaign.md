# Example: Service Business Multi-Platform Campaign

## Campaign Overview

```yaml
campaign:
  name: "january-wellness-launch"
  business: "Harmonia Wellness Studio"
  industry: "Health & Wellness (yoga, pilates, meditation)"
  goal: "Drive 50 new trial class bookings in January"
  duration: "Jan 6 - Jan 31, 2026"
  locales: ["en", "pt-BR"]
  platforms: ["instagram", "tiktok", "whatsapp-business", "google-business-profile"]
  content_pillars:
    - educational (30%)
    - behind-the-scenes (20%)
    - promotional (20%)
    - community (15%)
    - testimonial (15%)
  tone: "warm, encouraging, knowledgeable"
  audience:
    primary: "Women 25-45, health-conscious, urban professionals"
    secondary: "Men 30-50, stress management, beginners"
```

---

## Week 1 Content Calendar

### Monday — Educational Carousel (Instagram) + Educational TikTok

**Instagram Carousel: "5 Morning Stretches for Desk Workers"**

Slide 1 (Hook):
> [en] Sitting all day? Your body is paying the price. Here are 5 stretches you can do in 5 minutes.
> [pt-BR] Fica sentado o dia todo? Seu corpo esta cobrando o preco. Aqui vao 5 alongamentos que voce faz em 5 minutos.

Slides 2-6 (one stretch per slide):
> [en] 1. Neck rolls — 30 seconds each direction. Release tension from hours of screen time.
> [pt-BR] 1. Rotacao de pescoco — 30 segundos para cada lado. Libere a tensao de horas na tela.

> [en] 2. Seated spinal twist — Hold 20 seconds each side. Opens up the thoracic spine.
> [pt-BR] 2. Torcao sentada — Segure 20 segundos de cada lado. Abre a coluna toracica.

> [en] 3. Hip flexor stretch — 30 seconds each leg. Counteracts sitting posture.
> [pt-BR] 3. Alongamento de flexor do quadril — 30 segundos cada perna. Compensa a postura sentada.

> [en] 4. Wrist circles — 15 seconds each direction. Prevents repetitive strain.
> [pt-BR] 4. Circulos com os pulsos — 15 segundos para cada direcao. Previne lesao por esforco repetitivo.

> [en] 5. Standing forward fold — Hold 30 seconds. Resets your whole posterior chain.
> [pt-BR] 5. Flexao em pe — Segure 30 segundos. Reseta toda a cadeia posterior.

Slide 7 (CTA):
> [en] Want a full guided session? Book a free trial class at Harmonia.
> [pt-BR] Quer uma sessao completa guiada? Agende uma aula experimental gratis na Harmonia.

Caption:
```
[en]
Your desk job is not your body's friend.

These 5 stretches take less than 5 minutes and can transform how you feel by the end of the workday.

Save this post for your afternoon break.

Want more? Link in bio for a free trial class.

#DeskStretches #WellnessAtWork #YogaForBeginners #MorningRoutine #HarmoniaWellness #OfficeYoga #HealthyHabits #FitnessTips

[pt-BR]
Seu trabalho de escritorio nao e amigo do seu corpo.

Esses 5 alongamentos levam menos de 5 minutos e podem transformar como voce se sente no fim do dia.

Salva esse post pro seu intervalo da tarde.

Quer mais? Link na bio para uma aula experimental gratis.

#AlongamentoNoTrabalho #BemEstar #YogaParaIniciantes #RotinaDaManha #HarmoniaWellness #SaudeNoEscritorio #HabitosSaudaveis #DicasDeFitness
```

AI Image Prompt (per slide):
```yaml
image_prompt:
  platform: "instagram"
  format: "carousel_slide"
  style: "lifestyle photography"
  subject: "woman in professional casual clothing doing a stretch at a modern standing desk"
  setting: "bright, modern home office with plants"
  mood: "calm, refreshing, energizing"
  color_palette: ["#7CB9A8", "#F5F0EB", "#2D3436"]
  aspect_ratio: "4:5"
  negative_prompts: ["watermark", "cluttered background", "gym setting"]
```

---

**TikTok Script: "3 Stretches You Need If You Sit All Day"**

```yaml
duration: "30s"
audio: "original voiceover"
```

Hook (0-3s):
> [en] If you sit for more than 6 hours a day, you NEED to hear this.
> [pt-BR] Se voce fica sentado mais de 6 horas por dia, PRECISA ouvir isso.

Visual: Person sitting at desk, rubbing neck in discomfort. Quick cut.

Body (3-25s):
> [en] These 3 stretches take 2 minutes and undo hours of sitting damage.
> Number 1: Cat-cow. Gets your spine moving again.
> Number 2: Hip flexor lunge. Opens up what sitting closes.
> Number 3: Chest opener. Reverses that forward hunch.
> [pt-BR] Esses 3 alongamentos levam 2 minutos e desfazem horas de dano de ficar sentado.
> Numero 1: Gato-vaca. Coloca sua coluna pra mexer de novo.
> Numero 2: Afundo pro flexor do quadril. Abre o que ficar sentado fecha.
> Numero 3: Abertura de peito. Reverte aquela corcunda pra frente.

Visual: Quick demonstrations of each stretch, clean transitions, on-screen text labels.

CTA (25-30s):
> [en] Follow for more and book a free class — link in bio.
> [pt-BR] Segue pra mais e agenda uma aula gratis — link na bio.

Caption:
```
[en]
Your body will thank you. Try these today.

#DeskStretches #FitnessForBeginners #WellnessTips

[pt-BR]
Seu corpo vai agradecer. Tenta hoje.

#AlongamentoNoTrabalho #FitnessParaIniciantes #DicasDeBemEstar
```

---

### Wednesday — Promotional Offer (GBP + WhatsApp)

**Google Business Profile Offer Post**

```
[en]
New Year, New You — Free Trial Class at Harmonia Wellness

Start your wellness journey with a complimentary yoga or pilates class. Available for first-time visitors throughout January. Book online or call us directly.

[pt-BR]
Ano Novo, Voce Novo — Aula Experimental Gratis na Harmonia Wellness

Comece sua jornada de bem-estar com uma aula gratis de yoga ou pilates. Disponivel para novos alunos durante todo o mes de janeiro. Agende online ou ligue direto.
```

```yaml
offer:
  title_en: "Free Trial Class — January Only"
  title_ptbr: "Aula Experimental Gratis — So em Janeiro"
  start_date: "2026-01-06"
  end_date: "2026-01-31"
  coupon_code: "NEWYOU2026"
  redeem_url: "https://harmoniawellness.com/trial"
  terms_en: "Valid for first-time visitors only. One per person. Must book in advance."
  terms_ptbr: "Valido apenas para novos alunos. Um por pessoa. Necessario agendamento previo."
cta:
  type: "book"
  url: "https://harmoniawellness.com/trial"
```

**WhatsApp Business Broadcast (Marketing Template)**

Template name: `january_trial_offer_en` / `january_trial_offer_pt_BR`

```
[en]
Hi {{1}}!

Harmonia Wellness is offering a FREE trial class this January. Choose from yoga, pilates, or meditation.

Book your spot: https://harmoniawellness.com/trial
Use code NEWYOU2026 at checkout.

Reply STOP to unsubscribe.

[pt-BR]
Oi {{1}}!

A Harmonia Wellness esta oferecendo uma aula experimental GRATIS neste janeiro. Escolha entre yoga, pilates ou meditacao.

Agende seu horario: https://harmoniawellness.com/trial
Use o codigo NEWYOU2026 no agendamento.

Responda SAIR para cancelar.
```

```yaml
variables:
  "{{1}}":
    description: "Customer first name"
    sample_en: "Sarah"
    sample_ptbr: "Ana"
buttons:
  - type: "url"
    url: "https://harmoniawellness.com/trial"
    text_en: "Book Now"
    text_ptbr: "Agendar Agora"
  - type: "quick_reply"
    text_en: "Learn More"
    text_ptbr: "Saber Mais"
```

---

### Friday — Community Reel (Instagram) + Event (GBP)

**Instagram Reel: Community Class Highlight**

```yaml
duration: "30s"
audio: "upbeat trending audio"
```

Hook (0-3s):
> [en] This is what 7 AM looks like at Harmonia.
> [pt-BR] Assim que sao 7 da manha na Harmonia.

Visual: Time-lapse of empty studio filling up with students, morning light streaming in.

Body (3-25s):
Montage of class moments — instructor guiding poses, students laughing, peaceful meditation close, high-fives after class.

CTA (25-30s):
> [en] Your mat is waiting. First class free — link in bio.
> [pt-BR] Seu tapete ta esperando. Primeira aula gratis — link na bio.

**GBP Event Post**

```
[en]
Community Yoga in the Park — Saturday, January 17

Join us for a free outdoor yoga session at Riverside Park. All levels welcome. Bring your own mat. Light refreshments provided after class.

[pt-BR]
Yoga Comunitario no Parque — Sabado, 17 de Janeiro

Participe de uma sessao gratuita de yoga ao ar livre no Parque Riverside. Todos os niveis sao bem-vindos. Traga seu tapete. Comes e bebes leves apos a aula.
```

```yaml
event:
  title_en: "Community Yoga in the Park"
  title_ptbr: "Yoga Comunitario no Parque"
  start_date: "2026-01-17"
  start_time: "09:00"
  end_date: "2026-01-17"
  end_time: "10:30"
  timezone: "America/New_York"
cta:
  type: "sign_up"
  url: "https://harmoniawellness.com/events/park-yoga"
```

---

## Privacy Compliance Review

```yaml
compliance_review:
  campaign_name: "january-wellness-launch"
  reviewer: "Marketing Lead"
  date: "2026-01-03"
  jurisdictions: ["GDPR", "LGPD"]
  checklist:
    consent_collected: true
    opt_out_mechanism: true
    pixel_tracking_disclosed: true
    ugc_permissions: "N/A (no UGC in this campaign)"
    minor_protection: "age-gated ad targeting, no data from under-18s"
    whatsapp_templates_approved: "pending submission"
    dsar_process_ready: true
  status: "compliant"
  notes: "WhatsApp templates submitted for Meta review on Jan 2. Awaiting approval before broadcast."
```

---

## Campaign KPIs

| Metric | Target | Tracking |
|--------|--------|----------|
| Trial class bookings | 50 | Booking system + coupon code |
| Instagram reach | 10,000 | Instagram Insights |
| TikTok views | 25,000 | TikTok Analytics |
| WhatsApp open rate | 80%+ | WhatsApp Business API |
| GBP post views | 2,000 | GBP Insights |
| Website traffic from social | 500 visits | UTM tracking in Google Analytics |
