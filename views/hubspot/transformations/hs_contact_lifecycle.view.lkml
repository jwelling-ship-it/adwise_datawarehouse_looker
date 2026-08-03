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
    sql: ${TABLE}.contact_id ;;
    link: {
      label: "Open in HubSpot"
      url: "https://app.hubspot.com/contacts/139703519/record/0-1/{{ value }}"
    }
  }

  dimension_group: row {
    type: time
    timeframes: [month, quarter, year]
    description: "Exacte timestamp van de stage-wijziging (was: maand-afgeronde carry-forward datum). Voor instroom-analyse per periode — elke rij is per definitie nieuwe instroom, een is_change-filter is niet meer nodig."
    sql: ${TABLE}.stage_change_timestamp ;;
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

  dimension: previous_stage {
    order_by_field: previous_stage_sort_order
    label: "Previous Stage"
    description: "De stage die dit contact hiervóór had, vóór deze wijziging. Filter hierop (niet op 'Stage') om de duur van een AFGEROND verblijf te bekijken — bv. previous_stage = 'Lead' voor de gemiddelde tijd die contacten in Lead doorbrachten voordat ze naar de volgende stage gingen. NULL als dit de eerste bekende stage-wijziging van dit contact is."
    sql: ${TABLE}.previous_funnel_stage ;;
  }

  dimension: previous_stage_sort_order {
    hidden: yes
    type: number
    description: "Losse sorteervolgorde voor previous_stage, gebaseerd op previous_funnel_stage. Hergebruikte eerder per ongeluk stage_sort_order (gebaseerd op funnel_stage, de bestemmings-stage) — dat veroorzaakte een ongewenste extra GROUP BY op de bestemmings-stage, ook als die niet als kolom werd getoond. Zie Log/2026-07-30 - Contact Funnel Conversie %.md (2026-08-03)."
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
    description: "Afgeronde duur (in dagen) van het verblijf in Previous Stage, vóór deze wijziging. Dekt alleen afgeronde verblijven."
    sql: ${TABLE}.days_previous_stage ;;
  }

  dimension_group: previous_stage_start {
    type: time
    timeframes: [date, month, quarter, year]
    label: "Previous Stage Start"
    description: "Exacte timestamp waarop dit contact aan de Previous Stage begon — het COHORT-moment. Filter hierop (i.p.v. op Row Month/Quarter/Year) voor 'gemiddelde tijd in Lead voor contacten die dit jaar Lead werden'. Filteren op Row i.p.v. Previous Stage Start mengt oude en nieuwe verblijven en geeft een ander (hoger) gemiddelde — zie Log/2026-07-30 - Contact Funnel Conversie %.md (2026-08-03), voorbeeld: 96,5 vs 6,0 dagen voor Lead in 2026."
    sql: ${TABLE}.previous_stage_start_timestamp ;;
  }

  measure: completed_segment_count {
    type: count
    label: "# Completed Stage Visits"
    description: "Aantal afgeronde stage-verblijven binnen de huidige filterselectie (filter op Previous Stage voor een specifieke stage). Gebruik als steekproefgrootte-context naast Avg Days in Stage (Completed Only)."
    filters: [previous_stage: "-NULL"]
  }

  measure: average_completed_duration_days {
    type: average
    label: "Avg Days in Stage (Completed Only)"
    description: "Gemiddeld aantal dagen in een stage, alleen over afgeronde verblijven. Filter op Previous Stage (bv. 'Lead') voor de duur van die specifieke stage — niet op 'Stage', want dat is nu de NIEUWE stage na de wijziging, niet de afgeronde. Overweeg ook te filteren op Previous Stage Start (via hs_contact_stage_events) voor een cohort-gebaseerd gemiddelde in plaats van een door oude en nieuwe verblijven gemengd cijfer."
    sql: ${days_in_previous_stage} ;;
    filters: [previous_stage: "-NULL"]
    value_format_name: decimal_1
  }

  measure: count {
    type: count_distinct
    sql: ${contact_id} ;;
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company, hs_contact.source]
  }

  measure: lead_count {
    type: count_distinct
    label: "# Leads"
    description: "Contacten die in de gefilterde periode een stage-wijziging naar Lead hadden. Telt ook mee als hetzelfde contact in diezelfde periode ook al verder doorstroomde (bv. dezelfde dag nog MQL werd) — dat is precies waar de oude contact_funnel_stages-versie instroom miste."
    sql: ${contact_id} ;;
    filters: [stage: "Lead"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company]
  }

  measure: mql_count {
    type: count_distinct
    label: "# MQL"
    sql: ${contact_id};;
    filters: [stage: "MQL"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company]
  }

  measure: sql_count {
    type: count_distinct
    label: "# SQL"
    sql: ${contact_id};;
    filters: [stage: "SQL"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company]
  }

  measure: opportunity_count {
    type: count_distinct
    label: "# Opportunity"
    sql: ${contact_id};;
    filters: [stage: "Opportunity"]
    drill_fields: [contact_id, hs_contact.name, hs_contact.email, hs_contact.company]
  }
}
