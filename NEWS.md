# meddecide 1.0.4 (2026-08-07)

This release is the result of end-to-end release reviews of `decisioncompare`, `decision`,
`agreement` and `lassologistic`. Each analysis was traced from its user interface through to its
printed output, every statistic was checked against an independent R package, and the confirmed
defects were fixed. Most of what follows is a correction to a number a clinician could already have
copied into a report.

## Breaking changes

- **`decisioncompare()` has four new required arguments: `goldNegative`, `test1Negative`,
  `test2Negative` and `test3Negative`.** They name the level of each variable that represents a
  genuine negative result, so that a third, equivocal level can be told apart from a negative one.
  jamovi does not permit a default on a `Level` option, so all four compile to bare parameters of
  the R wrapper: **existing scripts that call `decisioncompare()` will fail with `argument
  "goldNegative" is missing, with no default` until they are updated**, passing `NULL` for any test
  that is not in use. Nothing changes for users driving the analysis from the jamovi GUI. The
  reason for the change is the `excludeIndeterminate` defect described below — without a declared
  negative level the analysis has no way to know which rows are equivocal.

## Fixed

### `decisioncompare` (Compare Medical Decision Tests)

- **Every results table grew on each re-run.** The six calls meant to clear old rows used
  `clearRows()`, which is not a `jmvcore` Table method — only `deleteRows()` exists — and each call
  was wrapped in `try(silent = TRUE)`, so the error was swallowed and nothing was ever cleared. In
  jamovi, toggling *any* option re-runs the analysis on the same object, so the comparison table
  went 4 → 8 → 12 rows across three runs and each test appeared twice, then three times, then four.
  Anyone who changed a checkbox mid-session was reading a duplicated table.
- **`excludeIndeterminate` was a complete no-op.** It filtered on
  `c(positiveLevel, setdiff(levels, positiveLevel))` — that is, on every level — so equivocal
  results were still collapsed into Negative and still inflated specificity and NPV, the exact harm
  the checkbox promises to prevent. On a 60-case fixture with 20 Equivocal results, specificity read
  0.950 with the option both off and on; excluding the equivocal cases gives 0.900. With the new
  negative-level options supplied, equivocal rows are now genuinely dropped; when they are not
  supplied the analysis says so explicitly rather than pretending to have acted.
- **The manuscript-ready report named a winner the data could not support.** On a fixture where
  Cochran's Q gives p = 0.076 and no pairwise comparison survives Holm correction, the report read
  "t1 demonstrated OPTIMAL diagnostic performance" one sentence before "did not reveal a
  statistically significant difference". It now says "had the highest observed accuracy" with an
  explicit caveat, and the clinical recommendation panel carries a matching caution block.
- **Four result panels were permanently visible.** The `visible:` expressions began with `!`
  (`(!is.null(test3) && test3 != "")`), and `jmvcore` routes an expression to the R evaluator only
  when it matches `^\([\$A-Za-z].*\)$`; a leading `!` fails that test, so the raw — and therefore
  truthy — string was returned instead of being evaluated. An empty "Test 3 — Recoded Data" table
  sat under every two-test analysis, and the stratified table showed with no stratifier selected.
- **The manuscript text printed a literal placeholder,** `95% CI: [see confidence interval table]`.
  It now prints real Clopper-Pearson intervals.
- **A tie for best-performing test was broken by whichever test came first, silently.** Ties are
  now disclosed.
- **The difference table's "95% Confidence Interval" header did not say which method produced it.**
  It is now footnoted as the paired Wald interval for correlated proportions, and distinguished
  from the separate "CI Method for Agreement" option that governs the Overall Percent Agreement
  table.
- The three tests in `test-decisioncompare-critical-fixes.R` never called the module at all — they
  re-implemented the logic inline and asserted on their own arithmetic. They now exercise the real
  analysis.
- Verified unchanged and correct: all per-test metrics against `epiR::epi.tests` (to 1e-8);
  Cochran's Q = 5.150442, p = 0.076137 against `DescTools::CochranQTest` (six decimal places);
  McNemar with Holm correction against `stats::mcnemar.test` + `p.adjust` (1e-10); Wilson intervals
  against `binom::binom.confint`; exact intervals against Clopper-Pearson; the paired Wald standard
  error by hand. McNemar correctly compares diagnostic *correctness* against the gold standard
  rather than raw positivity — proven with a fixture on which the wrong design gives p = 1.000 and
  the right one p = 0.0015.

### `decision` (Medical Decision)

- **With a user-supplied population prevalence, the results row was arithmetically impossible.**
  The Prevalence cell was overwritten with the user's prior while PPV and NPV stayed at the raw 2×2
  values computed at the study prevalence, so a row could read "Prevalence 5.0% … PPV 88.9%" — for
  a test with sensitivity 0.80 and specificity 0.90, Bayes gives 29.6%. A pathologist reading PPV
  off a screening-prevalence run would have overstated positive predictive value roughly threefold,
  and the footnote made it worse by asserting the predictive values had already been prior-adjusted.
  PPV and NPV now report the post-test probabilities that correspond to the stated prevalence, both
  branches carry a footnote naming which prevalence was used, and the `epiR` interval pane — whose
  exact binomial values cannot be moved to a different prevalence — gains a note saying it is at
  the observed sample prevalence.
- **The `epiR` "number" table's footnotes described the wrong statistics.** They were attached by
  hard-coded row number while the rows render LR+, LR−, DOR, Youden and NNDx, so LR+ was described
  as the diagnostic odds ratio, LR− as the number needed to diagnose, and DOR as Youden's index.
  Footnotes are now keyed to the `epiR` statistic name carried alongside the data.
- **The Fagan nomogram silently failed to render whenever a 2×2 cell was zero** — precisely the
  sparse tables that most need it. A zero cell makes sensitivity or specificity exactly 1, which
  `nomogrammer` rejects. The likelihood ratios passed to it were already Haldane-Anscombe
  corrected, so the proportions now come from the same corrected table, keeping the plot
  self-consistent instead of clamping to an arbitrary epsilon. `Plr`/`Nlr` are no longer passed:
  `nomogrammer` ignores them when sensitivity and specificity are supplied, and warned on every
  render.
- **With a zero cell, the interval pane disagreed with the estimates beside it.** LR+, LR− and DOR
  in the main tables are computed from Haldane-Anscombe corrected counts (LR+ 145), while
  `epi.tests()` was run on the raw table and returned `Inf` with a `NaN` lower bound — two numbers
  for one statistic on one screen. Those three rows now come from a second `epi.tests()` call on
  the corrected table. Sensitivity, specificity, PPV and NPV deliberately stay on raw counts.
- **The "Getting Started" welcome panel was permanently visible**, sitting above every completed
  analysis, for the same leading-`!` reason described under `decisioncompare`. Rewritten as
  `(length(gold) == 0 || length(newtest) == 0 || length(goldPositive) == 0 ||
  length(testPositive) == 0)`; a bare option name could not be used because a Variable's value is a
  list, which R's `&&` rejects.
- **Rows dropped because their level was neither the positive nor the negative one were reported as
  "cases with missing values removed"** — 40 rows with nothing missing. Rows are dropped twice: once
  by `jmvcore::naOmit()` for genuine missingness, and again when an explicit negative level is set
  and other levels are recoded to `NA`. The summary now counts the two separately, says plainly
  that level-excluded cases are not missing values, and reports "N of M cases analysed".
- **A likelihood ratio of exactly 1.0 was called flawed, and in the wrong direction.** It fell
  through the `lr_pos > 1` band into "Decreases probability of disease (test may be flawed)"; it
  now reads "Uninformative".
- The clinical summary called the user's population prior the *sample* prevalence. The copy-ready
  report quoted PPV and NPV with neither the prevalence they were computed at nor a confidence
  interval, and closed by concluding "the test may be clinically useful" regardless of the results.
  The summary and report now quote predictive values at their prevalence and the report includes
  Clopper-Pearson sensitivity and specificity intervals.
- Verified: all statistics match `epiR::epi.tests` exactly (sensitivity 0.8, specificity 0.9,
  PPV 0.888889, NPV 0.818182, LR+ 8, LR− 0.222222), with the 2×2 not transposed.

### `agreement` (Interrater Reliability)

- **Weighted kappa and Gwet's AC2 laid their weight matrices over an alphabetically sorted category
  order instead of the factor's declared level order**, scrambling any ordinal scale whose labels do
  not happen to sort into clinical order — which is most of them. Low/Moderate/High sorts to
  High/Low/Moderate; Negative/Weak/Strong to Negative/Strong/Weak; Absent/Focal/Diffuse to
  Absent/Diffuse/Focal. On the test set recorded in the code, weighted kappa read 0.751 where the
  correct value is 0.597 — across the Landis & Koch moderate/substantial boundary. Three separate
  places were at fault: `.pairKappaWithCI()` used `sort(unique(c(a, b)))`, `irr::kappa2` was handed
  a data frame (which `irr` coerces with `as.matrix()` to character and then re-derives categories
  alphabetically) and is now fed integer factor codes, and `irrCAC::gwet.ac1.raw` now receives an
  explicit `categ.labels`. Unweighted kappa and Gwet's AC1 are order-invariant and were unaffected;
  only the weighted options bite.
- **Weighted kappa was applied to nominal variables.** Ordinality was inferred from category count
  alone (`length(all_levels) >= 3`), so quadratic weights — which assume a meaningful distance
  between categories — were applied to any nominal variable with three or more levels, such as
  tumour type or mutation class. It now also requires `is.ordered()` on at least one of the two
  rating columns.
- **The headline Cohen's/Fleiss' kappa table reported kappa, z and p but no confidence interval,**
  while four secondary tables (Krippendorff, all-pairs, item-modal, hierarchical) all carried one.
  For two raters the table now shows an interval from the non-null asymptotic standard error via
  `vcd::Kappa`, which matches `psych::cohen.kappa` exactly, with a footnote explaining that z and p
  test H0: kappa = 0 off the *null* SE and so z is not kappa divided by the interval's SE. For
  three or more raters the interval is deliberately left blank with a note, because `irr` supplies
  only the null-SE test for Fleiss'/Conger's kappa.
- **A non-finite kappa crashed the entire analysis, not just the panel that produced it.** The
  "Clinical Meaning" block ran `if (kappa_val >= 0.60)` without the `is.na()` guard the Landis &
  Koch chain above it had, so `if (NA >= 0.60)` threw "missing value where TRUE/FALSE needed".
  Reachable with weighted kappa on nominal data, exact kappa with two raters, a single rating
  category, or Fleiss returning a non-finite value. Separately, `irr::kappam.fleiss` returns `-Inf`
  when three or more raters all use one category — 100% agreement — and that value was written
  straight into the table and graded "poor agreement (worse than chance)", the exact opposite of
  the data. Kappa is now blanked with a note explaining that there is no chance-agreement baseline
  when there is no variation.
- **Subgroup forest-plot intervals used the null-hypothesis standard error and ignored
  `confLevel`.** The subgroup path derived `se <- abs(kappa / z)` from `irr`'s z — the H0 SE, the
  same defect corrected elsewhere in the file — and hard-coded 1.96. Two-rater subgroups now use
  the non-null ASE, falling back to the null SE only when it is unavailable, and the multiplier is
  `qnorm()` at the user's confidence level. The plot subtitle, previously hard-coded to "95%
  confidence intervals", now prints the level actually used.
- **The same kappa was given two different words in one output.** The subgroup table used its own
  unattributed cut-points (0.40/0.60/0.75/0.90 → Poor/Fair/Good/Excellent/Outstanding) while the
  plain-language summary used Landis & Koch 1977 (0.20/0.40/0.60/0.80), so 0.61 read "substantial"
  in the summary and "Good" in the table, and 0.56 read "moderate" there and "Fair" here. One named
  scale (Landis & Koch) is now used throughout.
- **Wald intervals for kappa were not clamped to the parameter space**, and an unclamped interval
  reported an upper limit of 1.18 for a statistic bounded on [−1, 1]. Both branches now clamp,
  matching the sibling inter/intra path that already did.
- **Bootstrap confidence intervals computed the wrong statistics, in four separate ways.** (a) The
  categorical-versus-continuous decision was made per replicate with
  `length(unique(na.omit(x))) <= 20`; a bootstrap resample retains only about 0.63n distinct
  values, so at n ≈ 30–40 some replicates fell under the threshold, were treated as categorical,
  produced no ICC, and silently dropped the ICC row — at exactly the study sizes most common in
  pathology. It is now decided once, on the original data. (b) Each rater column was coded
  independently with `as.numeric(factor(x))`, so the same clinical category received different
  codes in different columns whenever raters used different subsets of the scale, corrupting
  Krippendorff's alpha; a single shared category set is now used. (c) Krippendorff's level of
  measurement was hard-coded to nominal and now follows the data. (d) The bootstrap ICC was
  hard-coded to ICC(2,1) two-way absolute agreement while the row was labelled with whatever
  `iccType` the user had selected; the user's choice is now honoured in both paths.
- **The Bland-Altman plot did not refresh when the proportional-bias option was toggled** —
  `proportionalBias` was missing from `clearWith` although the plot adds a `geom_smooth` line under
  it. Separately, the pairwise-agreement figure silently truncated at `max_pairs`: with five raters,
  4 of 10 pairs were dropped with no note, so the figure read as the complete set. The omission
  count is now stamped on the image itself, so it travels with an exported figure.

### `lassologistic`

- **Coefficients and odds ratios were reported on the standardized scale, not the original
  measurement scale.** The design matrix is standardized in-module and `glmnet` is then called with
  `standardize = FALSE`, so nothing was back-transformed and every coefficient was per 1 SD. For a
  0/1 dummy from a balanced marker (sd ≈ 0.5) the printed per-SD odds ratio is roughly the square
  root of the model's actual present-versus-absent odds ratio: 1.81 printed where the model implies
  3.25. The column standard deviations are now retained and coefficients divided through,
  reproducing exactly what `glmnet(standardize = TRUE)` would return. The Importance column keeps
  the per-SD magnitude, which is the quantity that is comparable across predictors, and the table
  note was rewritten accordingly.
- **The integer scoring system was internally inconsistent, and its rule was never published.**
  Points were derived from the raw per-SD coefficients while scores were awarded on a median split,
  so binary and continuous predictors were weighted on two different contrasts — a 0/1 dummy's
  per-SD coefficient is about half its real effect, while a continuous median split spans roughly
  1.6 SD — mis-ranking them against each other and making the Scoring System table's odds ratio
  disagree with the Selected Variables table for the same predictor (2.11 against 4.46 for p53).
  Points are now derived from the log-odds contribution of meeting each criterion, and the cut is
  resolved once so that the printed rule, the derivation contrast and the applied cut cannot drift
  apart. A new "Award points when" column publishes the criterion on the original measurement
  scale; previously the median cut never reached the output at all, so a clinician had no way to
  apply the score to a new patient.
- **The Brier score was graded against fixed cut-offs and mislabelled as calibration.** It is an
  overall accuracy score whose scale is driven by outcome prevalence: a no-information model that
  always predicts the base rate scores p(1−p), already 0.09 at 10% prevalence, which the old code
  graded "Excellent calibration". It is now graded by the Brier skill score against that null
  model ("Good (x% better than predicting the base rate)" / "Marginal" / "No better than predicting
  the base rate").
- **With zero selected variables, a model that calls everyone positive was presented as perfectly
  sensitive.** Every predicted probability is identical, the ROC is degenerate, and `pROC` returns
  `-Inf`, which was printed as "Optimal threshold: −Inf" beside Sensitivity 1.000 and Specificity
  0.000. Non-finite thresholds now fall back to 0.5.
- **Selecting exactly one predictor produced a completely blank result** — no panel, no notice, no
  error. The welcome/To Do panel shows only when `explanatory` is empty, and the analysis returned
  early with one predictor, so both guards stayed silent. A warning now explains that LASSO
  performs variable selection and needs candidates to choose among.
- **Listwise deletion was invisible.** "Total observations" in the model summary actually held the
  complete-case count, so it read as the full cohort while rows had silently been removed, and the
  suitability assessment then green-lit the reduced N. The summary now reports "Complete cases
  analysed" and "Excluded (incomplete data)" separately, and a warning fires whenever any case is
  excluded, pointing out that a single sparsely-measured predictor can remove a large share of the
  cohort.
- **The bootstrap optimism correction did not disclose how many replicates it rested on.** Failed
  replicates are caught by `tryCatch`, left as `NA` and dropped by `na.rm = TRUE`, so a correction
  computed from 50 survivors of 200 looked identical to one computed from all 200. The table now
  footnotes the completed and failed counts, and warns separately when fewer than 20 replicates
  succeeded.

## Changed

- **`lassologistic` score performance figures are now labelled as apparent.** "Score AUC" became
  "Score AUC (apparent)" and "Optimal score cutoff" became "Optimal score cutoff (chosen on this
  data)", with a note that these figures are optimistic twice over — the points were derived from a
  model fitted to these data, and the cutoff was Youden-optimised on the same rows. The model's own
  table already carried an optimism caveat; the score's did not.

## Added

- **`lassologistic` gained a configurable cut point for continuous predictors in the scoring
  system.** `scoreCutMethod` offers median, mean, upper tertile, upper quartile and manual
  (default median, i.e. the previous behaviour), and `scoreCutPoints` is a free-text field taking
  `variable=value` pairs on the original measurement scale (for example `ki67=20, age=65`), so an
  established clinical threshold can be used instead of a data-derived split. Unparseable entries
  are dropped rather than guessed; any continuous predictor without a manual cut falls back to the
  sample median, and that fallback is named in a table note. The Scoring System note states that a
  dataset-derived cut is not an externally established threshold and will differ in another cohort.

## Removed

- **Pruned NAMESPACE exports for analyses that this module does not ship,** together with unused
  `importFrom` declarations. Seven exports were removed (`clinicalscore`, `decisioncurve`,
  `latentbiomarker`, `leaveonecenterout`, `mageeequation`, `misclassificationbias`,
  `timedependentdca`) along with about 25 unused imports (`dplyr::arrange`/`filter`/`summarise`,
  several `ggplot2` and `graphics` functions, `stats::complete.cases`, and others). No shipped
  analysis was affected. `.Rbuildignore` gained `temp` and `backups` patterns.

# meddecide 1.0.3 (2026-08-04)

No user-visible changes. Version alignment across the ClinicoPath submodules: the package version
and every analysis version string were bumped, and no R code, option definition or results
definition was touched.

# meddecide 1.0.2 (2026-08-03)

## Fixed

- **Three analyses named the wrong confidence-interval method.** `epiR::epi.tests()` — the source
  of the sensitivity, specificity and predictive-value intervals in `decision`,
  `decisioncalculator` and `decisioncompare` — defaults to `method = "exact"`, which is the
  Clopper-Pearson interval, not Wilson. On a 2×2 of 67/56/38/79 the two differ in the third
  decimal (sensitivity 0.5385–0.7296 exact against 0.5428–0.7236 Wilson). The footnotes in
  `decision` and `decisioncompare` said "Wilson score method" and now name Clopper-Pearson. **No
  interval changed** — only the label was wrong. `decisioncombine` was checked and left alone: its
  own `.calcWilsonCI()` genuinely is Wilson and genuinely populates the CI table it describes, so
  its labelling was already correct.
- **`decisioncompare` advertised likelihood-ratio confidence intervals it never computes.** The
  per-test table is filtered to a row set that excludes `lr.pos`/`lr.neg`, and the LRP/LRN columns
  carry no lower/upper bounds — so no likelihood-ratio interval is rendered anywhere in that
  analysis. The Assumptions panel now states that likelihood ratios are point estimates only, and
  describes the intervals that *are* shown: Clopper-Pearson for the proportions, the user's chosen
  method (Wilson by default) for Overall Percent Agreement, and Wald for paired differences.
- **`decisioncalculator` overstated the reach of its continuity correction.** The notice said the
  Haldane-Anscombe 0.5 correction was applied to "likelihood ratios, diagnostic odds ratio, and
  confidence intervals". It is applied to the point estimates only — `epi.tests()` is fed the raw
  table — so the intervals are uncorrected and may be undefined for those statistics when a cell
  is zero. The notice now says which is which.

- **`decision` crashed whenever "Disease Absent Level" or "Test Negative Level" was left unset.**
  `dplyr::case_when()` evaluates every branch regardless of which one matches, so the unreachable
  `test == <negative level>` comparison still ran with the level `NULL`, produced a zero-length
  condition, and aborted the analysis with `Can't recycle ... size 0`. Both levels now use
  `NA_character_` as the "unset" sentinel, which compares to a full-length, never-matching
  condition. Behaviour with the levels *set* is unchanged: an explicitly chosen negative level
  still restricts the analysis to those two levels and drops rows with any other level.
- **Test and gold-standard variables were required arguments of the R function.** An option with
  no default in its jamovi definition compiles to a bare parameter, so calling the analysis from
  R without it failed with `argument "X" is missing, with no default` before the analysis's own
  validation could produce a usable message. Now defaulting to `NULL`: `agreement` (`vars`),
  `decision` (`gold`, `newtest`), `decisioncombine` (`gold`, `test1`), `decisioncompare`
  (`gold`, `test1`, `test2`) and `nogoldstandard` (`test2`). Behaviour in the jamovi GUI is
  unchanged; no statistical method was altered.

## Added

- **Automated GitHub release (`.github/workflows/release.yaml`).** A push to the default branch
  touching `DESCRIPTION` or `jamovi/0000.yaml` cross-checks the two version strings, refuses to
  proceed if they disagree, and — if the tag does not already exist — tags `v<version>` and
  publishes a release whose notes are the matching section of this file.

# meddecide 0.0.47 (2026-07-05)

## Bug Fixes

* **Restored correct inter-rater agreement statistics on jamovi installs.** `vcd` and `lme4` are used by `agreement()` but were missing from the package `Imports`. Because jamovi installs only a package's `Imports`, on a clean install they were unavailable: pairwise kappa confidence intervals silently fell back to the narrower `irr::kappa2` null-SE method, and the entire ICC / Lin's CCC / continuous-agreement suite (which relies on `lme4`) was non-functional. Both are now declared, so agreement CIs use the intended `vcd::Kappa` asymptotic-SE method and the continuous-agreement measures work.
* Clarified the all-pairs kappa fallback note so it distinguishes a missing `vcd` package (with install guidance) from a genuinely near-degenerate table.
* Declared `DescTools` and `lmerTest`, previously used via `::` but undeclared.

# meddecide 0.0.46 (2026-07-04)

This release consolidates every change since 0.0.32.69 (unreleased versions 0.0.33 through 0.0.46 roll into this entry). The headline is a large expansion of **`agreement()`** into a comprehensive interrater/intrarater reliability suite (20+ new agreement statistics, tests, and visualizations), robustness and input-validation hardening of the ROC modules, one-sided confidence-interval support in the kappa sample-size tools, and package infrastructure updates (minimum jamovi app raised to 2.7.27, new imports, dataset cleanup).

## Major Changes

### `agreement()` — Comprehensive Reliability Suite Expansion

The agreement module was expanded from Cohen's/Fleiss' Kappa into a full interrater/intrarater reliability toolkit. Each new statistic ships with its own results table, an "About …" HTML explanation, and a "When to use …" guide notice.

* **New chance-corrected / categorical measures:**
  - Gwet's AC1/AC2 (`gwet`, with `gwetWeights`: unweighted/linear/quadratic) → `gwetTable`
  - PABAK with prevalence and bias indices (`pabak`) → `pabakTable`
  - Light's Kappa for 3+ raters (`lightKappa`) → `lightKappaTable`
  - Krippendorff's Alpha guidance (`showKrippGuide`)

* **New continuous-data agreement measures:**
  - ICC with six models ICC(1,1)–ICC(3,k) (`icc`, `iccType`) → `iccTable`
  - Mean Pearson correlation (`meanPearson`) → `meanPearsonTable`
  - Lin's Concordance Correlation Coefficient (`linCCC`) → `linCCCTable`
  - Total Deviation Index (`tdi`, `tdiCoverage`, `tdiLimit`) → `tdiTable`
  - Finn coefficient with one-way/two-way models (`finn`, `finnLevels`, `finnModel`) → `finnTable`
  - Iota multivariate coefficient (`iota`, `iotaStandardize`) → `iotaTable`

* **New ordinal / rank-based agreement measures:**
  - Kendall's W coefficient of concordance (`kendallW`) → `kendallWTable`
  - Robinson's A ordinal agreement index (`robinsonA`) → `robinsonATable`
  - Mean Spearman rho (`meanSpearman`) → `meanSpearmanTable`

* **New marginal-homogeneity / rater-bias tests:**
  - Rater Bias test (`raterBias`) → `raterBiasTable`
  - Bhapkar test (`bhapkar`) → `bhapkarTable`
  - Stuart-Maxwell test (`stuartMaxwell`) → `stuartMaxwellTable`
  - Maxwell's RE random-error index (`maxwellRE`) → `maxwellRETable`

* **New multi-rater / structural analyses:**
  - Pairwise Kappa against a reference rater with performance ranking (`pairwiseKappa`, `referenceRater`, `rankRaters`) → `pairwiseKappaTable`
  - Hierarchical/multilevel Kappa (`hierarchicalKappa`, `clusterVariable`) with cluster-specific estimates, variance-component decomposition, hierarchical ICC, cluster-homogeneity test, and shrinkage (empirical Bayes) estimates → `hierarchicalOverallTable`, `clusterSpecificTable`, `varianceDecompositionTable`, `hierarchicalICCTable`, `homogeneityTestTable`
  - Mixed-effects condition comparison with Bonferroni/BH/Holm correction (`mixedEffectsComparison`, `conditionVariable`, `multipleTestCorrection`) → `mixedEffectsTable`, `mixedEffectsVarianceTable`
  - Inter/intra-rater test-retest reliability (`interIntraRater`, `interIntraSeparator`) → `interIntraRaterIntraTable`, `interIntraRaterInterTable`

* **New machine-learning-style metrics:**
  - Confusion matrix table with row/column normalization (`confusionMatrix`, `confusionNormalize`) → `confusionMatrixTable`, `perClassMetricsTable`
  - Multi-annotator concordance / F1 (`multiAnnotatorConcordance`, `predictionColumn`) → `concordanceF1Table`, `concordanceF1PerClassTable`
  - Specific (category-focused) agreement indices with optional CIs (`specificAgreement`, `specificPositiveCategory`, `specificAllCategories`, `specificConfidenceIntervals`) → `specificAgreementTable`
  - Bootstrap confidence intervals (`bootstrapCI`, `nBoot`) → `bootstrapCITable`

* **New visualizations:**
  - Agreement heatmap / confusion-matrix plot (`agreementHeatmap`) with color schemes (blue-red, traffic-light, viridis, grayscale) and count/percentage cell annotations (`heatmapColorScheme`, `heatmapShowCounts`, `heatmapShowPercentages`, `heatmapAnnotationSize`) → `agreementHeatmapPlot`
  - Bland-Altman method-comparison output with a Shapiro-Wilk normality check (`showBlandAltmanGuide`) → `blandAltmanHeading`, `blandAltmanExplanation`
  - Rater profile plots — box/violin/bar (`raterProfiles`, `raterProfileType`, `raterProfileShowPoints`) → `raterProfilePlot`
  - Rater clustering and case clustering with dendrograms and heatmaps — hierarchical/k-means, correlation/euclidean/manhattan/agreement distances, average/complete/single/ward linkage (`raterClustering`, `caseClustering`) → `raterClusterTable`, `raterDendrogram`, `raterClusterHeatmap`, `caseClusterTable`, `caseDendrogram`, `caseClusterHeatmap`
  - Stratified agreement-by-subgroup with forest plot (`agreementBySubgroup`, `subgroupVariable`, `subgroupForestPlot`, `subgroupMinCases`) → `subgroupAgreementTable`, `subgroupForestPlotImage`

* **New workflow tools:**
  - Paired agreement comparison between two rater conditions with bootstrap (`pairedAgreementTest`, `conditionBVars`, `pairedBootN`) → `pairedAgreementTable`
  - Sample-size calculator for agreement studies supporting Cohen's Kappa / Fleiss' Kappa / ICC (`agreementSampleSize`, `ssMetric`, `ssKappaNull`, `ssKappaAlt`, `ssNRaters`, `ssNCategories`, `ssAlpha`, `ssPower`) → `agreementSampleSizeTable`

* **New computed output variables:**
  - Consensus rating variable with majority/supermajority/unanimous rules and tie handling (`consensusVar`, `consensusName`, `consensusRule`, `tieBreaker`) → `consensusTable`, `consensusVar`
  - Case-level Level-of-Agreement categorization — simple/detailed with custom/quartile/tertile thresholds (`loaVariable`, `detailLevel`, `simpleThreshold`, `loaThresholds`, `loaHighThreshold`, `loaLowThreshold`, `loaVariableName`, `showLoaTable`) → `loaTable`, `loaDetailTable`, `loaOutput`

* **Other agreement additions:**
  - Configurable confidence level for CIs (`confLevel`)
  - Level-ordering information panel (`showLevelInfo`) → `levelInfoTable`
  - Plain-language Summary, About, and Clinical Use Cases panels (`showSummary`, `showAbout`) → `summary`, `about`, `clinicalUseCases`
  - New client-side events handler `jamovi/js/agreement.events.js` (bounds/dependency handling for `confLevel`, Bland-Altman confidence level, cluster counts, and subgroup minimums)

## Enhanced Existing Functions

* **`enhancedROC()`**: Robustness and UX overhaul
  - Rewritten input validation: guards for single-value outcomes, outcome-level checks, and positive-class validation
  - HTML-escaped error/warning messages (`private$.safeHtmlOutput`) and a notices framework (`.addNotice`/`.renderNotices`) plus a methods-explanation panel and instructions
  - Sensible defaults now ON: `youdenOptimization`, `rocCurve`, `aucTable`, `optimalCutoffs`, `diagnosticMetrics`; `customCutoffs` now defaults to empty
  - Added `clearWith` to results so outputs invalidate correctly; removed dead commented-out time-dependent AUC/ROC stubs

* **`psychopdaroc()`**: Input hardening and cleanup
  - Bootstrap/threshold count options changed from Number to Integer (`boot_runs`, `maxThresholds`, `bootstrapReps`, `idiNriBootRuns`)
  - Removed dead commented-out option stubs (`effectSizeMethod`, `advancedMetrics`); added `clearWith` to results

* **`kappasizeci()`**: One-sided confidence intervals
  - New `citype` option (two-sided vs one-sided lower-bound-only), wired to `kappaSize::CIBinary`/`CI3Cats`/`CI4Cats`/`CI5Cats`, with a UI ComboBox that disables the upper-limit input in one-sided mode
  - New plain-language `text_summary` output (CI type, lower limit, precision width)

* **`kappasizefixedn()` / `kappasizepower()`**: New plain-language `text_summary` output panel

* **`nogoldstandard()`**: New `notices` panel ("Important Information") with plain-text notice rendering that resets on each run

* **`decisioncalculator()`**: Sensitivity/specificity confidence intervals now use a logit transformation with continuity correction (`sens_se = sqrt(1/TP + 1/FN)`, `spec_se = sqrt(1/TN + 1/FP)`) when a zero cell is present — consistent with the existing PPV/NPV CI logic — falling back to exact Clopper-Pearson binomial CIs otherwise

## Package Infrastructure

* Version bumped 0.0.32.69 → 0.0.46; release date 2026-07-04; minimum jamovi app raised to 2.7.27 (`minApp`)
* New Imports: `ggraph`, `grDevices`, `graphics`, `htmltools`, `igraph`, `irrCAC`, `knitr`, `stats`, `tibble`, `tools` (`irrCAC`/`stats`/`psych` back the new chance-corrected, clustering, and ICC agreement measures; `ggraph`/`igraph` back the reimplemented `decisiongraph` tree visualization; `htmltools`/`knitr`/`tibble`/`tools`/`grDevices`/`graphics` support HTML output and plotting)
* Switched documentation config to `Config/roxygen2/version: 8.0.0`
* New shared helper files: `R/diagnostichelpers.R` (reusable sensitivity/specificity/PPV/NPV helpers) and `R/error_handling.R` (clinical error-handling framework: `clinicopath_init`, `clinicopath_error_handler`)
* Added `.escapeVariableNames` and refactored/hardened existing `R/utils.R` helpers (`%notin%`/`%!in%` rewritten as explicit functions, `load_required_package` default flipped to `install_if_missing = FALSE`, `print.sensSpecTable` given an S3-compliant `(x, ...)` signature)
* `R/decisiongraph_utils.R`: decision-tree visualization reimplemented as a real `igraph`/`ggraph` dendrogram renderer (`graph_from_data_frame`, `ggraph::geom_edge_diagonal`/`geom_node_point`/`geom_node_label`, horizontal/vertical/radial layouts) replacing the "Not Yet Implemented" placeholder, plus removal of the hardcoded 0.7/0.2/0.1 Markov transition-matrix stub (`decisiongraph` is a shipped utility, not a registered menu analysis)

## Data

* Removed five raw CSV files from `data/` (`cancer_biomarker_data.csv`, `cardiac_troponin_data.csv`, `dca_test_data.csv`, `sepsis_biomarker_data.csv`, `thyroid_function_data.csv`)
* Added roxygen dataset documentation in `R/data.R` for the packaged datasets (histopathology, Bayesian DCA, breast cancer, breast/lymphoma diagnostic-styles, thyroid function, and the cancer/cardiac/sepsis/thyroid diagnostic sets plus the combined master collection)

## Minor Changes

* Module-wide label cleanup: replaced "%" with "percent" and removed emojis across `decision()`, `decisioncalculator()`, `decisioncompare()`, `decisioncombine()`, `cotest()`, and `sequentialtests()` labels and descriptions (for `decisioncalculator()` this covers the label/emoji changes only; the CI methodology change is documented under Enhanced Existing Functions above). `decisioncombine()` also gained `allowNone: true` on its Test 3 positive-level option and had its example `dontrun` flag flipped to `true`
* Version strings synchronized to 0.0.46 across DESCRIPTION and all jamovi analysis definitions

---

# meddecide 0.0.32.69 (2026-01-02)

## New Features

* **`bootstrapNRI()`**: Exported bootstrapNRI function for Net Reclassification Improvement (NRI) bootstrap confidence interval estimation
  - Enables direct access to NRI bootstrap analysis
  - Provides robust confidence intervals for categorical and continuous NRI
  - Supports custom thresholds for risk category definitions
  - Configurable bootstrap iterations and confidence levels

## Bug Fixes

* Fixed critical bug in `computeNRI()` where risk category labels were incorrectly calculated
  - Corrected the labels vector calculation from `1:length(breaks - 1)` to `1:(length(breaks) - 1)`
  - This fix ensures proper risk categorization in NRI calculations
  - Affects categorical NRI computations in ROC and psychoPDA analyses
  
* **`agreement()`**: Fixed stability issues and hanging during initial run
  - Refactored `agreement.b.R` to ensure responsiveness
  - Maintained support for numeric variables in agreement analysis

## Minor Changes

* Updated package version to 0.0.32.69
* Synchronized version across DESCRIPTION and jamovi module files (jamovi/0000.yaml)

---

# meddecide 0.0.31.84 (2025-10-03)

## Major Changes

### New Analysis Functions

* **`decisioncombine()`**: New function for systematic evaluation of diagnostic test combinations
  - Analyzes all possible test result patterns (2-test: 4 patterns, 3-test: 8 patterns)
  - Calculates sensitivity, specificity, PPV, NPV, and accuracy for each pattern combination
  - Identifies optimal testing strategies based on Youden's J index
  - Includes visualization options: bar charts, heatmaps, forest plots, and decision trees
  - Supports filtering by statistic type and pattern type
  - Can add test pattern column to dataset for further analysis

* **`cotest()`**: New function for analyzing combined results of two concurrent diagnostic tests
  - Calculates post-test probabilities for various scenarios (either positive, both positive, both negative)
  - Supports both parallel and serial testing strategies
  - Provides Fagan nomogram visualizations

* **`sequentialtests()`**: New function for sequential testing analysis
  - Analyzes how diagnostic accuracy changes when applying two tests in sequence
  - Compares three different testing strategies: serial positive (confirmation), serial negative (exclusion), and parallel testing
  - Provides comprehensive analysis including population flow, cost implications, and Fagan nomograms

* **`decisioncalculator()`**: New calculator for diagnostic test evaluation
  - Designed for when you have the four key counts: TP, FP, TN, FN
  - Calculates comprehensive diagnostic performance metrics
  - Supports confidence interval estimation and Fagan nomogram visualization

### Enhanced Existing Functions

* **`decisioncompare()`**: Major improvements to test comparison functionality
  - Enhanced comparison plots (bar charts and radar plots)
  - Added statistical comparison using McNemar's test
  - New summary and explanation options for better interpretation
  - Added manuscript-ready report sentence generation
  - Improved handling of custom prevalence settings
  - Better visualization of confidence intervals for metric differences

### Removed Features

* **`decisionpanel()`**: Function removed for future redesign
  - Users should use `decisioncombine()` and `decisioncompare()` instead
  - These new functions provide more focused and comprehensive analysis

## Menu Organization

* Reorganized jamovi menu structure for better user experience
  - **Decision**: Core diagnostic test evaluation functions
  - **Decision Calculators**: Calculator-based tools for specific scenarios
  - **ROC**: ROC curve analysis functions
  - **Agreement**: Interrater reliability functions
  - **Power Analysis**: Sample size calculation functions

## Minor Changes

* Updated `agreement()` function with improvements to reliability assessment
* Enhanced documentation across all functions
* Improved error handling and validation
* Updated example datasets and usage examples

## Bug Fixes

* Fixed various edge cases in diagnostic metric calculations
* Improved handling of missing data
* Enhanced validation of input parameters

---

# meddecide 0.0.31 (2025-09-18)

## Package Updates

* Version synchronization across DESCRIPTION and jamovi module
* Updated package metadata and author information
* Enhanced package description with comprehensive feature list

## Documentation

* Improved function documentation with clearer examples
* Updated pkgdown website structure
* Added more detailed usage examples for main functions

---

# meddecide 0.0.3.91

## New Features

* Initial implementation of test comparison framework
* Added support for Fleiss' Kappa with differentiated method names
* Enhanced Kappa calculation methods

## Bug Fixes

* Fixed issues with exact Kappa calculations
* Improved handling of multiple rater scenarios

---

# meddecide 0.0.3.90

## Initial Release Features

* Basic diagnostic test evaluation functions
* ROC analysis capabilities
* Interrater reliability assessment (Cohen's Kappa, Fleiss' Kappa)
* Sample size calculations for reliability studies
* Visualization tools including Fagan nomograms
* jamovi module integration
