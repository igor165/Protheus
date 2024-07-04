#INCLUDE "PROTHEUS.CH"                
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ002.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ002

Adapter REST da rotina de LINHAS E TRECHOS 

@type 		function
@sample 	GTPIRJ002(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		06/05/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ002(lJob,lAuto,lMonit)

Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob := .F. 
Default lAuto := .F. 

If !lJob
	FwMsgRun( , {|oSelf| lRet := GI002Receb(lJob, oSelf, lAuto, @lMonit)}, , STR0001)		// "Processando registros de Linhas e Trechos... Aguarde!"  
Else
	lRet := GI002Receb(lJob, nil, lAuto)
EndIf

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI002Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI002Receb(cXml, lRet)
@param 		cXml, characters, Xml passado pela função do IntegDef
			lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return 	cXMLRet, characters, String contendo o xml de envio
@author 	jacomo.fernandes
@since 		15/02/2017
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI002Receb(lJob, oMessage, lAuto, lMonit)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA002")
Local oMdlGI2	  := Nil
Local oMdlG5I     := Nil
Local aFldsGI2    := {}
Local aDPXXFGI2   := {}
Local aFldsG5I    := {}
Local aDPXXFG5I   := {}
Local aG5IValues  := {}
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
Local cCodTreIni  := ""
Local cCodTreDes  := ""
Local cXmlAuto    := ""
Local cFilBkp     := cFilAnt 
Local nW          := 0
Local nX          := 0
Local nY          := 0
Local nZ          := 0
Local nOpc		  := 0
Local nTotReg     := 0
Local nTotG5I     := 0
Local nPos        := 0
Local nPosTrechos := 0
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'

cXmlAuto := '<?xml version="1.0" encoding="utf-8"?>'
cXmlAuto += "<RJIntegra>"
cXmlAuto += '	<Linha tagMainList="linha">'
cXmlAuto += "		<ListOfFields>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idLinha</tagName>"
cXmlAuto += "				<fieldProtheus>GI2_COD</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>descLinha</tagName>"
cXmlAuto += "				<fieldProtheus>GI2_DESCRI</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idOrgaoConcedente</tagName>"
cXmlAuto += "				<fieldProtheus>GI2_ORGAO</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "				<DeParaXXF>"
cXmlAuto += "					<Alias>GI0</Alias>"
cXmlAuto += "					<XXF_Field>GI0_COD</XXF_Field>"
cXmlAuto += "					<ColumnNumber>3</ColumnNumber>"
cXmlAuto += "					<IndiceOrder>1</IndiceOrder>"
cXmlAuto += "					<ListOfSeekField>"
cXmlAuto += "						<SeekField>GI0_FILIAL</SeekField>"
cXmlAuto += "						<SeekField>GI0_COD</SeekField>"
cXmlAuto += "					</ListOfSeekField>"
cXmlAuto += "				</DeParaXXF>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idClasse</tagName>"
cXmlAuto += "				<fieldProtheus>GI2_CATEG</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "				<DeParaXXF>"
cXmlAuto += "					<Alias>GYR</Alias>"
cXmlAuto += "					<XXF_Field>GYR_CODIGO</XXF_Field>"
cXmlAuto += "					<ColumnNumber>3</ColumnNumber>"
cXmlAuto += "					<IndiceOrder>1</IndiceOrder>"
cXmlAuto += "					<ListOfSeekField>"
cXmlAuto += "						<SeekField>GYR_FILIAL</SeekField>"
cXmlAuto += "						<SeekField>GYR_CODIGO</SeekField>"
cXmlAuto += "					</ListOfSeekField>"
cXmlAuto += "				</DeParaXXF>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>dataModificacao</tagName>"
cXmlAuto += "				<fieldProtheus>GI2_DTALT</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>prefixo</tagName>"
cXmlAuto += "				<fieldProtheus>GI2_PREFIX</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>codigoLinha</tagName>"
cXmlAuto += "				<fieldProtheus>GI2_NUMLIN</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "		</ListOfFields>"
cXmlAuto += '		<Trechos tagMainList="trechos">'
cXmlAuto += "			<ListOfFields>"
cXmlAuto += "				<Field>"
cXmlAuto += "					<tagName>idTrecho</tagName>"
cXmlAuto += "					<fieldProtheus>G5I_CODIGO</fieldProtheus>"
cXmlAuto += "					<onlyInsert>True</onlyInsert>"
cXmlAuto += "					<overwrite>False</overwrite>"
cXmlAuto += "				</Field>"
cXmlAuto += "				<Field>"
cXmlAuto += "					<tagName>origemID</tagName>"
cXmlAuto += "					<fieldProtheus>G5I_LOCALI</fieldProtheus>"
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
cXmlAuto += "					<tagName>destinoID</tagName>"
cXmlAuto += "					<fieldProtheus>G5I_LOCALI</fieldProtheus>"
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
cXmlAuto += "					<tagName>sequencia</tagName>"
cXmlAuto += "					<fieldProtheus>G5I_SEQ</fieldProtheus>"
cXmlAuto += "					<onlyInsert>True</onlyInsert>"
cXmlAuto += "					<overwrite>False</overwrite>"
cXmlAuto += "				</Field>"
cXmlAuto += "				<Field>"
cXmlAuto += "					<tagName>kmReal</tagName>"
cXmlAuto += "					<fieldProtheus>G5I_KM</fieldProtheus>"
cXmlAuto += "					<onlyInsert>False</onlyInsert>"
cXmlAuto += "					<overwrite>True</overwrite>"
cXmlAuto += "				</Field>  "
cXmlAuto += "			</ListOfFields>	"
cXmlAuto += "		</Trechos>"
cXmlAuto += "	</Linha>"
cXmlAuto += "</RJIntegra>"

oRJIntegra:SetPath("/linha/todas")

// recuperando as informações do XML de controle da LINHA
If !lAuto
	oRJIntegra:SetServico("Linha")
Else
	oRJIntegra:SetServico("Linha",,,cXmlAuto)
EndIf

aFldsGI2  := aClone(oRJIntegra:GetFieldDePara())
aDPXXFGI2 := aClone(oRJIntegra:GetFldXXF())

// recuperando as informações do XML de controle dos TRECHOS
If !lAuto
	oRJIntegra:SetServico('Linha/Trechos',.T.)
Else
	oRJIntegra:SetServico('Linha/Trechos',.T.,,cXmlAuto)
EndIf

aFldsG5I  := aClone(oRJIntegra:GetFieldDePara())
aDPXXFG5I := aClone(oRJIntegra:GetFldXXF())

If !lAuto
	oRJIntegra:SetServico("Linha")
Else
	oRJIntegra:SetServico("Linha",,,cXmlAuto)
EndIf

If lAuto
	oRJIntegra:cjsonresult := '{"linha":[{"idLinha":213,"descLinha":"UBERABA X SANTOS 20089","idClasse":1,"dataModificacao":"2018-03-19","idOrgaoConcedente":3,"prefixo":"06033801","tributaTarifa":1,"tributaTEmbarque":0,"tributaPedagio":0,"codigoLinha":"20089","idEmpresa":10,"trechos":{"trecho":[{"idTrecho":35965,"sequencia":1,"indVenda":null,"origemID":"7451","destinoID":"19249","descOrigem":"URA","origemIBGE":null,"descDestino":"IGA","destinoIBGE":null,"kmReal":"16","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null},{"idTrecho":35983,"sequencia":2,"indVenda":null,"origemID":"19249","destinoID":"19248","descOrigem":"IGA","origemIBGE":null,"descDestino":"AMI","destinoIBGE":null,"kmReal":"9","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null},{"idTrecho":36000,"sequencia":3,"indVenda":null,"origemID":"19248","destinoID":"19247","descOrigem":"AMI","origemIBGE":null,"descDestino":"ITV","destinoIBGE":null,"kmReal":"27","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null}]}}]}'
EndIf

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ002")

If oRJIntegra:Get()
	GI2->(DbSetOrder(1))	// GI2_FILIAL+GI2_COD+GI2_VIA
	G5I->(DbSetOrder(3))	// G5I_FILIAL+G5I_CODLIN+G5I_LOCALI	
	nTotReg := oRJIntegra:GetLenItens()

	//Necessário para a automação não efetuar todos os registros de uma vez
	If lAuto
		nTotReg := 1
	EndIf
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )

		For nW := 0 To nTotReg
			lContinua  := .T.
			aG5IValues := {}

			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nW + 1), nTotReg + 1}))		// "Processando registros de linhas e trechos - #1/#2... Aguarde!"  
				ProcessMessages()
			EndIf

			// para essa integração é preciso localizar a filial. Caso não encontrada, pular para próximo item do JSON
			If Empty((cFilAux := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt, oRJIntegra:GetJsonValue(nW, 'idEmpresa', 'C'), , "2")))
				Loop
			Else
				cFilAnt := cFilAux
			EndIf		

			oRJIntegra:aFldDePara := aFldsGI2
			oRJIntegra:aFldXXF    := aDPXXFGI2 
			If !Empty((cExtID := oRJIntegra:GetJsonValue(nW, 'idLinha', 'C', 'linha'))) 
				cCode := GTPxRetId("TotalBus", "GI2", "GI2_COD", cExtID, @cIntID, 3, @lOk, @cErro, {"GI2_FILIAL", "GI2_COD"}, 1)
				If Empty(cIntID)  
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GI2->(DbSeek(xFilial('GI2') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf

				If lContinua
					oModel:SetOperation(nOpc)
					oModel:GetModel('GRIDG5I'):GetStruct():SetProperty('G5I_VENDA', MODEL_FIELD_INIT, {|| "1"})
					If oModel:Activate()
						oMdlGI2 := oModel:GetModel('FIELDGI2')
						oMdlG5I := oModel:GetModel('GRIDG5I')

						// recuperando a TAG e o respectivo campo da tabela GI2 (Linhas) 
						For nX := 1 To Len(aFldsGI2)
							cTagName    := aFldsGI2[nX][1] 
							cCampo      := aFldsGI2[nX][2]
							cTipoCpo    := aFldsGI2[nX][3]
							lOnlyInsert := aFldsGI2[nX][6]
							lOverWrite  := aFldsGI2[nX][7]
							
							// recuperando através da TAG o valor a ser inserido no campo 
							If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nW, cTagName, cTipoCpo, 'linha')))
								
								// verificando a necessidade de realizar o DePara XXF
								If (nPos := aScan(aDPXXFGI2, {|x| x[1] == cCampo})) > 0
									xValor := GTPxRetId("TotalBus", aDPXXFGI2[nPos, 2], aDPXXFGI2[nPos, 3], xValor, @cIntAux, aDPXXFGI2[nPos, 4], @lOk, @cErro, aDPXXFGI2[nPos, 6], aDPXXFGI2[nPos, 5])
								EndIf

								
								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGI2:GetValue(cCampo)) 
									lContinua := oRJIntegra:SetValue(oMdlGI2, cCampo, xValor, lOverWrite)
								ElseIf !(cCampo $ "GI2_COD|") .AND. ((nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. nOpc <> MODEL_OPERATION_INSERT )
									lContinua := oRJIntegra:SetValue(oMdlGI2, cCampo, xValor, lOverWrite)
								EndIf
							
								If !lContinua 
									oRJIntegra:oGTPLog:SetText(I18N("Falha ao gravar o valor do campo #1 (#2).", {cCampo, GTPXErro(oModel)}))		// "Falha ao gravar o valor do campo #1 (#2)."  									
								EndIf
							EndIf
						Next nX
						
						// recuperando a TAG e o respectivo campo da tabela G5I (Trechos) 
						If lContinua .And. (nPosTrechos := aScan(oRJIntegra:aResult[1][2][1][2][nW + 1][2], {|x| x[1] == "trechos"})) > 0 						
							nTotG5I := Len(oRJIntegra:aResult[1][2][1][2][nW + 1][2][nPosTrechos + 1][2][1][2]) //- 1
							
							// populando o array com os valores a serem gravados na tabela G5I
							oRJIntegra:aFldDePara := aFldsG5I
							oRJIntegra:aFldXXF    := aDPXXFG5I 
							For nY := 0 To (nTotG5I-1)
								cSequencia := oRJIntegra:GetJsonValue(nY, 'sequencia', 'C', 'linha[' + cValToChar(nW) + '].trechos.trecho')
								aAdd(aG5IValues, {Replicate('0', TamSX3("G5I_SEQ")[1] - LEN(cSequencia)) + RTrim(LTrim(cSequencia))})
														
								For nZ := 1 To Len(aFldsG5I)
									xValor      := ""
									cTagName    := aFldsG5I[nZ][1] 
									cCampo      := aFldsG5I[nZ][2]
									cTipoCpo    := aFldsG5I[nZ][3]
									lOnlyInsert := aFldsG5I[nZ][6]
									lOverWrite  := aFldsG5I[nZ][7]
									
									// recuperando através da TAG o valor a ser inserido no campo 
									If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nY, cTagName, cTipoCpo, 'linha[' + cValToChar(nW) + '].trechos.trecho')))
										
										// verificando a necessidade de realizar o DePara XXF
										If (nPos := aScan(aDPXXFG5I, {|x| x[1] == cCampo})) > 0
											xValor := GTPxRetId("TotalBus", aDPXXFG5I[nPos, 2], aDPXXFG5I[nPos, 3], xValor, @cIntAux, aDPXXFG5I[nPos, 4], @lOk, @cErro, aDPXXFG5I[nPos, 6], aDPXXFG5I[nPos, 5])
										EndIf
										
										If cCampo == "G5I_LOCALI" .AND. cTagName = "origemID" .And. !Empty(xValor)
											If nY == 0
												cCodTreIni := xValor
											EndIf
										EndIf 

										If cCampo == "G5I_LOCALI" .AND. cTagName = "destinoID" .And. !Empty(xValor)
											If nY == (nTotG5I-1)
												cCodTreDes := xValor
											EndIf
										EndIf 
																																	
										aAdd(aG5IValues[nY + 1], {{cCampo, xValor, lOnlyInsert, lOverWrite, cTagName}})
									EndIf
								Next nZ
							Next nY

							aSort(aG5IValues, , , {|x, y| x[1] < y[1]})
						
							For nY := 1 To Len(aG5IValues)
								For nZ := 1 To Len(aG5IValues[nY])
									If ValType(aG5IValues[nY][nZ]) == "A"
										cCampo      := aG5IValues[nY][nZ][1][1] 
										xValor      := aG5IValues[nY][nZ][1][2]
										lOnlyInsert := aG5IValues[nY][nZ][1][3]
										lOverWrite  := aG5IValues[nY][nZ][1][4]
										cTagName	:= aG5IValues[nY][nZ][1][5]
										If cTagName != "destinoID"
											If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlG5I:GetValue(cCampo)) 
												lContinua := oRJIntegra:SetValue(oMdlG5I, cCampo, IIF(cCampo != "G5I_SEQ", xValor, 	Replicate('0', TamSx3('G5I_SEQ')[1] - Len(xValor)) + RTrim(LTrim(xValor))))
											ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
												If !(cCampo == "G5I_SEQ" .AND. oMdlG5I:SeekLine({{"G5I_SEQ",Replicate('0', TamSx3('G5I_SEQ')[1] - Len(xValor)) + RTrim(LTrim(xValor)) }}))
													lContinua := oRJIntegra:SetValue(oMdlG5I, cCampo, IIF(cCampo != "G5I_SEQ", xValor, 	Replicate('0', TamSx3('G5I_SEQ')[1] - Len(xValor)) + RTrim(LTrim(xValor))))
												EndIf
											EndIf

											If !lContinua 
												oRJIntegra:oGTPLog:SetText(I18N(STR0003, {cCampo, GTPXErro(oModel)}))		// "Falha ao gravar o valor do campo #1 (#2)."  												
											EndIf
										EndIf
										
									EndIf
								Next nZ
								
								If lContinua .And. oMdlG5I:VldLineData(.F.) .And. (nY + 1) <= nTotG5I
									oMdlG5I:AddLine()
								EndIf 
							Next nY
						EndIf 
												
						If lContinua 
							//Adicionando os valores no cabeçalho das linhas
							oMdlGI2:LoadValue("GI2_LOCINI", cCodTreIni)
							oMdlGI2:LoadValue("GI2_LOCFIM", cCodTreDes)

							If !(oMdlG5I:SeekLine({{"G5I_SEQ",Replicate("9", TamSx3('G5I_SEQ')[1]) }}))
								// adicionando o trecho final
								oMdlG5I:AddLine()
								oMdlG5I:SetValue("G5I_LOCALI", cCodTreDes)
								oMdlG5I:SetValue("G5I_SEQ", Replicate("9", TamSx3('G5I_SEQ')[1]))
							EndIf
							If (lContinua := oModel:VldData())
								oModel:CommitData()
								CFGA070MNT("TotalBus", "GI2", "GI2_COD", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGI2:GetValue('GI2_COD'), 'GI2')))
							Else							
								oRJIntegra:oGTPLog:SetText(I18N(STR0004, {GTPXErro(oModel)}))		// "Falha ao gravar os dados (#1)."  
							EndIf
						EndIf
						oModel:DeActivate()
					Else
						oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)}))		// "Falha ao corregar modelos de dados (#1)."  
						lContinua := .F.
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
GTPDestroy(oMdlGI2)
GTPDestroy(aFldsGI2)
GTPDestroy(aDPXXFGI2)
GTPDestroy(aFldsG5I)
GTPDestroy(aDPXXFG5I)
GTPDestroy(aG5IValues)
cFilAnt := cFilBkp

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI002Job

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
Function GI002Job(aParams, lAuto)

Default lAuto := .F.

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParams[1], aParams[2])

GTPIRJ002(.T.,lAuto)

RpcClearEnv()

Return
