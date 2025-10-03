# meddecide

**Medical Decision Analysis and Reliability Assessment Tools for Clinical Research**

## Abstract

`meddecide` is a comprehensive R package and jamovi module that bridges the gap between complex statistical methodology and practical clinical research. It provides an intuitive toolkit for medical professionals and researchers to perform diagnostic test evaluations, reliability assessments, and evidence-based decision analyses without requiring extensive programming knowledge. By offering both a traditional R interface and a user-friendly jamovi GUI, the package democratizes access to advanced statistical methods essential for modern medical research and clinical decision-making.

## Overview

The `meddecide` package serves as the computational engine for the ClinicoPath jamovi Module, offering dual functionality:
- **As an R Package**: Direct access to all functions through R scripts and console
- **As a jamovi Module**: Point-and-click interface for statistical analyses without coding

See full documentation at https://sbalci.github.io/ClinicoPathJamoviModule/

[![CRAN Status](https://www.r-pkg.org/badges/version/meddecide)](https://cran.r-project.org/package=meddecide)
[![R-CMD-check](https://github.com/sbalci/meddecide/workflows/R-CMD-check/badge.svg)](https://github.com/sbalci/meddecide/actions)
[![License: GPL (>= 2)](https://img.shields.io/badge/License-GPL%20(%3E=%202)-blue.svg)](https://www.gnu.org/licenses/gpl-2.0)
[![jamovi Module](https://img.shields.io/badge/jamovi-module-brightgreen.svg?logo=jamovi)](https://www.jamovi.org/)
[![jamovi Version](https://img.shields.io/badge/jamovi-%E2%89%A5%201.8.1-orange.svg)](https://www.jamovi.org/)
[![R Version](https://img.shields.io/badge/R-%E2%89%A5%204.1.0-blue.svg)](https://www.r-project.org/)

[![GitHub Release](https://img.shields.io/github/v/release/sbalci/meddecide)](https://github.com/sbalci/meddecide/releases)
[![GitHub Issues](https://img.shields.io/github/issues/sbalci/ClinicoPathJamoviModule)](https://github.com/sbalci/ClinicoPathJamoviModule/issues)
[![GitHub Stars](https://img.shields.io/github/stars/sbalci/meddecide?style=social)](https://github.com/sbalci/meddecide)

[![Medical Decision Analysis](https://img.shields.io/badge/Focus-Medical%20Decision%20Analysis-red.svg)](https://github.com/sbalci/meddecide)
[![Reliability Assessment](https://img.shields.io/badge/Focus-Reliability%20Assessment-green.svg)](https://github.com/sbalci/meddecide)
[![ROC Analysis](https://img.shields.io/badge/Feature-ROC%20Analysis-purple.svg)](https://github.com/sbalci/meddecide)
[![Kappa Statistics](https://img.shields.io/badge/Feature-Kappa%20Statistics-orange.svg)](https://github.com/sbalci/meddecide)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3997188.svg)](https://doi.org/10.5281/zenodo.3997188)
[![Documentation](https://img.shields.io/badge/docs-pkgdown-blue.svg)](https://sbalci.github.io/ClinicoPathJamoviModule/)
[![Clinical Research](https://img.shields.io/badge/Domain-Clinical%20Research-darkblue.svg)](https://github.com/sbalci/meddecide)

## Key Features

### 🏥 Medical Decision Analysis
- **Diagnostic Test Evaluation**: Calculate sensitivity, specificity, predictive values, and likelihood ratios
- **Test Comparison**: Compare multiple diagnostic tests against a gold standard with statistical significance testing
- **Test Combination**: Systematically evaluate all possible patterns from 2-3 diagnostic tests to identify optimal strategies
- **Decision Calculator**: Interactive tool for exploring how test characteristics affect clinical decisions
- **Co-Testing Analysis**: Analyze combined results of concurrent diagnostic tests (parallel strategies)
- **Sequential Testing**: Evaluate serial testing strategies (confirmation and exclusion approaches)
- **Bayesian Updates**: Fagan nomograms for visualizing post-test probability calculations

### 📊 ROC Analysis
- **ROC Curve Generation**: Create and visualize receiver operating characteristic curves
- **AUC Calculation**: Compute area under the curve with confidence intervals
- **Optimal Cutpoint Detection**: Determine best thresholds using various optimization methods
- **Multiple Comparison**: Compare ROC curves from different diagnostic tests

### 🤝 Reliability Assessment
- **Cohen's Kappa**: Calculate inter-rater agreement for two raters
- **Fleiss' Kappa**: Assess agreement among multiple raters
- **Weighted Kappa**: Account for ordinal data with custom weighting schemes
- **Agreement Visualization**: Generate plots to visualize rater concordance patterns

### 📐 Sample Size Calculations
- **Power-Based**: Determine sample size for desired statistical power
- **Precision-Based**: Calculate sample size for confidence interval width
- **Fixed N Analysis**: Evaluate achievable power with predetermined sample size
- **Multiple Scenarios**: Compare sample size requirements across different study designs

### 🔬 Advanced Analysis
- **No Gold Standard**: Analyze diagnostic tests when reference standard is imperfect
- **Latent Class Analysis**: Estimate test performance without gold standard
- **Bootstrap Methods**: Generate robust confidence intervals
- **Missing Data Handling**: Appropriate methods for incomplete datasets

### 📈 Visualization Tools
- **Fagan Nomograms**: Interactive Bayesian probability calculators for sequential testing
- **Forest Plots**: Compare diagnostic metrics across studies with confidence intervals
- **Agreement Plots**: Visualize inter-rater reliability patterns
- **ROC Space**: Multi-test comparison in ROC coordinate system
- **Radar Plots**: Comprehensive multi-metric test comparison visualization
- **Heatmaps**: Color-coded performance matrices for test combinations
- **Decision Trees**: Hierarchical visualization of test combination strategies
- **Comparison Bar Charts**: Side-by-side performance metric comparisons

## Installation

### As an R Package
```r
# Install from GitHub
devtools::install_github("sbalci/meddecide")

# Load the package
library(meddecide)
```

### As a jamovi Module
1. Open jamovi (≥ 1.8.1)
2. Click the modules menu (⋮) in the top right
3. Select "jamovi library"
4. Search for "ClinicoPath"
5. Click Install

## Quick Start Examples

### Basic Diagnostic Test Evaluation
```r
library(meddecide)

# Single test evaluation
result <- decision(
  data = histopathology,
  gold = "Golden Standart",
  goldPositive = "1",
  newtest = "New Test",
  testPositive = "1"
)
```

### Compare Multiple Tests
```r
# Compare two diagnostic tests
comparison <- decisioncompare(
  data = histopathology,
  gold = "Golden Standart",
  goldPositive = "1",
  test1 = "New Test",
  test1Positive = "1",
  test2 = "Rater 1",
  test2Positive = "1",
  ci = TRUE,
  plot = TRUE,
  statComp = TRUE
)
```

### Evaluate Test Combinations
```r
# Analyze all possible patterns from 2 tests
combinations <- decisioncombine(
  data = histopathology,
  gold = "Golden Standart",
  goldPositive = "1",
  test1 = "New Test",
  test1Positive = "1",
  test2 = "Rater 1",
  test2Positive = "1",
  showIndividual = TRUE,
  showHeatmap = TRUE,
  showRecommendation = TRUE
)
```

### Sequential Testing Analysis
```r
# Evaluate serial testing strategies
sequential <- sequentialtests(
  data = histopathology,
  gold = "Golden Standart",
  goldPositive = "1",
  test1 = "New Test",
  test1Positive = "1",
  test2 = "Rater 1",
  test2Positive = "1",
  showFagan = TRUE
)
```

### ROC Analysis
```r
# ROC curve with optimal cutpoint
roc_result <- psychopdaroc(
  data = biomarker_data,
  class = "diagnosis",
  value = "biomarker_level"
)
```

### Interrater Reliability
```r
# Cohen's Kappa for two raters
agreement_result <- agreement(
  data = rating_data
)
```

## Example Datasets

Small CSV files are provided in `inst/extdata` to illustrate the main functions:
- `decision_example.csv`: Basic medical decision analysis
- `roc_example.csv`: ROC curve analysis
- `agreement_example.csv`: Interrater reliability

Access via: `system.file("extdata", "filename.csv", package = "meddecide")`

## Citation

If you use meddecide in your research, please cite the main ClinicoPath project:

```
Serdar Balci (2025). ClinicoPath jamovi Module. doi:10.5281/zenodo.3997188
[R package]. Retrieved from https://github.com/sbalci/ClinicoPathJamoviModule
```
