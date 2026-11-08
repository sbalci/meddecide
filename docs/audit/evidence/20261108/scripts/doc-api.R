root <- "/Users/serdarbalci/Documents/GitHub/meddecide"
suppressPackageStartupMessages(pkgload::load_all(root, quiet=TRUE))
analyses <- yaml::read_yaml(file.path(root,"jamovi/0000.yaml"))$analyses
known <- vapply(analyses, `[[`, "", "name")
rows <- list()
for (file in c(file.path(root,"README.md"), list.files(file.path(root,"vignettes"), "\\.Rmd$", full.names=TRUE))) {
  lines <- readLines(file, warn=FALSE)
  active <- FALSE; code <- character(); start <- 0
  inspect <- function(code, start) {
    ex <- tryCatch(parse(text=code, keep.source=TRUE), error=function(e) NULL)
    if (is.null(ex)) return()
    walk <- function(x=NULL) {
      if (missing(x)) return()
      if (is.call(x)) {
        fun <- paste(deparse(x[[1]]), collapse="")
        fun <- sub("^meddecide::", "", fun)
        if (fun %in% known) {
          f <- get(fun, asNamespace("meddecide")); formal <- formals(f)
          args <- names(as.list(x)[-1]); args <- args[nzchar(args)]
          unknown <- setdiff(args, names(formal))
          required <- names(formal)[vapply(formal, identical, logical(1), quote(expr=))]
          missing <- setdiff(required, args)
          if (length(unknown) || length(missing)) rows[[length(rows)+1]] <<- data.frame(
            file=sub(paste0(root,"/"),"",file,fixed=TRUE), chunk_line=start, analysis=fun,
            unknown=paste(unknown,collapse=","), missing=paste(missing,collapse=","))
        }
        for (v in as.list(x)[-1]) if (!identical(v,quote(expr=))) tryCatch(walk(v), error=function(e) NULL)
      } else if (is.expression(x)) for (v in x) tryCatch(walk(v), error=function(e) NULL)
    }
    walk(ex)
  }
  for (i in seq_along(lines)) {
    if (!active && grepl("^```(\\{r|r($|[[:space:]]))",lines[i])) {
      active <- TRUE; code <- character(); start <- i
    } else if (active && grepl("^```", lines[i])) {
      inspect(code,start); active <- FALSE
    } else if (active) code <- c(code,lines[i])
  }
}
result <- if(length(rows)) do.call(rbind,rows) else data.frame()
write.csv(result,"/private/tmp/meddecide-release-20261108/doc-api.csv",row.names=FALSE)
print(result, row.names=FALSE)
