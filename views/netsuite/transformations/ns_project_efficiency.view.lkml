view: ns_project_efficiency {
  sql_table_name:`adwise-fivetran.adwise_datawarehouse.fact_project_efficiency`;;


  dimension_group: start {
    description: "Start date of the project"
    type: time
    datatype: date
    timeframes: [date, month, year]
    sql: ${TABLE}.project_start ;;
  }

  dimension_group: end {
    description: "End date of the project"
    type: time
    datatype: date
    timeframes: [date, month, year]
    sql: ${TABLE}.project_end ;;
  }

  dimension: project_id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.project_id ;;
  }

  dimension: project_name {
    label: "Project"
    description: "The name of the project"
    type: string
    sql: ${TABLE}.project_name ;;
  }

  dimension: is_complete {
    description: "Whether the project has finished"
    type: yesno
    sql: ${TABLE}.data_complete_flag ;;
  }

  measure: total_project_cost_price {
    type: sum
    label: "Cost price project (total)"
    description: "Total cost price of the project from NetSuite SO-rows"
    sql: ${TABLE}.total_project_cost_price ;;
    value_format_name: eur
  }

  measure: total_hours_ra {
    label: "Hours (ra)"
    description: "Total hours allocated to the project"
    type: sum
    sql: ${TABLE}.total_hours_ra ;;
    value_format_name: decimal_1
  }

  measure: total_allocated_value {
    label: "Allocated value"
    description: "Hours (ra) x HRate"
    type: sum
    sql: ${TABLE}.total_revenue_allocated ;;
    value_format_name: eur
  }

  measure: total_hours_ra_previous_year {
    label: "Hours (ra) - Previous year"
    description: "Total allocated hours on finished projects in the previous year"
    type: period_over_period
    based_on: total_hours_ra
    based_on_time: end_year
    period: year
    kind: previous
    value_format_name: decimal_1
  }

  measure: total_allocated_value_previous_year {
    label: "Allocated value - Previous year"
    description: "Total allocated value on finished projects in the previous year (Hours x HRate)"
    type: period_over_period
    based_on: total_allocated_value
    based_on_time: end_year
    period: year
    kind: previous
    value_format_name: eur
  }

  measure: total_cost_price_previous_year {
    label: "Cost price project (total) - previous year"
    description: "Total cost price on projects that finished in the previous year"
    type: period_over_period
    based_on: total_project_cost_price
    based_on_time: end_year
    period: year
    kind: previous
    value_format_name: eur
  }

}
