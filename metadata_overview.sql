-- First we select only the data we are interested in from 
-- the quality controlled data table
with base_data as (
	select * from data d
	join metadata m on d.meta_id=m.id
	-- The other, better, solution is to join the variables and filter by variable name
	where variable_id=1
),
mean_temperature as (
	select 
		base_data.id,
		avg(value) as t_avg
	from base_data
	group by base_data.id
),
-- YOUR SOLUTION
day_temperature as (
	select
		base_data.id,
		avg(value) as t_day
	from base_data
	where date_part('hour', tstamp) >= 6 and date_part('hour', tstamp) < 18
	group by base_data.id
),
night_temperature as (
	select
		id,
		avg(value) as t_night
	from base_data
	group by base_data.id
	
),
var as (
	-- here I am using the range as a coefficient of variation
	-- these are two different SQL queries, as the outer one is
	-- selecting from the inner one
	-- you can fix this one, or replace it all together with another
	-- coefficient of variation
	select 
		t.id,
		t_max - t_min as t_var
	from (
		select base_data.id,
		date_trunc('day', tstamp) as day,
		min(value) as t_min,
		max(value) as t_max
		from base_data
		group by base_data.id, date_trunc('day', tstamp)
	) t
),
amount as (
	select id, count(*) as "N" from base_data group by id
)
select 
	mean_temperature.t_avg,
	day_temperature.t_day,
	night_temperature.t_night,
	var.t_var,
	amount."N",
	m.*
from metadata m
join mean_temperature on m.id=mean_temperature.id
join day_temperature on m.id=day_temperature.id
join night_temperature on m.id=night_temperature.id
join amount on m.id=amount.id
join var on m.id=var.id