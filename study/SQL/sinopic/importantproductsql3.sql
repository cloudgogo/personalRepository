select resultmap.prov_code,
       resultmap.lvl_id,
       resultmap.CODE,
       resultmap.NAME,
       resultmap.thisamount thisamount,
       case
         when resultmap.thisamount = 0 or resultmap.lastamount = 0 or
              resultmap.thisamount = null or resultmap.lastamount = null then
          null
         else
          resultmap.thisamount / resultmap.lastamount
       end lastamountprcentage,
       case
         when resultmap.thisamount = 0 or resultmap.rollamount = 0 or
              resultmap.thisamount = null or resultmap.rollamount = null then
          null
         else
          resultmap.thisamount / resultmap.rollamount
       end lastamountprcentage,
       resultmap.thismennum thismennum,
       case
         when resultmap.thismennum = 0 or resultmap.lastmennum = 0 or
              resultmap.thismennum = null or resultmap.lastmennum = null then
          null
         else
          resultmap.thismennum / resultmap.lastmennum
       end lastmennumprcentage,
       case
         when resultmap.thismennum = 0 or resultmap.rollmennum = 0 or
              resultmap.thismennum = null or resultmap.rollmennum = null then
          null
         else
          resultmap.thismennum / resultmap.rollmennum
       end lastmennumprcentage

  from (
        
        SELECT result.prov_code,
                result.lvl_id,
                ci. CODE,
                ci. NAME,
                sum(thisamount) thisamount,
                sum(lastamount) lastamount,
                sum(rollamount) rollamount,
                sum(thismennum) thismennum,
                sum(lastmennum) lastmennum,
                sum(rollmennum) rollmennum
          FROM (SELECT map.prov_code,
                        map.lvl_id,
                        map.commodity_code,
                        sum(CASE
                              WHEN map.time = 'thistime' THEN
                               amount
                              ELSE
                               NULL
                            END) thisamount,
                        sum(CASE
                              WHEN map.time = 'lasttime' THEN
                               amount
                              ELSE
                               NULL
                            END) lastamount,
                        sum(CASE
                              WHEN map.time = 'rolltime' THEN
                               amount
                              ELSE
                               NULL
                            END) rollamount,
                        sum(CASE
                              WHEN map.time = 'thistime' THEN
                               mennum
                              ELSE
                               NULL
                            END) thismennum,
                        sum(CASE
                              WHEN map.time = 'lasttime' THEN
                               mennum
                              ELSE
                               NULL
                            END) lastmennum,
                        sum(CASE
                              WHEN map.time = 'rolltime' THEN
                               mennum
                              ELSE
                               NULL
                            END) rollmennum
                   FROM (SELECT SUM(SsTotal) amount,
                                COUNT(DISTINCT mem_code, mem_province_code) mennum,
                                'thistime' time,
                                prov_code,
                                lvl_id,
                                commodity_code
                           FROM rep_nooil_transaction_mem_commodity_detail
                          WHERE XsDate BETWEEN '${startDate}' AND '${endDate}'
                         
                          ${if(len(province) = 0,
                                     '',
                                     'and prov_code in (' + province + ')') }
                          ${if(len(city) = 0,
                                     '',
                                     'and city_code in (' + city + ')') }
                          ${if(len(sub) = 0,
                                     '',
                                     'and district_code in (' + sub + ')') }
                          ${if(len(station) = 0,
                                     '',
                                     'and org_code in (' + station + ')') }
                          ${if(isoilccard = 0,
                                     'and is_bind_oil_card=0',
                                     if(isoilccard = 1,
                                        'and is_bind_oil_card=1',
                                        '')) }
                          ${if(len(mentype) = 0,
                                     '',
                                     "and lvl_id in (" + mentype + ")")
                          }
                            and commodity_code in
                                (select code
                                   from rep_product_category_relation
                                  where lvl = 4
                                  ${if(len(producttype1) = 0,
                                             '',
                                             ' and par_code in (' + producttype1 + ')') }
                                  ${if(len(producttype2) = 0,
                                             '',
                                             'and par_code in (' + producttype2 + ')') }
                                  ${if(len(producttype3) = 0,
                                             '',
                                             'and par_code in (' + producttype3 + ')') })
                          ${if(len(productsearch) = 0,
                                     '',
                                     'and commodity_code in (' + productsearch + ')') }
                          GROUP BY prov_code, lvl_id, commodity_code
                         UNION ALL
                         SELECT SUM(SsTotal) amount,
                                COUNT(DISTINCT mem_code, mem_province_code) mennum,
                                'lasttime' time,
                                prov_code,
                                lvl_id,
                                commodity_code
                           FROM rep_nooil_transaction_mem_commodity_detail
                          WHERE XsDate BETWEEN
                                CONCAT(LEFT('${startDate}', 4) - 1,
                                       RIGHT('${startDate}', 3)) AND
                                CONCAT(LEFT('${endDate}', 4) - 1,
                                       RIGHT('${endDate}', 3))
                          ${if(len(province) = 0,
                                     '',
                                     'and prov_code in (' + province + ')') }
                          ${if(len(city) = 0,
                                     '',
                                     'and city_code in (' + city + ')') }
                          ${if(len(sub) = 0,
                                     '',
                                     'and district_code in (' + sub + ')') }
                          ${if(len(station) = 0,
                                     '',
                                     'and org_code in (' + station + ')') }
                          ${if(isoilccard = 0,
                                     'and is_bind_oil_card=0',
                                     if(isoilccard = 1,
                                        'and is_bind_oil_card=1',
                                        '')) }
                          ${if(len(mentype) = 0,
                                     '',
                                     "and lvl_id in (" + mentype + ")")
                          }
                            and commodity_code in
                                (select code
                                   from rep_product_category_relation
                                  where lvl = 4
                                  ${if(len(producttype1) = 0,
                                             '',
                                             ' and par_code in (' + producttype1 + ')') }
                                  ${if(len(producttype2) = 0,
                                             '',
                                             'and par_code in (' + producttype2 + ')') }
                                  ${if(len(producttype3) = 0,
                                             '',
                                             'and par_code in (' + producttype3 + ')') })
                          ${if(len(productsearch) = 0,
                                     '',
                                     'and commodity_code in (' + productsearch + ')') }
                          GROUP BY prov_code, lvl_id, commodity_code
                         UNION ALL
                         SELECT SUM(SsTotal) amount,
                                COUNT(DISTINCT mem_code, mem_province_code) mennum,
                                'rolltime' time,
                                prov_code,
                                lvl_id,
                                commodity_code
                           FROM rep_nooil_transaction_mem_commodity_detail
                          WHERE XsDate BETWEEN
                                date_format(date_add(STR_TO_DATE(concat('${startDate}',
                                                                        '-01'),
                                                                 '%Y-%m-%d'),
                                                     INTERVAL -
                                                     (TIMESTAMPDIFF(MONTH,
                                                                    STR_TO_DATE(concat('${startDate}',
                                                                                       '-01'),
                                                                                '%Y-%m-%d'),
                                                                    STR_TO_DATE(concat('${endDate}',
                                                                                       '-01'),
                                                                                '%Y-%m-%d')) + 1)
                                                     MONTH),
                                            '%Y-%m') AND
                                date_format(date_add(STR_TO_DATE(concat('${startDate}',
                                                                        '-01'),
                                                                 '%Y-%m-%d'),
                                                     INTERVAL - 1 MONTH),
                                            '%Y-%m')
                          ${if(len(province) = 0,
                                     '',
                                     'and prov_code in (' + province + ')') }
                          ${if(len(city) = 0,
                                     '',
                                     'and city_code in (' + city + ')') }
                          ${if(len(sub) = 0,
                                     '',
                                     'and district_code in (' + sub + ')') }
                          ${if(len(station) = 0,
                                     '',
                                     'and org_code in (' + station + ')') }
                          ${if(isoilccard = 0,
                                     'and is_bind_oil_card=0',
                                     if(isoilccard = 1,
                                        'and is_bind_oil_card=1',
                                        '')) }
                          ${if(len(mentype) = 0,
                                     '',
                                     "and lvl_id in (" + mentype + ")")
                          }
                            and commodity_code in
                                (select code
                                   from rep_product_category_relation
                                  where lvl = 4
                                  ${if(len(producttype1) = 0,
                                             '',
                                             ' and par_code in (' + producttype1 + ')') }
                                  ${if(len(producttype2) = 0,
                                             '',
                                             'and par_code in (' + producttype2 + ')') }
                                  ${if(len(producttype3) = 0,
                                             '',
                                             'and par_code in (' + producttype3 + ')') })
                          ${if(len(productsearch) = 0,
                                     '',
                                     'and commodity_code in (' + productsearch + ')') }
                          GROUP BY prov_code, lvl_id, commodity_code) map
                  GROUP BY map.prov_code, map.lvl_id, map.commodity_code) result,
                rep_product_category_relation cr,
                rep_product_category_info ci
         WHERE cr. CODE = result.commodity_code
           AND cr.par_code = ci.
         CODE
           AND ci.lvl =
               ${if(len(producttype3) != 0,
                    '3',
                    if(len(producttype2) != 0,
                       '2',
                       if(len(producttype1) != 0, '1', '1'))) }
         GROUP BY result.prov_code, result.lvl_id, ci. CODE, ci. NAME) resultmap
