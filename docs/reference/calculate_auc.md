# Calculate AUC from sensitivity and specificity

Uses the formula shown in the package documentation example:
`0.5 * (sens * (1 - spec)) + 0.5 * (1 * (1 - (1 - spec))) + 0.5 * ((1 - sens) * spec)`.

Uses a simplified formula to approximate AUC from sensitivity and
specificity

## Usage

``` r
calculate_auc(sens, spec)

calculate_auc(sens, spec)

calculate_auc(sens, spec)
```

## Arguments

- sens:

  Sensitivity of the test

- spec:

  Specificity of the test

## Value

Area under the ROC curve

Numeric AUC value or `NA` when inputs are not valid.

Numeric AUC value or NA when inputs are not valid
