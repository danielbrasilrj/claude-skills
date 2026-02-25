# Core Principles

## 1. Reproducibility

All analysis must be reproducible:

- **Fixed Random Seeds**: Set `np.random.seed(42)` for any randomized operations
- **Version Pinning**: Document library versions in requirements.txt
- **Data Provenance**: Record data source, extraction date, transformations
- **Documented Assumptions**: Explicitly state all assumptions in analysis

## 2. Data Quality First

Never skip data quality checks:

- Check for missing values, duplicates, outliers
- Validate data types and ranges
- Document data cleaning decisions
- Preserve raw data (never overwrite original)

## 3. Statistical Rigor

- State hypotheses before analysis (avoid p-hacking)
- Check test assumptions (normality, independence, etc.)
- Report effect sizes, not just p-values
- Use appropriate corrections for multiple comparisons

## Required Libraries

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
