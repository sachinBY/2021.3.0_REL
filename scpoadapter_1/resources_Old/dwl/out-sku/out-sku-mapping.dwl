%dw 2.0
output application/json encoding = "UTF-8"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.sku[0].sku[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.sku.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: p('scpo.outbound.sku.identifier'),
		messageId: uuid(),
		"type": p("scpo.outbound.sku.messagetype"),
		creationDateAndTime: now()

	},
	itemLocation: (payload map {
		creationDateTime: ($.CREATIONDATE),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "ADD",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		itemLocationId: {
			item: {
				primaryId: $.ITEM
			},
			location: {
				primaryId: $.LOC
			}
		},
		businessInstanceId: $.ENABLEOPT,
		statusCode: "ACTIVE",
		onHandInventoryQuantity: {
			value: $.OH
		},
		onHandInventoryPostingDate: ($.OHPOST) as DateTime,
		resource: [$.RES],
		hasInfiniteSupply: if($.INFINITESUPPLYSW == 0) false else true,
		isStorable: if($.STORABLESW == 0) false else true,
		replenishmentMethod: if($.REPLENMETHOD == 1) 'REPLENISHMENT_ONLY' else if($.REPLENMETHOD == 2) 'ALLOCATION_ONLY' else if($.REPLENMETHOD == 3) 'REPLENISHMENT_AND_ALLOCATION' else null,
		replenishmentType: if($.REPLENTYPE == 1) 'TRANSFERRED' else if($.REPLENTYPE == 2) 'ASSEMBLED' else if($.REPLENTYPE == 4) 'INTERFACE' else if($.REPLENTYPE == 5) 'MPS' else null,
		demandParameters: {
			cumulativeDemandQuantity: {
				value: $.DMDTODATE
			},
			unitCost: {
				currencyCode: "USD",
				value: $.INDDMDUNITCOST
			},
			unitMargin: {
				currencyCode: "USD",
				value: $.INDDMDUNITMARGIN
			},
			unitInventoryCarryingCost: {
				currencyCode: "USD",
				value: $.UNITCARCOST
			},
			unitPrice: {
				currencyCode: "USD",
				value: $.UNITPRICE
			},
			pricingCalendar: $.PRICECAL
		},
		deploymentParameters: {
			initialStockoutCost: {
				currencyCode: "USD",
				value: $.INITSTKOUTCOST
			},
			surplusRestockCost: {
				currencyCode: "USD",
				value: $.SURPLUSRESTOCKCOST
			}
		},
		effectiveInventoryParameters: [{
			effectiveFromDateTime: ($.EFFINV_EFF) as DateTime,
			maximumCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MAXCOVDUR
			},
			maximumOnHandQuantity: {
				measurementUnitCode: "EA",
				value: $.MAXOHQTY
			},
			minimumSafetyStockQuantity: {
				measurementUnitCode: "EA",
				value: $.MINSSQTY
			},
			safetyStockCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.SSCOVDUR
			},
			demandChannel: $.DMDGROUP
		}],
		inventoryOptimizationParameters: {
			averageRequisitionQuantity: {
				measurementUnitCode: "EA",
				value: $.AVGRQSNSIZE
			},
			groupName: $.GROUPNAME,
			annualRequisitionNumber: $.NUMRQSN,
			reviewGroup: $.REVIEWGROUP,
			sensitivityProfile: $.SENSITIVITYPROFILE,
			inventoryOptimizationEffectiveParameters: [{
				backOrderPenaltyAmount: {
					currencyCode: "USD",
					value: $.BACKORDERPENALTY
				},
				coefficientVariation: $.COEFFVAR,
				effectiveFromDate: ($.EFFIO_EFF) as Date{format:"yyyy-MM-dd",class:"java.sql.Date"},
				endOfLifeDemand: $.ENDOFLIFEDMD,
				eventType: $.EVENTTYPE as String,
				handlingCost: {
					currencyCode: "USD",
					value: $.HANDLINGCOST
				},
				holdingCost: {
					currencyCode: "USD",
					value: $.EFFIO_HOLDINGCOST
				},
				inventoryOptimizationServiceProfile: $.IOSERVICEPROFILE,
				maximumReOrderQuantity: {
					measurementUnitCode: "EA",
					value: $.MAXREORDERQTY
				},
				minimumReOrderQuantity: {
					measurementUnitCode: "EA",
					value: $.MINREORDERQTY
				},
				orderCost: {
					currencyCode: "USD",
					value: $.ORDERCOST
				},
				overStockPenaltyAmount: {
					currencyCode: "USD",
					value: $.OVERSTOCKPENALTY
				},
				replenishmentPolicy: $.REPLENPOLICY,
				reviewPeriodDuration: {
					timeMeasurementUnitCode: "MIN",
					value: $.REVIEWPERIOD
				},
				stockOutPenaltyAmount: {
					currencyCode: "USD",
					value: $.STOCKOUTPENALTY
				},
				unitCost: {
					currencyCode: "USD",
					value: $.UNITCOST
				}
			}]
		},
		perishableParameters: {
			shelfLifeDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.SHELFLIFEDUR
			},
			minimumShelfLifeDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MINSHELFLIFEDUR
			},
			minimumShipmentShelfLifeDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MINSHIPSHELFLIFEDUR
			},
			maximumShelfLifeDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MAXSHELFLIFEDUR
			},
		},
		planningParameters: {
			supplyLeadBufferDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.BUFFERLEADTIME
			},
			receiptCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.DRPCOVDUR
			},
			supplyCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MPSCOVDUR
			},
			receiptFrozenDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.DRPFRZDUR
			},
			holdingCost: {
				currencyCode: "USD",
				value: $.PLANPARAM_HOLDINGCOST
			},
			incrementalDRPQuantity: {
				value: $.INCDRPQTY
			},
			incrementalMPSQuantity: {
				value: $.INCMPSQTY
			},
			receivingHandlingCost: {
				currencyCode: "USD",
				value: $.INHANDLINGCOST
			},
			maximumOnHandQuantity: {
				measurementUnitCode: "EA",
				value: $.PLANPARAM_MAXOH
			},
			manufactureDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MFGFRZDUR
			},
			manufactureLeadTimeDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MFGLEADTIME
			},
			minimumDRPQuantity: {
				value: $.MINDRPQTY
			},
			minimumMPSQuantity: {
				value: $.MINMPSQTY
			},
			orderingCost: {
				currencyCode: "USD",
				value: $.ORDERINGCOST
			},
			shippingHandlingCost: {
				currencyCode: "USD",
				value: $.OUTHANDLINGCOST
			},
			shrinkageFactor: $.SHRINKAGEFACTOR,
			useWorkInProgressQuantity: if($.USEWIPSW == 0) false else true,
		},
		safetyStockParameters: {
			safetyStockRuleCode: $.SSRULE as String,
			accumulationDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.ACCUMDUR
			},
			averageReplenishmentLeadDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.AVGLEADTIME
			},
			maximumSafetyStock: {
				measurementUnitCode: "EA",
				value: $.SSPARAM_MAXSS
			},
			minimumSafetyStock: {
				measurementUnitCode: "EA",
				value: $.MINSS
			},
			safetyStockCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.SSCOV
			},
			safetyStockCustomerServiceLevel: $.STATSSCSL
		},
		safetyStockPresentation: [{
			actionCode: "ADD",
			effectiveFromDateTime: ($.SSPR_EFF) as DateTime,
			effectiveUpToDateTime: ($.DISC) as DateTime,
			displayQuantity: {
				measurementUnitCode: "EA",
				value: $.DISPLAYQTY
			},
			presentationQuantity: {
				measurementUnitCode: "EA",
				value: $.PRESENTATIONQTY
			},
			maximumOnHandQuantity: {
				measurementUnitCode: "EA",
				value: $.SSPR_MAXOH
			},
			maximumSafetyStock: {
				measurementUnitCode: "EA",
				value: $.SSPR_MAXSS
			},
		}]
	})
}
