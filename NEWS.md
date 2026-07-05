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
