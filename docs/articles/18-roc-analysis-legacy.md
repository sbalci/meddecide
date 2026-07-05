# ROC Curve Analysis

This vignette shows how to perform Receiver Operating Characteristic
(ROC) analysis with **meddecide** using the
[`psychopdaROC()`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md)
function.

## Loading the Data

``` r

df_roc <- read.csv(system.file("extdata", "roc_example.csv", package = "meddecide"))
head(df_roc)
```

## Creating the ROC Curve

``` r

roc_res <- psychopdaROC(data = df_roc, class = df_roc$class, value = df_roc$value)
roc_res$plot
```

The resulting plot shows the ROC curve along with the area under the
curve (AUC). You can extract the AUC value and other statistics from the
result object.

``` r

roc_res$AUC
```

## Bootstrapping and Confidence Intervals

The `pROC` package provides robust methods for computing confidence
intervals for diagnostic metrics.

``` r

# Calculate AUC confidence intervals using pROC
library(pROC)
roc_obj <- roc(response = outcome, predictor = biomarker)
pROC::ci.auc(roc_obj, method = "bootstrap")

# Calculate threshold-specific confidence intervals
pROC::ci.thresholds(roc_obj)
```

These methods provide statistically sound confidence intervals for your
ROC analysis.
