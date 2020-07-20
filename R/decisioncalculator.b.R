#' @title Decision Calculator
#'
#'
#'
#'
#' @importFrom R6 R6Class
#' @import jmvcore
#' @importFrom utils data
#'

decisioncalculatorClass <- if (requireNamespace("jmvcore")) R6::R6Class("decisioncalculatorClass",
    inherit = decisioncalculatorBase, private = list(.run = function() {


        # # Error Message ----
        #
        # if (nrow(self$data) == 0) stop("Data contains no (complete) rows")
        #
        # if ( (is.null(self$options$vars) || is.null(self$options$facs)) && is.null(self$options$target) ) {
        #     # ToDo Message ----
        #     todo <- "
        #         <br>Welcome to ClinicoPath
        #                   <br><br>
        #                   This tool will help you form an Alluvial Plots.
        #                   "
        #     html <- self$results$todo
        #     html$setContent(todo)
        #
        # } else {
        #     todo <- ""
        #     html <- self$results$todo
        #     html$setContent(todo)
        #
        #
        #
        # }








        # TODO

        # todo <- glue::glue( 'This Module is still under development - - ' )

        # self$results$todo$setContent(todo)

        TP <- self$options$TP

        FP <- self$options$FP

        TN <- self$options$TN

        FN <- self$options$FN

        # table1 <- matrix(c(TP, FP, FN, TN), nrow = 2, ncol = 2, byrow = TRUE,
        # dimnames = list(c('Test Positive', 'Test Negative'), c('Gold
        # Positive','Gold Negative'))) self$results$text1$setContent(table1)

        table2 <- matrix(c(TP, FP, FN, TN), nrow = 2, ncol = 2, byrow = TRUE,
            dimnames = list(c("Positive", "Negative"), c("Positive", "Negative")))

        table3 <- as.table(table2)

        names(attributes(table3)$dimnames) <- c("Test", "Golden Standard")

        # Prior Probability ----

        pp <- self$options$pp

        pprob <- self$options$pprob

        if (pp) {
            caretresult <- caret::confusionMatrix(table3, prevalence = pprob)

        } else {

            caretresult <- caret::confusionMatrix(table3)

        }

        self$results$text2$setContent(caretresult)


        # Self Calculation https://cran.r-project.org/web/packages/caret/caret.pdf
        # https://online.stat.psu.edu/stat509/node/150/

        # https://en.wikipedia.org/wiki/Sensitivity_and_specificity

        TotalPop <- TP + TN + FP + FN

        DiseaseP <- TP + FN

        DiseaseN <- TN + FP

        TestP <- TP + FP

        TestN <- TN + FN

        TestT <- TP + TN

        TestW <- FP + FN

        Sens <- TP/DiseaseP

        Spec <- TN/DiseaseN

        AccurT <- TestT/TotalPop

        PrevalenceD <- DiseaseP/TotalPop

        PPV <- TP/TestP

        NPV <- TN/TestN


        if (pp) {
            # Known prior probability from population
            PriorProb <- pprob
        } else {
            # From ConfusionMatrix
            PriorProb <- PrevalenceD
        }


        PostTestProbDisease <- (PriorProb * Sens)/((PriorProb * Sens) + ((1 -
            PriorProb) * (1 - Spec)))



        PostTestProbHealthy <- ((1 - PriorProb) * Spec)/(((1 - PriorProb) *
            Spec) + (PriorProb * (1 - Sens)))




        LRP <- Sens / (1 - Spec)

        LRN <- (1 - Sens) / Spec






        # Populate Table ----

        nTable <- self$results$nTable
        nTable$setRow(rowNo = 1,
                           values = list(
            tablename = "n",
            TotalPop = TotalPop,
            DiseaseP = DiseaseP,
            DiseaseN = DiseaseN,
            TestP = TestP,
            TestN = TestN,
            TestT = TestT,
            TestW = TestW
                           )
        )

        ratioTable <- self$results$ratioTable
        ratioTable$setRow(rowNo = 1,
                      values = list(
            tablename = "Ratios",
            Sens = Sens,
            Spec = Spec,
            AccurT = AccurT,
            PrevalenceD = PrevalenceD,
            PPV = PPV,
            NPV = NPV,
            PostTestProbDisease = PostTestProbDisease,
            PostTestProbHealthy = PostTestProbHealthy,
            LRP = LRP,
            LRN = LRN
            )
            )

        # footnotes ----

        if (self$options$fnote) {

        # nTable$addFootnote(rowKey = "1", col = "TotalPop", "Total Population")

        nTable$addFootnote(rowNo = 1, col = "TotalPop", "Total Number of Subjects")

        nTable$addFootnote(rowNo = 1, col = "DiseaseP", "Total Number of Subjects with Disease")

        nTable$addFootnote(rowNo = 1, col = "DiseaseN", "Total Number of Healthy Subjects")

        nTable$addFootnote(rowNo = 1, col = "TestP", "Total Number of Positive Tests")

        nTable$addFootnote(rowNo = 1, col = "TestN", "Total Number of Negative Tests")

        nTable$addFootnote(rowNo = 1, col = "TestT", "Total Number of True Test Results")

        nTable$addFootnote(rowNo = 1, col = "TestW", "Total Number of Wrong Test Results")


        }


        if (self$options$fnote) {

        ratioTable$addFootnote(rowNo = 1, col = "Sens", "Sensitivity (True Positives among Diseased)")

        ratioTable$addFootnote(rowNo = 1, col = "Spec", "Specificity (True Negatives among Healthy)")

        ratioTable$addFootnote(rowNo = 1, col = "AccurT", "Accuracy (True Test Result Ratio)")

        ratioTable$addFootnote(rowNo = 1, col = "PrevalenceD", "Disease Prevalence in this population")

        ratioTable$addFootnote(rowNo = 1, col = "PPV", "Positive Predictive Value (Probability of having disease after a positive test using this experimental population)")

        ratioTable$addFootnote(rowNo = 1, col = "NPV", "Negative Predictive Value (Probability of being healthy after a negative test using this experimental population)")

        ratioTable$addFootnote(rowNo = 1, col = "PostTestProbDisease", "Post-test Probability of Having Disease  (Probability of having disease after a positive test using known Population Prevalence)")

        ratioTable$addFootnote(rowNo = 1, col = "PostTestProbHealthy", "Post-test Probability of Being Healthy (Probability of being healthy after a negative test using known Population Prevalence)")

        # ratioTable$addFootnote(rowNo = 1, col = "LRP", "")

        # ratioTable$addFootnote(rowNo = 1, col = "LRN", "")


        }




        # Reorganize Table



        # caretresult[['positive']]
        # caretresult[['table']]
        # caretresult[['overall']]
        # caretresult[['overall']][['Accuracy']]
        # caretresult[['overall']][['Kappa']]
        # caretresult[['overall']][['AccuracyLower']]
        # caretresult[['overall']][['AccuracyUpper']]
        # caretresult[['overall']][['AccuracyNull']]
        # caretresult[['overall']][['AccuracyPValue']]
        # caretresult[['overall']][['McnemarPValue']]
        # caretresult[['byClass']]
        # caretresult[['byClass']][['Sensitivity']]
        # caretresult[['byClass']][['Specificity']]
        # caretresult[['byClass']][['Pos Pred Value']]
        # caretresult[['byClass']][['Neg Pred Value']]
        # caretresult[['byClass']][['Precision']]
        # caretresult[['byClass']][['Recall']] caretresult[['byClass']][['F1']]
        # caretresult[['byClass']][['Prevalence']]
        # caretresult[['byClass']][['Detection Rate']]
        # caretresult[['byClass']][['Detection Prevalence']]
        # caretresult[['byClass']][['Balanced Accuracy']] caretresult[['mode']]
        # caretresult[['dots']]




        # Write Summary




        # use epiR ----

        epirresult <- epiR::epi.tests(dat = table3)
        self$results$text3$setContent(epirresult)


        text4 <-
            list(
        epirresult[[3]][["aprev"]],


        epirresult[[3]]$aprev.est,
        epirresult[[3]]$tprev,
        epirresult[[3]]$se,
        epirresult[[3]]$sp,
        epirresult[[3]]$diag.acc,
        epirresult[[3]]$diag.or,
        epirresult[[3]]$nnd,
        epirresult[[3]]$youden,
        epirresult[[3]]$ppv,
        epirresult[[3]]$npv,
        epirresult[[3]]$plr,
        epirresult[[3]]$nlr,
        epirresult[[3]]$pro,
        epirresult[[3]]$pri,
        epirresult[[3]]$pfp,
        epirresult[[3]]$pfn
            )







        self$results$text4$setContent(text4)

        # ratioTable$setRow(rowNo = 2,
        #                   values = list(
        #                       tablename = "Ratios",
        #                       aprev = epirresult[[3]]$aprev,
        #                       tprev = epirresult[[3]]$tprev)
        # )



        # epirTable <- self$results$epirTable

        # data_frame <- epirresult[[4]]
        # for(i in seq_along(data_frame[,1,drop=T])) {
        #     epirTable$addRow(rowKey = i, values = c(data_frame[i,])) # This code produces a named vector/list, which is what the values argument expects
        # }


        # epirTable <- self$results$epirTable
        # epirTable$setRow(rowNo = 1,
        #                   values = epirresult
        #
        #                      # list(
        #                      #  tablename = "Ratios",
        #                      #  Sens = Sens,
        #                      #  Spec = Spec,
        #                      #  AccurT = AccurT,
        #                      #  PrevalenceD = PrevalenceD,
        #                      #  PPV = PPV,
        #                      #  NPV = NPV,
        #                      #  PostTestProbDisease = PostTestProbDisease,
        #                      #  PostTestProbHealthy = PostTestProbHealthy,
        #                      #  LRP = LRP,
        #                      #  LRN = LRN
        #                      # )
        # )





    }))
