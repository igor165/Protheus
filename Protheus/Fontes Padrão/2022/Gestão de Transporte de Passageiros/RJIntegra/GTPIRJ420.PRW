#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ420.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ420

Adapter REST da rotina de TIPOS DE DOCUMENTO 

@type 		function
@sample 	GTPIRJ420(lJOb)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		04/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ420(lJob, lMonit)

Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob := .F. 

FwMsgRun( , {|oSelf| lRet := GI420Receb(lJob, oSelf, @lMonit)}, , STR0001)		// "Processando registros de Tipos de Documento... Aguarde!" 

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI420Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI420Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI420Receb(lJob, oMessage, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA420")
Local oMdlGZC	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GZC_FILIAL", "GZC_CODIGO"}
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

oRJIntegra:SetPath("/TipoReceitaDespesa/todas")
oRJIntegra:SetServico("TipoDocumento")

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

oModel:GetModel('GZCMASTER'):GetStruct():SetProperty( "GZC_DESCRI" , MODEL_FIELD_WHEN  , {|| ALLWAYSTRUE() } ) 

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ420")

If oRJIntegra:Get()
	GZC->(DbSetOrder(1))	// GZC_FILIAL+GZC_CODIGO
	nTotReg := oRJIntegra:GetLenItens()	
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )

		For nX := 0 To nTotReg
			lContinua := .T.
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Tipos de Documento - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf
			
			If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idTipo' ,'C',, .F.))
				cCode := GTPxRetId("TotalBus", "GZC", "GZC_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GZC->(DbSeek(xFilial('GZC') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf
				
				If lContinua
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oMdlGZC	:= oModel:GetModel("GZCMASTER")

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

								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGZC:GetValue(cCampo))
									If cCampo == "GZC_CODIGO"
										xValor:= GI420PrxNum()	 	
									EndIf
									
									lContinua := oRJIntegra:SetValue(oMdlGZC, cCampo, xValor)
									
									
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
									
									lContinua := oRJIntegra:SetValue(oMdlGZC, cCampo, xValor)
									
								EndIf

								If !lContinua 
									oRJIntegra:oGTPLog:SetText(I18N(STR0003, {cCampo, GTPXErro(oModel)}))		// "Falha ao gravar o valor do campo #1 (#2)." 
									Exit	
								EndIf
							EndIf
						Next nY
						
						If (nOpc == MODEL_OPERATION_INSERT)
							oMdlGZC:SetValue('GZC_INCMAN'	,"2") 
							oMdlGZC:SetValue('GZC_PROPRI'	,"S")
						EndIf
						
							
						If !lContinua 
							Exit
						Else
						If (lContinua := oModel:VldData())
								
								oModel:CommitData()
								CFGA070MNT("TotalBus", "GZC", "GZC_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGZC:GetValue('GZC_CODIGO'), 'GZC')))
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
				
				RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText())
				
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
		oMessage:SetText(STR0007)		// "Processo finalizado." 
		ProcessMessages()
	Else
		Alert(STR0007)		// "Processo finalizado."
	EndIf	
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGZC)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI420Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI420Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jacomo.fernandes
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI420Job(aParam)

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[1], aParam[2])

GTPIRJ420(.T.)

RpcClearEnv()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI420PrxNum

Função utilizada para retornar o próximo número do Código automático

@type 		function
@sample 	GI420Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	gustavo.silva2
@since 		24/07/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------

Static Function GI420PrxNum()
Local cCodigo 	:= "100"
Local cAliasGZC	:= GetNextAlias()

	BeginSql Alias cAliasGZC
	 		
		SELECT ISNULL(MAX(GZC_CODIGO),'000') CODIGO
	 	FROM %Table:GZC% GZC
		WHERE
		GZC.GZC_FILIAL = %xFilial:GZC%
		AND ISNUMERIC(GZC_CODIGO)=1
		AND GZC.%NotDel%
			      
	EndSql
	
	If Val((cAliasGZC)->CODIGO) <= 100		    
		cCodigo := Soma1(cCodigo)
	Else
		cCodigo	:= Soma1((cAliasGZC)->CODIGO)
	EndIf
	
	(cAliasGZC)->(dbCloseArea())	

Return cCodigo
