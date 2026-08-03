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
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    sql: ${TABLE}.email ;;
  }

  dimension: name {
    sql: ${TABLE}.name ;;
    link: {
      label: "Open in HubSpot"
      url: "https://app.hubspot.com/contacts/139703519/record/0-1/{{ id }}"
    }
  }

  dimension: stage {
    sql: ${TABLE}.lifecyclestage ;;
  }

  dimension: source {
    sql: ${TABLE}.lead_source ;;
  }

  dimension: company {
    sql: ${TABLE}.companyname ;;
  }

  dimension: leadscore {
    sql: ${TABLE}.leadscore ;;
  }

  dimension: leadscore_category {
    order_by_field: leadscore_category_sort_order
    type: string
    label: "Leadscore category"
    description: "Cold: ≤25 (incl. 0 en negatieve scores), Warming: 26–50, Warm: 51–75, Hot: ≥76 (geen bovengrens, leadscore = engagement + fit en kan boven 100 uitkomen, tot 161 gezien). 'Unknown' = geen leadscore (NULL). Let op: ~66% van alle contacten heeft een score van exact 0 — dat is vermoedelijk 'nog niet gescoord', niet een echte neutrale score (niet bevestigd bij wie de HubSpot-scoring beheert)."
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
    sql: ${leadscore} ;;
    value_format_name: decimal_0
  }

  measure: count {
    type: count_distinct
    sql: ${id} ;;
    drill_fields: [name, email, company, stage]
  }

}
