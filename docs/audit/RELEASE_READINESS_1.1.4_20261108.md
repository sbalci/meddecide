# meddecide 1.1.4 release review — 2026-11-08

## Decision

The initial audited implementation passed the package, compiler and regression checks below.
A subsequent agreement UI follow-up is verified separately in
[AGREEMENT_UI_20261108.md](AGREEMENT_UI_20261108.md).
This review corrected material statistical documentation errors. It does **not**
constitute clinical validation or unconditional jamovi library clearance. Resolve
the dependency-license question and complete current desktop/platform acceptance
before describing the candidate as fully qualified for distribution.

The initial audit changed documentation only. The subsequent UI follow-up changes
the agreement welcome markup and options-panel guidance while preserving estimators,
defaults, clinical cutoffs, option/result schemas and generated headers. Changes remain
uncommitted. No release, push, submission or message to the jamovi team was made.

## Scope and provenance

- Target: `/Users/serdarbalci/Documents/GitHub/meddecide`, not the open OncoPath file.
- Inventory derived from `jamovi/0000.yaml`: 15 production analyses, including the
  three planners shown under Power. All four hand-maintained files exist for each.
- All 15 backend/option/UI/result file sets match the umbrella source byte for byte.
- DESCRIPTION, module metadata and CITATION specify 1.1.4. The checkout was clean
  before this review. NEWS previously started at 1.1.3.
- Review followed the audit-module/check-module procedures, with the user's
  documentation-update instruction taking precedence over the audit-only default.
- This is a bounded release review: package-wide gates and regression tests, targeted
  inspection of estimators and clinical statements, independent numerical probes,
  and native archive lifecycle probes. It is not a new line-by-line proof of all
  60,063 backend lines or every optional analysis/combination. Statistical coverage
  is limited to the fixtures and estimands identified below.

## Initial audit verification (before UI follow-up)

| Evidence | Result | Boundary |
|---|---|---|
| Installed-package test context | 1,226 assertions passed; 0 failures, errors, warnings or skips | Local R and dependency versions only |
| `R CMD check` | 0 errors, 0 warnings, 0 notes | `--no-manual --no-build-vignettes`; vignettes excluded by the package's existing build rules |
| Jamovi compiler and UI compiler | 15/15 passed; generated headers identical; UI input unchanged | Schema/compiler evidence, not desktop acceptance |
| Release gate before documentation update | 0 blocking, 4 advisory | One advisory was missing NEWS 1.1.4 |
| Release gate after documentation update | 0 blocking, 3 advisory | Advisories discussed below |
| Cross-analysis probes | 216 PASS, 17 INFO, 3 differences flagged | The three flags concern supported ranges/presentation/uncertainty contracts, not failed arithmetic |
| No-gold-standard independent probes | 132 PASS, 0 FAIL; 2 harness/design gaps | Independent latent estimation and simulation cases, including the executable vignette and bootstrap coverage; no clustered-data support |
| LASSO independent probes | 83 PASS, 2 flags, 2 desktop/native gaps in the historical harness | One table-note extraction mismatch; residual bootstrap optimism reproduced, already disclosed |
| Fixed-N independent probes | 164 PASS, 14 INFO | Quick mode; the large coverage-simulation section was not rerun |
| Decision-curve independent probes | 191 PASS, 4 flags, 1 skipped simulation section after adapting the notice extractor | Two flags are spelling expectations, two demonstrate unsupported case-control transport |
| Documentation build | Normal pkgdown site build completed: home, references, 19 articles, NEWS and indexes; corrected kappa pages refreshed afterward | Some articles intentionally show unevaluated examples; no site publication |
| Native 1.1.4 archive harness | 15 analyses serialized valid results; 18/18 recovery comparisons identical; 19 image-state redraws successful, recorded in 106 rows | Jamovi's bundled R/jmvcore; no new desktop save/reopen/export inspection |

Additional model-specific numerical and documentation-build results are recorded
with the evidence accompanying this report.

The generic `library(meddecide); test_dir()` diagnostic run could not find
non-exported Options classes. That runner did not reproduce the package's test
environment. The authoritative installed run used `test_local(load_package =
"installed")`; both it and R CMD check passed. Do not count the generic-runner
errors as user-facing calculation defects.

## Findings and corrections

### 1. Fixed-N kappa was incorrectly presented as power — corrected

The previous fixed-N guide called the result a power calculation and a minimum
detectable agreement, and claimed that clearing a clinical threshold established
adequate power. The implementation returns an **expected one-sided lower
goodness-of-fit confidence bound** around anticipated kappa. A realized interval
is random; its lower limit is not guaranteed to exceed the planning limit.

The replacement guide documents this estimand, the one-sided cutoff, common-margin
model, restricted-ML adjustment, sparse agreement-pattern cells, six-rater limit
and reporting language. README and the R-interface guide now use the same meaning.

### 2. Kappa CI planning was described as depending on the nearer limit — corrected

The goodness-of-fit model is asymmetric. The limit requiring more subjects governs;
it is not always the limit closest to the anticipated kappa. For anticipated 0.75
and requested limits 0.60/0.85, the lower limit governs despite being farther away.
The existing regression checks cover this example. The CI guide now distinguishes
expected precision from power, realized precision and a Wald interval's precision.

The power guide also no longer claims that `kappa1 > kappa0` is mandatory: the
two-sided implementation accepts a distinct lower alternative and warns about its
meaning. It tests one population kappa against a null; it does not compare two
panels or measure pre/post-training improvement.

### 3. Broad correctness and clinical-use claims exceeded the evidence — corrected

README previously said independent checks showed “the arithmetic is right.” It now
qualifies coverage by the methods and cases checked. The new methods guide covers
reference quality, selection/verification bias, prevalence transport, missing-data
denominators, clustering, cutpoint optimism, internal/external validation, calibration,
decision-curve utilities and latent-class assumptions.

The no-gold-standard vignette no longer says that a shared mechanism necessarily
violates independence or that a fourth test guarantees detection of dependence.
The fixed-prior `bayesian` option is MAP point estimation, not posterior sampling;
bootstrap intervals are not credible intervals. Reference-rule outputs remain
agreement with self-built rules, not diagnostic accuracy.

### 4. Cross-analysis differences require explicit interpretation — documented

The cross-analysis oracle found:

| Difference | Interpretation |
|---|---|
| `cotest` and `sequentialtests` reject prevalence 0.0004 | Their declared range is 0.001–0.999. Other diagnostic analyses allow rarer scenarios. A supported-range difference, not a Bayes-formula error. |
| Clinical ROC sensitivity uses 0–1 formatting while most diagnostic tables use percentages | Compare units before comparing displayed numbers. This remains a presentation inconsistency. |
| `decisioncompare` rejects supplied prevalence together with CI | The current method does not supply transported uncertainty for this combination. Other analyses' accepted combinations are not an identical inferential contract. |

Exact and Wilson intervals can differ legitimately. Comparisons must align coding,
denominators, interval methods and the population to which predictive values apply.

### 5. LASSO internal correction retains residual optimism — confirmed limitation

The independent FISTA/KKT, coefficient-to-prediction, performance and row-alignment
checks passed. The small prespecified simulation (30 datasets, N=150, eight
candidates, minimum-CV-error lambda, 50 bootstrap resamples, external N=5,000)
reproduced mean residual AUC optimism 0.0215 (MCSE 0.0068), versus apparent optimism
0.0570. This narrowly fails the oracle's prespecified tolerance of
`max(3*MCSE, 0.02)`. It supports the existing warning at
`R/lassologistic.b.R:2501` that the correction can remove only part of the optimism;
it does not establish a new implementation defect or an unbiased external estimate.
No tolerance or numerical expectation was relaxed after observing the result.

The other flag checks old HTML suitability prose. The same EPV convention/Riley
caution is now in the native table's `source` footnote at
`R/lassologistic.b.R:836`; the adapted extractor checked only its result cells.
Native serialization was tested separately; client display of the zero-term
coefficient plot still needs desktop acceptance.

### 6. DCA cannot transport a case-control sampling fraction — documented limitation

`R/decisioncurve.b.R:457` computes `TP/n - FP/n * t/(1-t)` and the treat-all line
uses the observed event fraction. The independent case-control probe reproduced
NB 0.259875 versus cohort NB 0.037275 at t=0.20; treat-all at t=0.30 was 0.285714
versus −0.223836. These are different target populations, not an error in the
net-benefit formula. The implementation already discloses the limitation at
`R/decisioncurve.b.R:2000`; it has no external-prevalence correction option.

The co-testing guide also now states the direction-specific AND/OR trade-offs
under positive conditional dependence, removes an arbitrary “conservative”
dependence range, and identifies its named scenarios as hypothetical. The sequential
guide's table is now a Boolean-rule/workload illustration, rather than clinical
strategy-selection guidance.

The new guide states this limitation and the distinction between net benefit,
utility-scaled interventions avoided and observed health outcomes. Ratio-based
sampling warnings cannot establish the actual design.

The historical DCA oracle's HTML title extractor needed to remove the subsequently
added severity prefix. After that extractor-only adaptation, two remaining text
flags compare British “analysed” with current “analyzed”; the disclosure and
out-of-range warning are present. The other two numerical flags are the
case-control limitation above. Raw/adapted results are retained separately; none
of these flags was silently converted into a numerical pass.

## Per-analysis coverage and remaining clinical requirements

All analyses below pass the current regression/compiler checks. “Covered” names
the focused checks; it does not certify every optional method or clinical use.

| Analysis | Focused coverage | Clinical/design requirement |
|---|---|---|
| agreement | Hand Cohen kappa, rater-margin distinction, resampling helpers and regression cases | Correct scale, rater design, ICC estimand, missingness and patient unit; no universal acceptance bands |
| cotest | Bayes transport and joint-positive agreement with sequential strategy | Conditional dependence inputs must be justified within disease groups |
| decision | Hand 2×2 estimates, exact/log-ratio intervals, zero cells and rare prevalence | Representative reference-verified population |
| decisioncalculator | Same hand counts, F1, uncertainty and workload | Valid counts and defensible target prevalence |
| decisioncombine | Observed patterns, Wilson/log intervals and paired helpers | Complete-case denominator and verification bias |
| decisioncompare | Paired differences, marginal accuracy, interval-method distinctions | Paired tests within independent patients; multiplicity and denominators |
| decisioncurve | Hand fractions, independent dcurves comparisons, plot/table agreement and edge cases | Calibrated risks; representative outcome rate; clinically chosen utilities; no censoring |
| enhancedROC | Rank AUC/DeLong, direction, binary marker, threshold and PR calculations | Locked threshold/model and independent validation |
| kappaSizeCI | Governing-limit regression and planner/estimator distinction | Expected goodness-of-fit limits; simulation for intended analysis |
| kappaSizeFixedN | Independent cell models and bound solvers | Expected one-sided bound; no achieved-power guarantee |
| kappaSizePower | Regression and agreement-planner reconciliation | Approximation/simulation notices; common-correlation target |
| lassologistic | Penalized-model, row mapping and performance regression; model-specific oracle evidence | Apparent versus internal/external validation; score requires its own validation |
| nogoldstandard | Latent/rule-method regression; model-specific oracle evidence | Identification, class orientation, conditional independence and complete cases |
| psychopdaROC | Rank AUC/logit-DeLong, direction, PR calculations and regression | Patient summaries and threshold selection must match the intended unit |
| sequentialtests | Conditional-independence Bayes reconciliation and regression | Accuracy/prevalence/cost inputs are fixed assumptions, not clinical pathways |

## Documentation build and final checks

README was regenerated from the new README.Rmd. The normal repository site build
completed after enabling public-metadata/cache access; the initial restricted
attempts failed at CRAN lookups. The standard publishing configuration was not
changed to the temporary preview overrides. The home/reference/NEWS pages and all
19 articles were generated; final kappa article corrections were then refreshed.
Pandoc emitted deprecation warnings for pkgdown's math flags. Final local-link
checks found zero missing targets across the home/NEWS/19 article pages; six
rendered-content checks confirmed the corrected statistical wording.

Several older comprehensive articles deliberately set `eval = FALSE` or gate
execution on external umbrella data. Rendering them is not execution evidence.
The no-gold-standard independent harness executes its vignette; the new fixed-N
and methods examples execute during the article build. The static documentation
API scan found no mismatch rows in parsable R fences.

At the close of the initial audit, all reviewed R/schema/namespace/metadata hashes
were unchanged. The subsequent UI changes have a separate source manifest and
verification record in the follow-up report. `git diff --check`
reports one trailing space generated in `docs/reference/nomogrammer.md:215` from
printed example output; generated output was not hand-edited to hide it.

## Submission review items

1. **Dependency-license clarification.** Both the build and the tested archive
   include `pander`, imported by `epiR`. Its DESCRIPTION says `AGPL-3 | file LICENSE`;
   its LICENSE contains OSL-3.0. The gate's AGPL substring warning is therefore
   broader than “AGPL-only”: the alternative must be considered. R's license syntax
   treats `|` as alternatives. This review does not establish the distribution
   compatibility/acceptance of that route. Record the proposed route and obtain the
   jamovi team's determination before calling the licensing item closed.
   [R license syntax](https://cran.r-project.org/doc/FAQ/r-devel/R-exts.html),
   [jamovi distribution requirements](https://dev.jamovi.org/tutorial/tuts0111-distributing-modules).
2. **UI follow-up applied.** The welcome layout now uses stacked headings and lists,
   removing the HTML-table scanner warning. The positive-category field remains text
   because it spans all selected raters, but it now has a read-only available-category
   hint. Matching/validation semantics are preserved. A selector remains a possible
   future enhancement, rather than a release blocker. The post-change gate reports
   **0 blocking, 2 advisory** findings: dependency licensing and the intentionally
   retained String category option. See the separate UI follow-up report for current
   verification; the initial audit's hashes, package checks and archive tests describe
   the pre-UI baseline.
3. **Desktop and platform acceptance.** Recalculate the eight bundled example OMVs
   with the final candidate; inspect error overlays, saved/reopened results, plots,
   computed-variable row alignment and HTML/PDF export. Native R serialization and
   redraw are separate evidence. The current local `.jmo` is platform-specific;
   it does not demonstrate Windows/Linux/other-architecture acceptance.
4. **Final source publication.** Commit reviewed source/documentation deliberately,
   build from that exact commit and rerun required checks. The existing archive was
   examined, not rebuilt with the documentation/UI changes. No `.jmo` or build directory
   is tracked in git. Do not equate a local artifact with a published/library version.
5. **Library workflow.** The current official process uses the
   [submission form](https://dev.jamovi.org/submit) for new modules and updates,
   followed by maintainer email confirmation and review. A GitHub push alone does
   not update the library. No submission was sent in this session.

## Artifact and reproducibility

Tested existing archive: `meddecide_1.1.4.jmo`.

SHA-256: `e00d73113e9d84c8afd01fe2780e0f957d44be70d6ce1b4e4a850d7d8fd92106`.

Evidence is retained under `docs/audit/evidence/20261108/`; large disposable runtime
libraries and the check working directory are under
`/private/tmp/meddecide-release-20261108/`. The evidence README records commands,
oracle adaptations, exclusions and result-file meanings. Historical source scripts
were reused as probes against **current** sources; their old header dates are not
current validation claims.
