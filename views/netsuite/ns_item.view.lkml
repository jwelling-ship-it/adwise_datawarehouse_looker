view: ns_item {
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
    description: "The full NetSuite item name"
    type: string
    sql: ${TABLE}.fullname ;;
    link: {
      label: "Netsuite item page"
      url: "https://3883209.app.netsuite.com/app/common/item/item.nl?id={{ id }}"
    }
  }

  dimension: item_displayname {
    label: "Item display name"
    description: "The customer-facing display name of the item"
    type: string
    sql: ${TABLE}.displayname ;;
    link: {
      label: "Netsuite item page"
      url: "https://3883209.app.netsuite.com/app/common/item/item.nl?id={{ id }}"
    }
  }

  dimension: product_type {
    label: "Product type"
    description: "The product type of the item"
    type: string
    sql: ${TABLE}.producttype ;;
  }

  dimension: item_type {
    label: "Item type"
    description: "The NetSuite item type (e.g. service, inventory, non-inventory)"
    type: string
    sql: ${TABLE}.itemtype ;;
  }

  dimension: contract_item {
    label: "Is contract item"
    description: "Whether this item is billed as a contract item"
    type: yesno
    sql: ${TABLE}.contractitem = "T" ;;
  }

  dimension: productized {
    label: "Productized / Custom"
    description: "Whether the item is a standardized, productized offering or a custom one"
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
    description: "Whether this item is a package/bundle of other items"
    type: yesno
    sql: ${TABLE}.packageditem ;;
  }

  measure: base_price {
    label: "Base price"
    description: "The list/base price of the item"
    type: number
    sql: ${TABLE}.baseprice ;;
    value_format_name: eur
  }

  measure: cost_price {
    label: "Cost price"
    description: "The cost price of the item"
    type: number
    sql: ${TABLE}.costprice ;;
    value_format_name: eur
  }

  measure: margin_eur {
    label: "Margin (€)"
    description: "Base price minus cost price"
    type: number
    sql: ${base_price} - ${cost_price} ;;
    value_format_name: eur
  }

  measure: margin_pct {
    label: "Margin (%)"
    description: "Margin as a percentage of base price"
    type: number
    sql: SAFE_DIVIDE(${base_price} - ${cost_price}, ${base_price}) ;;
    value_format_name: percent_1
  }

  measure: count_distinct {
    type: count_distinct
    description: "Count of distinct items"
    sql: ${id} ;;
    drill_fields: [ns_item.item_name]
  }
   }
