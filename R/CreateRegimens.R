#' Create an oncology drug regimen table in a CDM database
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
#' @param drugClassificationIdInput 
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
                            cohortTable = cohortTable,
                            rawEventTable = rawEventTable,
                            regimenTable = regimenTable,
                            regimenIngredientTable = regimenIngredientTable,
                            vocabularyTable = vocabularyTable,
                            drugClassificationIdInput = 21601387,
                            cancerConceptId = 4115276,
                            dateLagInput,
                            generateVocabTable = TRUE,
                            generateRawEvents = FALSE,
                            sampleSize = 999999999999) {

  connection <-  DatabaseConnector::connect(connectionDetails)

  createCohortTable(connection = connection,
                    cdmDatabaseSchema = cdmDatabaseSchema,
                    writeDatabaseSchema = writeDatabaseSchema,
                    cohortTable = cohortTable,
                    regimenTable = regimenTable,
                    drugClassificationIdInput = drugClassificationIdInput
                    )

  createSapmledRegimenTable(connection = connection,
                            writeDatabaseSchema = writeDatabaseSchema,
                            regimenTable = regimenTable,
                            sampleSize = sampleSize)

  createRegimenCalculation(connection = connection,
                           writeDatabaseSchema = writeDatabaseSchema,
                           regimenTable = regimenTable,
                           dateLagInput= dateLagInput)

  InsertIntoRegimenTable_f(connection = connection,
                           writeDatabaseSchema = writeDatabaseSchema,
                           regimenTable = regimenTable)

  createRawEvents(connection = connection,
                  rawEventTable = rawEventTable,
                  cancerConceptId = cancerConceptId,
                  writeDatabaseSchema = writeDatabaseSchema,
                  cdmDatabaseSchema = cdmDatabaseSchema,
                  drugClassificationIdInput = drugClassificationIdInput,
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
                           vocabularyTable = vocabularyTable)

}
