library(DatabaseConnector)

regimenIngredient <- readr::read_csv("regimenIngredients.csv", col_types = "cici")

source("R/createRegimens.R")

# Set temp schema if you are using BigQuery or Oracle
# Sys.setenv("sqlRenderTempEmulationSchema" = "regimen_results")

connectionDetails <- createConnectionDetails(
  dbms="",
  user="",
  password="",
)
con <- connect(connectionDetails)

createRegimens(con, regimenIngredient, cdmDatabaseSchema = "regimen", writeDatabaseSchema = "regimen_results", regimenTableName = "regimen")

dbGetQuery(con, "select count(*) as n from regimen_results.regimen")

disconnect(con)
