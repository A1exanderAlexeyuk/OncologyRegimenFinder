
#' Identify drug regimen exposures
#'
#' This function will create a new table in an OMOP CDM database that contains drug regimens exposures for each person.
#' Regimens are defined continuous periods of time where one or more ingredients taken within 30 days of each other.
#'
#' @details
#' This algorithm is based largely on OHDSI's drug era logic (https://ohdsi.github.io/CommonDataModel/sqlScripts.html#Drug_Eras).
#' The major difference is that instead of creating a different era for each ingredient the regimen finder creates eras for combinations
#' of ingredients and matches them to user specified regimens (i.e. ingredient combinations).
#'
#' Ingredients that are not part of any regimen are completely ignored by the algorithm.
#' The first step is to roll up drug exposures to the RxNorm ingredient level.
#' Then considering only ingredients that are part of at least one regimen in the user's input the algorithm
#' creates exposure eras with 30 day collapsing logic that ignore ingredient. These eras are continuous periods of exposure to any ingredient in at least one regimen.
#' Next the algorithm identifies all ingredients exposures that occur within an each exposure era.
#' If the complete set of ingredients in an era matches the set of ingredients in a regimen definition then we have identified a regimen exposure
#' and a new record will be created in the final regimen table.
#'
#' This function should work on any suppported OHDSI database platform.
#'
#' @param con A DatabaseConnectorJdbcConnection object
#' @param regimenIngredient A dataframe that contains the regimen definitions
#' @param cdmDatabaseSchema The schema containing an OMOP CDM in the database
#' @param writeDatabaseSchema The name of the schema where the results should be saved in the database. Write access is required. If NULL (default) then result will be written to a temp table.
#' @param regimenTableName The name of the results table that will contain the regimens
#'
#' @return Returns NULL. This function is called for its side effect of creating a regimen table in the CDM database
#' @export
#'
#' @examples
#'
#' library(Eunomia)
#' # create or derive a dataframe that defines regimens
#' regimenIngredient <- data.frame(regimen_name = c("Venetoclax and Obinutuzumab", "Venetoclax and Obinutuzumab", "Doxycycline monotherapy"),
#'                                 regimen_id = c(35100084L, 35100084L, 35806103),
#'                                 ingredient_name = c("venetoclax", "obinutuzumab", "Doxycycline"),
#'                                 ingredient_concept_id = c(35604205L, 44507676L, 1738521))
#'
#' cd <- getEunomiaConnectionDetails()
#' con <- connect(cd)
#' createRegimens(con, regimenIngredient, "main", "main", "myregimens")
#'
#' # download the result from the database
#' regimens <- dbGetQuery(con, "select * from myregimens")
#'
createRegimens <- function(con, regimenIngredient, cdmDatabaseSchema, writeDatabaseSchema = NULL, regimenTableName = "regimen") {

  # verify input
  stopifnot(is.data.frame(regimenIngredient), names(regimenIngredient) == c("regimen_name", "regimen_id", "ingredient_name", "ingredient_concept_id"))

  if(con@dbms %in% c("bigquery", "oracle") & Sys.getenv("sqlRenderTempEmulationSchema") == "") {
    rlang::abort("sqlRenderTempEmulationSchema environment variable must be set when using bigquery or oracle.")
  }
  rlang::inform("Loading regimenIngredient into the database.")
  DatabaseConnector::insertTable(con,
                                 tableName = "regimenIngredient",
                                 data = regimenIngredient,
                                 tempTable = TRUE,
                                 dropTableIfExists = TRUE,
                                 tempEmulationSchema = Sys.getenv("sqlRenderTempEmulationSchema"),
                                 progressBar = TRUE)
  check <- dbGetQuery(con, SqlRender::translate("SELECT * FROM #regimenIngredient", con@dbms, tempEmulationSchema = Sys.getenv("sqlRenderTempEmulationSchema")))
  if(nrow(regimenIngredient) != nrow(check)) rlang::abort("regimenIngredient was not uploaded to the database.")

  sql <- "
  /****
  DRUG ERA
  Note: Eras derived from DRUG_EXPOSURE table, using 30d gap.
  Era collapsing logic copied and modified from https://ohdsi.github.io/CommonDataModel/sqlScripts.html#Drug_Eras
   ****/
  DROP TABLE IF EXISTS #cteDrugTarget;

  /* / */

  -- Normalize DRUG_EXPOSURE_END_DATE to either the existing drug exposure end date, or add days supply, or add 1 day to the start date
  SELECT d.DRUG_EXPOSURE_ID
      ,d.PERSON_ID
      ,c.CONCEPT_ID AS INGREDIENT_CONCEPT_ID
      ,d.DRUG_TYPE_CONCEPT_ID
      ,DRUG_EXPOSURE_START_DATE
      ,COALESCE(DRUG_EXPOSURE_END_DATE, DATEADD(day, DAYS_SUPPLY, DRUG_EXPOSURE_START_DATE), DATEADD(day, 1, DRUG_EXPOSURE_START_DATE)) AS DRUG_EXPOSURE_END_DATE
  INTO #cteDrugTarget
  FROM @TARGET_CDMV5_SCHEMA.DRUG_EXPOSURE d
  INNER JOIN @TARGET_CDMV5_SCHEMA.CONCEPT_ANCESTOR ca ON ca.DESCENDANT_CONCEPT_ID = d.DRUG_CONCEPT_ID
  INNER JOIN @TARGET_CDMV5_SCHEMA.CONCEPT c ON ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
  WHERE c.DOMAIN_ID = 'Drug'
      AND c.CONCEPT_CLASS_ID = 'Ingredient'
      AND c.CONCEPT_ID IN(@ingredient_ids);

  /* / */

  DROP TABLE IF EXISTS #cteEndDates;

  /* / */

  SELECT PERSON_ID
      ,DATEADD(day, - 30, EVENT_DATE) AS END_DATE -- unpad the end date
  INTO #cteEndDates
  FROM (
      SELECT E1.PERSON_ID
          ,E1.EVENT_DATE
          ,COALESCE(E1.START_ORDINAL, MAX(E2.START_ORDINAL)) START_ORDINAL
          ,E1.OVERALL_ORD
      FROM (
          SELECT PERSON_ID
              ,EVENT_DATE
              ,EVENT_TYPE
              ,START_ORDINAL
              ,ROW_NUMBER() OVER (
                  PARTITION BY PERSON_ID ORDER BY EVENT_DATE, EVENT_TYPE
                  ) AS OVERALL_ORD -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
          FROM (
              -- select the start dates, assigning a row number to each
              SELECT PERSON_ID
                  ,DRUG_EXPOSURE_START_DATE AS EVENT_DATE
                  ,0 AS EVENT_TYPE
                  ,ROW_NUMBER() OVER (
                      PARTITION BY PERSON_ID ORDER BY DRUG_EXPOSURE_START_DATE
                      ) AS START_ORDINAL
              FROM #cteDrugTarget

              UNION ALL

              -- add the end dates with NULL as the row number, padding the end dates by 30 to allow a grace period for overlapping ranges.
              SELECT PERSON_ID
                  ,DATEADD(day, 30, DRUG_EXPOSURE_END_DATE)
                  ,1 AS EVENT_TYPE
                  ,NULL
              FROM #cteDrugTarget
              ) RAWDATA
          ) E1
      INNER JOIN (
          SELECT PERSON_ID
              ,DRUG_EXPOSURE_START_DATE AS EVENT_DATE
              ,ROW_NUMBER() OVER (
                  PARTITION BY PERSON_ID ORDER BY DRUG_EXPOSURE_START_DATE
                  ) AS START_ORDINAL
          FROM #cteDrugTarget
          ) E2 ON E1.PERSON_ID = E2.PERSON_ID
          AND E2.EVENT_DATE <= E1.EVENT_DATE
      GROUP BY E1.PERSON_ID
          ,E1.EVENT_DATE
          ,E1.START_ORDINAL
          ,E1.OVERALL_ORD
      ) E
  WHERE 2 * E.START_ORDINAL - E.OVERALL_ORD = 0;

  /* / */

  DROP TABLE IF EXISTS #cteDrugExpEnds;

  /* / */

  SELECT d.PERSON_ID
      ,d.DRUG_TYPE_CONCEPT_ID
      ,d.DRUG_EXPOSURE_START_DATE
      ,MIN(e.END_DATE) AS ERA_END_DATE
  INTO #cteDrugExpEnds
  FROM #cteDrugTarget d
  INNER JOIN #cteEndDates e ON d.PERSON_ID = e.PERSON_ID
      AND e.END_DATE >= d.DRUG_EXPOSURE_START_DATE
  GROUP BY d.PERSON_ID
      ,d.DRUG_TYPE_CONCEPT_ID
      ,d.DRUG_EXPOSURE_START_DATE;

  /* / */

  DROP TABLE IF EXISTS #exposureEra;

  SELECT
    row_number() OVER (ORDER BY person_id) AS drug_era_id
    ,person_id
    ,era_start_date
    ,era_end_date
  INTO #exposureEra
  FROM (
    SELECT
    person_id
    ,min(DRUG_EXPOSURE_START_DATE) AS era_start_date
    ,ERA_END_DATE as era_end_date
    FROM #cteDrugExpEnds
    GROUP BY person_id
      ,drug_type_concept_id
      ,ERA_END_DATE
  );

  -- Add ingredients to eras
  DROP TABLE IF EXISTS #comboIngredientEras;

  SELECT DISTINCT
    e.drug_era_id
    ,e.person_id as person_id
    ,e.era_start_date
    ,e.era_end_date
    ,i.INGREDIENT_CONCEPT_ID AS ingredient_concept_id
  INTO #comboIngredientEras
  FROM
  #exposureEra e
  LEFT JOIN #cteDrugTarget i
    ON e.person_id = i.PERSON_ID
    AND i.DRUG_EXPOSURE_START_DATE >= e.era_start_date
    AND i.DRUG_EXPOSURE_START_DATE <= e.era_end_date;

  -- Match comination ingredient eras with regimens
  -- If an exposure era has the same ingredients as a regimen we have a match
  DROP TABLE IF EXISTS #regimenIngredientEra;

  SELECT
    drug_era_id
    ,person_id
    ,era_start_date as regimen_start_date
    ,era_end_date as regimen_end_date
    ,ingredient_concept_id
    ,regimen_id
    ,regimen_name
  INTO #regimenIngredientEra
  FROM (
    SELECT DISTINCT
      e.*,
      r.regimen_name,
      r.regimen_id,
      r.ingredient_name AS regimen_ingredient,
      r.num_ingredients_in_regimen,
      COUNT(e.ingredient_concept_id) OVER(PARTITION BY drug_era_id, regimen_id) AS num_ingredients_in_intersection
    FROM #comboIngredientEras e
    INNER JOIN (
      SELECT *, COUNT(ingredient_concept_id) OVER(PARTITION BY regimen_id) AS num_ingredients_in_regimen from #regimenIngredient
    ) r
    ON e.ingredient_concept_id = r.ingredient_concept_id
  ) cte
  WHERE num_ingredients_in_regimen = num_ingredients_in_intersection;

  DROP TABLE IF EXISTS #@regimenTableName;

  SELECT DISTINCT
    drug_era_id
    ,person_id
    ,regimen_start_date
    ,regimen_end_date
    ,regimen_id
    ,regimen_name
  INTO #@regimenTableName
  FROM #regimenIngredientEra;
  "
  rlang::inform("Calculating regimens.")
  DatabaseConnector::renderTranslateExecuteSql(con,
                                               sql,
                                               TARGET_CDMV5_SCHEMA = cdmDatabaseSchema,
                                               ingredient_ids = regimenIngredient$ingredient_concept_id,
                                               regimenTableName = regimenTableName,
                                               tempEmulationSchema = Sys.getenv("sqlRenderTempEmulationSchema"))

  sql <- SqlRender::render("SELECT COUNT(*) as n FROM #@regimenTableName", regimenTableName = regimenTableName)
  sql <- SqlRender::translate(sql, con@dbms, tempEmulationSchema = Sys.getenv("sqlRenderTempEmulationSchema"))
  n <- DatabaseConnector::dbGetQuery(con, sql)$n
  if(n == 0) warning("0 regimens found")

  if(!is.null(writeDatabaseSchema)) {
    sql <- "
    DROP TABLE IF EXISTS @writeDatabaseSchema.@regimenTableName;

    SELECT
      drug_era_id
      ,person_id
      ,regimen_start_date
      ,regimen_end_date
      ,regimen_id
      ,regimen_name
    INTO @writeDatabaseSchema.@regimenTableName
    FROM #regimenIngredientEra;"
    tryCatch(
      DatabaseConnector::renderTranslateExecuteSql(con, sql, regimenTableName = regimenTableName, writeDatabaseSchema = writeDatabaseSchema, tempEmulationSchema = Sys.getenv("sqlRenderTempEmulationSchema")),
      error = function(e) {
        message(paste0("Regimen table with ", n, " rows saved as temporary table named ", regimenTableName))
        warning(paste0("Writing regimen table to ", writeDatabaseSchema, ".", regimenTableName, " failed"))
        warning(e)
      })
    # might check that the schema exists first and user has write access
    message(paste0("Regimen table with ", n, " rows saved to ", writeDatabaseSchema, ".", regimenTableName))
  } else {
    message(paste0("Regimen table with ", n, " rows saved as temporary table named ", regimenTableName))
  }
  invisible(NULL)
}


