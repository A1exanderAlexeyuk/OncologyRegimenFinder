#' Create an oncology drug regimen table in a `writeDatabaseSchema` database
#'
#' @description
#' Creates treatment regimens from a chosen classification code. All ingredient-level
#' descendants of the `drugClassificationIdInput` will be used for regimen construction.
#' Multiple ingredient exposures on the same day are combined into regimens using the
#' OncoRegimenFinder algorithm.
#'
#' @param connectionDetails
#' @param writeDatabaseSchema
#' @param rawEventTable
#' @param dateLagInput
#' @param generateVocabTable
#' @param sampleSize
#' @param cdmDatabaseSchema
#' @param cohortTable
#' @param regimenTable
#' @param regimenIngredientTable
#' @param vocabularyTable
#' @param cancerConceptId
#' @param generateRawEvents
#'
#' @return
#' This function does not return a value. It is called for its side effect of
#' creating a new SQL table called `regimenIngredientTable` in `writeDatabaseSchema`.
#' @export

createRegimens <- function(connectionDetails,
                           cdmDatabaseSchema,
                           writeDatabaseSchema,
                           cohortTable,
                           rawEventTable,
                           regimenTable,
                           regimenIngredientTable,
                           vocabularyTable,
                           cancerConceptId = 4115276,
                           dateLagInput = 30,
                           generateVocabTable = FALSE,
                           generateRawEvents = FALSE
                           ){

  connection <-  DatabaseConnector::connect(connectionDetails)

  createCohortTable(connection,
                    cdmDatabaseSchema,
                    writeDatabaseSchema,
                    cohortTable,
                    regimenTable
  )

  createRegimenCalculation(connection = connection,
                           writeDatabaseSchema = writeDatabaseSchema,
                           regimenTable = regimenTable,
                           dateLagInput= dateLagInput)

  createRawEvents(connection = connection,
                  rawEventTable = rawEventTable,
                  cancerConceptId = cancerConceptId,
                  writeDatabaseSchema = writeDatabaseSchema,
                  cdmDatabaseSchema = cdmDatabaseSchema,
                  dateLagInput = dateLagInput,
                  generateRawEvents = generateRawEvents)

  createVocabulary(connection = connection,
                   writeDatabaseSchema = writeDatabaseSchema,
                   cdmDatabaseSchema = cdmDatabaseSchema,
                   vocabularyTable = vocabularyTable,
                   generateVocabTable = generateVocabTable)

  createRegimenFormatTable(connection = connection,
                           writeDatabaseSchema = writeDatabaseSchema,
                           cohortTable = cohortTable,
                           regimenTable = regimenTable,
                           regimenIngredientTable = regimenIngredientTable,
                           vocabularyTable = vocabularyTable,
                           generateVocabTable = generateVocabTable
                           )

}
