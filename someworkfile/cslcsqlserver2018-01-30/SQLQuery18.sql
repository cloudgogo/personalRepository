--7
DECLARE @max_iyperiod INT
SET @max_iyperiod=201708
select right(cast(@max_iyperiod as nvarchar(10)),2)
select case right(cast(@max_iyperiod as nvarchar(10)),2) when '01' then sum(DBLDEPR1)  end  from odm.FCT_FIXEDASSETSDEPRECIATION where SDEPRASSETNUM in('20071001728','20071001729','20080906827') and IYEAR=LEFT(@max_iyperiod,4);
select (17034.01+632787.78+206178.73)*(2.5/7) --305713.73771384
select * from odm.COST_ALLOC_VALUE where IYPERIOD=201702

select * from odm.FCT_FIXEDASSETSDEPRECIATION


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
                               and IYEAR=LEFT(@max_iyperiod,4)
                               
                               
                               select case '02' 
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
                               and IYEAR=2017