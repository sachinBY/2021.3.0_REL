%dw 2.0
output application/java
---
 (payload distinctBy $.MOVINGEVENT map (movingEvent, indexOfEvent) -> {
 	MS_BULK_REF: movingEvent.MS_BULK_REF,
	MS_REF: movingEvent.MS_REF,
 	INTEGRATION_STAMP: movingEvent.INTEGRATION_STAMP,
    MOVINGEVENT: movingEvent.MOVINGEVENT,
    (vars.deleteudc): 'Y'
  })