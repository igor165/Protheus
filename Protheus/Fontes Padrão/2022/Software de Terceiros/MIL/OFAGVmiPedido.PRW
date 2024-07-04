
#include "protheus.ch"

function OFAGVmiPedido()
return .t.

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  12/06/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiPedido
	Interface DMS - 5 da definição do VMI

	{<br>
	  "data": {<br>
	    "dealerLegalNumber": "99.999.999/0001-99",<br>
	    "extractionDateTime": "2016-11-23T10:45:00+03:00",<br>
	    "order": {<br>
	      "orderId": "34562",<br>
	      "orderAgco": "AOL-123456",<br>
	      "orderIdOriginal": "4567",<br>
	      "deliveredDealerLegalNumber": "11.000.000/0001-00",<br>
	      "orderDate": "2016-11-23",<br>
	      "orderType": "STOCK_ORDER",<br>
	      "supplierLegalNumber": "00.000.000/0001-00",<br>
	      "supplierName": "NOME FANTASIA DO FORNECEDOR",<br>
	      "filter1": "",<br>
	      "filter2": "",<br>
	      "filter3": "",<br>
	      "items": [<br>
	        {<br>
	          "sourceLocation": "REPVT03",<br>
	          "orderLineNumber": "1",<br>
	          "partNumber": "1444437P",<br>
	          "receivedDate": "2016-11-23",<br>
	          "requestedQuantity": 1.5,<br>
	          "receivedQuantity": 1.5,<br>
	          "openQuantity": 1.5,<br>
	          "canceledQuantity": 1.5,<br>
	          "lineStatus": "OPEN"<br>
	        }<br>
	      ]<br>
	    }<br>
	  }<br>
	}<br>

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiPedido from OFAGVmiBase
	Data cIntName
	Method New() CONSTRUCTOR
	Method Trigger()
	Method TriggerDer()
	Method GetDadosPedido()
EndClass

Method New() Class OFAGVmiPedido
	_Super:New()
	AADD(::aMapValid, {"data"                                 , "V005"})
	AADD(::aMapValid, {"data:order:orderID"                   , "Obri"})
	AADD(::aMapValid, {"data:order:deliveredDealerLegalNumber", "Obri"})
	AADD(::aMapValid, {"data:order:orderDate"                 , "Obri"})
	AADD(::aMapValid, {"data:order:orderDate"                 , "Date"})
	AADD(::aMapValid, {"data:order:orderType"                 , "V004"})
	AADD(::aMapValid, {"data:order:supplierLegalNumber"       , "Obri"})
	AADD(::aMapValid, {"data:order:items:orderLineNumber"     , "Obri"})
	AADD(::aMapValid, {"data:order:items:partNumber"          , "Obri"})
	AADD(::aMapValid, {"data:order:items:requestedQuantity"   , "Obri"})
	AADD(::aMapValid, {"data:order:items:openQuantity"        , "Obri"})
	AADD(::aMapValid, {"data:order:items:lineStatus"          , "Obri"})
	AADD(::aMapValid, {"data:order:items:sourceLocation"      , "V005"})
	::cIntName := "DMS-3"
return self

/*/{Protheus.doc} Trigger
	Evento de envio de dados do PEDIDO (NF Entrada), modelo DMS-3 do VMI

	@author Vinicius Gati
	@since 21/06/2017
/*/
Method Trigger(oParams) Class OFAGVmiPedido
	Local cCoord  := ""
	Local oSqlHlp := DMS_SqlHelper():New()
	Local oJson   := DMS_DataContainer():New()
	local oArHlp  := DMS_ArrayHelper():New()
	Local cGrupos := "'" + oArHlp:Join(self:oVmiParametros:grupos(), "','") + oArHlp:Join(self:oVmiParametros:gruposparalelos(), "','") + "'"
	Local cIdPedido := oParams:GetValue("CODIGO") // DOC + SERIE + FORNECEDOR + LOJA
	Local cQuery    := ""
	Local cConcat   := FG_CONVSQL("CONCATENA")
	cQuery := "SELECT SD1.R_E_C_N_O_ AS RECSD1 "
	cQuery += "  FROM "+oSqlHlp:NoLock('SD1')
	cQuery += "  JOIN "+oSqlHlp:NoLock('SF4')
	cQuery += "    ON SF4.F4_FILIAL = '"+xFilial("SF4")+"'"
	cQuery += "   AND SF4.F4_CODIGO = SD1.D1_TES"
	cQuery += "   AND SF4.F4_OPEMOV = '01'"
	cQuery += "   AND SF4.D_E_L_E_T_ = ' '"
	cQuery += "  JOIN "+oSqlHlp:NoLock('SB1')
	cQuery += "    ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
	cQuery += "   AND SB1.B1_COD = SD1.D1_COD "
	cQuery += "   AND SB1.B1_GRUPO IN ("+cGrupos+")"
	cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'"
	cQuery += "   AND ( SD1.D1_DOC "+cConcat+" SD1.D1_SERIE "+cConcat+" SD1.D1_FORNECE "+cConcat+" SD1.D1_LOJA ) = '"+cIdPedido+"'"
	cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
	If FM_SQL( cQuery ) > 0
		SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
		oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
		oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))
		oJson:SetValue("order", self:GetDadosPedido( oParams:GetValue("CODIGO") , cQuery ))
		oJson:GetValue("order"):SetValue("deliveredDealerLegalNumber", self:fmtDoc(SA1->A1_CGC))
		cCoord := self:oVmiJson:Persist(self:cIntName, oParams, {oJson})
		if oParams:GetBool('INICIALIZACAO', .F.) == .F.
			self:TriggerDer(oJson:GetValue("order"):GetValue('items'), cCoord)
		end
	EndIf
Return cCoord

/*/{Protheus.doc} TriggerDer
	Engatilha os eventos derivados para atualizar AGCO
	é feito de 7 em 7 peças para melhorar performance de geração e envio de jsons

	@author Vinicius Gati
	@since 21/06/2017
/*/
Method TriggerDer(aItems, cCoord) Class OFAGVmiPedido
		Local nX := 1
		Local oVmi := OFAGVmi():New()
		For nX:= 1 to Len(aItems)
			oItem := aItems[nX]
			// somente 1 por vez infelizmente
			oVMi:Trigger({;
				{'EVENTO', oVmi:oVmiMovimentos:Inventario },;
				{'NUMCONTROLE' , cCoord                   },;
				{'ORIGEM', "DMS3_DMS1"                    },;
				{'PECAS' , {oItem:GetValue('partNumber') }} ;
			})
		Next
Return .T.

/*/{Protheus.doc} GetPedido
	Retorna dados conforme DMS-3 com dados de um pedido ( Entrada por Compra )
	@author Vinicius Gati
	@since 21/06/2017
	@param cIdPedido, String, Código do pedido
	@param cQuerySD1, String, Query SQL do SD1
/*/
Method GetDadosPedido(cIdPedido,cQuerySD1) Class OFAGVmiPedido
	Local aArea      := GetArea()
	Local aAreaA1    := SA1->(GetArea())
	Local aAreaA2    := SA2->(GetArea())
	Local aAreaD1    := SD1->(GetArea())
	Local cAl        := "SQLSD1"
	Local cFilIdPed  := xFilial('SD1')+cIdPedido // Filial + DOC + SERIE + FORNECEDOR + LOJA
	Local oPedido := DMS_DataContainer():New({;
		{"items", {}} ;
	})

	dbSelectArea('SD1')
	dbSetOrder(1)
	If dbSeek( cFilIdPed )

		dbSelectArea('SA2')
		dbSetOrder(1)
		dbSeek( xFiliAl('SA2') + SD1->D1_FORNECE + SD1->D1_LOJA )

		oPedido:SetValue("orderId" , cFilIdPed)
		oPedido:SetValue("orderIdOriginal" , cFilIdPed)
		oPedido:SetValue("orderType", 'STOCK_ORDER')
		oPedido:SetValue("orderDate", SD1->D1_EMISSAO)
		if EMPTY(SA2->A2_CGC)
			oPedido:remAttr("supplierLegalNumber")
		else
			oPedido:SetValue("supplierLegalNumber", self:fmtDoc(SA2->A2_CGC))
		end
		oPedido:SetValue("supplierName", SA2->A2_NOME)
		//
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuerySD1 ), cAl, .F., .T. )
		while !( (cAl)->(eof()) )
			SD1->(DbGoto( (cAl)->( RECSD1 ) ))
			oItem := DMS_DataContainer():New()
			oItem:SetValue("orderLineNumber", SD1->D1_ITEM)
			oItem:SetValue("partNumber", SD1->D1_COD)
			oItem:SetValue("receivedDate", SD1->D1_DTDIGIT)
			oItem:SetValue("requestedQuantity", SD1->D1_QUANT)
			oItem:SetValue("receivedQuantity", SD1->D1_QUANT)
			oItem:SetValue("openQuantity", 0 )
			oItem:SetValue("lineStatus", 'CLOSED')
//			oItem:SetValue("netValue", 0) // Valor Liquido
//			oItem:SetValue("totalValue", 0) // Valor TOTAL
//			oItem:SetValue("taxes", 0) // Valor Impostos (diferença entre Valor Liquido e TOTAL)
//			oItem:SetValue("currency",'BRL')
			AADD( oPedido:GetValue('items'), oItem )
			(cAl)->(DBSkip())
		enddo
		(cAl)->(dbCloseArea())
		DbSelectArea("SD1")
	EndIf
	RestArea( aAreaA1 )
	RestArea( aAreaA2 )
	RestArea( aAreaD1 )
	RestArea( aArea   )
Return oPedido