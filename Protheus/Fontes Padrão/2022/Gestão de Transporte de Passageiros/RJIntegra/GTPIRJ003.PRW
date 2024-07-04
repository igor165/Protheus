#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ003.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ003

Adapter REST da rotina de TARIFAS

@type 		function
@sample 	GTPIRJ003(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ003(lJob,lAuto,aParams,lMonit)

Local aArea := GetArea() 
Local lRet  := .T.

Default lJob := .F. 
Default aParams := {}

If !lJob

	If ( Len(aParams) > 0 )
		MV_PAR01	:= aParams[01]			
	Else
		If !Pergunte("GTPIRJ003", .T.)
			Return
		EndIf	
	EndIf

	FwMsgRun( , {|oSelf| lRet := GI003Receb(lJob, oSelf, MV_PAR01, lAuto, @lMonit)}, , STR0001)		// "Processando registros de Tarifas... Aguarde!"  

	Pergunte("GTPIRJ003", .F.)
	
Else
	Pergunte("GTPIRJ003", .F.)
	lRet := GI003Receb(lJob, nil, MV_PAR01, lAuto)
EndIf

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI003Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI003Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI003Receb(lJob, oMessage, dDtVigencia, lAuto, lMonit)

Local aArea       := GetArea()
Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPI003")
Local oMdlGI4	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aIntIDs     := {}
Local aDePara     := {{"GI4_MSBLQL", {{"A", "2"}, {"L", "1"}}}}
Local cIntID	  := ""
Local CIntAux     := ""
Local cExtID	  := ""
Local cExtLinha	  := ""
Local cCodLinha	  := ""
Local cExtLocOri  := ""
Local cExtLocDes  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local cXmlAuto    := ""
Local cResultAuto := ""
Local cFilBkp     := cFilAnt 
Local nX          := 0
Local nY          := 0
Local nOpc		  := 0
Local nTotReg     := 0
Local nPos        := 0
Local nPosDPara   := 0
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'

Private cCodLocOri  := ""
Private cCodLocDes  := ""

cXmlAuto := '<?xml version="1.0" encoding="utf-8"?>'
cXmlAuto += "<RJIntegra>"
cXmlAuto += '	<Tarifa tagMainList="preco">'
cXmlAuto += "		<ListOfFields>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idLinha</tagName>"
cXmlAuto += "				<fieldProtheus>GI4_LINHA</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "				<DeParaXXF>"
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
cXmlAuto += "				<tagName>idOrigem</tagName>"
cXmlAuto += "				<fieldProtheus>GI4_LOCORI</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>idDestino</tagName>"
cXmlAuto += "				<fieldProtheus>GI4_LOCDES</fieldProtheus>"
cXmlAuto += "				<onlyInsert>True</onlyInsert>"
cXmlAuto += "				<overwrite>False</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>dataInicioVigenciaT</tagName>"
cXmlAuto += "				<fieldProtheus>GI4_VIGTAR</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>dataModificacaoT</tagName>"
cXmlAuto += "				<fieldProtheus>GI4_DTALT</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>preco</tagName>"
cXmlAuto += "				<fieldProtheus>GI4_TAR</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>taxaEmbarque</tagName>"
cXmlAuto += "				<fieldProtheus>GI4_TAX</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>pedagio</tagName>"
cXmlAuto += "				<fieldProtheus>GI4_PED</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>seguro</tagName>"
cXmlAuto += "				<fieldProtheus>GI4_SGFACU</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "			<Field>"
cXmlAuto += "				<tagName>statusTarifa</tagName>"
cXmlAuto += "				<fieldProtheus>GI4_MSBLQL</fieldProtheus>"
cXmlAuto += "				<onlyInsert>False</onlyInsert>"
cXmlAuto += "				<overwrite>True</overwrite>"
cXmlAuto += "			</Field>"
cXmlAuto += "		</ListOfFields>"
cXmlAuto += "	</Tarifa>"
cXmlAuto += "</RJIntegra>"

oRJIntegra:SetPath("/preco")

If !lAuto
	oRJIntegra:SetServico("Tarifa")
Else
	oRJIntegra:SetServico("Tarifa",,,cXmlAuto)
EndIf

oRJIntegra:SetParam('dataVigencia', DtoS(dDtVigencia))

If lAuto
	cResultAuto := '{"linha":[{"idLinha":213,"descLinha":"UBERABA X SANTOS 20089","idClasse":1,"dataModificacao":"2018-03-19","idOrgaoConcedente":3,"prefixo":"06033801","tributaTarifa":1,"tributaTEmbarque":0,"tributaPedagio":0,"codigoLinha":"20089","idEmpresa":10,"trechos":{"trecho":[{"idTrecho":35965,"sequencia":1,"indVenda":null,"origemID":"7451","destinoID":"19249","descOrigem":"URA","origemIBGE":null,"descDestino":"IGA","destinoIBGE":null,"kmReal":"16","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null},{"idTrecho":35983,"sequencia":2,"indVenda":null,"origemID":"19249","destinoID":"19248","descOrigem":"IGA","origemIBGE":null,"descDestino":"AMI","destinoIBGE":null,"kmReal":"9","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null},{"idTrecho":36000,"sequencia":3,"indVenda":null,"origemID":"19248","destinoID":"19247","descOrigem":"AMI","origemIBGE":null,"descDestino":"ITV","destinoIBGE":null,"kmReal":"27","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null}]}}]}'
EndIf

aFldDePara := oRJIntegra:GetFieldDePara()
aDeParaXXF := oRJIntegra:GetFldXXF()

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ003")

If oRJIntegra:Get(cResultAuto)
	GI4->(DbSetOrder(5))	// GI4_FILIAL+GI4_LINHA+GI4_LOCORI+GI4_LOCDES+GI4_HIST
	nTotReg := oRJIntegra:GetLenItens()
	//Necessário para a automação não efetuar todos os registros de uma vez
	If lAuto
		nTotReg := 1
	EndIf

	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )	

		//nTotReg := IIf(nTotReg > 99, 99, nTotReg)	//TODO: Arrancar esta linha daqui
		
		For nX := 0 To nTotReg
			lContinua := .T.
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Tarifas - #1/#2... Aguarde!"
				ProcessMessages()
			EndIf	

			If !Empty(cExtLinha := oRJIntegra:GetJsonValue(nX, 'idLinha', 'C'))
				cCodLinha := GTPxRetId("TotalBus", "GI2", "GI2_COD", cExtLinha, @cIntID, 3, @lOk, @cErro, {"GI2_FILIAL", "GI2_COD", {"GI2_HIST", "2"}}, 4)

				// validando se a linha existe no cadastro de seções
				GI2->(DbSetOrder(1))	
				If GI2->(DbSeek(xFilial('GI2') + cCodLinha))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(STR0003)		// "Linha não encontrada. Favor realizar o cadastro prévio da Linha para prosseguir com a integração das Tarifas."
				EndIf
			
				If lContinua 
					cExtID     := oRJIntegra:GetJsonValue(nX, 'idPreco'  , 'C')
					cExtLocOri := oRJIntegra:GetJsonValue(nX, 'idOrigem' , 'C') 
					cExtLocDes := oRJIntegra:GetJsonValue(nX, 'idDestino', 'C') 
					aAdd(aIntIDs, {cExtLocOri, "cCodLocOri", "GI1", "GI1_COD", 3, {"GI1_FILIAL", "GI1_COD"}, 1})
					aAdd(aIntIDs, {cExtLocDes, "cCodLocDes", "GI1", "GI1_COD", 3, {"GI1_FILIAL", "GI1_COD"}, 1})
		
					For nY := 1 To Len(aIntIDs)
						If !Empty(aIntIDs[nY, 1])
							&(aIntIDs[nY, 2]) := GTPxRetId("TotalBus", aIntIDs[nY, 3], aIntIDs[nY, 4], aIntIDs[nY, 1], aIntIDs[nY, 2], aIntIDs[nY, 5], @lOk ,@cErro, aIntIDs[nY, 6], aIntIDs[nY, 7])
							If !lOk
								lContinua := .F.
								oRJIntegra:oGTPLog:SetText(cErro)
								Exit
							EndIf
						EndIf
					Next nY

					// verificando se existe tarifa para as localidades de origem e destino
					If !(GI4->(DbSeek(xFilial('GI4') + cCodLinha + cCodLocOri + cCodLocDes + "2")))
						oRJIntegra:oGTPLog:SetText(I18N(STR0004, {cExtLocOri, cExtLocDes}))		// "Não foi possivel encontrar a localidade do trecho de Origem: #1 e/ou de Destino: #2"
					Else
						oModel:SetOperation(nOpc)
						If oModel:Activate()
							oMdlGI4 := oModel:GetModel("GI4MASTER")
			
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
			
									// verificando a necessidade de realizar o DePara de alguns campos do serviço 
									If (nPos := aScan(aDePara, {|x| x[1] == cCampo})) > 0
										If (nPosDPara := aScan(aDePara[nPos][2], {|x| x[1] == xValor})) > 0
											xValor := aDePara[nPos][2][nPosDPara][2]
										EndIf
									EndIf
									
									If (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
										lContinua := oRJIntegra:SetValue(oMdlGI4, cCampo, xValor)
									EndIf

									If !lContinua 
										oRJIntegra:oGTPLog:SetText(I18N(STR0005, {cCampo, GTPXErro(oModel)}))		// "Falha ao gravar o valor do campo #1 (#2)."
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
									cIntId := GTPxMakeId(cCodLinha + "|" + cCodLocOri + "|" + cCodLocDes + "|" + "2", "GI4") 
									CFGA070MNT("TotalBus", "GI4", "GI4_ITEM", cExtID, GTPxMakeId(cIntId, 'GI4'))
								EndIf
			
								If !lContinua
									oRJIntegra:oGTPLog:SetText(I18N(STR0006, {GTPXErro(oModel)}))		// "Falha ao gravar os dados (#1)."
								EndIf
							EndIf
							oModel:DeActivate()
						Else
							oRJIntegra:oGTPLog:SetText(I18N(STR0007, {GTPXErro(oModel)}))		// "Falha ao corregar modelos de dados (#1)."
							
							//DSERGTP-6567: Novo Log Rest RJ
							RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText()/*,oRJIntegra:GetResult("")*/)
							Exit
						EndIf
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
		lMonit := .F.
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
		oMessage:SetText(STR0009)		// "Processo finalizado."
		ProcessMessages()
	Else
		Alert(STR0009)		// "Processo finalizado."
	EndIf	
EndIf

RestArea(aArea)

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGI4)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)
cFilAnt := cFilBkp

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI003Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI003Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI003Job(aParam, lAuto)

Local nPosEmp := IIF(Len(aParam) == 3, 2, 1)
Local nPosFil := IIF(Len(aParam) == 3, 3, 2)

Default lAuto := .F.

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[nPosEmp], aParam[nPosFil])
If Len(aParam) == 3
	GI003Receb(.T., Nil, STOD(aParam[1]),lAuto)
Else
	GTPIRJ003(.T.,lAuto)
EndIf
RpcClearEnv()

Return
