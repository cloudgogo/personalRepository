DECLARE @max_iyperiod INT
SET @max_iyperiod=201711
SELECT result1.O_ACCO_CODE,dirver.DRIVER_CODE,result1.linkSumAmount,result1.total_amount,result1.IYPERIOD
FROM (
	SELECT RESULT.O_ACCO_CODE, RESULT.IYPERIOD, RESULT.linkSumAmount, SUM(linkSumAmount) OVER (PARTITION BY RESULT.O_ACCO_CODE ) AS total_amount
	FROM (
		SELECT fixedresult.oaccode AS O_ACCO_CODE
			, CASE fixedresult.oaccode
				WHEN 7 THEN SUM(fixedresult.amount) / 7 * 2.5
				ELSE SUM(fixedresult.amount)
			END AS linkSumAmount, fixedresult.iyperiod AS IYPERIOD
		FROM (
			SELECT mapping.oaccode, mapping.SDEPRASSETNUM
				, LEFT(@max_iyperiod, 4) + mouth.mouth AS iyperiod
				, CASE mouth.mouth
					WHEN '01' THEN DBLDEPR1
					WHEN '02' THEN DBLDEPR2
					WHEN '03' THEN DBLDEPR3
					WHEN '04' THEN DBLDEPR4
					WHEN '05' THEN DBLDEPR5
					WHEN '06' THEN DBLDEPR6
					WHEN '07' THEN DBLDEPR7
					WHEN '08' THEN DBLDEPR8
					WHEN '09' THEN DBLDEPR9
					WHEN '10' THEN DBLDEPR10
					WHEN '11' THEN DBLDEPR11
					WHEN '12' THEN DBLDEPR12
				END AS amount
			FROM odm.FCT_FIXEDASSETSDEPRECIATION fixed, (
					SELECT '01' AS mouth
					UNION ALL
					SELECT '02' AS mouth
					UNION ALL
					SELECT '03' AS mouth
					UNION ALL
					SELECT '04' AS mouth
					UNION ALL
					SELECT '05' AS mouth
					UNION ALL
					SELECT '06' AS mouth
					UNION ALL
					SELECT '07' AS mouth
					UNION ALL
					SELECT '08' AS mouth
					UNION ALL
					SELECT '09' AS mouth
					UNION ALL
					SELECT '10' AS mouth
					UNION ALL
					SELECT '11' AS mouth
					UNION ALL
					SELECT '12' AS mouth
				) mouth, (
					SELECT '20071001728' AS SDEPRASSETNUM, 7 AS oaccode
					UNION ALL
					SELECT '20071001729' AS SDEPRASSETNUM, 7 AS oaccode
					UNION ALL
					SELECT '20080906827' AS SDEPRASSETNUM, 7 AS oaccode
					UNION ALL
					SELECT '201008071266' AS SDEPRASSETNUM, 8 AS oaccode
					UNION ALL
					SELECT '201412034966' AS SDEPRASSETNUM, 8 AS oaccode
					UNION ALL
					SELECT '201512065347' AS SDEPRASSETNUM, 8 AS oaccode
				) mapping
			WHERE fixed.IYEAR = LEFT(@max_iyperiod, 4)
				AND fixed.SDEPRASSETNUM = mapping.SDEPRASSETNUM
				AND mouth.mouth <= RIGHT(@max_iyperiod, 2)
		) fixedresult
		GROUP BY fixedresult.iyperiod, fixedresult.oaccode
		UNION ALL
		SELECT linkOAMap.O_ACCO_CODE
			,  SUM(linkFactAc.MD) linkSumAmount, linkFactAc.IYPERIOD
		FROM ODM.FCT_ACCASS linkFactAc, ODM.COST_OACCO_ACCO_MAP linkOAMap, ODM.COST_OACCO_DEPART_GET_MAP linkGetMap
		WHERE linkFactAc.CCODE = linkOAMap.CCODE
			AND linkOAMap.O_ACCO_CODE = linkGetMap.O_ACCO_CODE
			AND linkFactAc.CDEPT_ID = linkGetMap.CDEPT_ID
			AND IYPERIOD <= @max_iyperiod
			AND LEFT(IYPERIOD, 4) = LEFT(@max_iyperiod, 4)
			AND linkOAMap.O_ACCO_CODE NOT IN ('7', '8')
		GROUP BY linkOAMap.O_ACCO_CODE, linkFactAc.IYPERIOD
	) RESULT
) result1, ODM.COST_DRIVER_OACCO_MAP as dirver
WHERE result1.IYPERIOD = @max_iyperiod and result1.O_ACCO_CODE=dirver.O_ACCO_CODE
ORDER BY CAST(result1.O_ACCO_CODE as decimal)

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