%dw 2.0
output application/java
---
(payload map (uomCategory, indexOfUomCategory) -> {
	MS_BULK_REF: uomCategory.MS_BULK_REF,
	MS_REF: uomCategory.MS_REF,
	INTEGRATION_STAMP: uomCategory.INTEGRATION_STAMP,
	CATEGORY: uomCategory.CATEGORY,
	(vars.deleteudc): 'Y' 
})
