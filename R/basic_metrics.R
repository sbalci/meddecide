#' Calculate diagnostic sensitivity
#'
#' @param tp Number of true positives
#' @param fn Number of false negatives
#'
#' @return Sensitivity as a proportion
#' @export
calculate_sensitivity <- function(tp, fn) {
  if (tp < 0 || fn < 0) {
    stop("Counts must be non-negative")
  }
  if (tp + fn == 0) {
    return(0)
  }
  tp / (tp + fn)
}

#' Calculate diagnostic specificity
#'
#' @param tn Number of true negatives
#' @param fp Number of false positives
#'
#' @return Specificity as a proportion
#' @export
calculate_specificity <- function(tn, fp) {
  if (tn < 0 || fp < 0) {
    stop("Counts must be non-negative")
  }
  if (tn + fp == 0) {
    return(0)
  }
  tn / (tn + fp)
}

#' Calculate AUC from sensitivity and specificity
#'
#' @param sens Sensitivity of the test
#' @param spec Specificity of the test
#'
#' @return Area under the ROC curve
#' @export
calculate_auc <- function(sens, spec) {
  (sens + spec) / 2
}
