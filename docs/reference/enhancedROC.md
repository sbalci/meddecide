# Clinical ROC Analysis

Clinical ROC analysis toolkit for comprehensive diagnostic performance
evaluation. Includes ROC curve analysis, Youden Index optimization,
sensitivity/specificity analysis, optimal cutoff determination, and
comparative ROC analysis. Essential for biomarker validation, diagnostic
test evaluation, and clinical decision support in medical research.

## Usage

``` r
enhancedROC(
  data,
  outcome,
  positiveClass,
  predictors,
  analysisType = "single",
  direction = "higher",
  youdenOptimization = TRUE,
  customCutoffs = "",
  sensitivityThreshold = 0,
  specificityThreshold = 0,
  confidenceLevel = 95,
  bootstrapSamples = 1000,
  useBootstrap = FALSE,
  bootstrapMethod = "bca",
  bootstrapPartialAUC = FALSE,
  stratifiedBootstrap = FALSE,
  seed = 0,
  pairwiseComparisons = FALSE,
  comparisonMethod = "delong",
  rocCurve = TRUE,
  aucTable = TRUE,
  cutoffTable = FALSE,
  optimalCutoffs = TRUE,
  diagnosticMetrics = TRUE,
  clinicalMetrics = FALSE,
  smoothMethod = "none",
  partialAuc = FALSE,
  partialAucType = "specificity",
  partialAucFrom = 0.8,
  partialAucTo = 1,
  crocAnalysis = FALSE,
  crocAlpha = 7,
  convexHull = FALSE,
  detectImbalance = FALSE,
  imbalanceThreshold = 3,
  showImbalanceWarning = FALSE,
  recommendPRC = FALSE,
  prevalence = 0.1,
  useObservedPrevalence = TRUE,
  clinicalContext = "general",
  clinicalPresets = "custom",
  comprehensive_output = FALSE,
  clinical_interpretation = FALSE,
  showAnalysisSummary = FALSE,
  showClinicalReport = FALSE,
  showTableNotes = FALSE,
  plotTheme = "jamovi",
  plotWidth = 600,
  plotHeight = 600,
  showCutoffPoints = FALSE,
  showConfidenceBands = FALSE,
  showMetricsDiff = FALSE,
  statisticalComparison = FALSE,
  calibrationAnalysis = FALSE,
  calibrationPlot = FALSE,
  hosmerLemeshow = FALSE,
  hlGroups = 10,
  brierScore = FALSE,
  calibrationMetrics = FALSE,
  splineCalibration = FALSE,
  splineKnots = 4,
  eoRatio = FALSE,
  calibrationDensity = FALSE,
  multiClassROC = FALSE,
  multiClassStrategy = "ovr",
  multiClassAveraging = "macro",
  clinicalImpact = FALSE,
  nntCalculation = FALSE,
  clinicalUtilityCurve = FALSE,
  decisionImpactTable = FALSE,
  internalValidation = FALSE,
  validationMethod = "bootstrap",
  decisionImpactCurves = FALSE,
  impactCutoffs = "0.5",
  utilityThreshold = 0.1,
  workloadPopulationSize = 1000,
  analysisUnit = "slide",
  prevalenceScenarios = "",
  validationPanel = FALSE,
  validationNegative,
  referenceDescription = "",
  modelVersion = "",
  cohortRole = "frozen",
  samplingDesign = "other",
  thresholdSource = "prespecified",
  predictionScale = "score",
  patientID = NULL,
  siteID = NULL,
  partitionID = NULL,
  validationBootstrap = FALSE,
  validationDraws = 999
)
```

## Arguments

- data:

  The data as a data frame.

- outcome:

  Outcome variable (disease status). A factor with two levels, or with
  more than two (choose one as Positive class and the others are pooled
  as negative, or use Multi-class ROC). A numeric outcome must have
  exactly two values; 0/1 reads 1 as positive. Each row must be a
  different patient: every interval and test assumes independent rows.

- positiveClass:

  Level of outcome treated as the positive class (condition present),
  matched exactly. Pass NULL to leave it unset: a numeric outcome coded
  0/1 then reads 1 as positive, and any other outcome leaves the
  analysis waiting for a choice, because levels are never chosen from
  their order. Every other level is analyzed as negative (pooled when
  there are more than two). A numeric outcome must have exactly two
  values; to choose among more, make it a factor.

- predictors:

  Numeric predictor variables for ROC analysis, one value per patient
  (row).

- analysisType:

  Single analyses each predictor on its own; Comparative adds the
  pairwise comparison tables and the comparative ROC plot. Comprehensive
  Diagnostic Performance currently gives the same output as Single.

- direction:

  Direction of the predictor-outcome relationship. The default is
  "Higher values indicate positive outcome" because it is a stated
  hypothesis rather than an estimate. "Auto" reads the orientation off
  the same data that supply the AUC - pROC compares the two groups'
  median values

  - so the direction is fitted rather than assumed, and every AUC is
    biased upward (for n = 20 the AUC expected under no association is
    about 0.60, not 0.50, and exceeds 0.60 in roughly 45 of every 100
    markers carrying no information at all). It is not floored at 0.5
    either: a median split can disagree with the ranks, so about 12 of
    those 100 null markers are still reported below 0.5. "Auto" can also
    silently invert a marker and report 0.825 where the un-inverted
    reading is 0.175. Use "Auto" only for exploratory screening of
    markers whose direction is genuinely unknown, and say so.

- youdenOptimization:

  Find the optimal cutoff by maximizing the Youden index (sensitivity +
  specificity - 1), subject to the minimum sensitivity/specificity
  below. When off, the cutoff closest to the top-left corner of the ROC
  curve is reported instead. The minimum sensitivity and specificity are
  used only by the Youden search; with this off they are not applied and
  a warning says so.

- customCutoffs:

  Comma-separated list of custom cutoffs to evaluate (e.g., 0.1, 0.5,
  0.9)

- sensitivityThreshold:

  Minimum sensitivity a cutoff must achieve to be considered. 0 (the
  default) searches for the overall Youden optimum with no constraint.
  Raising it restricts the search, which is what you want for a
  screening test, but the reported cutoff is then the best one meeting
  your minimum rather than the Youden maximum - a notice says so when
  the two differ. Used only when Youden index optimization is on.

- specificityThreshold:

  Minimum specificity a cutoff must achieve to be considered. 0 (the
  default) searches for the overall Youden optimum with no constraint.
  Raising it restricts the search, which is what you want for a
  confirmatory test, but the reported cutoff is then the best one
  meeting your minimum rather than the Youden maximum - a notice says so
  when the two differ. Used only when Youden index optimization is on.

- confidenceLevel:

  Confidence level for AUC confidence intervals

- bootstrapSamples:

  Number of resamples for every resampling step except the frozen-model
  report: bootstrap confidence intervals (AUC, partial AUC,
  multi-class), the ROC confidence bands, the bootstrap comparison test,
  and the number of permutations for Venkatraman's test. With B
  permutations no p-value below 1/(B + 1) can be shown, so keep at least
  1000 for a test.

- useBootstrap:

  Use bootstrap methods for confidence intervals

- bootstrapMethod:

  Method for calculating bootstrap confidence intervals. BCa corrects
  for bias and skewness and is second-order accurate in large samples;
  for a single AUC in small samples no interval method is uniformly best
  (Obuchowski and Lieber 1998; Feng et al. 2017).

- bootstrapPartialAUC:

  Bootstrap confidence interval for the partial AUC, using the resample
  count, interval type (BCa/percentile/basic) and stratification set
  above. The interval is for the raw partial AUC on the chosen focus
  range, not for the McClish-normalized value.

- stratifiedBootstrap:

  Resample cases and controls separately, keeping the outcome
  proportions, in every bootstrap of this analysis: the AUC and
  partial-AUC intervals, the bootstrap comparison test and the ROC
  confidence bands (recommended for imbalanced data). Off by default:
  unticked, these bootstraps resample patients without regard to
  outcome.

- seed:

  Random seed used for every resampling step - bootstrap confidence
  intervals, bootstrap ROC comparisons, and internal validation
  resamples or cross-validation folds. Each step starts from this seed,
  so a predictor's result does not depend on which predictors or options
  were resampled before it. Fixing it makes a run reproducible: the same
  data and options give the same intervals every time. Change it to
  check how sensitive a result is to the particular resamples drawn.

- pairwiseComparisons:

  Perform pairwise comparisons between ROC curves

- comparisonMethod:

  Method for comparing ROC curves. DeLong et al. (1988) and Bootstrap
  test whether the two AUCs differ. The Venkatraman permutation test
  (Venkatraman & Begg 1996, paired data) tests whether the two ROC
  curves are identical over their whole range, not whether their AUCs
  differ.

- rocCurve:

  Display ROC curve plot

- aucTable:

  Display AUC summary table

- cutoffTable:

  Display detailed cutoff analysis

- optimalCutoffs:

  Display optimal cutoff summary

- diagnosticMetrics:

  Display comprehensive diagnostic metrics

- clinicalMetrics:

  Display clinical application metrics (PPV, NPV, LR+, LR-)

- smoothMethod:

  Method for smoothing ROC curves

- partialAuc:

  Calculate partial AUC for specific sensitivity/specificity ranges

- partialAucType:

  Whether to calculate pAUC over a specificity or sensitivity range

- partialAucFrom:

  Lower end of the partial AUC range, on the specificity or sensitivity
  scale chosen above, for example 0.8 for high specificity.

- partialAucTo:

  Upper end of the partial AUC range; it must be greater than the lower
  end.

- crocAnalysis:

  Calculate Concentrated ROC curves for early retrieval analysis

- crocAlpha:

  Concentration parameter for CROC exponential magnifier function

- convexHull:

  Calculate the ROC convex hull (operating points reachable by randomly
  mixing two cut-offs; in-sample, so optimistic)

- detectImbalance:

  Automatically detect class imbalance and recommend PRC when
  appropriate

- imbalanceThreshold:

  Ratio threshold for imbalance detection (e.g., 3.0 means 3:1 or 1:3
  ratio)

- showImbalanceWarning:

  Add the explanatory detail to the class-imbalance warning. The warning
  itself is always shown when imbalance is detected; this only controls
  how much it explains.

- recommendPRC:

  Recommend adding the Precision-Recall curve alongside the ROC curve
  when imbalance is detected.

- prevalence:

  Disease prevalence to assume when computing predictive values. Used
  only when "Use observed prevalence" is unticked - set it to the
  prevalence of the population the test will actually be used in, which
  for a screening setting is usually far lower than in a case-control
  sample.

- useObservedPrevalence:

  Compute PPV, NPV and the clinical impact metrics at the prevalence
  observed in these data (the default). Untick it to assume a different
  prevalence instead - appropriate when the sample is enriched for cases
  and does not reflect the population the test will be used in. The
  prevalence actually used is printed in the results.

- clinicalContext:

  Clinical application context for interpretation

- clinicalPresets:

  Sets how the optimal cutoff is searched for: each preset turns Youden
  index optimization on and sets the minimums (Screening: sensitivity
  0.90; Diagnostic validation: 0.80 and 0.80; Confirmatory: specificity
  0.95; Research: keeps the minimums you enter, so it differs from
  Custom only by switching Youden optimization on). No other option
  changes. The controls a preset overrides are greyed while it is
  selected.

- comprehensive_output:

  Include comprehensive statistical details

- clinical_interpretation:

  Provide clinical context for ROC analysis results

- showAnalysisSummary:

  A plain-language summary of the main results: the best AUC with its
  interval and the cutoff with its sensitivity and specificity. Internal
  validation results appear in the same panel whenever Internal
  validation is ticked.

- showClinicalReport:

  Copy-ready Methods and Results sentences built from these results.
  Check them against the tables before pasting them into a report.

- showTableNotes:

  Show explanatory notes and cell footnotes below the results tables,
  including methods, definitions and cautions for reading each table.
  The random seed of a resampled result is always shown.

- plotTheme:

  Visual theme for the ROC plots. "jamovi (follow global)" draws them
  with the theme chosen in jamovi, like every other plot in the
  document. Classic, Modern and Clinical adjust the grid lines and
  border on top of it.

- plotWidth:

  Width of ROC plots

- plotHeight:

  Height of ROC plots

- showCutoffPoints:

  Highlight optimal cutoff points on ROC curve

- showConfidenceBands:

  Display confidence bands around ROC curve

- showMetricsDiff:

  Display detailed differences between model metrics

- statisticalComparison:

  Perform comprehensive statistical comparison between models

- calibrationAnalysis:

  Assess calibration (agreement between observed and predicted
  probabilities)

- calibrationPlot:

  Display the calibration plot: observed proportion against predicted
  probability in the Hosmer-Lemeshow risk groups, with an optional
  flexible spline curve (splineCalibration)

- hosmerLemeshow:

  Perform Hosmer-Lemeshow goodness-of-fit test

- hlGroups:

  Number of equal-sized risk groups used both for the Hosmer-Lemeshow
  test and for binning the calibration plot

- brierScore:

  Calculate Brier score and scaled Brier score

- calibrationMetrics:

  Calculate calibration slope, intercept, and calibration-in-the-large

- splineCalibration:

  Fit a flexible calibration curve by logistic regression of the outcome
  on a natural cubic spline of the logit of the predicted probability, a
  variant of the flexible calibration curves of Austin & Steyerberg
  (2019), who used loess and restricted cubic splines on the probability
  scale. Adds the smooth curve to the calibration plot and the
  integrated calibration index (ICI, the mean absolute difference
  between the curve and the diagonal) with E50, E90 and Emax to the
  calibration summary. Requires calibrationAnalysis.

- splineKnots:

  Knots of the spline calibration curve (3 to 7). The spline has knots -
  1 degrees of freedom; more knots follow the data more closely but need
  more events per knot. Used only when splineCalibration is on.

- eoRatio:

  Expected/Observed ratio for overall calibration. Reported only when
  the predictor is supplied as a probability in 0 to 1; when a logistic
  model has to be fitted here to get probabilities the ratio is 1 by
  construction and the cell is left blank.

- calibrationDensity:

  Overlay the distribution of predicted probabilities along the bottom
  of the calibration plot, so a calibration point backed by two patients
  is not read like one backed by two hundred. Skipped when there are
  fewer than 10 usable probabilities to smooth.

- multiClassROC:

  Enable multi-class ROC analysis for outcomes with \>2 levels

- multiClassStrategy:

  Strategy for multi-class ROC analysis

- multiClassAveraging:

  Method for averaging AUC across classes. Both averages are reported
  side by side for the One-vs-Rest strategy: Macro weights every class
  equally, Weighted weights each class by how many cases it contains.
  The One-vs-One strategy reports only its own unweighted average over
  class pairs, which is what that statistic is defined as. Both averages
  are always shown, so this setting changes no displayed value; with
  One-vs-One, Weighted only raises a notice.

- clinicalImpact:

  Calculate observed or projected workload at independently supplied
  score cutoffs

- nntCalculation:

  Show inverse net benefit and inverse Youden index; neither is a count
  of tests or reviews

- clinicalUtilityCurve:

  Display clinical utility curve showing test consequences

- decisionImpactTable:

  Show decision impact at various thresholds

- internalValidation:

  Perform internal validation using cross-validation or bootstrap

- validationMethod:

  Bootstrap: Harrell's optimism-corrected AUC of a logistic model of the
  marker (resamples holding one outcome group are dropped and counted).
  Cross-validation: stratified 10-fold, or one fold per patient of the
  smaller outcome group when it has fewer than 10, reporting the mean
  fold AUC and the SD across folds, which is not a standard error.

- decisionImpactCurves:

  Plot the clinical impact curve: how many of 1000 tested patients would
  be called high risk at each threshold probability, and how many of
  those actually have the event.

- impactCutoffs:

  Fixed score cutoffs on the marker's own scale, comma separated. The
  default 0.5 is meant for predicted probabilities (Prediction scale =
  probability); for a raw marker enter cutoffs inside its observed
  range. A warning names any cutoff that classifies every analyzed
  patient the same way.

- utilityThreshold:

  Threshold probability for net benefit: the risk at which a clinician
  is indifferent between acting and not acting, so its odds are the harm
  of a false positive relative to the benefit of a true positive (0.1
  means one true positive is worth nine false positives). Used by the
  clinical impact and workload tables; it is not a score cutoff.

- workloadPopulationSize:

  Size of the population the projected workload counts are scaled to.
  Used for every projected row: the main prevalence when Observed
  prevalence is unticked, and every additional target prevalence.
  Observed rows count the analyzed patients instead.

- analysisUnit:

  What one row is (slide, core, patient...). Printed in the frozen-model
  report; every analyzed row weighs equally in its metrics.

- prevalenceScenarios:

  Extra target-population prevalences, as proportions between 0 and 1
  separated by commas (for example 0.05, 0.2). Each adds projected rows
  to the workload table at the same fixed cutoffs. Leave blank for none;
  an unreadable entry is ignored with a warning.

- validationPanel:

  Evaluates an already-fitted model or score at prespecified fixed
  cutoffs, without refitting or choosing a cutoff from these data, and
  replaces every other output with the validation context, denominator
  ledger and frozen-model metrics. Needs a positive class, an explicit
  negative level, an explicit Direction and the fixed score cutoffs.

- validationNegative:

  The outcome level that means the condition is absent. Required by the
  frozen-model report, which refuses any outcome level that is neither
  this nor the positive class instead of pooling it as negative.

- referenceDescription:

  Free text describing the reference standard and whether its readers
  were blinded to the score (for example histology, blinded). Printed in
  the frozen-model validation context.

- modelVersion:

  Identifier of the fitted model or score version being evaluated.
  Required when Cohort role is frozen, so the report names exactly which
  model the metrics belong to.

- cohortRole:

  Declared by you and printed in the frozen-model report; the analysis
  does not check it. A value left at its default is printed as (default
  setting).

- samplingDesign:

  Declared by you and printed in the frozen-model report; the analysis
  does not check it. A value left at its default is printed as (default
  setting). The default is Other / unknown so that an untouched report
  does not assert a sampling design; how PPV and NPV should be read
  depends on it.

- thresholdSource:

  Declared by you and printed in the frozen-model report; the analysis
  does not check it. A value left at its default is printed as (default
  setting).

- predictionScale:

  What the predictor values are. Score (default) is any marker or model
  score: the calibration summary and plot, Brier score, E/O ratio,
  Hosmer-Lemeshow test and the decision and clinical impact curves then
  use risks from a logistic model of the score fitted to these data
  (in-sample). Probability means the values are predicted probabilities
  of the selected positive class, assessed as supplied; a predictor with
  a value outside 0 to 1 gets none of those outputs, and a probability
  is never reversed. Values between 0 and 1 are not taken as
  probabilities unless this says so. Frozen-model validation uses the
  same setting.

- patientID:

  Patient identifier. On the main analysis it is used only to warn when
  a patient has several rows: every panel except the Frozen-model
  validation report treats each row as an independent patient, so their
  intervals and tests are too narrow then. Only the Frozen-model
  validation report resamples whole patients.

- siteID:

  Optional site or center of each row. The frozen-model report then adds
  one set of metrics per site, conditional on the observed sites, and
  resamples within sites. Every row needs a site, and a patient may not
  appear at two sites.

- partitionID:

  Optional development or validation label of each row, used by the
  frozen-model report to check that no patient appears in more than one
  partition (leakage). Requires a patient identifier.

- validationBootstrap:

  Adds percentile confidence intervals to the frozen-model metrics,
  resampling whole patients when a patient identifier is given (jointly
  across models, within sites). Without it the report shows point
  estimates only.

- validationDraws:

  Number of patient-level bootstrap replicates for the frozen-model
  intervals. Separate from Bootstrap samples, which serves the other
  panels.

## Value

A results object containing:

|  |  |  |  |  |  |
|----|----|----|----|----|----|
| `results$results$notices` |  |  |  |  | a html |
| `results$results$instructions` |  |  |  |  | a html |
| `results$results$outcomeCoding` |  |  |  |  | Outcome levels with their counts and the role each plays in the analysis |
| `results$results$imbalanceMetrics` |  |  |  |  | a table |
| `results$results$precisionRecallTable` |  |  |  |  | Metrics for imbalanced data analysis |
| `results$results$analysisSummary` |  |  |  |  | Plain language summary of key findings |
| `results$results$clinicalReport` |  |  |  |  | Copy-ready clinical report sentences for publications and reports |
| `results$results$aucSummary` |  |  |  |  | AUC values with confidence intervals for each predictor |
| `results$results$rocComparisons` |  |  |  |  | Pairwise comparisons between ROC curves |
| `results$results$detailedComparison` |  |  |  |  | Comprehensive comparison of diagnostic metrics between models |
| `results$results$statisticalSummary` |  |  |  |  | Summary of statistical tests for model comparison |
| `results$results$optimalCutoffSummary` |  |  |  |  | Youden Index optimization results for each predictor |
| `results$results$cutoffAnalysis` |  |  |  |  | Comprehensive analysis across multiple cutoff values |
| `results$results$diagnosticPerformance` |  |  |  |  | Comprehensive diagnostic performance measures at optimal cutoff |
| `results$results$clinicalApplicationMetrics` |  |  |  |  | Clinical metrics including predictive values and likelihood ratios |
| `results$results$partialAucAnalysis` |  |  |  |  | Partial AUC analysis for specific sensitivity/specificity ranges |
| `results$results$crocAnalysisTable` |  |  |  |  | Concentrated ROC analysis with early retrieval focus |
| `results$results$convexHullTable` |  |  |  |  | ROC convex hull - operating points reachable by randomly mixing two cut-offs (in-sample) |
| `results$results$comprehensiveAnalysisSummary` |  |  |  |  | Enhanced statistical summary for comprehensive output |
| `results$results$clinicalInterpretationGuide` |  |  |  |  | a html |
| `results$results$methodsExplanation` |  |  |  |  | a html |
| `results$results$rocCurvePlot` |  |  |  |  | ROC curves with optimal cutoff points |
| `results$results$prcPlot` |  |  |  |  | Precision-Recall curve for imbalanced data |
| `results$results$comparativeROCPlot` |  |  |  |  | Multiple ROC curves for comparison |
| `results$results$cutoffAnalysisPlot` |  |  |  |  | Sensitivity and specificity across cutoff values |
| `results$results$youdenIndexPlot` |  |  |  |  | Youden Index values across cutoff range |
| `results$results$clinicalDecisionPlot` |  |  |  |  | Clinical decision curves and threshold analysis |
| `results$results$crocCurvePlot` |  |  |  |  | Concentrated ROC curve with exponential magnifier transformation |
| `results$results$convexHullPlot` |  |  |  |  | ROC curve with convex hull overlay |
| `results$results$calibrationSummary` |  |  |  |  | Overall calibration metrics including Brier score |
| `results$results$hosmerLemeshowTable` |  |  |  |  | Hosmer-Lemeshow test for calibration |
| `results$results$calibrationPlotImage` |  |  |  |  | Calibration plot showing observed vs predicted probabilities |
| `results$results$multiClassAUC` |  |  |  |  | AUC values for each class in multi-class analysis |
| `results$results$multiClassAverage` |  |  |  |  | Averaged AUC across all classes |
| `results$results$multiClassROCPlot` |  |  |  |  | ROC curves for all classes |
| `results$results$clinicalImpactTable` |  |  |  |  | Number needed to test and clinical utility metrics |
| `results$results$decisionImpactSummary` |  |  |  |  | Clinical consequences at various decision thresholds |
| `results$results$clinicalUtilityPlot` |  |  |  |  | Decision curve: net benefit against threshold probability |
| `results$results$decisionImpactPlot` |  |  |  |  | Number of patients called high risk, and number of true events among them, per 1000 tested across threshold probabilities |
| `results$results$screeningWorkload` |  |  |  |  | a table |
| `results$results$validationContext` |  |  |  |  | a table |
| `results$results$denominatorLedger` |  |  |  |  | a table |
| `results$results$frozenMetrics` |  |  |  |  | a table |

## Examples

``` r
if (FALSE) { # \dontrun{
# pROC::aSAH ships with pROC, an Import, so the example runs in every module that
# carries this analysis. positiveClass and validationNegative are Level options: always
# required arguments (validationNegative = NULL unless the frozen-model report is used).
enhancedROC(
    data = pROC::aSAH,
    outcome = "outcome",
    positiveClass = "Poor",
    validationNegative = NULL,
    predictors = c("s100b", "ndka"))
} # }
```
