with prod_orders as (

    select 
    distinct
        order_id
    from {{ ref('stg_prod__orders')}}
          
),

core_orders as (

    select 
    distinct 
       order_id
    from {{ ref('core__orders')}}
          
)

select *
from core__orders
where order_id NOT IN (select * from prod_orders)