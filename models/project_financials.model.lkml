connection: "adwise_fivetran"

include: "/views/netsuite/*.view.lkml"
include: "/views/netsuite/transformations/*.view.lkml"

explore: project_item_revenue {
  view_label: "Revenue"
  description: "This explore shows the actual and forecasted revenue on project items"
  label: "Project Item Revenue"

  sql_always_where: ${project_item_revenue.subsidiary_id} = 4 ;;

  join: item {
    relationship: many_to_one
    type: left_outer
    sql_on: ${project_item_revenue.item_id} = ${item.id} ;;
  }

  join: project {
    relationship: many_to_one
    type: left_outer
    sql_on: ${project_item_revenue.project_id} = ${project.id} ;;
  }

  join: customer {
    relationship: many_to_one
    type: left_outer
    sql_on: ${project_item_revenue.customer_id} = ${customer.id} ;;
  }

  join: department {
    relationship: many_to_one
    type: left_outer
    sql_on: ${project_item_revenue.department_id} = ${department.id} ;;
  }
}

explore: project_financials {
  label: "Project Financials"
  description: "This explore shows the actual and forecasted financials on projects"
  view_label: "Financials"

  sql_always_where: ${project_financials.subsidiary_id} = 4 ;;

  join: project {
    relationship: many_to_one
    type: left_outer
    sql_on: ${project_financials.project_id} = ${project.id} ;;
  }

  join: customer {
    relationship: many_to_one
    type: left_outer
    sql_on: ${project_financials.customer_id} = ${customer.id} ;;
  }

}
