# Copyright 2021 Observational Health Data Sciences and Informatics
#
# This file is part of OncoRegimenFinder
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#' Create treatment regimens of a cohort
#'
#'
#'
#' @description
#'Creates treatment regimens from chosen classification code
#'
#' @template Connection
#'
#' @template CdmDatabaseSchema
#'
#' @template writeDatabaseSchema
#'
#' @template CohortTable
#'
#'
#' @param   rawEventTable
#'
#'
#' @param drugClassificationIdInput
#'
#'
#' @param dateLagInput
#' .
#'
#' @param regimenRepeats
#'
#'
#' @param generateVocabTable
#'
#'
#' @param sampleSize
#'
#' @param generateRawEvents
#'
#'  @return
#' SQL table in writeDatabaseSchema contains regimenIngredientTable.
#' @export

createRegimens <- function(connectionDetails,
                            cdmDatabaseSchema = "cdm_531",
                            writeDatabaseSchema,
                            cohortTable = cohortTable,
                            rawEventTable = rawEventTable,
                            regimenTable = regimenTable,
                            regimenIngredientTable = regimenIngredientTable,
                            vocabularyTable = vocabularyTable,
                            drugClassificationIdInput = 21601387,
                            cancerConceptId = 4115276,
                            dateLagInput,
                            regimenRepeats = 5,
                            generateVocabTable = TRUE,
                            generateRawEvents = FALSE,
                            sampleSize = 999999999999) {

  connection <-  DatabaseConnector::connect(connectionDetails)

  createCohortTable(connection = connection,
                    cdmDatabaseSchema = cdmDatabaseSchema,
                    writeDatabaseSchema = writeDatabaseSchema,
                    cohortTable = cohortTable,
                    regimenTable = regimenTable,
                    drugClassificationIdInput = drugClassificationIdInput,
                    cancerConceptId = cancerConceptId
                    )

  createSapmledRegimenTable(connection = connection,
                            writeDatabaseSchema = writeDatabaseSchema,
                            regimenTable = regimenTable,
                            sampleSize = sampleSize)

  createRegimenCalculation(connection = connection,
                           writeDatabaseSchema = writeDatabaseSchema,
                           regimenTable = regimenTable,
                           dateLagInput= dateLagInput,
                           regimenRepeats = regimenRepeats)

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
