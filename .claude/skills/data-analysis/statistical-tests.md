# Statistical Tests

## Proportion Test (Conversion Rates)

```python
from scipy.stats import chi2_contingency, norm
import numpy as np

def ab_test_proportions(
    control_conversions: int,
    control_total: int,
    variant_conversions: int,
    variant_total: int,
    alpha: float = 0.05
) -> dict:
    """
    A/B test for conversion rates (proportions).

    Uses chi-squared test for significance and calculates effect size.

    Returns:
        dict with control_rate, variant_rate, p_value, significant,
        relative_lift, confidence_interval
    """
    # Calculate conversion rates
    control_rate = control_conversions / control_total
    variant_rate = variant_conversions / variant_total

    # Chi-squared test
    table = [
        [control_conversions, control_total - control_conversions],
        [variant_conversions, variant_total - variant_conversions]
    ]
    chi2, p_value, dof, expected = chi2_contingency(table)

    # Effect size (relative lift)
    relative_lift = (variant_rate - control_rate) / control_rate * 100

    # Confidence interval for difference
    diff = variant_rate - control_rate
    se = np.sqrt(
        control_rate * (1 - control_rate) / control_total +
        variant_rate * (1 - variant_rate) / variant_total
    )
    ci_lower = diff - 1.96 * se
    ci_upper = diff + 1.96 * se

    return {
        'control_rate': f"{control_rate:.4f} ({control_rate*100:.2f}%)",
        'variant_rate': f"{variant_rate:.4f} ({variant_rate*100:.2f}%)",
        'absolute_diff': f"{diff:.4f} ({diff*100:.2f}pp)",
        'relative_lift': f"{relative_lift:+.2f}%",
        'p_value': f"{p_value:.6f}",
        'significant': p_value < alpha,
        'confidence_interval_95': f"[{ci_lower:.4f}, {ci_upper:.4f}]",
        'sample_size': f"Control: {control_total:,}, Variant: {variant_total:,}"
    }

# Example usage
results = ab_test_proportions(
    control_conversions=850,
    control_total=10000,
    variant_conversions=920,
    variant_total=10000
)

print("\nA/B Test Results:")
print("="*50)
for key, value in results.items():
    print(f"{key:20s}: {value}")
```

---

## Continuous Metrics Test (Revenue, Time)

```python
from scipy.stats import ttest_ind, mannwhitneyu, normaltest

def ab_test_continuous(
    control_values: np.ndarray,
    variant_values: np.ndarray,
    alpha: float = 0.05,
    use_nonparametric: bool = False
) -> dict:
    """
    A/B test for continuous metrics (revenue, time, etc.).

    Automatically checks normality and uses appropriate test.
    """
    # Check normality
    _, control_normal_p = normaltest(control_values)
    _, variant_normal_p = normaltest(variant_values)
    is_normal = (control_normal_p > 0.05) and (variant_normal_p > 0.05)

    # Choose test
    if is_normal and not use_nonparametric:
        test_name = "t-test (parametric)"
        t_stat, p_value = ttest_ind(control_values, variant_values)
    else:
        test_name = "Mann-Whitney U (non-parametric)"
        u_stat, p_value = mannwhitneyu(control_values, variant_values, alternative='two-sided')

    # Calculate statistics
    control_mean = np.mean(control_values)
    variant_mean = np.mean(variant_values)
    control_median = np.median(control_values)
    variant_median = np.median(variant_values)
    relative_lift = (variant_mean - control_mean) / control_mean * 100

    # Confidence interval (bootstrap)
    from scipy.stats import bootstrap
    def mean_diff(c, v):
        return np.mean(v) - np.mean(c)

    rng = np.random.default_rng(42)
    res = bootstrap(
        (control_values, variant_values),
        lambda c, v: np.mean(v) - np.mean(c),
        n_resamples=10000,
        confidence_level=0.95,
        random_state=rng,
        method='percentile'
    )

    return {
        'test_used': test_name,
        'normality': 'Yes' if is_normal else 'No',
        'control_mean': f"{control_mean:.2f}",
        'variant_mean': f"{variant_mean:.2f}",
        'control_median': f"{control_median:.2f}",
        'variant_median': f"{variant_median:.2f}",
        'relative_lift': f"{relative_lift:+.2f}%",
        'p_value': f"{p_value:.6f}",
        'significant': p_value < alpha,
        'confidence_interval_95': f"[{res.confidence_interval.low:.2f}, {res.confidence_interval.high:.2f}]"
    }

# Example usage
control_revenue = np.random.normal(50, 15, 1000)
variant_revenue = np.random.normal(53, 15, 1000)

results = ab_test_continuous(control_revenue, variant_revenue)

print("\nA/B Test Results (Continuous Metric):")
print("="*50)
for key, value in results.items():
    print(f"{key:20s}: {value}")
```

---

## Sample Size Calculation

```python
from statsmodels.stats.power import NormalIndPower, zt_ind_solve_power

def calculate_sample_size_proportion(
    baseline_rate: float,
    mde_relative: float,  # Minimum detectable effect (relative, e.g., 0.05 for 5%)
    alpha: float = 0.05,
    power: float = 0.80
) -> int:
    """
    Calculate required sample size per group for proportion test.

    Args:
        baseline_rate: Current conversion rate (e.g., 0.10 for 10%)
        mde_relative: Minimum detectable effect as relative change (e.g., 0.05 for 5% lift)
        alpha: Significance level (default 0.05)
        power: Statistical power (default 0.80)

    Returns:
        Required sample size per group
    """
    # Calculate effect size (Cohen's h)
    p1 = baseline_rate
    p2 = baseline_rate * (1 + mde_relative)

    effect_size = 2 * (np.arcsin(np.sqrt(p2)) - np.arcsin(np.sqrt(p1)))

    # Calculate sample size
    analysis = NormalIndPower()
    n = analysis.solve_power(
        effect_size=effect_size,
        alpha=alpha,
        power=power,
        alternative='two-sided'
    )

    return int(np.ceil(n))

# Example
n_required = calculate_sample_size_proportion(
    baseline_rate=0.08,  # 8% baseline conversion
    mde_relative=0.10,    # Want to detect 10% relative lift (0.8pp)
    alpha=0.05,
    power=0.80
)

print(f"Required sample size per group: {n_required:,}")
print(f"Total required: {n_required * 2:,}")
```

---

## Cohort Retention Analysis

```python
def cohort_retention_analysis(
    df: pd.DataFrame,
    user_col: str,
    date_col: str,
    cohort_period: str = 'M'  # 'M' for month, 'W' for week
) -> pd.DataFrame:
    """
    Calculate cohort retention table.

    Args:
        df: DataFrame with user activity data
        user_col: Column name for user ID
        date_col: Column name for activity date
        cohort_period: 'M' for monthly, 'W' for weekly cohorts

    Returns:
        DataFrame with retention percentages (cohorts x periods)
    """
    df = df.copy()
    df[date_col] = pd.to_datetime(df[date_col])

    # Assign cohort (first activity period)
    df['cohort'] = df.groupby(user_col)[date_col].transform('min').dt.to_period(cohort_period)

    # Activity period
    df['activity_period'] = df[date_col].dt.to_period(cohort_period)

    # Periods since cohort
    df['period_number'] = (df['activity_period'] - df['cohort']).apply(lambda x: x.n)

    # Count unique users per cohort-period
    cohort_data = df.groupby(['cohort', 'period_number'])[user_col].nunique().reset_index()
    cohort_data.columns = ['cohort', 'period_number', 'users']

    # Pivot to matrix
    cohort_pivot = cohort_data.pivot(index='cohort', columns='period_number', values='users')

    # Calculate retention percentage
    cohort_sizes = cohort_pivot[0]  # Period 0 = cohort size
    retention_pct = cohort_pivot.divide(cohort_sizes, axis=0) * 100

    return retention_pct

# Example usage
cohort_retention = cohort_retention_analysis(
    df=user_activity_df,
    user_col='user_id',
    date_col='activity_date',
    cohort_period='M'
)

print("Cohort Retention (%):")
print(cohort_retention.round(1))
```
