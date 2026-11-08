# Combine Medical Decision Tests

Systematic evaluation of diagnostic test combinations. Analyzes all
possible test result patterns (2-test: 4 patterns, 3-test: 8 patterns)
against a gold standard, each test alone, and parallel and serial
strategies (with three tests also for every pair of tests, and a
majority rule). Calculates sensitivity, specificity, predictive values,
likelihood ratios, accuracy, and uncertainty intervals. Descriptive
rankings are sample-dependent analytical summaries, not clinical guides
or validated recommendations.

## Usage

``` r
decisioncombine(
  data,
  gold = NULL,
  goldPositive,
  test1 = NULL,
  test1Positive,
  test2 = NULL,
  test2Positive,
  test3 = NULL,
  test3Positive,
  showIndividual = FALSE,
  showFrequency = FALSE,
  showCITables = TRUE,
  showBarPlot = FALSE,
  showHeatmap = FALSE,
  showForest = FALSE,
  showDecisionTree = FALSE,
  showRecommendation = FALSE,
  optimismCorrection = FALSE,
  nBoot = 1000,
  seed = 42,
  showPairedComparison = FALSE,
  showAbout = FALSE,
  filterStatistic = "all",
  filterPattern = "all"
)
```

## Arguments

- data:

  The data as a data frame.

- gold:

  The gold standard reference variable representing true disease status.

- goldPositive:

  The level indicating presence of disease in the gold standard. It is
  never taken from the order of the levels: NULL leaves the analysis
  pending, listing the levels found. The argument has no default; pass
  the level.

- test1:

  The first diagnostic test variable.

- test1Positive:

  The level representing a positive result for Test 1. It is never taken
  from the order of the levels: NULL leaves the analysis pending,
  listing the levels found. The argument has no default; pass the level.

- test2:

  The second diagnostic test variable for combination analysis.

- test2Positive:

  The level representing a positive result for Test 2. Pass NULL when
  Test 2 is not selected; with Test 2 selected, NULL leaves the analysis
  pending.

- test3:

  The third diagnostic test variable for 3-way combination analysis.

- test3Positive:

  The level representing a positive result for Test 3. Pass NULL when
  Test 3 is not selected; with Test 3 selected, NULL leaves the analysis
  pending.

- showIndividual:

  Boolean to show individual test performance tables.

- showFrequency:

  Boolean to show frequency tables.

- showCITables:

  Boolean to show the confidence-interval tables for the proportions and
  for the likelihood ratios and diagnostic odds ratio.

- showBarPlot:

  Boolean to display bar chart visualization.

- showHeatmap:

  Boolean to display heatmap visualization.

- showForest:

  Boolean to display forest plot.

- showDecisionTree:

  Boolean to display the decision-space (sensitivity vs specificity)
  scatter plot.

- showRecommendation:

  Boolean to show the descriptive candidate-rule ranking table.

- optimismCorrection:

  Boolean to add the bootstrap optimism-corrected Youden's J to the
  ranking table.

- nBoot:

  Number of bootstrap resamples for the optimism correction of the
  ranking.

- seed:

  Random seed for the bootstrap resamples of the optimism correction.
  Change it to obtain a different set of resamples.

- showPairedComparison:

  Boolean to show the paired comparison of each combination rule with
  each of its component tests.

- showAbout:

  Boolean to show the about-this-analysis and assumptions panels.

- filterStatistic:

  Character indicating which statistic to display in the plots; `all`
  uses each plot's default metric set.

- filterPattern:

  Character indicating which pattern type to display in the bar chart,
  heatmap and forest plot (default: all).

## Value

A results object containing:

|  |  |  |  |  |  |
|----|----|----|----|----|----|
| `results$welcome` |  |  |  |  | a html |
| `results$notices` |  |  |  |  | a html |
| `results$combinationTable` |  |  |  |  | Counts and diagnostic performance metrics for each test combination pattern, each test alone and each combination strategy, including prevalence, balanced accuracy, Youden's J with its Agresti-Caffo 95 percent confidence interval, likelihood ratios, and diagnostic odds ratios |
| `results$combinationTableCI` |  |  |  |  | Wilson score 95 percent confidence intervals for sensitivity, specificity, PPV, NPV and accuracy, shown as percentages to match the combination table above. Likelihood ratios and the diagnostic odds ratio are unbounded ratios rather than proportions, so they appear in their own table below. |
| `results$combinationTableCIRatios` |  |  |  |  | Log-scale 95 percent confidence intervals for LR+, LR- and the diagnostic odds ratio. These are ratios on an unbounded scale, so they are reported separately from the proportions above rather than sharing a column with them. |
| `results$pairedComparisonTable` |  |  |  |  | Each combination rule against each test it combines, on the same patients: the cases gained and lost, and the change in sensitivity (disease-present cases) and specificity (disease-absent cases) with a 95 percent confidence interval |
| `results$goldFreqTable` |  |  |  |  | Counts and percentages of disease-present and disease-absent cases (the reference standard dichotomised at the chosen positive level) among the complete cases used for the combination table |
| `results$crossTabTable` |  |  |  |  | Cross-tabulation showing how test combination patterns align with gold standard results |
| `results$individualTest1$test1Contingency` |  |  |  |  | a table |
| `results$individualTest1$test1Stats` |  |  |  |  | a table |
| `results$individualTest2$test2Contingency` |  |  |  |  | a table |
| `results$individualTest2$test2Stats` |  |  |  |  | a table |
| `results$individualTest3$test3Contingency` |  |  |  |  | a table |
| `results$individualTest3$test3Stats` |  |  |  |  | a table |
| `results$barPlot` |  |  |  |  | Grouped bar chart comparing sensitivity, specificity, PPV, NPV, and accuracy across test combinations |
| `results$heatmapPlot` |  |  |  |  | Color-coded heatmap of prevalence, sensitivity, specificity, PPV, NPV, accuracy and balanced accuracy for each pattern by default, or of one selected metric |
| `results$forestPlot` |  |  |  |  | Forest plot of 95 percent confidence intervals: proportions on a 0 to 100 percent axis, and LR+, LR- and the diagnostic odds ratio on a log axis with a dashed reference line at 1 |
| `results$decisionTreePlot` |  |  |  |  | Decision-space scatter plot positioning each test pattern by its sensitivity and specificity, with point size scaled by Youden's J |
| `results$recommendationTable` |  |  |  |  | Sample-dependent descriptive ranking of eligible exact-pattern rules, single tests and named testing strategies by observed Youden index; this is not a clinical guide or validated recommendation |
| `results$addedPattern` |  |  |  |  | an output |
| `results$about` |  |  |  |  | a html |
| `results$assumptions` |  |  |  |  | a html |

Tables can be converted to data frames with `asDF` or
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html). For
example:

`results$combinationTable$asDF`

`as.data.frame(results$combinationTable)`

## Examples

``` r
if (FALSE) { # \dontrun{
# Illustrative example only; this is not a clinical guide.
data(histopathology)
result <- decisioncombine(
    data = histopathology,
    gold = "Golden Standart",
    goldPositive = "1",
    test1 = "New Test",
    test1Positive = "1",
    test2 = "Rater 1",
    test2Positive = "1",
    test3 = NULL,
    test3Positive = NULL,
    showIndividual = TRUE,
    showRecommendation = TRUE
)
} # }
```
