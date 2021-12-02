# create a dataframe with the hemonc regimens and all ingredients in each regimen

library(DatabaseConnector)

cd <- createConnectionDetails("sqlite", server = "inst/sqlite/testdb.sqlite")

con <- connect(cd)

# disconnect(con)

regimens <- dbGetQuery(con, "
            select
                 c.concept_name as regimen_name,
                 c.concept_id as regimen_id,
                 c2.concept_name as ingredient_name,
                 c2.concept_id as ingredient_concept_id
           from concept c
           left join concept_relationship cr on c.concept_id = cr.concept_id_1
           left join concept c2 on cr.concept_id_2 = c2.concept_id
           where c.vocabulary_id = 'HemOnc'
                and c.domain_id = 'Regimen'
                and cr.relationship_id = 'Has antineopl Rx'
                and c2.concept_class_id = 'Ingredient'
                and c2.vocabulary_id = 'RxNorm'") %>%
  tibble()

regimens %>%
  filter(ingredient_concept_id == 1112807) %>%  # aspirin
  readr::write_csv("work/regimenIngredients.csv")
