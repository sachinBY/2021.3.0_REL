%dw 2.0
output application/java  
---
(payload map (tranmodeeqp, indexOftransmodeeqp) -> {
	MS_BULK_REF: tranmodeeqp.MS_BULK_REF,
	MS_REF: tranmodeeqp.MS_REF,
	INTEGRATION_STAMP: tranmodeeqp.INTEGRATION_STAMP,
    (TRANSMODE: tranmodeeqp.TRANSMODE) if not tranmodeeqp.TRANSMODE == null,
    (vars.deleteudc): 'Y'
 })