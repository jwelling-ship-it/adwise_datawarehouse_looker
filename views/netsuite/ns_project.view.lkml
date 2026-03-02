view: ns_project {
  sql_table_name: `adwise-fivetran.fvt_netsuite2_datawarehouse.project` ;;

  dimension: id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: customer_id {
    hidden: yes
    sql: ${TABLE}.customer ;;
  }

  dimension_group: created {
    description: "The date of creation for the project"
    type: time
    datatype: date
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.datecreated ;;
  }

  dimension_group: start {
    description: "The start date for the project"
    type: time
    datatype: date
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.startdate ;;
  }

  dimension_group: end {
    description: "The end date for the project"
    type: time
    datatype: date
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}.calculatedenddate ;;
  }

  dimension: project_name {
    label: "Project"
    type: string
    sql: ${TABLE}.project_name ;;
  }

  dimension: project_type {
    label: "Project type"
    type: string
    sql: ${TABLE}.jobtype ;;
  }

   }
