--What percentage of revenue is attributed to first time orders? 

--Assumption: We're interested in the Gross Revenue here

select  round(100*sum( case when user_type = 'new' then gross_tax_amount_cents else 0 end )/ sum(gross_tax_amount_cents),2) as fo_percent_tax_attribution
      , round(100*sum( case when user_type = 'new' then gross_amount_cents else 0 end ) / sum(gross_amount_cents),2) as fo_percent_amount_attribution
      , round(100*sum( case when user_type = 'new' then gross_shipping_amount_cents else 0 end )/ sum(gross_shipping_amount_cents),2) as fo_percent_shipping_attribution
      , round(100*sum(case when user_type = 'new' then gross_total_amount_cents else 0 end )/ sum(gross_total_amount_cents),2) as  fo_percent_total_attribution
from `dbt-analytics-00`.`dbt_pdhamija`.`core__orders`