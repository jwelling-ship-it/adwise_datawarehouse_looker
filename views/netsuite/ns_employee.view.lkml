view: ns_employee {
  sql_table_name: `adwise-fivetran.fvt_netsuite2_datawarehouse.employee` ;;

  dimension: employee_id {
    hidden: yes
    sql: ${TABLE}.employee_id ;;
  }

  dimension: department_id {
    hidden: yes
    sql: ${TABLE}.department_id ;;
  }

  dimension: title {
    label: "Job title"
    description: "The employee's job title"
    sql: ${TABLE}.title ;;
  }

  dimension: email {
    description: "The employee's email address"
    sql: ${TABLE}.email ;;
  }

  dimension: name {
    description: "The employee's full name"
    sql: ${TABLE}.name ;;
  }

  dimension: billing_class {
    label: "Billing class"
    description: "The NetSuite billing class of the employee"
    sql: ${TABLE}.billingclass ;;
  }

  dimension: squad {
    description: "The squad/team the employee belongs to"
    sql: ${TABLE}.squad ;;
  }




}
