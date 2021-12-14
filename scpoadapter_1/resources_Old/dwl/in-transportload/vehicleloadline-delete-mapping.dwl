%dw 2.0
output application/java
---
 (payload map (vehicleLoadLine, indexOfVehicleLoadLineData) -> {
 	LOADID: vehicleLoadLine.LOADID,
 	PRIMARYITEM: vehicleLoadLine.PRIMARYITEM,
 	EXPDATE: vehicleLoadLine.EXPDATE,
 	EXPDATE: vehicleLoadLine.EXPDATE,
 	DEST: vehicleLoadLine.DEST,
 	(vars.deleteudc): 'Y'
  })