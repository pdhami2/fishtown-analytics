{% snapshot orders_snapshot %}
{{
    config(
      target_database='dbt-analytics-00',
      target_schema='snapshots',
      unique_key='order_id',
      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * 
from {{ source('prod', 'orders') }}
{% endsnapshot %}