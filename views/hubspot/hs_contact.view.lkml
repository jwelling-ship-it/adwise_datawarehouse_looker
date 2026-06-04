view: hs_contact {
  sql_table_name: `adwise-fivetran.fvt_hubspot_datawarehouse.contact` ;;

  dimension: id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: email {
    sql: ${TABLE}.email ;;
  }

  dimension: name {
    sql: ${TABLE}.name ;;
  }

  dimension: stage {
    sql: ${TABLE}.lifecyclestage ;;
  }

  dimension: source {
    sql: ${TABLE}.lead_source ;;
  }

  dimension: company {
    sql: ${TABLE}.companyname ;;
  }

}
