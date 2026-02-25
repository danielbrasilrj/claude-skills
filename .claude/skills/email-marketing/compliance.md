# CAN-SPAM and LGPD Compliance

## CAN-SPAM (USA)

**Required elements:**

1. **Accurate "From" name** -- Real person or company name
2. **Accurate subject line** -- No deceptive subjects
3. **Physical address** -- Include mailing address in footer
4. **Unsubscribe link** -- Clear, functional, processes within 10 days
5. **Label ads clearly** -- If email is promotional

**Penalties:** Up to $46,517 per violation

**Example footer:**

```
(c) 2025 YourCompany Inc.
1234 Main St, Suite 100, San Francisco, CA 94105

You're receiving this because you signed up at yoursite.com.
Unsubscribe | Update preferences
```

---

## LGPD (Brazil)

**Key requirements:**

1. **Explicit consent** -- Users must opt-in (no pre-checked boxes)
2. **Purpose limitation** -- Only use data for stated purpose
3. **Data access rights** -- Users can request their data
4. **Right to deletion** -- Users can request data deletion
5. **Data portability** -- Users can export their data

**Consent language (pt-BR):**

```
[ ] Eu autorizo o recebimento de emails promocionais da [Empresa].
  Li e aceito a Politica de Privacidade.
```

**Penalties:** Up to 2% of revenue (max R$50 million per violation)

---

## Double Opt-In Best Practice

**Process:**

1. User submits email on form
2. Send confirmation email: "Confirm your subscription"
3. User clicks confirmation link
4. Add to active list
5. Send welcome email

**Benefits:**

- LGPD compliant (explicit consent)
- Reduces fake/typo emails
- Higher engagement (confirmed interest)

**Example confirmation email:**

```
Subject: Confirme sua inscricao

Ola!

Clique no link abaixo para confirmar que voce quer receber nossos emails:

[Confirmar Inscricao]

Se voce nao se inscreveu, ignore este email.
```

---

## Unsubscribe Best Practices

**Requirements:**

- One-click unsubscribe (no login required)
- Processes within 10 business days (CAN-SPAM) or immediately (best practice)
- Confirmation message after unsubscribe
- No "Are you sure?" guilt trips (one confirmation max)

**Example unsubscribe flow:**

1. User clicks "Unsubscribe"
2. Lands on page: "You've been unsubscribed. We're sorry to see you go."
3. Optional: "Want to update preferences instead?" (link to preference center)
4. Remove from list immediately
