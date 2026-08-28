view: hs_customer {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.company` ;;

  dimension: id {
    label: "Customer ID (HubSpot)"
    description: "The HubSpot company record ID"
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: owner_id {
    hidden: yes
    sql: ${TABLE}.owner_id ;;
  }

  dimension: netsuite_id {
    label: "NetSuite ID"
    description: "The matching NetSuite customer ID for this HubSpot company, used to join to NetSuite data"
    type: number
    sql: ${TABLE}.netsuite_customer_id ;;
    value_format_name: id
  }

  dimension: company_name {
    label: "Company"
    description: "The name of the company"
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: lifecyclestage {
    label: "Life cycle stage"
    description: "The current life cycle stage of the company"
  }

  dimension_group: first_order {
    label: "First order"
    description: "The first order date of the customer. Empty if the company has never placed an order"
    type: time
    datatype: datetime
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.firstorderdate ;;
  }

  dimension: sales_type {
    label: "Sales type"
    description: "The sales type of the customer based on their first order date. Empty when the company has never placed an order"
    type: string
    sql: ${TABLE}.salestype ;;
  }

  measure: count {
    type: count_distinct
    description: "Count of distinct companies"
    sql: ${TABLE}.id ;;
  }

   }
