connection: "adwise_fivetran"

include: "/views/hubspot/*.view.lkml"
include: "/views/netsuite/*.view.lkml"
include: "/views/hubspot/transformations/*.view.lkml"

explore: hs_deal_lines {
  label: "Deal Line Financials"
  description: "This explore focuses on the line item financials linked to deals"
  view_label: "Financials"

  join: hs_customer {
    view_label: "Customer"
    relationship: many_to_one
    type: left_outer
    sql_on: CAST((${hs_deal_lines.company_id}) AS STRING) = CAST((${hs_customer.id}) AS STRING) ;;
  }

  join: hs_owner {
    relationship: many_to_one
    type: left_outer
    sql_on: ${hs_deal_lines.owner_id} = ${hs_owner.id} ;;
  }

  join: ns_employee {
    view_label: "Employee"
    relationship: one_to_one
    type: left_outer
    sql_on: ${hs_owner.email} = ${ns_employee.email} ;;
  }

  join: hs_deal {
    view_label: "Deal"
    relationship: many_to_one
    type: left_outer
    sql_on: ${hs_deal_lines.deal_id} = ${hs_deal.deal_id} ;;
  }

  join: hs_deal_probability {
    view_label: "Win Probability Model"
    relationship: many_to_one
    sql_on: ${hs_deal_lines.deal_id} = ${hs_deal_probability.deal_id} ;;
  }

  join: hs_deal_probability_explainability {
    relationship: one_to_many
    sql_on: ${hs_deal_probability.deal_id} = ${hs_deal_probability_explainability.deal_id} ;;
  }

  join: hs_item {
    view_label: "Item"
    relationship: many_to_one
    type: left_outer
    sql_on: CAST((${hs_deal_lines.lineitem_id}) AS STRING) = CAST((${hs_item.id}) AS STRING) ;;
  }

  join: ns_item {
    relationship: one_to_one
    type: left_outer
    sql_on: ${hs_item.sku} = ${ns_item.id} ;;
    fields: []
  }

  join: ns_department {
    view_label: "Department"
    relationship: many_to_one
    type: left_outer
    sql_on: CAST((${hs_item.departmentid}) AS STRING) = CAST((${ns_department.id}) AS STRING) ;;  }


}
