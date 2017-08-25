SELECT *
  FROM (SELECT --T.COM, 
         T.ATTRIBUTE,
         T.PERIOD_NAME,
         T.VALUE,
         T.TYPE,
         case type
           when '总部' then
            1
           when '营业部' then
            2
           when '合计' then
            3
         end typeorder
          FROM (SELECT DECODE(R.CHANGE_SIGN, 'Y', -1, 1) *
                       DECODE(C.SIGN, '+', 1, -1) *
                       (SUM(IR.END_BALANCE_DR) - SUM(IR.END_BALANCE_CR)) /
                       10000 VALUE,
                       R.ATTRIBUTE1 ATTRIBUTE,
                       IR.PERIOD_NAME,
                       --COM.FIN_BRAN_COM_SHORT COM,
                       CASE R.ATTRIBUTE1
                         WHEN '人员费用' THEN
                          1
                         WHEN '可控费用' THEN
                          2
                         WHEN '刚性费用' THEN
                          3
                         WHEN '摊销费用' THEN
                          4
                         WHEN '其他费用' THEN
                          5
                       END ATTRIBUTEORDER,
                       COM.type
                  FROM HRS_CORE_ITEM_RESULT IR,
                       HRS_DEF_ROW_SET S,
                       HRS_DEF_ROW R,
                       HRS_DEF_ROW_CALCULATION C,
                       (SELECT FBB.FIN_BRAN_COM_SHORT,
                               DCV.dim_value FIN_EBS_CODE,
                               CASE
                                 WHEN FBB.FIN_IS_HEARQUAR = 'Y' THEN
                                  '总部'
                                 when FBB.FIN_IS_BS = 'Y' THEN
                                  '营业部'
                               end type
                          FROM HRS_CORE_DIM_CHILD_VALUE_V DCV,
                               HRS_CORE_DIMENSION         D,
                               FIN_FINANCE_BS_BRAN        FBB
                         WHERE D.DIM_SEGMENT = 'SEGMENT1'
                           AND D.DIM_SEGMENT = DCV.DIM_SEGMENT
                           AND FBB.FIN_EBS_CODE = DCV.PARENT_VALUE
                           AND (FBB.FIN_IS_HEARQUAR = 'Y' or
                               FBB.FIN_IS_BS = 'Y')
                        union all
                        SELECT FBB.FIN_BRAN_COM_SHORT,
                               DCV.dim_value FIN_EBS_CODE,
                               '合计' type
                          FROM HRS_CORE_DIM_CHILD_VALUE_V DCV,
                               HRS_CORE_DIMENSION         D,
                               FIN_FINANCE_BS_BRAN        FBB
                         WHERE D.DIM_SEGMENT = 'SEGMENT1'
                           AND D.DIM_SEGMENT = DCV.DIM_SEGMENT
                           AND FBB.FIN_EBS_CODE = DCV.PARENT_VALUE
                           AND (FBB.FIN_IS_HEARQUAR = 'Y' or
                               FBB.FIN_IS_BS = 'Y')
                        
                        ) COM
                 WHERE S.ROW_SET_ID = R.ROW_SET_ID
                   AND S.ROW_SET_NAME = 'E100ZQV1'
                   AND C.ROW_ID = R.ROW_ID
                   AND IR.ITEM_CODE = C.CAL_ITEM_CODE
                   AND IR.CURRENCY_CODE = 'CNY'
                   AND IR.PERIOD_NAME in ('2016-10', '2015-10', '2014-10') --参数期间
                   AND R.ATTRIBUTE1 <> '其他费用'
                   AND IR.SEGMENT1 = COM.FIN_EBS_CODE
                 GROUP BY C.SIGN,
                          R.CHANGE_SIGN,
                          R.ATTRIBUTE1,
                          --COM.FIN_BRAN_COM_SHORT,
                          COM.TYPE,
                          IR.PERIOD_NAME) T
        --ORDER BY T. T.ATTRIBUTEORDER --,T.VALUE
        ) T
 ORDER BY T.TYPEORDER, T.ATTRIBUTE
