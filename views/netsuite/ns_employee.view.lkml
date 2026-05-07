view: ns_employee {
  sql_table_name: `adwise_fivetran.fvt_netsuite2_datawarehouse` ;;

  dimension: employee_id {
    hidden: yes
    sql: ${TABLE}.employee_id ;;
  }


}
