DROP TABLE IF EXISTS @writeDatabaseSchema.@sampledRegimenTable;
     SELECT person_id, drug_era_id, concept_name, ingredient_start_date
     into @writeDatabaseSchema.@sampledRegimenTable
     FROM @writeDatabaseSchema.@regimenTable
     WHERE rn >= @start AND rn <= @end;
