# Analysis Without Gold Standard

Analysis of multiple binary tests when no perfect reference exists.
Implements a conditional-independence two-class latent class model,
fixed-prior penalized EM point estimation with numerical refinement, and
descriptive agreement with self-built reference rules. Latent classes
are unlabeled, and reference-rule results are not diagnostic-accuracy
estimates.

## Usage

``` r
nogoldstandard(
  data,
  clinicalPreset = "none",
  test1,
  test1Positive,
  test2 = NULL,
  test2Positive,
  test3 = NULL,
  test3Positive,
  test4 = NULL,
  test4Positive,
  test5 = NULL,
  test5Positive,
  method = "latent_class",
  bootstrap = FALSE,
  nboot = 1000,
  alpha = 0.05,
  verbose = FALSE,
  seed = 0,
  showSummary = FALSE,
  showMethodGuide = FALSE
)
```

## Arguments

- data:

  The data as a data frame.

- clinicalPreset:

  Illustrative scenario examples only. They do not change analysis
  settings and are not clinical guides, validated recommendations, or
  substitutes for a study-specific analysis plan.

- test1:

  First diagnostic test variable.

- test1Positive:

  The positive level for Test 1.

- test2:

  Second diagnostic test variable.

- test2Positive:

  The positive level for Test 2.

- test3:

  Third diagnostic test variable (optional).

- test3Positive:

  The positive level for Test 3.

- test4:

  Fourth diagnostic test variable (optional).

- test4Positive:

  The positive level for Test 4.

- test5:

  Fifth diagnostic test variable (optional).

- test5Positive:

  The positive level for Test 5.

- method:

  Method for analyzing tests without a gold standard. Composite
  Reference uses a strict majority (more than half positive); ties with
  an even number of tests are classified as rule negative.

- bootstrap:

  Calculate case-resampling percentile confidence intervals. For
  latent-class and penalized-EM models, confidence intervals are
  reported only when this option is enabled because ordinary binomial
  intervals do not account for latent-variable estimation. Latent
  intervals require a converged, reportable full-sample fit and at least
  20 finite estimates for each interval. Coverage is approximate and may
  be poor with small samples, boundaries or weak identification; case
  resampling assumes independent rows.

- nboot:

  Number of bootstrap samples for confidence intervals.

- alpha:

  Alpha level for confidence intervals.

- verbose:

  Show detailed analysis diagnostics, including convergence, random
  starts, exclusions, and bootstrap failures when bootstrap intervals
  are enabled.

- seed:

  Base random seed for the reproducible latent-class multi-start search
  and bootstrap resampling. Each start is offset from this base, so
  changing it shifts the whole reproducible sequence; the default (0)
  reproduces the previous behavior.

- showSummary:

  Show an optional plain-language summary. The summary describes the
  fitted quantities and their assumptions; it is not clinical guidance.

- showMethodGuide:

  Show an optional educational guide to the available methods. The
  scenarios are illustrative examples, not clinical guides or validated
  recommendations.

## Value

A results object containing:

|  |  |  |  |  |  |
|----|----|----|----|----|----|
| `results$notices` |  |  |  |  | a preformatted |
| `results$instructions` |  |  |  |  | a html |
| `results$agreement_stats` |  |  |  |  | a table |
| `results$clinical_summary` |  |  |  |  | a html |
| `results$method_guide` |  |  |  |  | a html |
| `results$prevalence` |  |  |  |  | a table |
| `results$test_metrics` |  |  |  |  | a table |
| `results$model_fit` |  |  |  |  | a table |
| `results$conditional_dependence` |  |  |  |  | Latent class analysis assumes the tests are conditionally independent within each latent class. For each pair this compares the observed two-way table with the one implied by the fitted model. A residual above 3.84 is descriptive evidence against conditional independence, but this squared statistic does not identify the direction or cause of dependence and cannot determine the direction of bias in the fitted parameters. With three tests the nominal residual degrees of freedom are zero, but exact fit is not guaranteed. Residuals remain descriptive and do not provide a formal chi-squared test or establish identifiability. |
| `results$diagnostics` |  |  |  |  | Detail of how the estimates were produced: sample size, method, convergence, number of random starts used, and bootstrap failures. Shown only when Verbose output is enabled. |
| `results$crosstab` |  |  |  |  | a table |
| `results$agreement_plot` |  |  |  |  | an image |

Tables can be converted to data frames with `asDF` or
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html). For
example:

`results$agreement_stats$asDF`

`as.data.frame(results$agreement_stats)`
