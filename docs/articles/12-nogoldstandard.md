# Analyzing Diagnostic Tests without a Gold Standard

## Introduction

Evaluating a diagnostic test usually needs a reference (“gold”) standard
that tells us who truly has the disease. Often no such reference exists,
or it is too invasive, costly or unethical to apply to everyone. The
`nogoldstandard` analysis estimates how several imperfect tests behave
from the patterns of agreement and disagreement among them, without a
reference test.

This vignette shows how to:

1.  fit a two-class latent class model and read its class proportion and
    response probabilities,
2.  obtain bootstrap confidence intervals,
3.  compare the latent-model results with simple reference rules,
4.  check, and understand the limits of checking, the
    conditional-independence assumption.

Every code chunk below is executed when the vignette is built.

## Methods Overview

The analysis offers five methods.

1.  **Latent class analysis** (`latent_class`, the default): a two-class
    model in which the tests are assumed to err independently within
    each class (conditional independence). Fitted by maximum likelihood.
2.  **Penalized EM** (`bayesian`): the same two-class model, fitted with
    fixed priors. Prevalence uses a uniform Beta(1, 1) prior;
    sensitivity and specificity each use a Beta(2, 1) prior, which adds
    one pseudo true-positive and one pseudo true-negative result to
    every test and pulls both estimates upward. The result is a
    penalized-likelihood (MAP) point estimate, not a posterior sample,
    and the priors cannot be changed.
3.  **Composite reference** (`composite`): a patient is
    reference-positive when more than half of the tests are positive (a
    tie counts as negative). Each evaluated test votes on the reference
    it is then compared with (incorporation bias), so its agreement can
    be distorted in either direction.
4.  **All tests positive** (`all_positive`): reference-positive only
    when every test is positive.
5.  **Any test positive** (`any_positive`): reference-positive when at
    least one test is positive.

The three rule methods report agreement of each test with a rule built
from the same tests. That is not diagnostic accuracy.

The latent methods need at least three tests; the analysis refuses two.

## Example Data

Four imperfect tests on 200 patients. In this simulation the true status
is known, so we can compare the estimates with the truth; in practice it
is not.

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`meddecide`](https://github.com/sbalci/ClinicoPathJamoviModule/)`)`\
\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``123``)`\
`n`` ``<-`` ``200`\
`true_status`` ``<-`` `[`rbinom`](https://rdrr.io/r/stats/Binomial.html)`(``n``, ``1``, ``0.3``)``  ``# 30% prevalence`\
\
`simulate_test`` ``<-`` ``function``(``sens``, ``spec``)`` ``{`\
`  `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``true_status`` ``==`` ``1``, `[`rbinom`](https://rdrr.io/r/stats/Binomial.html)`(``n``, ``1``, ``sens``)``, `[`rbinom`](https://rdrr.io/r/stats/Binomial.html)`(``n``, ``1``, ``1`` ``-`` ``spec``)``)`\
`}`\
`to_factor`` ``<-`` ``function``(``x``)`` `[`factor`](https://rdrr.io/r/base/factor.html)`(`[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``x`` ``==`` ``1``, ``"pos"``, ``"neg"``)``, levels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"neg"``, ``"pos"``)``)`\
\
`data`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  caseID ``=`` ``1``:``n``,`\
`  test1 ``=`` ``to_factor``(``simulate_test``(``0.90``, ``0.90``)``)``,`\
`  test2 ``=`` ``to_factor``(``simulate_test``(``0.75``, ``0.95``)``)``,`\
`  test3 ``=`` ``to_factor``(``simulate_test``(``0.85``, ``0.85``)``)``,`\
`  test4 ``=`` ``to_factor``(``simulate_test``(``0.70``, ``0.95``)``)`\
`)`\
[`head`](https://rdrr.io/r/utils/head.html)`(``data``)`\
`#>   caseID test1 test2 test3 test4`\
`#> 1      1   pos   neg   pos   neg`\
`#> 2      2   neg   pos   pos   pos`\
`#> 3      3   pos   neg   neg   neg`\
`#> 4      4   pos   pos   neg   pos`\
`#> 5      5   pos   pos   pos   pos`\
`#> 6      6   neg   pos   pos   neg`

## Running the Analysis

In R every test slot and every positive-level argument must be supplied.
Unused slots are passed as `NULL` (a positive level is a required
argument of the R function even when its test is not used).

\
`result`` ``<-`` `[`nogoldstandard`](https://www.serdarbalci.com/meddecide/reference/nogoldstandard.md)`(`\
`  data ``=`` ``data``,`\
`  test1 ``=`` ``"test1"``, test1Positive ``=`` ``"pos"``,`\
`  test2 ``=`` ``"test2"``, test2Positive ``=`` ``"pos"``,`\
`  test3 ``=`` ``"test3"``, test3Positive ``=`` ``"pos"``,`\
`  test4 ``=`` ``"test4"``, test4Positive ``=`` ``"pos"``,`\
`  test5 ``=`` ``NULL``, test5Positive ``=`` ``NULL``,`\
`  method ``=`` ``"latent_class"`\
`)`\
\
`result``$``prevalence``$``asDF`\
`#>      estimate ci_lower ci_upper`\
`#> "1" 0.2862007       NA       NA`\
`result``$``test_metrics``$``asDF``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"test"``, ``"sensitivity"``, ``"specificity"``, ``"ppv"``, ``"npv"``)``]`\
`#>          test sensitivity specificity       ppv       npv`\
`#> "test1" test1   0.9468650   0.9103297 0.8089356 0.9771319`\
`#> "test2" test2   0.6231854   0.9416588 0.8107095 0.8617377`\
`#> "test3" test3   0.8209333   0.8878560 0.7458784 0.9251839`\
`#> "test4" test4   0.6320051   0.9311856 0.7864361 0.8632203`

Results tables are read with `$asDF`, which is a field, not a function:
write `result$prevalence$asDF`, not `result$prevalence$asDF()`.

The output contains:

1.  the fitted proportion of the high-positive latent class,
2.  for each test, the probability of a positive result in the
    high-positive class and of a negative result in the other class,
    with predictive values,
3.  model-fit statistics and a conditional-independence check (bivariate
    residuals),
4.  the test agreement table and plot.

## Bootstrap Confidence Intervals

With `bootstrap = TRUE` the analysis resamples patients with
replacement, refits the selected method on each resample, and reports
percentile intervals. The point estimates do not change; only intervals
are added. `seed` makes the intervals reproducible. `nboot` must be at
least 100; use 1000 or more for reported results (100 keeps this
vignette fast).

\
`result_ci`` ``<-`` `[`nogoldstandard`](https://www.serdarbalci.com/meddecide/reference/nogoldstandard.md)`(`\
`  data ``=`` ``data``,`\
`  test1 ``=`` ``"test1"``, test1Positive ``=`` ``"pos"``,`\
`  test2 ``=`` ``"test2"``, test2Positive ``=`` ``"pos"``,`\
`  test3 ``=`` ``"test3"``, test3Positive ``=`` ``"pos"``,`\
`  test4 ``=`` ``"test4"``, test4Positive ``=`` ``"pos"``,`\
`  test5 ``=`` ``NULL``, test5Positive ``=`` ``NULL``,`\
`  method ``=`` ``"latent_class"``,`\
`  bootstrap ``=`` ``TRUE``, nboot ``=`` ``100``, alpha ``=`` ``0.05``, seed ``=`` ``42`\
`)`\
`result_ci``$``prevalence``$``asDF`\
`#>      estimate  ci_lower  ci_upper`\
`#> "1" 0.2862007 0.2183321 0.3505935`

Percentile intervals can be too narrow with weak identification,
estimates at 0% or 100%, or small samples; nominal coverage is not
guaranteed. Rows are resampled as independent patients, so the intervals
do not account for clustering (several specimens from one patient).

## Comparing Methods

\
`methods`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"latent_class"``, ``"bayesian"``, ``"composite"``, ``"all_positive"``, ``"any_positive"``)`\
`results`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``methods``, ``function``(``m``)`` ``{`\
`  `[`nogoldstandard`](https://www.serdarbalci.com/meddecide/reference/nogoldstandard.md)`(`\
`    data ``=`` ``data``,`\
`    test1 ``=`` ``"test1"``, test1Positive ``=`` ``"pos"``,`\
`    test2 ``=`` ``"test2"``, test2Positive ``=`` ``"pos"``,`\
`    test3 ``=`` ``"test3"``, test3Positive ``=`` ``"pos"``,`\
`    test4 ``=`` ``"test4"``, test4Positive ``=`` ``"pos"``,`\
`    test5 ``=`` ``NULL``, test5Positive ``=`` ``NULL``,`\
`    method ``=`` ``m`\
`  ``)`\
`}``)`\
[`names`](https://rdrr.io/r/base/names.html)`(``results``)`` ``<-`` ``methods`\
\
[`sapply`](https://rdrr.io/r/base/lapply.html)`(``results``, ``function``(``x``)`` ``x``$``prevalence``$``asDF``$``estimate``[``1``]``)`\
`#> latent_class     bayesian    composite all_positive any_positive `\
`#>    0.2862007    0.2846912    0.2150000    0.0900000    0.5000000`

The methods estimate different quantities:

- **Latent class analysis** and **penalized EM** estimate the proportion
  of the high-positive latent class. Penalized EM is pulled toward
  higher sensitivity and specificity by its fixed priors; with a large
  sample the two agree closely.
- **All tests positive** gives the smallest rule-positive proportion and
  **any test positive** the largest, by construction.
- **Composite** is a majority vote that includes the evaluated test.

## Interpreting Results

### Class proportion, not automatically prevalence

Latent classes are unlabeled. The analysis names the class whose tests
are, on average, more often positive the “high-positive” class. Calling
it the diseased class, its proportion the prevalence, and the response
probabilities sensitivity and specificity requires the substantive
assumption that positive results are more common in diseased patients
for most tests. If a positive level is selected the wrong way round, a
test can come out below chance (sensitivity plus specificity below 1),
and the analysis warns about it.

For the rule methods the “prevalence” is the proportion meeting the
rule, and sensitivity and specificity are agreement with that rule.

### Conditional independence

The latent model assumes the tests err independently within each class.
Two tests that share a mechanism (the same target, the same reader, the
same specimen) can violate this assumption and bias the estimates;
sharing a mechanism alone does not prove conditional dependence.

- **Four or five tests**: the bivariate-residual table compares each
  observed pairwise table with the one the fitted model implies. A
  residual above 3.84 is descriptive evidence against conditional
  independence, and the analysis then raises a warning. The flagged pair
  is not necessarily the dependent pair: the latent classes can absorb
  dependence between two tests so that the misfit appears elsewhere.
  Penalized EM shows the same table, computed from the unpenalized fit
  of the same model.
- **Three tests**: the two-class model has 7 parameters for 7 free cell
  frequencies, so it usually reproduces the observed table exactly.
  Dependence cannot be detected from the data, the residuals read “Not
  assessable”, and the analysis warns that conditional independence
  cannot be checked. A fourth test creates residual degrees of freedom
  and permits some model checks; it does not guarantee detection of
  dependence or identify the responsible test pair.

The analysis does not fit dependence models (direct test-to-test
associations, more than two classes, or random-effects latent class
models).

### Missing data

The analysis is complete-case: a patient with a missing result on any
selected test is excluded from every estimate, and the number of
analysed cases out of the total is reported. If results are not missing
completely at random, the estimates can be biased.

## Recommendations for Practice

1.  Use latent class analysis as the primary method, with at least four
    tests when you can, and read its conditional-independence check
    before interpreting the response probabilities as accuracy.
2.  Treat penalized EM as a stabilized version of the same model for
    small samples, not as a way to supply prior knowledge; its priors
    are fixed.
3.  Report the rule methods as agreement, not as accuracy.
4.  Report bootstrap intervals (1000 or more resamples) with the seed.
5.  Validate against external data, follow-up, or a reference test on a
    subset of patients where possible.

## References

1.  Hui SL, Walter SD. Estimating the error rates of diagnostic tests.
    Biometrics. 1980;36(1):167-171.

2.  Joseph L, Gyorkos TW, Coupal L. Bayesian estimation of disease
    prevalence and the parameters of diagnostic tests in the absence of
    a gold standard. Am J Epidemiol. 1995;141(3):263-272.

3.  Albert PS, Dodd LE. A cautionary note on the robustness of latent
    class models for estimating diagnostic error without a gold
    standard. Biometrics. 2004;60(2):427-435.

4.  Collins J, Huynh M. Estimation of diagnostic test accuracy without
    full verification: a review of latent class methods. Stat Med.
    2014;33(24):4141-4169.

5.  Dendukuri N, Joseph L. Bayesian approaches to modeling the
    conditional dependence between multiple diagnostic tests.
    Biometrics. 2001;57(1):158-167.

## Session Information

\
[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`\
`#> R version 4.6.0 (2026-04-24)`\
`#> Platform: aarch64-apple-darwin23`\
`#> Running under: macOS 27.2`\
`#> `\
`#> Matrix products: default`\
`#> BLAS:   /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRblas.0.dylib `\
`#> LAPACK: /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1`\
`#> `\
`#> locale:`\
`#> [1] C.UTF-8/C.UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8`\
`#> `\
`#> time zone: Europe/Istanbul`\
`#> tzcode source: internal`\
`#> `\
`#> attached base packages:`\
`#> [1] stats     graphics  grDevices utils     datasets  methods   base     `\
`#> `\
`#> other attached packages:`\
`#> [1] meddecide_1.1.4`\
`#> `\
`#> loaded via a namespace (and not attached):`\
`#>   [1] vcd_1.4-14              RColorBrewer_1.1-3      rstudioapi_0.19.0      `\
`#>   [4] jsonlite_2.0.0          shape_1.4.6.1           magrittr_2.0.5         `\
`#>   [7] nloptr_2.2.1            farver_2.1.2            rmarkdown_2.32         `\
`#>  [10] fs_2.1.0                ragg_1.5.2              vctrs_0.7.3            `\
`#>  [13] minqa_1.2.8             irr_0.85                cutpointr_1.2.1        `\
`#>  [16] askpass_1.2.1           htmltools_0.5.9         forcats_1.0.1          `\
`#>  [19] haven_2.5.5             cellranger_1.1.0        pROC_1.19.1            `\
`#>  [22] caret_7.0-1             sass_0.4.10             parallelly_1.48.0      `\
`#>  [25] KernSmooth_2.23-27      bslib_0.12.0            htmlwidgets_1.6.4      `\
`#>  [28] desc_1.4.3              plyr_1.8.9              rootSolve_1.8.2.4      `\
`#>  [31] zoo_1.9-0               lubridate_1.9.5         cachem_1.1.0           `\
`#>  [34] uuid_1.2-2              lifecycle_1.0.5         iterators_1.0.14       `\
`#>  [37] pkgconfig_2.0.3         Matrix_1.7-6            R6_2.6.1               `\
`#>  [40] fastmap_1.2.0           rbibutils_2.4.1         future_1.75.0          `\
`#>  [43] numDeriv_2016.8-1.1     digest_0.6.39           Exact_3.3              `\
`#>  [46] colorspace_2.1-3        patchwork_1.3.2         textshaping_1.0.5      `\
`#>  [49] timechange_0.4.0        httr_1.4.9              compiler_4.6.0         `\
`#>  [52] proxy_0.4-29            fontquiver_0.2.1        withr_3.0.3            `\
`#>  [55] pander_0.6.6            S7_0.2.2                DBI_1.3.0              `\
`#>  [58] BiasedUrn_2.0.12        MASS_7.3-66             lava_1.9.3             `\
`#>  [61] openssl_2.4.2           scatterplot3d_0.3-45    classInt_0.4-11        `\
`#>  [64] epiR_2.0.96             gld_2.6.8               ModelMetrics_1.2.2.2   `\
`#>  [67] tools_4.6.0             units_1.0-1             lmtest_0.9-40          `\
`#>  [70] otel_0.2.0              zip_3.0.2               future.apply_1.20.2    `\
`#>  [73] nnet_7.3-21             glue_1.8.1              nlme_3.1-171           `\
`#>  [76] grid_4.6.0              sf_1.1-2                reshape2_1.4.5         `\
`#>  [79] generics_0.1.4          lpSolve_5.6.23          recipes_1.4.0          `\
`#>  [82] gtable_0.3.6            tzdb_0.5.0              class_7.3-24           `\
`#>  [85] tidyr_1.3.2             data.table_1.18.6.1     lmom_3.3               `\
`#>  [88] hms_1.1.4               xml2_1.6.0              foreach_1.5.2          `\
`#>  [91] pillar_1.11.1           stringr_1.6.0           splines_4.6.0          `\
`#>  [94] dplyr_1.2.1             lattice_0.23-1          survival_3.8-12        `\
`#>  [97] tidyselect_1.2.1        fontLiberation_0.1.0    kappaSize_1.2          `\
`#> [100] knitr_1.52              reformulas_0.4.4        fontBitstreamVera_0.1.1`\
`#> [103] stats4_4.6.0            xfun_0.61               expm_1.0-1             `\
`#> [106] hardhat_1.4.3           jmvcore_2.7.38          timeDate_4052.112      `\
`#> [109] stringi_1.8.9           yaml_2.3.12             boot_1.3-32            `\
`#> [112] evaluate_1.0.5          codetools_0.2-20        officer_0.7.6          `\
`#> [115] gdtools_0.5.1           irrCAC_1.4              tibble_3.3.1           `\
`#> [118] cli_3.6.6               rpart_4.1.27            Rdpack_2.6.6           `\
`#> [121] DescTools_0.99.60       systemfonts_1.3.2       jquerylib_0.1.4        `\
`#> [124] Rcpp_1.1.2              readxl_1.5.0.1          globals_0.19.1         `\
`#> [127] parallel_4.6.0          pkgdown_2.2.1           gower_1.0.2            `\
`#> [130] ggplot2_4.0.3           readr_2.2.0             lme4_2.0-6             `\
`#> [133] listenv_1.0.0           glmnet_5.0              mvtnorm_1.4-2          `\
`#> [136] lmerTest_3.2-1          ipred_0.9-16            scales_1.4.0           `\
`#> [139] prodlim_2026.03.11      e1071_1.7-17            purrr_1.2.2            `\
`#> [142] flextable_0.10.1        rlang_1.3.0             poLCA_1.6.0.2`
