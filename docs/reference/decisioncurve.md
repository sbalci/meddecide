# Decision Curve Analysis

Decision Curve Analysis for evaluating the clinical utility of
prediction models and diagnostic tests. Calculates net benefit across
threshold probabilities to determine if using a model provides more
benefit than default strategies. Inputs must be probabilities for a
clearly defined binary outcome and prediction horizon; calibration must
be assessed separately, and this analysis does not handle censoring.

## Usage

``` r
decisioncurve(
  data,
  outcome = NULL,
  outcomePositive,
  models = NULL,
  modelNames = "",
  thresholdRange = "clinical",
  thresholdMin = 0.05,
  thresholdMax = 0.5,
  thresholdStep = 0.01,
  showTable = TRUE,
  selectedThresholds = "0.05, 0.10, 0.15, 0.20, 0.25, 0.30",
  showPlot = TRUE,
  plotStyle = "standard",
  showReferenceLinesLabels = FALSE,
  highlightRange = FALSE,
  highlightMin = 0.1,
  highlightMax = 0.3,
  calculateClinicalImpact = FALSE,
  populationSize = 1000,
  showInterventionAvoided = FALSE,
  confidenceIntervals = FALSE,
  bootReps = 1000,
  seed = 42,
  ciLevel = 0.95,
  ciBand = "pointwise",
  showBenefitRange = FALSE,
  compareModels = FALSE,
  weightedAUC = FALSE,
  clinicalDecisionRule = FALSE,
  decisionRuleVar = NULL,
  decisionRulePositive,
  decisionRuleLabel = "Clinical Rule",
  showClinicalImpactPlot = FALSE,
  costBenefitAnalysis = FALSE,
  testCost = 100,
  treatmentCost = 1000,
  benefitCorrectTreatment = 10000,
  harmFalseTreatment = 500,
  showStandardizedNetBenefit = FALSE,
  multiModelComparison = FALSE,
  showDecisionConsequences = FALSE,
  showInterpretation = FALSE,
  resourceUtilization = FALSE,
  showRelativeUtility = FALSE
)
```

## Arguments

- data:

  The data as a data frame.

- outcome:

  Binary outcome variable (0/1 or FALSE/TRUE). This represents the
  condition or event you want to predict.

- outcomePositive:

  Which level of the outcome variable represents the positive case
  (presence of condition/event). It is never taken from the order of the
  levels: until it is chosen the analysis lists the levels found and
  computes nothing. From R the argument has no default; pass the level.

- models:

  Variables holding predicted probabilities between 0 and 1 (inclusive),
  one column per model. They must refer to the outcome and prediction
  horizon being evaluated, not logits, linear predictors or raw risk
  scores. The analysis rejects values outside 0 to 1 rather than
  rescaling them because rescaling would destroy the clinical meaning of
  the threshold. Being within 0 to 1 does not prove calibration; assess
  calibration separately in the target population. For time-to-event
  predictions, use a binary fixed-horizon outcome with appropriate
  outcome ascertainment because censoring is not handled by this
  function.

- modelNames:

  Optional comma-separated list of names for the models. If not
  provided, variable names will be used.

- thresholdRange:

  Range of threshold probabilities to evaluate. Select the range from
  the actual clinical action and the relative consequences of missed
  cases and unnecessary interventions; the presets are computational
  conveniences, not recommendations.

- thresholdMin:

  Minimum threshold probability when using custom range.

- thresholdMax:

  Maximum threshold probability when using custom range.

- thresholdStep:

  Step size between threshold probabilities.

- showTable:

  Display table with net benefit values at selected thresholds.

- selectedThresholds:

  Comma-separated list of threshold probabilities to display in table.

- showPlot:

  Display the decision curve plot.

- plotStyle:

  Style of the decision curve plot.

- showReferenceLinesLabels:

  Show labels for "Treat All" and "Treat None" reference lines.

- highlightRange:

  Highlight a clinically relevant threshold range on the plot.

- highlightMin:

  Minimum threshold for highlighted range.

- highlightMax:

  Maximum threshold for highlighted range.

- calculateClinicalImpact:

  Calculate clinical impact metrics (number needed to screen, etc.).

- populationSize:

  Population size used to project clinical impact, resource use and
  exploratory monetary payoff from the complete-case cohort proportions.

- showInterventionAvoided:

  Display the net reduction in interventions compared with treat-all,
  derived from the net-benefit difference after accounting for the
  threshold odds.

- confidenceIntervals:

  Calculate bootstrap confidence intervals for net benefit at each
  threshold, for every model and for the clinical decision rule if one
  is supplied. Pointwise percentile intervals and a simultaneous sup-t
  band are both computed; ciBand selects which the plot draws.

- bootReps:

  Number of bootstrap replications for confidence intervals.

- seed:

  Random seed for the bootstrap resampling used in the confidence
  intervals and the model-comparison p-values. Without a fixed seed the
  same data and the same options produce a different interval and a
  different p-value on every run.

- ciLevel:

  Confidence level for bootstrap confidence intervals.

- ciBand:

  Which bootstrap interval the decision curve plot draws. 'pointwise'
  gives a percentile interval at each threshold; read jointly across
  thresholds these overstate confidence. 'simultaneous' gives a
  studentized sup-t band (Montiel Olea and Plagborg-Moller 2019) from
  the same replicates that covers the entire curve with approximately
  the stated probability; coverage falls below nominal in small samples
  and where few patients are classified positive. Both are computed;
  this only selects which is drawn.

- showBenefitRange:

  Report, for each model, the range of threshold probabilities over
  which its net benefit exceeds both treat-all and treat-none. The range
  is descriptive and may contain separated stretches. Threshold
  probability should be elicited from the clinical trade-off, not
  optimized on the same data.

- compareModels:

  Provide exploratory pairwise bootstrap comparisons of average net
  benefit across the selected range, between every pair of strategies:
  the models and, if one is supplied, the clinical decision rule. The
  p-values are approximate and should not replace comparison at
  prespecified clinically relevant thresholds or independent validation.

- weightedAUC:

  Summarize each decision curve by the area under it, normalized by the
  width of the threshold range - that is, the model's average net
  benefit over that range. The option is named weightedAUC for
  historical reasons but the average is UNWEIGHTED: every threshold in
  the range counts equally. The value therefore depends entirely on the
  threshold range chosen above, so always report the range alongside it.
  Curves may cross, so this descriptive average does not identify a
  universally best model.

- clinicalDecisionRule:

  Add clinical decision rule analysis and comparison with models.

- decisionRuleVar:

  Binary variable indicating whether the clinical rule recommends
  intervention (1/0 or yes/no).

- decisionRulePositive:

  Which level of the rule variable indicates a positive recommendation
  (treat/intervene). Never taken from the order of the levels: until it
  is chosen the rule is left out of the analysis. jamovi does not permit
  a default on a Level option, so this is always a required argument of
  the R function even when clinicalDecisionRule is FALSE. Programmatic
  callers that are not using a clinical decision rule must pass
  decisionRulePositive = NULL explicitly.

- decisionRuleLabel:

  Label for the clinical decision rule in plots and tables.

- showClinicalImpactPlot:

  Display projected true positives and false positives for the selected
  population size at the selected threshold probabilities.

- costBenefitAnalysis:

  Project a simple exploratory monetary payoff using user-assigned
  values in one common currency. This is not an ICER, QALY,
  cost-effectiveness or formal net-monetary-benefit analysis.

- testCost:

  Cost per test or screening procedure in the same currency and time
  frame as all other payoff inputs.

- treatmentCost:

  Cost of treatment or intervention in the same currency and time frame
  as all other payoff inputs.

- benefitCorrectTreatment:

  Monetary value assigned to correctly treating a true positive, in the
  same currency and time frame as every other payoff input. Do not enter
  QALYs.

- harmFalseTreatment:

  Monetary value assigned to the harm of treating a false positive, in
  the same currency and time frame as every other payoff input.

- showStandardizedNetBenefit:

  Display standardized net benefit, defined as net benefit divided by
  outcome prevalence. It is dimensionless and expresses net benefit
  relative to the maximum achievable value; it is not net benefit per
  100 patients.

- multiModelComparison:

  Perform exploratory pairwise bootstrap comparisons between all models,
  and any clinical decision rule, of the unweighted mean (and median)
  net-benefit difference over the threshold grid points. Inference is
  approximate and conditional on the selected threshold range.

- showDecisionConsequences:

  Show detailed table of decision consequences (TP, FP, TN, FN) at
  selected thresholds.

- showInterpretation:

  Show a plain-language interpretation of the decision curves (the model
  with the highest average net benefit over the range, its range of
  benefit, reading guidelines and methodological notes). The Analysis
  Summary, which states the data requirements, is always shown.

- resourceUtilization:

  Project tests, treatments, unnecessary treatments and missed cases to
  the selected population size.

- showRelativeUtility:

  Display relative utility curve comparing each model to default
  strategies.

## Value

A results object containing:

|  |  |  |  |  |  |
|----|----|----|----|----|----|
| `results$instructions` |  |  |  |  | a html |
| `results$procedureNotes` |  |  |  |  | a html |
| `results$notices` |  |  |  |  | a html |
| `results$resultsTable` |  |  |  |  | a table |
| `results$benefitRangeTable` |  |  |  |  | a table |
| `results$clinicalImpactTable` |  |  |  |  | a table |
| `results$comparisonTable` |  |  |  |  | a table |
| `results$weightedAUCTable` |  |  |  |  | a table |
| `results$dcaPlot` |  |  |  |  | Net-benefit curves with optional bootstrap ribbons, pointwise or a simultaneous sup-t band, for every model and any clinical rule |
| `results$clinicalImpactPlot` |  |  |  |  | Projected true and false positives for the selected population size |
| `results$interventionsAvoidedPlot` |  |  |  |  | an image |
| `results$summaryText` |  |  |  |  | a html |
| `results$costBenefitTable` |  |  |  |  | Simple monetary payoff projection under explicit assumptions; not an ICER, QALY or formal health-economic analysis |
| `results$decisionConsequencesTable` |  |  |  |  | Detailed consequences at selected thresholds |
| `results$modelComparisonEnhanced` |  |  |  |  | Exploratory case-resampling comparison of the unweighted mean net-benefit difference over the threshold grid points |
| `results$resourceUtilizationTable` |  |  |  |  | Resource utilization projected to the selected population size |
| `results$relativeUtilityPlot` |  |  |  |  | Relative utility compared to default strategies |
| `results$standardizedNetBenefitPlot` |  |  |  |  | Dimensionless net benefit divided by outcome prevalence; not net benefit per 100 patients |

Tables can be converted to data frames with `asDF` or
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html). For
example:

`results$resultsTable$asDF`

`as.data.frame(results$resultsTable)`

## Examples

``` r
if (FALSE) { # \dontrun{
# outcomePositive and decisionRulePositive are Level options: jamovi forbids a
# default on them, so both are REQUIRED arguments. Pass NULL for the rule level
# when no clinical decision rule is used.
decisioncurve(
    data = dca_test_data,
    outcome = "cardiac_event",
    outcomePositive = "Yes",
    models = c("basic_model", "enhanced_model"),
    decisionRulePositive = NULL
)
} # }
```
