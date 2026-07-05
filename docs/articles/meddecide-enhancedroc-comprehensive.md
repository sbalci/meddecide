# Clinical ROC Analysis (enhancedROC) - Comprehensive Guide

## Clinical ROC Analysis (enhancedROC)

### Overview

The **enhancedROC** module provides comprehensive Receiver Operating
Characteristic (ROC) curve analysis for clinical diagnostic performance
evaluation. It includes ROC curve analysis, Youden Index optimization,
sensitivity/specificity analysis, optimal cutoff determination,
comparative ROC analysis, calibration assessment, multi-class ROC,
clinical impact metrics, and class imbalance detection.

All examples below use the bundled test datasets. In jamovi, open the
corresponding `.omv` file. From R, read the `.csv` directly.

------------------------------------------------------------------------

### Datasets Used in This Guide

| Dataset | N | Outcome | Prevalence | Key Features | Primary Use |
|----|----|----|----|----|----|
| `enhancedroc_biomarker` | 300 | Disease/Healthy | 30% | 3 biomarkers + clinical risk score | Single biomarker validation |
| `enhancedroc_comparative` | 400 | Cancer/No Cancer | 25% | 5 markers (varying AUCs) | Compare diagnostic tests |
| `enhancedroc_imbalanced` | 500 | Positive/Negative | 5% | Rare disease, screening/confirmatory markers | Imbalanced data handling |
| `enhancedroc_multiclass` | 350 | 4 severity levels | Mixed | 3 biomarkers | Multi-class severity grading |
| `enhancedroc_calibration` | 300 | Event/No Event | 35% | Predicted probs + risk score | Calibration assessment |
| `enhancedroc_screening` | 600 | Screen Pos/Neg | 8% | High-sensitivity markers | Screening context |
| `enhancedroc_confirmatory` | 250 | Confirmed/Not | 45% | High-specificity markers | Confirmatory testing |
| `enhancedroc_small` | 60 | Positive/Negative | 30% | Single simple marker | Small sample testing |
| `enhancedroc_validation` | 350 | Positive/Negative | 30% | Probability predictors, biomarker | CROC / convex hull |
| `enhancedroc_tiedscores` | 200 | Disease/No Disease | 35% | Ordinal scores (many ties) | Tied score handling |

------------------------------------------------------------------------

### 1. Single Biomarker Analysis (Default)

The default analysis computes a single ROC curve with AUC, optimal
cutoff via Youden Index, and diagnostic performance metrics.

#### Basic single ROC

``` r

biomarker_data <- read.csv(paste0(data_path, "enhancedroc_biomarker.csv"))
#> Error in `file()`:
#> ! cannot open the connection

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### With cutoff table and clinical metrics

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  cutoffTable = TRUE,
  clinicalMetrics = TRUE,
  prevalence = 0.30,
  useObservedPrevalence = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### Direction control and custom cutoffs

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  direction = "higher",
  customCutoffs = "5.0,7.5,10.0"
)
#> Error:
#> ! object 'biomarker_data' not found
```

------------------------------------------------------------------------

### 2. Comparative ROC Analysis (Multiple Predictors)

Compare diagnostic performance across multiple biomarkers using DeLong’s
test.

#### Five-marker comparison with DeLong

``` r

comparative_data <- read.csv(paste0(data_path, "enhancedroc_comparative.csv"))
#> Error in `file()`:
#> ! cannot open the connection

enhancedROC(
  data = comparative_data,
  outcome = "cancer_status",
  positiveClass = "Cancer",
  predictors = vars(established_marker, novel_marker1, novel_marker2,
                    imaging_score, genetic_risk_score),
  analysisType = "comparative",
  pairwiseComparisons = TRUE,
  comparisonMethod = "delong",
  customCutoffs = NULL
)
#> Error:
#> ! object 'comparative_data' not found
```

#### Bootstrap comparison with metrics differences

``` r

enhancedROC(
  data = comparative_data,
  outcome = "cancer_status",
  positiveClass = "Cancer",
  predictors = vars(established_marker, novel_marker1),
  analysisType = "comparative",
  comparisonMethod = "bootstrap",
  bootstrapSamples = 200,
  showMetricsDiff = TRUE,
  statisticalComparison = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'comparative_data' not found
```

#### Comprehensive analysis with clinical interpretation

``` r

enhancedROC(
  data = comparative_data,
  outcome = "cancer_status",
  positiveClass = "Cancer",
  predictors = vars(established_marker, novel_marker1, novel_marker2,
                    imaging_score, genetic_risk_score),
  analysisType = "comprehensive",
  comprehensive_output = TRUE,
  clinical_interpretation = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'comparative_data' not found
```

------------------------------------------------------------------------

### 3. Bootstrap & Confidence Intervals

#### BCa bootstrap confidence intervals

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  useBootstrap = TRUE,
  bootstrapSamples = 200,
  bootstrapMethod = "bca",
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### Percentile bootstrap with stratification

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  useBootstrap = TRUE,
  bootstrapSamples = 200,
  bootstrapMethod = "percentile",
  stratifiedBootstrap = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### 90% CI with bootstrap CIs for cutoff and partial AUC

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  confidenceLevel = 90,
  useBootstrap = TRUE,
  bootstrapSamples = 200,
  bootstrapCutoffCI = TRUE,
  bootstrapPartialAUC = TRUE,
  partialAuc = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

------------------------------------------------------------------------

### 4. ROC Curve Plot Options

#### Clinical theme with cutoff points and confidence bands

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  rocCurve = TRUE,
  showCutoffPoints = TRUE,
  showConfidenceBands = TRUE,
  plotTheme = "clinical",
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### Classic theme with custom dimensions

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  rocCurve = TRUE,
  plotTheme = "classic",
  plotWidth = 800,
  plotHeight = 800,
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### Comparative ROC overlay plot

``` r

enhancedROC(
  data = comparative_data,
  outcome = "cancer_status",
  positiveClass = "Cancer",
  predictors = vars(established_marker, novel_marker1),
  analysisType = "comparative",
  rocCurve = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'comparative_data' not found
```

------------------------------------------------------------------------

### 5. Youden Index & Cutoff Analysis

#### Youden Index plot

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  youdenOptimization = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### Cutoff analysis plot

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  cutoffTable = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### Clinical decision plot

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  clinicalMetrics = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

------------------------------------------------------------------------

### 6. Advanced ROC Methods

#### Binormal smoothing

``` r

validation_data <- read.csv(paste0(data_path2, "enhancedroc_validation.csv"))
#> Error in `file()`:
#> ! cannot open the connection

enhancedROC(
  data = validation_data,
  outcome = "outcome",
  positiveClass = "Positive",
  predictors = "biomarker",
  smoothMethod = "binormal",
  customCutoffs = NULL
)
#> Error:
#> ! object 'validation_data' not found
```

#### Partial AUC (high specificity region)

``` r

enhancedROC(
  data = validation_data,
  outcome = "outcome",
  positiveClass = "Positive",
  predictors = "biomarker",
  partialAuc = TRUE,
  partialAucType = "specificity",
  partialRange = "0.8,1.0",
  customCutoffs = NULL
)
#> Error:
#> ! object 'validation_data' not found
```

#### Partial AUC (high sensitivity region)

``` r

enhancedROC(
  data = validation_data,
  outcome = "outcome",
  positiveClass = "Positive",
  predictors = "biomarker",
  partialAuc = TRUE,
  partialAucType = "sensitivity",
  partialRange = "0.9,1.0",
  customCutoffs = NULL
)
#> Error:
#> ! object 'validation_data' not found
```

#### CROC analysis (Concentrated ROC)

``` r

enhancedROC(
  data = validation_data,
  outcome = "outcome",
  positiveClass = "Positive",
  predictors = "biomarker",
  crocAnalysis = TRUE,
  crocAlpha = 7.0,
  customCutoffs = NULL
)
#> Error:
#> ! object 'validation_data' not found
```

#### Convex hull analysis

``` r

enhancedROC(
  data = validation_data,
  outcome = "outcome",
  positiveClass = "Positive",
  predictors = "biomarker",
  convexHull = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'validation_data' not found
```

#### Tied score handling

``` r

tied_data <- read.csv(paste0(data_path2, "enhancedroc_tiedscores.csv"))
#> Error in `file()`:
#> ! cannot open the connection

enhancedROC(
  data = tied_data,
  outcome = "disease",
  positiveClass = "Disease",
  predictors = vars(ordinal_score, rounded_lab, composite_score),
  tiedScoreHandling = "average",
  customCutoffs = NULL
)
#> Error:
#> ! object 'tied_data' not found
```

------------------------------------------------------------------------

### 7. Sensitivity & Specificity Thresholds

#### Screening context: high sensitivity threshold

``` r

screening_data <- read.csv(paste0(data_path, "enhancedroc_screening.csv"))
#> Error in `file()`:
#> ! cannot open the connection

enhancedROC(
  data = screening_data,
  outcome = "screening_indication",
  positiveClass = "Screen Positive",
  predictors = "sensitive_marker",
  sensitivityThreshold = 0.95,
  specificityThreshold = 0.5,
  customCutoffs = NULL
)
#> Error:
#> ! object 'screening_data' not found
```

#### Confirmatory context: high specificity threshold

``` r

confirmatory_data <- read.csv(paste0(data_path, "enhancedroc_confirmatory.csv"))
#> Error in `file()`:
#> ! cannot open the connection

enhancedROC(
  data = confirmatory_data,
  outcome = "confirmed_diagnosis",
  positiveClass = "Confirmed",
  predictors = "specific_marker",
  sensitivityThreshold = 0.5,
  specificityThreshold = 0.95,
  customCutoffs = NULL
)
#> Error:
#> ! object 'confirmatory_data' not found
```

------------------------------------------------------------------------

### 8. Class Imbalance Detection

#### Imbalance detection with PRC recommendation

``` r

imbalanced_data <- read.csv(paste0(data_path, "enhancedroc_imbalanced.csv"))
#> Error in `file()`:
#> ! cannot open the connection

enhancedROC(
  data = imbalanced_data,
  outcome = "rare_disease",
  positiveClass = "Positive",
  predictors = vars(screening_marker, confirmatory_marker),
  detectImbalance = TRUE,
  imbalanceThreshold = 3.0,
  showImbalanceWarning = TRUE,
  recommendPRC = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'imbalanced_data' not found
```

#### Lower imbalance threshold (more sensitive detection)

``` r

enhancedROC(
  data = imbalanced_data,
  outcome = "rare_disease",
  positiveClass = "Positive",
  predictors = "screening_marker",
  detectImbalance = TRUE,
  imbalanceThreshold = 1.5,
  customCutoffs = NULL
)
#> Error:
#> ! object 'imbalanced_data' not found
```

------------------------------------------------------------------------

### 9. Clinical Context & Presets

#### Biomarker screening preset

``` r

enhancedROC(
  data = screening_data,
  outcome = "screening_indication",
  positiveClass = "Screen Positive",
  predictors = "sensitive_marker",
  clinicalContext = "screening",
  clinicalPresets = "biomarker_screening",
  customCutoffs = NULL
)
#> Error:
#> ! object 'screening_data' not found
```

#### Confirmatory testing preset

``` r

enhancedROC(
  data = confirmatory_data,
  outcome = "confirmed_diagnosis",
  positiveClass = "Confirmed",
  predictors = "specific_marker",
  clinicalContext = "diagnosis",
  clinicalPresets = "confirmatory_testing",
  customCutoffs = NULL
)
#> Error:
#> ! object 'confirmatory_data' not found
```

#### Diagnostic validation preset (balanced)

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  clinicalContext = "prognosis",
  clinicalPresets = "diagnostic_validation",
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### Research comprehensive preset

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = vars(biomarker1, biomarker2, clinical_risk_score),
  clinicalPresets = "research_comprehensive",
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### Monitoring context with custom settings

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  clinicalContext = "monitoring",
  clinicalPresets = "custom",
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

------------------------------------------------------------------------

### 10. Calibration Analysis

#### Full calibration assessment

``` r

calibration_data <- read.csv(paste0(data_path, "enhancedroc_calibration.csv"))
#> Error in `file()`:
#> ! cannot open the connection

enhancedROC(
  data = calibration_data,
  outcome = "outcome",
  positiveClass = "Event",
  predictors = vars(predicted_prob, risk_score),
  calibrationAnalysis = TRUE,
  calibrationPlot = TRUE,
  brierScore = TRUE,
  calibrationMetrics = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'calibration_data' not found
```

#### Hosmer-Lemeshow test

``` r

enhancedROC(
  data = calibration_data,
  outcome = "outcome",
  positiveClass = "Event",
  predictors = "predicted_prob",
  hosmerLemeshow = TRUE,
  hlGroups = 10,
  customCutoffs = NULL
)
#> Error:
#> ! object 'calibration_data' not found
```

#### Hosmer-Lemeshow with fewer groups

``` r

enhancedROC(
  data = calibration_data,
  outcome = "outcome",
  positiveClass = "Event",
  predictors = "predicted_prob",
  hosmerLemeshow = TRUE,
  hlGroups = 5,
  customCutoffs = NULL
)
#> Error:
#> ! object 'calibration_data' not found
```

------------------------------------------------------------------------

### 11. Multi-Class ROC

#### One-vs-Rest with macro averaging

``` r

multiclass_data <- read.csv(paste0(data_path, "enhancedroc_multiclass.csv"))
#> Error in `file()`:
#> ! cannot open the connection

enhancedROC(
  data = multiclass_data,
  outcome = "disease_severity",
  positiveClass = "Severe",
  predictors = vars(biomarker_A, biomarker_B, imaging_severity_score),
  multiClassROC = TRUE,
  multiClassStrategy = "ovr",
  multiClassAveraging = "macro",
  customCutoffs = NULL
)
#> Error:
#> ! object 'multiclass_data' not found
```

#### One-vs-One with weighted averaging

``` r

enhancedROC(
  data = multiclass_data,
  outcome = "disease_severity",
  positiveClass = "Severe",
  predictors = "biomarker_A",
  multiClassROC = TRUE,
  multiClassStrategy = "ovo",
  multiClassAveraging = "weighted",
  customCutoffs = NULL
)
#> Error:
#> ! object 'multiclass_data' not found
```

------------------------------------------------------------------------

### 12. Clinical Impact & Utility

#### Clinical impact with NNT calculation

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  clinicalImpact = TRUE,
  nntCalculation = TRUE,
  decisionImpactTable = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

#### Clinical utility curve

``` r

enhancedROC(
  data = biomarker_data,
  outcome = "disease_status",
  positiveClass = "Disease",
  predictors = "biomarker1",
  clinicalUtilityCurve = TRUE,
  customCutoffs = NULL
)
#> Error:
#> ! object 'biomarker_data' not found
```

------------------------------------------------------------------------

### 13. Edge Cases

#### Small sample (n=60)

``` r

small_data <- read.csv(paste0(data_path, "enhancedroc_small.csv"))
#> Error in `file()`:
#> ! cannot open the connection

enhancedROC(
  data = small_data,
  outcome = "disease",
  positiveClass = "Positive",
  predictors = "marker",
  useBootstrap = TRUE,
  bootstrapSamples = 200,
  customCutoffs = NULL
)
#> Error:
#> ! object 'small_data' not found
```

#### Low prevalence screening data

``` r

enhancedROC(
  data = screening_data,
  outcome = "screening_indication",
  positiveClass = "Screen Positive",
  predictors = "sensitive_marker",
  customCutoffs = NULL
)
#> Error:
#> ! object 'screening_data' not found
```

#### Tied scores

``` r

enhancedROC(
  data = tied_data,
  outcome = "disease",
  positiveClass = "Disease",
  predictors = "ordinal_score",
  customCutoffs = NULL
)
#> Error:
#> ! object 'tied_data' not found
```

------------------------------------------------------------------------

### References

- DeLong ER, DeLong DM, Clarke-Pearson DL (1988). Comparing the areas
  under two or more correlated receiver operating characteristic curves:
  a nonparametric approach. *Biometrics*, 44(3), 837-845.
- Youden WJ (1950). Index for rating diagnostic tests. *Cancer*, 3(1),
  32-35.
- Hanley JA, McNeil BJ (1982). The meaning and use of the area under a
  receiver operating characteristic (ROC) curve. *Radiology*, 143(1),
  29-36.
- Robin X, Turck N, Hainard A, et al. (2011). pROC: an open-source
  package for R and S+ to analyze and compare ROC curves. *BMC
  Bioinformatics*, 12, 77.
- Hosmer DW, Lemeshow S (2000). *Applied Logistic Regression*. 2nd
  ed. Wiley.
- Brier GW (1950). Verification of forecasts expressed in terms of
  probability. *Monthly Weather Review*, 78(1), 1-3.
