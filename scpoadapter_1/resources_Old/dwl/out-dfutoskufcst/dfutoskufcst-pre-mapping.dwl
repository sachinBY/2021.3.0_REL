%dw 2.0
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var DEFAULT_VALUE='DEFAULT'
var forecastTypeCodeForFcst=vars.codeMap.forecastTypeCodeForFcst
output application/java
---
(payload groupBy ((item, index) -> item.ITEM ++ "-" ++ item.SKULOC ++ "-" ++ item.DMDGROUP ++ "-" ++ item.TYPE ++ "-" ++ item.STARTDATE ++ "-" ++ item.DUR) mapObject ((value, key, index) -> values:{
    ITEM: value.ITEM[0],
 	SKULOC: value.SKULOC[0],
 	DMDGROUP: value.DMDGROUP[0],
 	TYPE: if(value.TYPE[0] != null) forecastTypeCodeForFcst[value.TYPE[0]][0] else DEFAULT_VALUE,
 	STARTDATE: value.STARTDATE[0] >> "UTC",
 	DUR: value.DUR[0],
 	TOTFCST: sum(value.TOTFCST)
}
)).*values