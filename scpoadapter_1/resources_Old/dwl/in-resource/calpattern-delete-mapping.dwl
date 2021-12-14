%dw 2.0
output application/java  
---
 (payload map (calPattern, indexOfCal) -> { 
 	MS_BULK_REF: calPattern.MS_BULK_REF,
	MS_REF: calPattern.MS_REF,	 	  	
    CAL: calPattern.CAL,
    (vars.deleteudc): 'Y'
    })
