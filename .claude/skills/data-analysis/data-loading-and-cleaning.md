# Data Loading and Cleaning

## Standard Loading Pattern

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

## Initial Data Exploration

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
    print(f"Shape: {df.shape[0]:,} rows x {df.shape[1]} columns\n")

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

---

## Handling Missing Values

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

## Handling Outliers

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
