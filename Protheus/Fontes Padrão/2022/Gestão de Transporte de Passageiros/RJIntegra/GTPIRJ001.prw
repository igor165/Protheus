#INCLUDE "PROTHEUS.CH"                
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ001.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ001

Adapter REST da rotina de LOCALIDADE

@type 		function
@sample 	GTPIRJ001(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		25/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ001(lJob,lAuto,lMonit,lNoAsk)

Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob 	:= .F. 
Default lAuto 	:= .F.
Default lNoAsk	:= .F.

If !lJob .and. ( !lNoAsk .And. FwAlertYesNo(STR0001) )		// "Para integrar as Localidades é preciso integrar Estados e Cidades. Deseja realizar a integração?"
	GTPIRJA001(.F.)	// Estado
	GTPIRJB001(.F.)	// Cidades
EndIf		 

If !lJob
	FwMsgRun( , {|oSelf| lRet := GI001Receb(lJob, oSelf, lAuto, @lMonit)}, , STR0002)		// "Processando registros de Localidades... Aguarde!" 
Else
	lRet := GI001Receb(lJob, nil,lAuto)
EndIf
RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI001Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI001Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		29/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI001Receb(lJob, oMessage, lAuto, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA001")
Local oMdlGI1	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GI1_FILIAL", "GI1_COD"}
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

cXmlAuto := '<?xml version="1.0" encoding="utf-8"?>'
cXmlAuto += "<RJIntegra>"
cXmlAuto += '	<Localidade tagMainList="localidade">'
cXmlAuto += "		<ListOfFields>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idLocalidade</tagName>"
cXmlAuto += "				<fieldProtheus>GI1_COD</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>descLocalidade</tagName>"
cXmlAuto += "				<fieldProtheus>GI1_DESCRI</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>codigoLocalidade</tagName>"
cXmlAuto += "				<fieldProtheus>GI1_CODINT</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>dataModificacao</tagName>"
cXmlAuto += "				<fieldProtheus>GI1_DTALT</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idCidade</tagName>"
cXmlAuto += "				<fieldProtheus>GI1_CDMUNI</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "				<DeParaXXF>"
cXmlAuto += "					<Alias>CC2</Alias>"
cXmlAuto += "					<XXF_Field>CC2_CODMUN</XXF_Field>"
cXmlAuto += "					<ColumnNumber>3</ColumnNumber>"
cXmlAuto += "					<IndiceOrder>1</IndiceOrder>"
cXmlAuto += "					<ListOfSeekField>"
cXmlAuto += "						<SeekField>CC2_FILIAL</SeekField>"
cXmlAuto += "						<SeekField>CC2_EST</SeekField>"
cXmlAuto += "						<SeekField>CC2_CODMUN</SeekField>"
cXmlAuto += "					</ListOfSeekField>"
cXmlAuto += "				</DeParaXXF>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>codigoAntt</tagName>"
cXmlAuto += "				<fieldProtheus></fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>tipoLocalidadeID</tagName>"
cXmlAuto += "				<fieldProtheus>GI1_CODTIP</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "				<DeParaXXF>"
cXmlAuto += "					<Alias>G9V</Alias>"
cXmlAuto += "					<XXF_Field>G9V_CODIGO</XXF_Field>"
cXmlAuto += "					<ColumnNumber>3</ColumnNumber>"
cXmlAuto += "					<IndiceOrder>1</IndiceOrder>"
cXmlAuto += "					<ListOfSeekField>"
cXmlAuto += "						<SeekField>G9V_FILIAL</SeekField>"
cXmlAuto += "						<SeekField>G9V_CODIGO</SeekField>"
cXmlAuto += "					</ListOfSeekField>"
cXmlAuto += "				</DeParaXXF>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>codigoIBGE</tagName>"
cXmlAuto += "				<fieldProtheus>GI1_IBGE</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>cveEstado</tagName>"
cXmlAuto += "				<fieldProtheus>GI1_UF</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "		</ListOfFields>"
cXmlAuto += "	</Localidade>"
cXmlAuto += "</RJIntegra>"

oRJIntegra:SetPath("/localidade/todas")

oRJIntegra:SetServico('Localidade')

If !lAuto
	oRJIntegra:SetServico("Localidade")
Else
	oRJIntegra:SetServico("Localidade",,,cXmlAuto)
EndIf

If lAuto
	cResultAuto := '{"localidade":[{"idLocalidade":2,"descLocalidade":"RIO BRANCO - AC","tipoLocalidade":"EMBARQUE-DESEMBARQUE","tipoLocalidadeID":1,"codigoLocalidade":"RBO","dataModificacao":"2018-12-05","idCidade":2,"codigoAntt":62,"codigoIBGE":1200401},{"idLocalidade":3,"descLocalidade":"BUJARI - AC","tipoLocalidade":"EMBARQUE-DESEMBARQUE","tipoLocalidadeID":1,"codigoLocalidade":"BJRI","dataModificacao":"2018-12-05","idCidade":3,"codigoAntt":88,"codigoIBGE":1200138}]}'
EndIf

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ001")

If oRJIntegra:Get(cResultAuto) 
	GI1->(DbSetOrder(1))	// GI1_FILIAL+GI1_COD
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
				oMessage:SetText(I18N(STR0003, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de localidades - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf

			If !Empty((cExtID := oRJIntegra:GetJsonValue(nX, 'idLocalidade', 'C'))) 
				cCode := GTPxRetId("TotalBus", "GI1", "GI1_COD", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID)  
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GI1->(DbSeek(xFilial('GI1') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf

				If lContinua
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oMdlGI1 := oModel:GetModel("GI1MASTER")

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

								// se ao preencher o código do municipio os códigos de UF e PAIS estiverem vazios é preciso preenche-los 
								If cCampo == "GI1_CDMUNI" 
									
									cRetMun := RetMun(oRJIntegra:GetJsonValue(nX, "idCidade", "C"))
									cEstado := oRJIntegra:GetJsonValue(nX, "cveEstado", "C")	

									CC2->(dbSetOrder(1)) //CC2_FILIAL, CC2_EST, CC2_MUN, R_E_C_N_O_, D_E_L_E_T_
									
									If CC2->(dbSeek(xFilial('CC2')+cEstado+cRetMun))
										oMdlGI1:LoadValue("GI1_PAIS",'105')
									Else
										oMdlGI1:LoadValue("GI1_PAIS",'999')
									Endif										

									oMdlGI1:LoadValue("GI1_CDMUNI", ALLTRIM(cRetMun))
								EndIf
								If cCampo != "GI1_CDMUNI"
									If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGI1:GetValue(cCampo)) 
										lContinua := oRJIntegra:SetValue(oMdlGI1, cCampo, xValor)
									ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
										lContinua := oRJIntegra:SetValue(oMdlGI1, cCampo, xValor)
									EndIf
								EndIf

								If !lContinua 
									oRJIntegra:oGTPLog:SetText(I18N("Falha ao gravar o valor #2 do campo #1, da Localidade #4 (#3).", {cCampo,xValor, GTPXErro(oModel),cExtID}))		// "Falha ao gravar o valor do campo #1 (#2)." 	
								EndIf
							EndIf
						Next nY
						
						If lContinua 
							If (lContinua := oModel:VldData()) 
								oModel:CommitData()
								CFGA070MNT("TotalBus", "GI1", "GI1_COD", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGI1:GetValue('GI1_COD'), 'GI1')))
							Else							
								oRJIntegra:oGTPLog:SetText(I18N("Falha ao validar os dados da Localidade #2 (#1).", {GTPXErro(oModel),cExtID,cIntId}))		// "Falha ao gravar os dados (#1)." 
							EndIf
						EndIf
						oModel:DeActivate()
					Else
						oRJIntegra:oGTPLog:SetText(I18N("Falha ao corregar modelos de dados da Localidade #2 (#1)." , {GTPXErro(oModel),cExtID}))
						lContinua := .F.
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
		oMessage:SetText(STR0008)		// "Processo finalizado." 
		ProcessMessages()
	Else
		Alert(STR0008)		// "Processo finalizado."
	EndIf	
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGI1)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

/*/{Protheus.doc} RetMun
	(long_description)
	@type  Static Function
	@author user
	@since 31/08/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RetMun(uValor)
	Local cCodMun := ""
	Local aCodMun := {}
	Local cAliasTmp	:= GetNextAlias()

	BeginSql Alias cAliasTmp

		SELECT XXF_INTVAL INTVAL
		FROM XXF 
		WHERE XXF_ALIAS = 'CC2'
			AND UPPER(XXF_REFER) = 'TOTALBUS' 
			AND XXF_EXTVAL = %Exp:uValor% 
			AND %NotDel%

	EndSql

	If !(Empty((cAliasTmp)->INTVAL))
		aCodMun := STRTOKARR2((cAliasTmp)->INTVAL,"|",.T.)
		cCodMun := ALLTRIM(aCodMun[LEN(aCodMun)])
	Endif

	(cAliasTmp)->(dbCloseArea())
Return cCodMun

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI001Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI001Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jacomo.fernandes
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI001Job(aParams,lAuto)

Default lAuto := .F.
//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParams[1], aParams[2])

GTPIRJ001(.T.,lAuto)

RpcClearEnv()

Return
