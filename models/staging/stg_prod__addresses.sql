select *
from {{ source('prod', 'addresses') }}