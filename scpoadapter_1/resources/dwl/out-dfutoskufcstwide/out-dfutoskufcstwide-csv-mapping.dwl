%dw 2.0
output application/csv
var udcs = vars.outboundUDCs.fcst[0].dfutoskufcstwide[0]
import * from dw::core::Strings
var n = p("scpo.outbound.dfutoskufcstwide.periods") as Number
---
flatten(1 to n map(item,index)->{
(payload filter  $."PERIOD$(item)" != null map {
		(itemId:$.ITEM),
		(locationId:$.SKULOC),
		(demandChannel:$.DMDGROUP),
		
		(forecastTypeCode:$.TYPE as String),	
    	"measure.forecastStartDate": substringBefore($.STARTDATE,"T"),
    	"measure.durationInMinutes": 1440,
		"measure.quantity.value" : $."PERIOD$(item)"
})

})