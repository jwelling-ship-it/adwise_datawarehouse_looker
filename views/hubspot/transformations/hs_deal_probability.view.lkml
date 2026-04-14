view: hs_deal_probability {
  sql_table_name: `adwise-fivetran.bigquery_ml.deal_win_scores`;;

  dimension: deal_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.deal_id ;;
  }

  measure: probability  {
    type: max
    description: "The probability of the deal being won in its close month"
    sql: ${TABLE}.win_probability;;
    value_format_name: percent_1
    drill_fields: [
      hs_deal_probability.deal_id,
      hs_deal_probability_explainability.feature_label,
      hs_deal_probability_explainability.feature_value,
      hs_deal_probability_explainability.attribution,
      hs_deal_probability_explainability.impact_tier
    ]
  }

  dimension: checkup_label {
    label: "Checkup"
    description: "Flags deals where ML probability significantly diverges from HubSpot's stage probability"
    type: string
    sql:
    CASE
      WHEN ABS(${TABLE}.win_probability - ${hs_deal.probability}) <= 0.10
        THEN '✅ Aligned'
      WHEN ${TABLE}.win_probability - ${hs_deal.probability} < -0.20
        THEN '🔴 Urgent Review'
      WHEN ${TABLE}.win_probability - ${hs_deal.probability} BETWEEN -0.20 AND -0.10
        THEN '⚠️ At Risk'
      WHEN ${TABLE}.win_probability - ${hs_deal.probability} > 0.20
        THEN '💎 Hidden Gem'
      WHEN ${TABLE}.win_probability - ${hs_deal.probability} BETWEEN 0.10 AND 0.20
        THEN '👀 Undervalued'
    END ;;
  }





}
