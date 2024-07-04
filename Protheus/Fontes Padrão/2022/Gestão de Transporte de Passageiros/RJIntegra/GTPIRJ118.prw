#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ118.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ118

Adapter REST da rotina de CATEGORIAS DE BILHETE 

@type 		function
@sample 	GTPIRJ118(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		04/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ118(lJob,lMonit, lAuto)
Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob  := .F. 
Default lAuto := .F.

FwMsgRun( , {|oSelf| lRet := GI118Receb(lJob, oSelf, @lMonit, lAuto)}, , STR0001)	// "Processando registros de Categorias de Bilhete... Aguarde!" 

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI118Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI118Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI118Receb(lJob, oMessage, lMonit, lAuto)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA118")
Local oMdlG9B	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"G9B_FILIAL", "G9B_CODIGO"}
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
Local cResultAuto := ''
Local cXmlAuto    := ''

oRJIntegra:SetPath("/categoriapassagem/todas")
oRJIntegra:SetServico("CategoriaPassagem")

If lAuto
	cResultAuto := '{"categoriaPassagem":[{"idCategoria":12,"descCategoria":"IDOSO 100%","dataModificacao":"2020-11-16","descImpresionGratuidade":"VENDA GRATUIDADE IDOSO 100 RJ","desconto":0,"descontoPorc":100,"descontoTarifa":"false","descontoSeguro":"false","descontoTMR":"false","descontoTaxaEmbarque":"false","descontoPedagio":"false","alterarValor":"false","exigirDocumento":"false"}]}'
	cXmlAuto    := '<?xml version="1.0" encoding="UTF-8"?><RJIntegra><CategoriaPassagem tagMainList="categoriaPassagem"><ListOfFields><Field><tagName>idCategoria</tagName><fieldProtheus>G9B_CODIGO</fieldProtheus><onlyInsert>True</onlyInsert><overwrite>False</overwrite></Field><Field><tagName>descCategoria</tagName><fieldProtheus>G9B_DESCRI</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field></ListOfFields></CategoriaPassagem></RJIntegra>'
EndIf

If !lAuto
	oRJIntegra:SetServico("CategoriaPassagem")
Else
	oRJIntegra:SetServico("CategoriaPassagem",,,cXmlAuto)
EndIf

oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ118")

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

If oRJIntegra:Get(cResultAuto)
	G9B->(DbSetOrder(1))	// G9B_FILIAL+G9B_CODIGO
	nTotReg := oRJIntegra:GetLenItens()	
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )

		For nX := 0 To nTotReg
			lContinua := .T.
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Categorias de Bilhete - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf
			
			If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idCategoria' ,'C'))
				cCode := GTPxRetId("TotalBus", "G9B", "G9B_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. G9B->(DbSeek(xFilial('G9B') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf
				
				If lContinua
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oMdlG9B	:= oModel:GetModel("G9BMASTER")

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

								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlG9B:GetValue(cCampo)) 
									lContinua := oRJIntegra:SetValue(oMdlG9B, cCampo, xValor)
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
									lContinua := oRJIntegra:SetValue(oMdlG9B, cCampo, xValor)
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
								CFGA070MNT("TotalBus", "G9B", "G9B_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlG9B:GetValue('G9B_CODIGO'), 'G9B')))
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
		
			//DSERGTP-6567: Novo Log Rest RJ
			If ( !lContinua )
				
				RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText(),/*oRJIntegra:GetResult("")*/)
				oRJIntegra:oGTPLog:ResetText()

			EndIf
		
		Next nX	

	Else
		lMonit := .f.
		FwAlertHelp("Não há dados a serem processados com a parametrização utilizada.")
	EndIf

Else
	oRJIntegra:oGTPLog:SetText(I18N("Falha ao processar o retorno do serviço #2 (#1).", {oRJIntegra:GetLastError(),oRJIntegra:cUrl}))
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
GTPDestroy(oMdlG9B)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI118Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI118Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jacomo.fernandes
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI118Job(aParam, lAuto)

Default lAuto := .F.
//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[1], aParam[2])

GTPIRJ118(.T.,,lAuto)

RpcClearEnv()

Return
