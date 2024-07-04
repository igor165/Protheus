#Include "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ006.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ006

Adapter REST da rotina de AGÊNCIA

@type 		function
@sample 	GTPIRJ006()
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		25/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ006(lJob,lAuto, lMonit)

Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob := .F. 

If !lJob
	FwMsgRun( , {|oSelf| lRet := GI006Receb(lJob, oSelf,,lAuto,@lMonit)}, , STR0001)		// "Processando registros de Agência... Aguarde!" 
Else
	lRet := GI006Receb(lJob, nil,,lAuto)
EndIf

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI006Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI006Receb(cRestResult, oMessage)
@param 		oRJIntegra, objeto - classe que trata da integração
			oMessage, objeto   - trata a mensagem apresentada em tela
@return 	lRet, logical      - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		29/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI006Receb(lJob, oMessage, cEmpRJ, lAuto, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA006")
Local oMdlGI6	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GI6_FILIAL", "GI6_CODIGO"}
Local cIntID	  := ""
Local cIntAux	  := ""
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
Local nPos        := 0
Local nTotReg     := 0
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'

Default cEmpRJ    := oRJIntegra:GetEmpRJ(,,cEmpAnt, cFilAnt,,.T.)

cXmlAuto := '<?xml version="1.0" encoding="utf-8"?>'
cXmlAuto += "<RJIntegra>"
cXmlAuto += '	<Agencia tagMainList="agencia">'
cXmlAuto += "		<ListOfFields>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idAgencia</tagName>"
cXmlAuto += "				<fieldProtheus>GI6_CODIGO</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>descAgencia</tagName>"
cXmlAuto += "				<fieldProtheus>GI6_DESCRI</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>			"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idLocalidade</tagName>"
cXmlAuto += "				<fieldProtheus>GI6_LOCALI</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "				<DeParaXXF>"
cXmlAuto += "					<Alias>GI1</Alias>"
cXmlAuto += "					<XXF_Field>GI1_COD</XXF_Field>"
cXmlAuto += "					<ColumnNumber>3</ColumnNumber>"
cXmlAuto += "					<IndiceOrder>1</IndiceOrder>"
cXmlAuto += "					<ListOfSeekField>"
cXmlAuto += "						<SeekField>GI1_FILIAL</SeekField>"
cXmlAuto += "						<SeekField>GI1_COD</SeekField>"
cXmlAuto += "					</ListOfSeekField>"
cXmlAuto += "				</DeParaXXF>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>dataModificacao</tagName>"
cXmlAuto += "				<fieldProtheus>GI6_DTALT</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>descTipoAgenciaId</tagName>"
cXmlAuto += "				<fieldProtheus>GI5_CODIGO</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "				<DeParaXXF>"
cXmlAuto += "					<Alias>GI5</Alias>"
cXmlAuto += "					<XXF_Field>GI5_CODIGO</XXF_Field>"
cXmlAuto += "					<ColumnNumber>3</ColumnNumber>"
cXmlAuto += "					<IndiceOrder>1</IndiceOrder>"
cXmlAuto += "					<ListOfSeekField>"
cXmlAuto += "						<SeekField>GI5_FILIAL</SeekField>"
cXmlAuto += "						<SeekField>GI5_CODIGO</SeekField>"
cXmlAuto += "					</ListOfSeekField>"
cXmlAuto += "				</DeParaXXF>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>status</tagName>"
cXmlAuto += "				<fieldProtheus>GI6_MSBLQL</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>codigoAgencia</tagName>"
cXmlAuto += "				<fieldProtheus></fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>interFechamento</tagName>"
cXmlAuto += "				<fieldProtheus>GI6_FCHCAI</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName></tagName>"
cXmlAuto += "				<fieldProtheus>GI6_DIASFC</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>			"
cXmlAuto += "		</ListOfFields>"
cXmlAuto += "	</Agencia>"
cXmlAuto += "</RJIntegra>"

oRJIntegra:SetPath("/agencia")

If !lAuto
	oRJIntegra:SetServico("Agencia")
Else
	oRJIntegra:SetServico("Agencia",,,cXmlAuto)
EndIf

If !lAuto
	oRJIntegra:SetParam('empresa', ALLTRIM(cEmpRJ))
Else
	oRJIntegra:SetParam('empresa', ALLTRIM("10"))
EndIf

If lAuto
	cResultAuto := '{"agencia":[{"idAgencia":3992,"descAgencia":"FORTALEZA VIAGENS","idEmpresa":10,"idLocalidade":2063,"dataModificacao":"2018-02-05","descTipoAgencia":"PRESTACAO DE SERVICO","status":1,"codigoAgencia":"0700082035","tipoFechamento":"B","interFechamento":"Diario","descTipoAgenciaId":"13","numDocPuntoVenta":"11334495000292","numiePuntoVenta":"ISENTO","codPostal":"61000000","direccionCalle":"RUA JORGE DUMAR","direccionNumero":"2184B","comple":"","nombCiudad":"FORTALEZA","descColonia":"MONTESE"},{"idAgencia":3967,"descAgencia":"RODOVIARIA SOBRAL","idEmpresa":10,"idLocalidade":2201,"dataModificacao":"2021-04-07","descTipoAgencia":"PROPRIAS","status":1,"codigoAgencia":"0705148005","tipoFechamento":"B","interFechamento":"Diario","descTipoAgenciaId":"11","numDocPuntoVenta":"41550112000101","numiePuntoVenta":"","codPostal":"62011970","direccionCalle":"RUA DEP. JOAO ADEODATO TERM RODOVIARIO","direccionNumero":"505","comple":"BOX 19,20,21","nombCiudad":"SOBRAL","descColonia":"CENTRO"},{"idAgencia":1,"descAgencia":"CONTABILIDADE1","idEmpresa":10,"idLocalidade":5410,"dataModificacao":"2020-09-18","descTipoAgencia":"PROPRIAS","status":1,"codigoAgencia":"0800060000","tipoFechamento":"D","interFechamento":"Diario","descTipoAgenciaId":"11","numDocPuntoVenta":"41550112006053","numiePuntoVenta":"123456789","codPostal":"30494275","direccionCalle":"SIA TRECHO 1","direccionNumero":"247","comple":"COMPLEMENTO TESTE","nombCiudad":"BELO HORIZONTE","descColonia":"CENTRO"},{"idAgencia":496,"descAgencia":"ALFA TURISMO","idEmpresa":10,"idLocalidade":5410,"dataModificacao":"2021-04-07","descTipoAgencia":"TESTE 2","status":1,"codigoAgencia":"1500072004","tipoFechamento":"B","interFechamento":"Fora de range","descTipoAgenciaId":"16","numDocPuntoVenta":"01614829000147","numiePuntoVenta":"ISENTO","codPostal":"31310240","direccionCalle":"R.CONCEIÇÃO DO MATO DENTRO","direccionNumero":"173","comple":"E 175","nombCiudad":"BELO HORIZONTE","descColonia":"OURO/PRETO"},{"idAgencia":5264,"descAgencia":"OTTANER","idEmpresa":10,"idLocalidade":5410,"dataModificacao":"2021-03-31","descTipoAgencia":"PROPRIAS","status":1,"codigoAgencia":"13Ottan13","tipoFechamento":"D","interFechamento":"Diario","descTipoAgenciaId":"11","numDocPuntoVenta":"89.956.911/0001-09","numiePuntoVenta":"ISENTO","codPostal":"30660130","direccionCalle":"RUA OTTANER OLIVER","direccionNumero":"13","comple":"CASA","nombCiudad":"BELO HORIZONTE","descColonia":"BARREIRO DE BAIXO"},{"idAgencia":5824,"descAgencia":"J3","idEmpresa":10,"idLocalidade":5410,"dataModificacao":"2021-04-07","descTipoAgencia":"API","status":1,"codigoAgencia":"5541","tipoFechamento":"B","interFechamento":"Diario","descTipoAgenciaId":"19","numDocPuntoVenta":"","numiePuntoVenta":"","codPostal":"","direccionCalle":"BARÃO HOMEM DE MELO","direccionNumero":"4391","comple":"","nombCiudad":"BELO HORIZONTE","descColonia":"OUTRO PRETO"},{"idAgencia":5544,"descAgencia":"RODOVIARIA VESPAZIANO","idEmpresa":10,"idLocalidade":7485,"dataModificacao":"2019-10-21","descTipoAgencia":"PROPRIAS","status":1,"codigoAgencia":"1212","tipoFechamento":"B","interFechamento":"Diario","descTipoAgenciaId":"11","numDocPuntoVenta":"71.204.776/0001-71","numiePuntoVenta":"ISENTO","codPostal":"31111111","direccionCalle":"BARAO","direccionNumero":"11","comple":"AA","nombCiudad":"VESPASIANO","descColonia":"BETANIA"}]}'
EndIf

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ006")

If oRJIntegra:Get(cResultAuto)
	GI6->(DbSetOrder(1))	// GI6_FILIAL+GI6_CODIGO
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
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Agência - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf

			// para essa integraç?o é preciso localizar a filial. Caso n?o encontrada, pular para próximo item do JSON
			If Empty((cFilAux := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt, oRJIntegra:GetJsonValue(nX, 'idEmpresa', 'C'), , "2")))
				Loop
			Else
				cFilAnt := cFilAux
			EndIf	

			If !Empty((cExtID := oRJIntegra:GetJsonValue(nX, 'idAgencia', 'C'))) 
				cCode := GTPxRetId("TotalBus", "GI6", "GI6_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID)  
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GI6->(DbSeek(xFilial('GI6') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf

				If lContinua
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oMdlGI6 := oModel:GetModel("GI6MASTER")

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
								
								If cTagName == "descTipoAgenciaId"
									cCampo := 'GI6_TIPO'
									xValor := Posicione("GI5", 1, xFilial("GI5") + xValor, "GI5_TIPO")	 
								EndIf

								If cTagName == "interFechamento"
									cCampo := 'GI6_FCHCAI'

									if UPPER(xValor) == 'SEMANAL'
										oMdlGI6:LoadValue('GI6_FCHCAI', '2')
										oMdlGI6:LoadValue('GI6_DIASFC', 7)
									endif

									if UPPER(xValor) == 'DECENDIAL'
										oMdlGI6:LoadValue('GI6_FCHCAI', '2')
										oMdlGI6:LoadValue('GI6_DIASFC', 10)
									endif

									if UPPER(xValor) == 'QUINZENAL'
										oMdlGI6:LoadValue('GI6_FCHCAI', '2')
										oMdlGI6:LoadValue('GI6_DIASFC', 15)
									endif

									if UPPER(xValor) == 'MENSAL'
										oMdlGI6:LoadValue('GI6_FCHCAI', '2')
										oMdlGI6:LoadValue('GI6_DIASFC', 31)
									endif
								EndIf

								// para o campo GI6_MSBLQL é preciso realizar De/Para TAG enviada Status 0=Ativo e 1=Inativo
								If cCampo == "GI6_MSBLQL"
									xValor := IIF(xValor == "0", "1", "2")
								EndIf

								if cCampo != 'GI6_FCHCAI'
									If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGI6:GetValue(cCampo)) 
										lContinua := oRJIntegra:SetValue(oMdlGI6, cCampo, SUBSTR(xValor,0,TAMSX3(cCampo)[1]))
									ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
										lContinua := oRJIntegra:SetValue(oMdlGI6, cCampo, SUBSTR(xValor,0,TAMSX3(cCampo)[1]))
									EndIf
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
								CFGA070MNT("TotalBus", "GI6", "GI6_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGI6:GetValue('GI6_CODIGO'), 'GI6')))
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
GTPDestroy(oMdlGI6)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI006Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI006Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jacomo.fernandes
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI006Job(aParams, lAuto)

Default lAuto := .F.

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParams[1], aParams[2])

GTPIRJ006(.T., lAuto)

RpcClearEnv()

Return
