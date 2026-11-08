# Lowest Expected Kappa for a Fixed Sample Size

For an interobserver agreement study whose number of subjects is already
fixed, the lowest kappa the study would still be unable to rule out -
the lower bound of the one-sided confidence interval around the
anticipated kappa (kappa0); every value below it is excluded. Solved
from the goodness-of-fit models of the kappaSize package; with three or
more raters or categories it also allows for re-estimating the category
proportions when the study is analyzed. Use kappaSizePower to size a
study for a hypothesis test and kappaSizeCI to size it for target
confidence limits.

## Usage

``` r
kappaSizeFixedN(
  outcome = "2",
  kappa0 = 0.6,
  props = "0.20, 0.80",
  raters = "2",
  alpha = 0.05,
  n = 100,
  showExplanations = FALSE,
  showSummary = FALSE
)
```

## Arguments

- outcome:

  Number of outcome levels (categories) of the rated variable.

- kappa0:

  The preliminary (anticipated) value of kappa - the agreement you
  expect to observe. kappaSize documents this argument as "the
  preliminary value of kappa". Contrast kappaSizePower, where kappa0 IS
  the null being tested.

- props:

  Anticipated share of subjects in each outcome category as a single
  string, separated by commas, semicolons or spaces, using a decimal
  point, and summing to 1 (for example "0.20, 0.80" for a finding
  present in one case in five). For a binary outcome a single prevalence
  is enough. Enter exactly one value per outcome level otherwise.

- raters:

  Number of raters who will each rate every subject (2 to 6).

- alpha:

  Significance level of the one-sided lower confidence bound (capped at
  0.20).

- n:

  Number of subjects available, each rated by all raters (at least 11;
  the kappaSize engine refuses 10 or fewer).

- showExplanations:

  If TRUE, adds the methodology to the caveats panel and shows the Study
  Explanation.

- showSummary:

  If TRUE, shows the kappaSize package's own summary output.

## Value

A results object containing:

|                        |     |     |     |     |                |
|------------------------|-----|-----|-----|-----|----------------|
| `results$notices`      |     |     |     |     | a html         |
| `results$text1`        |     |     |     |     | a preformatted |
| `results$text_summary` |     |     |     |     | a preformatted |
| `results$text2`        |     |     |     |     | a preformatted |
| `results$methodology`  |     |     |     |     | a html         |

## Examples

``` r
if (FALSE) { # \dontrun{
# kappaSize::FixedNBinary example: anticipated kappa 0.7, 100 subjects,
# 4 raters, trait prevalence 0.50
kappaSizeFixedN(
    outcome = "2",
    kappa0 = 0.7,
    props = "0.50",
    raters = "4",
    alpha = 0.05,
    n = 100)
} # }
```
