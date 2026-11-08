#!/usr/bin/env Rscript
# Cross-analysis independent review (/independent-reviewer, consolidated-summary scope) of the
# meddecide 1.1.1 pre-release, 2026-10-21, commit 403e034.
#
# Scope: what a one-analysis pass cannot see. The same 2x2 (plus a zero-cell and a rare-prevalence
# variant) is fed to every diagnostic analysis that can express it - decision, decisioncalculator,
# decisioncompare, decisioncombine, enhancedROC and psychopdaROC (binary 0/1 marker) - and the
# printed quantities are compared with closed forms and with each other; the zero-cell rule of each
# analysis is tabulated; prior-adjusted PPV/NPV are compared across six analyses; the shared helpers
# in R/utils*.R are tested at their boundaries; enhancedROC and psychopdaROC are compared on one
# continuous marker; and the kappaSize planners are compared with the estimator agreement reports.
#
# Audit only. Loads the SHIPPED meddecide source and calls the public wrappers (E4); the helper
# contracts are tested directly because they are not wrappers. Every expected value is a closed
# form or literal arithmetic written in this file. Writes the matrix CSV and exits non-zero on FAIL.
#
#   Rscript --vanilla development-scripts/audit_meddecide_cross_2026-10-21.R   (twice; identical CSV)

suppressPackageStartupMessages(pkgload::load_all("/Users/serdarbalci/Documents/GitHub/meddecide",
                                                 quiet = TRUE, export_all = TRUE))
set.seed(20261021)
OUT <- "/private/tmp/meddecide-release-20261108/cross-analysis-matrix.csv"
Z <- stats::qnorm(0.975)

quiet <- function(expr) suppressWarnings(suppressMessages(force(expr)))
fmt   <- function(x) paste(base::format(x, digits = 10), collapse = ", ")   # jmvcore masks format
audit <- new.env(); audit$rows <- list()
add_row <- function(id, claim, analyses, grade, observed, expected, diff, tol, result, finding, note)
  audit$rows[[length(audit$rows) + 1L]] <- data.frame(
    id, claim, analyses, grade, observed, expected, max_abs_diff = diff, tol, result,
    finding, note, stringsAsFactors = FALSE)
check <- function(id, claim, analyses, observed, expected, tol = 1e-8, grade = "EXEC-IND",
                  finding = "", note = "") {
  if (length(observed) == 0) observed <- NA
  o <- suppressWarnings(as.numeric(unname(observed))); e <- as.numeric(unname(expected))
  ok <- length(o) == length(e) && all(is.na(o) == is.na(e)) &&
        all(abs(o[!is.na(o)] - e[!is.na(e)]) <= tol * pmax(abs(e[!is.na(e)]), 1))
  d <- if (length(o) == length(e)) suppressWarnings(max(abs(o - e), na.rm = TRUE)) else NA_real_
  if (!is.finite(d)) d <- NA_real_
  add_row(id, claim, analyses, grade, fmt(observed), fmt(expected), d, tol,
          if (isTRUE(ok)) "PASS" else "FAIL", finding, note)
  invisible(isTRUE(ok))
}
check_true <- function(id, claim, analyses, cond, grade = "EXEC-PROP", finding = "", note = "",
                       observed = NULL) {
  add_row(id, claim, analyses, grade, if (is.null(observed)) fmt(isTRUE(cond)) else observed,
          "TRUE", NA_real_, NA_real_, if (isTRUE(cond)) "PASS" else "FAIL", finding, note)
  invisible(isTRUE(cond))
}
info <- function(id, claim, analyses, observed, grade = "EXEC-PROP", finding = "", note = "")
  add_row(id, claim, analyses, grade, observed, "", NA_real_, NA_real_, "INFO", finding, note)
section <- function(x) cat("\n==== ", x, " ====\n", sep = "")

# ------------------------------------------------------------------------------------------------
# Closed-form oracles (written here, not taken from the analyses)
# ------------------------------------------------------------------------------------------------
cp  <- function(x, n) c(if (x == 0) 0 else stats::qbeta(0.025, x, n - x + 1),
                        if (x == n) 1 else stats::qbeta(0.975, x + 1, n - x))      # Clopper-Pearson
wil <- function(x, n) { p <- x / n; den <- 1 + Z^2 / n
  ctr <- (p + Z^2 / (2 * n)) / den; hw <- Z * sqrt(p * (1 - p) / n + Z^2 / (4 * n^2)) / den
  c(max(0, ctr - hw), min(1, ctr + hw)) }                                           # Wilson 1927
katz <- function(a, n1, b, n0) { r <- (a / n1) / (b / n0)
  se <- sqrt(1 / a - 1 / n1 + 1 / b - 1 / n0); c(r, r * exp(-Z * se), r * exp(Z * se)) }  # Simel 1991
woolf <- function(a, b, c, d) { o <- a * d / (b * c); se <- sqrt(1 / a + 1 / b + 1 / c + 1 / d)
  c(o, o * exp(-Z * se), o * exp(Z * se)) }
agresti_caffo <- function(tp, n1, fp, n0) { p1 <- (tp + 1) / (n1 + 2); p2 <- (fp + 1) / (n0 + 2)
  s <- sqrt(p1 * (1 - p1) / (n1 + 2) + p2 * (1 - p2) / (n0 + 2)); (p1 - p2) + c(-1, 1) * Z * s }
bayes <- function(se, sp, p) c(ppv = se * p / (se * p + (1 - sp) * (1 - p)),
                               npv = sp * (1 - p) / (sp * (1 - p) + (1 - se) * p))
truth <- function(TP, FP, FN, TN) { n1 <- TP + FN; n0 <- FP + TN
  list(se = TP / n1, sp = TN / n0, ppv = TP / (TP + FP), npv = TN / (TN + FN),
       acc = (TP + TN) / (n1 + n0), lrp = (TP / n1) / (FP / n0), lrn = (FN / n1) / (TN / n0),
       dor = TP * TN / (FP * FN), youden = TP / n1 + TN / n0 - 1, n1 = n1, n0 = n0) }

# ------------------------------------------------------------------------------------------------
# Fixtures. One row per patient. t = the index test, g = reference, t2 = a second complete test
# (needed by decisioncompare and decisioncombine), m = t as a 0/1 marker for the ROC analyses.
# ------------------------------------------------------------------------------------------------
mk <- function(TP, FP, FN, TN) {
  g <- c(rep("dis", TP), rep("non", FP), rep("dis", FN), rep("non", TN))
  t <- c(rep("pos", TP + FP), rep("neg", FN + TN))
  # t2: positive on every other diseased row and on every 10th non-diseased row (never perfect).
  idx <- stats::ave(seq_along(g), g, FUN = seq_along)
  t2 <- ifelse(g == "dis", ifelse(idx %% 2 == 1, "pos", "neg"), ifelse(idx %% 10 == 0, "pos", "neg"))
  data.frame(t = factor(t, levels = c("pos", "neg")), g = factor(g, levels = c("dis", "non")),
             t2 = factor(t2, levels = c("pos", "neg")), m = as.numeric(t == "pos"),
             y = factor(g, levels = c("dis", "non")))
}
FX <- list(A = c(TP = 40, FP = 15, FN = 10, TN = 135),   # prevalence 0.25
           R = c(TP = 8, FP = 50, FN = 2, TN = 940),     # rare: prevalence 0.01
           Z1 = c(TP = 0, FP = 1, FN = 10, TN = 99),      # never-positive in the diseased
           Z2 = c(TP = 20, FP = 5, FN = 0, TN = 75))      # FN = 0

# ------------------------------------------------------------------------------------------------
# Wrappers and extractors (public wrappers; Level options passed, NULL when unset)
# ------------------------------------------------------------------------------------------------
rk <- function(df, key) { k <- gsub('^"|"$', "", rownames(df)); df[k == key, , drop = FALSE] }
dec  <- function(d, ...) quiet(meddecide::decision(data = d, gold = "g", goldPositive = "dis",
          newtest = "t", testPositive = "pos", goldNegative = "non", testNegative = "neg", ...))
calc <- function(f, ...) quiet(meddecide::decisioncalculator(TP = f[["TP"]], FP = f[["FP"]],
          FN = f[["FN"]], TN = f[["TN"]], ...))
cmp  <- function(d, ...) quiet(meddecide::decisioncompare(data = d, gold = "g", goldPositive = "dis",
          goldNegative = "non", test1 = "t", test1Positive = "pos", test1Negative = "neg",
          test2 = "t2", test2Positive = "pos", test2Negative = "neg", test3 = NULL,
          test3Positive = NULL, test3Negative = NULL, stratify = NULL, ...))
comb <- function(d, ...) quiet(meddecide::decisioncombine(data = d, gold = "g", goldPositive = "dis",
          test1 = "t", test1Positive = "pos", test2 = "t2", test2Positive = "pos",
          test3Positive = NULL, ...))
# do.call with evaluated values: the wrappers resolve variable arguments by NSE.
eroc <- function(d, ...) quiet(do.call(meddecide::enhancedROC, c(list(data = d, outcome = "y",
          positiveClass = "dis", validationNegative = NULL, predictors = "m"), list(...))))
proc <- function(d, ...) quiet(do.call(meddecide::psychopdaROC, c(list(data = d, dependentVars = "m",
          classVar = "y", positiveClass = "dis", negativeClass = "non", subGroup = NULL,
          patientID = NULL, refVar = NULL, run = TRUE), list(...))))

ex_dec <- function(r) { a <- r$ratioTable$asDF; n <- r$epirTable_number$asDF; q <- r$epirTable_ratio$asDF
  list(se = a$Sens, sp = a$Spec, acc = a$AccurT, ppv = a$PPV, npv = a$NPV, lrp = a$LRP, lrn = a$LRN,
       dor = rk(n, "diag.or")$est, youden = rk(n, "youden")$est,
       se_ci = unlist(rk(q, "se")[, c("lower", "upper")]), sp_ci = unlist(rk(q, "sp")[, c("lower", "upper")]),
       ppv_ci = unlist(rk(q, "pv.pos")[, c("lower", "upper")]), npv_ci = unlist(rk(q, "pv.neg")[, c("lower", "upper")]),
       lrp_ci = unlist(rk(n, "lr.pos")[, c("lower", "upper")]), lrn_ci = unlist(rk(n, "lr.neg")[, c("lower", "upper")]),
       dor_ci = unlist(rk(n, "diag.or")[, c("lower", "upper")]), youden_ci = unlist(rk(n, "youden")[, c("lower", "upper")])) }
ex_calc <- function(r) { a <- r$ratioTable$asDF; n <- r$epirTable_number$asDF; q <- r$epirTable_ratio$asDF
  list(se = a$Sens, sp = a$Spec, acc = a$AccurT, ppv = a$PPV, npv = a$NPV, lrp = a$LRP, lrn = a$LRN,
       dor = r$advancedMetricsTable$asDF$dor, youden = r$advancedMetricsTable$asDF$youdenIndex,
       se_ci = unlist(rk(q, "se")[, c("lower", "upper")]), sp_ci = unlist(rk(q, "sp")[, c("lower", "upper")]),
       acc_ci = unlist(rk(q, "diag.ac")[, c("lower", "upper")]),
       lrp_ci = unlist(rk(n, "lr.pos")[, c("lower", "upper")]), lrn_ci = unlist(rk(n, "lr.neg")[, c("lower", "upper")]),
       dor_ci = unlist(rk(n, "diag.or")[, c("lower", "upper")]), youden_ci = unlist(rk(n, "youden")[, c("lower", "upper")])) }
ex_cmp <- function(r) { a <- rk(r$comparisonTable$asDF, "test_1"); q <- r$epirTable1$asDF
  out <- list(se = a$Sens, sp = a$Spec, acc = a$AccurT, ppv = a$PPV, npv = a$NPV, lrp = a$LRP, lrn = a$LRN)
  if (nrow(q) && !all(is.na(q$est))) out <- c(out, list(
    se_ci = unlist(rk(q, "se")[, c("lower", "upper")]), sp_ci = unlist(rk(q, "sp")[, c("lower", "upper")]),
    ppv_ci = unlist(rk(q, "pv.pos")[, c("lower", "upper")]), npv_ci = unlist(rk(q, "pv.neg")[, c("lower", "upper")]),
    acc_ci = unlist(rk(q, "diag.ac")[, c("lower", "upper")])))
  out }
ex_comb <- function(r) { a <- rk(r$combinationTable$asDF, "Test 1 alone"); q <- r$combinationTableCI$asDF
  w <- r$combinationTableCIRatios$asDF
  ci <- function(s) unlist(rk(q, paste0("Test 1 alone_", s))[, c("lower", "upper")])
  cr <- function(s) unlist(rk(w, paste0("Test 1 alone_", s))[, c("lower", "upper")])
  list(se = a$sens, sp = a$spec, acc = a$acc, ppv = a$ppv, npv = a$npv, lrp = a$lrPos, lrn = a$lrNeg,
       dor = a$dor, youden = a$youden, youden_ci = c(a$youdenLower, a$youdenUpper),
       se_ci = ci("sens"), sp_ci = ci("spec"), ppv_ci = ci("ppv"), npv_ci = ci("npv"), acc_ci = ci("acc"),
       lrp_ci = cr("lrPos"), lrn_ci = cr("lrNeg"), dor_ci = cr("dor"), tp = a$tp, fp = a$fp, fn = a$fn, tn = a$tn) }
ex_eroc <- function(r) { o <- r$results$optimalCutoffSummary$asDF; dp <- r$results$diagnosticPerformance$asDF
  cm <- r$results$clinicalApplicationMetrics$asDF
  num <- function(s) as.numeric(strsplit(gsub("[() ]", "", s), ",")[[1]])
  list(se = o$sensitivity, sp = o$specificity, acc = o$accuracy, youden = o$youden_index,
       cut = o$optimal_cutoff, auc = r$results$aucSummary$asDF$auc,
       auc_ci = c(r$results$aucSummary$asDF$auc_lower, r$results$aucSummary$asDF$auc_upper),
       auc_se = r$results$aucSummary$asDF$std_error,
       se_ci_text = dp$sensitivity_ci, sp_ci_text = dp$specificity_ci,
       se_ci = num(dp$sensitivity_ci), sp_ci = num(dp$specificity_ci),
       ppv = if (nrow(cm)) cm$ppv else NA, npv = if (nrow(cm)) cm$npv else NA,
       lrp = if (nrow(cm)) cm$lr_positive else NA, lrn = if (nrow(cm)) cm$lr_negative else NA,
       dor = if (nrow(cm)) cm$diagnostic_odds_ratio else NA) }
ex_proc <- function(r) { a <- r$resultsTable$items[[1]]$asDF; s <- r$aucSummaryTable$asDF
  list(se = a$sensitivity, sp = a$specificity, ppv = a$ppv, npv = a$npv, youden = a$youden,
       cut = a$cutpoint, auc = s$auc, auc_ci = c(s$ci_lower, s$ci_upper)) }

# Every user-visible string of a results tree: table notes, Html content, Preformatted text.
alltext <- function(item) {
  out <- character()
  walk <- function(x) {
    if (inherits(x, "Table")) {
      if (isTRUE(x$visible)) for (n in x$notes) out <<- c(out, tryCatch(n$note, error = function(e) ""))
    } else if (inherits(x, "Html") || inherits(x, "Preformatted")) {
      if (isTRUE(x$visible)) out <<- c(out, tryCatch(as.character(x$content), error = function(e) ""))
    } else if (inherits(x, "Group") || inherits(x, "Array")) for (i in x$items) walk(i)
  }
  walk(item)
  s <- paste(out, collapse = " ")
  s <- gsub("</?[A-Za-z][^<>]*>", " ", s)   # real tags only: "<=" in a sentence is text
  for (p in list(c("&lt;", "<"), c("&gt;", ">"), c("&quot;", "\""), c("&#x27;", "'"), c("&#x2F;", "/"), c("&amp;", "&")))
    s <- gsub(p[1], p[2], s, fixed = TRUE)
  gsub("\\s+", " ", s)
}

# ================================================================================================
section("X1. One 2x2, six analyses: point estimates against closed forms")
# ================================================================================================
RES <- list()
for (fx in c("A", "R")) {
  f <- FX[[fx]]; d <- mk(f[["TP"]], f[["FP"]], f[["FN"]], f[["TN"]]); tr <- truth(f[["TP"]], f[["FP"]], f[["FN"]], f[["TN"]])
  got <- list(
    decision = ex_dec(dec(d, ci = TRUE)),
    decisioncalculator = ex_calc(calc(f, ci = TRUE)),
    decisioncompare = ex_cmp(cmp(d, ci = TRUE)),
    decisioncombine = ex_comb(comb(d)),
    enhancedROC = ex_eroc(eroc(d, clinicalMetrics = TRUE)),
    psychopdaROC = ex_proc(proc(d)))
  RES[[fx]] <- got
  for (an in names(got)) for (q in c("se", "sp", "acc", "ppv", "npv", "lrp", "lrn", "dor", "youden")) {
    v <- got[[an]][[q]]
    if (is.null(v) || (length(v) == 1 && is.na(v))) next
    check(paste0("X1-", fx, "-", an, "-", q), paste0(q, " equals the closed form on fixture ", fx),
          an, v, tr[[q]])
  }
  # ROC analyses with a 0/1 marker: AUC = (Se + Sp) / 2, cut-point classifies exactly like the test
  check(paste0("X1-", fx, "-auc"), "binary-marker AUC = (Se + Sp)/2 in both ROC analyses",
        "enhancedROC, psychopdaROC", c(got$enhancedROC$auc, got$psychopdaROC$auc),
        rep((tr$se + tr$sp) / 2, 2))
  check_true(paste0("X1-", fx, "-cut"), "both ROC cut-points classify marker=1 positive and marker=0 negative",
             "enhancedROC, psychopdaROC",
             got$enhancedROC$cut > 0 && got$enhancedROC$cut <= 1 && got$psychopdaROC$cut > 0 && got$psychopdaROC$cut <= 1,
             observed = paste0("enhancedROC ", got$enhancedROC$cut, " ; psychopdaROC ", got$psychopdaROC$cut),
             note = "Different cut conventions (midpoint vs observed value), same classification rule (>=).")
}

# ================================================================================================
section("X2. Every printed interval: method, value, label")
# ================================================================================================
f <- FX$A; tr <- truth(f[["TP"]], f[["FP"]], f[["FN"]], f[["TN"]]); g <- RES$A
CPse <- cp(40, 50); CPsp <- cp(135, 150); CPppv <- cp(40, 55); CPnpv <- cp(135, 145); CPacc <- cp(175, 200)
for (an in c("decision", "decisioncalculator", "decisioncompare")) {
  check(paste0("X2-", an, "-se_ci"), "Se CI is Clopper-Pearson", an, g[[an]]$se_ci, CPse, 1e-6)
  check(paste0("X2-", an, "-sp_ci"), "Sp CI is Clopper-Pearson", an, g[[an]]$sp_ci, CPsp, 1e-6)
}
for (an in c("decision", "decisioncompare")) {
  check(paste0("X2-", an, "-ppv_ci"), "PPV CI (sample prevalence) is Clopper-Pearson", an, g[[an]]$ppv_ci, CPppv, 1e-6)
  check(paste0("X2-", an, "-npv_ci"), "NPV CI (sample prevalence) is Clopper-Pearson", an, g[[an]]$npv_ci, CPnpv, 1e-6)
}
check("X2-decisioncalculator-acc_ci", "accuracy CI is Clopper-Pearson", "decisioncalculator", g$decisioncalculator$acc_ci, CPacc, 1e-6)
check("X2-decisioncompare-acc_ci", "accuracy CI is Clopper-Pearson", "decisioncompare", g$decisioncompare$acc_ci, CPacc, 1e-6)
for (q in list(c("se_ci", 40, 50), c("sp_ci", 135, 150), c("ppv_ci", 40, 55), c("npv_ci", 135, 145), c("acc_ci", 175, 200)))
  check(paste0("X2-decisioncombine-", q[1]), paste0(q[1], " is Wilson"), "decisioncombine",
        g$decisioncombine[[q[1]]], wil(as.numeric(q[2]), as.numeric(q[3])), 1e-6)
check("X2-enhancedROC-se_ci", "enhancedROC Se CI (text cell) is Clopper-Pearson rounded to 3 dp",
      "enhancedROC", g$enhancedROC$se_ci, round(CPse, 3), 1e-9)
k <- katz(40, 50, 15, 150); w <- woolf(40, 15, 10, 135); ac <- agresti_caffo(40, 50, 15, 150)
for (an in c("decision", "decisioncalculator", "decisioncombine")) {
  check(paste0("X2-", an, "-lrp_ci"), "LR+ CI is Simel/Katz log", an, g[[an]]$lrp_ci, k[2:3], 1e-6)
  check(paste0("X2-", an, "-lrn_ci"), "LR- CI is Simel/Katz log", an, g[[an]]$lrn_ci, katz(10, 50, 135, 150)[2:3], 1e-6)
  check(paste0("X2-", an, "-dor_ci"), "DOR CI is Woolf log", an, g[[an]]$dor_ci, w[2:3], 1e-6)
  check(paste0("X2-", an, "-youden_ci"), "Youden CI is Agresti-Caffo", an, g[[an]]$youden_ci, ac, 1e-6)
}
# Same 40/50 sensitivity, two methods: does the Wilson table say so in the output a user sees?
rB <- comb(mk(40, 15, 10, 135))
ciNotes <- paste(vapply(rB$combinationTableCI$notes, function(n) n$note, ""), collapse = " ")
info("X2-diff-se", "Se 40/50: decision/decisioncalculator/decisioncompare/enhancedROC print Clopper-Pearson, decisioncombine prints Wilson",
     "decision, decisioncombine", paste0("CP ", fmt(round(CPse, 4)), " ; Wilson ", fmt(round(wil(40, 50), 4))))
check_true("X2-comb-label", "decisioncombine's 'Proportions with 95% Confidence Intervals' table names its interval method in displayed output",
           "decisioncombine", grepl("Wilson", paste(rB$combinationTableCI$title, ciNotes), ignore.case = TRUE),
           finding = "XA-04", observed = paste0("title='", rB$combinationTableCI$title, "'; notes='", substr(ciNotes, 1, 80), "'"),
           note = "Method appears only in the .r.yaml description (not rendered) and in the Recommendation text.")
# AUC interval on the same marker: enhancedROC Wald-DeLong vs psychopdaROC logit-DeLong
set.seed(7)
xc <- round(c(stats::rnorm(60, 1.2), stats::rnorm(90, 0)), 1)
dcont <- data.frame(m = xc, y = factor(rep(c("dis", "non"), c(60, 90)), levels = c("dis", "non")))
cs <- xc[1:60]; ct <- xc[61:150]
psi <- outer(cs, ct, function(a, b) (a > b) + 0.5 * (a == b))
AUC <- mean(psi); V10 <- rowMeans(psi); V01 <- colMeans(psi)
SE <- sqrt(stats::var(V10) / 60 + stats::var(V01) / 90)                         # DeLong 1988
lg <- log(AUC / (1 - AUC)); lse <- SE / (AUC * (1 - AUC))
LOGIT_CI <- 1 / (1 + exp(-(lg + c(-1, 1) * Z * lse)))
rE <- eroc(dcont, detectImbalance = TRUE); rY <- proc(dcont, compareClassifiers = TRUE)
gE <- ex_eroc(rE); gY <- ex_proc(rY)
check("X2-roc-auc", "AUC equals the Mann-Whitney closed form in both ROC analyses", "enhancedROC, psychopdaROC",
      c(gE$auc, gY$auc), c(AUC, AUC))
check("X2-roc-se", "enhancedROC std. error equals the DeLong closed form", "enhancedROC", gE$auc_se, SE, 1e-6)
check("X2-roc-eCI", "enhancedROC AUC CI = AUC +/- z*SE (Wald on the AUC scale)", "enhancedROC", gE$auc_ci, AUC + c(-1, 1) * Z * SE, 1e-6)
check("X2-roc-yCI", "psychopdaROC AUC CI = logit-DeLong closed form", "psychopdaROC", gY$auc_ci, LOGIT_CI, 1e-6)
txtE <- alltext(rE$results)
check_true("X2-roc-eLabel", "enhancedROC default output names the AUC interval method (psychopdaROC does, for a different method)",
           "enhancedROC", grepl("DeLong", txtE, fixed = TRUE), finding = "XA-05",
           observed = paste0("'DeLong' in default enhancedROC text: ", grepl("DeLong", txtE, fixed = TRUE),
                             "; enhancedROC CI ", fmt(round(gE$auc_ci, 4)), " vs psychopdaROC ", fmt(round(gY$auc_ci, 4))),
           note = "ci_method note is stripped when showTableNotes = FALSE (enhancedROC.b.R:1378-1382, 2315).")
# Youden-optimal cut on the continuous marker: brute force over every observed threshold (>=)
th <- sort(unique(xc)); J <- vapply(th, function(c0) mean(cs >= c0) + mean(ct < c0) - 1, 0)
best <- th[J == max(J)]
check("X2-roc-J", "maximal Youden J equals the brute-force maximum in both ROC analyses", "enhancedROC, psychopdaROC",
      c(gE$youden, gY$youden), rep(max(J), 2))
check_true("X2-roc-cut", "both cut-points give the same classification as the brute-force optimum",
           "enhancedROC, psychopdaROC",
           length(best) == 1 && all(c(sum(xc >= gE$cut), sum(xc >= gY$cut)) == sum(xc >= best)),
           observed = paste0("enhancedROC ", gE$cut, "; psychopdaROC ", gY$cut, "; optimum >= ", fmt(best)))
# Direction = lower on the negated marker
dneg <- dcont; dneg$m <- -dneg$m
gEl <- ex_eroc(eroc(dneg, direction = "lower")); gYl <- ex_proc(proc(dneg, direction = "<="))
check("X2-roc-lower", "AUC is invariant to negating the marker when Direction is lowered (both analyses)",
      "enhancedROC, psychopdaROC", c(gEl$auc, gYl$auc), c(AUC, AUC))
# AUPRC: both use .dvAuprc; oracle = numerical integration of the count-interpolated PR curve
pr_oracle <- function(score, lab) {       # adaptive quadrature of precision along each segment
  thr <- sort(unique(score), decreasing = TRUE); P <- sum(lab)
  tp <- c(0, vapply(thr, function(t0) sum(score >= t0 & lab == 1), 0))
  fp <- c(0, vapply(thr, function(t0) sum(score >= t0 & lab == 0), 0))
  area <- 0
  for (i in 2:length(tp)) {
    dtp <- tp[i] - tp[i - 1]; dfp <- fp[i] - fp[i - 1]
    if (dtp == 0) next
    prec <- function(s) { a <- tp[i - 1] + s * dtp; b <- a + fp[i - 1] + s * dfp; ifelse(b > 0, a / b, dtp / (dtp + dfp)) }
    area <- area + dtp / P * stats::integrate(prec, 0, 1, rel.tol = 1e-12)$value
  }
  area }
AUPRC <- pr_oracle(xc, as.integer(dcont$y == "dis"))
check("X2-auprc", "AUC-PR equals numerical integration of the count-interpolated PR curve (both analyses)",
      "enhancedROC, psychopdaROC", c(rE$results$precisionRecallTable$asDF$auc_pr, rY$rocComparisonTable$asDF$auprc),
      c(AUPRC, AUPRC), 1e-6, grade = "EXEC-IND")

# ================================================================================================
section("X3. Zero cells: each analysis's rule, and what it prints")
# ================================================================================================
haldane <- function(TP, FP, FN, TN) { a <- TP + .5; b <- FP + .5; c <- FN + .5; d <- TN + .5
  c(lrp = (a / (a + c)) / (b / (b + d)), lrn = (c / (a + c)) / (d / (b + d)), dor = a * d / (b * c)) }
ZR <- list()
for (fx in c("Z1", "Z2")) {
  f <- FX[[fx]]; d <- mk(f[["TP"]], f[["FP"]], f[["FN"]], f[["TN"]]); h <- do.call(haldane, as.list(f))
  tr <- truth(f[["TP"]], f[["FP"]], f[["FN"]], f[["TN"]])
  got <- list(decision = ex_dec(dec(d, ci = TRUE)), decisioncalculator = ex_calc(calc(f, ci = TRUE)),
              decisioncompare = ex_cmp(cmp(d)), decisioncombine = ex_comb(comb(d)))
  ZR[[fx]] <- got
  check_true(paste0("X3-", fx, "-same2x2"), "decisioncombine 'Test 1 alone' row uses the full 2x2 (complete t2)",
             "decisioncombine", identical(as.numeric(c(got$decisioncombine$tp, got$decisioncombine$fp,
                                                       got$decisioncombine$fn, got$decisioncombine$tn)), as.numeric(f)))
  for (an in names(got)) {
    g1 <- got[[an]]
    info(paste0("X3-", fx, "-", an), paste0("printed LR+ / LR- / DOR on ", fx, " (TP,FP,FN,TN = ", paste(f, collapse = ","), ")"),
         an, paste0("LR+ ", fmt(g1$lrp), "; LR- ", fmt(g1$lrn), "; DOR ", fmt(if (is.null(g1$dor)) NA else g1$dor)))
  }
  if (fx == "Z1") {
    # MLE LR+ = 0 (Se = 0): any estimator shown must keep LR+ <= 1 (Se < 1 - Sp) or be blank.
    for (an in names(got))
      check_true(paste0("X3-Z1-", an, "-dir"), "Se = 0 < FPR = 1%: displayed LR+ keeps the direction (<= 1) or is blank",
                 an, is.na(got[[an]]$lrp) || got[[an]]$lrp <= 1, grade = "EXEC-IND", finding = "XA-01",
                 observed = paste0("LR+ ", fmt(got[[an]]$lrp), " (Haldane ", fmt(h[["lrp"]]), "; MLE 0)"))
    # updated 2026-10-21: XA-01 shared rule (.diagRatioRules) - empty numerator TP gives LR+ exactly 0 (MLE) in all four, not Haldane
    check("X3-Z1-equal", "the four analyses print the same LR+, exactly 0 for an empty numerator (one shared rule)",
          "decision, decisioncalculator, decisioncompare, decisioncombine",
          vapply(got, function(g1) g1$lrp, 0), rep(0, 4), grade = "EXEC-IND")
    check("X3-Z1-lrn", "LR- on Z1 is the raw value (10/10)/(99/100) in all four", "all four",
          vapply(got, function(g1) g1$lrn, 0), rep(tr$lrn, 4))
    for (an in c("decision", "decisioncalculator", "decisioncombine"))
      check_true(paste0("X3-Z1-", an, "-dor"), "Se = 0: displayed DOR keeps the direction (<= 1) or is blank",
                 an, is.na(got[[an]]$dor) || got[[an]]$dor <= 1, grade = "EXEC-IND", finding = "XA-01",
                 observed = paste0("DOR ", fmt(got[[an]]$dor), " (Haldane ", fmt(h[["dor"]]), "; MLE 0)"))
  } else {
    # updated 2026-10-21: XA-01 shared rule (.diagRatioRules) - empty numerator FN gives LR- exactly 0 in all four, not Haldane
    check("X3-Z2-lrn", "FN = 0: the four analyses print the same LR-, exactly 0 (empty numerator, uncorrected)",
          "all four", vapply(got, function(g1) g1$lrn, 0), rep(0, 4))
    check("X3-Z2-lrp", "FN = 0: LR+ is the raw value in all four", "all four",
          vapply(got, function(g1) g1$lrp, 0), rep(tr$lrp, 4))
  }
}

# ================================================================================================
section("X4. Prior-adjusted PPV/NPV at a user prevalence, and how the prior is printed")
# ================================================================================================
fA <- FX$A; dA <- mk(fA[["TP"]], fA[["FP"]], fA[["FN"]], fA[["TN"]])
for (p in c(0.01, 0.002, 0.0004)) {
  b <- bayes(0.8, 0.9, p)
  rD <- dec(dA, pp = TRUE, pprob = p); rC <- calc(fA, pp = TRUE, pprob = p); rP <- cmp(dA, pp = TRUE, pprob = p)
  rE <- eroc(dA, clinicalMetrics = TRUE, prevalence = p, useObservedPrevalence = FALSE)
  rY <- proc(dA, usePriorPrev = TRUE, priorPrev = p)
  obs <- rbind(decision = c(rD$ratioTable$asDF$PPV, rD$ratioTable$asDF$NPV),
               decisioncalculator = c(rC$ratioTable$asDF$PPV, rC$ratioTable$asDF$NPV),
               decisioncompare = unlist(rk(rP$comparisonTable$asDF, "test_1")[, c("PPV", "NPV")]),
               enhancedROC = c(rE$results$clinicalApplicationMetrics$asDF$ppv, rE$results$clinicalApplicationMetrics$asDF$npv),
               psychopdaROC = c(rY$resultsTable$items[[1]]$asDF$ppv, rY$resultsTable$items[[1]]$asDF$npv))
  for (an in rownames(obs))
    check(paste0("X4-", p, "-", an), paste0("PPV, NPV at prior ", p, " = Bayes closed form"), an, obs[an, ], b)
  if (p >= 0.001) {
    rS <- quiet(meddecide::sequentialtests(test1_sens = 0.8, test1_spec = 0.9, test2_sens = 0.94,
                                           test2_spec = 29 / 30, prevalence = p, strategy = "serial_positive"))
    rT <- quiet(meddecide::cotest(test1_sens = 0.8, test1_spec = 0.9, test2_sens = 0.94, test2_spec = 29 / 30,
                                  indep = TRUE, prevalence = p))
    check(paste0("X4-", p, "-sequentialtests-single"), "single-test PPV/NPV at the prior = Bayes", "sequentialtests",
          unlist(rk(rS$individual_tests_table$asDF, "test1")[, c("ppv", "npv")]), b)
    sC <- 0.8 * 0.94; spC <- 1 - 0.1 * (1 / 30)
    check(paste0("X4-", p, "-serial"), "serial (both +) PPV: sequentialtests combined = cotest Both+ = Bayes on Se1Se2, 1-(1-Sp1)(1-Sp2)",
          "sequentialtests, cotest", c(rS$summary_table$asDF$combined_ppv, rk(rT$cotestResultsTable$asDF, "both_pos")$postProb),
          rep(bayes(sC, spC, p)[["ppv"]], 2))
  } else {
    eS <- tryCatch({ quiet(meddecide::sequentialtests(prevalence = p)); "accepted" }, error = function(e) "refused")
    eT <- tryCatch({ quiet(meddecide::cotest(prevalence = p)); "accepted" }, error = function(e) "refused")
    check_true("X4-bounds", "cotest and sequentialtests accept a prior the other diagnostic analyses accept (0.0004)",
               "cotest, sequentialtests", eS == "accepted" && eT == "accepted", finding = "XA-08",
               observed = paste0("sequentialtests ", eS, ", cotest ", eT, "; decision/decisioncalculator/decisioncompare/enhancedROC/psychopdaROC accept"),
               note = "a.yaml min 0.001 vs 1e-9; decisioncalculator's own default prevalenceScenarios include 0.0001.")
  }
  if (p == 0.0004) {
    for (pair in list(list("decision", rD), list("decisioncalculator", rC), list("decisioncompare", rP),
                      list("enhancedROC", rE$results), list("psychopdaROC", rY))) {
      s <- alltext(pair[[2]])
      # Every number printed within 60 characters after "prior"/"prevalence": is any of them a zero?
      hits <- regmatches(s, gregexpr("(prior|prevalence)[^0-9]{0,60}?[0-9]+(\\.[0-9]+)?%?", s, ignore.case = TRUE))[[1]]
      vals <- suppressWarnings(as.numeric(sub(".*?([0-9]+(\\.[0-9]+)?)%?$", "\\1", hits)))
      bad <- hits[!is.na(vals) & vals == 0]
      check_true(paste0("X4-text-", pair[[1]]), "a prior of 0.0004 is never printed as zero (0.0% / 0.000)", pair[[1]],
                 length(bad) == 0, finding = if (length(bad)) "XA-03" else "",
                 observed = paste0(length(bad), " zero rendering(s)", if (length(bad)) paste0(": '", paste(unique(bad), collapse = "' | '"), "'") else
                   paste0("; prior printed as: ", paste(unique(regmatches(s, regexpr("(prior|prevalence)[^0-9]{0,60}?[0-9]+(\\.[0-9]+)?%?", s, ignore.case = TRUE))), collapse = " | "))))
    }
  }
}
# Fagan nomogram (shared nomogrammer, decision/decisioncalculator/cotest) prints the same prior properly
pN <- nomogrammer(Prevalence = 0.0004, Sens = 0.8, Spec = 0.9, Detail = TRUE)
labs <- unlist(lapply(pN$layers, function(l) if (is.data.frame(l$data) && "label" %in% names(l$data)) as.character(l$data$label)))
labs <- c(labs, unlist(lapply(pN$labels, as.character)))
info("X4-nomogram", "shared nomogrammer labels at prior 0.0004", "nomogrammer (decision, decisioncalculator, cotest)",
     paste(unique(grep("%", labs, value = TRUE)), collapse = " | "))

# ================================================================================================
section("X5. Shared helpers in R/utils*.R: contracts at the boundaries")
# ================================================================================================
# pairedProportionDifference (decisioncompare, decisioncombine)
newcombe10 <- function(a, b, c, d) {                              # independent re-derivation
  n <- a + b + c + d; p1 <- (a + b) / n; p2 <- (a + c) / n
  w <- function(x) { r <- sort(Re(polyroot(c(x^2, -(2 * x + Z^2 / n), 1 + Z^2 / n)))); r }  # Wilson as quadratic roots
  l1u1 <- w(p1); l2u2 <- w(p2)
  phi_num <- a * d - b * c; if (phi_num > 0) phi_num <- max(phi_num - n / 2, 0)
  den <- sqrt((a + b) * (c + d) * (a + c) * (b + d)); phi <- if (den == 0) 0 else phi_num / den
  dl <- sqrt((p1 - l1u1[1])^2 - 2 * phi * (p1 - l1u1[1]) * (l2u2[2] - p2) + (l2u2[2] - p2)^2)
  du <- sqrt((l1u1[2] - p1)^2 - 2 * phi * (l1u1[2] - p1) * (p2 - l2u2[1]) + (p2 - l2u2[1])^2)
  c(p1 - p2, max(-1, p1 - p2 - dl), min(1, p1 - p2 + du)) }
mkpair <- function(a, b, c, d) list(x = c(rep(1, a + b), rep(0, c + d)), y = c(rep(1, a), rep(0, b), rep(1, c), rep(0, d)))
for (tup in list(c(36, 12, 2, 0), c(10, 3, 7, 30), c(200, 100, 0, 200), c(0, 0, 0, 5))) {
  pr <- do.call(mkpair, as.list(tup)); o <- pairedProportionDifference(pr$x, pr$y)
  check(paste0("X5-ppd-", paste(tup, collapse = "_")), "pairedProportionDifference = Newcombe method 10 (root-form re-derivation)",
        "decisioncompare, decisioncombine", c(o$diff, o$lower, o$upper), do.call(newcombe10, as.list(tup)), 1e-9)
}
pr <- mkpair(10, 3, 7, 30)
o1 <- pairedProportionDifference(pr$x, pr$y); o2 <- pairedProportionDifference(pr$x == 1, pr$y == 1)
check("X5-ppd-logical", "logical and 0/1 input give the same interval", "decisioncompare, decisioncombine",
      c(o2$diff, o2$lower, o2$upper), c(o1$diff, o1$lower, o1$upper), 1e-12, grade = "EXEC-PROP")
check_true("X5-ppd-empty", "no complete pair returns NULL", "decisioncompare, decisioncombine",
           is.null(pairedProportionDifference(c(NA, 1), c(0, NA))))
pr2 <- list(x = c(pr$x, NA, 1), y = c(pr$y, 1, NA)); o3 <- pairedProportionDifference(pr2$x, pr2$y)
check("X5-ppd-na", "incomplete pairs are dropped (same result as without them)", "decisioncompare, decisioncombine",
      c(o3$diff, o3$lower, o3$upper, o3$n), c(o1$diff, o1$lower, o1$upper, o1$n), 1e-12, grade = "EXEC-PROP")
big <- mkpair(30000, 20000, 0, 50000); ob <- pairedProportionDifference(big$x, big$y)
check_true("X5-ppd-overflow", "margins of 1e5 do not overflow (finite interval)", "decisioncompare, decisioncombine",
           all(is.finite(c(ob$lower, ob$upper))))
# .diagHalfUp1 (decision, decisioncompare comparator report): ties at one decimal
ties <- c(100 * 3 / 80, 100 * 1 / 16, 100 * 167 / 2000, 100 * 7 / 40, 100 * 1 / 400, 100 * 29 / 200)
exp_half_up <- c(3.8, 6.3, 8.4, 17.5, 0.3, 14.5)                  # decimal half-up, by hand
check("X5-halfup", ".diagHalfUp1 rounds decimal ties up (3.75, 6.25, 8.35, 0.25 -> up)", "decision, decisioncompare",
      .diagHalfUp1(ties), exp_half_up, 1e-12, finding = "",
      note = paste0("sprintf('%.1f') on the same values: ", paste(sprintf("%.1f", ties), collapse = " ")))
# .rocOutcomeCoding (enhancedROC, psychopdaROC, lassologistic)
o <- .rocOutcomeCoding(c(0, 1, 1, NA)); check_true("X5-roc01", "numeric 0/1 outcome defaults positive to '1'", "enhancedROC, psychopdaROC, lassologistic",
  o$status == "default01" && o$positive == "1" && o$n_missing == 1)
o <- .rocOutcomeCoding(factor(c("a", "b", "", NA))); check_true("X5-rocblank", "'' is treated as missing, not a level", "enhancedROC, psychopdaROC, lassologistic",
  identical(o$levels, c("a", "b")) && o$n_missing == 2 && o$status == "unset")
o <- .rocOutcomeCoding(c("x", "y"), positive = "z"); check_true("X5-rocinvalid", "a positive level not in the data is 'invalid'", "enhancedROC, psychopdaROC, lassologistic", o$status == "invalid")
o <- .rocOutcomeCoding(c(1, 2, 2)); check_true("X5-roc12", "numeric 1/2 outcome never infers a positive level", "enhancedROC, psychopdaROC, lassologistic",
  o$status == "unset" && is.null(o$positive))
# kappaSizeGofCells (kappaSizeCI, kappaSizeFixedN, kappaSizePower, agreement)
for (cfg in list(list(2, 2, c(.2, .8)), list(2, 5, c(.05, .95)), list(3, 2, c(.5, .3, .2)), list(4, 4, c(.4, .3, .2, .1))))
  check(paste0("X5-gof-sum-", cfg[[1]], "-", cfg[[2]]), "GOF cell probabilities sum to 1", "kappaSize*, agreement",
        sum(kappaSizeGofCells(cfg[[1]], cfg[[2]], cfg[[3]], 0.6)), 1, 1e-12, grade = "EXEC-PROP")
cells <- kappaSizeGofCells(3, 2, c(.5, .3, .2), 0.6)
check("X5-gof-2r", "two raters: 'all agree on j' cell = p_j^2 + rho p_j (1 - p_j)", "kappaSize*, agreement",
      cells[-1], c(.5, .3, .2)^2 + 0.6 * c(.5, .3, .2) * (1 - c(.5, .3, .2)), 1e-12)
check("X5-gof-bin", "binary, 2 raters: cells = (q^2 + rho p q, 2 p q (1 - rho), p^2 + rho p q)", "kappaSize*, agreement",
      kappaSizeGofCells(2, 2, c(.2, .8), 0.6), c(.64 + .6 * .16, 2 * .16 * .4, .04 + .6 * .16), 1e-12)
check_true("X5-commas", "decimal-comma detector: '0,2, 0,8' TRUE; '0.2, 0.8' FALSE; '1.2, 0.8' FALSE", "kappaSize*",
           kappaSizePropsLookDecimalComma("0,2, 0,8") && !kappaSizePropsLookDecimalComma("0.2, 0.8") &&
           !kappaSizePropsLookDecimalComma("1.2, 0.8"))
# Syntax helpers: a hostile string must come back as ONE string literal
evil <- 'x", alpha = {cat("PWNED")}, b = "'
for (h in list(list(".sourcifyDiagnosticOption", .sourcifyDiagnosticOption, "decision, decisioncurve, agreement, lassologistic"),
               list("kappaSizeSourcifyOption", kappaSizeSourcifyOption, "kappaSizeCI, kappaSizeFixedN, kappaSizePower"))) {
  s <- h[[2]](list(name = "props", value = evil, default = "0.2, 0.8"))
  e <- tryCatch(parse(text = paste0("f(", s, ")"))[[1]], error = function(e) NULL)
  check_true(paste0("X5-src-", h[[1]]), "syntax export of a hostile string parses to one string argument equal to the input",
             h[[3]], !is.null(e) && length(e) == 2 && identical(e[[2]], evil) && identical(names(e)[2], "props"))
}
# .dvAuprc / .dvPR (enhancedROC, psychopdaROC) on tied scores
sc <- c(3, 3, 2, 2, 2, 1, 1, 0); lb <- c(1, 0, 1, 1, 0, 0, 1, 0)
check("X5-auprc-ties", ".dvAuprc = numerical integral of the count-interpolated curve (ties across classes)",
      "enhancedROC, psychopdaROC", .dvAuprc(sc, lb, 1), pr_oracle(sc, lb), 1e-6)
ap <- { thr <- sort(unique(sc), decreasing = TRUE); tp <- sapply(thr, function(t0) sum(sc >= t0 & lb == 1))
        nn <- sapply(thr, function(t0) sum(sc >= t0)); sum(diff(c(0, tp / sum(lb))) * tp / nn) }
check("X5-ap", ".dvPR average precision = sum over thresholds of (recall step) x precision", "enhancedROC, psychopdaROC",
      .dvPR(sc, lb, 1)$avg_precision, ap, 1e-12)
check("X5-auprc-const", "a constant marker has AUC-PR equal to the prevalence", "enhancedROC, psychopdaROC",
      .dvAuprc(rep(1, 8), lb, 1), mean(lb), 1e-12)
# .dvWorkload (decisioncalculator, enhancedROC)
wl <- .dvWorkload(0.8, 0.9, c(0, 0.0004, 1), 1000)
check("X5-workload", ".dvWorkload: PPV at 0.0004 = Bayes; absent stratum contributes 0", "decisioncalculator, enhancedROC",
      c(wl$ppv[2], wl$tp[1], wl$fp[3]), c(bayes(.8, .9, .0004)[["ppv"]], 0, 0), 1e-12)
# .readerResample (agreement): reproducible, degenerate statistics refused rather than invented
dd <- data.frame(v = c(1, 2, 3, 4, 5, 6))
r1 <- .readerResample(dd, function(z) c(m = mean(z$v)), samples = 50, seed = 3)
r2 <- .readerResample(dd, function(z) c(m = mean(z$v)), samples = 50, seed = 3)
rc <- .readerResample(dd, function(z) c(k = 1), samples = 50, seed = 3)
check_true("X5-resample", ".readerResample: same seed -> identical; constant statistic -> no interval", "agreement",
           identical(r1, r2) && is.na(rc$lower) && grepl("Constant", rc$status))
check_true("X5-resample-cl", ".readerResample refuses missing cluster IDs", "agreement",
           inherits(tryCatch(.readerResample(dd, function(z) c(m = mean(z$v)), clusters = c(1, 1, 2, NA, 3, 3), samples = 50),
                             error = function(e) e), "error"))
# .diagRejectInputErrors (decision, decisioncalculator, decisioncombine, enhancedROC)
check_true("X5-reject", ".diagRejectInputErrors: silent without an ERROR notice; rejects with the title otherwise",
           "decision, decisioncalculator, decisioncombine, enhancedROC",
           is.null(.diagRejectInputErrors(list(list(type = "WARNING", title = "w", content = "c")))) &&
           grepl("Bad level", tryCatch(.diagRejectInputErrors(list(list(type = "ERROR", title = "Bad level", content = "c"))),
                                       error = function(e) conditionMessage(e))))
# .diagComparatorBinary (decisioncompare): other levels never become negatives
b1 <- tryCatch(.diagComparatorBinary(factor(c("P", "N", "Eq")), "P", "N"), error = function(e) "refused")
b2 <- .diagComparatorBinary(factor(c("P", "N", "Eq")), "P", "N", exclude = TRUE)
check_true("X5-binary", ".diagComparatorBinary refuses an unselected level unless excluded, then sets it NA (never negative)",
           "decisioncompare", identical(b1, "refused") && identical(b2, c(TRUE, FALSE, NA)))

# ================================================================================================
section("X6. Kappa: what kappaSize plans vs what agreement estimates")
# ================================================================================================
nfrom <- function(r) as.numeric(sub(".*Required sample size: *([0-9]+).*", "\\1", gsub("<[^>]+>", " ", r$notices$content)))
for (cfg in list(list(2, "kappa", .4, .7), list(3, "fleiss", .4, .7), list(4, "fleiss", .5, .8))) {
  set.seed(1); m <- matrix(sample(c("a", "b"), 40 * cfg[[1]], TRUE), 40)
  da <- as.data.frame(lapply(seq_len(cfg[[1]]), function(j) factor(m[, j], levels = c("a", "b"))))
  names(da) <- paste0("r", seq_len(cfg[[1]]))
  ra <- quiet(meddecide::agreement(data = da, vars = names(da), agreementSampleSize = TRUE, ssMetric = cfg[[2]],
                                   ssNRaters = cfg[[1]], ssNCategories = 2, ssKappaNull = cfg[[3]], ssKappaAlt = cfg[[4]]))
  nA <- as.numeric(rk(ra$pairedAgreementGroup$agreementSampleSizeTable$asDF, "n_required")$value)
  nP <- nfrom(quiet(meddecide::kappaSizePower(outcome = "2", kappa0 = cfg[[3]], kappa1 = cfg[[4]],
                                             props = "0.5, 0.5", raters = as.character(cfg[[1]]))))
  check(paste0("X6-ssn-", cfg[[1]]), paste0("same design, same n: agreement's planner vs kappaSizePower (binary, ", cfg[[1]],
        " raters, kappa ", cfg[[3]], " vs ", cfg[[4]], ", props 0.5/0.5)"), "agreement, kappaSizePower", nA, nP, 0,
        grade = "EXEC-PROP", finding = "")
}
# Plan with kappaSizeCI, analyse with agreement (Cohen's kappa, Wald non-null SE), under the model planned for
rK <- quiet(meddecide::kappaSizeCI(kappa0 = 0.6, kappaL = 0.4, kappaU = 0.8, props = "0.20, 0.80", raters = "2", alpha = 0.05))
nK <- nfrom(rK)
info("X6-nCI", "kappaSizeCI planned n (kappa0 0.6, limits 0.4-0.8, P(present) 0.2, 2 raters)", "kappaSizeCI", fmt(nK))
pp <- 0.2; qq <- 0.8; kk <- 0.6
cellp <- c(p11 = pp^2 + kk * pp * qq, p10 = pp * qq * (1 - kk), p01 = pp * qq * (1 - kk), p00 = qq^2 + kk * pp * qq)
REPS <- 300; set.seed(20261021)
sim <- t(vapply(seq_len(REPS), function(i) {
  cnt <- stats::rmultinom(1, nK, cellp)[, 1]
  r1 <- rep(c("pos", "pos", "neg", "neg"), cnt); r2 <- rep(c("pos", "neg", "pos", "neg"), cnt)
  ds <- data.frame(r1 = factor(r1, levels = c("neg", "pos")), r2 = factor(r2, levels = c("neg", "pos")))
  a <- quiet(meddecide::agreement(data = ds, vars = c("r1", "r2")))$irrtable$asDF
  c(a$kappa, a$ci_lower, a$ci_upper)
}, numeric(3)))
ok <- stats::complete.cases(sim)
cov <- mean(sim[ok, 2] <= kk & sim[ok, 3] >= kk); lowOK <- mean(sim[ok, 2] >= 0.4); hw <- mean((sim[ok, 3] - sim[ok, 2]) / 2)
mcse <- function(p) sqrt(p * (1 - p) / sum(ok))
add_row("X6-sim-cov", paste0("agreement Wald CI coverage of kappa 0.6 at the kappaSizeCI n (", nK, "), R = ", sum(ok)),
        "kappaSizeCI -> agreement", "SIM", sprintf("%.4f (MCSE %.4f)", cov, mcse(cov)), "0.95 +/- 3 MCSE",
        abs(cov - 0.95), 3 * sqrt(0.95 * 0.05 / sum(ok)), if (abs(cov - 0.95) <= 3 * sqrt(0.95 * 0.05 / sum(ok))) "PASS" else "FAIL",
        "", "seed 20261021, common-marginal model, P(present) 0.2")
info("X6-sim-low", "share of agreement Wald intervals with lower limit >= 0.4 at the planned n", "kappaSizeCI -> agreement",
     sprintf("%.4f (MCSE %.4f); kappaSizeCI states 'roughly half' for its own goodness-of-fit interval", lowOK, mcse(lowOK)), grade = "SIM")
info("X6-sim-hw", "mean half-width of agreement's Wald interval at the planned n (planned half-width 0.2)", "kappaSizeCI -> agreement",
     sprintf("%.4f", hw), grade = "SIM")
check_true("X6-disclosed", "kappaSizeCI discloses that its n does not deliver the precision of a Wald interval and that its kappa is not Cohen's under rater bias",
           "kappaSizeCI", grepl("Wald", rK$notices$content) && grepl("Cohen", rK$notices$content))
# Estimator mismatch under rater bias (disclosed): Cohen's kappa (agreement) vs the common-marginal kappa (kappaSize)
tb <- c(a = 30, b = 25, c = 5, d = 40)        # r1 pos/r2 pos, r1 pos/r2 neg, r1 neg/r2 pos, both neg; r1 55% pos, r2 35%
r1 <- rep(c("pos", "pos", "neg", "neg"), tb); r2 <- rep(c("pos", "neg", "pos", "neg"), tb)
ag <- quiet(meddecide::agreement(data = data.frame(r1 = factor(r1, levels = c("neg", "pos")), r2 = factor(r2, levels = c("neg", "pos"))),
                                 vars = c("r1", "r2")))$irrtable$asDF$kappa
po <- (30 + 40) / 100; pe_c <- .55 * .35 + .45 * .65; pbar <- (.55 + .35) / 2; pe_s <- pbar^2 + (1 - pbar)^2
check("X6-cohen", "agreement prints Cohen's kappa (hand) on a rater-biased table", "agreement", ag, (po - pe_c) / (1 - pe_c))
info("X6-scott", "common-marginal (Scott/intraclass) kappa that kappaSize plans for, same table", "kappaSize*",
     sprintf("Cohen %.4f vs intraclass %.4f", (po - pe_c) / (1 - pe_c), (po - pe_s) / (1 - pe_s)), grade = "EXEC-IND")

# ================================================================================================
section("X7. Conventions a user reads side by side")
# ================================================================================================
fmts <- function(f, tab, cols) { y <- yaml::read_yaml(file.path("/Users/serdarbalci/Documents/GitHub/meddecide/jamovi", paste0(f, ".r.yaml")))
  find <- function(items) { for (it in items) { if (identical(it$name, tab)) return(it)
      for (k in c("items", "template")) if (!is.null(it[[k]])) { s <- if (!is.null(it[[k]]$name)) list(it[[k]]) else it[[k]]; r <- find(s); if (!is.null(r)) return(r) } }
    NULL }
  it <- find(y$items); if (!is.null(it$template)) it <- it$template
  vapply(cols, function(cn) { c0 <- Filter(function(c1) identical(c1$name, cn), it$columns); if (length(c0)) (c0[[1]]$format %||% "") else "?" }, "") }
`%||%` <- function(a, b) if (is.null(a)) b else a
FMT <- c(decision = fmts("decision", "ratioTable", "Sens"), decisioncalculator = fmts("decisioncalculator", "ratioTable", "Sens"),
       decisioncompare = fmts("decisioncompare", "comparisonTable", "Sens"), decisioncombine = fmts("decisioncombine", "combinationTable", "sens"),
       psychopdaROC = fmts("psychopdaROC", "resultsTable", "sensitivity"), cotest = fmts("cotest", "testParamsTable", "sens"),
       sequentialtests = fmts("sequentialtests", "individual_tests_table", "sensitivity"),
       enhancedROC = fmts("enhancedROC", "diagnosticPerformance", "sensitivity"))
check_true("X7-pc", "sensitivity is displayed on one scale (percent) in every diagnostic analysis", paste(names(FMT), collapse = ", "),
           all(FMT == "pc"), finding = "XA-07", observed = paste(names(FMT), FMT, sep = "=", collapse = "; "))
check_true("X7-citext", "enhancedROC's interval text keeps a fixed number of decimals", "enhancedROC",
           identical(RES$A$enhancedROC$se_ci_text, "(0.663, 0.900)"), finding = "XA-07",
           observed = RES$A$enhancedROC$se_ci_text, note = "round(x, 3) pasted as text drops trailing zeros (enhancedROC.b.R:2597)")
eDC <- tryCatch({ cmp(dA, ci = TRUE, pp = TRUE, pprob = 0.01); "accepted" }, error = function(e) "refused")
eD  <- tryCatch({ dec(dA, ci = TRUE, pp = TRUE, pprob = 0.01); "accepted" }, error = function(e) "refused")
check_true("X7-ppci", "CI + population prior: the same combination is accepted (decision) or refused (decisioncompare) consistently",
           "decision, decisioncompare", eDC == eD, finding = "XA-08", observed = paste0("decision ", eD, "; decisioncompare ", eDC))
dfl <- c(decision = formals(meddecide::decision)$pprob, decisioncalculator = formals(meddecide::decisioncalculator)$pprob,
         decisioncompare = formals(meddecide::decisioncompare)$pprob, enhancedROC = formals(meddecide::enhancedROC)$prevalence,
         psychopdaROC = formals(meddecide::psychopdaROC)$priorPrev, cotest = formals(meddecide::cotest)$prevalence,
         sequentialtests = formals(meddecide::sequentialtests)$prevalence)
info("X7-defaults", "default population prior per analysis", paste(names(dfl), collapse = ", "), paste(names(dfl), dfl, sep = "=", collapse = "; "))
# decisioncompare shows accuracy twice when OPA and CI are both on: is each interval named?
rO <- cmp(dA, ci = TRUE, opa = TRUE)
opa <- rO$opaTable$asDF; dac <- rk(rO$epirTable1$asDF, "diag.ac")
opaNote <- paste(vapply(rO$opaTable$notes, function(n) n$note, ""), collapse = " ")
epiNote <- paste(vapply(rO$epirTable1$notes, function(n) n$note, ""), collapse = " ")
info("X7-acc2", "decisioncompare accuracy 175/200 on one page: OPA table vs epiR table", "decisioncompare",
     paste0("OPA CI ", fmt(round(unlist(opa[1, grep("lower|upper", names(opa))]), 4)), " ; epiR diag.ac CI ", fmt(round(c(dac$lower, dac$upper), 4)),
            " ; Wilson ", fmt(round(wil(175, 200), 4)), " ; CP ", fmt(round(CPacc, 4))))
check_true("X7-acc2-labels", "both accuracy intervals name their method (Wilson / Clopper-Pearson)", "decisioncompare",
           grepl("Wilson", opaNote) && grepl("Clopper", epiNote))
# Missing second test: the same test 1, two denominators
dm <- mk(40, 15, 10, 135); dm$t2[seq(1, 200, by = 4)] <- NA
sP <- ex_cmp(cmp(dm)); sB <- ex_comb(comb(dm))
txtB <- alltext(comb(dm))
info("X7-missing", "Se of test 1 when test 2 is missing on 50 rows: decisioncompare (per-test rows) vs decisioncombine 'Test 1 alone' (complete cases)",
     "decisioncompare, decisioncombine", paste0("decisioncompare ", fmt(sP$se), " ; decisioncombine ", fmt(sB$se),
     " (", sB$tp + sB$fn, " diseased)"))
check_true("X7-missing-disclosed", "decisioncombine says its single-test rows use complete cases across all tests",
           "decisioncombine", grepl("complete[- ]case", txtB, ignore.case = TRUE))

# ------------------------------------------------------------------------------------------------
m <- do.call(rbind, audit$rows)
utils::write.csv(m, OUT, row.names = FALSE)
cat("\nRows:", nrow(m), " PASS:", sum(m$result == "PASS"), " FAIL:", sum(m$result == "FAIL"),
    " INFO:", sum(m$result == "INFO"), "\n")
if (any(m$result == "FAIL")) { print(m[m$result == "FAIL", c("id", "analyses", "observed", "expected")], right = FALSE) }
cat("\nINFO rows:\n"); print(m[m$result == "INFO", c("id", "observed")], right = FALSE)
cat("\nsessionInfo:\n"); print(utils::sessionInfo())
quit(status = if (any(m$result == "FAIL")) 1L else 0L)
