%dw 2.0
output application/json encoding = "UTF-8"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.projordersummarydetail[0].projordersummarydetail[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.projordersummarydetail.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: p('scpo.outbound.projordersummarydetail.identifier'),
		messageId: uuid(),
		"type": p("scpo.outbound.projordersummarydetail.messagetype"),
		creationDateAndTime: now()
	},
	recommendedPurchaseOrder: (payload map {
		creationDateTime: now(),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "ADD",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		recommendedPurchaseOrderId: $.ORDERID as String default "",
		"type": "RECOMMENDED_ORDER_PROJECTION",
		orderDetail: {
			delayDuration: {
				value: $.DELAYDUR,
				timeMeasurementUnitCode: "DAY"
			},
			finalCoverageDuration: {
				value: $.FINALCOVDUR,
				timeMeasurementUnitCode: "DAY"
			},
			minimumCoverageDuration: {
				value: $.MINCOVDUR,
				timeMeasurementUnitCode: "DAY"
			},
			minimumCoverageDate: $.MINCOVDATE as Date {
				format: "yyyy-MM-dd", class : "java.sql.Date"
			},
			orderCoverageDuration: {
				value: $.NEEDCOVDUR,
				timeMeasurementUnitCode: "DAY"
			},
			orderProcessingDate: $.SOURCEPROCESSINGDATE as Date {
				format: "yyyy-MM-dd", class : "java.sql.Date"
			},
			orderGroupBuildRule: if ( $.ORDERGROUPBUILDRULE == 0 ) "NONE" else if ( $.ORDERGROUPBUILDRULE == 1 ) "BUILD_TO_GROUP" else if ( $.ORDERGROUPBUILDRULE == 2 ) "BUILD_TO_MEMBER" else "NONE"
		}
	})
}
