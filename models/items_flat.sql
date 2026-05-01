select
    r.data:id::int as id,
    item.value:item_id::int as item_id,
    item.value:price::number as price
from SAI.PUBLIC.raw_json_data r,
lateral flatten(input => r.data:nested.items) item