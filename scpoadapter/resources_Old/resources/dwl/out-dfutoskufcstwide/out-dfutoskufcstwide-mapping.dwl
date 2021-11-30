%dw 2.0
output application/json encoding = "UTF-8"
var udcs = vars.outboundUDCs.fcst[0].fcst[0]
import * from dw::core::Strings
var n = p("scpo.outbound.dfutoskufcstwide.periods") as Number
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.dfutoskufcstwide.receivers") , ",") map {
			(receiver: $) if ($ != null and $ != '')
		}).receiver,
		messageId: uuid(),
		"type": p('scpo.outbound.dfutoskufcstwide.messagetype'),
		creationDateAndTime: now(),
		messageVersion: p('scpo.outbound.dfutoskufcstwide.identifier')
		},
		
		forecast2:flatten((1 to n map(item,index)->{
			value:(payload filter $."PERIOD$(item)" != null map {
			(itemId:$.ITEM),
				(locationId:$.SKULOC),
				(demandChannel:$.DMDGROUP),
			(avpList: 
					(filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
						name: udc.hostColumnName,
						value: $[upper(udc.scpoColumnName)]
					})
			) if (!isEmpty(udcs)),
				(forecastTypeCode:$.TYPE as String),	
				measure:[{
    				forecastStartDate: substringBefore($.STARTDATE,"T"),
    				durationInMinutes: 1440,
					"quantity":{ 
						"value": $."PERIOD$(item)"
						}
						
			}]
			
			
})
}).value)
}