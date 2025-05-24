# meddecide

Functions for Medical Decision Making for ClinicoPath jamovi Module

See https://sbalci.github.io/ClinicoPathJamoviModule/


[![R-CMD-check](https://github.com/sbalci/meddecide/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/sbalci/meddecide/actions/workflows/R-CMD-check.yaml)

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
