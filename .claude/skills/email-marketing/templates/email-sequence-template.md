# Email Sequence Template

Use this template for any automated email sequence (welcome, nurture, re-engagement, etc.).

---

## Sequence Metadata

**Sequence Name:** [Descriptive name]  
**Sequence Type:** [Welcome / Nurture / Re-engagement / Reactivation / Transactional]  
**Target Segment:** [Who receives this sequence]  
**Primary Goal:** [Activation, conversion, retention, etc.]  
**Secondary Goal:** [Optional secondary metric]  
**Total Emails:** [Number of emails in sequence]  
**Duration:** [Total time span, e.g., 14 days]  
**Target Locales:** [en, pt-BR, etc.]

---

## Sequence Flow Diagram

```
[Trigger Event] → Email 1 (Day 0) → Email 2 (Day X) → Email 3 (Day Y) → [Goal]
```

**Example:**
```
User signs up → Welcome (Day 0) → Tutorial (Day 3) → Case Study (Day 7) → Upgrade (Day 14) → Paying customer
```

---

## Email 1: [Descriptive Name]

### Timing
**When:** [Day 0, immediately / Day 3, 10am user's timezone / etc.]  
**Delay from trigger:** [Immediate, 3 days, 1 week, etc.]

### Goal
**Primary:** [What should happen after reading this email]  
**Metric:** [Open rate / Click rate / Conversion / etc.]

---

### Subject Line

**English:**
```
[Subject line variant A]
```

**pt-BR:**
```
[Adapted subject line — not literal translation]
```

**A/B Test Variant (Optional):**
**English:**
```
[Subject line variant B]
```

**pt-BR:**
```
[Adapted variant B]
```

---

### Preview Text

**English:**
```
[First line visible in inbox preview — 40-90 chars]
```

**pt-BR:**
```
[Adapted preview text]
```

---

### Email Body (English)

#### From Name
```
[First Name from Company / Company Name / Team Name]
```

#### From Email
```
[hello@, team@, or personal email]
```

#### Greeting
```
Hi {{first_name}},
```

#### Body Copy
```
[Paragraph 1: Hook — why they're receiving this, what's in it for them]

[Paragraph 2: Value/content — key message or benefit]

[Paragraph 3: Social proof or credibility element (optional)]

[Paragraph 4: Clear next action]
```

#### CTA
```
Button Text: [Action verb + value]
Button URL: [Link destination]
```

#### Sign-Off
```
[Friendly closing],
[Name]
[Title]
[Company]
```

#### Footer
```
You're receiving this because you signed up at [website].
[Unsubscribe] | [Update preferences]

[Company Name]
[Physical Address]
```

---

### Email Body (pt-BR)

#### From Name
```
[Adapted from name]
```

#### From Email
```
[Same as English]
```

#### Greeting
```
Oi {{first_name}},
```

#### Body Copy
```
[Paragraph 1: Transcreated hook]

[Paragraph 2: Transcreated value/content]

[Paragraph 3: Social proof or credibility (adapted)]

[Paragraph 4: Transcreated next action]
```

#### CTA
```
Button Text: [Adapted action — account for +25% text expansion]
Button URL: [Same link or localized version]
```

#### Sign-Off
```
[Adapted closing],
[Name]
[Title]
[Company]
```

#### Footer
```
Você está recebendo este email porque se inscreveu em [website].
[Cancelar inscrição] | [Atualizar preferências]

[Company Name]
[Physical Address]
```

---

### Design Notes
- **Template:** [Template ID or name in ESP]
- **Images:** [List any images/graphics needed]
- **Mobile-friendly:** [Yes/No — responsive design required]
- **Plain text version:** [Required for deliverability]

---

### Success Metrics
| Metric | Target | Measurement Window |
|--------|--------|-------------------|
| Open rate | [%] | [24 hours / 7 days] |
| Click rate | [%] | [24 hours / 7 days] |
| Conversion rate | [%] | [7 days / 14 days] |
| Unsubscribe rate | [<X%] | [Immediate] |

---

## Email 2: [Descriptive Name]

### Timing
**When:** [Day 3, 10am user's timezone]  
**Delay from Email 1:** [3 days]  
**Condition:** [Optional — only send if Email 1 was opened, etc.]

### Goal
**Primary:** [What should happen after reading this email]  
**Metric:** [Open rate / Click rate / Conversion / etc.]

---

### Subject Line

**English:**
```
[Subject line variant A]
```

**pt-BR:**
```
[Adapted subject line]
```

---

### Preview Text

**English:**
```
[Preview text 40-90 chars]
```

**pt-BR:**
```
[Adapted preview text]
```

---

### Email Body (English)

#### From Name
```
[First Name from Company / Company Name / Team Name]
```

#### From Email
```
[hello@, team@, or personal email]
```

#### Greeting
```
Hi {{first_name}},
```

#### Body Copy
```
[Paragraph 1: Hook — reference previous email or continue story]

[Paragraph 2: Value/content — educational content or next step]

[Paragraph 3: Social proof or use case example (optional)]

[Paragraph 4: Clear next action]
```

#### CTA
```
Button Text: [Action verb + value]
Button URL: [Link destination]
```

#### Sign-Off
```
[Friendly closing],
[Name]
[Title]
[Company]
```

#### Footer
```
You're receiving this because you signed up at [website].
[Unsubscribe] | [Update preferences]

[Company Name]
[Physical Address]
```

---

### Email Body (pt-BR)

[Same structure as Email 1 pt-BR section]

---

### Design Notes
- **Template:** [Template ID or name in ESP]
- **Images:** [List any images/graphics needed]
- **Mobile-friendly:** [Yes/No]
- **Plain text version:** [Required]

---

### Success Metrics
| Metric | Target | Measurement Window |
|--------|--------|-------------------|
| Open rate | [%] | [24 hours / 7 days] |
| Click rate | [%] | [24 hours / 7 days] |
| Conversion rate | [%] | [7 days / 14 days] |
| Unsubscribe rate | [<X%] | [Immediate] |

---

## Email 3: [Descriptive Name]

[Repeat structure from Email 2]

---

## Email 4: [Descriptive Name]

[Repeat structure from Email 2]

---

## Email 5: [Descriptive Name] (if applicable)

[Repeat structure from Email 2]

---

## Sequence Exit Conditions

**User exits sequence if:**
- [ ] User completes goal action (e.g., upgrades, makes purchase)
- [ ] User unsubscribes
- [ ] User marks as spam
- [ ] User becomes inactive (define inactivity threshold)

**Re-entry rules:**
- [ ] User can re-enter sequence: [Yes / No]
- [ ] Minimum wait time before re-entry: [X days]

---

## A/B Testing Plan

### Test 1: Subject Lines (Email 1)
**Variable:** Personalization (with name vs without)  
**Variant A:** [Subject without name]  
**Variant B:** [Subject with {{first_name}}]  
**Sample size:** 1,000 per variant  
**Duration:** 4 hours  
**Winner selection:** Highest open rate

### Test 2: CTA Copy (Email 2)
**Variable:** CTA text  
**Variant A:** [CTA option 1]  
**Variant B:** [CTA option 2]  
**Sample size:** 1,000 per variant  
**Duration:** 24 hours  
**Winner selection:** Highest click rate

---

## Send Time Optimization

**Default send times:**
- **USA (EST):** Tuesday-Thursday, 10am
- **Brazil (BRT):** Tuesday-Thursday, 9am
- **Europe (CET):** Wednesday, 8am

**ESP send time optimization:** [Enable if available in Klaviyo, HubSpot, etc.]

---

## Localization Notes

### Text Expansion (pt-BR)
- [ ] All buttons tested with +25% longer text
- [ ] Email width accommodates expanded paragraphs
- [ ] Subject lines stay under 50 chars in both languages

### Formatting
- [ ] Dates formatted correctly: `03/15/2025` (en) → `15/03/2025` (pt-BR)
- [ ] Currency formatted: `$49.99` (en) → `R$ 49,99` (pt-BR)
- [ ] Time formatted: `3:45 PM` (en) → `15h45` (pt-BR)

---

## Compliance Checklist

**CAN-SPAM (USA):**
- [ ] Accurate "From" name
- [ ] Accurate subject line (no deception)
- [ ] Physical address in footer
- [ ] Unsubscribe link functional
- [ ] Unsubscribe processes within 10 days

**LGPD (Brazil):**
- [ ] Explicit consent obtained at signup
- [ ] Privacy policy linked in footer
- [ ] Unsubscribe honored immediately
- [ ] User can request data export/deletion

---

## Deliverability Checklist

- [ ] SPF, DKIM, DMARC configured
- [ ] Plain text version included
- [ ] No spam trigger words in subject/body
- [ ] Images optimized (under 1MB total)
- [ ] Tested in Litmus or Email on Acid
- [ ] Unsubscribe link tested
- [ ] Links tested (no broken URLs)
- [ ] Spam score under 5 (Mail Tester)

---

## Notes

[Add any additional context, edge cases, or special instructions here]
