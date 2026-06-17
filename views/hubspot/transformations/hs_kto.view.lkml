view: hs_kto {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.kto_monthly` ;;

  # -------------------------------------------------------------------------
  # DIMENSIONS — identifiers & attributen
  # -------------------------------------------------------------------------

  dimension: contact_id {
    type: string
    sql: CAST(${TABLE}.contact_id AS STRING) ;;
    label: "Contact ID"
    primary_key: yes
    hidden: yes
  }

  dimension_group: response {
    type: time
    timeframes: [date, month, quarter, year]
    datatype: date
    sql: ${TABLE}.response_month ;;
  }

  dimension: firstname {
    type: string
    sql: ${TABLE}.firstname ;;
    hidden: yes
  }

  dimension: lastname {
    type: string
    sql: ${TABLE}.lastname ;;
    hidden: yes
  }

  dimension: full_name {
    type: string
    sql: CONCAT(COALESCE(${TABLE}.firstname, ''), ' ', COALESCE(${TABLE}.lastname, '')) ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: company_id {
    hidden: yes
    type: string
    sql: CAST(${TABLE}.company_id AS STRING) ;;
    label: "Company ID (HubSpot)"
  }

  # -------------------------------------------------------------------------
  # MEASURES — gemiddelden over respondenten
  # -------------------------------------------------------------------------

  measure: count_respondenten {
    type: count_distinct
    sql: ${TABLE}.contact_id ;;
    label: "# Respondents"
  }

  measure: avg_kto {
    type: average
    sql: ${TABLE}.kto_score ;;
    label: "Avg. NPS score"
    description: "Average NPS score across alle respondenten. NPS = (communicatie + impact + aanbeveling) / 3."
    value_format: "0.00"
    group_label: "NPS Scores"
    drill_fields: [hs_kto.full_name, hs_customer.company_name, hs_kto.avg_communicatie, hs_kto.avg_impact, hs_kto.avg_aanbevelen]
  }

  measure: avg_communicatie {
    type: average
    sql: ${TABLE}.score_communicatie ;;
    label: "Avg. Communicatie & samenwerking"
    value_format: "0.00"
    group_label: "NPS Scores"
  }

  measure: avg_impact {
    type: average
    sql: ${TABLE}.score_impact ;;
    label: "Avg. Impact online doelstellingen"
    value_format: "0.00"
    group_label: "NPS Scores"
  }

  measure: avg_aanbevelen {
    type: average
    sql: ${TABLE}.score_aanbevelen ;;
    label: "Avg. Aanbevelen"
    value_format: "0.00"
    group_label: "NPS Scores"
  }

  measure: avg_account {
    type: average
    sql: ${TABLE}.score_account_pm ;;
    label: "Avg. Account score"
    value_format: "0.00"
    group_label: "Department Scores"
    drill_fields: [hs_kto.full_name, hs_customer.company_name, hs_kto.avg_account]
  }
}
