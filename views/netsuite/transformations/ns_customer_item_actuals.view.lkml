view: ns_customer_item_actuals {
  sql_table_name: `adwise-fivetran.adwise_datawarehouse.fact_customer_item_actuals_monthly` ;;

  dimension_group: row {
    type: time
    datatype: date
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.row_date ;;
  }

  dimension: customer_id {
    hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension: item_id {
    hidden: yes
    sql: ${TABLE}.item_id ;;
  }

  dimension: project_id {
    hidden: yes
    sql: ${TABLE}.project_id ;;
  }

  dimension: department_id {
    hidden: yes
    sql: ${TABLE}.department_id ;;
  }

  measure: revenue {
    label: "Revenue"
    type: sum
    sql: ${TABLE}.revenue ;;
    value_format_name: eur
  }

  measure: cogs {
    label: "COGS"
    type: sum
    sql: ${TABLE}.cogs ;;
    value_format_name: eur
  }

  measure: gross_margin {
    label: "Gross margin"
    type: sum
    sql: ${TABLE}.gross_margin ;;
    value_format_name: eur
  }

  measure: labor_gross_margin {
    label: "Labor gross margin"
    type: sum
    sql: ${TABLE}.labor_gm ;;
    value_format_name: eur
  }

  measure: labor_cogs {
    label: "Labor COGS"
    type: sum
    sql: ${TABLE}.labor_cogs ;;
    value_format_name: eur
  }

  measure: labor_revenue {
    label: "Labor revenue"
    type: sum
    sql: ${TABLE}.labor_revenue;;
    value_format_name: eur
    }
  }
