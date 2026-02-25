# Common Pitfalls and How to Avoid Them

## 1. Peeking (Sequential Testing Error)

**Problem:** Checking results before reaching planned sample size inflates false positive rate from 5% to 25%+.

**Why it happens:** If you check every day, you have 30 chances to find "significance" in a 30-day test. Pure chance will show p<0.05 on 1-2 days even with no real difference.

**Solution:**

- Set sample size upfront, don't peek until reached
- If you must peek, use sequential testing methods (e.g., Optimizely's Stats Engine)
- Or apply Bonferroni correction: divide alpha by number of peeks (checking 10 times -> use alpha = 0.005)

## 2. Sample Ratio Mismatch (SRM)

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

## 3. Novelty Effect

**Problem:** Users react to _change itself_, not the specific variant. Effect fades after 1-2 weeks.

**Example:** Changing button from blue to red shows 10% lift in week 1, but returns to baseline in week 3.

**Solution:**

- Run tests for minimum 2 full business cycles (2 weeks for B2C, 2 months for B2B)
- Check if effect size is stable over time
- Segment new vs. returning users to see if effect is novelty-driven

## 4. Segment Pollution

**Problem:** Including wrong users in analysis (e.g., logged-in users in a signup page test).

**Solution:**

- Define eligible population before testing
- Filter out ineligible users from analysis
- Pre-filter in test assignment code when possible

## 5. Multiple Comparison Problem

**Problem:** Testing 20 metrics with alpha=0.05 means you expect 1 false positive by chance.

**Example:** Test shows no change to primary metric (conversion), but "statistically significant" improvement to 2 of 15 secondary metrics. Likely noise.

**Solution:**

- Declare ONE primary metric before test
- Secondary metrics are for learning, not decision-making
- If testing multiple metrics, apply Bonferroni correction: alpha / number of metrics

## 6. Insufficient Power

**Problem:** Test ends "inconclusive" because sample size was too small to detect realistic effects.

**Solution:**

- Calculate required sample size BEFORE testing
- Don't launch if you can't reach sample size in reasonable time
- Increase MDE threshold (easier to detect 20% change than 5%)
- Or test higher-traffic pages

## 7. Carryover Effects

**Problem:** Users see multiple variants over time, confounding results.

**Example:** User sees control on Monday, variant on Tuesday due to cookie deletion or device switching.

**Solution:**

- Use sticky bucketing (same user always sees same variant)
- Test user ID-based assignment if users log in
- Cookie-based assignment for anonymous users
- Monitor cookie persistence rates

## 8. Regression to Mean

**Problem:** Extreme results in early data (day 1 shows 40% lift!) regress toward true effect over time.

**Why it happens:** Early sample has high variance. First 100 conversions might randomly skew high.

**Solution:**

- Ignore early results
- Wait for planned sample size
- Expect effect size to stabilize as n increases
