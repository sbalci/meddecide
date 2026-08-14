# Changelog

## meddecide 1.0.4 (2026-08-07)

This release is the result of end-to-end release reviews of fourteen
analyses: `decisioncompare`, `decision`, `agreement`, `lassologistic`,
`decisioncombine`, `decisioncalculator`, `nogoldstandard`, `cotest`,
`sequentialtests`, `enhancedROC`, `psychopdaROC`, and all three
kappaSize sample-size analyses — `kappaSizePower`, `kappaSizeCI` and
`kappaSizeFixedN`, each reviewed in its own right and then cross-checked
against the other two. Each was traced from its user interface through
to its printed output, every statistic was checked against an
independent R package (`epiR`, `DescTools`, `psych`, `binom`, `poLCA`,
`pROC`, `cutpointr`, `kappaSize`, `stats`), and the confirmed defects
were fixed. Most of what follows is a correction to a number a clinician
could already have copied into a report.

### Breaking changes

- **[`decisioncompare()`](https://www.serdarbalci.com/meddecide/reference/decisioncompare.md)
  has four new required arguments: `goldNegative`, `test1Negative`,
  `test2Negative` and `test3Negative`.** They name the level of each
  variable that represents a genuine negative result, so that a third,
  equivocal level can be told apart from a negative one. jamovi does not
  permit a default on a `Level` option, so all four compile to bare
  parameters of the R wrapper: **existing scripts that call
  [`decisioncompare()`](https://www.serdarbalci.com/meddecide/reference/decisioncompare.md)
  will fail with `argument "goldNegative" is missing, with no default`
  until they are updated**, passing `NULL` for any test that is not in
  use. Nothing changes for users driving the analysis from the jamovi
  GUI. The reason for the change is the `excludeIndeterminate` defect
  described below — without a declared negative level the analysis has
  no way to know which rows are equivocal.
- **[`decisioncombine()`](https://www.serdarbalci.com/meddecide/reference/decisioncombine.md)’s
  `filterPattern` lost the levels `serial`, `parallel` and `majority`.**
  That option selects rows of the *observed pattern* table, but those
  three names describe decision *rules*, which is what the strategy
  table reports — “serial” as a filter selected the `+/+/+` pattern
  while the Serial (AND) rule is a different row of a different table.
  The remaining levels are `all`, `allPositive`, `allNegative` and
  `mixed`. **A script passing one of the removed values now fails** with
  `Argument 'filterPattern' must be one of ...`; use `allPositive` for
  the old `serial` and `all` for the old `parallel`. The jamovi GUI
  shows only the current levels.
- **[`nogoldstandard()`](https://www.serdarbalci.com/meddecide/reference/nogoldstandard.md)’s
  default `method` changed from `all_positive` to `latent_class`.** The
  old default defines the reference standard as “every test positive”,
  which fixes sensitivity and NPV at 1 for every test on every dataset —
  it cannot estimate accuracy, which is the entire point of the
  analysis. `latent_class` is the only method here that estimates
  sensitivity and specificity without building the reference standard
  out of the tests themselves. **A new analysis will therefore produce
  different numbers than it did in 1.0.3**, and because `latent_class`
  needs three or more tests, a two-test analysis that previously
  returned (meaningless) results now refuses and explains why. Saved
  `.omv` files keep the method they were saved with; pass
  `method = "all_positive"` explicitly to restore the old behaviour.

### Fixed

#### `decisioncompare` (Compare Medical Decision Tests)

- **Every results table grew on each re-run.** The six calls meant to
  clear old rows used `clearRows()`, which is not a `jmvcore` Table
  method — only `deleteRows()` exists — and each call was wrapped in
  `try(silent = TRUE)`, so the error was swallowed and nothing was ever
  cleared. In jamovi, toggling *any* option re-runs the analysis on the
  same object, so the comparison table went 4 → 8 → 12 rows across three
  runs and each test appeared twice, then three times, then four. Anyone
  who changed a checkbox mid-session was reading a duplicated table.
- **`excludeIndeterminate` was a complete no-op.** It filtered on
  `c(positiveLevel, setdiff(levels, positiveLevel))` — that is, on every
  level — so equivocal results were still collapsed into Negative and
  still inflated specificity and NPV, the exact harm the checkbox
  promises to prevent. On a 60-case fixture with 20 Equivocal results,
  specificity read 0.950 with the option both off and on; excluding the
  equivocal cases gives 0.900. With the new negative-level options
  supplied, equivocal rows are now genuinely dropped; when they are not
  supplied the analysis says so explicitly rather than pretending to
  have acted.
- **The manuscript-ready report named a winner the data could not
  support.** On a fixture where Cochran’s Q gives p = 0.076 and no
  pairwise comparison survives Holm correction, the report read “t1
  demonstrated OPTIMAL diagnostic performance” one sentence before “did
  not reveal a statistically significant difference”. It now says “had
  the highest observed accuracy” with an explicit caveat, and the
  clinical recommendation panel carries a matching caution block.
- **Four result panels were permanently visible.** The `visible:`
  expressions began with `!` (`(!is.null(test3) && test3 != "")`), and
  `jmvcore` routes an expression to the R evaluator only when it matches
  `^\([\$A-Za-z].*\)$`; a leading `!` fails that test, so the raw — and
  therefore truthy — string was returned instead of being evaluated. An
  empty “Test 3 — Recoded Data” table sat under every two-test analysis,
  and the stratified table showed with no stratifier selected.
- **The manuscript text printed a literal placeholder,**
  `95% CI: [see confidence interval table]`. It now prints real
  Clopper-Pearson intervals.
- **A tie for best-performing test was broken by whichever test came
  first, silently.** Ties are now disclosed.
- **The difference table’s “95% Confidence Interval” header did not say
  which method produced it.** It is now footnoted as the paired Wald
  interval for correlated proportions, and distinguished from the
  separate “CI Method for Agreement” option that governs the Overall
  Percent Agreement table.
- The three tests in `test-decisioncompare-critical-fixes.R` never
  called the module at all — they re-implemented the logic inline and
  asserted on their own arithmetic. They now exercise the real analysis.
- Verified unchanged and correct: all per-test metrics against
  [`epiR::epi.tests`](https://rdrr.io/pkg/epiR/man/epi.tests.html) (to
  1e-8); Cochran’s Q = 5.150442, p = 0.076137 against
  [`DescTools::CochranQTest`](https://andrisignorell.github.io/DescTools/reference/CochranQTest.html)
  (six decimal places); McNemar with Holm correction against
  [`stats::mcnemar.test`](https://rdrr.io/r/stats/mcnemar.test.html) +
  `p.adjust` (1e-10); Wilson intervals against
  [`binom::binom.confint`](https://rdrr.io/pkg/binom/man/binom.confint.html);
  exact intervals against Clopper-Pearson; the paired Wald standard
  error by hand. McNemar correctly compares diagnostic *correctness*
  against the gold standard rather than raw positivity — proven with a
  fixture on which the wrong design gives p = 1.000 and the right one p
  = 0.0015.

#### `decision` (Medical Decision)

- **With a user-supplied population prevalence, the results row was
  arithmetically impossible.** The Prevalence cell was overwritten with
  the user’s prior while PPV and NPV stayed at the raw 2×2 values
  computed at the study prevalence, so a row could read “Prevalence 5.0%
  … PPV 88.9%” — for a test with sensitivity 0.80 and specificity 0.90,
  Bayes gives 29.6%. A pathologist reading PPV off a
  screening-prevalence run would have overstated positive predictive
  value roughly threefold, and the footnote made it worse by asserting
  the predictive values had already been prior-adjusted. PPV and NPV now
  report the post-test probabilities that correspond to the stated
  prevalence, both branches carry a footnote naming which prevalence was
  used, and the `epiR` interval pane — whose exact binomial values
  cannot be moved to a different prevalence — gains a note saying it is
  at the observed sample prevalence.
- **The `epiR` “number” table’s footnotes described the wrong
  statistics.** They were attached by hard-coded row number while the
  rows render LR+, LR−, DOR, Youden and NNDx, so LR+ was described as
  the diagnostic odds ratio, LR− as the number needed to diagnose, and
  DOR as Youden’s index. Footnotes are now keyed to the `epiR` statistic
  name carried alongside the data.
- **The Fagan nomogram silently failed to render whenever a 2×2 cell was
  zero** — precisely the sparse tables that most need it. A zero cell
  makes sensitivity or specificity exactly 1, which `nomogrammer`
  rejects. The likelihood ratios passed to it were already
  Haldane-Anscombe corrected, so the proportions now come from the same
  corrected table, keeping the plot self-consistent instead of clamping
  to an arbitrary epsilon. `Plr`/`Nlr` are no longer passed:
  `nomogrammer` ignores them when sensitivity and specificity are
  supplied, and warned on every render.
- **With a zero cell, the interval pane disagreed with the estimates
  beside it.** LR+, LR− and DOR in the main tables are computed from
  Haldane-Anscombe corrected counts (LR+ 145), while `epi.tests()` was
  run on the raw table and returned `Inf` with a `NaN` lower bound — two
  numbers for one statistic on one screen. Those three rows now come
  from a second `epi.tests()` call on the corrected table. Sensitivity,
  specificity, PPV and NPV deliberately stay on raw counts.
- **The “Getting Started” welcome panel was permanently visible**,
  sitting above every completed analysis, for the same leading-`!`
  reason described under `decisioncompare`. Rewritten as
  `(length(gold) == 0 || length(newtest) == 0 || length(goldPositive) == 0 || length(testPositive) == 0)`;
  a bare option name could not be used because a Variable’s value is a
  list, which R’s `&&` rejects.
- **Rows dropped because their level was neither the positive nor the
  negative one were reported as “cases with missing values removed”** —
  40 rows with nothing missing. Rows are dropped twice: once by
  [`jmvcore::naOmit()`](https://rdrr.io/pkg/jmvcore/man/naOmit.html) for
  genuine missingness, and again when an explicit negative level is set
  and other levels are recoded to `NA`. The summary now counts the two
  separately, says plainly that level-excluded cases are not missing
  values, and reports “N of M cases analysed”.
- **A likelihood ratio of exactly 1.0 was called flawed, and in the
  wrong direction.** It fell through the `lr_pos > 1` band into
  “Decreases probability of disease (test may be flawed)”; it now reads
  “Uninformative”.
- The clinical summary called the user’s population prior the *sample*
  prevalence. The copy-ready report quoted PPV and NPV with neither the
  prevalence they were computed at nor a confidence interval, and closed
  by concluding “the test may be clinically useful” regardless of the
  results. The summary and report now quote predictive values at their
  prevalence and the report includes Clopper-Pearson sensitivity and
  specificity intervals.
- Verified: all statistics match
  [`epiR::epi.tests`](https://rdrr.io/pkg/epiR/man/epi.tests.html)
  exactly (sensitivity 0.8, specificity 0.9, PPV 0.888889, NPV 0.818182,
  LR+ 8, LR− 0.222222), with the 2×2 not transposed.

#### `agreement` (Interrater Reliability)

- **Weighted kappa and Gwet’s AC2 laid their weight matrices over an
  alphabetically sorted category order instead of the factor’s declared
  level order**, scrambling any ordinal scale whose labels do not happen
  to sort into clinical order — which is most of them. Low/Moderate/High
  sorts to High/Low/Moderate; Negative/Weak/Strong to
  Negative/Strong/Weak; Absent/Focal/Diffuse to Absent/Diffuse/Focal. On
  the test set recorded in the code, weighted kappa read 0.751 where the
  correct value is 0.597 — across the Landis & Koch moderate/substantial
  boundary. Three separate places were at fault: `.pairKappaWithCI()`
  used `sort(unique(c(a, b)))`,
  [`irr::kappa2`](https://rdrr.io/pkg/irr/man/kappa2.html) was handed a
  data frame (which `irr` coerces with
  [`as.matrix()`](https://rdrr.io/r/base/matrix.html) to character and
  then re-derives categories alphabetically) and is now fed integer
  factor codes, and
  [`irrCAC::gwet.ac1.raw`](https://rdrr.io/pkg/irrCAC/man/gwet.ac1.raw.html)
  now receives an explicit `categ.labels`. Unweighted kappa and Gwet’s
  AC1 are order-invariant and were unaffected; only the weighted options
  bite.
- **Weighted kappa was applied to nominal variables.** Ordinality was
  inferred from category count alone (`length(all_levels) >= 3`), so
  quadratic weights — which assume a meaningful distance between
  categories — were applied to any nominal variable with three or more
  levels, such as tumour type or mutation class. It now also requires
  [`is.ordered()`](https://rdrr.io/r/base/factor.html) on at least one
  of the two rating columns.
- **The headline Cohen’s/Fleiss’ kappa table reported kappa, z and p but
  no confidence interval,** while four secondary tables (Krippendorff,
  all-pairs, item-modal, hierarchical) all carried one. For two raters
  the table now shows an interval from the non-null asymptotic standard
  error via [`vcd::Kappa`](https://rdrr.io/pkg/vcd/man/Kappa.html),
  which matches
  [`psych::cohen.kappa`](https://rdrr.io/pkg/psych/man/kappa.html)
  exactly, with a footnote explaining that z and p test H0: kappa = 0
  off the *null* SE and so z is not kappa divided by the interval’s SE.
  For three or more raters the interval is deliberately left blank with
  a note, because `irr` supplies only the null-SE test for
  Fleiss’/Conger’s kappa.
- **A non-finite kappa crashed the entire analysis, not just the panel
  that produced it.** The “Clinical Meaning” block ran
  `if (kappa_val >= 0.60)` without the
  [`is.na()`](https://rdrr.io/r/base/NA.html) guard the Landis & Koch
  chain above it had, so `if (NA >= 0.60)` threw “missing value where
  TRUE/FALSE needed”. Reachable with weighted kappa on nominal data,
  exact kappa with two raters, a single rating category, or Fleiss
  returning a non-finite value. Separately,
  [`irr::kappam.fleiss`](https://rdrr.io/pkg/irr/man/kappam.fleiss.html)
  returns `-Inf` when three or more raters all use one category — 100%
  agreement — and that value was written straight into the table and
  graded “poor agreement (worse than chance)”, the exact opposite of the
  data. Kappa is now blanked with a note explaining that there is no
  chance-agreement baseline when there is no variation.
- **Subgroup forest-plot intervals used the null-hypothesis standard
  error and ignored `confLevel`.** The subgroup path derived
  `se <- abs(kappa / z)` from `irr`’s z — the H0 SE, the same defect
  corrected elsewhere in the file — and hard-coded 1.96. Two-rater
  subgroups now use the non-null ASE, falling back to the null SE only
  when it is unavailable, and the multiplier is
  [`qnorm()`](https://rdrr.io/r/stats/Normal.html) at the user’s
  confidence level. The plot subtitle, previously hard-coded to “95%
  confidence intervals”, now prints the level actually used.
- **The same kappa was given two different words in one output.** The
  subgroup table used its own unattributed cut-points
  (0.40/0.60/0.75/0.90 → Poor/Fair/Good/Excellent/Outstanding) while the
  plain-language summary used Landis & Koch 1977 (0.20/0.40/0.60/0.80),
  so 0.61 read “substantial” in the summary and “Good” in the table, and
  0.56 read “moderate” there and “Fair” here. One named scale (Landis &
  Koch) is now used throughout.
- **Wald intervals for kappa were not clamped to the parameter space**,
  and an unclamped interval reported an upper limit of 1.18 for a
  statistic bounded on \[−1, 1\]. Both branches now clamp, matching the
  sibling inter/intra path that already did.
- **Bootstrap confidence intervals computed the wrong statistics, in
  four separate ways.** (a) The categorical-versus-continuous decision
  was made per replicate with `length(unique(na.omit(x))) <= 20`; a
  bootstrap resample retains only about 0.63n distinct values, so at n ≈
  30–40 some replicates fell under the threshold, were treated as
  categorical, produced no ICC, and silently dropped the ICC row — at
  exactly the study sizes most common in pathology. It is now decided
  once, on the original data. (b) Each rater column was coded
  independently with `as.numeric(factor(x))`, so the same clinical
  category received different codes in different columns whenever raters
  used different subsets of the scale, corrupting Krippendorff’s alpha;
  a single shared category set is now used. (c) Krippendorff’s level of
  measurement was hard-coded to nominal and now follows the data. (d)
  The bootstrap ICC was hard-coded to ICC(2,1) two-way absolute
  agreement while the row was labelled with whatever `iccType` the user
  had selected; the user’s choice is now honoured in both paths.
- **The Bland-Altman plot did not refresh when the proportional-bias
  option was toggled** — `proportionalBias` was missing from `clearWith`
  although the plot adds a `geom_smooth` line under it. Separately, the
  pairwise-agreement figure silently truncated at `max_pairs`: with five
  raters, 4 of 10 pairs were dropped with no note, so the figure read as
  the complete set. The omission count is now stamped on the image
  itself, so it travels with an exported figure.

#### `lassologistic`

- **Coefficients and odds ratios were reported on the standardized
  scale, not the original measurement scale.** The design matrix is
  standardized in-module and `glmnet` is then called with
  `standardize = FALSE`, so nothing was back-transformed and every
  coefficient was per 1 SD. For a 0/1 dummy from a balanced marker (sd ≈
  0.5) the printed per-SD odds ratio is roughly the square root of the
  model’s actual present-versus-absent odds ratio: 1.81 printed where
  the model implies 3.25. The column standard deviations are now
  retained and coefficients divided through, reproducing exactly what
  `glmnet(standardize = TRUE)` would return. The Importance column keeps
  the per-SD magnitude, which is the quantity that is comparable across
  predictors, and the table note was rewritten accordingly.
- **The integer scoring system was internally inconsistent, and its rule
  was never published.** Points were derived from the raw per-SD
  coefficients while scores were awarded on a median split, so binary
  and continuous predictors were weighted on two different contrasts — a
  0/1 dummy’s per-SD coefficient is about half its real effect, while a
  continuous median split spans roughly 1.6 SD — mis-ranking them
  against each other and making the Scoring System table’s odds ratio
  disagree with the Selected Variables table for the same predictor
  (2.11 against 4.46 for p53). Points are now derived from the log-odds
  contribution of meeting each criterion, and the cut is resolved once
  so that the printed rule, the derivation contrast and the applied cut
  cannot drift apart. A new “Award points when” column publishes the
  criterion on the original measurement scale; previously the median cut
  never reached the output at all, so a clinician had no way to apply
  the score to a new patient.
- **The Brier score was graded against fixed cut-offs and mislabelled as
  calibration.** It is an overall accuracy score whose scale is driven
  by outcome prevalence: a no-information model that always predicts the
  base rate scores p(1−p), already 0.09 at 10% prevalence, which the old
  code graded “Excellent calibration”. It is now graded by the Brier
  skill score against that null model (“Good (x% better than predicting
  the base rate)” / “Marginal” / “No better than predicting the base
  rate”).
- **With zero selected variables, a model that calls everyone positive
  was presented as perfectly sensitive.** Every predicted probability is
  identical, the ROC is degenerate, and `pROC` returns `-Inf`, which was
  printed as “Optimal threshold: −Inf” beside Sensitivity 1.000 and
  Specificity 0.000. Non-finite thresholds now fall back to 0.5.
- **Selecting exactly one predictor produced a completely blank result**
  — no panel, no notice, no error. The welcome/To Do panel shows only
  when `explanatory` is empty, and the analysis returned early with one
  predictor, so both guards stayed silent. A warning now explains that
  LASSO performs variable selection and needs candidates to choose
  among.
- **Listwise deletion was invisible.** “Total observations” in the model
  summary actually held the complete-case count, so it read as the full
  cohort while rows had silently been removed, and the suitability
  assessment then green-lit the reduced N. The summary now reports
  “Complete cases analysed” and “Excluded (incomplete data)” separately,
  and a warning fires whenever any case is excluded, pointing out that a
  single sparsely-measured predictor can remove a large share of the
  cohort.
- **The bootstrap optimism correction did not disclose how many
  replicates it rested on.** Failed replicates are caught by `tryCatch`,
  left as `NA` and dropped by `na.rm = TRUE`, so a correction computed
  from 50 survivors of 200 looked identical to one computed from
  all 200. The table now footnotes the completed and failed counts, and
  warns separately when fewer than 20 replicates succeeded.

#### `decisioncombine` (Combine Medical Decision Tests)

- **Five of the seven optional outputs were completely non-functional.**
  `asDF` is an R6 *active binding* on
  [`jmvcore::Table`](https://rdrr.io/pkg/jmvcore/man/Analysis.html), so
  `tbl$asDF` already returns the data frame; the code wrote
  `tbl$asDF()`, invoking that data frame as a function — “attempt to
  apply non-function”. The recommendation and all four plots were
  affected.
- **The tables grew on every re-run and then broke.** Nothing called
  `deleteRows()`, and jamovi re-runs `.run()` on the same object
  whenever an option changes, so rows went 5 → 10 → 15; the duplicated
  row keys then made `$asDF` fail with
  `duplicate 'row.names' are not allowed`, taking down the second run
  entirely.
- **The analysis explained nothing when it stopped.** `.renderNotices()`
  sat after three early returns in `.run()`, so the notice saying *why*
  it had stopped was collected and then discarded, leaving a blank
  analysis with no message.
- **The “optimal” rule was an uncorrected argmax.** It ranks 5 candidate
  rules with two tests, or 10 with three, using no interval and no test,
  so on pure noise it still names a winner — and called it optimal. It
  now discloses how many rules were compared and that the winner is not
  an established finding. Serial (AND) and the all-positive pattern are
  the same 2×2 under two labels; counting both manufactured a tie and
  inflated that count.
- **Proportions and odds ratios shared one `estimate` column** —
  sensitivity appeared as a percentage in one table and as 0.813 in
  another. Now split. Serial (AND) also gained its own named row: it was
  numerically identical to the “+/+/+” pattern and had been omitted,
  leaving a reader to know that the pattern *was* the serial rule.
- **The “mixed” pattern filter dropped genuinely mixed patterns.** It
  excluded anything *starting with* `+/+` or `-/-`, removing `+/+/-` and
  `-/-/+`; and when no pattern matched it fell back to the whole
  unfiltered table rather than to nothing. A multi-level variable is now
  flagged rather than silently dichotomised, and a gold standard with
  one outcome yields `NA` with a notice instead of a silent number.
- Pattern and strategy statistics were confirmed against
  [`epiR::epi.tests`](https://rdrr.io/pkg/epiR/man/epi.tests.html), the
  Wilson intervals against
  [`binom::binom.confint`](https://rdrr.io/pkg/binom/man/binom.confint.html),
  and the OR/AND identities and the eight-pattern partition were checked
  as mathematical facts rather than estimates.

#### `decisioncalculator` (Medical Decision Calculator)

- **The tables grew on every re-run** — verified at the jmvcore level:
  `addRow()` with an existing `rowKey` *duplicates* rather than replaces
  (rowCount 2 → 4 → 6 over three passes, after which `$asDF` fails).
  Fixed on the three tables that populate via `addRow`.
- **The Fagan nomogram silently failed on any table with a zero cell** —
  precisely the sparse tables that most need one — because `nomogrammer`
  rejects a sensitivity or specificity of exactly 0 or 1. The
  proportions now come from the same Haldane-Anscombe corrected table
  the likelihood ratios already used, and a test whose positive result
  argues *against* disease declines with an explanation instead of
  crashing.
- **The most clinically useful part of the nomogram was invisible.**
  `nomogrammer` prints its reading — prevalence, likelihood ratios,
  post-test probabilities — to stdout under `Verbose = TRUE`, and jamovi
  never shows stdout. It is now rendered beside the figure, at the
  tables’ precision rather than `nomogrammer`’s whole percents, and
  tracks the supplied prior.
- **The cut-off comparison named the wrong alternative.** The verdict
  was an if/else-if chain, so when both alternatives beat the current
  cut-off only the first was ever named, however much better the second
  was. It now picks the best of the three, declines to call a trivial
  advantage better performance, flags cut-offs whose totals differ
  (moving a threshold cannot change how many patients there are, so
  differing totals mean separate studies), and reports whether the
  Wilson intervals on the accuracies overlap — a formal paired test is
  not possible from four marginal counts per scenario, and the table now
  says so.
- Point estimates and every interval bound were confirmed against
  [`epiR::epi.tests`](https://rdrr.io/pkg/epiR/man/epi.tests.html); the
  2×2 is not transposed; a supplied prior moves PPV and NPV while
  leaving sensitivity and specificity alone, and the table states which
  prevalence was used — the defect found in the sibling `decision` is
  not present here.

#### `nogoldstandard` (Analysis Without Gold Standard)

- **Latent-class analysis reported sensitivity and specificity
  swapped.** The diseased class was identified with
  `probs[[i]][class, outcome]` but read back as
  `probs[[i]][2, disease_class]` — the transpose. `[2,2]` and `[1,1]`
  coincide, so the error surfaced only when poLCA happened to label the
  diseased group as class 1, which is about half of all runs. Verified
  against `poLCA` on identical data and against the known truth of
  simulated data.
- **The default method could not estimate accuracy at all, and now does
  not hide it.** Under `all_positive` the reference standard is “every
  test positive”, so a diseased case can never be test-negative: FN is
  identically 0 and sensitivity and NPV are 1 for every test on every
  dataset. It printed “100% (95% CI 100–100%)”. `any_positive` is the
  mirror image (FP ≡ 0, specificity and PPV fixed at 1), and `composite`
  with two tests *is* `any_positive`, because a 1-of-2 tie passes a
  `rowMeans >= 0.5` majority. Those quantities are now blanked with an
  explanation. See Breaking changes for the change of default.
- **The confidence intervals were too narrow — by about 1.8× for
  sensitivity at 30% prevalence.** The standard error used the total n
  for both metrics; the denominators are n × prevalence for sensitivity
  and n × (1 − prevalence) for specificity.
- **The analysis claimed its latent-class model handles the assumption
  it actually makes.** The always-visible method guide advertised
  “Handles conditional dependence” and “No identifiability issues”,
  while `poLCA(nclass = 2, ~ 1)` assumes the tests err *independently*
  given true status. The guide now says so; a new **Conditional
  Independence Check** table reports bivariate residuals per test pair
  (above 3.84 is evidence of a shared error source, which inflates
  estimated accuracy); and it explains that four or more tests are
  needed for the check to be informative — with three the model is
  just-identified and reproduces every table exactly. Two tests cannot
  identify a two-class model at all (5 parameters against 3 degrees of
  freedom) and are now refused rather than answered with numbers
  determined by the starting values.
- **The Bayesian method disclosed neither its priors nor its nature.**
  Beta(2, 1) on both sensitivity and specificity has mean 2/3 and
  increases toward 1, so it pulls estimates upward; nothing mentioned
  any prior, or that the results are not draws from a posterior. Both
  are now stated.
- **One undefined cell could kill the analysis.**
  `if (ppv_denominator > 0)` with an `NA` sensitivity threw “missing
  value where TRUE/FALSE needed”, ending the run instead of blanking a
  number. An invalid positive level produced
  `Level 'test1_result' not found in variable 'negative, positive'. Available levels: {}`
  — `jmvcore::reject(formats, code = NULL, ...)` takes `code` as its
  second *positional* argument, so the substitution values were
  swallowed and shifted.
- Bootstrapping is now a single seeded pass with warm-started
  latent-class fits, and an **Analysis Diagnostics** panel (under
  Verbose output) reports sample size, method, convergence, random
  starts and bootstrap failures. The clinical summary no longer
  announces a sensitivity “Range from 100.0% to 100.0%”, and no longer
  presents the fraction of cases on which all tests agree as an estimate
  of disease prevalence.

#### `cotest` (Co-Testing Analysis)

- **A 0% post-test probability was reported for a test combination the
  model had made impossible.** When two tests are modelled as
  conditionally dependent, the joint probability P(Test1+, Test2+)
  cannot exceed the smaller of the two marginals — a Fréchet bound.
  Beyond it the requested dependence is unattainable and `cotest`
  truncated it to the bound. That truncation is correct, but it forces
  one of the four test combinations to have probability exactly zero in
  one disease group, and the likelihood-ratio helper turned that into a
  printed post-test probability of `0.000000` — which reads as “this
  combination rules out disease”. With the standard cervical co-testing
  pair (HPV 95%/85%, cytology 55%/97%) the bound binds from a dependence
  of 0.25 upward, so the analysis reported that an HPV-negative,
  cytology-positive woman has no chance of disease. When *both* groups
  hit their bounds the ratio was 0/0 and the same `0.000000` appeared
  for a combination that cannot occur at all. The three degenerate cases
  are now distinguished: 0/0 is undefined and the row is blank; a
  combination impossible only in non-diseased subjects gives exactly 1
  (previously a fake-precision `0.999991`, an artefact of an internal
  likelihood-ratio cap of 1e6); and one impossible only in diseased
  subjects still gives 0. All three, and the truncation behind them, now
  raise a warning stating that the value follows from the assumed model
  rather than from data. The truncation was previously reported at
  “info” severity and never said what it implied.
- **The Fagan nomogram emitted a raw R error into the results pane.**
  [`nomogrammer()`](https://www.serdarbalci.com/meddecide/reference/nomogrammer.md)
  refuses a positive likelihood ratio below 1, which the permitted
  specificity range (down to 0.01) can produce, and the call was
  unguarded. The nomogram is now suppressed with an explanation naming
  the offending ratio.
- **The “Understanding Test Dependence” panel was displayed even under
  conditional independence,** where it describes a model that is not
  being fitted — the `visible: (!indep)` case of the leading-`!` defect
  described under `decisioncompare`. Rewritten as `(indep == FALSE)`.
- Post-test probabilities under conditional independence were confirmed
  against Bayes’ theorem to nine decimal places, and the dependent model
  was confirmed to reduce to them exactly at zero dependence. The
  shipped tests had asserted four different values, implying joint
  likelihood ratios of 120/2.105/3.333/0.0585 where the correct ones are
  112/2.526/3.111/0.0702 — the module was right and the expected values
  were fabricated. Eight further assertions passed an error message
  containing parentheses as a regular expression, so they never matched,
  and because testthat re-raises a non-matching error they masked one
  another.
- **The joint-probability validation could never fail.** It compared the
  sum of the four cells against 1, but the caller *defines* the fourth
  cell as one minus the other three, so the sum was 1 by construction
  and the check passed on any input — including a set whose cells no
  longer matched the sensitivities they were built from. It now also
  verifies that every cell is a probability and that P(both) + P(one
  only) still reproduces the marginal it came from, which is the
  invariant the clamping could actually break.
- **Negative conditional dependence is now accepted.** The parameter was
  bounded at 0, so tests that partly compensate for each other’s errors
  could not be expressed. The permitted range is now −1 to 1 across the
  option definition, the UI clamp and the backend validation. The
  existing Fréchet clamping already handled negative values; the
  resulting joint distributions were verified to be valid and to
  reproduce their marginals across the full range. For tests with high
  specificity the feasible negative range is narrow, and values beyond
  it are truncated with the warning described above.
- **Post-test probabilities carry no uncertainty, and now say so where
  they are read.** Sensitivity, specificity and prevalence are typed in
  by the user and treated as exact, so no reported probability has a
  confidence interval. That was stated only in the collapsible “Getting
  Started” panel and is now a note on the results table itself.

#### `sequentialtests` (Sequential Testing Analysis)

- **Clinical presets were ignored whenever the analysis was called from
  R.** The eight presets are applied by
  `jamovi/js/sequentialtests.events.js`, which writes the values into
  the interface controls; nothing runs that JavaScript outside jamovi,
  so asking for the HIV scenario silently analysed the panel defaults -
  0.95/0.70 with 0.80/0.98 at 10% prevalence - instead of ELISA and
  Western Blot at 2%. `preset` was the only declared option the backend
  never read. Presets are now applied in the backend as well, and a
  regression test parses the JavaScript configuration and compares it
  field by field against the R table, so the two cannot drift apart.
- **Illustrative teaching values were presented as evidence.** The
  preset control was documented as loading “evidence-based test
  parameters and optimal strategies from medical literature”. They are
  rounded approximations with no citation, no confidence interval and no
  population behind them, chosen to make each strategy’s behaviour
  visible. Selecting a preset now raises a warning that the figures are
  for demonstration only and must not be used to design a protocol or
  advise on a patient; the same caveat appears beside the preset in the
  interface and in the option documentation. The eleven bundled
  `sequentialtests_*` example datasets had **no documentation at all**;
  they are now documented, leading with the same warning and spelling
  out that a single sensitivity figure hides variation by assay,
  operator and disease stage, that the prevalences are illustrative
  settings rather than yours, and that a label such as `"RT-PCR"` names
  the scenario rather than asserting anything about that test as
  actually performed.
- **A Fagan nomogram was advertised that does not exist.** The word
  appeared in the analysis description and nowhere else in the module -
  no option, no results item, no code - while every sibling analysis in
  the same menu does provide one.
- **Two of the three strategies are the same rule, and nothing said
  so.** Serial testing of negatives and parallel testing both call a
  subject positive if *either* test is positive, so they are
  algebraically identical in sensitivity, specificity, PPV and NPV; they
  differ only in how many second tests are performed, which only the
  cost table reveals. Verified identical to 1e-12. A note now explains
  it.
- **The conditional-independence caveat went stale.** It was attached
  only to parallel testing, and because the summary table declares no
  `clearWith` it survived a change of strategy - leaving a note about
  parallel testing under a row labelled “Serial Testing”. The assumption
  applies to all three strategies and is now stated for all three,
  alongside a note that sensitivity, specificity and prevalence are
  treated as exact so the combined figures carry no confidence interval.
  Negative conditional dependence, previously forbidden by a lower bound
  of 0, is now permitted across the -1 to 1 range in the option, the
  interface clamp and the backend validation; the existing Frechet
  clamping already handled it correctly. All three strategies were
  confirmed against a four-million-subject simulation of their actual
  decision rules, and the conditional-independence figures against
  Bayes’ theorem to nine decimal places.

#### `enhancedROC` (Clinical ROC Analysis)

- **Every results table doubled on each re-run, and then broke.**
  Twenty-one `addRow()` calls and not one `deleteRows()`. jamovi re-runs
  an analysis on the same object whenever an option changes, so the AUC
  summary went 2 to 4 to 6 rows and the cut-off table 32 to 64 to 96;
  from the second run onward the tables could not be read at all,
  failing with `duplicate 'row.names' are not allowed`. Anyone who
  changed a checkbox mid-session was reading each predictor two or three
  times over. Fixed on all 18 tables populated by `addRow`; the two
  driven by `setRow` cannot duplicate and were left alone.
- **Nothing in 4,500 lines set a random seed,** while the analysis
  resamples in four places: bootstrap AUC confidence intervals,
  bootstrap ROC comparisons, internal-validation resamples and
  cross-validation fold assignment. Two identical runs returned 95%
  intervals of 0.775-0.862 and 0.771-0.862, so a figure copied into a
  manuscript could not be reproduced. A new **Random Seed** option
  (default 0) seeds all four; the caller’s own random number stream is
  restored afterwards.
- **Automatic direction detection biases the AUC upward, and now says by
  how much.** `pROC`‘s auto-detection reads the direction from the data
  by comparing the two groups’ medians, and it is the default. Because
  the direction is then fitted from the same data that supply the AUC,
  the AUC is inflated: a marker carrying no information at all gives a
  mean reported AUC of 0.593 at n = 20 and 0.565 at n = 40, against
  0.502 when the direction is fixed in advance, and exceeds 0.60 in 43%
  of runs at n = 20 - enough to turn a null pilot study into an
  apparently promising biomarker. The notice named the direction chosen
  but not this consequence, and was filed as informational. It is now a
  warning quoting the expected AUC for an uninformative marker at the
  study’s own sample size, and recommending that Direction be set
  explicitly.
- **Three comparison options did nothing, without explanation.**
  Pairwise comparisons, metric differences and statistical comparison
  all require Analysis Type to be “Comparative ROC Analysis”, but the
  interface offers them as plain checkboxes with no such dependency;
  ticking one under the default Analysis Type produced no output and no
  message. They now say what to change.
- **Nineteen options were documented as working features but do
  nothing.** They reach the public R wrapper and
  [`?enhancedROC`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)
  described them in the present tense - “Calculate Harrell’s concordance
  index for time-to-event outcomes” - while the backend only lists them
  in a “planned features” notice at run time. None has an interface
  control, so this affected R callers and the help page rather than the
  jamovi menus. All twenty such options, including `splineKnots` which
  configures one of them, are now prefixed “NOT YET IMPLEMENTED -
  selecting this produces no output”.
- `test-enhancedroc-pr-clinical.R` never exercised the analysis. It
  built a hand-rolled `jmvcore` (`MockTable`, `MockHtml`, `MockImage`),
  assigned a fake base class into the global environment and
  [`source()`](https://rdrr.io/r/base/source.html)d the backend; the
  mock implemented only `addRow`, `setRow` and `asDF`, drifted from the
  real backend, and the whole file died with “attempt to apply
  non-function”. Rewritten against the real function, keeping its
  assertions and adding a check that PPV at a user-supplied prevalence
  equals Bayes’ theorem applied to the table’s own likelihood ratio. AUC
  itself was confirmed against `pROC` to nine decimal places under every
  direction setting.

#### `psychopdaROC` (Advanced ROC Analysis)

- **Fourteen of the sixteen results tables doubled on every re-run.**
  Twenty-one `addRow()` calls against two `deleteRows()`. jamovi re-runs
  an analysis on the same object whenever any option changes, so rows
  went 1 to 2 to 3 per predictor and the decision curve 40 to 80 to 120.
  Every table is now cleared once at the top of the run - after the
  manual-run gate, so that manual mode keeps its results when an option
  is edited.
- **Leaving the positive class unset ran the whole analysis backwards.**
  The fallback took the FIRST factor level, which for every ordinary
  coding - Healthy/Disease, Negative/Positive, Control/Case, 0/1 - is
  the NEGATIVE group. On the bundled example data it reported AUC 0.1001
  where naming the positive class gives 0.8999, with no error and no
  warning. Worse, the positive class was worked out in four places that
  could disagree, one of which fell back to `unique(classVar)[1]` - the
  first value in DATA ORDER, so the answer depended on how the rows
  happened to be sorted. All four now go through one resolver, which
  takes the last level and says so on the results tables. With three or
  more levels it refuses instead of guessing, matching `enhancedROC`: on
  a three-level recode of the bundled data, assuming “Disease” gives AUC
  0.8012 and assuming “Severe” gives 0.8263, and there is no basis for
  preferring either.
- **The reported “optimal cutpoint” was usually not the optimum.** The
  metric tolerance defaulted to 0.05 while the underlying `cutpointr`
  package uses 1e-06. Every cutpoint scoring within 0.05 Youden of the
  best was treated as equivalent and averaged: on the bundled data 39 of
  200 candidate thresholds, spanning 52.1 to 67.7, giving a cutpoint
  with 84.5 percent sensitivity in place of the 94.4 percent available
  at the true optimum. The default now matches `cutpointr`, and any
  tolerance still in force is disclosed beside the cutpoint.
- **The Hanley-McNeil fallback footnote pointed the wrong way.** It
  warned that the approximation “may produce narrower confidence
  intervals than appropriate”. On the shipped data its standard error is
  0.025863 against DeLong’s 0.021092 - 22.6 percent WIDER,
  i.e. conservative. The formula itself is the standard Hanley-McNeil
  variance and is correct; only the footnote was wrong.
- Six [`warning()`](https://rdrr.io/r/base/warning.html) calls remain
  invisible to jamovi users (R sends them to stderr, which the GUI does
  not display). Two of them used to change the analysis rather than
  merely inform; those are gone, and the analysis has no general notices
  panel - see Remaining work.
- **DeLong’s test could report an AUC of 0.794 for a marker the AUC
  table reported as 0.206.** DeLong’s test needs every marker read in
  the same direction, so when a marker’s AUC came out below 0.5 the
  fallback implementation flipped its scores and then displayed
  `1 - AUC`. The primary implementation does not flip - it passes the
  user’s Classification Direction straight to `pROC` and reports the
  honest figure - so the two tables disagreed for exactly the markers
  where the direction is in question, and the only signal was an R
  [`warning()`](https://rdrr.io/r/base/warning.html), which a jamovi
  user never sees. Measured on a constructed marker: 0.206 in the AUC
  table, 0.794 in the DeLong output. The flip still happens, because the
  test requires it, but the affected markers are now named both in the
  DeLong output and in a note on the comparison table, with the
  instruction to change Classification Direction and re-run if the
  reversed direction is the clinically correct one.
- **DeLong’s test printed confident p-values on samples too small to
  support them.** Its variance is a large-sample approximation, so with
  few cases in either class the p-values and confidence intervals are
  too narrow. A note now appears when either class holds fewer than ten
  cases - the conventional floor for a stable AUC variance - and says
  that any difference should be treated as provisional. The check sits
  in the rendering path, so it covers both implementations.
- The test suite was substantially broken and is repaired:
  `test-psychopdaroc.R` was 29 failures and 6 errors, and
  [`source()`](https://rdrr.io/r/base/source.html)d
  `../../R/psychopdaROC.h.R` - capitalised paths that do not exist, so
  the file only loaded on a case-insensitive filesystem. Its helper in
  five other files filled every argument lacking a default with `""`,
  including `dependentVars` and `classVar`, so a test that omitted a
  required variable was silently handed an empty string. All nine
  documented examples were uncopyable because none passed `refVar`, a
  `type: Level` option that the jamovi compiler forbids a default on and
  which is therefore a required argument. AUC, the DeLong test and the
  optimal cutpoint were confirmed against `pROC` and `cutpointr`.

#### Cross-checking the two ROC analyses

`enhancedROC` and `psychopdaROC` sit in the same menu, so the same data
can be put through either. They were compared directly on eight
datasets. **The estimators agree to machine precision**: AUC and DeLong
confidence intervals were bit-identical across all of them - maximum
absolute AUC difference 3.2e-15, maximum CI difference exactly zero -
and both matched `pROC` and a hand-computed Mann-Whitney AUC, including
on data rounded to only twenty distinct values. What differs is defaults
and scope, and one of those matters:

- **Their direction defaults disagree, and both analyses now explain
  this on screen.** For a marker where LOWER values indicate disease - a
  falling haemoglobin, a falling ejection fraction

  - the same column of numbers came back as AUC 0.8999 from
    `enhancedROC` and 0.1001 from `psychopdaROC`, with nothing on screen
    saying why. The cause is a default, not a calculation: `enhancedROC`
    works the direction out from the data, while `psychopdaROC` assumes
    higher values mean disease unless told otherwise. Both answers are
    correct for the question each is asking - 0.1001 is what you get if
    you insist higher means disease, and 0.8999 is the same marker read
    the right way round - and told the same direction the two agree
    exactly.

  Each analysis now prints the same plain sentence beside its AUC,
  worded identically so the two outputs can be read side by side:

  > Reading of the test values: **HIGHER values of biomarker were taken
  > to indicate Disease**.

  It goes on to say where that reading came from (specified by you, or
  worked out from the data) and that every sensitivity, specificity,
  cutpoint and AUC is reversed if it is the wrong way round.
  `psychopdaROC`’s “AUC below 0.5” warning now also names the current
  Classification Direction setting and states that switching it gives an
  AUC of 1 minus the value shown, with sensitivity and specificity
  swapped - so the remedy is explicit rather than left to the reader.
  Set Direction explicitly whenever the marker’s orientation is known
  clinically.

- `enhancedROC` honours a confidence-level option; `psychopdaROC` has
  none and always reports 95 percent, so at 99 percent the two give
  \[0.8456, 0.9542\] and \[0.8585, 0.9412\].

- `enhancedROC` refuses any dataset below n = 20 and returns nothing;
  `psychopdaROC` computes and agrees with `pROC` (n = 16: 0.6406
  \[0.3236, 0.9576\]).

- Their optimal cutpoints differ in the last decimal by construction:
  `pROC` places the threshold at the MIDPOINT between two adjacent
  observed values (54.1979) while `cutpointr` returns an observed value
  (54.2904). Sensitivity and specificity are identical either way.

- Given a positive class that does not exist, `enhancedROC` returns
  empty tables with an explanatory panel while `psychopdaROC` raises an
  R error.

#### The kappaSize sample-size family (`kappaSizePower`, `kappaSizeCI`, `kappaSizeFixedN`)

- **Certain option combinations froze the analysis permanently.**
  `kappaSize`’s root finder does not converge when the significance
  level is at or above the target power: a direct
  `PowerBinary(alpha = 0.90, power = 0.20)` call was still running when
  killed after 60 seconds and could not be interrupted, while the same
  call at alpha 0.05 and power 0.80 returns instantly. The option bounds
  permitted alpha up to 0.99 and power down to 0.01, so the combination
  was reachable from the interface and left jamovi with no way to
  recover. It is now refused before the engine is entered, in 0.07
  seconds, with an explanation that a study whose power does not exceed
  its type I error rate provides no evidence. The same guard removes two
  related absurdities: power 0.01 used to report “A minimum of 1
  subjects”, and alpha just below power produced a sample size of zero
  rendered as one subject.
- **`kappa0` was documented backwards in two of the three analyses.**
  `kappaSize`’s own documentation defines `PowerBinary`’s `kappa0` as
  “the null hypothesis for the kappa hypothesis test” and `CIBinary`’s
  and `FixedNBinary`’s as “the preliminary value of kappa” - two
  different quantities that happen to share a name. `kappaSizePower`
  described its null as the “Expected value of kappa”, and `kappaSizeCI`
  described its anticipated value as “the null hypothesis value of
  kappa”: each carried the other’s meaning. Someone following the help
  text would enter the wrong quantity and get a different answer without
  any indication. All three descriptions now match the package, each
  says explicitly what it is NOT, and `kappaSizeCI`’s printed output no
  longer labels its anticipated kappa “Null hypothesis kappa”.
- **The three analyses now agree on their shared options.** The
  significance level was bounded 0.01-0.99 in Power and CI but 0.01-0.20
  in FixedN; all three are now 0.001-0.20. The old floor made a
  Bonferroni-adjusted alpha inexpressible, and the old ceiling admitted
  values that are not significance levels at all. Proportions parse
  identically everywhere (commas, semicolons or spaces) - the string
  `0.30 0.70` was accepted by `kappaSizeFixedN` and rejected by
  `kappaSizePower`. A binary outcome may be entered as one prevalence or
  as two proportions in all three; `kappaSizeFixedN` alone demanded two,
  although
  [`kappaSize::FixedNBinary`](https://rdrr.io/pkg/kappaSize/man/FixedNBinary.html)
  accepts either. A European decimal comma (`0,30 0,70`) used to report
  “Each proportion must be strictly between 0 and 1”, which is true and
  useless; it now names the decimal separator as the problem.
- **The power and confidence-interval approaches answer different
  questions, and each now says so.** For the same study they can differ
  by nearly threefold in required sample size, with nothing in either
  output explaining why. Each now opens by stating whether it is sizing
  the study to reject a null value or to achieve a target interval
  width, and names the other analysis.
- **An alternative kappa below the null was answered silently.** It is a
  legitimate question - how many subjects to show agreement is WORSE
  than the null - but it is more often a transposition, and it returns a
  different sample size from the mirrored input (149 against 191 on the
  default scenario). The output now states which way round it read the
  two values.
- The study explanation never reported the sample size it was
  explaining, and read “the prevalence of the categories are” for three
  or more categories. The result panel rendered the raw `kappaSize`
  object, duplicating the summary panel and repeating the same
  expected-cell-count warning ten times in the five-category case; it
  now shows the headline sentence.
- Sample sizes were confirmed against `kappaSize` across 540
  combinations - four cardinalities, five rater counts, three kappa
  pairs, three significance levels and three power targets - with zero
  divergences, plus a 95-case rounding check. The module is a faithful
  wrapper; everything fixed here sits around the calculation rather than
  in it.

##### `kappaSizeCI`

- **A narrow confidence interval froze the analysis with no way out.**
  [`kappaSize::CIBinary`](https://rdrr.io/pkg/kappaSize/man/CIBinary.html)
  finds its answer by brute force - `n <- 10; while (...) n <- n + 1` in
  interpreted R, with no cap - and the required n grows as roughly one
  over the square of the distance from `kappa0` to the nearer limit.
  Measured on the binary engine: distances of 0.20, 0.05, 0.01 and 0.005
  give 118, 1,625, 38,203 and 151,533 subjects in 0.00 to 1.38 seconds,
  while 0.0005 had not returned after eight seconds. jamovi cannot abort
  a running analysis, so the user was simply stuck with no error and no
  progress. The search now runs under a bounded wall-clock budget
  (`setTimeLimit`, which does interrupt an interpreted loop) and, if it
  expires, refuses with a message naming the distance to the nearer
  limit and telling the user to widen the interval. Demanding but finite
  designs are untouched: 0.55-0.65, 0.58-0.62 and 0.59-0.61 still return
  1,625, 9,707 and 38,203.
- **The explanation reported the wrong quantity as the driver of the
  sample size.** It showed the “Precision width” of the interval, but
  `kappaSize` sizes on whichever limit lies nearer `kappa0`: with
  `kappaL = 0.55` the answer is 1,625 for every `kappaU` from 0.65 to
  0.99. In one-sided mode `kappaU` is not used at all. The output now
  states the distance to the nearer limit and says explicitly that this,
  not the full width, is what determines the number of subjects.
- **Proportions were parsed with a character class that did not mean
  what it looked like.** The separator set was written `"[,;|\\t]+"`,
  which in R is the *set* of characters `,` `;` `|` `\` and the letter
  `t` - it matched a literal backslash and the letter t, but neither an
  actual tab nor a space. So `0.2, 0.3; 0.5` was accepted and
  `0.2, 0.3 0.5` was rejected. It is now `[,;|[:space:]]+`, which
  handles tabs and spaces properly. A European decimal comma is
  diagnosed as such rather than reported as an out-of-range proportion.
- **`kappaSize`’s own sparse-cell caveat reached only the Summary
  pane.** When the computed sample size leaves a category with fewer
  than five expected subjects, the package says so in its summary text -
  a real warning about the large-sample approximation it relies on, in
  the one place a reader looking for caveats would not think to look. It
  is now raised in the Notes panel as well.
- Sample sizes were confirmed against `kappaSize` across 2,560
  comparisons, including the one-sided path, with zero divergences.

##### `kappaSizeFixedN`

- **The analysis could display a lower bound of -23.78 for Cohen’s
  kappa.** Kappa is bounded below by -1. `kappaSize` searches by
  decrementing rho from `kappa0` in steps of 0.001 with no floor, so a
  combination that is inside every declared option bound -
  `kappa0 = 0.01`, `n = 11`, a 2% prevalence, `alpha = 0.001` - walks
  straight past -1, and the result was printed as an ordinary answer. It
  is now refused, with an explanation that the large-sample
  approximation has broken down at this combination and what to change.
  A bound that is negative but still valid (for example -0.293) is
  reported as before, now with a sentence saying that a bound at or
  below zero means this many subjects cannot rule out agreement no
  better than chance.
- **A sample size of infinity hung the analysis forever.** The guard
  read `is.na(n) || n < 2 || n != round(n)`, and `Inf` passes all three
  clauses - `is.na(Inf)` is FALSE, `Inf < 2` is FALSE, and
  `Inf != round(Inf)` is FALSE. Inside the engine the test statistic
  becomes NaN and the search never terminates. `n` is now bounded 11 to
  1,000,000 at the option level and checked for finiteness and
  integrality in the backend.
- **Sample sizes below 11 produced the package’s own message, which is
  off by one.** Every `kappaSize` FixedN engine contains
  `if (n <= 10) stop("Sorry, your study should enroll at least 10 subjects.")`,
  while the option permitted `n` down to 2 - so 2 through 10 reached the
  engine only to bounce back as a raw vendor string that names the wrong
  threshold. The option floor is now 11 and the message explains that
  the method is a large-sample approximation.
- **The significance level was checked against the wrong bounds in the
  backend.** The backend accepted anything in (0, 1) while the option
  compiles to 0.001-0.20, so an R caller passing `alpha = 0.5` reached
  the engine and got “missing value where TRUE/FALSE needed”. The two
  now agree. The proportions-sum tolerance likewise used `all.equal`,
  which accepts a sum within 0.001 inclusive, while the engine rejects
  at 0.001 exclusive; the module now uses the engine’s own predicate so
  no input can slip past the clear message into the vendor one.
- **A rejected re-run left the previous run’s numbers on screen.**
  jamovi calls `.run()` on the same object for every option change, and
  validation rejects before anything new is written, so an invalid edit
  produced a red error above a stale, still-plausible-looking result.
  All panels are cleared first, as the two sibling analyses already did.
- **The study explanation invited a misreading.** It opened “Researchers
  would like to determine the expected lower bound for kappa0=0.6”,
  which reads as though the bound belonged to `kappa0`. It does not:
  `kappa0` here is the agreement the researchers *anticipate observing*,
  and the bound is the worst case still compatible with it at this
  sample size. The wording now says so, states the confidence level,
  reports the answer it is explaining, and says “the prevalence of the
  trait is” rather than “the proportions of the outcome categories are”
  when a single binary prevalence was entered.
- **A Notes panel was added.** It states the method and, in particular,
  that `kappa0` here is the anticipated agreement and *not* a null
  hypothesis value as it is in `kappaSizePower` - the two analyses sit
  in the same menu and take an identically named argument with different
  meanings. It warns when a category is expected to contain fewer than
  five subjects, and warns in red when the achievable bound is at or
  below zero, the case where the planned study cannot demonstrate
  agreement at all regardless of what it observes.
- Lower bounds were confirmed against `kappaSize` across 2,000
  combinations with a maximum difference of 6e-16 (print rounding
  alone). Both monotonicity properties - more subjects raise the bound,
  a higher significance level raises it - held in 400 of 400 checks
  each, and the returned bound was below `kappa0` in all 2,000.

### Changed

- **`lassologistic` score performance figures are now labelled as
  apparent.** “Score AUC” became “Score AUC (apparent)” and “Optimal
  score cutoff” became “Optimal score cutoff (chosen on this data)”,
  with a note that these figures are optimistic twice over — the points
  were derived from a model fitted to these data, and the cutoff was
  Youden-optimised on the same rows. The model’s own table already
  carried an optimism caveat; the score’s did not.

### Added

- **`lassologistic` gained a configurable cut point for continuous
  predictors in the scoring system.** `scoreCutMethod` offers median,
  mean, upper tertile, upper quartile and manual (default median,
  i.e. the previous behaviour), and `scoreCutPoints` is a free-text
  field taking `variable=value` pairs on the original measurement scale
  (for example `ki67=20, age=65`), so an established clinical threshold
  can be used instead of a data-derived split. Unparseable entries are
  dropped rather than guessed; any continuous predictor without a manual
  cut falls back to the sample median, and that fallback is named in a
  table note. The Scoring System note states that a dataset-derived cut
  is not an externally established threshold and will differ in another
  cohort.

### Documentation

All 92 files under `vignettes/` were audited against the shipped
analyses and their current option definitions. These articles are
published to <https://www.serdarbalci.com/meddecide/articles/>; they are
excluded from the package tarball by `.Rbuildignore`, so none of what
follows affects `R CMD check`.

- **Twenty-eight articles document an analysis that meddecide does not
  ship, and now say so.** `decisionpanel`, `decisiongraph`,
  `decisioncurve`, `modelbuilder`, `screeningcalculator`, `bayesdca`,
  `icccoeff`, `latentbiomarker`, `advancedtree`, `decision2` and `ppv`
  are all still on development or test menu routes, in this module and
  in the umbrella ClinicoPath module alike, so they reach no user today.
  Each affected article carries a note at the top - or, where the
  article is mainly about a shipped analysis and only borrows one of
  these, at the point of use - saying that the analysis is documented
  ahead of a future release, that its options and output may change, and
  that it will not appear in the jamovi menu yet. No article was
  deleted.
- **`07-kappasizeci-comprehensive.Rmd` described `kappa0` as a null
  hypothesis value.** For `kappaSizeCI` it is the *anticipated* kappa;
  only `kappaSizePower` treats it as a null. The article now states
  which it is and names the other analysis, since the two sit in the
  same menu and take an identically named argument meaning different
  things. The same article claimed that the *width* of the confidence
  interval drives the required sample size; the calculation actually
  sizes on whichever limit lies nearer `kappa0`, so with `kappaL = 0.55`
  the answer is 1,625 subjects for every `kappaU` from 0.65 to 0.99, and
  in one-sided mode `kappaU` is ignored entirely. It also listed the
  rater options as 2 to 5 where the analysis accepts 2 to 6.
- **`nogoldstandard-documentation.md` still gave the old default.** It
  listed `method` as defaulting to `all_positive` in two places; the
  1.0.4 default is `latent_class`, and the reason for the change is now
  stated alongside it.
- **Four articles illustrate
  [`agreement()`](https://www.serdarbalci.com/meddecide/reference/agreement.md)
  with an argument list that no longer exists.** Twenty- eight code
  chunks use names such as `rater1_var`, `agreement_type`,
  `pathologyContext` and `diagnosticStyleAnalysis`, none of which have
  existed for some time - copying them yields `unused argument`. Every
  chunk in these articles is `eval = FALSE`, so nothing broke and the
  narrative and statistics remain sound, but the code was uncopyable.
  Each now carries a notice to that effect together with a **verified**
  working call, checked against 1.0.4 on three raters and 60 cases
  (Fleiss’ kappa 0.734, Krippendorff’s alpha 0.735). A full rewrite of
  those examples against the current API is still outstanding.
- Argument names in six further call sites were corrected outright:
  `psychopdaROC(class =, value =)` is
  `psychopdaROC(dependentVars =, classVar =, positiveClass =)`, and
  `kappaSizeCI`/`kappaSizeFixedN` take `alpha` rather than a
  `conf_level`, with `kappaL`/`kappaU` in place of a single `width`.
- Every call to a shipped analysis across all 92 files - 345 of them -
  was checked against the generated wrapper signatures. Apart from the
  49 described above, all use argument names the functions accept.

### Removed

- **Pruned NAMESPACE exports for analyses that this module does not
  ship,** together with unused `importFrom` declarations. Seven exports
  were removed (`clinicalscore`, `decisioncurve`, `latentbiomarker`,
  `leaveonecenterout`, `mageeequation`, `misclassificationbias`,
  `timedependentdca`) along with about 25 unused imports
  ([`dplyr::arrange`](https://dplyr.tidyverse.org/reference/arrange.html)/`filter`/`summarise`,
  several `ggplot2` and `graphics` functions,
  [`stats::complete.cases`](https://rdrr.io/r/stats/complete.cases.html),
  and others). No shipped analysis was affected. `.Rbuildignore` gained
  `temp` and `backups` patterns.
- **`boot` and `survival` were dropped from `Imports`.** Neither is used
  anywhere in the package: no `::` call, no `NAMESPACE` import, and no
  bare call to any function they export. jamovi installs every package
  in `Imports` the first time a module is used, so two unused
  dependencies and their own dependency trees were being downloaded by
  every user for nothing.

## meddecide 1.0.3 (2026-08-04)

No user-visible changes. Version alignment across the ClinicoPath
submodules: the package version and every analysis version string were
bumped, and no R code, option definition or results definition was
touched.

## meddecide 1.0.2 (2026-08-03)

### Fixed

- **Three analyses named the wrong confidence-interval method.**
  [`epiR::epi.tests()`](https://rdrr.io/pkg/epiR/man/epi.tests.html) —
  the source of the sensitivity, specificity and predictive-value
  intervals in `decision`, `decisioncalculator` and `decisioncompare` —
  defaults to `method = "exact"`, which is the Clopper-Pearson interval,
  not Wilson. On a 2×2 of 67/56/38/79 the two differ in the third
  decimal (sensitivity 0.5385–0.7296 exact against 0.5428–0.7236
  Wilson). The footnotes in `decision` and `decisioncompare` said
  “Wilson score method” and now name Clopper-Pearson. **No interval
  changed** — only the label was wrong. `decisioncombine` was checked
  and left alone: its own `.calcWilsonCI()` genuinely is Wilson and
  genuinely populates the CI table it describes, so its labelling was
  already correct.

- **`decisioncompare` advertised likelihood-ratio confidence intervals
  it never computes.** The per-test table is filtered to a row set that
  excludes `lr.pos`/`lr.neg`, and the LRP/LRN columns carry no
  lower/upper bounds — so no likelihood-ratio interval is rendered
  anywhere in that analysis. The Assumptions panel now states that
  likelihood ratios are point estimates only, and describes the
  intervals that *are* shown: Clopper-Pearson for the proportions, the
  user’s chosen method (Wilson by default) for Overall Percent
  Agreement, and Wald for paired differences.

- **`decisioncalculator` overstated the reach of its continuity
  correction.** The notice said the Haldane-Anscombe 0.5 correction was
  applied to “likelihood ratios, diagnostic odds ratio, and confidence
  intervals”. It is applied to the point estimates only — `epi.tests()`
  is fed the raw table — so the intervals are uncorrected and may be
  undefined for those statistics when a cell is zero. The notice now
  says which is which.

- **`decision` crashed whenever “Disease Absent Level” or “Test Negative
  Level” was left unset.**
  [`dplyr::case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)
  evaluates every branch regardless of which one matches, so the
  unreachable `test == <negative level>` comparison still ran with the
  level `NULL`, produced a zero-length condition, and aborted the
  analysis with `Can't recycle ... size 0`. Both levels now use
  `NA_character_` as the “unset” sentinel, which compares to a
  full-length, never-matching condition. Behaviour with the levels *set*
  is unchanged: an explicitly chosen negative level still restricts the
  analysis to those two levels and drops rows with any other level.

- **Test and gold-standard variables were required arguments of the R
  function.** An option with no default in its jamovi definition
  compiles to a bare parameter, so calling the analysis from R without
  it failed with `argument "X" is missing, with no default` before the
  analysis’s own validation could produce a usable message. Now
  defaulting to `NULL`: `agreement` (`vars`), `decision` (`gold`,
  `newtest`), `decisioncombine` (`gold`, `test1`), `decisioncompare`
  (`gold`, `test1`, `test2`) and `nogoldstandard` (`test2`). Behaviour
  in the jamovi GUI is unchanged; no statistical method was altered.

### Added

- **Automated GitHub release (`.github/workflows/release.yaml`).** A
  push to the default branch touching `DESCRIPTION` or
  `jamovi/0000.yaml` cross-checks the two version strings, refuses to
  proceed if they disagree, and — if the tag does not already exist —
  tags `v<version>` and publishes a release whose notes are the matching
  section of this file.

## meddecide 0.0.47 (2026-07-05)

### Bug Fixes

- **Restored correct inter-rater agreement statistics on jamovi
  installs.** `vcd` and `lme4` are used by
  [`agreement()`](https://www.serdarbalci.com/meddecide/reference/agreement.md)
  but were missing from the package `Imports`. Because jamovi installs
  only a package’s `Imports`, on a clean install they were unavailable:
  pairwise kappa confidence intervals silently fell back to the narrower
  [`irr::kappa2`](https://rdrr.io/pkg/irr/man/kappa2.html) null-SE
  method, and the entire ICC / Lin’s CCC / continuous-agreement suite
  (which relies on `lme4`) was non-functional. Both are now declared, so
  agreement CIs use the intended
  [`vcd::Kappa`](https://rdrr.io/pkg/vcd/man/Kappa.html) asymptotic-SE
  method and the continuous-agreement measures work.
- Clarified the all-pairs kappa fallback note so it distinguishes a
  missing `vcd` package (with install guidance) from a genuinely
  near-degenerate table.
- Declared `DescTools` and `lmerTest`, previously used via `::` but
  undeclared.

## meddecide 0.0.46 (2026-07-04)

This release consolidates every change since 0.0.32.69 (unreleased
versions 0.0.33 through 0.0.46 roll into this entry). The headline is a
large expansion of
**[`agreement()`](https://www.serdarbalci.com/meddecide/reference/agreement.md)**
into a comprehensive interrater/intrarater reliability suite (20+ new
agreement statistics, tests, and visualizations), robustness and
input-validation hardening of the ROC modules, one-sided
confidence-interval support in the kappa sample-size tools, and package
infrastructure updates (minimum jamovi app raised to 2.7.27, new
imports, dataset cleanup).

### Major Changes

#### `agreement()` — Comprehensive Reliability Suite Expansion

The agreement module was expanded from Cohen’s/Fleiss’ Kappa into a full
interrater/intrarater reliability toolkit. Each new statistic ships with
its own results table, an “About …” HTML explanation, and a “When to use
…” guide notice.

- **New chance-corrected / categorical measures:**
  - Gwet’s AC1/AC2 (`gwet`, with `gwetWeights`:
    unweighted/linear/quadratic) → `gwetTable`
  - PABAK with prevalence and bias indices (`pabak`) → `pabakTable`
  - Light’s Kappa for 3+ raters (`lightKappa`) → `lightKappaTable`
  - Krippendorff’s Alpha guidance (`showKrippGuide`)
- **New continuous-data agreement measures:**
  - ICC with six models ICC(1,1)–ICC(3,k) (`icc`, `iccType`) →
    `iccTable`
  - Mean Pearson correlation (`meanPearson`) → `meanPearsonTable`
  - Lin’s Concordance Correlation Coefficient (`linCCC`) → `linCCCTable`
  - Total Deviation Index (`tdi`, `tdiCoverage`, `tdiLimit`) →
    `tdiTable`
  - Finn coefficient with one-way/two-way models (`finn`, `finnLevels`,
    `finnModel`) → `finnTable`
  - Iota multivariate coefficient (`iota`, `iotaStandardize`) →
    `iotaTable`
- **New ordinal / rank-based agreement measures:**
  - Kendall’s W coefficient of concordance (`kendallW`) →
    `kendallWTable`
  - Robinson’s A ordinal agreement index (`robinsonA`) →
    `robinsonATable`
  - Mean Spearman rho (`meanSpearman`) → `meanSpearmanTable`
- **New marginal-homogeneity / rater-bias tests:**
  - Rater Bias test (`raterBias`) → `raterBiasTable`
  - Bhapkar test (`bhapkar`) → `bhapkarTable`
  - Stuart-Maxwell test (`stuartMaxwell`) → `stuartMaxwellTable`
  - Maxwell’s RE random-error index (`maxwellRE`) → `maxwellRETable`
- **New multi-rater / structural analyses:**
  - Pairwise Kappa against a reference rater with performance ranking
    (`pairwiseKappa`, `referenceRater`, `rankRaters`) →
    `pairwiseKappaTable`
  - Hierarchical/multilevel Kappa (`hierarchicalKappa`,
    `clusterVariable`) with cluster-specific estimates,
    variance-component decomposition, hierarchical ICC,
    cluster-homogeneity test, and shrinkage (empirical Bayes) estimates
    → `hierarchicalOverallTable`, `clusterSpecificTable`,
    `varianceDecompositionTable`, `hierarchicalICCTable`,
    `homogeneityTestTable`
  - Mixed-effects condition comparison with Bonferroni/BH/Holm
    correction (`mixedEffectsComparison`, `conditionVariable`,
    `multipleTestCorrection`) → `mixedEffectsTable`,
    `mixedEffectsVarianceTable`
  - Inter/intra-rater test-retest reliability (`interIntraRater`,
    `interIntraSeparator`) → `interIntraRaterIntraTable`,
    `interIntraRaterInterTable`
- **New machine-learning-style metrics:**
  - Confusion matrix table with row/column normalization
    (`confusionMatrix`, `confusionNormalize`) → `confusionMatrixTable`,
    `perClassMetricsTable`
  - Multi-annotator concordance / F1 (`multiAnnotatorConcordance`,
    `predictionColumn`) → `concordanceF1Table`,
    `concordanceF1PerClassTable`
  - Specific (category-focused) agreement indices with optional CIs
    (`specificAgreement`, `specificPositiveCategory`,
    `specificAllCategories`, `specificConfidenceIntervals`) →
    `specificAgreementTable`
  - Bootstrap confidence intervals (`bootstrapCI`, `nBoot`) →
    `bootstrapCITable`
- **New visualizations:**
  - Agreement heatmap / confusion-matrix plot (`agreementHeatmap`) with
    color schemes (blue-red, traffic-light, viridis, grayscale) and
    count/percentage cell annotations (`heatmapColorScheme`,
    `heatmapShowCounts`, `heatmapShowPercentages`,
    `heatmapAnnotationSize`) → `agreementHeatmapPlot`
  - Bland-Altman method-comparison output with a Shapiro-Wilk normality
    check (`showBlandAltmanGuide`) → `blandAltmanHeading`,
    `blandAltmanExplanation`
  - Rater profile plots — box/violin/bar (`raterProfiles`,
    `raterProfileType`, `raterProfileShowPoints`) → `raterProfilePlot`
  - Rater clustering and case clustering with dendrograms and heatmaps —
    hierarchical/k-means, correlation/euclidean/manhattan/agreement
    distances, average/complete/single/ward linkage (`raterClustering`,
    `caseClustering`) → `raterClusterTable`, `raterDendrogram`,
    `raterClusterHeatmap`, `caseClusterTable`, `caseDendrogram`,
    `caseClusterHeatmap`
  - Stratified agreement-by-subgroup with forest plot
    (`agreementBySubgroup`, `subgroupVariable`, `subgroupForestPlot`,
    `subgroupMinCases`) → `subgroupAgreementTable`,
    `subgroupForestPlotImage`
- **New workflow tools:**
  - Paired agreement comparison between two rater conditions with
    bootstrap (`pairedAgreementTest`, `conditionBVars`, `pairedBootN`) →
    `pairedAgreementTable`
  - Sample-size calculator for agreement studies supporting Cohen’s
    Kappa / Fleiss’ Kappa / ICC (`agreementSampleSize`, `ssMetric`,
    `ssKappaNull`, `ssKappaAlt`, `ssNRaters`, `ssNCategories`,
    `ssAlpha`, `ssPower`) → `agreementSampleSizeTable`
- **New computed output variables:**
  - Consensus rating variable with majority/supermajority/unanimous
    rules and tie handling (`consensusVar`, `consensusName`,
    `consensusRule`, `tieBreaker`) → `consensusTable`, `consensusVar`
  - Case-level Level-of-Agreement categorization — simple/detailed with
    custom/quartile/tertile thresholds (`loaVariable`, `detailLevel`,
    `simpleThreshold`, `loaThresholds`, `loaHighThreshold`,
    `loaLowThreshold`, `loaVariableName`, `showLoaTable`) → `loaTable`,
    `loaDetailTable`, `loaOutput`
- **Other agreement additions:**
  - Configurable confidence level for CIs (`confLevel`)
  - Level-ordering information panel (`showLevelInfo`) →
    `levelInfoTable`
  - Plain-language Summary, About, and Clinical Use Cases panels
    (`showSummary`, `showAbout`) → `summary`, `about`,
    `clinicalUseCases`
  - New client-side events handler `jamovi/js/agreement.events.js`
    (bounds/dependency handling for `confLevel`, Bland-Altman confidence
    level, cluster counts, and subgroup minimums)

### Enhanced Existing Functions

- **[`enhancedROC()`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md)**:
  Robustness and UX overhaul

  - Rewritten input validation: guards for single-value outcomes,
    outcome-level checks, and positive-class validation
  - HTML-escaped error/warning messages (`private$.safeHtmlOutput`) and
    a notices framework (`.addNotice`/`.renderNotices`) plus a
    methods-explanation panel and instructions
  - Sensible defaults now ON: `youdenOptimization`, `rocCurve`,
    `aucTable`, `optimalCutoffs`, `diagnosticMetrics`; `customCutoffs`
    now defaults to empty
  - Added `clearWith` to results so outputs invalidate correctly;
    removed dead commented-out time-dependent AUC/ROC stubs

- **`psychopdaroc()`**: Input hardening and cleanup

  - Bootstrap/threshold count options changed from Number to Integer
    (`boot_runs`, `maxThresholds`, `bootstrapReps`, `idiNriBootRuns`)
  - Removed dead commented-out option stubs (`effectSizeMethod`,
    `advancedMetrics`); added `clearWith` to results

- **`kappasizeci()`**: One-sided confidence intervals

  - New `citype` option (two-sided vs one-sided lower-bound-only), wired
    to
    [`kappaSize::CIBinary`](https://rdrr.io/pkg/kappaSize/man/CIBinary.html)/`CI3Cats`/`CI4Cats`/`CI5Cats`,
    with a UI ComboBox that disables the upper-limit input in one-sided
    mode
  - New plain-language `text_summary` output (CI type, lower limit,
    precision width)

- **`kappasizefixedn()` / `kappasizepower()`**: New plain-language
  `text_summary` output panel

- **[`nogoldstandard()`](https://www.serdarbalci.com/meddecide/reference/nogoldstandard.md)**:
  New `notices` panel (“Important Information”) with plain-text notice
  rendering that resets on each run

- **[`decisioncalculator()`](https://www.serdarbalci.com/meddecide/reference/decisioncalculator.md)**:
  Sensitivity/specificity confidence intervals now use a logit
  transformation with continuity correction
  (`sens_se = sqrt(1/TP + 1/FN)`, `spec_se = sqrt(1/TN + 1/FP)`) when a
  zero cell is present — consistent with the existing PPV/NPV CI logic —
  falling back to exact Clopper-Pearson binomial CIs otherwise

### Package Infrastructure

- Version bumped 0.0.32.69 → 0.0.46; release date 2026-07-04; minimum
  jamovi app raised to 2.7.27 (`minApp`)
- New Imports: `ggraph`, `grDevices`, `graphics`, `htmltools`, `igraph`,
  `irrCAC`, `knitr`, `stats`, `tibble`, `tools`
  (`irrCAC`/`stats`/`psych` back the new chance-corrected, clustering,
  and ICC agreement measures; `ggraph`/`igraph` back the reimplemented
  `decisiongraph` tree visualization;
  `htmltools`/`knitr`/`tibble`/`tools`/`grDevices`/`graphics` support
  HTML output and plotting)
- Switched documentation config to `Config/roxygen2/version: 8.0.0`
- New shared helper files: `R/diagnostichelpers.R` (reusable
  sensitivity/specificity/PPV/NPV helpers) and `R/error_handling.R`
  (clinical error-handling framework: `clinicopath_init`,
  `clinicopath_error_handler`)
- Added `.escapeVariableNames` and refactored/hardened existing
  `R/utils.R` helpers (`%notin%`/`%!in%` rewritten as explicit
  functions, `load_required_package` default flipped to
  `install_if_missing = FALSE`, `print.sensSpecTable` given an
  S3-compliant `(x, ...)` signature)
- `R/decisiongraph_utils.R`: decision-tree visualization reimplemented
  as a real `igraph`/`ggraph` dendrogram renderer
  (`graph_from_data_frame`,
  [`ggraph::geom_edge_diagonal`](https://ggraph.data-imaginist.com/reference/geom_edge_diagonal.html)/`geom_node_point`/`geom_node_label`,
  horizontal/vertical/radial layouts) replacing the “Not Yet
  Implemented” placeholder, plus removal of the hardcoded 0.7/0.2/0.1
  Markov transition-matrix stub (`decisiongraph` is a shipped utility,
  not a registered menu analysis)

### Data

- Removed five raw CSV files from `data/` (`cancer_biomarker_data.csv`,
  `cardiac_troponin_data.csv`, `dca_test_data.csv`,
  `sepsis_biomarker_data.csv`, `thyroid_function_data.csv`)
- Added roxygen dataset documentation in `R/data.R` for the packaged
  datasets (histopathology, Bayesian DCA, breast cancer, breast/lymphoma
  diagnostic-styles, thyroid function, and the
  cancer/cardiac/sepsis/thyroid diagnostic sets plus the combined master
  collection)

### Minor Changes

- Module-wide label cleanup: replaced “%” with “percent” and removed
  emojis across
  [`decision()`](https://www.serdarbalci.com/meddecide/reference/decision.md),
  [`decisioncalculator()`](https://www.serdarbalci.com/meddecide/reference/decisioncalculator.md),
  [`decisioncompare()`](https://www.serdarbalci.com/meddecide/reference/decisioncompare.md),
  [`decisioncombine()`](https://www.serdarbalci.com/meddecide/reference/decisioncombine.md),
  [`cotest()`](https://www.serdarbalci.com/meddecide/reference/cotest.md),
  and
  [`sequentialtests()`](https://www.serdarbalci.com/meddecide/reference/sequentialtests.md)
  labels and descriptions (for
  [`decisioncalculator()`](https://www.serdarbalci.com/meddecide/reference/decisioncalculator.md)
  this covers the label/emoji changes only; the CI methodology change is
  documented under Enhanced Existing Functions above).
  [`decisioncombine()`](https://www.serdarbalci.com/meddecide/reference/decisioncombine.md)
  also gained `allowNone: true` on its Test 3 positive-level option and
  had its example `dontrun` flag flipped to `true`
- Version strings synchronized to 0.0.46 across DESCRIPTION and all
  jamovi analysis definitions

------------------------------------------------------------------------

## meddecide 0.0.32.69 (2026-01-02)

### New Features

- **[`bootstrapNRI()`](https://www.serdarbalci.com/meddecide/reference/bootstrapNRI.md)**:
  Exported bootstrapNRI function for Net Reclassification Improvement
  (NRI) bootstrap confidence interval estimation
  - Enables direct access to NRI bootstrap analysis
  - Provides robust confidence intervals for categorical and continuous
    NRI
  - Supports custom thresholds for risk category definitions
  - Configurable bootstrap iterations and confidence levels

### Bug Fixes

- Fixed critical bug in
  [`computeNRI()`](https://www.serdarbalci.com/meddecide/reference/computeNRI.md)
  where risk category labels were incorrectly calculated
  - Corrected the labels vector calculation from `1:length(breaks - 1)`
    to `1:(length(breaks) - 1)`
  - This fix ensures proper risk categorization in NRI calculations
  - Affects categorical NRI computations in ROC and psychoPDA analyses
- **[`agreement()`](https://www.serdarbalci.com/meddecide/reference/agreement.md)**:
  Fixed stability issues and hanging during initial run
  - Refactored `agreement.b.R` to ensure responsiveness
  - Maintained support for numeric variables in agreement analysis

### Minor Changes

- Updated package version to 0.0.32.69
- Synchronized version across DESCRIPTION and jamovi module files
  (jamovi/0000.yaml)

------------------------------------------------------------------------

## meddecide 0.0.31.84 (2025-10-03)

### Major Changes

#### New Analysis Functions

- **[`decisioncombine()`](https://www.serdarbalci.com/meddecide/reference/decisioncombine.md)**:
  New function for systematic evaluation of diagnostic test combinations
  - Analyzes all possible test result patterns (2-test: 4 patterns,
    3-test: 8 patterns)
  - Calculates sensitivity, specificity, PPV, NPV, and accuracy for each
    pattern combination
  - Identifies optimal testing strategies based on Youden’s J index
  - Includes visualization options: bar charts, heatmaps, forest plots,
    and decision trees
  - Supports filtering by statistic type and pattern type
  - Can add test pattern column to dataset for further analysis
- **[`cotest()`](https://www.serdarbalci.com/meddecide/reference/cotest.md)**:
  New function for analyzing combined results of two concurrent
  diagnostic tests
  - Calculates post-test probabilities for various scenarios (either
    positive, both positive, both negative)
  - Supports both parallel and serial testing strategies
  - Provides Fagan nomogram visualizations
- **[`sequentialtests()`](https://www.serdarbalci.com/meddecide/reference/sequentialtests.md)**:
  New function for sequential testing analysis
  - Analyzes how diagnostic accuracy changes when applying two tests in
    sequence
  - Compares three different testing strategies: serial positive
    (confirmation), serial negative (exclusion), and parallel testing
  - Provides comprehensive analysis including population flow, cost
    implications, and Fagan nomograms
- **[`decisioncalculator()`](https://www.serdarbalci.com/meddecide/reference/decisioncalculator.md)**:
  New calculator for diagnostic test evaluation
  - Designed for when you have the four key counts: TP, FP, TN, FN
  - Calculates comprehensive diagnostic performance metrics
  - Supports confidence interval estimation and Fagan nomogram
    visualization

#### Enhanced Existing Functions

- **[`decisioncompare()`](https://www.serdarbalci.com/meddecide/reference/decisioncompare.md)**:
  Major improvements to test comparison functionality
  - Enhanced comparison plots (bar charts and radar plots)
  - Added statistical comparison using McNemar’s test
  - New summary and explanation options for better interpretation
  - Added manuscript-ready report sentence generation
  - Improved handling of custom prevalence settings
  - Better visualization of confidence intervals for metric differences

#### Removed Features

- **`decisionpanel()`**: Function removed for future redesign
  - Users should use
    [`decisioncombine()`](https://www.serdarbalci.com/meddecide/reference/decisioncombine.md)
    and
    [`decisioncompare()`](https://www.serdarbalci.com/meddecide/reference/decisioncompare.md)
    instead
  - These new functions provide more focused and comprehensive analysis

### Menu Organization

- Reorganized jamovi menu structure for better user experience
  - **Decision**: Core diagnostic test evaluation functions
  - **Decision Calculators**: Calculator-based tools for specific
    scenarios
  - **ROC**: ROC curve analysis functions
  - **Agreement**: Interrater reliability functions
  - **Power Analysis**: Sample size calculation functions

### Minor Changes

- Updated
  [`agreement()`](https://www.serdarbalci.com/meddecide/reference/agreement.md)
  function with improvements to reliability assessment
- Enhanced documentation across all functions
- Improved error handling and validation
- Updated example datasets and usage examples

### Bug Fixes

- Fixed various edge cases in diagnostic metric calculations
- Improved handling of missing data
- Enhanced validation of input parameters

------------------------------------------------------------------------

## meddecide 0.0.31 (2025-09-18)

### Package Updates

- Version synchronization across DESCRIPTION and jamovi module
- Updated package metadata and author information
- Enhanced package description with comprehensive feature list

### Documentation

- Improved function documentation with clearer examples
- Updated pkgdown website structure
- Added more detailed usage examples for main functions

------------------------------------------------------------------------

## meddecide 0.0.3.91

### New Features

- Initial implementation of test comparison framework
- Added support for Fleiss’ Kappa with differentiated method names
- Enhanced Kappa calculation methods

### Bug Fixes

- Fixed issues with exact Kappa calculations
- Improved handling of multiple rater scenarios

------------------------------------------------------------------------

## meddecide 0.0.3.90

### Initial Release Features

- Basic diagnostic test evaluation functions
- ROC analysis capabilities
- Interrater reliability assessment (Cohen’s Kappa, Fleiss’ Kappa)
- Sample size calculations for reliability studies
- Visualization tools including Fagan nomograms
- jamovi module integration
