# Module audit report — meddecide 1.1.1

> **Superseded for correctness (2026-10-21, later the same day).** An independent review with executed oracles found one S1 and five S2 defects that this static audit graded READY. All six were fixed and re-verified in jamovi's engine before release; see `ClinicoPathJamoviModule/development-ideas/independent-review-2026-10-21-summary.md`. The M1 list below has been corrected to cotest, decision and decisioncombine.

**Audited:** 2026-10-21 10:00 (+03) · **Profile:** standard · **Skill:** audit-module v0.1.0
**Target:** `/Users/serdarbalci/Documents/GitHub/meddecide` at `403e034` (working tree clean) · **Umbrella:** `/Users/serdarbalci/Documents/GitHub/ClinicoPathJamoviModule`
**Functions:** 15 · READY 15 · NEEDS WORK 0 · PLACEHOLDER 0 · MISSING 0 · ORPHANED 0
**Security catalog:** HIGH 0 · MEDIUM 0 · LOW 3 · **Functional:** CRITICAL 0 · HIGH 0 · MEDIUM 11 · LOW 63
**Previous audit:** [MODULE_AUDIT_REPORT_20261020-1153.md](MODULE_AUDIT_REPORT_20261020-1153.md) (1.1.0, verdict HOLD)

## Verdict

**No blocking defect in the shipped surface. The HOLD from 2026-10-20 is lifted.** Yesterday's HIGH (F1:
`decisioncalculator` narratives surviving an invalid rerun) and the MEDIUM (F2: four fatal-input paths
completing normally) are fixed in the shipped code. Yesterday's broken R syntax export (F3) is fixed in all
four analyses, and an executed probe also confirms it for two more. The release gate reports 0 blocking
issues, and the installed-namespace smoke test passes.

**Recommended before release:** fix the stale-notices pattern in five analyses (one line each), plus the three
`decisioncompare` MEDIUMs and the `enhancedROC` silent null-model swap. The other MEDIUMs (raw-HTML tables,
NaN cells, ERROR→reject) can follow. "READY" here means the reviewed technical surface; 11 of 15 analyses are
`NEEDS_VALIDATION` for clinical use (no independent oracle run in this audit).

### The 11 MEDIUM findings

| # | Analysis | Finding | Evidence |
|---|---|---|---|
| M1 | cotest, decision, decisioncombine | A run that ends with no notices blanks the panel with `setContent("")`; the jamovi client skips empty Html updates, so the **previous run's warnings stay on screen** ([R/cotest.b.R:1324](R/cotest.b.R#L1324), [R/decision.b.R:508](R/decision.b.R#L508), [R/decisioncombine.b.R:140](R/decisioncombine.b.R#L140)). Fix: `"<div></div>"`. *(Corrected 2026-10-21: decisioncalculator removed — its notices item is Preformatted, which `setContent("")` does clear; sequentialtests removed — its success path always adds an "Analysis Complete" INFO notice, so its `""` branch is unreachable; engine runs never sent an empty panel.)* | Client source, jamovi 28.13 `resultsview-*.js`: ``e.content!==`` `` gates `replaceChildren` (read 2026-10-21) |
| M2 | decisioncompare | Zero-cell LR correction also fires on a zero **numerator**: FN=0 turns raw LR− = 0 into 0.0123, while three notes say it applies only to an empty denominator ([R/decisioncompare.b.R:1548](R/decisioncompare.b.R#L1548)) | Executed probe P6 |
| M3 | decisioncompare | Choosing variables before levels raises a red ERROR ("Validation failed"); Level options are `allowNone: true` ([R/decisioncompare.b.R:1032](R/decisioncompare.b.R#L1032)) | Executed probe P8 |
| M4 | decisioncompare | ERROR text names the renamed checkbox "Exclude other observed levels" ([R/decisioncompare.b.R:379](R/decisioncompare.b.R#L379), [R/utils-diagnostic-comparator.R:38](R/utils-diagnostic-comparator.R#L38)) | Static |
| M5 | enhancedROC | Score scale + slope contradicting Direction → `.riskProbabilities()` substitutes a constant-prevalence model; Brier (0.25 = p(1−p)), HL and calibration outputs describe it under the marker's name, and no notice says so ([R/enhancedROC.b.R:2623](R/enhancedROC.b.R#L2623)) | Executed probe P1: a "Marker Reads Backwards" ERROR fires only when the AUC CI excludes 0.5 |
| M6 | enhancedROC | All predictors fail → ERROR banner + normal completion instead of `reject()` ([R/enhancedROC.b.R:580](R/enhancedROC.b.R#L580)) | Static |
| M7 | decisioncombine | Undefined statistics written as `NA_real_` render "NaN", while notes promise blank ([R/decisioncombine.b.R:2317](R/decisioncombine.b.R#L2317)) | jmvcore 2.7.38 `Cell$asProtoBuf` (executed 2026-10-07) |
| M8 | lassologistic | Computed EPV/N/balance/\|r\| in a raw HTML `<table>` ([R/lassologistic.b.R:835](R/lassologistic.b.R#L835)) | Static |
| M9 | psychopdaROC | Confusion matrices as raw HTML with hard-coded black border and untranslated title ([R/psychopdaROC.b.R:5177](R/psychopdaROC.b.R#L5177)) | Static |

M1 counts once per analysis (3), so the table's 9 rows hold 11 findings.

## Scope and provenance

- **Inventory:** `jamovi/0000.yaml` declares 15 analyses; all have the full file set (`.a/.u/.r.yaml`, `.b.R`,
  `.h.R`; JS for `cotest`, `kappaSizeCI`, `kappaSizeFixedN`, `kappaSizePower`, `sequentialtests`). Routing:
  12 `meddecide` + 3 `Power` (kappaSize*), all production. The umbrella stages 1 `meddecideT`, 1 `meddecideP`,
  11 `meddecideD` and 47 `meddecideExtraD` analyses that this sibling does not ship (no promotion debt in the shipped module).
- **Drift:** every audited analysis file (`.b.R`, three yaml, JS) is **byte-identical** to the umbrella, so all
  line numbers apply to both repos. Yesterday's five staged repairs (`agreement`, `decision`,
  `decisioncalculator`, `decisioncombine`, `enhancedROC`) are now promoted and shipped. `R/enhancedROC-errors.R`
  differs only by a trailing newline. 52 files changed since the 2026-10-20 audit, so this is a full re-audit,
  not a delta.
- **Method:** one subagent per analysis made a static read of the full file set and all reachable helpers, then
  re-checked every prior finding against current code. PLAUSIBLE claims were then executed in the main session
  (one R process, `pkgload::load_all`, R 4.6.0, jmvcore 2.7.38). Four claims were corrected after verification (see below).

## Runtime verification (executed 2026-10-21)

| Probe | Claim | Result |
|---|---|---|
| P1 | enhancedROC silent null-model swap | **Confirmed** (M5) |
| P2 | Syntax export with spaced column names (decision, decisioncurve, lassologistic, agreement, enhancedROC, psychopdaROC) | **Fixed**: parses *and* evaluates in all six. A candidate decisioncurve G-LOW (unset Level omitted → "argument missing") was **refuted**: the export of a default run evaluated |
| P3 | cotest footnote cut at `" ["` | **Refuted**: "HPV [hr]" survives in full |
| P4 | agreement 3-rater subgroup CI method undisclosed | **Confirmed** (LOW) |
| P5 | decisioncalculator F1 protobuf replay | **Not run**: RProtoBuf is not installed on this machine. F1 FIXED rests on static reading plus the `setContent`-simulated regression test |
| P6 | decisioncompare LR− with FN = 0 | **Confirmed** (M2) |
| P7 | psychopdaROC misclassification-cost / total-utility metrics ≡ accuracy (cutpointr unit costs never passed) | Probe not discriminating; **confirmed analytically** (FP+FN and 2(TP+TN)−n are monotone in accuracy). LOW |
| P8 | decisioncompare ERROR before levels chosen | **Confirmed** (M3) |
| — | nogoldstandard poLCA `probs` column names vs response levels | **Refuted**: identical, so the bivariate-residual path fills |
| — | sequentialtests citation "no title / Cohen DOI" | **False positive**: the entry is correct |
| — | lassologistic `fatal-not-reject` tag | Mis-tag; every configured-invalid path calls `reject()` |

## Module-wide release gates

| Gate | Result |
|---|---|
| DESCRIPTION `Version` ≥ 1.0.0 | **PASS** (1.1.1; consistent across DESCRIPTION / 0000.yaml / CITATION.cff; NEWS heading present) |
| `tools/release_gate.py --root ../meddecide` | **0 blocking, 1 advisory**. All checks zero: citations 141/141, 0 dangling; clearWith 0 dangling; requiresData 0/0; renderer private state 0; bare `set.seed` 0; unused Imports 0 of 30; CollapseBox case 0; `.()` separators 0; `" ["` 0; format tokens 0; fabricated statistics 0; heavy setState 0; `$insert()` sentinel 0; fixed rows in `.run()` 0 *tables* (the gate counts tables; agents flag 4 analyses with fixed-label rows, see sections); 8 datasets OK |
| Licence (advisory) | **WARN**: AGPL `pander` ships in `build/R4.6.0-arm64-macos`, pulled in transitively by `epiR` (meddecide never calls pander). The library does not accept AGPL-3, so ask the jamovi team or isolate the epiR use |
| `Rscript --vanilla tools/submodule_smoke.R ../meddecide` | **PASS**: 0 findings, 1,945 functions scanned (installed namespace) |
| Undeclared deps (`pkg::`, `requireNamespace`) | **0**: `psych::`, `rms::`, `survival::` etc. appear only in comments or user-facing strings |
| Unguarded `image$state` (`check_state_guards.py`) | **0** |
| Theme-unsafe HTML (`theme_safe_html.py`) | **0** in the 15 backends |
| Named HTML symbol entities | **0** |
| Committed build artifacts | **0**: root `*.jmo` / `meddecide_1.0.0.tar.gz` are untracked and git-ignored |
| Dataset documentation | **PASS (corrected 2026-10-21 by executed check)**: the six objects first reported as phantom (`breast_data`, `cancer_data`, `cardiac_data`, `master_data`, `sepsis_data`, `thyroid_data`) exist inside the multi-object files `breast_diagnostic_styles.rda` and `roc_analysis_test_data.RData`; `data(package = "meddecide")` in the installed 1.1.1 module lists them. The two file names are containers, not undocumented datasets. Earlier wording here was a false positive from comparing file names with object names |
| Sibling-only source files | 14 `R/data_*.R` dataset-doc files exist only in the sibling (outside the updater's `data-*.R` naming) |
| Unused helper functions | 9 LOW: `enhancedROC-errors.R` (6 of 12: `safe_execute`, `get_error_summary`, `clear_error_log`, `clinicopath_cleanup`, `get_clinical_context`, `create_enhanced_result`); `utils-formula.R` (`.escapeVariableNames`, `.asSurvivalFormula`, a survival helper in a module with no survival analysis); `utils.R` (`.stripPrefix`) |
| Turkish catalog | **870 of 7,799** msgids in `jamovi/i18n/tr.po` have an empty `msgstr` (e.g. kappaSizePower's two validation messages). Format specifiers: 0 mismatched |
| clearWith gaps | 1 analysis (`agreement`: `exct` and `wght` missing from the subgroup table and forest plot) |
| UI label deviations | 8 analyses (see cross-cutting) |
| `minApp` | 2.7.27; no 28.3 File/Text/vector features used, so no `minApp` gate applies |

## Executive dashboard

**15 analyses:** READY 15 · NEEDS WORK 0 · PLACEHOLDER 0 · MISSING 0 · ORPHANED 0.  
**Security catalog:** HIGH 0 · MEDIUM 0 · LOW 3.  
**Functional:** CRITICAL 0 · HIGH 0 · MEDIUM 11 · LOW 63.

All 15 analyses are in a production menuGroup (12 `meddecide`, 3 `Power`), so every count below is a **shipped** count; the module carries no D/P/T analyses (promotion debt 0).

| Analysis | Group | Status | Sec H/M/L | Func C/H/M/L | i18n | Clinical readiness | Prior findings fixed |
|---|---|---|:---:|:---:|---|---|---|
| [agreement](#agreement) | meddecide | ✅ READY | 0/0/0 | 0/0/0/6 | PARTIAL | NEEDS_VALIDATION | 4/5 fixed; still present: F9 |
| [cotest](#cotest) | meddecide | ✅ READY | 0/0/0 | 0/0/1/2 | COMPLETE | READY | 0/0 fixed; still present: none |
| [decision](#decision) | meddecide | ✅ READY | 0/0/0 | 0/0/1/6 | PARTIAL | NEEDS_VALIDATION | 2/3 fixed; still present: F9 |
| [decisioncalculator](#decisioncalculator) | meddecide | ✅ READY | 0/0/0 | 0/0/0/6 | COMPLETE | NEEDS_VALIDATION | 2/3 fixed; still present: F9 |
| [decisioncombine](#decisioncombine) | meddecide | ✅ READY | 0/0/0 | 0/0/2/3 | COMPLETE | NEEDS_VALIDATION | 3/3 fixed; still present: none |
| [decisioncompare](#decisioncompare) | meddecide | ✅ READY | 0/0/1 | 0/0/3/4 | COMPLETE | NEEDS_VALIDATION | 1/1 fixed; still present: none (the F7 rename of excludeIndeterminate left the bin_other ERROR text stale, reported as a new MEDIUM) |
| [decisioncurve](#decisioncurve) | meddecide | ✅ READY | 0/0/0 | 0/0/0/2 | PARTIAL | READY | 1/3 fixed; still present: F7 (partially — u.yaml labels Title Case at u.yaml:20,29,57), F9 |
| [enhancedROC](#enhancedroc) | meddecide | ✅ READY | 0/0/2 | 0/0/2/5 | PARTIAL | NEEDS_VALIDATION | 1/1 fixed; still present: none |
| [kappaSizeCI](#kappasizeci) | Power | ✅ READY | 0/0/0 | 0/0/0/2 | COMPLETE | NEEDS_VALIDATION | 0/0 fixed; still present: none |
| [kappaSizeFixedN](#kappasizefixedn) | Power | ✅ READY | 0/0/0 | 0/0/0/3 | COMPLETE | NEEDS_VALIDATION | 0/0 fixed; still present: none |
| [kappaSizePower](#kappasizepower) | Power | ✅ READY | 0/0/0 | 0/0/0/3 | PARTIAL | READY | 0/0 fixed; still present: none |
| [lassologistic](#lassologistic) | meddecide | ✅ READY | 0/0/0 | 0/0/1/4 | COMPLETE | NEEDS_VALIDATION | 1/1 fixed; still present: none |
| [nogoldstandard](#nogoldstandard) | meddecide | ✅ READY | 0/0/0 | 0/0/0/7 | PARTIAL | NEEDS_VALIDATION | 1/1 fixed; still present: none |
| [psychopdaROC](#psychopdaroc) | meddecide | ✅ READY | 0/0/0 | 0/0/1/7 | PARTIAL | NEEDS_VALIDATION | 1/2 fixed; still present: F9 |
| [sequentialtests](#sequentialtests) | meddecide | ✅ READY | 0/0/0 | 0/0/0/3 | COMPLETE | READY | 0/1 fixed; still present: F9 |

## Cross-cutting issues

Tags reported by two or more analyses (all shipped).

- **`run-too-long`** — .run() far beyond ~120 lines — **11**: `agreement`, `cotest`, `decision`, `decisioncalculator`, `decisioncurve`, `enhancedROC`, `kappaSizeFixedN`, `kappaSizePower`, `lassologistic`, `psychopdaROC`, `sequentialtests`
- **`i18n-fragment`** — Translatable strings glued from fragments — **8**: `decisioncompare`, `enhancedROC`, `kappaSizeCI`, `kappaSizePower`, `lassologistic`, `nogoldstandard`, `psychopdaROC`, `sequentialtests`
- **`ui-label-convention`** — UI labels deviate from jamovi conventions — **8**: `decision`, `decisioncalculator`, `decisioncombine`, `decisioncompare`, `decisioncurve`, `enhancedROC`, `kappaSizeFixedN`, `psychopdaROC`
- **`i18n-unwrapped`** — User-visible strings not wrapped in .() — **7**: `agreement`, `decision`, `decisioncalculator`, `decisioncurve`, `enhancedROC`, `nogoldstandard`, `psychopdaROC`
- **`estimand-label`** — Displayed label/footnote misdescribes the estimand or method — **5**: `agreement`, `decisioncompare`, `kappaSizeCI`, `kappaSizeFixedN`, `psychopdaROC`
- **`stale-output-on-rerun`** — A previous run's notices stay on screen (panel blanked with setContent(""), which the client skips) — **5**: `cotest`, `decision`, `decisioncalculator`, `decisioncombine`, `sequentialtests`
- **`fixed-rows-in-run`** — Fixed-structure table rows built in .run() instead of .init() — **4**: `decisioncalculator`, `decisioncombine`, `lassologistic`, `nogoldstandard`
- **`fatal-not-reject`** — Fatal configuration errors shown as an ERROR notice + return instead of jmvcore::reject() — **3**: `agreement`, `decisioncompare`, `enhancedROC`
- **`raw-html-table`** — Tabular data drawn as raw HTML <table> — **3**: `agreement`, `lassologistic`, `psychopdaROC`
- **`sec-D-html-escape`** — User strings concatenated into HTML without escaping — **2**: `decisioncompare`, `enhancedROC`
- **`silent-fallback`** — A failed step silently falls back to a plausible-looking value — **2**: `decision`, `enhancedROC`

Single-analysis tags: `bare-warning` (nogoldstandard); `clearwith-gap` (agreement); `declared-unpopulated` (psychopdaROC); `error-on-empty-input` (decisioncompare); `heavy-state` (enhancedROC); `palette-no-jamovi` (decisioncalculator); `perf` (decisioncompare); `sec-H-debug` (enhancedROC); `stats-unverified` (kappaSizeFixedN).

## Per-analysis sections

### agreement

**Status:** ✅ READY (LOW-only findings on the reviewed surface; statistics NEEDS_VALIDATION as a whole)
**Files:** [`R/agreement.b.R`](R/agreement.b.R) · [`jamovi/agreement.a.yaml`](jamovi/agreement.a.yaml) · [`jamovi/agreement.u.yaml`](jamovi/agreement.u.yaml) · [`jamovi/agreement.r.yaml`](jamovi/agreement.r.yaml) · helpers [`R/agreement-latent.R`](R/agreement-latent.R), [`R/utils-syntax-exports.R`](R/utils-syntax-exports.R)
**Metrics:** .b.R LOC 17,603 (143 private methods) · options 161 · outputs 122 top-level (9 Images) · UI controls 762-line u.yaml · JS 0 (`agreement.events.js` deleted in 6ae7c93) · menuGroup `meddecide` (shipped)

#### Changes since 2026-10-20 audit

| Prior | Then | Now |
|---|---|---|
| F3 (LOW-G) syntax export breaks on spaced column names | `vars = vars(test with space, ...)` | **FIXED (static)** — [R/agreement.b.R:20](R/agreement.b.R#L20) `.sourcifyOption` routes through [R/utils-syntax-exports.R:3](R/utils-syntax-exports.R#L3), which `deparse()`s character values (`vars = c("test with space", ...)`); regression tests added in 6ae7c93. Not executed here. |
| F4 (MEDIUM) events.js silently clamps LoA coverage | `95 → 0.99` | **FIXED** — events.js removed; backend now `reject()`s out-of-range coverage at [R/agreement.b.R:16002](R/agreement.b.R#L16002). |
| F5 (LOW) null-SE fallback "too narrow / optimistic" claim | 5 notes | **FIXED** — every fallback note now says "coverage at nonzero kappa is uncertain" (e.g. [R/agreement.b.R:8224](R/agreement.b.R#L8224), [:16456](R/agreement.b.R#L16456)); old msgid is `#~` obsolete in tr.po. |
| F6 (LOW i18n) educational guides untranslated | `.populateGwetExplanation` etc. | **FIXED** for the named panels — sentences wrapped with markup as format args ([R/agreement.b.R:1139](R/agreement.b.R#L1139)) and translated in tr.po. Residual unwrapped literals elsewhere: new finding 4. |
| F9 (advisory) `.run()` length | 15332–17038 (1707) | **STILL PRESENT** — [R/agreement.b.R:15903](R/agreement.b.R#L15903)–17598 (~1,696 lines). |
| `gradingHeading` no body setter | info | Unchanged; heading-only Preformatted idiom, not a defect. |

**Today's commit 403e034** (subgroup kappa, [R/agreement.b.R:6038–6108](R/agreement.b.R#L6038)): 3+ rater subgroups now use `.fleissAllRatings()` (all observed ratings, Fleiss/Conger per `exct`, Gwet subject-sampling SE, t interval on n−1 df) — the same estimator as the headline ([:16313](R/agreement.b.R#L16313)) and the hierarchical cluster table ([:12612](R/agreement.b.R#L12612)). Verified: label now honours `exct` via `.kappaLabel(..., exact=)`; `n_cases` switches to subjects-with-a-rating; one-category subgroups return `NaN` → "Not estimable" path; the 2-rater null-SE fallback is now gated to `n_raters == 2`. Estimator change is correct. Two loose ends it left behind are findings 1 and 2.

#### Security

*No findings in profile standard.* No evaluator/formula/system/deserialisation sinks. User strings into notes go through `.noteSafe()` ([R/agreement.b.R:252](R/agreement.b.R#L252), `htmlEscape` + bracket swap); free-text `consensusName`/`loaVariableName` are `htmlEscape`d before HTML ([R/agreement.b.R:12098](R/agreement.b.R#L12098)). Seeds use `withr::local_seed` (no bare `set.seed`). Category G closed (F3).

#### jmvcore migration

*No migration opportunities found.* No `as.formula`, `na.omit` on attributed frames in user paths, or `insert()` calls.

#### Integration

**Arguments declared:** 161 · **used in logic:** 160 · **dead:** 0 (`allPairsCI` is consumed by an r.yaml `visible:` expression only — by design)

| Argument | Type | Default | Used? | In logic? | Notes |
|---|---|---|:---:|:---:|---|
| `exct` | Bool | false | ✅ | ✅ | Since 403e034 it changes the subgroup table's value and label, but is absent from `subgroupAgreementTable` / `subgroupForestPlotImage` `clearWith` (finding 2) |

**Outputs declared:** 122 · **populated:** 121 · **unpopulated:** 1 (`gradingHeading`, heading-only)

Renderers: all 9 Images read only `image$state`, each with an `is.null` guard (e.g. [R/agreement.b.R:15754](R/agreement.b.R#L15754), [:5887](R/agreement.b.R#L5887)); none touches `self$data`, and none declares `requiresData: true` — contract satisfied. State payloads are drawing frames; the case heatmap is subsampled to ≤200 cases ([R/agreement.b.R:7230](R/agreement.b.R#L7230)). Rows:0 tables are reset at the top of `.run()` ([R/agreement.b.R:15924](R/agreement.b.R#L15924)) and all table notes are cleared each run ([:15992](R/agreement.b.R#L15992)), which mitigates most clearWith gaps. `format:` tokens all valid (`zto,pvalue`, `pc`, `zto`).

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs (<2 raters) | quiet welcome | ✅ | n/a | Instructions panel, no red error ([R/agreement.b.R:16019](R/agreement.b.R#L16019)) |
| Empty data / invalid LoA coverage | `reject()` | ✅ | ✅ | [:16072](R/agreement.b.R#L16072), [:16002](R/agreement.b.R#L16002); not inside a catch-all |
| Low n | table note | ✅ | ✅ | `small_sample` notes quote simulated coverage, method-specific ([:16376](R/agreement.b.R#L16376)) |
| Prevalence imbalance (kappa paradox) | table note | ✅ | ✅ | [:16592](R/agreement.b.R#L16592) |
| Failed optional step | table note | ✅ | — | ~30 `setNote("error", ...)` sites; documented maintainer decision ([:15904](R/agreement.b.R#L15904)) |
| Configured-invalid optional sub-feature | table note | ⚠️ | — | finding 3 |

No `jmvcore::Notice` used (table notes + Html panels throughout); none required by the brief.

#### Code review

- **Overall quality:** 3/5 stars (exceptionally well-annotated, but monolithic)
- **Architecture:** 17.6k-line single class; `.run()` ~1,696 lines
- **Mathematical/statistical correctness:** MINOR_ISSUES (scoped). Checked against sources: `.fleissAllRatings` kappa = (pa−pe)/(1−pe) rebuilt from irrCAC components, t(n−1) interval and two-sided p (Gwet 2014; irrCAC 1.4 source as cited); `.pairKappaWithCI` Fisher-z SE = ASE/(1−κ²) (delta method, correct), Wald clamp, vcd non-null ASE; null-SE fallback = κ/z from irr::kappa2. Whole-analysis (ICC, Krippendorff, latent model, TDI, Finn, iota…) NOT independently re-validated.
- **Clinical readiness:** NEEDS_VALIDATION
- **i18n coverage:** PARTIAL

**Coordinator item — the two "z and p" notes.** Both are accurate for the table they decorate; no finding.
- [R/agreement.b.R:8421](R/agreement.b.R#L8421)/[:8428](R/agreement.b.R#L8428) decorate `interIntraRaterInterTable` (2 rater×time columns, vcd branch). There `p_value <- kc_inter$p` ([:8354](R/agreement.b.R#L8354)) and `.pairKappaWithCI` sets `z = kappa / ase`, `p = 2*pnorm(-|z|)` ([:10105](R/agreement.b.R#L10105), [:10116](R/agreement.b.R#L10116)). That is a Wald test with the same non-null ASE as the interval, so "divides kappa by the same standard error" is true for both Wald and Fisher-z modes. The irr-fallback branch gets its own note.
- [R/agreement.b.R:16463](R/agreement.b.R#L16463)/[:16466](R/agreement.b.R#L16466) decorate the headline `irrtable` (2 raters). Its z/p come from `result2 <- .kappa2Ordered()` = `irr::kappa2`, which uses the variance under H0 ([:16280](R/agreement.b.R#L16280), [:16406](R/agreement.b.R#L16406)). So "use the null standard error" is true there.
- They differ because the two tables use different but valid tests (score-type null-SE vs Wald non-null ASE), and each table discloses its own test. INFO only: the same coefficient type gets a differently built p in two tables. Unifying them would be a design choice, not a correction.

**Top issues:**

1. **LOW** — The subgroup table's CI disclosure is stale after 403e034. The `ci_null_se` note still ends "three or more raters always use this fallback" ([R/agreement.b.R:6261](R/agreement.b.R#L6261)). That is no longer true: `used_null_se` is now set only for 2 raters. Since that is the only case where the note fires, a reader of a 2-rater table is told something false about 3+ raters. For 3+ raters the new Gwet-SE t-interval is undisclosed, and it ignores `kappaCIMethod` (Fisher z), which 2-rater rows honour ([:6103](R/agreement.b.R#L6103)). Fix: drop the clause and add a `ci_method_fleiss` note mirroring the headline's Gwet note ([:16497](R/agreement.b.R#L16497)). The msgid is also untranslated (tr.po:12237 `msgstr ""`). `/fix-function agreement`
2. **LOW** — clearWith gap introduced by 403e034. `exct` now changes subgroup values and labels, but `subgroupAgreementTable` ([jamovi/agreement.r.yaml:2221](jamovi/agreement.r.yaml#L2221)) and `subgroupForestPlotImage` ([:2239](jamovi/agreement.r.yaml#L2239), which also lacks `wght`) do not list it. Rows are reset and the state is re-set every run, so practical staleness is limited (no restored-row duplication). Add `exct` (and `wght` on the image). `/fix-function agreement`
3. **LOW** — A configured-invalid specific-agreement setup (cluster ID with non-bootstrap CI, unaligned or blank cluster IDs) raises bare English `stop()` ([R/agreement.b.R:4687–4692](R/agreement.b.R#L4687)). It is caught at [:4937](R/agreement.b.R#L4937) and shown as an "Error calculating specific agreement: …" table note, with the message untranslated and the analysis completing. That fits the documented best-effort policy, but the reason should be translated (via `self`-context `.()` in the method). `/fix-notices agreement`
4. **LOW** — Residual untranslated user-visible literals: forest plot title, subtitle and axes ([R/agreement.b.R:5900–5903](R/agreement.b.R#L5900)); the method cell "Inter-Rater Reliability (All Raters × Time Points)" ([:8295](R/agreement.b.R#L8295), [:8441](R/agreement.b.R#L8441)); and the computed-variables info "Consensus rating (", "Case Agreement (Simple mode - threshold: " ([:12098](R/agreement.b.R#L12098), [:12112](R/agreement.b.R#L12112), [:12122](R/agreement.b.R#L12122)). `/prepare-translation agreement`
5. **LOW** — `.run()` spans [R/agreement.b.R:15903](R/agreement.b.R#L15903)–17598 (F9). Not a blocker; extract feature by feature with parity tests only. `/review-function agreement`
6. **LOW** — Reference tables drawn as raw HTML `<table>` inside the educational Html panels. This is module-house style and appears in about 40 guide panels, e.g. the Gwet AC1/AC2 table ([R/agreement.b.R:1162](R/agreement.b.R#L1162)) and the continuous-data recommendation table ([:16195](R/agreement.b.R#L16195)). All are static guide content, so the impact is copy/export, theming and translation layout only (guide §26). Not computed results.

#### Recommended remediation

- `/fix-function agreement` — findings 1–2 (subgroup CI note + `exct` clearWith), both from today's commit
- `/fix-notices agreement` — finding 3
- `/prepare-translation agreement` — finding 4 and the untranslated subgroup note msgid
- `/review-function agreement` — independent statistical validation of the non-kappa families before a clinical-readiness claim

---

### cotest

**Status:** ✅ READY (one MEDIUM: stale notices panel on re-run; no HIGH/CRITICAL)
**Files:** [`R/cotest.b.R`](R/cotest.b.R) · [`jamovi/cotest.a.yaml`](jamovi/cotest.a.yaml) · [`jamovi/cotest.u.yaml`](jamovi/cotest.u.yaml) · [`jamovi/cotest.r.yaml`](jamovi/cotest.r.yaml) · [`jamovi/js/cotest.events.js`](jamovi/js/cotest.events.js)
**Metrics:** .b.R LOC 1450 · options 14 · outputs 8 (5 Html, 2 Table, 1 Image) · UI controls 14 · JS LOC 159 · `.run()` ≈295 lines ([R/cotest.b.R:106](R/cotest.b.R#L106)–400)

#### Changes since 2026-10-20 audit

The 2026-10-20 report found nothing on cotest ("No blocking issue confirmed"). It cited
[R/cotest.b.R:24](R/cotest.b.R#L24) (`.sourcifyOption` with `encodeString`) only as a *good*
reference for the module-wide LOW-G finding. I re-checked it in the current code and it is still correct.
- Prior findings: **0/0**. Nothing to mark FIXED or STILL PRESENT.
- **NEW this round:** finding 1 (stale notices). The earlier audit missed it. It is not a regression.

#### Security

*No findings in profile standard.* Checked:
- **Free-text sources (`test1_name`, `test2_name`).** Names are escaped for every Html sink (`.escapeHtml`, [R/cotest.b.R:136](R/cotest.b.R#L136)). Table cells and footnotes get the tag-opener sanitiser `.cellText` ([R/cotest.b.R:1300](R/cotest.b.R#L1300)). Every notice message is escaped again inside `.displayNotices` ([R/cotest.b.R:1355](R/cotest.b.R#L1355)).
- **Syntax export (G).** `encodeString(value, quote = '"')` handles quotes and backslashes, and default omission is kept through `super$.sourcifyOption`.
- **Not present:** no eval/parse, formula, file, `system`, `set.seed`, `library()` or debug flags.
- **Regex use.** The names are only ever the subject of a `gsub`, never the pattern.

#### jmvcore migration

*No migration opportunities found.* There is no formula, NA-omit, `as.numeric(factor)` or user-facing `stop()`. The only `jmvcore::reject()` ([R/cotest.b.R:549](R/cotest.b.R#L549), non-finite probability) cannot be reached with bounded inputs. It sits in no `tryCatch`, and the file has no `tryCatch` at all.

#### Integration

**Arguments declared:** 14 · **used in logic:** 13 · **dead:** 0
- `showGuidance` is cosmetic by design. It drives only the `visible:` of `instructions` and `dependenceExplanation`.
- `preset` overrides parameters. The override is disclosed to the user, and a value the caller passed that differs from both the default and the preset raises a warning ([R/cotest.b.R:209](R/cotest.b.R#L209)–251).

**Outputs declared:** 8 · **populated:** 8 · **unpopulated:** 0
- **Table rows** are scaffolded in `.init()` ([R/cotest.b.R:87](R/cotest.b.R#L87)–103) and filled with `setRow()`. `setRow()` clears footnotes before `addFootnote()` runs, so footnotes cannot go stale when `fnote` is toggled.
- **`plot1`:**
  - `requiresData: false` is correct: `.plot1` reads only `image$state`, and `nomogrammer()` is pure.
  - The state read is guarded ([R/cotest.b.R:408](R/cotest.b.R#L408)).
  - The state is a small list of 9 scalars plus a caption.
  - `clearWith` covers every input of the state. The test names are not plotted, so they do not need to be listed.
- **Table `clearWith`** lists every option that changes the computation.

| Output | Type | Setter | Populated? | Notes |
|---|---|---|:---:|---|
| `notices` | Html | `setContent` | ✅ | Blanks with `""`, which the client ignores (finding 1) |

#### Notices coverage

House style is a severity-styled Html panel (rgba tints, `color: inherit`). There are no `jmvcore::Notice` objects and no `insert()` calls.

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | n/a | — | — | Calculator: every input has a bounded default; out-of-range values are rejected by OptionNumber before `.run()` |
| Test below chance / Youden < 0.1 | WARNING | ✅ | ✅ | [R/cotest.b.R:472](R/cotest.b.R#L472) names the test as labelled |
| Extreme prevalence (<5%, >95%; >50% INFO) | WARNING | ✅ | ✅ | [R/cotest.b.R:487](R/cotest.b.R#L487) |
| Dependence above the Fréchet bound (truncated) | WARNING | ✅ | ✅ | Gives the raw value and the bound; realised phi is reported ([R/cotest.b.R:751](R/cotest.b.R#L751), 771) |
| Degenerate LR (0 / Inf / undefined) | WARNING + row footnote | ✅ | ✅ | [R/cotest.b.R:510](R/cotest.b.R#L510), 933, 942 |
| Worked example in use / caller values overridden | INFO / WARNING | ✅ | ✅ | [R/cotest.b.R:171](R/cotest.b.R#L171) |
| Nomogram not drawable | WARNING | ✅ | ✅ | [R/cotest.b.R:1020](R/cotest.b.R#L1020)–1041 |
| Methodology summary | Html | ✅ | ✅ | `dependenceInfo` is always written for whichever model was fitted; a table note says inputs are treated as exact (no CI) |

#### Code review

- **Overall quality:** 4/5. Heavily hardened by earlier validation rounds and carries 1,860 lines of oracle-backed tests in the umbrella (`tests/testthat/test-cotest*.R`).
- **Architecture:** OK. Helpers are well factored, but `.run()` is long (finding 2).
- **Mathematical/statistical correctness: CORRECT.** What I checked, and against what:
  - **Dependence model.** P(T1+,T2+|D) = Se₁Se₂ + ρ·√(Se₁(1−Se₁)Se₂(1−Se₂)) is the phi-correlation form of the Gardner et al. (2000) / Vacek covariance model, and the covariance-to-phi conversion in the help text matches it.
  - **Fréchet bounds.** [max(0, Se₁+Se₂−1), min(Se₁, Se₂)] is correct, and the remaining three cells are non-negative inside it.
  - **Realised phi formula.** Correct.
  - **Parallel-rule LR.** (1−P(−,−|D)) / (1−P(−,−|D̄)) is correct, and the Fagan plot uses this LR and the both-negative LR.
  - **Independent Bayes oracle (python).** I recomputed the defaults by direct Bayes on the four joint cells: both+ 0.8910, either+ 0.4246, both− 0.00754. Under independence: 0.9302 / 0.4213. These match the code's odds×LR path and the figures quoted in the code comments.
  - **Fabricated statistics.** None. No CI is shown, and the absence of one is disclosed on the table, in the sentence and in the help.
- **Clinical readiness:** READY. Worked examples are marked as demonstration-only in the table notes, the copy-ready sentence and the plot caption. Independence is off by default.
- **i18n coverage:** COMPLETE. I checked all 153 `.()` literals against `jamovi/i18n/tr.po`: every one is present with a non-empty `msgstr`. That includes the long multi-line panels, the `—` msgids and the nomogram labels translated in the renderer. No separator-inside-`.()` hits, no symbol entities, no malformed `format:` tokens.

**Top issues:**

1. **MEDIUM** — Stale notices panel after a re-run.
   - **Where:** [R/cotest.b.R:1324](R/cotest.b.R#L1324). `.displayNotices()` blanks the panel with `self$results$notices$setContent("")`.
   - **Why it fails:** The jamovi client re-renders an Html item only when `content != ""` (`resultsview` Html `render()`, verified 2026-10-17). The previous run's notices therefore stay on screen.
   - **Reproduction:** select `hpv_pap`, then *Custom values*. events.js resets the inputs to the defaults, the defaults raise no notice, and the panel keeps showing *"Worked example in use: HPV… These are round illustrative numbers…"* above results that are now custom. The same happens to any truncation or extreme-prevalence warning after the user corrects the input.
   - **Effect:** a misleading disclosure. The numbers are correct.
   - **Fix:** `setContent("<div></div>")`, or a short "No issues" line. Check `test-cotest-release-review.R:246`-style assertions on `notices$content` afterwards.
   - **Tool:** `/fix-function cotest`.
2. **LOW** — `.run()` is about 295 lines ([R/cotest.b.R:106](R/cotest.b.R#L106)–400). The preset-override and disclosure block ([R/cotest.b.R:149](R/cotest.b.R#L149)–268) could be extracted into a helper. `/review-function cotest`
3. ~~**LOW (PLAUSIBLE)** — Footnotes may be cut short when a test name contains `" ["`.~~ **Orchestrator verification (executed probe, 2026-10-21):** **refuted** — with `test1_name = "HPV [hr]"`, `fnote = TRUE` the footnotes read "…correctly identified by HPV [hr]" in full. No action.
4. **LOW** — Translated preset test names are never shown in the GUI ([R/cotest.b.R:1226](R/cotest.b.R#L1226), [jamovi/js/cotest.events.js:41](jamovi/js/cotest.events.js#L41)). events.js writes the English names into the boxes, and a typed name wins over the preset's own. This is acknowledged by an in-code TODO. `/prepare-translation cotest`

#### Recommended remediation

- `/fix-function cotest`: replace the `""` blank at [R/cotest.b.R:1324](R/cotest.b.R#L1324) with non-empty blank markup (the `" ["` footnote concern was refuted by probe).
- `/review-function cotest`: optionally extract the preset-disclosure block out of `.run()`.
- `/prepare-translation cotest`: decide which preset test names the GUI shows (in-code TODO).

---

### decision

**Status:** ✅ READY (LOW-only findings; numerical validation still pending — see Code review)
**Files:** [`R/decision.b.R`](R/decision.b.R) · [`jamovi/decision.a.yaml`](jamovi/decision.a.yaml) · [`jamovi/decision.u.yaml`](jamovi/decision.u.yaml) · [`jamovi/decision.r.yaml`](jamovi/decision.r.yaml) · helpers [`R/utils-diagnostic-inputs.R`](R/utils-diagnostic-inputs.R), [`R/utils-syntax-exports.R`](R/utils-syntax-exports.R), [`R/utils-diagnostic-comparator.R`](R/utils-diagnostic-comparator.R), [`R/utils-diagnostic-validation.R`](R/utils-diagnostic-validation.R), [`R/utils-nomogrammer.R`](R/utils-nomogrammer.R)
**Metrics:** .b.R LOC 3138 · options 29 (incl. `data`) · outputs 28 · UI controls 28 · JS LOC 0 · `.run()` 1072 source lines ([R/decision.b.R:1760](R/decision.b.R#L1760)–2831). The sibling files are byte-identical to the umbrella. `menuGroup: meddecide` (production).

#### Changes since 2026-10-20 audit

| Prior | Prior claim | Now | Evidence (current line) |
|---|---|---|---|
| F2 (MEDIUM) | Fatal configuration errors (e.g. positive level absent) showed an ERROR notice and completed normally | **FIXED** | Each fatal validation return now calls `.diagRejectInputErrors(private$.noticeList)` → `jmvcore::reject()` after blanking outputs: [R/decision.b.R:1822-1826](R/decision.b.R#L1822), [R/decision.b.R:1833-1837](R/decision.b.R#L1833); helper [R/utils-diagnostic-inputs.R:3](R/utils-diagnostic-inputs.R#L3). No catch-all `tryCatch` encloses those calls. Regression test: `tests/testthat/test-decision-release-inputs.R:20` (`status == "error"`). |
| F3 (LOW-G) | `asSource()` emitted `gold = gold with space` (unparseable) and copied unescaped label strings | **FIXED (static; parse probe below)** | `.sourcifyOption` override at [R/decision.b.R:24](R/decision.b.R#L24) routes every character option through `.sourcifyDiagnosticOption()` ([R/utils-syntax-exports.R:3](R/utils-syntax-exports.R#L3)), which `deparse()`s the value, so spaces, quotes and backslashes are quoted and escaped. |
| F9 (advisory) | `.run()` 1068 lines | **STILL PRESENT** | 1072 lines, [R/decision.b.R:1760](R/decision.b.R#L1760)–2831. |

#### Security

*No findings in profile standard.* I checked categories A–I:
- No evaluator, formula, `system`, deserialisation or `set.seed` is present.
- Free-text `String` options go only to table cells, through `.diagCellText`/`.dvProvenance`, which break the `<` that would open a tag; jamovi's cell renderer also sanitises.
- User strings in HTML panels go through `.safeHtmlOutput` (notices, summary, report) or `jmvcore::htmlEscape` (comparator report).
- Syntax export: see F3 above (fixed).

#### jmvcore migration

*No migration opportunities found.* The code already uses `jmvcore::naOmit` ([R/decision.b.R:736](R/decision.b.R#L736)), `jmvcore::reject` (through the helper) and `.fmt`→`jmvcore::format`, and builds no formulas.

#### Integration

**Arguments declared:** 29 · **used in logic:** 29 · **dead:** 0. Several fields are read through whole-options helpers: `referenceDescription` and `targetDefinition` by `.diagReferenceDefinition`, and the provenance fields by `.dvProvenance`.

| Argument | Type | Default | Used? | In logic? | Notes |
|---|---|---|:---:|:---:|---|
| `pprob` | Number | 0.3 (min 1e-9, max 0.999999999) | ✅ | ✅ | The UI label says "(0.001-0.999)" ([jamovi/decision.u.yaml:80](jamovi/decision.u.yaml#L80)) and a backend comment says the same ([R/decision.b.R:587](R/decision.b.R#L587)). Neither matches the declared bounds ([jamovi/decision.a.yaml:167](jamovi/decision.a.yaml#L167)). |
| `pp` | Bool | false | ✅ | ✅ | Disabled in comparator modes but keeps its value, so the `pp && ci` WARNING still fires there (Top issue 2). |

**Outputs declared:** 28 · **populated:** 28 · **unpopulated:** 0. The comparator tables and `referenceDefinition` are filled by the `utils-diagnostic-comparator.R` helpers.
- No declared-but-unpopulated item and no computed-but-invisible item.
- `requiresData`: `plot1` reads only `image$state` (a 6-scalar list), and `nomogrammer()` is file-level and never reads `self$data`. The flag is absent, which is correct.
- `image$state` is guarded (`.validatePlotState(NULL)` → `return(FALSE)`, [R/decision.b.R:2863](R/decision.b.R#L2863)).
- No heavy state, no `insert()`, no `setVisible()`, no bare `warning()`.
- Fixed-structure tables (epiR rows, rawContingency, cTable, confusionMatrixSummary) are scaffolded in `.init()`.
- `clearWith`: every item that can show stale content is either rewritten on every run in which it is visible, or blanked by `.clearDiseaseOutputs()` on the pending, reject and comparator paths. Notes written in `.run()` are not restored from protobuf, so the FP/FN "truncated" note cannot go stale despite `maxCasesShow` being absent from `clearWith`. No gap found.
- Citations: not re-audited at module level here.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Nothing selected | quiet welcome | ✅ | — | `welcome` visible expression; no red ERROR |
| Variable selected, positive level unset | INFO | ✅ | ✅ | Lists the observed levels with counts ([R/decision.b.R:1800-1819](R/decision.b.R#L1800)) |
| Configured invalid (absent/identical level, same variable, no 2x2, n<4 after exclusions) | `reject()` | ✅ | ✅ | **FIXED since 2026-10-20** |
| Low n / few cases per arm | STRONG_WARNING / WARNING | ✅ | ✅ | n<20, <50, <100; arm <10; min cell <5 ([R/decision.b.R:1365](R/decision.b.R#L1365)) |
| Zero cell / continuity correction | STRONG_WARNING + INFO + table notes | ✅ | ✅ | |
| Prevalence <5% or >95% | STRONG_WARNING | ✅ | ✅ | |
| Worse than chance / no evidence of discrimination | ERROR / STRONG_WARNING | ✅ | ✅ | Graded by the Agresti-Caffo CI, not the point estimate |
| Failed optional step (epiR CIs) | WARNING | ✅ | ✅ | Names the reason |
| Failed optional step (misclassified tables) | ERROR (non-fatal) | ⚠️ | ✅ | Should be WARNING (Top issue 3) |
| Methodology summary | always-on table notes + opt-in About | ✅ | ✅ | |

#### Code review

- **Overall quality:** 4/5 stars
- **Architecture:** `.run()` is 1072 lines. The helpers are well factored, and the comments are unusually rich and record the reasons behind each choice.
- **Mathematical/statistical correctness:** CORRECT, by static derivation against standard formulas. Checked:
  - 2x2 orientation (`table(test, gold)`, Positive first) → TP/FP/FN/TN [R/decision.b.R:2098](R/decision.b.R#L2098).
  - Sens, Spec, PPV, NPV, and Bayes PPV/NPV at a prior ([R/decision.b.R:2219](R/decision.b.R#L2219)).
  - LR± with a conditional Haldane–Anscombe correction applied only to the ratio whose formula contains the zero.
  - Simel log-LR+ CI ([R/decision.b.R:387](R/decision.b.R#L387)).
  - Agresti–Caffo Youden CI, (x+1)/(n+2) per arm ([R/decision.b.R:359](R/decision.b.R#L359)).
  - NNDx by inversion of the positive part of the Youden interval ([R/decision.b.R:377](R/decision.b.R#L377)).
  - Fagan back-solve sp=(LR+−1)/(LR+−LR−), se=LR+(1−sp) ([R/decision.b.R:2794](R/decision.b.R#L2794)).
  - Comparator PPA/NPA/OPA/PSA/NSA ([R/utils-diagnostic-comparator.R:81](R/utils-diagnostic-comparator.R#L81)).
  - epiR interval values were not independently re-computed (no R run).
- **Clinical readiness:** NEEDS_VALIDATION. No blocking defect remains; an independent numerical oracle run (`/validate-function decision`) has not been done in this audit.
- **i18n coverage:** PARTIAL. Almost every string is wrapped; the gaps are below.

**Top issues:**

1. **LOW** — `.run()` is 1072 source lines ([R/decision.b.R:1760](R/decision.b.R#L1760)). Extract the raw-table block (1885–2064) and the CI block (2492–2770) as helpers, with parity tests. → `/review-function decision`
2. **LOW** — In comparator modes (`referenceType` consensus/method), `pp` is UI-disabled but keeps its value. `.validateCategoricalInputs()` runs before the comparator branch, so `pp && ci` still raises the WARNING "Confidence Intervals Interpretation". That WARNING talks about prior-adjusted PPV/NPV in a main table that this mode does not show ([R/decision.b.R:591](R/decision.b.R#L591), branch at [R/decision.b.R:1843](R/decision.b.R#L1843)). PLAUSIBLE: probe 2. → `/fix-notices decision`
3. **LOW** — A failure of the optional misclassified-cases step is raised as an **ERROR** notice while the analysis completes ([R/decision.b.R:2474](R/decision.b.R#L2474)); it should be a WARNING naming the step. The narrative `tryCatch` fallbacks ([R/decision.b.R:1663-1702](R/decision.b.R#L1663)) substitute a "Basic results" panel with no notice that the full text failed. Both are unlikely to be reached. → `/fix-notices decision`
4. **LOW** — Saved classification column values in disease mode are untranslated English literals ("True Positive" … [R/decision.b.R:2936-2948](R/decision.b.R#L2936)). The comparator path translates its labels (`.diagText` class_*), so the two modes are inconsistent. → `/prepare-translation decision`
5. **LOW** — `referenceDefinition` is `visible: true` and is filled at the very top of `.run()` ([R/decision.b.R:1772](R/decision.b.R#L1772)). Two effects:
   - On an untouched analysis it shows "Reference:  positive  negative  ; test: …" with blanks.
   - In disease mode an inferred (dichotomous) negative level is left blank in "Positive and negative rules", although the cTable note names it.
   → `/fix-function decision`
6. **LOW** — UI conventions:
   - The `Reference Interpretation` CollapseBox (expanded) sits above the VariableSupplier ([jamovi/decision.u.yaml:8](jamovi/decision.u.yaml#L8)).
   - `Test Under Evaluation` is a Title-Case control title ([jamovi/decision.a.yaml:87](jamovi/decision.a.yaml#L87)).
   - The Output title "Save classifications to data" starts with an action verb ([jamovi/decision.a.yaml:298](jamovi/decision.a.yaml#L298)).
   - The `pprob` label range "(0.001-0.999)" disagrees with the a.yaml bounds (1e-9 to 0.999999999), and so does the comment at [R/decision.b.R:587](R/decision.b.R#L587).
   → `/fix-function decision`

**Orchestrator addition (MEDIUM, confirmed from client source 2026-10-21):** when a run ends with no notices, [R/decision.b.R:508](R/decision.b.R#L508) blanks the notices panel with `setContent("")`. The installed jamovi 28.13 client renders an Html item only when `content !== ""` (`resultsview-*.js`), so the previous run's warnings stay on screen beside results that no longer support them. Send `"<div></div>"` instead. Same root cause as `cotest` and `decisioncombine`; see Cross-cutting issues. → `/fix-function decision`

#### Recommended remediation

- `/fix-notices decision`: comparator-mode `pp` warning; misclassified-step ERROR → WARNING; silent narrative fallbacks.
- `/prepare-translation decision`: disease-mode saved classification labels.
- `/fix-function decision`: `referenceDefinition` empty-state and inferred-negative text; UI label and `pprob` range consistency.
- `/review-function decision`: `.run()` extraction (maintenance only).
- `/validate-function decision`: independent numerical oracle (epiR intervals, Youden/NNDx, Bayes PPV/NPV, Fagan back-solve) before a clinical-readiness claim.

---

### decisioncalculator

**Status:** ✅ READY (LOW-only findings; statistical validation still static)
**Files:** [`R/decisioncalculator.b.R`](R/decisioncalculator.b.R) · [`jamovi/decisioncalculator.a.yaml`](jamovi/decisioncalculator.a.yaml) · [`jamovi/decisioncalculator.u.yaml`](jamovi/decisioncalculator.u.yaml) · [`jamovi/decisioncalculator.r.yaml`](jamovi/decisioncalculator.r.yaml) · helpers [`R/utils-diagnostic-inputs.R`](R/utils-diagnostic-inputs.R) (`.diagRejectInputErrors`), [`R/utils-diagnostic-validation.R`](R/utils-diagnostic-validation.R) (`.dvNumbers`, `.dvWorkload`), [`R/utils-nomogrammer.R`](R/utils-nomogrammer.R), [`R/utils.R`](R/utils.R) (`.fmt`, `.deleteTableRows`)
**Metrics:** .b.R 1840 lines (1324 non-blank/non-comment) · options 28 (27 read in .b.R; `showWelcome` drives `visible:` only) · outputs 16 (1 Image) · no JS · `.run()` [R/decisioncalculator.b.R:264](R/decisioncalculator.b.R#L264)–1520 (1257 lines)
**Routing:** `menuGroup: meddecide` (production). Yesterday's report had it staged in `meddecideT`; it now ships.

#### Changes since 2026-10-20 audit

| Prior | Was | Now | Evidence (current code) |
|---|---|---|---|
| F1 (HIGH) stale narratives after invalid rerun | `summary`/`faganSummary` survived TP=-1 | **FIXED** | [R/decisioncalculator.b.R:269](R/decisioncalculator.b.R#L269)–279 clears `summary`, `faganSummary`, `assumptions`, `about`, `glossary` before validation and resets visibility on exit. Regression: `tests/testthat/test-decisioncalculator-release-inputs.R` (valid → invalid → valid; simulates restoration with `setContent`, not a protobuf replay). |
| F2 (MEDIUM) fatal input completes normally | ERROR notice + `return()` | **FIXED** | Each fatal check calls `.diagRejectInputErrors()` → `jmvcore::reject()` ([R/decisioncalculator.b.R:324](R/decisioncalculator.b.R#L324), 330, 336, 342, 348; helper [R/utils-diagnostic-inputs.R:3](R/utils-diagnostic-inputs.R#L3)). Neither `tryCatch` in `.run()` (L485 parser, L912 epiR) can reach it. Test asserts `status == "error"`, `errored`. |
| F9 (advisory) long `.run()` | 1234 lines | **STILL PRESENT** | 264–1520, now 1257 lines. |

#### Security

*No HIGH/MEDIUM findings in profile standard.*

- Free-text options (`cutoff1`, `cutoff2`, `analysisUnit`) reach table cells only through `.richText()` ([L34](R/decisioncalculator.b.R#L34)), which breaks `<tag` openings; recommendation text that quotes a scenario name is also passed through it ([L1330](R/decisioncalculator.b.R#L1330)). Notices are plain text in a Preformatted item. No user string reaches an Html `setContent()`.
- `prevalenceScenarios` is parsed numerically only (`.dvNumbers`, `as.numeric`).
- Category G: `.sourcifyOption` override ([L14](R/decisioncalculator.b.R#L14)–20) escapes the four String options with `encodeString(quote = '"')`. There are no Variable options, so the column-name-with-spaces export defect cannot occur here.
- No A/B/C/E/F/H sinks.

#### jmvcore migration

*No migration opportunities found.* Fatal validation already uses `jmvcore::reject()` through a shared helper. There are no formulas or data-frame `na.omit`, and `base::format()` is called deliberately where jmvcore masks `format`.

#### Integration

**Arguments declared:** 28 · **used in logic:** 27 (+ `showWelcome` declarative) · **dead:** 0
**Outputs declared:** 16 · **populated:** 16 · **unpopulated:** 0

- `requiresData: false` on `plot1` is correct. `.plot1` ([L1521](R/decisioncalculator.b.R#L1521)) reads only `image$state` (a 6-scalar list) and calls `nomogrammer()`. The state is guarded with `is.null` and has a `drawable` flag.
- clearWith: every option a result's content depends on is listed (counts, `pp`/`pprob`, `fnote`, `ci`, cut-off options, workload options). The `notices` item misses the workload options, but `.run()` rewrites it in full every run (`on.exit` + [L1519](R/decisioncalculator.b.R#L1519)), so nothing goes stale.
- Citations: all 15 `refs:` keys resolve in `jamovi/00refs.yaml`.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Non-finite / negative / all-zero counts, empty reference group | ERROR → `reject()` | ✅ | ✅ | L322–349 |
| Test never positive / never negative | WARNING | ✅ | ✅ | L352–359, says which ratios are not estimable |
| Sparse reference groups (<10) | STRONG_WARNING | ✅ | ✅ | L548, quotes n; says it is not a clinical threshold |
| Extreme prevalence (<5% / >95%) | STRONG_WARNING (sample) / INFO (supplied) | ✅ | ✅ | L528–546 |
| Zero cell / continuity correction | WARNING | ✅ | ✅ | L471 |
| Inverted coding (J<0) | STRONG_WARNING if the Agresti-Caffo CI lies wholly below 0, else INFO | ✅ | ✅ | L649–671 |
| Fractional counts → no CIs | WARNING | ✅ | — | L441 |
| Failed optional step (epiR, scenario parse, cut-off frequencies) | labelled **ERROR** | ✅ | ✅ | Visible, but labelled ERROR while the analysis completes (finding 1) |
| Methodology / independence | table notes | ✅ | — | L1013–1014, L1048–1049 |

#### Code review

- **Overall quality:** 4/5
- **Architecture:** OK, apart from the long `.run()`.
- **Mathematical/statistical correctness:** CORRECT (formula-level static check; not executed)
  - Formulas checked: Se, Sp, PPV and NPV (sample, and Bayes at the supplied prevalence), P(D+|T−) = 1 − NPV, LR±, DOR, Youden, balanced accuracy, F1 and MCC, against standard 2×2 definitions (Altman & Bland 1994; Deeks & Altman 2004).
  - Simel log-LR variance (`lr_v`, L991): checked term by term for LR+ and LR−.
  - DOR interval: Woolf variance on the Haldane-corrected counts (L1005).
  - Youden interval: Agresti-Caffo for a difference of independent proportions, (x+1)/(n+2) (Agresti & Caffo 2000), L118.
  - NNDx interval: the inverse of the positive part of the Youden interval (L148).
  - Inversion test: TP·n0 < FP·n1 ⇔ J < 0.
  - Nomogram back-solve: sp = (LR+−1)/(LR+−LR−), se = LR+(1−sp) (L1376).
  - Matrix passed to `epi.tests`: `[TP FP; FN TN]` with test in rows (L364), with exact intervals.
  - Documented, accepted ceiling: +0.5 LR limits can under-cover at extreme accuracy (L969–977, maintainer decision 2026-10-21).
- **Clinical readiness:** NEEDS_VALIDATION. The validation and release-review tests exist in the umbrella (`test-decisioncalculator-validation.R`, `-release-review.R`) but were not run in this audit.
- **i18n coverage:** COMPLETE. Sampled strings are present in `catalog.pot` and `tr.po`, with Turkish translations. The only exception is one link label (finding 6).

**Top issues:**

1. **LOW** — Failures of optional steps are labelled `ERROR` while the analysis completes normally. This happens for the epiR interval failure or a missing epiR ([L901](R/decisioncalculator.b.R#L901), [L918](R/decisioncalculator.b.R#L918), [L1037](R/decisioncalculator.b.R#L1037)), an unparseable target-prevalence list ([L487](R/decisioncalculator.b.R#L487)) and invalid cut-off scenario frequencies ([L1064](R/decisioncalculator.b.R#L1064), [L1085](R/decisioncalculator.b.R#L1085)). The cut-off case also raises a second ERROR for the same cause ([L1177](R/decisioncalculator.b.R#L1177)). The text correctly says that the other results are unaffected, but an "ERROR:" banner beside complete results misstates the severity. Use WARNING, and raise one notice per cause. → `/fix-notices decisioncalculator`
2. **LOW** — The `screeningWorkload` row set is built with `addRow()` in `.run()` ([L499](R/decisioncalculator.b.R#L499)–508) although it depends only on options (`prevalenceScenarios`, `pp`, `pprob`). A TODO at L496 acknowledges this. → `/fix-function decisioncalculator`
3. **LOW** — The Fagan trajectory colours are hard-coded red/blue ([L1558](R/decisioncalculator.b.R#L1558)) and there is no "jamovi (follow global)" palette choice. A TODO at L1555 acknowledges this. → `/fix-function decisioncalculator`
4. **LOW** — `.run()` spans 1257 lines ([L264](R/decisioncalculator.b.R#L264)–1520); this is prior F9. Extract the CI block, the cut-off block and the Fagan block into helpers, with parity tests. → `/review-function decisioncalculator`
5. **LOW** — Individual control labels use Title Case: `True Positive (TP)` and the other three count labels ([jamovi/decisioncalculator.u.yaml:34](jamovi/decisioncalculator.u.yaml#L34), 38, 52, 56; [jamovi/decisioncalculator.a.yaml:41](jamovi/decisioncalculator.a.yaml#L41)–71), and `Prior Probability (prevalence)` ([jamovi/decisioncalculator.a.yaml:96](jamovi/decisioncalculator.a.yaml#L96)). → `/fix-function decisioncalculator`
6. **LOW** — The link label `epiR package documentation` in the About panel is not wrapped in `.()` ([L1674](R/decisioncalculator.b.R#L1674)). → `/prepare-translation decisioncalculator`

**Orchestrator correction (2026-10-21):** an earlier version of this report added a stale-notices MEDIUM here. Withdrawn: decisioncalculator's notices item is `type: Preformatted`, whose client renderer sets the text unconditionally, so `setContent("")` clears it.

#### Recommended remediation

- `/fix-notices decisioncalculator`: downgrade the optional-step ERRORs to WARNING and drop the duplicate cut-off notice.
- `/fix-function decisioncalculator`: move the workload rows to `.init()`, add the jamovi palette choice, and change labels to sentence case.
- `/prepare-translation decisioncalculator`: wrap the one link label.
- `/review-function decisioncalculator`: optional `.run()` extraction.
- Before calling it clinically ready, run the umbrella `test-decisioncalculator-validation.R` and a protobuf replay (valid → TP=-1 → valid) on the installed module.

---

### decisioncombine

**Status:** ✅ READY (no HIGH or CRITICAL finding; two MEDIUM display defects remain, see Code review)
**Files:** [`R/decisioncombine.b.R`](R/decisioncombine.b.R) · [`jamovi/decisioncombine.a.yaml`](jamovi/decisioncombine.a.yaml) · [`jamovi/decisioncombine.u.yaml`](jamovi/decisioncombine.u.yaml) · [`jamovi/decisioncombine.r.yaml`](jamovi/decisioncombine.r.yaml) · helpers [`R/utils-diagnostic-inputs.R`](R/utils-diagnostic-inputs.R), [`R/utils-paired-proportions.R`](R/utils-paired-proportions.R), [`R/utils.R`](R/utils.R) (`.fmt`, `.deleteTableRows`, `%||%`)
**Metrics:** .b.R LOC 3856 · options 25 · outputs 20 top-level (4 Images, 1 Output, 3 Groups) · UI controls 23 · JS 0 · `.run()` 97 lines ([R/decisioncombine.b.R:505](R/decisioncombine.b.R#L505)–602)
**Routing:** `menuGroup: meddecide` (production; it was staged in `meddecideT` at the 2026-10-20 audit), so it ships now.

#### Changes since 2026-10-20 audit

| Prior finding | Now | Evidence (current code) |
|---|---|---|
| F2: a configured reference positive level that is absent adds an ERROR notice and completes normally | **FIXED** | "Missing Level" returns FALSE at [R/decisioncombine.b.R:804](R/decisioncombine.b.R#L804), and `.run()` then calls `.diagRejectInputErrors()` at [R/decisioncombine.b.R:544](R/decisioncombine.b.R#L544). That helper calls `jmvcore::reject()` on any ERROR ([R/utils-diagnostic-inputs.R:9](R/utils-diagnostic-inputs.R#L9)), outside any `tryCatch`. The same applies to "No Data", "Insufficient Data", "Variables Must Be Distinct", "No Complete Cases" and "Test 2 Required Before Test 3". |
| F2 (input triage): ERROR when a test is selected before the reference | **FIXED** | The empty state returns quietly ([R/decisioncombine.b.R:623](R/decisioncombine.b.R#L623)). A missing gold standard or Test 1 is now INFO ([R/decisioncombine.b.R:656](R/decisioncombine.b.R#L656), 665), and an unset positive level is a pending INFO ([R/decisioncombine.b.R:634](R/decisioncombine.b.R#L634)–654). None of these reaches `reject()`. |
| F7: "Test 1 Positive Level" uses Title Case | **FIXED** | It is now "Test 1 positive level" ([jamovi/decisioncombine.a.yaml:91](jamovi/decisioncombine.a.yaml#L91)), and every control label is sentence case. The List *item* titles are still Title Case (new LOW finding 4). |

#### Security

*No findings in profile standard.*

- D: every notice title and content, the welcome step and the About text go through `jmvcore::htmlEscape` ([R/decisioncombine.b.R:206](R/decisioncombine.b.R#L206)–210, 467, 86). Table cells carry only fixed rule labels.
- G: `.sourcifyOption` writes variable and level options as `encodeString()` literals ([R/decisioncombine.b.R:45](R/decisioncombine.b.R#L45)), so names with spaces, quotes or backslashes produce parseable code.
- A, B, C, E and F: no evaluator, formula, file or deserialisation sink. The bootstrap seed is scoped with `withr::local_seed` ([R/decisioncombine.b.R:2490](R/decisioncombine.b.R#L2490)), so no seed leaks.

#### jmvcore migration

*No migration opportunities found.* The code already uses `jmvcore::naOmit` ([R/decisioncombine.b.R:773](R/decisioncombine.b.R#L773), 1179), `jmvcore::reject` (via the helper) and `jmvcore::format` (via `.fmt`). It builds no formulas.

#### Integration

**Arguments declared:** 25  ·  **used in logic:** 25  ·  **dead:** 0. `showCITables` is consumed only by `visible: (showCITables)`; it has no backend read, which is correct because the forest plot reads the CI tables whatever their visibility. `addedPattern` is gated with `isNotFilled()` on the results item ([R/decisioncombine.b.R:595](R/decisioncombine.b.R#L595)), and `setRowNums(rownames(...))` comes before `setValues` ([R/decisioncombine.b.R:3022](R/decisioncombine.b.R#L3022)), so the column stays correct under a filter.

**Outputs declared:** 20  ·  **populated:** 20  ·  **unpopulated:** 0

| Output | Type | Setter | Populated? | Notes |
|---|---|---|:---:|---|
| notices | Html | `setContent()` in an `on.exit` hook | ✅ | Writes `""` when there are no notices ([R/decisioncombine.b.R:140](R/decisioncombine.b.R#L140)). See finding 2. |
| combinationTable, combinationTableCI, combinationTableCIRatios, goldFreqTable, crossTabTable | Table | `addRow()` in `.run()` | ✅ | The row set is fixed by the number of tests k alone. See finding 3. |
| barPlot / heatmapPlot / forestPlot / decisionTreePlot | Image | `setState()` + renderer | ✅ | Every renderer reads only `image$state`, guarded by `is.list(state) && isTRUE(state$valid)`, and none sets `requiresData`, which is correct. The state is the small results frame, never a model or the dataset. The forest plot is sized in `.init()`. |

clearWith: the image lists contain both filters, `recommendationTable` adds `optimismCorrection`/`nBoot`/`seed`, and the Html items are rewritten on every run. No gap found (§2b). Citations: all 21 keys cited in `.r.yaml`, or set dynamically through `setRefs`, are defined in `jamovi/00refs.yaml`.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Nothing selected | quiet + Getting Started | ✅ | n/a | [R/decisioncombine.b.R:623](R/decisioncombine.b.R#L623) |
| Partial selection / positive level unset | INFO | ✅ | ✅ | Lists the observed levels with counts. |
| Configured invalid (absent level, duplicate variables, n < 4, no complete cases, Test 3 without Test 2) | ERROR + `reject()` | ✅ | ✅ | |
| Low n / small reference group | STRONG_WARNING / WARNING / INFO | ✅ | ✅ | Graded thresholds of 20, 50 and 100 in total and 10 per group. |
| Extreme prevalence (< 5% or > 95%), one-class reference | STRONG_WARNING | ✅ | ✅ | |
| More than 2 levels folded into negative; constant test | STRONG_WARNING | ✅ | ✅ | |
| Selective missingness (reflex testing, partial verification) | STRONG_WARNING / WARNING | ✅ | ✅ | Mantel-Haenszel screen. |
| Sparse cells / continuity correction | WARNING / INFO | ✅ | ✅ | |
| Discrimination (J < 0.40 ⇔ AUC < 0.70) and inverted level | graded by the Agresti-Caffo CI | ✅ | ✅ | |
| Plot blank (filter, statistic, one-class sample) | WARNING / INFO | ✅ | ✅ | |
| Methodology | table notes + optional About panel | ✅ | ✅ | |

#### Code review

- **Overall quality:** 4/5. Maintainability: MEDIUM, because a 3856-line class carries many long explanatory comments.
- **Architecture:** OK. The rule definitions (`.strategyDefinitions`, `.patternConditions`) are written once and shared by the table, the paired comparison and the bootstrap.
- **Mathematical/statistical correctness:** CORRECT for every formula checked against its standard source:
  - Wilson score interval
  - log-scale LR± standard errors (Simel 1991)
  - Woolf log-DOR with the Haldane-Anscombe 0.5 correction only on sampling zeros
  - Agresti-Caffo interval for J through `DescTools::BinomDiffCI(method = "ac")`, where J = sensitivity − false-positive rate
  - Newcombe method-10 paired interval ([R/utils-paired-proportions.R:19](R/utils-paired-proportions.R#L19))
  - McNemar mid-p, 2·(P(X ≤ s) − ½·P(X = s)) (Fagerland 2013)
  - the Wilson interval of the reclassified share for nested Parallel/Serial contrasts, where one discordant cell is structurally 0
  - the Bonferroni-type lower bound of Wilson-lower(sens) + Wilson-lower(spec) − 1
  - the stratified multinomial optimism bootstrap with a control variate, whose expectation equals Harrell's

  The selective-missingness screen was not independently verified (stats-unverified, informational).
- **Clinical readiness:** NEEDS_VALIDATION. Static review only; no oracle run in this audit.
- **i18n coverage:** COMPLETE on the wrapped surface. Sentences are whole, placeholders are underscore-free and none is a partial match for `str`, and none hits the leading/trailing-separator grep.

**Top issues:**

1. **MEDIUM** — Undefined numeric cells print "NaN", while the notes say they are "blank". Every undefined statistic is written as `NA_real_`: PPV/NPV/Accuracy on one-class rows, LR+/DOR on rows with no test positives, the always-blank `sensP`/`specP` of every Parallel/Serial row in the paired table ([R/decisioncombine.b.R:2317](R/decisioncombine.b.R#L2317)), the individual-test PPV/NPV ([R/decisioncombine.b.R:1527](R/decisioncombine.b.R#L1527)), and the stat rows reset in `.clearDynamicResults()` ([R/decisioncombine.b.R:356](R/decisioncombine.b.R#L356)), which show during a pending run. jmvcore's `Cell$asProtoBuf()` tests `inherits(v, "numeric")` before `is.na(v)`, so `NA_real_` is sent as a double, and the client prints `NaN`; only a logical `NA` or `NULL` becomes MISSING ("."). The notes promise otherwise: "haldane" says "its LR+ and odds ratio are blank" ([R/decisioncombine.b.R:1568](R/decisioncombine.b.R#L1568)), "nested" says "Their p is therefore left blank" ([R/decisioncombine.b.R:2295](R/decisioncombine.b.R#L2295)), and the one-class notice says "reported as blank". The code comment at [R/decisioncombine.b.R:1941](R/decisioncombine.b.R#L1941) ("jamovi renders NA as an empty cell") is wrong. The CI tables also mix logical `NA` (".") with `NA_real_` ("NaN") in the same column ([R/decisioncombine.b.R:2045](R/decisioncombine.b.R#L2045) vs 2051). Fix: write `""` with `setCell()` plus a footnote (decisioncalculator's `.footnoteNA()` pattern), and correct the note wording. → `/fix-function decisioncombine`
2. **MEDIUM** — Notices from the previous run stay on screen. When a run has no notices, `.renderNotices()` calls `setContent("")` ([R/decisioncombine.b.R:139](R/decisioncombine.b.R#L139)–141). The jamovi client re-renders an Html item only when its content is not `""` (client `resultsview` Html `render()`, verified 2026-10-17), so the earlier banners remain. Example: "Positive Levels May Be Inverted" or "No Rows Match the Pattern Filter" stays beside clean results after the user corrects the level or filter on a large, clean dataset. Fix: `setContent("<div></div>")`. Client-side, so it is not reproducible from R. → `/fix-function decisioncombine`
3. **LOW** — Fixed-structure tables are built in `.run()`. The rows of `combinationTable`, both CI tables, `goldFreqTable` (always Positive/Negative) and `crossTabTable` (2^k rows) depend only on the number of selected tests, yet they are created with `addRow()` after `.deleteTableRows()` in `.run()` ([R/decisioncombine.b.R:1583](R/decisioncombine.b.R#L1583), 1952, 2347, 2376). `pairedComparisonTable` already follows the `.init()` pattern ([R/decisioncombine.b.R:449](R/decisioncombine.b.R#L449)). Review guide §6. → `/fix-function decisioncombine`
4. **LOW** — Title Case List item titles: "Default Metric Set", "All Patterns", "All Tests Positive", "Balanced Accuracy" ([jamovi/decisioncombine.a.yaml:313](jamovi/decisioncombine.a.yaml#L313)–363). Individual control labels are otherwise sentence case. → `/fix-function decisioncombine`
5. **LOW (PLAUSIBLE)** — Test 3 kept while disabled. `test3` is `enable: (test2)` ([jamovi/decisioncombine.u.yaml:52](jamovi/decisioncombine.u.yaml#L52)), and a disabled control keeps its value. Remove Test 2 after choosing Test 3 and the backend rejects with "Select Test 2 … or remove Test 3" ([R/decisioncombine.b.R:688](R/decisioncombine.b.R#L688)), while the Test 3 box can no longer be edited. Recovery is possible by re-adding Test 2. Fix either the wording or the gating. GUI-only.

#### Recommended remediation

- `/fix-function decisioncombine`: NaN cells and the note wording (1), the empty-Html notices panel (2), and `.init()` row skeletons (3).
- `/fix-function decisioncombine`: List item titles in sentence case (4), and the Test 3 retained-while-disabled message (5).
- `/validate-function decisioncombine`: an oracle run (epiR/DescTools) of the pattern, strategy, paired and optimism outputs, to move clinical readiness beyond NEEDS_VALIDATION.

---

### decisioncompare

**Status:** ✅ READY (MEDIUM/LOW findings only; no HIGH/CRITICAL)
**Files:** [`R/decisioncompare.b.R`](R/decisioncompare.b.R) · [`jamovi/decisioncompare.a.yaml`](jamovi/decisioncompare.a.yaml) · [`jamovi/decisioncompare.u.yaml`](jamovi/decisioncompare.u.yaml) · [`jamovi/decisioncompare.r.yaml`](jamovi/decisioncompare.r.yaml) · helpers [`R/utils-diagnostic-comparator.R`](R/utils-diagnostic-comparator.R), [`R/utils-diagnostic-validation.R`](R/utils-diagnostic-validation.R), [`R/utils-paired-proportions.R`](R/utils-paired-proportions.R)
**Metrics:** .b.R LOC 4261 · options 42 (incl. `data`) · outputs 34 (6 Images) · UI controls 41 · JS none

#### Changes since 2026-10-20 audit

| Prior finding | Status | Current evidence |
|---|---|---|
| F7 (LOW UX): [jamovi/decisioncompare.a.yaml:137](jamovi/decisioncompare.a.yaml#L137) "Test 1 Positive Level" | **FIXED** | Now `Test 1 positive level` (same for all Level titles) |
| F7 (LOW UX): [jamovi/decisioncompare.a.yaml:306](jamovi/decisioncompare.a.yaml#L306) "Exclude other observed levels" | **FIXED**, with a regression | Now `Selected positive and negative levels only`, but the ERROR text that tells users to tick it still names the old label — see Code review #3 |

Prior: 1/1 finding fixed (F7, two sites). No other prior finding named this analysis.

#### Security

- **[D-LOW]** [`R/decisioncompare.b.R:1696`](R/decisioncompare.b.R#L1696), [`:1861`](R/decisioncompare.b.R#L1861), [`:1943`](R/decisioncompare.b.R#L1943): the disease or legacy path writes raw variable names into `comparisonTable`, `opaTable` and `stratifiedTable` `test` cells. Table cells are parsed as HTML. The comparator path wraps the same names in `.diagCellText()` ([utils-diagnostic-comparator.R:3](R/utils-diagnostic-comparator.R#L3)), so the two paths are inconsistent. A column called `<LOD assay` would render truncated. This is a display defect with no script execution. Fix: `/security-audit-function decisioncompare`.

All other categories are clean. Every Html sink escapes user strings: `.safeHtmlOutput()` covers notices and narrative panels, `jmvcore::htmlEscape` covers the comparator report, and kable escapes by default. There is no eval, formula, file or deserialisation sink. The `.sourcifyOption` override ([:76](R/decisioncompare.b.R#L76)) `encodeString()`-quotes variable names, Level values and the 7 free-text options, so category G is clean.

#### jmvcore migration

- **[error]** About 25 sites use `private$.addNotice("ERROR", …)` followed by `stop(.("Validation failed"))` (e.g. [`:1037`](R/decisioncompare.b.R#L1037), [`:984`](R/decisioncompare.b.R#L984)). The outer handler at [`:840`](R/decisioncompare.b.R#L840) renders the notices and re-throws, so the error state is correct. However, the analysis-level message is the generic "Validation failed". Use `jmvcore::reject("{}", msg = content)` so the specific text reaches jamovi's error presentation. LOW. Fix: `/jamovify-function decisioncompare --apply`.

#### Integration

**Arguments declared:** 42 · **used in logic:** 42 · **dead:** 0. The free-text and provenance options reach the output through `.diagReferenceDefinition()` and `.dvProvenance()`. `pp` is deliberately ignored in comparator modes ([:1052](R/decisioncompare.b.R#L1052)).

**Outputs declared:** 34 · **populated:** 34 · **unpopulated:** 0

- **clearWith:** there is no staleness path. Every `rows: 0` table is `.deleteTableRows()`-ed at the top of `.run()` ([:712](R/decisioncompare.b.R#L712)). Every Html panel is reset to `""` and every Image state to `NULL` before validation, the cTable and epirTable values are blanked, and `setRow` clears footnotes.
- **Renderers:** `.plot1`, `.plotRadar`, `.plotHeatmap` and `.diagComparatorPlot` read only `image$state`, and every one NULL-guards it. No Image declares `requiresData`, which is correct. The states are small plot frames, with one exception noted under Code review #6.
- **tryCatch:** the outer handler re-throws, passes `.checkpoint()` restarts through, and keeps `$code`. The inner handlers (epiR, Cochran's Q, McNemar, `.opt`) wrap only computations that cannot reach `reject()`.
- **Format tokens:** `pc` and `zto,pvalue` are valid. There are no `insert()`, `setVisible`, bare `warning()` or `set.seed` calls.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Nothing selected | (quiet) | ✅ | – | `return()` with no notice ([:753](R/decisioncompare.b.R#L753)) |
| Reference + only one test | INFO | ✅ | ✅ | "Second Test Required" |
| Variables chosen, levels not yet chosen | should be INFO | ❌ | – | Red ERROR plus error state instead; see Code review #2 |
| Missing data | WARNING / INFO | ✅ | ✅ | Per-test counts; STARD wording |
| Small n, sparse reference class | STRONG_WARNING | ✅ | ✅ | n<30 or n<50; class n<30 per test |
| Extreme prevalence (<5% or >95%) | STRONG_WARNING | ✅ | ✅ | |
| Zero cell, LR not estimable | WARNING / INFO | ✅ | ✅ | Wording is wrong for the numerator-zero case (#1) |
| Failed optional step (epiR, Cochran's Q, McNemar pair) | WARNING | ✅ | ✅ | Visible, and names the step |
| Multiplicity | table notes | ✅ | ✅ | Holm over informative pairs; CIs disclosed as unadjusted |
| Methodology summary | INFO | ✅ | ✅ | |

#### Code review

- **Overall quality:** 4/5 stars
- **Architecture:** OK. `.run()` is about 185 lines (LOW). Helpers are well factored and comparator logic is shared.
- **Mathematical/statistical correctness:** MINOR_ISSUES. I checked these by hand against their sources:
  - Wilson, logit and Clopper-Pearson OPA intervals (Wilson 1927; Brown, Cai and DasGupta 2001).
  - McNemar mid-p, eq. 5 and the tie case eq. 6, and the uncorrected asymptotic test (Fagerland, Lydersen and Laake 2013).
  - Cochran's Q formula, and the exact conditional dynamic program for k=3 (row permutations and the monotone score are correct).
  - Newcombe 1998 method 10 for paired differences, including the φ correction (n/2, floored at 0).
  - Bayes PPV and NPV.
  - LR± formed from the class rates.
  - epiR cell order (TP, FP / FN, TN) and statistic codes.
  - Holm adjustment restricted to informative pairs.
  - Comparator PPA, NPA and OPA (exact CIs), and PSA/NSA (2a/(2a+b+c)).
- **Clinical readiness:** NEEDS_VALIDATION
- **i18n coverage:** COMPLETE. All strings are wrapped and `.diagText` is fully overridden. There is LOW splice debt (#5).

**Top issues:**

1. **MEDIUM** — The zero-cell LR correction is described wrongly for a zero numerator. [`R/decisioncompare.b.R:1548`](R/decisioncompare.b.R#L1548)–[`1549`](R/decisioncompare.b.R#L1549) apply the 0.5 correction when `TP == 0 || FP == 0`, and the same for `FN == 0 || TN == 0`. So a test with 100% sensitivity (FN = 0), whose raw LR− is a well-defined 0, is shown as about 0.012 (TP=50, FP=10, TN=40). Three displayed texts claim the correction applies only when the denominator cell is empty:
   - the notice at [`:1604`](R/decisioncompare.b.R#L1604): "would be undefined because the cell in its denominator is empty";
   - the comparison-table footnote at [`:1718`](R/decisioncompare.b.R#L1718): "Denominator cell empty";
   - the cTable footnote at [`:1659`](R/decisioncompare.b.R#L1659): "applied only … (FP = 0 with TP > 0 …, TN = 0 with FN > 0 …)".

   The VAL tests cover only FP = 0. Fix one side: either restrict the correction to `FP == 0` (LR+) and `TN == 0` (LR−), or reword all three texts to say that any zero cell triggers it. `/fix-function decisioncompare` (PLAUSIBLE, probe given).
2. **MEDIUM** — Choosing variables before levels raises a red ERROR. Every Level option has `allowNone: true`, so none is pre-selected. Once the reference and two tests are dropped in, `.validateInputs()` raises ERROR "Missing Positive Levels" plus an error state ([`:1032`](R/decisioncompare.b.R#L1032)–[`1043`](R/decisioncompare.b.R#L1043); missing negatives reach the same state through `.validateMappings()`). This is an incomplete configuration, not a mistake. Guide §25 and the house ROC pattern call for an INFO that names the slots still needing levels, plus a quiet return. `/fix-notices decisioncompare`.
3. **MEDIUM** — The ERROR names a control that no longer exists. `bin_other` at [`R/decisioncompare.b.R:379`](R/decisioncompare.b.R#L379) (and the English default at [`R/utils-diagnostic-comparator.R:38`](R/utils-diagnostic-comparator.R#L38)) tells the user to "Select 'Exclude other observed levels'". The checkbox was renamed `Selected positive and negative levels only` by the F7 fix ([a.yaml:306](jamovi/decisioncompare.a.yaml#L306)). This is the fatal message users see when extra levels exist. `/fix-function decisioncompare`.
4. **LOW** — NA numeric cells render as "NaN", not blank. `opaTable` writes `niMargin = NA_real_` ([`:1816`](R/decisioncompare.b.R#L1816), [`:1868`](R/decisioncompare.b.R#L1868)) whenever the criterion is off (the default). The "OPA Criterion" column therefore reads NaN on every row. Not-estimable Sens/Spec/PPV/NPV/LR cells do the same, while the texts at [`:161`](R/decisioncompare.b.R#L161) and [`:1576`](R/decisioncompare.b.R#L1576) say "set to NA" or "left blank". Write `""` (or NULL) and add a footnote. `/fix-function decisioncompare`.
5. **LOW** — i18n noun splice. Lowercase metric nouns (`.("sensitivity")`, [`:1510`](R/decisioncompare.b.R#L1510)) are spliced into "Unable to compute {metric} for {test}" ([`:161`](R/decisioncompare.b.R#L161)). `paste0(interpretation, " ", .("(Holm-Bonferroni corrected)"))` appends a fragment. `/prepare-translation decisioncompare`.
6. **LOW** — The disease-path heatmap state is uncapped. `.buildHeatmapData()` ([`:3664`](R/decisioncompare.b.R#L3664)) stores n×(k+1) rows for every case. The comparator path caps at 1,000 rows ([utils-diagnostic-comparator.R:236](R/utils-diagnostic-comparator.R#L236)). Large cohorts bloat the `.omv` and draw unreadable tiles. Apply the same cap and say so in a note. `/fix-function decisioncompare`.
7. **LOW** — UI conventions:
   - The individual control label `Prior Probability` is Title Case ([`u.yaml:125`](jamovi/decisioncompare.u.yaml#L125)).
   - `pp` and `pprob` share the same title.
   - The expanded `Reference Interpretation` box sits above the VariableSupplier. This is a deliberate choice; recheck it.

   `/fix-function decisioncompare`.

#### Recommended remediation

- `/fix-function decisioncompare`: LR correction rule vs. text (#1), stale `bin_other` label (#3), NaN cells (#4), heatmap cap (#6), labels (#7)
- `/fix-notices decisioncompare`: pending-levels INFO instead of ERROR (#2)
- `/jamovify-function decisioncompare --apply`: `stop()` after ERROR notice → `jmvcore::reject()`
- `/security-audit-function decisioncompare`: `.diagCellText()` on disease-path test-name cells
- `/prepare-translation decisioncompare`: metric-noun splice

---

### decisioncurve

**Status:** ✅ READY (LOW findings only)
**Files:** [`R/decisioncurve.b.R`](R/decisioncurve.b.R) · [`jamovi/decisioncurve.a.yaml`](jamovi/decisioncurve.a.yaml) · [`jamovi/decisioncurve.u.yaml`](jamovi/decisioncurve.u.yaml) · [`jamovi/decisioncurve.r.yaml`](jamovi/decisioncurve.r.yaml) · helpers [`R/utils-syntax-exports.R`](R/utils-syntax-exports.R), [`R/utils.R`](R/utils.R) (`.fmt`, `.rocLabel`, `.deleteTableRows`)
**Metrics:** .b.R LOC 3398 · options 44 (43 + `data`) · outputs 18 (5 Images, 9 Tables, 4 Html) · UI controls 43 · JS LOC 0 · `.run()` 837 lines ([R/decisioncurve.b.R:1288](R/decisioncurve.b.R#L1288)–2124)

#### Changes since 2026-10-20 audit

The 88-line `.a.yaml` diff (commit `6ae7c93`) is **title-only**: 43 `title:` values Title Case → sentence case, plus `version: 1.1.1`. No option was added, removed, retyped or re-defaulted, so the wiring did not change. All 43 options were re-checked anyway. Every one is read in `.b.R`, or (for `showInterventionAvoided`, `showRelativeUtility`, `showStandardizedNetBenefit`) consumed through `.r.yaml` `visible:` and [`.publishPlotStates`](R/decisioncurve.b.R#L88). The `.u.yaml` diff (12 lines) changes 6 labels only. Backend diff: `.sourcifyOption` override + `is.finite` guards + `.footnoteNA` on two tables.

| Prior | Finding | Now |
|---|---|---|
| F3 | Syntax export failed to parse with spaced column names | **FIXED.** [R/decisioncurve.b.R:17](R/decisioncurve.b.R#L17) routes character options through `.sourcifyDiagnosticOption()` ([R/utils-syntax-exports.R:3](R/utils-syntax-exports.R#L3), `deparse()` literals). Regression: `tests/testthat/test-decisioncurve-audit-fixes.R` (parse + literal round-trip). Executed probe: the exported syntax with spaced names parses **and evaluates**. |
| F7 | Title Case individual labels (`a.yaml:38` "Outcome Variable") | **CHANGED.** All `.a.yaml` titles are now sentence case. But the `.u.yaml` labels, which are what the user actually sees, still include Title Case: [jamovi/decisioncurve.u.yaml:20](jamovi/decisioncurve.u.yaml#L20) "Positive Outcome", :29 "Model Names (optional)", :57 "Step Size". In the same panel, "Outcome variable" (:12) now disagrees with "Prediction Models/Variables" (:23). |
| F9 | `.run()` 837 lines | **STILL PRESENT** (advisory; unchanged span). |

#### Security

*No findings in profile standard.* **Orchestrator verification (executed probe, 2026-10-21):** a candidate G-LOW (unset `decisionRulePositive` omitted from the export → "argument missing") was **refuted**: the export of a default run evaluated without error, because R evaluates a missing argument lazily and the rule-off path never reads it.
- Category D clean. Notice titles and content go through `.safeHtmlOutput` ([:410](R/decisioncurve.b.R#L410)). The Html narratives escape outcome, level, model and rule names ([:1949](R/decisioncurve.b.R#L1949), [:2785](R/decisioncurve.b.R#L2785), [:2899](R/decisioncurve.b.R#L2899)). Cells and notes use `.rocLabel()`, and `.fmt()` defuses braces. Categories A/B/C/E/F/H: none (no formula, no evaluation, no file I/O, no debug flags). `jmvcore::reject("{}", msg=)` ([:374](R/decisioncurve.b.R#L374)) is brace-safe.

#### jmvcore migration

*No migration opportunities found.* No formulas. NA handling is `complete.cases` over the exact analysed variable set. Fatal paths use `jmvcore::reject()` with no catch-all around them. The only `tryCatch` in the run path ([:1014](R/decisioncurve.b.R#L1014)) cannot reach a `reject()`: the length check at [:997](R/decisioncurve.b.R#L997) sits outside it, and the handler re-raises the `.checkpoint()` restart.

#### Integration

**Arguments declared:** 43 (+ data) · **used in logic:** 43 · **dead:** 0
**Outputs declared:** 18 · **populated:** 18 · **unpopulated:** 0

- `requiresData`: none declared, and none needed. All five renderers read only private fields rehydrated from `image$state` ([`.restoreFromState`, :114](R/decisioncurve.b.R#L114), `tryCatch`-guarded). No renderer touches `self$data`.
- State payload is small: the plotted curve frame, the prevalence and the per-100 impact rates. No models and no per-patient vectors (they were stripped earlier; legacy migration at [:131](R/decisioncurve.b.R#L131)). Hidden images get no state, and every state is cleared at the top of `.run()` ([:1332](R/decisioncurve.b.R#L1332)).
- clearWith is complete for every content-determining option: `populationSize`/`selectedThresholds` on the impact, cost and resource items; `bootReps`/`ciLevel`/`seed`/`ciBand` on the plot, comparison and interpretation. `modelComparisonEnhanced` omitting `ciLevel` is correct, because its p-value does not depend on alpha.
- Fixed rows and columns are built in `.init()` ([:183](R/decisioncurve.b.R#L183)) with shared keys (`.tableRowKeys`). `.run()` only `setRow()`s, with `.syncRows` as a fallback. Format tokens are all valid (`zto`, `pc`, `zto,pvalue`). All 8 `refs:` keys resolve in `00refs.yaml` with author, year and url.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Nothing selected | Instructions (quiet) | ✅ | n/a | [:1367](R/decisioncurve.b.R#L1367) |
| Positive level unset (`allowNone`) | INFO + level counts | ✅ | ✅ | [:1399](R/decisioncurve.b.R#L1399); never inferred |
| Invalid config (non-binary, absent level, probabilities outside 0–1, duplicate/reserved names, range) | `reject()` | ✅ | ✅ | `.fatal` [:373](R/decisioncurve.b.R#L373) |
| n < 100 / < 50; events < 25; non-events < 25 | WARNING / STRONG_WARNING | ✅ | ✅ | [:1534](R/decisioncurve.b.R#L1534), [:720](R/decisioncurve.b.R#L720), [:748](R/decisioncurve.b.R#L748) |
| Extreme prevalence / 1:1 case-control / possible inverted risk | STRONG_WARNING / WARNING | ✅ | ✅ | inversion uses DeLong bound + permutation p ([:1870](R/decisioncurve.b.R#L1870)) |
| Failed optional bootstrap | WARNING | ✅ | ✅ | [:1102](R/decisioncurve.b.R#L1102) |
| Apparent (not optimism-corrected) NB | WARNING | ✅ | n/a | [:2091](R/decisioncurve.b.R#L2091) |

#### Code review

- **Overall quality:** 4 stars
- **Architecture:** OK. The long `.run()` is the only structural debt.
- **Mathematical/statistical correctness:** CORRECT (static check against these sources):
  - NB = TP/n − FP/n·t/(1−t), and treat-all = p − (1−p)·t/(1−t) (Vickers & Elkin 2006). The vectorised sweep uses `findInterval(left.open=TRUE)`, so `>=` stays consistent with the exact-threshold path.
  - Net interventions avoided = ΔNB/odds × 100.
  - Relative utility = (NB − max(NB_all, 0)) / (p − D) (Baker 2009 §9). sNB = NB/p (Kerr 2016).
  - DeLong variance from placement values. V10 and V01 were checked against Sun & Xu.
  - Pointwise percentile bootstrap, plus a sup-t band (Montiel Olea & Plagborg-Møller 2019).
  - Holm-adjusted bootstrap p-values, with the Vickers 2023 caution.
  - Oracle script `development-scripts/validate_decisioncurve.R` and seven test files exist; they were not re-run in this static round.
- **Clinical readiness:** READY. Calibration, the prevalence or design caveat, the unit of analysis and optimism are all stated on screen.
- **i18n coverage:** PARTIAL (one deliberate gap, below).

**Top issues:**

1. **LOW**: the residual from F7 (u.yaml labels above) plus stale control names in messages. [R/decisioncurve.b.R:1637](R/decisioncurve.b.R#L1637) says 'disable "Clinical Decision Rule Integration"', but the checkbox is labelled "Clinical decision rule". [:1897](R/decisioncurve.b.R#L1897) names "Positive Outcome Level", but the control is "Positive Outcome". [:1477](R/decisioncurve.b.R#L1477) differs by case only. → `/fix-function decisioncurve`
2. **LOW**: the reference-strategy names "Treat All" / "Treat None" are literal keys ([:1802](R/decisioncurve.b.R#L1802)). They therefore appear untranslated in every plot legend and in the reference-line labels ([:3101](R/decisioncurve.b.R#L3101)). Keep the keys, and map them to `.("Treat all")` / `.("Treat none")` only at draw time. → `/prepare-translation decisioncurve`
3. **LOW**: `.run()` is 837 lines (F9). Extract feature by feature, with parity tests only.

#### Recommended remediation

- `/fix-function decisioncurve`: sentence-case the remaining u.yaml labels; correct the two stale control names in messages
- `/prepare-translation decisioncurve`: translate the reference-strategy display labels in plots

---

### enhancedROC

**Status:** ✅ READY (MEDIUM/LOW findings only; statistics reviewed statically, not executed against oracles)
**Files:** [`R/enhancedROC.b.R`](R/enhancedROC.b.R) · [`jamovi/enhancedROC.a.yaml`](jamovi/enhancedROC.a.yaml) · [`jamovi/enhancedROC.u.yaml`](jamovi/enhancedROC.u.yaml) · [`jamovi/enhancedROC.r.yaml`](jamovi/enhancedROC.r.yaml) · helpers [`R/enhancedROC-errors.R`](R/enhancedROC-errors.R), [`R/enhancedROC-validation.R`](R/enhancedROC-validation.R), [`R/utils-diagnostic-inputs.R`](R/utils-diagnostic-inputs.R), [`R/utils-diagnostic-validation.R`](R/utils-diagnostic-validation.R), [`R/utils.R`](R/utils.R)
**Metrics:** .b.R 6,844 lines (5,043 non-blank/non-comment) · options 90 · outputs 43 (12 Images) · UI controls 89 · JS none · `.run()` 462 lines ([R/enhancedROC.b.R:411](R/enhancedROC.b.R#L411)–872)
**Routing:** `menuGroup: meddecide` (shipped).

#### Changes since 2026-10-20 audit

| Prior | Finding | Now | Evidence (current code) |
|---|---|---|---|
| F2a | Configured positive class absent → ERROR notice, analysis completes | **FIXED** | ERROR added at [R/enhancedROC.b.R:1017](R/enhancedROC.b.R#L1017), `.prepareData()` returns NULL, `.run()` calls `.diagRejectInputErrors()` → `jmvcore::reject()` at [R/enhancedROC.b.R:536](R/enhancedROC.b.R#L536) (helper [R/utils-diagnostic-inputs.R:3](R/utils-diagnostic-inputs.R#L3)). No catch-all around it. Same route for the frozen-validation input errors ([R/enhancedROC.b.R:499](R/enhancedROC.b.R#L499)–504: the helper is caught, the reject is outside the catch). |
| F2b | Untouched / partial selection raised ERROR | **FIXED** (INFO now) | [R/enhancedROC.b.R:483](R/enhancedROC.b.R#L483)–490 emits INFO "Missing Variables" and returns; unset positive class is INFO at [R/enhancedROC.b.R:1040](R/enhancedROC.b.R#L1040). Residual nit: the fully empty state still shows an INFO banner rather than staying quiet behind the instructions. |
| (F2 note) | Constant predictor: ERROR notice, AUC 0.5, run completes | unchanged, not a defect | [R/enhancedROC.b.R:1856](R/enhancedROC.b.R#L1856); cut-point tables skip it. |

Prior: 1/1 fixed.

#### Security

- **[D-LOW]** [`R/enhancedROC.b.R:2335`](R/enhancedROC.b.R#L2335) — predictor names reach table cells raw in ~18 tables (acknowledged TODO in code). Not XSS (client keeps only em/i/sub/sup), but a column named `<LOD flag` renders blank. Wrap cells with `.rocLabel(x, note = FALSE)` as `outcomeCoding` already does. `/fix-function enhancedROC`
- **[H-LOW]** [`R/enhancedROC-errors.R:85`](R/enhancedROC-errors.R#L85) — `clinicopath_error_handler()`, `clinicopath_warning_handler()`, `clinicopath_cleanup()`, `safe_execute()` etc. are exported but called from nowhere in the module and print `cat()` banners to the engine console. Only `clinicopath_init()` (a log-only no-op, [R/enhancedROC.b.R:218](R/enhancedROC.b.R#L218)) and `validate_clinical_data()` are used. Dead exported API; remove or un-export.

All user strings in Html are escaped (`.safeHtmlOutput`, `jmvcore::htmlEscape`, [R/enhancedROC.b.R:77](R/enhancedROC.b.R#L77), [R/enhancedROC.b.R:6624](R/enhancedROC.b.R#L6624)); no `eval`/`parse`/formula-from-string sinks; custom `.sourcifyOption()` quotes non-syntactic Variable(s) and escapes String/Level values ([R/enhancedROC.b.R:6796](R/enhancedROC.b.R#L6796)) — category G clean. Seeds are scoped with `withr::local_seed`/`with_seed` ([R/enhancedROC.b.R:471](R/enhancedROC.b.R#L471)); the `set.seed()` inside `.dvBootstrap()` runs inside that scope.

#### jmvcore migration

*No migration opportunities found.* `jmvcore::naOmit` ([R/enhancedROC.b.R:936](R/enhancedROC.b.R#L936)) and `jmvcore::toNumeric` for coded factors ([R/enhancedROC.b.R:942](R/enhancedROC.b.R#L942)) already used; fatal input errors go through `jmvcore::reject()`; no string formulas.

#### Integration

**Arguments declared:** 90 · **used in logic:** 88 directly or via the frozen-validation helper · **dead:** 0. `nntCalculation` and `decisionImpactTable` are visibility-only gates (column/table `visible:`), by design. Commented-out options (`bootstrapCutoffCI`, `calibrationBelt`, `harrellCIndex`, …) are not referenced by the backend or UI.

**Outputs declared:** 43 · **populated:** 43 · **unpopulated:** 0. All 12 Images draw from `image$state` only (no `self$data` / `.analysisData` / refit reachable from any renderer or its helpers — traced), so the absence of `requiresData` is correct; every renderer guards a NULL/old-schema state ([R/enhancedROC.b.R:393](R/enhancedROC.b.R#L393)–410). `setSize()` is in `.init()`. Every table is cleared with `.deleteTableRows()` before refilling, and early returns only follow changes to options that every item lists in `clearWith` — no stale-restore path found. All `refs:` keys resolve in `jamovi/00refs.yaml`; all `format:` tokens valid.

| Output | Type | Setter | Populated? | Notes |
|---|---|---|:---:|---|
| `instructions` | Html | `setContent` in `.init()` | ✅ | `visible: true` ([jamovi/enhancedROC.r.yaml:28](jamovi/enhancedROC.r.yaml#L28)); the long educational panel never hides, even beside results (LOW, finding 3) |
| 10 ROC-based Images | Image | `.publishPlotStates()` | ✅ | full ROC coordinates copied into every image's state whether or not the image is visible (LOW heavy-state, finding 5) |

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | INFO | ✅ | n/a | INFO, not quiet, on a fresh panel ([R/enhancedROC.b.R:484](R/enhancedROC.b.R#L484)) |
| Configured-invalid input (positive class absent, non-binary numeric outcome, non-numeric predictor, n < 20, level lost to missingness) | ERROR + `reject()` | ✅ | ✅ | FIXED since prior audit |
| Low n / events | ERROR <10 per class; WARNING n < 30 | ✅ | ✅ | [R/enhancedROC.b.R:1830](R/enhancedROC.b.R#L1830) |
| DeLong small-sample under-coverage | WARNING | ✅ | ✅ | rule n_min·(1−AUC) < 6 checked exact in integers ([R/enhancedROC.b.R:598](R/enhancedROC.b.R#L598)) |
| Repeated rows per patient | WARNING | ✅ | ✅ | [R/enhancedROC.b.R:554](R/enhancedROC.b.R#L554) |
| AUC < 0.5 / < 0.7, auto-direction bias, extreme prevalence, imbalance | ERROR/STRONG_WARNING/WARNING | ✅ | ✅ | reversal only asserted when CI lies wholly below 0.5 |
| Failed optional step (bootstrap CI, band, smoothing, comparison, partial AUC, calibration, CV) | WARNING | ✅ | ✅ | per-step catches, named predictor |
| Every predictor failed | ERROR, no reject | ⚠️ | ✅ | finding 2 |
| Risk model replaced by constant prevalence | — | ❌ | — | finding 1 |
| Methodology summary | INFO | ✅ | ✅ | "Analysis Complete / Finished with Errors/Warnings" |

#### Code review

- **Overall quality:** 4/5 (heavily remediated; most numbers carry their caveats)
- **Architecture:** OK, but `.run()` is 462 lines (LOW)
- **Mathematical/statistical correctness:** MINOR_ISSUES. Checked by hand against the cited definitions: Youden / closest-to-corner search with exact count-based ties ([R/enhancedROC.b.R:2036](R/enhancedROC.b.R#L2036)); PPV/NPV by Bayes, LR±, DOR with zero-cell handling ([R/enhancedROC.b.R:2718](R/enhancedROC.b.R#L2718)); Clopper–Pearson at the chosen level ([R/enhancedROC.b.R:4001](R/enhancedROC.b.R#L4001)); stratified bootstrap with BCa→percentile fallback ([R/enhancedROC.b.R:1268](R/enhancedROC.b.R#L1268)); tie bounds AUC ± p_tie/2; CROC integral and random baseline 1/α − 1/(e^α − 1) (Swamidass 2010) ([R/enhancedROC.b.R:3304](R/enhancedROC.b.R#L3304)); upper convex hull by monotone chain; HL statistic Σ(O−E)²/[E(1−E/n)], df g−2 vs g; scaled Brier; ICI/E50/E90 (Austin & Steyerberg 2019); net benefit and treat-all (Vickers); Harrell optimism ([R/enhancedROC.b.R:6689](R/enhancedROC.b.R#L6689)); Venkatraman p floored at 1/(B+1). All correct. Not executed against pROC/rms oracles.
- **Clinical readiness:** NEEDS_VALIDATION
- **i18n coverage:** PARTIAL (a few English fragments; finding 4)

**Top issues:**

1. **MEDIUM** — Silent null-model substitution in every risk-based output. [R/enhancedROC.b.R:2623](R/enhancedROC.b.R#L2623)–2633: with Prediction scale = Score, when the fitted logistic slope's sign contradicts Direction (e.g. the default `direction: higher` on a marker where lower values mean disease), `.riskProbabilities()` returns a constant risk equal to the sample prevalence, with no notice.
   ```r
   if (!is.finite(slope) || (identical(dir_opt, "higher") && slope < 0) || ...) {
       p_bar <- mean(y_binary, na.rm = TRUE)
       return(list(probs = rep(p_bar, n_obs), lp = rep(lp_bar, n_obs), ...))
   ```
   Downstream, the outputs are labelled with the marker's name but describe the intercept-only model: the Brier score becomes prev(1 − prev), with a scaled Brier of 0. The decision and clinical-impact curves become the treat-all line, then 0. Hosmer–Lemeshow is skipped with a wrong reason ("predictor has very few unique values", [R/enhancedROC.b.R:5646](R/enhancedROC.b.R#L5646)). The calibration plot says "usually means the predictor is constant" ([R/enhancedROC.b.R:5768](R/enhancedROC.b.R#L5768)). This is the constrained MLE, so the numbers are defensible, but nothing on screen says what happened. Add one WARNING per predictor from `.riskNotices()` naming the contradiction. `/fix-notices enhancedROC`. PLAUSIBLE (probe below).
2. **MEDIUM** — When ROC analysis fails for every predictor, the run completes with an ERROR banner instead of rejecting. [R/enhancedROC.b.R:580](R/enhancedROC.b.R#L580)–583 adds "No Predictor Could Be Analysed" as an ERROR, then the run continues and completes with every binary table empty. This is a fatal state, so call `jmvcore::reject()` (outside the per-predictor `tryCatch`). Reachability is narrow, since `.prepareData()` already screens type, levels and n. `/fix-function enhancedROC`
3. **LOW** — The `instructions` Html is `visible: true` and is filled in `.init()` on every run ([R/enhancedROC.b.R:228](R/enhancedROC.b.R#L228)). The setup guide, presets and glossary stay above the results permanently, against the opt-in rule for educational panels. Gate it on an option, or hide it once results exist. `/fix-function enhancedROC`
4. **LOW** — i18n fragments in English:
   - "(AUC =" pasted into a cell at [R/enhancedROC.b.R:3529](R/enhancedROC.b.R#L3529).
   - PPV/NPV legend keys at [R/enhancedROC.b.R:5085](R/enhancedROC.b.R#L5085).
   - "vs" in class-pair cells at [R/enhancedROC.b.R:6165](R/enhancedROC.b.R#L6165).
   - "binormal"/"kernel density" spliced into a translated sentence at [R/enhancedROC.b.R:622](R/enhancedROC.b.R#L622).
   - `validate_clinical_data()` errors shown verbatim at [R/enhancedROC.b.R:900](R/enhancedROC.b.R#L900).

   `/prepare-translation enhancedROC`
5. **LOW** — `.publishPlotStates()` ([R/enhancedROC.b.R:357](R/enhancedROC.b.R#L357)–381) writes the full ROC staircase of every predictor into 10 image states, including the comparative, CROC and hull plots when they are hidden. That is O(n × predictors × 10) doubles saved in the `.omv`. Publish state only for visible images. `/fix-function enhancedROC`
6. **LOW** — UI labels:
   - "Outcome Variable" and "Predictor Variables" are in Title Case ([jamovi/enhancedROC.u.yaml:13](jamovi/enhancedROC.u.yaml#L13), [:24](jamovi/enhancedROC.u.yaml#L24)), while the .a.yaml titles and the other target labels use sentence case.
   - The action-verb title "Explain the imbalance warning in full" ([jamovi/enhancedROC.a.yaml:401](jamovi/enhancedROC.a.yaml#L401)) should be a noun phrase.

   `/fix-function enhancedROC`
7. **LOW** — `.run()` is 462 lines, and the 70-line binary branch (lines 575–775) could be extracted. Hygiene only.

#### Recommended remediation

- `/fix-notices enhancedROC`: add a per-predictor WARNING when the risk model is constrained to constant prevalence (finding 1). Fix the HL and calibration-plot reasons in the same pass.
- `/fix-function enhancedROC`: reject when no predictor yields ROC results (2), gate `instructions` (3), publish only visible image states (5), wrap cell names with `.rocLabel` (Security D), fix the UI labels (6), and remove the dead exported error helpers (Security H).
- `/prepare-translation enhancedROC`: fix the fragments in finding 4.
- `/validate-function enhancedROC`: oracle-check the AUC/CI, cut-point, calibration, decision-curve and multi-class numbers against pROC, rms and dcurves before calling it clinically READY.

---

### kappaSizeCI

**Status:** ✅ READY (two LOW findings; no HIGH/CRITICAL, no security finding)
**Files:** [`R/kappaSizeCI.b.R`](R/kappaSizeCI.b.R) · [`jamovi/kappaSizeCI.a.yaml`](jamovi/kappaSizeCI.a.yaml) · [`jamovi/kappaSizeCI.u.yaml`](jamovi/kappaSizeCI.u.yaml) · [`jamovi/kappaSizeCI.r.yaml`](jamovi/kappaSizeCI.r.yaml) · [`jamovi/js/kappaSizeCI.events.js`](jamovi/js/kappaSizeCI.events.js) · helper [`R/utils-kappasize.R`](R/utils-kappasize.R)
**Metrics:** .b.R LOC 1229 (657 non-blank/non-comment) · options 10 · outputs 4 (Html `notices`, Preformatted `text1`/`text_summary`/`text2`; no Images) · UI controls 10 · JS LOC 35 · `.run()` 134 lines (mostly comments) · 88 `.()` msgids, all with a Turkish `msgstr` in `jamovi/i18n/tr.po`

#### Changes since 2026-10-20 audit

The 2026-10-20 report recorded **no findings** for kappaSizeCI ("No blocking issue confirmed"). `git log` since then
touches only the `version:` line of `kappaSizeCI.a.yaml` (6ae7c93); `.b.R`, `.r.yaml`, `.u.yaml`, the events JS and
`utils-kappasize.R` are unchanged. Prior: 0/0. The two LOW items below are new observations, not regressions.

#### Security

*No findings in profile standard.*

- `props` (free-text `String`, HIGH-tier source) only ever reaches the engine as a parsed numeric vector
  ([R/kappaSizeCI.b.R:82](R/kappaSizeCI.b.R#L82)–[89](R/kappaSizeCI.b.R#L89)); no user string enters the Html.
  All values interpolated into `notices` are numbers.
- Syntax export (G): `.sourcifyOption` ([R/kappaSizeCI.b.R:1088](R/kappaSizeCI.b.R#L1088)) routes through
  `kappaSizeSourcifyOption` ([R/utils-kappasize.R:83](R/utils-kappasize.R#L83)), which escapes strings with
  `encodeString(quote = '"')` and drops list-valued options from a crafted `.omv`. No column names in this analysis.
- JS: no `innerHTML`; `onChange_outcome` only rewrites `props` when the value count no longer fits.
- No `eval`/`parse`/formula/file/system calls; no debug flags; no `set.seed`, `warning()` or `print()`.

#### jmvcore migration

*No migration opportunities found.* (No formulas, no data, no NA handling; errors already use `jmvcore::reject()`.)

#### Integration

**Arguments declared:** 10 · **used in logic:** 10 · **dead:** 0

**Outputs declared:** 4 · **populated:** 4 · **unpopulated:** 0

- clearWith (§2b) complete: `notices` lists all 10 options (its content depends on `showExplanations`/`showSummary`);
  `text1` lists the 8 design options and depends on nothing else; `text_summary`/`text2` add their own checkbox.
- `text2`/`text_summary` are `visible: (showX)` and are built only when visible
  ([R/kappaSizeCI.b.R:1207](R/kappaSizeCI.b.R#L1207)–[1208](R/kappaSizeCI.b.R#L1208)) — no computed-invisible work.
- No Images → no `requiresData`/`image$state`/`setState` concerns. Html uses `rgba(...)` tints with `color: inherit`
  (theme-safe). No `insert()`.
- tryCatch trace: the `.run()` display block ([R/kappaSizeCI.b.R:1129](R/kappaSizeCI.b.R#L1129)) guards only
  formatting helpers that never call `reject()`, and its handler re-raises via `reject()`; the engine tryCatch
  ([R/kappaSizeCI.b.R:613](R/kappaSizeCI.b.R#L613)) wraps only the vendor call; `.checkpoint()` sits outside it;
  `setTimeLimit` is lifted by `on.exit` and explicitly ([R/kappaSizeCI.b.R:651](R/kappaSizeCI.b.R#L651)); time-out
  detected by wall clock, not translated message text. `.validateProportions`' tryCatch contains no `reject()`.
- Refs: all 7 keys in `.r.yaml` resolve in `jamovi/00refs.yaml` with a `url`. `kappaSize` is in `DESCRIPTION` Imports.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Invalid configuration (limits, proportions, % / decimal comma) | `reject()` | ✅ | ✅ | `code='validation_failed'`; specific, actionable messages ([L1096](R/kappaSizeCI.b.R#L1096)) |
| Unsizeable / too-narrow design | `reject()` | ✅ | ✅ | quotes the closed-form n and the governing distance ([L559](R/kappaSizeCI.b.R#L559)) |
| Engine non-convergence | `reject()` | ✅ | ✅ | wall-clock detected; advises fewer raters ([L632](R/kappaSizeCI.b.R#L632)) |
| Sparse GOF cells (Cochran) | warning panel | ✅ | ✅ | judged per limit on the pooled cells of the test ([L178](R/kappaSizeCI.b.R#L178)) |
| Small n (< 25) | warning panel | ✅ | ✅ | source-qualified ([L1039](R/kappaSizeCI.b.R#L1039)) |
| Rare category (< 5%) | warning panel | ✅ | ✅ | expected positives per rater ([L1020](R/kappaSizeCI.b.R#L1020)) |
| Very large n (> 1000) | warning panel | ✅ | ✅ | advice adapts to sparse state ([L1049](R/kappaSizeCI.b.R#L1049)) |
| Planning-expectation / interval-type caveat | info panel | ✅ | — | always shown |
| Methodology summary | info panel | ✅ | — | opt-in (`showExplanations`) |

Empty state not applicable (no-data calculator with valid defaults); an emptied `props` box is a configured-invalid
`reject()`, which is correct.

#### Code review

- **Overall quality:** 4 stars
- **Architecture:** OK — shared closed forms in `R/utils-kappasize.R`; slopes computed once per run (`params$governing`).
- **Mathematical/statistical correctness:** CORRECT for the published (fixed-proportion) calculation; the
  restricted-ML extension is NOT independently evaluated here. Checked statically: the engine's statistic
  Σ (nP_j(κ0) − nP_j(ρ))² / nP_j(ρ) is exactly n·slope, so n = ⌈χ²_crit / min slope⌉ ([L466](R/kappaSizeCI.b.R#L466));
  critical values qchisq(1−α,1) two-sided and qchisq(1−2α,1) one-sided match Rotondi & Donner 2012 p.780; binary
  cells are the Altaye–Donner–Klar common-correlation form (binomial·(1−ρ) + ρ on the two concordant cells) and
  pooling the split cells leaves the chi-square unchanged because every interior cell scales by (1−ρ); 3–5
  category cells are the Dirichlet-multinomial product. Smaller-first binary props are justified by relabelling
  symmetry. The umbrella's `test-kappaSizeCI-validation.R` pins the fixed path to RD2012's published cells and
  the worked example (171 fixed / 190 re-estimated).
- **Clinical readiness:** NEEDS_VALIDATION (the reported n for every design except binary/2 raters comes from the
  in-house restricted-ML rule, supported by the module's own simulations rather than a published table).
- **i18n coverage:** COMPLETE (88/88 msgids translated in `tr.po`; minor fragments below).

**Top issues:**

1. **LOW** — Reported n departs from kappaSize / RD2012 tables without saying so in the always-visible output.
   For every design except a binary outcome with two raters, `required_n` is `pmin(fixed, rml)` slopes
   ([R/kappaSizeCI.b.R:409](R/kappaSizeCI.b.R#L409)–[417](R/kappaSizeCI.b.R#L417), used at
   [L1121](R/kappaSizeCI.b.R#L1121)), so it exceeds what `kappaSize::CI3Cats` or the published tables give
   (e.g. 190 vs 171 for RD2012's own example). The difference is explained only in the opt-in Study Explanation
   ([L735](R/kappaSizeCI.b.R#L735)) and Summary ([L1174](R/kappaSizeCI.b.R#L1174)) panes; the default Notes/text1
   and the `.a.yaml` `description.main` ("the confidence-interval approach of the kappaSize package") do not. A user
   reproducing the figure in kappaSize, or citing RD2012 in a methods section, sees a number that does not match.
   The figure is the more conservative one, so this is labelling, not a wrong n. Fix: one always-visible sentence in
   `caveats` when `n_min > n_fixed` naming both figures. `/review-function kappaSizeCI`.
2. **LOW** — i18n fragments: `.subjects()` splices a singular/plural word into "{n} {subjects}"
   ([L1075](R/kappaSizeCI.b.R#L1075)–[1085](R/kappaSizeCI.b.R#L1085); gettext plural forms cannot be expressed this
   way, and that msgid carries `<b>` markup against the file's own "tags outside msgids" rule at
   [L902](R/kappaSizeCI.b.R#L902)); `.fmtCount()` returns translated phrases ("below 0.0001", "unavailable",
   [L229](R/kappaSizeCI.b.R#L229)–[230](R/kappaSizeCI.b.R#L230)) spliced into "the smallest expected count is {min}"
   ([L1006](R/kappaSizeCI.b.R#L1006)); `ci_side_text` is spliced into "({side})" ([L897](R/kappaSizeCI.b.R#L897)).
   Harmless in Turkish today. `/prepare-translation kappaSizeCI`.

#### Recommended remediation

- `/review-function kappaSizeCI` — add an always-visible sentence when the reported n exceeds kappaSize's fixed-proportion figure; align `description.main`.
- `/prepare-translation kappaSizeCI` — replace the spliced plural/fragment msgids with complete sentences (low priority).

---

### kappaSizeFixedN

**Status:** ✅ READY (LOW findings only)
**Files:** [`R/kappaSizeFixedN.b.R`](R/kappaSizeFixedN.b.R) · [`jamovi/kappaSizeFixedN.a.yaml`](jamovi/kappaSizeFixedN.a.yaml) · [`jamovi/kappaSizeFixedN.u.yaml`](jamovi/kappaSizeFixedN.u.yaml) · [`jamovi/kappaSizeFixedN.r.yaml`](jamovi/kappaSizeFixedN.r.yaml) · [`jamovi/js/kappaSizeFixedN.events.js`](jamovi/js/kappaSizeFixedN.events.js) · helpers [`R/utils-kappasize.R`](R/utils-kappasize.R) (`kappaSizeGofCells`, `kappaSizePropsLookDecimalComma`, `kappaSizeSourcifyOption`), [`R/utils.R:100`](R/utils.R#L100) (`.fmt`)
**Metrics:** .b.R LOC 803 · options 8 · outputs 5 (3 Preformatted, 2 Html; 0 Images, 0 Tables) · UI controls 8 · JS LOC 35 · `.run()` 179 lines

#### Changes since 2026-10-20 audit

The 1.1.0 audit recorded **no findings** for kappaSizeFixedN (READY scoped, math NOT_EVALUATED,
readiness NEEDS_VALIDATION). Nothing to mark FIXED / STILL PRESENT. This round re-read the full
current backend (all 803 lines), the three YAMLs, the events JS and the shared helpers. It
evaluates the fixed-proportion statistics independently (see Code review) and adds three LOW
findings that the earlier audit did not record.

#### Security

*No findings in profile standard.*

- Html panels (`notices`, `methodology`) interpolate only computed numbers and translated
  constants. The user's `props` tokens reach only the Preformatted `text2`
  ([R/kappaSizeFixedN.b.R:740](R/kappaSizeFixedN.b.R#L740)), which is not HTML. The engine's
  `conditionMessage` also goes to Preformatted only ([:710](R/kappaSizeFixedN.b.R#L710)).
- Syntax export: `.sourcifyOption` drops option names that are not formals of the wrapper and
  escapes every non-default string with `encodeString()` ([:618](R/kappaSizeFixedN.b.R#L618),
  [R/utils-kappasize.R:83](R/utils-kappasize.R#L83)). Category G is closed. There are no column
  names because the analysis takes no data.
- The vendor loop is bounded by `setTimeLimit(elapsed = 5)` inside `tryCatch`, and the limit is
  reset right after it ([:702-707](R/kappaSizeFixedN.b.R#L702)), which is the documented pattern.

#### jmvcore migration

*No migration opportunities found.* (No dataset, formula, `as.numeric(factor)` or NA handling.
Every validation failure uses `jmvcore::reject()`.)

#### Integration

**Arguments declared:** 8 · **used in logic:** 8 · **dead:** 0

**Outputs declared:** 5 · **populated:** 5 · **unpopulated:** 0

- **Reset on rerun:** all five panels are blanked before `.validateInputs()`
  ([:628-632](R/kappaSizeFixedN.b.R#L628)), so a rejected rerun cannot leave stale numbers.
  `notices` is never left as `""` (it falls back to `<div></div>`, [:797](R/kappaSizeFixedN.b.R#L797)).
- **clearWith (§2b):** complete. `text1` and `notices` depend only on the six calculation options.
  `text_summary` also lists `showSummary`, `text2` lists `showExplanations`, and `methodology`
  lists both, which matches what each builder reads.
- **Error handling:** `.validateInputs()` and the `fixed`-bound `reject()`
  ([:661](R/kappaSizeFixedN.b.R#L661)) sit outside every `tryCatch`. The three `tryCatch`
  regions (nlminb [:218](R/kappaSizeFixedN.b.R#L218), uniroot [:271](R/kappaSizeFixedN.b.R#L271),
  engine [:702](R/kappaSizeFixedN.b.R#L702)) cannot reach `reject()`.
- **Other checks:** no images, so `requiresData` and `setState` do not apply. No tables, so
  fixed rows built in `.run()` do not apply. No `set.seed`, `warning()` or `insert()`.
- **Events JS:** it overwrites `props` only when the token count no longer fits the level count,
  so a saved `.omv` is not reset on load. Its regex agrees with the backend parser.
- **Refs:** 8 keys in `.r.yaml`. Citation integrity in `00refs.yaml` was not re-checked in this pass.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Invalid input (levels, raters, props format/count/range/sum, decimal comma, N, kappa0, alpha) | `reject()` | ✅ | ✅ | [:536-612](R/kappaSizeFixedN.b.R#L536); count and sum quoted |
| Bound not computable (extreme rarity) | `reject()` | ✅ | — | [:661](R/kappaSizeFixedN.b.R#L661) |
| Bound ≤ 0 (cannot exclude chance) | red block | ✅ | ✅ | [:318](R/kappaSizeFixedN.b.R#L318) |
| Bound < 0.40 (no reliability claim) | amber block | ✅ | ✅ | remedy depends on whether the bound can reach 0.40 within option limits (kappa0 ≤ 0.40 / `liftable`) |
| Rarest category < 1 expected per rater | red block | ✅ | ✅ | [:358](R/kappaSizeFixedN.b.R#L358) |
| Sparse GOF cells (Cochran rule) | amber block | ✅ | ✅ | judged on the pooled cells at the reported bound |
| Rare category < 5% | amber block | ✅ | ✅ | |
| N < 25 | amber block | ✅ | ✅ | cites DE1992 / ADK2001 qualifiers |
| Re-estimation fit failed | info caveat | ✅ | — | [:470](R/kappaSizeFixedN.b.R#L470) |
| Methodology summary | info block | ✅ | — | caveats always shown; detail behind `showExplanations` |

Empty state is not applicable: no data is needed and the defaults are a valid design.

#### Code review

- **Overall quality:** 4/5 stars
- **Architecture:** OK. The cell model is shared through `R/utils-kappasize.R`. `.run()` is
  179 lines, and the RML fitter/bracket logic is dense but heavily commented.
- **Mathematical/statistical correctness:** CORRECT for the fixed-proportion core, checked
  against Donner & Eliasziw 1992 and Altaye, Donner & Klar 2001:
  - Binary cells are C(R,j)p^j(1−p)^(R−j)(1−ρ) + ρ·[p if j=R, 1−p if j=0] (ADK eq. 4). For R=2
    this reduces to p²+ρp(1−p) and 2p(1−p)(1−ρ).
  - The multi-category "all agree on j" cell is the Dirichlet-multinomial product, which I
    re-derived with α_j = p_j(1−ρ)/ρ.
  - X² = N·Σ(q−b)²/b, with q the cells at κ0 and b the cells at ρ.
  - The one-sided critical value is χ²₁(1−2α), which equals z²₁₋α.
  - The root is bracketed between the model floor and κ0.
  
  The restricted-ML (re-estimated) lower bound is an in-house extension that neither kappaSize
  nor the published tables have. It rests on the project's own simulations (VAL-03) and was
  **not independently verified** here.
- **Clinical readiness:** NEEDS_VALIDATION, because of the RML extension. The fixed-proportion
  path is ready.
- **i18n coverage:** COMPLETE. Every user string is wrapped and catalogued, and the spot-checked
  `tr.po` msgids are translated. No separator inside `.()`, no `" ["`, no `\u{}` inside `.()`.

**Top issues:**

1. **LOW** — When the re-estimated bound governs, the default view does not say so. If it
   governs and differs at the shown precision (`show_rml`, [R/kappaSizeFixedN.b.R:674](R/kappaSizeFixedN.b.R#L674)),
   the headline `text1` ([:678](R/kappaSizeFixedN.b.R#L678)) reports a figure below
   kappaSize's and below the Rotondi–Donner tables. The explanation appears only in `text2`
   (`showExplanations`), the Summary pane (`showSummary`) or the methodology detail
   (`show_details`), and both options are off by default. The always-on caveats block
   mentions re-estimation only in the `failed` case ([:470](R/kappaSizeFixedN.b.R#L470)). A
   user cross-checking against kappaSize sees an unexplained, lower number. The fix is one
   always-on caveat sentence when `show_rml`. Tool: `/fix-function kappaSizeFixedN`.
2. **LOW** — Results headings use mixed case. `text1` is "Analysis result" and `text_summary`
   is "Summary by the published formula (kappaSize)", both sentence case
   ([jamovi/kappaSizeFixedN.r.yaml:19](jamovi/kappaSizeFixedN.r.yaml#L19),
   [:30](jamovi/kappaSizeFixedN.r.yaml#L30)). Their siblings "Study Explanation" and
   "Methodology" are Title Case. Tool: `/fix-function kappaSizeFixedN`.
3. **LOW** — `.run()` is 179 lines ([:624-802](R/kappaSizeFixedN.b.R#L624)), above the
   ~120-line guidance. The Summary-pane engine block (:683-737) and the Study Explanation
   builder (:739-776) could be extracted. Tool: `/review-function kappaSizeFixedN`.

#### Recommended remediation

- `/fix-function kappaSizeFixedN`: add an always-on sentence when the re-estimated bound
  governs, and make the result titles Title Case.
- `/review-function kappaSizeFixedN`: extract the two optional-pane builders from `.run()`.
- `/check-function-full kappaSizeFixedN`: independent oracle for the RML bound (e.g. the
  3-category / 3-rater RD2012 design and binary with 4 raters, p 0.1) before calling it
  clinically validated.

---

### kappaSizePower

**Status:** ✅ READY (LOW findings only)
**Files:** [`R/kappaSizePower.b.R`](R/kappaSizePower.b.R) · [`jamovi/kappaSizePower.a.yaml`](jamovi/kappaSizePower.a.yaml) · [`jamovi/kappaSizePower.u.yaml`](jamovi/kappaSizePower.u.yaml) · [`jamovi/kappaSizePower.r.yaml`](jamovi/kappaSizePower.r.yaml) · [`jamovi/js/kappaSizePower.events.js`](jamovi/js/kappaSizePower.events.js) · helper [`R/utils-kappasize.R`](R/utils-kappasize.R) · `.fmt` in [`R/utils.R:100`](R/utils.R#L100)
**Metrics:** .b.R LOC 756 · options 7 · outputs 4 (1 Html, 3 Preformatted, 0 Images) · UI controls 7 · JS LOC 35 · menuGroup `Power` (shipped)

#### Changes since 2026-10-20 audit

The 2026-10-20 report listed **no findings** for kappaSizePower (READY scoped, 0/0 security, "No blocking issue confirmed"; math marked NOT_EVALUATED). Nothing to mark FIXED or STILL PRESENT. This pass adds a statistical check (below) and three new LOW findings. The prior audit did not count the 283-line `.run()` as a finding; it is still that long ([R/kappaSizePower.b.R:473](R/kappaSizePower.b.R#L473) to [:755](R/kappaSizePower.b.R#L755)).

#### Security

*No findings in profile standard.*

- `props` (the only free-text String) is parsed to numbers ([R/kappaSizePower.b.R:42](R/kappaSizePower.b.R#L42)). Only numbers reach the Html `notices` and the Preformatted panes. No raw user text reaches HTML (D) or a formula (C).
- Syntax export: `kappaSizeSourcifyOption()` escapes non-default strings with `encodeString()` and drops list values ([R/utils-kappasize.R](R/utils-kappasize.R)). `.sourcifyOption` drops names that are not formals of the wrapper ([R/kappaSizePower.b.R:467](R/kappaSizePower.b.R#L467)). Category G is clean.
- Seeds: simulation runs inside `withr::with_seed()` ([:168](R/kappaSizePower.b.R#L168), [:685](R/kappaSizePower.b.R#L685)). There is no bare `set.seed`. `options(scipen = 999)` is restored with `on.exit` ([:647](R/kappaSizePower.b.R#L647)).
- No debug flags, no `library()`, no file or process access.

#### jmvcore migration

*No migration opportunities found.* Validation uses `jmvcore::reject()` throughout. There is no formula, no data frame and no `na.omit`.

#### Integration

**Arguments declared:** 7  ·  **used in logic:** 7  ·  **dead:** 0
All seven options (`outcome`, `kappa0`, `kappa1`, `props`, `raters`, `alpha`, `power`) feed the engine call and the recomputed N. `events.js` replaces `props` only when its count is invalid for the new `outcome` (1–2 values for binary, else K). This preserves values loaded from an `.omv`.

**Outputs declared:** 4  ·  **populated:** 4  ·  **unpopulated:** 0
`notices` (Html), `text1`, `text_summary` and `text2` (Preformatted) are all set every run ([:664](R/kappaSizePower.b.R#L664), [:668](R/kappaSizePower.b.R#L668), [:701](R/kappaSizePower.b.R#L701), [:747](R/kappaSizePower.b.R#L747)). Each item's `clearWith` lists all 7 options, so there is no clearWith gap. There are no Images, so requiresData, image state and heavy state do not apply. The Notes Html is never `""` after a successful run, because the Methodology block is always present, so the empty-Html client skip does not apply.

**tryCatch trace:** only one, at [:602](R/kappaSizePower.b.R#L602). It guards only the `kappaSize::Power*` call, and `reject()` is in the handler, not in the guarded region. No reject is swallowed.

**Citations:** all 6 `refs:` keys resolve in `jamovi/00refs.yaml` with author and year (`kappaSize`, `rotondiDonnerKappaCI`, `donnerEliasziwKappaGOF`, `altayeDonnerKlarKappaRaters`, `altayeDonnerEliasziwKappaGOF`, `ClinicoPathJamoviModule`). Every author named in the Methodology text is citable.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Invalid configuration (props unreadable, wrong count, sum ≠ 1, decimal comma, alpha ≥ power, kappa0 = kappa1) | `reject()` | ✅ | ✅ | Specific, actionable messages ([:488](R/kappaSizePower.b.R#L488)–[:591](R/kappaSizePower.b.R#L591)). alpha ≥ power is refused before the engine, which would otherwise hang. |
| Empty state | — | n/a | — | No data is needed and the defaults are valid, so it runs at once. |
| Very small N (< 10) / very large N (> 2000) | warning block | ✅ | ✅ | Prints N. |
| Sparse GOF cells (Cochran) + rare marginal category | warning block | ✅ | ✅ | Gives the smallest expected count and the number of cells below 5. Uses the pooled cells of the actual test. |
| Simulated power short of the stated power (binary) | warning block | ✅ | ✅ | Shows the simulated power, the simulated N and the seed (4000 replicates). |
| Proportions treated as known (3–5 categories) | warning block | ✅ | n/a | Qualitative by design (local projection, see the code comment at [:81](R/kappaSizePower.b.R#L81)). |
| kappa1 < kappa0, gap < 0.05, power < 0.5 | warning block | ✅ | ✅ | |
| Methodology summary | info block | ✅ | — | Estimand (intraclass kappa, no rater bias), test, model and limitations. |

Delivered through the HTML Notes panel, the house pattern. It uses theme-safe rgba backgrounds with `color: inherit` and has no named symbol entities.

#### Code review

- **Overall quality:** 4/5 stars
- **Architecture:** OK. Shared cells, decimal-comma detection and sourcify live in `R/utils-kappasize.R`. `.run()` is long (LOW).
- **Mathematical/statistical correctness:** CORRECT (checked statically; Monte Carlo figures not re-run). What was checked:
  - **N formula.** N = λ / Σ(P1−P0)²/P0, with λ solved from `pchisq(qchisq(1−α,1), 1, ncp=λ) = 1−power` ([:634](R/kappaSizePower.b.R#L634)–[:638](R/kappaSizePower.b.R#L638)). This is the noncentrality of a 1-df GOF test (Donner & Eliasziw 1992). The bracket `c(0,100)` holds: at λ = 0 the residual is power − α > 0, guaranteed by the `alpha >= power` reject; at the extremes (α = 0.001, power = 0.99) λ ≈ 31.6.
  - **Pooling.** For binary with 3+ raters, N is computed on the unpooled cells. I checked algebraically that, under the ADK mixture, the middle cells have P1−P0 = binom_j(ρ0−ρ1) and P0 = (1−ρ0)·binom_j. Pooling them therefore gives the same Σ(P1−P0)²/P0, so the code comment at [:736](R/kappaSizePower.b.R#L736) is correct.
  - **Cell probabilities.** `kappaSizeGofCells` (Dirichlet-multinomial agreement cells plus one pooled disagreement cell) was checked against the formula as written.
  - **`.simPowerBinary`.** The score derivatives for the three pooled cells are correct: d0 = −(1−ρ)r(1−q)^(r−1) − ρ, dn = (1−ρ)r q^(r−1) + ρ, and the middle cell is −(d0+dn). The middle cell is ≥ 0 for ρ ∈ (0,1), so the bisection is well defined. df = 3 − 1 − 1 = 1.
  - **`lam()`.** `pnorm(√λ−z)+pnorm(−√λ−z)` is the exact 1-df noncentral chi-square power.
  - **`.estimatedPropsRatio`.** The Jacobian G (product-rule derivative of the agreement cells, with the K-th proportion as the complement) and the weighted QR projection match Mitra's estimated-parameter noncentrality. It is used only to trigger a warning.
  - **Renormalising props** ([:568](R/kappaSizePower.b.R#L568)) prevents the documented negative-N engine defect.
  - **Prior validation.** The in-code history cites four validation rounds plus an independent review, with oracle scripts in the umbrella (`development-scripts/validate_kappaSizePower.R`, `audit_kappaSizePower.R`) and three test files (`tests/testthat/test-kappaSizePower*.R`).
- **Clinical readiness:** READY. Defaults are sensible (0.40 vs 0.60, 0.20/0.80, α 0.05, power 0.80). The direction of kappa0 vs kappa1 is explained. The difference from kappaSizeCI and kappaSizeFixedN is stated. The bold protocol figure carries the simulated N when the published N falls short.
- **i18n coverage:** PARTIAL. 71 `.()` msgids, all present in `tr.po`; 2 have an empty `msgstr`, and plural/qualifier words are spliced in.

**Top issues:**

1. **LOW** — Two `tr.po` entries for this analysis have an empty `msgstr`: `"kappa1 must be strictly between 0 and 1."` ([R/kappaSizePower.b.R:500](R/kappaSizePower.b.R#L500)) and `"Power must be between 0.01 and 0.99."` ([:506](R/kappaSizePower.b.R#L506)). Turkish users get English. These are reachable only through the R wrapper or a hand-edited `.omv`, because the `.a.yaml` min/max bound the GUI. Its sibling `"kappa0 must be strictly between 0 and 1."` is translated. → `/prepare-translation kappaSizePower`
2. **LOW** — Spliced fragments. `{n} {subjects}`, where `.subjects()` returns `.("subject")` or `.("subjects")` ([:236](R/kappaSizePower.b.R#L236), used at [:301](R/kappaSizePower.b.R#L301), [:451](R/kappaSizePower.b.R#L451)–[:458](R/kappaSizePower.b.R#L458), [:706](R/kappaSizePower.b.R#L706)). `{min}` filled with `.("below 0.0001")` or `.("unavailable")` ([:71](R/kappaSizePower.b.R#L71)–[:72](R/kappaSizePower.b.R#L72), into [:362](R/kappaSizePower.b.R#L362) and [:387](R/kappaSizePower.b.R#L387)). An English-only singular/plural switch does not fit languages with other plural rules. Turkish works today. → `/prepare-translation kappaSizePower`
3. **LOW** — `.run()` is 283 lines ([:473](R/kappaSizePower.b.R#L473)–[:755](R/kappaSizePower.b.R#L755)). Validation, the engine call, recomputing N, simulation and notice assembly are inline. Candidates to extract: `.validateInputs()` and `.estimateShortfall()`. → `/review-function kappaSizePower`

Non-findings noted:
- `text1` and `text_summary` show kappaSize's own English `print()` and `summary()` output. This is deliberate: one copy of the duplicate warning is kept, the panes are titled "by the published formula", and N is overwritten before printing. Tests assert the plain-digit N (`test-kappaSizePower-validation.R:257`).
- `<b>` tags inside msgids are kept in the Turkish `msgstr`.

#### Recommended remediation

- `/prepare-translation kappaSizePower`: fill the 2 empty `tr.po` msgstr. Optionally replace the `{subjects}` splice with full singular and plural sentences.
- `/review-function kappaSizePower`: optional `.run()` extraction (maintainability only).

---

### lassologistic

**Status:** ✅ READY (MEDIUM/LOW findings only; shipped, `menuGroup: meddecide`)
**Files:** [`R/lassologistic.b.R`](R/lassologistic.b.R) · [`jamovi/lassologistic.a.yaml`](jamovi/lassologistic.a.yaml) · [`jamovi/lassologistic.u.yaml`](jamovi/lassologistic.u.yaml) · [`jamovi/lassologistic.r.yaml`](jamovi/lassologistic.r.yaml) · helpers [`R/utils-syntax-exports.R`](R/utils-syntax-exports.R), [`R/utils.R`](R/utils.R) (`.rocOutcomeCoding`, `.rocLabel`, `.deleteTableRows`, `.quietly`, `.fmt`), [`R/utils-formula.R`](R/utils-formula.R) (`.stripBackticks`)
**Metrics:** .b.R LOC 3157 · options 30 · outputs 21 (3 Images, 1 Output) · UI controls 29 · JS LOC 0 · `.run()` 257 lines

#### Changes since 2026-10-20 audit

| Prior finding | Now | Evidence |
|---|---|---|
| F3 — LOW-G: `asSource()` emits `outcome = gold with space` (unparseable) | **FIXED** | [R/lassologistic.b.R:17](R/lassologistic.b.R#L17) overrides `.sourcifyOption` with `.sourcifyDiagnosticOption()` ([R/utils-syntax-exports.R:3](R/utils-syntax-exports.R#L3)): every character option is `deparse()`d (quotes, backslashes, backticks escaped), defaults omitted, `data`/`results/` skipped. Regression test [tests/testthat/test-lassologistic-audit-fixes.R:2](tests/testthat/test-lassologistic-audit-fixes.R#L2) parses the export for spaces, quotes, backslashes and backticks. Static read; the test was not run here. |

Prior report also listed "NEEDS_VALIDATION" (not a finding) — unchanged, see Code review.

#### Security

*No findings in profile standard.* Checked: every HTML sink escapes user strings — notices ([:73-76](R/lassologistic.b.R#L73)), level list ([:458](R/lassologistic.b.R#L458)), error panels ([:267](R/lassologistic.b.R#L267), [:309](R/lassologistic.b.R#L309)), summary ([:3082](R/lassologistic.b.R#L3082)); table cells/notes go through `.rocLabel()`. The free-text `scoreCutPoints` is parsed with literal `strsplit` (`fixed = TRUE` / character class) and matched with `%in%`, never as a regex or evaluator ([:1902-1917](R/lassologistic.b.R#L1902)). No formula is built from strings (`model.matrix(~., data = pred_cc)` on a selected frame). No `set.seed` (uses `withr::local_seed`, [:259](R/lassologistic.b.R#L259)). Category G fixed (above).

#### jmvcore migration

*No migration opportunities found.* `reject()` used for every configured-invalid input; `.sourcifyOption` now quotes correctly; no `as.formula(paste(...))`, no `na.omit` on attributed frames.

#### Integration

**Arguments declared:** 30 · **used in logic:** 29 (+`data`) · **dead:** 0. `scoreCutMethod`/`scoreCutPoints` read through the `.opt()` shim ([:1641](R/lassologistic.b.R#L1641)), still effective.

**Outputs declared:** 21 · **populated:** 21 · **unpopulated:** 0.

- `requiresData`: none declared; all three renderers ([:2877](R/lassologistic.b.R#L2877), [:2936](R/lassologistic.b.R#L2936), [:2987](R/lassologistic.b.R#L2987)) read only `image$state`, each NULL-guarded. The legacy-ROC path rebuilds from `state$y`, not `self$data`. Correct contract.
- State payloads are plain vectors (CV curve, sorted coefficients, ROC coordinates); validation cache in `validationTable$state` is a 10-field summary with a data hash key ([:2425-2435](R/lassologistic.b.R#L2425)). No heavy state.
- clearWith: every item is rebuilt or blanked at the top of each `.run()` ([:206-229](R/lassologistic.b.R#L206)), so missing clearWith entries cannot leave stale content. No gap found.
- Predictions Output: `setRowNums(rownames(self$data))` before `setValues` and `complete_idx` positional over the filtered frame ([:413-421](R/lassologistic.b.R#L413)): correct under a row filter.
- Every `tryCatch` in `.run()` that can reach `reject()` (`.cleanData` [:262](R/lassologistic.b.R#L262), `.fitLasso` [:303](R/lassologistic.b.R#L303)) re-raises with `stop(e)` after rendering, and lets the checkpoint `restart` through. Not swallowed.
- refs: all 15 keys resolve in `jamovi/00refs.yaml`. `format:` tokens (`zto`, `pc`) valid.
- Fixed-row tables `performance`, `scoringPerformance`, `validationTable`, `methodComparison` are laid down in `.init()` ([:136-149](R/lassologistic.b.R#L136)).

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Nothing selected | quiet welcome (`todo`) | ✅ | n/a | [:162](R/lassologistic.b.R#L162) |
| Event level not chosen | INFO panel, levels + counts | ✅ | ✅ | [:253-256](R/lassologistic.b.R#L253) |
| Exactly one predictor | WARNING | ⚠️ | n/a | partial selection, should be INFO (finding 2) |
| Invalid config (>2 levels, <5 per class, <10 complete, outcome as predictor, repeated/missing IDs, absent level) | `reject()` | ✅ | ✅ | counts and the exclusion cause in the message ([:560-621](R/lassologistic.b.R#L560)) |
| Low EPV / small n / imbalance / collinearity | STRONG_WARNING / WARNING, always on | ✅ | ✅ | fires even with the panel unticked ([:856-876](R/lassologistic.b.R#L856)) |
| Folds reduced, glmnet small-fold warnings | WARNING / INFO | ✅ | ✅ | glmnet warnings muffled and restated ([:918-929](R/lassologistic.b.R#L918)) |
| No terms selected / constant score / perfect separation / AUC < 0.7 | STRONG_WARNING | ✅ | ✅ | |
| Failed optional step (bootstrap replicates, unpenalized refit) | table note | ✅ | ✅ | `n_ok of B` ([:2471](R/lassologistic.b.R#L2471)); refit failure named ([:2752](R/lassologistic.b.R#L2752)) |
| Methodology summary | INFO | ✅ | ✅ | [:441](R/lassologistic.b.R#L441) |

#### Code review

- **Overall quality:** 4 stars
- **Architecture:** OK. Single selection rule (`.probsFrom`) shared by the fit, the bootstrap and the path counts; one cut resolver shared by criterion, contribution and scoring. `.run()` is long (finding 4).
- **Mathematical/statistical correctness:** CORRECT on the formulas checked statically (no execution):
  - The Harrell optimism is `apparent − mean(boot_on_boot − boot_on_orig)` for AUC, Brier and slope, with lambda CV repeated in each resample and duplicate rows kept in one fold (Harrell 1996; Steyerberg 2019).
  - The calibration slope is the `glm(y ~ logit p)` coefficient, set to NA under separation.
  - The F1 score is `2TP/(2TP+FP+FN)`. The Brier skill score is measured against `p(1−p)`.
  - EPV is the minority class divided by the number of design-matrix terms (Peduzzi 1996).
  - The AUC uses pROC with fixed `direction = "<"`, so it is not auto-flipped, and a DeLong CI that is caveated as apparent.
  - The coefficients come from `coef(cv.glmnet$glmnet.fit, s = λ)`, which glmnet returns on the original scale. Importance is per sample SD.
  - Beta10 is `×10` and rounded (Mehta 2016). Max-scaled is `β/max|β|·M`. Points are derived from `β × contrast` of the applied criterion.
  - Predictions use the same thresholded β as the tables.
- **Clinical readiness:** NEEDS_VALIDATION. The analysis has no executed oracle comparison this audit. Apparent and optimism-corrected metrics are clearly labelled. The score is flagged in several places as needing external validation.
- **i18n coverage:** COMPLETE (wrapped surface; one splice, finding 5).

**Top issues:**

1. **MEDIUM** — Computed statistics drawn as a raw HTML `<table>`. `suitabilityReport` builds rows of computed EPV, N, minority %, n/p and max |r| into `<table class='table table-condensed'>` ([R/lassologistic.b.R:835-850](R/lassologistic.b.R#L835)). This loses jamovi table theming, Copy/Copy LaTeX and export, and these are not empty-state help (guide §26). Move it to a `type: Table` with rows `check`/`status`/`result`, labels in `.init()`, and the Peduzzi/Riley sentence as a `setNote()`. Fix: `/fix-function lassologistic`.
2. **LOW** — Partial selection raises a WARNING. With an outcome and exactly one predictor, `.run()` renders a yellow "Warning" notice ([R/lassologistic.b.R:238-247](R/lassologistic.b.R#L238)). An incomplete selection is an unconfigured state (guide §25) and should be INFO naming what is missing. Fix: `/fix-notices lassologistic`.
3. **LOW** — Fixed-label rows are built in `.run()`. `modelSummary` (`rows: 0`) gets 12 rows with option-independent labels by `addRow()` on every run ([R/lassologistic.b.R:1095-1158](R/lassologistic.b.R#L1095)). Only the two exclusion-breakdown rows depend on data. The 2026-09-16 round moved the four sibling tables to `.init()` and left this one. Fix: `/fix-function lassologistic`.
4. **LOW** — `.run()` is 257 lines ([R/lassologistic.b.R:195-451](R/lassologistic.b.R#L195)). The notice-building blocks for exclusions and dropped predictors ([:337-388](R/lassologistic.b.R#L337)) could move into a helper. Fix: `/review-function lassologistic`.
5. **LOW** — i18n splice in the exclusion notice. Untranslated punctuation (`" ("`, `"; "`, `")"`) and a leading-space clause are glued into `%4$s`/`%6$s` of one msgid ([R/lassologistic.b.R:350-363](R/lassologistic.b.R#L350)). Turkish word order and punctuation cannot be adapted. Use whole-sentence variants per cause. Fix: `/prepare-translation lassologistic`.

Observations (not counted): the comment at [:2891](R/lassologistic.b.R#L2891) still says "Okabe-Ito hues", but the code uses `jmvcore::colorPalette(theme$palette)` (correct behaviour, stale comment). `predictions` values are computed even when the Output is not enabled ([:413](R/lassologistic.b.R#L413), `!is.null(self$results$predictions)` is always TRUE). This is harmless, with a small cost.

#### Recommended remediation

- `/fix-function lassologistic`: suitability panel → Table; `modelSummary` rows → `.init()`
- `/fix-notices lassologistic`: one-predictor state → INFO
- `/prepare-translation lassologistic`: exclusion-notice splice
- `/check-function-full lassologistic`: executed oracle run (glmnet `cv.glmnet` + manual Harrell bootstrap, pROC) to move clinical readiness past NEEDS_VALIDATION

---

### nogoldstandard

**Status:** ✅ READY (LOW-only findings; clinical use still NEEDS_VALIDATION)
**Files:** [`R/nogoldstandard.b.R`](R/nogoldstandard.b.R) · [`R/nogoldstandard-mixture.R`](R/nogoldstandard-mixture.R) · [`jamovi/nogoldstandard.a.yaml`](jamovi/nogoldstandard.a.yaml) · [`jamovi/nogoldstandard.u.yaml`](jamovi/nogoldstandard.u.yaml) · [`jamovi/nogoldstandard.r.yaml`](jamovi/nogoldstandard.r.yaml)
**Metrics:** .b.R LOC 2450 (1798 non-blank/non-comment) + 200 helper LOC · options 20 · outputs 12 · UI controls 19 · JS LOC 0 · `.run()` 334 lines

#### Changes since 2026-10-20 audit

| Prior finding | Now | Evidence |
|---|---|---|
| F7 — Title Case control label "Analysis Method" | **FIXED** | [jamovi/nogoldstandard.a.yaml:143](jamovi/nogoldstandard.a.yaml#L143) `title: Analysis method`; u.yaml label matches |

Prior audit raised no other finding on this analysis. 1/1 fixed.

#### Security

*No findings in profile standard.*

- C: LCA formula is `jmvcore::composeTerms()` + `jmvcore::asFormula()` ([R/nogoldstandard.b.R:1256](R/nogoldstandard.b.R#L1256)).
- D: the only user strings in Html go through `jmvcore::htmlEscape` ([R/nogoldstandard.b.R:2332](R/nogoldstandard.b.R#L2332)). Table cells use `.diagCellText()`. Notices are plain text in a Preformatted item.
- G: `.sourcifyOption` quotes the test/level values with `encodeString(quote = '"')` ([R/nogoldstandard.b.R:57](R/nogoldstandard.b.R#L57)).
- A/B/E/F/H: none.

#### jmvcore migration

*No migration opportunities found.* (The code already uses `naOmit`, `composeTerms`/`asFormula` and `reject`.)

#### Integration

**Arguments declared:** 20 · **used in logic:** 20 · **dead:** 0
(`clinicalPreset` is informational by design: it adds a notice that compares the example settings with the current ones. It cannot write options.)

**Outputs declared:** 12 · **populated:** 12 · **unpopulated:** 0

- `requiresData`: `agreement_plot` declares none, and `.plot_ggplot` reads only `image$state`. The state is guarded ([R/nogoldstandard.b.R:1903](R/nogoldstandard.b.R#L1903)) and small (k×k matrix + names). OK.
- clearWith: every result whose content depends on test/level/method/bootstrap/nboot/alpha/seed lists those options. `conditional_dependence` and `method_guide` omit only options their content does not read. No gap.
- tryCatch vs reject: the main-run fitters are not wrapped. The tryCatch around the bootstrap replicates ([R/nogoldstandard.b.R:1756](R/nogoldstandard.b.R#L1756)) swallows a replicate's `reject()` on purpose (it counts as a failed replicate) and re-raises `restart`. The per-start tryCatch wraps only `poLCA::poLCA`. OK.
- Seeds are scoped with `withr::with_seed` / `local_seed`. There is no bare `set.seed`, and no `insert(N)` is used.
- Refs: `ClinicoPathJamoviModule`, `poLCA`, `LinzerLewis2011`, `AllmanLatent2018`, `irr` are all defined with author/year/url in `jamovi/00refs.yaml`.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Empty state | Html instructions | ✅ | n/a | Welcome panel, no red error |
| Partial (variable without positive level) | INFO | ✅ | ✅ | Names the pending slots ([R/nogoldstandard.b.R:465](R/nogoldstandard.b.R#L465)) |
| Invalid configuration (<2 tests, duplicates, LCA/EM <3 tests, constant test, missing level) | `reject()` | ✅ | ✅ | [R/nogoldstandard.b.R:477-613](R/nogoldstandard.b.R#L477) |
| Missing-data exclusion | WARNING / INFO | ✅ | ✅ | n analysed / n supplied, % |
| Low n (LCA <100, EM <50), sparse split <5, imbalance <5% | STRONG_WARNING / WARNING | ✅ | ✅ | Wording explicitly not a clinical threshold |
| Non-convergence, unstable starts, identification, boundary, orientation tie/conflict | STRONG_WARNING | ✅ | ✅ | Estimates are blanked, not shown |
| Conditional dependence (BVR > 3.84) | STRONG_WARNING | ✅ | ✅ | latent_class only |
| Incorporation bias / degenerate rule metrics | STRONG_WARNING / WARNING | ✅ | n/a | Degenerate cells left blank |
| Bootstrap failures / <20 finite / zero-width CI | WARNING / STRONG_WARNING | ✅ | ✅ | |
| Plot render failure | — | ❌ | — | Finding 4 |

#### Code review

- **Overall quality:** 4 stars
- **Architecture:** OK. Helpers are well split. `.run()` is 334 lines, so long but readable.
- **Mathematical/statistical correctness:** CORRECT (static check, not executed). Checked against these sources:
  - Wilson score interval ([R/nogoldstandard.b.R:776](R/nogoldstandard.b.R#L776)) matches Newcombe 1998 method 3.
  - Cohen κ = (pₒ − pₑ)/(1 − pₑ). The p-value comes from the null-variance z of `irr::kappa2`, two-sided.
  - PPV/NPV use Bayes' rule. The rule methods use the empirical PPV/NPV.
  - Mixture likelihood, Jacobian and gradient are correct ([R/nogoldstandard-mixture.R:17-66](R/nogoldstandard-mixture.R#L17)). The pattern index matches the `expand.grid` order.
  - Penalized-EM M-step is (x+1)/(n₁+1) for P(+|class 1) and x/(n₀+1) for P(+|class 0). These are the Beta(2,1) modes on sensitivity and specificity, consistent with the penalty `log q1 + log(1−q0)`.
  - AIC/BIC use 2k+1 parameters. G² and Pearson X² include zero cells.
  - The bivariate residual is Pearson X² on the pair margin against the model-implied 2×2 table (Vermunt–Magidson BVR, df 1).
  - Sensitivity/specificity are extracted as `probs[[i]][class, outcome]`.
  - Rule-method degeneracies (all_positive: sensitivity/NPV ≡ 1; any_positive: specificity/PPV ≡ 1; 2-test composite = all_positive) are blanked, not displayed.
  - No fabricated statistic: latent intervals stay blank unless bootstrap is on.
- **Clinical readiness:** NEEDS_VALIDATION. Latent-class estimates depend on conditional independence and on the class-orientation assumption, and both are disclosed. Bootstrap coverage has not been checked in this audit.
- **i18n coverage:** PARTIAL

**Top issues:**

1. **LOW** — The Analysis Diagnostics panel is English in every locale. The `.diag()` literals are not wrapped: [R/nogoldstandard.b.R:574-580](R/nogoldstandard.b.R#L574), [1343](R/nogoldstandard.b.R#L1343), [1370](R/nogoldstandard.b.R#L1370), [1380](R/nogoldstandard.b.R#L1380), [1626](R/nogoldstandard.b.R#L1626), [1850](R/nogoldstandard.b.R#L1850), [1854](R/nogoldstandard.b.R#L1854). `/prepare-translation nogoldstandard`
2. **LOW** — i18n fragments: the label colon sits outside `.()` (`.("Scenario"), ":</strong> "`), so a translator cannot place it, for example before a French non-breaking space. Sites: [R/nogoldstandard.b.R:334-337](R/nogoldstandard.b.R#L334) and [2130-2156](R/nogoldstandard.b.R#L2130) ("Description", "Illustrative context", "Limitations"). `/prepare-translation nogoldstandard`
3. **LOW** — Stale rationale comments say the Preformatted notice panel works around "the jmvcore::Notice serialization error" and that "dynamic Notice objects are not serializable": [R/nogoldstandard.b.R:16-19](R/nogoldstandard.b.R#L16), [146-147](R/nogoldstandard.b.R#L146). This contradicts the 2026-09-22 correction (the cause is `Group$insert()` bounds). The design itself is fine; only the comments mislead. `/fix-function nogoldstandard`
4. **LOW** — If ggplot fails, the renderer reports it only through `message()` (invisible in jamovi) and silently draws a base-R heatmap: [R/nogoldstandard.b.R:1985](R/nogoldstandard.b.R#L1985). The user sees a different plot with no explanation. `/fix-notices nogoldstandard`
5. **LOW** — `crosstab` rows are created in `.run()` by `addRow()` ([R/nogoldstandard.b.R:279](R/nogoldstandard.b.R#L279)), although the row set (2^k patterns) is fixed by the options. Only the descending-count sort depends on the data. Either build the rows in `.init()` in pattern order, or accept this as a deliberate sort. `/fix-function nogoldstandard`
6. **LOW** — The `.u.yaml` ComboBox repeats the method `options:` list ([jamovi/nogoldstandard.u.yaml:72](jamovi/nogoldstandard.u.yaml#L72)). It is the only ComboBox in the module that does so. Its order already differs from `.a.yaml`, and its titles can drift. Drop the list and let `.a.yaml` own it. `/fix-function nogoldstandard`
7. **LOW** (enhancement) — Penalized EM relies on the same conditional-independence model, but `model_fit` and `conditional_dependence` are `visible: (method=="latent_class")` ([jamovi/nogoldstandard.r.yaml](jamovi/nogoldstandard.r.yaml)). So the "bayesian" method shows no dependence check. `/review-function nogoldstandard`

#### Recommended remediation

- `/prepare-translation nogoldstandard`: wrap the diagnostics lines and fold the label colons into `.()` (findings 1–2)
- `/fix-notices nogoldstandard`: surface a ggplot render failure (finding 4)
- `/fix-function nogoldstandard`: stale comments, crosstab rows in `.init()`, redundant u.yaml options (findings 3, 5, 6)
- `/check-function-full nogoldstandard`: executed oracle and bootstrap-coverage check for clinical sign-off. The poLCA residual-label probe is listed in PROBES.

---

### psychopdaROC

**Status:** ✅ READY (MEDIUM/LOW findings only; statistical validation still pending)
**Files:** [`R/psychopdaROC.b.R`](R/psychopdaROC.b.R) · [`jamovi/psychopdaROC.a.yaml`](jamovi/psychopdaROC.a.yaml) · [`jamovi/psychopdaROC.u.yaml`](jamovi/psychopdaROC.u.yaml) · [`jamovi/psychopdaROC.r.yaml`](jamovi/psychopdaROC.r.yaml) · helpers [`R/psychopdaROC-inputs.R`](R/psychopdaROC-inputs.R), [`R/psychopdaROC-nri-idi.R`](R/psychopdaROC-nri-idi.R), `.rocLabel`/`.deleteTableRows` in [`R/utils.R`](R/utils.R#L204)
**Metrics:** .b.R LOC 6840 (+133 inputs, +564 NRI/IDI) · options 83 (incl. `data`) · outputs 38 · UI controls 77 · JS none · `.run()` 1797 lines

#### Changes since 2026-10-20 audit

What changed: `jamovi/psychopdaROC.a.yaml` (the 80-line diff since `a41344a`) is **40 `title:` edits to sentence case, plus the version bump**. No option was added, removed, renamed or retyped, so no new wiring is needed. All 83 options have the same types and are still read in `.b.R`. The `.b.R` change (`403e034`) adds `.effectiveMethod()` ([R/psychopdaROC.b.R:380](R/psychopdaROC.b.R#L380)), which makes the maximize/minimize direction follow the metric. It is used at [R/psychopdaROC.b.R:1570](R/psychopdaROC.b.R#L1570) (tie note) and [R/psychopdaROC.b.R:2656](R/psychopdaROC.b.R#L2656) (cutpointr method).

| Prior finding | Now | Evidence |
|---|---|---|
| F7 — Title-Case control label "Classification Direction" (a.yaml:278) | **FIXED** | Now `title: Classification direction` ([jamovi/psychopdaROC.a.yaml:278](jamovi/psychopdaROC.a.yaml#L278)); the u.yaml label at :81 matches. One stray u.yaml label remains (Code review #7). |
| F9 — `.run()` source span 1789 lines (2318–4106) | **STILL PRESENT** | [R/psychopdaROC.b.R:2332](R/psychopdaROC.b.R#L2332)–4128, 1797 lines. |
| F3 control (custom `asSource()` passes the name/quote probe) | unchanged, still passes | [R/psychopdaROC.b.R:6809](R/psychopdaROC.b.R#L6809). Uses `deparse()` per value, so names with spaces or quotes serialize safely. |

#### Security

*No findings in profile standard.*

- Every HTML sink escapes user strings: `jmvcore::htmlEscape` on class levels and variable names in Procedure Notes and Analysis Status ([R/psychopdaROC.b.R:2477](R/psychopdaROC.b.R#L2477), [:2627](R/psychopdaROC.b.R#L2627)), on warnings ([:430](R/psychopdaROC.b.R#L430)) and on the confusion-matrix title and labels ([:5183](R/psychopdaROC.b.R#L5183)). Notes go through `.rocLabel()`.
- There is no `eval`/`parse`, no formula built from user input (the only `glm` formula is a literal), no file I/O and no bare `set.seed` (all seeding uses `withr::local_seed`).
- Display only, not a security issue: raw column names in table cells (`variable = var`) render blank if a name starts with `<letter`. The client sanitizer prevents XSS.

#### jmvcore migration

*No migration opportunities found.* `jmvcore::toNumeric` is used correctly, to unwrap values-attributed integer columns ([R/psychopdaROC-inputs.R:87](R/psychopdaROC-inputs.R#L87)). Errors go through `jmvcore::reject`, and no `as.formula` or `na.omit` is used.

#### Integration

**Arguments declared:** 83 · **used in logic:** 77 · **dead:** 0. Six options are intentionally kept but have no effect: `correlationROCs`, `metaAnalysisMethod`, `heterogeneityTest`, `forestPlot`, `overrideMetaAnalysisWarning` (labelled "legacy/inactive" in a.yaml), plus `metaAnalysis`, which only shows an explanation.

**Outputs declared:** 38 · **populated:** 36 · **unpopulated:** 2

| Output | Type | Setter | Populated? | Notes |
|---|---|---|:---:|---|
| `metaAnalysisTable` | Table | rows scaffolded in `.init()` ([:2034](R/psychopdaROC.b.R#L2034)), always `setVisible(FALSE)` ([:6784](R/psychopdaROC.b.R#L6784)) | ❌ | Legacy. Rebuilt on every `.init()` and never shown. |
| `metaAnalysisForestPlot` | Image Array | `.generateMetaAnalysisForestPlot()` ([:6687](R/psychopdaROC.b.R#L6687)) **is never called** | ❌ | The renderer `.plotMetaAnalysisForest` is dead code. |

- **Renderer contract:** no item declares `requiresData`, and none needs it. I traced all 13 renderers: they read only `image$state` and options, and their helpers (`.wilsonCI`, `.thresholdIndex`, `.aucLimits`, `.hanleyMcNeilPower`) are pure.
- **State guards:** every `image$state` read is guarded. `.plotROC` treats NULL as a 0-row frame and returns.
- **State size:** no fitted models are stored in state. The rawData attribute is stripped before `setState` ([:3054](R/psychopdaROC.b.R#L3054)).
- **clearWith:** complete for every Image against the options its renderer and state builder read. Tables are rebuilt on every `.run()` (`.clearTables()` at [:2398](R/psychopdaROC.b.R#L2398)), and the manual-run gate deliberately keeps prior results with a "previous run" banner.
- **tryCatch vs `reject()`:** all `tryCatch`s in `.run()` were traced. The DeLong wrapper re-raises `delong_validation` and `restart` ([:3230](R/psychopdaROC.b.R#L3230)). Patient data uses `stop()` codes and then `reject()` outside the handler ([:2582](R/psychopdaROC.b.R#L2582)). The `.prepareVarData` call inside `.degen_const` ([:3350](R/psychopdaROC.b.R#L3350)) can only fail after the loop has already validated the same data.
- **Citations:** all 18 ref keys used in r.yaml are defined in `00refs.yaml`. Column `format:` tokens are valid (`zto`, `pc`, `zto,pvalue`).

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | quiet welcome Html | ✅ | n/a | No red ERROR on an empty analysis ([:2437](R/psychopdaROC.b.R#L2437)). |
| Partial selection (classes unset) | INFO + coding-table note | ✅ | ✅ | [:2412](R/psychopdaROC.b.R#L2412) |
| Configured-invalid (same/absent class, bad ID, cut score, ranges) | `reject()` + ERROR notice | ✅ | ✅ | `.throwError` / `.validateInputs` |
| Low n per class (<10) | STRONG_WARNING | ✅ | ✅ | [:1297](R/psychopdaROC.b.R#L1297); DeLong note [:3289](R/psychopdaROC.b.R#L3289) |
| Prevalence <10% / >90% | STRONG_WARNING | ✅ | ✅ | [:2606](R/psychopdaROC.b.R#L2606) |
| AUC < 0.5 | WARNING + table note | ✅ | ✅ | [:3487](R/psychopdaROC.b.R#L3487) |
| Perfect separation / constant marker | table note | ✅ | ✅ | `.noteDegenerateEstimates` |
| Failed optional step | WARNING (status box + notice) | ✅ | ✅ | Bootstrap, PR, Bayesian, utility and LOESS failures are named. |
| Methodology summary | INFO (scope, analysis unit) | ✅ | ✅ | [:2539](R/psychopdaROC.b.R#L2539), [:2590](R/psychopdaROC.b.R#L2590) |

#### Code review

- **Overall quality:** 4 stars
- **Architecture:** a monolithic `.run()` (1797 lines) and a 6840-line class. The flow is well commented, and per-run state is reset explicitly.
- **Mathematical/statistical correctness:** MINOR_ISSUES. Checked by reading the code against the cited sources:
  - Logit-DeLong interval `se/(a(1-a))` and its test ([R/psychopdaROC-inputs.R:66](R/psychopdaROC-inputs.R#L66)): correct delta method.
  - Hanley–McNeil 1982 variance, Q1 = A/(2−A), Q2 = 2A²/(1+A): correct.
  - Expected-cost cutpoint, maximizing `Se·p − r·(1−Sp)(1−p)` (Metz 1978): correct.
  - Vickers–Elkin 2006 net benefit `TP/n − FP/n·t/(1−t)` and interventions avoided per 100: correct.
  - Wilson interval: correct.
  - `.effectiveMethod` minimize set (`abs_d_*`, `misclassification_cost`, `roc01`): matches cutpointr's metric documentation.
  - Power uses only the alternative-hypothesis Hanley–McNeil variance (Wald form, not Obuchowski's V0/V1). It is disclosed as approximate.
- **Clinical readiness:** NEEDS_VALIDATION. No fresh oracle run in this pass.
- **i18n coverage:** PARTIAL

**Top issues:**

1. **MEDIUM** — The confusion matrices are raw HTML `<table>` markup in an Html Array. This ignores the results theme, breaks copy/export, and hardcodes `border-color:black` and Arial. The title is untranslated English: `paste("Confusion Matrix for", var, "at Selected Cutpoint =", …)`. Location: [R/psychopdaROC.b.R:5177](R/psychopdaROC.b.R#L5177), populated at [:1612](R/psychopdaROC.b.R#L1612) and [:1617](R/psychopdaROC.b.R#L1617). Fix: a `type: Table` Array (guide §26). `/fix-function psychopdaROC`
2. **LOW** — Leftovers around the new `.effectiveMethod()` override:
   - Procedure Notes still print the *requested* method key ([:2500](R/psychopdaROC.b.R#L2500)).
   - The `method` description ([jamovi/psychopdaROC.a.yaml:228](jamovi/psychopdaROC.a.yaml#L228)) does not say that the direction now follows the metric, so the "Minimize …" choices are silently redirected.
   - The INFO notice shows the raw metric key and splices translated words into one sentence ([:2658](R/psychopdaROC.b.R#L2658)–2662, i18n-fragment). It is also queued through `.warnUser`, so it is listed under "Warnings:" in Analysis Status.
   - The `.noteMetricTolerance` note always says "maximises" ([:2109](R/psychopdaROC.b.R#L2109)).

   `/fix-function psychopdaROC`, `/prepare-translation psychopdaROC`
3. **LOW** — The "Misclassification cost" and "Total utility" metrics ([jamovi/psychopdaROC.a.yaml:261](jamovi/psychopdaROC.a.yaml#L261)) use cutpointr's default unit costs: `cost_fp`/`cost_fn`/`utility_*` are never passed ([:2750](R/psychopdaROC.b.R#L2750)), and `costratioFP` is used only by `oc_cost_ratio`. Both should then select the same cut-point as "Overall accuracy" (PLAUSIBLE). Either say "(equal costs)" in the metric titles or pass `costratioFP`. `/review-function psychopdaROC`
4. **LOW** — Two AUC wordings disagree within one table row. `.getDetailedInterpretation` calls everything below 0.7 "poor" ([:593](R/psychopdaROC.b.R#L593)–601), while `.interpretAUC` beside it uses six bands ([:561](R/psychopdaROC.b.R#L561)). An AUC of 0.31 is therefore "Below chance" in one cell and "indicating poor discrimination" in the next. The Basic guidance text ([:513](R/psychopdaROC.b.R#L513)) uses the 4-band wording too. `/fix-function psychopdaROC`
5. **LOW** — Untranslated user-facing strings (i18n-unwrapped):
   - Image titles at [:3038](R/psychopdaROC.b.R#L3038), [:3048](R/psychopdaROC.b.R#L3048), [:3060](R/psychopdaROC.b.R#L3060), [:3080](R/psychopdaROC.b.R#L3080), [:3146](R/psychopdaROC.b.R#L3146), [:3153](R/psychopdaROC.b.R#L3153), [:3777](R/psychopdaROC.b.R#L3777) and [:3794](R/psychopdaROC.b.R#L3794).
   - The `"<b>Error:</b>"` prefix ([:2443](R/psychopdaROC.b.R#L2443)).
   - The "Fixed …" cell ([:994](R/psychopdaROC.b.R#L994)).
   - The `delong_validation` reject texts ([:5263](R/psychopdaROC.b.R#L5263)–5281).
   - HTML inside the msgid at [:3136](R/psychopdaROC.b.R#L3136).

   `/prepare-translation psychopdaROC`
6. **LOW** — Declared but never populated: `metaAnalysisTable` and `metaAnalysisForestPlot` (see Integration), plus about 100 lines of dead code: `.generateMetaAnalysisForestPlot`, `.plotMetaAnalysisForest`, and the `.init()` row scaffold. They are kept on purpose for saved-analysis compatibility. Remove them when that window closes. `/fix-function psychopdaROC`
7. **LOW** — UI labels:
   - [jamovi/psychopdaROC.u.yaml:109](jamovi/psychopdaROC.u.yaml#L109) "Cost Ratio (False Positive : False Negative)" is Title Case.
   - [:508](jamovi/psychopdaROC.u.yaml#L508) "Explain why …" starts with an action verb.
   - Notes and errors still name controls by their old Title-Case titles ("Positive Class", "Classification Direction", "Tie Breaking Method", "Manual Cut Score").
   - `.throwError("invalid_class", …)` ([:2422](R/psychopdaROC.b.R#L2422), [:2429](R/psychopdaROC.b.R#L2429)) has no entry in the message table, so its error starts with the generic "An error occurred:".

   `/fix-function psychopdaROC`
8. **LOW** — F9: `.run()` is 1797 lines ([:2332](R/psychopdaROC.b.R#L2332)–4128). This is a maintenance risk, not a blocker. `/review-function psychopdaROC`

#### Recommended remediation

- `/fix-function psychopdaROC`: confusion matrices as a Table Array; the `.effectiveMethod` leftovers; aligned AUC bands; the meta-analysis dead schema; labels.
- `/prepare-translation psychopdaROC`: image titles, the confusion-matrix title, `<b>Error:</b>`, the spliced direction notice, and the `delong_validation` messages.
- `/review-function psychopdaROC`: cost and utility metric semantics vs `costratioFP`; Obuchowski V0/V1 power; `.run()` decomposition.
- `/check-function-full psychopdaROC`: a fresh oracle run (pROC and cutpointr parity per method/metric, including the new direction override). Statistical correctness has not been revalidated end to end.

---

### sequentialtests

**Status:** ✅ READY (LOW-only findings)
**Files:** [`R/sequentialtests.b.R`](R/sequentialtests.b.R) · [`jamovi/sequentialtests.a.yaml`](jamovi/sequentialtests.a.yaml) · [`jamovi/sequentialtests.u.yaml`](jamovi/sequentialtests.u.yaml) · [`jamovi/sequentialtests.r.yaml`](jamovi/sequentialtests.r.yaml) · [`jamovi/js/sequentialtests.events.js`](jamovi/js/sequentialtests.events.js)
**Metrics:** .b.R LOC 1946 (1759 non-blank) · options 16 · outputs 14 (5 Images) · UI controls 16 · JS LOC 132 · `.run()` 58–1098 (1041 lines)

#### Changes since 2026-10-20 audit

| Prior finding | Status | Current evidence |
|---|---|---|
| F9: long `.run()` body (58–1098, 1041 lines) | **STILL PRESENT** | [R/sequentialtests.b.R:58](R/sequentialtests.b.R#L58)–[1098](R/sequentialtests.b.R#L1098), unchanged span |

The prior audit raised no other finding for this analysis. Its "no blocking issue" verdict holds after a full re-read of the current code.

#### Security

*No findings in profile standard.* I traced every sink that receives the user's free-text `test1_name`/`test2_name` (`String`, HIGH-tier source):
- Table cells go through `.diagCellText()` ([R/utils-diagnostic-comparator.R:3](R/utils-diagnostic-comparator.R#L3)) at [:28](R/sequentialtests.b.R#L28), [:276](R/sequentialtests.b.R#L276), [:348](R/sequentialtests.b.R#L348) and [:555](R/sequentialtests.b.R#L555).
- Html output goes through `.safeHtmlOutput()` ([:1930](R/sequentialtests.b.R#L1930)) at [:323](R/sequentialtests.b.R#L323) and [:650](R/sequentialtests.b.R#L650).
- Notices are a plain-text `Preformatted` item, and plot labels are plain text.
- The syntax export (G) uses its own `.sourcifyOption` ([:14](R/sequentialtests.b.R#L14)), which quotes with `encodeString(value, quote = '"')`.
- The name-similarity check passes `fixed = TRUE` to `agrepl` ([:159](R/sequentialtests.b.R#L159)), so a name containing regex metacharacters cannot abort `.run()`.
- No eval/parse, formula, file, `system`, `set.seed` or debug-flag pattern is present.

#### jmvcore migration

- **[error]** [R/sequentialtests.b.R:128](R/sequentialtests.b.R#L128), and likewise at :131, :135, :141, :148, :172, :177–186, :316, :327, :405, :1468 and :1482: user-facing messages are built with `sprintf(.("…%s…"), …)` and should use `.fmt(.("…{name}…"), …)`. The rest of the file already uses `.fmt`, through `.formatTranslated`. If a translator drops or adds a `%` conversion, `sprintf` errors and aborts `.run()`. An unmatched `{name}` in `jmvcore::format` degrades to `…` instead. LOW. `/jamovify-function sequentialtests --apply`.

#### Integration

**Arguments declared:** 16  ·  **used in logic:** 16  ·  **dead:** 0
- All four `show_*` options gate their outputs, both through `visible:` and through `if` in `.run()`.
- `preset` overrides the values in `.run()` ([:80–111](R/sequentialtests.b.R#L80)) as well as in the JS. The JS table and the R table hold identical values; I compared all 7 presets field by field.
- `population_size` is cast with `as.integer` ([:395](R/sequentialtests.b.R#L395)), which avoids the known `1e+05` formatting pitfall.

**Outputs declared:** 14  ·  **populated:** 14  ·  **unpopulated:** 0
- **clearWith:** every item lists each option its content depends on. The cost table also lists `test1_cost`/`test2_cost` and the names. The flow table omits the names, correctly, because it shows none.
- **Fixed rows:** fixed-structure rows are built in `.init()` ([:22–56](R/sequentialtests.b.R#L22)), not `.run()`.
- **Images:** all 5 renderers read only `image$state`, each with an `is.null` guard (:1106, :1334, :1405, :1565, :1680). None reads `self$data` or `self$options`, and no `requiresData` is set, which is correct. The state is a 21-field list of scalars with no model or data frame, so it is not heavy.
- No phantom private methods, no `insert(N)`, no `tryCatch`, no `reject()` to swallow and no `setVisible`. `.fmt` is defined at [R/utils.R:100](R/utils.R#L100).

**Citation refs** (`refs:` in [jamovi/sequentialtests.r.yaml](jamovi/sequentialtests.r.yaml)):
- `ConditionalDependenceDiagnosticTests` (Gardner 2000) and `CDC_HIV_Testing_2023` resolve with complete metadata.
- ~~**LOW**: `ClinicoPathJamoviModule` citation has no title / Cohen-1988 DOI.~~ **Orchestrator verification (executed probe, 2026-10-21):** **false positive** — meddecide `jamovi/00refs.yaml` has title "ClinicoPath jamovi Module" and doi `10.17605/OSF.IO/9SZUD`, identical to the umbrella. No action.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing/invalid inputs | native | ✅ | ✅ | No variables. The `.a.yaml` min/max bounds are enforced by jmvcore, which puts the analysis into the jamovi error state. The empty state runs on defaults and shows no red ERROR. |
| Low n | WARNING | ✅ | ✅ | "Illustrative Population Too Small" fires when expected diseased < 10 ([:402](R/sequentialtests.b.R#L402)). |
| Extreme prevalence | STRONG_WARNING | ✅ | ✅ | Fires at ≤1%, <5% and ≥90% ([:134–149](R/sequentialtests.b.R#L134)). |
| Assumption (conditional independence) | INFO + table note | ✅ | n/a | Gives the direction for each strategy ([:293](R/sequentialtests.b.R#L293)). A WARNING about name similarity fires for likely-dependent pairs. |
| Implausible performance | STRONG_WARNING / WARNING | ✅ | ✅ | Fires for Se/Sp < 50% and for values ≥ 99%. |
| Teaching example in use | STRONG_WARNING | ✅ | n/a | Says plainly that the values are not clinical guidance. |
| Methodology summary | INFO | ✅ | ✅ | "Analysis Complete" with the combined Se/Sp. |

The notices render as plain text in one `Preformatted` item, which follows the project convention.

#### Code review

- **Overall quality:** 4/5
- **Architecture:** a monolithic `.run()` (F9). Helpers are well factored: a single Bayes formula in `.ppvOf`/`.npvOf`, plus formatters that handle the edges near 0% and 100%.
- **Mathematical/statistical correctness:** CORRECT. I checked each formula algebraically against the closed-form results under conditional independence:
  - Serial-positive: Se = Se1·Se2 and Sp = 1−(1−Sp1)(1−Sp2) ([:233](R/sequentialtests.b.R#L233)).
  - Serial-negative and parallel: Se = 1−(1−Se1)(1−Se2) and Sp = Sp1·Sp2.
  - PPV/NPV by Bayes, LR± = Se/(1−Sp) and (1−Se)/Sp.
  - Flow-table final counts (serial-positive FN = T1 FN + T2 FN; serial-negative mirrored).
  - Probability-plot endpoints: post-odds(T1+)·LR2+ equals the combined PPV, and post-odds(T1−)·LR2− equals 1−NPV.
  - NNS = ⌈1/(P·Se_c)⌉, with a note that defines it as "pathway entries per TP" and not the screening-benefit statistic.

  Every denominator stays above 0 under the yaml bounds. The direction of the dependence bias is stated correctly for each strategy (Gardner 2000). Not executed numerically in this audit.
- **Clinical readiness:** READY as a teaching and planning calculator. Inputs are labelled as exact point estimates with no CI, the presets carry a STRONG_WARNING, and the note on the standalone PPV/NPV per test prevents misreading.
- **i18n coverage:** COMPLETE. Every user-facing string is wrapped and the sampled msgids are present in `jamovi/i18n/catalog.pot`. There are no bracket msgids, separator-edge strings or named symbol entities.
- **UI:** CheckBox labels are noun phrases in sentence case, CollapseBox headings are in Title Case, and advanced options sit in collapsed boxes. The only `format:` token is `pc`.

**Top issues:**

1. **LOW** — Long `.run()` (F9, 1041 lines; [R/sequentialtests.b.R:58](R/sequentialtests.b.R#L58)). About 300 of those lines are the formulas panel, built from piecewise `paste0` ([:739–1038](R/sequentialtests.b.R#L739)). Extract `.buildFormulasHtml()`, `.buildExplanationHtml()` and `.collectNotices()`. `/review-function sequentialtests`.
2. **LOW** — Spliced i18n fragments. Translated phrases are spliced into other sentences:
   - `strategy_desc` and `tests_phrase` go into "Using a %1$s with %2$s" ([:327](R/sequentialtests.b.R#L327)).
   - `other` goes into "as {other}" ([:634](R/sequentialtests.b.R#L634)).
   - `dependence_caveat` goes into three sentences ([:293](R/sequentialtests.b.R#L293)).
   - `strategy_name` goes into "{strategy} strategy" ([:1079](R/sequentialtests.b.R#L1079)), which gives "Serial Testing (Test positives) strategy" even in English.
   - The `clinical_guidance` msgid at [:718](R/sequentialtests.b.R#L718) ends inside an open `<ul>` that a later literal closes.

   Grammatical agreement breaks in Turkish (case suffixes). `/prepare-translation sequentialtests`.
3. ~~**LOW** — `ClinicoPathJamoviModule` citation.~~ False positive (see Citation refs).
4. **LOW** — `aes()` uses bare column names (`TestKey`, `Value`, `Probability`, `Path`, `Prevalence`, `Metric`) at [:1368](R/sequentialtests.b.R#L1368), [:1511](R/sequentialtests.b.R#L1511) and [:1705](R/sequentialtests.b.R#L1705). None is in `utils::globalVariables` ([R/utils.R:17](R/utils.R#L17)), so `R CMD check` gives a "no visible binding" NOTE. Use `.data$`. `/fix-function sequentialtests`.

**Orchestrator correction (2026-10-21):** an earlier version of this report added a MEDIUM here for blanking the notices panel with `setContent("")` ([R/sequentialtests.b.R:1816](R/sequentialtests.b.R#L1816)). Withdrawn: the success path always adds an "Analysis Complete" INFO notice ([R/sequentialtests.b.R:1075](R/sequentialtests.b.R#L1075)), so that branch is unreachable on a completed run, and engine runs never sent an empty panel.

#### Recommended remediation

- `/jamovify-function sequentialtests --apply`: convert `sprintf(.())` to `.fmt(.())` with named placeholders.
- `/prepare-translation sequentialtests`: replace the spliced fragments with complete per-strategy msgids.
- `/review-function sequentialtests`: split `.run()` (F9). This is maintenance only.

---

## Methodology

**Profile:** standard. **Checks run:** discovery (`0000.yaml` + filesystem + umbrella drift); security catalog A–I;
jmvcore migration (6 groups); integration (argument and output crosswalks, clearWith §2b, requiresData tracing,
`tryCatch`/`reject()` reachability, dead-schema references, citations §10); notices coverage (empty / partial /
configured-invalid / failed optional step); code review (8 areas incl. i18n and statistical correctness);
re-verification of every 2026-10-20 finding; executed probes for PLAUSIBLE claims (table above); module
release gates.

**Skipped:** deep-profile blocks (R6 / R-package hygiene per function, vignette cross-reference); external
documentation comparison; `R CMD check`, `devtools::document()`, `jmvtools::prepare()`; GUI and `.omv`
round-trip testing; independent numerical oracles (clinical readiness stays `NEEDS_VALIDATION` where marked);
protobuf replay (RProtoBuf not installed).

**References used:** `references/security-patterns.md`, `jmvcore-migration.md`, `integration-checks.md`,
`notices-checklist.md`, `code-review-checks.md`, `r-package-best-practices.md`;
`guides/jamovi_library_review_guide.md`.

**Audit-only.** No source file was modified; the only new repository file is this report.

---

## Remediation playbook

**Priority 1: before release (MEDIUM, small diffs)**

- Stale notices (M1): replace `setContent("")` on a completing run with `"<div></div>"`:
  `/fix-function cotest`, `/fix-function decision`, `/fix-function decisioncalculator`,
  `/fix-function decisioncombine`, `/fix-function sequentialtests`. Add a regression test asserting
  `nzchar(notices$content)` after a warning → clean rerun.
- `/fix-function decisioncompare`: apply the LR correction only to an empty denominator, or make the three notes say what the code does (M2); show INFO, not ERROR, while levels are unset (M3); rename the stale checkbox reference (M4).
- `/fix-function enhancedROC`: disclose the constant-prevalence substitution, or suppress the risk outputs for that predictor with a notice (M5); `reject()` when no predictor can be analysed (M6).

**Priority 2: soon (MEDIUM, structural)**

- `/fix-function decisioncombine`: write `""` + footnote instead of `NA_real_` for undefined cells (M7; pattern: `decisioncalculator` `.footnoteNA()`).
- `/fix-function lassologistic`, `/fix-function psychopdaROC`: move computed HTML tables to `type: Table` results (M8, M9; guide §26).

**Priority 3: module hygiene (LOW)**

- Dataset docs: no action (the earlier "phantom datasets" item was a false positive; the objects live in multi-object `.rda`/`.RData` files).
- Licence: trace the `epiR` → `pander` (AGPL) chain with the jamovi team.
- Translations: `/prepare-translation <name>` for analyses marked PARTIAL; fill the 870 empty Turkish `msgstr`.
- Estimand disclosures (`agreement` subgroup CI note after 403e034, `kappaSizeCI`/`kappaSizeFixedN` RML bound, `psychopdaROC` cost metrics): `/review-function <name>`.
- Dead helpers in `enhancedROC-errors.R` / `utils-formula.R`: remove in the umbrella.
- Long `.run()` methods (11 analyses): extract only with parity tests (`/review-function <name>`).

**Priority 4: clinical sign-off**

- `/validate-function <name>` (independent oracles) for the 11 `NEEDS_VALIDATION` analyses before any clinical-readiness claim.

---

## Appendix: guides referenced

- `guides/jamovi_library_review_guide.md`: §2b clearWith, §6 fixed rows, §13 `insert()`, §15–18 requiresData / `reject()` in `tryCatch` / state payloads, §19 bare symbols, §20 fabricated statistics, §24 promotion, §25 notice states, §26 raw HTML tables, §30 library requirements.
- `guides/jamovi_notices_guide.md`: notice severity and panel blanking.
- `guides/jamovi_tables_guide.md`: NA vs blank cells, `setNote` HTML subset.
- `guides/jamovi_module_patterns_guide.md`: asSource / syntax export, state management.

*Generated by the `audit-module` skill. Re-run with `--functions a,b` for a targeted re-audit; previous reports are kept.*
