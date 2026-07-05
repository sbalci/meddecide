# Advanced ROC Analysis (psychopdaROC) - Comprehensive Guide

## Advanced ROC Analysis (psychopdaROC)

### Overview

The **psychopdaROC** module provides advanced Receiver Operating
Characteristic (ROC) curve analysis with optimal cutpoint determination
using the `cutpointr` framework. It supports 12 cutpoint optimization
methods, 16 optimization metrics, subgroup analysis, DeLong’s test for
comparing ROC curves, IDI/NRI reclassification indices, effect size and
power analysis, bootstrap ROC with prior weighting, clinical utility
analysis, meta-analysis of AUC values, and fixed sensitivity/specificity
analysis.

All examples below use the bundled test datasets. In jamovi, open the
corresponding `.omv` file. From R, read the `.csv` directly.

------------------------------------------------------------------------

### Datasets Used in This Guide

| Dataset | N | Class Levels | Prevalence | Key Features | Primary Use |
|----|----|----|----|----|----|
| `psychopdaROC_test` | 200 | Healthy/Disease | ~50% | 1 biomarker, age, sex | Basic single-marker testing |
| `psychopdaROC_screening` | 250 | No Cancer/Cancer | ~25% | PSA, CA125 | Cancer screening |
| `psychopdaROC_cardiac` | 180 | No MI/MI | ~30% | Troponin, creatinine, BNP | Cardiac biomarkers |
| `psychopdaROC_multibiomarker` | 220 | Negative/Positive | ~30% | 3 markers + combined score | Multi-marker comparison |
| `psychopdaROC_subgroup` | 200 | No Disease/Disease | ~30% | test_score, age_group, sex | Subgroup analysis |
| `psychopdaROC_perfect` | 100 | Negative/Positive | 50% | Perfect separation | AUC=1.0 edge case |
| `psychopdaROC_poor` | 150 | Negative/Positive | ~50% | No discrimination | AUC~0.5 edge case |
| `psychopdaROC_overlap` | 190 | Negative/Positive | ~50% | Moderate overlap | AUC~0.70 |
| `psychopdaROC_rare` | 300 | No Disease/Disease | 5% | Single biomarker | Rare disease |
| `psychopdaROC_costbenefit` | 160 | No Event/Event | ~30% | Risk score, cost columns | Cost-benefit optimization |
| `psychopdaROC_spectrum` | 170 | 3 severity + binary | varies | Continuous marker | Disease spectrum |
| `psychopdaROC_timedep` | 140 | No Event/Event | ~30% | Baseline + follow-up | Longitudinal comparison |
| `psychopdaROC_small` | 30 | Negative/Positive | ~50% | Single marker | Small sample edge case |
| `psychopdaROC_imbalanced` | 200 | No Event/Event | 2% | Single predictor | Extreme imbalance |
| `psychopdaROC_missing` | 150 | Negative/Positive | ~30% | 2 tests + covariate, NAs | Missing data handling |
| `psychopdaROC_constant` | 80 | No Event/Event | ~50% | Constant marker (all=50) | Zero variance edge case |
| `psychopdaROC_large` | 500 | No Disease/Disease | ~30% | 2 biomarkers, site | Large sample / subgroups |
| `psychopdaROC_advanced` | 250 | Negative/Positive | ~30% | 5 markers, site | Meta-analysis / advanced |

------------------------------------------------------------------------

### 1. Basic ROC Analysis (Default Cutpoint)

The default analysis uses Youden Index optimization (`maximize_metric`
with `youden`) to find the optimal cutpoint.

#### Default single-marker ROC

``` r

test_data <- read.csv(paste0(data_path, "psychopdaROC_test.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### With confusion matrix and threshold table

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  sensSpecTable = TRUE,
  showThresholdTable = TRUE,
  maxThresholds = 20,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Lower values indicate positive class

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  direction = "<=",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

------------------------------------------------------------------------

### 2. Cutpoint Optimization Methods

#### Key optimization metrics

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "maximize_metric",
  metric = "youden",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "maximize_metric",
  metric = "accuracy",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "maximize_metric",
  metric = "F1_score",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "maximize_metric",
  metric = "cohens_kappa",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Minimize misclassification cost

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "minimize_metric",
  metric = "misclassification_cost",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### LOESS-smoothed Youden

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "maximize_loess_metric",
  metric = "youden",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Bootstrap-optimized cutpoint

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "maximize_boot_metric",
  boot_runs = 200,
  seed = 123,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Kernel-smoothed Youden

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "oc_youden_kernel",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Parametric normal Youden

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "oc_youden_normal",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Manual cutpoint

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "oc_manual",
  specifyCutScore = "7.5",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Cost-benefit optimized cutpoint

``` r

costbenefit_data <- read.csv(paste0(data_path, "psychopdaROC_costbenefit.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = costbenefit_data,
  classVar = "outcome",
  positiveClass = "Event",
  dependentVars = "risk_score",
  method = "oc_cost_ratio",
  costratioFP = 0.1,
  refVar = NULL
)
#> Error:
#> ! object 'costbenefit_data' not found
```

#### Equal sensitivity and specificity

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "oc_equal_sens_spec",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Closest to perfect classifier (0,1)

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  method = "oc_closest_01",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

------------------------------------------------------------------------

### 3. Cutpoint Fine-Tuning

#### Metric tolerance

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  tol_metric = 0.01,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Tie-breaking methods

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  break_ties = "mean",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  break_ties = "median",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### All observed cutpoints

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  allObserved = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

------------------------------------------------------------------------

### 4. Multiple Test Variables (Comparative)

#### Multi-marker ROC overlay

``` r

multi_data <- read.csv(paste0(data_path, "psychopdaROC_multibiomarker.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = multi_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker1, marker2, marker3, combined_score),
  plotROC = TRUE,
  combinePlots = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'multi_data' not found
```

#### DeLong test for AUC comparison

``` r

psychopdaROC(
  data = multi_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker1, marker2, marker3),
  delongTest = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'multi_data' not found
```

#### Cardiac biomarker comparison

``` r

cardiac_data <- read.csv(paste0(data_path, "psychopdaROC_cardiac.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = cardiac_data,
  classVar = "mi_status",
  positiveClass = "MI",
  dependentVars = vars(troponin, creatinine, bnp),
  combinePlots = TRUE,
  delongTest = TRUE,
  refVar = NULL
)
#> Error:
#> ! Argument 'dependentVars' contains 'troponin', 'creatinine', 'bnp' which are not present in the dataset
```

------------------------------------------------------------------------

### 5. ROC Visualization Options

#### Optimal point and confidence bands

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  plotROC = TRUE,
  showOptimalPoint = TRUE,
  showConfidenceBands = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Smoothed ROC with standard error

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  smoothing = TRUE,
  displaySE = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Publication-ready clean plot

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  cleanPlot = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Legend positions

``` r

psychopdaROC(
  data = multi_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker1, marker2, marker3),
  combinePlots = TRUE,
  legendPosition = "bottom",
  refVar = NULL
)
#> Error:
#> ! object 'multi_data' not found
```

#### Direct curve labels

``` r

psychopdaROC(
  data = multi_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker1, marker2, marker3),
  combinePlots = TRUE,
  directLabel = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'multi_data' not found
```

------------------------------------------------------------------------

### 6. Diagnostic Plots

#### Sensitivity/Specificity vs Threshold

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  showCriterionPlot = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Predictive values vs Prevalence

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  showPrevalencePlot = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Test value distribution by class

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  showDotPlot = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Precision-Recall curve

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  precisionRecallCurve = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

------------------------------------------------------------------------

### 7. Prevalence & Prior Settings

#### Prior prevalence adjustment for rare disease

``` r

rare_data <- read.csv(paste0(data_path, "psychopdaROC_rare.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = rare_data,
  classVar = "rare_disease",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  usePriorPrev = TRUE,
  priorPrev = 0.05,
  refVar = NULL
)
#> Error:
#> ! object 'rare_data' not found
```

#### Sample prevalence (default)

``` r

psychopdaROC(
  data = rare_data,
  classVar = "rare_disease",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  usePriorPrev = FALSE,
  refVar = NULL
)
#> Error:
#> ! object 'rare_data' not found
```

------------------------------------------------------------------------

### 8. Subgroup Analysis

#### By age group

``` r

subgroup_data <- read.csv(paste0(data_path, "psychopdaROC_subgroup.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = subgroup_data,
  classVar = "disease",
  positiveClass = "Disease",
  dependentVars = "test_score",
  subGroup = "age_group",
  refVar = NULL
)
#> Error:
#> ! object 'subgroup_data' not found
```

#### By sex

``` r

psychopdaROC(
  data = subgroup_data,
  classVar = "disease",
  positiveClass = "Disease",
  dependentVars = "test_score",
  subGroup = "sex",
  refVar = NULL
)
#> Error:
#> ! object 'subgroup_data' not found
```

#### Large dataset with site subgroups

``` r

large_data <- read.csv(paste0(data_path, "psychopdaROC_large.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = large_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = vars(biomarker1, biomarker2),
  subGroup = "site",
  refVar = NULL
)
#> Error:
#> ! object 'large_data' not found
```

------------------------------------------------------------------------

### 9. Advanced ROC Analysis

#### Partial AUC (high specificity region)

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  partialAUC = TRUE,
  partialAUCfrom = 0.8,
  partialAUCto = 1.0,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Partial AUC (very high specificity)

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  partialAUC = TRUE,
  partialAUCfrom = 0.9,
  partialAUCto = 1.0,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Binormal smoothing

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  rocSmoothingMethod = "binormal",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Bootstrap confidence intervals

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  bootstrapCI = TRUE,
  bootstrapReps = 200,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Quantile-based CIs

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  quantileCIs = TRUE,
  quantiles = "0.1,0.25,0.5,0.75,0.9",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

------------------------------------------------------------------------

### 10. Fixed Sensitivity / Specificity Analysis

#### Fixed sensitivity for screening (95%)

``` r

screening_data <- read.csv(paste0(data_path, "psychopdaROC_screening.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = screening_data,
  classVar = "cancer",
  positiveClass = "Cancer",
  dependentVars = "psa_level",
  fixedSensSpecAnalysis = TRUE,
  fixedAnalysisType = "sensitivity",
  fixedSensitivityValue = 0.95,
  refVar = NULL
)
#> Error:
#> ! object 'screening_data' not found
```

#### Fixed specificity for confirmation (90%)

``` r

psychopdaROC(
  data = screening_data,
  classVar = "cancer",
  positiveClass = "Cancer",
  dependentVars = "psa_level",
  fixedSensSpecAnalysis = TRUE,
  fixedAnalysisType = "specificity",
  fixedSpecificityValue = 0.90,
  refVar = NULL
)
#> Error:
#> ! object 'screening_data' not found
```

#### Interpolation methods

``` r

psychopdaROC(
  data = screening_data,
  classVar = "cancer",
  positiveClass = "Cancer",
  dependentVars = "psa_level",
  fixedSensSpecAnalysis = TRUE,
  fixedAnalysisType = "sensitivity",
  fixedSensitivityValue = 0.95,
  fixedInterpolation = "linear",
  refVar = NULL
)
#> Error:
#> ! object 'screening_data' not found
```

#### Fixed ROC plot with explanation

``` r

psychopdaROC(
  data = screening_data,
  classVar = "cancer",
  positiveClass = "Cancer",
  dependentVars = "psa_level",
  fixedSensSpecAnalysis = TRUE,
  fixedAnalysisType = "sensitivity",
  fixedSensitivityValue = 0.95,
  showFixedROC = TRUE,
  showFixedExplanation = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'screening_data' not found
```

------------------------------------------------------------------------

### 11. Model Comparison (IDI / NRI)

#### Integrated Discrimination Improvement (IDI)

``` r

psychopdaROC(
  data = multi_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker1, marker2, marker3),
  calculateIDI = TRUE,
  refVar = NULL,
  idiNriBootRuns = 200
)
#> Error:
#> ! object 'multi_data' not found
```

#### Category-based Net Reclassification Index (NRI)

``` r

psychopdaROC(
  data = multi_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker1, marker2, marker3),
  calculateNRI = TRUE,
  refVar = NULL,
  nriThresholds = "0.3,0.7"
)
#> Error:
#> ! object 'multi_data' not found
```

#### Continuous NRI (no thresholds)

``` r

psychopdaROC(
  data = multi_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker1, marker2, marker3),
  calculateNRI = TRUE,
  refVar = NULL,
  nriThresholds = ""
)
#> Error:
#> ! object 'multi_data' not found
```

#### Comprehensive classifier comparison

``` r

psychopdaROC(
  data = multi_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker1, marker2, marker3),
  compareClassifiers = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'multi_data' not found
```

------------------------------------------------------------------------

### 12. Effect Size & Power Analysis

#### Effect size analysis

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  effectSizeAnalysis = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Post-hoc power analysis

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  powerAnalysis = TRUE,
  powerAnalysisType = "post_hoc",
  significanceLevel = 0.05,
  targetPower = 0.80,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Prospective power analysis

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  powerAnalysis = TRUE,
  powerAnalysisType = "prospective",
  expectedAUCDifference = 0.10,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Sample size estimation

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  powerAnalysis = TRUE,
  powerAnalysisType = "sample_size",
  correlationROCs = 0.5,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

------------------------------------------------------------------------

### 13. Bootstrap ROC with Prior Weighting

#### Default prior (AUC=0.7, precision=10)

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  bayesianAnalysis = TRUE,
  priorAUC = 0.7,
  priorPrecision = 10,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Strong prior belief (AUC=0.9, high precision)

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  bayesianAnalysis = TRUE,
  priorAUC = 0.9,
  priorPrecision = 50,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

------------------------------------------------------------------------

### 14. Clinical Utility Analysis

#### Decision curve analysis

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  clinicalUtilityAnalysis = TRUE,
  treatmentThreshold = "0.05,0.5,0.05",
  harmBenefitRatio = 0.25,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### With intervention cost analysis

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  clinicalUtilityAnalysis = TRUE,
  interventionCost = TRUE,
  harmBenefitRatio = 1.0,
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

------------------------------------------------------------------------

### 15. Meta-Analysis (3+ Variables Required)

#### Fixed and random effects meta-analysis

``` r

advanced_data <- read.csv(paste0(data_path2, "psychopdaROC_advanced.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = advanced_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker_excellent, marker_good, marker_moderate,
                       marker_fair, marker_poor),
  metaAnalysis = TRUE,
  metaAnalysisMethod = "both",
  heterogeneityTest = TRUE,
  overrideMetaAnalysisWarning = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'advanced_data' not found
```

#### Forest plot

``` r

psychopdaROC(
  data = advanced_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker_excellent, marker_good, marker_moderate,
                       marker_fair, marker_poor),
  metaAnalysis = TRUE,
  metaAnalysisMethod = "both",
  forestPlot = TRUE,
  overrideMetaAnalysisWarning = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'advanced_data' not found
```

#### Fixed effects only (3 markers)

``` r

psychopdaROC(
  data = advanced_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker_excellent, marker_good, marker_moderate),
  metaAnalysis = TRUE,
  metaAnalysisMethod = "fixed",
  overrideMetaAnalysisWarning = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'advanced_data' not found
```

------------------------------------------------------------------------

### 16. Clinical Mode Presets

#### Basic mode (minimal clinical output)

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  clinicalMode = "basic",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Advanced mode

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  clinicalMode = "advanced",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Comprehensive mode (full research-grade output)

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  clinicalMode = "comprehensive",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

#### Screening preset

``` r

psychopdaROC(
  data = screening_data,
  classVar = "cancer",
  positiveClass = "Cancer",
  dependentVars = "psa_level",
  clinicalPreset = "screening",
  refVar = NULL
)
#> Error:
#> ! object 'screening_data' not found
```

#### Confirmation preset

``` r

psychopdaROC(
  data = cardiac_data,
  classVar = "mi_status",
  positiveClass = "MI",
  dependentVars = "troponin",
  clinicalPreset = "confirmation",
  refVar = NULL
)
#> Error:
#> ! Argument 'dependentVars' contains 'troponin' which is not present in the dataset
```

#### Balanced and research presets

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  clinicalPreset = "balanced",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

``` r

psychopdaROC(
  data = test_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  clinicalPreset = "research",
  refVar = NULL
)
#> Error:
#> ! object 'test_data' not found
```

------------------------------------------------------------------------

### 17. Edge Cases

#### Perfect separation (AUC=1.0)

``` r

perfect_data <- read.csv(paste0(data_path, "psychopdaROC_perfect.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = perfect_data,
  classVar = "condition",
  positiveClass = "Positive",
  dependentVars = "perfect_test",
  refVar = NULL
)
#> Error:
#> ! object 'perfect_data' not found
```

#### No discrimination (AUC~0.5)

``` r

poor_data <- read.csv(paste0(data_path, "psychopdaROC_poor.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = poor_data,
  classVar = "status",
  positiveClass = "Case",
  dependentVars = "poor_marker",
  refVar = NULL
)
#> Error:
#> ! object 'poor_data' not found
```

#### Moderate overlap (AUC~0.70)

``` r

overlap_data <- read.csv(paste0(data_path, "psychopdaROC_overlap.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = overlap_data,
  classVar = "diagnosis",
  positiveClass = "Diseased",
  dependentVars = "test_value",
  refVar = NULL
)
#> Error:
#> ! object 'overlap_data' not found
```

#### Small sample (n=30)

``` r

small_data <- read.csv(paste0(data_path, "psychopdaROC_small.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = small_data,
  classVar = "class",
  positiveClass = "Positive",
  dependentVars = "marker",
  refVar = NULL
)
#> Error:
#> ! object 'small_data' not found
```

#### Extreme imbalance (2% event rate)

``` r

imbalanced_data <- read.csv(paste0(data_path, "psychopdaROC_imbalanced.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = imbalanced_data,
  classVar = "rare_outcome",
  positiveClass = "Event",
  dependentVars = "predictor",
  refVar = NULL
)
#> Error:
#> ! object 'imbalanced_data' not found
```

#### Constant predictor (zero variance)

``` r

constant_data <- read.csv(paste0(data_path, "psychopdaROC_constant.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = constant_data,
  classVar = "outcome",
  positiveClass = "Positive",
  dependentVars = "constant_marker",
  refVar = NULL
)
#> Error:
#> ! object 'constant_data' not found
```

#### Missing data

``` r

missing_data <- read.csv(paste0(data_path, "psychopdaROC_missing.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = missing_data,
  classVar = "diagnosis",
  positiveClass = "Disease",
  dependentVars = vars(test_a, test_b),
  refVar = NULL
)
#> Error:
#> ! object 'missing_data' not found
```

#### Rare disease (5% prevalence)

``` r

psychopdaROC(
  data = rare_data,
  classVar = "rare_disease",
  positiveClass = "Disease",
  dependentVars = "biomarker",
  refVar = NULL
)
#> Error:
#> ! object 'rare_data' not found
```

#### Large dataset (n=500)

``` r

psychopdaROC(
  data = large_data,
  classVar = "disease_status",
  positiveClass = "Disease",
  dependentVars = vars(biomarker1, biomarker2),
  refVar = NULL
)
#> Error:
#> ! object 'large_data' not found
```

------------------------------------------------------------------------

### 18. Time-Dependent & Spectrum Analysis

#### Compare baseline vs follow-up markers

``` r

timedep_data <- read.csv(paste0(data_path, "psychopdaROC_timedep.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = timedep_data,
  classVar = "outcome",
  positiveClass = "Event",
  dependentVars = vars(baseline_marker, followup_marker),
  delongTest = TRUE,
  combinePlots = TRUE,
  refVar = NULL
)
#> Error:
#> ! object 'timedep_data' not found
```

#### Disease spectrum data

``` r

spectrum_data <- read.csv(paste0(data_path, "psychopdaROC_spectrum.csv"))
#> Error in `file()`:
#> ! cannot open the connection

psychopdaROC(
  data = spectrum_data,
  classVar = "binary_status",
  positiveClass = "Positive",
  dependentVars = "continuous_marker",
  refVar = NULL
)
#> Error:
#> ! object 'spectrum_data' not found
```

------------------------------------------------------------------------

### 19. Comprehensive Publication-Ready Scenario

Full research-grade analysis combining multiple features.

``` r

psychopdaROC(
  data = multi_data,
  classVar = "diagnosis",
  positiveClass = "Positive",
  dependentVars = vars(marker1, marker2, marker3, combined_score),
  clinicalMode = "comprehensive",
  method = "maximize_metric",
  metric = "youden",
  delongTest = TRUE,
  calculateIDI = TRUE,
  calculateNRI = TRUE,
  refVar = NULL,
  bootstrapCI = TRUE,
  bootstrapReps = 200,
  clinicalUtilityAnalysis = TRUE,
  plotROC = TRUE,
  combinePlots = TRUE,
  cleanPlot = TRUE,
  sensSpecTable = TRUE
)
#> Error:
#> ! object 'multi_data' not found
```

------------------------------------------------------------------------

### References

- Youden WJ (1950). Index for rating diagnostic tests. *Cancer*, 3(1),
  32-35.
- DeLong ER, DeLong DM, Clarke-Pearson DL (1988). Comparing the areas
  under two or more correlated receiver operating characteristic curves:
  a nonparametric approach. *Biometrics*, 44(3), 837-845.
- Pencina MJ, D’Agostino RB, D’Agostino RB Jr, Vasan RS (2008).
  Evaluating the added predictive ability of a new marker: from area
  under the ROC curve to reclassification and beyond. *Statistics in
  Medicine*, 27(2), 157-172.
- Thiele C, Hirschfeld G (2021). cutpointr: Improved estimation and
  validation of optimal cutpoints in R. *Journal of Statistical
  Software*, 98(11), 1-27.
- Robin X, Turck N, Hainard A, et al. (2011). pROC: an open-source
  package for R and S+ to analyze and compare ROC curves. *BMC
  Bioinformatics*, 12, 77.
- Vickers AJ, Elkin EB (2006). Decision curve analysis: a novel method
  for evaluating prediction models. *Medical Decision Making*, 26(6),
  565-574.
