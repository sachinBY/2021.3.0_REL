%dw 2.0
output application/json
---
using (
    sql = "SELECT EFF.ITEM ||'-'||EFF.LOC||'-'|| EFF.EFF AS PRIMEKEY , EFF.* FROM SKUEFFINVENTORYPARAM  EFF"
)
if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition
  else 
  	sql