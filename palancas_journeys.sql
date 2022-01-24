

select acade from cohort_day limit 100;

select 
salesforce_contact_id,moodle_course_id,moodle_activity_completion_date,count(module_id) as activities
from
(
	select 
	salesforce_contact_id,moodle_course_id,module_id,date(moodle_activity_completion_date) as moodle_activity_completion_date
	from moodle_module_activity_summary
	where content_completion_required=1 and LENGTH(salesforce_contact_id)>=2
)
group by salesforce_contact_id,moodle_course_id,moodle_activity_completion_date;



--
--
--

select 
*,
lag(activities_day,1) over (partition by student_id, moodle_course_id order by day_info desc) as activities_day1,
lag(activities_day,2) over (partition by student_id, moodle_course_id order by day_info desc) as activities_day2,
lag(activities_day,3) over (partition by student_id, moodle_course_id order by day_info desc) as activities_day3,
lag(activities_day,4) over (partition by student_id, moodle_course_id order by day_info desc) as activities_day4,
lag(activities_day,5) over (partition by student_id, moodle_course_id order by day_info desc) as activities_day5,
lag(activities_day,6) over (partition by student_id, moodle_course_id order by day_info desc) as activities_day6,
lag(activities_day,7) over (partition by student_id, moodle_course_id order by day_info desc) as activities_day7,
activities_day+activities_day1 as activities_0_1,
activities_day+activities_day1+activities_day2+activities_day3 as activities_0_3,
activities_day+activities_day1+activities_day2+activities_day3+activities_day4+activities_day5+activities_day6+activities_day7 as activities_0_7,
row_number() over (partition by student_id, moodle_course_id order by day_info desc) as "row_number"
from 
(
select 
tbl1.student_id,tbl1.moodle_course_id,tbl1.general_sequence,day_info,has_login,
case 
	when tbl2.activities is null then 0 else tbl2.activities 
end as activities_day
from
(
select cohort_day.student_id,moodle_course_id,general_sequence,date(day_info) as day_info,
has_login
from cohort_day
	left join moodle_user_course_completion_summary
	on cohort_day.student_id = moodle_user_course_completion_summary.salesforce_contact_id
where day_info>=to_date('2021-09-01', 'YYYY/MM/DD') and createddate>=to_date('2021-01-01', 'YYYY/MM/DD')
) as tbl1
	left join 
	(
	select 
	salesforce_contact_id,moodle_course_id,moodle_activity_completion_date,count(module_id) as activities
	from
		(
			select 
			salesforce_contact_id,moodle_course_id,module_id,date(moodle_activity_completion_date) as moodle_activity_completion_date
			from moodle_module_activity_summary
			where content_completion_required=1 and LENGTH(salesforce_contact_id)>=2
		)
	group by salesforce_contact_id,moodle_course_id,moodle_activity_completion_date
	) as tbl2
	on tbl1.student_id=tbl2.salesforce_contact_id and tbl1.moodle_course_id=tbl2.moodle_course_id and date(tbl1.day_info)=tbl2.moodle_activity_completion_date
order by moodle_course_id, day_info desc
) order by moodle_course_id desc,day_info asc limit 10000;


--
-- BUENAS PRACTICAS, AVANCE DEL ESTUDIANTE
-- 

select 
date(createddate) as createddate,student_id,moodle_course_id,general_sequence,day_info,
extract(day from day_info-createddate) as progress_start_day, 
activities_day as activities_0,
activities_day+activities_day1 as activities_0_1,
activities_day+activities_day1+activities_day2+activities_day3 as activities_0_3,
activities_day+activities_day1+activities_day2+activities_day3+activities_day4+activities_day5+activities_day6+activities_day7 as activities_0_7
from 
(
select 
tbl1.createddate,tbl1.student_id,tbl1.moodle_course_id,tbl1.general_sequence,day_info,has_login,
case 
	when tbl2.activities is null then 0 else tbl2.activities 
end as activities_day,
lag(activities_day,1) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day1,
lag(activities_day,2) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day2,
lag(activities_day,3) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day3,
lag(activities_day,4) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day4,
lag(activities_day,5) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day5,
lag(activities_day,6) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day6,
lag(activities_day,7) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day7,
row_number() over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as row_days
from
(
select createddate,cohort_day.student_id,moodle_course_id,general_sequence,date(day_info) as day_info,
has_login
from cohort_day
	left join moodle_user_course_completion_summary
	on cohort_day.student_id = moodle_user_course_completion_summary.salesforce_contact_id
where day_info>=to_date('2021-06-01', 'YYYY/MM/DD') and createddate>=to_date('2021-01-01', 'YYYY/MM/DD')
) as tbl1
	left join 
	(
	select 
	salesforce_contact_id,moodle_course_id,moodle_activity_completion_date,count(module_id) as activities
	from
		(
			select 
			salesforce_contact_id,moodle_course_id,module_id,date(moodle_activity_completion_date) as moodle_activity_completion_date
			from moodle_module_activity_summary
			where content_completion_required=1 and LENGTH(salesforce_contact_id)>=2
		)
	group by salesforce_contact_id,moodle_course_id,moodle_activity_completion_date
	) as tbl2
	on tbl1.student_id=tbl2.salesforce_contact_id and tbl1.moodle_course_id=tbl2.moodle_course_id and date(tbl1.day_info)=tbl2.moodle_activity_completion_date
order by moodle_course_id, day_info desc
) where row_days>7 and progress_start_day>=0 and student_id='0035G00001bz102QAA' order by createddate asc,student_id desc,moodle_course_id asc,day_info asc; 


--
-- DIPLOMADO EN EL QUE VA MAS AVANZADO
--
select 
salesforce_contact_id,moodle_course_id 
from 
(
select moodle_user_course_completion_summary.salesforce_contact_id,
		moodle_user_course_completion_summary.moodle_course_id,general_sequence,
case
	when completed_evaluations is null then 0 else completed_evaluations
end as completed_courses_evaluations,
case
	when required_activities is null then 0 else required_activities
end as required_activities_content,
row_number() over (partition by moodle_user_course_completion_summary.salesforce_contact_id
					order by completed_courses_evaluations desc,required_activities_content desc,general_sequence) as new_general_sequence
from moodle_user_course_completion_summary
left join
(
	select salesforce_contact_id,moodle_course_id,count(distinct concat(moodle_activity_name,coursesection)) as completed_evaluations
	from moodle_module_activity_summary
	where (moodle_activitytype like '%uiz%' or moodle_activitytype like '%h5p%' or moodle_activitytype like '%hvp%')
		and content_completion_required=1 
		and moodle_activity_name not like '%EP%' 
		and moodle_activity_name not like '%ntegradora%' 
		and moodle_activity_name not like '%CV%'
		and moodle_activity_name not like '%ideo%'
		and moodle_activity_name not like '%Lección%' 
		and moodle_assign_type not like '%integradora%' 
		and moodle_assign_type not like '%practica%'
		and moodle_activity_name not like '%nteractivo%'
		and length(salesforce_contact_id)>=1
	group by salesforce_contact_id,moodle_course_id
) as tbl1
	on moodle_user_course_completion_summary.salesforce_contact_id=tbl1.salesforce_contact_id
	and moodle_user_course_completion_summary.moodle_course_id=tbl1.moodle_course_id
left join 
(
	select salesforce_contact_id,moodle_course_id,count(distinct concat(moodle_activity_name,coursesection)) as required_activities
	from moodle_module_activity_summary
	where content_completion_required=1 and length(salesforce_contact_id)>=1
	group by salesforce_contact_id,moodle_course_id
) as tbl2
	on moodle_user_course_completion_summary.salesforce_contact_id=tbl2.salesforce_contact_id
	and moodle_user_course_completion_summary.moodle_course_id=tbl2.moodle_course_id
) where new_general_sequence=1;

--
-- JOINS
--

select 
date(createddate) as createddate,student_id,moodle_course_id,general_sequence,day_info,
extract(day from day_info-createddate) as progress_start_day, 
activities_day as activities_0,
activities_day+activities_day1 as activities_0_1,
activities_day+activities_day1+activities_day2+activities_day3 as activities_0_3,
activities_day+activities_day1+activities_day2+activities_day3+activities_day4+activities_day5+activities_day6+activities_day7 as activities_0_7
from 
(
	select 
	tbl3.createddate,tbl3.student_id,tbl3.moodle_course_id,tbl3.general_sequence,day_info,has_login,
	case 
		when tbl4.activities is null then 0 else tbl4.activities 
	end as activities_day,
	lag(activities_day,1) over (partition by tbl3.student_id, tbl3.moodle_course_id order by day_info desc) as activities_day1,
	lag(activities_day,2) over (partition by tbl3.student_id, tbl3.moodle_course_id order by day_info desc) as activities_day2,
	lag(activities_day,3) over (partition by tbl3.student_id, tbl3.moodle_course_id order by day_info desc) as activities_day3,
	lag(activities_day,4) over (partition by tbl3.student_id, tbl3.moodle_course_id order by day_info desc) as activities_day4,
	lag(activities_day,5) over (partition by tbl3.student_id, tbl3.moodle_course_id order by day_info desc) as activities_day5,
	lag(activities_day,6) over (partition by tbl3.student_id, tbl3.moodle_course_id order by day_info desc) as activities_day6,
	lag(activities_day,7) over (partition by tbl3.student_id, tbl3.moodle_course_id order by day_info desc) as activities_day7,
	row_number() over (partition by tbl3.student_id, tbl3.moodle_course_id order by day_info desc) as row_days
	from
	(
		select createddate,cohort_day.student_id,moodle_course_id,general_sequence,date(day_info) as day_info,has_login
		from cohort_day
		left join moodle_user_course_completion_summary
		on cohort_day.student_id = moodle_user_course_completion_summary.salesforce_contact_id
		where day_info>=to_date('2021-06-01', 'YYYY/MM/DD') and createddate>=to_date('2021-01-01', 'YYYY/MM/DD')
	) as tbl3
	left join 
	(
		select tbl1.salesforce_contact_id,tbl1.moodle_course_id,tbl1.moodle_activity_completion_date,activities
		from
		(
			select 
			moodle_module_activity_summary.salesforce_contact_id,moodle_module_activity_summary.moodle_course_id,
			date(moodle_activity_completion_date) as moodle_activity_completion_date,
			count(distinct concat(moodle_activity_name,coursesection)) as activities
			from moodle_module_activity_summary
			where content_completion_required=1 and LENGTH(salesforce_contact_id)>=2
			group by salesforce_contact_id,moodle_course_id,moodle_activity_completion_date
		) as tbl1
		inner join
		(
		select 
		salesforce_contact_id,moodle_course_id as moodle_course_id_new
		from 
		(
			select moodle_user_course_completion_summary.salesforce_contact_id,
			moodle_user_course_completion_summary.moodle_course_id,general_sequence,
			case
				when completed_evaluations is null then 0 else completed_evaluations
			end as completed_courses_evaluations,
			case
				when required_activities is null then 0 else required_activities
			end as required_activities_content,
			row_number() over (partition by moodle_user_course_completion_summary.salesforce_contact_id
							order by completed_courses_evaluations desc,required_activities_content desc,general_sequence) as new_general_sequence
			from moodle_user_course_completion_summary
			left join
			(
				select salesforce_contact_id,moodle_course_id,count(distinct concat(moodle_activity_name,coursesection)) as completed_evaluations
				from moodle_module_activity_summary
				where (moodle_activitytype like '%uiz%' or moodle_activitytype like '%h5p%' or moodle_activitytype like '%hvp%')
					and content_completion_required=1 
					and moodle_activity_name not like '%EP%' 
					and moodle_activity_name not like '%ntegradora%' 
					and moodle_activity_name not like '%CV%'
					and moodle_activity_name not like '%ideo%'
					and moodle_activity_name not like '%Lección%' 
					and moodle_assign_type not like '%integradora%' 
					and moodle_assign_type not like '%practica%'
					and moodle_activity_name not like '%nteractivo%'
					and length(salesforce_contact_id)>=1
				group by salesforce_contact_id,moodle_course_id
			) as tbl1
			on moodle_user_course_completion_summary.salesforce_contact_id=tbl1.salesforce_contact_id
			and moodle_user_course_completion_summary.moodle_course_id=tbl1.moodle_course_id
		left join 
			(
				select salesforce_contact_id,moodle_course_id,count(distinct concat(moodle_activity_name,coursesection)) as required_activities
				from moodle_module_activity_summary
				where content_completion_required=1 and length(salesforce_contact_id)>=1
				group by salesforce_contact_id,moodle_course_id
			) as tbl2
		on moodle_user_course_completion_summary.salesforce_contact_id=tbl2.salesforce_contact_id
		and moodle_user_course_completion_summary.moodle_course_id=tbl2.moodle_course_id
		) where new_general_sequence=1
	) as tbl2
	on tbl1.salesforce_contact_id=tbl2.salesforce_contact_id 
	and tbl1.moodle_course_id=tbl2.moodle_course_id_new
	) as tbl4
	on tbl3.student_id=tbl4.salesforce_contact_id and tbl3.moodle_course_id=tbl4.moodle_course_id and date(tbl3.day_info)=tbl4.moodle_activity_completion_date
	order by moodle_course_id, day_info desc
) 
where row_days>7 and progress_start_day>=0 and student_id='0035G00001bz14jQAA' order by createddate asc,student_id desc,moodle_course_id asc,day_info;



--
-- QUERY OPRTIMIZADA
--

select tbl1.salesforce_contact_id,tbl1.moodle_course_id,tbl1.moodle_activity_completion_date,activities
from
(
	select 
	moodle_module_activity_summary.salesforce_contact_id,moodle_module_activity_summary.moodle_course_id,
	date(moodle_activity_completion_date) as moodle_activity_completion_date,
	count(distinct concat(moodle_activity_name,coursesection)) as activities
	from moodle_module_activity_summary
	where content_completion_required=1 and LENGTH(salesforce_contact_id)>=2
	group by salesforce_contact_id,moodle_course_id,moodle_activity_completion_date
) as tbl1
inner join
(
	select 
	salesforce_contact_id,moodle_course_id as moodle_course_id_new
	from 
	(
		select moodle_user_course_completion_summary.salesforce_contact_id,
		moodle_user_course_completion_summary.moodle_course_id,general_sequence,
		case
			when completed_evaluations is null then 0 else completed_evaluations
		end as completed_courses_evaluations,
		case
			when required_activities is null then 0 else required_activities
		end as required_activities_content,
		row_number() over (partition by moodle_user_course_completion_summary.salesforce_contact_id
							order by completed_courses_evaluations desc,required_activities_content desc,general_sequence) as new_general_sequence
		from moodle_user_course_completion_summary
		left join
		(
			select salesforce_contact_id,moodle_course_id,count(distinct concat(moodle_activity_name,coursesection)) as completed_evaluations
			from moodle_module_activity_summary
			where (moodle_activitytype like '%uiz%' or moodle_activitytype like '%h5p%' or moodle_activitytype like '%hvp%')
				and content_completion_required=1 
				and moodle_activity_name not like '%EP%' 
				and moodle_activity_name not like '%ntegradora%' 
				and moodle_activity_name not like '%CV%'
				and moodle_activity_name not like '%ideo%'
				and moodle_activity_name not like '%Lección%' 
				and moodle_assign_type not like '%integradora%' 
				and moodle_assign_type not like '%practica%'
				and moodle_activity_name not like '%nteractivo%'
				and length(salesforce_contact_id)>=1
			group by salesforce_contact_id,moodle_course_id
		) as tbl1
		on moodle_user_course_completion_summary.salesforce_contact_id=tbl1.salesforce_contact_id
		and moodle_user_course_completion_summary.moodle_course_id=tbl1.moodle_course_id
		left join 
		(
			select salesforce_contact_id,moodle_course_id,count(distinct concat(moodle_activity_name,coursesection)) as required_activities
			from moodle_module_activity_summary
			where content_completion_required=1 and length(salesforce_contact_id)>=1
			group by salesforce_contact_id,moodle_course_id
		) as tbl2
		on moodle_user_course_completion_summary.salesforce_contact_id=tbl2.salesforce_contact_id
		and moodle_user_course_completion_summary.moodle_course_id=tbl2.moodle_course_id
		) where new_general_sequence=1
) as tbl2
on tbl1.salesforce_contact_id=tbl2.salesforce_contact_id 
and tbl1.moodle_course_id=tbl2.moodle_course_id_new;

--
-- CONSULTA FINAL
--

select 
date(createddate) as createddate,student_id,moodle_course_id,day_info,
extract(day from day_info-createddate) as progress_start_day, 
activities_day as activities_0,
activities_day+activities_day1 as activities_0_1,
activities_day+activities_day1+activities_day2+activities_day3 as activities_0_3,
activities_day+activities_day1+activities_day2+activities_day3+activities_day4+activities_day5+activities_day6+activities_day7 as activities_0_7
from 
(
	select 
	tbl1.createddate,tbl1.student_id,tbl1.moodle_course_id,day_info,has_login,
	case 
		when tbl2.activities is null then 0 else tbl2.activities 
	end as activities_day,
	lag(activities_day,1) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day1,
	lag(activities_day,2) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day2,
	lag(activities_day,3) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day3,
	lag(activities_day,4) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day4,
	lag(activities_day,5) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day5,
	lag(activities_day,6) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day6,
	lag(activities_day,7) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day7,
	row_number() over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as row_days
	from
	(
		select createddate,cohort_day.student_id,moodle_course_id,date(day_info) as day_info,has_login
		from cohort_day
		inner join 
		(
			select 
			salesforce_contact_id,moodle_course_id
			from 
			(
				select moodle_user_course_completion_summary.salesforce_contact_id,
				moodle_user_course_completion_summary.moodle_course_id,general_sequence,
				case
					when completed_evaluations is null then 0 else completed_evaluations
				end as completed_courses_evaluations,
				row_number() over (partition by moodle_user_course_completion_summary.salesforce_contact_id
							order by completed_courses_evaluations desc,general_sequence asc) as new_general_sequence
				from moodle_user_course_completion_summary
				left join
				(
					select salesforce_contact_id,moodle_course_id,count(distinct concat(moodle_activity_name,coursesection)) as completed_evaluations
					from moodle_module_activity_summary
					where (moodle_activitytype like '%uiz%' or moodle_activitytype like '%h5p%' or moodle_activitytype like '%hvp%')
						and content_completion_required=1 
						and moodle_activity_name not like '%EP%' 
						and moodle_activity_name not like '%ntegradora%' 
						and moodle_activity_name not like '%CV%'
						and moodle_activity_name not like '%ideo%'
						and moodle_activity_name not like '%Lección%' 
						and moodle_assign_type not like '%integradora%' 
						and moodle_assign_type not like '%practica%'
						and moodle_activity_name not like '%nteractivo%'
						and length(salesforce_contact_id)>=1
				group by salesforce_contact_id,moodle_course_id
				) as tbl3
				on moodle_user_course_completion_summary.salesforce_contact_id=tbl3.salesforce_contact_id
				and moodle_user_course_completion_summary.moodle_course_id=tbl3.moodle_course_id
		) 
		where new_general_sequence=1		
	) as tbl5
		on cohort_day.student_id = tbl5.salesforce_contact_id
		where day_info>=to_date('2021-06-01', 'YYYY/MM/DD') and createddate>=to_date('2021-01-01', 'YYYY/MM/DD')
	) as tbl1
		left join 
		(
			select 
			salesforce_contact_id,moodle_course_id,date(moodle_activity_completion_date) as moodle_activity_completion_date,
			count(distinct concat(moodle_activity_name,coursesection)) as activities
			from moodle_module_activity_summary
			where content_completion_required=1 and LENGTH(salesforce_contact_id)>=2
			group by salesforce_contact_id,moodle_course_id,moodle_activity_completion_date
		) as tbl2
	on tbl1.student_id=tbl2.salesforce_contact_id and tbl1.moodle_course_id=tbl2.moodle_course_id and date(tbl1.day_info)=tbl2.moodle_activity_completion_date 
	order by moodle_course_id, day_info desc
) 
where row_days>7 and progress_start_day>=0 and student_id='0035G00001bz102QAA' order by createddate asc,student_id desc,moodle_course_id asc,day_info asc;




--
--
--
--
select 
	salesforce_contact_id,moodle_course_id as moodle_course_id_new
	from 
	(
		select moodle_user_course_completion_summary.salesforce_contact_id,
		moodle_user_course_completion_summary.moodle_course_id,general_sequence,
		case
			when completed_evaluations is null then 0 else completed_evaluations
		end as completed_courses_evaluations,
		case
			when required_activities is null then 0 else required_activities
		end as required_activities_content,
		row_number() over (partition by moodle_user_course_completion_summary.salesforce_contact_id
							order by completed_courses_evaluations desc,required_activities_content desc,general_sequence asc) as new_general_sequence
		from moodle_user_course_completion_summary
		left join
		(
			select salesforce_contact_id,moodle_course_id,count(distinct concat(moodle_activity_name,coursesection)) as completed_evaluations
			from moodle_module_activity_summary
			where (moodle_activitytype like '%uiz%' or moodle_activitytype like '%h5p%' or moodle_activitytype like '%hvp%')
				and content_completion_required=1 
				and moodle_activity_name not like '%EP%' 
				and moodle_activity_name not like '%ntegradora%' 
				and moodle_activity_name not like '%CV%'
				and moodle_activity_name not like '%ideo%'
				and moodle_activity_name not like '%Lección%' 
				and moodle_assign_type not like '%integradora%' 
				and moodle_assign_type not like '%practica%'
				and moodle_activity_name not like '%nteractivo%'
				and length(salesforce_contact_id)>=1
			group by salesforce_contact_id,moodle_course_id
		) as tbl3
		on moodle_user_course_completion_summary.salesforce_contact_id=tbl3.salesforce_contact_id
		and moodle_user_course_completion_summary.moodle_course_id=tbl3.moodle_course_id
		left join 
		(
			select salesforce_contact_id,moodle_course_id,count(distinct concat(moodle_activity_name,coursesection)) as required_activities
			from moodle_module_activity_summary
			where content_completion_required=1 and length(salesforce_contact_id)>=1
			group by salesforce_contact_id,moodle_course_id
		) as tbl4
		on moodle_user_course_completion_summary.salesforce_contact_id=tbl4.salesforce_contact_id
		and moodle_user_course_completion_summary.moodle_course_id=tbl4.moodle_course_id
		) where new_general_sequence=1;
	
--
-- QUITTAR DUPLOCADOS
--
	
select 
date(createddate) as createddate,student_id,moodle_course_id,day_info,
extract(day from day_info-createddate) as progress_start_day, 
activities_day as activities_0,
activities_day+activities_day1 as activities_0_1,
activities_day+activities_day1+activities_day2+activities_day3 as activities_0_3,
activities_day+activities_day1+activities_day2+activities_day3+activities_day4+activities_day5+activities_day6+activities_day7 as activities_0_7
from 
(
	select 
	tbl1.createddate,tbl1.student_id,tbl1.moodle_course_id,day_info,has_login,
	case 
		when tbl2.activities is null then 0 else tbl2.activities 
	end as activities_day,
	lag(activities_day,1) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day1,
	lag(activities_day,2) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day2,
	lag(activities_day,3) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day3,
	lag(activities_day,4) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day4,
	lag(activities_day,5) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day5,
	lag(activities_day,6) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day6,
	lag(activities_day,7) over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as activities_day7,
	row_number() over (partition by tbl1.student_id, tbl1.moodle_course_id order by day_info desc) as row_days
	from
	(
		select createddate,cohort_day.student_id,moodle_course_id,date(day_info) as day_info,has_login
		from cohort_day
		inner join 
		(
			select 
			salesforce_contact_id,moodle_course_id
			from 
			(
				select moodle_user_course_completion_summary.salesforce_contact_id,
				moodle_user_course_completion_summary.moodle_course_id,general_sequence,
				case
					when completed_evaluations is null then 0 else completed_evaluations
				end as completed_courses_evaluations,
				row_number() over (partition by moodle_user_course_completion_summary.salesforce_contact_id
							order by completed_courses_evaluations desc,general_sequence asc) as new_general_sequence
				from moodle_user_course_completion_summary
				left join
				(
					select salesforce_contact_id,moodle_course_id,count(distinct concat(moodle_activity_name,coursesection)) as completed_evaluations
					from moodle_module_activity_summary
					where (moodle_activitytype like '%uiz%' or moodle_activitytype like '%h5p%' or moodle_activitytype like '%hvp%')
						and content_completion_required=1 
						and moodle_activity_name not like '%EP%' 
						and moodle_activity_name not like '%ntegradora%' 
						and moodle_activity_name not like '%CV%'
						and moodle_activity_name not like '%ideo%'
						and moodle_activity_name not like '%Lección%' 
						and moodle_assign_type not like '%integradora%' 
						and moodle_assign_type not like '%practica%'
						and moodle_activity_name not like '%nteractivo%'
						and length(salesforce_contact_id)>=1
				group by salesforce_contact_id,moodle_course_id
				) as tbl3
				on moodle_user_course_completion_summary.salesforce_contact_id=tbl3.salesforce_contact_id
				and moodle_user_course_completion_summary.moodle_course_id=tbl3.moodle_course_id
		) 
		where new_general_sequence=1		
	) as tbl5
		on cohort_day.student_id = tbl5.salesforce_contact_id
		where day_info>=to_date('2021-06-01', 'YYYY/MM/DD') and createddate>=to_date('2021-01-01', 'YYYY/MM/DD')
	) as tbl1
		left join 
		(
			select 
			salesforce_contact_id,moodle_course_id,moodle_activity_completion_date,count(distinct concat(moodle_activity_name,coursesection)) as activities
			from
			(
				select 
				salesforce_contact_id,moodle_course_id,module_id,moodle_activity_name,coursesection,
				date(moodle_activity_completion_date) as moodle_activity_completion_date
				from moodle_module_activity_summary
				where content_completion_required=1 and LENGTH(salesforce_contact_id)>=2 
			)
			group by salesforce_contact_id,moodle_course_id,moodle_activity_completion_date order by moodle_activity_completion_date asc
		) as tbl2
	on tbl1.student_id=tbl2.salesforce_contact_id and tbl1.moodle_course_id=tbl2.moodle_course_id and date(tbl1.day_info)=tbl2.moodle_activity_completion_date 
	order by moodle_course_id, day_info desc
) 
where row_days>7 and progress_start_day>=0 order by createddate asc,student_id desc,moodle_course_id asc,day_info asc;


select 
salesforce_contact_id,moodle_course_id,module_id,moodle_activity_name,coursesection,date(moodle_activity_completion_date) as moodle_activity_completion_date,
concat(moodle_activity_name,coursesection)
from moodle_module_activity_summary
where content_completion_required=1 and salesforce_contact_id='0035G00001f7WSAQA2' and moodle_course_id=508 order by moodle_activity_completion_date desc;