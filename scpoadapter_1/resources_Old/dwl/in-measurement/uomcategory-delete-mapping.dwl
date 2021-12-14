%dw 2.0
output application/java
---
(payload map (uomCategory, indexOfUomCategory) -> {
	INTEGRATION_STAMP: uomCategory.INTEGRATION_STAMP,
	CATEGORY: uomCategory.CATEGORY,
	(vars.deleteudc): 'Y' 
})
