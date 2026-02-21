# Experiment Plan: Pricing Page Social Proof

**Date:** 2026-02-21
**Owner:** Growth Team (Sarah Chen)
**Status:** Completed

---

## 1. Hypothesis

**If we** add a "Join 50,000+ businesses" social proof badge above the pricing table,
**then** trial start rate will increase by 12%,
**because** social proof reduces perceived risk for new visitors and builds credibility (supported by Baymard Institute research showing 10-15% lift from trust signals on pricing pages).

---

## 2. ICE Prioritization Score

| Dimension | Score (1-10) | Rationale |
|-----------|--------------|-----------|
| **Impact** | 8 | Pricing page is critical conversion funnel step; all free trial signups flow through it. Even 5% lift = $40k/month ARR gain. |
| **Confidence** | 7 | Strong external evidence (Booking.com case study, Baymard research). We haven't tested social proof before, but multiple competitors use it. |
| **Ease** | 9 | Frontend-only change, existing React component. Designer estimates 2 hours, engineer estimates 4 hours. |
| **ICE Score** | **504** | High priority — clear business case, low implementation risk. |

---

## 3. Experiment Details

### Type
- [x] A/B Test (1 variant)
- [ ] A/B/n Test (multiple variants)
- [ ] Multivariate Test
- [ ] Multi-armed Bandit

### Target Audience
**Who sees this test?**
- [x] All users visiting /pricing
- [ ] New users only
- [ ] Returning users only
- [ ] Specific segment: N/A

**Exclusions:**
- Existing paying customers (they see /billing instead of /pricing)
- Users on mobile app (pricing page is web-only)

### Variants

#### **Control (A)**
**Description:** Current pricing page with three-tier pricing table (Starter, Professional, Enterprise). No social proof or trust signals above fold.

**Screenshot:**
![Control pricing page](https://via.placeholder.com/800x600/f0f0f0/333333?text=Control+Pricing+Page)

**Key elements:**
- H1: "Simple, transparent pricing"
- Subheadline: "Start free, upgrade when you're ready"
- Three pricing cards with features
- "Start Free Trial" CTA button (blue)

---

#### **Variant B: Social Proof Badge**
**Description:** Same layout as control, but add social proof badge above pricing table.

**Screenshot:**
![Variant B with social proof](https://via.placeholder.com/800x600/f0f0f0/333333?text=Variant+B+Social+Proof)

**Badge design:**
- Text: "Join 50,000+ businesses already using [Product]"
- Icon: Small badge/checkmark icon
- Placement: Centered, 32px above pricing table
- Styling: Light gray background, 14px font, subtle

**Key differences from control:**
- Adds social proof badge (new element)
- No other changes to layout, copy, or CTAs

---

## 4. Metrics

### Primary Metric (Decision Metric)
**Metric:** Trial Start Rate

**Definition:** (Users who clicked "Start Free Trial" on any pricing card) / (Users who viewed /pricing page)

**Current baseline:** 8.2% (based on last 60 days, n=42,000 visitors)

**Minimum Detectable Effect (MDE):** 12% relative improvement (8.2% → 9.2% absolute)

**Why this MDE?**
12% is the median lift from social proof tests in our industry (based on 5 case studies). We need at least 10% lift to justify ongoing A/B testing program investment.

---

### Secondary Metrics (Learning Metrics)

| Metric | Definition | Baseline | Expected Direction |
|--------|------------|----------|-------------------|
| Time on Page | Median seconds on /pricing | 42s | ↔ Neutral (no expected change) |
| Scroll Depth | % who scroll to pricing table | 78% | ↔ Neutral |
| Pricing Card Clicks | Clicks on any card (not just CTA) | 15.3% | ↑ Increase (more engagement) |
| Exit Rate | % who leave site from /pricing | 64% | ↓ Decrease (fewer exits if converting more) |

---

### Guardrail Metrics (Must Not Degrade)

| Metric | Threshold | Why it matters |
|--------|-----------|----------------|
| Page Load Time | +200ms | Slow pages kill conversion; 100ms delay = 1% CR drop |
| Error Rate | >0.1% | JavaScript errors would invalidate test |
| Activation Rate (Day 7) | -5% | Ensure trial users actually activate product |

---

## 5. Sample Size & Duration

### Traffic Allocation
- **Split:** 50% Control / 50% Variant B
- **Ramp plan:**
  - Day 1: 10% traffic (smoke test)
  - Day 2-14: 100% traffic

### Sample Size Calculation

**Inputs:**
- Baseline conversion rate: 8.2%
- Minimum Detectable Effect (MDE): 12% relative (0.98% absolute)
- Significance level (α): 0.05 (95% confidence)
- Statistical power (1-β): 0.80 (80% power)

**Required sample size:** 7,850 users per variant ([Evan Miller calculator](https://www.evanmiller.org/ab-testing/sample-size.html))

**Total sample needed:** 15,700 users

---

### Duration Estimate

**Current traffic:** 1,400 /pricing visitors per day

**Estimated test duration:** 15,700 / 1,400 = 11.2 days → **12 days** (round up to full business cycles)

**Planned start date:** 2026-02-24 (Monday)
**Planned end date:** 2026-03-07 (Friday, 12 days later)

**Seasonality considerations:**
- No major holidays in this period
- SaaS buying typically slows last week of month (March 24-31), so ending March 7 avoids this
- Traffic is consistent Monday-Friday, drops 40% on weekends (we'll filter weekends in analysis)

---

## 6. Implementation Plan

### Engineering Tasks
- [x] Create SocialProofBadge React component
- [x] Add feature flag `pricing_social_proof` to LaunchDarkly
- [x] Modify PricingPage.tsx to conditionally render badge
- [x] Add event tracking: `pricing_page_viewed`, `social_proof_badge_viewed`
- [x] Configure 50/50 split in LaunchDarkly

**Estimated engineering effort:** 0.5 developer-days

**Owner:** Jake Martinez

---

### Design Tasks
- [x] Design social proof badge (3 variants reviewed, 1 selected)
- [x] Create mobile responsive version
- [x] Get PM approval on final design

**Owner:** Emma Liu

---

### QA Checklist
Before launch, verify:
- [x] Both variants render correctly on Chrome, Safari, Firefox
- [x] Mobile (iOS + Android) rendering is correct
- [x] Tracking events fire correctly in both variants
- [x] Feature flag toggles badge visibility as expected
- [x] 50/50 split is working (checked first 1,000 users: 503/497 split ✓)
- [x] No JavaScript errors in console
- [x] Page load time delta: +12ms (well within budget)

---

## 7. Decision Criteria

### Ship Variant If:
1. Trial start rate improves by ≥12% with p < 0.05
2. No guardrail metrics degraded (page load <+200ms, error rate <0.1%)
3. Effect is consistent across desktop/mobile (no interaction effect)
4. Activation rate (D7) unchanged or improved

### Keep Control If:
1. No statistically significant difference (p ≥ 0.05)
2. Improvement exists but below 10% threshold
3. Desktop shows lift but mobile shows negative movement

### Stop Early If:
1. Error rate exceeds 0.1%
2. Trial start rate drops >5% with p < 0.05
3. Implementation bug discovered (e.g., badge blocks CTA on some browsers)

---

## 8. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Badge looks "spammy" and reduces trust | Medium | High | A/B test minimizes risk; we can revert instantly if negative |
| 50k number seems inflated to users | Low | Medium | Number is accurate (pulled from production DB); we update quarterly |
| Not enough mobile traffic to detect effect | Low | Medium | 60% of traffic is desktop; desktop-only analysis still powers test adequately |
| Weekend traffic skews results | Medium | Low | Exclude weekends from final analysis (weekday behavior more predictive) |

---

## 9. Rollout Plan (Post-Experiment)

**If variant wins:**
- [x] Ship to 100% (remove feature flag)
- [x] Update PricingPage component to include badge permanently
- [x] Add to component library (SocialProofBadge.tsx)
- [x] Update customer count quarterly (next update: May 2026)
- [x] Share results in #growth Slack channel and weekly all-hands

**If control wins:**
- [ ] Archive experiment in Notion
- [ ] Document why social proof failed
- [ ] Test alternative trust signals (testimonials, security badges, press logos)

**Timeline:** 2 days post-experiment

---

## 10. Results

**Actual end date:** 2026-03-07
**Total sample size:** 16,240 users (8,105 control, 8,135 variant)

### Primary Metric Results

| Variant | Sample Size | Trial Starts | Trial Start Rate | Relative Change | P-Value | Significant? |
|---------|-------------|--------------|------------------|-----------------|---------|--------------|
| Control | 8,105 | 658 | 8.12% | — | — | — |
| Variant B | 8,135 | 763 | 9.38% | **+15.5%** | 0.003 | **Yes** |

**Interpretation:**
✅ **SHIP VARIANT.** Social proof badge increased trial start rate from 8.12% to 9.38%, a 15.5% relative improvement (1.26% absolute lift). Result is statistically significant (p=0.003) and exceeds our 12% MDE threshold. At current traffic levels, this equals ~18 additional trials per day = ~$45k/month incremental ARR (assuming 25% trial→paid conversion).

---

### Secondary Metrics Results

| Metric | Control | Variant | Change | P-Value | Notes |
|--------|---------|---------|--------|---------|-------|
| Time on Page | 41s | 43s | +4.9% | 0.18 | Neutral, not significant |
| Scroll Depth | 77.8% | 78.4% | +0.8% | 0.64 | Neutral |
| Pricing Card Clicks | 15.1% | 16.8% | +11.3% | 0.02 | Significant increase in engagement |
| Exit Rate | 64.2% | 61.7% | -3.9% | 0.01 | Significant decrease (good — fewer exits) |

**Key insight:** Variant not only improved conversion but also increased engagement (more card clicks) and reduced exits. Social proof is drawing users deeper into funnel.

---

### Segment Analysis

| Segment | Control CR | Variant CR | Relative Change | P-Value | Significant? |
|---------|------------|------------|-----------------|---------|--------------|
| Desktop | 9.2% | 10.8% | +17.4% | 0.005 | Yes |
| Mobile | 6.4% | 7.1% | +10.9% | 0.12 | No (underpowered) |
| New Users | 7.1% | 8.5% | +19.7% | 0.001 | Yes (strongest effect) |
| Returning | 11.3% | 12.6% | +11.5% | 0.18 | No |

**Key insights:**
- Effect is strongest on new users (19.7% lift) — makes sense, social proof reduces uncertainty for first-time visitors
- Desktop shows significant lift; mobile trend is positive but didn't reach significance (smaller sample)
- Returning users show neutral effect (they already trust us, social proof is redundant)

**Recommendation:** Ship to all users. Consider testing mobile-specific variant (smaller badge, different placement) to amplify mobile effect.

---

### Guardrail Metrics

| Metric | Control | Variant | Change | Violated? |
|--------|---------|---------|--------|-----------|
| Page Load Time | 1.24s | 1.26s | +16ms | No (threshold: +200ms) |
| Error Rate | 0.03% | 0.04% | +0.01pp | No (threshold: 0.1%) |
| Activation Rate (D7) | 68.2% | 69.1% | +1.3% | No (no degradation) |

✅ All guardrails passed. No negative side effects.

---

## 11. Learnings & Next Steps

### Key Learnings
1. **Social proof works for new users:** 19.7% lift on new visitors vs. 11.5% on returning. Future tests should focus on first-time visitor experience.
2. **Magnitude matters:** We tested "50,000+ businesses" — next test could explore if larger numbers (100k, 250k) amplify effect.
3. **Placement is key:** Badge above pricing table worked. Could test in-card placement ("Join 50k businesses on the Starter plan") for per-tier social proof.

### Follow-Up Experiments
1. **Test customer logos** — Add "Trusted by [Logo] [Logo] [Logo]" below social proof number (ICE: 7×6×8 = 336)
2. **Test dynamic social proof** — "23 people started a trial in the last hour" (urgency + social proof combo) (ICE: 8×5×6 = 240)
3. **Test mobile-specific badge** — Smaller, icon-only version for mobile to reduce visual clutter (ICE: 6×7×9 = 378)

---

## 12. Appendix

**Links:**
- Experiment dashboard: https://app.launchdarkly.com/experiments/pricing-social-proof
- Design mocks: https://figma.com/pricing-social-proof-variants
- Implementation PR: https://github.com/company/app/pull/3847
- Results deck: https://docs.google.com/presentation/d/abc123

**Stakeholders:**
- Sarah Chen, Growth PM (owner)
- Jake Martinez, Frontend Engineer
- Emma Liu, Product Designer
- David Park, Data Analyst
- Lauren Wu, VP Product

**Cost/Benefit:**
- Engineering cost: 4 hours = $400
- Design cost: 2 hours = $200
- Incremental ARR: $45k/month = $540k/year
- ROI: 900x
