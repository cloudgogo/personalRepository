SELECT *
  FROM (SELECT --T.COM, 
         T.ATTRIBUTE,
         T.PERIOD_NAME,
         T.VALUE,
         T.TYPE,
         case type
           when '�ܲ�' then
            1
           when 'Ӫҵ��' then
            2
           when '�ϼ�' then
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
                         WHEN '��Ա����' THEN
                          1
                         WHEN '�ɿط���' THEN
                          2
                         WHEN '���Է���' THEN
                          3
                         WHEN '̯������' THEN
                          4
                         WHEN '��������' THEN
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
                                  '�ܲ�'
                                 when FBB.FIN_IS_BS = 'Y' THEN
                                  'Ӫҵ��'
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
                               '�ϼ�' type
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
                   AND IR.PERIOD_NAME in ('2016-10', '2015-10', '2014-10') --�����ڼ�
                   AND R.ATTRIBUTE1 <> '��������'
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
