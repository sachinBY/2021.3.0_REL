%dw 2.0
output application/json
---
using (
    sql = "SELECT VLL.*,VL.APPROVALSTATUS as APPROVALSTATUS FROM VEHICLELOAD VL, VEHICLELOADLINE VLL where VL.LOADID = VLL.LOADID"
)
if (vars.filterCondition != null)
   sql ++ " AND " ++ vars.filterCondition
  else 
  	sql