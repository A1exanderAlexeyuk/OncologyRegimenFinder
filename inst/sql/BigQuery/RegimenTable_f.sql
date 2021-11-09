DROP TABLE IF EXISTS  @writeDatabaseSchema.@regimenTable_f;
    CREATE TABLE @writeDatabaseSchema.@regimenTable_f (
       person_id bigint not null,
       drug_era_id bigint,
       concept_name string,
       ingredient_start_date date not null
    )
