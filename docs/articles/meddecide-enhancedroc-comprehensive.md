# Clinical ROC Analysis (enhancedROC) - Comprehensive Guide

## Clinical ROC Analysis (enhancedROC)

### Overview

The **enhancedROC** module provides comprehensive Receiver Operating
Characteristic (ROC) curve analysis for clinical diagnostic performance
evaluation. It includes ROC curve analysis, Youden Index optimization,
sensitivity/specificity analysis, optimal cutoff determination,
comparative ROC analysis, calibration assessment, multi-class ROC,
clinical impact metrics, and class imbalance detection.

All examples below use the test datasets in the `data-raw/non-rda/`
folder of the [ClinicoPath
repository](https://github.com/sbalci/ClinicoPathJamoviModule) (`.omv`
for jamovi, `.csv` for R). On this website the code is shown without
output.

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
| `enhancedroc_tiedscores` | 200 | Disease/No Disease | 35% | Ordinal scores (many ties) | Scores with many ties |

------------------------------------------------------------------------

### 1. Single Biomarker Analysis (Default)

The default analysis computes a single ROC curve with AUC, optimal
cutoff via Youden Index, and diagnostic performance metrics.

#### Basic single ROC

\
`biomarker_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"enhancedroc_biomarker.csv"``)``)`\
\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### With cutoff table and clinical metrics

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  cutoffTable ``=`` ``TRUE``,`\
`  clinicalMetrics ``=`` ``TRUE``,`\
`  prevalence ``=`` ``0.30``,`\
`  useObservedPrevalence ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Direction control and custom cutoffs

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  direction ``=`` ``"higher"``,`\
`  customCutoffs ``=`` ``"5.0,7.5,10.0"`\
`)`

------------------------------------------------------------------------

### 2. Comparative ROC Analysis (Multiple Predictors)

Compare diagnostic performance across multiple biomarkers using DeLong’s
test.

#### Five-marker comparison with DeLong

\
`comparative_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"enhancedroc_comparative.csv"``)``)`\
\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``comparative_data``,`\
`  outcome ``=`` ``"cancer_status"``,`\
`  positiveClass ``=`` ``"Cancer"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``established_marker``, ``novel_marker1``, ``novel_marker2``,`\
`                    ``imaging_score``, ``genetic_risk_score``)``,`\
`  analysisType ``=`` ``"comparative"``,`\
`  pairwiseComparisons ``=`` ``TRUE``,`\
`  comparisonMethod ``=`` ``"delong"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Bootstrap comparison with metrics differences

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``comparative_data``,`\
`  outcome ``=`` ``"cancer_status"``,`\
`  positiveClass ``=`` ``"Cancer"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``established_marker``, ``novel_marker1``)``,`\
`  analysisType ``=`` ``"comparative"``,`\
`  comparisonMethod ``=`` ``"bootstrap"``,`\
`  bootstrapSamples ``=`` ``100``,`\
`  showMetricsDiff ``=`` ``TRUE``,`\
`  statisticalComparison ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Comprehensive analysis with clinical interpretation

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``comparative_data``,`\
`  outcome ``=`` ``"cancer_status"``,`\
`  positiveClass ``=`` ``"Cancer"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``established_marker``, ``novel_marker1``, ``novel_marker2``,`\
`                    ``imaging_score``, ``genetic_risk_score``)``,`\
`  analysisType ``=`` ``"comprehensive"``,`\
`  comprehensive_output ``=`` ``TRUE``,`\
`  clinical_interpretation ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 3. Bootstrap & Confidence Intervals

#### BCa bootstrap confidence intervals

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  useBootstrap ``=`` ``TRUE``,`\
`  bootstrapSamples ``=`` ``100``,`\
`  bootstrapMethod ``=`` ``"bca"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Percentile bootstrap with stratification

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  useBootstrap ``=`` ``TRUE``,`\
`  bootstrapSamples ``=`` ``100``,`\
`  bootstrapMethod ``=`` ``"percentile"``,`\
`  stratifiedBootstrap ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### 90% CI with a bootstrap CI for the partial AUC

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  confidenceLevel ``=`` ``90``,`\
`  useBootstrap ``=`` ``TRUE``,`\
`  bootstrapSamples ``=`` ``100``,`\
`  bootstrapPartialAUC ``=`` ``TRUE``,`\
`  partialAuc ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 4. ROC Curve Plot Options

#### Clinical theme with cutoff points and confidence bands

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  rocCurve ``=`` ``TRUE``,`\
`  showCutoffPoints ``=`` ``TRUE``,`\
`  showConfidenceBands ``=`` ``TRUE``,`\
`  plotTheme ``=`` ``"clinical"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Classic theme with custom dimensions

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  rocCurve ``=`` ``TRUE``,`\
`  plotTheme ``=`` ``"classic"``,`\
`  plotWidth ``=`` ``800``,`\
`  plotHeight ``=`` ``800``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Comparative ROC overlay plot

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``comparative_data``,`\
`  outcome ``=`` ``"cancer_status"``,`\
`  positiveClass ``=`` ``"Cancer"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``established_marker``, ``novel_marker1``)``,`\
`  analysisType ``=`` ``"comparative"``,`\
`  rocCurve ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 5. Youden Index & Cutoff Analysis

#### Youden Index plot

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  youdenOptimization ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Cutoff analysis plot

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  cutoffTable ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Clinical decision plot

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  clinicalMetrics ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 6. Advanced ROC Methods

#### Binormal smoothing

\
`validation_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path2``, ``"enhancedroc_validation.csv"``)``)`\
\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``validation_data``,`\
`  outcome ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker"``,`\
`  smoothMethod ``=`` ``"binormal"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Partial AUC (high specificity region)

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``validation_data``,`\
`  outcome ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker"``,`\
`  partialAuc ``=`` ``TRUE``,`\
`  partialAucType ``=`` ``"specificity"``,`\
`  partialAucFrom ``=`` ``0.8``,`\
`  partialAucTo ``=`` ``1.0``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Partial AUC (high sensitivity region)

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``validation_data``,`\
`  outcome ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker"``,`\
`  partialAuc ``=`` ``TRUE``,`\
`  partialAucType ``=`` ``"sensitivity"``,`\
`  partialAucFrom ``=`` ``0.9``,`\
`  partialAucTo ``=`` ``1.0``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### CROC analysis (Concentrated ROC)

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``validation_data``,`\
`  outcome ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker"``,`\
`  crocAnalysis ``=`` ``TRUE``,`\
`  crocAlpha ``=`` ``7.0``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Convex hull analysis

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``validation_data``,`\
`  outcome ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker"``,`\
`  convexHull ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Scores with many ties

Ordinal scores and rounded lab values produce many ties. A tied pair of
patients (one positive, one negative) always counts one half in the AUC,
and a note under the AUC table reports how many ties there are and the
bounds the AUC could take if they were broken either way. No option is
needed.

\
`tied_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path2``, ``"enhancedroc_tiedscores.csv"``)``)`\
\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``tied_data``,`\
`  outcome ``=`` ``"disease"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``ordinal_score``, ``rounded_lab``, ``composite_score``)``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 7. Sensitivity & Specificity Thresholds

#### Screening context: high sensitivity threshold

\
`screening_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"enhancedroc_screening.csv"``)``)`\
\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``screening_data``,`\
`  outcome ``=`` ``"screening_indication"``,`\
`  positiveClass ``=`` ``"Screen Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"sensitive_marker"``,`\
`  sensitivityThreshold ``=`` ``0.95``,`\
`  specificityThreshold ``=`` ``0.5``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Confirmatory context: high specificity threshold

\
`confirmatory_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"enhancedroc_confirmatory.csv"``)``)`\
\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``confirmatory_data``,`\
`  outcome ``=`` ``"confirmed_diagnosis"``,`\
`  positiveClass ``=`` ``"Confirmed"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"specific_marker"``,`\
`  sensitivityThreshold ``=`` ``0.5``,`\
`  specificityThreshold ``=`` ``0.95``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 8. Class Imbalance Detection

#### Imbalance detection with PRC recommendation

\
`imbalanced_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"enhancedroc_imbalanced.csv"``)``)`\
\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``imbalanced_data``,`\
`  outcome ``=`` ``"rare_disease"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``screening_marker``, ``confirmatory_marker``)``,`\
`  detectImbalance ``=`` ``TRUE``,`\
`  imbalanceThreshold ``=`` ``3.0``,`\
`  showImbalanceWarning ``=`` ``TRUE``,`\
`  recommendPRC ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Lower imbalance threshold (more sensitive detection)

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``imbalanced_data``,`\
`  outcome ``=`` ``"rare_disease"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"screening_marker"``,`\
`  detectImbalance ``=`` ``TRUE``,`\
`  imbalanceThreshold ``=`` ``1.5``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 9. Clinical Context & Presets

#### Biomarker screening preset

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``screening_data``,`\
`  outcome ``=`` ``"screening_indication"``,`\
`  positiveClass ``=`` ``"Screen Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"sensitive_marker"``,`\
`  clinicalContext ``=`` ``"screening"``,`\
`  clinicalPresets ``=`` ``"biomarker_screening"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Confirmatory testing preset

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``confirmatory_data``,`\
`  outcome ``=`` ``"confirmed_diagnosis"``,`\
`  positiveClass ``=`` ``"Confirmed"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"specific_marker"``,`\
`  clinicalContext ``=`` ``"diagnosis"``,`\
`  clinicalPresets ``=`` ``"confirmatory_testing"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Diagnostic validation preset (balanced)

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  clinicalContext ``=`` ``"prognosis"``,`\
`  clinicalPresets ``=`` ``"diagnostic_validation"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Research comprehensive preset

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``biomarker1``, ``biomarker2``, ``clinical_risk_score``)``,`\
`  clinicalPresets ``=`` ``"research_comprehensive"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Monitoring context with custom settings

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  clinicalContext ``=`` ``"monitoring"``,`\
`  clinicalPresets ``=`` ``"custom"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 10. Calibration Analysis

#### Full calibration assessment

\
`calibration_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"enhancedroc_calibration.csv"``)``)`\
\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``calibration_data``,`\
`  outcome ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Event"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``predicted_prob``, ``risk_score``)``,`\
`  calibrationAnalysis ``=`` ``TRUE``,`\
`  calibrationPlot ``=`` ``TRUE``,`\
`  brierScore ``=`` ``TRUE``,`\
`  calibrationMetrics ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Hosmer-Lemeshow test

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``calibration_data``,`\
`  outcome ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Event"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"predicted_prob"``,`\
`  hosmerLemeshow ``=`` ``TRUE``,`\
`  hlGroups ``=`` ``10``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Hosmer-Lemeshow with fewer groups

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``calibration_data``,`\
`  outcome ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Event"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"predicted_prob"``,`\
`  hosmerLemeshow ``=`` ``TRUE``,`\
`  hlGroups ``=`` ``5``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 11. Multi-Class ROC

#### One-vs-Rest with macro averaging

\
`multiclass_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"enhancedroc_multiclass.csv"``)``)`\
\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``multiclass_data``,`\
`  outcome ``=`` ``"disease_severity"``,`\
`  positiveClass ``=`` ``"Severe"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``biomarker_A``, ``biomarker_B``, ``imaging_severity_score``)``,`\
`  multiClassROC ``=`` ``TRUE``,`\
`  multiClassStrategy ``=`` ``"ovr"``,`\
`  multiClassAveraging ``=`` ``"macro"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### One-vs-One with weighted averaging

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``multiclass_data``,`\
`  outcome ``=`` ``"disease_severity"``,`\
`  positiveClass ``=`` ``"Severe"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker_A"``,`\
`  multiClassROC ``=`` ``TRUE``,`\
`  multiClassStrategy ``=`` ``"ovo"``,`\
`  multiClassAveraging ``=`` ``"weighted"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 12. Clinical Impact & Utility

#### Clinical impact with NNT calculation

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  clinicalImpact ``=`` ``TRUE``,`\
`  nntCalculation ``=`` ``TRUE``,`\
`  decisionImpactTable ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Clinical utility curve

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``biomarker_data``,`\
`  outcome ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"biomarker1"``,`\
`  clinicalUtilityCurve ``=`` ``TRUE``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 13. Edge Cases

#### Small sample (n=60)

\
`small_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"enhancedroc_small.csv"``)``)`\
\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``small_data``,`\
`  outcome ``=`` ``"disease"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"marker"``,`\
`  useBootstrap ``=`` ``TRUE``,`\
`  bootstrapSamples ``=`` ``100``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Low prevalence screening data

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``screening_data``,`\
`  outcome ``=`` ``"screening_indication"``,`\
`  positiveClass ``=`` ``"Screen Positive"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"sensitive_marker"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

#### Tied scores

\
[`enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)`(`\
`  data ``=`` ``tied_data``,`\
`  outcome ``=`` ``"disease"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  validationNegative ``=`` ``NULL``,`\
`  predictors ``=`` ``"ordinal_score"``,`\
`  customCutoffs ``=`` ``NULL`\
`)`

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
