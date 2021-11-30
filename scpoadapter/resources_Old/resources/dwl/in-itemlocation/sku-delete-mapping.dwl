%dw 2.0
output application/java
---
 (payload map (sku, indexOfsku) -> {
 	MS_BULK_REF: sku.MS_BULK_REF,
	MS_REF: sku.MS_REF,	
	INTEGRATION_STAMP: sku.INTEGRATION_STAMP,
    (ITEM: sku.ITEM) if not sku.ITEM == null,
    (LOC: sku.LOC) if not sku.LOC == null,
    (vars.deleteudc): 'Y'
  })