# Hand-maintained (the module updater never writes or deletes this file): @importFrom tags to satisfy R CMD check
# 'Namespaces in Imports field not imported from' NOTE for pkg::-used packages.
# library-audit 2026-09-16 meddecide [LOW] DONE: a tag here never stands in for a use; ggraph, igraph and
#   Matrix (and glue, htmlTable) had no caller and left Imports with their tags
# library-audit 2026-09-16 meddecide [LOW] DONE: the five agreement tags below came back with
#   `agreement` (it was briefly menuGroup meddecideT). Removing a tag while an analysis is
#   parked in JamoviTest ships a module whose analysis cannot resolve its own calls.
#   `psych` has no tag on purpose: every psych:: in agreement.b.R is a comment or a
#   user-facing string saying the result agrees with psych::cohen.kappa, not a call.
#' @importFrom DescTools CCC
#' @importFrom glmnet cv.glmnet
#' @importFrom graphics par
#' @importFrom grDevices colorRampPalette
#' @importFrom grid arrow
#' @importFrom irrCAC gwet.ac1.raw
#' @importFrom kappaSize PowerBinary
#' @importFrom knitr kable
#' @importFrom lme4 lmer
#' @importFrom lmerTest as_lmerModLmerTest
#' @importFrom poLCA poLCA
#' @importFrom tibble rownames_to_column
#' @importFrom tools toTitleCase
#' @importFrom vcd Kappa
#' @importFrom withr local_seed
NULL
