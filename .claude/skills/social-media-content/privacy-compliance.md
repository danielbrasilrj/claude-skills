# Privacy Compliance Deep Reference

## GDPR Summary (EU/EEA)

| Requirement            | Implementation                                                                  |
| ---------------------- | ------------------------------------------------------------------------------- |
| Lawful basis           | Document for each processing activity (consent, legitimate interest, contract)  |
| Consent                | Must be freely given, specific, informed, unambiguous; pre-ticked boxes invalid |
| Right to erasure       | Must delete within 30 days of request                                           |
| Data portability       | Provide data in machine-readable format on request                              |
| DPO                    | Required for large-scale processing of personal data                            |
| Breach notification    | 72 hours to supervisory authority                                               |
| Cross-border transfers | Adequacy decision, SCCs, or BCRs required                                       |

## LGPD Summary (Brazil)

| Requirement             | Implementation                                                             |
| ----------------------- | -------------------------------------------------------------------------- |
| Legal basis             | 10 legal bases (similar to GDPR but includes credit protection)            |
| Consent                 | Must be free, informed, unambiguous; written must be in highlighted clause |
| DSAR response           | 15 days (shorter than GDPR's 30)                                           |
| DPO (Encarregado)       | Required for all controllers (no size exemption in original law)           |
| ANPD                    | National Data Protection Authority — can impose fines up to 2% of revenue  |
| International transfers | Adequacy, contractual clauses, or specific consent                         |

## Platform-Specific Privacy Rules

**Instagram/Meta Ads**:

- Custom Audiences require consent documentation
- Pixel tracking must be disclosed in privacy policy
- iOS 14.5+ App Tracking Transparency reduces targeting
- Use Conversions API as server-side complement

**TikTok**:

- TikTok Pixel similar rules to Meta Pixel
- Restricted data processing mode for CCPA compliance
- No targeting of users under 13

**WhatsApp Business**:

- End-to-end encryption does NOT apply to Business API (messages pass through BSP)
- Must disclose data sharing with Meta in privacy policy
- Template messages reviewed for compliance per language
- Opt-out must be processed within 24 hours
