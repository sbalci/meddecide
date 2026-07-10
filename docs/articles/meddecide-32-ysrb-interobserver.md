# Interobserver reliability beyond a single kappa

## When to use this

A reliability study almost never ends with one number. You report an
overall Fleiss’ kappa, a reviewer asks *“which two readers actually
disagreed?”* and *“which diagnostic category is dragging the agreement
down?”*, and suddenly a single summary statistic is not enough.
Interobserver studies of structured reporting systems - the Yokohama
System for Reporting Breast cytopathology (YSRB), the Milan system, the
Bethesda system, ISUP grading - routinely pair the overall kappa with
two supplementary tables:

- **Table I - every rater pair.** Cohen’s kappa for each of the
  $`\binom{k}{2}`$ reader pairs, with a confidence interval and a
  significance test. This is how you spot an outlier reader whose
  pairwise kappas are systematically lower than everyone else’s.
- **Table II - every category.** A per-category agreement rate that
  answers *“when readers land on category c, how often do they all
  agree?”* This is how you find the diagnostic bottleneck - typically
  the “atypical / suspicious” middle category.

The `agreement` analysis produces both, alongside the overall kappa,
from the same set of rater columns.

## A synthetic YSRB-like dataset

The real study data are not redistributable, so we simulate a dataset
with the same shape: 99 cases, four readers, and five ordinal YSRB
categories (I = insufficient, II = benign, III = atypical, IV =
suspicious, V = malignant) with the characteristic heavily-benign
marginal distribution.

``` r

library(meddecide)

set.seed(2024)
n     <- 99
cats  <- c("I", "II", "III", "IV", "V")
prob  <- c(0.05, 0.75, 0.05, 0.04, 0.11)   # mostly benign, as in real cytology
truth <- sample(cats, n, replace = TRUE, prob = prob)

# Each reader agrees with the latent truth most of the time, otherwise slips to
# an adjacent category. Reader 4 is a little noisier than the rest.
slip <- function(x) {
  i <- match(x, cats)
  cats[pmin(length(cats), pmax(1, i + sample(c(-1, 1), 1)))]
}
reader <- function(p_agree) {
  vapply(truth, function(t) if (runif(1) < p_agree) t else slip(t), character(1))
}

ysrb <- data.frame(
  Reader1 = reader(0.92),
  Reader2 = reader(0.90),
  Reader3 = reader(0.91),
  Reader4 = reader(0.84),
  stringsAsFactors = FALSE
)
ysrb[] <- lapply(ysrb, factor, levels = cats, ordered = TRUE)

knitr::kable(head(ysrb), caption = "First few cases (4 readers, YSRB category)")
```

| Reader1 | Reader2 | Reader3 | Reader4 |
|:--------|:--------|:--------|:--------|
| V       | V       | V       | V       |
| II      | II      | II      | II      |
| II      | II      | II      | III     |
| II      | II      | II      | II      |
| II      | II      | III     | II      |
| II      | II      | II      | III     |

First few cases (4 readers, YSRB category) {.table}

## Run the analysis

We turn on the all-pairs table, the per-category item-modal table, and a
Bonferroni correction for the $`\binom{4}{2} = 6`$ pairwise tests.

``` r

res <- agreement(
  data                   = ysrb,
  vars                   = c("Reader1", "Reader2", "Reader3", "Reader4"),
  allPairsKappa          = TRUE,
  itemModalCategoryAgreement = TRUE,
  multipleTestCorrection = "bonferroni"
)
```

### Overall agreement

``` r

knitr::kable(res$irrtable$asDF, digits = 3,
             caption = "Overall agreement (Fleiss' kappa across all four readers)")
```

|     | method                     | subjects | raters | peragree | kappa |    z |   p |
|:----|:---------------------------|---------:|-------:|---------:|------:|-----:|----:|
| “1” | Fleiss’ Kappa for m Raters |       99 |      4 |   60.606 | 0.571 | 22.8 |   0 |

Overall agreement (Fleiss’ kappa across all four readers) {.table
style="width:100%;"}

The overall kappa tells you the readers agree appreciably better than
chance, but it hides *where* the agreement comes from and *where* it
breaks down.

## Table I - All-pairs Cohen’s kappa

``` r

allpairs <- res$allPairsKappaTable$asDF
knitr::kable(
  allpairs[, c("rater_a", "rater_b", "n", "peragree", "kappa",
               "ci_lower", "ci_upper", "p_adj")],
  digits = 3,
  col.names = c("Reader A", "Reader B", "n", "Obs. agree", "Kappa",
                "CI lower", "CI upper", "p (Bonf.)"),
  caption = "Cohen's kappa for every reader pair, with 95% CI."
)
```

|  | Reader A | Reader B | n | Obs. agree | Kappa | CI lower | CI upper | p (Bonf.) |
|:---|:---|:---|---:|---:|---:|---:|---:|---:|
| “Reader1\_\_Reader2” | Reader1 | Reader2 | 99 | 0.848 | 0.674 | 0.528 | 0.819 | 0 |
| “Reader1\_\_Reader3” | Reader1 | Reader3 | 99 | 0.848 | 0.669 | 0.524 | 0.814 | 0 |
| “Reader1\_\_Reader4” | Reader1 | Reader4 | 99 | 0.747 | 0.500 | 0.345 | 0.656 | 0 |
| “Reader2\_\_Reader3” | Reader2 | Reader3 | 99 | 0.818 | 0.613 | 0.464 | 0.762 | 0 |
| “Reader2\_\_Reader4” | Reader2 | Reader4 | 99 | 0.747 | 0.510 | 0.355 | 0.665 | 0 |
| “Reader3\_\_Reader4” | Reader3 | Reader4 | 99 | 0.737 | 0.486 | 0.330 | 0.642 | 0 |

Cohen’s kappa for every reader pair, with 95% CI. {.table
style="width:100%;"}

Two points worth stressing about this table:

- **The confidence intervals are computed from the non-null asymptotic
  standard error** (via
  [`vcd::Kappa`](https://rdrr.io/pkg/vcd/man/Kappa.html)), so they agree
  with
  [`psych::cohen.kappa()`](https://rdrr.io/pkg/psych/man/kappa.html) and
  are *wider* - i.e. honest - compared with intervals built from the
  kappa/z test statistic, which uses the standard error under the null
  hypothesis of no agreement. A too-narrow CI would overstate precision.
- **Pairs involving the noisier Reader 4** sit at the bottom of the
  kappa ranking. In a real study this is exactly the signal that prompts
  targeted re-training rather than a blanket “agreement was moderate”
  conclusion.

## Table II - Agreement by modal category

For each case we take the modal (most common) reading across the four
readers, then, within each category, average the case-level agreement
rate. A 4/4 case scores 1.00, a 3/1 split scores 0.75, and a 2/2 split
has no unique mode and is excluded.

``` r

modal <- res$itemModalAgreementTable$asDF
knitr::kable(
  modal,
  digits = 3,
  col.names = c("Modal category", "Cases", "Mean agreement",
                "CI lower", "CI upper"),
  caption = "Within-case agreement, by the case's modal category."
)
```

|       | Modal category | Cases | Mean agreement | CI lower | CI upper |
|:------|:---------------|------:|---------------:|---------:|---------:|
| “I”   | I              |     2 |          1.000 |    1.000 |    1.000 |
| “II”  | II             |    76 |          0.898 |    0.867 |    0.929 |
| “III” | III            |     5 |          0.850 |    0.730 |    0.970 |
| “IV”  | IV             |     4 |          0.938 |    0.815 |    1.000 |
| “V”   | V              |     9 |          0.917 |    0.835 |    0.998 |

Within-case agreement, by the case’s modal category. {.table}

The benign category (II) carries most of the cases and shows high,
tightly estimated agreement. The rarer categories (I, III, IV) are
represented by only a handful of modal cases, so their agreement
estimates are unstable and their confidence intervals are wide - a
reminder that a per-category mean is only as trustworthy as its cell
count. In a real, larger YSRB or Milan series this same table is where
the atypical/suspicious middle categories typically reveal themselves as
the agreement bottleneck; here it mainly illustrates that you should
read sparse-category rows with their CIs, not their point estimates.

## Two cautions the analysis flags for you

**The kappa paradox.** When a category is rare, kappa can be
paradoxically low even when observed agreement is high. If any category
is sparse, the analysis attaches a note to the overall table suggesting
the prevalence-robust alternatives it also offers - Gwet’s AC1/AC2 and
PABAK - as sensitivity analyses. Enable those (and `bootstrapCI`) when
your marginal distribution is as lopsided as a typical benign-dominated
cytology series.

**Multiplicity.** With $`k`$ readers you run $`\binom{k}{2}`$ pairwise
tests - 6 for four readers, 15 for six. The
`Multiple Testing Correction` option (Bonferroni, Benjamini-Hochberg, or
Holm) adds an adjusted-p column to Table I so you do not read six raw
p-values as if they were one.

## Reproducibility

``` r

sessionInfo()
```

    ## R version 4.6.0 (2026-04-24)
    ## Platform: aarch64-apple-darwin23
    ## Running under: macOS Tahoe 26.5.1
    ## 
    ## Matrix products: default
    ## BLAS:   /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRblas.0.dylib 
    ## LAPACK: /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
    ## 
    ## locale:
    ## [1] C.UTF-8/C.UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8
    ## 
    ## time zone: Europe/Istanbul
    ## tzcode source: internal
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] meddecide_0.0.5
    ## 
    ## loaded via a namespace (and not attached):
    ##   [1] DBI_1.3.0               pROC_1.19.0.1           gridExtra_2.3.1        
    ##   [4] BiasedUrn_2.0.12        rlang_1.3.0             magrittr_2.0.5         
    ##   [7] otel_0.2.0              e1071_1.7-17            compiler_4.6.0         
    ##  [10] systemfonts_1.3.2       vctrs_0.7.3             reshape2_1.4.5         
    ##  [13] stringr_1.6.0           cutpointr_1.2.1         pkgconfig_2.0.3        
    ##  [16] fastmap_1.2.0           backports_1.5.1         pander_0.6.6           
    ##  [19] rmarkdown_2.31          prodlim_2026.03.11      epiR_2.0.94            
    ##  [22] ragg_1.5.2              purrr_1.2.2             xfun_0.59              
    ##  [25] cachem_1.1.0            jsonlite_2.0.0          recipes_1.3.3          
    ##  [28] uuid_1.2-2              parallel_4.6.0          R6_2.6.1               
    ##  [31] vcd_1.4-13              bslib_0.11.0            stringi_1.8.7          
    ##  [34] RColorBrewer_1.1-3      parallelly_1.48.0       boot_1.3-32            
    ##  [37] rpart_4.1.27            lmtest_0.9-40           lubridate_1.9.5        
    ##  [40] jquerylib_0.1.4         Rcpp_1.1.2              iterators_1.0.14       
    ##  [43] knitr_1.51              future.apply_1.20.2     zoo_1.8-15             
    ##  [46] Matrix_1.7-5            splines_4.6.0           nnet_7.3-20            
    ##  [49] timechange_0.4.0        tidyselect_1.2.1        rstudioapi_0.19.0      
    ##  [52] yaml_2.3.12             timeDate_4052.112       codetools_0.2-20       
    ##  [55] listenv_1.0.0           lattice_0.22-9          tibble_3.3.1           
    ##  [58] plyr_1.8.9              withr_3.0.3             S7_0.2.2               
    ##  [61] flextable_0.10.0        askpass_1.2.1           evaluate_1.0.5         
    ##  [64] future_1.70.0           desc_1.4.3              survival_3.8-6         
    ##  [67] sf_1.1-1                units_1.0-1             proxy_0.4-29           
    ##  [70] zip_3.0.0               xml2_1.6.0              lpSolve_5.6.23         
    ##  [73] pillar_1.11.1           KernSmooth_2.23-26      checkmate_2.3.4        
    ##  [76] foreach_1.5.2           stats4_4.6.0            generics_0.1.4         
    ##  [79] ggplot2_4.0.3           scales_1.4.0            irr_0.85               
    ##  [82] globals_0.19.1          jmvcore_2.7.35          class_7.3-23           
    ##  [85] glue_1.8.1              gdtools_0.5.1           tools_4.6.0            
    ##  [88] data.table_1.18.4       ModelMetrics_1.2.2.2    gower_1.0.2            
    ##  [91] forcats_1.0.1           fs_2.1.0                grid_4.6.0             
    ##  [94] tidyr_1.3.2             colorspace_2.1-2        ipred_0.9-15           
    ##  [97] patchwork_1.3.2         nlme_3.1-169            htmlTable_2.5.0        
    ## [100] cli_3.6.6               textshaping_1.0.5       officer_0.7.5          
    ## [103] fontBitstreamVera_0.1.1 lava_1.9.2              dplyr_1.2.1            
    ## [106] gtable_0.3.6            sass_0.4.10             digest_0.6.39          
    ## [109] fontquiver_0.2.1        classInt_0.4-11         caret_7.0-1            
    ## [112] htmlwidgets_1.6.4       farver_2.1.2            htmltools_0.5.9        
    ## [115] pkgdown_2.2.0           lifecycle_1.0.5         hardhat_1.4.3          
    ## [118] fontLiberation_0.1.0    openssl_2.4.2           MASS_7.3-65
