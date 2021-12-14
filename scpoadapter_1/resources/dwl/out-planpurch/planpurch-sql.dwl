%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from PLANPURCH" ++ " where " ++ vars.filterCondition
else	
	"select * from PLANPURCH"
