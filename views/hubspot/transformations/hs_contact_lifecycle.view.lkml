view: hs_contact_lifecycle {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.contact_stage_events`;;

  # -----------------------------------------------------------------------
  # v2 (2026-08-03): bron omgezet van contact_funnel_stages (maand-carry-
  # forward) naar contact_stage_events (exacte stage-wijziging-timestamps,
  # geen collapsing). Reden: contact_funnel_stages bewaarde per contact per
  # maand alleen de LAATSTE stage-wijziging, waardoor contacten die binnen
  # dezelfde maand meerdere stages doorliepen instroom misten. Zie
  # Log/2026-07-30 - Contact Funnel Conversie %.md (2026-08-03).
  #
  # Veldnamen zoveel mogelijk gelijk gehouden zodat bestaande dashboards
  # grotendeels blijven werken. Wat NIET is meegenomen (bewust, elders
  # ondergebracht of niet meer van toepassing):
  #  - company_id, source (lead_source): niet aanwezig in contact_stage_events
  #    (bevestigd niet gebruikt in dashboards, 2026-08-03).
  #  - is_change: vervalt — elke rij hier IS al een stage-wijziging (geen
  #    carry-forward-vulrijen meer), dus dit zou altijd TRUE zijn.
  #  - is_current_stage: vervalt — geen carry-forward meer, dus "loopt dit
  #    verblijf nog" is hier niet meer van toepassing (alleen afgeronde
  #    verblijven zijn zichtbaar, via Previous Stage).
  #  - days_in_stage → hernoemd naar days_in_previous_stage: LET OP, filter
  #    voor stage-duur voortaan op de nieuwe dimensie 'Previous Stage', niet
  #    op 'Stage' (die betekent nu de NIEUWE stage ná de wijziging). Meet-
  #    namen (completed_segment_count, average_completed_duration_days)
  #    zijn ongewijzigd gebleven. Voor een cohort-gebaseerd gemiddelde (op
  #    basis van wanneer het verblijf BEGON i.p.v. eindigde) gebruik
  #    hs_contact_stage_events (Previous Stage Start).
  #  - leadscore, leadscore_category, average_leadscore, count_cold/warming/
  #    warm/hot, pct_cold/warming/warm/hot: verplaatst naar hs_contact
  #    (actuele waarde, geen carry-forward-geschiedenis nodig bevonden).
  # -----------------------------------------------------------------------

  dimension: contact_lifecycle_unique_id {
    primary_key: yes
    type: string
    sql: CONCAT(${TABLE}.contact_id, '-', CAST(${TABLE}.stage_change_timestamp AS STRING)) ;;
    hidden: yes
  }

  dimension: contact_id {
    description: "The HubSpot contact ID"
    sql: ${TABLE}.contact_id ;;
    link: {
      label: "Open in HubSpot"
      url: "https://app.hubspot.com/contacts/139703519/record/0-1/{{ value }}"
    }
  }

  dimension_group: row {
    type: time
    timeframes: [month, quarter, year]
    description: "Exact timestamp of the stage change (previously: month-rounded carry-forward date). For inflow analysis per period — every row is by definition new inflow, an is_change filter is no longer needed."
    sql: ${TABLE}.stage_change_timestamp ;;
  }

  dimension: stage {
    order_by_field: stage_sort_order
    description: "The funnel stage this contact moved into at this stage-change event"
    sql: ${TABLE}.funnel_stage ;;
  }

  dimension: stage_sort_order {
    hidden: yes
    type: number
    description: "Logical funnel order for sorting 'stage' in tables/pivots (instead of alphabetical). Assumption about order: Subscriber < Other < Hitlist < Lead < MQL < SQL < Opportunity < Customer < Partner, with the 'lost/inactive' stages at the end. Adjust the numbering below if this is not the desired order."
    sql: CASE ${TABLE}.funnel_stage
      WHEN 'Subscriber'        THEN 1
      WHEN 'Other'             THEN 2
      WHEN 'Hitlist'           THEN 3
      WHEN 'Lead'              THEN 4
      WHEN 'MQL'               THEN 5
      WHEN 'SQL'               THEN 6
      WHEN 'Opportunity'       THEN 7
      WHEN 'Customer'          THEN 8
      WHEN 'Partner'           THEN 9
      WHEN 'Disqualified Lead' THEN 10
      WHEN 'Prospect Lost'     THEN 11
      WHEN 'Customer Inactive' THEN 12
      WHEN 'Customer Lost'     THEN 13
      ELSE 99
    END ;;
  }

  dimension: previous_stage {
    order_by_field: previous_stage_sort_order
    label: "Previous Stage"
    description: "The stage this contact was in immediately before this change. Filter on this (not on 'Stage') to look at the duration of a COMPLETED stay — e.g. previous_stage = 'Lead' for the average time contacts spent in Lead before moving to the next stage. NULL if this is the first known stage change for this contact."
    sql: ${TABLE}.previous_funnel_stage ;;
  }

  dimension: previous_stage_sort_order {
    hidden: yes
    type: number
    description: "Separate sort order for previous_stage, based on previous_funnel_stage. Previously accidentally reused stage_sort_order (based on funnel_stage, the destination stage) — that caused an unwanted extra GROUP BY on the destination stage, even when it wasn't shown as a column. See Log/2026-07-30 - Contact Funnel Conversie %.md (2026-08-03)."
    sql: CASE ${TABLE}.previous_funnel_stage
      WHEN 'Subscriber'        THEN 1
      WHEN 'Other'             THEN 2
      WHEN 'Hitlist'           THEN 3
      WHEN 'Lead'              THEN 4
      WHEN 'MQL'               THEN 5
      WHEN 'SQL'               THEN 6
      WHEN 'Opportunity'       THEN 7
      WHEN 'Customer'          THEN 8
      WHEN 'Partner'           THEN 9
      WHEN 'Disqualified Lead' THEN 10
      WHEN 'Prospect Lost'     THEN 11
      WHEN 'Customer Inactive' THEN 12
      WHEN 'Customer Lost'     THEN 13
      ELSE 99
    END ;;
  }

  dimension: days_in_previous_stage {
    type: number
    label: "Days in Previous Stage"
    description: "Completed duration (in days) of the stay in Previous Stage, before this change. Covers only completed stays."
    sql: ${TABLE}.days_previous_stage ;;
  }

  dimension_group: previous_stage_start {
    type: time
    timeframes: [date, month, quarter, year]
    label: "Previous Stage Start"
    description: "Exact timestamp when this contact started Previous Stage — the COHORT moment. Filter on this (instead of on Row Month/Quarter/Year) for 'average time in Lead for contacts that became Lead this year'. Filtering on Row instead of Previous Stage Start mixes old and new stays and gives a different (higher) average — see Log/2026-07-30 - Contact Funnel Conversie %.md (2026-08-03), example: 96.5 vs 6.0 days for Lead in 2026."
    sql: ${TABLE}.previous_stage_start_timestamp ;;
  }

  measure: completed_segment_count {
    type: count
    label: "# Completed Stage Visits"
    description: "Number of completed stage stays within the current filter selection (filter on Previous Stage for a specific stage). Use as sample-size context alongside Avg Days in Stage (Completed Only)."
    filters: [previous_stage: "-NULL"]
  }

  measure: average_completed_duration_days {
    type: average
    label: "Avg Days in Stage (Completed Only)"
    description: "Average number of days in a stage, over completed stays only. Filter on Previous Stage (e.g. 'Lead') for the duration of that specific stage — not on 'Stage', since that is now the NEW stage after the change, not the completed one. Also consider filtering on Previous Stage Start (via hs_contact_stage_events) for a cohort-based average instead of a figure mixed from old and new stays."
    sql: ${days_in_previous_stage} ;;
    filters: [previous_stage: "-NULL"]
    value_format_name: decimal_1
  }

  measure: count {
    type: count_distinct
    description: "Count of distinct contacts with a stage-change event in the current filter selection"
    sql: ${contact_id} ;;
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company, hs_contact.source]
  }

  measure: lead_count {
    type: count_distinct
    label: "# Leads"
    description: "Contacts that had a stage change to Lead in the filtered period. Also counts if the same contact progressed further within that same period (e.g. became MQL that same day) — this is exactly the inflow that the old contact_funnel_stages version missed."
    sql: ${contact_id} ;;
    filters: [stage: "Lead"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company]
  }

  measure: mql_count {
    type: count_distinct
    label: "# MQL"
    description: "Contacts that had a stage-change event into MQL in the filtered period"
    sql: ${contact_id};;
    filters: [stage: "MQL"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company]
  }

  measure: sql_count {
    type: count_distinct
    label: "# SQL"
    description: "Contacts that had a stage-change event into SQL in the filtered period"
    sql: ${contact_id};;
    filters: [stage: "SQL"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company]
  }

  measure: opportunity_count {
    type: count_distinct
    label: "# Opportunity"
    description: "Contacts that had a stage-change event into Opportunity in the filtered period"
    sql: ${contact_id};;
    filters: [stage: "Opportunity"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company]
  }
}
