connection: "adwise_fivetran"

include: "/views/hubspot/transformations/*.view.lkml"
include: "/views/hubspot/*.view.lkml"
include: "/views/netsuite/*.view.lkml"

explore: hs_kto {
  label: "KTO"
  view_label: "KTO"
  join: hs_customer {
    view_label: "Company"
    type: left_outer
    relationship: many_to_one
    sql_on: CAST((${hs_kto.company_id}) AS STRING) = CAST((${hs_customer.id}) AS STRING) ;;
  }
  join: hs_owner {
    type: left_outer
    relationship: many_to_one
    sql_on: ${hs_customer.owner_id} = ${hs_owner.id} ;;
    fields: []
  }
  join: ns_employee {
    view_label: "Employee"
    type: left_outer
    relationship: one_to_one
    sql_on: ${hs_owner.email} = ${ns_employee.email} ;;
  }
}

explore: hs_contact_lifecycle {
  view_label: "Funnel"
  label: "Contact Funnel"

  join: hs_contact {
    view_label: "Contact"
    type: left_outer
    relationship: many_to_one
    sql_on: ${hs_contact_lifecycle.contact_id} = ${hs_contact.id} ;;
  }

  join: hs_contact_conversions {
    view_label: "Conversions"
    type: left_outer
    relationship: many_to_one
    sql_on: ${hs_contact_lifecycle.contact_id} = ${hs_contact_conversions.contact_id} ;;
  }
}
