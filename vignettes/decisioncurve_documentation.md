# Decision Curve Analysis Documentation

> **Not yet released in meddecide.** This article documents `decisioncurve`, which is not part of the
> meddecide 1.0.4 release. It is documented here ahead of a future release, so the
> options, defaults and output described below are subject to change and the analysis
> will not appear in your jamovi menu yet. For the analyses that ship today see the
> [meddecide articles index](https://www.serdarbalci.com/meddecide/articles/).

This document provides a comprehensive overview of the Decision Curve Analysis module (decisioncurve), detailing its features, user interface elements, and the underlying R functions.

## Feature Summary

The decisioncurve module is a specialized tool for evaluating the clinical utility of diagnostic or prognostic models using Decision Curve Analysis (DCA). DCA quantifies the net benefit of a model across a range of threshold probabilities, allowing for a direct comparison of different models or strategies based on patient outcomes.

The module's features can be broadly categorized as follows:

*   **Core DCA Calculation:** Compute net benefit and interventions avoided across a range of threshold probabilities.
*   **Model Comparison:** Compare the clinical utility of multiple models against each other and against default strategies (e.g., treat all, treat none).
*   **Visualization:** Generate decision curves to graphically represent net benefit.
*   **Threshold Customization:** Define specific threshold probabilities for analysis.
*   **Export Options:** Capabilities to save DCA results and plots in various formats.

## Feature Details

The following table provides a detailed mapping of the module's features, from the user interface to the underlying R functions.

| Feature                          | YAML Argument (`.a.yaml`)      | UI Label                               | Results Section (`.r.yaml`)         | R Function (`.b.R`)                  |
| -------------------------------- | ------------------------------ | -------------------------------------- | ----------------------------------- | ------------------------------------ |
| **Core Analysis**                |                                |                                        |                                     |                                      |
| Outcome Variable                 | `outcomeVar`                   | Outcome Variable                       | `dcaOverview`                       | `.calculateDCA`                      |
| Predictor Variables              | `predictorVars`                | Predictor Variables                    | `dcaOverview`                       | `.calculateDCA`                      |
| Outcome Event Level              | `outcomeEventLevel`            | Outcome Event Level                    | `dcaOverview`                       | `.calculateDCA`                      |
| Threshold Probabilities          | `thresholds`                   | Threshold Probabilities                | `dcaOverview`                       | `.calculateDCA`                      |
| **DCA Metrics**                  |                                |                                        |                                     |                                      |
| Show Net Benefit                 | `showNetBenefit`               | Show Net Benefit                       | `dcaResults`                        | `.calculateDCA`                      |
| Show Interventions Avoided       | `showInterventionsAvoided`     | Show Interventions Avoided             | `dcaResults`                        | `.calculateDCA`                      |
| **Visualizations**               |                                |                                        |                                     |                                      |
| Show Decision Curve Plot         | `showDecisionCurvePlot`        | Show Decision Curve Plot               | `dcaPlot`                           | `.plotDecisionCurve`                 |
| Add No Treatment Line            | `addNoTreatmentLine`           | Add No Treatment Line                  | `dcaPlot`                           | `.plotDecisionCurve`                 |
| Add Treat All Line               | `addTreatAllLine`              | Add Treat All Line                     | `dcaPlot`                           | `.plotDecisionCurve`                 |
| Plot Type                        | `plotType`                     | Plot Type                              | `dcaPlot`                           | `.plotDecisionCurve`                 |
| **Advanced Options**             |                                |                                        |                                     |                                      |
| Missing Data Handling            | `missingDataHandling`          | Missing Data Handling                  | `advancedOptions`                   | `.handleMissingData`                 |
| Export Results                   | `exportResults`                | Export Results                         | `exportOptions`                     | `.exportDCAResults`                  |
| Export Plot                      | `exportPlot`                   | Export Plot                            | `exportOptions`                     | `.exportDCAPlot`                     |