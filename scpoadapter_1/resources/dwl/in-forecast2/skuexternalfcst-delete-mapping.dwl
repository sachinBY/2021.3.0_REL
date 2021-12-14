%dw 2.0
output application/java
---
payload map (forecast, indexOfForecast) -> {
	MS_BULK_REF: forecast.MS_BULK_REF,
	MS_REF: forecast.MS_REF,
	INTEGRATION_STAMP: forecast.INTEGRATION_STAMP,
	(ITEM: forecast.ITEM),
	(LOC: forecast.LOC) ,
	(STARTDATE: forecast.STARTDATE),
	(PROJECT: forecast.PROJECT),
	(vars.deleteudc): 'Y' 
}