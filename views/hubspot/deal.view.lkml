view: deal {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.deal_company` ;;

  dimension: deal_id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.dealid ;;
  }

  dimension: owner_id {
    hidden: yes
    sql: ${TABLE}.owner ;;
  }

  dimension: deal_name {
    label: "Deal"
    description: "Name of the deal"
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension_group: created_date {
    label: "Created"
    description: "The date of creation for the deal"
    type: time
    datatype: date
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.createddate ;;
  }

  dimension_group: close_date {
    label: "Close"
    description: "The expected close date for the deal"
    type: time
    datatype: date
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

  dimension: probability {
    description: "The probability of winning the deal in its current stage"
    type: number
    sql: ${TABLE}.proability ;;
    value_format_name: percent_0
  }



   }
