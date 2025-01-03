% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{bootstrap_roc_test}
\alias{bootstrap_roc_test}
\title{Compare ROC curves using bootstrap method}
\usage{
bootstrap_roc_test(test_data, n_bootstrap = 1000)
}
\arguments{
\item{test_data}{List of test results}

\item{n_bootstrap}{Number of bootstrap iterations}
}
\value{
A list containing bootstrap comparison results:
\item{overall}{Overall comparison results using Friedman test}
\item{pairwise}{Matrix of pairwise comparison p-values}
}
\description{
Compare ROC curves using bootstrap method
}
