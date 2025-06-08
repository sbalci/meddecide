# meddecide

Functions for Medical Decision Making for ClinicoPath jamovi Module

See https://sbalci.github.io/ClinicoPathJamoviModule/

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

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXX)
[![Documentation](https://img.shields.io/badge/docs-pkgdown-blue.svg)](https://sbalci.github.io/ClinicoPathJamoviModule/)
[![Clinical Research](https://img.shields.io/badge/Domain-Clinical%20Research-darkblue.svg)](https://github.com/sbalci/meddecide)

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
