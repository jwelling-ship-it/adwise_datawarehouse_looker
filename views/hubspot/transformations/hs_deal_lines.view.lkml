view: hs_deal_lines {
sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.deal_lines` ;;

dimension: deal_id {
  hidden: yes
  sql: ${TABLE}.dealid ;;
}

dimension: item_id {
  hidden: yes
  sql: ${TABLE}.itemid ;;
}

dimension: company_id {
  hidden: yes
  sql: ${TABLE}.companyid ;;
}

dimension: department_id {
  hidden: yes
  sql: ${TABLE}.department_id ;;
}

dimension_group: close_date {
  label: "Close"
  description: "The expected close date of the deal"
  type: time
  datatype: timestamp
  timeframes: [date, month, quarter, year]
  sql: ${TABLE}.closedate ;;
}

dimension: is_recurring {
  label: "Is recurring"
  description: "Check if deal item is recurring"
  type: yesno
  sql: ${TABLE}.isrecurring ;;
}

dimension: billing_frequency {
  label: "Billing frequency"
  description: "The billing frequency of the deal item"
  type: string
  sql: ${TABLE}.billingfrequency ;;
}

measure: amount {
  description: "The sum of the line item amounts on the deal"
  type: sum
  sql: ${TABLE}.itemamount ;;
  value_format_name: eur
}

measure: weighted_amount {
  label: "Weighted amount"
  description: "The weighted sum of the line item amounts based on deal probability"
  type: sum
  sql: ${TABLE}.weighted_amount ;;
  value_format_name: eur
}
 }
