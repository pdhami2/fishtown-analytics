select *
from {{ source('prod', 'devices') }}