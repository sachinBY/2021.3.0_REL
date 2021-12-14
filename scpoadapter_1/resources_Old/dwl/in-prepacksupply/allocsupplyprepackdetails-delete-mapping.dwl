%dw 2.0
output application/java
---
payload map (value,index) -> {
	MS_BULK_REF: value.MS_BULK_REF,
	MS_REF: value.MS_REF,
	INTEGRATION_STAMP: value.INTEGRATION_STAMP,
	ITEM: value.ITEM,
	LOC: value.LOC,
	SUPPLYID: value.SUPPLYID,
	(vars.deleteudc): 'Y'
}