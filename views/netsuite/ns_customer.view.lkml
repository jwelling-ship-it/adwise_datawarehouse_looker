view: ns_customer {
  sql_table_name: `adwise-fivetran.fvt_netsuite2_datawarehouse.customer` ;;

  dimension: id {
    label: "Customer ID"
    description: "The NetSuite customer record ID"
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
    value_format_name: id
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
    description: "The name of the customer"
    sql: ${TABLE}.companyname ;;
  }

  dimension: industry {
    label: "Industry"
    description: "The industry the customer operates in"
    sql: ${TABLE}.industry ;;
  }

  measure: count {
    type: count_distinct
    description: "Count of distinct customers"
    sql: ${id} ;;
  }

   }
