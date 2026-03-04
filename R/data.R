# Dataset documentation for meddecide package

#' Histopathology example dataset
#'
#' Simulated histopathology data for medical decision analysis examples.
#' Contains diagnostic test results and gold standard classifications.
#'
#' @format A data frame with 250 rows and 38 columns.
#' @source Simulated data for package examples.
"histopathology"

#' Bayesian DCA test dataset
#'
#' Simulated data for Bayesian decision curve analysis examples.
#'
#' @format A data frame with 500 rows and 4 columns:
#' \describe{
#'   \item{outcome}{Binary outcome variable}
#'   \item{model_prediction}{Model predicted probability}
#'   \item{binary_test}{Binary test result}
#'   \item{weak_test}{Weak test result}
#' }
#' @source Simulated data for package examples.
"bayesdca_test_data"

#' Breast cancer diagnostic dataset
#'
#' Simulated breast cancer diagnostic test data with multiple imaging modalities.
#'
#' @format A data frame with 2000 rows and 10 columns.
#' @source Simulated data for package examples.
"breast_cancer_data"

#' Breast pathology diagnostic styles dataset
#'
#' Simulated breast pathology data with diagnostic style information.
#'
#' @format A list with diagnostic data, pathologist info, and case info.
#' @source Simulated data for package examples.
"breast_data"

#' Lymphoma diagnostic styles dataset
#'
#' Simulated lymphoma pathology data with diagnostic style information.
#'
#' @format A list with diagnostic data, pathologist info, and case info.
#' @source Simulated data for package examples.
"lymphoma_data"

#' Thyroid function test dataset
#'
#' Simulated thyroid function data for ROC analysis examples.
#'
#' @format A data frame with 500 rows and 9 columns.
#' @source Simulated data for package examples.
"thyroid_function_data"

#' Cancer diagnostic dataset
#'
#' Simulated cancer data with multiple biomarkers for ROC analysis.
#'
#' @format A data frame with 500 rows and 11 columns.
#' @source Simulated data for package examples.
"cancer_data"

#' Cardiac diagnostic dataset
#'
#' Simulated cardiac troponin data for diagnostic test evaluation.
#'
#' @format A data frame with 500 rows and 11 columns.
#' @source Simulated data for package examples.
"cardiac_data"

#' Master dataset collection
#'
#' A list containing multiple diagnostic datasets (cancer, cardiac, sepsis, thyroid).
#'
#' @format A list with 4 elements.
#' @source Simulated data for package examples.
"master_data"

#' Sepsis diagnostic dataset
#'
#' Simulated sepsis biomarker data for diagnostic test evaluation.
#'
#' @format A data frame with 500 rows and 10 columns.
#' @source Simulated data for package examples.
"sepsis_data"

#' Thyroid diagnostic dataset
#'
#' Simulated thyroid function data for diagnostic analysis.
#'
#' @format A data frame with 500 rows and 9 columns.
#' @source Simulated data for package examples.
"thyroid_data"
