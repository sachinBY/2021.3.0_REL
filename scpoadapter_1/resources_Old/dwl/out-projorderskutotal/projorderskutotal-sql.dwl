%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from PROJORDERSKUTOTAL" ++ " where " ++ vars.filterCondition
else	
	"select * from PROJORDERSKUTOTAL"
