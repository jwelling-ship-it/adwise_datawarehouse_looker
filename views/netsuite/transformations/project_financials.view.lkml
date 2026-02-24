view: project_financials {
  sql_table_name: `adwise-fivetran.adwise_datawarehouse.project_financials`;;

  dimension_group: row {
    type: time
    datatype: date
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.row_date ;;
  }

  dimension: project_id {
    hidden: yes
    sql: ${TABLE}.project_id ;;
  }

  dimension: customer_id {
    hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  measure: revenue {
    type: sum
    sql: ${TABLE}.revenue ;;
    value_format_name: eur
  }

  measure: project_costs {
    label: "Project cost"
    type: sum
    sql: ${TABLE}.internal_costs ;;
    value_format_name: eur
  }

  measure: freelance_costs {
    label: "Freelance cost"
    type: sum
    sql: ${TABLE}.external_costs ;;
    value_format_name: eur
  }

  measure: net_revenue {
    label: "Net revenue"
    type: number
    sql: ${revenue} - ${project_costs} - ${freelance_costs} ;;
  }




  }
