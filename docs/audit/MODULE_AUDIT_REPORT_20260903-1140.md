# Module Audit Report — meddecide 1.0.8.09

**Audited:** 2026-09-03 11:40  
**Profile:** standard (with deep release-gate and security catalog)  
**Module path:** `/Users/serdarbalci/Documents/GitHub/meddecide`  
**Umbrella reference:** `/Users/serdarbalci/Documents/GitHub/ClinicoPathJamoviModule`  
**Functions:** 15 · READY 15 · NEEDS WORK 0 · PLACEHOLDER 0 · MISSING 0 · ORPHANED 0  
**Security findings:** HIGH 0 · MEDIUM 0 · LOW 0  
**Skill:** audit-module v0.1.0  

---

## Executive Dashboard

| Function | Status | HIGH-Sec | MED-Sec | Integration | Notices | i18n | Readiness |
|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| **agreement** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (198) | READY |
| **cotest** | ✅ | 0 | 0 | ✅ | ✅ | ⚠️ (0) | READY (i18n pending) |
| **decision** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (332) | READY |
| **decisioncalculator** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (205) | READY |
| **decisioncombine** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (180) | READY |
| **decisioncompare** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (39) | READY |
| **decisioncurve** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (129) | READY |
| **enhancedROC** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (315) | READY |
| **kappaSizeCI** | ✅ | 0 | 0 | ✅ | ✅ | ⚠️ (0) | READY (i18n pending) |
| **kappaSizeFixedN** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (32) | READY |
| **kappaSizePower** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (38) | READY |
| **lassologistic** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (259) | READY |
| **nogoldstandard** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (180) | READY |
| **psychopdaROC** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (109) | READY |
| **sequentialtests** | ✅ | 0 | 0 | ✅ | ✅ | ✅ (247) | READY |

### Summary Totals

- **Analyses Discovered:** 15 production analyses declared in `jamovi/0000.yaml` under `menuGroup: meddecide`.
- **4-File Sets:** 15 / 15 complete (`.a.yaml`, `.u.yaml`, `.r.yaml`, `.b.R`).
- **Production Readiness:** 15 / 15 (100% READY).
- **Umbrella Zero-Drift Parity:** 60 / 60 files 100% byte-identical against `ClinicoPathJamoviModule`.
- **Security Vulnerabilities:** 0 HIGH, 0 MEDIUM, 0 LOW.
- **Automated Test Results:** 39 passed, 0 failed, 1 skipped (`devtools::test()`).

---

## Module-Wide Release Gates

| Release Gate | Requirement | Status | Observed Value / Details |
|---|---|:---:|---|
| **Version Gate** | `Version >= 1.0.0` & synced across 3 anchors | **PASS** | `1.0.8.09` in `DESCRIPTION`, `jamovi/0000.yaml`, and `CITATION.cff` |
| **License Gate** | OSI-approved license declared | **PASS** | `GPL (>= 2)` declared in `DESCRIPTION` and `LICENSE.md` |
| **Citation Integrity** | All used keys exist in `00refs.yaml`, no empty metadata | **PASS** | 53 defined, 49 cited, 0 dangling keys, 0 invalid year records |
| **clearWith Completeness** | Every `clearWith` token maps to a declared option | **PASS** | 0 dangling clearWith entries across all 15 `.r.yaml` files |
| **renderFun Resolution** | Every `renderFun` links to a defined R function | **PASS** | 0 unresolved renderFun references |
| **Compiler Mode** | `compilerMode: tame` declared on all UI files | **PASS** | Present on all 15 `jamovi/*.u.yaml` definitions |
| **No Silent Visibility Traps** | No unroutable `visible: (!x)` expressions in results | **PASS** | 0 occurrences across all `.r.yaml` files |
| **No Non-Structural HTML Entities** | No `&plusmn;`, `&times;`, etc. in R code (use literal UTF-8) | **PASS** | 0 occurrences across all `R/*.R` source files |
| **No Unguarded Image State Reads** | No `image$state` reads without `is.null()` protection | **PASS** | 0 unguarded reads across all plot renderers |
| **Theme-Safe HTML Pass** | No hardcoded dark `#hex` text colors inside HTML panels | **PASS** | 0 hardcoded dark hex text colors; all use `color: inherit;` |
| **No Committed Build Artifacts** | No `.tar.gz` or `.jmo` tracked in Git index | **PASS** | 0 tracked build artifacts in repository Git index |
| **UI Control Uniqueness** | No duplicate control names within any `.u.yaml` layout | **PASS** | 0 duplicate control IDs across all 15 `.u.yaml` files |

---

## Methodology

**Profile:** standard (with deep release-gate checks and zero-drift verification)

### Checks Executed:

1. **Discovery & Inventory:** Parsed `jamovi/0000.yaml` and verified presence of `.a.yaml`, `.u.yaml`, `.r.yaml`, and `.b.R` for all 15 analyses.
2. **Zero-Drift Crosswalk:** Compared all 60 analysis files byte-for-byte against the umbrella repository `ClinicoPathJamoviModule`.
3. **Security Audit (Categories A–I):**
   - Category A (Runtime Eval): `eval(parse())`, `parse(text=)`, `str2lang()`, `str2expression()`.
   - Category B (Dynamic Calls): user input flowing into function resolvers or `get()`.
   - Category C (Formula Construction): formula parsing injection, allow-list checks.
   - Category D (HTML/XSS): user column names, levels, or labels in `setContent()` without `htmlEscape()` or `.safeHtmlOutput()`.
   - Category E/F (Filesystem/Deserialization): `system()`, `system2()`, `readRDS()`, `load()`.
   - Category G/H (Codegen/Hygiene): hardcoded debug flags, bare `library()` calls.
4. **jmvcore Migration Review:** Checked usage of `jmvcore::reject()`, `jmvcore::asFormula()`, `jmvcore::naOmit()`.
5. **Notices & Defensive Error Handling:** Verified input gating, sample size thresholds, and clinical alert mechanisms.
6. **Theme & Dark Mode Verification:** Validated that background tints use translucent `rgba(...)` and text styling inherits theme colors.
7. **R Package Quality & Automated Tests:** Executed full package test suite (`devtools::test()`).

---

## Per-Function Audit Sections

### agreement

- **Status:** ✅ READY
- **Files:** [`R/agreement.b.R`](R/agreement.b.R) · [`jamovi/agreement.a.yaml`](jamovi/agreement.a.yaml) · [`jamovi/agreement.u.yaml`](jamovi/agreement.u.yaml) · [`jamovi/agreement.r.yaml`](jamovi/agreement.r.yaml) · [`jamovi/js/agreement.events.js`](jamovi/js/agreement.events.js)
- **Metrics:** LOC: 9,357 · Options: 153 · Result Items: 115 (48 Tables, 8 Images, 42 HTML panels, 15 Preformatted, 2 Output items) · i18n Strings: 198
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. User-supplied variables and ratings matrices are strictly typed and sanitized before entering statistical algorithms (`irr`, `irrCAC`, `psych`).
- **jmvcore Integration:** Uses `jmvcore::reject()` for input validation; clearWith bindings properly invalidate dependent agreement matrices.
- **Clinical & Output Integrity:** Comprehensive inter-rater reliability suite covering Cohen's kappa, Fleiss' kappa, Gwet's AC1/AC2, Krippendorff's alpha, and Intraclass Correlation Coefficients (ICC).
- **Theme-Safety:** HTML guide and summary panels use `rgba(...)` backgrounds with `color: inherit;`.

### cotest

- **Status:** ✅ READY (i18n pending)
- **Files:** [`R/cotest.b.R`](R/cotest.b.R) · [`jamovi/cotest.a.yaml`](jamovi/cotest.a.yaml) · [`jamovi/cotest.u.yaml`](jamovi/cotest.u.yaml) · [`jamovi/cotest.r.yaml`](jamovi/cotest.r.yaml) · [`jamovi/js/cotest.events.js`](jamovi/js/cotest.events.js)
- **Metrics:** LOC: 984 · Options: 14 · Result Items: 8 (2 Tables, 1 Image, 5 HTML panels) · Notices: 22
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. User test labels (`test1_name`, `test2_name`) are sanitized via `.testLabel()` calling `.escapeHtml()` prior to interpolation into HTML interpretation summaries.
- **jmvcore Integration:** Gated calculations with structured notices (`NoticeType$ERROR`, `NoticeType$WARNING`, `NoticeType$INFO`).
- **Clinical & Output Integrity:** Dual diagnostic testing evaluation modeling both conditional independence and conditional dependence (Vacek-Gart model) with Fagan nomogram Bayesian probability updates.
- **Theme-Safety:** Clean HTML output inheriting theme styles with translucent alert callouts.

### decision

- **Status:** ✅ READY
- **Files:** [`R/decision.b.R`](R/decision.b.R) · [`jamovi/decision.a.yaml`](jamovi/decision.a.yaml) · [`jamovi/decision.u.yaml`](jamovi/decision.u.yaml) · [`jamovi/decision.r.yaml`](jamovi/decision.r.yaml)
- **Metrics:** LOC: 1,642 · Options: 20 · Result Items: 21 (10 Tables, 1 Image, 9 HTML panels, 1 Output) · i18n Strings: 332 · Notices: 38
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. All user inputs escaped via `private$.safeHtmlOutput()` before HTML template formatting.
- **jmvcore Integration:** Full input gating across gold standard and index test levels; Haldane-Anscombe zero-cell correction safely prevents division-by-zero infinities.
- **Clinical & Output Integrity:** Diagnostic test evaluation providing Sensitivity, Specificity, PPV, NPV, Positive/Negative Likelihood Ratios, Youden's Index, Number Needed to Diagnose, and misclassified case extraction.
- **Theme-Safety:** All 21 inline color sites refactored to `color: inherit;` and `rgba(74, 144, 226, 0.08)`.

### decisioncalculator

- **Status:** ✅ READY
- **Files:** [`R/decisioncalculator.b.R`](R/decisioncalculator.b.R) · [`jamovi/decisioncalculator.a.yaml`](jamovi/decisioncalculator.a.yaml) · [`jamovi/decisioncalculator.u.yaml`](jamovi/decisioncalculator.u.yaml) · [`jamovi/decisioncalculator.r.yaml`](jamovi/decisioncalculator.r.yaml)
- **Metrics:** LOC: 1,076 · Options: 24 · Result Items: 15 (7 Tables, 1 Image, 6 HTML panels, 1 Preformatted) · i18n Strings: 205 · Notices: 28
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Parameter-based calculations from summary counts (TP, FP, FN, TN) or rates without external code execution.
- **jmvcore Integration:** Structured clinical notices validate cell counts and extreme prevalence values.
- **Clinical & Output Integrity:** Generates summary decision tables, Bayes theorem nomograms, and copy-ready clinical report sentences.

### decisioncombine

- **Status:** ✅ READY
- **Files:** [`R/decisioncombine.b.R`](R/decisioncombine.b.R) · [`jamovi/decisioncombine.a.yaml`](jamovi/decisioncombine.a.yaml) · [`jamovi/decisioncombine.u.yaml`](jamovi/decisioncombine.u.yaml) · [`jamovi/decisioncombine.r.yaml`](jamovi/decisioncombine.r.yaml)
- **Metrics:** LOC: 1,659 · Options: 20 · Result Items: 23 (12 Tables, 4 Images, 3 HTML panels, 3 Groups, 1 Output) · i18n Strings: 180 · Notices: 43
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Safe combination of test rules (Believe the Positive, Believe the Negative, Simultaneous, Sequential).
- **jmvcore Integration:** Validates test availability and factor alignment; correctly maps contingency matrices.
- **Theme-Safety:** Welcome card header updated to `color: inherit;`.

### decisioncompare

- **Status:** ✅ READY
- **Files:** [`R/decisioncompare.b.R`](R/decisioncompare.b.R) · [`jamovi/decisioncompare.a.yaml`](jamovi/decisioncompare.a.yaml) · [`jamovi/decisioncompare.u.yaml`](jamovi/decisioncompare.u.yaml) · [`jamovi/decisioncompare.r.yaml`](jamovi/decisioncompare.r.yaml)
- **Metrics:** LOC: 2,275 · Options: 32 · Result Items: 22 (11 Tables, 3 Images, 7 HTML panels, 1 Preformatted) · i18n Strings: 39 · Notices: 37
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Statistical comparison via McNemar test and relative predictive values without eval/parse sinks.
- **jmvcore Integration:** Gated against missing paired data; handles unmatched or single-level observations gracefully.

### decisioncurve

- **Status:** ✅ READY
- **Files:** [`R/decisioncurve.b.R`](R/decisioncurve.b.R) · [`jamovi/decisioncurve.a.yaml`](jamovi/decisioncurve.a.yaml) · [`jamovi/decisioncurve.u.yaml`](jamovi/decisioncurve.u.yaml) · [`jamovi/decisioncurve.r.yaml`](jamovi/decisioncurve.r.yaml)
- **Metrics:** LOC: 2,018 · Options: 45 · Result Items: 18 (9 Tables, 5 Images, 4 HTML panels) · i18n Strings: 129 · Notices: 58
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Safe calculation of Net Benefit and Net Reduction in Interventions across clinical threshold ranges.
- **jmvcore Integration:** All plotting functions guarded against empty states and non-convergent model fits.
- **Theme-Safety:** Notice wrappers and footnotes converted to `color: inherit; opacity: 0.85;`.

### enhancedROC

- **Status:** ✅ READY
- **Files:** [`R/enhancedROC.b.R`](R/enhancedROC.b.R) · [`jamovi/enhancedROC.a.yaml`](jamovi/enhancedROC.a.yaml) · [`jamovi/enhancedROC.u.yaml`](jamovi/enhancedROC.u.yaml) · [`jamovi/enhancedROC.r.yaml`](jamovi/enhancedROC.r.yaml)
- **Metrics:** LOC: 4,052 · Options: 84 · Result Items: 38 (20 Tables, 11 Images, 6 HTML panels, 1 Group) · i18n Strings: 315 · Notices: 71
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. User-specified cutoff points, bootstrap replications, and Delong test comparisons are validated and escaped.
- **jmvcore Integration:** Full suite of ROC curves, precision-recall curves, optimal cutpoint discovery (Youden, closest to (0,1)), and multiple curve comparisons.
- **Theme-Safety:** Summary and clinical report sentence headers use `color: inherit;`.

### kappaSizeCI

- **Status:** ✅ READY (i18n pending)
- **Files:** [`R/kappaSizeCI.b.R`](R/kappaSizeCI.b.R) · [`jamovi/kappaSizeCI.a.yaml`](jamovi/kappaSizeCI.a.yaml) · [`jamovi/kappaSizeCI.u.yaml`](jamovi/kappaSizeCI.u.yaml) · [`jamovi/kappaSizeCI.r.yaml`](jamovi/kappaSizeCI.r.yaml) · [`jamovi/js/kappaSizeCI.events.js`](jamovi/js/kappaSizeCI.events.js)
- **Metrics:** LOC: 502 · Options: 8 · Result Items: 4 (1 HTML panel, 3 Preformatted) · Notices: 3
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Clean numeric parameter bounds checking (`kappa0`, `kappaL`, `kappaU`, `alpha`).
- **jmvcore Integration:** Wraps `kappaSize::CI3Cats`, `kappaSize::CI4Cats`, `kappaSize::CI5Cats` with boundary validation preventing engine crashes.

### kappaSizeFixedN

- **Status:** ✅ READY
- **Files:** [`R/kappaSizeFixedN.b.R`](R/kappaSizeFixedN.b.R) · [`jamovi/kappaSizeFixedN.a.yaml`](jamovi/kappaSizeFixedN.a.yaml) · [`jamovi/kappaSizeFixedN.u.yaml`](jamovi/kappaSizeFixedN.u.yaml) · [`jamovi/kappaSizeFixedN.r.yaml`](jamovi/kappaSizeFixedN.r.yaml) · [`jamovi/js/kappaSizeFixedN.events.js`](jamovi/js/kappaSizeFixedN.events.js)
- **Metrics:** LOC: 215 · Options: 6 · Result Items: 4 (1 HTML panel, 3 Preformatted) · i18n Strings: 32 · Notices: 3
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Fixed-sample power and confidence interval calculations.
- **jmvcore Integration:** Uses `jmvcore::reject()` for invalid proportions; returns structured summary tables.

### kappaSizePower

- **Status:** ✅ READY
- **Files:** [`R/kappaSizePower.b.R`](R/kappaSizePower.b.R) · [`jamovi/kappaSizePower.a.yaml`](jamovi/kappaSizePower.a.yaml) · [`jamovi/kappaSizePower.u.yaml`](jamovi/kappaSizePower.u.yaml) · [`jamovi/kappaSizePower.r.yaml`](jamovi/kappaSizePower.r.yaml) · [`jamovi/js/kappaSizePower.events.js`](jamovi/js/kappaSizePower.events.js)
- **Metrics:** LOC: 224 · Options: 7 · Result Items: 4 (1 HTML panel, 3 Preformatted) · i18n Strings: 38 · Notices: 3
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Power analysis for interobserver agreement studies.
- **jmvcore Integration:** Input parameter verification prevents invalid null/alternative hypotheses.

### lassologistic

- **Status:** ✅ READY
- **Files:** [`R/lassologistic.b.R`](R/lassologistic.b.R) · [`jamovi/lassologistic.a.yaml`](jamovi/lassologistic.a.yaml) · [`jamovi/lassologistic.u.yaml`](jamovi/lassologistic.u.yaml) · [`jamovi/lassologistic.r.yaml`](jamovi/lassologistic.r.yaml)
- **Metrics:** LOC: 1,692 · Options: 29 · Result Items: 21 (10 Tables, 3 Images, 7 HTML panels, 1 Output) · i18n Strings: 259 · Notices: 30
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Regularized logistic regression via `glmnet` without dynamic formula evaluation. Matrix inputs sanitized for sparse encoding.
- **jmvcore Integration:** Full cross-validation tuning (`lambda.min`, `lambda.1se`), coefficient trajectory plots, and model discrimination metrics.
- **Theme-Safety:** Notice wrapper converted to `color: inherit;`.

### nogoldstandard

- **Status:** ✅ READY
- **Files:** [`R/nogoldstandard.b.R`](R/nogoldstandard.b.R) · [`jamovi/nogoldstandard.a.yaml`](jamovi/nogoldstandard.a.yaml) · [`jamovi/nogoldstandard.u.yaml`](jamovi/nogoldstandard.u.yaml) · [`jamovi/nogoldstandard.r.yaml`](jamovi/nogoldstandard.r.yaml)
- **Metrics:** LOC: 1,651 · Options: 20 · Result Items: 12 (6 Tables, 1 Image, 3 HTML panels, 2 Preformatted) · i18n Strings: 180 · Notices: 29
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Latent class formula constructed with `jmvcore::asFormula()` allow-list guard; user-derived test names escaped in HTML summaries.
- **jmvcore Integration:** Implements 2-class Latent Class Analysis (poLCA), Penalized EM MAP estimation, and composite reference standards.
- **Theme-Safety:** All 13 headers and guide cards converted to `color: inherit;`.

### psychopdaROC

- **Status:** ✅ READY
- **Files:** [`R/psychopdaROC.b.R`](R/psychopdaROC.b.R) · [`jamovi/psychopdaROC.a.yaml`](jamovi/psychopdaROC.a.yaml) · [`jamovi/psychopdaROC.u.yaml`](jamovi/psychopdaROC.u.yaml) · [`jamovi/psychopdaROC.r.yaml`](jamovi/psychopdaROC.r.yaml)
- **Metrics:** LOC: 4,471 · Options: 78 · Result Items: 37 (16 Tables, 1 Image, 6 HTML panels, 13 Dynamic Arrays, 1 Preformatted) · i18n Strings: 109 · Notices: 1
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Advanced clinical ROC analytics including Net Reclassification Improvement (NRI) and Integrated Discrimination Improvement (IDI).
- **jmvcore Integration:** Safe bootstrap estimation of reclassification statistics; calibration metrics safely consolidated.
- **Theme-Safety:** All 9 section titles and reading notes converted to `color: inherit; opacity: 0.85;`.

### sequentialtests

- **Status:** ✅ READY
- **Files:** [`R/sequentialtests.b.R`](R/sequentialtests.b.R) · [`jamovi/sequentialtests.a.yaml`](jamovi/sequentialtests.a.yaml) · [`jamovi/sequentialtests.u.yaml`](jamovi/sequentialtests.u.yaml) · [`jamovi/sequentialtests.r.yaml`](jamovi/sequentialtests.r.yaml) · [`jamovi/js/sequentialtests.events.js`](jamovi/js/sequentialtests.events.js)
- **Metrics:** LOC: 1,456 · Options: 16 · Result Items: 14 (4 Tables, 5 Images, 4 HTML panels, 1 Preformatted) · i18n Strings: 247 · Notices: 38
- **Security:** 0 HIGH, 0 MEDIUM, 0 LOW. Sequential multi-stage diagnostic testing evaluations without dynamic script evaluation.
- **jmvcore Integration:** Exemplary use of notices, decision pathway flowcharts, and post-test probability calculations.

---

## Cross-Cutting Observations & Best Practices

1. **Complete Theme-Safe Dark Mode Compatibility:**
   - Following the comprehensive dark mode pass, 0 hardcoded dark hex text colors remain across all 15 analyses.
   - All informational and clinical guidance panels use translucent `rgba(...)` background fills paired with `color: inherit;`, ensuring perfect legibility across light, gray, and dark jamovi window themes.
2. **Robust Input Sanitization:**
   - User-supplied variable names and factor level strings are uniformly passed through `private$.safeHtmlOutput()` or `htmltools::htmlEscape()` before being embedded into custom HTML cards, preventing injection vulnerabilities.
3. **Defense-in-Depth Formula Construction:**
   - Where formula evaluation is required (`nogoldstandard`), it utilizes `jmvcore::asFormula()` rather than base R `as.formula(paste(...))`, strictly respecting the jamovi global allow-list.
4. **Stable Output Binding Architecture:**
   - 0 dangling `clearWith` dependencies across all 15 `.r.yaml` specifications.
   - 0 unresolved `renderFun` methods.
   - 0 unguarded `image$state` reads in image renderers.
5. **Internationalization Progress:**
   - Standalone translation catalogs (`jamovi/i18n/catalog.pot`, `en.po`, `tr.po`) are bundled and maintained.
   - 13 of 15 analyses actively use `.()` string wrapping (over 2,100 translatable strings wrapped). `cotest` and `kappaSizeCI` are queued for future `.()` internationalization passes.

---

## Remediation & Maintenance Playbook

All release gates and unit tests are currently passing. For ongoing maintenance and future additions, follow these protocols:

1. **Adding New Analysis Features:**
   - Whenever editing any analysis in `meddecide`, immediately mirror changes to `ClinicoPathJamoviModule` (Zero-Drift rule).
   - Use `tools/release_gate.py` and `tools/theme_safe_html.py` to prevent regressions.
2. **Internationalization Expansion:**
   - When updating `cotest` or `kappaSizeCI`, run `/prepare-translation <name>` to wrap remaining display strings with `.()`.
3. **Pre-Release Verification:**
   - Run `devtools::test()` inside both `meddecide` and `ClinicoPathJamoviModule` before tagging a release.
   - Verify that `DESCRIPTION`, `0000.yaml`, and `CITATION.cff` share the exact same version string.

---

## Appendix: Verified Guides & Tooling

The checks performed in this audit correspond directly to the official guidelines in:
- `guides/jamovi_library_review_guide.md`: Reviewer checklist, release gates, and common pitfalls.
- `guides/jamovi_notices_guide.md`: Structured clinical warnings and error notices.
- `guides/jamovi_formula_guide.md`: Safe formula handling and allow-list integration.
- `guides/jamovi_plots_guide.md`: Guarded plot state management and render functions.
- `guides/jamovi_i18n_guide.md`: Localization catalogs and translation extraction.
