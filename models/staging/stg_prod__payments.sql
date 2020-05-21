select *
from {{ source('prod', 'payments') }}