# Inter-Rater Agreement and Reliability in Pathology

This article is a short, practical guide to the **Interrater
Reliability** analysis
([`agreement()`](https://www.serdarbalci.com/meddecide/reference/agreement.md),
jamovi menu **meddecide \> Agreement \> Interrater Reliability**). It
shows which statistic fits which kind of rating, and how to read the
result tables from R. For every option, see
[`?agreement`](https://www.serdarbalci.com/meddecide/reference/agreement.md)
or the [comprehensive
guide](https://www.serdarbalci.com/meddecide/articles/meddecide-agreement-comprehensive.md).

Each rater is one column of `data`; each row is one case. Pass the rater
columns to `vars`. With two raters the analysis reports Cohen’s kappa;
with three or more, Fleiss’ kappa.

## Choosing a statistic

| Ratings | Primary statistic | Options |
|----|----|----|
| Nominal (e.g. diagnosis) | Cohen’s / Fleiss’ kappa | default; `kripp = TRUE`, `gwet = TRUE` |
| Ordinal (e.g. grade 1-3) | Weighted kappa (2 raters); ordinal alpha or Gwet’s AC2 (3+ raters) | `wght = "equal"` (linear) or `"squared"` (quadratic); with 3+ raters `allPairsKappa = TRUE` gives weighted kappa per pair, or `krippMethod = "ordinal"`, `gwetWeights` |
| Rare category, skewed prevalence | Gwet’s AC1, PABAK | `gwet = TRUE`, `pabak = TRUE` |
| Continuous (e.g. Ki-67 %) | ICC, Lin’s CCC, Bland-Altman | `icc = TRUE`, `linCCC = TRUE`, `blandAltmanPlot = TRUE` |
| Missing ratings, any scale | Krippendorff’s alpha | `kripp = TRUE`, `krippMethod = "nominal"/"ordinal"/"interval"/"ratio"` |
| Which pairs disagree | All-pairs kappa | `allPairsKappa = TRUE` |

## Nominal ratings: three raters

The bundled `histopathology` data has three binary rater columns.

\
[`data`](https://rdrr.io/r/utils/data.html)`(``histopathology``)`\
\
`res`` ``<-`` `[`agreement`](https://www.serdarbalci.com/meddecide/reference/agreement.md)`(`\
`  data ``=`` ``histopathology``,`\
`  vars ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Rater 1"``, ``"Rater 2"``, ``"Rater 3"``)``,`\
`  kripp ``=`` ``TRUE``,`\
`  gwet ``=`` ``TRUE``,`\
`  allPairsKappa ``=`` ``TRUE`\
`)`\
\
`res``$``irrtable``$``asDF``                          ``# Fleiss' kappa`\
`#>        method subjects raters peragree     kappa ci_lower  ci_upper        z`\
`#> "1" Fleiss' κ      250      3 76.30522 0.6512801 0.572085 0.7304752 16.19697`\
`#>                p`\
`#> "1" 8.688896e-41`\
`res``$``krippTableGroup``$``krippTable``$``asDF``        ``# Krippendorff's alpha`\
`#>                             method subjects raters     alpha`\
`#> "1" Krippendorff's Alpha (nominal)      250      3 0.6540881`\
`#>                                interpretation`\
`#> "1" Insufficient agreement - discard variable`\
`res``$``gwetGroup``$``gwetTable``$``asDF``               ``# Gwet's AC1`\
`#>                      method subjects raters coefficient      se ci_lower`\
`#> "1" Gwet's AC1 (unweighted)      250      3     0.69976 0.03545     0.63`\
`#>     ci_upper           p`\
`#> "1"     0.77 7.61843e-53`\
`res``$``allPairsKappaTable``$``asDF``                ``# Cohen's kappa for every pair`\
`#>       rater_a rater_b   n  peragree     kappa         se  ci_lower  ci_upper`\
`#> "1_2" Rater 1 Rater 2 249 0.9196787 0.8205535 0.03832152 0.7454447 0.8956623`\
`#> "1_3" Rater 1 Rater 3 249 0.8433735 0.6661395 0.04800118 0.5720589 0.7602201`\
`#> "2_3" Rater 2 Rater 3 250 0.7600000 0.4943707 0.05604538 0.3845237 0.6042176`\
`#>               z             p`\
`#> "1_2" 21.412343 1.025272e-101`\
`#> "1_3" 13.877566  8.663573e-44`\
`#> "2_3"  8.820899  1.135447e-18`

Several tables live inside result groups, so the path has two parts
(`res$krippTableGroup$krippTable`, `res$gwetGroup$gwetTable`,
`res$iccGroup$iccTable`).

## Ordinal ratings: weighted kappa

For two raters scoring an ordered scale, weighted kappa gives partial
credit for near-misses. `wght = "squared"` (quadratic weights) is the
usual choice for grades.

\
`res_w`` ``<-`` `[`agreement`](https://www.serdarbalci.com/meddecide/reference/agreement.md)`(`\
`  data ``=`` ``histopathology``,`\
`  vars ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Rater A"``, ``"Rater B"``)``,`\
`  wght ``=`` ``"squared"`\
`)`\
`res_w``$``irrtable``$``asDF`\
`#>                   method subjects raters peragree     kappa  ci_lower  ci_upper`\
`#> "1" Quadratic-weighted κ      250      2     58.8 0.4005073 0.2832064 0.5178081`\
`#>            z            p`\
`#> "1" 6.376624 1.810345e-10`

## Continuous measurements: ICC and Lin’s CCC

\
`res_c`` ``<-`` `[`agreement`](https://www.serdarbalci.com/meddecide/reference/agreement.md)`(`\
`  data ``=`` ``histopathology``,`\
`  vars ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Measurement1"``, ``"Measurement2"``)``,`\
`  icc ``=`` ``TRUE``,`\
`  iccType ``=`` ``"icc21"``,`\
`  linCCC ``=`` ``TRUE``,`\
`  blandAltmanPlot ``=`` ``TRUE`\
`)`\
`res_c``$``iccGroup``$``iccTable``$``asDF`\
`#>                                 model subjects raters icc_value   ci_lower`\
`#> "1" ICC(2,1) - Two-way random, single      250      2 0.1718531 0.04903747`\
`#>      ci_upper  f_value df1 df2           p`\
`#> "1" 0.2895482 1.414754 249 249 0.003187137`\
`res_c``$``iccGroup``$``linCCCTable``$``asDF`\
`#>                         comparison subjects       ccc   ci_lower  ci_upper`\
`#> "1_2" Measurement1 vs Measurement2      250 0.1712834 0.06751243 0.2713883`\
`#>       pearson_r bias_factor   interpretation`\
`#> "1_2" 0.2011813   0.8513884 Poor concordance`

Pick the ICC model from the study design (Shrout & Fleiss 1979; McGraw &
Wong 1996):

| `iccType` | Model | Use when |
|----|----|----|
| `icc11` / `icc1k` | One-way random effects | each case is rated by a different set of raters |
| `icc21` / `icc2k` | Two-way random effects, absolute agreement | the same raters rate every case and are a sample of possible raters |
| `icc31` / `icc3k` | Two-way mixed effects, consistency | the same fixed raters rate every case and only their ranking matters |

The `1` forms give the reliability of a single rater; the `k` forms give
the reliability of the mean of the k raters, which is always higher.

## Rater clustering

`raterClustering = TRUE` groups raters by how alike they rate. See
[Diagnostic Style
Clustering](https://www.serdarbalci.com/meddecide/articles/15-diagnostic-style-clustering.md).

## Interpreting kappa

Landis and Koch (1977) proposed these descriptive bands. They are a
convention, not a validated clinical threshold; always report the
confidence interval.

| Kappa       | Landis & Koch label |
|-------------|---------------------|
| \< 0        | Poor                |
| 0.00 - 0.20 | Slight              |
| 0.21 - 0.40 | Fair                |
| 0.41 - 0.60 | Moderate            |
| 0.61 - 0.80 | Substantial         |
| 0.81 - 1.00 | Almost perfect      |

For the ICC, Koo and Li (2016) suggest \< 0.50 poor, 0.50 - 0.75
moderate, 0.75 - 0.90 good and \> 0.90 excellent, judged on the 95%
confidence interval.

Kappa depends on prevalence: with one very common category, kappa can be
low while percent agreement is high (the “kappa paradox”). Report
percent agreement alongside kappa, and consider Gwet’s AC1 or PABAK.

## Sample size

To plan an agreement study, use the kappa sample-size tools under
jamovi’s **Power** menu:
[`kappaSizeCI()`](https://www.serdarbalci.com/meddecide/reference/kappaSizeCI.md),
[`kappaSizePower()`](https://www.serdarbalci.com/meddecide/reference/kappaSizePower.md)
and
[`kappaSizeFixedN()`](https://www.serdarbalci.com/meddecide/reference/kappaSizeFixedN.md).

## References

- Landis JR, Koch GG. The measurement of observer agreement for
  categorical data. *Biometrics*. 1977;33:159-174.
- Shrout PE, Fleiss JL. Intraclass correlations: uses in assessing rater
  reliability. *Psychol Bull*. 1979;86:420-428.
- McGraw KO, Wong SP. Forming inferences about some intraclass
  correlation coefficients. *Psychol Methods*. 1996;1:30-46.
- Koo TK, Li MY. A guideline of selecting and reporting intraclass
  correlation coefficients for reliability research. *J Chiropr Med*.
  2016;15:155-163.
- Gwet KL. Computing inter-rater reliability and its variance in the
  presence of high agreement. *Br J Math Stat Psychol*. 2008;61:29-48.
- Krippendorff K. *Content Analysis: An Introduction to Its
  Methodology*. 4th ed. Sage; 2018.
