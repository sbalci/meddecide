# Comprehensive ROC Analysis with Advanced Features

Performs sophisticated Receiver Operating Characteristic (ROC) curve
analysis with optimal cutpoint determination, multiple comparison
methods, and advanced statistical features including IDI/NRI
calculations, DeLong test, and comprehensive visualization options.

## Value

A psychopdaROCResults object containing:

- `resultsTable`: Detailed results for each threshold

- `simpleResultsTable`: Summary AUC results with confidence intervals

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

- Interactive ROC plots

- Confidence bands and quantile confidence intervals

**Subgroup Analysis:**

- Stratified analysis by grouping variables

- Cost-benefit optimization with custom cost ratios

- Hospital/site comparisons

## Note

This function originally developed by Lucas Friesen in the psychoPDA
module. Enhanced version with additional features added to the
ClinicoPath module.

## References

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
- [`jmvcore::Analysis$init()`](https://rdrr.io/pkg/jmvcore/man/Analysis.html#method-init)
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
