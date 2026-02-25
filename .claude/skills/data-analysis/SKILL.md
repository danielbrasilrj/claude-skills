---
name: data-analysis
description: Python data analysis (pandas, matplotlib). CSV/Excel analysis, A/B test significance, cohort retention, and visualizations.
---

## Purpose

Data Analysis provides structured procedures for analyzing datasets using Python. It covers the full workflow from data loading and exploration through statistical testing and visualization, with specialized procedures for A/B test significance and cohort retention analysis.

## When to Use

- Analyzing CSV, Excel, or JSON data files
- Calculating A/B test statistical significance
- Building cohort retention analysis
- Generating data visualizations and charts
- Interpreting analytics dashboards or metrics
- Performing exploratory data analysis (EDA)

## Prerequisites

- **Python 3.10+**
- **Libraries**: pandas, numpy, scipy, statsmodels, matplotlib, seaborn
- Install: `pip install pandas numpy scipy statsmodels matplotlib seaborn openpyxl`

## Procedures

### 1. Data Loading and Exploration

For core principles (reproducibility, data quality, statistical rigor), see [core-principles.md](core-principles.md). For comprehensive loading patterns and cleaning procedures, see [data-loading-and-cleaning.md](data-loading-and-cleaning.md).

```python
import pandas as pd
import numpy as np

# Load data
df = pd.read_csv("data.csv")  # or pd.read_excel("data.xlsx")

# Quick exploration
print(f"Shape: {df.shape}")
print(f"Columns: {list(df.columns)}")
print(df.dtypes)
print(df.describe())
print(f"Missing values:\n{df.isnull().sum()}")
```

### 2. A/B Test Statistical Significance

For expanded test functions (normality checks, bootstrap CIs, sample size calculator), see [statistical-tests.md](statistical-tests.md).

**For conversion rates (proportions):**

```python
from scipy.stats import chi2_contingency, norm
import numpy as np

def ab_test_proportions(control_conversions, control_total, variant_conversions, variant_total, alpha=0.05):
    control_rate = control_conversions / control_total
    variant_rate = variant_conversions / variant_total

    # Chi-squared test
    table = [[control_conversions, control_total - control_conversions],
             [variant_conversions, variant_total - variant_conversions]]
    chi2, p_value, dof, expected = chi2_contingency(table)

    # Effect size and confidence interval
    diff = variant_rate - control_rate
    se = np.sqrt(control_rate*(1-control_rate)/control_total + variant_rate*(1-variant_rate)/variant_total)
    ci_lower = diff - 1.96 * se
    ci_upper = diff + 1.96 * se
    relative_lift = (variant_rate - control_rate) / control_rate * 100

    return {
        "control_rate": f"{control_rate:.4f}",
        "variant_rate": f"{variant_rate:.4f}",
        "relative_lift": f"{relative_lift:.2f}%",
        "p_value": f"{p_value:.6f}",
        "significant": p_value < alpha,
        "confidence_interval": f"[{ci_lower:.4f}, {ci_upper:.4f}]"
    }
```

**For continuous metrics (revenue, time):**

```python
from scipy.stats import ttest_ind, mannwhitneyu

def ab_test_continuous(control_values, variant_values, alpha=0.05):
    t_stat, p_value = ttest_ind(control_values, variant_values)

    return {
        "control_mean": f"{np.mean(control_values):.4f}",
        "variant_mean": f"{np.mean(variant_values):.4f}",
        "p_value": f"{p_value:.6f}",
        "significant": p_value < alpha
    }
```

**Sample size calculation:**

```python
from statsmodels.stats.power import NormalIndPower

def required_sample_size(baseline_rate, mde_relative, alpha=0.05, power=0.80):
    effect_size = baseline_rate * mde_relative
    analysis = NormalIndPower()
    n = analysis.solve_power(effect_size=effect_size, alpha=alpha, power=power, alternative='two-sided')
    return int(np.ceil(n))
```

### 3. Cohort Retention Analysis

```python
def cohort_retention(df, user_col, date_col, activity_col=None):
    df[date_col] = pd.to_datetime(df[date_col])
    df['cohort'] = df.groupby(user_col)[date_col].transform('min').dt.to_period('M')
    df['activity_month'] = df[date_col].dt.to_period('M')
    df['cohort_period'] = (df['activity_month'] - df['cohort']).apply(lambda x: x.n)

    cohort_table = df.groupby(['cohort', 'cohort_period'])[user_col].nunique().reset_index()
    cohort_pivot = cohort_table.pivot(index='cohort', columns='cohort_period', values=user_col)
    cohort_sizes = cohort_pivot[0]
    retention = cohort_pivot.divide(cohort_sizes, axis=0) * 100

    return retention
```

### 4. Visualization

For full visualization standards and report generation patterns, see [visualization-and-reporting.md](visualization-and-reporting.md).

```python
import seaborn as sns
import matplotlib.pyplot as plt

# Cohort heatmap
plt.figure(figsize=(12, 8))
sns.heatmap(retention, annot=True, fmt='.1f', cmap='YlOrRd_r', vmin=0, vmax=100)
plt.title('Cohort Retention (%)')
plt.xlabel('Months Since Acquisition')
plt.ylabel('Cohort')
plt.savefig('cohort_retention.png', dpi=150, bbox_inches='tight')
```

## References

- [core-principles.md](core-principles.md) — Reproducibility, data quality, statistical rigor, required libraries
- [data-loading-and-cleaning.md](data-loading-and-cleaning.md) — Loading patterns, exploration function, missing values, outlier detection
- [statistical-tests.md](statistical-tests.md) — Proportion tests, continuous metric tests, sample size calculation, cohort retention
- [visualization-and-reporting.md](visualization-and-reporting.md) — Heatmaps, distribution plots, notebook conventions, report generation

## Templates

- `templates/analysis-report.md` — Structured analysis report template
- `scripts/analysis-template.py` — Reusable Python analysis script

## Examples

- `examples/ab-test-example.md` — Complete A/B test analysis walkthrough

## Chaining

| Chain With                 | Purpose                                       |
| -------------------------- | --------------------------------------------- |
| `deep-research`            | Gather data for analysis                      |
| `ab-test-generator`        | Design experiments, then analyze results here |
| `performance-optimization` | Analyze performance metrics                   |
| `documentation-generator`  | Document analysis methodology                 |

## Troubleshooting

| Problem                   | Solution                                             |
| ------------------------- | ---------------------------------------------------- |
| Small sample size warning | Use Mann-Whitney U test or bootstrap methods         |
| Multiple comparisons      | Apply Bonferroni correction: `alpha / num_tests`     |
| Non-normal distribution   | Use non-parametric tests (Mann-Whitney, permutation) |
| Missing data              | Document missing rate; use dropna() or imputation    |
