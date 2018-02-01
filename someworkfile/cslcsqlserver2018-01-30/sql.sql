DECLARE @max_iyperiod INT
SET @max_iyperiod=201708
SELECT a.O_ACCO_CODE, b.DRIVER_CODE, c.linkSumAmount,
          (  select sum(tmp.innerSumAmount) 
		     from ( select innOAMap.O_ACCO_CODE, (CASE WHEN innOAMap.O_ACCO_CODE = '7' THEN (SUM(innFactAcc.MD)/7*2.5) ELSE SUM(innFactAcc.MD) END) innerSumAmount, 
			               innFactAcc.IYPERIOD
                    from ODM.FCT_ACCASS as innFactAcc,
                         ODM.COST_OACCO_ACCO_MAP as innOAMap,
                         ODM.COST_OACCO_DEPART_GET_MAP as innerGetMap
                    where innFactAcc.CCODE=innOAMap.CCODE and 
                          innOAMap.O_ACCO_CODE=innerGetMap.O_ACCO_CODE and
                          innFactAcc.CDEPT_ID= innerGetMap.CDEPT_ID and 
	                      innFactAcc.IYPERIOD<= @max_iyperiod and LEFT(IYPERIOD,4)=left(@max_iyperiod,4)
                          group by innOAMap.O_ACCO_CODE, innFactAcc.IYPERIOD
			       ) tmp 
		      where tmp.IYPERIOD<=@max_iyperiod and tmp.O_ACCO_CODE=c.O_ACCO_CODE --and tmp.IYPERIOD=c.IYPERIOD
	       ) as total_amount, c.IYPERIOD
    FROM  ODM.COST_OUT_ACCOUNT as a inner join  ODM.COST_DRIVER_OACCO_MAP as b on a.O_ACCO_CODE = b.O_ACCO_CODE
	       left join (  select linkOAMap.O_ACCO_CODE, (CASE WHEN linkOAMap.O_ACCO_CODE = '7' THEN (SUM(linkFactAc.MD)/7*2.5) ELSE SUM(linkFactAc.MD) END) linkSumAmount,
		                       linkFactAc.IYPERIOD
                        from ODM.FCT_ACCASS as linkFactAc,
                             ODM.COST_OACCO_ACCO_MAP as linkOAMap,
                             ODM.COST_OACCO_DEPART_GET_MAP as linkGetMap
                        where linkFactAc.CCODE=linkOAMap.CCODE and 
                              linkOAMap.O_ACCO_CODE=linkGetMap.O_ACCO_CODE and
                              linkFactAc.CDEPT_ID=linkGetMap.CDEPT_ID and 
	                          IYPERIOD<=@max_iyperiod and LEFT(IYPERIOD,4)=left(@max_iyperiod,4)
                       group by linkOAMap.O_ACCO_CODE,linkFactAc.IYPERIOD) as c on a.O_ACCO_CODE = c.O_ACCO_CODE
   WHERE c.IYPERIOD = @max_iyperiod
   ORDER BY CAST(a.O_ACCO_CODE as decimal)