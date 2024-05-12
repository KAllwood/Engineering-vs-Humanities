creat/create the tables and import the data.
create table "Project".public.recent_grads(
rank bigint,
major_code bigint,
major varchar,
total bigint,
men bigint,
women bigint,
major_category varchar,
ShareWomen float8,
Sample_size int,
Employed bigint,
Part_time bigint,
Full_time_year_round bigint,
Unemployed bigint,
Unemployment_rate float8,
Median bigint,
P25th bigint,
P75th bigint,
Non_college_jobs bigint,
Low_wage_jobs bigint
);
ALTER TABLE "Project".public.recent_grads ADD PRIMARY key (major,major_code);
create table "Project".public.grad_students (
major_code bigint,
major varchar,
major_category varchar,
Grad_total bigint,
Grad_sample_size bigint,
Grad_full_time_year_round bigint,
Grad_unemployed bigint,
Grad_unemployment_rate float8,
Grad_median bigint,
Grad_P25 bigint,
Grad_P75 bigint,
Nongrad_total bigint,
Nongrad_employed bigint,
Nongrad_full_time_year_round bigint,
Nongrad_unemployed bigint,
Nongrad_unemployment_rate float8,
Nongrad_median bigint,
Nongrad_P25 bigint,
Nongrad_P75 bigint,
Grad_share bigint,
Grad_premium bigint
);
ALTER TABLE "Project".public.grad_students ADD PRIMARY key (major,major_code);
-- Isolate the target major categories for analysis
CREATE TABLE "Project".public.grad_majors_unemployed
  AS (select *  from grad_students
where "major_category"= 'Engineering' or "major_category"= 'Humanities & Liberal Arts'
);
CREATE TABLE "Project".public.undergrad_majors_unemployed
  AS (select *  from recent_grads
where "major_category"= 'Engineering' or "major_category"= 'Humanities & Liberal Arts'
);
/*
 * This was our first attempt to combine the tables using a UNION keyword
select *
from grad_majors_unemployed gmu
union
select *
from undergrad_majors_unemployed rgmu
//The union statement above did not work so we added a dummy column for the time being
alter table public.undergrad_majors_unemployed
add dummy bigint;
The tables not only don't have the same number of column but they also don't have matching data types
This was a good attempt but it failed
ALTER TABLE public.undergrad_majors_unemployed
DROP COLUMN Dummy;
*/
select COUNT (*)
	from "Project".public.undergrad_majors_unemployed
		where major_category = 'Engineering' or major_category = 'Humanities & Liberal Arts'
	
		select COUNT (*)
	from "Project".public.grad_majors_unemployed
		where major_category = 'Engineering' or major_category = 'Humanities & Liberal Arts'
select count (
from grad_majors_unemployed
where "major_category"= 'Engineering' or "major_category"= 'Humanities & Liberal Arts'
);
/Join the unemployment tables together/
select distinct  undergrad_majors_unemployed.unemployment_rate , grad_majors_unemployed.major_category
from grad_majors_unemployed
left outer join undergrad_majors_unemployed
ON undergrad_majors_unemployed.major_code = undergrad_majors_unemployed.major_code
/* make the join a standalone table*/
CREATE TABLE "Project".public.unemployment_join
AS (select distinct  undergrad_majors_unemployed.unemployment_rate , grad_majors_unemployed.major_category
from grad_majors_unemployed
left outer join undergrad_majors_unemployed
ON undergrad_majors_unemployed.major_code = undergrad_majors_unemployed.major_code );
CREATE TABLE "Project".public.unemployment_join_engineering
AS (select *
	from unemployment_join
	where major_category = 'Engineering');
CREATE TABLE "Project".public.unemployment_join_humanities
AS (select *
	from unemployment_join
	where major_category = 'Humanities & Liberal Arts');
-- the average unemployment rate for engineering majors is 0.06935901761363637
select AVG(unemployment_rate)
from unemployment_join_engineering
-- the average unemployment rate for Humanities & Liberal Arts majors is 0.06935901761363635
select AVG(unemployment_rate)
from unemployment_join_humanities
-- these results are too accurate we need to check for the validity of our join
/* the second entry in the engineering unemployment table has a rate of '0.063429289', let's check to see if
 * any engineering majors have this exact rate in either table
*/
/* This only returns 'AREA ETHNIC AND CIVILIZATION STUDIES' which is not an engineering major
 * this means that the only entry with this unemployment rate in the entire dataset is an Humanities major
 * so our join is wrong
select *
from recent_grads
where unemployment_rate  = '0.063429289'
***/
/*
 *
--1.1401852730000004
select SUM(grad_unemployment_rate)
from grad_students
where major_category = 'Engineering'
--1.836682438
select SUM(unemployment_rate)
from recent_grads
where major_category = 'Engineering'
select count(grad_unemployment_rate)
from grad_students
where major_category = 'Engineering'
select count(unemployment_rate)
from recent_grads
where major_category = 'Engineering'
*/
create table "Project".public.Engineering_unemployment
AS(select  grad_unemployment_rate as unemployment_rate
from grad_students
where major_category = 'Engineering'
union
select unemployment_rate
from recent_grads
where major_category = 'Engineering');
--0.05132530536206896
select avg (unemployment_rate)
from engineering_unemployment
create table "Project".public.Humanities_unemployment
AS(select  grad_unemployment_rate as unemployment_rate
from grad_students
where major_category = 'Humanities & Liberal Arts'
union
select unemployment_rate
from recent_grads
where major_category = 'Humanities & Liberal Arts');
--0.06259660746666668
select avg (unemployment_rate)
from humanities_unemployment
-- This is for the average median salary
create table "Project".public.Engineering_median
AS(select  grad_median  as median
from grad_students
where major_category = 'Engineering'
union
select median
from recent_grads
where major_category = 'Engineering');
--74635.323529411765
select avg (median)
from engineering_median
create table "Project".public.Humanities_median
as (select  grad_median  as median
from grad_students
where major_category = 'Humanities & Liberal Arts'
union
select median
from recent_grads
where major_category = 'Humanities & Liberal Arts');
--47223.809523809524
select avg (median)
from humanities_median
-- This is for the average full time year round
create table "Project".public.Engineering_fulltime
AS(select grad_full_time_year_round as full_time_year_round
from grad_students
where major_category = 'Engineering'
union
select full_time_year_round
from recent_grads
where major_category = 'Engineering');
--29258.206896551724
select avg (full_time_year_round)
from engineering_fulltime
create table "Project".public.humanities_fulltime
AS(select grad_full_time_year_round as full_time_year_round
from grad_students
where major_category = 'Humanities & Liberal Arts'
union
select full_time_year_round
from recent_grads
where major_category = 'Humanities & Liberal Arts');
--58138.466666666667
select avg (full_time_year_round)
from humanities_fulltime
-- Checking for the sample size of each major
create table "Project".public.humanities_sample
AS(select grad_sample_size as sample_size
from grad_students
where major_category = 'Humanities & Liberal Arts'
union
select sample_size
from recent_grads
where major_category = 'Humanities & Liberal Arts');
--52,565
select sum (sample_size)
from humanities_sample
create table "Project".public.engineering_sample
AS(select grad_sample_size as sample_size
from grad_students
where major_category = 'Engineering'
union
select sample_size
from recent_grads
where major_category = 'Engineering');
--47,347
select sum (sample_size)
from engineering_sample
