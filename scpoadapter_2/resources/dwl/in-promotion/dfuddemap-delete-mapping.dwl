%dw 2.0
output application/java
---
(payload map (promotion, promotionIndex) -> {
		MS_BULK_REF: promotion.MS_BULK_REF,
		MS_REF: promotion.MS_REF,	
	    INTEGRATION_STAMP: promotion.INTEGRATION_STAMP,
		DMDUNIT:  promotion.DMDUNIT,
		DMDGROUP:  promotion.DMDGROUP,			  		
		LOC: promotion.LOC,
		MODEL:  promotion.MODEL,
		DDEPROFILEID : promotion.DDEPROFILEID,
		(vars.deleteudc): 'Y'
})
