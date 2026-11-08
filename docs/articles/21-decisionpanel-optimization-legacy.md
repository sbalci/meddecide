# Introduction to Decision Panel Optimization

> **Not yet released in meddecide.** This article documents
> `decisionpanel`, which is not part of the meddecide 1.0.4 release. It
> is documented here ahead of a future release, so the options, defaults
> and output described below are subject to change and the analysis will
> not appear in your jamovi menu yet. For the analyses that ship today
> see the [meddecide articles
> index](https://www.serdarbalci.com/meddecide/articles/).

## Introduction

The Decision Panel Optimization module in the `meddecide` package
provides a comprehensive framework for optimizing diagnostic test
combinations in medical decision-making. This vignette introduces the
basic concepts and demonstrates core functionality.

## Key Concepts

### Testing Strategies

When multiple diagnostic tests are available, they can be combined in
different ways:

1.  **Single Testing**: Use individual tests independently
2.  **Parallel Testing**: Perform multiple tests simultaneously
    - ANY rule (OR): Positive if any test is positive
    - ALL rule (AND): Positive only if all tests are positive
    - MAJORITY rule: Positive if majority of tests are positive
3.  **Sequential Testing**: Perform tests in sequence based on previous
    results
    - Stop on first positive
    - Confirmatory (require multiple positives)
    - Exclusion (require multiple negatives)

### Optimization Criteria

The module can optimize test panels based on various criteria:

- **Accuracy**: Overall correct classification rate
- **Sensitivity**: Ability to detect disease (minimize false negatives)
- **Specificity**: Ability to rule out disease (minimize false
  positives)
- **Predictive Values**: PPV and NPV
- **Cost-Effectiveness**: Balance performance with resource utilization
- **Utility**: Custom utility functions incorporating costs of errors

## Installation and Loading

\
`# Install meddecide package`\
[`install.packages`](https://rdrr.io/r/utils/install.packages.html)`(``"meddecide"``)`\
\
`# Or install from GitHub`\
`devtools``::`[`install_github`](https://devtools.r-lib.org/reference/install-deprecated.html)`(``"ClinicoPath/meddecide"``)`

\
`# Load required packages`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`rpart`](https://github.com/bethatkinson/rpart)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`rpart.plot`](http://www.milbo.org/rpart-plot/index.md)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`knitr`](https://yihui.org/knitr/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`forcats`](https://forcats.tidyverse.org/)`)`

## Basic Example: COVID-19 Screening

Let’s start with a simple example using COVID-19 screening data:

\
`# Examine the data structure`\
[`str`](https://rdrr.io/r/utils/str.html)`(``covid_screening_data``)`\
\
`# Check disease prevalence`\
[`table`](https://rdrr.io/r/base/table.html)`(``covid_screening_data``$``covid_status``)`\
[`prop.table`](https://rdrr.io/r/base/proportions.html)`(`[`table`](https://rdrr.io/r/base/table.html)`(``covid_screening_data``$``covid_status``)``)`

### Running Basic Analysis

\
`# Basic decision panel analysis`\
`covid_panel`` ``<-`` ``decisionpanel``(`\
`  data ``=`` ``covid_screening_data``,`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"rapid_antigen"``, ``"pcr"``, ``"chest_ct"``)``,`\
`  testLevels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Positive"``, ``"Positive"``, ``"Abnormal"``)``,`\
`  gold ``=`` ``"covid_status"``,`\
`  goldPositive ``=`` ``"Positive"``,`\
`  strategies ``=`` ``"all"``,`\
`  optimizationCriteria ``=`` ``"accuracy"`\
`)`

### Interpreting Results

The analysis provides several key outputs:

1.  **Individual Test Performance**: How each test performs alone
2.  **Optimal Panel**: The best combination of tests
3.  **Strategy Comparison**: Performance of different testing approaches
4.  **Decision Tree**: Optimal sequence for testing

## Understanding Testing Strategies

### Parallel Testing Example

\
`# Simulate parallel testing with ANY rule`\
`# Positive if rapid_antigen OR pcr is positive`\
`parallel_any`` ``<-`` `[`with`](https://rdrr.io/r/base/with.html)`(`\
`  ``covid_screening_data``,`\
`  ``rapid_antigen`` ``==`` ``"Positive"`` ``|`` ``pcr`` ``==`` ``"Positive"`\
`)`\
\
`# Create confusion matrix`\
`conf_matrix_any`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(`\
`  Predicted ``=`` ``parallel_any``,`\
`  Actual ``=`` ``covid_screening_data``$``covid_status`` ``==`` ``"Positive"`\
`)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``conf_matrix_any``)`\
\
`# Calculate metrics`\
`sensitivity_any`` ``<-`` ``conf_matrix_any``[``2``, ``2``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``conf_matrix_any``[``, ``2``]``)`\
`specificity_any`` ``<-`` ``conf_matrix_any``[``1``, ``1``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``conf_matrix_any``[``, ``1``]``)`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Parallel ANY Rule:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(`[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"Sensitivity: %.1f%%\n"``, ``sensitivity_any`` ``*`` ``100``)``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(`[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"Specificity: %.1f%%\n"``, ``specificity_any`` ``*`` ``100``)``)`

### Sequential Testing Example

\
`# Simulate sequential testing`\
`# Start with rapid test, only do PCR if rapid is positive`\
`sequential_result`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``"Negative"``, `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``covid_screening_data``)``)`\
\
`# Those with positive rapid test`\
`rapid_pos_idx`` ``<-`` `[`which`](https://rdrr.io/r/base/which.html)`(``covid_screening_data``$``rapid_antigen`` ``==`` ``"Positive"``)`\
\
`# Among those, check PCR`\
`sequential_result``[``rapid_pos_idx``]`` ``<-`\
`  `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``covid_screening_data``$``pcr``[``rapid_pos_idx``]`` ``==`` ``"Positive"``,`\
`    ``"Positive"``, ``"Negative"`\
`  ``)`\
\
`# Create confusion matrix`\
`conf_matrix_seq`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(`\
`  Predicted ``=`` ``sequential_result`` ``==`` ``"Positive"``,`\
`  Actual ``=`` ``covid_screening_data``$``covid_status`` ``==`` ``"Positive"`\
`)`\
\
[`print`](https://rdrr.io/r/base/print.html)`(``conf_matrix_seq``)`\
\
`# Calculate metrics`\
`sensitivity_seq`` ``<-`` ``conf_matrix_seq``[``2``, ``2``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``conf_matrix_seq``[``, ``2``]``)`\
`specificity_seq`` ``<-`` ``conf_matrix_seq``[``1``, ``1``]`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``conf_matrix_seq``[``, ``1``]``)`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nSequential Testing:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(`[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"Sensitivity: %.1f%%\n"``, ``sensitivity_seq`` ``*`` ``100``)``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(`[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"Specificity: %.1f%%\n"``, ``specificity_seq`` ``*`` ``100``)``)`\
\
`# Calculate cost savings`\
`pcr_tests_saved`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``covid_screening_data``$``rapid_antigen`` ``==`` ``"Negative"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(`[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(`\
`  ``"PCR tests saved: %d (%.1f%%)\n"``,`\
`  ``pcr_tests_saved``,`\
`  ``pcr_tests_saved`` ``/`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``covid_screening_data``)`` ``*`` ``100`\
`)``)`

## Cost-Effectiveness Analysis

When costs are considered, the optimal strategy may change:

\
`# Analysis with costs`\
`covid_panel_cost`` ``<-`` ``decisionpanel``(`\
`  data ``=`` ``covid_screening_data``,`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"rapid_antigen"``, ``"pcr"``, ``"chest_ct"``)``,`\
`  testLevels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Positive"``, ``"Positive"``, ``"Abnormal"``)``,`\
`  gold ``=`` ``"covid_status"``,`\
`  goldPositive ``=`` ``"Positive"``,`\
`  strategies ``=`` ``"all"``,`\
`  optimizationCriteria ``=`` ``"utility"``,`\
`  useCosts ``=`` ``TRUE``,`\
`  testCosts ``=`` ``"5,50,200"``, ``# Costs for each test`\
`  fpCost ``=`` ``500``, ``# Cost of false positive`\
`  fnCost ``=`` ``5000`` ``# Cost of false negative`\
`)`

## Visualization

### Performance Comparison Plot

\
`# Create performance comparison data`\
`strategies`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Strategy ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Rapid Only"``, ``"PCR Only"``, ``"Parallel ANY"``, ``"Sequential"``)``,`\
`  Sensitivity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``65``, ``95``, ``98``, ``62``)``,`\
`  Specificity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``98``, ``99``, ``97``, ``99.9``)``,`\
`  Cost ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``5``, ``50``, ``55``, ``15``)`\
`)`\
\
`# Plot sensitivity vs specificity`\
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``strategies``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``100`` ``-`` ``Specificity``, y ``=`` ``Sensitivity``)``)`` ``+`\
`  `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``size ``=`` ``Cost``)``, alpha ``=`` ``0.6``)`` ``+`\
`  `[`geom_text`](https://ggplot2.tidyverse.org/reference/geom_text.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``label ``=`` ``Strategy``)``, vjust ``=`` ``-``1``)`` ``+`\
`  `[`scale_size_continuous`](https://ggplot2.tidyverse.org/reference/scale_size.html)`(``range ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``3``, ``10``)``)`` ``+`\
`  `[`xlim`](https://ggplot2.tidyverse.org/reference/lims.html)`(``0``, ``5``)`` ``+`\
`  `[`ylim`](https://ggplot2.tidyverse.org/reference/lims.html)`(``60``, ``100``)`` ``+`\
`  `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`\
`    title ``=`` ``"Testing Strategy Comparison"``,`\
`    x ``=`` ``"False Positive Rate (%)"``,`\
`    y ``=`` ``"Sensitivity (%)"``,`\
`    size ``=`` ``"Cost ($)"`\
`  ``)`` ``+`\
`  `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`

## Decision Trees

Decision trees provide clear algorithms for clinical use:

\
`# Generate decision tree`\
`covid_tree`` ``<-`` ``decisionpanel``(`\
`  data ``=`` ``covid_screening_data``,`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"rapid_antigen"``, ``"pcr"``, ``"chest_ct"``, ``"symptom_score"``)``,`\
`  testLevels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Positive"``, ``"Positive"``, ``"Abnormal"``, ``">5"``)``,`\
`  gold ``=`` ``"covid_status"``,`\
`  goldPositive ``=`` ``"Positive"``,`\
`  createTree ``=`` ``TRUE``,`\
`  treeMethod ``=`` ``"cart"``,`\
`  maxDepth ``=`` ``3`\
`)`

### Interpreting the Tree

A typical decision tree output might look like:

    1. Start with Rapid Antigen Test
       ├─ If Positive (2% of patients)
       │  └─ Confirm with PCR
       │     ├─ If Positive → COVID Positive (PPV: 95%)
       │     └─ If Negative → COVID Negative (NPV: 98%)
       └─ If Negative (98% of patients)
          ├─ If Symptoms > 5
          │  └─ Perform Chest CT
          │     ├─ If Abnormal → Perform PCR
          │     └─ If Normal → COVID Negative
          └─ If Symptoms <= 5 → COVID Negative

## Advanced Features

### Cross-Validation

Validate panel performance using k-fold cross-validation:

\
`# Run with cross-validation`\
`covid_panel_cv`` ``<-`` ``decisionpanel``(`\
`  data ``=`` ``covid_screening_data``,`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"rapid_antigen"``, ``"pcr"``, ``"chest_ct"``)``,`\
`  testLevels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Positive"``, ``"Positive"``, ``"Abnormal"``)``,`\
`  gold ``=`` ``"covid_status"``,`\
`  goldPositive ``=`` ``"Positive"``,`\
`  crossValidate ``=`` ``TRUE``,`\
`  nFolds ``=`` ``5``,`\
`  seed ``=`` ``123`\
`)`

### Bootstrap Confidence Intervals

Get uncertainty estimates for performance metrics:

\
`# Run with bootstrap`\
`covid_panel_boot`` ``<-`` ``decisionpanel``(`\
`  data ``=`` ``covid_screening_data``,`\
`  tests ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"rapid_antigen"``, ``"pcr"``, ``"chest_ct"``)``,`\
`  testLevels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Positive"``, ``"Positive"``, ``"Abnormal"``)``,`\
`  gold ``=`` ``"covid_status"``,`\
`  goldPositive ``=`` ``"Positive"``,`\
`  bootstrap ``=`` ``TRUE``,`\
`  bootReps ``=`` ``1000``,`\
`  seed ``=`` ``123`\
`)`

## Best Practices

1.  **Start Simple**: Begin with individual test performance before
    combinations
2.  **Consider Context**: Screening vs. diagnosis requires different
    strategies
3.  **Validate Results**: Use cross-validation or separate test sets
4.  **Include Costs**: Real-world decisions must consider resources
5.  **Think Sequentially**: Often more efficient than parallel testing
6.  **Set Constraints**: Define minimum acceptable performance
7.  **Interpret Clinically**: Statistical optimality isn’t everything

## Conclusion

The Decision Panel Optimization module provides a systematic approach to
combining diagnostic tests. By considering various strategies, costs,
and constraints, it helps identify practical testing algorithms that
balance performance with resource utilization.

## Next Steps

- See the “Clinical Applications” vignette for disease-specific examples
- Review “Advanced Optimization” for complex scenarios
- Check “Implementation Guide” for deploying algorithms in practice

## Session Information

\
[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`
