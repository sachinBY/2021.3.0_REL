%dw 2.0
output application/java
---
(payload map (productionMethod,indexofproductionMethod) -> {
		MS_BULK_REF: productionMethod.MS_BULK_REF,
		MS_REF: productionMethod.MS_REF,
	    INTEGRATION_STAMP: productionMethod.INTEGRATION_STAMP,
		PRODUCTIONMETHOD :  productionMethod.PRODUCTIONMETHOD ,
		ITEM:  productionMethod.ITEM ,
		LOC: productionMethod.LOC,
		(vars.deleteudc): 'Y'	
	})