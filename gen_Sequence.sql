select 
tbl1.contact_creation_week,
tbl1.student_id,
tbl1.email,
tbl1.moodle_course_id,
tbl1.school,
tbl1.diplomado,
tbl1.content_course_version,
max (
	case
		when tbl1.last_weeks='Week_-1' then tbl1.total_modulos
	end) as week_1_total_modules,
max (
	case
		when tbl1.last_weeks='Week_-2' then tbl1.total_modulos
	end) as week_2_total_modules,
max (
	case
		when tbl1.last_weeks='Week_-3' then tbl1.total_modulos
	end) as week_3_total_modules,
max (
	case
		when tbl1.last_weeks='Week_-4' then tbl1.total_modulos
	end) as week_4_total_modules,
max (
	case
		when tbl1.last_weeks='Week_-5' then tbl1.total_modulos
	end) as week_5_total_modules,
max (
	case
		when tbl1.last_weeks='Week_-6' then tbl1.total_modulos
	end) as week_6_total_modules,
week_1_total_modules-week_2_total_modules as week_1_new_modules,
week_2_total_modules-week_3_total_modules as week_2_new_modules,
week_3_total_modules-week_4_total_modules as week_3_new_modules,
week_4_total_modules-week_5_total_modules as week_4_new_modules,
week_5_total_modules-week_6_total_modules as week_5_new_modules,
max (
	case
		when tbl1.last_weeks_login='Week_-1' then tbl1.has_login
	end) as week_1_login,
max (
	case
		when tbl1.last_weeks_login='Week_-2' then tbl1.has_login
	end) as week_2_login,
max (
	case
		when tbl1.last_weeks_login='Week_-3' then tbl1.has_login
	end) as week_3_login,
max (
	case
		when tbl1.last_weeks_login='Week_-4' then tbl1.has_login
	end) as week_4_login,
max (
	case
		when tbl1.last_weeks_login='Week_-5' then tbl1.has_login
	end) as week_5_login,
max (
	case
		when tbl1.last_weeks_login='Week_-6' then tbl1.has_login
	end) as week_6_login,
max (
	case
		when tbl1.last_weeks_login='Week_-6' then tbl1.is_complete
	end) as week_1_is_complete
from (SELECT cohort_week_diplomado.contact_creation_week,
               cohort_week_diplomado.student_id,
               contact.email,
               cohort_week_diplomado.moodle_course_id,
               moodle_course_attributes.school,
               moodle_course_attributes.diplomado,
               moodle_course_attributes.content_course_version,
               moodle_user_course_completion_summary.general_sequence,
               cohort_week_diplomado.progress_start_week,
               cohort_week_diplomado.week_info,
               cohort_week_diplomado.is_complete, 
               cohort_week_diplomado.is_license_active,
               cohort_week_diplomado.has_login,
				case 
               		when cohort_week_diplomado.module1_completion_date <= dateadd(WEEK,1,week_info) then 1 else 0 
               end as module1_completed,
               case 
               		when cohort_week_diplomado.module2_completion_date <= dateadd(WEEK,1,week_info) then 1 else 0 
               end as module2_completed,
               case 
               		when cohort_week_diplomado.module3_completion_date <= dateadd(WEEK,1,week_info) then 1 else 0 
               end as module3_completed,
               case 
               		when cohort_week_diplomado.module4_completion_date <= dateadd(WEEK,1,week_info) then 1 else 0 
               end as module4_completed,
               case 
               		when cohort_week_diplomado.module5_completion_date <= dateadd(WEEK,1,week_info) then 1 else 0 
               end as module5_completed,
               case 
               		when cohort_week_diplomado.module6_completion_date <= dateadd(WEEK,1,week_info) then 1 else 0 
               end as module6_completed,
               case 
               		when cohort_week_diplomado.module7_completion_date <= dateadd(WEEK,1,week_info) then 1 else 0 
               end as module7_completed,
               case 
               		when cohort_week_diplomado.module8_completion_date <= dateadd(WEEK,1,week_info) then 1 else 0 
               end as module8_completed,
               case 
               		when cohort_week_diplomado.module9_completion_date <= dateadd(WEEK,1,week_info) then 1 else 0 
               end as module9_completed,
               module1_completed+module2_completed+module3_completed+module4_completed+module5_completed+module6_completed+module7_completed+module8_completed+module9_completed
               as total_modulos,
               row_number() over (partition by cohort_week_diplomado.student_id order by total_modulos desc, cohort_week_diplomado.week_info desc) as ranking,
               case 
               		when ranking=1 then 'Week_-1'
               		when ranking=2 then 'Week_-2'
               		when ranking=3 then 'Week_-3'
               		when ranking=4 then 'Week_-4'
               		when ranking=5 then 'Week_-5'
               		when ranking=6 then 'Week_-6'
               end as last_weeks,
               row_number() over (partition by cohort_week_diplomado.student_id order by cohort_week_diplomado.week_info desc) as ranking_login,
               case 
               		when ranking_login=1 then 'Week_-1'
               		when ranking_login=2 then 'Week_-2'
               		when ranking_login=3 then 'Week_-3'
               		when ranking_login=4 then 'Week_-4'
               		when ranking_login=5 then 'Week_-5'
               		when ranking_login=6 then 'Week_-6'
               end as last_weeks_login
from aprende.cohort_week_diplomado
	LEFT JOIN aprende.moodle_user_course_completion_summary
		ON  ( cohort_week_diplomado.moodle_course_id = moodle_user_course_completion_summary.moodle_course_id )
			AND ( cohort_week_diplomado.student_id = moodle_user_course_completion_summary.salesforce_contact_id ) 
	LEFT JOIN aprende.moodle_course_attributes
      	ON ( cohort_week_diplomado.moodle_course_id = moodle_course_attributes.moodle_course_id )
    left join aprende.contact
    	on (cohort_week_diplomado.student_id=contact.id)
	where ( moodle_user_course_completion_summary.general_sequence = 1) and (cohort_week_diplomado.is_license_active=1)) as tbl1 where tbl1.ranking between 1 and 6 and tbl1.ranking_login between 1 and 6
group by 
tbl1.contact_creation_week,
tbl1.student_id,
tbl1.email,
tbl1.moodle_course_id,
tbl1.school,
tbl1.diplomado,
tbl1.content_course_version;

select * from (select cohort_week_diplomado.contact_creation_week,cohort_week_diplomado.student_id,cohort_week_diplomado.moodle_course_id,
	MAX(cohort_week_diplomado.content_course_progress_cummulative), row_number() over (partition by cohort_week_diplomado.student_id order by MAX(cohort_week_diplomado.content_course_progress_cummulative) desc) as ranking_progress,
	moodle_user_course_completion_summary.general_sequence,
	case 
		when MAX(cohort_week_diplomado.content_course_progress_cummulative)>0 then ranking_progress else moodle_user_course_completion_summary.general_sequence
	end as diplomado_analisis
	from cohort_week_diplomado 
	LEFT JOIN aprende.moodle_user_course_completion_summary
		ON  ( cohort_week_diplomado.moodle_course_id = moodle_user_course_completion_summary.moodle_course_id )
		AND ( cohort_week_diplomado.student_id = moodle_user_course_completion_summary.salesforce_contact_id )
	group by cohort_week_diplomado.contact_creation_week,cohort_week_diplomado.student_id,cohort_week_diplomado.moodle_course_id,moodle_user_course_completion_summary.general_sequence order by cohort_week_diplomado.student_id,ranking_progress) as tbl1
	where tbl1.diplomado_analisis=1;
	
select created_date,salesforce_contact_id,moodle_course_id,last_any_activity_completion_date,initial_any_activity_completion_date,
case
	when last_any_activity_completion_date is not null
		then row_number() over (partition by salesforce_contact_id order by last_any_activity_completion_date desc)
	end
as ranking_last_activity,	
case
	when initial_any_activity_completion_date is not null
		then row_number() over (partition by salesforce_contact_id order by initial_any_activity_completion_date desc)
	end
as ranking_initial_activity
from moodle_user_course_completion_summary order by salesforce_contact_id,ranking_last_activity;


select * from (select created_date,salesforce_contact_id,moodle_course_id,last_any_activity_completion_date,initial_any_activity_completion_date,
case
	when initial_any_activity_completion_date is null
		then 1 else 0
	end
as null_initial_any_activity,
case
	when last_any_activity_completion_date is null
		then 1 else 0
	end
as null_last_any_activity,
row_number() over (partition by salesforce_contact_id order by last_any_activity_completion_date desc)
as ranking_last_activity,	
row_number() over (partition by salesforce_contact_id order by initial_any_activity_completion_date desc)
as ranking_initial_activity
from moodle_user_course_completion_summary order by salesforce_contact_id,ranking_last_activity) tbl1
	left join (select salesforce_contact_id,COUNT(distinct moodle_course_id) as n_diplomados
				from moodle_user_course_completion_summary group by salesforce_contact_id order by salesforce_contact_id) tbl2
			on tbl1.salesforce_contact_id=tbl2.salesforce_contact_id;

select salesforce_contact_id,COUNT(distinct moodle_course_id) as n_diplomados
from moodle_user_course_completion_summary group by salesforce_contact_id order by salesforce_contact_id;

-- Analisis

select * from (select salesforce_contact_id,created_date,moodle_course_id,last_any_activity_completion_date,initial_any_activity_completion_date,
case
	when initial_any_activity_completion_date is null
		then 1 else 0
	end
as null_initial_any_activity,
case
	when last_any_activity_completion_date is null
		then 1 else 0
	end
as null_last_any_activity,
row_number() over (partition by salesforce_contact_id order by last_any_activity_completion_date desc)
as ranking_last_activity,	
row_number() over (partition by salesforce_contact_id order by initial_any_activity_completion_date desc)
as ranking_initial_activity
from moodle_user_course_completion_summary order by salesforce_contact_id,ranking_last_activity) tbl1
	left join (select salesforce_contact_id,COUNT(distinct moodle_course_id) as n_diplomados
				from moodle_user_course_completion_summary group by salesforce_contact_id order by salesforce_contact_id) tbl2
			on tbl1.salesforce_contact_id=tbl2.salesforce_contact_id;
		
		
--'0035G00001ZkK5DQAV'
		
select * from (select tbl1.salesforce_contact_id,tbl1.moodle_course_id,tbl2.n_diplomados,	
rank() over (partition by tbl1.salesforce_contact_id order by tbl1.initial_any_activity_completion_date desc) as rank_initial,
rank() over (partition by tbl1.salesforce_contact_id order by tbl1.last_any_activity_completion_date asc) as rank_last
from 
	(select distinct salesforce_contact_id, moodle_course_id,last_any_activity_completion_date,initial_any_activity_completion_date
	from moodle_user_course_completion_summary where initial_any_activity_completion_date is not null) tbl1
		left join (select salesforce_contact_id,COUNT(distinct moodle_course_id) as n_diplomados
				from moodle_user_course_completion_summary group by salesforce_contact_id order by salesforce_contact_id) tbl2
			on tbl1.salesforce_contact_id=tbl2.salesforce_contact_id order by tbl1.salesforce_contact_id) tbl3;
		
select distinct moodle_user_course_completion_summary.salesforce_contact_id, moodle_user_course_completion_summary.moodle_course_id,
moodle_user_course_completion_summary.initial_any_activity_completion_date,moodle_user_course_completion_summary.last_any_activity_completion_date, 
tbl1.rank_initial, tbl1.rank_last,
rank() over (partition by moodle_user_course_completion_summary.salesforce_contact_id 
order by moodle_user_course_completion_summary.initial_any_activity_completion_date asc) as rank_initial_null,
rank() over (partition by moodle_user_course_completion_summary.salesforce_contact_id 
order by moodle_user_course_completion_summary.last_any_activity_completion_date asc) as rank_last_null,
tbl2.n_diplomados
from moodle_user_course_completion_summary
	left join (select distinct salesforce_contact_id, moodle_course_id,initial_any_activity_completion_date,last_any_activity_completion_date,
					rank() over (partition by salesforce_contact_id order by initial_any_activity_completion_date asc) as rank_initial,
					rank() over (partition by salesforce_contact_id order by last_any_activity_completion_date desc) as rank_last
				from moodle_user_course_completion_summary where initial_any_activity_completion_date is not null order by salesforce_contact_id) tbl1
			on moodle_user_course_completion_summary.salesforce_contact_id=tbl1.salesforce_contact_id
				and moodle_user_course_completion_summary.moodle_course_id=tbl1.moodle_course_id 
	left join (select salesforce_contact_id,COUNT(distinct moodle_course_id) as n_diplomados
				from moodle_user_course_completion_summary group by salesforce_contact_id) tbl2
			on moodle_user_course_completion_summary.salesforce_contact_id=tbl2.salesforce_contact_id
order by moodle_user_course_completion_summary.salesforce_contact_id;

(select salesforce_contact_id, moodle_course_id,initial_any_activity_completion_date,last_any_activity_completion_date,
					row_number() over (partition by salesforce_contact_id order by initial_any_activity_completion_date asc) as rank_initial,
					row_number() over (partition by salesforce_contact_id order by last_any_activity_completion_date desc) as rank_last
				from (select distinct salesforce_contact_id, moodle_course_id,initial_any_activity_completion_date,last_any_activity_completion_date from moodle_user_course_completion_summary 
			where initial_any_activity_completion_date is not null and salesforce_contact_id='0035G00001ZkDcUQAV') order by salesforce_contact_id);
		
-- PRUEBAS
		
select distinct moodle_user_course_completion_summary.salesforce_contact_id, moodle_user_course_completion_summary.moodle_course_id,
moodle_user_course_completion_summary.initial_any_activity_completion_date,moodle_user_course_completion_summary.last_any_activity_completion_date, 
tbl1.rank_initial, tbl1.rank_last,
row_number() over (partition by moodle_user_course_completion_summary.salesforce_contact_id 
order by moodle_user_course_completion_summary.initial_any_activity_completion_date asc) as rank_initial_null,
row_number() over (partition by moodle_user_course_completion_summary.salesforce_contact_id 
order by moodle_user_course_completion_summary.last_any_activity_completion_date asc) as rank_last_null,
tbl2.n_diplomados
from moodle_user_course_completion_summary
	left join (select salesforce_contact_id, moodle_course_id,initial_any_activity_completion_date,last_any_activity_completion_date,
					row_number() over (partition by salesforce_contact_id order by initial_any_activity_completion_date asc) as rank_initial,
					row_number() over (partition by salesforce_contact_id order by last_any_activity_completion_date desc) as rank_last
				from (select distinct salesforce_contact_id, moodle_course_id,initial_any_activity_completion_date,last_any_activity_completion_date from moodle_user_course_completion_summary 
			where initial_any_activity_completion_date is not null) order by salesforce_contact_id) tbl1
			on moodle_user_course_completion_summary.salesforce_contact_id=tbl1.salesforce_contact_id
				and moodle_user_course_completion_summary.moodle_course_id=tbl1.moodle_course_id 
	left join (select salesforce_contact_id,COUNT(distinct moodle_course_id) as n_diplomados
				from moodle_user_course_completion_summary group by salesforce_contact_id) tbl2
			on moodle_user_course_completion_summary.salesforce_contact_id=tbl2.salesforce_contact_id
order by moodle_user_course_completion_summary.salesforce_contact_id;





-- CONSULTA FINAL: NEW_GENERAL_SEQUENCE


select tbl4.salesforce_contact_id, tbl4.n_diplomados, tbl4.moodle_course_id, 
tbl4.initial_any_activity_completion_date,tbl4.last_any_activity_completion_date,
tbl4.rank_initial_any_activity, tbl4.rank_last_any_activity, 
case 
	when tbl5.max_progress is null
		then 0 else tbl5.max_progress
	end
as max_progreso, 
row_number() over (partition by tbl4.salesforce_contact_id order by max_progreso desc, tbl4.rank_initial_any_activity asc, tbl4.rank_last_any_activity asc) as new_general_sequence
from (select 
tbl3.salesforce_contact_id, tbl3.moodle_course_id,
tbl3.initial_any_activity_completion_date,tbl3.last_any_activity_completion_date, 
tbl3.rank_initial, tbl3.rank_last,
row_number() over (partition by tbl3.salesforce_contact_id 
order by tbl3.initial_any_activity_completion_date asc) as rank_initial_null,
row_number() over (partition by tbl3.salesforce_contact_id 
order by tbl3.last_any_activity_completion_date asc) as rank_last_null,
tbl3.n_diplomados,
case
	when tbl3.rank_initial is null
		then rank_initial_null else tbl3.rank_initial
	end
as rank_initial_any_activity,
case
	when tbl3.rank_last is null
		then rank_last_null else tbl3.rank_last
	end
as rank_last_any_activity
from (select distinct moodle_user_course_completion_summary.salesforce_contact_id, moodle_user_course_completion_summary.moodle_course_id,
moodle_user_course_completion_summary.initial_any_activity_completion_date,moodle_user_course_completion_summary.last_any_activity_completion_date, 
tbl1.rank_initial, tbl1.rank_last,
tbl2.n_diplomados
from moodle_user_course_completion_summary
	left join (select salesforce_contact_id, moodle_course_id,initial_any_activity_completion_date,last_any_activity_completion_date,
					row_number() over (partition by salesforce_contact_id order by initial_any_activity_completion_date asc) as rank_initial,
					row_number() over (partition by salesforce_contact_id order by last_any_activity_completion_date desc) as rank_last
				from (select distinct salesforce_contact_id, moodle_course_id,initial_any_activity_completion_date,last_any_activity_completion_date from moodle_user_course_completion_summary 
			where initial_any_activity_completion_date is not null) order by salesforce_contact_id) tbl1
			on moodle_user_course_completion_summary.salesforce_contact_id=tbl1.salesforce_contact_id
				and moodle_user_course_completion_summary.moodle_course_id=tbl1.moodle_course_id 
	left join (select salesforce_contact_id,COUNT(distinct moodle_course_id) as n_diplomados
				from moodle_user_course_completion_summary group by salesforce_contact_id) tbl2
			on moodle_user_course_completion_summary.salesforce_contact_id=tbl2.salesforce_contact_id
				order by moodle_user_course_completion_summary.salesforce_contact_id) tbl3) tbl4
	left join (select student_id,moodle_course_id,MAX(content_course_progress_cummulative) as max_progress from cohort_week_diplomado group by 1,2 order by student_id) tbl5
			on tbl4.salesforce_contact_id=tbl5.student_id
		    and tbl4.moodle_course_id=tbl5.moodle_course_id order by tbl4.salesforce_contact_id;		   
-- PRUEBA #2 --
