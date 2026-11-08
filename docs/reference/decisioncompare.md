# Compare Medical Decision Tests

Function for comparing multiple Medical Decision Tests. Compares
sensitivity, specificity, positive predictive value, negative predictive
value, and other metrics between different tests against the same gold
standard. Includes statistical comparison using McNemar's test and
confidence intervals for differences. Tests are paired within each case;
cases must be independent across rows. Repeated specimens or lesions
from one patient require a method that accounts for clustering. Explicit
positive and negative levels are required for the reference and every
selected test. Other observed levels require explicit exclusion or prior
recoding; they are never pooled as negative.

## Usage

``` r
decisioncompare(
  data,
  referenceType = "legacy",
  referenceDescription = "",
  targetDefinition = "",
  gold = NULL,
  goldPositive,
  goldNegative,
  test1 = NULL,
  test1Positive,
  test1Negative,
  test2 = NULL,
  test2Positive,
  test2Negative,
  test3 = NULL,
  test3Positive,
  test3Negative,
  pp = FALSE,
  pprob = 0.3,
  od = FALSE,
  fnote = FALSE,
  ci = FALSE,
  plot = FALSE,
  excludeIndeterminate = FALSE,
  radarplot = FALSE,
  heatmap = FALSE,
  opa = FALSE,
  niMargin = 75,
  useOpaCriterion = FALSE,
  ciMethod = "wilson",
  stratify = NULL,
  statComp = FALSE,
  mcnemarMethod = "midp",
  showSummary = FALSE,
  showExplanations = FALSE,
  showReportSentence = FALSE,
  showDescriptiveReport = FALSE,
  showValidationContext = FALSE,
  cohortRole = "",
  samplingDesign = "",
  thresholdSource = "",
  modelVersion = "",
  analysisUnit = ""
)
```

## Arguments

- data:

  The data as a data frame.

- referenceType:

  Comparator interpretation; legacy retains diagnostic terminology. All
  modes require explicit positive and negative levels. Consensus and
  method report agreement without disease-risk interpretation.

- referenceDescription:

  Free text describing the reference or comparator (e.g. consensus of
  three pathologists); displayed in the Reference and target table and,
  when shown, the Validation context table; not validated.

- targetDefinition:

  Free text defining the target condition the positive level represents;
  displayed in the Reference and target table only, not validated.

- gold:

  The reference variable; its interpretation is selected separately.

- goldPositive:

  The positive reference level; disease interpretation requires a
  disease standard.

- goldNegative:

  Explicit negative level, required for each selected variable. Pass
  NULL only when this variable is not selected.

- test1:

  The first diagnostic test variable being evaluated for performance.

- test1Positive:

  The level representing a positive result for Test 1.

- test1Negative:

  Explicit negative level, required for each selected variable. Pass
  NULL only when this variable is not selected.

- test2:

  The second diagnostic test variable for comparison analysis.

- test2Positive:

  The level representing a positive result for Test 2.

- test2Negative:

  Explicit negative level, required for each selected variable. Pass
  NULL only when this variable is not selected.

- test3:

  Optional third diagnostic test variable for extended comparison
  analysis.

- test3Positive:

  The level representing a positive result for Test 3.

- test3Negative:

  Explicit negative level, required for each selected variable. Pass
  NULL only when this variable is not selected.

- pp:

  Enable custom prior probability (prevalence) for predictive value
  calculations.

- pprob:

  Prior probability (disease prevalence in the community). Requires a
  value strictly between 0 and 1, default 0.300.

- od:

  Boolean selection whether to show frequency tables. Default is
  'false'.

- fnote:

  Boolean indicating whether table footnotes should be displayed.

- ci:

  Boolean indicating whether confidence interval tables should be
  displayed.

- plot:

  Generate comparison plot showing test performance metrics.

- excludeIndeterminate:

  If TRUE, exclude results outside the explicit positive/negative pairs.
  If FALSE, additional observed levels cause a validation error. Both
  levels are always required; neither missing mappings nor extra labels
  invoke one-versus-rest recoding.

- radarplot:

  Generate radar plot for comprehensive test comparison visualization.

- heatmap:

  Generate concordance heatmap comparing per-case test results against
  gold standard.

- opa:

  Show overall percent agreement with 95 percent confidence intervals
  for each test.

- niMargin:

  Minimum acceptable OPA percentage (default 75). Retains the niMargin
  option name for compatibility with saved analyses.

- useOpaCriterion:

  Whether to apply the descriptive minimum OPA criterion.

- ciMethod:

  CI method for overall percent agreement: wilson (default), logit, or
  exact (Clopper-Pearson). Logit falls back to Clopper-Pearson at 0 or
  100 percent agreement.

- stratify:

  Optional stratification variable for subgroup-specific diagnostic
  accuracy analysis.

- statComp:

  Perform statistical comparison between tests (McNemar's test and
  confidence intervals for differences).

- mcnemarMethod:

  McNemar test for the pairwise comparisons: midp (default; Fagerland et
  al. 2013) or asymptotic (chi-squared without continuity correction).

- showSummary:

  Boolean to show natural language summary of statistical comparisons.

- showExplanations:

  Boolean to show explanations, glossary, and educational content.

- showReportSentence:

  Boolean to show manuscript-ready report sentence.

- showDescriptiveReport:

  Boolean to show the longer descriptive report templates.

- showValidationContext:

  Display the user-declared validation context (cohort role, sampling
  design, threshold source, model version, unit of observation) with the
  reference interpretation and comparator description in the Validation
  context table.

- cohortRole:

  Declared role of this cohort (e.g. development, internal or external
  validation); displayed only, not verified.

- samplingDesign:

  Declared sampling design (e.g. consecutive, case-control); displayed
  only, not verified. Case-control sampling distorts predictive values.

- thresholdSource:

  Declared origin of any cut-off used to make the tests binary (e.g.
  prespecified, chosen in this sample); displayed only, not verified.

- modelVersion:

  Declared version of the test, assay or algorithm; displayed only, not
  verified.

- analysisUnit:

  Declared unit each row represents (e.g. case, patient, lesion);
  displayed only, not verified. This analysis assumes independent rows.

## Value

A results object containing:

|                                 |     |     |     |     |          |
|---------------------------------|-----|-----|-----|-----|----------|
| `results$notices`               |     |     |     |     | a html   |
| `results$levelMapping`          |     |     |     |     | a table  |
| `results$goldFrequency`         |     |     |     |     | a table  |
| `results$originalCrossTab`      |     |     |     |     | a table  |
| `results$cTable1`               |     |     |     |     | a table  |
| `results$epirTable1`            |     |     |     |     | a table  |
| `results$cTable2`               |     |     |     |     | a table  |
| `results$epirTable2`            |     |     |     |     | a table  |
| `results$cTable3`               |     |     |     |     | a table  |
| `results$epirTable3`            |     |     |     |     | a table  |
| `results$comparisonTable`       |     |     |     |     | a table  |
| `results$opaTable`              |     |     |     |     | a table  |
| `results$stratifiedTable`       |     |     |     |     | a table  |
| `results$mcnemarTable`          |     |     |     |     | a table  |
| `results$diffTable`             |     |     |     |     | a table  |
| `results$plot1`                 |     |     |     |     | an image |
| `results$plotRadar`             |     |     |     |     | an image |
| `results$plotHeatmap`           |     |     |     |     | an image |
| `results$summaryReport`         |     |     |     |     | a html   |
| `results$reportSentence`        |     |     |     |     | a html   |
| `results$explanationsContent`   |     |     |     |     | a html   |
| `results$clinicalReport`        |     |     |     |     | a html   |
| `results$aboutAnalysis`         |     |     |     |     | a html   |
| `results$referenceDefinition`   |     |     |     |     | a table  |
| `results$comparatorCounts`      |     |     |     |     | a table  |
| `results$comparatorPopulation`  |     |     |     |     | a table  |
| `results$comparatorMetrics`     |     |     |     |     | a table  |
| `results$comparatorReport`      |     |     |     |     | a html   |
| `results$comparatorDifferences` |     |     |     |     | a table  |
| `results$comparatorStrata`      |     |     |     |     | a table  |
| `results$comparatorPlot`        |     |     |     |     | an image |
| `results$comparatorRadar`       |     |     |     |     | an image |
| `results$comparatorHeatmap`     |     |     |     |     | an image |
| `results$validationContext`     |     |     |     |     | a table  |

Tables can be converted to data frames with `asDF` or
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html). For
example:

`results$levelMapping$asDF`

`as.data.frame(results$levelMapping)`

## Examples

``` r
if (FALSE) { # \dontrun{
# Level arguments are explicit in the generated R API. Pass NULL for
# the unused optional third test selectors only.
decisioncompare(
    data = histopathology,
    gold = "Golden Standart",
    goldPositive = "1",
    goldNegative = "0",
    test1 = "New Test",
    test1Positive = "1",
    test1Negative = "0",
    test2 = "Rater 1",
    test2Positive = "1",
    test2Negative = "0",
    test3 = NULL,
    test3Positive = NULL,
    test3Negative = NULL,
    statComp = TRUE
)
} # }
```
