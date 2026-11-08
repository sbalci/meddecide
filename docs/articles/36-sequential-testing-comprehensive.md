# Sequential Testing Analysis: A Comprehensive Guide

## Introduction

Sequential testing analysis is a powerful approach for optimizing
diagnostic accuracy by combining multiple tests in systematic ways. This
guide demonstrates how to use the Sequential Testing Analysis module to
design, evaluate, and optimize diagnostic protocols across various
clinical scenarios.

### Key Learning Objectives

After reading this guide, you will understand:

- The three main sequential testing strategies and when to use each
- How test characteristics interact in different combinations
- Clinical applications across medical specialties
- Cost-effectiveness considerations in test sequencing
- How to interpret and apply Fagan nomograms for sequential testing
- Practical implementation in clinical decision-making

### What Makes Sequential Testing Important

Sequential testing addresses fundamental challenges in clinical
diagnosis:

- **Single tests are often insufficient** for complex clinical decisions
- **Balancing sensitivity and specificity** requires strategic test
  combinations
- **Cost-effectiveness** demands optimal use of expensive confirmatory
  tests
- **Clinical workflows** benefit from systematic diagnostic protocols
- **Patient outcomes** improve with more accurate diagnostic strategies

## Understanding Sequential Testing Strategies

### The Three Core Strategies

#### 1. Serial Positive Testing (Confirmation Strategy)

**Approach**: Perform second test only if first test is positive
**Result interpretation**: Positive only if both tests are positive
**Effect**: Maximizes specificity, reduces sensitivity

**Best for**: - Avoiding false positives when consequences are serious -
Expensive or invasive confirmatory tests - High-stakes diagnoses (e.g.,
cancer, genetic diseases)

#### 2. Serial Negative Testing (Exclusion Strategy)

**Approach**: Perform second test only if first test is negative
**Result interpretation**: Positive if either test is positive
**Effect**: Maximizes sensitivity, reduces specificity

**Best for**: - Cannot afford to miss cases - Screening for serious
conditions - Complementary tests detecting different disease
manifestations

#### 3. Parallel Testing

**Approach**: Perform both tests on all subjects **Result
interpretation**: Positive if either test is positive **Effect**:
Improves sensitivity, reduces specificity

**Best for**: - Emergency situations requiring rapid diagnosis -
Comprehensive evaluation protocols - When tests are quick and
inexpensive

### Mathematical Framework

#### Combined Sensitivity and Specificity

**Serial Positive Strategy**:

    Combined Sensitivity = Se₁ × Se₂
    Combined Specificity = Sp₁ + (1-Sp₁) × Sp₂

**Serial Negative Strategy**:

    Combined Sensitivity = Se₁ + (1-Se₁) × Se₂
    Combined Specificity = Sp₁ × Sp₂

**Parallel Strategy**:

    Combined Sensitivity = Se₁ + Se₂ - (Se₁ × Se₂)
    Combined Specificity = Sp₁ × Sp₂

## Example Data and Clinical Scenarios

Named scenarios, costs and accuracy values in this guide are
hypothetical teaching inputs. They are not clinical guidelines or
validated pathways. Combined accuracy assumes conditional independence
within disease groups, and uncertainty in the entered parameters is not
propagated. See [Choosing and interpreting an
analysis](https://www.serdarbalci.com/meddecide/articles/17-methods-and-interpretation.md).

### Loading the Example Datasets

These example datasets are distributed with the umbrella **ClinicoPath**
package (<https://github.com/sbalci/ClinicoPathJamoviModule>), not with
meddecide:

\
`# Load all sequential testing datasets`\
[`data`](https://rdrr.io/r/utils/data.html)`(``sequential_testing_examples``, package ``=`` ``"ClinicoPath"``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``strategy_comparison``, package ``=`` ``"ClinicoPath"``)`` `\
[`data`](https://rdrr.io/r/utils/data.html)`(``cost_effectiveness_examples``, package ``=`` ``"ClinicoPath"``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``teaching_examples``, package ``=`` ``"ClinicoPath"``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``common_test_combinations``, package ``=`` ``"ClinicoPath"``)`\
\
`# Display overview of main clinical scenarios`\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``sequential_testing_examples``[``1``:``5``, `[`c`](https://rdrr.io/r/base/c.html)`(``"scenario"``, ``"clinical_setting"``, ``"strategy"``, ``"combined_sens"``, ``"combined_spec"``)``]``, `\
`      caption ``=`` ``"Sample Sequential Testing Scenarios"``,`\
`      digits ``=`` ``3``)`

### COVID-19 Testing: A Modern Example

Let’s examine how COVID-19 testing demonstrates sequential testing
principles:

\
`covid_data`` ``<-`` ``sequential_testing_examples``[`\
`  ``sequential_testing_examples``$``scenario`` ``==`` ``"COVID-19 Testing"``, ``]`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``covid_data``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"clinical_setting"``, ``"prevalence"``, ``"test1_ppv"``, ``"combined_ppv"``, ``"strategy_benefit"``)``]``,`\
`      caption ``=`` ``"COVID-19 Testing: Impact of Sequential Testing"``,`\
`      digits ``=`` ``3``)`

#### Key Insights:

1.  **Community screening** (2% prevalence): Rapid test alone has 26%
    PPV, combined strategy improves confidence
2.  **Contact tracing** (15% prevalence): Higher prevalence improves PPV
    significantly
3.  **Symptomatic patients** (40% prevalence): High prevalence leads to
    excellent combined PPV

This demonstrates how prevalence dramatically affects the value of
sequential testing strategies.

### Cancer Screening: The Classic Use Case

Cancer screening exemplifies serial positive testing:

\
`cancer_data`` ``<-`` ``sequential_testing_examples``[`\
`  `[`grepl`](https://rdrr.io/r/base/grep.html)`(``"Cancer"``, ``sequential_testing_examples``$``scenario``)``, ``]`\
\
`cancer_summary`` ``<-`` ``cancer_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``scenario``, ``test1_name``, ``test2_name``, ``prevalence``, ``test1_ppv``, ``combined_ppv``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    ppv_improvement ``=`` ``combined_ppv`` ``-`` ``test1_ppv``,`\
`    fold_improvement ``=`` ``combined_ppv`` ``/`` ``test1_ppv`\
`  ``)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``cancer_summary``,`\
`      caption ``=`` ``"Cancer Screening: Serial Positive Strategy Benefits"``,`\
`      digits ``=`` ``3``)`

\
`cancer_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``scenario``, ``test1_ppv``, ``combined_ppv``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  ``pivot_longer``(``cols ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``test1_ppv``, ``combined_ppv``)``, `\
`               names_to ``=`` ``"test_stage"``, values_to ``=`` ``"ppv"``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``test_stage ``=`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``test_stage`` ``==`` ``"test1_ppv"``, ``"Screening Test"``, ``"Combined Strategy"``)``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  ``ggplot``(``aes``(``x ``=`` ``scenario``, y ``=`` ``ppv``, fill ``=`` ``test_stage``)``)`` ``+`\
`  ``geom_col``(``position ``=`` ``"dodge"``)`` ``+`\
`  ``scale_y_continuous``(``labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`)`` ``+`\
`  ``labs``(``title ``=`` ``"Cancer Screening: PPV Improvement Through Sequential Testing"``,`\
`       x ``=`` ``"Cancer Type"``, y ``=`` ``"Positive Predictive Value"``, fill ``=`` ``"Test Stage"``)`` ``+`\
`  ``theme_minimal``(``)`` ``+`\
`  ``theme``(``axis.text.x ``=`` ``element_text``(``angle ``=`` ``45``, hjust ``=`` ``1``)``)`

## Strategy Comparison Analysis

### Comparing All Three Strategies

\
`# Filter for a specific test combination at different prevalences`\
`strategy_subset`` ``<-`` ``strategy_comparison`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``test1_sens`` ``==`` ``0.90``, ``test1_spec`` ``==`` ``0.85``, `\
`         ``test2_sens`` ``==`` ``0.85``, ``test2_spec`` ``==`` ``0.95``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``strategy``, ``prevalence``, ``combined_sens``, ``combined_spec``, ``combined_ppv``, ``combined_npv``)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``strategy_subset``, `\
`      caption ``=`` ``"Strategy Comparison: Same Tests, Different Approaches"``,`\
`      digits ``=`` ``3``)`

\
`strategy_subset`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  ``pivot_longer``(``cols ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``combined_ppv``, ``combined_npv``)``, `\
`               names_to ``=`` ``"metric"``, values_to ``=`` ``"value"``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``metric ``=`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``metric`` ``==`` ``"combined_ppv"``, ``"PPV"``, ``"NPV"``)``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  ``ggplot``(``aes``(``x ``=`` ``prevalence``, y ``=`` ``value``, color ``=`` ``strategy``, linetype ``=`` ``metric``)``)`` ``+`\
`  ``geom_line``(``size ``=`` ``1.2``)`` ``+`\
`  ``geom_point``(``size ``=`` ``3``)`` ``+`\
`  ``scale_y_continuous``(``labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`)`` ``+`\
`  ``scale_x_continuous``(``labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`)`` ``+`\
`  ``labs``(``title ``=`` ``"Sequential Testing Strategies: Performance Across Prevalence"``,`\
`       x ``=`` ``"Disease Prevalence"``, y ``=`` ``"Predictive Value"``, `\
`       color ``=`` ``"Strategy"``, linetype ``=`` ``"Metric"``)`` ``+`\
`  ``theme_minimal``(``)`

### Illustrative strategy trade-offs

\
`guidelines`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Strategy ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Serial Positive"``, ``"Serial Negative"``, ``"Parallel"``)``,`\
``   `Primary Goal`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Minimize false positives"``, ``"Minimize false negatives"``, ``"Comprehensive evaluation"``)``,`\
``   `Positive Rule`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Both tests positive"``, ``"At least one test positive"``, ``"At least one test positive"``)``,`\
``   `Trade-off`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Lower sensitivity"``, ``"Lower specificity"``, ``"Higher cost"``)``,`\
``   `Testing Workload`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Second test after first positive"``, ``"Second test after first negative"``, ``"Both tests for everyone"``)``,`\
`  check.names ``=`` ``FALSE`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``guidelines``, caption ``=`` ``"Illustrative Boolean rules and workload; not clinical recommendations"``)`

## Clinical Applications by Specialty

### Infectious Disease Testing

\
`infectious_data`` ``<-`` ``sequential_testing_examples``[`\
`  ``sequential_testing_examples``$``scenario`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"COVID-19 Testing"``, ``"Tuberculosis Screening"``)``, ``]`\
\
`infectious_summary`` ``<-`` ``infectious_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``scenario``, ``strategy``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    settings ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    avg_sensitivity ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``combined_sens``)``,`\
`    avg_specificity ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``combined_spec``)``,`\
`    avg_ppv ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``combined_ppv``)`\
`  ``)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``infectious_summary``, `\
`      caption ``=`` ``"Infectious Disease Sequential Testing"``,`\
`      digits ``=`` ``3``)`

#### TB Screening Example

TB screening demonstrates how prevalence affects strategy choice:

\
`tb_data`` ``<-`` ``sequential_testing_examples``[`\
`  ``sequential_testing_examples``$``scenario`` ``==`` ``"Tuberculosis Screening"``, ``]`\
\
`ggplot``(``tb_data``, ``aes``(``x ``=`` ``prevalence``, y ``=`` ``combined_ppv``)``)`` ``+`\
`  ``geom_point``(``aes``(``color ``=`` ``clinical_setting``)``, size ``=`` ``4``)`` ``+`\
`  ``geom_smooth``(``method ``=`` ``"loess"``, se ``=`` ``FALSE``)`` ``+`\
`  ``scale_x_continuous``(``labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`)`` ``+`\
`  ``scale_y_continuous``(``labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`)`` ``+`\
`  ``labs``(``title ``=`` ``"TB Screening: PPV vs Prevalence in Different Populations"``,`\
`       x ``=`` ``"TB Prevalence"``, y ``=`` ``"Combined PPV"``, color ``=`` ``"Population"``)`` ``+`\
`  ``theme_minimal``(``)`

### Emergency Medicine: Parallel Testing

\
`emergency_data`` ``<-`` ``sequential_testing_examples``[`\
`  ``sequential_testing_examples``$``scenario`` ``==`` ``"Myocardial Infarction Rule-out"``, ``]`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``emergency_data``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"clinical_setting"``, ``"combined_sens"``, ``"combined_npv"``, ``"clinical_impact"``)``]``,`\
`      caption ``=`` ``"Emergency Medicine: Parallel Testing for MI Rule-out"``,`\
`      digits ``=`` ``3``)`

### Cardiology: Risk Stratification

\
`cardiac_data`` ``<-`` ``sequential_testing_examples``[`\
`  ``sequential_testing_examples``$``scenario`` ``==`` ``"Coronary Artery Disease"``, ``]`\
\
`cardiac_analysis`` ``<-`` ``cardiac_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    risk_category ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``prevalence`` ``<`` ``0.20`` ``~`` ``"Low Risk"``,`\
`      ``prevalence`` ``<`` ``0.30`` ``~`` ``"Intermediate Risk"``,`\
`      ``TRUE`` ``~`` ``"High Risk"`\
`    ``)`\
`  ``)`\
\
`ggplot``(``cardiac_analysis``, ``aes``(``x ``=`` ``combined_sens``, y ``=`` ``combined_spec``, color ``=`` ``risk_category``)``)`` ``+`\
`  ``geom_point``(``size ``=`` ``4``)`` ``+`\
`  ``scale_x_continuous``(``labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`)`` ``+`\
`  ``scale_y_continuous``(``labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`)`` ``+`\
`  ``labs``(``title ``=`` ``"Cardiac Testing: Sensitivity-Specificity by Risk Category"``,`\
`       x ``=`` ``"Combined Sensitivity"``, y ``=`` ``"Combined Specificity"``, color ``=`` ``"Risk Category"``)`` ``+`\
`  ``theme_minimal``(``)`

## Cost-Effectiveness Analysis

### Economic Considerations

\
[`data`](https://rdrr.io/r/utils/data.html)`(``cost_effectiveness_examples``, package ``=`` ``"ClinicoPath"``)`\
\
`# Calculate additional metrics`\
`cost_analysis`` ``<-`` ``cost_effectiveness_examples`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    cost_per_person_serial ``=`` ``serial_total_cost`` ``/`` ``population_size``,`\
`    cost_per_person_parallel ``=`` ``parallel_total_cost`` ``/`` ``population_size``,`\
`    savings_per_person ``=`` ``cost_savings`` ``/`` ``population_size``,`\
`    savings_percent ``=`` ``(``cost_savings`` ``/`` ``parallel_total_cost``)`` ``*`` ``100`\
`  ``)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``cost_analysis``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"scenario"``, ``"cost_per_person_serial"``, ``"cost_per_person_parallel"``, `\
`                       ``"savings_percent"``, ``"cost_per_case_found"``)``]``,`\
`      caption ``=`` ``"Cost-Effectiveness of Sequential Testing Strategies"``,`\
`      digits ``=`` ``2``)`

\
`cost_comparison`` ``<-`` ``cost_effectiveness_examples`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``scenario``, ``serial_total_cost``, ``parallel_total_cost``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  ``pivot_longer``(``cols ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``serial_total_cost``, ``parallel_total_cost``)``,`\
`               names_to ``=`` ``"strategy"``, values_to ``=`` ``"total_cost"``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``strategy ``=`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(`[`grepl`](https://rdrr.io/r/base/grep.html)`(``"serial"``, ``strategy``)``, ``"Serial Positive"``, ``"Parallel"``)``)`\
\
`ggplot``(``cost_comparison``, ``aes``(``x ``=`` ``scenario``, y ``=`` ``total_cost``, fill ``=`` ``strategy``)``)`` ``+`\
`  ``geom_col``(``position ``=`` ``"dodge"``)`` ``+`\
`  ``scale_y_continuous``(``labels ``=`` ``scales``::`[`dollar`](https://scales.r-lib.org/reference/dollar_format.html)`)`` ``+`\
`  ``labs``(``title ``=`` ``"Cost Comparison: Serial vs Parallel Testing"``,`\
`       subtitle ``=`` ``"Based on 1,000 person population"``,`\
`       x ``=`` ``"Clinical Scenario"``, y ``=`` ``"Total Testing Cost"``, fill ``=`` ``"Strategy"``)`` ``+`\
`  ``theme_minimal``(``)`` ``+`\
`  ``theme``(``axis.text.x ``=`` ``element_text``(``angle ``=`` ``45``, hjust ``=`` ``1``)``)`

### Cost-Effectiveness Calculations

\
`# Calculate incremental cost-effectiveness`\
`cost_effectiveness_examples`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    diseased_population ``=`` ``population_size`` ``*`` ``prevalence``,`\
`    cases_found_serial ``=`` ``diseased_population`` ``*`` ``test1_sens`` ``*`` ``test2_sens``,`\
`    incremental_cost ``=`` ``serial_total_cost`` ``-`` ``(``population_size`` ``*`` ``test1_cost``)``,`\
`    incremental_cases ``=`` ``cases_found_serial`` ``-`` ``(``diseased_population`` ``*`` ``test1_sens``)``,`\
`    icer ``=`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``incremental_cases`` ``>`` ``0``, ``incremental_cost`` ``/`` ``incremental_cases``, ``NA``)`\
`  ``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``scenario``, ``incremental_cost``, ``incremental_cases``, ``icer``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``caption ``=`` ``"Incremental Cost-Effectiveness of Adding Second Test"``,`\
`        digits ``=`` ``0``)`

## Advanced Topics

### Fagan Nomograms for Sequential Testing

Sequential Fagan nomograms help visualize how probability changes
through multiple testing stages:

\
`# Example: COVID-19 testing progression`\
`covid_example`` ``<-`` ``sequential_testing_examples``[``1``, ``]`\
\
`nomogram_data`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Stage ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Pre-test"``, ``"After Rapid Test (+)"``, ``"After RT-PCR (+)"``)``,`\
`  Probability ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``covid_example``$``prevalence``,`\
`    ``covid_example``$``test1_ppv``,`\
`    ``covid_example``$``combined_ppv`\
`  ``)``,`\
`  Test ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Clinical assessment"``, ``"Rapid antigen"``, ``"RT-PCR confirmation"``)``,`\
`  LR ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``NA``, ``covid_example``$``test1_plr``, ``covid_example``$``test2_plr``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``nomogram_data``, `\
`      caption ``=`` ``"Probability Evolution in COVID-19 Sequential Testing"``,`\
`      digits ``=`` ``3``)`

### Population Flow Analysis

Understanding how patients flow through sequential testing:

\
`# Simulate population flow for breast cancer screening`\
`pop_size`` ``<-`` ``10000`\
`prevalence`` ``<-`` ``0.008`\
`sens1`` ``<-`` ``0.80``  ``# Mammography`\
`spec1`` ``<-`` ``0.90`\
`sens2`` ``<-`` ``0.95``  ``# Biopsy`\
`spec2`` ``<-`` ``0.98`\
\
`# Calculate flow`\
`diseased`` ``<-`` ``pop_size`` ``*`` ``prevalence`\
`healthy`` ``<-`` ``pop_size`` ``-`` ``diseased`\
\
`# After mammography`\
`mammo_tp`` ``<-`` ``diseased`` ``*`` ``sens1`\
`mammo_fp`` ``<-`` ``healthy`` ``*`` ``(``1`` ``-`` ``spec1``)`\
`mammo_pos`` ``<-`` ``mammo_tp`` ``+`` ``mammo_fp`\
\
`# After biopsy (serial positive strategy)`\
`biopsy_tp`` ``<-`` ``mammo_tp`` ``*`` ``sens2`\
`biopsy_fp`` ``<-`` ``mammo_fp`` ``*`` ``(``1`` ``-`` ``spec2``)`\
\
`flow_data`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Stage ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Initial Population"``, ``"Mammography Positive"``, ``"Biopsy Positive"``)``,`\
`  Total ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``pop_size``, ``mammo_pos``, ``biopsy_tp`` ``+`` ``biopsy_fp``)``,`\
``   `True Positive`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(``diseased``, ``mammo_tp``, ``biopsy_tp``)``,`\
``   `False Positive`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``mammo_fp``, ``biopsy_fp``)``,`\
`  PPV ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``prevalence``, ``mammo_tp``/``mammo_pos``, ``biopsy_tp``/``(``biopsy_tp`` ``+`` ``biopsy_fp``)``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``flow_data``, `\
`      caption ``=`` ``"Population Flow: Breast Cancer Screening"``,`\
`      digits ``=`` ``3``)`

### Test Independence vs Dependence

Most sequential testing analysis assumes test independence, but
real-world tests may be correlated:

\
`correlation_scenarios`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Scenario ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Independent tests"``, ``"Positively correlated"``, ``"Negatively correlated"``)``,`\
`  Description ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Tests detect different disease aspects"``,`\
`    ``"Tests detect similar disease features"``,`\
`    ``"Tests detect complementary aspects"`\
`  ``)``,`\
``   `Expected Effect`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Standard calculations apply"``,`\
`    ``"Lower combined sensitivity/specificity than predicted"``,`\
`    ``"Higher combined sensitivity/specificity than predicted"`\
`  ``)``,`\
`  Example ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Troponin + ECG for MI"``,`\
`    ``"Two imaging modalities"``,`\
`    ``"Functional + anatomical tests"`\
`  ``)``,`\
`  check.names ``=`` ``FALSE`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``correlation_scenarios``, caption ``=`` ``"Test Correlation Effects"``)`

## Using the Module in jamovi

### Step-by-Step Guide

#### 1. **Basic Setup**

- Navigate to **meddecide** → **Decision Calculators** → **Sequential
  Testing Analysis**
- Enter test characteristics for both tests:
  - **First Test**: Name, sensitivity, specificity
  - **Second Test**: Name, sensitivity, specificity
  - **Disease prevalence** in your population

#### 2. **Strategy Selection**

Choose the appropriate testing strategy: - **Test all positives from
first test** (Serial positive) - **Test all negatives from first test**
(Serial negative)\
\- **Test all subjects with both tests (parallel)** (Parallel)

#### 3. **Display Options**

- **Explanations**: Detailed strategy explanations
- **Calculation formulas**: Step-by-step mathematics
- **Cost analysis**: Cost per case detected, when test costs are entered
- **Diagnostic plots**: Flow diagram, performance comparison,
  probability transformation, population flow, and PPV/NPV versus
  prevalence

The analysis has no Fagan nomogram option; the *Probability
Transformation* plot shows how the probability of disease changes after
each test.

#### 4. **Results Interpretation**

- **Summary Table**: Combined strategy performance
- **Individual Tests Table**: Comparison of individual test performance
- **Population Flow Table**: Patient flow through testing process

### Input Validation and Warnings

The module includes intelligent validation:

#### Error Conditions

- Test characteristics outside 0-1 range
- Missing test names
- Invalid prevalence values

#### Clinical Warnings

- Unusual test characteristics (sensitivity/specificity \<50% or \>99%)
- Extreme prevalence values
- Strategy-test mismatches (e.g., low-specificity confirmatory test)
- Poor test performance combinations

#### Strategy-Specific Guidance

- **Serial positive**: Second test should have higher specificity
- **Serial negative**: Second test should have higher sensitivity
- **Parallel**: Tests should be complementary

## Best Practices and Recommendations

### For Clinical Practice

#### 1. **Strategy Selection**

- **High-stakes diagnoses**: Use serial positive for confirmation
- **Cannot miss cases**: Use serial negative for comprehensive screening
- **Emergency situations**: Use parallel for rapid, sensitive diagnosis

#### 2. **Test Selection**

- **First test**: Should be practical, accessible, cost-effective
- **Second test**: Should complement first test’s weaknesses
- **Consider test correlation** and independence assumptions

#### 3. **Prevalence Considerations**

- **Low prevalence**: PPV will be low even with good tests
- **High prevalence**: NPV becomes less informative
- **Variable prevalence**: Strategy effectiveness changes dramatically

### For Research and Quality Improvement

#### 1. **Protocol Design**

- Model different strategies before implementation
- Consider cost-effectiveness alongside diagnostic accuracy
- Plan for different prevalence scenarios

#### 2. **Performance Monitoring**

- Track real-world performance vs predictions
- Monitor for test correlation effects
- Evaluate patient outcomes and satisfaction

#### 3. **Continuous Improvement**

- Regular review of test characteristics
- Update protocols based on new evidence
- Consider emerging diagnostic technologies

## Case Studies

### Case Study 1: Optimizing COVID-19 Testing Protocol

**Challenge**: Design testing protocol for hospital employee screening

**Parameters**: - Population: 5,000 employees - Expected prevalence:
3% - Available tests: Rapid antigen (Se=85%, Sp=95%), RT-PCR (Se=95%,
Sp=99%) - Constraints: Cost, turnaround time, accuracy

**Analysis**:

\
`# Calculate outcomes for different strategies`\
`covid_strategies`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Strategy ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Rapid only"``, ``"PCR only"``, ``"Rapid → PCR (pos)"``, ``"Both parallel"``)``,`\
`  Sensitivity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.85``, ``0.95``, ``0.85``*``0.95``, ``0.85`` ``+`` ``0.95`` ``-`` ``0.85``*``0.95``)``,`\
`  Specificity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.95``, ``0.99``, ``0.95`` ``+`` ``(``1``-``0.95``)``*``0.99``, ``0.95``*``0.99``)``,`\
`  Cost_per_person ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``25``, ``100``, ``25`` ``+`` ``0.08``*``100``, ``125``)``,`\
`  Turnaround_hours ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.5``, ``24``, ``24``, ``24``)`\
`)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    PPV ``=`` ``(``Sensitivity`` ``*`` ``0.03``)`` ``/`` ``(``Sensitivity`` ``*`` ``0.03`` ``+`` ``(``1``-``Specificity``)`` ``*`` ``0.97``)``,`\
`    NPV ``=`` ``(``Specificity`` ``*`` ``0.97``)`` ``/`` ``(``Specificity`` ``*`` ``0.97`` ``+`` ``(``1``-``Sensitivity``)`` ``*`` ``0.03``)`\
`  ``)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``covid_strategies``, caption ``=`` ``"COVID-19 Testing Strategy Comparison"``, digits ``=`` ``3``)`

**Recommendation**: Serial positive strategy balances accuracy, cost,
and operational feasibility.

### Case Study 2: Breast Cancer Screening Optimization

**Challenge**: Optimize screening protocol for women aged 50-69

**Considerations**: - Cancer prevalence: 0.8% - Available tests: Digital
mammography, 3D tomosynthesis, MRI, biopsy - Goals: Maximize cancer
detection, minimize unnecessary procedures

\
`# Compare different screening approaches`\
`breast_strategies`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Approach ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"2D mammography only"``, ``"3D tomosynthesis only"``, ``"2D → biopsy"``, ``"3D → biopsy"``, ``"2D + 3D → biopsy"``)``,`\
`  First_test_sens ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.80``, ``0.85``, ``0.80``, ``0.85``, ``0.90``)``,`\
`  First_test_spec ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.90``, ``0.92``, ``0.90``, ``0.92``, ``0.88``)``,`\
`  Combined_sens ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.80``, ``0.85``, ``0.76``, ``0.81``, ``0.86``)``,`\
`  Combined_spec ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.90``, ``0.92``, ``0.998``, ``0.998``, ``0.998``)``,`\
`  Biopsies_per_1000 ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``0``, ``12``, ``10``, ``14``)`\
`)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    Cancers_detected_per_1000 ``=`` ``Combined_sens`` ``*`` ``8``,`\
`    PPV ``=`` ``(``Combined_sens`` ``*`` ``0.008``)`` ``/`` ``(``Combined_sens`` ``*`` ``0.008`` ``+`` ``(``1``-``Combined_spec``)`` ``*`` ``0.992``)`\
`  ``)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``breast_strategies``, caption ``=`` ``"Breast Cancer Screening Strategy Analysis"``, digits ``=`` ``3``)`

## Troubleshooting and Common Issues

### Mathematical Issues

#### 1. **Division by Zero**

- Occurs with perfect test characteristics
- Module handles gracefully with infinite likelihood ratios
- Clinical interpretation: “Perfect” tests rarely exist in practice

#### 2. **Extreme Prevalence**

- Very low prevalence: PPV remains low despite good tests
- Very high prevalence: NPV becomes uninformative
- Solution: Consider prevalence-appropriate strategies

#### 3. **Test Correlation**

- Independence assumption may not hold
- Real performance may differ from predictions
- Solution: Validate with real-world data

### Clinical Interpretation Challenges

#### 1. **Strategy Selection Confusion**

- **Problem**: Unclear which strategy to use
- **Solution**: Focus on primary clinical goal (avoid false positives vs
  false negatives)

#### 2. **Prevalence Estimation**

- **Problem**: Uncertain disease prevalence
- **Solution**: Use sensitivity analysis across prevalence ranges

#### 3. **Test Characteristic Uncertainty**

- **Problem**: Published test characteristics may not apply to your
  population
- **Solution**: Use conservative estimates and local validation data

## Advanced Applications

### Markov Models for Sequential Testing

For complex diagnostic pathways with multiple decision points:

\
`markov_states`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  State ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Pre-test"``, ``"Test 1 +"``, ``"Test 1 -"``, ``"Test 2 +"``, ``"Test 2 -"``, ``"Diagnosed"``, ``"Not diagnosed"``)``,`\
`  Description ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Initial clinical presentation"``,`\
`    ``"Positive first test result"``,`\
`    ``"Negative first test result"``, `\
`    ``"Positive second test result"``,`\
`    ``"Negative second test result"``,`\
`    ``"Disease confirmed"``,`\
`    ``"Disease ruled out"`\
`  ``)``,`\
`  Transition_probabilities ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Based on test characteristics"``,`\
`    ``"To Test 2 or final diagnosis"``,`\
`    ``"To Test 2 or discharge"``,`\
`    ``"To final diagnosis"``,`\
`    ``"To discharge or additional testing"``,`\
`    ``"Terminal state"``,`\
`    ``"Terminal state"`\
`  ``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``markov_states``, caption ``=`` ``"Markov Model States for Complex Sequential Testing"``)`

### Machine Learning Integration

Modern sequential testing can incorporate ML predictions:

\
`ml_framework`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Component ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Risk Prediction"``, ``"Test Selection"``, ``"Result Integration"``, ``"Decision Support"``)``,`\
`  Traditional_Approach ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Fixed prevalence estimates"``,`\
`    ``"Protocol-driven selection"``,`\
`    ``"Rule-based interpretation"``,`\
`    ``"Physician judgment"`\
`  ``)``,`\
`  ML_Enhanced_Approach ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Personalized risk scores"``,`\
`    ``"Adaptive test selection"``,`\
`    ``"Probabilistic integration"``,`\
`    ``"Evidence-based recommendations"`\
`  ``)``,`\
`  Benefit ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"More accurate pre-test probabilities"``,`\
`    ``"Optimal test sequences"``,`\
`    ``"Better diagnostic accuracy"``,`\
`    ``"Reduced cognitive load"`\
`  ``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``ml_framework``, caption ``=`` ``"Machine Learning Enhancement of Sequential Testing"``)`

## Conclusion

Sequential testing analysis provides a systematic framework for
optimizing diagnostic accuracy through strategic test combinations. The
Sequential Testing Analysis module offers comprehensive tools for:

### Key Capabilities

1.  **Strategy Comparison**: Evaluate serial positive, serial negative,
    and parallel approaches
2.  **Clinical Scenarios**: Apply to real-world medical situations
    across specialties
3.  **Cost-Effectiveness**: Balance diagnostic accuracy with economic
    considerations
4.  **Visual Analysis**: Use Fagan nomograms and population flow
    diagrams
5.  **Quality Improvement**: Design and optimize clinical protocols

### Best Practices Summary

1.  **Match strategy to clinical goals**: Confirmation vs exclusion vs
    comprehensive evaluation
2.  **Consider prevalence effects**: Strategy effectiveness varies
    dramatically with disease prevalence
3.  **Plan for real-world constraints**: Cost, time, availability, and
    patient factors
4.  **Validate assumptions**: Test independence and population
    applicability
5.  **Monitor performance**: Track outcomes and continuously improve
    protocols

### Future Directions

- Integration with electronic health records for automated risk
  assessment
- Real-time adaptive testing protocols based on individual patient
  characteristics
- Machine learning-enhanced test selection and interpretation
- Cost-effectiveness modeling with health economic outcomes
- Population-level optimization for public health screening programs

Sequential testing analysis represents a critical tool for
evidence-based diagnostic decision-making, helping clinicians and
healthcare systems optimize patient care while managing resources
effectively.

------------------------------------------------------------------------

*This vignette was generated using meddecide version 1.1.4 on
2026-11-08.*
