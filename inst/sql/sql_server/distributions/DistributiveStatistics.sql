     details   AS (
                  SELECT cohort_definition_id,
                         value,
                         ROW_NUMBER() OVER (PARTITION BY
                         cohort_definition_id ORDER BY value) AS row_number,
                         SUM(1) OVER (PARTITION BY cohort_definition_id) AS total
                  FROM init_data
                  ),
     quartiles AS (
                  SELECT cohort_definition_id,
                         value,
                         AVG(CASE
                                 WHEN row_number >= (FLOOR(total / 2.0) / 2.0)
                                     AND row_number <= (FLOOR(total / 2.0) / 2.0) + 1
                                     THEN value / 1.0
                             END
                             ) OVER (PARTITION BY cohort_definition_id) AS q1,
                         AVG(CASE
                                 WHEN row_number >= (total / 2.0)
                                     AND row_number <= (total / 2.0) + 1
                                     THEN value / 1.0
                             END
                             ) OVER (PARTITION BY cohort_definition_id) AS median,
                         AVG(CASE
                                 WHEN row_number >= (CEIL(total / 2.0) + (FLOOR(total / 2.0) / 2.0))
                                     AND row_number <= (CEIL(total / 2.0) + (FLOOR(total / 2.0) / 2.0) + 1)
                                     THEN value / 1.0
                             END
                             ) OVER (PARTITION BY cohort_definition_id) AS q3,

                             power((value - avg(value) OVER
                             (PARTITION BY cohort_definition_id)), 2) / (total -1)
		 						as Variance,
		 	(avg(value) OVER (PARTITION BY cohort_definition_id))
		 	as mean

                  FROM details

                  where total > 1 -- to prevent devision on 0

                  )
SELECT  cohort_definition_id,
        ROUND (AVG(q3) - AVG(q1),1) AS IQR,
        ROUND (MIN(value),1) AS minimum,
        ROUND (AVG(q1),1) AS q1,
        ROUND (AVG(median),1) AS median,
        ROUND (AVG(q3),1) AS q3,
        ROUND (MAX(value),1) AS maximum,
        ROUND (AVG(mean) ,1) as mean,
        ROUND (sqrt(SUM(Variance)), 1) as std,
       '@analysis_name' AS analysis_name

FROM quartiles
GROUP BY 1;
