view: hs_contact {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.contact` ;;

  dimension: id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [date, month, quarter, year]
    label: "Created"
    description: "The date this contact was created in HubSpot"
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    description: "The contact's email address"
    sql: ${TABLE}.email ;;
  }

  dimension: name {
    description: "The contact's full name"
    sql: ${TABLE}.name ;;
    link: {
      label: "Open in HubSpot"
      url: "https://app.hubspot.com/contacts/139703519/record/0-1/{{ id }}"
    }
  }

  dimension: stage {
    description: "The current HubSpot lifecycle stage of the contact"
    sql: ${TABLE}.lifecyclestage ;;
  }

  dimension: source {
    description: "The original lead source of the contact"
    sql: ${TABLE}.lead_source ;;
  }

  dimension: company {
    description: "The name of the company the contact belongs to"
    sql: ${TABLE}.companyname ;;
  }

  dimension: leadscore {
    description: "The contact's HubSpot leadscore (engagement + fit)"
    sql: ${TABLE}.leadscore ;;
  }

  dimension: leadscore_category {
    order_by_field: leadscore_category_sort_order
    type: string
    label: "Leadscore category"
    description: "Cold: ≤25 (incl. 0 and negative scores), Warming: 26–50, Warm: 51–75, Hot: ≥76 (no upper bound, leadscore = engagement + fit and can exceed 100, up to 161 observed). 'Unknown' = no leadscore (NULL). Note: ~66% of all contacts have a score of exactly 0 — this is presumably 'not yet scored', not a genuine neutral score (not confirmed with whoever manages the HubSpot scoring)."
    sql: CASE
      WHEN ${TABLE}.leadscore IS NULL THEN 'Unknown'
      WHEN ${TABLE}.leadscore <= 25 THEN 'Cold'
      WHEN ${TABLE}.leadscore BETWEEN 26 AND 50 THEN 'Warming'
      WHEN ${TABLE}.leadscore BETWEEN 51 AND 75 THEN 'Warm'
      WHEN ${TABLE}.leadscore >= 76 THEN 'Hot'
      ELSE 'Other'
    END ;;
  }

  dimension: leadscore_category_sort_order {
    hidden: yes
    type: number
    sql: CASE ${leadscore_category}
      WHEN 'Cold' THEN 1 WHEN 'Warming' THEN 2 WHEN 'Warm' THEN 3 WHEN 'Hot' THEN 4 WHEN 'Other' THEN 5 ELSE 6
    END ;;
  }

  measure: average_leadscore {
    type: average
    label: "Avg Leadscore"
    description: "Average HubSpot leadscore across contacts"
    sql: ${leadscore} ;;
    value_format_name: decimal_0
  }

  measure: count {
    type: count_distinct
    description: "Count of distinct contacts"
    sql: ${id} ;;
    drill_fields: [name, email, company, stage]
  }

}
