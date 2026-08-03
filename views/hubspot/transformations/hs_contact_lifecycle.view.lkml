view: hs_contact_lifecycle {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.contact_funnel_stages`;;

  dimension: contact_lifecycle_unique_id {
    primary_key: yes
    type: string
    sql: CONCAT(${TABLE}.contact_id, '-', ${TABLE}.email) ;;
    hidden: yes
  }

  dimension: contact_id {
    hidden: yes
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
    order_by_field: stage_sort_order
    sql: ${TABLE}.funnel_stage ;;
  }

  dimension: stage_sort_order {
    hidden: yes
    type: number
    description: "Logische funnel-volgorde voor sortering van 'stage' in tabellen/pivots (i.p.v. alfabetisch). Aanname over volgorde: Subscriber < Other < Hitlist < Lead < MQL < SQL < Opportunity < Customer < Partner, met de 'verloren/inactief'-stages aan het eind. Pas de nummering hieronder aan als dit niet de gewenste volgorde is."
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

  dimension: stage_start_timestamp {
    hidden: yes
    type: date_time
    sql: ${TABLE}.stage_start_timestamp ;;
  }

  dimension: is_current_stage {
    type: yesno
    label: "Is Current Stage"
    description: "TRUE als dit stage-verblijf nog loopt (contact is sindsdien niet naar een volgende stage gewijzigd) — days_in_stage groeit dan nog door. FALSE als het verblijf is afgerond."
    sql: ${TABLE}.is_current_stage ;;
  }

  dimension: days_in_stage {
    type: number
    label: "Days in Stage"
    description: "Aantal dagen in dit stage-verblijf (echte HubSpot-timestamps, niet maand-afgerond). Bij is_current_stage = Yes: dagen sinds start, live t.o.v. vandaag (groeit door). Bij is_current_stage = No: het vaste, afgeronde aantal dagen. Gebruik de measure 'Avg Days in Stage (Completed Only)' voor een gemiddelde — deze waarde staat op elke carry-forward-rij van het verblijf, dus een simpele AVG() over deze dimensie telt lang lopende verblijven te zwaar mee."
    sql: ${TABLE}.days_in_stage ;;
  }

  dimension: leadscore {
    type: number
    label: "Leadscore"
    description: "Carry-forward maandwaarde van HubSpot-property contact_leadscore. NULL vóór de maand waarin dit contact voor het eerst een leadscore kreeg. ⚠️ Historie bestaat pas sinds 13 juli 2026 — periodevergelijkingen over kwartaal/jaar kunnen nog niet. ⚠️ Dekking: alleen contacten met een lifecyclestage-wijziging (~87% van alle contacten met een leadscore)."
    sql: ${TABLE}.leadscore ;;
  }

  dimension: leadscore_category {
    order_by_field: leadscore_category_sort_order
    type: string
    label: "Leadscore Category"
    description: "Cold: 0–25, Warming: 26–50, Warm: 51–75, Hot: 76–100. 'Other' = buiten dit bereik (leadscore loopt in de praktijk van -100 t/m 161). 'Unknown' = nog geen leadscore gehad (NULL). Vooral zinvol bij stage = Lead/MQL/SQL — bij Opportunity valt vrijwel iedereen in 'Other' (leadscore lijkt niet meer actief bijgehouden te worden zodra een contact Opportunity wordt, zie steekproef juli 2026: 502 van ~510 Opportunities in 'Other')."
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
      WHEN 'Cold'    THEN 1
      WHEN 'Warming' THEN 2
      WHEN 'Warm'    THEN 3
      WHEN 'Hot'     THEN 4
      WHEN 'Other'   THEN 5
      ELSE 6
    END ;;
  }

  measure: average_leadscore {
    type: average
    label: "Avg Leadscore"
    description: "Gemiddelde leadscore. Groepeer of filter altijd op 'Row Month' (of een andere maand-dimensie) voor een correct snapshot-gemiddelde — leadscore is carry-forward, dus zonder maand-filter tellen contacten met een lang ongewijzigde score te zwaar mee (zelfde principe als bij 'Avg Days in Stage'). ⚠️ Historie bestaat pas sinds 13 juli 2026."
    sql: ${leadscore} ;;
    value_format_name: decimal_1
  }

  measure: average_completed_duration_days {
    type: average
    label: "Avg Days in Stage"
    description: "Gemiddeld aantal dagen in de stage, alleen over afgeronde verblijven (is_current_stage = No). Filtert intern ook op is_change = Yes zodat elk verblijf precies 1x meetelt (niet per carry-forward-maand — anders tellen lang lopende verblijven te zwaar mee). Filter ook altijd op 'stage' voor een zinvol gemiddelde per funnel-stage. Let op censoring: recente periodes hebben relatief weinig afgeronde verblijven — check altijd '# Completed Stage Visits' erbij."
    sql: ${days_in_stage} ;;
    filters: [is_change: "yes", is_current_stage: "no"]
    value_format_name: decimal_0
  }

  measure: count {
    type: count_distinct
    sql: ${contact_id} ;;
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company, hs_contact.source]
  }

  measure: lead_count {
    type: count_distinct
    label: "# Leads"
    sql: ${contact_id} ;;
    filters: [stage: "Lead"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company, hs_contact_lifecycle.source]

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

  measure: opportunity_count {
    type: count_distinct
    label: "# Opportunity"
    sql: ${contact_id};;
    filters: [stage: "Opportunity"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company, hs_contact_lifecycle.source]
  }

  # -----------------------------------------------------------------------
  # Leadscore-categorieën: filter eerst op 'stage' (Lead/MQL/SQL/Opportunity)
  # en bekijk daarna de pct_*-measures voor het aandeel Cold/Warming/Warm/Hot
  # binnen die stage. Filter/groepeer ook op 'Row Month' voor een correct
  # snapshot (leadscore is carry-forward, zie beschrijving bij 'Leadscore').
  # -----------------------------------------------------------------------

  measure: count_cold {
    hidden: yes
    type: count_distinct
    label: "# Cold"
    sql: ${contact_id} ;;
    filters: [leadscore_category: "Cold"]
  }

  measure: count_warming {
    hidden: yes
    type: count_distinct
    label: "# Warming"
    sql: ${contact_id} ;;
    filters: [leadscore_category: "Warming"]
  }

  measure: count_warm {
    hidden: yes
    type: count_distinct
    label: "# Warm"
    sql: ${contact_id} ;;
    filters: [leadscore_category: "Warm"]
  }

  measure: count_hot {
    hidden: yes
    type: count_distinct
    label: "# Hot"
    sql: ${contact_id} ;;
    filters: [leadscore_category: "Hot"]
  }

  measure: pct_cold {
    type: number
    label: "% Cold"
    description: "# Cold / # Contacts binnen de huidige filterselectie (bv. filter op stage = Lead voor '% van de Leads dat Cold is'). Filter ook op Row Month voor een correct snapshot."
    sql: SAFE_DIVIDE(${count_cold}, ${count}) ;;
    value_format_name: percent_1
  }

  measure: pct_warming {
    type: number
    label: "% Warming"
    description: "# Warming / # Contacts binnen de huidige filterselectie. Filter ook op Row Month voor een correct snapshot."
    sql: SAFE_DIVIDE(${count_warming}, ${count}) ;;
    value_format_name: percent_1
  }

  measure: pct_warm {
    type: number
    label: "% Warm"
    description: "# Warm / # Contacts binnen de huidige filterselectie. Filter ook op Row Month voor een correct snapshot."
    sql: SAFE_DIVIDE(${count_warm}, ${count}) ;;
    value_format_name: percent_1
  }

  measure: pct_hot {
    type: number
    label: "% Hot"
    description: "# Hot / # Contacts binnen de huidige filterselectie. Filter ook op Row Month voor een correct snapshot."
    sql: SAFE_DIVIDE(${count_hot}, ${count}) ;;
    value_format_name: percent_1
  }

}
