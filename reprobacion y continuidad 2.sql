--
-- VALIDACION V3
--

select 
tbl1.salesforce_contact_id,content_course_version,tbl1.moodle_course_id,
case 
	when (evaluacion_1<7 and (evaluacion_2 is not null or evaluacion_3 is not null or evaluacion_4 is not null or evaluacion_5 is not null or evaluacion_6 is not null or evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null))
	or (evaluacion_2<7 and (evaluacion_3 is not null or evaluacion_4 is not null or evaluacion_5 is not null or evaluacion_6 is not null or evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null))
	or (evaluacion_3<7 and (evaluacion_4 is not null or evaluacion_5 is not null or evaluacion_6 is not null or evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null)) 
	or (evaluacion_4<7 and (evaluacion_5 is not null or evaluacion_6 is not null or evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null)) 
	or (evaluacion_5<7 and (evaluacion_6 is not null or evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null)) 
	or (evaluacion_6<7 and (evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null)) 
	or (evaluacion_7<7 and (evaluacion_8 is not null or evaluacion_9 is not null)) 
	or (evaluacion_8<7 and (evaluacion_9 is not null)) then 'reprobo_continuo' else 'Bien'
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
where createddate>=to_date('2021/01/01', 'YYYY/MM/DD') and createddate<=to_date('2021/10/31', 'YYYY/MM/DD') and content_course_version not in ('V4','V4.5','V5','microcourse');


--
-- VALIDACION V4
--

select 
salesforce_contact_id,content_course_version,moodle_course_id,
case 
	when (evaluacion_1<7 and (evaluacion_2 is not null or evaluacion_3 is not null or evaluacion_4 is not null or evaluacion_5 is not null or evaluacion_6 is not null or evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null))
	or (evaluacion_2<7 and (evaluacion_3 is not null or evaluacion_4 is not null or evaluacion_5 is not null or evaluacion_6 is not null or evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null))
	or (evaluacion_3<7 and (evaluacion_4 is not null or evaluacion_5 is not null or evaluacion_6 is not null or evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null)) 
	or (evaluacion_4<7 and (evaluacion_5 is not null or evaluacion_6 is not null or evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null)) 
	or (evaluacion_5<7 and (evaluacion_6 is not null or evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null)) 
	or (evaluacion_6<7 and (evaluacion_7 is not null or evaluacion_8 is not null or evaluacion_9 is not null)) 
	or (evaluacion_7<7 and (evaluacion_8 is not null or evaluacion_9 is not null)) 
	or (evaluacion_8<7 and (evaluacion_9 is not null)) then 'reprobo_continuo' else 'Bien'
end as validacion
from 
(
select 
salesforce_contact_id,moodle_course_id,content_course_version,
max (
	case
		when evaluacion='evaluacion 1' then score
	end
	) as evaluacion_1,
max (
	case
		when evaluacion='evaluacion 2' then score
	end
	) as evaluacion_2,
max (
	case
		when evaluacion='evaluacion 3' then score
	end
	) as evaluacion_3,
max (
	case
		when evaluacion='evaluacion 4' then score
	end
	) as evaluacion_4,
max (
	case
		when evaluacion='evaluacion 5' then score
	end
	) as evaluacion_5,
max (
	case
		when evaluacion='evaluacion 6' then score
	end
	) as evaluacion_6,
max (
	case
		when evaluacion='evaluacion 7' then score
	end
	) as evaluacion_7,
max (
	case
		when evaluacion='evaluacion 8' then score
	end
	) as evaluacion_8,
max (
	case
		when evaluacion='evaluacion 9' then score
	end
	) as evaluacion_9
from 
(
select 
salesforce_contact_id,moodle_course_id,content_course_version,coursesection,
case 
	when coursesection=1 then 1
	when coursesection=2 then 2
	when coursesection=3 then 3
	when coursesection=4 then 0
	when coursesection=5 then 4
	when coursesection=6 then 5
	when coursesection=7 then 6
	when coursesection=8 then 0
	when coursesection=9 then 7
	when coursesection=10 then 8
	when coursesection=11 then 9
	when coursesection=12 then 0
end as curso,
moodle_activity_name,
case 
	when left(moodle_activity_name,1)<>'C' then concat('evaluacion ',curso) else concat('evaluacion ',left(right(moodle_activity_name,length(moodle_activity_name)-1),1)) 
end as evaluacion,
module_id,
date_trunc('minute',attempt_created_at) as attempt_date,
attempt_number,attempt_id,sum(question_score) as score,
row_number() over (partition by salesforce_contact_id,moodle_course_id,module_id
					order by score desc,attempt_number desc) as ranking_intento
from
(
select 
salesforce_contact_id,moodle_user_h5p_attempt_summary.moodle_course_id,content_course_version,moodle_course_progress.coursesection, 
moodle_course_progress.actvityname as moodle_activity_name,
moodle_course_progress.module_id,
concat(interaction_type,maxscore) as interaction_type_score,
attempt_created_at,attempt_number,attempt_id,result_id,rawscore,maxscore,
case 
	when rawscore=maxscore then 1 else 0
end as question_score
from moodle_user_h5p_attempt_summary
	left join moodle_course_progress
		on moodle_user_h5p_attempt_summary.moodle_course_module_id=moodle_course_progress.module_id
	left join moodle_course_attributes
		on moodle_user_h5p_attempt_summary.moodle_course_id=moodle_course_attributes.moodle_course_id
where content_course_version in ('V4','V4.5','V5')
		and interaction_type_score<>'compound10' and interaction_type_score<>'compound11' and interaction_type_score<>'compound12' and interaction_type_score<>'compound13'
		and interaction_type_score<>'compound14' and interaction_type_score<>'compound15' and interaction_type_score<>'compound16' and interaction_type_score<>'compound17'
		and interaction_type_score<>'compound18'
		and moodle_activity_name not like '%EP%' 
		and moodle_activity_name not like '%ntegradora%' 
		and moodle_activity_name not like '%CV%'
		and moodle_activity_name not like '%Lección%'  
		and moodle_assign_type not like '%integradora%' 
		and moodle_assign_type not like '%practica%' 
		and moodle_course_progress.actvityname not like '%ideo%' and LENGTH(salesforce_contact_id)>=2
) where moodle_course_id not in (907,780,905)
group by salesforce_contact_id,moodle_course_id,content_course_version,coursesection,moodle_activity_name,module_id,attempt_date,attempt_number,attempt_id
) group by salesforce_contact_id,moodle_course_id,content_course_version
);





--
--VALIDACION COMPOUNDS
--

select 
moodle_course_id,min(maxscore)
from 
(
select 
salesforce_contact_id,moodle_user_h5p_attempt_summary.moodle_course_id,content_course_version,moodle_course_progress.coursesection, 
moodle_course_progress.actvityname as moodle_activity_name,concat('evaluacion ',left(right(moodle_activity_name,length(moodle_activity_name)-1),1)) as prueba,
moodle_course_progress.module_id,
attempt_created_at,attempt_number,attempt_id,result_id,interaction_type,rawscore,maxscore
from moodle_user_h5p_attempt_summary
left join moodle_course_progress
		on moodle_user_h5p_attempt_summary.moodle_course_module_id=moodle_course_progress.module_id
	left join moodle_course_attributes
		on moodle_user_h5p_attempt_summary.moodle_course_id=moodle_course_attributes.moodle_course_id
where content_course_version in ('V4','V4.5','V5') and moodle_user_h5p_attempt_summary.moodle_course_id not in (907,780,905) and moodle_course_progress.actvityname not like '%ideo%'
and interaction_type='compound' and LENGTH(salesforce_contact_id)>=2 and attempt_number=1 
order by salesforce_contact_id
) group by moodle_course_id;

--
-- VALIDACION CASOS
--

select 
salesforce_contact_id,moodle_course_id,content_course_version,
max (
	case
		when evaluacion='evaluacion 1' then score
	end
	) as evaluacion_1,
max (
	case
		when evaluacion='evaluacion 2' then score
	end
	) as evaluacion_2,
max (
	case
		when evaluacion='evaluacion 3' then score
	end
	) as evaluacion_3,
max (
	case
		when evaluacion='evaluacion 4' then score
	end
	) as evaluacion_4,
max (
	case
		when evaluacion='evaluacion 5' then score
	end
	) as evaluacion_5,
max (
	case
		when evaluacion='evaluacion 6' then score
	end
	) as evaluacion_6,
max (
	case
		when evaluacion='evaluacion 7' then score
	end
	) as evaluacion_7,
max (
	case
		when evaluacion='evaluacion 8' then score
	end
	) as evaluacion_8,
max (
	case
		when evaluacion='evaluacion 9' then score
	end
	) as evaluacion_9
from 
(
select 
salesforce_contact_id,moodle_course_id,content_course_version,coursesection,
case 
	when coursesection=1 then 1
	when coursesection=2 then 2
	when coursesection=3 then 3
	when coursesection=4 then 0
	when coursesection=5 then 4
	when coursesection=6 then 5
	when coursesection=7 then 6
	when coursesection=8 then 0
	when coursesection=9 then 7
	when coursesection=10 then 8
	when coursesection=11 then 9
	when coursesection=12 then 0
end as curso,
moodle_activity_name,
case 
	when left(moodle_activity_name,1)<>'C' then concat('evaluacion ',curso) else concat('evaluacion ',left(right(moodle_activity_name,length(moodle_activity_name)-1),1)) 
end as evaluacion,
module_id,
date_trunc('minute',attempt_created_at) as attempt_date,
attempt_number,attempt_id,sum(question_score) as score,
row_number() over (partition by salesforce_contact_id,moodle_course_id,module_id
					order by score desc,attempt_number desc) as ranking_intento
from
(
select 
salesforce_contact_id,moodle_user_h5p_attempt_summary.moodle_course_id,content_course_version,moodle_course_progress.coursesection, 
moodle_course_progress.actvityname as moodle_activity_name,
moodle_course_progress.module_id,
attempt_created_at,attempt_number,attempt_id,result_id,rawscore,maxscore,
case 
	when rawscore=maxscore then 1 else 0
end as question_score
from moodle_user_h5p_attempt_summary
	left join moodle_course_progress
		on moodle_user_h5p_attempt_summary.moodle_course_module_id=moodle_course_progress.module_id
	left join moodle_course_attributes
		on moodle_user_h5p_attempt_summary.moodle_course_id=moodle_course_attributes.moodle_course_id
where content_course_version in ('V4','V4.5','V5')
		and interaction_type<>'compound'
		and moodle_activity_name not like '%EP%' 
		and moodle_activity_name not like '%ntegradora%' 
		and moodle_activity_name not like '%CV%'
		and moodle_activity_name not like '%Lección%'  
		and moodle_assign_type not like '%integradora%' 
		and moodle_assign_type not like '%practica%' 
		and moodle_course_progress.actvityname not like '%ideo%' and LENGTH(salesforce_contact_id)>=2
) where moodle_course_id not in (907,780,905) and salesforce_contact_id='0035G00001k8AWKQA2'
group by salesforce_contact_id,moodle_course_id,content_course_version,coursesection,moodle_activity_name,module_id,attempt_date,attempt_number,attempt_id
) group by salesforce_contact_id,moodle_course_id,content_course_version;

--
--
--

select 
salesforce_contact_id,moodle_course_id,content_course_version,coursesection,
case 
	when coursesection=1 then 1
	when coursesection=2 then 2
	when coursesection=3 then 3
	when coursesection=4 then 0
	when coursesection=5 then 4
	when coursesection=6 then 5
	when coursesection=7 then 6
	when coursesection=8 then 0
	when coursesection=9 then 7
	when coursesection=10 then 8
	when coursesection=11 then 9
	when coursesection=12 then 0
end as curso,
moodle_activity_name,
case 
	when left(moodle_activity_name,1)<>'C' then concat('evaluacion ',curso) else concat('evaluacion ',left(right(moodle_activity_name,length(moodle_activity_name)-1),1)) 
end as evaluacion,
module_id,
date_trunc('minute',attempt_created_at) as attempt_date,
attempt_number,attempt_id,sum(question_score) as score,
row_number() over (partition by salesforce_contact_id,moodle_course_id,module_id
					order by score desc,attempt_number desc) as ranking_intento
from
(
select 
salesforce_contact_id,moodle_user_h5p_attempt_summary.moodle_course_id,content_course_version,moodle_course_progress.coursesection, 
moodle_course_progress.actvityname as moodle_activity_name,
moodle_course_progress.module_id,
concat(interaction_type,maxscore) as interaction_type_score,
attempt_created_at,attempt_number,attempt_id,result_id,rawscore,maxscore,
case 
	when rawscore=maxscore then 1 else 0
end as question_score
from moodle_user_h5p_attempt_summary
	left join moodle_course_progress
		on moodle_user_h5p_attempt_summary.moodle_course_module_id=moodle_course_progress.module_id
	left join moodle_course_attributes
		on moodle_user_h5p_attempt_summary.moodle_course_id=moodle_course_attributes.moodle_course_id
where content_course_version in ('V4','V4.5','V5')
		and interaction_type_score<>'compound10'
		and moodle_activity_name not like '%EP%' 
		and moodle_activity_name not like '%ntegradora%' 
		and moodle_activity_name not like '%CV%'
		and moodle_activity_name not like '%Lección%'  
		and moodle_assign_type not like '%integradora%' 
		and moodle_assign_type not like '%practica%' 
		and moodle_course_progress.actvityname not like '%ideo%' and LENGTH(salesforce_contact_id)>=2
) where moodle_course_id not in (907,780,905) and salesforce_contact_id='0035G00001k8AWKQA2'
group by salesforce_contact_id,moodle_course_id,content_course_version,coursesection,moodle_activity_name,module_id,attempt_date,attempt_number,attempt_id
order by evaluacion asc;
