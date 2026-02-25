# Experiment Types

## A/B Test (Split Test)

**Structure:** Control (A) vs. Single Variant (B)

**Use when:**

- Testing a single hypothesis
- Clear champion vs. challenger scenario
- Limited traffic (most efficient design)

**Traffic split:** 50/50 (equal allocation maximizes statistical power)

**Example:**

- Control: Blue CTA button
- Variant: Green CTA button

## A/B/n Test (Multi-variant)

**Structure:** Control (A) vs. Multiple Variants (B, C, D...)

**Use when:**

- Testing multiple alternatives to same element
- Exploring different approaches (conservative vs. aggressive copy)

**Traffic split:** Equal across all variants (e.g., 33/33/33 for A/B/C)

**Downside:** Requires n x the sample size of A/B test. With 3 variants, you need 3x traffic.

**Example:**

- Control: "Sign Up Free"
- Variant B: "Start Your Free Trial"
- Variant C: "Get Started Now"

## Multivariate Test (MVT)

**Structure:** Testing multiple elements simultaneously to find optimal combination

**Use when:**

- You have massive traffic (10x what A/B tests need)
- Elements likely interact (headline x CTA x image combinations)
- Want to find global optimum, not local

**Traffic split:** Equal across all combinations

**Formula for combinations:**

```
Total variants = Options_1 x Options_2 x ... x Options_n

Example:
2 headlines x 2 CTAs x 2 images = 8 variants total
```

**Sample size:** Multiply A/B requirements by number of variants. Testing 8 combinations requires 8x the sample size.

**Example:**

- Headlines: "Save Money" vs. "Grow Your Business"
- CTA: "Sign Up" vs. "Get Started"
- Image: Product screenshot vs. Customer photo
- Total: 2 x 2 x 2 = 8 variants to test

**Warning:** MVT is often misused. Most businesses lack sufficient traffic. Stick to A/B tests unless you have 100k+ weekly users.

## Multi-Armed Bandit

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
