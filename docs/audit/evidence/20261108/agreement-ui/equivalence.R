root <- "/Users/serdarbalci/Documents/GitHub/meddecide"
suppressPackageStartupMessages(pkgload::load_all(root, quiet=TRUE))
ns <- asNamespace("meddecide")
baseline <- new.env(parent=ns)
sys.source("/private/tmp/meddecide-agreement-ui-20261108/before/meddecide/R/agreement.b.R",
           envir=baseline)
run <- function(cls, data, ...) {
  a <- cls$new(options=ns$agreementOptions$new(...), data=data)
  suppressWarnings(suppressMessages(a$run()))
  a$results
}
tables <- function(g) {
  out <- list()
  walk <- function(g,path="") {
    if (inherits(g,"Table")) {
      out[[path]] <<- if(g$rowCount) g$asDF else list(rows=0L)
    } else if (inherits(g,"Group") || inherits(g,"Array")) {
      for(it in g$items) walk(it,paste0(path,"/",it$name))
    }
  }
  walk(g);out
}
set.seed(421)
d <- data.frame(R1=factor(sample(c("Neg","Pos"),80,TRUE)),
                R2=factor(sample(c("Neg","Pos"),80,TRUE)),
                R3=factor(sample(c("Neg","Pos"),80,TRUE)))
ord <- data.frame(R1=ordered(sample(1:3,80,TRUE)),R2=ordered(sample(1:3,80,TRUE)))
cont <- data.frame(R1=rnorm(80),R2=rnorm(80))
cases <- list(
  binary=list(data=d,vars=c("R1","R2")),
  multi_rater=list(data=d,vars=c("R1","R2","R3")),
  specific=list(data=d,vars=c("R1","R2"),specificAgreement=TRUE,specificPositiveCategory=" pos "),
  bad_category=list(data=d,vars=c("R1","R2"),specificAgreement=TRUE,specificPositiveCategory="absent"),
  ordinal=list(data=ord,vars=c("R1","R2"),wght="squared"),
  continuous=list(data=cont,vars=c("R1","R2"),icc=TRUE)
)
for(n in names(cases)) {
  a <- do.call(run,c(list(cls=baseline$agreementClass),cases[[n]]))
  b <- do.call(run,c(list(cls=ns$agreementClass),cases[[n]]))
  stopifnot(identical(tables(a),tables(b)))
  cat(n,": all result tables identical\n")
}
old <- run(baseline$agreementClass,data.frame(),vars=NULL)$welcome$content
new <- run(ns$agreementClass,data.frame(),vars=NULL)$welcome$content
stopifnot(grepl("<table",old,fixed=TRUE), !grepl("<table",new,fixed=TRUE))
plain <- function(h) trimws(gsub("[[:space:]]+"," ",gsub("<[^>]+>"," ",h)))
stopifnot(identical(plain(old),plain(new)))
cat("welcome: original table removed; all displayed text identical\n")
