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
- **Test Comparison**: Compare multiple diagnostic tests against a gold standard
- **Decision Calculator**: Interactive tool for exploring how test characteristics affect clinical decisions
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
- **Fagan Nomograms**: Interactive Bayesian probability calculators
- **Forest Plots**: Compare diagnostic metrics across studies
- **Agreement Plots**: Visualize inter-rater reliability patterns
- **ROC Space**: Multi-test comparison in ROC coordinate system

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

## Example datasets

Small CSV files are provided in `inst/extdata` to illustrate the main
functions. Use `read.csv()` together with `system.file()` to access the
files after the package is installed.

```r
# Decision analysis example
df_dec <- read.csv(system.file("extdata", "decision_example.csv", package = "meddecide"))
decision(data = df_dec, gold = df_dec$gold, newtest = df_dec$newtest,
         goldPositive = 1, testPositive = 1)

# ROC analysis example
df_roc <- read.csv(system.file("extdata", "roc_example.csv", package = "meddecide"))
psychopdaroc(data = df_roc, class = df_roc$class, value = df_roc$value)

# Agreement analysis example
df_agr <- read.csv(system.file("extdata", "agreement_example.csv", package = "meddecide"))
agreement(data = df_agr)
```

## Citation

If you use meddecide in your research, please cite the main ClinicoPath project:

```
Serdar Balci (2025). ClinicoPath jamovi Module. doi:10.5281/zenodo.3997188
[R package]. Retrieved from https://github.com/sbalci/ClinicoPathJamoviModule
```
