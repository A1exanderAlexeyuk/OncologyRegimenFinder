/*

CREATE TABLE @writeDatabaseSchema.episode (
episode_id bigint,
	episode_number bigint ,
	person_id bigint,
	episode_concept_id integer ,
	episode_start_datetime date ,
	episode_end_datetime date ,
	episode_parent_id text,
	episode_type_concept_id integer ,
	episode_source_value text,
	episode_source_concept_id integer,
	identity_id text NULL
);

*/

DELETE FROM   @cdmDatabaseSchema.episode *
WHERE episode_type_concept_id IN (
@episodeTypeConceptId
);

INSERT INTO @cdmDatabaseSchema.episode
(   episode_id,
    person_id,
    episode_concept_id,
    episode_start_datetime,
    episode_end_datetime,
    episode_parent_id,
    episode_number,
    episode_object_concept_id,
    episode_type_concept_id,
    episode_source_value,
    episode_source_concept_id,
    identity_id
)
SELECT
    row_number() OVER(episode_concept_id)   AS episode_id,
    row_number() OVER(partition by src.person_id
    order by regimen_start_date)            AS episode_number,
    src.person_id                           AS person_id,
    32531                                   AS episode_concept_id,          -- 'Treatment Regimen'
    src.regimen_start_date                  AS episode_start_datetime,
    src.regimen_end_date                    AS episode_end_datetime,
    NULL                                    AS episode_parent_id,
    COALESCE(src.hemonc_concept_id, 0)      AS episode_object_concept_id,
   -- 32545
    @episodeTypeConceptId                   AS episode_type_concept_id,     -- 'Episode algorithmically derived from EHR'
    NULL                                    AS episode_source_value,
    0                                       AS episode_source_concept_id,
    NULL                                    AS identity_id
FROM
    @writeDatabaseSchema.@cancerRegimenIngredients src
GROUP BY
    src.person_id,
    src.regimen,
    src.hemonc_concept_id,
    src.regimen_start_date,
    src.regimen_end_date
;



