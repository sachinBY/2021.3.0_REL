%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map(vehicleLoad, indexOfVehicleLoad) -> {
 		INTEGRATION_STAMP: vehicleLoad.INTEGRATION_STAMP,
	 	ARRIVDATE: vehicleLoad.ARRIVDATE,
		DESCR: vehicleLoad.DESCR,
		DESTSTATUS: vehicleLoad.DESTSTATUS,
		EXPORTED: vehicleLoad.EXPORTED,
		LBSOURCE: vehicleLoad.LBSOURCE,
		LOADID: vehicleLoad.LOADID,
		LOADSW: vehicleLoad.LOADSW,
		SHIPDATE: vehicleLoad.SHIPDATE,
		SOURCESTATUS: vehicleLoad.SOURCESTATUS,
		TRANSMODE: vehicleLoad.TRANSMODE,
	    (vehicleLoad.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(vehicleLoad.VehicleLoadUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
   
  })