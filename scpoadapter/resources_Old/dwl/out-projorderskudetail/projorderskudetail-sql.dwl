%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select PROJORDERSKUDETAIL.*,ITEM.UOM from PROJORDERSKUDETAIL,ITEM where PROJORDERSKUDETAIL.ITEM = ITEM.ITEM" ++ " AND " ++ vars.filterCondition
else	
	"select PROJORDERSKUDETAIL.*,ITEM.UOM from PROJORDERSKUDETAIL,ITEM where PROJORDERSKUDETAIL.ITEM = ITEM.ITEM"
