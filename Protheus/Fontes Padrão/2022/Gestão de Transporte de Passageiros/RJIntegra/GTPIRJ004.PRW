#INCLUDE "PROTHEUS.CH"                
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ004

Adapter REST da rotina de Horarios/Serviços 

@type 		function
@sample 	GTPIRJ004(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		06/05/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ004(lJob, lAuto, aParams, lMonit)

Local aArea  := GetArea() 
Local lRet   := .T.
Local cEmpRJ  := nil
Local dDtIni  := nil
Local cHrIni  := nil
Local dDtFim  := nil
Local cHrFim  := nil

Default lJob := .F. 
Default lAuto := .F.
Default aParams	:= {}

If !lJob

	If ( Len(aParams) == 0 )

		If Pergunte('GTPIRJ004',!lJob)

			cEmpRJ  := MV_PAR01
			dDtIni  := MV_PAR02
			cHrIni  := MV_PAR03
			dDtFim  := MV_PAR04
			cHrFim  := MV_PAR05 
			
			lRet := .T.
		
		Else
			lRet := .F.
		EndIf
	
	Else

		cEmpRJ  := aParams[1]
		dDtIni  := aParams[2]
		cHrIni  := aParams[3]
		dDtFim  := aParams[4]
		cHrFim  := aParams[5] 

	EndIf

	If ( lRet )
		FwMsgRun( , {|oSelf| lRet := GI004Receb(lJob, oSelf,cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim,lAuto,@lMonit)}, , "Processando registros de Horários/Serviço... Aguarde!")  
	EndIf	
		
Else
	Pergunte('GTPIRJ004',.F.)
	lRet := GI004Receb(lJob, oSelf,cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim,lAuto)
EndIf

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI004Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI004Receb(cXml, lRet)
@param 		cXml, characters, Xml passado pela função do IntegDef
			lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return 	cXMLRet, characters, String contendo o xml de envio
@author 	jacomo.fernandes
@since 		15/02/2017
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI004Receb(lJob, oMessage,cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, lAuto, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA004")
Local oMdlGID	  := Nil
Local oMdlGIE     := Nil
Local aFldsGID    := {}
Local aDPXXFGID   := {}
Local aFldsGIE    := {}
Local aDPXXFGIE   := {}
Local aGIEValues  := {}
Local cIntID	  := ""
Local cIntAux	  := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local cSequencia  := ""
Local cFilAux     := ""
Local cFrequenc   := ""
Local cStatus     := ""
Local cXmlAuto    := ""
Local cResultAuto := ""
Local cFilBkp     := cFilAnt 
Local nW          := 0
Local nX          := 0
Local nY          := 0
Local nZ          := 0
Local nOpc		  := 0
Local nTotReg     := 0
Local nTotGIE     := 0
Local nPos        := 0
Local nPosTrechos := 0
Local nCont       := 0
Local nSequencia  := 0
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local aAux        := {}
Local lMessage	  := ValType(oMessage) == 'O'

cXmlAuto := '<?xml version="1.0" encoding="utf-8"?>'
cXmlAuto += "<RJIntegra>"
cXmlAuto += '	<Servico tagMainList="servico">'
cXmlAuto += "		<ListOfFields>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idServico</tagName>"
cXmlAuto += "				<fieldProtheus>GID_COD</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idLinha</tagName>"
cXmlAuto += "				<fieldProtheus>GID_LINHA</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "                <DeParaXXF>"
cXmlAuto += "					<Alias>GI2</Alias>"
cXmlAuto += "					<XXF_Field>GI2_COD</XXF_Field>"
cXmlAuto += "					<ColumnNumber>3</ColumnNumber>"
cXmlAuto += "					<IndiceOrder>1</IndiceOrder>"
cXmlAuto += "					<ListOfSeekField>"
cXmlAuto += "						<SeekField>GI2_FILIAL</SeekField>"
cXmlAuto += "						<SeekField>GI2_COD</SeekField>"
cXmlAuto += "					</ListOfSeekField>"
cXmlAuto += "				</DeParaXXF>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>horaInicio</tagName>"
cXmlAuto += "				<fieldProtheus>GID_HORCAB</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "            <Field>"
cXmlAuto += "				<tagName>dataSaida</tagName>"
cXmlAuto += "				<fieldProtheus>GID_INIVIG</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "            <Field>"
cXmlAuto += "				<tagName>dataChegada</tagName>"
cXmlAuto += "				<fieldProtheus>GID_FINVIG</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>frequencia</tagName>"
cXmlAuto += "				<fieldProtheus>GID_SEG</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>numeroServico</tagName>"
cXmlAuto += "				<fieldProtheus>GID_NUMSRV</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>statusT</tagName>"
cXmlAuto += "				<fieldProtheus>GID_STATUS</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>feriados</tagName>"
cXmlAuto += "				<fieldProtheus>GID_FER</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>sentidoIda</tagName>"
cXmlAuto += "				<fieldProtheus>GID_SENTID</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>dataHoraModificacaoT</tagName>"
cXmlAuto += "				<fieldProtheus>GID_DTALT</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>statusCorrida</tagName>"
cXmlAuto += "				<fieldProtheus>GID_MSBLQL</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "		</ListOfFields>"
cXmlAuto += '		<Trechos tagMainList="trechos">'
cXmlAuto += "			<ListOfFields>"
cXmlAuto += "				<Field>"
cXmlAuto += "					<tagName>idTrecho</tagName>"
cXmlAuto += "					<fieldProtheus>GIE_COD</fieldProtheus>"
cXmlAuto += "					<onlyInsert>True</onlyInsert>"
cXmlAuto += "					<overwrite>False</overwrite>"
cXmlAuto += "				</Field>"
cXmlAuto += "				<Field>"
cXmlAuto += "					<tagName>sequencia</tagName>"
cXmlAuto += "					<fieldProtheus>GIE_SEQ</fieldProtheus>"
cXmlAuto += "					<onlyInsert>False</onlyInsert>"
cXmlAuto += "					<overwrite>True</overwrite>"
cXmlAuto += "				</Field>"
cXmlAuto += "				<Field>"
cXmlAuto += "					<tagName>origemID</tagName>"
cXmlAuto += "					<fieldProtheus>GIE_IDLOCP</fieldProtheus>"
cXmlAuto += "					<onlyInsert>False</onlyInsert>"
cXmlAuto += "					<overwrite>True</overwrite>"
cXmlAuto += "					<DeParaXXF>"
cXmlAuto += "						<Alias>GI1</Alias>"
cXmlAuto += "						<XXF_Field>GI1_COD</XXF_Field>"
cXmlAuto += "						<ColumnNumber>3</ColumnNumber>"
cXmlAuto += "						<IndiceOrder>1</IndiceOrder>"
cXmlAuto += "						<ListOfSeekField>"
cXmlAuto += "							<SeekField>GI1_FILIAL</SeekField>"
cXmlAuto += "							<SeekField>GI1_COD</SeekField>"
cXmlAuto += "						</ListOfSeekField>"
cXmlAuto += "					</DeParaXXF>"
cXmlAuto += "				</Field>"
cXmlAuto += "                <Field>"
cXmlAuto += "					<tagName>destinoID</tagName>"
cXmlAuto += "					<fieldProtheus>GIE_IDLOCD</fieldProtheus>"
cXmlAuto += "					<onlyInsert>False</onlyInsert>"
cXmlAuto += "					<overwrite>True</overwrite>"
cXmlAuto += "					<DeParaXXF>"
cXmlAuto += "						<Alias>GI1</Alias>"
cXmlAuto += "						<XXF_Field>GI1_COD</XXF_Field>"
cXmlAuto += "						<ColumnNumber>3</ColumnNumber>"
cXmlAuto += "						<IndiceOrder>1</IndiceOrder>"
cXmlAuto += "						<ListOfSeekField>"
cXmlAuto += "							<SeekField>GI1_FILIAL</SeekField>"
cXmlAuto += "							<SeekField>GI1_COD</SeekField>"
cXmlAuto += "						</ListOfSeekField>"
cXmlAuto += "					</DeParaXXF>"
cXmlAuto += "				</Field>"
cXmlAuto += "				<Field>"
cXmlAuto += "					<tagName>horaIncio</tagName>"
cXmlAuto += "					<fieldProtheus>GIE_HORLOC</fieldProtheus>"
cXmlAuto += "					<onlyInsert>True</onlyInsert>"
cXmlAuto += "					<overwrite>False</overwrite>"
cXmlAuto += "				</Field>"
cXmlAuto += "				<Field>"
cXmlAuto += "					<tagName>horaFinal</tagName>"
cXmlAuto += "					<fieldProtheus>GIE_HORDES</fieldProtheus>"
cXmlAuto += "					<onlyInsert>False</onlyInsert>"
cXmlAuto += "					<overwrite>True</overwrite>"
cXmlAuto += "				</Field>"
cXmlAuto += "				<Field>"
cXmlAuto += "					<tagName>via</tagName>"
cXmlAuto += "					<fieldProtheus>GIE_VIA</fieldProtheus>"
cXmlAuto += "					<onlyInsert>False</onlyInsert>"
cXmlAuto += "					<overwrite>True</overwrite>"
cXmlAuto += "				</Field>  "
cXmlAuto += "				<Field>"
cXmlAuto += "					<tagName>tempoTrecho</tagName>"
cXmlAuto += "					<fieldProtheus>GIE_TPTR</fieldProtheus>"
cXmlAuto += "					<onlyInsert>False</onlyInsert>"
cXmlAuto += "					<overwrite>True</overwrite>"
cXmlAuto += "				</Field>"
cXmlAuto += "                <Field>"
cXmlAuto += "					<tagName>tempoExcecao</tagName>"
cXmlAuto += "					<fieldProtheus>GIE_TEMPO</fieldProtheus>"
cXmlAuto += "					<onlyInsert>False</onlyInsert>"
cXmlAuto += "					<overwrite>True</overwrite>"
cXmlAuto += "				</Field>    "
cXmlAuto += "			</ListOfFields>	"
cXmlAuto += "		</Trechos>"
cXmlAuto += "	</Servico>"
cXmlAuto += "</RJIntegra>"

oRJIntegra:SetPath("/servico")

oRJIntegra:SetParam('empresa'		 , ALLTRIM(cEmpRJ))
oRJIntegra:SetParam('dataInicial', SubStr(DtoS(dDtIni), 3,8) + STRTRAN(cHrIni,":",""))
oRJIntegra:SetParam('dataFinal'	 , SubStr(DtoS(dDtFim), 3,8) + STRTRAN(cHrFim,":",""))

// recuperando as informações do XML de controle da LINHA
If !lAuto
	oRJIntegra:SetServico("Servico")
Else
	oRJIntegra:SetServico("Servico",,,cXmlAuto)
EndIf

aFldsGID  := aClone(oRJIntegra:GetFieldDePara())
aDPXXFGID := aClone(oRJIntegra:GetFldXXF())

// recuperando as informações do XML de controle dos TRECHOS
If !lAuto
	oRJIntegra:SetServico("Servico/Trechos",.T.)
Else
	oRJIntegra:SetServico("Servico/Trechos",.T.,,cXmlAuto)
EndIf

aFldsGIE  := aClone(oRJIntegra:GetFieldDePara())
aDPXXFGIE := aClone(oRJIntegra:GetFldXXF())

If !lAuto
	oRJIntegra:SetServico("Servico")
Else
	oRJIntegra:SetServico("Servico",,,cXmlAuto)
EndIf

If lAuto
	cResultAuto := '{"linha":[{"idLinha":213,"descLinha":"UBERABA X SANTOS 20089","idClasse":1,"dataModificacao":"2018-03-19","idOrgaoConcedente":3,"prefixo":"06033801","tributaTarifa":1,"tributaTEmbarque":0,"tributaPedagio":0,"codigoLinha":"20089","idEmpresa":10,"trechos":{"trecho":[{"idTrecho":35965,"sequencia":1,"indVenda":null,"origemID":"7451","destinoID":"19249","descOrigem":"URA","origemIBGE":null,"descDestino":"IGA","destinoIBGE":null,"kmReal":"16","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null},{"idTrecho":35983,"sequencia":2,"indVenda":null,"origemID":"19249","destinoID":"19248","descOrigem":"IGA","origemIBGE":null,"descDestino":"AMI","destinoIBGE":null,"kmReal":"9","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null},{"idTrecho":36000,"sequencia":3,"indVenda":null,"origemID":"19248","destinoID":"19247","descOrigem":"AMI","origemIBGE":null,"descDestino":"ITV","destinoIBGE":null,"kmReal":"27","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null}]}}]}'
EndIf

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ004")

If oRJIntegra:Get(cResultAuto)
	GID->(DbSetOrder(1))	// GI2_FILIAL+GI2_COD+GI2_VIA
	GIE->(DbSetOrder(3))	// G5I_FILIAL+G5I_CODLIN+G5I_LOCALI	
	nTotReg := oRJIntegra:GetLenItens()
	//Necessário para a automação não efetuar todos os registros de uma vez
	If lAuto
		nTotReg := 1
	EndIf
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)
	
	If ( nTotReg >= 0 )

		//nTotReg := IIf(nTotReg > 99, 99, nTotReg)	//TODO: Arrancar esta linha daqui

		For nW := 0 To nTotReg
			lContinua  := .T.
			aGIEValues := {}

			If lMessage .And. !lJob
				oMessage:SetText(I18N("Processando registros de Horários/Serviço - #1/#2... Aguarde!" , {cValtoChar(nW + 1), nTotReg + 1}))
				ProcessMessages()
			EndIf

			// para essa integração é preciso localizar a filial. Caso não encontrada, pular para próximo item do JSON
			If Empty((cFilAux := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt, oRJIntegra:GetJsonValue(nW, 'idEmpresa', 'C'), , "2")))
				Loop
			Else
				cFilAnt := cFilAux
			EndIf		

			oRJIntegra:aFldDePara := aFldsGID
			oRJIntegra:aFldXXF    := aDPXXFGID 

			If !Empty((cExtID := oRJIntegra:GetJsonValue(nW, 'idServico', 'C', 'servico'))) .And. oRJIntegra:GetJsonValue(nW, 'idLinha', 'C', 'servico') == '1208'
				cCode := GTPxRetId("TotalBus", "GID", "GID_COD", cExtID, @cIntID, 3, @lOk, @cErro, {"GID_FILIAL", "GID_COD"}, 1)
				If Empty(cIntID)  
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GI2->(DbSeek(xFilial('GID') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf

				If lContinua
					oModel:SetOperation(nOpc)
					
					If oModel:Activate()
						oMdlGID := oModel:GetModel('GIDMASTER')
						oMdlGIE := oModel:GetModel('GIEDETAIL')

						// recuperando a TAG e o respectivo campo da tabela GID
						For nX := 1 To Len(aFldsGID)
							cTagName    := aFldsGID[nX][1] 
							cCampo      := aFldsGID[nX][2]
							cTipoCpo    := aFldsGID[nX][3]
							lOnlyInsert := aFldsGID[nX][6]
							lOverWrite  := aFldsGID[nX][7]
							
							If cTagName $ "frequencia"
								cFrequenc := oRJIntegra:GetJsonValue(nW, cTagName, "C", 'servico')
								For nCont := 1 To Len(cFrequenc)
									If SUBSTR(cFrequenc, nCont, 1) == "|" .AND. SUBSTR(cFrequenc, nCont+1, 1) == "X"
										aadd(aAux,"X")
									ElseIf SUBSTR(cFrequenc, nCont, 1) == "|" .AND. SUBSTR(cFrequenc, nCont+1, 1) == "|"
										aadd(aAux,"Y")
									EndIf
								Next
								If LEN(aAux) == 7
									If aAux[1] == "X"
										lContinua := oMdlGID:LoadValue("GID_SEG", .T.)
									EndIf
									IF aAux[2] == "X"
										lContinua := oMdlGID:LoadValue("GID_TER", .T.)
									EndIf
									IF aAux[3] == "X"
										lContinua := oMdlGID:LoadValue("GID_QUA", .T.)
									EndIf
									IF aAux[4] == "X"
										lContinua := oMdlGID:LoadValue("GID_QUI", .T.)
									EndIf
									IF aAux[5] == "X"
										lContinua := oMdlGID:LoadValue("GID_SEX", .T.)
									EndIf
									IF aAux[6] == "X"
										lContinua := oMdlGID:LoadValue("GID_SAB", .T.)
									EndIf
									IF aAux[7] == "X"
										lContinua := oMdlGID:LoadValue("GID_DOM", .T.)
									EndIf
								EndIf
							EndIf
							
							If cTagName $ "statusT|statusCorrida|feriados"
								cStatus := oRJIntegra:GetJsonValue(nW, cTagName, "C", 'servico')
							EndIf

							// recuperando através da TAG o valor a ser inserido no campo 
							If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nW, cTagName, cTipoCpo, 'servico')))
								
								// verificando a necessidade de realizar o DePara XXF
								If (nPos := aScan(aDPXXFGID, {|x| x[1] == cCampo})) > 0
									xValor := GTPxRetId("TotalBus", aDPXXFGID[nPos, 2], aDPXXFGID[nPos, 3], xValor, @cIntAux, aDPXXFGID[nPos, 4], @lOk, @cErro, aDPXXFGID[nPos, 6], aDPXXFGID[nPos, 5])
								EndIf
								If cTagName $ "horaInicio"
									xValor := STRTRAN( xValor, ":", "") 
								EndIf
								If cTagName $ "sentidoIda"
									xValor := IIF(xValor=="0","1","2")
								EndIf
								If cCampo $ "GID_STATUS|GID_MSBLQL"
									xValor := IIF(cStatus=="Ativo","2","1")
								EndIf
								If cCampo $ "GID_FER"
									xValor := IIF(cStatus!="1",.F.,.T.)
								EndIf
								
								If !(cTagName $ "frequencia")
									If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGID:GetValue(cCampo)) 
										lContinua := oRJIntegra:SetValue(oMdlGID, cCampo, xValor, lOverWrite)
									ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. nOpc <> MODEL_OPERATION_INSERT 
										lContinua := oRJIntegra:SetValue(oMdlGID, cCampo, xValor, lOverWrite)
									EndIf
								EndIf
								If !lContinua 
									oRJIntegra:oGTPLog:SetText(I18N("Falha ao gravar o valor do campo #1 (#2)."  , {cCampo, GTPXErro(oModel)}))		// 
									Exit	
								EndIf
							EndIf
						Next nX
						
						// recuperando a TAG e o respectivo campo da tabela G5I (Trechos) 
						If lContinua .And. (nPosTrechos := aScan(oRJIntegra:aResult[1][2][1][2][nW + 1][2], {|x| x[1] == "trechos"})) > 0 						
							nTotGIE := Len(oRJIntegra:aResult[1][2][1][2][nW + 1][2][nPosTrechos + 1][2][1][2]) - 1
							
							// populando o array com os valores a serem gravados na tabela G5I
							oRJIntegra:aFldDePara := aFldsGIE
							oRJIntegra:aFldXXF    := aDPXXFGIE 
							For nY := 0 To nTotGIE
								cSequencia := oRJIntegra:GetJsonValue(nY, 'sequencia', 'C', 'servico[' + cValToChar(nW) + '].trechos.trecho')
								aAdd(aGIEValues, {Replicate('0', TamSX3("GIE_SEQ")[1] - LEN(cSequencia)) + RTrim(LTrim(cSequencia))})
							
								For nZ := 1 To Len(aFldsGIE)
									xValor      := ""
									cTagName    := aFldsGIE[nZ][1] 
									cCampo      := aFldsGIE[nZ][2]
									cTipoCpo    := aFldsGIE[nZ][3]
									lOnlyInsert := aFldsGIE[nZ][6]
									lOverWrite  := aFldsGIE[nZ][7]
									
									// recuperando através da TAG o valor a ser inserido no campo 
									If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nY, cTagName, cTipoCpo, 'servico[' + cValToChar(nW) + '].trechos.trecho')))
										
										// verificando a necessidade de realizar o DePara XXF
										If (nPos := aScan(aDPXXFGIE, {|x| x[1] == cCampo})) > 0
											xValor := GTPxRetId("TotalBus", aDPXXFGIE[nPos, 2], aDPXXFGIE[nPos, 3], xValor, @cIntAux, aDPXXFGIE[nPos, 4], @lOk, @cErro, aDPXXFGIE[nPos, 6], aDPXXFGIE[nPos, 5])
										EndIf
										
										aAdd(aGIEValues[nY + 1], {{cCampo, xValor, lOnlyInsert, lOverWrite}})
									EndIf
								Next nZ
							Next nY

							aSort(aGIEValues, , , {|x, y| x[1] < y[1]})
						
							For nY := 1 To Len(aGIEValues)
								
								For nZ := 1 To Len(aGIEValues[nY])
									
									If ValType(aGIEValues[nY][nZ]) == "A"
										cCampo      := aGIEValues[nY][nZ][1][1] 
										xValor      := aGIEValues[nY][nZ][1][2]
										lOnlyInsert := aGIEValues[nY][nZ][1][3]
										lOverWrite  := aGIEValues[nY][nZ][1][4]
										If cCampo == "GIE_SEQ"
											nSequencia  := nSequencia + 1
										EndIf
										If cCampo $ "GIE_HORLOC|GIE_HORDES"
											xValor := STRTRAN( xValor, ":", "")
										EndIf
										If cCampo $ "GIE_TPTR|GIE_TEMPO"//"1970-01-01 01:00:00.0"
											xValor := STRTRAN(SUBSTR(xValor,12,5), ":", "")
										EndIf
										If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGIE:GetValue(cCampo)) 
											lContinua := oRJIntegra:SetValue(oMdlGIE, cCampo, IIF(cCampo != "GIE_SEQ", xValor, 	Replicate('0', TamSx3('GIE_SEQ')[1] - Len(cValtoChar(nSequencia))) + RTrim(LTrim(cValtoChar(nSequencia)))))
										ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
											lContinua := oRJIntegra:SetValue(oMdlGIE, cCampo, IIF(cCampo != "GIE_SEQ", xValor, 	Replicate('0', TamSx3('GIE_SEQ')[1] - Len(cValtoChar(nSequencia))) + RTrim(LTrim(cValtoChar(nSequencia)))))
										EndIf

										If !lContinua 
											oRJIntegra:oGTPLog:SetText(I18N("Falha ao gravar o valor do campo #1 (#2)."  , {cCampo, GTPXErro(oModel)})) 
											Exit	
										EndIf
										
									EndIf
								Next nZ
								
								If lContinua .And. oMdlGIE:VldLineData(.F.) .And. (nY + 1) <= nTotGIE
									oMdlGIE:SetNoInsertLine(.F.)
									oMdlGIE:AddLine()
								Else
									Exit
								EndIf 
							Next nY
						EndIf 
																											
						If !lContinua 
							//DSERGTP-6567: Novo Log Rest RJ
							RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText()/*,oRJIntegra:GetResult("")*/)
							Exit
						Else
							If (lContinua := oModel:VldData())
								oModel:CommitData()
								nSequencia := 0
								aAux       := {}
								cFrequenc  := ""
								CFGA070MNT("TotalBus", "GID", "GID_COD", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGID:GetValue('GID_COD'), 'GID')))
							Else							
								oRJIntegra:oGTPLog:SetText(I18N("Falha ao gravar os dados (#1) (#2)."  , {GTPXErro(oModel),cExtID}))		// 
							EndIf
						EndIf
						oModel:DeActivate()
					Else
						oRJIntegra:oGTPLog:SetText(I18N("Falha ao corregar modelos de dados (#1) (#2)."  , {GTPXErro(oModel),cExtID}))
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

		Next nW

	Else
		lMonit := .F.	//Precisará efetuar o disarmTransaction
		FwAlertHelp("Não há dados a serem processados com a parametrização utilizada.")
	EndIf

Else
	oRJIntegra:oGTPLog:SetText(I18N("Falha ao processar o retorno do serviço (#1)."  , {oRJIntegra:GetLastError()}))		// 
	
	//DSERGTP-6567: Novo Log Rest RJ
	RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText()/*,oRJIntegra:GetResult("")*/)
EndIf

If !lJob .And. oRJIntegra:oGTPLog:HasInfo() 
	oRJIntegra:oGTPLog:ShowLog()
	lRet := .F.
ElseIf !lJob .And. !oRJIntegra:oGTPLog:HasInfo()
	If lMessage 
		oMessage:SetText("Processo finalizado."  )
		ProcessMessages()
	Else
		Alert("Processo finalizado."  )
	EndIf	
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGID)
GTPDestroy(aFldsGID)
GTPDestroy(aDPXXFGID)
GTPDestroy(aFldsGIE)
GTPDestroy(aDPXXFGIE)
GTPDestroy(aGIEValues)
cFilAnt := cFilBkp

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI004Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI002Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	henrique.toyada
@since 		
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI004Job(aParam, lAuto)

Local nPosEmp := 0
Local nPosFil := 0

Default lAuto := .F.

nPosEmp := IF(Len(aParam) == 9, 6, 1)
nPosFil := IF(Len(aParam) == 9, 7, 2)
//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[nPosEmp],aParam[nPosFil])

If Len(aParam) == 9
	GI004Receb(.F., Nil, aParam[1], STOD(aParam[2]), aParam[3], STOD(aParam[4]), aParam[5],lAuto)
Else
	GTPIRJ004(.F.,lAuto)
EndIf

RpcClearEnv()

Return
