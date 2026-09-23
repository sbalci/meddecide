# Module Audit Report — meddecide 1.0.83.02

**Audited:** 2026-09-22 23:44
**Profile:** standard
**Analyses:** 14  ·  READY 4  ·  NEEDS WORK 10  ·  PLACEHOLDER 0  ·  MISSING 0  ·  ORPHANED 0
**Security findings:** HIGH 0  ·  MEDIUM 0  ·  LOW 21
**Skill:** audit-module

> **Which tree was audited.** Every `file:line` reference below points at the **umbrella source**
> (`ClinicoPathJamoviModule`), which is one day ahead of the generated sibling. Fourteen files differ
> between the two; see [M1](#m1--the-generated-submodule-is-stale-medium). Line numbers for
> `cotest`, `decisioncalculator`, `enhancedROC`, `kappaSizeCI`, `kappaSizeFixedN`, `kappaSizePower`,
> `nogoldstandard` and `sequentialtests` will not match the copies currently in this repository until
> it is regenerated. Module-wide gates (`release_gate.py`, `check_state_guards.py`,
> `theme_safe_html.py`, DESCRIPTION / NAMESPACE / `00refs.yaml`) were run against **this**
> repository, because it owns those files.

---

## Executive Dashboard

| Analysis | Status | HIGH | MED | LOW | Integration | Notices | i18n | Statistics | Clinical |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|---|---|
| [`cotest`](#cotest) | ✅ | 0 | 0 | 2 | ✅ | ✅ | partial | Correct | Ready |
| [`decision`](#decision) | ⚠️ | 0 | 0 | 2 | ⚠ | ⚠ | partial | Minor Issues | Ready |
| [`decisioncalculator`](#decisioncalculator) | ⚠️ | 0 | 0 | 1 | ⚠ | ✅ | OK | Minor Issues | Ready |
| [`decisioncombine`](#decisioncombine) | ⚠️ | 0 | 0 | 0 | ⚠ | ⚠ | partial | Correct | Needs Validation |
| [`decisioncompare`](#decisioncompare) | ⚠️ | 0 | 0 | 2 | ⚠ | ⚠ | partial | Minor Issues | Ready |
| [`decisioncurve`](#decisioncurve) | ⚠️ | 0 | 0 | 3 | ⚠ | ⚠ | partial | Minor Issues | Ready |
| [`enhancedROC`](#enhancedroc) | ⚠️ | 0 | 0 | 3 | ⚠ | ⚠ | partial | Minor Issues | Needs Validation |
| [`kappaSizeCI`](#kappasizeci) | ✅ | 0 | 0 | 2 | ✅ | ⚠ | partial | Correct | Ready |
| [`kappaSizeFixedN`](#kappasizefixedn) | ⚠️ | 0 | 0 | 1 | ✅ | ⚠ | partial | Correct | Ready |
| [`kappaSizePower`](#kappasizepower) | ✅ | 0 | 0 | 0 | ✅ | ✅ | partial | Correct | Ready |
| [`lassologistic`](#lassologistic) | ⚠️ | 0 | 0 | 0 | ✅ | ⚠ | OK | Minor Issues | Needs Validation |
| [`nogoldstandard`](#nogoldstandard) | ⚠️ | 0 | 0 | 2 | ⚠ | ⚠ | partial | Minor Issues | Needs Validation |
| [`psychopdaROC`](#psychopdaroc) | ⚠️ | 0 | 0 | 2 | ⚠ | ⚠ | partial | Minor Issues | Needs Validation |
| [`sequentialtests`](#sequentialtests) | ✅ | 0 | 0 | 1 | ⚠ | ⚠ | partial | Correct | Ready |

**Release gates (module-wide):**

| Gate | Verdict |
|---|---|
| `Version` >= 1.0.0 | **PASS** — 1.0.83.02 |
| HIGH security findings | **PASS** — 0 across 35,670 lines of backend |
| Broken / mis-cased / empty citations | **PASS** — 53 defined, 53 cited, 0 dangling |
| Named HTML symbol entities in R output | **PASS** — 0 |
| Declared-but-unused `Imports` | **FAIL** — 6 (`DescTools`, `irrCAC`, `lme4`, `lmerTest`, `psych`, `vcd`) |
| Orphaned non-analysis source files | **PASS** — 0 files; 5 unreachable functions inside a used file |
| Analyses with `clearWith` gaps | 6 of 14 |
| Analyses with UI label-convention deviations | 10 of 14 |
| Generated submodule in sync with umbrella | **FAIL** — 14 files behind |

**Top cross-cutting issues:**

1. **Incomplete Turkish catalog — 12 of 14.** Source-side `.()` wrapping is good to excellent; the catalog is not.
2. **Bare-identifier `.a.yaml` `title:` values — 10 of 14.** `kappa0`, `raters`, `alpha` reach `man/*.Rd` and jamovi syntax mode.
3. **Safety notices reachable only through jamovi's HTML panels, never its error state — 6 of 14.**
4. **`.run()` past 900 lines — 8 of 14**, up to 1,710.
5. **Clinical guards gated behind default-off display checkboxes — confirmed in 2, candidate in 1.**
6. **`clearWith` omits an option that changes displayed text — 6 of 14.**
7. **Clinical-threshold notices under-graded — 5 of 14** (events < 10 as WARNING, not ERROR).
8. **The retracted "Notice serialization" premise still cited in source comments — 5 files.**
9. **Hardcoded white ggplot backgrounds — 9 sites in 2 analyses**, invisible to `theme_safe_html.py`.
10. **Plots ignore jamovi's global palette — 6 of 11 plot-bearing analyses** never reference `theme$palette`.

---

## Methodology

**Profile:** standard. One subagent per analysis read the full four-file set
(`.b.R`, `.a.yaml`, `.u.yaml`, `.r.yaml`), plus any `jamovi/js/*.events.js` and helper module, and
walked the skill's reference checklists. Module-wide gates ran in the orchestrating context.

**Checks run:**

- [x] Analysis discovery from `jamovi/0000.yaml` + filesystem cross-check
- [x] Drift diff of every audited file, umbrella vs generated sibling
- [x] Security pattern scan, categories A–I
- [x] jmvcore migration scan, 6 pattern groups
- [x] Integration audit — dead options, unpopulated and permanently-invisible outputs, `clearWith` completeness, citation-ref integrity
- [x] Notices coverage against the clinical-threshold checklist
- [x] Code review — architecture, robustness, docs/UX, performance, statistical correctness, clinical readiness, i18n
- [x] Module gates — `release_gate.py`, `check_state_guards.py`, `theme_safe_html.py`, reverse dependency check on `Imports`
- [ ] R6 / R-package per-analysis hygiene *(deep profile only; the module-wide subset was run)*
- [ ] Vignette cross-reference *(deep profile only)*

**Checks skipped:** external documentation comparison; execution / differential runs; `R CMD check`,
`devtools::document()`, `jmvtools::prepare()`.

**Audit-only. No source file was modified.** The only artefact is this report.

---

## Module-Wide Findings

These are properties of the package as a whole, checked in the orchestrating context rather than per analysis.

### M1 — The generated submodule is stale (MEDIUM)

14 shipped files differ between the umbrella source and the generated sibling
`/Users/serdarbalci/Documents/GitHub/meddecide`, with the umbrella roughly one day newer
(umbrella `R/enhancedROC.b.R` 2026-09-22 22:08 vs sibling 2026-09-22 08:50).

| Drifted | Files |
|---|---|
| `.b.R` | `cotest` (8 lines), `decisioncalculator` (11), `enhancedROC` (207), `kappaSizeCI` (13), `kappaSizeFixedN` (26), `kappaSizePower` (53), `nogoldstandard` (12), `sequentialtests` (44) |
| `.a.yaml` | `decisioncalculator` (31), `decisioncombine` (2), `enhancedROC` (23), `lassologistic` (2), `sequentialtests` (22) |
| `.r.yaml` | `enhancedROC` (2) |
| helper | `R/enhancedROC-errors.R` |

This matters beyond tidiness: **the release gate's two advisory warnings are both artefacts of the
stale copy.** `python3 tools/release_gate.py --root ../meddecide` reports 5 analyses whose
`description: main:` resolves with interior newlines and therefore breaks the jamovi library
listing. Resolving the YAML against the umbrella gives **0 newlines for all 14 analyses** — the
`main: |` blocks were already converted to folded `main: >` upstream. Audited against the sibling
alone, five phantom defects would have been filed.

`R/agreement.b.R` and `R/agreement.h.R` are also deleted in the sibling's working tree but not
committed, following `agreement`'s move to `menuGroup: meddecideT` (JamoviTest).

**Action:** `Rscript _updateModules.R --dry-run`, then regenerate `meddecide`, then re-run the gate.
Until then, treat the sibling's gate output as provisional. See `reference_stale_generated_module_masquerades_as_bug`.

### M2 — Six DESCRIPTION Imports are now unused (LOW, library-acceptance item)

`DescTools`, `irrCAC`, `lme4`, `lmerTest`, `psych`, `vcd` are declared in `Imports:` and tagged in
`R/zzz_imports.R`, but no shipped code calls any of them. All six were `agreement.b.R`'s
dependencies and were orphaned when that analysis moved to `menuGroup: meddecideT`. The lone
surviving `vcd::` string in the module is inside a **comment** at `R/nogoldstandard.b.R:2382`, which
is why the parse-based check correctly counts it as unused.

jamovi installs `Imports:` for every user, so this currently pulls `lme4` and `lmerTest` — both
heavy, with compiled dependencies — onto every install for nothing.

**Action:** drop the six from `Imports:` and their tags from `R/zzz_imports.R`, and add them to
`prune_imports` in the umbrella registry. Note the standing caution in `CLAUDE.md`: `prune_imports`
is a delete order that has shipped broken code before (pruning `magrittr` from OncoPath left
`waterfall` unable to run), so confirm with `--dry-run`, which re-derives every entry at plan time.

### M3 — NEWS.md trails DESCRIPTION by a wide margin (LOW)

`DESCRIPTION` / `jamovi/0000.yaml` / `CITATION.cff` agree on `1.0.83.02` (2026-09-22). The newest
`NEWS.md` entry is `meddecide 1.0.6.03 (2026-08-22)`. The release gate does not fail this because a
four-part version is treated as a dev build that publishes nothing, but a user reading NEWS.md sees
a month-old changelog.

### M4 — Dead helper surface (LOW)

`R/enhancedROC-errors.R` defines 12 top-level functions; **5 have zero callers anywhere in the
package**: `safe_execute`, `get_error_summary`, `clear_error_log`, `get_clinical_context`,
`create_enhanced_result`. The file ships for the four that `enhancedROC` does use
(`clinicopath_init`, `clinicopath_error_handler`, `clinicopath_warning_handler`,
`validate_clinical_data`).

Informational, by contrast: `.stripPrefix` (`R/utils.R`), `.escapeVariableNames` and
`.asSurvivalFormula` (`R/utils-formula.R`) also have no caller in this module, but helpers ship at
**file** granularity and their file-mates (`.fmt`, `.quietly`, `.stripBackticks`) are used. That is
the documented design, not a defect — though a survival-formula helper in a medical-decision module
is a sign the file was copied wholesale.

### M5 — Local build clutter, not committed (INFO)

`meddecide_1.0.0.tar.gz` and a full `build/R4.6.0-arm64-macos/` R library tree sit in the working
directory. Both are covered by `.gitignore` (`/*.tar.gz`, `build`) and `git ls-files` confirms
neither is tracked, so this is not the "committed build artifacts" finding the library reviewer
raises elsewhere — just local disk use.

### Module-wide checks that passed

Run against the sibling with `python3 tools/release_gate.py`, `tools/check_state_guards.py` and
`tools/theme_safe_html.py`, plus direct scans of the umbrella source:

| Check | Result |
|---|---|
| `Version` >= 1.0.0 (library-acceptance gate) | **PASS** — 1.0.83.02, consistent across DESCRIPTION / 0000.yaml / CITATION.cff |
| Citations | 53 defined, 53 cited, 0 dangling, 0 missing `url`, 0 missing author/year |
| Unguarded `image$state` reads | 0 |
| Opaque light-theme HTML backgrounds | 0 |
| Malformed `format:` tokens | 0 |
| Fabricated statistics | 0 methods |
| Heavy `setState()` payloads | 0 sites |
| Non-structural named HTML entities | 0 |
| `.()` separator / padding / `" [..]"` truncation / braced `\u{}` | 0 each |
| i18n catalog scope | 4,005 msgids, 0 belonging to another module |
| Translation format specifiers | 0 mismatched |
| `CollapseBox` Title Case | 0 off-convention |
| Bare `set.seed()` | 0 |
| `library()` / `require()` in backends | 0 |
| `inherit = <name>Base` | 14 / 14 |
| Bare `warning()` for user-relevant conditions | 0 |
| Action-verb / Title-Case UI labels | 0 (the single grep hit, `Plot Style`, is a noun phrase) |
| `compilerMode: tame` | present on 14 / 14 `.u.yaml` |
| jamovi 28.3 features vs `minApp` | 0 `File`/`Text`/vector images; `minApp 2.7.27` — no gate risk |
| Sentinel `$insert()` past end of group | 0 |
| Dangling `clearWith` entries / unresolved `renderFun` | 0 |
| `requiresData` contract | 0 missing, 0 surplus |
| Committed build artifacts | 0 tracked |
| Bug-report URL | 1 distinct repository |

### Seed discipline — a module strength

The house rule is that a seed-dependent result needs a user-visible seed option *and* the seed
printed beside the result whenever the random part ran. **All five analyses with a stochastic path
satisfy both halves:**

| Analysis | Seed option | Applied via | Reported to user |
|---|---|---|---|
| `decisioncurve` | `seed` | explicit, with a `42` fallback | `.("Random seed: {seed}")` at `R/decisioncurve.b.R#L2617` |
| `enhancedROC` | `seed` | guarded read at `#L370` | four `setNote("seed", ...)` sites, gated on bootstrap actually running |
| `lassologistic` | `random_seed` | `withr::local_seed()` at `R/lassologistic.b.R#L229` | `#L2090`, plus a row in the reproducibility table at `#L999` |
| `nogoldstandard` | `seed` | `private$.seedValue()` | `#L705`, `#L713`, `#L760`, gated on bootstrap or latent-class |
| `psychopdaROC` | `seed` | `withr::local_seed()` at `R/psychopdaROC.b.R#L2369` | `#L1577`, `#L3561`, `#L3636`, `#L3801`, gated per table |

No analysis calls a bare `set.seed()` that the user cannot see. `lassologistic` additionally draws
**stratified** CV folds (`#L800-807`) rather than letting `cv.glmnet` pick its own, which is the
right choice for imbalanced diagnostic outcomes.

### A caution on automated dead-option counts

A naive scan for `self$options$<name>` reports 27 unreferenced options module-wide. **Essentially all
are false positives, for two separate reasons.**

*Dynamic access.* Five backends (`cotest`, `decisioncombine`, `decisioncompare`, `lassologistic`,
`nogoldstandard`) read options through a computed key. `nogoldstandard` builds its entire test list
with `self$options[[paste0("test", i)]]` at `R/nogoldstandard.b.R#L416-421`, which makes all ten of
its `test1..test5` / `test*Positive` options look dead to a grep while being the analysis's core
inputs.

*Declarative consumption.* The seven remaining candidates are all referenced in the schema — an
option consumed only by a `.r.yaml` `visible: (showX)` binding or a `.u.yaml` `enable:` binding is
correctly wired and the backend never needs to read it:

| Option | `.r.yaml` | `.u.yaml` | `.b.R` | Verdict |
|---|:---:|:---:|:---:|---|
| `decisioncurve` `showPlot` | 1 | 6 | 0 | visibility binding — wired |
| `decisioncurve` `showInterventionAvoided` | 1 | 1 | 0 | visibility binding — wired |
| `decisioncurve` `showStandardizedNetBenefit` | 2 | 1 | 0 | visibility binding — wired |
| `decisioncurve` `showRelativeUtility` | 2 | 1 | 0 | visibility binding — wired |
| `decisioncurve` `comparisonMethod` | 1 | 1 | 0 | **genuinely inert** — a live ComboBox that changes nothing |
| `decisioncalculator` `showWelcome` | 2 | 1 | 0 | visibility binding — wired |
| `enhancedROC` `nntCalculation` | 2 | 1 | 0 | visibility binding — wired |

So the module has **one** confirmed dead option, `decisioncurve`'s `comparisonMethod`: the user can
pick a comparison method and the result does not change. Everything else the grep flagged is sound.
See `feedback_silent_empty_search_r_accessors`.

### A caution on raw grep counts generally

Several counts in this audit's first pass came from `grep -c` over `.b.R` files and did not survive
contact with the source. `kappaSizePower` appeared to have 10 `jmvcore::reject()` calls and 1
`jmvcore::Notice` use; reading it gives **9 rejects and zero Notice uses** — the Notice hit was a
comment. Comments are not code, and neither `grep` nor `ugrep` knows the difference. Counts quoted
in the per-analysis sections below come from reading, not grepping; counts in this module-wide
section are stated only where a parser (PyYAML, `release_gate.py`'s R parser) produced them.

---

## Per-Analysis Sections

### cotest

**Status:** ✅ READY
**Files:** [`R/cotest.b.R`](R/cotest.b.R) · [`jamovi/cotest.a.yaml`](jamovi/cotest.a.yaml) · [`jamovi/cotest.u.yaml`](jamovi/cotest.u.yaml) · [`jamovi/cotest.r.yaml`](jamovi/cotest.r.yaml) · [`jamovi/js/cotest.events.js`](jamovi/js/cotest.events.js)
**Metrics:** .b.R LOC 1333 · options 13 · outputs 8 · UI controls 14 · JS LOC 221

#### Security

- **[D-LOW]** [`R/cotest.b.R:882`](R/cotest.b.R#L882) — free-text `test1_name`/`test2_name` (`type: String`, HIGH-tier source) is interpolated **unescaped** into four `addFootnote()` calls (also `:886`, `:898`, `:902`). Table *cells* are correctly left raw (plain-text renderer, deliberate, documented at `:114-119`), but footnotes/notes go through jamovi's allow-listed HTML renderer (`i em b strong sub sup`), so a name like `Ki-67 <10%` is mangled or partially swallowed. Not script-executable — a rendering-corruption bug. Fix: `private$.escapeHtml()` on the name for footnote text only.
- **[H-LOW]** [`R/cotest.b.R:172`](R/cotest.b.R#L172) — reads jmvcore's private per-option object: `self$options$.__enclos_env__$private[[paste0("..", nm)]]`. A jmvcore rename silently disables the "a worked example replaced your value" warning. The code already guards it and emits a notice on miss (`:173-178`), which is the right mitigation; a `tests/` assertion on the internal path would make the miss a build failure rather than a runtime notice.

Clean on the rest: no `eval`/`parse`/`str2lang`, no `do.call(<var>)`, no formula construction at all, no `system`/`source`/`readRDS`/`download.file`, no `.asSource` override, no debug flag, no `library()`. `jamovi/js/cotest.events.js` has no `innerHTML`/`Function`/string-body timers. HTML panels are theme-safe (rgba tints + `color: inherit`, §4) and notice messages are escaped at render (`:1239`).

#### jmvcore migration

*No migration opportunities found.* No `as.formula`, no `na.omit`, no `as.numeric(factor)`, no user-facing `stop()`. `jmvcore::reject()` is used once (`:486`) and is **not** wrapped in any `tryCatch` — the file contains zero `tryCatch`/`try` calls.

One hygiene note, not a migration: `format(given)` / `format(used)` at [`R/cotest.b.R:204`](R/cotest.b.R#L204) resolve to **`jmvcore::format`**, not `base::format`, because `NAMESPACE:536` carries `import(jmvcore)`. Verified harmless (a numeric with no `...` args is returned unchanged), but the call reads as base R. Qualify it `base::format()` to stop a future `big.mark=`/`nsmall=` argument silently doing nothing.

#### Integration

**Arguments declared:** 13  ·  **used in logic:** 13  ·  **dead:** 0

`showGuidance` is the only option never read in `.b.R` — it is consumed declaratively by `visible: (showGuidance)` on `instructions` and `dependenceExplanation`, so it is **effective, not dead**.

**Outputs declared:** 8  ·  **populated:** 8  ·  **unpopulated:** 0

No permanently-invisible output, no declared-but-never-populated output. `plot1` is `setState`-d only under `if (self$options$fagan)` and is gated `visible: (fagan)` — consistent. `requiresData: false` is **correct**: `.plot1` reads only `image1$state` plus a private constant and calls the file-level `nomogrammer()`; nothing on that path touches `self$data`.

`clearWith` checked and **complete**. `fnote`/`fagan`/`showGuidance` are absent from the two tables' `clearWith`, which normally is the 2b defect — here it is safe and I verified the mechanism rather than assuming: `Table$setRow()` → `setCell()` → `Cell$setValue()` resets `footnotes <- character()`, and every `setRow()` precedes every `addFootnote()` on every path. Unchecking "Detailed footnotes" therefore does remove them, and repeated runs do not accumulate. Locked by [`tests/testthat/test-cotest.R:729`](tests/testthat/test-cotest.R#L729). (That test's comment "neither table declares clearWith" is now stale — both do, `cotest.r.yaml:41` and `:72`.)

**UI/backend agreement.** The `.u.yaml` `enable:` locks use the colon binding grammar (`(preset:custom)`, `(preset:custom && !indep)`) — the `==` trap is documented at `cotest.u.yaml:1-5` and asserted by a test. No `enable:` drift: every control the backend overrides under a preset is disabled while that preset is selected, and a *scripted* call that bypasses the GUI lock gets an explicit "the worked example replaced values you supplied" warning naming each option by its UI title ([`R/cotest.b.R:218-222`](R/cotest.b.R#L218)) — including `indep`, handled without the schema-default test precisely because a `FALSE` default makes half of all deliberate choices look untouched (`:207-217`). The JS preset table is a maintained mirror of `.getPresetValues()` with a field-for-field parity test.

**Citation refs:** all 5 (`ClinicoPathJamoviModule`, `DiagnosticTests`, `ConditionalDependenceDiagnosticTests`, `Fagan1975`, `DeeksAltman2004`) are defined in `jamovi/00refs.yaml` with non-empty author and year, correct case. No USED-but-UNDEFINED, no case mismatch.

**Placeholder assessment:** FUNCTIONAL. Closed-form calculator (`requiresData=FALSE` by design); every displayed number is derived from the options, no `# Placeholder`, no `if (FALSE)` block, no half-wired removed option.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | n/a | n/a | No variables; all 13 options bounded + defaulted, so no unconfigured state exists (§25 satisfied by construction — nothing red on open) |
| Low n / events | STRONG_WARNING | n/a | n/a | No data |
| Assumption violation — rho outside the Fréchet-attainable range | STRONG_WARNING | ✅ | ✅ | `:687` / `:707`, names requested rho, raw joint value and the bound it was truncated to |
| Extreme prevalence (<5% / >95%) | STRONG_WARNING | ✅ | ✅ | `:421-424`; the old guard tested `< 0.001`, the option's own minimum, so it could never fire — fixed and documented |
| Low discriminatory power (Youden < 0.1) | WARNING | ✅ | ✅ | `:411-416`, per test |
| Degenerate likelihood ratio (0 / Inf / undefined) | WARNING | ✅ | ✅ | `:441-460` + a per-row `addFootnote` saying the 0% / 100% is structural, not an estimate (`:866`) |
| Worked example in use | INFO + WARNING | ✅ | ✅ | `:153` every run, plus a `setNote("demo")` on **both** tables so an exported table carries the marker |
| Fagan nomogram not drawable | WARNING | ✅ | ✅ | `:945-961`, four distinct reasons incl. the LR+ == LR- case that used to surface `nomogrammer()`'s raw `stop()` |
| Methodology summary | INFO | ⚠ | — | Carried by the `explanation` / `dependenceInfo` Html panels, not as a single-line banner |

**Structural gap (not a trigger gap):** cotest raises **zero** `jmvcore::Notice` objects. All nine trigger classes above route through one hand-rolled `Html` panel (`.addNotice` → `.displayNotices`, `:1195-1251`). Trigger *coverage* is the best in this module; what is missing is the native half of the project's stated "keep both HTML and Notice" policy — severity never reaches jamovi's notice channel, and the `"error"` level accepted by `.addNotice` has no call site anywhere (dead branch). The panel also renders a titled "Validation Notices" region when there is nothing to say (`setContent("")`, `:1208`); that choice is deliberate and correct — the code explicitly rejects `setVisible(FALSE)` as an error mechanism (§5) and says why at `:1205-1207`. **The domain concern about `setVisible(FALSE)` is already resolved: the file contains no `setVisible` call at all.**

Latent: `jmvcore::reject()` at `:486` fires before `.displayNotices()` and would discard the whole accumulated panel. Unreachable in practice (a NaN/Inf joint probability cannot arise from marginals bounded to 0.01–0.99), so this is a note, not a finding.

#### Code review

- **Overall quality:** 5 stars
- **Architecture:** OK — clean helper split. Only smell: `.run()` is 256 lines ([`R/cotest.b.R:92-347`](R/cotest.b.R#L92)), over the ~200 target, mostly the worked-example override-detection block (`:131-224`) which would lift out as `.applyPreset()` unchanged.
- **Mathematical/statistical correctness:** CORRECT
- **Clinical readiness:** READY
- **i18n coverage:** PARTIAL

**Statistical verification (read carefully, verified analytically — no R run against the analysis):**

- **Conditional-dependence parameterisation is correct.** `p11 = p1·p2 + ρ·√(p1 q1 p2 q2)` (`:674`, `:699`) is exactly the definition of the phi/Pearson correlation for two binary indicators, applied within each disease group with marginals (Sens₁,Sens₂) and (1−Spec₁,1−Spec₂).
- **Fréchet–Hoeffding bounds are the right ones and are correctly applied.** `lower = max(0, p1+p2−1)`, `upper = min(p1,p2)` (`:677-678`, `:702-703`) are the attainable bounds on P(A∩B) given the marginals. Out-of-range ρ is truncated **and the user is told**, in three independent places: a quantified notice naming requested ρ / raw value / bound (`:687`), the "Realized phi" line in the Test Dependence panel (`:760-765`), and a parenthetical in the copy-ready methods sentence, which quotes the **realized** phi rather than the requested one (`:1064-1085`). The `.a.yaml` descriptions warn in advance that the practical ceiling is often ≈0.5. This is the strongest handling of this issue I have seen in the module.
- **Marginals survive truncation.** With `p11` clamped into `[max(0,p1+p2−1), min(p1,p2)]`, `p10 = p1 − p11 ∈ [0,p1]` and `p01 = p2 − p11 ∈ [0,p2]` always, and `p00 = 1 − p1 − p2 + p11 ≥ 0` — so the three `.clampProbability()` calls at `:692`, `:694`, `:712`, `:714` never bite and the entered sensitivities/specificities are reproduced exactly. `.validateJointDistribution()` (`:517`) checks exactly the two invariants that can fail and explicitly documents that the "cells sum to 1" check is vacuous by construction — a level of honesty worth copying elsewhere.
- **Bayes updating is correct on every row.** Post-test odds = pre-test odds × LR, per-cell LRs from the joint cells under dependence and from LR products under independence (`:596-599`). `.oddsToProbability()` handles `Inf → 1` and `NA → NA` rather than collapsing to 0 (`:475-481`). Realized phi is re-derived from the fitted 2×2 with the standard formula (`:748-752`).
- **The parallel ("either positive") rule is coherent with the other four rows.** `P(E+|D) = 1 − P(both−|D)` taken from the **same clamped** joint cells (`:270-271`), not recomputed from the marginals — so the five rows are one distribution.
- **`nomogrammer()` pre-flight is complete.** It rejects LR+ < 1, non-finite LRs, LR− ≤ 0 and LR+ ≈ LR− with a plain-language reason. It does *not* check `nomogrammer`'s remaining stop (`Nlr > 1`), but that is provably unreachable: LR− > 1 ⟹ P(both−|D) > P(both−|¬D) ⟹ P(E+|D) < P(E+|¬D) ⟹ LR+ < 1, which the existing guard already catches. The `warning()` calls inside `nomogrammer`'s back-calculation branch are likewise unreachable for any (LR+ ≥ 1, 0 < LR− ≤ 1) pair.
- **Prevalence edges are safe.** Schema bounds 0.001–0.999 make 0 and 1 unreachable, `OptionNumber$check()` rejects (does not clamp) out-of-range input before `.run()`, and both tails now warn inside the reachable range.
- **Direction of effect is read off the ratio, never asserted** (`:1012-1015`, `:1091-1096`) and `.interpretPLR()` returns "evidence against disease" rather than "no diagnostic value" for LR < 1 (`:1030`) — the transposed-sens/spec case is handled as evidence pointing the other way, with a hint to check for a swap.

**Clinical readiness.** The worked examples are marked DEMONSTRATION ONLY in six places (notice, both table notes, the copy-ready sentence, the plot caption baked into the PNG, the `.a.yaml` description). The absence of confidence intervals is disclosed three times. `indep` defaults to FALSE (the conservative choice) and the tutorial argues explicitly that independence is the assumption requiring justification. Three test files, 100+ assertions, incl. exact-rational hand-calculation oracles in `development-scripts/validate_cotest.R`.

**i18n.** Source-side wrapping is **complete** — every user-facing string is one whole `.()` literal (long panels included, with the documented reason that a msgid cannot be assembled by `paste0`), `sprintf` uses positional `%n$s` throughout, no leading/trailing space or punctuation inside `.()`, no trailing `" [...]"` msgctxt trap, no non-structural named HTML entities (`&apos;` at `:1191` is one of the five structural ones). 126 cotest msgids reach `catalog.pot`/`en.po`/`tr.po`. The gap is the catalog: **108 of 126 (86%) have an empty `msgstr` in `tr.po`**. Two untranslated strings remain in code: the `.clampProbability` `context` labels (`"P(Test1+, Test2+ | Disease+)"`, `:680` etc.) that feed the `reject()` message, and the `scenario_name` labels passed to `.calculateLikelihoodRatio` are translated but positional ("Test 1 Positive LR") so a notice says "Test 1" even when the user named the test "HPV".

**Top issues:**

1. **§26 — the dependence panel is a table rendered as prose.** [`R/cotest.b.R:756-780`](R/cotest.b.R#L756) emits 8 fitted joint probabilities plus 2 realized phi values as `<p>…<br>` lines in an `Html` result. These are computed values, so per §26 they belong in a `Table`: as HTML they ignore the results theme and number format, **Copy** yields markup instead of a grid, there is no Copy-LaTeX, and the row labels cannot be translated independently. A 4-row × 2-column Table (`Test 1 / Test 2` combination × `Disease+ / Disease−`) plus a 2-row phi table, with the explanatory sentence moved to `setNote()`, would preserve every word of the current disclosure.
2. **No `jmvcore::Notice` anywhere** — nine well-designed trigger classes all render through one custom `Html` panel, so severity never reaches jamovi's native notice channel, and `.addNotice(..., "error")` is an implemented-but-unreachable level. The project's standing decision keeps the HTML panel for multi-line content; the native banners should be added *alongside* it (`$add()` for INFO, `insert(1, …)` for ERROR/STRONG_WARNING — never an out-of-range index, §13.3).
3. **`tr.po` is 86% empty for this analysis** (108/126 msgids). The code is fully prepared for translation; only the catalog is behind.
4. **Unverifiable quantitative claim in user-facing prose.** [`R/cotest.b.R:1322-1325`](R/cotest.b.R#L1322) states "Simulation across 400 ordinary clinical parameter sets: this held in 100% of them" and "85%" for the parallel-rule row. The two 100% claims are covered by a 120-set test ([`test-cotest-release-review.R:508`](tests/testthat/test-cotest-release-review.R#L508)); the 85% figure and the 400-set simulation are **not** in the repo. Either archive the script under `development-scripts/` and cite it, or soften the wording to the tested claim.
5. **Minor.** `.run()` at 256 lines (extract `.applyPreset()`); `preset_label <- preset_values$label` runs one line before the `is.null(preset_values)` guard (`:137` vs `:138`) — harmless in R, but reversed order reads correctly; §23 — `.plot1` does not take `theme`, so jamovi's global palette is unreachable for the nomogram (`nomogrammer` pins `"red"`/`"blue"` at `R/utils-nomogrammer.R:388`; arguably a legitimate semantic encoding for the positive/negative pathways, so this is an enhancement rather than a defect); a user-typed test name is silently overwritten when a preset is selected, and the override warning covers the numeric options and `indep` but not the two name fields.

#### Recommended remediation

- `/review-function cotest` — §26: move the 8 joint probabilities + 2 realized phi values out of `dependenceInfo`'s HTML into a `Table` (top issue 1).
- `/fix-notices cotest` — add native `jmvcore::Notice` banners alongside the existing HTML panel for the nine trigger classes; either wire or drop the unused `"error"` level.
- `/prepare-translation cotest` — fill the 108 empty `tr.po` msgstr entries; translate the `.clampProbability` `context` labels.
- `/security-audit-function cotest` — one-line fix only: escape `t1_name`/`t2_name` before the four `addFootnote()` calls at `:882`/`:886`/`:898`/`:902`.
- No `/jamovify-function` needed. No `/check-function-full` needed (not a placeholder; integration is clean).

### decision

**Status:** ⚠️ NEEDS WORK
**Files:** [`R/decision.b.R`](R/decision.b.R) · [`jamovi/decision.a.yaml`](jamovi/decision.a.yaml) · [`jamovi/decision.u.yaml`](jamovi/decision.u.yaml) · [`jamovi/decision.r.yaml`](jamovi/decision.r.yaml)
**Metrics:** .b.R LOC 2577 · options 20 (19 + `data`) · outputs 21 · UI controls 19 · JS LOC 0

#### Security

- **[B-LOW]** [`R/decision.b.R:2251`](R/decision.b.R#L2251) — `get0("nomogrammer", mode = "function", inherits = TRUE)`. The name is a hardcoded literal (no user input), but a package function's enclosing chain reaches `globalenv()`, so a user object named `nomogrammer` shadows the package helper outside the jamovi engine. `nomogrammer` is defined in this package (`R/utils-nomogrammer.R`) — call it directly, or `get0(..., envir = asNamespace("ClinicoPath"), inherits = FALSE)`.
- **[I-LOW]** [`R/decision.b.R:394`](R/decision.b.R#L394), [`R/decision.b.R:1293`](R/decision.b.R#L1293) — working columns are written into the user's frame under fixed names (`original_row_position`, `original_row_index`, `testVariable2`, `goldVariable2`, `classification_group`, `row_id`). A gold/test variable literally named `n` also makes `dplyr::count()` abort ("Column `n` already present in output") — an uncaught red error in `.run()`. Prefix working names (`.cp_row_index`) and pass `name = ".cp_n"` to `count()`.

Scanned clean on A (no `eval`/`parse(text=)`/`str2lang`), C (no `as.formula`/`reformulate` anywhere), E (no `system`/`source`/`download.file`/file I/O), F (no `readRDS`/`load`), G (no `.asSource`), H (no `library()`, no debug flag, no top-level code). **D (XSS) is genuinely clean**: every user-derived string that reaches an `Html` result goes through `private$.safeHtmlOutput()` — notice titles/content ([`R/decision.b.R:203-205`](R/decision.b.R#L203)), variable names in the clinical summary ([`R/decision.b.R:712`](R/decision.b.R#L712)) and the copy-ready report ([`R/decision.b.R:761`](R/decision.b.R#L761)). All other HTML is composed from `.()` literals and `sprintf`'d numbers.

#### jmvcore migration

- **[error]** [`R/decision.b.R:1961`](R/decision.b.R#L1961) — `sprintf(.("Technical details: %s Please report this issue if it persists."), e$message)` → `.fmt(.("Technical details: {msg} Please report this issue if it persists."), msg = e$message)`. Why: this is the only `sprintf`-on-a-translated-template in the file (everything else already uses `.fmt`); a translator who drops `%s` produces `one argument not used by format` — a stray R warning in the Analysis Notes, in the one code path that is already reporting a failure. The Turkish `msgstr` for this id is currently empty, so the defect is latent, not live.

`jmvcore::naOmit` ([L399](R/decision.b.R#L399)), `constructFormula`/`decomposeFormula` ([L264-267](R/decision.b.R#L264)) and `.fmt`/`jmvcore::format` are already used throughout. No `as.formula`, no `na.omit`, no `as.numeric(<factor>)`, no user-facing bare `stop()`. Placeholder names were checked against the `s`/`st`/`str` partial-match trap and the underscore trap — none present; `{sens}`/`{sensnote}` and `{n}`/`{npv}` prefix pairs were verified to interpolate correctly.

#### Integration

**Arguments declared:** 20  ·  **used in logic:** 19  ·  **dead:** 0

Every option is read and branches computation. `data` is implicit. No `NON-EFFECTIVE-CANDIDATE`s.

**Outputs declared:** 21  ·  **populated:** 21  ·  **unpopulated:** 0

All 21 results are populated, including the ones that are commonly missed (`misclassifiedHeading` at [L2418](R/decision.b.R#L2418), `saveClassifications` at [L2405](R/decision.b.R#L2405) with the correct `setRowNums()`-before-`setValues()` order). No permanently-invisible computed output.

**Integration issues:**

| Issue | Where | Notes |
|---|---|---|
| `clearwith-gap` — `fnote` | [`jamovi/decision.r.yaml:373`](jamovi/decision.r.yaml#L373), [`:407`](jamovi/decision.r.yaml#L407) | See the footnote-accumulation defect below — this is the mechanism. |
| `clearwith-gap` — `maxCasesShow` | [`jamovi/decision.r.yaml:561`](jamovi/decision.r.yaml#L561), [`:584`](jamovi/decision.r.yaml#L584) | `fp_table$setNote("truncated", …)` ([L2474](R/decision.b.R#L2474)) is written only when truncation happens and never cleared. Raise the cap from 10 to 500 and the table shows all 100 cases under a note still reading "Showing first 10 of 100". |
| `dead-code-schema` | [`jamovi/decision.r.yaml:41-54`](jamovi/decision.r.yaml#L41), [`:105-131`](jamovi/decision.r.yaml#L105), [`:161-186`](jamovi/decision.r.yaml#L161), [`:295-347`](jamovi/decision.r.yaml#L295), [`:419-435`](jamovi/decision.r.yaml#L419) | ~110 lines of commented-out result declarations (`todo`, `text1`–`text5`, `origTable`, `cTable2`, `nTable2`, `ratioTable2`, `plotcontent`). `ratioTable2` declares `PostTestProbDisease`/`PostTestProbHealthy` columns that the live `ratioTable` no longer has; partially uncommenting it would not match the backend. Delete or finish. |

**Footnote accumulation (the one reproducible user-visible defect).** `epirTable_ratio` / `epirTable_number` rows are scaffolded in `.init()`, and `.init()` runs **once** per analysis instance (`jmvcore::Analysis$init` returns early unless `.status == "none"`), while `.run()` re-runs on every option change. The blanking/fill loops set only `est`/`lower`/`upper`:

```r
self$results$epirTable_ratio$setRow(rowKey = key,
    values = list(est = NA_real_, lower = NA_real_, upper = NA_real_))
```

`jmvcore::Cell$setValue()` resets that cell's `footnotes` — but the `statsnames` cell is never re-set, so `add_ratio_note(key, "statsnames", …)` ([L2134-2137](R/decision.b.R#L2134)) and the `number_notes` loop ([L2173-2176](R/decision.b.R#L2173)) **append the same note again on every re-run** with `ci` + `fnote` on, and the notes **persist after the user unticks `fnote`** (nothing re-sets the cell and `fnote` is in no `clearWith`). `nTable`/`ratioTable` are unaffected — their footnoted columns are all re-set by `setRow()` first. Safest fix: add `statsnames = unname(labels[[key]])` to the two blanking loops at [L1985-1990](R/decision.b.R#L1985) (adding `fnote` to `clearWith` risks wiping the `.init()` scaffold).

**Citation refs: PASS.** All six keys used by `decision.r.yaml` resolve in `jamovi/00refs.yaml` — `ClinicoPathJamoviModule` (:220), `DiagnosticTests` (:436), `Fagan` (:547), `Fagan2` (:566), `epiR` (:2033), `forcats` (:2141). No case mismatch, no option name inside a `refs:` block.

**Renderer data contract: PASS.** `.plot1` ([L2242](R/decision.b.R#L2242)) reads only `image1$state` and `private$` constants — it never touches `self$data`, `.cleandata()` or a refit — so the absence of `requiresData: true` on `plot1` is correct. State is five scalars, so no heavy-`setState`. `is.null(plotData1)` guard present ([L2246](R/decision.b.R#L2246)).

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ⚠️ | — | Handled instead by the `welcome` Html panel + silent `return()` ([L1251](R/decision.b.R#L1251)); defensible and arguably better UX, but there is no ERROR banner. |
| No data / n < 4 | ERROR | ✅ | ✅ | [L224-241](R/decision.b.R#L224) |
| Level not found in data | ERROR | ✅ | ✅ | Lists the available levels ([L283-364](R/decision.b.R#L283)). |
| Ambiguous negative level (3+ levels) | ERROR | ✅ | ✅ | [L475-494](R/decision.b.R#L475) — names the candidate levels. |
| Levels excluded from analysis | WARNING | ✅ | ✅ | [L503-527](R/decision.b.R#L503) |
| Explicit-NA level dropped | WARNING | ✅ | ✅ | [L428-439](R/decision.b.R#L428) |
| Missing-data rows dropped | WARNING | ✅ | ✅ | [L410-418](R/decision.b.R#L410) |
| Low n / events | STRONG_WARNING | ✅ | ✅ | n<20 STRONG_WARNING, <50 WARNING, <100 INFO ([L915-933](R/decision.b.R#L915)); plus a per-arm guard (<10 disease-present or disease-free) at [L950](R/decision.b.R#L950) — the right denominator check, rarely seen. |
| Small cell count (<5) | WARNING | ✅ | ✅ | [L935-941](R/decision.b.R#L935) |
| Zero cell | STRONG_WARNING | ✅ | ❌ | [L577-583](R/decision.b.R#L577) — does not say *which* cell. |
| AUC / discrimination | ERROR + STRONG_WARNING | ✅ | ✅ | [L971-1000](R/decision.b.R#L971): Youden<0 → ERROR, ==0 and AUC<0.7 → STRONG_WARNING. Matches the ROC row of the clinical-threshold table. |
| Prevalence <5% / >95% | STRONG_WARNING | ✅ | ✅ | [L794-811](R/decision.b.R#L794) |
| Methodology summary | INFO | ❌ | — | No bottom INFO stating the estimator/CI method actually used. |

Two structural notes. (1) **Severity is not ordered** — all notices render into one `notices` Html block in insertion order, so `.checkDataSize()`'s "Large dataset" INFO ([L901](R/decision.b.R#L901)) sits *above* `.validateDiscrimination()`'s "performs worse than chance" ERROR ([L978](R/decision.b.R#L978)). Sort `private$.noticeList` by severity in `.renderNotices()`. (2) `.validateDiscrimination()` raises severity `ERROR` for a run that nonetheless completes and fills every table; per the notices policy that is a `STRONG_WARNING`.

Early-return coverage is correct: `on.exit(private$.renderNotices(), add = TRUE)` at [L1248](R/decision.b.R#L1248) means all five early `return()`s still render their notices — the `notice-early-return` trap is already fixed here.

#### Code review

- **Overall quality:** 4 stars
- **Architecture:** OK at the helper level (19 private methods, all defined — no phantom `private$` calls), but `.run()` is **979 lines** ([L1234-2212](R/decision.b.R#L1234)) against a ~200 target. The contingency-table relabelling block ([L1302-1497](R/decision.b.R#L1302)) and the epiR/CI block ([L1976-2180](R/decision.b.R#L1976)) are each self-contained and should be private methods.
- **Mathematical/statistical correctness:** MINOR_ISSUES *(no estimator is wrong — the issues are disclosure)*
- **Clinical readiness:** READY
- **i18n coverage:** PARTIAL (295/315 `catalog.pot` ids for this file carry a Turkish `msgstr`; 20 empty, 0 echoing English, placeholders preserved)

**Domain verification (what was checked hard, and the verdict):**

- **Positive-level wiring — CORRECT.** `goldPositive`/`testPositive` drive the `case_when` recode ([L532-543](R/decision.b.R#L532)); level order is then forced with `factor(x, levels = intersect(c("Positive","Negative"), x))` ([L553-556](R/decision.b.R#L553)), so `conf_table <- table(test, gold)` ([L1516](R/decision.b.R#L1516)) is reliably `[1,1]=TP, [1,2]=FP, [2,1]=FN, [2,2]=TN`. That orientation is also exactly what `epiR::epi.tests()` expects (rows = test, positive first; columns = disease, positive first), so [L2014](R/decision.b.R#L2014) is correct. Downstream slices agree: `.validateSampleSize` reads `sum(conf_table[,1])` as the sensitivity denominator ([L948](R/decision.b.R#L948)) and `.detectMisuse` reads `sum(conf_table[1,])` as the test-positive count ([L813](R/decision.b.R#L813)).
- **`addNA`/explicit-NA counted as negative — ALREADY FIXED, correctly.** `jmvcore::naOmit()` does not drop a factor element sitting on an `addNA()` level (its integer code is not `NA`), so [L427](R/decision.b.R#L427) catches them with `is.na(as.character(x))` and *excludes* rather than pools them, with a WARNING and a re-baselined denominator. This is the known class of bug in this codebase and `decision` is on the right side of it.
- **Level pooling — ALREADY FIXED.** A third level is excluded, never folded into the negative arm ([L449-494](R/decision.b.R#L449)), with an ERROR when the negative level cannot be inferred from a 3+-level variable and a WARNING listing what was dropped.
- **Zero cells / division by zero — CORRECT.** Haldane–Anscombe (+0.5 everywhere) is confined to LR+, LR−, DOR and the Fagan nomogram ([L1522-1527](R/decision.b.R#L1522), [L1728-1748](R/decision.b.R#L1728), [L2194](R/decision.b.R#L2194)); Se/Sp/accuracy/PPV/NPV stay on observed counts, and the mismatch is disclosed in a notice ([L1761](R/decision.b.R#L1761)), a `setNote` on `ratioTable` ([L1837](R/decision.b.R#L1837)) and an appended sentence in the copy-ready report ([L1218-1225](R/decision.b.R#L1218)). No fabricated statistic anywhere — the old `.validateLikelihoodRatios()` that invented `sens/max(1-spec, 0.001)` is deleted and documented as such at [L1750](R/decision.b.R#L1750).
- **Prevalence — CORRECT and well disclosed.** With `pp=TRUE`, PPV/NPV are recomputed by Bayes at the prior ([L1707-1718](R/decision.b.R#L1707), [L1811-1825](R/decision.b.R#L1811)); `AccurT` deliberately stays on the sample; both facts carry unconditional `setNote`s, and the epiR CI pane gets its own note saying its predictive values are at the *sample* prevalence ([L1999-2003](R/decision.b.R#L1999)). The `PrevalenceD` cell showing the prior rather than the sample prevalence is the one thing a hurried reader could still misread, but it is noted.
- **`as.numeric(factor)` off-by-one — NOT PRESENT.** The only `as.numeric` on a non-number is `as.numeric(rownames(mydata2))` ([L2369](R/decision.b.R#L2369)), an unreachable fallback.
- **11 `tryCatch` sites — NONE wraps a `jmvcore::reject()`.** `decision.b.R` calls `reject()` nowhere; validation is done with notice + `return()`. Both `tryCatch`es that guard `private$.checkpoint()` call sites correctly re-raise the restart condition (`if (identical(e$code, "restart")) stop(e)` at [L1957](R/decision.b.R#L1957) and [L2084](R/decision.b.R#L2084)).

**Top issues:**

1. **CI method is disclosed only behind an off-by-default checkbox.** The one statement that the intervals are Clopper–Pearson exact lives in `add_ratio_note("se", "est", …)` at [`R/decision.b.R:2138`](R/decision.b.R#L2138), inside `if (self$options$fnote)`. `fnote` defaults `false`, so a pathologist who ticks "95% confidence intervals" gets two tables of intervals with no stated method — and the LR+/LR−/DOR interval method (epiR's, not exact binomial) is never stated at all. Move both to unconditional `setNote()`s, the same way `sample_accuracy` and `prior_ppv` were already moved for exactly this reason ([L1846-1848](R/decision.b.R#L1846)).
2. **Duplicate, un-clearable footnotes on the two epiR tables** (mechanism and fix in *Integration*, above).
3. **`ci` defaults to `false`** ([`jamovi/decision.a.yaml:160`](jamovi/decision.a.yaml#L160)). For a diagnostic-accuracy tool the default view is point estimates with no uncertainty; the notices only nudge toward the checkbox at n<20 or min-cell<5. Consider `default: true`.
4. **Stale in-code TODO.** [`R/decision.b.R:38-40`](R/decision.b.R#L38) claims "only 2 of [106 strings] are translated in tr.po". Measured today: 315 ids from this file are in `catalog.pot` and 295 have a non-empty Turkish `msgstr`. The comment is wrong by two orders of magnitude and will mislead the next reader — delete it and keep only the list of the 20 that remain (mostly the newest discrimination/continuity/epiR-failure strings).
5. **Minor UI polish.** `.u.yaml` pairs a `Label` with a control that already carries the same `title:` — "Maximum cases to display:" beside `maxCasesShow` ([`jamovi/decision.u.yaml:102-108`](jamovi/decision.u.yaml#L102)) and "Save classification groups (TP/FP/FN/TN) to dataset:" beside `saveClassifications` ([`:112-116`](jamovi/decision.u.yaml#L112)), which renders the label twice. `saveClassifications`' `title: 'Save classifications to data'` also leads with a verb. `ggplot2::geom_line(size = 1.2)` at [`R/decision.b.R:2296`](R/decision.b.R#L2296) uses the argument deprecated in ggplot2 3.4 — use `linewidth` before the deprecation warning reaches Analysis Notes. (`.validatePlotState` at [L2230](R/decision.b.R#L2230) would also throw "missing value where TRUE/FALSE needed" on an `NA` field; unreachable today because the 2×2 structure check guarantees non-NA, but one guard relaxation away.)

**Strengths.** This is among the most carefully hardened analyses in the module: the `on.exit` notice renderer, the no-pooling level policy, the observed-vs-corrected separation with three independent disclosures, the per-arm sample-size guard, the `setRowNums()` before `setValues()` output write, and `.init()`-scaffolded fixed rows are all correct patterns that other meddecide analyses should copy. The inline comments document the *reasoning* behind past fixes rather than just the fix.

#### Recommended remediation

- `/fix-function decision` — clear the `statsnames` footnotes in the two epiR blanking loops; add `maxCasesShow` to the FP/FN tables' `clearWith` (or clear the `"truncated"` note in the non-truncated branch); sort `.noticeList` by severity; `linewidth` for `geom_line`; prefix the working column names and pass `name =` to `dplyr::count()`.
- `/review-function decision` — promote the CI-method statements to unconditional `setNote()`s on both epiR tables (Clopper–Pearson for Se/Sp/PV, epiR's method for LR/DOR); reconsider `ci: default true`; downgrade `.validateDiscrimination()`'s ERROR to STRONG_WARNING; split `.run()` (979 lines) into a contingency-display helper and a CI helper.
- `/jamovify-function decision --pattern=error --apply` — the single `sprintf`-on-a-translated-template at [L1961](R/decision.b.R#L1961) → `.fmt`.
- `/prepare-translation decision` — finish the 20 empty `tr.po` msgstrs and delete the stale TODO at [L38-40](R/decision.b.R#L38).
- Housekeeping (no skill needed): delete the ~110 commented-out result blocks in `decision.r.yaml`.

### decisioncalculator

**Status:** ⚠️ NEEDS WORK
**Files:** [`R/decisioncalculator.b.R`](R/decisioncalculator.b.R) · [`jamovi/decisioncalculator.a.yaml`](jamovi/decisioncalculator.a.yaml) · [`jamovi/decisioncalculator.u.yaml`](jamovi/decisioncalculator.u.yaml) · [`jamovi/decisioncalculator.r.yaml`](jamovi/decisioncalculator.r.yaml)
**Metrics:** .b.R LOC 1503 · options 24 · outputs 15 · UI controls 24 · JS LOC 0

No-variable calculator: the four counts arrive as `type: Number` options, `self$data` is never touched.

#### Security

Categories A–I scanned. No `eval`/`parse`/`str2lang`, no `do.call`/`match.fun`/`get`, no `as.formula`,
no `system`/`source`/`readRDS`/`download.file`, no `library()`, no debug flag, no `jamovi/js/` file,
no `.asSource`/`.sourcifyOption` override, no raw non-ASCII (the one symbol is `×`, L124),
no named HTML symbol entities.

- **[D-LOW]** [`R/decisioncalculator.b.R:174`](R/decisioncalculator.b.R#L174), [`:851`](R/decisioncalculator.b.R#L851), [`:1029`](R/decisioncalculator.b.R#L1029) — the two free-text `String` options (`cutoff1`/`cutoff2`) are the only user-controlled strings in the analysis. Today they reach **only** Table `text` cells and plain-text notice bodies, both non-HTML renderers, so there is no live XSS. Defense-in-depth only: the five `Html` panels (`.createSummary`, `.createAboutPanel`, `.createAssumptionsPanel`, `.createGlossary`, `faganSummary`) currently interpolate **numbers exclusively** — if a scenario name is ever added to one of them, it needs `htmltools::htmlEscape()`.

**HIGH 0 · MEDIUM 0 · LOW 1.**

#### jmvcore migration

*No migration opportunities found.*

`sprintf("%.1f%%", …)` (27 sites) is numeric formatting fed **into** `.fmt()`/`jmvcore::format()`
placeholders, not a message template — correctly not a `jmvcore::format` candidate. No `stop()`,
no `na.omit`, no `as.numeric(factor)`, no manual backtick quoting.

#### Integration

**Arguments declared:** 24  ·  **used in logic:** 24  ·  **dead:** 0

Every option is read and every one changes an output. `showWelcome` is visibility-only
(`welcome` is built unconditionally in `.init()`, gated by `visible: (showWelcome)`) — correct, not dead.

**Outputs declared:** 15  ·  **populated:** 15  ·  **unpopulated:** 0

`clearWith` is **complete**: every result lists exactly the options its value depends on, including
`fnote` on the three footnoted tables and `fagan` on `notices`. No permanently-invisible output.
`format:` tokens are all the single valid token `pc` — no malformed formats.

**Citation refs:** clean. All 10 used keys (`ClinicoPathJamoviModule`, `DiagnosticTests`,
`AltmanBland1994`, `DeeksAltman2004`, `Fagan1975`, `STARD2015`, `Buderer1996`, `HuiWalter1980`,
`epiR`, `Fagan`) are defined in `jamovi/00refs.yaml` with non-empty author and year; no case
mismatch; `Fagan` (the nomogrammer package) and `Fagan1975` (the NEJM paper) are legitimately
distinct, not a duplicate. INFO: 503 defined keys vs ~10 used — shared-file bloat, module-level not
function-level.

| Output | Type | Setter | Populated? | Notes |
|---|---|---|:---:|---|
| `notices` | Preformatted | `setContent` L36/L68 | ✅ | Set to `""` on a clean run, and has `title: Important Information` with no `visible:` gate — an empty titled panel is likely rendered on the default table. |
| `summary`, `about`, `assumptions`, `glossary`, `plot1` | Html/Image | L1049–L1108 | ⚠️ conditionally | All set **after** two `return()`s that can fire on non-fatal conditions — see I1. |

**I1 (MEDIUM) — an invalid *optional* cut-off scenario blanks the primary outputs.**
[`R/decisioncalculator.b.R:876`](R/decisioncalculator.b.R#L876)

```r
if (is.null(cutoff1_metrics) || is.null(cutoff2_metrics)) {
    private$.addNotice("ERROR", .("Cut-off validation failed"), …)
    return()
}
```

`return()` at L878 exits `.run()` before L1044–L1108, so `summary`, `about`, `assumptions`,
`glossary` are never set and `plot1` never receives `setState()` — the Fagan nomogram and every
explanatory panel go blank even though the whole primary analysis (all five tables) already
succeeded. Identical shape at [`:683`](R/decisioncalculator.b.R#L683) when `epiR` is not installed.
Notices themselves survive (`.addNotice` renders eagerly, L32), so the user sees the message but
loses unrelated output. Fix: `multiplecuts` and `ci` are optional branches — skip the branch, don't
return from `.run()`.

**I2 (MEDIUM) — the `epiR` call is unguarded.**
[`R/decisioncalculator.b.R:686`](R/decisioncalculator.b.R#L686)

```r
epirresult2 <- epiR::epi.tests(dat = table3) |> summary() |> as.data.frame() |>
    tibble::rownames_to_column(var = "statsabv")
```

The code carefully anticipates epiR **renaming** its statistics (the `n_filled == 0L` notice at
L749–L757) but not epiR **erroring** or changing the `dat =`/`summary()` contract. Any error here
aborts `.run()` with a raw R error and discards the five already-populated tables. Fix: wrap only
this pipeline in `tryCatch` (no `jmvcore::reject()` is reachable inside it, so this is safe) and
route the failure into the existing notice path.

**I3 (LOW) — the epiR row-key set is defined twice.** `private$.epirRatioStats()` /
`.epirNumberStats()` ([`:94`](R/decisioncalculator.b.R#L94)–[`:100`](R/decisioncalculator.b.R#L100),
used by `.init()` to scaffold rows) duplicate the inline `ratiorows` / `numberrows` literals
([`:694`](R/decisioncalculator.b.R#L694)–[`:702`](R/decisioncalculator.b.R#L702), used by `.run()`
to select them). Drift between the two silently leaves scaffolded rows blank. Call the private
helpers in both places.

**I4 (LOW) — dead defensiveness.** `private$.resultsItem()`
([`:23`](R/decisioncalculator.b.R#L23), used at [`:1116`](R/decisioncalculator.b.R#L1116))
tryCatch-wraps a lookup of `faganSummary`, which **is** declared in `.r.yaml` L313. The comment
explains it as a bridge for a not-yet-compiled item; that bridge is no longer needed.

**Placeholder assessment:** FUNCTIONAL. Real computation throughout, no TODO/FIXME, no
`if (FALSE)` block referencing absent schema. The only dead schema is three commented-out `.r.yaml`
items (`text3`, `text4`, `table1`, L220–L237/L309–L311) — inert YAML comments, harmless.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ✅ | ✅ | Non-finite L223, negative L229, all-zero L235 — all four counts |
| Row/column of zeros (÷0 in sens/spec) | ERROR | ✅ | ✅ | `TP+FN==0` L241, `TN+FP==0` L247 → ERROR + return; `TP+FP==0` L253, `TN+FN==0` L258 → WARNING (PPV/NPV undefined only) |
| Non-integer counts | WARNING | ✅ | ✅ | L342, and CIs are correctly withheld |
| Zero cell / continuity correction | WARNING | ✅ | ✅ | L365, plus a reconciling `setNote` at L763 and a footnote at L613 |
| Extreme prevalence (<5% / >95%) | STRONG_WARNING | ✅ | ✅ | L383, prints the actual percentage |
| Low n / sparse reference groups | STRONG_WARNING | ✅ | ✅ | L394, `DiseaseP < 10 \|\| DiseaseN < 10`, prints both counts |
| Fatal calculation error (epiR absent / unmatched) | ERROR | ✅ | ✅ | L678, L753 |
| LR+ < 1 → nomogram not drawable | WARNING | ✅ | ✅ | L1088, prints LR+; the plot declines via `state$drawable` instead of crashing |
| Cut-off cohorts differ in size | WARNING | ✅ | ✅ | L914, prints all three totals |
| Methodology summary | INFO | ⚠️ partial | — | INFO exists only for the `pp`×`ci` combinations (L206, L215). No general end-of-run methods note, and in particular **no statement of the CI method** (see S1). |

Positioning is safe by construction: there is **no `jmvcore::Notice` object and no `Group$insert()`
anywhere in this file.** The brief's "1 `jmvcore::Notice` use" is a **false positive** — notices are
collected in `private$.noticeList` and rendered as severity-ordered plain text into the single
`Preformatted` item `notices` (L34–L69). No index-safety exposure. Duplicate accumulation is
prevented by resetting `.noticeList` at L186 and re-rendering at L1193.

#### Code review

- **Overall quality:** 4 stars
- **Architecture:** `.run()` is **1010 lines** ([`:185`](R/decisioncalculator.b.R#L185)–[`:1194`](R/decisioncalculator.b.R#L1194)) — well past the ~200-line target. The four HTML panels and the nomogram summary are already private helpers; the cut-off block (L771–L1039, ~270 lines) and the CI block (L665–L768, ~100 lines) should follow. Otherwise correct: fixed rows live in `.init()`, `.run()` only `setRow`s.
- **Mathematical/statistical correctness:** MINOR_ISSUES
- **Clinical readiness:** READY
- **i18n coverage:** COMPLETE

**Domain checks requested — results:**

- **Input validation at the trust boundary: PASS.** `.a.yaml` deliberately gives the four counts no
  `min:` (documented at `.a.yaml` L35–L39) so a negative value reaches `.run()` and gets the clinical
  ERROR notice instead of jmvcore's raw `"TP must be between 0 and Inf"`. Verified in
  `R/decisioncalculator.h.R:40` — `OptionNumber$new("TP", TP)` with no bounds. Non-finite, negative,
  all-zero, and both zero-margin cases are each caught with a distinct, actionable message.
- **LR+ / LR− at spec = 1 or sens = 0: PASS — the user never sees `Inf` or `NaN`.** The
  Haldane-Anscombe 0.5 correction (L359–L366) removes the zero denominator *before* the ratios are
  formed, so the `else Inf` / `else 0` fallbacks at L454/L460 are unreachable in practice; and the
  epiR fill blanks non-finite cells explicitly (`v[!is.finite(v)] <- NA_real_`, L736–L737 — jamovi
  renders an empty cell) with the discrepancy reconciled in a table note (L763). This is the correct
  handling and it is explained to the user, not swallowed.
- **Fagan nomogram / `nomogrammer()`: PASS.** `requiresData: false` (`.r.yaml` L334) is **correct** —
  `.plot1` (L1195–L1245) reads only `image1$state` and calls no `private$` helper that touches
  `self$data`. The state guard is present and correct (`if (is.null(plotData1)) return(FALSE)`,
  L1197) plus a second semantic guard on `state$drawable` (L1200). The state payload is six scalars
  — light. `nomogrammer` resolves from `R/utils-nomogrammer.R:96` and ships to the sibling
  (`../meddecide/R/utils-nomogrammer.R` present); `epiR`, `tibble`, `ggplot2` are all in
  `../meddecide/DESCRIPTION` `Imports`. The three `|>` uses are native R 4.1 — no `%>%`
  bare-symbol exposure. `ggtheme` is applied **before** the palette scale and the blanking
  `theme()` tweaks (L1229–L1241), which is the documented correct order.

**Top issues:**

1. **I1 (MEDIUM)** — [`R/decisioncalculator.b.R:878`](R/decisioncalculator.b.R#L878): `return()` on
   an invalid *optional* cut-off scenario aborts `.run()` and blanks the Fagan nomogram plus all
   four explanatory panels, though the primary analysis succeeded. Same at
   [`:683`](R/decisioncalculator.b.R#L683). Skip the branch instead of returning.
2. **I2 (MEDIUM)** — [`R/decisioncalculator.b.R:686`](R/decisioncalculator.b.R#L686): the
   `epiR::epi.tests()` pipeline is unguarded; any error there discards every already-populated
   table. Wrap only that call.
3. **S1 (MINOR, statistical)** — the confidence-interval **method is never named to the user**.
   `epi.tests()` is called with defaults ([`:686`](R/decisioncalculator.b.R#L686)) — no `method=`,
   no `conf.level=`, and no table note stating whether the proportion intervals are exact
   (Clopper-Pearson) or Wilson. The intervals are correct; they are simply unreportable. Note the
   inconsistency: the *cut-off* accuracy interval **is** named ("Wilson 95% intervals",
   [`:1023`](R/decisioncalculator.b.R#L1023)) and is hand-coded correctly at
   [`:944`](R/decisioncalculator.b.R#L944)–[`:953`](R/decisioncalculator.b.R#L953). Add
   `epirTable_*$setNote()` naming the epiR method, and pass `method=` explicitly so a future epiR
   default change cannot silently alter the intervals.
4. **S2 (LOW, statistical labelling)** — [`R/decisioncalculator.b.R:523`](R/decisioncalculator.b.R#L523):
   the `PrevalenceD` cell is filled with `PriorProb`, i.e. the **user-typed population prevalence**
   when `pp = TRUE`, under the generic column title `Prevalence` (`.r.yaml` L149). The disclosure
   ("The user-supplied population prevalence is used, not the prevalence observed in this sample",
   L577) is inside `if (self$options$fnote)` and `fnote` defaults to `false`. Same asymmetry for
   `AccurT`, which stays sample-based while PPV/NPV are Bayes-adjusted. The INFO notice at L215
   mentions predictive values but not prevalence or accuracy. Either title the column
   conditionally or move the one-line disclosure out of the `fnote` gate.
5. **i18n catalog gaps (LOW)** — all 210 distinct `.()` msgids in the backend are wrapped
   (no unwrapped user-visible literal; the bibliographic `<li>` entries at L1338–L1340 are
   legitimately untranslated). In `jamovi/i18n/tr.po`: 1 msgid absent (the "Evaluates
   diagnostic-test performance…" welcome line, L124) and 6 present with an empty `msgstr` —
   including both epiR-failure messages (L756, L763) and the zero-cell caveats (L1172, L1367).
   No fuzzy entries. Style nit: [`:1018`](R/decisioncalculator.b.R#L1018) and
   [`:1023`](R/decisioncalculator.b.R#L1023) use `jmvcore::.(` while all 208 other sites use bare
   `.()` — both work (`#' @importFrom jmvcore .` is present at L4), but make it uniform so the
   extractor scan stays predictable.

**Strengths.** The zero-cell handling is unusually thorough and honest: the correction is applied,
warned about, footnoted, reconciled between the corrected tables and the uncorrected epiR intervals
(L763), and the Fagan summary is recomputed from the *same* corrected likelihood ratios so the panel
cannot contradict the plot (L1129–L1176). The cut-off comparison refuses to overclaim — it names the
best of all three candidates (not just the first that beats current), quantifies the margin, reports
Wilson accuracy intervals, warns when the three cohorts differ in size, and states plainly that four
summary counts cannot supply paired uncertainty (L1021–L1024). Every table is framed as descriptive
rather than as a clinical threshold. UI labels conform to convention (no leading `Show`/`Enable`
verbs; five `CollapseBox` groups, all `collapsed: true`), and `.u.yaml` `enable:` expressions
(`pprob` on `(pp)`, the scenario groups on `(multiplecuts)`) match the backend gates exactly — no
enable drift.

#### Recommended remediation

- `/fix-function decisioncalculator` — I1 (replace both `return()`s with branch skips), I2 (wrap
  only the `epiR::epi.tests()` pipeline), I3 (call the private key helpers in `.run()`), I4 (drop
  `.resultsItem`), and split the cut-off and CI blocks out of the 1010-line `.run()`.
- `/review-function decisioncalculator` — S1 (name and pin the epiR CI method) and S2 (prevalence /
  accuracy column labelling when `pp = TRUE`).
- `/prepare-translation decisioncalculator` — fill the 1 absent + 6 empty `tr.po` entries; unify
  `jmvcore::.(` → `.()` at L1018/L1023.
- No security action required (HIGH 0 / MEDIUM 0).
- **Do not** action the reported `jmvcore::Notice` / `Group$insert()` concern — this file contains
  no `Notice` object and no `insert()` call at all; refuted above.

### decisioncombine

**Status:** ⚠️ NEEDS WORK
**Files:** [`R/decisioncombine.b.R`](R/decisioncombine.b.R) · [`jamovi/decisioncombine.a.yaml`](jamovi/decisioncombine.a.yaml) · [`jamovi/decisioncombine.u.yaml`](jamovi/decisioncombine.u.yaml) · [`jamovi/decisioncombine.r.yaml`](jamovi/decisioncombine.r.yaml)
**Metrics:** .b.R LOC 2493 · options 20 · outputs 17 top-level (23 elements) · UI controls 18 · JS LOC 0

#### Security

*No findings in profile standard.*

Categories A, B, C, E, F, G, H, I all clean: no `eval`/`parse(text=)`/`str2lang`, no `as.formula`/`reformulate`, no filesystem or process calls, no deserialization, no `library()` in `R/`, no debug flags, no `class(x) == "…"` / non-vectorized `is.null` filters. The single `do.call` is [`R/decisioncombine.b.R:2347`](R/decisioncombine.b.R#L2347) with the literal symbol `rbind` — not user-derived.

**Category D verified complete, not sampled.** There are exactly three HTML sinks — [`R/decisioncombine.b.R:113`](R/decisioncombine.b.R#L113) and [`:189`](R/decisioncombine.b.R#L189) (`notices$setContent`) plus the `about` / `assumptions` pair at the tail of `.renderAboutPanels()`. Every user-derived string (variable names, level labels, duplicated-variable lists, observed gold levels, pattern labels) reaches HTML **only** as a notice `title`/`content`, and both are escaped at the single render boundary [`R/decisioncombine.b.R:179`](R/decisioncombine.b.R#L179)/[`:182`](R/decisioncombine.b.R#L182). The `about`/`assumptions` bodies are built entirely from static `.()` literals passed through a local `esc()` wrapper. Escaping at the sink rather than at each of the ~20 notice call sites is the right design and is what makes 5 `htmlEscape` calls sufficient.

- **[D-INFO]** [`R/decisioncombine.b.R:45`](R/decisioncombine.b.R#L45) — `.panelHtml(title, body)` escapes `title` but injects `body` raw (correct today: both call sites pass statically-built HTML). Worth a one-line comment so a future caller does not pass a variable name through it.

#### jmvcore migration

*No migration opportunities found.*

Already idiomatic: `jmvcore::naOmit()` (not `stats::na.omit`) on the attribute-carrying frames, `jmvcore::htmlEscape()`, `jmvcore::.()` for table notes, `.fmt()` (the repo's `jmvcore::format` wrapper, `R/utils.R:100`) for every interpolated message, `base::format()` qualified against the `jmvcore` mask. No formulas are built, so the formula/term groups do not apply.

#### Integration

**Arguments declared:** 20  ·  **used in logic:** 19  ·  **dead:** 0

| Argument | Type | Default | Used? | In logic? | Notes |
|---|---|---|:---:|:---:|---|
| `addedPattern` | Output | — | ✅ | ✅ | Never read as `self$options$addedPattern`; gated on `self$results$addedPattern$isNotFilled()` ([`:437`](R/decisioncombine.b.R#L437)). Deliberate — an `OptionOutput` resolves the result element's `enabled` state by name and is not a wrapper argument. Not dead. |
| `showRecommendation` | Bool | `false` | ✅ | ✅ | Gates far more than a display table — see Code review #1. |

**Outputs declared:** 17 top-level (23 elements)  ·  **populated:** 17  ·  **unpopulated:** 0

No dead schema and no permanently-invisible computed result. All four `Image`s correctly carry **no** `requiresData:` — traced `.plotBarChart` / `.plotHeatmap` / `.plotForest` / `.plotDecisionTree` through `.applyPatternFilter()` and `.metricLabel()`; neither touches `self$data`. States are small (≤ 11 rows) — no heavy-setState.

| Output | Type | Setter | Populated? | Notes |
|---|---|---|:---:|---|
| `goldFreqTable` | Table | `addRow` | ✅ | Visibility handled **only** declaratively, while its sibling `crossTabTable` gets an imperative reset+show pair. On any `.run()` early return with `showFrequency` ticked, `crossTabTable` hides but `goldFreqTable` renders an empty headered table. Asymmetric — see Code review #3. |
| `notices` | Html | `setContent` | ✅ | `visible: true` unconditionally; `setContent("")` on the empty path leaves a bare "Notices" heading on a freshly added analysis. |

**clearWith:** `notices` lists only the 8 analysis inputs ([`jamovi/decisioncombine.r.yaml:442`](jamovi/decisioncombine.r.yaml#L442)), but its content is produced by `showIndividual` (pairwise-denominator INFO), `showRecommendation` (ranking + inverted-level warnings), `filterPattern` / `showBarPlot` / `showHeatmap` / `showForest` (the "No Rows Match the Pattern Filter" warning) and `filterStatistic` (the "Forest Plot Not Available" INFO). Toggling any of those leaves the panel visibly stale until `.run()` overwrites it. The four plots' `clearWith` are complete; the deliberate omission of both filters from `decisionTreePlot` is documented in-file and correct.

**Citation refs:** all 6 (`ClinicoPathJamoviModule`, `DiagnosticTests`, `wilson1927`, `youden1950`, `haldane1956`, `forcats`) resolve in `jamovi/00refs.yaml` with non-empty author and year. No case mismatches, no option names in `refs:`. Gap, not a breakage: the log-scale LR± interval is Simel/Samsa/Matchar (1991) and the log-DOR SE is Woolf — neither is cited.

**Placeholder assessment:** FUNCTIONAL. No TODO/FIXME, no `if (FALSE)` blocks, no half-wired removed options, no constant-valued setters.

#### Domain checks (combination logic)

- **Pattern enumeration** — `.patternConditions()` ([`:1633`](R/decisioncombine.b.R#L1633)) generates both arities from one definition. Verified by hand for 2 tests (`+/+`, `+/-`, `-/+`, `-/-`) and 3 tests (`+/+/+` … `-/-/-`, test 3 varying fastest): the `expand.grid(rev(cols))` + column-reverse produces exactly binary counting with test 1 most significant, and label position *j* maps to `tests[j]`. Cross-tabulation and the added data column now derive from the same generator, so the three views cannot disagree.
- **Serial / parallel / majority** — Parallel = `|` over all selected tests (believe-the-positive), Serial = `&` (believe-the-negative), Majority = `sum(pos) >= 2` of 3. All three correct for both arities ([`:1660`](R/decisioncombine.b.R#L1660), [`:1686`](R/decisioncombine.b.R#L1686)).
- **Independence** — *not* assumed, and said so in three places: the `joint_estimation` table note, the "What this analysis does NOT assume" panel, and an explicit contrast with the sibling `sequentialtests`. The panel also states the two costs of assumption-free estimation (wider intervals, stronger transport requirement). This is the strongest treatment of the point in the module.
- **Positive-level wiring** — one recode idiom (`case_when(is.na ~ NA; == <level> ~ "Positive"; TRUE ~ "Negative")`) for gold and all three tests, with `factor(levels = c("Positive","Negative"))` so `table()` is unconditionally 2×2 and `[1,1]=TP / [1,2]=FP / [2,1]=FN / [2,2]=TN`. `.analyzeIndividualTest()` uses an `ifelse` of the same shape with the same level order. Consistent — no inversion path. A swapped level is additionally *detected* (see below), but only when the ranking is on.
- **Missing data** — `.normalizeMissing()` ([`:229`](R/decisioncombine.b.R#L229)) converts `addNA()`-style explicit-NA levels back to real `NA` at ingress, which is the fix for the trap where an explicit-NA level survives `naOmit()` and then falls through `case_when`'s `TRUE ~ "Negative"` and is **counted as a negative result**. Combination rows use joint listwise deletion with the dropped count, kept count and percentage reported in a WARNING; individual-test tables use pairwise denominators and disclose them in an INFO. Correct and fully disclosed.
- **`setVisible(FALSE)` — the library-audit HIGH pattern does NOT hold here.** Both sites ([`:313`](R/decisioncombine.b.R#L313) `crossTabTable`, [`:322`](R/decisioncombine.b.R#L322) `recommendationTable`) are *resets* inside `.clearDynamicResults()`, which runs on every `.run()`, and each is paired with a show in its populate path that also runs every `.run()`. Neither signals failure, and no hidden element carries a `setNote()` the user cannot reach (`recommendationTable`'s `scope` note is written immediately before `setVisible(TRUE)`; the `combinationTableCIRatios` note is on an always-visible table). One residual gap: the `combTable$rowCount == 0` early return at [`:1787`](R/decisioncombine.b.R#L1787) hides the table with no notice — unreachable in practice (the exhaustive patterns partition the sample) but the only un-noticed hide.

#### Notices coverage

All notices are rendered as a hand-built `Html` panel; there is **no** `jmvcore::Notice` and no `jmvcore::reject()` anywhere in the file, so jamovi's own analysis error state is never set. Consistent with the project's standing "keep the HTML panel" decision, but this analysis carries only the HTML half. Positioning is sound: `on.exit(private$.renderNotices(), add = TRUE)` at [`:384`](R/decisioncombine.b.R#L384) covers all three early returns, and `.renderNotices()` sorts by severity so STRONG_WARNINGs sit above routine INFOs.

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ❌ | — | Five ERROR branches exist at [`:479`](R/decisioncombine.b.R#L479)–[`:515`](R/decisioncombine.b.R#L515) but are **unreachable** — see Code review #2. |
| Missing positive level (test 2/3) | ERROR | ✅ | ✅ | Reachable; names the test. |
| Duplicate / non-distinct variables | ERROR | ✅ | ✅ | Names the offending variables. |
| Level not present in variable | ERROR | ✅ | ✅ | Names level, variable and role. |
| Low n | STRONG_WARNING / WARNING / INFO | ✅ | ✅ | Graded ladder at n < 20 / < 50 / < 100. |
| Small reference group | STRONG_WARNING | ✅ | ✅ | `min(pos, neg) < 10`, reports both arms. |
| Extreme prevalence (<5% / >95%) | STRONG_WARNING | ✅ | ✅ | House threshold; names the exact denominator used. |
| Sparse 2×2 cells (<5) | STRONG_WARNING | ✅ | ✅ | Scans **all** pattern rows, not just strategies; names the rows and smallest cell. |
| One-class gold standard | STRONG_WARNING | ✅ | ✅ | Branch-specific text; explains why all three ratios are blank. |
| >2 levels folded to negative | STRONG_WARNING | ✅ | ✅ | Per variable; lists the levels being absorbed. |
| Complete-case exclusions | WARNING | ✅ | ✅ | used / total / percent. |
| Continuity correction applied | INFO | ✅ | ✅ | One aggregated banner, names every corrected pattern. |
| **Inverted positive levels** | STRONG_WARNING | ⚠️ | ✅ | Present and well-reasoned, but **only fires when `showRecommendation` is on** (default `false`). |
| **No rule beats chance** | STRONG_WARNING | ⚠️ | ✅ | Same gating. |
| Methodology summary | INFO | ✅ | ✅ | PPV/NPV prevalence dependence; plus two `Html` panels. |

#### Code review

- **Overall quality:** 4.5 stars
- **Architecture:** OK — `.run()` is 75 lines, 30 private helpers, no phantom `private$` method (every `private$.x(` call has a matching definition), no writes to `self$options`, no free-text option used as a regex.
- **Mathematical/statistical correctness:** CORRECT
- **Clinical readiness:** NEEDS_VALIDATION
- **i18n coverage:** PARTIAL

Statistics verified against their references: Wilson score interval ([`:1213`](R/decisioncombine.b.R#L1213)) algebraically correct including the `z` from `qnorm((1+conf)/2)` rather than the literal 1.96; `se(log LR+) = sqrt(1/tp − 1/(tp+fn) + 1/fp − 1/(fp+tn))` and the LR− mirror are Simel's; `se(log DOR) = sqrt(Σ 1/cell)` is Woolf's; Haldane-Anscombe 0.5 is applied to all four cells and **withheld on a structurally empty margin**, with LR−=1 / LR+=1 correctly retained on the two determinate cases and the whole triple blanked on an empty *disease* margin. The `.estimableSe()` guard blanking a zero-SE interval (which would print `LR+ 1.00 [1.00, 1.00]`) is a genuinely subtle catch. Proportions use raw counts while ratios use adjusted counts — unusual, but stated in the `haldane` table note per branch.

**Top issues:**

1. **The inverted-positive-level guard is gated behind an off-by-default display option.** `.populateRecommendation()` is reached only via `if (self$options$showRecommendation)` ([`R/decisioncombine.b.R:427`](R/decisioncombine.b.R#L427)), and `showRecommendation` defaults to `false` ([`jamovi/decisioncombine.a.yaml:196`](jamovi/decisioncombine.a.yaml#L196)). Both "Positive Levels May Be Inverted" ([`:1994`](R/decisioncombine.b.R#L1994)) and "No Rule Performs Better Than Chance" ([`:1871`](R/decisioncombine.b.R#L1871)) live inside it. A swapped `goldPositive` or `test1Positive` is the single failure mode that silently inverts every number in the analysis, and in the default configuration nothing detects it. Move the two detectors into `.analyzeCombinations()` (they need only `combinationTable$asDF`, which is already built) so they fire regardless of the ranking checkbox.
2. **Five ERROR notices are unreachable dead code.** `.run()` calls `.hasRequiredVars()` first and returns silently on `FALSE` ([`:391`](R/decisioncombine.b.R#L391)); that method tests exactly the same five conditions — no data, no `gold`, no `goldPositive`, no `test1`, no `test1Positive` — that `.validateInputs()` then re-tests with an ERROR notice each ([`:479`](R/decisioncombine.b.R#L479), [`:488`](R/decisioncombine.b.R#L488), [`:497`](R/decisioncombine.b.R#L497), [`:506`](R/decisioncombine.b.R#L506), [`:515`](R/decisioncombine.b.R#L515)). The messages can never render, yet all five ship to translators. Net effect: a user who assigns `gold` and `test1` but leaves a positive level unset gets three empty tables and no guidance. This is the exact duplication the author already removed from `.prepareData()` with the comment *"A defensive guard is only defensive if it can fire"* ([`:713`](R/decisioncombine.b.R#L713)) — apply the same reasoning here: either drop the five branches, or have `.hasRequiredVars()` emit them.
3. **`goldFreqTable` visibility is asymmetric with `crossTabTable`.** [`:313`](R/decisioncombine.b.R#L313) resets `crossTabTable` to hidden every run and `.populateFrequencyTables()` turns it back on; `goldFreqTable` relies on the declarative `visible: (showFrequency)` alone. With `showFrequency` ticked and any early return (validation error, no complete cases), the user sees a headered "Gold Standard Frequency Distribution" with zero rows next to a correctly hidden cross-tabulation.
4. **`notices` `clearWith` is narrower than its data dependencies** — see Integration. Add `showIndividual`, `showFrequency`, `showRecommendation`, `showBarPlot`, `showHeatmap`, `showForest`, `filterStatistic`, `filterPattern`.
5. **`.plotDecisionTree` does not drop non-finite rows** ([`:2401`](R/decisioncombine.b.R#L2401)) while `.plotBarChart` does ([`:2172`](R/decisioncombine.b.R#L2172)) precisely to stop ggplot's *"Removed n rows containing missing values"* leaking into Analysis Notes. A pattern with an empty test margin carries `NA` for `sens`/`spec`, so this plot can emit that message. Apply the same `is.finite()` filter. (It also overplots `geom_text` labels at 4–11 points; `ggrepel` is out of scope, `check_overlap = TRUE` is one argument.)
6. **No `private$.checkpoint()`** anywhere — up to 11 pattern analyses plus four plot states run without yielding, so the analysis cannot be cancelled mid-run. Cheap at typical n; add one in the `.analyzeTwoTestPatterns` loop if large datasets are expected.
7. **i18n PARTIAL** — code side is complete (all 35 user-facing strings wrapped, no leading/trailing space or punctuation inside `.()`, `\u{…}` icon escapes correctly kept *outside* `.()`, no unwrapped literals). `jamovi/i18n/tr.po` has 5 empty `msgstr` of 157 entries referencing this file, including both one-class-gold-standard messages, the `haldane` table note and the non-estimable-CI note. No fuzzy entries.
8. **Label convention (minor)** — the gold selector reads "Disease present level" (sentence case) while all three test selectors read "Positive Level" (Title Case) in [`jamovi/decisioncombine.u.yaml`](jamovi/decisioncombine.u.yaml#L31); `filterStatistic`'s first choice is "Default Metric Set". Checkbox labels are all correct noun phrases with no leading verbs, `VariableSupplier` is at the top, and both `CollapseBox`es are `collapsed: true` — the rest of the panel is exemplary.
9. **Test-coverage gap (minor)** — `tests/testthat/test-decisioncombine-release-review.R:822` asserts only the *length* of the `addedPattern` output values. The correctness of `output$setRowNums(rownames(data_prep))` ([`:2041`](R/decisioncombine.b.R#L2041)) under listwise deletion — i.e. that the pattern lands on the right patient after rows are dropped — is not asserted. Add a fixture with missing values and check the written column against the original row indices.

**Strengths:** the `.about` / `assumptions` panels are the best clinical-caveat writing in the module (verification, spectrum and incorporation bias, each with worked numbers); the pattern-row vs strategy-row distinction is explained where a reader will actually hit it; the Haldane-Anscombe sampling-zero vs structural-zero distinction is handled correctly and documented per branch; nearly every non-obvious decision carries a comment naming the defect it fixes.

#### Recommended remediation

- `/fix-notices decisioncombine` — ungate the inverted-level and below-chance STRONG_WARNINGs from `showRecommendation`; delete or relocate the five unreachable ERROR branches in `.validateInputs()`.
- `/check-function-full decisioncombine` — `goldFreqTable` early-return visibility, `notices` `clearWith` completeness, `.plotDecisionTree` NA filtering.
- `/prepare-translation decisioncombine` — 5 empty `tr.po` `msgstr`.
- `/update-refs decisioncombine --validate` — add Simel 1991 (log-LR interval) and Woolf (log-DOR SE); all 6 current refs resolve.
- `/generate-test-data decisioncombine` — regression fixture asserting `addedPattern` row alignment under listwise deletion.

### decisioncompare

**Status:** ⚠️ NEEDS WORK
**Files:** [`R/decisioncompare.b.R`](R/decisioncompare.b.R) · [`jamovi/decisioncompare.a.yaml`](jamovi/decisioncompare.a.yaml) · [`jamovi/decisioncompare.u.yaml`](jamovi/decisioncompare.u.yaml) · [`jamovi/decisioncompare.r.yaml`](jamovi/decisioncompare.r.yaml)
**Metrics:** .b.R LOC 3146 · options 33 (incl. `data`) · outputs 22 · UI controls 24 · JS LOC 0

#### Security

No HIGH or MEDIUM findings. Categories A (eval/parse), B (string-built calls), C (formula construction), E (filesystem/process), F (deserialization), G (codegen), H (hygiene) and I (data integrity) are all clean: zero hits for `eval`/`parse(text=)`/`do.call`/`as.formula`/`system`/`source`/`readRDS`/`library()`/`DEBUG`, and no `.asSource()`/`.sourcifyOption()` overrides. Every user-derived string that reaches an `Html` result is routed through `private$.safeHtmlOutput()`.

- **[D-LOW]** [`R/decisioncompare.b.R:710`](R/decisioncompare.b.R#L710) — `knitr::kable(cross_tab, format = "html", …)` renders user factor-level labels as row/column headers. Safe today only because `escape = TRUE` is kable's default; the caption is escaped explicitly but the table body is not. Pass `escape = TRUE` explicitly so a future kable default change cannot open an XSS hole.
- **[D-LOW]** [`R/decisioncompare.b.R:278-287`](R/decisioncompare.b.R#L278) — `.safeHtmlOutput()` is a hand-rolled escaper rather than `htmltools::htmlEscape()`. It is correct (`&` escaped first, then `<`, `>`, `"`, `'`), but it also rewrites `/` → `&#x2F;`, which is unnecessary and makes the function a second, divergent implementation of an existing utility.

#### jmvcore migration

- **[error]** [`R/decisioncompare.b.R:75`](R/decisioncompare.b.R#L75), [`:91`](R/decisioncompare.b.R#L91), [`:459`](R/decisioncompare.b.R#L459), [`:472`](R/decisioncompare.b.R#L472), [`:480`](R/decisioncompare.b.R#L480), [`:506`](R/decisioncompare.b.R#L506), [`:517`](R/decisioncompare.b.R#L517), [`:527`](R/decisioncompare.b.R#L527), [`:552`](R/decisioncompare.b.R#L552), [`:564`](R/decisioncompare.b.R#L564), [`:582`](R/decisioncompare.b.R#L582), [`:829`](R/decisioncompare.b.R#L829), [`:865`](R/decisioncompare.b.R#L865) — 13 × `stop(jmvcore::.("Validation failed"), call. = FALSE)` in user-facing validation paths → `jmvcore::reject(<the actual message>)`. The red error box a user sees always reads "Validation failed"; the actionable text is only reachable in the `notices` Html panel rendered at the *bottom* of the pane.

  ```r
  stop(jmvcore::.("Validation failed"), call. = FALSE)
  ```

  No `na` / `numeric` / `formula` / `term` / `source` opportunities: available-case handling is deliberate (no `na.omit` on a jamovi frame), there is no `as.numeric(factor)`, and no formulas are built.

  The `.run()` catch-all at [`:324`](R/decisioncompare.b.R#L324) does **not** swallow validation: it re-raises `.checkpoint()` restarts untouched, renders notices, then re-throws. `reject()` would survive it (the handler explicitly documents the `$code == NULL` fall-through). **No `trycatch-swallows-reject` finding.**

#### Integration

**Arguments declared:** 33  ·  **used in logic:** 33  ·  **dead:** 0

Every option is read and every one changes computation. `test1Negative`/`test2Negative`/`test3Negative` are read via `private$.opt(paste0("test", i, "Negative"))` in `.getTestNegatives()` ([`:747`](R/decisioncompare.b.R#L747)); `useOpaCriterion`, `showDescriptiveReport` and `stratify` via `private$.opt()`. No dead options.

**Outputs declared:** 22  ·  **populated:** 22  ·  **unpopulated:** 0

No unpopulated and no permanently-invisible outputs. All three `Image` items correctly omit `requiresData` — `.plot1`, `.plotRadar` and `.plotHeatmap` read only `image$state`, and every helper they call (`.buildBarPlotData`, `.buildRadarPlotData`, `.radarMetricLabels`) operates on that state.

| Item | Type | Issue |
|---|---|---|
| `cTable1`–`cTable3` | Table | `clearWith` omits `fnote`, which gates `addFootnote()` at [`:1102`](R/decisioncompare.b.R#L1102). These rows are scaffolded in `.init()` and never deleted, so turning footnotes off can leave stale footnotes attached. |
| `comparisonTable` | Table | Same: `clearWith` omits `fnote`, which gates the footnote block at [`:1186`](R/decisioncompare.b.R#L1186). (Rows *are* deleted each run here, so the exposure is smaller.) |
| `plotHeatmap` | Image | State is a long data frame of `n_cases × (n_tests + 1)` rows with no cap ([`:2724`](R/decisioncompare.b.R#L2724)). A 10 000-row dataset serializes 40 000 rows into the `.omv` for a plot that is already unreadable at that width. |

**Citation refs:** PASS. All 13 keys used across `.r.yaml` (`ClinicoPathJamoviModule`, `DiagnosticTests`, `epiR`, `forcats`, `knitr`, `mcnemar1947`, `cochran1950`, `holm1979`, `wilson1927`, `newcombe1998paired`, `STARD2015`, `jaeschke1994`, `ggplot2`) resolve in `jamovi/00refs.yaml` with non-empty `author`/`year`. No case mismatches, no option names in `refs:` blocks. Gap: `.proportionCI(method = "exact")` and the epiR CI table use Clopper-Pearson, which has no ref entry.

**`.u.yaml` ↔ backend consistency:** `enable: (!pp)` on `ci` and `enable: (!ci)` on `pp` match the backend "Conflicting Options" guard at [`:517`](R/decisioncompare.b.R#L517); `useOpaCriterion`/`niMargin`/`ciMethod` gate on `opa`; `showSummary`/`showReportSentence` gate on `statComp`, matching `.run()` steps 8a/8b. No `ui-enable-drift`.

**Column formats:** all tokens valid (`pc`, and `zto,pvalue` correctly comma-separated); all column `type:` values lowercase.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ✅ | ✅ | Missing/invalid positive level, duplicate test slots, reference reused as a test, no data, no determinate cases. `.hasRequiredVars()` ([`:427`](R/decisioncompare.b.R#L427)) returns silently when < 2 tests — standard jamovi idiom, but the user gets no hint that two tests are required. |
| Low n / events | STRONG_WARNING | ✅ | ✅ | n < 30 STRONG_WARNING, n < 50 WARNING on the observed reference denominator ([`:643`](R/decisioncompare.b.R#L643)), **plus** a per-test "Sparse Reference-Standard Class" STRONG_WARNING when either gold class < 30 ([`:915`](R/decisioncompare.b.R#L915)). Best-in-module. |
| Assumption violation | STRONG_WARNING | ✅ | ✅ | Extreme prevalence (< 5 % / > 95 %) ([`:662`](R/decisioncompare.b.R#L662)); "Multi-Level Results Combined" when a variable has > 2 levels and exclusion is off ([`:886`](R/decisioncompare.b.R#L886)). |
| Methodology summary | INFO | ✅ | ✅ | Completion notice lists per-test determinate denominators ([`:392`](R/decisioncompare.b.R#L392)). |
| Diagnostic prevalence < 5 % / > 95 % | STRONG_WARNING | ✅ | ✅ | As above. |
| Multiple testing | WARNING | ✅ | ✅ | Holm-Bonferroni applied and disclosed via `setNote` on both tables ([`:1618`](R/decisioncompare.b.R#L1618)); uncomputable pairs are excluded from the family and reported ([`:1594`](R/decisioncompare.b.R#L1594)). Exemplary. |
| Low discordant pairs | STRONG_WARNING | ⚠ | ✅ | Only a **table footnote** at [`:1921`](R/decisioncompare.b.R#L1921), and its threshold (`MIN_DISCORDANT_PAIRS = 10`, [`:28`](R/decisioncompare.b.R#L28)) disagrees with the actual exact-test switch at 25 ([`:1834`](R/decisioncompare.b.R#L1834)) — so 10–24 discordant pairs get exact inference with no visible flag. |
| Sparse / multiplicity in strata | WARNING | ❌ | — | `.populateStratifiedTable()` calls `.calculateDiagnosticMetrics(…, add_notices = FALSE)` ([`:1359`](R/decisioncompare.b.R#L1359)), so *all* per-stratum metric warnings are suppressed, and `stratifiedTable` carries no `notes:` and no `setNote()` about subgroup multiplicity or sparse cells. |

**Positioning:** all notices are aggregated into one `Html` item (`notices`) that is the **last** item in `jamovi/decisioncompare.r.yaml`, so an ERROR or STRONG_WARNING banner renders *below* every table and plot instead of at the top. (Per project policy the HTML notice panel stays; only the ordering is the finding.) Deduplication of identical `(type, title, content)` triples at [`:213`](R/decisioncompare.b.R#L213) correctly prevents the `notice-accumulation` class of bug, and `.run()` resets `private$.noticeList` on every run ([`:302`](R/decisioncompare.b.R#L302)).

#### Code review

- **Overall quality:** 4.5 stars
- **Architecture:** OK — `.run()` is ~125 lines of orchestration; 30+ private helpers; per-run state reset; `.checkpoint()` placed *outside* every `tryCatch` so restarts are never swallowed; fixed rows scaffolded in `.init()` ([`:687`](R/decisioncompare.b.R#L687)) and only `setRow()` in `.run()`.
- **Mathematical/statistical correctness:** MINOR_ISSUES
- **Clinical readiness:** READY
- **i18n coverage:** PARTIAL

**Domain checks requested — all verified against the source:**

- **McNemar guarded on discordant pairs, not total N** — ✅ correct. [`:1830-1848`](R/decisioncompare.b.R#L1830) computes `n_discordant <- n_b + n_c` from the *correctness* 2×2 and switches to `stats::binom.test(n_b, n_discordant, p = 0.5)` below 25 discordant pairs; `n_discordant == 0` returns p = 1. The n = 206 / 6-discordant case therefore gets exact inference, a "Exact binomial McNemar" method label and a quantified footnote. Above 25 it uses `stats::mcnemar.test(tbl, correct = TRUE)` and the method column states `"McNemar chi-squared (continuity corrected)"` — continuity correction is disclosed to the user. `statistic`/`parameter` are left `NA` on the exact path rather than fabricated.
- **Paired vs unpaired difference CIs** — ✅ correct, and this is the analysis's strongest piece. `.pairedProportionDifference()` ([`:138-200`](R/decisioncompare.b.R#L138)) implements Newcombe (1998) method 10: Wilson intervals for each marginal, φ from the paired 2×2 with Newcombe's `A − n/2` continuity rule (`A > n/2` → corrected, `0 < A ≤ n/2` → φ = 0, `A ≤ 0` → uncorrected), then `d ∓ sqrt(δ² − 2φδδ' + δ'²)`. Sensitivity differences are computed only on `gold == "Positive"` rows and specificity only on `gold == "Negative"` rows ([`:2012-2033`](R/decisioncompare.b.R#L2012)) — correctly paired within each gold class. No unpaired two-proportion CI anywhere.
- **Multiple-comparison handling for > 2 tests** — ✅ correct. Cochran's Q as the global test (formula at [`:1717-1725`](R/decisioncompare.b.R#L1717) is the standard `(k−1)[kΣC² − (ΣC)²] / [kΣR − ΣR²]`, computed on *correctness*, not positivity), then Holm over the pairwise family. Crucially, uncomputable pairs are dropped from `p.adjust()` rather than padded with p = 1, and the "(Holm-Bonferroni corrected)" suffix is only appended when `n_effective > 1`.
- **Positive-`Level` wiring** — ✅ correct. Per-test positive levels via `.getTestPositives()`, optional negative levels via `.getTestNegatives()`, all validated by `.assertLevelExists()` with the *raw* column name and the slot label. The slot-index bug (writing test 3's 2×2 under the "Test 2" heading when slot 1 is empty) is already fixed via `match(testVariable, slotVariables)` at [`:781`](R/decisioncompare.b.R#L781).
- **`tryCatch` vs `reject()`** — no `jmvcore::reject()` exists in this file (validation uses `stop()`), so there is nothing for the catch-all to swallow; see the jmvcore section. 8 `tryCatch` sites reviewed, all with `.checkpoint()` outside.
- **Listwise deletion / dropped rows** — ✅ reported. Deliberately *available-case*, not listwise: each standalone metric uses rows observed for that test + reference, each pairwise comparison its own complete cases. Disclosed through `n` / `excluded` / `excludedRate` columns, a per-test "Missing Results Excluded Per Test" INFO, an "Available-Case Missing-Data Handling" WARNING citing STARD 2015, and the completion notice's per-test denominators.

**Top issues:**

1. **False negative claim when nothing was computable.** [`R/decisioncompare.b.R:1648`](R/decisioncompare.b.R#L1648) — `private$.any_significant_comparison <- any(sig_pvals < 0.05, na.rm = TRUE)`. When *no* pair was computable and Cochran's Q did not run, `sig_pvals` is all-`NA`, `any(…, na.rm = TRUE)` returns `FALSE`, and the Summary / Manuscript-Ready / Descriptive panels then assert *"Statistical comparison (McNemar's/Cochran's test) did not reveal a statistically significant difference in test performance"* ([`:2384`](R/decisioncompare.b.R#L2384)) — a statistical claim about a test that never ran, printed in text offered as manuscript-ready. The `NULL` branch that would print the neutral sentence is unreachable. Fix: set `NA` when `n_effective == 0 && is.null(private$.cochran_pvalue)`.
2. **Empty narrative boxes in the 2-test branch.** [`:2873`](R/decisioncompare.b.R#L2873) and [`:2984`](R/decisioncompare.b.R#L2984) — `if (length(mcnemar_table$rowKeys) > 0) { … }` with no `else`, so when the single pair could not be tested the Summary and Manuscript-Ready panels render a styled box containing only their heading. The identical defect was already fixed in the 3-test branch ([`:2866`](R/decisioncompare.b.R#L2866), [`:2967`](R/decisioncompare.b.R#L2967)); the 2-test branch was missed.
3. **Stratified subgroups run silent.** [`:1359`](R/decisioncompare.b.R#L1359) — `add_notices = FALSE` suppresses every metric warning inside strata, and `stratifiedTable` has neither a `notes:` block nor a `setNote()`. A subgroup with two reference-positive cases prints a 100 % sensitivity beside the cohort figures with nothing marking it as exploratory or unadjusted for multiplicity.
4. **Silent error swallow.** [`:1857`](R/decisioncompare.b.R#L1857) — `.computeMcNemar()`'s `error = function(e) NULL` discards the condition; the caller then attributes every `NULL` to *"no case has a determinate result for both tests"* ([`:1596`](R/decisioncompare.b.R#L1596)), which misdescribes any other failure.
5. **i18n gaps.** Code-side wrapping is otherwise complete — no unwrapped user strings, no leading/trailing-space msgids, no `" ["` msgctxt traps, χ² written as `χ²` escapes. Two gaps: the heatmap axis label `"Gold Standard"` is a hardcoded English literal shared between builder and renderer ([`:2722`](R/decisioncompare.b.R#L2722), [`:2777`](R/decisioncompare.b.R#L2777) — translate at render time only, since the two must stay byte-identical), and **258 of 449** `decisioncompare` msgids have an empty `msgstr` in `jamovi/i18n/tr.po`.
6. **UI label conventions.** `.a.yaml` `title: Exclude indeterminate/Equivocal levels` (leading verb + stray mid-phrase capital → "Indeterminate or equivocal levels"), `CI Method for Agreement` and `Stratification Variable` (Title Case on individual controls), `.u.yaml` `label: Prior Probability`. The `excludeIndeterminate` checkbox also sits alone in a bare bottom `LayoutBox` outside every `CollapseBox`, although it is a data-gating option.
7. **`statComp` defaults to `false`** on an analysis titled "Compare Medical Decision Tests" — the headline McNemar/Cochran comparison is off until the user opens a collapsed box.

**Strengths:** validated against independent oracles in `tests/testthat/test-decisioncompare-release-review.R` (epiR `epi.tests`, DescTools Cochran's Q, Newcombe method 10, OPA CI methods); the LR continuity correction is applied *only* to the ratio whose own denominator cell is empty, with a quantified INFO notice and a cell footnote naming the corrected value; wording throughout is carefully hedged ("descriptive ranking", "not a clinical recommendation", "a non-significant result does not establish equivalence") and ties in the best-test ranking are disclosed rather than broken silently.

#### Recommended remediation

- `/review-function decisioncompare` — fix `.any_significant_comparison` to stay `NA` when nothing was computable (#1), add the missing `else` branches at `:2873` / `:2984` (#2), and give `stratifiedTable` a subgroup caveat note plus per-stratum sparse-cell warnings (#3).
- `/jamovify-function decisioncompare --pattern=error --apply` — convert the 13 `stop(jmvcore::.("Validation failed"))` calls to `jmvcore::reject()` so the real message reaches the jamovi error box.
- `/fix-notices decisioncompare` — align the low-discordant-pair threshold with the exact-test switch (10 → 25) and promote it from a footnote to a STRONG_WARNING; move the `notices` item to the top of `jamovi/decisioncompare.r.yaml`.
- `/check-function decisioncompare` — add `fnote` to the `clearWith` of `cTable1`–`cTable3` and `comparisonTable`; cap the `plotHeatmap` state row count; add `escape = TRUE` to the `knitr::kable()` call.
- `/prepare-translation decisioncompare` — 258 empty `msgstr` entries in `tr.po`; translate the heatmap `"Gold Standard"` axis label at render time.

### decisioncurve

**Status:** ⚠️ NEEDS WORK (minor; substantively the strongest analysis reviewed in this module)
**Files:** [`R/decisioncurve.b.R`](R/decisioncurve.b.R) · [`jamovi/decisioncurve.a.yaml`](jamovi/decisioncurve.a.yaml) · [`jamovi/decisioncurve.u.yaml`](jamovi/decisioncurve.u.yaml) · [`jamovi/decisioncurve.r.yaml`](jamovi/decisioncurve.r.yaml)
**Metrics:** .b.R LOC 2997 · options 45 (44 user-facing) · outputs 18 · UI controls 44 · JS LOC 0

#### Security

No HIGH or MEDIUM findings. No `eval`/`parse(text=)`/`do.call(<var>)`/`as.formula`/`system`/`readRDS`/`source`/filesystem or network sinks anywhere in the file. Every user-derived string that reaches HTML (`outcome_var`, `outcome_positive`, model names, `decisionRuleLabel`, notice titles/contents) is passed through `private$.safeHtmlOutput()` first — [`R/decisioncurve.b.R:202`](R/decisioncurve.b.R#L202), [`:271`](R/decisioncurve.b.R#L271), [`:1589`](R/decisioncurve.b.R#L1589), [`:2452`](R/decisioncurve.b.R#L2452).

- **[H-LOW]** [`R/decisioncurve.b.R:733`](R/decisioncurve.b.R#L733), [`:1370`](R/decisioncurve.b.R#L1370), [`:1383`](R/decisioncurve.b.R#L1383) — three empty `if (...) { }` blocks left behind when `message()`-based progress reporting was removed; `DECISIONCURVE_DEFAULTS$bootstrap_progress_threshold`, `$performance_threshold_count` and `$bootstrap_chunk_size` now exist only to feed them.
- **[H-LOW]** [`R/decisioncurve.b.R:197`](R/decisioncurve.b.R#L197) — `.escapeVar()` is defined and never called (zero call sites in the file).
- **[I-LOW]** [`R/decisioncurve.b.R:314`](R/decisioncurve.b.R#L314) — `.calculateNetBenefit()` divides by `1 - threshold` with no guard of its own; it is safe only because every call site is pre-validated (grid bounded by `.generateThresholds()`, table list filtered to `> 0 & < 1`). A defence-in-depth `if (threshold <= 0 || threshold >= 1) return(NULL)` would make the invariant local.

`.safeHtmlOutput()` also maps `/` to `&#x2F;` — harmless in the `Html` results it feeds today, but it would render literally if that text were ever routed to a `Text` result or `setNote()`.

#### jmvcore migration

- **[error]** [`R/decisioncurve.b.R:465`](R/decisioncurve.b.R#L465), [`:555`](R/decisioncurve.b.R#L555), [`:566`](R/decisioncurve.b.R#L566), [`:718`](R/decisioncurve.b.R#L718) — four user-facing validation paths inside `.run()` use `stop(msg, call. = FALSE)` rather than `jmvcore::reject(msg)`. The message text is correct and is also rendered as an HTML notice immediately before the `stop()`, so the user is informed twice; but the red banner is a raw R error rather than jamovi's structured error state.
  ```r
  private$.renderNotices()
  stop(msg, call. = FALSE)          # -> jmvcore::reject(msg)
  ```
  **Not** a `trycatch-swallows-reject` case: the only catch-all `tryCatch` ([`:739`](R/decisioncurve.b.R#L739)) opens *after* the `stop()` at `:718`, guards only the resample loop, and correctly re-raises `.checkpoint()`'s `code == "restart"` condition at [`:820`](R/decisioncurve.b.R#L820).
- **[numeric]** No misuse. `as.numeric()` is applied only to logical comparisons (`outcomes == positive_outcome`), never to a jamovi factor, so `jmvcore::toNumeric()` is not indicated.
- No `na.omit`, no formula construction, no `.asSource()` — nothing else to migrate.

#### Integration

**Arguments declared:** 45  ·  **used in logic:** 43  ·  **dead:** 1 (+1 `data`)

| Argument | Type | Default | Used? | In logic? | Notes |
|---|---|---|:---:|:---:|---|
| `comparisonMethod` | List | `bootstrap` | ❌ | ❌ | Zero reads in `.b.R`. One enumerated choice, so the ComboBox at [`decisioncurve.u.yaml:211`](jamovi/decisioncurve.u.yaml#L211) is a live control that can never change anything. Deliberately retained for `.omv` back-compat (documented in the `.a.yaml`), but it should be `enable: (false)` or removed from the `.u.yaml`. |
| `showPlot` / `showInterventionAvoided` / `showRelativeUtility` / `showStandardizedNetBenefit` | Bool | false | ❌ in `.b.R` | ✅ via `.r.yaml` | Correct pattern — they drive `visible:` expressions only. Not dead. |
| `confidenceIntervals` / `showNetBenefitCI` | Bool | false | ✅ | ✅ | Two options with byte-identical effect (`||`-ed at every site). Honestly documented in the `.a.yaml`, but it is still two checkboxes for one behaviour in two different CollapseBoxes. |

**Outputs declared:** 18  ·  **populated:** 18  ·  **unpopulated:** 0

No unpopulated outputs, no permanently-invisible outputs, no `type: Notice` in the `.r.yaml`, no `results$insert()` anywhere (so no `Group$insert()` bounds trap).

**`requiresData` contract — PASS.** Traced all five `renderFun`s (`.plotDCA`, `.plotClinicalImpact`, `.plotInterventionsAvoided`, `.plotRelativeUtility`, `.plotStandardizedNetBenefit`) through `.restoreFromState()`, `.calculateModelAtThreshold()`, `.calculateNetBenefit()`, `.calculateNetInterventionsAvoided()`, `.parseSelectedThresholds()` and `.optimizePlotDataForManyModels()`. None reaches `self$data` or a `.cleandata()` equivalent; everything comes from `image$state` published in `.run()` by `.publishPlotStates()` ([`:84`](R/decisioncurve.b.R#L84)). `requiresData` is correctly absent on all five images — no missing flag and no surplus flag.

**Heavy `setState()` (LOW).** `.publishPlotStates()` writes state to all five images unconditionally, ignoring `visible:`. Four of the five slices carry `dcaResults`, which holds one full `predictions` vector per strategy ([`:1460`](R/decisioncurve.b.R#L1460)), plus three carry `analysisOutcomes`. On a 5,000-row / 4-model analysis that is ~4 copies of ~160 KB written into the `.omv` even when all four of those plots are switched off. The `dcaPlot` slice was already trimmed for exactly this reason; the fix is the same one applied there — skip `img$setState()` when `img$visible` is FALSE.

**clearWith (LOW gap).** [`decisioncurve.r.yaml:32`](jamovi/decisioncurve.r.yaml#L32) — the `notices` `Html` lists only the data/threshold options, but notice content also depends on `bootReps` ("Low Bootstrap Replications"), `confidenceIntervals`/`showNetBenefitCI`, `compareModels`, `multiModelComparison`, `costBenefitAnalysis`, `showDecisionConsequences`, `resourceUtilization`, `calculateClinicalImpact` and `showTable`. Practical impact is limited to the stale-grey indicator because `.run()` rewrites the panel on every cycle ([`:1027`](R/decisioncurve.b.R#L1027)), but the list is incomplete. Every other result's `clearWith` is complete, including the rule variables on the two bootstrap comparison tables (correct — the rule changes the complete-case cohort).

**Citation refs — PASS.** All six keys used (`ClinicoPathJamoviModule`, `Vickers2006`, `Vickers2019DCA`, `Kerr2016DCA`, `Vickers2023DCAInference`, `MandelBetensky2008`) resolve in `jamovi/00refs.yaml`; no case mismatches, no option names inside the `refs:` block.

**Column `format:` tokens — PASS.** Only `pc`, `zto` and `zto,pvalue` appear; comma-separated and exact-matched.

**Placeholder assessment: FUNCTIONAL.** Real computation throughout, four testthat files (`tests/testthat/test-decisioncurve*.R`) and seven DCA fixtures in `data/`.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ✅ | n/a | Handled by the `instructions` Html panel + `setVisible(TRUE/FALSE)` ([`:1104`](R/decisioncurve.b.R#L1104)), not a notice. That `setVisible(FALSE)` at [`:1113`](R/decisioncurve.b.R#L1113) is **not** an error mechanism — it is the matching hide for the instructions pane. Twelve further ERROR notices cover duplicate/reserved model names, non-binary outcome, missing positive level, non-binary rule, non-numeric or out-of-range predictions, and the rule-enabled-without-variable case. |
| Low n / events | STRONG_WARNING | ✅ | ✅ | `.warnOnLowEventCount()` ([`:515`](R/decisioncurve.b.R#L515)): < 10 events STRONG_WARNING, 10–24 WARNING, with the exact count. Separate n < 50 / n < 100 sample-size ladder at [`:1252`](R/decisioncurve.b.R#L1252). |
| Extreme prevalence (< 5% or > 95%) | STRONG_WARNING | ✅ | ✅ | [`:1300`](R/decisioncurve.b.R#L1300), reports `pct`, `events/n`. |
| Assumption / optimism violation | STRONG_WARNING | ✅ | n/a | [`:1684`](R/decisioncurve.b.R#L1684) — "Net benefit shown here is apparent, not validated". This is the single most important clinical caveat in DCA and most implementations omit it. |
| Multiple testing | — | ✅ | ✅ | Holm applied in both comparison tables and stated in the table notes ([`:2041`](R/decisioncurve.b.R#L2041), [`:2350`](R/decisioncurve.b.R#L2350)); unadjusted `p` is shown beside `p (Holm)` with an explicit note. |
| Complete-case exclusion | WARNING | ✅ | ✅ | [`:1230`](R/decisioncurve.b.R#L1230), excluded / total / %. |
| Methodology summary | INFO | ✅ | ✅ | "Analysis Complete" appended last ([`:1701`](R/decisioncurve.b.R#L1701)) so it renders at the bottom. |

Two coverage defects:

1. **Ordering is insertion order, not severity.** `.renderNotices()` ([`:240`](R/decisioncurve.b.R#L240)) iterates `private$.noticeList` unsorted. The low-event, complete-case and small-sample warnings are appended at [`:1224`](R/decisioncurve.b.R#L1224)–[`:1252`](R/decisioncurve.b.R#L1252), *before* the "Outcome Not Binary" / "Positive Outcome Level Required" ERROR checks at [`:1263`](R/decisioncurve.b.R#L1263)–[`:1281`](R/decisioncurve.b.R#L1281). So on those two failure paths the ERROR panel renders **below** three warnings. Sort by `ERROR > STRONG_WARNING > WARNING > INFO` before emitting.
2. **Stale premise in the schema comment.** [`decisioncurve.r.yaml:31`](jamovi/decisioncurve.r.yaml#L31) says "Notice outputs converted to HTML to avoid serialization errors". That premise was retracted on 2026-09-22 — `jmvcore::Notice` serializes correctly; the crash was `Group$insert()`'s missing bounds check. Keeping the HTML panel is still the right call here (multi-line, styled content), but the comment should say *that* rather than repeating the retracted claim.

Notices are never dropped on an early return: all thirteen `return()` paths call `.renderNotices()` first, and `.plotClinicalImpact()` saves/restores `private$.noticeList` around `.parseSelectedThresholds()` ([`:2731`](R/decisioncurve.b.R#L2731)) so resize renders cannot grow the list.

#### Code review

- **Overall quality:** 4.5 stars
- **Architecture:** OK, with one caveat — `.run()` spans [`:1007`](R/decisioncurve.b.R#L1007)–[`:1714`](R/decisioncurve.b.R#L1714), ~706 lines, well past the ~200-line target. It is mostly linear validation and dispatch, and the heavy lifting is already in ~25 private helpers, but the validation block (packages → instructions → names → complete cases → outcome → rule) is an obvious `.validateInputs()` extraction.
- **Mathematical/statistical correctness:** MINOR_ISSUES
- **Clinical readiness:** READY
- **i18n coverage:** PARTIAL

**Domain verification (the items specifically requested):**

- **Net benefit formula — CORRECT.** [`R/decisioncurve.b.R:314`](R/decisioncurve.b.R#L314) and the vectorised twin at [`:410`](R/decisioncurve.b.R#L410):
  ```r
  nb <- (tp / n) - (fp / n) * (threshold / (1 - threshold))
  ```
  The weight is `pt/(1-pt)`, not inverted, and `n` is the full analysed cohort in both terms.
- **Treat-all / treat-none — CORRECT.** [`:334`](R/decisioncurve.b.R#L334) uses the event rate: `prevalence - (1 - prevalence) * (threshold / (1 - threshold))`, and it is evaluated inside a per-threshold loop at [`:1494`](R/decisioncurve.b.R#L1494) — not a constant. Treat-none is 0 by definition.
- **pt = 0 / pt = 1 edges — SAFE.** The grid is bounded by `.generateThresholds()` (auto 0.01–0.99, focused 0.05–0.50, custom rejected unless `0 < min < max < 1` at [`:558`](R/decisioncurve.b.R#L558)), `.a.yaml` clamps min/max to 0.001–0.999, the table list is filtered to `kept > 0 & kept < 1` at [`:638`](R/decisioncurve.b.R#L638), and `.calculateNetInterventionsAvoided()` returns `NA_real_` outside `(0,1)` at [`:348`](R/decisioncurve.b.R#L348). A single-point range is refused outright at [`:451`](R/decisioncurve.b.R#L451).
- **Predictor range — VALIDATED AND REJECTED, NOT RESCALED.** [`:1420`](R/decisioncurve.b.R#L1420) raises an ERROR naming the observed min/max when any value falls outside [0,1], with explicit text that logits/linear predictors/raw scores are not threshold probabilities and that min–max scaling does not create calibrated risks. A non-numeric column is rejected separately at [`:1390`](R/decisioncurve.b.R#L1390), and a range narrower than 5% draws a STRONG_WARNING. This is exactly the guard the brief asked for and it is better than most published implementations.
- **Seed — USER-VISIBLE AND REPORTED.** `seed` is an `Integer` option (default 42) and `withr::local_seed()` is applied once at [`:1059`](R/decisioncurve.b.R#L1059) so the caller's RNG stream is restored on exit. The value is printed in the `comparisonTable` note ([`:2337`](R/decisioncurve.b.R#L2337)), the `modelComparisonEnhanced` note ([`:2041`](R/decisioncurve.b.R#L2041)) and the `dcaPlot` caption when a bootstrap ribbon is actually drawn ([`:2617`](R/decisioncurve.b.R#L2617)). House rule satisfied.
- **`setVisible(FALSE)` — NOT an error mechanism.** Sole site is the instructions-pane hide ([`:1113`](R/decisioncurve.b.R#L1113)).
- Relative utility ([`:2894`](R/decisioncurve.b.R#L2894)) and standardized net benefit ([`:2963`](R/decisioncurve.b.R#L2963)) are both formulated correctly (`NB_perfect = prevalence`; RU baseline `max(NB_all, 0)`; sNB = NB/prevalence), and the sup-t simultaneous band at [`:791`](R/decisioncurve.b.R#L791) is a faithful Mandel & Betensky construction from the same replicates.

**Top issues:**

1. **Bootstrap p-values are confidence-interval inversions, not null-hypothesis tests** — `calc_stats()` at [`:987`](R/decisioncurve.b.R#L987) computes `2 * min((#≥0 + 1)/(B + 1), (#≤0 + 1)/(B + 1))` from the *unshifted* bootstrap distribution of the difference. The `(b+1)/(B+1)` convention is right and avoids `p = 0`, but no null-centring is done, so the quantity is an approximate percentile p, not a bootstrap hypothesis test. Every surrounding string says "exploratory" / "approximate" and the tables are titled "Exploratory …", so this is disclosed rather than hidden — but it is the one place a reader could over-read the output.
2. **RNG stream is shared across features, so a p-value depends on which *other* options are on.** `withr::local_seed()` is set once for the whole run, then `.calculateBootstrapCI()` (per model, and per clinical rule) consumes draws before `.performModelComparison()` and `.performEnhancedModelComparison()` run. Toggling the CI checkbox therefore changes the comparison p-value for identical data. The note at [`:2337`](R/decisioncurve.b.R#L2337) claims "Re-running with the same seed reproduces these numbers exactly" — true for an identical option set, misleading otherwise. Fix: re-seed (`withr::with_seed(seed + k, ...)`) per bootstrap consumer.
3. **ERROR notices can render below WARNINGs** (see Notices coverage §1) — `.renderNotices()` does not sort by severity.
4. **Two bootstrap tables use different B on the same screen** — `.performEnhancedModelComparison()` caps at `min(bootReps, 1000)` ([`:1985`](R/decisioncurve.b.R#L1985)) while `.performModelComparison()` uses the full `bootReps`. Disclosed in a `setNote("cap", …)`, but the two panels' p-values for the same pair will differ for `bootReps > 1000`.
5. **Tie handling at derived thresholds (LOW).** `predicted_positive <- predictions >= threshold` compares against `seq()`-generated grid points, so the nominal "15%" threshold is `0.15000000000000002`; a prediction recorded as exactly `0.15` is classified negative on the curve but positive in the results table (which uses the user's literal value). Only bites discrete/rounded predictors. A `>= threshold - 1e-10` tolerance would align the two, matching the pattern already used for `nb_tol` at [`:868`](R/decisioncurve.b.R#L868).
6. **Always-on narratives (minor UX).** `procedureNotes` and `summaryText` are `visible: true` with no gating option, so the "Analysis Summary" and "Clinical Interpretation" panels always render. The project convention is that verbose explanatory output is enabled by a checkbox.
7. **i18n PARTIAL** — source wrapping is complete (every user-facing string is `.()`-wrapped with `{placeholder}` values via `.fmt()`; no leading/trailing space or punctuation inside `.()`; no ` [` msgctxt-truncation trap; no non-ASCII literals — `×` is written `×`). The gap is catalog-side: 12 of ~393 `decisioncurve` blocks in `jamovi/i18n/tr.po` still carry an empty `msgstr`, including "Model comparison needs two models", "Clinical Decision Rule Variable Required", "Shaded: {level}% pointwise CI" and the net-benefit formula footnote.
8. **Stale defensive code (LOW).** `.ciBand()` wraps `self$options$ciBand` in a `tryCatch` "because the option is absent from the compiled Options class until `prepare()` has run" ([`:180`](R/decisioncurve.b.R#L180)) — `ciBand` is now compiled (`R/decisioncurve.h.R:186`), so the guard is dead.

**Strengths.** The statistical core is correct and the surrounding honesty is exceptional: no "optimal threshold" is ever reported (replaced by a descriptive range-of-benefit with a contiguity flag), the weighted-AUC gain is measured against `pmax(treat-all, 0)` rather than treat-all alone, the "Exploratory Monetary Payoff" table is explicitly disclaimed as not an ICER/QALY/CEA, censoring and calibration limitations are stated in three separate places, and the apparent-vs-validated optimism warning is a STRONG_WARNING on every successful run. The `.init()`/`.run()` column-scaffolding contract via a single `.ruleStrategyLabel()` source, the `.restoreFromState()` rehydration design, and the per-image state slicing are all well above the module average.

#### Recommended remediation

- `/fix-notices decisioncurve` — sort `.renderNotices()` by severity so ERROR cannot render under a WARNING; correct the retracted "serialization errors" premise in the `.r.yaml` comment.
- `/jamovify-function decisioncurve --pattern=error --apply` — replace the four `stop(msg, call. = FALSE)` validation exits with `jmvcore::reject(msg)`.
- `/review-function decisioncurve` — re-seed per bootstrap consumer (issue 2), align B between the two comparison tables (issue 4), add the `>= threshold - 1e-10` tie tolerance (issue 5), and decide whether the percentile p-value should be null-centred or dropped in favour of the CI alone (issue 1).
- `/prepare-translation decisioncurve` — fill the 12 empty Turkish `msgstr` entries.
- `/check-function decisioncurve` — remove the dead `if () {}` blocks, unused `DECISIONCURVE_DEFAULTS` constants, `.escapeVar()` and the stale `.ciBand()` `tryCatch`; disable or drop the `comparisonMethod` ComboBox; gate `.publishPlotStates()` on `img$visible`; complete the `notices` `clearWith`.

### enhancedROC

**Status:** ⚠️ NEEDS WORK
**Files:** [`R/enhancedROC.b.R`](R/enhancedROC.b.R) · [`R/enhancedROC-errors.R`](R/enhancedROC-errors.R) · [`jamovi/enhancedROC.a.yaml`](jamovi/enhancedROC.a.yaml) · [`jamovi/enhancedROC.u.yaml`](jamovi/enhancedROC.u.yaml) · [`jamovi/enhancedROC.r.yaml`](jamovi/enhancedROC.r.yaml)
**Metrics:** .b.R LOC 5911 (+478 helper) · options 69 (+`data`) · outputs 38 (26 tables/HTML, 12 images) · UI controls 69 · JS LOC 0

This backend has clearly been through several remediation passes: every fix is annotated with the defect it closes. Categories A/B/C/E/F/G are genuinely clean, all 38 outputs are populated, all 12 `renderFun`s exist, no placeholder or fabricated statistic survives, and no `$insert()` or `setVisible()` misuse. The remaining work is concentrated in four places: the notices architecture, `clearWith`, i18n, and two statistical details.

#### Security

- **[H-LOW]** [`R/enhancedROC-errors.R:403`](R/enhancedROC-errors.R#L403) — `cat("ClinicoPath cleanup completed for function:", function_name, "\n")` in a shipped `@export`ed function writes to the jamovi engine's stdout. (`clinicopath_cleanup()` has zero callers in the shipped module, so it is inert today — but it is public API.)
- **[I-LOW]** [`R/enhancedROC-errors.R:11-16`](R/enhancedROC-errors.R#L11) — `.clinicopath_errors` is a package-global mutable environment. Every analysis in the jamovi session shares one R process, so `clinicopath_init()` resets another analysis's counters and `function_stack` on each panel open. Affects only log text, not results.
- **[I-LOW]** [`R/enhancedROC.b.R:48-53`](R/enhancedROC.b.R#L48) — `.escapeVar()` (`gsub("[^A-Za-z0-9_]", "_", make.names(x))`) is used as the `rowKey` for 11 tables. Two predictors named `CA 19-9` and `CA.19.9` both collapse to `CA_19_9`; `addRow()` has no duplicate-key check, so the rows stack under one key. The visible `predictor` column still shows the real name, so this is a key-integrity issue, not a display one.

**D (XSS) — traced clean, no finding.** Every user-derived string reaching HTML is escaped: predictor/outcome names and option values go through `private$.safeHtmlOutput()` (27 sites, escapes `& < > " '`) or `jmvcore::htmlEscape()` (10 sites). `.renderNotices()` escapes both the title and the content of every notice, so the ~60 `.addNotice()` call sites are covered at the sink. `validate_clinical_data()`'s English warning strings are escaped before being appended to the instructions panel. No user string reaches an HTML *attribute*, and there is no `javascript:`/URL sink.

**Also verified absent:** no `eval`/`parse(text=)`/`str2lang`, no `as.formula`/`reformulate`, no `system`/`source`/`readRDS`/`download.file`, no `library()`, no debug flag, no `do.call` on a variable first argument (the single `do.call(rbind, ci_data_list)` at [`:3746`](R/enhancedROC.b.R#L3746) takes a literal). **No bare `plot(roc_obj)`** — every renderer `print()`s a ggplot object, so the `spatstat` masking of `pROC::plot.roc` is not reachable here.

#### jmvcore migration

- **[error]** [`R/enhancedROC.b.R:376`, `:600`, `:685`, `:720`, `:744`, `:786`, `:812`, `:825`](R/enhancedROC.b.R#L376) — **55 `tryCatch` sites and 0 `jmvcore::reject()` calls.** The 8 fatal validation paths in `.run()`/`.prepareData()` emit `private$.addNotice(type = "ERROR", ...)` into a hand-rolled HTML panel and `return(NULL)`. Nothing ever enters jamovi's error state.

  ```r
  private$.addNotice(type = "ERROR", title = .("Missing Variables"),
                     content = .("Please select an outcome variable and ..."))
  return()
  ```

  Consequence: a run with no outcome variable reports *complete* to jamovi, and the R wrapper path (`ClinicoPath::enhancedROC(...)`) returns a results object carrying an HTML blob instead of raising. Fix: `jmvcore::reject()` for the hard-stop cases, or a real `jmvcore::Notice` + `return()`, **keeping** the HTML panel per the project's standing both-mechanisms decision. There is no `tryCatch`-swallows-`reject` trap here, because there is no `reject` to swallow.

- **[error]** ~120 user-facing messages use `sprintf()` where `jmvcore::format()` / `.fmt()` is the house style; the file already uses `.fmt()` 21 times, so the two idioms are mixed. The `sprintf` calls do use positional `%1$s` specifiers, so translator word-order is not blocked — low priority, cosmetic consistency.

*No `formula`, `na`, `numeric`, `term` or `source` opportunities:* `.prepareData()` already uses `jmvcore::naOmit()` ([`:662`](R/enhancedROC.b.R#L662)), `asSource()` already delegates to `private$.asArgs()`.

#### Integration

**Arguments declared:** 69 · **used in logic:** 67 · **dead:** 0 (2 non-effective)

| Argument | Type | Default | Used? | In logic? | Notes |
|---|---|---|:---:|:---:|---|
| `tiedScoreHandling` | List | `average` | ✅ | ❌ | [`:963`](R/enhancedROC.b.R#L963) — the only use is an INFO notice saying the setting is *not supported by pROC*. Picking `upper`/`lower` changes nothing but the apology. Either implement or remove the control. |
| `multiClassAveraging` | List | `macro` | ✅ | ❌ | [`:519`](R/enhancedROC.b.R#L519) — the OVR branch computes **both** `macro_auc` and `weighted_auc` unconditionally and shows both columns; the OVO branch only raises a warning. The combo box never selects anything. |
| `nntCalculation` | Bool | false | ✅ | ✅ | Not read in `.b.R` — correctly wired declaratively via `visible: (nntCalculation)` on two `clinicalImpactTable` columns. **Not** a dead option. |

**Outputs declared:** 38 · **populated:** 38 · **unpopulated:** 0 · **permanently invisible:** 0

**`requiresData` — correct as absent.** Traced all 12 `renderFun`s through `.restoreFromState()` → `image$state` (and, for the light-payload images, `rocCurvePlot`'s state). `self$data` is read only at [`:188`](R/enhancedROC.b.R#L188) (`.init`), [`:594`](R/enhancedROC.b.R#L594) and [`:661`](R/enhancedROC.b.R#L661) (`.prepareData`) — never from a renderer or a helper a renderer calls. The state payload is deliberately protobuf-safe (no pROC/caret objects) and the heavy data frame rides on `rocCurvePlot` only.

**`clearWith` completeness — the main integration defect (14 results).**

- **`clinicalContext` drives user-visible text in 10 results and appears in ZERO `clearWith` lists.** Consumers: `.assessClinicalUtility` → `aucSummary`; `.generateClinicalRecommendation` → `optimalCutoffSummary`; `.interpretClinicalMetrics` → `clinicalApplicationMetrics`; `.assessClinicalSignificanceDifference` → `rocComparisons`; `.assessPartialAUCRelevance` → `partialAucAnalysis`; `comprehensiveAnalysisSummary`; `clinicalInterpretationGuide` (**the entire panel branches on it**); `analysisSummary`; `clinicalReport`; `.validateClinicalAssumptions` → `instructions`. Switching Screening → Diagnosis leaves every one of these showing the previous context's prose.
- **`seed` missing from three tables that print a `Random seed: {seed}` note** — `rocComparisons`, `statisticalSummary`, `multiClassAUC`. `bootstrapSamples` is likewise missing from `rocComparisons`/`statisticalSummary` although [`:2115`](R/enhancedROC.b.R#L2115) passes `boot.n = self$options$bootstrapSamples`.
- **`direction` missing from the four risk-probability results** — `calibrationSummary`, `hosmerLemeshowTable`, `clinicalImpactTable`, `decisionImpactSummary`. `.riskProbabilities()` is direction-aware ([`:1776`](R/enhancedROC.b.R#L1776)), so flipping Direction changes every number in them.
- `multiClassAUC` also omits `useBootstrap`/`bootstrapMethod`/`confidenceLevel` despite computing bootstrap CIs; `optimalCutoffSummary` omits `useObservedPrevalence`/`prevalence`/`clinicalMetrics` (all read by `.generateClinicalRecommendation`); `clinicalReport`/`analysisSummary` omit `analysisType`, `confidenceLevel`, `useBootstrap`, `comparisonMethod`, `pairwiseComparisons`, `seed`.

**UI (`ui-enable-drift`):** [`jamovi/enhancedROC.u.yaml:99-101`](jamovi/enhancedROC.u.yaml#L99) — `plotTheme` carries `enable: (rocCurve)`, but `.plotThemeFor()` is applied by **all 12** renderers. Unticking "ROC curve" greys out the theme control while it still governs the other 11 plots. Also, `showMetricsDiff` and `statisticalComparison` sit under the **Plots** label ([`:102-106`](jamovi/enhancedROC.u.yaml#L102)) although they produce tables, and neither carries `enable: (analysisType:comparative)` — the backend compensates with a runtime WARNING notice at [`:452`](R/enhancedROC.b.R#L452).

**Citation refs — clean.** All 10 used keys (`pROC`, `boot`, `caret`, `splines`, `Swamidass2010`, `McClish1989`, `AustinSteyerberg2019ICI`, `Kerr2016DCA`, `Vickers2019DCA`, `ClinicoPathJamoviModule`) are defined in `00refs.yaml` with non-empty author and year. No undefined, no case mismatch, no option names in the list. One gap (INFO): `DeLong1988` **is** defined in `00refs.yaml` and DeLong is the default CI *and* default comparison method, cited in the methods HTML at [`:2666`](R/enhancedROC.b.R#L2666) — but it is not in the analysis's `refs:` block, while the optional McClish correction is.

**Column formats:** all checked against the `zto|pvalue|pc|log10|dp:N|sf:N` grammar — 0 malformed tokens, 0 capitalised column types.

**Parked features are correctly parked, not half-wired.** 20 commented-out `.a.yaml` options and 14 commented-out `.u.yaml` controls, each annotated `NOT IMPLEMENTED`. Every live `self$options$X` in `.b.R` resolves to a live option — verified by crosswalk, so there is no `dead-code-schema` trap.

**Dead-weight helper surface.** In the *shipped* module (`enhanced_wrapper_example.R` is umbrella-only and does not ship), only 4 of the 12 top-level functions in `R/enhancedROC-errors.R` are reachable: `clinicopath_init`, `validate_clinical_data`, `clinicopath_error_handler` and `generate_user_friendly_error` (transitively). Dead, yet all `@export`ed into the meddecide NAMESPACE and `man/`: `safe_execute`, `clinicopath_warning_handler`, `generate_user_friendly_warning`, `get_error_summary`, `clear_error_log`, `clinicopath_cleanup`, `get_clinical_context`, `create_enhanced_result` — ~370 of 478 lines.

#### Notices coverage

**Architectural finding: there is not a single `jmvcore::Notice` in this analysis.** All ~60 notices go through `private$.addNotice()` → `private$.renderNotices()` → one `Html` item (`results/notices`). The project's standing decision is to carry *both* the HTML panel and real Notices; here only the HTML half exists. The HTML implementation is itself well built — severity-coloured with `rgba()` tints (theme-safe), `color: inherit`, cleared on every exit path via `on.exit()` at [`:335`](R/enhancedROC.b.R#L335), and reset at the top of each `.run()` so notices cannot accumulate.

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ✅ | ✅ | [`:376`](R/enhancedROC.b.R#L376) — HTML only, no `reject()`; jamovi never enters the error state |
| Non-binary / single-level / non-numeric / <10 rows | ERROR | ✅ | ✅ | [`:685`](R/enhancedROC.b.R#L685)–[`:825`](R/enhancedROC.b.R#L825), all name the variable and the counts |
| **Events < 10** | **ERROR** | ⚠️ | ✅ | [`:1146`](R/enhancedROC.b.R#L1146) raises **STRONG_WARNING**, not ERROR. A 200-patient set with 4 events proceeds to a full results pane — AUC, DeLong CI, optimal cutpoint, PPV/NPV — behind an orange banner. Checklist requires ERROR at <10 events. |
| Small n (<30) | WARNING / STRONG_WARNING | ✅ | ✅ | [`:1155`](R/enhancedROC.b.R#L1155), escalates below n=10 |
| **AUC < 0.5** | ERROR | ✅* | ✅ | [`:1174`](R/enhancedROC.b.R#L1174) — ERROR ("Marker Reads Backwards") **only when the whole CI lies below 0.5**, otherwise STRONG_WARNING ("AUC Below Chance"). This deviates from the checklist by design and the design is better: under the null ~half of uninformative markers fall below 0.5, and telling those users to flip Direction would flip the cutpoint on noise. The comment documents a 2000-replicate simulation. **Accept as-is.** |
| AUC < 0.7 | STRONG_WARNING | ✅ | ✅ | [`:1194`](R/enhancedROC.b.R#L1194) |
| Extreme prevalence (<5% / >95%) | STRONG_WARNING | ✅ | ✅ | [`:1203`](R/enhancedROC.b.R#L1203), raised once per run, not per predictor |
| Class imbalance | WARNING / STRONG_WARNING | ✅ | ✅ | [`:2604`](R/enhancedROC.b.R#L2604), severity scales with the ratio |
| Direction auto-detected | WARNING | ✅ | ✅ | [`:1097`](R/enhancedROC.b.R#L1097) — quantifies the upward bias at *this* n (Hanley–McNeil null SE) |
| Cutpoint optimism | note | ✅ | — | `optimalCutoffSummary$setNote("cutpoint_optimism")` at [`:1592`](R/enhancedROC.b.R#L1592) |
| Multiplicity (k(k−1)/2 tests) | note | ✅ | ✅ | On all three comparison tables |
| Methodology summary | INFO | ✅ | ✅ | "Analysis Complete" at [`:566`](R/enhancedROC.b.R#L566) + `methodsExplanation` HTML |
| Bootstrap-CI / BCa-downgrade / spline / HL-skip failures | WARNING | ✅ | ✅ | Each names the predictor and the reason |

**Silent-failure exceptions (the brief's "does any catch-all hide a real failure?"):** most handlers do raise a notice, but five do not —

- [`:5077`](R/enhancedROC.b.R#L5077) `class_ci <- tryCatch(private$.bootstrapAucCi(roc_obj), error = function(e) NULL)` — a failed multi-class bootstrap blanks `auc_lower`/`auc_upper` with **no** notice, while the identical failure on the binary path *does* warn at [`:1004`](R/enhancedROC.b.R#L1004). Inconsistent.
- [`:4944`](R/enhancedROC.b.R#L4944) `.ovrDirection()` falls back to `error = function(e) "<"`. A failed direction probe silently pins the orientation and can invert the entire multi-class analysis.
- [`:2252`](R/enhancedROC.b.R#L2252) McClish normalisation → `NA_real_` silently blanks the `normalized_pauc` column.
- [`:1563`](R/enhancedROC.b.R#L1563) `sqrt(pROC::var(roc_obj))` → `NA_real_`; the note explains the *bootstrap* blank but not a genuine DeLong-variance failure.
- [`:5762`](R/enhancedROC.b.R#L5762) if every optimism resample fails, `mean(NA, na.rm = TRUE)` is `NaN` and the panel prints `Corrected AUC = NaN`.

`private$.plotMessage()` at [`:135`](R/enhancedROC.b.R#L135) is the right answer to "a renderer cannot raise a notice" — it draws the explanation on the canvas and resolves the foreground colour out of jamovi's `ggtheme` list.

#### Code review

- **Overall quality:** ★★★★☆ (4/5)
- **Architecture:** OK. R6 inherits `enhancedROCBase`; `.run()` is 256 lines but is a pure `if (option) populateX()` dispatcher over ~30 private helpers; `.checkpoint()` is called before every expensive block; `deleteRows()` precedes every `addRow()` loop; the `.restoreFromState()` / `.plotStatePayload()` split is exemplary state handling.
- **Mathematical/statistical correctness:** MINOR_ISSUES
- **Clinical readiness:** NEEDS_VALIDATION
- **i18n coverage:** PARTIAL

**Statistics — verified correct:**

- **Positive class is pinned, not left to pROC.** `.prepareData()` re-levels the outcome to `c(negative, positive)` ([`:773`](R/enhancedROC.b.R#L773)), so pROC's default `levels = levels(response)[1:2]` is deterministic, and `direction` is passed explicitly (`"<"`/`">"`) unless the user chose auto. `.bootstrapAucCi()` passes both `levels =` and `direction =` to every resample ([`:874`](R/enhancedROC.b.R#L874)).
- **Auto-detection is disclosed and quantified**, not silently accepted — see the notice above and the `.a.yaml` `direction` description.
- **Cutpoint method is named** in the `cutoff_type` cell ("Optimal (Youden)" vs "Optimal (closest to top-left)") and its **optimism is disclosed** in a table note. Ties are broken deterministically with an INFO notice ([`:1330`](R/enhancedROC.b.R#L1330)).
- **The seed is a user option and is reported** — a `Random seed: {seed}` note on 5 tables, the clinical-report HTML, the internal-validation HTML and the ROC plot caption; `withr::local_seed()` in `.run()` and again in `.plotROCCurve` (whose `ci.coords` bands run after `.run()` has restored the RNG).
- Confusion matrices honour the pROC direction convention (`>= t` for `"<"`, `<= t` for `">"`) at [`:1256`](R/enhancedROC.b.R#L1256); caret cells are read by level name.
- McNemar guards **discordant pairs** (≥10), not total N ([`:3540`](R/enhancedROC.b.R#L3540)).
- Hosmer–Lemeshow df switches between `g` and `g−2` depending on whether the probabilities were supplied or fitted here ([`:4680`](R/enhancedROC.b.R#L4680)) — a subtle point most implementations get wrong.
- Calibration slope/intercept and E/O are **suppressed** on the fitted-here branch because they are 1/0 and 1.000 by construction.
- Infinite LR+/LR−/DOR render as empty cells, never as `9999`.
- AUPRC vs average precision are computed as genuinely different integrals; PR steps accumulate per distinct score, so ties do not make AUPRC depend on row order.

**Top issues:**

1. **Sensitivity/specificity CIs ignore `confidenceLevel`.** [`R/enhancedROC.b.R:2952-2956`](R/enhancedROC.b.R#L2952) — `.calculateBinomialCI()` calls `binom.test(successes, n)` with no `conf.level`, so it is always 95%. The `.r.yaml` column titles are hardcoded `Sensitivity 95% CI` / `Specificity 95% CI` ([`jamovi/enhancedROC.r.yaml:409`](jamovi/enhancedROC.r.yaml#L409)). A user who sets 90% gets a 90% AUC interval and a 95% sensitivity interval side by side in one pane, distinguished only by a column heading.

   ```r
   .calculateBinomialCI = function(successes, n) {
       bt <- suppressWarnings(binom.test(successes, n))   # conf.level defaults to 0.95
       return(bt$conf.int)
   }
   ```

2. **`clinicalContext` is in no `clearWith` list** (10 results) — see Integration. Toggling the context leaves stale clinical prose on screen across the whole pane.

3. **i18n is 45% untranslated and still splices untranslated English into translated sentences.** 376 distinct `.()` msgids in the backend (good `.()` discipline), but 117 are absent from `tr.po` and 54 have an empty `msgstr`. On top of that:
   - Two whole HTML panels carry **zero** `.()`: `.getInstructions()` ([`:3561-3625`](R/enhancedROC.b.R#L3561), the welcome/glossary panel, always visible) and `.populateClinicalInterpretation()` ([`:2692-2760`](R/enhancedROC.b.R#L2692)).
   - English fragments spliced through `%s` into translated sentences: `size_note` [`:1090`](R/enhancedROC.b.R#L1090), preset `changed` clauses [`:1300-1306`](R/enhancedROC.b.R#L1300), `lr_notes` [`:1878`](R/enhancedROC.b.R#L1878), `prc_recommendation` [`:2596`](R/enhancedROC.b.R#L2596), `predictor_text` [`:563`](R/enhancedROC.b.R#L563), the prevalence note HTML [`:1816`](R/enhancedROC.b.R#L1816).
   - Untranslated values in user-visible cells: `range_display` [`:2232`](R/enhancedROC.b.R#L2232), `paste("Custom", i)` [`:1679`](R/enhancedROC.b.R#L1679), `paste(metric, "(", pred1, "vs", pred2, ")")` [`:2046`](R/enhancedROC.b.R#L2046), raw enum names (`general`, `single`) in `comprehensiveAnalysisSummary` [`:2628`](R/enhancedROC.b.R#L2628), `"Treat All"`/`"Treat None"` legend entries [`:5645`](R/enhancedROC.b.R#L5645).
   - All 12 renderer failure messages are untranslated English literals (e.g. `"Failed to create ROC curve plot: "`), although `.plotDecisionImpact` at [`:5583`](R/enhancedROC.b.R#L5583) shows the corrected pattern.
   - `validate_clinical_data()`'s English error/warning strings are spliced into a `.()` notice at [`:600`](R/enhancedROC.b.R#L600).

4. **The "clinical" plot theme forces a white panel on jamovi's dark theme.** [`:3776`](R/enhancedROC.b.R#L3776), [`:3929`](R/enhancedROC.b.R#L3929), [`:4695`](R/enhancedROC.b.R#L4695) — `plotTheme` defaults to `clinical`, and that branch applies `panel.background = element_rect(fill = "white")`, `strip.background = "lightblue"` and `legend.background = "white"` **after** `ggtheme`. On jamovi's dark theme the axis text and title keep the theme's light foreground and are drawn on white.

   ```r
   if (self$options$plotTheme == "clinical") {
       p <- p + ggplot2::theme(
           panel.background  = ggplot2::element_rect(fill = "white"),
           legend.background = ggplot2::element_rect(fill = "white", color = "gray80"))
   }
   ```

   `.plotThemeFor()` at [`:3065`](R/enhancedROC.b.R#L3065) was explicitly rewritten to emit only incremental deltas for exactly this reason; these three inline blocks bypass it. Related: 11 of 12 renderers use the hardcoded `.getColorblindSafePalette()` and ignore `theme$palette`; only `.plotDecisionImpact` ([`:5570`](R/enhancedROC.b.R#L5570)) calls `jmvcore::colorPalette()`.

5. **CROC "early retrieval gain" is a difference between two differently-scaled areas.** [`:2440`](R/enhancedROC.b.R#L2440) computes `croc_auc - roc_auc` and `.interpretCROC()` grades it "Excellent / Good / Moderate early retrieval performance". The magnifier warps the FPR axis, so the difference is positive for essentially any better-than-random classifier and the column will nearly always read favourably. The code comment acknowledges this ("not a direct AUC gain"); the user-facing string does not. Minor, but it is a graded verdict a clinician will read. Same class of issue at [`:2514`](R/enhancedROC.b.R#L2514), where a large ROC-convex-hull gap is described as "may benefit from **recalibration**" — the hull gap is about threshold/discrimination geometry, not calibration.

6. **Three narrative panels render unconditionally** — `instructions`, `analysisSummary` and `clinicalReport` are all `visible: true` with no gating option, while the comparable `clinicalInterpretationGuide` and `methodsExplanation` are gated. The review checklist asks that educational/summary output render only when the user enables it. (`clinicalReport` is well guarded statistically: it *refuses* to write copy-ready sentences when AUC < 0.5 or no usable cutpoint exists — [`:3277`](R/enhancedROC.b.R#L3277).)

7. **Clinical readiness — NEEDS_VALIDATION, not NOT_READY.** The interpretive prose is unusually careful (apparent-vs-validated language, no fitness-for-care verdicts, equivalence-fallacy notes, prevalence-dependence of PPV/NPV spelled out, NND explicitly labelled prevalence-free). What blocks READY is (a) the events<10 severity gap, (b) the mixed 90%/95% intervals, (c) the absence of a registered reference-parity test — I found no `tests/verify_enhancedROC.R`, so pROC/caret parity is asserted by code inspection only.

#### Recommended remediation

- `/fix-notices enhancedROC` — add real `jmvcore::Notice` objects alongside the HTML panel, promote the events<10 guard from STRONG_WARNING to ERROR, and give the five silent handlers ([`:5077`](R/enhancedROC.b.R#L5077), [`:4944`](R/enhancedROC.b.R#L4944), [`:2252`](R/enhancedROC.b.R#L2252), [`:1563`](R/enhancedROC.b.R#L1563), [`:5762`](R/enhancedROC.b.R#L5762)) a user-visible explanation.
- `/jamovify-function enhancedROC --pattern=error --apply` — convert the 8 fatal validation paths to `jmvcore::reject()` so jamovi enters its error state; wrap only third-party calls in `tryCatch`.
- `/fix-function enhancedROC` — pass `conf.level = self$options$confidenceLevel / 100` to `binom.test()` and make the two column titles dynamic; add `clinicalContext` to 10 `clearWith` lists, `seed`/`bootstrapSamples` to 3, `direction` to 4; move `plotTheme` out of `enable: (rocCurve)`; fold the three inline "clinical" theme blocks into `.plotThemeFor()`; retire `tiedScoreHandling` and `multiClassAveraging` or implement them.
- `/prepare-translation enhancedROC` — regenerate `catalog.pot`, fill the 117 missing + 54 empty `tr.po` entries, wrap `.getInstructions()` and `.populateClinicalInterpretation()`, and replace the 6 English-fragment splices with complete per-branch msgids.
- `/review-function enhancedROC` — re-word `.interpretCROC()` / `.interpretConvexHull()`, and register a pROC/caret reference-parity test (`tests/verify_enhancedROC.R`) before promotion.
- `/update-refs enhancedROC` — add `DeLong1988` (already defined in `00refs.yaml`) to the analysis `refs:` block.
- Housekeeping: delete the 8 unreachable `@export`ed helpers in `R/enhancedROC-errors.R` (~370 of 478 lines) or drop their `@export` tags; remove the `cat()` at [`R/enhancedROC-errors.R:403`](R/enhancedROC-errors.R#L403).

### kappaSizeCI

**Status:** ✅ READY
**Files:** [`R/kappaSizeCI.b.R`](R/kappaSizeCI.b.R) · [`jamovi/kappaSizeCI.a.yaml`](jamovi/kappaSizeCI.a.yaml) · [`jamovi/kappaSizeCI.u.yaml`](jamovi/kappaSizeCI.u.yaml) · [`jamovi/kappaSizeCI.r.yaml`](jamovi/kappaSizeCI.r.yaml) · [`jamovi/js/kappaSizeCI.events.js`](jamovi/js/kappaSizeCI.events.js) · shared helper [`R/utils-kappasize.R`](R/utils-kappasize.R)
**Metrics:** .b.R LOC 885 · options 8 · outputs 4 · UI controls 8 · JS LOC 35 · `requiresData=FALSE` (no-variable calculator)

#### Security

No HIGH or MEDIUM findings. Categories A, B, C, E, F, G, H are clean: no `eval`/`parse(text=)`/`str2lang`, no string-built `do.call`/`get`/`match.fun`, no formulas at all, no filesystem/process/network/deserialization call, no `.asSource` codegen, no `library()` in `.b.R`, no debug flag.

Category D (XSS) is clean by construction and worth recording as the good pattern: the only free-text option is `props` (`type: String` → HIGH-tier source), and it is parsed to numbers and rejected at the trust boundary in [`R/kappaSizeCI.b.R:59-134`](R/kappaSizeCI.b.R#L59) before any use. Every value interpolated into the HTML in `.buildNotices()` is a formatted number (`.fmtN`, `.fmtCount`, `.fmtProp`) or a translated literal, so no user-controlled string reaches `self$results$notices$setContent()` at [`:865`](R/kappaSizeCI.b.R#L865). The panels also use `rgba()` tints plus `color: inherit`, which is the theme-safe HTML pattern.

- **[I-LOW]** [`R/kappaSizeCI.b.R:33`](R/kappaSizeCI.b.R#L33), [`:39`](R/kappaSizeCI.b.R#L39), [`:44`](R/kappaSizeCI.b.R#L44) — the kappa ordering comparisons have no `is.na()` guard. `kappaSizeCI(kappa0 = NA)` from the R wrapper makes `if (NA <= NA)` raise a bare `missing value where TRUE/FALSE needed` instead of a jamovi error state. Not reachable from the GUI (the TextBoxes are `format: number` over `OptionNumber(min, max)`), so it is an R-API-only hole. `.validateProportions()` is already immune — its `tryCatch` at [`:59`](R/kappaSizeCI.b.R#L59) converts the same `NA` case into a message.
- **[I-LOW]** [`R/kappaSizeCI.b.R:469`](R/kappaSizeCI.b.R#L469) — `jmvcore::reject(.("Error in sample size calculation: {}"), code = NULL, msg)` pushes the raw third-party `conditionMessage` through a positional `{}` template, bypassing the project's `.fmt()` brace-sanitiser (`R/utils.R:100`) that every other message in this file goes through. A `{` in a vendor error string can mis-drive `jmvcore::format`. Single placeholder, so impact is cosmetic.

#### jmvcore migration

- **[error]** [`R/kappaSizeCI.b.R:330`](R/kappaSizeCI.b.R#L330) — the `switch()` default arm is the one non-jmvcore error exit in the file:
  ```r
  "5" = kappaSize::CI5Cats,
  stop(.("Unsupported number of outcome categories"))
  ```
  → `jmvcore::reject(.("Unsupported number of outcome categories"))`. Unreachable today (`outcome` is an `OptionList` of `"2"`–`"5"`), so this is hygiene, not a live defect.

No other opportunities. There are no formulas, no `self$data`, no `na.omit`, no `as.numeric(factor)`, and no `.asSource()`; user-facing messages already use `jmvcore::reject` + `jmvcore::format` (via `.fmt`).

#### Integration

**Arguments declared:** 8 · **used in logic:** 8 · **dead:** 0

All of `outcome`, `citype`, `kappa0`, `kappaL`, `kappaU`, `props`, `raters`, `alpha` are read and change the computation. `kappaU` is correctly neutralised (`NA`) for one-sided at [`:238`](R/kappaSizeCI.b.R#L238) and disabled in the UI by `enable: (citype:two_sided)` — backend and `.u.yaml` agree, no enable drift. All 8 options have a `.u.yaml` control.

**Outputs declared:** 4 · **populated:** 4 · **unpopulated:** 0

`notices` (Html), `text1`, `text_summary`, `text2` (Preformatted) are all set at [`:862-865`](R/kappaSizeCI.b.R#L862) with type-correct setters. None is `visible: false`, so there is no permanently-invisible computed output. No Image outputs, so the `requiresData` renderer contract does not apply.

**clearWith:** complete — all 8 options are listed on all 4 result items.

**Citation refs:** 4 used (`ClinicoPathJamoviModule`, `kappaSize`, `rotondiDonnerKappaCI`, `donnerEliasziwKappaGOF`), all 4 defined in `jamovi/00refs.yaml` with non-empty author and year. No undefined, case-mismatched, or option-name entries.

**`.events.js`:** reads only `ui.outcome` and `ui.props`, both live `.a.yaml` options — no dead-option handler. The guard at [`kappaSizeCI.events.js:26-30`](jamovi/js/kappaSizeCI.events.js#L26) only rewrites `props` when the token count no longer matches the level count, and its binary case accepts 1 or 2 values, which matches `.validateProportions()`. That is the correct behaviour (an unconditional overwrite would reset a saved `.omv` on option binding).

**Menu:** `menuGroup: Power #meddecide` is the deliberate cross-cutting Power-menu trick — not a routing error. The trailing space on `menuSubgroup:` ([`kappaSizeCI.a.yaml:5`](jamovi/kappaSizeCI.a.yaml#L5)) is stripped by the YAML parser; `jamovi/0000.yaml:1444` confirms it lands in the same subgroup as its two siblings.

**Integration issue (robustness, not schema):**

| Output | Type | Setter | Populated? | Notes |
|---|---|---|:---:|---|
| `text_summary` | Preformatted | `setContent` | ✅ | Two post-processing rewrites match undocumented `kappaSize` print labels with `grepl()` and have no regression test — [`:821`](R/kappaSizeCI.b.R#L821) `"^KappaU:\\s*NA\\s*$"` and [`:835`](R/kappaSizeCI.b.R#L835) `"^Event Proportion:"`. If the vendor relabels either line the match silently stops firing and the user sees a bare `KappaU: NA` (reads as a failed calculation) or, for a binary design entered with prevalence > 0.5, the complement of their own assumption — the exact two bugs these lines were added to fix. `tests/testthat/test-kappasizeci-release-review.R` asserts `text_summary` content only for the `"less than five"` line. |

#### Notices coverage

There are **zero `jmvcore::Notice` objects** in this analysis — the only occurrence of the word is the explanatory comment at [`:683`](R/kappaSizeCI.b.R#L683). Consequently there is **no `Group$insert()` call anywhere**, so the `insert()` out-of-bounds hazard (review guide §13) does not apply here. All banners are HTML `<div>`s composed in `.buildNotices()` and written to the `notices` Html item, which is the **first** item in `.r.yaml`, so they render above the results; `.buildNotices()` returns `paste0(warn, info)` so warnings precede the methodology block. Fatal conditions correctly use `jmvcore::reject()`, which is the right error state for a data-free calculator.

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing / invalid required inputs | ERROR | ✅ | ✅ | 8 `jmvcore::reject()` sites; messages name the offending quantity and the fix (decimal-comma detection at [`:94`](R/kappaSizeCI.b.R#L94), "received {got}" count at [`:107`](R/kappaSizeCI.b.R#L107), "current sum is {sum}" at [`:118`](R/kappaSizeCI.b.R#L118)) |
| Unsizeable design / engine non-convergence | ERROR | ✅ | ✅ | [`:390`](R/kappaSizeCI.b.R#L390) refuses in microseconds *with the predicted n*; [`:455`](R/kappaSizeCI.b.R#L455)/[`:463`](R/kappaSizeCI.b.R#L463) give **opposite** advice for the two distinct causes (extreme prevalence vs narrow interval) — unusually good |
| Sparse expected cells | STRONG_WARNING (as HTML) | ✅ | ✅ | "smallest expected count is {min} and {below} of {total} cells are below 5"; remedy is outcome-aware (no "collapse categories" for a binary outcome) |
| Impractically large n | WARNING (as HTML) | ✅ | ✅ | `n > 1000`; its advice is reconciled with the sparse-cell advice so the two panels never contradict |
| Methodology summary | INFO (as HTML) | ✅ | ✅ | Names the estimand (intraclass/Fleiss κ of the common-correlation model), states the actual confidence percentage, and says explicitly when it does **not** coincide with Cohen's κ |
| Planning-expectation caveat | INFO (as HTML) | ✅ | ✅ | Flags that the vendor Summary pane's word "ensure" is an overclaim — a caveat most wrappers omit |

Only gap: because every banner is an HTML div rather than a `jmvcore::Notice`, none carries jamovi's semantic severity styling. That is the standing project-wide decision recorded in `CLAUDE.md` (notice content renders as escaped single-line plain text), not a defect of this analysis.

#### Code review

- **Overall quality:** 5 stars
- **Architecture:** OK — 17 private helpers, `.run()` ≈ 95 lines, no phantom `private$` methods (all 16 non-jamovi ones are defined in-file), no `if (FALSE)` / commented-out schema / TODO scaffolding, no writes to `self$options`, no unkeyed caches. The duplicated closed form was correctly extracted to `R/utils-kappasize.R` (3 callers ⇒ the `utils-<topic>.R` naming rule is satisfied).
- **`tryCatch` vs `reject()`:** 3 `tryCatch` sites against 8 `reject()` sites, and **no catch-all swallows a `reject()`**. `.prepareParameters()` and `.calculateSampleSize()` — the two reject-throwing steps — are deliberately called *outside* `.run()`'s display `tryCatch` ([`:792-795`](R/kappaSizeCI.b.R#L792) vs [`:802`](R/kappaSizeCI.b.R#L802)); the engine `tryCatch` at [`:429`](R/kappaSizeCI.b.R#L429) wraps only the vendor call and its handler *raises* `reject()` rather than eating it; and `private$.checkpoint()` sits outside it at [`:426`](R/kappaSizeCI.b.R#L426) because its restart is error-class. This is the reference pattern, not a finding.
- **Mathematical/statistical correctness:** CORRECT
  - Dispatch is right: `2 → CIBinary`, `3 → CI3Cats`, `4 → CI4Cats`, `5 → CI5Cats` ([`:324-331`](R/kappaSizeCI.b.R#L324)), with the proportion count validated against the declared category count and a single prevalence accepted for binary.
  - **The sparse-cell trap is handled correctly.** `.sparseVerdict()` ([`:164`](R/kappaSizeCI.b.R#L164)) evaluates `kappaSizeGofCells()` at `kappaL` and `kappaU` — the agreement-pattern cells the CI engine actually divides by — not the outcome marginals that `kappaSize`'s own print check tests. Cochran's rule is applied per confidence limit and reports the numbers from one coherent limit, so the counts shown always justify the warning shown.
  - Critical value: `qchisq(1-alpha, 1)` two-sided, `qchisq(1-2*alpha, 1)` one-sided ([`:297-300`](R/kappaSizeCI.b.R#L297)) — both give 100(1−α)%, consistent with the confidence level printed to the user.
  - `.predictedN()` is exact, not heuristic: the GOF statistic is `n × Σ(P_j(κ₀) − P_j(ρ))² / P_j(ρ)`, i.e. linear in n. It is used **only to triage**; the number reported to the user still comes from `kappaSize` itself. The binding limit is `min(slope)` — correct, since a two-sided design must clear the critical value at *both* limits.
  - `props` renormalised after a 0.001 sum check ([`:127`](R/kappaSizeCI.b.R#L127)); binary props sorted for the engine ([`:363`](R/kappaSizeCI.b.R#L363)) with the symmetry argument (the cell multiset is invariant under p ↔ 1−p with j ↔ raters−j, so n and the sparse verdict are unchanged) and the display restored afterwards.
  - **n denominator is stated, not left ambiguous** — the classic wrapper bug is absent: output reads "At least {n} subjects rated by {raters} raters …" ([`:674`](R/kappaSizeCI.b.R#L674)), and the vendor's "ensure" wording is explicitly corrected to a conditional ("if the observed kappa comes in at {kappa0}").
  - Validation evidence: `tests/testthat/test-kappasizeci-release-review.R` (517 lines, 27 blocks) includes direct reference-implementation parity against `kappaSize`, closed-form-vs-engine agreement, and order-invariance.
- **Clinical readiness:** READY — the analysis distinguishes itself from the power approach in prose, names the estimand, quantifies the sparse-cell risk, caps runaway searches with an actionable number instead of freezing, and warns that the sample size is a planning expectation rather than a guarantee.
- **i18n coverage:** PARTIAL
  - Source side is **complete**: 72 `.()` msgids, zero bare user-facing strings, no leading/trailing space inside `.()`, no `" ["` msgctxt-truncation hazard (bracketed intervals are passed in as values at [`:523`](R/kappaSizeCI.b.R#L523) and [`:672`](R/kappaSizeCI.b.R#L672)), no `\u{XXXX}` brace escapes inside msgids, and no named HTML entities — the symbols are written as `•`, `κ`, `—`, `“`.
  - `.("below 0.0001")` at [`:203`](R/kappaSizeCI.b.R#L203) is **absent from both `jamovi/i18n/catalog.pot` and `tr.po`** — the catalogs are stale relative to this file.
  - 62 of the 72 msgids have an empty Turkish `msgstr`. Module-wide `tr.po` is 70% empty, so this is the shared backlog rather than a function-specific regression.
- **UI label conventions:** `.u.yaml` is clean — group `Label`s are Title Case, control labels are sentence case ("Anticipated kappa (kappa0)", "Lower confidence limit"), no leading-verb checkbox labels, variable pickers N/A. The `.a.yaml` `title:` values are the weak spot: `raters`, `kappa0`, `kappaL`, `kappaU`, `alpha` are bare identifiers and `outcome`'s title is the ungrammatical "Number of outcome level". These surface in the generated `man/kappaSizeCI.Rd` and jamovi syntax mode.

**Top issues:**

1. [`R/kappaSizeCI.b.R:821`](R/kappaSizeCI.b.R#L821), [`:835`](R/kappaSizeCI.b.R#L835) — the two `text_summary` rewrites depend on undocumented `kappaSize` print labels via `grepl()` and are not covered by any test; a vendor relabel silently reinstates the two UX bugs they fix.
2. [`R/kappaSizeCI.b.R:33`](R/kappaSizeCI.b.R#L33), [`:39`](R/kappaSizeCI.b.R#L39), [`:44`](R/kappaSizeCI.b.R#L44) — no `is.na()` guard on the kappa ordering comparisons; `NA` via the R wrapper yields a bare R error instead of a jamovi error state.
3. i18n: `.("below 0.0001")` ([`:203`](R/kappaSizeCI.b.R#L203)) missing from `catalog.pot`/`tr.po`; 62/72 msgids untranslated in Turkish.
4. [`R/kappaSizeCI.b.R:330`](R/kappaSizeCI.b.R#L330) — `stop()` instead of `jmvcore::reject()` in the dispatch default.
5. [`jamovi/kappaSizeCI.a.yaml:35,84,100,131,148`](jamovi/kappaSizeCI.a.yaml#L35) — bare-identifier option titles (`raters`, `kappaL`, `kappaU`, `alpha`) and "Number of outcome level" (should be "levels").

**Strengths:** the sparse-cell diagnostic is computed on the correct (agreement-pattern) cells via the shared `kappaSizeGofCells()`; the runaway-search guard refuses with an actual number and cause-specific advice rather than hanging; the reject/tryCatch boundary is textbook.

#### Recommended remediation

- `/fix-function kappaSizeCI` — add `is.na()` guards to the three kappa comparisons ([`:33`](R/kappaSizeCI.b.R#L33), [`:39`](R/kappaSizeCI.b.R#L39), [`:44`](R/kappaSizeCI.b.R#L44)); route [`:469`](R/kappaSizeCI.b.R#L469) through `.fmt()`; swap the `stop()` at [`:330`](R/kappaSizeCI.b.R#L330) for `jmvcore::reject()`.
- `/generate-test-data kappaSizeCI` — add two regression tests pinning the `text_summary` rewrites: a one-sided run must not contain `KappaU: NA`, and a binary run with `props = "0.85, 0.15"` must print `Event Proportion: 0.85`, not `0.15`.
- `/prepare-translation kappaSizeCI` — regenerate `catalog.pot` so `.("below 0.0001")` is extracted, then fill the 62 empty Turkish `msgstr` entries.
- `.a.yaml` title pass (no slash command needed) — `raters` → "Number of raters", `kappa0` → "Anticipated kappa (kappa0)", `kappaL`/`kappaU` → "Lower/Upper confidence limit", `alpha` → "Significance level (alpha)", `outcome` → "Number of outcome levels".
- Housekeeping: three `TODO.md` entries for this analysis are now stale and can be closed — line 4920 (sparse detection "still greps the marginal warning" — fixed, it now uses `kappaSizeGofCells`), line 4925 (`jamovi/js/kappasizeci.js` lowercase leftover — the file no longer exists and `kappaSizeCI.events.js` is correctly bound), and line 4960 ("0 `.()` wraps across 69 prose strings" — now 72 wrapped msgids).
- No `/security-audit-function` needed (0 HIGH, 0 MEDIUM). No `/review-function` needed (statistics reviewed and CORRECT).

### kappaSizeFixedN

**Status:** ⚠️ NEEDS WORK (minor — i18n catalog staleness + one clinical-threshold notice gap; the statistics and wiring are sound)
**Files:** [`R/kappaSizeFixedN.b.R`](R/kappaSizeFixedN.b.R) · [`R/utils-kappasize.R`](R/utils-kappasize.R) · [`jamovi/kappaSizeFixedN.a.yaml`](jamovi/kappaSizeFixedN.a.yaml) · [`jamovi/kappaSizeFixedN.u.yaml`](jamovi/kappaSizeFixedN.u.yaml) · [`jamovi/kappaSizeFixedN.r.yaml`](jamovi/kappaSizeFixedN.r.yaml) · [`jamovi/js/kappaSizeFixedN.events.js`](jamovi/js/kappaSizeFixedN.events.js)
**Metrics:** .b.R LOC 365 · options 6 · outputs 4 · UI controls 6 · JS LOC 35 · `reject()` 12 call sites · `tryCatch` 1 call site

> **Brief corrections.** The task sheet says "13 `jmvcore::reject()`" and "3 `tryCatch` sites". Measured: **12** `reject()` call sites ([`#L154`](R/kappaSizeFixedN.b.R#L154), [`157`](R/kappaSizeFixedN.b.R#L157), [`170`](R/kappaSizeFixedN.b.R#L170), [`180`](R/kappaSizeFixedN.b.R#L180), [`186`](R/kappaSizeFixedN.b.R#L186), [`194`](R/kappaSizeFixedN.b.R#L194), [`199`](R/kappaSizeFixedN.b.R#L199), [`208`](R/kappaSizeFixedN.b.R#L208), [`216`](R/kappaSizeFixedN.b.R#L216), [`219`](R/kappaSizeFixedN.b.R#L219), [`266`](R/kappaSizeFixedN.b.R#L266), [`306`](R/kappaSizeFixedN.b.R#L306)) — the 13th grep hit is the comment at [`#L145`](R/kappaSizeFixedN.b.R#L145). And **1** `tryCatch` call site ([`#L257`](R/kappaSizeFixedN.b.R#L257)); [`#L145`](R/kappaSizeFixedN.b.R#L145) and [`#L254`](R/kappaSizeFixedN.b.R#L254) are comments naming it.

#### Security

Categories A–I scanned. No HIGH, no MEDIUM.

- **[D-LOW]** [`R/kappaSizeFixedN.b.R:322-328`](R/kappaSizeFixedN.b.R#L322) — the free-text `type: String` option `props` reaches user-visible output as **raw text tokens** (`parsed$tokens`, not the parsed numbers) via `private$.formatProps()`. Currently unexploitable: `.validateInputs()` runs first at [`#L243`](R/kappaSizeFixedN.b.R#L243) and rejects any token that is not a finite number in (0,1) ([`#L156`](R/kappaSizeFixedN.b.R#L156), [`#L193`](R/kappaSizeFixedN.b.R#L193)), so the reachable alphabet is digits / `.` / `e` / sign / whitespace, and the sink is `Preformatted`, not `Html`. Defense-in-depth only: if the validate-then-render order is ever inverted, or a token is echoed into the `notices` `Html` panel, this becomes a live D1. Recommend echoing the *parsed numbers* rather than the raw tokens.

Verified clean, with the trace:

- **A/B** — no `eval`/`parse(text=)`/`str2lang`/`do.call`/`get`/`match.fun`. The engine is chosen by `switch()` over the already-validated closed enum ([`#L245-251`](R/kappaSizeFixedN.b.R#L245)), not by name lookup.
- **C** — no formula construction anywhere.
- **D** — `notices` is the only `Html` sink ([`#L357`](R/kappaSizeFixedN.b.R#L357)); every interpolated value is numeric (`.fmtBound`, `.fmtCount`, two integer counts). No user string reaches it. `tools/theme_safe_html.py` on this file: **0 rewrites needed** — the three `<div>` blocks already use translucent `rgba()` tints with `color: inherit` ([`#L65-67`](R/kappaSizeFixedN.b.R#L65)), the theme-safe pattern.
- **E/F** — no filesystem, process, network or deserialization calls.
- **G** — no `.asSource()` / `.sourcifyOption()`.
- **H** — no `library()`, no debug flag, no top-level executable code, no duplicate top-level symbol. `kappaSize::` and `utils::` are namespace-qualified; `kappaSize` is in `Imports:` of both `DESCRIPTION` and the meddecide sibling.
- **I** — the one vendor-controlled string, `conditionMessage(e)` at [`#L269`](R/kappaSizeFixedN.b.R#L269), is routed through `.fmt()` ([`R/utils.R:100`](R/utils.R#L100)), which neutralises braces and so cannot trigger the `jmvcore::format` self-referential-placeholder hang.
- **trycatch-swallows-reject: NOT present.** The single `tryCatch` wraps *only* the third-party `kappa_fn(...)` call; `.validateInputs()` is invoked outside it at [`#L243`](R/kappaSizeFixedN.b.R#L243), and the `reject()` inside the handler is raised after unwinding, so it propagates. This is the pattern review guide §15–18 prescribes.
- No phantom `private$` methods — all 7 called helpers (`.parseProps`, `.wrap`, `.fmtBound`, `.fmtCount`, `.buildNotices`, `.formatProps`, `.validateInputs`) are defined in this file.
- No `self$options$X <- …` writes, no `setVisible()` used as an error mechanism.
- **JS** — no `innerHTML`, no dynamic `Function`, no string-bodied timers, no `DEBUG = true`.

#### jmvcore migration

*No migration opportunities found.*

Two would-be false positives, noted so a later pass does not "fix" them:

- `as.numeric(self$options$outcome)` / `as.numeric(self$options$raters)` ([`#L234`](R/kappaSizeFixedN.b.R#L234), [`#L236`](R/kappaSizeFixedN.b.R#L236)) are **not** `jmvcore::toNumeric()` candidates — these are `OptionList` *character* values (`"2"`…`"6"`), and `toNumeric()` is a documented no-op on character/factor. `as.numeric()` is the correct call here.
- All user-facing validation already uses `jmvcore::reject(.(…), code = NULL)`; there is not a single `stop()` in the file.

#### Integration

**Arguments declared:** 6 · **used in logic:** 6 · **dead:** 0

All of `outcome`, `kappa0`, `props`, `raters`, `alpha`, `n` are read and change the computation. Pinned by a regression test (`tests/testthat/test-kappasizefixedn-release-review.R`, "every declared option is read by the backend"). No table needed.

**Outputs declared:** 4 · **populated:** 4 · **unpopulated:** 0 · **permanently invisible:** 0

`notices` (`Html` → `setContent`), `text1`, `text_summary`, `text2` (all `Preformatted` → `setContent`). All four are blanked at the top of `.run()` ([`#L229-232`](R/kappaSizeFixedN.b.R#L229)) so a rejected re-run cannot leave the previous run's numbers on screen under the error — a genuinely good pattern most analyses in this module lack.

**clearWith:** complete. All four items list all six options; the release-review test asserts `expect_setequal` per item, so drift is caught.

**Citation-ref integrity:** 4 used / 4 defined / **0 dangling**. `ClinicoPathJamoviModule`, `kappaSize`, `donnerEliasziwKappaGOF`, `rotondiDonnerKappaCI` all resolve in `jamovi/00refs.yaml` with non-empty author, year and doi/url. The two methodological papers credited in the Methodology prose are the two that are cited — a test pins that link.

**Engine dispatch mapping — verified correct.** `"2"→FixedNBinary`, `"3"→FixedN3Cats`, `"4"→FixedN4Cats`, `"5"→FixedN5Cats` ([`#L245-251`](R/kappaSizeFixedN.b.R#L245)). All four exist as exported topics in the installed kappaSize 1.2 (`help/AnIndex`). The `switch()` has no default, but `.validateInputs()` rejects any non-`2/3/4/5` at [`#L153`](R/kappaSizeFixedN.b.R#L153) before it, so no `NULL(args)` path exists.

**JS — no dead options.** `kappaSizeFixedN.events.js` reads exactly `ui.outcome` and `ui.props`; both are live `.a.yaml` options. The handler is correctly *conditional* (it rewrites `props` only when the token count no longer matches the new level count), so binding-time `change` events cannot silently reset a saved `.omv` back to the template.

**menuGroup / menuSubgroup — benign, not a mis-sort.** `menuGroup: Power #meddecide` is the deliberate cross-cutting Power-menu trick (not reported as a routing error). The **leading double space** in `menuSubgroup:  Power Analysis by meddecide` is stripped by YAML: PyYAML parses it to `'Power Analysis by meddecide'`, and both `jamovi/0000.yaml:1460` (umbrella) and `meddecide/jamovi/0000.yaml:99` compile to the identical string as `kappaSizeCI`. **No mis-sort — all three kappaSize analyses land in the same subgroup.** Cosmetic only: `kappaSizeCI.a.yaml:5` uses one space plus a trailing space, `kappaSizeFixedN`/`kappaSizePower` use two leading spaces. Worth normalising for diff hygiene, nothing more.

**Sibling sync:** `R/kappaSizeFixedN.b.R`, `R/utils-kappasize.R` and `jamovi/js/kappaSizeFixedN.events.js` are **byte-identical** to the generated meddecide copies. No stale-submodule risk for this analysis.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing/invalid required inputs | ERROR | ✅ | ✅ | No-variable calculator: surfaced via 12 `jmvcore::reject()` sites, which *is* jamovi's error state. A `Notice ERROR` would be wrong here. |
| Bound at or below zero (study cannot exclude chance agreement) | STRONG_WARNING | ✅ | ✅ | Red block, [`#L80-86`](R/kappaSizeFixedN.b.R#L80); quotes the bound and lists only the three remedies that actually move it the right way (the comment documents that "use a less extreme prevalence" *lowers* the bound in this region — a real, measured correction). |
| Assumption violation — sparse chi-square cells | STRONG_WARNING | ✅ | ✅ | [`#L92-104`](R/kappaSizeFixedN.b.R#L92); reports smallest expected count, count below 5, and total cells, and explains why it disagrees with kappaSize's own looser marginal check. |
| Methodology summary | INFO | ✅ | ✅ | [`#L106-129`](R/kappaSizeFixedN.b.R#L106); names the estimand, the sidedness, the 0.001 search resolution, the "half of such studies do worse" caveat, and the kappa0-means-something-else-in-kappaSizePower hazard. |
| **Positive but clinically inadequate bound (0 < kappaL < ~0.40)** | **WARNING** | **❌** | — | **Genuine gap.** The only severity trigger is `kappaL <= 0`. A design returning kappaL = 0.15 produces a clean green panel, yet it cannot rule out "slight" agreement in Landis–Koch terms. This is the direct analogue of the checklist's "AUC < 0.7 → STRONG_WARNING" rule for a diagnostic analysis. |
| **kappa benchmark scale for the returned number** | **INFO** | **❌** | — | The panel never tells a pathologist what 0.45 *means*. One line citing Landis–Koch (or Altman) would close it; the ref machinery is already wired. |

**0 `jmvcore::Notice` and 0 `setNote()` — assessed, and appropriate here.** This is not a coverage gap: the project's standing decision (CLAUDE.md) is that `Notice` content renders as escaped plain text with no newlines, so the richer multi-line HTML panels stay. The `notices` `Html` item is declared *first* in `.r.yaml`, so severity content lands above the numbers — correct positioning. `release_gate.py` reports **0 hits** for this analysis on every check (including `check_sentinel_insert`, `check_state_guards`, `check_column_formats`, `check_fabricated_stats`, notice title colours and non-structural HTML entities).

#### Code review

- **Overall quality:** 5 stars
- **Architecture:** OK. `.run()` is ~140 lines with 7 extracted private helpers; the previously-triplicated goodness-of-fit closed form is factored into [`R/utils-kappasize.R`](R/utils-kappasize.R) with a derivation comment and a stated verification tolerance (binomial to 1e-11, K=3..5 polynomials to 1e-15). That file-level helper correctly contains **no** `.()` call, so it cannot hit the "object 'self' not found" trap.
- **Mathematical/statistical correctness:** CORRECT
- **Clinical readiness:** READY
- **i18n coverage:** PARTIAL

**Domain verification (the items the brief asked to check hard):**

1. **The `props` semantics trap — handled correctly.** `props4` (the *marginals*) is passed as **input** to `kappaSizeGofCells()` at [`#L282`](R/kappaSizeFixedN.b.R#L282), and the Cochran test at [`#L356-363`](R/kappaSizeFixedN.b.R#L356) runs on `e <- cells * n`, i.e. on the **agreement-pattern cells**, not the marginals. The Methodology block explicitly tells the user that kappaSize's own printed "expected cell count is less than five" line is *a different and looser check on the marginals*, and that seeing one without the other is expected ([`#L127`](R/kappaSizeFixedN.b.R#L127)). That cross-reference is correctly made conditional on `sparse_cells` ([`#L128`](R/kappaSizeFixedN.b.R#L128)) so it never dangles.
2. **Proportion count vs declared category count — enforced.** Binary accepts 1 or 2 values (matching `FixedNBinary`'s own `props <- props[1]`) at [`#L178-184`](R/kappaSizeFixedN.b.R#L178); 3/4/5 require exactly N at [`#L185-191`](R/kappaSizeFixedN.b.R#L185). Cell-vector length is therefore `raters+1` (binary) or `outcome+1` (multi-category), matching `sparse_total` in the message.
3. **Sum-to-1 uses the engine's own predicate** (`abs(sum - 1) >= 0.001`, [`#L198`](R/kappaSizeFixedN.b.R#L198)) rather than `all.equal(tolerance = 1e-3)`, so no sum can slip past the readable message into the vendor one — including the 1.001 knife edge, which a test pins on both sides.
4. **Lower-bound interpretation is stated, and stated consistently.** `text2` says "the one-sided {conf}% lower confidence bound … the smallest agreement the study would still be unable to rule out; every value below it is excluded" ([`#L342-345`](R/kappaSizeFixedN.b.R#L342)), with `conf = 100 * (1 - alpha)`; the Methodology block repeats "the lower bound of the one-sided 100(1 - alpha)% confidence interval" ([`#L108`](R/kappaSizeFixedN.b.R#L108)). `alpha` is passed to the engine unhalved, which is the correct one-sided form given the `qchisq(1 - 2*alpha, 1)` critical value documented in [`R/utils-kappasize.R:20-23`](R/utils-kappasize.R#L20). **Caveat:** the audit is bound by "do not run R", so I confirmed the *stated* interpretation, the consistency between panes, and the repo's recorded verification — I did not re-execute the engine to re-derive its critical value.
5. **Out-of-model bound guard is the standout piece of work.** [`#L298-310`](R/kappaSizeFixedN.b.R#L298) tests the Dirichlet-multinomial **factors**, not the cell products, because for 3–5 categories an even number of sign flips makes the product positive again and an out-of-model bound sails through a naive `any(cells < 0)`. Two concrete counterexamples are recorded in the comment and both are pinned as tests. This is the kind of defect that would otherwise print a confident `-0.704` to a planner.
6. **Are the rejects thorough, or boilerplate?** **Thorough, with ~5 deliberate redundancies.** The 7 that do real work are the five `props` clauses (parse failure, decimal comma, count, range, sum) plus the two engine guards (vendor error, out-of-model). The other 5 — `outcome` enum [`#L153`](R/kappaSizeFixedN.b.R#L153), `n >= 11` [`#L207`](R/kappaSizeFixedN.b.R#L207), `kappa0` range [`#L215`](R/kappaSizeFixedN.b.R#L215), `alpha` range [`#L218`](R/kappaSizeFixedN.b.R#L218) — duplicate bounds the compiled option classes already enforce (`R/kappaSizeFixedN.h.R` shows `min=11`, `min=0.01/max=0.99`, `min=0.001/max=0.2`, and the `OptionList` enum). The file *documents* them as deliberate backstops at [`#L146-149`](R/kappaSizeFixedN.b.R#L146), so this is a design choice, not sloppiness — but see issue 4 below for its cost.

**Top issues:**

1. **[i18n-partial] The translation catalogs are stale for this file — 3 strings can never be translated.** `catalog.pot` is dated 13:23 today, `R/kappaSizeFixedN.b.R` 21:14. Parsing both catalogs against the 36 `.()` literals in the backend: **`.("below 0.0001")` [`#L55`](R/kappaSizeFixedN.b.R#L55)**, the "If the Analysis result panel also prints…" sentence **[`#L127`](R/kappaSizeFixedN.b.R#L127)** and "The warning above is the check that matters…" **[`#L129`](R/kappaSizeFixedN.b.R#L129)** appear in neither `catalog.pot` nor `tr.po`. Separately, `.("unavailable")` **[`#L54`](R/kappaSizeFixedN.b.R#L54)** exists in `tr.po` with an **empty `msgstr`**, and its `#:` reference list credits `cotest.b.R` / `kappaSizeCI.b.R` / `kappaSizePower.b.R` but not this file. `"below 0.0001"` is missing for **all three** kappaSize siblings, so this is a small cross-cutting item, not a kappaSizeFixedN-only one. `release_gate.py`'s i18n check only looks for *unused* msgids, so it does not catch this direction. Fix: `jmvtools::i18nUpdate()`, then translate the four entries.
2. **[notice-threshold-gap / clinical-readiness] No warning for a positive-but-inadequate bound.** Only `kappaL <= 0` triggers a severity block ([`#L80`](R/kappaSizeFixedN.b.R#L80)). Add a WARNING block for roughly `0 < kappaL < 0.40` — "this design can only rule out agreement below {bound}, which is still within the *slight/fair* range (Landis & Koch); the study will not be able to demonstrate substantial agreement" — plus the benchmark scale as an INFO line. This is the single most clinically consequential omission in an otherwise exemplary file.
3. **[LOW] The `n` reject message promises a check the code does not perform.** [`#L207`](R/kappaSizeFixedN.b.R#L207) tests `!is.finite(n) || n < 11`, but the message at [`#L210`](R/kappaSizeFixedN.b.R#L210) says "must be a **whole number** of at least 11". Integrality is enforced only by `OptionInteger`; as an R-caller backstop this clause does not do what it says. Add `|| n != round(n)` (one term) or drop the words.
4. **[LOW] Five translated backstop messages are unreachable from the GUI.** Because the compiled option bounds fire first, a jamovi user entering `alpha = 0.5` sees **jmvcore's** generic "between 0.001 and 0.2", never the backend's carefully worded, `.()`-wrapped "Significance level (alpha) must be between 0.001 and 0.20." Same for `n`, `kappa0` and the `outcome` enum — the test suite confirms this (`expect_error(fn_run(alpha = 0.5), "between")` matches jmvcore's string). Net effect: four translatable strings are carried in the catalog for messages no user can reach, while the message users *do* get is jmvcore's. Keep the backstops (cheap, correct), but do not invest translation effort in them.
5. **[LOW, cosmetic] `.a.yaml` `title:` values for `kappa0`, `raters` and `alpha` are bare lowercase jargon tokens** ("kappa0", "raters", "alpha"), while the `.u.yaml` labels are properly sentence-cased ("Anticipated kappa (kappa0)", "Raters", "Alpha"). The `.u.yaml` wins in the GUI, so this only affects the generated `man/` page. No leading-verb violations anywhere; section headings are correctly Title Case and control labels correctly sentence case; no `CollapseBox` needed for 6 essential controls; no `VariableSupplier` ordering issue (no-variable calculator).

**Strengths worth carrying to sibling analyses:** the blank-the-panels-first pattern ([`#L229`](R/kappaSizeFixedN.b.R#L229)); the seven-significant-digit `.fmtBound` that makes every pane agree with the engine's own `cat()` output; `.fmtCount`'s `scientific = FALSE` floor (without it, 64 of 120 swept designs told a pathologist "the smallest expected count is 2.4e-06"); the conditional cross-reference that prevents a dangling "the warning above"; and the explicit "kappa0 means the anticipated value *here* and the null value in kappaSizePower" hazard note — two analyses in one menu taking an identically-named argument with opposite meanings is exactly how a confidently wrong sample size gets published.

#### Recommended remediation

- `jmvtools::i18nUpdate()` in the umbrella, then translate the 4 entries — applies to `kappaSizeCI` and `kappaSizePower` too (`"below 0.0001"` is missing for all three). Then `/prepare-translation kappaSizeFixedN`.
- `/fix-notices kappaSizeFixedN` — add the `0 < kappaL < 0.40` WARNING block and a Landis–Koch benchmark INFO line to `.buildNotices()`; keep the existing HTML-panel approach (do not migrate to `jmvcore::Notice`).
- One-line edit at [`R/kappaSizeFixedN.b.R:207`](R/kappaSizeFixedN.b.R#L207): add `|| n != round(n)` so the clause matches its own message.
- Optional hygiene: echo parsed numbers rather than raw tokens in `prev_txt` ([`#L322`](R/kappaSizeFixedN.b.R#L322)); normalise the `menuSubgroup:` leading whitespace across the three kappaSize `.a.yaml` files (benign today).
- **No** `/security-audit-function`, **no** `/jamovify-function`, **no** `/check-function-full` needed — security is clean, there are no migration opportunities, and the analysis is fully wired with a 465-line regression suite already pinning the behaviour.

### kappaSizePower

**Status:** ✅ READY
**Files:** [`R/kappaSizePower.b.R`](R/kappaSizePower.b.R) · [`R/utils-kappasize.R`](R/utils-kappasize.R) · [`jamovi/kappaSizePower.a.yaml`](jamovi/kappaSizePower.a.yaml) · [`jamovi/kappaSizePower.u.yaml`](jamovi/kappaSizePower.u.yaml) · [`jamovi/kappaSizePower.r.yaml`](jamovi/kappaSizePower.r.yaml) · [`jamovi/js/kappaSizePower.events.js`](jamovi/js/kappaSizePower.events.js)
**Metrics:** .b.R LOC 424 · options 7 · outputs 4 · UI controls 6 · JS LOC 35

#### Security

*No findings in profile standard.*

Scanned A–I. Why each category is clean:

- **A/B/C/F** — no `eval`/`parse`/`str2lang`, no `do.call` with a variable function, no formulas, no deserialization. Engine dispatch is a literal-mapped `switch()` over a closed `type: List` ([`R/kappaSizePower.b.R:352`](R/kappaSizePower.b.R#L352)).
- **D (XSS)** — the only HTML sink is `notices$setContent()` fed by `.buildNotices()`. Every interpolated value is numeric-derived (`.fmtN`, `.fmtCount`, `signif()`, `kappa0`/`kappa1`/`power` from `type: Number` options). `props`, the sole free-text `type: String` option, is parsed to numeric and `reject()`ed unless every token reads as a number ([`R/kappaSizePower.b.R:268`](R/kappaSizePower.b.R#L268)); its formatted form reaches only the **Preformatted** `text2` pane, never the HTML panel. No reachable injection path.
- **E/G/H** — no filesystem, process, network, `library()`, debug flag, `.asSource`/`.sourcifyOption` override, or dead top-level probe.
- **I** — `is.finite()`/`isTRUE()`/`anyNA()` guards throughout; no whole-frame NA coercion, no `class(x) ==` comparison, no cached R6 helper.
- The HTML notice blocks are already theme-safe: `rgba()` tints plus `color: inherit`, no opaque hex background ([`R/kappaSizePower.b.R:118-119`](R/kappaSizePower.b.R#L118)).

#### jmvcore migration

*No migration opportunities found.*

All nine validation paths already use `jmvcore::reject(..., code = )`; string building uses the project `.fmt()` wrapper over `jmvcore::format`. `base::format()` is explicitly namespaced at [`:52`](R/kappaSizePower.b.R#L52), [`:60`](R/kappaSizePower.b.R#L60) and [`:71`](R/kappaSizePower.b.R#L71), correctly dodging the `library(jmvcore)` masking of `base::format()`. `as.integer(self$options$outcome)` operates on a character `List` value, not a factor — not a `jmvcore::toNumeric` case.

#### Integration

**Arguments declared:** 7  ·  **used in logic:** 7  ·  **dead:** 0

No findings. `outcome`, `kappa0`, `kappa1`, `props`, `raters`, `alpha`, `power` all reach computation; `tests/testthat/test-kappasizepower-release-review.R:322` pins this with a schema-vs-backend sweep.

**Outputs declared:** 4  ·  **populated:** 4  ·  **unpopulated:** 0

No findings. `notices` (Html) and `text1`/`text_summary`/`text2` (Preformatted) are each cleared at the top of `.run()` and re-populated. None is `visible: false`; none is permanently invisible.

Other integration checks:

- **clearWith completeness** — all four results list all seven options. Complete; no stale-pane path.
- **Citation refs** — `ClinicoPathJamoviModule`, `kappaSize`, `rotondiDonnerKappaCI`, `donnerEliasziwKappaGOF` are all defined in `jamovi/00refs.yaml` (lines 220, 2835, 3775, 1974). No USED-but-UNDEFINED, no case mismatch. The Methodology block's "(Rotondi and Donner)" attribution is backed by both cited papers.
- **`menuGroup: Power #meddecide`** — verified as the deliberate cross-cutting Power-menu trick; `#meddecide` is a YAML comment and PyYAML yields `menuGroup='Power'`. Not a routing error.
- **`menuSubgroup` leading space — NOT a defect.** The extra space at [`jamovi/kappaSizePower.a.yaml:5`](jamovi/kappaSizePower.a.yaml#L5) is post-colon indentation, which YAML strips from a plain scalar. PyYAML yields `'Power Analysis by meddecide'`, and the compiled `jamovi/0000.yaml:1476` carries the same unpadded value. The menu sorts correctly; no action.
- **`.events.js` option integrity** — reads only `ui.outcome` and `ui.props`, both live in the `.a.yaml`. No `js-dead-option`. The guard that overwrites `props` only when the token count no longer matches the level count is correct and mirrors the backend's binary 1-or-2 rule.
- **Renderer data contract** — N/A: no `Image` outputs, no `self$data` access, `requiresData=FALSE` in the generated header. Correct for a no-variable calculator.
- **`tryCatch` vs `reject()`** — the single `tryCatch` ([`:359`](R/kappaSizePower.b.R#L359)) wraps **only** the `powerFun(...)` engine call; all nine `reject()` sites sit outside it. No swallowed validation. (Count note: the brief's "13→10" is a grep artefact — the file holds **9** `jmvcore::reject()` calls plus one mention in a comment at `:12`.)
- **`Group$insert()` safety** — zero `insert()` calls in the file. Safe by construction; the brief's "1 Notice use" is the comment at `:110`, not a call (see Notices coverage).

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing / invalid required inputs | ERROR | ✅ | ✅ | 9 `jmvcore::reject()` paths ([`:268`](R/kappaSizePower.b.R#L268)–[`:368`](R/kappaSizePower.b.R#L368)); each names the offending value |
| Very small n (< 10 subjects) | STRONG_WARNING | ✅ | ✅ | [`:165`](R/kappaSizePower.b.R#L165); prints the actual n, pluralised via `.subjects()` |
| Very large n (> 2000) | STRONG_WARNING | ✅ | ✅ | [`:154`](R/kappaSizePower.b.R#L154); names all three inflators rather than blaming one |
| Assumption violation — sparse GOF cells | STRONG_WARNING | ✅ | ✅ | [`:198`](R/kappaSizePower.b.R#L198); Cochran rule, prints min expected count and `below/total` |
| Assumption violation — rare outcome marginal | STRONG_WARNING | ✅ | ✅ | [`:223`](R/kappaSizePower.b.R#L223); independent of the cell block, deliberately un-gated so both can fire |
| Transposed kappa pair (kappa1 < kappa0) | WARNING | ✅ | ✅ | [`:130`](R/kappaSizePower.b.R#L130); names both values and states the two orderings differ |
| Near-identical kappas (< 0.05 apart) | WARNING | ✅ | ✅ | [`:143`](R/kappaSizePower.b.R#L143); prints the delta |
| Power below 0.50 | WARNING | ✅ | ✅ | [`:173`](R/kappaSizePower.b.R#L173) |
| Methodology summary | INFO | ✅ | ✅ | [`:232`](R/kappaSizePower.b.R#L232); names the estimator, the package, two-sidedness, the weighted-kappa exclusion, the `kappa0` semantic difference vs. the siblings, and the resulting n |

Coverage is complete in **content**. Two mechanism notes:

- **Zero `setNote()` is NOT a gap.** There are no `Table` outputs in the `.r.yaml`, so `setNote()` has nothing to attach to. All messaging is delivered through the `notices` Html panel, which is the first item in the results tree. No action.
- **Zero `jmvcore::Notice` objects, and the stated reason is retracted.** [`R/kappaSizePower.b.R:109-110`](R/kappaSizePower.b.R#L109) justifies the HTML panel with *"those cannot be serialised when inserted dynamically"*. That premise was corrected on 2026-09-22: `jmvcore::Notice` serialises correctly, and the `attempt to apply non-function` failure belonged to `Group$insert()`'s missing bounds check. The **decision** to keep the HTML panel is still right (the panel is multi-block and uses `<b>`/`<div>`, which Notice content cannot carry), but the comment propagates a false rule to anyone copying this file. Rewrite it to cite the real reason (escaped-plain-text rendering, no newlines) — comment-only, no behaviour change.

#### Code review

- **Overall quality:** 5 stars
- **Architecture:** OK. `.run()` is ~176 lines ([`:248`](R/kappaSizePower.b.R#L248)–424) — above the 100-line heuristic, but it is a linear validate → dispatch → populate sequence with all formatting, explanation and notice construction already extracted into seven private helpers, and the shared GOF closed form lifted to [`R/utils-kappasize.R`](R/utils-kappasize.R) so the trio cannot drift. Splitting further would not reduce complexity.
- **Mathematical/statistical correctness:** CORRECT
- **Clinical readiness:** READY
- **i18n coverage:** PARTIAL

**Statistical verification (domain checks from the brief):**

- **Engine dispatch is correct.** `2 → kappaSize::PowerBinary`, `3 → Power3Cats`, `4 → Power4Cats`, `5 → Power5Cats` ([`:352`](R/kappaSizePower.b.R#L352)). `raters` is restricted to 2–6, matching kappaSize 1.2's supported range.
- **The `props` semantics trap is handled correctly.** The sparse check uses `kappaSizeGofCells(outcome, raters, props, kappa0)` ([`:407`](R/kappaSizePower.b.R#L407)) — the **agreement-pattern** cells, evaluated at `kappa0`, which [`R/utils-kappasize.R:19`](R/utils-kappasize.R#L19) documents as the right level for a `Power*` engine. The outcome **marginals** are checked *in addition* ([`:413`](R/kappaSizePower.b.R#L413)), not instead, precisely because one rare category in a 4/5-level design puts exactly one of six cells below 5 and slips under the 20% Cochran threshold. This is the better of the two possible readings of the trap.
- **Proportion count matches the declared cardinality.** Binary accepts 1 or 2 values ([`:296`](R/kappaSizePower.b.R#L296)); 3/4/5 require exactly `outcome` values ([`:299`](R/kappaSizePower.b.R#L299)); sum-to-1 enforced within 1e-3 ([`:308`](R/kappaSizePower.b.R#L308)) then **renormalised** ([`:326`](R/kappaSizePower.b.R#L326)) — the comment documents a real measured case where verbatim `0.0003/0.0003/0.9999` drove the lumped cell negative and returned `N = -380296.1`, which `ceiling()` happily printed.
- **Input validation is complete.** `kappa0`/`kappa1`/`alpha`/`power` ranges are enforced by the generated `OptionNumber` classes (kappa 0.01–0.99, alpha 0.001–0.20, power 0.01–0.99 — `R/kappaSizePower.h.R:32-68`), so "both in (0,1)" holds at the wrapper boundary. `alpha >= power` is rejected ([`:338`](R/kappaSizePower.b.R#L338)) — this prevents a documented non-interruptible hang in `kappaSize:::.hichi`, a genuine freeze-the-app bug. `kappa0 == kappa1` is rejected ([`:346`](R/kappaSizePower.b.R#L346)).
- **`kappa1 > kappa0` is deliberately NOT enforced, and that is the right call.** A reversed pair is a legitimate (if rarer) design — "show agreement is worse than the null" — and the engine answers it, so rejecting it would block valid work. It is not silent: [`:130`](R/kappaSizePower.b.R#L130) raises a named warning block that states the direction, prints both values, and says the two orderings do not give the same n.
- **n is total subjects, and it is stated.** "Required sample size: **{n}** subjects, each rated by all {raters} raters" ([`:240`](R/kappaSizePower.b.R#L240)) — no per-rater ambiguity.
- **Two-sidedness is stated twice** ([`:97`](R/kappaSizePower.b.R#L97) and [`:235`](R/kappaSizePower.b.R#L235)), consistent with the Donner–Eliasziw 1-df goodness-of-fit chi-square. Not re-derived from the kappaSize internals in this audit (no R execution), but `tests/testthat/test-kappasizepower-release-review.R:49-66` pins exact parity against `kappaSize::Power*` over five cardinality/rater cases, and the file header records a 540-combination sweep with zero disagreement.
- The Methodology block also warns that the analysis does **not** cover weighted kappa for ordered grades, and that `kappa0` means something different here than in `kappaSizeCI`/`kappaSizeFixedN` — a real cross-analysis trap for the trio, handled.

**Top issues:**

1. **i18n — one string can never be translated, three are untranslated.** `"below 0.0001"` ([`R/kappaSizePower.b.R:52`](R/kappaSizePower.b.R#L52)) appears in **none** of `jamovi/i18n/catalog.pot`, `en.po` or `tr.po` — the catalogs are stale against current source. Separately, three msgids used here carry an empty `tr` msgstr: `"Rare outcome category."`, `"At the required sample size the rarest outcome category is expected in only {min} subjects…"`, and `"unavailable"`. The other 38 of the 42 `.()` strings are wrapped, placeholder-based, concatenation-free, free of leading/trailing punctuation, and free of the `" ["` msgctxt truncation trap. `.fmtCount` is byte-identical across the trio, so the extraction gap affects `kappaSizeCI` and `kappaSizeFixedN` too — fix once, at catalog level.
2. **Markup inside a translatable msgid.** [`:240`](R/kappaSizePower.b.R#L240) — `.("Required sample size: <b>{n}</b> {subjects}, each rated by all {raters} raters.")`. A translator dropping or unbalancing `<b>` corrupts the HTML panel. Move the tags outside the `.()` and interpolate the bolded number.
3. **Stale rationale comment on the Notice decision.** [`:109-110`](R/kappaSizePower.b.R#L109) repeats the retracted "Notice cannot be serialised" claim. Comment-only, but it is exactly the kind of note that gets copied into the next analysis.

**Minor / LOW (non-blocking):**

- **`.a.yaml` `title:` values are bare identifiers** — `kappa0`, `kappa1`, `raters`, `alpha`, `power` ([`:49`](jamovi/kappaSizePower.a.yaml#L49), [`:67`](jamovi/kappaSizePower.a.yaml#L67), [`:100`](jamovi/kappaSizePower.a.yaml#L100), [`:116`](jamovi/kappaSizePower.a.yaml#L116), [`:128`](jamovi/kappaSizePower.a.yaml#L128)). The `.u.yaml` overrides them in the GUI with good sentence-case labels, so this is cosmetic, but plain-language titles ("Null kappa (kappa0)", "Significance level (alpha)", "Raters", "Power") read better wherever `title:` surfaces. No leading verbs anywhere; group headings correctly Title Case; six controls is too few to need a `CollapseBox`; no `VariableSupplier` ordering issue (no-variable calculator).
- **Unlabelled `props` TextBox** — [`jamovi/kappaSizePower.u.yaml:81`](jamovi/kappaSizePower.u.yaml#L81) sets `label: ''` and leans on the enclosing `Label` heading. Visually fine; leaves the input without an accessible name for a screen reader.
- **Percentages are rejected with a range message, not a hint.** Typing `30, 70` falls past the decimal-comma detector to `"Each proportion must be strictly between 0 and 1."` ([`:287`](R/kappaSizePower.b.R#L287)). The decimal-comma case already gets a bespoke message; a matching "these look like percentages — divide by 100" branch would close the last common entry mistake.
- **No `private$.checkpoint()` anywhere.** The engine's root finder is iterative and the one non-converging design is now rejected up front, so exposure is small; a checkpoint before the `powerFun()` call would still keep jamovi responsive on the slowest legitimate designs (very small kappa gaps reaching ~10^5 subjects).
- **Stale cross-reference** — [`:324`](R/kappaSizePower.b.R#L324) and [`jamovi/js/kappaSizePower.events.js:25`](jamovi/js/kappaSizePower.events.js#L25) both point at `.validateProportions()`, a method that lives on `kappaSizeCI` (`R/kappaSizeCI.b.R:58`) and not on this class. Informative pointer only — not a phantom `private$` call — but it misdirects.

**Strengths:** the rationale comments carry measured counter-examples (the negative-N renormalisation case, the six-rater 5%-prevalence sparse design, the `alpha = 0.90` hang) rather than assertions; the GOF closed form is extracted to one shared helper with a stated verification tolerance; the engine's own repeated untranslatable warning is deduped rather than deleted, so a user comparing against a direct `kappaSize` call still sees it once.

#### Recommended remediation

- `/prepare-translation kappaSizePower` — regenerate `catalog.pot` so `"below 0.0001"` is extracted, fill the three empty `tr` msgstrs, and lift `<b>` out of the `:240` msgid. Run the same pass on `kappaSizeCI` and `kappaSizeFixedN`: `.fmtCount` is identical in all three.
- Comment-only edits (no command needed): correct the retracted Notice-serialisation rationale at `:109-110`; repoint the two `.validateProportions()` cross-references.
- Optional polish: plain-language `.a.yaml` `title:` values, an accessible name on the `props` TextBox, a percentages-detected branch beside the decimal-comma one, and a `private$.checkpoint()` before the engine call.
- No security, jmvcore-migration, integration or notices-coverage remediation required.

### lassologistic

**Status:** ⚠️ NEEDS WORK
**Files:** [`R/lassologistic.b.R`](R/lassologistic.b.R) · [`jamovi/lassologistic.a.yaml`](jamovi/lassologistic.a.yaml) · [`jamovi/lassologistic.u.yaml`](jamovi/lassologistic.u.yaml) · [`jamovi/lassologistic.r.yaml`](jamovi/lassologistic.r.yaml)
**Metrics:** .b.R LOC 2715 · options 29 · outputs 21 · UI controls 24 · JS LOC 0

One of the most carefully remediated backends in the module. Almost every audit-catalog
trap has already been fixed *and documented in-line* (Output row identity, `reject()`
re-raise, `Group$insert` avoidance, fixed rows in `.init()`, ggtheme ordering,
`plot.roc` dispatch collision, `format:` token choice, `.()` placement, seed exposure).
The findings below are what is left, and none of them is a security defect.

#### Security

*No findings in profile standard.*

Scan notes (all nine categories walked, all negative):

- **A/B** — no `eval`/`parse`/`str2lang`/`match.fun`/`get`. The single `do.call` is
  [`R/lassologistic.b.R:846`](R/lassologistic.b.R#L846) with a literal `glmnet::cv.glmnet`, not a variable.
- **C** — **zero string-built formulas.** Every model is fitted from a literal formula
  (`model.matrix(~., data = pred_cc)`, `glm(y ~ ., ...)`, `glm(y ~ lp, ...)`), so there is
  no C1/C2/C3 surface and `jmvcore::asFormula`/`composeTerm` are correctly not needed here.
- **D** — all 5 HTML sinks are clean. Every user-derived string reaching HTML is escaped:
  notice title/content ([`:59-62`](R/lassologistic.b.R#L59)), `todo` error text ([`:236`](R/lassologistic.b.R#L236), [`:277`](R/lassologistic.b.R#L277)),
  the copy-ready report incl. selected variable names ([`:2639`](R/lassologistic.b.R#L2639)), the manual-cut fallback
  footnote ([`:1847`](R/lassologistic.b.R#L1847)) and both refit-failure footnotes ([`:2347`](R/lassologistic.b.R#L2347), [`:2377`](R/lassologistic.b.R#L2377)).
  `suitabilityReport` and the three explanatory panels are built from `.()` literals and
  numbers only. The 10 `htmlEscape` calls cover the full set — nothing is missed.
- **E/F** — no filesystem, process, network or deserialization calls.
- **G** — no `.asSource`/`.sourcifyOption` in this backend.
- **H** — no `library()`, no debug flag, no top-level executable code, no dead probes.
- **I** — no whole-frame NA coercion, no `inherits(x,"numeric")`, no `class(x)==`, no
  unvectorised `is.null` filter, no stale cached R6 helper.

Variable-name safety is clean: the only regex-capable calls are
`strsplit(txt, "[,;\n]+")` and `strsplit(pt, "=", fixed = TRUE)` on the *option string*
([`:1635`](R/lassologistic.b.R#L1635), [`:1639`](R/lassologistic.b.R#L1639)) — no user column name is ever used as a pattern, and there is
no `paste0("^", name)` prefix-strip anywhere. `.stripBackticks` is called once
([`:581`](R/lassologistic.b.R#L581)) and uses `gsub(..., fixed = TRUE)`.

#### jmvcore migration

*No migration opportunities found.*

The backend already uses `jmvcore::reject` (13 sites), `jmvcore::toNumeric`,
`jmvcore::htmlEscape`, `jmvcore::format` and the `.()` translator. `na.omit` appears
once inside `length(unique(na.omit(x)))` on a single extracted column — a plain vector,
so `jmvcore::naOmit` is not indicated. `complete.cases` is used for the frame-level
filter, which is correct (it keeps the attribute-carrying columns untouched).

#### Integration

**Arguments declared:** 29 (28 + `data`)  ·  **used in logic:** 28  ·  **dead:** 0

Every non-`data` option is read and every one reaches a branch or a model argument.
`scoreCutMethod` / `scoreCutPoints` are read through `private$.opt()` rather than
`self$options$…`; both are present in the compiled [`R/lassologistic.h.R:27-28`](R/lassologistic.h.R#L27), so the
defensive wrapper is now redundant.

| Argument | Type | Default | Used? | In logic? | Notes |
|---|---|---|:---:|:---:|---|
| `outcomeLevel` | Level | *(none)* | ✅ | ✅ | correctly carries no `default:`; `.h.R` gives the wrapper `= NULL` |
| `random_seed` | Integer | 123456 | ✅ | ✅ | `withr::local_seed()` at [`:229`](R/lassologistic.b.R#L229), before every random call |
| `scoreCutMethod` | List | median | ✅ | ✅ | read via `private$.opt()` ([`:1463`](R/lassologistic.b.R#L1463)) — see LOW-3 |
| `scoreCutPoints` | String | `''` | ✅ | ✅ | same; only free-text option, never used as a regex |
| `scoringMaxPoints` | Integer | 10 | ✅ | ⚠ | genuinely ignored by Beta10 and Schneeweiss — correctly documented in `.a.yaml` and correctly gated in `.u.yaml` |

**Outputs declared:** 21  ·  **populated:** 21  ·  **unpopulated:** 0

No unpopulated output, no permanently-invisible output, no half-wired removed option,
no `if (FALSE)` block, no TODO/FIXME in `.run()`. Classification: **FUNCTIONAL**.

`clearWith` completeness: every result that depends on the fit lists
`outcome/outcomeLevel/explanatory/lambda/penalty/alpha/nfolds/standardize/random_seed`;
the scoring family adds the four scoring options and `validationTable` adds `bootstrapN`.
`coefficients` additionally lists `showModelComparison` because its `ci_note` branches on
it — correct and unusually thorough. The `notices` panel's `clearWith` omits the scoring
and model-comparison options, but that is benign: `.noticeList` is reset at the top of
`.run()` ([`:211`](R/lassologistic.b.R#L211)) and `.renderNotices()` uses `setContent()`, so the panel is fully
rewritten on every run.

**Citation-ref integrity:** clean. `glmnet`, `pROC`, `ClinicoPathJamoviModule` are all
defined in `jamovi/00refs.yaml` with author + year + title; the two Image-level `refs:`
(`glmnet`, `pROC`) resolve; no case mismatch, no option name inside a `refs:` block.

**Renderer data contract:** all three renderers (`.cvPlot`, `.coefPlot`, `.rocPlot`) read
`image$state` only and call no `private$` helper, so the **absence** of `requiresData` on
all three Images is correct. Each guards `is.null(state)` and returns `FALSE`. State
payloads are plain numerics/characters — no fitted `glmnet` object is serialized
([`:2416-2450`](R/lassologistic.b.R#L2416)). Only `roc_state` scales with n (a 2-column frame, n rows).

#### Notices coverage

Delivered through the HTML `notices` panel (`private$.addNotice` + `.renderNotices`), not
`jmvcore::Notice`. **Zero `insert()` calls anywhere in the file**, so the `Group$insert()`
bounds-check defect is not reachable. `.renderNotices()` is called on every terminating
path, including both error handlers before they re-raise.

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ⚠️ | ✅ | 0 predictors → `todo` welcome panel (idiomatic); **exactly 1 predictor → WARNING** at [`:220`](R/lassologistic.b.R#L220) although `.run()` then returns with no results — should be ERROR |
| Invalid / un-analysable data | ERROR | ✅ | ✅ | 9 `reject()` guards, each rendered as an ERROR notice then re-raised into jamovi's error state |
| Low n / events (EPV) | STRONG_WARNING | ✅ | ✅ | EPV, N, class balance, n/p, max&#124;r&#124; all graded and quantified ([`:637`](R/lassologistic.b.R#L637)) |
| Cases excluded (listwise) | WARNING | ✅ | ✅ | partitioned by cause (predictor / outcome NA / outcome level) |
| Assumption violation — separation | STRONG_WARNING | ⚠️ | ✅ | perfect apparent separation is STRONG_WARNING ✅; separation in the *unpenalized refit* is only WARNING ([`:2400`](R/lassologistic.b.R#L2400)) though it invalidates that row's AUC/AIC/Brier |
| Model does not discriminate | STRONG_WARNING | ✅ | ✅ | constant-probability guard, names which of sens/spec is the artefact |
| AUC &lt; 0.5 | ERROR | ✅ | ✅ | exactly the checklist threshold, and says the ranking is inverted |
| AUC &lt; 0.7 | STRONG_WARNING | ✅ | ✅ | |
| Logistic EPV &lt; 10 | WARNING | ✅ | ✅ | covered by the suitability grading (yellow 5–10, red &lt;5) |
| CV folds reduced | WARNING | ✅ | ✅ | names the minority-class cap |
| Scoring system degenerate / inverted / unusable scale | STRONG_WARNING / WARNING | ✅ | ✅ | two distinct branches, each quoting the on-screen sens/spec |
| Methodology summary | INFO | ✅ | ✅ | bottom of the panel, with terms/N/events and the display labels |

Content rules pass: plain text, single-line, quantified, actionable, deterministic
severity words spelled out (not colour-only). Only gap is the severity of the two rows
marked ⚠️ above.

#### Code review

- **Overall quality:** 4.5 stars
- **Architecture:** OK — `.run()` is 239 lines but is orchestration only (13 numbered
  phases delegating to 20 private helpers); no phantom `private$` method, no write to
  `self$options`, no `setVisible` at all.
- **Mathematical/statistical correctness:** MINOR_ISSUES
- **Clinical readiness:** NEEDS_VALIDATION
- **i18n coverage:** COMPLETE — 287 `.()` calls, zero leading/trailing-space or
  `msgctxt`-bracket violations, positional `%n$` used wherever a translator must reorder,
  `tr.po` msgstrs populated for this analysis's strings. Residual: two glue literals,
  `" (n="` in the Model Summary class rows ([`:970-971`](R/lassologistic.b.R#L970)) and `sprintf("%d to %d", …)` for the
  score range ([`:1892`](R/lassologistic.b.R#L1892)).

**Statistical assessment against the domain checklist:**

| Question | Verdict |
|---|---|
| Seed for CV reproducibility | ✅ **user-visible `random_seed` option** (default 123456), applied via `withr::local_seed()` before every random call, printed as a Model Summary row ([`:1000`](R/lassologistic.b.R#L1000)) *and* as a `validationTable` note ([`:2088`](R/lassologistic.b.R#L2088)), and listed in every result's `clearWith`. No bare hardcoded `set.seed()`. **Fully satisfies the house rule.** |
| Standardization | ✅ scaled in-module with `standardize = FALSE` passed to glmnet, coefficients back-transformed to the original scale, intercept back-transformed too ([`:1035`](R/lassologistic.b.R#L1035)); Coefficient/OR on original units, Importance and the coefficient plot on the per-SD scale, both disclosed. See MINOR-4 for one over-stated comment. |
| Post-selection inference | ✅ **no SE, no p-value, no CI is reported for any LASSO coefficient**, and the `ci_note` explains why. No literal/placeholder SE, no `rnorm()` estimate — zero fabricated statistics in the file. |
| lambda.min vs lambda.1se | ✅ default `lambda.1se`, both labelled in plain language, the choice explained in the explanations panel and echoed in the "no variables selected" remedy text. |
| Factor handling | ⚠️ **MINOR-1** — see below. |
| Bootstrap optimism | ✅ Harrell/Efron construction is correct: each replicate re-runs the *whole* `cv.glmnet` selection, scores the boot model on both boot and original data, and the Brier sign convention is right. Replicate survival count is reported, and a below-chance corrected AUC is explained rather than hidden. |
| Ties / degenerate cases | ✅ constant-probability, perfect-separation, zero-selection, collapsed-Youden and inverted-score cases all have explicit guards and notes. |

**Top issues:**

1. **MINOR-1 (stat, disclosure) — grouped vs individual penalisation of factor dummies is
   never disclosed.** `model.matrix(~., data = pred_cc)` ([`:562`](R/lassologistic.b.R#L562)) expands a k-level factor
   into k−1 dummies that are penalised **individually**, so LASSO can retain "Grade 3" and
   drop "Grade 2" — which silently redefines the reference contrast and is a well-known
   reason to prefer a group penalty. Model Summary does distinguish "Variables analysed"
   from "Model terms (after dummy coding)", but nothing tells the pathologist that a
   partially-selected factor is what they are looking at. Add one sentence to the
   `coefficients` table note.
2. **MINOR-2 (stat, real inconsistency) — the zero-tolerance in Variable Importance uses
   the wrong SDs, exactly inverted relative to the coefficient table.**
   [`R/lassologistic.b.R:2253`](R/lassologistic.b.R#L2253):
   ```r
   sds <- if (!is.null(data$X_sd)) data$X_sd[rownames(all_coefs)] else rep(1, nrow(all_coefs))
   inclusion_prop <- rowMeans(abs(all_coefs) * sds > 1e-10)
   ```
   `all_coefs` are coefficients **on the matrix glmnet was fitted on** (`data$X`), but
   `data$X_sd` holds the **original** column SDs. With `standardize = TRUE` the fitted
   matrix already has sd 1, so the correct multiplier is 1 and this multiplies by the
   original sd; with `standardize = FALSE` `X_sd` is all 1 while the correct multiplier is
   the raw column sd. `.probsFrom` ([`:1491`](R/lassologistic.b.R#L1491)) gets it right in both branches
   (`apply(fit_X, 2, sd)`), so the comment's claim of "same per-SD zero rule as the
   coefficient table" does not hold. Display-only (the fitted model is unaffected), but on
   a predictor with an extreme scale it can report a ~100% Path Inclusion Proportion for a
   term that was never selected, or under-report a genuine one. Fix: use
   `apply(data$X, 2, stats::sd)`, the same expression `.probsFrom` uses.
3. **MINOR-3 (stat/clinical) — with `standardize = FALSE` the Importance column is
   silently unit-dependent.** `importance <- abs(coef_sd) / max_abs` ([`:1083`](R/lassologistic.b.R#L1083)) is normalised
   raw coefficients when standardisation is off, so a predictor measured in µm outranks one
   measured in mm purely on units. The explanatory `scale_note` that would say so is gated
   on `isTRUE(self$options$standardize)` ([`:1110`](R/lassologistic.b.R#L1110)), and the only other disclosure lives in
   `methodologyNotes`, which is `default: false`. Add an `else`-branch note on the table.
4. **MINOR-4 (stat, comment accuracy) — "reproduces exactly what `glmnet(standardize=TRUE)`
   would have returned" ([`:594`](R/lassologistic.b.R#L594)) is not exact.** `scale()` uses the sample SD (÷ n−1);
   glmnet's internal standardisation uses the population SD (÷ n). The per-column penalty
   weights therefore differ by √(n/(n−1)) and the two fits are close but not identical.
   Harmless in practice, misleading as a documented guarantee.
5. **MINOR-5 (stat) — post-selection AIC is presented for direct comparison.** The
   `Logistic (LASSO-selected vars)` row reports `AIC(glm_sel)` ([`:2339`](R/lassologistic.b.R#L2339)) with df counted as
   the number of *selected* terms, ignoring the selection step, against
   `Logistic (all vars)` ([`:2370`](R/lassologistic.b.R#L2370)) whose df is honest. The selected-variable row is therefore
   systematically favoured. `refit_note` covers the AUC inflation but says nothing about
   the AIC. Either add the caveat or blank the AIC on the selected-variables row.
6. **MINOR-6 (clinical labelling) — the lookup table's `probability` column is titled
   "Predicted Probability" but holds an observed rate.** `prob <- n_events / n_cases`
   ([`:2050`](R/lassologistic.b.R#L2050)) is the empirical in-sample event proportion at each total score, not a model
   prediction. The `smallcell_note` says "in-sample empirical event rates", contradicting
   the column header a clinician will read first. Rename to "Observed event rate".
7. **LOW-1 (notices severity) — the single-predictor guard is a WARNING for a condition
   that stops the analysis** ([`:220`](R/lassologistic.b.R#L220)), and separation in an unpenalized refit is a WARNING
   for a row whose AUC/AIC/Brier are unusable ([`:2400`](R/lassologistic.b.R#L2400)). Both warrant ERROR /
   STRONG_WARNING respectively.
8. **LOW-2 (UX) — `.init()` scaffolds fixed rows before the input guards** ([`:122-135`](R/lassologistic.b.R#L122)), and
   `performance` has no `visible:` gate, so opening the analysis with nothing selected shows
   an 8-row "Classification Performance" table with blank values beside the welcome panel —
   the same "titled but blank rows read as a partial computation" problem the `.cleanData`
   handler comment at [`:247`](R/lassologistic.b.R#L247) was written to avoid.
9. **LOW-3 (maintainability) — `private$.opt()`'s catch-all masks schema drift.**
   `tryCatch(self$options[[name]], error = function(e) NULL)` ([`:1463`](R/lassologistic.b.R#L1463)) was a
   pre-regeneration shim; both options it guards are now in the compiled `.h.R`, so today it
   only converts a future rename into a silent fallback to `"median"` instead of a loud
   failure. (Not a `reject()`-swallow: no `reject()` or `.checkpoint()` is reachable inside
   it.)
10. **LOW-4 (label convention)** — ~9 `.a.yaml` `title:` values are Title Case on
    *individual* controls where sentence case is the convention: `Event Level`,
    `Penalty Type`, `Lambda Selection Method`, `Number of CV Folds`, `Random Seed`,
    `Bootstrap Iterations`, `Scoring Method`, `Maximum Points per Feature`,
    `Cut Point for Continuous Predictors`, `Manual Cut Points`. No leading-verb violations
    remain (already swept), `CollapseBox` headings are correctly Title Case, the
    `VariableSupplier` is at the top, and advanced options are in collapsed boxes.
11. **LOW-5 (robustness)** — `data.frame(y = data$y, X_sel)` ([`:2321`](R/lassologistic.b.R#L2321), [`:2354`](R/lassologistic.b.R#L2354)) applies
    `check.names = TRUE`, mangling a column named `Ki-67 (%)` into `Ki.67....`. Benign here
    because only AUC/AIC/Brier are read back and never the coefficient names — but
    `check.names = FALSE` + `composeTerm`ed terms would remove the latent trap.
12. **LOW-6 (silent failure)** — five `error = function(e) {}` handlers swallow pROC / glm
    failures without a note ([`:801`](R/lassologistic.b.R#L801), [`:1122`](R/lassologistic.b.R#L1122), [`:1143`](R/lassologistic.b.R#L1143), [`:1732`](R/lassologistic.b.R#L1732), [`:2301`](R/lassologistic.b.R#L2301)). Each degrades to a
    blank cell or "Not available", so nothing is fabricated, but a repeated failure is
    invisible to the user.

**Strengths:** zero fabricated statistics and an explicit refusal to print post-selection
SEs/CIs; a genuinely exemplary seed story (option + default + `withr::local_seed` +
printed beside the results + in every `clearWith`); the most thorough degenerate-case
guarding in the module (constant probabilities, perfect separation, zero selection,
collapsed Youden cut, inverted score, denormal coefficients, negligible-reference
overflow), each with a note that names the artefact rather than the number.

#### Recommended remediation

- `/review-function lassologistic` — MINOR-1 (factor-dummy grouping disclosure), MINOR-2
  (`sds` in `.populateVariableImportance`, [`:2253`](R/lassologistic.b.R#L2253)), MINOR-3 (Importance note when
  `standardize = FALSE`), MINOR-5 (post-selection AIC caveat), MINOR-6 (lookup column
  title). MINOR-2 is the only one that changes a printed number.
- `/fix-notices lassologistic` — raise the single-predictor guard to ERROR and the
  unpenalized-refit separation notice to STRONG_WARNING.
- `/check-function lassologistic` — LOW-2 (gate the `.init()` fixed-row scaffolding, or
  give `performance` a `visible:` expression), LOW-3 (retire `private$.opt()`), LOW-4
  (sentence-case the ten `title:` values), LOW-5 (`check.names = FALSE`).
- No security remediation required — do **not** run `/security-audit-function`.
- No `/jamovify-function` run required.
- No `/prepare-translation` run required (i18n is complete; only two glue literals remain,
  fold them into the `/review-function` pass).

### nogoldstandard

**Status:** ⚠️ NEEDS WORK
**Files:** [`R/nogoldstandard.b.R`](R/nogoldstandard.b.R) · [`jamovi/nogoldstandard.a.yaml`](jamovi/nogoldstandard.a.yaml) · [`jamovi/nogoldstandard.u.yaml`](jamovi/nogoldstandard.u.yaml) · [`jamovi/nogoldstandard.r.yaml`](jamovi/nogoldstandard.r.yaml)
**Metrics:** .b.R LOC 2437 · options 20 · outputs 13 · UI controls 20 · JS LOC 0

#### Security

- **[I-LOW]** [`R/nogoldstandard.b.R:461`](R/nogoldstandard.b.R#L461) — `data[unlist(tests)]` with the same variable chosen for two test slots yields duplicate column names (`A`, `A.1`), then `names(binary_data) <- unlist(tests)` (L506) makes both `A`; every later `[[name]]` silently returns the first. Unreachable through the GUI (`persistentItems: false`), reachable from the R wrapper. Guard with `anyDuplicated(unlist(tests))` → `jmvcore::reject`.
- **[H-LOW]** [`R/nogoldstandard.b.R:1861`](R/nogoldstandard.b.R#L1861), [`:1968`](R/nogoldstandard.b.R#L1968) — plot-failure paths report via `message()`, which goes to an R console jamovi never shows; a failed render is silent to the user.

Categories A, B, C, E, F, G clean — verified by grep: no `eval`/`parse(text=)`/`str2lang`, no `do.call`/`get`/`match.fun`, no `system`/`source`/`readRDS`/`download.file`, no `.asSource`/`.sourcifyOption`, no `library()`, no debug flags.

**Category C (formula) is exemplary** — [`R/nogoldstandard.b.R:1110`](R/nogoldstandard.b.R#L1110) uses `jmvcore::composeTerms()` for backtick-quoting and `jmvcore::asFormula()` for the parse-time allow-list; `cbind` is on the global allow-list.

**Category D (XSS) clean — escape coverage is complete.** Three helpers build HTML (`.showWelcomeMessage`, `.showMethodGuide`, `.generateClinicalSummary`). Traced every interpolated value: the only user-derived string that reaches HTML is the test/column-name vector at [`:2329`](R/nogoldstandard.b.R#L2329), and it is wrapped in `jmvcore::htmlEscape()`. Everything else is a `.()` literal, an internal enum label (`.methodLabel`/`.presetLabel`), or a formatted number. The `notices` panel is `Preformatted` (plain text), so variable names reaching notices carry no injection surface.

#### jmvcore migration

*No functional migration opportunities found.* The analysis already uses `jmvcore::asFormula` + `composeTerms` (L1110–1111), `jmvcore::naOmit` (L463), `jmvcore::reject` with `{}` placeholders (L426, L432), `jmvcore::format`/`.fmt`, and `jmvcore::htmlEscape`.

- **[style only]** ~12 user-facing messages use `sprintf()` rather than the project's `.fmt()`/`jmvcore::format()` idiom (L474, 583, 764, 1388, 1542, 1730, …). All of them correctly carry ordered `%n$` markers where there are 2+ conversions, so they are i18n-safe; this is inconsistency, not a defect.
- `as.numeric(var == pos_level)` (L165, L513) is a logical→numeric coercion, **not** a `jmvcore::toNumeric` candidate (`toNumeric` is a no-op on factor/character).

#### Integration

**Arguments declared:** 20  ·  **used in logic:** 20  ·  **dead:** 0

| Argument | Type | Default | Used? | In logic? | Notes |
|---|---|---|:---:|:---:|---|
| `clinicalPreset` | List | `none` | ✅ | ✅ | Advisory only by design — a backend cannot write `self$options`; it now reports the example settings and how they differ (L2217–2267). Correctly *not* half-wired. |
| `nboot` | Number | 1000 | ✅ | ✅ | Should be `type: Integer`; `Number` accepts `1000.5`, which `seq_len()` silently truncates. |
| `seed` | Integer | 0 | ✅ | ✅ | No `min:`/`max:`; `.seedValue()` normalises with `%% .Machine$integer.max`, so negatives and huge values are safe. |

**Outputs declared:** 13  ·  **populated:** 13  ·  **unpopulated:** 0

| Output | Type | Setter | Populated? | Notes |
|---|---|---|:---:|---|
| `notices` | Preformatted | `setContent` | ✅ | Bodies are 300–600-character single-line paragraphs; `Preformatted` does **not** wrap → horizontal overflow. See below. |
| `model_fit` | Table | `addRow` | ✅ | `visible: (method=="latent_class")`. `.runBayesian` returns no log-likelihood/AIC/BIC, so the penalized-EM path has no fit statistics at all. |
| `conditional_dependence` | Table | `addRow` | ✅ | `visible: (method=="latent_class")` — but `bayesian` fits the *same* conditional-independence model and gets no bivariate-residual check. |
| `agreement_plot` | Image | `setState` | ✅ | State is a k×k numeric matrix + a character vector (L642–645) — tiny. Renderer reads only `image$state`; Image correctly carries **no** `requiresData`. Contract verified. |

**Other integration findings**

- **Unreachable validation.** [`R/nogoldstandard.b.R:447`](R/nogoldstandard.b.R#L447) `if (length(tests) < 2) jmvcore::reject(...)` can never fire: `.showWelcomeMessage()` (L224–229) counts the *identical* condition (variable AND positive level both set) and `.run()` returns early at L398–400. Dead branch.
- **Red error on the most likely first configuration.** The welcome gate opens at **2** configured tests, but the default `method` is `latent_class`, which rejects below **3** (L452). Selecting test1 + test2 — the two boxes that are not labelled "(Optional)" — produces an immediate red error instead of guidance. Fix: make `.showWelcomeMessage()` method-aware, or surface the 3-test requirement as an ERROR notice inside the instructions panel.
- **`clearWith` completeness: PASS.** Every data-gating option (`test1..test5`, `*Positive`, `method`, `bootstrap`, `nboot`, `alpha`, `seed`, `verbose`, `showSummary`, `showMethodGuide`) appears in the `clearWith` of every result it can change. Only cosmetic inconsistency: `conditional_dependence` omits `clinicalPreset` (which cannot change a bivariate residual).
- **Citation refs: 3 used, 3 defined.** `ClinicoPathJamoviModule`, `poLCA`, `irr` all resolve in `jamovi/00refs.yaml` (L220, L2743, L3449) with non-empty author/year. **But** the `poLCA` entry carries `year: 2026` and `title: "poLCA: R package"` — a wrong year and a placeholder title. The canonical citation is Linzer DA, Lewis JB. *J Stat Softw*. 2011;42(10):1–29. Route through `/update-refs nogoldstandard --fetch-metadata`.
- **`vcd` is an unused meddecide Import — CONFIRMED.** The only `vcd` reference in any shipped meddecide R file is the **comment** at [`R/nogoldstandard.b.R:2386`](R/nogoldstandard.b.R#L2386). `meddecide/R/zzz_imports.R:19` keeps `#' @importFrom vcd Kappa` alive and `meddecide/DESCRIPTION` lists `vcd`; no bare `Kappa(` call exists anywhere in `meddecide/R/`. Add `vcd` to the `meddecide` `prune_imports` list in `_updateModules_config.yaml` **and** delete the roxygen tag (the planner parses, so the comment alone will not block the prune).
- **No `jmvcore::Notice` object and no `$insert()` call exist in this file.** The "1 Notice use" is a grep hit on the comments at L16–19 and L131–133. Index safety is therefore N/A — nothing to fix. However those comments assert that "dynamic Notice objects are not serializable", which the 2026-09-22 project correction retracts: `Notice` serializes fine; the defect was `jmvcore::Group$insert()`'s missing bounds check. The comments should be corrected so the next maintainer does not inherit a retracted premise.
- **`tryCatch` audit (6 sites, 12 `reject()` sites).** Five are correctly scoped (L40 results lookup; L1144 poLCA call only; L1790/L1901 plot render; L2390 `irr::kappa2` only). The sixth, [`R/nogoldstandard.b.R:1683`](R/nogoldstandard.b.R#L1683), guards `.runLCA`/`.runBayesian` inside the bootstrap loop and **does swallow their `jmvcore::reject()` calls** (L1090, L1195, L1366) — only `identical(e$code, "restart")` is re-raised. Turning a failed replicate into a counted failure rather than a fatal error is defensible, and the restart re-raise correctly protects `private$.checkpoint()` called at L1131/L1409 inside the guarded region. Worth an explicit comment; not a behavioural bug.
- **`setVisible(FALSE)` (1 site, L287)** hides the welcome/instructions panel once the analysis can run. This is the standard idiom, **not** an error mechanism, and nothing hidden carries a `setNote()`.

#### Notices coverage

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ✅ | ✅ | Via `jmvcore::reject` (L403, 426, 432, 448, 453, 456, 495) + the instructions panel. No notice uses type `ERROR`; errors go through jamovi's error state, which is correct. |
| Complete-case exclusions | WARNING | ✅ | ✅ | L469–484 — names N analysed, N supplied, and the % (a genuine gap closed). |
| Low n / events | STRONG_WARNING | ✅ | ✅ | LCA N<100 (L2010), penalized EM N<50 (L2021), per-test cell <5 (L2054), imbalance <5% (L2069), rule group <10 on either side (L561). |
| Assumption violation | STRONG_WARNING | ✅ | ✅ | Bivariate residuals name the offending pairs (L964–971); incorporation bias (L1290, L812); composite ties (L2092); label unidentifiability (L533). |
| Non-convergence | STRONG_WARNING | ✅ | ⚠️ | L577–586 present, but the number spliced is iterations *used*, not the limit (see Code review). |
| Extreme prevalence / class proportion | STRONG_WARNING | ✅ | ✅ | <5% or >95% for latent methods (L539); counts on both sides for rule methods (L550–571). |
| Prior sensitivity | WARNING | ✅ | ✅ | L1385–1391 states Beta(2,1), its mean, and that it adds one pseudo-positive per test. Rare and excellent. |
| Bootstrap failures | WARNING | ✅ | ✅ | L1726–1733 with count, %, and survivors. |
| Methodology summary | INFO | ✅ | ✅ | L479 "Analysing N cases"; preset advisory L2252; verbose summary L2102. |

**Coverage is the best in the module.** Positioning is sound: `on.exit(private$.renderNotices(), add = TRUE)` at [`:382`](R/nogoldstandard.b.R#L382) guarantees notices survive every `reject()` early exit, and `.renderNotices()` overwrites rather than appends, so nothing accumulates across runs.

**One gap (rendering, not coverage):** the notices go into a `type: Preformatted` item. `Preformatted` is monospace and does not soft-wrap, so a 500-character notice body renders as one horizontally-scrolling line. Given the correction above (`Notice` serializes fine), the right target is either real `jmvcore::Notice` items appended with `self$results$add()` (never `insert(N,…)`), or an `Html` item like the rest of the module uses.

#### Code review

- **Overall quality:** 4.5/5 stars
- **Architecture:** OK — clean R6, no `library()`, no top-level code, helpers well factored. One issue: `.run()` spans [`:377`–`:653`](R/nogoldstandard.b.R#L377) = **277 lines**, over the ~200 target; the notice-emission block (L532–586) and the agreement-matrix block (L626–648) are extractable.
- **Mathematical/statistical correctness:** MINOR_ISSUES
- **Clinical readiness:** NEEDS_VALIDATION
- **i18n coverage:** PARTIAL

**Estimator-vs-label audit (the core domain question) — PASS.**

| `method` value | Label | What is actually computed | Verdict |
|---|---|---|---|
| `latent_class` | Latent Class Analysis | `poLCA::poLCA(nclass = 2, maxiter = 1000)`, up to 30 seeded random starts with a stall-out at 10 (L1127–1188) | ✅ matches |
| `bayesian` | Penalized EM (MAP-like; fixed priors; 3+ tests) | Hand-rolled EM with Beta(1,1) prevalence and Beta(2,1) sens/spec MAP offsets (L1354–1565) | ✅ label is honest — explicitly disclaims posterior sampling in the option description, the guide, the notice (L1385) and the table note (L791) |
| `composite` | Composite Reference (strict majority) | `rowMeans > 0.5`, ties rule-negative (L1304) | ✅ matches, and the tie convention is disclosed for even k |
| `all_positive` / `any_positive` | All / Any Tests Positive | AND / OR reference rules | ✅ matches |

**Hui–Walter (multi-population) is not implemented and, correctly, is not claimed anywhere.** No label promises LCA over a composite-reference computation.

**Identifiability — PASS.** Both latent methods reject below 3 tests (L452, L455, and defensively again at L1365). The just-identified k=3 case is handled properly: `G²`/`χ²` are suppressed from `model_fit` (L1043–1044) with an explaining note, and `conditional_dependence` returns a "not computable with three tests" note (L918–920) instead of a table of structural zeros. This is the most careful handling of `resid.df == 0` in the module.

**Conditional independence — PASS.** Stated as an assumption in the instructions, the method guide, and the `model_fit`/`conditional_dependence` notes, *and measured* by bivariate residuals against χ²₁(0.95) = 3.841 with a STRONG_WARNING naming the offending pairs. I verified the poLCA data contract the BVR code depends on: `names(ret$probs) <- colnames(y)` keeps the **unmangled** names, and poLCA's `is.factor(data[, match(colnames(y), colnames(data))[j]])` branch sets `colnames(probs[[j]])` to the factor levels (`"no"`/`"yes"`) and converts `ret$y[,j]` to a labelled factor. So the name-matching at L933 and the positional `model$y[[ia]]` indexing at L987–991 are both correct, including for non-syntactic column names — the documented `make.names()` hazard is genuinely neutralised.

**Label switching — PASS.** Both latent estimators orient deterministically on mean selected-positive probability (L1246–1249 for poLCA, L1510–1519 for the EM). I checked the EM swap algebraically: new sens = 1 − old spec, new spec = 1 − old sens, new prevalence = 1 − old prevalence — correct. A STRONG_WARNING (L533–537) tells the user the classes are unlabeled and that a below-chance test inverts the clinical reading.

**Seed handling — PASS (house rule satisfied).** `seed` is a user option with a default; `.seedValue()` normalises it; `withr::with_seed` scopes each LCA start and `withr::local_seed` scopes the bootstrap so the caller's RNG stream is untouched. There is **no bare `set.seed()`**. The seed is printed beside every seed-dependent result — `prevalence` (L713), `test_metrics` (L760), `model_fit` and `conditional_dependence` (L704–709), and inside the bootstrap CI provenance note (L764) — and is correctly *omitted* for the deterministic penalized-EM path.

**Kappa — PASS, and the `vcd::Kappa` trap is correctly avoided.** No kappa CI is reported, so no ASE is needed; the p-value comes from `irr::kappa2()`'s null-variance Wald statistic (L2390–2399), which is the right statistic for H₀: κ = 0. The comment at L2385–2389 states exactly this reasoning. Regression-tested at `tests/testthat/test-nogoldstandard-release-review.R:250`.

**Degenerate metrics — exemplary.** `all_positive` (sens, NPV), `any_positive` (spec, PPV) and 2-test `composite` are fixed at 100% by construction; all are blanked with `NA_real_` rather than printed as "100%", with a STRONG_WARNING and a table note (L812–824, L866–878). PPV/NPV via Bayes (L1753–1772) are algebraically identical to the direct 2×2 values for the rule methods — verified. `isTRUE()` guards make the denominators NA-safe. No fabricated statistics anywhere.

**Top issues:**

1. **Latent-class bootstrap intervals are warm-started and the note misdescribes them.** [`R/nogoldstandard.b.R:1685`](R/nogoldstandard.b.R#L1685) passes `n_starts = 1L, probs_start = warm_start` (the full-sample `model$probs`) for every replicate, so each replicate is a single EM run from the full-sample optimum rather than an independent refit. That conditions the percentile interval on one mode and is plausibly anti-conservative — yet the `ci_provenance` note the user reads says "*bootstrap percentile intervals from N resamples of the cases, **refitting the model on each***" ([`:764`](R/nogoldstandard.b.R#L764)). The performance rationale is sound (the comment at L1156–1160 is right that random restarts per replicate were the whole cost); the *description* is not. Fix the note to say the replicates are warm-started from the full-sample fit, and validate coverage on simulated data before the intervals are used in a clinical report.
2. **`bayesian` gets no conditional-independence diagnostic and no fit statistics.** `conditional_dependence` and `model_fit` are both `visible: (method=="latent_class")` in the `.r.yaml`, but the penalized EM fits the identical conditional-independence model. The user is told the assumption matters (L1385, L791) and given no way to check it. `.runBayesian` also returns no log-likelihood/AIC/BIC, so there is nothing to populate `model_fit` with even if it were made visible.
3. **Non-convergence message quotes the wrong number.** [`:583`](R/nogoldstandard.b.R#L583) — "*reached its iteration limit (%s)*" splices `results$iterations`, which for the LCA path is `best_model$numiter` (iterations **used**). `.lcaConverged()` also declares failure when `llik <= -1e10` at numiter < 1000, in which case the printed value is neither the limit nor a limit. Print `maxiter` (1000 / 100), or reword.
4. **Boundary clamping can masquerade as convergence.** [`:1479`–`:1480`](R/nogoldstandard.b.R#L1479) clamps every sens/spec to [0.001, 0.999] each iteration; a clamped parameter stops moving, so `max(param_diffs) < tol` declares convergence at a boundary. The `eff_diseased < 1` blanking (L1529–1536) catches the global collapse but not per-test pinning.
5. **Bootstrap failure count understates.** [`:1711`](R/nogoldstandard.b.R#L1711) increments `error_count` only for `NULL` or `isFALSE(converged)` results; a replicate that returns NA sens/spec (the `.runBayesian` blanking path) is counted as a success. `.bootCI` then silently returns `NA` below 20 finite values (L1748) with no notice explaining the blank interval.
6. **`.run()` is 277 lines** (L377–653) — above the ~200 guideline.
7. **`diagnostics` panel is 100% untranslated.** Every `.diag()` string is bare English: L486–492, 1198, 1224, 1553, 1735, 1738–1739. It is a user-visible output item (`visible: (verbose)`), so this is an i18n hole, not internal logging.
8. **tr.po has ~39 untranslated `msgstr` for this file** out of ~234 entries, including user-visible strings ("Analysing %d cases", "Bootstrap samples: currently {current}, example {example}", "Agreement data available but plotting failed"). Source-side `.()` wrapping is otherwise complete and free of the msgctxt trap — grep found **zero** `.()` strings containing `" ["` and zero leading/trailing-space msgids.
9. **UI label convention (LOW).** The `.u.yaml` labels users see are correctly sentence-case, noun-phrased, and free of leading verbs ("Bootstrap CI", "Analysis diagnostics", "Plain-language summary", "Method guide"); `VariableSupplier` is at the top and advanced options sit in `collapsed: true` boxes. But the `.a.yaml` `title:` values are Title Case ("Number of Bootstrap Samples", "Alpha for Confidence Intervals", "Illustrative Scenario Example"), and those surface in the generated R documentation.
10. **Cosmetic:** in the welcome state (<2 tests configured with no preset selected) the "Important Information" panel renders as an empty titled box beside the instructions, because `.renderNotices()` calls `setContent("")` (L101).

**Strengths (worth propagating to the rest of the module):** every degenerate or non-estimable quantity is blanked with `NA_real_` and explained rather than printed as a number; the seed is published beside every seed-dependent result; the `resid.df == 0` just-identified case is handled instead of ignored; incorporation bias and class unidentifiability are disclosed in four places each; `jmvcore::asFormula` + `composeTerms` is used correctly; `withr` scoping leaves the caller's RNG untouched; and the `tryCatch` at L1683 correctly re-raises the `.checkpoint()` restart error.

#### Recommended remediation

- `/review-function nogoldstandard` — items 1–5: document (and validate the coverage of) the warm-started latent-class bootstrap, extend `conditional_dependence`/`model_fit` to the `bayesian` method, fix the non-convergence message, and tighten the boundary-clamp convergence test and the bootstrap failure count.
- `/fix-function nogoldstandard` — make the welcome gate method-aware so the default `latent_class` + 2 tests no longer produces a red error on open; remove the unreachable `reject()` at L447; add an `anyDuplicated()` guard on the selected test variables; split the notice-emission and agreement-matrix blocks out of `.run()`.
- `/fix-notices nogoldstandard` — migrate the `Preformatted` accumulator to real `jmvcore::Notice` items via `self$results$add()` (never `insert(N,…)`) or to an `Html` item, so long notice bodies wrap; and correct the stale comments at L16–19 and L131–133 that claim `Notice` is unserializable.
- `/prepare-translation nogoldstandard` — wrap the `.diag()` strings feeding the `diagnostics` panel and fill the ~39 empty `tr.po` msgstr for this file.
- `/update-refs nogoldstandard --fetch-metadata` — fix the `poLCA` entry in `jamovi/00refs.yaml` (`year: 2026`, placeholder title → Linzer & Lewis 2011, *J Stat Softw* 42(10)).
- **Module config (not this analysis's files):** add `vcd` to `modules.meddecide.prune_imports` in `_updateModules_config.yaml` and delete `#' @importFrom vcd Kappa` from `meddecide/R/zzz_imports.R:19` — the only `vcd` reference in shipped meddecide code is a comment.

### psychopdaROC

**Status:** ⚠️ NEEDS WORK
**Files:** [`R/psychopdaROC.b.R`](R/psychopdaROC.b.R) · [`R/psychopdaROC-nri-idi.R`](R/psychopdaROC-nri-idi.R) · [`jamovi/psychopdaROC.a.yaml`](jamovi/psychopdaROC.a.yaml) · [`jamovi/psychopdaROC.u.yaml`](jamovi/psychopdaROC.u.yaml) · [`jamovi/psychopdaROC.r.yaml`](jamovi/psychopdaROC.r.yaml)
**Metrics:** .b.R LOC 6950 (+523 helper) · options 78 · outputs 37 · UI controls 122 · JS LOC 0

#### Security

Categories A (eval/parse), B (string-built calls), C (formula construction), E (filesystem/process),
F (deserialization), H (debug flags / `library()`) and I (data-integrity idioms) are **clean** — zero
hits across both files. No bare `plot(roc_obj)`, so the `spatstat` masking of `pROC::plot.roc` is not
reachable here; every figure is ggplot2. `asSource()` delegates to `jmvcore`'s `private$.asArgs()`
rather than hand-quoting, so category G is clean too.

- **[D-LOW]** [`R/psychopdaROC.b.R:2153`](R/psychopdaROC.b.R#L2153), [`:2155`](R/psychopdaROC.b.R#L2155), [`:2236`](R/psychopdaROC.b.R#L2236), [`:2252`](R/psychopdaROC.b.R#L2252), [`:3853`](R/psychopdaROC.b.R#L3853), [`:6045`](R/psychopdaROC.b.R#L6045) — factor levels and column names interpolated **unescaped** into `table$setNote()` strings that also carry `<b>`/`<i>` markup. `setNote` renders through jamovi's HTML allow-list (`i em b strong sub sup`), so this is not a script sink, but the escaping is **inconsistent within the same file**: [`:3274`](R/psychopdaROC.b.R#L3274) and [`:3457`](R/psychopdaROC.b.R#L3457) do call `jmvcore::htmlEscape()` on the identical kind of value. Make all of them escape.
- **[E/robustness-LOW]** [`R/psychopdaROC.b.R:404`](R/psychopdaROC.b.R#L404) — `.throwError()` passes a composed message straight in as `jmvcore::reject()`'s **format string**:
  ```r
  full_message <- paste(base_message, details)
  jmvcore::reject(full_message)
  ```
  `details` carries user data (e.g. `paste(lv, collapse = ", ")` of factor levels at [`:2124`](R/psychopdaROC.b.R#L2124)). A level containing `{` / `}` is read as a placeholder. Use `jmvcore::reject("{}", full_message)`.

The 12 `jmvcore::htmlEscape()` calls were traced against **all 15 `setContent()` sites**: every
user-derived string reaching an `Html` result is escaped (variable lists, class variable, positive
class, subgroup, inverted-marker list, the whole `.warnUser` queue at [`:359`](R/psychopdaROC.b.R#L359), and the confusion-matrix
title at [`:5069`](R/psychopdaROC.b.R#L5069)). The remaining `setContent` payloads interpolate only `List`/`Bool`/`Number`
options or literals. The two `Preformatted` payloads ([`:3242`](R/psychopdaROC.b.R#L3242), [`:3266`](R/psychopdaROC.b.R#L3266)) are plain text by contract.
**No HTML-escape gap found.**

#### jmvcore migration

*No migration opportunities found.* `jmvcore::toNumeric()`, `htmlEscape()`, `format()`, `reject()`,
`colorPalette()` and the repo-local `.fmt()` are already used idiomatically; there is no
`as.formula`, no `na.omit` on an attributed frame, and no `as.numeric(factor)` on an option value.

#### Integration

**Arguments declared:** 78  ·  **used in logic:** 76  ·  **dead:** 1 (+1 inert plumbing)

| Argument | Type | Default | Used? | In logic? | Notes |
|---|---|---|:---:|:---:|---|
| `clinicalMode` | List | `basic` | ✅ | ❌ | **Effectively dead.** Read only at [`:420`](R/psychopdaROC.b.R#L420) and [`:2624`](R/psychopdaROC.b.R#L2624). `.applyClinicalModeSettings()` writes the mode text to `instructions` at [`:453`](R/psychopdaROC.b.R#L453); `.init()` then **overwrites the same item** with static boilerplate at [`:2060`](R/psychopdaROC.b.R#L2060), and `.run()` overwrites it again at [`:2375`](R/psychopdaROC.b.R#L2375)/[`:2422`](R/psychopdaROC.b.R#L2422) or hides it at [`:2460`](R/psychopdaROC.b.R#L2460). The private field's own comment at [`:275`](R/psychopdaROC.b.R#L275) says the later writer "has to prepend this rather than overwrite it" — **nothing ever prepends it.** Net observable effect of all three levels: one cosmetic line, "Analysis Mode: Basic". |
| `interactiveROC` | Bool | `false` | ✅ | ⚠ | Title "Interactive plot", description "Create an interactive HTML ROC plot (requires plotROC package)". `.plotInteractiveROC()` ([`:5032`](R/psychopdaROC.b.R#L5032)) draws a **static ggplot** titled `"ROC Curve (static rendering)"` into a raster `type: Image`. The `.r.yaml` already removed the `plotROC` package ref confirming zero `plotROC::` calls; the option text was not updated. Promises interactivity that does not exist. |
| `direction` (into IDI/NRI) | List | `>=` | ✅ | ❌ | Threaded through `bootstrapIDI`/`bootstrapNRI`/`computeNRI`/`raw_to_prob`, but **provably inert**: `raw_to_prob` fits `glm(actual ~ predictor)` and a sign flip of a single predictor yields identical fitted probabilities. IDI/NRI therefore always use the data-optimal direction. `.calculateClinicalUtility()` has the *same* invariance and **does** disclose it ([`:6040`](R/psychopdaROC.b.R#L6040)); `idiTable`/`nriTable` do not. |
| `bootstrapReps` | Integer | 2000 | ✅ | ⚠ | Governs pROC bootstraps, but `.calculateBayesianROC()` hardcodes `n_boot <- 2000` at [`:5812`](R/psychopdaROC.b.R#L5812) and ignores it. |

**Outputs declared:** 37  ·  **populated:** 37  ·  **unpopulated:** 0

No dead schema and no output that is computed-then-discarded. The library reviewer's original HIGH
finding (four plots computed and silently thrown away by an unpaired `setVisible(FALSE)`) **has been
fixed** — `criterionPlot`, `prevalencePlot`, `dotPlot` and `precisionRecallPlot` are now purely
declarative, with the history recorded at [`:2020-2027`](R/psychopdaROC.b.R#L2020) and [`:3078`](R/psychopdaROC.b.R#L3078).

**The 10 `setVisible` call sites (all 14 occurrences, classified as requested):**

| Line | Call | Class | Verdict |
|---|---|---|---|
| [`2059`](R/psychopdaROC.b.R#L2059) | `instructions$setVisible(TRUE)` | (b) init leg | Harmless no-op — `.r.yaml` already says `visible: true`. |
| [`2448`](R/psychopdaROC.b.R#L2448) | `instructions$setVisible(FALSE)` | (a) **error mechanism** | Sits immediately before `jmvcore::reject(val)`. Hides the onboarding panel on a validation failure. Self-heals because `.init()` re-runs, but it is error-path visibility manipulation. |
| [`2460`](R/psychopdaROC.b.R#L2460) | `instructions$setVisible(FALSE)` | (b) run leg | **Legitimate** — documented, data-driven onboarding panel. |
| [`3196`](R/psychopdaROC.b.R#L3196) | `delongTest$setVisible(TRUE)` | (b) **UNPAIRED** | ❌ **Real defect.** Overrides `visible: (delongTest)` with no counterpart. `delongTest`'s `clearWith` does not list the `delongTest` option, so unticking "Compare test performance statistically" leaves the **DeLong Test Details panel on screen with its previous content**. Identical failure mode to the one the file itself diagnoses at [`:6410`](R/psychopdaROC.b.R#L6410). |
| [`6255`](R/psychopdaROC.b.R#L6255)/[`6257`](R/psychopdaROC.b.R#L6257) | `metaAnalysisWarning` TRUE / `metaAnalysisTable` FALSE | (b) pair | Paired, but see below. |
| [`6262`](R/psychopdaROC.b.R#L6262)/[`6263`](R/psychopdaROC.b.R#L6263) | `metaAnalysisWarning` FALSE / `metaAnalysisTable` TRUE | (b) **partially restored** | ⚠ Both legs only run inside `.calculateMetaAnalysis()`, which is gated on `metaAnalysis && length(dependentVars) >= 3`. `.updateMetaAnalysisVisibility()` ([`:6895`](R/psychopdaROC.b.R#L6895)) restores the declarative state **only when `< 3` variables** — it `return(TRUE)`s early otherwise. So unticking *Meta-analysis* with 3+ markers leaves whichever of the warning box / pooled-AUC table was last forced visible **on screen and stale**. |
| [`6408`](R/psychopdaROC.b.R#L6408)/[`6413`](R/psychopdaROC.b.R#L6413) | `metaAnalysisForestPlot` TRUE/FALSE | (b) pair | ✅ Correctly paired (this one was fixed). |
| [`6847`](R/psychopdaROC.b.R#L6847) | `metaAnalysisWarning$setVisible(TRUE)` | (a) error reporting | Acceptable — surfaces a forest-plot build failure that would otherwise be a silent gap. |
| [`6903`](R/psychopdaROC.b.R#L6903)–[`6905`](R/psychopdaROC.b.R#L6905) | three `setVisible(FALSE)` | (b) reset leg | Only fires for `< 3` variables; no symmetric restore leg. |

**Case (c) — hidden element given an unreadable `setNote()`: none found.** Every `setNote` target is
visible when written (checked `powerAnalysisTable`'s `degenerate_correlation`, `metaAnalysisTable`'s
`override_warning`, and all `resultsTable`/`aucSummaryTable` notes).

**`tryCatch` vs `reject()` — 53 handlers, 16 `reject()` calls: CLEAN.** Traced every reject site
(`.throwError` ×1 shared by 6 callers, `.deLongTest` ×4, `.enhancedDelongTest` ×6, `.run()` ×2) against
every enclosing handler. The two historically dangerous ones are already fixed and the fixes are
correct: the DeLong handler re-raises on `e$code` at [`:3163-3166`](R/psychopdaROC.b.R#L3163), and the AUC-CI block hoists
`.prepareVarData()` **outside** its `tryCatch` at [`:3379`](R/psychopdaROC.b.R#L3379). I verified the `restart` guard against
jmvcore: `Analysis$.checkpoint()` raises `jmvcore::createError("restarting", "restart")`, so
`identical(e$code, "restart")` does match — the checkpoint restart is not swallowed. The five
`.calculate*()` per-variable handlers enclose no reject and no `.checkpoint()`.

**`requiresData`: correct by omission.** All 12 `renderFun`s read `image$state`, `self$options` and (for
`.plotEffectSize`) `self$results` only. Not one reaches `self$data`, `.prepareVarData()` or a model
refit. No `requiresData:` in the `.r.yaml` is the right answer. `.attachRocOverlayState()` ([`:4087`](R/psychopdaROC.b.R#L4087))
deliberately pushes *counts and quantiles* into state rather than raw values.

**`clearWith` gaps — Images (where it is decisive; a filled Image is not re-rendered unless one of
its own `clearWith` options changed):**

- `plotROC` — has all 5 renderer-read options (that fix is documented in the `.r.yaml`), but is missing `method`, `metric`, `tol_metric`, `break_ties`, `allObserved`, `specifyCutScore`. All six move the **optimal cutpoint marked on the curve** via `setState`. Changing Optimization Metric updates the tables and leaves the marker on the plot stale.
- `powerCurvePlot` — missing **`correlationROCs`** and **`powerAnalysisType`**, both of which the renderer reads out of state (`adjustment_factor`, `auc_target`) at [`:6553-6560`](R/psychopdaROC.b.R#L6553). Changing either updates `powerAnalysisTable` and leaves the curve beside it stale. Same class as the reviewer's original finding.
- `prevalencePlot`, `dotPlot` — missing `method`/`metric`; both states carry the optimal cutpoint.
- `bayesianTracePlot` — missing `direction` and `seed`.
- **`seed` appears in no `clearWith` anywhere**, while six tables print "Random seed: {seed}" and five results are seed-dependent. Changing the seed currently changes nothing on screen.

**Tables:** `sensSpecTable` (`metric`/`tol_metric`/`break_ties`/`boot_runs`), `thresholdTable`
(`maxThresholds`), `partialAUCTable` (`bootstrapCI`/`bootstrapReps`) have gaps too, but `.run()`
rebuilds tables unconditionally so these are cosmetic.

**Dead schema (LOW):** `clinicalInterpretationTable`'s
`visible: (clinicalMode:basic || clinicalMode:advanced || clinicalMode:comprehensive)` enumerates
every value of the option — a tautology. Replace with `visible: true`.

**UI `enable:` drift (MEDIUM):** [`jamovi/psychopdaROC.u.yaml:113`](jamovi/psychopdaROC.u.yaml#L113) gates
Metric Tolerance on `maximize_metric || minimize_metric || maximize_loess_metric || minimize_loess_metric`.
The backend at [`R/psychopdaROC.b.R:2682-2695`](R/psychopdaROC.b.R#L2682) deliberately **also** applies `tol_metric` to
`maximize_boot_metric` / `minimize_boot_metric`, with a long comment explaining that a `NULL` there makes
cutpointr return `NaN` and empties the results table. So with a boot method selected the control is greyed
out while its value is in force and unreachable. The backend fix landed; the `.u.yaml` did not follow.

**Citation refs: clean.** 15 keys used, 15 defined in `jamovi/00refs.yaml`, no case mismatches, no
empty author/year, no option names leaking into a `refs:` block. The `.r.yaml` carries explicit
comments recording three refs that were *removed* as mis-citations (`plotROC`, `Kruschke2014`/
`McElreath2020`, `Cohen1988`/`Faul2007`) — that is exactly the right hygiene.

**Placeholder assessment: FUNCTIONAL.** Real computation throughout; no TODO/FIXME in `.run()`, no
`if (FALSE)` blocks, no half-wired removed options.

#### Notices coverage

**The `jmvcore::Notice` API is not used at all** (0 `Notice`, 0 `NoticeType`, 0 `insert()` — so the
`Group$insert()` bounds-check hazard is absent). All user messaging runs through three channels: the
always-visible `runSummary` "Analysis Status" HTML box fed by `private$.warnUser()` + `.renderRunSummary()`
(de-duplicated, re-rendered on `on.exit` so late warnings survive a `reject()`), `table$setNote()`, and
`jmvcore::reject()`. The *substance* is unusually thorough; the *mechanism* is the project's HTML
pattern, not Notices.

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing required inputs | ERROR | ✅ | n/a | Onboarding panel + `return()` (correct jamovi idiom); conditional validation via `.validateInputs()` → `reject()`. |
| Low n / events | STRONG_WARNING | ✅ | ✅ | `< 10` per class → `.warnUser` at [`:1345`](R/psychopdaROC.b.R#L1345) naming marker, positives and negatives; plus `small_sample` note [`:2229`](R/psychopdaROC.b.R#L2229) and a DeLong-specific note [`:3199`](R/psychopdaROC.b.R#L3199). Hard floor 2 per class → reject. Delivered as WARNING, not ERROR. |
| Assumption violation | STRONG_WARNING | ✅ | ✅ | Perfect separation (AUC ≥ 0.9995), constant marker, class imbalance, > 2 class levels (one-vs-rest), meta-analysis independence (blocking, with an explicit override option). |
| Methodology summary | INFO | ✅ | ✅ | `procedureNotes` Html lists method, metric, direction, ties, tolerance, bootstrap runs. |
| **AUC < 0.5 → ERROR** | ERROR | ⚠ | ✅ | Present as a `setNote` on `aucSummaryTable` ([`:3450`](R/psychopdaROC.b.R#L3450)) with excellent wording (names the markers, both direction symbols, the 1−AUC consequence) — but it is a **footnote, not an error state**, and the analysis proceeds. |
| **AUC < 0.7 → STRONG_WARNING** | STRONG_WARNING | ❌ | ❌ | **Missing.** The only signal is the word "Fair"/"Poor"/"Minimal" in a `clinicalInterpretationTable` cell. No banner. |
| Prevalence < 5% / > 95% | STRONG_WARNING | ✅ | ✅ | Fires at < 10% / > 90% (`.notePredictiveValues` + class-imbalance `.warnUser`), stricter than the checklist. |
| Seed reported | INFO | ✅ | ✅ | "Seed: N" in the Analysis Status box [`:2622`](R/psychopdaROC.b.R#L2622) **and** a `Random seed: {seed}` note on each of the six seed-dependent tables — and only when the random path actually ran. Model behaviour. |

#### Code review

- **Overall quality:** ★★★★☆
- **Architecture:** `.run()` is **1,710 lines** ([`:2361`](R/psychopdaROC.b.R#L2361)–[`:4071`](R/psychopdaROC.b.R#L4071)) — by far the worst structural issue. Sections 2–14 are numbered comment banners doing the job that private methods should. The `.calculate*` extractions show the pattern already exists; sections 10 (DeLong), 13 (partial AUC / smoothing / bootstrap CI / PR curves / classifier comparison) and 14 (IDI/NRI) are self-contained and would lift out unchanged.
- **Mathematical/statistical correctness:** MINOR_ISSUES
- **Clinical readiness:** NEEDS_VALIDATION
- **i18n coverage:** PARTIAL — 221 `.()` in `.b.R` (notes, warnings, table cells, plot labels: very good), but **0** in `R/psychopdaROC-nri-idi.R`, five large raw-English HTML blocks, and **90 of 203** psychopdaROC msgids in `tr.po` have an empty `msgstr`.

**Top issues:**

1. **`clinicalMode` is inert and takes a clinical safety caveat down with it.** `.init()` [`:2060`](R/psychopdaROC.b.R#L2060) overwrites the mode HTML written at [`:453`](R/psychopdaROC.b.R#L453); `.run()` then hides the item entirely at [`:2460`](R/psychopdaROC.b.R#L2460). The Basic-mode text that is discarded contains the AUC interpretation bands **and** the cutpoint-optimism caveat ("…searched on these same data, so the sensitivity and specificity reported at it are optimistically biased…"). The option's `.a.yaml` promises three analysis levels; it delivers a label.

2. **Forest-plot labels can be misaligned with their estimates.** [`:6398`](R/psychopdaROC.b.R#L6398) filters the estimates but not the names:
   ```r
   valid_idx <- !is.na(aucs) & !is.na(se_aucs)
   aucs <- aucs[valid_idx]; se_aucs <- se_aucs[valid_idx]   # vars NOT filtered
   private$.generateMetaAnalysisForestPlot(aucs, se_aucs, vars, combined_result)
   ```
   `data.frame(study = vars, auc = aucs, …)` then either errors (4 markers, 1 dropped → caught, plot replaced by a build-failure note) or, when the lengths happen to divide (6 markers, 3 dropped), **silently recycles** — each AUC plotted twice under the wrong marker's name. Fix: `vars <- vars[valid_idx]` before the call.

3. **Four of the five advanced analyses fail silently when pROC is absent.** `.calculatePowerAnalysis` [`:5568`](R/psychopdaROC.b.R#L5568), `.calculateBayesianROC` [`:5820`](R/psychopdaROC.b.R#L5820), `.calculateClinicalUtility` [`:6011`](R/psychopdaROC.b.R#L6011) and `.calculateMetaAnalysis` all wrap their body in a bare `if (requireNamespace("pROC", quietly = TRUE))` with **no `else`**. The user ticks the box, gets an empty table, and is told nothing. The class already has the right helper — `.checkPackageDependencies("pROC", "…")` [`:366`](R/psychopdaROC.b.R#L366) — and three other methods use it. Use it in these four.

4. **The "Bootstrap ROC with prior weighting" interval is narrower than the bootstrap it comes from, by construction.** [`:5875`](R/psychopdaROC.b.R#L5875): `posterior_samples <- data_weight * bootstrap_aucs + prior_weight * prior_auc` is an affine shrink whose spread is `data_weight = n/(n + prior_precision)` times the bootstrap spread. At n = 50 with `priorPrecision = 100` (both inside the option ranges) the displayed "95% Bootstrap CI" is **one third** the width of the bootstrap interval. The methodology note is admirably candid about everything else (not MCMC, not a Bayes factor, not a credible interval) but does not say the interval narrows with the prior; and `priorPrecision` is on an undocumented pseudo-sample-size scale. Either widen correctly or state the shrinkage in the note.

5. **Confidence bands are drawn in a different palette from the curves they belong to.** [`:4457`](R/psychopdaROC.b.R#L4457) uses `scale_fill_brewer(palette = "Set1")` under a comment reading "Match the curve palette so a band is unambiguously 'its' marker's" — while the curves at [`:4164`](R/psychopdaROC.b.R#L4164) use `jmvcore::colorPalette(n, theme$palette, "color")`. With 2+ markers under any non-Set1 global palette the band colour contradicts the curve colour. Also at [`:4222`](R/psychopdaROC.b.R#L4222) the top-left/top-right legend forces `fill = "white"` on `legend.key`/`legend.background`, which is unreadable under a dark jamovi theme.

6. **Continuous NRI is biased toward 0 when any predicted probability is NA.** [`R/psychopdaROC-nri-idi.R:207-218`](R/psychopdaROC-nri-idi.R#L207) counts reclassifications with `na.rm = TRUE` but divides by `sum(events)` / `sum(non_events)`, the *full* class sizes. Only the all-NA case is guarded ([`:196`](R/psychopdaROC-nri-idi.R#L196)). Use the count of non-NA pairs as the denominator.

   *(Positively: the NRI/IDI CI method is the right one. There is **no asymptotic NRI SE anywhere** — the only interval is a bootstrap percentile CI over `idiNriBootRuns` replicates, the bootstrap correctly resamples the logistic calibration inside each replicate, the p-value uses the `(1 + count)/(B + 1)` correction, failed replicates are dropped rather than silently counted as 0.0, and the seed is a user option reported on both tables. Category-free vs categorical NRI is selected correctly and **which variant ran is disclosed in a table note** ([`:3932`](R/psychopdaROC.b.R#L3932)), with a warning when a malformed threshold string would have silently switched variants. Per the coordinator's correction, `raw_to_prob` is **not** dead — 6 in-file callers. Its only surface issue is that it is `@export`ed and its `warn = TRUE` branch is unreachable from inside the package, since all four internal callers pass `warn = FALSE`.)*

7. **Cutpoint governance is a model for the rest of the module — with one gap.** `.noteCutpointOptimism()` [`:2260`](R/psychopdaROC.b.R#L2260) names the **exact** criterion each of the 12 methods optimises (including "the Optimization Metric setting is not used by this method" for the five that ignore it), states the in-sample optimism, scales the warning with `allObserved`, and carves out `oc_manual` where nothing was searched. `.noteMetricTolerance()` explains the tie-averaging. What is missing is any **correction**: `maximize_boot_metric` selects on resamples but the reported sensitivity/specificity are still resubstitution values, and no bootstrap-corrected or split-sample operating point is offered. Disclosed, not corrected.

8. **i18n is fragmented at the boundary.** The helper file's `warning()` payloads are raw English ("Logistic calibration showed separation or non-convergence…") and are captured by `withCallingHandlers` and spliced into a *translated* wrapper via `.fmt(.("IDI caution for {variable}: {details}"), details = …)` [`:3868`](R/psychopdaROC.b.R#L3868). A Turkish user gets a Turkish sentence with an English clause inside it. `.()` cannot be used in a file-level helper (throws "object 'self' not found"), so the fix is a reason-code enum returned by the helper and mapped in `.b.R` — the pattern the project already used for the follow-up helpers. The five untranslated HTML blocks are `.generateFixedSensSpecExplanation()` ([`:907`](R/psychopdaROC.b.R#L907)–[`:1077`](R/psychopdaROC.b.R#L1077), ~170 lines), `procedureNotes` ([`:2463`](R/psychopdaROC.b.R#L2463)–[`:2546`](R/psychopdaROC.b.R#L2546)), the two `instructions` blocks, the meta-analysis independence warning ([`:6230`](R/psychopdaROC.b.R#L6230)), plus `.printEnhancedDeLong()` headers and the power-analysis `recommendation` strings ([`:5605`](R/psychopdaROC.b.R#L5605), [`:5670`](R/psychopdaROC.b.R#L5670), [`:5723`](R/psychopdaROC.b.R#L5723)) and 8 `paste()`-built image titles ([`:2992`](R/psychopdaROC.b.R#L2992), [`:2998`](R/psychopdaROC.b.R#L2998), [`:3010`](R/psychopdaROC.b.R#L3010), [`:3028`](R/psychopdaROC.b.R#L3028), [`:3093`](R/psychopdaROC.b.R#L3093), [`:3100`](R/psychopdaROC.b.R#L3100), [`:3736`](R/psychopdaROC.b.R#L3736), [`:3752`](R/psychopdaROC.b.R#L3752)) — note that three sibling titles at [`:2953`](R/psychopdaROC.b.R#L2953), [`:3052`](R/psychopdaROC.b.R#L3052), [`:3061`](R/psychopdaROC.b.R#L3061) *are* correctly wrapped, so the pattern is known.

9. **Heavy `setState` payloads.** [`:6193-6199`](R/psychopdaROC.b.R#L6193) serialises `risk = <one per patient>` and `outcome = <one per patient>` into the decision-curve image state **per test variable**, plus `sensitivities`/`specificities` vectors that the renderer reads only as a liveness guard ([`:6663`](R/psychopdaROC.b.R#L6663)) and never uses — `use_risk` is the actual path. `dotPlot` ([`:3027`](R/psychopdaROC.b.R#L3027)) likewise carries one row per patient (intrinsic to a dot plot, but the `threshold`/`direction` columns are constant vectors that could be scalars). Contrast `.attachRocOverlayState()`, which was deliberately reduced to counts and quantiles for exactly this reason — apply the same discipline here and drop the unused ROC vectors.

10. **`sensSpecTable` is a hand-built HTML `<table>`** (`type: Html` + `.formatSensSpecTable()` at [`:5063`](R/psychopdaROC.b.R#L5063), 80 lines of inline CSS with hardcoded `border-color:black` and `font-family:Arial`). It escapes its title correctly, but a jamovi `Table` would theme itself, export to Word/PDF, and translate its headers for free.

**UI label conventions:** structure is exemplary — `VariableSupplier` first, advanced groups in
`collapsed: true` CollapseBoxes, no duplicate control names, checkbox labels are noun phrases
("Confusion matrices", "Threshold table", "Optimal cutpoint") rather than "Show …". Two LOW
deviations: ~16 individual control labels are Title Case where sentence case is the convention
("Positive Class", "Manual Cut Score", "Metric Tolerance", "Random Seed", "Target Sensitivity",
"Reference Variable", "Expected AUC Difference", "Target Power", "Significance Level", "ROC
Correlation", "Prior AUC", "Prior Precision", "Harm-Benefit Ratio", …), and six labels lead with a
verb ("Compare classifier performance", "Test for heterogeneity…", "Combine all curves in one plot",
"Label curves directly", "Adjust for population prevalence…", "Override independence warning").

#### Recommended remediation

- `/fix-function psychopdaROC` — **(1)** make `clinicalMode` observable: prepend `.modeInstructionsHtml` in the `.run()` writers as the field comment already specifies, or drop the option; **(2)** `vars <- vars[valid_idx]` before `.generateMetaAnalysisForestPlot()`; **(3)** pair or remove `delongTest$setVisible(TRUE)` at `:3196` and give `.updateMetaAnalysisVisibility()` a restore leg for the ≥3-variable case; **(4)** route the four bare `requireNamespace("pROC")` guards through `.checkPackageDependencies()`; **(5)** NRI denominators to non-NA pair counts.
- `/check-function psychopdaROC` — `clearWith` completeness: add the six cutpoint options to `plotROC`, `correlationROCs` + `powerAnalysisType` to `powerCurvePlot`, `method`/`metric` to `prevalencePlot` and `dotPlot`, and `seed` to every seed-dependent item; fix the `tol_metric` `enable:` drift in the `.u.yaml`; collapse `clinicalInterpretationTable`'s tautological `visible:`.
- `/fix-notices psychopdaROC` — add the AUC < 0.7 STRONG_WARNING; consider promoting the AUC < 0.5 footnote to an ERROR-strength banner.
- `/prepare-translation psychopdaROC` — the five raw-English HTML blocks, the 8 `paste()`-built image titles, the power-analysis recommendation strings, and a reason-code enum for the NRI/IDI helper warnings; 90 empty `tr.po` msgstrs.
- `/review-function psychopdaROC` — the prior-weighted bootstrap interval's shrinkage (item 4), the inert `direction` in IDI/NRI (disclose as `.calculateClinicalUtility` already does), `bootstrapReps` vs the hardcoded 2000, and a bootstrap/split-sample-corrected operating point to go with the existing optimism disclosure.
- `/security-audit-function psychopdaROC` — LOW only: escape the six `setNote()` interpolations to match the two that already do, and make `.throwError()` call `reject("{}", msg)`.
- **Refactor `.run()`** (1,710 lines) — lift sections 10, 13 and 14 into `.runDeLong()`, `.runAdditionalAnalyses()`, `.runReclassification()`. This is the single change that most reduces the risk of the next defect hiding in here, and the file's own commit archaeology shows that is exactly where they have been hiding.

### sequentialtests

**Status:** ✅ READY
**Files:** [`R/sequentialtests.b.R`](R/sequentialtests.b.R) · [`jamovi/sequentialtests.a.yaml`](jamovi/sequentialtests.a.yaml) · [`jamovi/sequentialtests.u.yaml`](jamovi/sequentialtests.u.yaml) · [`jamovi/sequentialtests.r.yaml`](jamovi/sequentialtests.r.yaml) · [`jamovi/js/sequentialtests.events.js`](jamovi/js/sequentialtests.events.js)
**Metrics:** .b.R LOC 1934 · options 16 · outputs 14 · UI controls 16 · JS LOC 201

#### Security

- **[D-LOW]** [`R/sequentialtests.b.R:1899`](R/sequentialtests.b.R#L1899) — `.safeHtmlOutput()` is a hand-rolled escaper instead of `htmltools::htmlEscape()`. It is *functionally correct* (`&` first, then `<`, `>`, `"`, `'`, all `fixed = TRUE`) and it is applied to both free-text names on every HTML sink that carries them, so there is no XSS. The nit is the extra `/` → `&#x2F;` rule: it is unnecessary outside attribute context and mangles a name such as `HIV Ag/Ab Assay` in any consumer that does not decode numeric references.

Reachability trace for the two `type: String` (HIGH-tier) options `test1_name` / `test2_name`:

| Sink | Escaped? |
|---|:---:|
| `plain_summary` (Html) [`:424`](R/sequentialtests.b.R#L424) | ✅ `.safeHtmlOutput` |
| `explanation_text` (Html) [`:721`](R/sequentialtests.b.R#L721) | ✅ `.safeHtmlOutput` |
| `clinical_guidance` / `formulas_text` (Html) | ✅ names never interpolated |
| `notices` (Preformatted) | ✅ literal renderer, no markup |
| table cells, ggplot labels | ✅ client-side text nodes / grid text |

Categories A, B, C, E, F, G, H, I: clean. No `eval`/`parse`/`as.formula`/`system`/`readRDS`/`source`/`library()`/debug flag. The single `do.call` [`:1896`](R/sequentialtests.b.R#L1896) takes a hardcoded symbol (`.fmt`, defined at `R/utils.R:100`), not a user string. `jamovi/js/sequentialtests.events.js` has no `innerHTML`, no dynamic `Function`, no string-bodied timers.

The Category-3 finding recorded against this file in `references/code-review-checks.md` (`agrepl(test1_name, test2_name, max.distance = 0.3)` — free-text option as a regex) is **resolved**: [`:180`](R/sequentialtests.b.R#L180) now passes `fixed = TRUE` explicitly, and the empty-name guard above it stops a zero-length pattern.

#### jmvcore migration

- **[error]** [`R/sequentialtests.b.R:120-152`](R/sequentialtests.b.R#L120) — 7 ERROR-severity validations use `private$.addNotice('ERROR', …)` + bare `return()`. There are **0 `jmvcore::reject()` calls** in this backend, so invalid input never puts the analysis into jamovi's error state; see the Notices section for the consequence.
- **[error]** 16 sites use `sprintf(.("…"), …)` where `jmvcore::format()` / the project's `.fmt()` is already used elsewhere in the same file (e.g. [`:161`](R/sequentialtests.b.R#L161), [`:190`](R/sequentialtests.b.R#L190), [`:1145`](R/sequentialtests.b.R#L1145)). Beyond style this is the i18n-reorder hazard below — `{name}` tokens are reorderable, bare `%.1f` is not.

Groups `formula`, `na`, `numeric`, `term`, `source`: no opportunities (no-variable calculator, no `self$data`, no `.asSource`).

#### Integration

**Arguments declared:** 16  ·  **used in logic:** 16  ·  **dead:** 0

| Argument | Type | Default | Used? | In logic? | Notes |
|---|---|---|:---:|:---:|---|
| `preset` | List | `custom` | ✅ | ✅ | Backend re-applies the example itself ([`:76`](R/sequentialtests.b.R#L76)) and **overwrites** `test1_*`, `test2_*`, `prevalence`, `strategy`. Safe in the GUI (`.u.yaml` disables those controls via `enable: (preset == 'custom')`), but from R syntax a caller's own values are discarded without being named. |
| `test1_cost` / `test2_cost` | Number | 0 | ✅ | ⚠️ | Only consumer is the `show_cost_analysis`-gated block [`:605`](R/sequentialtests.b.R#L605). The two TextBoxes are always enabled while the checkbox sits inside a *collapsed* `Display Options` box, so typing a cost appears to do nothing. Suggest `enable: (show_cost_analysis)`. |

**Outputs declared:** 14  ·  **populated:** 14  ·  **unpopulated:** 0

No dead schema, no permanently-invisible result. `clinical_guidance` is built on every run but rendered only under `visible: (show_explanation)` [`:803`](R/sequentialtests.b.R#L803) — wasted string building, not a correctness issue.

**Renderer data contract:** all 5 `renderFun`s read `image$state` only and each opens with an `is.null(plotData) → return(FALSE)` guard. Correctly no `requiresData:` on any Image.

**clearWith:** complete. Every result lists the options that feed it; `summary_table`'s conditional `equivalence_note` is explicitly cleared on the `else` branch [`:712`](R/sequentialtests.b.R#L712), which is the right pattern for a strategy-dependent note on a `rows: 1` table.

**Fixed rows:** `individual_tests_table` (3), `population_flow_table` (3) and `cost_analysis_table` (3) are all `addRow`-ed in `.init()` and only `setRow`-ed in `.run()` — no accumulation, structure visible before the first run.

**Citation refs:** `ClinicoPathJamoviModule`, `ConditionalDependenceDiagnosticTests`, `CDC_HIV_Testing_2023` — all 3 defined in `jamovi/00refs.yaml` (lines 220, 315, 200) with populated author + year. No case mismatch, no option name inside `refs:`.

**`.events.js` ↔ `.a.yaml`:** clean. The JS touches `ui.preset`, `ui.test1_name/_sens/_spec`, `ui.test2_name/_sens/_spec`, `ui.prevalence`, `ui.strategy` — all 9 exist. All 7 rows of `SEQUENTIAL_PRESET_CONFIGS` match `private$.getPresetValues()` [`:1818`](R/sequentialtests.b.R#L1818) value-for-value (verified by hand; `tests/testthat/test-sequentialtests-release-review.R` also compares them).

#### Notices coverage

There is **no `jmvcore::Notice` object in this backend.** All severities are collected into `private$.noticeList` and flushed as one **`Preformatted`** result named `notices`, with the severity rendered as a text prefix (`"ERROR: "`, `"STRONG WARNING: "`, `"WARNING: "`) at [`:1885`](R/sequentialtests.b.R#L1885).

| Trigger | Type | Present? | Quantified? | Notes |
|---|---|:---:|:---:|---|
| Missing / invalid required inputs | ERROR | ✅ | ✅ | 7 checks, [`:120-152`](R/sequentialtests.b.R#L120). Delivered as grey preformatted text, not jamovi's red error state. |
| Low n / events | STRONG_WARNING | ✅ | ✅ | "Illustrative Population Too Small" fires when expected diseased < 10 [`:489`](R/sequentialtests.b.R#L489) (WARNING tier) |
| Assumption violation (conditional dependence) | STRONG_WARNING | ✅ | ✅ | Name-similarity heuristic [`:184`](R/sequentialtests.b.R#L184), with the default-pair exemption correctly requiring **both** names untouched |
| Methodology summary | INFO | ✅ | ✅ | Two INFO notices at the bottom [`:1142`](R/sequentialtests.b.R#L1142), [`:1150`](R/sequentialtests.b.R#L1150) |
| Diagnostic test: prevalence < 5% or > 95% | STRONG_WARNING | ✅ | ✅ | Two tiers, ≤1% and <5% [`:170-177`](R/sequentialtests.b.R#L170); ≥90% at [`:167`](R/sequentialtests.b.R#L167) |
| PPV/NPV/LR undefined | STRONG_WARNING / WARNING | ✅ | ✅ | [`:326`](R/sequentialtests.b.R#L326), [`:334`](R/sequentialtests.b.R#L334), [`:339`](R/sequentialtests.b.R#L339) |

Consequences of the Preformatted sink, in priority order:

1. An ERROR **does not enter jamovi's error state**. The analysis `return()`s with the previous run's tables still on screen, so a user who types an invalid value sees a full, stale result set with one grey `ERROR:` line above it. Mitigated in practice because `.a.yaml` min/max (`0.01–0.99` for sens/spec, `0.001–0.999` for prevalence, `100–100000` for population) makes these paths near-unreachable from the GUI — they are defence-in-depth only.
2. Severity is invisible: ERROR, STRONG_WARNING and WARNING render in identical grey type, distinguished only by a word.
3. The justifying comment at [`:1811-1813`](R/sequentialtests.b.R#L1811) is **stale and cites a retracted premise** — "avoids … the `jmvcore::Notice` serialization error from `self$results$insert(999, Notice)`". Per `CLAUDE.md` / review guide §13 the defect was `Group$insert()`'s missing bounds check, never `Notice`; `$add()` is safe. Keep the Preformatted panel if the multi-line layout is wanted, but the ERROR/STRONG_WARNING tiers should *additionally* go out as real `jmvcore::Notice` objects via `self$results$add(notice)`.

Positive: `.addNotice()` calls `.renderNotices()` immediately [`:1873`](R/sequentialtests.b.R#L1873), so none of the four early-`return()` paths drops its notices — the "notices dropped on early return" trap is avoided. No `$insert()` anywhere. No `setVisible(FALSE)` used as an error mechanism.

**Red ERROR on open:** none. Every option carries a default, all defaults pass validation, so a freshly opened analysis renders the two INFO notices and nothing else.

#### Code review

- **Overall quality:** 4.5 stars
- **Architecture:** OK — `.run()` is long (≈1095 lines, [`:48`](R/sequentialtests.b.R#L48)–[`:1142`](R/sequentialtests.b.R#L1142)) but the bulk is straight-line HTML assembly for `show_formulas`/`show_explanation`; the five renderers and six helpers are properly split. Extracting `.buildFormulasHtml()` / `.buildExplanationHtml()` would halve it.
- **Mathematical/statistical correctness:** CORRECT
- **Clinical readiness:** READY (for its stated teaching / exploration purpose)
- **i18n coverage:** PARTIAL

**Statistical verification (done by hand against the code):**

- **Combination formulas match the stated strategy, none swapped** [`:302-320`](R/sequentialtests.b.R#L302). serial_positive `Se₁·Se₂` / `Sp₁+(1−Sp₁)·Sp₂`; serial_negative `Se₁+(1−Se₁)·Se₂` / `Sp₁·Sp₂`; parallel `Se₁+Se₂−Se₁Se₂` / `Sp₁·Sp₂`.
- **Stage-2 prevalence — the signature bug of this calculator class is NOT present.** The second stage never re-uses the pre-test prevalence: it works from the *subgroup counts* leaving test 1 (`diseased_in_test2 <- test1_tp`, `healthy_in_test2 <- test1_fp` at [`:538`](R/sequentialtests.b.R#L538); the mirror pair at [`:553`](R/sequentialtests.b.R#L553)), which carries the post-test prevalence implicitly and exactly. `.plot_probability` does the same job on the odds scale, chaining `post_test1_pos_odds × LR₂` [`:1493`](R/sequentialtests.b.R#L1493). Combined PPV/NPV correctly apply Bayes with the *original* cohort prevalence and the *combined* Se/Sp [`:323-336`](R/sequentialtests.b.R#L323) — which is the right quantity for the whole cohort, not a double-application.
- **Population flow adds up at every stage.** Algebraically `final_tp + final_fn = diseased` and `final_fp + final_tn = healthy` in all three branches, so every row totals `pop_size`. Counts are stored **unrounded** and rounded only by the column formatter, so the table sums exactly — no rounded-counts-vs-unrounded-percentages mismatch.
- **Cost is charged to who is actually tested** [`:610-620`](R/sequentialtests.b.R#L610): `n_test1 = pop_size`; `n_test2 = test1_pos` (serial +), `test1_neg` (serial −), `pop_size` (parallel). A `setNote` states the counts are expected values.
- **Conditional independence is stated as an assumption in six places** and — unusually well done — with the *direction* of the bias resolved per strategy rather than a generic "too optimistic" [`:388-392`](R/sequentialtests.b.R#L388), plus the Gardner 2000 citation. The "no confidence interval" note [`:671`](R/sequentialtests.b.R#L671) and the serial-negative ≡ parallel equivalence note [`:702`](R/sequentialtests.b.R#L702) are both correct and both pre-empt a user bug report.
- PPV/NPV in `.plot_performance` [`:1399-1405`](R/sequentialtests.b.R#L1399) are the correct prevalence-normalised rearrangement of Bayes; `nnt = ceiling(1/(prev × Se_combined))` is NNS-to-one-true-positive and its scope limit is noted [`:679`](R/sequentialtests.b.R#L679).
- Plot mechanics follow the guide: `theme_minimal()/theme_void()` → `ggtheme` → tweaks and `scale_*_manual()` **after** `ggtheme`, with the reason recorded in-comment [`:1568`](R/sequentialtests.b.R#L1568); `vjust = 1` restored after `ggtheme` drops it [`:1433`](R/sequentialtests.b.R#L1433).

**Top issues:**

1. **Silent option override when a teaching example is selected** ([`:76-104`](R/sequentialtests.b.R#L76)). From R syntax, `sequentialtests(preset = "hiv_screening_confirmation", prevalence = 0.30)` reports **2%** and never says the caller's `prevalence` was discarded. The STRONG_WARNING that fires talks about the example not being clinical guidance; it never names the overridden options. Fix: append the replaced option names to that notice, e.g. `"Values supplied for prevalence, test1_sens … were replaced by the example."`.
2. **ERROR-tier validation does not reach jamovi's error state** — see Notices above. 0 `jmvcore::reject()` calls; the ERROR word is plain grey text above a stale table.
3. **i18n = PARTIAL / fragmented.** 262 `tr.po` blocks cite this file and **34 carry an empty `msgstr`** (including the `plain_summary` and `clinical_guidance` panels and most of the PPV/NPV derivation bullets), so a Turkish user sees those sections in English. Separately, the formulas panel is assembled from ~60 one-fragment `.()` calls including 4 markup-only msgids (`<ul>`, `</ul>`, `<ol>`, `</ol>`) sent to translators. And 6 `sprintf(.("…"))` templates carry 2–4 **non-indexed** conversions ([`:161`](R/sequentialtests.b.R#L161), [`:164`](R/sequentialtests.b.R#L164), [`:190`](R/sequentialtests.b.R#L190), [`:210`](R/sequentialtests.b.R#L210), [`:214`](R/sequentialtests.b.R#L214), [`:1145`](R/sequentialtests.b.R#L1145) — the last has 4), so a translation that reorders sensitivity and specificity silently swaps the two numbers. I checked every translated msgid in `tr.po`: **no live reorder today**, so this is a latent hazard. Convert to `%1$…` or to `{name}` tokens.
4. **Cost units are never stated where the numbers are.** `.a.yaml` calls them "user-defined currency or cost units", but `cost_analysis_table`'s `Unit Cost` / `Total Cost` columns carry no unit and the table's only note is about expected counts. A reader cannot tell whether 12 500 is dollars, euros or lira. Add it to the column titles or a second `setNote`.
5. **`population_flow_table` has no expected-counts note** although `cost_analysis_table` has one [`:654`](R/sequentialtests.b.R#L654). The flow table routinely shows fractional people (`False Positives 270.0`); the `diseased < 10` WARNING only fires at the extreme.
6. **Minor — the formulas panel asserts the independence substitution as a given.** "Given a positive Test 1, probability of testing positive on Test 2: 0.80" [`:812`](R/sequentialtests.b.R#L812) (and its serial-negative mirror) is exactly the conditional-independence step; every *other* panel flags it, this one does not.

**Strengths:** the three combination formulas, the population flow and the stage-2 conditioning are all correct and mutually consistent; the disclaimer discipline around the named examples is genuinely thorough (option titles carry "(Illustrative)", the CollapseBox is labelled "Teaching Examples (Not Clinical Guidance)", a STRONG_WARNING fires on selection, and the `clinical_guidance` panel repeats it); the directional conditional-dependence caveat and the serial-negative ≡ parallel equivalence note are the kind of thing most calculators omit. No raw HTML `<table>` anywhere. Six test files present.

#### Recommended remediation

- `/fix-notices sequentialtests` — add real `jmvcore::Notice` objects for the ERROR and STRONG_WARNING tiers alongside the existing Preformatted panel (use `self$results$add()`, never `$insert(999, …)`), and delete the stale retracted-premise comment at [`:1811`](R/sequentialtests.b.R#L1811).
- `/jamovify-function sequentialtests --pattern=error --apply` — `jmvcore::reject()` for the 7 fatal validations; `jmvcore::format()`/`.fmt()` for the 16 `sprintf(.())` templates (this also closes the reorder hazard).
- `/prepare-translation sequentialtests` — fill the 34 empty `tr.po` msgstrs, merge the markup-only fragments into their surrounding sentences, index the multi-conversion templates.
- `/review-function sequentialtests` — items 1, 4, 5, 6 above (name the overridden options in the preset warning; label the cost unit; add the flow-table expected-counts note; caveat the independence step in the formulas panel).
- No security remediation required; the one LOW is cosmetic (`/` over-escaping in `.safeHtmlOutput`).

---

## Cross-Cutting Issues

Ordered by how much a fix buys. A count of *n* means *n* of the 14 shipped analyses carry the
pattern. All 14 are in a production `menuGroup` (`meddecide`, or `Power #meddecide` for the
`kappaSize` trio), so there is **no promotion-debt column here** — every hit is a live defect.
`agreement` has moved to `menuGroup: meddecideT` and is out of scope.

### 1. Safety notices that cannot reach jamovi's error state — 6 analyses

**`decision`, `decisioncompare`, `decisioncurve`, `enhancedROC`, `kappaSizeCI`, `sequentialtests`**

The module's dominant notice architecture collects messages into a private list and renders them into
an `Html` or `Preformatted` result. That is a legitimate choice — `jmvcore::Notice` content renders as
escaped plain text and takes no newlines, and the project decided to keep richer panels. But the
**severity is lost on delivery**: an ERROR renders as grey body text, positioned by insertion order,
above the previous run's stale tables, and the analysis never enters jamovi's error state.

`enhancedROC` is the extreme case: **55 `tryCatch` sites, zero `jmvcore::reject()` calls**, and roughly
60 hand-rolled HTML notices. No failure in that analysis, however fundamental, is ever signalled as a
failure. `sequentialtests` has 7 ERROR-tier checks and 0 `reject()`. `decisioncurve` uses bare `stop()`
in 4 places where `jmvcore::reject()` belongs. `decisioncurve` additionally renders ERRORs *below*
earlier WARNINGs because the panel sorts by insertion order, not severity.

**The distinction that matters:** a *validation* failure the user can fix by changing an option should
call `jmvcore::reject()`; an *advisory* belongs in the panel. Today both go to the panel.

**Reference pattern:** `nogoldstandard` and `lassologistic` both call `jmvcore::reject()` for genuine
validation failures while keeping an HTML panel for advisories.

**Run:** `/fix-notices <name>` on each.

### 2. The retracted "Notice serialization" premise, still in source comments — 5 files

[`R/decisioncompare.b.R:208`](R/decisioncompare.b.R#L208) ·
[`R/sequentialtests.b.R:1812`](R/sequentialtests.b.R#L1812) ·
[`R/kappaSizeCI.b.R:684`](R/kappaSizeCI.b.R#L684) ·
[`R/nogoldstandard.b.R:17`](R/nogoldstandard.b.R#L17) ·
[`R/lassologistic.b.R:20`](R/lassologistic.b.R#L20)

These comments justify the HTML notice panels on the grounds that `jmvcore::Notice` cannot be
serialised. **It can.** The 2026-09-22 correction established that the `attempt to apply non-function`
crash came from `jmvcore::Group$insert()` having no bounds check — an `Html` element at the same index
fails identically. The architectural decision stands on the *rendering* grounds above; the recorded
*reason* is false, and the next maintainer who reads it will conclude that Notice is unusable.

[`R/decisioncalculator.b.R:15`](R/decisioncalculator.b.R#L15) already carries the corrected wording, so
the replacement text exists in-tree. Note that
[`R/lassologistic.b.R:2402`](R/lassologistic.b.R#L2402) is about protobuf-serialising `glmnet` model
objects — that one is legitimate and should stay.

No analysis in this module calls `$insert()` at all, so the underlying bug is not reachable here.

### 3. Clinical guards gated behind default-off display checkboxes — 2 confirmed

A warning that fires only when the user ticks an unrelated display box is a warning that does not
exist for the user who most needs it.

- **`enhancedROC`** — [`R/enhancedROC.b.R:2585`](R/enhancedROC.b.R#L2585): the class-imbalance
  `STRONG_WARNING` is guarded by `is_imbalanced && self$options$showImbalanceWarning`, and
  `showImbalanceWarning` has `default: false`. A 20:1 imbalanced outcome yields an AUC with no caution.
- **`decisioncombine`** — "Positive Levels May Be Inverted" and "No Rule Performs Better Than Chance"
  live only inside `.populateRecommendation()`, gated by `showRecommendation` (`default: false`). A
  swapped positive level inverts every number in the analysis and nothing detects it by default.

`decisioncurve` has two candidate sites (`showBenefitRange`, `showDecisionConsequences`) that the
per-analysis audit did not escalate.

**Rule of thumb:** display options may gate *presentation*. They must never gate *detection*.

### 4. Incomplete Turkish catalog — 12 analyses

**Everything except `decisioncalculator` and `lassologistic`.**

Two distinct failures, and only the second is an i18n-process problem:

**(a) `.()` strings that never reached `catalog.pot`** — untranslatable no matter what a translator
does. The `kappaSize` trio shares the defect through a common `.fmtCount` helper:
[`R/kappaSizePower.b.R:52`](R/kappaSizePower.b.R#L52) ("below 0.0001"),
[`R/kappaSizeFixedN.b.R:55`](R/kappaSizeFixedN.b.R#L55), `:127`, `:129`.

**(b) Empty `msgstr` in `tr.po`** — measured per analysis: `cotest` 108 of 126 (86%), `psychopdaROC`
90 of 203 (44%), `enhancedROC` 117 absent + 54 empty (~45% short), `decisioncurve` 12,
`kappaSizePower` 3. Against this, `decision` is 295 of 315 translated — so the module is not
uniformly behind, and a per-analysis catalogue refresh is the right granularity.

**Also:** `psychopdaROC` has **zero** `.()` calls in `R/psychopdaROC-nri-idi.R` and five large raw-English
HTML blocks. A stale in-source TODO at [`R/decision.b.R:38-40`](R/decision.b.R#L38) claims only 2 of 106
strings are translated; the measured figure is 295 of 315. Correct the comment.

**Run:** `/prepare-translation <name>`.

### 5. Bare-identifier `.a.yaml` `title:` values — 10 analyses

`kappa0`, `kappa1`, `kappaL`, `kappaU`, `raters`, `alpha`, `power` and similar appear as option
`title:` values. The `.u.yaml` overrides them with correct sentence-case labels, so the GUI is fine —
but `title:` is what surfaces in the generated `man/*.Rd` and in jamovi's **syntax mode**, where a user
reading generated R code sees `raters` rather than "Raters". `outcome`'s title in `kappaSizeCI` is the
ungrammatical "Number of outcome level".

Structurally the UI is in good shape: `VariableSupplier` placement, `CollapseBox` Title Case, advanced
options collapsed, and sentence-case control labels are all correct module-wide, and the release gate
confirms 0 off-convention `CollapseBox` headings. One accessibility gap:
[`jamovi/kappaSizePower.u.yaml:81`](jamovi/kappaSizePower.u.yaml#L81) sets `label: ''` on the `props`
TextBox, leaving the input without an accessible name.

### 6. `clearWith` omits an option that changes displayed text — 6 analyses

**`decision`, `decisioncombine`, `decisioncompare`, `decisioncurve`, `enhancedROC`, `psychopdaROC`**

A results item whose `clearWith` is narrower than what actually feeds it keeps showing the previous
run's content. Worst instance: `enhancedROC`'s `clinicalContext` feeds user-visible prose in **10
results and appears in zero `clearWith` lists**; `seed` and `bootstrapSamples` are missing from 3
seed-dependent tables, and `direction` from the 4 risk-probability results. In `psychopdaROC`,
`delongTest` is absent from its own item's `clearWith`, so unticking it leaves a stale DeLong panel on
screen.

The release gate reports 0 *dangling* `clearWith` entries — that check catches names that do not exist,
not names that are missing. The two are different failures and only the second is present here.

### 7. Under-graded clinical thresholds — 5 analyses

**`decisioncompare`, `enhancedROC`, `kappaSizeFixedN`, `lassologistic`, `psychopdaROC`**

The sharpest instance: `enhancedROC` raises a **STRONG_WARNING**, not an ERROR, when events < 10, so a
200-patient dataset with 4 events produces a full results pane with an AUC, a CI and an optimal cutpoint.
`kappaSizeFixedN` gives no warning at all for a positive-but-useless lower bound (0 < kappaL < 0.40).

Accepted as deliberate, not counted against `enhancedROC`: AUC < 0.5 raises ERROR only when the whole CI
lies below 0.5 and STRONG_WARNING otherwise. That is a defensible, simulation-backed refinement of the
checklist rather than a gap.

### 8. `.run()` past 900 lines — 8 analyses

`psychopdaROC` 1,710 · `decisioncalculator` 1,010 · `decision` 979 · plus `cotest`, `decisioncurve`,
`enhancedROC`, `nogoldstandard`, `sequentialtests`. LOW on its own, but this is where the other findings
in this list are hiding: every one of the module's genuine wrong-number bugs sits inside a `.run()` or a
populate method past the 200-line mark.

### 9. Hardcoded white ggplot backgrounds — 9 sites, 2 analyses

[`R/enhancedROC.b.R:3784`](R/enhancedROC.b.R#L3784), `:3933-3934`, `:4910-4911` and
[`R/psychopdaROC.b.R:4223-4254`](R/psychopdaROC.b.R#L4223) set
`panel.background` / `legend.background` to `element_rect(fill = "white")`. In `enhancedROC` these are
applied *after* `ggtheme` under the **default** `plotTheme: clinical`, so they win. On jamovi's dark
theme the panel or legend is a white rectangle.

**Tooling gap worth recording:** `python3 tools/theme_safe_html.py` reports **0** for this module. It
only scans HTML string literals and never inspects `ggplot2::element_rect`. A module can be fully
theme-safe by that tool and still ship white plot panels.

### 10. Plots do not follow jamovi's global palette — 6 of 11 plot-bearing analyses

`cotest`, `decisioncalculator`, `decisioncompare`, `lassologistic`, `nogoldstandard` and
`sequentialtests` never reference `theme$palette` or `jmvcore::colorPalette`; `enhancedROC` references
it but 11 of its 12 renderers use a hardcoded palette anyway. `theme` is already a parameter of every
render function. Adding a "jamovi (follow global)" choice to each palette option lets a document's plots
agree across modules (review guide §23).

### 11. Smaller recurring patterns

| Pattern | Count | Analyses |
|---|:---:|---|
| Dead code referencing removed/inert schema | 3 | `decision`, `decisioncurve`, `psychopdaROC` |
| Genuinely inert option | 3 | `decisioncurve` (`comparisonMethod`), `enhancedROC`, `psychopdaROC` (`clinicalMode`) |
| Model object / large vectors in `setState()` | 3 | `decisioncompare`, `decisioncurve`, `psychopdaROC` |
| `.u.yaml` `enable:` drift vs backend behaviour | 3 | `enhancedROC`, `psychopdaROC`, `sequentialtests` |
| Fragmented / positionally-glued `.()` strings | 3 | `enhancedROC`, `psychopdaROC`, `sequentialtests` |
| Inconsistent HTML escaping (LOW, defence-in-depth) | 3 | `cotest`, `decisioncompare`, `psychopdaROC` |
| Unreachable `@export`ed helper functions | 2 | `enhancedROC` (8 of 12, ~370 lines), `psychopdaROC` |
| Tabular data drawn as raw HTML instead of a `Table` | 2 | `cotest`, `psychopdaROC` |
| Computed result permanently invisible to the user | 2 | `nogoldstandard`, `psychopdaROC` |

---

## Statistical and Clinical Findings Worth a Maintainer's Attention

No analysis was judged MAJOR_ISSUES. Eight were MINOR_ISSUES, and the following **change a number the
user reads** — these are the ones to fix first.

1. **`lassologistic` — Variable Importance uses the wrong standard deviations.**
   [`R/lassologistic.b.R:2253`](R/lassologistic.b.R#L2253) thresholds `|beta| * data$X_sd`, where `X_sd`
   holds the *original* SDs. The coefficient table's identical zero-rule thresholds against
   `apply(fit_X, 2, stats::sd)` ([`:1502`](R/lassologistic.b.R#L1502)), and `fit_X` is the *scaled*
   matrix when `standardize = TRUE` (`X <- scale(X)` at [`:602`](R/lassologistic.b.R#L602)). The two
   factors are inverses of each other, and the relationship flips again in the `standardize = FALSE`
   branch. The two tables can disagree about which variables are in the model. *Independently confirmed
   during aggregation.*

2. **`enhancedROC` — sensitivity/specificity CIs ignore the requested confidence level.**
   `.calculateBinomialCI()` omits `conf.level`, so those intervals are always 95% while the AUC interval
   honours `confidenceLevel`. A user selecting 99% gets a mixed table with no indication.

3. **`nogoldstandard` — the latent-class bootstrap does not do what its note says.** Every replicate
   warm-starts from the full-sample fit with `n_starts = 1`, while the CI note claims a full refit per
   resample. The interval is too narrow and its stated provenance is wrong.

4. **`decisioncurve` — a shared RNG stream makes an unrelated checkbox move a p-value.** Toggling the
   CI checkbox changes the comparison p-value because both consumers draw from one stream, while the
   note claims exact reproducibility. Two comparison tables also use different bootstrap counts
   (a 1,000 cap vs the full `bootReps`).

5. **`decisioncompare` — manuscript text asserts a test that never ran.** When no pair is computable,
   `.any_significant_comparison = FALSE` produces ready-to-paste prose claiming "no significant
   difference".

6. **`psychopdaROC` — NRI denominator mismatch** (`sum(events)` against `na.rm`'d numerators); forest-plot
   `vars` not filtered by `valid_idx`, so estimates can be recycled and mislabelled; a prior-weighted
   bootstrap "95% CI" that narrows by `n/(n+precision)` by construction.

7. **`decision` — footnotes accumulate across runs.** `statsnames` cells are set only in `.init()` while
   `addFootnote` runs every `.run()`, so footnotes duplicate on re-run and never clear when `fnote` is
   unticked.

8. **`decisioncalculator` — an invalid *optional* cut-off aborts `.run()`.**
   [`R/decisioncalculator.b.R:878`](R/decisioncalculator.b.R#L878) returns early, blanking the Fagan plot
   and all four HTML panels although the primary tables had already succeeded.

### What the audit checked and found correct

Worth recording, because these are the traps this codebase has been bitten by before:

- **Positive-`Level` wiring** verified end-to-end in `decision`, `decisioncombine` and `decisioncompare`.
- **Explicit `addNA` levels excluded, not silently counted as negative** ([`R/decision.b.R:427`](R/decision.b.R#L427)).
- **McNemar guarded on discordant pairs, not total N** — `decisioncompare` switches to an exact binomial
  below 25 discordant pairs and names the method in the output.
- **Decision-curve net benefit** — weighting is `pt/(1-pt)`, treat-all recomputed per threshold, predictor
  range validated and *rejected* rather than silently rescaled.
- **Sequential-testing stage 2** conditions on the subgroup leaving test 1, so the post-test prevalence is
  carried correctly — the signature bug of these calculators is absent.
- **Post-selection inference** — `lassologistic` reports no SE, p-value or CI for any LASSO coefficient,
  with an explanatory note. Zero fabricated statistics module-wide.
- **`requiresData`** — all renderers in all 14 analyses traced through their `private$` helpers; none
  reaches `self$data`, and the flag is correctly absent everywhere.
- **`tryCatch` vs `reject()`** — 1 swallow found (`nogoldstandard`'s bootstrap handler, defensible and
  correctly re-raising `.checkpoint()`'s `restart`). `psychopdaROC`'s two historically dangerous handlers
  are already fixed.
- **The library reviewer's original HIGH against `psychopdaROC` is fixed** — the four silently-discarded
  plots are now purely declarative, with the history documented at
  [`R/psychopdaROC.b.R:2020-2027`](R/psychopdaROC.b.R#L2020).

---

## Remediation Playbook

**Priority 1 — correctness (a user reads a wrong number).**

```
/validate-function lassologistic      # SD mismatch in Variable Importance
/validate-function enhancedROC        # binomial CI ignores conf.level
/validate-function nogoldstandard     # bootstrap warm-start vs its own note
/validate-function decisioncurve      # shared RNG stream; mismatched bootstrap B
/validate-function psychopdaROC       # NRI denominator; forest-plot var filtering
/fix-function decisioncompare         # "no significant difference" for an unrun test
/fix-function decision                # footnote accumulation across runs
/fix-function decisioncalculator      # early return blanks plot + 4 panels
```

**Priority 2 — clinical safety.**

```
/fix-notices enhancedROC              # ungate imbalance warning; events<10 -> ERROR
/fix-notices decisioncombine          # ungate inverted-level + below-chance guards
/fix-notices kappaSizeFixedN          # warn on positive-but-inadequate kappaL
```

**Priority 3 — notice architecture (the 6-analysis pattern).**

```
/fix-notices decision decisioncompare decisioncurve enhancedROC kappaSizeCI sequentialtests
```
Split validation failures (`jmvcore::reject()`) from advisories (HTML panel), sort the panel by
severity, and replace the retracted serialization comments using
[`R/decisioncalculator.b.R:15`](R/decisioncalculator.b.R#L15) as the model.

**Priority 4 — module hygiene (no per-analysis tool needed).**

1. **Regenerate the submodule.** `Rscript _updateModules.R --dry-run`, then without `--dry-run`. Re-run
   `python3 tools/release_gate.py` afterwards; both current advisories should clear.
2. **Drop 6 unused `Imports`** — remove from `DESCRIPTION`, delete the tags from `R/zzz_imports.R`
   (including `@importFrom vcd Kappa` at line 19), and add a `prune_imports` entry in the umbrella
   registry. `--dry-run` re-derives every entry at plan time, so it will catch a mistake before anything
   is written.
3. **Update `NEWS.md`** — newest entry is 1.0.6.03; `DESCRIPTION` is 1.0.83.02.
4. **Replace 9 hardcoded white ggplot backgrounds** and extend `tools/theme_safe_html.py` to inspect
   `ggplot2::element_rect` fills, which it currently cannot see.
5. **Delete 5 unreachable `@export`ed functions** from `R/enhancedROC-errors.R` (~370 of 478 lines).
6. **Rename bare-identifier `.a.yaml` `title:` values** across the 10 affected analyses.

**Priority 5 — internationalization.**

```
/prepare-translation cotest psychopdaROC enhancedROC kappaSizeCI kappaSizeFixedN kappaSizePower
```
Regenerate `catalog.pot` first — several `.()` strings have never been extracted, so no amount of
translation work reaches them.

**Not recommended.** `/security-audit-function` is not worth a slot on any analysis in this module.
Zero HIGH and zero MEDIUM findings across 35,670 lines; the 21 LOWs are defence-in-depth notes. Both
large ROC backends were traced end-to-end for XSS and escape at the render sink, which is the right
design.

---

## Appendix: Guides and Tools Consulted

- `vignettes/jamovi_library_review_guide.md` — §13 (`Group$insert` bounds), §15–18 (`requiresData`,
  `tryCatch`/`reject`, `setState` payloads), §20 (fabricated statistics), §23 (global palette),
  §24 (promotion debt), §25 (red ERROR on open), §26 (HTML tables), §27 (self-description)
- `.claude/skills/audit-module/references/` — `security-patterns.md`, `jmvcore-migration.md`,
  `integration-checks.md`, `notices-checklist.md`, `code-review-checks.md`
- `tools/release_gate.py`, `tools/check_state_guards.py`, `tools/theme_safe_html.py`

One correction back to the skill's own reference material: the Category-3 finding recorded against
`sequentialtests` in `references/code-review-checks.md` (`agrepl` with a free-text regex) is **resolved**
in the current source — [`R/sequentialtests.b.R:180`](R/sequentialtests.b.R#L180) passes `fixed = TRUE`
and guards the empty-name case.

---

*Generated by the `audit-module` skill, standard profile. Re-run with `--profile deep` for R6/R-package
per-analysis hygiene and vignette cross-referencing, or `--functions a,b,c` for a targeted re-audit.*

---

# Addendum — Remediation Pass, 2026-09-23

All fixes were made in the **umbrella** (`ClinicoPathJamoviModule`). The generated sibling has not
been regenerated; `Rscript _updateModules.R --dry-run` then a real run is still required, and that
is deliberately left to the maintainer because the updater ships the working tree and this one
carries unrelated in-flight edits.

## Corrections to this report

Two of the report's own recommendations were wrong, and acting on them would have caused damage.

**"Delete 5 unreachable `@export`ed functions from `R/enhancedROC-errors.R` (~370 of 478 lines)."**
Wrong. Two of the five (`safe_execute`, `create_enhanced_result`) are called by
`R/enhanced_wrapper_example.R`, and the project already holds a standing decision about that file:
`tests/testthat/test-zzz-analysis-file-naming.R:100` lists it as *"dead, but exports
enhanced_ttest(): removal is an API change"*. The accurate, narrower fact is that
`enhancedROC-errors.R` ships ~370 lines meddecide never executes — install weight at file
granularity, which is the documented design, not a defect. **No action taken.**

**The "27 dead options" figure quoted during the audit.** Essentially all false positives, for two
different reasons — dynamic access via `self$options[[paste0("test", i)]]`, and options consumed
declaratively by a `.r.yaml` `visible:` binding. Exactly one option in the module was genuinely
inert: `decisioncurve`'s `comparisonMethod`. It is now removed from the `.a.yaml`, `.u.yaml`,
`.r.yaml` and the test that passed it, and `prepare()` confirms it is gone from the generated
wrapper.

**The 5 "description breaks the library listing" gate warnings** were stale-sibling artefacts, as
[M1](#m1--the-generated-submodule-is-stale-medium) said. Nothing to fix.

## Fixed

**Wrong numbers**

- `lassologistic` — the two zero-rules now share one scale factor via a new `private$.fitColSDs()`,
  so the Variable Importance panel and the coefficient table can no longer disagree about which
  variables are in the model. The old code was wrong in *both* standardize branches, not just one.
- `enhancedROC` — `.calculateBinomialCI()` now honours `confidenceLevel`; the two CI column headings
  are set at run time instead of asserting 95%.
- `decisioncompare` — prose no longer claims "no significant difference" when no comparison was
  computable; the three states are now distinguished explicitly.
- `decision` — `statsnames` is re-set in the blanking loops, so epiR footnotes stop accumulating
  across runs and clear when `fnote` is unticked.
- `decisioncalculator` — an invalid *optional* cut-off no longer aborts `.run()` and blank the Fagan
  nomogram and four panels; a regression test was added that fails on the pre-fix code.
- `decisioncurve` — each bootstrap consumer draws from its own reproducible substream, so toggling
  the CI checkbox no longer moves a comparison p-value; both comparison tables now use one
  bootstrap count, memoized so a pair is resampled once rather than twice.
- `psychopdaROC` — forest-plot `vars` filtered by `valid_idx` (estimates could be recycled and
  mislabelled); prior-weighted interval relabelled for what it is; `delongTest` made declaratively
  visible with its option in `clearWith`; `clinicalMode` wired up so the cutpoint-optimism caveat
  reaches the user.
- `nogoldstandard` — the latent-class bootstrap note now states that replicates warm-start from the
  full-sample fit and that the interval is conditional on that solution and likely anti-conservative.

**Clinical safety**

- `enhancedROC` — class-imbalance detection is now unconditional. It was worse than the audit
  found: **two** independent default-off gates suppressed it (`showImbalanceWarning` *and*
  `detectImbalance`), so fixing only the one the audit named would have left the symptom intact.
  Events < 10 raised from STRONG_WARNING to ERROR.
- `decisioncombine` — the inverted-positive-level and below-chance guards now run regardless of
  `showRecommendation`, and above the `>= 10 / >= 10` ranking-eligibility filter that previously
  hid them in exactly the small series where inversion matters most.
- `kappaSizeFixedN` — a warning for a positive-but-inadequate lower bound, with remedy advice that
  branches on whether the remedy is achievable at all.

**Hygiene**

- Six unused `Imports` (`DescTools`, `irrCAC`, `lme4`, `lmerTest`, `psych`, `vcd`) dropped: tags
  removed from the sibling's hand-maintained `R/zzz_imports.R`, packages added to
  `meddecide > prune_imports` in the umbrella config. Both halves are required.
- The retracted "Notice serialization" premise corrected in `sequentialtests.b.R` and
  `kappaSizeCI.b.R`. `sequentialtests`' comment had actually *named* `insert(999, Notice)` — the
  real culprit — while blaming Notice for it.
- Four unlabelled text inputs across the three `kappaSize` UIs given accessible names, matching the
  convention the module's other 105 TextBoxes already follow.
- `clearWith` completed on `enhancedROC` (including `clinicalReport` and `detailedComparison`,
  which a first sweep missed by its own detection method).

## Three fixes that had to be fixed again

Worth recording, because each is a way a plausible fix goes wrong:

1. **A fix that reversed a platform convention.** Making `decisioncombine`'s dead validation notices
   reachable produced a red ERROR on every freshly-opened analysis — the very §25 defect this report
   flags elsewhere. Reverted to a silent return on the empty state, keeping the notice for *partial*
   selection, which was the genuine defect.
2. **A fix that introduced a false positive.** Moving the inversion guard earlier made it fire on a
   no-information sample where every rule sits at exactly chance and the positive levels are
   perfectly correct — two contradictory STRONG_WARNINGs side by side. The guard now tests both
   halves of what its own notice text claims.
3. **A fix with an off-by-boundary that reproduced the defect.** `kappaSizeFixedN` branched on
   `kappa0 < 0.40`, but the bound is searched *downward* from `kappa0`, so at `kappa0 == 0.40`
   exactly, no reachable design clears 0.40 and the unfollowable advice fired for every one. Now `<=`.

## Verification

- `jmvtools::prepare()` and `devtools::document()` run centrally, once, after all edits.
  `prepare()` returns 0 even on a YAML compile error, so the output was checked rather than trusted:
  the digest of all `.u.yaml` files is byte-identical before and after (no re-added controls, no
  duplicate injection), no hand-written schema was rewritten, and `jamovi/0000.yaml` still carries
  390 analyses as a list.
- `parse()` clean across 56 files (14 backends, their generated headers, helpers, touched tests).
- 1,172 YAML files well-formed.
- **meddecide test suite: 67 files, 3,393 passing, 0 errors, 1 failure** (below).

## Open — maintainer decisions

1. **Regenerate the submodule.** `Rscript _updateModules.R --dry-run` first. Until then the sibling
   is stale and its DESCRIPTION still lists the six pruned Imports.
2. **`test-sequentialtests-release-review.R` — "release metadata versions agree" fails.**
   Pre-existing and unchanged from HEAD: `sequentialtests.a.yaml` is `1.0.83` while `DESCRIPTION` is
   `1.0.81.01`. Across the umbrella, `.a.yaml` versions range from `0.0.1` to `1.0.83`. This is a
   release-metadata decision, and a version bump also obliges a `NEWS.md` entry, so it was left alone.
3. **`NEWS.md` still trails `DESCRIPTION`** (newest entry 1.0.6.03). Resolve together with (2).
4. **`decisiongraph` has 45 failing tests, 4 of them `attempt to apply non-function`** — the
   `Group$insert()` signature. It is `menuGroup: meddecideExtraD`, so unshipped, and untouched by
   this pass. It is promotion debt that will arrive the moment someone renames that menuGroup.
5. **The notice-architecture split** (validation via `jmvcore::reject()` vs advisory via the HTML
   panel) was done only where it was local. The full 6-analysis re-architecture in
   [cross-cutting §1](#1-safety-notices-that-cannot-reach-jamovis-error-state--6-analyses) remains.
6. **Turkish catalog** — untouched. `catalog.pot` should be regenerated first, since several `.()`
   strings had never been extracted.
