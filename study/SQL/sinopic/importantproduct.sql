SELECT
	SUM(SsTotal) amount,
	COUNT(
		DISTINCT mem_code,
		mem_province_code
	) mennum,
	'thistime' time,
	prov_code,
	lvl_id,
	commodity_code
FROM
	rep_nooil_transaction_mem_commodity_detail
WHERE
	XsDate BETWEEN '${startDate}'
AND '${endDate}'
${if(len(province)=0,'','and prov_code in ('+province+')')} 
${if(len(city)=0,'','and city_code in ('+city+')') }
${if(len(sub)=0,'','and district_code in ('+sub+')') }
${if(len(station)=0,'','and org_code in ('+station+')')}
${if(isoilccard=0,'and is_bind_oil_card=0',if(isoilccard=1,'and is_bind_oil_card=1',''))}
${if(len(mentype)=0,'',"and lvl_id in ("+mentype+")") }
and commodity_code in ( select code from rep_product_category_relation where lvl=4 
    ${if(len(producttype1)=0,'',' and par_code in ('+producttype1+')') }
    ${if(len(producttype2)=0,'','and par_code in ('+producttype2+')') }
    ${if(len(producttype3)=0,'','and par_code in ('+producttype3+')') }
  ) 
${if(len(productsearch)=0,'','and commodity_code in ('+productsearch+')') }
GROUP BY
	prov_code,
	lvl_id,
	commodity_code
UNION ALL
SELECT
	SUM(SsTotal) amount,
	COUNT(
		DISTINCT mem_code,
		mem_province_code
	) mennum,
	'lasttime' time,
	prov_code,
	lvl_id,
	commodity_code
FROM
	rep_nooil_transaction_mem_commodity_detail
WHERE
	XsDate BETWEEN CONCAT(
		LEFT ('${startDate}', 4) - 1,
		RIGHT ('${startDate}', 3)
	)
AND CONCAT(
	LEFT ('${endDate}', 4) - 1,
	RIGHT ('${endDate}', 3)
)
${if(len(province)=0,'','and prov_code in ('+province+')')} 
${if(len(city)=0,'','and city_code in ('+city+')') }
${if(len(sub)=0,'','and district_code in ('+sub+')') }
${if(len(station)=0,'','and org_code in ('+station+')')}
${if(isoilccard=0,'and is_bind_oil_card=0',if(isoilccard=1,'and is_bind_oil_card=1',''))}
${if(len(mentype)=0,'',"and lvl_id in ("+mentype+")") }
and commodity_code in ( select code from rep_product_category_relation where lvl=4 
    ${if(len(producttype1)=0,'',' and par_code in ('+producttype1+')') }
    ${if(len(producttype2)=0,'','and par_code in ('+producttype2+')') }
    ${if(len(producttype3)=0,'','and par_code in ('+producttype3+')') }
  ) 
${if(len(productsearch)=0,'','and commodity_code in ('+productsearch+')') }
GROUP BY
	prov_code,
	lvl_id,
	commodity_code
UNION ALL
SELECT
	SUM(SsTotal) amount,
	COUNT(
		DISTINCT mem_code,
		mem_province_code
	) mennum,
	'rolltime' time,
	prov_code,
	lvl_id,
	commodity_code
FROM
	rep_nooil_transaction_mem_commodity_detail
WHERE
	XsDate BETWEEN date_format(
		date_add(
			STR_TO_DATE(
				concat('${startDate}', '-01'),
				'%Y-%m-%d'
			),
			INTERVAL - (
				TIMESTAMPDIFF(
					MONTH,
					STR_TO_DATE(
						concat('${startDate}', '-01'),
						'%Y-%m-%d'
					),
					STR_TO_DATE(
						concat('${endDate}', '-01'),
						'%Y-%m-%d'
					)
				) + 1
			) MONTH
		),
		'%Y-%m'
	)
AND date_format(
	date_add(
		STR_TO_DATE(
			concat('${startDate}', '-01'),
			'%Y-%m-%d'
		),
		INTERVAL - 1 MONTH
	),
	'%Y-%m'
)

${if(len(province)=0,'','and prov_code in ('+province+')')} 
${if(len(city)=0,'','and city_code in ('+city+')') }
${if(len(sub)=0,'','and district_code in ('+sub+')') }
${if(len(station)=0,'','and org_code in ('+station+')')}
${if(isoilccard=0,'and is_bind_oil_card=0',if(isoilccard=1,'and is_bind_oil_card=1',''))}
${if(len(mentype)=0,'',"and lvl_id in ("+mentype+")") }
and commodity_code in ( select code from rep_product_category_relation where lvl=4 
    ${if(len(producttype1)=0,'',' and par_code in ('+producttype1+')') }
    ${if(len(producttype2)=0,'','and par_code in ('+producttype2+')') }
    ${if(len(producttype3)=0,'','and par_code in ('+producttype3+')') }
  ) 
${if(len(productsearch)=0,'','and commodity_code in ('+productsearch+')') }
GROUP BY
	prov_code,
	lvl_id,
	commodity_code