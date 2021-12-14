%dw 2.0
output application/json encoding = "UTF-8"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.skuhist[0].skuhist[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.skuhist.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: p('scpo.outbound.skuhist.identifier'),
		messageId: uuid(),
		"type": p("scpo.outbound.skuhist.messagetype"),
		creationDateAndTime: now()
	},
	demandHistory: (payload map {
		creationDateTime: now(),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		itemId: $.ITEM,
		locationId: $.LOC,
		durationInMinutes: $.DUR,
		demandQuantity: {
			value: $.QTY
		},
		startDateTime: $.STARTDATE,
		isNetTotalHistory: if ( $.TYPE==1 ) true else false
	})
}
