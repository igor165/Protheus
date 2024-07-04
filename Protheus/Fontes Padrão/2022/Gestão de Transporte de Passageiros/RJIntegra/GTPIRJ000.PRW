#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ000.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ000

Adapter REST da rotina de ÓRGÃOS CONCEDENTES

@type 		function
@sample 	GTPIRJ000(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ000(lJob,lAuto,lMonit)

Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob := .F. 
Default lAuto := .F.

If !lJob
	FwMsgRun( , {|oSelf| lRet := GI000Receb(lJob, oSelf,lAuto,@lMonit)}, , STR0001)		// "Processando registros de Órgãos Concedentes... Aguarde!" 
Else	
	lRet := GI000Receb(lJob,nil,lAuto)
EndIf

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI000Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI000Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI000Receb(lJob, oMessage, lAuto, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA000")
Local oMdlGI0	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GI0_FILIAL", "GI0_COD"}
Local cIntID	  := ""
Local cIntAux     := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local cResultAuto := ""
Local cXmlAuto    := ""
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

oRJIntegra:SetPath("/orgao/todos")

If lAuto
	cResultAuto := '{"orgao":[{"idOrgao":32,"descOrgao":"AGER/MT","sigla":""},{"idOrgao":22,"descOrgao":"DETRO/RJ","sigla":""},{"idOrgao":-1,"descOrgao":"TODOS","sigla":""},{"idOrgao":1,"descOrgao":"DER/SP","sigla":""},{"idOrgao":2,"descOrgao":"DER/PR","sigla":""},{"idOrgao":3,"descOrgao":"ANTT","sigla":""},{"idOrgao":4,"descOrgao":"AGEPAN","sigla":""},{"idOrgao":5,"descOrgao":"DER/MT","sigla":""},{"idOrgao":6,"descOrgao":"DER/MG","sigla":""},{"idOrgao":7,"descOrgao":"DER/BA","sigla":""},{"idOrgao":8,"descOrgao":"DER/CE/PB/PA","sigla":""},{"idOrgao":9,"descOrgao":"DER/RJ","sigla":""},{"idOrgao":10,"descOrgao":"DER/ES","sigla":""},{"idOrgao":11,"descOrgao":"INTERNACIONAL","sigla":""},{"idOrgao":12,"descOrgao":"DER/TO","sigla":""},{"idOrgao":13,"descOrgao":"DER/CE","sigla":""},{"idOrgao":14,"descOrgao":"DER/PE","sigla":""},{"idOrgao":15,"descOrgao":"DER/SC","sigla":""},{"idOrgao":16,"descOrgao":"DER/GO","sigla":""},{"idOrgao":17,"descOrgao":"SINFRA - MA","sigla":""},{"idOrgao":18,"descOrgao":"SETRANS - PI","sigla":""},{"idOrgao":19,"descOrgao":"DER-PB","sigla":""},{"idOrgao":20,"descOrgao":"DETRAN-CE","sigla":""},{"idOrgao":21,"descOrgao":"ARTESP","sigla":""},{"idOrgao":28,"descOrgao":"DER/RO","sigla":""},{"idOrgao":30,"descOrgao":"DETER","sigla":""},{"idOrgao":31,"descOrgao":"DAER","sigla":""},{"idOrgao":25,"descOrgao":"Pref de Ibatiba","sigla":""},{"idOrgao":26,"descOrgao":"Pref de Joï¿½o Neiva","sigla":""},{"idOrgao":27,"descOrgao":"AGERBA","sigla":""},{"idOrgao":23,"descOrgao":"Pref.Marilia","sigla":""},{"idOrgao":24,"descOrgao":"EMTU","sigla":""},{"idOrgao":29,"descOrgao":"ATR","sigla":""}]}'
	cXmlAuto    := '<?xml version="1.0" encoding="utf-8"?><RJIntegra><OrgaoConcedente tagMainList="orgao"><ListOfFields><Field><tagName>idOrgao</tagName><fieldProtheus>GI0_CODIGO</fieldProtheus><onlyInsert>True</onlyInsert><overwrite>False</overwrite></Field><Field><tagName>descOrgao</tagName><fieldProtheus>GI0_DESCRI</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>sigla</tagName><fieldProtheus>GI0_SIGLA</fieldProtheus><onlyInsert>True</onlyInsert><overwrite>True</overwrite></Field></ListOfFields></OrgaoConcedente></RJIntegra>'
EndIf

If !lAuto
	oRJIntegra:SetServico("OrgaoConcedente")
Else
	oRJIntegra:SetServico("OrgaoConcedente",,,cXmlAuto)
EndIf

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ000")

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

If oRJIntegra:Get(cResultAuto)
	GI0->(DbSetOrder(1))	// GI0_FILIAL+GI0_COD
	nTotReg := oRJIntegra:GetLenItens()	
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )

		For nX := 0 To nTotReg
			lContinua := .T.
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Órgãos Concedentes - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf
			
			If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idOrgao' ,'C'))
				cCode := GTPxRetId("TotalBus", "GI0", "GI0_COD", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GI0->(DbSeek(xFilial('GI0') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf
				
				If lContinua
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oMdlGI0	:= oModel:GetModel("GI0MASTER")

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

								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGI0:GetValue(cCampo)) 
									lContinua := oRJIntegra:SetValue(oMdlGI0, cCampo, xValor)
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
									lContinua := oRJIntegra:SetValue(oMdlGI0, cCampo, xValor)
								EndIf

								If !lContinua 
									oRJIntegra:oGTPLog:SetText(I18N(STR0003, {cCampo, GTPXErro(oModel)}))		// "Falha ao gravar o valor do campo #1 (#2)." 	
								EndIf
							EndIf
						Next nY
							
						If lContinua 
							If (lContinua := oModel:VldData())
								oModel:CommitData()
								CFGA070MNT("TotalBus", "GI0", "GI0_COD", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGI0:GetValue('GI0_COD'), 'GI0')))
							EndIf

							If !lContinua
								oRJIntegra:oGTPLog:SetText(I18N(STR0004, {GTPXErro(oModel)}))		// "Falha ao gravar os dados (#1)." 
							EndIf
						EndIf
						oModel:DeActivate()
					Else
						oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)}))		// "Falha ao corregar modelos de dados (#1)." 
						//DSERGTP-6567: Novo Log Rest RJ
						RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText()/*,oRJIntegra:GetResult("")*/)
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
		oMessage:SetText(STR0007)		// "Processo finalizado." 
		ProcessMessages()
	Else
		Alert(STR0007)		// "Processo finalizado."
	EndIf	
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGI0)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI000Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI000Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI000Job(aParam,lAuto)

Default lAuto := .F.
//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[1], aParam[2])

GTPIRJ000(.T.,lAuto)

RpcClearEnv()

Return
