connection: "adwise_fivetran"

include: "/views/hubspot/transformations/*.view.lkml"
include: "/views/hubspot/*.view.lkml"

explore: hs_kto {
  label: "KTO"
  view_label: "KTO"
  join: hs_customer {
    view_label: "Company"
    type: left_outer
    relationship: many_to_one
    sql_on: CAST((${hs_kto.company_id}) AS STRING) = CAST((${hs_customer.id}) AS STRING) ;;
  }
}

explore: hs_contact_lifecycle {
  view_label: "Funnel"
  label: "Contact Funnel"

  join: hs_contact {
    type: left_outer
    relationship: many_to_one
    sql_on: ${hs_contact_lifecycle.contact_id} = ${hs_contact.id} ;;
  }
}
