#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GTPIRJ001B.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJB001

Adapter REST da rotina de CIDADE

@type 		function
@sample 	GTPIRJB001(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJB001(lJob,lAuto,lMonit)

Local aArea := GetArea() 
Local lRet  := .T.

Default lJob := .F. 
Default lAuto := .F.

If !lJob
	FwMsgRun( , {|oSelf| lRet := GI001BReceb(lJob, oSelf, lAuto, @lMonit)}, , STR0001)		// "Processando registros de Cidades... Aguarde!" 
Else
	lRet := GI001BReceb(lJob, nil, lAuto)
EndIf

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI001BReceb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI001BReceb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	Logical - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI001BReceb(lJob, oMessage, lAuto, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local cIntID	  := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cCodEstado  := ""
Local cCodIBGE	  := ""
Local cResultAuto := ""
Local nX		  := 0
Local nTotReg     := 0 
Local lRet        := .T. 
Local lMessage	  := ValType(oMessage) == 'O'

oRJIntegra:SetPath("/cidade/todas")
oRJIntegra:cMainList := 'cidade'

If lAuto
	cResultAuto := '{"cidade":[{"idCidade":1208,"descCidade":"CENTRAL DO MARANHAO","idEstado":14,"dataModificacao":"2012-08-07","codIBGE":2103125}]}'
EndIf

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ001B")

If oRJIntegra:Get(cResultAuto)
	CC2->(DbSetOrder(1))	// CC2_FILIAL+CC2_EST+CC2_CODMUN
	nTotReg := oRJIntegra:GetLenItens()
	//Necessário para a automação não efetuar todos os registros de uma vez
	If lAuto
		nTotReg := 1
	EndIf

	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )

		For nX := 0 To nTotReg 
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Cidades - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf

			cExtID     := oRJIntegra:GetJsonValue(nX, 'idCidade', 'C')  
			cCodEstado := oRJIntegra:GetJsonValue(nX, 'idEstado', 'C')
			cCodIBGE   := oRJIntegra:GetJsonValue(nX, 'codIBGE', 'C')
			cDescMun   := oRJIntegra:GetJsonValue(nX, 'descCidade', 'C')
			
			If !Empty(cExtID) .And. !Empty(cCodEstado) .And. !Empty(cCodIBGE) .And. !Empty(cDescMun)
				cExtID	   := cValToChar(cExtID)
				cCode      := GTPxRetId("TotalBus", "CC2", "CC2_CODMUN", cExtID, @cIntID, 4)
				cCodEstado := GTPxRetId("TotalBus", "SX5", "X5_CHAVE", cValToChar(cCodEstado), , 4)
				cCodIBGE   := cValToChar(cCodIBGE)
				
				If Len(cCodIBGE) > 5 //Com Estado
					cCodIBGE := SubStr(cCodIBGE, 3)
				EndIf
				
				If Empty(cCode) .And. !Empty(cCodEstado)
					If CC2->(DbSeek(xFilial('CC2') + cCodEstado + cCodIBGE))
						CFGA070MNT("TotalBus", "CC2", "CC2_CODMUN", cExtID, GTPxMakeId({cCodEstado, cCodIBGE}, "CC2"))
					Else
						If RecLock('CC2', .T.)
							CC2->CC2_FILIAL	:= xFilial('CC2')				
							CC2->CC2_EST	:= cCodEstado
							CC2->CC2_CODMUN := cCodIBGE
							CC2->CC2_MUN	:= cDescMun
							CFGA070MNT("TotalBus", "CC2", "CC2_CODMUN", cExtID, GTPxMakeId({cCodEstado, cCodIBGE}, "CC2"))
						EndIf
						CC2->(MsUnlock())
					EndIf
				EndIf
			EndIf	
		Next nX	

	Else
		lMonit := .f.
		FwAlertHelp("Não há dados a serem processados com a parametrização utilizada.")
	EndIf
	
Else
	oRJIntegra:oGTPLog:SetText(I18N("Falha ao processar o retorno do serviço #2 (#1).", {oRJIntegra:GetLastError(),oRJIntegra:cUrl}))
	//DSERGTP-6567: Novo Log Rest RJ
	RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText()/*,oRJIntegra:GetResult("")*/)
EndIf

If !lJob .And. oRJIntegra:oGTPLog:HasInfo() 
	oRJIntegra:oGTPLog:ShowLog()
	lRet := .F.
ElseIf !lJob .And. !oRJIntegra:oGTPLog:HasInfo()
	If lMessage 
		oMessage:SetText(STR0004)		// "Processo finalizado." 
		ProcessMessages()
	Else
		Alert(STR0004)		// "Processo finalizado."
	EndIf	
EndIf

oRJIntegra:Destroy()

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI001BJob

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI001BJob(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	thiago.tavares
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI001BJob(aParams,lAuto)

Default lAuto := .F.
//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParams[1], aParams[2])

GTPIRJB001(.T.,lAuto)

RpcClearEnv()

Return
