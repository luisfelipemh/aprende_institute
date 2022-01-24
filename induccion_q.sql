
-- fecha de compra/venta y primer acceso CHECK

select id,createddate,moodle_user_first_access__c,onboarding_date__c,onboarding_status__c,
extract (hour from moodle_user_first_access__c-createddate) 
from contact where isdeleted=0;

-- clase en vivo de induccion CHECK 

select *
from
(
select salesforce_contact_id_atendee,email,id,start_time,join_time,leave_time,duration_in_seconds,
round(duration_in_seconds/60,0) as duration_in_minutos,
case 
	when join_time is not null then 1 else 0
end as asistencia_cv_induccion,
row_number() over (partition by salesforce_contact_id_atendee
				  order by (case when join_time is not null then join_time else to_date('9999-01-01', 'YYYY-MM-DD') end), join_time asc) as first_class
from zoom_induction_meeting_new
where length(salesforce_contact_id_atendee)>=1
)
where first_class=1;

select * from zoom_induction_meeting_new;

-- Diplomado de induccion CHECK

select student_id,moodle_course_id,max(is_complete) as is_complete_658,date(min(graduation_date)) as graduation_date_658
from cohort_natural_week_diplomado
where moodle_course_id=658
group by student_id,moodle_course_id;


-- Fecha primer login

select student_id,has_login,min(day_info) as fecha_primer_login from cohort_day
where has_login=1
group by student_id,has_login;

-- Fecha de la primera actividad, poner el content_completion_required?

select salesforce_contact_id,min(moodle_activity_completion_date) as fecha_primer_ogin
from moodle_module_activity_summary
group by salesforce_contact_id;

-- Fecha de graduacion

select student_id,min(first_graduation_date) as min_graduation_date,max(last_graduation_date) as max_graduation_date
from cohort_day
group by student_id;

select onboar from contact;

--
--dataset induccion
-- 

select date(contact.createddate) as createddate,cohort_day.student_id,contact.email,
case 
	when moodle_user_first_access__c is not null then 1 else 0
end as is_active__ob,
date(moodle_user_first_access__c) as moodle_user_first_access__c,date(cohort_day.onboarding_date__c) as onboarding_date__c,cohort_day.onboarding_status__c,
case 
	when cohort_day.onboarding_status__c='Done' then 1 else 0
end as onboarding_done,
case 
	when onboarding_done=1 then extract(day from cohort_day.onboarding_date__c-cohort_day.createddate) else null
end as onboarding_days_since_create,
case 
	when moodle_user_first_access__c is not null then extract(day from moodle_user_first_access__c-cohort_day.createddate) else null
end as activation_days_since_create,
case 
	when onboarding_done=1 and Moodle_User_Last_Access__c>=cohort_day.onboarding_date__c then 1 else 0
end as login_after_onboarding,
first_login_date,
first_activity_date,
date(dateadd(day,1,first_activity_date)) as first_activity_plus_one,
graduation_date,
is_complete_658,
graduation_date_658,
induction_id_cv,
attendance_induction_cv,
start_time as induction_cv_start_time,
duration_in_minutos as induction_cv_duration,
date(day_info) as day_info,
round(extract(hour from day_info-contact.createddate)/24,0) as progress_start_day,
round(extract(hour from day_info-contact.onboarding_date__c)/24,0) as progress_start_onboarding,
round(extract(hour from day_info-moodle_user_first_access__c)/24,0) as progress_start_activation,
has_login as has_login__cd,
case 
	when evaluaciones_completadas is null then 0 else evaluaciones_completadas
end as evaluaciones_completadas__cd,
sum(evaluaciones_completadas__cd) over (partition by cohort_day.student_id order by day_info rows unbounded preceding) as evaluaciones_completadas_cum__cd,
case 
	when cv_atendidas is null then 0 else cv_atendidas
end as cv_atendidas__cd,
sum(cv_atendidas__cd) over (partition by cohort_day.student_id order by day_info rows unbounded preceding) as cv_atendidas_cum__cd
from cohort_day
	left join contact
		on student_id=id
	left join
	(
		select salesforce_contact_id,is_complete as is_complete_658,date(min(last_activity_completion_date)) as graduation_date_658
		from moodle_user_course_completion_summary
		where is_complete=1 and moodle_user_course_completion_summary.moodle_course_id=658
		group by salesforce_contact_id,is_complete
	) as tbl1
	on cohort_day.student_id=tbl1.salesforce_contact_id
	left join
	(
		select *
		from
		(
			select salesforce_contact_scheduled,salesforce_contact_id_atendee,email,id as induction_id_cv,start_time,join_time,leave_time,duration_in_seconds,
			case
				when join_time is not null then round(duration_in_seconds/60,0) else null
			end as duration_in_minutos,
			case 
				when join_time is not null then 1 else 0
			end as attendance_induction_cv,
			row_number() over (partition by salesforce_contact_scheduled order by start_time asc) as first_class
			from zoom_induction_meeting_new
		)
			where first_class=1
	) as tbl2
	on cohort_day.student_id=salesforce_contact_scheduled
	left join 
	(
		select 
		salesforce_contact_id,date(moodle_activity_completion_date) as completion_date,count(distinct diplomado_evaluacion) as evaluaciones_completadas
		from
		(
			select 
			salesforce_contact_id,moodle_module_activity_summary.moodle_course_id,content_course_version,moodle_activity_name,coursesection,moodle_activity_completion_date,
			case
				when coursesection<=12 and coursesection is not null then 'evaluacion - ' || coursesection  else concat('evaluacion - ',left(right(moodle_activity_name,length(moodle_activity_name)-1),1)) 
			end as evaluacion1,
			case 
				when evaluacion1 like '%- i%'
    			OR evaluacion1 like '%- v%' then concat('evaluacion - ',right(left(moodle_activity_name,11),1)) else evaluacion1
			end as evaluacion,
			moodle_module_activity_summary.moodle_course_id || ' - ' || evaluacion as diplomado_evaluacion
			from moodle_module_activity_summary
			left join moodle_course_attributes 
			on moodle_module_activity_summary.moodle_course_id=moodle_course_attributes.moodle_course_id
			where 	content_completion_required=1
				and (moodle_activitytype like '%uiz%' or moodle_activitytype like '%h5p%' or moodle_activitytype like '%hvp%')
				and content_completion_required=1 
				and moodle_activity_name not like '%EP%' 
				and moodle_activity_name not like '%ntegradora%' 
				and moodle_activity_name not like '%CV%'
				and moodle_activity_name not like '%ideo%'
				and moodle_activity_name not like '%Lección%' 
				and moodle_activity_name not like '%nteractivo%' 
				and moodle_assign_type not like '%integradora%' 
				and moodle_assign_type not like '%practica%' 
				and LENGTH(salesforce_contact_id)>=2
				and content_course_version<>'microcourse'
		) group by salesforce_contact_id,date(moodle_activity_completion_date)
	) as tbl3
	on cohort_day.student_id=tbl3.salesforce_contact_id
	and cohort_day.day_info=tbl3.completion_date
	left join
	(
		select salesforce_contact_id,zoom_webinar_date,count(distinct zoom_webinar_id) as cv_atendidas
		from
		(
			select salesforce_contact_id,zoom_webinar_id,date(zoom_webinar_date) as zoom_webinar_date
			from zoom_webinar_user_summary
			where zoom_webinar_attendance_join_time is not null
		)
		group by salesforce_contact_id,date(zoom_webinar_date)
	) as tbl4
	on  cohort_day.student_id=tbl4.salesforce_contact_id
	and cohort_day.day_info=tbl4.zoom_webinar_date
	left join 
	(
		select student_id,date(min(day_info)) as first_login_date from cohort_day
		where has_login=1
		group by student_id,has_login
	) as tbl5
	on  cohort_day.student_id=tbl5.student_id
	left join 
	(
		select salesforce_contact_id,date(min(moodle_activity_completion_date)) as first_activity_date
		from moodle_module_activity_summary
		group by salesforce_contact_id
	) as tbl6
	on  cohort_day.student_id=tbl6.salesforce_contact_id
	left join 
	(
		select salesforce_contact_id,is_complete,date(min(last_activity_completion_date)) as graduation_date
		from moodle_user_course_completion_summary
		left join moodle_course_attributes
		on moodle_user_course_completion_summary.moodle_course_id=moodle_course_attributes.moodle_course_id 
		where is_complete=1 and moodle_user_course_completion_summary.moodle_course_id<>658 and content_course_version<>'microcourse'
		group by salesforce_contact_id,is_complete
	) as tbl7
	on  cohort_day.student_id=tbl7.salesforce_contact_id
where progress_start_day between 0 and 30 and isdeleted=0 and contact.createddate>=to_date('2021-03-22', 'YYYY/MM/DD')
order by student_id desc, progress_start_day asc;

--
-- GRADUATION DATE
--

select salesforce_contact_id,is_complete,date(min(last_activity_completion_date)) as graduation_date_658
from moodle_user_course_completion_summary
where is_complete=1 and moodle_user_course_completion_summary.moodle_course_id=658
group by salesforce_contact_id,is_complete;



--
-- FECHA PRIMER LOGIN
--

select student_id,date(min(day_info)) as first_login_date from cohort_day
where has_login=1
group by student_id,has_login;

--
-- FECHA DE LA PRIMERA ACTIVIDAD
--

select salesforce_contact_id,min(moodle_activity_completion_date_local) as first_activity_date_local,min(moodle_activity_completion_date) as completion_date
from moodle_module_activity_summary
where salesforce_contact_id='0035G000020gapGQAQ'
group by salesforce_contact_id;

--
-- FECHA DE GRADUACION
--

select  from moodle_user_course_completion_summary;

--
-- clases en vivo normal
--

select salesforce_contact_id,zoom_webinar_date,count(distinct zoom_webinar_id) as cv_atendidas
from
(
	select salesforce_contact_id,zoom_webinar_id,date(zoom_webinar_date) as zoom_webinar_date
	from zoom_webinar_user_summary
	where zoom_webinar_attendance_join_time is not null
)
group by salesforce_contact_id,date(zoom_webinar_date);

--
-- Clase en vivo de induccion
--

select *
		from
		(
			select salesforce_contact_scheduled,salesforce_contact_id_atendee,email,id as induction_id_cv,start_time,join_time,leave_time,duration_in_seconds,
			case
				when join_time is not null then round(duration_in_seconds/60,0) else null
			end as duration_in_minutos,
			case 
				when join_time is not null then 1 else 0
			end as attendance_induction_cv,
			row_number() over (partition by salesforce_contact_scheduled order by start_time asc) as first_class
			from zoom_induction_meeting_new
		)
			where first_class=1;
		
		
select salesforce_contact_scheduled,salesforce_contact_id_atendee,email,id as induction_id_cv,start_time,join_time,leave_time,duration_in_seconds,
case
	when join_time is not null then round(duration_in_seconds/60,0) else null
end as duration_in_minutos,
case 
	when join_time is not null then 1 else 0
end as attendance_induction_cv,
row_number() over (partition by salesforce_contact_scheduled order by start_time asc) as first_class
from zoom_induction_meeting_new;

--
-- evaluaciones
--
--

select 
salesforce_contact_id,date(moodle_activity_completion_date) as completion_date,count(distinct diplomado_evaluacion) as evaluaciones_completadas
from
(
select 
salesforce_contact_id,moodle_module_activity_summary.moodle_course_id,content_course_version,moodle_activity_name,coursesection,moodle_activity_completion_date,
case
	when coursesection<=12 and coursesection is not null then 'evaluacion - ' || coursesection  else concat('evaluacion - ',left(right(moodle_activity_name,length(moodle_activity_name)-1),1)) 
end as evaluacion1,
case 
	when evaluacion1 like '%- i%'
    	OR evaluacion1 like '%- v%' then concat('evaluacion - ',right(left(moodle_activity_name,11),1)) else evaluacion1
end as evaluacion,
moodle_module_activity_summary.moodle_course_id || ' - ' || evaluacion as diplomado_evaluacion
from moodle_module_activity_summary
left join moodle_course_attributes 
on moodle_module_activity_summary.moodle_course_id=moodle_course_attributes.moodle_course_id
where 	content_completion_required=1
		and (moodle_activitytype like '%uiz%' or moodle_activitytype like '%h5p%' or moodle_activitytype like '%hvp%')
		and content_completion_required=1 
		and moodle_activity_name not like '%EP%' 
		and moodle_activity_name not like '%ntegradora%' 
		and moodle_activity_name not like '%CV%'
		and moodle_activity_name not like '%ideo%'
		and moodle_activity_name not like '%Lección%' 
		and moodle_activity_name not like '%nteractivo%' 
		and moodle_assign_type not like '%integradora%' 
		and moodle_assign_type not like '%practica%' 
		and LENGTH(salesforce_contact_id)>=2
		and content_course_version<>'microcourse'
) group by salesforce_contact_id,date(moodle_activity_completion_date);

select gra from cohort_day;