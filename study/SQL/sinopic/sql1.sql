SELECT (LEFT('2016-05', 4) - LEFT('2016-01', 4)) * 12 + (RIGHT('2016-05', 2) - RIGHT('2016-01', 2)) + 1
FROM DUAL;

SELECT LEFT('2016-05', 4)

SELECT 7 / 12
FROM DUAL

SELECT DATEDIFF('2008-12-29', '2008-12-30') AS DiffDate

SELECT period_diff(CONCAT (
			left('2016-05', 4)
			,right('2016-05', 2)
			), CONCAT (
			left('2016-01', 4)
			,right('2016-01', 2)
			)) + 1

SELECT - (TIMESTAMPDIFF(MONTH, STR_TO_DATE('2016-06-01', '%Y-%m-%d'), STR_TO_DATE('2016-07-01', '%Y-%m-%d')) + 1)
FROM dual

SELECT date_add(STR_TO_DATE('2016-01-01', '%Y-%m-%d'), INTERVAL - (TIMESTAMPDIFF(MONTH, STR_TO_DATE('2016-01-01', '%Y-%m-%d'), STR_TO_DATE('2016-05-01', '%Y-%m-%d')) + 1) month)
FROM dual;

SELECT date_format(date_add(STR_TO_DATE(CONCAT (
					'2016-01'
					,'-01'
					), '%Y-%m-%d'), INTERVAL - (
				TIMESTAMPDIFF(MONTH, STR_TO_DATE(CONCAT (
							'2016-01'
							,'-01'
							), '%Y-%m-%d'), STR_TO_DATE(CONCAT (
							'2016-05'
							,'-01'
							), '%Y-%m-%d')) + 1
				) month), '%Y-%m')

SELECT STR_TO_DATE('2016-06', '%Y-%m')
FROM dual

--环比日期�?
SELECT date_format(date_add(STR_TO_DATE(CONCAT (
					'2016-01'
					,'-01'
					), '%Y-%m-%d'), INTERVAL - 1 month), '%Y-%m')

--环比日期�?
SELECT date_format(date_add(STR_TO_DATE(CONCAT (
					'2016-01'
					,'-01'
					), '%Y-%m-%d'), INTERVAL - (
				TIMESTAMPDIFF(MONTH, STR_TO_DATE(CONCAT (
							'2016-01'
							,'-01'
							), '%Y-%m-%d'), STR_TO_DATE(CONCAT (
							'2016-05'
							,'-01'
							), '%Y-%m-%d')) + 1
				) month), '%Y-%m')
