WITH cte AS (SELECT person_id, regimen_start_date, regimen_end_date
      case when regimen in ("erlotinib",
                                "gefitinib",
                                "afatinib",
                                "dacomitinib",
                                "osimertinib")
              then 1 else 0 end AS 'EGFR_tyrosine_kinase_inhibitors',

      case when regimen in ('crizotinib', 'ceritinib',
                'brigatinib', 'alectinib',
                'lorlatinib', 'entrectinib',
                'capmatinib', 'selpercatinib',
                'pralsetinib', 'vandetanib',
                'cabozantinib', 'lenvatinib',
                'larotrectinib') OR regimen like ('%dabrafenib%trametinib%')
            then 1 else 0 AS 'Other_EGFR_tyrosine_kinase_inhibitors',

      case when regimen in ('pembrolizumab', 'nivolumab', 'dostarlimab') then 1
            else 0 end AS "Anti_PD_1"

      case  when regimen in ('atezolizumab', 'avelumab', 'durvalumab') then 1
            else 0 end AS "Anti_L_1",

      case when regimen in ('ipilimumab') then 1 else 0 end AS "Anti_CTLA_4",

      case  when regimen in ('cisplatin', 'carboplatin') then 1
            else 0 end AS "Platinum_doublet",

      case  when regimen in ('%pemetrexed%docetaxel%') then 1
            else 0 end AS "Single_agent",

      case  when regimen in ('bevacizumab','ranibizumab','aflibercept','ramucirumab')
            then 1 else 0 end AS "anti_VEGF_mAb"

 FROM @writeDatabaseSchema.@regimenIngredientTable )

SELECT DISTINCT c.cohort_definition_id, c.subject_id, c.cohort_start_date, 
                c.cohort_end_date, op.observation_period_start_date, 
                op.observation_period_end_date, d.death_date, 
                concept.concept_name as gender, p.year_of_birth,
       cte.*, case when EGFR_tyrosine_kinase_inhibitors = 1
        then  'Reimen_1'

      when Other_EGFR_tyrosine_kinase_inhibitors = 1
        then  'Reimen_2'

      when Platinum_doublet = 1 AND Anti_PD_1 + Platinum_doublet +
      anti-VEGF_mAb >= 2 OR  Anti_L_1  + Platinum_doublet +
      anti-VEGF_mAb >= 2 OR Platinum_doublet + Anti_CTLA_4 +  anti_VEGF_mAb = 3
        then "Regimen_4"

      when Platinum_doublet + anti_VEGF_mAb = 0 AND Anti_PD_1 + Anti_L_1
          + Anti_CTLA_4 >= 2
        then "Regimen_3"

      when Platinum_doublet + anti_VEGF_mAb >= 1 AND Anti_PD_1 + Anti_L_1
          + Anti_CTLA_4 = 0
        then "Regimen_5"

      when Platinum_doublet + Anti_PD_1 + Anti_L_1 + Anti_CTLA_4 AND
           Single_agent + anti_VEGF_mAb >= 1
        then "Regimen_6"

      else 'Other' AS 'Regimens_categories'
      
FROM @cohortDatabaseSchema.@cohortTable c
LEFT JOIN cte 
  on cte.person_id = c.subject_id 
  and cte.regimen_start_date >= DATEADD(day, -14, c.cohort_start_date)
  and cte.regimen_end_date >= c.cohort_start_date
  and cte.regimen_start_date <= c.cohort_end_date
LEFT JOIN @cdmDatabaseSchema.observation_period op
  on op.person_id = c.subject_id
  and op.observation_period_start_date <= c.cohort_start_date
  and op.observation_period_end_date >= c.cohort_end_date
LEFT JOIN @cdmDatabaseSchema.@deathTable d on d.person_id = c.subject_id
LEFT JOIN @cdmDatabaseSchema.person p on c.subject_id = p.person_id
LEFT JOIN @cdmDatabaseSchema.concept on concept.concept_id = p.gender_concept_id
ORDER BY c.cohort_definition_id, c.subject_id, cte.regimen_start_date
    
