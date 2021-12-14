%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from ORDERLINK" ++ " where " ++ vars.filterCondition
else	
	"select * from ORDERLINK"
