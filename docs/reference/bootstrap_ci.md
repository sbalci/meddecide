# Bootstrap confidence intervals for diagnostic metrics

Bootstrap confidence intervals for diagnostic metrics

## Usage

``` r
bootstrap_ci(data, metric, R = 1000)
```

## Arguments

- data:

  Data frame containing test results

- metric:

  Function to calculate desired metric

- R:

  Number of bootstrap iterations

## Value

List containing point estimate and confidence intervals
