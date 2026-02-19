view: department {
  sql_table_name: `adwise-fivetran.fvt_netsuite2_datawarehouse.department` ;;

  dimension: id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: department_name {
    label: "Department"
    type: string
    sql: ${TABLE}.parent_name ;;
  }

  dimension: sub_department_name {
    label: "Sub-department"
    type: string
    sql: ${TABLE}.name ;;
  }

   }
