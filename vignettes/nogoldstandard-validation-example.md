# Three imperfect diagnostic tests without a gold standard

The jamovi Data Library entry **Three Imperfect Tests Without a Gold Standard** opens
[`nogoldstandard_validation.omv`](../data/nogoldstandard_validation.omv). This simulated
teaching example replaces the pathologist-reading example. Its purpose is to demonstrate
estimation from several imperfect diagnostic tests when no observed test is accepted as
an error-free reference. Use the agreement examples for reader reproducibility.

## Data and provenance

The file contains 190 simulated patients and five columns:

| Column | Role |
| --- | --- |
| `patient_id` | Unique patient identifier; one independent row per patient |
| `New_Test` | Binary test being evaluated |
| `Reference1` | First additional imperfect test |
| `Reference2` | Second additional imperfect test |
| `test_site` | Simulated site label; not used as a grouping variable or predictor |

Each test is coded `Negative` / `Positive`. All 190 patients have all three test results.
Despite their names, `Reference1` and `Reference2` are not gold standards.

Source: `ClinicoPathJamoviModule/data-raw/nogoldstandard_test_data.R`, section 13,
“Diagnostic Validation Data” (script seed 42). The generator draws a latent disease
indicator with probability 0.32, then generates the three test results independently
conditional on that indicator. Its generating sensitivities are 0.88, 0.85 and 0.82,
and specificities are 0.90, 0.88 and 0.92. These are simulation inputs, not measured
clinical performance, and they are not supplied to the fitted model. The latent truth
is not included in the five-column dataset. The analysis seed 42 below controls fitting
and resampling; it does not regenerate the original data.

The raw data-only input is
`ClinicoPathJamoviModule/data-raw/non-rda/nogoldstandard_validation.omv`.
The configured teaching document is owned by `meddecide/data/` and was prepared and
saved through the jamovi desktop GUI. Keep the configured document when updating modules;
do not replace it with the raw file.

## Saved GUI configuration

Open **meddecide → Decision → Analysis Without Gold Standard** to recreate the analysis:

| Control | Value |
| --- | --- |
| Test 1 / positive level | `New_Test` / `Positive` |
| Test 2 / positive level | `Reference1` / `Positive` |
| Test 3 / positive level | `Reference2` / `Positive` |
| Test 4 and Test 5 | Unassigned |
| Analysis method | Latent Class Analysis |
| Bootstrap CI / samples | On / 1,000 |
| Alpha | 0.05 (95% intervals) |
| Random seed | 42 |
| Analysis diagnostics | On |
| Plain-language summary | On |
| Illustrative scenario | No example |
| Method guide | Off |

The saved document includes an introductory teaching annotation, populated tables,
bootstrap intervals, diagnostics and the test agreement matrix.

## Reading the results

The saved analysis estimates a high-positive class proportion of approximately **34.5%**,
with a percentile-bootstrap interval of approximately **27.0% to 42.8%**. This is a fitted
latent-class proportion, not an observed disease prevalence. The generating prevalence
of 32% is a population simulation setting, so it need not equal the fitted proportion
or the unobserved realized sample proportion.

The response probabilities describe each selected-positive result in the high-positive
class and each negative result in the other class. Interpreting those quantities as
clinical sensitivity and specificity requires a substantive justification for treating
the high-positive class as disease. Predictive values also depend on the fitted class
proportion in this dataset.

Three binary tests give zero nominal residual degrees of freedom for a two-class
conditional-independence model. Small fit discrepancies and small bivariate residuals
therefore cannot establish conditional independence. In real studies, shared biological
targets, specimens or other mechanisms can make tests conditionally dependent. The
simulation assumption does not establish independence in a clinical application.

The intervals resample independent patient rows and refit the model. Their coverage is
approximate and can be poor near parameter boundaries or under weak identification.
The pairwise kappa table describes concordance between tests; it does not supply a
reference standard or independently validate their diagnostic accuracy.

The word `validation` in the filename denotes the simulated study scenario. This example
is not evidence of clinical validation, method-wide validation or release clearance.

## Reproduce the analysis in R

Install `jmvReadWrite` to read the bundled document, then run this code from the
meddecide repository root. All unused positive-level arguments are explicit because
the generated R wrapper requires them.

```r
d <- jmvReadWrite::read_omv("data/nogoldstandard_validation.omv")
result <- meddecide::nogoldstandard(
  data = d,
  test1 = "New_Test", test1Positive = "Positive",
  test2 = "Reference1", test2Positive = "Positive",
  test3 = "Reference2", test3Positive = "Positive",
  test4Positive = NULL, test5Positive = NULL,
  method = "latent_class",
  bootstrap = TRUE, nboot = 1000, alpha = 0.05,
  seed = 42, verbose = TRUE, showSummary = TRUE
)
```

## File checks

The document was saved in jamovi 28.13.0 with the installed `meddecide` analysis. Its ZIP
integrity, 190-row dataset, retained teaching annotation and stored analysis settings
were checked. Save/reopen verification and the final file hash are recorded with the
[example preparation report](../quality-reports/NOGOLDSTANDARD_VALIDATION_EXAMPLE_2026-10-23.md). These checks establish the example artifact's integrity;
they do not establish statistical coverage or clinical validity.
