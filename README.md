OncologyRegimenFinder
====================
This is a package specific for the OMOP СDM databases, which makes it possible to determine the regimens of  cancer therapy.

Introduction
============

Filtration of medicinal ingredients was made by searching for concepts from the HemOnc release 2021 and having a relationship_id: 
Has AB-drug cjgt Rx, Has cytotox chemo Rx, Has endocrine tx Rx, Has immunotherapy Rx, Has pept-drg cjg Rx, Has radiocjgt Rx, Has radiotherapy Rx, Has targeted tx Rx, Has antineopl Rx, Has immunosuppr Rx.
Thus, over 10.000 standard RxNorm concepts are included.

The key part of the package is located in the inst folder, where sql files are stored that can be used for 3 sql dialects: postgresql, bigquery, redshift.

SQL files are wrapped in R functions. The main function, the only one that is exported is createRegimens, which has a side effect of creating a `regimenIngredientTable` in `writeDatabaseSchema`.
R files createFunctions and Utilits are a set of helper functions for createRegimens.

The extras folder contains the CodeToRun.R file, which contains a set of requirements and necessary arguments for calling the key function of the package.

Overview
========
Algorithm for the formation of `regimenIngredientTable`.
CohortBuild.sql
At the first stage, all use cases of patients receiving anticancer therapy (including all children of standard RxNorm concepts) are collected using the DrugEra table.
RegimenCalculation.sql
Further, several successive data transformations take place to obtain ingredients grouped by dates, which will subsequently be combined into modes.
Add_groups temporary table includes grouped data with highlighting the minimum start date of treatment and left join according to the start of therapy “r2.ingredient_start_date <= (r1.ingredient_start_date) and
  r2.ingredient_start_date> = (r1.ingredient_start_date - 30)”
Thus, a table is obtained grouped according to the beginning of therapy with the capture of the 30-day interval.
Next, a temporary regimens table is formed, where ingredient (1) is marked, the date of which corresponds to the minimum value in the group
Then the regimens_to_keep table is formed, which selects records with label 1; then there is a union of the original table and regimens _to_keep, followed by the formation of regimenTable.
RawEvents.sql
Optional script that generates a table using interests and oncology of interest for possible further analysis
RegimenFormat.sql
Then the ingredients are aggregated into one cell according to the same therapy start date and number.
RegimenVocabulary.sql
An optional script, the task of which is to find a match between the found mode and the mode in HemOnc selection

Features
========
*** NOTE. The grouping at the first stage was carried out after the start date - 30, there are situations when the difference between the early and subsequent groups can be less than 30 (5-10 days), this is due to the fact that the subsequent grouping date is more than 30 in relation to the first group, but in this group there may be a date that is less than 30 more than the earlier group, so there are cases when the grouping behavior is not entirely predictable. ***

# *******************************************************
# -----------------INSTRUCTIONS -------------------------
# *******************************************************
#
#-----------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------

