select license_start_week,student_id,email,
cast(moodle_course_id as nvarchar(3))+'-'+email as id_email,
moodle_course_id,week_info,
case
	when moodle_course_id=562 or moodle_course_id=498 or moodle_course_id=509 then extract(week from date_trunc('week',week_info))-extract(week from date_trunc('week',license_start_week))
	when moodle_course_id=941 or moodle_course_id=942 or moodle_course_id=943 then extract(week from date_trunc('week',week_info))-extract(week from to_date('2021/11/22', 'YYYY/MM/DD'))
end as progress_start_week_new,
has_login 
from cohort_week_diplomado
left join aprende.contact
    	on (cohort_week_diplomado.student_id=contact.id)
where moodle_course_id in (941,942,943,562,498,509)
and license_start_week>=to_date('2021/10/10', 'YYYY/MM/DD') and license_start_week <=to_date('2021/11/22', 'YYYY/MM/DD')
and email not like '%aprende%';









select salesforce_contact_id,moodle_module_activity_summary.moodle_course_id,content_course_version,moodle_activity_name,
case 
	when content_course_version='V4' then concat('evaluacion ',left(right(moodle_activity_name,length(moodle_activity_name)-1),1)) 
	else concat('evaluacion ',left(reverse(moodle_activity_name),1))
end as evaluación,	
date_trunc('week',moodle_activity_completion_date) as week_completion_date
from moodle_module_activity_summary
LEFT JOIN moodle_course_attributes
      	ON ( moodle_module_activity_summary.moodle_course_id = moodle_course_attributes.moodle_course_id )
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
		and moodle_module_activity_summary.moodle_course_id in (941,942,943,562,498,509);
	
	
select salesforce_contact_id,moodle_course_id,evaluacion,week_completion_date 
from
(
select salesforce_contact_id,moodle_module_activity_summary.moodle_course_id,content_course_version,moodle_activity_name,
case 
	when content_course_version='V4' then concat('evaluacion ',left(right(moodle_activity_name,length(moodle_activity_name)-1),1)) 
	else concat('evaluacion ',left(reverse(moodle_activity_name),1))
end as evaluacion,	
date_trunc('week',moodle_activity_completion_date) as week_completion_date
from moodle_module_activity_summary
LEFT JOIN moodle_course_attributes
      	ON ( moodle_module_activity_summary.moodle_course_id = moodle_course_attributes.moodle_course_id )
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
		and moodle_module_activity_summary.moodle_course_id in (941,942,943,562,498,509)
);




select salesforce_contact_id,moodle_course_id,
min (
	case
		when evaluacion='evaluacion 1' then week_completion_date
	end) as evaluacion_1,
min (
	case
		when evaluacion='evaluacion 2' then week_completion_date
	end) as evaluacion_2,
min (
	case
		when evaluacion='evaluacion 3' then week_completion_date
	end) as evaluacion_3,
min (
	case
		when evaluacion='evaluacion 4' then week_completion_date
	end) as evaluacion_4,
min (
	case
		when evaluacion='evaluacion 5' then week_completion_date
	end) as evaluacion_5,
min (
	case
		when evaluacion='evaluacion 6' then week_completion_date
	end) as evaluacion_6,
min (
	case
		when evaluacion='evaluacion 7' then week_completion_date
	end) as evaluacion_7,
min (
	case
		when evaluacion='evaluacion 8' then week_completion_date
	end) as evaluacion_8,
min (
	case
		when evaluacion='evaluacion 9' then week_completion_date
	end) as evaluacion_9
from
(
select salesforce_contact_id,moodle_module_activity_summary.moodle_course_id,content_course_version,moodle_activity_name,
case 
	when content_course_version='V4' then concat('evaluacion ',left(right(moodle_activity_name,length(moodle_activity_name)-1),1)) 
	else concat('evaluacion ',left(reverse(moodle_activity_name),1))
end as evaluacion,	
date_trunc('week',moodle_activity_completion_date) as week_completion_date
from moodle_module_activity_summary
LEFT JOIN moodle_course_attributes
      	ON ( moodle_module_activity_summary.moodle_course_id = moodle_course_attributes.moodle_course_id )
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
		and moodle_module_activity_summary.moodle_course_id in (941,942,943,562,498,509)
) group by salesforce_contact_id,moodle_course_id;


-- LEFT JOIN DOS TABLAS dateadd(WEEK,1,week_info)

select
date_trunc('week',license_start_week) as week_license,student_id,email,id_email,tbl1.moodle_course_id,date_trunc('week',week_info) as week_info,progress_start_week_new,has_login,
evaluacion_1,evaluacion_2,evaluacion_3,evaluacion_4,evaluacion_5,evaluacion_6,evaluacion_7,evaluacion_8,evaluacion_9,
	case 
    	when evaluacion_1 <= dateadd(WEEK,1,week_info) then 1 else 0 
    end as evaluacion1_completed,
    case 
    	when evaluacion_2 <= dateadd(WEEK,1,week_info) then 1 else 0 
    end as evaluacion2_completed,
    case 
    	when evaluacion_3 <= dateadd(WEEK,1,week_info) then 1 else 0 
    end as evaluacion3_completed,
    case 
    	when evaluacion_4 <= dateadd(WEEK,1,week_info) then 1 else 0 
    end as evaluacion4_completed,
    case 
    	when evaluacion_5 <= dateadd(WEEK,1,week_info) then 1 else 0 
    end as evaluacion5_completed,
    case 
    	when evaluacion_6 <= dateadd(WEEK,1,week_info) then 1 else 0 
    end as evaluacion6_completed,
    case 
    	when evaluacion_7 <= dateadd(WEEK,1,week_info) then 1 else 0 
    end as evaluacion7_completed,
    case 
    	when evaluacion_8 <= dateadd(WEEK,1,week_info) then 1 else 0 
    end as evaluacion8_completed,
    case 
    	when evaluacion_9 <= dateadd(WEEK,1,week_info) then 1 else 0 
    end as evaluacion9_completed,
    evaluacion1_completed+evaluacion2_completed+evaluacion3_completed+evaluacion4_completed+evaluacion5_completed+evaluacion6_completed+evaluacion7_completed+evaluacion8_completed+evaluacion9_completed
    	as total_evaluaciones
from 
(
select license_start_week,student_id,email,
cast(moodle_course_id as nvarchar(3))+'-'+email as id_email,
moodle_course_id,week_info,
case
	when moodle_course_id=562 or moodle_course_id=498 or moodle_course_id=509 then extract(week from date_trunc('week',week_info))-extract(week from date_trunc('week',license_start_week))
	when moodle_course_id=941 or moodle_course_id=942 or moodle_course_id=943 then extract(week from date_trunc('week',week_info))-extract(week from to_date('2021/11/22', 'YYYY/MM/DD'))
end as progress_start_week_new,
has_login 
from cohort_week_diplomado
left join aprende.contact
    	on (cohort_week_diplomado.student_id=contact.id)
where moodle_course_id in (941,942,943,562,498,509)
and license_start_week>=to_date('2021/10/10', 'YYYY/MM/DD') and license_start_week <=to_date('2021/11/22', 'YYYY/MM/DD')
) as tbl1
left join
(
select salesforce_contact_id,moodle_course_id,
min (
	case
		when evaluacion='evaluacion 1' then week_completion_date
	end) as evaluacion_1,
min (
	case
		when evaluacion='evaluacion 2' then week_completion_date
	end) as evaluacion_2,
min (
	case
		when evaluacion='evaluacion 3' then week_completion_date
	end) as evaluacion_3,
min (
	case
		when evaluacion='evaluacion 4' then week_completion_date
	end) as evaluacion_4,
min (
	case
		when evaluacion='evaluacion 5' then week_completion_date
	end) as evaluacion_5,
min (
	case
		when evaluacion='evaluacion 6' then week_completion_date
	end) as evaluacion_6,
min (
	case
		when evaluacion='evaluacion 7' then week_completion_date
	end) as evaluacion_7,
min (
	case
		when evaluacion='evaluacion 8' then week_completion_date
	end) as evaluacion_8,
min (
	case
		when evaluacion='evaluacion 9' then week_completion_date
	end) as evaluacion_9
from
(
select salesforce_contact_id,moodle_module_activity_summary.moodle_course_id,content_course_version,moodle_activity_name,
case 
	when content_course_version='V4' then concat('evaluacion ',left(right(moodle_activity_name,length(moodle_activity_name)-1),1)) 
	else concat('evaluacion ',left(reverse(moodle_activity_name),1))
end as evaluacion,	
date_trunc('week',moodle_activity_completion_date) as week_completion_date
from moodle_module_activity_summary
LEFT JOIN moodle_course_attributes
      	ON ( moodle_module_activity_summary.moodle_course_id = moodle_course_attributes.moodle_course_id )
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
		and moodle_module_activity_summary.moodle_course_id in (941,942,943,562,498,509)
) group by salesforce_contact_id,moodle_course_id
) as tbl2
on tbl1.student_id=tbl2.salesforce_contact_id and tbl1.moodle_course_id=tbl2.moodle_course_id
where email not like '%aprende%' and email not in 
('942-acarreon29@hotmail.com',
'942-cesariorivera210@gmail.com',
'942-efrainvnieves@gmail.com',
'562-g.garciaenrique@gmail.com',
'942-grato11@hotmail.com',
'942-grupoaztecar@hotmail.com',
'942-irving9873@gmail.com',
'942-jazbequi@gmail.com',
'562-jhoset7428@gmail.com',
'562-jopasr8@gmail.com',
'942-lbw412construction@gmail.com',
'942-littleboy383@hotmail.com',
'942-mayaguilar30@gmail.com',
'942-puchoivebervil20@gmail.com',
'942-stephanedesgrottes@yahoo.fr',
'498-alejamaz1405@hotmail.com',
'498-analuavila44@gmail.com',
'943-ariasriosadriana@gmail.com',
'943-claudia.c.services@gmail.com',
'943-fer0408@hotmail.com',
'498-fervillesp@gmail.com',
'498-geraldinepadronmorales@gmail.com',
'943-harvelo@armisglobal.com',
'943-ivettevr2210@gmail.com',
'943-luciamedina1485@gmail.com',
'498-lunazora999@hotmail.com',
'943-marcela@europe.com',
'943-marelyvalverde@hotmail.com',
'943-martha-munoz@outlook.com',
'943-ordonez.maria7900@gmail.com',
'943-rojashermy@yahoo.com',
'942-reyeslopez123@hotmail.com',
'943-buendiaivi@gmail.com',
'942-dixjarquin@gmail.com',
'942-humvil2@hotmail.com',
'942-mymurillo@gmail.com',
'942-osw_vill@hotmail.com')
order by salesforce_contact_id, progress_start_week_new asc;
