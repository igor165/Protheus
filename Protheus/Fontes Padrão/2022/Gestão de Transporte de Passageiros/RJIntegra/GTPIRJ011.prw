#Include "Protheus.ch"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ011.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ011

Adapter REST da rotina de CATEGORIAS DE LINHA

@type 		function
@sample 	GTPIRJ011(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	jacomo.fernandes
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ011(lJob,lAuto,lMonit)

Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob := .F. 
Default lAuto := .F. 

If !lJob
	FwMsgRun( , {|oSelf| lRet := GI011Receb(lJob, oSelf, lAuto, @lMonit)}, , STR0001)		// "Processando registros de Categorias de Linha... Aguarde!" 
Else
	lRet := GI011Receb(lJob, nil, lAuto)
EndIf
RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI011Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI011Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	jacomo.fernandes
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI011Receb(lJob, oMessage, lAuto, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA011")
Local oMdlGYR	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GYR_FILIAL", "GYR_CODIGO"}
Local cIntID	  := ""
Local cIntAux     := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local cXmlAuto    := ""
Local cResultAuto := ""
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

cXmlAuto := '<?xml version="1.0" encoding="utf-8"?>'
cXmlAuto += "<RJIntegra>"
cXmlAuto += '	<Classe tagMainList="classe">'
cXmlAuto += "		<ListOfFields>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idClasse</tagName>"
cXmlAuto += "				<fieldProtheus>GYR_CODIGO</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>descClasse</tagName>"
cXmlAuto += "				<fieldProtheus>GYR_DESCRI</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "		</ListOfFields>"
cXmlAuto += "	</Classe>"
cXmlAuto += "</RJIntegra>"

oRJIntegra:SetPath("/classe/todas")
If !lAuto
	oRJIntegra:SetServico("Classe")
Else
	oRJIntegra:SetServico("Classe",,,cXmlAuto)
EndIf

If lAuto
	cResultAuto := '{"classe":[{"idClasse":8,"descClasse":"CONVENCIONAL TESTE","modalidadeBpe":"1-CONVENCIONAL COM SANITÃRIO","dataModificacao":"2020-07-08","sigla":null},{"idClasse":21,"descClasse":"DD EXEC","modalidadeBpe":"6-EXECUTIVO","dataModificacao":"2018-04-18","sigla":null},{"idClasse":61,"descClasse":"TESTE 2 T","modalidadeBpe":"2-CONVENCIONAL SEM SANITÃRIO","dataModificacao":"2018-06-04","sigla":null},{"idClasse":82,"descClasse":"TESTE FRED","modalidadeBpe":"1-CONVENCIONAL COM SANITÃRIO","dataModificacao":"2018-05-24","sigla":null},{"idClasse":5,"descClasse":"CONVENCIONAL DIRETO","modalidadeBpe":"2-CONVENCIONAL SEM SANITÃRIO","dataModificacao":"2019-06-04","sigla":null},{"idClasse":6,"descClasse":"COMUM","modalidadeBpe":"2-CONVENCIONAL SEM SANITÃRIO","dataModificacao":"2018-04-18","sigla":null},{"idClasse":7,"descClasse":"DD LEITO","modalidadeBpe":"4-LEITO COM AR CONDICIONADO","dataModificacao":"2018-04-18","sigla":null},{"idClasse":-1,"descClasse":"TODAS","modalidadeBpe":"","dataModificacao":"2012-08-30","sigla":null},{"idClasse":3,"descClasse":"LEITO","modalidadeBpe":"4-LEITO COM AR CONDICIONADO","dataModificacao":"2019-06-04","sigla":null},{"idClasse":1,"descClasse":"CONVENCIONAL","modalidadeBpe":"1-CONVENCIONAL COM SANITÃRIO","dataModificacao":"2021-06-02","sigla":null},{"idClasse":2,"descClasse":"EXECUTIVO","modalidadeBpe":"6-EXECUTIVO","dataModificacao":"2019-06-04","sigla":null},{"idClasse":85,"descClasse":"EXECUTIVO SD","modalidadeBpe":"6-EXECUTIVO","dataModificacao":"2018-04-18","sigla":null},{"idClasse":86,"descClasse":"TESTE4","modalidadeBpe":"2-CONVENCIONAL SEM SANITÃRIO","dataModificacao":"2019-06-04","sigla":null},{"idClasse":9,"descClasse":"TTB CLASSE","modalidadeBpe":"1-CONVENCIONAL COM SANITÃRIO","dataModificacao":"2019-06-04","sigla":null},{"idClasse":10,"descClasse":"SUPER EXECUTIVO - ALAIR","modalidadeBpe":"6-EXECUTIVO","dataModificacao":"2020-01-30","sigla":null},{"idClasse":11,"descClasse":"CAMA","modalidadeBpe":"10","dataModificacao":"2020-09-23","sigla":null},{"idClasse":14,"descClasse":"TESTEAA","modalidadeBpe":"1-CONVENCIONAL COM SANITÃRIO","dataModificacao":"2021-04-12","sigla":null}]}'
EndIf

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ011")

If oRJIntegra:Get(cResultAuto)
	GYR->(DbSetOrder(1))	// GYR_FILIAL+GYR_CODIGO
	nTotReg := oRJIntegra:GetLenItens()	
	//Necessário para a automação não efetuar todos os registros de uma vez
	If lAuto
		nTotReg := 1
	EndIf

	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )

		For nX := 0 To nTotReg
			lContinua := .T.
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Categorias de Linha - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf
			
			If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idClasse' ,'C'))
				cCode := GTPxRetId("TotalBus", "GYR", "GYR_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GYR->(DbSeek(xFilial('GYR') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf
				
				If lContinua
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oMdlGYR	:= oModel:GetModel("GYRMASTER")

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

								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGYR:GetValue(cCampo)) 
									lContinua := oRJIntegra:SetValue(oMdlGYR, cCampo, xValor)
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
									lContinua := oRJIntegra:SetValue(oMdlGYR, cCampo, xValor)
								EndIf

								If !lContinua 
									oRJIntegra:oGTPLog:SetText(I18N(STR0003, {cCampo, GTPXErro(oModel)}))		// "Falha ao gravar o valor do campo #1 (#2)." 
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
								CFGA070MNT("TotalBus", "GYR", "GYR_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGYR:GetValue('GYR_CODIGO'), 'GYR')))
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
		oMessage:SetText(STR0007)		// "Processo finalizado." 
		ProcessMessages()
	Else
		Alert(STR0007)		// "Processo finalizado."
	EndIf	
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGYR)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI011Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI011Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jacomo.fernandes
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI011Job(aParam,lAuto)

Default lAuto := .F.
//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[1], aParam[2])

GTPIRJ011(.T.,lAuto)

RpcClearEnv()

Return
