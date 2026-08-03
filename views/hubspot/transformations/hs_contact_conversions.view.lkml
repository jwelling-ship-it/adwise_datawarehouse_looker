view: hs_contact_conversions {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.contact_funnel_conversions`;;

  # -----------------------------------------------------------------------
  # Grain: 1 rij per contact. Per-contact geverifieerde conversie tussen
  # funnel-stages (zelfde contact_id moet eerst de vorige stage bereiken en
  # dáárna de volgende) — niet een simpele COUNT(volgende)/COUNT(vorige) op
  # twee losse totalen. Zie Log/2026-07-30 - Contact Funnel Conversie %.
  # -----------------------------------------------------------------------

  dimension: contact_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.contact_id ;;
    link: {
      label: "Open in HubSpot"
      url: "https://app.hubspot.com/contacts/139703519/record/0-1/{{ value }}"
    }
  }

  dimension: email {
    sql: ${TABLE}.email ;;
  }

  dimension: company_id {
    hidden: yes
    sql: ${TABLE}.company_id ;;
  }

  # -----------------------------------------------------------------------
  # Eerste-datum per stage (cohort-basis: filter hierop om een cohort te
  # bekijken, bv. lead_first_month = deze maand voor "wie werd deze maand
  # Lead, en wat is daarvan uiteindelijk doorgestroomd").
  # -----------------------------------------------------------------------

  dimension_group: lead_first {
    type: time
    timeframes: [date, month, quarter]
    label: "Lead First"
    description: "Exacte timestamp waarop dit contact voor het eerst de Lead-stage bereikte (sinds 2026-08-03 op stage-wijziging-niveau, niet meer maand-afgerond). NULL als nooit Lead."
    sql: ${TABLE}.lead_first_date ;;
  }

  dimension_group: mql_first {
    type: time
    timeframes: [date, month, quarter]
    label: "MQL First"
    description: "Exacte timestamp waarop dit contact voor het eerst de MQL-stage bereikte (sinds 2026-08-03 op stage-wijziging-niveau, niet meer maand-afgerond). NULL als nooit MQL."
    sql: ${TABLE}.mql_first_date ;;
  }

  dimension_group: sql_first {
    type: time
    timeframes: [date, month, quarter]
    label: "SQL First"
    description: "Exacte timestamp waarop dit contact voor het eerst de SQL-stage bereikte (sinds 2026-08-03 op stage-wijziging-niveau, niet meer maand-afgerond). NULL als nooit SQL."
    sql: ${TABLE}.sql_first_date ;;
  }

  dimension_group: opportunity_first {
    type: time
    timeframes: [date, month, quarter]
    label: "Opportunity First"
    description: "Exacte timestamp waarop dit contact voor het eerst de Opportunity-stage bereikte (sinds 2026-08-03 op stage-wijziging-niveau, niet meer maand-afgerond). NULL als nooit Opportunity."
    sql: ${TABLE}.opportunity_first_date ;;
  }

  # -----------------------------------------------------------------------
  # Aanwezigheid per stage (hidden helpers, gebruikt om de *_count measures
  # correct te filteren op "heeft deze stage ooit bereikt").
  # -----------------------------------------------------------------------

  dimension: is_lead {
    hidden: yes
    type: yesno
    sql: ${TABLE}.lead_first_date IS NOT NULL ;;
  }

  dimension: is_mql {
    hidden: yes
    type: yesno
    sql: ${TABLE}.mql_first_date IS NOT NULL ;;
  }

  dimension: is_sql {
    hidden: yes
    type: yesno
    sql: ${TABLE}.sql_first_date IS NOT NULL ;;
  }

  dimension: is_opportunity {
    hidden: yes
    type: yesno
    sql: ${TABLE}.opportunity_first_date IS NOT NULL ;;
  }

  # -----------------------------------------------------------------------
  # Per-contact geverifieerde conversie-vlaggen (zelfde contact, juiste
  # tijdsvolgorde). NULL = transitie niet van toepassing (contact was nooit
  # in de vorige stage van dit paar).
  # -----------------------------------------------------------------------

  dimension: converted_lead_to_mql {
    hidden: yes
    type: yesno
    label: "Converted: Lead → MQL"
    description: "TRUE als dit contact na Lead ook daadwerkelijk MQL werd. NULL als contact nooit Lead is geweest."
    sql: ${TABLE}.converted_lead_to_mql ;;
  }

  dimension: converted_mql_to_sql {
    hidden: yes
    type: yesno
    label: "Converted: MQL → SQL"
    description: "TRUE als dit contact na MQL ook daadwerkelijk SQL werd. NULL als contact nooit MQL is geweest."
    sql: ${TABLE}.converted_mql_to_sql ;;
  }

  dimension: converted_sql_to_opportunity {
    hidden: yes
    type: yesno
    label: "Converted: SQL → Opportunity"
    description: "TRUE als dit contact na SQL ook daadwerkelijk Opportunity werd. NULL als contact nooit SQL is geweest."
    sql: ${TABLE}.converted_sql_to_opportunity ;;
  }

  dimension: converted_mql_to_opportunity_direct {
    hidden: yes
    type: yesno
    label: "Converted: MQL → Opportunity (direct)"
    description: "TRUE als dit contact na MQL alsnog Opportunity werd, ongeacht of SQL is doorlopen. Praktisch bruikbaar omdat de meerderheid van contacten de SQL-stage overslaat (zie datakwaliteit-noot in contact_funnel_stages/Log 2026-07-30). NULL als contact nooit MQL is geweest."
    sql: ${TABLE}.converted_mql_to_opportunity_direct ;;
  }

  # -----------------------------------------------------------------------
  # Basis-counts per stage. Filter op lead_first_month/quarter/year etc. om
  # een cohort te selecteren — dat filtert alléén de instroom-datum van de
  # betreffende stage, niet de conversie zelf (die mag ook later vallen).
  # -----------------------------------------------------------------------

  measure: count {
    type: count_distinct
    label: "# Contacts"
    sql: ${contact_id} ;;
    drill_fields: [contact_id, email]
  }

  measure: lead_count {
    type: count_distinct
    label: "# Leads"
    sql: ${contact_id} ;;
    filters: [is_lead: "yes"]
    drill_fields: [contact_id, email, lead_first_date]
  }

  measure: mql_count {
    type: count_distinct
    label: "# MQLs"
    sql: ${contact_id} ;;
    filters: [is_mql: "yes"]
    drill_fields: [contact_id, email, mql_first_date]
  }

  measure: sql_count {
    type: count_distinct
    label: "# SQLs"
    sql: ${contact_id} ;;
    filters: [is_sql: "yes"]
    drill_fields: [contact_id, email, sql_first_date]
  }

  measure: opportunity_count {
    type: count_distinct
    label: "# Opportunities"
    sql: ${contact_id} ;;
    filters: [is_opportunity: "yes"]
    drill_fields: [contact_id, email, opportunity_first_date]
  }

  # -----------------------------------------------------------------------
  # Geconverteerde counts (per-contact geverifieerd — dit is de teller voor
  # de %-measures hieronder, niet de losse stage-totalen).
  # -----------------------------------------------------------------------

  measure: lead_to_mql_converted_count {
    type: count_distinct
    label: "# Lead → MQL Converted"
    sql: ${contact_id} ;;
    filters: [converted_lead_to_mql: "yes"]
    drill_fields: [contact_id, hs_contact.name, email, hs_contact.company, lead_first_date, mql_first_date]
  }

  measure: mql_to_sql_converted_count {
    type: count_distinct
    label: "# MQL → SQL Converted"
    sql: ${contact_id} ;;
    filters: [converted_mql_to_sql: "yes"]
    drill_fields: [contact_id, hs_contact.name, email, hs_contact.company, mql_first_date, sql_first_date]
  }

  measure: sql_to_opportunity_converted_count {
    type: count_distinct
    label: "# SQL → Opportunity Converted"
    sql: ${contact_id} ;;
    filters: [converted_sql_to_opportunity: "yes"]
    drill_fields: [contact_id, hs_contact.name, email, hs_contact.company, sql_first_date, opportunity_first_date]
  }

  measure: mql_to_opportunity_direct_converted_count {
    type: count_distinct
    label: "# MQL → Opportunity Converted (Direct)"
    sql: ${contact_id} ;;
    filters: [converted_mql_to_opportunity_direct: "yes"]
    drill_fields: [contact_id, hs_contact.name, email, hs_contact.company, mql_first_date, opportunity_first_date]
  }

  # -----------------------------------------------------------------------
  # Conversie-percentages: ratio-van-sommen, NIET vooraf berekend en
  # opgeslagen in BigQuery. Werkt daardoor correct bij elke periode-filter
  # (maand/kwartaal/jaar/custom) zonder het "gemiddelde-van-gemiddelden"-
  # probleem. Filter voor een cohort-analyse op de bijbehorende *_first_*
  # dimension_group (bv. mql_first_quarter voor de MQL→SQL conversie),
  # niet op een andere stage se datum.
  # -----------------------------------------------------------------------

  measure: lead_to_mql_pct {
    type: number
    label: "Lead → MQL %"
    description: "% van de Leads (in de gefilterde periode/selectie) dat ook daadwerkelijk MQL werd, ongeacht wanneer dat gebeurde. Let op censoring: recente cohorts hebben nog weinig tijd gehad om te converteren."
    sql: SAFE_DIVIDE(${lead_to_mql_converted_count}, ${lead_count}) ;;
    value_format_name: percent_1
  }

  measure: mql_to_sql_pct {
    type: number
    label: "MQL → SQL %"
    description: "% van de MQL's (in de gefilterde periode/selectie) dat ook daadwerkelijk SQL werd, ongeacht wanneer dat gebeurde. Let op censoring: recente cohorts hebben nog weinig tijd gehad om te converteren."
    sql: SAFE_DIVIDE(${mql_to_sql_converted_count}, ${mql_count}) ;;
    value_format_name: percent_1
  }

  measure: sql_to_opportunity_pct {
    type: number
    label: "SQL → Opportunity %"
    description: "% van de SQL's (in de gefilterde periode/selectie) dat ook daadwerkelijk Opportunity werd, ongeacht wanneer dat gebeurde. Kleine steekproef (zie # SQLs) — interpreteer met voorzichtigheid."
    sql: SAFE_DIVIDE(${sql_to_opportunity_converted_count}, ${sql_count}) ;;
    value_format_name: percent_1
  }

  measure: mql_to_opportunity_direct_pct {
    type: number
    label: "MQL → Opportunity % (Direct)"
    description: "% van de MQL's dat alsnog Opportunity werd, ongeacht of SQL is doorlopen. Praktisch relevanter dan MQL→SQL→Opportunity omdat de meeste contacten SQL overslaan (zie datakwaliteit-noot)."
    sql: SAFE_DIVIDE(${mql_to_opportunity_direct_converted_count}, ${mql_count}) ;;
    value_format_name: percent_1
  }
}
