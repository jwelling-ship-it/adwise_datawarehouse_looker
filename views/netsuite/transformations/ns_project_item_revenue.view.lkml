view: ns_project_item_revenue {
  sql_table_name: `adwise-fivetran.adwise_datawarehouse.fact_project_item_revenue_monthly` ;;

  dimension: charge_id {
    hidden: yes
    sql: ${TABLE}.charge_id ;;
  }

  dimension: project_id {
    hidden: yes
    sql: ${TABLE}.project_id ;;
  }

  dimension: customer_id {
    hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension: department_id {
    hidden: yes
    sql: ${TABLE}.effective_department_id ;;
  }

  dimension: item_id {
    hidden: yes
    sql: ${TABLE}.effective_item_id ;;
  }

  dimension: groupitem_id {
    hidden: yes
    sql: ${TABLE}.groupitem_id ;;
  }

  dimension: subsidiary_id {
    hidden: yes
    sql: ${TABLE}.subsidiary_id ;;
  }

  dimension_group: row {
    description: "The date of project financial entry"
    type: time
    datatype: date
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.row_date ;;
  }

  dimension: billing_type {
    hidden: yes
    label: "Contract / Milestone"
    description: "The billing type of project items"
    type: string
    sql: ${TABLE}.use_type ;;
  }

  dimension: billing_frequency {
    label: "Billing frequency"
    description: "The billing frequency of project contract items"
    type: string
    sql:
    CASE
      WHEN ${TABLE}.billing_period IN (1, 4) THEN 'Monthly'
      WHEN ${TABLE}.billing_period IN (2, 5) THEN 'Quarterly'
      WHEN ${TABLE}.billing_period = 6 THEN 'Semi-Annual'
      WHEN ${TABLE}.billing_period = 3 THEN 'Yearly'
      ELSE NULL
    END ;;
  }

  measure: item_revenue {
    label: "Revenue"
    description: "Revenue on project items"
    type: sum
    sql: ${TABLE}.revenue ;;
    value_format_name: eur
  }

  measure: item_contract_revenue {
    label: "Contract revenue"
    description: "Revenue on project contract items"
    type: sum
    sql: ${TABLE}.revenue ;;
    value_format_name: eur
    filters: [
      billing_type: "Forecast contract"
    ]
  }

  measure: item_milestone_revenue {
    label: "Milestone revenue"
    description: "Revenue on project milestone items"
    type: sum
    sql: ${TABLE}.revenue ;;
    value_format_name: eur
    filters: [
      billing_type: "Forecast milestone"
    ]
  }

  measure: monthly_recurring_revenue {
    label: "Monthly recurring revenue (MRR)"
    description: "Revenue on project contract items that are billed monthly"
    type: sum
    sql: ${TABLE}.revenue ;;
    value_format_name: eur
    filters: [
      billing_frequency: "Monthly"
    ]
  }

  measure: count_customers {
    label: "# Customers"
    type: count_distinct
    sql: ${customer_id} ;;
    drill_fields: [ns_customer.customer_name, ns_item.item_name, ns_project_product_revenue.item_revenue]
  }




  }
