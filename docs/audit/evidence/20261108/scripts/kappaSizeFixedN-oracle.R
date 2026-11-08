# Independent review of kappaSizeFixedN (meddecide 1.1.1, commit 403e034) - 2026-10-21.
# Audit only. Loads the shipped meddecide source; calls the public wrapper WITHOUT data= (E4).
# Run from anywhere:  Rscript --vanilla development-scripts/audit_kappaSizeFixedN_2026-10-21.R
# Writes development-ideas/kappaSizeFixedN-independent-review-2026-10-21-matrix.csv; exit 1 on any FAIL.
#
# Oracles (independent of R/kappaSizeFixedN.b.R and R/utils-kappasize.R):
#   cells, binary  : ADK 2001 common-correlation model written as the mixture "with probability rho all
#                    raters copy one Bernoulli(p) call, otherwise R independent calls";
#                    lambda_k = rho p + (1 - rho) p^k, inverted to P(X = x) by inclusion-exclusion;
#                    pooled 1-df cells (all negative, split, all positive) as ADK p.586.
#   cells, K = 3-5 : ADE 2001 Dirichlet-multinomial; P(all R raters on j) = E[theta_j^R] as a ratio of
#                    beta functions (rho > 0) or the elementary-symmetric expansion of ADE eq. (6) (rho <= 0).
#   fixed bound    : lower root of n X2(rho) = qchisq(1 - 2 alpha, 1) on the expected table at kappa0
#                    (DE1992 p.1514, RD2012 p.780), downward scan + bisection.
#   closed form    : 2 raters, K equal categories, X2 = (K-1)(k0-r)^2 / ((1+(K-1)r)(1-r))  (DERIVED in report).
#   restricted ML  : proportions re-estimated by ML at each rho on the pooled cells (ADE eqs 8-9);
#                    binary by optimize(), K = 3-5 by multi-start Nelder-Mead on stick-breaking logits.
#   simulation     : rating studies generated from the two models, each analysed by the plug-in and the
#                    restricted-ML goodness-of-fit interval; seeds and acceptance bands fixed below
#                    BEFORE the first run.

suppressPackageStartupMessages(pkgload::load_all("/Users/serdarbalci/Documents/GitHub/meddecide",
                                                  quiet = TRUE, export_all = TRUE))
umbrella <- "/Users/serdarbalci/Documents/GitHub/ClinicoPathJamoviModule"
out_csv <- "/private/tmp/meddecide-release-20261108/kappaSizeFixedN-matrix.csv"
QUICK <- nzchar(Sys.getenv("AUDIT_QUICK"))

quiet <- function(expr) suppressWarnings(suppressMessages(force(expr)))
fmt   <- function(x) paste(base::format(x, digits = 12), collapse = ", ")
audit <- new.env(); audit$rows <- list()
record <- function(claim, test, grade, observed, expected, result, tol = NA, note = "", d = NA_real_) {
  audit$rows[[length(audit$rows) + 1L]] <- data.frame(claim, test, grade, observed = fmt(observed),
    expected = fmt(expected), max_abs_diff = d, tol, result, note, stringsAsFactors = FALSE)
}
check <- function(claim, test, observed, expected, tol = 1e-8, grade = "EXEC-IND", note = "") {
  sc <- if (is.numeric(expected) && all(is.finite(expected)) && all(expected != 0)) abs(expected) else NULL
  ok <- isTRUE(all.equal(unname(observed), unname(expected), tolerance = tol, scale = sc, check.attributes = FALSE))
  d <- if (is.numeric(observed) && is.numeric(expected) && length(observed) == length(expected))
         max(abs(observed - expected)) else NA_real_
  record(claim, test, grade, observed, expected, if (ok) "PASS" else "FAIL", tol, note, d)
  invisible(ok)
}
info <- function(claim, test, observed, grade = "EXEC-IND", note = "") record(claim, test, grade, observed, "", "INFO", NA, note)

# ---------------------------------------------------------------- oracles ----
o_lambda <- function(p, k, rho) if (k == 0) 1 else rho * p + (1 - rho) * p^k
o_bin_dist <- function(p, R, rho) vapply(0:R, function(x) {
  u <- 0:(R - x)
  choose(R, x) * sum((-1)^u * choose(R - x, u) * vapply(x + u, function(k) o_lambda(p, k, rho), 0))
}, 0)
o_bin_cells <- function(p, R, rho) { d <- o_bin_dist(p, R, rho); c(d[1], sum(d[2:R]), d[R + 1]) }
o_esym <- function(z) { e <- c(1, rep(0, length(z))); for (zz in z) e <- e + c(0, head(e, -1)) * zz; e }
o_agree <- function(pj, R, rho) {
  if (rho > 1e-6) { a0 <- (1 - rho) / rho; aj <- pj * a0
    return(exp(lbeta(aj + R, a0 - aj) - lbeta(aj, a0 - aj))) }
  z <- (seq_len(R - 1) - pj) / pj
  pj^R * sum(rho^(0:(R - 1)) * o_esym(z)) / prod(1 + (0:(R - 2)) * rho)
}
o_multi_cells <- function(props, R, rho) { a <- vapply(props, o_agree, 0, R = R, rho = rho); c(1 - sum(a), a) }
o_cells <- function(K, R, props, rho) if (K == 2) o_bin_cells(props[1], R, rho) else o_multi_cells(props, R, rho)
o_valid <- function(K, R, props, rho) {
  if (K == 2) { d <- o_bin_dist(props[1], R, rho)
    return(all(is.finite(d)) && all(d > -1e-15) && all(o_bin_cells(props[1], R, rho) > 0)) }
  f <- outer(props, 0:(R - 1), function(p, k) p + rho * (k - p))
  all(f >= 0) && all(1 + (0:(R - 2)) * rho > 0) && all(o_multi_cells(props, R, rho) > 0)
}
o_x2 <- function(q, b) sum((q - b)^2 / b)
o_root_down <- function(g, kappa0, h = 1e-3) {      # g(r) >= 0 means "rejected"
  hi <- kappa0 - 1e-12; lo <- hi
  repeat { lo <- lo - h; if (lo < -1.5) return(NA_real_); if (g(lo) >= 0) break; hi <- lo }
  for (i in 1:200) { mid <- (lo + hi) / 2; if (g(mid) >= 0) lo <- mid else hi <- mid; if (hi - lo < 1e-13) break }
  (lo + hi) / 2
}
o_fixed <- function(K, R, props, kappa0, n, alpha, cells = o_cells, valid = o_valid) {
  crit <- qchisq(1 - 2 * alpha, 1); q <- cells(K, R, props, kappa0)
  o_root_down(function(r) if (!valid(K, R, props, r)) Inf else n * o_x2(q, cells(K, R, props, r)) - crit, kappa0)
}
o_bin_prange <- function(R, rho) { if (rho >= 0) return(c(1e-9, 1 - 1e-9))
  c0 <- (-rho / (1 - rho))^(1 / (R - 1)); if (c0 >= 0.5) return(NULL); c(c0 + 1e-12, 1 - c0 - 1e-12) }
o_rml_fit <- function(K, R, m, rho, start) {
  if (K == 2) {
    rg <- o_bin_prange(R, rho); if (is.null(rg)) return(NULL)
    nll <- function(p) { b <- o_bin_cells(p, R, rho); if (any(b <= 0)) return(1e100); -sum(m * log(b)) }
    o <- optimize(nll, rg, tol = 1e-12)
    return(list(props = c(o$minimum, 1 - o$minimum), cells = o_bin_cells(o$minimum, R, rho)))
  }
  to_p <- function(th) { v <- plogis(th); p <- numeric(K); rest <- 1
    for (j in seq_len(K - 1)) { p[j] <- rest * v[j]; rest <- rest - p[j] }; p[K] <- rest; p }
  from_p <- function(p) { th <- numeric(K - 1); rest <- 1
    for (j in seq_len(K - 1)) { th[j] <- qlogis(p[j] / rest); rest <- rest - p[j] }; th }
  nll <- function(th) { p <- to_p(th); if (any(p <= 0) || !o_valid(K, R, p, rho)) return(1e100)
    -sum(m * log(o_multi_cells(p, R, rho))) }
  best <- NULL
  for (s in list(start, rep(1 / K, K))) {
    o <- optim(from_p(s), nll, method = "Nelder-Mead", control = list(reltol = 1e-12, maxit = 5000))
    o <- optim(o$par, nll, method = "Nelder-Mead", control = list(reltol = 1e-13, maxit = 5000))
    if (is.null(best) || o$value < best$value) best <- o
  }
  if (best$value >= 1e100) return(NULL)
  p <- to_p(best$par); list(props = p, cells = o_multi_cells(p, R, rho))
}
o_rml_x2 <- function(K, R, m, rho, start) { f <- o_rml_fit(K, R, m, rho, start); if (is.null(f)) return(Inf)
  N <- sum(m); sum((m - N * f$cells)^2 / (N * f$cells)) }
o_rml <- function(K, R, props, kappa0, n, alpha, h = 0.005) {
  crit <- qchisq(1 - 2 * alpha, 1); m <- n * o_cells(K, R, props, kappa0)
  g <- function(r) o_rml_x2(K, R, m, r, props) - crit
  hi <- kappa0 - 1e-9; lo <- hi
  repeat { lo <- lo - h; if (lo < -1) return(NA_real_); if (g(lo) >= 0) break; hi <- lo }
  for (i in 1:60) { mid <- (lo + hi) / 2; if (g(mid) >= 0) lo <- mid else hi <- mid; if (hi - lo < 1e-9) break }
  (lo + hi) / 2
}
o_closed <- function(K, kappa0, n, alpha) { t <- qchisq(1 - 2 * alpha, 1) / n
  a <- (K - 1) * (1 + t); b <- -(2 * (K - 1) * kappa0 + t * (K - 2)); c <- (K - 1) * kappa0^2 - t
  (-b - sqrt(b^2 - 4 * a * c)) / (2 * a) }
# Display rule as a property (Methodology: positive bound rounded DOWN to 3 dp, 2 s.f. below 0.001;
# negative to nearest 3 dp). TRUE when string d is consistent with oracle b.
o_display_ok <- function(d, b, tol = 1e-9) {
  d <- as.numeric(d); if (!is.finite(d) || !is.finite(b)) return(FALSE)
  if (b > 0 && b < 0.001) return(d <= b + tol && b - d < 10^(floor(log10(b)) - 1) + tol)
  if (b > 0) return(d <= b + tol && b - d < 0.001 + tol)
  if (abs(b) < 0.001) return(abs(d - b) <= 0.5 * 10^(floor(log10(abs(b))) - 1) + tol)
  abs(d - b) <= 0.0005 + tol
}
near_boundary <- function(b) abs(b * 1000 - round(b * 1000)) < 1e-4

# ---------------------------------------------------------------- module access ----
run <- function(K, kappa0, props, R, alpha, n, ex = FALSE, su = FALSE)
  quiet(meddecide::kappaSizeFixedN(outcome = as.character(K), kappa0 = kappa0, props = props,
                                   raters = as.character(R), alpha = alpha, n = n,
                                   showExplanations = ex, showSummary = su))
# updated 2026-10-21: FN-01 - text1 can carry a second line (the fixed-proportion figure); parse the headline line only
shown <- function(r) { t <- strsplit(r$text1$content, "\n", fixed = TRUE)[[1]][1]
  if (!grepl(" of -?[0-9.]+\\.$", t)) stop("text1 unparsable: ", t); as.numeric(sub(".* of (-?[0-9.]+)\\.$", "\\1", t)) }
strip <- function(h) gsub("\\s+", " ", gsub("<[^>]+>", " ", h))
default_view <- function(r) paste(r$text1$content, strip(r$notices$content), strip(r$methodology$content))
priv <- meddecide:::kappaSizeFixedNClass$new(options = meddecide:::kappaSizeFixedNOptions$new())$.__enclos_env__$private
m_fixed <- function(K, R, props, kappa0, n, alpha) priv$.fixedBound(K, R, props, kappa0, n, qchisq(1 - 2 * alpha, 1))
m_rml <- function(K, R, props, kappa0, n, alpha, start)
  priv$.rmlBound(K, R, props, kappa0, n, qchisq(1 - 2 * alpha, 1), start = start)
pstr <- function(p) paste(p, collapse = ", ")
full_props <- function(K, p) if (K == 2) c(p[1], 1 - p[1]) else p

# =========================================================== A. known answers ====
# A1 closed form, 2 raters, K equal categories. For K >= 3 the restricted fit stays at 1/K by symmetry,
# so no second ("would be") figure may appear.
a1 <- expand.grid(K = 2:5, d = 1:4)
des <- list(c(0.6, 100, 0.05), c(0.8, 50, 0.10), c(0.4, 300, 0.01), c(0.7, 30, 0.20))
for (i in seq_len(nrow(a1))) {
  K <- a1$K[i]; v <- des[[a1$d[i]]]; p <- rep(1 / K, K)
  cf <- o_closed(K, v[1], v[2], v[3])
  r <- run(K, v[1], pstr(round(p, 6)), 2, v[3], v[2], ex = TRUE)
  check("C01", sprintf("A1 closed form K%d R2 k0 %.2f n %d a %.2f: internal fixed root", K, v[1], v[2], v[3]),
        m_fixed(K, 2, p, v[1], v[2], v[3]), cf, tol = 1e-9)
  check("C02", sprintf("A1 closed form K%d k0 %.2f n %d a %.2f: displayed bound obeys display rule", K, v[1], v[2], v[3]),
        o_display_ok(shown(r), cf), TRUE, note = paste("shown", shown(r), "closed", signif(cf, 10)))
  if (K >= 3) check("C03", sprintf("A1 K%d equal props: no second figure (re-estimation leaves 1/K)", K),
                    grepl("would be", r$text2$content), FALSE, grade = "EXEC-IND")
}
# A2 Cohen identity of the model's pair table (Methodology claim): (Po - Pe)/(1 - Pe) = rho, R = 2.
for (pp in list(c(.2, .8), c(.1, .3, .6), c(.05, .15, .3, .5))) {
  K <- length(pp); cl <- o_cells(K, 2, pp, 0.37)
  Po <- if (K == 2) cl[1] + cl[3] else sum(cl[-1]); Pe <- sum(pp^2)
  check("C04", sprintf("A2 Cohen kappa of the model pair table equals rho (K%d)", K), (Po - Pe) / (1 - Pe), 0.37,
        tol = 1e-12, grade = "EXEC-PROP")
}

# =========================================================== B. grid: WIRE + IND ====
props_for <- list(`2` = c(0.3), `3` = c(.2, .3, .5), `4` = c(.1, .2, .3, .4), `5` = c(.1, .15, .2, .25, .3))
gB <- expand.grid(K = 2:5, R = 2:6, k0 = c(0.4, 0.75), n = c(40, 250), alpha = 0.05)
if (QUICK) gB <- gB[seq(1, nrow(gB), by = 8), ]
gaps <- c(); gov <- 0; nrml <- 0; wire_d <- c(); disp_fail <- 0; bnd <- 0
for (i in seq_len(nrow(gB))) {
  K <- gB$K[i]; R <- gB$R[i]; k0 <- gB$k0[i]; n <- gB$n[i]; a <- gB$alpha[i]
  p1 <- props_for[[as.character(K)]]; pf <- full_props(K, p1)
  lab <- sprintf("K%d R%d k0 %.2f n %d", K, R, k0, n)
  # B1 EXEC-WIRE: kappaSize's own walk sits 0..0.00115 below the module's fixed root
  eng <- quiet(switch(as.character(K), "2" = kappaSize::FixedNBinary, "3" = kappaSize::FixedN3Cats,
                      "4" = kappaSize::FixedN4Cats, "5" = kappaSize::FixedN5Cats)(kappa0 = k0, n = n, props = p1, alpha = a, raters = R))
  fx <- m_fixed(K, R, pf, k0, n, a)
  wd <- fx - round(eng$kappaL, 10); wire_d <- c(wire_d, wd)
  check("C05", paste("B1 kappaSize walk below module fixed root by 0..0.00115 -", lab), wd >= -1e-9 && wd <= 0.00115 + 1e-9,
        TRUE, grade = "EXEC-WIRE", note = paste("diff", signif(wd, 6)))
  # B2 EXEC-IND: fixed root vs independent cells + root finder
  of <- o_fixed(K, R, pf, k0, n, a)
  check("C01", paste("B2 fixed root vs independent oracle -", lab), fx, of, tol = 1e-8)
  # B3 EXEC-IND: restricted-ML root and the governing rule
  reest <- !(K == 2 && R == 2)
  orml <- if (reest) o_rml(K, R, pf, k0, n, a) else NA_real_
  expect <- if (reest) min(of, orml) else of
  r <- run(K, k0, pstr(p1), R, a, n, ex = TRUE)
  ok <- o_display_ok(shown(r), expect)
  if (!ok && near_boundary(expect)) { bnd <- bnd + 1
    info("C06", paste("B3 displayed vs oracle min(fixed, re-estimated) at a 3-dp boundary (not adjudicated) -", lab), shown(r))
  } else check("C06", paste("B3 displayed bound = oracle min(fixed, re-estimated) under display rule -", lab), ok, TRUE,
               note = sprintf("shown %s fixed %.6f rml %.6f", shown(r), of, orml))
  if (reest) {
    mr <- m_rml(K, R, pf, k0, n, a, start = fx)
    if (identical(mr$status, "rml")) { nrml <- nrml + 1
      check("C07", paste("B3 module restricted-ML root vs independent oracle -", lab), mr$bound, orml, tol = 1e-5) }
    else check("C07", paste("B3 module says re-estimated not lower; oracle agrees -", lab), orml >= fx - 1e-6, TRUE,
               note = paste("status", mr$status, "oracle rml", signif(orml, 8), "fixed", signif(fx, 8)))
    gaps <- c(gaps, fx - orml); if (orml < fx) gov <- gov + 1
    two <- grepl("would be", r$text2$content)
    differ <- !identical(priv$.fmtBound(fx), priv$.fmtBound(min(fx, orml)))
    check("C08", paste("B3 Study Explanation gives both figures iff they differ at 3 dp -", lab), two, differ && orml < fx,
          grade = "EXEC-IND")
  }
}
info("C05", "B1 summary of module fixed - kappaSize walk (min, median, max)", c(min(wire_d), median(wire_d), max(wire_d)), grade = "EXEC-WIRE")
info("C07", "B3 designs where re-estimation governs / of designs where it applies; fixed - re-estimated gap (median, max)",
     c(gov, length(gaps), median(gaps), max(gaps)))

# B4 RD2012 'film' design (3 categories .11/.70/.19, 3 raters, kappa0 .44, n 171): headline vs both oracles
r <- run(3, 0.44, "0.11, 0.70, 0.19", 3, 0.05, 171)
of <- o_fixed(3, 3, c(.11, .70, .19), .44, 171, .05); orml <- o_rml(3, 3, c(.11, .70, .19), .44, 171, .05)
check("C06", "B4 RD2012 design: headline = oracle min(fixed, re-estimated)", o_display_ok(shown(r), min(of, orml)), TRUE,
      note = sprintf("shown %s fixed %.6f rml %.6f", shown(r), of, orml))
info("C09", "B4 RD2012 design: kappaSize / published-method fixed figure vs headline (fixed oracle, shown)", c(of, shown(r)))

# =========================================================== C. metamorphic ====
# C1 category order and binary forms
r0 <- shown(run(4, .6, "0.1, 0.2, 0.3, 0.4", 3, .05, 100))
perms <- list(c(.4, .3, .2, .1), c(.2, .4, .1, .3), c(.3, .1, .4, .2))
check("C10", "C1 permuting 4 category proportions leaves the bound unchanged",
      vapply(perms, function(p) shown(run(4, .6, pstr(p), 3, .05, 100)), 0), rep(r0, 3), tol = 0, grade = "EXEC-PROP")
bf <- vapply(c("0.3", "0.3, 0.7", "0.7, 0.3", "0.7"), function(s) shown(run(2, .6, s, 4, .05, 80)), 0)
check("C10", "C1 binary: '0.3', '0.3, 0.7', '0.7, 0.3', '0.7' give one bound", bf, rep(bf[1], 4), tol = 0, grade = "EXEC-PROP")
# C2 alpha: label and monotonicity; label percent wired to alpha
al <- c(0.001, 0.01, 0.025, 0.05, 0.10, 0.20)
for (dz in list(c(2, 2, .6, 100), c(4, 3, .6, 100))) {
  K <- dz[1]; R <- dz[2]; pp <- props_for[[as.character(K)]]
  rr <- lapply(al, function(a) run(K, dz[3], pstr(pp), R, a, dz[4]))
  b <- vapply(rr, shown, 0)
  check("C11", sprintf("C2 bound non-decreasing in alpha (K%d R%d)", K, R), all(diff(b) >= 0), TRUE, grade = "EXEC-PROP",
        note = fmt(b))
  labs <- vapply(rr, function(x) sub(".*one-sided ([0-9.]+%).*", "\\1", x$text1$content), "")
  check("C12", sprintf("C2 confidence label = 100(1 - alpha)%% (K%d R%d)", K, R), labs,
        c("99.9%", "99%", "97.5%", "95%", "90%", "80%"), grade = "EXEC-IND")
  of <- vapply(al, function(a) { f <- o_fixed(K, R, full_props(K, pp), dz[3], dz[4], a)
    if (K == 2 && R == 2) f else min(f, o_rml(K, R, full_props(K, pp), dz[3], dz[4], a)) }, 0)
  check("C06", sprintf("C2 every alpha: displayed = oracle under display rule (K%d R%d)", K, R),
        mapply(o_display_ok, b, of), rep(TRUE, length(al)))
}
# C3 monotone in n and raters (EXEC-PROP)
bn <- vapply(c(11, 25, 50, 100, 400, 2000, 1e5), function(n) shown(run(3, .6, "0.2, 0.3, 0.5", 4, .05, n)), 0)
check("C13", "C3 bound non-decreasing in n (K3 R4)", all(diff(bn) >= 0), TRUE, grade = "EXEC-PROP", note = fmt(bn))
for (K in 2:5) {
  br <- vapply(2:6, function(R) shown(run(K, .6, pstr(props_for[[as.character(K)]]), R, .05, 60)), 0)
  check("C13", sprintf("C3 bound non-decreasing in raters 2..6 (K%d)", K), all(diff(br) >= -1e-12), TRUE, grade = "EXEC-PROP", note = fmt(br))
}

# =========================================================== D. boundary / prior findings ====
# IR-02: bound in (0, 0.001) displayed without overstatement
for (v in list(c(.22, 56), c(.19, 75), c(.17, 94))) {
  cf <- o_closed(2, v[1], v[2], .05); s <- shown(run(2, v[1], "0.5", 2, .05, v[2]))
  check("C14", sprintf("D1 IR-02 k0 %.2f n %d: 0 < bound < 0.001 shown <= closed form", v[1], v[2]), s <= cf, TRUE,
        note = sprintf("shown %s closed %.9f", s, cf))
}
# IR-03: restricted fit at an extreme rare-category design
r <- run(3, .20, "0.02, 0.4426, 0.5374", 2, .05, 11)
orml <- o_rml(3, 2, c(.02, .4426, .5374), .20, 11, .05); of <- o_fixed(3, 2, c(.02, .4426, .5374), .20, 11, .05)
check("C15", "D2 IR-03 design: 'could not be re-estimated' absent", grepl("could not be re-estimated", strip(r$methodology$content)), FALSE)
check("C15", "D2 IR-03 design: displayed = oracle min(fixed, re-estimated)", o_display_ok(shown(r), min(of, orml)), TRUE,
      note = sprintf("shown %s fixed %.6f rml %.6f", shown(r), of, orml))
# IR-04: kappa0 0.4001 -> no 'Enrol more subjects' remedy
r <- run(2, .4001, "0.5", 2, .05, 300)
check("C16", "D3 IR-04 k0 0.4001: unreachable 'Enrol more subjects' remedy not offered",
      grepl("Enrol more subjects, add raters, or relax", strip(r$notices$content)), FALSE, grade = "EXEC-PROP")
# IR-01: plug-in under-coverage sentence carries a rarity qualifier
r <- run(2, .6, "0.3", 3, .05, 100, ex = TRUE)
# updated 2026-10-21: FN-02 - the "less than about a fifth" rare-category qualifier was retracted (plug-in under-coverage is
# not a rare-category effect only); assert the new sentence is shown and the retracted qualifier is gone.
check("C17", "D4 IR-01/FN-02 ML-advice sentence: plug-in under-coverage stated for 3+ raters or categories, balanced included; no rare-category qualifier",
      c(grepl("plugging in the overall proportions of ratings instead can give an interval that covers kappa less often than stated", strip(r$methodology$content), fixed = TRUE),
        grepl("Balanced categories do not prevent it", strip(r$methodology$content), fixed = TRUE),
        grepl("less than about a fifth", strip(r$methodology$content), fixed = TRUE)), c(TRUE, TRUE, FALSE),
      grade = "EXEC-PROP")
# zero threshold: red block iff bound <= 0 (closed form K2 R2 p .5 k0 .2)
for (n in c(60, 67, 68, 69, 80)) {
  cf <- o_closed(2, .2, n, .05); rr <- run(2, .2, "0.5", 2, .05, n)
  check("C18", sprintf("D5 red 'cannot demonstrate agreement' iff oracle bound <= 0 (n %d)", n),
        grepl("cannot demonstrate agreement", strip(rr$notices$content)), cf <= 0, note = paste("bound", signif(cf, 6)))
}
# 0.40 threshold: amber iff 0 < bound < 0.40 (closed form, kappa0 .55, K2 R2)
for (n in c(100, 140, 160, 200, 300)) {
  cf <- o_closed(2, .55, n, .05); rr <- run(2, .55, "0.5", 2, .05, n)
  check("C19", sprintf("D6 amber 'cannot support a reliability claim' iff 0 < oracle bound < 0.40 (n %d)", n),
        grepl("cannot support a reliability claim", strip(rr$notices$content)), cf > 0 && cf < 0.40, note = paste("bound", signif(cf, 6)))
}
# guards: n < 25, rare category < 5 %, fewer than one expected subject
for (n in c(24, 25)) check("C20", sprintf("D7 small-sample block iff n < 25 (n %d)", n),
      grepl("Small sample", strip(run(2, .6, "0.5", 2, .05, n)$notices$content)), n < 25, grade = "EXEC-PROP")
for (p in c(0.049, 0.05)) check("C21", sprintf("D8 rare-category block iff min prop < 0.05 (p %.3f)", p),
      grepl("Rare category", strip(run(2, .6, as.character(p), 2, .05, 200)$notices$content)), p < 0.05, grade = "EXEC-PROP")
for (p in c(0.009, 0.011)) check("C22", sprintf("D9 'too few expected subjects' iff n p < 1 (p %.3f, n 100)", p),
      grepl("Too few expected subjects", strip(run(2, .6, as.character(p), 2, .05, 100)$notices$content)), 100 * p < 1, grade = "EXEC-PROP")
# input refusals
rej <- function(...) inherits(tryCatch(quiet(meddecide::kappaSizeFixedN(...)), error = function(e) e), "error")
check("C23", "D10 n = 10 refused", rej(n = 10), TRUE, grade = "EXEC-PROP")
check("C23", "D10 proportions summing to 1.01 refused", rej(outcome = "3", props = "0.2, 0.3, 0.51"), TRUE, grade = "EXEC-PROP")
check("C23", "D10 decimal-comma proportions refused", rej(props = "0,2 0,8"), TRUE, grade = "EXEC-PROP")
check("C23", "D10 wrong proportion count refused", rej(outcome = "4", props = "0.5, 0.5"), TRUE, grade = "EXEC-PROP")
# extreme size: n = 1e6, 5 categories, 6 raters -> finite bound below kappa0, time recorded
tt <- system.time(r <- run(5, .7, "0.05, 0.15, 0.2, 0.25, 0.35", 6, .05, 1e6))[["elapsed"]]
check("C24", "D11 n 1e6 K5 R6: finite bound in (0, kappa0)", shown(r) > 0 && shown(r) < 0.7, TRUE, grade = "EXEC-PROP",
      note = paste("shown", shown(r)))
cat("D11 elapsed (s, console only so the CSV stays deterministic):", round(tt, 2), "\n")

# =========================================================== E. methodology claims ====
# E1 'the Dirichlet-multinomial (beta-binomial) model ... never gave a lower bound than the one shown'
o_bb_cells <- function(K, R, props, rho) o_multi_cells(props, R, rho)
o_bb_valid <- function(K, R, props, rho) { f <- outer(props, 0:(R - 1), function(p, k) p + rho * (k - p))
  all(f >= 0) && all(1 + (0:(R - 2)) * rho > 0) && all(o_multi_cells(props, R, rho) > 0) }
gE <- expand.grid(R = 3:6, p = c(.05, .1, .2, .5), k0 = c(.4, .6, .8), n = c(30, 100, 300))
if (QUICK) gE <- gE[seq(1, nrow(gE), by = 12), ]
lower <- 0; dif <- c()
for (i in seq_len(nrow(gE))) {
  v <- gE[i, ]; pp <- c(v$p, 1 - v$p)
  bb <- o_fixed(2, v$R, pp, v$k0, v$n, .05, cells = o_bb_cells, valid = o_bb_valid)
  s <- shown(run(2, v$k0, as.character(v$p), v$R, .05, v$n)); dif <- c(dif, bb - s)
  if (bb < s - 1e-9) lower <- lower + 1
}
check("C25", sprintf("E1 beta-binomial fixed bound never below the shown bound (%d binary designs, 3-6 raters)", nrow(gE)),
      lower, 0, tol = 0, note = sprintf("bb - shown: min %.6f median %.6f max %.6f", min(dif), median(dif), max(dif)))
# E2 default view: what a user sees with both optional panes off
r <- run(2, .6, "0.20, 0.80", 2, .05, 100)
of <- o_fixed(2, 2, c(.2, .8), .6, 100, .05)
check("C26", "E2 defaults: headline sentence text and figure", r$text1$content,
      sprintf("A total of 100 subjects can produce an expected one-sided 95%% lower limit for kappa of %s.",
              formatC(floor(of * 1000) / 1000, format = "f", digits = 3)), grade = "EXEC-IND", note = paste("oracle", signif(of, 10)))
check("C26", "E2 defaults: no warning block", nzchar(strip(r$notices$content)) && grepl("[A-Za-z]", strip(r$notices$content)), FALSE, grade = "EXEC-PROP")
# E3 default view when re-estimation governs and differs at 3 dp (RD2012 design): does any always-visible
# pane say the headline is not the published / kappaSize figure?
r <- run(3, 0.44, "0.11, 0.70, 0.19", 3, 0.05, 171)
dv <- default_view(r)
check("C27", "E3 RD2012 design, default view: headline identified as re-estimated (differs from kappaSize / published fixed figure)",
      grepl("re-estimat", dv), TRUE, grade = "EXEC-PROP",
      note = sprintf("headline %s; kappaSize/published-method figure %s", shown(r), priv$.fmtBound(o_fixed(3, 3, c(.11, .7, .19), .44, 171, .05))))
# E4 the largest gap fixed - re-estimated in a clinically plausible grid and whether it crosses 0.40
gG <- expand.grid(K = 2:5, R = 3:6, k0 = c(.45, .5, .55), n = c(50, 100, 200))
if (QUICK) gG <- gG[seq(1, nrow(gG), by = 16), ]
pr2 <- list(`2` = c(.1, .9), `3` = c(.1, .3, .6), `4` = c(.05, .15, .3, .5), `5` = c(.05, .1, .15, .3, .4))
cross <- 0; gp <- c(); ex_cross <- ""
for (i in seq_len(nrow(gG))) {
  v <- gG[i, ]; pp <- pr2[[as.character(v$K)]]
  fx <- m_fixed(v$K, v$R, pp, v$k0, v$n, .05); mr <- m_rml(v$K, v$R, pp, v$k0, v$n, .05, start = fx)
  b <- if (identical(mr$status, "rml")) min(fx, mr$bound) else fx
  gp <- c(gp, fx - b)
  if (fx >= 0.40 && b < 0.40) { cross <- cross + 1
    if (!nzchar(ex_cross)) ex_cross <- sprintf("K%d R%d props %s k0 %.2f n %d: fixed %.4f shown-bound %.4f", v$K, v$R, pstr(pp), v$k0, v$n, fx, b) }
}
info("C27", sprintf("E4 %d designs: fixed - reported gap (median, max); designs where the published figure is >= 0.40 but the headline < 0.40", nrow(gG)),
     c(median(gp), max(gp), cross), note = ex_cross)

# =========================================================== F. simulation ====
# Pre-specified (2026-10-21, before the first run): designs below, R_SIM = 1000 studies each, seed
# 20261021 + design index. Acceptance:
#  (a) coverage of the interval the module plans for (plug-in for 2 raters x binary, restricted ML
#      otherwise) inside nominal +/- 3 sqrt(p(1-p)/R);
#  (b) 'roughly half' claim: P(study's lower bound < shown) in [0.40, 0.60];
#  (c) plug-in coverage in a design WITHOUT a category below 0.2 inside the band (Methodology claim
#      'without such a category it stayed close to 0.95');
#  (d) simulator check: mean Fleiss kappa of the simulated studies within 0.02 of kappa0.
#  Rare-category plug-in coverages and the median simulated bound are INFO.
s_gen <- function(K, R, props, rho, n) {
  if (K == 2) { same <- runif(n) < rho
    x <- ifelse(same, R * (runif(n) < props[1]), rbinom(n, R, props[1])); cbind(x, R - x)
  } else { a <- props * (1 - rho) / rho
    g <- matrix(rgamma(n * K, shape = rep(a, each = n)), n, K); th <- g / rowSums(g)
    t(apply(th, 1, function(t) rmultinom(1, R, t))) }
}
s_pooled <- function(K, R, cnt) if (K == 2) { x <- cnt[, 1]; c(sum(x == 0), sum(x > 0 & x < R), sum(x == R)) } else {
  ag <- colSums(cnt == R); c(nrow(cnt) - sum(ag), ag) }
s_fleiss <- function(cnt) { R <- sum(cnt[1, ]); pj <- colSums(cnt) / sum(cnt)
  Pi <- rowSums(cnt * (cnt - 1)) / (R * (R - 1)); Pe <- sum(pj^2); (mean(Pi) - Pe) / (1 - Pe) }
s_floor <- function(K, R, p) { lo <- -0.999; hi <- 0; if (o_valid(K, R, p, lo)) return(lo)
  for (i in 1:60) { mid <- (lo + hi) / 2; if (o_valid(K, R, p, mid)) hi <- mid else lo <- mid }; hi }
s_study <- function(K, R, props, rho, n, alpha, at) {
  crit <- qchisq(1 - 2 * alpha, 1)
  cnt <- s_gen(K, R, props, rho, n); m <- s_pooled(K, R, cnt); ph <- colSums(cnt) / sum(cnt)
  if (any(ph <= 0)) return(NULL)
  fl <- s_floor(K, R, ph) + 1e-9
  f <- function(r) { if (!o_valid(K, R, ph, r)) return(Inf); b <- o_cells(K, R, ph, r); sum((m - n * b)^2 / (n * b)) }
  op <- optimize(f, c(fl, 0.9999), tol = 1e-10); rh <- op$minimum
  plugL <- if (op$objective >= crit) NA_real_ else if (f(fl) <= crit) fl else uniroot(function(r) f(r) - crit, c(fl, rh), tol = 1e-10)$root
  g <- function(r) o_rml_x2(K, R, m, r, ph)
  rml_le <- function(r) { if (g(r) < crit) return(TRUE); if (r < rh) return(FALSE)
    optimize(g, c(max(fl, rh - 0.15), min(0.9999, rh + 0.15)), tol = 1e-8)$objective < crit }
  c(fleiss = s_fleiss(cnt), plugL = plugL,
    plug_cov = !is.na(plugL) && rho >= plugL, plug_below = !is.na(plugL) && plugL < at,
    rml_cov = rml_le(rho), rml_below = rml_le(at))
}
sims <- list(
  list(id = "F1", K = 2, R = 2, p = c(.2, .8), k0 = .6, n = 100, a = .05),
  list(id = "F2", K = 2, R = 5, p = c(.15, .85), k0 = .5, n = 60, a = .10),
  list(id = "F3", K = 4, R = 3, p = c(.1, .2, .3, .4), k0 = .6, n = 100, a = .05),
  list(id = "F4", K = 5, R = 4, p = c(.05, .15, .2, .25, .35), k0 = .7, n = 150, a = .05),
  list(id = "F5", K = 4, R = 4, p = rep(.25, 4), k0 = .6, n = 80, a = .05),
  list(id = "F6", K = 3, R = 3, p = rep(1/3, 3), k0 = .6, n = 20, a = .05))
R_SIM <- if (QUICK) 40 else 1000
for (j in seq_along(sims)) {
  s <- sims[[j]]; set.seed(20261021 + j)
  pr <- if (s$K == 2) as.character(s$p[1]) else pstr(round(s$p, 6))
  sh <- shown(run(s$K, s$k0, pr, s$R, s$a, s$n))
  planned_rml <- !(s$K == 2 && s$R == 2)
  res <- do.call(rbind, Filter(Negate(is.null), lapply(seq_len(R_SIM), function(i) s_study(s$K, s$R, s$p, s$k0, s$n, s$a, at = sh))))
  Rn <- nrow(res); nom <- 1 - s$a; band <- 3 * sqrt(nom * (1 - nom) / Rn)
  lab <- sprintf("%s K%d R%d props %s k0 %.2f n %d alpha %.2f (shown %s; R = %d)", s$id, s$K, s$R, pstr(round(s$p, 3)), s$k0, s$n, s$a, sh, Rn)
  check("C28", paste("F(d) simulator: mean Fleiss kappa within 0.02 of kappa0 -", lab), abs(mean(res[, "fleiss"]) - s$k0) <= 0.02, TRUE,
        grade = "SIM", note = sprintf("mean %.4f (MC SE %.4f)", mean(res[, "fleiss"]), sd(res[, "fleiss"]) / sqrt(Rn)))
  cov <- mean(res[, if (planned_rml) "rml_cov" else "plug_cov"])
  check("C29", paste("F(a) coverage of the planned-for interval inside nominal +/- 3 MC SE -", lab), abs(cov - nom) <= band, TRUE,
        grade = "SIM", note = sprintf("%s coverage %.4f, band %.4f-%.4f, MC SE %.4f", if (planned_rml) "re-estimated" else "plug-in",
                                      cov, nom - band, nom + band, sqrt(cov * (1 - cov) / Rn)))
  below <- mean(res[, if (planned_rml) "rml_below" else "plug_below"])
  check("C30", paste("F(b) 'roughly half' end below the figure shown: P in [0.40, 0.60] -", lab), below >= 0.40 && below <= 0.60, TRUE,
        grade = "SIM", note = sprintf("P = %.4f (MC SE %.4f)", below, sqrt(below * (1 - below) / Rn)))
  pc <- mean(res[, "plug_cov"])
  # updated 2026-10-21: FN-02 - the module retracted "only with a category below about a fifth" and now states that with
  # 3+ raters or categories, balanced included, the plug-in interval can cover about 0.86-0.94. The row now tests that
  # statement (balanced 3+ design: plug-in coverage inside the stated 0.86-0.94 +/- 3 MC SE; for the K4 R4 design the
  # text quotes "about 0.88", so that one must also sit within 0.88 +/- 3 MC SE).
  if (min(s$p) >= 0.2 && planned_rml)
    check("C31", paste("F(c) FN-02 statement: balanced 3+ rater/category plug-in coverage inside the stated 0.86-0.94 (K4 R4: about 0.88) -", lab),
          pc >= 0.86 - band && pc <= 0.94 + band && (!(s$K == 4 && s$R == 4) || abs(pc - 0.88) <= band), TRUE,
          grade = "SIM", note = sprintf("plug-in coverage %.4f (empty %.4f); module text: 'about 0.88' for four balanced categories and four raters", pc, mean(is.na(res[, "plugL"]))))
  else info("C31", paste("F plug-in coverage (method property) -", lab), pc, grade = "SIM",
            note = sprintf("empty plug-in intervals %.4f", mean(is.na(res[, "plugL"]))))
  if (!planned_rml) {
    L <- res[, "plugL"]; L <- L[!is.na(L)]
    bm <- replicate(200, median(sample(L, replace = TRUE)))
    info("C30", paste("F median simulated plug-in lower bound vs shown (median, MC SE, shown) -", lab), c(median(L), sd(bm), sh), grade = "SIM")
  }
}

# F7 adjudication of F5 (E6, third source; added after runs 1-2, seeds fixed here): the plug-in and the
# restricted-ML Pearson statistics evaluated at the TRUE kappa. A valid 1-df test has mean ~ 1 and a
# two-sided 5% rejection rate ~ 0.05. Balanced designs only, to test 'without such a category it stayed
# close to 0.95'. Plug-in rows are the claim test (FAIL when mean > 1.25 or rejection outside
# 0.05 +/- 3 MC SE); restricted-ML rows are INFO.
f7 <- list(c(4, 4, 80, 777), c(4, 4, 300, 778), c(3, 3, 100, 779), c(4, 2, 100, 780), c(5, 6, 100, 781))
for (v in f7) {
  K <- v[1]; R <- v[2]; n <- v[3]; set.seed(v[4]); pp <- rep(1 / K, K); RR <- if (QUICK) 30 else 1000
  x <- replicate(RR, { cnt <- s_gen(K, R, pp, .6, n); m <- s_pooled(K, R, cnt); ph <- colSums(cnt) / sum(cnt)
    b <- o_cells(K, R, ph, .6); c(sum((m - n * b)^2 / (n * b)), o_rml_x2(K, R, m, .6, ph)) })
  rej <- mean(x[1, ] > qchisq(.95, 1)); band <- 3 * sqrt(.05 * .95 / RR)
  lab <- sprintf("F7 K%d R%d equal props, k0 .6, n %d (R = %d)", K, R, n, RR)
  # updated 2026-10-21: FN-02 - the claim under test was the retracted "balanced designs stay close to 0.95"; the module now
  # says balanced designs are NOT protected. The row tests the new statement: the plug-in statistic departs from chi-square(1).
  check("C31", paste(lab, "- FN-02 statement: balanced design does not protect the plug-in statistic (mean > 1.25 or rejection outside 0.05 +/- 3 MC SE)"),
        mean(x[1, ]) > 1.25 || abs(rej - .05) > band, TRUE, grade = "SIM",
        note = sprintf("plug-in mean %.3f rejection %.3f", mean(x[1, ]), rej))
  info("C31", paste(lab, "- restricted-ML statistic at the true kappa (mean, rejection)"),
       c(mean(x[2, ]), mean(x[2, ] > qchisq(.95, 1))), grade = "SIM")
}

# ------------------------------------------------------------------ output ----
out <- do.call(rbind, audit$rows)
print(table(out$result))
print(out[out$result != "PASS", c("claim", "test", "observed", "expected", "result", "note")], row.names = FALSE, right = FALSE)
utils::write.csv(out, out_csv, row.names = FALSE)
cat("\nrows:", nrow(out), " boundary-unadjudicated:", bnd, "\n")
print(utils::sessionInfo())
if (any(out$result == "FAIL")) quit(status = 1)
