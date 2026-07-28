view: media_assets {
  sql_table_name: `adwise-fivetran.df_dev_seeds.media_assets` ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }


  dimension_group: production {
    type: time
    timeframes: [date, month, quarter, year]
    datatype: date
    sql: ${TABLE}.production_date ;;
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}.active ;;
  }

  dimension: status_value {
    hidden: yes
    type: number
    sql: ${TABLE}.status_value ;;
  }

  dimension: status_label {
    label: "Status"
    type: string
    sql: ${TABLE}.status_label ;;
  }

  dimension: media_asset_type_id {
    hidden: yes
    type: number
    sql: ${TABLE}.media_asset_type_id ;;
  }

  dimension: media_asset_type_name {
    label: "Media asset type"
    type: string
    sql: ${TABLE}.media_asset_type_name ;;
  }

  dimension: customer_id {
    hidden: yes
    type: number
    sql: ${TABLE}.customer_id ;;
  }

  dimension: customer_name {
    label: "Customer"
    type: string
    sql: ${TABLE}.customer_name ;;
  }

  dimension: department_id {
    hidden: yes
    type: number
    sql: ${TABLE}.department_id ;;
  }

  dimension: department_name {
    hidden: yes
    label: "Department"
    type: string
    sql: ${TABLE}.department_name ;;
  }

  dimension: industry_id {
    hidden: yes
    type: number
    sql: ${TABLE}.industry_id ;;
  }

  dimension: industry_name {
    hidden: yes
    type: string
    sql: ${TABLE}.industry_name ;;
  }

  dimension: reporter_id {
    hidden: yes
    type: number
    sql: ${TABLE}.reporter_id ;;
  }

  dimension: reporter_name {
    label: "Reporter"
    type: string
    sql: ${TABLE}.reporter_name ;;
  }

  dimension: reporter_email {
    hidden: yes
    type: string
    sql: ${TABLE}.reporter_email ;;
  }

  measure: count {
    type: count_distinct
    sql: ${id} ;;
    drill_fields: [name, department_name, customer_name, reporter_name, production_month]
  }
}
