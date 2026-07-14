view: hs_deal_lines {
sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.deal_lines` ;;

dimension: deal_id {
  hidden: yes
  type: number
  sql: ${TABLE}.dealid ;;
  value_format_name: id
}

dimension: lineitem_id {
  hidden: yes
  sql: ${TABLE}.lineitemid ;;
}

dimension: company_id {
  hidden: yes
  sql: ${TABLE}.companyid ;;
}

dimension: department_id {
  hidden: yes
  sql: ${TABLE}.department_id ;;
}

dimension: owner_id {
  hidden: yes
  sql: ${TABLE}.owner ;;
}

dimension: contact_id {
  hidden: yes
  sql: ${TABLE}.primary_contact_id ;;
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

measure: contract_value {
  label: "Contract value"
  description: "The sum of the total contract value of the items."
  type: sum
  sql: ${TABLE}.contractvalue ;;
  value_format_name: eur
}

measure: predicted_amount {
  label: "Predicted amount"
  description: "The predicted weighted sum of the line item amounts based on the ML model's probability"
  type: sum
  sql: ${TABLE}.predicted_amount ;;
  value_format_name: eur
  drill_fields: [hs_deal.deal_name, hs_deal.probability, hs_deal.predicted_probability, predicted_amount]
}

measure: predicted_contract_value {
  label: "Predicted contract value"
  description: "The precited weighted sum of the total contract value of the items based on the ML model's probability"
  type: sum
  sql: ${TABLE}.predicted_contract_value ;;
  value_format_name: eur
  drill_fields: [hs_deal.deal_name, hs_deal.probability, hs_deal.predicted_probability, predicted_contract_value]
}

measure: weighted_amount {
  label: "Weighted amount"
  description: "The weighted sum of the line item amounts based on deal probability"
  type: sum
  sql: ${TABLE}.weighted_amount ;;
  value_format_name: eur
  drill_fields: [ns_employee.name, hs_customer.company_name, hs_deal.deal_name, hs_item.item_name, weighted_amount]
}

measure: weighted_contract_value {
  label: "Weighted contract value"
  description: "The weighted sum of the total contract value of the items based on deal probability"
  type: sum
  sql: ${TABLE}.weighted_contract_value ;;
  value_format_name: eur
  drill_fields: [ns_employee.name, hs_customer.company_name, hs_deal.deal_name, hs_item.item_name, weighted_contract_value]
}
 }
