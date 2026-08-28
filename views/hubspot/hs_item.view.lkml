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

  dimension: departmentid {
    hidden: yes
    sql: ${TABLE}.departmentid ;;
  }

  dimension: item_name {
    label: "Item"
    description: "The name of the HubSpot line item"
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: item_type {
    label: "Item type"
    description: "The HubSpot product type of the line item"
    type: string
    sql: ${TABLE}.producttype ;;
  }
   }
