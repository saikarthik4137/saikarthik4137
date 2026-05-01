select
    try_cast(r.data:id::string as int) as id,
    try_cast(r.data:name::string as string) as name,
    try_cast(r.data:amount::string as number) as amount,
    try_cast(r.data:is_active::string as boolean) as is_active,
    try_cast(r.data:created_at::string as timestamp) as created_at
from SAI.PUBLIC.raw_json_data r