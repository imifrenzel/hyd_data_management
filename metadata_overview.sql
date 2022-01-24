with base_data as (
	select * from data d
	join metadata m on d.meta_id=m.id
	where variable_id=1
),
mean_temperature as (
	select 
		base_data.id,
		avg(value) as t_avg
	from base_data
	group by base_data.id
),
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
	select 
		t.id,
		t_var
	from (
		select base_data.id,
		date_trunc('day', tstamp) as day,
		stddev_samp(value) as t_var
		from base_data
		group by base_data.id, date_trunc('day', tstamp)
	) t
),
amount as (
	select id, count(*) as "N" from base_data group by id
)
select 
	m.id,
	device_id,
	avg(mean_temperature.t_avg) as tavg,
	avg(day_temperature.t_day) as tavg_day,
	avg(night_temperature.t_night) as tavg_night,
	avg(var.t_var) as t_var,
	min(amount."N") as N,
	location
from metadata m
join mean_temperature on m.id=mean_temperature.id
join day_temperature on m.id=day_temperature.id
join night_temperature on m.id=night_temperature.id
join amount on m.id=amount.id
join var on m.id=var.id
group by m.id, device_id, location
order by m.id asc