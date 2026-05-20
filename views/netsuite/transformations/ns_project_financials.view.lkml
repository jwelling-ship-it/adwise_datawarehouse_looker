view: ns_project_financials {
  sql_table_name: `adwise-fivetran.adwise_datawarehouse.fact_project_financials_monthly`;;

  dimension_group: row {
    description: "The date of the project financial entry"
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

  dimension: subsidiary_id {
    hidden: yes
    sql: ${TABLE}.subsidiary_id ;;
  }

  measure: revenue {
    description: "Revenue on projects"
    type: sum
    sql: ${TABLE}.revenue ;;
    value_format_name: eur
  }

  measure: internal_costs {
    label: "Internal cost"
    description: "The internal costs on projects (project cost budget from NetSuite)"
    type: sum
    sql: ${TABLE}.internal_costs ;;
    value_format_name: eur
  }

  measure: freelance_costs {
    label: "Freelance cost"
    description: "The cost of freelancers on projects"
    type: sum
    sql: ${TABLE}.external_costs ;;
    value_format_name: eur
  }

  measure: net_revenue {
    label: "Net revenue"
    description: "Revenue after deducting internal and freelance costs on projects"
    type: number
    sql: ${revenue} - ${internal_costs} - ${freelance_costs} ;;
    value_format_name: eur
  }

  measure: net_revenue_mom {
    label: "Net revenue (MoM %)"
    type: period_over_period
    description: "Net revenue compared to last month in percentage"
    based_on: net_revenue
    based_on_time: row_month
    period: month
    kind: relative_change
    value_format_name: percent_0
  }

  measure: net_revenue_yoy {
    label: "Net revenue (YoY %)"
    type: period_over_period
    description: "Net revenue compared to last year in percentage"
    based_on: net_revenue
    based_on_time: row_year
    period: year
    kind: relative_change
    value_format_name: percent_0
  }

  measure: count {
    label: "# Customers"
    type: count_distinct
    sql: ${customer_id} ;;
  }




  }
