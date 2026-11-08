# Convert raw test values to fitted logistic probabilities

Fits a logistic regression of the binary outcome on the marker. The
predictor is centered and scaled internally to keep fitted probabilities
stable when measurement units change.

## Usage

``` r
raw_to_prob(values, actual, direction = ">=", warn = TRUE)
```

## Arguments

- values:

  Raw test values

- actual:

  Binary outcomes (0/1)

- direction:

  Direction of test ("\>=" or "\<=")

- warn:

  Logical; emit a consolidated warning when logistic calibration shows
  separation, non-convergence, or fitting failure. Bootstrap callers set
  this to `FALSE` and report one aggregate diagnostic instead.

## Value

Vector of predicted probabilities
