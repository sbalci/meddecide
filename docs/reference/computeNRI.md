# Compute Net Reclassification Index (NRI)

Compute Net Reclassification Index (NRI)

## Usage

``` r
computeNRI(
  new_values,
  ref_values,
  actual,
  direction = ">=",
  thresholds = NULL,
  warn = TRUE
)
```

## Arguments

- new_values:

  Test values for new test

- ref_values:

  Test values for reference test

- actual:

  Binary outcome vector (0/1)

- direction:

  Classification direction

- thresholds:

  Risk category thresholds (NULL for continuous NRI)

- warn:

  Emit a warning when the logistic calibration shows separation or fails
  to converge. Set to `FALSE` inside bootstrap replicates.

## Value

List containing NRI components
