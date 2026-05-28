connection: "adwise_fivetran"

include: "/views/other/*.view.lkml"

explore: bing_ads_spend {
  label: "Bing Ads"
  view_label: "Spend"
}
