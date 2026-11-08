# Independent audit of meddecide::lassologistic (meddecide 1.1.1, commit 403e034), 2026-10-21.
# Audit only. Loads the shipped sibling, calls the public wrapper, compares with independent
# oracles written below (FISTA penalized logistic, hand AUC/DeLong/Youden/Brier, IRLS slope).
# Run: LANG=en_US.UTF-8 Rscript --vanilla development-scripts/audit_lassologistic_2026-10-21.R
# Writes the matrix CSV; exits 1 on any FAIL.

suppressPackageStartupMessages(pkgload::load_all("/Users/serdarbalci/Documents/GitHub/meddecide",
                                                 quiet = TRUE, export_all = TRUE))
OUT_CSV <- "/private/tmp/meddecide-release-20261108/lassologistic-matrix.csv"
set.seed(20261021)
quiet <- function(expr) suppressWarnings(suppressMessages(force(expr)))
fmt <- function(x) paste(base::format(x, digits = 12), collapse = ", ")
audit <- new.env(); audit$rows <- list()
check <- function(id, cls, claim, observed, expected, tol = 1e-8, grade = "EXEC-IND",
                  note = "", abs_tol = FALSE) {
  ok <- if (is.numeric(expected) && is.numeric(observed) && length(observed) == length(expected)) {
    if (abs_tol) isTRUE(all(is.finite(observed)) && max(abs(observed - expected)) <= tol)
    else {
      sc <- if (all(is.finite(expected)) && all(expected != 0)) abs(expected) else NULL
      isTRUE(all.equal(unname(observed), unname(expected), tolerance = tol, scale = sc,
                       check.attributes = FALSE))
    }
  } else identical(unname(observed), unname(expected))
  d <- if (is.numeric(observed) && is.numeric(expected) && length(observed) == length(expected))
    max(abs(observed - expected)) else NA_real_
  audit$rows[[length(audit$rows) + 1L]] <- data.frame(
    id, class = cls, claim, grade, observed = fmt(observed), expected = fmt(expected),
    max_abs_diff = d, tol, result = if (ok) "PASS" else "FAIL", note, stringsAsFactors = FALSE)
  invisible(ok)
}
blocked <- function(id, cls, claim, note) {
  audit$rows[[length(audit$rows) + 1L]] <- data.frame(
    id, class = cls, claim, grade = "NONE", observed = "", expected = "", max_abs_diff = NA_real_,
    tol = NA_real_, result = "BLOCKED", note, stringsAsFactors = FALSE)
}
strip <- function(x) gsub('^"|"$', "", x)
row_of <- function(df, key) {
  i <- which(strip(rownames(df)) == key); if (length(i) != 1) stop("row ", key, " not unique")
  df[i, , drop = FALSE]
}
notes_text <- function(tbl) paste(vapply(tbl$notes, function(x) x$note, ""), collapse = " ")
plain <- function(html) gsub("\\s+", " ", gsub("<[^>]+>", " ", html))
# do.call with evaluated values: the wrapper resolves outcome/explanatory by NSE, and a bare symbol
# such as `outcome` would be looked up as a column name.
LL <- function(data, outcome, outcomeLevel, explanatory, ...)
  quiet(do.call(meddecide::lassologistic, c(list(data = data, outcome = outcome,
        outcomeLevel = outcomeLevel, explanatory = explanatory), list(...))))

# ---------------------------------------------------------------- independent oracles
# glmnet objective (binomial): (1/n) sum[log(1+e^eta) - y eta] + lambda[alpha|b|_1 + (1-alpha)/2 |b|^2],
# intercept unpenalized, penalty on columns scaled by the POPULATION (1/n) SD when standardize.
# Solved by FISTA with adaptive restart; no glmnet code involved.
or_scale <- function(X, standardize) {
  mu <- colMeans(X)
  s <- if (standardize) sqrt(colMeans(sweep(X, 2, mu)^2)) else rep(1, ncol(X))
  list(mu = mu, s = s, Z = sweep(sweep(X, 2, mu), 2, s, "/"))
}
or_fit <- function(X, y, lambda, alpha, standardize = TRUE, maxit = 400000, tol = 1e-14) {
  sc <- or_scale(X, standardize); Z <- sc$Z; n <- nrow(Z); p <- ncol(Z)
  A <- cbind(1, Z)
  L <- 0.25 * max(eigen(crossprod(A) / n, symmetric = TRUE, only.values = TRUE)$values) +
       lambda * (1 - alpha)
  soft <- function(z, t) sign(z) * pmax(abs(z) - t, 0)
  grad <- function(th) {
    pr <- plogis(drop(A %*% th))
    g <- drop(crossprod(A, pr - y)) / n
    g[-1] <- g[-1] + lambda * (1 - alpha) * th[-1]
    g
  }
  obj <- function(th) {
    eta <- drop(A %*% th)
    mean(log1p(exp(-abs(eta))) + pmax(eta, 0) - y * eta) +
      lambda * (alpha * sum(abs(th[-1])) + (1 - alpha) / 2 * sum(th[-1]^2))
  }
  th <- c(qlogis(mean(y)), rep(0, p)); zv <- th; tk <- 1; f_old <- obj(th)
  for (it in seq_len(maxit)) {
    g <- grad(zv)
    nt <- zv - g / L
    nt[-1] <- soft(nt[-1], lambda * alpha / L)
    f_new <- obj(nt)
    if (f_new > f_old) { zv <- th; tk <- 1; next }          # adaptive restart
    tk1 <- (1 + sqrt(1 + 4 * tk^2)) / 2
    zv <- nt + ((tk - 1) / tk1) * (nt - th)
    if (max(abs(nt - th)) < tol && it > 50) { th <- nt; break }
    th <- nt; tk <- tk1; f_old <- f_new
  }
  braw <- th[-1] / sc$s
  list(b0 = th[1] - sum(braw * sc$mu), b = stats::setNames(braw, colnames(X)), kkt = or_kkt(X, y, th[1] - sum(braw * sc$mu), braw, lambda, alpha, standardize))
}
# KKT residual of ANY raw-scale solution, on the scaled problem (subgradient optimality).
or_kkt <- function(X, y, b0, braw, lambda, alpha, standardize = TRUE) {
  sc <- or_scale(X, standardize); bz <- braw * sc$s
  pr <- plogis(b0 + drop(X %*% braw))
  g <- drop(crossprod(sc$Z, pr - y)) / nrow(X) + lambda * (1 - alpha) * bz
  r <- ifelse(abs(bz) > 0, abs(g + lambda * alpha * sign(bz)), pmax(abs(g) - lambda * alpha, 0))
  c(slopes = max(r), intercept = abs(mean(pr - y)))
}
or_auc <- function(y, s) {               # Mann-Whitney with ties counted 1/2
  pos <- s[y == 1]; neg <- s[y == 0]
  mean(outer(pos, neg, ">") + 0.5 * outer(pos, neg, "=="))
}
or_delong <- function(y, s) {            # DeLong 1988 placement variance, Wald 95% CI
  pos <- s[y == 1]; neg <- s[y == 0]; m <- length(pos); k <- length(neg)
  psi <- outer(pos, neg, ">") + 0.5 * outer(pos, neg, "==")
  v10 <- rowMeans(psi); v01 <- colMeans(psi); a <- mean(psi)
  se <- sqrt(var(v10) / m + var(v01) / k)
  c(a - qnorm(0.975) * se, a, a + qnorm(0.975) * se)
}
or_youden <- function(y, s) {            # all thresholds between distinct scores, ">=" rule
  u <- sort(unique(s)); th <- c(-Inf, (u[-1] + u[-length(u)]) / 2, Inf)
  J <- vapply(th, function(t) mean(s[y == 1] >= t) + mean(s[y == 0] < t) - 1, 0)
  list(J = max(J), th = th[J == max(J)])
}
or_irls_slope <- function(y, p) {        # logistic regression of y on logit(p), Newton-Raphson
  x <- qlogis(p); b <- c(0, 1)
  for (i in 1:100) {
    mu <- plogis(b[1] + b[2] * x); W <- mu * (1 - mu); Xm <- cbind(1, x)
    step <- solve(crossprod(Xm, Xm * W), crossprod(Xm, y - mu)); b <- b + drop(step)
    if (max(abs(step)) < 1e-12) break
  }
  b[2]
}
# oracle self-tests (closed forms)
local({
  # intercept-only: lambda above lambda_max gives b = 0, b0 = qlogis(ybar)
  X0 <- cbind(a = c(1, 2, 3, 4, 5, 6, 7, 8), b = c(2, 1, 2, 1, 2, 1, 2, 1)); y0 <- c(0, 0, 1, 0, 1, 1, 0, 1)
  f0 <- or_fit(X0, y0, lambda = 10, alpha = 1)
  check("O01", "A", "oracle: lambda > lambda_max -> intercept-only qlogis(ybar)",
        c(f0$b0, f0$b), c(qlogis(mean(y0)), 0, 0), tol = 1e-10, abs_tol = TRUE)
  # one standardized predictor, lambda = 0: equals unpenalized IRLS logistic MLE
  x1 <- c(-1.2, -0.4, 0.1, 0.3, 0.8, 1.5, -0.7, 2.0); y1 <- c(0, 0, 1, 0, 1, 1, 1, 1)
  f1 <- or_fit(matrix(x1, dimnames = list(NULL, "x")), y1, lambda = 1e-12, alpha = 1)
  b <- c(0, 0); for (i in 1:50) { mu <- plogis(b[1] + b[2] * x1); Xm <- cbind(1, x1)
    b <- b + drop(solve(crossprod(Xm, Xm * (mu * (1 - mu))), crossprod(Xm, y1 - mu))) }
  check("O02", "A", "oracle: lambda -> 0 equals Newton MLE", c(f1$b0, f1$b), b, tol = 1e-6, abs_tol = TRUE)
  check("O03", "A", "oracle: own KKT residual", max(f0$kkt, f1$kkt), 0, tol = 1e-9, abs_tol = TRUE)
  check("O04", "A", "oracle AUC on hand table (pos 3,2,2; neg 2,1): (2+2*1.5+... )/6",
        or_auc(c(1, 1, 1, 0, 0), c(3, 2, 2, 2, 1)), (1 + 1 + 0.5 + 1 + 0.5 + 1) / 6)
})

# ---------------------------------------------------------------- fixtures
mk_main <- function(n = 200, seed = 11) {
  set.seed(seed)
  d <- data.frame(x1 = rnorm(n), x2 = rnorm(n, 50, 10) * 100, x3 = rnorm(n), x4 = rnorm(n),
                  grade = factor(sample(c("G1", "G2", "G3"), n, TRUE), levels = c("G1", "G2", "G3"),
                                 ordered = TRUE),
                  marker = factor(sample(c("neg", "pos"), n, TRUE), levels = c("neg", "pos")))
  eta <- -0.6 + 1.1 * d$x1 - 0.0008 * (d$x2 - 5000) + 0.9 * (d$grade == "G3") + 0.8 * (d$marker == "pos")
  d$dx <- factor(ifelse(rbinom(n, 1, plogis(eta)) == 1, "Malignant", "Benign"),
                 levels = c("Benign", "Malignant"))
  d
}
d <- mk_main()
expl <- c("x1", "x2", "x3", "x4", "grade", "marker")
# independent design matrix: treatment dummies for the ordered factor too, built by hand
Xh <- cbind(x1 = d$x1, x2 = d$x2, x3 = d$x3, x4 = d$x4,
            gradeG2 = as.numeric(d$grade == "G2"), gradeG3 = as.numeric(d$grade == "G3"),
            markerpos = as.numeric(d$marker == "pos"))
yh <- as.numeric(d$dx == "Malignant")

coef_of <- function(r) {
  cf <- r$coefficients$asDF
  b <- stats::setNames(rep(0, ncol(Xh)), colnames(Xh))
  sel <- cf[strip(rownames(cf)) != "intercept" & cf$variable != "No variables selected", ]
  b[sel$variable] <- sel$coefficient
  list(b0 = row_of(cf, "intercept")$coefficient, b = b, names = sel$variable)
}
lam_of <- function(r, rule) if (rule == "lambda.min") r$cv_plot$state$lambda_min else r$cv_plot$state$lambda_1se
preds_of <- function(r) unlist(r$predictions$.__enclos_env__$private$.values)

# ---------------------------------------------------------------- A: known answers vs oracle
cases <- list(
  list(id = "A01", pen = "lasso", al = 1, rule = "lambda.min", std = TRUE),
  list(id = "A02", pen = "lasso", al = 1, rule = "lambda.1se", std = TRUE),
  list(id = "A03", pen = "ridge", al = 0, rule = "lambda.min", std = TRUE),
  list(id = "A04", pen = "elasticnet", al = 0.5, rule = "lambda.1se", std = TRUE),
  list(id = "A05", pen = "lasso", al = 1, rule = "lambda.min", std = FALSE))
res <- list()
for (cs in cases) {
  r <- LL(d, "dx", "Malignant", expl, penalty = cs$pen, alpha = 0.5, lambda = cs$rule,
          standardize = cs$std, nfolds = 5)
  res[[cs$id]] <- r
  m <- coef_of(r); lam <- lam_of(r, cs$rule)
  o <- or_fit(Xh, yh, lam, cs$al, cs$std)
  tag <- sprintf("%s %s std=%s", cs$pen, cs$rule, cs$std)
  # coefficient tolerance prespecified on the per-SD scale (glmnet thresh = 1e-7 is a deviance
  # change criterion, not a parameter bound): |b_module - b_oracle| * SD <= 5e-4
  sdp <- sqrt(colMeans(sweep(Xh, 2, colMeans(Xh))^2))
  check(paste0(cs$id, "a"), "A", paste("per-SD coefficients vs FISTA oracle,", tag),
        m$b * sdp, o$b * sdp, tol = 5e-4, abs_tol = TRUE, note = sprintf("oracle KKT %.2e", max(o$kkt)))
  check(paste0(cs$id, "b"), "A", paste("intercept on logit scale vs oracle (via linear predictor),", tag),
        mean(m$b0 + Xh %*% m$b), mean(o$b0 + Xh %*% o$b), tol = 5e-4, abs_tol = TRUE)
  check(paste0(cs$id, "c"), "A", paste("selected set equals oracle nonzero set,", tag),
        sort(m$names), sort(names(o$b)[abs(o$b * sdp) > 1e-6]), grade = "EXEC-IND")
  pm <- preds_of(r)
  check(paste0(cs$id, "d"), "A", paste("saved probabilities vs oracle probabilities,", tag),
        pm, as.numeric(plogis(o$b0 + Xh %*% o$b)), tol = 2e-4, abs_tol = TRUE)
  k <- or_kkt(Xh, yh, m$b0, m$b, lam, cs$al, cs$std)
  check(paste0(cs$id, "e"), "A", paste("module solution satisfies KKT (independent gradient),", tag),
        max(k), 0, tol = 1e-3 * max(lam, 1e-3), abs_tol = TRUE,
        note = "tol = 1e-3 * lambda on the mean-loss gradient scale")
}
r0 <- res$A01; m0 <- coef_of(r0); p0 <- preds_of(r0)

# G: displayed coefficients reproduce saved probabilities exactly; OR = exp(coef)
check("G01", "G", "plogis(intercept + X b) from displayed table == saved probabilities",
      as.numeric(plogis(m0$b0 + Xh %*% m0$b)), p0, tol = 1e-10, abs_tol = TRUE, grade = "EXEC-PROP")
cf0 <- r0$coefficients$asDF; cf0 <- cf0[strip(rownames(cf0)) != "intercept", ]
check("G02", "G", "odds ratio == exp(coefficient)", cf0$oddsRatio, exp(cf0$coefficient), grade = "EXEC-PROP")
check("A06", "A", "mean predicted probability == event prevalence (intercept score equation)",
      mean(p0), mean(yh), tol = 1e-3, abs_tol = TRUE)
# Importance = per-sample-SD |b| / max
sds <- apply(Xh, 2, sd)
imp_exp <- abs(m0$b[cf0$variable]) * sds[cf0$variable]; imp_exp <- imp_exp / max(imp_exp)
check("A07", "A", "Importance == |b| x sample SD normalised (unit-free)", cf0$importance, unname(imp_exp),
      tol = 1e-10, abs_tol = TRUE)
check("A08", "A", "ordered factor coded by treatment contrasts (gradeG2/gradeG3, no .L/.Q)",
      any(grepl("\\.L$|\\.Q$", r0$coefficients$asDF$variable)), FALSE, grade = "EXEC-PROP")
check("A09", "H", "reference-level note names grade = G1 and marker = neg",
      all(c(grepl("grade = G1", notes_text(r0$coefficients)),
            grepl("marker = neg", notes_text(r0$coefficients)) | !("markerpos" %in% m0$names))), TRUE,
      grade = "EXEC-PROP")

# Performance metrics
pf <- r0$performance$asDF
dl <- or_delong(yh, p0)
check("A10", "A", "apparent AUC cell vs Mann-Whitney + DeLong hand CI (3 dp)",
      row_of(pf, "auc")$value, sprintf("%.3f (%.3f-%.3f)", dl[2], dl[1], dl[3]))
yd <- or_youden(yh, p0)
sens <- as.numeric(row_of(pf, "sensitivity")$value); spec <- as.numeric(row_of(pf, "specificity")$value)
check("A11", "A", "displayed sens+spec-1 equals the maximum Youden over all thresholds",
      sens + spec - 1, yd$J, tol = 1.5e-3, abs_tol = TRUE, note = "displayed at 3 dp")
thr <- min(yd$th); cls <- as.numeric(p0 >= thr)
tp <- sum(cls & yh == 1); fp <- sum(cls & yh == 0); fn <- sum(!cls & yh == 1)
check("A12", "A", "accuracy, precision, F1 at the Youden threshold (3 dp)",
      c(row_of(pf, "accuracy")$value, row_of(pf, "precision")$value, row_of(pf, "f1")$value),
      sprintf("%.3f", c(mean(cls == yh), tp / (tp + fp), 2 * tp / (2 * tp + fp + fn))),
      note = sprintf("%d Youden-maximising thresholds; lowest used", length(yd$th)))
check("A13", "A", "Brier score (4 dp)", row_of(pf, "brier")$value, sprintf("%.4f", mean((p0 - yh)^2)))
check("H01", "H", "AUC row is labelled apparent", grepl("apparent", row_of(pf, "auc")$metric), TRUE,
      grade = "EXEC-PROP")
check("H02", "H", "AUC CI note says it ignores fitting/selection", grepl("does not account for fitting",
      notes_text(r0$performance)), TRUE, grade = "EXEC-PROP")

# ---------------------------------------------------------------- B: lambda rules
cvs <- r0$cv_plot$state
check("B01", "B", "lambda.min == argmin CV deviance (state)", cvs$lambda_min,
      cvs$lambda[which.min(cvs$cvm)], grade = "EXEC-PROP")
i_min <- which.min(cvs$cvm)
check("B02", "B", "lambda.1se == largest lambda with cvm <= cvm_min + cvsd_min (glmnet documented rule)",
      cvs$lambda_1se, max(cvs$lambda[cvs$cvm <= cvs$cvm[i_min] + cvs$cvsd[i_min]]), grade = "EXEC-PROP")
check("B03", "B", "1SE model has no more terms than min model (same folds)",
      length(coef_of(res$A02)$names) <= length(m0$names), TRUE, grade = "EXEC-PROP",
      note = "A02 uses the same seed/folds as A01")

# ---------------------------------------------------------------- C: metamorphic / seeds
dk <- d; dk$x1 <- dk$x1 * 1000
rk <- LL(dk, "dx", "Malignant", expl, lambda = "lambda.min", nfolds = 5)
mk <- coef_of(rk)
check("C01", "C", "x1 x1000 under standardize: coef(x1) scales by 1/1000, others unchanged",
      c(mk$b["x1"] * 1000, mk$b[-1]), c(m0$b["x1"], m0$b[-1]), tol = 1e-6, grade = "EXEC-PROP")
check("C02", "C", "x1 x1000: identical lambda and saved probabilities",
      c(lam_of(rk, "lambda.min"), preds_of(rk)), c(lam_of(r0, "lambda.min"), p0), tol = 1e-7,
      grade = "EXEC-PROP")
rs <- LL(d, "dx", "Malignant", expl, lambda = "lambda.min", nfolds = 5)
check("C03", "C", "same seed -> identical lambda and probabilities", c(lam_of(rs, "lambda.min"), preds_of(rs)),
      c(lam_of(r0, "lambda.min"), p0), tol = 0, abs_tol = TRUE, grade = "EXEC-PROP")
seeds <- c(1, 2, 3, 4, 5)
lams <- vapply(seeds, function(s) lam_of(LL(d, "dx", "Malignant", expl, lambda = "lambda.min", nfolds = 5,
                                            random_seed = s), "lambda.min"), 0)
check("C04", "C", "different seeds change the fold split (lambda.min not all equal)",
      length(unique(signif(lams, 10))) > 1, TRUE, grade = "EXEC-PROP", note = fmt(lams))
set.seed(99); before <- .Random.seed
invisible(LL(d, "dx", "Malignant", expl, nfolds = 5))
check("C05", "C", "global RNG state untouched by the analysis", identical(before, .Random.seed), TRUE,
      grade = "EXEC-PROP")
rev_r <- LL(d, "dx", "Benign", expl, lambda = "lambda.min", nfolds = 5)
mr <- coef_of(rev_r)
check("C06", "C", "event = Benign: mean saved prob == P(Benign); x1 coefficient changes sign",
      c(mean(preds_of(rev_r)), sign(mr$b["x1"])), c(1 - mean(yh), -sign(m0$b["x1"])), tol = 1e-3,
      abs_tol = TRUE, grade = "EXEC-IND", note = "folds differ with the label swap, so only sign/closed form tested")
dp <- d[sample(nrow(d)), ]
rp <- LL(dp, "dx", "Malignant", expl, lambda = "lambda.min", nfolds = 5)
op <- or_fit(Xh[as.integer(rownames(dp)), ], yh[as.integer(rownames(dp))], lam_of(rp, "lambda.min"), 1)
check("C07", "C", "row permutation: fit still equals oracle at its own CV lambda",
      coef_of(rp)$b * sqrt(colMeans(sweep(Xh, 2, colMeans(Xh))^2)),
      op$b * sqrt(colMeans(sweep(Xh, 2, colMeans(Xh))^2)), tol = 5e-4, abs_tol = TRUE,
      note = "lambda legitimately depends on row order through the random folds")

# ---------------------------------------------------------------- D: boundaries
# D01 zero selected predictors (lead from orchestrator)
set.seed(2); n0 <- 100
dn <- as.data.frame(matrix(rnorm(n0 * 5), n0, dimnames = list(NULL, paste0("n", 1:5)))); dn$y <- rbinom(n0, 1, 0.4)
rn <- LL(dn, "y", NULL, paste0("n", 1:5), showSummary = TRUE)
mn <- rn$coefficients$asDF
check("D01a", "D", "0 selected: table says 'No variables selected'", mn$variable[1], "No variables selected",
      grade = "EXEC-PROP")
check("D01b", "D", "0 selected: intercept == qlogis(ybar) (intercept-only MLE)",
      row_of(mn, "intercept")$coefficient, qlogis(mean(dn$y)), tol = 1e-6)
check("D01c", "D", "0 selected: AUC shown as 0.500 with no CI", row_of(rn$performance$asDF, "auc")$value,
      "0.500 (CI not estimable)", grade = "EXEC-IND")
check("D01d", "D", "0 selected: STRONG_WARNING 'No Variables Selected' shown",
      grepl("No Variables Selected", rn$notices$content), TRUE, grade = "EXEC-PROP")
check("D01e", "D", "0 selected: coef_plot visible with NULL state (renderer draws nothing)",
      c(rn$coef_plot$visible, is.null(rn$coef_plot$state)), c(TRUE, TRUE), grade = "EXEC-PROP")
all_text <- paste(plain(rn$notices$content), notes_text(rn$coefficients), notes_text(rn$performance),
                  plain(rn$summaryText$content))
check("D01f", "D", "0 selected: some output tells the user the Coefficient Plot is empty and why",
      grepl("plot", all_text, ignore.case = TRUE) && grepl("coefficient plot", all_text, ignore.case = TRUE),
      TRUE, grade = "EXEC-PROP", note = "searched notices, coefficient/performance notes, summary")
a_cp <- meddecide:::lassologisticClass$new(
  options = meddecide:::lassologisticOptions$new(outcome = "y", outcomeLevel = NULL, explanatory = paste0("n", 1:5)),
  data = dn)
quiet({a_cp$init(); a_cp$run()})
ret <- a_cp$.__enclos_env__$private$.coefPlot(a_cp$results$coef_plot, ggplot2::theme_grey(),
                                              list(palette = "jmv", color = c("#333333", "#333333")))
check("D01g", "D", "0 selected: .coefPlot returns FALSE (blank panel in jamovi)", ret, FALSE, grade = "EXEC-PROP")
check("D01h", "H", "0 selected: summary says no term retained",
      grepl("No term was retained", plain(rn$summaryText$content)), TRUE, grade = "EXEC-PROP")

pfn <- rn$performance$asDF
check("D01i", "H", "0 selected: the 0.500 fallback threshold is not labelled 'Youden index'",
      row_of(pfn, "threshold")$interpretation != "Youden index", TRUE, grade = "EXEC-PROP",
      note = paste0("value ", row_of(pfn, "threshold")$value, "; note says a default of 0.500 was used: ",
                    grepl("A default of 0.500 was used", notes_text(rn$performance))))
check("D01j", "D", "0 selected: saved column is the constant base rate (no fabricated ranking)",
      range(preds_of(rn)), rep(mean(dn$y), 2), tol = 1e-8, abs_tol = TRUE)

# D02 exact null (prior A01 boundary): balanced 12 rows, identical predictor distribution per class
dz <- data.frame(a = rep(c(1, 2, 3), 4), b = rep(c(5, 5, 7, 7, 9, 9), 2),
                 y = rep(c(0, 1), each = 6))
dz$a <- c(1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3); dz$b <- c(5, 7, 9, 5, 7, 9, 5, 7, 9, 5, 7, 9)
rz <- tryCatch(LL(dz, "y", NULL, c("a", "b"), nfolds = 3), error = function(e) e)
check("D02", "D", "exact-null data: analysis completes with every probability 0.5 (prior A01)",
      if (inherits(rz, "error")) conditionMessage(rz) else round(range(preds_of(rz)), 12), c(0.5, 0.5),
      tol = 1e-12, abs_tol = TRUE)

# D03 minority-class guard at 4 / 5
mk_min <- function(k) { set.seed(5); dd <- data.frame(u = rnorm(40), v = rnorm(40)); dd$y <- c(rep(1, k), rep(0, 40 - k)); dd }
e4 <- tryCatch(LL(mk_min(4), "y", NULL, c("u", "v")), error = function(e) conditionMessage(e))
r5 <- tryCatch(LL(mk_min(5), "y", NULL, c("u", "v")), error = function(e) conditionMessage(e))
check("D03", "D", "4 events refused with counts; 5 events fitted with folds capped at 5",
      c(is.character(e4) && grepl("4 events", e4), !is.character(r5) &&
          row_of(r5$modelSummary$asDF, "12")$value == "5"), c(TRUE, TRUE), grade = "EXEC-PROP")

# D04 perfect separation
set.seed(7); ds <- data.frame(s = c(rnorm(30, -2, .3), rnorm(30, 2, .3)), t = rnorm(60)); ds$y <- rep(0:1, each = 30)
rsep <- LL(ds, "y", NULL, c("s", "t"), nfolds = 5)
check("D04", "D", "complete separation: AUC flagged, CI not shown, perfect-separation notice",
      c(row_of(rsep$performance$asDF, "auc")$value, grepl("Perfect Apparent Separation", rsep$notices$content)),
      c("1.000 (CI not estimable)", "TRUE"), grade = "EXEC-PROP")

# D05 numeric outcome coded 1/2 -> pending, nothing fitted; 0/1 -> event = 1 (checked in D01)
d12 <- dn; d12$y <- d12$y + 1
r12 <- LL(d12, "y", NULL, paste0("n", 1:5))
check("D05", "D", "1/2-coded numeric outcome without event level: pending, no rows fitted",
      c(grepl("Choose the event level", r12$todo$content), nrow(r12$coefficients$asDF) == 0), c(TRUE, TRUE),
      grade = "EXEC-PROP")

# D06 (prior IR-01) tiny units: re-apply the PUBLISHED rule to raw data, compare lookup N per score
set.seed(401)
dt <- data.frame(x1 = seq(.00001, .00040, length.out = 240), x2 = rnorm(240))
dt$y <- rbinom(240, 1, plogis(-3 + 15000 * dt$x1 + .3 * dt$x2))
rt <- LL(dt, "y", NULL, c("x1", "x2"), lambda = "lambda.min", nfolds = 5, scoringSystem = TRUE)
st <- rt$scoringTable$asDF; lk <- rt$lookupTable$asDF
award <- function(v, crit) {
  if (crit == "present") return(v == max(v))
  op <- sub("^([>=]) .*", "\\1", crit); val <- as.numeric(sub("^[>=] ", "", crit))
  if (op == ">") v > val else v == val
}
tot <- Reduce(`+`, lapply(seq_len(nrow(st)), function(i) award(dt[[st$variable[i]]], st$criterion[i]) * st$points[i]))
tab <- table(tot)
check("D06", "D", "published criteria reapplied to raw data reproduce the lookup table's N per score",
      as.integer(tab[as.character(lk$score)]), as.integer(lk$n_cases), grade = "EXEC-IND",
      note = paste("criteria:", paste(st$variable, st$criterion, collapse = "; ")))

# D07 (prior IR-05) factor/numeric name collision with a manual cut
set.seed(14)
dc <- data.frame(Tumor = factor(sample(c("Low", "High"), 400, TRUE), levels = c("High", "Low")), TumorLow = rnorm(400))
dc$y <- rbinom(400, 1, plogis(-.5 + 1.5 * (dc$Tumor == "Low") + 1.2 * dc$TumorLow))
rc <- LL(dc, "y", NULL, c("Tumor", "TumorLow"), lambda = "lambda.min", nfolds = 5, scoringSystem = TRUE,
         scoreCutMethod = "manual", scoreCutPoints = "TumorLow=1")
sc <- rc$scoringTable$asDF
check("D07", "D", "manual cut for numeric TumorLow is applied (> 1) despite dummy-name collision",
      sort(sc$criterion), sort(c("present", "> 1")), grade = "EXEC-IND",
      note = paste(sc$variable, sc$criterion, collapse = "; "))

# D08 (prior IR-L-03) manual cut above every value
rm_ <- LL(d, "dx", "Malignant", expl, lambda = "lambda.min", nfolds = 5, scoringSystem = TRUE,
          scoreCutMethod = "manual", scoreCutPoints = "x1=1000")
cr <- rm_$scoringTable$asDF
check("D08", "D", "manual cut x1=1000 (above max) is not published; moved inside data and disclosed",
      c(any(cr$criterion == "> 1000"), grepl("left no case on one side", notes_text(rm_$scoringTable))),
      c(FALSE, TRUE), grade = "EXEC-PROP")

# D09 (prior IR-04) repeated patients
dr <- d[rep(1:60, each = 3), ]; dr$pid <- rep(1:60, each = 3)
er <- tryCatch(LL(dr, "dx", "Malignant", expl, patientID = "pid"), error = function(e) conditionMessage(e))
check("D09", "D", "repeated patient IDs are refused", is.character(er) && grepl("Repeated patient IDs", er), TRUE,
      grade = "EXEC-PROP")
rsum <- LL(dr, "dx", "Malignant", expl, showSummary = TRUE, nfolds = 5)
check("D10", "H", "without IDs, the copy-ready sentence counts observations, not patients",
      c(grepl("independent observations", plain(rsum$summaryText$content)),
        grepl("patients", plain(rsum$summaryText$content))), c(TRUE, FALSE), grade = "EXEC-PROP")

# D11 (prior IR-06) penalty labels under ridge
rr <- LL(d, "dx", "Malignant", expl, penalty = "ridge", showModelComparison = TRUE, scoringSystem = TRUE,
         scoringMethod = "compare", nfolds = 5)
mc <- rr$modelComparison$asDF; smc <- rr$methodComparison$asDF
check("D11a", "H", "ridge: model-comparison row 1 says Ridge", mc$model_type[1], "Ridge (L2) (penalized)",
      grade = "EXEC-PROP")
check("D11b", "H", "ridge: scoring method comparison reference row does not call the model LASSO",
      grepl("LASSO", row_of(smc, "full")$method), FALSE, grade = "EXEC-PROP",
      note = row_of(smc, "full")$method)

# D12 (prior IR-07) stale methodology after the event is unset
dfac <- d
a7 <- meddecide:::lassologisticClass$new(options = meddecide:::lassologisticOptions$new(
  outcome = "dx", outcomeLevel = NULL, explanatory = expl, showMethodologyNotes = TRUE), data = dfac)
quiet(a7$init()); a7$results$methodologyNotes$setContent("<p>STALE previous fit</p>"); quiet(a7$run())
check("D12", "E", "pending event: methodology panel from a previous fit is cleared",
      a7$results$methodologyNotes$content, "", grade = "EXEC-PROP")

# D13 (prior IR-03) preprocessing inside folds: trace what cv.glmnet receives
caps <- list()
trace_fun <- function(...) { a <- list(...); caps[[length(caps) + 1L]] <<- list(sd = apply(a$x, 2, sd), std = a$standardize, n = nrow(a$x)) }
suppressMessages(trace(glmnet::cv.glmnet, tracer = quote(trace_fun(x = x, standardize = list(...)$standardize)),
                       print = FALSE, where = asNamespace("glmnet")))
assign("trace_fun", trace_fun, envir = globalenv())
rb_ <- LL(d, "dx", "Malignant", expl, bootstrapValidation = TRUE, bootstrapN = 50, nfolds = 5)
suppressMessages(untrace(glmnet::cv.glmnet, where = asNamespace("glmnet")))
check("D13", "D", "every cv.glmnet call (main + bootstrap) gets RAW x with standardize=TRUE (scaling learned per fit/fold)",
      c(length(caps) >= 2, all(vapply(caps, function(z) isTRUE(z$std) && z$sd[["x2"]] > 100, TRUE))),
      c(TRUE, TRUE), grade = "EXEC-PROP", note = sprintf("%d calls traced", length(caps)))

# D14 non-syntactic / non-ASCII names, saved predictions under a filter
dnn <- d; names(dnn)[names(dnn) == "x1"] <- "Ki-67 (%)"; names(dnn)[names(dnn) == "x3"] <- "Gréade sc"
expl2 <- c("Ki-67 (%)", "x2", "Gréade sc", "x4", "grade", "marker")
rnn <- LL(dnn, "dx", "Malignant", expl2, lambda = "lambda.min", nfolds = 5)
check("D14", "D", "non-syntactic names: same fit as plain names, no backticks in labels",
      c(preds_of(rnn), any(grepl("`", rnn$coefficients$asDF$variable))), c(p0, 0), tol = 1e-10,
      abs_tol = TRUE, grade = "EXEC-PROP")
dfl <- d[-(1:25), ]
rfl <- LL(dfl, "dx", "Malignant", expl, lambda = "lambda.min", nfolds = 5)
mfl <- coef_of(rfl); priv <- rfl$predictions$.__enclos_env__$private
xfl <- Xh[-(1:25), ]
check("D15", "D", "filtered data: Output row numbers are the data's row names and values belong to those rows",
      c(as.numeric(priv$.rowNums), preds_of(rfl)), c(as.numeric(rownames(dfl)), as.numeric(plogis(mfl$b0 + xfl %*% mfl$b))),
      tol = 1e-10, abs_tol = TRUE, grade = "EXEC-PROP")

# D18 missing values: predictions stay on their own rows, excluded rows get NA
dm <- d; dm$x1[c(3, 7)] <- NA; dm$dx[c(11)] <- NA
rm2 <- LL(dm, "dx", "Malignant", expl, lambda = "lambda.min", nfolds = 5)
mm2 <- coef_of(rm2); keep <- setdiff(seq_len(nrow(dm)), c(3, 7, 11))
pm2 <- preds_of(rm2); exp2 <- rep(NA_real_, nrow(dm)); exp2[keep] <- plogis(mm2$b0 + Xh[keep, ] %*% mm2$b)
check("D18", "D", "rows with a missing predictor/outcome get NA; others keep their own prediction",
      c(is.na(pm2[c(3, 7, 11)]), pm2[keep]), c(rep(TRUE, 3), exp2[keep]), tol = 1e-10, abs_tol = TRUE,
      grade = "EXEC-PROP")

# D16 EPV guard at the threshold: p = 2 terms, minority 20 -> EPV 10 (green); 19 -> 9.5 (yellow)
mk_epv <- function(k) { set.seed(8); dd <- data.frame(u = rnorm(100), v = rnorm(100)); dd$y <- c(rep(1, k), rep(0, 100 - k)); dd }
ep <- vapply(c(19, 20, 21), function(k) paste(LL(mk_epv(k), "y", NULL, c("u", "v"))$suitabilityReport$asDF$result, collapse=" "), "")
check("D16", "D", "EPV bands at 9.5 / 10 / 10.5", c(grepl("EPV = 9.5 \\(5-10", ep[1]),
      grepl("EPV = 10.0 \\(meets", ep[2]), grepl("EPV = 10.5 \\(meets", ep[3])), c(TRUE, TRUE, TRUE),
      grade = "EXEC-PROP")
check("D17", "H", "suitability text frames EPV as convention and points to Riley criteria",
      grepl("Riley et al. 2019, 2020", ep[2]) && grepl("conventions", ep[2]), TRUE, grade = "EXEC-PROP")

# ---------------------------------------------------------------- E: bootstrap
vt <- rb_$validationTable$asDF
check("E01", "G", "corrected = apparent - optimism (all three rows)", vt$corrected, vt$apparent - vt$optimism,
      tol = 1e-12, abs_tol = TRUE, grade = "EXEC-PROP")
check("E02", "G", "bootstrap apparent AUC/Brier equal the performance table", c(vt$apparent[1], vt$apparent[2]),
      c(or_auc(yh, preds_of(rb_)), mean((preds_of(rb_) - yh)^2)), tol = 1e-12, abs_tol = TRUE)
check("E03", "A", "apparent calibration slope vs hand Newton-Raphson", vt$apparent[3],
      or_irls_slope(yh, pmin(pmax(preds_of(rb_), 1e-6), 1 - 1e-6)), tol = 1e-7)
rb2 <- LL(d, "dx", "Malignant", expl, bootstrapValidation = TRUE, bootstrapN = 50, nfolds = 5)
check("E04", "E", "bootstrap deterministic under the same seed", rb2$validationTable$asDF$corrected, vt$corrected,
      tol = 0, abs_tol = TRUE, grade = "EXEC-PROP")
check("E05", "H", "probability note warns penalized probabilities are pulled toward base rate",
      grepl("pulls them toward the overall event rate", notes_text(r0$performance)), TRUE, grade = "EXEC-PROP")

# ---------------------------------------------------------------- F: small simulation
# Prespecified: R = 30 datasets, n = 150, 8 candidates (3 true), lambda.min, B = 50, external n = 5000.
# Acceptance: |mean(corrected AUC - external AUC)| <= max(3 * MCSE, 0.02); apparent shown for contrast.
set.seed(777)
sim <- t(vapply(seq_len(30), function(i) {
  gen <- function(n) { X <- matrix(rnorm(n * 8), n, dimnames = list(NULL, paste0("v", 1:8)))
    data.frame(X, y = rbinom(n, 1, plogis(-0.4 + 0.8 * X[, 1] - 0.6 * X[, 2] + 0.5 * X[, 3]))) }
  tr <- gen(150); te <- gen(5000)
  rr_ <- LL(tr, "y", NULL, paste0("v", 1:8), lambda = "lambda.min", bootstrapValidation = TRUE,
            bootstrapN = 50, random_seed = 1000 + i)
  m <- rr_$coefficients$asDF; m <- m[!(m$variable %in% c("No variables selected")), ]
  b0 <- row_of(m, "intercept")$coefficient; m <- m[strip(rownames(m)) != "intercept", ]
  lp <- b0 + if (nrow(m)) as.matrix(te[, m$variable, drop = FALSE]) %*% m$coefficient else 0
  v <- rr_$validationTable$asDF
  c(app = v$apparent[1], cor = v$corrected[1], ext = or_auc(te$y, drop(lp)))
}, c(app = 0, cor = 0, ext = 0)))
bias_c <- sim[, "cor"] - sim[, "ext"]; bias_a <- sim[, "app"] - sim[, "ext"]
mcse <- sd(bias_c) / sqrt(nrow(sim))
check("F01", "F", "bootstrap-corrected AUC unbiased for external AUC (R=30)", abs(mean(bias_c)) <= max(3 * mcse, 0.02),
      TRUE, grade = "SIM", note = sprintf("bias corrected %.4f (MCSE %.4f); bias apparent %.4f (MCSE %.4f)",
      mean(bias_c), mcse, mean(bias_a), sd(bias_a) / sqrt(nrow(sim))))

blocked("X01", "E", "protobuf serialization / .omv reopen of all results", "RProtoBuf not installed; orchestrator engine harness covers redraw")
blocked("X02", "I", "client display of blank Coefficient Plot panel when 0 terms selected", "needs jamovi GUI")

out <- do.call(rbind, audit$rows)
print(out[, c("id", "result", "claim", "observed", "expected", "note")], row.names = FALSE, right = FALSE)
utils::write.csv(out, OUT_CSV, row.names = FALSE)
cat(sprintf("\nTOTAL %d  PASS %d  FAIL %d  BLOCKED %d\n", nrow(out), sum(out$result == "PASS"),
            sum(out$result == "FAIL"), sum(out$result == "BLOCKED")))
print(sapply(c("glmnet", "pROC", "jmvcore", "withr", "meddecide"), function(p) as.character(packageVersion(p))))
print(utils::sessionInfo())
if (any(out$result == "FAIL")) quit(status = 1)
