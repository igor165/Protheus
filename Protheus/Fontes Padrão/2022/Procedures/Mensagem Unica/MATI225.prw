#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI225.CH"
Static lMI255POS := ExistBlock("MI255POS")
Static aTimesGen := {} //Guarda os horarios de geração do xml para não gerar chave duplicada na SOF

/*/{Protheus.doc} MATI225
Adapter de consulta de estoque (mensagem StockLevel).

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.
@param   lEAIObj       Indica se é mensagem XML (.F.) ou JSON (.T.).

@author	Flavio Lopes Rasta
@since		23/12/2013
@version	P12.00
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem
/*/
Function MATI225(xEnt, cTypeTrans, cTypeMsg, cVersion, cTransac, lEAIObj)

Local cError	:= ""
Local cWarning	:= ""
Local cXMLRet	:= ""
Local cVersao   := ""
Local lRet      := .T.
Local aRet      := {lRet, cXMLRet, "STOCKLEVEL"}
Local aArea     := GetArea()
Local lIntegPPI := PCPIntgPPI()

Default cVersion 	:= ""
Default cTransac 	:= ""
Default lEAIObj 	:= .F.

Default cProdPPI := ' '

// Trata o envio de mensagem
If cTypeTrans == TRANS_SEND
	if lIntegPPI .And. !Empty(cProdPPI)
		aRet := MATI225SND()
	Else
		If Left( cVersion, 1 ) == "3"
			aRet := v3000(xEnt, cTypeTrans, cTypeMsg, lEAIObj,cVersion)
		Else
			aRet := {.F., STR0004} // "A versão da mensagem informada não foi implementada!"
		EndIf
	EndIf
	lRet    := aRet[1]
	cXMLRet := aRet[2]

// Trata recebimento de mensagens
ElseIf cTypeTrans == TRANS_RECEIVE
	// Recebimento da WhoIs
	If cTypeMsg == EAI_MESSAGE_WHOIS
		cXmlRet := '1.000|2.000|3.000|3.001|3.002|3.003|3.004'

	// Recebimento da Response Message
	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
		cXmlRet := STR0001 // 'Mensagem processada'

	// Receipt Message (Aviso de receb. em transmissoes assincronas)
	ElseIf cTypeMsg == EAI_MESSAGE_RECEIPT
		cXmlRet := STR0002 // 'Mensagem recebida'

	// Recebimento da Business Message
	ElseIf cTypeMsg == EAI_MESSAGE_BUSINESS
		If !lEAIObj
			oXML := xmlParser(xEnt, "_", @cError, @cWarning)
			If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
				// Versão da mensagem
				If Type("oXML:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_version:Text)
					cVersao := StrTokArr(oXML:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
				Else
					If Type("oXML:_TOTVSMessage:_MessageInformation:_StandardVersion:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_StandardVersion:Text)
						cVersao := StrTokArr(oXML:_TOTVSMessage:_MessageInformation:_StandardVersion:Text, ".")[1]
					Else
						lRet    := .F.
						cXmlRet := STR0003 // "Versão da mensagem não informada!"
					Endif
				EndIf
			Else
				lRet    := .F.
				cXmlRet := STR0005 // "Erro no parser!"
			EndIf
		Else
			cVersao := StrTokArr(PmsMsgUVer('STOCKLEVEL','MATA225'), ".")[1]
		EndIf

		If lRet
			If !lEAIObj .AND. cVersao == "1"
				aRet := v1000(xEnt, cTypeTrans, cTypeMsg)
			ElseIf !lEAIObj .and. cVersao == "2"
				aRet := v2000(xEnt, cTypeTrans, cTypeMsg)
			ElseIf cVersao == "3"
				aRet := v3000(xEnt, cTypeTrans, cTypeMsg, lEAIObj,cVersion)
			Else
				aRet := {.F., STR0004} // "A versão da mensagem informada não foi implementada!"
			Endif
			lRet    := aRet[1]
			cXmlRet := aRet[2]
		Endif
	Endif
Endif

// Ponto de entrada no final da rotina para tratamento do XML.
If lMI255POS
	aRet := ExecBlock("MI255POS", .F., .F., {lRet, cXmlRet, cTypeTrans, cTypeMsg, cVersion, cTransac, lEAIObj})
	If ValType(aRet) = "A" .and. len(aRet) > 1
		lRet    := aRet[1]
		cXmlRet := aRet[2]
	Endif
Endif

RestArea(aArea)
Return {lRet, cXmlRet, "StockLevel"}

/*/{Protheus.doc} v1000
Consulta de StockLevel da versão 1.x.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.
@param   lEAIObj       Indica se é mensagem XML (.F.) ou JSON (.T.).

@return	 lRet     Indica se a mensagem foi processada com sucesso
@return	 cXMLRet  XML de retorno da funcao

@author	Flavio Lopes Rasta
@since		23/12/2013
@version	P12.00
/*/
Static Function v1000(cXml, cTypeTrans, cTypeMsg)

Local oXMLM225	:= NIL
Local oBMessage	:= NIL
Local oBContent	:= NIL
Local aProd		:= {}
Local cError		:= ""
Local cWarning	:= ""
Local cProduto	:= ""
Local cArmazem	:= ""
Local cMarca		:= ""
Local cXMLRet 	:= ""
Local nX			:= 0
Local lRet 		:= .T.
Local lLocaliza	:= .F.
Local lRastro		:= .F.

oXMLM225 := XmlParser(cXml, "_", @cError, @cWarning)
oBMessage  := oXMLM225:_TOTVSMessage:_BusinessMessage
oBContent  := oBMessage:_BusinessContent
If ( oXMLM225 <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )
	cMarca := oXMLM225:_TOTVSMESSAGE:_MESSAGEINFORMATION:_PRODUCT:_NAME:TEXT
	aProd := IIF(ValType(oXMLM225:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTITEM) == "O",;
		{oXMLM225:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTITEM},;
		oXMLM225:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_REQUESTITEM)
	For nX:=1 To Len(aProd)
		cFilQry:= ""
		cFilSB8:= ""
		cFilSBF:= ""
		If aProd[nX]:_ItemInternalId == NiL .And. aProd[nX]:_WarehouseInternalId == Nil
			lRet := .F.
			cXMLRet := STR0006 // "Produto ou armazém inválido"
		Endif
		If lRet
			//-Produto
			cProduto:= aProd[nX]:_ItemInternalId:Text
			cProduto:= CFGA070INT( cMarca, 'SB1', 'B1_COD', cProduto )
			cProduto:= MTIGetCod(cProduto)
			If SB1->(DbSeek(xFilial('SB1')+cProduto))
				cFilQry += " SB2.B2_COD = '"+cProduto+"' "
				cFilSB8 += " SB8.B8_PRODUTO = '"+cProduto+"' "
				cFilSBF += " SBF.BF_PRODUTO = '"+cProduto+"' "
			EndIf
			//-Armazem
			cArmazem:= aProd[nX]:_WarehouseInternalId:Text
			cArmazem:= CFGA070INT( cMarca, 'NNR', 'NNR_CODIGO', cArmazem )
			cArmazem:= MTIGetCod(cArmazem)
			If NNR->(DbSeek(xFilial('NNR')+cArmazem))
				If !Empty(cProduto)
					cFilQry += ' AND '
					cFilSB8 += ' AND '
					cFilSBF += ' AND '
				Endif
				cFilQry += " SB2.B2_LOCAL = '"+cArmazem+"' "
				cFilSB8 += " SB8.B8_LOCAL = '"+cArmazem+"' "
				cFilSBF += " SBF.BF_LOCAL = '"+cArmazem+"' "
			EndIf

			If Empty(cProduto) .And. Empty(cArmazem)
				lRet:= .F.
				cXMLRet := STR0006 // "Produto ou armazém inválido"
			Endif
		Endif
		cFilQry := '%'+cFilQry+'%'
		cFilSB8 := '%'+cFilSB8+'%'
		cFilSBF := '%'+cFilSBF+'%'
		If lRet
			BeginSQL Alias "TMPSB2"
				SELECT *
				FROM 	%Table:SB2% SB2
				WHERE 	SB2.%NotDel% AND
				%Exp:cFilQry%
				ORDER BY SB2.B2_COD, SB2.B2_LOCAL
			EndSQL
			While TMPSB2->(!Eof())
				SB2->(dbSeek(xFilial("SB2")+TMPSB2->B2_COD))
				lLocaliza  := Localiza(TMPSB2->B2_COD)
				lRastro    := Rastro(TMPSB2->B2_COD)
				cXMLRet  += '<RequestItem>'
				cXMLRet  += 		'<CompanyId>'+ cEmpAnt +'</CompanyId>'
				cXMLRet  += 		'<BranchId>' + RTrim(xFilial("SB2")) +'</BranchId>'
				cXMLRet  += 		'<CompanyInternalId>' + cEmpAnt + "|" + RTrim(xFilial("SB2")) + '</CompanyInternalId>'
				cXMLRet  += 		'<ItemInternalId>' + cEmpAnt + "|" + RTrim(xFilial("SB1")) + "|" + RTrim(TMPSB2->B2_COD) +	'</ItemInternalId>'
				cXMLRet  += 		'<WarehouseInternalId>' + cEmpAnt + "|" + RTrim(xFilial("NNR")) + "|" + RTrim(TMPSB2->B2_LOCAL) +'</WarehouseInternalId>'
				cXMLRet  += 		'<UnitItemCost>' + AllTrim(cValToChar(TMPSB2->B2_CM1)) + '</UnitItemCost>'
				cXMLRet  += 		'<AverageUnitItemCost>' + AllTrim(cValToChar(TMPSB2->B2_VATU1)) + '</AverageUnitItemCost>'
				cXMLRet  += 		'<CurrentStockAmount>' + AllTrim(cValToChar(TMPSB2->B2_QATU)) + '</CurrentStockAmount>'
				cXMLRet  += 		'<AvailableStockAmount>' + AllTrim(cValToChar(SaldoSB2())) + '</AvailableStockAmount>'
				cXMLRet  += 		'<BookedStockAmount>' + AllTrim(cValToChar(TMPSB2->B2_RESERVA)) + '</BookedStockAmount>'
				cXMLRet  += 		'<ValueOfCurrentStockAmount>' + AllTrim(cValToChar(TMPSB2->B2_VATU1)) + '</ValueOfCurrentStockAmount>'
				If lRastro  //Realiza query de busca de Lotes
					cXMLRet  +=		'<ListOfLotStock>'
					BeginSQL Alias "TMPSB8"
						SELECT *
						FROM 	%Table:SB8% SB8
						WHERE 	SB8.%NotDel% AND
						%Exp:cFilSB8%
						ORDER BY SB8.B8_LOTECTL
					EndSQL
					While TMPSB8->(!Eof())
						cXMLRet  +=			'<LotStock>'
						cXMLRet  +=				'<LotNumber>' + TMPSB8->B8_LOTECTL + '</LotNumber>'
						cXMLRet  +=				'<LotExpirationDate>' + Transform(TMPSB8->B8_DTVALID,"@R 9999-99-99") + '</LotExpirationDate>'
						cXMLRet  +=				'<CurrentStockAmount>' + AllTrim(cValToChar(TMPSB8->B8_SALDO)) + '</CurrentStockAmount>'
						cXMLRet  +=				'<BookedStockAmount>' + AllTrim(cValToChar(TMPSB8->B8_EMPENHO)) + '</BookedStockAmount>'
						cXMLRet  +=				'<AvailableStockAmount>' + AllTrim(cValToChar(TMPSB8->B8_SALDO - TMPSB8->B8_EMPENHO)) + '</AvailableStockAmount>'
						cXMLRet  +=			'</LotStock>'
						TMPSB8->(dbSkip())
					EndDo
					cXMLRet  +=		'</ListOfLotStock>'
				EndIf
				If lLocaliza //Realiza query de busca de Endereços
					cXMLRet  +=		'<ListOfAddressStock>'
					BeginSQL Alias "TMPSBF"
						SELECT *
						FROM 	%Table:SBF% SBF
						WHERE 	SBF.%NotDel% AND
						%Exp:cFilSBF%
						ORDER BY SBF.BF_LOCALIZ
					EndSQL
					While TMPSBF->(!Eof())
						cXMLRet  +=			'<AddressStock>'
						cXMLRet  +=				'<Address>' + TMPSBF->BF_LOCALIZ + '</Address>'
						cXMLRet  +=				'<CurrentStockAmount>' + AllTrim(cValToChar(TMPSBF->BF_QUANT)) + '</CurrentStockAmount>'
						cXMLRet  +=				'<BookedStockAmount>' + AllTrim(cValToChar(TMPSBF->BF_EMPENHO)) + '</BookedStockAmount>'
						cXMLRet  +=				'<AvailableStockAmount>' + AllTrim(cValToChar(TMPSBF->BF_QUANT-TMPSBF->BF_EMPENHO)) + '</AvailableStockAmount>'
						cXMLRet  +=			'</AddressStock>'
						TMPSBF->(dbSkip())
					EndDo
					cXMLRet  +=		'</ListOfAddressStock>'
				EndIf
				If lLocaliza //Realiza query de Endereços e Numero de Serie
					TMPSBF->(dbCloseArea())
					cXMLRet  +=		'<ListOfSeriesStock>'
					BeginSQL Alias "TMPSBF"
						SELECT *
						FROM 	%Table:SBF% SBF
						WHERE 	SBF.%NotDel% AND
						SBF.BF_NUMSERI != ' ' AND
						%Exp:cFilSBF%
						ORDER BY SBF.BF_LOCALIZ,SBF.BF_NUMSERI
					EndSQL
					While TMPSBF->(!Eof())
						cXMLRet  +=			'<SeriesStock>'
						cXMLRet  +=				'<SerialNumber>' + TMPSBF->BF_NUMSERI + '</SerialNumber>'
						cXMLRet  +=				'<CurrentStockAmount>' + AllTrim(cValToChar(TMPSBF->BF_QUANT)) + '</CurrentStockAmount>'
						cXMLRet  +=				'<BookedStockAmount>' + AllTrim(cValToChar(TMPSBF->BF_EMPENHO)) + '</BookedStockAmount>'
						cXMLRet  +=				'<AvailableStockAmount>' + AllTrim(cValToChar(TMPSBF->BF_QUANT-TMPSBF->BF_EMPENHO)) + '</AvailableStockAmount>'
						cXMLRet  +=			'</SeriesStock>'
						TMPSBF->(dbSkip())
					EndDo
					cXMLRet  +=		'</ListOfSeriesStock>'
				EndIf
				cXMLRet  += '</RequestItem>'
				TMPSB2->(dbSkip())
			EndDo
			TMPSB2->(dbCloseArea())
		Else
			Loop
		Endif
	Next nX
Endif
//TMPSB2->(dbCloseArea())
If lRastro
	TMPSB8->(dbCloseArea())
EndIf
If lLocaliza
	TMPSBF->(dbCloseArea())
EndIf

Return { lRet, cXmlRet }

/*/{Protheus.doc} v2000
Consulta de StockLevel da versão 2.x.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.
@param   lEAIObj       Indica se é mensagem XML (.F.) ou JSON (.T.).

@return	 lRet     Indica se a mensagem foi processada com sucesso
@return	 cXMLRet  XML de retorno da funcao

@author	Lucas Konrad França
@since		02/05/2016
@version	P11.80
/*/
Static Function v2000(cXml, cTypeTrans, cTypeMsg)

Local cAliasSld := ""
Local cQuery    := ""
Local cFilQry   := ""
Local cFilSB8   := ""
Local cFilSBF   := ""
Local cError    := ""
Local cWarning  := ""
Local cMarca    := ""
Local cXMLRet   := ""
Local cProduto  := ""
Local cLocal    := ""
Local cLote     := ""
Local cSubLote  := ""
Local cNumSeri  := ""
Local cAddress  := ""
Local dDatVld   := CtoD("  /  /    ")
Local dValid    := CtoD("  /  /    ")
Local nI        := 0
Local nX        := 0
Local lRet      := .T.
Local nPos      := 0
Local cAllProd  := ""

Local aProdutos  := {}
Local nPosProd   := 1
Local nPosLocal  := 2
Local nPosLote   := 3
Local nPosSbLote := 4
Local nPosSerie  := 5
Local nPosEnder  := 6
Local nPosDtVld  := 7

Local aInfXml    := {}
Local lEntrou    := .F.
Local lPesqB2    := .T.

Private oXMLM225 := NIL
Private aXmlProd := {}

oXMLM225 := XmlParser(cXml, "_", @cError, @cWarning)
If ( oXMLM225 <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )
	If Type("oXMLM225:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" .And. ;
	   !Empty(oXMLM225:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
		cMarca := oXMLM225:_TOTVSMESSAGE:_MESSAGEINFORMATION:_PRODUCT:_NAME:TEXT
	Else
		lRet := .F.
		cXMLRet := STR0007 // "Product:Name é obrigatório."
		Return {lRet, cXmlRet}
	EndIf
	If Upper(AllTrim(cMarca)) == "PPI"
		//Verifica se a integração com o PPI está ativa. Se não estiver, não permite prosseguir com a integração.
		If !PCPIntgPPI()
			lRet := .F.
			cXmlRet := STR0008 // "Integração com o TOTVS MES desativada. Processamento não permitido."
			Return {lRet, cXMLRet}
		EndIf
	EndIf

	If Type("oXMLM225:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfRequest:_Request") == "O"
		aXmlProd := {oXMLM225:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfRequest:_Request}
	Else
		If Type("oXMLM225:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfRequest:_Request") == "A"
			aXmlProd := oXMLM225:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfRequest:_Request
		Else
			lRet := .F.
			cXmlRet := STR0009 // "Request inválido."
			Return {lRet, cXMLRet}
		EndIf
	EndIf

	For nI := 1 To Len(aXmlProd)
		cProduto  := ""
		cLocal    := ""
		cLote     := ""
		cSubLote  := ""
		cNumSeri  := ""
		cAddress  := ""
		dDatVld   := CtoD("  /  /    ")

		If Type("aXmlProd["+cValToChar(nI)+"]:_ItemInternalId:Text") <> "U" .And. ;
		   !Empty(aXmlProd[nI]:_ItemInternalId:Text)
			cProduto := aXmlProd[nI]:_ItemInternalId:Text
		EndIf

		If Type("aXmlProd["+cValToChar(nI)+"]:_WarehouseInternalId:Text") <> "U" .And. ;
		   !Empty(aXmlProd[nI]:_WarehouseInternalId:Text)
			cLocal := aXmlProd[nI]:_WarehouseInternalId:Text
		EndIf

		If Type("aXmlProd["+cValToChar(nI)+"]:_LotNumber:Text") <> "U" .And. ;
		   !Empty(aXmlProd[nI]:_LotNumber:Text)
			cLote := aXmlProd[nI]:_LotNumber:Text
		EndIf

		If Type("aXmlProd["+cValToChar(nI)+"]:_SubLotCode:Text") <> "U" .And. ;
		   !Empty(aXmlProd[nI]:_SubLotCode:Text)
			cSubLote := aXmlProd[nI]:_SubLotCode:Text
		EndIf

		If Type("aXmlProd["+cValToChar(nI)+"]:_SerialNumber:Text") <> "U" .And. ;
		   !Empty(aXmlProd[nI]:_SerialNumber:Text)
			cNumSeri := aXmlProd[nI]:_SerialNumber:Text
		EndIf

		If Type("aXmlProd["+cValToChar(nI)+"]:_Address:Text") <> "U" .And. ;
		   !Empty(aXmlProd[nI]:_Address:Text)
			cAddress := aXmlProd[nI]:_Address:Text
		EndIf

		If Type("aXmlProd["+cValToChar(nI)+"]:_LotExpirationDate:Text") <> "U" .And. ;
		   !Empty(aXmlProd[nI]:_LotExpirationDate:Text)
			dDatVld := StoD(getDate(aXmlProd[nI]:_LotExpirationDate:Text))
		EndIf

		If Empty(cProduto) .And. Empty(cLocal)
			lRet := .F.
			cXmlRet := STR0010 // "Obrigatório informar o ItemInternalId e/ou WarehouseInternalId."
			Return {lRet, cXmlRet}
		EndIf

		If Empty(cProduto)
			If !Empty(cLote)
				lRet := .F.
				cXmlRet := STR0011 + "LotNumber" // "Campo permitido apenas quando o ItemInternalId for informado: "
				Return {lRet, cXmlRet}
			EndIf
			If !Empty(cSubLote)
				lRet := .F.
				cXmlRet := STR0011 + "SubLotCode" // "Campo permitido apenas quando o ItemInternalId for informado: "
				Return {lRet, cXmlRet}
			EndIf
			If !Empty(cNumSeri)
				lRet := .F.
				cXmlRet := STR0011 + "SerialNumber" // "Campo permitido apenas quando o ItemInternalId for informado: "
				Return {lRet, cXmlRet}
			EndIf
			If !Empty(cAddress)
				lRet := .F.
				cXmlRet := STR0011 + "Address" // "Campo permitido apenas quando o ItemInternalId for informado: "
				Return {lRet, cXmlRet}
			EndIf
			If !Empty(dDatVld)
				lRet := .F.
				cXmlRet := STR0011 + "LotExpirationDate" // "Campo permitido apenas quando o ItemInternalId for informado: "
				Return {lRet, cXmlRet}
			EndIf
		EndIf

		//nPosProd   := 1
		//nPosLocal  := 2
		//nPosLote   := 3
		//nPosSbLote := 4
		//nPosSerie  := 5
		//nPosEnder  := 6
		//nPosDtVld  := 7
		aAdd(aProdutos,{cProduto,;
								cLocal,;
								cLote,;
								cSubLote,;
								cNumSeri,;
								cAddress,;
								dDatVld})
	Next nI

	If Len(aProdutos) < 1
		lRet := .F.
		cXmlRet := STR0012 // "RequestItem informado não possui nenhum filtro válido para realização da consulta de saldo."
		Return {lRet, cXmlRet}
	EndIf
	aInfXml := {}
	For nI := 1 To Len(aProdutos)
		cFilQry  := ""
		cFilSB8  := ""
		cFilSBF  := ""
		cAllProd := ""
		lEntrou  := .F.
		lPesqB2  := .T.
		//-Produto
		If Upper(AllTrim(cMarca)) != "PPI"
			aProdutos[nI,nPosProd] := CFGA070INT( cMarca, 'SB1', 'B1_COD', aProdutos[nI,nPosProd] )
			aProdutos[nI,nPosProd] := MTIGetCod(aProdutos[nI,nPosProd])
		EndIf
		If !Empty(aProdutos[nI,nPosProd])
			cFilQry += " SB2.B2_COD = '"+aProdutos[nI,nPosProd]+"' "
			cFilSB8 += " SB8.B8_PRODUTO = '"+aProdutos[nI,nPosProd]+"' "
			cFilSBF += " SBF.BF_PRODUTO = '"+aProdutos[nI,nPosProd]+"' "
		EndIf
		//-Armazem
		If Upper(AllTrim(cMarca)) != "PPI"
			aProdutos[nI,nPosLocal] := CFGA070INT( cMarca, 'NNR', 'NNR_CODIGO', aProdutos[nI,nPosLocal] )
			aProdutos[nI,nPosLocal] := MTIGetCod(aProdutos[nI,nPosLocal])
		EndIf
		If !Empty(aProdutos[nI,nPosLocal])
			If !Empty(cFilQry)
				cFilQry += ' AND '
				cFilSB8 += ' AND '
				cFilSBF += ' AND '
			Endif
			cFilQry += " SB2.B2_LOCAL = '"+aProdutos[nI,nPosLocal]+"' "
			cFilSB8 += " SB8.B8_LOCAL = '"+aProdutos[nI,nPosLocal]+"' "
			cFilSBF += " SBF.BF_LOCAL = '"+aProdutos[nI,nPosLocal]+"' "
		EndIf

		If !Empty(aProdutos[nI,nPosLote])
			If !Empty(cFilSB8)
				cFilSB8 += " AND "
			EndIf
			If !Empty(cFilSBF)
				cFilSBF += " AND "
			EndIf
			cFilSB8 += " SB8.B8_LOTECTL = '" + aProdutos[nI,nPosLote] + "' "
			cFilSBF += " SBF.BF_LOTECTL = '" + aProdutos[nI,nPosLote] + "' "
			lPesqB2 := .F.
		EndIf

		If !Empty(aProdutos[nI,nPosSbLote])
			If !Empty(cFilSB8)
				cFilSB8 += " AND "
			EndIf
			If !Empty(cFilSBF)
				cFilSBF += " AND "
			EndIf
			cFilSB8 += " SB8.B8_NUMLOTE = '" + aProdutos[nI,nPosSbLote] + "' "
			cFilSBF += " SBF.BF_NUMLOTE = '" + aProdutos[nI,nPosSbLote] + "' "
			lPesqB2 := .F.
		EndIf

		If !Empty(aProdutos[nI,nPosSerie])
			If !Empty(cFilSBF)
				cFilSBF += " AND "
			EndIf
			cFilSBF += " SBF.BF_NUMSERI = '" + aProdutos[nI,nPosSerie] + "' "
			lPesqB2 := .F.
		EndIf

		If !Empty(aProdutos[nI,nPosEnder])
			If !Empty(cFilSBF)
				cFilSBF += " AND "
			EndIf
			cFilSBF += " SBF.BF_LOCALIZ = '" + aProdutos[nI,nPosEnder] + "' "
			lPesqB2 := .F.
		EndIf

		If !Empty(aProdutos[nI,nPosDtVld])
			If !Empty(cFilSB8)
				cFilSB8 += " AND "
			EndIf
			//If !Empty(cFilSBF)
			//	cFilSBF += " AND "
			//EndIf
			cFilSB8 += " SB8.B8_DTVALID = '" + DtoS(aProdutos[nI,nPosDtVld]) + "' "
			//cFilSBF += " SBF.BF_DATAVEN = '" + DtoS(aProdutos[nI,nPosDtVld]) + "' "
			lPesqB2 := .F.
		EndIf

		cAliasSld := GetNextAlias()
		cQuery := " SELECT SBF.R_E_C_N_O_ RECSBF "
		cQuery +=   " FROM " + RetSqlName("SBF") + " SBF "
		cQuery +=  " WHERE SBF.BF_FILIAL  = '" + xFilial("SBF") + "' "
		cQuery +=    " AND SBF.D_E_L_E_T_ = ' ' "
		If !Empty(cFilSBF)
			cQuery += " AND " + cFilSBF
		EndIf

		SB8->(dbSetOrder(2))

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSld,.T.,.T.)
		While (cAliasSld)->(!Eof())
			lEntrou := .T.
			SBF->(dbGoTo((cAliasSld)->RECSBF))

			dValid := CtoD("  /  /    ")
			If Empty(aProdutos[nI,nPosDtVld])
				//Não tem filtro por data de validade, apenas busca na SB8 a data de validade do lote.
				If SB8->(dbSeek(xFilial("SB8")+SBF->BF_NUMLOTE+SBF->BF_LOTECTL+SBF->BF_PRODUTO+SBF->BF_LOCAL))
					dValid := SB8->(B8_DTVALID)
				EndIf
			Else
				//Fez filtro por data de validade, verifica se existe saldo nesta data na SB8.
				If SB8->(dbSeek(xFilial("SB8")+SBF->BF_NUMLOTE+SBF->BF_LOTECTL+SBF->BF_PRODUTO+SBF->BF_LOCAL+DtoS(aProdutos[nI,nPosDtVld])))
					dValid := SB8->(B8_DTVALID)
				Else
					(cAliasSld)->(dbSkip())
					Loop
				EndIf
			EndIf

			nPos := aScan(aInfXml,{|x| AllTrim(x[1]) == AllTrim(SBF->BF_PRODUTO) })

			If nPos == 0
				aAdd(aInfXml,{SBF->BF_PRODUTO, {} })
				nPos := Len(aInfXml)
			EndIf
			If AT("'"+AllTrim(SBF->BF_PRODUTO)+"'",cAllProd) <= 0
				cAllProd += Iif(!Empty(cAllProd),","," ") + " '" + AllTrim(SBF->BF_PRODUTO) + "' "
			EndIf
			aAdd(aInfXml[nPos,2],{SBF->BF_PRODUTO,;
			              SBF->BF_LOCAL,;
			              SBF->BF_LOTECTL,;
			              dValid,;
			              SBF->BF_NUMSERI,;
			              SBF->BF_NUMLOTE,;
			              SBF->BF_LOCALIZ,;
			              SBF->BF_QUANT,;
			              SBF->BF_EMPENHO,;
			              SBF->BF_QUANT - SBF->BF_EMPENHO})
			(cAliasSld)->(dbSkip())
		EndDo
		(cAliasSld)->(dbCloseArea())
		If !lEntrou .Or. (Empty(aProdutos[nI,nPosProd]) .And. !Empty(aProdutos[nI,nPosLocal]) )
			cAliasSld := GetNextAlias()
			cQuery := " SELECT SB8.R_E_C_N_O_ RECSB8 "
			cQuery +=   " FROM " + RetSqlName("SB8") + " SB8 "
			cQuery +=  " WHERE SB8.B8_FILIAL  = '" + xFilial("SB8") + "' "
			cQuery +=    " AND SB8.D_E_L_E_T_ = ' ' "
			If !Empty(cFilSB8)
				cQuery += " AND " + cFilSB8
			EndIf
			// Se pesquisou somente pelo Local de estoque, busca os produtos que não foram encontrados
			// na tabela SBF.
			If Empty(aProdutos[nI,nPosProd]) .And. !Empty(aProdutos[nI,nPosLocal]) .And. !Empty(cAllProd)
				cQuery += " AND SB8.B8_PRODUTO NOT IN (" + cAllProd + ")"
			EndIf

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSld,.T.,.T.)
			While (cAliasSld)->(!Eof())
				lEntrou := .T.
				SB8->(dbGoTo((cAliasSld)->RECSB8))

				nPos := aScan(aInfXml,{|x| AllTrim(x[1]) == AllTrim(SB8->B8_PRODUTO) })

				If nPos == 0
					aAdd(aInfXml,{SB8->B8_PRODUTO, {} })
					nPos := Len(aInfXml)
					cAllProd += Iif(!Empty(cAllProd),","," ") + " '" + AllTrim(SB8->B8_PRODUTO) + "' "
				EndIf
				If AT("'"+AllTrim(SB8->B8_PRODUTO)+"'",cAllProd) <= 0
					cAllProd += Iif(!Empty(cAllProd),","," ") + " '" + AllTrim(SB8->B8_PRODUTO) + "' "
				EndIf
				aAdd(aInfXml[nPos,2],{SB8->B8_PRODUTO,;
				              SB8->B8_LOCAL,;
				              SB8->B8_LOTECTL,;
				              SB8->B8_DTVALID,;
				              "",;
				              SB8->B8_NUMLOTE,;
				              "",;
				              SB8->B8_SALDO,;
				              SB8->B8_EMPENHO,;
				              SB8->B8_SALDO - SB8->B8_EMPENHO})
				(cAliasSld)->(dbSkip())
			EndDo
			(cAliasSld)->(dbCloseArea())
			If !lEntrou .And. lPesqB2  .Or. ( lPesqB2 .And. Empty(aProdutos[nI,nPosProd]) .And. !Empty(aProdutos[nI,nPosLocal]) )
				cAliasSld := GetNextAlias()
				cQuery := " SELECT SB2.R_E_C_N_O_ RECSB2 "
				cQuery +=   " FROM " + RetSqlName("SB2") + " SB2 "
				cQuery +=  " WHERE SB2.B2_FILIAL  = '" + xFilial("SB2") + "' "
				cQuery +=    " AND SB2.D_E_L_E_T_ = ' ' "
				If !Empty(cFilQry)
					cQuery += " AND " + cFilQry
				EndIf
				// Se pesquisou somente pelo Local de estoque, busca os produtos que não foram encontrados
				// nas tabelas SBF e SB8.
				If Empty(aProdutos[nI,nPosProd]) .And. !Empty(aProdutos[nI,nPosLocal]) .And. !Empty(cAllProd)
					cQuery += " AND SB2.B2_COD NOT IN (" + cAllProd + ")"
				EndIf

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSld,.T.,.T.)
				While (cAliasSld)->(!Eof())
					lEntrou := .T.
					SB2->(dbGoTo((cAliasSld)->RECSB2))

					nPos := aScan(aInfXml,{|x| AllTrim(x[1]) == AllTrim(SB2->B2_COD) })

					If nPos == 0
						aAdd(aInfXml,{SB2->B2_COD, {} })
						nPos := Len(aInfXml)
					EndIf

					aAdd(aInfXml[nPos,2],{SB2->B2_COD,;
					              SB2->B2_LOCAL,;
					              "",;
					              "",;
					              "",;
					              "",;
					              "",;
					              SB2->B2_QATU,;
					              SB2->B2_RESERVA,;
					              SB2->B2_QATU - SB2->B2_RESERVA})
					(cAliasSld)->(dbSkip())
				EndDo
				(cAliasSld)->(dbCloseArea())
			EndIf
		EndIf
		If !lEntrou .And. !Empty(aProdutos[nI,nPosProd])
			nPos := aScan(aInfXml,{|x| AllTrim(x[1]) == AllTrim(aProdutos[nI,nPosProd]) })
			If nPos == 0
				aAdd(aInfXml,{aProdutos[nI,nPosProd], {} })
				nPos := Len(aInfXml)
			EndIf
			aAdd(aInfXml[nPos,2],{aProdutos[nI,nPosProd],;
					              aProdutos[nI,nPosLocal],;
					              aProdutos[nI,nPosLote],;
					              aProdutos[nI,nPosDtVld],;
					              aProdutos[nI,nPosSerie],;
					              aProdutos[nI,nPosSbLote],;
					              aProdutos[nI,nPosEnder],;
					              0,;
					              0,;
					              0})
		EndIf
	Next nI

	If Len(aInfXml) < 1
		lRet := .F.
		cXmlRet := STR0013 // "Saldo não encontrado."
		Return {lRet, cXmlRet}
	EndIf
	cXMLRet += '<ListOfReturnItem>'
	For nI := 1 To Len(aInfXml)
		cXMLRet  += '<ReturnItem>'
		cXMLRet  +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet  +=    '<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet  +=    '<CompanyInternalId>' + cEmpAnt + "|" + cFilAnt + '</CompanyInternalId>'
		cXMLRet  +=    '<ItemInternalId>' + aInfXml[nI,1] + '</ItemInternalId>'
		cXmlRet  +=    '<ListOfStockBalance>'
		For nX := 1 To Len(aInfXml[nI,2])
			cXmlRet  +=          '<StockBalance>'
			cXmlRet  +=             '<WarehouseInternalId>'+aInfXml[nI,2,nX,2]+'</WarehouseInternalId>'
			cXmlRet  +=             '<LotNumber>'+aInfXml[nI,2,nX,3]+'</LotNumber>'
			cXmlRet  +=             '<LotExpirationDate>'+getDateStr(aInfXml[nI,2,nX,4])+'</LotExpirationDate>'
			cXmlRet  +=             '<SerialNumber>'+aInfXml[nI,2,nX,5]+'</SerialNumber>'
			cXmlRet  +=             '<SubLotCode>'+aInfXml[nI,2,nX,6]+'</SubLotCode>'
			cXmlRet  +=             '<Address>'+aInfXml[nI,2,nX,7]+'</Address>'
			cXmlRet  +=             '<CurrentStockAmount>'+cValToChar(aInfXml[nI,2,nX,8])+'</CurrentStockAmount>'
			cXmlRet  +=             '<BookedStockAmount>'+cValToChar(aInfXml[nI,2,nX,9])+'</BookedStockAmount>'
			cXmlRet  +=             '<AvailableStockAmount>'+cValToChar(aInfXml[nI,2,nX,10])+'</AvailableStockAmount>'
			cXmlRet  +=          '</StockBalance>'
		Next nX
		cXmlRet  +=    '</ListOfStockBalance>'
		cXMLRet  += '</ReturnItem>'
	Next nI
	cXMLRet += '</ListOfReturnItem>'
Else
	lRet    := .F.
	cXmlRet := STR0005 // "Erro no parser!"
	Return {lRet, cXmlRet}
Endif
Return { lRet, cXmlRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} MTICalPrd()
Obtem o codigo do produto
@author Flavio Lopes Rasta
@since 26/12/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function MTIGetCod(cCodigo)

While At('|',cCodigo) > 0
	cCodigo:= Substr(cCodigo,At('|',cCodigo)+1)
EndDo

Return cCodigo

//-------------------------------------------------------------------
/*/{Protheus.doc} getDateStr()
Formata uma data e uma hora para o formato DateTime

@param   dDate  - Data que será transformada para String
@param   cHora  - Hora

@author  Lucas Konrad França
@version P12
@since   03/09/2015
@return  cDataHora
/*/
//-------------------------------------------------------------------
Static Function getDateStr(dDate)
   Local cDate     := ""

   If !Empty(dDate)
      cDate := DtoS(dDate)

      cDate := SubStr(cDate, 1, 4) + '-' + SubStr(cDate, 5, 2) + '-' + SubStr(cDate, 7, 2)
   EndIf
Return cDate

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDate

Retorna somente a data de uma variável datetime

@param dDateTime - Variável DateTime

@return dDate - Retorna a data.

@author  Lucas Konrad França
@version P12
@since   24/09/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function getDate(dDateTime)
   Local dDate := Nil
   If AT("T",dDateTime) > 0
      dDate := StrTokArr(dDateTime,"T")[1]
   Else
      dDate := StrTokArr(AllTrim(dDateTime)," ")[1]
   EndIf
   dDate := SubStr(dDate,1,4)+SubStr(dDate,6,2)+SubStr(dDate,9,2)
Return dDate

//-------------------------------------------------------------------
/*/{Protheus.doc} completXml()
Adiciona o cabeçalho da mensagem quando utilizado integração com o PPI.

@param   cXML  - XML gerado pelo adapter. Parâmetro recebido por referência.

@author  Lucas Konrad França
@version P12
@since   13/08/2015
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function completXml(cXML)
	Local cCabec     := ""
	Local cCloseTags := ""
	Local cGenerated := ""
	Local cTime      := Time()

	//Se já gerou um xml com esse horario, soma 1 segundo para evitar chave duplicada na SOF
	IF AScan(aTimesGen, cTime) == 0
		Aadd(aTimesGen, cTime)
	ELSE
		cTime := IncTime(cTime,0,0,1 )

		While .T.
			IF AScan(aTimesGen, cTime) == 0
				Aadd(aTimesGen, cTime)
				Exit
			Else
				cTime := IncTime(cTime,0,0,1 )
			EndIf
		End				
	ENDIF

	cGenerated := SubStr(DTOS(Date()), 1, 4) + '-' + SubStr(DTOS(Date()), 5, 2) + '-' + SubStr(DTOS(Date()), 7, 2) + 'T' + cTime//Time()
	cCabec := '<?xml version="1.0" encoding="UTF-8" ?>'
	cCabec += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="xmlschema/general/events/ItemStockLevel_1_000.xsd">'
	cCabec +=     '<MessageInformation version="1.000">'
	cCabec +=         '<UUID>1</UUID>'
	cCabec +=         '<Type>BusinessMessage</Type>'
	cCabec +=         '<Transaction>ItemStockLevel</Transaction>'
	cCabec +=         '<StandardVersion>1.0</StandardVersion>'
	cCabec +=         '<SourceApplication>SIGAPCP</SourceApplication>'
	cCabec +=         '<CompanyId>'+cEmpAnt+'</CompanyId>'
	cCabec +=         '<BranchId>'+cFilAnt+'</BranchId>'
	cCabec +=         '<UserId>'+__cUserId+'</UserId>'
	cCabec +=         '<Product name="'+FunName()+'" version="'+GetRPORelease()+'"/>'
	cCabec +=         '<ContextName>PROTHEUS</ContextName>'
	cCabec +=         '<GeneratedOn>' + cGenerated +'</GeneratedOn>'
	cCabec +=         '<DeliveryType>Sync</DeliveryType>'
	cCabec +=     '</MessageInformation>'
	cCabec +=     '<BusinessMessage>'

	cCloseTags := '</BusinessMessage>'
	cCloseTags += '</TOTVSMessage>'

	cXML := cCabec + cXML + cCloseTags
Return cXML

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI225SND()
Send de mensagem de movimentação de estoque PPI

@param   cXML  - XML gerado pelo adapter. Parâmetro recebido por referência.

@author  Samantha Preima
@version P12
@since   02/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------
Function MATI225SND()
Local cXMLRet
Local lRet   := .T.
Local cXMLini   := ''
Local cXMLmeio  := ''

Private cAliasTop := GetNextAlias()

Default cProdPPI := ' '

If Empty(cProdPPI)
	cXmlRet := ' '
	Return {lRet, cXmlRet}
EndIf

if Localiza(cProdPPI) .And. !Empty(cLocaliPPI)

	dbSelectArea('SBF')
	SBF->(dbSetOrder(1))
	If SBF->(dbSeek(xFilial('SBF')+cArmPPI+cLocaliPPI+cProdPPI+cNumserPPI+cLotctlPPI+cNumlotPPI))

		if PCPFiltPPI('SBF', cProdPPI, 'SBF')

			//Quando a quantidade (QuantityUpdated) é zero e o CurrentStockAmount maior do que zero a variavel cAcao deve ser 3.
			If SBF->BF_QUANT > 0 .and. nQuantPPI = 0
				cAcaoPPI := '3'
			EndIf 
			
			cXMLmeio += 	'<LotCode>'      + AllTrim(SBF->BF_LOTECTL) + '</LotCode>'
			cXMLmeio += 	'<SubLotCode>'   + AllTrim(SBF->BF_NUMLOTE) + '</SubLotCode>'
			cXMLmeio += 	'<NumberSeries>' + AllTrim(SBF->BF_NUMSERI) + '</NumberSeries>'
			cXMLmeio += 	'<AddressCode>'  + AllTrim(SBF->BF_LOCALIZ) + '</AddressCode>'
			cXMLmeio += 	'<LotDueDate>' + getVldLote(SBF->BF_PRODUTO,SBF->BF_LOCAL,SBF->BF_LOTECTL,SBF->BF_NUMLOTE) + '</LotDueDate>'
			cXMLmeio += 	'<CurrentStockAmount>'   + AllTrim(STR(SBF->BF_QUANT)) + '</CurrentStockAmount>'
			cXMLmeio +=		'<BookedStockAmount>'    + AllTrim(STR(SBF->BF_EMPENHO)) + '</BookedStockAmount>'
			cXMLmeio += 	'<AvailableStockAmount>' + AllTrim(STR(SBF->BF_QUANT - SBF->BF_EMPENHO)) + '</AvailableStockAmount>'

			cChavePPI += '+' + Alltrim(STR(SBF->(Recno()))) + '+SBF'

		Else
			cXMLRet := ''
			lRet    := .F.
		Endif
	Else
		// Se não encontrar, registro pode ter sido eliminado
		IF Type('aDelPPI') == 'A' .AND. Len(aDelPPI) > 0
			BeginSql Alias cAliasTop

				SELECT SBF.*, D_E_L_E_T_ AS DELETED FROM %Table:SBF% SBF
					WHERE SBF.R_E_C_N_O_ = %Exp:aDelPPI[1]%

			EndSql

			if PCPFiltPPI('SBF', cProdPPI, '(cAliasTop)')

				if (cAliasTop)->DELETED == '*'
					cEventPPI = 'delete'
				Endif

				cXMLmeio += 	'<LotCode>'      + AllTrim((cAliasTop)->BF_LOTECTL) + '</LotCode>'
				cXMLmeio += 	'<SubLotCode>'   + AllTrim((cAliasTop)->BF_NUMLOTE) + '</SubLotCode>'
				cXMLmeio += 	'<NumberSeries>' + AllTrim((cAliasTop)->BF_NUMSERI) + '</NumberSeries>'
				cXMLmeio += 	'<AddressCode>'  + AllTrim((cAliasTop)->BF_LOCALIZ) + '</AddressCode>'
				cXMLmeio += 	'<LotDueDate>' + getVldLote(SBF->BF_PRODUTO,SBF->BF_LOCAL,SBF->BF_LOTECTL,SBF->BF_NUMLOTE) + '</LotDueDate>'
				cXMLmeio += 	'<CurrentStockAmount>'   + AllTrim(STR((cAliasTop)->BF_QUANT)) + '</CurrentStockAmount>'
				cXMLmeio +=		'<BookedStockAmount>'    + AllTrim(STR((cAliasTop)->BF_EMPENHO)) + '</BookedStockAmount>'
				cXMLmeio += 	'<AvailableStockAmount>' + AllTrim(STR((cAliasTop)->BF_QUANT - SBF->BF_EMPENHO)) + '</AvailableStockAmount>'

				cChavePPI += '+' + Alltrim(STR(aDelPPI[1])) + '+SBF'

			Else
				cXMLRet := ''
				lRet    := .F.
			Endif

			(cAliasTop)->(dbCloseArea())
		Else
			cXMLRet := ''
			lRet    := .F.
		Endif
	Endif

ElseIf Rastro(cProdPPI) .And. (!Empty(cLotctlPPI) .Or. !Empty(cNumlotPPI))
	dbSelectArea('SB8')
	SB8->(dbSetOrder(1))
	if SB8->(dbSeek(xFilial('SB8')+cProdPPI+cArmPPI+DTOS(dValidPPI)+cLotctlPPI+cNumlotPPI))

		if PCPFiltPPI('SB8', cProdPPI, 'SB8')

			//Quando a quantidade (QuantityUpdated) é zero e o CurrentStockAmount maior do que zero a variavel cAcao deve ser 3.
			If SB8->B8_SALDO > 0 .and. nQuantPPI = 0
				cAcaoPPI := '3'
			EndIf 
			
			cXMLmeio += 	'<LotCode>'      + AllTrim(SB8->B8_LOTECTL) + '</LotCode>'
			cXMLmeio += 	'<SubLotCode>'   + AllTrim(SB8->B8_NUMLOTE) + '</SubLotCode>'
			cXMLmeio += 	'<NumberSeries></NumberSeries>'
			cXMLmeio += 	'<AddressCode></AddressCode>'
			cXMLmeio += 	'<LotDueDate>' + Substr(DTOS(SB8->B8_DTVALID),1,4) + '-' + Substr(DTOS(SB8->B8_DTVALID),5,2) + '-' + Substr(DTOS(SB8->B8_DTVALID),7,2) + 'T00:00:00</LotDueDate>'
			cXMLmeio += 	'<CurrentStockAmount>'   + AllTrim(STR(SB8->B8_SALDO)) + '</CurrentStockAmount>'
			cXMLmeio += 	'<BookedStockAmount>'    + AllTrim(STR(SB8->B8_EMPENHO)) + '</BookedStockAmount>'
			cXMLmeio += 	'<AvailableStockAmount>' + AllTrim(STR(SB8->B8_SALDO - SB8->B8_EMPENHO)) + '</AvailableStockAmount>'

			cChavePPI += '+' + Alltrim(STR(SB8->(Recno()))) + '+SB8'

		Else
			cXMLRet := ''
			lRet    := .F.
		Endif
	Else
		IF Type('aDelPPI') == 'A' .AND. Len(aDelPPI) > 0
			BeginSql Alias cAliasTop

				SELECT SB8.*, D_E_L_E_T_ AS DELETED FROM %Table:SB8% SB8
					WHERE SB8.R_E_C_N_O_ = %Exp:aDelPPI[1]%

			EndSql

			if PCPFiltPPI('SB8', cProdPPI, '(cAliasTop)')

				if (cAliasTop)->DELETED == '*'
					cEventPPI = 'delete'
				Endif

				cXMLmeio += 	'<LotCode>'      + AllTrim((cAliasTop)->B8_LOTECTL) + '</LotCode>'
				cXMLmeio += 	'<SubLotCode>'   + AllTrim((cAliasTop)->B8_NUMLOTE) + '</SubLotCode>'
				cXMLmeio += 	'<NumberSeries></NumberSeries>'
				cXMLmeio += 	'<AddressCode></AddressCode>'
				cXMLmeio += 	'<LotDueDate>' + Substr((cAliasTop)->B8_DTVALID,1,4) + '-' + Substr((cAliasTop)->B8_DTVALID,5,2) + '-' + Substr((cAliasTop)->B8_DTVALID,7,2) + 'T00:00:00</LotDueDate>'
				cXMLmeio += 	'<CurrentStockAmount>0</CurrentStockAmount>'
				cXMLmeio += 	'<BookedStockAmount>0</BookedStockAmount>'
				cXMLmeio += 	'<AvailableStockAmount>0</AvailableStockAmount>'

				cChavePPI += '+' + Alltrim(STR(aDelPPI[1])) + '+SB8'

			Else
				cXMLRet := ''
				lRet    := .F.
			Endif

			(cAliasTop)->(dbCloseArea())
		Else
			cXMLRet := ''
			lRet    := .F.
		Endif
	Endif
Else
	dbSelectArea('SB2')
	SB2->(dbSetOrder(1))
	if SB2->(dbSeek(xFilial('SB2')+cProdPPI+cArmPPI))
		if PCPFiltPPI('SB2', cProdPPI, 'SB2')

			//Quando a quantidade (QuantityUpdated) é zero e o CurrentStockAmount maior do que zero a variavel cAcao deve ser 3.
			If SB2->B2_QATU > 0 .and. nQuantPPI = 0
				cAcaoPPI := '3'
			EndIf 

			cXMLmeio += 	'<LotCode></LotCode>'
			cXMLmeio += 	'<SubLotCode></SubLotCode>'
			cXMLmeio += 	'<NumberSeries></NumberSeries>'
			cXMLmeio += 	'<AddressCode></AddressCode>'
			cXMLmeio += 	'<LotDueDate></LotDueDate>'
			cXMLmeio += 	'<CurrentStockAmount>'   + AllTrim(STR(SB2->B2_QATU)) + '</CurrentStockAmount>'
			cXMLmeio += 	'<BookedStockAmount>'    + AllTrim(STR(SB2->B2_RESERVA)) + '</BookedStockAmount>'
			cXMLmeio += 	'<AvailableStockAmount>' + AllTrim(STR(SB2->B2_QATU - SB2->B2_RESERVA)) + '</AvailableStockAmount>'

			cChavePPI += '+' + Alltrim(STR(SB2->(Recno()))) + '+SB2'

		Else
			cXMLRet := ''
			lRet    := .F.
		Endif
	ElseIf cEventPPI == 'delete'

		IF Type('aDelPPI') == 'A' .AND. Len(aDelPPI) > 0
			BeginSql Alias cAliasTop

				SELECT SB2.*, D_E_L_E_T_ AS DELETED FROM %Table:SB2% SB2
					WHERE SB2.R_E_C_N_O_ = %Exp:aDelPPI[1]%

			EndSql

			if PCPFiltPPI('SB2', cProdPPI, '(cAliasTop)')

				if (cAliasTop)->DELETED == '*'
					cEventPPI = 'delete'
				Endif

				cXMLmeio += 	'<LotCode></LotCode>'
				cXMLmeio += 	'<SubLotCode></SubLotCode>'
				cXMLmeio += 	'<NumberSeries></NumberSeries>'
				cXMLmeio += 	'<AddressCode></AddressCode>'
				cXMLmeio += 	'<LotDueDate></LotDueDate>'
				cXMLmeio += 	'<CurrentStockAmount>0</CurrentStockAmount>'
				cXMLmeio += 	'<BookedStockAmount>0</BookedStockAmount>'
				cXMLmeio += 	'<AvailableStockAmount>0</AvailableStockAmount>'

				cChavePPI += '+' + Alltrim(STR(aDelPPI[1])) + '+SB2'

			Else
				cXMLRet := ''
				lRet    := .F.
			Endif

			(cAliasTop)->(dbCloseArea())
		Else
			cXMLRet := ''
			lRet    := .F.
		Endif
	Endif
Endif

IF lRet
	// Monta XML de envio de mensagem unica
	cXMLini := '<BusinessEvent>'
	cXMLini +=    '<Entity>ItemStockLevel</Entity>'
	cXMLini +=    '<Event>' + cEventPPI + '</Event>'
	cXMLini +=    '<Identification>'
	cXMLini +=       '<key name="InternalID">' + AllTrim(cProdPPI) + '</key>'
	cXMLini +=    '</Identification>'
	cXMLini += '</BusinessEvent>'
	cXMLini += '<BusinessContent>'
	cXMLini +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLini +=    '<BranchId>' + RTrim(cFilAnt) + '</BranchId>'
	cXMLini +=    '<CompanyInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '</CompanyInternalId>'
	cXMLini +=    '<ItemCode>' + AllTrim(cProdPPI) + '</ItemCode>'
	cXMLini +=    '<ItemDescription>' + _NoTags(AllTrim(Posicione('SB1',1,xFilial('SB1')+cProdPPI,'B1_DESC'))) + '</ItemDescription>'
	cXMLini +=    '<ListOfStock>'
	cXMLini +=      '<Stock>'
	cXMLini +=        '<ReferenceCode></ReferenceCode>'
	cXMLini +=        '<WarehouseCode>' + AllTrim(cArmPPI) + '</WarehouseCode>'

	cXMLRet := cXMLini + cXMLmeio

	cXMLRet +=        '<QuantityUpdated>' + AllTrim(STR(nQuantPPI)) + '</QuantityUpdated>'
	cXMLRet +=        '<InputOutput>'     + Alltrim(cAcaoPPI) + '</InputOutput>'
	cXmlRet +=      '</Stock>'
	cXMLRet +=    '</ListOfStock>'
	cXMLRet += '</BusinessContent>'

	completXml(@cXMLRet)
Endif

Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} getVldLote()
Busca a data de validade do lote.

@param	cProduto	- Código do produto
@param	cLocal		- Código do local de estoque
@param	cLoteCTL	- Número do Lote
@param	cNumLote	- Número do Sub-lote

@author  Lucas Konrad França
@version P12
@since   22/12/2017
@return  cVldLote - Data de validade do lote, no formato AAAA-MM-DDT00:00:00
/*/
//-------------------------------------------------------------------
Static Function getVldLote(cProduto,cLocal,cLoteCTL,cNumLote)
	Local cVldLote := ""
	Local aAreaB8 := SB8->(GetArea())

	SB8->(dbSetOrder(3))
	If SB8->(dbSeek(xFilial("SB8")+cProduto+cLocal+cLoteCTL+cNumLote))
		//Se encontrar registro do lote, monta a string com a data de validade
		cDtLote := DtOs(SB8->B8_DTVALID)
		cVldLote := Substr(cDtLote,1,4) + '-' + Substr(cDtLote,5,2) + '-' + Substr(cDtLote,7,2) + 'T00:00:00'
	EndIf
	SB8->(RestArea(aAreaB8))
Return cVldLote

/*/{Protheus.doc} v3000
Consulta de StockLevel da versão 3.x.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.
@param   lEAIObj       Indica se é mensagem XML (.F.) ou JSON (.T.).

@return	 lRet     Indica se a mensagem foi processada com sucesso
@return	 cXMLRet  XML de retorno da funcao

@author	Paulo Henrique Santos de Moura
@since		09/03/2018
@version	P12.14
/*/
Static Function v3000(cXml, cTypeTrans, cTypeMsg, lEAIObj,cVersion)

Local lRet       := .T.
Local aRet       := {.F., ""}
Local cQuery     := ""
Local cAliasTop  := ""
Local cError     := ""
Local cWarning   := ""
Local cMarca     := ""
Local cXMLRet    := ""
Local cItemIntId := ""
Local aIntId     := {}
Local cFilProd   := ""
Local cProduto   := ""
Local cLocal     := ""
Local cLote      := ""
Local cSubLote   := ""
Local cNumSeri   := ""
Local cAddress   := ""
Local dDatVld    := CtoD("//")
Local dRefDate   := CToD("//")
Local dDataSrv   := Date()
Local aFilSol    := {}
Local aFilEst    := {}
Local lDateRetro := .F.
Local cSaldoTab  := ""
Local aProdutos  := {}
Local nPosProd   := 1
Local nPosLocal  := 2
Local nPosLote   := 3
Local nPosSbLote := 4
Local nPosDtVld  := 5
Local nPosEnder  := 6
Local nPosSerie  := 7
Local nPosRefDat := 8
Local nPosFil    := 9
Local aInfXml    := {}
Local aStockVal  := {}
Local aStockTot  := {}
Local aStockWH   := {}
Local aStockLot  := {}
Local aStockAddr := {}
Local aStockSer  := {}
Local nUnitCost  := 0
Local aSaldo     := {}
Local nQuant     := 0
Local nValor     := 0
Local nReserva   := 0
Local nTransit   := 0
Local cFilBak    := cFilAnt
Local nI, nX, nAux
Local nQtdEmp    := 0
Local nQtdPv     := 0

Private oXMLM225    := NIL
Private aXmlProd    := {}
Private oXMLM225Aux as object
Private oXMLAux     as object

Default cVersion	:= ""

If cTypeTrans == TRANS_RECEIVE

	If !lEAIObj
		oXMLM225 := XmlParser(cXml, "_", @cError, @cWarning)
		If oXMLM225 <> Nil .And. Empty(cError) .And. Empty(cWarning)
			If Type("oXMLM225:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" .And. ;
				!Empty(oXMLM225:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
				cMarca := oXMLM225:_TOTVSMESSAGE:_MESSAGEINFORMATION:_PRODUCT:_NAME:TEXT
			Else
				lRet := .F.
				cXMLRet := STR0007 // "Product:Name é obrigatório."
			EndIf

			// Verifica se a integração com o PPI está ativa. Se não estiver, não permite prosseguir com a integração.
			If lRet .and. Upper(AllTrim(cMarca)) == "PPI" .and. !PCPIntgPPI()
				lRet := .F.
				cXmlRet := STR0008 // "Integração com o TOTVS MES desativada. Processamento não permitido."
			EndIf

			// Prepara os produtos solicitados.
			If lRet
				// Se não for array, faz a transformação
				If Type("oXMLM225:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfRequest:_Request") != "A"
					XmlNode2Arr(oXMLM225:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfRequest:_Request, "_Request")
				EndIf

				For nI := 1 To Len(oXMLM225:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfRequest:_Request)

					// Obtém a posição atual do objeto
					oXMLM225Aux := oXMLM225:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfRequest:_Request[nI]

					cItemIntId := ""
					cFilProd   := ""
					cProduto   := ""
					cLocal     := ""
					cLote      := ""
					cSubLote   := ""
					cNumSeri   := ""
					cAddress   := ""
					dDatVld    := SToD("")
					dRefDate   := SToD("")
					aFilSol    := {}

					// ItemInternalId
					If Type("oXMLM225Aux:_ItemInternalId:Text") <> "U" .And. !Empty(oXMLM225Aux:_ItemInternalId:Text)
						cItemIntId := oXMLM225Aux:_ItemInternalId:Text
						If Upper(AllTrim(cMarca)) == "PPI"
							cProduto := cItemIntId
						Else
							cProduto := CFGA070INT(cMarca, 'SB1', 'B1_COD', cItemIntId)
							If !empty(cProduto)
								aIntId   := StrTokArr2(cProduto, "|", .T.)
								cFilProd := aIntId[2]
								cProduto := aIntId[3]
							Endif
						EndIf
					EndIf

					If !empty(cProduto)
						// WarehouseInternalId
						If Type("oXMLM225Aux:_WarehouseInternalId:Text") <> "U" .And. !Empty(oXMLM225Aux:_WarehouseInternalId:Text)
							cLocal := oXMLM225Aux:_WarehouseInternalId:Text
							If Upper(AllTrim(cMarca)) != "PPI"
								cLocal := CFGA070INT(cMarca, 'NNR', 'NNR_CODIGO', cLocal)
								If !empty(cLocal)
									aIntId := StrTokArr2(cLocal, "|", .T.)
									cLocal := aIntId[3]
								Endif
							EndIf
						EndIf

						// LotNumber
						If Type("oXMLM225Aux:_LotNumber:Text") <> "U" .And. !Empty(oXMLM225Aux:_LotNumber:Text)
							cLote := oXMLM225Aux:_LotNumber:Text
						EndIf

						// SubLotCode
						If Type("oXMLM225Aux:_SubLotCode:Text") <> "U" .And. !Empty(oXMLM225Aux:_SubLotCode:Text)
							cSubLote := oXMLM225Aux:_SubLotCode:Text
						EndIf

						// LotExpirationDate
						If Type("oXMLM225Aux:_LotExpirationDate:Text") <> "U" .And. !Empty(oXMLM225Aux:_LotExpirationDate:Text)
							dDatVld := StoD(getDate(oXMLM225Aux:_LotExpirationDate:Text))
						EndIf

						// Address
						If Type("oXMLM225Aux:_Address:Text") <> "U" .And. !Empty(oXMLM225Aux:_Address:Text)
							cAddress := oXMLM225Aux:_Address:Text
						EndIf

						// SerialNumber
						If Type("oXMLM225Aux:_SerialNumber:Text") <> "U" .And. !Empty(oXMLM225Aux:_SerialNumber:Text)
							cNumSeri := oXMLM225Aux:_SerialNumber:Text
						EndIf

						// ReferenceDate
						If Type("oXMLM225Aux:_ReferenceDate:Text") <> "U" .And. !Empty(oXMLM225Aux:_ReferenceDate:Text)
							dRefDate := StoD(getDate(oXMLM225Aux:_ReferenceDate:Text))
						Else
							dRefDate := dDataSrv
						EndIf

						// ListOfCompany
						If empty(xFilial("SB1"))
							If Type("oXMLM225Aux:_ListOfCompany:_Company") <> "U"
								If Type("oXMLM225Aux:_ListOfCompany:_Company") <> "A"
									XmlNode2Arr(oXMLM225Aux:_ListOfCompany:_Company, "_Company")
								EndIf
								For nX := 1 to len(oXMLM225Aux:_ListOfCompany:_Company)
									oXMLAux := oXMLM225Aux:_ListOfCompany:_Company[nX]
									If Type("oXMLAux:_CompanyInternalId:Text") <> "U"
										aIntId := StrTokArr(oXMLAux:_CompanyInternalId:Text, "|")
										If ValType(aIntId) = "A" .and. len(aIntId) > 1
											aIntId := FWEAIEmpFil(aIntId[1], aIntId[2], cMarca)
											If ValType(aIntId) = "A" .and. len(aIntId) > 1
												If aIntId[1] = cEmpAnt
													aAdd(aFilSol, aIntId[2])
												Endif
											Endif
										Endif
									Endif
								Next nX

								// Se as filiais informadas não existem no Protheus, não retorna esse produto.
								If empty(aFilSol)
									cProduto := ""
								Endif
							Else
								// Se não foi informada nenhuma filial, pega apenas a filial em que o produto está cadastrado.
								aAdd(aFilSol, If(empty(cFilProd), cFilAnt, cFilProd))
							Endif

							// Verifica se existe matriz de abastecimento para a filial.
							aFilEst := {}
							For nX := 1 to len(aFilSol)
								// Adiciona a filial solicitada na matriz de retorno.
								If aScan(aFilEst, aFilSol[nX]) = 0
									aAdd(aFilEst, aFilSol[nX])
								Endif

								cQuery := "select DB5.DB5_FILABA "
								cQuery += "from " + RetSQLName("DB5") + " DB5 "
								cQuery += "where DB5.D_E_L_E_T_ = ' ' "
								cQuery += "and DB5.DB5_FILIAL  = '" + xFilial("DB5") + "' "
								cQuery += "and (DB5.DB5_FILDIS = '" + aFilSol[nX] + "' or DB5.DB5_FILABA = '" + aFilSol[nX] + "') "
								cQuery += "order by DB5.DB5_FILDIS, DB5.DB5_PRIORI, DB5.DB5_FILABA "
								cAliasTop := MPSysOpenQuery(cQuery)

								Do While (cAliasTop)->(!eof())
									If aScan(aFilEst, (cAliasTop)->DB5_FILABA) = 0
										aAdd(aFilEst, (cAliasTop)->DB5_FILABA)
									Endif
									(cAliasTop)->(dbSkip())
								EndDo
								(cAliasTop)->(dbCloseArea())
							Next nX
						Else
							// Se a tabela de produtos for exclusiva, não faz sentido tratar filiais.
							aFilEst := {cFilAnt}
						Endif

						// nPosProd   -> 1
						// nPosLocal  -> 2
						// nPosLote   -> 3
						// nPosSbLote -> 4
						// nPosDtVld  -> 5
						// nPosEnder  -> 6
						// nPosSerie  -> 7
						// nPosRefDat -> 8
						// nPosFil    -> 9
						If !empty(cProduto)
							aAdd(aProdutos, {cProduto, cLocal, cLote, cSubLote, dDatVld, cAddress, cNumSeri, dRefDate, aFilEst})
						Endif
					Endif
				Next nI

				If Len(aProdutos) < 1
					lRet := .F.
					cXmlRet := STR0012 // "RequestItem informado não possui nenhum filtro válido para realização da consulta de saldo."
				EndIf
			Endif

			If lRet
				aInfXml := {}
				For nI := 1 To Len(aProdutos)

					cProduto := PadR(aProdutos[nI, nPosProd],   TamSX3('B1_COD')[1])
					cLocal   := PadR(aProdutos[nI, nPosLocal],  TamSX3('B2_LOCAL')[1])
					cLote    := PadR(aProdutos[nI, nPosLote],   TamSX3('B8_LOTECTL')[1])
					cSubLote := PadR(aProdutos[nI, nPosSbLote], TamSX3('B8_NUMLOTE')[1])
					dDatVld  := aProdutos[nI, nPosDtVld]
					cAddress := PadR(aProdutos[nI, nPosEnder],  TamSX3('BF_LOCALIZ')[1])
					cNumSeri := PadR(aProdutos[nI, nPosSerie],  TamSX3('BF_NUMSERI')[1])
					dRefDate := aProdutos[nI, nPosRefDat]
					aFilEst  := aProdutos[nI, nPosFil]

					// Verifica se a consulta é para uma data retroativa.
					// Em caso de data retroativa, não será possível calcular as quantidades reservadas ou em trânsito.
					lDateRetro := (dRefDate <> dDataSrv)

					// Define de qual tabela o sistema irá retornar o saldo total do produto.
					If empty(cLote) .and. empty(cSubLote) .and. empty(dDatVld) .and. empty(cAddress) .and. empty(cNumSeri)
						cSaldoTab := "SB2"
					ElseIf empty(cAddress) .and. empty(cNumSeri)
						cSaldoTab := "SB8"
					Else
						cSaldoTab := "SBF"
					Endif

					// Processa todas as filiais solicitadas para o produto.
					aFilEst := aProdutos[nI, nPosFil]
					For nX := 1 to len(aFilEst)

						// Muda a filial do sistema.
						cFilAnt := aFilEst[nX]

						// Matriz com o saldo total do produto.
						aStockVal := {0, 0}
						aStockTot := {0, 0, 0, 0, 0}
						If cSaldoTab == "SB2"
							aAdd(aStockTot, MTSldTrFil(cProduto, dRefDate)[1])
						Endif

						// Adiciona o produto na matriz para montagem do XML posteriormente.
						aAdd(aInfXml, {cFilAnt, cProduto, dRefDate, aStockVal, aStockTot, {}, {}, {}, {},C0Origem(cFilAnt,cProduto)})
						aStockVal  := aTail(aInfXml)[4]  // Usado no cálculo de valor unitário.
						aStockTot  := aTail(aInfXml)[5]
						aStockWH   := aTail(aInfXml)[6]
						aStockLot  := aTail(aInfXml)[7]
						aStockAddr := aTail(aInfXml)[8]
						aStockSer  := aTail(aInfXml)[9]
						cStockOri  := aTail(aInfXml)[10]

						// SB2
						// Query para pegar todos os armazéns do produto.
						cQuery := "select SB2.R_E_C_N_O_ SB2RecNo "
						cQuery += "from " + RetSQLName("SB2") + " SB2 "
						cQuery += "where SB2.D_E_L_E_T_ = ' ' "
						cQuery += "and SB2.B2_FILIAL  = '" + xFilial("SB2") + "' "
						cQuery += "and SB2.B2_COD     = '" + cProduto + "' "
						If !empty(cLocal)
							cQuery += "and SB2.B2_LOCAL = '" + cLocal + "' "
						Endif
						cQuery += "order by SB2.B2_LOCAL "
						cAliasTop := MPSysOpenQuery(cQuery)
						Do While (cAliasTop)->(!eof())
							SB2->(dbGoTo((cAliasTop)->SB2RecNo))

							// Calcula o saldo do produto da data de referência.
							If lDateRetro
								aSaldo   := SB2->(CalcEst(B2_COD, B2_LOCAL, dRefDate))
								nQuant   := aSaldo[1]
								nValor   := aSaldo[2]
								nReserva := 0
								nTransit := 0								
								nQtdEmp  := 0							
								nQtdPv   := 0   
							Else
								nQuant   := SB2->B2_QATU
								nValor   := SB2->B2_VATU1
								nReserva := SB2->B2_RESERVA
								nTransit := SB2->(B2_SALPEDI + B2_QACLASS)								
								nQtdEmp  := SB2->B2_QEMP							
								nQtdPv   := SB2->B2_QPEDVEN								
							Endif

							// Cálculo de valor unitário.
							aStockVal[1] += nQuant
							aStockVal[2] += nValor

							If cSaldoTab == "SB2"
								// Aglutina estoque total.
								aStockTot[1] += nQuant
								aStockTot[2] += nReserva
								aStockTot[3] += nTransit
								aStockTot[4] += nQtdEmp
								aStockTot[5] += nQtdPv
								// Estoque por armazém.
								SB2->(aAdd(aStockWH, {B2_LOCAL, nQuant, nValor, nReserva, nTransit,nQtdEmp,nQtdPv}))
							Endif

							(cAliasTop)->(dbSkip())
						EndDo
						(cAliasTop)->(dbCloseArea())

						// SB8
						// Query para pegar todos os lotes.
						If cSaldoTab == "SB2" .or. cSaldoTab == "SB8"
							cQuery := "select SB2.R_E_C_N_O_ SB2RecNo, SB8.R_E_C_N_O_ SB8RecNo "
							cQuery += "from " + RetSQLName("SB8") + " SB8 "
							cQuery += "inner join " + RetSQLName("SB2") + " SB2 on SB2.D_E_L_E_T_ = ' ' "
							cQuery += "and SB2.B2_FILIAL  = '" + xFilial("SB2") + "' "
							cQuery += "and SB2.B2_COD     = SB8.B8_PRODUTO "
							cQuery += "and SB2.B2_LOCAL   = SB8.B8_LOCAL "
							cQuery += "where SB8.D_E_L_E_T_ = ' ' "
							cQuery += "and SB8.B8_FILIAL  = '" + xFilial("SB8") + "' "
							cQuery += "and SB8.B8_PRODUTO = '" + cProduto + "' "
							If !empty(cLocal)
								cQuery += "and SB8.B8_LOCAL   = '" + cLocal + "' "
							Endif
							If !empty(cLote)
								cQuery += "and SB8.B8_LOTECTL = '" + cLote + "' "
							Endif
							If !empty(cSubLote)
								cQuery += "and SB8.B8_NUMLOTE = '" + cSubLote + "' "
							Endif
							If !empty(dDatVld)
								cQuery += "and SB8.B8_DTVALID = '" + dtos(dDatVld) + "' "
							Endif
							cQuery += "order by SB8.B8_LOCAL, SB8.B8_LOTECTL, SB8.B8_NUMLOTE, SB8.B8_DTVALID "
							cAliasTop := MPSysOpenQuery(cQuery)
							Do While (cAliasTop)->(!eof())
								SB2->(dbGoTo((cAliasTop)->SB2RecNo))
								SB8->(dbGoTo((cAliasTop)->SB8RecNo))

								// Calcula o saldo do produto da data de referência.
								If lDateRetro
									nQuant   := SB8->(CalcEstL(B8_PRODUTO, B8_LOCAL, dRefDate, B8_LOTECTL, B8_NUMLOTE))[1]
									nReserva := 0
								Else
									nQuant   := SB8->B8_SALDO
									nReserva := SB8->B8_EMPENHO
								Endif

								If cSaldoTab == "SB8"
									// Aglutina estoque total.
									aStockTot[1] += nQuant
									aStockTot[2] += nReserva

									// Aglutina estoque por armazém.
									nAux := aScan(aStockWH, {|x| x[1] == SB8->B8_LOCAL})
									If nAux = 0
										SB8->(aAdd(aStockWH, {B8_LOCAL, nQuant, nQuant * SB2->B2_CM1, 0, 0,0,0}))
									Else
										aStockWH[nAux, 2] += nQuant
										aStockWH[nAux, 3] += (nQuant * SB2->B2_CM1)
									Endif
								Endif

								// Estoque por lote.
								SB8->(aAdd(aStockLot, {B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, nQuant, nReserva}))

								(cAliasTop)->(dbSkip())
							EndDo
							(cAliasTop)->(dbCloseArea())
						Endif

						// SBF
						// Query para pegar todos os endereços e séries.
						cQuery := "select SB2.R_E_C_N_O_ SB2RecNo, SB8.R_E_C_N_O_ SB8RecNo, SBF.R_E_C_N_O_ SBFRecNo "
						cQuery += "from " + RetSQLName("SBF") + " SBF "
						cQuery += "inner join " + RetSQLName("SB2") + " SB2 on SB2.D_E_L_E_T_ = ' ' "
						cQuery += "and SB2.B2_FILIAL  = '" + xFilial("SB2") + "' "
						cQuery += "and SB2.B2_COD     = SBF.BF_PRODUTO "
						cQuery += "and SB2.B2_LOCAL   = SBF.BF_LOCAL "
						cQuery += "left  join " + RetSQLName("SB8") + " SB8 on SB8.D_E_L_E_T_ = ' ' "
						cQuery += "and SB8.B8_FILIAL  = '" + xFilial("SB8") + "' "
						cQuery += "and SB8.B8_PRODUTO = SBF.BF_PRODUTO "
						cQuery += "and SB8.B8_LOCAL   = SBF.BF_LOCAL "
						cQuery += "and SB8.B8_LOTECTL = SBF.BF_LOTECTL "
						cQuery += "and SB8.B8_NUMLOTE = SBF.BF_NUMLOTE "
						cQuery += "where SBF.D_E_L_E_T_ = ' ' "
						cQuery += "and SBF.BF_FILIAL  = '" + xFilial("SBF") + "' "
						cQuery += "and SBF.BF_PRODUTO = '" + cProduto + "' "
						If !empty(cLocal)
							cQuery += "and SBF.BF_LOCAL   = '" + cLocal + "' "
						Endif
						If !empty(cLote)
							cQuery += "and SBF.BF_LOTECTL = '" + cLote + "' "
						Endif
						If !empty(cSubLote)
							cQuery += "and SBF.BF_NUMLOTE = '" + cSubLote + "' "
						Endif
						If !empty(dDatVld)
							cQuery += "and SB8.B8_DTVALID = '" + dtos(dDatVld) + "' "
						Endif
						If !empty(cAddress)
							cQuery += "and SBF.BF_LOCALIZ = '" + cAddress + "' "
						Endif
						If !empty(cNumSeri)
							cQuery += "and SBF.BF_NUMSERI = '" + cNumSeri + "' "
						Endif
						cQuery += "order by SBF.BF_LOCAL, SBF.BF_LOTECTL, SBF.BF_NUMLOTE, SBF.BF_LOCALIZ, SBF.BF_NUMSERI "
						cAliasTop := MPSysOpenQuery(cQuery)
						Do While (cAliasTop)->(!eof())
							SB2->(dbGoTo((cAliasTop)->SB2RecNo))
							SB8->(dbGoTo((cAliasTop)->SB8RecNo))
							SBF->(dbGoTo((cAliasTop)->SBFRecNo))

							// Calcula o saldo do produto da data de referência.
							If lDateRetro
								nQuant   := SBF->(CalcEstL(BF_PRODUTO, BF_LOCAL, dRefDate, BF_LOTECTL, BF_NUMLOTE, BF_LOCALIZ, BF_NUMSERI))[1]
								nReserva := 0
							Else
								nQuant   := SBF->BF_QUANT
								nReserva := SBF->BF_EMPENHO
							Endif

							If cSaldoTab == "SBF"
								// Aglutina estoque total.
								aStockTot[1] += nQuant
								aStockTot[2] += nReserva

								// Aglutina estoque por armazém.
								nAux := aScan(aStockWH, {|x| x[1] == SBF->BF_LOCAL})
								If nAux = 0
									SBF->(aAdd(aStockWH, {BF_LOCAL, nQuant, nQuant * SB2->B2_CM1, 0, 0,0,0}))
								Else
									aStockWH[nAux, 2] += nQuant
									aStockWH[nAux, 3] += (nQuant * SB2->B2_CM1)
								Endif

								// Aglutina estoque por lote.
								nAux := aScan(aStockLot, {|x| x[1] + x[2] + x[3] == SB8->(B8_LOCAL + B8_LOTECTL + B8_NUMLOTE)})
								If nAux = 0
									SB8->(aAdd(aStockLot, {B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, nQuant, nReserva}))
								Else
									aStockLot[nAux, 5] += nQuant
									aStockLot[nAux, 6] += nReserva
								Endif
							Endif

							// Estoque por endereço.
							nAux := aScan(aStockAddr, {|x| x[1] + x[2] + x[3] + x[4] == SBF->(BF_LOCAL + BF_LOTECTL + BF_NUMLOTE + BF_LOCALIZ)})
							If nAux = 0
								SBF->(aAdd(aStockAddr, {BF_LOCAL, BF_LOTECTL, BF_NUMLOTE, BF_LOCALIZ, nQuant, nReserva}))
							Else
								aStockAddr[nAux, 5] += nQuant
								aStockAddr[nAux, 6] += nReserva
							Endif

							// Estoque por série.
							SBF->(aAdd(aStockSer, {BF_LOCAL, BF_LOTECTL, BF_NUMLOTE, BF_LOCALIZ, BF_NUMSERI, nQuant, nReserva}))

							(cAliasTop)->(dbSkip())
						EndDo
						(cAliasTop)->(dbCloseArea())
					Next nX

					// Restaura a filial do sistema.
					cFilAnt := cFilBak
				Next nI

				If empty(aInfXml)
					lRet := .F.
					cXmlRet := STR0013 // "Saldo não encontrado."
				EndIf
			Endif

			If lRet
				cXMLRet += '<ListOfReturnItem>'
				For nI := 1 To Len(aInfXml)

					cFilAnt    := aInfXml[nI, 1]
					cProduto   := aInfXml[nI, 2]
					dRefDate   := aInfXml[nI, 3]
					aStockVal  := aInfXml[nI, 4]  // Usado no cálculo de valor unitário.
					aStockTot  := aInfXml[nI, 5]
					aStockWH   := aInfXml[nI, 6]
					aStockLot  := aInfXml[nI, 7]
					aStockAddr := aInfXml[nI, 8]
					aStockSer  := aInfXml[nI, 9]
					cStockOri  := aInfXml[nI, 10]
					nUnitCost  := If(aStockVal[1] = 0, 0, aStockVal[2] / aStockVal[1])

					cXMLRet  += '<ReturnItem>'
					cXMLRet  +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
					cXMLRet  +=    '<BranchId>' + cFilAnt + '</BranchId>'
					cXMLRet  +=    '<CompanyInternalId>' + cEmpAnt + "|" + cFilAnt + '</CompanyInternalId>'
					cXMLRet  +=    '<ItemInternalId>' + IntProExt(,, cProduto)[2] + '</ItemInternalId>'
					cXMLRet  +=    '<ReferenceDate>' + getDateStr(dRefDate) + '</ReferenceDate>'

					// Totalizadores por produto.
					cXMLRet  +=    '<CurrentStockAmount>' + cValToChar(aStockTot[1]) + '</CurrentStockAmount>'
					cXMLRet  +=    '<AvailableStockAmount>' + cValToChar(aStockTot[1] - aStockTot[2]) + '</AvailableStockAmount>'
					cXMLRet  +=    '<BookedStockAmount>' + cValToChar(aStockTot[2]) + '</BookedStockAmount>'
					If len(aStockTot) > 5 
						cXMLRet  +=    '<TransitStockAmount>' + cValToChar(aStockTot[6]) + '</TransitStockAmount>'
					Endif
					cXMLRet  +=    '<FutureStockAmount>' + cValToChar(aStockTot[3]) + '</FutureStockAmount>'
					cXMLRet  +=    '<ReserveSource>' + cValToChar(cStockOri) + '</ReserveSource>'
					cXMLRet  +=    '<UnitItemCost>' + cValToChar(nUnitCost) + '</UnitItemCost>'
					cXMLRet  +=    '<AverageUnitItemCost>' + cValToChar(nUnitCost) + '</AverageUnitItemCost>'
					cXMLRet  +=    '<ValueOfCurrentStockAmount>' + cValToChar(aStockTot[1] * nUnitCost) + '</ValueOfCurrentStockAmount>'

					cXMLRet  +=    '<Amountcommittedstock>' + cValToChar(aStockTot[4] ) + '</Amountcommittedstock>' 
					cXMLRet  +=    '<SalesOrderQuantity>'   + cValToChar(aStockTot[5] ) + '</SalesOrderQuantity>' 

					// Totalizadores por armazém (WareHouse).
					cXmlRet  +=    '<ListOfWarehouseStock>'
					For nX := 1 To len(aStockWH)
						cXmlRet  +=		'<WarehouseStock>'
						cXMLRet  +=			'<WarehouseInternalId>'	+ IntLocExt(,, aStockWH[nX, 1])[2] + '</WarehouseInternalId>'
						cXMLRet  +=			'<CurrentStockAmount>' + cValToChar(aStockWH[nX, 2]) +	'</CurrentStockAmount>'
						cXMLRet  +=			'<AvailableStockAmount>' + cValToChar(aStockWH[nX, 2] - aStockWH[nX, 4]) +	'</AvailableStockAmount>'
						cXMLRet  +=			'<BookedStockAmount>' + cValToChar(aStockWH[nX, 4]) +	'</BookedStockAmount>'
						cXMLRet  +=			'<FutureStockAmount>' + cValToChar(aStockWH[nX, 5]) +	'</FutureStockAmount>'
						cXMLRet  +=    		'<UnitItemCost>' + cValToChar(If(aStockWH[nX, 2] = 0, 0, aStockWH[nX, 3] / aStockWH[nX, 2])) + 	'</UnitItemCost>'
						cXMLRet  +=    		'<ValueOfCurrentStockAmount>' + cValToChar(aStockWH[nX, 3]) + '</ValueOfCurrentStockAmount>'
						cXMLRet  +=         '<Amountcommittedstock>' + cValToChar(aStockWH[nX, 6] ) + '</Amountcommittedstock>' 
						cXMLRet  +=         '<SalesOrderQuantity>'   + cValToChar(aStockWH[nX, 7] ) + '</SalesOrderQuantity>' 
				cXmlRet  +=		'</WarehouseStock>'
					Next nX
					cXmlRet  +=    '</ListOfWarehouseStock>'

					// Totalizadores por lote (Lot).
					cXmlRet  +=    '<ListOfLotStock>'
					For nX := 1 To len(aStockLot)
						cXmlRet  +=		'<LotStock>'
						cXMLRet  +=			'<WarehouseInternalId>' + IntLocExt(,, aStockLot[nX, 1])[2] + '</WarehouseInternalId>'
						cXMLRet  +=			'<LotNumber>' + RTrim(aStockLot[nX, 2]) + '</LotNumber>'
						cXMLRet  +=			'<SubLotCode>' + RTrim(aStockLot[nX, 3]) + '</SubLotCode>'
						cXMLRet  +=			'<LotExpirationDate>' + Transform(aStockLot[nX, 4], "@R 9999-99-99") + '</LotExpirationDate>'
						cXMLRet  +=			'<CurrentStockAmount>' + cValToChar(aStockLot[nX, 5]) +	'</CurrentStockAmount>'
						cXMLRet  +=			'<AvailableStockAmount>' + cValToChar(aStockLot[nX, 5] - aStockLot[nX, 6]) + '</AvailableStockAmount>'
						cXMLRet  +=			'<BookedStockAmount>' + cValToChar(aStockLot[nX, 6]) + '</BookedStockAmount>'
						cXmlRet  +=		'</LotStock>'
					Next nX
					cXmlRet  +=    '</ListOfLotStock>'

					// Totalizadores por endereço (Address).
					cXmlRet  +=    '<ListOfAddressStock>'
					For nX := 1 To len(aStockAddr)
						cXmlRet  +=		'<AddressStock>'
						cXMLRet  +=			'<WarehouseInternalId>' + IntLocExt(,, aStockAddr[nX, 1])[2] + '</WarehouseInternalId>'
						cXMLRet  +=			'<Address>' + RTrim(aStockAddr[nX, 4]) + '</Address>'
						cXMLRet  +=			'<LotNumber>' + RTrim(aStockAddr[nX, 2]) + '</LotNumber>'
						cXMLRet  +=			'<SubLotCode>' + RTrim(aStockAddr[nX, 3]) + '</SubLotCode>'
						cXMLRet  +=			'<CurrentStockAmount>' + cValToChar(aStockAddr[nX, 5]) + '</CurrentStockAmount>'
						cXMLRet  +=			'<AvailableStockAmount>' + cValToChar(aStockAddr[nX, 5] - aStockAddr[nX, 6]) + '</AvailableStockAmount>'
						cXMLRet  +=			'<BookedStockAmount>' + cValToChar(aStockAddr[nX, 6]) +	'</BookedStockAmount>'
						cXmlRet  +=		'</AddressStock>'
					Next nX
					cXmlRet  +=    '</ListOfAddressStock>'

					// Totalizadores por serial (SerialNumber).
					cXmlRet  +=    '<ListOfSeriesStock>'
					For nX := 1 To len(aStockSer)
						cXmlRet  +=		'<SeriesStock>'
						cXMLRet  +=			'<WarehouseInternalId>' + IntLocExt(,, aStockSer[nX, 1])[2] + '</WarehouseInternalId>'
						cXMLRet  +=			'<Address>' + RTrim(aStockSer[nX, 4]) + '</Address>'
						cXMLRet  +=			'<LotNumber>' + RTrim(aStockSer[nX, 2]) + '</LotNumber>'
						cXMLRet  +=			'<SubLotCode>' + RTrim(aStockSer[nX, 3]) + '</SubLotCode>'
						cXMLRet  +=			'<SerialNumber>' + RTrim(aStockSer[nX, 5]) + '</SerialNumber>'
						cXMLRet  +=			'<CurrentStockAmount>' + cValToChar(aStockSer[nX, 6]) + '</CurrentStockAmount>'
						cXMLRet  +=			'<AvailableStockAmount>' + cValToChar(aStockSer[nX, 6] - aStockSer[nX, 7]) + '</AvailableStockAmount>'
						cXMLRet  +=			'<BookedStockAmount>' + cValToChar(aStockSer[nX, 7]) +	'</BookedStockAmount>'
						cXmlRet  +=		'</SeriesStock>'
					Next nX
					cXmlRet  +=    '</ListOfSeriesStock>'

					cXMLRet  += '</ReturnItem>'
				Next nI
				cXMLRet += '</ListOfReturnItem>'

				// Restaura a filial do sistema.
				cFilAnt := cFilBak
			Endif

			aRet := {lRet, cXMLRet}
		Else
			lRet    := .F.
			cXmlRet := STR0005 // "Erro no parser!"
		Endif
	EndIf
ElseIf cTypeTrans == TRANS_SEND
	// Solicita estoque do produto com base no movimento da SB2, o retorno sempre será por armazem e não passa demais parametros permitidos quando o retorno é por mensagem de Request
	// O modo TRANS_SEND é chamado na rotina SCHEDESTMG(), que pode ser configurada no Schedule para o envio de atualizações de estoque
	// Não é permitido chamar o IntegDef dentro da rotina B2AtuComD1,B2AtuComD2,B2AtuComD3 devido a impacto na performance da gravação das notas(entrada/saída)
	If FwEaiInSinc()	//quando carga inicial, envia a mensagem por item(SB1) sem filtro por armazém
		cProduto 	:= SB1->B1_COD
		cLocal		:= CriaVar( "B1_LOCPAD", .F. )
	Else
		cProduto 	:= SB2->B2_COD
		cLocal		:= SB2->B2_LOCAL
	EndIf
	aAdd(aProdutos,{cProduto, cLocal, cLote, cSubLote, cNumSeri, cAddress, dDatVld})

	aRet := getXml3000(aProdutos, cTypeTrans, cMarca, lEAIObj,cVersion)
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getXml3000()
Monta XML de retorno, mensagem do tipo Request, utiliza o mesmo XML
para TRANS_SEND ou para TRANS_RECEIVE

@param	aProdutos	- Array de Produto contendo:
		{	cProduto,
			cLocal,
			cLote,
			cSubLote,
			cNumSeri,
			cAddress,
			dDatVld
		}

@author  Paulo Henrique Santos de Moura
@version P12
@since   28/12/2017
@return  aInfXml - Array com retorno contendo o XML e se houve sucesso
/*/
//-------------------------------------------------------------------
Static Function getXml3000(aProdutos, cTypeTrans, cMarca, lEAIObj,cVersion)

Local nI			:= 0
Local cAliasBase	:= ""
Local cAliasSB2		:= ""
Local cAliasSB8		:= ""
Local cQuery		:= ""
Local nPosProd   	:= 1
Local nPosLocal  	:= 2
Local aInfXml		:= {}
Local aInfTotais	:= {}
Local aInfWareHouse	:= {}
Local aInfLot		:= {}
Local aInfAddress	:= {}
Local ainfSeries	:= {}
Local cXMLRet		:= ""
Local cLocal		:= ""
Local cLocInt		:= ""  //InternalId do local de estoque
Local nSldDispo		:= 0
Local nTotDispo		:= 0
Local cEvento		:= "upsert"
Local ofwEAIObj		:= nil
Local aRet			:= {}

Default aProdutos	:= {}
Default cTypeTrans	:= ""
Default cMarca		:= ""
Default lEAIObj 	:= .f.
Default cVersion	:= ""

DbSelectArea("SB2")
SB2->(dbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL

If lEAIObj
	ofwEAIObj := FWEAIobj():NEW()
EndIf

For nI := 1 To Len(aProdutos)
	cLocal := aProdutos[nI,nPosLocal] //PHSM -> Tratar tamanho do campo código para manter o padrão mesmo quando receber sem os espaços
	//Monta query para processamento dos dados com base na SB2 agrupado/totalizado por Produto, caso não seja enviado o armazém, o produto será totalizado em todos os armazens
	cQuery := " SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_UM, SB2.B2_FILIAL, SB2.B2_COD, SUM(SB2.B2_QATU) B2_QATU, SUM(SB2.B2_RESERVA) B2_RESERVA, SUM(SB2.B2_SALPEDI) B2_SALPEDI, SUM(SB2.B2_CM1) B2_CM1, SUM(SB2.B2_VATU1) B2_VATU1, SUM(SB2.B2_QACLASS) B2_QACLASS, SUM(SB2.B2_QPEDVEN) B2_QPEDVEN, SUM(SB2.B2_QEMP) B2_QEMP "
	cQuery += " FROM " + RetSqlName("SB2") + " SB2 INNER JOIN " + RetSqlName("SB1") + " SB1 ON ( B1_FILIAL = '"+ FWxFilial( "SB1" ) +"' AND B2_FILIAL  = '" + FWxFilial("SB2") + "' AND B1_COD = B2_COD ) "
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' AND SB2.D_E_L_E_T_ = ' ' "
	
	If !Empty(aProdutos[nI,nPosProd])
		cQuery += " AND SB2.B2_COD = '"+aProdutos[nI,nPosProd]+"' "
	EndIf
	
	cQuery += " GROUP BY SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_UM, SB2.B2_FILIAL, SB2.B2_COD "
	
	cQuery := ChangeQuery(cQuery)
	cAliasBase := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBase,.T.,.T.)
	While (cAliasBase)->(!Eof())
		aInfTotais		:= {}
		aInfWareHouse	:= {}
		aInfLot			:= {}
		aInfAddress		:= {}
		ainfSeries		:= {}
		nTotDispo		:= 0

		aInfTotais := {	AllTrim(cValToChar((cAliasBase)->B2_QATU)), ;								//01-CurrentStockAmount
						AllTrim(cValToChar(0)), ;													//02-AvailableStockAmount -> Saldo disponível, valor(nTotDispo) será totalizado após a totalização do saldo por armazem. Motivo: rotina SaldoSB2() retorna o saldo do registro posicionado
						AllTrim(cValToChar((cAliasBase)->B2_RESERVA)),;								//03-BookedStockAmount
						AllTrim(cValToChar(MTSldTrFil((cAliasBase)->B2_COD)[1])),;					//04-TransitStockAmount
						AllTrim(cValToChar((cAliasBase)->B2_SALPEDI+(cAliasBase)->B2_QACLASS)),;	//05-FutureStockAmount
						AllTrim(cValToChar((cAliasBase)->B2_CM1)),;									//06-UnitItemCost
						AllTrim(cValToChar((cAliasBase)->B2_VATU1)),;								//07-AverageUnitItemCost
						AllTrim(cValToChar((cAliasBase)->B2_VATU1)),;								//08-ValueOfCurrentStockAmount
						AllTrim(cValToChar((cAliasBase)->B2_QPEDVEN - MIN(nTotDispo, (cAliasBase)->B2_QPEDVEN))),; //09-RequestStockAmount -> Saldo encomenda
						AllTrim(cValToChar((cAliasBase)->B2_QEMP    )),; //10-Amountcommittedstock -> Quantidade epenhada  
						AllTrim(cValToChar((cAliasBase)->B2_QPEDVEN )),; //11-SalesOrderQuantity -> Quantidade em pedido de vendas
						AllTrim(cValToChar(cEmpAnt + "|" + RTrim(xFilial("SAH")) + "|" + RTrim((cAliasBase)->B1_UM) ))} //12-UnitofMeasureInternalId

		//********** ListOfWarehouseStock **********//
		//Insere dados agrupados por Armazem, quando possui filtro por armazem e produto, os valores serão os mesmos que os apresentados dentro de aInfTotais, sendo assim não faz query
		If Empty(aProdutos[nI,nPosLocal]) .OR. Empty(aProdutos[nI,nPosProd])
			cQuery := " SELECT SB2.B2_FILIAL, SB2.B2_COD, SB2.B2_LOCAL, SUM(SB2.B2_QATU) B2_QATU, SUM(SB2.B2_RESERVA) B2_RESERVA, SUM(SB2.B2_SALPEDI) B2_SALPEDI, SUM(SB2.B2_CM1) B2_CM1, SUM(SB2.B2_VATU1) B2_VATU1, SUM(SB2.B2_QPEDVEN) B2_QPEDVEN, SUM(SB2.B2_QEMP) B2_QEMP "
			cQuery += " FROM " + RetSqlName("SB2") + " SB2 "
			cQuery += " WHERE SB2.B2_FILIAL  = '" + xFilial("SB2") + "' "
			cQuery += " AND SB2.B2_COD = '"+(cAliasBase)->B2_COD+"' "
			cQuery += " AND SB2.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY SB2.B2_FILIAL, SB2.B2_COD, SB2.B2_LOCAL "

			cQuery := ChangeQuery(cQuery)
			cAliasSB2 := GetNextAlias()

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB2,.T.,.T.)
			While (cAliasSB2)->(!Eof())
				If SB2->(dbSeek(xFilial("SB2") + (cAliasSB2)->B2_COD + (cAliasSB2)->B2_LOCAL))	//posiciona SB2 para calculo de estoque disponível pela rotina SaldoSB2()
					nSldDispo := SaldoSB2()
					nTotDispo += nSldDispo
					aAdd(aInfWareHouse,{AllTrim(cValToChar((cAliasSB2)->B2_QATU)), ;			//01-CurrentStockAmount
										AllTrim(cValToChar(nSldDispo)),;						//02-AvailableStockAmount
										AllTrim(cValToChar((cAliasSB2)->B2_RESERVA)),;			//03-BookedStockAmount
										AllTrim(cValToChar(MTSldTrFil((cAliasBase)->B2_COD)[1])),; //04-TransitStockAmount
										AllTrim(cValToChar((cAliasSB2)->B2_SALPEDI)),;			//05-FutureStockAmount
										IntLocExt(/*Empresa*/, /*Filial*/, (cAliasSB2)->B2_LOCAL, /*Versão*/)[2],; //06-WarehouseInternalId
										AllTrim(cValToChar((cAliasSB2)->B2_CM1)),;				//07-UnitItemCost
										AllTrim(cValToChar((cAliasSB2)->B2_VATU1)),;			//08-AverageUnitItemCost
										AllTrim(cValToChar((cAliasSB2)->B2_VATU1)),;			//09-ValueOfCurrentStockAmount
										AllTrim(cValToChar((cAliasSB2)->B2_QPEDVEN - MIN(nSldDispo, (cAliasSB2)->B2_QPEDVEN))),;//10-RequestStockAmount
										AllTrim(cValToChar((cAliasBase)->B2_QEMP    )),; //11-Amountcommittedstock -> Quantidade epenhada  
										AllTrim(cValToChar((cAliasBase)->B2_QPEDVEN ))}) //12-SalesOrderQuantity -> Quantidade em pedido de vendas
				EndIf

				(cAliasSB2)->(dbSkip())
			EndDo
			(cAliasSB2)->(dbCloseArea())
		Else
				cLocInt := IntLocExt(/*Empresa*/, /*Filial*/, cLocal, /*Versão*/)[2]

				DbSelectArea("SB2")
				SB2->(dbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
				If SB2->(dbSeek(xFilial("SB2") + (cAliasBase)->B2_COD + cLocal ))	//posiciona SB2 para calculo de estoque disponível pela rotina SaldoSB2()
					nSldDispo := SaldoSB2()
					nTotDispo += nSldDispo
				EndIf

				aAdd(aInfWareHouse,{AllTrim(cValToChar((cAliasBase)->B2_QATU)), ;				//01-CurrentStockAmount
									AllTrim(cValToChar(nSldDispo)),;							//02-AvailableStockAmount
									AllTrim(cValToChar((cAliasBase)->B2_RESERVA)),;				//03-BookedStockAmount
									AllTrim(cValToChar(MTSldTrFil((cAliasBase)->B2_COD)[1])),;	//04-TransitStockAmount
									AllTrim(cValToChar((cAliasBase)->B2_SALPEDI)),;				//05-FutureStockAmount
									cLocInt,; 													//06-WarehouseInternalId
									AllTrim(cValToChar((cAliasBase)->B2_CM1)),;					//07-UnitItemCost
									AllTrim(cValToChar((cAliasBase)->B2_VATU1)),;				//08-AverageUnitItemCost
									AllTrim(cValToChar((cAliasBase)->B2_VATU1)),;				//09-ValueOfCurrentStockAmount
									AllTrim(cValToChar((cAliasBase)->B2_QPEDVEN - MIN(nSldDispo, (cAliasBase)->B2_QPEDVEN))),;//10-RequestStockAmount
									AllTrim(cValToChar((cAliasBase)->B2_QEMP    )),; //11-Amountcommittedstock -> Quantidade epenhada  
									AllTrim(cValToChar((cAliasBase)->B2_QPEDVEN ))}) //12-SalesOrderQuantity -> Quantidade em pedido de vendas
		EndIf

		//02-AvailableStockAmount -> Atualiza Saldo disponível após calcular saldo de cada armazem
		aInfTotais[02] := AllTrim(cValToChar(nTotDispo))

		//********** ListOfLotStock **********//
		cQuery := " SELECT SB8.B8_FILIAL, SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_LOTECTL, SB8.B8_NUMLOTE, SB8.B8_DTVALID, SB8.B8_SALDO, SB8.B8_EMPENHO "
		cQuery += " FROM " + RetSqlName("SB8") + " SB8 "
		cQuery += " WHERE SB8.B8_FILIAL  = '" + xFilial("SB8") + "' "
		cQuery += " AND SB8.B8_PRODUTO = '"+(cAliasBase)->B2_COD+"' "
		cQuery += " AND SB8.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		cAliasSB8 := GetNextAlias()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB8,.T.,.T.)
		While (cAliasSB8)->(!Eof())
			cLocInt := IntLocExt(/*Empresa*/, /*Filial*/, (cAliasSB8)->B8_LOCAL, /*Versão*/)[2]
			aAdd(aInfLot,{	AllTrim(cValToChar((cAliasSB8)->B8_SALDO)), ;							//01-CurrentStockAmount
							AllTrim(cValToChar((cAliasSB8)->B8_SALDO - (cAliasSB8)->B8_EMPENHO )),;	//02-AvailableStockAmount
							AllTrim(cValToChar((cAliasSB8)->B8_EMPENHO)),;							//03-BookedStockAmount
							cLocInt,;																//04-WarehouseInternalId
							AllTrim((cAliasSB8)->B8_LOTECTL),;										//05-LotNumber
							AllTrim((cAliasSB8)->B8_NUMLOTE),;										//06-SubLotCode
							Transform((cAliasSB8)->B8_DTVALID,"@R 9999-99-99")})					//07-LotExpirationDate
			(cAliasSB8)->(dbSkip())
		EndDo
		(cAliasSB8)->(dbCloseArea())

		//********** ListOfAddressStock **********//
		cQuery := " SELECT SBF.BF_FILIAL, SBF.BF_PRODUTO, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_LOTECTL, SBF.BF_NUMLOTE, Sum(SBF.BF_QUANT) BF_QUANT, Sum(SBF.BF_EMPENHO) BF_EMPENHO "
		cQuery += " FROM " + RetSqlName("SBF") + " SBF "
		cQuery += " WHERE SBF.BF_FILIAL  = '" + xFilial("SBF") + "' "
		cQuery += " AND SBF.BF_PRODUTO = '"+(cAliasBase)->B2_COD+"' "
		cQuery += " AND SBF.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY SBF.BF_FILIAL, SBF.BF_PRODUTO, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_LOTECTL, SBF.BF_NUMLOTE "
		cQuery := ChangeQuery(cQuery)
		cAliasSBF := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBF,.T.,.T.)
		While (cAliasSBF)->(!Eof())
			cLocInt := IntLocExt(/*Empresa*/, /*Filial*/, (cAliasSBF)->BF_LOCAL, /*Versão*/)[2]
			aAdd(aInfAddress,{	AllTrim(cValToChar((cAliasSBF)->BF_QUANT)), ;							//CurrentStockAmount
								AllTrim(cValToChar((cAliasSBF)->BF_QUANT - (cAliasSBF)->BF_EMPENHO )),;	//AvailableStockAmount
								AllTrim(cValToChar((cAliasSBF)->BF_EMPENHO)),;							//BookedStockAmount
								cLocInt,;																//WarehouseInternalId
								AllTrim((cAliasSBF)->BF_LOCALIZ),;										//Address
								AllTrim((cAliasSBF)->BF_LOTECTL),;										//LotNumber
								AllTrim((cAliasSBF)->BF_NUMLOTE)}) 										//SubLotCode
			(cAliasSBF)->(dbSkip())
		EndDo
		(cAliasSBF)->(dbCloseArea())

		//********** ListOfSeriesStock **********//
		cQuery := " SELECT SBF.BF_FILIAL, SBF.BF_PRODUTO, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_NUMSERI, SBF.BF_LOTECTL, SBF.BF_NUMLOTE, SBF.BF_QUANT, SBF.BF_EMPENHO "
		cQuery += " FROM " + RetSqlName("SBF") + " SBF "
		cQuery += " WHERE SBF.BF_FILIAL  = '" + xFilial("SBF") + "' "
		cQuery += " AND SBF.BF_PRODUTO = '"+(cAliasBase)->B2_COD+"' "
		cQuery += " AND SBF.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		cAliasSBF := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBF,.T.,.T.)
		While (cAliasSBF)->(!Eof())
			cLocInt := IntLocExt(/*Empresa*/, /*Filial*/, (cAliasSBF)->BF_LOCAL, /*Versão*/)[2]
			aAdd(ainfSeries,{	AllTrim(cValToChar((cAliasSBF)->BF_QUANT)), ;							//CurrentStockAmount
								AllTrim(cValToChar((cAliasSBF)->BF_QUANT - (cAliasSBF)->BF_EMPENHO )),;	//AvailableStockAmount
								AllTrim(cValToChar((cAliasSBF)->BF_EMPENHO)),;							//BookedStockAmount
								cLocInt,;																//WarehouseInternalId
								AllTrim((cAliasSBF)->BF_LOCALIZ),;										//Address
								AllTrim((cAliasSBF)->BF_LOTECTL),;										//LotNumber
								AllTrim((cAliasSBF)->BF_NUMLOTE),; 										//SubLotCode
								AllTrim((cAliasSBF)->BF_NUMSERI)}) 										//SerialNumber
			(cAliasSBF)->(dbSkip())
		EndDo
		(cAliasSBF)->(dbCloseArea())

		//Atualiza Array principal
		aAdd(aInfXml,{ IntProExt(/*cEmpresa*/, (cAliasBase)->B1_FILIAL, (cAliasBase)->B1_COD, /*cVersao*/)[2] ,aInfTotais,aInfWareHouse,aInfLot,aInfAddress,ainfSeries,C0Origem((cAliasBase)->B1_FILIAL,(cAliasBase)->B1_COD)})
		(cAliasBase)->(dbSkip())
	EndDo
	(cAliasBase)->(dbCloseArea())
Next nI

If Len(aInfXml) < 1
	 Return {.F., STR0013} // "Saldo não encontrado."
EndIf

GeraSaida(@cXMLRet, @ofwEAIObj , lEAIObj, aInfXml, cEvento, cTypeTrans,cVersion)

If !lEAIObj
	aRet := {.T.,cXMLRet}
Else
	aRet := {.T.,ofwEAIObj}
EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraSaida
Gera a mensagem de saída

@param		cXMLRet XML de Retorno
@param		ofwEAIObj Objeto EAI
@param		lEAIObj É mensagem EAI?
@param		aInfXml - Dados do XML de Estoque
@param		cEvento - Evento
@param 		cTypeTrans - Tipo da transação

@author	fabiana.silva
@since		03/09/2018
@version	P12.17
/*/
//-------------------------------------------------------------------
Static Function GeraSaida(	cXMLRet, ofwEAIObj , lEAIObj, aInfXml, ;
							cEvento, cTypeTrans,cVersion)
Local nX := 0 //Contador
Local nI := 0 //Contador

Default cXMLRet    := ""
Default lEAIObj    := .F.
Default aInfXml    := {}
Default cEvento    := "UPSERT"
Default cTypeTrans := ""
Default cVersion   := ""

If !lEAIObj

	If cTypeTrans == TRANS_SEND
		cXMLRet += '<BusinessEvent>'
		cXMLRet +=    '<Entity>StockLevel</Entity>'
		cXMLRet +=    '<Event>' + cEvento + '</Event>'
		cXMLRet +=    '<Identification>'
		cXMLRet +=       '<key name="InternalID">' + cEmpAnt + "|" + cFilAnt + '</key>'
		cXMLRet +=    '</Identification>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
	EndIf
	cXMLRet += '<ListOfReturnItem>'
	For nI := 1 To Len(aInfXml)

		cXMLRet  += '<ReturnItem>'

			cXMLRet  +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
			cXMLRet  +=    '<BranchId>' + cFilAnt + '</BranchId>'
			cXMLRet  +=    '<CompanyInternalId>' + cEmpAnt + "|" + cFilAnt + '</CompanyInternalId>'
			cXMLRet  +=    '<ItemInternalId>' + aInfXml[nI,1] + '</ItemInternalId>'

			//Totalizadores por produto
			cXMLRet  +=    '<CurrentStockAmount>' 	+ aInfXml[nI,02,01] + '</CurrentStockAmount>'
			cXMLRet  +=    '<AvailableStockAmount>' + aInfXml[nI,02,02] + '</AvailableStockAmount>'
			cXMLRet  +=    '<BookedStockAmount>' 	+ aInfXml[nI,02,03] + '</BookedStockAmount>'
			cXMLRet  +=    '<TransitStockAmount>' 	+ aInfXml[nI,02,04] + '</TransitStockAmount>'
			cXMLRet  +=    '<FutureStockAmount>' 	+ aInfXml[nI,02,05] + '</FutureStockAmount>'
			
			cXMLRet  +=    '<UnitItemCost>' 		+ aInfXml[nI,02,06] + '</UnitItemCost>'
			cXMLRet  +=    '<AverageUnitItemCost>' 	+ aInfXml[nI,02,07] +	'</AverageUnitItemCost>'
			cXMLRet  +=    '<ValueOfCurrentStockAmount>' + aInfXml[nI,02,08] + '</ValueOfCurrentStockAmount>'
			cXMLRet  +=    '<Amountcommittedstock>' + aInfXml[nI,02,10] + '</Amountcommittedstock>'
			cXMLRet  +=    '<SalesOrderQuantity>' + aInfXml[nI,02,11] + '</SalesOrderQuantity>'
			cXMLRet  +=    '<UnitOfMeasureInternalId>' + aInfXml[nI,02,12] + '</UnitOfMeasureInternalId>'
			cXMLRet  +=    '<ReserveSource>' 		+ aInfXml[nI,07] + '</ReserveSource>'

			//Totalizadores por Armazem(WareHouse)
			cXmlRet  +=    '<ListOfWarehouseStock>'
			For nX := 1 To Len(aInfXml[nI,3])
				cXmlRet  +=		'<WarehouseStock>'
				cXMLRet  +=			'<WarehouseInternalId>'		+ aInfXml[nI,03,nX,06] + 	'</WarehouseInternalId>'
				cXMLRet  +=			'<CurrentStockAmount>'		+ aInfXml[nI,03,nX,01] +	'</CurrentStockAmount>'
				cXMLRet  +=			'<AvailableStockAmount>'	+ aInfXml[nI,03,nX,02] +	'</AvailableStockAmount>'
				cXMLRet  +=			'<BookedStockAmount>'		+ aInfXml[nI,03,nX,03] +	'</BookedStockAmount>'
				cXMLRet  +=			'<TransitStockAmount>'		+ aInfXml[nI,03,nX,04] +	'</TransitStockAmount>'
				cXMLRet  +=			'<FutureStockAmount>'		+ aInfXml[nI,03,nX,05] +	'</FutureStockAmount>'
				cXMLRet  +=    		'<UnitItemCost>' 			+ aInfXml[nI,03,nX,07] + 	'</UnitItemCost>'
				cXMLRet  +=    		'<AverageUnitItemCost>' 	+ aInfXml[nI,03,nX,08] + 	'</AverageUnitItemCost>'
				cXMLRet  +=    		'<ValueOfCurrentStockAmount>' + aInfXml[nI,03,nX,09] + '</ValueOfCurrentStockAmount>'
				cXMLRet  +=         '<Amountcommittedstock>'      + aInfXml[nI,03,nX,11] + '</Amountcommittedstock>'
				cXMLRet  +=         '<SalesOrderQuantity>'        + aInfXml[nI,03,nX,12] + '</SalesOrderQuantity>'
				cXmlRet  +=		'</WarehouseStock>'
			Next nX
			cXmlRet  +=    '</ListOfWarehouseStock>'

			//Totalizadores por Lote(Lot)
			cXmlRet  +=    '<ListOfLotStock>'
			For nX := 1 To Len(aInfXml[nI,4])
				cXmlRet  +=		'<LotStock>'
				cXMLRet  +=			'<WarehouseInternalId>'		+ aInfXml[nI,04,nX,04] + 	'</WarehouseInternalId>'
				cXMLRet  +=			'<LotNumber>'				+ aInfXml[nI,04,nX,05] + 	'</LotNumber>'
				cXMLRet  +=			'<SubLotCode>'				+ aInfXml[nI,04,nX,06] + 	'</SubLotCode>'
				cXMLRet  +=			'<LotExpirationDate>'		+ aInfXml[nI,04,nX,07] + 	'</LotExpirationDate>'
				cXMLRet  +=			'<CurrentStockAmount>'		+ aInfXml[nI,04,nX,01] +	'</CurrentStockAmount>'
				cXMLRet  +=			'<AvailableStockAmount>'	+ aInfXml[nI,04,nX,02] +	'</AvailableStockAmount>'
				cXMLRet  +=			'<BookedStockAmount>'		+ aInfXml[nI,04,nX,03] +	'</BookedStockAmount>'
				cXmlRet  +=		'</LotStock>'
			Next nX
			cXmlRet  +=    '</ListOfLotStock>'

			//Totalizadores por Endereço(Address)
			cXmlRet  +=    '<ListOfAddressStock>'
			For nX := 1 To Len(aInfXml[nI,5])
				cXmlRet  +=		'<AddressStock>'
				cXMLRet  +=			'<WarehouseInternalId>'		+ aInfXml[nI,05,nX,04] + 	'</WarehouseInternalId>'
				cXMLRet  +=			'<Address>'					+ aInfXml[nI,05,nX,05] + 	'</Address>'
				cXMLRet  +=			'<LotNumber>'				+ aInfXml[nI,05,nX,06] + 	'</LotNumber>'
				cXMLRet  +=			'<SubLotCode>'				+ aInfXml[nI,05,nX,07] + 	'</SubLotCode>'
				cXMLRet  +=			'<CurrentStockAmount>'		+ aInfXml[nI,05,nX,01] +	'</CurrentStockAmount>'
				cXMLRet  +=			'<AvailableStockAmount>'	+ aInfXml[nI,05,nX,02] +	'</AvailableStockAmount>'
				cXMLRet  +=			'<BookedStockAmount>'		+ aInfXml[nI,05,nX,03] +	'</BookedStockAmount>'
				cXmlRet  +=		'</AddressStock>'
			Next nX
			cXmlRet  +=    '</ListOfAddressStock>'

			//Totalizadores por Serial(SerialNumber)
			cXmlRet  +=    '<ListOfSeriesStock>'
			For nX := 1 To Len(aInfXml[nI,6])
				cXmlRet  +=		'<SeriesStock>'
				cXMLRet  +=			'<WarehouseInternalId>'		+ aInfXml[nI,06,nX,04] + 	'</WarehouseInternalId>'
				cXMLRet  +=			'<Address>'					+ aInfXml[nI,06,nX,05] + 	'</Address>'
				cXMLRet  +=			'<LotNumber>'				+ aInfXml[nI,06,nX,06] + 	'</LotNumber>'
				cXMLRet  +=			'<SubLotCode>'				+ aInfXml[nI,06,nX,07] + 	'</SubLotCode>'
				cXMLRet  +=			'<SerialNumber>'			+ aInfXml[nI,06,nX,08] + 	'</SerialNumber>'
				cXMLRet  +=			'<CurrentStockAmount>'		+ aInfXml[nI,06,nX,01] +	'</CurrentStockAmount>'
				cXMLRet  +=			'<AvailableStockAmount>'	+ aInfXml[nI,06,nX,02] +	'</AvailableStockAmount>'
				cXMLRet  +=			'<BookedStockAmount>'		+ aInfXml[nI,06,nX,03] +	'</BookedStockAmount>'
				cXmlRet  +=		'</SeriesStock>'
			Next nX
			cXmlRet  +=    '</ListOfSeriesStock>'
		cXMLRet  += '</ReturnItem>'
	Next nI
	cXMLRet += '</ListOfReturnItem>'
	
	If cTypeTrans == TRANS_SEND
		cXMLRet += '</BusinessContent>'
	EndIf

Else
	If cVersion >= "3.004"
		MsgJsonNew(aInfXml,cTypeTrans,cEvento,ofwEAIObj)
	Else
		MsgJsonOld(aInfXml,cTypeTrans,cEvento,ofwEAIObj)
	EndIf
EndIf

Return

Static Function C0Origem(cFil,cProd)

Local cQuery	:= ""
Local cTemp		:= GetNextAlias()
Local cOrigem	:= ""
Local lProd		:= ""
Local lOri		:= "" 

Default cFil	:= ""
Default cProd	:= ""

dbSelectArea('SC0')
SC0->(dbSetOrder(2))
lProd		:= SC0->(dbSeek(xFilial("SC0")+cProd))
lOri		:= FieldPos("C0_ORIGEM") > 0 

If lOri .And. lProd 
	If !Empty(cFil)
		cQuery := " SELECT C0_ORIGEM ORIGEM FROM " + RetSqlName("SC0") + " SC0 "
		cQuery += " WHERE  SC0.C0_FILIAL IN ('" + cFil + "') AND  SC0.C0_PRODUTO = '" + cProd + "' AND "
		cQuery += " SC0.D_E_L_E_T_ = ' '  "
	Else
		cQuery := " SELECT C0_ORIGEM ORIGEM FROM " + RetSqlName("SC0") + " SC0 "
		cQuery += " WHERE  SC0.C0_FILIAL IN ('" + xFilial("SC0") + "') AND  SC0.C0_PRODUTO = '" + cProd + "' AND "
		cQuery += " SC0.D_E_L_E_T_ = ' '  "
	EndIf

	MPSysOpenQuery(cQuery,cTemp)

	While (cTemp)->(!Eof())
		cOrigem := (cTemp)->ORIGEM
		(cTemp)->(dbSkip())
	EndDo

	(cTemp)->(dbCloseArea())
Else
	cOrigem := " "
EndIf

SC0->(dbCloseArea())

Return cOrigem

/*/{Protheus.doc} MsgJsonOld
	Funcao responsavel por montar a mensagem de saída no formato JSON 
	para os clientes que utilizam a sessaao da tag "ReturnItem"
	@type  Function
	@author Squad Entradas
	@since 03/06/2022
	@version 3.003
	@param itens, tipo transacao, evento, objeto JsonEAI
	@return 
	/*/
Static Function MsgJsonOld(aInfJson,cTypeTrans,cEvento,ofwEAIObj)

Local nX := 0 //Contador
Local nI := 0 //Contador

Default lEAIObj    := .F.
Default aInfJson   := {}
Default cEvento    := "UPSERT"
Default cTypeTrans := ""

ofwEAIObj:Activate()

	If cTypeTrans == TRANS_SEND
	   	ofwEAIObj:setEvent(cEvento)
		ofwEAIObj:setProp("Entity"           		,'StockLevel')
		ofwEAIObj:setProp("Event"            		,cEvento)
		ofwEAIObj:setProp("CompanyId"        		,cEmpAnt)
		ofwEAIObj:setProp("BranchId"         		,cFilAnt)
		ofwEAIObj:setProp("CompanyinternalId"		,cEmpAnt + '|' + cFilAnt )
		ofwEAIObj:setProp("Active"		    		,'true'  )

	ENDIF

	ofwEAIObj:SetProp("ListOfReturnItem")

	For nI := 1 To Len(aInfJson)
		ofwEAIObj:SetProp("ListOfReturnItem", {})
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ReturnItem")

			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("CompanyId", cEmpAnt)
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("BranchId", cFilAnt)
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("CompanyInternalId",  cEmpAnt + "|" + cFilAnt )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ItemInternalId", aInfJson[nI,1] )

			//Totalizadores por produto
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("CurrentStockAmount",  aInfJson[nI,02,01])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("AvailableStockAmount", aInfJson[nI,02,02] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("BookedStockAmount", aInfJson[nI,02,03] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("TransitStockAmount", aInfJson[nI,02,04] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("FutureStockAmount", aInfJson[nI,02,05] )


			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("UnitItemCost", aInfJson[nI,02,06] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("AverageUnitItemCost", aInfJson[nI,02,07] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ValueOfCurrentStockAmount", aInfJson[nI,02,08])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ReserveSource", aInfJson[nI,07])

			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("Amountcommittedstock", aInfJson[nI,02,10])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("SalesOrderQuantity", aInfJson[nI,02,11])
			//Totalizadores por armazém (WareHouse)
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ListOfWarehouseStock")
			For nX := 1 To Len(aInfJson[nI,3])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ListOfWarehouseStock", {})
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:SetProp("WarehouseStock")
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("WarehouseInternalId",aInfJson[nI,03,nX,06])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("CurrentStockAmount",aInfJson[nI,03,nX,01])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("AvailableStockAmount",aInfJson[nI,03,nX,02])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("BookedStockAmount",aInfJson[nI,03,nX,03])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("TransitStockAmount",aInfJson[nI,03,nX,04])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("FutureStockAmount",aInfJson[nI,03,nX,05])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("UnitItemCost",aInfJson[nI,03,nX,07] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("AverageUnitItemCost",aInfJson[nI,03,nX,08])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("ValueOfCurrentStockAmount",aInfJson[nI,03,nX,09] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("Amountcommittedstock",aInfJson[nI,03,nX,11] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfWarehouseStock")[nX]:Get("WarehouseStock"):SetProp("SalesOrderQuantity",aInfJson[nI,03,nX,12] )
			Next nX
			//Totalizadores por armazém (WareHouse - final)

			//Totalizadores por lote (Lot)
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ListOfLotStock")
			For nX := 1 To Len(aInfJson[nI,4])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ListOfLotStock", {})
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfLotStock")[nX]:SetProp("LotStock")
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfLotStock")[nX]:Get("LotStock"):SetProp("WarehouseInternalId",aInfJson[nI,04,nX,04])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfLotStock")[nX]:Get("LotStock"):SetProp("LotNumber",aInfJson[nI,04,nX,05] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfLotStock")[nX]:Get("LotStock"):SetProp("SubLotCode",aInfJson[nI,04,nX,06])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfLotStock")[nX]:Get("LotStock"):SetProp("LotExpirationDate",aInfJson[nI,04,nX,07])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfLotStock")[nX]:Get("LotStock"):SetProp("CurrentStockAmount",aInfJson[nI,04,nX,01] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfLotStock")[nX]:Get("LotStock"):SetProp("AvailableStockAmount",aInfJson[nI,04,nX,02])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfLotStock")[nX]:Get("LotStock"):SetProp("BookedStockAmount",aInfJson[nI,04,nX,03])
			Next nX
			//Totalizadores por lote (Lot - final)

			//Totalizadores por endereço (Address)
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ListOfAddressStock")
			For nX := 1 To Len(aInfJson[nI,5])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ListOfAddressStock", {})
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfAddressStock")[nX]:SetProp("AddressStock")
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfAddressStock")[nX]:Get("AddressStock"):SetProp("WarehouseInternalId",aInfJson[nI,05,nX,04])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfAddressStock")[nX]:Get("AddressStock"):SetProp("Address",aInfJson[nI,05,nX,05] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfAddressStock")[nX]:Get("AddressStock"):SetProp("LotNumber",aInfJson[nI,05,nX,06])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfAddressStock")[nX]:Get("AddressStock"):SetProp("SubLotCode",aInfJson[nI,05,nX,07])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfAddressStock")[nX]:Get("AddressStock"):SetProp("urrentStockAmount",aInfJson[nI,05,nX,01])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfAddressStock")[nX]:Get("AddressStock"):SetProp("AvailableStockAmount",aInfJson[nI,05,nX,02])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfAddressStock")[nX]:Get("AddressStock"):SetProp("BookedStockAmount",aInfJson[nI,05,nX,03] )
			Next nX
			//Totalizadores por endereço (Address - final)

			//Totalizadores por serial (SerialNumber)
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ListOfSeriesStock")
			//cXmlRet  +=    '<ListOfSeriesStock>'
			For nX := 1 To Len(aInfJson[nI,6])
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):SetProp("ListOfSeriesStock", {})
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfSeriesStock")[nX]:SetProp("SeriesStock")
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfSeriesStock")[nX]:Get("SeriesStock"):SetProp("WarehouseInternalId",aInfJson[nI,06,nX,04] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfSeriesStock")[nX]:Get("SeriesStock"):SetProp("Address",aInfJson[nI,06,nX,05]  )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfSeriesStock")[nX]:Get("SeriesStock"):SetProp("LotNumber",aInfJson[nI,06,nX,06] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfSeriesStock")[nX]:Get("SeriesStock"):SetProp("SubLotCode",aInfJson[nI,06,nX,07]  )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfSeriesStock")[nX]:Get("SeriesStock"):SetProp("SerialNumber",aInfJson[nI,06,nX,08] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfSeriesStock")[nX]:Get("SeriesStock"):SetProp("CurrentStockAmount",aInfJson[nI,06,nX,01] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfSeriesStock")[nX]:Get("SeriesStock"):SetProp("AvailableStockAmount",aInfJson[nI,06,nX,02] )
				ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ReturnItem"):Get("ListOfSeriesStock")[nX]:Get("SeriesStock"):SetProp("BookedStockAmount",aInfJson[nI,06,nX,03] )
			Next nX
			//Totalizadores por serial (SerialNumber - final)
	Next nI

Return

/*/{Protheus.doc} MsgJsonNew
	Funcao responsavel por montar a mensagem de saída no formato JSON 
	para os clientes que utilizam a sessaao da tag "ReturnItem"
	@type  Function
	@author Squad Entradas
	@since 03/06/2022
	@version 3.004
	@param itens, tipo transacao, evento, objeto JsonEAI
	@description Para utilizar a nova estrutura é necessario cadastrar no Adapter a versao 3.004
	@return 
	/*/
Static Function MsgJsonNew(aInfJson,cTypeTrans,cEvento,ofwEAIObj)

Local nX := 0 //Contador
Local nI := 0 //Contador

Default lEAIObj    := .F.
Default aInfJson   := {}
Default cEvento    := "UPSERT"
Default cTypeTrans := ""

ofwEAIObj:Activate()

	If cTypeTrans == TRANS_SEND
	   	ofwEAIObj:setEvent(cEvento)
		ofwEAIObj:setProp("Entity"           		,'StockLevel')
		ofwEAIObj:setProp("Event"            		,cEvento)
		ofwEAIObj:setProp("CompanyId"        		,cEmpAnt)
		ofwEAIObj:setProp("BranchId"         		,cFilAnt)
		ofwEAIObj:setProp("CompanyinternalId"		,cEmpAnt + '|' + cFilAnt )
		ofwEAIObj:setProp("Active"		    		,'true'  )

	ENDIF

	ofwEAIObj:SetProp("ListOfReturnItem")

	For nI := 1 To Len(aInfJson)
		ofwEAIObj:SetProp("ListOfReturnItem", {})

		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("CompanyId", cEmpAnt)
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("BranchId", cFilAnt)
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("CompanyInternalId",  cEmpAnt + "|" + cFilAnt )
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ItemInternalId", aInfJson[nI,1] )

		//Totalizadores por produto
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("CurrentStockAmount",  aInfJson[nI,02,01])
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("AvailableStockAmount", aInfJson[nI,02,02] )
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("BookedStockAmount", aInfJson[nI,02,03] )
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("TransitStockAmount", aInfJson[nI,02,04] )
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("FutureStockAmount", aInfJson[nI,02,05] )

		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("UnitItemCost", aInfJson[nI,02,06] )
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("AverageUnitItemCost", aInfJson[nI,02,07] )
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ValueOfCurrentStockAmount", aInfJson[nI,02,08])
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ReserveSource", aInfJson[nI,07])

		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("Amountcommittedstock", aInfJson[nI,02,10])
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("SalesOrderQuantity", aInfJson[nI,02,11])
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("UnitOfMeasureInternalId", aInfJson[nI,02,12])

		//Totalizadores por armazém (WareHouse)
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ListOfWarehouseStock")
		For nX := 1 To Len(aInfJson[nI,3])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ListOfWarehouseStock", {})
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("WarehouseInternalId",aInfJson[nI,03,nX,06])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("CurrentStockAmount",aInfJson[nI,03,nX,01])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("AvailableStockAmount",aInfJson[nI,03,nX,02])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("BookedStockAmount",aInfJson[nI,03,nX,03])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("TransitStockAmount",aInfJson[nI,03,nX,04])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("FutureStockAmount",aInfJson[nI,03,nX,05])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("UnitItemCost",aInfJson[nI,03,nX,07] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("AverageUnitItemCost",aInfJson[nI,03,nX,08])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("ValueOfCurrentStockAmount",aInfJson[nI,03,nX,09] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("Amountcommittedstock",aInfJson[nI,03,nX,11] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfWarehouseStock")[nX]:SetProp("SalesOrderQuantity",aInfJson[nI,03,nX,12] )
		Next nX
		//Totalizadores por armazém (WareHouse - final)

		//Totalizadores por lote (Lot)
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ListOfLotStock")
		For nX := 1 To Len(aInfJson[nI,4])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ListOfLotStock", {})
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfLotStock")[nX]:SetProp("WarehouseInternalId",aInfJson[nI,04,nX,04])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfLotStock")[nX]:SetProp("LotNumber",aInfJson[nI,04,nX,05] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfLotStock")[nX]:SetProp("SubLotCode",aInfJson[nI,04,nX,06])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfLotStock")[nX]:SetProp("LotExpirationDate",aInfJson[nI,04,nX,07])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfLotStock")[nX]:SetProp("CurrentStockAmount",aInfJson[nI,04,nX,01] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfLotStock")[nX]:SetProp("AvailableStockAmount",aInfJson[nI,04,nX,02])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfLotStock")[nX]:SetProp("BookedStockAmount",aInfJson[nI,04,nX,03])
		Next nX
		//Totalizadores por lote (Lot - final)

		//Totalizadores por endereço (Address)
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ListOfAddressStock")
		For nX := 1 To Len(aInfJson[nI,5])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ListOfAddressStock", {})
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfAddressStock")[nX]:SetProp("WarehouseInternalId",aInfJson[nI,05,nX,04])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfAddressStock")[nX]:SetProp("Address",aInfJson[nI,05,nX,05] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfAddressStock")[nX]:SetProp("LotNumber",aInfJson[nI,05,nX,06])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfAddressStock")[nX]:SetProp("SubLotCode",aInfJson[nI,05,nX,07])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfAddressStock")[nX]:SetProp("urrentStockAmount",aInfJson[nI,05,nX,01])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfAddressStock")[nX]:SetProp("AvailableStockAmount",aInfJson[nI,05,nX,02])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfAddressStock")[nX]:SetProp("BookedStockAmount",aInfJson[nI,05,nX,03] )
		Next nX
		//Totalizadores por endereço (Address - final)

		//Totalizadores por serial (SerialNumber)
		ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ListOfSeriesStock")
		//cXmlRet  +=    '<ListOfSeriesStock>'
		For nX := 1 To Len(aInfJson[nI,6])
			ofwEAIObj:Get("ListOfReturnItem")[nI]:SetProp("ListOfSeriesStock", {})
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfSeriesStock")[nX]:SetProp("WarehouseInternalId",aInfJson[nI,06,nX,04] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfSeriesStock")[nX]:SetProp("Address",aInfJson[nI,06,nX,05]  )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfSeriesStock")[nX]:SetProp("LotNumber",aInfJson[nI,06,nX,06] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfSeriesStock")[nX]:SetProp("SubLotCode",aInfJson[nI,06,nX,07]  )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfSeriesStock")[nX]:SetProp("SerialNumber",aInfJson[nI,06,nX,08] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfSeriesStock")[nX]:SetProp("CurrentStockAmount",aInfJson[nI,06,nX,01] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfSeriesStock")[nX]:SetProp("AvailableStockAmount",aInfJson[nI,06,nX,02] )
			ofwEAIObj:Get("ListOfReturnItem")[nI]:Get("ListOfSeriesStock")[nX]:SetProp("BookedStockAmount",aInfJson[nI,06,nX,03] )
		Next nX
			//Totalizadores por serial (SerialNumber - final)
	Next nI

Return
