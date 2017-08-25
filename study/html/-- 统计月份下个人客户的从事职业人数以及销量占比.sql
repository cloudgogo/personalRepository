-- 统计月份下个人客户的从事职业人数以及销量占比
SELECT t1.sale_num/t2.sale_num,
 case when t1.professional is null then 0
     else
	t1.professional
	end as industy  from (
SELECT
  sum(r.sale_num) sale_num,
  c.professional
FROM
	rep_summary_cust_month r,
     c_customer_personal c
WHERE
	r.cust_type = 1
and r.customer_id=c.id
and r.rep_date<='${p_period}'
group by c.professional) t1,

(SELECT
  sum(r.sale_num) sale_num
FROM
	rep_summary_cust_month r,
  c_customer_personal c
WHERE
	r.cust_type = 1
and r.customer_id=c.id
-- and c.professional is not null
and r.rep_date<='${p_period}') t2
