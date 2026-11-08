# Clinical Applications of Decision Panel Optimization

> **Not yet released in meddecide.** This article documents
> `decisionpanel`, which is not part of the meddecide 1.0.4 release. It
> is documented here ahead of a future release, so the options, defaults
> and output described below are subject to change and the analysis will
> not appear in your jamovi menu yet. For the analyses that ship today
> see the [meddecide articles
> index](https://www.serdarbalci.com/meddecide/articles/).

## Introduction

This vignette demonstrates real-world clinical applications of the
Decision Panel Optimization module across different medical specialties
and scenarios.

\
`# Load required packages`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`rpart`](https://github.com/bethatkinson/rpart)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`rpart.plot`](http://www.milbo.org/rpart-plot/index.md)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`knitr`](https://yihui.org/knitr/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`forcats`](https://forcats.tidyverse.org/)`)`

## Scenario 1: Emergency Department COVID-19 Screening

### Clinical Context

An emergency department needs to rapidly screen patients for COVID-19
while managing limited resources and preventing nosocomial transmission.

\
`# Examine test characteristics`\
`covid_tests`` ``<-`` ``covid_screening_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``rapid_antigen``, ``pcr``, ``chest_ct``, ``covid_status``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`na.omit`](https://rdrr.io/r/stats/na.fail.html)`(``)`\
\
`# Calculate individual test performance`\
`test_performance`` ``<-`` ``function``(``test``, ``truth``)`` ``{`\
`  ``tab`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``test``, ``truth``)`\
`  ``sens`` ``<-`` ``tab``[``2``,``2``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``tab``[``,``2``]``)`\
`  ``spec`` ``<-`` ``tab``[``1``,``1``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``tab``[``,``1``]``)`\
`  ``ppv`` ``<-`` ``tab``[``2``,``2``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``tab``[``2``,``]``)`\
`  ``npv`` ``<-`` ``tab``[``1``,``1``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``tab``[``1``,``]``)`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(`[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`    Sensitivity ``=`` ``sens``,`\
`    Specificity ``=`` ``spec``,`\
`    PPV ``=`` ``ppv``,`\
`    NPV ``=`` ``npv`\
`  ``)``)`\
`}`\
\
`# Individual test performance`\
`rapid_perf`` ``<-`` ``test_performance``(``covid_tests``$``rapid_antigen``, ``covid_tests``$``covid_status``)`\
`pcr_perf`` ``<-`` ``test_performance``(``covid_tests``$``pcr``, ``covid_tests``$``covid_status``)`\
`ct_perf`` ``<-`` ``test_performance``(``covid_tests``$``chest_ct``, ``covid_tests``$``covid_status``)`\
\
`performance_table`` ``<-`` `[`rbind`](https://amices.org/mice/reference/cbind.html)`(`\
``   `Rapid Antigen`  ```=`` ``rapid_perf``,`\
``   `PCR`  ```=`` ``pcr_perf``,`\
``   `Chest CT`  ```=`` ``ct_perf`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(``performance_table`` ``*`` ``100``, ``1``)``, `\
`      caption ``=`` ``"Individual Test Performance (%)"``)`

### Optimization Analysis

\
`# Run optimization for different scenarios`\
`# 1. Maximum sensitivity (don't miss cases)`\
`covid_max_sens`` ``<-`` ``decisionpanel``(`\
`  data ``=`` ``covid_screening_data``,`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"rapid_antigen"``, ``"pcr"``, ``"chest_ct"``)``,`\
`  testLevels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Positive"``, ``"Positive"``, ``"Abnormal"``)``,`\
`  gold ``=`` ``"covid_status"``,`\
`  goldPositive ``=`` ``"Positive"``,`\
`  strategies ``=`` ``"all"``,`\
`  optimizationCriteria ``=`` ``"sensitivity"``,`\
`  minSensitivity ``=`` ``0.95`\
`)`\
\
`# 2. Cost-effective screening`\
`covid_cost_effective`` ``<-`` ``decisionpanel``(`\
`  data ``=`` ``covid_screening_data``,`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"rapid_antigen"``, ``"pcr"``, ``"chest_ct"``)``,`\
`  testLevels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Positive"``, ``"Positive"``, ``"Abnormal"``)``,`\
`  gold ``=`` ``"covid_status"``,`\
`  goldPositive ``=`` ``"Positive"``,`\
`  strategies ``=`` ``"all"``,`\
`  optimizationCriteria ``=`` ``"efficiency"``,`\
`  useCosts ``=`` ``TRUE``,`\
`  testCosts ``=`` ``"5,50,200"``,`\
`  fpCost ``=`` ``500``,`\
`  fnCost ``=`` ``5000`\
`)`

### Clinical Decision Algorithm

Based on the analysis, here’s a practical algorithm:

\
`# Implement sequential testing algorithm`\
`apply_covid_algorithm`` ``<-`` ``function``(``data``)`` ``{`\
`  ``n`` ``<-`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``data``)`\
`  ``decisions`` ``<-`` `[`character`](https://rdrr.io/r/base/character.html)`(``n``)`\
`  ``tests_used`` ``<-`` `[`character`](https://rdrr.io/r/base/character.html)`(``n``)`\
`  `\
`  ``for`` ``(``i`` ``in`` ``1``:``n``)`` ``{`\
`    ``# Step 1: Rapid antigen test`\
`    ``if`` ``(``data``$``rapid_antigen``[``i``]`` ``==`` ``"Positive"``)`` ``{`\
`      ``decisions``[``i``]`` ``<-`` ``"Isolate, Confirm with PCR"`\
`      ``tests_used``[``i``]`` ``<-`` ``"Rapid"`\
`    ``}`` ``else`` ``if`` ``(``data``$``symptom_score``[``i``]`` ``>=`` ``6``)`` ``{`\
`      ``# Step 2: High symptom score → CT`\
`      ``if`` ``(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``data``$``chest_ct``[``i``]``)`` ``&&`` ``data``$``chest_ct``[``i``]`` ``==`` ``"Abnormal"``)`` ``{`\
`        ``decisions``[``i``]`` ``<-`` ``"Probable COVID, Isolate, PCR"`\
`        ``tests_used``[``i``]`` ``<-`` ``"Rapid + CT"`\
`      ``}`` ``else`` ``{`\
`        ``decisions``[``i``]`` ``<-`` ``"Low probability, Standard care"`\
`        ``tests_used``[``i``]`` ``<-`` ``"Rapid + CT"`\
`      ``}`\
`    ``}`` ``else`` ``{`\
`      ``decisions``[``i``]`` ``<-`` ``"Low probability, Standard care"`\
`      ``tests_used``[``i``]`` ``<-`` ``"Rapid"`\
`    ``}`\
`  ``}`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(`[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``Decision ``=`` ``decisions``, Tests ``=`` ``tests_used``)``)`\
`}`\
\
`# Apply algorithm`\
`algorithm_results`` ``<-`` ``apply_covid_algorithm``(``covid_screening_data``[``1``:``10``,``]``)`\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(`[`cbind`](https://amices.org/mice/reference/cbind.html)`(``covid_screening_data``[``1``:``10``, `[`c`](https://rdrr.io/r/base/c.html)`(``"patient_id"``, ``"rapid_antigen"``, `\
`                                         ``"symptom_score"``, ``"covid_status"``)``]``,`\
`            ``algorithm_results``)``)`

### Cost-Effectiveness Visualization

\
`# Simulate different strategies`\
`strategies`` ``<-`` `[`expand.grid`](https://rdrr.io/r/base/expand.grid.html)`(`\
`  use_rapid ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``TRUE``, ``FALSE``)``,`\
`  use_pcr ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``TRUE``, ``FALSE``)``,`\
`  use_ct ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``TRUE``, ``FALSE``)`\
`)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``use_rapid`` ``|`` ``use_pcr`` ``|`` ``use_ct``)`` ``# At least one test`\
\
`# Calculate performance for each strategy`\
`strategy_performance`` ``<-`` ``strategies`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`rowwise`](https://dplyr.tidyverse.org/reference/rowwise.html)`(``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    tests ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(`\
`      ``if``(``use_rapid``)`` ``"RAT"`` ``else`` ``NULL``,`\
`      ``if``(``use_pcr``)`` ``"PCR"`` ``else`` ``NULL``,`\
`      ``if``(``use_ct``)`` ``"CT"`` ``else`` ``NULL`\
`    ``)``, collapse ``=`` ``"+"``)``,`\
`    cost ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(`\
`      ``if``(``use_rapid``)`` ``5`` ``else`` ``0``,`\
`      ``if``(``use_pcr``)`` ``50`` ``else`` ``0``,`\
`      ``if``(``use_ct``)`` ``200`` ``else`` ``0`\
`    ``)``)``,`\
`    ``# Simulated performance (would come from actual analysis)`\
`    sensitivity ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``use_rapid`` ``&`` ``use_pcr`` ``&`` ``use_ct`` ``~`` ``0.99``,`\
`      ``use_pcr`` ``&`` ``use_ct`` ``~`` ``0.98``,`\
`      ``use_rapid`` ``&`` ``use_pcr`` ``~`` ``0.97``,`\
`      ``use_pcr`` ``~`` ``0.95``,`\
`      ``use_rapid`` ``&`` ``use_ct`` ``~`` ``0.94``,`\
`      ``use_ct`` ``~`` ``0.90``,`\
`      ``use_rapid`` ``~`` ``0.65`\
`    ``)``,`\
`    specificity ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``use_rapid`` ``&`` ``use_pcr`` ``&`` ``use_ct`` ``~`` ``0.83``,`\
`      ``use_pcr`` ``&`` ``use_ct`` ``~`` ``0.84``,`\
`      ``use_rapid`` ``&`` ``use_pcr`` ``~`` ``0.97``,`\
`      ``use_pcr`` ``~`` ``0.99``,`\
`      ``use_rapid`` ``&`` ``use_ct`` ``~`` ``0.83``,`\
`      ``use_ct`` ``~`` ``0.85``,`\
`      ``use_rapid`` ``~`` ``0.98`\
`    ``)`\
`  ``)`\
\
`# Create cost-effectiveness plot`\
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``strategy_performance``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``cost``, y ``=`` ``sensitivity`` ``*`` ``100``)``)`` ``+`\
`  `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``size ``=`` ``specificity`` ``*`` ``100``)``, alpha ``=`` ``0.6``)`` ``+`\
`  `[`geom_text`](https://ggplot2.tidyverse.org/reference/geom_text.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``label ``=`` ``tests``)``, vjust ``=`` ``-``1``, size ``=`` ``3``)`` ``+`\
`  `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``data ``=`` ``strategy_performance`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)` `\
`              `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(``cost``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`              `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``sensitivity`` ``==`` `[`cummax`](https://rdrr.io/r/base/cumsum.html)`(``sensitivity``)``)``,`\
`            color ``=`` ``"red"``, alpha ``=`` ``0.5``)`` ``+`\
`  `[`scale_size_continuous`](https://ggplot2.tidyverse.org/reference/scale_size.html)`(``name ``=`` ``"Specificity (%)"``, range ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``3``, ``10``)``)`` ``+`\
`  `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`\
`    title ``=`` ``"Cost-Effectiveness of COVID-19 Testing Strategies"``,`\
`    x ``=`` ``"Cost per Patient ($)"``,`\
`    y ``=`` ``"Sensitivity (%)"``,`\
`    caption ``=`` ``"Red line shows cost-effectiveness frontier"`\
`  ``)`` ``+`\
`  `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`

## Scenario 2: Breast Cancer Screening Program

### Clinical Context

A population-based breast cancer screening program needs to optimize use
of mammography, ultrasound, and MRI based on risk factors.

\
`# Examine population characteristics`\
`breast_summary`` ``<-`` ``breast_cancer_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    n ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    prevalence ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``cancer_status`` ``==`` ``"Cancer"``)``,`\
`    mean_age ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``age``)``,`\
`    pct_family_history ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``family_history`` ``==`` ``"Yes"``)`` ``*`` ``100``,`\
`    pct_brca ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``brca_mutation`` ``==`` ``"Positive"``)`` ``*`` ``100``,`\
`    pct_dense_breast ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``breast_density`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"C"``, ``"D"``)``)`` ``*`` ``100`\
`  ``)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``breast_summary``, digits ``=`` ``2``,`\
`      caption ``=`` ``"Population Characteristics"``)`\
\
`# Risk stratification`\
`breast_cancer_data`` ``<-`` ``breast_cancer_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    risk_category ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``brca_mutation`` ``==`` ``"Positive"`` ``~`` ``"High Risk"``,`\
`      ``family_history`` ``==`` ``"Yes"`` ``&`` ``age`` ``<`` ``50`` ``~`` ``"High Risk"``,`\
`      ``family_history`` ``==`` ``"Yes"`` ``|`` ``breast_density`` ``==`` ``"D"`` ``~`` ``"Moderate Risk"``,`\
`      ``TRUE`` ``~`` ``"Average Risk"`\
`    ``)`\
`  ``)`\
\
[`table`](https://rdrr.io/r/base/table.html)`(``breast_cancer_data``$``risk_category``)`

### Risk-Stratified Analysis

\
`# Analyze each risk group separately`\
`risk_groups`` ``<-`` `[`split`](https://rdrr.io/r/base/split.html)`(``breast_cancer_data``, ``breast_cancer_data``$``risk_category``)`\
\
`# High-risk group optimization`\
`high_risk_panel`` ``<-`` ``decisionpanel``(`\
`  data ``=`` ``risk_groups``$``` `High Risk` ```,`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"mammography"``, ``"ultrasound"``, ``"mri"``)``,`\
`  testLevels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"BIRADS 3-5"``, ``"Suspicious"``, ``"Suspicious"``)``,`\
`  gold ``=`` ``"cancer_status"``,`\
`  goldPositive ``=`` ``"Cancer"``,`\
`  strategies ``=`` ``"all"``,`\
`  optimizationCriteria ``=`` ``"sensitivity"``,`\
`  minSensitivity ``=`` ``0.95`\
`)`\
\
`# Average-risk group optimization (cost-conscious)`\
`average_risk_panel`` ``<-`` ``decisionpanel``(`\
`  data ``=`` ``risk_groups``$``` `Average Risk` ```,`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"clinical_exam"``, ``"mammography"``, ``"ultrasound"``)``,`\
`  testLevels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Abnormal"``, ``"BIRADS 3-5"``, ``"Suspicious"``)``,`\
`  gold ``=`` ``"cancer_status"``,`\
`  goldPositive ``=`` ``"Cancer"``,`\
`  strategies ``=`` ``"all"``,`\
`  optimizationCriteria ``=`` ``"efficiency"``,`\
`  useCosts ``=`` ``TRUE``,`\
`  testCosts ``=`` ``"20,100,150"`\
`)`

### Screening Recommendations by Risk

\
`# Create recommendation table`\
`recommendations`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Risk_Category ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"High Risk"``, ``"Moderate Risk"``, ``"Average Risk"``)``,`\
`  Recommended_Tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Annual MRI + Mammography"``,`\
`    ``"Annual Mammography + US if dense"``,`\
`    ``"Biennial Mammography"`\
`  ``)``,`\
`  Expected_Sensitivity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"99%"``, ``"90%"``, ``"85%"``)``,`\
`  Expected_Specificity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"80%"``, ``"92%"``, ``"95%"``)``,`\
`  Cost_per_Screen ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"$1,100"``, ``"$250"``, ``"$100"``)``,`\
`  NNS ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``50``, ``200``, ``500``)``  ``# Number needed to screen`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``recommendations``, `\
`      caption ``=`` ``"Risk-Stratified Screening Recommendations"``)`

### Age-Specific Performance

\
`# Analyze performance by age group`\
`age_groups`` ``<-`` ``breast_cancer_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``age_group ``=`` `[`cut`](https://rdrr.io/r/base/cut.html)`(``age``, breaks ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``40``, ``50``, ``60``, ``70``, ``80``)``,`\
`                         labels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"40-49"``, ``"50-59"``, ``"60-69"``, ``"70-79"``)``)``)`\
\
`# Calculate mammography performance by age`\
`age_performance`` ``<-`` ``age_groups`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``age_group``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    n ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    prevalence ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``cancer_status`` ``==`` ``"Cancer"``)``,`\
`    mammography_sens ``=`` ``{`\
`      ``tab`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``mammography``, ``cancer_status``)`\
`      ``if``(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``tab``)`` ``==`` ``2`` ``&&`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``tab``)`` ``==`` ``2``)`` ``{`\
`        ``tab``[``2``,``2``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``tab``[``,``2``]``)`\
`      ``}`` ``else`` ``NA`\
`    ``}``,`\
`    mammography_spec ``=`` ``{`\
`      ``tab`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``mammography``, ``cancer_status``)`\
`      ``if``(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``tab``)`` ``==`` ``2`` ``&&`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``tab``)`` ``==`` ``2``)`` ``{`\
`        ``tab``[``1``,``1``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``tab``[``,``1``]``)`\
`      ``}`` ``else`` ``NA`\
`    ``}`\
`  ``)`\
\
`# Visualize`\
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``age_performance``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``age_group``)``)`` ``+`\
`  `[`geom_bar`](https://ggplot2.tidyverse.org/reference/geom_bar.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``y ``=`` ``mammography_sens`` ``*`` ``100``)``, stat ``=`` ``"identity"``, `\
`           fill ``=`` ``"skyblue"``, alpha ``=`` ``0.7``)`` ``+`\
`  `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``y ``=`` ``prevalence`` ``*`` ``1000``, group ``=`` ``1``)``, color ``=`` ``"red"``, size ``=`` ``2``)`` ``+`\
`  `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``y ``=`` ``prevalence`` ``*`` ``1000``)``, color ``=`` ``"red"``, size ``=`` ``3``)`` ``+`\
`  `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(`\
`    name ``=`` ``"Mammography Sensitivity (%)"``,`\
`    sec.axis ``=`` `[`sec_axis`](https://ggplot2.tidyverse.org/reference/sec_axis.html)`(``~``.``/``10``, name ``=`` ``"Cancer Prevalence per 1000"``)`\
`  ``)`` ``+`\
`  `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`\
`    title ``=`` ``"Mammography Performance by Age Group"``,`\
`    x ``=`` ``"Age Group"`\
`  ``)`` ``+`\
`  `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`

## Scenario 3: Tuberculosis Case Finding

### Clinical Context

A TB program in a high-burden setting needs to optimize case finding
with limited resources.

\
`# TB test combinations for different settings`\
`tb_settings`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Setting ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Community"``, ``"Clinic"``, ``"Hospital"``, ``"Contact Tracing"``)``,`\
`  Prevalence ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.02``, ``0.20``, ``0.40``, ``0.10``)``,`\
`  Available_Tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Symptoms, CXR"``,`\
`    ``"Symptoms, Smear, GeneXpert, CXR"``,`\
`    ``"All tests"``,`\
`    ``"Symptoms, GeneXpert"`\
`  ``)``,`\
`  Budget_per_case ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``10``, ``30``, ``100``, ``50``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``tb_settings``, caption ``=`` ``"TB Testing Scenarios by Setting"``)`

### Sequential Testing Algorithm

\
`# Implement WHO-recommended algorithm`\
`apply_tb_algorithm`` ``<-`` ``function``(``data``)`` ``{`\
`  ``decisions`` ``<-`` `[`character`](https://rdrr.io/r/base/character.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``data``)``)`\
`  `\
`  ``for`` ``(``i`` ``in`` ``1``:`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``data``)``)`` ``{`\
`    ``if`` ``(``data``$``symptoms``[``i``]`` ``==`` ``"Yes"`` ``||`` ``data``$``contact_history``[``i``]`` ``==`` ``"Yes"``)`` ``{`\
`      ``# Symptomatic or contact: get GeneXpert`\
`      ``if`` ``(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``data``$``genexpert``[``i``]``)`` ``&&`` ``data``$``genexpert``[``i``]`` ``==`` ``"MTB detected"``)`` ``{`\
`        ``decisions``[``i``]`` ``<-`` ``"Start TB treatment"`\
`      ``}`` ``else`` ``if`` ``(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``data``$``chest_xray``[``i``]``)`` ``&&`` ``data``$``chest_xray``[``i``]`` ``==`` ``"Abnormal"``)`` ``{`\
`        ``# CXR abnormal but GeneXpert negative`\
`        ``if`` ``(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``data``$``culture``[``i``]``)``)`` ``{`\
`          ``decisions``[``i``]`` ``<-`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``data``$``culture``[``i``]`` ``==`` ``"Positive"``,`\
`                                ``"Start TB treatment"``,`\
`                                ``"Not TB, investigate other causes"``)`\
`        ``}`` ``else`` ``{`\
`          ``decisions``[``i``]`` ``<-`` ``"Clinical decision needed"`\
`        ``}`\
`      ``}`` ``else`` ``{`\
`        ``decisions``[``i``]`` ``<-`` ``"TB unlikely"`\
`      ``}`\
`    ``}`` ``else`` ``{`\
`      ``# Asymptomatic: screen with CXR if available`\
`      ``if`` ``(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``data``$``chest_xray``[``i``]``)`` ``&&`` ``data``$``chest_xray``[``i``]`` ``==`` ``"Abnormal"``)`` ``{`\
`        ``decisions``[``i``]`` ``<-`` ``"Needs further testing"`\
`      ``}`` ``else`` ``{`\
`        ``decisions``[``i``]`` ``<-`` ``"No TB screening needed"`\
`      ``}`\
`    ``}`\
`  ``}`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``decisions``)`\
`}`\
\
`# Apply to sample`\
`tb_sample`` ``<-`` ``tb_diagnosis_data``[``1``:``20``,``]`\
`tb_sample``$``decision`` ``<-`` ``apply_tb_algorithm``(``tb_sample``)`\
\
`# Show results`\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``tb_sample`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)` `\
`      `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``patient_id``, ``symptoms``, ``genexpert``, ``chest_xray``, ``tb_status``, ``decision``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`      `[`head`](https://rdrr.io/r/utils/head.html)`(``10``)``)`

### Cost-Effectiveness by Strategy

\
`# Compare different TB screening strategies`\
`tb_strategies`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Strategy ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Symptoms only"``,`\
`    ``"Symptoms → Smear"``,`\
`    ``"Symptoms → GeneXpert"``, `\
`    ``"Symptoms → CXR → GeneXpert"``,`\
`    ``"Universal GeneXpert"``,`\
`    ``"Universal CXR → GeneXpert"`\
`  ``)``,`\
`  Tests_per_case_found ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``100``, ``50``, ``20``, ``15``, ``10``, ``12``)``,`\
`  Cost_per_case_found ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``100``, ``200``, ``400``, ``350``, ``800``, ``600``)``,`\
`  Sensitivity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``60``, ``70``, ``85``, ``92``, ``95``, ``93``)``,`\
`  Time_to_diagnosis ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``3``, ``1``, ``2``, ``1``, ``1``)`\
`)`\
\
`# Create multi-dimensional comparison`\
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``tb_strategies``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``Cost_per_case_found``, y ``=`` ``Sensitivity``)``)`` ``+`\
`  `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``size ``=`` ``Tests_per_case_found``, `\
`                 color ``=`` `[`factor`](https://rdrr.io/r/base/factor.html)`(``Time_to_diagnosis``)``)``, alpha ``=`` ``0.7``)`` ``+`\
`  `[`geom_text`](https://ggplot2.tidyverse.org/reference/geom_text.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``label ``=`` ``Strategy``)``, vjust ``=`` ``-``1``, size ``=`` ``3``)`` ``+`\
`  `[`scale_size_continuous`](https://ggplot2.tidyverse.org/reference/scale_size.html)`(``name ``=`` ``"Tests per case"``, range ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``3``, ``10``)``)`` ``+`\
`  `[`scale_color_discrete`](https://ggplot2.tidyverse.org/reference/scale_colour_discrete.html)`(``name ``=`` ``"Days to diagnosis"``)`` ``+`\
`  `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`\
`    title ``=`` ``"TB Screening Strategy Comparison"``,`\
`    x ``=`` ``"Cost per TB case found ($)"``,`\
`    y ``=`` ``"Sensitivity (%)"`\
`  ``)`` ``+`\
`  `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`

## Scenario 4: Chest Pain Evaluation

### Clinical Context

Emergency department evaluation of chest pain requires rapid, accurate
rule-out of myocardial infarction.

\
`# Risk stratification using HEART score components`\
`mi_ruleout_data`` ``<-`` ``mi_ruleout_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    heart_score ``=`` ``(``age`` ``>`` ``65``)`` ``*`` ``1`` ``+`\
`                  ``(``chest_pain`` ``==`` ``"Typical"``)`` ``*`` ``2`` ``+`\
`                  ``(``chest_pain`` ``==`` ``"Atypical"``)`` ``*`` ``1`` ``+`\
`                  ``(``ecg`` ``==`` ``"Ischemic changes"``)`` ``*`` ``2`` ``+`\
`                  ``(``prior_cad`` ``==`` ``"Yes"``)`` ``*`` ``1`` ``+`\
`                  ``(``diabetes`` ``==`` ``"Yes"`` ``|`` ``smoking`` ``==`` ``"Yes"``)`` ``*`` ``1``,`\
`    risk_category ``=`` `[`cut`](https://rdrr.io/r/base/cut.html)`(``heart_score``, `\
`                       breaks ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``-``1``, ``3``, ``6``, ``10``)``,`\
`                       labels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Low"``, ``"Moderate"``, ``"High"``)``)`\
`  ``)`\
\
`# Show risk distribution`\
`risk_table`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``mi_ruleout_data``$``risk_category``, ``mi_ruleout_data``$``mi_status``)`\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(`[`prop.table`](https://rdrr.io/r/base/proportions.html)`(``risk_table``, margin ``=`` ``1``)`` ``*`` ``100``,`\
`      digits ``=`` ``1``,`\
`      caption ``=`` ``"MI Prevalence by Risk Category (%)"``)`

### Time-Sensitive Protocols

\
`# Define protocols by urgency`\
`protocols`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`  rapid_rule_out ``=`` ``function``(``data``)`` ``{`\
`    ``# 0/1-hour protocol`\
`    ``data``$``troponin_initial`` ``==`` ``"Normal"`` ``&`` `\
`    ``data``$``ecg`` ``==`` ``"Normal"`` ``&`` `\
`    ``data``$``heart_score`` ``<=`` ``3`\
`  ``}``,`\
`  `\
`  standard_rule_out ``=`` ``function``(``data``)`` ``{`\
`    ``# 0/3-hour protocol`\
`    ``data``$``troponin_initial`` ``==`` ``"Normal"`` ``&`` `\
`    ``data``$``troponin_3hr`` ``==`` ``"Normal"`` ``&`\
`    ``data``$``ecg`` ``==`` ``"Normal"`\
`  ``}``,`\
`  `\
`  rule_in ``=`` ``function``(``data``)`` ``{`\
`    ``# Immediate rule-in`\
`    ``data``$``troponin_initial`` ``==`` ``"Elevated"`` ``&`` `\
`    ``data``$``ecg`` ``==`` ``"Ischemic changes"`\
`  ``}`\
`)`\
\
`# Apply protocols`\
`mi_ruleout_data`` ``<-`` ``mi_ruleout_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    rapid_rule_out ``=`` ``protocols``$``rapid_rule_out``(``.``)``,`\
`    standard_rule_out ``=`` ``protocols``$``standard_rule_out``(``.``)`` ``&`` ``!``rapid_rule_out``,`\
`    rule_in ``=`` ``protocols``$``rule_in``(``.``)``,`\
`    need_further_testing ``=`` ``!``rapid_rule_out`` ``&`` ``!``standard_rule_out`` ``&`` ``!``rule_in`\
`  ``)`\
\
`# Summarize protocol performance`\
`protocol_performance`` ``<-`` ``mi_ruleout_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    rapid_rule_out_pct ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``rapid_rule_out``)`` ``*`` ``100``,`\
`    rapid_rule_out_npv ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``rapid_rule_out`` ``&`` ``mi_status`` ``==`` ``"No MI"``)`` ``/`` `\
`                         `[`sum`](https://rdrr.io/r/base/sum.html)`(``rapid_rule_out``)`` ``*`` ``100``,`\
`    standard_rule_out_pct ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_rule_out``)`` ``*`` ``100``,`\
`    standard_rule_out_npv ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``standard_rule_out`` ``&`` ``mi_status`` ``==`` ``"No MI"``)`` ``/`` `\
`                           `[`sum`](https://rdrr.io/r/base/sum.html)`(``standard_rule_out``)`` ``*`` ``100``,`\
`    rule_in_pct ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``rule_in``)`` ``*`` ``100``,`\
`    rule_in_ppv ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``rule_in`` ``&`` ``mi_status`` ``==`` ``"MI"``)`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``rule_in``)`` ``*`` ``100`\
`  ``)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(`[`t`](https://rdrr.io/r/base/t.html)`(``protocol_performance``)``, digits ``=`` ``1``,`\
`      caption ``=`` ``"Protocol Performance Metrics"``)`

### Visualization of Patient Flow

\
`# Create patient flow diagram data`\
`flow_data`` ``<-`` ``mi_ruleout_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    disposition ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``rapid_rule_out`` ``~`` ``"Discharge (1 hour)"``,`\
`      ``standard_rule_out`` ``~`` ``"Discharge (3 hours)"``,`\
`      ``rule_in`` ``~`` ``"Admit CCU"``,`\
`      ``TRUE`` ``~`` ``"Observation/Further testing"`\
`    ``)`\
`  ``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``disposition``, ``mi_status``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(``n ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``pct ``=`` ``n`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``n``)`` ``*`` ``100``)`\
\
`# Create flow diagram`\
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``flow_data``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``disposition``, y ``=`` ``n``, fill ``=`` ``mi_status``)``)`` ``+`\
`  `[`geom_bar`](https://ggplot2.tidyverse.org/reference/geom_bar.html)`(``stat ``=`` ``"identity"``, position ``=`` ``"stack"``)`` ``+`\
`  `[`geom_text`](https://ggplot2.tidyverse.org/reference/geom_text.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``label ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%.0f%%"``, ``pct``)``)``, `\
`            position ``=`` `[`position_stack`](https://ggplot2.tidyverse.org/reference/position_stack.html)`(``vjust ``=`` ``0.5``)``)`` ``+`\
`  `[`scale_fill_manual`](https://ggplot2.tidyverse.org/reference/scale_manual.html)`(``values ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"No MI"`` ``=`` ``"lightgreen"``, ``"MI"`` ``=`` ``"salmon"``)``)`` ``+`\
`  `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`\
`    title ``=`` ``"Patient Disposition by Protocol"``,`\
`    x ``=`` ``"Disposition"``,`\
`    y ``=`` ``"Number of Patients"``,`\
`    fill ``=`` ``"Final Diagnosis"`\
`  ``)`` ``+`\
`  `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`` ``+`\
`  `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``axis.text.x ``=`` `[`element_text`](https://ggplot2.tidyverse.org/reference/element.html)`(``angle ``=`` ``45``, hjust ``=`` ``1``)``)`

## Scenario 5: Thyroid Nodule Evaluation

### Clinical Context

Thyroid nodules are common but cancer is rare. Optimize use of FNA,
molecular testing, and surgery.

\
`# Analyze by nodule size`\
`thyroid_by_size`` ``<-`` ``thyroid_nodule_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``size_category ``=`` `[`cut`](https://rdrr.io/r/base/cut.html)`(``nodule_size``, `\
`                             breaks ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``10``, ``20``, ``40``, ``100``)``,`\
`                             labels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"<1cm"``, ``"1-2cm"``, ``"2-4cm"``, ``">4cm"``)``)``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``size_category``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    n ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    cancer_rate ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``cancer_status`` ``==`` ``"Malignant"``)`` ``*`` ``100``,`\
`    fna_done ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``fna_cytology``)``)`` ``*`` ``100``,`\
`    molecular_done ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``molecular_test``)``)`` ``*`` ``100`\
`  ``)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``thyroid_by_size``, digits ``=`` ``1``,`\
`      caption ``=`` ``"Thyroid Nodule Characteristics by Size"``)`

### Diagnostic Algorithm Implementation

\
`# Implement Bethesda-based algorithm`\
`thyroid_algorithm`` ``<-`` ``decisionpanel``(`\
`  data ``=`` ``thyroid_nodule_data``,`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"ultrasound"``, ``"fna_cytology"``, ``"molecular_test"``)``,`\
`  testLevels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"TI-RADS 4-5"``, ``"Suspicious/Malignant"``, ``"Suspicious"``)``,`\
`  gold ``=`` ``"cancer_status"``,`\
`  goldPositive ``=`` ``"Malignant"``,`\
`  strategies ``=`` ``"sequential"``,`\
`  sequentialStop ``=`` ``"positive"``,`\
`  createTree ``=`` ``TRUE``,`\
`  treeMethod ``=`` ``"cart"``,`\
`  useCosts ``=`` ``TRUE``,`\
`  testCosts ``=`` ``"200,300,3000"``,  ``# US, FNA, Molecular`\
`  fpCost ``=`` ``10000``,  ``# Unnecessary surgery`\
`  fnCost ``=`` ``50000``   ``# Missed cancer`\
`)`

### Decision Tree Visualization

\
`# Simplified decision tree representation`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Thyroid Nodule Evaluation Algorithm:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"1. Ultrasound Assessment\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"   ├─ TI-RADS 1-2: No FNA needed\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"   └─ TI-RADS 3-5: Proceed to FNA\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"      ├─ Benign (Bethesda II): Follow-up\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"      ├─ Indeterminate (Bethesda III-IV): Molecular testing\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"      │  ├─ Benign profile: Follow-up\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"      │  └─ Suspicious profile: Surgery\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"      └─ Suspicious/Malignant (Bethesda V-VI): Surgery\n"``)`\
\
`# Create visual representation of outcomes`\
`outcomes`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Test_Path ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"US only"``, ``"US+FNA"``, ``"US+FNA+Molecular"``, ``"Direct Surgery"``)``,`\
`  Patients_pct ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``40``, ``30``, ``20``, ``10``)``,`\
`  Cancers_found_pct ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``20``, ``60``, ``20``)``,`\
`  Cost ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``200``, ``500``, ``3500``, ``200``)`\
`)`\
\
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``outcomes``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``Test_Path``, y ``=`` ``Patients_pct``)``)`` ``+`\
`  `[`geom_bar`](https://ggplot2.tidyverse.org/reference/geom_bar.html)`(``stat ``=`` ``"identity"``, fill ``=`` ``"lightblue"``, alpha ``=`` ``0.7``)`` ``+`\
`  `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``y ``=`` ``Cancers_found_pct``, group ``=`` ``1``)``, color ``=`` ``"red"``, size ``=`` ``2``)`` ``+`\
`  `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``y ``=`` ``Cancers_found_pct``)``, color ``=`` ``"red"``, size ``=`` ``3``)`` ``+`\
`  `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(`\
`    name ``=`` ``"Percentage of Patients"``,`\
`    sec.axis ``=`` `[`sec_axis`](https://ggplot2.tidyverse.org/reference/sec_axis.html)`(``~``.``, name ``=`` ``"Percentage of Cancers Found"``)`\
`  ``)`` ``+`\
`  `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`\
`    title ``=`` ``"Thyroid Nodule Evaluation Pathways"``,`\
`    x ``=`` ``"Testing Path"`\
`  ``)`` ``+`\
`  `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`` ``+`\
`  `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``axis.text.x ``=`` `[`element_text`](https://ggplot2.tidyverse.org/reference/element.html)`(``angle ``=`` ``45``, hjust ``=`` ``1``)``)`

## Summary and Best Practices

### Key Learnings Across Scenarios

1.  **Context Matters**: Optimal strategies differ between screening and
    diagnosis
2.  **Sequential Testing**: Often more efficient than parallel testing
3.  **Risk Stratification**: Improves efficiency and outcomes
4.  **Cost Considerations**: Must balance performance with resources
5.  **Implementation**: Clear algorithms improve adoption

### General Recommendations

\
`summary_recommendations`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Scenario ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Screening"``, ``"Diagnosis"``, ``"Emergency"``, ``"Surveillance"``)``,`\
`  Priority ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"High Sensitivity"``, ``"Balanced"``, ``"Speed + Accuracy"``, ``"Specificity"``)``,`\
`  Strategy ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Parallel OR"``, ``"Sequential"``, ``"Rapid protocols"``, ``"Confirmatory"``)``,`\
`  Key_Metric ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"NPV"``, ``"Accuracy"``, ``"Time to decision"``, ``"PPV"``)``,`\
`  Example ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Cancer screening"``, ``"TB diagnosis"``, ``"Chest pain"``, ``"Cancer follow-up"``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``summary_recommendations``,`\
`      caption ``=`` ``"Testing Strategy Recommendations by Clinical Scenario"``)`

### Future Directions

1.  **Machine Learning Integration**: Combine multiple variables beyond
    just test results
2.  **Dynamic Protocols**: Adapt based on local prevalence and resources
3.  **Real-time Optimization**: Update algorithms based on performance
    data
4.  **Patient Preferences**: Include patient values in decision-making

## Session Information

\
[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`
