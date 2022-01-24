with raw_data_lux as(
with meta_loc as (
	select *,  me.id as id_metadata, osm_nodes.id as id_osm
	from metadata me
	join osm_nodes on st_within(me.location, osm_nodes.geom))
	
	select r.value as meanlux, rd.value as temp, r.tstamp, r.meta_id, name, location,
	case
		when r.value <= 10 then '1'
		when r.value <= 500 then '2'
		when r.value <= 2000 then '3'
		when r.value <= 15000 then '4'
		when r.value <= 20000 then '5'
		
		when r.value <= 50000 then '6'
		when r.value > 50000 then '7'
	end 
	as category, m.geom

	from raw_data as r
	join raw_data as rd on r.tstamp=rd.tstamp 
		and rd.meta_id=r.meta_id --stamp und meta_id provide a unique id
		and rd.variable_id = 1 --join only temperature
	join meta_loc as m on r.meta_id=m.id_metadata 
	where r.variable_id = 2),

raw_data_dis as(
select avg(temp) as avgtemp, name, category, count(temp) as n
from raw_data_lux rdl
group by name, category),

meantemp as (
	select avg(temp) as avgtemp, name
	from raw_data_lux
	group by name
	)
select mt.avgtemp, rdl.name,  rdl.category, rdl.n
from raw_data_dis as rdl
join meantemp as mt on mt.name=rdl.name
