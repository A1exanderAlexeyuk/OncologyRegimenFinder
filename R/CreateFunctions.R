createCohortTable <- function(connection,
                              cdmDatabaseSchema,
                              writeDatabaseSchema,
                              cohortTable,
                              regimenTable,
                              drugClassificationIdInput){

  sql <- SqlRender::render(sql = readDbSql("CohortBuild.sql", connection@dbms),
                           cdmDatabaseSchema = cdmDatabaseSchema,
                           writeDatabaseSchema = writeDatabaseSchema,
                           cohortTable = cohortTable,
                           regimenTable = regimenTable,
                           drugClassificationIdInput = drugClassificationIdInput)

  DatabaseConnector::executeSql(connection = connection, sql = sql)
}

# createSapmledRegimenTable <- function(connection,
#                                       writeDatabaseSchema,
#                                       regimenTable,
#                                       sampleSize){
#   if(connection@dbms == 'bigquery'){
#     ParallelLogger::logInfo("Sampled table won't be created")
#   }else{
#     sqlTemp <- SqlRender::render("SELECT max(rn) as max FROM @writeDatabaseSchema.@regimenTable;",
#                                  writeDatabaseSchema = writeDatabaseSchema,
#                                  regimenTable = regimenTable)
#
#     maxId <- DatabaseConnector::dbGetQuery(connection, sqlTemp)
#     message(paste0("Cohort contains ", maxId$max, " subjects"))
#     idGroups <- c(seq(1, maxId$max, sampleSize), maxId$max + 1)
#
#     sql <- SqlRender::render(readDbSql("RegimenTable_f.sql", connection@dbms),
#                              regimenTable_f = paste0(regimenTable,"_f"),
#                              writeDatabaseSchema = writeDatabaseSchema)
#
#     DatabaseConnector::executeSql(connection = connection, sql = sql)
#     for(g in c(1:(length(idGroups)-1))){
#
#       startId = idGroups[g]
#       endId = idGroups[g+1] - 1
#
#       message(paste0("Processing persons ",startId," to ",endId))
#       sql <- SqlRender::render(readDbSql("InsertIntoSampledRegimenTable.sql", connection@dbms),
#                                writeDatabaseSchema = writeDatabaseSchema,
#                                regimenTable = regimenTable,
#                                sampledRegimenTable = paste0(regimenTable,"_sampled"),
#                                start = startId,
#                                end = endId)
#
#       DatabaseConnector::executeSql(connection = connection, sql = sql)
#     }
#   }
# }

createRegimenCalculation <- function(connection,
                                     writeDatabaseSchema,
                                     regimenTable,
                                     dateLagInput
){
  sql <- SqlRender::render(sql = readDbSql("RegimenCalculation.sql", connection@dbms),
                           writeDatabaseSchema = writeDatabaseSchema,
                           regimenTable = regimenTable,
                           dateLagInput= dateLagInput)

}


# InsertIntoRegimenTable_f <- function(connection,
#                                      writeDatabaseSchema,
#                                      regimenTable){
#   sql <- SqlRender::render(readDbSql("InsertIntoRegimenTable_f.sql", connection@dbms),
#                            writeDatabaseSchema = writeDatabaseSchema,
#                            sampledRegimenTable = paste0(regimenTable,"_sampled"),
#                            regimenTable_f = paste0(regimenTable,"_f"))
#
#   DatabaseConnector::executeSql(connection = connection, sql)
# }

createRawEvents <- function(connection,
                            rawEventTable,
                            cancerConceptId,
                            writeDatabaseSchema ,
                            cdmDatabaseSchema,
                            drugClassificationIdInput,
                            dateLagInput,
                            generateRawEvents){
  if(generateRawEvents){
    sql <- render(sql = readDbSql("RawEvents.sql"),
                  rawEventTable = rawEventTable,
                  cancerConceptId = cancerConceptId,
                  writeDatabaseSchema = cohortDatabaseSchema,
                  cdmDatabaseSchema = cdmDatabaseSchema,
                  drugClassificationIdInput = drugClassificationIdInput,
                  dateLagInput = dateLagInput)

    executeSql(connection = connection, sql = sql)
  }
}

# createVocabulary <- function(connection,
#                              writeDatabaseSchema,
#                              cdmDatabaseSchema,
#                              vocabularyTable,
#                              generateVocabTable){
#
#   sql <- SqlRender::render(sql = readDbSql("RegimenVocabulary.sql", connection@dbms),
#                            writeDatabaseSchema = writeDatabaseSchema,
#                            cdmDatabaseSchema = cdmDatabaseSchema,
#                            vocabularyTable = vocabularyTable)
#
#   DatabaseConnector::executeSql(connection = connection, sql = sql)
# }


createRegimenFormatTable <- function(connection,
                                     writeDatabaseSchema,
                                     cohortTable,
                                     regimenTable,
                                     regimenIngredientTable,
                                     vocabularyTable = FALSE,
                                     generateVocabTable = FALSE){
  if(generateVocabTable){
    sql_t <- readDbSql("RegimenFormat.sql", connection@dbms)
  } else {
    sql_t <- readDbSql("RegimenFormatWithoutVocabulary.sql", connection@dbms)
  }
  try(sql <- SqlRender::render(sql = sql_t,
                               writeDatabaseSchema = writeDatabaseSchema,
                               cohortTable = cohortTable,
                               regimenTable = regimenTable,
                               regimenIngredientTable = regimenIngredientTable
                               #vocabularyTable = vocabularyTable
                               ), silent = TRUE)

  DatabaseConnector::executeSql(connection = connection, sql = sql)

}
