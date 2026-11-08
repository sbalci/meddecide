# Advanced ROC Analysis (psychopdaROC) - Comprehensive Guide

## Advanced ROC Analysis (psychopdaROC)

### Overview

The **psychopdaROC** module provides advanced Receiver Operating
Characteristic (ROC) curve analysis with optimal cutpoint determination
using the `cutpointr` framework. It supports 12 cutpoint optimization
methods, 16 optimization metrics, subgroup analysis, DeLong’s test for
comparing ROC curves, IDI/NRI reclassification indices, effect size and
power analysis, bootstrap ROC with prior weighting, clinical utility
analysis, and fixed sensitivity/specificity analysis.

All examples below use the test datasets in the `data-raw/non-rda/`
folder of the [ClinicoPath
repository](https://github.com/sbalci/ClinicoPathJamoviModule) (`.omv`
for jamovi, `.csv` for R). On this website the code is shown without
output.

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

\
`test_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_test.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### With confusion matrix and threshold table

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  sensSpecTable ``=`` ``TRUE``,`\
`  showThresholdTable ``=`` ``TRUE``,`\
`  maxThresholds ``=`` ``20``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Lower values indicate positive class

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  direction ``=`` ``"<="``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 2. Cutpoint Optimization Methods

#### Key optimization metrics

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"maximize_metric"``,`\
`  metric ``=`` ``"youden"``,`\
`  refVar ``=`` ``NULL`\
`)`

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"maximize_metric"``,`\
`  metric ``=`` ``"accuracy"``,`\
`  refVar ``=`` ``NULL`\
`)`

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"maximize_metric"``,`\
`  metric ``=`` ``"F1_score"``,`\
`  refVar ``=`` ``NULL`\
`)`

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"maximize_metric"``,`\
`  metric ``=`` ``"cohens_kappa"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Minimize misclassification cost

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"minimize_metric"``,`\
`  metric ``=`` ``"misclassification_cost"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### LOESS-smoothed Youden

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"maximize_loess_metric"``,`\
`  metric ``=`` ``"youden"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Bootstrap-optimized cutpoint

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"maximize_boot_metric"``,`\
`  boot_runs ``=`` ``100``,`\
`  seed ``=`` ``123``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Kernel-smoothed Youden

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"oc_youden_kernel"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Parametric normal Youden

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"oc_youden_normal"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Manual cutpoint

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"oc_manual"``,`\
`  specifyCutScore ``=`` ``"7.5"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Cost-benefit optimized cutpoint

\
`costbenefit_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_costbenefit.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``costbenefit_data``,`\
`  classVar ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Event"``,`\
`  negativeClass ``=`` ``"No_Event"``,`\
`  dependentVars ``=`` ``"risk_score"``,`\
`  method ``=`` ``"oc_cost_ratio"``,`\
`  costratioFP ``=`` ``0.1``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Equal sensitivity and specificity

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"oc_equal_sens_spec"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Closest to perfect classifier (0,1)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  method ``=`` ``"oc_closest_01"``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 3. Cutpoint Fine-Tuning

#### Metric tolerance

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  tol_metric ``=`` ``0.01``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Tie-breaking methods

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  break_ties ``=`` ``"mean"``,`\
`  refVar ``=`` ``NULL`\
`)`

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  break_ties ``=`` ``"median"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### All observed cutpoints

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  allObserved ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 4. Multiple Test Variables (Comparative)

#### Multi-marker ROC overlay

\
`multi_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_multibiomarker.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``multi_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``marker1``, ``marker2``, ``marker3``, ``combined_score``)``,`\
`  plotROC ``=`` ``TRUE``,`\
`  combinePlots ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

#### DeLong test for AUC comparison

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``multi_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``marker1``, ``marker2``, ``marker3``)``,`\
`  delongTest ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Cardiac biomarker comparison

\
`cardiac_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_cardiac.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``cardiac_data``,`\
`  classVar ``=`` ``"mi_status"``,`\
`  positiveClass ``=`` ``"MI"``,`\
`  negativeClass ``=`` ``"No_MI"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``troponin``, ``creatinine``, ``bnp``)``,`\
`  combinePlots ``=`` ``TRUE``,`\
`  delongTest ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 5. ROC Visualization Options

#### Optimal point and confidence bands

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  plotROC ``=`` ``TRUE``,`\
`  showOptimalPoint ``=`` ``TRUE``,`\
`  showConfidenceBands ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Smoothed ROC with standard error

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  smoothing ``=`` ``TRUE``,`\
`  displaySE ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Publication-ready clean plot

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  cleanPlot ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Legend positions

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``multi_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``marker1``, ``marker2``, ``marker3``)``,`\
`  combinePlots ``=`` ``TRUE``,`\
`  legendPosition ``=`` ``"bottom"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Direct curve labels

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``multi_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``marker1``, ``marker2``, ``marker3``)``,`\
`  combinePlots ``=`` ``TRUE``,`\
`  directLabel ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 6. Diagnostic Plots

#### Sensitivity/Specificity vs Threshold

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  showCriterionPlot ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Predictive values vs Prevalence

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  showPrevalencePlot ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Test value distribution by class

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  showDotPlot ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Precision-Recall curve

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  precisionRecallCurve ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 7. Prevalence & Prior Settings

#### Prior prevalence adjustment for rare disease

\
`rare_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_rare.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``rare_data``,`\
`  classVar ``=`` ``"rare_disease"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"No_Disease"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  usePriorPrev ``=`` ``TRUE``,`\
`  priorPrev ``=`` ``0.05``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Sample prevalence (default)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``rare_data``,`\
`  classVar ``=`` ``"rare_disease"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"No_Disease"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  usePriorPrev ``=`` ``FALSE``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 8. Subgroup Analysis

#### By age group

\
`subgroup_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_subgroup.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``subgroup_data``,`\
`  classVar ``=`` ``"disease"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"test_score"``,`\
`  subGroup ``=`` ``"age_group"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### By sex

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``subgroup_data``,`\
`  classVar ``=`` ``"disease"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"test_score"``,`\
`  subGroup ``=`` ``"sex"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Large dataset with site subgroups

\
`large_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_large.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``large_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"No_Disease"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``biomarker1``, ``biomarker2``)``,`\
`  subGroup ``=`` ``"site"``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 9. Advanced ROC Analysis

#### Partial AUC (high specificity region)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  partialAUC ``=`` ``TRUE``,`\
`  partialAUCfrom ``=`` ``0.8``,`\
`  partialAUCto ``=`` ``1.0``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Partial AUC (very high specificity)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  partialAUC ``=`` ``TRUE``,`\
`  partialAUCfrom ``=`` ``0.9``,`\
`  partialAUCto ``=`` ``1.0``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Binormal smoothing

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  rocSmoothingMethod ``=`` ``"binormal"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Bootstrap confidence intervals

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  bootstrapCI ``=`` ``TRUE``,`\
`  bootstrapReps ``=`` ``100``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Quantile-based CIs

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  quantileCIs ``=`` ``TRUE``,`\
`  quantiles ``=`` ``"0.1,0.25,0.5,0.75,0.9"``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 10. Fixed Sensitivity / Specificity Analysis

#### Fixed sensitivity for screening (95%)

\
`screening_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_screening.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``screening_data``,`\
`  classVar ``=`` ``"cancer"``,`\
`  positiveClass ``=`` ``"Cancer"``,`\
`  negativeClass ``=`` ``"No_Cancer"``,`\
`  dependentVars ``=`` ``"psa_level"``,`\
`  fixedSensSpecAnalysis ``=`` ``TRUE``,`\
`  fixedAnalysisType ``=`` ``"sensitivity"``,`\
`  fixedSensitivityValue ``=`` ``0.95``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Fixed specificity for confirmation (90%)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``screening_data``,`\
`  classVar ``=`` ``"cancer"``,`\
`  positiveClass ``=`` ``"Cancer"``,`\
`  negativeClass ``=`` ``"No_Cancer"``,`\
`  dependentVars ``=`` ``"psa_level"``,`\
`  fixedSensSpecAnalysis ``=`` ``TRUE``,`\
`  fixedAnalysisType ``=`` ``"specificity"``,`\
`  fixedSpecificityValue ``=`` ``0.90``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Interpolation methods

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``screening_data``,`\
`  classVar ``=`` ``"cancer"``,`\
`  positiveClass ``=`` ``"Cancer"``,`\
`  negativeClass ``=`` ``"No_Cancer"``,`\
`  dependentVars ``=`` ``"psa_level"``,`\
`  fixedSensSpecAnalysis ``=`` ``TRUE``,`\
`  fixedAnalysisType ``=`` ``"sensitivity"``,`\
`  fixedSensitivityValue ``=`` ``0.95``,`\
`  fixedInterpolation ``=`` ``"linear"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Fixed ROC plot with explanation

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``screening_data``,`\
`  classVar ``=`` ``"cancer"``,`\
`  positiveClass ``=`` ``"Cancer"``,`\
`  negativeClass ``=`` ``"No_Cancer"``,`\
`  dependentVars ``=`` ``"psa_level"``,`\
`  fixedSensSpecAnalysis ``=`` ``TRUE``,`\
`  fixedAnalysisType ``=`` ``"sensitivity"``,`\
`  fixedSensitivityValue ``=`` ``0.95``,`\
`  showFixedROC ``=`` ``TRUE``,`\
`  showFixedExplanation ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 11. Model Comparison (IDI / NRI)

#### Integrated Discrimination Improvement (IDI)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``multi_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``marker1``, ``marker2``, ``marker3``)``,`\
`  calculateIDI ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL``,`\
`  idiNriBootRuns ``=`` ``100`\
`)`

#### Category-based Net Reclassification Index (NRI)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``multi_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``marker1``, ``marker2``, ``marker3``)``,`\
`  calculateNRI ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL``,`\
`  nriThresholds ``=`` ``"0.3,0.7"`\
`)`

#### Continuous NRI (no thresholds)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``multi_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``marker1``, ``marker2``, ``marker3``)``,`\
`  calculateNRI ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL``,`\
`  nriThresholds ``=`` ``""`\
`)`

#### Comprehensive classifier comparison

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``multi_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``marker1``, ``marker2``, ``marker3``)``,`\
`  compareClassifiers ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 12. Effect Size & Power Analysis

#### Effect size analysis

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  effectSizeAnalysis ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Post-hoc power analysis

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  powerAnalysis ``=`` ``TRUE``,`\
`  powerAnalysisType ``=`` ``"post_hoc"``,`\
`  significanceLevel ``=`` ``0.05``,`\
`  targetPower ``=`` ``0.80``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Prospective power analysis

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  powerAnalysis ``=`` ``TRUE``,`\
`  powerAnalysisType ``=`` ``"prospective"``,`\
`  expectedAUCDifference ``=`` ``0.10``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Sample size estimation

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  powerAnalysis ``=`` ``TRUE``,`\
`  powerAnalysisType ``=`` ``"sample_size"``,`\
`  correlationROCs ``=`` ``0.5``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 13. Bootstrap ROC with Prior Weighting

#### Default prior (AUC=0.7, precision=10)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  bayesianAnalysis ``=`` ``TRUE``,`\
`  priorAUC ``=`` ``0.7``,`\
`  priorPrecision ``=`` ``10``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Strong prior belief (AUC=0.9, high precision)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  bayesianAnalysis ``=`` ``TRUE``,`\
`  priorAUC ``=`` ``0.9``,`\
`  priorPrecision ``=`` ``50``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 14. Clinical Utility Analysis

#### Decision curve analysis

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  clinicalUtilityAnalysis ``=`` ``TRUE``,`\
`  treatmentThresholdMin ``=`` ``0.05``,`\
`  treatmentThresholdMax ``=`` ``0.5``,`\
`  treatmentThresholdStep ``=`` ``0.05``,`\
`  harmBenefitRatio ``=`` ``0.25``,`\
`  refVar ``=`` ``NULL`\
`)`

#### With intervention cost analysis

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  clinicalUtilityAnalysis ``=`` ``TRUE``,`\
`  interventionCost ``=`` ``TRUE``,`\
`  harmBenefitRatio ``=`` ``1.0``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 15. Within-Cohort Meta-Analysis (Retired)

Pooling multiple markers measured on the **same patients** as if they
were independent studies is statistically invalid because the AUCs are
correlated. The legacy `metaAnalysis`, `metaAnalysisMethod`,
`heterogeneityTest`, `forestPlot`, and `overrideMetaAnalysisWarning`
options are retained as hidden arguments for backward compatibility with
saved `.omv` files and R scripts, but no pooled AUC, heterogeneity test,
or pooled forest plot is emitted. Use `delongTest = TRUE` or
`compareClassifiers = TRUE` (Section 6) to compare multiple markers on
the same cohort.

------------------------------------------------------------------------

### 16. Guidance Level (`clinicalMode`)

`clinicalMode` only changes which explanatory notes appear in the
Procedure Notes panel; it does not change any statistic. To tailor the
cut-point to a clinical goal, choose the `method` and `metric` (sections
above), or report performance at a fixed sensitivity or specificity
(`fixedSensSpecAnalysis`).

#### Basic (default)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  clinicalMode ``=`` ``"basic"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Advanced mode

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  clinicalMode ``=`` ``"advanced"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Comprehensive mode

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``test_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  clinicalMode ``=`` ``"comprehensive"``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 17. Edge Cases

#### Perfect separation (AUC=1.0)

\
`perfect_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_perfect.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``perfect_data``,`\
`  classVar ``=`` ``"condition"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` ``"perfect_test"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### No discrimination (AUC~0.5)

\
`poor_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_poor.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``poor_data``,`\
`  classVar ``=`` ``"status"``,`\
`  positiveClass ``=`` ``"Case"``,`\
`  negativeClass ``=`` ``"Control"``,`\
`  dependentVars ``=`` ``"poor_marker"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Moderate overlap (AUC~0.70)

\
`overlap_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_overlap.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``overlap_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Diseased"``,`\
`  negativeClass ``=`` ``"Non_Diseased"``,`\
`  dependentVars ``=`` ``"test_value"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Small sample (n=30)

\
`small_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_small.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``small_data``,`\
`  classVar ``=`` ``"class"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` ``"marker"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Extreme imbalance (2% event rate)

\
`imbalanced_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_imbalanced.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``imbalanced_data``,`\
`  classVar ``=`` ``"rare_outcome"``,`\
`  positiveClass ``=`` ``"Event"``,`\
`  negativeClass ``=`` ``"No_Event"``,`\
`  dependentVars ``=`` ``"predictor"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Constant predictor (zero variance)

\
`constant_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_constant.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``constant_data``,`\
`  classVar ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` ``"constant_marker"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Missing data

\
`missing_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_missing.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``missing_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"Healthy"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``test_a``, ``test_b``)``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Rare disease (5% prevalence)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``rare_data``,`\
`  classVar ``=`` ``"rare_disease"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"No_Disease"``,`\
`  dependentVars ``=`` ``"biomarker"``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Large dataset (n=500)

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``large_data``,`\
`  classVar ``=`` ``"disease_status"``,`\
`  positiveClass ``=`` ``"Disease"``,`\
`  negativeClass ``=`` ``"No_Disease"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``biomarker1``, ``biomarker2``)``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 18. Time-Dependent & Spectrum Analysis

#### Compare baseline vs follow-up markers

\
`timedep_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_timedep.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``timedep_data``,`\
`  classVar ``=`` ``"outcome"``,`\
`  positiveClass ``=`` ``"Event"``,`\
`  negativeClass ``=`` ``"No_Event"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``baseline_marker``, ``followup_marker``)``,`\
`  delongTest ``=`` ``TRUE``,`\
`  combinePlots ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL`\
`)`

#### Disease spectrum data

\
`spectrum_data`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``data_path``, ``"psychopdaROC_spectrum.csv"``)``)`\
\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``spectrum_data``,`\
`  classVar ``=`` ``"binary_status"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` ``"continuous_marker"``,`\
`  refVar ``=`` ``NULL`\
`)`

------------------------------------------------------------------------

### 19. Comprehensive Publication-Ready Scenario

Full research-grade analysis combining multiple features.

\
[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``multi_data``,`\
`  classVar ``=`` ``"diagnosis"``,`\
`  positiveClass ``=`` ``"Positive"``,`\
`  negativeClass ``=`` ``"Negative"``,`\
`  dependentVars ``=`` `[`vars`](https://dplyr.tidyverse.org/reference/vars.html)`(``marker1``, ``marker2``, ``marker3``, ``combined_score``)``,`\
`  clinicalMode ``=`` ``"comprehensive"``,`\
`  method ``=`` ``"maximize_metric"``,`\
`  metric ``=`` ``"youden"``,`\
`  delongTest ``=`` ``TRUE``,`\
`  calculateIDI ``=`` ``TRUE``,`\
`  calculateNRI ``=`` ``TRUE``,`\
`  refVar ``=`` ``NULL``,`\
`  bootstrapCI ``=`` ``TRUE``,`\
`  bootstrapReps ``=`` ``100``,`\
`  clinicalUtilityAnalysis ``=`` ``TRUE``,`\
`  plotROC ``=`` ``TRUE``,`\
`  combinePlots ``=`` ``TRUE``,`\
`  cleanPlot ``=`` ``TRUE``,`\
`  sensSpecTable ``=`` ``TRUE`\
`)`

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
