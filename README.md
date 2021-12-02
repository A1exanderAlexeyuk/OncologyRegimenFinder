# OncologyRegimenFinder 

This is a new algorithm that takes as input a dataframe containing the ingredient that each regimen contains.
This dataframe is uploaded to the database and used to to find combination drug eras that match the regimens in the dataframe.

To run this algorithm on your data, clone this repository and open it as an RStudio project. Then run the `codeToRun.R` script.

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

## Algorithm details

First the user defines the regimens of interest in a dataframe with four columns: regimen_name, regimen_id, ingredient_name, ingredient_concept_id.
All columns are required. regimen_name and regimen_id can be Hemoc concept names and ids but do not have to be. The can be any custom defined regimens 
and regimen_id does not need to be a valid OMOP concept id. `ingredien_concept_id` should be a valid RxNorm ingredient OMOP concept ID. An example of
a regimen definition table is included in this repository as `regimenIngredients.csv`.

The algorithm is executed by the `createRegimens()` function that performs several steps:

1. Upload the regimen definition dataframe to the database as a temp table.
2. Construct drug eras from drug exposure records that contain an ingredient in the regimen definition dataframe. These eras differ from typical drug eras in one crucial way. They ignore ingredient and are constructed to represent continuous periods of exposure to any drug in the regimen definition dataframe.
3. Once the exposure eras are constructed we add a new column with the ingredients that the pserson is exposed to during the era. We end up with a table with one row per ingredient and era start and end dates duplicated on multiple rows when an era contains more than one ingredient exposure. Remember we only consider ingredients that are in the regimen definition dataframe and ignore all other ingredients.
4. Finally we join with the regimen definition table and keep eras where the set of ingredients in the era exactly matches the set of ingredients in a regimen.


