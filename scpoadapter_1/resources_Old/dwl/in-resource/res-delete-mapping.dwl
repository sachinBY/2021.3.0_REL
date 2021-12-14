%dw 2.0
output application/java  
---
(payload map (resource, indexOfresource) -> {  	 
	MS_BULK_REF: resource.MS_BULK_REF,
	MS_REF: resource.MS_REF,	
	INTEGRATION_STAMP: resource.INTEGRATION_STAMP, 	
    RES: resource.RES,
    (vars.deleteudc): 'Y'
    })
