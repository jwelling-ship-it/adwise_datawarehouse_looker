view: hs_contact_lifecycle {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.contact_funnel_stages`;;

  dimension: contact_lifecycle_unique_id {
    primary_key: yes
    type: string
    sql: CONCAT(${TABLE}.contact_id, '-', ${TABLE}.email) ;;
    hidden: yes
  }

  dimension: contact_id {
    sql: ${TABLE}.contact_id ;;
    link: {
      label: "Open in HubSpot"
      url: "https://app.hubspot.com/contacts/139703519/record/0-1/{{ value }}"
    }
  }

  dimension_group: row {
    type: time
    datatype: date
    timeframes: [month, quarter, year]
    sql: ${TABLE}.row_date ;;
  }

  dimension: stage {
    sql: ${TABLE}.funnel_stage ;;
  }

  dimension: company_id {
    hidden: yes
    sql: ${TABLE}.company_id ;;
  }

  dimension: source {
    sql: ${TABLE}.lead_source ;;
  }

  dimension: is_change {
    type: yesno
    description: "Whether or not stage changed this month"
    sql: ${TABLE}.is_stage_change ;;
  }


  measure: count {
    type: count_distinct
    sql: ${contact_id} ;;
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.source]
  }

  measure: mql_count {
    type: count_distinct
    label: "# MQL"
    sql: ${contact_id};;
    filters: [stage: "MQL"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company, hs_contact_lifecycle.source]
  }

  measure: sql_count {
    type: count_distinct
    label: "# SQL"
    sql: ${contact_id};;
    filters: [stage: "SQL"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company, hs_contact_lifecycle.source]
  }

}
