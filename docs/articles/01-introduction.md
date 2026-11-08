# Introduction to meddecide

**meddecide** is a jamovi module, and an R package, for the statistics
of medical decisions in pathology and clinical research: how well raters
agree, how accurate a diagnostic test is, where to put a cut-off, how
two tests combine, whether a prediction model is clinically useful, and
how many cases an agreement study needs.

## What is in the module

The **meddecide** menu in jamovi has six groups:

| Group | Analyses |
|----|----|
| Agreement | Interrater Reliability |
| Decision | Medical Decision; Combine Medical Decision Tests; Compare Medical Decision Tests; Analysis Without Gold Standard |
| Decision Calculators | Medical Decision Calculator; Co-Testing Analysis; Sequential Testing Analysis |
| Decision Curve Analysis | Decision Curve Analysis |
| ROC | Clinical ROC Analysis; Advanced ROC Analysis |
| Prediction Models | LASSO Logistic Regression |

Three sample-size tools for agreement studies appear under jamovi’s
**Power** menu, in **Power Analysis by meddecide**: Confidence Interval
Approach for the Number of Subjects Required, Power Approach for the
Number of Subjects Required, and Lowest Expected Kappa for a Fixed
Sample Size.

[Use meddecide in
R](https://www.serdarbalci.com/meddecide/articles/16-use-in-r.md) lists
all 15 analyses with their R function names and links to the articles.

## Installing

**In jamovi:** open the jamovi library (the **+ Modules** button), find
**meddecide** and install it. Example data sets are under **File \> Open
\> Data Library \> meddecide**.

**In R:**

\
[`install.packages`](https://rdrr.io/r/utils/install.packages.html)`(``"remotes"``)`\
`remotes``::`[`install_github`](https://remotes.r-lib.org/reference/install_github.html)`(``"sbalci/meddecide"``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`meddecide`](https://github.com/sbalci/ClinicoPathJamoviModule/)`)`

## Where to start

- Agreement between pathologists: [Inter-Rater Agreement and
  Reliability](https://www.serdarbalci.com/meddecide/articles/03-agreement-analysis.md),
  then [Diagnostic Style
  Clustering](https://www.serdarbalci.com/meddecide/articles/15-diagnostic-style-clustering.md).
- Accuracy of a test against a reference standard: [Diagnostic Test
  Evaluation](https://www.serdarbalci.com/meddecide/articles/13-diagnostic-tests.md).
- Two tests together:
  [Co-Testing](https://www.serdarbalci.com/meddecide/articles/34-cotest-analysis.md)
  and [Sequential
  Testing](https://www.serdarbalci.com/meddecide/articles/36-sequential-testing-comprehensive.md).
- No reference standard: [Analysis Without a Gold
  Standard](https://www.serdarbalci.com/meddecide/articles/12-nogoldstandard.md).
- Cut-offs and AUC: [ROC Curve
  Analysis](https://www.serdarbalci.com/meddecide/articles/03-roc-analysis.md).
- Planning an agreement study: the three kappa sample-size articles.

## A note on interpretation

The module reports estimates with confidence intervals and explains them
in plain language, but it does not decide whether a test or a rater
panel is good enough for clinical use. That depends on the clinical
question, the setting and the consequences of errors, and it should be
judged on the confidence interval, not on the point estimate alone.

[Choosing and interpreting an
analysis](https://www.serdarbalci.com/meddecide/articles/17-methods-and-interpretation.md)
explains prevalence, dependence, validation and the different kappa
planning targets.
