# A/B Test Generator Reference Guide

## ICE Scoring Framework Deep Dive

### Impact (1-10)

Impact measures the potential business value if the experiment succeeds. Consider both magnitude and breadth of the change.

**Scoring Guidelines:**

| Score | Description | Examples |
|-------|-------------|----------|
| 1-3 | **Marginal impact** — affects a small user segment or secondary metric | Changing button radius from 4px to 6px; adjusting footer link color |
| 4-6 | **Moderate impact** — meaningful improvement to a core metric for a subset of users | Improving checkout form validation messages; adding social proof below CTA |
| 7-8 | **High impact** — significant improvement to a primary business metric | Redesigning entire checkout flow; adding guest checkout option |
| 9-10 | **Transformational impact** — potential to fundamentally change key business metrics | New pricing model; complete onboarding reimagination; removing signup friction entirely |

**Impact Multipliers:**
- Traffic volume affected (homepage = higher impact than settings page)
- Metric proximity to revenue (conversion > engagement > awareness)
- Reversibility (irreversible changes carry higher stakes)

### Confidence (1-10)

Confidence reflects your certainty that the change will produce the expected result. Base this on evidence, not hope.

**Scoring Guidelines:**

| Score | Evidence Level | Examples |
|-------|---------------|----------|
| 1-3 | **Pure speculation** — gut feeling, no supporting data | "Users might prefer blue buttons because blue is calming" |
| 4-5 | **Weak signals** — qualitative feedback from <10 users, unvalidated assumptions | "A few customer support tickets mentioned this issue" |
| 6-7 | **Moderate evidence** — user research with 10+ participants, industry benchmarks, A/B test results from similar products | "Baymard Institute reports 70% cart abandonment due to unexpected shipping costs" |
| 8-9 | **Strong evidence** — previous A/B test results on same product, quantitative user behavior data | "We tested this on mobile last quarter and saw 15% lift" |
| 10 | **Near certainty** — replicating a proven winner from prior testing or established laws (e.g., removing broken functionality) | "Fixing broken checkout button that currently shows JS error" |

**Common Confidence Killers:**
- No user research conducted
- Assumption based on competitor copying
- "Best practice" claims without data
- Internal stakeholder preferences

### Ease (1-10)

Ease measures implementation complexity: engineering time, design work, dependencies, and risk of bugs.

**Scoring Guidelines:**

| Score | Effort | Examples |
|-------|--------|----------|
| 1-3 | **Weeks** — multi-team coordination, backend changes, new infrastructure | Building recommendation engine; implementing personalization platform |
| 4-5 | **Several days** — frontend + backend work, third-party integration | Adding live chat widget; implementing OAuth login |
| 6-7 | **1-2 days** — frontend-only work with existing components | Reordering form fields; changing CTA copy and color |
| 8-9 | **Hours** — copy changes, CSS tweaks, feature flag toggles | Headline A/B test; button color change; hiding existing element |
| 10 | **Minutes** — pure copy changes with no code | Email subject line test; ad headline test |

**Ease Reducers:**
- Cross-team dependencies
- Need for legal/compliance review
- Technical debt in affected codebase
- Mobile app changes (requires app store approval)

### ICE Score Calculation

```
ICE Score = Impact × Confidence × Ease
Maximum possible score: 10 × 10 × 10 = 1000
```

**Decision Framework:**

| ICE Score | Priority | Action |
|-----------|----------|--------|
| 500+ | **Run immediately** | Clear winner, allocate resources now |
| 300-499 | **Backlog** | Strong candidate, run when capacity allows |
| 100-299 | **Consider** | May be worth running if aligned with strategic goals |
| <100 | **Reject** | Not worth the effort; focus elsewhere |

**Example Scored Hypotheses:**

1. **High-scoring experiment (ICE = 560)**
   - *Hypothesis*: Adding "Free shipping over $50" banner will increase AOV by 15%
   - Impact: 8 (directly affects revenue, applies to all users)
   - Confidence: 7 (similar tests show 10-20% lifts)
   - Ease: 10 (banner copy change only)

2. **Medium-scoring experiment (ICE = 192)**
   - *Hypothesis*: Redesigning product page layout will increase add-to-cart rate by 10%
   - Impact: 8 (core conversion metric)
   - Confidence: 4 (no prior data, gut feeling)
   - Ease: 6 (frontend-only, 2 days work)

3. **Low-scoring experiment (ICE = 60)**
   - *Hypothesis*: AI-powered product recommendations will increase repeat purchase rate by 25%
   - Impact: 10 (major revenue impact if true)
   - Confidence: 3 (no proof this will work for our product)
   - Ease: 2 (requires ML infrastructure, weeks of work)

---

## Statistical Significance and Sample Size

### Core Statistical Concepts

**Minimum Detectable Effect (MDE):**
The smallest change you care about detecting. Smaller MDEs require exponentially larger sample sizes.

- **5% MDE** — detect a change from 10% to 10.5% conversion rate
- **10% MDE** — detect a change from 10% to 11% conversion rate
- **20% MDE** — detect a change from 10% to 12% conversion rate

**Rule of thumb**: Don't test for <5% MDE unless you have massive traffic. Most businesses should target 10-20% MDE.

**Significance Level (α):**
Probability of false positive (declaring a winner when there's no real difference).
- Standard: **α = 0.05** (95% confidence)
- Conservative: **α = 0.01** (99% confidence, requires larger samples)

**Statistical Power (1-β):**
Probability of detecting a true difference when it exists.
- Standard: **80% power** (β = 0.20)
- High power: **90% power** (β = 0.10, requires larger samples)

### Sample Size Calculation

Use Evan Miller's calculator (https://www.evanmiller.org/ab-testing/sample-size.html) or this formula:

```
n = 2 × (Zα + Zβ)² × p × (1-p) / (MDE)²

Where:
- Zα = 1.96 for 95% confidence
- Zβ = 0.84 for 80% power
- p = baseline conversion rate
- MDE = minimum detectable effect (as decimal)
```

**Example Calculation:**
- Baseline conversion rate: 10%
- Target MDE: 10% relative improvement (1% absolute, from 10% to 11%)
- Confidence: 95%
- Power: 80%

```
MDE (absolute) = 0.10 × 0.10 = 0.01
n = 2 × (1.96 + 0.84)² × 0.10 × 0.90 / (0.01)²
n = 2 × 7.84 × 0.09 / 0.0001
n = 14,112 per variant
Total sample needed: 28,224 users
```

### Extended Sample Size Table

| Baseline Rate | 5% MDE | 10% MDE | 20% MDE | 30% MDE |
|---------------|---------|---------|---------|---------|
| 0.5% | 770,000 | 193,000 | 48,500 | 21,600 |
| 1% | 305,000 | 76,700 | 19,300 | 8,600 |
| 2% | 145,000 | 36,500 | 9,200 | 4,100 |
| 5% | 58,400 | 14,750 | 3,750 | 1,700 |
| 10% | 27,200 | 6,940 | 1,775 | 800 |
| 20% | 12,400 | 3,200 | 830 | 375 |
| 30% | 7,460 | 1,935 | 510 | 230 |
| 40% | 5,140 | 1,350 | 360 | 165 |
| 50% | 3,840 | 1,020 | 270 | 125 |

*Sample size per variant at 95% confidence, 80% power*

**Duration Estimation:**

```
Test Duration (days) = (Sample per variant × 2) / Daily traffic

Example:
- Required sample: 7,000 per variant (14,000 total)
- Daily traffic: 2,000 users
- Duration: 14,000 / 2,000 = 7 days
```

---

## Experiment Types

### A/B Test (Split Test)

**Structure:** Control (A) vs. Single Variant (B)

**Use when:**
- Testing a single hypothesis
- Clear champion vs. challenger scenario
- Limited traffic (most efficient design)

**Traffic split:** 50/50 (equal allocation maximizes statistical power)

**Example:**
- Control: Blue CTA button
- Variant: Green CTA button

### A/B/n Test (Multi-variant)

**Structure:** Control (A) vs. Multiple Variants (B, C, D...)

**Use when:**
- Testing multiple alternatives to same element
- Exploring different approaches (conservative vs. aggressive copy)

**Traffic split:** Equal across all variants (e.g., 33/33/33 for A/B/C)

**Downside:** Requires n× the sample size of A/B test. With 3 variants, you need 3× traffic.

**Example:**
- Control: "Sign Up Free"
- Variant B: "Start Your Free Trial"
- Variant C: "Get Started Now"

### Multivariate Test (MVT)

**Structure:** Testing multiple elements simultaneously to find optimal combination

**Use when:**
- You have massive traffic (10× what A/B tests need)
- Elements likely interact (headline × CTA × image combinations)
- Want to find global optimum, not local

**Traffic split:** Equal across all combinations

**Formula for combinations:**
```
Total variants = Options₁ × Options₂ × ... × Optionsₙ

Example:
2 headlines × 2 CTAs × 2 images = 8 variants total
```

**Sample size:** Multiply A/B requirements by number of variants. Testing 8 combinations requires 8× the sample size.

**Example:**
- Headlines: "Save Money" vs. "Grow Your Business"
- CTA: "Sign Up" vs. "Get Started"
- Image: Product screenshot vs. Customer photo
- Total: 2 × 2 × 2 = 8 variants to test

**Warning:** MVT is often misused. Most businesses lack sufficient traffic. Stick to A/B tests unless you have 100k+ weekly users.

### Multi-Armed Bandit

**Structure:** Dynamic traffic allocation based on real-time performance

**Use when:**
- Minimizing opportunity cost of showing losers
- Traffic is very expensive (paid ads)
- You need continuous optimization, not one-time decision

**How it works:**
1. Start with equal traffic split
2. Algorithm observes conversion rates
3. Progressively allocates more traffic to winners
4. Continues indefinitely

**Algorithms:**
- **Epsilon-Greedy:** Exploit best variant 90% of time, explore randomly 10%
- **Thompson Sampling:** Bayesian approach, balances exploration/exploitation optimally
- **UCB (Upper Confidence Bound):** Explores variants with uncertain outcomes

**Tradeoff:** Faster to find winners, but harder to measure exact effect size. Use when speed > precision.

---

## Common Pitfalls and How to Avoid Them

### 1. Peeking (Sequential Testing Error)

**Problem:** Checking results before reaching planned sample size inflates false positive rate from 5% to 25%+.

**Why it happens:** If you check every day, you have 30 chances to find "significance" in a 30-day test. Pure chance will show p<0.05 on 1-2 days even with no real difference.

**Solution:**
- Set sample size upfront, don't peek until reached
- If you must peek, use sequential testing methods (e.g., Optimizely's Stats Engine)
- Or apply Bonferroni correction: divide α by number of peeks (checking 10 times → use α = 0.005)

### 2. Sample Ratio Mismatch (SRM)

**Problem:** Traffic split doesn't match intended allocation (e.g., 50/50 test shows 52/48 split).

**Why it happens:**
- Implementation bugs
- Bot traffic hitting one variant more
- Redirect loops
- Browser/device compatibility issues

**Detection:** Chi-square test on observed vs. expected split. If p<0.01, you have SRM.

**Solution:**
- Check implementation before launching
- Monitor split ratio daily
- Investigate any deviation >1%
- Don't trust results if SRM exists — fix implementation and retest

### 3. Novelty Effect

**Problem:** Users react to *change itself*, not the specific variant. Effect fades after 1-2 weeks.

**Example:** Changing button from blue to red shows 10% lift in week 1, but returns to baseline in week 3.

**Solution:**
- Run tests for minimum 2 full business cycles (2 weeks for B2C, 2 months for B2B)
- Check if effect size is stable over time
- Segment new vs. returning users to see if effect is novelty-driven

### 4. Segment Pollution

**Problem:** Including wrong users in analysis (e.g., logged-in users in a signup page test).

**Solution:**
- Define eligible population before testing
- Filter out ineligible users from analysis
- Pre-filter in test assignment code when possible

### 5. Multiple Comparison Problem

**Problem:** Testing 20 metrics with α=0.05 means you expect 1 false positive by chance.

**Example:** Test shows no change to primary metric (conversion), but "statistically significant" improvement to 2 of 15 secondary metrics. Likely noise.

**Solution:**
- Declare ONE primary metric before test
- Secondary metrics are for learning, not decision-making
- If testing multiple metrics, apply Bonferroni correction: α / number of metrics

### 6. Insufficient Power

**Problem:** Test ends "inconclusive" because sample size was too small to detect realistic effects.

**Solution:**
- Calculate required sample size BEFORE testing
- Don't launch if you can't reach sample size in reasonable time
- Increase MDE threshold (easier to detect 20% change than 5%)
- Or test higher-traffic pages

### 7. Carryover Effects

**Problem:** Users see multiple variants over time, confounding results.

**Example:** User sees control on Monday, variant on Tuesday due to cookie deletion or device switching.

**Solution:**
- Use sticky bucketing (same user always sees same variant)
- Test user ID-based assignment if users log in
- Cookie-based assignment for anonymous users
- Monitor cookie persistence rates

### 8. Regression to Mean

**Problem:** Extreme results in early data (day 1 shows 40% lift!) regress toward true effect over time.

**Why it happens:** Early sample has high variance. First 100 conversions might randomly skew high.

**Solution:**
- Ignore early results
- Wait for planned sample size
- Expect effect size to stabilize as n increases

---

## Experiment Design Checklist

Before launching any test, verify:

- [ ] **Single clear hypothesis** with expected direction and magnitude
- [ ] **One primary metric** (not 5 "co-primary" metrics)
- [ ] **Sample size calculated** for realistic MDE
- [ ] **Duration estimated** (can we reach sample size in <4 weeks?)
- [ ] **Eligible population defined** (who should see this test?)
- [ ] **Variants implemented** and QA tested on all devices/browsers
- [ ] **Randomization verified** (50/50 split is actually 50/50)
- [ ] **Tracking validated** (events firing correctly in both variants)
- [ ] **Guardrail metrics defined** (what must NOT break?)
- [ ] **Decision criteria documented** (what result = ship variant?)

---

## Advanced Topics

### Bayesian A/B Testing

Alternative to frequentist hypothesis testing. Instead of p-values, you get probability that variant beats control.

**Pros:**
- Easier to interpret ("95% chance variant is better")
- Can stop test early with less risk
- No peeking penalty

**Cons:**
- Requires prior beliefs (though uninformative priors work fine)
- Less familiar to stakeholders
- Slightly more complex math

**Tools:** VWO, Dynamic Yield, or custom implementation with pymc

### CUPED (Controlled-Experiment Using Pre-Experiment Data)

Variance reduction technique using pre-test user data.

**How it works:**
1. Measure user behavior before test (e.g., average order value last 30 days)
2. Use this as covariate in analysis
3. Reduces variance by 20-50%, meaning smaller required sample sizes

**When to use:** You have historical user-level data and test duration >2 weeks

**Implementation:** Requires statistical infrastructure, not available in most A/B tools

### Stratified Sampling

Ensure equal representation of user segments across variants.

**Example:** Force 50/50 desktop/mobile split in both variants, instead of randomizing freely.

**Use when:** Segment behavior differs wildly (desktop converts 3×, mobile users), and you have uneven traffic (70% mobile).

**Benefit:** Increases statistical power by 10-30%

---

## Recommended Reading

- **Trustworthy Online Controlled Experiments** by Kohavi, Tang, Xu — the definitive guide
- **Evan Miller's Blog** (evanmiller.org) — deep dives on statistics
- **Booking.com Testing Articles** — real-world case studies at scale

## Tools Reference

- **Sample Size Calculators:**
  - Evan Miller: https://www.evanmiller.org/ab-testing/sample-size.html
  - Optimizely: https://www.optimizely.com/sample-size-calculator/

- **Statistics Calculators:**
  - Chi-square test for SRM: https://www.evanmiller.org/ab-testing/chi-squared.html
  - Sequential testing boundaries: https://www.evanmiller.org/sequential-ab-testing.html

- **A/B Testing Platforms:**
  - Google Optimize (free, basic features)
  - Optimizely (enterprise)
  - VWO (mid-market)
  - LaunchDarkly (feature flags + experimentation)
  - GrowthBook (open source)
