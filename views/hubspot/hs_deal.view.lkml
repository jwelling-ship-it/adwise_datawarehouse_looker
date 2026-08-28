view: hs_deal {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.deal_company` ;;

  dimension: deal_id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.dealid ;;
    value_format_name: id
  }

  dimension: owner_id {
    hidden: yes
    sql: ${TABLE}.owner ;;
  }

  dimension: deal_name {
    label: "Deal"
    description: "Name of the deal"
    type: string
    sql: ${TABLE}.dealname ;;
    link: {
      label: "Open in HubSpot"
      url: "https://app.hubspot.com/contacts/139703519/record/0-3/{{ deal_id }}"
    }
  }

  dimension_group: close_date {
    group_label: "Dates"
    label: "Close"
    description: "The expected close date for the deal"
    type: time
    timeframes: [date, month, week, quarter, year]
    sql: ${TABLE}.closedate ;;
  }

  dimension_group: create_date {
    group_label: "Dates"
    label: "Create"
    description: "The date of creation of the deal"
    type: time
    timeframes: [date, month, week, quarter, year]
    sql: ${TABLE}.createddate ;;
  }

  dimension: stage {
    label: "Deal stage"
    description: "The current stage of the deal"
    type: string
    sql: ${TABLE}.dealstage ;;
  }

  dimension: financecheck {
    type: yesno
    hidden: yes
    sql: ${TABLE}.financecheck ;;
  }

  dimension: is_closed {
    group_label: "Status"
    label: "Is closed"
    description: "Check whether deal has been closed or not"
    type: yesno
    sql: ${TABLE}.isclosed ;;
  }

  dimension: is_closed_won {
    group_label: "Status"
    label: "Is won"
    description: "Check whether deal has been won or not"
    type: yesno
    sql: ${TABLE}.isclosedwon ;;
  }

  dimension: is_pipeline {
    group_label: "Status"
    label: "Is pipeline"
    description: "Deal is open and close date is in the current or a future month, or deal is closed but not yet finance-checked"
    type: yesno
    sql: (${is_closed} = false
      AND DATE_TRUNC(${close_date_date}, MONTH) >= DATE_TRUNC(CURRENT_DATE(), MONTH))
      OR (${is_closed_won} = true AND ${financecheck} = false) ;;
  }


  dimension: probability {
    group_label: "Probabilities"
    description: "The probability of winning the deal in its current stage"
    type: number
    sql: ${TABLE}.probability ;;
    value_format_name: percent_0
  }

  dimension: predicted_probability {
    group_label: "Probabilities"
    label: "Predicted probability"
    description: "The ML model's predicted probability of winning this deal in its current close month"
    type: number
    sql: ${TABLE}.ml_probability ;;
    value_format_name: percent_0
  }

  dimension: quote_sent {
    group_label: "Status"
    label: "Quote sent"
    description: "Check whether or not a quote has been sent to the customer for this deal"
    type: yesno
    sql: ${TABLE}.has_quote_sent ;;
  }

  dimension_group: quote_date {
    group_label: "Dates"
    label: "Quote sent"
    description: "The date a quote was sent to the customer for this deal"
    type: time
    timeframes: [date, month, week, quarter, year]
    sql: ${TABLE}.quote_sent_date ;;
  }


  measure: count {
    group_label: "Counts"
    label: "# Deals"
    description: "Count of distinct deals"
    type: count_distinct
    sql: ${deal_id} ;;
    drill_fields: [deal_name, ns_employee.name, create_date_date, close_date_date, stage]
  }

  measure: count_won {
    group_label: "Counts"
    label: "# Deals Won"
    description: "Count of distinct deals that have been closed won"
    type: count_distinct
    sql: ${deal_id} ;;
    filters: [is_closed_won: "Yes"]
    drill_fields: [deal_name, ns_employee.name, create_date_date, close_date_date, stage]
  }

  measure: count_open {
    group_label: "Counts"
    label: "# Deals Open"
    description: "Count of distinct deals currently in the pipeline"
    type: count_distinct
    sql: ${deal_id} ;;
    filters: [is_pipeline: "Yes"]
    drill_fields: [deal_name, ns_employee.name, create_date_date, close_date_date, stage]
  }

  measure: win_rate {
    label: "Win %"
    description: "Share of deals (# Deals Won divided by # Deals) that were closed won"
    type: number
    sql: SAFE_DIVIDE(${count_won}, ${count}) ;;
    value_format_name: percent_0
  }



   }
