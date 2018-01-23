DECLARE @max_iyperiod INT
SET @max_iyperiod=201702
select right(cast(@max_iyperiod as nvarchar(10)),2)
select case right(cast(@max_iyperiod as nvarchar(10)),2) 
when '01' then sum(DBLDEPR1)/7*2.5 
when '02' then sum(DBLDEPR2)/7*2.5  
when '03' then sum(DBLDEPR3)/7*2.5
when '04' then sum(DBLDEPR4)/7*2.5  
when '05' then sum(DBLDEPR5)/7*2.5
when '06' then sum(DBLDEPR6)/7*2.5  
when '07' then sum(DBLDEPR7)/7*2.5 
when '08' then sum(DBLDEPR8)/7*2.5  
when '09' then sum(DBLDEPR9)/7*2.5 
when '10' then sum(DBLDEPR10)/7*2.5  
when '11' then sum(DBLDEPR11)/7*2.5 
when '12' then sum(DBLDEPR12)/7*2.5  
end
from odm.FCT_FIXEDASSETSDEPRECIATION
where SDEPRASSETNUM in('20071001728','20071001729','20080906827') 
and IYEAR=LEFT(@max_iyperiod,4);

SET @max_iyperiod=201702
select right(cast(@max_iyperiod as nvarchar(10)),2)
select case right(cast(@max_iyperiod as nvarchar(10)),2) 
when '01' then sum(DBLDEPR1)
when '02' then sum(DBLDEPR2) 
when '03' then sum(DBLDEPR3)
when '04' then sum(DBLDEPR4) 
when '05' then sum(DBLDEPR5)
when '06' then sum(DBLDEPR6) 
when '07' then sum(DBLDEPR7)
when '08' then sum(DBLDEPR8) 
when '09' then sum(DBLDEPR9)
when '10' then sum(DBLDEPR10)  
when '11' then sum(DBLDEPR11) 
when '12' then sum(DBLDEPR12)  
end
from odm.FCT_FIXEDASSETSDEPRECIATION
where SDEPRASSETNUM in('201008071266','201412034966','201512065347') 
and IYEAR=LEFT(@max_iyperiod,4);

select *
from odm.FCT_FIXEDASSETSDEPRECIATION
where SDEPRASSETNUM in('201008071266','201412034966','201512065347') 
and IYEAR=LEFT(@max_iyperiod,4);

select * from  odm.COST_ALLOC_VALUE where  IYPERIOD=201702