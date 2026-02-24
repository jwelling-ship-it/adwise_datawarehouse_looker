view: deal_financials {
sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.deal_lines` ;;

dimension: deal_id {
  hidden: yes
  sql: ${TABLE}.dealid ;;
}

dimension: item_id {
  hidden: yes
  sql: ${TABLE}.itemid ;;
}

dimension: company_id {
  hidden: yes
  sql: ${TABLE}.companyid ;;
}


 }
