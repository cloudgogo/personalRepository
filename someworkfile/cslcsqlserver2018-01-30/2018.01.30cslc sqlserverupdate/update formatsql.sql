USE [ESREPORT]
GO
/****** Object:  StoredProcedure [ODM].[Pro_DivideCost]    Script Date: 01/22/2018 21:03:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROC [ODM].[Pro_DivideCost]
AS 

DECLARE @out_acct_code VARCHAR(255)
DECLARE @driven_code VARCHAR(255)
DECLARE @cur_amount decimal(20,2)
DECLARE @sum_amount decimal(20, 2)
DECLARE @dep_percentage decimal(20, 10)
DECLARE @total_tmp decimal(20, 10)
DECLARE @rate decimal(20,10)
DECLARE @dept_id VARCHAR(255)
DECLARE @iyperiod int
DECLARE @max_iyperiod int
DECLARE @driver_update_date date
DECLARE @dvd_update_date date
DECLARE @tailCountingAmount decimal(20,2)
DECLARE @tailTotalAmount decimal(20,2)

--DECLARE @cost_ou_acc_code VARCHAR(255)
TRUNCATE TABLE ODM.COST_PUB_EXPENSE_TMP;

--取得动因配置最新的会计区间
SELECT @max_iyperiod=MAX(a.IYPERIOD)
FROM ODM.COST_DRIVER_DEPART_MAP a, ODM.COST_OACCO_DEPART_POST_MAP b
WHERE a.IYPERIOD = b.IYPERIOD
--初始化数据时使用
 set @max_iyperiod=201708
 
IF (@max_iyperiod IS NOT NULL AND @max_iyperiod != 0)
    BEGIN
    --取得动因配置最后的更新时间
    SELECT @driver_update_date=MAX(a.UPDATE_DATE)
    FROM ODM.COST_DRIVER_DEPART_MAP a, ODM.COST_OACCO_DEPART_POST_MAP b
    WHERE a.IYPERIOD = b.IYPERIOD

    --取得成本分摊开始时间
    SELECT @dvd_update_date=MIN(a.UPDATE_DATE)
    FROM ODM.COST_PUB_EXPENSE a
    WHERE a.IYPERIOD = @max_iyperiod

    --判断是否需要执行成本分摊
    IF(@dvd_update_date IS NOT NULL) --如果@dvd_update_date为NULL, 说明当期还没有进行成本分摊,可以直接进行分摊，如果不为NLL,那要分情况
            BEGIN
        IF (@driver_update_date < @dvd_update_date)  --如果分摊开始时间比动因更新时间晚，说明已经进行了分摊，并且分摊之后动因数据没有更新，可以直接返回
		            BEGIN
            RETURN 405
        END
	            ELSE --当期成本分摊之后，动因数据发生改变，需要重新分摊
		            BEGIN
            --删除成本分摊项
            DELETE FROM COST_PUB_EXPENSE
						WHERE IYPERIOD = @max_iyperiod

            --删除部门全成本1
            DELETE FROM COST_DEPT_FULL_COSTING
						WHERE IYPERIOD = @max_iyperiod
            --删除部门全成本2   2016-12-06update 职能部门分摊数据未删除
            DELETE FROM COST_FUNC_DEPT_FULL_COSTING
						WHERE IYPERIOD = @max_iyperiod

            --删除productuse   2017-03-15update 
            DELETE FROM COST_COST_DETAILS
						WHERE IYPERIOD = @max_iyperiod

            --删除分摊总值     2018.01.22update 将分摊总值的计算放入此处
            delete from COST_ALLOC_VALUE
						where IYPERIOD =@max_iyperiod

        END
    END
END
ELSE 
    BEGIN
    RETURN 404
END

	print 'start to perform division'

--取得账外分摊公共费用项各项的总金额   
    
--- 2018.01.22update 修改房租的取值逻辑
DECLARE public_expense_cursor CURSOR FOR 
SELECT result1.O_ACCO_CODE, dirver.DRIVER_CODE, result1.linkSumAmount, result1.total_amount, result1.IYPERIOD
FROM (
	SELECT RESULT.O_ACCO_CODE, RESULT.IYPERIOD, RESULT.linkSumAmount, SUM(linkSumAmount) OVER (PARTITION BY RESULT.O_ACCO_CODE ) AS total_amount
    FROM (
                    SELECT fixedresult.oaccode AS O_ACCO_CODE
			, CASE fixedresult.oaccode
				WHEN 7 THEN SUM(fixedresult.amount) / 7 * 2.5
				ELSE SUM(fixedresult.amount)
			END AS linkSumAmount, fixedresult.iyperiod AS IYPERIOD
            FROM (
		    -- 分摊动因为房租的结果
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
                    AND mouth.mouth = RIGHT(@max_iyperiod, 2)
		) fixedresult
            GROUP BY fixedresult.iyperiod, fixedresult.oaccode
        UNION ALL
            SELECT linkOAMap.O_ACCO_CODE
			, SUM(linkFactAc.MD) linkSumAmount, linkFactAc.IYPERIOD
            FROM ODM.FCT_ACCASS linkFactAc, ODM.COST_OACCO_ACCO_MAP linkOAMap, ODM.COST_OACCO_DEPART_GET_MAP linkGetMap
            WHERE linkFactAc.CCODE = linkOAMap.CCODE
                AND linkOAMap.O_ACCO_CODE = linkGetMap.O_ACCO_CODE
                AND linkFactAc.CDEPT_ID = linkGetMap.CDEPT_ID
                AND IYPERIOD = @max_iyperiod
                AND LEFT(IYPERIOD, 4) = LEFT(@max_iyperiod, 4)
                AND linkOAMap.O_ACCO_CODE NOT IN ('7', '8')
            GROUP BY linkOAMap.O_ACCO_CODE, linkFactAc.IYPERIOD
        UNION ALL
            -- 当月之前的值
            select ALLOC_CODE O_ACCO_CODE, CUR_AMOUNT linkSumAmount, IYPERIOD
            from odm.COST_ALLOC_VALUE
            where  left (IYPERIOD,4)=left(@max_iyperiod,4) and right(IYPERIOD,2)<right(@max_iyperiod,2)
	
	) RESULT
) result1, ODM.COST_DRIVER_OACCO_MAP as dirver
WHERE result1.IYPERIOD = @max_iyperiod and result1.O_ACCO_CODE=dirver.O_ACCO_CODE
ORDER BY CAST(result1.O_ACCO_CODE as decimal)
--- ^ 2018.01.22update





   --打开游标，
   OPEN public_expense_cursor
   FETCH NEXT FROM public_expense_cursor INTO @out_acct_code, @driven_code, @cur_amount,@sum_amount,@iyperiod
   --判断是否存在下一条记录
   WHILE @@FETCH_STATUS = 0
       BEGIN
    --2018.01.22update 向COST_ALLOC_VALUE表中插入数据
    INSERT INTO COST_ALLOC_VALUE
        (ALLOC_CODE,CUR_AMOUNT,SUM_AMOUNT,IYPERIOD)
    VALUES
        (@out_acct_code, @cur_amount, @sum_amount, @iyperiod)
    --- ^ 2018.01.22update
    SET @total_tmp = 0
    SET @tailCountingAmount = 0
    SET @tailTotalAmount = 0
    --循环处理基于人数占比动因的公共费用项
    IF (@driven_code ='1' OR @driven_code ='2') 
		     BEGIN
        --计算各个部门的人数占比
        DECLARE person_inner_cursor CURSOR FOR 
		           SELECT a.O_ACCO_CODE, a.CDEPT_ID, round(b.DRIVER_VALUE/s.sumperson,10) percentage
        FROM ODM.COST_OACCO_DEPART_POST_MAP ａ, ODM.COST_DRIVER_DEPART_MAP b,
            (	select c.O_ACCO_CODE, sum(d.DRIVER_VALUE) sumperson
            from ODM.COST_OACCO_DEPART_POST_MAP c, ODM.COST_DRIVER_DEPART_MAP d
            where  c.CDEPT_ID = d.CDEPT_ID and
                c.IYPERIOD = d.IYPERIOD and
                c.IYPERIOD = @max_iyperiod
            group by c.O_ACCO_CODE
					          ) s
        WHERE a.O_ACCO_CODE = @out_acct_code and
            a.CDEPT_ID = b.CDEPT_ID and
            a.IYPERIOD = b.IYPERIOD and
            a.O_ACCO_CODE = s.O_ACCO_CODE and
            a.IYPERIOD = @max_iyperiod
        ORDER BY a.O_ACCO_CODE,a.CDEPT_ID

        --打开游标，循环处理每个公共费用项下的部门所占成本
        OPEN person_inner_cursor
        FETCH NEXT FROM person_inner_cursor INTO @out_acct_code, @dept_id, @rate
        WHILE @@FETCH_STATUS = 0
			           BEGIN
            --进行尾差处理(处理占比除不尽的情况)
            IF (1- @total_tmp <= @rate)
			                   BEGIN
                SET @tailCountingAmount = (@cur_amount-@tailTotalAmount)
            END
						   ELSE 
						       BEGIN
                SET @tailCountingAmount=round(@cur_amount*@rate,2)
            END

            --将每个部门计算出来的公共费用分摊金额插入COST_PUB_EXPENSE 表中		    
            INSERT INTO ODM.COST_PUB_EXPENSE_TMP
                (OUT_ACCT_CODE,DEPT_ID,CUR_AMOUNT,IYPERIOD)
            VALUES
                (@out_acct_code,
                    @dept_id,
                    @tailCountingAmount,
                    @iyperiod)

            SET @tailTotalAmount = @tailTotalAmount + @tailCountingAmount
            SET @total_tmp =  @total_tmp + @rate

            FETCH NEXT FROM person_inner_cursor INTO @out_acct_code, @dept_id, @rate
        END
        --释放游标
        CLOSE person_inner_cursor
        DEALLOCATE person_inner_cursor
    END     
			  --循环处理基于成本占比动因的公共费用项
			 ELSE IF(@driven_code = '3')
			     BEGIN
        --计算各个部门的部门成本占比
        DECLARE cost_inner_cursor CURSOR FOR 
		                 SELECT ps.O_ACCO_CODE, ct.CDEPT_ID,
            cast(SUM(ct.SUM_AMOUNT) as decimal(20,10))/cast(s.sumallamount as decimal(20,10)) percentage
        FROM ODM.COST_OACCO_DEPART_POST_MAP as ps, ODM.COST_CT_ANALYSIS as ct,
            (	select b.O_ACCO_CODE, SUM(a.SUM_AMOUNT) sumallamount, a.IYPERIOD
            from ESREPORT.ODM.COST_CT_ANALYSIS as a,
                ESREPORT.ODM.COST_OACCO_DEPART_POST_MAP as b,
                ESREPORT.ODM.COST_DRIVER_OACCO_MAP as c
            where a.CDEPT_ID=b.CDEPT_ID and
                c.O_ACCO_CODE=b.O_ACCO_CODE and
                /*修改位置-只有部门成本元素参与成本总和的计算，如果以后变更需要修改下面的成本元素CODE*/
                a.CT_CODE IN ('1','12','13','14','18','26','27','28','29','30','31','40','41','47','48','49','50','51','52') and
                c.DRIVER_CODE=3 and
                a.IYPERIOD=b.IYPERIOD and
                a.IYPERIOD=@max_iyperiod
            group by b.O_ACCO_CODE,a.IYPERIOD
					          ) s
        WHERE ps.O_ACCO_CODE = @out_acct_code and
            ps.CDEPT_ID = ct.CDEPT_ID and
            ps.IYPERIOD = ct.IYPERIOD and
            ps.O_ACCO_CODE = s.O_ACCO_CODE and
            ps.IYPERIOD = s.IYPERIOD and
            ps.IYPERIOD = @max_iyperiod and
            /*修改位置-只有部门成本元素参与成本总和的计算，如果以后变更需要修改下面的成本元素CODE*/
            ct.CT_CODE IN ('1','12','13','14','18','26','27','28','29','30','31','40','41','47','48','49','50','51','52')
        GROUP BY ps.O_ACCO_CODE, ct.CDEPT_ID,s.sumallamount
        ORDER BY ps.O_ACCO_CODE, ct.CDEPT_ID

        --打开游标，循环处理每个公共费用项下的部门所占成本
        OPEN cost_inner_cursor
        FETCH NEXT FROM cost_inner_cursor INTO @out_acct_code, @dept_id, @rate
        WHILE @@FETCH_STATUS = 0
				        BEGIN
            IF (1- @total_tmp <= @rate)
							    BEGIN
                SET @tailCountingAmount = (@cur_amount-@tailTotalAmount)
            END
						    ELSE 
						        BEGIN
                SET @tailCountingAmount=round(@cur_amount*@rate,2)
            END

            --将每个部门计算出来的公共费用分摊金额插入COST_PUB_EXPENSE 表中		    
            INSERT INTO ODM.COST_PUB_EXPENSE_TMP
                (OUT_ACCT_CODE,DEPT_ID,CUR_AMOUNT,IYPERIOD)
            VALUES
                (@out_acct_code,
                    @dept_id,
                    @tailCountingAmount,
                    @iyperiod)

            SET @total_tmp =  @total_tmp + @rate
            SET @tailTotalAmount = @tailTotalAmount + @tailCountingAmount

            FETCH NEXT FROM cost_inner_cursor INTO @out_acct_code, @dept_id, @rate
        END
        --释放游标
        CLOSE cost_inner_cursor
        DEALLOCATE cost_inner_cursor
    END
    --读取一条数据
    FETCH NEXT FROM public_expense_cursor INTO @out_acct_code, @driven_code, @cur_amount,@sum_amount,@iyperiod
--END
--ELSE   -- 循环处理基于成本动因的公共费用项
END
	  
        --释放游标
        CLOSE public_expense_cursor
        DEALLOCATE public_expense_cursor

		--合并分摊项元素 成为成本元素口径 插表
	    INSERT INTO ODM.COST_PUB_EXPENSE
    (COST_ELE_CODE, DEPT_ID, CUR_AMOUNT, IYPERIOD)
SELECT b.ELE_CODE, a.DEPT_ID, SUM(a.CUR_AMOUNT) CUR_AMOUNT, a.IYPERIOD
FROM ODM.COST_PUB_EXPENSE_TMP a, ODM.COST_OACCO_COELE_MAP b
WHERE b.O_ACCO_CODE = a.OUT_ACCT_CODE and a.IYPERIOD=@max_iyperiod
GROUP BY b.ELE_CODE, a.DEPT_ID, a.IYPERIOD


DECLARE @ele_code VARCHAR(255)
DECLARE @pub_expenKey int
		--更新各部门分摊项金额的累计值
		DECLARE ele_expense_cursor CURSOR FOR 
		   SELECT ID, COST_ELE_CODE, DEPT_ID, CUR_AMOUNT, IYPERIOD
FROM ODM.COST_PUB_EXPENSE
WHERE IYPERIOD=@max_iyperiod

		 --打开游标，
         OPEN ele_expense_cursor
         FETCH NEXT FROM ele_expense_cursor INTO @pub_expenKey,@ele_code, @dept_id, @cur_amount,@iyperiod
         --判断是否存在下一条记录
         WHILE @@FETCH_STATUS = 0
             BEGIN
    UPDATE ODM.COST_PUB_EXPENSE
				 SET TOTAL_AMOUNT=(  SELECT SUM(CUR_AMOUNT)
    FROM ODM.COST_PUB_EXPENSE
    WHERE  COST_ELE_CODE=@ele_code and DEPT_ID=@dept_id
        and IYPERIOD<= @iyperiod and LEFT(IYPERIOD,4)=left(@iyperiod,4)
    GROUP BY COST_ELE_CODE,DEPT_ID
								   )
				 WHERE ID=@pub_expenKey
    --读取一条数据
    FETCH NEXT FROM ele_expense_cursor INTO @pub_expenKey,@ele_code, @dept_id, @cur_amount,@iyperiod
END

			 --释放游标
            CLOSE ele_expense_cursor
            DEALLOCATE ele_expense_cursor


--基于成本分析表数据和各部门分摊项金额数据进行成本分摊
DECLARE @pub_amount decimal(20,2)
DECLARE @pub_sum_amount decimal(20, 2)
        SET @ele_code = NULL
		SET @dept_id = NULL
		SET @cur_amount = 0
		SET @sum_amount = 0
		SET @iyperiod = 0

		DECLARE full_consting_cursor CURSOR FOR 
		   --取得成本分析表和分摊项表中都存在的数据
		       SELECT CT_CODE, CDEPT_ID,
        case when  a.CDEPT_ID in ( select CDEPT_ID
        --如果取数源是该部门的话，应该先从原金额中减去取数金额，再加上应该分摊的金额
        from ( select d.CDEPT_ID, e.SRC_ELE_CODE
            from esreport.ODM.COST_OACCO_DEPART_GET_MAP d, esreport.ODM.COST_OACCO_COELE_MAP e
            where d.O_ACCO_CODE = e.O_ACCO_CODE
												 ) map
        where map.CDEPT_ID = a.CDEPT_ID and
            map.SRC_ELE_CODE = a.CT_CODE										        
										 ) 
	               then (isnull(a.CUR_AMOUNT,0)- isnull((select SUM(linkSumAmount) linkSumAmount
        from (
select resultmap.*, OCM.ELE_CODE, OCM.SRC_ELE_CODE
            from (
                    SELECT fixedresult.oaccode AS O_ACCO_CODE
			, CASE fixedresult.oaccode
				WHEN 7 THEN SUM(fixedresult.amount) / 7 * 2.5
				ELSE SUM(fixedresult.amount)
			END AS linkSumAmount, fixedresult.iyperiod  AS IYPERIOD, fixedresult.deptcode
                    FROM (
			SELECT mapping.oaccode, mapping.SDEPRASSETNUM, mapping.deptcode
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
					                                                                                                                                                SELECT '20071001728' AS SDEPRASSETNUM, 7 AS oaccode, '101' as deptcode
                            UNION ALL
                                SELECT '20071001729' AS SDEPRASSETNUM, 7 AS oaccode, '101' as deptcode
                            UNION ALL
                                SELECT '20080906827' AS SDEPRASSETNUM, 7 AS oaccode, '101' as deptcode
                            UNION ALL
                                SELECT '201008071266' AS SDEPRASSETNUM, 8 AS oaccode, '101' as deptcode
                            UNION ALL
                                SELECT '201412034966' AS SDEPRASSETNUM, 8 AS oaccode, '304' as deptcode
                            UNION ALL
                                SELECT '201512065347' AS SDEPRASSETNUM, 8 AS oaccode, '304' as deptcode
				) mapping
                        WHERE fixed.IYEAR = LEFT(@max_iyperiod, 4)
                            AND fixed.SDEPRASSETNUM = mapping.SDEPRASSETNUM
                            AND mouth.mouth = RIGHT(@max_iyperiod, 2)
		) fixedresult
                    GROUP BY fixedresult.iyperiod, fixedresult.oaccode,fixedresult.deptcode
                UNION ALL
                    SELECT linkOAMap.O_ACCO_CODE
			, SUM(linkFactAc.MD) linkSumAmount, linkFactAc.IYPERIOD, linkGetMap.CDEPT_ID deptcode
                    FROM ODM.FCT_ACCASS linkFactAc, ODM.COST_OACCO_ACCO_MAP linkOAMap, ODM.COST_OACCO_DEPART_GET_MAP linkGetMap
                    WHERE linkFactAc.CCODE = linkOAMap.CCODE
                        AND linkOAMap.O_ACCO_CODE = linkGetMap.O_ACCO_CODE
                        AND linkFactAc.CDEPT_ID = linkGetMap.CDEPT_ID
                        AND IYPERIOD = @max_iyperiod
                        AND LEFT(IYPERIOD, 4) = LEFT(@max_iyperiod, 4)
                        AND linkOAMap.O_ACCO_CODE NOT IN ('7', '8')
                    GROUP BY linkOAMap.O_ACCO_CODE, linkFactAc.IYPERIOD,linkGetMap.CDEPT_ID) resultmap,
                ESREPORT.ODM.COST_OACCO_COELE_MAP OCM
            where OCM.O_ACCO_CODE=resultmap.O_ACCO_CODE
		 )result
        where result.deptcode=a.CDEPT_ID and result.SRC_ELE_CODE=a.CT_CODE
        group by result.deptcode,result.SRC_ELE_CODE),0)  --原金额-取数金额
						)
	               else a.CUR_AMOUNT end AS CURRENT_AMOUNT, a.IYPERIOD, ISNULL(b.CUR_AMOUNT,0) pub_amount
    FROM esreport.ODM.COST_CT_ANALYSIS a left join esreport.ODM.COST_PUB_EXPENSE b on a.CT_CODE = b.COST_ELE_CODE and a.CDEPT_ID = b.DEPT_ID and a.IYPERIOD = b.IYPERIOD
    WHERE a.IYPERIOD = @max_iyperiod and a.CT_CODE NOT IN (SELECT PARENT_CT_CODE
        FROM esreport.ODM.COST_ELEMENTS_INNER_MAPPING)

UNION ALL
    --取得分摊项表存在，但是成本分析表中不存在的数据
    select a.COST_ELE_CODE, a.DEPT_ID, 0 CURRENT_AMOUNT, a.IYPERIOD, ISNULL(a.CUR_AMOUNT,0) pub_amount
    --, b.CUR_AMOUNT or_amount, b.SUM_AMOUNT or_sumaount
    from esreport.ODM.COST_PUB_EXPENSE a
    where a.COST_ELE_CODE NOT IN (SELECT b.CT_CODE
        FROM esreport.ODM.COST_CT_ANALYSIS b
        WHERE a.DEPT_ID=b.CDEPT_ID and a.COST_ELE_CODE=b.CT_CODE and a.IYPERIOD=b.IYPERIOD)
        and a.IYPERIOD=@max_iyperiod
 
		 --打开游标，
         OPEN full_consting_cursor
         FETCH NEXT FROM full_consting_cursor INTO @ele_code,@dept_id, @cur_amount, @iyperiod, @pub_amount
         --判断是否存在下一条记录
         WHILE @@FETCH_STATUS = 0
             BEGIN
    IF(@pub_amount IS NULL)
				     BEGIN
        SET @pub_amount = 0
    END
    INSERT INTO ODM.COST_DEPT_FULL_COSTING
        (CT_CODE,CDEPT_ID,CUR_AMOUNT,IYPERIOD)
    VALUES
        (@ele_code,
            @dept_id,
            @cur_amount + @pub_amount,
            @iyperiod)
    --读取一条数据
    FETCH NEXT FROM full_consting_cursor INTO @ele_code,@dept_id, @cur_amount,@iyperiod,@pub_amount
END

			 --释放游标
            CLOSE full_consting_cursor
            DEALLOCATE full_consting_cursor

			--进行成本元素组内合并项目
			INSERT INTO ODM.COST_DEPT_FULL_COSTING
    (CT_CODE,CDEPT_ID,CUR_AMOUNT,IYPERIOD)
select b.PARENT_CT_CODE, a.CDEPT_ID, SUM(a.CUR_AMOUNT), a.IYPERIOD
from ODM.COST_DEPT_FULL_COSTING a, ODM.COST_ELEMENTS_INNER_MAPPING b
where a.CT_CODE = b.SUB_CT_CODE and a.IYPERIOD=@max_iyperiod
GROUP BY b.PARENT_CT_CODE, a.CDEPT_ID,a.IYPERIOD 


		--更新部门全成本1各项的累计值
		set @pub_expenKey = 0
        SET @ele_code = NULL
		SET @dept_id = NULL
		SET @cur_amount = 0
		SET @iyperiod = 0

		DECLARE upd_full_costing_cursor CURSOR FOR 
		   SELECT ID, CT_CODE, CDEPT_ID, CUR_AMOUNT, IYPERIOD
FROM ODM.COST_DEPT_FULL_COSTING
WHERE IYPERIOD=@max_iyperiod

		 --打开游标，
         OPEN upd_full_costing_cursor
         FETCH NEXT FROM upd_full_costing_cursor INTO @pub_expenKey,@ele_code, @dept_id, @cur_amount,@iyperiod
         --判断是否存在下一条记录
         WHILE @@FETCH_STATUS = 0
             BEGIN
    UPDATE ODM.COST_DEPT_FULL_COSTING
				 SET SUM_AMOUNT=(  SELECT SUM(CUR_AMOUNT)
    FROM ODM.COST_DEPT_FULL_COSTING
    WHERE  CT_CODE=@ele_code and CDEPT_ID=@dept_id
        and IYPERIOD<= @iyperiod and LEFT(IYPERIOD,4)=left(@iyperiod,4)
    GROUP BY CT_CODE,CDEPT_ID
								   )
				 WHERE ID=@pub_expenKey
    --读取一条数据
    FETCH NEXT FROM upd_full_costing_cursor INTO @pub_expenKey,@ele_code, @dept_id, @cur_amount,@iyperiod
END
			 --释放游标
            CLOSE upd_full_costing_cursor
            DEALLOCATE upd_full_costing_cursor
       
--进行职能部门向业务部门的分摊
		SET @dept_id = NULL
		SET @ele_code= NULL
		SET @cur_amount = 0
		SET @iyperiod= 0
		SET @sum_amount=0
		--计算业务部门成本占比，因为对于所有成本元素来说，成本占比不变,所以先放入历史表中
		SELECT fullcost.CDEPT_ID, case when cast(s.CUR_AMOUNT as decimal(20,10))=0 then 0 else  cast(SUM(fullcost.CUR_AMOUNT) as decimal(20,10))/cast(s.CUR_AMOUNT as decimal(20,10)) end percentage
INTO #busDeptPercen
FROM ODM.[COST_DEPT_FULL_COSTING] as fullcost,
    --非职能部门成本总和
    ( select SUM(in_tmpB.CUR_AMOUNT) CUR_AMOUNT, in_tmpB.IYPERIOD
    from [ESREPORT].ODM.[COST_DEPT_FULL_COSTING] in_tmpB
    where in_tmpB.CDEPT_ID NOT IN ('101','102','103','104','105', '106','8') and in_tmpB.CDEPT_ID not like '7%' --6个职能部门，公司公用和项目不计入业务部门
        and in_tmpB.CT_CODE in  ('1','12','13','14','18','26','27','28','29','30','31','40','41','47','48','49','50','51','52')
    group by in_tmpB.IYPERIOD
              ) s
WHERE  fullcost.IYPERIOD = s.IYPERIOD
    AND fullcost.CDEPT_ID NOT IN ('101','102','103','104','105', '106','8')
    AND fullcost.CDEPT_ID not like '7%'
    AND fullcost.CT_CODE in ('1','12','13','14','18','26','27','28','29','30','31','40','41','47','48','49','50','51','52')
    AND fullcost.IYPERIOD = @max_iyperiod
GROUP BY fullcost.CDEPT_ID, fullcost.IYPERIOD, s.CUR_AMOUNT
ORDER BY fullcost.CDEPT_ID

		 DECLARE func_dept_sumCost_cusor CURSOR FOR
		    SELECT CT_CODE, SUM(CUR_AMOUNT) CUR_AMOUNT
FROM [ESREPORT].ODM.[COST_DEPT_FULL_COSTING]
WHERE CDEPT_ID in ('101','102','103','104','105', '106') AND IYPERIOD=@max_iyperiod
GROUP BY CT_CODE, IYPERIOD

 		 --打开游标，
         OPEN func_dept_sumCost_cusor
           FETCH NEXT FROM func_dept_sumCost_cusor INTO @ele_code, @cur_amount
           --判断是否存在下一条记录
           WHILE @@FETCH_STATUS = 0
               BEGIN
    SET @total_tmp = 0
    SET @tailCountingAmount = 0
    SET @tailTotalAmount = 0
    SET @rate = 0
    --计算业务部门各部门占比
    DECLARE bus_dept_cost_percne_cusor CURSOR FOR
				       SELECT a.CDEPT_ID, a.percentage
    FROM #busDeptPercen a

    --打开游标，循环处理业务部门占比
    OPEN bus_dept_cost_percne_cusor
    FETCH NEXT FROM bus_dept_cost_percne_cusor INTO @dept_id, @rate
    WHILE @@FETCH_STATUS = 0
			             BEGIN
        --2017-09-15 update 由于未查看select语句的exist情况,故为使@sum_amount不取到上次查询结果,在循环开始赋初值
        --set @sum_amount=0
        --进行尾差处理(处理占比除不尽的情况)
        IF (1- @total_tmp <= @rate)
			                     BEGIN
            SET @tailCountingAmount = (@cur_amount-@tailTotalAmount)
        END
						     ELSE 
						         BEGIN
            SET @tailCountingAmount=round(@cur_amount*@rate,2)
        END

        --计算累计值
        IF (RIGHT(@max_iyperiod,2) = '01')
							      BEGIN
            SET @sum_amount=0
        END
							  ELSE 
							      BEGIN
            set @sum_amount=0
            SELECT @sum_amount=ISNULl(SUM_AMOUNT,0)
            FROM ODM.COST_FUNC_DEPT_FULL_COSTING
            WHERE CDEPT_ID=@dept_id and CT_CODE=@ele_code and IYPERIOD=@max_iyperiod-1
        END

        --将每个业务部门计算出来的职能部门分摊金额插入COST_FUNC_DEPT_FULL_COSTING 表中
        INSERT INTO ODM.COST_FUNC_DEPT_FULL_COSTING
            (CT_CODE,CDEPT_ID,CUR_AMOUNT,SUM_AMOUNT,IYPERIOD)
        VALUES
            (@ele_code,
                @dept_id,
                @tailCountingAmount,
                (@sum_amount+@tailCountingAmount),
                @max_iyperiod)

        SET @tailTotalAmount = @tailTotalAmount + @tailCountingAmount
        SET @total_tmp =  @total_tmp + @rate
        FETCH NEXT FROM bus_dept_cost_percne_cusor INTO @dept_id, @rate
    END
    --释放游标
    CLOSE bus_dept_cost_percne_cusor
    DEALLOCATE bus_dept_cost_percne_cusor
    --读取一条数据
    FETCH NEXT FROM func_dept_sumCost_cusor INTO @ele_code, @cur_amount
END
			   --释放游标
         CLOSE func_dept_sumCost_cusor
         DEALLOCATE func_dept_sumCost_cusor

		 --释放临时表
		 DROP TABLE #busDeptPercen
          
	     --插入职能部门成本总计数据
	     INSERT INTO ODM.COST_FUNC_DEPT_FULL_COSTING
    (CT_CODE,CDEPT_ID,CUR_AMOUNT,SUM_AMOUNT,IYPERIOD)
select CT_CODE, '1' CDEPT_ID, SUM(CUR_AMOUNT) CUR_AMOUNT, SUM(SUM_AMOUNT) SUM_AMOUNT, IYPERIOD
from [ESREPORT].ODM.[COST_DEPT_FULL_COSTING]
where CDEPT_ID in ('101','102','103','104','105', '106') and IYPERIOD=@max_iyperiod
group by CT_CODE, IYPERIOD


--导入产品全成本使用的成本要素金额
   
    INSERT INTO ODM.COST_COST_DETAILS
    (DIST_CODE,CDEPT_ID,IYPERIOD,discurrentamount,discostvalue)
SELECT code, CDEPT_ID, IYPERIOD, cur_amount, total_amount
FROM ODM.COM_COST_ELE_DETAILS
WHERE IYPERIOD=@max_iyperiod and LEN(code) = 10 --只需要导入二级目录即可