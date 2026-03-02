view: hs_item {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.line_item` ;;

  dimension: id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: sku {
    hidden: yes
    sql: ${TABLE}.sku ;;
  }

  dimension: department_id {
    hidden: yes
    sql: ${TABLE}.departmentid ;;
  }

  dimension: item_name {
    label: "Item"
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: item_type {
    label: "Item type"
    type: string
    sql: ${TABLE}.producttype ;;
  }
   }
