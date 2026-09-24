# meddecide

**Medical Decision Analysis, Diagnostic Evaluation, and Reliability Assessment for jamovi and R**

[![CRAN Status](https://www.r-pkg.org/badges/version/meddecide)](https://cran.r-project.org/package=meddecide)
[![R-CMD-check](https://github.com/sbalci/meddecide/workflows/R-CMD-check/badge.svg)](https://github.com/sbalci/meddecide/actions)
[![License: GPL (>= 2)](https://img.shields.io/badge/License-GPL%20(%3E=%202)-blue.svg)](https://www.gnu.org/licenses/gpl-2.0)
[![jamovi Module](https://img.shields.io/badge/jamovi-module-brightgreen.svg?logo=jamovi)](https://www.jamovi.org/)
[![Documentation](https://img.shields.io/badge/docs-pkgdown-blue.svg)](https://www.serdarbalci.com/meddecide/)

## Abstract

`meddecide` is a comprehensive R package and jamovi module bridging statistical methodology and practical clinical decision-making. As the diagnostic analytics and decision science engine of the **ClinicoPath** ecosystem, it equips clinicians, pathologists, and biomedical researchers with advanced tools for diagnostic test accuracy evaluation, Decision Curve Analysis (DCA), ROC curve modeling, inter-rater reliability assessment, regularized prediction modeling (LASSO Logistic), and precision/power sample size planning—all accessible through an intuitive graphical interface and reproducible R code.

---

## 🎯 Key Features & Analysis Suite (15 Analyses)

`meddecide` provides **15 specialized analyses** across 6 clinical domains:

| Domain | Analysis | Function | Key Clinical Features |
| :--- | :--- | :--- | :--- |
| **Diagnostic Evaluation** | **Medical Decision** | `decision` | Comprehensive evaluation of a single diagnostic test against a reference standard: Sensitivity, Specificity, Positive/Negative Predictive Values (PPV/NPV), Positive/Negative Likelihood Ratios (PLR/NLR), Diagnostic Odds Ratio (DOR), and accuracy metrics with 95% confidence intervals. |
| **Diagnostic Evaluation** | **Decision Calculator** | `decisioncalculator` | Interactive clinical calculator transforming 2x2 counts or known test characteristics into post-test probabilities; generates interactive Fagan nomograms. |
| **Diagnostic Evaluation** | **Compare Tests** | `decisioncompare` | Direct statistical comparison of two or more diagnostic tests against a common gold standard; highlights differences in sensitivity, specificity, and predictive values. |
| **Diagnostic Evaluation** | **Combine Tests** | `decisioncombine` | Evaluates all combinatorial permutations of 2 to 3 diagnostic tests to find optimal diagnostic panel algorithms; includes decision matrices and performance heatmaps. |
| **Diagnostic Evaluation** | **Co-Testing Analysis** | `cotest` | Evaluates simultaneous (parallel) testing strategies (e.g. HPV + cytology co-testing) to quantify gains in diagnostic sensitivity and trade-offs in specificity. |
| **Diagnostic Evaluation** | **Sequential Testing** | `sequentialtests` | Evaluates two-stage serial testing algorithms (screening followed by confirmatory reflex testing) to minimize invasive testing costs while maintaining diagnostic precision. |
| **Diagnostic Evaluation** | **No Gold Standard** | `nogoldstandard` | Evaluates diagnostic accuracy when an imperfect or absent gold standard exists, utilizing latent class analysis and Bayesian Hui-Walter estimation. |
| **Decision Curve Analysis** | **Decision Curve Analysis (DCA)** | `decisioncurve` | Evaluates clinical net benefit across a continuum of patient decision thresholds; compares "treat all", "treat none", and model-guided strategies; calculates standardized net benefit and number of unnecessary interventions avoided. |
| **ROC Modeling** | **Clinical ROC Analysis** | `enhancedROC` | Publication-ready ROC curves, empirical and smooth AUC estimation with DeLong/bootstrap confidence intervals, and automated optimal cutpoint detection (Youden's J, closest-to-(0,1)). |
| **ROC Modeling** | **Advanced ROC Analysis** | `psychopdaROC` | In-depth ROC coordinates evaluation with customizable threshold tables, sensitivity/specificity tradeoffs, and cost-weighted cutoff optimization. |
| **Agreement & Reliability** | **Interrater Reliability** | `agreement` | Multi-rater agreement analysis including Cohen's Kappa, Fleiss' Kappa, weighted kappa for ordinal scales, Gwet's AC1/AC2, percentage agreement, and disagreement visualizations. |
| **Prediction Modeling** | **LASSO Logistic Regression** | `lassologistic` | L1-penalized logistic regression via glmnet for binary clinical outcome prediction and sparse biomarker selection; includes k-fold cross-validation and penalty tuning. |
| **Sample Size Planning** | **Kappa Sample Size (CI)** | `kappaSizeCI` | Precision-based sample size calculator determining the number of subjects or ratings required to achieve a target confidence interval half-width for Cohen's Kappa. |
| **Sample Size Planning** | **Kappa Fixed N Analysis** | `kappaSizeFixedN` | Computes the lowest expected Kappa value and achievable lower confidence bound for a predetermined or constrained sample size. |
| **Sample Size Planning** | **Kappa Power Analysis** | `kappaSizePower` | Hypothesis testing power calculator computing sample size required to demonstrate agreement exceeding a minimum acceptable threshold. |

---

## 🚀 Installation

### In jamovi (Recommended)

1. Open **jamovi** (>= 2.6).
2. Click the **+** button in the top right corner → **jamovi library**.
3. Search for **meddecide** (or browse under **meddecide**).
4. Click **Install**.

### As an R Package

```r
# Install development version from GitHub
remotes::install_github("sbalci/meddecide")
```

---

## 💡 Quick Start (R Interface)

```r
library(meddecide)

# Load included clinical histopathology dataset
data("histopathology", package = "meddecide")

# 1. Single diagnostic test evaluation
decision_res <- meddecide::decision(
  data = histopathology,
  gold = "Golden Standart",
  goldPositive = "1",
  newtest = "New Test",
  testPositive = "1"
)

# 2. Decision Curve Analysis (DCA)
data("dca_test_data", package = "meddecide")
dca_res <- meddecide::decisioncurve(
  data = dca_test_data,
  outcome = "Cancer",
  predictors = vars(Biomarker, Age, PriorBiopsy),
  thresholds = "0.01, 0.50, 0.01"
)

# 3. Interrater agreement (Cohen's / Fleiss' Kappa)
data("breast_diagnostic_styles", package = "meddecide")
agreement_res <- meddecide::agreement(
  data = breast_diagnostic_styles,
  vars = vars(Pathologist_A, Pathologist_B)
)

# 4. Precision-based sample size calculation for agreement
k_size <- meddecide::kappaSizeCI(
  kappa0 = 0.80,
  w = 0.10,
  k = 2,
  props = "0.5, 0.5",
  alpha = 0.05
)
```

---

## 📖 Documentation & Resources

- **Module Website & Vignettes**: [https://www.serdarbalci.com/meddecide/](https://www.serdarbalci.com/meddecide/)
- **ClinicoPath Umbrella Ecosystem**: [https://www.serdarbalci.com/ClinicoPathJamoviModule/](https://www.serdarbalci.com/ClinicoPathJamoviModule/)
- **GitHub Repository**: [https://github.com/sbalci/meddecide/](https://github.com/sbalci/meddecide/)
- **Issue Tracking & Feedback**: [GitHub Issues](https://github.com/sbalci/ClinicoPathJamoviModule/issues)

---

## Citation

If you use meddecide in your research or publications, please cite:

```bibtex
@manual{balci2026clinicopath,
  title  = {ClinicoPath: jamovi Module for Clinicopathological Research},
  author = {Serdar Balci},
  year   = {2026},
  url    = {https://www.serdarbalci.com/ClinicoPathJamoviModule/},
  doi    = {10.5281/zenodo.3997188}
}
```

## License

GPL (>= 2) — see the [LICENSE.md](LICENSE.md) file for details.
