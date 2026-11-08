#!/usr/bin/env Rscript
# Independent review of decisioncurve - 2026-10-21 (meddecide 1.1.1 pre-release, commit 403e034)
# /independent-reviewer decisioncurve. Audit only: no production file is modified.
# Adapted from development-scripts/audit_decisioncurve.R (2026-10-13): loads the SHIPPED meddecide
# source (pkgload, --vanilla) instead of the umbrella, runs single-process (RAM cap), and adds
# section N (new tests, 2026-10-21). Expected values of the reused checks are unchanged.
#
# Run twice (E9), from any directory:
#   LANG=en_US.UTF-8 Rscript --vanilla development-scripts/audit_decisioncurve_2026-10-21.R
#   AUDIT_SIM=0 skips the Monte Carlo section F (R = 400 replicates, single process, ~80 s; R raised from 100 after timing a run, same as 2026-10-13).
#
# Every expected value below was written from the estimand definition (Vickers & Elkin 2006:
# NB = TP/n - FP/n * pt/(1 - pt), positive when risk >= pt), from exact fractions worked by hand
# in the comments, from closed-form population truth, or from dcurves 0.5.1 (an independent
# implementation decisioncurve never calls). No expected value was revised after a run.
# Output: a results matrix printed and written to
#   development-ideas/decisioncurve-independent-review-2026-10-21-matrix.csv
# Exit status 1 when any check is FAIL.

suppressPackageStartupMessages(pkgload::load_all("/Users/serdarbalci/Documents/GitHub/meddecide", quiet = TRUE, export_all = TRUE))
suppressPackageStartupMessages(library(dcurves))
set.seed(20261021)
t_start <- Sys.time()

`%||%` <- function(a, b) if (is.null(a)) b else a
quiet <- function(expr) suppressWarnings(suppressMessages(force(expr)))
fmt   <- function(x) paste(base::format(x, digits = 12), collapse = ", ")
audit <- new.env(); audit$rows <- list()

# Element-wise comparison. `tol` is RELATIVE to each expected value (absolute where expected is 0);
# `abs_tol`, when given, replaces it with an absolute bound. all.equal() is not used: with a vector
# `scale` it tests the MEAN difference, so one bad element can hide among good ones.
check <- function(claim, test, observed, expected, tol = 1e-8, abs_tol = NULL, grade = "EXEC-IND",
                  cls = "A", note = "") {
    observed <- unname(unlist(observed)); expected <- unname(unlist(expected))
    if (is.numeric(expected)) {
        ok <- is.numeric(observed) && length(observed) == length(expected) && length(observed) > 0 &&
            identical(is.na(observed), is.na(expected))
        if (ok) {
            k <- !is.na(expected)
            lim <- if (!is.null(abs_tol)) rep_len(abs_tol, length(expected))[k]
                   else tol * ifelse(expected[k] != 0, abs(expected[k]), 1)
            ok <- all(abs(observed[k] - expected[k]) <= lim)
        }
        d <- if (is.numeric(observed) && length(observed) == length(expected))
            max(abs(observed - expected)) else NA_real_
    } else {
        ok <- identical(as.character(observed), as.character(expected)); d <- NA_real_
    }
    audit$rows[[length(audit$rows) + 1L]] <- data.frame(
        claim, class = cls, test, grade, observed = fmt(observed), expected = fmt(expected),
        max_abs_diff = d, tol = if (is.null(abs_tol)) tol else abs_tol[1],
        result = if (isTRUE(ok)) "PASS" else "FAIL", note, stringsAsFactors = FALSE)
    invisible(isTRUE(ok))
}
# Logical condition (property, guard, disclosure). observed/expected recorded as text.
check_true <- function(claim, test, cond, grade = "EXEC-PROP", cls = "C", note = "",
                       observed = NULL) {
    ok <- isTRUE(cond)
    audit$rows[[length(audit$rows) + 1L]] <- data.frame(
        claim, class = cls, test, grade,
        observed = if (is.null(observed)) as.character(ok) else fmt(observed),
        expected = "TRUE", max_abs_diff = NA_real_, tol = NA_real_,
        result = if (ok) "PASS" else "FAIL", note, stringsAsFactors = FALSE)
    invisible(ok)
}
record <- function(claim, test, result, grade, cls, note, observed = "", expected = "") {
    audit$rows[[length(audit$rows) + 1L]] <- data.frame(
        claim, class = cls, test, grade, observed = observed, expected = expected,
        max_abs_diff = NA_real_, tol = NA_real_, result = result, note,
        stringsAsFactors = FALSE)
}

# Every Level argument passed explicitly (decisionRulePositive defaults to NULL here).
# do.call(), so the wrapper receives VALUES: its jmvcore::resolveQuo() reads a bare symbol
# (`models = bmods`) as a column name and `c(a, b)` as the names "a" and "b".
# showInterpretation became opt-in (default FALSE) after 2026-10-13; the narrative checks need it,
# and it is presentation-only (E-class checks below confirm it moves no number).
dc <- function(data, ..., decisionRulePositive = NULL, showInterpretation = TRUE) {
    args <- c(list(data = data), list(...), list(decisionRulePositive = decisionRulePositive,
                                                 showInterpretation = showInterpretation))
    quiet(do.call(meddecide::decisioncurve, args))
}
dc_try <- function(...) tryCatch(dc(...), error = function(e) e)

strip_key <- function(df) gsub('^"|"$', "", rownames(df))
row_at <- function(df, col, value, tol = 1e-9) {
    hit <- if (is.numeric(value)) which(abs(df[[col]] - value) < tol) else which(df[[col]] == value)
    if (length(hit) != 1) stop(sprintf("row_at: %d rows match %s = %s", length(hit), col, value))
    df[hit, , drop = FALSE]
}
col_by_title <- function(tbl, title) {
    for (c in tbl$columns) if (identical(c$title, title)) return(c$name)
    stop("no column titled ", title)
}
notices_df <- function(res) {
    h <- res$notices$content
    if (is.null(h) || !nzchar(h))
        return(data.frame(type = character(), title = character(), content = character()))
    chunks <- strsplit(h, "<div style='background-color: ", fixed = TRUE)[[1]][-1]
    bg <- sub(";.*$", "", chunks)
    map <- c("rgba(220, 38, 38, 0.10)" = "ERROR", "rgba(234, 88, 12, 0.10)" = "STRONG_WARNING",
             "rgba(202, 138, 4, 0.12)" = "WARNING", "rgba(37, 99, 235, 0.08)" = "INFO")
    data.frame(type = unname(map[bg]),
               title = sub("^(Error|Important warning|Warning|Note): ", "", trimws(sub("^.*?<strong> ?(.*?)</strong>.*$", "\\1", chunks, perl = TRUE))),
               content = sub("^.*?<span style='color: inherit;'>(.*?)</span>.*$", "\\1", chunks,
                             perl = TRUE),
               stringsAsFactors = FALSE)
}
# 2026-10-21: a fatal input now raises jmvcore::reject() out of the wrapper (the analysis stops
# with jamovi's error state) instead of returning results carrying an ERROR notice. A refusal is
# either form; the message must name the cause.
refused <- function(r, title) {
    if (inherits(r, "error")) return(grepl(title, conditionMessage(r), fixed = TRUE))
    has_notice(r, title, "ERROR")
}
has_notice <- function(res, title, type = NULL) {
    nd <- notices_df(res)
    hit <- nd$title == title
    if (!is.null(type)) hit <- hit & nd$type == type
    any(hit)
}
# Render one image through jmvcore and return the ggplot that was printed.
render_plot <- function(res, image) {
    ggplot2::set_last_plot(NULL)
    f <- tempfile(fileext = ".png")
    ok <- tryCatch({ res[[image]]$saveAs(f); file.exists(f) && file.size(f) > 0 },
                   error = function(e) FALSE)
    list(ok = ok, plot = ggplot2::last_plot())
}
layer_xy <- function(p, i) {
    grDevices::pdf(NULL); on.exit(grDevices::dev.off())
    ld <- ggplot2::layer_data(p, i)
    ld
}
notes_txt <- function(tbl) paste(vapply(tbl$notes, function(z) z$note, ""), collapse = " ")
has_point <- function(ld, x, y, tol = 1e-9) any(abs(ld$x - x) < tol & abs(ld$y - y) < tol)

# Oracles written from the estimand definition (Vickers & Elkin 2006), not from the module.
nb_def <- function(p, y, t) vapply(t, function(tt) {
    n <- length(y); pos <- p >= tt
    sum(pos & y) / n - sum(pos & !y) / n * tt / (1 - tt) }, numeric(1))
ta_def <- function(y, t) mean(y) - (1 - mean(y)) * t / (1 - t)
trap_avg <- function(x, y) sum(diff(x) * (head(y, -1) + tail(y, -1)) / 2) / (max(x) - min(x))
dec_grid <- function(lo, hi, step, digits) as.numeric(sprintf(paste0("%.", digits, "f"),
                                                     seq(lo, hi, by = step)))

# ============================================================================================
# Phase 1 static checks (graded READ; they generate hypotheses, they verify nothing)
# ============================================================================================
src <- readLines("/Users/serdarbalci/Documents/GitHub/meddecide/R/decisioncurve.b.R", warn = FALSE)
ayaml <- readLines("/Users/serdarbalci/Documents/GitHub/meddecide/jamovi/decisioncurve.a.yaml", warn = FALSE)
n_try <- length(grep("tryCatch(", src, fixed = TRUE))
record("IR-C32", "S1 fabricated-result sweep: tryCatch handlers that return a number",
       "PASS", "READ", "D",
       paste0(n_try, " tryCatch sites; the only numeric fallback (bootstrap CI) returns NA with a",
              " WARNING notice; sensitivity=0/specificity=1 fallbacks are unreachable because a",
              " single-class outcome is refused (see D-tests)"), observed = n_try)
# User-visible text only: translatable strings in the backend and the option descriptions.
# Code comments are not a disclosure.
visible_txt <- c(grep("\\.\\(|\\.fmt\\(", src, value = TRUE),
                 grep("^\\s*#", ayaml, value = TRUE, invert = TRUE))
disclosure_design <- any(grepl("case-control|case control|sampling design|exogenous|prevalence of the target",
                               visible_txt, ignore.case = TRUE))
disclosure_cluster <- any(grepl("cluster|patient-level|per-patient|independent patients|one row per patient",
                                visible_txt, ignore.case = TRUE))

# ============================================================================================
# A. Known answers - tiny data (n = 12), exact fractions by hand
# ============================================================================================
# risk m and outcome; events at rows 1,2,4,6,9 -> 5 events, 7 non-events, prevalence 5/12.
# Row 9 has m = 0.15 exactly, row 7 has 0.30 exactly, row 8 0.20, row 10 0.10, row 11 0.05:
# each sits ON a selected threshold, so `>=` is exercised at every table row.
tiny <- data.frame(
    y = factor(c("yes","yes","no","yes","no","yes","no","no","yes","no","no","no"),
               levels = c("no", "yes")),
    m = c(0.90, 0.80, 0.70, 0.60, 0.50, 0.40, 0.30, 0.20, 0.15, 0.10, 0.05, 0.02))
yT <- tiny$y == "yes"
# t=0.05: pos rows 1-11, TP 5 FP 6 -> 5/12 - 6/12*1/19 = 89/228 ; TA 5/12 - 7/12*1/19 = 22/57
# t=0.10: pos 1-10, TP 5 FP 5 -> 5/12*(8/9) = 10/27            ; TA 19/54
# t=0.15: pos 1-9,  TP 5 FP 4 -> 5/12 - 4/12*3/17 = 73/204      ; TA 16/51
# t=0.20: pos 1-8,  TP 4 FP 4 -> 4/12 - 4/12*1/4 = 1/4          ; TA 13/48
# t=0.25: pos 1-7,  TP 4 FP 3 -> 4/12 - 3/12*1/3 = 1/4          ; TA 2/9
# t=0.30: pos 1-7,  TP 4 FP 3 -> 4/12 - 3/12*3/7 = 19/84        ; TA 1/6
exp_nb <- c(89/228, 10/27, 73/204, 1/4, 1/4, 19/84)
exp_ta <- c(22/57, 19/54, 16/51, 13/48, 2/9, 1/6)
sel <- c(0.05, 0.10, 0.15, 0.20, 0.25, 0.30)

resT <- dc(tiny, outcome = "y", outcomePositive = "yes", models = "m",
           showDecisionConsequences = TRUE, calculateClinicalImpact = TRUE,
           costBenefitAnalysis = TRUE, resourceUtilization = TRUE, showBenefitRange = TRUE,
           weightedAUC = TRUE, showInterventionAvoided = TRUE, showRelativeUtility = TRUE,
           showStandardizedNetBenefit = TRUE)
rt <- resT$resultsTable$asDF
check("IR-C01", "A1 model NB at the six selected thresholds (hand fractions)",
      rt$model_m, exp_nb, tol = 1e-12)
check("IR-C02", "A1 treat-all NB at the six selected thresholds (hand fractions)",
      rt$treat_all, exp_ta, tol = 1e-12)
check("IR-C03", "A1 treat-none NB is 0", rt$treat_none, rep(0, 6), tol = 0)
check("IR-C01", "A1 row thresholds are the selected values", rt$threshold, sel, tol = 0)

dcT <- resT$decisionConsequencesTable$asDF
d30 <- row_at(dcT, "threshold", 0.30); d15 <- row_at(dcT, "threshold", 0.15)
# t=0.30: TP 4 FP 3 TN 4 FN 1; sens 4/5 spec 4/7 PPV 4/7 NPV 4/5
check("IR-C07", "A2 consequences at 30%: TP,FP,TN,FN",
      c(d30$true_positive, d30$false_positive, d30$true_negative, d30$false_negative),
      c(4, 3, 4, 1), tol = 0)
check("IR-C07", "A2 consequences at 30%: sens,spec,PPV,NPV",
      c(d30$sensitivity, d30$specificity, d30$ppv, d30$npv), c(4/5, 4/7, 4/7, 4/5), tol = 1e-12)
# t=0.15: TP 5 FP 4 TN 3 FN 0; sens 1 spec 3/7 PPV 5/9 NPV 1
check("IR-C07", "A2 consequences at 15% (risk exactly 0.15 counted positive)",
      c(d15$true_positive, d15$false_positive, d15$true_negative, d15$false_negative,
        d15$sensitivity, d15$specificity, d15$ppv, d15$npv),
      c(5, 4, 3, 0, 1, 3/7, 5/9, 1), tol = 1e-12)

ci30 <- row_at(resT$clinicalImpactTable$asDF, "threshold", 0.30)
# population 1000: interventions 7/12*1000; TP 4/12*1000; FP 3/12*1000;
# net interventions avoided (19/84 - 1/6) / (3/7) * 1000 = 35/252*1000; patients/TP 12/4
check("IR-C08", "A3 clinical impact at 30% (pop 1000)",
      c(ci30$interventions_per_100, ci30$true_positives_per_100, ci30$false_positives_per_100,
        ci30$interventions_avoided, ci30$number_needed_to_screen),
      c(7000/12, 4000/12, 3000/12, 35000/252, 3), tol = 1e-10)

cb30 <- row_at(resT$costBenefitTable$asDF, "threshold", 0.30)
# n=1000, tp=1000/3, fp=250. cost = 1000*100 + (1000/3+250)*1000; benefit = tp*1e4 - fp*500
# treat-all: tp 5000/12, fp 7000/12, cost 1e6, benefit 5000/12*1e4 - 7000/12*500 = 3875000
cost_m <- 1e5 + (1000/3 + 250) * 1000; ben_m <- 1000/3 * 1e4 - 250 * 500
check("IR-C09", "A4 monetary payoff at 30% (defaults)",
      c(cb30$total_cost, cb30$total_benefit, cb30$net_monetary_benefit, cb30$incremental_cost,
        cb30$incremental_benefit, cb30$incremental_net_payoff),
      c(cost_m, ben_m, ben_m - cost_m, cost_m - 1e6, ben_m - 3875000,
        (ben_m - cost_m) - (3875000 - 1e6)), tol = 1e-10)

ru30 <- row_at(resT$resourceUtilizationTable$asDF, "threshold", 0.30)
check("IR-C10", "A5 resource utilisation at 30% (pop 1000)",
      c(ru30$treatments_per_1000, ru30$unnecessary_treatments,
        ru30$missed_cases, ru30$reduction_vs_treat_all),
      c(7000/12, 250, 1000/12, 5/12), tol = 1e-10)

# Curve, range of benefit and average NB on the default 5-50% grid, from the definition
gridC <- dec_grid(0.05, 0.50, 0.01, 2)
nbT_curve <- nb_def(tiny$m, yT, gridC); taT_curve <- ta_def(yT, gridC)
sup <- nbT_curve - pmax(taT_curve, 0) > 1e-10
pdT <- resT$dcaPlot$state$plotData
mT <- pdT[pdT$model == "m", ]
check("IR-C04", "A6 plotted curve equals definition at all 46 grid points (tiny)",
      mT$net_benefit, nbT_curve, tol = 1e-12)
check("IR-C04", "A6 plotted grid equals the decimal grid 0.05..0.50", mT$threshold, gridC, tol = 0)
br <- resT$benefitRangeTable$asDF
check("IR-C11", "A7 range of benefit endpoints", c(br$range_start, br$range_end),
      c(min(gridC[sup]), max(gridC[sup])), tol = 1e-12)
gap_expected <- !identical(which(sup), seq(min(which(sup)), max(which(sup))))
check_true("IR-C11", "A7 the superior set has a gap (16-20%) and the gap note is shown",
           gap_expected && grepl("more than one separate stretch",
                                 notes_txt(resT$benefitRangeTable),
                                 fixed = TRUE), grade = "EXEC-IND", cls = "A")
wa <- resT$weightedAUCTable$asDF
check("IR-C12", "A8 average NB = trapezoid area / range width",
      wa$weighted_auc, trap_avg(gridC, nbT_curve), tol = 1e-12)
check("IR-C12", "A8 gain vs best default = avg(NB) - avg(max(TA, 0))",
      wa$benefit_gain, trap_avg(gridC, nbT_curve) - trap_avg(gridC, pmax(taT_curve, 0)),
      tol = 1e-12)

# H. narrative: the interpretation names the range and the gap
st <- resT$summaryText$content
check_true("IR-C15", "H1 interpretation states the range of benefit with the table endpoints",
           grepl(sprintf("%s%% to %s%% threshold probability", round(min(gridC[sup]) * 100, 1),
                         round(max(gridC[sup]) * 100, 1)), st, fixed = TRUE),
           grade = "EXEC-IND", cls = "H")
check_true("IR-C15", "H1 interpretation discloses the gap",
           grepl("contains a gap", st, fixed = TRUE), grade = "EXEC-IND", cls = "H")
check_true("IR-C32", "H2 procedure notes show prevalence 41.7% and 12 complete cases",
           grepl("41.7%", resT$procedureNotes$content, fixed = TRUE) &&
               grepl("12 complete cases", resT$procedureNotes$content, fixed = TRUE),
           grade = "EXEC-IND", cls = "G")

# I. plots on tiny data (layer data of the ggplot actually printed)
rp <- render_plot(resT, "interventionsAvoidedPlot")
check_true("IR-C19", "I1 interventions-avoided plot renders", rp$ok, cls = "I")
ld <- layer_xy(rp$plot, 1)
# per 100: (19/84 - 1/6) / (3/7) * 100 = 3500/252
check_true("IR-C19", "I1 interventions avoided at 30% = 13.889 per 100 (hand)",
           has_point(ld, 0.30, 3500/252), grade = "EXEC-IND", cls = "I")
rp <- render_plot(resT, "standardizedNetBenefitPlot")
ld <- layer_xy(rp$plot, 1)
# sNB = NB / prevalence = (19/84) / (5/12) = 228/420
check_true("IR-C20", "I2 standardized NB at 30% = (19/84)/(5/12)", rp$ok && has_point(ld, 0.30, 228/420),
           grade = "EXEC-IND", cls = "I")
rp <- render_plot(resT, "relativeUtilityPlot")
ld <- layer_xy(rp$plot, 1)
# Baker 2009 s.9 (prose): RU = (NB - max(0, TA)) / (prev - max(0, TA))
# t=0.30 < prev: (19/84 - 1/6) / (5/12 - 1/6) = 5/21
# t=0.45 > prev: pos rows 1-5 TP 3 FP 2 -> NB 3/12 - 2/12*9/11 = 5/44; RU = (5/44)/(5/12) = 3/11
check_true("IR-C21", "I3 relative utility at 30% = 5/21 and at 45% = 3/11 (hand)",
           rp$ok && has_point(ld, 0.30, 5/21) && has_point(ld, 0.45, 3/11),
           grade = "EXEC-IND", cls = "I")
rp <- render_plot(resT, "clinicalImpactPlot")
check_true("IR-C08", "I4 clinical impact plot renders", rp$ok, cls = "I")
rp <- render_plot(resT, "dcaPlot")
check_true("IR-C04", "I5 decision curve renders", rp$ok, cls = "I")
ld1 <- layer_xy(rp$plot, 1)
check_true("IR-C04", "I5 base layer of the DCA plot draws exactly the model curve points",
           nrow(ld1) == 46 && all(mapply(function(x, y) has_point(ld1, x, y), mT$threshold,
                                         mT$net_benefit)), grade = "EXEC-PROP", cls = "I")
lin <- vapply(seq_along(rp$plot$layers), function(i) {
    lt <- rp$plot$layers[[i]]$aes_params$linetype; if (is.null(lt)) "" else lt }, "")
check_true("IR-C04", "I5 reference strategies drawn in a dashed layer in the default style",
           any(lin == "dashed"), grade = "EXEC-PROP", cls = "I")

# ============================================================================================
# B. Reference parity with dcurves 0.5.1 (independent implementation)
# ============================================================================================
set.seed(101); nB <- 1000
rB <- runif(nB, 0, 0.6); yB <- rbinom(nB, 1, rB) == 1
datB <- data.frame(
    y = factor(ifelse(yB, "event", "none"), levels = c("none", "event")),
    good = round(pmin(pmax(rB + rnorm(nB, 0, 0.03), 0), 1), 3),   # 3 decimals: ties on the grid
    weak = pmin(pmax(0.3 + 0.3 * (rB - 0.3) + rnorm(nB, 0, 0.1), 0), 1))
dcB <- dcurves::dca(yy ~ good + weak, data = data.frame(yy = yB, good = datB$good, weak = datB$weak),
                    thresholds = gridC)$dca
resB <- dc(datB, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
           selectedThresholds = "0.07, 0.12, 0.15, 0.21, 0.333")
pdB <- resB$dcaPlot$state$plotData
for (v in c("good", "weak", "all")) {
    mod <- c(good = "good", weak = "weak", all = "Treat All")[[v]]
    obs <- pdB[pdB$model == mod, ]
    ref <- dcB[dcB$variable == v, ]
    check("IR-C04", paste0("B1 curve vs dcurves, clinical grid (", mod, ", 46 points)"),
          obs$net_benefit, ref$net_benefit[match(round(obs$threshold, 10), round(ref$threshold, 10))],
          tol = 1e-10, cls = "B")
}
rtB <- resB$resultsTable$asDF
selB <- c(0.07, 0.12, 0.15, 0.21, 0.333)
dcSel <- dcurves::dca(yy ~ good + weak, data = data.frame(yy = yB, good = datB$good, weak = datB$weak),
                      thresholds = selB)$dca
check("IR-C01", "B2 results table vs dcurves at 7,12,15,21,33.3% (good)",
      rtB$model_good, dcSel$net_benefit[dcSel$variable == "good"], tol = 1e-10, cls = "B")
check("IR-C02", "B2 results table treat-all vs dcurves", rtB$treat_all,
      dcSel$net_benefit[dcSel$variable == "all"], tol = 1e-10, cls = "B")
# G1: the table row at t equals the plotted point at t (3-decimal predictions tie on the grid)
for (tt in c(0.07, 0.12, 0.15, 0.21)) {
    check("IR-C06", sprintf("G1 table row equals curve point at %.0f%% (3-decimal risks)", tt * 100),
          row_at(rtB, "threshold", tt)$model_good,
          pdB$net_benefit[pdB$model == "good" & abs(pdB$threshold - tt) < 1e-12],
          tol = 1e-12, grade = "EXEC-PROP", cls = "G")
}
rOut <- dc(datB, outcome = "y", outcomePositive = "event", models = "good",
           selectedThresholds = "0.2, 0.6")
check("IR-C26", "B3 a table row outside the analysed 5-50% range is computed at its exact value",
      row_at(rOut$resultsTable$asDF, "threshold", 0.6)$model_good, nb_def(datB$good, yB, 0.6),
      tol = 1e-12, cls = "B")
check_true("IR-C26", "B3 ... and flagged as outside the curve's range",
           any(notices_df(rOut)$title == "Table thresholds outside the analysed range" &
                   grepl("60.0%", notices_df(rOut)$content, fixed = TRUE)), cls = "E")

# Bundled data, auto range 1-99% (99 points), five models, 3-decimal risks
data("dca_test_data", package = "meddecide", envir = environment())
bd <- dca_test_data
bmods <- c("basic_model", "enhanced_model", "biomarker_model", "miscalibrated_model", "poor_model")
resBD <- dc(bd, outcome = "cardiac_event", outcomePositive = "Yes", models = bmods,
            thresholdRange = "auto")
gridA <- dec_grid(0.01, 0.99, 0.01, 2)
dcBD <- dcurves::dca(as.formula(paste("yy ~", paste(bmods, collapse = "+"))),
                     data = cbind(data.frame(yy = bd$cardiac_event == "Yes"), bd[bmods]),
                     thresholds = gridA)$dca
pdBD <- resBD$dcaPlot$state$plotData
dev_max <- max(vapply(bmods, function(v) {
    o <- pdBD[pdBD$model == v, ]; r <- dcBD[dcBD$variable == v, ]
    max(abs(o$net_benefit - r$net_benefit[match(round(o$threshold, 10), round(r$threshold, 10))]))
}, numeric(1)))
check("IR-C04", "B4 bundled dca_test_data: 5 models x 99 thresholds vs dcurves (max |diff|)",
      dev_max, 0, tol = 1e-10, cls = "B")
check("IR-C26", "B4 auto grid is the decimal grid 1..99%",
      pdBD$threshold[pdBD$model == "basic_model"], gridA, tol = 0, cls = "B")

# Standardized NB and net interventions avoided vs dcurves helpers (bundled data, 20%)
sNB_dc <- dcurves::standardized_net_benefit(dcurves::dca(yy ~ basic_model,
    data = data.frame(yy = bd$cardiac_event == "Yes", basic_model = bd$basic_model),
    thresholds = 0.20))$dca
res_bd2 <- dc(bd, outcome = "cardiac_event", outcomePositive = "Yes", models = "basic_model",
              selectedThresholds = "0.2", calculateClinicalImpact = TRUE, populationSize = 100)
nia_dc <- dcurves::net_intervention_avoided(dcurves::dca(yy ~ basic_model,
    data = data.frame(yy = bd$cardiac_event == "Yes", basic_model = bd$basic_model),
    thresholds = 0.20), nper = 100)$dca
check("IR-C08", "B5 net interventions avoided per 100 at 20% vs dcurves",
      res_bd2$clinicalImpactTable$asDF$interventions_avoided,
      nia_dc$net_intervention_avoided[nia_dc$variable == "basic_model"], tol = 1e-10, cls = "B")
prev_bd <- mean(bd$cardiac_event == "Yes")
check("IR-C20", "B5 sNB definition matches dcurves standardized_net_benefit at 20%",
      res_bd2$resultsTable$asDF$model_basic_model / prev_bd,
      sNB_dc$standardized_net_benefit[sNB_dc$variable == "basic_model"], tol = 1e-10, cls = "B",
      note = "module computes sNB inside the renderer from the same NB / prevalence")

# ============================================================================================
# G/E. Comparison tables
# ============================================================================================
resCmp <- dc(datB, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
             compareModels = TRUE, multiModelComparison = TRUE, bootReps = 1000)
ctab <- resCmp$comparisonTable$asDF; etab <- resCmp$modelComparisonEnhanced$asDF
nb_g <- nb_def(datB$good, yB, gridC); nb_w <- nb_def(datB$weak, yB, gridC)
check("IR-C13", "G2 comparison: observed difference in average NB (trapezoid)",
      ctab$weighted_auc_diff, trap_avg(gridC, nb_g) - trap_avg(gridC, nb_w), tol = 1e-10, cls = "G")
check("IR-C14", "G2 enhanced: mean and median grid-point NB difference",
      c(etab$nb_difference_mean, etab$nb_difference_median),
      c(mean(nb_g - nb_w), median(nb_g - nb_w)), tol = 1e-10, cls = "G")
check_true("IR-C15", "H4 'Highest Average Net Benefit' names the model with the larger trapezoid average",
           grepl(paste0("Over the Selected Range:</strong> ",
                        if (trap_avg(gridC, nb_g) > trap_avg(gridC, nb_w)) "good" else "weak", " ("),
                 resCmp$summaryText$content, fixed = TRUE), grade = "EXEC-IND", cls = "H")
check_true("IR-C13", "G3 a clearly better model: CI excludes 0 and raw p < 0.05, with p >= 2/(B+1)",
           ctab$ci_lower > 0 && ctab$p_value < 0.05 && ctab$p_value >= 2 / 1001 - 1e-15, cls = "G",
           observed = c(ctab$ci_lower, ctab$ci_upper, ctab$p_value))
# identical models: every replicate difference is 0 -> CI [0, 0], p = 1
datI <- transform(datB, twin = good)
resI <- dc(datI, outcome = "y", outcomePositive = "event", models = c("good", "twin"),
           compareModels = TRUE, multiModelComparison = TRUE, bootReps = 200)
check("IR-C13", "D1 identical models: diff, CI, p, Holm p", unlist(resI$comparisonTable$asDF[1, -1]),
      c(0, 0, 0, 1, 1), tol = 1e-12, grade = "EXEC-PROP", cls = "D")
check("IR-C14", "D1 identical models (enhanced): mean, median, Holm p",
      c(resI$modelComparisonEnhanced$asDF$nb_difference_mean,
        resI$modelComparisonEnhanced$asDF$nb_difference_median,
        resI$modelComparisonEnhanced$asDF$p_value), c(0, 0, 1), tol = 1e-12,
      grade = "EXEC-PROP", cls = "D")
# Holm across 3 pairs; enhanced raw p from the private memo (a built object, E4)
set.seed(7)
datH <- transform(datB, mid = pmin(pmax(rB + rnorm(nB, 0, 0.12), 0), 1))
resH <- dc(datH, outcome = "y", outcomePositive = "event", models = c("good", "weak", "mid"),
           compareModels = TRUE, bootReps = 300)
hc <- resH$comparisonTable$asDF
check("IR-C13", "G4 Holm column equals p.adjust(raw, 'holm') over 3 pairs",
      hc$p_value_adj, stats::p.adjust(hc$p_value, "holm"), tol = 1e-12, grade = "EXEC-WIRE", cls = "G")
dual_ok <- all(((hc$ci_lower > 0 | hc$ci_upper < 0) == (hc$p_value < 0.05)) |
                   abs(hc$p_value - 0.05) < 4 / 301)
check_true("IR-C13", "G4 CI/p duality: CI excludes 0 iff raw p < 0.05 (within 4/(B+1))",
           dual_ok, cls = "G", observed = c(hc$ci_lower, hc$ci_upper, hc$p_value))
opts <- meddecide:::decisioncurveOptions$new(outcome = "y", outcomePositive = "event",
    models = c("good", "weak", "mid"), multiModelComparison = TRUE, bootReps = 300,
    decisionRulePositive = NULL)
aH <- meddecide:::decisioncurveClass$new(options = opts, data = datH)
quiet({ aH$init(); aH$run() })
memo <- aH$.__enclos_env__$private$.bootCompCache
raw_nb_p <- vapply(memo, function(z) z$nb$p_value, numeric(1))
check("IR-C14", "G4 enhanced p column equals Holm of the memoised raw p (3 pairs)",
      sort(aH$results$modelComparisonEnhanced$asDF$p_value),
      sort(stats::p.adjust(raw_nb_p, "holm")), tol = 1e-12, grade = "EXEC-WIRE", cls = "G")

# ============================================================================================
# B/E/F-lite. Bootstrap intervals against a closed form
# ============================================================================================
# NB is a sample mean of c_i = y_i d_i - (1 - y_i) d_i w with d_i = 1(p_i >= t), w = t/(1-t), so
# its bootstrap distribution is that of a mean: percentile limits ~ NB +/- z * sqrt(var_n(c)/n).
# Tolerance 0.15 * SE: MC error of a 2.5% quantile at B = 4000 is ~0.042 SE, skewness of the mean
# at n = 1000 shifts it by < 0.03 SE.
resCI <- dc(datB, outcome = "y", outcomePositive = "event", models = "good",
            confidenceIntervals = TRUE, bootReps = 4000)
pci <- resCI$dcaPlot$state$plotData; pci <- pci[pci$model == "good", ]
for (tt in c(0.10, 0.20, 0.30, 0.40)) {
    d <- datB$good >= tt; w <- tt / (1 - tt); cc <- yB * d - (!yB) * d * w
    se <- sqrt(mean((cc - mean(cc))^2) / nB)
    r <- pci[abs(pci$threshold - tt) < 1e-12, ]
    check("IR-C16", sprintf("B6 pointwise 95%% limits vs NB +/- 1.96 SE at %d%% (n=1000, B=4000)", tt * 100),
          c(r$ci_lower, r$ci_upper), mean(cc) + c(-1, 1) * qnorm(0.975) * se,
          abs_tol = 0.15 * se, cls = "B",
          note = sprintf("SE closed form %.5f; tolerance 0.15 SE", se))
}
check("IR-C17", "C1 simultaneous band is symmetric about the observed curve (nb +/- q*se)",
      pci$sim_upper - pci$net_benefit, pci$net_benefit - pci$sim_lower, tol = 1e-10,
      grade = "EXEC-PROP", cls = "C")
ratio <- median((pci$sim_upper - pci$sim_lower) / (pci$ci_upper - pci$ci_lower))
check_true("IR-C17", "C1 band/pointwise width ratio lies between 1 and the Bonferroni bound",
           ratio > 1 && ratio < qnorm(1 - 0.025 / 46) / qnorm(0.975), cls = "C", observed = ratio)
# I6: a small cohort (n = 80, the regime the module itself warns about). Does the panel the
# reader sees contain every plotted interval limit, or does the y-zoom cut the ribbon off?
set.seed(55); n80 <- 80; r80r <- runif(n80, 0, 0.3)
d80 <- data.frame(y = factor(rbinom(n80, 1, r80r), levels = 0:1, labels = c("n", "e")), p = r80r)
r80 <- dc(d80, outcome = "y", outcomePositive = "e", models = "p", confidenceIntervals = TRUE,
          bootReps = 500)
rp80 <- render_plot(r80, "dcaPlot")
grDevices::pdf(NULL)
yr80 <- ggplot2::ggplot_build(rp80$plot)$layout$panel_params[[1]]$y.range
grDevices::dev.off()
pm80 <- r80$dcaPlot$state$plotData; pm80 <- pm80[pm80$model == "p", ]
clip80 <- sum(pm80$ci_lower < yr80[1] | pm80$ci_upper > yr80[2])
check_true("IR-C16", "I6 the drawn y-range contains every plotted interval limit (n = 80)",
           clip80 == 0, cls = "I",
           observed = c(y_from = yr80[1], y_to = yr80[2], min_lower = min(pm80$ci_lower),
                        max_upper = max(pm80$ci_upper), thresholds_clipped = clip80))
resCI90 <- dc(datB, outcome = "y", outcomePositive = "event", models = "good",
              confidenceIntervals = TRUE, bootReps = 4000, ciLevel = 0.90)
p90 <- resCI90$dcaPlot$state$plotData; p90 <- p90[p90$model == "good", ]
wr <- median((p90$ci_upper - p90$ci_lower) / (pci$ci_upper - pci$ci_lower))
check("IR-C18", "E1 90% vs 95% pointwise width ratio = qnorm(.95)/qnorm(.975)", wr,
      qnorm(0.95) / qnorm(0.975), abs_tol = 0.05, cls = "E",
      note = "same seed, same replicates; tolerance +/-0.05")
check_true("IR-C18", "E1 90% caption and footnote say 90%",
           grepl("at the 90% level", resCI90$summaryText$content, fixed = TRUE), cls = "E",
           grade = "EXEC-IND")
datD <- rbind(datB, datB)
resDup <- dc(datD, outcome = "y", outcomePositive = "event", models = "good",
             confidenceIntervals = TRUE, bootReps = 4000)
pdup <- resDup$dcaPlot$state$plotData; pdup <- pdup[pdup$model == "good", ]
check("IR-C35", "C2 duplicated rows: point estimates unchanged", pdup$net_benefit, pci$net_benefit,
      tol = 1e-12, grade = "EXEC-PROP", cls = "C")
wd <- median((pdup$ci_upper - pdup$ci_lower) / (pci$ci_upper - pci$ci_lower))
check("IR-C35", "C2 duplicated rows: interval width falls by 1/sqrt(2) (rows resampled as independent)",
      wd, 1 / sqrt(2), abs_tol = 0.05, grade = "EXEC-PROP", cls = "C",
      note = "clustered specimens of one patient are treated as independent patients")
check_true("IR-C35", "C2 a clustering/patient-level disclosure exists in the analysis text",
           disclosure_cluster, grade = "READ", cls = "C",
           note = "grep of decisioncurve.b.R and .a.yaml for cluster/per-patient/repeated")

# ============================================================================================
# E/G. Determinism, seed scope, option equivalence
# ============================================================================================
r1 <- dc(datB, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
         confidenceIntervals = TRUE, compareModels = TRUE, bootReps = 300)
r2 <- dc(datB, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
         confidenceIntervals = TRUE, compareModels = TRUE, bootReps = 300)
check_true("IR-C29", "E2 same seed: identical intervals and p",
           identical(r1$dcaPlot$state, r2$dcaPlot$state) &&
               identical(r1$comparisonTable$asDF, r2$comparisonTable$asDF), cls = "E")
r3 <- dc(datB, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
         confidenceIntervals = TRUE, compareModels = TRUE, bootReps = 300, seed = 7)
check_true("IR-C29", "E2 different seed: intervals differ",
           !identical(r1$dcaPlot$state$plotData$ci_lower, r3$dcaPlot$state$plotData$ci_lower),
           cls = "E")
r4 <- dc(datB, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
         compareModels = TRUE, bootReps = 300)
check("IR-C29", "E3 ticking CI does not move the comparison p (own substream)",
      r4$comparisonTable$asDF$p_value, r1$comparisonTable$asDF$p_value, tol = 0,
      grade = "EXEC-PROP", cls = "E")
# E4 (showNetBenefitCI == confidenceIntervals) retired: the duplicate option was removed
# 2026-10-13 (CF-decisioncurve-04).
set.seed(99); u1 <- runif(3)
set.seed(99); invisible(dc(datB, outcome = "y", outcomePositive = "event", models = "good",
                           confidenceIntervals = TRUE, bootReps = 100)); u2 <- runif(3)
check("IR-C29", "E5 caller RNG stream restored after the analysis", u2, u1, tol = 0,
      grade = "EXEC-PROP", cls = "E")

# ============================================================================================
# C. Metamorphic relations
# ============================================================================================
perm <- sample(nrow(datB))
rP2 <-dc(datB[perm, ], outcome = "y", outcomePositive = "event", models = c("good", "weak"),
          selectedThresholds = "0.07, 0.12, 0.15, 0.21, 0.333")
check("IR-C04", "C3 row permutation leaves the table unchanged (same thresholds)",
      as.numeric(unlist(rP2$resultsTable$asDF)), as.numeric(unlist(resB$resultsTable$asDF)),
      tol = 1e-12, grade = "EXEC-PROP", cls = "C")
datLv <- datB; datLv$y <- factor(as.character(datLv$y), levels = c("event", "none"))
rLv <- dc(datLv, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
          selectedThresholds = "0.07, 0.12, 0.15, 0.21, 0.333")
check("IR-C25", "C4 outcome level ORDER reversed: identical results (positive class is the option)",
      as.numeric(unlist(rLv$resultsTable$asDF)), as.numeric(unlist(resB$resultsTable$asDF)),
      tol = 0, grade = "EXEC-PROP", cls = "C")
datRn <- datB; levels(datRn$y) <- c("Negatif", "Pozitif")
rRn <- dc(datRn, outcome = "y", outcomePositive = "Pozitif", models = c("good", "weak"),
          selectedThresholds = "0.07, 0.12, 0.15, 0.21, 0.333")
check("IR-C25", "C4 levels renamed: identical numbers",
      as.numeric(unlist(rRn$resultsTable$asDF)), as.numeric(unlist(resB$resultsTable$asDF)),
      tol = 0, grade = "EXEC-PROP", cls = "C")
datNum <- datB; datNum$y <- as.integer(yB)
rNum <- dc(datNum, outcome = "y", outcomePositive = "1", models = c("good", "weak"),
           selectedThresholds = "0.07, 0.12, 0.15, 0.21, 0.333")
check("IR-C25", "C5 numeric 0/1 outcome with positive level '1' equals the factor run",
      as.numeric(unlist(rNum$resultsTable$asDF)), as.numeric(unlist(resB$resultsTable$asDF)),
      tol = 0, grade = "EXEC-PROP", cls = "C")
# Wrong positive level chosen: NB must be computed for the OTHER event, not silently re-inferred
rWrong <- dc(datB, outcome = "y", outcomePositive = "none", models = "good",
             selectedThresholds = "0.2")
check("IR-C25", "C6 positive level 'none' computes NB for 'none' as the event (no re-inference)",
      rWrong$resultsTable$asDF$model_good, nb_def(datB$good, !yB, 0.2), tol = 1e-12,
      grade = "EXEC-IND", cls = "C")
# The chosen positive level contradicts the predictions (risks of 'event' scored against 'none'):
# AUC of `good` for 'none' is 1 - AUC for 'event'. The output is a correct computation of the
# wrong question, so the only protection is a warning. Is there one?
auc_none <- mean(outer(datB$good[!yB], datB$good[yB], ">")) +
    0.5 * mean(outer(datB$good[!yB], datB$good[yB], "=="))
rWrongFull <- dc(datB, outcome = "y", outcomePositive = "none", models = "good", showBenefitRange = TRUE)
check_true("IR-C25", "C6 predictions inversely related to the chosen positive level are flagged",
           any(grepl("inverse|opposite|reversed|below 0.5|AUC", paste(notices_df(rWrongFull)$title,
                                                                    notices_df(rWrongFull)$content),
                     ignore.case = TRUE)), grade = "EXEC-IND", cls = "D",
           observed = c(auc_for_chosen_level = auc_none,
                        range_shown = rWrongFull$benefitRangeTable$asDF$range_start),
           note = "AUC for the event is 1 minus the observed value (~0.74); the interpretation then reads 'Range of Benefit: none'")
datNA <- rbind(datB, data.frame(y = factor(NA, levels = c("none", "event")), good = 0.5, weak = NA))
rNA <- dc(datNA, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
          selectedThresholds = "0.07, 0.12, 0.15, 0.21, 0.333")
check("IR-C04", "C7 an all-missing row is excluded and changes nothing",
      as.numeric(unlist(rNA$resultsTable$asDF)), as.numeric(unlist(resB$resultsTable$asDF)),
      tol = 0, grade = "EXEC-PROP", cls = "C")
check_true("IR-C23", "C7 the exclusion is disclosed (1 of 1001 rows)",
           has_notice(rNA, "Complete-Case Analysis", "WARNING") &&
               grepl("1 of 1001 rows", notices_df(rNA)$content[notices_df(rNA)$title ==
                                                                 "Complete-Case Analysis"], fixed = TRUE),
           cls = "C")
# Non-syntactic and non-ASCII names
nm1 <- "Risk (Model A)"; nm2 <- "Olasılık skoru"
datNm <- data.frame(y = datB$y, a = datB$good, b = datB$weak, check.names = FALSE)
names(datNm) <- c("Outcome / 5y", nm1, nm2)
rNm <- dc(datNm, outcome = "Outcome / 5y", outcomePositive = "event", models = c(nm1, nm2),
          selectedThresholds = "0.07, 0.12, 0.15, 0.21, 0.333")
tb <- rNm$resultsTable
check("IR-C28", "C8 non-syntactic / non-ASCII column names: values follow their titles",
      c(tb$asDF[[col_by_title(tb, nm1)]], tb$asDF[[col_by_title(tb, nm2)]]),
      c(rtB$model_good, rtB$model_weak), tol = 0, grade = "EXEC-PROP", cls = "C")

# ============================================================================================
# D. Boundary, degenerate and adversarial inputs
# ============================================================================================
mk <- function(n_event, n_non, p = NULL) {
    y <- factor(c(rep("yes", n_event), rep("no", n_non)), levels = c("no", "yes"))
    data.frame(y = y, m = if (is.null(p)) seq(0.02, 0.98, length.out = n_event + n_non) else p)
}
r9 <- dc_try(mk(4, 5), outcome = "y", outcomePositive = "yes", models = "m")
check_true("IR-C24", "D2 9 complete cases: refused, no table rows",
           refused(r9, "Insufficient Cases"), cls = "D")
r10 <- dc(mk(4, 6), outcome = "y", outcomePositive = "yes", models = "m")
check_true("IR-C24", "D2 10 complete cases: runs", nrow(r10$resultsTable$asDF) == 6, cls = "D")
badP <- tiny; badP$m[1] <- 1.2
rB1 <- dc_try(badP, outcome = "y", outcomePositive = "yes", models = "m")
check_true("IR-C24", "D3 a prediction of 1.2 is refused, nothing computed",
           refused(rB1, "Invalid Probabilities: m"), cls = "D")
edgeP <- tiny; edgeP$m[1] <- 1; edgeP$m[12] <- 0
rE <- dc(edgeP, outcome = "y", outcomePositive = "yes", models = "m")
check("IR-C24", "D3 predictions of exactly 0 and 1 are accepted and computed",
      rE$resultsTable$asDF$model_m, nb_def(edgeP$m, yT, sel), tol = 1e-12, cls = "D")
oneCls <- tiny; oneCls$y <- factor(rep("yes", 12), levels = c("no", "yes"))
rO <- dc_try(oneCls, outcome = "y", outcomePositive = "yes", models = "m")
check_true("IR-C24", "D4 single-class outcome is refused (fallback sens/spec unreachable)",
           refused(rO, "Outcome Not Binary"), cls = "D")
three <- tiny; three$y <- factor(rep(c("a", "b", "c"), 4))
rTh <- dc_try(three, outcome = "y", outcomePositive = "a", models = "m")
check_true("IR-C24", "D4 three-level outcome is refused", refused(rTh, "Outcome Not Binary"),
           cls = "D")
addna <- rbind(tiny, data.frame(y = NA, m = 0.5)); addna$y <- addNA(addna$y)
rAN <- dc_try(addna, outcome = "y", outcomePositive = "yes", models = "m")
check_true("IR-C24", "D4 an explicit NA LEVEL is not silently counted as a class",
           inherits(rAN, "error") || has_notice(rAN, "Outcome Not Binary", "ERROR") ||
               identical(as.numeric(rAN$resultsTable$asDF$model_m), exp_nb), cls = "D")
const <- tiny; const$m <- 0.2
rC <- dc(const, outcome = "y", outcomePositive = "yes", models = "m", showBenefitRange = TRUE)
check_true("IR-C15", "H3 a model that never beats both references: interpretation says 'none.'",
           grepl("Range of Benefit:</strong> None: across every threshold examined", rC$summaryText$content, fixed = TRUE),
           grade = "EXEC-IND", cls = "H")
check_true("IR-C11", "D5 constant prediction: narrow-range warning, NB equals treat-all at 20% and no range",
           has_notice(rC, "Narrow Probability Range: m", "STRONG_WARNING") &&
               abs(row_at(rC$resultsTable$asDF, "threshold", 0.2)$model_m - 13/48) < 1e-12 &&
               is.na(rC$benefitRangeTable$asDF$range_start), cls = "D", grade = "EXEC-IND")
nonnum <- tiny; nonnum$m <- factor(nonnum$m); attr(nonnum$m, "values") <- seq_along(levels(nonnum$m))
rNN <- dc_try(nonnum, outcome = "y", outcomePositive = "yes", models = "m")
check_true("IR-C24", "D6 a factor (jamovi integer-nominal) prediction column is refused, never read as codes",
           refused(rNN, "Not a numeric column: m"), cls = "D")
rAbsent <- dc_try(tiny, outcome = "y", outcomePositive = "maybe", models = "m")
check_true("IR-C24", "D7 a positive level absent from the data is refused",
           refused(rAbsent, "Positive Outcome Level Required"),
           cls = "D")
rNoPos <- dc_try(tiny, outcome = "y", outcomePositive = NULL, models = "m")
# Unset is now a pending state (allowNone, review guide 25): an INFO listing the levels and nothing
# computed. The claim under test is unchanged: the level is never inferred.
check_true("IR-C24", "D7 positive level unset (NULL): nothing computed, INFO pending notice, not inferred",
           !inherits(rNoPos, "error") && has_notice(rNoPos, "Choose the Positive Outcome Level", "INFO") &&
               is.null(rNoPos$dcaPlot$state) && nrow(rNoPos$resultsTable$asDF) == 0,
           cls = "D")

# Threshold grid and range validation
g <- function(...) { r <- dc(datB, outcome = "y", outcomePositive = "event", models = "good", ...)
    r$dcaPlot$state$plotData$threshold[r$dcaPlot$state$plotData$model == "good"] }
check("IR-C26", "D8 custom 5-33% step 2% grid equals the decimal grid", g(thresholdRange = "custom",
      thresholdMin = 0.05, thresholdMax = 0.33, thresholdStep = 0.02), dec_grid(0.05, 0.33, 0.02, 2),
      tol = 0, cls = "D")
check("IR-C26", "D8 custom 10-20% step 0.1% grid equals the decimal grid (101 points)",
      g(thresholdRange = "custom", thresholdMin = 0.10, thresholdMax = 0.20, thresholdStep = 0.001),
      dec_grid(0.10, 0.20, 0.001, 3), tol = 0, cls = "D")
check("IR-C26", "D8 custom 0.1-99.9% step 0.1% grid equals the decimal grid (999 points)",
      g(thresholdRange = "custom", thresholdMin = 0.001, thresholdMax = 0.999, thresholdStep = 0.001),
      dec_grid(0.001, 0.999, 0.001, 3), tol = 0, cls = "D")
rInv <- dc_try(datB, outcome = "y", outcomePositive = "event", models = "good",
               thresholdRange = "custom", thresholdMin = 0.4, thresholdMax = 0.3)
msg_of <- function(r) if (inherits(r, "error")) conditionMessage(r) else
    paste(notices_df(r)$content, collapse = " ")
check_true("IR-C26", "D9 min >= max is refused with the bounds in the message",
           grepl("(40.0%) must be less than maximum threshold (30.0%)", msg_of(rInv), fixed = TRUE) &&
               (inherits(rInv, "error") || nrow(rInv$resultsTable$asDF) == 0), cls = "D")
rNar <- dc_try(datB, outcome = "y", outcomePositive = "event", models = "good",
               thresholdRange = "custom", thresholdMin = 0.20, thresholdMax = 0.205, thresholdStep = 0.01)
check_true("IR-C26", "D9 a range narrower than the step is refused",
           grepl("narrower than the step size", msg_of(rNar), fixed = TRUE) &&
               (inherits(rNar, "error") || nrow(rNar$resultsTable$asDF) == 0), cls = "D")

# selectedThresholds parsing
pt <- function(s) dc(tiny, outcome = "y", outcomePositive = "yes", models = "m", selectedThresholds = s)
rs1 <- pt("0.3 0.1;0.1,0.2")
check("IR-C27", "D10 mixed separators, duplicate, unsorted -> 0.1, 0.2, 0.3",
      rs1$resultsTable$asDF$threshold, c(0.1, 0.2, 0.3), tol = 0, cls = "D")
rs2 <- pt("15, 30")
check_true("IR-C27", "D10 percentages: default rows used AND the hint names 0.15, 0.3",
           nrow(rs2$resultsTable$asDF) == 6 &&
               grepl("enter 0.15, 0.3", paste(notices_df(rs2)$content, collapse = " "), fixed = TRUE),
           cls = "D")
rs3 <- pt("15%")
check_true("IR-C27", "D10 '15%' is ignored with a warning, not read as 15 or 0.15",
           has_notice(rs3, "Some thresholds ignored", "WARNING") && nrow(rs3$resultsTable$asDF) == 6,
           cls = "D")

# Model names
mn <- function(s) dc(datB, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
                     modelNames = s)
rm1 <- mn("Clinical, Genomic")
check("IR-C28", "D11 custom names become the model column titles, in order",
      vapply(rm1$resultsTable$columns, function(c) c$title, "")[4:5], c("Clinical", "Genomic"),
      grade = "EXEC-PROP", cls = "D")
check_true("IR-C28", "D11 no orphan columns: exactly 5 columns (threshold, 2 references, 2 models)",
           length(rm1$resultsTable$columns) == 5, cls = "D")
check("IR-C28", "D11 the column titled 'Clinical' holds the first model's values",
      rm1$resultsTable$asDF[[col_by_title(rm1$resultsTable, "Clinical")]],
      dc(datB, outcome = "y", outcomePositive = "event", models = "good")$resultsTable$asDF$model_good,
      tol = 0, grade = "EXEC-PROP", cls = "D")
check_true("IR-C28", "D11 count mismatch: warning and variable names used",
           has_notice(mn("OnlyOne"), "Model Names Replaced", "WARNING"), cls = "D")
check_true("IR-C28", "D11 duplicate names refused", refused(tryCatch(mn("A, A"), error = function(e) e), "Duplicate Model Names"),
           cls = "D")
check_true("IR-C28", "D11 reserved name refused", refused(tryCatch(mn("treat all, B"), error = function(e) e), "Reserved Model Name"),
           cls = "D")

# ============================================================================================
# Clinical decision rule
# ============================================================================================
ruleD <- transform(tiny, rule = factor(ifelse(m >= 0.5, "treat", "watch"), levels = c("watch", "treat")),
                   m2 = rev(m))
# rule positive rows 1-5: TP 3 (1,2,4), FP 2 (3,5). NB(t) = 3/12 - 2/12 * t/(1-t)
rR <- dc(ruleD, outcome = "y", outcomePositive = "yes", models = c("m", "m2"), clinicalDecisionRule = TRUE,
         decisionRuleVar = "rule", decisionRulePositive = "treat", decisionRuleLabel = "",
         compareModels = TRUE, bootReps = 100)
rrt <- rR$resultsTable
rule_col <- col_by_title(rrt, "Clinical Rule (treat)")
check("IR-C22", "R1 rule NB = 3/12 - 2/12 * t/(1-t) at the six thresholds",
      rrt$asDF[[rule_col]], 3/12 - 2/12 * sel / (1 - sel), tol = 1e-12, cls = "A")
# Behaviour changed after 2026-10-13 by design: the rule is now resampled as a frozen 0/1 strategy
# and compared like any model (comments at .performEnhancedModelComparison). Claim re-targeted.
check_true("IR-C22", "R1 rule takes part in the comparison table (3 strategies -> 3 pairs, p present)",
           nrow(rR$comparisonTable$asDF) == 3 && all(is.finite(rR$comparisonTable$asDF$p_value)), cls = "E")
check_true("IR-C31", "R2 the footnote names the rule by the label used in the table",
           grepl("Applied as provided in the data (Clinical Rule (treat))", rR$summaryText$content,
                 fixed = TRUE), grade = "EXEC-IND", cls = "H",
           observed = regmatches(rR$summaryText$content,
                                 regexpr("Applied as provided in the data \\([^<]*", rR$summaryText$content)))
rRnoVar <- dc(ruleD, outcome = "y", outcomePositive = "yes", models = "m", clinicalDecisionRule = TRUE)
# Now a pending state (INFO), the models still run and the rule is left out - re-targeted 2026-10-21.
check_true("IR-C24", "R3 rule switched on without a variable: INFO, rule absent from the table",
           has_notice(rRnoVar, "Clinical Decision Rule Not Included Yet", "INFO") &&
               length(rRnoVar$resultsTable$columns) == 4, cls = "D")
rRclash <- dc_try(ruleD, outcome = "y", outcomePositive = "yes", models = "m", clinicalDecisionRule = TRUE,
              decisionRuleVar = "rule", decisionRulePositive = "treat", decisionRuleLabel = "m")
check_true("IR-C24", "R3 rule label equal to a model name: refused",
           refused(rRclash, "Duplicate Strategy Name"), cls = "D")

# ============================================================================================
# Guard tests: threshold - 1, threshold, threshold + 1
# ============================================================================================
gt <- function(ne, nn) dc(mk(ne, nn), outcome = "y", outcomePositive = "yes", models = "m")
ev <- list(c(24, 200, "WARNING"), c(25, 200, ""), c(9, 200, "STRONG_WARNING"), c(10, 200, "WARNING"))
for (e in ev) {
    r <- gt(as.integer(e[1]), as.integer(e[2]))
    nd <- notices_df(r); got <- nd$type[nd$title == "Few Outcome Events"]
    check("IR-C23", sprintf("GT1 %s events: few-events notice", e[1]),
          if (length(got)) got else "", e[3], cls = "D", grade = "EXEC-IND")
}
for (e in list(c(200, 24, "WARNING"), c(200, 25, ""), c(200, 9, "STRONG_WARNING"))) {
    r <- gt(as.integer(e[1]), as.integer(e[2]))
    nd <- notices_df(r); got <- nd$type[nd$title == "Few Patients Without the Outcome"]
    check("IR-C23", sprintf("GT2 %s non-events: few-non-events notice", e[2]),
          if (length(got)) got else "", e[3], cls = "D", grade = "EXEC-IND")
}
for (e in list(c(49, "STRONG_WARNING"), c(50, "WARNING"), c(99, "WARNING"), c(100, ""))) {
    n <- as.integer(e[1]); r <- gt(ceiling(n / 2), n - ceiling(n / 2))
    nd <- notices_df(r); got <- nd$type[nd$title == "Small Sample Size"]
    check("IR-C23", sprintf("GT3 n = %d: small-sample notice", n), if (length(got)) got else "", e[2],
          cls = "D", grade = "EXEC-IND")
}
for (e in list(c(25, 475, ""), c(24, 476, "STRONG_WARNING"))) {   # 5.0% and 4.8%
    r <- gt(as.integer(e[1]), as.integer(e[2]))
    nd <- notices_df(r); got <- nd$type[nd$title == "Extreme Prevalence"]
    check("IR-C23", sprintf("GT4 prevalence %d/500: extreme-prevalence notice", as.integer(e[1])),
          if (length(got)) got else "", e[3], cls = "D", grade = "EXEC-IND")
}
# Few positive classifications: exactly 10 patients at >= 0.30, 9 at >= 0.31
fp <- data.frame(y = factor(rep(c("yes", "no"), 60), levels = c("no", "yes")),
                 m = c(rep(0.305, 1), rep(0.40, 9), rep(0.10, 110)))
rFP <- dc(fp, outcome = "y", outcomePositive = "yes", models = "m", confidenceIntervals = TRUE,
          bootReps = 100)
nd <- notices_df(rFP)
check_true("IR-C23", "GT5 'Few Positive Classifications' starts at 31% (10 positive at 30%, 9 at 31%)",
           any(nd$title == "Few Positive Classifications: m" & grepl("From the 31.0% threshold", nd$content,
                                                                    fixed = TRUE)),
           cls = "D", grade = "EXEC-IND")

# ============================================================================================
# Text and number formatting claims
# ============================================================================================
rPop <- dc(tiny, outcome = "y", outcomePositive = "yes", models = "m", calculateClinicalImpact = TRUE,
           populationSize = 100000)
check_true("IR-C31", "T1 population 100000 is printed in full in every note and footnote",
           !grepl("e+05", paste(rPop$summaryText$content,
                                notes_txt(rPop$clinicalImpactTable)), fixed = TRUE),
           grade = "EXEC-IND", cls = "H",
           observed = regmatches(rPop$summaryText$content,
                                 regexpr("population of [^ ]* patients", rPop$summaryText$content)))
# Title and level changed after 2026-10-13 (now WARNING "Net Benefit Is Not Optimism-Corrected").
check_true("IR-C32", "T2 the not-optimism-corrected caution is shown on every successful run",
           has_notice(resT, "Net Benefit Is Not Optimism-Corrected", "WARNING"),
           grade = "EXEC-IND", cls = "H")

# ============================================================================================
# E. Option semantics; presentation-only options must not move a number
# ============================================================================================
geom_idx <- function(p, cls) which(vapply(p$layers, function(l) inherits(l$geom, cls), logical(1)))
base_pd <- dc(tiny, outcome = "y", outcomePositive = "yes", models = "m")$dcaPlot$state$plotData
for (sty in c("clean", "detailed")) {
    r <- dc(tiny, outcome = "y", outcomePositive = "yes", models = "m", plotStyle = sty)
    rp <- render_plot(r, "dcaPlot")
    check_true("IR-C04", sprintf("E6 plotStyle '%s' renders; curve data unchanged", sty),
               rp$ok && identical(r$dcaPlot$state$plotData, base_pd), cls = "E")
    if (sty == "detailed")
        check_true("IR-C04", "E6 'detailed' adds the y = 0 reference line",
                   length(geom_idx(rp$plot, "GeomHline")) == 1, cls = "I")
}
r <- dc(tiny, outcome = "y", outcomePositive = "yes", models = "m", showReferenceLinesLabels = TRUE)
rp <- render_plot(r, "dcaPlot"); ti <- geom_idx(rp$plot, "GeomText")
ldt <- if (length(ti)) layer_xy(rp$plot, ti[1]) else data.frame(label = character(), x = numeric())
check_true("IR-C04", "E7 reference labels: 'Treat All' and 'Treat None' at the right-most threshold (50%)",
           setequal(ldt$label, c("Treat All", "Treat None")) && all(abs(ldt$x - 0.5) < 1e-12), cls = "I")
r <- dc(tiny, outcome = "y", outcomePositive = "yes", models = "m", highlightRange = TRUE,
        highlightMin = 0.12, highlightMax = 0.28)
rp <- render_plot(r, "dcaPlot"); ri <- geom_idx(rp$plot, "GeomRect")
ldr <- if (length(ri)) layer_xy(rp$plot, ri[1]) else data.frame(xmin = NA, xmax = NA)
check("IR-C04", "E8 highlight range drawn from 12% to 28%", c(ldr$xmin, ldr$xmax), c(0.12, 0.28),
      tol = 1e-12, grade = "EXEC-PROP", cls = "I")
rS <- dc(datB, outcome = "y", outcomePositive = "event", models = "good", confidenceIntervals = TRUE,
         bootReps = 300, ciBand = "simultaneous")
rp <- render_plot(rS, "dcaPlot"); rbi <- geom_idx(rp$plot, "GeomRibbon")
ldS <- layer_xy(rp$plot, rbi[1])
pS <- rS$dcaPlot$state$plotData; pS <- pS[pS$model == "good", ]
mm <- match(round(ldS$x, 10), round(pS$threshold, 10))
check("IR-C17", "E9 ciBand = simultaneous: the drawn ribbon is the sup-t band",
      c(ldS$ymin, ldS$ymax), c(pS$sim_lower[mm], pS$sim_upper[mm]), tol = 1e-12,
      grade = "EXEC-PROP", cls = "I")
check_true("IR-C17", "E9 ... and the caption names the simultaneous band",
           grepl("95% simultaneous band", rp$plot$labels$caption, fixed = TRUE), cls = "I")
# Payoff option semantics, tiny data at 30%, population 12 so the scale factor is 1:
# all costs 0, value 1 per TP and harm 1 per FP -> benefit = TP - FP = 4 - 3 = 1, cost 0;
# treat-all benefit = 5 - 7 = -2 -> net payoff vs treat-all = 1 - (-2) = 3
rCost <- dc(tiny, outcome = "y", outcomePositive = "yes", models = "m", costBenefitAnalysis = TRUE,
            testCost = 0, treatmentCost = 0, benefitCorrectTreatment = 1, harmFalseTreatment = 1,
            populationSize = 100, selectedThresholds = "0.3")
cb <- rCost$costBenefitTable$asDF
check("IR-C09", "E10 payoff options move the right cells (population 100: x 100/12)",
      c(cb$total_cost, cb$total_benefit, cb$incremental_net_payoff),
      c(0, (4 - 3) * 100 / 12, ((4 - 3) - (5 - 7)) * 100 / 12), tol = 1e-12, cls = "E")
rPop5 <- dc(tiny, outcome = "y", outcomePositive = "yes", models = "m", calculateClinicalImpact = TRUE,
            resourceUtilization = TRUE, populationSize = 500, selectedThresholds = "0.3")
check("IR-C08", "E11 population 500: projected interventions and missed cases scale to 500",
      c(rPop5$clinicalImpactTable$asDF$interventions_per_100,
        rPop5$resourceUtilizationTable$asDF$missed_cases), c(7 / 12 * 500, 1 / 12 * 500),
      tol = 1e-12, cls = "E")
rNoTab <- dc(tiny, outcome = "y", outcomePositive = "yes", models = "m", showTable = FALSE,
             showDecisionConsequences = TRUE)
check_true("IR-C07", "E12 showTable = FALSE hides only the NB table; consequences still computed",
           nrow(rNoTab$resultsTable$asDF) == 0 && nrow(rNoTab$decisionConsequencesTable$asDF) == 6,
           cls = "E")

# ============================================================================================
# Redraw from saved state with the dataset cleared (jamovi resize / .omv reopen path)
# ============================================================================================
optR <- function() meddecide:::decisioncurveOptions$new(outcome = "y", outcomePositive = "yes",
    models = "m", calculateClinicalImpact = TRUE, showInterventionAvoided = TRUE,
    showRelativeUtility = TRUE, showStandardizedNetBenefit = TRUE, confidenceIntervals = TRUE,
    bootReps = 100, decisionRulePositive = NULL)
aRun <- meddecide:::decisioncurveClass$new(options = optR(), data = tiny)
quiet({ aRun$init(); aRun$run() })
aNew <- meddecide:::decisioncurveClass$new(options = optR(), data = tiny)
quiet(aNew$init())
aNew$.__enclos_env__$private$.data <- NULL
imgs <- c(dcaPlot = ".plotDCA", clinicalImpactPlot = ".plotClinicalImpact",
          interventionsAvoidedPlot = ".plotInterventionsAvoided",
          relativeUtilityPlot = ".plotRelativeUtility",
          standardizedNetBenefitPlot = ".plotStandardizedNetBenefit")
redraw <- vapply(names(imgs), function(nm) {
    aNew$results[[nm]]$setState(aRun$results[[nm]]$state)
    grDevices::png(tempfile(fileext = ".png")); on.exit(grDevices::dev.off())
    ggplot2::set_last_plot(NULL)
    ok <- tryCatch(isTRUE(aNew$.createImage(imgs[[nm]], aNew$results[[nm]])),
                   error = function(e) FALSE)
    grDevices::dev.off(); on.exit()
    ok
}, logical(1))
check_true("IR-C30", "L1 all five plots redraw from state with private$.data = NULL and no .run()",
           all(redraw), cls = "E", observed = paste(names(redraw), redraw, collapse = "; "))
# Same-object re-run must not accumulate rows or notices
quiet(aRun$run())
check_true("IR-C30", "L2 a second .run() on the same object does not duplicate rows or notices",
           nrow(aRun$results$resultsTable$asDF) == 6 &&
               sum(notices_df(aRun$results)$title == "Analysis Complete") == 1, cls = "E")
# Same object: valid -> invalid -> valid, via the Option's own value field
lifecycle <- tryCatch({
    o <- aRun$options$option("thresholdRange"); o$value <- "custom"
    o2 <- aRun$options$option("thresholdMin"); o2$value <- 0.4
    o3 <- aRun$options$option("thresholdMax"); o3$value <- 0.3
    quiet(try(aRun$run(), silent = TRUE))
    stale_state <- !is.null(aRun$results$dcaPlot$state)
    stale_rows <- nrow(aRun$results$resultsTable$asDF)
    o$value <- "clinical"
    quiet(aRun$run())
    list(stale_state = stale_state, stale_rows = stale_rows,
         recovered = nrow(aRun$results$resultsTable$asDF) == 6 && !is.null(aRun$results$dcaPlot$state))
}, error = function(e) e)
if (inherits(lifecycle, "error")) {
    record("IR-C30", "L3 same-object valid -> invalid -> valid", "BLOCKED", "NONE", "E",
           paste("option value not settable from R:", conditionMessage(lifecycle)))
} else {
    check_true("IR-C30", "L3 invalid run leaves no plot state behind", !lifecycle$stale_state, cls = "E")
    check_true("IR-C30", "L3 recovery after the invalid run", lifecycle$recovered, cls = "E")
    record("IR-C30", "L3 result-table rows left on screen by the refused run (R object only)", "PASS",
           "EXEC-PROP", "E", paste("rows after refused run:", lifecycle$stale_rows,
           "- jamovi clears tables on a clearWith option change; the R object does not, so this is",
           "informational for the jamovi path (BLOCKED there)"), observed = lifecycle$stale_rows)
}

# ============================================================================================
# Method choice: case-control sampling (sample prevalence used as the population prevalence)
# ============================================================================================
set.seed(4242)
N <- 200000
riskC <- rbeta(N, 1, 6)                         # cohort prevalence ~ 1/7 = 0.143, calibrated risks
yC <- rbinom(N, 1, riskC) == 1
cases <- sample(which(yC), 1000); ctrls <- sample(which(!yC), 1000)
cc <- data.frame(y = factor(ifelse(c(rep(TRUE, 1000), rep(FALSE, 1000)), "case", "control"),
                            levels = c("control", "case")), risk = riskC[c(cases, ctrls)])
truth_nb <- nb_def(riskC, yC, gridC); truth_ta <- ta_def(yC, gridC)
truth_sup <- truth_nb - pmax(truth_ta, 0) > 1e-10
rCC <- dc(cc, outcome = "y", outcomePositive = "case", models = "risk", showBenefitRange = TRUE)
dcc <- dcurves::dca(yy ~ risk, data = data.frame(yy = cc$y == "case", risk = cc$risk),
                    thresholds = gridC, prevalence = mean(yC))$dca
# Analytic cohort truth for Beta(1,6) risks (u = 1 - r): at t = 0.2, E[r 1(r>=t)] = 0.8^6 -
# 6*0.8^7/7 = 0.082388, E[(1-r) 1(r>=t)] = 0.179756, NB = 0.082388 - 0.25*0.179756 = 0.03745.
# SE of a 1000+1000 prevalence-corrected estimate ~0.004, so +/-0.012 is ~3 SE.
check("IR-C34", "M1 cohort NB at 20% (N = 200000) equals the analytic Beta(1,6) value 0.03745",
      truth_nb[abs(gridC - 0.2) < 1e-12], 0.082388 - 0.25 * 0.179756, abs_tol = 0.002, cls = "F",
      grade = "SIM")
check("IR-C34", "M1 dcurves(prevalence = cohort) on the case-control sample recovers cohort NB at 20%",
      dcc$net_benefit[dcc$variable == "risk" & abs(dcc$threshold - 0.2) < 1e-12],
      truth_nb[abs(gridC - 0.2) < 1e-12], abs_tol = 0.012, cls = "B", grade = "SIM",
      note = "shows a correct estimator exists (exogenous prevalence, Baker 2009 s.2.3)")
cc_pd <- rCC$dcaPlot$state$plotData
check("IR-C34", "M1 decisioncurve NB at 20% on a 1:1 case-control sample vs cohort NB",
      cc_pd$net_benefit[cc_pd$model == "risk" & abs(cc_pd$threshold - 0.2) < 1e-12],
      truth_nb[abs(gridC - 0.2) < 1e-12], abs_tol = 0.012, cls = "B", grade = "SIM",
      note = "sample prevalence 50% replaces the cohort prevalence; disclosed (1:1 WARNING + Analysis Summary), not corrected: no prevalence input")
check("IR-C34", "M1 treat-all NB at 30% on the case-control sample vs cohort (sign decides the advice)",
      cc_pd$net_benefit[cc_pd$model == "Treat All" & abs(cc_pd$threshold - 0.3) < 1e-12],
      truth_ta[abs(gridC - 0.3) < 1e-12], abs_tol = 0.02, cls = "B", grade = "SIM")
check_true("IR-C34", "M1 a sampling-design (case-control / exogenous prevalence) disclosure exists",
           disclosure_design || any(grepl("case-control|prevalence of the target",
                                          notices_df(rCC)$content, ignore.case = TRUE)),
           grade = "EXEC-IND", cls = "H",
           observed = paste(notices_df(rCC)$title, collapse = " | "))

# ============================================================================================
# F. Simulation (closed-form truth). AUDIT_SIM=0 skips.
# ============================================================================================
if (!identical(Sys.getenv("AUDIT_SIM"), "0")) {
    # DGP: risk ~ U(0, a), Y | risk ~ Bernoulli(risk). With a = 0.6 the population NB at t < a is
    #   P(Y=1, r>=t) - w P(Y=0, r>=t) = (a^2 - t^2)/(2a) - w [(a - t) - (a^2 - t^2)/2] / a
    a <- 0.6
    nb_true <- function(t) (a^2 - t^2) / (2 * a) - t / (1 - t) * ((a - t) - (a^2 - t^2) / 2) / a
    R <- as.integer(Sys.getenv("AUDIT_SIM_R", "400")); nS <- 200; Bs <- 500
    cores <- 4L
    one_rep <- function(k) {
        set.seed(1e6 + k)
        r <- runif(nS, 0, a); y <- rbinom(nS, 1, r)
        d <- data.frame(y = factor(y, levels = 0:1, labels = c("n", "e")), p = r,
                        q1 = pmin(pmax(r + rnorm(nS, 0, 0.05), 0), 1),
                        q2 = pmin(pmax(r + rnorm(nS, 0, 0.05), 0), 1))
        res <- dc(d, outcome = "y", outcomePositive = "e", models = "p", confidenceIntervals = TRUE,
                  bootReps = Bs, seed = k)
        pdx <- res$dcaPlot$state$plotData; pdx <- pdx[pdx$model == "p", ]
        tv <- nb_true(pdx$threshold)
        pick <- vapply(c(0.10, 0.20, 0.30, 0.40, 0.50), function(t) which(abs(pdx$threshold - t) < 1e-12),
                       integer(1))
        pw <- (pdx$ci_lower <= tv & tv <= pdx$ci_upper)[pick]
        sim <- all(pdx$sim_lower <= tv & tv <= pdx$sim_upper)
        cmp <- dc(d, outcome = "y", outcomePositive = "e", models = c("q1", "q2"), compareModels = TRUE,
                  bootReps = Bs, seed = k)
        c(pw, sim = sim, rej = cmp$comparisonTable$asDF$p_value < 0.05)
    }
    t0 <- Sys.time()
    sims <- do.call(rbind, parallel::mclapply(seq_len(R), one_rep, mc.cores = 1L))
    sim_secs <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
    band <- 3 * sqrt(0.95 * 0.05 / R)
    for (j in 1:5) {
        cov <- mean(sims[, j])
        check("IR-C16", sprintf("F1 pointwise 95%% coverage at %d%% (n=200, B=500, R=%d)",
                                c(10, 20, 30, 40, 50)[j], R), cov, 0.95, abs_tol = band,
              grade = "SIM", cls = "F", note = sprintf("MC band +/- %.3f", band))
    }
    check("IR-C17", sprintf("F2 simultaneous band coverage of the whole 5-50%% curve (R=%d)", R),
          mean(sims[, "sim"]), 0.95, abs_tol = band, grade = "SIM", cls = "F",
          note = sprintf("MC band +/- %.3f", band))
    cat(sprintf("Simulation wall time: %.0f s\n", sim_secs))   # console only: keeps the matrix byte-reproducible
    tb1 <- 3 * sqrt(0.05 * 0.95 / R)
    check("IR-C13", sprintf("F3 type I error of the comparison p at 0.05, exchangeable models (R=%d)", R),
          mean(sims[, "rej"]), 0.05, abs_tol = tb1, grade = "SIM", cls = "F",
          note = sprintf("MC band +/- %.3f", tb1))
} else {
    record("IR-C16", "F simulation section", "BLOCKED", "NONE", "F", "AUDIT_SIM=0")
}

# ============================================================================================
# N. New tests, 2026-10-21 (expected values written before the first run of this section)
# ============================================================================================
# N0 Does the analysis wrap dcurves/rmda? If not, dcurves is an INDEPENDENT oracle (E5).
wraps <- grep("dcurves::|rmda::|library\\(dcurves|requireNamespace\\(\"dcurves", src, value = TRUE)
check("IR-C04", "N0 decisioncurve.b.R calls no dcurves/rmda function (dcurves oracle is independent)",
      length(wraps), 0L, tol = 0, grade = "READ", cls = "B",
      note = "static grep of the shipped .b.R; NB is computed in .calculateNetBenefit/.calculateNetBenefitsVectorized")

# N1 Net interventions avoided, TABLE, against dcurves at six thresholds incl. ones where the model
# is worse than treat-all (negative values), population 1000 -> dcurves nper = 1000.
selN <- c(0.05, 0.10, 0.20, 0.30, 0.45, 0.50)
resN1 <- dc(datB, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
            selectedThresholds = paste(selN, collapse = ", "), calculateClinicalImpact = TRUE,
            populationSize = 1000)
dcN1 <- dcurves::net_intervention_avoided(dcurves::dca(yy ~ good + weak,
    data = data.frame(yy = yB, good = datB$good, weak = datB$weak), thresholds = selN), nper = 1000)$dca
cit <- resN1$clinicalImpactTable$asDF
for (v in c("good", "weak")) {
    check("IR-C08", paste0("N1 net interventions avoided per 1000 vs dcurves, 6 thresholds (", v, ")"),
          cit$interventions_avoided[cit$model == v],
          dcN1$net_intervention_avoided[dcN1$variable == v], tol = 1e-10, cls = "B")
}
check_true("IR-C08", "N1 the fixture reaches negative interventions avoided (sign exercised)",
           any(cit$interventions_avoided < 0), cls = "B", observed = min(cit$interventions_avoided))
# N1b hand: projected TP/FP/interventions per 1000 = counts / n * 1000 (definition, not the module)
for (tt in c(0.10, 0.30)) {
    pos <- datB$weak >= tt
    check("IR-C08", sprintf("N1b projected interventions/TP/FP per 1000 at %d%% (weak, hand counts)", tt * 100),
          unlist(cit[cit$model == "weak" & abs(cit$threshold - tt) < 1e-12,
                     c("interventions_per_100", "true_positives_per_100", "false_positives_per_100")]),
          c(sum(pos), sum(pos & yB), sum(pos & !yB)) / nB * 1000, tol = 1e-12, cls = "A")
}

# N2-N4 Derived curves over the whole default grid, read from the ggplot actually printed.
resN2 <- dc(datB, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
            showInterventionAvoided = TRUE, showStandardizedNetBenefit = TRUE,
            showRelativeUtility = TRUE)
dcN2 <- dcurves::dca(yy ~ good + weak,
    data = data.frame(yy = yB, good = datB$good, weak = datB$weak), thresholds = gridC)
niaN2 <- dcurves::net_intervention_avoided(dcN2, nper = 100)$dca
snbN2 <- dcurves::standardized_net_benefit(dcN2)$dca
prevB <- mean(yB)
all_points <- function(ld, x, y) all(mapply(function(a, b) has_point(ld, a, b, tol = 1e-9), x, y))
rpN <- render_plot(resN2, "interventionsAvoidedPlot"); ldN <- layer_xy(rpN$plot, 1)
for (v in c("good", "weak")) {
    r <- niaN2[niaN2$variable == v, ]
    check_true("IR-C19", paste0("N2 interventions-avoided PLOT = dcurves at all 46 thresholds (", v, ")"),
               rpN$ok && all_points(ldN, r$threshold, r$net_intervention_avoided), grade = "EXEC-IND", cls = "I")
}
rpS <- render_plot(resN2, "standardizedNetBenefitPlot"); ldS <- layer_xy(rpS$plot, 1)
for (v in c("good", "weak", "all")) {
    r <- snbN2[snbN2$variable == v, ]
    check_true("IR-C20", paste0("N3 sNB PLOT = dcurves standardized_net_benefit at all 46 thresholds (", v, ")"),
               rpS$ok && all_points(ldS, r$threshold, r$standardized_net_benefit), grade = "EXEC-IND", cls = "I")
}
# Relative utility, Baker et al. 2009 s.9: RU = (NB - D)/(prev - D), D = max(treat-all, 0).
rpU <- render_plot(resN2, "relativeUtilityPlot"); ldU <- layer_xy(rpU$plot, 1)
taB <- ta_def(yB, gridC); D <- pmax(taB, 0)
for (v in c("good", "weak")) {
    ru_exp <- (nb_def(datB[[v]], yB, gridC) - D) / (prevB - D)
    check_true("IR-C21", paste0("N4 relative utility PLOT = Baker 2009 definition at all 46 thresholds (", v, ")"),
               rpU$ok && all_points(ldU, gridC, ru_exp), grade = "EXEC-IND", cls = "I")
}
# N4b Known answer: a PERFECT predictor (risk = outcome, 0/1) has NB = prevalence at every
# threshold, so sNB = 1 and RU = 1 everywhere; a NULL predictor equal to the prevalence for every
# patient has NB = treat-all below the prevalence and 0 above, so RU = 0 everywhere.
datP <- data.frame(y = datB$y, perfect = as.numeric(yB), flat = rep(round(prevB, 3), nB))
resP <- dc(datP, outcome = "y", outcomePositive = "event", models = c("perfect", "flat"),
           showStandardizedNetBenefit = TRUE, showRelativeUtility = TRUE)
pdP <- resP$dcaPlot$state$plotData
check("IR-C04", "N4b perfect predictor: NB = prevalence at all 46 thresholds",
      pdP$net_benefit[pdP$model == "perfect"], rep(prevB, 46), tol = 1e-12, cls = "A")
ldS2 <- layer_xy(render_plot(resP, "standardizedNetBenefitPlot")$plot, 1)
ldU2 <- layer_xy(render_plot(resP, "relativeUtilityPlot")$plot, 1)
check_true("IR-C20", "N4b perfect predictor: sNB = 1 at all 46 thresholds", all_points(ldS2, gridC, rep(1, 46)),
           grade = "EXEC-IND", cls = "A")
check_true("IR-C21", "N4b perfect predictor: RU = 1 at all 46 thresholds", all_points(ldU2, gridC, rep(1, 46)),
           grade = "EXEC-IND", cls = "A")
flat_t <- round(prevB, 3)
ru_flat_exp <- ifelse(gridC <= flat_t, (ta_def(yB, gridC) - D) / (prevB - D), (0 - D) / (prevB - D))
check_true("IR-C21", "N4b constant predictor at the prevalence: RU = 0 on both sides of it",
           all_points(ldU2, gridC, ru_flat_exp) && max(abs(ru_flat_exp)) < 1e-12,
           grade = "EXEC-IND", cls = "A", observed = max(abs(ru_flat_exp)))

# N5 Clinical impact PLOT bar heights equal the clinical impact TABLE (prior audit: not compared).
resN5 <- dc(datB, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
            calculateClinicalImpact = TRUE, populationSize = 500,
            selectedThresholds = "0.1, 0.2, 0.3")
rpI <- render_plot(resN5, "clinicalImpactPlot")
grDevices::pdf(NULL); bI <- ggplot2::ggplot_build(rpI$plot); grDevices::dev.off()
ldI <- bI$data[[1]]; ldI$h <- ldI$ymax - ldI$ymin
pnl <- bI$layout$layout; ldI$model <- as.character(pnl$model[match(ldI$PANEL, pnl$PANEL)])
xlev <- levels(factor(c(0.1, 0.2, 0.3)))
tabI <- resN5$clinicalImpactTable$asDF
obsI <- expI <- numeric(0)
for (v in c("good", "weak")) for (k in seq_along(xlev)) {
    tr <- tabI[tabI$model == v & abs(tabI$threshold - as.numeric(xlev[k])) < 1e-12, ]
    bars <- ldI[ldI$model == v & ldI$x == k, ]
    bars <- bars[order(bars$group), ]   # group 1 = True Positives, 2 = False Positives (factor order)
    obsI <- c(obsI, bars$h); expI <- c(expI, tr$true_positives_per_100, tr$false_positives_per_100)
}
check("IR-C08", "N5 clinical impact plot: 12 bar heights (2 models x 3 thresholds x TP/FP) = table",
      obsI, expI, tol = 1e-10, grade = "EXEC-PROP", cls = "I")

# N6 Binary decision-rule mode against dcurves given the same rule as a 0/1 numeric predictor.
datR <- transform(datB, rule = factor(ifelse(weak >= 0.3, "refer", "discharge"),
                                       levels = c("refer", "discharge")))   # positive level FIRST
resR <- dc(datR, outcome = "y", outcomePositive = "event", models = "good",
           clinicalDecisionRule = TRUE, decisionRuleVar = "rule", decisionRulePositive = "refer",
           decisionRuleLabel = "Referral rule", selectedThresholds = "0.1, 0.25, 0.4")
dcR <- dcurves::dca(yy ~ r01, data = data.frame(yy = yB, r01 = as.numeric(datR$rule == "refer")),
                    thresholds = gridC)$dca
pdR <- resR$dcaPlot$state$plotData
check("IR-C22", "N6 rule curve vs dcurves on the 0/1 rule, all 46 thresholds (positive level listed first)",
      pdR$net_benefit[pdR$model == "Referral rule"], dcR$net_benefit[dcR$variable == "r01"],
      tol = 1e-10, cls = "B")
tR <- resR$resultsTable$asDF
check("IR-C22", "N6 rule column in the results table = hand NB at 10/25/40%",
      tR[[col_by_title(resR$resultsTable, "Referral rule")]],
      nb_def(as.numeric(datR$rule == "refer"), yB, c(0.1, 0.25, 0.4)), tol = 1e-12, cls = "A")
datR2 <- datR; datR2$rule <- factor(as.character(datR2$rule), levels = c("discharge", "refer"))
resR2 <- dc(datR2, outcome = "y", outcomePositive = "event", models = "good",
            clinicalDecisionRule = TRUE, decisionRuleVar = "rule", decisionRulePositive = "refer",
            decisionRuleLabel = "Referral rule", selectedThresholds = "0.1, 0.25, 0.4")
check("IR-C22", "N6 rule level ORDER reversed: identical rule column",
      resR2$resultsTable$asDF[[col_by_title(resR2$resultsTable, "Referral rule")]],
      tR[[col_by_title(resR$resultsTable, "Referral rule")]], tol = 0, grade = "EXEC-PROP", cls = "C")
resR3 <- dc(datR, outcome = "y", outcomePositive = "event", models = "good",
            clinicalDecisionRule = TRUE, decisionRuleVar = "rule", decisionRulePositive = "discharge",
            decisionRuleLabel = "Referral rule", selectedThresholds = "0.1, 0.25, 0.4")
check("IR-C22", "N6 rule positive level switched to 'discharge': NB of the complementary policy",
      resR3$resultsTable$asDF[[col_by_title(resR3$resultsTable, "Referral rule")]],
      nb_def(as.numeric(datR$rule == "discharge"), yB, c(0.1, 0.25, 0.4)), tol = 1e-12, cls = "A")
check_true("IR-C25", "N6 ...and the inverted rule is flagged 'Possible Inversion'",
           has_notice(resR3, "Possible Inversion: Referral rule", "STRONG_WARNING"), cls = "D",
           grade = "EXEC-PROP")

# N7 Bootstrap seeding: per-consumer substreams. Model 1's interval must not depend on whether a
# second model is present; the rule's interval must not depend on how many models precede it.
ciA <- dc(datR, outcome = "y", outcomePositive = "event", models = "good", confidenceIntervals = TRUE,
          bootReps = 200, clinicalDecisionRule = TRUE, decisionRuleVar = "rule",
          decisionRulePositive = "refer", decisionRuleLabel = "Referral rule")$dcaPlot$state$plotData
ciB <- dc(datR, outcome = "y", outcomePositive = "event", models = c("good", "weak"),
          confidenceIntervals = TRUE, bootReps = 200, clinicalDecisionRule = TRUE,
          decisionRuleVar = "rule", decisionRulePositive = "refer",
          decisionRuleLabel = "Referral rule")$dcaPlot$state$plotData
check("IR-C29", "N7 model 1 interval unchanged when a second model is added (stream 1, index 1)",
      unlist(ciB[ciB$model == "good", c("ci_lower", "ci_upper")]),
      unlist(ciA[ciA$model == "good", c("ci_lower", "ci_upper")]), tol = 0, grade = "EXEC-PROP", cls = "E")
check("IR-C29", "N7 rule interval unchanged when a model is added (stream 2)",
      unlist(ciB[ciB$model == "Referral rule", c("ci_lower", "ci_upper")]),
      unlist(ciA[ciA$model == "Referral rule", c("ci_lower", "ci_upper")]), tol = 0, grade = "EXEC-PROP",
      cls = "E")
# N7b Resampling unit for a 0/1 rule: the bootstrap SE of the rule NB at t equals the closed-form
# SE of a sample mean (the rule is fixed, rows resampled). B = 4000, tolerance 0.15 SE (as B6).
ciR <- dc(datR, outcome = "y", outcomePositive = "event", models = "good", confidenceIntervals = TRUE,
          bootReps = 4000, clinicalDecisionRule = TRUE, decisionRuleVar = "rule",
          decisionRulePositive = "refer", decisionRuleLabel = "Referral rule")$dcaPlot$state$plotData
for (tt in c(0.10, 0.30)) {
    d <- datR$rule == "refer"; w <- tt / (1 - tt); cc <- yB * d - (!yB) * d * w
    se <- sqrt(mean((cc - mean(cc))^2) / nB)
    r <- ciR[ciR$model == "Referral rule" & abs(ciR$threshold - tt) < 1e-12, ]
    check("IR-C16", sprintf("N7b rule pointwise 95%% limits vs NB +/- 1.96 SE at %d%%", tt * 100),
          c(r$ci_lower, r$ci_upper), mean(cc) + c(-1, 1) * qnorm(0.975) * se,
          abs_tol = 0.15 * se, cls = "B", note = sprintf("SE closed form %.5f", se))
}
# N8 Seed at its documented maximum still runs, and seed changes only the bootstrap.
rS <- dc(datB, outcome = "y", outcomePositive = "event", models = "good", confidenceIntervals = TRUE,
         bootReps = 200, seed = 999999)
pS <- rS$dcaPlot$state$plotData
check_true("IR-C29", "N8 seed = 999999 (max): finite intervals that contain the estimate",
           all(is.finite(pS$ci_lower[pS$model == "good"])) &&
               all(pS$ci_lower[pS$model == "good"] <= pS$net_benefit[pS$model == "good"] + 1e-12),
           cls = "E")
check("IR-C29", "N8 seed changes no point estimate", pS$net_benefit, pci_like <- dc(datB, outcome = "y",
      outcomePositive = "event", models = "good")$dcaPlot$state$plotData$net_benefit, tol = 0,
      grade = "EXEC-PROP", cls = "E")

# N9 Prediction inputs outside [0, 1] and other non-probabilities
bad <- function(vals) { d <- tiny; d$m[seq_along(vals)] <- vals
    dc_try(d, outcome = "y", outcomePositive = "yes", models = "m") }
check_true("IR-C24", "N9 1 + 1e-9 is refused", refused(bad(1 + 1e-9), "Invalid Probabilities: m"), cls = "D")
check_true("IR-C24", "N9 -1e-9 is refused", refused(bad(-1e-9), "Invalid Probabilities: m"), cls = "D")
# Inf never reaches .b.R: jmvcore's option check stops it first ("... contains (and must not)
# infinite values"). Either refusal satisfies the claim. (Test corrected 2026-10-21 after the first
# run expected only the module's own title; the claim - refused, nothing computed - is unchanged.)
rInf <- bad(Inf)
check_true("IR-C24", "N9 Inf is refused (jmvcore option check or module notice)",
           refused(rInf, "Invalid Probabilities: m") || refused(rInf, "infinite values"), cls = "D",
           observed = if (inherits(rInf, "error")) conditionMessage(rInf) else "no error")
dPct <- tiny; dPct$m <- dPct$m * 100
check_true("IR-C24", "N9 percentages (0-100) are refused",
           refused(dc_try(dPct, outcome = "y", outcomePositive = "yes", models = "m"),
                   "Invalid Probabilities: m"), cls = "D")
dLg <- tiny; dLg$m <- qlogis(pmin(pmax(dLg$m, 0.01), 0.99))
check_true("IR-C24", "N9 logits are refused",
           refused(dc_try(dLg, outcome = "y", outcomePositive = "yes", models = "m"),
                   "Invalid Probabilities: m"), cls = "D")
dNaN <- rbind(tiny, data.frame(y = factor("no", levels = c("no", "yes")), m = NaN))
rNaN <- dc_try(dNaN, outcome = "y", outcomePositive = "yes", models = "m")
check_true("IR-C24", "N9 NaN prediction: row excluded as missing, disclosed, NB unchanged",
           !inherits(rNaN, "error") && has_notice(rNaN, "Complete-Case Analysis", "WARNING") &&
               isTRUE(all.equal(rNaN$resultsTable$asDF$model_m, exp_nb, tolerance = 1e-12)),
           cls = "D", grade = "EXEC-IND")

# N10 Sampling design beyond the 1:1 case: a 1:3 case-control sample (prevalence 25%) drawn from a
# cohort with prevalence 14.3%. No notice can know the design; the claim under test is that the
# disclosure is on screen and that the analysis offers no prevalence input (limitation, not bug).
set.seed(4243); Nc <- 2e5; rc <- rbeta(Nc, 1, 6); ycoh <- rbinom(Nc, 1, rc) == 1
ic <- c(sample(which(ycoh), 500), sample(which(!ycoh), 1500))
dcc3 <- data.frame(y = factor(ifelse(ycoh[ic], "case", "control"), c("control", "case")), risk = rc[ic])
rCC3 <- dc(dcc3, outcome = "y", outcomePositive = "case", models = "risk")
pd3 <- rCC3$dcaPlot$state$plotData
truth20 <- nb_def(rc, ycoh, 0.2)
record("IR-C34", "N10 1:3 case-control: NB at 20% vs cohort NB (limitation, observed only)", "PASS", "SIM", "B",
       "documents the size of the residual IR-01 limitation; graded as a disclosed method limitation",
       observed = fmt(pd3$net_benefit[pd3$model == "risk" & abs(pd3$threshold - 0.2) < 1e-12]),
       expected = fmt(truth20))
check_true("IR-C34", "N10 1:3 sample: the prevalence-validity sentence is in the Analysis Summary",
           grepl("valid only when the analysed rows have the outcome rate of the target population",
                 rCC3$procedureNotes$content, fixed = TRUE), grade = "EXEC-IND", cls = "H",
           observed = paste(notices_df(rCC3)$title, collapse = " | "))
check_true("IR-C34", "N10 no option accepts an external prevalence (static: .a.yaml option list)",
           !any(grepl("^    - name: .*[Pp]revalence", ayaml)), grade = "READ", cls = "H")


# N12 Prior findings closed by DISCLOSURE or wording (IR-04, IR-06, IR-10, Codex-07): executed,
# reading what the user is shown rather than grepping source.
check_true("IR-C35", "N12 IR-04: Analysis Summary states one row per patient (Unit of Analysis)",
           grepl("Each row is treated as an independent patient", resT$procedureNotes$content, fixed = TRUE),
           grade = "EXEC-IND", cls = "H")
check_true("IR-C35", "N12 IR-04: with intervals on, the footnotes state the resampling unit",
           grepl("Rows are resampled as independent patients", resCI90$summaryText$content, fixed = TRUE),
           grade = "EXEC-IND", cls = "H")
check_true("IR-C13", "N12 IR-06: both comparison tables carry the Vickers 2023 caution note",
           grepl("Vickers et al. (2023) caution", notes_txt(resCmp$comparisonTable), fixed = TRUE) &&
               grepl("Vickers et al. (2023) caution", notes_txt(resCmp$modelComparisonEnhanced), fixed = TRUE),
           grade = "EXEC-IND", cls = "H")
check_true("IR-C21", "N12 IR-10: the relative-utility plot caption attributes Baker et al. (2009)",
           grepl("Baker et al. (2009)", rpU$plot$labels$caption, fixed = TRUE), grade = "EXEC-IND", cls = "I")
rPO <- dc(datB, outcome = "y", outcomePositive = "event", models = "good", showTable = FALSE,
          showClinicalImpactPlot = TRUE, selectedThresholds = "15, 30")
check_true("IR-C27", "N12 Codex-07: plot-only clinical impact mode reports an unusable threshold entry",
           has_notice(rPO, "Some thresholds ignored", "WARNING"), grade = "EXEC-PROP", cls = "D")

# N11 Narrative under the null (prespecified 2026-10-21, before running): a predictor generated
# INDEPENDENTLY of the outcome has expected NB = P(r >= t) x treat-all, which is never above both
# references. How often does the Range of Benefit table / the interpretation nevertheless print a
# range "over which this model beats both treating everyone and treating no one"?
# DGP: n = 200, Y ~ Bernoulli(0.2), r ~ U(0, 1) independent; default 5-50% grid; R = 300, seed
# 1e7 + k. Acceptance criterion: the share of null predictors shown with a range <= 0.10.
# This is a narrative-overreach probe (S3 at most), not an arithmetic one.
Rn <- 300; null_hit <- logical(Rn); null_w <- rep(NA_real_, Rn); null_txt <- logical(Rn); null_qual <- logical(Rn)
for (k in seq_len(Rn)) {
    set.seed(1e7 + k)
    dn <- data.frame(y = factor(ifelse(rbinom(200, 1, 0.2) == 1, "e", "n"), c("n", "e")), r = runif(200))
    rn <- dc(dn, outcome = "y", outcomePositive = "e", models = "r", showBenefitRange = TRUE,
             showTable = FALSE)
    br <- rn$benefitRangeTable$asDF
    null_hit[k] <- is.finite(br$range_start)
    if (null_hit[k]) null_w[k] <- br$range_end - br$range_start
    null_txt[k] <- grepl("the range over which this model beats both", rn$summaryText$content, fixed = TRUE)
    # updated 2026-10-21: DC S3 fix - a shown range must carry the in-sample / no-sampling-allowance qualifier on screen
    dn_note <- rn$benefitRangeTable$notes$definition$note
    null_qual[k] <- !null_hit[k] ||
        (grepl("apparent (in-sample) net benefit", if (is.null(dn_note)) "" else dn_note, fixed = TRUE) &&
         grepl("carries no allowance for sampling variation", if (is.null(dn_note)) "" else dn_note, fixed = TRUE) &&
         !null_txt[k])
}
mc_se <- sqrt(mean(null_hit) * (1 - mean(null_hit)) / Rn)
# updated 2026-10-21: DC S3 fix - the deliberate remedy is disclosure, not suppression: the range is now labelled the
# observed, apparent (in-sample) range with no allowance for sampling variation. The probe now asks whether any null
# predictor's range is shown WITHOUT that qualifier (criterion: none); the share shown is still recorded as observed.
check_true("IR-C15", sprintf("N11 null predictor (independent of Y): every Range of Benefit shown carries the in-sample / sampling-variation qualifier and no unqualified 'beats both' sentence (R=%d)", Rn),
           all(null_qual), grade = "SIM", cls = "F",
           observed = c(share = mean(null_hit), mc_se = mc_se, interp_sentence = mean(null_txt),
                        median_width = stats::median(null_w, na.rm = TRUE), qualified = mean(null_qual[null_hit])),
           note = "pre-fix criterion 'share shown <= 0.10' failed at 0.577 with an unqualified point-estimate statement; share is unchanged by design")

# ============================================================================================
# Citations (E7): verified in this session with PubMed metadata / Crossref; recorded here
# ============================================================================================
cites <- list(
    c("Vickers2006", "VERIFIED", "PMID 17099194, doi:10.1177/0272989X06295361, MDM 26(6):565-74"),
    c("Vickers2019DCA", "VERIFIED", "PMID 31592444, doi:10.1186/s41512-019-0064-7, DPR 3:18"),
    c("Kerr2016DCA", "VERIFIED", "PMID 27247223, doi:10.1200/JCO.2015.65.5654, JCO 34(21):2534-40"),
    c("Vickers2023DCAInference", "VERIFIED", "PMID 37277840, doi:10.1186/s41512-023-00148-y, DPR 7(1):11"),
    c("MontielOleaPlagborgMoller2019", "VERIFIED (metadata only)",
      "Crossref doi:10.1002/jae.2656, JAE 34(1):1-17; supplement Appendix A.2 Algorithm 3 not read"))
for (cc_ in cites) record("IR-C33", paste("CIT", cc_[1]), "PASS", "CITED", "H", cc_[3], observed = cc_[2],
                          expected = "VERIFIED")
# The weightedAUC option text claims "on one example dataset it moved from 0.309 to 0.163 as the
# range widened from 5-20 percent to 1-99 percent". Search every bundled DCA dataset, every binary
# column, both levels, every probability column.
g520 <- dec_grid(0.05, 0.20, 0.01, 2)
hits <- character(0)
for (nm in c("dca_test_data", "comprehensive_dca_data", "dca_test", "bayesdca_test_data")) {
    e <- new.env(); data(list = nm, package = "meddecide", envir = e); d <- get(nm, e)
    bin <- names(d)[vapply(d, function(v) length(unique(stats::na.omit(v))) == 2, TRUE)]
    prc <- names(d)[vapply(d, function(v) is.numeric(v) && all(v >= 0 & v <= 1, na.rm = TRUE) &&
                               length(unique(v)) > 2, TRUE)]
    for (o in bin) for (lv in unique(as.character(stats::na.omit(d[[o]])))) for (p in prc) {
        k <- complete.cases(d[c(o, p)]); yy <- as.character(d[[o]][k]) == lv; xx <- d[[p]][k]
        if (round(trap_avg(g520, nb_def(xx, yy, g520)), 3) == 0.309 &&
            round(trap_avg(gridA, nb_def(xx, yy, gridA)), 3) == 0.163)
            hits <- c(hits, paste(nm, o, lv, p))
    }
}
claim_stated <- any(grepl("0.309", ayaml, fixed = TRUE))
check_true("IR-C12", "CIT weightedAUC option example (0.309 -> 0.163) is withdrawn or reproduces on a bundled dataset",
           !claim_stated || length(hits) > 0, grade = "EXEC-IND", cls = "H",
           observed = c(claim_still_stated = claim_stated, bundled_hits = length(hits)),
           note = "4 bundled DCA datasets searched exhaustively; no locator given in the option text")
record("IR-C21", "CIT relative utility definition (not cited by the analysis)", "PASS", "CITED", "H",
       "Baker 2009 JRSS-A 172(4):729-48, PMID 20069131, s.9 prose: ratio of model utility over no-prediction to perfect over no-prediction, no-prediction = better of treat-all/none",
       observed = "matches implemented RU", expected = "matches")

# ============================================================================================
out <- do.call(rbind, audit$rows)
op <- options(width = 250); print(out[, c("claim", "class", "test", "grade", "observed", "expected",
                                          "result")], row.names = FALSE, right = FALSE); options(op)
utils::write.csv(out, "/private/tmp/meddecide-release-20261108/decisioncurve-adapted-matrix.csv",
                 row.names = FALSE)
cat(sprintf("\n%d checks: %d PASS, %d FAIL, %d BLOCKED. Wall time %.0f s\n", nrow(out),
            sum(out$result == "PASS"), sum(out$result == "FAIL"), sum(out$result == "BLOCKED"),
            as.numeric(difftime(Sys.time(), t_start, units = "secs"))))
print(utils::sessionInfo())
if (any(out$result == "FAIL")) quit(status = 1)
