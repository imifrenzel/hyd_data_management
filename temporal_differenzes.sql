with meta_loc as (
		select me.id as id_metadata, osm_nodes.id as id_osm, location, geom, name, device_id
		from metadata me
		join osm_nodes on st_within(me.location, osm_nodes.geom)),
		
	 years as(
		select meta_id, 
		CASE
			WHEN tstamp between '2021-11-01' and '2022-02-01' then 2022
			WHEN tstamp between '2020-11-01' and '2021-02-01' then 2021
			WHEN tstamp between '2019-11-01' and '2020-02-01' then 2020
			WHEN tstamp between '2018-11-01' and '2019-02-01' then 2019
			WHEN tstamp between '2017-11-01' and '2018-02-01' then 2018
		end as year
		from raw_data
	group by meta_id, year
	),
	
	categories as(
	select r.value as lux, rd.value as temp, name, year,
	case
		when r.value <= 10 then '1'
		when r.value <= 500 then '2'
		when r.value <= 2000 then '3'
		when r.value <= 15000 then '4'
		when r.value <= 20000 then '5'
		when r.value <= 50000 then '6'
		when r.value > 50000 then '7'
	end as category, geom
	from raw_data as r
	join raw_data as rd on r.tstamp=rd.tstamp
		and rd.meta_id=r.meta_id --stamp und meta_id provide a unique id
		and rd.variable_id = 1 --join only temperature
	join meta_loc as m on r.meta_id=m.id_metadata
	join years as y on r.meta_id=y.meta_id
	where r.variable_id = 2),
	
	gis as (
	select avg(lux) as avglux, avg(temp) as avgtemp, name, year, category, geom 
	from categories
	group by name, year, category, geom)
	
select * into giss from gis
