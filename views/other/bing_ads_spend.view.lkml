view: bing_ads_spend {
  sql_table_name: `adwise-fivetran.adwise_datawarehouse.fact_bing_ads_spend_monthly` ;;

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

  dimension: account_id {
    hidden: yes
    type: number
    sql: ${TABLE}.account_id ;;
    label: "Account ID"
    value_format_name: id
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
    label: "Account"
  }

  dimension: currency_code {
    type: string
    sql: ${TABLE}.currency_code ;;
    label: "Currency"
    hidden: yes
  }

  # -------------------------------------------------------------------------
  # MEASURES
  # -------------------------------------------------------------------------

  measure: total_spend {
    type: sum
    sql: ${TABLE}.spend ;;
    label: "Spend"
    value_format_name: eur
  }

  # -------------------------------------------------------------------------
  # PAYOUT — gebaseerd op kwartaal spend tiers
  # 4% bij <500K, 5% bij ≥700K, 6% bij ≥900K
  # -------------------------------------------------------------------------

  measure: payout_percentage {
    type: number
    sql:
      CASE
        WHEN ${total_spend} >= 900000 THEN 0.06
        WHEN ${total_spend} >= 700000 THEN 0.05
        ELSE 0.04
      END ;;
    label: "Payout %"
    description: "4% bij <700K, 5% bij ≥700K, 6% bij ≥900K (per kwartaal)"
    value_format_name: percent_0
  }

  measure: payout_amount {
    type: number
    sql: ${total_spend} * ${payout_percentage} ;;
    label: "Payout"
    description: "Spend × payout percentage. Filter op kwartaal voor correcte berekening."
    value_format_name: eur
  }
}
