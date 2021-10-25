with cte as (select  distinct person_id, regimen_start_date, regimen_end_date,
              from regimeningredienttable)


select *, ROW_NUMBER() OVER (PARTITION BY person_id
	Order by person_id, regimen_start_date) as Line_of_therapy
	from cte;
