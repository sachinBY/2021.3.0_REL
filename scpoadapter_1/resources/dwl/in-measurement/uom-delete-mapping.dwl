%dw 2.0
output application/java
---
(payload map (uom, indexOfUom) -> {
	INTEGRATION_STAMP: uom.INTEGRATION_STAMP,
	UOM: uom.UOM,
	(vars.deleteudc): 'Y' 
})
