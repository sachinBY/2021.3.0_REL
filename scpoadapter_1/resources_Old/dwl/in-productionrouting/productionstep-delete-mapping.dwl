%dw 2.0
output application/java
---
(payload map (productionStep, indexofproductionStep) -> {
		MS_BULK_REF: productionStep.MS_BULK_REF,
		MS_REF: productionStep.MS_REF,
	    INTEGRATION_STAMP: productionStep.INTEGRATION_STAMP,
		PRODUCTIONMETHOD:  productionStep.PRODUCTIONMETHOD ,
		STEPNUM:  productionStep.STEPNUM,
		ITEM:  productionStep.ITEM ,
		LOC:  productionStep.LOC ,
		EFF:  productionStep.EFF as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
		(vars.deleteudc): 'Y'
	})