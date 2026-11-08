# Choosing and interpreting a meddecide analysis

## Choose the question before the statistic

| Question | Analysis | Main condition or limitation |
|----|----|----|
| How accurate is one binary test? | `decision` | Specify both reference and test levels; the reference must support an accuracy claim. |
| What follows from four diagnostic counts? | `decisioncalculator` | Counts must describe the same population and reference; uncertainty in an externally supplied prevalence is not automatically propagated. |
| How do two tests combine under assumed accuracy? | `cotest` | Dependence is specified separately within disease groups; an arbitrary dependence value is not an estimate from paired observations. |
| What is the workload of a two-stage strategy? | `sequentialtests` | Combined accuracy assumes conditional independence. Entered accuracy, prevalence and costs are treated as fixed inputs. |
| How do observed combinations perform? | `decisioncombine` | Uses observed paired patterns, rather than multiplying marginal accuracies. Single-test rows use cases complete across selected tests. |
| Do tests differ on the same patients? | `decisioncompare` | Paired comparisons use the relevant complete pairs; per-test estimates can have different denominators. Independent rows are required. |
| What can imperfect tests tell us without a reference? | `nogoldstandard` | Latent methods require at least three tests; self-built reference rules describe agreement rather than diagnostic accuracy. |
| Which marker discriminates and at which cutpoint? | `enhancedROC` | AUC does not measure calibration; selected cutpoints have apparent performance. Frozen-model validation needs a locked model and appropriate validation data. |
| How do ROC markers or cutpoint methods compare? | `psychopdaROC` | Fix outcome coding and direction; patient summaries require a consistent outcome within patient. NRI/IDI based on probabilities require appropriate probability inputs. |
| Does a risk-based action improve net benefit? | `decisioncurve` | Supply risks on a 0–1 scale for a defined binary outcome and horizon. This analysis does not handle censoring. |
| How can predictors be combined? | `lassologistic` | Penalized coefficients have no conventional coefficient p-values here. Penalty selection by CV and performance validation are separate steps. |
| How reproducible are ratings? | `agreement` | Choose categorical, ordinal or continuous methods to match the scale and study design. Agreement with a rater does not establish accuracy against disease. |
| How many subjects for expected kappa limits? | `kappaSizeCI` | Confidence-limit planning, without a hypothesis test or a power guarantee. |
| How many subjects to test a null kappa? | `kappaSizePower` | Two-sided goodness-of-fit test under the common-correlation model; approximation and achieved-power warnings matter. |
| What lower kappa limit is expected with fixed N? | `kappaSizeFixedN` | Expected one-sided confidence bound, rather than power or a guaranteed minimum observed kappa. |

## Diagnostic accuracy and prevalence

With TP, FN, FP and TN denoting the four cells, sensitivity is
TP/(TP+FN), specificity is TN/(TN+FP), and observed PPV is TP/(TP+FP).
At target prevalence $`p`$, transporting sensitivity $`Se`$ and
specificity $`Sp`$ gives

``` math
PPV(p)=\frac{Se\,p}{Se\,p+(1-Sp)(1-p)},\qquad
NPV(p)=\frac{Sp(1-p)}{Sp(1-p)+(1-Se)p}.
```

Transport also assumes these accuracy estimates apply to the target
population. Changing prevalence cannot repair spectrum bias,
incorporation bias or selective verification. A ratio with denominator
zero is undefined. Zero-cell handling for likelihood ratios is
method-specific; read the displayed correction note.

\
`se`` ``<-`` ``0.80``; ``sp`` ``<-`` ``0.90``; ``p`` ``<-`` ``0.01`\
[`c`](https://rdrr.io/r/base/c.html)`(``PPV ``=`` ``se``*``p``/``(``se``*``p``+``(``1``-``sp``)``*``(``1``-``p``)``)``,`\
`  NPV ``=`` ``sp``*``(``1``-``p``)``/``(``sp``*``(``1``-``p``)``+``(``1``-``se``)``*``p``)``)`\
`#>        PPV        NPV `\
`#> 0.07476636 0.99776036`

Here a positive test has a predictive value of about 7.5%, despite 80%
sensitivity and 90% specificity. A false-positive rate of 10% applies to
people without disease; it is not the probability that a positive result
is false.

The diagnostic analyses do not all use the same interval construction.
Exact Clopper–Pearson and Wilson intervals can legitimately differ for
the same proportion. Select the same population, coding, denominator and
interval method before comparing outputs.
[`cotest()`](https://www.serdarbalci.com/meddecide/reference/cotest.md)
and
[`sequentialtests()`](https://www.serdarbalci.com/meddecide/reference/sequentialtests.md)
accept prevalence from 0.001 to 0.999; very rare-disease scenarios
outside that range are refused.
[`decisioncompare()`](https://www.serdarbalci.com/meddecide/reference/decisioncompare.md)
refuses simultaneous population-prevalence adjustment and confidence
intervals; it does not supply transported uncertainty for that
combination. Repeated observations require analysis at the patient level
or a method that accounts for clustering.

## Combining tests

Under conditional independence, an AND rule has sensitivity $`Se_1Se_2`$
and specificity $`1-(1-Sp_1)(1-Sp_2)`$. An OR rule has sensitivity
$`1-(1-Se_1)(1-Se_2)`$ and specificity $`Sp_1Sp_2`$. These are
conditional on disease status; an unconditional correlation between the
two tests does not establish the needed assumption. Use observed paired
patterns when available, and sensitivity analysis when dependence is
uncertain.

## ROC analysis and prediction

AUC measures rank discrimination. AUC 0.5 does not establish that a
marker has no possible clinical use, and broad adjectives such as
“excellent” are not clinical acceptance thresholds. Check uncertainty,
direction, calibration and the consequences of errors. Youden’s index
weights sensitivity and specificity equally and does not incorporate
prevalence or clinical costs.

Optimizing a cutpoint and reporting its sensitivity on the same data is
development. Bootstrap intervals around apparent performance do not
automatically remove selection optimism. Lock the model, preprocessing,
outcome definition, prediction horizon and threshold before independent
validation.

For LASSO, the displayed training AUC remains apparent even when
cross-validation selected lambda. Bootstrap optimism correction can
leave residual optimism, especially with model and penalty selection in
modest samples. It is internal validation and does not validate a
simplified points score or a new clinical population. Penalized odds
ratios describe shrunk model coefficients, rather than causal effects.

## Decision curves

At threshold probability $`t`$,

``` math
NB(t)=TP/n-FP/n\times t/(1-t).
```

Treat-none has NB zero; treat-all has NB $`p-(1-p)t/(1-t)`$. The
threshold represents the relative consequences of a false positive and a
true positive. Choose a clinically defensible range before looking at
the curves. Do not feed an uncalibrated score as though it were a risk.
Net benefit here uses the observed event fraction. A case-control
sampling fraction is not a population event rate; this analysis has no
prevalence-weighting correction for that design. A warning based on an
outcome ratio cannot identify every case-control sample.

\
`# 100 independent patients; at t=0.20 a model identifies 15 events and 20 non-events.`\
`t`` ``<-`` ``0.20`\
[`c`](https://rdrr.io/r/base/c.html)`(``model ``=`` ``15``/``100`` ``-`` ``20``/``100``*``t``/``(``1``-``t``)``,`\
`  treat_all ``=`` ``0.20`` ``-`` ``0.80``*``t``/``(``1``-``t``)``, treat_none ``=`` ``0``)`\
`#>         model     treat_all    treat_none `\
`#>  1.000000e-01 -2.775558e-17  0.000000e+00`

The model’s net benefit is 0.10 per patient under these utilities. This
does not mean ten lives saved per 100 patients. Interventions avoided
are a utility-scaled comparison with treat-all, rather than a measured
clinical outcome. A pointwise interval clearing the treat-all estimate
is not a paired test of their difference.

The definition follows [Vickers and Elkin
(2006)](https://pubmed.ncbi.nlm.nih.gov/17099194/).

## Agreement and study size

Kappa depends on the marginal category frequencies. Weighted kappa also
depends on the order and weights assigned to categories. ICC needs a
stated model, agreement/consistency target, and single/average-measure
estimand. Correlation alone does not measure agreement, and Bland–Altman
limits describe differences on the measurement scale.

The three kappa planners assume a common-correlation, common-margin
rating model. With two raters and equal margins its kappa coincides with
Cohen’s kappa; unequal rater margins, weighted kappa, missing ratings
and clustered specimens need design-specific planning. Increasing the
number of raters does not simply multiply the number of independent
subjects.

| Function | Meaning of `kappa0` | What the result provides |
|----|----|----|
| `kappaSizeCI` | Anticipated kappa | N needed for specified expected goodness-of-fit confidence limits |
| `kappaSizeFixedN` | Anticipated kappa | Expected one-sided lower confidence bound at fixed N |
| `kappaSizePower` | Null kappa | N for a two-sided test against alternative `kappa1` |

The realized confidence interval varies between studies. Planning its
expected limits does not guarantee that a future interval lies inside
those limits. Read the [kappaSize reference
manual](https://cran.r-project.org/web/packages/kappaSize/kappaSize.pdf)
and the module’s approximation and sparse-cell notes; confirm demanding
designs by simulation of the analysis you intend to use.

## Without a gold standard

Two latent classes are unlabeled. A high-positive class is not
automatically disease. With three binary tests there are seven
independent response-pattern probabilities and seven model parameters:
one class proportion and six response probabilities. Such a model has
zero residual degrees of freedom. A good fit or non-significant residual
check therefore cannot establish conditional independence. Extra tests
permit some checks but do not prove the assumption.

The method named `bayesian` in R is fixed-prior penalized EM/MAP point
estimation. It does not sample a posterior; bootstrap confidence
intervals are not posterior credible intervals. Reference rules that
include the evaluated test have incorporation bias and provide agreement
with that rule, not disease accuracy.

See the [worked
example](https://www.serdarbalci.com/meddecide/articles/12-nogoldstandard.md)
and a [simulation study of dependence
diagnostics](https://pubmed.ncbi.nlm.nih.gov/39639189/).

## What to report

Report the source population, independent observation unit, reference
and outcome coding, exclusions, missingness, model or threshold
provenance, estimator and interval method, uncertainty, and whether
performance is apparent, internally validated or independently
validated. Teaching scenarios and simulated data illustrate the
calculation; they do not supply clinical recommendations.
