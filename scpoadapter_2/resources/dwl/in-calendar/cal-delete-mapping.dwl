%dw 2.0
output application/java
---
(payload map (calendar, calendarIndex) -> {
	MS_BULK_REF: calendar.MS_BULK_REF,
	MS_REF: calendar.MS_REF,
	CAL: calendar.CAL,
	(vars.deleteudc): 'Y'
})
