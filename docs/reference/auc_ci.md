# Statistical Utility Functions

Functions for calculating confidence intervals and test statistics
Calculate AUC confidence intervals

## Usage

``` r
auc_ci(auc, n_pos, n_neg, conf_level = 0.95)
```

## Arguments

- auc:

  Area under curve value

- n_pos:

  Number of positive cases

- n_neg:

  Number of negative cases

- conf_level:

  Confidence level (default 0.95)

## Value

Vector containing lower and upper CI bounds
