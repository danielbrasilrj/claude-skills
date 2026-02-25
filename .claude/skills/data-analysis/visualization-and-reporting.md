# Visualization Standards & Reporting

## Cohort Heatmap

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

## Distribution Comparison

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

---

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

---

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
