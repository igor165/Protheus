#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FWMVCDEF.CH'
#Include 'MATI685.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI685
Funcao de integracao com o adapter EAI para envio e recebimento do
apontamento de perda (SBC) utilizando o conceito de mensagem unica.

@param		oXMLEnv			Variavel com conteudo xml para envio/recebimento.
@param		nTypeTrans		Tipo de transacao. (Envio/Recebimento)
@param		cTypeMessage	Tipo de mensagem. (Business Type, WhoIs, etc)

@author		Lucas Konrad França
@version	P118
@since		03/11/2016
@return		aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
				aRet[1] - (boolean) Indica o resultado da execução da função
				aRet[2] - (caracter) Mensagem Xml para envio

@obs			O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
				o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
				TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
				O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function MATI685(oXMLEnv, nTypeTrans, cTypeMessage)
	Local cVersao     := ""
	Local lRet        := .T.
	Local cXmlRet     := ""

	Private oXML      := oXMLEnv
	Private lIntegPPI := .F.

	//Verifica se está sendo executado para realizar a integração com o PPI.
	//Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
	If Type("lRunPPI") == "L" .And. lRunPPI
		lIntegPPI := .T.
	EndIf

	//Mensagem de Entrada
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			
			// Versão da mensagem
			If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			Else
				If Type("oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text)
					cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text, ".")[1]
				Else
					lRet    := .F.
					cXmlRet := STR0001 //"Versão da mensagem não informada!"
					Return {lRet, cXmlRet}
				Endif
			EndIf

			If cVersao != "1"
				lRet    := .F.
				cXmlRet := STR0002 //"A versão da mensagem informada não foi implementada!"
				Return {lRet, cXmlRet}
			Else
				BeginTran()
					aRet := runIntegra(oXML, nTypeTrans, cTypeMessage, cVersao)
					If !aRet[1]
						DisarmTransaction()
					EndIf
				EndTran()
				MsUnLockAll()
			EndIf
		Endif
	ElseIf nTypeTrans == TRANS_SEND
	
	EndIf
	
	lRet    := aRet[1]
	cXMLRet := aRet[2]
Return {lRet, cXMLRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} runIntegra

Funcao de integracao com o adapter EAI para recebimento do apontamento de perda (SBC)
utilizando o conceito de mensagem unica.

@param		oXMLEnv			Variável com conteúdo XML para envio/recebimento.
@param		nTypeTrans		Tipo de transação. (Envio/Recebimento)
@param		cTypeMessage	Tipo de mensagem. (Business Type, WhoIs, etc)
@param		cVersao			Versão da mensagem que está sendo trafegada.

@author		Lucas Konrad França
@version	P118
@since		03/11/2016
@return		aRet  - (array)   Contém o resultado da execução e a mensagem XML de retorno.
					aRet[1] - (boolean)  Indica o resultado da execução da função
					aRet[2] - (caracter) Mensagem XML para envio

@obs		O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
			o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
			TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
			O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Static Function runIntegra(oXMLEnv, nTypeTrans, cTypeMessage, cVersao)
	Local lRet        := .T.
	Local cXmlRet     := ""
	Local cEvent      := ""
	Local cProduct    := ""
	Local cLogErro    := ""
	Local aRet        := {}
	Local aErroAuto   := {}
	Local nCount      := 0
	Local aCabSBC     := {}
	Local aDetSBC     := {}
	Local aDet        := {}
	
	Local cOrdem     := Nil
	Local cProd      := Nil
	Local cLocal     := Nil
	Local cEndereco  := Nil
	Local cNumSeri   := Nil
	Local cTipo      := Nil
	Local cMot       := Nil
	Local cDesMotivo := Nil
	Local nQtdPerda  := Nil
	Local cCentCusto := Nil
	Local cProdDest  := Nil
	Local cLocalDest := Nil
	Local cEnderDest := Nil
	Local cSerieDest := Nil
	Local nQtdDest   := Nil
	Local cOperac    := Nil
	Local cRecurso   := Nil
	Local dDtPerda   := Nil
	Local cLote      := Nil
	Local cSubLote   := Nil
	Local dDtVldLote := Nil
	
	Private oXml        := oXMLEnv
	Private lMSErroAuto := .F.
	Private lRunPPI     := .T.
	Private lAutoErrNoFile := .T.
	
	If !lIntegPPI .And. FindFunction("AdpLogEAI")
		AdpLogEAI(1, "MATI685", nTypeTrans, cTypeMessage)
	EndIf
	
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
				cEvent := Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
				If AllTrim(cEvent) != "UPSERT"
					lRet := .F.
					cXmlRet := STR0003 //"Event informado é inválido. Apenas 'UPSERT' válido para esta mensagem."
				EndIf
			Else
				lRet    := .F.
				cXmlRet := "Event" + STR0004 // é obrigatório."
				Return {lRet, cXMLRet}
			EndIf
		EndIf
		
		If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			cProduct := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		Else
			lRet   := .F.
			cXmlRet := "Product:Name" + STR0004 // é obrigatório."
			Return {lRet, cXMLRet}
		EndIf
		
		If Type("oXml:_TotvsMessage:_MessageInformation:_CompanyId:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_CompanyId:Text)
			cEmpIntg := oXml:_TotvsMessage:_MessageInformation:_CompanyId:Text
		Else
			cEmpIntg := cEmpAnt
		EndIf
		
		If Type("oXml:_TotvsMessage:_MessageInformation:_BranchId:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_BranchId:Text)
			cFilIntg := oXml:_TotvsMessage:_MessageInformation:_BranchId:Text
		Else
			cFilIntg := cFilAnt
		EndIf
		
		If AllTrim(UPPER(cProduct)) == "PPI"
			//Verifica se a integração com o PPI está ativa. Se não estiver, não permite prosseguir com a integração.
			If !PCPIntgPPI()
				lRet := .F.
				cXmlRet := STR0005 //"Integração com o PC-Factory desativada. Processamento não permitido."
				Return {lRet, cXMLRet}
			EndIf
		EndIf
		
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text)
			cOrdem := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text
			cNumOp := cOrdem
			SC2->(dbSetOrder(1))
			If !SC2->(dbSeek(xFilial("SC2")+cOrdem))
				cXmlRet := STR0007 //"Ordem de produção não cadastrada."
				lRet := .F.
				Return {lRet,cXmlRet}
			EndIf
		Else
			lRet := .F.
			cXmlRet := "ProductionOrderNumber" + STR0004 // é obrigatório."
			Return {lRet, cXMLRet}
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text)
			cProd := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text
			cProduto := cProd
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text)
			cLocal := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text
		Else
			If !Empty(cProd)
				SC2->(dbSetOrder(1))
				If SC2->(dbSeek(xFilial("SC2")+cOrdem))
					cLocal := SC2->C2_LOCAL
				EndIf
			EndIf
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_AddressCode:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_AddressCode:Text)
			cEndereco := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_AddressCode:Text
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeries:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeries:Text)
			cNumSeri := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeries:Text
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Type:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Type:Text)
			cTipo := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Type:Text
			If cTipo == "1"
				cTipo := "R"
			ElseIf cTipo == "2"
				cTipo := "S"
			Else
				cXmlRet := STR0008 //"Type inválido. Valores aceitos: 1-Refugo; 2-Scrap."
				lRet := .F.
				Return {lRet, cXmlRet}
			EndIf
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WasteCode:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WasteCode:Text)
			cMot := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WasteCode:Text
			cMotivo := cMot
		Else
			lRet := .F.
			cXmlRet := "WasteCode" + STR0004 // é obrigatório."
			Return {lRet, cXMLRet}
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WasteDescription:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WasteDescription:Text)
			cDesMotivo := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WasteDescription:Text
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LossQuantity:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LossQuantity:Text)
			nQtdPerda := Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LossQuantity:Text)
			nQtdSOG := nQtdPerda
		Else
			lRet := .F.
			cXmlRet := "LossQuantity" + STR0004 // é obrigatório."
			Return {lRet, cXMLRet}
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_CostCenterCode:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_CostCenterCode:Text)
			cCentCusto := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_CostCenterCode:Text
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCodeTo:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCodeTo:Text)
			cProdDest := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCodeTo:Text
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCodeTo:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCodeTo:Text)
			cLocalDest := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCodeTo:Text
		Else
			If !Empty(cProdDest)
				SOE->(dbSetOrder(1))
				If SOE->(dbSeek(xFilial("SOE")+"SC2"))
					cLocalDest := SOE->OE_VAR3
				EndIf
			EndIf
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_AddressCodeTo:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_AddressCodeTo:Text)
			cEnderDest := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_AddressCodeTo:Text
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeriesTo:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeriesTo:Text)
			cSerieDest := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeriesTo:Text
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_QuantityTo:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_QuantityTo:Text)
			nQtdDest := Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_QuantityTo:Text)
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ActivityCode:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ActivityCode:Text)
			cOperac := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ActivityCode:Text
			cOperacao := cOperac
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ResourceCode:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ResourceCode:Text)
			cRecurso := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ResourceCode:Text
			cMaquina := cRecurso
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LossDate:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LossDate:Text)
			dDtPerda := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LossDate:Text))
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotCode:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotCode:Text)
			cLote := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotCode:Text
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotCode:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotCode:Text)
			cSubLote := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotCode:Text
		EndIf
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotDueDate:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotDueDate:Text)
			dDtVldLote := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotDueDate:Text))
		EndIf
		
		
		/*
		* Monta o cabeçalho da SBC
		*/
		If !Empty(cOrdem)
			aAdd(aCabSBC,{'BC_OP'     , cOrdem    , Nil })
		EndIf
		If !Empty(cOperac)
			aAdd(aCabSBC,{'BC_OPERAC' , cOperac   , Nil })
		EndIf
		If !Empty(cRecurso)
			aAdd(aCabSBC,{'BC_RECURSO', cRecurso  , Nil })
		EndIf
		
		/*
		* Monta o detalhe da SBC
		*/
		If !Empty(cProd)
			aAdd(aDet, {'BC_PRODUTO', cProd     , Nil } )
		EndIf
		If !Empty(cLocal)
			aAdd(aDet, {'BC_LOCORIG', cLocal    , Nil } )
		EndIf
		If !Empty(cEndereco)
			aAdd(aDet, {'BC_LOCALIZ', cEndereco , Nil } )
		EndIf
		If !Empty(cNumSeri)
			aAdd(aDet, {'BC_NUMSERI', cNumSeri  , Nil } )
		EndIf
		If !Empty(cTipo)
			aAdd(aDet, {'BC_TIPO'   , cTipo     , Nil } )
		EndIf
		If !Empty(cMot)
			aAdd(aDet, {'BC_MOTIVO' , cMot      , Nil } )
		EndIf
		If !Empty(nQtdPerda)
			aAdd(aDet, {'BC_QUANT'  , nQtdPerda , Nil } )
		EndIf
		If !Empty(cCentCusto)
			aAdd(aDet, {'BC_CC'     , cCentCusto, Nil } )
		EndIf
		If !Empty(cProdDest)
			aAdd(aDet, {'BC_CODDEST', cProdDest , Nil } )
		EndIf
		If !Empty(cLocalDest)
			aAdd(aDet, {'BC_LOCAL'  , cLocalDest, Nil } )
		EndIf
		If !Empty(cEnderDest)
			aAdd(aDet, {'BC_LOCDEST', cEnderDest, Nil } )
		EndIf
		If !Empty(cSerieDest)
			aAdd(aDet, {'BC_NSEDEST', cSerieDest, Nil } )
		EndIf
		If !Empty(nQtdDest)
			aAdd(aDet, {'BC_QTDDEST', nQtdDest  , Nil } )
		EndIf
		If !Empty(dDtPerda)
			aAdd(aDet, {'BC_DATA'   , dDtPerda  , Nil } )
		EndIf
		If !Empty(cLote)
			aAdd(aDet, {'BC_LOTECTL', cLote     , Nil } )
		EndIf
		If !Empty(cSubLote)
			aAdd(aDet, {'BC_NUMLOTE', cSubLote  , Nil } )
		EndIf
		If !Empty(dDtVldLote)
			aAdd(aDet, {'BC_DTVALID', dDtVldLote, Nil } )
		EndIf
		aAdd(aDet, {'BC_OBSERVA', Iif(AllTrim(UPPER(cProduct))=="PPI","TOTVSMES",cProduct), Nil } )
		aAdd(aDetSBC, aDet)
		// PE MATI685EXC
		If (ExistBlock('MATI685EXC'))
			aRet := ExecBlock('MATI685EXC',.F.,.F.,{aCabSBC, aDetSBC})
			If !aRet[1]
				Return {.F., Iif(Empty(aRet[2]), STR0006, aRet[2] ) } //"Não processado devido ao Ponto de Entrada MATI685EXC."
			EndIf
		EndIf
		MSExecAuto({|x,y,z| mata685(x,y,z)}, aCabSBC, aDetSBC, 3)
		If lMsErroAuto
			aErroAuto := GetAutoGRLog()
			cLogErro := getMsgErro(aErroAuto)
			lRet    := .F.
			cXMLRet := cLogErro
			Return {lRet,cXmlRet}
		Else
			lRet    := .T.
			cXmlRet := cValToChar(SBC->(Recno()))
		EndIf
	ElseIf nTypeTrans == TRANS_SEND
	
	EndIf
	
	If !lIntegPPI .And. FindFunction("AdpLogEAI")
		AdpLogEAI(5, "MATI685", cXMLRet, lRet)
	EndIf
	
Return {lRet, cXmlRet}

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

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getMsgErro

Transforma o array com as informações de um erro em uma string para ser retornada.

@param aErro - Array com a mensagem de erro, obtido através da função GetAutoGRLog

@return cMsg - Mensagem no formato String

@author  Lucas Konrad França
@version P12
@since   07/03/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function getMsgErro(aErro)
	Local cMsg   := ""
	Local nCount := 0
	
	For nCount := 1 To Len(aErro)
		If AT(':=',aErro[nCount]) > 0 .And. AT('< --',aErro[nCount]) < 1
			Loop
		EndIf
		If AT("------", aErro[nCount]) > 0
			Loop
		EndIf
		//Retorna somente a mensagem de erro (Help) e o valor que está inválido, sem quebras de linha e sem tags '<>'
		If !Empty(cMsg)
			cMsg += " "
		EndIf
		cMsg += AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aErro[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
	Next nCount
	
	If Empty(cMsg) .And. Len(aErro) > 0
		For nCount := 1 To Len(aErro)
			If !Empty(cMsg)
				cMsg += " "
			EndIf
			cMsg += AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aErro[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
		Next nCount
	EndIf

Return cMsg
