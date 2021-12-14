%dw 2.0
output application/csv
var udcs = vars.outboundUDCs.projordertotal[0].projordertotal[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map {
	
	"recommendedPurchaseOrderId": $.ORDERID as String default "",
	"type": "RECOMMENDED_ORDER_PROJECTION",
	"orderDetail.orderTotal.unitOfMeasure": $.UOM as String default "",
	"orderDetail.orderTotal.totalOrderQuantityOrAmount": $.QTY,
    (udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval($[udc.scpoColumnName] , upper(udc.dataType)))
	}),
}  	   
