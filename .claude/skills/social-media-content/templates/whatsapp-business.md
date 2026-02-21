# WhatsApp Business Message Template

## Template Configuration

```yaml
template_name: ""       # lowercase_with_underscores, unique per language
category: ""            # utility | authentication | marketing
language_code: ""       # en | pt_BR (WhatsApp uses underscore)
status: "draft"         # draft | submitted | approved | rejected
business_account: ""
```

---

## Utility Template

**Use case**: Order confirmations, appointment reminders, shipping updates.

**Template name**: `{{ template_name }}_{{ language_code }}`

### Header (optional)

```yaml
header:
  type: ""  # text | image | video | document
  # If text:
  text_en: "{{ header_text_en }}"
  text_ptbr: "{{ header_text_ptbr }}"
  # If media:
  media_url: ""
```

### Body

```
[en]
{{ body_en }}
```

```
[pt-BR]
{{ body_ptbr }}
```

**Variables**: Use `{{1}}`, `{{2}}`, etc. for dynamic content. Each variable must have a sample value for review.

```yaml
variables:
  "{{1}}":
    description: ""
    sample_en: ""
    sample_ptbr: ""
  "{{2}}":
    description: ""
    sample_en: ""
    sample_ptbr: ""
```

### Footer (optional)

```
[en] {{ footer_en }}
[pt-BR] {{ footer_ptbr }}
```

### Buttons (optional, max 3)

```yaml
buttons:
  - type: ""  # quick_reply | url | phone
    # quick_reply:
    text_en: ""
    text_ptbr: ""
    # url:
    url: ""  # one dynamic parameter allowed: https://example.com/order/{{1}}
    text_en: ""
    text_ptbr: ""
    # phone:
    phone_number: ""
    text_en: ""
    text_ptbr: ""
```

---

## Marketing Template

**Use case**: Promotions, offers, newsletters, product launches.

**IMPORTANT**: Marketing templates require explicit user opt-in. Every marketing message must include an opt-out mechanism.

### Header (optional)

```yaml
header:
  type: ""  # text | image | video | document
  text_en: ""
  text_ptbr: ""
```

### Body

```
[en]
{{ marketing_body_en }}

Reply STOP to unsubscribe.
```

```
[pt-BR]
{{ marketing_body_ptbr }}

Responda SAIR para cancelar.
```

### Buttons

```yaml
buttons:
  - type: "quick_reply"
    text_en: "Shop Now"
    text_ptbr: "Comprar Agora"
  - type: "quick_reply"
    text_en: "Not Interested"
    text_ptbr: "Nao Tenho Interesse"
```

---

## Authentication Template

**Use case**: OTP codes, login verification.

```
[en]
Your verification code is {{1}}. This code expires in {{2}} minutes. Do not share this code with anyone.

[pt-BR]
Seu codigo de verificacao e {{1}}. Este codigo expira em {{2}} minutos. Nao compartilhe este codigo com ninguem.
```

```yaml
buttons:
  - type: "otp"
    otp_type: "copy_code"  # copy_code | one_tap
```

---

## Broadcast Campaign Structure

```yaml
broadcast:
  name: ""
  template: ""               # approved template name
  audience_segment: ""        # segment name from CRM
  schedule:
    date: ""
    time: ""                  # in recipient's timezone
    timezone: ""              # e.g., America/Sao_Paulo
  locales:
    - language_code: "en"
      template_name: "{{ template_name }}_en"
      audience_filter: "locale=en"
    - language_code: "pt_BR"
      template_name: "{{ template_name }}_pt_BR"
      audience_filter: "locale=pt-BR"
  opt_in_verified: true       # MUST be true before sending
  estimated_recipients: 0
  fallback_locale: "en"       # send this if user locale unknown
```

---

## Opt-In Collection Template

For collecting marketing opt-in during customer interactions:

```
[en]
Hi {{1}}! Would you like to receive updates and offers from us via WhatsApp? You can unsubscribe anytime.

[pt-BR]
Oi {{1}}! Gostaria de receber novidades e ofertas nossas pelo WhatsApp? Voce pode cancelar a qualquer momento.
```

```yaml
buttons:
  - type: "quick_reply"
    text_en: "Yes, subscribe me"
    text_ptbr: "Sim, quero receber"
  - type: "quick_reply"
    text_en: "No thanks"
    text_ptbr: "Nao, obrigado"
```

---

## Meta Approval Checklist

Before submitting templates to Meta for approval:

- [ ] Template name is unique and uses only lowercase letters, numbers, and underscores
- [ ] Each language variant has its own separate template submission
- [ ] Utility templates contain no promotional language
- [ ] Marketing templates include opt-out instructions
- [ ] Variables (`{{1}}`, `{{2}}`) have clear sample values
- [ ] No URL shorteners in body text (only in URL buttons)
- [ ] No misleading or deceptive content
- [ ] Header media meets format requirements (image: JPG/PNG, video: MP4, document: PDF)
- [ ] Button text is under 25 characters
- [ ] Body text is under 1024 characters
- [ ] Footer text is under 60 characters

---

## Conversation Window Rules

```yaml
conversation_windows:
  business_initiated:
    trigger: "approved template message"
    window: "24 hours from delivery"
    cost: "per-conversation pricing"
  user_initiated:
    trigger: "user sends message first"
    window: "24 hours from last user message"
    cost: "per-conversation pricing (lower rate)"
  free_tier:
    first_1000_conversations: "free per month"
    service_conversations: "always free (user-initiated with no template)"
```

**Key rule**: You can only send template messages outside the 24-hour window. Within the window, you can send free-form messages.
