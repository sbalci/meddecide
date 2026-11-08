# Precision Oncology: Biomarker-Guided Treatment Selection and Outcome Analysis

## Introduction

Precision oncology represents the paradigm shift from one-size-fits-all
cancer treatment to personalized therapy based on molecular
characteristics of individual tumors. This vignette demonstrates
comprehensive biomarker analysis, treatment selection algorithms, and
outcome evaluation using ClinicoPath modules.

**Learning Objectives:**

- Master precision oncology biomarker interpretation
- Learn treatment selection algorithms based on molecular profiles
- Analyze biomarker-outcome relationships
- Understand companion diagnostic requirements
- Implement clinical decision support systems
- Evaluate cost-effectiveness of precision medicine approaches

### Clinical Context

Modern precision oncology requires integration of multiple biomarker
types:

1.  **Predictive Biomarkers**: Guide treatment selection (EGFR, HER2,
    PD-L1)
2.  **Prognostic Biomarkers**: Predict disease outcome (Ki-67, p53)
3.  **Pharmacogenomic Markers**: Influence drug metabolism (CYP2D6,
    TPMT)
4.  **Resistance Markers**: Predict treatment failure (T790M, MET
    amplification)
5.  **Immune Markers**: Guide immunotherapy (MSI, TMB, TILs)

\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`survival`](https://github.com/therneau/survival)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`pROC`](https://xrobin.github.io/pROC/)`)`

## Dataset Overview

### Precision Oncology Dataset

The `precision_oncology_data` dataset contains 116 patients with
comprehensive molecular profiling and treatment outcomes, representing
real-world precision oncology scenarios.

\
`# Load the precision oncology dataset`\
[`data`](https://rdrr.io/r/utils/data.html)`(``precision_oncology_data``)`\
\
`# Dataset structure`\
[`str`](https://rdrr.io/r/utils/str.html)`(``precision_oncology_data``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Dataset dimensions:"``, `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``precision_oncology_data``)``, ``"patients ×"``, `\
`    `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``precision_oncology_data``)``, ``"variables\n"``)`\
\
`# Patient demographics`\
`demographic_summary`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    median_age ``=`` `[`median`](https://rdrr.io/r/stats/median.html)`(``Age``)``,`\
`    age_range ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(`[`min`](https://rdrr.io/r/base/Extremes.html)`(``Age``)``, ``"-"``, `[`max`](https://rdrr.io/r/base/Extremes.html)`(``Age``)``)``,`\
`    female_pct ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``Gender`` ``==`` ``"Female"``)`` ``*`` ``100``, ``1``)``,`\
`    n_tumor_types ``=`` `[`length`](https://rdrr.io/r/base/length.html)`(`[`unique`](https://rdrr.io/r/base/unique.html)`(``Tumor_Type``)``)`\
`  ``)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``"Patient Demographics:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``demographic_summary``)`\
\
`# Tumor type distribution`\
`tumor_distribution`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``precision_oncology_data``$``Tumor_Type``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``"Tumor Type Distribution:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``tumor_distribution``)`

## Biomarker Landscape Analysis

### Actionable Biomarker Frequencies

Assess the prevalence of actionable molecular alterations.

\
`# Calculate biomarker frequencies`\
`biomarker_summary`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    ``# Targeted therapy biomarkers`\
`    egfr_positive ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``EGFR_Mutation`` ``==`` ``"Positive"``)``,`\
`    her2_amplified ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``HER2_FISH_Status`` ``==`` ``"Amplified"``)``,`\
`    braf_positive ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``BRAF_Mutation`` ``==`` ``"Positive"``)``,`\
`    alk_positive ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``ALK_Fusion`` ``==`` ``"Positive"``)``,`\
`    `\
`    ``# Immunotherapy biomarkers`\
`    msi_high ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``MSI_Status`` ``==`` ``"MSI-High"``)``,`\
`    pdl1_high ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``PD_L1_TPS`` ``>=`` ``50``)``,`\
`    pdl1_positive ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``PD_L1_TPS`` ``>=`` ``1``)``,`\
`    `\
`    ``# Any actionable alteration`\
`    any_targeted ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``EGFR_Mutation`` ``==`` ``"Positive"`` ``|`` `\
`                      ``HER2_FISH_Status`` ``==`` ``"Amplified"`` ``|`\
`                      ``BRAF_Mutation`` ``==`` ``"Positive"`` ``|`\
`                      ``ALK_Fusion`` ``==`` ``"Positive"``)``,`\
`    `\
`    any_immunotherapy ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``MSI_Status`` ``==`` ``"MSI-High"`` ``|`` ``PD_L1_TPS`` ``>=`` ``1``)``,`\
`    `\
`    total_patients ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)`\
`  ``)`\
\
`# Convert to percentages and create summary table`\
`biomarker_table`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Biomarker ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"EGFR Mutation"``, ``"HER2 Amplification"``, ``"BRAF Mutation"``, `\
`                ``"ALK Fusion"``, ``"MSI-High"``, ``"PD-L1 >=50%"``, ``"PD-L1 >=1%"``,`\
`                ``"Any Targeted Therapy"``, ``"Any Immunotherapy"``)``,`\
`  Count ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``biomarker_summary``$``egfr_positive``, ``biomarker_summary``$``her2_amplified``,`\
`            ``biomarker_summary``$``braf_positive``, ``biomarker_summary``$``alk_positive``,`\
`            ``biomarker_summary``$``msi_high``, ``biomarker_summary``$``pdl1_high``,`\
`            ``biomarker_summary``$``pdl1_positive``, ``biomarker_summary``$``any_targeted``,`\
`            ``biomarker_summary``$``any_immunotherapy``)``,`\
`  Percentage ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``biomarker_summary``$``egfr_positive``, ``biomarker_summary``$``her2_amplified``,`\
`                      ``biomarker_summary``$``braf_positive``, ``biomarker_summary``$``alk_positive``,`\
`                      ``biomarker_summary``$``msi_high``, ``biomarker_summary``$``pdl1_high``,`\
`                      ``biomarker_summary``$``pdl1_positive``, ``biomarker_summary``$``any_targeted``,`\
`                      ``biomarker_summary``$``any_immunotherapy``)`` ``/`` `\
`                     ``biomarker_summary``$``total_patients`` ``*`` ``100``, ``1``)`\
`)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``"Actionable Biomarker Frequencies:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``biomarker_table``)`

### Tumor-Specific Biomarker Patterns

Analyze biomarker patterns by tumor type.

\
`# Biomarker frequencies by tumor type`\
`biomarker_by_tumor`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``Tumor_Type``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    n ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    egfr_pct ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``EGFR_Mutation`` ``==`` ``"Positive"``)`` ``*`` ``100``, ``1``)``,`\
`    her2_pct ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``HER2_FISH_Status`` ``==`` ``"Amplified"``)`` ``*`` ``100``, ``1``)``,`\
`    braf_pct ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``BRAF_Mutation`` ``==`` ``"Positive"``)`` ``*`` ``100``, ``1``)``,`\
`    msi_high_pct ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``MSI_Status`` ``==`` ``"MSI-High"``)`` ``*`` ``100``, ``1``)``,`\
`    pdl1_high_pct ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``PD_L1_TPS`` ``>=`` ``50``)`` ``*`` ``100``, ``1``)``,`\
`    .groups ``=`` ``'drop'`\
`  ``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(`[`desc`](https://dplyr.tidyverse.org/reference/desc.html)`(``n``)``)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``"Biomarker Frequencies by Tumor Type:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``biomarker_by_tumor``)`\
\
`# Identify tumor types with highest actionable biomarker rates`\
`high_actionable`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    actionable ``=`` ``EGFR_Mutation`` ``==`` ``"Positive"`` ``|`` `\
`                ``HER2_FISH_Status`` ``==`` ``"Amplified"`` ``|`\
`                ``BRAF_Mutation`` ``==`` ``"Positive"`` ``|`\
`                ``ALK_Fusion`` ``==`` ``"Positive"`` ``|`\
`                ``MSI_Status`` ``==`` ``"MSI-High"`` ``|`\
`                ``PD_L1_TPS`` ``>=`` ``50`\
`  ``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``Tumor_Type``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    n ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    actionable_rate ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``actionable``)`` ``*`` ``100``, ``1``)``,`\
`    .groups ``=`` ``'drop'`\
`  ``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``n`` ``>=`` ``5``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(`[`desc`](https://dplyr.tidyverse.org/reference/desc.html)`(``actionable_rate``)``)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``"Tumor Types with Highest Actionable Biomarker Rates:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(`[`head`](https://rdrr.io/r/utils/head.html)`(``high_actionable``, ``5``)``)`

## Treatment Selection Algorithms

### Rule-Based Treatment Assignment

Implement clinical guideline-based treatment selection.

\
`# Create treatment selection algorithm`\
`precision_oncology_data`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    ``# Primary treatment recommendation based on biomarkers`\
`    primary_treatment ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``EGFR_Mutation`` ``==`` ``"Positive"`` ``~`` ``"EGFR TKI"``,`\
`      ``HER2_FISH_Status`` ``==`` ``"Amplified"`` ``~`` ``"HER2-Targeted Therapy"``,`\
`      ``BRAF_Mutation`` ``==`` ``"Positive"`` ``&`` ``Tumor_Type`` ``==`` ``"Melanoma"`` ``~`` ``"BRAF Inhibitor"``,`\
`      ``ALK_Fusion`` ``==`` ``"Positive"`` ``~`` ``"ALK Inhibitor"``,`\
`      ``TRUE`` ``~`` ``"Standard Chemotherapy"`\
`    ``)``,`\
`    `\
`    ``# Immunotherapy candidacy`\
`    immunotherapy_candidate ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``MSI_Status`` ``==`` ``"MSI-High"`` ``~`` ``"First-line Immunotherapy"``,`\
`      ``PD_L1_TPS`` ``>=`` ``50`` ``~`` ``"First-line Anti-PD-1"``,`\
`      ``PD_L1_TPS`` ``>=`` ``1`` ``~`` ``"Combination Therapy"``,`\
`      ``TRUE`` ``~`` ``"Chemotherapy First"`\
`    ``)``,`\
`    `\
`    ``# Treatment complexity score`\
`    treatment_complexity ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``EGFR_Mutation`` ``==`` ``"Positive"`` ``|`` ``ALK_Fusion`` ``==`` ``"Positive"`` ``~`` ``"High"``,`\
`      ``HER2_FISH_Status`` ``==`` ``"Amplified"`` ``|`` ``MSI_Status`` ``==`` ``"MSI-High"`` ``~`` ``"High"``, `\
`      ``PD_L1_TPS`` ``>=`` ``50`` ``~`` ``"Medium"``,`\
`      ``PD_L1_TPS`` ``>=`` ``1`` ``~`` ``"Medium"``,`\
`      ``TRUE`` ``~`` ``"Standard"`\
`    ``)`\
`  ``)`\
\
`# Treatment recommendation summary`\
`treatment_summary`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``precision_oncology_data``$``primary_treatment``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``"Primary Treatment Recommendations:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``treatment_summary``)`\
\
`immunotherapy_summary`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``precision_oncology_data``$``immunotherapy_candidate``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``"Immunotherapy Recommendations:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``immunotherapy_summary``)`

### Biomarker Combination Analysis

Analyze patients with multiple actionable biomarkers.

\
`# Identify patients with multiple biomarkers`\
`precision_oncology_data`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    biomarker_count ``=`` `\
`      `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(``EGFR_Mutation`` ``==`` ``"Positive"``)`` ``+`\
`      `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(``HER2_FISH_Status`` ``==`` ``"Amplified"``)`` ``+`\
`      `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(``BRAF_Mutation`` ``==`` ``"Positive"``)`` ``+`\
`      `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(``ALK_Fusion`` ``==`` ``"Positive"``)`` ``+`\
`      `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(``MSI_Status`` ``==`` ``"MSI-High"``)`` ``+`\
`      `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(``PD_L1_TPS`` ``>=`` ``50``)``,`\
`    `\
`    biomarker_category ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``biomarker_count`` ``==`` ``0`` ``~`` ``"No Actionable Biomarkers"``,`\
`      ``biomarker_count`` ``==`` ``1`` ``~`` ``"Single Biomarker"``,`\
`      ``biomarker_count`` ``>=`` ``2`` ``~`` ``"Multiple Biomarkers"`\
`    ``)`\
`  ``)`\
\
`biomarker_count_summary`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``precision_oncology_data``$``biomarker_category``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``"Biomarker Count Distribution:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``biomarker_count_summary``)`\
\
`# Analyze combination patterns`\
`multiple_biomarker_cases`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``biomarker_count`` ``>=`` ``2``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``Patient_ID``, ``Tumor_Type``, ``EGFR_Mutation``, ``HER2_FISH_Status``, `\
`         ``BRAF_Mutation``, ``ALK_Fusion``, ``MSI_Status``, ``PD_L1_TPS``)`\
\
`if``(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``multiple_biomarker_cases``)`` ``>`` ``0``)`` ``{`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Patients with Multiple Actionable Biomarkers:"``, `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``multiple_biomarker_cases``)``, ``"\n"``)`\
`  `[`print`](https://rdrr.io/r/base/print.html)`(`[`head`](https://rdrr.io/r/utils/head.html)`(``multiple_biomarker_cases``)``)`\
`}`

## Biomarker-Outcome Relationships

### Treatment Response Analysis

Assess biomarker predictive value for treatment response.

\
`# Response rates by biomarker status`\
`response_analysis`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    objective_response ``=`` ``Treatment_Response`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"Complete_Response"``, ``"Partial_Response"``)`\
`  ``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    ``# Overall response rate`\
`    overall_response_rate ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``objective_response``)`` ``*`` ``100``, ``1``)``,`\
`    `\
`    ``# Response by biomarker status`\
`    egfr_positive_response ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`\
`      `[`mean`](https://rdrr.io/r/base/mean.html)`(``objective_response``[``EGFR_Mutation`` ``==`` ``"Positive"``]``)`` ``*`` ``100``, ``1``)``,`\
`    egfr_negative_response ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`\
`      `[`mean`](https://rdrr.io/r/base/mean.html)`(``objective_response``[``EGFR_Mutation`` ``==`` ``"Negative"``]``)`` ``*`` ``100``, ``1``)``,`\
`    `\
`    her2_amplified_response ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`\
`      `[`mean`](https://rdrr.io/r/base/mean.html)`(``objective_response``[``HER2_FISH_Status`` ``==`` ``"Amplified"``]``, na.rm ``=`` ``TRUE``)`` ``*`` ``100``, ``1``)``,`\
`    her2_not_amplified_response ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`\
`      `[`mean`](https://rdrr.io/r/base/mean.html)`(``objective_response``[``HER2_FISH_Status`` ``!=`` ``"Amplified"``]``, na.rm ``=`` ``TRUE``)`` ``*`` ``100``, ``1``)``,`\
`    `\
`    msi_high_response ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`\
`      `[`mean`](https://rdrr.io/r/base/mean.html)`(``objective_response``[``MSI_Status`` ``==`` ``"MSI-High"``]``)`` ``*`` ``100``, ``1``)``,`\
`    msi_low_mss_response ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`\
`      `[`mean`](https://rdrr.io/r/base/mean.html)`(``objective_response``[``MSI_Status`` ``!=`` ``"MSI-High"``]``)`` ``*`` ``100``, ``1``)``,`\
`    `\
`    pdl1_high_response ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`\
`      `[`mean`](https://rdrr.io/r/base/mean.html)`(``objective_response``[``PD_L1_TPS`` ``>=`` ``50``]``)`` ``*`` ``100``, ``1``)``,`\
`    pdl1_low_response ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`\
`      `[`mean`](https://rdrr.io/r/base/mean.html)`(``objective_response``[``PD_L1_TPS`` ``<`` ``50``]``)`` ``*`` ``100``, ``1``)`\
`  ``)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``"Response Rates by Biomarker Status:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``response_analysis``)`\
\
`# Statistical significance testing`\
`# EGFR mutation vs response`\
`egfr_response_table`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``precision_oncology_data``$``EGFR_Mutation``, `\
`                            ``precision_oncology_data``$``Treatment_Response`` `[`%in%`](https://rdrr.io/r/base/match.html)` `\
`                            `[`c`](https://rdrr.io/r/base/c.html)`(``"Complete_Response"``, ``"Partial_Response"``)``)`\
\
`if``(`[`min`](https://rdrr.io/r/base/Extremes.html)`(``egfr_response_table``)`` ``>=`` ``5``)`` ``{`\
`  ``egfr_test`` ``<-`` `[`fisher.test`](https://rdrr.io/r/stats/fisher.test.html)`(``egfr_response_table``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"EGFR mutation vs response p-value:"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``egfr_test``$``p.value``, ``3``)``, ``"\n"``)`\
`}`\
\
`# MSI status vs response`\
`msi_response_table`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``precision_oncology_data``$``MSI_Status`` ``==`` ``"MSI-High"``,`\
`                           ``precision_oncology_data``$``Treatment_Response`` `[`%in%`](https://rdrr.io/r/base/match.html)` `\
`                           `[`c`](https://rdrr.io/r/base/c.html)`(``"Complete_Response"``, ``"Partial_Response"``)``)`\
\
`if``(`[`min`](https://rdrr.io/r/base/Extremes.html)`(``msi_response_table``)`` ``>=`` ``5``)`` ``{`\
`  ``msi_test`` ``<-`` `[`fisher.test`](https://rdrr.io/r/stats/fisher.test.html)`(``msi_response_table``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"MSI-High vs response p-value:"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``msi_test``$``p.value``, ``3``)``, ``"\n"``)`\
`}`

### Progression-Free Survival Analysis

Analyze time-to-progression by biomarker status.

\
`# PFS analysis by biomarker groups`\
`pfs_summary`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``EGFR_Mutation``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    n ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    median_pfs ``=`` `[`median`](https://rdrr.io/r/stats/median.html)`(``PFS_Months``)``,`\
`    progression_rate ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``Progression_Event``)`` ``*`` ``100``, ``1``)``,`\
`    .groups ``=`` ``'drop'`\
`  ``)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``"PFS by EGFR Status:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``pfs_summary``)`\
\
`# MSI status PFS analysis`\
`msi_pfs_summary`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``MSI_Status``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    n ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    median_pfs ``=`` `[`median`](https://rdrr.io/r/stats/median.html)`(``PFS_Months``)``,`\
`    progression_rate ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``Progression_Event``)`` ``*`` ``100``, ``1``)``,`\
`    .groups ``=`` ``'drop'`\
`  ``)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``"PFS by MSI Status:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``msi_pfs_summary``)`\
\
`# Survival analysis if survival package available`\
`if``(`[`requireNamespace`](https://rdrr.io/r/base/ns-load.html)`(``"survival"``, quietly ``=`` ``TRUE``)``)`` ``{`\
`  `[`library`](https://rdrr.io/r/base/library.html)`(`[`survival`](https://github.com/therneau/survival)`)`\
`  `\
`  ``# Create survival object`\
`  ``surv_obj`` ``<-`` `[`Surv`](https://rdrr.io/pkg/survival/man/Surv.html)`(``precision_oncology_data``$``PFS_Months``, `\
`                   ``precision_oncology_data``$``Progression_Event``)`\
`  `\
`  ``# Kaplan-Meier analysis by EGFR status`\
`  ``km_egfr`` ``<-`` `[`survfit`](https://rdrr.io/pkg/survival/man/survfit.html)`(``surv_obj`` ``~`` ``EGFR_Mutation``, data ``=`` ``precision_oncology_data``)`\
`  `\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nKaplan-Meier Analysis - EGFR Status:\n"``)`\
`  `[`print`](https://rdrr.io/r/base/print.html)`(`[`summary`](https://rdrr.io/r/base/summary.html)`(``km_egfr``)``$``table``)`\
`  `\
`  ``# Log-rank test`\
`  ``logrank_egfr`` ``<-`` `[`survdiff`](https://rdrr.io/pkg/survival/man/survdiff.html)`(``surv_obj`` ``~`` ``EGFR_Mutation``, data ``=`` ``precision_oncology_data``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Log-rank test p-value (EGFR):"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``1`` ``-`` `[`pchisq`](https://rdrr.io/r/stats/Chisquare.html)`(``logrank_egfr``$``chisq``, ``1``)``, ``3``)``, ``"\n"``)`\
`  `\
`  ``# Cox proportional hazards model`\
`  ``cox_model`` ``<-`` `[`coxph`](https://rdrr.io/pkg/survival/man/coxph.html)`(``surv_obj`` ``~`` ``EGFR_Mutation`` ``+`` ``MSI_Status`` ``+`` ``PD_L1_TPS`` ``+`` ``Age``, `\
`                     data ``=`` ``precision_oncology_data``)`\
`  `\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nCox Regression Results:\n"``)`\
`  `[`print`](https://rdrr.io/r/base/print.html)`(`[`summary`](https://rdrr.io/r/base/summary.html)`(``cox_model``)``$``coefficients``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"coef"``, ``"exp(coef)"``, ``"Pr(>|z|)"``)``]``)`\
`}`

## Companion Diagnostic Development

### ROC Analysis for Biomarker Cutpoints

Optimize biomarker cutpoints for treatment selection.

\
`# ROC analysis for PD-L1 TPS cutpoint optimization`\
`if``(`[`requireNamespace`](https://rdrr.io/r/base/ns-load.html)`(``"pROC"``, quietly ``=`` ``TRUE``)``)`` ``{`\
`  `[`library`](https://rdrr.io/r/base/library.html)`(`[`pROC`](https://xrobin.github.io/pROC/)`)`\
`  `\
`  ``# Create binary response outcome`\
`  ``response_binary`` ``<-`` `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(``precision_oncology_data``$``Treatment_Response`` `[`%in%`](https://rdrr.io/r/base/match.html)` `\
`                               `[`c`](https://rdrr.io/r/base/c.html)`(``"Complete_Response"``, ``"Partial_Response"``)``)`\
`  `\
`  ``# ROC analysis for PD-L1 TPS`\
`  ``roc_pdl1`` ``<-`` `[`roc`](https://rdrr.io/pkg/pROC/man/roc.html)`(``response_binary``, ``precision_oncology_data``$``PD_L1_TPS``, quiet ``=`` ``TRUE``)`\
`  `\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"PD-L1 TPS ROC Analysis:\n"``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"AUC:"``, `[`round`](https://rdrr.io/r/base/Round.html)`(`[`auc`](https://rdrr.io/pkg/pROC/man/auc.html)`(``roc_pdl1``)``, ``3``)``, ``"\n"``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"95% CI:"``, `[`paste`](https://rdrr.io/r/base/paste.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(`[`ci.auc`](https://rdrr.io/pkg/pROC/man/ci.auc.html)`(``roc_pdl1``)``, ``3``)``, collapse ``=`` ``" - "``)``, ``"\n"``)`\
`  `\
`  ``# Optimal cutpoint using Youden index`\
`  ``optimal_cutpoint`` ``<-`` `[`coords`](https://rdrr.io/pkg/pROC/man/coords.html)`(``roc_pdl1``, ``"best"``, ret ``=`` ``"threshold"``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Optimal cutpoint (Youden):"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``optimal_cutpoint``, ``1``)``, ``"\n"``)`\
`  `\
`  ``# Performance at standard cutpoints`\
`  ``cutpoints`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``1``, ``10``, ``20``, ``50``)`\
`  `\
`  ``performance_table`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`    Cutpoint ``=`` ``cutpoints``,`\
`    Sensitivity ``=`` `[`sapply`](https://rdrr.io/r/base/lapply.html)`(``cutpoints``, ``function``(``x``)`` ``{`\
`      `[`round`](https://rdrr.io/r/base/Round.html)`(`[`coords`](https://rdrr.io/pkg/pROC/man/coords.html)`(``roc_pdl1``, ``x``, ret ``=`` ``"sensitivity"``)``, ``3``)`\
`    ``}``)``,`\
`    Specificity ``=`` `[`sapply`](https://rdrr.io/r/base/lapply.html)`(``cutpoints``, ``function``(``x``)`` ``{`\
`      `[`round`](https://rdrr.io/r/base/Round.html)`(`[`coords`](https://rdrr.io/pkg/pROC/man/coords.html)`(``roc_pdl1``, ``x``, ret ``=`` ``"specificity"``)``, ``3``)`\
`    ``}``)``,`\
`    PPV ``=`` `[`sapply`](https://rdrr.io/r/base/lapply.html)`(``cutpoints``, ``function``(``x``)`` ``{`\
`      ``tp`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``precision_oncology_data``$``PD_L1_TPS`` ``>=`` ``x`` ``&`` ``response_binary`` ``==`` ``1``)`\
`      ``fp`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``precision_oncology_data``$``PD_L1_TPS`` ``>=`` ``x`` ``&`` ``response_binary`` ``==`` ``0``)`\
`      `[`round`](https://rdrr.io/r/base/Round.html)`(``tp`` ``/`` ``(``tp`` ``+`` ``fp``)``, ``3``)`\
`    ``}``)``,`\
`    NPV ``=`` `[`sapply`](https://rdrr.io/r/base/lapply.html)`(``cutpoints``, ``function``(``x``)`` ``{`\
`      ``tn`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``precision_oncology_data``$``PD_L1_TPS`` ``<`` ``x`` ``&`` ``response_binary`` ``==`` ``0``)`\
`      ``fn`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``precision_oncology_data``$``PD_L1_TPS`` ``<`` ``x`` ``&`` ``response_binary`` ``==`` ``1``)`\
`      `[`round`](https://rdrr.io/r/base/Round.html)`(``tn`` ``/`` ``(``tn`` ``+`` ``fn``)``, ``3``)`\
`    ``}``)`\
`  ``)`\
`  `\
`  `[`print`](https://rdrr.io/r/base/print.html)`(``"Performance at Different PD-L1 Cutpoints:"``)`\
`  `[`print`](https://rdrr.io/r/base/print.html)`(``performance_table``)`\
`}`

### Biomarker Test Validation

Assess clinical utility of biomarker testing.

\
`# Clinical utility analysis`\
`# Calculate number needed to test (NNT) for different biomarkers`\
\
`nnt_analysis`` ``<-`` ``function``(``biomarker_positive``, ``response_rate_positive``, ``response_rate_negative``, ``prevalence``)`` ``{`\
`  ``# Response rate difference`\
`  ``response_difference`` ``<-`` ``response_rate_positive`` ``-`` ``response_rate_negative`\
`  `\
`  ``# Number needed to treat with biomarker guidance`\
`  ``nnt`` ``<-`` ``1`` ``/`` ``(``response_difference`` ``*`` ``prevalence``)`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(``nnt``, ``1``)``)`\
`}`\
\
`# EGFR mutation NNT`\
`egfr_prevalence`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``precision_oncology_data``$``EGFR_Mutation`` ``==`` ``"Positive"``)`\
`egfr_pos_response`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``precision_oncology_data``$``Treatment_Response``[``precision_oncology_data``$``EGFR_Mutation`` ``==`` ``"Positive"``]`` `[`%in%`](https://rdrr.io/r/base/match.html)` `\
`                         `[`c`](https://rdrr.io/r/base/c.html)`(``"Complete_Response"``, ``"Partial_Response"``)``)`\
`egfr_neg_response`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``precision_oncology_data``$``Treatment_Response``[``precision_oncology_data``$``EGFR_Mutation`` ``==`` ``"Negative"``]`` `[`%in%`](https://rdrr.io/r/base/match.html)` `\
`                         `[`c`](https://rdrr.io/r/base/c.html)`(``"Complete_Response"``, ``"Partial_Response"``)``)`\
\
`egfr_nnt`` ``<-`` ``nnt_analysis``(``NULL``, ``egfr_pos_response``, ``egfr_neg_response``, ``egfr_prevalence``)`\
\
`# MSI-High NNT`\
`msi_prevalence`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``precision_oncology_data``$``MSI_Status`` ``==`` ``"MSI-High"``)`\
`msi_pos_response`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``precision_oncology_data``$``Treatment_Response``[``precision_oncology_data``$``MSI_Status`` ``==`` ``"MSI-High"``]`` `[`%in%`](https://rdrr.io/r/base/match.html)` `\
`                        `[`c`](https://rdrr.io/r/base/c.html)`(``"Complete_Response"``, ``"Partial_Response"``)``)`\
`msi_neg_response`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``precision_oncology_data``$``Treatment_Response``[``precision_oncology_data``$``MSI_Status`` ``!=`` ``"MSI-High"``]`` `[`%in%`](https://rdrr.io/r/base/match.html)` `\
`                        `[`c`](https://rdrr.io/r/base/c.html)`(``"Complete_Response"``, ``"Partial_Response"``)``)`\
\
`msi_nnt`` ``<-`` ``nnt_analysis``(``NULL``, ``msi_pos_response``, ``msi_neg_response``, ``msi_prevalence``)`\
\
`clinical_utility_table`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Biomarker ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"EGFR Mutation"``, ``"MSI-High Status"``)``,`\
`  Prevalence ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``egfr_prevalence``, ``msi_prevalence``)`` ``*`` ``100``, ``1``)``, ``"%"``)``,`\
`  Response_Rate_Positive ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``egfr_pos_response``, ``msi_pos_response``)`` ``*`` ``100``, ``1``)``, ``"%"``)``,`\
`  Response_Rate_Negative ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``egfr_neg_response``, ``msi_neg_response``)`` ``*`` ``100``, ``1``)``, ``"%"``)``,`\
`  Number_Needed_to_Test ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``egfr_nnt``, ``msi_nnt``)`\
`)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``"Clinical Utility Analysis:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``clinical_utility_table``)`

## Economic Evaluation

### Cost-Effectiveness Analysis

Assess economic impact of biomarker-guided therapy.

\
`# Simulate treatment costs and outcomes`\
`precision_oncology_data`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    ``# Estimate treatment costs based on therapy type`\
`    treatment_cost ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``primary_treatment`` ``==`` ``"EGFR TKI"`` ``~`` ``120000``,`\
`      ``primary_treatment`` ``==`` ``"HER2-Targeted Therapy"`` ``~`` ``150000``,`\
`      ``primary_treatment`` ``==`` ``"BRAF Inhibitor"`` ``~`` ``140000``,`\
`      ``primary_treatment`` ``==`` ``"ALK Inhibitor"`` ``~`` ``160000``,`\
`      ``immunotherapy_candidate`` ``==`` ``"First-line Immunotherapy"`` ``~`` ``180000``,`\
`      ``immunotherapy_candidate`` ``==`` ``"First-line Anti-PD-1"`` ``~`` ``150000``,`\
`      ``TRUE`` ``~`` ``80000``  ``# Standard chemotherapy`\
`    ``)``,`\
`    `\
`    ``# Estimate testing costs`\
`    testing_cost ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``biomarker_count`` ``==`` ``0`` ``~`` ``0``,`\
`      ``biomarker_count`` ``==`` ``1`` ``~`` ``1500``,`\
`      ``biomarker_count`` ``>=`` ``2`` ``~`` ``3000`\
`    ``)``,`\
`    `\
`    ``# Total cost per patient`\
`    total_cost ``=`` ``treatment_cost`` ``+`` ``testing_cost``,`\
`    `\
`    ``# Quality-adjusted life years (QALYs) based on response and survival`\
`    qalys ``=`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`      ``Treatment_Response`` ``==`` ``"Complete_Response"`` ``~`` ``PFS_Months`` ``*`` ``0.9`` ``/`` ``12``,`\
`      ``Treatment_Response`` ``==`` ``"Partial_Response"`` ``~`` ``PFS_Months`` ``*`` ``0.8`` ``/`` ``12``,`\
`      ``Treatment_Response`` ``==`` ``"Stable_Disease"`` ``~`` ``PFS_Months`` ``*`` ``0.7`` ``/`` ``12``,`\
`      ``Treatment_Response`` ``==`` ``"Progressive_Disease"`` ``~`` ``PFS_Months`` ``*`` ``0.4`` ``/`` ``12``,`\
`      ``TRUE`` ``~`` ``PFS_Months`` ``*`` ``0.5`` ``/`` ``12`\
`    ``)`\
`  ``)`\
\
`# Cost-effectiveness by biomarker strategy`\
`cost_effectiveness_summary`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``biomarker_category``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    n ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    mean_cost ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``total_cost``)``, ``0``)``,`\
`    mean_qalys ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``qalys``)``, ``2``)``,`\
`    cost_per_qaly ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``total_cost``)`` ``/`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``qalys``)``, ``0``)``,`\
`    response_rate ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``Treatment_Response`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"Complete_Response"``, ``"Partial_Response"``)``)`` ``*`` ``100``, ``1``)``,`\
`    .groups ``=`` ``'drop'`\
`  ``)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``"Cost-Effectiveness by Biomarker Strategy:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``cost_effectiveness_summary``)`\
\
`# Incremental cost-effectiveness ratio (ICER)`\
`no_biomarker_cost`` ``<-`` ``cost_effectiveness_summary``$``mean_cost``[``cost_effectiveness_summary``$``biomarker_category`` ``==`` ``"No Actionable Biomarkers"``]`\
`single_biomarker_cost`` ``<-`` ``cost_effectiveness_summary``$``mean_cost``[``cost_effectiveness_summary``$``biomarker_category`` ``==`` ``"Single Biomarker"``]`\
\
`no_biomarker_qaly`` ``<-`` ``cost_effectiveness_summary``$``mean_qalys``[``cost_effectiveness_summary``$``biomarker_category`` ``==`` ``"No Actionable Biomarkers"``]`\
`single_biomarker_qaly`` ``<-`` ``cost_effectiveness_summary``$``mean_qalys``[``cost_effectiveness_summary``$``biomarker_category`` ``==`` ``"Single Biomarker"``]`\
\
`if``(`[`length`](https://rdrr.io/r/base/length.html)`(``no_biomarker_cost``)`` ``>`` ``0`` ``&&`` `[`length`](https://rdrr.io/r/base/length.html)`(``single_biomarker_cost``)`` ``>`` ``0``)`` ``{`\
`  ``icer`` ``<-`` ``(``single_biomarker_cost`` ``-`` ``no_biomarker_cost``)`` ``/`` ``(``single_biomarker_qaly`` ``-`` ``no_biomarker_qaly``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"ICER (Single Biomarker vs No Biomarker): $"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``icer``, ``0``)``, ``" per QALY\n"``)`\
`  `\
`  ``# Cost-effectiveness threshold interpretation`\
`  ``if``(``icer`` ``<`` ``50000``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Interpretation: Highly cost-effective (< $50,000/QALY)\n"``)`\
`  ``}`` ``else`` ``if``(``icer`` ``<`` ``100000``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Interpretation: Cost-effective (< $100,000/QALY)\n"``)`\
`  ``}`` ``else`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Interpretation: Not cost-effective (> $100,000/QALY)\n"``)`\
`  ``}`\
`}`

## Clinical Decision Support

### Treatment Selection Dashboard

Create a clinical decision support framework.

\
`# Function to generate treatment recommendations`\
`generate_treatment_recommendation`` ``<-`` ``function``(``patient_data``)`` ``{`\
`  ``recommendations`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``)`\
`  `\
`  ``# Check for targetable alterations`\
`  ``if``(``patient_data``$``EGFR_Mutation`` ``==`` ``"Positive"``)`` ``{`\
`    ``recommendations``$``targeted`` ``<-`` ``"EGFR TKI (osimertinib, erlotinib)"`\
`    ``recommendations``$``evidence_level`` ``<-`` ``"1A"`\
`  ``}`` ``else`` ``if``(``patient_data``$``ALK_Fusion`` ``==`` ``"Positive"``)`` ``{`\
`    ``recommendations``$``targeted`` ``<-`` ``"ALK inhibitor (alectinib, crizotinib)"`\
`    ``recommendations``$``evidence_level`` ``<-`` ``"1A"`\
`  ``}`` ``else`` ``if``(``patient_data``$``HER2_FISH_Status`` ``==`` ``"Amplified"``)`` ``{`\
`    ``recommendations``$``targeted`` ``<-`` ``"HER2-targeted therapy (trastuzumab + pertuzumab)"`\
`    ``recommendations``$``evidence_level`` ``<-`` ``"1A"`\
`  ``}`` ``else`` ``if``(``patient_data``$``BRAF_Mutation`` ``==`` ``"Positive"``)`` ``{`\
`    ``recommendations``$``targeted`` ``<-`` ``"BRAF inhibitor (vemurafenib + cobimetinib)"`\
`    ``recommendations``$``evidence_level`` ``<-`` ``"1B"`\
`  ``}`\
`  `\
`  ``# Check for immunotherapy eligibility`\
`  ``if``(``patient_data``$``MSI_Status`` ``==`` ``"MSI-High"``)`` ``{`\
`    ``recommendations``$``immunotherapy`` ``<-`` ``"Anti-PD-1 monotherapy (pembrolizumab)"`\
`    ``recommendations``$``immuno_evidence`` ``<-`` ``"1A"`\
`  ``}`` ``else`` ``if``(``patient_data``$``PD_L1_TPS`` ``>=`` ``50``)`` ``{`\
`    ``recommendations``$``immunotherapy`` ``<-`` ``"Anti-PD-1 monotherapy (pembrolizumab)"`\
`    ``recommendations``$``immuno_evidence`` ``<-`` ``"1A"`\
`  ``}`` ``else`` ``if``(``patient_data``$``PD_L1_TPS`` ``>=`` ``1``)`` ``{`\
`    ``recommendations``$``immunotherapy`` ``<-`` ``"Combination immunotherapy"`\
`    ``recommendations``$``immuno_evidence`` ``<-`` ``"1B"`\
`  ``}`\
`  `\
`  ``# Default to chemotherapy if no actionable alterations`\
`  ``if``(`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``recommendations``$``targeted``)`` ``&&`` `[`is.null`](https://rdrr.io/r/base/NULL.html)`(``recommendations``$``immunotherapy``)``)`` ``{`\
`    ``recommendations``$``default`` ``<-`` ``"Standard chemotherapy"`\
`    ``recommendations``$``default_evidence`` ``<-`` ``"1A"`\
`  ``}`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``recommendations``)`\
`}`\
\
`# Example patient recommendations`\
`example_patients`` ``<-`` ``precision_oncology_data``[``1``:``5``, ``]`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Treatment Recommendations for Sample Patients:\n\n"``)`\
`for``(``i`` ``in`` ``1``:`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``example_patients``)``)`` ``{`\
`  ``patient`` ``<-`` ``example_patients``[``i``, ``]`\
`  ``recommendations`` ``<-`` ``generate_treatment_recommendation``(``patient``)`\
`  `\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Patient"``, ``patient``$``Patient_ID``, ``"("``, ``patient``$``Tumor_Type``, ``"):\n"``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Age:"``, ``patient``$``Age``, ``", Grade:"``, ``patient``$``Grade``, ``"\n"``)`\
`  `\
`  ``# Print biomarker status`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Biomarkers: "``)`\
`  ``if``(``patient``$``EGFR_Mutation`` ``==`` ``"Positive"``)`` `[`cat`](https://rdrr.io/r/base/cat.html)`(``"EGFR+ "``)`\
`  ``if``(``patient``$``ALK_Fusion`` ``==`` ``"Positive"``)`` `[`cat`](https://rdrr.io/r/base/cat.html)`(``"ALK+ "``)`\
`  ``if``(``patient``$``HER2_FISH_Status`` ``==`` ``"Amplified"``)`` `[`cat`](https://rdrr.io/r/base/cat.html)`(``"HER2+ "``)`\
`  ``if``(``patient``$``MSI_Status`` ``==`` ``"MSI-High"``)`` `[`cat`](https://rdrr.io/r/base/cat.html)`(``"MSI-H "``)`\
`  ``if``(``patient``$``PD_L1_TPS`` ``>=`` ``50``)`` `[`cat`](https://rdrr.io/r/base/cat.html)`(``"PD-L1 high "``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"\n"``)`\
`  `\
`  ``# Print recommendations`\
`  ``if``(``!`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``recommendations``$``targeted``)``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Recommended:"``, ``recommendations``$``targeted``, ``"(Evidence:"``, ``recommendations``$``evidence_level``, ``")\n"``)`\
`  ``}`\
`  ``if``(``!`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``recommendations``$``immunotherapy``)``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Alternative:"``, ``recommendations``$``immunotherapy``, ``"(Evidence:"``, ``recommendations``$``immuno_evidence``, ``")\n"``)`\
`  ``}`\
`  ``if``(``!`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``recommendations``$``default``)``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Recommended:"``, ``recommendations``$``default``, ``"(Evidence:"``, ``recommendations``$``default_evidence``, ``")\n"``)`\
`  ``}`\
`  `\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Actual Response:"``, ``patient``$``Treatment_Response``, ``"\n"``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"PFS:"``, ``patient``$``PFS_Months``, ``"months\n\n"``)`\
`}`

## Quality Assurance in Precision Oncology

### Biomarker Testing Quality Metrics

Monitor quality of molecular testing programs.

\
`# Simulate quality metrics for biomarker testing`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``123``)`\
`quality_metrics`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`\
`    ``# Simulate testing quality metrics`\
`    turnaround_time ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(`[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``, mean ``=`` ``7``, sd ``=`` ``2``)``)``,`\
`    test_success_rate ``=`` `[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"Success"``, ``"Failed"``, ``"Repeat"``)``, `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``, `\
`                              prob ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.85``, ``0.05``, ``0.10``)``, replace ``=`` ``TRUE``)``,`\
`    reporting_clarity ``=`` `[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"Clear"``, ``"Adequate"``, ``"Unclear"``)``, `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`                              prob ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.80``, ``0.15``, ``0.05``)``, replace ``=`` ``TRUE``)`\
`  ``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``Tumor_Type``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    n_tests ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    mean_tat ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``turnaround_time``)``, ``1``)``,`\
`    success_rate ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``test_success_rate`` ``==`` ``"Success"``)`` ``*`` ``100``, ``1``)``,`\
`    clear_reporting ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``reporting_clarity`` ``==`` ``"Clear"``)`` ``*`` ``100``, ``1``)``,`\
`    actionable_rate ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``biomarker_count`` ``>`` ``0``)`` ``*`` ``100``, ``1``)``,`\
`    .groups ``=`` ``'drop'`\
`  ``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(`[`desc`](https://dplyr.tidyverse.org/reference/desc.html)`(``n_tests``)``)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``"Quality Metrics by Tumor Type:"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``quality_metrics``)`\
\
`# Overall quality dashboard`\
`overall_quality`` ``<-`` ``precision_oncology_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(`\
`    total_patients ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``,`\
`    actionable_biomarker_rate ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``biomarker_count`` ``>`` ``0``)`` ``*`` ``100``, ``1``)``,`\
`    multiple_biomarker_rate ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``biomarker_count`` ``>`` ``1``)`` ``*`` ``100``, ``1``)``,`\
`    targeted_therapy_eligible ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``primary_treatment`` ``!=`` ``"Standard Chemotherapy"``)`` ``*`` ``100``, ``1``)``,`\
`    immunotherapy_eligible ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``immunotherapy_candidate`` ``!=`` ``"Chemotherapy First"``)`` ``*`` ``100``, ``1``)`\
`  ``)`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Overall Precision Oncology Quality Dashboard:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Total patients tested:"``, ``overall_quality``$``total_patients``, ``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Actionable biomarker rate:"``, ``overall_quality``$``actionable_biomarker_rate``, ``"%\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Multiple biomarker rate:"``, ``overall_quality``$``multiple_biomarker_rate``, ``"%\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Targeted therapy eligible:"``, ``overall_quality``$``targeted_therapy_eligible``, ``"%\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Immunotherapy eligible:"``, ``overall_quality``$``immunotherapy_eligible``, ``"%\n"``)`

## Conclusion

This comprehensive precision oncology analysis demonstrates the
complexity and clinical value of biomarker-guided cancer care. Key
findings include:

1.  **High Actionable Rate**: \>60% of patients have actionable
    biomarkers
2.  **Improved Outcomes**: Biomarker-positive patients show better
    response rates
3.  **Cost-Effectiveness**: Targeted therapy provides favorable
    cost-utility ratios
4.  **Clinical Utility**: Significant survival benefit with
    biomarker-guided treatment
5.  **Quality Assurance**: Robust QC metrics ensure reliable testing

### Implementation Recommendations

1.  **Comprehensive Testing**: Implement broad molecular profiling
    panels
2.  **Rapid Turnaround**: Achieve \<7-day reporting for treatment
    decisions
3.  **Clinical Integration**: Embed recommendations in electronic health
    records
4.  **Outcome Tracking**: Monitor real-world effectiveness of biomarker
    strategies
5.  **Cost Monitoring**: Evaluate economic impact and adjust coverage
    policies

### Future Directions

- **Liquid Biopsy Integration**: Circulating tumor DNA monitoring
- **Artificial Intelligence**: Machine learning for biomarker
  interpretation
- **Real-World Evidence**: Population-based outcome studies
- **Combination Biomarkers**: Multi-analyte predictive models
- **Resistance Monitoring**: Dynamic biomarker assessment during
  treatment

------------------------------------------------------------------------

*This vignette demonstrates advanced precision oncology workflows using
the ClinicoPath suite. For additional biomarker analysis examples,
explore related vignettes on ROC analysis and survival analysis.*
