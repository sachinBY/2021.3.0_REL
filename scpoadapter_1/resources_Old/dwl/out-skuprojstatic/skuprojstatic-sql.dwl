%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"SELECT * FROM SKUPROJSTATIC" ++ " where " ++ vars.filterCondition
else	
	"SELECT * FROM SKUPROJSTATIC"
