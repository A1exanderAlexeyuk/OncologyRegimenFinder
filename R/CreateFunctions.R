createCohortTable <- function(connection,
                              cdmDatabaseSchema,
                              writeDatabaseSchema,
                              cohortTable,
                              regimenTable
                              ){
  drugClassificationIdInput <- getIngredientsIds()

  sql <- SqlRender::render(sql = readDbSql("CohortBuild.sql", connection@dbms),
                           cdmDatabaseSchema = cdmDatabaseSchema,
                           writeDatabaseSchema = writeDatabaseSchema,
                           cohortTable = cohortTable,
                           regimenTable = regimenTable,
                           drugClassificationIdInput = drugClassificationIdInput$V1)

  DatabaseConnector::executeSql(connection = connection, sql = sql)
}

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


createRawEvents <- function(connection,
                            rawEventTable,
                            cancerConceptId,
                            writeDatabaseSchema ,
                            cdmDatabaseSchema,
                            drugClassificationIdInput,
                            dateLagInput,
                            generateRawEvents){
  if(generateRawEvents & connection@dbms != "bigquery"){
    sql <- SqlRender::render(sql = readDbSql("RawEvents.sql"),
                            rawEventTable = rawEventTable,
                            cancerConceptId = cancerConceptId,
                            writeDatabaseSchema = writeDatabaseSchema,
                            cdmDatabaseSchema = cdmDatabaseSchema,
                            drugClassificationIdInput = drugClassificationIdInput,
                            dateLagInput = dateLagInput)

    DatabaseConnector::executeSql(connection = connection, sql = sql)
  } else{

    ParallelLogger::logInfo("Raw events are not avalible in bigquery")

  }
}

createVocabulary <- function(connection,
                             writeDatabaseSchema,
                             cdmDatabaseSchema,
                             vocabularyTable,
                             generateVocabTable){
  if(generateVocabTable & connection@dbms !='bigquery'){
  sql <- SqlRender::render(sql = readDbSql("RegimenVocabulary.sql", connection@dbms),
                           writeDatabaseSchema = writeDatabaseSchema,
                           cdmDatabaseSchema = cdmDatabaseSchema,
                           vocabularyTable = vocabularyTable)

  DatabaseConnector::executeSql(connection = connection, sql = sql)
  } else{

    ParallelLogger::logInfo("Vocabulary will not be created")

  }
}


createRegimenFormatTable <- function(connection,
                                     writeDatabaseSchema,
                                     cohortTable,
                                     regimenTable,
                                     regimenIngredientTable,
                                     vocabularyTable = FALSE,
                                     generateVocabTable = FALSE){
  if(generateVocabTable & connection@dbms !='bigquery'){
    sql_t <- readDbSql("RegimenFormat.sql", connection@dbms)
  } else {
    sql_t <- readDbSql("RegimenFormatWithoutVocabulary.sql", connection@dbms)
  }
  try(sql <- SqlRender::render(sql = sql_t,
                               writeDatabaseSchema = writeDatabaseSchema,
                               cohortTable = cohortTable,
                               regimenTable = regimenTable,
                               regimenIngredientTable = regimenIngredientTable,
                               vocabularyTable = vocabularyTable
                               ), silent = TRUE)

  DatabaseConnector::executeSql(connection = connection, sql = sql)

}
