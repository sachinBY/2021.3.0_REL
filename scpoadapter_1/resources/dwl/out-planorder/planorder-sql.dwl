%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from PLANORDER" ++ " WHERE " ++ vars.filterCondition
else	
	"select * from PLANORDER"
