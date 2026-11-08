# Independent review of meddecide::nogoldstandard - 2026-10-21
# Audit only. Loads the shipped meddecide source (commit 403e034) and calls the public wrapper.
# Run from anywhere:  LANG=en_US.UTF-8 Rscript --vanilla development-scripts/audit_nogoldstandard_2026-10-21.R
# Writes development-ideas/nogoldstandard-independent-review-2026-10-21-matrix.csv; exits 1 on any FAIL.
suppressPackageStartupMessages(pkgload::load_all("/Users/serdarbalci/Documents/GitHub/meddecide",
                                                 quiet = TRUE, export_all = TRUE))
ROOT <- "/Users/serdarbalci/Documents/GitHub/ClinicoPathJamoviModule"
OUT <- "/private/tmp/meddecide-release-20261108/nogoldstandard-matrix.csv"
quiet <- function(expr) suppressWarnings(suppressMessages(force(expr)))
fmt <- function(x) paste(base::format(x, digits = 10), collapse = "; ")
audit <- new.env(); audit$rows <- list()
check <- function(id, cls, purpose, observed, expected, tol = 1e-8, grade = "EXEC-IND",
                  note = "", pass = NULL) {
  if (is.null(pass)) {
    sc <- if (is.numeric(expected) && all(is.finite(expected)) && all(expected != 0)) abs(expected) else NULL
    pass <- isTRUE(all.equal(unname(observed), unname(expected), tolerance = tol, scale = sc,
                             check.attributes = FALSE))
  }
  d <- if (is.numeric(observed) && is.numeric(expected) && length(observed) == length(expected))
         suppressWarnings(max(abs(observed - expected))) else NA_real_
  audit$rows[[length(audit$rows) + 1L]] <- data.frame(id, class = cls, purpose, grade,
    observed = fmt(observed), expected = fmt(expected), max_abs_diff = d, tol,
    result = if (isTRUE(pass)) "PASS" else "FAIL", note, stringsAsFactors = FALSE)
  invisible(pass)
}
record <- function(id, cls, purpose, result, note, grade = "NONE")
  audit$rows[[length(audit$rows) + 1L]] <- data.frame(id, class = cls, purpose, grade,
    observed = "", expected = "", max_abs_diff = NA_real_, tol = NA_real_, result, note,
    stringsAsFactors = FALSE)

# ---------------------------------------------------------------- data + wrapper helpers
fac <- function(v) factor(v, levels = 0:1, labels = c("neg", "pos"))
from_counts <- function(counts, k, nm = paste0("T", seq_len(k))) {
  g <- expand.grid(rep(list(0:1), k)); names(g) <- nm      # first column varies fastest
  d <- g[rep(seq_len(nrow(g)), counts), , drop = FALSE]; rownames(d) <- NULL
  d[] <- lapply(d, fac); d
}
sim <- function(n, p, se, sp) {
  dz <- rbinom(n, 1, p)
  x <- sapply(seq_along(se), function(j) ifelse(dz == 1, rbinom(n, 1, se[j]), rbinom(n, 1, 1 - sp[j])))
  x <- as.data.frame(x); names(x) <- paste0("T", seq_along(se)); x[] <- lapply(x, fac); x
}
run <- function(d, method = "latent_class", pos = "pos", ...) {
  k <- ncol(d); a <- list(data = d, method = method)
  pos <- rep_len(pos, k)
  for (j in 1:5) {
    a[paste0("test", j)] <- list(if (j <= k) names(d)[j] else NULL)
    a[paste0("test", j, "Positive")] <- list(if (j <= k) pos[j] else NULL)
  }
  quiet(do.call(meddecide::nogoldstandard, c(a, list(...))))
}
est <- function(r) {
  tm <- r$test_metrics$asDF; mf <- tryCatch(r$model_fit$asDF, error = function(e) NULL)
  list(prev = r$prevalence$asDF$estimate[1], se = tm$sensitivity, sp = tm$specificity,
       ppv = tm$ppv, npv = tm$npv, tm = tm,
       ll = if (!is.null(mf)) mf$value[mf$statistic == "Log-Likelihood"] else NA_real_,
       g2 = if (!is.null(mf)) mf$value[mf$statistic == "G-squared"] else NA_real_,
       df = if (!is.null(mf)) mf$value[mf$statistic == "Degrees of Freedom"] else NA_real_,
       notes = paste(r$notices$content, collapse = " "))
}
vec <- function(e) c(e$prev, e$se, e$sp)
has <- function(txt, pattern) grepl(pattern, txt, fixed = TRUE)

# ---------------------------------------------------------------- independent oracle
# Written from the model definition, NOT from the backend: pattern-level EM for the two-class
# binary latent-class model, random multistart, then a central-difference gradient check.
# par = (pi, q1[1..k], q0[1..k]); q = P(test+ | class). Orientation: class 1 has the larger
# mean q (the documented naming convention), applied after fitting.
or_patterns <- function(k) as.matrix(expand.grid(rep(list(0:1), k)))
or_counts <- function(d) {
  x <- sapply(d, function(v) as.integer(v == "pos")); k <- ncol(x)
  tabulate(1L + as.vector(x %*% 2^(0:(k - 1))), 2^k)
}
or_comp <- function(par, P) {
  k <- ncol(P); q1 <- par[1 + 1:k]; q0 <- par[1 + k + 1:k]
  f1 <- exp(as.vector(P %*% log(q1) + (1 - P) %*% log(1 - q1)))   # prod_j q^x (1-q)^(1-x)
  f0 <- exp(as.vector(P %*% log(q0) + (1 - P) %*% log(1 - q0)))
  list(a = par[1] * f1, b = (1 - par[1]) * f0)
}
or_ll <- function(par, cnt, P) { z <- or_comp(par, P); u <- cnt > 0; sum(cnt[u] * log(z$a[u] + z$b[u])) }
or_pen <- function(par, cnt, P) { k <- ncol(P); or_ll(par, cnt, P) + sum(log(par[1 + 1:k])) + sum(log(1 - par[1 + k + 1:k])) }
or_estep <- function(par, P) { z <- or_comp(par, P); z$a / (z$a + z$b) }
or_em <- function(par, cnt, P, it, map = FALSE, tol = 1e-13) {
  k <- ncol(P); n <- sum(cnt)
  for (i in seq_len(it)) {
    w <- or_estep(par, P); n1 <- sum(cnt * w); n0 <- n - n1
    x1 <- colSums(P * cnt * w); x0 <- colSums(P * cnt * (1 - w))
    # M-step. MAP: Beta(2,1) on q1 (mode (x+1)/(n+1)), Beta(1,2) on q0 (mode x/(n+1)), Beta(1,1) on pi.
    nx <- if (map) c(n1 / n, (x1 + 1) / (n1 + 1), x0 / (n0 + 1)) else c(n1 / n, x1 / n1, x0 / n0)
    nx <- pmin(pmax(nx, 1e-15), 1 - 1e-15)
    if (max(abs(nx - par)) < tol) { par <- nx; break }
    par <- nx
  }
  par
}
or_orient <- function(par, k) {
  if (mean(par[1 + 1:k]) < mean(par[1 + k + 1:k])) par <- c(1 - par[1], par[1 + k + 1:k], par[1 + 1:k])
  par
}
or_fit <- function(cnt, k, nstart = 60, map = FALSE, seed = 1) {
  P <- or_patterns(k); obj <- if (map) or_pen else or_ll
  set.seed(seed)
  starts <- lapply(seq_len(nstart), function(i) c(runif(1, .1, .9), runif(2 * k, .05, .95)))
  short <- lapply(starts, or_em, cnt = cnt, P = P, it = 1500, map = map)
  vals <- vapply(short, obj, numeric(1), cnt = cnt, P = P)
  top <- order(-vals)[1:3]
  long <- lapply(short[top], or_em, cnt = cnt, P = P, it = 100000, map = map)
  lv <- vapply(long, obj, numeric(1), cnt = cnt, P = P)
  par <- long[[which.max(lv)]]
  if (!map) par <- or_orient(par, k)
  h <- 1e-6; free <- which(par > 1e-6 & par < 1 - 1e-6)
  grad <- vapply(free, function(j) { e <- replace(numeric(length(par)), j, h)
    (obj(par + e, cnt, P) - obj(par - e, cnt, P)) / (2 * h) }, numeric(1))
  list(par = par, ll = or_ll(par, cnt, P), obj = max(lv), grad = if (length(grad)) max(abs(grad)) else 0)
}
as_disp <- function(par, k) c(par[1], par[1 + 1:k], 1 - par[1 + k + 1:k])  # displayed Sp = 1 - q0
or_g2 <- function(par, cnt, P) { z <- or_comp(par, P); e <- sum(cnt) * (z$a + z$b); u <- cnt > 0
  2 * sum(cnt[u] * log(cnt[u] / e[u])) }
or_wilson <- function(x, n, a = .05) { z <- qnorm(1 - a / 2); p <- x / n
  c((p + z^2 / (2 * n) - z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2))) / (1 + z^2 / n),
    (p + z^2 / (2 * n) + z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2))) / (1 + z^2 / n)) }

# ---- O0: oracle E-step verified by hand.
# pi=.25, q1=(.8,.6,.9), q0=(.1,.2,.3), pattern (1,0,1):
# class1 .25*.8*.4*.9 = .072 ; class0 .75*.1*.8*.3 = .018 ; posterior .072/.09 = .8
P3 <- or_patterns(3)
check("O0", "A", "oracle E-step, hand arithmetic", or_estep(c(.25, .8, .6, .9, .1, .2, .3), P3)[6], 0.8,
      note = "pattern row 6 = (1,0,1)")

# ================================================================ A. KNOWN ANSWERS (closed form)
# A1: exact 3-test mixture. pi=.25, Se=(.8,.6,.9), Sp=(.9,.8,.7). N=4000 makes every expected
# count an integer, so empirical = model probabilities and the saturated-model MLE IS the truth.
truth3 <- c(.25, .8, .6, .9, .1, .2, .3)
z <- or_comp(truth3, P3); cnt3 <- 4000 * (z$a + z$b)
stopifnot(max(abs(cnt3 - round(cnt3))) < 1e-9); cnt3 <- round(cnt3)
d3 <- from_counts(cnt3, 3)
e3 <- est(r3 <- run(d3))
check("A1-prev", "A", "3-test exact mixture: class proportion = truth", e3$prev, .25, 1e-6)
check("A1-se", "A", "3-test exact mixture: P(T+|C+) = truth", e3$se, c(.8, .6, .9), 1e-6)
check("A1-sp", "A", "3-test exact mixture: P(T-|C-) = truth", e3$sp, c(.9, .8, .7), 1e-6)
check("A1-df", "A", "3 tests: residual df = 2^3-1-7 = 0", e3$df, 0)
check("A1-g2", "A", "3 tests exact fit: G2 = 0", e3$g2, 0, tol = 1e-8, pass = abs(e3$g2) < 1e-8,
      note = "display shows tiny negative values (-1e-13) - cosmetic")
check("A1-ppv", "G", "PPV = Bayes(prev, Se, Sp) from displayed values",
      e3$ppv, e3$prev * e3$se / (e3$prev * e3$se + (1 - e3$prev) * (1 - e3$sp)), 1e-10, "EXEC-PROP")
check("A1-npv", "G", "NPV = Bayes(prev, Se, Sp) from displayed values",
      e3$npv, (1 - e3$prev) * e3$sp / ((1 - e3$prev) * e3$sp + e3$prev * (1 - e3$se)), 1e-10, "EXEC-PROP")
bv3 <- r3$conditional_dependence$asDF
check("A1-bvr", "A", "3 tests interior exact fit: every BVR verdict 'Not assessable'",
      sum(grepl("Not assessable", bv3$verdict)), 3)

# A2: exact 4-test mixture, N=40000 (all expected counts integers): MLE = truth, G2 = 0, df = 6.
truth4 <- c(.25, .8, .6, .9, .7, .1, .2, .3, .2)
P4 <- or_patterns(4); z <- or_comp(truth4, P4); cnt4 <- 40000 * (z$a + z$b)
stopifnot(max(abs(cnt4 - round(cnt4))) < 1e-9); cnt4 <- round(cnt4)
e4 <- est(run(from_counts(cnt4, 4)))
check("A2-par", "A", "4-test exact mixture: all 9 parameters = truth",
      vec(e4), c(.25, .8, .6, .9, .7, .9, .8, .7, .8), 1e-6)
check("A2-df", "A", "4 tests: residual df = 15-9 = 6", e4$df, 6)

# A3: tiny dataset (n = 24, 4 tests) vs independent EM oracle (log-likelihood must not be lower)
set.seed(11); dt <- sim(24, .4, c(.9, .8, .85, .7), c(.9, .85, .8, .9))
or_t <- or_fit(or_counts(dt), 4); et <- est(rt <- run(dt))
check("A3-ll", "B", "n=24: wrapper log-likelihood >= oracle best (multistart EM)",
      et$ll, or_t$ll, pass = et$ll >= or_t$ll - 1e-6,
      note = sprintf("oracle grad %.2e; estimable=%s", or_t$grad, is.finite(et$prev)))
if (is.finite(et$prev)) check("A3-par", "B", "n=24: parameters equal oracle MLE", vec(et), as_disp(or_t$par, 4), 1e-4)

# ================================================================ B. REFERENCE PARITY vs oracle
set.seed(2026); db <- sim(800, .3, c(.9, .75, .85, .7, .8), c(.9, .95, .85, .95, .8))
for (k in 3:5) {
  dk <- db[, 1:k]; ok <- or_fit(or_counts(dk), k); ek <- est(run(dk))
  check(sprintf("B1-ll-k%d", k), "B", sprintf("k=%d sim n=800: log-likelihood = oracle", k), ek$ll, ok$ll, 1e-8,
        note = sprintf("oracle |grad| %.2e", ok$grad))
  check(sprintf("B1-par-k%d", k), "B", sprintf("k=%d sim n=800: 2k+1 parameters = oracle MLE", k),
        vec(ek), as_disp(ok$par, k), tol = 1e-5, pass = max(abs(vec(ek) - as_disp(ok$par, k))) < 1e-5,
        note = "tol 1e-5 abs: EM linear convergence + wrapper score tol 1e-7")
}
# B2: penalized EM ('bayesian') vs oracle MAP-EM with the documented Beta(2,1) penalties
for (k in c(3, 5)) {
  dk <- db[, 1:k]; ok <- or_fit(or_counts(dk), k, map = TRUE); ek <- est(run(dk, method = "bayesian"))
  check(sprintf("B2-map-k%d", k), "B", sprintf("penalized EM k=%d = oracle MAP", k), vec(ek), as_disp(ok$par, k),
        tol = 1e-5, pass = max(abs(vec(ek) - as_disp(ok$par, k))) < 1e-5,
        note = sprintf("oracle |grad| of penalized objective %.2e", ok$grad))
}
# B3: BVR = Pearson X2 of observed vs fitted 2x2 margin, rebuilt from the DISPLAYED parameters
set.seed(5); dbv <- sim(1500, .35, c(.85, .7, .8, .75), c(.9, .8, .85, .9))
rbv <- run(dbv); ebv <- est(rbv); bvt <- rbv$conditional_dependence$asDF
bvr_hand <- function(e, d, a, b) {
  p <- e$prev; qa <- c(e$se[a], 1 - e$sp[a]); qb <- c(e$se[b], 1 - e$sp[b]); n <- nrow(d)
  ex <- matrix(0, 2, 2)
  for (cl in 1:2) { w <- c(p, 1 - p)[cl]
    ex <- ex + w * outer(c(1 - qa[cl], qa[cl]), c(1 - qb[cl], qb[cl])) }
  ob <- table(factor(d[[a]] == "pos", c(FALSE, TRUE)), factor(d[[b]] == "pos", c(FALSE, TRUE)))
  sum((ob - n * ex)^2 / (n * ex))
}
pairs <- utils::combn(4, 2)
hand <- apply(pairs, 2, function(ij) bvr_hand(ebv, dbv, ij[1], ij[2]))
check("B3-bvr", "B", "BVR (6 pairs) = Pearson X2 on 2x2 margin from displayed estimates", bvt$bvr, hand, 1e-6)

# B4: rule methods, tiny hand data (n = 10, 3 tests)
T1 <- c(1,1,1,1,0,0,0,1,0,0); T2 <- c(1,1,0,1,0,1,0,0,0,0); T3 <- c(1,0,1,1,0,0,0,0,1,0)
dr <- data.frame(T1 = fac(T1), T2 = fac(T2), T3 = fac(T3))
ec <- est(run(dr, "composite"))
# majority rows 1-4 -> 0.4; T1 rule+ 4/4, rule- 5/6; T2 3/4, 5/6; T3 3/4, 5/6; T1 PPV 4/5, NPV 5/5
check("B4-comp", "A", "composite hand counts (prev, Se, Sp)", c(ec$prev, ec$se, ec$sp),
      c(.4, 1, .75, .75, 5/6, 5/6, 5/6))
check("B4-comp-pv", "A", "composite T1 PPV 4/5, NPV 5/5", c(ec$ppv[1], ec$npv[1]), c(.8, 1))
rc <- run(dr, "composite"); pa <- rc$prevalence$asDF
check("B4-wilson", "A", "composite prevalence Wilson CI 4/10 (closed form)", c(pa$ci_lower, pa$ci_upper), or_wilson(4, 10))
ea <- est(run(dr, "all_positive"))
check("B4-all", "A", "all-positive: prev 2/10, T1 spec 5/8, Se blank", c(ea$prev, ea$sp[1], is.na(ea$se[1])), c(.2, 5/8, 1))
ey <- est(run(dr, "any_positive"))
check("B4-any", "A", "any-positive: prev 7/10, T1 Se 5/7, Sp blank", c(ey$prev, ey$se[1], is.na(ey$sp[1])), c(.7, 5/7, 1))
rk <- run(dr, "composite"); ka <- rk$agreement_stats$asDF
# T1 vs T2: a=3 b=2 c=1 d=4; po=.7; pe=.5*.4+.5*.6=.5; kappa=.4
check("B4-kappa", "A", "kappa T1 vs T2 = 0.4, agreement 0.7", c(ka$kappa[1], ka$agreement[1]), c(.4, .7))
check("B4-plot", "I", "agreement plot state [T1,T2] = 0.7 (hand)", rk$agreement_plot$state$agreement_matrix[1, 2], .7)

# ================================================================ C. LABEL SWITCHING / METAMORPHIC
set.seed(31); dm <- sim(1200, .3, c(.9, .8, .7, .85, .75), c(.95, .85, .75, .9, .8))
base <- vec(est(run(dm)))
for (s in c(1, 7, 99, 12345))
  check(sprintf("C1-seed%d", s), "C", sprintf("seed %d vs 0: identical oriented estimates (label switching)", s),
        vec(est(run(dm, seed = s))), base, 1e-6, "EXEC-PROP")
perm <- c(4, 2, 5, 1, 3); ep <- est(run(dm[, perm]))
check("C2-colperm", "C", "test column permutation: estimates follow the tests",
      c(ep$prev, ep$se[order(perm)], ep$sp[order(perm)]), base, 1e-6, "EXEC-PROP")
set.seed(32)
check("C3-rowperm", "C", "row permutation invariance", vec(est(run(dm[sample(nrow(dm)), ]))), base, 1e-6, "EXEC-PROP")
check("C4-dup", "C", "duplicating every row leaves the MLE unchanged",
      vec(est(run(rbind(dm, dm)))), base, 1e-6, "EXEC-PROP")
dlev <- dm; dlev[] <- lapply(dlev, function(v) factor(as.character(v), levels = c("pos", "neg")))
check("C5-levorder", "C", "factor level order pos/neg vs neg/pos: unchanged", vec(est(run(dlev))), base, 1e-6, "EXEC-PROP")
# C6: select 'neg' as positive for ALL tests -> class proportion 1-p, Se <-> Sp, PPV <-> NPV
eb <- est(run(dm)); er <- est(run(dm, pos = "neg"))
check("C6-allrev", "C", "all positive levels reversed: prev->1-prev, Se<->Sp",
      c(er$prev, er$se, er$sp), c(1 - eb$prev, eb$sp, eb$se), 1e-6, "EXEC-PROP")
check("C6-pv", "C", "all positive levels reversed: PPV<->NPV", c(er$ppv, er$npv), c(eb$npv, eb$ppv), 1e-6, "EXEC-PROP")
# C7: reverse ONE test -> anchor holds (others unchanged), that test reads 1-Se / 1-Sp + warning
e1 <- est(run(dm, pos = c("neg", "pos", "pos", "pos", "pos")))
check("C7-onerev", "C", "one test reversed: others unchanged, it becomes (1-Se, 1-Sp)",
      c(e1$prev, e1$se, e1$sp), c(eb$prev, 1 - eb$se[1], eb$se[-1], 1 - eb$sp[1], eb$sp[-1]), 1e-6, "EXEC-PROP",
      note = "TEST ERROR corrected after first run: expectation had (1-Sp,1-Se); P(neg|C+)=1-Se, P(pos|C-)=1-Sp")
check("C7-warn", "H", "one test reversed: 'Test below chance' names it", has(e1$notes, "Test below chance") &&
      has(e1$notes, "below 1 for: T1"), TRUE, grade = "EXEC-PROP")
# C8: Bayesian MAP under all-reversed: prior is asymmetric; the fit must not be relabelled silently
eB <- est(run(dm, "bayesian")); eBr <- est(run(dm, "bayesian", pos = "neg"))
check("C8-map-rev", "C", "penalized EM, all reversed: either blank+conflict notice or Se<->Sp within prior effect",
      c(eBr$prev, eBr$se, eBr$sp), c(1 - eB$prev, eB$sp, eB$se), tol = 0.01,
      pass = (all(is.na(eBr$se)) && has(eBr$notes, "Prior and class orientation conflict")) ||
             max(abs(c(eBr$prev, eBr$se, eBr$sp) - c(1 - eB$prev, eB$sp, eB$se))) < 0.01,
      grade = "EXEC-PROP", note = "Beta(2,1) on both Se and Sp is symmetric under the swap, so MAP should mirror")

# ================================================================ D. IDENTIFIABILITY / DEGENERATE
# D1 tie (prior IR-NGS-01): class means tie exactly -> blank + notice, any seed
tie <- from_counts(c(442, 718, 658, 1582, 2538, 702, 2562, 798), 3)
for (s in 0:1) { et_ <- est(run(tie, seed = s))
  check(sprintf("D1-tie-s%d", s), "D", "orientation tie: estimates blank + 'ambiguous' notice",
        c(is.na(et_$prev), all(is.na(et_$se)), has(et_$notes, "Class orientation is ambiguous")),
        c(TRUE, TRUE, TRUE), grade = "EXEC-PROP") }
# D2: T1,T2 dependent, T3 independent of both (exact): 2 informative tests -> not identified
p12 <- c(.4, .1, .1, .4)                 # (T1,T2) = 00,10,01,11
cntu <- round(1000 * c(p12 * .7, p12 * .3)); eu <- est(run(from_counts(cntu, 3)))
check("D2-unident", "D", "dependent pair + independent 3rd test: blank + 'not estimable'",
      c(is.na(eu$prev), has(eu$notes, "Latent parameters not estimable")), c(TRUE, TRUE), grade = "EXEC-PROP")
# D3: 3-test table violating the model's covariance-sign constraint -> G2 > 0 with zero df
cnti <- c(10, 80, 80, 10, 80, 10, 10, 10); ri <- run(from_counts(cnti, 3)); ei <- est(ri)
oi <- or_fit(cnti, 3)
check("D3-g2", "B", "incompatible 3-test table: displayed G2 = oracle G2 at the MLE (df 0, G2 > 0)",
      ei$g2, or_g2(oi$par, cnti, P3), tol = 1e-4, note = sprintf("oracle ll %.6f wrapper ll %.6f", oi$ll, ei$ll))
check("D3-note", "H", "zero-df note says G2 is descriptive", has(paste(ri$model_fit$notes, collapse = " "), "") ||
      TRUE, TRUE, grade = "EXEC-PROP", pass = any(grepl("descriptive discrepancies",
      vapply(ri$model_fit$notes, function(n) n$note, ""))))
# D4: <3 tests refused for latent methods
d2 <- dm[, 1:2]
msg <- tryCatch({ run(d2); "" }, error = conditionMessage)
check("D4-two", "D", "LCA with 2 tests is refused (5 params > 3 df)", grepl("at least 3 tests", msg), TRUE, grade = "EXEC-PROP")
msg <- tryCatch({ run(d2, "bayesian"); "" }, error = conditionMessage)
check("D4-two-map", "D", "penalized EM with 2 tests is refused", grepl("3 tests", msg), TRUE, grade = "EXEC-PROP")
# D5: three identical tests -> boundary warning, not '100% accurate'
did <- dm[, c(1, 1, 1)]; names(did) <- c("A", "B", "C"); eid <- est(run(did))
check("D5-identical", "D", "three copies of one test: blank or boundary warning (never silent 100%)",
      TRUE, TRUE, grade = "EXEC-PROP",
      pass = all(is.na(eid$se)) || has(eid$notes, "Estimates at the parameter boundary"))
# D6: missing data -> complete-case equals the run on complete rows; exclusions disclosed
dmis <- dm; dmis$T2[1:40] <- NA; emis <- est(run(dmis))
check("D6-missing", "C", "NA rows: equal to complete-case run, notice discloses 40 excluded",
      c(vec(emis), has(emis$notes, "Excluded 40 case(s)")), c(vec(est(run(dm[-(1:40), ]))), 1), 1e-6, "EXEC-PROP")
dna <- dm; v <- as.character(dna$T3); v[1:25] <- NA; dna$T3 <- addNA(factor(v, levels = c("neg", "pos")))
check("D7-addNA", "C", "explicit NA factor level treated as missing (not negative)",
      vec(est(run(dna))), vec(est(run(dm[-(1:25), ]))), 1e-6, "EXEC-PROP")
# D8: equivocal third category (prior IR-NGS-02) -> disclosed pooling
deq <- dm; v <- as.character(deq$T1); v[which(v == "neg")[1:50]] <- "equivocal"; deq$T1 <- factor(v)
check("D8-equivocal", "H", "observed third category: 'Test categories collapsed' names it",
      has(est(run(deq, "composite"))$notes, "equivocal"), TRUE, grade = "EXEC-PROP")
# D9: names colliding under '_' joining (prior IR-NGS-03) -> 6 agreement rows
dcol <- dm[, 1:4]; names(dcol) <- c("a_b", "c", "a", "b_c")
nrow_ag <- tryCatch(nrow(run(dcol, "composite")$agreement_stats$asDF), error = function(e) -1)
check("D9-keys", "D", "test names a_b/c/a/b_c: 6 agreement rows export", nrow_ag, 6, grade = "EXEC-PROP")
# D10: non-syntactic / non-ASCII names: BVR fills and estimates unchanged
dns <- dm[, 1:4]; names(dns) <- c("HPV DNA", "p16+/p53", "Grade 2/3", "Ki-67 ≥20%")
rns <- run(dns); ens <- est(rns)
check("D10-names", "C", "non-syntactic names: estimates equal syntactic run", vec(ens), vec(est(run(dm[, 1:4]))), 1e-6, "EXEC-PROP")
check("D10-bvr", "D", "non-syntactic names: all 6 BVR cells finite", sum(is.finite(rns$conditional_dependence$asDF$bvr)), 6,
      grade = "EXEC-PROP")

# ================================================================ E. BOOTSTRAP / OPTIONS
dbs <- dm[1:500, 1:4]
rb1 <- run(dbs, bootstrap = TRUE, nboot = 100, seed = 3)
rb2 <- run(dbs, bootstrap = TRUE, nboot = 100, seed = 3)
rb3 <- run(dbs, bootstrap = TRUE, nboot = 100, seed = 4)
rb9 <- run(dbs, bootstrap = TRUE, nboot = 100, seed = 3, alpha = .10)
ci <- function(r) { p <- r$prevalence$asDF; t <- r$test_metrics$asDF
  c(p$ci_lower, p$ci_upper, t$sens_ci_lower, t$sens_ci_upper, t$spec_ci_lower, t$spec_ci_upper) }
check("E1-seed", "E", "bootstrap same seed: identical intervals", ci(rb2), ci(rb1), 0, "EXEC-PROP")
check("E2-seed", "E", "bootstrap different seed: intervals differ", TRUE, TRUE, grade = "EXEC-PROP",
      pass = !isTRUE(all.equal(ci(rb3), ci(rb1))))
eb1 <- est(rb1); c1 <- ci(rb1); k4 <- 4
lo <- c(c1[1], c1[2 + 1:k4], c1[2 + 2 * k4 + 1:k4]); hi <- c(c1[2], c1[2 + k4 + 1:k4], c1[2 + 3 * k4 + 1:k4])
check("E3-contain", "G", "bootstrap CI contains estimate, lower < upper", TRUE, TRUE, grade = "EXEC-PROP",
      pass = all(lo <= vec(eb1) & vec(eb1) <= hi & lo < hi))
c9 <- ci(rb9); lo9 <- c(c9[1], c9[2 + 1:k4], c9[2 + 2 * k4 + 1:k4]); hi9 <- c(c9[2], c9[2 + k4 + 1:k4], c9[2 + 3 * k4 + 1:k4])
check("E4-nested", "E", "90% bootstrap intervals nested inside 95%", TRUE, TRUE, grade = "EXEC-PROP",
      pass = all(lo9 >= lo - 1e-12 & hi9 <= hi + 1e-12))
check("E5-point", "E", "bootstrap does not change point estimates", vec(eb1), vec(est(run(dbs))), 1e-10, "EXEC-PROP")
# E6: bootstrap replicate orientation relative to the full-sample fit (label switching inside resamples)
a <- meddecide:::nogoldstandardClass$new(options = meddecide:::nogoldstandardOptions$new(
  test1 = "T1", test1Positive = "pos", test2 = "T2", test2Positive = "pos", test3 = "T3",
  test3Positive = "pos", test4 = "T4", test4Positive = "pos", test5 = NULL, test5Positive = NULL,
  bootstrap = TRUE, nboot = 200, seed = 3), data = dbs)
quiet({ a$init(); a$run() })
bc <- a$.__enclos_env__$private$.boot_cache
full <- vec(eb1); keep <- is.finite(bc$prevalence)
dist_same <- sqrt((bc$prevalence - full[1])^2 + rowSums((bc$sensitivities - matrix(full[1 + 1:4], nrow(bc$sensitivities), 4, byrow = TRUE))^2))
dist_swap <- sqrt((1 - bc$prevalence - full[1])^2 + rowSums((1 - bc$specificities - matrix(full[1 + 1:4], nrow(bc$sensitivities), 4, byrow = TRUE))^2))
flips <- sum(dist_swap[keep] < dist_same[keep])
check("E6-bootflip", "E", "bootstrap replicates oriented like the full fit (no label switching)", flips, 0,
      grade = "EXEC-PROP", note = sprintf("%d finite replicates", sum(keep)))
# E7: rule-method Wilson CI wired to alpha
rw <- run(dr, "composite", alpha = .10)$prevalence$asDF
check("E7-alpha", "E", "composite prevalence CI at alpha=.10 = Wilson 90%", c(rw$ci_lower, rw$ci_upper), or_wilson(4, 10, .10))
# E8: clinicalPreset changes no number
check("E8-preset", "E", "clinicalPreset changes no estimate", vec(est(run(dm, clinicalPreset = "tumor_markers"))), base, 0, "EXEC-PROP")

# ================================================================ H. WORDING (clinical interpretation)
rsum <- run(dm, showSummary = TRUE, showMethodGuide = TRUE); esum <- est(rsum)
pn <- vapply(rsum$prevalence$notes, function(n) n$note, "")
check("H1-unlabeled", "H", "LCA: STRONG WARNING that classes are unlabeled", has(esum$notes, "Latent classes are unlabeled"), TRUE, grade = "EXEC-PROP")
check("H2-prevnote", "H", "class proportion note: not automatically disease prevalence",
      any(grepl("not automatically disease prevalence", pn)), TRUE, grade = "EXEC-PROP")
check("H3-titles", "H", "metric columns titled as response probabilities, not 'Sensitivity'",
      rsum$test_metrics$getColumn("sensitivity")$title, "P(Test+ | Class+/Rule+)", grade = "EXEC-PROP")
check("H4-summary", "H", "plain-language summary carries the unlabeled-class caution",
      has(rsum$clinical_summary$content, "latent classes are unlabeled"), TRUE, grade = "EXEC-PROP")
check("H5-guide", "H", "method guide: zero df but constraints (prior IR-NGS-04)",
      has(rsum$method_guide$content, "probability constraints"), TRUE, grade = "EXEC-PROP")
ecomp <- est(run(dm, "composite"))
check("H6-incorp", "H", "composite: incorporation-bias warning", has(ecomp$notes, "incorporation bias"), TRUE, grade = "EXEC-PROP")
check("H7-map", "H", "penalized EM: says MAP, not posterior/credible", has(eB$notes, "not credible intervals"), TRUE, grade = "EXEC-PROP")

# ================================================================ V. DOCUMENTATION executed
# updated 2026-10-21: VAL-NGS-03 fix - V1/V2 used to run a hard-coded copy of the vignette's call; they now extract the
# code of the SHIPPED vignette (knitr::purl) and run every chunk in order, so the check follows the file as shipped.
# library(meddecide) inside the vignette is a no-op here: load_all() has already attached the sibling source.
VIG <- "/Users/serdarbalci/Documents/GitHub/meddecide/vignettes/12-nogoldstandard.Rmd"
vcode <- tempfile(fileext = ".R")
quiet(knitr::purl(VIG, output = vcode, documentation = 0, quiet = TRUE))
venv <- new.env(parent = globalenv())
vmsg <- tryCatch({ utils::capture.output(quiet(source(vcode, local = venv, echo = FALSE))); "runs" },
                 error = function(e) paste("ERROR:", conditionMessage(e)))
check("V1-vignette", "V", "shipped vignette 12-nogoldstandard.Rmd: every code chunk (purl) runs end to end", vmsg, "runs",
      grade = "EXEC-PROP", note = sprintf("%d lines of chunk code from %s", length(readLines(vcode)), basename(VIG)))
vlines <- readLines(vcode)
vmsg2 <- tryCatch({
  est1 <- venv$result$prevalence$asDF$estimate[1]
  if (!is.numeric(est1) || !is.finite(est1)) stop("prevalence estimate not a finite number: ", base::format(est1))
  if (any(grepl("asDF()", vlines, fixed = TRUE))) stop("vignette code still calls asDF()")
  "runs" }, error = function(e) paste("ERROR:", conditionMessage(e)))
check("V2-vignette-asDF", "V", "vignette's result$prevalence$asDF extraction (field, not asDF()) yields a finite estimate",
      vmsg2, "runs", grade = "EXEC-PROP")

# ================================================================ F. SIMULATION (known truth)
# F1 recovery: R = 60 per configuration, n = 1500. Acceptance (prespecified): for every parameter
# |mean - truth| <= 3*MCSE + 0.01 (0.01 allows finite-sample bias); <= 2/60 non-estimable fits.
simrec <- function(id, method, p, se, sp, R = 60, n = 1500, seed) {
  set.seed(seed); truth <- c(p, se, sp); k <- length(se)
  M <- t(vapply(seq_len(R), function(i) vec(est(run(sim(n, p, se, sp), method))), numeric(2 * k + 1)))
  ok <- stats::complete.cases(M); M <- M[ok, , drop = FALSE]
  m <- colMeans(M); mcse <- apply(M, 2, sd) / sqrt(nrow(M))
  lab <- c("prev", paste0("Se", 1:k), paste0("Sp", 1:k))
  for (j in seq_along(truth))
    check(sprintf("%s-%s", id, lab[j]), "F", sprintf("%s recovery k=%d %s", method, k, lab[j]),
          m[j], truth[j], pass = abs(m[j] - truth[j]) <= 3 * mcse[j] + 0.01, grade = "SIM",
          note = sprintf("R=%d n=%d MCSE=%.4f bias=%+.4f", nrow(M), n, mcse[j], m[j] - truth[j]))
  check(paste0(id, "-estimable"), "F", sprintf("%s k=%d: non-estimable fits <= 2/%d", method, k, R),
        sum(!ok), 0, pass = sum(!ok) <= 2, grade = "SIM")
}
simrec("F1a", "latent_class", .3, c(.9, .8, .7), c(.95, .85, .75), seed = 101)
simrec("F1b", "latent_class", .2, c(.85, .75, .9, .65), c(.9, .95, .8, .85), seed = 102)
simrec("F1c", "latent_class", .4, c(.8, .7, .9, .6, .75), c(.85, .9, .7, .95, .8), seed = 103)
simrec("F1d", "bayesian", .2, c(.85, .75, .9, .65), c(.9, .95, .8, .85), seed = 104)
simrec("F1e", "latent_class", .05, c(.85, .75, .9, .8), c(.95, .97, .9, .93), n = 3000, seed = 105)

# F2 multiple starts: 20 weakly informative datasets (n = 200); wrapper log-likelihood must not be
# below the oracle's best of 60 random EM starts (a lower value = a local optimum was reported).
set.seed(202); worse <- 0; gap <- numeric(0)
for (i in 1:20) {
  dw <- sim(200, .4, c(.7, .65, .6, .7), c(.7, .75, .65, .6))
  ow <- or_fit(or_counts(dw), 4, seed = i); ew <- est(run(dw, seed = i))
  gap[i] <- ew$ll - ow$ll; if (gap[i] < -1e-6) worse <- worse + 1
}
check("F2-multistart", "F", "20 weak datasets: wrapper never reports a lower log-likelihood than oracle",
      worse, 0, grade = "EXEC-IND", note = sprintf("min(wrapper-oracle) = %.3g", min(gap)))

# F3 conditional dependence, 4 tests: within each class T2 copies T1 w.p. .7 (marginals kept).
cdsim <- function(n, k, seed) {
  set.seed(seed); dz <- rbinom(n, 1, .3)
  t1 <- ifelse(dz == 1, rbinom(n, 1, .8), rbinom(n, 1, .1))
  t2i <- ifelse(dz == 1, rbinom(n, 1, .8), rbinom(n, 1, .1)); cp <- rbinom(n, 1, .7)
  t2 <- ifelse(cp == 1, t1, t2i)
  t3 <- ifelse(dz == 1, rbinom(n, 1, .75), rbinom(n, 1, .1)); t4 <- ifelse(dz == 1, rbinom(n, 1, .85), rbinom(n, 1, .15))
  d <- data.frame(T1 = fac(t1), T2 = fac(t2), T3 = fac(t3), T4 = fac(t4)); d[, 1:k]
}
rcd <- run(cdsim(3000, 4, 301)); ecd <- est(rcd); bcd <- rcd$conditional_dependence$asDF
check("F3-cd4-flag", "F", "4 tests, T1-T2 dependent: dependence STRONG WARNING shown",
      has(ecd$notes, "do not appear to err independently"), TRUE, grade = "SIM",
      note = sprintf("fitted prev=%.3f Se=%s (truth .3; Se .8/.8/.75/.85)", ecd$prev, paste(round(ecd$se, 3), collapse = "/")))
# TEST ERROR corrected after run 1: the first version also required BVR(T1,T2) > 3.84. Observed 0.07:
# the two-class model absorbs the T1-T2 dependence into the latent class and the misfit appears on
# T3-T4 (BVR ~95) - exactly what the module's notice text says ("the flagged pair is not necessarily
# the dependent pair"). The row below records that behaviour as a property check.
check("F3-cd4-absorb", "F", "dependent pair absorbed: BVR(T1,T2) small, misfit flagged elsewhere (as the notice says)",
      c(bcd$bvr[1] < qchisq(.95, 1), any(bcd$bvr[-1] > qchisq(.95, 1))), c(TRUE, TRUE), grade = "SIM",
      note = sprintf("BVR12=%.2f max other=%.2f", bcd$bvr[1], max(bcd$bvr[-1])))
# F3b same 4-test data, penalized EM: the dependence the LCA path flags must not pass silently
rbd <- run(cdsim(3000, 4, 301), "bayesian"); ebd <- est(rbd)
check("F3-cd4-bayes", "H", "penalized EM, same dependent 4-test data: dependence checked or warned",
      grepl("independen", ebd$notes) || any(is.finite(rbd$conditional_dependence$asDF$bvr)), TRUE, grade = "SIM",
      note = sprintf("Se=%s (truth .8/.8/.75/.85); BVR cells=%d", paste(round(ebd$se, 3), collapse = "/"),
                     sum(is.finite(rbd$conditional_dependence$asDF$bvr))))
# F4 same dependence, 3 tests: zero df -> no residual can detect it. Requirement: the output must
# disclose that the check is not possible. Fitted bias is recorded.
rc3 <- run(cdsim(3000, 3, 302)); ec3 <- est(rc3); b3 <- rc3$conditional_dependence$asDF
nt3 <- vapply(rc3$conditional_dependence$notes, function(n) n$note, "")
check("F4-cd3-disclose", "F", "3 tests with dependence: verdicts 'Not assessable' + zero-df note shown",
      c(all(grepl("Not assessable", b3$verdict)), any(grepl("not chi-squared tests", nt3))), c(TRUE, TRUE),
      grade = "SIM", note = sprintf("fitted prev=%.3f (truth .3) Se=%s Sp=%s (truth Se .8/.8/.75 Sp .9/.9/.9); dependence notice shown=%s",
        ec3$prev, paste(round(ec3$se, 3), collapse = "/"), paste(round(ec3$sp, 3), collapse = "/"),
        has(ec3$notes, "do not appear to err independently")))

check("F4-cd3-panel", "H", "3-test LCA: Important Information panel warns that conditional independence cannot be checked",
      grepl("independen", ec3$notes), TRUE, grade = "SIM",
      note = "only the table footnotes say so; the notices panel carries no dependence caution while estimates are biased (see F4-cd3-disclose note)")

# F5 bootstrap coverage: 4 tests, n = 600, nboot = 100, R = 50, 95% percentile intervals.
# Acceptance: coverage >= .95 - 3*sqrt(.95*.05/50) = 0.858 for prev, Se1, Sp4.
set.seed(505); R <- 50; cov <- matrix(NA, R, 3); tr <- c(.3, .85, .85)
for (i in 1:R) {
  ds <- sim(600, .3, c(.85, .75, .9, .7), c(.9, .95, .8, .85))
  rr <- run(ds, bootstrap = TRUE, nboot = 100, seed = i)
  p <- rr$prevalence$asDF; tm <- rr$test_metrics$asDF
  cov[i, ] <- c(p$ci_lower <= .3 & .3 <= p$ci_upper, tm$sens_ci_lower[1] <= .85 & .85 <= tm$sens_ci_upper[1],
                tm$spec_ci_lower[4] <= .85 & .85 <= tm$spec_ci_upper[4])
}
band <- .95 - 3 * sqrt(.95 * .05 / R)
for (j in 1:3) check(sprintf("F5-cov-%s", c("prev", "Se1", "Sp4")[j]), "F",
  "bootstrap 95% percentile coverage", mean(cov[, j], na.rm = TRUE), .95,
  pass = mean(cov[, j], na.rm = TRUE) >= band, grade = "SIM",
  note = sprintf("R=%d, band >= %.3f, NA=%d", R, band, sum(is.na(cov[, j]))))

# ================================================================ BLOCKED
record("X1-omv", "E", ".omv save/reopen, protobuf serialization", "BLOCKED", "RProtoBuf not installed; GUI only")
record("X2-cluster", "F", "clustered rows (several slides/blocks per patient)", "BLOCKED",
       "no cluster option exists; method assumes independent rows - limitation, not testable")

out <- do.call(rbind, audit$rows)
print(out[, c("id", "grade", "result", "observed", "expected", "note")], row.names = FALSE, right = FALSE)
utils::write.csv(out, OUT, row.names = FALSE)
cat(sprintf("\nTOTAL %d  PASS %d  FAIL %d  BLOCKED %d\n", nrow(out), sum(out$result == "PASS"),
            sum(out$result == "FAIL"), sum(out$result == "BLOCKED")))
print(utils::sessionInfo())
if (any(out$result == "FAIL")) quit(status = 1)
