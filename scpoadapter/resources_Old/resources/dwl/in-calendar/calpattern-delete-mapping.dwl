%dw 2.0
output application/java
---
(payload map (calendarPattern, calendarPatternPatternIndex) -> {
	//How to mitigate pattern sequence number
	MS_BULK_REF: calendarPattern.MS_BULK_REF,
	MS_REF: calendarPattern.MS_REF,
	CAL: calendarPattern.CAL,
	(vars.deleteudc): 'Y' 
})
