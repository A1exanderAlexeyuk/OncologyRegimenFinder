#' @export
#'
#'
createEpisodeTable <- function(
  connection,
  writeDatabaseSchema,
  regimenIngredientTable,
  episodeTypeConceptId,
  cdmDatabaseSchema
) {

  sql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "EpisodeTable.sql",
    packageName = getThisPackageName(),
    cancerRegimenIngredients = regimenIngredientTable,
    writeDatabaseSchema = writeDatabaseSchema,
    episodeTypeConceptId = episodeTypeConceptId,
    cdmDatabaseSchema = cdmDatabaseSchema
  )

  DatabaseConnector::executeSql(
    connection = connection,
    sql = sql
  )
}


#' @export
#'
#'
createEpisodeEventTable <- function(
  connection,
  writeDatabaseSchema,
  regimenIngredientTable,
  eventTableConceptId,
  cdmDatabaseSchema
) {

  sql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "EpisodeEventTable.sql",
    packageName = getThisPackageName(),
    cancerRegimenIngredients = regimenIngredientTable,
    writeDatabaseSchema = writeDatabaseSchema,
    cdmDatabaseSchema = cdmDatabaseSchema,
    eventTableConceptId = eventTableConceptId
  )

  DatabaseConnector::executeSql(
    connection = connection,
    sql = sql
  )
}
