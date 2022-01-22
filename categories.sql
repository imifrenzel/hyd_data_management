select r.meta_id as m_id, r.variable_id as v_id, r.tstamp as dttm, r.value as lux, rd.value as temp,
	m.location, device_id,
	case
		when r.value <= 10 then '1'
		when r.value <= 500 then '2'
		when r.value <= 2000 then '3'
		when r.value <= 15000 then '4'
		when r.value <= 20000 then '5'
		when r.value <= 50000 then '6'
		when r.value > 50000 then '7'
	end 
	as category

from raw_data as r
join raw_data as rd on r.tstamp=rd.tstamp 
	and rd.meta_id=r.meta_id --stamp und meta_id provide a unique id
	and rd.variable_id = 1 --join only temperature
join metadata as m on r.meta_id=m.id 
where r.variable_id = 2 


