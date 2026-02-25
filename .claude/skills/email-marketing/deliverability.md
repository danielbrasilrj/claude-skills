# Deliverability Best Practices

## Email Authentication (SPF, DKIM, DMARC)

### SPF (Sender Policy Framework)

**What it is:** DNS record that lists authorized sending servers
**How to set up:** Add TXT record to your domain's DNS
**Example:**

```
v=spf1 include:_spf.google.com include:servers.mcsv.net ~all
```

### DKIM (DomainKeys Identified Mail)

**What it is:** Cryptographic signature proving email authenticity
**How to set up:** Generate key pair via your ESP, add public key to DNS
**Where to find:** Your ESP (Klaviyo, HubSpot, etc.) provides DKIM records

### DMARC (Domain-based Message Authentication)

**What it is:** Policy telling receivers what to do with unauthenticated emails
**How to set up:** Add TXT record specifying policy (none, quarantine, reject)
**Example:**

```
v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com
```

**Why it matters:** Emails without SPF/DKIM/DMARC are flagged as spam by Gmail, Outlook, etc.

---

## List Hygiene

**Clean your list regularly:**

| Action                          | Frequency       | Reason                                   |
| ------------------------------- | --------------- | ---------------------------------------- |
| Remove hard bounces             | Immediately     | Invalid addresses hurt sender reputation |
| Remove inactive users           | Every 6 months  | Low engagement signals spam to ISPs      |
| Remove unengaged (never opened) | Every 12 months | Clean list = higher deliverability       |
| Validate new signups            | On signup       | Prevent fake/typo emails                 |

**Engagement thresholds:**

- **Hard bounce:** Remove immediately
- **Soft bounce:** Remove after 3 consecutive bounces
- **Never opened (6+ months):** Send re-engagement, then remove
- **Never clicked (12+ months):** Consider removing or re-confirming

---

## Spam Trigger Words to Avoid

**High-risk words:**

- Free, winner, cash, prize, guarantee
- Click here, act now, urgent, limited time
- 100% free, risk-free, no obligation
- $$$, !!!, ALL CAPS

**Medium-risk phrases:**

- Congratulations, you've been selected
- Order now, buy now, call now
- Once in a lifetime, special promotion

**Best practice:** Use spam checker tools before sending (Mail Tester, Litmus Spam Testing)

---

## Sender Reputation

**Factors affecting reputation:**

1. **Bounce rate** -- Keep under 2%
2. **Spam complaints** -- Keep under 0.1%
3. **Engagement** -- Higher open/click rates = better reputation
4. **Consistency** -- Send regularly (not sporadically)
5. **List quality** -- Avoid purchased/scraped lists

**How to monitor:**

- Google Postmaster Tools (Gmail deliverability)
- Microsoft SNDS (Outlook deliverability)
- Sender Score (overall reputation score 0-100)

**Recovery from poor reputation:**

- Pause sending for 7-14 days
- Clean list aggressively (remove all unengaged)
- Gradually warm up sending (start with 10% of list)
- Focus on highest engagement segments first

---

## IP Warming (For Dedicated IPs)

If you send from a dedicated IP, warm it up gradually:

| Day | Send Volume | Notes                     |
| --- | ----------- | ------------------------- |
| 1   | 50-100      | Most engaged segment only |
| 2   | 200-500     |                           |
| 3   | 1,000       |                           |
| 7   | 5,000       |                           |
| 14  | 10,000      |                           |
| 30  | 50,000+     | Full volume               |

**Best practices:**

- Send to most engaged users first
- Monitor bounces and spam complaints daily
- Pause if bounce rate exceeds 5%

## Email Metrics Benchmarks

| Metric              | Good  | Average  | Poor  |
| ------------------- | ----- | -------- | ----- |
| Open rate           | 25%+  | 15-25%   | <15%  |
| Click rate          | 3%+   | 1-3%     | <1%   |
| Bounce rate         | <2%   | 2-5%     | >5%   |
| Unsubscribe rate    | <0.5% | 0.5-1%   | >1%   |
| Spam complaint rate | <0.1% | 0.1-0.5% | >0.5% |

**Note:** Benchmarks vary by industry and email type (transactional vs promotional)
