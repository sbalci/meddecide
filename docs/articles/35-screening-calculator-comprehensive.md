# Screening Test Calculator: A Comprehensive Guide

> **Not yet released in meddecide.** This article documents
> `screeningcalculator`, which is not part of the meddecide 1.0.4
> release. It is documented here ahead of a future release, so the
> options, defaults and output described below are subject to change and
> the analysis will not appear in your jamovi menu yet. For the analyses
> that ship today see the [meddecide articles
> index](https://www.serdarbalci.com/meddecide/articles/).

## Introduction

The Screening Test Calculator is a powerful tool for understanding how
diagnostic test characteristics interact with disease prevalence to
determine the clinical value of test results. This guide demonstrates
how to use Bayes’ theorem in clinical practice through realistic
scenarios and sequential testing examples.

### Key Learning Objectives

After reading this guide, you will understand:

- How sensitivity, specificity, and prevalence affect predictive values
- When screening tests work well (and when they don’t)
- How to interpret likelihood ratios in clinical practice
- The power of sequential testing and confirmatory tests
- Real-world applications across medical specialties

### What Makes This Calculator Special

Unlike simple calculators that just compute numbers, this tool:

- **Provides clinical context** with real-world scenarios
- **Demonstrates sequential testing** showing how probabilities update
  with each test
- **Includes Fagan nomograms** for visual probability assessment
- **Offers extensive example datasets** from multiple medical
  specialties
- **Validates inputs** and provides clinical plausibility warnings

## Understanding the Fundamentals

### Bayes’ Theorem in Medicine

The screening calculator applies Bayes’ theorem to medical testing:

**Prior Probability** (Prevalence) + **Test Result** → **Posterior
Probability** (Predictive Value)

#### Key Formulas

**Positive Predictive Value (PPV)**:

    PPV = (Sensitivity × Prevalence) / [(Sensitivity × Prevalence) + (1-Specificity) × (1-Prevalence)]

**Negative Predictive Value (NPV)**:

    NPV = (Specificity × (1-Prevalence)) / [(Specificity × (1-Prevalence)) + (1-Sensitivity) × Prevalence]

**Likelihood Ratios**:

    Positive LR = Sensitivity / (1-Specificity)
    Negative LR = (1-Sensitivity) / Specificity

### Clinical Interpretation Guidelines

| Metric | Range  | Clinical Meaning                                          |
|--------|--------|-----------------------------------------------------------|
| PPV    | \<10%  | High false positive rate - confirmatory testing essential |
| PPV    | 10-50% | Moderate confidence - consider additional testing         |
| PPV    | 50-80% | Good confidence - proceed with clinical follow-up         |
| PPV    | \>80%  | Excellent confidence - high likelihood of disease         |
| NPV    | \>95%  | Disease can be confidently ruled out                      |
| LR+    | \>10   | Strong evidence for disease                               |
| LR+    | 5-10   | Moderate evidence for disease                             |
| LR+    | 2-5    | Weak evidence for disease                                 |
| LR-    | \<0.1  | Strong evidence against disease                           |

## Example Data and Scenarios

### Loading the Example Datasets

The package includes five comprehensive datasets with realistic clinical
scenarios:

\
`# Load all screening calculator datasets`\
[`data`](https://rdrr.io/r/utils/data.html)`(``screening_examples``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``prevalence_demo``)`` `\
[`data`](https://rdrr.io/r/utils/data.html)`(``performance_demo``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``sequential_demo``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``common_tests``)`\
\
`# Display overview of main clinical scenarios`\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``screening_examples``[``1``:``5``, `[`c`](https://rdrr.io/r/base/c.html)`(``"scenario"``, ``"setting"``, ``"sensitivity"``, ``"specificity"``, ``"prevalence"``, ``"ppv"``)``]``, `\
`      caption ``=`` ``"Sample Clinical Scenarios"``,`\
`      digits ``=`` ``3``)`

### COVID-19 Testing Scenarios

Let’s examine how COVID-19 rapid tests perform in different settings:

\
`covid_data`` ``<-`` ``screening_examples``[``screening_examples``$``scenario`` ``==`` ``"COVID-19 Rapid Test"``, ``]`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``covid_data``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"setting"``, ``"prevalence"``, ``"ppv"``, ``"npv"``, ``"interpretation"``)``]``,`\
`      caption ``=`` ``"COVID-19 Rapid Test Performance by Setting"``,`\
`      digits ``=`` ``3``)`

#### Key Insights:

1.  **Community screening** (2% prevalence): Only 26% of positive tests
    are true positives
2.  **Outbreak testing** (15% prevalence): 78% of positive tests are
    true positives\
3.  **Symptomatic patients** (40% prevalence): 94% of positive tests are
    true positives

This demonstrates the critical importance of prevalence in test
interpretation!

### Cancer Screening Examples

Mammography shows the classic challenge of cancer screening:

\
`mammo_data`` ``<-`` ``screening_examples``[``screening_examples``$``scenario`` ``==`` ``"Mammography Screening"``, ``]`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``mammo_data``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"setting"``, ``"prevalence"``, ``"sensitivity"``, ``"specificity"``, ``"ppv"``, ``"npv"``)``]``,`\
`      caption ``=`` ``"Mammography Performance by Age Group"``, `\
`      digits ``=`` ``3``)`

Even with good test characteristics (80-85% sensitivity, 88-92%
specificity), PPV remains low due to low cancer prevalence. This
explains why positive mammograms require tissue confirmation.

## Prevalence Effects: The Most Important Concept

### Demonstration with Fixed Test Performance

\
`# Use the prevalence demo data`\
`prevalence_plot_data`` ``<-`` ``prevalence_demo`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``prevalence``, ``ppv``, ``npv``)`` `[`%>%`](https://www.serdarbalci.com/meddecide/reference/pipe.md)\
`  ``tidyr``::`[`pivot_longer`](https://tidyr.tidyverse.org/reference/pivot_longer.html)`(``cols ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``ppv``, ``npv``)``, names_to ``=`` ``"metric"``, values_to ``=`` ``"value"``)`\
\
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``prevalence_plot_data``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``prevalence``, y ``=`` ``value``, color ``=`` ``metric``)``)`` ``+`\
`  `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``size ``=`` ``1.2``)`` ``+`\
`  `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(``size ``=`` ``3``)`` ``+`\
`  `[`scale_x_log10`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`)`` ``+`\
`  `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`, limits ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``1``)``)`` ``+`\
`  `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(``title ``=`` ``"How Disease Prevalence Affects Predictive Values"``,`\
`       subtitle ``=`` ``"Fixed test performance: Sensitivity = 90%, Specificity = 90%"``,`\
`       x ``=`` ``"Disease Prevalence (log scale)"``,`\
`       y ``=`` ``"Predictive Value"``, `\
`       color ``=`` ``"Metric"``)`` ``+`\
`  `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`` ``+`\
`  `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``legend.position ``=`` ``"bottom"``)`

### Critical Clinical Lessons

1.  **In low prevalence settings**: Even excellent tests have poor PPV
2.  **NPV remains high** across most prevalence ranges
3.  **Screening vs. diagnostic contexts** require different
    interpretation
4.  **Sequential testing** can dramatically improve diagnostic accuracy

## Sequential Testing: The Power of Multiple Tests

### HIV Testing Example

HIV testing demonstrates the power of sequential testing:

\
`hiv_data`` ``<-`` ``screening_examples``[``screening_examples``$``scenario`` ``==`` ``"HIV Testing"``, ``]`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``hiv_data``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"setting"``, ``"prevalence"``, ``"ppv"``, ``"clinical_action"``)``]``,`\
`      caption ``=`` ``"HIV Testing: From Screening to Confirmation"``,`\
`      digits ``=`` ``3``)`

The progression from 9% PPV (general population screening) to \>99%
(confirmatory testing) shows how sequential testing transforms
diagnostic certainty.

### Mathematical Progression

\
`# Show how probability evolves through testing`\
`sequential_data`` ``<-`` ``sequential_demo`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``sequential_data``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"test_sequence"``, ``"final_probability"``)``]``,`\
`      caption ``=`` ``"Disease Probability Evolution Through Sequential Testing"``,`\
`      digits ``=`` ``3``)`

\
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``sequential_data``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``test_sequence``, y ``=`` ``final_probability``)``)`` ``+`\
`  `[`geom_col`](https://ggplot2.tidyverse.org/reference/geom_bar.html)`(``fill ``=`` ``"steelblue"``, alpha ``=`` ``0.7``)`` ``+`\
`  `[`geom_text`](https://ggplot2.tidyverse.org/reference/geom_text.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``label ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(``final_probability`` ``*`` ``100``, ``1``)``, ``"%"``)``)``, `\
`            vjust ``=`` ``-``0.5``, size ``=`` ``4``)`` ``+`\
`  `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`, limits ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``1``)``)`` ``+`\
`  `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(``title ``=`` ``"Disease Probability After Sequential Testing"``,`\
`       subtitle ``=`` ``"Sensitivity = 85%, Specificity = 90%, Initial Prevalence = 10%"``,`\
`       x ``=`` ``"Test Sequence Pattern"``,`\
`       y ``=`` ``"Final Disease Probability"``)`` ``+`\
`  `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`` ``+`\
`  `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``axis.text.x ``=`` `[`element_text`](https://ggplot2.tidyverse.org/reference/element.html)`(``angle ``=`` ``45``, hjust ``=`` ``1``)``)`

## Practical Clinical Applications

### When to Use the Screening Calculator

#### 1. **Evaluating Screening Programs**

- Determine appropriate populations for screening
- Calculate expected false positive rates
- Plan confirmatory testing strategies

#### 2. **Diagnostic Test Interpretation**

- Understand confidence levels in test results
- Plan sequential testing approaches
- Counsel patients about test limitations

#### 3. **Educational Purposes**

- Teach Bayes’ theorem concepts
- Demonstrate prevalence effects
- Show power of confirmatory testing

#### 4. **Quality Improvement**

- Evaluate diagnostic pathways
- Optimize test ordering protocols
- Reduce unnecessary procedures

### Test Performance Comparison

\
`# Create heatmap showing PPV across different sens/spec combinations`\
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``performance_demo``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` `[`factor`](https://rdrr.io/r/base/factor.html)`(``specificity``)``, y ``=`` `[`factor`](https://rdrr.io/r/base/factor.html)`(``sensitivity``)``, fill ``=`` ``ppv``)``)`` ``+`\
`  `[`geom_tile`](https://ggplot2.tidyverse.org/reference/geom_tile.html)`(``)`` ``+`\
`  `[`geom_text`](https://ggplot2.tidyverse.org/reference/geom_text.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``label ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``ppv``, ``2``)``)``, color ``=`` ``"white"``, size ``=`` ``4``)`` ``+`\
`  `[`scale_fill_gradient`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)`(``low ``=`` ``"red"``, high ``=`` ``"green"``, name ``=`` ``"PPV"``, labels ``=`` ``scales``::`[`percent`](https://scales.r-lib.org/reference/percent_format.html)`)`` ``+`\
`  `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(``title ``=`` ``"Positive Predictive Value Heatmap"``,`\
`       subtitle ``=`` ``"Fixed prevalence = 10%"``,`\
`       x ``=`` ``"Specificity"``, `\
`       y ``=`` ``"Sensitivity"``)`` ``+`\
`  `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`

### Reference Test Characteristics

\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``common_tests``, `\
`      caption ``=`` ``"Common Clinical Tests: Reference Characteristics"``,`\
`      col.names ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Test"``, ``"Sensitivity Range"``, ``"Specificity Range"``, ``"Typical Prevalence"``, ``"Clinical Use"``)``)`

## Using the Calculator in jamovi

### Step-by-Step Guide

#### 1. **Basic Setup**

- Navigate to **meddecide** → **Decision** → **Screening Test
  Calculator**
- Enter test characteristics:
  - **Sensitivity**: True positive rate (0.01 to 0.99)
  - **Specificity**: True negative rate (0.01 to 0.99)\
  - **Prevalence**: Disease prevalence in your population (0.001 to
    0.999)

#### 2. **Interpretation Options**

- **Show 2x Test Repetition**: See results for two consecutive tests
- **Show 3x Test Repetition**: See results for three consecutive tests
- **Show Footnotes**: Get detailed explanations of each metric
- **Fagan Nomogram**: Visual probability assessment tool

#### 3. **Results Interpretation**

- **Single Test Results**: Basic PPV, NPV, and likelihood ratios
- **Sequential Testing Tables**: Probability evolution through multiple
  tests
- **Clinical Warnings**: Alerts for unusual parameter combinations
- **Explanatory Text**: Detailed guidance and clinical examples

### Input Validation and Warnings

The calculator includes intelligent validation:

#### Error Conditions

- Values outside 0-1 range
- Missing or invalid inputs
- Mathematical impossibilities

#### Clinical Warnings

- Sensitivity or specificity \<50% (unusual for clinical tests)
- Sensitivity or specificity \>99% (rarely achieved)
- Very low prevalence (\<0.1%) leading to extremely low PPV
- Combined sensitivity + specificity \<100% (poor test performance)

### Advanced Features

#### Fagan Nomograms

Visual tools for probability assessment: - Connect pre-test probability
to likelihood ratio - Read post-test probability directly from the
nomogram - Available for single tests and sequential testing scenarios

#### Clinical Context

Built-in examples from: - **COVID-19 testing** in different
populations - **Cancer screening** across age groups\
\- **Cardiac stress testing** in various risk categories - **Infectious
disease screening** and confirmation - **Biomarker testing** for cancer
detection

## Advanced Clinical Scenarios

### Multi-Stage Diagnostic Pathways

#### Coronary Artery Disease Detection

\
`# Simulate a typical CAD diagnostic pathway`\
`cad_pathway`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Stage ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Pre-test"``, ``"After Stress Test"``, ``"After Catheterization"``)``,`\
`  Test ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Clinical Assessment"``, ``"Exercise Stress Test"``, ``"Cardiac Catheterization"``)``,`\
`  Prevalence ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.25``, ``0.70``, ``0.95``)``,`\
`  Test_Performance ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"N/A"``, ``"Sens 85%, Spec 75%"``, ``"Sens 95%, Spec 98%"``)``,`\
`  Clinical_Action ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Risk stratification"``, ``"Consider catheterization"``, ``"Treatment planning"``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``cad_pathway``, caption ``=`` ``"Coronary Artery Disease: Multi-Stage Diagnostic Pathway"``)`

#### Breast Cancer Screening and Diagnosis

\
`breast_pathway`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Stage ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Population Screening"``, ``"Abnormal Mammogram"``, ``"Tissue Diagnosis"``)``,`\
`  Prevalence ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"0.8%"``, ``"7.2%"``, ``"92%"``)``,`\
`  PPV ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"N/A"``, ``"7.2%"``, ``"92%"``)``, `\
`  Next_Step ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Annual mammography"``, ``"Tissue biopsy"``, ``"Treatment planning"``)``,`\
`  False_Positive_Rate ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"N/A"``, ``"93%"``, ``"8%"``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``breast_pathway``, caption ``=`` ``"Breast Cancer: From Screening to Diagnosis"``)`

### Outbreak Investigation Scenarios

During disease outbreaks, prevalence changes dramatically:

\
`outbreak_data`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Setting ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Pre-outbreak"``, ``"Early outbreak"``, ``"Peak outbreak"``, ``"Post-outbreak"``)``,`\
`  Estimated_Prevalence ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.001``, ``0.05``, ``0.20``, ``0.02``)``,`\
`  PPV_Rapid_Test ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.08``, ``0.46``, ``0.81``, ``0.26``)``,`\
`  Clinical_Strategy ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Standard screening"``, ``"Enhanced surveillance"``, ``"Containment focus"``, ``"Return to baseline"``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``outbreak_data``, `\
`      caption ``=`` ``"COVID-19 Testing Strategy by Outbreak Phase"``,`\
`      digits ``=`` ``2``)`

## Statistical Concepts and Calculations

### Understanding Likelihood Ratios

Likelihood ratios quantify how much a test result changes disease
probability:

\
`lr_guide`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  LR_Positive ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``">10"``, ``"5-10"``, ``"2-5"``, ``"1-2"``, ``"<1"``)``,`\
`  Evidence_For ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Strong"``, ``"Moderate"``, ``"Weak"``, ``"Minimal"``, ``"Against"``)``,`\
`  LR_Negative ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"<0.1"``, ``"0.1-0.2"``, ``"0.2-0.5"``, ``"0.5-1"``, ``">1"``)``,`\
`  Evidence_Against ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Strong"``, ``"Moderate"``, ``"Weak"``, ``"Minimal"``, ``"For"``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``lr_guide``, caption ``=`` ``"Likelihood Ratio Interpretation Guide"``)`

### Probability Conversion

Converting between odds and probabilities:

\
`conversion_examples`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Probability ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.01``, ``0.05``, ``0.10``, ``0.25``, ``0.50``, ``0.75``, ``0.90``)``,`\
`  Odds ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"1:99"``, ``"1:19"``, ``"1:9"``, ``"1:3"``, ``"1:1"``, ``"3:1"``, ``"9:1"``)``,`\
`  Clinical_Context ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Rare disease"``, ``"Uncommon"``, ``"Screening"``, ``"Symptomatic"``, ``"50-50"``, ``"Likely"``, ``"Very likely"``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``conversion_examples``, caption ``=`` ``"Probability to Odds Conversion Examples"``)`

## Case Studies

### Case Study 1: PSA Screening Dilemma

**Scenario**: 55-year-old man with elevated PSA (4.5 ng/mL)

**Test Characteristics**: - Sensitivity: 70% - Specificity: 80%\
\- Prevalence in this age group: 3%

**Calculations**:

\
`psa_ppv`` ``<-`` ``(``0.70`` ``*`` ``0.03``)`` ``/`` ``(``(``0.70`` ``*`` ``0.03``)`` ``+`` ``(``0.20`` ``*`` ``0.97``)``)`\
`psa_npv`` ``<-`` ``(``0.80`` ``*`` ``0.97``)`` ``/`` ``(``(``0.80`` ``*`` ``0.97``)`` ``+`` ``(``0.30`` ``*`` ``0.03``)``)`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"PSA Screening Results:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"PPV ="``, `[`round`](https://rdrr.io/r/base/Round.html)`(``psa_ppv`` ``*`` ``100``, ``1``)``, ``"%\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"NPV ="``, `[`round`](https://rdrr.io/r/base/Round.html)`(``psa_npv`` ``*`` ``100``, ``1``)``, ``"%\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nClinical Interpretation:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"- Only"``, `[`round`](https://rdrr.io/r/base/Round.html)`(``psa_ppv`` ``*`` ``100``, ``1``)``, ``"% of positive PSA tests indicate cancer\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"- Tissue biopsy needed for confirmation\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"- Consider patient preferences and comorbidities\n"``)`

### Case Study 2: COVID-19 Contact Tracing

**Scenario**: Contact of confirmed COVID-19 case, asymptomatic

**Initial rapid test**: Negative **Question**: How confident can we be
that they don’t have COVID-19?

\
`# Scenario parameters`\
`covid_sens`` ``<-`` ``0.85`\
`covid_spec`` ``<-`` ``0.95`\
`covid_prev_contact`` ``<-`` ``0.15``  ``# Higher prevalence as a contact`\
\
`# Calculate NPV`\
`covid_npv`` ``<-`` ``(``covid_spec`` ``*`` ``(``1`` ``-`` ``covid_prev_contact``)``)`` ``/`` `\
`             ``(``(``covid_spec`` ``*`` ``(``1`` ``-`` ``covid_prev_contact``)``)`` ``+`` ``(``(``1`` ``-`` ``covid_sens``)`` ``*`` ``covid_prev_contact``)``)`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"COVID-19 Contact Tracing:\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Negative rapid test NPV ="``, `[`round`](https://rdrr.io/r/base/Round.html)`(``covid_npv`` ``*`` ``100``, ``1``)``, ``"%\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"Probability of disease despite negative test ="``, `[`round`](https://rdrr.io/r/base/Round.html)`(``(``1``-``covid_npv``)`` ``*`` ``100``, ``1``)``, ``"%\n"``)`\
[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nRecommendation: Consider repeat testing or quarantine period\n"``)`

## Troubleshooting and Common Mistakes

### Common Input Errors

#### 1. **Confusing Sensitivity and Specificity**

- **Sensitivity**: How often the test is positive when disease is
  present
- **Specificity**: How often the test is negative when disease is absent

#### 2. **Using Wrong Prevalence**

- **Population prevalence**: For screening scenarios
- **Clinical prevalence**: For symptomatic patients\
- **Post-test prevalence**: For sequential testing

#### 3. **Misinterpreting Results**

- **PPV depends heavily on prevalence**
- **NPV is often high even for poor tests**
- **Likelihood ratios are prevalence-independent**

### Clinical Pitfalls

#### 1. **Over-relying on Screening Tests**

Remember: Low prevalence = Low PPV, even for good tests

#### 2. **Ignoring Pre-test Probability**

Clinical assessment should always inform test interpretation

#### 3. **Stopping After One Test**

Sequential testing often dramatically improves diagnostic accuracy

### Technical Issues

#### Input Validation Messages

The calculator will warn you about: - Unrealistic test characteristics -
Extreme prevalence values - Clinically implausible combinations

#### Mathematical Edge Cases

- Perfect specificity → Infinite positive LR
- Zero specificity → Infinite negative LR\
- Extreme prevalence → Undefined predictive values

## Best Practices and Recommendations

### For Clinical Practice

#### 1. **Before Ordering Tests**

- Estimate pre-test probability
- Consider what you’ll do with results
- Plan for positive AND negative results

#### 2. **When Interpreting Results**

- Always consider prevalence in your population
- Use likelihood ratios for probability updating
- Consider sequential testing when appropriate

#### 3. **Patient Communication**

- Explain uncertainty in test results
- Discuss false positive/negative possibilities
- Involve patients in decision-making

### For Education and Training

#### 1. **Teaching Bayes’ Theorem**

- Start with prevalence effects
- Use realistic clinical scenarios
- Demonstrate with visual tools (Fagan nomograms)

#### 2. **Quality Improvement Projects**

- Evaluate current diagnostic pathways
- Identify opportunities for sequential testing
- Reduce unnecessary procedures

#### 3. **Research Applications**

- Design diagnostic studies
- Calculate sample sizes for test evaluation
- Interpret published test characteristics

## Advanced Topics

### Test Combinations and Parallel Testing

When multiple tests are performed simultaneously:

\
`# Example: Combined testing approach`\
`parallel_example`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  Strategy ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Test A alone"``, ``"Test B alone"``, ``"Either positive"``, ``"Both positive"``)``,`\
`  Sensitivity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.80``, ``0.70``, ``0.94``, ``0.56``)``,`\
`  Specificity ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.90``, ``0.95``, ``0.86``, ``0.99``)``,`\
`  Clinical_Use ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Standard approach"``, ``"Alternative test"``, ``"High sensitivity"``, ``"High specificity"``)`\
`)`\
\
[`kable`](https://rdrr.io/pkg/knitr/man/kable.html)`(``parallel_example``, caption ``=`` ``"Parallel Testing Strategies"``)`

### Bayesian Networks and Complex Pathways

For more complex diagnostic scenarios: - Multiple risk factors -
Multiple test results - Time-dependent probabilities -
Cost-effectiveness considerations

### Population Health Applications

#### Screening Program Design

- Target population selection
- Expected false positive rates
- Resource allocation planning
- Cost-effectiveness analysis

#### Outbreak Response

- Testing strategy optimization
- Contact tracing efficiency
- Resource allocation during surges

## Conclusion

The Screening Test Calculator provides a comprehensive platform for
understanding and applying Bayesian probability concepts in clinical
practice. By combining rigorous mathematical foundations with practical
clinical examples, it bridges the gap between statistical theory and
real-world medical decision-making.

### Key Takeaways

1.  **Prevalence is crucial**: Test performance depends heavily on
    disease prevalence
2.  **Sequential testing is powerful**: Multiple tests can dramatically
    improve diagnostic accuracy\
3.  **Context matters**: Screening vs. diagnostic contexts require
    different interpretation
4.  **Clinical judgment remains essential**: Tests inform but don’t
    replace clinical reasoning

### Next Steps

- Explore the example datasets for your specialty
- Practice with realistic clinical scenarios
- Use Fagan nomograms for visual probability assessment
- Incorporate Bayesian thinking into your clinical practice

### Further Reading

- Bayes’ theorem in medical diagnosis
- Diagnostic test evaluation methodology\
- Clinical decision-making under uncertainty
- Evidence-based medicine principles
