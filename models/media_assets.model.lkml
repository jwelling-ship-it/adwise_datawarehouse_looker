connection: "adwise_fivetran"

include: "/views/netsuite/*.view.lkml"
include: "/views/other/*.view.lkml"

explore: media_assets {
  join: ns_department {
    view_label: "Department"
    type: left_outer
    relationship: many_to_one
    sql_on: ${media_assets.department_name} = ${ns_department.sub_department_name} ;;
  }
}
