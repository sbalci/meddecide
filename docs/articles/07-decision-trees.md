# Decision Tree and Markov Chain Analysis Examples

## Overview

This vignette provides comprehensive examples explaining both decision
tree and Markov chain analysis types implemented in the ClinicoPath
jamovi module.

## Decision Tree Analysis Example

### Scenario: Acute Appendicitis Treatment Decision

**Clinical Question:** Should a patient with suspected appendicitis
receive immediate surgery or conservative treatment?

#### Creating Example Data

\
`# Create decision tree example data`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``123``)`\
`n_patients`` ``<-`` ``100`\
\
`appendicitis_decision_data`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  patient_id ``=`` ``1``:``n_patients``,`\
\
`  ``# DECISION NODES (Square boxes)`\
`  treatment_choice ``=`` `[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"Immediate Surgery"``, ``"Conservative Treatment"``)``,`\
`                           ``n_patients``, replace ``=`` ``TRUE``)``,`\
\
`  ``# PROBABILITY VARIABLES (for chance nodes - circles)`\
`  prob_appendicitis_confirmed ``=`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_patients``, ``0.7``, ``0.9``)``,     ``# Probability patient actually has appendicitis`\
`  prob_surgery_success ``=`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_patients``, ``0.95``, ``0.99``)``,          ``# Surgery success rate`\
`  prob_conservative_success ``=`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_patients``, ``0.6``, ``0.8``)``,       ``# Conservative treatment success`\
`  prob_complications_surgery ``=`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_patients``, ``0.02``, ``0.08``)``,    ``# Surgery complications`\
`  prob_complications_conservative ``=`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_patients``, ``0.15``, ``0.25``)``, ``# Conservative complications`\
\
`  ``# COST VARIABLES (outcomes)`\
`  cost_surgery ``=`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_patients``, ``12000``, ``2000``)``,                 ``# Surgery costs`\
`  cost_conservative ``=`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_patients``, ``3000``, ``500``)``,              ``# Conservative treatment costs`\
`  cost_complications ``=`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_patients``, ``8000``, ``1500``)``,            ``# Complication management costs`\
`  cost_failed_conservative ``=`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_patients``, ``15000``, ``2500``)``,     ``# Emergency surgery after failed conservative`\
\
`  ``# UTILITY VARIABLES (quality of life outcomes)`\
`  utility_success ``=`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_patients``, ``0.95``, ``1.0``)``,               ``# Full recovery`\
`  utility_minor_complications ``=`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_patients``, ``0.8``, ``0.9``)``,    ``# Recovery with minor issues`\
`  utility_major_complications ``=`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_patients``, ``0.6``, ``0.8``)``,    ``# Recovery with major issues`\
\
`  ``# OUTCOME VARIABLES (terminal nodes - triangles)`\
`  clinical_outcome ``=`` `[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"Complete Recovery"``, ``"Minor Complications"``, ``"Major Complications"``)``,`\
`                           ``n_patients``, replace ``=`` ``TRUE``, prob ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.8``, ``0.15``, ``0.05``)``)`\
`)`\
\
`# Display first few rows`\
[`head`](https://rdrr.io/r/utils/head.html)`(``appendicitis_decision_data``, ``5``)`

#### Decision Tree Structure

The decision tree has the following structure:

1.  **DECISION NODE (Square):** Treatment Choice
    - Option A: Immediate Surgery
    - Option B: Conservative Treatment
2.  **CHANCE NODES (Circles):** Probabilistic Outcomes
    - For Surgery:
      - Success (95-99%): Low cost, high utility
      - Complications (2-8%): Higher cost, lower utility
    - For Conservative:
      - Success (60-80%): Low cost, high utility
      - Failure (20-40%): Requires emergency surgery
3.  **TERMINAL NODES (Triangles):** Final Outcomes
    - Each path ends with:
      - Cost: \$3,000 - \$20,000
      - Utility: 0.6 - 1.0 QALYs

#### Expected Value Calculations

\
`# Calculate expected values for decision tree`\
`surgery_expected_cost`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``appendicitis_decision_data``$``cost_surgery`` ``+`\
`                             ``appendicitis_decision_data``$``prob_complications_surgery`` ``*`\
`                             ``appendicitis_decision_data``$``cost_complications``)`\
\
`conservative_expected_cost`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``appendicitis_decision_data``$``cost_conservative`` ``+`\
`                                  ``(``1`` ``-`` ``appendicitis_decision_data``$``prob_conservative_success``)`` ``*`\
`                                  ``appendicitis_decision_data``$``cost_failed_conservative``)`\
\
`surgery_expected_utility`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``appendicitis_decision_data``$``utility_success`` ``*`\
`                                ``appendicitis_decision_data``$``prob_surgery_success`` ``+`\
`                                ``appendicitis_decision_data``$``utility_minor_complications`` ``*`\
`                                ``appendicitis_decision_data``$``prob_complications_surgery``)`\
\
`conservative_expected_utility`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``appendicitis_decision_data``$``utility_success`` ``*`\
`                                     ``appendicitis_decision_data``$``prob_conservative_success`` ``+`\
`                                     ``appendicitis_decision_data``$``utility_major_complications`` ``*`\
`                                     ``(``1`` ``-`` ``appendicitis_decision_data``$``prob_conservative_success``)``)`\
\
`# Calculate ICER`\
`incremental_cost`` ``<-`` ``surgery_expected_cost`` ``-`` ``conservative_expected_cost`\
`incremental_utility`` ``<-`` ``surgery_expected_utility`` ``-`` ``conservative_expected_utility`\
`icer`` ``<-`` ``incremental_cost`` ``/`` ``incremental_utility`\
\
`# Display results`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"DECISION TREE ANALYSIS RESULTS:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"===============================\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Surgery Strategy:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"  Expected Cost: $"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``surgery_expected_cost``, ``0``)``, ``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"  Expected Utility:"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``surgery_expected_utility``, ``3``)``, ``"QALYs\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Conservative Strategy:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"  Expected Cost: $"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``conservative_expected_cost``, ``0``)``, ``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"  Expected Utility:"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``conservative_expected_utility``, ``3``)``, ``"QALYs\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Cost-Effectiveness Analysis:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"  Incremental Cost: $"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``incremental_cost``, ``0``)``, ``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"  Incremental Utility:"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``incremental_utility``, ``3``)``, ``"QALYs\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"  ICER: $"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``icer``, ``0``)``, ``"per QALY\n"``)`\
\
`if`` ``(``icer`` ``<`` ``50000``)`` ``{`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"  ✓ Surgery is cost-effective (ICER < $50,000/QALY)\n"``)`\
`}`` ``else`` ``{`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"  ⚠ Surgery may not be cost-effective (ICER > $50,000/QALY)\n"``)`\
`}`

#### Decision Tree Interpretation

Decision trees are ideal for:

- One-time decisions with immediate outcomes
- Comparing 2-3 distinct treatment strategies
- Situations where timing is not critical
- When outcomes occur relatively quickly (days to months)
- Point-in-time cost-effectiveness analysis

## Markov Chain Analysis Example

### Scenario: Chronic Heart Disease Management

**Clinical Question:** What is the long-term cost-effectiveness of
different heart disease management strategies?

#### Creating Markov Data

\
`# Create Markov chain example data`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``456``)`\
`n_strategies`` ``<-`` ``150`\
\
`# First create basic structure`\
`heart_disease_markov_data`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  strategy_id ``=`` ``1``:``n_strategies``,`\
\
`  ``# DECISION VARIABLES`\
`  management_strategy ``=`` `[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"Standard Care"``, ``"Intensive Monitoring"``, ``"Preventive Surgery"``)``,`\
`                              ``n_strategies``, replace ``=`` ``TRUE``)``,`\
`  patient_risk_category ``=`` `[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"Low Risk"``, ``"Moderate Risk"``, ``"High Risk"``)``,`\
`                                ``n_strategies``, replace ``=`` ``TRUE``, prob ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.4``, ``0.4``, ``0.2``)``)`\
`)`\
\
`# Add transition probabilities`\
`heart_disease_markov_data``$``prob_asymp_to_symp`` ``<-`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`  ``heart_disease_markov_data``$``management_strategy`` ``==`` ``"Standard Care"`` ``~`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.08``, ``0.12``)``,`\
`  ``heart_disease_markov_data``$``management_strategy`` ``==`` ``"Intensive Monitoring"`` ``~`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.05``, ``0.08``)``,`\
`  ``heart_disease_markov_data``$``management_strategy`` ``==`` ``"Preventive Surgery"`` ``~`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.02``, ``0.05``)`\
`)`\
\
`heart_disease_markov_data``$``prob_asymp_to_death`` ``<-`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.01``, ``0.02``)`\
\
`# From Symptomatic state`\
`heart_disease_markov_data``$``prob_symp_to_hf`` ``<-`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`  ``heart_disease_markov_data``$``management_strategy`` ``==`` ``"Standard Care"`` ``~`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.15``, ``0.25``)``,`\
`  ``heart_disease_markov_data``$``management_strategy`` ``==`` ``"Intensive Monitoring"`` ``~`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.10``, ``0.18``)``,`\
`  ``heart_disease_markov_data``$``management_strategy`` ``==`` ``"Preventive Surgery"`` ``~`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.05``, ``0.12``)`\
`)`\
\
`heart_disease_markov_data``$``prob_symp_to_death`` ``<-`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.02``, ``0.04``)`\
\
`# From Heart Failure state`\
`heart_disease_markov_data``$``prob_hf_to_death`` ``<-`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.12``, ``0.20``)`\
\
`# STATE-SPECIFIC ANNUAL COSTS`\
`heart_disease_markov_data``$``cost_asymptomatic`` ``<-`` `[`case_when`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)`(`\
`  ``heart_disease_markov_data``$``management_strategy`` ``==`` ``"Standard Care"`` ``~`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_strategies``, ``2000``, ``300``)``,`\
`  ``heart_disease_markov_data``$``management_strategy`` ``==`` ``"Intensive Monitoring"`` ``~`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_strategies``, ``4000``, ``500``)``,`\
`  ``heart_disease_markov_data``$``management_strategy`` ``==`` ``"Preventive Surgery"`` ``~`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_strategies``, ``8000``, ``1000``)`\
`)`\
\
`heart_disease_markov_data``$``cost_symptomatic`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_strategies``, ``12000``, ``2000``)`\
`heart_disease_markov_data``$``cost_heart_failure`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_strategies``, ``35000``, ``5000``)`\
`heart_disease_markov_data``$``cost_death`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``0``, ``n_strategies``)``  ``# No ongoing costs after death`\
\
`# STATE-SPECIFIC ANNUAL UTILITIES (Quality of Life)`\
`heart_disease_markov_data``$``utility_asymptomatic`` ``<-`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.90``, ``0.95``)`\
`heart_disease_markov_data``$``utility_symptomatic`` ``<-`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.70``, ``0.80``)`\
`heart_disease_markov_data``$``utility_heart_failure`` ``<-`` `[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_strategies``, ``0.45``, ``0.60``)`\
`heart_disease_markov_data``$``utility_death`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``0``, ``n_strategies``)``  ``# No utility after death`\
\
`# Display first few rows`\
[`head`](https://rdrr.io/r/utils/head.html)`(``heart_disease_markov_data``, ``5``)`

#### Markov Chain Structure

**HEALTH STATES (Markov States):**

1.  Asymptomatic Heart Disease
2.  Symptomatic Heart Disease\
3.  Heart Failure
4.  Death (Absorbing State)

**TRANSITION PATHWAYS:**

    Asymptomatic → Symptomatic → Heart Failure → Death
                 ↘ Death        ↘ Death

#### Transition Matrix Example

\
`# Create example transition matrix for Standard Care`\
`states`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Asymptomatic"``, ``"Symptomatic"``, ``"Heart Failure"``, ``"Death"``)`\
`trans_matrix_standard`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(``0``, nrow ``=`` ``4``, ncol ``=`` ``4``)`\
[`rownames`](https://rdrr.io/r/base/colnames.html)`(``trans_matrix_standard``)`` ``<-`` ``states`\
[`colnames`](https://rdrr.io/r/base/colnames.html)`(``trans_matrix_standard``)`` ``<-`` ``states`\
\
`# Fill transition matrix with average probabilities for Standard Care`\
`standard_data`` ``<-`` ``heart_disease_markov_data``[``heart_disease_markov_data``$``management_strategy`` ``==`` ``"Standard Care"``, ``]`\
\
`trans_matrix_standard``[``1``, ``1``]`` ``<-`` ``1`` ``-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``prob_asymp_to_symp``)`` ``-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``prob_asymp_to_death``)``  ``# Stay asymptomatic`\
`trans_matrix_standard``[``1``, ``2``]`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``prob_asymp_to_symp``)``  ``# Asymp to symptomatic`\
`trans_matrix_standard``[``1``, ``4``]`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``prob_asymp_to_death``)``  ``# Asymp to death`\
\
`trans_matrix_standard``[``2``, ``2``]`` ``<-`` ``1`` ``-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``prob_symp_to_hf``)`` ``-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``prob_symp_to_death``)``  ``# Stay symptomatic`\
`trans_matrix_standard``[``2``, ``3``]`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``prob_symp_to_hf``)``  ``# Symp to heart failure`\
`trans_matrix_standard``[``2``, ``4``]`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``prob_symp_to_death``)``  ``# Symp to death`\
\
`trans_matrix_standard``[``3``, ``3``]`` ``<-`` ``1`` ``-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``prob_hf_to_death``)``  ``# Stay in heart failure`\
`trans_matrix_standard``[``3``, ``4``]`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``prob_hf_to_death``)``  ``# HF to death`\
\
`trans_matrix_standard``[``4``, ``4``]`` ``<-`` ``1.0``  ``# Death is absorbing`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"EXAMPLE TRANSITION MATRIX (Standard Care):\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"=========================================\n"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(``trans_matrix_standard``, ``3``)``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nRow sums (should equal 1.0):"``, `[`round`](https://rdrr.io/r/base/Round.html)`(`[`rowSums`](https://rdrr.io/pkg/Matrix/man/colSums-methods.html)`(``trans_matrix_standard``)``, ``3``)``, ``"\n"``)`

#### Markov Cohort Simulation

\
`# Run Markov cohort simulation`\
`num_cycles`` ``<-`` ``20`\
`cohort_trace`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(``0``, nrow ``=`` ``num_cycles`` ``+`` ``1``, ncol ``=`` ``4``)`\
[`colnames`](https://rdrr.io/r/base/colnames.html)`(``cohort_trace``)`` ``<-`` ``states`\
\
`# Initial distribution: Everyone starts asymptomatic`\
`cohort_trace``[``1``, ``1``]`` ``<-`` ``1.0`\
\
`# Run Markov simulation`\
`for`` ``(``cycle`` ``in`` ``2``:``(``num_cycles`` ``+`` ``1``)``)`` ``{`\
`  ``cohort_trace``[``cycle``, ``]`` ``<-`` ``cohort_trace``[``cycle`` ``-`` ``1``, ``]`` `[`%*%`](https://rdrr.io/r/base/matmult.html)` ``trans_matrix_standard`\
`}`\
\
`# Create summary table`\
`trace_df`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Year ``=`` ``0``:``num_cycles``,`\
`  Asymptomatic ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``cohort_trace``[``, ``1``]`` ``*`` ``100``, ``1``)``,`\
`  Symptomatic ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``cohort_trace``[``, ``2``]`` ``*`` ``100``, ``1``)``,`\
`  Heart_Failure ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``cohort_trace``[``, ``3``]`` ``*`` ``100``, ``1``)``,`\
`  Death ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``cohort_trace``[``, ``4``]`` ``*`` ``100``, ``1``)`\
`)`\
\
`# Show key time points`\
`key_years`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``1``, ``6``, ``11``, ``16``, ``21``)``  ``# 0, 5, 10, 15, 20 years`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Population distribution over time:\n"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``trace_df``[``key_years``, ``]``)`

#### Cost-Effectiveness Calculation

\
`# Calculate costs and utilities for Standard Care`\
`state_costs`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``cost_asymptomatic``)``,`\
`                `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``cost_symptomatic``)``,`\
`                `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``cost_heart_failure``)``,`\
`                ``0``)``  ``# Death`\
\
`state_utilities`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``utility_asymptomatic``)``,`\
`                    `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``utility_symptomatic``)``,`\
`                    `[`mean`](https://rdrr.io/r/base/mean.html)`(``standard_data``$``utility_heart_failure``)``,`\
`                    ``0``)``  ``# Death`\
\
[`names`](https://rdrr.io/r/base/names.html)`(``state_costs``)`` ``<-`` ``states`\
[`names`](https://rdrr.io/r/base/names.html)`(``state_utilities``)`` ``<-`` ``states`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Annual costs per state:\n"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(``state_costs``, ``0``)``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nAnnual utilities per state:\n"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(``state_utilities``, ``3``)``)`\
\
`# Calculate cumulative discounted costs and utilities`\
`discount_rate`` ``<-`` ``0.03`\
`cumulative_costs`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``0``, ``num_cycles`` ``+`` ``1``)`\
`cumulative_utilities`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``0``, ``num_cycles`` ``+`` ``1``)`\
\
`for`` ``(``cycle`` ``in`` ``2``:``(``num_cycles`` ``+`` ``1``)``)`` ``{`\
`  ``# Calculate cycle costs and utilities`\
`  ``cycle_cost`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``cohort_trace``[``cycle``, ``]`` ``*`` ``state_costs``)`\
`  ``cycle_utility`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``cohort_trace``[``cycle``, ``]`` ``*`` ``state_utilities``)`\
\
`  ``# Apply discounting`\
`  ``discount_factor`` ``<-`` ``(``1`` ``+`` ``discount_rate``)``^``(``-``(``cycle`` ``-`` ``1``)``)`\
\
`  ``cumulative_costs``[``cycle``]`` ``<-`` ``cumulative_costs``[``cycle`` ``-`` ``1``]`` ``+`` ``cycle_cost`` ``*`` ``discount_factor`\
`  ``cumulative_utilities``[``cycle``]`` ``<-`` ``cumulative_utilities``[``cycle`` ``-`` ``1``]`` ``+`` ``cycle_utility`` ``*`` ``discount_factor`\
`}`\
\
`# Final results`\
`final_cost`` ``<-`` ``cumulative_costs``[``num_cycles`` ``+`` ``1``]`\
`final_qalys`` ``<-`` ``cumulative_utilities``[``num_cycles`` ``+`` ``1``]`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nFINAL 20-YEAR RESULTS (Standard Care):\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Total Lifetime Cost: $"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``final_cost``, ``0``)``, ``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Total Lifetime QALYs:"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``final_qalys``, ``2``)``, ``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Cost per QALY: $"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``final_cost`` ``/`` ``final_qalys``, ``0``)``, ``"\n"``)`

#### Markov Chain Interpretation

Markov chains are ideal for:

- Chronic diseases with multiple stages
- Long-term cost-effectiveness analysis (years to lifetime)
- Disease progression modeling
- Comparing interventions with different timing effects
- Policy decisions affecting population health
- When disease states change over time
- Recurring decisions or ongoing treatments

## When to Use Each Method

### Comparison Table

\
`comparison_table`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Aspect ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Time Horizon"``, ``"Disease Type"``, ``"Decision Complexity"``, ``"Outcomes"``,`\
`             ``"Costs"``, ``"Best For"``, ``"Data Requirements"``, ``"Computational Needs"``)``,`\
`  Decision_Tree ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Short-term (days-months)"``, ``"Acute conditions"``, ``"Simple (2-3 options)"``,`\
`                   ``"One-time outcomes"``, ``"One-time costs"``, ``"Treatment selection"``,`\
`                   ``"Probabilities, costs, utilities"``, ``"Low"``)``,`\
`  Markov_Chain ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Long-term (years-lifetime)"``, ``"Chronic conditions"``, ``"Complex strategies"``,`\
`                  ``"Recurring outcomes"``, ``"Ongoing costs"``, ``"Disease management"``,`\
`                  ``"Transition probabilities, state costs"``, ``"Higher"``)`\
`)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``comparison_table``)`

### Example Applications

**DECISION TREES are best for:**

- Emergency treatment decisions (appendicitis, trauma)
- Surgical vs non-surgical interventions
- Diagnostic test decisions
- Vaccination decisions
- One-time screening decisions

**MARKOV CHAINS are best for:**

- Chronic disease management (diabetes, heart disease)
- Cancer progression and treatment
- Addiction treatment programs
- Preventive intervention policies
- Healthcare resource planning
- Long-term pharmaceutical studies

### Combined Approaches

Some complex problems benefit from both:

1.  Decision tree for initial treatment choice
2.  Markov chain for long-term disease progression

**Example:** Cancer treatment selection (tree) + survival modeling
(Markov)

## Summary

This vignette demonstrates practical applications of both decision tree
and Markov chain methods for medical decision analysis and
cost-effectiveness research. The generated datasets can be used with the
ClinicoPath jamovi module to perform these analyses interactively.

### Generated Datasets

The example code creates two key datasets:

- `appendicitis_decision_data` - Decision tree example
- `heart_disease_markov_data` - Markov chain example

These datasets demonstrate realistic medical scenarios and can be used
to practice both analysis types in jamovi.

### Next Steps

- Load these datasets into jamovi
- Use the ClinicoPath decision analysis modules
- Practice interpreting cost-effectiveness results
- Apply these methods to your own research questions
