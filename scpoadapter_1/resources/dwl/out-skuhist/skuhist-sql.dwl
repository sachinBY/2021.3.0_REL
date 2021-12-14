%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"SELECT * FROM SKUHIST" ++ " where " ++ vars.filterCondition
else	
	"SELECT * FROM SKUHIST"