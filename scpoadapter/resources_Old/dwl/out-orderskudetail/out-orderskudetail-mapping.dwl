%dw 2.0
output application/json encoding = "UTF-8"
var dateUtil = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.orderskudetail[0].orderskudetail[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.orderskudetail.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: p('scpo.outbound.orderskudetail.identifier'),
		messageId: uuid(),
		"type": p("scpo.outbound.orderskudetail.messagetype"),
		creationDateAndTime: now()
	},
	recommendedPurchaseOrder: (payload groupBy $.ORDERID pluck {
		documentStatusCode: "ORIGINAL",
		documentActionCode: "ADD",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		recommendedPurchaseOrderId: $$ as String default "",
		"type": "RECOMMENDED_ORDER",
		lineItem: $ map {
			itemId: $.ITEM,
			shipTo: $.DEST,
			requestedShipDate: dateUtil.formatSCPOToGS1($.DEPARTUREDATE),
			lineItemDetail: {
				scheduledDeliveryDate: dateUtil.formatSCPOToGS1($.DELIVERYDATE),
				additionalLoadingDuration: {
					value: $.EXTRALOADDUR as Number,
					timeMeasurementUnitCode: "MIN"
				},
				loadingDuration: {
					value: $.LOADDUR as Number,
					timeMeasurementUnitCode: "MIN"
				},
				unloadingDuration: {
					value: $.UNLOADDUR as Number,
					timeMeasurementUnitCode: "MIN"
				},
				totalLeadTime: {
					value: $.TOTALLEADTIME as Number,
					timeMeasurementUnitCode: "DAY"
				},
				transitDuration: {
					value: $.TRANSITDUR as Number,
					timeMeasurementUnitCode: "DAY"
				}
			}
		}
	})
}
