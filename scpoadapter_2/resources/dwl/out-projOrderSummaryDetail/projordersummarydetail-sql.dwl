%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from PROJORDERSUMMARYDETAIL" ++ " where " ++ vars.filterCondition
else	
	"select * from PROJORDERSUMMARYDETAIL"
