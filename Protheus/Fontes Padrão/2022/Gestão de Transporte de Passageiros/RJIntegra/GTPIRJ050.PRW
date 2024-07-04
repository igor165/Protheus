#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
//#INCLUDE "GTPIRJ050.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ050

Adapter REST da rotina de Tipos de Vendas

@type 		function
@sample 	GTPIRJ050(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ050(lJob, lMonit)

Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob := .F. 

FwMsgRun( , {|oSelf| lRet := GI050Receb(lJob, oSelf, @lMonit)}, , "Processando registros de Tipos de Vendas... Aguarde!" )		// "Processando registros de Órgãos Concedentes... Aguarde!" 

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI050Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI050Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI050Receb(lJob, oMessage, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA050")
Local oMdlGYB	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GYB_FILIAL", "GYB_CODIGO"}
Local cIntID	  := ""
Local cIntAux     := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local nX          := 0
Local nY          := 0
Local nOpc		  := 0
Local nTotReg     := 0
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'

oRJIntegra:SetPath("/tipoVenda/todas")
oRJIntegra:SetServico("TipoVenda")

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ050")

If oRJIntegra:Get()
	GYB->(DbSetOrder(1))	// GYB_FILIAL+GYB_CODIGO
	nTotReg := oRJIntegra:GetLenItens()	
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )
	
		For nX := 0 To nTotReg
			lContinua := .T.
			If lMessage .And. !lJob
				oMessage:SetText(I18N("Processando registros de Tipos de Vendas - #1/#2... Aguarde!", {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Órgãos Concedentes - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf
			
			If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idTipo' ,'C'))
				cCode := GTPxRetId("TotalBus", "GYB", "GYB_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GYB->(DbSeek(xFilial('GYB') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf
				
				If lContinua
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oMdlGYB	:= oModel:GetModel("GYBMASTER")

						For nY := 1 To Len(aFldDePara)
							// recuperando a TAG e o respectivo campo da tabela 
							cTagName    := aFldDePara[nY][1] 
							cCampo      := aFldDePara[nY][2]
							cTipoCpo    := aFldDePara[nY][3]
							lOnlyInsert := aFldDePara[nY][6]
							lOverWrite  := aFldDePara[nY][7]

							// recuperando através da TAG o valor a ser inserido no campo 
							If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)))

								// verificando a necessidade de realizar o DePara XXF
								If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
									xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
								EndIf

								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGYB:GetValue(cCampo)) 
									lContinua := oRJIntegra:SetValue(oMdlGYB, cCampo, xValor)
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
									lContinua := oRJIntegra:SetValue(oMdlGYB, cCampo, xValor)
								EndIf

								If !lContinua 
									oRJIntegra:oGTPLog:SetText(I18N("Falha ao gravar o valor do campo #1 (#2).", {cCampo, GTPXErro(oModel)}))		// "Falha ao gravar o valor do campo #1 (#2)." 
									Exit	
								EndIf
							EndIf
						Next nY
							
						If !lContinua 
							//DSERGTP-6567: Novo Log Rest RJ
							RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText()/*,oRJIntegra:GetResult("")*/)
							Exit
						Else
							If (lContinua := oModel:VldData())
								oModel:CommitData()
								CFGA070MNT("TotalBus", "GYB", "GYB_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGYB:GetValue('GYB_CODIGO'), 'GYB')))
							EndIf

							If !lContinua
								oRJIntegra:oGTPLog:SetText(I18N("Falha ao gravar os dados (#1).", {GTPXErro(oModel)}))		// "Falha ao gravar os dados (#1)." 
							EndIf
						EndIf
						oModel:DeActivate()
					Else
						oRJIntegra:oGTPLog:SetText(I18N("Falha ao corregar modelos de dados (#1).", {GTPXErro(oModel)}))		// "Falha ao corregar modelos de dados (#1)." 
						//DSERGTP-6567: Novo Log Rest RJ
						RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText()/*,oRJIntegra:GetResult("")*/)
						Exit
					EndIf
				EndIf
			EndIf  	
			
			//DSERGTP-6567: Novo Log Rest RJ
			If ( !lContinua )
				RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText()/*,oRJIntegra:GetResult("")*/)
				oRJIntegra:oGTPLog:ResetText()
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
		oMessage:SetText( "Processo finalizado.")		// "Processo finalizado." 
		ProcessMessages()
	Else
		Alert( "Processo finalizado.")		// "Processo finalizado."
	EndIf	
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGYB)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI050Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI050Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI050Job(aParam)

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[1], aParam[2])

GTPIRJ050(.T.)

RpcClearEnv()

Return
