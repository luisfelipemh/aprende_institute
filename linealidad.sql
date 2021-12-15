-- VALIDACION GENERAL, TODAS LAS VERSIONES

select 
salesforce_contact_id, COUNT(distinct moodle_course_id) as n_diplomados,
count(distinct case when linealidad='no_lineal' then moodle_course_id end) as diplomados_no_lineal,
count(distinct case when linealidad='si_lineal' then moodle_course_id end) as diplomados_si_lineal,
case 
	when diplomados_si_lineal>=1 and diplomados_no_lineal=0 then 'lineales_todos_sus_diplomados'
	when diplomados_si_lineal=0 and diplomados_no_lineal>=1  then 'no_lineales_todos_sus_diplomados'
	when diplomados_si_lineal>=1 and diplomados_no_lineal>=1  then 'mezclado'
end as categorias
from
(
select salesforce_contact_id,moodle_course_id,
case 
	when sum(lineal)>=1 then 'no_lineal' else 'si_lineal'
end as linealidad
from 
	(
select salesforce_contact_id,moodle_course_id,moodle_activitytype,moodle_activity_name,
		activity_index,module_id,moodle_activity_completion_date,
		row_number() over (partition by salesforce_contact_id,moodle_course_id order by moodle_activity_completion_date asc) as ranking_completion_date,
		row_number() over (partition by moodle_module_activity_summary.salesforce_contact_id,moodle_module_activity_summary.moodle_course_id 
							order by activity_index asc) as ranking_activity_index,	
		case
			when ranking_activity_index<>ranking_completion_date then 1 else 0
		end as lineal,					
		case
			when moodle_grade>=20 then moodle_grade/10 else moodle_grade
		end as moodle_grade_stand
from moodle_module_activity_summary 
		where moodle_activitytype like '%uiz%' 
		and content_completion_required=1 
		and moodle_activity_name not like '%EP%' 
		and moodle_activity_name not like '%ntegradora%' 
		and moodle_activity_name not like '%CV%' 
		and moodle_assign_type not like '%integradora%' 
		and moodle_assign_type not like '%practica%' 
		and LENGTH(salesforce_contact_id)>=2
		and created_date>=to_date('2021/01/01', 'YYYY/MM/DD') and created_date<=to_date('2021/10/31', 'YYYY/MM/DD')
		)
group by salesforce_contact_id,moodle_course_id
) group by salesforce_contact_id;

-- VALIDACION GENERAL SOLO PARA V3

select 
salesforce_contact_id, COUNT(distinct moodle_course_id) as n_diplomados,
count(distinct case when linealidad='no_lineal' then moodle_course_id end) as diplomados_no_lineal,
count(distinct case when linealidad='si_lineal' then moodle_course_id end) as diplomados_si_lineal,
case 
	when diplomados_si_lineal>=1 and diplomados_no_lineal=0 then 'lineales_todos_sus_diplomados'
	when diplomados_si_lineal=0 and diplomados_no_lineal>=1  then 'no_lineales_todos_sus_diplomados'
	when diplomados_si_lineal>=1 and diplomados_no_lineal>=1  then 'mezclado'
end as categorias
from
(
select salesforce_contact_id,moodle_course_id,content_course_version,
case 
	when sum(lineal)>=1 then 'no_lineal' else 'si_lineal'
end as linealidad
from 
		(
select moodle_module_activity_summary.salesforce_contact_id,created_date,moodle_module_activity_summary.moodle_course_id,content_course_version,moodle_activitytype,moodle_activity_name,
		activity_index,module_id,moodle_activity_completion_date,
		row_number() over (partition by moodle_module_activity_summary.salesforce_contact_id,moodle_module_activity_summary.moodle_course_id 
							order by moodle_activity_completion_date asc) as ranking_completion_date,
		row_number() over (partition by moodle_module_activity_summary.salesforce_contact_id,moodle_module_activity_summary.moodle_course_id 
							order by activity_index asc) as ranking_activity_index,	
		case
			when ranking_activity_index<>ranking_completion_date then 1 else 0
		end as lineal,					
		case
			when moodle_grade>=20 then moodle_grade/10 else moodle_grade
		end as moodle_grade_stand
from moodle_module_activity_summary
LEFT JOIN aprende.moodle_course_attributes
      	ON ( moodle_module_activity_summary.moodle_course_id = moodle_course_attributes.moodle_course_id )
		where moodle_activitytype like '%uiz%' 
		and content_completion_required=1 
		and moodle_activity_name not like '%EP%' 
		and moodle_activity_name not like '%ntegradora%' 
		and moodle_activity_name not like '%CV%' 
		and moodle_assign_type not like '%integradora%' 
		and moodle_assign_type not like '%practica%' 
		and LENGTH(salesforce_contact_id)>=2
		and created_date>=to_date('2021/01/01', 'YYYY/MM/DD') and created_date<=to_date('2021/10/31', 'YYYY/MM/DD')
		)
		where content_course_version='V3'
		group by salesforce_contact_id,moodle_course_id,content_course_version
) group by salesforce_contact_id;

-- CONTEO GENERAL

select 
count(distinct salesforce_contact_id) as estudiantes_general,
count(distinct case when categorias='lineales_todos_sus_diplomados' then salesforce_contact_id end) as lineales_todos_sus_diplomados,
count(distinct case when categorias='no_lineales_todos_sus_diplomados' then salesforce_contact_id end) as no_lineales_todos_sus_diplomados,
count(distinct case when categorias='mezclado' then salesforce_contact_id end) as mezclado
from
(
select 
salesforce_contact_id, COUNT(distinct moodle_course_id) as n_diplomados,
count(distinct case when linealidad='no_lineal' then moodle_course_id end) as diplomados_no_lineal,
count(distinct case when linealidad='si_lineal' then moodle_course_id end) as diplomados_si_lineal,
case 
	when diplomados_si_lineal>=1 and diplomados_no_lineal=0 then 'lineales_todos_sus_diplomados'
	when diplomados_si_lineal=0 and diplomados_no_lineal>=1  then 'no_lineales_todos_sus_diplomados'
	when diplomados_si_lineal>=1 and diplomados_no_lineal>=1  then 'mezclado'
end as categorias
from
(
select salesforce_contact_id,moodle_course_id,
case 
	when sum(lineal)>=1 then 'no_lineal' else 'si_lineal'
end as linealidad
from 
	(
select salesforce_contact_id,moodle_course_id,moodle_activitytype,moodle_activity_name,
		activity_index,module_id,moodle_activity_completion_date,
		row_number() over (partition by salesforce_contact_id,moodle_course_id order by moodle_activity_completion_date asc) as ranking_completion_date,
		row_number() over (partition by moodle_module_activity_summary.salesforce_contact_id,moodle_module_activity_summary.moodle_course_id 
							order by activity_index asc) as ranking_activity_index,	
		case
			when ranking_activity_index<>ranking_completion_date then 1 else 0
		end as lineal,					
		case
			when moodle_grade>=20 then moodle_grade/10 else moodle_grade
		end as moodle_grade_stand
from moodle_module_activity_summary 
		where moodle_activitytype like '%uiz%' 
		and content_completion_required=1 
		and moodle_activity_name not like '%EP%' 
		and moodle_activity_name not like '%ntegradora%' 
		and moodle_activity_name not like '%CV%' 
		and moodle_assign_type not like '%integradora%' 
		and moodle_assign_type not like '%practica%' 
		and LENGTH(salesforce_contact_id)>=2
		and created_date>=to_date('2021/01/01', 'YYYY/MM/DD') and created_date<=to_date('2021/10/31', 'YYYY/MM/DD')
		)
group by salesforce_contact_id,moodle_course_id
) group by salesforce_contact_id
);

-- CONTEO GENERAL V3

select 
count(distinct salesforce_contact_id) as estudiantes_v3,
count(distinct case when categorias='lineales_todos_sus_diplomados' then salesforce_contact_id end) as lineales_todos_sus_diplomados,
count(distinct case when categorias='no_lineales_todos_sus_diplomados' then salesforce_contact_id end) as no_lineales_todos_sus_diplomados,
count(distinct case when categorias='mezclado' then salesforce_contact_id end) as mezclado
from 
(
select 
salesforce_contact_id, COUNT(distinct moodle_course_id) as n_diplomados,
count(distinct case when linealidad='no_lineal' then moodle_course_id end) as diplomados_no_lineal,
count(distinct case when linealidad='si_lineal' then moodle_course_id end) as diplomados_si_lineal,
case 
	when diplomados_si_lineal>=1 and diplomados_no_lineal=0 then 'lineales_todos_sus_diplomados'
	when diplomados_si_lineal=0 and diplomados_no_lineal>=1  then 'no_lineales_todos_sus_diplomados'
	when diplomados_si_lineal>=1 and diplomados_no_lineal>=1  then 'mezclado'
end as categorias
from
(
select salesforce_contact_id,moodle_course_id,content_course_version,
case 
	when sum(lineal)>=1 then 'no_lineal' else 'si_lineal'
end as linealidad
from 
		(
select moodle_module_activity_summary.salesforce_contact_id,created_date,moodle_module_activity_summary.moodle_course_id,content_course_version,moodle_activitytype,moodle_activity_name,
		activity_index,module_id,moodle_activity_completion_date,
		row_number() over (partition by moodle_module_activity_summary.salesforce_contact_id,moodle_module_activity_summary.moodle_course_id 
							order by moodle_activity_completion_date asc) as ranking_completion_date,
		row_number() over (partition by moodle_module_activity_summary.salesforce_contact_id,moodle_module_activity_summary.moodle_course_id 
							order by activity_index asc) as ranking_activity_index,	
		case
			when ranking_activity_index<>ranking_completion_date then 1 else 0
		end as lineal,					
		case
			when moodle_grade>=20 then moodle_grade/10 else moodle_grade
		end as moodle_grade_stand
from moodle_module_activity_summary
LEFT JOIN aprende.moodle_course_attributes
      	ON ( moodle_module_activity_summary.moodle_course_id = moodle_course_attributes.moodle_course_id )
		where moodle_activitytype like '%uiz%' 
		and content_completion_required=1 
		and moodle_activity_name not like '%EP%' 
		and moodle_activity_name not like '%ntegradora%' 
		and moodle_activity_name not like '%CV%' 
		and moodle_assign_type not like '%integradora%' 
		and moodle_assign_type not like '%practica%' 
		and LENGTH(salesforce_contact_id)>=2
		and created_date>=to_date('2021/01/01', 'YYYY/MM/DD') and created_date<=to_date('2021/10/31', 'YYYY/MM/DD')
		)
		where content_course_version='V3'
		group by salesforce_contact_id,moodle_course_id,content_course_version
) group by salesforce_contact_id
);
