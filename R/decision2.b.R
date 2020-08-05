
# This file is a generated template, your changes will not be overwritten

decision2Class <- if (requireNamespace('jmvcore')) R6::R6Class(
    "decision2Class",
    inherit = decision2Base,
    private = list(


        .init = function() {

            table <- self$results$cTable

            private$.initcTable()

        },


        .run = function() {

            results <- private$.compute()
            private$.populatecTable(results)

        },




        .compute = function() {

            # Data definition ----
            mydata <- self$data

            mydata <- jmvcore::naOmit(mydata)

            testPLevel <- jmvcore::constructFormula(terms = self$options$testPositive)

            testPLevel <- jmvcore::decomposeFormula(formula = testPLevel)

            testPLevel <- unlist(testPLevel)


            testVariable <- jmvcore::constructFormula(terms = self$options$newtest)

            testVariable <- jmvcore::decomposeFormula(formula = testVariable)

            testVariable <- unlist(testVariable)


            goldPLevel <- jmvcore::constructFormula(terms = self$options$goldPositive)

            goldPLevel <- jmvcore::decomposeFormula(formula = goldPLevel)

            goldPLevel <- unlist(goldPLevel)


            goldVariable <- jmvcore::constructFormula(terms = self$options$gold)

            goldVariable <- jmvcore::decomposeFormula(formula = goldVariable)

            goldVariable <- unlist(goldVariable)

            mydata[[testVariable]] <- forcats::as_factor(mydata[[testVariable]])

            mydata[[goldVariable]] <- forcats::as_factor(mydata[[goldVariable]])

            # Table 1 ----

            results1 <- mydata %>% dplyr::select(.data[[testVariable]], .data[[goldVariable]]) %>%
                table()

            self$results$text1$setContent(results1)



            # Recode ----

            mydata2 <- mydata

            mydata2 <- mydata2 %>% dplyr::mutate(testVariable2 = dplyr::case_when(.data[[testVariable]] ==
                                                                                      self$options$testPositive ~ "Positive", NA ~ NA_character_, TRUE ~
                                                                                      "Negative")) %>%
                dplyr::mutate(goldVariable2 = dplyr::case_when(.data[[goldVariable]] ==
                                                                   self$options$goldPositive ~ "Positive", NA ~ NA_character_, TRUE ~
                                                                   "Negative"))

            mydata2 <- mydata2 %>% dplyr::mutate(testVariable2 = forcats::fct_relevel(testVariable2,
                                                                                      "Positive")) %>% dplyr::mutate(goldVariable2 = forcats::fct_relevel(goldVariable2,
                                                                                                                                                          "Positive"))




            # conf_table ----

            conf_table <- table(mydata2[["testVariable2"]], mydata2[["goldVariable2"]])


            # Caret ----


            TP <- conf_table[1,1]

            FP <- conf_table[1,2]

            FN <- conf_table[2,1]

            TN <- conf_table[2,2]


        },



        .initcTable = function() {


            cTable <- self$results$cTable

        },


        .populatecTable = function() {

            table <- self$results$cTable


            cTable$addRow(rowKey = "Test Positive",
                          values = list(
                              newtest = "Test Positive",
                              GP = TP,
                              GN = FP,
                              Total = TP + FP
                          )
            )


            cTable$addRow(rowKey = "Test Negative",
                          values = list(
                              newtest = "Test Negative",
                              GP = FN,
                              GN = TN,
                              Total = FN + TN
                          )
            )

            cTable$addRow(rowKey = "Total",
                          values = list(
                              newtest = "Total",
                              GP = TP + FN,
                              GN = FP + TN,
                              Total = TP + FP + FN + TN
                          )
            )



        }


        )
)
