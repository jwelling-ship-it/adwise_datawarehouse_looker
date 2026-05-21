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
    description: "Maand waarin de KTO-respons is ontvangen (DATE_TRUNC op response_month)."
  }

  dimension: firstname {
    type: string
    sql: ${TABLE}.firstname ;;
    label: "Voornaam"
  }

  dimension: lastname {
    type: string
    sql: ${TABLE}.lastname ;;
    label: "Achternaam"
  }

  dimension: full_name {
    type: string
    sql: CONCAT(COALESCE(${TABLE}.firstname, ''), ' ', COALESCE(${TABLE}.lastname, '')) ;;
    label: "Naam"
    description: "Volledige naam van de contactpersoon."
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
    label: "E-mail"
  }

  dimension: company_id {
    hidden: yes
    type: string
    sql: CAST(${TABLE}.company_id AS STRING) ;;
    label: "Company ID (HubSpot)"
    description: "HubSpot company ID — gebruik voor join met company view."
  }

  # -------------------------------------------------------------------------
  # MEASURES — gemiddelden over respondenten
  # -------------------------------------------------------------------------

  measure: count_respondenten {
    type: count_distinct
    sql: ${TABLE}.contact_id ;;
    label: "Respondenten"
    description: "Aantal unieke contactpersonen dat de KTO heeft ingevuld."
  }

  measure: avg_kto {
    type: average
    sql: ${TABLE}.kto_score ;;
    label: "Gem. NPS score"
    description: "Gemiddelde NPS score over alle respondenten. NPS = (communicatie + impact + aanbevelen) / 3."
    value_format: "0.00"
    group_label: "NPS Scores"
    drill_fields: [hs_kto.full_name, hs_customer.company_name, hs_kto.avg_communicatie, hs_kto.avg_impact, hs_kto.avg_aanbevelen]
  }

  measure: avg_communicatie {
    type: average
    sql: ${TABLE}.score_communicatie ;;
    label: "Gem. Communicatie & samenwerking"
    value_format: "0.00"
    group_label: "NPS Scores"
  }

  measure: avg_impact {
    type: average
    sql: ${TABLE}.score_impact ;;
    label: "Gem. Impact online doelstellingen"
    value_format: "0.00"
    group_label: "NPS Scores"
  }

  measure: avg_aanbevelen {
    type: average
    sql: ${TABLE}.score_aanbevelen ;;
    label: "Gem. Aanbevelen (NPS vraag)"
    value_format: "0.00"
    group_label: "NPS Scores"
  }
}
