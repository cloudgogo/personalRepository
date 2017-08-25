-- 统计月份下单位客户的从事职业人数以及销量占比
SELECT
	t1.sale_num / t2.sale_num,
	case when t1.industry is null then 0
     else
	t1.industry
	end as industy
FROM
	(
		SELECT
			sum(r.sale_num) sale_num,
			c.industry
		FROM
			rep_summary_cust_month r,
			c_customer_company c
		WHERE
			r.cust_type = 0
		AND r.customer_id = c.id
		AND r.rep_date <= '${p_period}'
		GROUP BY
			c.industry
	) t1,
	(
		SELECT
			sum(r.sale_num) sale_num
		FROM
			rep_summary_cust_month r,
			c_customer_company c
		WHERE
			r.cust_type = 0
		AND r.customer_id = c.id
		AND r.rep_date <= '${p_period}'
	) t2