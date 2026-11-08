# Medical Decision

Function for Medical Decision Analysis. Sensitivity, Specificity,
Positive Predictive Value, Negative Predictive Value.

## Usage

``` r
decision(
  data,
  referenceType = "legacy",
  referenceDescription = "",
  targetDefinition = "",
  gold = NULL,
  goldPositive,
  newtest = NULL,
  testPositive,
  goldNegative,
  testNegative,
  pp = FALSE,
  pprob = 0.3,
  od = FALSE,
  fnote = FALSE,
  ci = FALSE,
  fagan = FALSE,
  faganColors = "jamovi",
  showNaturalLanguage = FALSE,
  showClinicalInterpretation = FALSE,
  showReportTemplate = FALSE,
  showAboutAnalysis = FALSE,
  showMisclassified = FALSE,
  maxCasesShow = 50,
  showValidationContext = FALSE,
  cohortRole = "",
  samplingDesign = "",
  thresholdSource = "",
  modelVersion = "",
  analysisUnit = "slide"
)
```

## Arguments

- data:

  The data as a data frame. The data frame should contain the variables
  specified in the 'variables' option.

- referenceType:

  Comparator interpretation; legacy preserves existing binary
  calculations. Consensus and method report agreement without
  disease-risk interpretation.

- referenceDescription:

  .

- targetDefinition:

  .

- gold:

  The reference standard variable, used as each case's disease status.

- goldPositive:

  The positive reference level; disease interpretation requires a
  disease standard. It is never taken from the order of the levels: NULL
  leaves the analysis pending, listing the levels found. The argument
  has no default; pass the level.

- newtest:

  The diagnostic test variable being evaluated for performance.

- testPositive:

  The level representing a positive result for the test under
  evaluation. It is never taken from the order of the levels: NULL
  leaves the analysis pending, listing the levels found. The argument
  has no default; pass the level.

- goldNegative:

  The level indicating absence of disease in the gold standard variable.
  The compiler forbids a default on a Level option, so R callers must
  pass it explicitly; pass NULL only for a two-level variable, where it
  is inferred. With three or more levels a NULL raises an error rather
  than pooling them.

- testNegative:

  The level representing a negative result for the test under
  evaluation. The compiler forbids a default on a Level option, so R
  callers must pass it explicitly; pass NULL only for a two-level
  variable, where it is inferred. With three or more levels a NULL
  raises an error rather than pooling them.

- pp:

  Boolean selection whether to use known population prevalence instead
  of study prevalence.

- pprob:

  Population disease prevalence as a proportion strictly between 0 and
  1.

- od:

  Boolean selection whether to show original data frequency tables. The
  raw data outputs (rawContingency, rawCounts and missingDataSummary)
  are filled only when this is TRUE, so R code that reads them must set
  od = TRUE.

- fnote:

  Boolean selection whether to show detailed explanatory footnotes.

- ci:

  Boolean selection whether to calculate and display 95 percent
  confidence intervals.

- fagan:

  Boolean selection whether to generate a Fagan nomogram plot.

- faganColors:

  Colors of the Fagan nomogram's lines: "jamovi" follows the global
  palette, "classic" draws the positive-result line red and the
  negative-result line blue.

- showNaturalLanguage:

  Boolean selection whether to show the natural language clinical
  summary.

- showClinicalInterpretation:

  Boolean selection whether to show the clinical interpretation guide.

- showReportTemplate:

  Boolean selection whether to show the copy-ready results paragraph.

- showAboutAnalysis:

  Boolean selection whether to show the about analysis section.

- showMisclassified:

  Boolean selection whether to show detailed misclassified cases tables.

- maxCasesShow:

  Maximum number of misclassified cases to display in tables.

- showValidationContext:

  .

- cohortRole:

  .

- samplingDesign:

  .

- thresholdSource:

  .

- modelVersion:

  .

- analysisUnit:

  .

## Value

A results object containing:

|                                           |     |     |     |     |           |
|-------------------------------------------|-----|-----|-----|-----|-----------|
| `results$welcome`                         |     |     |     |     | a html    |
| `results$notices`                         |     |     |     |     | a html    |
| `results$rawContingency`                  |     |     |     |     | a table   |
| `results$rawCounts`                       |     |     |     |     | a table   |
| `results$cTable`                          |     |     |     |     | a table   |
| `results$nTable`                          |     |     |     |     | a table   |
| `results$ratioTable`                      |     |     |     |     | a table   |
| `results$missingDataSummary`              |     |     |     |     | a html    |
| `results$epirTable_ratio`                 |     |     |     |     | a table   |
| `results$epirTable_number`                |     |     |     |     | a table   |
| `results$plot1`                           |     |     |     |     | an image  |
| `results$naturalLanguageSummary`          |     |     |     |     | a html    |
| `results$clinicalInterpretation`          |     |     |     |     | a html    |
| `results$reportTemplate`                  |     |     |     |     | a html    |
| `results$aboutAnalysis`                   |     |     |     |     | a html    |
| `results$misclassifiedHeading`            |     |     |     |     | a html    |
| `results$confusionMatrixSummary`          |     |     |     |     | a table   |
| `results$falsePositiveTable`              |     |     |     |     | a table   |
| `results$falseNegativeTable`              |     |     |     |     | a table   |
| `results$misclassificationInterpretation` |     |     |     |     | a html    |
| `results$saveClassifications`             |     |     |     |     | an output |
| `results$referenceDefinition`             |     |     |     |     | a table   |
| `results$comparatorCounts`                |     |     |     |     | a table   |
| `results$comparatorPopulation`            |     |     |     |     | a table   |
| `results$comparatorMetrics`               |     |     |     |     | a table   |
| `results$comparatorReport`                |     |     |     |     | a html    |
| `results$comparatorCases`                 |     |     |     |     | a table   |
| `results$validationContext`               |     |     |     |     | a table   |

Tables can be converted to data frames with `asDF` or
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html). For
example:

`results$rawContingency$asDF`

`as.data.frame(results$rawContingency)`
