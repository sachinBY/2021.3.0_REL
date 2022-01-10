%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload map (sourcingconv, indexOfsourcingconv) -> {
		MS_BULK_REF: sourcingconv.MS_BULK_REF,
		MS_REF: sourcingconv.MS_REF,
		INTEGRATION_STAMP: sourcingconv.INTEGRATION_STAMP,
		DEST: sourcingconv.DEST,
		ITEM: sourcingconv.ITEM,
		SOURCE: sourcingconv.SOURCE,
		SOURCECATEGORY: sourcingconv.SOURCECATEGORY,
		TARGETCATEGORY: sourcingconv.TARGETCATEGORY,
		TRANSMODE: sourcingconv.TRANSMODE,
		(vars.deleteudc): 'Y'
  })