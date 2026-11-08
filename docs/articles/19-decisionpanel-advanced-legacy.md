# Advanced Features and Customization in Decision Panel Optimization

> **Not yet released in meddecide.** This article documents
> `decisionpanel`, which is not part of the meddecide 1.0.4 release. It
> is documented here ahead of a future release, so the options, defaults
> and output described below are subject to change and the analysis will
> not appear in your jamovi menu yet. For the analyses that ship today
> see the [meddecide articles
> index](https://www.serdarbalci.com/meddecide/articles/).

## Introduction

This vignette covers advanced features of the Decision Panel
Optimization module, including custom optimization functions, complex
constraints, and programmatic access to results.

\
`# Load required packages`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`rpart`](https://github.com/bethatkinson/rpart)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`rpart.plot`](http://www.milbo.org/rpart-plot/index.md)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`knitr`](https://yihui.org/knitr/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`forcats`](https://forcats.tidyverse.org/)`)`

\
`# Set seed for reproducibility`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``123``)`

## Custom Optimization Functions

### Defining Custom Utility Functions

The module allows custom utility functions that incorporate
domain-specific knowledge:

\
`# Define a custom utility function for COVID screening`\
`# Prioritizes not missing cases while considering hospital capacity`\
`covid_utility`` ``<-`` ``function``(``TP``, ``FP``, ``TN``, ``FN``, ``test_cost``, ``hospital_capacity`` ``=`` ``100``)`` ``{`\
`  ``# Base utilities`\
`  ``u_TP`` ``<-`` ``100``    ``# Correctly identified case`\
`  ``u_TN`` ``<-`` ``10``     ``# Correctly ruled out`\
`  ``u_FP`` ``<-`` ``-``20``    ``# Unnecessary isolation`\
`  ``u_FN`` ``<-`` ``-``1000``  ``# Missed case (high penalty)`\
`  `\
`  ``# Capacity penalty - increases FP cost when near capacity`\
`  ``current_positives`` ``<-`` ``TP`` ``+`` ``FP`\
`  ``capacity_factor`` ``<-`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``current_positives`` ``>`` ``hospital_capacity`` ``*`` ``0.8``,`\
`                           ``(``current_positives`` ``/`` ``hospital_capacity``)``^``2``,`\
`                           ``1``)`\
`  ``u_FP_adjusted`` ``<-`` ``u_FP`` ``*`` ``capacity_factor`\
`  `\
`  ``# Calculate total utility`\
`  ``total_utility`` ``<-`` ``(``TP`` ``*`` ``u_TP`` ``+`` ``TN`` ``*`` ``u_TN`` ``+`` `\
`                   ``FP`` ``*`` ``u_FP_adjusted`` ``+`` ``FN`` ``*`` ``u_FN`` ``-`` ``test_cost``)`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``total_utility``)`\
`}`\
\
`# Example calculation`\
`n_total`` ``<-`` ``1000`\
`prevalence`` ``<-`` ``0.15`\
`test_cost`` ``<-`` ``55``  ``# Combined test cost`\
\
`# Scenario 1: Low capacity`\
`utility_low_capacity`` ``<-`` ``covid_utility``(`\
`  TP ``=`` ``147``,  ``# 98% sensitivity`\
`  FP ``=`` ``26``,   ``# 97% specificity  `\
`  TN ``=`` ``824``,`\
`  FN ``=`` ``3``,`\
`  test_cost ``=`` ``test_cost``,`\
`  hospital_capacity ``=`` ``50`\
`)`\
\
`# Scenario 2: High capacity`\
`utility_high_capacity`` ``<-`` ``covid_utility``(`\
`  TP ``=`` ``147``,`\
`  FP ``=`` ``26``,`\
`  TN ``=`` ``824``,`\
`  FN ``=`` ``3``,`\
`  test_cost ``=`` ``test_cost``,`\
`  hospital_capacity ``=`` ``200`\
`)`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Utility with low capacity:"``, ``utility_low_capacity``, ``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Utility with high capacity:"``, ``utility_high_capacity``, ``"\n"``)`

### Implementing Multi-Objective Optimization

When multiple objectives conflict, use Pareto optimization:

\
`# Generate test combinations and their performance`\
`generate_pareto_data`` ``<-`` ``function``(``data``, ``tests``, ``gold``, ``gold_positive``)`` ``{`\
`  ``# Get all possible test combinations`\
`  ``all_combinations`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``)`\
`  `\
`  ``for`` ``(``i`` ``in`` ``1``:`[`length`](https://rdrr.io/r/base/length.html)`(``tests``)``)`` ``{`\
`    ``combos`` ``<-`` `[`combn`](https://rdrr.io/r/utils/combn.html)`(``tests``, ``i``, simplify ``=`` ``FALSE``)`\
`    ``all_combinations`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``all_combinations``, ``combos``)`\
`  ``}`\
`  `\
`  ``# Calculate metrics for each combination`\
`  ``results`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``)`\
`  `\
`  ``for`` ``(``combo`` ``in`` ``all_combinations``)`` ``{`\
`    ``# Simulate parallel ANY rule`\
`    ``test_positive`` ``<-`` `[`rowSums`](https://rdrr.io/pkg/Matrix/man/colSums-methods.html)`(``data``[``combo``]`` ``==`` ``"Positive"`` ``|`` `\
`                           ``data``[``combo``]`` ``==`` ``"Abnormal"`` ``|`` `\
`                           ``data``[``combo``]`` ``==`` ``"MTB detected"``,`\
`                           na.rm ``=`` ``TRUE``)`` ``>`` ``0`\
`    `\
`    ``truth`` ``<-`` ``data``[[``gold``]``]`` ``==`` ``gold_positive`\
`    `\
`    ``# Calculate metrics`\
`    ``TP`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``test_positive`` ``&`` ``truth``)`\
`    ``FP`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``test_positive`` ``&`` ``!``truth``)`\
`    ``TN`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``!``test_positive`` ``&`` ``!``truth``)`\
`    ``FN`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``!``test_positive`` ``&`` ``truth``)`\
`    `\
`    ``sensitivity`` ``<-`` ``TP`` ``/`` ``(``TP`` ``+`` ``FN``)`\
`    ``specificity`` ``<-`` ``TN`` ``/`` ``(``TN`` ``+`` ``FP``)`\
`    `\
`    ``# Simulated costs`\
`    ``test_costs`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``rapid_antigen ``=`` ``5``, pcr ``=`` ``50``, chest_ct ``=`` ``200``)`\
`    ``total_cost`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``test_costs``[``combo``]``)`\
`    `\
`    ``results`` ``<-`` `[`rbind`](https://amices.org/mice/reference/cbind.html)`(``results``, `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`      tests ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``combo``, collapse ``=`` ``"+"``)``,`\
`      n_tests ``=`` `[`length`](https://rdrr.io/r/base/length.html)`(``combo``)``,`\
`      sensitivity ``=`` ``sensitivity``,`\
`      specificity ``=`` ``specificity``,`\
`      cost ``=`` ``total_cost`\
`    ``)``)`\
`  ``}`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``results``)`\
`}`\
\
`# Generate Pareto frontier for COVID tests`\
`pareto_data`` ``<-`` ``generate_pareto_data``(`\
`  ``covid_screening_data``[``1``:``500``,``]``,  ``# Use subset for speed`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"rapid_antigen"``, ``"pcr"``, ``"chest_ct"``)``,`\
`  gold ``=`` ``"covid_status"``,`\
`  gold_positive ``=`` ``"Positive"`\
`)`\
\
`# Identify Pareto optimal solutions`\
`is_pareto_optimal`` ``<-`` ``function``(``data``, ``objectives``)`` ``{`\
`  ``n`` ``<-`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``data``)`\
`  ``pareto`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``TRUE``, ``n``)`\
`  `\
`  ``for`` ``(``i`` ``in`` ``1``:``n``)`` ``{`\
`    ``for`` ``(``j`` ``in`` ``1``:``n``)`` ``{`\
`      ``if`` ``(``i`` ``!=`` ``j``)`` ``{`\
`        ``# Check if j dominates i`\
`        ``dominates`` ``<-`` `[`all`](https://rdrr.io/r/base/all.html)`(``data``[``j``, ``objectives``]`` ``>=`` ``data``[``i``, ``objectives``]``)`` ``&&`\
`                    `[`any`](https://rdrr.io/r/base/any.html)`(``data``[``j``, ``objectives``]`` ``>`` ``data``[``i``, ``objectives``]``)`\
`        ``if`` ``(``dominates``)`` ``{`\
`          ``pareto``[``i``]`` ``<-`` ``FALSE`\
`          ``break`\
`        ``}`\
`      ``}`\
`    ``}`\
`  ``}`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``pareto``)`\
`}`\
\
`# For sensitivity and cost (cost should be minimized, so use negative)`\
`pareto_data``$``neg_cost`` ``<-`` ``-``pareto_data``$``cost`\
`pareto_data``$``pareto_optimal`` ``<-`` ``is_pareto_optimal``(`\
`  ``pareto_data``, `\
`  `[`c`](https://rdrr.io/r/base/c.html)`(``"sensitivity"``, ``"neg_cost"``)`\
`)`\
\
`# Visualize Pareto frontier`\
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``pareto_data``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``cost``, y ``=`` ``sensitivity`` ``*`` ``100``)``)`` ``+`\
`  `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``color ``=`` ``pareto_optimal``, size ``=`` ``n_tests``)``, alpha ``=`` ``0.7``)`` ``+`\
`  `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``data ``=`` ``pareto_data``[``pareto_data``$``pareto_optimal``,``]`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(``cost``)``,`\
`            color ``=`` ``"red"``, size ``=`` ``1``)`` ``+`\
`  `[`geom_text`](https://ggplot2.tidyverse.org/reference/geom_text.html)`(``data ``=`` ``pareto_data``[``pareto_data``$``pareto_optimal``,``]``,`\
`            `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``label ``=`` ``tests``)``, vjust ``=`` ``-``1``, size ``=`` ``3``)`` ``+`\
`  `[`scale_color_manual`](https://ggplot2.tidyverse.org/reference/scale_manual.html)`(``values ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"gray"``, ``"red"``)``)`` ``+`\
`  `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`\
`    title ``=`` ``"Pareto Frontier for Multi-Objective Optimization"``,`\
`    x ``=`` ``"Total Cost ($)"``,`\
`    y ``=`` ``"Sensitivity (%)"``,`\
`    caption ``=`` ``"Red points and line show Pareto optimal solutions"`\
`  ``)`` ``+`\
`  `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`` ``+`\
`  `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``legend.position ``=`` ``"none"``)`

## Advanced Decision Trees

### Cost-Sensitive Decision Trees

Implement decision trees that consider both accuracy and cost:

\
`# Prepare data for decision tree`\
`tree_data`` ``<-`` ``covid_screening_data`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``rapid_antigen``, ``pcr``, ``chest_ct``, ``symptom_score``, `\
`         ``age``, ``risk_group``, ``covid_status``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`na.omit`](https://rdrr.io/r/stats/na.fail.html)`(``)`\
\
`# Create cost matrix`\
`# Rows: predicted, Columns: actual`\
`# Cost of false negative is 10x cost of false positive`\
`cost_matrix`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``1``,     ``# Predict Negative`\
`                       ``10``, ``0``)``,    ``# Predict Positive`\
`                     nrow ``=`` ``2``, byrow ``=`` ``TRUE``)`\
\
`# Build cost-sensitive tree`\
`cost_tree`` ``<-`` `[`rpart`](https://rdrr.io/pkg/rpart/man/rpart.html)`(`\
`  ``covid_status`` ``~`` ``rapid_antigen`` ``+`` ``pcr`` ``+`` ``chest_ct`` ``+`` `\
`                 ``symptom_score`` ``+`` ``age`` ``+`` ``risk_group``,`\
`  data ``=`` ``tree_data``,`\
`  method ``=`` ``"class"``,`\
`  parms ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``loss ``=`` ``cost_matrix``)``,`\
`  control ``=`` `[`rpart.control`](https://rdrr.io/pkg/rpart/man/rpart.control.html)`(``cp ``=`` ``0.01``, maxdepth ``=`` ``4``)`\
`)`\
\
`# Visualize tree`\
[`rpart.plot`](https://rdrr.io/pkg/rpart.plot/man/rpart.plot.html)`(``cost_tree``, `\
`           main ``=`` ``"Cost-Sensitive Decision Tree for COVID-19"``,`\
`           extra ``=`` ``104``,  ``# Show probability and number`\
`           under ``=`` ``TRUE``,`\
`           faclen ``=`` ``0``,`\
`           cex ``=`` ``0.8``)`\
\
`# Compare with standard tree`\
`standard_tree`` ``<-`` `[`rpart`](https://rdrr.io/pkg/rpart/man/rpart.html)`(`\
`  ``covid_status`` ``~`` ``rapid_antigen`` ``+`` ``pcr`` ``+`` ``chest_ct`` ``+`` `\
`                 ``symptom_score`` ``+`` ``age`` ``+`` ``risk_group``,`\
`  data ``=`` ``tree_data``,`\
`  method ``=`` ``"class"``,`\
`  control ``=`` `[`rpart.control`](https://rdrr.io/pkg/rpart/man/rpart.control.html)`(``cp ``=`` ``0.01``, maxdepth ``=`` ``4``)`\
`)`\
\
`# Performance comparison`\
`tree_comparison`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Model ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Standard"``, ``"Cost-Sensitive"``)``,`\
`  Accuracy ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    `[`sum`](https://rdrr.io/r/base/sum.html)`(`[`predict`](https://rdrr.io/r/stats/predict.html)`(``standard_tree``, type ``=`` ``"class"``)`` ``==`` ``tree_data``$``covid_status``)`` ``/`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``tree_data``)``,`\
`    `[`sum`](https://rdrr.io/r/base/sum.html)`(`[`predict`](https://rdrr.io/r/stats/predict.html)`(``cost_tree``, type ``=`` ``"class"``)`` ``==`` ``tree_data``$``covid_status``)`` ``/`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``tree_data``)`\
`  ``)``,`\
`  Sensitivity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``{`\
`      ``pred`` ``<-`` `[`predict`](https://rdrr.io/r/stats/predict.html)`(``standard_tree``, type ``=`` ``"class"``)`\
`      `[`sum`](https://rdrr.io/r/base/sum.html)`(``pred`` ``==`` ``"Positive"`` ``&`` ``tree_data``$``covid_status`` ``==`` ``"Positive"``)`` ``/`` `\
`        `[`sum`](https://rdrr.io/r/base/sum.html)`(``tree_data``$``covid_status`` ``==`` ``"Positive"``)`\
`    ``}``,`\
`    ``{`\
`      ``pred`` ``<-`` `[`predict`](https://rdrr.io/r/stats/predict.html)`(``cost_tree``, type ``=`` ``"class"``)`\
`      `[`sum`](https://rdrr.io/r/base/sum.html)`(``pred`` ``==`` ``"Positive"`` ``&`` ``tree_data``$``covid_status`` ``==`` ``"Positive"``)`` ``/`` `\
`        `[`sum`](https://rdrr.io/r/base/sum.html)`(``tree_data``$``covid_status`` ``==`` ``"Positive"``)`\
`    ``}`\
`  ``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``tree_comparison``, digits ``=`` ``3``,`\
`      caption ``=`` ``"Performance Comparison: Standard vs Cost-Sensitive Trees"``)`

### Ensemble Decision Trees

Combine multiple trees for more robust decisions:

\
`# Create bootstrap samples and build multiple trees`\
`n_trees`` ``<-`` ``10`\
`trees`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``)`\
`tree_weights`` ``<-`` `[`numeric`](https://rdrr.io/r/base/numeric.html)`(``n_trees``)`\
\
`for`` ``(``i`` ``in`` ``1``:``n_trees``)`` ``{`\
`  ``# Bootstrap sample`\
`  ``boot_indices`` ``<-`` `[`sample`](https://rdrr.io/r/base/sample.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``tree_data``)``, replace ``=`` ``TRUE``)`\
`  ``boot_data`` ``<-`` ``tree_data``[``boot_indices``,``]`\
`  `\
`  ``# Build tree with random feature subset`\
`  ``features`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"rapid_antigen"``, ``"pcr"``, ``"chest_ct"``, `\
`                ``"symptom_score"``, ``"age"``, ``"risk_group"``)`\
`  ``selected_features`` ``<-`` `[`sample`](https://rdrr.io/r/base/sample.html)`(``features``, size ``=`` ``4``)`\
`  `\
`  ``formula`` ``<-`` `[`as.formula`](https://rdrr.io/r/stats/formula.html)`(`[`paste`](https://rdrr.io/r/base/paste.html)`(``"covid_status ~"``, `\
`                             `[`paste`](https://rdrr.io/r/base/paste.html)`(``selected_features``, collapse ``=`` ``" + "``)``)``)`\
`  `\
`  ``trees``[[``i``]``]`` ``<-`` `[`rpart`](https://rdrr.io/pkg/rpart/man/rpart.html)`(`\
`    ``formula``,`\
`    data ``=`` ``boot_data``,`\
`    method ``=`` ``"class"``,`\
`    control ``=`` `[`rpart.control`](https://rdrr.io/pkg/rpart/man/rpart.control.html)`(``cp ``=`` ``0.02``, maxdepth ``=`` ``3``)`\
`  ``)`\
`  `\
`  ``# Calculate out-of-bag performance for weighting`\
`  ``oob_indices`` ``<-`` `[`setdiff`](https://generics.r-lib.org/reference/setops.html)`(``1``:`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``tree_data``)``, `[`unique`](https://rdrr.io/r/base/unique.html)`(``boot_indices``)``)`\
`  ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``oob_indices``)`` ``>`` ``0``)`` ``{`\
`    ``oob_pred`` ``<-`` `[`predict`](https://rdrr.io/r/stats/predict.html)`(``trees``[[``i``]``]``, ``tree_data``[``oob_indices``,``]``, type ``=`` ``"class"``)`\
`    ``tree_weights``[``i``]`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``oob_pred`` ``==`` ``tree_data``$``covid_status``[``oob_indices``]``)`` ``/`` `\
`                      `[`length`](https://rdrr.io/r/base/length.html)`(``oob_indices``)`\
`  ``}`` ``else`` ``{`\
`    ``tree_weights``[``i``]`` ``<-`` ``0.5`\
`  ``}`\
`}`\
\
`# Normalize weights`\
`tree_weights`` ``<-`` ``tree_weights`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``tree_weights``)`\
\
`# Ensemble prediction function`\
`ensemble_predict`` ``<-`` ``function``(``trees``, ``weights``, ``newdata``)`` ``{`\
`  ``# Get probability predictions from each tree`\
`  ``prob_matrix`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(``0``, nrow ``=`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``newdata``)``, ncol ``=`` ``2``)`\
`  `\
`  ``for`` ``(``i`` ``in`` ``1``:`[`length`](https://rdrr.io/r/base/length.html)`(``trees``)``)`` ``{`\
`    ``probs`` ``<-`` `[`predict`](https://rdrr.io/r/stats/predict.html)`(``trees``[[``i``]``]``, ``newdata``, type ``=`` ``"prob"``)`\
`    ``prob_matrix`` ``<-`` ``prob_matrix`` ``+`` ``probs`` ``*`` ``weights``[``i``]`\
`  ``}`\
`  `\
`  ``# Return class with highest probability`\
`  ``classes`` ``<-`` `[`levels`](https://rdrr.io/r/base/levels.html)`(``tree_data``$``covid_status``)`\
`  ``predicted_class`` ``<-`` ``classes``[`[`apply`](https://rdrr.io/r/base/apply.html)`(``prob_matrix``, ``1``, ``which.max``)``]`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(`[`list`](https://rdrr.io/r/base/list.html)`(``class ``=`` ``predicted_class``, prob ``=`` ``prob_matrix``)``)`\
`}`\
\
`# Test ensemble`\
`ensemble_pred`` ``<-`` ``ensemble_predict``(``trees``, ``tree_weights``, ``tree_data``)`\
\
`# Compare performance`\
`ensemble_comparison`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Model ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Single Tree"``, ``"Ensemble"``)``,`\
`  Accuracy ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    `[`sum`](https://rdrr.io/r/base/sum.html)`(`[`predict`](https://rdrr.io/r/stats/predict.html)`(``trees``[[``1``]``]``, type ``=`` ``"class"``)`` ``==`` ``tree_data``$``covid_status``)`` ``/`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``tree_data``)``,`\
`    `[`sum`](https://rdrr.io/r/base/sum.html)`(``ensemble_pred``$``class`` ``==`` ``tree_data``$``covid_status``)`` ``/`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``tree_data``)`\
`  ``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``ensemble_comparison``, digits ``=`` ``3``,`\
`      caption ``=`` ``"Single Tree vs Ensemble Performance"``)`

## Complex Constraints and Business Rules

### Implementing Complex Constraints

Real-world scenarios often have complex constraints:

\
`# Function to check if a test combination meets constraints`\
`meets_constraints`` ``<-`` ``function``(``tests``, ``constraints``)`` ``{`\
`  ``# Example constraints for TB testing`\
`  `\
`  ``# 1. If GeneXpert is used, must have sputum collection capability`\
`  ``if`` ``(``"genexpert"`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``tests`` ``&&`` ``!``(``"sputum_smear"`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``tests`` ``||`` `\
`                                   ``constraints``$``has_sputum_collection``)``)`` ``{`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(``FALSE``)`\
`  ``}`\
`  `\
`  ``# 2. Culture requires biosafety level 3 lab`\
`  ``if`` ``(``"culture"`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``tests`` ``&&`` ``!``constraints``$``has_bsl3_lab``)`` ``{`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(``FALSE``)`\
`  ``}`\
`  `\
`  ``# 3. Maximum turnaround time constraint`\
`  ``test_times`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``symptoms ``=`` ``0``, sputum_smear ``=`` ``0.5``, genexpert ``=`` ``0.1``, `\
`                  culture ``=`` ``21``, chest_xray ``=`` ``0.5``)`\
`  ``max_time`` ``<-`` `[`max`](https://rdrr.io/r/base/Extremes.html)`(``test_times``[``tests``]``)`\
`  ``if`` ``(``max_time`` ``>`` ``constraints``$``max_turnaround_days``)`` ``{`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(``FALSE``)`\
`  ``}`\
`  `\
`  ``# 4. Budget constraint`\
`  ``test_costs`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``symptoms ``=`` ``1``, sputum_smear ``=`` ``3``, genexpert ``=`` ``20``, `\
`                  culture ``=`` ``30``, chest_xray ``=`` ``10``)`\
`  ``total_cost`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``test_costs``[``tests``]``)`\
`  ``if`` ``(``total_cost`` ``>`` ``constraints``$``budget_per_patient``)`` ``{`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(``FALSE``)`\
`  ``}`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``TRUE``)`\
`}`\
\
`# Define facility-specific constraints`\
`facility_constraints`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`  rural_clinic ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`    has_sputum_collection ``=`` ``TRUE``,`\
`    has_bsl3_lab ``=`` ``FALSE``,`\
`    max_turnaround_days ``=`` ``1``,`\
`    budget_per_patient ``=`` ``15`\
`  ``)``,`\
`  district_hospital ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`    has_sputum_collection ``=`` ``TRUE``,`\
`    has_bsl3_lab ``=`` ``FALSE``,`\
`    max_turnaround_days ``=`` ``7``,`\
`    budget_per_patient ``=`` ``50`\
`  ``)``,`\
`  reference_lab ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`    has_sputum_collection ``=`` ``TRUE``,`\
`    has_bsl3_lab ``=`` ``TRUE``,`\
`    max_turnaround_days ``=`` ``30``,`\
`    budget_per_patient ``=`` ``100`\
`  ``)`\
`)`\
\
`# Find valid combinations for each facility type`\
`tb_tests`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"symptoms"``, ``"sputum_smear"``, ``"genexpert"``, ``"culture"``, ``"chest_xray"``)`\
\
`for`` ``(``facility`` ``in`` `[`names`](https://rdrr.io/r/base/names.html)`(``facility_constraints``)``)`` ``{`\
`  ``valid_combos`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``)`\
`  `\
`  ``# Check all combinations`\
`  ``for`` ``(``i`` ``in`` ``1``:`[`length`](https://rdrr.io/r/base/length.html)`(``tb_tests``)``)`` ``{`\
`    ``combos`` ``<-`` `[`combn`](https://rdrr.io/r/utils/combn.html)`(``tb_tests``, ``i``, simplify ``=`` ``FALSE``)`\
`    ``for`` ``(``combo`` ``in`` ``combos``)`` ``{`\
`      ``if`` ``(``meets_constraints``(``combo``, ``facility_constraints``[[``facility``]``]``)``)`` ``{`\
`        ``valid_combos`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``valid_combos``, `[`list`](https://rdrr.io/r/base/list.html)`(``combo``)``)`\
`      ``}`\
`    ``}`\
`  ``}`\
`  `\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"\n"``, ``facility``, ``": "``, `[`length`](https://rdrr.io/r/base/length.html)`(``valid_combos``)``, ``" valid combinations\n"``, sep ``=`` ``""``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Examples: \n"``)`\
`  ``for`` ``(``j`` ``in`` ``1``:`[`min`](https://rdrr.io/r/base/Extremes.html)`(``3``, `[`length`](https://rdrr.io/r/base/length.html)`(``valid_combos``)``)``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"  -"``, `[`paste`](https://rdrr.io/r/base/paste.html)`(``valid_combos``[[``j``]``]``, collapse ``=`` ``" + "``)``, ``"\n"``)`\
`  ``}`\
`}`

### Time-Dependent Testing Strategies

Implement strategies that change based on time constraints:

\
`# Time-dependent chest pain protocol`\
`time_dependent_protocol`` ``<-`` ``function``(``patient_data``, ``time_available_hours``)`` ``{`\
`  `\
`  ``decisions`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`    patient_id ``=`` ``patient_data``$``patient_id``,`\
`    protocol ``=`` `[`character`](https://rdrr.io/r/base/character.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``patient_data``)``)``,`\
`    tests_used ``=`` `[`character`](https://rdrr.io/r/base/character.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``patient_data``)``)``,`\
`    decision_time ``=`` `[`numeric`](https://rdrr.io/r/base/numeric.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``patient_data``)``)``,`\
`    stringsAsFactors ``=`` ``FALSE`\
`  ``)`\
`  `\
`  ``for`` ``(``i`` ``in`` ``1``:`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``patient_data``)``)`` ``{`\
`    ``patient`` ``<-`` ``patient_data``[``i``,``]`\
`    `\
`    ``if`` ``(``time_available_hours`` ``>=`` ``3``)`` ``{`\
`      ``# Full protocol available`\
`      ``if`` ``(``patient``$``troponin_initial`` ``==`` ``"Normal"`` ``&&`` `\
`          ``patient``$``troponin_3hr`` ``==`` ``"Normal"`` ``&&`\
`          ``patient``$``ecg`` ``==`` ``"Normal"``)`` ``{`\
`        ``decisions``$``protocol``[``i``]`` ``<-`` ``"Rule out"`\
`        ``decisions``$``tests_used``[``i``]`` ``<-`` ``"ECG + Serial troponins"`\
`        ``decisions``$``decision_time``[``i``]`` ``<-`` ``3`\
`      ``}`` ``else`` ``if`` ``(``patient``$``troponin_3hr`` ``==`` ``"Elevated"``)`` ``{`\
`        ``decisions``$``protocol``[``i``]`` ``<-`` ``"Rule in"`\
`        ``decisions``$``tests_used``[``i``]`` ``<-`` ``"ECG + Serial troponins"`\
`        ``decisions``$``decision_time``[``i``]`` ``<-`` ``3`\
`      ``}`` ``else`` ``{`\
`        ``decisions``$``protocol``[``i``]`` ``<-`` ``"Further testing"`\
`        ``decisions``$``tests_used``[``i``]`` ``<-`` ``"ECG + Serial troponins + CTA"`\
`        ``decisions``$``decision_time``[``i``]`` ``<-`` ``3.5`\
`      ``}`\
`      `\
`    ``}`` ``else`` ``if`` ``(``time_available_hours`` ``>=`` ``1``)`` ``{`\
`      ``# Rapid protocol`\
`      ``if`` ``(``patient``$``troponin_initial`` ``==`` ``"Normal"`` ``&&`` `\
`          ``patient``$``ecg`` ``==`` ``"Normal"`` ``&&`\
`          ``patient``$``age`` ``<`` ``40``)`` ``{`\
`        ``decisions``$``protocol``[``i``]`` ``<-`` ``"Low risk discharge"`\
`        ``decisions``$``tests_used``[``i``]`` ``<-`` ``"ECG + Initial troponin"`\
`        ``decisions``$``decision_time``[``i``]`` ``<-`` ``1`\
`      ``}`` ``else`` ``{`\
`        ``decisions``$``protocol``[``i``]`` ``<-`` ``"Requires admission"`\
`        ``decisions``$``tests_used``[``i``]`` ``<-`` ``"ECG + Initial troponin"`\
`        ``decisions``$``decision_time``[``i``]`` ``<-`` ``1`\
`      ``}`\
`      `\
`    ``}`` ``else`` ``{`\
`      ``# Ultra-rapid`\
`      ``if`` ``(``patient``$``ecg`` ``==`` ``"Ischemic changes"``)`` ``{`\
`        ``decisions``$``protocol``[``i``]`` ``<-`` ``"Immediate cath lab"`\
`        ``decisions``$``tests_used``[``i``]`` ``<-`` ``"ECG only"`\
`        ``decisions``$``decision_time``[``i``]`` ``<-`` ``0.2`\
`      ``}`` ``else`` ``{`\
`        ``decisions``$``protocol``[``i``]`` ``<-`` ``"Clinical decision"`\
`        ``decisions``$``tests_used``[``i``]`` ``<-`` ``"ECG only"`\
`        ``decisions``$``decision_time``[``i``]`` ``<-`` ``0.2`\
`      ``}`\
`    ``}`\
`  ``}`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``decisions``)`\
`}`\
\
`# Apply to sample patients`\
`sample_mi`` ``<-`` ``mi_ruleout_data``[``1``:``20``,``]`\
\
`# Different time scenarios`\
`time_scenarios`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.5``, ``1``, ``3``, ``6``)`\
\
`for`` ``(``time_limit`` ``in`` ``time_scenarios``)`` ``{`\
`  ``results`` ``<-`` ``time_dependent_protocol``(``sample_mi``, ``time_limit``)`\
`  `\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nTime available:"``, ``time_limit``, ``"hours\n"``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Protocols used:\n"``)`\
`  `[`print`](https://rdrr.io/r/base/print.html)`(`[`table`](https://rdrr.io/r/base/table.html)`(``results``$``protocol``)``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Average decision time:"``, `[`mean`](https://rdrr.io/r/base/mean.html)`(``results``$``decision_time``)``, ``"hours\n"``)`\
`}`

## Performance Optimization

### Efficient Computation for Large Datasets

\
`# Performance Optimization and Benchmarking`\
`# This section demonstrates different approaches to optimize performance calculations`\
\
`# Function to safely calculate performance metrics with NA handling`\
`safe_performance_metrics`` ``<-`` ``function``(``predictions``, ``actual``, ``positive_class`` ``=`` ``"Positive"``)`` ``{`\
`  ``# Handle missing values`\
`  ``complete_cases`` ``<-`` ``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``predictions``)`` ``&`` ``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``actual``)`\
`  `\
`  ``if`` ``(`[`sum`](https://rdrr.io/r/base/sum.html)`(``complete_cases``)`` ``==`` ``0``)`` ``{`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(`[`list`](https://rdrr.io/r/base/list.html)`(`\
`      accuracy ``=`` ``NA``,`\
`      sensitivity ``=`` ``NA``,`\
`      specificity ``=`` ``NA``,`\
`      ppv ``=`` ``NA``,`\
`      npv ``=`` ``NA``,`\
`      n_complete ``=`` ``0`\
`    ``)``)`\
`  ``}`\
`  `\
`  ``pred_clean`` ``<-`` ``predictions``[``complete_cases``]`\
`  ``actual_clean`` ``<-`` ``actual``[``complete_cases``]`\
`  `\
`  ``# Convert to binary if needed`\
`  ``pred_binary`` ``<-`` `[`as.character`](https://rdrr.io/r/base/character.html)`(``pred_clean``)`` ``==`` ``positive_class`\
`  ``actual_binary`` ``<-`` `[`as.character`](https://rdrr.io/r/base/character.html)`(``actual_clean``)`` ``==`` ``positive_class`\
`  `\
`  ``# Calculate confusion matrix components`\
`  ``tp`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``pred_binary`` ``&`` ``actual_binary``, na.rm ``=`` ``TRUE``)`\
`  ``tn`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``!``pred_binary`` ``&`` ``!``actual_binary``, na.rm ``=`` ``TRUE``)`\
`  ``fp`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``pred_binary`` ``&`` ``!``actual_binary``, na.rm ``=`` ``TRUE``)`\
`  ``fn`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``!``pred_binary`` ``&`` ``actual_binary``, na.rm ``=`` ``TRUE``)`\
`  `\
`  ``# Calculate metrics with division by zero protection`\
`  ``total`` ``<-`` ``tp`` ``+`` ``tn`` ``+`` ``fp`` ``+`` ``fn`\
`  ``accuracy`` ``<-`` ``if`` ``(``total`` ``>`` ``0``)`` ``(``tp`` ``+`` ``tn``)`` ``/`` ``total`` ``else`` ``NA`\
`  `\
`  ``sensitivity`` ``<-`` ``if`` ``(``(``tp`` ``+`` ``fn``)`` ``>`` ``0``)`` ``tp`` ``/`` ``(``tp`` ``+`` ``fn``)`` ``else`` ``NA`\
`  ``specificity`` ``<-`` ``if`` ``(``(``tn`` ``+`` ``fp``)`` ``>`` ``0``)`` ``tn`` ``/`` ``(``tn`` ``+`` ``fp``)`` ``else`` ``NA`\
`  ``ppv`` ``<-`` ``if`` ``(``(``tp`` ``+`` ``fp``)`` ``>`` ``0``)`` ``tp`` ``/`` ``(``tp`` ``+`` ``fp``)`` ``else`` ``NA`\
`  ``npv`` ``<-`` ``if`` ``(``(``tn`` ``+`` ``fn``)`` ``>`` ``0``)`` ``tn`` ``/`` ``(``tn`` ``+`` ``fn``)`` ``else`` ``NA`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(`[`list`](https://rdrr.io/r/base/list.html)`(`\
`    accuracy ``=`` ``accuracy``,`\
`    sensitivity ``=`` ``sensitivity``,`\
`    specificity ``=`` ``specificity``,`\
`    ppv ``=`` ``ppv``,`\
`    npv ``=`` ``npv``,`\
`    n_complete ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``complete_cases``)`\
`  ``)``)`\
`}`\
\
`# Optimized confusion matrix calculation`\
`fast_confusion_matrix`` ``<-`` ``function``(``predictions``, ``actual``, ``positive_class`` ``=`` ``"Positive"``)`` ``{`\
`  ``# Handle NAs upfront`\
`  ``complete_cases`` ``<-`` ``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``predictions``)`` ``&`` ``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``actual``)`\
`  `\
`  ``if`` ``(`[`sum`](https://rdrr.io/r/base/sum.html)`(``complete_cases``)`` ``<`` ``2``)`` ``{`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(`[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``0``, ``0``, ``0``)``, nrow ``=`` ``2``, `\
`                  dimnames ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`                    Predicted ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Negative"``, ``"Positive"``)``,`\
`                    Actual ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Negative"``, ``"Positive"``)`\
`                  ``)``)``)`\
`  ``}`\
`  `\
`  ``pred_clean`` ``<-`` ``predictions``[``complete_cases``]`\
`  ``actual_clean`` ``<-`` ``actual``[``complete_cases``]`\
`  `\
`  ``# Use table for fast cross-tabulation`\
`  ``conf_table`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(`\
`    Predicted ``=`` `[`factor`](https://rdrr.io/r/base/factor.html)`(``pred_clean``, levels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`[`setdiff`](https://generics.r-lib.org/reference/setops.html)`(`[`unique`](https://rdrr.io/r/base/unique.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``pred_clean``, ``actual_clean``)``)``, ``positive_class``)``, ``positive_class``)``)``,`\
`    Actual ``=`` `[`factor`](https://rdrr.io/r/base/factor.html)`(``actual_clean``, levels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`[`setdiff`](https://generics.r-lib.org/reference/setops.html)`(`[`unique`](https://rdrr.io/r/base/unique.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``pred_clean``, ``actual_clean``)``)``, ``positive_class``)``, ``positive_class``)``)`\
`  ``)`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``conf_table``)`\
`}`\
\
`# Vectorized performance calculation`\
`vectorized_metrics`` ``<-`` ``function``(``pred_vector``, ``actual_vector``, ``positive_class`` ``=`` ``"Positive"``)`` ``{`\
`  ``# Remove NAs`\
`  ``complete_idx`` ``<-`` ``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``pred_vector``)`` ``&`` ``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``actual_vector``)`\
`  `\
`  ``if`` ``(`[`sum`](https://rdrr.io/r/base/sum.html)`(``complete_idx``)`` ``==`` ``0``)`` ``{`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(`[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`      method ``=`` ``"vectorized"``,`\
`      accuracy ``=`` ``NA``,`\
`      sensitivity ``=`` ``NA``,`\
`      specificity ``=`` ``NA``,`\
`      n_obs ``=`` ``0`\
`    ``)``)`\
`  ``}`\
`  `\
`  ``pred`` ``<-`` ``pred_vector``[``complete_idx``]`\
`  ``actual`` ``<-`` ``actual_vector``[``complete_idx``]`\
`  `\
`  ``# Vectorized operations`\
`  ``pred_pos`` ``<-`` ``pred`` ``==`` ``positive_class`\
`  ``actual_pos`` ``<-`` ``actual`` ``==`` ``positive_class`\
`  `\
`  ``tp`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``pred_pos`` ``&`` ``actual_pos``)`\
`  ``tn`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``!``pred_pos`` ``&`` ``!``actual_pos``)`\
`  ``fp`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``pred_pos`` ``&`` ``!``actual_pos``)`\
`  ``fn`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``!``pred_pos`` ``&`` ``actual_pos``)`\
`  `\
`  ``n_total`` ``<-`` `[`length`](https://rdrr.io/r/base/length.html)`(``pred``)`\
`  ``n_pos`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``actual_pos``)`\
`  ``n_neg`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``!``actual_pos``)`\
`  `\
`  `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`    method ``=`` ``"vectorized"``,`\
`    accuracy ``=`` ``(``tp`` ``+`` ``tn``)`` ``/`` ``n_total``,`\
`    sensitivity ``=`` ``if`` ``(``n_pos`` ``>`` ``0``)`` ``tp`` ``/`` ``n_pos`` ``else`` ``NA``,`\
`    specificity ``=`` ``if`` ``(``n_neg`` ``>`` ``0``)`` ``tn`` ``/`` ``n_neg`` ``else`` ``NA``,`\
`    n_obs ``=`` ``n_total`\
`  ``)`\
`}`\
\
`# Create test data for benchmarking (ensure no NAs in critical columns)`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``123``)`\
`n_test`` ``<-`` ``1000`\
\
`# Create predictions with some realistic accuracy`\
`actual_test`` ``<-`` `[`factor`](https://rdrr.io/r/base/factor.html)`(`[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"Negative"``, ``"Positive"``)``, ``n_test``, `\
`                           replace ``=`` ``TRUE``, prob ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.8``, ``0.2``)``)``)`\
\
`# Create predictions that correlate with actual (realistic scenario)`\
`pred_prob`` ``<-`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``actual_test`` ``==`` ``"Positive"``, ``0.85``, ``0.15``)`\
`pred_test`` ``<-`` `[`factor`](https://rdrr.io/r/base/factor.html)`(`[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(`[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_test``)`` ``<`` ``pred_prob``, ``"Positive"``, ``"Negative"``)``)`\
\
`# Introduce some missing values (but not in the benchmarked functions)`\
`missing_idx`` ``<-`` `[`sample`](https://rdrr.io/r/base/sample.html)`(``n_test``, size ``=`` `[`floor`](https://rdrr.io/r/base/Round.html)`(``n_test`` ``*`` ``0.05``)``)`\
`actual_test_with_na`` ``<-`` ``actual_test`\
`pred_test_with_na`` ``<-`` ``pred_test`\
`actual_test_with_na``[``missing_idx``[``1``:`[`length`](https://rdrr.io/r/base/length.html)`(``missing_idx``)``/``2``]``]`` ``<-`` ``NA`\
`pred_test_with_na``[``missing_idx``[``(`[`length`](https://rdrr.io/r/base/length.html)`(``missing_idx``)``/``2`` ``+`` ``1``)``:`[`length`](https://rdrr.io/r/base/length.html)`(``missing_idx``)``]``]`` ``<-`` ``NA`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Test data created:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Total observations:"``, ``n_test``, ``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Missing values in actual:"``, `[`sum`](https://rdrr.io/r/base/sum.html)`(`[`is.na`](https://rdrr.io/r/base/NA.html)`(``actual_test_with_na``)``)``, ``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Missing values in predictions:"``, `[`sum`](https://rdrr.io/r/base/sum.html)`(`[`is.na`](https://rdrr.io/r/base/NA.html)`(``pred_test_with_na``)``)``, ``"\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Complete cases:"``, `[`sum`](https://rdrr.io/r/base/sum.html)`(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``actual_test_with_na``)`` ``&`` ``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``pred_test_with_na``)``)``, ``"\n"``)`\
\
`# Test the functions with clean data first`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nTesting functions with clean data:\n"``)`\
`clean_metrics`` ``<-`` ``safe_performance_metrics``(``pred_test``, ``actual_test``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``clean_metrics``)`\
\
`clean_confusion`` ``<-`` ``fast_confusion_matrix``(``pred_test``, ``actual_test``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``clean_confusion``)`\
\
`# Test with data containing NAs`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nTesting functions with NA values:\n"``)`\
`na_metrics`` ``<-`` ``safe_performance_metrics``(``pred_test_with_na``, ``actual_test_with_na``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``na_metrics``)`\
\
`# Benchmark different approaches (using clean data to avoid NA issues in timing)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nPerformance benchmarking:\n"``)`\
\
`# Only benchmark if microbenchmark is available`\
`if`` ``(`[`requireNamespace`](https://rdrr.io/r/base/ns-load.html)`(``"microbenchmark"``, quietly ``=`` ``TRUE``)``)`` ``{`\
`  `[`tryCatch`](https://rdrr.io/r/base/conditions.html)`(``{`\
`    ``benchmark_results`` ``<-`` ``microbenchmark``::`[`microbenchmark`](https://rdrr.io/pkg/microbenchmark/man/microbenchmark.html)`(`\
`      ``"safe_metrics"`` ``=`` ``safe_performance_metrics``(``pred_test``, ``actual_test``)``,`\
`      ``"fast_confusion"`` ``=`` ``fast_confusion_matrix``(``pred_test``, ``actual_test``)``,`\
`      ``"vectorized"`` ``=`` ``vectorized_metrics``(``pred_test``, ``actual_test``)``,`\
`      times ``=`` ``10`\
`    ``)`\
`    `\
`    `[`print`](https://rdrr.io/r/base/print.html)`(``benchmark_results``)`\
`    `\
`    ``# Plot benchmark results if possible`\
`    ``if`` ``(`[`requireNamespace`](https://rdrr.io/r/base/ns-load.html)`(``"ggplot2"``, quietly ``=`` ``TRUE``)``)`` ``{`\
`      `[`plot`](https://rdrr.io/r/graphics/plot.default.html)`(``benchmark_results``)`\
`    ``}`\
`    `\
`  ``}``, error ``=`` ``function``(``e``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Benchmark error (using fallback timing):"``, ``e``$``message``, ``"\n"``)`\
`    `\
`    ``# Fallback timing method`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Using system.time for performance measurement:\n"``)`\
`    `\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Safe metrics timing:\n"``)`\
`    `[`print`](https://rdrr.io/r/base/print.html)`(`[`system.time`](https://rdrr.io/r/base/system.time.html)`(``for``(``i`` ``in`` ``1``:``10``)`` ``safe_performance_metrics``(``pred_test``, ``actual_test``)``)``)`\
`    `\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Fast confusion matrix timing:\n"``)`\
`    `[`print`](https://rdrr.io/r/base/print.html)`(`[`system.time`](https://rdrr.io/r/base/system.time.html)`(``for``(``i`` ``in`` ``1``:``10``)`` ``fast_confusion_matrix``(``pred_test``, ``actual_test``)``)``)`\
`    `\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Vectorized metrics timing:\n"``)`\
`    `[`print`](https://rdrr.io/r/base/print.html)`(`[`system.time`](https://rdrr.io/r/base/system.time.html)`(``for``(``i`` ``in`` ``1``:``10``)`` ``vectorized_metrics``(``pred_test``, ``actual_test``)``)``)`\
`  ``}``)`\
`}`` ``else`` ``{`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"microbenchmark package not available, using system.time:\n"``)`\
`  `\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Safe metrics timing:\n"``)`\
`  `[`print`](https://rdrr.io/r/base/print.html)`(`[`system.time`](https://rdrr.io/r/base/system.time.html)`(`[`replicate`](https://rdrr.io/r/base/lapply.html)`(``10``, ``safe_performance_metrics``(``pred_test``, ``actual_test``)``)``)``)`\
`  `\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Fast confusion matrix timing:\n"``)`\
`  `[`print`](https://rdrr.io/r/base/print.html)`(`[`system.time`](https://rdrr.io/r/base/system.time.html)`(`[`replicate`](https://rdrr.io/r/base/lapply.html)`(``10``, ``fast_confusion_matrix``(``pred_test``, ``actual_test``)``)``)``)`\
`  `\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Vectorized metrics timing:\n"``)`\
`  `[`print`](https://rdrr.io/r/base/print.html)`(`[`system.time`](https://rdrr.io/r/base/system.time.html)`(`[`replicate`](https://rdrr.io/r/base/lapply.html)`(``10``, ``vectorized_metrics``(``pred_test``, ``actual_test``)``)``)``)`\
`}`\
\
`# Performance comparison table`\
`performance_comparison`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Method ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Safe Metrics"``, ``"Fast Confusion Matrix"``, ``"Vectorized Metrics"``)``,`\
``   `Handles NAs`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Yes"``, ``"Yes"``, ``"Yes"``)``,`\
``   `Memory Efficient`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Medium"``, ``"High"``, ``"High"``)``,`\
``   `Speed`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Medium"``, ``"Fast"``, ``"Fastest"``)``,`\
``   `Use Case`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"General purpose"``, ``"Detailed analysis"``, ``"Large datasets"``)``,`\
`  stringsAsFactors ``=`` ``FALSE`\
`)`\
\
`knitr``::`[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``performance_comparison``, `\
`             caption ``=`` ``"Performance Optimization Comparison"``,`\
`             align ``=`` ``'c'``)`

### Caching and Memoization

\
`# Create memoized function for expensive calculations`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`memoise`](https://memoise.r-lib.org)`)`\
\
`# Original expensive function`\
`calculate_test_performance`` ``<-`` ``function``(``test_data``, ``gold_standard``)`` ``{`\
`  ``# Simulate expensive calculation`\
`  `[`Sys.sleep`](https://rdrr.io/r/base/Sys.sleep.html)`(``0.1``)``  ``# Pretend this takes time`\
`  `\
`  ``conf_matrix`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``test_data``, ``gold_standard``)`\
`  ``sensitivity`` ``<-`` ``conf_matrix``[``2``,``2``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``conf_matrix``[``,``2``]``)`\
`  ``specificity`` ``<-`` ``conf_matrix``[``1``,``1``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``conf_matrix``[``,``1``]``)`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(`[`list`](https://rdrr.io/r/base/list.html)`(``sensitivity ``=`` ``sensitivity``, specificity ``=`` ``specificity``)``)`\
`}`\
\
`# Memoized version`\
`calculate_test_performance_memo`` ``<-`` `[`memoise`](https://memoise.r-lib.org/reference/memoise.html)`(``calculate_test_performance``)`\
\
`# Demonstration`\
`test_vector`` ``<-`` `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(``covid_screening_data``$``rapid_antigen`` ``==`` ``"Positive"``)`\
`gold_vector`` ``<-`` `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(``covid_screening_data``$``covid_status`` ``==`` ``"Positive"``)`\
\
`# First call - slow`\
[`system.time`](https://rdrr.io/r/base/system.time.html)`(``{`\
`  ``result1`` ``<-`` ``calculate_test_performance_memo``(``test_vector``[``1``:``100``]``, ``gold_vector``[``1``:``100``]``)`\
`}``)`\
\
`# Second call with same data - fast (cached)`\
[`system.time`](https://rdrr.io/r/base/system.time.html)`(``{`\
`  ``result2`` ``<-`` ``calculate_test_performance_memo``(``test_vector``[``1``:``100``]``, ``gold_vector``[``1``:``100``]``)`\
`}``)`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Results match:"``, `[`identical`](https://rdrr.io/r/base/identical.html)`(``result1``, ``result2``)``, ``"\n"``)`

## Integration with External Systems

### Exporting Results for Clinical Decision Support Systems

\
`# Export Clinical Decision Support System Rules`\
\
`# Safe function to export tree rules with proper error handling`\
`export_tree_as_rules`` ``<-`` ``function``(``tree_model``, ``data``)`` ``{`\
`  ``# Check if tree model exists and is valid`\
`  ``if`` ``(`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``tree_model``)`` ``||`` ``!`[`inherits`](https://rdrr.io/r/base/class.html)`(``tree_model``, ``"rpart"``)``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Error: Invalid or missing tree model\n"``)`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(``NULL``)`\
`  ``}`\
`  `\
`  ``# Check if tree has any splits`\
`  ``if`` ``(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``tree_model``$``frame``)`` ``<=`` ``1``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Warning: Tree has no splits (single node)\n"``)`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(`[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`      rule_id ``=`` ``1``,`\
`      condition ``=`` ``"Always true"``,`\
`      prediction ``=`` ``"Default"``,`\
`      confidence ``=`` ``1.0``,`\
`      n_cases ``=`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``data``)`\
`    ``)``)`\
`  ``}`\
`  `\
`  `[`tryCatch`](https://rdrr.io/r/base/conditions.html)`(``{`\
`    ``# Get tree frame information`\
`    ``frame`` ``<-`` ``tree_model``$``frame`\
`    `\
`    ``# Check if required columns exist`\
`    ``required_cols`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"var"``, ``"yval"``)`\
`    ``if`` ``(``!`[`all`](https://rdrr.io/r/base/all.html)`(``required_cols`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`names`](https://rdrr.io/r/base/names.html)`(``frame``)``)``)`` ``{`\
`      `[`stop`](https://rdrr.io/r/base/stop.html)`(``"Tree frame missing required columns"``)`\
`    ``}`\
`    `\
`    ``# Extract node information safely`\
`    ``node_info`` ``<-`` ``frame`\
`    `\
`    ``# Handle yval2 safely`\
`    ``if`` ``(``"yval2"`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`names`](https://rdrr.io/r/base/names.html)`(``node_info``)`` ``&&`` ``!`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``node_info``$``yval2``)``)`` ``{`\
`      ``# Check dimensions before using rowSums`\
`      ``yval2_data`` ``<-`` ``node_info``$``yval2`\
`      `\
`      ``if`` ``(`[`is.matrix`](https://rdrr.io/r/base/matrix.html)`(``yval2_data``)`` ``&&`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``yval2_data``)`` ``>=`` ``2``)`` ``{`\
`        ``# Safe to use rowSums`\
`        ``node_counts`` ``<-`` `[`rowSums`](https://rdrr.io/pkg/Matrix/man/colSums-methods.html)`(``yval2_data``[``, ``1``:`[`min`](https://rdrr.io/r/base/Extremes.html)`(``2``, `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``yval2_data``)``)``, drop ``=`` ``FALSE``]``)`\
`      ``}`` ``else`` ``if`` ``(`[`is.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(``yval2_data``)`` ``&&`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``yval2_data``)`` ``>=`` ``2``)`` ``{`\
`        ``# Convert to matrix first`\
`        ``yval2_matrix`` ``<-`` `[`as.matrix`](https://rdrr.io/r/base/matrix.html)`(``yval2_data``[``, ``1``:`[`min`](https://rdrr.io/r/base/Extremes.html)`(``2``, `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``yval2_data``)``)``]``)`\
`        ``node_counts`` ``<-`` `[`rowSums`](https://rdrr.io/pkg/Matrix/man/colSums-methods.html)`(``yval2_matrix``)`\
`      ``}`` ``else`` ``{`\
`        ``# Fallback: use node$n if available`\
`        ``node_counts`` ``<-`` ``if`` ``(``"n"`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`names`](https://rdrr.io/r/base/names.html)`(``node_info``)``)`` ``node_info``$``n`` ``else`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``1``, `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``node_info``)``)`\
`      ``}`\
`    ``}`` ``else`` ``{`\
`      ``# Fallback: use node$n or estimate`\
`      ``node_counts`` ``<-`` ``if`` ``(``"n"`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`names`](https://rdrr.io/r/base/names.html)`(``node_info``)``)`` ``node_info``$``n`` ``else`` `[`rep`](https://rdrr.io/r/base/rep.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``data``)``, `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``node_info``)``)`\
`    ``}`\
`    `\
`    ``# Generate rules for leaf nodes`\
`    ``leaf_nodes`` ``<-`` `[`which`](https://rdrr.io/r/base/which.html)`(``node_info``$``var`` ``==`` ``"<leaf>"``)`\
`    `\
`    ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``leaf_nodes``)`` ``==`` ``0``)`` ``{`\
`      `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Warning: No leaf nodes found\n"``)`\
`      `[`return`](https://rdrr.io/r/base/function.html)`(``NULL``)`\
`    ``}`\
`    `\
`    ``rules_list`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``)`\
`    `\
`    ``for`` ``(``i`` ``in`` `[`seq_along`](https://rdrr.io/r/base/seq.html)`(``leaf_nodes``)``)`` ``{`\
`      ``node_idx`` ``<-`` ``leaf_nodes``[``i``]`\
`      `\
`      ``# Get the path to this leaf node`\
`      ``node_path`` ``<-`` `[`path.rpart`](https://rdrr.io/pkg/rpart/man/path.rpart.html)`(``tree_model``, nodes ``=`` `[`as.numeric`](https://rdrr.io/r/base/numeric.html)`(`[`rownames`](https://rdrr.io/r/base/colnames.html)`(``node_info``)``[``node_idx``]``)``)`\
`      `\
`      ``# Extract condition text`\
`      ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``node_path``)`` ``>`` ``0`` ``&&`` ``!`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``node_path``[[``1``]``]``)``)`` ``{`\
`        ``condition_parts`` ``<-`` ``node_path``[[``1``]``]`\
`        ``# Remove the root node (usually just "root")`\
`        ``condition_parts`` ``<-`` ``condition_parts``[``condition_parts`` ``!=`` ``"root"``]`\
`        `\
`        ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``condition_parts``)`` ``>`` ``0``)`` ``{`\
`          ``condition`` ``<-`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``condition_parts``, collapse ``=`` ``" AND "``)`\
`        ``}`` ``else`` ``{`\
`          ``condition`` ``<-`` ``"Always true (root node)"`\
`        ``}`\
`      ``}`` ``else`` ``{`\
`        ``condition`` ``<-`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``"Node"``, ``node_idx``)`\
`      ``}`\
`      `\
`      ``# Get prediction`\
`      ``prediction`` ``<-`` `[`as.character`](https://rdrr.io/r/base/character.html)`(``node_info``$``yval``[``node_idx``]``)`\
`      `\
`      ``# Calculate confidence (proportion of cases)`\
`      ``n_cases`` ``<-`` ``node_counts``[``node_idx``]`\
`      ``confidence`` ``<-`` ``n_cases`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``node_counts``, na.rm ``=`` ``TRUE``)`\
`      `\
`      ``rules_list``[[``i``]``]`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`        rule_id ``=`` ``i``,`\
`        condition ``=`` ``condition``,`\
`        prediction ``=`` ``prediction``,`\
`        confidence ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``confidence``, ``3``)``,`\
`        n_cases ``=`` ``n_cases``,`\
`        stringsAsFactors ``=`` ``FALSE`\
`      ``)`\
`    ``}`\
`    `\
`    ``# Combine all rules`\
`    ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``rules_list``)`` ``>`` ``0``)`` ``{`\
`      ``rules_df`` ``<-`` `[`do.call`](https://rdrr.io/r/base/do.call.html)`(``rbind``, ``rules_list``)`\
`      `[`return`](https://rdrr.io/r/base/function.html)`(``rules_df``)`\
`    ``}`` ``else`` ``{`\
`      `[`return`](https://rdrr.io/r/base/function.html)`(``NULL``)`\
`    ``}`\
`    `\
`  ``}``, error ``=`` ``function``(``e``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Error in export_tree_as_rules:"``, ``e``$``message``, ``"\n"``)`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Tree structure:\n"``)`\
`    ``if`` ``(`[`exists`](https://rdrr.io/r/base/exists.html)`(``"frame"``)``)`` ``{`\
`      `[`print`](https://rdrr.io/r/base/print.html)`(`[`str`](https://rdrr.io/r/utils/str.html)`(``frame``)``)`\
`    ``}`` ``else`` ``{`\
`      `[`print`](https://rdrr.io/r/base/print.html)`(`[`str`](https://rdrr.io/r/utils/str.html)`(``tree_model``)``)`\
`    ``}`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(``NULL``)`\
`  ``}``)`\
`}`\
\
`# Alternative simple rule extraction function`\
`simple_tree_rules`` ``<-`` ``function``(``tree_model``, ``data``)`` ``{`\
`  ``if`` ``(`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``tree_model``)`` ``||`` ``!`[`inherits`](https://rdrr.io/r/base/class.html)`(``tree_model``, ``"rpart"``)``)`` ``{`\
`    `[`return`](https://rdrr.io/r/base/function.html)`(``"No valid tree model available"``)`\
`  ``}`\
`  `\
`  ``# Use rpart's built-in text representation`\
`  ``rules_text`` ``<-`` `[`capture.output`](https://rdrr.io/r/utils/capture.output.html)`(`[`print`](https://rdrr.io/r/base/print.html)`(``tree_model``)``)`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(`[`paste`](https://rdrr.io/r/base/paste.html)`(``rules_text``, collapse ``=`` ``"\n"``)``)`\
`}`\
\
`# Generate exportable rules`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Generating Clinical Decision Support Rules...\n"``)`\
\
`# Check if we have a valid tree from previous chunks`\
`if`` ``(`[`exists`](https://rdrr.io/r/base/exists.html)`(``"cost_tree"``)`` ``&&`` ``!`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``cost_tree``)``)`` ``{`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Exporting rules from cost-sensitive tree...\n"``)`\
`  `\
`  ``# Try the main function first`\
`  ``exported_rules`` ``<-`` ``export_tree_as_rules``(``cost_tree``, ``covid_screening_data``)`\
`  `\
`  ``if`` ``(``!`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``exported_rules``)`` ``&&`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``exported_rules``)`` ``>`` ``0``)`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Successfully exported"``, `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``exported_rules``)``, ``"rules\n"``)`\
`    `\
`    ``# Display the rules`\
`    ``knitr``::`[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``exported_rules``, `\
`                 caption ``=`` ``"Clinical Decision Support Rules"``,`\
`                 align ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``'c'``, ``'l'``, ``'c'``, ``'c'``, ``'c'``)``)`\
`    `\
`    ``# Create a more readable format`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"\n## Human-Readable Decision Rules:\n\n"``)`\
`    ``for`` ``(``i`` ``in`` ``1``:`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``exported_rules``)``)`` ``{`\
`      `[`cat`](https://rdrr.io/r/base/cat.html)`(``"**Rule"``, ``exported_rules``$``rule_id``[``i``]``, ``":**\n"``)`\
`      `[`cat`](https://rdrr.io/r/base/cat.html)`(``"- **If:** "``, ``exported_rules``$``condition``[``i``]``, ``"\n"``)`\
`      `[`cat`](https://rdrr.io/r/base/cat.html)`(``"- **Then:** Predict"``, ``exported_rules``$``prediction``[``i``]``, ``"\n"``)`\
`      `[`cat`](https://rdrr.io/r/base/cat.html)`(``"- **Confidence:** "``, ``exported_rules``$``confidence``[``i``]``*``100``, ``"%\n"``)`\
`      `[`cat`](https://rdrr.io/r/base/cat.html)`(``"- **Based on:** "``, ``exported_rules``$``n_cases``[``i``]``, ``"cases\n\n"``)`\
`    ``}`\
`    `\
`  ``}`` ``else`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Failed to export structured rules. Using simple text representation:\n\n"``)`\
`    ``simple_rules`` ``<-`` ``simple_tree_rules``(``cost_tree``, ``covid_screening_data``)`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(````` "```\n" `````)`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``simple_rules``)`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(````` "\n```\n" `````)`\
`  ``}`\
`  `\
`}`` ``else`` ``{`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"No decision tree available. Creating a simple example tree...\n"``)`\
`  `\
`  ``# Create a simple example tree for demonstration`\
`  ``if`` ``(`[`exists`](https://rdrr.io/r/base/exists.html)`(``"covid_screening_data"``)``)`` ``{`\
`    ``# Ensure we have the necessary columns`\
`    ``if`` ``(``"rapid_antigen"`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`names`](https://rdrr.io/r/base/names.html)`(``covid_screening_data``)`` ``&&`` `\
`        ``"covid_status"`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`names`](https://rdrr.io/r/base/names.html)`(``covid_screening_data``)``)`` ``{`\
`      `\
`      ``# Simple tree with minimal requirements`\
`      ``simple_formula`` ``<-`` ``covid_status`` ``~`` ``rapid_antigen`\
`      `\
`      ``# Check if we have enough data`\
`      ``complete_data`` ``<-`` ``covid_screening_data``[`[`complete.cases`](https://rdrr.io/r/stats/complete.cases.html)`(``covid_screening_data``[`[`c`](https://rdrr.io/r/base/c.html)`(``"rapid_antigen"``, ``"covid_status"``)``]``)``, ``]`\
`      `\
`      ``if`` ``(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``complete_data``)`` ``>`` ``10``)`` ``{`\
`        ``simple_tree`` ``<-`` `[`rpart`](https://rdrr.io/pkg/rpart/man/rpart.html)`(``simple_formula``, `\
`                            data ``=`` ``complete_data``,`\
`                            method ``=`` ``"class"``,`\
`                            control ``=`` `[`rpart.control`](https://rdrr.io/pkg/rpart/man/rpart.control.html)`(``minbucket ``=`` ``5``, cp ``=`` ``0.1``)``)`\
`        `\
`        `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Created simple demonstration tree:\n"``)`\
`        `[`print`](https://rdrr.io/r/base/print.html)`(``simple_tree``)`\
`        `\
`        ``# Try to export rules from simple tree`\
`        ``simple_exported`` ``<-`` ``export_tree_as_rules``(``simple_tree``, ``complete_data``)`\
`        `\
`        ``if`` ``(``!`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``simple_exported``)``)`` ``{`\
`          ``knitr``::`[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``simple_exported``, `\
`                       caption ``=`` ``"Simple Decision Rules (Example)"``,`\
`                       align ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``'c'``, ``'l'``, ``'c'``, ``'c'``, ``'c'``)``)`\
`        ``}`\
`      ``}`` ``else`` ``{`\
`        `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Insufficient data for tree creation\n"``)`\
`      ``}`\
`    ``}`` ``else`` ``{`\
`      `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Required columns not found in data\n"``)`\
`    ``}`\
`  ``}`` ``else`` ``{`\
`    `[`cat`](https://rdrr.io/r/base/cat.html)`(``"No data available for tree creation\n"``)`\
`  ``}`\
`}`\
\
`# Export formats section`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\n## Export Formats\n\n"``)`\
\
`export_formats`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Format ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"JSON"``, ``"XML"``, ``"CSV"``, ``"SQL"``, ``"R Code"``)``,`\
``   `Use Case`  ```=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"Web applications, APIs"``,`\
`    ``"Healthcare standards (HL7)"``,`\
`    ``"Spreadsheet analysis"``,`\
`    ``"Database integration"``,`\
`    ``"R/Statistical software"`\
`  ``)``,`\
`  Complexity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Medium"``, ``"High"``, ``"Low"``, ``"Medium"``, ``"Low"``)``,`\
`  Implementation ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"jsonlite::toJSON()"``,`\
`    ``"XML::xmlTree()"``,`\
`    ``"write.csv()"``,`\
`    ``"Custom SQL generation"``,`\
`    ``"dput() or custom function"`\
`  ``)``,`\
`  stringsAsFactors ``=`` ``FALSE`\
`)`\
\
`knitr``::`[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``export_formats``,`\
`             caption ``=`` ``"Available Export Formats for Decision Rules"``,`\
`             align ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``'l'``, ``'l'``, ``'c'``, ``'l'``)``)`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\n## Implementation Example\n\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Here's how these rules could be implemented in a clinical system:\n\n"``)`\
\
`implementation_example`` ``<-`` ``'`\
`# Example implementation in R`\
`clinical_decision <- function(rapid_antigen_result) {`\
`  if (rapid_antigen_result == "Positive") {`\
`    return(list(`\
`      decision = "Positive",`\
`      confidence = 0.95,`\
`      recommendation = "Confirm with PCR if needed for official diagnosis"`\
`    ))`\
`  } else {`\
`    return(list(`\
`      decision = "Negative", `\
`      confidence = 0.85,`\
`      recommendation = "Consider PCR if high clinical suspicion"`\
`    ))`\
`  }`\
`}`\
\
`# Usage example:`\
`# result <- clinical_decision("Positive")`\
`# print(result$decision)`\
`'`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(````` "```r\n" `````)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``implementation_example``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(````` "```\n" `````)`

### Creating API-Ready Outputs

\
`# Function to create API response for test panel recommendation`\
`create_api_response`` ``<-`` ``function``(``patient_data``, ``optimal_panel``)`` ``{`\
`  ``response`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`    timestamp ``=`` `[`Sys.time`](https://rdrr.io/r/base/Sys.time.html)`(``)``,`\
`    patient_id ``=`` ``patient_data``$``patient_id``,`\
`    recommendations ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`      primary ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`        tests ``=`` ``optimal_panel``$``tests``,`\
`        strategy ``=`` ``optimal_panel``$``strategy``,`\
`        expected_performance ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`          sensitivity ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``optimal_panel``$``sensitivity`` ``*`` ``100``, ``1``)``,`\
`          specificity ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``optimal_panel``$``specificity`` ``*`` ``100``, ``1``)``,`\
`          ppv ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``optimal_panel``$``ppv`` ``*`` ``100``, ``1``)``,`\
`          npv ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``optimal_panel``$``npv`` ``*`` ``100``, ``1``)`\
`        ``)``,`\
`        estimated_cost ``=`` ``optimal_panel``$``cost`\
`      ``)``,`\
`      alternative_protocols ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`        rapid ``=`` ``"Rapid antigen only"``,`\
`        comprehensive ``=`` ``"All available tests"`\
`      ``)`\
`    ``)``,`\
`    warnings ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``)``,`\
`    metadata ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`      model_version ``=`` ``"1.0.0"``,`\
`      confidence_level ``=`` ``"high"`\
`    ``)`\
`  ``)`\
`  `\
`  ``# Add warnings based on patient characteristics`\
`  ``if`` ``(``patient_data``$``age`` ``>`` ``65``)`` ``{`\
`    ``response``$``warnings`` ``<-`` `[`append`](https://rdrr.io/r/base/append.html)`(``response``$``warnings``, `\
`                               ``"High-risk age group - consider lower threshold"``)`\
`  ``}`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``response``)`\
`}`\
\
`# Example API response`\
`example_patient`` ``<-`` ``covid_screening_data``[``1``,``]`\
`example_panel`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`  tests ``=`` ``"rapid_antigen+pcr"``,`\
`  strategy ``=`` ``"parallel_any"``,`\
`  sensitivity ``=`` ``0.97``,`\
`  specificity ``=`` ``0.97``,`\
`  ppv ``=`` ``0.82``,`\
`  npv ``=`` ``0.99``,`\
`  cost ``=`` ``55`\
`)`\
\
`api_response`` ``<-`` ``create_api_response``(``example_patient``, ``example_panel``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"API Response:\n"``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``jsonlite``::`[`toJSON`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)`(``api_response``, pretty ``=`` ``TRUE``)``)`

## Validation and Quality Control

### Cross-Validation with Custom Splits

\
`# Time-based cross-validation for temporal data`\
`time_based_cv`` ``<-`` ``function``(``data``, ``date_column``, ``n_splits`` ``=`` ``5``)`` ``{`\
`  ``# Sort by date`\
`  ``data`` ``<-`` ``data``[`[`order`](https://rdrr.io/r/base/order.html)`(``data``[[``date_column``]``]``)``,``]`\
`  ``n`` ``<-`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``data``)`\
`  `\
`  ``# Create time-based splits`\
`  ``splits`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``)`\
`  ``test_size`` ``<-`` `[`floor`](https://rdrr.io/r/base/Round.html)`(``n`` ``/`` ``(``n_splits`` ``+`` ``1``)``)`\
`  `\
`  ``for`` ``(``i`` ``in`` ``1``:``n_splits``)`` ``{`\
`    ``train_end`` ``<-`` ``test_size`` ``*`` ``i`\
`    ``test_start`` ``<-`` ``train_end`` ``+`` ``1`\
`    ``test_end`` ``<-`` `[`min`](https://rdrr.io/r/base/Extremes.html)`(``test_start`` ``+`` ``test_size`` ``-`` ``1``, ``n``)`\
`    `\
`    ``splits``[[``i``]``]`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`      train ``=`` ``1``:``train_end``,`\
`      test ``=`` ``test_start``:``test_end`\
`    ``)`\
`  ``}`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``splits``)`\
`}`\
\
`# Stratified cross-validation ensuring prevalence balance`\
`stratified_cv`` ``<-`` ``function``(``data``, ``outcome_column``, ``n_folds`` ``=`` ``5``)`` ``{`\
`  ``# Separate by outcome`\
`  ``positive_idx`` ``<-`` `[`which`](https://rdrr.io/r/base/which.html)`(``data``[[``outcome_column``]``]`` ``==`` `[`levels`](https://rdrr.io/r/base/levels.html)`(``data``[[``outcome_column``]``]``)``[``2``]``)`\
`  ``negative_idx`` ``<-`` `[`which`](https://rdrr.io/r/base/which.html)`(``data``[[``outcome_column``]``]`` ``==`` `[`levels`](https://rdrr.io/r/base/levels.html)`(``data``[[``outcome_column``]``]``)``[``1``]``)`\
`  `\
`  ``# Shuffle within strata`\
`  ``positive_idx`` ``<-`` `[`sample`](https://rdrr.io/r/base/sample.html)`(``positive_idx``)`\
`  ``negative_idx`` ``<-`` `[`sample`](https://rdrr.io/r/base/sample.html)`(``negative_idx``)`\
`  `\
`  ``# Create folds maintaining proportion`\
`  ``folds`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``)`\
`  ``pos_per_fold`` ``<-`` `[`length`](https://rdrr.io/r/base/length.html)`(``positive_idx``)`` `[`%/%`](https://rdrr.io/r/base/Arithmetic.html)` ``n_folds`\
`  ``neg_per_fold`` ``<-`` `[`length`](https://rdrr.io/r/base/length.html)`(``negative_idx``)`` `[`%/%`](https://rdrr.io/r/base/Arithmetic.html)` ``n_folds`\
`  `\
`  ``for`` ``(``i`` ``in`` ``1``:``n_folds``)`` ``{`\
`    ``if`` ``(``i`` ``<`` ``n_folds``)`` ``{`\
`      ``fold_pos`` ``<-`` ``positive_idx``[``(``(``i``-``1``)``*``pos_per_fold`` ``+`` ``1``)``:``(``i``*``pos_per_fold``)``]`\
`      ``fold_neg`` ``<-`` ``negative_idx``[``(``(``i``-``1``)``*``neg_per_fold`` ``+`` ``1``)``:``(``i``*``neg_per_fold``)``]`\
`    ``}`` ``else`` ``{`\
`      ``# Last fold gets remaining`\
`      ``fold_pos`` ``<-`` ``positive_idx``[``(``(``i``-``1``)``*``pos_per_fold`` ``+`` ``1``)``:`[`length`](https://rdrr.io/r/base/length.html)`(``positive_idx``)``]`\
`      ``fold_neg`` ``<-`` ``negative_idx``[``(``(``i``-``1``)``*``neg_per_fold`` ``+`` ``1``)``:`[`length`](https://rdrr.io/r/base/length.html)`(``negative_idx``)``]`\
`    ``}`\
`    `\
`    ``folds``[[``i``]``]`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``fold_pos``, ``fold_neg``)`\
`  ``}`\
`  `\
`  `[`return`](https://rdrr.io/r/base/function.html)`(``folds``)`\
`}`\
\
`# Apply stratified CV`\
`folds`` ``<-`` ``stratified_cv``(``covid_screening_data``, ``"covid_status"``, n_folds ``=`` ``5``)`\
\
`# Check fold balance`\
`for`` ``(``i`` ``in`` ``1``:`[`length`](https://rdrr.io/r/base/length.html)`(``folds``)``)`` ``{`\
`  ``fold_data`` ``<-`` ``covid_screening_data``[``folds``[[``i``]``]``,``]`\
`  ``prevalence`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``fold_data``$``covid_status`` ``==`` ``"Positive"``)`\
`  `[`cat`](https://rdrr.io/r/base/cat.html)`(``"Fold"``, ``i``, ``": n ="``, `[`length`](https://rdrr.io/r/base/length.html)`(``folds``[[``i``]``]``)``, `\
`      ``", prevalence ="``, `[`round`](https://rdrr.io/r/base/Round.html)`(``prevalence`` ``*`` ``100``, ``1``)``, ``"%\n"``)`\
`}`

## Conclusion

This vignette has covered advanced features including:

1.  **Custom Optimization**: Multi-objective optimization, Pareto
    frontiers
2.  **Advanced Trees**: Cost-sensitive and ensemble methods
3.  **Complex Constraints**: Business rules and time-dependent
    strategies
4.  **Performance**: Efficient computation and caching
5.  **Integration**: API outputs and clinical decision support
6.  **Validation**: Custom cross-validation schemes

These advanced features enable the Decision Panel Optimization module to
handle complex real-world scenarios while maintaining computational
efficiency and clinical relevance.

## Session Information

\
[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`
