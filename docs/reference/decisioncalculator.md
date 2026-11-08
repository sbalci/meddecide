# Medical Decision Calculator

Medical Decision Calculator for diagnostic test evaluation when you have
the four key counts: True Positives (TP), False Positives (FP), True
Negatives (TN), and False Negatives (FN). Calculates comprehensive
diagnostic performance metrics including sensitivity, specificity,
positive and negative predictive values, likelihood ratios, and
post-test probabilities. Supports confidence interval estimation and
Fagan nomogram visualization for educational interpretation. Presets and
examples are illustrative only and are not clinical guides.

## Usage

``` r
decisioncalculator(
  TP = 90,
  TN = 80,
  FP = 30,
  FN = 20,
  pp = FALSE,
  pprob = 0.3,
  fnote = FALSE,
  ci = FALSE,
  fagan = FALSE,
  faganColors = "jamovi",
  showWelcome = FALSE,
  showSummary = FALSE,
  showAbout = FALSE,
  showGlossary = FALSE,
  multiplecuts = FALSE,
  cutoff1 = "Higher sensitivity example",
  tp1 = 100,
  fp1 = 40,
  tn1 = 70,
  fn1 = 10,
  cutoff2 = "Higher specificity example",
  tp2 = 80,
  fp2 = 15,
  tn2 = 95,
  fn2 = 30,
  showWorkload = FALSE,
  workloadPopulationSize = 1000,
  prevalenceScenarios = "0.0001,0.001,0.01",
  analysisUnit = "patient"
)
```

## Arguments

- TP:

  True-positive frequency relative to the stated reference standard.

- TN:

  True-negative frequency relative to the stated reference standard.

- FP:

  False-positive frequency relative to the stated reference standard.

- FN:

  False-negative frequency relative to the stated reference standard.

- pp:

  Boolean selection whether to use known population prevalence for
  prevalence-dependent predictive measures.

- pprob:

  Prior probability (disease prevalence in the community). Requires a
  value strictly between 0 and 1, default 0.300.

- fnote:

  Boolean selection whether to show detailed explanatory footnotes.

- ci:

  Boolean selection whether to calculate 95 percent confidence
  intervals.

- fagan:

  Boolean selection whether to generate a Fagan nomogram plot.

- faganColors:

  Colors of the Fagan nomogram's lines: "jamovi" follows the global
  palette, "classic" draws the positive-result line red and the
  negative-result line blue.

- showWelcome:

  Boolean selection whether to show welcome message.

- showSummary:

  Boolean selection whether to show plain-language summary of results.

- showAbout:

  Boolean selection whether to show about and assumptions panels.

- showGlossary:

  Boolean selection whether to show clinical glossary.

- multiplecuts:

  Boolean selection whether to evaluate multiple cut-off scenarios.

- cutoff1:

  Name identifier for cut-off scenario 1.

- tp1:

  True-positive frequency for illustrative scenario 1.

- fp1:

  False-positive frequency for illustrative scenario 1.

- tn1:

  True-negative frequency for illustrative scenario 1.

- fn1:

  False-negative frequency for illustrative scenario 1.

- cutoff2:

  Name identifier for cut-off scenario 2.

- tp2:

  True-positive frequency for illustrative scenario 2.

- fp2:

  False-positive frequency for illustrative scenario 2.

- tn2:

  True-negative frequency for illustrative scenario 2.

- fn2:

  False-negative frequency for illustrative scenario 2.

- showWorkload:

  Boolean selection whether to show the observed and projected workload
  table.

- workloadPopulationSize:

  Population size used for the projected workload rows.

- prevalenceScenarios:

  Comma-separated proportions between 0 and 1 (at most 100) at which
  workload is projected.

- analysisUnit:

  Label for the unit each count represents, shown in the workload table.

## Value

A results object containing:

|  |  |  |  |  |  |
|----|----|----|----|----|----|
| `results$notices` |  |  |  |  | a preformatted |
| `results$welcome` |  |  |  |  | a html |
| `results$summary` |  |  |  |  | a html |
| `results$about` |  |  |  |  | a html |
| `results$assumptions` |  |  |  |  | a html |
| `results$glossary` |  |  |  |  | a html |
| `results$cTable` |  |  |  |  | a table |
| `results$nTable` |  |  |  |  | a table |
| `results$ratioTable` |  |  |  |  | a table |
| `results$advancedMetricsTable` |  |  |  |  | a table |
| `results$epirTable_ratio` |  |  |  |  | a table |
| `results$epirTable_number` |  |  |  |  | a table |
| `results$faganSummary` |  |  |  |  | Plain-language reading of the Fagan nomogram: the pre-test probability, the likelihood ratios, and where a positive or a negative result moves the probability of disease. |
| `results$plot1` |  |  |  |  | an image |
| `results$multipleCutoffTable` |  |  |  |  | a table |
| `results$screeningWorkload` |  |  |  |  | a table |

Tables can be converted to data frames with `asDF` or
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html). For
example:

`results$cTable$asDF`

`as.data.frame(results$cTable)`

## Examples

``` r
if (FALSE) { # \dontrun{
# Illustrative examples only; these are not clinical guides.
result1 <- decisioncalculator(
  TP = 90, FN = 20, TN = 80, FP = 30
)

result2 <- decisioncalculator(
  TP = 90, FN = 20, TN = 80, FP = 30,
  ci = TRUE, pp = TRUE, pprob = 0.15, fagan = TRUE
)
} # }
```
