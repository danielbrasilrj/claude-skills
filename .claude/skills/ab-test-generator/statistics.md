# Statistical Significance and Sample Size

## Core Statistical Concepts

**Minimum Detectable Effect (MDE):**
The smallest change you care about detecting. Smaller MDEs require exponentially larger sample sizes.

- **5% MDE** — detect a change from 10% to 10.5% conversion rate
- **10% MDE** — detect a change from 10% to 11% conversion rate
- **20% MDE** — detect a change from 10% to 12% conversion rate

**Rule of thumb**: Don't test for <5% MDE unless you have massive traffic. Most businesses should target 10-20% MDE.

**Significance Level (alpha):**
Probability of false positive (declaring a winner when there's no real difference).

- Standard: **alpha = 0.05** (95% confidence)
- Conservative: **alpha = 0.01** (99% confidence, requires larger samples)

**Statistical Power (1-beta):**
Probability of detecting a true difference when it exists.

- Standard: **80% power** (beta = 0.20)
- High power: **90% power** (beta = 0.10, requires larger samples)

## Sample Size Calculation

Use Evan Miller's calculator (https://www.evanmiller.org/ab-testing/sample-size.html) or this formula:

```
n = 2 x (Z_alpha + Z_beta)^2 x p x (1-p) / (MDE)^2

Where:
- Z_alpha = 1.96 for 95% confidence
- Z_beta = 0.84 for 80% power
- p = baseline conversion rate
- MDE = minimum detectable effect (as decimal)
```

**Example Calculation:**

- Baseline conversion rate: 10%
- Target MDE: 10% relative improvement (1% absolute, from 10% to 11%)
- Confidence: 95%
- Power: 80%

```
MDE (absolute) = 0.10 x 0.10 = 0.01
n = 2 x (1.96 + 0.84)^2 x 0.10 x 0.90 / (0.01)^2
n = 2 x 7.84 x 0.09 / 0.0001
n = 14,112 per variant
Total sample needed: 28,224 users
```

## Extended Sample Size Table

| Baseline Rate | 5% MDE  | 10% MDE | 20% MDE | 30% MDE |
| ------------- | ------- | ------- | ------- | ------- |
| 0.5%          | 770,000 | 193,000 | 48,500  | 21,600  |
| 1%            | 305,000 | 76,700  | 19,300  | 8,600   |
| 2%            | 145,000 | 36,500  | 9,200   | 4,100   |
| 5%            | 58,400  | 14,750  | 3,750   | 1,700   |
| 10%           | 27,200  | 6,940   | 1,775   | 800     |
| 20%           | 12,400  | 3,200   | 830     | 375     |
| 30%           | 7,460   | 1,935   | 510     | 230     |
| 40%           | 5,140   | 1,350   | 360     | 165     |
| 50%           | 3,840   | 1,020   | 270     | 125     |

_Sample size per variant at 95% confidence, 80% power_

## Duration Estimation

```
Test Duration (days) = (Sample per variant x 2) / Daily traffic

Example:
- Required sample: 7,000 per variant (14,000 total)
- Daily traffic: 2,000 users
- Duration: 14,000 / 2,000 = 7 days
```

## Tools Reference

- **Sample Size Calculators:**
  - Evan Miller: https://www.evanmiller.org/ab-testing/sample-size.html
  - Optimizely: https://www.optimizely.com/sample-size-calculator/

- **Statistics Calculators:**
  - Chi-square test for SRM: https://www.evanmiller.org/ab-testing/chi-squared.html
  - Sequential testing boundaries: https://www.evanmiller.org/sequential-ab-testing.html
