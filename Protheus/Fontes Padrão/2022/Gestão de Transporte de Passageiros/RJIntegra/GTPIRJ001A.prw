#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GTPIRJ001A.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJA001

Adapter REST da rotina de ESTADO

@type 		function
@sample 	GTPIRJA001(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJA001(lJob,lAuto,lMonit)

Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob := .F. 
Default lAuto := .F.

If !lJob
	FwMsgRun( , {|oSelf| lRet := GI001AReceb(lJob, oSelf, lAuto, @lMonit)}, , STR0001)		// "Processando registros de Estados... Aguarde!" 
Else
	lRet := GI001AReceb(lJob, nil, lAuto)
EndIf
RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI001AReceb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI001AReceb(cRestResult, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	Logical - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI001AReceb(lJob, oMessage, lAuto, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local cIntID      := ""
Local cExtID      := ""
Local cCode	      := ""
Local cResultAuto := ""
Local nX	      := 0
Local nTotReg     := 0
Local lRet        := .T.   
Local lMessage    := ValType(oMessage) == 'O'

oRJIntegra:SetPath("/estado/todos")
oRJIntegra:cMainList := 'estado'

If lAuto
	cResultAuto := '{"estado":[{"idEstado":2,"descEstado":"ACRE","idPais":3,"dataModificacao":"2020-05-20","codigoEstado":"AC","icms":18.0,"idIBGE":"12"}]}'
EndIf

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ001A")

If oRJIntegra:Get(cResultAuto)
	nTotReg := oRJIntegra:GetLenItens()
	//Necessário para a automação não efetuar todos os registros de uma vez
	If lAuto
		nTotReg := 1
	EndIf
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)
	
	If ( nTotReg >= 0 )

		For nX := 0 To nTotReg 

			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Estados - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf

			If !Empty((cExtID := oRJIntegra:GetJsonValue(nX, 'idEstado', 'C'))) 
				cExtID := cValToChar(cExtID)
				cCode  := GTPxRetId("TotalBus", "SX5", "X5_CHAVE", cExtID, @cIntID, 4)
				If Empty(cCode)				
					If !Empty(FWGetSX5( "12", oRJIntegra:GetJsonValue(nX, 'codigoEstado', 'C') ) )
						CFGA070MNT("TotalBus", "SX5", "X5_CHAVE", cExtID, GTPxMakeId({"12", FWGetSX5( "12", oRJIntegra:GetJsonValue(nX, 'codigoEstado', 'C') )[1][3] }, "SX5"))
					Else
						CFGA070MNT("TotalBus", "SX5", "X5_CHAVE", cExtID, GTPxMakeId({"12", "EX"}, "SX5"))
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
/*/{Protheus.doc} GI001AJob

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI001AJob(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	thiago.tavares
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI001AJob(aParams,lAuto)

Default lAuto := .F.
//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParams[1], aParams[2])

GTPIRJA001(.T.,lAuto)

RpcClearEnv()

Return
