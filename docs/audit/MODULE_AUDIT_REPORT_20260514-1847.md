# Module Audit Report — meddecide 0.0.38.1

**Audited:** 2026-05-14 18:47
**Profile:** standard
**Module path:** `/Users/serdarbalci/Documents/GitHub/meddecide`
**Functions:** 13 · READY 1 · NEEDS WORK 12 · PLACEHOLDER 0 · MISSING 0 · ORPHANED 0
**Security findings:** HIGH 3 · MEDIUM 5 · LOW 8
**Skill:** audit-module v0.1.0

---

## Executive Dashboard

| Function | Status | HIGH-Sec | MEDIUM-Sec | Integration | Notices | i18n | Readiness |
|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| agreement              | ⚠️ | 0 | 1 | ⚠ | ❌ | ❌ | NEEDS_VALIDATION |
| cotest                 | ⚠️ | 0 | 0 | ✅ | ❌ | ❌ | NEEDS_VALIDATION |
| decision               | ⚠️ | 1 | 1 | ✅ | ⚠ | ⚠ | NEEDS_VALIDATION |
| decisioncalculator     | ⚠️ | 0 | 0 | ✅ | ✅ | ❌ | NEEDS_VALIDATION |
| decisioncombine        | ⚠️ | 0 | 0 | ✅ | ⚠ | ❌ | NEEDS_VALIDATION |
| decisioncompare        | ⚠️ | 1 | 1 | ✅ | ❌ | ⚠ | NEEDS_VALIDATION |
| enhancedROC            | ⚠️ | 0 | 1 | ⚠ | ❌ | ⚠ | NEEDS_VALIDATION |
| kappasizeci            | ⚠️ | 0 | 0 | ⚠ | ❌ | ❌ | NEEDS_VALIDATION |
| kappasizefixedn        | ⚠️ | 0 | 0 | ⚠ | ❌ | ❌ | NEEDS_VALIDATION |
| kappasizepower         | ⚠️ | 0 | 0 | ⚠ | ❌ | ❌ | NEEDS_VALIDATION |
| nogoldstandard         | ⚠️ | 1 | 0 | ✅ | ⚠ | ⚠ | NEEDS_VALIDATION |
| psychopdaROC           | ⚠️ | 0 | 1 | ⚠ | ❌ | ⚠ | NEEDS_VALIDATION |
| sequentialtests        | ✅ | 0 | 0 | ✅ | ✅ | ❌ | READY (i18n pending) |

**Top 10 cross-cutting issues (affecting multiple functions):**

1. **No i18n infrastructure** — no `jamovi/i18n/` directory, no `.po`/`.pot` catalogs, no `NAMESPACE` `importFrom(jmvcore, .)` (relies on `import(jmvcore)`). 7 of 13 functions have zero `.()` wraps. (13 functions affected — module-wide).
2. **HTML XSS via variable names in `setContent`** — `test_name` / `gold_name` / column names from user `Variable`-type options interpolated into HTML output without `htmlEscape`. Module has `.safeHtmlOutput` helper but it's only applied to notice content, not to report bodies. (3 functions: `decision`, `decisioncompare`, `nogoldstandard`).
3. **Notices coverage critically uneven** — `sequentialtests` and `decisioncalculator` are exemplary; `agreement`, `cotest`, `decision`, `decisioncombine`, `decisioncompare`, `enhancedROC`, `kappasize*`, `psychopdaROC` have **zero** `NoticeType$` use, falling back to `setNote` on tables or `setContent` on Html outputs. (10 functions).
4. **jmvcore migration opportunities** — 0 uses of `jmvcore::asFormula` (despite formula constructions in `nogoldstandard`); only 4 uses of `constructFormula`/`composeFormula`; 8 `na.omit` calls on jamovi-attributed data frames could use `jmvcore::naOmit`; 31 bare `stop()` calls in user-facing paths could become `jmvcore::reject` (only 16 currently do). (8+ functions).
5. **Formula construction without allow-list guard** — `nogoldstandard.b.R:642` uses `stats::as.formula(paste(...))` with a hand-rolled backtick escaper instead of `jmvcore::asFormula` + `jmvcore::composeTerms`. Currently safe by virtue of `[^a-zA-Z0-9._]` escape but lacks parse-time defense against the (rare) embedded-backtick edge case. (1 function).
6. **`agreement.b.R` is a 10,559-line monolith** — single `.b.R` with 146 options and 396 declared outputs. `.run()` starts at line 9,584 and runs ~970 lines straight through. Helpers extracted, but the file is hard to navigate. (1 function).
7. **R-level `stop()` instead of `jmvcore::reject()` in validation** — naked `stop()` (often without `.()` wrapping) in `agreement` (multiple), `nogoldstandard` (~6 instances), `psychopdaROC` (~5), `decisioncombine` (table-level). (8 functions).
8. **No `.po`/`.pot` translation catalog** — even where `.()` is used (e.g. `enhancedROC` has 143 calls), there is no extraction catalog, so all strings render in English regardless of locale. (module-wide).
9. **396 outputs declared in `agreement.r.yaml` vs 131 setters in `.b.R`** — gross mismatch suggests many outputs are conditionally rendered via `setVisible(FALSE)` rather than populated. Outputs may appear empty/blank to users who toggle the wrong combination of flags. (1 function but high impact).
10. **No regression test coverage for 11 of 13 analyses** — only `tests/testthat/test-decision.R` (271 lines) and `tests/testthat/test-roc.R` (42 lines) exist; `agreement`, `cotest`, `decisioncalculator`, `decisioncombine`, `decisioncompare`, `enhancedROC`, `kappasize*` (3), `nogoldstandard`, `sequentialtests` have no tests. (11 functions).

---

## Methodology

**Profile:** standard

**Checks run:**

- [x] Function discovery from `jamovi/0000.yaml` + filesystem (13 analyses, all 4 yaml files + `.b.R` present for each)
- [x] Security pattern scan (catalog A–I) — see `references/security-patterns.md`
- [x] jmvcore migration scan (6 groups) — see `references/jmvcore-migration.md`
- [x] Integration audit (9 checks) — see `references/integration-checks.md`
- [x] Notices coverage — see `references/notices-checklist.md`
- [x] Code review (8 areas including i18n) — see `references/code-review-checks.md`
- [ ] R6 & R-package best practices — `deep` only (skipped)
- [ ] Vignette cross-reference — `deep` only (skipped)

**Checks skipped:**

- External documentation comparison (CRAN/GitHub) — run `/check-function-full <name>` per function if needed
- Function execution (differential runs) — heuristic only, no actual jamovi runs
- R CMD check, `devtools::document()`, `jmvtools::prepare()` — out of scope for this skill

**Audit-only.** No source files were modified.

---

## Per-Function Sections

### agreement

**Status:** ⚠️ NEEDS WORK
**Files:** [`R/agreement.b.R`](R/agreement.b.R) · [`jamovi/agreement.a.yaml`](jamovi/agreement.a.yaml) · [`jamovi/agreement.u.yaml`](jamovi/agreement.u.yaml) · [`jamovi/agreement.r.yaml`](jamovi/agreement.r.yaml) · [`jamovi/js/agreement.events.js`](jamovi/js/agreement.events.js)
**Metrics:** .b.R LOC **10,559** · options 146 (6 Variable, 20 List, 93 Bool, 21 Number) · outputs 396 (40 Html, 46 Table, 8 Image) · setContent calls 41 · NoticeType uses **0** · `.()` wraps 3

#### Security

- **[D-MEDIUM]** [`R/agreement.b.R:8688`](R/agreement.b.R#L8688) — `table$setNote("raters", paste0("Reference: ", rater_names[1], ", Predicted: ", rater_names[2], ...))` — `rater_names` are user column names. `setNote` is plain-text in current jamovi versions, but the same column-name source is unescaped if/when it lands in any `setContent` path later. Module already has no `.safeHtmlOutput` helper in this file (unlike `decision`/`enhancedROC`).
- *No HIGH findings.*

#### jmvcore migration

- **[na]** [`R/agreement.b.R:9762`](R/agreement.b.R#L9762) and several elsewhere — `na.omit(ratings)` used on a frame that may carry jamovi attributes. Replace with `jmvcore::naOmit(ratings)` to preserve `measureType` / `values` attributes.
- **[error]** Multiple — bare `setNote("error", "...")` paths in lieu of structured `jmvcore::Notice` with `NoticeType$ERROR`.

#### Integration

**Arguments declared:** 146  ·  **used in logic:** ~140  ·  **dead:** small handful of `show*Guide` flags only render explanations
**Outputs declared:** 396  ·  **populated:** 131 setter calls; remainder gated by `setVisible(FALSE)` defaults — flagged as **OUTPUT-OVERDECLARATION**.

| Output | Type | Setter | Populated? | Notes |
|---|---|---|:---:|---|
| many `*Heading`, `*Explanation`, `*Guide` HTML blocks | Html | `setContent` | ⚠ conditional | populated only when matching `show*Guide` flag toggled — verify each on/off via `/check-function-full agreement` |

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs (`vars` < 2) | ERROR | ⚠ | ✅ | Uses `setVisible(TRUE)` + welcome HTML, not `Notice ERROR`. UX-friendly but inconsistent with rest of module's notice pattern. |
| Low n (`nrow == 0`) | ERROR | ⚠ | ❌ | Uses `setNote("error", "Data contains no (complete) rows...")` rather than a top-level ERROR notice. |
| Assumption violation (ordinal required for weighted kappa) | STRONG_WARNING | ⚠ | ✅ | `setNote("error", ...)` not `STRONG_WARNING`. |
| Methodology summary | INFO | ❌ | — | None. |

#### Code review

- **Overall quality:** 3/5 — comprehensive but a 10k-line file is unmaintainable; helper extraction would split it 4× without behaviour change.
- **Architecture:** Helpers are extracted but the file size and the giant `.run()` block (≈970 lines starting [`R/agreement.b.R:9584`](R/agreement.b.R#L9584)) make navigation hard.
- **Mathematical/statistical correctness:** NOT_EVALUATED — Cohen/Fleiss/Krippendorff/ICC/CCC/Bhapkar/Stuart-Maxwell/PABAK/Gwet/etc. are all wired through `irr::*`, `psych::ICC`, `irrCAC`, etc. Surface looks correct but **needs `/review-function agreement`** for parity checks.
- **Clinical readiness:** NEEDS_VALIDATION — many statistical methods rendered without surfacing assumption violations as STRONG_WARNING.
- **i18n coverage:** NONE — only 3 `.()` calls in 10,559 lines.

**Top issues:**

1. Monolithic `.run()` (~970 lines) and overall 10,559-LOC file — split per analysis family (kappa, ICC, alpha, etc.).
2. Zero `jmvcore::Notice` usage despite 41 `setContent` calls and many `setNote("error", …)` paths — migrate validation to notices.
3. i18n is essentially absent (3 wraps); statistical text in HTML/setNote is hardcoded English.

#### Recommended remediation

- `/review-function agreement` — confirm statistical parity for each helper (kappa2, ICC, kripp.alpha, Gwet AC, etc.)
- `/jamovify-function agreement --pattern=na,error --apply` — bulk-swap `na.omit` and `stop()` per the jmvcore migration table
- `/fix-notices agreement` — convert `setNote("error", …)` paths to structured `Notice ERROR/STRONG_WARNING`
- `/prepare-translation agreement` — wrap user-visible strings with `.()` and bootstrap `jamovi/i18n/`

---

### cotest

**Status:** ⚠️ NEEDS WORK (no security findings — but missing notices + i18n)
**Files:** [`R/cotest.b.R`](R/cotest.b.R) · [`jamovi/cotest.a.yaml`](jamovi/cotest.a.yaml) · [`jamovi/cotest.u.yaml`](jamovi/cotest.u.yaml) · [`jamovi/cotest.r.yaml`](jamovi/cotest.r.yaml) · [`jamovi/js/cotest.events.js`](jamovi/js/cotest.events.js)
**Metrics:** .b.R LOC 856 · options 18 (0 Variable, 1 List, 3 Bool, 7 Number) · outputs 17 (5 Html, 2 Table, 1 Image) · setContent 5 · NoticeType **0** · `.()` wraps 0

#### Security

*No findings in standard profile.* All HTML construction uses static templates; numeric option values flow into HTML but none are free-text `String`.

#### jmvcore migration

*No high-priority opportunities.* Calculator-style function — no data, no formula building.

#### Integration

**Arguments declared:** 18  ·  **used:** 18  ·  **dead:** 0
**Outputs declared:** 17  ·  **populated:** 16 setter calls — all visible

Calculator wired through `epiR`/sequential rules. `self$data` not used (calculator-style — by design).

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Invalid inputs | ERROR | ❌ | — | Validation is silent — user gets NaN/empty cells. |
| Low n / events | STRONG_WARNING | ❌ | — | Test characteristics are parameters, but no warnings on extreme combos. |
| Assumption violation (test independence) | STRONG_WARNING | ⚠ | ✅ | Note appended to `explanation` HTML; should also be a STRONG_WARNING notice banner. |
| Methodology summary | INFO | ❌ | — | None. |

#### Code review

- **Overall quality:** 3.5/5
- **Architecture:** Clean, single-purpose calculator. Builds dependence-info HTML via a private helper.
- **Mathematical/statistical correctness:** NOT_EVALUATED — needs `/review-function cotest` (Bayes update formulas + sequential rules).
- **Clinical readiness:** NEEDS_VALIDATION — fine for screening rounds, but lacks thresholds for unreasonable joint probabilities.
- **i18n coverage:** NONE.

**Top issues:**

1. No structured notices — all validation either silent or buried in HTML body.
2. No `.()` wrapping; English-only.
3. Independence assumption surfaces as a buried paragraph; should be a banner.

#### Recommended remediation

- `/fix-notices cotest` — add ERROR/STRONG_WARNING for invalid inputs + independence assumption
- `/review-function cotest` — validate Bayes math against textbook reference
- `/prepare-translation cotest`

---

### decision

**Status:** ⚠️ NEEDS WORK (1 HIGH security finding)
**Files:** [`R/decision.b.R`](R/decision.b.R) · [`jamovi/decision.a.yaml`](jamovi/decision.a.yaml) · [`jamovi/decision.u.yaml`](jamovi/decision.u.yaml) · [`jamovi/decision.r.yaml`](jamovi/decision.r.yaml)
**Metrics:** .b.R LOC 2,136 · options 20 (2 Variable, 0 List, 10 Bool, 2 Number) · outputs 68 (9 Html, 10 Table, 1 Image) · setContent 12 · NoticeType **0** · `.()` wraps 91

#### Security

- **[D-HIGH]** [`R/decision.b.R:626-639`](R/decision.b.R#L626-L639) (.generateNaturalLanguageSummary): `summary_template` contains `%s` placeholders, then `sprintf(summary_template, test_name, gold_name, …)` interpolates column names (from `self$options$newtest` / `self$options$gold`, both `type: Variable`) into HTML. The result is later rendered via `self$results$naturalLanguageSummary$setContent(content_results$natural_summary)` at [`R/decision.b.R:1607`](R/decision.b.R#L1607). `test_name` / `gold_name` are **not** wrapped through `private$.safeHtmlOutput` (which exists at line 88). A column named `<script>alert(1)</script>` (jamovi permits any unicode label) would inject script.
- **[D-HIGH]** [`R/decision.b.R:651-660`](R/decision.b.R#L651-L660) (.generateReportTemplate): same chain. `template_string` `%s` is filled with `test_name`, `gold_name`. Result lands at [`R/decision.b.R:1612`](R/decision.b.R#L1612) via `setContent(content_results$report_template)`.
- **[D-MEDIUM]** [`R/decision.b.R:1629`](R/decision.b.R#L1629) — `setContent(paste0(warning_panel, current_content))` where `warning_panel` is built from `warning_text <- paste(warnings, collapse = "<br>")` and `warnings` are internal hardcoded strings (clinical thresholds). Internal-only ⇒ MEDIUM (kept because future authors may add user-derived warning content).

#### jmvcore migration

- **[error]** Multiple bare `stop(.("…"))` paths could be `jmvcore::reject(.("…"))` for consistency with the rest of `decision.b.R` already using `reject`.
- **[na]** `na.omit(…)` calls in helper paths — switch to `jmvcore::naOmit` when frame carries `measureType`.

#### Integration

**Arguments declared:** 20  ·  **used:** 20  ·  **dead:** 0
**Outputs declared:** 68  ·  **populated:** 32 setters; many gated by `show*` flags (intentional, but verify each toggles correctly).

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs (`newtest`/`gold`) | ERROR | ✅ | ✅ | Uses private `.addNotice(type="ERROR", …)` + custom `notices` Html (own implementation, not `jmvcore::Notice`). |
| Extreme prevalence (< 5% / > 95%) | STRONG_WARNING | ⚠ | ✅ | Wrapped in `.detectMisuse` and prepended to clinical interpretation HTML — should also be a top banner. |
| Small cell counts (< 5) | STRONG_WARNING | ⚠ | ✅ | Same — surfaced via misuse panel, not as a banner. |
| Methodology summary | INFO | ❌ | — | None. |

#### Code review

- **Overall quality:** 4/5 — well-organized helpers, but the home-grown notice system parallels `jmvcore::Notice`. Consolidating would simplify.
- **Architecture:** Has `.safeHtmlOutput` (line 88) and uses it for notice title/body — but **not for natural-language / report-template / clinical-interpretation** HTML where variable names land.
- **Mathematical/statistical correctness:** Diagnostic metrics use standard formulas; Bayes prior/posterior chain is correct. Needs `/review-function decision` for CI parity (Wilson vs exact Clopper-Pearson — `decision` currently uses bootstrap & epiR; verify direction).
- **Clinical readiness:** NEEDS_VALIDATION — clinical thresholds documented but not all surfaced as banners.
- **i18n coverage:** PARTIAL — 91 `.()` wraps; some strings inside `paste0()` HTML blocks not wrapped.

**Top issues:**

1. **D-HIGH XSS** via variable names in HTML report outputs ([R/decision.b.R:626-639](R/decision.b.R#L626) and [:651-660](R/decision.b.R#L651)).
2. Two parallel notice systems: home-grown `private$.addNotice` ↔ `jmvcore::Notice` — pick one.
3. Misuse warnings live in a different code path than the warning banner; user has to scroll to see them.

#### Recommended remediation

- `/security-audit-function decision` — full audit with approval gate (D-HIGH XSS findings)
- `/fix-notices decision` — migrate `.addNotice` to `jmvcore::Notice` directly
- `/review-function decision` — validate CI methods and post-test probability direction
- `/prepare-translation decision`

---

### decisioncalculator

**Status:** ⚠️ NEEDS WORK (calculator with strongest notice discipline; only i18n missing)
**Files:** [`R/decisioncalculator.b.R`](R/decisioncalculator.b.R) · [`jamovi/decisioncalculator.a.yaml`](jamovi/decisioncalculator.a.yaml) · [`jamovi/decisioncalculator.u.yaml`](jamovi/decisioncalculator.u.yaml) · [`jamovi/decisioncalculator.r.yaml`](jamovi/decisioncalculator.r.yaml)
**Metrics:** .b.R LOC 1,314 · options 24 · outputs 58 (5 Html, 7 Table, 1 Image) · setContent 23 · NoticeType **17** · `.()` wraps 0

#### Security

*No findings.* Calculator pattern — only numeric inputs, no `self$data`. All `setContent` use static HTML strings or notice-template strings with no user-derived names.

#### jmvcore migration

*No high-priority opportunities.*

#### Integration

**Arguments declared:** 24  ·  **used:** 24  ·  **dead:** 0
**Outputs declared:** 58  ·  **populated:** 39 setter calls.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Invalid input (negative / non-finite / zero counts) | ERROR | ✅ | ✅ | Excellent — 17 distinct `Notice` paths covering all edge cases. |
| Haldane–Anscombe continuity correction applied | INFO/WARNING | ✅ | ✅ | Surfaces correction when zero cells. |
| Extreme prevalence | STRONG_WARNING | ⚠ | ❌ | Not explicit — relies on the user to set a sensible prior. |
| epiR availability | ERROR | ✅ | ✅ | Excellent. |

#### Code review

- **Overall quality:** 4.5/5 — exemplary notice coverage; serves as the **reference implementation** for the rest of the module.
- **Architecture:** Clean, parameter-driven; uses `notice$setContent(...)` style consistently.
- **Mathematical/statistical correctness:** Bayes update with prevalence is standard; CIs via `epiR::epi.tests`. Looks correct but **needs `/review-function decisioncalculator`** to confirm post-test probability with prior-overrides.
- **Clinical readiness:** READY (pending i18n).
- **i18n coverage:** NONE — strings hardcoded English (despite excellent notices).

**Top issues:**

1. Zero `.()` wrapping — all 17 notice contents and 23 setContent calls render English only.
2. CI behavior when `prevalence` overridden vs sampled is correctly handled with notices, but no methodology INFO summary at end of run.

#### Recommended remediation

- `/prepare-translation decisioncalculator` — high priority since notices are well-structured (translation-ready content)
- `/review-function decisioncalculator` — confirm Bayes prior override math

---

### decisioncombine

**Status:** ⚠️ NEEDS WORK
**Files:** [`R/decisioncombine.b.R`](R/decisioncombine.b.R) · [`jamovi/decisioncombine.a.yaml`](jamovi/decisioncombine.a.yaml) · [`jamovi/decisioncombine.u.yaml`](jamovi/decisioncombine.u.yaml) · [`jamovi/decisioncombine.r.yaml`](jamovi/decisioncombine.r.yaml)
**Metrics:** .b.R LOC 1,156 · options 40 (4 Variable, 2 List, 8 Bool, 0 Number) · outputs 72 (1 Html, 11 Table, 4 Image) · setContent 2 · NoticeType **0** · `.()` wraps 0

#### Security

*No findings in standard profile.* The function builds notices as HTML via its own `.addNotice`/`.renderNotices` pattern (lines 22–57). Variable names are escaped through `.escapeVariableNames` (line 59) — backtick-style escape for special chars.

#### jmvcore migration

- **[error]** ~5 `stop("...")` calls in helpers — should use `jmvcore::reject` for jamovi-UI-friendly errors.
- **[term]** `.escapeVariableNames` (line 59) is functionally equivalent to `jmvcore::composeTerm` for single-token escape; swap for jmvcore.

#### Integration

**Arguments declared:** 40  ·  **used:** ~38  ·  **dead:** 0
**Outputs declared:** 72  ·  **populated:** 21 setter calls. A 72→21 ratio is **OUTPUT-OVERDECLARATION** — many outputs are placeholder or pattern-specific.

#### Notices coverage

Uses its own `.addNotice` / `.renderNotices` pattern instead of `jmvcore::Notice` (lines 22–57). Functionally similar (ERROR/STRONG_WARNING/WARNING/INFO types) but **doesn't integrate with jamovi's native notice surface** — they render as a custom HTML block.

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing inputs (gold + at least 2 tests) | ERROR | ✅ | ✅ | Via custom `.addNotice`. |
| Pattern-not-found (test results don't match expected levels) | WARNING | ✅ | ✅ | |
| Low cell counts in a pattern | STRONG_WARNING | ⚠ | ❌ | Not quantified — vague language. |
| Methodology summary | INFO | ❌ | — | None. |

#### Code review

- **Overall quality:** 3.5/5
- **Architecture:** Custom notice system parallels `jmvcore::Notice` — consolidate to one.
- **Mathematical/statistical correctness:** Standard cross-tab × pattern enumeration. Looks correct — needs `/review-function decisioncombine`.
- **Clinical readiness:** NEEDS_VALIDATION
- **i18n coverage:** NONE.

**Top issues:**

1. Two notice systems coexist. Pick `jmvcore::Notice`.
2. 72 declared outputs vs 21 setters — many outputs are placeholder tables for patterns that may not exist in user data.
3. No i18n.

#### Recommended remediation

- `/fix-notices decisioncombine` — migrate custom notice system to `jmvcore::Notice`
- `/check-function-full decisioncombine` — verify which outputs are populated for typical 2-test and 3-test scenarios
- `/prepare-translation decisioncombine`

---

### decisioncompare

**Status:** ⚠️ NEEDS WORK (1 HIGH security finding)
**Files:** [`R/decisioncompare.b.R`](R/decisioncompare.b.R) · [`jamovi/decisioncompare.a.yaml`](jamovi/decisioncompare.a.yaml) · [`jamovi/decisioncompare.u.yaml`](jamovi/decisioncompare.u.yaml) · [`jamovi/decisioncompare.r.yaml`](jamovi/decisioncompare.r.yaml)
**Metrics:** .b.R LOC 2,135 · options 21 (4 Variable, 0 List, 11 Bool, 1 Number) · outputs 61 (7 Html, 9 Table, 2 Image) · setContent 8 · NoticeType **0** · `.()` wraps 26

#### Security

- **[D-HIGH]** [`R/decisioncompare.b.R:1602-1617`](R/decisioncompare.b.R#L1602-L1617) (.generateMethodsSection): `test_names <- names(test_results)` → `paste(test_names, collapse = ", ")` → `sprintf("...%s tests (%s)...", n_tests, <names>, ...)` → returned as `methods_section` → interpolated into `report_html` at [`R/decisioncompare.b.R:1570`](R/decisioncompare.b.R#L1570) → `self$results$clinicalReport$setContent(report_html)` at [`R/decisioncompare.b.R:1581`](R/decisioncompare.b.R#L1581). Test names come from user `Variable`-type options. Not wrapped through `private$.safeHtmlOutput` (line 196).
- **[D-HIGH (continued)]** [`R/decisioncompare.b.R:1620-1648`](R/decisioncompare.b.R#L1620-L1648) (.generateResultsSection): `best_test` (a column name) used unescaped in `sprintf("...%s demonstrated optimal...", best_test, ...)` → into `report_html`.
- **[D-MEDIUM]** [`R/decisioncompare.b.R:67`](R/decisioncompare.b.R#L67) — `.assertLevelExists` builds error notice via `paste0('The positive level "', level, '" was not found in ', label, '. … Available levels: ', paste(levels(x), collapse = ", "))` and stores in the custom notice content. `level` is user `Level`-type option and `levels(x)` come from data — both flow into notice HTML. The notice system applies `.safeHtmlOutput` to title and content separately, **but** at [`R/decisioncompare.b.R:184`](R/decisioncompare.b.R#L184) only the title/content fields are escaped — internal level strings inside `content` are passed already-baked. Currently MEDIUM because the inner content is escaped on render — verify.

#### jmvcore migration

- **[error]** Several `stop("Validation failed", call. = FALSE)` paths after a notice insert — these mostly work but could use `jmvcore::reject` for the user-facing case.
- **[term]** Custom `.escapeVar` (line 35) does `make.names(gsub(...))` — different semantics from `jmvcore::composeTerm`. Acceptable since used only for table rowKeys, but document the divergence.

#### Integration

**Arguments declared:** 21  ·  **used:** 21  ·  **dead:** 0
**Outputs declared:** 61  ·  **populated:** 23 setter calls; many `show*` flags gate specific outputs.

#### Notices coverage

Custom `.addNotice`/`.renderNotices` (lines 35–192) parallels `jmvcore::Notice`. Coverage is reasonable for missing levels, but no STRONG_WARNING for assumption violations (independence, paired-sample structure for McNemar).

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing positive level | ERROR | ✅ | ✅ | Custom notice. |
| Invalid positive level (not in factor) | ERROR | ✅ | ✅ | Custom notice. |
| Small cell counts for McNemar | STRONG_WARNING | ❌ | — | |
| Methodology summary | INFO | ❌ | — | |

#### Code review

- **Overall quality:** 3.5/5
- **Architecture:** Two notice surfaces (custom HTML + jmvcore) — pick one.
- **Mathematical/statistical correctness:** McNemar comparison is standard; difference-CIs use exact methods. Needs `/review-function decisioncompare` for sample-size warnings on McNemar.
- **Clinical readiness:** NEEDS_VALIDATION.
- **i18n coverage:** PARTIAL — 26 `.()` wraps; HTML report templates mostly English.

**Top issues:**

1. **D-HIGH XSS** — `test_names` flow into HTML report unescaped ([R/decisioncompare.b.R:1607](R/decisioncompare.b.R#L1607) and [:1626](R/decisioncompare.b.R#L1626)).
2. Custom notice system; no McNemar-specific assumption warning.
3. i18n half-done.

#### Recommended remediation

- `/security-audit-function decisioncompare` — full audit with approval gate
- `/fix-notices decisioncompare` — consolidate to `jmvcore::Notice`
- `/review-function decisioncompare` — McNemar small-n + paired-CI checks
- `/prepare-translation decisioncompare`

---

### enhancedROC

**Status:** ⚠️ NEEDS WORK (large; no security HIGH but many notice gaps)
**Files:** [`R/enhancedROC.b.R`](R/enhancedROC.b.R) · [`jamovi/enhancedROC.a.yaml`](jamovi/enhancedROC.a.yaml) · [`jamovi/enhancedROC.u.yaml`](jamovi/enhancedROC.u.yaml) · [`jamovi/enhancedROC.r.yaml`](jamovi/enhancedROC.r.yaml)
**Metrics:** .b.R LOC 4,212 · options 83 (2 Variable, 13 List, 53 Bool, 11 Number) · outputs 173 (6 Html, 20 Table, 11 Image) · setContent 25 · NoticeType **0** · `.()` wraps 143

#### Security

- **[D-MEDIUM]** [`R/enhancedROC.b.R:336`](R/enhancedROC.b.R#L336) — `paste0("...<p>", private$.safeHtmlOutput(paste(validation_result$errors, collapse = "; ")), "</p>")` — `validation_result$errors` are internal messages that may interpolate variable names. Escape is applied at the right boundary, so MEDIUM only because the upstream messages should themselves be escaped at construction time.
- *No HIGH findings.* The function uses `.safeHtmlOutput` for available levels at line 530 — exemplary.

#### jmvcore migration

- **[error]** `jmvcore::reject` used in some places, but also bare `stop()` in helpers (~3 places).

#### Integration

**Arguments declared:** 83  ·  **used:** ~80  ·  **dead:** 0
**Outputs declared:** 173  ·  **populated:** 60 setter calls. Ratio 173→60 — **OUTPUT-OVERDECLARATION** — many `clinicalPreset` and `meta-analysis` outputs only populated under specific flag combinations.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ⚠ | ✅ | Via `jmvcore::reject` (not `Notice ERROR`) — works but no banner. |
| Invalid positive class | ERROR | ⚠ | ✅ | Currently surfaces as HTML in `instructions` output. Should be a banner ERROR. |
| AUC < 0.5 (worse than chance) | ERROR | ❌ | — | **Missing** — clinical safety check. |
| AUC < 0.7 (poor discrimination) | STRONG_WARNING | ❌ | — | **Missing** — clinical interpretation guard. |
| Methodology summary | INFO | ❌ | — | None. |

#### Code review

- **Overall quality:** 4/5 — comprehensive ROC suite (DeLong, bootstrap CIs, Youden, cost-effective cutoffs, meta-analysis). `.safeHtmlOutput` is consistently used in the few HTML-interpolation paths.
- **Architecture:** Clean. Best `.()` coverage in the module (143 wraps).
- **Mathematical/statistical correctness:** NOT_EVALUATED — wraps `pROC::roc`, `pROC::ci.auc`, `cutpointr`. Needs `/review-function enhancedROC` for DeLong-vs-bootstrap CI parity and meta-analysis (`metafor`?) correctness.
- **Clinical readiness:** NEEDS_VALIDATION — missing AUC threshold guards (< 0.5 / < 0.7) are a clinical-safety gap.
- **i18n coverage:** PARTIAL — 143 wraps, but no `.po` catalog exists so renders English.

**Top issues:**

1. Missing clinical AUC threshold notices (< 0.5 = ERROR, < 0.7 = STRONG_WARNING).
2. 173 declared outputs vs 60 setters; verify each `clinicalPreset` / `metaAnalysis` flag toggles the right output.
3. No `.po` catalog — `.()` wraps are dormant.

#### Recommended remediation

- `/fix-notices enhancedROC` — add AUC threshold notices + convert `reject` to top-banner ERROR notices
- `/check-function-full enhancedROC` — verify output population for each preset flag
- `/review-function enhancedROC` — DeLong / bootstrap parity, meta-analysis correctness
- `/prepare-translation enhancedROC` — wraps exist; bootstrap `jamovi/i18n/`

---

### kappasizeci

**Status:** ⚠️ NEEDS WORK (calculator; sample-size only)
**Files:** [`R/kappasizeci.b.R`](R/kappasizeci.b.R) · [`jamovi/kappasizeci.a.yaml`](jamovi/kappasizeci.a.yaml) · [`jamovi/kappasizeci.u.yaml`](jamovi/kappasizeci.u.yaml) · [`jamovi/kappasizeci.r.yaml`](jamovi/kappasizeci.r.yaml) · [`jamovi/js/kappasizeci.js`](jamovi/js/kappasizeci.js)
**Metrics:** .b.R LOC 393 · options 10 · outputs 3 (all Preformatted) · setContent 8 · NoticeType **0** · `.()` wraps 0

#### Security

*No findings.* Output type is `Preformatted` for all 3 results (jamovi escapes content), and `props` is a free-text `String` field that gets coerced via `as.numeric` before display — non-numeric tokens become NA and don't reach HTML. The string itself is also displayed in `text2` (study explanation) but as `Preformatted`, so any `<script>…</script>` user input would render as literal text, not script.

#### jmvcore migration

- **[error]** [`R/kappasizeci.b.R:349`](R/kappasizeci.b.R#L349) — already uses `jmvcore::reject(error_msg, code='validation_failed')` — good.

#### Integration

**Arguments declared:** 10  ·  **used:** 10  ·  **dead:** 0
**Outputs declared:** 3  ·  **populated:** 8 setter calls (multiple branches set the same 3 outputs).

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Invalid kappa/CI range | ERROR | ⚠ | ✅ | `jmvcore::reject` (top-level error) — works, no banner. |
| Sample size unfeasible | WARNING | ❌ | — | |
| Methodology summary | INFO | ❌ | — | |

#### Code review

- **Overall quality:** 3.5/5 — well-structured calculator with input validation.
- **Architecture:** No `.init`; only `.run` and `.validateInputs` helpers. Cache pattern (`prepared_params`, `cached_result`) for performance — solid for a calculator.
- **Mathematical/statistical correctness:** Wraps `kappaSize::*` functions directly. Correct as long as upstream package is correct.
- **Clinical readiness:** READY pending i18n.
- **i18n coverage:** NONE.

**Top issues:**

1. Free-text `props` requires comma-separated numbers — no live validation of format (only on `.run()`).
2. No i18n.
3. Methodology INFO summary absent.

#### Recommended remediation

- `/fix-notices kappasizeci` — add INFO methodology summary
- `/prepare-translation kappasizeci`

---

### kappasizefixedn

**Status:** ⚠️ NEEDS WORK (calculator)
**Files:** [`R/kappasizefixedn.b.R`](R/kappasizefixedn.b.R) · [`jamovi/kappasizefixedn.a.yaml`](jamovi/kappasizefixedn.a.yaml) · [`jamovi/kappasizefixedn.u.yaml`](jamovi/kappasizefixedn.u.yaml) · [`jamovi/kappasizefixedn.r.yaml`](jamovi/kappasizefixedn.r.yaml) · [`jamovi/js/kappasizefixedn.js`](jamovi/js/kappasizefixedn.js)
**Metrics:** .b.R LOC 146 · options 6 · outputs 3 (all Preformatted) · setContent 9 · NoticeType **0** · `.()` wraps 0

#### Security

*No findings.* Same pattern as `kappasizeci` — Preformatted outputs.

#### jmvcore migration

- **[error]** Bare `stop()` in input validation paths — replace with `jmvcore::reject`.

#### Integration

**Arguments declared:** 6  ·  **used:** 6  ·  **dead:** 0
**Outputs declared:** 3  ·  **populated:** 9 setter calls (multiple outcome branches).
No `.init` method (lightweight calculator — acceptable).

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Invalid input range | ERROR | ❌ | — | Only `min`/`max` in `.a.yaml`; no runtime guard for `props` malformed. |
| Methodology summary | INFO | ❌ | — | |

#### Code review

- **Overall quality:** 3/5 — short and clear, but no notices at all.
- **Architecture:** Single `.run` with branch per `outcome`. Code duplication across outcome branches — extract helper.
- **Mathematical/statistical correctness:** Wraps `kappaSize::FixedNBinary/3Cats/4Cats/5Cats`. Correct if upstream is.
- **Clinical readiness:** READY pending notices + i18n.
- **i18n coverage:** NONE.

**Top issues:**

1. Code duplication across 4 outcome branches (each `if (outcome == "N") { kappaSize::FixedNNCats(...) ; ... }`).
2. No notices for invalid props.
3. No i18n.

#### Recommended remediation

- `/fix-notices kappasizefixedn` — add ERROR for malformed `props`, INFO summary
- `/jamovify-function kappasizefixedn --pattern=error --apply` — stop → reject
- `/prepare-translation kappasizefixedn`

---

### kappasizepower

**Status:** ⚠️ NEEDS WORK (calculator)
**Files:** [`R/kappasizepower.b.R`](R/kappasizepower.b.R) · [`jamovi/kappasizepower.a.yaml`](jamovi/kappasizepower.a.yaml) · [`jamovi/kappasizepower.u.yaml`](jamovi/kappasizepower.u.yaml) · [`jamovi/kappasizepower.r.yaml`](jamovi/kappasizepower.r.yaml) · [`jamovi/js/kappasizepower.js`](jamovi/js/kappasizepower.js)
**Metrics:** .b.R LOC 168 · options 7 · outputs 3 (all Preformatted) · setContent 9 · NoticeType **0** · `.()` wraps 0

#### Security

*No findings.* Same Preformatted-output pattern.

#### jmvcore migration / Integration / Notices

Same as `kappasizefixedn`. Code duplication across 4 outcome branches; zero notices; zero i18n.

#### Code review

- **Overall quality:** 3/5
- **Architecture:** Identical pattern to `kappasizefixedn` — opportunity to share a helper between the three kappa-size functions.
- **Mathematical/statistical correctness:** Wraps `kappaSize::PowerBinary/3Cats/4Cats/5Cats`. Correct if upstream is.
- **Clinical readiness:** READY pending notices + i18n.
- **i18n coverage:** NONE.

**Top issues:** same as kappasizefixedn.

#### Recommended remediation

- `/fix-notices kappasizepower`
- `/jamovify-function kappasizepower --pattern=error --apply`
- `/prepare-translation kappasizepower`

---

### nogoldstandard

**Status:** ⚠️ NEEDS WORK (1 HIGH security finding)
**Files:** [`R/nogoldstandard.b.R`](R/nogoldstandard.b.R) · [`jamovi/nogoldstandard.a.yaml`](jamovi/nogoldstandard.a.yaml) · [`jamovi/nogoldstandard.u.yaml`](jamovi/nogoldstandard.u.yaml) · [`jamovi/nogoldstandard.r.yaml`](jamovi/nogoldstandard.r.yaml)
**Metrics:** .b.R LOC 1,630 · options 22 (5 Variable, 2 List, 2 Bool, 2 Number) · outputs 31 (3 Html, 5 Table, 2 Image) · setContent 4 · NoticeType **8** · `.()` wraps 95

#### Security

- **[C1-HIGH]** [`R/nogoldstandard.b.R:642`](R/nogoldstandard.b.R#L642) — `f <- stats::as.formula(paste("cbind(", paste(escaped_var_names, collapse=","), ")~1"))` for LCA. `escaped_var_names` is built by the local `.escapeVariableNames` helper at line 8, which wraps names containing `[^a-zA-Z0-9._]` in backticks. The escape regex covers the usual special chars, but **(a)** a column literally named `` ` `` (backtick) is not handled — the wrapper would produce `` `na`me`backtick` `` which closes the backtick early; **(b)** there is no parse-time allow-list guard à la `jmvcore::asFormula(...)`. Even though `poLCA::poLCA` doesn't evaluate arbitrary RHS, the formula goes through R's parser, so a malicious column name could in principle smuggle a side effect through `cbind(<bad>) ~ 1`. Recommend `jmvcore::composeTerms()` + `jmvcore::asFormula(...)` for proper defense-in-depth.
- *No HIGH XSS findings* — function uses notices and structured tables, not bespoke HTML.

#### jmvcore migration

- **[formula]** [`R/nogoldstandard.b.R:642`](R/nogoldstandard.b.R#L642) — replace `stats::as.formula(paste(...))` with `jmvcore::asFormula(paste0("cbind(", jmvcore::composeTerms(list(var_names_split_by_token)), ")~1"))`. Drops the local `.escapeVariableNames` helper.
- **[na]** Several `na.omit(...)` calls on jamovi-attributed frames — switch to `jmvcore::naOmit`.

#### Integration

**Arguments declared:** 22  ·  **used:** 22  ·  **dead:** 0
**Outputs declared:** 31  ·  **populated:** 11 setter calls. Ratio 31→11 — many bootstrap outputs gated by bootstrap flag.

#### Notices coverage

Uses `private$.addNotice` (similar to `decision`) with 8 notice paths.

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required tests | ERROR | ✅ | ✅ | |
| `poLCA` not installed | ERROR | ✅ | ✅ | Surfaced as `stop(.("Package 'poLCA' is required..."))` at line 624 — convert to `jmvcore::reject`. |
| LCA non-convergence | STRONG_WARNING | ⚠ | ❌ | Implicit (best_model = NULL) — should surface a notice. |
| Insufficient sample / extreme prevalence | STRONG_WARNING | ❌ | — | |
| Methodology summary | INFO | ⚠ | — | Some explanatory HTML, no INFO notice. |

#### Code review

- **Overall quality:** 4/5
- **Architecture:** Clean. Has its own `.addNotice`/`.renderNotices` (lines 22–57) and HTML escape helper for variable names.
- **Mathematical/statistical correctness:** LCA via `poLCA`, Bayesian via `runjags`/`R2jags`, composite reference — sophisticated. Needs `/review-function nogoldstandard` to validate the Hui-Walter and Joseph-Gyorkos implementations match canonical references.
- **Clinical readiness:** NEEDS_VALIDATION — small-sample LCA convergence is fragile; convergence-warning notice missing.
- **i18n coverage:** PARTIAL — 95 `.()` wraps, no `.po` catalog.

**Top issues:**

1. **C1-HIGH formula injection corner** — backtick-in-column-name not handled; no `jmvcore::asFormula` allow-list.
2. LCA convergence failures silently produce poor results — add STRONG_WARNING notice.
3. Custom notice system parallels `jmvcore::Notice`.

#### Recommended remediation

- `/security-audit-function nogoldstandard` — full audit with approval gate for the formula construction
- `/jamovify-function nogoldstandard --pattern=formula,na,error --apply` — bulk jmvcore swap
- `/fix-notices nogoldstandard` — add LCA-convergence + small-n notices; consolidate notice system
- `/review-function nogoldstandard` — Hui-Walter / Joseph-Gyorkos parity
- `/prepare-translation nogoldstandard`

---

### psychopdaROC

**Status:** ⚠️ NEEDS WORK (largest after agreement)
**Files:** [`R/psychopdaROC.b.R`](R/psychopdaROC.b.R) · [`jamovi/psychopdaROC.a.yaml`](jamovi/psychopdaROC.a.yaml) · [`jamovi/psychopdaROC.u.yaml`](jamovi/psychopdaROC.u.yaml) · [`jamovi/psychopdaROC.r.yaml`](jamovi/psychopdaROC.r.yaml)
**Metrics:** .b.R LOC 5,601 · options 138 (3 Variable, 12 List, 36 Bool, 19 Number) · outputs 158 (7 Html, 18 Table, 12 Image) · setContent 19 · NoticeType **0** · `.()` wraps 26

#### Security

- **[D-MEDIUM]** [`R/psychopdaROC.b.R:358-384`](R/psychopdaROC.b.R#L358-L384) — `setContent(paste0(...self$options$method..., self$options$metric...))` — both options are `List` (closed enum), so values come from a known whitelist. LOW source, MEDIUM only because future authors may add free-text options into the same template.
- **[D-MEDIUM]** [`R/psychopdaROC.b.R:1876`](R/psychopdaROC.b.R#L1876) — `setContent(paste("<b>Error:</b>", val))` — `val` is the output of `private$.validateInputs()`, which is an internal-constructed error message. The message itself doesn't appear to interpolate user input directly, but the closure should still escape.
- *No HIGH findings.*

#### jmvcore migration

- **[error]** Mix of `jmvcore::reject` (good) and bare `stop()`/`message()`/`warning()` paths.
- **[error]** [`R/psychopdaROC.b.R:1592`](R/psychopdaROC.b.R#L1592) — `jmvcore::reject(paste("Reference ref must be one of the markers (1...", nauc, " in this case)", sep = ""))` — wrap in `.()` for i18n and consider `jmvcore::format("...{}...", nauc)`.

#### Integration

**Arguments declared:** 138  ·  **used:** ~135  ·  **dead:** 0
**Outputs declared:** 158  ·  **populated:** 59 setter calls. **OUTPUT-OVERDECLARATION** — many DeLong, IDI/NRI, meta-analysis, cost-effective cutoff outputs are gated by specific flag combinations.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ⚠ | ✅ | Via `jmvcore::reject` (not a banner notice). |
| AUC < 0.5 (worse than chance) | ERROR | ❌ | — | **Missing**. |
| AUC < 0.7 (poor) | STRONG_WARNING | ❌ | — | **Missing** — `.detectInverted` does flip but doesn't surface a notice. |
| Small n / events | STRONG_WARNING | ❌ | — | |
| DeLong sample size warning | STRONG_WARNING | ❌ | — | |
| Methodology summary | INFO | ❌ | — | |

#### Code review

- **Overall quality:** 3.5/5 — sweeping ROC suite; large surface; comprehensive.
- **Architecture:** Helpers extracted; private `.utility` file used. 5,601 LOC is on the edge of unmaintainable.
- **Mathematical/statistical correctness:** NOT_EVALUATED — wraps `pROC::roc`, `pROC::roc.test`, `cutpointr::cutpointr`, `metafor::rma`, IDI/NRI via private helpers. Needs `/review-function psychopdaROC` and direct comparison with `pROC` and `cutpointr` reference values.
- **Clinical readiness:** NEEDS_VALIDATION — major gap is missing AUC threshold notices.
- **i18n coverage:** PARTIAL — 26 wraps in 5,601 lines; majority of strings hardcoded.

**Top issues:**

1. No clinical AUC thresholds as notices (< 0.5 / < 0.7).
2. 158 outputs vs 59 setters; verify each preset combination.
3. i18n is < 1% coverage.

#### Recommended remediation

- `/fix-notices psychopdaROC` — add AUC/n-thresholds, methodology INFO summary, convert `reject` to banner notices
- `/check-function-full psychopdaROC` — verify output population per preset
- `/review-function psychopdaROC` — DeLong / IDI / NRI / meta-analysis parity
- `/prepare-translation psychopdaROC`

---

### sequentialtests

**Status:** ✅ READY (only i18n pending)
**Files:** [`R/sequentialtests.b.R`](R/sequentialtests.b.R) · [`jamovi/sequentialtests.a.yaml`](jamovi/sequentialtests.a.yaml) · [`jamovi/sequentialtests.u.yaml`](jamovi/sequentialtests.u.yaml) · [`jamovi/sequentialtests.r.yaml`](jamovi/sequentialtests.r.yaml) · [`jamovi/js/sequentialtests.events.js`](jamovi/js/sequentialtests.events.js)
**Metrics:** .b.R LOC 1,710 · options 24 · outputs 44 (5 Html, 4 Table, 5 Image) · setContent 29 · NoticeType **24** · `.()` wraps 0

#### Security

*No findings.* Calculator-style (no `self$data`); HTML content built from numeric parameters with safe formatting. The setContent at [`R/sequentialtests.b.R:862`](R/sequentialtests.b.R#L862) concatenates internal-built HTML only.

#### jmvcore migration

*No high-priority opportunities.*

#### Integration

**Arguments declared:** 24  ·  **used:** 24  ·  **dead:** 0
**Outputs declared:** 44  ·  **populated:** 50 setter calls (multiple branches set the same outputs) — **OUTPUT-FULLY-COVERED**.

#### Notices coverage

**Exemplary** — 24 `NoticeType$*` uses covering low-performance tests, extreme prevalence, near-perfect performance, strategy mismatch with test characteristics, etc. This is the **module-wide reference implementation** for notice coverage.

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Low test sensitivity/specificity | STRONG_WARNING | ✅ | ✅ | Quantified with actual values. |
| Extreme prevalence (low/high) | STRONG_WARNING | ✅ | ✅ | |
| Near-perfect performance (>99%) | WARNING | ✅ | ✅ | |
| Similar test names (likely correlated) | STRONG_WARNING | ✅ | ✅ | Independence assumption violation. |
| Wrong-direction test for strategy | STRONG_WARNING | ✅ | ✅ | Sequence-specific guidance. |
| Methodology summary | INFO | ⚠ | — | Independence note in HTML body; could also be top INFO notice. |

#### Code review

- **Overall quality:** 4.5/5 — best-engineered function in the module.
- **Architecture:** Clean, calculator pattern with thorough validation.
- **Mathematical/statistical correctness:** Serial-positive / serial-negative / parallel testing math is standard; independence assumption surfaced clearly. Needs `/review-function sequentialtests` for one last check on parallel-test combined PPV formula.
- **Clinical readiness:** READY (notice coverage + independence guidance is best in class).
- **i18n coverage:** NONE — zero `.()` wraps.

**Top issues:**

1. No i18n — surprising given the otherwise exemplary quality.
2. Methodology INFO summary buried in HTML; not a top banner.
3. No `/review-function` validation yet for parallel-test combined PPV.

#### Recommended remediation

- `/prepare-translation sequentialtests` — wrap user-visible strings with `.()`
- `/review-function sequentialtests` — final math check; could be the reference function after
- *(Notice work: none required.)*

---

## Cross-Cutting Issues

### D-HIGH/MEDIUM — HTML XSS via variable names in setContent — 3 functions

Variable names (column names from user data, source: `type: Variable` options) flow into HTML output via `sprintf`/`paste0` then `setContent` without `htmlEscape`. The module has a `private$.safeHtmlOutput` helper in `decision`, `decisioncompare`, and `enhancedROC` but it is applied only to notice title/content, not to the larger HTML report bodies (`clinicalReport`, `naturalLanguageSummary`, `reportTemplate`).

**Affected functions:** `decision`, `decisioncompare`, `nogoldstandard` (indirectly — formula side).

**Reference fix pattern:** [`R/enhancedROC.b.R:530`](R/enhancedROC.b.R#L530) — `private$.safeHtmlOutput(positive_class)` wraps the user-derived class label before interpolation.

**Run per function:** `/security-audit-function <name>`

### C1-HIGH — Formula construction without allow-list guard — 1 function

`stats::as.formula(paste(...))` with a hand-rolled backtick escaper (not `jmvcore::composeTerm`) and no `jmvcore::asFormula` parse-time defense.

**Affected functions:** `nogoldstandard`

**Reference fix pattern:** Use `jmvcore::asFormula(paste0("cbind(", jmvcore::composeTerms(list_of_terms), ")~1"))`.

**Run per function:** `/jamovify-function nogoldstandard --pattern=formula --apply`, then `/security-audit-function nogoldstandard`

### NOTICES — Zero or stub notice coverage — 10 functions

Functions either have **no** `jmvcore::Notice` usage (relying on `setNote` on tables or `jmvcore::reject` for fatal errors) or implement **custom** `.addNotice`/`.renderNotices` helpers that parallel `jmvcore::Notice`. Two parallel notice surfaces (custom + jmvcore) coexist in `decision`, `decisioncompare`, `decisioncombine`, and `nogoldstandard`.

**Affected functions:** `agreement` (0 jmvcore notices, multiple `setNote("error", …)`), `cotest` (0), `decision` (custom), `decisioncombine` (custom), `decisioncompare` (custom), `enhancedROC` (0), `kappasize*` (3 × 0), `psychopdaROC` (0), `nogoldstandard` (custom).

**Reference fix pattern:** `decisioncalculator.b.R` (17 `jmvcore::Notice` uses) and `sequentialtests.b.R` (24 `jmvcore::Notice` uses).

**Run per function:** `/fix-notices <name>`

### i18n — Module-wide internationalization absent — 13 functions

No `jamovi/i18n/` directory, no `.po` or `.pot` translation catalogs, no `NAMESPACE` `importFrom(jmvcore, .)` (relies on `import(jmvcore)`). Even where `.()` is used (e.g. `enhancedROC` has 143 wraps), no extraction catalog exists. 7 of 13 functions have zero wraps.

**Affected functions:** all 13.

**Run per function:** `/prepare-translation <name>` — then bootstrap `jamovi/i18n/{catalog.pot,en.po,tr.po}`.

### jmvcore-MIGRATION — Bare `stop()` and `na.omit()` in user-facing paths — 8 functions

31 bare `stop()` calls in `.b.R` (only 16 use `jmvcore::reject`). 8 `na.omit()` calls on data frames that carry jamovi attributes (column `measureType`, `values`). Bare `stop()` doesn't render nicely in the jamovi UI and bare `na.omit()` drops attributes.

**Affected functions:** `agreement`, `decisioncombine`, `decisioncompare`, `kappasizefixedn`, `kappasizepower`, `nogoldstandard`, `psychopdaROC`, `sequentialtests` (minor).

**Reference fix pattern:** `psychopdaROC.b.R:1555-1569` already uses `jmvcore::reject(.("..."))` cleanly.

**Run per function:** `/jamovify-function <name> --pattern=error,na --apply`

### OUTPUT-OVERDECLARATION — Declared outputs > setters by 2× or more — 5 functions

| Function | Outputs declared | Setter calls | Ratio |
|---|---|---|---|
| `agreement` | 396 | 131 | 3.0× |
| `enhancedROC` | 173 | 60 | 2.9× |
| `psychopdaROC` | 158 | 59 | 2.7× |
| `decisioncombine` | 72 | 21 | 3.4× |
| `decision` | 68 | 32 | 2.1× |

Many outputs are conditionally populated via `setVisible` flags. Users toggling unfamiliar flag combinations may see empty result panels. **Run `/check-function-full <name>` per function to verify each flag toggles the right output.**

### TESTING — 11 of 13 functions lack regression tests

Only `tests/testthat/test-decision.R` (271 LOC) and `tests/testthat/test-roc.R` (42 LOC) exist. No tests for `agreement`, `cotest`, `decisioncalculator`, `decisioncombine`, `decisioncompare`, `enhancedROC`, `kappasizeci`, `kappasizefixedn`, `kappasizepower`, `nogoldstandard`, `sequentialtests`. (Note: `test-roc.R` likely covers `psychopdaROC`/`enhancedROC` partially — needs confirmation via `/check-function-full`.)

---

## Remediation Playbook

**Priority 1 — HIGH security findings (run these first; one approval gate per function):**

- `/security-audit-function decision` — D-HIGH XSS in natural-language summary + report template
- `/security-audit-function decisioncompare` — D-HIGH XSS in clinical report (methods/results sections)
- `/security-audit-function nogoldstandard` — C1-HIGH formula injection corner

**Priority 2 — Critical statistical/clinical issues:**

- `/fix-notices enhancedROC` — add AUC < 0.5 ERROR and AUC < 0.7 STRONG_WARNING (clinical safety)
- `/fix-notices psychopdaROC` — same AUC thresholds + DeLong sample-size warning
- `/fix-notices nogoldstandard` — LCA-convergence STRONG_WARNING; small-n warning
- `/review-function agreement` — kappa/ICC/Krippendorff/Gwet parity against `irr`/`psych`/`irrCAC`
- `/review-function psychopdaROC` — DeLong/IDI/NRI/meta-analysis parity
- `/review-function decision`, `/review-function decisioncompare` — CI/McNemar parity

**Priority 3 — Module-wide hygiene:**

- jmvcore migration: `/jamovify-function <name> --pattern=error,na --apply` for 8 functions
- Notices coverage: `/fix-notices <name>` for the 10 functions in the cross-cutting "NOTICES" issue
- i18n: bootstrap `jamovi/i18n/` (en.po, tr.po, catalog.pot), then `/prepare-translation <name>` per function (priority order: `enhancedROC`, `nogoldstandard`, `decision` first — already have 143/95/91 wraps)

**Priority 4 — Placeholders to triage:**

- *None.* All 13 functions use `self$options` actively. The calculator-style ones (`cotest`, `decisioncalculator`, `kappasize*`, `sequentialtests`) do not use `self$data` by design.

**Priority 5 — Test coverage:**

- Add `tests/testthat/test-<name>.R` for the 11 missing functions. Reference: `test-decision.R` already provides utility-function unit tests + integration tests against `histopathology` example data.

**Priority 6 — Architecture:**

- Consider splitting `agreement.b.R` (10,559 LOC) into per-method files. The monolith works but is hard to navigate and review.

---

## Appendix: Guides Referenced

- `references/security-patterns.md` — D-category HTML XSS, C-category formula construction
- `references/jmvcore-migration.md` — formula, na, error groups
- `references/integration-checks.md` — output-population matrix, placeholder detection
- `references/notices-checklist.md` — clinical thresholds (AUC, prevalence, events), positioning policy
- `references/code-review-checks.md` — 8 areas incl. i18n setup, content quality

*Note: `deep` profile would additionally consult `guides/jamovi_module_patterns_guide.md`, `guides/jamovi_plots_guide.md`, `guides/jamovi_notices_guide.md`, `guides/jamovi_i18n_guide.md`. Re-run with `--profile deep` for guide cross-referencing per function.*

---

*Generated by the `audit-module` skill. Re-run with `--profile deep` for R6/R-package hygiene checks and vignette cross-references, or `--functions a,b,c` for a targeted re-audit.*
