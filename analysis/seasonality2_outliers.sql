--Find the outliers using Interquartile Range
with quartiles as (
    select order_id
      , gross_total_amount_cents
      , ntile(4) over (order by gross_total_amount_cents) as amount_quartile
from `dbt-analytics-00`.`dbt_pdhamija`.`core__orders`),

--Interquartile base range
iqr_base as (
    select amount_quartile
      , max(gross_total_amount_cents) as quartile_break
    from quartiles
    where  amount_quartile in (1,3)
    group by 1
),

--Final IQR as 
iqr_final as (
    select max(quartile_break) - min(quartile_break) as iqr
    from iqr_base
),

iqr_metrics as (
    select 1.5 *iqr as metric
    from iqr_final
)

--Assumtion: Analyzing completed payments in US
select 
      *
--     extract(day from created_at) as day_of_month
--   , round(sum(gross_total_amount_cents),2) as aggregated_gross_amount
from `dbt-analytics-00`.`dbt_pdhamija`.`core__orders`
where gross_total_amount_cents<= (select metric from iqr_metrics )
and country_type = 'US'
and order_status_category = 'completed'
-- group by 1
-- order by 1