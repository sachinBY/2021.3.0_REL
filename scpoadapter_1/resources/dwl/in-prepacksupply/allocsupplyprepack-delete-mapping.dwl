%dw 2.0
output application/java  
---
 (payload map (prepack, index) -> {
 	MS_BULK_REF: prepack.MS_BULK_REF,
	MS_REF: prepack.MS_REF,
 	INTEGRATION_STAMP: prepack.INTEGRATION_STAMP,
    SUPPLYID: prepack.SUPPLYID,
    (vars.deleteudc): 'Y'
  })