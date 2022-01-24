
































select 
count(id)
from
(
select 
distinct tbl1.id,tbl1.is_complete_658,tbl1.cv_induccion,tbl2.n_clases_vivo_atendidas_menor_40,tbl2.n_clases_vivo_atendidas_mayor_40,
tbl3.n_llamadas_menor_2min,tbl3.n_llamadas_mayor_2min 
from 
(
	select id,is_complete_658,
		case 
			when onboarding_status__c='Done' then 1 else 0 
		end as cv_induccion
	from contact 
	left join
	(
	select student_id,moodle_course_id,max(is_complete) as is_complete_658,max(content_course_progress_cummulative) as progress_658
	from cohort_week_diplomado 
	where moodle_course_id=658 
	group by student_id,moodle_course_id
	)
	on id=student_id
) as tbl1
left join
(
select
salesforce_contact_id,
count(distinct case when attendance_time<40 then zoom_webinar_id end) as n_clases_vivo_atendidas_menor_40,
count(distinct case when attendance_time>=40 then zoom_webinar_id end) as n_clases_vivo_atendidas_mayor_40
from
(
	select 
	salesforce_contact_id,zoom_webinar_id,
	extract(minute from leave_time-join_time) as attendance_time
	from 
	(
		select salesforce_contact_id,zoom_webinar_id,
		min(zoom_webinar_attendance_join_time) as join_time,max(zoom_webinar_attendance_leave_time) as leave_time
			from zoom_webinar_user_summary where zoom_webinar_attendance_join_time is not null group by salesforce_contact_id,zoom_webinar_id
	) 
	where length(salesforce_contact_id)>=2
) 
	group by salesforce_contact_id
) as tbl2
on tbl1.id=tbl2.salesforce_contact_id
left join 
(
	select salesforce_id, 
count(distinct case when "call time"<120 then "call id" end) as n_llamadas_menor_2min,
count(distinct case when "call time">=120  then "call id" end) as n_llamadas_mayor_2min
from
(
	select salesforce_id,"customer name","call id",campaign,"call time" 
	from five9_callog where campaign like '%Academic%'
)
group by salesforce_id	
) as tbl3
on tbl1.id=tbl3.salesforce_id
);

select * from zoom_induction_meeting_new where join_time is not null limit 50;




