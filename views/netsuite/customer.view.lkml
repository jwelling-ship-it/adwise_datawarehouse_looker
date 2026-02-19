view: customer {
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
    sql: ${TABLE}.salesrep ;;
  }

  dimension: customer_name {
    label: "Customer"
    sql: ${TABLE}.companyname ;;
  }

   }
