# Diagnostic Test Evaluation

The **meddecide** package provides tools to evaluate medical diagnostic
tests. This vignette demonstrates the core functions for decision
analysis.

## Example Data

Small example datasets are included with the package. You can load them
using [`system.file()`](https://rdrr.io/r/base/system.file.html) and
[`read.csv()`](https://rdrr.io/r/utils/read.table.html).

\
`df_dec`` ``<-`` `[`read.csv`](https://rdrr.io/r/utils/read.table.html)`(`[`system.file`](https://rdrr.io/r/base/system.file.html)`(``"extdata"``, ``"decision_example.csv"``, package ``=`` ``"meddecide"``)``)`\
[`head`](https://rdrr.io/r/utils/head.html)`(``df_dec``)`

## Calculating Diagnostic Metrics

The
[`decision()`](https://www.serdarbalci.com/meddecide/reference/decision.md)
function computes sensitivity, specificity and related metrics from raw
test results.

\
`res`` ``<-`` `[`decision`](https://www.serdarbalci.com/meddecide/reference/decision.md)`(``data ``=`` ``df_dec``,`\
`                gold ``=`` ``df_dec``$``gold``,`\
`                goldPositive ``=`` ``1``,`\
`                newtest ``=`` ``df_dec``$``newtest``,`\
`                testPositive ``=`` ``1``,`\
`                ci ``=`` ``TRUE``)`\
`res``$``ratioTable`

When you only have the four counts (true positives, false positives,
true negatives and false negatives) you can use
[`decisioncalculator()`](https://www.serdarbalci.com/meddecide/reference/decisioncalculator.md)
directly.

\
`calc`` ``<-`` `[`decisioncalculator`](https://www.serdarbalci.com/meddecide/reference/decisioncalculator.md)`(``TP ``=`` ``90``, FN ``=`` ``10``, TN ``=`` ``80``, FP ``=`` ``20``,`\
`                           ci ``=`` ``TRUE``, fagan ``=`` ``TRUE``)`\
`calc``$``ratioTable`

The option `fagan = TRUE` adds a Fagan nomogram to illustrate how the
pre-test probability is updated by the diagnostic result.

\
`calc``$``fagan`

These tools help summarise diagnostic performance and can be combined
with other functions in **meddecide** for more advanced analysis.
