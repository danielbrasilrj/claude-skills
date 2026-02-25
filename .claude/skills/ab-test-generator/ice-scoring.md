# ICE Scoring Framework Deep Dive

## Impact (1-10)

Impact measures the potential business value if the experiment succeeds. Consider both magnitude and breadth of the change.

**Scoring Guidelines:**

| Score | Description                                                                          | Examples                                                                                |
| ----- | ------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| 1-3   | **Marginal impact** — affects a small user segment or secondary metric               | Changing button radius from 4px to 6px; adjusting footer link color                     |
| 4-6   | **Moderate impact** — meaningful improvement to a core metric for a subset of users  | Improving checkout form validation messages; adding social proof below CTA              |
| 7-8   | **High impact** — significant improvement to a primary business metric               | Redesigning entire checkout flow; adding guest checkout option                          |
| 9-10  | **Transformational impact** — potential to fundamentally change key business metrics | New pricing model; complete onboarding reimagination; removing signup friction entirely |

**Impact Multipliers:**

- Traffic volume affected (homepage = higher impact than settings page)
- Metric proximity to revenue (conversion > engagement > awareness)
- Reversibility (irreversible changes carry higher stakes)

## Confidence (1-10)

Confidence reflects your certainty that the change will produce the expected result. Base this on evidence, not hope.

**Scoring Guidelines:**

| Score | Evidence Level                                                                                                                | Examples                                                                          |
| ----- | ----------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| 1-3   | **Pure speculation** — gut feeling, no supporting data                                                                        | "Users might prefer blue buttons because blue is calming"                         |
| 4-5   | **Weak signals** — qualitative feedback from <10 users, unvalidated assumptions                                               | "A few customer support tickets mentioned this issue"                             |
| 6-7   | **Moderate evidence** — user research with 10+ participants, industry benchmarks, A/B test results from similar products      | "Baymard Institute reports 70% cart abandonment due to unexpected shipping costs" |
| 8-9   | **Strong evidence** — previous A/B test results on same product, quantitative user behavior data                              | "We tested this on mobile last quarter and saw 15% lift"                          |
| 10    | **Near certainty** — replicating a proven winner from prior testing or established laws (e.g., removing broken functionality) | "Fixing broken checkout button that currently shows JS error"                     |

**Common Confidence Killers:**

- No user research conducted
- Assumption based on competitor copying
- "Best practice" claims without data
- Internal stakeholder preferences

## Ease (1-10)

Ease measures implementation complexity: engineering time, design work, dependencies, and risk of bugs.

**Scoring Guidelines:**

| Score | Effort                                                                   | Examples                                                              |
| ----- | ------------------------------------------------------------------------ | --------------------------------------------------------------------- |
| 1-3   | **Weeks** — multi-team coordination, backend changes, new infrastructure | Building recommendation engine; implementing personalization platform |
| 4-5   | **Several days** — frontend + backend work, third-party integration      | Adding live chat widget; implementing OAuth login                     |
| 6-7   | **1-2 days** — frontend-only work with existing components               | Reordering form fields; changing CTA copy and color                   |
| 8-9   | **Hours** — copy changes, CSS tweaks, feature flag toggles               | Headline A/B test; button color change; hiding existing element       |
| 10    | **Minutes** — pure copy changes with no code                             | Email subject line test; ad headline test                             |

**Ease Reducers:**

- Cross-team dependencies
- Need for legal/compliance review
- Technical debt in affected codebase
- Mobile app changes (requires app store approval)

## ICE Score Calculation

```
ICE Score = Impact x Confidence x Ease
Maximum possible score: 10 x 10 x 10 = 1000
```

**Decision Framework:**

| ICE Score | Priority            | Action                                               |
| --------- | ------------------- | ---------------------------------------------------- |
| 500+      | **Run immediately** | Clear winner, allocate resources now                 |
| 300-499   | **Backlog**         | Strong candidate, run when capacity allows           |
| 100-299   | **Consider**        | May be worth running if aligned with strategic goals |
| <100      | **Reject**          | Not worth the effort; focus elsewhere                |

**Example Scored Hypotheses:**

1. **High-scoring experiment (ICE = 560)**
   - _Hypothesis_: Adding "Free shipping over $50" banner will increase AOV by 15%
   - Impact: 8 (directly affects revenue, applies to all users)
   - Confidence: 7 (similar tests show 10-20% lifts)
   - Ease: 10 (banner copy change only)

2. **Medium-scoring experiment (ICE = 192)**
   - _Hypothesis_: Redesigning product page layout will increase add-to-cart rate by 10%
   - Impact: 8 (core conversion metric)
   - Confidence: 4 (no prior data, gut feeling)
   - Ease: 6 (frontend-only, 2 days work)

3. **Low-scoring experiment (ICE = 60)**
   - _Hypothesis_: AI-powered product recommendations will increase repeat purchase rate by 25%
   - Impact: 10 (major revenue impact if true)
   - Confidence: 3 (no proof this will work for our product)
   - Ease: 2 (requires ML infrastructure, weeks of work)
