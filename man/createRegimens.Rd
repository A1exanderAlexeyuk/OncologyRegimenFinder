% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CreateRegimens.R
\name{createRegimens}
\alias{createRegimens}
\title{Create an oncology drug regimen table in a CDM database}
\usage{
createRegimens(
  connectionDetails,
  cdmDatabaseSchema,
  writeDatabaseSchema,
  cohortTable = cohortTable,
  rawEventTable = rawEventTable,
  regimenTable = regimenTable,
  regimenIngredientTable = regimenIngredientTable,
  vocabularyTable = vocabularyTable,
  addAntineoplasticAgents = TRUE,
  addEndocrineTherapy = TRUE,
  addImmunostimulants = TRUE,
  addImmunosuppressants = TRUE,
  cancerConceptId = 4115276,
  dateLagInput = 30,
  generateVocabTable = FALSE,
  generateRawEvents = FALSE,
  sampleSize = 999999999999
)
}
\arguments{
\item{addImmunosuppressants}{}
}
\value{
This function does not return a value. It is called for its side effect of
creating a new SQL table called `regimenIngredientTable` in `writeDatabaseSchema`.
}
\description{
Creates treatment regimens from a chosen classification code. All ingredient-level
descendants of the `drugClassificationIdInput` will be used for regimen construction.
Multiple ingredient exposures on the same day are combined into regimens using the
OncoRegimenFinder algorithm.
}
