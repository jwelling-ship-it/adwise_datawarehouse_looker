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
    label: "Close"
    description: "The expected close date for the deal"
    type: time
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.closedate ;;
  }

  dimension: stage {
    label: "Deal stage"
    description: "The current stage of the deal"
    type: string
    sql: ${TABLE}.stage ;;
  }

  dimension: is_closed {
    label: "Is closed"
    description: "Check whether deal has been closed or not"
    type: yesno
    sql: ${TABLE}.isclosed ;;
  }

  dimension: is_closed_won {
    label: "Is won"
    description: "Check whether deal has been won or not"
    type: yesno
    sql: ${TABLE}.isclosedwon ;;
  }

  dimension: is_pipeline {
    label: "Is pipeline"
    description: "Deal is open and close date is in the current or a future month"
    type: yesno
    sql: ${is_closed} = false
      AND DATE_TRUNC(${close_date_date}, MONTH) >= DATE_TRUNC(CURRENT_DATE(), MONTH) ;;
  }


  dimension: probability {
    description: "The probability of winning the deal in its current stage"
    type: number
    sql: ${TABLE}.probability ;;
    value_format_name: percent_0
  }

  dimension: predicted_probability {
    label: "Predicted probability"
    description: "The ML model's predicted probability of winning this deal in its current close month"
    type: number
    sql: ${TABLE}.ml_probability ;;
    value_format_name: percent_0
  }



   }
