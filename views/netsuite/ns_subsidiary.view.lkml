view: ns_subsidiary {
  sql_table_name: `adwise-fivetran.df_dev_looks.adwi_look_subsidiary`;;

  dimension: id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: subsidiary {
    type: string
    description: "The name of the NetSuite subsidiary"
    sql: ${TABLE}.name ;;
  }

  }
