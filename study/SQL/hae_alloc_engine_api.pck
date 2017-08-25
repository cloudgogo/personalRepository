CREATE OR REPLACE PACKAGE hae_alloc_engine_api IS

  FUNCTION get_alloc_source_amount(p_amount_type    VARCHAR2,
                                   p_direction_code VARCHAR2,
                                   p_operator       VARCHAR2,
                                   p_period_dr      NUMBER,
                                   p_period_cr      NUMBER,
                                   p_end_dr         NUMBER,
                                   p_end_cr         NUMBER) RETURN NUMBER;

  --运行分摊
  FUNCTION RUN_ALLOC(P_HISTORY_ID NUMBER) RETURN VARCHAR2;

  --回滚分摊
  FUNCTION ROLLBACK_ALLOC(P_HISTORY_ID NUMBER) RETURN VARCHAR2;

END hae_alloc_engine_api;
/
CREATE OR REPLACE PACKAGE BODY hae_alloc_engine_api IS

  c_proportion_format       CONSTANT NUMBER := 2;
  C_TXN_HEADER_TYPE         CONSTANT VARCHAR2(10) := 'C'; --事务处理类型：HAE_TXN_PROCESS_HEADER.TYPE_CODE
  C_TXN_HEADER_DES          CONSTANT VARCHAR2(100) := '分摊生成';
  C_TXN_LINE_DES            CONSTANT VARCHAR2(100) := '分摊生成';
  C_LOG_STATE_WARNING1      CONSTANT VARCHAR2(50) := 'W101';
  C_LOG_MSG_WARNING1        CONSTANT VARCHAR2(200) := '警告:分摊源为空';
  C_LOG_STATE_WARNING2      CONSTANT VARCHAR2(50) := 'W102';
  C_LOG_MSG_WARNING2        CONSTANT VARCHAR2(200) := '警告:分摊因子为空，无法分摊';
  C_LOG_STATE_WARNING3      CONSTANT VARCHAR2(50) := 'W103';
  C_LOG_MSG_WARNING3        CONSTANT VARCHAR2(200) := '警告:分摊结果合计不为0';
  C_LOG_STATE_WARNING4      CONSTANT VARCHAR2(50) := 'W104';
  C_LOG_MSG_WARNING4        CONSTANT VARCHAR2(200) := '警告:存在分摊因子为空的分摊源，无法分摊';
  C_LOG_STATE_WARNING5      CONSTANT VARCHAR2(50) := 'W105';
  C_LOG_MSG_WARNING5        CONSTANT VARCHAR2(200) := '警告:期间未打开';
  C_LOG_STATE_ERROR         CONSTANT VARCHAR2(50) := 'E101';
  C_LOG_MSG_ERROR           CONSTANT VARCHAR2(200) := '分摊处理异常';
  C_LOG_STATE_SUCCESS       CONSTANT VARCHAR2(50) := 'S101';
  C_LOG_MSG_SUCCESS         CONSTANT VARCHAR2(200) := '分摊处理成功';
  C_LOG_STATE_ROLLBACK      CONSTANT VARCHAR2(50) := 'R101';
  C_LOG_MSG_ROLLBACK        CONSTANT VARCHAR2(200) := '分摊已回滚';
  C_LOG_STATE_ROLLBACKERROR CONSTANT VARCHAR2(50) := 'R102';
  C_LOG_MSG_ROLLBACKERROR   CONSTANT VARCHAR2(200) := '分摊回滚失败';
  G_LOG_DETAIL_MSG CLOB; --程序执行过程中的所有日志信息
  G_LOG_STATE      VARCHAR2(50);

  --
  -- Procedure
  --   get_alloc_source_amount
  -- Purpose
  --   Based on the definiation of the allocation rules, 
  --   including amount type and direciton to determin the calculation method of the source amount
  -- History
  --   13-02-2017   Bob Li   Created
  -- Arguments
  --   p_amount_type    
  --   p_direction_code 
  --   p_operator       
  --   p_period_dr      
  --   p_period_cr      
  --   p_end_dr         
  --   p_end_cr         
  -- Returns
  --   
  -- Notes
  --
  FUNCTION get_alloc_source_amount(p_amount_type    VARCHAR2,
                                   p_direction_code VARCHAR2,
                                   p_operator       VARCHAR2,
                                   p_period_dr      NUMBER,
                                   p_period_cr      NUMBER,
                                   p_end_dr         NUMBER,
                                   p_end_cr         NUMBER) RETURN NUMBER IS
    l_amount NUMBER;
    l_sign   NUMBER;
  BEGIN
    IF p_operator = '-' THEN
      l_sign := -1;
    ELSE
      l_sign := 1;
    END IF;
  
    --根据余额类型，符号，方向获取需要分摊的金额
    IF p_amount_type = 'PTD' THEN
      IF p_direction_code = 'DR' THEN
        l_amount := l_sign * p_period_dr;
      ELSIF p_direction_code = 'CR' THEN
        l_amount := l_sign * p_period_cr;
      ELSIF p_direction_code = 'NET' THEN
        l_amount := l_sign * (p_period_dr - p_period_cr);
      END IF;
    ELSIF p_amount_type = 'YTD' THEN
      IF p_direction_code = 'DR' THEN
        l_amount := l_sign * p_end_dr;
      ELSIF p_direction_code = 'CR' THEN
        l_amount := l_sign * p_end_cr;
      ELSIF p_direction_code = 'NET' THEN
        l_amount := l_sign * (p_end_dr - p_end_cr);
      END IF;
    END IF;
  
    RETURN l_amount;
  
  END;

  --分摊运行结束，更新日志表的字段：状态STATE、描述MSG、完成时间END_DATE、日志详情DETAIL_MSG
  PROCEDURE update_log(P_INSTANCE_ID IN NUMBER,
                       P_HISTORY_ID  IN NUMBER,
                       p_rule_id     IN NUMBER,
                       p_period_name IN VARCHAR2,
                       P_STATE       IN VARCHAR2) IS
    L_LOG_MSG VARCHAR2(200);
  BEGIN
    IF P_STATE = 'W101' THEN
      L_LOG_MSG := C_LOG_MSG_WARNING1;
    ELSIF P_STATE = 'W102' THEN
      L_LOG_MSG := C_LOG_MSG_WARNING2;
    ELSIF P_STATE = 'W103' THEN
      L_LOG_MSG := C_LOG_MSG_WARNING3;
    ELSIF P_STATE = 'W104' THEN
      L_LOG_MSG := C_LOG_MSG_WARNING4;
    ELSIF P_STATE = 'E101' THEN
      L_LOG_MSG := C_LOG_MSG_ERROR;
    ELSIF P_STATE = 'S101' THEN
      L_LOG_MSG := C_LOG_MSG_SUCCESS;
    END IF;
  
    UPDATE HAE_ALLOC_LOG
       SET STATE      = P_STATE,
           MSG        = L_LOG_MSG,
           END_DATE   = SYSDATE,
           DETAIL_MSG = G_LOG_DETAIL_MSG
     WHERE ALLOC_INSTANCE_ID = P_INSTANCE_ID
       AND ALLOC_HISTORY_ID = P_HISTORY_ID
       AND RULE_ID = P_RULE_ID
       AND PERIOD_NAME = P_PERIOD_NAME;
  END;

  --回滚运行结束，更新日志表的字段：状态STATE、描述MSG、（追加）日志详情DETAIL_MSG
  PROCEDURE update_rollback_log(P_INSTANCE_ID IN NUMBER,
                                P_HISTORY_ID  IN NUMBER,
                                p_rule_id     IN NUMBER,
                                p_period_name IN VARCHAR2,
                                P_STATE       IN VARCHAR2) IS
    L_LOG_MSG VARCHAR2(200);
  BEGIN
    IF P_STATE = 'R101' THEN
      L_LOG_MSG := C_LOG_MSG_ROLLBACK;
    ELSIF P_STATE = 'R102' THEN
      L_LOG_MSG := C_LOG_MSG_ROLLBACKERROR;
    END IF;
    UPDATE HAE_ALLOC_LOG
       SET STATE      = P_STATE,
           MSG        = L_LOG_MSG,
           DETAIL_MSG = DETAIL_MSG || chr(10) || G_LOG_DETAIL_MSG
     WHERE ALLOC_INSTANCE_ID = P_INSTANCE_ID
       AND ALLOC_HISTORY_ID = P_HISTORY_ID
       AND RULE_ID = P_RULE_ID
       AND PERIOD_NAME = P_PERIOD_NAME;
  END;

  --
  -- Procedure
  --   process_alloc_source
  -- Purpose
  --   Based on the definiation of the allocation rules, 
  --   including amount type and direciton to determin the calculation method of the source amount
  -- History
  --   13-02-2017   Bob Li   Created
  -- Arguments
  --   p_rule_id                 allocation rule id
  --   p_source_id               allocation source id
  -- Returns
  --   
  -- Notes
  --
  PROCEDURE process_alloc_source(p_rule_id       IN NUMBER,
                                 p_period_name   IN VARCHAR2,
                                 P_PERIOD_YEAR   IN NUMBER,
                                 P_PERIOD_NUM    IN NUMBER,
                                 P_INSTANCE_ID   IN NUMBER,
                                 P_HISTORY_ID    IN NUMBER,
                                 P_CONTINUE_FLAG OUT BOOLEAN) IS
  
    L_SOURCE_ID      NUMBER;
    L_SOURCE_TYPE    VARCHAR2(150);
    L_CONSTANT       NUMBER;
    L_ACTUAL_FLAG    VARCHAR2(30);
    L_CURRENCY_TYPE  VARCHAR2(30);
    L_CURRENCY_CODE  VARCHAR2(30);
    L_AMOUNT_TYPE    VARCHAR2(30);
    L_DIRECTION_CODE VARCHAR2(30);
    L_OPERATOR       VARCHAR2(1);
    L_INSERT_SQL     VARCHAR2(4000);
    L_SOURCE_TOTAL   NUMBER;
  
  BEGIN
    G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                        'S.0  START TO PROCESS SOURCE';
    P_CONTINUE_FLAG  := TRUE;
    BEGIN
      SELECT SOURCE_ID,
             SOURCE_TYPE,
             CONSTANT,
             ACTUAL_FLAG,
             CURRENCY_TYPE,
             CURRENCY_CODE,
             AMOUNT_TYPE,
             DIRECTION_CODE,
             OPERATOR
        INTO L_SOURCE_ID,
             L_SOURCE_TYPE,
             L_CONSTANT,
             L_ACTUAL_FLAG,
             L_CURRENCY_TYPE,
             L_CURRENCY_CODE,
             L_AMOUNT_TYPE,
             L_DIRECTION_CODE,
             L_OPERATOR
        FROM HAE_ALLOC_SOURCE
       WHERE RULE_ID = p_rule_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_CONTINUE_FLAG  := FALSE;
        G_LOG_STATE      := C_LOG_STATE_ERROR;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'S.1.1  NO_DATA_FOUND WHEN HAE_ALLOC_SOURCE SELECT INTO';
        RETURN;
      WHEN OTHERS THEN
        L_SOURCE_ID      := NULL;
        L_SOURCE_TYPE    := NULL;
        L_CONSTANT       := NULL;
        L_ACTUAL_FLAG    := NULL;
        L_CURRENCY_TYPE  := NULL;
        L_CURRENCY_CODE  := NULL;
        L_AMOUNT_TYPE    := NULL;
        L_DIRECTION_CODE := NULL;
        L_OPERATOR       := NULL;
      
        P_CONTINUE_FLAG  := FALSE;
        G_LOG_STATE      := C_LOG_STATE_ERROR;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'S.1.2  EXCEPTION WHEN HAE_ALLOC_SOURCE SELECT INTO:' ||
                            SUBSTR(SQLERRM, 1, 100);
        RETURN;
    END;
  
    --如果分摊源为常数
    IF L_SOURCE_TYPE = 'CONSTANT' THEN
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'S.2.1  SOURCE_TYPE=CONSTANT';
      IF L_OPERATOR = '-' THEN
        L_CONSTANT := L_CONSTANT * (-1);
      END IF;
      BEGIN
        INSERT INTO HAE_ALLOC_SOURCE_DATA_TMP
          (DATA_TMP_ID,
           RULE_ID,
           SOURCE_TYPE,
           ACTUAL_FLAG,
           CURRENCY_TYPE,
           CURRENCY_CODE,
           PERIOD_NAME,
           PERIOD_YEAR,
           PERIOD_NUM,
           SOURCE_AMOUNT,
           ALLOC_INSTANCE_ID,
           ALLOC_HISTORY_ID)
          SELECT HAE_ALLOC_DATA_TMP_S.NEXTVAL,
                 p_rule_id,
                 L_SOURCE_TYPE,
                 L_ACTUAL_FLAG,
                 L_CURRENCY_TYPE,
                 L_CURRENCY_CODE,
                 P_PERIOD_NAME,
                 P_PERIOD_YEAR,
                 P_PERIOD_NUM,
                 L_CONSTANT,
                 P_INSTANCE_ID,
                 P_HISTORY_ID
            FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN
          P_CONTINUE_FLAG  := FALSE;
          G_LOG_STATE      := C_LOG_STATE_ERROR;
          G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                              'S.2.2  EXCEPTION WHEN INSERT INTO HAE_ALLOC_SOURCE_DATA_TMP:' ||
                              SUBSTR(SQLERRM, 1, 100);
          RETURN;
      END;
    
      --分摊源为ACCOUNT
    ELSIF L_SOURCE_TYPE = 'ACCOUNT' THEN
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'S.3.1  SOURCE_TYPE=ACCOUNT';
    
      L_INSERT_SQL := 'SELECT HAE_ALLOC_DATA_TMP_S.NEXTVAL,' || p_rule_id ||
                      ',''' || L_SOURCE_TYPE ||
                      ''', fin_element,ledger_id,  actual_flag, currency_type, currency_code, segment1,segment2,segment3,segment4,segment5,segment6, segment7,segment8,
          segment9, segment10, segment11, segment12, segment13,segment14,segment15, segment16,segment17, segment18,segment19, segment20,period_name, period_num,
          period_year,hae_alloc_engine_api.get_alloc_source_amount(''' ||
                      L_AMOUNT_TYPE || ''',''' || L_DIRECTION_CODE ||
                      ''', ''' || L_OPERATOR ||
                      ''', b.period_dr, b.period_cr, b.end_balance_dr,b.end_balance_cr) source_amount,' ||
                      P_INSTANCE_ID || ',' || P_HISTORY_ID || '
     FROM (SELECT T.FIN_ELEMENT,
       T.LEDGER_ID,
       T.ACTUAL_FLAG,
       T.CURRENCY_TYPE,
       T.CURRENCY_CODE,
       T.SEGMENT1,
       T.SEGMENT2,
       T.SEGMENT3,
       T.SEGMENT4,
       T.SEGMENT5,
       T.SEGMENT6,
       T.SEGMENT7,
       T.SEGMENT8,
       T.SEGMENT9,
       T.SEGMENT10,
       T.SEGMENT11,
       T.SEGMENT12,
       T.SEGMENT13,
       T.SEGMENT14,
       T.SEGMENT15,
       T.SEGMENT16,
       T.SEGMENT17,
       T.SEGMENT18,
       T.SEGMENT19,
       T.SEGMENT20,
       T.PERIOD_NAME,
       T.PERIOD_NUM,
       T.PERIOD_YEAR,
       SUM(NVL(T.BEGIN_BALANCE_DR, 0)) BEGIN_BALANCE_DR,
       SUM(NVL(T.BEGIN_BALANCE_CR, 0)) BEGIN_BALANCE_CR,
       SUM(NVL(T.PERIOD_DR, 0)) PERIOD_DR,
       SUM(NVL(T.PERIOD_CR, 0)) PERIOD_CR,
       SUM(NVL(T.BEGIN_BALANCE_DR, 0)) + SUM(NVL(T.PERIOD_DR, 0)) END_BALANCE_DR,
       SUM(NVL(T.BEGIN_BALANCE_CR, 0)) + SUM(NVL(T.PERIOD_CR, 0)) END_BALANCE_CR
  FROM HRS_CORE_BALANCE T
 WHERE T.actual_flag = ''' || L_ACTUAL_FLAG || '''
   AND T.currency_type = ''' || L_CURRENCY_TYPE || '''
   AND T.currency_code = ''' || L_CURRENCY_CODE || '''
   AND T.period_name = ''' || P_PERIOD_NAME || '''' ||
                      ' GROUP BY T.FIN_ELEMENT,
          T.LEDGER_ID,
          T.ACTUAL_FLAG,
          T.CURRENCY_TYPE,
          T.CURRENCY_CODE,
          T.SEGMENT1,
          T.SEGMENT2,
          T.SEGMENT3,
          T.SEGMENT4,
          T.SEGMENT5,
          T.SEGMENT6,
          T.SEGMENT7,
          T.SEGMENT8,
          T.SEGMENT9,
          T.SEGMENT10,
          T.SEGMENT11,
          T.SEGMENT12,
          T.SEGMENT13,
          T.SEGMENT14,
          T.SEGMENT15,
          T.SEGMENT16,
          T.SEGMENT17,
          T.SEGMENT18,
          T.SEGMENT19,
          T.SEGMENT20,
          T.PERIOD_NAME,
          T.PERIOD_NUM,
          T.PERIOD_YEAR) b
    WHERE b.actual_flag = ''' || L_ACTUAL_FLAG || '''
      AND b.currency_type = ''' || L_CURRENCY_TYPE || '''
      AND b.currency_code = ''' || L_CURRENCY_CODE || '''
      AND b.period_name = ''' || P_PERIOD_NAME || '''';
    
      FOR rec_source_acc IN (SELECT *
                               FROM hae_alloc_source_account sa
                              WHERE sa.source_id = L_SOURCE_ID
                                AND (DIMENSION_VALUE IS NOT NULL OR
                                    FILTER_HEADER_ID IS NOT NULL)) LOOP
      
        --维值和筛选条件互斥
        --如果筛选组不为空，则维值一定为空，反之一样
        IF rec_source_acc.filter_header_id IS NULL THEN
          IF rec_source_acc.dimension_segment = 'LEDGER_ID' THEN
            L_INSERT_SQL := L_INSERT_SQL || ' AND ' ||
                            rec_source_acc.dimension_segment || ' = ' ||
                            rec_source_acc.dimension_value;
          ELSE
            L_INSERT_SQL := L_INSERT_SQL || ' AND ' ||
                            rec_source_acc.dimension_segment || ' = ''' ||
                            rec_source_acc.dimension_value || '''';
          END IF;
        ELSE
        
          FOR rec_filter IN (SELECT l.*
                               FROM hae_dim_filter_header h,
                                    hae_dim_filter_line   l
                              WHERE h.filter_header_id = l.filter_header_id
                                AND h.filter_header_id =
                                    rec_source_acc.filter_header_id
                                AND h.dimension_segment =
                                    rec_source_acc.dimension_segment) LOOP
            IF rec_filter.inc_exc_indicator = 'INC' THEN
            
              L_INSERT_SQL := L_INSERT_SQL || ' AND (' ||
                              rec_source_acc.dimension_segment || ' >= ''' ||
                              rec_filter.value_low || ''' AND ' ||
                              rec_source_acc.dimension_segment || ' <= ''' ||
                              rec_filter.value_high || ''')';
            
            ELSE
              L_INSERT_SQL := L_INSERT_SQL || ' AND NOT (' ||
                              rec_source_acc.dimension_segment || ' >= ''' ||
                              rec_filter.value_low || ''' AND ' ||
                              rec_source_acc.dimension_segment || ' <= ''' ||
                              rec_filter.value_high || ''')';
            END IF;
          END LOOP; --filter loop
        
        END IF;
      END LOOP; --source acc loop
    
      L_INSERT_SQL := 'INSERT INTO HAE_ALLOC_SOURCE_DATA_TMP ' ||
                      L_INSERT_SQL;
    
      --将当前的分摊源写入临时表
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'S.3.2  INSERT INTO HAE_ALLOC_SOURCE_DATA_TMP:' ||
                          L_INSERT_SQL;
      --dbms_output.put_line(L_INSERT_SQL);
      BEGIN
        EXECUTE IMMEDIATE L_INSERT_SQL;
      EXCEPTION
        WHEN OTHERS THEN
          P_CONTINUE_FLAG  := FALSE;
          G_LOG_STATE      := C_LOG_STATE_ERROR;
          G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                              'S.3.3  EXCEPTION WHEN INSERT INTO HAE_ALLOC_SOURCE_DATA_TMP:' ||
                              SUBSTR(SQLERRM, 1, 100);
          RETURN;
      END;
    END IF;
  
    --校验分摊源的记录条数 
    BEGIN
      SELECT COUNT(*)
        INTO L_SOURCE_TOTAL
        FROM HAE_ALLOC_SOURCE_DATA_TMP
       WHERE RULE_ID = P_RULE_ID
         AND PERIOD_NAME = P_PERIOD_NAME
         AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
         AND ALLOC_HISTORY_ID = P_HISTORY_ID;
    EXCEPTION
      WHEN OTHERS THEN
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'S.4.1  EXCEPTION WHEN GET COUNT OF HAE_ALLOC_SOURCE_DATA_TMP';
        L_SOURCE_TOTAL   := 0;
    END;
    --分摊源为空，则终止后续操作、并更新日志
    IF L_SOURCE_TOTAL < 1 THEN
      P_CONTINUE_FLAG := FALSE;
      G_LOG_STATE     := C_LOG_STATE_WARNING1;
    
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'S.4.2  HAE_ALLOC_SOURCE_DATA_TMP COUNT<1';
    
      RETURN;
    END IF;
  
  END;

  --
  -- Procedure
  --   process_alloc_driver
  -- Purpose
  --   Based on the definiation of the allocation rules, 
  --   including amount type and direciton to determin the calculation method of the source amount
  -- History
  --   13-02-2017   Bob Li   Created
  -- Arguments
  --   p_rule_id                 allocation rule id
  --   p_source_id               allocation source id
  --   p_source_id               allocation source id
  -- Returns
  --   
  -- Notes
  --
  PROCEDURE process_alloc_driver(p_rule_id       IN NUMBER,
                                 p_period_name   IN VARCHAR2,
                                 P_PERIOD_YEAR   IN NUMBER,
                                 P_PERIOD_NUM    IN NUMBER,
                                 P_INSTANCE_ID   IN NUMBER,
                                 P_HISTORY_ID    IN NUMBER,
                                 P_CONTINUE_FLAG OUT BOOLEAN) IS
    L_DRIVER_ID        NUMBER;
    L_DRIVER_TYPE      VARCHAR2(30);
    L_STATIC_HEADER_ID NUMBER;
    L_CONSTANT         NUMBER;
    L_ACTUAL_FLAG      VARCHAR2(30);
    L_CURRENCY_TYPE    VARCHAR2(30);
    L_CURRENCY_CODE    VARCHAR2(30);
    L_AMOUNT_TYPE      VARCHAR2(30);
    L_DIRECTION_CODE   VARCHAR2(30);
    l_driver_sql       VARCHAR2(4000);
    l_driver_sql_tmp1  VARCHAR2(4000);
    l_tot_proportion   NUMBER;
    L_COLUMN_TEMP      VARCHAR2(100);
    L_STATIC_SQL       VARCHAR2(2000);
    L_DRIVER_TOTAL     NUMBER;
  BEGIN
    G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                        'D.0  START TO PROCESS DRIVER';
    P_CONTINUE_FLAG  := TRUE;
    BEGIN
      SELECT DRIVER_ID,
             DRIVER_TYPE,
             STATIC_HEADER_ID,
             CONSTANT,
             ACTUAL_FLAG,
             CURRENCY_TYPE,
             CURRENCY_CODE,
             AMOUNT_TYPE,
             DIRECTION_CODE
        INTO L_DRIVER_ID,
             L_DRIVER_TYPE,
             L_STATIC_HEADER_ID,
             L_CONSTANT,
             L_ACTUAL_FLAG,
             L_CURRENCY_TYPE,
             L_CURRENCY_CODE,
             L_AMOUNT_TYPE,
             L_DIRECTION_CODE
        FROM HAE_ALLOC_DRIVER
       WHERE RULE_ID = p_rule_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_CONTINUE_FLAG  := FALSE;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'D.1.1  NO_DATA_FOUND WHEN HAE_ALLOC_DRIVER SELECT INTO';
      
        RETURN;
      WHEN OTHERS THEN
        L_DRIVER_ID        := NULL;
        L_DRIVER_TYPE      := NULL;
        L_STATIC_HEADER_ID := NULL;
        L_CONSTANT         := NULL;
        L_ACTUAL_FLAG      := NULL;
        L_CURRENCY_TYPE    := NULL;
        L_CURRENCY_CODE    := NULL;
        L_AMOUNT_TYPE      := NULL;
        L_DIRECTION_CODE   := NULL;
      
        P_CONTINUE_FLAG := FALSE;
        G_LOG_STATE     := C_LOG_STATE_ERROR;
      
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'D.1.2  EXCEPTION WHEN HAE_ALLOC_DRIVER SELECT INTO:' ||
                            SUBSTR(SQLERRM, 1, 100);
        RETURN;
    END;
  
    --初始化变量 
    l_driver_sql_tmp1 := NULL;
  
    --根据不同的分摊因子类型差分处不同分摊因子数据
    --分摊因子为常数
    IF L_DRIVER_TYPE = 'CONSTANT' THEN
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'D.2.1  DRIVER_TYPE=CONSTANT';
    
      BEGIN
        INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP
          (DATA_TMP_ID,
           RULE_ID,
           SOURCE_TYPE,
           ACTUAL_FLAG,
           CURRENCY_TYPE,
           CURRENCY_CODE,
           PERIOD_NAME,
           PERIOD_YEAR,
           PERIOD_NUM,
           DRIVER_AMOUNT,
           PROPORTION,
           ALLOC_INSTANCE_ID,
           ALLOC_HISTORY_ID)
          SELECT HAE_ALLOC_DATA_TMP_S.NEXTVAL,
                 p_rule_id,
                 L_DRIVER_TYPE,
                 L_ACTUAL_FLAG,
                 L_CURRENCY_TYPE,
                 L_CURRENCY_CODE,
                 p_period_name,
                 P_PERIOD_YEAR,
                 P_PERIOD_NUM,
                 NULL,
                 L_CONSTANT,
                 P_INSTANCE_ID,
                 P_HISTORY_ID
            FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN
          P_CONTINUE_FLAG  := FALSE;
          G_LOG_STATE      := C_LOG_STATE_ERROR;
          G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                              'D.2.2  EXCEPTION WHEN INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP:' ||
                              SUBSTR(SQLERRM, 1, 100);
          RETURN;
      END;
    
      --分摊因子为静态
    ELSIF L_DRIVER_TYPE = 'STATIC' THEN
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'D.3.1  DRIVER_TYPE=STATIC';
    
      BEGIN
        SELECT DIMENSION_SEGMENT
          INTO L_COLUMN_TEMP
          FROM HAE_DRIVER_STATIC_HEADER
         WHERE STATIC_HEADER_ID = L_STATIC_HEADER_ID;
      EXCEPTION
        WHEN OTHERS THEN
          P_CONTINUE_FLAG  := FALSE;
          G_LOG_STATE      := C_LOG_STATE_ERROR;
          G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                              'D.3.2  STATIC DRIVER:FAIL TO GET DIMENSION_SEGMENT' ||
                              SUBSTR(SQLERRM, 1, 100);
        
          RETURN;
      END;
    
      L_STATIC_SQL := 'INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP(DATA_TMP_ID,RULE_ID,SOURCE_TYPE,ACTUAL_FLAG,
      CURRENCY_TYPE,CURRENCY_CODE,' || L_COLUMN_TEMP ||
                      ',PERIOD_NAME,PERIOD_YEAR,PERIOD_NUM,DRIVER_AMOUNT,ALLOC_INSTANCE_ID,ALLOC_HISTORY_ID)
          SELECT HAE_ALLOC_DATA_TMP_S.NEXTVAL,' ||
                      p_rule_id || ',''' || L_DRIVER_TYPE || ''',''' ||
                      L_ACTUAL_FLAG || ''',''' || L_CURRENCY_TYPE ||
                      ''',''' || L_CURRENCY_CODE || ''',T.DIM_VALUE,''' ||
                      p_period_name || ''',' || P_PERIOD_YEAR || ',' ||
                      P_PERIOD_NUM || ',T.PROPORTION,' || P_INSTANCE_ID || ',' ||
                      P_HISTORY_ID ||
                      ' FROM HAE_DRIVER_STATIC_LINE T WHERE STATIC_HEADER_ID=' ||
                      L_STATIC_HEADER_ID;
      --dbms_output.put_line('--driver--3.2--L_STATIC_SQL=' || L_STATIC_SQL);
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'D.3.3  INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP:' ||
                          L_STATIC_SQL;
      BEGIN
        EXECUTE IMMEDIATE L_STATIC_SQL;
      EXCEPTION
        WHEN OTHERS THEN
        
          P_CONTINUE_FLAG  := FALSE;
          G_LOG_STATE      := C_LOG_STATE_ERROR;
          G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                              'D.3.4  EXCEPTION WHEN INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP:' ||
                              SUBSTR(SQLERRM, 1, 100);
        
          RETURN;
      END;
    
      --计算分摊比例，并处理比例的尾差。
      BEGIN
        l_tot_proportion := 0;
        FOR rec_data IN (SELECT t.DATA_TMP_ID,
                                t.driver_amount,
                                SUM(t.driver_amount) over() total,
                                COUNT(1) over() cont,
                                row_number() over(ORDER BY t.driver_amount) row_num
                           FROM hae_alloc_driver_data_tmp t
                          WHERE t.rule_id = p_rule_id
                            AND T.PERIOD_NAME = P_PERIOD_NAME
                            AND T.ALLOC_INSTANCE_ID = P_INSTANCE_ID
                            AND T.ALLOC_HISTORY_ID = P_HISTORY_ID) LOOP
          --处理尾差  
          IF rec_data.cont = rec_data.row_num THEN
            UPDATE hae_alloc_driver_data_tmp dt
               SET dt.proportion = 1 - l_tot_proportion
             WHERE dt.DATA_TMP_ID = rec_data.DATA_TMP_ID;
          ELSE
            l_tot_proportion := l_tot_proportion +
                                round(rec_data.driver_amount /
                                      rec_data.total,
                                      c_proportion_format); --控制尾差精度
          
            UPDATE hae_alloc_driver_data_tmp dt
               SET dt.proportion = round(rec_data.driver_amount /
                                         rec_data.total,
                                         c_proportion_format)
             WHERE dt.DATA_TMP_ID = rec_data.DATA_TMP_ID;
          END IF;
        END LOOP;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'D.3.5  CALCULATE PROPORTION END';
      
      EXCEPTION
        WHEN OTHERS THEN
          P_CONTINUE_FLAG  := FALSE;
          G_LOG_STATE      := C_LOG_STATE_ERROR;
          G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                              'D.3.6  EXCEPTION WHEN CALCULATE PROPORTION';
        
          RETURN;
      END;
      --dbms_output.put_line('--driver--3.2--calculate proportion');
    
      --分摊因子为动态
    ELSIF L_DRIVER_TYPE = 'DYNAMIC' THEN
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'D.4.1  DRIVER_TYPE=DYNAMIC';
    
      l_driver_sql := 'SELECT HAE_ALLOC_DATA_TMP_S.NEXTVAL,' || p_rule_id ||
                      ',''' || L_DRIVER_TYPE ||
                      ''', fin_element,ledger_id,  actual_flag, currency_type, currency_code, segment1,segment2,segment3,segment4,segment5,segment6, segment7,segment8,
       segment9, segment10, segment11, segment12, segment13,segment14,segment15, segment16,segment17, segment18,segment19, segment20,period_name, period_num,
       period_year,hae_alloc_engine_api.get_alloc_source_amount(''' ||
                      L_AMOUNT_TYPE || ''',''' || L_DIRECTION_CODE ||
                      ''', ''+'', b.period_dr, b.period_cr, b.end_balance_dr,b.end_balance_cr) driver_amount, NULL,' ||
                      P_INSTANCE_ID || ',' || P_HISTORY_ID || ' 
  FROM (SELECT T.FIN_ELEMENT,
       T.LEDGER_ID,
       T.ACTUAL_FLAG,
       T.CURRENCY_TYPE,
       T.CURRENCY_CODE,
       T.SEGMENT1,
       T.SEGMENT2,
       T.SEGMENT3,
       T.SEGMENT4,
       T.SEGMENT5,
       T.SEGMENT6,
       T.SEGMENT7,
       T.SEGMENT8,
       T.SEGMENT9,
       T.SEGMENT10,
       T.SEGMENT11,
       T.SEGMENT12,
       T.SEGMENT13,
       T.SEGMENT14,
       T.SEGMENT15,
       T.SEGMENT16,
       T.SEGMENT17,
       T.SEGMENT18,
       T.SEGMENT19,
       T.SEGMENT20,
       T.PERIOD_NAME,
       T.PERIOD_NUM,
       T.PERIOD_YEAR,
       SUM(NVL(T.BEGIN_BALANCE_DR, 0)) BEGIN_BALANCE_DR,
       SUM(NVL(T.BEGIN_BALANCE_CR, 0)) BEGIN_BALANCE_CR,
       SUM(NVL(T.PERIOD_DR, 0)) PERIOD_DR,
       SUM(NVL(T.PERIOD_CR, 0)) PERIOD_CR,
       SUM(NVL(T.BEGIN_BALANCE_DR, 0)) + SUM(NVL(T.PERIOD_DR, 0)) END_BALANCE_DR,
       SUM(NVL(T.BEGIN_BALANCE_CR, 0)) + SUM(NVL(T.PERIOD_CR, 0)) END_BALANCE_CR
  FROM HRS_CORE_BALANCE T
 WHERE T.actual_flag = ''' || L_ACTUAL_FLAG || '''
   AND T.currency_type = ''' || L_CURRENCY_TYPE || '''
   AND T.currency_code = ''' || L_CURRENCY_CODE || '''
   AND T.period_name = ''' || P_PERIOD_NAME || ''' ' ||
                      'GROUP BY T.FIN_ELEMENT,
          T.LEDGER_ID,
          T.ACTUAL_FLAG,
          T.CURRENCY_TYPE,
          T.CURRENCY_CODE,
          T.SEGMENT1,
          T.SEGMENT2,
          T.SEGMENT3,
          T.SEGMENT4,
          T.SEGMENT5,
          T.SEGMENT6,
          T.SEGMENT7,
          T.SEGMENT8,
          T.SEGMENT9,
          T.SEGMENT10,
          T.SEGMENT11,
          T.SEGMENT12,
          T.SEGMENT13,
          T.SEGMENT14,
          T.SEGMENT15,
          T.SEGMENT16,
          T.SEGMENT17,
          T.SEGMENT18,
          T.SEGMENT19,
          T.SEGMENT20,
          T.PERIOD_NAME,
          T.PERIOD_NUM,
          T.PERIOD_YEAR
) b
 WHERE b.actual_flag = ''' || L_ACTUAL_FLAG || '''
   AND b.currency_type = ''' || L_CURRENCY_TYPE || '''
   AND b.currency_code = ''' || L_CURRENCY_CODE || '''
   AND b.period_name = ''' || p_period_name || '''';
    
      FOR rec_driver_acc IN (SELECT *
                               FROM hae_alloc_driver_account da
                              WHERE da.drvier_id = L_DRIVER_ID
                                AND (DIMENSION_VALUE IS NOT NULL OR
                                    FILTER_HEADER_ID IS NOT NULL)) LOOP
      
        --维值和筛选条件互斥
        --如果筛选组不为空，则维值一定为空，反之一样
        IF rec_driver_acc.filter_header_id IS NULL THEN
          IF rec_driver_acc.dimension_segment = 'LEDGER_ID' THEN
            l_driver_sql_tmp1 := l_driver_sql_tmp1 || ' AND ' ||
                                 rec_driver_acc.dimension_segment || ' = ' ||
                                 rec_driver_acc.dimension_value;
          ELSE
            l_driver_sql_tmp1 := l_driver_sql_tmp1 || ' AND ' ||
                                 rec_driver_acc.dimension_segment ||
                                 ' = ''' || rec_driver_acc.dimension_value || '''';
          END IF;
        ELSE
        
          FOR rec_filter IN (SELECT l.*
                               FROM hae_dim_filter_header h,
                                    hae_dim_filter_line   l
                              WHERE h.filter_header_id = l.filter_header_id
                                AND h.filter_header_id =
                                    rec_driver_acc.filter_header_id
                                AND h.dimension_segment =
                                    rec_driver_acc.dimension_segment) LOOP
            IF rec_filter.inc_exc_indicator = 'INC' THEN
            
              l_driver_sql_tmp1 := l_driver_sql_tmp1 || ' AND (' ||
                                   rec_driver_acc.dimension_segment ||
                                   ' >= ''' || rec_filter.value_low ||
                                   ''' AND ' ||
                                   rec_driver_acc.dimension_segment ||
                                   ' <= ''' || rec_filter.value_high ||
                                   ''')';
            
            ELSE
              l_driver_sql_tmp1 := l_driver_sql_tmp1 || ' AND NOT (' ||
                                   rec_driver_acc.dimension_segment ||
                                   ' >= ''' || rec_filter.value_low ||
                                   ''' AND ' ||
                                   rec_driver_acc.dimension_segment ||
                                   ' <= ''' || rec_filter.value_high ||
                                   ''')';
            END IF;
          END LOOP; --filter loop
        
        END IF;
      END LOOP; --source acc loop
    
      l_driver_sql := 'INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP ' ||
                      l_driver_sql || l_driver_sql_tmp1;
    
      --将当前的分摊源写入临时表
    
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'D.4.2  INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP:' ||
                          l_driver_sql;
    
      BEGIN
        EXECUTE IMMEDIATE l_driver_sql;
      EXCEPTION
        WHEN OTHERS THEN
          P_CONTINUE_FLAG  := FALSE;
          G_LOG_STATE      := C_LOG_STATE_ERROR;
          G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                              'D.4.3  EXCEPTION WHEN INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP:' ||
                              SUBSTR(SQLERRM, 1, 100);
          RETURN;
      END;
      BEGIN
        l_tot_proportion := 0;
        FOR rec_data IN (SELECT t.DATA_TMP_ID,
                                t.driver_amount,
                                SUM(t.driver_amount) over() total,
                                COUNT(1) over() cont,
                                row_number() over(ORDER BY t.driver_amount) row_num
                           FROM hae_alloc_driver_data_tmp t
                          WHERE t.rule_id = p_rule_id
                            AND T.PERIOD_NAME = P_PERIOD_NAME
                            AND T.ALLOC_INSTANCE_ID = P_INSTANCE_ID
                            AND T.ALLOC_HISTORY_ID = P_HISTORY_ID) LOOP
          --处理尾差  
          IF rec_data.cont = rec_data.row_num THEN
            UPDATE hae_alloc_driver_data_tmp dt
               SET dt.proportion = 1 - l_tot_proportion
             WHERE dt.DATA_TMP_ID = rec_data.DATA_TMP_ID;
          ELSE
            l_tot_proportion := l_tot_proportion +
                                round(rec_data.driver_amount /
                                      rec_data.total,
                                      c_proportion_format); --控制尾差精度
          
            UPDATE hae_alloc_driver_data_tmp dt
               SET dt.proportion = round(rec_data.driver_amount /
                                         rec_data.total,
                                         c_proportion_format)
             WHERE dt.DATA_TMP_ID = rec_data.DATA_TMP_ID;
          END IF;
        END LOOP;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'D.4.4  CALCULATE PROPORTION END';
      
      EXCEPTION
        WHEN OTHERS THEN
          P_CONTINUE_FLAG  := FALSE;
          G_LOG_STATE      := C_LOG_STATE_ERROR;
          G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                              'D.4.5  EXCEPTION WHEN CALCULATE PROPORTION';
        
          RETURN;
      END;
      --dbms_output.put_line('--driver--3.3--calculate proportion');
    
    END IF;
  
    --校验分摊因子的记录条数     
    BEGIN
      SELECT COUNT(*)
        INTO L_DRIVER_TOTAL
        FROM HAE_ALLOC_DRIVER_DATA_TMP
       WHERE RULE_ID = P_RULE_ID
         AND PERIOD_NAME = P_PERIOD_NAME
         AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
         AND ALLOC_HISTORY_ID = P_HISTORY_ID;
    EXCEPTION
      WHEN OTHERS THEN
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'D.5.1  EXCEPTION WHEN GET COUNT OF HAE_ALLOC_DRIVER_DATA_TMP';
      
        L_DRIVER_TOTAL := 0;
    END;
    --分摊因子为空，则终止后续操作、并更新日志
    IF L_DRIVER_TOTAL < 1 THEN
      P_CONTINUE_FLAG := FALSE;
      G_LOG_STATE     := C_LOG_STATE_WARNING2;
    
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'D.5.2  HAE_ALLOC_DRIVER_DATA_TMP COUNT<1';
    
      RETURN;
    END IF;
  
  END;

  --
  -- Procedure
  --   process_alloc_target
  -- Purpose
  -- create the target and offset records to table:HAE_ALLOC_TARGET_DATA_TMP   
  -- History
  --   29-03-2017   LSS   Created
  -- Arguments
  --   p_rule_id
  --   p_period_name
  -- Returns
  --   
  -- Notes
  --
  PROCEDURE process_alloc_target(p_rule_id       IN NUMBER,
                                 p_period_name   IN VARCHAR2,
                                 P_PERIOD_YEAR   IN NUMBER,
                                 P_PERIOD_NUM    IN NUMBER,
                                 P_INSTANCE_ID   IN NUMBER,
                                 P_HISTORY_ID    IN NUMBER,
                                 P_CONTINUE_FLAG OUT BOOLEAN) IS
    L_MATCH_NUM           NUMBER := 0;
    L_WHERE_SQL           VARCHAR2(1000);
    L_INSERT_SQL          VARCHAR2(2000);
    L_TARGET_SQL0         VARCHAR2(2000);
    L_TARGET_SQL          VARCHAR2(4000);
    L_TARGET_COLUMN       VARCHAR2(1000);
    L_TARGET_INSERT       VARCHAR2(4000);
    L_TARGET_ACTUAL_FLAG  VARCHAR2(100);
    L_TARGET_CUR_TYPE     VARCHAR2(100);
    L_TARGET_CUR          VARCHAR2(100);
    L_TARGET_AMT_TYPE     VARCHAR2(100); --PTD
    L_TARGET_DIRECTION    VARCHAR2(100);
    L_OFFSET_SQL0         VARCHAR2(2000);
    L_OFFSET_SQL          VARCHAR2(4000);
    L_OFFSET_COLUMN       VARCHAR2(1000);
    L_OFFSET_INSERT       VARCHAR2(4000);
    L_OFFSET_ACTUAL_FLAG  VARCHAR2(100);
    L_OFFSET_CUR_TYPE     VARCHAR2(100);
    L_OFFSET_CUR          VARCHAR2(100);
    L_OFFSET_AMT_TYPE     VARCHAR2(100); --PTD
    L_OFFSET_DIRECTION    VARCHAR2(100);
    L_ACC_PROPORTION      NUMBER;
    L_TOTAL_PROPORTION    NUMBER;
    L_MATCH_TEMP          NUMBER;
    L_TAGERT_RESULT_TOTAL NUMBER;
    L_TOTAL_TEMP          NUMBER;
  BEGIN
    --dbms_output.put_line('--target--1');
    G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                        'T.0  START TO PROCESS TARGET';
  
    P_CONTINUE_FLAG := TRUE;
    BEGIN
      SELECT ACTUAL_FLAG,
             CURRENCY_TYPE,
             CURRENCY_CODE,
             AMOUNT_TYPE,
             DIRECTION_CODE
        INTO L_TARGET_ACTUAL_FLAG,
             L_TARGET_CUR_TYPE,
             L_TARGET_CUR,
             L_TARGET_AMT_TYPE,
             L_TARGET_DIRECTION
        FROM HAE_ALLOC_TARGET
       WHERE RULE_ID = p_rule_id
         AND TYPE = 'TARGET';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_CONTINUE_FLAG := FALSE;
        G_LOG_STATE     := C_LOG_STATE_ERROR;
      
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.1.1  NO_DATA_FOUND WHEN HAE_ALLOC_TARGET.TARGET SELECT INTO';
      
        RETURN;
      WHEN OTHERS THEN
        L_TARGET_ACTUAL_FLAG := NULL;
        L_TARGET_CUR_TYPE    := NULL;
        L_TARGET_CUR         := NULL;
        L_TARGET_AMT_TYPE    := NULL;
        L_TARGET_DIRECTION   := NULL;
      
        P_CONTINUE_FLAG  := FALSE;
        G_LOG_STATE      := C_LOG_STATE_ERROR;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.1.2  EXCEPTION WHEN HAE_ALLOC_TARGET.TARGET SELECT INTO:' ||
                            SUBSTR(SQLERRM, 1, 100);
      
        RETURN;
    END;
  
    BEGIN
      SELECT ACTUAL_FLAG,
             CURRENCY_TYPE,
             CURRENCY_CODE,
             AMOUNT_TYPE,
             DIRECTION_CODE
        INTO L_OFFSET_ACTUAL_FLAG,
             L_OFFSET_CUR_TYPE,
             L_OFFSET_CUR,
             L_OFFSET_AMT_TYPE,
             L_OFFSET_DIRECTION
        FROM HAE_ALLOC_TARGET
       WHERE RULE_ID = p_rule_id
         AND TYPE = 'OFFSET';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_CONTINUE_FLAG  := FALSE;
        G_LOG_STATE      := C_LOG_STATE_ERROR;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.2.1  NO_DATA_FOUND WHEN HAE_ALLOC_TARGET.OFFSET SELECT INTO';
      
        RETURN;
      WHEN OTHERS THEN
        L_OFFSET_ACTUAL_FLAG := NULL;
        L_OFFSET_CUR_TYPE    := NULL;
        L_OFFSET_CUR         := NULL;
        L_OFFSET_AMT_TYPE    := NULL;
        L_OFFSET_DIRECTION   := NULL;
      
        P_CONTINUE_FLAG  := FALSE;
        G_LOG_STATE      := C_LOG_STATE_ERROR;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.2.2  EXCEPTION WHEN HAE_ALLOC_TARGET.OFFSET SELECT INTO:' ||
                            SUBSTR(SQLERRM, 1, 100);
      
        RETURN;
    END;
  
    --拼分摊目标的查询sql
    FOR LEC_TARGET IN (SELECT HATA.DIMENSION_SEGMENT,
                              HATA.DIM_ALLOC_TYPE,
                              HATA.DIMENSION_VALUE
                         FROM HAE_ALLOC_TARGET         HAT,
                              HAE_ALLOC_TARGET_ACCOUNT HATA
                        WHERE HAT.TARGET_ID = HATA.TARGET_ID
                          AND HAT.TYPE = 'TARGET'
                          AND HAT.RULE_ID = p_rule_id
                          AND HATA.DIM_ALLOC_TYPE IS NOT NULL
                        ORDER BY HATA.DIMENSION_SEGMENT) LOOP
      IF LEC_TARGET.DIM_ALLOC_TYPE IN ('MATCH', 'SOURCE') THEN
        L_TARGET_SQL0 := L_TARGET_SQL0 || ',ST.' ||
                         LEC_TARGET.DIMENSION_SEGMENT;
      ELSIF LEC_TARGET.DIM_ALLOC_TYPE = 'DRIVER' THEN
        L_TARGET_SQL0 := L_TARGET_SQL0 || ',DT.' ||
                         LEC_TARGET.DIMENSION_SEGMENT;
      ELSIF LEC_TARGET.DIM_ALLOC_TYPE = 'VALUE' THEN
        L_TARGET_SQL0 := L_TARGET_SQL0 || ',''' ||
                         LEC_TARGET.DIMENSION_VALUE || '''';
      ELSE
        NULL;
      END IF;
      L_TARGET_COLUMN := L_TARGET_COLUMN || ',' ||
                         LEC_TARGET.DIMENSION_SEGMENT;
    END LOOP;
  
    --拼分摊抵消的查询sql
    FOR LEC_OFFSET IN (SELECT HATA.DIMENSION_SEGMENT,
                              HATA.DIM_ALLOC_TYPE,
                              HATA.DIMENSION_VALUE
                         FROM HAE_ALLOC_TARGET         HAT,
                              HAE_ALLOC_TARGET_ACCOUNT HATA
                        WHERE HAT.TARGET_ID = HATA.TARGET_ID
                          AND HAT.TYPE = 'OFFSET'
                          AND HAT.RULE_ID = p_rule_id
                          AND HATA.DIM_ALLOC_TYPE IS NOT NULL
                        ORDER BY HATA.DIMENSION_SEGMENT) LOOP
      IF LEC_OFFSET.DIM_ALLOC_TYPE = 'SOURCE' THEN
        L_OFFSET_SQL0 := L_OFFSET_SQL0 || ',ST.' ||
                         LEC_OFFSET.DIMENSION_SEGMENT;
      ELSIF LEC_OFFSET.DIM_ALLOC_TYPE = 'DRIVER' THEN
        L_OFFSET_SQL0 := L_OFFSET_SQL0 || ',DT.' ||
                         LEC_OFFSET.DIMENSION_SEGMENT;
      ELSIF LEC_OFFSET.DIM_ALLOC_TYPE = 'VALUE' THEN
        L_OFFSET_SQL0 := L_OFFSET_SQL0 || ',''' ||
                         LEC_OFFSET.DIMENSION_VALUE || '''';
      ELSE
        NULL;
      END IF;
      L_OFFSET_COLUMN := L_OFFSET_COLUMN || ',' ||
                         LEC_OFFSET.DIMENSION_SEGMENT;
    END LOOP;
  
    --分摊目标中是否存在MATCH
    BEGIN
      SELECT COUNT(HATA.DIMENSION_SEGMENT)
        INTO L_MATCH_NUM
        FROM HAE_ALLOC_TARGET HAT, HAE_ALLOC_TARGET_ACCOUNT HATA
       WHERE HAT.TARGET_ID = HATA.TARGET_ID
         AND HAT.TYPE = 'TARGET'
         AND HATA.DIM_ALLOC_TYPE = 'MATCH'
         AND HAT.RULE_ID = p_rule_id;
    EXCEPTION
      WHEN OTHERS THEN
        L_MATCH_NUM := 0;
    END;
  
    --判断TARGET对应的金额类型 
    IF L_TARGET_DIRECTION = 'DR' THEN
      L_TARGET_COLUMN := L_TARGET_COLUMN || ',PERIOD_DR';
    ELSE
      L_TARGET_COLUMN := L_TARGET_COLUMN || ',PERIOD_CR';
    END IF;
  
    --判断OFFSET对应的金额类型 
    IF L_OFFSET_DIRECTION = 'DR' THEN
      L_OFFSET_COLUMN := L_OFFSET_COLUMN || ',PERIOD_DR';
    ELSE
      L_OFFSET_COLUMN := L_OFFSET_COLUMN || ',PERIOD_CR';
    END IF;
  
    IF L_MATCH_NUM > 0 THEN
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'T.3.1  EXIST MATCH IN TARGET';
    
      --分摊目标中存在MATCH，则重新计算分摊因子
      FOR LEC_SEGMENT IN (SELECT HATA.DIMENSION_SEGMENT
                            INTO L_MATCH_NUM
                            FROM HAE_ALLOC_TARGET         HAT,
                                 HAE_ALLOC_TARGET_ACCOUNT HATA
                           WHERE HAT.TARGET_ID = HATA.TARGET_ID
                             AND HAT.TYPE = 'TARGET'
                             AND HATA.DIM_ALLOC_TYPE = 'MATCH'
                             AND HAT.RULE_ID = p_rule_id) LOOP
        L_WHERE_SQL := L_WHERE_SQL || ' AND DT.' ||
                       LEC_SEGMENT.DIMENSION_SEGMENT || '=ST.' ||
                       LEC_SEGMENT.DIMENSION_SEGMENT;
      END LOOP;
    
      L_INSERT_SQL := 'INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP2 SELECT HAE_ALLOC_DATA_TMP_S.NEXTVAL,
       DT.RULE_ID,
       DT.SOURCE_TYPE,
       DT.FIN_ELEMENT,
       DT.LEDGER_ID,
       DT.ACTUAL_FLAG,
       DT.CURRENCY_TYPE,
       DT.CURRENCY_CODE,
       DT.SEGMENT1,
       DT.SEGMENT2,
       DT.SEGMENT3,
       DT.SEGMENT4,
       DT.SEGMENT5,
       DT.SEGMENT6,
       DT.SEGMENT7,
       DT.SEGMENT8,
       DT.SEGMENT9,
       DT.SEGMENT10,
       DT.SEGMENT11,
       DT.SEGMENT12,
       DT.SEGMENT13,
       DT.SEGMENT14,
       DT.SEGMENT15,
       DT.SEGMENT16,
       DT.SEGMENT17,
       DT.SEGMENT18,
       DT.SEGMENT19,
       DT.SEGMENT20,
       DT.PERIOD_NAME,
       DT.PERIOD_NUM,
       DT.PERIOD_YEAR,
       DT.DRIVER_AMOUNT,
       ST.DATA_TMP_ID,
       NULL,' || P_INSTANCE_ID || ',' || P_HISTORY_ID || ' 
  FROM HAE_ALLOC_SOURCE_DATA_TMP ST, HAE_ALLOC_DRIVER_DATA_TMP DT
 WHERE 1 = 1
 AND ST.ALLOC_INSTANCE_ID=' || P_INSTANCE_ID ||
                      '  AND ST.ALLOC_HISTORY_ID=' || P_HISTORY_ID ||
                      '  AND DT.ALLOC_INSTANCE_ID=' || P_INSTANCE_ID ||
                      '  AND DT.ALLOC_HISTORY_ID=' || P_HISTORY_ID ||
                      '  AND ST.RULE_ID =' || p_rule_id ||
                      ' AND DT.RULE_ID =' || p_rule_id || L_WHERE_SQL;
    
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'T.3.2  INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP2:' ||
                          L_INSERT_SQL;
    
      --dbms_output.put_line('--target--3.1--L_INSERT_SQL=' || L_INSERT_SQL);
      BEGIN
        EXECUTE IMMEDIATE L_INSERT_SQL;
      EXCEPTION
        WHEN OTHERS THEN
          P_CONTINUE_FLAG  := FALSE;
          G_LOG_STATE      := C_LOG_STATE_ERROR;
          G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                              'T.3.3  EXCEPTION WHEN INSERT INTO HAE_ALLOC_DRIVER_DATA_TMP2:' ||
                              SUBSTR(SQLERRM, 1, 100);
        
          RETURN;
      END;
      /*校验是否所有的分摊源都有对应的分摊因子*/
      --校验HAE_ALLOC_SOURCE_DATA_TMP表的DATA_TMP_ID是否都存在于HAE_ALLOC_DRIVER_DATA_TMP2表中
      --
      BEGIN
        SELECT 1
          INTO L_MATCH_TEMP
          FROM HAE_ALLOC_SOURCE_DATA_TMP ST
         WHERE NOT EXISTS (SELECT 1
                  FROM HAE_ALLOC_DRIVER_DATA_TMP2 DT
                 WHERE ST.DATA_TMP_ID = DT.SOURCE_DATA_TEMP_ID
                   AND DT.ALLOC_INSTANCE_ID = P_INSTANCE_ID
                   AND DT.ALLOC_HISTORY_ID = P_HISTORY_ID)
           AND ST.ALLOC_INSTANCE_ID = P_INSTANCE_ID
           AND ST.ALLOC_HISTORY_ID = P_HISTORY_ID;
      EXCEPTION
        WHEN OTHERS THEN
          L_MATCH_TEMP := 0;
      END;
    
      IF L_MATCH_TEMP = 1 THEN
        G_LOG_STATE      := C_LOG_STATE_WARNING4;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.3.4  EXIST SOURCE WHO DO NOT HAVE DRIVER';
      
        P_CONTINUE_FLAG := FALSE;
        RETURN;
      END IF;
    
      --针对每条分摊源，重新计算分摊系数
      FOR LEC_SOURCE IN (SELECT T.*
                           FROM HAE_ALLOC_SOURCE_DATA_TMP T
                          WHERE T.RULE_ID = p_rule_id
                            AND T.ALLOC_INSTANCE_ID = P_INSTANCE_ID
                            AND T.ALLOC_HISTORY_ID = P_HISTORY_ID
                            AND EXISTS
                          (SELECT 1
                                   FROM HAE_ALLOC_DRIVER_DATA_TMP2 T2
                                  WHERE T.DATA_TMP_ID =
                                        T2.SOURCE_DATA_TEMP_ID)) LOOP
        L_ACC_PROPORTION := 0;
      
        --重新计算分摊系数
        FOR REC_DATA IN (SELECT T.DATA_TMP_ID,
                                T.DRIVER_AMOUNT,
                                SUM(T.DRIVER_AMOUNT) OVER() TOTAL,
                                COUNT(1) OVER() CONT,
                                ROW_NUMBER() OVER(ORDER BY T.DRIVER_AMOUNT) ROW_NUM
                           FROM HAE_ALLOC_DRIVER_DATA_TMP2 T
                          WHERE T.RULE_ID = p_rule_id
                            AND T.ALLOC_INSTANCE_ID = P_INSTANCE_ID
                            AND T.ALLOC_HISTORY_ID = P_HISTORY_ID
                            AND T.SOURCE_DATA_TEMP_ID =
                                LEC_SOURCE.DATA_TMP_ID) LOOP
        
          --处理尾差  
          IF REC_DATA.CONT = REC_DATA.ROW_NUM THEN
            UPDATE HAE_ALLOC_DRIVER_DATA_TMP2 T
               SET T.MATCHED_PROPORTION = 1 - L_ACC_PROPORTION
             WHERE T.DATA_TMP_ID = REC_DATA.DATA_TMP_ID;
          ELSE
            L_ACC_PROPORTION := L_ACC_PROPORTION +
                                round(REC_DATA.DRIVER_AMOUNT /
                                      REC_DATA.TOTAL,
                                      c_proportion_format); --控制尾差精度
          
            UPDATE HAE_ALLOC_DRIVER_DATA_TMP2 T
               SET T.MATCHED_PROPORTION = round(REC_DATA.DRIVER_AMOUNT /
                                                REC_DATA.TOTAL,
                                                c_proportion_format)
             WHERE T.DATA_TMP_ID = REC_DATA.DATA_TMP_ID;
          END IF;
        END LOOP;
      
        --生成分摊目标
      
        L_TARGET_SQL    := 'SELECT ' || LEC_SOURCE.DATA_TMP_ID || ',' ||
                           P_RULE_ID || ',''TARGET'',''' ||
                           L_TARGET_ACTUAL_FLAG || ''',''' ||
                           L_TARGET_CUR_TYPE || ''',''' || L_TARGET_CUR ||
                           ''',''' || p_period_name || ''',' ||
                           P_PERIOD_YEAR || ',' || P_PERIOD_NUM ||
                           ',SYSDATE,0,SYSDATE,0' || L_TARGET_SQL0 ||
                           ',ST.SOURCE_AMOUNT*DT.MATCHED_PROPORTION,' ||
                           P_INSTANCE_ID || ',' || P_HISTORY_ID ||
                           ' FROM HAE_ALLOC_SOURCE_DATA_TMP ST,HAE_ALLOC_DRIVER_DATA_TMP2 DT WHERE ST.RULE_ID=' ||
                           p_rule_id || ' AND DT.RULE_ID=' || p_rule_id ||
                           ' AND ST.ALLOC_INSTANCE_ID=' || P_INSTANCE_ID ||
                           '  AND ST.ALLOC_HISTORY_ID=' || P_HISTORY_ID ||
                           '  AND DT.ALLOC_INSTANCE_ID=' || P_INSTANCE_ID ||
                           '  AND DT.ALLOC_HISTORY_ID=' || P_HISTORY_ID ||
                           ' AND ST.DATA_TMP_ID = DT.SOURCE_DATA_TEMP_ID' ||
                           ' AND ST.DATA_TMP_ID =' ||
                           LEC_SOURCE.DATA_TMP_ID;
        L_TARGET_INSERT := 'INSERT INTO HAE_ALLOC_TARGET_DATA_TMP(SOURCE_DATA_TEMP_ID,RULE_ID,RESULT_TYPE,ACTUAL_FLAG,CURRENCY_TYPE,CURRENCY_CODE,PERIOD_NAME,PERIOD_YEAR,PERIOD_NUM,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY' ||
                           L_TARGET_COLUMN ||
                           ',ALLOC_INSTANCE_ID,ALLOC_HISTORY_ID) ' ||
                           L_TARGET_SQL;
      
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.3.5  INSERT INTO HAE_ALLOC_TARGET_DATA_TMP.TARGET:' ||
                            L_TARGET_INSERT;
      
        BEGIN
          EXECUTE IMMEDIATE L_TARGET_INSERT;
        EXCEPTION
          WHEN OTHERS THEN
            P_CONTINUE_FLAG  := FALSE;
            G_LOG_STATE      := C_LOG_STATE_ERROR;
            G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                                'T.3.6  EXCEPTION WHEN INSERT INTO HAE_ALLOC_TARGET_DATA_TMP.TARGET:' ||
                                SUBSTR(SQLERRM, 1, 100);
          
            RETURN;
        END;
      
        --生成分摊抵消
        SELECT SUM(NVL(MATCHED_PROPORTION, 0))
          INTO L_TOTAL_PROPORTION
          FROM HAE_ALLOC_DRIVER_DATA_TMP2
         WHERE SOURCE_DATA_TEMP_ID = LEC_SOURCE.DATA_TMP_ID;
      
        L_OFFSET_SQL    := 'SELECT ' || LEC_SOURCE.DATA_TMP_ID || ',' ||
                           P_RULE_ID || ',''OFFSET'',''' ||
                           L_OFFSET_ACTUAL_FLAG || ''',''' ||
                           L_OFFSET_CUR_TYPE || ''',''' || L_OFFSET_CUR ||
                           ''',''' || p_period_name || ''',' ||
                           P_PERIOD_YEAR || ',' || P_PERIOD_NUM ||
                           ',SYSDATE,0,SYSDATE,0' || L_OFFSET_SQL0 ||
                           ',ST.SOURCE_AMOUNT*' ||
                           L_TOTAL_PROPORTION * (-1) || ',' ||
                           P_INSTANCE_ID || ',' || P_HISTORY_ID ||
                           ' FROM HAE_ALLOC_SOURCE_DATA_TMP ST,HAE_ALLOC_DRIVER_DATA_TMP2 DT WHERE ST.RULE_ID=' ||
                           p_rule_id || ' AND DT.RULE_ID=' || p_rule_id ||
                           ' AND ST.ALLOC_INSTANCE_ID=' || P_INSTANCE_ID ||
                           '  AND ST.ALLOC_HISTORY_ID=' || P_HISTORY_ID ||
                           '  AND DT.ALLOC_INSTANCE_ID=' || P_INSTANCE_ID ||
                           '  AND DT.ALLOC_HISTORY_ID=' || P_HISTORY_ID ||
                           ' AND ST.DATA_TMP_ID = DT.SOURCE_DATA_TEMP_ID' ||
                           ' AND ST.DATA_TMP_ID =' ||
                           LEC_SOURCE.DATA_TMP_ID || ' AND ROWNUM=1'; --一条分摊源仅生成一条抵消
        L_OFFSET_INSERT := 'INSERT INTO HAE_ALLOC_TARGET_DATA_TMP(SOURCE_DATA_TEMP_ID,RULE_ID,RESULT_TYPE,ACTUAL_FLAG,CURRENCY_TYPE,CURRENCY_CODE,PERIOD_NAME,PERIOD_YEAR,PERIOD_NUM,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY' ||
                           L_OFFSET_COLUMN ||
                           ',ALLOC_INSTANCE_ID,ALLOC_HISTORY_ID) ' ||
                           L_OFFSET_SQL;
      
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.3.7  INSERT INTO HAE_ALLOC_TARGET_DATA_TMP.OFFSET:' ||
                            L_OFFSET_INSERT;
      
        BEGIN
          EXECUTE IMMEDIATE L_OFFSET_INSERT;
        EXCEPTION
          WHEN OTHERS THEN
            P_CONTINUE_FLAG  := FALSE;
            G_LOG_STATE      := C_LOG_STATE_ERROR;
            G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                                'T.3.8  EXCEPTION WHEN INSERT INTO HAE_ALLOC_TARGET_DATA_TMP.OFFSET:' ||
                                SUBSTR(SQLERRM, 1, 100);
          
            RETURN;
        END;
      END LOOP;
    
    ELSE
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'T.4.1  NOT EXIST MATCH IN TARGET';
    
      --针对每条分摊源，生成分摊目标和分摊抵消
      FOR LEC_SOURCE IN (SELECT *
                           FROM HAE_ALLOC_SOURCE_DATA_TMP
                          WHERE RULE_ID = p_rule_id
                            AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
                            AND ALLOC_HISTORY_ID = P_HISTORY_ID) LOOP
        --生成分摊目标
        L_TARGET_SQL    := 'SELECT ' || LEC_SOURCE.DATA_TMP_ID || ',' ||
                           P_RULE_ID || ',''TARGET'',''' ||
                           L_TARGET_ACTUAL_FLAG || ''',''' ||
                           L_TARGET_CUR_TYPE || ''',''' || L_TARGET_CUR ||
                           ''',''' || p_period_name || ''',' ||
                           P_PERIOD_YEAR || ',' || P_PERIOD_NUM ||
                           ',SYSDATE,0,SYSDATE,0' || L_TARGET_SQL0 ||
                           ',ST.SOURCE_AMOUNT*DT.PROPORTION,' ||
                           P_INSTANCE_ID || ',' || P_HISTORY_ID ||
                           ' FROM HAE_ALLOC_SOURCE_DATA_TMP ST,HAE_ALLOC_DRIVER_DATA_TMP DT WHERE ST.RULE_ID=' ||
                           p_rule_id || ' AND DT.RULE_ID=' || p_rule_id ||
                           ' AND ST.ALLOC_INSTANCE_ID=' || P_INSTANCE_ID ||
                           '  AND ST.ALLOC_HISTORY_ID=' || P_HISTORY_ID ||
                           '  AND DT.ALLOC_INSTANCE_ID=' || P_INSTANCE_ID ||
                           '  AND DT.ALLOC_HISTORY_ID=' || P_HISTORY_ID ||
                           ' AND ST.DATA_TMP_ID = ' ||
                           LEC_SOURCE.DATA_TMP_ID;
        L_TARGET_INSERT := 'INSERT INTO HAE_ALLOC_TARGET_DATA_TMP(SOURCE_DATA_TEMP_ID,RULE_ID,RESULT_TYPE,ACTUAL_FLAG,CURRENCY_TYPE,CURRENCY_CODE,PERIOD_NAME,PERIOD_YEAR,PERIOD_NUM,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY' ||
                           L_TARGET_COLUMN ||
                           ',ALLOC_INSTANCE_ID,ALLOC_HISTORY_ID) ' ||
                           L_TARGET_SQL;
      
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.4.2  INSERT INTO HAE_ALLOC_TARGET_DATA_TMP.TARGET:' ||
                            L_TARGET_INSERT;
      
        BEGIN
          EXECUTE IMMEDIATE L_TARGET_INSERT;
        EXCEPTION
          WHEN OTHERS THEN
            P_CONTINUE_FLAG  := FALSE;
            G_LOG_STATE      := C_LOG_STATE_ERROR;
            G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                                'T.4.3  EXCEPTION WHEN INSERT INTO HAE_ALLOC_TARGET_DATA_TMP.TARGET:' ||
                                SUBSTR(SQLERRM, 1, 100);
          
            RETURN;
        END;
        --生成分摊抵消
        SELECT SUM(PROPORTION)
          INTO L_TOTAL_PROPORTION
          FROM HAE_ALLOC_DRIVER_DATA_TMP
         WHERE RULE_ID = p_rule_id
           AND PERIOD_NAME = p_period_name
           AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
           AND ALLOC_HISTORY_ID = P_HISTORY_ID;
        L_OFFSET_SQL     := 'SELECT ' || LEC_SOURCE.DATA_TMP_ID || ',' ||
                            P_RULE_ID || ',''OFFSET'',''' ||
                            L_OFFSET_ACTUAL_FLAG || ''',''' ||
                            L_OFFSET_CUR_TYPE || ''',''' || L_OFFSET_CUR ||
                            ''',''' || p_period_name || ''',' ||
                            P_PERIOD_YEAR || ',' || P_PERIOD_NUM ||
                            ',SYSDATE,0,SYSDATE,0' || L_OFFSET_SQL0 ||
                            ',ST.SOURCE_AMOUNT*' ||
                            L_TOTAL_PROPORTION * (-1) || ',' ||
                            P_INSTANCE_ID || ',' || P_HISTORY_ID ||
                            ' FROM HAE_ALLOC_SOURCE_DATA_TMP ST,HAE_ALLOC_DRIVER_DATA_TMP DT WHERE ST.RULE_ID=' ||
                            p_rule_id || ' AND DT.RULE_ID=' || p_rule_id ||
                            ' AND ST.ALLOC_INSTANCE_ID=' || P_INSTANCE_ID ||
                            '  AND ST.ALLOC_HISTORY_ID=' || P_HISTORY_ID ||
                            '  AND DT.ALLOC_INSTANCE_ID=' || P_INSTANCE_ID ||
                            '  AND DT.ALLOC_HISTORY_ID=' || P_HISTORY_ID ||
                            ' AND ST.DATA_TMP_ID = ' ||
                            LEC_SOURCE.DATA_TMP_ID || ' AND ROWNUM=1'; --一条分摊源仅生成一条抵消
        L_OFFSET_INSERT  := 'INSERT INTO HAE_ALLOC_TARGET_DATA_TMP(SOURCE_DATA_TEMP_ID,RULE_ID,RESULT_TYPE,ACTUAL_FLAG,CURRENCY_TYPE,CURRENCY_CODE,PERIOD_NAME,PERIOD_YEAR,PERIOD_NUM,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY' ||
                            L_OFFSET_COLUMN ||
                            ',ALLOC_INSTANCE_ID,ALLOC_HISTORY_ID) ' ||
                            L_OFFSET_SQL;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.4.4  INSERT INTO HAE_ALLOC_TARGET_DATA_TMP.OFFSET:' ||
                            L_OFFSET_INSERT;
      
        BEGIN
          EXECUTE IMMEDIATE L_OFFSET_INSERT;
        EXCEPTION
          WHEN OTHERS THEN
            P_CONTINUE_FLAG  := FALSE;
            G_LOG_STATE      := C_LOG_STATE_ERROR;
            G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                                'T.4.5  EXCEPTION WHEN INSERT INTO HAE_ALLOC_TARGET_DATA_TMP.OFFSET:' ||
                                SUBSTR(SQLERRM, 1, 100);
          
            RETURN;
        END;
      END LOOP;
    END IF;
  
    --分别针对每条分摊源、校验分摊结果合计是否为0
    /*所有分摊源的分摊结果合计的绝对值为0，那么说明每条分摊源的分摊结果合计都是为0的*/
    BEGIN
      SELECT SUM(ABS(TEMP.TOTAL))
        INTO L_TAGERT_RESULT_TOTAL
        FROM (SELECT SOURCE_DATA_TEMP_ID,
                     SUM(NVL(BEGIN_BALANCE_DR, 0) + NVL(BEGIN_BALANCE_CR, 0) +
                         NVL(PERIOD_DR, 0) + NVL(PERIOD_CR, 0) +
                         NVL(END_BALANCE_DR, 0) + NVL(END_BALANCE_CR, 0)) TOTAL
              
                FROM HAE_ALLOC_TARGET_DATA_TMP
               WHERE RULE_ID = P_RULE_ID
                 AND PERIOD_NAME = P_PERIOD_NAME
                 AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
                 AND ALLOC_HISTORY_ID = P_HISTORY_ID
               GROUP BY SOURCE_DATA_TEMP_ID) TEMP;
    EXCEPTION
      WHEN OTHERS THEN
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.5.1  EXCEPTION WHEN CHECK THE TOTAL_AMT OF ALL TARGET RECORDS';
      
        L_TAGERT_RESULT_TOTAL := 0;
    END;
    --分摊结果合计不为0，则终止后续操作、并更新日志
    IF L_TAGERT_RESULT_TOTAL <> 0 THEN
      P_CONTINUE_FLAG  := FALSE;
      G_LOG_STATE      := C_LOG_STATE_WARNING3;
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'T.5.2  THE TOTAL_AMT OF ALL TARGET RECORDS IS NOT ZERO';
      RETURN;
    ELSE
    
      --处理分摊金额的尾差：金额保留两位小数、尾差在分摊系数最大的那个（金额绝对值最大的那个）
      /*
      一条分摊源，对应N条分摊目标和1条分摊抵消 ，尾差放在目标N
      由于   AMT(抵消)*(-1) = AMT(目标1)+AMT(目标2)+...+AMT(目标N)
      那么       AMT(目标N) = [ round(AMT(抵消),2) + round(AMT(目标1),2)+...+round(AMT(目标N-1),2) ]*(-1)
      */
      BEGIN
        FOR LEC IN (SELECT SOURCE_DATA_TEMP_ID
                      FROM HAE_ALLOC_TARGET_DATA_TMP
                     WHERE RULE_ID = P_RULE_ID
                       AND PERIOD_NAME = P_PERIOD_NAME
                       AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
                       AND ALLOC_HISTORY_ID = P_HISTORY_ID
                       AND RESULT_TYPE = 'OFFSET') LOOP
          --更新抵消
          IF L_OFFSET_DIRECTION = 'DR' THEN
          
            UPDATE HAE_ALLOC_TARGET_DATA_TMP
               SET PERIOD_DR = ROUND(PERIOD_DR, 2)
             WHERE RULE_ID = P_RULE_ID
               AND PERIOD_NAME = P_PERIOD_NAME
               AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
               AND ALLOC_HISTORY_ID = P_HISTORY_ID
               AND RESULT_TYPE = 'OFFSET'
               AND SOURCE_DATA_TEMP_ID = LEC.SOURCE_DATA_TEMP_ID;
          
            SELECT PERIOD_DR
              INTO L_TOTAL_TEMP
              FROM HAE_ALLOC_TARGET_DATA_TMP
             WHERE RULE_ID = P_RULE_ID
               AND PERIOD_NAME = P_PERIOD_NAME
               AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
               AND ALLOC_HISTORY_ID = P_HISTORY_ID
               AND RESULT_TYPE = 'OFFSET'
               AND SOURCE_DATA_TEMP_ID = LEC.SOURCE_DATA_TEMP_ID;
          ELSE
          
            UPDATE HAE_ALLOC_TARGET_DATA_TMP
               SET PERIOD_CR = ROUND(PERIOD_CR, 2)
             WHERE RULE_ID = P_RULE_ID
               AND PERIOD_NAME = P_PERIOD_NAME
               AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
               AND ALLOC_HISTORY_ID = P_HISTORY_ID
               AND RESULT_TYPE = 'OFFSET'
               AND SOURCE_DATA_TEMP_ID = LEC.SOURCE_DATA_TEMP_ID;
          
            SELECT PERIOD_CR
              INTO L_TOTAL_TEMP
              FROM HAE_ALLOC_TARGET_DATA_TMP
             WHERE RULE_ID = P_RULE_ID
               AND PERIOD_NAME = P_PERIOD_NAME
               AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
               AND ALLOC_HISTORY_ID = P_HISTORY_ID
               AND RESULT_TYPE = 'OFFSET'
               AND SOURCE_DATA_TEMP_ID = LEC.SOURCE_DATA_TEMP_ID;
          
          END IF;
        
          IF L_TARGET_DIRECTION = 'DR' THEN
          
            FOR LEC_TARGET IN (SELECT t.ROWID,
                                      t.PERIOD_DR,
                                      SUM(t.PERIOD_DR) over() total,
                                      COUNT(1) over() cont,
                                      row_number() over(ORDER BY ABS(t.PERIOD_DR)) row_num
                                 FROM HAE_ALLOC_TARGET_DATA_TMP T
                                WHERE 1 = 1
                                  AND RULE_ID = P_RULE_ID
                                  AND PERIOD_NAME = P_PERIOD_NAME
                                  AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
                                  AND ALLOC_HISTORY_ID = P_HISTORY_ID
                                  AND RESULT_TYPE = 'TARGET'
                                  AND SOURCE_DATA_TEMP_ID =
                                      LEC.SOURCE_DATA_TEMP_ID) LOOP
              --最后一条
              IF LEC_TARGET.CONT = LEC_TARGET.ROW_NUM THEN
                UPDATE HAE_ALLOC_TARGET_DATA_TMP
                   SET PERIOD_DR = L_TOTAL_TEMP * (-1)
                 WHERE ROWID = LEC_TARGET.ROWID;
              ELSE
                L_TOTAL_TEMP := L_TOTAL_TEMP +
                                ROUND(LEC_TARGET.PERIOD_DR, 2);
                UPDATE HAE_ALLOC_TARGET_DATA_TMP
                   SET PERIOD_DR = ROUND(LEC_TARGET.PERIOD_DR, 2)
                 WHERE ROWID = LEC_TARGET.ROWID;
              END IF;
            END LOOP;
          
          ELSE
          
            FOR LEC_TARGET IN (SELECT t.ROWID,
                                      t.PERIOD_CR,
                                      SUM(t.PERIOD_CR) over() total,
                                      COUNT(1) over() cont,
                                      row_number() over(ORDER BY ABS(t.PERIOD_CR)) row_num
                                 FROM HAE_ALLOC_TARGET_DATA_TMP T
                                WHERE 1 = 1
                                  AND RULE_ID = P_RULE_ID
                                  AND PERIOD_NAME = P_PERIOD_NAME
                                  AND ALLOC_INSTANCE_ID = P_INSTANCE_ID
                                  AND ALLOC_HISTORY_ID = P_HISTORY_ID
                                  AND RESULT_TYPE = 'TARGET'
                                  AND SOURCE_DATA_TEMP_ID =
                                      LEC.SOURCE_DATA_TEMP_ID) LOOP
              --最后一条
              IF LEC_TARGET.CONT = LEC_TARGET.ROW_NUM THEN
                UPDATE HAE_ALLOC_TARGET_DATA_TMP
                   SET PERIOD_CR = L_TOTAL_TEMP * (-1)
                 WHERE ROWID = LEC_TARGET.ROWID;
              ELSE
                L_TOTAL_TEMP := L_TOTAL_TEMP +
                                ROUND(LEC_TARGET.PERIOD_CR, 2);
                UPDATE HAE_ALLOC_TARGET_DATA_TMP
                   SET PERIOD_CR = ROUND(LEC_TARGET.PERIOD_CR, 2)
                 WHERE ROWID = LEC_TARGET.ROWID;
              END IF;
            END LOOP;
          
          END IF;
        END LOOP;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'T.5.3  ROUND THE AMT OF HAE_ALLOC_TARGET_DATA_TMP SUCCESS';
      EXCEPTION
        WHEN OTHERS THEN
          P_CONTINUE_FLAG  := FALSE;
          G_LOG_STATE      := C_LOG_STATE_ERROR;
          G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                              'T.5.4  EXCEPTION WHEN ROUND THE AMT OF HAE_ALLOC_TARGET_DATA_TMP:' ||
                              SUBSTR(SQLERRM, 1, 100);
          RETURN;
      END;
    
    END IF;
  
  END;

  --
  -- Procedure
  --   process_alloc_trx
  -- Purpose
  -- create the trx and balance records 
  -- History
  --   29-03-2017   LSS   Created
  -- Arguments
  --   p_rule_id
  --   p_period_name
  -- Returns
  --   
  -- Notes
  --
  PROCEDURE process_alloc_trx(p_rule_id      IN NUMBER,
                              P_RULE_NAME    IN VARCHAR2,
                              p_period_name  IN VARCHAR2,
                              P_PERIOD_YEAR  IN NUMBER,
                              P_PERIOD_NUM   IN NUMBER,
                              P_INSTANCE_ID  IN NUMBER,
                              P_HISTORY_ID   IN NUMBER,
                              P_SUCCESS_FLAG OUT VARCHAR2) IS
    L_TRX_HEADER_ID NUMBER;
    CURSOR CSR_TRX_HEADER IS
      SELECT DISTINCT T.LEDGER_ID,
                      T.SEGMENT1,
                      T.ACTUAL_FLAG,
                      T.CURRENCY_TYPE,
                      T.CURRENCY_CODE
        FROM HAE_ALLOC_TARGET_DATA_TMP T
       WHERE T.RULE_ID = P_RULE_ID
         AND T.PERIOD_NAME = P_PERIOD_NAME
         AND T.ALLOC_INSTANCE_ID = P_INSTANCE_ID
         AND T.ALLOC_HISTORY_ID = P_HISTORY_ID;
  
  BEGIN
    P_SUCCESS_FLAG := 'SUCCESS';
    BEGIN
      INSERT INTO HRS_CORE_BALANCE
        (FIN_ELEMENT,
         LEDGER_ID,
         ACTUAL_FLAG,
         CURRENCY_TYPE,
         CURRENCY_CODE,
         SEGMENT1,
         SEGMENT2,
         SEGMENT3,
         SEGMENT4,
         SEGMENT5,
         SEGMENT6,
         SEGMENT7,
         SEGMENT8,
         SEGMENT9,
         SEGMENT10,
         SEGMENT11,
         SEGMENT12,
         SEGMENT13,
         SEGMENT14,
         SEGMENT15,
         SEGMENT16,
         SEGMENT17,
         SEGMENT18,
         SEGMENT19,
         SEGMENT20,
         PERIOD_NAME,
         PERIOD_NUM,
         PERIOD_YEAR,
         BEGIN_BALANCE_DR,
         BEGIN_BALANCE_CR,
         PERIOD_DR,
         PERIOD_CR,
         END_BALANCE_DR,
         END_BALANCE_CR,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY)
        SELECT T.FIN_ELEMENT,
               T.LEDGER_ID,
               T.ACTUAL_FLAG,
               T.CURRENCY_TYPE,
               T.CURRENCY_CODE,
               T.SEGMENT1,
               T.SEGMENT2,
               T.SEGMENT3,
               T.SEGMENT4,
               T.SEGMENT5,
               T.SEGMENT6,
               T.SEGMENT7,
               T.SEGMENT8,
               T.SEGMENT9,
               T.SEGMENT10,
               T.SEGMENT11,
               T.SEGMENT12,
               T.SEGMENT13,
               T.SEGMENT14,
               T.SEGMENT15,
               T.SEGMENT16,
               T.SEGMENT17,
               T.SEGMENT18,
               T.SEGMENT19,
               T.SEGMENT20,
               T.PERIOD_NAME,
               T.PERIOD_NUM,
               T.PERIOD_YEAR,
               SUM(NVL(T.BEGIN_BALANCE_DR, 0)),
               SUM(NVL(T.BEGIN_BALANCE_CR, 0)),
               SUM(NVL(T.PERIOD_DR, 0)),
               SUM(NVL(T.PERIOD_CR, 0)),
               SUM(NVL(T.END_BALANCE_DR, 0)),
               SUM(NVL(T.END_BALANCE_CR, 0)),
               SYSDATE,
               'ALLOC',
               SYSDATE,
               'ALLOC'
          FROM HAE_ALLOC_TARGET_DATA_TMP T
         WHERE T.RULE_ID = P_RULE_ID
           AND PERIOD_NAME = P_PERIOD_NAME
           AND T.ALLOC_INSTANCE_ID = P_INSTANCE_ID
           AND T.ALLOC_HISTORY_ID = P_HISTORY_ID
         GROUP BY T.FIN_ELEMENT,
                  T.LEDGER_ID,
                  T.ACTUAL_FLAG,
                  T.CURRENCY_TYPE,
                  T.CURRENCY_CODE,
                  T.SEGMENT1,
                  T.SEGMENT2,
                  T.SEGMENT3,
                  T.SEGMENT4,
                  T.SEGMENT5,
                  T.SEGMENT6,
                  T.SEGMENT7,
                  T.SEGMENT8,
                  T.SEGMENT9,
                  T.SEGMENT10,
                  T.SEGMENT11,
                  T.SEGMENT12,
                  T.SEGMENT13,
                  T.SEGMENT14,
                  T.SEGMENT15,
                  T.SEGMENT16,
                  T.SEGMENT17,
                  T.SEGMENT18,
                  T.SEGMENT19,
                  T.SEGMENT20,
                  T.PERIOD_NAME,
                  T.PERIOD_NUM,
                  T.PERIOD_YEAR;
    EXCEPTION
      WHEN OTHERS THEN
        P_SUCCESS_FLAG := 'ERROR';
        G_LOG_STATE    := C_LOG_STATE_ERROR;
      
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'TR.1  EXCEPTION WHEN INSERT INTO HRS_CORE_BALANCE:' ||
                            SUBSTR(SQLERRM, 1, 100);
      
    END;
    BEGIN
      FOR LEC IN CSR_TRX_HEADER LOOP
        SELECT HAE_TXN_PROCESS_HEADER_S.NEXTVAL
          INTO L_TRX_HEADER_ID
          FROM DUAL;
        INSERT INTO HAE_TXN_PROCESS_HEADER
          (TXN_HEADER_ID,
           TYPE_CODE,
           LEDGER_ID,
           COMPANY_SEG_VAL,
           ACTUAL_FLAG,
           CURRENCY_TYPE,
           CURRENCY_CODE,
           PERIOD_NAME,
           TXN_DATE,
           DESCRIPTION,
           AUDIT_FLAG,
           TRANSFER_FLAY,
           CREATED_BY,
           CREATED_DATE,
           UPDATED_BY,
           UPDATED_DATE,
           ALLOC_INSTANCE_ID,
           ALLOC_HISTORY_ID)
        VALUES
          (L_TRX_HEADER_ID,
           C_TXN_HEADER_TYPE,
           LEC.LEDGER_ID,
           LEC.SEGMENT1,
           LEC.ACTUAL_FLAG,
           LEC.CURRENCY_TYPE,
           LEC.CURRENCY_CODE,
           P_PERIOD_NAME,
           SYSDATE,
           C_TXN_HEADER_DES || '(' || P_RULE_NAME || ')_' ||
           TO_CHAR(SYSDATE, 'YYYYMMDD'),
           'N',
           'N',
           'ALLOC',
           SYSDATE,
           'ALLOC',
           SYSDATE,
           P_INSTANCE_ID,
           P_HISTORY_ID);
      
        INSERT INTO HAE_TXN_PROCESS_LINE
          (TXN_LINE_ID,
           TXN_HEADER_ID,
           LEDGER_ID,
           FIN_ELEMENT,
           SEGMENT1,
           SEGMENT2,
           SEGMENT3,
           SEGMENT4,
           SEGMENT5,
           SEGMENT6,
           SEGMENT7,
           SEGMENT8,
           SEGMENT9,
           SEGMENT10,
           SEGMENT11,
           SEGMENT12,
           SEGMENT13,
           SEGMENT14,
           SEGMENT15,
           SEGMENT16,
           SEGMENT17,
           SEGMENT18,
           SEGMENT19,
           SEGMENT20,
           AMOUNT_DR,
           AMOUNT_CR,
           DESCRIPTION,
           CREATED_BY,
           CREATED_DATE,
           UPDATED_BY,
           UPDATED_DATE,
           SEQ_NUM)
          SELECT HAE_TXN_PROCESS_LINE_S.NEXTVAL,
                 L_TRX_HEADER_ID,
                 T2.LEDGER_ID,
                 T2.FIN_ELEMENT,
                 T2.SEGMENT1,
                 T2.SEGMENT2,
                 T2.SEGMENT3,
                 T2.SEGMENT4,
                 T2.SEGMENT5,
                 T2.SEGMENT6,
                 T2.SEGMENT7,
                 T2.SEGMENT8,
                 T2.SEGMENT9,
                 T2.SEGMENT10,
                 T2.SEGMENT11,
                 T2.SEGMENT12,
                 T2.SEGMENT13,
                 T2.SEGMENT14,
                 T2.SEGMENT15,
                 T2.SEGMENT16,
                 T2.SEGMENT17,
                 T2.SEGMENT18,
                 T2.SEGMENT19,
                 T2.SEGMENT20,
                 T2.AMT_DR,
                 T2.AMT_CR,
                 C_TXN_LINE_DES || '(' || P_RULE_NAME || ')_' ||
                 TO_CHAR(SYSDATE, 'YYYYMMDD'),
                 'ALLOC',
                 SYSDATE,
                 'ALLOC',
                 SYSDATE,
                 ROWNUM
            FROM (SELECT T.LEDGER_ID,
                         T.FIN_ELEMENT,
                         T.SEGMENT1,
                         T.SEGMENT2,
                         T.SEGMENT3,
                         T.SEGMENT4,
                         T.SEGMENT5,
                         T.SEGMENT6,
                         T.SEGMENT7,
                         T.SEGMENT8,
                         T.SEGMENT9,
                         T.SEGMENT10,
                         T.SEGMENT11,
                         T.SEGMENT12,
                         T.SEGMENT13,
                         T.SEGMENT14,
                         T.SEGMENT15,
                         T.SEGMENT16,
                         T.SEGMENT17,
                         T.SEGMENT18,
                         T.SEGMENT19,
                         T.SEGMENT20,
                         T.PERIOD_NAME,
                         T.PERIOD_NUM,
                         T.PERIOD_YEAR,
                         SUM(NVL(T.BEGIN_BALANCE_DR,
                                 NVL(T.PERIOD_DR, NVL(T.END_BALANCE_DR, 0)))) AMT_DR,
                         SUM(NVL(T.BEGIN_BALANCE_CR,
                                 NVL(T.PERIOD_CR, NVL(T.END_BALANCE_CR, 0)))) AMT_CR
                    FROM HAE_ALLOC_TARGET_DATA_TMP T
                   WHERE T.RULE_ID = P_RULE_ID
                     AND PERIOD_NAME = P_PERIOD_NAME
                     AND T.ALLOC_INSTANCE_ID = P_INSTANCE_ID
                     AND T.ALLOC_HISTORY_ID = P_HISTORY_ID
                     AND T.LEDGER_ID = LEC.LEDGER_ID
                     AND T.SEGMENT1 = LEC.SEGMENT1
                     AND T.ACTUAL_FLAG = LEC.ACTUAL_FLAG
                     AND T.CURRENCY_TYPE = LEC.CURRENCY_TYPE
                     AND T.CURRENCY_CODE = LEC.CURRENCY_CODE
                   GROUP BY T.LEDGER_ID,
                            T.FIN_ELEMENT,
                            T.SEGMENT1,
                            T.SEGMENT2,
                            T.SEGMENT3,
                            T.SEGMENT4,
                            T.SEGMENT5,
                            T.SEGMENT6,
                            T.SEGMENT7,
                            T.SEGMENT8,
                            T.SEGMENT9,
                            T.SEGMENT10,
                            T.SEGMENT11,
                            T.SEGMENT12,
                            T.SEGMENT13,
                            T.SEGMENT14,
                            T.SEGMENT15,
                            T.SEGMENT16,
                            T.SEGMENT17,
                            T.SEGMENT18,
                            T.SEGMENT19,
                            T.SEGMENT20,
                            T.PERIOD_NAME,
                            T.PERIOD_NUM,
                            T.PERIOD_YEAR) T2;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        P_SUCCESS_FLAG   := 'ERROR';
        G_LOG_STATE      := C_LOG_STATE_ERROR;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'TR.2  EXCEPTION WHEN INSERT INTO HAE_TRN_PROCESS:' ||
                            SUBSTR(SQLERRM, 1, 100);
      
    END;
  END;

  --
  -- Procedure
  --   generate_alloc_result
  -- Purpose
  --   Based on the definiation of the allocation rules, inculding allocation source
  --   allocation driver, allocation target , to get the allocation result
  -- History
  --   13-02-2017   Bob Li   Created
  -- Arguments
  --   p_rule_id               allocation rules
  --   p_period_name           fiscal period
  -- Returns
  --   
  -- Notes
  --
  PROCEDURE generate_alloc_result(p_rule_id     IN NUMBER,
                                  p_period_name IN VARCHAR2,
                                  P_INSTANCE_ID IN NUMBER,
                                  P_HISTORY_ID  IN NUMBER) IS
  
    L_PERIOD_YEAR   NUMBER;
    L_PERIOD_NUM    NUMBER;
    L_CONTINUE_FLAG BOOLEAN;
    L_RULE_NAME     VARCHAR2(150);
    L_SUCCESS_FLAG  VARCHAR2(20) := 'ERROR';
  BEGIN
    INSERT INTO HAE_ALLOC_LOG
      (ALLOC_INSTANCE_ID,
       ALLOC_HISTORY_ID,
       RULE_ID,
       PERIOD_NAME,
       START_DATE)
    VALUES
      (P_INSTANCE_ID, P_HISTORY_ID, P_RULE_ID, P_PERIOD_NAME, SYSDATE);
    COMMIT;
  
    SELECT PERIOD_YEAR, PERIOD_NUM
      INTO L_PERIOD_YEAR, L_PERIOD_NUM
      FROM HRS_CORE_FIN_PERIOD
     WHERE PERIOD_NAME = p_period_name;
  
    SELECT RULE_NAME
      INTO L_RULE_NAME
      FROM HAE_ALLOC_RULE
     WHERE RULE_ID = p_rule_id;
  
    --一、处理分摊源
    process_alloc_source(p_rule_id,
                         p_period_name,
                         L_PERIOD_YEAR,
                         L_PERIOD_NUM,
                         P_INSTANCE_ID,
                         P_HISTORY_ID,
                         L_CONTINUE_FLAG);
  
    --二、处理分摊因子
    IF L_CONTINUE_FLAG THEN
      process_alloc_driver(p_rule_id,
                           p_period_name,
                           L_PERIOD_YEAR,
                           L_PERIOD_NUM,
                           P_INSTANCE_ID,
                           P_HISTORY_ID,
                           L_CONTINUE_FLAG);
    
      --三、处理分摊
      IF L_CONTINUE_FLAG THEN
        process_alloc_target(p_rule_id,
                             p_period_name,
                             L_PERIOD_YEAR,
                             L_PERIOD_NUM,
                             P_INSTANCE_ID,
                             P_HISTORY_ID,
                             L_CONTINUE_FLAG);
        --更新事务处理表和余额表
        IF L_CONTINUE_FLAG THEN
          process_alloc_trx(p_rule_id,
                            L_RULE_NAME,
                            p_period_name,
                            L_PERIOD_YEAR,
                            L_PERIOD_NUM,
                            P_INSTANCE_ID,
                            P_HISTORY_ID,
                            L_SUCCESS_FLAG);
        END IF;
      END IF;
    END IF;
  
    IF L_SUCCESS_FLAG = 'SUCCESS' THEN
      G_LOG_STATE := C_LOG_STATE_SUCCESS;
      update_log(P_INSTANCE_ID,
                 P_HISTORY_ID,
                 p_rule_id,
                 p_period_name,
                 G_LOG_STATE);
      COMMIT;
    ELSE
      ROLLBACK;
      update_log(P_INSTANCE_ID,
                 P_HISTORY_ID,
                 p_rule_id,
                 p_period_name,
                 G_LOG_STATE);
      COMMIT;
    END IF;
  END;

  procedure validate_data(p_rule_id         IN NUMBER,
                          p_period_name     IN VARCHAR2,
                          P_INSTANCE_ID     IN NUMBER,
                          P_HISTORY_ID      IN NUMBER,
                          P_VALIDATE_RESULT OUT VARCHAR2) is
    L_PERIOD_STATUS VARCHAR2(10);
  BEGIN
    P_VALIDATE_RESULT := 'SUCCESS';
    --校验期间是否是打开状态
    BEGIN
      SELECT PERIOD_STATUS
        INTO L_PERIOD_STATUS
        FROM HRS_CORE_FIN_PERIOD
       WHERE PERIOD_NAME = p_period_name;
    EXCEPTION
      WHEN OTHERS THEN
        P_VALIDATE_RESULT := 'ERROR';
        RETURN;
    END;
    IF L_PERIOD_STATUS <> 'O' THEN
      P_VALIDATE_RESULT := 'ERROR';
      RETURN;
    END IF;
  END;

  FUNCTION RUN_ALLOC(P_HISTORY_ID NUMBER) RETURN VARCHAR2 IS
    L_VALIDATE_RESULT VARCHAR2(50);
    L_RULE_ID         NUMBER;
    L_PERIOD_NAME     VARCHAR2(30);
    L_INSTANCE_ID     NUMBER;
  BEGIN
    SELECT INSTANCE_ID, RULE_ID, PERIOD
      INTO L_INSTANCE_ID, L_RULE_ID, L_PERIOD_NAME
      FROM HAE_ALLOC_INSTANCE_HISTORY
     WHERE HISTORY_ID = P_HISTORY_ID;
    validate_data(L_RULE_ID,
                  L_PERIOD_NAME,
                  L_INSTANCE_ID,
                  P_HISTORY_ID,
                  L_VALIDATE_RESULT);
    IF L_VALIDATE_RESULT = 'SUCCESS' THEN
      generate_alloc_result(L_RULE_ID,
                            L_PERIOD_NAME,
                            L_INSTANCE_ID,
                            P_HISTORY_ID);
    ELSE
      G_LOG_STATE := C_LOG_STATE_WARNING5;
    END IF;
    RETURN G_LOG_STATE;
  END RUN_ALLOC;

  --
  -- FUNCTION
  --   ROLLBACK_ALLOC
  -- Purpose
  --   ROLLBACK ALLOC 
  --   
  -- History
  --   27-04-2017   LSS   Created
  -- Arguments
  --   **            
  -- Returns
  --   
  -- Notes
  --

  FUNCTION ROLLBACK_ALLOC(P_HISTORY_ID NUMBER) RETURN VARCHAR2 IS
    L_VALIDATE_RESULT VARCHAR2(50);
    L_RULE_ID         NUMBER;
    L_PERIOD_NAME     VARCHAR2(30);
    L_PERIOD_YEAR     NUMBER;
    L_PERIOD_NUM      NUMBER;
    L_INSTANCE_ID     NUMBER;
  BEGIN
    BEGIN
      SELECT INSTANCE_ID, RULE_ID, PERIOD
        INTO L_INSTANCE_ID, L_RULE_ID, L_PERIOD_NAME
        FROM HAE_ALLOC_INSTANCE_HISTORY
       WHERE HISTORY_ID = P_HISTORY_ID;
    
      SELECT PERIOD_YEAR, PERIOD_NUM
        INTO L_PERIOD_YEAR, L_PERIOD_NUM
        FROM HRS_CORE_FIN_PERIOD
       WHERE PERIOD_NAME = L_PERIOD_NAME;
    
      G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                          'R.0  INIT DATA';
    
      validate_data(L_RULE_ID,
                    L_PERIOD_NAME,
                    L_INSTANCE_ID,
                    P_HISTORY_ID,
                    L_VALIDATE_RESULT);
      IF L_VALIDATE_RESULT = 'SUCCESS' THEN
      
        --根据事务处理表的内容来生成余额表的抵消记录
        INSERT INTO HRS_CORE_BALANCE
          SELECT L.FIN_ELEMENT,
                 H.LEDGER_ID,
                 H.AUDIT_FLAG,
                 H.CURRENCY_TYPE,
                 H.CURRENCY_CODE,
                 H.COMPANY_SEG_VAL,
                 L.SEGMENT2,
                 L.SEGMENT3,
                 L.SEGMENT4,
                 L.SEGMENT5,
                 L.SEGMENT6,
                 L.SEGMENT7,
                 L.SEGMENT8,
                 L.SEGMENT9,
                 L.SEGMENT10,
                 L.SEGMENT11,
                 L.SEGMENT12,
                 L.SEGMENT13,
                 L.SEGMENT14,
                 L.SEGMENT15,
                 L.SEGMENT16,
                 L.SEGMENT17,
                 L.SEGMENT18,
                 L.SEGMENT19,
                 L.SEGMENT20,
                 H.PERIOD_NAME,
                 L_PERIOD_NUM,
                 L_PERIOD_YEAR,
                 0,
                 0,
                 L.AMOUNT_DR * (-1),
                 L.AMOUNT_CR * (-1),
                 0,
                 0,
                 SYSDATE,
                 'ALLOC_ROLLBACK',
                 SYSDATE,
                 'ALLOC_ROLLBACK'
            FROM HAE_TXN_PROCESS_HEADER H, HAE_TXN_PROCESS_LINE L
           WHERE H.TXN_HEADER_ID = L.TXN_HEADER_ID
             AND H.ALLOC_HISTORY_ID = P_HISTORY_ID
             AND H.ALLOC_INSTANCE_ID = L_INSTANCE_ID;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'R.1  INSERT INTO HRS_CORE_BALANCE';
        --删除事务处理表的内容
        --删行表
        DELETE FROM HAE_TXN_PROCESS_LINE L
         WHERE EXISTS (SELECT 1
                  FROM HAE_TXN_PROCESS_HEADER H
                 WHERE H.TXN_HEADER_ID = L.TXN_HEADER_ID
                   AND H.ALLOC_HISTORY_ID = P_HISTORY_ID
                   AND H.ALLOC_INSTANCE_ID = L_INSTANCE_ID);
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'R.2  DELETE FROM HAE_TXN_PROCESS_LINE';
        --删头表           
        DELETE FROM HAE_TXN_PROCESS_HEADER H
         WHERE H.ALLOC_HISTORY_ID = P_HISTORY_ID
           AND H.ALLOC_INSTANCE_ID = L_INSTANCE_ID;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--' ||
                            'R.3  DELETE FROM HAE_TXN_PROCESS_HEADER';
        --回滚成功更新日志
        G_LOG_STATE      := C_LOG_STATE_ROLLBACK;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--R.4 ' ||
                            C_LOG_MSG_ROLLBACK;
        update_rollback_log(L_INSTANCE_ID,
                            P_HISTORY_ID,
                            L_RULE_ID,
                            L_period_name,
                            G_LOG_STATE);
        COMMIT;
      ELSE
        G_LOG_STATE := C_LOG_STATE_WARNING5;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        G_LOG_STATE      := C_LOG_STATE_ROLLBACKERROR;
        G_LOG_DETAIL_MSG := G_LOG_DETAIL_MSG || chr(10) || '--R.5 ' ||
                            C_LOG_MSG_ROLLBACKERROR || ':' ||
                            SUBSTR(SQLERRM, 1, 100);
        update_rollback_log(L_INSTANCE_ID,
                            P_HISTORY_ID,
                            L_RULE_ID,
                            L_period_name,
                            G_LOG_STATE);
        COMMIT;
    END;
    RETURN G_LOG_STATE;
  
  END ROLLBACK_ALLOC;

END hae_alloc_engine_api;
/
