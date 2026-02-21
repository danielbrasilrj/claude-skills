# Data Analysis Report: {{ANALYSIS_TITLE}}

**Analyst**: {{ANALYST_NAME}}  
**Date**: {{YYYY-MM-DD}}  
**Version**: {{VERSION}}

---

## Executive Summary

{{2-3 sentence summary of what was analyzed, key findings, and primary recommendation}}

**Key Findings**:
- {{Finding 1}}
- {{Finding 2}}
- {{Finding 3}}

**Primary Recommendation**: {{Action to take based on analysis}}

---

## 1. Objective

### Business Question
{{What business question is this analysis answering?}}

### Success Criteria
{{How will we know if this analysis was successful?}}

### Stakeholders
- **Primary**: {{Who needs this for decision-making?}}
- **Secondary**: {{Who else should be informed?}}

---

## 2. Data Sources

| Source | Description | Date Range | Records |
|--------|-------------|------------|---------|
| {{Source 1}} | {{Description}} | {{Start - End}} | {{N}} |
| {{Source 2}} | {{Description}} | {{Start - End}} | {{N}} |

### Data Quality Notes
- **Missing Data**: {{% missing, how handled}}
- **Outliers**: {{# outliers detected, treatment}}
- **Assumptions**: {{Any assumptions made about the data}}

---

## 3. Methodology

### Analytical Approach
{{Describe the analysis method: descriptive stats, hypothesis testing, cohort analysis, etc.}}

### Statistical Tests Used
- **Test 1**: {{Name (e.g., chi-squared test for proportions)}}
  - Null Hypothesis: {{H0}}
  - Alternative Hypothesis: {{H1}}
  - Significance Level: α = {{0.05}}

### Tools and Libraries
- Python {{version}}
- pandas {{version}}
- scipy {{version}}
- matplotlib {{version}}

---

## 4. Data Exploration

### Summary Statistics

{{Table or description of key statistics}}

| Metric | Count | Mean | Median | Std Dev | Min | Max |
|--------|-------|------|--------|---------|-----|-----|
| {{Metric 1}} | {{N}} | {{X}} | {{X}} | {{X}} | {{X}} | {{X}} |

### Distributions

{{Insert histogram or distribution plot}}

**Observations**:
- {{Observation 1}}
- {{Observation 2}}

---

## 5. Findings

### Finding 1: {{Title}}

**Description**: {{What did you discover?}}

**Evidence**:
```
{{Statistical test results, e.g.:
- Control conversion rate: 8.5%
- Variant conversion rate: 9.2%
- Relative lift: +8.2%
- p-value: 0.032
- Result: Statistically significant at α=0.05
}}
```

**Visualization**:
{{Insert chart/graph}}

**Interpretation**: {{What does this mean for the business?}}

---

### Finding 2: {{Title}}

{{Repeat structure above}}

---

### Finding 3: {{Title}}

{{Repeat structure above}}

---

## 6. Statistical Significance

### Hypothesis Test Results

| Test | Metric | Control | Variant | p-value | Significant? | Effect Size |
|------|--------|---------|---------|---------|--------------|-------------|
| {{Test 1}} | {{Metric}} | {{Value}} | {{Value}} | {{p}} | {{Yes/No}} | {{Cohen's d}} |

### Confidence Intervals

{{Provide 95% confidence intervals for key metrics}}

- **{{Metric 1}}**: [{{lower}}, {{upper}}]
- **{{Metric 2}}**: [{{lower}}, {{upper}}]

---

## 7. Visualizations

### Chart 1: {{Title}}

![{{Alt text}}](path/to/chart1.png)

**Interpretation**: {{What does this chart show?}}

---

### Chart 2: {{Title}}

![{{Alt text}}](path/to/chart2.png)

**Interpretation**: {{What does this chart show?}}

---

## 8. Limitations

{{List any limitations or caveats}}

- **Limitation 1**: {{Description and impact}}
- **Limitation 2**: {{Description and impact}}
- **Limitation 3**: {{Description and impact}}

---

## 9. Recommendations

### Immediate Actions
1. **{{Recommendation 1}}**
   - Rationale: {{Why this action?}}
   - Expected Impact: {{Quantified if possible}}
   - Owner: {{Who should do this?}}
   - Timeline: {{When?}}

2. **{{Recommendation 2}}**
   - Rationale: {{Why this action?}}
   - Expected Impact: {{Quantified if possible}}
   - Owner: {{Who should do this?}}
   - Timeline: {{When?}}

### Long-Term Actions
- {{Long-term recommendation 1}}
- {{Long-term recommendation 2}}

---

## 10. Next Steps

### Follow-Up Analysis
{{What additional analysis should be conducted?}}

### Monitoring
{{What metrics should be tracked going forward?}}

### Decision Timeline
{{When does a decision need to be made?}}

---

## Appendix

### A. Data Dictionary

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| {{field1}} | {{type}} | {{description}} | {{example}} |

### B. Code Repository

{{Link to GitHub/notebook with full analysis code}}

### C. Raw Data

{{Link to raw data files or database queries}}

---

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Analyst | {{Name}} | {{Date}} | ✅ |
| Data Lead | {{Name}} | {{Date}} |  |
| Stakeholder | {{Name}} | {{Date}} |  |
