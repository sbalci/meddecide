# meddecide: Medical Decision Analysis with Oncology Data

## Introduction

This vignette demonstrates medical decision analysis using the meddecide
module with oncology datasets from the `OncoDataSets` package. We’ll
cover diagnostic test evaluation, ROC analysis, decision curves, and
decision tree modeling.

## Loading Required Packages

``` r


library(OncoDataSets)
library(dplyr)
library(knitr)
```

## Example 1: PSA for Prostate Cancer Detection

The PSA dataset contains prostate-specific antigen measurements and
cancer outcomes.

``` r

data("PSAProstateCancer_df")

# Dataset overview
str(PSAProstateCancer_df)
#> 'data.frame':    97 obs. of  9 variables:
#>  $ lcavol : num  -0.58 -0.994 -0.511 -1.204 0.751 ...
#>  $ lweight: num  2.77 3.32 2.69 3.28 3.43 ...
#>  $ age    : int  50 58 74 58 62 50 64 58 47 63 ...
#>  $ lbph   : num  -1.39 -1.39 -1.39 -1.39 -1.39 ...
#>  $ svi    : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ lcp    : num  -1.39 -1.39 -1.39 -1.39 -1.39 ...
#>  $ gleason: int  6 6 7 6 6 6 6 6 6 6 ...
#>  $ pgg45  : int  0 0 20 0 0 0 0 0 0 0 ...
#>  $ lpsa   : num  -0.431 -0.163 -0.163 -0.163 0.372 ...

# Create binary outcome for high-grade cancer
PSAProstateCancer_df$high_grade <- ifelse(PSAProstateCancer_df$gleason >= 7, 1, 0)

# PSA levels (back-transform from log)
PSAProstateCancer_df$psa <- exp(PSAProstateCancer_df$lpsa)

summary(PSAProstateCancer_df$psa)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>    0.65    5.65   13.35   23.74   21.25  265.85
table(PSAProstateCancer_df$high_grade)
#> 
#>  0  1 
#> 35 62
```

### ROC Analysis for PSA

``` r

# In jamovi:
# 1. Select Analyses → meddecide → ROC Analysis
# 2. Set 'psa' as test variable
# 3. Set 'high_grade' as state variable (1 = disease)
# 4. Enable:
#    - ROC curve with confidence bands
#    - Optimal cutoff calculation
#    - Sensitivity/specificity table
#    - Likelihood ratios
```

### Multiple Biomarker Comparison

Compare PSA with other clinical factors:

``` r

# In jamovi:
# 1. Select Analyses → meddecide → ROC Comparison
# 2. Add multiple test variables:
#    - psa
#    - age
#    - lweight (log prostate weight)
# 3. Compare AUCs with DeLong test
# 4. Generate comparative ROC plot
```

### Decision Curve Analysis

Evaluate clinical utility across different threshold probabilities:

``` r

# In jamovi:
# 1. Select Analyses → meddecide → Decision Curve
# 2. Add PSA-based model
# 3. Compare with:
#    - Treat all strategy
#    - Treat none strategy
# 4. Set threshold probability range (0-50%)
# 5. Calculate net benefit
```

## Example 2: CA19-9 for Pancreatic Cancer

Meta-analysis data for CA19-9 diagnostic accuracy:

``` r

data("CA19PancreaticCancer_df")

# Dataset structure (diagnostic accuracy studies)
str(CA19PancreaticCancer_df)
#> Classes 'data.table' and 'data.frame':   22 obs. of  5 variables:
#>  $ study: chr  "Andriulli" "Benini" "DelFavero" "Gupta" ...
#>  $ TP   : int  64 23 18 13 74 27 20 11 19 32 ...
#>  $ FP   : int  148 7 20 64 23 27 39 5 49 10 ...
#>  $ FN   : int  12 2 6 4 21 13 4 3 6 5 ...
#>  $ TN   : int  294 118 29 589 83 265 103 43 172 29 ...

# Calculate sensitivity and specificity for each study
CA19PancreaticCancer_df <- CA19PancreaticCancer_df %>%
  mutate(
    sensitivity = TP / (TP + FN),
    specificity = TN / (TN + FP),
    total_n = TP + FP + FN + TN
  )

kable(CA19PancreaticCancer_df[1:5, c("study", "sensitivity", "specificity", "total_n")])
```

| study     | sensitivity | specificity | total_n |
|:----------|------------:|------------:|--------:|
| Andriulli |   0.8421053 |   0.6651584 |     518 |
| Benini    |   0.9200000 |   0.9440000 |     150 |
| DelFavero |   0.7500000 |   0.5918367 |      73 |
| Gupta     |   0.7647059 |   0.9019908 |     670 |
| Haglund   |   0.7789474 |   0.7830189 |     201 |

### Meta-analysis of Diagnostic Accuracy

``` r

# In jamovi:
# 1. Select Analyses → meddecide → Diagnostic Meta-analysis
# 2. Input TP, FP, FN, TN for each study
# 3. Enable:
#    - Summary ROC curve
#    - Heterogeneity assessment
#    - Forest plots
#    - Publication bias analysis
```

### Bayesian Analysis

Calculate post-test probabilities:

``` r

# In jamovi:
# 1. Select Analyses → meddecide → Bayesian Calculator
# 2. Input pooled sensitivity/specificity
# 3. Set pre-test probabilities (prevalence)
# 4. Calculate:
#    - Positive predictive value
#    - Negative predictive value
#    - Post-test probability curves
```

## Example 3: Lung Nodule Evaluation

``` r

data("LungNodulesDetected_df")

# Dataset overview
str(LungNodulesDetected_df)
#> Classes 'data.table' and 'data.frame':   999 obs. of  8 variables:
#>  $ sex          : Factor w/ 2 levels "F","M": 2 2 1 1 2 2 2 1 1 2 ...
#>  $ age          : num  84 53.9 75.5 66.1 47.8 38.6 77.9 77.5 46.6 67.8 ...
#>  $ num.annotated: num  0 0 0 0 0 0 0 0 0 0 ...
#>  $ location     : Factor w/ 6 levels "Lingular Segment",..: 5 1 5 5 4 1 2 3 3 6 ...
#>  $ spiculate    : Factor w/ 2 levels "No","Yes": 1 1 1 1 1 1 1 2 1 1 ...
#>  $ smoke.status : Factor w/ 5 levels "current","exsmoke",..: 4 4 4 4 4 4 4 4 4 4 ...
#>  $ diameter     : num  5 7 8 5 5 6 7 11 5 10 ...
#>  $ malignant    : num  0 0 0 0 0 0 0 0 0 0 ...
#>  - attr(*, ".internal.selfref")=<pointer: 0x0>

# Malignancy by nodule characteristics
table(LungNodulesDetected_df$spiculate, LungNodulesDetected_df$malignant)
#>      
#>         0   1
#>   No  665  85
#>   Yes 110 139
table(cut(LungNodulesDetected_df$diameter, c(0, 5, 10, 20, Inf)), 
      LungNodulesDetected_df$malignant)
#>           
#>              0   1
#>   (0,5]    166   7
#>   (5,10]   506  70
#>   (10,20]  103 147
#>   (20,Inf]   0   0
```

### Decision Tree for Nodule Management

``` r

# In jamovi:
# 1. Select Analyses → meddecide → Decision Tree
# 2. Create decision nodes:
#    - Nodule detected
#    - Size > 8mm?
#    - Spiculated?
#    - Biopsy vs. follow-up
# 3. Input probabilities:
#    - Malignancy rates by size/features
#    - Test characteristics (biopsy sensitivity/specificity)
# 4. Input utilities/costs:
#    - Early detection benefit
#    - Biopsy complications
#    - Anxiety from follow-up
# 5. Calculate expected values
```

### Clinical Decision Rule Development

``` r

# In jamovi:
# 1. Use Classification Analysis
# 2. Predictors: diameter, spiculate, age, smoking
# 3. Outcome: malignant
# 4. Methods:
#    - Logistic regression
#    - Decision tree (CART)
#    - Random forest
# 5. Validate with cross-validation
# 6. Create clinical scoring system
```

## Example 4: Comparative Effectiveness

Using multiple datasets to compare diagnostic strategies:

### Prostate Cancer Screening Strategies

``` r

# In jamovi:
# 1. Select Analyses → meddecide → Decision Compare
# 2. Define strategies:
#    - PSA alone (cutoff 4.0)
#    - PSA + age adjustment
#    - PSA + free/total ratio
#    - MRI-based screening
# 3. Input:
#    - Test characteristics
#    - Costs
#    - Quality-adjusted life years
# 4. Perform cost-effectiveness analysis
# 5. Generate efficiency frontier
```

## Example 5: Markov Model for Cancer Progression

Long-term outcomes modeling:

``` r

# In jamovi:
# 1. Select Analyses → meddecide → Decision Tree (Markov mode)
# 2. Define health states:
#    - No cancer
#    - Localized cancer
#    - Advanced cancer
#    - Death
# 3. Input transition probabilities
# 4. Set cycle length (e.g., 1 year)
# 5. Time horizon (e.g., lifetime)
# 6. Calculate:
#    - Life expectancy
#    - Quality-adjusted life years
#    - Incremental cost-effectiveness
```

## Practical Applications

### 1. Biomarker Cutoff Optimization

``` r

# Workflow:
# 1. ROC analysis to assess discrimination
# 2. Calculate optimal cutoffs for:
#    - Youden index (sensitivity + specificity)
#    - Clinical utility (weighted by consequences)
#    - Cost-effectiveness
# 3. Validate in independent dataset
```

### 2. Risk Prediction Model

``` r

# Using PSA data:
# 1. Develop multivariable model
# 2. Generate risk scores
# 3. Create risk categories
# 4. Decision curve analysis
# 5. Clinical impact assessment:
#    - Number needed to screen
#    - False positives avoided
#    - Cancers detected
```

### 3. Diagnostic Pathway Design

``` r

# Example: Lung nodule workup
# 1. Initial CT findings
# 2. Risk stratification (size, features)
# 3. Decision points:
#    - Immediate biopsy
#    - PET scan
#    - Short-term follow-up
#    - Annual screening
# 4. Calculate pathway efficiency
```

## Advanced Features

### Sensitivity Analysis

``` r

# In jamovi meddecide:
# 1. One-way sensitivity analysis
#    - Vary each parameter
#    - Identify threshold values
# 2. Two-way sensitivity analysis
#    - Vary two parameters simultaneously
#    - Create contour plots
# 3. Probabilistic sensitivity analysis
#    - Monte Carlo simulation
#    - Confidence ellipses
```

### Time-to-Event Integration

``` r

# Combine with survival data:
# 1. Time-dependent ROC curves
# 2. Dynamic decision curves
# 3. Landmark analysis
# 4. Risk prediction over time
```

## Best Practices

1.  **Define Clinical Question**: Clear objectives for decision analysis
2.  **Evidence Quality**: Document sources for probabilities/utilities
3.  **Perspective**: Specify (patient, provider, societal)
4.  **Uncertainty**: Always perform sensitivity analyses
5.  **Validation**: Test models in independent data

## Reporting Guidelines

### For Diagnostic Studies

- STARD checklist compliance
- Report all performance metrics
- Confidence intervals
- Clinical utility measures

### For Decision Analysis

- Model structure diagram
- Parameter sources
- Base case results
- Sensitivity analyses
- Clinical implications

## Integration Example

Complete diagnostic evaluation workflow:

``` r

# 1. Data Preparation
#    - Load OncoDataSets
#    - Define outcomes
#    - Handle missing data

# 2. Test Performance
#    - ROC analysis
#    - Optimal cutoffs
#    - Subgroup analyses

# 3. Clinical Utility
#    - Decision curves
#    - Net benefit calculation
#    - Number needed to test

# 4. Decision Modeling
#    - Build decision tree
#    - Input probabilities
#    - Calculate expected values

# 5. Sensitivity Analysis
#    - Test robustness
#    - Identify key drivers

# 6. Implementation
#    - Clinical algorithm
#    - Decision support tool
#    - Monitoring plan
```

## Conclusion

The meddecide module provides comprehensive tools for medical decision
analysis in oncology:

- Evaluate diagnostic test performance
- Compare multiple biomarkers
- Assess clinical utility beyond accuracy
- Model complex decision scenarios
- Support evidence-based clinical guidelines

Combined with `OncoDataSets`, researchers can develop and validate
decision support tools using real-world cancer data.

## References

- OncoDataSets package:
  <https://cran.r-project.org/package=OncoDataSets>
- meddecide documentation: <https://www.serdarbalci.com/meddecide/>
- Decision curve analysis:
  <https://www.mskcc.org/departments/epidemiology-biostatistics/biostatistics/decision-curve-analysis>
