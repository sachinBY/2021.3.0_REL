%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from PLANARRIV" ++ " where " ++ vars.filterCondition
else	
	"select * from PLANARRIV"
