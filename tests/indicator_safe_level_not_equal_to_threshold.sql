select
    series_id
    
from {{ ref('indicator_registry') }}
where safe_level = threshold