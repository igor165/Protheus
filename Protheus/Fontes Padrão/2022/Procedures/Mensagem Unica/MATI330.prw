#INCLUDE "Protheus.ch"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWLIBVERSION.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI330

Funcao de integracao com o adapter EAI para recebimento dos dados mensagem ItemCosting

@param   cXml        Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans   Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Matheus Lando Raimundo
@version P11
@since   21/04//2014
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
/*/
//-------------------------------------------------------------------------------------------------
Function MATI330(cXML,nTypeTrans,cTypeMessage,cAliasTmp,cVersion, cTransac, lEAIObj)
Local aUnitValues   := {}
Local lRet			:= .T.
Local cXMLRet		:= ""
Local cEvent		:= "upsert"
Local cXmlErro		:= ""
Local cXmlWarn		:= ""
Local aArea			:= GetArea()
Local lPIMSINT 		:= SuperGetMV("MV_PIMSINT",.F.,.F.)// Indica se Existe Integração Protheus x PIMS Graos
Local nCount		:= 0
Local cXMLItem		:= ""
Local lMI330001   	:= ExistBlock("MI330001")
Local uRet          := Nil
Local nApropri      := 3
Local cBatchCost    := ''
Local aMatValue     := {0,0,0,0,0}
Local lPIMSCtSai    := SuperGetMV('MV_PIMSCSA',.F.,.F.) //Indica que será enviado o custo médio das saídas do período
Local dDtDe         := SuperGetMv("MV_ULMES",.F.,SToD("19961231"))+1
Local dDtAte        := dDataBase

Private oXmlM330		:= Nil
//Tratamento do recebimento de mensagens
If ( nTypeTrans == TRANS_RECEIVE )

	If cTypeMessage == EAI_MESSAGE_BUSINESS
	//Negocio Recebimento
	ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
		oXmlM330 := XmlParser(cXml, "_", @cXmlErro, @cXmlWarn)
		If oXmlM330 <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
			If oXmlM330:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text == "ERROR"
				lRet    := .F.
				cXMLRet := 	"Erro no processamento " + ' | ' +cXmlErro + ' | ' + cXmlWarn //""
			EndIf
		Else
			lRet    := .F.
			cXMLRet := 	"Xml mal formatado " + ' | ' +cXmlErro + ' | ' + cXmlWarn //"Xml mal formatado "
		EndIf
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000|1.001'
	EndIf
ElseIf nTypeTrans == TRANS_SEND

	If Type("a330ParamZX") == "A" .And. Len(a330ParamZX) > 14
		nApropri := a330ParamZX[14]
		dDtAte   := a330ParamZX[01]
	Else
		If Empty(MV_PAR14) .Or. Empty(MV_PAR01)
			Pergunte("MTA330",.F.)
		EndIf
		nApropri := MV_PAR14
		dDtAte   := MV_PAR01
	EndIf
	cBatchCost := If(nApropri==3,"1","2")

	If cVersion >= '1.001'
		//BatchCost = 3 disponível somente a partir da 1.001
		cBatchCost := If(lPIMSCtSai .And. nApropri == 2,"3",cBatchCost) //Apropriação mensal
	EndIf

	//Monta XML de envio de mensagem unica
	cXMLRet := "<BusinessEvent>"
	cXMLRet +=		"<Entity>ItemCosting</Entity>"
	cXMLRet +=		"<Event>" +cEvent +"</Event>"
	cXmlRet += 	"<Identification>"
	cXmlRet +=            '<key name="InternalId">' + cEmpAnt + '|' + RTrim(SB1->B1_FILIAL) + '|' +  RTrim((cAliasTmp)->B2_COD)  + '</key>'
	cXmlRet += 	"</Identification>"
	cXmlRet += "</BusinessEvent>"

	cXmlRet += "<BusinessContent>"
	cXmlRet += "  <CompanyId>" + cEmpAnt + "</CompanyId>"
	cXMLRet += "  <CompanyInternal>" + cEmpAnt + "|" + cFilAnt + "</CompanyInternal>"
	cXmlRet += "  <ItemCode>" +  RTrim((cAliasTmp)->B2_COD)  + "</ItemCode>"
	cXmlRet += "  <ItemInternalId>" + cEmpAnt + '|' + RTrim(SB1->B1_FILIAL) + '|' +  RTrim((cAliasTmp)->B2_COD) + "</ItemInternalId>"
	cXmlRet += "  <ItemDescription>" + _NoTags(Rtrim(SB1->B1_DESC)) + "</ItemDescription>"
	cXmlRet += "  <ListOfSites>"

	BeginSQL Alias "ITEMB2"
		SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_LOCALIZ, 
		B2_CMFIM1, B2_CMFIM2, B2_CMFIM3, B2_CMFIM4, B2_CMFIM5
		FROM %Table:SB2% SB2
		WHERE SB2.%NotDel% AND
			SB2.B2_FILIAL = %Exp:(cAliasTmp)->B2_FILIAL% AND
			SB2.B2_COD = %Exp:(cAliasTmp)->B2_COD%
		ORDER BY SB2.B2_LOCAL
	EndSQL

	While ITEMB2->(!EOF())
		nCount := 1
		cXMLItem := "            <SiteItemCosting>"
		cXMLItem += "                  <BranchId>" +RTrim(ITEMB2->B2_FILIAL) + "</BranchId>"
		cXMLItem += "                  <WarehouseCode>" +RTrim(ITEMB2->B2_LOCAL) + "</WarehouseCode> "
		cXMLItem += "                  <WarehouseInternalId>" + cEmpAnt + "|" + RTrim(ITEMB2->B2_FILIAL)+ "|" +RTrim(ITEMB2->B2_LOCAL) +"</WarehouseInternalId> "
		cXMLItem += "                  <WarehouseDescription>" + _NoTags(Rtrim(ITEMB2->B2_LOCALIZ)) +"</WarehouseDescription> "  //-- PEGAR DA NNR

		If !Empty(SB1->B1_UCOM)
			cXMLItem += "                  <LastReceivingPrice>"
	    	cXMLItem += "					  		 <Date>" + Transform(DToS(SB1->B1_UCOM),"@R 9999-99-99") + "</Date>"
	    	cXMLItem += "							 <Price>" + AllTrim(cValToChar(SB1->B1_UPRC)) + "</Price>"
			cXMLItem += "                  </LastReceivingPrice>"
		EndIf

		cXMLItem += "                  <BatchAverageCosting>"
		cXMLItem += "                        <BatchCostingMethod>" + cBatchCost + "</BatchCostingMethod>"
		cXMLItem += "                        <LastUpdate>" + If(lPIMSINT,Transform(DToS(dInicio),"@R 9999-99-99"),Transform(DToS(dDataBase),"@R 9999-99-99")) + "</LastUpdate>"
		cXMLItem += "                        <ListOfBatchAverageCosts>"

		//Se considerar o custo do histórico das saídas
		If cBatchCost == '3'
			aMatValue := CMSaidas(ITEMB2->B2_COD, ITEMB2->B2_LOCAL, dDtDe, dDtAte)
		Else
			aMatValue := {ITEMB2->B2_CMFIM1,;
			              ITEMB2->B2_CMFIM2,;
						  ITEMB2->B2_CMFIM3,;
						  ITEMB2->B2_CMFIM4,;
						  ITEMB2->B2_CMFIM5}
		EndIf

  		For nCount := 1 to 5
			nMatValue := aMatValue[nCount]

			aUnitValues := {ITEMB2->B2_FILIAL, (cAliasTmp)->B2_COD, ITEMB2->B2_LOCAL, cValToChar(nCount), nMatValue, 0, 0}

			If lMI330001		
				uRet := ExecBlock("MI330001",.F.,.F.,{aUnitValues})
				If Valtype(uRet)=="A"
					aUnitValues := uRet
				EndIf
			ENDIF

			cXMLItem += "                        	<UnitValues>"
			cXMLItem += "                             <Sequence>" + aUnitValues[4] + "</Sequence>"
			cXMLItem += "                             <MaterialValue>" + cValToChar(aUnitValues[5]) + "</MaterialValue>"
			cXMLItem += "                             <LaborValue>" + cValToChar(aUnitValues[6]) + "</LaborValue>"
			cXMLItem += "                             <OverHeadValue>" + cValToChar(aUnitValues[7]) + "</OverHeadValue>"
			cXMLItem += "                        	</UnitValues>"

		Next nCount

		cXMLItem += "                        </ListOfBatchAverageCosts>"
		cXMLItem += "                  </BatchAverageCosting>"

		If !Empty(SB1->B1_UCALSTD)
			cXMLItem += "                  <StandardCosting>"
			cXMLItem += "                        <LastUpdate>" + Transform(DToS(SB1->B1_UCALSTD),"@R 9999-99-99")+ "</LastUpdate>"
			cXMLItem += "                        <ListOfStandardCosts>"
			For nCount := 1 to 5
				cXMLItem += "                        	<UnitValues>"
				cXMLItem += "                             <Sequence>" + cValToChar(nCount) + "</Sequence>"
				cXMLItem += "                             <MaterialValue>" + AllTrim(cValToChar(xMoeda(SB1->B1_CUSTD,1,nCount,SB1->B1_UCALSTD))) + "</MaterialValue>"
				cXMLItem += "                             <LaborValue>" + "0" + "</LaborValue>"
				cXMLItem += "                             <OverHeadValue>" + "0" + "</OverHeadValue>"
				cXMLItem += "                        	</UnitValues>"
			Next nCount
			cXMLItem += "                        </ListOfStandardCosts>"
			cXMLItem += "                  </StandardCosting>"
		EndIf

		cXMLItem += "            </SiteItemCosting>"

		cXmlRet += cXMLItem

		ITEMB2->(dbSkip())

	EndDo
	ITEMB2->(dbCloseArea())
	cXmlRet += "  </ListOfSites>"
	cXmlRet += "</BusinessContent>"
EndIf
RestArea(aArea)

Return {lRet,cXMLRet}

Static __oTempTab := Nil
Static __lLibVer  := Nil

/*/{Protheus.doc} CMSaidas
	Quando o metodo de apropriação for mensal e o parâmetro MV_PIMSCSA estiver ativo,
	calcula o custo médio na mensagem EAI pelo custo médio das movimentações de saída
	do período
	@type  Static Function
	@author Gianluca Moreira
	@since 06/07/2022
/*/
Static Function CMSaidas(cProduto, cLocal, dDtDe, dDtAte)
	Local aRet     := {0,0,0,0,0}
	Local aBind    := {}
	Local cAlTMP   := ''
	Local cQuery   := ""
	Local nCusto1  := 0
	Local nCusto2  := 0
	Local nCusto3  := 0
	Local nCusto4  := 0
	Local nCusto5  := 0
	Local nQuant   := 0
	Local lWmsNew  := SuperGetMv("MV_WMSNEW",.F.,.F.)
	Local lD3Servi := IIF(lWmsNew,.F.,SuperGetMv('MV_D3SERVI',.F.,'N')=='N')
	Local cMvCQ    := GetMvNNR('MV_CQ','98')
	Local nBind    := 0

	If __lLibVer == Nil
		__lLibVer := FWLibVersion() >= "20211116"
	EndIf

	If __oTempTab == Nil
		cQuery := " Select Sum(D2_CUSTO1) C1, Sum(D2_CUSTO2) C2, Sum(D2_CUSTO3) C3, "
		cQuery += " Sum(D2_CUSTO4) C4, Sum(D2_CUSTO5) C5, Sum(D2_QUANT) QT "
		cQuery += " From "+RetSqlName('SD2')+" SD2 "
		cQuery += " Join "+RetSqlName('SF4')+" SF4 "
		cQuery += "    On SF4.F4_FILIAL   = ? "
		cQuery += "   And SF4.F4_CODIGO   = SD2.D2_TES "
		cQuery += "   And SF4.F4_ESTOQUE  = ? " //S - Mov. Estoque
		cQuery += "   And SF4.D_E_L_E_T_  = ? "
		cQuery += " Where SD2.D2_FILIAL   = ? "
		cQuery += "   And SD2.D2_COD      = ? "
		cQuery += "   And SD2.D2_LOCAL    = ? "
		cQuery += "   And SD2.D2_EMISSAO >= ? "
		cQuery += "   And SD2.D2_EMISSAO <= ? "
		cQuery += "   And SD2.D2_ORIGLAN <> ? " //LF - Livros Fiscais
		cQuery += "   And SD2.D_E_L_E_T_  = ? "

		cQuery += " Union All "

		cQuery += " Select Sum(D3_CUSTO1) C1, Sum(D3_CUSTO3) C2, Sum(D3_CUSTO3) C3,"
		cQuery += " Sum(D3_CUSTO4) C4, Sum(D3_CUSTO5) C5, Sum(D3_QUANT) QT "
		cQuery += " From "+RetSqlName('SD3')+" SD3 "
		cQuery += " Where SD3.D3_FILIAL   = ? "
		cQuery += "   And SD3.D3_COD      = ? "
		cQuery += "   And SD3.D3_LOCAL    = ? "
		cQuery += "   And SD3.D3_EMISSAO >= ? "
		cQuery += "   And SD3.D3_EMISSAO <= ? "
		cQuery += "   And SD3.D3_TM       > ? " //500
		cQuery += "   And SD3.D3_CF      In (?, " //'RE0'
		cQuery += " ?, " //RE1
		cQuery += " ?, " //RE2
		cQuery += " ?, " //RE4
		cQuery += " ?, " //RE5
		cQuery += " ?, " //RE6
		cQuery += " ?, " //RE7
		cQuery += " ?, " //RE8
		cQuery += " ?, " //RE9
		cQuery += " ?) " //REA
		cQuery += "   And SD3.D3_ESTORNO  = ? "
		If lD3Servi .And. IntDL()
			cQuery += " And ((SD3.D3_SERVIC = ?) "
			cQuery += " Or (SD3.D3_SERVIC  <> ? "
			cQuery += " And SD3.D3_TM      <= ?) "
			cQuery += " Or (SD3.D3_SERVIC  <> ? "
			cQuery += " And SD3.D3_TM       > ? "
			cQuery += " And SD3.D3_LOCAL    = ?))"
		EndIf
		cQuery += "   And SD3.D_E_L_E_T_  = ? "

		cQuery := ChangeQuery(cQuery)
		If __lLibVer
			__oTempTab := FwExecStatement():New(cQuery)
		Else
			__oTempTab := FWPreparedStatement():New(cQuery)
		EndIf
	EndIf

	//Preenchimento do filtro
	aBind := {}
	AAdd(aBind, FWXFilial('SF4')) //F4_FILIAL
	AAdd(aBind, 'S')              //F4_ESTOQUE
	AAdd(aBind, ' ')              //SF4.D_E_L_E_T_
	AAdd(aBind, FWXFilial('SD2')) //D2_FILIAL
	AAdd(aBind, cProduto)         //D2_COD
	AAdd(aBind, cLocal)           //D2_LOCAL
	AAdd(aBind, DToS(dDtDe))      //D2_EMISSAO
	AAdd(aBind, DToS(dDtAte))     //D2_EMISSAO
	AAdd(aBind, 'LF')             //D2_ORIGLAN
	AAdd(aBind, ' ')              //SD2.D_E_L_E_T_

	AAdd(aBind, FWXFilial('SD3')) //D3_FILIAL
	AAdd(aBind, cProduto)         //D3_COD
	AAdd(aBind, cLocal)           //D3_LOCAL
	AAdd(aBind, DToS(dDtDe))      //D3_EMISSAO
	AAdd(aBind, DToS(dDtAte))     //D3_EMISSAO
	AAdd(aBind, '500')            //D3_TM
	AAdd(aBind, 'RE0')            //D3_CF
	AAdd(aBind, 'RE1')            //D3_CF
	AAdd(aBind, 'RE2')            //D3_CF
	AAdd(aBind, 'RE4')            //D3_CF
	AAdd(aBind, 'RE5')            //D3_CF
	AAdd(aBind, 'RE6')            //D3_CF
	AAdd(aBind, 'RE7')            //D3_CF
	AAdd(aBind, 'RE8')            //D3_CF
	AAdd(aBind, 'RE9')            //D3_CF
	AAdd(aBind, 'REA')            //D3_CF
	AAdd(aBind, ' ')              //D3_ESTORNO
	If lD3Servi .And. IntDL()
		AAdd(aBind, Space(TamSx3('D3_SERVIC')[1])) //D3_SERVIC
		AAdd(aBind, Space(TamSx3('D3_SERVIC')[1])) //D3_SERVIC
		AAdd(aBind, '500')        //D3_TM
		AAdd(aBind, Space(TamSx3('D3_SERVIC')[1])) //D3_SERVIC
		AAdd(aBind, '500')        //D3_TM
		AAdd(aBind, cMvCQ)        //D3_LOCAL
	EndIf
	AAdd(aBind, ' ')              //SD3.D_E_L_E_T_

	For nBind := 1 To Len(aBind)
		__oTempTab:SetString(nBind, aBind[nBind])
	Next nBind

	If __lLibVer
		cAlTMP := GetNextAlias()
		__oTempTab:OpenAlias(cAlTMP)
	Else
		cQuery := __oTempTab:GetFixQuery()
		cAlTMP := MpSysOpenQuery(cQuery)
	EndIf

	While !(cAlTMP)->(EoF())
		nCusto1  += (cAlTMP)->C1
		nCusto2  += (cAlTMP)->C2
		nCusto3  += (cAlTMP)->C3
		nCusto4  += (cAlTMP)->C4
		nCusto5  += (cAlTMP)->C5
		nQuant   += (cAlTMP)->QT
		
		(cAlTMP)->(DbSkip())
	EndDo

	(cAlTMP)->(DbCloseArea())

	If nQuant > 0
		aRet[1] = nCusto1/nQuant
		aRet[2] = nCusto2/nQuant
		aRet[3] = nCusto3/nQuant
		aRet[4] = nCusto4/nQuant
		aRet[5] = nCusto5/nQuant
	EndIf

	ASize(aBind, 0)
	aBind := Nil
Return aRet
