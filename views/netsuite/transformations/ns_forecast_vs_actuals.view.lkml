view: ns_forecast_vs_actuals {
  sql_table_name: `adwise-fivetran.adwise_datawarehouse.fact_forecast_vs_actuals_monthly` ;;

  # -------------------------------------------------------------------------
  # DIMENSIONS
  # -------------------------------------------------------------------------

  dimension_group: row {
    type: time
    timeframes: [date, month, quarter, year]
    datatype: date
    sql: ${TABLE}.row_date ;;
    label: "Row"
  }

  dimension: customer_id {
    hidden: yes
    type: number
    sql: ${TABLE}.customer_id ;;
    value_format_name: id
  }

  dimension: department_id {
    hidden: yes
    type: number
    sql: ${TABLE}.department_id ;;
    value_format_name: id
  }

  # -------------------------------------------------------------------------
  # MEASURES — Forecast (Employee)
  # -------------------------------------------------------------------------

  measure: total_rev_a {
    type: sum
    sql: ${TABLE}.rev_a ;;
    label: "Forecast Revenue"
    description: "Gealloceerde omzet uit employee forecast (milestones + contracts)"
    value_format_name: eur
  }

  measure: total_nrev_a {
    type: sum
    sql: ${TABLE}.nrev_a ;;
    label: "Forecast GM"
    description: "Gealloceerde bruto marge uit employee forecast (milestones + contracts - costs)"
    value_format_name: eur
  }

  measure: total_hours_ra {
    type: sum
    sql: ${TABLE}.hours_ra ;;
    label: "Hours (RA)"
    description: "Gealloceerde uren"
    value_format_name: decimal_1
  }

  # -------------------------------------------------------------------------
  # MEASURES — Actuals
  # -------------------------------------------------------------------------

  measure: total_labor_revenue {
    type: sum
    sql: ${TABLE}.labor_revenue ;;
    label: "Actuals Labor Revenue"
    value_format_name: eur
  }

  measure: total_labor_cogs {
    type: sum
    sql: ${TABLE}.labor_cogs ;;
    label: "Actuals Labor COGS"
    value_format_name: eur
  }

  measure: total_labor_gm {
    type: sum
    sql: ${TABLE}.labor_gm ;;
    label: "Actuals Labor GM"
    value_format_name: eur
  }

  measure: total_revenue {
    type: sum
    sql: ${TABLE}.total_revenue ;;
    label: "Actuals Revenue (totaal)"
    description: "Totale omzet incl. non-labor"
    value_format_name: eur
  }

  measure: total_gm {
    type: sum
    sql: ${TABLE}.total_gm ;;
    label: "Actuals GM (totaal)"
    description: "Totale bruto marge incl. non-labor"
    value_format_name: eur
  }

  # -------------------------------------------------------------------------
  # MEASURES — Vergelijkingen
  # -------------------------------------------------------------------------

  measure: verschil_rev {
    type: sum
    sql: ${TABLE}.verschil_rev ;;
    label: "Verschil Revenue"
    description: "Forecast Rev - Actuals Labor Revenue"
    value_format_name: eur
  }

  measure: verschil_gm {
    type: sum
    sql: ${TABLE}.verschil_gm ;;
    label: "Verschil GM"
    description: "Forecast GM - Actuals Labor GM"
    value_format_name: eur
  }

  measure: coverage_rev_pct {
    type: number
    sql: SAFE_DIVIDE(${total_rev_a}, NULLIF(${total_labor_revenue}, 0)) * 100 ;;
    label: "Coverage Revenue %"
    description: "Forecast Rev / Actuals Labor Rev × 100"
    value_format: "0.0\"%\""
  }

  measure: coverage_gm_pct {
    type: number
    sql: SAFE_DIVIDE(${total_nrev_a}, NULLIF(${total_labor_gm}, 0)) * 100 ;;
    label: "Coverage GM %"
    description: "Forecast GM / Actuals Labor GM × 100"
    value_format: "0.0\"%\""
  }
}
