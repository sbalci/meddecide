# Comprehensive ROC Analysis with Advanced Features

Performs sophisticated Receiver Operating Characteristic (ROC) curve
analysis with optimal cutpoint determination, multiple comparison
methods, and advanced statistical features including IDI/NRI
calculations, DeLong test, and comprehensive visualization options.

## Value

A psychopdaROCResults object containing:

- `resultsTable`: Detailed results for each threshold

- `sensSpecTable`: Confusion matrix at optimal cutpoint

- `plotROC`: ROC curve visualization

- `delongTest`: DeLong test results (if requested)

- `idiTable`: IDI results with confidence intervals (if requested)

- `nriTable`: NRI results with confidence intervals (if requested)

- Additional plots and tables based on options selected

## Details

This function provides an extensive ROC analysis toolkit that goes
beyond basic ROC curve generation. Key features include:

**Core ROC Analysis:**

- AUC calculation with confidence intervals

- Multiple cutpoint optimization methods (12 different approaches)

- 16 different optimization metrics (Youden, accuracy, F1, etc.)

- Bootstrap confidence intervals

- Manual cutpoint specification

**Advanced Statistical Methods:**

- DeLong test for comparing multiple AUCs

- IDI (Integrated Discrimination Index) with bootstrap CI

- NRI (Net Reclassification Index) with bootstrap CI

- Partial AUC calculations

- ROC curve smoothing (multiple methods)

- Classifier performance comparison

**Visualization Options:**

- ROC curves (individual and combined)

- Sensitivity/specificity vs threshold plots

- Predictive value vs prevalence plots

- Precision-recall curves

- Dot plots showing class distributions

- Additional static ROC visualization

- Confidence bands and quantile confidence intervals

**Subgroup Analysis:**

- Stratified analysis by grouping variables

- Cost-benefit optimization with custom cost ratios

- Hospital/site comparisons

Single-AUC inference defaults to a logit transformation of the DeLong
standard error; the legacy untransformed approximation remains
selectable. Patient summaries use one prespecified mean or median per
patient for all calculations. They estimate patient-summary accuracy,
not lesion-level accuracy. Pairwise DeLong output includes raw and
Holm-adjusted p-values. IDI/NRI remain exploratory apparent estimates
with percentile intervals and no significance test. Within-cohort
meta-analysis is unavailable, including legacy overrides.

Computationally intensive options and more than 10000 selected marker
values require the Run selected analyses button. In R, pass
`run = TRUE`. Basic analysis otherwise updates automatically unless
manual mode is enabled.

## Note

This function originally developed by Lucas Friesen in the psychoPDA
module. Enhanced version with additional features added to the
ClinicoPath module.

## References

Kottas, M., Kuss, O., & Zapf, A. (2014). A modified Wald interval for
the area under the ROC curve (AUC) in diagnostic case-control studies.
BMC Medical Research Methodology, 14, 26. doi:10.1186/1471-2288-14-26.

Pepe, M. S., Janes, H., & Li, C. I. (2014). Net risk reclassification P
values: valid or misleading? JNCI, 106(4), dju041.
doi:10.1093/jnci/dju041.

DeLong, E. R., DeLong, D. M., & Clarke-Pearson, D. L. (1988). Comparing
the areas under two or more correlated receiver operating characteristic
curves: a nonparametric approach. Biometrics, 44(3), 837-845.

Pencina, M. J., D'Agostino, R. B., D'Agostino, R. B., & Vasan, R. S.
(2008). Evaluating the added predictive ability of a new marker: from
area under the ROC curve to reclassification and beyond. Statistics in
Medicine, 27(2), 157-172.

Youden, W. J. (1950). Index for rating diagnostic tests. Cancer, 3(1),
32-35.

## See also

[`cutpointr`](https://rdrr.io/pkg/cutpointr/man/cutpointr.html) for
cutpoint optimization methods
[`roc`](https://rdrr.io/pkg/pROC/man/roc.html) for ROC curve analysis

## Super classes

[`jmvcore::Analysis`](https://rdrr.io/pkg/jmvcore/man/Analysis.html) -\>
`psychopdaROCBase` -\> `psychopdaROCClass`

## Methods

### Public methods

- [`psychopdaROCClass$init()`](#method-psychopdaROCClass-init)

- [`psychopdaROCClass$asSource()`](#method-psychopdaROCClass-asSource)

- [`psychopdaROCClass$clone()`](#method-psychopdaROCClass-clone)

Inherited methods

- [`jmvcore::Analysis$.createImage()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.createImage)
- [`jmvcore::Analysis$.createImages()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.createImages)
- [`jmvcore::Analysis$.createPlotObject()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.createPlotObject)
- [`jmvcore::Analysis$.getSessionTemp()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.getSessionTemp)
- [`jmvcore::Analysis$.load()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.load)
- [`jmvcore::Analysis$.render()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.render)
- [`jmvcore::Analysis$.save()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.save)
- [`jmvcore::Analysis$.savePart()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.savePart)
- [`jmvcore::Analysis$.setCheckpoint()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.setCheckpoint)
- [`jmvcore::Analysis$.setParent()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.setParent)
- [`jmvcore::Analysis$.setReadDatasetHeaderSource()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.setReadDatasetHeaderSource)
- [`jmvcore::Analysis$.setReadDatasetSource()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.setReadDatasetSource)
- [`jmvcore::Analysis$.setResourcesPathSource()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.setResourcesPathSource)
- [`jmvcore::Analysis$.setStatePathSource()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-.setStatePathSource)
- [`jmvcore::Analysis$addAddon()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-addAddon)
- [`jmvcore::Analysis$asProtoBuf()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-asProtoBuf)
- [`jmvcore::Analysis$check()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-check)
- [`jmvcore::Analysis$optionsChangedHandler()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-optionsChangedHandler)
- [`jmvcore::Analysis$postInit()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-postInit)
- [`jmvcore::Analysis$print()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-print)
- [`jmvcore::Analysis$readDataset()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-readDataset)
- [`jmvcore::Analysis$run()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-run)
- [`jmvcore::Analysis$serialize()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-serialize)
- [`jmvcore::Analysis$setError()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-setError)
- [`jmvcore::Analysis$setStatus()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-setStatus)
- [`jmvcore::Analysis$translate()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-translate)
- `psychopdaROCBase$initialize()`

------------------------------------------------------------------------

### `psychopdaROCClass$init()`

Initialize safely when an R caller has not selected any variables.

#### Usage

    psychopdaROCClass$init(noThrow = FALSE)

#### Arguments

- `noThrow`:

  Capture initialization errors in the analysis error state when TRUE.

------------------------------------------------------------------------

### `psychopdaROCClass$asSource()`

Generate R source code for psychopdaROC analysis

#### Usage

    psychopdaROCClass$asSource()

#### Returns

Character string with R syntax for reproducible analysis

------------------------------------------------------------------------

### `psychopdaROCClass$clone()`

The objects of this class are cloneable with this method.

#### Usage

    psychopdaROCClass$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
# Load example medical data
data(medical_roc_data)

# Basic ROC analysis
result1 <- psychopdaROC(
  data = medical_roc_data,
  dependentVars = "biomarker1",
  classVar = "disease_status",
  positiveClass = "Disease", negativeClass = "Healthy",
  refVar = NULL
)

# Compare multiple biomarkers with DeLong test
result2 <- psychopdaROC(
  run = TRUE,
  data = medical_roc_data,
  dependentVars = c("biomarker1", "biomarker2", "biomarker3"),
  classVar = "disease_status",
  positiveClass = "Disease", negativeClass = "Healthy",
  delongTest = TRUE,
  combinePlots = TRUE,
  refVar = NULL
)

# Advanced analysis with IDI/NRI
result3 <- psychopdaROC(
  run = TRUE,
  data = medical_roc_data,
  dependentVars = c("biomarker1", "biomarker2"),
  classVar = "disease_status",
  positiveClass = "Disease", negativeClass = "Healthy",
  calculateIDI = TRUE,
  calculateNRI = TRUE,
  refVar = "biomarker1",
  nriThresholds = "0.3,0.7"
)

# Cost-benefit optimization
result4 <- psychopdaROC(
  data = medical_roc_data,
  dependentVars = "biomarker1",
  classVar = "disease_status",
  positiveClass = "Disease", negativeClass = "Healthy",
  method = "oc_cost_ratio",
  costratioFP = 2.5,  # False positives cost 2.5x false negatives
  refVar = NULL
)

# Subgroup analysis by hospital
result5 <- psychopdaROC(
  data = medical_roc_data,
  dependentVars = "biomarker1",
  classVar = "disease_status",
  positiveClass = "Disease", negativeClass = "Healthy",
  subGroup = "hospital",
  refVar = NULL
)

# Comprehensive analysis with all features
result6 <- psychopdaROC(
  run = TRUE,
  data = medical_roc_data,
  dependentVars = c("biomarker1", "biomarker2"),
  classVar = "disease_status",
  positiveClass = "Disease", negativeClass = "Healthy",
  method = "maximize_metric",
  metric = "youden",
  plotROC = TRUE,
  sensSpecTable = TRUE,
  showThresholdTable = TRUE,
  delongTest = TRUE,
  calculateIDI = TRUE,
  partialAUC = TRUE,
  bootstrapCI = TRUE,
  precisionRecallCurve = TRUE,
  compareClassifiers = TRUE,
  refVar = NULL
)

# Financial risk assessment example
data(financial_roc_data)

financial_result <- psychopdaROC(
  run = TRUE,
  data = financial_roc_data,
  dependentVars = c("credit_score", "income_debt_ratio", "employment_score"),
  classVar = "default_status",
  positiveClass = "Default", negativeClass = "No_Default",
  direction = "<=", # Lower credit scores indicate higher risk
  method = "oc_cost_ratio",
  costratioFP = 0.1, # False positives (rejected good clients) cost less
  subGroup = "client_type", # DeLong comparisons require an ungrouped analysis
  refVar = NULL
)

# Educational assessment example
data(education_roc_data)

education_result <- psychopdaROC(
  run = TRUE,
  data = education_roc_data,
  dependentVars = c("exam_score", "project_score", "peer_score"),
  classVar = "pass_status",
  positiveClass = "Pass", negativeClass = "Fail",
  method = "maximize_metric",
  metric = "accuracy",
  calculateIDI = TRUE,
  refVar = "exam_score",
  subGroup = "class_section"
)

# Manufacturing quality control example
data(manufacturing_roc_data)

quality_result <- psychopdaROC(
  run = TRUE,
  data = manufacturing_roc_data,
  dependentVars = c("dimension_score", "surface_score", "strength_score"),
  classVar = "quality_status",
  positiveClass = "Defect", negativeClass = "Pass",
  method = "oc_equal_sens_spec", # Balanced sensitivity/specificity
  plotROC = TRUE,
  showCriterionPlot = TRUE,
  showDotPlot = TRUE,
  subGroup = "production_line",
  refVar = NULL
)
} # }
```
