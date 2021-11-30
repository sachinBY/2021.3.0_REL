%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var itemUomCatConvFactorEntity = vars.entityMap.item[0].uomcategoryconvfactor[0]
var itemUomCatConvFactorCol = vars.entityMap.item[0].uomcategoryconvfactor[0] groupBy $.scpoColumnName orderBy ($$) pluck ($$)
var entityMap = if (itemUomCatConvFactorEntity != null) unzip((itemUomCatConvFactorEntity map (v,k)->{(payload.data map {((v.scpoColumnName) : if ($[v.scpoColumnName] !=null) true else false)})})) else []
---
 payload map {
 			MS_BULK_REF: $.MS_BULK_REF,
			MS_REF: $.MS_REF, 
 			INTEGRATION_STAMP: $.INTEGRATION_STAMP,
			ITEM: $.ITEM,
			RATIO: $.RATIO,
			SOURCECATEGORY: $.SOURCECATEGORY,
			SOURCEUOM: $.SOURCEUOM,
			TARGETCATEGORY: $.TARGETCATEGORY,
			TARGETUOM: $.TARGETUOM,
			//($ mapObject (value, key)->{
				//((key) :  value) if (itemUomCatConvFactorEntity[(key)][0] !=null)
			//}),
			//(entityMap[$$] map(v,k)-> {
				//((itemUomCatConvFactorCol[(k)]) : default_value) if (v ~= false)
			//})		
}