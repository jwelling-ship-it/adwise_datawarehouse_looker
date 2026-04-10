view: hs_deal_probability_explainability {
  sql_table_name: `adwise-fivetran.bigquery_ml.deal_win_explanations` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(CAST(${TABLE}.deal_id AS STRING), '-', CAST(${TABLE}.rank AS STRING)) ;;
  }

  dimension: deal_id {
    type: number
    hidden: yes
    sql: ${TABLE}.deal_id ;;
  }

  dimension: rank {
    label: "Rank"
    description: "1 = most impactful feature for this deal"
    type: number
    sql: ${TABLE}.rank ;;
  }

  dimension: feature_name {
    label: "Feature (technical)"
    hidden: yes
    type: string
    sql: ${TABLE}.feature_name ;;
  }

  dimension: feature_label {
    label: "Feature"
    description: "What aspect of the deal this factor explains"
    type: string
    sql: ${TABLE}.feature_label ;;
  }

  dimension: attribution {
    label: "Impact Score"
    description: "Shapley value — positive pushes towards win, negative towards loss"
    type: number
    value_format_name: decimal_3
    sql: ${TABLE}.attribution ;;
  }
}
