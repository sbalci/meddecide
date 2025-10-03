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
