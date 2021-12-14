%dw 2.0
output application/java
---
 (payload map (dfuMovingEventMap, indexOfEvent) -> {
 		MS_BULK_REF: dfuMovingEventMap.MS_BULK_REF,
		MS_REF: dfuMovingEventMap.MS_REF,
 		INTEGRATION_STAMP: dfuMovingEventMap.INTEGRATION_STAMP,
		DMDUNIT: dfuMovingEventMap.DMDUNIT,
		DMDGROUP: dfuMovingEventMap.DMDGROUP,
		LOC: dfuMovingEventMap.LOC,
		MOVINGEVENT: dfuMovingEventMap.MOVINGEVENT,
		(vars.deleteudc): 'Y'
   
  })