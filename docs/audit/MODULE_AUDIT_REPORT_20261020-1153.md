# Module audit report — meddecide 1.1.0

Audited 2026-10-20. Profile: **standard**. Skill: audit-module v0.1.0.
Target: `/Users/serdarbalci/Documents/GitHub/meddecide`. Umbrella comparison: `/Users/serdarbalci/Documents/GitHub/ClinicoPathJamoviModule`.

**15 analyses: 8 READY for the reviewed technical surface, 7 NEEDS WORK, 0 placeholders, 0 missing, 0 orphaned implementations.** Security-catalog findings: HIGH 0, MEDIUM 0, LOW 4 (category G, one code-export defect in each affected analysis). Functional severity is recorded separately below.

**Release verdict: HOLD the current candidate.** The existing shipped source/archive still has stale calculator narratives after invalid input and four fatal-input paths that complete successfully. Additional current defects include broken R syntax export in four analyses and silent agreement coverage clamping. The static release gate alone does not detect these behaviors. READY here is a scoped technical assessment, not independent statistical validation or clinical/library certification.

## Executive dashboard

| Analysis | Technical status | High / medium security | Low G | Integration / notices | i18n review | Clinical readiness |
|---|---|---|---:|---|---|---|
| agreement | NEEDS WORK | 0 / 0 | 1 | F3–F6 | PARTIAL: F6 | NOT_READY |
| cotest | READY (scoped) | 0 / 0 | 0 | No blocking defect confirmed | Wrapped/catalogued surface; not linguistically certified | NEEDS_VALIDATION |
| decision | NEEDS WORK | 0 / 0 | 1 | F2, F3 | Wrapped/catalogued surface; not linguistically certified | NOT_READY |
| decisioncalculator | NEEDS WORK | 0 / 0 | 0 | F1, F2 | Wrapped/catalogued surface; not linguistically certified | NOT_READY |
| decisioncombine | NEEDS WORK | 0 / 0 | 0 | F2, F7 | Wrapped/catalogued surface; not linguistically certified | NOT_READY |
| decisioncompare | READY (scoped) | 0 / 0 | 0 | No blocking defect confirmed | Wrapped/catalogued surface; not linguistically certified | NEEDS_VALIDATION |
| decisioncurve | NEEDS WORK | 0 / 0 | 1 | F3, F7 | Wrapped/catalogued surface; not linguistically certified | NEEDS_VALIDATION |
| enhancedROC | NEEDS WORK | 0 / 0 | 0 | F2 | Wrapped/catalogued surface; not linguistically certified | NOT_READY |
| kappaSizeCI | READY (scoped) | 0 / 0 | 0 | No blocking defect confirmed | Wrapped/catalogued surface; not linguistically certified | NEEDS_VALIDATION |
| kappaSizeFixedN | READY (scoped) | 0 / 0 | 0 | No blocking defect confirmed | Wrapped/catalogued surface; not linguistically certified | NEEDS_VALIDATION |
| kappaSizePower | READY (scoped) | 0 / 0 | 0 | No blocking defect confirmed | Wrapped/catalogued surface; not linguistically certified | NEEDS_VALIDATION |
| lassologistic | NEEDS WORK | 0 / 0 | 1 | F3 | Wrapped/catalogued surface; not linguistically certified | NEEDS_VALIDATION |
| nogoldstandard | READY (scoped) | 0 / 0 | 0 | No blocking defect confirmed | Wrapped/catalogued surface; not linguistically certified | NEEDS_VALIDATION |
| psychopdaROC | READY (scoped) | 0 / 0 | 0 | No blocking defect confirmed | Wrapped/catalogued surface; not linguistically certified | NEEDS_VALIDATION |
| sequentialtests | READY (scoped) | 0 / 0 | 0 | No blocking defect confirmed | Wrapped/catalogued surface; not linguistically certified | NEEDS_VALIDATION |

## Scope, provenance and evidence grades

The actual sibling declares 15 analyses. Current umbrella routing declares 10 production analyses and stages the repaired `agreement`, `decision`, `decisioncalculator`, `decisioncombine` and `enhancedROC` in `meddecideT`. Those five are still present in this sibling. The current distribution plan reports 10 production analyses and would remove their old production backend paths if applied now. It reports zero plan errors but retains import-scanner warnings; that is not build evidence. No routing, copying, promotion or removal was performed.

After normalizing only package-qualified names, package literals and comments, substantive five-file surface differences are limited to those five backends and their `menuGroup` declarations. Broad replacement of the word ClinicoPath would falsely classify citation identifiers as drift. The staged diagnostic input helper is intentionally absent from the current sibling. The five analyses must not be silently promoted or excluded as an audit side effect.

Fresh provenance checks match **108/108** production backend/schema/JS hashes to the preceding release audit manifest. The existing `.jmo` SHA-256 remains `5d05b2e902b65489ccfc7f0eea57e405bde0e6f620445ad2ac22a17c60d1bfb3`. This allows the fresh archive probes below to be associated with the unchanged audited production surface. Existing compiled artifacts were loaded; no artifacts were regenerated. Prior remediation tests and build results are historical evidence for the staged candidate, not new evidence that these fixes ship here.

The sibling already had four modified files at audit start: `DESCRIPTION`, `NEWS.md`, `tests/testthat/test-decision.R`, `tests/testthat/test-roc.R`. The umbrella also contains prior remediation and unrelated survival work. Those changes were preserved. Source/test/metadata baseline hashes were checked again before report creation and after completion. The only repository file created by this audit is this report.

## Numbered findings

### F1 — HIGH functional: calculator narratives survive an invalid-input rerun

Affected: `decisioncalculator`. [R/decisioncalculator.b.R:264](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncalculator.b.R:264) clears the workload table and notices at entry, but not the two narrative panels. Negative counts add an ERROR and return at [R/decisioncalculator.b.R:315](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncalculator.b.R:315) before the later narrative setters ([R/decisioncalculator.b.R:1321](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncalculator.b.R:1321), [R/decisioncalculator.b.R:1414](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncalculator.b.R:1414)). Existing `clearWith` entries already name TP; that does not replace testing the runtime replay contract.

Fresh reproduction: calculate TP=40, FN=10, FP=6, TN=24 with summary and Fagan output; serialize results; initialize a new analysis with TP=-1; restore the prior protobuf with `oChanges="TP"`; run. A fresh invalid run is the control.

| Panel | Cached-invalid characters | Fresh-invalid characters |
|---|---:|---:|
| summary | 2365 | 0 |
| faganSummary | 831 | 0 |

The cached run reports `status=complete`, `complete=TRUE`, `errored=FALSE`. Old clinical statements remain beside an error, including sensitivity 80%, PPV about 87% and LR+ 4. This is a stale-result defect, not a newly computed estimate from negative counts. The separate staged repair addresses it; it is not present in the current sibling/archive. Require valid → invalid → valid protobuf regression before promotion.

### F2 — MEDIUM functional: fatal configuration errors do not enter jamovi error state

Affected: four analyses. Fresh native R6 probes of the existing archive find ERROR content followed by normal return:

| Analysis | Fatal test | Source path | Current archive state | Staged candidate state |
|---|---|---|---|---|
| decision | Configured positive level absent | [R/decision.b.R:624](/Users/serdarbalci/Documents/GitHub/meddecide/R/decision.b.R:624), [R/decision.b.R:1816](/Users/serdarbalci/Documents/GitHub/meddecide/R/decision.b.R:1816) | complete / TRUE / FALSE | error / FALSE / TRUE |
| decisioncalculator | TP=-1 | [R/decisioncalculator.b.R:315](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncalculator.b.R:315) | complete / TRUE / FALSE | error / FALSE / TRUE |
| decisioncombine | Configured reference positive level absent | [R/decisioncombine.b.R:795](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncombine.b.R:795), [R/decisioncombine.b.R:544](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncombine.b.R:544) | complete / TRUE / FALSE | error / FALSE / TRUE |
| enhancedROC | Configured positive class absent | [R/enhancedROC.b.R:1021](/Users/serdarbalci/Documents/GitHub/meddecide/R/enhancedROC.b.R:1021), [R/enhancedROC.b.R:535](/Users/serdarbalci/Documents/GitHub/meddecide/R/enhancedROC.b.R:535) | complete / TRUE / FALSE | error / FALSE / TRUE |

State columns mean status / complete / errored. A displayed error is insufficient to mark the analysis failed. Correct with `jmvcore::reject()` outside broad catch-all handlers, or narrow the handler around the fallible third-party step. The staged candidate demonstrates the intended state on these selected cases.

Input-state triage also needs the staged fixes: `enhancedROC` raises ERROR on untouched and partial selection ([R/enhancedROC.b.R:485](/Users/serdarbalci/Documents/GitHub/meddecide/R/enhancedROC.b.R:485)); `decisioncombine` raises ERROR when a test is selected before its reference ([R/decisioncombine.b.R:657](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncombine.b.R:657)). Use quiet empty instructions and INFO for incomplete selection. Configured invalid inputs should fail. A constant ROC predictor is a different case: the fresh probe computes its defined AUC=0.5 and flags the failed cut-point step, so normal completion alone is not evidence that this case must be fatal.

### F3 — LOW security catalog G / functional: R syntax export fails for ordinary column names

Affected: `agreement`, `decision`, `decisioncurve`, `lassologistic`. This is generated user-visible code, not a runtime evaluation sink. No generated code was executed.

| Analysis / handwritten integration point | Non-default option | Export fragment | `parse(text=asSource())` |
|---|---|---|---|
| [R/agreement.b.R:20](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:20) | vars with spaces | `vars = vars(test with space, second test)` | FAIL |
| [R/decision.b.R:19](/Users/serdarbalci/Documents/GitHub/meddecide/R/decision.b.R:19) | gold, newtest with spaces | `gold = gold with space` | FAIL |
| [R/decisioncurve.b.R:13](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncurve.b.R:13) | outcome with spaces | `outcome = gold with space` | FAIL |
| [R/lassologistic.b.R:12](/Users/serdarbalci/Documents/GitHub/meddecide/R/lassologistic.b.R:12) | outcome with spaces | `outcome = gold with space` | FAIL |

The inherited export route is not overridden safely in these four handwritten classes. Quoted/backslash-bearing positive labels are also copied without escaping in the affected scalar label options. The same five-case probe against the staged installed candidate produces the same four failures; `psychopdaROC` is the passing control.

Reachability example, from the real decision export:

```r
meddecide::decision(
    data = data,
    gold = gold with space,
    goldPositive = "Po"s\class",
    newtest = test with space)
```

This is **four LOW-G instances**, not four runtime code-execution vulnerabilities. It affects the reproducibility/export feature even if calculations work. Correct the handwritten source serialization route with framework source helpers or correctly serialized literals appropriate to the public wrapper; never edit generated `.h.R`. A working nearby reference is [R/psychopdaROC.b.R:6787](/Users/serdarbalci/Documents/GitHub/meddecide/R/psychopdaROC.b.R:6787); scalar free text is escaped at [R/cotest.b.R:24](/Users/serdarbalci/Documents/GitHub/meddecide/R/cotest.b.R:24). Add parse-only regressions for spaces, backticks, quotes, backslashes, multiple variables and default omission. Re-test on the declared minimum jamovi version and current runtime; the probe demonstrates the loaded runtime behavior, not universal framework behavior.

### F4 — MEDIUM functional: agreement silently changes the limits-of-agreement coverage

Affected: `agreement`; persists in the staged source. [jamovi/js/agreement.events.js:4](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/js/agreement.events.js:4) is wired to the numeric control at [jamovi/agreement.u.yaml:251](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/agreement.u.yaml:251). The backend schema explicitly calls this **coverage for limits of agreement**, not the confidence level for a CI ([jamovi/agreement.a.yaml:48](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/agreement.a.yaml:48)).

```javascript
let val = ui.baConfidenceLevel.value();
if (val < 0.50) {
    ui.baConfidenceLevel.setValue(0.50);
} else if (val > 0.99) {
    ui.baConfidenceLevel.setValue(0.99);
}
```

Fresh handler probes: `95 → 0.99`, `-1 → 0.50`, `0.20 → 0.50`, `0.95 → 0.95`, `1 → 0.99`. Thus a percent-style entry of 95 can silently request 99% coverage. This changes the limits themselves. Retain the entered value for visible validation rather than silently substituting a bound. Backend validation must remain authoritative for non-UI calls. The handler was exercised with a mocked control; actual desktop keystroke behavior was not tested. This is input-integrity/UX evidence, not an exploitable security finding.

### F5 — LOW statistical interpretation: fallback warning asserts an invalid universal direction

Affected: `agreement`; already repaired in staged source. Current fallback notes at [R/agreement.b.R:7699](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:7699), [R/agreement.b.R:7702](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:7702), [R/agreement.b.R:12094](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:12094), [R/agreement.b.R:15896](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:15896) and [R/agreement.b.R:15899](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:15899) claim the null-SE interval is too narrow when kappa is high and should be treated as optimistic.

Fresh counterexample: the 2×2 table `matrix(c(45,5,5,45),2)` has κ=0.8, non-null ASE=0.06 and null SE=0.10. Controlled `vcd::Kappa` failure triggers the real fallback, producing [0.6040036, 0.9959964] and that warning. Here the null-SE interval is wider. The arithmetic follows the stated fallback; the universal interpretation is wrong. The fault was deliberately injected to reach the fallback, not observed as a spontaneous vcd failure. State that coverage/direction are not guaranteed without asserting a universal relation.

### F6 — LOW i18n: agreement's educational guides bypass translation

Affected: `agreement`; persists staged. Examples: [R/agreement.b.R:685](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:685) `.createAboutPanel()`, [R/agreement.b.R:1123](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:1123) `.populateGwetExplanation()` and [R/agreement.b.R:1200](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:1200) `.populateClinicalUseCases()`. Long English HTML paragraphs are passed to `setContent()` as raw strings; their reachable optional panels stay English in other languages. The existing TODO at line 1130 acknowledges this debt. Its historical word/literal counts were not independently recounted here.

Separate markup from sentence/cell translation calls, then regenerate catalogues during a separately authorized repair. Agreement is PARTIAL, not wholly untranslated. Names of references and CSS fragments were excluded; `decisioncompare`'s namespaced `jmvcore::.()` calls are translated, despite simple grep false positives.

### F7 — LOW UX: individual labels use Title Case / action wording

Examples in five analyses (section headings and proper nouns excluded):

- [jamovi/decisioncombine.a.yaml:91](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncombine.a.yaml:91) — “Test 1 Positive Level”.
- [jamovi/decisioncompare.a.yaml:137](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncompare.a.yaml:137) — “Test 1 Positive Level”.
- [jamovi/decisioncurve.a.yaml:38](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncurve.a.yaml:38) — “Outcome Variable”.
- [jamovi/nogoldstandard.a.yaml:143](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/nogoldstandard.a.yaml:143) — “Analysis Method”.
- [jamovi/psychopdaROC.a.yaml:278](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/psychopdaROC.a.yaml:278) — “Classification Direction”.

Also [jamovi/decisioncompare.a.yaml:306](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncompare.a.yaml:306) “Exclude other observed levels” begins with an action. Apply sentence case to individual controls and noun labels for checkboxes; retain Title Case for CollapseBox headings. The release gate checks CollapseBox headings, so its zero count does not contradict these individual-control examples. This is cosmetic debt, not numerical failure. Of these five, only decisioncombine is currently staged in T.

### F8 — DISTRIBUTION ADVISORY: bundled transitive AGPL dependency needs a policy decision

The existing archive actually contains `pander` 0.6.6, License AGPL-3, through `epiR` 2.0.92 Imports; this is not inferred solely from a stale build directory. The local gate independently flags [build/R4.6.0-arm64-macos/pander/DESCRIPTION](/Users/serdarbalci/Documents/GitHub/meddecide/build/R4.6.0-arm64-macos/pander/DESCRIPTION). The module's own `GPL (>= 2)` declaration is not thereby proven incorrect.

The current [official jamovi distribution guide](https://dev.jamovi.org/tutorial/tuts0111-distributing-modules) excludes AGPL-3 for submitted module licensing and requires compliance with bundled dependencies. It does not settle this particular transitive bundle's acceptance. Confirm that policy with the jamovi maintainers before submission. Do not relabel the dependency's licence or remove epiR blindly. This remains an advisory requiring a distribution decision, not a legal incompatibility verdict.

### F9 — MAINTENANCE ADVISORY: long run bodies increase change risk

Fourteen of fifteen `.run()` source bodies exceed 120 lines; six exceed 500 lines. Counts include comments and blank lines and describe source span, not executed operations:

| Analysis | Run source span | Lines |
|---|---|---:|
| agreement | [R/agreement.b.R:15332](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:15332)–17038 | 1707 |
| decision | [R/decision.b.R:1754](/Users/serdarbalci/Documents/GitHub/meddecide/R/decision.b.R:1754)–2821 | 1068 |
| decisioncalculator | [R/decisioncalculator.b.R:264](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncalculator.b.R:264)–1497 | 1234 |
| decisioncurve | [R/decisioncurve.b.R:1282](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncurve.b.R:1282)–2118 | 837 |
| psychopdaROC | [R/psychopdaROC.b.R:2318](/Users/serdarbalci/Documents/GitHub/meddecide/R/psychopdaROC.b.R:2318)–4106 | 1789 |
| sequentialtests | [R/sequentialtests.b.R:58](/Users/serdarbalci/Documents/GitHub/meddecide/R/sequentialtests.b.R:58)–1098 | 1041 |

This alone is not a release blocker. Extract helpers feature by feature only with statistical and lifecycle parity evidence. The large agreement architecture is already documented locally; do not refactor it incidentally during a narrow bug repair.

## Module gates and review coverage

| Check family | Fresh result | Interpretation |
|---|---|---|
| Discovery / five-file presence | 15 analyses, all present; six JS event files | No missing/orphaned analysis or placeholder confirmed |
| Backend parse | 15/15 OK | Parsing is not execution |
| Static release gate | **0 blocking / 1 advisory** | F8 only; does not test F1–F7 behavior |
| Metadata | 1.1.0 consistent; release NEWS heading present | Earlier metadata issues are fixed here |
| Citation integrity | 141 defined / 141 used / 0 dangling / 0 empty author/year | Exact keys checked; not bibliographic truth verification |
| Options / result inventory | 607 options / 393 result nodes / 49 Images | Result count includes Groups and dataset Outputs |
| clearWith / renderFun | 0 dangling option names / 0 unresolved renderers | Not an exhaustive cache-correctness proof |
| Compiler / data requirements | tame on all 15 UIs; no gate violations | Static declarations pass |
| Image state / seeds / payloads | No gate violations | No fresh desktop save/reopen certification |
| Imports | 30 checked; 0 unused by gate | Dynamic guarded use included; no confirmed undeclared dependency |
| Translation gate | 6339 msgids; 0 out-of-module; 0 printf mismatch | Unextracted raw guides can still be missing: F6 |
| Results / rendering declarations | No File/Text/vector feature mismatch; no malformed column format | minApp 2.7.27 consistent with audited features |
| Examples / package metadata | Eight listed datasets, no file/contract issue | Not a fresh recalculation of all examples |
| Source integrity | Baseline hashes unchanged | Audit only; this report is the sole new repo file |

Security categories A–I were scanned over parsed non-generated R sources and all six JavaScript files, with candidate sinks followed into relevant helpers. No confirmed HIGH/MEDIUM runtime evaluation, string-built call, formula injection, HTML/JS injection, process/filesystem or deserialization exploit was found. Category G produced F3. Closed local lookup, RNG restoration, inherited `.asArgs()`, ordinary translated HTML and public helpers without internal consumers were not treated as exploits or dead files. This is a standard static review with targeted execution, not a proof that all attacks or branches are safe.

All six jmvcore migration groups were considered. **error**: F2; **source**: F3. Formula parsing already uses the shared safety helper / `asFormula` in the identified construction paths; no confirmed unsafe string formula sink was found. Existing `naOmit` and `toNumeric` paths were checked. Eleven `na.omit` calls were triaged: vector uses and a row-count-only predicate are not evidence of lost metadata in outputs. No behavior-preserving mandatory **formula**, **na**, **numeric** or **term** migration was confirmed. Blanket conversion of all `as.numeric` calls would change intentional category/statistic coding and is not recommended.

## Per-analysis review

Each section separates direct option reads from other valid consumers. A data argument, schema visibility condition, dynamic helper lookup or client-managed dataset Output is not a dead option. Output “resolved” below describes a static setter/render/schema route, not exhaustive execution of every optional output. Overall mathematical status is **NOT_EVALUATED for a fresh independent whole-analysis validation**; selected formulas/assumptions were inspected and F5 was independently challenged. Existing source assertions or previous green tests do not substitute for that validation.

### agreement

**Status:** NEEDS WORK. **Implementation:** FUNCTIONAL.
**Files:** [R/agreement.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/agreement.b.R:1) · [jamovi/agreement.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/agreement.a.yaml) · [jamovi/agreement.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/agreement.u.yaml) · [jamovi/agreement.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/agreement.r.yaml).
**Metrics:** 12084 backend nonblank/noncomment LOC; 161 declared options, 159 direct option names; 122 result nodes, 9 Images; `.run()` 1707 source lines.

**Security / migration:** LOW G: F3; source serialization migration required. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | `allPairsCI` is used by schema column visibility, not a direct backend read. `baConfidenceLevel` has F4. Data enters through `self$data`. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | `gradingHeading` is a heading-only Preformatted node with no body setter identified (r.yaml:153). No missing numerical result is inferred from that. Consensus and limits-of-agreement dataset Outputs are client managed. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Selected fallback warning is quantified but directionally wrong (F5); broader small-sample/method notices were source-reviewed. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 3/5 (subjective, scoped); maintainability LOW. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NOT_READY**. i18n: **PARTIAL — untranslated guides (F6)**.

**Strength:** Extensive method-specific outputs, explicit ordinal ordering and opt-in guidance; confidence-level labelling is centralized.

**Statistical/clinical limit:** Keep the case and reader sampling units explicit. Repeated observations need the applicable cluster-aware path; Wald/Fisher-z finite-sample coverage caveats do not establish universal coverage guarantees.

**Issues / next verification:** F3, F4, F5, F6, F9. Suggested follow-up: `/fix-function agreement error-handling --apply; /prepare-translation agreement`. These are pointers, not commands executed by this audit.

### cotest

**Status:** READY for reviewed technical surface. **Implementation:** FUNCTIONAL.
**Files:** [R/cotest.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/cotest.b.R:1) · [jamovi/cotest.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/cotest.a.yaml) · [jamovi/cotest.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/cotest.u.yaml) · [jamovi/cotest.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/cotest.r.yaml).
**Metrics:** 975 backend nonblank/noncomment LOC; 14 declared options, 13 direct option names; 8 result nodes, 1 Images; `.run()` 295 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | `showGuidance` gates welcome/explanation in the results schema. Data is intentionally not required. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Eight result nodes have resolved static routes; no unpopulated numerical node confirmed. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Feasible-dependence and parameter notices are present in the reviewed source; native cases were not freshly rerun. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 4/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NEEDS_VALIDATION**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Conditional dependence is bounded rather than silently treated as independent; text option export has an explicit escape override.

**Statistical/clinical limit:** Teaching presets are illustrative. Their sensitivity, specificity and prevalence do not validate use in a different clinical population.

**Issues / next verification:** No blocking issue confirmed. Suggested follow-up: `/check-function-full cotest`. These are pointers, not commands executed by this audit.

### decision

**Status:** NEEDS WORK. **Implementation:** FUNCTIONAL.
**Files:** [R/decision.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/decision.b.R:1) · [jamovi/decision.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decision.a.yaml) · [jamovi/decision.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decision.u.yaml) · [jamovi/decision.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decision.r.yaml).
**Metrics:** 2022 backend nonblank/noncomment LOC; 29 declared options, 20 direct option names; 28 result nodes, 1 Images; `.run()` 1068 source lines.

**Security / migration:** LOW G: F3; source serialization migration required. Error-state migration required: F2.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | Reference-definition and validation-provenance fields are consumed by whole-options helpers. Missing direct reads are not dead options. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | `referenceDefinition` is helper populated. Disease/comparator outputs are cleared through shared paths; F2 remains live. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Fresh empty/partial inputs are quiet, pending level selection INFO, configured absent level ERROR with successful completion (F2). |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 3/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NOT_READY**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Explicit positive/negative coding and separate comparator agreement versus disease accuracy avoid silently treating any comparator as disease truth.

**Statistical/clinical limit:** Paired classifications belong to the same cases; do not silently treat multiple visits/lesions as independent patients. External-prevalence predictive values require separate uncertainty treatment.

**Issues / next verification:** F2, F3, F9. Suggested follow-up: `/fix-function decision error-handling --apply; /jamovify-function decision --apply`. These are pointers, not commands executed by this audit.

### decisioncalculator

**Status:** NEEDS WORK. **Implementation:** FUNCTIONAL.
**Files:** [R/decisioncalculator.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncalculator.b.R:1) · [jamovi/decisioncalculator.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncalculator.a.yaml) · [jamovi/decisioncalculator.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncalculator.u.yaml) · [jamovi/decisioncalculator.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncalculator.r.yaml).
**Metrics:** 1314 backend nonblank/noncomment LOC; 28 declared options, 27 direct option names; 16 result nodes, 1 Images; `.run()` 1234 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. Error-state migration required: F2.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | Aggregate TP/FP/TN/FN inputs intentionally require no dataset. Text and cutoff names flow through escaping/formatting routes. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | All 16 result nodes have static routes, but summary and faganSummary violate valid-to-invalid freshness (F1). |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Fresh zero/pending input is quiet; negative TP displays ERROR but does not fail the analysis (F2). |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 3/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NOT_READY**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Count products use double arithmetic to avoid integer overflow; external-prevalence settings distinguish unavailable predictive-value intervals.

**Statistical/clinical limit:** Aggregate counts carry no patient identity or clustering information. Prevalence-adjusted PPV/NPV are conditional on the supplied prevalence and its provenance.

**Issues / next verification:** F1, F2, F9. Suggested follow-up: `/fix-function decisioncalculator error-handling --apply`. These are pointers, not commands executed by this audit.

### decisioncombine

**Status:** NEEDS WORK. **Implementation:** FUNCTIONAL.
**Files:** [R/decisioncombine.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncombine.b.R:1) · [jamovi/decisioncombine.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncombine.a.yaml) · [jamovi/decisioncombine.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncombine.u.yaml) · [jamovi/decisioncombine.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncombine.r.yaml).
**Metrics:** 2596 backend nonblank/noncomment LOC; 25 declared options, 22 direct option names; 25 result nodes, 4 Images; `.run()` 97 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. Error-state migration required: F2.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | `showCITables` is a schema gate; `addedPattern` is a client-managed Output, not a missing numerical option read. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Nested tables inherit parent result-group invalidation. Missing local clearWith on six child tables is not itself a defect. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Fresh partial reference selection is ERROR rather than INFO; configured absent positive level also completes normally (F2). |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 3/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NOT_READY**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Uses observed joint test patterns rather than assuming independent tests when evaluating empirical combination rules.

**Statistical/clinical limit:** Selecting the best rule on the same cases is exploratory and can overstate performance. Rule rankings are not causal treatment benefit.

**Issues / next verification:** F2, F7. Suggested follow-up: `/fix-function decisioncombine error-handling --apply`. These are pointers, not commands executed by this audit.

### decisioncompare

**Status:** READY for reviewed technical surface. **Implementation:** FUNCTIONAL.
**Files:** [R/decisioncompare.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncompare.b.R:1) · [jamovi/decisioncompare.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncompare.a.yaml) · [jamovi/decisioncompare.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncompare.u.yaml) · [jamovi/decisioncompare.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncompare.r.yaml).
**Metrics:** 3124 backend nonblank/noncomment LOC; 42 declared options, 28 direct option names; 34 result nodes, 6 Images; `.run()` 184 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | Negative-level settings are read dynamically; report visibility is schema driven. `useOpaCriterion` and provenance enter helper contexts. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | cTable1 and epirTable1/2/3 are dynamically populated; referenceDefinition is helper populated. No dead numerical output confirmed. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Notices and quantification were source-reviewed; no fresh paired-comparison numerical run was performed. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 4/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NEEDS_VALIDATION**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Paired-comparison and multiplicity paths, explicit level coding and bounded original-data display have identifiable integration routes.

**Statistical/clinical limit:** A non-gold comparator estimates agreement (PPA/NPA), not automatically sensitivity/specificity for disease. Pairwise estimates require aligned cases.

**Issues / next verification:** F7; no blocking issue confirmed. Suggested follow-up: `/check-function-full decisioncompare`. These are pointers, not commands executed by this audit.

### decisioncurve

**Status:** NEEDS WORK. **Implementation:** FUNCTIONAL.
**Files:** [R/decisioncurve.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncurve.b.R:1) · [jamovi/decisioncurve.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncurve.a.yaml) · [jamovi/decisioncurve.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncurve.u.yaml) · [jamovi/decisioncurve.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncurve.r.yaml).
**Metrics:** 2249 backend nonblank/noncomment LOC; 44 declared options, 40 direct option names; 18 result nodes, 5 Images; `.run()` 837 source lines.

**Security / migration:** LOW G: F3; source serialization migration required. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | Three plot switches are consumed through maps/schema gates; these are not unused controls. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Five image renderers have state routes; no unresolved renderFun or confirmed numerical output gap. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Risk/threshold and model-fit safeguards are present in source; no fresh full decision-curve differential run. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 3/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NEEDS_VALIDATION**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Net-benefit source follows TP/N − FP/N × t/(1−t); renderers use serialized state rather than relying on a prior .run in the renderer process.

**Statistical/clinical limit:** Calibrated risks, clinically meaningful thresholds and correct study prevalence remain essential. Apparent benefit on training data is not external validation.

**Issues / next verification:** F3, F7, F9. Suggested follow-up: `/jamovify-function decisioncurve --apply; /check-function-full decisioncurve`. These are pointers, not commands executed by this audit.

### enhancedROC

**Status:** NEEDS WORK. **Implementation:** FUNCTIONAL.
**Files:** [R/enhancedROC.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/enhancedROC.b.R:1) · [jamovi/enhancedROC.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/enhancedROC.a.yaml) · [jamovi/enhancedROC.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/enhancedROC.u.yaml) · [jamovi/enhancedROC.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/enhancedROC.r.yaml).
**Metrics:** 5040 backend nonblank/noncomment LOC; 90 declared options, 78 direct option names; 44 result nodes, 12 Images; `.run()` 460 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. Error-state migration required: F2.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | `nntCalculation` controls columns; `decisionImpactTable` is a visibility gate. Frozen-validation fields and draws pass through whole-options helpers. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Twelve image declarations resolve renderers; no dangling output reference confirmed. Fatal null-preparation return is F2. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Fresh positive-class pending selection INFO; untouched/partial selection ERROR; invalid configured class completes normally. Constant predictor produces AUC 0.5 with an unavailable cut-point warning/error. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 3/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NOT_READY**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Explicit class selection, validation provenance and patient/cluster bootstrap controls are present; tied cutoffs and small-sample AUC limitations are disclosed.

**Statistical/clinical limit:** Ordinary row ROC inference must not be labelled patient inference when there are repeated patient records. Frozen-validation and clustered resampling paths have different prerequisites.

**Issues / next verification:** F2. Suggested follow-up: `/fix-function enhancedROC error-handling --apply; /check-function-full enhancedROC`. These are pointers, not commands executed by this audit.

### kappaSizeCI

**Status:** READY for reviewed technical surface. **Implementation:** FUNCTIONAL.
**Files:** [R/kappaSizeCI.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/kappaSizeCI.b.R:1) · [jamovi/kappaSizeCI.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/kappaSizeCI.a.yaml) · [jamovi/kappaSizeCI.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/kappaSizeCI.u.yaml) · [jamovi/kappaSizeCI.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/kappaSizeCI.r.yaml).
**Metrics:** 657 backend nonblank/noncomment LOC; 10 declared options, 10 direct option names; 4 result nodes, 0 Images; `.run()` 134 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | All 10 declared arguments have direct backend references; scalar planning inputs require no data. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Four result nodes resolve; no Image declared, no missing plot renderer. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Planning feasibility, category proportions and method explanations are source-reviewed; no fresh planning oracle run. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 4/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NEEDS_VALIDATION**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Planning settings and category-proportion validation have explicit routes; the JS does not silently clamp invalid proportions.

**Statistical/clinical limit:** The expected model-based goodness-of-fit interval criterion is not a guarantee of observed Wald, Fisher-z or bootstrap precision. Rare categories require separate dependability assessment.

**Issues / next verification:** No blocking issue confirmed. Suggested follow-up: `/check-function-full kappaSizeCI`. These are pointers, not commands executed by this audit.

### kappaSizeFixedN

**Status:** READY for reviewed technical surface. **Implementation:** FUNCTIONAL.
**Files:** [R/kappaSizeFixedN.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/kappaSizeFixedN.b.R:1) · [jamovi/kappaSizeFixedN.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/kappaSizeFixedN.a.yaml) · [jamovi/kappaSizeFixedN.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/kappaSizeFixedN.u.yaml) · [jamovi/kappaSizeFixedN.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/kappaSizeFixedN.r.yaml).
**Metrics:** 480 backend nonblank/noncomment LOC; 8 declared options, 8 direct option names; 5 result nodes, 0 Images; `.run()` 179 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | All eight declared arguments have direct references; no dataset is required for fixed-N planning. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Five result nodes resolve; no unpopulated numerical node confirmed. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Fixed-N feasibility and sparse-category guidance are present in source; no fresh independent precision oracle. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 4/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NEEDS_VALIDATION**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Fixed-N mode keeps the sample-size constraint explicit and validates category inputs.

**Statistical/clinical limit:** Predicted interval behavior is model based; sparse-category cautions are not proof that clinically acceptable agreement cannot be demonstrated.

**Issues / next verification:** No blocking issue confirmed. Suggested follow-up: `/check-function-full kappaSizeFixedN`. These are pointers, not commands executed by this audit.

### kappaSizePower

**Status:** READY for reviewed technical surface. **Implementation:** FUNCTIONAL.
**Files:** [R/kappaSizePower.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/kappaSizePower.b.R:1) · [jamovi/kappaSizePower.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/kappaSizePower.a.yaml) · [jamovi/kappaSizePower.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/kappaSizePower.u.yaml) · [jamovi/kappaSizePower.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/kappaSizePower.r.yaml).
**Metrics:** 431 backend nonblank/noncomment LOC; 7 declared options, 7 direct option names; 4 result nodes, 0 Images; `.run()` 283 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | All seven declared arguments have direct references; planning uses scalar/proportion settings. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Four result nodes resolve; no missing Image or renderer. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Power/design validation and method explanations are present; no fresh power simulation. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 4/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NEEDS_VALIDATION**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Separates planning power inputs from observed study inference and validates category proportions.

**Statistical/clinical limit:** Check the assumed null/alternative kappa, category distribution, reader design and attainable model before applying an estimated sample size.

**Issues / next verification:** No blocking issue confirmed. Suggested follow-up: `/check-function-full kappaSizePower`. These are pointers, not commands executed by this audit.

### lassologistic

**Status:** NEEDS WORK. **Implementation:** FUNCTIONAL.
**Files:** [R/lassologistic.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/lassologistic.b.R:1) · [jamovi/lassologistic.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/lassologistic.a.yaml) · [jamovi/lassologistic.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/lassologistic.u.yaml) · [jamovi/lassologistic.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/lassologistic.r.yaml).
**Metrics:** 2107 backend nonblank/noncomment LOC; 30 declared options, 26 direct option names; 21 result nodes, 3 Images; `.run()` 257 source lines.

**Security / migration:** LOW G: F3; source serialization migration required. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | `scoreCutMethod` and `scoreCutPoints` use .opt/dynamic lookups; predictions is a dataset Output. These are not dead options. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Three images and prediction export have identifiable routes; no unresolved renderers. Syntax export is F3. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Severity is textual as well as colored, and sorted. Fit/validation notices are source-reviewed; no fresh model fit. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 3/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NEEDS_VALIDATION**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Model, validation and simplified-score paths are separated; dataset prediction Output has a distinct client contract.

**Statistical/clinical limit:** Check preprocessing within resampling folds, score mapping and the distinction between apparent/internal validation and frozen external performance. These were not independently validated this audit.

**Issues / next verification:** F3. Suggested follow-up: `/jamovify-function lassologistic --apply; /check-function-full lassologistic`. These are pointers, not commands executed by this audit.

### nogoldstandard

**Status:** READY for reviewed technical surface. **Implementation:** FUNCTIONAL.
**Files:** [R/nogoldstandard.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/nogoldstandard.b.R:1) · [jamovi/nogoldstandard.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/nogoldstandard.a.yaml) · [jamovi/nogoldstandard.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/nogoldstandard.u.yaml) · [jamovi/nogoldstandard.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/nogoldstandard.r.yaml).
**Metrics:** 1788 backend nonblank/noncomment LOC; 20 declared options, 9 direct option names; 12 result nodes, 1 Images; `.run()` 320 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | Test1–5 variable/positive-level options are constructed by slot name; nine direct references do not imply 11 dead arguments. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Twelve result nodes and the renderer resolve. No missing numerical result confirmed. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Identifiability/convergence and model-assumption warnings have source routes; no fresh latent-model fit. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 4/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NEEDS_VALIDATION**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Uses validated formula construction at b.R:1243; conditional model paths have explicit configuration.

**Statistical/clinical limit:** Latent disease classes require identifiability and dependence assumptions. Composite agreement is not independently verified disease truth.

**Issues / next verification:** F7; no blocking issue confirmed. Suggested follow-up: `/check-function-full nogoldstandard`. These are pointers, not commands executed by this audit.

### psychopdaROC

**Status:** READY for reviewed technical surface. **Implementation:** FUNCTIONAL.
**Files:** [R/psychopdaROC.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/psychopdaROC.b.R:1) · [jamovi/psychopdaROC.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/psychopdaROC.a.yaml) · [jamovi/psychopdaROC.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/psychopdaROC.u.yaml) · [jamovi/psychopdaROC.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/psychopdaROC.r.yaml).
**Metrics:** 4595 backend nonblank/noncomment LOC; 83 declared options, 78 direct option names; 38 result nodes, 1 Images; `.run()` 1789 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | manualRun is a gate. Five hidden compatibility options (correlationROCs, metaAnalysisMethod, heterogeneityTest, forestPlot, overrideMetaAnalysisWarning) remain intentionally accepted, not active user controls. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Thirty-eight result nodes resolve; native output coverage was not exhaustively executed. Custom asSource passes the new name/quote probe. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Class, analysis-unit and validation gates are source-reviewed; no fresh complete AUC/IDI/NRI calculation. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 4/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NEEDS_VALIDATION**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Custom literal serialization, explicit class coding and patient/analysis-unit settings have identifiable implementations.

**Statistical/clinical limit:** Match analysis units and settings before comparing AUCs. IDI/NRI require probabilities with meaningful calibration, and clustered records require the chosen patient-level inference contract.

**Issues / next verification:** F7, F9. Suggested follow-up: `/check-function-full psychopdaROC`. These are pointers, not commands executed by this audit.

### sequentialtests

**Status:** READY for reviewed technical surface. **Implementation:** FUNCTIONAL.
**Files:** [R/sequentialtests.b.R:1](/Users/serdarbalci/Documents/GitHub/meddecide/R/sequentialtests.b.R:1) · [jamovi/sequentialtests.a.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/sequentialtests.a.yaml) · [jamovi/sequentialtests.u.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/sequentialtests.u.yaml) · [jamovi/sequentialtests.r.yaml](/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/sequentialtests.r.yaml).
**Metrics:** 1438 backend nonblank/noncomment LOC; 16 declared options, 16 direct option names; 14 result nodes, 5 Images; `.run()` 1041 source lines.

**Security / migration:** No confirmed A–I finding on reviewed paths. No additional mandatory helper migration confirmed.

| Argument behavior matrix | Assessment |
|---|---|
| Direct and indirect consumers | All 16 arguments have direct references; illustrative population and costs are scalar settings. |
| Confirmed dead public options | None established; direct-read counts are not a dead-option count |

| Output population matrix | Assessment |
|---|---|
| Declared result routes | Fourteen nodes / five images resolve. No phantom private method confirmed. |
| Exhaustive optional-output execution | Not performed; see module evidence limits |

| Notices coverage | Assessment |
|---|---|
| Empty / partial / invalid inputs | Strategy assumptions and parameter validation are source-reviewed; no fresh exhaustive strategy calculation. |
| Small samples / assumptions / methodology | Source routes considered; quantification was not exhaustively exercised for every branch |

**Code review:** reviewer quality assessment 4/5 (subjective, scoped); maintainability MEDIUM. Math/statistical validation: **NOT_EVALUATED as a fresh independent whole-analysis review**. Clinical readiness: **NEEDS_VALIDATION**. i18n: **wrapped/catalogued reviewed surface; full completeness not certified**.

**Strength:** Strategy-specific flow, cost and test-volume outputs are identifiable; text names use safe literal matching/escaping paths.

**Statistical/clinical limit:** Combined sensitivity/specificity formulas depend on the stated conditional-independence assumptions. A teaching preset is not evidence of clinical calibration.

**Issues / next verification:** F9; no blocking issue confirmed. Suggested follow-up: `/check-function-full sequentialtests`. These are pointers, not commands executed by this audit.

## Cross-cutting priorities and staged status

| Theme | Shipped analyses affected | Current staged evidence / limit |
|---|---:|---|
| Stale invalid narrative, F1 | 1 | Repair exists in T; current archive still reproduces |
| Fatal error state, F2 | 4 | Selected staged invalid cases now fail correctly |
| R syntax export, F3 | 4 | Same four failures in existing staged installation |
| Agreement coverage clamp, F4 | 1 | Persists in staged source; JS handler probe only |
| Fallback interpretation, F5 | 1 | Staged wording repair exists; no production promotion |
| Untranslated guides, F6 | 1 | Persists staged; raw strings are absent from extraction |
| Individual-control labels, F7 | 5 | One T analysis, four production umbrella analyses |
| Dependency distribution policy, F8 | Module | Bundled dependency verified; policy question unresolved |
| Long .run source span, F9 | 14 >120; 6 >500 | Maintenance advisory; not an automatic blocker |

The same analysis appears in several rows; do not sum them as independent analyses. Seven distinct analyses need technical work. No HIGH or MEDIUM security finding requires a security approval gate in this report. The four LOW category-G instances share one export theme.

Repair the confirmed source defects in the umbrella/T workflow and retain rollback evidence. Then validate selected regressions against freshly generated candidates, explicitly decide routing/promotion, and repeat the release checks against the exact final distribution. Do not run the updater now and assume its ten-analysis plan preserves all fifteen shipped analyses. No statistical defaults, clinical cutoffs or interpretation bands should change incidentally.

Suggested ordered follow-up (not executed):

1. Retain and validate the staged F1/F2/F5 repairs. In each affected analysis, test empty → partial → valid → invalid → valid with result state and status assertions, not notice text alone.
2. `/fix-function agreement error-handling --apply` for F4, and source serialization repair for the four F3 analyses. Parse exported R without evaluating it; use meaningful names/labels from the failure cases.
3. `/prepare-translation agreement` for F6; scoped label fixes for F7.
4. Resolve F8 with the jamovi maintainers using the actual dependency bundle. This audit has not contacted anyone.
5. Perform independent domain-specific numerical checks and desktop `.omv` save/close/reopen against the final promoted archive before claiming clinical/library release readiness.

## Reproducible evidence and limits

Read-only commands executed included:

```sh
bash .agents/skills/audit-module/scripts/discover-functions.sh ../meddecide
bash .agents/skills/audit-module/scripts/parse-check.sh ../meddecide
python3 tools/release_gate.py --root ../meddecide
```

Temporary audit scripts and CSV/log evidence are under `/private/tmp/meddecide-audit-20261020-r313_uvu` (ephemeral; no persistent source dependency). Key artifacts: `inventory.json`, `substantive-drift.json`, `metadata.json`, `parse.tsv`, `gate.log`, `calls.csv`, `definitions.csv`, `methods.csv`, `baseline-hashes.json`, `probe-production.csv`, `probe-staged.csv`, `calculator-replay.csv`, `fallback.csv`, `codegen.csv`, `codegen-staged.csv` and `routing-plan.log`.

Fresh execution consisted of 19 lifecycle cases on the existing archive plus the same 19 on the existing staged installation; a calculator valid-to-invalid protobuf replay with a fresh-invalid control; controlled fallback fault injection; direct JS coverage-handler tests; five parse-only syntax-export probes on each installation. These are selected tests, not all-option numerical validation. The initial empty-input harness used a nonempty data frame with no selected columns and failed during initialization; using an empty data frame corrected the fixture. That harness failure is not classified as a product defect.

A compact syntax-export reproducer, using the existing installed namespace (no build, no evaluation):

```r
ns <- asNamespace("meddecide")
pos <- paste0("Po", intToUtf8(34), "s", intToUtf8(92), "class")
d <- data.frame(y = factor(rep(c("Neg", pos), each = 40)),
                a = factor(rep(c("Neg", pos), 40)))
names(d) <- c("gold with space", "test with space")
o <- ns$decisionOptions$new(gold = names(d)[1], newtest = names(d)[2],
                             goldPositive = pos, testPositive = pos,
                             goldNegative = "Neg", testNegative = "Neg")
a <- ns$decisionClass$new(data = d, options = o)
a$init()
code <- a$asSource()
cat(code)
parse(text = code) # fails; do not eval(code)
```

For the stale-output reproduction, `calculator-replay.R` uses `results$asProtoBuf()` / `fromProtoBuf(..., oChanges="TP", vChanges=character())`, then `run(noThrow=TRUE)`. Local RProtoBuf wrapper bindings were adapted within that scratch R process to use installed exports; no package file was edited. F1's panel lengths and F2's status triples are embedded above so the finding does not depend solely on temporary files.

The standard profile covered discovery, security catalog A–I, six migration groups, integration/option/output crosswalks, notices and eight code-review areas. Parsed source enumeration and targeted manual inspection were used; this is not a claim that every branch of the approximately 50k-line backend surface received independent manual statistical validation. All-file static scans and inventory are broader evidence than the selected runtime cases, and weaker evidence for clinical correctness.

Not performed this audit: fresh package compilation, `jmvtools::prepare()`, documentation generation, full testthat rerun, R CMD check, all-example recalculation, per-analysis external documentation comparison, exhaustive R6/package review, deep guide cross-reference, independent full-analysis numerical or simulation validation, or desktop cold `.omv` reopen. These operations are outside this read-only standard audit or require a separate validation pass. Historical tests/builds are not reported as newly run. No source edits or requested fixes were applied because `/audit-module` explicitly requires report-only work.

## Guides and instructions actually consulted

- Repository `CLAUDE.md`, sibling `CLAUDE.md` and `docs/CLAUDE.md`: source ownership, generated-file policy, notices, release evidence and documentation rules.
- `jamovi-playbooks/SKILL.md` and `audit-module/SKILL.md`: scope, standard profile and report-only procedure.
- Audit references: `security-patterns.md`, `jmvcore-migration.md`, `integration-checks.md`, `notices-checklist.md`, `code-review-checks.md`, `jamovi-guides-index.md`; report templates.
- Canonical `vignettes/jamovi_library_review_guide.md`, §25: release-gate coverage and limits.
- Bundled `guides/jamovi_r_yaml_guide.md`, clearWith section: invalidation contract and inherited/default behavior.
- Bundled `guides/jamovi_formula_guide.md`, introductory safety guidance: formula helper routing and nonliteral inputs.
- Official jamovi distribution guide linked in F8: present licence policy; not case-specific legal approval.

Where old bundled advice conflicts with the primary skill/current repository guidance, this audit uses quiet untouched inputs, INFO for partial selection, rejection for a configured invalid analysis, warnings for failed optional steps, no universal clinical cutoff-as-error rule, and safe notice addition rather than sentinel result insertion.

*Read-only standard audit. Source/test/metadata integrity verified; only this report was added.*
