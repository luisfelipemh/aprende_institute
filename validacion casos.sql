-- Validador
	
select tbl1.salesforce_contact_id,tbl1.moodle_course_id,content_course_version,
case 
	when tbl1.modulos_completados>9 then 9 else tbl1.modulos_completados
end as total_modulos_actsumm,tbl2.total_modulos from 
	(
		select salesforce_contact_id,moodle_course_id,count(*) as modulos_completados from
		(
			select salesforce_contact_id,moodle_course_id,moodle_activitytype,moodle_activity_name,moodle_activity_completion_date,activity_index,
			case
				when moodle_grade>=20 then moodle_grade/10 else moodle_grade
			end as moodle_grade_stand
			from moodle_module_activity_summary 
			where cast(moodle_activity_completion_date as date)<=dateadd(day,-1,cast(date_trunc('week',cast(cast(to_timestamp(to_Char(current_date,'YYYY-MM-DD'), 'YYYY-MM-DD') as date) as date)) as date))
			and moodle_activitytype like '%uiz%' and content_completion_required=1 and moodle_activity_name not like '%EP%' and moodle_activity_name not like '%ntegradora%' 
			and moodle_activity_name not like '%CV%' and moodle_grade_stand>=7
	) 
	group by salesforce_contact_id,moodle_course_id order by salesforce_contact_id desc) as tbl1
inner join 
	(
	select * from (select student_id,cohort_week_diplomado.moodle_course_id,content_course_version,week_info, 
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
               row_number() over (partition by cohort_week_diplomado.student_id order by total_modulos desc, cohort_week_diplomado.week_info desc) as ranking 
               from cohort_week_diplomado 
               LEFT JOIN aprende.moodle_course_attributes
      		   ON ( cohort_week_diplomado.moodle_course_id = moodle_course_attributes.moodle_course_id )) as tbl3 where tbl3.ranking=1
	) as tbl2
		on tbl1.salesforce_contact_id=tbl2.student_id and tbl1.moodle_course_id=tbl2.moodle_course_id where tbl1.moodle_course_id not in (508) and total_modulos_actsumm<>tbl2.total_modulos;






