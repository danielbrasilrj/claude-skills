# Experiment Plan: [Experiment Name]

**Date:** [YYYY-MM-DD]
**Owner:** [Name/Team]
**Status:** [Planning / In Progress / Completed / Archived]

---

## 1. Hypothesis

**If we** [specific change to product/feature],
**then** [primary metric] will [increase/decrease] by [X%],
**because** [user behavior rationale or evidence].

**Example:**
If we add social proof (customer count) below the CTA on the pricing page, then conversion rate will increase by 12%, because social proof reduces perceived risk and builds trust (supported by 3 prior studies showing 10-15% lifts).

---

## 2. ICE Prioritization Score

| Dimension | Score (1-10) | Rationale |
|-----------|--------------|-----------|
| **Impact** | [X] | [Why this score? What's the potential business value?] |
| **Confidence** | [X] | [What evidence supports this hypothesis?] |
| **Ease** | [X] | [How much effort to implement?] |
| **ICE Score** | **[I × C × E]** | [Total score — should be >300 to prioritize] |

---

## 3. Experiment Details

### Type
- [ ] A/B Test (1 variant)
- [ ] A/B/n Test (multiple variants)
- [ ] Multivariate Test
- [ ] Multi-armed Bandit

### Target Audience
**Who sees this test?**
- [ ] All users
- [ ] New users only
- [ ] Returning users only
- [ ] Specific segment: [describe]

**Exclusions:**
[Any users who should NOT see this test? E.g., enterprise customers, logged-out users, mobile app users]

### Variants

#### **Control (A)**
**Description:** [Current experience]

**Screenshot/Mock:** [Link or attach image]

**Implementation notes:** [Any technical details]

---

#### **Variant B** [give it a descriptive name]
**Description:** [Proposed change]

**Screenshot/Mock:** [Link or attach image]

**Implementation notes:** [Any technical details]

**Key differences from control:**
- [Change 1]
- [Change 2]
- [Change 3]

---

#### **Variant C** (if applicable)
**Description:** [Second alternative]

**Screenshot/Mock:** [Link or attach image]

**Implementation notes:** [Any technical details]

**Key differences from control:**
- [Change 1]
- [Change 2]

---

## 4. Metrics

### Primary Metric (Decision Metric)
**Metric:** [e.g., Conversion Rate, Add-to-Cart Rate, Trial Start Rate]

**Definition:** [Exactly how is this calculated? Numerator and denominator.]
Example: Trial Start Rate = (Users who clicked "Start Trial") / (Users who viewed pricing page)

**Current baseline:** [X%] (based on [time period, e.g., last 30 days])

**Minimum Detectable Effect (MDE):** [X%] relative improvement ([Y%] absolute)
Example: 10% relative improvement = 5.0% → 5.5% absolute

**Why this MDE?** [Is this the smallest improvement you care about? Or limited by traffic?]

---

### Secondary Metrics (Learning Metrics)
These inform interpretation but don't determine ship/no-ship decision.

| Metric | Definition | Baseline | Expected Direction |
|--------|------------|----------|-------------------|
| [Metric 1] | [How calculated] | [Current value] | [↑ Increase / ↓ Decrease / ↔ Neutral] |
| [Metric 2] | [How calculated] | [Current value] | [↑ Increase / ↓ Decrease / ↔ Neutral] |
| [Metric 3] | [How calculated] | [Current value] | [↑ Increase / ↓ Decrease / ↔ Neutral] |

---

### Guardrail Metrics (Must Not Degrade)
If any of these metrics degrade beyond threshold, STOP test immediately.

| Metric | Threshold | Why it matters |
|--------|-----------|----------------|
| [e.g., Page Load Time] | [e.g., +500ms] | [User experience degradation] |
| [e.g., Error Rate] | [e.g., >0.5%] | [Technical stability] |
| [e.g., Revenue per User] | [e.g., -5%] | [Business viability] |

---

## 5. Sample Size & Duration

### Traffic Allocation
- **Split:** [e.g., 50% Control / 50% Variant B]
- **Ramp plan (if applicable):**
  - Week 1: 10% traffic
  - Week 2: 50% traffic
  - Week 3+: 100% traffic

### Sample Size Calculation

**Inputs:**
- Baseline conversion rate: [X%]
- Minimum Detectable Effect (MDE): [Y%] relative ([Z%] absolute)
- Significance level (α): 0.05 (95% confidence)
- Statistical power (1-β): 0.80 (80% power)

**Required sample size:** [N] users per variant ([Source: Evan Miller calculator](https://www.evanmiller.org/ab-testing/sample-size.html))

**Total sample needed:** [N × number of variants]

---

### Duration Estimate

**Current traffic:** [X] eligible users per day

**Estimated test duration:** [N total users / X daily traffic] = [Y days]

**Planned start date:** [YYYY-MM-DD]
**Planned end date:** [YYYY-MM-DD] (may extend if sample size not reached)

**Seasonality considerations:** [Any holidays, sales events, or known traffic fluctuations during test period?]

---

## 6. Implementation Plan

### Engineering Tasks
- [ ] [Task 1: e.g., Implement variant UI in React component]
- [ ] [Task 2: e.g., Add feature flag for experiment toggle]
- [ ] [Task 3: e.g., Set up event tracking for primary metric]
- [ ] [Task 4: e.g., Configure A/B test in platform (Optimizely/LaunchDarkly/etc.)]

**Estimated engineering effort:** [X] developer-days

**Owner:** [Engineer name]

---

### Design Tasks
- [ ] [Task 1: e.g., Create high-fidelity mocks for variant]
- [ ] [Task 2: e.g., Design mobile responsive version]
- [ ] [Task 3: e.g., Get stakeholder approval on designs]

**Owner:** [Designer name]

---

### QA Checklist
Before launch, verify:
- [ ] Both variants render correctly on Chrome, Safari, Firefox
- [ ] Mobile (iOS + Android) rendering is correct
- [ ] Tracking events fire correctly in both variants
- [ ] Feature flag toggles variants as expected
- [ ] 50/50 split is working (check first 1000 users)
- [ ] No JavaScript errors in console
- [ ] Page load time is within acceptable range (<3s)

---

## 7. Decision Criteria

### Ship Variant If:
1. Primary metric improves by ≥[MDE]% with p < 0.05
2. No guardrail metrics degraded beyond threshold
3. Effect is consistent across key segments (desktop/mobile, new/returning)
4. Minimum sample size reached

### Keep Control If:
1. No statistically significant difference (p ≥ 0.05) after reaching full sample size
2. Variant shows improvement but below MDE threshold
3. Any guardrail metric violated

### Stop Early If:
1. Guardrail metric degrades beyond threshold
2. Primary metric shows significant negative movement (p < 0.05)
3. Implementation bug discovered that invalidates results

---

## 8. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [e.g., Variant breaks checkout flow] | [Low/Med/High] | [Low/Med/High] | [Mitigation plan] |
| [e.g., Not enough traffic to reach sample size] | [Low/Med/High] | [Low/Med/High] | [Mitigation plan] |
| [e.g., Seasonal traffic spike skews results] | [Low/Med/High] | [Low/Med/High] | [Mitigation plan] |

---

## 9. Rollout Plan (Post-Experiment)

**If variant wins:**
- [ ] Remove feature flag, ship variant to 100%
- [ ] Update design system / component library
- [ ] Document learnings in [location]
- [ ] Communicate results to stakeholders

**If control wins:**
- [ ] Archive experiment
- [ ] Document why variant failed
- [ ] Identify follow-up hypotheses

**Timeline:** [X] days post-experiment

---

## 10. Results (Fill out after experiment completes)

**Actual end date:** [YYYY-MM-DD]
**Total sample size:** [N] users ([X] control, [Y] variant)

### Primary Metric Results

| Variant | Sample Size | Conversion Rate | Relative Change | P-Value | Significant? |
|---------|-------------|-----------------|-----------------|---------|--------------|
| Control | [N] | [X%] | — | — | — |
| Variant | [N] | [Y%] | [+Z%] | [p-value] | [Yes/No] |

**Interpretation:** [What does this result mean? Ship or keep control?]

---

### Secondary Metrics Results

| Metric | Control | Variant | Change | P-Value | Notes |
|--------|---------|---------|--------|---------|-------|
| [Metric 1] | [X] | [Y] | [+Z%] | [p] | [Interpretation] |
| [Metric 2] | [X] | [Y] | [+Z%] | [p] | [Interpretation] |

---

### Segment Analysis

Did the variant perform differently across segments?

| Segment | Control CR | Variant CR | Relative Change | Significant? |
|---------|------------|------------|-----------------|--------------|
| Desktop | [X%] | [Y%] | [+Z%] | [Yes/No] |
| Mobile | [X%] | [Y%] | [+Z%] | [Yes/No] |
| New Users | [X%] | [Y%] | [+Z%] | [Yes/No] |
| Returning | [X%] | [Y%] | [+Z%] | [Yes/No] |

**Key insights:** [Any segment-specific findings?]

---

### Guardrail Metrics

| Metric | Control | Variant | Change | Violated? |
|--------|---------|---------|--------|-----------|
| [Metric 1] | [X] | [Y] | [+Z%] | [Yes/No] |
| [Metric 2] | [X] | [Y] | [+Z%] | [Yes/No] |

---

## 11. Learnings & Next Steps

### Key Learnings
1. [What did we learn about user behavior?]
2. [What worked? What didn't?]
3. [Any unexpected results?]

### Follow-Up Experiments
Based on this result, what should we test next?

1. [Hypothesis 1]
2. [Hypothesis 2]
3. [Hypothesis 3]

---

## 12. Appendix

**Links:**
- Experiment dashboard: [URL]
- Design mocks: [Figma link]
- Implementation PR: [GitHub link]
- Results deck: [Google Slides link]

**Stakeholders:**
- [Name 1, Role]
- [Name 2, Role]
- [Name 3, Role]
