%dw 2.0
import * from dw::core::Strings
output application/json encoding = "UTF-8"
var udcs = vars.outboundUDCs.skueffinventoryparam[0].skueffinventoryparam[0]
var DEFAULT_VALUE='DEFAULT'
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.skueffinventoryparam.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: p('scpo.outbound.skueffinventoryparam.identifier'),
		messageId: uuid(),
		"type": p("scpo.outbound.skueffinventoryparam.messagetype"),
		creationDateAndTime: now()
	},
	itemLocationEffectiveInventoryParameters: flatten(payload groupBy ($.PRIMEKEY) pluck($) map(groupedData , index)->{
		creationDateTime: now() as DateTime,
		documentStatusCode: "ORIGINAL",
		documentActionCode: "ADD",
		itemLocationEffectiveInventoryParametersId: {
			item: {
				primaryId: groupedData.ITEM[0]
			},
			location: {
				primaryId: groupedData.LOC[0]
			}
		},
		(avpList: (filter(udcs, (element, index) -> groupedData[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: groupedData[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		effectiveInventoryParameters: (groupedData map {
			effectiveFromDateTime: $.EFF as DateTime,
			maximumCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MAXCOVDUR
			},
			maximumOnHandQuantity: {
				measurementUnitCode: "EA",
				value: $.MAXOHQTY
			},
			minimumSafetyStockQuantity: {
				measurementUnitCode: "EA",
				value: $.MINSSQTY
			},
			safetyStockCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.SSCOVDUR
			}
		})
	})
}