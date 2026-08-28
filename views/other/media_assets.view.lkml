view: media_assets {
  sql_table_name: `adwise-fivetran.df_dev_seeds.media_assets` ;;

  dimension: id {
    primary_key: yes
    type: number
    description: "The media asset record ID"
    sql: ${TABLE}.id ;;
  }

  dimension: name {
    type: string
    description: "The name of the media asset"
    sql: ${TABLE}.name ;;
  }

  dimension: description {
    type: string
    description: "The description of the media asset"
    sql: ${TABLE}.description ;;
  }


  dimension_group: production {
    type: time
    timeframes: [date, month, quarter, year]
    datatype: date
    description: "The date the media asset was produced"
    sql: ${TABLE}.production_date ;;
  }

  dimension: active {
    type: yesno
    description: "Whether the media asset is currently active"
    sql: ${TABLE}.active ;;
  }

  dimension: status_value {
    hidden: yes
    type: number
    sql: ${TABLE}.status_value ;;
  }

  dimension: status_label {
    label: "Status"
    description: "The current status of the media asset"
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
    description: "The type/category of the media asset"
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
    description: "The name of the customer the media asset belongs to"
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
    description: "The name of the person who reported/created the media asset"
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
    description: "Count of distinct media assets"
    sql: ${id} ;;
    drill_fields: [name, department_name, customer_name, reporter_name, production_month]
  }
}
