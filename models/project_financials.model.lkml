connection: "adwise_fivetran"

include: "/views/netsuite/*.view.lkml"
include: "/views/netsuite/transformations/*.view.lkml"

explore: ns_project_item_revenue {
  view_label: "Revenue"
  description: "This explore shows the actual and forecasted revenue on project items (sub-items on packages aggregated)"
  label: "Project - Item Revenue"

  sql_always_where: ${ns_project_item_revenue.subsidiary_id} = 4 ;;

  join: ns_item {
    view_label: "Item"
    relationship: many_to_one
    type: left_outer
    sql_on: ${ns_project_item_revenue.item_id} = ${ns_item.id} ;;
  }

  join: ns_project {
    view_label: "Project"
    relationship: many_to_one
    type: left_outer
    sql_on: ${ns_project_item_revenue.project_id} = ${ns_project.id} ;;
  }

  join: ns_customer {
    view_label: "Customer"
    relationship: many_to_one
    type: left_outer
    sql_on: ${ns_project_item_revenue.customer_id} = ${ns_customer.id} ;;
  }

  join: ns_employee {
    view_label: "Employee"
    relationship: many_to_one
    type: left_outer
    sql_on: ${ns_customer.salesrep_id} = ${ns_employee.employee_id} ;;
  }

  join: ns_department {
    view_label: "Department"
    relationship: many_to_one
    type: left_outer
    sql_on: CAST((${ns_project_item_revenue.department_id}) AS STRING) = CAST((${ns_department.id}) AS STRING) ;;
  }
}

explore: ns_project_financials {
  label: "Project - Total Financials"
  description: "This explore shows the total actual and forecasted financials on projects"
  view_label: "Financials"

  sql_always_where: ${ns_project_financials.subsidiary_id} = 4 ;;

  join: ns_project {
    view_label: "Project"
    relationship: many_to_one
    type: left_outer
    sql_on: ${ns_project_financials.project_id} = ${ns_project.id} ;;
  }

  join: ns_customer {
    view_label: "Customer"
    relationship: many_to_one
    type: left_outer
    sql_on: ${ns_project_financials.customer_id} = ${ns_customer.id} ;;
  }

}
