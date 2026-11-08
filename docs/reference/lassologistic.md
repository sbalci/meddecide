# LASSO Logistic Regression

Performs LASSO-penalized logistic regression for variable selection in
binary classification problems. Ideal for diagnostic pathology studies
that build classifiers (e.g., tumor type A vs B) with automatic feature
selection.

## Usage

``` r
lassologistic(
  data,
  outcome,
  outcomeLevel,
  explanatory,
  penalty = "lasso",
  alpha = 0.5,
  lambda = "lambda.1se",
  nfolds = 10,
  random_seed = 123456,
  standardize = TRUE,
  suitabilityCheck = TRUE,
  bootstrapValidation = FALSE,
  bootstrapN = 200,
  cv_plot = TRUE,
  coef_plot = TRUE,
  roc_plot = TRUE,
  scoringSystem = FALSE,
  scoringMethod = "maxscaled",
  scoringMaxPoints = 10,
  scoreCutMethod = "median",
  scoreCutPoints = "",
  scoreLookupTable = TRUE,
  showSummary = FALSE,
  showExplanations = FALSE,
  showMethodologyNotes = FALSE,
  includeClinicalGuidance = FALSE,
  showVariableImportance = FALSE,
  showModelComparison = FALSE,
  patientID = NULL
)
```

## Arguments

- data:

  The data as a data frame, with one independent observation per row.

- outcome:

  Binary outcome variable to classify. Can be factor or numeric with
  exactly two observed values.

- outcomeLevel:

  Level of the outcome that is the event (positive class), for example
  Malignant. Required for a nominal or ordinal outcome: it is never
  taken from the order of the levels, and until it is chosen the
  analysis shows the levels found and fits nothing. A numeric outcome
  coded 0/1 is read as 1 = event without a choice; for any other numeric
  coding, set the outcome's measure type to Nominal and choose the
  level. From R the argument has no default: pass the level, or NULL for
  a 0/1 outcome.

- explanatory:

  Variables to be considered for selection. At least 2 required.
  Constant variables are removed automatically.

- penalty:

  Type of regularization penalty. LASSO (L1) produces sparse models by
  setting coefficients to zero. Ridge (L2) shrinks but retains all.
  Elastic Net combines both.

- alpha:

  Mixing parameter for elastic net. Only used when penalty is
  elasticnet.

- lambda:

  Method for selecting the optimal lambda from cross-validation. 1SE
  rule tends to select fewer variables (more conservative).

- nfolds:

  Number of folds for cross-validation. Automatically reduced when
  sample size is limited.

- random_seed:

  Random seed for reproducible cross-validation fold assignment.

- standardize:

  Whether glmnet standardizes predictors within each training fold and
  bootstrap fit, using its population (1/n) standard deviation. Reported
  coefficients remain on the original measurement scale.

- suitabilityCheck:

  Check sample size, events-per-variable ratio, multicollinearity, and
  whether regularization is needed.

- bootstrapValidation:

  Perform bootstrap optimism-corrected validation (Harrell method).
  Reports corrected AUC, calibration slope, and Brier score. Scaling and
  lambda selection are repeated within every resample. Copies of an
  observation in a bootstrap sample remain in the same CV fold.

- bootstrapN:

  Number of bootstrap iterations for internal validation.

- cv_plot:

  Show cross-validation deviance vs lambda plot.

- coef_plot:

  Show bar plot of selected variable coefficients.

- roc_plot:

  Show ROC curve with AUC and confidence interval.

- scoringSystem:

  Convert model coefficients to an integer-point scoring system.
  Multiple methods available following published standards.

- scoringMethod:

  Method for converting each predictor's log-odds contribution (the
  coefficient times the contrast its criterion applies) to integer
  points. Beta10: multiply by 10 and round (the Beta10/integer method of
  Mehta et al. 2016). Smallest: divide by the smallest contribution and
  round, a Sullivan-type scale with one point per smallest contribution
  (Sullivan et al. 2004); contributions below 1e-8 of the largest are
  not used as the divisor. This option was previously labeled
  "Schneeweiss"; Schneeweiss et al. 2003 instead add one point per 0.3
  increase in the log odds ratio. Max-scaled: divide by the largest
  absolute coefficient and multiply by scoringMaxPoints, so the
  strongest predictor scores exactly the maximum. This option was
  previously labeled "Sullivan/D'Agostino"; it is not the Sullivan 2004
  Framingham procedure, which awards points per category of each factor
  relative to a reference factor's per-category distance. Compare:
  generate all three and show performance comparison; the selected
  points and score performance then use Max-scaled, the default. Every
  method gives a selected predictor at least one point (of its sign)
  when its points would round to zero, and caps a single predictor at
  1000 points.

- scoringMaxPoints:

  Points assigned to the strongest predictor in the Max-scaled method.
  The Beta10 method uses a fixed x10 coefficient scaling and ignores
  this value; the Smallest method scales by the smallest contribution
  and also ignores it.

- scoreCutMethod:

  How continuous predictors are dichotomized when awarding points. A
  predictor earns its points when the patient's value exceeds this cut.
  'median' (the default) splits at the sample median, which is
  data-derived and will differ in another cohort. 'manual' lets you
  enter established clinical thresholds. Fixed cutoffs alone do not
  establish transportability; the score still requires external
  validation.

- scoreCutPoints:

  Cut points on the ORIGINAL measurement scale, as 'variable=value'
  pairs separated by commas or semicolons, e.g. 'ki67=20, age=65'. Used
  when Cut Point method is 'manual'. Any continuous predictor not listed
  falls back to the sample median, and that fallback is reported. Binary
  predictors ignore this - they score when present.

- scoreLookupTable:

  Generate a table listing each observed total score with its number of
  cases, events and observed (in-sample) event rate. These are
  proportions in this dataset, not model predictions.

- showSummary:

  Display a natural-language summary of the main results.

- showExplanations:

  Display explanations of LASSO logistic regression methodology.

- showMethodologyNotes:

  Show technical notes about regularization and validation.

- includeClinicalGuidance:

  Include guidance for clinical interpretation of results.

- showVariableImportance:

  Display variable importance rankings across lambda values.

- showModelComparison:

  Compare the selected penalized model with unpenalized logistic refits.

- patientID:

  Optional identifier for independent patients. Repeated or missing IDs
  among analyzed rows are rejected. Each row is otherwise assumed
  independent; repeated lesions, visits, or readings require a
  patient-level summary or a method that accounts for clustering.

## Value

A results object containing:

|                              |     |     |     |     |           |
|------------------------------|-----|-----|-----|-----|-----------|
| `results$todo`               |     |     |     |     | a html    |
| `results$notices`            |     |     |     |     | a html    |
| `results$suitabilityReport`  |     |     |     |     | a table   |
| `results$modelSummary`       |     |     |     |     | a table   |
| `results$coefficients`       |     |     |     |     | a table   |
| `results$performance`        |     |     |     |     | a table   |
| `results$scoringTable`       |     |     |     |     | a table   |
| `results$scoringPerformance` |     |     |     |     | a table   |
| `results$methodComparison`   |     |     |     |     | a table   |
| `results$lookupTable`        |     |     |     |     | a table   |
| `results$validationTable`    |     |     |     |     | a table   |
| `results$cv_plot`            |     |     |     |     | an image  |
| `results$coef_plot`          |     |     |     |     | an image  |
| `results$roc_plot`           |     |     |     |     | an image  |
| `results$predictions`        |     |     |     |     | an output |
| `results$summaryText`        |     |     |     |     | a html    |
| `results$lassoExplanation`   |     |     |     |     | a html    |
| `results$methodologyNotes`   |     |     |     |     | a html    |
| `results$clinicalGuidance`   |     |     |     |     | a html    |
| `results$variableImportance` |     |     |     |     | a table   |
| `results$modelComparison`    |     |     |     |     | a table   |

Tables can be converted to data frames with `asDF` or
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html). For
example:

`results$suitabilityReport$asDF`

`as.data.frame(results$suitabilityReport)`
