# meddecide (development version)

No statistic changes. Saved analyses open as before, except that the two ranges below return to
their defaults (see the R note).

- **Tables instead of HTML.** Advanced ROC Analysis shows its confusion matrices as tables (rows:
  the decision at the cutpoint; columns: the selected positive and negative levels). Compare
  Medical Decision Tests shows its original data as two tables: reference-standard counts, and
  each test against the reference levels. The LASSO Logistic Regression suitability check is a
  table whose status column says "No concern", "Marginal" or "Major concern" in words. The
  bordered summary grids in the Medical Decision Calculator and in Interrater Reliability are
  gone; those numbers are in their tables. All of them now follow your number format and copy into
  a spreadsheet as cells.
- **Results stay in place when an input is invalid.** jamovi greys them and shows the error over
  them; panels no longer vanish or go blank while you type through an invalid value.
- **Tables keep their shape while computing.** Comparison, agreement, McNemar and difference
  tables in Compare Medical Decision Tests, the combination tables in Combine Medical Decision
  Tests and the workload table in the Medical Decision Calculator show their rows from the start.
  A pair of tests that cannot be compared, and Cochran's Q when it is undefined, now keep their
  row and say "Not computed".
- **Variables first.** In Interrater Reliability and Decision Curve Analysis every variable box is
  in the top variable list, greyed until the analysis that uses it is ticked. In Medical Decision
  and Compare Medical Decision Tests the variables come before the reference-interpretation box.
- **Choose, don't type, the negative reference level** in Clinical ROC Analysis' frozen-model
  validation: it is now a level list. In Interrater Reliability the positive category is still
  typed, and an extra space or different capitalization no longer stops it matching.
- **R users:** `enhancedROC()` now has a required argument `validationNegative`, like
  `positiveClass`. Pass `validationNegative = NULL` unless you use the frozen-model report.
- **Clinical presets show what they override.** In Clinical ROC Analysis, choosing a clinical
  preset greys Youden index optimization and, except for Research, the minimum sensitivity and
  specificity boxes, since the preset sets them.
- **Panels grouped by the question you are asking.** Interrater Reliability's 38 option boxes are
  now nine: General Options, Categorical, Ordinal, Continuous, Any Data Type, Tests, Rater and
  Case Diagnostics, Computed Variables and Study Design, each method under its own heading. The
  shared settings (exact kappa, multiple-testing correction, number of bootstrap samples) are in
  General Options. Combine Medical Decision Tests splits its display options into Tables, Rule
  Ranking, Plots (with the plot filters) and Save to Data. In Clinical ROC Analysis the analysis
  settings are in their own box, each heading holds the options under it, and the cost ratio sits
  under the cutpoint method that uses it. Co-Testing Analysis' display options are a collapsed box.
  Nothing is computed differently, and saved analyses keep their settings.
- **Interrater Reliability results are grouped under their section headings.** Each heading and
  its tables form one group that shows only when something in it is shown, so the empty heading
  lines are gone from the output and from copies and exports. Results saved in an older file are
  recomputed when it is opened.
- **Name the prediction rater** in Interrater Reliability's multi-annotator concordance, in a
  variable box, instead of typing its position in the Raters list. It must also be one of the
  raters. The "Standardize quantitative ratings" box is gone, as it never changed single-variable
  iota.
- **R users:** in `agreement()`, `predictionColumn = 1` is now `predictionRater = "<column>"`.
  Results that sat under a heading are one level down, for example
  `result$krippTableGroup$krippTable`.
- **Clinical ROC Analysis** no longer offers "Explain why within-cohort meta-analysis is
  unavailable"; the option remains for saved analyses and R calls.
- **Clinical ROC Analysis plots follow jamovi's theme.** Plot theme has a new first choice,
  "jamovi (follow global)", which is now the default, so these plots match the rest of the
  document. Classic, Modern and Clinical (the previous default) are still there to override it.
- **A more precise verification-bias caution** in Combine Medical Decision Tests: when the
  reference standard was obtained only after a positive test, sensitivity, specificity and the
  predictive values of single tests and combined rules can be biased, but an exact result
  pattern's predictive values are not, if verification depended only on that pattern.
- **Worked examples name their tests in your language.** In Co-Testing Analysis, the test names a
  worked example puts in the name boxes are shown translated in the tables and summary; a name you
  type yourself is kept as typed.
- **Fagan nomograms follow jamovi's colors and name their lines.** In Medical Decision, the Medical
  Decision Calculator and Co-Testing Analysis, the two lines now use the palette chosen in jamovi,
  and a legend says which is the positive result and which the negative. "Fagan line colors" ->
  "Red / blue (classic)" brings back the old red and blue.
- **Predictor names that start with "<" show in Clinical ROC Analysis tables.** A variable named,
  for example, "<LOD flag" appeared as a blank cell in 18 tables; it now shows as "< LOD flag".
- **Sample-size numbers follow your number format.** Interrater Reliability's Sample Size for
  Agreement Study table now holds its values as numbers rather than text formatted in R; the
  agreement metric is named in its first row.
- **One label style.** Variable boxes and result titles are in title case; options and list
  choices in sentence case. Youden's index has one name (columns: "Youden's J"); "95% confidence
  intervals" reads the same in Medical Decision, the Medical Decision Calculator and Compare
  Medical Decision Tests; and two options that shared a title now have their own ("Known
  population prevalence" and "Population disease prevalence"; "Bootstrap interval for
  Krippendorff's alpha"). The kappa sample-size labels and their messages name the inputs one way: κ₀, κ₁, κL and κU instead of the R argument names in the CI and power analyses, and "the anticipated kappa" in the fixed-sample analysis, the prevalence
  box gives its real range (between 0 and 1), Interrater Reliability's percent boxes show "%",
  and its method headings use one style of brackets. Clinical ROC Analysis says "cutoff"
  throughout. Only labels changed: saved analyses and R calls work as before.
- **Validation context boxes greyed when unused.** In Medical Decision, cohort role, sampling
  design, threshold source, model version and unit of observation are greyed until Validation
  context is ticked, as they already were in Compare Medical Decision Tests.
- **Ranges as number boxes.** Clinical ROC Analysis' partial AUC range is two boxes, Partial AUC
  from and to, and Advanced ROC Analysis' treatment threshold range is three, from, to and step;
  each box checks its own value. A saved analysis that used another range returns to the defaults
  (0.8 to 1, and 0.05 to 0.50 in steps of 0.05). Lists of any length, such as cutoffs and target
  prevalences, stay as comma-separated text.
- **R users:** in `enhancedROC()`, `partialRange = "0.8,1.0"` is now `partialAucFrom = 0.8,
  partialAucTo = 1`; in `psychopdaROC()`, `treatmentThreshold = "0.05,0.5,0.05"` is now
  `treatmentThresholdMin`, `treatmentThresholdMax` and `treatmentThresholdStep`.
- **Notices say how serious they are in words** in Compare Medical Decision Tests, Decision Curve
  Analysis and the three kappa sample-size analyses, not by colour alone. An invalid input is
  reported once, as the analysis error, in Advanced ROC Analysis and LASSO Logistic Regression.
  Interrater Reliability no longer repeats its "kappa not computed for continuous ratings" note in
  a second panel, and its computed-variables message is translated.
- **A sub-analysis that cannot run says so at the top.** In Interrater Reliability, an optional
  analysis that cannot be computed (rater clustering with two raters, Bland-Altman with fewer than
  three complete pairs, and so on) raises a warning naming it above the results, instead of a
  footnote under its empty table.
- **Help only when it helps.** Co-Testing Analysis no longer shows its guidance panel by default
  (tick Guidance and explanations to see it), and Clinical ROC Analysis shows its instructions
  only until an outcome and a predictor are chosen.
- **Smaller saved files.** Interrater Reliability's rater-profile plot keeps the category counts
  it draws, not every rating, and Advanced ROC Analysis' dot plot stores its threshold and labels
  once; analyses saved earlier still open and draw as before.
- **Severity labels in sentence case.** Notices start with "Error:", "Strong warning:", "Warning:"
  or "Info:" instead of capitals, and the confusion-matrix headers in ROC analysis read "Decision
  based on measure" and "Criterion".
- **American spelling throughout** (analyzed, modeled, color, behavior, center, favor). The Turkish
  translations follow.
- **Repository:** a personal settings file is no longer tracked.

# meddecide 1.1.2 (2026-10-23)

- **Example dataset update:** replaced the no-gold-standard Data Library entry for pathologist
  readings with `nogoldstandard_validation.omv`: 190 simulated patients, three imperfect binary
  diagnostic tests, a GUI-configured latent-class analysis, 1,000 bootstrap refits,
  95% confidence intervals, seed 42, diagnostics, a summary and a teaching annotation.
  Neither reference test is treated as a gold standard. The example is not clinical validation.
- **Documentation:** a worked example for the no-gold-standard analysis, and updated Turkish
  translations.

# meddecide 1.1.1 (2026-10-21)

Independent-review corrections (2026-10-21):

- psychopdaROC: IDI and NRI no longer replace a marker whose risk runs against the
  Classification Direction with a constant base rate, which could flip their sign (a
  stronger "lower = disease" reference read as the weaker marker). Both risk models are
  fitted freely, and a table note names any marker whose association runs against the
  selected direction.
- Zero cells (decision, decisioncalculator, decisioncompare, decisioncombine): one shared
  rule. LR+, LR- and the diagnostic odds ratio are 0.5-corrected only when their denominator
  cell is empty; an empty numerator gives an exact 0 with no log-scale interval; a ratio
  whose correction would not stay above 1, or 0/0, is left blank. Previously TP = 0 could
  print LR+ 3.06. A ratio of exactly 0 shows the interval [0, U], U from the 0.5-corrected
  log-scale interval, so a perfect small study does not read as certain. Fagan nomograms are
  not drawn for a zero or blank likelihood ratio.
- enhancedROC: calibration, Brier, Hosmer-Lemeshow, decision and clinical impact curves
  use the fitted risk model when its slope runs against Direction, with a warning, instead
  of a silent constant-prevalence model. The analysis is rejected when no predictor can be
  analysed, and the AUC interval method is always named.
- decision: the negative-level boxes start at None, so jamovi no longer pre-selects the
  first level (with three levels it could take "Equivocal" as negative). A variable with
  several candidate negatives waits for the choice; an inferred negative is shown.
- decisioncompare: when tests were done on different cases, the best-test sentence ranks
  them on the cases common to all; the prevalence sentence names its denominator; an empty
  level box is an information notice, not an error.
- nogoldstandard: the penalized EM method now shows bivariate residuals and the dependence
  warning; three-test models carry a warning that dependence cannot be checked.
  The vignette runs and describes complete-case handling and the fixed priors.
- Stale results: notices are cleared when a re-run has nothing to report (cotest, decision,
  decisioncombine), and kappaSizeCI no longer leaves the previous sample size under an
  error. Undefined cells in decisioncombine are blank instead of "NaN".
- Plot text no longer runs off the edge at the default size: the cotest Fagan caption (which
  hid its "not for clinical use" disclaimer), two decisioncurve captions, and the enhancedROC
  clinical-utility legend and CROC caption.
- Wording made accurate: agreement 3+ rater subgroup intervals (Gwet SE, t) and minimum-case
  rule; kappaSize methodology and governing-limit statements; decisioncurve "range of
  benefit" (observed, in-sample) and case-control notice; lassologistic optimism-corrected
  AUC; sequentialtests conditional-independence formulas; rare priors print with enough
  digits; psychopdaROC tie, fixed-sensitivity and unit-cost notes.
- Turkish translations added for the new and reworded messages.

Earlier 1.1.1 corrections:

- Fix full-response serialization when citation pages are numeric in YAML.
- Report 0% categorical unanimity correctly for valid complete disagreement.
- Correct the explanation of selective zero-cell likelihood-ratio corrections;
  estimates and interval methods are unchanged.
- Add regressions for citation types, zero unanimity and correction explanations.
- Retain epiR and its calculations. pander declares AGPL-3 or the OSL-3.0 in its
  LICENSE file; library acceptance can be discussed with the jamovi team if needed.

# meddecide 1.1.0 (2026-10-20)

- Packages the medical-decision, ROC, agreement and kappa-planning analyses at
  version 1.1.0. The statistical and interpretation changes since 1.0.81 are
  documented in the 1.0.9 notes below.
- Adds installed-package decision and ROC-wrapper regression checks with
  synthetic, reproducible fixtures and testthat edition 3.

The earlier 1.1.0 archive is superseded by the 1.1.1 candidate. Local checks and
library submission status are recorded separately in the release preparation report.

# meddecide 1.0.9 (2026-10-17)

The analyses were validated against independent calculations and then independently reviewed.
Much of what follows changes a number, label or verdict you may have reported, so behaviour changes
come first; a saved `.omv` keeps its old results until you re-run it. This is the first release
since 1.0.81, and it also contains the 1.0.83.03 changes below, never released on their own.

## Behaviour changes -- saved analyses may produce different results

### Across the module

- **The positive (event) level is no longer filled in for you.** jamovi used to pre-select the
  outcome's first level, usually the negative one ("No", "0", "Benign"), so a new analysis could
  compute everything for the wrong event. In Clinical ROC Analysis, Advanced ROC Analysis, Compare
  Medical Decision Tests, Analysis Without Gold Standard, Decision Curve Analysis and LASSO Logistic
  Regression the level boxes now start empty, and the analysis waits until you choose. A saved
  analysis keeps the level it was saved with: check it when you reopen the file.
- **Out-of-range entries are reported, not silently replaced.** In Co-Testing Analysis and
  Sequential Testing Analysis, typing `80` for an 80% sensitivity was quietly changed to 0.99 and
  the analysis ran on that value. It now tells you the entry is out of range.

### Interrater Reliability (`agreement`)

- **Kappa for three or more raters uses every observed rating.** One missing reading used to drop
  the whole case. Fleiss' and Conger's kappa now keep the other readers' ratings and add a standard
  error, interval and p-value; values are unchanged on complete data.
- **Weighted kappa keeps the grade order** when raters used different grades: G1/G2/G4 for one rater
  and G1/G2/G3 for another built the scale G1, G2, G4, G3 (0.370 instead of 0.213). All pairs,
  subgroups and institutions now share one scale.
- **Stuart-Maxwell and Bhapkar use the full table.** Dropping categories both raters used equally
  often could give chi-squared = 4.00, p = 0.046 where the correct test gives 0.145, p = 0.930.
- **Other coefficients:** Krippendorff's alpha is exact for 3+ raters with complete data (0.4355
  becomes 0.4374); Lin's CCC uses every case both raters scored; Gwet's AC p-value is always
  two-sided; macro-averaged F1 counts never-matched classes (0.81 becomes 0.54). The multi-centre
  ICC is estimated within institution; its G-coefficient row and "Shrinkage estimates" are removed.
- **Labels and verdicts.** Robinson's A and Kendall's W are graded on chance-corrected values (46%
  of pairs of independent raters had read "Moderate agreement"); every table uses one name per
  coefficient; Light's kappa loses a p-value that was not valid; Iota is titled "single variable",
  since it never was the multivariate index the guide described (its value is unchanged).
- **Rater clustering groups readers by agreement.** The default distance is now Concordance (1 -
  Lin's CCC); the old correlation distance ignores a constant offset, so a reader who read 25 points
  high was clustered with the accurate readers. Analyses that never set the metric will re-cluster.

### Medical Decision (`decision`)

- **Levels other than the two you select are excluded, never counted as negative.** With 40 Benign
  (35 test-negative) and 10 Equivocal (all test-positive) cases, specificity read 70.0% instead of
  87.5%. Excluded cases are counted in the notices and the copy-ready paragraph.
- **Only the likelihood ratio with the zero cell is continuity-corrected:** TP 20, FP 2, FN 0, TN 19
  keeps its observed LR+ of 10.5 ("large") instead of 8.59 ("moderate").
- **Youden's index has an Agresti-Caffo interval** (the old one covered about 99.7% under a 95%
  label). Likelihood ratios use one band in every panel, and "worse than chance" is an error only
  when the Youden interval lies wholly below 0.

### Compare Medical Decision Tests (`decisioncompare`)

- **Positive and negative levels must be chosen for the reference and every test.** Any other
  observed level stops the analysis unless **Exclude other observed levels** is ticked, and a new
  table shows the levels used and excluded. Saved analyses that relied on an implicit negative
  level must select one to re-run.
- **Pairwise p-values come from the McNemar mid-p test** (Fagerland, Lydersen & Laake 2013) instead
  of the exact or continuity-corrected test. P-values are smaller: with 6 and 16 discordant pairs,
  0.052 becomes 0.035. A new **McNemar Test** option offers the asymptotic test without correction.
- **The text names the test each significant comparison favours.** It used to name the test with
  the highest balanced accuracy beside "a significant difference" even when that test was
  significantly less accurate (95%/70% against 60%/97.5% at 20% prevalence). Sensitivity and
  specificity get their own p-values in the Differences table.
- **A 0/0 likelihood ratio is blank, not invented:** a test that never called positive got a finite
  LR+ labelled "Moderate" or "Strong".

### Combine Medical Decision Tests (`decisioncombine`)

- **Each test alone is now a row and a candidate in the ranking.** A strong test (0.90/0.90) with a
  weak one (0.60) used to give combinations tied at Youden's J 0.50 while Test 1 alone, at 0.80,
  appeared nowhere. With three tests every pair also gets Parallel and Serial rows (11 rows become
  20).
- **"Positive Levels May Be Inverted" checks each test** and fires only when its Youden's J is below
  0 beyond sampling variation. Heatmap colours for the ratios use a log scale centred on 1.

### Decision Curve Analysis (`decisioncurve`)

- **Curve points sit exactly on the thresholds the axis shows.** Rounding had put the points
  labelled 6, 12, 15, 21 and 22% a hair above them, so patients at the threshold counted differently
  in plot and table. The clinical decision rule now enters both comparison tables, which changes the
  Holm-adjusted p-values when there are several models.
- **Removed:** the "Net benefit confidence intervals" checkbox, a duplicate of "Bootstrap confidence
  intervals" (a saved analysis that ticked only it reopens without ribbons), and the "Conclusion"
  column of the exploratory pairwise table. The Clinical Interpretation panel is opt-in.

### LASSO Logistic Regression (`lassologistic`)

- **The event level is never guessed.** jamovi took the outcome's first level and R the second, so
  the same data gave inverted odds ratios. A numeric 0/1 outcome still reads 1 as the event.
- **Standardization is repeated inside every cross-validation fold and bootstrap fit**, so lambda,
  coefficients and validation estimates can change.
- **The default scoring method is Max-scaled.** "Schneeweiss" was not Schneeweiss's method and is
  renamed "Smallest-contribution units" (on the bundled example it gave a -23 to 120 point scale).
  Ordinal predictors get one indicator per level, ending rules such as "grade.L > 0".

### Clinical ROC Analysis (`enhancedROC`) and Advanced ROC Analysis (`psychopdaROC`)

- **AUC-PR is the interpolated precision-recall area in both**, not the trapezoid that overstated
  tied scores (a constant marker at 10% prevalence reported 0.55, not 0.10).
- **Advanced ROC Analysis needs both a Positive Class and a Negative Class**; saved analyses must
  select the Negative Class to re-run. Single-AUC intervals use logit DeLong by default, paired
  DeLong comparisons add Holm-adjusted p-values, and power tests each marker against AUC 0.5 however
  many markers are selected (a duplicate marker had raised one example from 12.1% to 99.98% power).
- **Clinical ROC Analysis separates fixed score cutoffs, target prevalence and utility thresholds**
  in its impact analysis, so re-enter the intended cutoffs in saved impact analyses. "Stratified
  bootstrap" now also governs the comparison test and confidence bands. Table notes, the Analysis
  summary and the Report sentences are opt-in.

### Analysis Without Gold Standard (`nogoldstandard`)

- **Penalized EM estimates can change.** The fit now starts from several points and is refined
  numerically, instead of one EM pass clipped to 0.1%-99.9%.
- **Unreliable latent estimates are blank, not shown with a caveat.** A fit that does not converge,
  is not identified, or cannot tell its two classes apart ("Class orientation is ambiguous") leaves
  prevalence, sensitivities and specificities blank with a strong warning. Bootstrap intervals with
  fewer than 20 usable resamples are blank and can otherwise be wider than before; a rare test's
  interval can now reach 0%; with three tests the dependence check reads "Not assessable".

### Kappa sample-size analyses (`kappaSizeCI`, `kappaSizePower`, `kappaSizeFixedN`)

- **Confidence Interval Approach for the Number of Subjects Required (`kappaSizeCI`): larger n for
  most designs with 3+ raters or 3-5 categories.** At the published n, the interval the study should
  report covered kappa only 91-93% of the time. Rotondi & Donner's own example now needs 190
  subjects, not 171 (147, not 110, with 6 raters); a binary outcome with two raters is unchanged.
  The n is the exact minimum, shown with its arithmetic (3.84146 / 0.032634, rounded up, = 118).
- **Power Approach for the Number of Subjects Required (`kappaSizePower`): binary designs are
  checked by simulation.** When the recommended test falls more than 0.03 short of the stated power,
  the result names both figures: 6 raters, a 5% finding, kappa0 0.40 against 0.60 and power 0.80
  need 316 subjects by the published formula and about 572 by simulation (316 give about 0.59). The
  "0 subjects" result for 5-6 raters and a finding at or below 0.1% (181,129 needed) is fixed.
- **Lowest Expected Kappa for a Fixed Sample Size (`kappaSizeFixedN`, formerly "Lowest Expected
  Value for a fixed sample size"):** the bound is solved exactly and rounded down (0.419 at the
  defaults, where kappaSize gives 0.418). With 3+ raters or categories it allows for re-estimating
  the proportions: 3 raters, kappa0 0.60, prevalence 0.30 and 60 subjects give 0.443 (was 0.445).
  With fewer than one expected subject per rater in the rarest category it no longer claims the
  study "can show that agreement exceeds chance".
- In all three, the "Sparse categories" check judges the cells the test actually uses (19 of 40
  designs had been flagged spuriously in `kappaSizeCI`).

### Medical Decision Calculator (`decisioncalculator`)

- **A test that was never positive no longer gets a likelihood ratio.** TP 0, FP 0, FN 10, TN 100
  showed LR+ 9.18 (a function of the group sizes alone) and a nomogram promising a rise from 9.1% to
  47.9%; the cell is now blank with a note. "Post-test Reference-negative Probability", which
  repeated the NPV, is replaced by the probability of disease after a negative test (1 - NPV).
- **The illustrative cut-off comparison ranks on the Youden index intervals** (a scenario with
  accuracy 0.595 could be called clearly better than one with 0.941), and its scenarios must share
  the same numbers of reference positives and negatives.

## New features

- **Interrater Reliability (`agreement`): Pathologist Grading Analysis.** For grades, keeping cases
  some pathologists did not read: grade use per pathologist, agreement with colleagues at each
  grade boundary, each pathologist's grading tendency with a forest plot, and model-based agreement
  (latent ICC and kappa, Nelson & Edwards 2015). Model-based numbers appear only in designs where
  simulation showed them accurate (for example from 50 cases and 3 pathologists); otherwise a note
  says why.
- **`agreement`, also:** multi-centre analysis of categorical ratings with a stratified kappa; a
  Case ID so the mixed-effects comparison compares each case with itself; a Kappa interval method
  option (Wald or Fisher z); an exploratory patient-level bootstrap for specific agreement.
- **Medical Decision (`decision`) and Compare Medical Decision Tests (`decisioncompare`): say what
  the reference is.** Against an expert consensus or a comparative method the output reports
  positive and negative percent agreement, with comparator tables and plots, and leaves out
  disease-risk figures such as PPV. An optional Validation context table records the cohort,
  sampling design, threshold source, model version and unit of observation.
- **Combine Medical Decision Tests (`decisioncombine`):** a "Combination Rules vs Each Test Alone"
  table; Youden's J with an interval, optionally corrected for picking the best rule on the same
  data; a notice when results are missing because of another result (reflex testing, partial
  verification), which biases every complete-case row. Notices now appear at the top.
- **Medical Decision Calculator (`decisioncalculator`): observed and projected workload** -- flags
  per 1000 tested and tests per detected positive at target prevalences (default 0.01%, 0.1%, 1%).
  Prevalences below 0.1% are accepted here and in Compare Medical Decision Tests.
- **Clinical ROC Analysis (`enhancedROC`): frozen-model validation report** with reference mapping,
  patient-level bootstrap intervals, paired score comparisons and workload at rare prevalences.
- **Advanced ROC Analysis (`psychopdaROC`):** a Patient ID with mean or median summaries for
  repeated measurements. **LASSO Logistic Regression (`lassologistic`):** an optional patient ID.
- **Analysis Without Gold Standard (`nogoldstandard`):** PPV and NPV have confidence intervals; a
  warning says when categories other than the positive level (equivocal too) count as negative.
- **Decision Curve Analysis (`decisioncurve`):** warnings for values that run opposite to the
  positive level, fewer than 25 patients without the outcome, and thresholds with fewer than 10
  positive classifications.
- **Kappa sample-size analyses:** the Notes name the model and test each number rests on; new
  warnings flag a rare category, a small sample and (fixed sample) a design that cannot support a
  reliability claim. The step-by-step explanation and kappaSize's own summary are optional in the
  CI and fixed-sample analyses.

## Fixes

- **`agreement`:** "Benjamini-Hochberg (FDR)" in the mixed-effects comparison stopped the analysis;
  notes and numbers no longer carry over into the next run; interval columns follow the confidence
  level you chose; "ER+" and "ER-" are no longer merged; long runs can be cancelled.
- **`decision`:** the nomogram's negative-result line no longer vanishes at low prevalence; levels
  such as `<LOD` display. **`decisioncompare`:** paired differences no longer fail on a few hundred
  cases or more; copy-ready text prints "p < 0.001" and names the tests and intervals used.
- **`decisioncombine`:** no longer stops on large samples (about 93,000 cases) with a few missing
  values; a test column named like an internal working column is no longer silently replaced.
- **`decisioncurve`:** bootstrap intervals are about 17 times faster with identical results;
  undefined cells are blank with a footnote instead of "." or "NaN"; impact bars are colour-blind
  safe.
- **`decisioncalculator`:** studies of more than about 430 cases (for example 180/20/30/270) no
  longer stop with an error; blank cells no longer show "NaN".
- **Co-Testing Analysis (`cotest`):** the numbers were right but several sentences were not. The
  copy-ready summary now leads with the co-testing rule's own result, a positive on either test
  (42.5% at the defaults; only both-positive, 89.1%, was given). Magnitude words follow the
  likelihood ratio (a rise from 92% to 99.9% had read "minimal change"), and an impossible result
  combination is footnoted instead of showing "NaN".
- **Sequential Testing Analysis (`sequentialtests`):** the test-order warning is replaced by a note
  that appears only when swapping the tests would save second tests (order never changes the
  combined figures); each test's PPV and NPV are labelled as values for that test alone; cells that
  round to 100.0% get a footnote with the real value; long test names wrap in the flow diagram.
- **`nogoldstandard`:** a test added without its positive level is named instead of silently
  dropped. **`psychopdaROC`:** numeric columns imported as Nominal keep their codes.
  **`enhancedROC`:** a minimum sensitivity or specificity no longer yields an infinite cutoff, and
  every resampled result shows its seed.

## Packaging and translations

- **Turkish:** 6,253 of the module's 6,304 texts are translated, up from 3,738 of 4,881 in
  1.0.83.03.
- A message containing its own placeholder could freeze jamovi's analysis engine, and a table
  emptied on a re-run could stop the analysis; neither can happen now.
- Syntax copied from the syntax pane quotes free-text fields safely, so it runs for names with
  quotes or spaces and cannot carry other code.
- `ordinal` is added to the install list (for the Pathologist Grading Analysis); `tibble` is
  dropped.

# meddecide 1.0.83.03 (2026-09-23)

This release is the result of an external review of the module. Most of it is
about results that did not survive leaving the screen.

* The meta-analysis forest plot in ROC analysis exported as a blank file, and
  came back empty when a saved `.omv` was reopened. It now draws from the data
  saved with the plot, so exporting and reopening give you the plot you saw.
  If the plot cannot be built, you now get an explanation instead of the plot
  silently disappearing.
* ROC curve overlays (confidence bands, optimal-cutpoint markers, comparison
  curves) had the same problem and are fixed the same way.
* Tables and plots no longer redraw when you change an option that only affects
  appearance, so the results panel stops blinking as you adjust display settings.
* Analyses no longer leave a fixed random seed behind them. Previously, running
  one analysis that used resampling could make the *next* analysis in the same
  session draw from a fixed random stream.
* Interrater Reliability (`agreement`) is back in the module after a period
  out for testing, with the five packages it needs restored to the install list.
* Five packages that no analysis actually used were dropped, so installing the
  module pulls in less.
* `caret` is now cited by the analyses whose sensitivity, specificity, PPV and
  NPV figures it computes, so you can attribute those numbers.
* The Turkish and English translation catalogues were inherited from a much
  larger project and carried about 31,000 message IDs, most from analyses that
  are not in this module. They are now trimmed to this module's own text
  (roughly 4,000), which makes the download substantially smaller. Translatable
  sentences that were previously split into fragments (`"ERROR: "`,
  `", correlation adjustment = %.2f"`) are now whole sentences, which a
  translator can actually work with. Some existing Turkish translations were
  attached to the old fragments and will show in English until they are
  re-translated.
* The "Test method" control in Decision Curve Analysis offered a single choice;
  its label and description now say plainly that only the bootstrap is
  implemented.

# meddecide 1.0.81 (2026-09-09)

These notes were written after the release, which was published without a description. 1.0.81 was
the first release after 1.0.6, so it also delivered the 1.0.6.03 changes listed below.

## New analysis

- **Decision Curve Analysis (`decisioncurve`)** joins the meddecide menu. It compares the net
  benefit of predicted risks, or of a yes/no clinical rule, with treating everyone and treating no
  one across a range of threshold probabilities. It reports a Range of Benefit (the thresholds where
  a model beats both default strategies) rather than an "optimal threshold", which does not exist
  for net benefit. Model comparisons are bootstrapped with a fixed seed (default 42), so a re-run
  gives the same p-values, and are Holm-adjusted; intervals can be pointwise or a simultaneous band
  over the whole curve. The output states that net benefit is apparent, not optimism-corrected,
  when the risks were developed on the same data.

## Behaviour changes -- saved analyses may produce different results

- **Interrater Reliability (`agreement`): Robinson's A is now Robinson's (1957) coefficient.** The
  value shown before was Goodman-Kruskal's gamma, an association measure: two raters one grade
  apart on every case scored 1.0. It now comes with a bootstrap interval. The table headed
  "Maxwell's RE" did not compute Maxwell's statistic; it is now the "Rater Variance Decomposition",
  a two-way (case and rater) split of disagreement. The bootstrap ICC row follows the chosen ICC
  model, and paired-comparison intervals follow the confidence level.
- **Compare Medical Decision Tests (`decisioncompare`): tests with equivocal results on different
  cases stay aligned.** Paired comparisons could match one patient's result with another's. Each
  test's estimates now use its own determinate cases, and McNemar, Cochran's Q and the paired
  differences use the cases determinate on both, with the denominators shown. The "noninferiority
  margin", described as a regulatory convention, is now a descriptive "Minimum OPA criterion". The
  same test chosen twice, or the reference reused as a test, is rejected.
- **Lowest Expected Value for a fixed sample size (`kappaSizeFixedN`):** the anticipated kappa now
  defaults to 0.60 (the agreement you expect, as in the confidence-interval approach, not the 0.40
  null of the power approach) and is labelled "Anticipated kappa (kappa0)". A bound below the lowest
  agreement the model allows (for example -0.841 against a floor of -0.0004) is refused with an
  explanation instead of being printed. The description no longer states the bound backwards, and
  the estimand is named as the intraclass (Fleiss-type) kappa, not Cohen's.
- **Power Approach for the Number of Subjects Required (`kappaSizePower`):** the sparse-cell warning
  checks the agreement-pattern cells the method uses, not the category proportions: six raters at
  5% prevalence gave N = 316 with no warning while three of seven cells had expected counts below
  0.5. New warnings flag N below 10, power below 0.5, a kappa gap under 0.05 and N above 2000.
- **LASSO Logistic Regression (`lassologistic`):** the "Sullivan/D'Agostino" scoring method is
  renamed "Max-scaled"; a saved analysis that used it must select it again.
- **Clinical ROC Analysis (`enhancedROC`):** custom cutoffs under "lower is positive" follow pROC's
  rule for ties; with Youden optimisation off the cutoff is the point closest to the top-left
  corner; internal validation labels its interval honestly; one-vs-rest curves use one direction
  per marker.
- **Advanced ROC Analysis (`psychopdaROC`):** the power curve uses the table's Hanley-McNeil power,
  and the decision-curve plot uses the table's risk fit and prevalence; effect-size columns are
  labelled as differences.

## New features

- **Interrater Reliability (`agreement`):** "Case agreement categorization column" now adds the
  per-case agreement categories to your data (the option existed, but no column was added).
- **Co-Testing Analysis (`cotest`):** name fields for the two tests and a "Guidance and
  explanations" switch. **Combine Medical Decision Tests (`decisioncombine`):** an optional "About
  this analysis" panel; "Add Test Pattern to Data" is now a "Test pattern column" output, and the
  "Optimal Pattern Recommendation" is now a "Descriptive Candidate-Rule Ranking".
- **Analysis Without Gold Standard (`nogoldstandard`):** optional Plain-Language Summary and Method
  Guide; tables are retitled "Estimated Class or Rule Proportion" and "Estimated Test Metrics or
  Rule Agreement".

## Fixes

- **`psychopdaROC`:** re-running after ROC smoothing, an unselected positive class and a missing
  subgroup value no longer crash the analysis. **`enhancedROC`:** plots redraw after a saved file is
  reopened. **`sequentialtests`:** the explanation and formula panels show their numbers instead of
  `{placeholders}`. **`agreement`:** tables no longer duplicate rows on re-run, and weighted kappa
  on unordered categories stops with a clear message.

## Packaging and translations

- First Turkish translation catalogue, with partial coverage (see 1.0.83.03 above).
- `boot` and `splines` are added to the install list; `gridExtra` and `htmltools` are dropped.

# meddecide 1.0.6.03 (2026-08-22)

This release removes clinical advice from analysis output and corrects statistical statements that
were false as written. The module now describes what was measured and explains how to read it,
rather than issuing verdicts on whether a test is fit for patient care. Two defects produced a
wrong or misleading number on screen and are listed first.

## Behaviour changes -- saved analyses may produce different results

- **`decision`: the positive likelihood ratio no longer prints as 0.00 when specificity is 100%.**
  When a test produced no false positives, LR+ is infinite -- the strongest possible rule-in
  evidence. The Clinical Summary collapsed every non-finite value to zero and printed
  *"Positive LR: 0.00"*, which reads as the exact opposite: a positive result making disease
  infinitely less likely. Infinite and undefined values are now distinguished and labelled
  ("not estimable (specificity is 100% in this sample)"). The same collapse applied to LR-, where
  the non-finite case arises when specificity is 0%, and the message now names that condition
  correctly.

- **`decisioncompare`: predictive values are attributed to the prevalence actually used.** When the
  prior-probability option is on, PPV and NPV are computed by Bayes at the prevalence you supply,
  while overall accuracy stays at the prevalence of the sample. The copy-ready summary sentence
  asserted a single sample prevalence for all three, so a manuscript-ready sentence could carry the
  wrong prevalence for the predictive values. The sentence now branches on the option and states
  which prevalence each figure rests on.

- **`decisioncompare`: the best-performing test is described by the criterion actually used.** The
  summary said the winning test "had the highest observed accuracy", but the selection maximises
  the Youden index plus accuracy, so the winner need not be the most accurate test in the table.

## Changed -- results no longer give clinical advice

- **Recommendation columns now report performance instead of issuing verdicts.** In
  `decisioncalculator`, `psychopdaroc` and `enhancedroc`, columns titled *Clinical Recommendation*
  returned strings such as *"Excellent performance - Recommended"* and *"Suitable for clinical
  use"*, keyed on point estimates alone. They are retitled *Performance Summary* and now report the
  measured quantities, with the optimism made explicit where a cut-point was chosen on the same
  data that measured it. `sequentialtests`' *Clinical Guidance* panel is retitled *Testing Strategy
  Notes*.

- **`enhancedroc`: the AUC context column is populated for every setting.** The column was blank on
  every row under the default `general` context. It now explains the AUC in plain language for all
  contexts -- for example *"Ranks a random case above a random non-case 81% of the time"* -- and says
  where a conventional reference level exists and where none does.

## Fixed -- statements that were not true

- **`agreement`: non-significant tests no longer establish agreement.** The Stuart-Maxwell and
  Bhapkar tables reported *"marginal homogeneity holds"* and *"no systematic rater bias"* whenever
  p was at or above 0.05, stating the null hypothesis as established fact. Worked examples went
  further, concluding from p = 0.68 that a digital pathology platform yields *"equivalent"*
  distributions and is *"suitable for clinical use"*, and from p = 0.12 that two PD-L1 clones
  (22C3 and SP263) are interchangeable. These now report that no difference was detected and state
  plainly that this does not establish equivalence.

- **`agreement`: quantitative claims the module never computed have been removed.** The output
  asserted that confidence intervals overlap in a table that has no confidence-interval columns,
  and that a test had limited power where no power calculation exists. Kendall's W and Robinson's A
  examples claimed to validate treatment timing, credentialing and regulatory submissions from
  statistics that contain no outcome data at all.

- **`decisioncompare`, `cotest`, `nogoldstandard`:** non-significant comparisons no longer describe
  the tests as performing equally, and the McNemar note now explains that the test uses only the
  discordant pairs, so few discordant pairs mean little power.

- **`psychopdaroc`: AUC is described correctly.** An AUC of 0.90 was said to mean the test "can
  reliably distinguish between diseased and healthy patients". AUC is the probability that a
  randomly chosen case outranks a randomly chosen non-case -- a property of pairs, not a
  classification accuracy for any individual patient.

## Fixed -- output hygiene

- **R package chatter no longer appears in Analysis Notes.** jamovi surfaces `message()` and
  `warning()` conditions to the user, so third-party notices leaked into results -- a single
  Lasso-Cox run displayed the glmnet tie-handling notice twelve times. Third-party calls are now
  wrapped so package chatter and deprecation notices are suppressed while substantive warnings,
  such as non-convergence, still reach you.

- **A malformed reference no longer prevents results from rendering.** A citation with an empty
  publication year caused a serialization failure that produced no output at all, with an error
  mentioning `serialize` rather than anything about the analysis. All references now carry a year.

# meddecide 1.0.4 (2026-08-07)

This release is the result of end-to-end release reviews of fourteen analyses:
`decisioncompare`, `decision`, `agreement`, `lassologistic`, `decisioncombine`,
`decisioncalculator`, `nogoldstandard`, `cotest`, `sequentialtests`, `enhancedROC`,
`psychopdaROC`, and all three kappaSize sample-size analyses -- `kappaSizePower`,
`kappaSizeCI` and `kappaSizeFixedN`, each reviewed in its own right and then cross-checked
against the other two. Each was traced from its user interface through to its printed
output, every statistic was checked against an independent R package (`epiR`, `DescTools`,
`psych`, `binom`, `poLCA`, `pROC`, `cutpointr`, `kappaSize`, `stats`), and the confirmed defects were fixed. Most of what follows is
a correction to a number a clinician could already have copied into a report.

## Breaking changes

- **`decisioncompare()` has four new required arguments: `goldNegative`, `test1Negative`,
  `test2Negative` and `test3Negative`.** They name the level of each variable that represents a
  genuine negative result, so that a third, equivocal level can be told apart from a negative one.
  jamovi does not permit a default on a `Level` option, so all four compile to bare parameters of
  the R wrapper: **existing scripts that call `decisioncompare()` will fail with `argument
  "goldNegative" is missing, with no default` until they are updated**, passing `NULL` for any test
  that is not in use. Nothing changes for users driving the analysis from the jamovi GUI. The
  reason for the change is the `excludeIndeterminate` defect described below -- without a declared
  negative level the analysis has no way to know which rows are equivocal.
- **`decisioncombine()`'s `filterPattern` lost the levels `serial`, `parallel` and `majority`.**
  That option selects rows of the *observed pattern* table, but those three names describe
  decision *rules*, which is what the strategy table reports -- "serial" as a filter selected the
  `+/+/+` pattern while the Serial (AND) rule is a different row of a different table. The
  remaining levels are `all`, `allPositive`, `allNegative` and `mixed`. **A script passing one of
  the removed values now fails** with `Argument 'filterPattern' must be one of ...`; use
  `allPositive` for the old `serial` and `all` for the old `parallel`. The jamovi GUI shows only
  the current levels.
- **`nogoldstandard()`'s default `method` changed from `all_positive` to `latent_class`.** The old
  default defines the reference standard as "every test positive", which fixes sensitivity and NPV
  at 1 for every test on every dataset -- it cannot estimate accuracy, which is the entire point of
  the analysis. `latent_class` is the only method here that estimates sensitivity and specificity
  without building the reference standard out of the tests themselves. **A new analysis will
  therefore produce different numbers than it did in 1.0.3**, and because `latent_class` needs
  three or more tests, a two-test analysis that previously returned (meaningless) results now
  refuses and explains why. Saved `.omv` files keep the method they were saved with; pass
  `method = "all_positive"` explicitly to restore the old behaviour.

## Fixed

### `decisioncompare` (Compare Medical Decision Tests)

- **Every results table grew on each re-run.** The six calls meant to clear old rows used
  `clearRows()`, which is not a `jmvcore` Table method -- only `deleteRows()` exists -- and each call
  was wrapped in `try(silent = TRUE)`, so the error was swallowed and nothing was ever cleared. In
  jamovi, toggling *any* option re-runs the analysis on the same object, so the comparison table
  went 4 -> 8 -> 12 rows across three runs and each test appeared twice, then three times, then four.
  Anyone who changed a checkbox mid-session was reading a duplicated table.
- **`excludeIndeterminate` was a complete no-op.** It filtered on
  `c(positiveLevel, setdiff(levels, positiveLevel))` -- that is, on every level -- so equivocal
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
  when it matches `^\([\$A-Za-z].*\)$`; a leading `!` fails that test, so the raw -- and therefore
  truthy -- string was returned instead of being evaluated. An empty "Test 3 -- Recoded Data" table
  sat under every two-test analysis, and the stratified table showed with no stratifier selected.
- **The manuscript text printed a literal placeholder,**`95% CI: [see confidence interval table]`.
  It now prints real Clopper-Pearson intervals.
- **A tie for best-performing test was broken by whichever test came first, silently.** Ties are
  now disclosed.
- **The difference table's "95% Confidence Interval" header did not say which method produced it.**
  It is now footnoted as the paired Wald interval for correlated proportions, and distinguished
  from the separate "CI Method for Agreement" option that governs the Overall Percent Agreement
  table.
- The three tests in `test-decisioncompare-critical-fixes.R` never called the module at all -- they
  re-implemented the logic inline and asserted on their own arithmetic. They now exercise the real
  analysis.
- Verified unchanged and correct: all per-test metrics against `epiR::epi.tests` (to 1e-8);
  Cochran's Q = 5.150442, p = 0.076137 against `DescTools::CochranQTest` (six decimal places);
  McNemar with Holm correction against `stats::mcnemar.test` + `p.adjust` (1e-10); Wilson intervals
  against `binom::binom.confint`; exact intervals against Clopper-Pearson; the paired Wald standard
  error by hand. McNemar correctly compares diagnostic *correctness* against the gold standard
  rather than raw positivity -- proven with a fixture on which the wrong design gives p = 1.000 and
  the right one p = 0.0015.

### `decision` (Medical Decision)

- **With a user-supplied population prevalence, the results row was arithmetically impossible.**
  The Prevalence cell was overwritten with the user's prior while PPV and NPV stayed at the raw 2x2
  values computed at the study prevalence, so a row could read "Prevalence 5.0% ... PPV 88.9%" -- for
  a test with sensitivity 0.80 and specificity 0.90, Bayes gives 29.6%. A pathologist reading PPV
  off a screening-prevalence run would have overstated positive predictive value roughly threefold,
  and the footnote made it worse by asserting the predictive values had already been prior-adjusted.
  PPV and NPV now report the post-test probabilities that correspond to the stated prevalence, both
  branches carry a footnote naming which prevalence was used, and the `epiR` interval pane -- whose
  exact binomial values cannot be moved to a different prevalence -- gains a note saying it is at
  the observed sample prevalence.
- **The `epiR` "number" table's footnotes described the wrong statistics.** They were attached by
  hard-coded row number while the rows render LR+, LR-, DOR, Youden and NNDx, so LR+ was described
  as the diagnostic odds ratio, LR- as the number needed to diagnose, and DOR as Youden's index.
  Footnotes are now keyed to the `epiR` statistic name carried alongside the data.
- **The Fagan nomogram silently failed to render whenever a 2x2 cell was zero** -- precisely the
  sparse tables that most need it. A zero cell makes sensitivity or specificity exactly 1, which
  `nomogrammer` rejects. The likelihood ratios passed to it were already Haldane-Anscombe
  corrected, so the proportions now come from the same corrected table, keeping the plot
  self-consistent instead of clamping to an arbitrary epsilon. `Plr`/`Nlr` are no longer passed:
  `nomogrammer` ignores them when sensitivity and specificity are supplied, and warned on every
  render.
- **With a zero cell, the interval pane disagreed with the estimates beside it.** LR+, LR- and DOR
  in the main tables are computed from Haldane-Anscombe corrected counts (LR+ 145), while
  `epi.tests()` was run on the raw table and returned `Inf` with a `NaN` lower bound -- two numbers
  for one statistic on one screen. Those three rows now come from a second `epi.tests()` call on
  the corrected table. Sensitivity, specificity, PPV and NPV deliberately stay on raw counts.
- **The "Getting Started" welcome panel was permanently visible**, sitting above every completed
  analysis, for the same leading-`!` reason described under `decisioncompare`. Rewritten as
  `(length(gold) == 0 || length(newtest) == 0 || length(goldPositive) == 0 ||
  length(testPositive) == 0)`; a bare option name could not be used because a Variable's value is a
  list, which R's `&&` rejects.
- **Rows dropped because their level was neither the positive nor the negative one were reported as
  "cases with missing values removed"**-- 40 rows with nothing missing. Rows are dropped twice: once
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
  PPV 0.888889, NPV 0.818182, LR+ 8, LR- 0.222222), with the 2x2 not transposed.

### `agreement` (Interrater Reliability)

- **Weighted kappa and Gwet's AC2 laid their weight matrices over an alphabetically sorted category
  order instead of the factor's declared level order**, scrambling any ordinal scale whose labels do
  not happen to sort into clinical order -- which is most of them. Low/Moderate/High sorts to
  High/Low/Moderate; Negative/Weak/Strong to Negative/Strong/Weak; Absent/Focal/Diffuse to
  Absent/Diffuse/Focal. On the test set recorded in the code, weighted kappa read 0.751 where the
  correct value is 0.597 -- across the Landis & Koch moderate/substantial boundary. Three separate
  places were at fault: `.pairKappaWithCI()` used `sort(unique(c(a, b)))`, `irr::kappa2` was handed
  a data frame (which `irr` coerces with `as.matrix()` to character and then re-derives categories
  alphabetically) and is now fed integer factor codes, and `irrCAC::gwet.ac1.raw` now receives an
  explicit `categ.labels`. Unweighted kappa and Gwet's AC1 are order-invariant and were unaffected;
  only the weighted options bite.
- **Weighted kappa was applied to nominal variables.** Ordinality was inferred from category count
  alone (`length(all_levels) >= 3`), so quadratic weights -- which assume a meaningful distance
  between categories -- were applied to any nominal variable with three or more levels, such as
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
  when three or more raters all use one category -- 100% agreement -- and that value was written
  straight into the table and graded "poor agreement (worse than chance)", the exact opposite of
  the data. Kappa is now blanked with a note explaining that there is no chance-agreement baseline
  when there is no variation.
- **Subgroup forest-plot intervals used the null-hypothesis standard error and ignored
  `confLevel`.** The subgroup path derived `se <- abs(kappa / z)` from `irr`'s z -- the H0 SE, the
  same defect corrected elsewhere in the file -- and hard-coded 1.96. Two-rater subgroups now use
  the non-null ASE, falling back to the null SE only when it is unavailable, and the multiplier is
  `qnorm()` at the user's confidence level. The plot subtitle, previously hard-coded to "95%
  confidence intervals", now prints the level actually used.
- **The same kappa was given two different words in one output.** The subgroup table used its own
  unattributed cut-points (0.40/0.60/0.75/0.90 -> Poor/Fair/Good/Excellent/Outstanding) while the
  plain-language summary used Landis & Koch 1977 (0.20/0.40/0.60/0.80), so 0.61 read "substantial"
  in the summary and "Good" in the table, and 0.56 read "moderate" there and "Fair" here. One named
  scale (Landis & Koch) is now used throughout.
- **Wald intervals for kappa were not clamped to the parameter space**, and an unclamped interval
  reported an upper limit of 1.18 for a statistic bounded on [-1, 1]. Both branches now clamp,
  matching the sibling inter/intra path that already did.
- **Bootstrap confidence intervals computed the wrong statistics, in four separate ways.**(a) The
  categorical-versus-continuous decision was made per replicate with
  `length(unique(na.omit(x))) <= 20`; a bootstrap resample retains only about 0.63n distinct
  values, so at n ~ 30-40 some replicates fell under the threshold, were treated as categorical,
  produced no ICC, and silently dropped the ICC row -- at exactly the study sizes most common in
  pathology. It is now decided once, on the original data. (b) Each rater column was coded
  independently with `as.numeric(factor(x))`, so the same clinical category received different
  codes in different columns whenever raters used different subsets of the scale, corrupting
  Krippendorff's alpha; a single shared category set is now used. (c) Krippendorff's level of
  measurement was hard-coded to nominal and now follows the data. (d) The bootstrap ICC was
  hard-coded to ICC(2,1) two-way absolute agreement while the row was labelled with whatever
  `iccType` the user had selected; the user's choice is now honoured in both paths.
- **The Bland-Altman plot did not refresh when the proportional-bias option was toggled** --
  `proportionalBias` was missing from `clearWith` although the plot adds a `geom_smooth` line under
  it. Separately, the pairwise-agreement figure silently truncated at `max_pairs`: with five raters,
  4 of 10 pairs were dropped with no note, so the figure read as the complete set. The omission
  count is now stamped on the image itself, so it travels with an exported figure.

### `lassologistic`

- **Coefficients and odds ratios were reported on the standardized scale, not the original
  measurement scale.** The design matrix is standardized in-module and `glmnet` is then called with
  `standardize = FALSE`, so nothing was back-transformed and every coefficient was per 1 SD. For a
  0/1 dummy from a balanced marker (sd ~ 0.5) the printed per-SD odds ratio is roughly the square
  root of the model's actual present-versus-absent odds ratio: 1.81 printed where the model implies
  3.25. The column standard deviations are now retained and coefficients divided through,
  reproducing exactly what `glmnet(standardize = TRUE)` would return. The Importance column keeps
  the per-SD magnitude, which is the quantity that is comparable across predictors, and the table
  note was rewritten accordingly.
- **The integer scoring system was internally inconsistent, and its rule was never published.**
  Points were derived from the raw per-SD coefficients while scores were awarded on a median split,
  so binary and continuous predictors were weighted on two different contrasts -- a 0/1 dummy's
  per-SD coefficient is about half its real effect, while a continuous median split spans roughly
  1.6 SD -- mis-ranking them against each other and making the Scoring System table's odds ratio
  disagree with the Selected Variables table for the same predictor (2.11 against 4.46 for p53).
  Points are now derived from the log-odds contribution of meeting each criterion, and the cut is
  resolved once so that the printed rule, the derivation contrast and the applied cut cannot drift
  apart. A new "Award points when" column publishes the criterion on the original measurement
  scale; previously the median cut never reached the output at all, so a clinician had no way to
  apply the score to a new patient.
- **The Brier score was graded against fixed cut-offs and mislabelled as calibration.** It is an
  overall accuracy score whose scale is driven by outcome prevalence: a no-information model that
  always predicts the base rate scores p(1-p), already 0.09 at 10% prevalence, which the old code
  graded "Excellent calibration". It is now graded by the Brier skill score against that null
  model ("Good (x% better than predicting the base rate)" / "Marginal" / "No better than predicting
  the base rate").
- **With zero selected variables, a model that calls everyone positive was presented as perfectly
  sensitive.** Every predicted probability is identical, the ROC is degenerate, and `pROC` returns
  `-Inf`, which was printed as "Optimal threshold: -Inf" beside Sensitivity 1.000 and Specificity
  0.000. Non-finite thresholds now fall back to 0.5.
- **Selecting exactly one predictor produced a completely blank result** -- no panel, no notice, no
  error. The welcome/To Do panel shows only when `explanatory` is empty, and the analysis returned
  early with one predictor, so both guards stayed silent. A warning now explains that LASSO
  performs variable selection and needs candidates to choose among.
- **Listwise deletion was invisible.**"Total observations" in the model summary actually held the
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

### `decisioncombine` (Combine Medical Decision Tests)

- **Five of the seven optional outputs were completely non-functional.**`asDF` is an R6 *active
  binding* on `jmvcore::Table`, so `tbl$asDF` already returns the data frame; the code wrote
  `tbl$asDF()`, invoking that data frame as a function -- "attempt to apply non-function". The
  recommendation and all four plots were affected.
- **The tables grew on every re-run and then broke.** Nothing called `deleteRows()`, and jamovi
  re-runs `.run()` on the same object whenever an option changes, so rows went 5 -> 10 -> 15; the
  duplicated row keys then made `$asDF` fail with `duplicate 'row.names' are not allowed`, taking
  down the second run entirely.
- **The analysis explained nothing when it stopped.**`.renderNotices()` sat after three early
  returns in `.run()`, so the notice saying *why* it had stopped was collected and then discarded,
  leaving a blank analysis with no message.
- **The "optimal" rule was an uncorrected argmax.** It ranks 5 candidate rules with two tests, or
  10 with three, using no interval and no test, so on pure noise it still names a winner -- and
  called it optimal. It now discloses how many rules were compared and that the winner is not an
  established finding. Serial (AND) and the all-positive pattern are the same 2x2 under two
  labels; counting both manufactured a tie and inflated that count.
- **Proportions and odds ratios shared one `estimate` column** -- sensitivity appeared as a
  percentage in one table and as 0.813 in another. Now split. Serial (AND) also gained its own
  named row: it was numerically identical to the "+/+/+" pattern and had been omitted, leaving a
  reader to know that the pattern *was* the serial rule.
- **The "mixed" pattern filter dropped genuinely mixed patterns.** It excluded anything *starting
  with* `+/+` or `-/-`, removing `+/+/-` and `-/-/+`; and when no pattern matched it fell back to
  the whole unfiltered table rather than to nothing. A multi-level variable is now flagged rather
  than silently dichotomised, and a gold standard with one outcome yields `NA` with a notice
  instead of a silent number.
- Pattern and strategy statistics were confirmed against `epiR::epi.tests`, the Wilson intervals
  against `binom::binom.confint`, and the OR/AND identities and the eight-pattern partition were
  checked as mathematical facts rather than estimates.

### `decisioncalculator` (Medical Decision Calculator)

- **The tables grew on every re-run** -- verified at the jmvcore level: `addRow()` with an existing
  `rowKey` *duplicates* rather than replaces (rowCount 2 -> 4 -> 6 over three passes, after which
  `$asDF` fails). Fixed on the three tables that populate via `addRow`.
- **The Fagan nomogram silently failed on any table with a zero cell** -- precisely the sparse
  tables that most need one -- because `nomogrammer` rejects a sensitivity or specificity of
  exactly 0 or 1. The proportions now come from the same Haldane-Anscombe corrected table the
  likelihood ratios already used, and a test whose positive result argues *against* disease
  declines with an explanation instead of crashing.
- **The most clinically useful part of the nomogram was invisible.**`nomogrammer` prints its
  reading -- prevalence, likelihood ratios, post-test probabilities -- to stdout under
  `Verbose = TRUE`, and jamovi never shows stdout. It is now rendered beside the figure, at the
  tables' precision rather than `nomogrammer`'s whole percents, and tracks the supplied prior.
- **The cut-off comparison named the wrong alternative.** The verdict was an if/else-if chain, so
  when both alternatives beat the current cut-off only the first was ever named, however much
  better the second was. It now picks the best of the three, declines to call a trivial advantage
  better performance, flags cut-offs whose totals differ (moving a threshold cannot change how
  many patients there are, so differing totals mean separate studies), and reports whether the
  Wilson intervals on the accuracies overlap -- a formal paired test is not possible from four
  marginal counts per scenario, and the table now says so.
- Point estimates and every interval bound were confirmed against `epiR::epi.tests`; the 2x2 is
  not transposed; a supplied prior moves PPV and NPV while leaving sensitivity and specificity
  alone, and the table states which prevalence was used -- the defect found in the sibling
  `decision` is not present here.

### `nogoldstandard` (Analysis Without Gold Standard)

- **Latent-class analysis reported sensitivity and specificity swapped.** The diseased class was
  identified with `probs[[i]][class, outcome]` but read back as `probs[[i]][2, disease_class]` --
  the transpose. `[2,2]` and `[1,1]` coincide, so the error surfaced only when poLCA happened to
  label the diseased group as class 1, which is about half of all runs. Verified against `poLCA`
  on identical data and against the known truth of simulated data.
- **The default method could not estimate accuracy at all, and now does not hide it.** Under
  `all_positive` the reference standard is "every test positive", so a diseased case can never be
  test-negative: FN is identically 0 and sensitivity and NPV are 1 for every test on every
  dataset. It printed "100% (95% CI 100-100%)". `any_positive` is the mirror image (FP == 0,
  specificity and PPV fixed at 1), and `composite` with two tests *is* `any_positive`, because a
  1-of-2 tie passes a `rowMeans >= 0.5` majority. Those quantities are now blanked with an
  explanation. See Breaking changes for the change of default.
- **The confidence intervals were too narrow -- by about 1.8x for sensitivity at 30% prevalence.**
  The standard error used the total n for both metrics; the denominators are n x prevalence for
  sensitivity and n x (1 - prevalence) for specificity.
- **The analysis claimed its latent-class model handles the assumption it actually makes.** The
  always-visible method guide advertised "Handles conditional dependence" and "No identifiability
  issues", while `poLCA(nclass = 2, ~ 1)` assumes the tests err *independently* given true status.
  The guide now says so; a new **Conditional Independence Check** table reports bivariate residuals
  per test pair (above 3.84 is evidence of a shared error source, which inflates estimated
  accuracy); and it explains that four or more tests are needed for the check to be informative --
  with three the model is just-identified and reproduces every table exactly. Two tests cannot
  identify a two-class model at all (5 parameters against 3 degrees of freedom) and are now
  refused rather than answered with numbers determined by the starting values.
- **The Bayesian method disclosed neither its priors nor its nature.** Beta(2, 1) on both
  sensitivity and specificity has mean 2/3 and increases toward 1, so it pulls estimates upward;
  nothing mentioned any prior, or that the results are not draws from a posterior. Both are now
  stated.
- **One undefined cell could kill the analysis.**`if (ppv_denominator > 0)` with an `NA`
  sensitivity threw "missing value where TRUE/FALSE needed", ending the run instead of blanking a
  number. An invalid positive level produced `Level 'test1_result' not found in variable
  'negative, positive'. Available levels: {}` -- `jmvcore::reject(formats, code = NULL, ...)` takes
  `code` as its second *positional* argument, so the substitution values were swallowed and
  shifted.
- Bootstrapping is now a single seeded pass with warm-started latent-class fits, and an **Analysis
  Diagnostics** panel (under Verbose output) reports sample size, method, convergence, random
  starts and bootstrap failures. The clinical summary no longer announces a sensitivity "Range
  from 100.0% to 100.0%", and no longer presents the fraction of cases on which all tests agree as
  an estimate of disease prevalence.

### `cotest` (Co-Testing Analysis)

- **A 0% post-test probability was reported for a test combination the model had made
  impossible.** When two tests are modelled as conditionally dependent, the joint probability
  P(Test1+, Test2+) cannot exceed the smaller of the two marginals -- a Frechet bound. Beyond it the
  requested dependence is unattainable and `cotest` truncated it to the bound. That truncation is
  correct, but it forces one of the four test combinations to have probability exactly zero in one
  disease group, and the likelihood-ratio helper turned that into a printed post-test probability
  of `0.000000` -- which reads as "this combination rules out disease". With the standard cervical
  co-testing pair (HPV 95%/85%, cytology 55%/97%) the bound binds from a dependence of 0.25 upward,
  so the analysis reported that an HPV-negative, cytology-positive woman has no chance of disease.
  When *both* groups hit their bounds the ratio was 0/0 and the same `0.000000` appeared for a
  combination that cannot occur at all. The three degenerate cases are now distinguished: 0/0 is
  undefined and the row is blank; a combination impossible only in non-diseased subjects gives
  exactly 1 (previously a fake-precision `0.999991`, an artefact of an internal likelihood-ratio
  cap of 1e6); and one impossible only in diseased subjects still gives 0. All three, and the
  truncation behind them, now raise a warning stating that the value follows from the assumed model
  rather than from data. The truncation was previously reported at "info" severity and never said
  what it implied.
- **The Fagan nomogram emitted a raw R error into the results pane.**`nomogrammer()` refuses a
  positive likelihood ratio below 1, which the permitted specificity range (down to 0.01) can
  produce, and the call was unguarded. The nomogram is now suppressed with an explanation naming
  the offending ratio.
- **The "Understanding Test Dependence" panel was displayed even under conditional independence,**
  where it describes a model that is not being fitted -- the `visible: (!indep)` case of the
  leading-`!` defect described under `decisioncompare`. Rewritten as `(indep == FALSE)`.
- Post-test probabilities under conditional independence were confirmed against Bayes' theorem to
  nine decimal places, and the dependent model was confirmed to reduce to them exactly at zero
  dependence. The shipped tests had asserted four different values, implying joint likelihood
  ratios of 120/2.105/3.333/0.0585 where the correct ones are 112/2.526/3.111/0.0702 -- the module
  was right and the expected values were fabricated. Eight further assertions passed an error
  message containing parentheses as a regular expression, so they never matched, and because
  testthat re-raises a non-matching error they masked one another.
- **The joint-probability validation could never fail.** It compared the sum of the four cells
  against 1, but the caller *defines* the fourth cell as one minus the other three, so the sum was
  1 by construction and the check passed on any input -- including a set whose cells no longer
  matched the sensitivities they were built from. It now also verifies that every cell is a
  probability and that P(both) + P(one only) still reproduces the marginal it came from, which is
  the invariant the clamping could actually break.
- **Negative conditional dependence is now accepted.** The parameter was bounded at 0, so tests
  that partly compensate for each other's errors could not be expressed. The permitted range is
  now -1 to 1 across the option definition, the UI clamp and the backend validation. The existing
  Frechet clamping already handled negative values; the resulting joint distributions were
  verified to be valid and to reproduce their marginals across the full range. For tests with high
  specificity the feasible negative range is narrow, and values beyond it are truncated with the
  warning described above.
- **Post-test probabilities carry no uncertainty, and now say so where they are read.**
  Sensitivity, specificity and prevalence are typed in by the user and treated as exact, so no
  reported probability has a confidence interval. That was stated only in the collapsible
  "Getting Started" panel and is now a note on the results table itself.

### `sequentialtests` (Sequential Testing Analysis)

- **Clinical presets were ignored whenever the analysis was called from R.** The eight presets are
  applied by `jamovi/js/sequentialtests.events.js`, which writes the values into the interface
  controls; nothing runs that JavaScript outside jamovi, so asking for the HIV scenario silently
  analysed the panel defaults - 0.95/0.70 with 0.80/0.98 at 10% prevalence - instead of ELISA and
  Western Blot at 2%. `preset` was the only declared option the backend never read. Presets are now
  applied in the backend as well, and a regression test parses the JavaScript configuration and
  compares it field by field against the R table, so the two cannot drift apart.
- **Illustrative teaching values were presented as evidence.** The preset control was documented as
  loading "evidence-based test parameters and optimal strategies from medical literature". They are
  rounded approximations with no citation, no confidence interval and no population behind them,
  chosen to make each strategy's behaviour visible. Selecting a preset now raises a warning that
  the figures are for demonstration only and must not be used to design a protocol or advise on a
  patient; the same caveat appears beside the preset in the interface and in the option
  documentation. The eleven bundled `sequentialtests_*` example datasets had **no documentation at
  all**; they are now documented, leading with the same warning and spelling out that a single
  sensitivity figure hides variation by assay, operator and disease stage, that the prevalences are
  illustrative settings rather than yours, and that a label such as `"RT-PCR"` names the scenario
  rather than asserting anything about that test as actually performed.
- **A Fagan nomogram was advertised that does not exist.** The word appeared in the analysis
  description and nowhere else in the module - no option, no results item, no code - while every
  sibling analysis in the same menu does provide one.
- **Two of the three strategies are the same rule, and nothing said so.** Serial testing of
  negatives and parallel testing both call a subject positive if *either* test is positive, so they
  are algebraically identical in sensitivity, specificity, PPV and NPV; they differ only in how many
  second tests are performed, which only the cost table reveals. Verified identical to 1e-12. A note
  now explains it.
- **The conditional-independence caveat went stale.** It was attached only to parallel testing, and
  because the summary table declares no `clearWith` it survived a change of strategy - leaving a
  note about parallel testing under a row labelled "Serial Testing". The assumption applies to all
  three strategies and is now stated for all three, alongside a note that sensitivity, specificity
  and prevalence are treated as exact so the combined figures carry no confidence interval.
  Negative conditional dependence, previously forbidden by a lower bound of 0, is now permitted
  across the -1 to 1 range in the option, the interface clamp and the backend validation; the
  existing Frechet clamping already handled it correctly. All three strategies were confirmed
  against a four-million-subject simulation of their actual decision rules, and the
  conditional-independence figures against Bayes' theorem to nine decimal places.

### `enhancedROC` (Clinical ROC Analysis)

- **Every results table doubled on each re-run, and then broke.** Twenty-one `addRow()` calls and
  not one `deleteRows()`. jamovi re-runs an analysis on the same object whenever an option changes,
  so the AUC summary went 2 to 4 to 6 rows and the cut-off table 32 to 64 to 96; from the second run
  onward the tables could not be read at all, failing with `duplicate 'row.names' are not allowed`.
  Anyone who changed a checkbox mid-session was reading each predictor two or three times over.
  Fixed on all 18 tables populated by `addRow`; the two driven by `setRow` cannot duplicate and
  were left alone.
- **Nothing in 4,500 lines set a random seed,** while the analysis resamples in four places:
  bootstrap AUC confidence intervals, bootstrap ROC comparisons, internal-validation resamples and
  cross-validation fold assignment. Two identical runs returned 95% intervals of 0.775-0.862 and
  0.771-0.862, so a figure copied into a manuscript could not be reproduced. A new **Random Seed**
  option (default 0) seeds all four; the caller's own random number stream is restored afterwards.
- **Automatic direction detection biases the AUC upward, and now says by how much.**`pROC`'s
  auto-detection reads the direction from the data by comparing the two groups' medians, and it is
  the default. Because the direction is then fitted from the same data that supply the AUC, the
  AUC is inflated: a marker carrying no information at all gives a mean reported AUC of 0.593 at
  n = 20 and 0.565 at n = 40, against 0.502 when the direction is fixed in advance, and exceeds
  0.60 in 43% of runs at n = 20 - enough to turn a null pilot study into an apparently promising
  biomarker. The notice named the direction chosen but not this consequence, and was filed as
  informational. It is now a warning quoting the expected AUC for an uninformative marker at the
  study's own sample size, and recommending that Direction be set explicitly.
- **Three comparison options did nothing, without explanation.** Pairwise comparisons, metric
  differences and statistical comparison all require Analysis Type to be "Comparative ROC
  Analysis", but the interface offers them as plain checkboxes with no such dependency; ticking one
  under the default Analysis Type produced no output and no message. They now say what to change.
- **Nineteen options were documented as working features but do nothing.** They reach the public R
  wrapper and `?enhancedROC` described them in the present tense - "Calculate Harrell's concordance
  index for time-to-event outcomes" - while the backend only lists them in a "planned features"
  notice at run time. None has an interface control, so this affected R callers and the help page
  rather than the jamovi menus. All twenty such options, including `splineKnots` which configures
  one of them, are now prefixed "NOT YET IMPLEMENTED - selecting this produces no output".
- `test-enhancedroc-pr-clinical.R` never exercised the analysis. It built a hand-rolled `jmvcore`
  (`MockTable`, `MockHtml`, `MockImage`), assigned a fake base class into the global environment
  and `source()`d the backend; the mock implemented only `addRow`, `setRow` and `asDF`, drifted
  from the real backend, and the whole file died with "attempt to apply non-function". Rewritten
  against the real function, keeping its assertions and adding a check that PPV at a
  user-supplied prevalence equals Bayes' theorem applied to the table's own likelihood ratio.
  AUC itself was confirmed against `pROC` to nine decimal places under every direction setting.

### `psychopdaROC` (Advanced ROC Analysis)

- **Fourteen of the sixteen results tables doubled on every re-run.** Twenty-one `addRow()` calls
  against two `deleteRows()`. jamovi re-runs an analysis on the same object whenever any option
  changes, so rows went 1 to 2 to 3 per predictor and the decision curve 40 to 80 to 120. Every
  table is now cleared once at the top of the run - after the manual-run gate, so that manual mode
  keeps its results when an option is edited.
- **Leaving the positive class unset ran the whole analysis backwards.** The fallback took the
  FIRST factor level, which for every ordinary coding - Healthy/Disease, Negative/Positive,
  Control/Case, 0/1 - is the NEGATIVE group. On the bundled example data it reported AUC 0.1001
  where naming the positive class gives 0.8999, with no error and no warning. Worse, the positive
  class was worked out in four places that could disagree, one of which fell back to
  `unique(classVar)[1]` - the first value in DATA ORDER, so the answer depended on how the rows
  happened to be sorted. All four now go through one resolver, which takes the last level and says
  so on the results tables. With three or more levels it refuses instead of guessing, matching
  `enhancedROC`: on a three-level recode of the bundled data, assuming "Disease" gives AUC 0.8012
  and assuming "Severe" gives 0.8263, and there is no basis for preferring either.
- **The reported "optimal cutpoint" was usually not the optimum.** The metric tolerance defaulted
  to 0.05 while the underlying `cutpointr` package uses 1e-06. Every cutpoint scoring within 0.05
  Youden of the best was treated as equivalent and averaged: on the bundled data 39 of 200
  candidate thresholds, spanning 52.1 to 67.7, giving a cutpoint with 84.5 percent sensitivity in
  place of the 94.4 percent available at the true optimum. The default now matches `cutpointr`,
  and any tolerance still in force is disclosed beside the cutpoint.
- **The Hanley-McNeil fallback footnote pointed the wrong way.** It warned that the approximation
  "may produce narrower confidence intervals than appropriate". On the shipped data its standard
  error is 0.025863 against DeLong's 0.021092 - 22.6 percent WIDER, i.e. conservative. The formula
  itself is the standard Hanley-McNeil variance and is correct; only the footnote was wrong.
- Six `warning()` calls remain invisible to jamovi users (R sends them to stderr, which the GUI
  does not display). Two of them used to change the analysis rather than merely inform; those are
  gone, and the analysis has no general notices panel - see Remaining work.
- **DeLong's test could report an AUC of 0.794 for a marker the AUC table reported as 0.206.**
  DeLong's test needs every marker read in the same direction, so when a marker's AUC came out
  below 0.5 the fallback implementation flipped its scores and then displayed `1 - AUC`. The
  primary implementation does not flip - it passes the user's Classification Direction straight to
  `pROC` and reports the honest figure - so the two tables disagreed for exactly the markers where
  the direction is in question, and the only signal was an R `warning()`, which a jamovi user never
  sees. Measured on a constructed marker: 0.206 in the AUC table, 0.794 in the DeLong output. The
  flip still happens, because the test requires it, but the affected markers are now named both in
  the DeLong output and in a note on the comparison table, with the instruction to change
  Classification Direction and re-run if the reversed direction is the clinically correct one.
- **DeLong's test printed confident p-values on samples too small to support them.** Its variance
  is a large-sample approximation, so with few cases in either class the p-values and confidence
  intervals are too narrow. A note now appears when either class holds fewer than ten cases - the
  conventional floor for a stable AUC variance - and says that any difference should be treated as
  provisional. The check sits in the rendering path, so it covers both implementations.
- The test suite was substantially broken and is repaired: `test-psychopdaroc.R` was 29 failures
  and 6 errors, and `source()`d `../../R/psychopdaROC.h.R` - capitalised paths that do not exist,
  so the file only loaded on a case-insensitive filesystem. Its helper in five other files filled
  every argument lacking a default with `""`, including `dependentVars` and `classVar`, so a test
  that omitted a required variable was silently handed an empty string. All nine documented
  examples were uncopyable because none passed `refVar`, a `type: Level` option that the jamovi
  compiler forbids a default on and which is therefore a required argument. AUC, the DeLong test
  and the optimal cutpoint were confirmed against `pROC` and `cutpointr`.

### Cross-checking the two ROC analyses

`enhancedROC` and `psychopdaROC` sit in the same menu, so the same data can be put through either.
They were compared directly on eight datasets. **The estimators agree to machine precision**: AUC
and DeLong confidence intervals were bit-identical across all of them - maximum absolute AUC
difference 3.2e-15, maximum CI difference exactly zero - and both matched `pROC` and a
hand-computed Mann-Whitney AUC, including on data rounded to only twenty distinct values. What
differs is defaults and scope, and one of those matters:

- **Their direction defaults disagree, and both analyses now explain this on screen.** For a
  marker where LOWER values indicate disease - a falling haemoglobin, a falling ejection fraction
  - the same column of numbers came back as AUC 0.8999 from `enhancedROC` and 0.1001 from
  `psychopdaROC`, with nothing on screen saying why. The cause is a default, not a calculation:
  `enhancedROC` works the direction out from the data, while `psychopdaROC` assumes higher values
  mean disease unless told otherwise. Both answers are correct for the question each is asking -
  0.1001 is what you get if you insist higher means disease, and 0.8999 is the same marker read
  the right way round - and told the same direction the two agree exactly.

  Each analysis now prints the same plain sentence beside its AUC, worded identically so the two
  outputs can be read side by side:

  > Reading of the test values: **HIGHER values of biomarker were taken to indicate Disease**.

  It goes on to say where that reading came from (specified by you, or worked out from the data)
  and that every sensitivity, specificity, cutpoint and AUC is reversed if it is the wrong way
  round. `psychopdaROC`'s "AUC below 0.5" warning now also names the current Classification
  Direction setting and states that switching it gives an AUC of 1 minus the value shown, with
  sensitivity and specificity swapped - so the remedy is explicit rather than left to the reader.
  Set Direction explicitly whenever the marker's orientation is known clinically.
- `enhancedROC` honours a confidence-level option; `psychopdaROC` has none and always reports 95
  percent, so at 99 percent the two give [0.8456, 0.9542] and [0.8585, 0.9412].
- `enhancedROC` refuses any dataset below n = 20 and returns nothing; `psychopdaROC` computes and
  agrees with `pROC` (n = 16: 0.6406 [0.3236, 0.9576]).
- Their optimal cutpoints differ in the last decimal by construction: `pROC` places the threshold
  at the MIDPOINT between two adjacent observed values (54.1979) while `cutpointr` returns an
  observed value (54.2904). Sensitivity and specificity are identical either way.
- Given a positive class that does not exist, `enhancedROC` returns empty tables with an
  explanatory panel while `psychopdaROC` raises an R error.

### The kappaSize sample-size family (`kappaSizePower`, `kappaSizeCI`, `kappaSizeFixedN`)

- **Certain option combinations froze the analysis permanently.**`kappaSize`'s root finder does
  not converge when the significance level is at or above the target power: a direct
  `PowerBinary(alpha = 0.90, power = 0.20)` call was still running when killed after 60 seconds
  and could not be interrupted, while the same call at alpha 0.05 and power 0.80 returns
  instantly. The option bounds permitted alpha up to 0.99 and power down to 0.01, so the
  combination was reachable from the interface and left jamovi with no way to recover. It is now
  refused before the engine is entered, in 0.07 seconds, with an explanation that a study whose
  power does not exceed its type I error rate provides no evidence. The same guard removes two
  related absurdities: power 0.01 used to report "A minimum of 1 subjects", and alpha just below
  power produced a sample size of zero rendered as one subject.
- **`kappa0` was documented backwards in two of the three analyses.**`kappaSize`'s own
  documentation defines `PowerBinary`'s `kappa0` as "the null hypothesis for the kappa hypothesis
  test" and `CIBinary`'s and `FixedNBinary`'s as "the preliminary value of kappa" - two different
  quantities that happen to share a name. `kappaSizePower` described its null as the "Expected
  value of kappa", and `kappaSizeCI` described its anticipated value as "the null hypothesis value
  of kappa": each carried the other's meaning. Someone following the help text would enter the
  wrong quantity and get a different answer without any indication. All three descriptions now
  match the package, each says explicitly what it is NOT, and `kappaSizeCI`'s printed output no
  longer labels its anticipated kappa "Null hypothesis kappa".
- **The three analyses now agree on their shared options.** The significance level was bounded
  0.01-0.99 in Power and CI but 0.01-0.20 in FixedN; all three are now 0.001-0.20. The old floor
  made a Bonferroni-adjusted alpha inexpressible, and the old ceiling admitted values that are not
  significance levels at all. Proportions parse identically everywhere (commas, semicolons or
  spaces) - the string `0.30 0.70` was accepted by `kappaSizeFixedN` and rejected by
  `kappaSizePower`. A binary outcome may be entered as one prevalence or as two proportions in all
  three; `kappaSizeFixedN` alone demanded two, although `kappaSize::FixedNBinary` accepts either.
  A European decimal comma (`0,30 0,70`) used to report "Each proportion must be strictly between
  0 and 1", which is true and useless; it now names the decimal separator as the problem.
- **The power and confidence-interval approaches answer different questions, and each now says
  so.** For the same study they can differ by nearly threefold in required sample size, with
  nothing in either output explaining why. Each now opens by stating whether it is sizing the study
  to reject a null value or to achieve a target interval width, and names the other analysis.
- **An alternative kappa below the null was answered silently.** It is a legitimate question -
  how many subjects to show agreement is WORSE than the null - but it is more often a
  transposition, and it returns a different sample size from the mirrored input (149 against 191
  on the default scenario). The output now states which way round it read the two values.
- The study explanation never reported the sample size it was explaining, and read "the prevalence
  of the categories are" for three or more categories. The result panel rendered the raw
  `kappaSize` object, duplicating the summary panel and repeating the same expected-cell-count
  warning ten times in the five-category case; it now shows the headline sentence.
- Sample sizes were confirmed against `kappaSize` across 540 combinations - four cardinalities,
  five rater counts, three kappa pairs, three significance levels and three power targets - with
  zero divergences, plus a 95-case rounding check. The module is a faithful wrapper; everything
  fixed here sits around the calculation rather than in it.

#### `kappaSizeCI`

- **A narrow confidence interval froze the analysis with no way out.**`kappaSize::CIBinary` finds
  its answer by brute force - `n <- 10; while (...) n <- n + 1` in interpreted R, with no cap - and
  the required n grows as roughly one over the square of the distance from `kappa0` to the nearer
  limit. Measured on the binary engine: distances of 0.20, 0.05, 0.01 and 0.005 give 118, 1,625,
  38,203 and 151,533 subjects in 0.00 to 1.38 seconds, while 0.0005 had not returned after eight
  seconds. jamovi cannot abort a running analysis, so the user was simply stuck with no error and
  no progress. The search now runs under a bounded wall-clock budget (`setTimeLimit`, which does
  interrupt an interpreted loop) and, if it expires, refuses with a message naming the distance to
  the nearer limit and telling the user to widen the interval. Demanding but finite designs are
  untouched: 0.55-0.65, 0.58-0.62 and 0.59-0.61 still return 1,625, 9,707 and 38,203.
- **The explanation reported the wrong quantity as the driver of the sample size.** It showed the
  "Precision width" of the interval, but `kappaSize` sizes on whichever limit lies nearer `kappa0`:
  with `kappaL = 0.55` the answer is 1,625 for every `kappaU` from 0.65 to 0.99. In one-sided mode
  `kappaU` is not used at all. The output now states the distance to the nearer limit and says
  explicitly that this, not the full width, is what determines the number of subjects.
- **Proportions were parsed with a character class that did not mean what it looked like.** The
  separator set was written `"[,;|\\t]+"`, which in R is the *set* of characters `,` `;` `|` `\` and
  the letter `t` - it matched a literal backslash and the letter t, but neither an actual tab nor a
  space. So `0.2, 0.3; 0.5` was accepted and `0.2, 0.3 0.5` was rejected. It is now
  `[,;|[:space:]]+`, which handles tabs and spaces properly. A European decimal comma is diagnosed
  as such rather than reported as an out-of-range proportion.
- **`kappaSize`'s own sparse-cell caveat reached only the Summary pane.** When the computed sample
  size leaves a category with fewer than five expected subjects, the package says so in its summary
  text - a real warning about the large-sample approximation it relies on, in the one place a
  reader looking for caveats would not think to look. It is now raised in the Notes panel as well.
- Sample sizes were confirmed against `kappaSize` across 2,560 comparisons, including the
  one-sided path, with zero divergences.

#### `kappaSizeFixedN`

- **The analysis could display a lower bound of -23.78 for Cohen's kappa.** Kappa is bounded below
  by -1. `kappaSize` searches by decrementing rho from `kappa0` in steps of 0.001 with no floor, so
  a combination that is inside every declared option bound - `kappa0 = 0.01`, `n = 11`, a 2%
  prevalence, `alpha = 0.001` - walks straight past -1, and the result was printed as an ordinary
  answer. It is now refused, with an explanation that the large-sample approximation has broken
  down at this combination and what to change. A bound that is negative but still valid (for
  example -0.293) is reported as before, now with a sentence saying that a bound at or below zero
  means this many subjects cannot rule out agreement no better than chance.
- **A sample size of infinity hung the analysis forever.** The guard read
  `is.na(n) || n < 2 || n != round(n)`, and `Inf` passes all three clauses - `is.na(Inf)` is FALSE,
  `Inf < 2` is FALSE, and `Inf != round(Inf)` is FALSE. Inside the engine the test statistic
  becomes NaN and the search never terminates. `n` is now bounded 11 to 1,000,000 at the option
  level and checked for finiteness and integrality in the backend.
- **Sample sizes below 11 produced the package's own message, which is off by one.** Every
  `kappaSize` FixedN engine contains `if (n <= 10) stop("Sorry, your study should enroll at least
  10 subjects.")`, while the option permitted `n` down to 2 - so 2 through 10 reached the engine
  only to bounce back as a raw vendor string that names the wrong threshold. The option floor is
  now 11 and the message explains that the method is a large-sample approximation.
- **The significance level was checked against the wrong bounds in the backend.** The backend
  accepted anything in (0, 1) while the option compiles to 0.001-0.20, so an R caller passing
  `alpha = 0.5` reached the engine and got "missing value where TRUE/FALSE needed". The two now
  agree. The proportions-sum tolerance likewise used `all.equal`, which accepts a sum within 0.001
  inclusive, while the engine rejects at 0.001 exclusive; the module now uses the engine's own
  predicate so no input can slip past the clear message into the vendor one.
- **A rejected re-run left the previous run's numbers on screen.** jamovi calls `.run()` on the
  same object for every option change, and validation rejects before anything new is written, so an
  invalid edit produced a red error above a stale, still-plausible-looking result. All panels are
  cleared first, as the two sibling analyses already did.
- **The study explanation invited a misreading.** It opened "Researchers would like to determine
  the expected lower bound for kappa0=0.6", which reads as though the bound belonged to `kappa0`.
  It does not: `kappa0` here is the agreement the researchers *anticipate observing*, and the bound
  is the worst case still compatible with it at this sample size. The wording now says so, states
  the confidence level, reports the answer it is explaining, and says "the prevalence of the trait
  is" rather than "the proportions of the outcome categories are" when a single binary prevalence
  was entered.
- **A Notes panel was added.** It states the method and, in particular, that `kappa0` here is the
  anticipated agreement and *not* a null hypothesis value as it is in `kappaSizePower` - the two
  analyses sit in the same menu and take an identically named argument with different meanings. It
  warns when a category is expected to contain fewer than five subjects, and warns in red when the
  achievable bound is at or below zero, the case where the planned study cannot demonstrate
  agreement at all regardless of what it observes.
- Lower bounds were confirmed against `kappaSize` across 2,000 combinations with a maximum
  difference of 6e-16 (print rounding alone). Both monotonicity properties - more subjects raise
  the bound, a higher significance level raises it - held in 400 of 400 checks each, and the
  returned bound was below `kappa0` in all 2,000.

## Changed

- **`lassologistic` score performance figures are now labelled as apparent.**"Score AUC" became
  "Score AUC (apparent)" and "Optimal score cutoff" became "Optimal score cutoff (chosen on this
  data)", with a note that these figures are optimistic twice over -- the points were derived from a
  model fitted to these data, and the cutoff was Youden-optimised on the same rows. The model's own
  table already carried an optimism caveat; the score's did not.

## Added

- **`lassologistic` gained a configurable cut point for continuous predictors in the scoring
  system.**`scoreCutMethod` offers median, mean, upper tertile, upper quartile and manual
  (default median, i.e. the previous behaviour), and `scoreCutPoints` is a free-text field taking
  `variable=value` pairs on the original measurement scale (for example `ki67=20, age=65`), so an
  established clinical threshold can be used instead of a data-derived split. Unparseable entries
  are dropped rather than guessed; any continuous predictor without a manual cut falls back to the
  sample median, and that fallback is named in a table note. The Scoring System note states that a
  dataset-derived cut is not an externally established threshold and will differ in another cohort.

## Documentation

All 92 files under `vignettes/` were audited against the shipped analyses and their current option
definitions. These articles are published to
<https://www.serdarbalci.com/meddecide/articles/>; they are excluded from the package tarball by
`.Rbuildignore`, so none of what follows affects `R CMD check`.

- **Twenty-eight articles document an analysis that meddecide does not ship, and now say so.**
  `decisionpanel`, `decisiongraph`, `decisioncurve`, `modelbuilder`, `screeningcalculator`,
  `bayesdca`, `icccoeff`, `latentbiomarker`, `advancedtree`, `decision2` and `ppv` are all still on
  development or test menu routes, in this module and in the umbrella ClinicoPath module alike, so
  they reach no user today. Each affected article carries a note at the top - or, where the article
  is mainly about a shipped analysis and only borrows one of these, at the point of use - saying
  that the analysis is documented ahead of a future release, that its options and output may change,
  and that it will not appear in the jamovi menu yet. No article was deleted.
- **`07-kappasizeci-comprehensive.Rmd` described `kappa0` as a null hypothesis value.** For
  `kappaSizeCI` it is the *anticipated* kappa; only `kappaSizePower` treats it as a null. The
  article now states which it is and names the other analysis, since the two sit in the same menu
  and take an identically named argument meaning different things. The same article claimed that
  the *width* of the confidence interval drives the required sample size; the calculation actually
  sizes on whichever limit lies nearer `kappa0`, so with `kappaL = 0.55` the answer is 1,625
  subjects for every `kappaU` from 0.65 to 0.99, and in one-sided mode `kappaU` is ignored
  entirely. It also listed the rater options as 2 to 5 where the analysis accepts 2 to 6.
- **`nogoldstandard-documentation.md` still gave the old default.** It listed
  `method` as defaulting to `all_positive` in two places; the 1.0.4 default is `latent_class`, and
  the reason for the change is now stated alongside it.
- **Four articles illustrate `agreement()` with an argument list that no longer exists.** Twenty-
  eight code chunks use names such as `rater1_var`, `agreement_type`, `pathologyContext` and
  `diagnosticStyleAnalysis`, none of which have existed for some time - copying them yields
  `unused argument`. Every chunk in these articles is `eval = FALSE`, so nothing broke and the
  narrative and statistics remain sound, but the code was uncopyable. Each now carries a notice to
  that effect together with a **verified** working call, checked against 1.0.4 on three raters and
  60 cases (Fleiss' kappa 0.734, Krippendorff's alpha 0.735). A full rewrite of those examples
  against the current API is still outstanding.
- Argument names in six further call sites were corrected outright:
  `psychopdaROC(class =, value =)` is `psychopdaROC(dependentVars =, classVar =, positiveClass =)`,
  and `kappaSizeCI`/`kappaSizeFixedN` take `alpha` rather than a `conf_level`, with `kappaL`/`kappaU`
  in place of a single `width`.
- Every call to a shipped analysis across all 92 files - 345 of them - was checked against the
  generated wrapper signatures. Apart from the 49 described above, all use argument names the
  functions accept.

## Removed

- **Pruned NAMESPACE exports for analyses that this module does not ship,** together with unused
  `importFrom` declarations. Seven exports were removed (`clinicalscore`, `decisioncurve`,
  `latentbiomarker`, `leaveonecenterout`, `mageeequation`, `misclassificationbias`,
  `timedependentdca`) along with about 25 unused imports (`dplyr::arrange`/`filter`/`summarise`,
  several `ggplot2` and `graphics` functions, `stats::complete.cases`, and others). No shipped
  analysis was affected. `.Rbuildignore` gained `temp` and `backups` patterns.
- **`boot` and `survival` were dropped from `Imports`.** Neither is used anywhere in the package:
  no `::` call, no `NAMESPACE` import, and no bare call to any function they export. jamovi
  installs every package in `Imports` the first time a module is used, so two unused dependencies
  and their own dependency trees were being downloaded by every user for nothing.

# meddecide 1.0.3 (2026-08-04)

No user-visible changes. Version alignment across the ClinicoPath submodules: the package version
and every analysis version string were bumped, and no R code, option definition or results
definition was touched.

# meddecide 1.0.2 (2026-08-03)

## Fixed

- **Three analyses named the wrong confidence-interval method.**`epiR::epi.tests()` -- the source
  of the sensitivity, specificity and predictive-value intervals in `decision`,
  `decisioncalculator` and `decisioncompare` -- defaults to `method = "exact"`, which is the
  Clopper-Pearson interval, not Wilson. On a 2x2 of 67/56/38/79 the two differ in the third
  decimal (sensitivity 0.5385-0.7296 exact against 0.5428-0.7236 Wilson). The footnotes in
  `decision` and `decisioncompare` said "Wilson score method" and now name Clopper-Pearson. **No
  interval changed** -- only the label was wrong. `decisioncombine` was checked and left alone: its
  own `.calcWilsonCI()` genuinely is Wilson and genuinely populates the CI table it describes, so
  its labelling was already correct.
- **`decisioncompare` advertised likelihood-ratio confidence intervals it never computes.** The
  per-test table is filtered to a row set that excludes `lr.pos`/`lr.neg`, and the LRP/LRN columns
  carry no lower/upper bounds -- so no likelihood-ratio interval is rendered anywhere in that
  analysis. The Assumptions panel now states that likelihood ratios are point estimates only, and
  describes the intervals that *are* shown: Clopper-Pearson for the proportions, the user's chosen
  method (Wilson by default) for Overall Percent Agreement, and Wald for paired differences.
- **`decisioncalculator` overstated the reach of its continuity correction.** The notice said the
  Haldane-Anscombe 0.5 correction was applied to "likelihood ratios, diagnostic odds ratio, and
  confidence intervals". It is applied to the point estimates only -- `epi.tests()` is fed the raw
  table -- so the intervals are uncorrected and may be undefined for those statistics when a cell
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
  proceed if they disagree, and -- if the tag does not already exist -- tags `v<version>` and
  publishes a release whose notes are the matching section of this file.

# meddecide 0.0.47 (2026-07-05)

## Bug Fixes

* **Restored correct inter-rater agreement statistics on jamovi installs.**`vcd` and `lme4` are used by `agreement()` but were missing from the package `Imports`. Because jamovi installs only a package's `Imports`, on a clean install they were unavailable: pairwise kappa confidence intervals silently fell back to the narrower `irr::kappa2` null-SE method, and the entire ICC / Lin's CCC / continuous-agreement suite (which relies on `lme4`) was non-functional. Both are now declared, so agreement CIs use the intended `vcd::Kappa` asymptotic-SE method and the continuous-agreement measures work.
* Clarified the all-pairs kappa fallback note so it distinguishes a missing `vcd` package (with install guidance) from a genuinely near-degenerate table.
* Declared `DescTools` and `lmerTest`, previously used via `::` but undeclared.

# meddecide 0.0.46 (2026-07-04)

This release consolidates every change since 0.0.32.69 (unreleased versions 0.0.33 through 0.0.46 roll into this entry). The headline is a large expansion of **`agreement()`** into a comprehensive interrater/intrarater reliability suite (20+ new agreement statistics, tests, and visualizations), robustness and input-validation hardening of the ROC modules, one-sided confidence-interval support in the kappa sample-size tools, and package infrastructure updates (minimum jamovi app raised to 2.7.27, new imports, dataset cleanup).

## Major Changes

### `agreement()` -- Comprehensive Reliability Suite Expansion

The agreement module was expanded from Cohen's/Fleiss' Kappa into a full interrater/intrarater reliability toolkit. Each new statistic ships with its own results table, an "About ..." HTML explanation, and a "When to use ..." guide notice.

* **New chance-corrected / categorical measures:**
  - Gwet's AC1/AC2 (`gwet`, with `gwetWeights`: unweighted/linear/quadratic) -> `gwetTable`
  - PABAK with prevalence and bias indices (`pabak`) -> `pabakTable`
  - Light's Kappa for 3+ raters (`lightKappa`) -> `lightKappaTable`
  - Krippendorff's Alpha guidance (`showKrippGuide`)

* **New continuous-data agreement measures:**
  - ICC with six models ICC(1,1)-ICC(3,k) (`icc`, `iccType`) -> `iccTable`
  - Mean Pearson correlation (`meanPearson`) -> `meanPearsonTable`
  - Lin's Concordance Correlation Coefficient (`linCCC`) -> `linCCCTable`
  - Total Deviation Index (`tdi`, `tdiCoverage`, `tdiLimit`) -> `tdiTable`
  - Finn coefficient with one-way/two-way models (`finn`, `finnLevels`, `finnModel`) -> `finnTable`
  - Iota multivariate coefficient (`iota`, `iotaStandardize`) -> `iotaTable`

* **New ordinal / rank-based agreement measures:**
  - Kendall's W coefficient of concordance (`kendallW`) -> `kendallWTable`
  - Robinson's A ordinal agreement index (`robinsonA`) -> `robinsonATable`
  - Mean Spearman rho (`meanSpearman`) -> `meanSpearmanTable`

* **New marginal-homogeneity / rater-bias tests:**
  - Rater Bias test (`raterBias`) -> `raterBiasTable`
  - Bhapkar test (`bhapkar`) -> `bhapkarTable`
  - Stuart-Maxwell test (`stuartMaxwell`) -> `stuartMaxwellTable`
  - Maxwell's RE random-error index (`maxwellRE`) -> `maxwellRETable`

* **New multi-rater / structural analyses:**
  - Pairwise Kappa against a reference rater with performance ranking (`pairwiseKappa`, `referenceRater`, `rankRaters`) -> `pairwiseKappaTable`
  - Hierarchical/multilevel Kappa (`hierarchicalKappa`, `clusterVariable`) with cluster-specific estimates, variance-component decomposition, hierarchical ICC, cluster-homogeneity test, and shrinkage (empirical Bayes) estimates -> `hierarchicalOverallTable`, `clusterSpecificTable`, `varianceDecompositionTable`, `hierarchicalICCTable`, `homogeneityTestTable`
  - Mixed-effects condition comparison with Bonferroni/BH/Holm correction (`mixedEffectsComparison`, `conditionVariable`, `multipleTestCorrection`) -> `mixedEffectsTable`, `mixedEffectsVarianceTable`
  - Inter/intra-rater test-retest reliability (`interIntraRater`, `interIntraSeparator`) -> `interIntraRaterIntraTable`, `interIntraRaterInterTable`

* **New machine-learning-style metrics:**
  - Confusion matrix table with row/column normalization (`confusionMatrix`, `confusionNormalize`) -> `confusionMatrixTable`, `perClassMetricsTable`
  - Multi-annotator concordance / F1 (`multiAnnotatorConcordance`, `predictionColumn`) -> `concordanceF1Table`, `concordanceF1PerClassTable`
  - Specific (category-focused) agreement indices with optional CIs (`specificAgreement`, `specificPositiveCategory`, `specificAllCategories`, `specificConfidenceIntervals`) -> `specificAgreementTable`
  - Bootstrap confidence intervals (`bootstrapCI`, `nBoot`) -> `bootstrapCITable`

* **New visualizations:**
  - Agreement heatmap / confusion-matrix plot (`agreementHeatmap`) with color schemes (blue-red, traffic-light, viridis, grayscale) and count/percentage cell annotations (`heatmapColorScheme`, `heatmapShowCounts`, `heatmapShowPercentages`, `heatmapAnnotationSize`) -> `agreementHeatmapPlot`
  - Bland-Altman method-comparison output with a Shapiro-Wilk normality check (`showBlandAltmanGuide`) -> `blandAltmanHeading`, `blandAltmanExplanation`
  - Rater profile plots -- box/violin/bar (`raterProfiles`, `raterProfileType`, `raterProfileShowPoints`) -> `raterProfilePlot`
  - Rater clustering and case clustering with dendrograms and heatmaps -- hierarchical/k-means, correlation/euclidean/manhattan/agreement distances, average/complete/single/ward linkage (`raterClustering`, `caseClustering`) -> `raterClusterTable`, `raterDendrogram`, `raterClusterHeatmap`, `caseClusterTable`, `caseDendrogram`, `caseClusterHeatmap`
  - Stratified agreement-by-subgroup with forest plot (`agreementBySubgroup`, `subgroupVariable`, `subgroupForestPlot`, `subgroupMinCases`) -> `subgroupAgreementTable`, `subgroupForestPlotImage`

* **New workflow tools:**
  - Paired agreement comparison between two rater conditions with bootstrap (`pairedAgreementTest`, `conditionBVars`, `pairedBootN`) -> `pairedAgreementTable`
  - Sample-size calculator for agreement studies supporting Cohen's Kappa / Fleiss' Kappa / ICC (`agreementSampleSize`, `ssMetric`, `ssKappaNull`, `ssKappaAlt`, `ssNRaters`, `ssNCategories`, `ssAlpha`, `ssPower`) -> `agreementSampleSizeTable`

* **New computed output variables:**
  - Consensus rating variable with majority/supermajority/unanimous rules and tie handling (`consensusVar`, `consensusName`, `consensusRule`, `tieBreaker`) -> `consensusTable`, `consensusVar`
  - Case-level Level-of-Agreement categorization -- simple/detailed with custom/quartile/tertile thresholds (`loaVariable`, `detailLevel`, `simpleThreshold`, `loaThresholds`, `loaHighThreshold`, `loaLowThreshold`, `loaVariableName`, `showLoaTable`) -> `loaTable`, `loaDetailTable`, `loaOutput`

* **Other agreement additions:**
  - Configurable confidence level for CIs (`confLevel`)
  - Level-ordering information panel (`showLevelInfo`) -> `levelInfoTable`
  - Plain-language Summary, About, and Clinical Use Cases panels (`showSummary`, `showAbout`) -> `summary`, `about`, `clinicalUseCases`
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

* **`decisioncalculator()`**: Sensitivity/specificity confidence intervals now use a logit transformation with continuity correction (`sens_se = sqrt(1/TP + 1/FN)`, `spec_se = sqrt(1/TN + 1/FP)`) when a zero cell is present -- consistent with the existing PPV/NPV CI logic -- falling back to exact Clopper-Pearson binomial CIs otherwise

## Package Infrastructure

* Version bumped 0.0.32.69 -> 0.0.46; release date 2026-07-04; minimum jamovi app raised to 2.7.27 (`minApp`)
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
