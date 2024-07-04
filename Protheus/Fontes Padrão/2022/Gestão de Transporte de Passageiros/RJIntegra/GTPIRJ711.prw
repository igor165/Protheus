#Include "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ711.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ711

Adapter REST da rotina de Tipo de Ag�ncia

@type 		function
@sample 	GTPIRJ711()
@param 	 	lJob, logical - indica se a chamada foi realizada atrav�s de JOB (.T.) ou n�o (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou n�o (.F.)	 	
@author 	GTP
@since 		25/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ711(lJob,lMonit)

Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob := .F. 

FwMsgRun( , {|oSelf| lRet := GI711Receb(lJob, oSelf, @lMonit)}, , STR0001)		// "Processando registros de Tipo de Ag�ncia... Aguarde!" 

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI711Receb

Fun��o utilizada para executar o recebimento da integra��o e atualizar o registro

@type 		function
@sample 	GI711Receb(cRestResult, oMessage)
@param 		oRJIntegra, objeto - classe que trata da integra��o
			oMessage, objeto   - trata a mensagem apresentada em tela
@return 	lRet, logical      - resultado do processamento da rotina (.T. / .F.)
@author 	GTP
@since 		20/05/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI711Receb(lJob, oMessage, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA711")
Local oMdlGI5	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GI5_FILIAL", "GI5_CODIGO"}
Local cIntID	  := ""
Local cIntAux	  := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local cEstado     := ""
Local nX          := 0
Local nY          := 0
Local nOpc		  := 0
Local nPos        := 0
Local nTotReg     := 0
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'

oRJIntegra:SetPath("/tipoAgencia/todas")
oRJIntegra:SetServico('TipoAgencia')

oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ711")

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

If oRJIntegra:Get()
	GI5->(DbSetOrder(1))	// GI5_FILIAL+GI5_CODIGO
	nTotReg := oRJIntegra:GetLenItens()
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )
		
		For nX := 0 To nTotReg
			lContinua := .T.
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Tipo de Ag�ncia - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf

			If !Empty((cExtID := oRJIntegra:GetJsonValue(nX, 'idTipo', 'C'))) 
				cCode := GTPxRetId("TotalBus", "GI5", "GI5_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID)  
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GI5->(DbSeek(xFilial('GI5') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf

				If lContinua
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oMdlGI5 := oModel:GetModel("GI5MASTER")

						For nY := 1 To Len(aFldDePara)
							// recuperando a TAG e o respectivo campo da tabela 
							cTagName    := aFldDePara[nY][1] 
							cCampo      := aFldDePara[nY][2]
							cTipoCpo    := aFldDePara[nY][3]
							lOnlyInsert := aFldDePara[nY][6]
							lOverWrite  := aFldDePara[nY][7]
							
							// recuperando atrav�s da TAG o valor a ser inserido no campo 
							If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)))
								
								// verificando a necessidade de realizar o DePara XXF
								If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
									xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
								EndIf

								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGI5:GetValue(cCampo)) 
									lContinua := oRJIntegra:SetValue(oMdlGI5, cCampo, xValor)
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
									lContinua := oRJIntegra:SetValue(oMdlGI5, cCampo, xValor)
								EndIf

								If !lContinua 
									oRJIntegra:oGTPLog:SetText(I18N(STR0003, {cCampo, GTPXErro(oModel)}))		// "Falha ao gravar o valor do campo #1 (#2)." 
									Exit	
								EndIf
							EndIf
						Next nY
						
						If !lContinua 
							Exit
						Else
							If (lContinua := oModel:VldData())
								oModel:CommitData()
								CFGA070MNT("TotalBus", "GI5", "GI5_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGI5:GetValue('GI5_CODIGO'), 'GI5')))							
							EndIf							
							
							If !lContinua
								oRJIntegra:oGTPLog:SetText(I18N("Falha ao validar os dados do tipo ag�ncia #2 (#1).", {GTPXErro(oModel),cExtID,cIntId}))
							EndIf
						EndIf
						oModel:DeActivate()
					Else
						oRJIntegra:oGTPLog:SetText(I18N("Falha ao validar os dados do tipo ag�ncia #2 (#1).", {GTPXErro(oModel),cExtID,cIntId}))
					EndIf
				EndIf
			EndIf
			
			//DSERGTP-6567: Novo Log Rest RJ
			If ( !lContinua )
				
				RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText(),/*oRJIntegra:GetResult("")*/)
				oRJIntegra:oGTPLog:ResetText()

			EndIf
		
		Next nX

	Else
		lMonit := .f.
		FwAlertHelp("N�o h� dados a serem processados com a parametriza��o utilizada.")
	EndIf
				
Else
	oRJIntegra:oGTPLog:SetText(I18N("Falha ao processar o retorno do servi�o #2 (#1).", {oRJIntegra:GetLastError(),oRJIntegra:cUrl}))
	RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText(),/*oRJIntegra:GetResult("")*/)
EndIf

If !lJob .And. oRJIntegra:oGTPLog:HasInfo() 
	oRJIntegra:oGTPLog:ShowLog()
	lRet := .F.
ElseIf !lJob .And. !oRJIntegra:oGTPLog:HasInfo()
	If lMessage 
		oMessage:SetText(STR0007)		// "Processo finalizado." 
		ProcessMessages()
	Else
		Alert(STR0007)		// "Processo finalizado."
	EndIf	
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGI5)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI711Job

Fun��o utilizada para consumir o servi�o atrav�s de um JOB

@type 		function
@sample 	GI711Job(aParams)
@param		aParam, array - lista de par�metros 	 	
@return 	
@author 	GTP
@since 		20/05/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI711Job(aParams)

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParams[1], aParams[2])

GTPIRJ711(.T.)

RpcClearEnv()

Return
