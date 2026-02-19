view: subsidiary {
  sql_table_name: `adwise-fivetran.df_dev_looks.adwi_look_subsidiary`;;

  dimension: id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: subsidiary {
    type: string
    sql: ${TABLE}.name ;;
  }

  }
