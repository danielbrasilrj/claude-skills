# Advanced Topics

## Bayesian A/B Testing

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

## CUPED (Controlled-Experiment Using Pre-Experiment Data)

Variance reduction technique using pre-test user data.

**How it works:**

1. Measure user behavior before test (e.g., average order value last 30 days)
2. Use this as covariate in analysis
3. Reduces variance by 20-50%, meaning smaller required sample sizes

**When to use:** You have historical user-level data and test duration >2 weeks

**Implementation:** Requires statistical infrastructure, not available in most A/B tools

## Stratified Sampling

Ensure equal representation of user segments across variants.

**Example:** Force 50/50 desktop/mobile split in both variants, instead of randomizing freely.

**Use when:** Segment behavior differs wildly (desktop converts 3x, mobile users), and you have uneven traffic (70% mobile).

**Benefit:** Increases statistical power by 10-30%

## Recommended Reading

- **Trustworthy Online Controlled Experiments** by Kohavi, Tang, Xu — the definitive guide
- **Evan Miller's Blog** (evanmiller.org) — deep dives on statistics
- **Booking.com Testing Articles** — real-world case studies at scale

## A/B Testing Platforms

- Google Optimize (free, basic features)
- Optimizely (enterprise)
- VWO (mid-market)
- LaunchDarkly (feature flags + experimentation)
- GrowthBook (open source)
