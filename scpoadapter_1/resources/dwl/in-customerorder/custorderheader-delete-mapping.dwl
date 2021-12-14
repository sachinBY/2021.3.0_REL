%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (custOrderHeader, indexOfCustOrderHeader) -> {
 	    MS_BULK_REF: custOrderHeader.MS_BULK_REF,
	    MS_REF: custOrderHeader.MS_REF,
 		INTEGRATION_STAMP: custOrderHeader.INTEGRATION_STAMP,
		CUST: custOrderHeader.CUST,
		EXTREF: custOrderHeader.EXTREF,
		(vars.deleteudc): 'Y'
    })