%dw 2.0
output application/java  
---
 (payload map (dfu, indexOfDfu) -> {
 	MS_BULK_REF: dfu.MS_BULK_REF,
	MS_REF: dfu.MS_REF,
 	INTEGRATION_STAMP: dfu.INTEGRATION_STAMP,
    (DMDUNIT: dfu.DMDUNIT) if not dfu.DMDUNIT == null and not dfu.DMDUNIT == "*UNKNOWN",
    (DMDGROUP: dfu.DMDGROUP) if not dfu.DMDGROUP == null and not dfu.DMDGROUP == "*UNKNOWN",
    (LOC: dfu.LOC) if not dfu.LOC == null and not dfu.LOC == "*UNKNOWN",
    (vars.deleteudc): 'Y'
  })