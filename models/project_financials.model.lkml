connection: "adwise_fivetran"

include: "/views/netsuite/*.view.lkml"
include: "/views/netsuite/transformations/*.view.lkml"

explore: ns_customer_item_actuals {
  view_label: "Actuals"
  description: "This explore shows the revenue, COGS, and gross margin per month, customer, item, and project based on transactions"
  label: "Project - Actuals"

  join: ns_customer {
    view_label: "Customer"
    relationship: many_to_one
    type: left_outer
    sql_on: ${ns_customer_item_actuals.customer_id} = ${ns_customer.id} ;;
  }

  join: ns_project {
    view_label: "Project"
    relationship: many_to_one
    type: left_outer
    sql_on: ${ns_customer_item_actuals.project_id} = ${ns_project.id} ;;
  }

  join: ns_item {
    view_label: "Item"
    relationship: many_to_one
    type: left_outer
    sql_on: ${ns_customer_item_actuals.item_id} = ${ns_item.id} ;;
  }

  join: ns_department {
    view_label: "Department"
    relationship: many_to_one
    type: left_outer
    sql_on: ${ns_customer_item_actuals.department_id}= ${ns_department.id} ;;
  }
}

explore: ns_project_item_revenue {
  view_label: "Revenue"
  description: "This explore shows the actual and forecasted revenue on project items (sub-items on packages aggregated)"
  label: "Project - Item Forecast"

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
    sql_on: ${ns_project_item_revenue.department_id}= ${ns_department.id};;
  }
}

explore: ns_project_financials {
  label: "Project - Total Forecast"
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
