select *
from {{ source('prod', 'orders') }}