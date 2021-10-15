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
#'@param   rawEventTable
#'
#'
#' @param drugClassificationIdInput
#'
#'
#' @param dateLagInput
#' .
#'
#'@param regimenRepeats
#'
#'
#'@param generateVocabTable
#'
#'
#'@param sampleSize
#'
#'
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
                            sampleSize = 999999999999) {

  connection <-  DatabaseConnector::connect(connectionDetails)

  sql <- SqlRender::render(sql = getCohortBuild(),
                           cdmDatabaseSchema = cdmDatabaseSchema,
                           writeDatabaseSchema = writeDatabaseSchema,
                           cohortTable = cohortTable,
                           regimenTable = regimenTable,
                           drugClassificationIdInput = drugClassificationIdInput)

  DatabaseConnector::executeSql(connection = connection, sql = sql)

  sqlTemp <- SqlRender::render("SELECT max(rn) FROM @writeDatabaseSchema.@regimenTable;", writeDatabaseSchema = writeDatabaseSchema, regimenTable = regimenTable)
  maxId <- DatabaseConnector::dbGetQuery(connection, sqlTemp)
  message(paste0("Cohort contains ", maxId$max, " subjects"))
  idGroups <- c(seq(1, maxId$max, sampleSize), maxId$max + 1)

  sql <- SqlRender::render(getRegimenTable_f(),
                          regimenTable_f = paste0(regimenTable,"_f"),
                          writeDatabaseSchema = writeDatabaseSchema)

  DatabaseConnector::executeSql(connection = connection, sql = sql)
  for(g in c(1:(length(idGroups)-1))){

    startId = idGroups[g]
    endId = idGroups[g+1] - 1

    message(paste0("Processing persons ",startId," to ",endId))
    sql <- SqlRender::render(getInsertIntoSampledRegimenTable(),
                             writeDatabaseSchema = writeDatabaseSchema,
                             regimenTable = regimenTable,
                             sampledRegimenTable = paste0(regimenTable,"_sampled"),
                             start = startId,
                             end = endId)

    DatabaseConnector::executeSql(connection = connection, sql = sql)

  sql <- SqlRender::render(sql = getRegimenCalculation(),
                           writeDatabaseSchema = writeDatabaseSchema,
                           regimenTable = regimenTable,
                           dateLagInput= dateLagInput)

  for(i in c(1:regimenRepeats)){DatabaseConnector::executeSql(connection = connection, sql = sql)}


  }
  sql <- SqlRender::render(getInsertIntoRegimenTable_f(),
                           writeDatabaseSchema = writeDatabaseSchema,
                           sampledRegimenTable = paste0(regimenTable,"_sampled"),
                           regimenTable_f = paste0(regimenTable,"_f"))

  DatabaseConnector::executeSql(connection = connection, sql)

  sql <- render(sql = getRawEvents(),
                rawEventTable = rawEventTable,
                cancerConceptId = cancerConceptId,
                writeDatabaseSchema = cohortDatabaseSchema,
                cdmDatabaseSchema = cdmDatabaseSchema,
                drugClassificationIdInput = drugClassificationIdInput,
                dateLagInput = dateLagInput
                )

  executeSql(connection = connection, sql = sql)

  if(generateVocabTable){

    sql <- SqlRender::render(sql = getRegimenVocabulary(),
                             writeDatabaseSchema = writeDatabaseSchema,
                             cdmDatabaseSchema = cdmDatabaseSchema,
                             vocabularyTable = vocabularyTable)

    DatabaseConnector::executeSql(connection = connection, sql = sql)

  }

  sql <- SqlRender::render(getRegimenFormat(),
                           writeDatabaseSchema = writeDatabaseSchema,
                           cohortTable = cohortTable,
                           regimenTable = regimenTable,
                           regimenIngredientTable = regimenIngredientTable,
                           vocabularyTable = vocabularyTable)

  DatabaseConnector::executeSql(connection = connection, sql = sql)


}
