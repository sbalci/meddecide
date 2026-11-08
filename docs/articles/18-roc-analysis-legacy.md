# ROC Curve Analysis

This vignette shows how to perform Receiver Operating Characteristic
(ROC) analysis with **meddecide** using the
[`psychopdaROC()`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)
function.

## Loading the Data

\
`df_roc`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`system.file`](https://rdrr.io/r/base/system.file.html)`(``"extdata"``, ``"roc_example.csv"``, package ``=`` ``"meddecide"``)``)`\
[`head`](https://rdrr.io/r/utils/head.html)`(``df_roc``)`

## Creating the ROC Curve

\
`roc_res`` ``<-`` `[`psychopdaROC`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)`(`\
`  data ``=`` ``df_roc``,`\
`  dependentVars ``=`` ``"value"``,   ``# the marker column(s), by NAME`\
`  classVar ``=`` ``"class"``,        ``# the outcome column, by NAME`\
`  positiveClass ``=`` ``"1"``        ``# name the positive level; leaving it unset`\
`)``                            ``# makes the analysis assume the last level`\
`roc_res``$``plot`

The resulting plot shows the ROC curve along with the area under the
curve (AUC). You can extract the AUC value and other statistics from the
result object.

\
`roc_res``$``AUC`

## Bootstrapping and Confidence Intervals

The `pROC` package provides robust methods for computing confidence
intervals for diagnostic metrics.

\
`# Calculate AUC confidence intervals using pROC`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`pROC`](https://xrobin.github.io/pROC/)`)`\
`roc_obj`` ``<-`` `[`roc`](https://rdrr.io/pkg/pROC/man/roc.html)`(``response ``=`` ``outcome``, predictor ``=`` ``biomarker``)`\
`pROC``::`[`ci.auc`](https://rdrr.io/pkg/pROC/man/ci.auc.html)`(``roc_obj``, method ``=`` ``"bootstrap"``)`\
\
`# Calculate threshold-specific confidence intervals`\
`pROC``::`[`ci.thresholds`](https://rdrr.io/pkg/pROC/man/ci.thresholds.html)`(``roc_obj``)`

These methods provide statistically sound confidence intervals for your
ROC analysis.
