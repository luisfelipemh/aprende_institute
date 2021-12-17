select 
tbl1.salesforce_contact_id,content_course_version,tbl1.moodle_course_id,
case 
	when (evaluacion_1<7 and evaluacion_2 is not null)
	or (evaluacion_2<7 and evaluacion_3 is not null)
	or (evaluacion_3<7 and evaluacion_4 is not null) 
	or (evaluacion_4<7 and evaluacion_5 is not null) 
	or (evaluacion_5<7 and evaluacion_6 is not null) 
	or (evaluacion_6<7 and evaluacion_7 is not null) 
	or (evaluacion_7<7 and evaluacion_8 is not null) 
	or (evaluacion_8<7 and evaluacion_9 is not null) then 'reprobo_continuo' else 'Bien'
end as validacion
from 
(
select
salesforce_contact_id,
moodle_course_id,
max (
	case
		when ranking_activity_index=1 then moodle_grade_new
	end
	) as evaluacion_1,
max (
	case
		when ranking_activity_index=2 then moodle_grade_new
	end
	) as evaluacion_2,
max (
	case
		when ranking_activity_index=3 then moodle_grade_new
	end
	) as evaluacion_3,
max (
	case
		when ranking_activity_index=4 then moodle_grade_new
	end
	) as evaluacion_4,
max (
	case
		when ranking_activity_index=5 then moodle_grade_new
	end
	) as evaluacion_5,
max (
	case
		when ranking_activity_index=6 then moodle_grade_new
	end
	) as evaluacion_6,
max (
	case
		when ranking_activity_index=7 then moodle_grade_new
	end
	) as evaluacion_7,
max (
	case
		when ranking_activity_index=8 then moodle_grade_new
	end
	) as evaluacion_8,
max (
	case
		when ranking_activity_index=9 then moodle_grade_new
	end
	) as evaluacion_9
from 
(
select 
salesforce_contact_id,moodle_course_id,moodle_activitytype,moodle_activity_name,
activity_index,module_id,moodle_activity_completion_date,
	case
		when moodle_grade>=11 then moodle_grade/10 else moodle_grade
	end as moodle_grade_new,
row_number() over (partition by moodle_module_activity_summary.salesforce_contact_id,moodle_module_activity_summary.moodle_course_id 
					order by activity_index asc) as ranking_activity_index
from moodle_module_activity_summary
where 	content_completion_required=1
		and (moodle_activitytype like '%uiz%' or moodle_activitytype like '%h5p%' or moodle_activitytype like '%hvp%')
		and content_completion_required=1 
		and moodle_activity_name not like '%EP%' 
		and moodle_activity_name not like '%ntegradora%' 
		and moodle_activity_name not like '%CV%'
		and moodle_activity_name not like '%ideo%'
		and moodle_activity_name not like '%Lección%' 
		and moodle_activity_name not like '%Dinámica%' 
		and moodle_assign_type not like '%integradora%' 
		and moodle_assign_type not like '%practica%' 
		and LENGTH(salesforce_contact_id)>=2
)
group by salesforce_contact_id,moodle_course_id
) as tbl1
left join aprende.moodle_course_attributes
      	on ( tbl1.moodle_course_id = moodle_course_attributes.moodle_course_id )
left join aprende.contact
    	on (tbl1.salesforce_contact_id=contact.id)
where createddate>=to_date('2021/01/01', 'YYYY/MM/DD') and createddate<=to_date('2021/10/31', 'YYYY/MM/DD');










		
