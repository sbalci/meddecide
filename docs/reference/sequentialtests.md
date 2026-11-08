# Sequential Testing Analysis

Analyzes how diagnostic accuracy changes when applying two tests in
sequence, comparing three different testing strategies: serial positive
(confirmation), serial negative (exclusion), and parallel testing.
Provides comprehensive analysis including population flow, cost
implications, and diagnostic plots, so you can explore how diagnostic
strategies behave under explicit assumptions, compare hypothetical test
sequences, weigh trade-offs between sensitivity and specificity, and
illustrate expected testing volume and cost under user-supplied
assumptions. The named scenarios and their values are teaching examples
only, not clinical guidance or validated diagnostic pathways. Replace
all example parameters with estimates applicable to the intended
population before interpreting results.

## Usage

``` r
sequentialtests(
  preset = "custom",
  test1_name = "Screening Test",
  test1_sens = 0.95,
  test1_spec = 0.7,
  test1_cost = 0,
  test2_name = "Confirmatory Test",
  test2_sens = 0.8,
  test2_spec = 0.98,
  test2_cost = 0,
  strategy = "serial_positive",
  prevalence = 0.1,
  population_size = 1000,
  show_explanation = FALSE,
  show_formulas = FALSE,
  show_cost_analysis = FALSE,
  show_plots = FALSE
)
```

## Arguments

- preset:

  Select a teaching example or use custom values. Examples load rounded,
  hypothetical parameters chosen only to demonstrate how each strategy
  behaves. They are not clinical guidance, validated diagnostic
  pathways, or estimates from a specific study, and their prevalence
  will not match your population. Replace every value with estimates
  from the intended setting before interpretation.

- test1_name:

  Display name for the first test.

- test1_sens:

  Assumed sensitivity of the first test, entered as a proportion from
  0.01 to 0.99.

- test1_spec:

  Assumed specificity of the first test, entered as a proportion from
  0.01 to 0.99.

- test1_cost:

  Assumed unit cost of the first test in user-defined currency or cost
  units.

- test2_name:

  Display name for the second test.

- test2_sens:

  Assumed sensitivity of the second test, entered as a proportion from
  0.01 to 0.99.

- test2_spec:

  Assumed specificity of the second test, entered as a proportion from
  0.01 to 0.99.

- test2_cost:

  Assumed unit cost of the second test in user-defined currency or cost
  units.

- strategy:

  Rule for combining results: test first-test positives, test first-test
  negatives, or apply both tests to everyone. Combined accuracy assumes
  conditional independence between tests.

- prevalence:

  Assumed pre-test disease probability, entered as a proportion from
  0.001 to 0.999.

- population_size:

  Population size used to illustrate population flow counts. Does not
  affect probabilities.

- show_explanation:

  Show a plain-language summary and explanation of the selected
  strategy.

- show_formulas:

  Show the formulas used for individual and combined test metrics.

- show_cost_analysis:

  Show expected testing volume and cost using the illustrative
  population size.

- show_plots:

  Show the five diagnostic-performance and population-flow plots.

## Value

A results object containing:

|                                     |     |     |     |     |                |
|-------------------------------------|-----|-----|-----|-----|----------------|
| `results$notices`                   |     |     |     |     | a preformatted |
| `results$plain_summary`             |     |     |     |     | a html         |
| `results$summary_table`             |     |     |     |     | a table        |
| `results$individual_tests_table`    |     |     |     |     | a table        |
| `results$population_flow_table`     |     |     |     |     | a table        |
| `results$cost_analysis_table`       |     |     |     |     | a table        |
| `results$explanation_text`          |     |     |     |     | a html         |
| `results$formulas_text`             |     |     |     |     | a html         |
| `results$plot_flow_diagram`         |     |     |     |     | an image       |
| `results$plot_performance`          |     |     |     |     | an image       |
| `results$plot_probability`          |     |     |     |     | an image       |
| `results$plot_population_flow`      |     |     |     |     | an image       |
| `results$plot_sensitivity_analysis` |     |     |     |     | an image       |
| `results$clinical_guidance`         |     |     |     |     | a html         |

Tables can be converted to data frames with `asDF` or
[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html). For
example:

`results$summary_table$asDF`

`as.data.frame(results$summary_table)`

## Examples

``` r
if (FALSE) { # \dontrun{
# No data: every input is an assumed parameter, not an estimate.
sequentialtests(
    test1_sens = 0.95, test1_spec = 0.70,
    test2_sens = 0.80, test2_spec = 0.98,
    prevalence = 0.10, strategy = "serial_positive",
    show_cost_analysis = TRUE, test1_cost = 10, test2_cost = 150)
} # }
```
