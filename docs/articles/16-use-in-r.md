# Use meddecide in R

Every analysis in the jamovi module is also an R function with the same
name. The function arguments are the options of the jamovi panel; see
the help page of each function (for example
[`?decision`](https://www.serdarbalci.com/meddecide/reference/decision.md))
for the full list.

## The 15 analyses

| Function | jamovi menu | Purpose | Article |
|----|----|----|----|
| [`agreement()`](https://www.serdarbalci.com/meddecide/reference/agreement.md) | meddecide \> Agreement \> Interrater Reliability | Kappa, weighted kappa, ICC, Krippendorff’s alpha, Gwet’s AC1, Bland-Altman and related agreement statistics | [Agreement](https://www.serdarbalci.com/meddecide/articles/03-agreement-analysis.md), [comprehensive](https://www.serdarbalci.com/meddecide/articles/meddecide-agreement-comprehensive.md) |
| [`decision()`](https://www.serdarbalci.com/meddecide/reference/decision.md) | meddecide \> Decision \> Medical Decision | Sensitivity, specificity, predictive values and likelihood ratios from raw data against a reference standard | [Diagnostic tests](https://www.serdarbalci.com/meddecide/articles/13-diagnostic-tests.md) |
| [`decisioncombine()`](https://www.serdarbalci.com/meddecide/reference/decisioncombine.md) | meddecide \> Decision \> Combine Medical Decision Tests | Accuracy of combinations (patterns) of up to three binary tests |  |
| [`decisioncompare()`](https://www.serdarbalci.com/meddecide/reference/decisioncompare.md) | meddecide \> Decision \> Compare Medical Decision Tests | Compare the accuracy of up to three tests on the same patients |  |
| [`nogoldstandard()`](https://www.serdarbalci.com/meddecide/reference/nogoldstandard.md) | meddecide \> Decision \> Analysis Without Gold Standard | Latent models for 3-5 tests without a reference standard; reference-rule agreement for 2-5 tests | [No gold standard](https://www.serdarbalci.com/meddecide/articles/12-nogoldstandard.md) |
| [`decisioncalculator()`](https://www.serdarbalci.com/meddecide/reference/decisioncalculator.md) | meddecide \> Decision Calculators \> Medical Decision Calculator | Diagnostic accuracy from the four cell counts, with Fagan nomogram | [Diagnostic tests](https://www.serdarbalci.com/meddecide/articles/13-diagnostic-tests.md) |
| [`cotest()`](https://www.serdarbalci.com/meddecide/reference/cotest.md) | meddecide \> Decision Calculators \> Co-Testing Analysis | Post-test probabilities when two tests are done together, with or without conditional dependence | [Co-testing](https://www.serdarbalci.com/meddecide/articles/34-cotest-analysis.md) |
| [`sequentialtests()`](https://www.serdarbalci.com/meddecide/reference/sequentialtests.md) | meddecide \> Decision Calculators \> Sequential Testing Analysis | Serial and parallel two-test strategies | [Sequential testing](https://www.serdarbalci.com/meddecide/articles/36-sequential-testing-comprehensive.md) |
| [`decisioncurve()`](https://www.serdarbalci.com/meddecide/reference/decisioncurve.md) | meddecide \> Decision Curve Analysis \> Decision Curve Analysis | Net benefit of prediction models across threshold probabilities |  |
| [`enhancedROC()`](https://www.serdarbalci.com/meddecide/reference/enhancedROC.md) | meddecide \> ROC \> Clinical ROC Analysis | ROC curves, AUC, optimal cut-offs and clinical metrics | [Clinical ROC](https://www.serdarbalci.com/meddecide/articles/meddecide-enhancedroc-comprehensive.md) |
| [`psychopdaROC()`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md) | meddecide \> ROC \> Advanced ROC Analysis | ROC with many cut-point methods, DeLong comparison, IDI/NRI, decision curves | [ROC](https://www.serdarbalci.com/meddecide/articles/03-roc-analysis.md), [comprehensive](https://www.serdarbalci.com/meddecide/articles/meddecide-psychopdaroc-comprehensive.md) |
| [`lassologistic()`](https://www.serdarbalci.com/meddecide/reference/lassologistic.md) | meddecide \> Prediction Models \> LASSO Logistic Regression | Penalised logistic regression for variable selection and risk scores |  |
| [`kappaSizeCI()`](https://www.serdarbalci.com/meddecide/reference/kappaSizeCI.md) | Power \> Power Analysis by meddecide \> Confidence Interval Approach for the Number of Subjects Required | Sample size for a kappa confidence interval of a given width | [kappaSizeCI](https://www.serdarbalci.com/meddecide/articles/07-kappasizeci-comprehensive.md) |
| [`kappaSizePower()`](https://www.serdarbalci.com/meddecide/reference/kappaSizePower.md) | Power \> Power Analysis by meddecide \> Power Approach for the Number of Subjects Required | Sample size to test kappa against a null value | [kappaSizePower](https://www.serdarbalci.com/meddecide/articles/09-kappasizepower-comprehensive.md) |
| [`kappaSizeFixedN()`](https://www.serdarbalci.com/meddecide/reference/kappaSizeFixedN.md) | Power \> Power Analysis by meddecide \> Lowest Expected Kappa for a Fixed Sample Size | Expected one-sided lower confidence bound at fixed N; not a power calculation | [kappaSizeFixedN](https://www.serdarbalci.com/meddecide/articles/08-kappasizefixedn-comprehensive.md) |

## Calling conventions

- Pass columns **by name**: `gold = "gold"`,
  `vars = c("Rater1", "Rater2")`. A bare object name given to a variable
  argument is read as a column name, so build vectors of names inline
  (`vars = c(...)` or `vars = sprintf(...)`).
- Arguments of type *Level* (the positive and negative levels of an
  outcome or test, such as `goldPositive`/`goldNegative` in
  [`decision()`](https://www.serdarbalci.com/meddecide/reference/decision.md)
  or `positiveClass`/`negativeClass` in
  [`psychopdaROC()`](https://www.serdarbalci.com/meddecide/reference/psychopdaROC.md))
  have no default and must always be given. The analysis does not guess
  which level means “disease”.
- The result is an object whose elements are the tables and plots of the
  jamovi output. Print it to see everything, or pick one element and
  convert a table with `$asDF`:

\
`res`` ``<-`` `[`decisioncalculator`](https://www.serdarbalci.com/meddecide/reference/decisioncalculator.md)`(``TP ``=`` ``90``, FN ``=`` ``10``, TN ``=`` ``80``, FP ``=`` ``20``)`\
`res``$``ratioTable``$``asDF`\
`#>     tablename Sens Spec AccurT PrevalenceD       PPV       NPV`\
`#> "1"  Measures  0.9  0.8   0.85         0.5 0.8181818 0.8888889`\
`#>     PostTestProbDisease PostTestProbNeg LRP   LRN`\
`#> "1"           0.8181818       0.1111111 4.5 0.125`

Some results sit inside groups and need a two-part path, for example
`agreement(...)$krippTableGroup$krippTable`.

For assumptions, denominator differences and validation status, see
[Choosing and interpreting an
analysis](https://www.serdarbalci.com/meddecide/articles/17-methods-and-interpretation.md).
