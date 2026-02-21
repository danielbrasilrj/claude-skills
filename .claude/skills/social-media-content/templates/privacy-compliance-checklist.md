# Privacy Compliance Checklist for Social Media Content

## Pre-Publication Checklist

Complete this checklist before publishing any social media content that involves data collection, tracking, user targeting, or user-generated content.

---

## 1. Data Collection and Consent

### GDPR (EU/EEA)

- [ ] Legal basis for data processing is documented (consent, legitimate interest, contract)
- [ ] Consent is collected before any data processing (no pre-ticked boxes)
- [ ] Consent request is separate from terms of service
- [ ] Privacy policy is linked and accessible from all profile pages
- [ ] Users can withdraw consent as easily as they gave it
- [ ] Data processing register is updated with this campaign's activities

### LGPD (Brazil)

- [ ] Legal basis is identified (one of 10 LGPD bases)
- [ ] Consent is free, informed, and unambiguous
- [ ] Written consent appears in a highlighted clause (if applicable)
- [ ] Encarregado (DPO) contact information is publicly available
- [ ] DSAR process is ready to respond within 15 days
- [ ] Data processing record includes this campaign

### Both

- [ ] Minimum data principle: only collecting what is strictly necessary
- [ ] Data retention period is defined for this campaign
- [ ] Cross-border data transfer safeguards are in place (if applicable)

---

## 2. Tracking and Analytics

### Pixels and Tracking

- [ ] Meta Pixel usage is disclosed in privacy policy
- [ ] TikTok Pixel usage is disclosed in privacy policy
- [ ] Google Analytics / Tag Manager usage is disclosed
- [ ] Cookie consent banner is implemented on landing pages
- [ ] Opt-out mechanism is functional and tested
- [ ] iOS App Tracking Transparency is respected (no workarounds)
- [ ] Server-side tracking (Conversions API) is documented

### UTM and Campaign Tracking

- [ ] UTM parameters do not contain personally identifiable information (PII)
- [ ] Custom audience lists are based on consented data only
- [ ] Lookalike audiences are created from consented source audiences
- [ ] Retargeting audiences respect opt-out preferences

---

## 3. Content-Specific Compliance

### User-Generated Content (UGC)

- [ ] Written permission obtained before reposting user content
- [ ] Permission covers all platforms where content will be shared
- [ ] Credit is given to original creator (unless they prefer otherwise)
- [ ] UGC from minors is not used without parental consent
- [ ] UGC contest rules include data processing disclosure

### Testimonials and Reviews

- [ ] Testimonial is from a real customer (no fabrication)
- [ ] Customer consented to use of their testimonial
- [ ] If incentivized, disclosure is included (FTC / CONAR compliance)
- [ ] Testimonial does not contain third-party PII

### Influencer and Partnership Content

- [ ] Partnership is disclosed (#ad, #sponsored, #publi, #parceria)
- [ ] Disclosure is clear, prominent, and in the content's language
- [ ] Influencer has been briefed on privacy requirements
- [ ] Data sharing agreements are in place with influencer/agency

---

## 4. Platform-Specific Compliance

### Instagram / Meta

- [ ] Custom Audiences use only consented email/phone lists
- [ ] Ad targeting does not use sensitive categories (health, religion, politics)
- [ ] Special Ad Categories are correctly configured (if applicable)
- [ ] Automated messages comply with Meta's commerce policies

### TikTok

- [ ] Content does not target users under 13
- [ ] Restricted data processing mode enabled for CCPA regions
- [ ] Lead generation forms include privacy policy link
- [ ] Branded content toggle is enabled for paid partnerships

### WhatsApp Business

- [ ] Message templates are approved by Meta before sending
- [ ] Each language variant is submitted separately
- [ ] Marketing messages include opt-out instructions
- [ ] Opt-in was collected before sending marketing messages
- [ ] Opt-out is processed within 24 hours
- [ ] Data sharing with Meta is disclosed in privacy policy
- [ ] BSP (Business Solution Provider) has DPA in place

### Google Business Profile

- [ ] Business information is accurate and matches website
- [ ] No PII is included in public post content
- [ ] Review responses do not disclose customer details
- [ ] Photos do not contain recognizable individuals without consent

---

## 5. Minor Protection

- [ ] Content does not knowingly target users under 13 (COPPA)
- [ ] Content does not collect data from users under 18 (LGPD stricter protection)
- [ ] Age-gating is implemented where required
- [ ] Parental consent mechanisms are in place for youth-targeted campaigns
- [ ] No behavioral tracking of known minors

---

## 6. Locale-Specific Requirements

### English-Speaking Markets

| Jurisdiction | Key Requirement | Deadline |
|-------------|-----------------|----------|
| EU/EEA (GDPR) | Right to erasure | 30 days |
| UK (UK GDPR) | Same as EU GDPR | 30 days |
| California (CCPA/CPRA) | Right to opt out of sale | Immediate |
| Canada (PIPEDA) | Meaningful consent | Reasonable time |
| Australia (Privacy Act) | APP 6 — use/disclosure limits | Reasonable time |

### Brazil (LGPD)

| Requirement | Detail |
|-------------|--------|
| DSAR response | 15 days (faster than GDPR) |
| DPO required | Yes, for all controllers |
| Anonymized data | Exempt if truly anonymized |
| International transfer | Requires adequacy, consent, or contractual clauses |
| Fines | Up to 2% of Brazilian revenue, capped at R$50M per violation |

---

## 7. Documentation Requirements

For each campaign, maintain:

- [ ] Record of processing activities (ROPA)
- [ ] Consent collection evidence (timestamp, method, scope)
- [ ] Data processing agreements with all third parties
- [ ] Privacy impact assessment (for high-risk processing)
- [ ] Opt-out/unsubscribe log
- [ ] Incident response plan (breach notification within 72h GDPR / reasonable time LGPD)

---

## Sign-Off

```yaml
compliance_review:
  campaign_name: ""
  reviewer: ""
  date: ""
  jurisdictions: []  # e.g., [GDPR, LGPD, CCPA]
  status: ""         # compliant | needs_review | non_compliant
  notes: ""
```
