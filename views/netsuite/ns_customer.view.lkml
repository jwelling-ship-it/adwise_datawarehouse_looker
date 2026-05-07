view: ns_customer {
  sql_table_name: `adwise-fivetran.fvt_netsuite2_datawarehouse.customer` ;;

  dimension: id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: industry_id {
    hidden: yes
    sql: ${TABLE}.industry ;;
  }

  dimension: salesrep_id {
    hidden: yes
    sql: ${TABLE}.salesrep_local ;;
  }

  dimension: customer_name {
    label: "Customer"
    sql: ${TABLE}.companyname ;;
  }

  measure: count {
    type: count_distinct
    sql: ${id} ;;
  }

   }
