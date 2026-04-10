view: hs_deal_probability {
  sql_table_name: `adwise-fivetran.bigquery_ml.deal_win_scores`;;

  dimension: deal_id {
    primary_key: yes
    sql: ${TABLE}.deal_id ;;
  }

  measure: probability  {
    type: max
    sql: ${TABLE}.win_probability;;
    value_format_name: percent_1
    drill_fields: [
      hs_deal_probability_explainability.feature_label,
      hs_deal_probability_explainability.attribution
    ]
  }

  measure: weighted_pipeline {
    type: sum
    sql: ${TABLE}.expected_value;;
    value_format_name: eur_0
  }



}
