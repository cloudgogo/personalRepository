--主程序1
SELECT --T_HANG.ROW_ID,
       T_HANG.ROW_NAME,
       T_HANG.ROW_NUM,
       --  T_HANG.ATTRIBUTE1,
       ALL_T.COM1,
       SUM(ALL_T.B02)/100000000 B02,
       SUM(ALL_T.B02_BF)/100000000 B02_BF,
       SUM(ALL_T.A12)/100000000 A12,
       SUM(ALL_T.A02)/100000000 A02,
       --DECODE( SUM(ALL_T.A02), 0, 0, (SUM(ALL_T.A12) -  SUM(ALL_T.A02)) / SUM(ALL_T.A02)) R02,
       SUM(ALL_T.A11)/100000000 A11,
       SUM(ALL_T.A01)/100000000 A01,
       (SUM(ALL_T.A11) -  SUM(ALL_T.A01))/100000000 A11_A01,
       DECODE( SUM(ALL_T.A01), 0, 0, (SUM(ALL_T.A11) -  SUM(ALL_T.A01)) / SUM(ALL_T.A01)) R01
       --SUM(ALL_T.AB01) AB01,
      -- SUM(ALL_T.AB02) AB02

/*     DECODE(T_HANG.CHANGE_SIGN, 'Y', -1, 1) * ALL_T.A03 A03,
       DECODE(T_HANG.CHANGE_SIGN, 'Y', -1, 1) * ALL_T.A04 A04,
       DECODE(T_HANG.CHANGE_SIGN, 'Y', -1, 1) * ALL_T.B01 B01,
       DECODE(T_HANG.CHANGE_SIGN, 'Y', -1, 1) * ALL_T.V01 V01,
       DECODE(T_HANG.CHANGE_SIGN, 'Y', -1, 1) * ALL_T.R01 R01,
       DECODE(T_HANG.CHANGE_SIGN, 'Y', -1, 1) * ALL_T.R11 R11*/
  FROM (SELECT T.LEDGER_ID,
               T.ROW_NAME,
               T.ROW_NUM,
               T.ROW_ID,
               T_LIE.COM1,
               SUM(A01) A01,
               SUM(A02) A02,
               
               SUM(A11) A11,
               SUM(A12) A12,
              -- DECODE(SUM(A01), 0, 0, (SUM(A11) - SUM(A01)) / SUM(A01)) R01,
              -- DECODE(SUM(A02), 0, 0, (SUM(A12) - SUM(A02)) / SUM(A02)) R02,
               
              -- DECODE(SUM(B02), 0, 0, (SUM(A11) / SUM(B02))) AB01,
              -- DECODE(SUM(B02_BF), 0, 0, (SUM(A01) / SUM(B02_BF))) AB02,
               SUM(B02_BF) B02_BF,
               SUM(B02) B02
        
          FROM (SELECT IR.LEDGER_ID,
                       R.ROW_NAME,
                       R.ROW_NUM,
                       R.ROW_ID,
                       IR.PERIOD_NAME,
                       IR.SEGMENT1 SEGMENT1,
                       -- IR.SEGMENT2,
                       -- - IR.SEGMENT8,
                       DECODE(R.CHANGE_SIGN, 'Y', -1, 1) *
                       SUM(CASE
                             WHEN IR.AMOUNT_TYPE = 'A01'
                                  AND IR.PERIOD_NAME = '${periodName}' THEN
                              NVL(IR.AMOUNT1, 0)
                             ELSE
                              0
                           END) A01, --上年同期累计
                       
                       DECODE(R.CHANGE_SIGN, 'Y', -1, 1) *
                       SUM(CASE
                             WHEN IR.AMOUNT_TYPE = 'A12'
                                  AND IR.PERIOD_NAME =
                                  TO_CHAR(TO_NUMBER(SUBSTR('${periodName}', 0, 4)) - 1) ||
                                  SUBSTR('${periodName}', 5) THEN
                              NVL(IR.AMOUNT1, 0)
                             ELSE
                              0
                           END) A02, --上年同期  
                       
                       DECODE(R.CHANGE_SIGN, 'Y', -1, 1) *
                       SUM(CASE
                             WHEN IR.AMOUNT_TYPE = 'A11'
                                  AND IR.PERIOD_NAME = '${periodName}' THEN
                              NVL(IR.AMOUNT1, 0)
                             ELSE
                              0
                           END) A11, --本年累计
                       DECODE(R.CHANGE_SIGN, 'Y', -1, 1) *
                       SUM(CASE
                             WHEN IR.AMOUNT_TYPE = 'B02'
                                  AND
                                  IR.PERIOD_YEAR =
                                  TO_CHAR(TO_NUMBER(SUBSTR('${periodName}', 0, 4)) - 1) THEN
                              NVL(IR.AMOUNT1, 0)
                             ELSE
                              0
                           END) B02_BF, --QUNIAN预算
                       SUM(CASE
                             WHEN IR.AMOUNT_TYPE = 'B02'
                                  AND IR.PERIOD_YEAR = SUBSTR('${periodName}', 0, 4) THEN
                              NVL(IR.AMOUNT1, 0)
                             ELSE
                              0
                           END) B02, --预算
                       DECODE(R.CHANGE_SIGN, 'Y', -1, 1) *
                       SUM(CASE
                             WHEN IR.AMOUNT_TYPE = 'A12'
                                  AND IR.PERIOD_NAME = '${periodName}' THEN
                              NVL(IR.AMOUNT1, 0)
                           
                             ELSE
                              0
                           END) A12 --本期实际  
                
                  FROM HRS_DEF_ROW_SET RS,
                       HRS_DEF_ROW     R,
                       
                       HFM_CORE_ITEM_RESULT IR
                
                 WHERE RS.ROW_SET_NAME = 'MBS102V1'
                   AND RS.ROW_SET_ID = R.ROW_SET_ID
                   AND IR.ITEM_CODE = R.EXTERNAL_CODE
                      
                   AND IR.PERIOD_NAME IN
                       ('${periodName}', SUBSTR('${periodName}', 0, 4),
                        TO_CHAR(TO_NUMBER(SUBSTR('${periodName}', 0, 4)) - 1),
                        TO_CHAR(TO_NUMBER(SUBSTR('${periodName}', 0, 4)) - 1) ||
                        SUBSTR('${periodName}', 5))
                   AND IR.AMOUNT_TYPE IN ('A01', 'A11', 'A12', 'B02')
                
                 GROUP BY IR.LEDGER_ID,
                          R.ROW_NAME,
                          R.ROW_NUM,
                          R.ROW_ID,
                          IR.PERIOD_NAME,
                          IR.SEGMENT1,
                          R.CHANGE_SIGN) T,
               
               (SELECT H.DIM_VALUE COM1,
                       H.CHILD_DIM_VALUE_LOW,
                       H.CHILD_DIM_VALUE_HIGH
                
                  FROM HRS_CORE_DIMENSION           D,
                       HRS_CORE_DIM_VALUE_HIERARCHY H,
                       HRS_DEF_RELATIONSHIP_SET     RS,
                       HRS_DEF_RELATIONSHIP         R
                
                 WHERE 1 = 1
                   AND D.DIM_SEGMENT = 'SEGMENT1'
                   AND H.DIMENSION_ID = D.DIMENSION_ID
                   AND RS.RELATIONSHIP_SET_NAME = 'ORG_HFM_102'
                   AND RS.RELATIONSHIP_SET_ID = R.RELATIONSHIP_SET_ID
                   AND R.COMPANY_CODE = H.DIM_VALUE
                      
                   AND H.DIM_VALUE IN ('104')
                       --IN ('136T', '1376T', '140T', '131S', '137S', '138T')
                UNION ALL
                SELECT V.DIM_VALUE COM1,
                       V.DIM_VALUE CHILD_DIM_VALUE_LOW,
                       V.DIM_VALUE CHILD_DIM_VALUE_HIGH
                  FROM HRS_CORE_DIMENSION       D,
                       HRS_CORE_DIMENSION_VALUE V,
                       HRS_DEF_RELATIONSHIP_SET RS,
                       HRS_DEF_RELATIONSHIP     R
                 WHERE 1 = 1
                   AND D.DIM_SEGMENT = 'SEGMENT1'
                   AND D.DIMENSION_ID = V.DIMENSION_ID
                   AND V.SUMMARY_FLAG = 'N'
                   AND RS.RELATIONSHIP_SET_NAME = 'ORG_HFM_102'
                   AND RS.RELATIONSHIP_SET_ID = R.RELATIONSHIP_SET_ID
                   AND R.COMPANY_CODE = V.DIM_VALUE
                   AND V.DIM_VALUE IN ('104')) T_LIE
        
         WHERE 1 = 1
           AND T.SEGMENT1 BETWEEN T_LIE.CHILD_DIM_VALUE_LOW AND
               T_LIE.CHILD_DIM_VALUE_HIGH
         GROUP BY T.LEDGER_ID, T.ROW_NAME, T.ROW_NUM, T.ROW_ID, T_LIE.COM1) ALL_T,
       
       (SELECT R.*
          FROM HRS_DEF_ROW_SET S, HRS_DEF_ROW R
         WHERE S.ROW_SET_ID = R.ROW_SET_ID
           AND S.ROW_SET_NAME = 'MBS102V1') T_HANG

 WHERE 1 = 1
   AND ALL_T.ROW_ID(+) = T_HANG.ROW_ID
   AND T_HANG.ROW_NAME='自有资产'
 GROUP BY T_HANG.ROW_NUM, T_HANG.ROW_NAME, ALL_T.COM1--, T_HANG.ROW_ID
 ORDER BY T_HANG.ROW_NUM, ALL_T.COM1
