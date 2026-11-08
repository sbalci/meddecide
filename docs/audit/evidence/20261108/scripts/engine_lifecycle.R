# Engine lifecycle harness: installed meddecide 1.1.1 in jamovi's own R / jmvcore 28.3 / RProtoBuf.
# Mimics what the jamovi engine does on an option change: init() the new analysis, restore the previous
# results with fromProtoBuf(pb, oChanges, vChanges), then run(). Compares a restored run with a fresh run,
# checks serialization of every results tree, and redraws every image with the data removed (.omv reopen).
source("engine_env.R")
set.seed(20261021)
out <- list(); add <- function(...) { r <- data.frame(..., stringsAsFactors = FALSE); out[[length(out) + 1]] <<- r; print(r, row.names = FALSE) }

h <- meddecide::histopathology
for (v in c("Golden Standart", "New Test", "Rater 1", "Rater 2", "Rater 3", "Outcome")) h[[v]] <- factor(h[[v]])
h$Mortality5yr <- factor(h$Mortality5yr)

walk <- function(g, acc = list()) {
  for (it in g$items) {
    nm <- it$name
    if (inherits(it, "Group") || inherits(it, "Array")) acc <- walk(it, acc)
    else if (inherits(it, "Html") || inherits(it, "Preformatted")) acc[[paste0(g$name, "/", nm)]] <- list(type = "html", visible = isTRUE(it$visible), val = paste(it$content, collapse = ""))
    else if (inherits(it, "Table")) acc[[paste0(g$name, "/", nm)]] <- list(type = "table", visible = isTRUE(it$visible), val = tryCatch(paste(capture.output(print(it$asDF)), collapse = "\n"), error = function(e) ""), rows = it$rowCount)
    else if (inherits(it, "Image")) acc[[paste0(g$name, "/", nm)]] <- list(type = "image", visible = isTRUE(it$visible), val = if (is.null(it$state)) "" else "STATE", img = it)
  }
  acc
}
build <- function(fn, opts, data) {
  o <- do.call(getFromNamespace(paste0(fn, "Options"), "meddecide")$new, opts)
  engineOptions(o)  # engine builds options from the client protobuf
  a <- getFromNamespace(paste0(fn, "Class"), "meddecide")$new(options = o, data = data, datasetId = "audit-ds", analysisId = 7L, revision = 1L)
  a$init(); a
}
runq <- function(a) tryCatch({ suppressWarnings(a$run()); "ok" }, error = function(e) paste("raised:", conditionMessage(e)))
st <- function(a) paste0(a$status, "/", a$complete, "/", a$errored)

cycle <- function(fn, data, valid, invalid) {
  tag <- fn
  sf <- tempfile(fileext = ".pb")
  save_ <- function(a) { a$.setStatePathSource(function() sf); a$.save() }
  load_ <- function(a) { a$.setStatePathSource(function() sf); a$.load(vChanges = character()) }
  A <- build(fn, valid, data); ra <- runq(A)
  ser <- tryCatch(A$serialize(final = TRUE, createErrorOnFailure = FALSE), error = function(e) e)
  ok <- !inherits(ser, "error") && !is.null(ser)
  add(analysis = tag, check = "S valid run + engine serialize()", result = if (ok) paste("ok", st(A), ra, length(ser), "bytes") else paste("SERIALIZE FAIL:", if (inherits(ser, "error")) conditionMessage(ser) else "NULL"))
  sv <- tryCatch({ save_(A); "ok" }, error = function(e) conditionMessage(e))
  add(analysis = tag, check = "saved state bytes", result = as.character(file.size(sf)))
  if (sv != "ok") { add(analysis = tag, check = "S .save()", result = paste("FAIL:", sv)); return(invisible()) }
  B <- build(fn, invalid, data); load_(B); rb <- runq(B)
  C <- build(fn, invalid, data); rc <- runq(C)
  wb <- walk(B$results); wc <- walk(C$results)
  stale <- names(wb)[vapply(names(wb), function(k) nzchar(wb[[k]]$val) && wb[[k]]$visible && !identical(wb[[k]]$val, wc[[k]]$val %||% ""), TRUE)]
  add(analysis = tag, check = "L valid->invalid via .save/.load",
      result = paste0("restored ", st(B), " ", substr(rb, 1, 80), " | fresh ", st(C), " | stale vs fresh: ", if (length(stale)) paste(stale, collapse = "; ") else "none"))
  nb <- names(wb)[grepl("notice", names(wb), ignore.case = TRUE)]
  if (length(nb)) { wa0 <- walk(A$results); add(analysis = tag, check = "N notices chars: first run -> restored second run", result = paste(vapply(nb, function(k) paste0(k, " ", nchar(wa0[[k]]$val %||% ""), "->", nchar(wb[[k]]$val)), ""), collapse = "; ")) }
  save_(B)
  D <- build(fn, valid, data); load_(D); rd <- runq(D)
  wa <- walk(A$results); wd <- walk(D$results)
  diff <- names(wa)[vapply(names(wa), function(k) wa[[k]]$type %in% c("table", "html") && wa[[k]]$visible && !identical(wa[[k]]$val, wd[[k]]$val %||% ""), TRUE)]
  add(analysis = tag, check = "L invalid->valid recovery (tables+html identical to first valid run)", result = paste0(st(D), " | differing: ", if (length(diff)) paste(diff, collapse = "; ") else "none"))
  save_(A)
  E <- build(fn, valid, data); load_(E)
  E$.__enclos_env__$private$.data <- NULL
  we <- walk(E$results); imgs <- Filter(function(x) x$type == "image" && x$val == "STATE" && x$visible, we)
  res <- vapply(names(imgs), function(k) {
    img <- imgs[[k]]$img
    r <- tryCatch({ x <- E$.createImage(img$.__enclos_env__$private$.renderFun, img); if (is.list(x) && !is.null(x$error) && nzchar(x$error)) paste("ERR", x$error) else "ok" }, error = function(e) paste("ERR", conditionMessage(e)))
    paste0(k, "=", substr(r, 1, 110)) }, "")
  add(analysis = tag, check = paste0("R .omv reopen: restore, data=NULL, redraw (", length(imgs), " images)"), result = if (length(res)) paste(res, collapse = " ; ") else "no visible images with state")
}
`%||%` <- function(a, b) if (is.null(a)) b else a
safe <- function(expr) tryCatch(expr, error = function(e) add(analysis = "?", check = "harness", result = conditionMessage(e)))

safe(cycle("decisioncalculator", data.frame(), list(TP = 40, FN = 10, FP = 6, TN = 24, showSummary = TRUE, fagan = TRUE, ci = TRUE), list(TP = -1, FN = 10, FP = 6, TN = 24, showSummary = TRUE, fagan = TRUE, ci = TRUE)))
safe(cycle("cotest", data.frame(), list(preset = "hpv_pap", fnote = TRUE, fagan = TRUE), list(preset = "custom", fnote = TRUE, fagan = TRUE)))
safe(cycle("kappaSizeCI", data.frame(), list(showExplanations = TRUE, showSummary = TRUE), list(props = "0.5, 0.6", showExplanations = TRUE, showSummary = TRUE)))
safe(cycle("kappaSizeFixedN", data.frame(), list(showExplanations = TRUE, showSummary = TRUE), list(props = "0.5, 0.6", showExplanations = TRUE, showSummary = TRUE)))
safe(cycle("kappaSizePower", data.frame(), list(), list(props = "0.5, 0.6")))
safe(cycle("sequentialtests", data.frame(), list(show_explanation = TRUE, show_formulas = TRUE, show_plots = TRUE), list(test1_sens = 0.5, test1_spec = 0.4, show_explanation = TRUE, show_formulas = TRUE, show_plots = TRUE)))
dv <- list(gold = "Golden Standart", goldPositive = "1", goldNegative = "0", newtest = "New Test", testPositive = "1", testNegative = "0", ci = TRUE, fagan = TRUE, showSummary = TRUE)
safe(cycle("decision", h, dv, modifyList(dv, list(goldPositive = "9"))))
cv <- list(gold = "Golden Standart", goldPositive = "1", test1 = "New Test", test1Positive = "1", test2 = "Rater 1", test2Positive = "1", test3Positive = NULL, showIndividual = TRUE, showBarPlot = TRUE, showHeatmap = TRUE)
safe(cycle("decisioncombine", h, cv, modifyList(cv, list(goldPositive = "9"))))
pv <- list(gold = "Golden Standart", goldPositive = "1", goldNegative = "0", test1 = "New Test", test1Positive = "1", test1Negative = "0", test2 = "Rater 1", test2Positive = "1", test2Negative = "0", test3Positive = NULL, test3Negative = NULL, plot = TRUE)
safe(cycle("decisioncompare", h, pv, modifyList(pv, list(goldPositive = "9"))))
ev <- list(outcome = "Golden Standart", positiveClass = "1", predictors = c("MeasurementA", "Age"), calibrationAnalysis = TRUE, rocCurve = TRUE)
safe(cycle("enhancedROC", h, ev, modifyList(ev, list(positiveClass = "9"))))
rv <- list(dependentVars = "MeasurementA", classVar = "Golden Standart", positiveClass = "1", negativeClass = "0", plotROC = TRUE)
safe(cycle("psychopdaROC", h, rv, modifyList(rv, list(positiveClass = "9"))))
lv <- list(outcome = "Mortality5yr", outcomeLevel = "Dead", explanatory = c("Age", "MeasurementA", "MeasurementB", "Anti-X-intensity"), plotCoefficients = TRUE)
safe(cycle("lassologistic", h, lv, modifyList(lv, list(outcomeLevel = "Zombie"))))
nv <- list(test1 = "Rater 1", test1Positive = "1", test2 = "Rater 2", test2Positive = "1", test3 = "Rater 3", test3Positive = "1", test4Positive = NULL, test5Positive = NULL, method = "latent_class")
safe(cycle("nogoldstandard", h, nv, modifyList(nv, list(test1Positive = "9"))))
av <- list(vars = c("Rater 1", "Rater 2", "Rater 3"), blandAltmanPlot = FALSE, agreementHeatmap = TRUE)
safe(cycle("agreement", h, av, modifyList(av, list(vars = "Rater 1"))))
dc <- meddecide::dca_test_data
safe({ nm <- names(dc); cat("dca_test_data cols:", paste(nm, collapse = ", "), "\n") })


safe(cycle("decision", h, modifyList(dv, list(pp = TRUE, pprob = 0.3)), dv))
safe(cycle("sequentialtests", data.frame(), list(prevalence = 0.001, show_explanation = TRUE), list(prevalence = 0.1, show_explanation = TRUE)))
safe(cycle("decisioncalculator", data.frame(), list(TP = 0, FN = 10, FP = 6, TN = 24), list(TP = 40, FN = 10, FP = 6, TN = 24)))
dv2 <- list(outcome="cardiac_event", outcomePositive="Yes", models=c("basic_model","enhanced_model"), decisionRulePositive=NULL)
safe(cycle("decisioncurve", dc, dv2, modifyList(dv2,list(outcomePositive="INVALID"))))
res <- do.call(rbind, out); write.csv(res, "engine_lifecycle.csv", row.names = FALSE)
