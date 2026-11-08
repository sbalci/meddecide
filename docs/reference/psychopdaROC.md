# Advanced ROC Analysis

Exploratory Receiver Operating Characteristic (ROC) curve analysis with
optimal cutpoint determination. Analyze independent rows or a
prespecified mean or median per patient. Patient summaries require an ID
and a consistent outcome within each patient; all calculations and
resampling then use one summary per patient. Nominal coverage is not
guaranteed in small or imbalanced samples. Cutpoints selected on these
data report apparent performance and require validation in the intended
setting.

## Usage

``` r
psychopdaROC(
  manualRun = FALSE,
  run = FALSE,
  showExplanations = FALSE,
  clinicalMode = "basic",
  data,
  patientID = NULL,
  analysisUnit = "rows",
  aucInference = "logit",
  dependentVars,
  classVar,
  positiveClass,
  negativeClass,
  subGroup = NULL,
  method = "maximize_metric",
  metric = "youden",
  direction = ">=",
  specifyCutScore = "",
  tol_metric = 1e-06,
  break_ties = "mean",
  allObserved = FALSE,
  boot_runs = 0,
  seed = 123,
  usePriorPrev = FALSE,
  priorPrev = 0.5,
  costratioFP = 1,
  sensSpecTable = FALSE,
  showThresholdTable = FALSE,
  maxThresholds = 20,
  delongTest = FALSE,
  plotROC = FALSE,
  combinePlots = FALSE,
  cleanPlot = FALSE,
  showOptimalPoint = FALSE,
  displaySE = FALSE,
  smoothing = FALSE,
  showConfidenceBands = FALSE,
  legendPosition = "right",
  directLabel = FALSE,
  interactiveROC = FALSE,
  showCriterionPlot = FALSE,
  showPrevalencePlot = FALSE,
  showDotPlot = FALSE,
  precisionRecallCurve = FALSE,
  partialAUC = FALSE,
  partialAUCfrom = 0.8,
  partialAUCto = 1,
  rocSmoothingMethod = "none",
  bootstrapCI = FALSE,
  bootstrapReps = 2000,
  quantileCIs = FALSE,
  quantiles = "0.1,0.25,0.5,0.75,0.9",
  compareClassifiers = FALSE,
  calculateIDI = FALSE,
  calculateNRI = FALSE,
  refVar = NULL,
  nriThresholds = "",
  idiNriBootRuns = 1000,
  effectSizeAnalysis = FALSE,
  powerAnalysis = FALSE,
  powerAnalysisType = "post_hoc",
  expectedAUCDifference = 0.1,
  targetPower = 0.8,
  significanceLevel = 0.05,
  correlationROCs = 0.5,
  bayesianAnalysis = FALSE,
  priorAUC = 0.7,
  priorPrecision = 10,
  clinicalUtilityAnalysis = FALSE,
  treatmentThresholdMin = 0.05,
  treatmentThresholdMax = 0.5,
  treatmentThresholdStep = 0.05,
  harmBenefitRatio = 0.25,
  interventionCost = FALSE,
  fixedSensSpecAnalysis = FALSE,
  fixedAnalysisType = "sensitivity",
  fixedSensitivityValue = 0.9,
  fixedSpecificityValue = 0.9,
  showFixedROC = FALSE,
  fixedInterpolation = "linear",
  showFixedExplanation = FALSE,
  metaAnalysis = FALSE,
  metaAnalysisMethod = "both",
  heterogeneityTest = FALSE,
  forestPlot = FALSE,
  overrideMetaAnalysisWarning = FALSE
)
```

## Arguments

- manualRun:

  When TRUE, results are only computed after clicking the Run button.
  Intensive options and datasets with more than 10000 selected marker
  values always require Run, even when this option is FALSE.

- run:

  Set TRUE to run intensive options, large datasets, or manual mode.

- showExplanations:

  Show optional educational interpretation and procedure details. Input
  and scope notices remain visible.

- clinicalMode:

  Selects which guidance notes are shown in the Procedure Notes panel.
  Basic explains the AUC bands and warns that a cutpoint searched on
  these data is optimistic; Advanced and Comprehensive give a shorter
  research framing. This option does not switch any analysis on or off -
  every optional analysis has its own checkbox.

- data:

  The data as a data frame, with one independent observation per row.

- patientID:

  Identifier for independent patients. Required for patient summaries.
  With independent rows, supplying an ID checks for duplicates and
  rejects repeated patients.

- analysisUnit:

  Choose a clinically prespecified summary before inspecting results.
  The mean or median of observed scores is calculated for each patient
  and marker, including a separate IDI/NRI reference. Patients with all
  scores missing for a marker are excluded for that marker. Outcomes and
  subgroups must be consistent within patients. This estimates
  patient-level accuracy of the summary, not accuracy of individual
  lesions or visits.

- aucInference:

  Logit DeLong uses the DeLong standard error with a logit delta
  transformation for the 95\\ test against AUC 0.5. The legacy option
  uses the untransformed normal approximation. Both remain asymptotic;
  unavailable or zero variance gives missing inference. Pairwise AUC
  comparisons use ordinary paired DeLong.

- dependentVars:

  Test variable(s) to be evaluated for classification performance.
  Multiple variables can be selected for comparison.

- classVar:

  Classification variable representing the true class (gold standard).
  Choose one positive and one negative level. Only observations in those
  two levels are analyzed; other levels and missing outcomes are
  excluded and counted.

- positiveClass:

  Level of classVar treated as the positive class (condition present).
  Required: NULL leaves the analysis waiting for a choice; levels are
  never inferred from their order.

- negativeClass:

  Level of classVar treated as the negative class (condition absent).
  Required: NULL leaves the analysis waiting for a choice. Other levels
  are excluded.

- subGroup:

  Optional grouping variable for stratified analysis. ROC curves will be
  calculated separately for each group.

- method:

  Method for determining the optimal cutpoint. Different methods
  optimize different aspects of classifier performance.

- metric:

  Metric to optimize when determining the cutpoint. Only applies to
  maximize/minimize methods. The legacy p_chisquared option identifier
  denotes the Pearson chi-squared statistic (without continuity
  correction), not its p-value.

- direction:

  Direction of classification relative to the cutpoint. Use '\>=' when
  higher test values indicate the positive class.

- specifyCutScore:

  Specific cutpoint value to use when method is set to 'Manual
  cutpoint'.

- tol_metric:

  Cutpoints whose metric is within this tolerance of the best value are
  treated as equivalent and averaged together. BEHAVIOR CHANGE (1.0.4) -
  the default was 0.05, which is 50000 times wider than the 1e-06 used
  by the underlying cutpointr package and meant the reported "optimal"
  cutpoint was usually not the one maximizing the metric. On the bundled
  example data 39 of 200 candidate thresholds, spanning 52.1 to 67.7,
  fell within 0.05 Youden of the optimum and were averaged, giving a
  cutpoint with 84.5 percent sensitivity in place of the 94.4 percent
  available at the true optimum. Raise it deliberately if you want that
  averaging as a guard against over-fitting one threshold.

- break_ties:

  Method for handling ties when multiple cutpoints achieve the same
  metric value.

- allObserved:

  Display performance metrics for all observed test values as potential
  cutpoints, not just the optimal cutpoint.

- boot_runs:

  Number of bootstrap iterations for methods using bootstrapping. Set to
  0 to disable bootstrapping.

- seed:

  Random seed for reproducibility of bootstrap and permutation tests.

- usePriorPrev:

  Use a specified prior prevalence instead of the sample prevalence for
  calculating predictive values.

- priorPrev:

  Population prevalence to use for predictive value calculations. Only
  used when 'Use Prior Prevalence' is checked.

- costratioFP:

  Relative cost of false positives compared to false negatives. Values
  \> 1 penalize false positives more heavily.

- sensSpecTable:

  Display detailed confusion matrices at optimal cutpoints.

- showThresholdTable:

  Display detailed table with performance metrics at multiple
  thresholds.

- maxThresholds:

  Maximum number of threshold values to show in the threshold table.

- delongTest:

  Test whether the diagnostic performance differs significantly between
  multiple tests. Uses DeLong's method to compare Area Under the Curve
  (AUC) values. Requires at least two test variables.

- plotROC:

  Display ROC curves for visual assessment of classifier performance.

- combinePlots:

  When multiple test variables are selected, combine all ROC curves in a
  single plot.

- cleanPlot:

  Create clean ROC curves without annotations, suitable for
  publications.

- showOptimalPoint:

  Display the selected cutpoint on the ROC curve. When all tied
  cutpoints are listed, mark the first selected cutpoint.

- displaySE:

  Display the pointwise 95\\ LOESS smooth. This describes uncertainty in
  the visual smooth, not the Wilson intervals for ROC sensitivity and
  specificity or a simultaneous ROC confidence region.

- smoothing:

  Apply LOESS smoothing to ROC curves for visualization.

- showConfidenceBands:

  Display confidence bands around the ROC curve.

- legendPosition:

  Position of the legend in plots with multiple ROC curves.

- directLabel:

  Label curves directly on the plot instead of using a legend.

- interactiveROC:

  Create an additional static ROC plot. The stable option name is
  retained for saved analyses; the jamovi Image output does not provide
  HTML interaction.

- showCriterionPlot:

  Plot showing how sensitivity and specificity change across different
  thresholds.

- showPrevalencePlot:

  Plot showing how PPV and NPV change with disease prevalence.

- showDotPlot:

  Dot plot showing the distribution of test values by class.

- precisionRecallCurve:

  Display precision-recall step curves with average precision. The
  classifier comparison table reports the separate interpolated AUC-PR
  estimate.

- partialAUC:

  Calculate AUC for a specific region of the ROC curve.

- partialAUCfrom:

  Lower bound of specificity range for partial AUC calculation.

- partialAUCto:

  Upper bound of specificity range for partial AUC calculation.

- rocSmoothingMethod:

  Method for smoothing the ROC curve (requires pROC package).

- bootstrapCI:

  Calculate bootstrap confidence intervals for full AUC and a separate
  Youden reference cutoff, sensitivity and specificity. This does not
  follow the main Cutpoint Method. Tied Youden optima use seeded random
  selection in both the original sample and stratified bootstrap
  replicates.

- bootstrapReps:

  Number of bootstrap replications for confidence interval calculation.

- quantileCIs:

  Display confidence intervals at specific quantiles of the test
  variable.

- quantiles:

  Comma-separated list of quantiles (0-1) at which to display confidence
  intervals.

- compareClassifiers:

  Perform comprehensive comparison of classifier performance metrics.

- calculateIDI:

  Calculate how much better one test is at discriminating between
  diseased and healthy patients. IDI (Integrated Discrimination
  Improvement) measures the average improvement in predicted
  probabilities.

- calculateNRI:

  Calculate how many patients are correctly reclassified when using a
  new test. NRI (Net Reclassification Index) measures the net
  improvement in patient classification.

- refVar:

  Reference test for IDI and NRI (a numeric variable; it need not be one
  of the test variables, and it cannot be the class variable). Every
  test variable other than the reference is compared against it. NULL
  uses the first test variable.

- nriThresholds:

  Comma-separated probability thresholds (0-1) defining risk categories
  for NRI. Leave empty for continuous NRI. In both variants, predicted
  risks differing by at most sqrt(machine epsilon), approximately
  1.5e-8, are treated as numerical ties. This tolerance removes
  numerical roundoff and is not a clinically meaningful change
  threshold.

- idiNriBootRuns:

  Number of bootstrap iterations for IDI and NRI confidence intervals.

- effectSizeAnalysis:

  Calculate within-marker standardized differences between outcome
  classes and pairwise differences in those effects. Size bands are
  descriptive conventions only.

- powerAnalysis:

  Approximate power and sample size for each marker's AUC against 0.5.
  Does not calculate power for a difference between markers.

- powerAnalysisType:

  Type of power analysis to perform.

- expectedAUCDifference:

  Target AUC above chance (target AUC = 0.5 + this value) for
  prospective power and sample size estimation, separately for each
  marker. A target AUC of exactly 1 is degenerate and has no sample size
  recommendation.

- targetPower:

  Target statistical power for sample size calculations (typically 0.8
  or 0.9).

- significanceLevel:

  Type I error rate for power calculations (typically 0.05).

- correlationROCs:

  Deprecated compatibility option, ignored. Power compares each marker's
  AUC with 0.5; there is no paired AUC comparison in this calculation.

- bayesianAnalysis:

  Perform bootstrap-based ROC analysis with optional prior weighting to
  estimate uncertainty in AUC. Uses bootstrap resampling to create an
  empirical distribution. NOTE: This is NOT full Bayesian MCMC
  inference; it uses bootstrap simulation with prior parameters as
  weights. Interpret "credible intervals" as bootstrap percentile
  confidence intervals.

- priorAUC:

  Prior belief about AUC value for Bayesian analysis (center of prior
  distribution).

- priorPrecision:

  Precision of prior belief (higher values = more confident prior).

- clinicalUtilityAnalysis:

  Perform clinical utility analysis including net benefit curves,
  decision curve analysis, and clinical impact assessment.

- treatmentThresholdMin:

  Lowest treatment threshold probability for the decision curve.

- treatmentThresholdMax:

  Highest treatment threshold probability for the decision curve.

- treatmentThresholdStep:

  Step between thresholds. The defaults give thresholds from 5 to 50
  percent in 5 percent steps.

- harmBenefitRatio:

  Ratio of harm from unnecessary treatment to benefit from necessary
  treatment. Lower values favor more aggressive treatment policies.

- interventionCost:

  Include cost-effectiveness considerations in clinical utility
  analysis.

- fixedSensSpecAnalysis:

  Determine cutoffs based on fixed sensitivity or specificity values and
  display corresponding performance metrics.

- fixedAnalysisType:

  Choose whether to fix sensitivity or specificity value for cutoff
  determination.

- fixedSensitivityValue:

  Target sensitivity value (0-1) for determining the corresponding
  cutoff and specificity.

- fixedSpecificityValue:

  Target specificity value (0-1) for determining the corresponding
  cutoff and sensitivity.

- showFixedROC:

  Display separate ROC curve highlighting the fixed
  sensitivity/specificity point.

- fixedInterpolation:

  Method for selecting a cutoff near the target sensitivity/specificity.
  Achieved rates always use empirical classifications at the returned
  cutoff. Linear interpolation may miss the target; Stepwise meets or
  exceeds it.

- showFixedExplanation:

  Display explanatory guide for fixed sensitivity/specificity analysis
  including clinical interpretation, interpolation methods, and usage
  recommendations.

- metaAnalysis:

  Shows why marker columns from one cohort cannot be pooled as
  independent studies. No pooled estimate or inference is computed,
  including with the legacy override.

- metaAnalysisMethod:

  Deprecated compatibility option. Within-cohort meta-analysis is
  unavailable.

- heterogeneityTest:

  Deprecated compatibility option. No heterogeneity inference is
  computed.

- forestPlot:

  Deprecated compatibility option. No pooled forest plot is computed.

- overrideMetaAnalysisWarning:

  Deprecated and ignored. An override cannot correct dependence between
  markers.

## Value

A results object containing:

|  |  |  |  |  |  |
|----|----|----|----|----|----|
| `results$instructions` |  |  |  |  | a html |
| `results$procedureNotes` |  |  |  |  | a html |
| `results$runSummary` |  |  |  |  | a html |
| `results$outcomeCoding` |  |  |  |  | Class levels with their counts and the role each plays in the analysis |
| `results$clinicalInterpretationTable` |  |  |  |  | a table |
| `results$resultsTable` |  |  |  |  | an array of tables |
| `results$sensSpecTable` |  |  |  |  | an array of tables |
| `results$thresholdTable` |  |  |  |  | a table |
| `results$fixedSensSpecTable` |  |  |  |  | a table |
| `results$fixedSensSpecExplanation` |  |  |  |  | a html |
| `results$aucSummaryTable` |  |  |  |  | a table |
| `results$delongComparisonTable` |  |  |  |  | a table |
| `results$delongTest` |  |  |  |  | a preformatted |
| `results$plotROC` |  |  |  |  | an array of images |
| `results$interactivePlot` |  |  |  |  | an image |
| `results$fixedSensSpecROC` |  |  |  |  | an array of images |
| `results$criterionPlot` |  |  |  |  | an array of images |
| `results$prevalencePlot` |  |  |  |  | an array of images |
| `results$dotPlot` |  |  |  |  | an array of images |
| `results$dotPlotMessage` |  |  |  |  | a html |
| `results$precisionRecallPlot` |  |  |  |  | an array of images |
| `results$idiTable` |  |  |  |  | a table |
| `results$nriTable` |  |  |  |  | a table |
| `results$effectSizeTable` |  |  |  |  | a table |
| `results$powerAnalysisTable` |  |  |  |  | a table |
| `results$bayesianROCTable` |  |  |  |  | a table |
| `results$clinicalUtilityTable` |  |  |  |  | a table |
| `results$metaAnalysisWarning` |  |  |  |  | a html |
| `results$metaAnalysisTable` |  |  |  |  | a table |
| `results$decisionCurveTable` |  |  |  |  | a table |
| `results$partialAUCTable` |  |  |  |  | a table |
| `results$bootstrapCITable` |  |  |  |  | a table |
| `results$rocComparisonTable` |  |  |  |  | a table |
| `results$effectSizePlot` |  |  |  |  | an array of images |
| `results$powerCurvePlot` |  |  |  |  | an array of images |
| `results$bayesianTracePlot` |  |  |  |  | an array of images |
| `results$decisionCurvePlot` |  |  |  |  | an array of images |
| `results$metaAnalysisForestPlot` |  |  |  |  | an array of images |

Tables can be converted to data frames with `asDF` or
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html). For
example:

`results$outcomeCoding$asDF`

`as.data.frame(results$outcomeCoding)`
