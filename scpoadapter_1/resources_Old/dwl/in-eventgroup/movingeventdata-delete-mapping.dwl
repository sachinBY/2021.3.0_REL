%dw 2.0
output application/java
---
 (payload map (movingEventData, indexOfEvent) -> {
 	MS_BULK_REF: movingEventData.MS_BULK_REF,
	MS_REF: movingEventData.MS_REF,
 	INTEGRATION_STAMP: movingEventData.INTEGRATION_STAMP,
    MOVINGEVENT: movingEventData.MOVINGEVENT,
    YEAR: movingEventData.YEAR,
    (vars.deleteudc): 'Y'
  })