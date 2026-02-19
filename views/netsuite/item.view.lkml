view: item {
  sql_table_name: `adwise-fivetran.fvt_netsuite2_datawarehouse.item` ;;

  dimension: id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: department_id {
    hidden: yes
    sql: ${TABLE}.department ;;
  }

  dimension: item_name {
    label: "Item"
    type: string
    sql: ${TABLE}.fullname ;;
    link: {
      label: "Netsuite item page"
      url: "https://3883209.app.netsuite.com/app/common/item/item.nl?id={{ id }}"
    }
  }

  dimension: item_type {
    label: "Item type"
    type: string
    sql: ${TABLE}.producttype ;;
  }

  dimension: contract_item {
    label: "Is contract item"
    type: yesno
    sql: ${TABLE}.contractitem = "T" ;;
  }

  dimension: productized {
    label: "Productized / Custom"
    type: string
    sql:
    CASE
      WHEN ${TABLE}.productized = 1 THEN 'Productized'
      WHEN ${TABLE}.productized = 2 THEN 'Custom'
      ELSE NULL
    END ;;
  }

  dimension: packaged {
    label: "Is packaged"
    type: yesno
    sql: ${TABLE}.packageditem ;;
  }

  measure: base_price {
    label: "Base price"
    type: number
    sql: ${TABLE}.baseprice ;;
    value_format_name: eur
  }

  measure: cost_price {
    label: "Cost price"
    type: number
    sql: ${TABLE}.costprice ;;
    value_format_name: eur
  }

  measure: margin_eur {
    label: "Margin (€)"
    type: number
    sql: ${base_price} - ${cost_price} ;;
    value_format_name: eur
  }

  measure: margin_pct {
    label: "Margin (%)"
    type: number
    sql: SAFE_DIVIDE(${base_price} - ${cost_price}, ${base_price}) ;;
    value_format_name: percent_1
  }
   }
