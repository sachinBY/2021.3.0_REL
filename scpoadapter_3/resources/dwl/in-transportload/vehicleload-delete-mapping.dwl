%dw 2.0
output application/java
---
(payload map (vehicleLoad, indexOfVehicleLoad) -> {
	INTEGRATION_STAMP: vehicleLoad.INTEGRATION_STAMP,
	LOADID: vehicleLoad.LOADID,
	(vars.deleteudc): 'Y'
  })