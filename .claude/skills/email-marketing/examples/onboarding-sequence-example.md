# Onboarding Email Sequence Example: AppointmentPro SaaS

**Sequence Name:** New User Onboarding  
**Sequence Type:** Welcome Series  
**Target Segment:** Users who signed up for free trial in last 24 hours  
**Primary Goal:** Activate trial users (complete first booking)  
**Secondary Goal:** Educate on core features  
**Total Emails:** 5 emails  
**Duration:** 14 days  
**Target Locales:** en, pt-BR

---

## Sequence Flow Diagram

```
User signs up → Email 1 (Day 0) → Email 2 (Day 3) → Email 3 (Day 7) → Email 4 (Day 10) → Email 5 (Day 14) → Convert to paid
```

---

## Email 1: Welcome & Quick Start

### Timing
**When:** Immediately upon signup (within 5 minutes)  
**Delay from trigger:** 0 minutes

### Goal
**Primary:** Complete onboarding (connect calendar)  
**Metric:** Click rate on "Connect Calendar" CTA (target: 40%)

---

### Subject Line

**English:**
```
Welcome to AppointmentPro, {{first_name}}!
```

**pt-BR:**
```
Bem-vindo(a) ao AppointmentPro, {{first_name}}!
```

---

### Preview Text

**English:**
```
Here's how to book your first appointment in 2 minutes
```

**pt-BR:**
```
Veja como agendar sua primeira consulta em 2 minutos
```

---

### Email Body (English)

#### From Name
```
Sarah from AppointmentPro
```

#### From Email
```
sarah@appointmentpro.com
```

#### Greeting
```
Hi {{first_name}},
```

#### Body Copy
```
Welcome to AppointmentPro! I'm Sarah, and I'm here to help you get set up in under 5 minutes.

You're about to save 15+ hours every week on scheduling. Here's what happens next:

**Step 1: Connect Your Calendar**
Sync Google Calendar, Outlook, or iCal in one click. No technical setup required.

[Connect Calendar Button]

**Step 2: Set Your Availability**
Tell us your working hours and preferred buffer times. The AI handles the rest.

**Step 3: Share Your Booking Link**
Send clients your personalized link. They book instantly, and you get automatic reminders.

Most users are fully set up in under 10 minutes. Let's get started!

Click below to connect your calendar now:

[Connect Calendar Button]

Have questions? Just reply to this email — I read every message.
```

#### CTA
```
Button Text: Connect My Calendar
Button URL: https://app.appointmentpro.com/onboarding/calendar
```

#### Sign-Off
```
Let's do this,
Sarah
Head of Customer Success
AppointmentPro
```

#### Footer
```
You're receiving this because you signed up at appointmentpro.com.
Unsubscribe | Update preferences

AppointmentPro Inc.
1234 Market St, Suite 500, San Francisco, CA 94103
```

---

### Email Body (pt-BR)

#### From Name
```
Sarah da AppointmentPro
```

#### From Email
```
sarah@appointmentpro.com
```

#### Greeting
```
Oi {{first_name}},
```

#### Body Copy
```
Bem-vindo(a) ao AppointmentPro! Sou a Sarah, e estou aqui para te ajudar a configurar tudo em menos de 5 minutos.

Você está prestes a economizar mais de 15 horas toda semana com agendamentos. Veja o que vem a seguir:

**Passo 1: Conecte Sua Agenda**
Sincronize Google Calendar, Outlook ou iCal em um clique. Sem configuração técnica.

[Botão: Conectar Agenda]

**Passo 2: Defina Sua Disponibilidade**
Nos diga seus horários de trabalho e intervalos preferidos. A IA cuida do resto.

**Passo 3: Compartilhe Seu Link de Agendamento**
Envie aos clientes seu link personalizado. Eles agendam na hora, e você recebe lembretes automáticos.

A maioria dos usuários configura tudo em menos de 10 minutos. Vamos começar!

Clique abaixo para conectar sua agenda agora:

[Botão: Conectar Minha Agenda]

Tem dúvidas? Responda este email — eu leio cada mensagem.
```

#### CTA
```
Button Text: Conectar Minha Agenda
Button URL: https://app.appointmentpro.com/onboarding/calendar
```

#### Sign-Off
```
Vamos lá,
Sarah
Diretora de Sucesso do Cliente
AppointmentPro
```

#### Footer
```
Você está recebendo este email porque se inscreveu em appointmentpro.com.
Cancelar inscrição | Atualizar preferências

AppointmentPro Inc.
1234 Market St, Suite 500, San Francisco, CA 94103
```

---

### Design Notes
- **Template:** welcome-v2
- **Images:** AppointmentPro logo (header), screenshot of calendar sync screen
- **Mobile-friendly:** Yes — responsive design
- **Plain text version:** Included

---

### Success Metrics
| Metric | Target | Measurement Window |
|--------|--------|-------------------|
| Open rate | 60% | 24 hours |
| Click rate | 40% | 24 hours |
| Calendar connection | 30% | 24 hours |
| Unsubscribe rate | <0.5% | Immediate |

---

## Email 2: Quick Win Tutorial

### Timing
**When:** Day 3, 10am user's timezone  
**Delay from Email 1:** 3 days  
**Condition:** Only send if user connected calendar in Email 1

### Goal
**Primary:** Complete first booking setup  
**Metric:** User creates first booking link (target: 50%)

---

### Subject Line

**English:**
```
{{first_name}}, your first booking link is ready 🎉
```

**pt-BR:**
```
{{first_name}}, seu primeiro link de agendamento está pronto 🎉
```

**A/B Test Variant:**

**English:**
```
Your calendar is connected — here's what's next
```

**pt-BR:**
```
Sua agenda está conectada — veja o próximo passo
```

---

### Preview Text

**English:**
```
Share this link and start booking appointments in seconds
```

**pt-BR:**
```
Compartilhe este link e comece a agendar consultas em segundos
```

---

### Email Body (English)

#### From Name
```
Sarah from AppointmentPro
```

#### From Email
```
sarah@appointmentpro.com
```

#### Greeting
```
Hi {{first_name}},
```

#### Body Copy
```
Great news — your calendar is connected! 🎉

You're already saving time. Now let's get you your first booking.

**Your personalized booking link:**
{{booking_link}}

Here's how it works:

1. **Copy your link** above
2. **Share it with a client** via text, email, or social media
3. **They pick a time** from your available slots
4. **You both get automatic confirmations** and reminders

No more back-and-forth "When are you free?" texts. Just instant bookings.

**Pro tip:** Add your booking link to your email signature, Instagram bio, or website. 73% of our users get their first booking within 24 hours of sharing.

Ready to test it? Send your link to one client right now:

[Copy My Booking Link]

Already got your first booking? You're crushing it! Email me a screenshot and I'll send you a surprise. 😊
```

#### CTA
```
Button Text: Copy My Booking Link
Button URL: https://app.appointmentpro.com/dashboard/booking-link
```

#### Sign-Off
```
You've got this,
Sarah
Head of Customer Success
AppointmentPro

P.S. Reply with any questions — I'm here to help!
```

#### Footer
```
You're receiving this because you signed up at appointmentpro.com.
Unsubscribe | Update preferences

AppointmentPro Inc.
1234 Market St, Suite 500, San Francisco, CA 94103
```

---

### Email Body (pt-BR)

#### From Name
```
Sarah da AppointmentPro
```

#### From Email
```
sarah@appointmentpro.com
```

#### Greeting
```
Oi {{first_name}},
```

#### Body Copy
```
Ótima notícia — sua agenda está conectada! 🎉

Você já está economizando tempo. Agora vamos conseguir seu primeiro agendamento.

**Seu link personalizado de agendamento:**
{{booking_link}}

Veja como funciona:

1. **Copie seu link** acima
2. **Compartilhe com um cliente** por mensagem, email ou redes sociais
3. **Ele escolhe um horário** dos seus slots disponíveis
4. **Vocês dois recebem confirmações** e lembretes automáticos

Chega de ficar trocando mensagens "Quando você está livre?". Só agendamentos instantâneos.

**Dica:** Adicione seu link de agendamento à sua assinatura de email, bio do Instagram ou site. 73% dos nossos usuários conseguem o primeiro agendamento em até 24 horas depois de compartilhar.

Pronto pra testar? Envie seu link para um cliente agora mesmo:

[Copiar Meu Link de Agendamento]

Já conseguiu seu primeiro agendamento? Você está arrasando! Me mande um print e eu te envio uma surpresa. 😊
```

#### CTA
```
Button Text: Copiar Meu Link de Agendamento
Button URL: https://app.appointmentpro.com/dashboard/booking-link
```

#### Sign-Off
```
Você consegue,
Sarah
Diretora de Sucesso do Cliente
AppointmentPro

P.S. Responda com qualquer dúvida — estou aqui pra ajudar!
```

#### Footer
```
Você está recebendo este email porque se inscreveu em appointmentpro.com.
Cancelar inscrição | Atualizar preferências

AppointmentPro Inc.
1234 Market St, Suite 500, San Francisco, CA 94103
```

---

### Design Notes
- **Template:** tutorial-v1
- **Images:** Screenshot of booking link in action
- **Mobile-friendly:** Yes
- **Plain text version:** Included

---

### Success Metrics
| Metric | Target | Measurement Window |
|--------|--------|-------------------|
| Open rate | 50% | 24 hours |
| Click rate | 35% | 24 hours |
| First booking created | 25% | 7 days |
| Unsubscribe rate | <0.5% | Immediate |

---

## Email 3: Social Proof & Case Study

### Timing
**When:** Day 7, 2pm user's timezone  
**Delay from Email 2:** 4 days

### Goal
**Primary:** Build trust, show ROI  
**Metric:** Open rate (target: 40%)

---

### Subject Line

**English:**
```
How Marcus cut no-shows from 30% to 4% in 30 days
```

**pt-BR:**
```
Como o Marcus reduziu faltas de 30% pra 4% em 30 dias
```

---

### Preview Text

**English:**
```
Real results from a personal trainer just like you
```

**pt-BR:**
```
Resultados reais de um personal trainer como você
```

---

### Email Body (English)

#### From Name
```
Sarah from AppointmentPro
```

#### From Email
```
sarah@appointmentpro.com
```

#### Greeting
```
Hi {{first_name}},
```

#### Body Copy
```
I want to introduce you to Marcus.

Marcus is a personal trainer in Austin. Before AppointmentPro, 30% of his clients were no-shows. He was losing $2,000+ every month.

Here's what he did:

✅ **Connected his calendar** (took 2 minutes)  
✅ **Shared his booking link** in his Instagram bio  
✅ **Turned on automatic SMS reminders** 24 hours before sessions

**The result?**
No-shows dropped from 30% to 4% in the first month. He got back 12 hours per week and earned an extra $1,800 that month alone.

Here's what Marcus said:

> "I was skeptical at first, but the reminders work. Clients actually show up now. I'm making more money and stressing way less."
> — Marcus T., Personal Trainer

**You can do the same.**

If you haven't turned on reminders yet, do it now. It takes 30 seconds:

[Turn On Reminders]

Already using reminders? You're ahead of the game! Keep it up.
```

#### CTA
```
Button Text: Turn On Reminders
Button URL: https://app.appointmentpro.com/settings/reminders
```

#### Sign-Off
```
Rooting for you,
Sarah
Head of Customer Success
AppointmentPro
```

#### Footer
```
You're receiving this because you signed up at appointmentpro.com.
Unsubscribe | Update preferences

AppointmentPro Inc.
1234 Market St, Suite 500, San Francisco, CA 94103
```

---

### Email Body (pt-BR)

#### From Name
```
Sarah da AppointmentPro
```

#### From Email
```
sarah@appointmentpro.com
```

#### Greeting
```
Oi {{first_name}},
```

#### Body Copy
```
Quero te apresentar o Marcus.

O Marcus é personal trainer em Austin. Antes do AppointmentPro, 30% dos clientes dele faltavam. Ele estava perdendo mais de R$ 10 mil por mês.

Veja o que ele fez:

✅ **Conectou a agenda** (levou 2 minutos)  
✅ **Compartilhou o link de agendamento** na bio do Instagram  
✅ **Ativou lembretes automáticos por SMS** 24 horas antes das sessões

**O resultado?**
As faltas caíram de 30% pra 4% no primeiro mês. Ele recuperou 12 horas por semana e ganhou R$ 9 mil extras só naquele mês.

Veja o que o Marcus disse:

> "Eu estava cético no início, mas os lembretes funcionam. Os clientes realmente aparecem agora. Estou ganhando mais e estressando muito menos."
> — Marcus T., Personal Trainer

**Você pode fazer o mesmo.**

Se você ainda não ativou os lembretes, faça agora. Leva 30 segundos:

[Ativar Lembretes]

Já está usando lembretes? Você está na frente! Continue assim.
```

#### CTA
```
Button Text: Ativar Lembretes
Button URL: https://app.appointmentpro.com/settings/reminders
```

#### Sign-Off
```
Torcendo por você,
Sarah
Diretora de Sucesso do Cliente
AppointmentPro
```

#### Footer
```
Você está recebendo este email porque se inscreveu em appointmentpro.com.
Cancelar inscrição | Atualizar preferências

AppointmentPro Inc.
1234 Market St, Suite 500, San Francisco, CA 94103
```

---

### Design Notes
- **Template:** case-study-v1
- **Images:** Headshot of Marcus (with permission), graph showing no-show reduction
- **Mobile-friendly:** Yes
- **Plain text version:** Included

---

### Success Metrics
| Metric | Target | Measurement Window |
|--------|--------|-------------------|
| Open rate | 40% | 24 hours |
| Click rate | 25% | 24 hours |
| Reminders activated | 20% | 7 days |
| Unsubscribe rate | <0.5% | Immediate |

---

## Email 4: Feature Highlight (Advanced)

### Timing
**When:** Day 10, 11am user's timezone  
**Delay from Email 3:** 3 days

### Goal
**Primary:** Increase feature adoption (payment integration)  
**Metric:** Click rate on payment setup (target: 15%)

---

### Subject Line

**English:**
```
Get paid at booking (no more chasing clients for payment)
```

**pt-BR:**
```
Receba no agendamento (chega de correr atrás de pagamento)
```

---

### Preview Text

**English:**
```
Collect deposits or full payments automatically
```

**pt-BR:**
```
Receba sinais ou pagamentos completos automaticamente
```

---

### Email Body (English)

#### From Name
```
Sarah from AppointmentPro
```

#### From Email
```
sarah@appointmentpro.com
```

#### Greeting
```
Hi {{first_name}},
```

#### Body Copy
```
Quick question: Are you still chasing clients for payment after appointments?

Here's a better way:

**Get paid at booking** with our payment integration. Clients pay a deposit (or full amount) when they book. No awkward "Did you bring cash?" conversations.

**How it works:**

1. Connect Stripe or PayPal (takes 3 minutes)
2. Set your deposit amount (e.g., $20 or 50%)
3. Clients pay when they book
4. Money hits your account instantly

**Why our users love it:**

✅ **Reduces no-shows** — People show up when they've already paid  
✅ **Saves time** — No invoicing, no payment reminders  
✅ **Increases revenue** — Get paid upfront, improve cash flow

Lisa from Bloom Salon said:
> "I used to lose $500/month on no-shows. Now I collect a $25 deposit at booking. No-shows are basically zero, and I never chase payment anymore."

Want to try it? Set it up now:

[Connect Payment Method]

(And yes, we support both Stripe and PayPal. No hidden fees — you keep 100% minus standard payment processing.)
```

#### CTA
```
Button Text: Connect Payment Method
Button URL: https://app.appointmentpro.com/settings/payments
```

#### Sign-Off
```
Here to help,
Sarah
Head of Customer Success
AppointmentPro
```

#### Footer
```
You're receiving this because you signed up at appointmentpro.com.
Unsubscribe | Update preferences

AppointmentPro Inc.
1234 Market St, Suite 500, San Francisco, CA 94103
```

---

### Email Body (pt-BR)

#### From Name
```
Sarah da AppointmentPro
```

#### From Email
```
sarah@appointmentpro.com
```

#### Greeting
```
Oi {{first_name}},
```

#### Body Copy
```
Pergunta rápida: você ainda está correndo atrás de clientes pra receber pagamento depois das consultas?

Tem um jeito melhor:

**Receba no agendamento** com nossa integração de pagamento. Os clientes pagam um sinal (ou o valor total) quando agendam. Chega de "Você trouxe dinheiro?" constrangedor.

**Como funciona:**

1. Conecte Stripe ou PayPal (leva 3 minutos)
2. Defina o valor do sinal (ex: R$ 50 ou 50%)
3. Clientes pagam quando agendam
4. Dinheiro cai na sua conta na hora

**Por que nossos usuários adoram:**

✅ **Reduz faltas** — As pessoas aparecem quando já pagaram  
✅ **Economiza tempo** — Sem cobranças, sem lembretes de pagamento  
✅ **Aumenta receita** — Receba adiantado, melhore seu fluxo de caixa

A Lisa do Bloom Salon disse:
> "Eu perdia R$ 2.500/mês com faltas. Agora cobro R$ 50 de sinal no agendamento. As faltas são praticamente zero, e nunca mais corro atrás de pagamento."

Quer testar? Configure agora:

[Conectar Método de Pagamento]

(E sim, nós suportamos tanto Stripe quanto PayPal. Sem taxas escondidas — você fica com 100% menos as taxas padrão de processamento.)
```

#### CTA
```
Button Text: Conectar Método de Pagamento
Button URL: https://app.appointmentpro.com/settings/payments
```

#### Sign-Off
```
Aqui pra ajudar,
Sarah
Diretora de Sucesso do Cliente
AppointmentPro
```

#### Footer
```
Você está recebendo este email porque se inscreveu em appointmentpro.com.
Cancelar inscrição | Atualizar preferências

AppointmentPro Inc.
1234 Market St, Suite 500, San Francisco, CA 94103
```

---

### Design Notes
- **Template:** feature-highlight-v1
- **Images:** Screenshot of payment setup flow
- **Mobile-friendly:** Yes
- **Plain text version:** Included

---

### Success Metrics
| Metric | Target | Measurement Window |
|--------|--------|-------------------|
| Open rate | 35% | 24 hours |
| Click rate | 20% | 24 hours |
| Payment setup completed | 10% | 7 days |
| Unsubscribe rate | <0.5% | Immediate |

---

## Email 5: Trial Ending / Conversion Nudge

### Timing
**When:** Day 14 (last day of trial), 9am user's timezone  
**Delay from Email 4:** 4 days

### Goal
**Primary:** Convert trial to paid subscription  
**Metric:** Conversion rate (target: 25%)

---

### Subject Line

**English:**
```
{{first_name}}, your trial ends tonight — here's what happens next
```

**pt-BR:**
```
{{first_name}}, seu teste termina hoje — veja o que acontece agora
```

---

### Preview Text

**English:**
```
Keep everything you've built — upgrade in one click
```

**pt-BR:**
```
Mantenha tudo que você criou — faça upgrade em um clique
```

---

### Email Body (English)

#### From Name
```
Sarah from AppointmentPro
```

#### From Email
```
sarah@appointmentpro.com
```

#### Greeting
```
Hi {{first_name}},
```

#### Body Copy
```
Your 14-day trial ends tonight at midnight.

First, thank you for trying AppointmentPro. It's been awesome watching you set up your calendar, share your booking link, and start saving time.

**Here's what you've accomplished so far:**
- {{num_bookings}} appointments booked
- {{hours_saved}} hours saved on scheduling
- {{num_reminders}} automatic reminders sent

**What happens if you upgrade?**

✅ Keep everything you've built (no data lost)  
✅ Unlimited appointments every month  
✅ Continue using reminders, payments, and integrations  
✅ Cancel anytime — no long-term contract

**What happens if you don't upgrade?**

Your account will downgrade to the free plan:
- Your booking link stops working
- No more automatic reminders
- You lose access to payment integration
- All existing data is saved (you can re-activate anytime)

**Ready to keep saving 15+ hours per week?**

Upgrade now and keep everything running:

[Upgrade to Starter — $29/month]

Still on the fence? Reply to this email with any questions. I'll personally help you decide if AppointmentPro is right for you.
```

#### CTA
```
Button Text: Upgrade to Starter — $29/month
Button URL: https://app.appointmentpro.com/billing/upgrade
```

#### Sign-Off
```
Thank you for giving us a try,
Sarah
Head of Customer Success
AppointmentPro

P.S. If you decide not to upgrade, I'd love to know why. Just reply and let me know what we could've done better. Your feedback helps us improve.
```

#### Footer
```
You're receiving this because you signed up at appointmentpro.com.
Unsubscribe | Update preferences

AppointmentPro Inc.
1234 Market St, Suite 500, San Francisco, CA 94103
```

---

### Email Body (pt-BR)

#### From Name
```
Sarah da AppointmentPro
```

#### From Email
```
sarah@appointmentpro.com
```

#### Greeting
```
Oi {{first_name}},
```

#### Body Copy
```
Seu teste de 14 dias termina hoje à meia-noite.

Primeiro, obrigada por testar o AppointmentPro. Foi ótimo te ver configurar sua agenda, compartilhar seu link de agendamento e começar a economizar tempo.

**Veja o que você conseguiu até agora:**
- {{num_bookings}} consultas agendadas
- {{hours_saved}} horas economizadas em agendamentos
- {{num_reminders}} lembretes automáticos enviados

**O que acontece se você fizer upgrade?**

✅ Mantenha tudo que você criou (sem perda de dados)  
✅ Agendamentos ilimitados todo mês  
✅ Continue usando lembretes, pagamentos e integrações  
✅ Cancele quando quiser — sem contrato longo

**O que acontece se você não fizer upgrade?**

Sua conta será rebaixada pro plano grátis:
- Seu link de agendamento para de funcionar
- Sem mais lembretes automáticos
- Você perde acesso à integração de pagamento
- Todos os dados existentes são salvos (você pode reativar quando quiser)

**Pronto pra continuar economizando mais de 15 horas por semana?**

Faça upgrade agora e mantenha tudo funcionando:

[Upgrade para Starter — R$ 149/mês]

Ainda em dúvida? Responda este email com qualquer pergunta. Vou te ajudar pessoalmente a decidir se o AppointmentPro é certo pra você.
```

#### CTA
```
Button Text: Upgrade para Starter — R$ 149/mês
Button URL: https://app.appointmentpro.com/billing/upgrade
```

#### Sign-Off
```
Obrigada por nos testar,
Sarah
Diretora de Sucesso do Cliente
AppointmentPro

P.S. Se você decidir não fazer upgrade, adoraria saber por quê. Só responda e me diga o que poderíamos ter feito melhor. Seu feedback nos ajuda a melhorar.
```

#### Footer
```
Você está recebendo este email porque se inscreveu em appointmentpro.com.
Cancelar inscrição | Atualizar preferências

AppointmentPro Inc.
1234 Market St, Suite 500, San Francisco, CA 94103
```

---

### Design Notes
- **Template:** conversion-v1
- **Images:** Dynamic chart showing user's trial stats (bookings, hours saved)
- **Mobile-friendly:** Yes
- **Plain text version:** Included

---

### Success Metrics
| Metric | Target | Measurement Window |
|--------|--------|-------------------|
| Open rate | 55% | 24 hours |
| Click rate | 35% | 24 hours |
| Trial to paid conversion | 25% | 24 hours |
| Unsubscribe rate | <1% | Immediate |

---

## Sequence Exit Conditions

**User exits sequence if:**
- [x] User upgrades to paid plan
- [x] User unsubscribes
- [x] User marks as spam
- [x] Trial expires without upgrade

**Re-entry rules:**
- [x] User can re-enter sequence: No (one-time onboarding)
- [ ] If user re-activates trial after expiring, trigger reactivation sequence (separate)

---

## A/B Testing Plan

### Test 1: Subject Line Personalization (Email 1)
**Variable:** Personalization  
**Variant A:** "Welcome to AppointmentPro!"  
**Variant B:** "Welcome to AppointmentPro, {{first_name}}!"  
**Sample size:** 1,000 per variant  
**Duration:** 4 hours  
**Winner selection:** Highest open rate

### Test 2: Emoji in Subject (Email 2)
**Variable:** Emoji usage  
**Variant A:** "{{first_name}}, your first booking link is ready 🎉"  
**Variant B:** "{{first_name}}, your first booking link is ready"  
**Sample size:** 1,000 per variant  
**Duration:** 4 hours  
**Winner selection:** Highest open rate

---

## Send Time Optimization

**Default send times:**
- **Email 1 (Welcome):** Immediate (within 5 minutes of signup)
- **Email 2:** Day 3, 10am user's timezone
- **Email 3:** Day 7, 2pm user's timezone
- **Email 4:** Day 10, 11am user's timezone
- **Email 5 (Conversion):** Day 14, 9am user's timezone

**ESP send time optimization:** Enabled in Klaviyo for Emails 2-4

---

## Localization Notes

### Text Expansion (pt-BR)
- [x] All buttons tested with +25% longer text
- [x] Email width accommodates expanded paragraphs
- [x] Subject lines stay under 50 chars in both languages

### Formatting
- [x] Dates formatted correctly: Trial ends `03/15/2025` (en) → `15/03/2025` (pt-BR)
- [x] Currency formatted: `$29/month` (en) → `R$ 149/mês` (pt-BR)
- [x] Time formatted: `3:45 PM` (en) → `15h45` (pt-BR)

---

## Compliance Checklist

**CAN-SPAM (USA):**
- [x] Accurate "From" name (Sarah from AppointmentPro)
- [x] Accurate subject line (no deception)
- [x] Physical address in footer
- [x] Unsubscribe link functional
- [x] Unsubscribe processes within 10 days

**LGPD (Brazil):**
- [x] Explicit consent obtained at signup
- [x] Privacy policy linked in footer
- [x] Unsubscribe honored immediately
- [x] User can request data export/deletion

---

## Deliverability Checklist

- [x] SPF, DKIM, DMARC configured
- [x] Plain text version included for all emails
- [x] No spam trigger words in subject/body
- [x] Images optimized (under 1MB total per email)
- [x] Tested in Litmus Email Previews
- [x] Unsubscribe link tested
- [x] All links tested (no broken URLs)
- [x] Spam score under 5 (Mail Tester)
