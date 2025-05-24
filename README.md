# meddecide

Functions for Medical Decision Making for ClinicoPath jamovi Module

See https://sbalci.github.io/ClinicoPathJamoviModule/


[![R-CMD-check](https://github.com/sbalci/meddecide/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/sbalci/meddecide/actions/workflows/R-CMD-check.yaml)

## Example: running `decision()`

Several small example datasets are included in `inst/extdata`.  The file
`decision_example.csv` provides binary test results along with the gold
standard outcome.  After loading it you can run `decision()` and inspect the
tables and plots that are produced.

```r
library(meddecide)

path <- system.file("extdata", "decision_example.csv", package = "meddecide")
dec_data <- read.csv(path)

res <- decision(dec_data,
                gold = Gold,
                goldPositive = "Positive",
                newtest = Test,
                testPositive = "Positive")

res$cTable$asDF      # confusion matrix
res$plot1            # Fagan nomogram/ROC plot
```

Additional CSV examples such as `agreement_example.csv` and
`decisioncalculator_example.csv` can be found in the same directory for use
with the other functions in this package.

The package also includes a more complete example dataset named
`histopathology` which can be loaded with:

```r
data(histopathology)
str(histopathology)
```
