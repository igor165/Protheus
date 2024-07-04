#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ022.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ022

Adapter REST da rotina de TIPOS DE LINHA

@type 		function
@sample 	GTPIRJ022(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		04/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ022(lJob)

Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob := .F. 

FwMsgRun( , {|oSelf| lRet := GI022Receb(lJob, oSelf)}, , STR0001)		// "Processando registros de Tipos de Linha... Aguarde!" 

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI022Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI022Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI022Receb(lJob, oMessage)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA022")
Local oMdlGQC	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GQC_FILIAL", "GQC_CODIGO"}
Local cIntID	  := ""
Local cIntAux     := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cErro		  := ""
Local cMsgErro    := ""
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

oRJIntegra:SetPath("/tipolinha/todos")
oRJIntegra:SetServico("TipoLinha")

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

If oRJIntegra:Get()
	GQC->(DbSetOrder(1))	// GQC_FILIAL+GQC_CODIGO
	nTotReg := oRJIntegra:GetLenItens()	
	For nX := 0 To nTotReg
		lContinua := .T.
		If lMessage .And. !lJob
			oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Tipos de Linha - #1/#2... Aguarde!" 
			ProcessMessages()
		EndIf
		
		If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idTpLinha' ,'C'))
		  	cCode := GTPxRetId("TotalBus", "GQC", "GQC_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
			If Empty(cIntID) 
				nOpc := MODEL_OPERATION_INSERT
			ElseIf lOk .And. GQC->(DbSeek(xFilial('GQC') + cCode))
				nOpc := MODEL_OPERATION_UPDATE
			Else
				lContinua := .F.
				oRJIntegra:oGTPLog:SetText(cErro)
			EndIf
			
			If lContinua
				oModel:SetOperation(nOpc)
				If oModel:Activate()
					oMdlGQC	:= oModel:GetModel("GQCMASTER")

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

							If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGQC:GetValue(cCampo)) 
								lContinua := oRJIntegra:SetValue(oMdlGQC, cCampo, xValor)
							ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
								lContinua := oRJIntegra:SetValue(oMdlGQC, cCampo, xValor)
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
							CFGA070MNT("TotalBus", "GQC", "GQC_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGQC:GetValue('GQC_CODIGO'), 'GQC')))
						EndIf

						If !lContinua
							oRJIntegra:oGTPLog:SetText(I18N(STR0004, {GTPXErro(oModel)}))		// "Falha ao gravar os dados (#1)." 
						EndIf
					EndIf
					oModel:DeActivate()
				Else
					oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)}))		// "Falha ao corregar modelos de dados (#1)." 
					Exit
				EndIf
			EndIf
		EndIf  	
	Next nX	
Else
	oRJIntegra:oGTPLog:SetText(I18N("Falha ao processar o retorno do serviço #2 (#1).", {oRJIntegra:GetLastError(),oRJIntegra:cUrl}))
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
GTPDestroy(oMdlGQC)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI022Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI022Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	thiago.tavares
@since 		04/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI022Job(aParam)

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[1], aParam[2])

GTPIRJ022(.T.)

RpcClearEnv()

Return
