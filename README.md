# OncologyRegimenFinder 

This is a new algorithm that takes as input a dataframe containing the ingredient that each regimen contains.
This dataframe is uploaded to the database and used to to find combination drug eras that match the regimens in the dataframe.

```
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


```
