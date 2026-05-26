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
    sql: ${TABLE}.title ;;
  }

  dimension: email {
    sql: ${TABLE}.email ;;
  }

  dimension: name {
    sql: ${TABLE}.name ;;
  }

  dimension: billing_class {
    label: "Billing class"
    sql: ${TABLE}.billingclass ;;
  }

  dimension: squad {
    sql: ${TABLE}.squad ;;
  }




}
