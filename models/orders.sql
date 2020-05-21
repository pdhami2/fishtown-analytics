{{ config(materialized='table') }}

with payments_aggregated as ( 

    select 
        order_id
      , sum( case when status = 'completed' then tax_amount_cents else 0 end ) as gross_tax_amount_cents
      , sum( case when status = 'completed' then amount_cents else 0 end ) as gross_amount_cents
      , sum( case when status = 'completed' then amount_shipping_cents else 0 end ) as gross_shipping_amount_cents
      , sum( case when status = 'completed' then tax_amount_cents + amount_cents + amount_shipping_cents else 0 end ) as gross_total_amount_cents 
    from `fa--interview-task.interview.payments` 
    group by order_id 
    
),

first_order as (
    
    select 
         fo.user_id
       , min(fo.order_id) as first_order_id 
    from `fa--interview-task.interview.orders` as fo 
    where fo.status != 'cancelled' 
    group by fo.user_id 
    
),

devices as (

    select
         distinct 
         cast(d.type_id as int64) as order_id
       , first_value(d.device) over ( partition by d.type_id order by d.created_at rows between unbounded preceding and unbounded following ) as device    
    from `fa--interview-task.interview.devices` d 
    where d.type = 'order'
     
),

joined as (

    select 
         o.order_id
       , o.user_id
       , o.created_at
       , o.updated_at
       , o.shipped_at
       , o.currency
       , o.status as order_status
       , case when o.status in ( 'paid', 'completed', 'shipped' ) 
              then 'completed' else o.status 
         end as order_status_category
       , case when oa.country_code is null then 'Null country' 
              when oa.country_code = 'US' then 'US'
              when oa.country_code != 'US' then 'International' 
         end as country_type
       , o.shipping_method
       , case when d.device = 'web' then 'desktop' 
              when d.device IN ('ios-app', 'android-app') then 'mobile-app' 
              when d.device IN ('mobile', 'tablet') then 'mobile-web' 
              when NULLIF(d.device, '') is null then 'unknown' 
              else 'ERROR' 
         end as purchase_device_type
       , d.device AS purchase_device
       , case when fo.first_order_id = o.order_id then 'new' 
             else 'repeat' 
         end as user_type 
       , o.amount_total_cents
       , pa.gross_total_amount_cents
       , case when o.currency = 'USD' then o.amount_total_cents 
             else pa.gross_total_amount_cents 
         end as total_amount_cents
       , pa.gross_tax_amount_cents
       , pa.gross_amount_cents
       , pa.gross_shipping_amount_cents 
    from `fa--interview-task.interview.orders` o 
    left join devices as d 
    on d.order_id = o.order_id 

    left join first_order as fo 
    on o.user_id = fo.user_id 

    left join `fa--interview-task.interview.addresses` oa 
    on oa.order_id = o.order_id 
    left join  payments_aggregated as pa 
    on pa.order_id = o.order_id

)

select
       *
    , amount_total_cents / 100 as amount_total
    , gross_total_amount_cents/ 100 as gross_total_amount
    , total_amount_cents/ 100 as total_amount
    , gross_tax_amount_cents/ 100 as gross_tax_amount
    , gross_amount_cents/ 100 as gross_amount
    , gross_shipping_amount_cents/ 100 as gross_shipping_amount 
from joined
