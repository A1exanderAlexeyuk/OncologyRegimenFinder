createCohortTable <- function(connection,
                              cdmDatabaseSchema,
                              writeDatabaseSchema,
                              cohortTable,
                              regimenTable,
                              drugClassificationIdInput){

  sql <- SqlRender::render(sql = getCohortBuild(),
                           cdmDatabaseSchema = cdmDatabaseSchema,
                           writeDatabaseSchema = writeDatabaseSchema,
                           cohortTable = cohortTable,
                           regimenTable = regimenTable,
                           drugClassificationIdInput = drugClassificationIdInput)

  DatabaseConnector::executeSql(connection = connection, sql = sql)
}

createSapmledRegimenTable <- function(connection,
                                      writeDatabaseSchema,
                                      regimenTable,
                                      sampleSize){
  sqlTemp <- SqlRender::render("SELECT max(rn) FROM @writeDatabaseSchema.@regimenTable;",
                               writeDatabaseSchema = writeDatabaseSchema,
                               regimenTable = regimenTable)

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
  }
}

createRegimenCalculation <- function(connection,
                                     writeDatabaseSchema,
                                     regimenTable,
                                     dateLagInput,
                                     regimenRepeats){
  sql <- SqlRender::render(sql = getRegimenCalculation(),
                           writeDatabaseSchema = writeDatabaseSchema,
                           regimenTable = regimenTable,
                           dateLagInput= dateLagInput)

  for(i in c(1:regimenRepeats))
  {
    DatabaseConnector::executeSql(connection = connection, sql = sql)
  }
}


InsertIntoRegimenTable_f <- function(connection,
                                     writeDatabaseSchema,
                                     regimenTable){
  sql <- SqlRender::render(getInsertIntoRegimenTable_f(),
                           writeDatabaseSchema = writeDatabaseSchema,
                           sampledRegimenTable = paste0(regimenTable,"_sampled"),
                           regimenTable_f = paste0(regimenTable,"_f"))

  DatabaseConnector::executeSql(connection = connection, sql)
}

createRawEvents <- function(connection,
                            rawEventTable,
                            cancerConceptId,
                            writeDatabaseSchema ,
                            cdmDatabaseSchema,
                            drugClassificationIdInput,
                            dateLagInput,
                            generateRawEvents){
  if(generateRawEvents){
  sql <- render(sql = getRawEvents(),
                rawEventTable = rawEventTable,
                cancerConceptId = cancerConceptId,
                writeDatabaseSchema = cohortDatabaseSchema,
                cdmDatabaseSchema = cdmDatabaseSchema,
                drugClassificationIdInput = drugClassificationIdInput,
                dateLagInput = dateLagInput
  )

  executeSql(connection = connection, sql = sql)
  }
}

createVocabulary <- function(connection,
                             writeDatabaseSchema,
                             cdmDatabaseSchema,
                             vocabularyTable,
                             generateVocabTable){
  if(generateVocabTable){

    sql <- SqlRender::render(sql = getRegimenVocabulary(),
                             writeDatabaseSchema = writeDatabaseSchema,
                             cdmDatabaseSchema = cdmDatabaseSchema,
                             vocabularyTable = vocabularyTable)

    DatabaseConnector::executeSql(connection = connection, sql = sql)

  }
}


createRegimenFormatTable <- function(connection,
                                     writeDatabaseSchema,
                                     cohortTable,
                                     regimenTable,
                                     regimenIngredientTable,
                                     vocabularyTable){
  sql <- SqlRender::render(getRegimenFormat(),
                           writeDatabaseSchema = writeDatabaseSchema,
                           cohortTable = cohortTable,
                           regimenTable = regimenTable,
                           regimenIngredientTable = regimenIngredientTable,
                           vocabularyTable = vocabularyTable)

  DatabaseConnector::executeSql(connection = connection, sql = sql)

}
