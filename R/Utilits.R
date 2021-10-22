getPath <- function() {
  if(connectionDetails$dbms == "postgresql"){
    return("inst/sql/Postgres")
    }
  if(connectionDetails$dbms == "redshift"){
    return("inst/sql/Redshift")
    }
}

getThisPackageName <- function() {
  return("OncoRegimenFinderA1")
}

getCohortBuild <- function(){
  SqlRender::readSql(file.path(getPath(),
                       "CohortBuild.sql"))
}

getRegimenTable <- function(){
  SqlRender::readSql(file.path(getPath(),
                               "RegimenTable.sql"))
}

getRegimenTable_f <- function(){
  SqlRender::readSql(file.path(getPath(),
                               "RegimenTable_f.sql"))
}
getSampledRegimenTable <- function(){
  SqlRender::readSql(file.path(getPath(),
                               "SampledRegimenTable.sql"))
}

getRegimenCalculation <- function(){
  SqlRender::readSql(file.path(getPath(),
                               "RegimenCalculation.sql"))
}

getInsertIntoRegimenTable_f <- function(){
  SqlRender::readSql(file.path(getPath(),
                               "InsertIntoRegimenTable_f.sql"))
}

getRawEvents <- function(){
  SqlRender::readSql(file.path(getPath(),
                               "RawEvents.sql"))
}

getRegimenFormat <- function(){
  SqlRender::readSql(file.path(getPath(),
                               "RegimenFormat.sql"))
}

getInsertIntoSampledRegimenTable <- function(){
  SqlRender::readSql(file.path(getPath(),
                               "InsertIntoSampledRegimenTable.sql"))
}

getRegimenVocabulary <- function(){
  SqlRender::readSql(file.path(getPath(),
                               "RegimenVocabulary.sql"))
}
