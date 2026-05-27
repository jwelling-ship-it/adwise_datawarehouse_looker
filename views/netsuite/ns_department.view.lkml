view: ns_department {
  sql_table_name: `adwise-fivetran.fvt_netsuite2_datawarehouse.department` ;;

  dimension: id {
    hidden: yes
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
    value_format_name: id
  }

  dimension: parent_id {
    hidden: yes
    type: number
    sql: ${TABLE}.parent ;;
    value_format_name: id
  }


  dimension: department_name {
    label: "Department"
    type: string
    sql:  REPLACE(${TABLE}.parent_name, '&', 'and') ;;
  }

  dimension: sub_department_name {
    label: "Sub-department"
    type: string
    sql: ${TABLE}.name ;;
  }

   }
