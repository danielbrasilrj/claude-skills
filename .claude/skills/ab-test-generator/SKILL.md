---
name: ab-test-generator
description: Generates A/B test hypotheses with ICE scoring. Use for growth experiments and prioritization.
---

## Purpose

A/B Test Generator transforms product observations into structured, prioritized experiments. It uses the ICE scoring framework to rank competing ideas and produces complete experiment documents that include hypothesis, metrics, sample size requirements, and duration estimates.

## When to Use

- Planning growth experiments for a product
- Prioritizing a backlog of test ideas
- Designing an A/B test from a feature change
- Estimating required sample sizes and test duration
- Reviewing app screenshots or URLs for optimization opportunities

## Prerequisites

- App screenshot, URL, or feature description to analyze
- Current baseline metrics (conversion rate, engagement rate, etc.)
- Approximate daily traffic/user volume (for duration estimates)

## Procedures

### 1. Identify Optimization Opportunities

Analyze the provided input and list potential improvements:

- **UI/UX friction points** — confusing flows, too many steps, unclear CTAs
- **Copy improvements** — weak headlines, missing social proof, unclear value props
- **Feature gaps** — missing functionality users might expect
- **Performance issues** — slow loads, poor mobile experience

### 2. Generate Hypotheses

For each opportunity, write a hypothesis:

```
If we [specific change],
then [metric] will [increase/decrease] by [estimated %],
because [rationale based on user behavior or best practice].
```

### 3. ICE Score Each Hypothesis

Score each dimension 1-10:

| Dimension             | Scoring Guide                                                                                  |
| --------------------- | ---------------------------------------------------------------------------------------------- |
| **Impact** (1-10)     | 1-3: Minor metric move. 4-6: Moderate improvement. 7-10: Major business impact.                |
| **Confidence** (1-10) | 1-3: Gut feeling only. 4-6: Some supporting data. 7-10: Strong evidence or prior test results. |
| **Ease** (1-10)       | 1-3: Weeks of work, multiple teams. 4-6: Days of work, one team. 7-10: Hours, simple change.   |

**ICE Score = Impact x Confidence x Ease** (max 1000)

Rank all hypotheses by ICE score. Top 3 become priority experiments.

See [ice-scoring.md](ice-scoring.md) for detailed scoring guidelines, examples, and the decision framework.

### 4. Build Experiment Document

For each priority experiment, create a full doc:

```markdown
## Experiment: [Name]

**Hypothesis**: If we [change], then [metric] will [direction] because [reason].

**ICE Score**: I=[x] C=[x] E=[x] → Total: [xxx]

### Variants

- **Control**: [Current behavior]
- **Variant**: [Proposed change]

### Metrics

- **Primary**: [Single metric that determines success]
- **Secondary**: [Supporting metrics to monitor]
- **Guardrail**: [Metrics that must NOT degrade]

### Sample Size

- Baseline rate: [x%]
- Minimum detectable effect (MDE): [x%]
- Significance level: 95%
- Power: 80%
- Required sample per variant: [calculated]
- Estimated duration: [days] at [daily traffic] users/day

### Decision Criteria

- **Ship variant** if: primary metric improves ≥ MDE with p < 0.05
- **Keep control** if: no significant difference after full duration
- **Stop early** if: guardrail metric degrades > [threshold]
```

### 5. Sample Size Quick Reference

| Baseline Rate | 5% MDE  | 10% MDE | 20% MDE |
| ------------- | ------- | ------- | ------- |
| 1%            | 305,000 | 76,700  | 19,300  |
| 5%            | 58,400  | 14,750  | 3,750   |
| 10%           | 27,200  | 6,940   | 1,775   |
| 20%           | 12,400  | 3,200   | 830     |
| 50%           | 3,070   | 800     | 215     |

_Per variant. Use Evan Miller's calculator for exact numbers._

See [statistics.md](statistics.md) for the full sample size table, calculation formulas, and duration estimation.

## Templates

- `templates/experiment-doc.md` — Full experiment document template
- `templates/ice-scoring-matrix.md` — ICE scoring spreadsheet template

## Examples

- `examples/onboarding-experiment.md` — Complete onboarding flow A/B test

## Chaining

| Chain With               | Purpose                                         |
| ------------------------ | ----------------------------------------------- |
| `data-analysis`          | Analyze experiment results after test completes |
| `conversion-copywriting` | Generate copy variants for testing              |
| `deep-research`          | Research best practices to inform hypotheses    |
| `figma-handoff`          | Design variant UI from experiment spec          |

## Troubleshooting

| Problem                     | Solution                                                   |
| --------------------------- | ---------------------------------------------------------- |
| Not enough traffic for test | Increase MDE threshold or test a higher-traffic page       |
| Too many test ideas         | Use ICE scoring strictly; only run top 1-3                 |
| Hypothesis too vague        | Add specific numbers and user behavior rationale           |
| Test ran but inconclusive   | Check if sample size was reached; consider longer duration |

## References

- [ice-scoring.md](ice-scoring.md) — Detailed ICE dimension scoring guides with examples
- [statistics.md](statistics.md) — Sample size formulas, extended tables, duration estimation, and calculators
- [experiment-types.md](experiment-types.md) — A/B, A/B/n, multivariate, and multi-armed bandit patterns
- [pitfalls.md](pitfalls.md) — 8 common pitfalls (peeking, SRM, novelty effect, etc.) and how to avoid them
- [checklist.md](checklist.md) — Pre-launch experiment design checklist
- [advanced-topics.md](advanced-topics.md) — Bayesian testing, CUPED, stratified sampling, recommended reading
