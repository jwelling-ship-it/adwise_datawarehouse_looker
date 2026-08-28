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
    description: "The month the KTO (klanttevredenheidsonderzoek / customer satisfaction survey) response was submitted"
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
    description: "The respondent's full name (first + last name)"
    sql: CONCAT(COALESCE(${TABLE}.firstname, ''), ' ', COALESCE(${TABLE}.lastname, '')) ;;
  }

  dimension: email {
    type: string
    description: "The respondent's email address"
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
    description: "Count of distinct survey respondents"
    sql: ${TABLE}.contact_id ;;
    label: "# Respondents"
  }

  measure: avg_kto {
    type: average
    sql: ${TABLE}.kto_score ;;
    label: "Avg. NPS score"
    description: "Average NPS score across all respondents. NPS = (communication + impact + recommendation) / 3."
    value_format: "0.00"
    group_label: "NPS Scores"
    drill_fields: [hs_kto.full_name, hs_customer.company_name, hs_kto.avg_communicatie, hs_kto.avg_impact, hs_kto.avg_aanbevelen]
  }

  measure: avg_communicatie {
    type: average
    sql: ${TABLE}.score_communicatie ;;
    label: "Avg. Communication & collaboration"
    description: "Average respondent score for communication & collaboration"
    value_format: "0.00"
    group_label: "NPS Scores"
  }

  measure: avg_impact {
    type: average
    sql: ${TABLE}.score_impact ;;
    label: "Avg. Impact on online objectives"
    description: "Average respondent score for impact on online objectives"
    value_format: "0.00"
    group_label: "NPS Scores"
  }

  measure: avg_aanbevelen {
    type: average
    sql: ${TABLE}.score_aanbevelen ;;
    label: "Avg. Likelihood to recommend"
    description: "Average respondent likelihood-to-recommend score (the component used to calculate NPS)"
    value_format: "0.00"
    group_label: "NPS Scores"
  }

  measure: avg_account {
    type: average
    sql: ${TABLE}.score_account_pm ;;
    label: "Avg. Account score"
    description: "Average respondent score for the account/project manager"
    value_format: "0.00"
    group_label: "Department Scores"
    drill_fields: [hs_kto.full_name, hs_customer.company_name, hs_kto.avg_account]
  }

  measure: nps_score {
    type: number
    sql: SAFE_DIVIDE(
           COUNTIF(${TABLE}.score_aanbevelen >= 9) - COUNTIF(${TABLE}.score_aanbevelen <= 6),
           COUNTIF(${TABLE}.score_aanbevelen IS NOT NULL)
         ) * 100 ;;
    label: "NPS score"
    description: "Net Promoter Score: % promoters (9-10) − % detractors (0-6). Range: -100 to +100."
    value_format: "0"
    group_label: "NPS Scores"
  }
}
