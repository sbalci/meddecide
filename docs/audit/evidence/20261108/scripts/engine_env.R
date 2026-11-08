.libPaths(c("/private/tmp/meddecide-release-20261108/archive/meddecide/R", "/Applications/jamovi.app/Contents/Resources/modules/jmv/R",
            "/Applications/jamovi.app/Contents/Resources/modules/base/R", "/Applications/jamovi.app/Contents/Frameworks/R.framework/Versions/4.6/Resources/library"))
suppressMessages({library(jmvcore); library(RProtoBuf); library(meddecide)})
RProtoBuf::readProtoFiles(system.file("jamovi.proto", package = "jmvcore"))
# Encode R option values as the jamovi client would send them (jamovi.coms.AnalysisOptions), so that
# Options$asProtoBuf()/compProtoBuf() behave as in the engine (R-built options carry no .pb).
encodeOpt <- function(v, isInt = FALSE) {
  AO <- RProtoBuf::P("jamovi.coms.AnalysisOption"); AOS <- RProtoBuf::P("jamovi.coms.AnalysisOptions")
  O <- list(`FALSE` = 0L, `TRUE` = 1L, NONE = 2L)
  if (is.null(v)) { m <- RProtoBuf::new(AO); m$o <- O$NONE; return(m) }
  if ((is.list(v) || length(v) != 1 || !is.null(names(v))) && !(is.atomic(v) && length(v) == 1 && is.null(names(v)))) {
    cc <- RProtoBuf::new(AOS)
    for (x in as.list(v)) cc$add("options", encodeOpt(x, isInt))
    if (!is.null(names(v))) { cc$hasNames <- TRUE; for (n in names(v)) cc$add("names", n) }
    { m <- RProtoBuf::new(AO); m$c <- cc; return(m) }
  }
  m <- RProtoBuf::new(AO)
  if (is.logical(v)) { m$o <- if (isTRUE(v)) O$`TRUE` else O$`FALSE`; return(m) }
  if (is.numeric(v)) { if (isInt) m$i <- as.integer(v) else m$d <- as.numeric(v); return(m) }
  m$s <- as.character(v); m
}
engineOptions <- function(o) {
  pb <- RProtoBuf::new(RProtoBuf::P("jamovi.coms.AnalysisOptions")); pb$hasNames <- TRUE
  for (n in names(o$.__enclos_env__$private$.options)) {
    op <- o$.__enclos_env__$private$.options[[n]]
    if (inherits(op, "OptionOutput") || inherits(op, "OptionAction")) next
    pb$add("options", encodeOpt(op$value, inherits(op, "OptionInteger"))); pb$add("names", n)
  }
  o$fromProtoBuf(pb); invisible(o)
}
