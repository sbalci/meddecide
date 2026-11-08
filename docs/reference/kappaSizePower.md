# Power Approach for the Number of Subjects Required

Sample size for an interobserver agreement study sized to reject a null
kappa (kappa0) in favor of an alternative kappa (kappa1) at a given
two-sided significance level and power - the power approach of the
kappaSize package. Use kappaSizeCI for a target confidence-interval
width, and kappaSizeFixedN when the number of subjects is already fixed.

## Usage

``` r
kappaSizePower(
  outcome = "2",
  kappa0 = 0.4,
  kappa1 = 0.6,
  props = "0.20, 0.80",
  raters = "2",
  alpha = 0.05,
  power = 0.8
)
```

## Arguments

- outcome:

  Number of outcome levels (categories) of the rated variable.

- kappa0:

  The null hypothesis value of kappa - the level of agreement the study
  tests against, versus the alternative kappa1. kappaSize documents this
  argument as "the null hypothesis for the kappa hypothesis test". It is
  NOT the anticipated value; kappaSizeCI and kappaSizeFixedN use kappa0
  for the anticipated value, which is a different quantity.

- kappa1:

  The alternative hypothesis value of kappa - the level of agreement the
  study should be able to detect against kappa0 (kappaSize: "the
  alternate hypothesis for the kappa hypothesis test").

- props:

  Anticipated share of subjects in each outcome category as a single
  string, separated by commas, semicolons or spaces, using a decimal
  point, and summing to 1 (for example "0.20, 0.80" for a finding
  present in one case in five). For a binary outcome a single prevalence
  is enough. Enter exactly one value per outcome level otherwise.

- raters:

  Number of raters who will each rate every subject (2 to 6).

- alpha:

  Two-sided significance level (capped at 0.20; must be below the
  power).

- power:

  Probability of rejecting kappa0 when the true agreement is kappa1 (1 -
  type II error). Conventional values are 0.80 or 0.90; must exceed
  alpha.

## Value

A results object containing:

|                        |     |     |     |     |                |
|------------------------|-----|-----|-----|-----|----------------|
| `results$notices`      |     |     |     |     | a html         |
| `results$text1`        |     |     |     |     | a preformatted |
| `results$text_summary` |     |     |     |     | a preformatted |
| `results$text2`        |     |     |     |     | a preformatted |

## Examples

``` r
if (FALSE) { # \dontrun{
# kappaSize::PowerBinary example: test kappa0 = 0.4 against kappa1 = 0.6
# with a trait prevalence of 0.30, two raters, alpha 0.05 and power 0.80
kappaSizePower(
    outcome = "2",
    kappa0 = 0.4,
    kappa1 = 0.6,
    props = "0.30",
    raters = "2",
    alpha = 0.05,
    power = 0.80)
} # }
```
