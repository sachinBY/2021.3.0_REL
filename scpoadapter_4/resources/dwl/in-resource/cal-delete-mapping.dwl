%dw 2.0
output application/java  
---
(payload map (calData, indexOfCal) -> { 
	MS_BULK_REF: calData.MS_BULK_REF,
	MS_REF: calData.MS_REF,	 	  	
	CAL: calData.CAL
    })