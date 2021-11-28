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




