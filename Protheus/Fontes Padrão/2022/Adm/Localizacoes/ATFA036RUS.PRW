#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ATFA036.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} AF036RUSOI()

Russian function to generate outflow invoice for sold fixed assets

@param		CHARACTER cSeries - Serie for the invoice
@param		CHARACTER cCustomer - Code of the customer (A1_COD)
@param		CHARACTER cCustUnit - Unit of the customer (A1_LOJA)
@param		CHARACTER cPaymCond - Payment condition
@param		CHARACTER cClass - Class of the operation
@param		NUMERIC nSalesCurr - Currency used in sales order
@param		ARRAY aItems
	Invoice items {
		Product code,
		Quantity,
		Unit Price,
		TIO,
		Operation Type,
		Fiscal Code
	}
@return		ARRAY aInvoice {cInvNumber, cInvSerie}
@author 	victor.rezende
@since 		09/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------

Function _AF036RUSOI(cSeries AS CHARACTER, cCustomer AS CHARACTER, cCustUnit AS CHARACTER, cPaymCond AS CHARACTER, cClass AS CHARACTER, nSalesCurr AS NUMERIC, aItems AS ARRAY)

Local nX			AS NUMERIC
Local cQuery		AS CHARACTER
Local cTmpAls		AS CHARACTER
Local cSONumber		AS CHARACTER
Local cInvNumber	AS CHARACTER
Local cInvSerie		AS CHARACTER
Local cIteSO		AS CHARACTER
Local lRet			AS LOGICAL
Local aSOHeader		AS ARRAY
Local aSOItems		AS ARRAY
Local aTmp			AS ARRAY
Local aSOBalances	AS ARRAY
Local aSOBlocked	AS ARRAY
Local aParams		AS ARRAY
Local aInvRegs		AS ARRAY
Local aInvoices		AS ARRAY
Local aArea			AS ARRAY
Local aAreaSC5		AS ARRAY

Private lMsErroAuto	:= .F.

aArea		:= GetArea()
aAreaSC5	:= SC5->(GetArea())
lRet		:= .T.
cInvNumber	:= ""
cInvSerie	:= ""

BEGIN TRANSACTION

// Generate sales order for fixed asset
If lRet
	aSOHeader	:= {}
	aAdd(aSOHeader, { "C5_TIPO",	"N",		Nil })
	aAdd(aSOHeader, { "C5_DOCGER ",	"1",		Nil })	// Generate invoice
	aAdd(aSOHeader, { "C5_CLIENTE",	cCustomer,	Nil })
	aAdd(aSOHeader, { "C5_LOJACLI",	cCustUnit,	Nil })
	aAdd(aSOHeader, { "C5_CONDPAG",	cPaymCond,	Nil })
	aAdd(aSOHeader, { "C5_NATUREZ",	cClass,	Nil })
	If ! Empty(nSalesCurr)
		aAdd(aSOHeader, { "C5_MOEDA",	nSalesCurr,	Nil })
	EndIf

	aSOItems	:= {}
	For nX := 1 To Len(aItems)
		cIteSO		:= StrZero(nX, GetSX3Cache("C6_ITEM", "X3_TAMANHO"))
		aTmp		:= {}
		aAdd(aTmp, { "C6_ITEM",		cIteSO,	Nil })
		aAdd(aTmp, { "C6_PRODUTO",	aItems[nX, 01],	Nil })
		aAdd(aTmp, { "C6_QTDVEN", 	aItems[nX, 02],	Nil })
		aAdd(aTmp, { "C6_PRCVEN", 	aItems[nX, 03],	Nil })
		aAdd(aTmp, { "C6_TES",		aItems[nX, 04],	Nil })
		aAdd(aSOItems, aTmp)
	Next nX

	lMsErroAuto	:= .F.
	MSExecAuto( { |x,y,z| MATA410(x,y,z) }, aSOHeader, aSOItems, 3 )
	lRet		:= ! lMsErroAuto
	If ! lRet
		MostraErro()
		Help("",1,"AF036RUSSOCREATE",,STR0152,1,0)	// "Error creating sales order for write-off"
	Else
		cSONumber	:= SC5->C5_NUM
	EndIf
EndIf

// Perform evaluation of available balances
If lRet
	If lRet
		SC5->(dbSetOrder(1))	// C5_FILIAL+C5_NUM
		lRet	:= lRet .And. SC5->(dbSeek(xFilial("SC5") + cSONumber))
		If ! lRet
			Help("",1,"AF036RUSSONOTFOUND",,STR0153,1,0)	// "Sales order of writen-off fixed asset not found"
		EndIf
	EndIf

	If lRet
		aSOBalances	:= {}
		aSOBlocked	:= {}
		Ma410LbNfs( 2, @aSOBalances, @aSOBlocked )
		Ma410LbNfs( 1, @aSOBalances, @aSOBlocked )

		aInvRegs	:= {}
		For nX := 1 To Len(aSOBalances)
			aAdd(aInvRegs, aSOBalances[nX, 08])
		Next nX

		lRet	:= lRet .And. ! Empty(aSOBalances) .And. Empty(aSOBlocked)
		If ! lRet
			Help("",1,"AF036RUSSONOBALANCE",,STR0154,1,0)	// "The preparation of the sales order for invoicing failed, check inventory balances."
		EndIf
	EndIf
EndIf

// Generate invoice
If lRet
	Pergunte("MTA410FAT", .F.)
	aParams	:= {}
	aAdd(aParams, SC5->C5_NUM)	// Sales order - from
	aAdd(aParams, SC5->C5_NUM)	// Sales order - to
	aAdd(aParams, SC5->C5_CLIENTE)	// Customers - from
	aAdd(aParams, SC5->C5_CLIENTE)	// Customers - to
	aAdd(aParams, SC5->C5_LOJACLI)	// Customers unit - from
	aAdd(aParams, SC5->C5_LOJACLI)	// Customers unit - to
	aAdd(aParams, MV_PAR01)	// Group from
	aAdd(aParams, MV_PAR02)	// Group to
	aAdd(aParams, MV_PAR03)	// Aggregator from
	aAdd(aParams, MV_PAR04)	// Aggregator to
	aAdd(aParams, MV_PAR05)	// Show acc entries
	aAdd(aParams, MV_PAR06)	// Group acc entries
	aAdd(aParams, MV_PAR07)	// Online acc entries
	aAdd(aParams, 2)	// Inverse
	aAdd(aParams, MV_PAR08)	// Update binding
	aAdd(aParams, MV_PAR09)	// Group
	aAdd(aParams, MV_PAR10)	// Minimum value
	aAdd(aParams, 2)	// 
	aAdd(aParams, "")	// Transporter from
	aAdd(aParams, "Z")	// Transporter to
	aAdd(aParams, MV_PAR11)	// Readjust on same NF
	aAdd(aParams, MV_PAR12)	// Bill order through
	aAdd(aParams, MV_PAR13)	// Currency
	aAdd(aParams, MV_PAR14)	// Account by
	aAdd(aParams, 1)	// Type of SO
	
	// Invoices are being returned even when operation is cancelled,
	//	should check manually
	aInvoices	:= a468nFatura(;
		"SC9" /* cAlias */,;
		aParams /* aParams */,;
		aInvRegs /* aRecs */,;
		/* cCamposQueb */,;
		/* lCarga */,;
		/* lAuto */,;
		/* aNotas */,;
		/* lMT310 */,;
		cSeries /* c310Ser */,;
		/* c310Num */)
	
	SX5->(MsUnLock())
	FWPutSX5("TRANSL", "01", cSeries, AllTrim(SX5->X5_DESCRI), AllTrim(SX5->X5_DESCRI), AllTrim(SX5->X5_DESCRI), AllTrim(SX5->X5_DESCRI))
EndIf

If lRet
	cInvNumber	:= ""
	cInvSerie	:= ""

	cQuery	:= " select d2_doc, d2_serie "
	cQuery	+="   from " + RetSqlName("SD2")
	cQuery	+= "  where d_e_l_e_t_ = ' ' "
	cQuery	+= "    and d2_filial = '"+xFilial("SD2")+"' "
	cQuery	+= "    and d2_pedido = '"+cSONumber+"' "
	cQuery	+= " group by d2_doc, d2_serie "

	cTmpAls		:= RU01GETALS(cQuery)
	lRet		:= (cTmpAls)->(! EOF())
	If lRet
		cInvNumber	:= (cTmpAls)->D2_DOC
		cInvSerie	:= (cTmpAls)->D2_SERIE

		lRet		:= ! Empty(cInvNumber) .And. ! Empty(cInvSerie)
	EndIf
	(cTmpAls)->(dbCloseArea())

	If ! lRet
		Help("",1,"AF036RUSSONOINVOICE",,STR0155,1,0)	// "The outflow invoice was not created."
	EndIf
EndIf

If ! lRet
	DisarmTransaction()
EndIf

END TRANSACTION

RestArea(aAreaSC5)
RestArea(aArea)

Return {cInvNumber, cInvSerie}

//-----------------------------------------------------------------------
/*/{Protheus.doc} ProcFARules

Enforce localization rules

@param		ARRAY aFARules
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        EV01A012RU
/*/
//-----------------------------------------------------------------------


Function _ProcFARules(aFARules AS ARRAY)
Local nX		AS NUMERIC
Local cBase		AS CHARACTER
Local cItem		AS CHARACTER
Local aProc		AS ARRAY
aProc		:= {}

For nX := 1 To Len(aFARules)
	cBase		:= aFARules[nX,01]
	cItem		:= aFARules[nX,02]

	If Empty(AScan(aProc, cBase + cItem))
		RU01RULES(cBase, cItem)
		aAdd(aProc, cBase + cItem)
	EndIf
Next nX

Return Nil