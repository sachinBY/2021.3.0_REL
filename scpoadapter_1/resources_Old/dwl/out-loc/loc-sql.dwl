%dw 2.0
output application/json
---
using (
    sql = "SELECT * FROM LOC"
)
if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition
  else 
  	sql