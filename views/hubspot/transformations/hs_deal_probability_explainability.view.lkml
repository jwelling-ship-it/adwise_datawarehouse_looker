view: hs_deal_probability_explainability {
  sql_table_name: `adwise-fivetran.bigquery_ml.deal_win_explanations` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(CAST(${TABLE}.deal_id AS STRING), '-', CAST(${TABLE}.rank AS STRING)) ;;
  }

  dimension: deal_id {
    hidden: yes
    sql: ${TABLE}.deal_id ;;
  }

  dimension: rank {
    hidden: yes
    label: "Rank"
    description: "1 = most impactful feature for this deal"
    type: number
    sql: ${TABLE}.rank ;;
  }

  dimension: feature_name {
    hidden: yes
    label: "Feature (technical)"
    type: string
    sql: ${TABLE}.feature_name ;;
  }

  dimension: feature_value {
    hidden: yes
    label: "Feature Value"
    sql: ${TABLE}.feature_value ;;
  }

  dimension: feature_label {
    hidden: yes
    label: "Feature"
    description: "What aspect of the deal this factor explains"
    type: string
    sql: ${TABLE}.feature_label ;;
  }

  dimension: attribution {
    hidden: yes
    label: "Impact Score"
    description: "Shapley value — positive pushes towards win, negative towards loss"
    type: number
    value_format_name: decimal_3
    sql: ${TABLE}.attribution ;;
  }

  dimension: impact_tier {
    hidden: yes
    label: "Impact"
    description: "Human-readable impact of this feature on win probability"
    type: string
    sql:
      CASE
        WHEN ${attribution} >=  0.10 THEN "🟢 Strong positive"
        WHEN ${attribution} >=  0.03 THEN "🟡 Moderate positive"
        WHEN ${attribution} >  -0.03 THEN "⚪ Minor"
        WHEN ${attribution} >  -0.10 THEN "🟠 Moderate negative"
        ELSE                               "🔴 Strong negative"
      END ;;
    html:
      {% if value == "🟢 Strong positive" %}
        <span style="background:#1a7f37;color:#fff;padding:2px 8px;border-radius:12px;font-weight:600;font-size:12px;">{{ value }}</span>
      {% elsif value == "🟡 Moderate positive" %}
        <span style="background:#9a6700;color:#fff;padding:2px 8px;border-radius:12px;font-weight:600;font-size:12px;">{{ value }}</span>
      {% elsif value == "⚪ Minor" %}
        <span style="background:#6e7781;color:#fff;padding:2px 8px;border-radius:12px;font-weight:600;font-size:12px;">{{ value }}</span>
      {% elsif value == "🟠 Moderate negative" %}
        <span style="background:#bc4c00;color:#fff;padding:2px 8px;border-radius:12px;font-weight:600;font-size:12px;">{{ value }}</span>
      {% else %}
        <span style="background:#cf222e;color:#fff;padding:2px 8px;border-radius:12px;font-weight:600;font-size:12px;">{{ value }}</span>
      {% endif %} ;;
  }

}
