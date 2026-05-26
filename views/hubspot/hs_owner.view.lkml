view: hs_owner {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.owner` ;;

  dimension: id {
    hidden: yes
    sql: ${TABLE}.id ;;
  }


  dimension: email {
    hidden: yes
    sql: ${TABLE}.email ;;
  }
   }
