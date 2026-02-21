# Data Analysis Reference Guide

## Overview

This reference guide provides comprehensive standards, patterns, and best practices for conducting data analysis using Python's scientific computing stack (pandas, numpy, scipy, matplotlib, seaborn). It covers the full workflow from data loading through statistical testing to visualization.

## Core Principles

### 1. Reproducibility

All analysis must be reproducible:
- **Fixed Random Seeds**: Set `np.random.seed(42)` for any randomized operations
- **Version Pinning**: Document library versions in requirements.txt
- **Data Provenance**: Record data source, extraction date, transformations
- **Documented Assumptions**: Explicitly state all assumptions in analysis

### 2. Data Quality First

Never skip data quality checks:
- Check for missing values, duplicates, outliers
- Validate data types and ranges
- Document data cleaning decisions
- Preserve raw data (never overwrite original)

### 3. Statistical Rigor

- State hypotheses before analysis (avoid p-hacking)
- Check test assumptions (normality, independence, etc.)
- Report effect sizes, not just p-values
- Use appropriate corrections for multiple comparisons

## Python Data Analysis Stack

### Required Libraries

```python
# requirements.txt
pandas==2.1.4
numpy==1.26.3
scipy==1.11.4
statsmodels==0.14.1
matplotlib==3.8.2
seaborn==0.13.1
openpyxl==3.1.2  # For Excel support
jupyter==1.0.0
```

Install with:
```bash
pip install -r requirements.txt
```

## Data Loading and Exploration

### Standard Loading Pattern

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

# Set random seed for reproducibility
np.random.seed(42)

# Configure display options
pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', 100)
pd.set_option('display.float_format', '{:.2f}'.format)

# Configure plotting
sns.set_style('whitegrid')
plt.rcParams['figure.figsize'] = (12, 6)
plt.rcParams['figure.dpi'] = 100

# Load data
data_path = Path('data/input/customers.csv')
df = pd.read_csv(
    data_path,
    parse_dates=['created_at', 'last_activity_at'],  # Auto-parse dates
    dtype={'user_id': str, 'amount': float},  # Explicit types
    na_values=['', 'NULL', 'N/A', 'nan']  # Additional null values
)

# Document data provenance
print(f"Data source: {data_path}")
print(f"Loaded at: {pd.Timestamp.now()}")
print(f"Shape: {df.shape}")
```

### Initial Data Exploration

```python
def explore_dataframe(df: pd.DataFrame, name: str = "DataFrame") -> None:
    """
    Comprehensive data exploration function.
    
    Prints summary statistics, missing values, duplicates, and data types.
    """
    print(f"\n{'='*60}")
    print(f"Exploring: {name}")
    print(f"{'='*60}\n")
    
    # Basic info
    print(f"Shape: {df.shape[0]:,} rows × {df.shape[1]} columns\n")
    
    # Data types
    print("Data Types:")
    print(df.dtypes)
    print()
    
    # Missing values
    missing = df.isnull().sum()
    missing_pct = (missing / len(df) * 100).round(2)
    missing_df = pd.DataFrame({
        'Missing Count': missing,
        'Missing %': missing_pct
    })
    missing_df = missing_df[missing_df['Missing Count'] > 0].sort_values(
        'Missing Count', ascending=False
    )
    
    if len(missing_df) > 0:
        print("Missing Values:")
        print(missing_df)
        print()
    else:
        print("No missing values.\n")
    
    # Duplicates
    dup_count = df.duplicated().sum()
    print(f"Duplicate Rows: {dup_count:,} ({dup_count/len(df)*100:.2f}%)\n")
    
    # Summary statistics
    print("Summary Statistics:")
    print(df.describe(include='all'))
    print()
    
    # Memory usage
    memory_mb = df.memory_usage(deep=True).sum() / 1024**2
    print(f"Memory Usage: {memory_mb:.2f} MB")

# Use the function
explore_dataframe(df, "Customer Data")
```

## Data Cleaning Procedures

### Handling Missing Values

```python
def handle_missing_values(df: pd.DataFrame) -> pd.DataFrame:
    """
    Handle missing values with documented strategy.
    """
    df = df.copy()  # Never modify original
    
    # Strategy 1: Drop rows with missing critical fields
    critical_fields = ['user_id', 'created_at']
    before_count = len(df)
    df = df.dropna(subset=critical_fields)
    dropped = before_count - len(df)
    print(f"Dropped {dropped} rows missing critical fields ({dropped/before_count*100:.2f}%)")
    
    # Strategy 2: Fill numeric fields with median
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    for col in numeric_cols:
        if df[col].isnull().sum() > 0:
            median_val = df[col].median()
            df[col].fillna(median_val, inplace=True)
            print(f"Filled {col} missing values with median: {median_val:.2f}")
    
    # Strategy 3: Fill categorical with mode or 'Unknown'
    categorical_cols = df.select_dtypes(include=['object']).columns
    for col in categorical_cols:
        if df[col].isnull().sum() > 0:
            df[col].fillna('Unknown', inplace=True)
            print(f"Filled {col} missing values with 'Unknown'")
    
    return df

df_clean = handle_missing_values(df)
```

### Handling Outliers

```python
def detect_outliers_iqr(series: pd.Series, multiplier: float = 1.5) -> pd.Series:
    """
    Detect outliers using Interquartile Range (IQR) method.
    
    Returns boolean mask where True = outlier.
    """
    Q1 = series.quantile(0.25)
    Q3 = series.quantile(0.75)
    IQR = Q3 - Q1
    
    lower_bound = Q1 - multiplier * IQR
    upper_bound = Q3 + multiplier * IQR
    
    outliers = (series < lower_bound) | (series > upper_bound)
    
    print(f"{series.name}: {outliers.sum()} outliers detected")
    print(f"  Range: [{lower_bound:.2f}, {upper_bound:.2f}]")
    
    return outliers

# Example: Detect outliers in revenue
revenue_outliers = detect_outliers_iqr(df_clean['revenue'])

# Visualize outliers
fig, ax = plt.subplots(1, 2, figsize=(14, 5))
ax[0].boxplot(df_clean['revenue'])
ax[0].set_title('Revenue Distribution (with outliers)')
ax[1].boxplot(df_clean.loc[~revenue_outliers, 'revenue'])
ax[1].set_title('Revenue Distribution (outliers removed)')
plt.show()

# Decision: Cap outliers at 99th percentile
p99 = df_clean['revenue'].quantile(0.99)
df_clean['revenue_capped'] = df_clean['revenue'].clip(upper=p99)
print(f"Capped revenue at 99th percentile: ${p99:,.2f}")
```

## A/B Test Statistical Analysis

### Proportion Test (Conversion Rates)

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

### Continuous Metrics Test (Revenue, Time)

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

### Sample Size Calculation

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
        DataFrame with retention percentages (cohorts × periods)
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

## Data Visualization Standards

### Cohort Heatmap

```python
def plot_cohort_heatmap(retention_df: pd.DataFrame, title: str = "Cohort Retention") -> None:
    """
    Plot cohort retention as heatmap.
    """
    plt.figure(figsize=(14, 8))
    
    sns.heatmap(
        retention_df,
        annot=True,
        fmt='.1f',
        cmap='RdYlGn',
        vmin=0,
        vmax=100,
        cbar_kws={'label': 'Retention %'},
        linewidths=0.5,
        linecolor='gray'
    )
    
    plt.title(title, fontsize=16, fontweight='bold')
    plt.xlabel('Months Since Acquisition', fontsize=12)
    plt.ylabel('Cohort', fontsize=12)
    plt.tight_layout()
    plt.savefig('cohort_retention.png', dpi=150, bbox_inches='tight')
    plt.show()

plot_cohort_heatmap(cohort_retention)
```

### Distribution Comparison

```python
def plot_ab_distributions(
    control: np.ndarray,
    variant: np.ndarray,
    metric_name: str,
    bins: int = 30
) -> None:
    """
    Plot overlapping distributions for A/B test.
    """
    fig, ax = plt.subplots(1, 2, figsize=(14, 5))
    
    # Histogram
    ax[0].hist(control, bins=bins, alpha=0.6, label='Control', color='blue', density=True)
    ax[0].hist(variant, bins=bins, alpha=0.6, label='Variant', color='green', density=True)
    ax[0].axvline(np.mean(control), color='blue', linestyle='--', label=f'Control Mean: {np.mean(control):.2f}')
    ax[0].axvline(np.mean(variant), color='green', linestyle='--', label=f'Variant Mean: {np.mean(variant):.2f}')
    ax[0].set_xlabel(metric_name)
    ax[0].set_ylabel('Density')
    ax[0].set_title(f'{metric_name} Distribution')
    ax[0].legend()
    ax[0].grid(alpha=0.3)
    
    # Box plot
    ax[1].boxplot([control, variant], labels=['Control', 'Variant'])
    ax[1].set_ylabel(metric_name)
    ax[1].set_title(f'{metric_name} Comparison')
    ax[1].grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(f'{metric_name.lower().replace(" ", "_")}_comparison.png', dpi=150)
    plt.show()

plot_ab_distributions(control_revenue, variant_revenue, 'Revenue ($)')
```

## Jupyter Notebook Conventions

### Notebook Structure

```markdown
# Analysis Title

**Author**: Your Name  
**Date**: 2024-01-15  
**Purpose**: Brief description of analysis goal

## 1. Setup

Import libraries, load data, set configurations.

## 2. Data Exploration

Initial exploration and quality checks.

## 3. Data Cleaning

Document all cleaning steps and decisions.

## 4. Analysis

Main analysis (statistical tests, cohort analysis, etc.).

## 5. Visualization

Key charts and graphs.

## 6. Conclusions

Summary of findings and recommendations.

## 7. Next Steps

What further analysis is needed?
```

### Cell Organization

```python
# %% [markdown]
# ## 1. Setup

# %%
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# %% [markdown]
# Load data from CSV...

# %%
df = pd.read_csv('data/input/customers.csv')

# %% [markdown]
# ## 2. Data Exploration
# 
# Check data quality and distributions...

# %%
explore_dataframe(df)
```

## Report Generation

Save analysis results to structured report:

```python
def generate_analysis_report(results: dict, output_path: str) -> None:
    """
    Generate markdown report from analysis results.
    """
    report = f"""
# Analysis Report

**Generated**: {pd.Timestamp.now().strftime('%Y-%m-%d %H:%M:%S')}

## Summary

{results.get('summary', 'No summary provided')}

## Key Findings

{results.get('findings', 'No findings documented')}

## Statistical Tests

{results.get('tests', 'No tests performed')}

## Recommendations

{results.get('recommendations', 'No recommendations')}
"""
    
    with open(output_path, 'w') as f:
        f.write(report)
    
    print(f"Report saved to: {output_path}")
```

This comprehensive reference guide provides production-ready patterns for all common data analysis workflows.
