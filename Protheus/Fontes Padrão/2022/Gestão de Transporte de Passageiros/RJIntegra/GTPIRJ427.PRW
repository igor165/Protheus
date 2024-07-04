#Include "GTPIRJ427.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ427

Adapter REST da rotina de Receitas e Despesas

@type 		function
@sample 	GTPIRJ420(lJOb)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	henrique.toyada
@since 		24/07/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ427(lJob,aParams,lMonit, lAuto)

	Local aArea  := GetArea() 
	Local lRet   := .T.

	Default lJob    := .F. 
	Default aParams	:= {}
	Default lAuto   := .F.

	If ( Len(aParams) > 0 )

		MV_PAR01	:= aParams[01]	
		MV_PAR02	:= aParams[02]	
		MV_PAR03	:= aParams[04]	
		MV_PAR04	:= aParams[03]	
		MV_PAR05	:= aParams[05]	
		MV_PAR06	:= aParams[06]
		MV_PAR07	:= aParams[07]

	Else

		If !Pergunte("GTPIRJ427", !lJob)
			Return
		EndIf
	
	EndIf

	FwMsgRun( , {|oSelf| lRet := GI427Receb(lJob, oSelf, MV_PAR01, MV_PAR02, MV_PAR04, MV_PAR03, MV_PAR05, MV_PAR06, MV_PAR07,@lMonit, lAuto)}, , STR0001) //"Processando registros de Receitas e Despesas... Aguarde!"

	Pergunte("GTPIRJ427", .f.)

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI427Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI427Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI427Receb(lJob, oMessage, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim, lMonit, lAuto)

	Local oRJIntegra  := GtpRjIntegra():New()
	Local oModel	  := FwLoadModel("GTPA427")
	Local oMdlGZT	  := Nil
	Local oMdlGZP     := Nil
	Local aFldDePara  := {}
	Local aDeParaXXF  := {}
	Local aCampos	  := {}
	Local cIntID	  := ""
	Local cIntAux     := ""
	Local cExtID	  := ""
	Local cCode		  := ""
	Local cErro		  := ""
	Local cTagName    := ""
	Local cCampo      := ""
	Local cTipoCpo    := ""
	Local xValor      := ""
	Local cFormPag    := ""
	Local nValorGZT   := 0
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

	Default cEmpRJ    := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt)
	Default dDtIni    := dDataBase-1
	Default cHrIni    := '0000'
	Default dDtFim    := dDataBase-1
	Default cHrFim    := '2359'
	Default cAgeIni   := ''
	Default cAgeFim   := ''

	oRJIntegra:SetPath("/receitaDespesa")
	oRJIntegra:SetServico("ReceitaDespesa")

	If lAuto
		cResultAuto := '{"bilhete":[{"idTransacao":10000003808424,"idTransacaoAnterior":null,"idTransacaoOiginal":10000003808424,"idCategoria":1,"nomePassageiro":"DEBORA ROSA","telefonePassageiro":"","documentoUm":"403289440","documentoDois":"30542621703","dataHoraVendaT":"2021-04-30T09:3635-0300","dataHoraViagemT":"2021-04-30T21:0000-0300","dataHoraVenda":1619786195000,"dataHoraViagem":1619827200000,"dataHoraServico":"2021-04-30T17:0000-0300","dataHoraEmbarque":"2021-04-30T21:00:00-03:00","dataHoraAutorizado":"2021-04-30T09:36:34-03:00","idLinha":1488,"porcentagemDesconto":"0","serie":"BPe","subSerie":"","serieFiscal":"","subSerieFiscal":"","numeroImpresso":"49473","numeroSistema":"222578","contador":"","idOrigem":2201,"idOrigemA":0,"idDestino":2063,"idDestinoA":0,"idServico":1010710,"statusBilhete":"V","tarifa":"50","pedagio":"0","taxaEmbarque":"0","seguro":"0","seguroW2i":"","outros":"0","idAgencia":3967,"agenciaDigitador":"3967","idAgenciaFechaCaixa":"0705148005","descAgenciaFechaCaixa":"","ptoNumDigitador":"0705148005","idUsuario":9430,"idUsuarioFechaCaixa":0,"nomeUsuarioFechaCaixa":"","idUsuarioVenda":3967,"idEstacao":9549,"poltrona":"30","descTipoVenda":null,"codigoCategoria":"NO","codigoLinha":"10078","sentido":"V","valorDesconto":0,"origem":"SOL","destino":"FOR","ufOrigem":"CE","ufOrigemalias":"","ufDestino":"CE","ufDestinoalias":"","ufAgenciavenda":"CE","ibgeOrigem":"2312908","ibgeOrigemalias":"","ibgeDestino":"2304400","ibgeDestinoalias":"","ibgeAgenciaVenda":"5148","classeTransporte":"CONVENCIONAL","motivoBpe":"Autorizado o uso do BP-e","erroContingencia":"","aliquota":"15","agencia":"0705148005","idFormaPagamento1":1,"formaPagamento1":"DI","valorPagamento1":50,"nsu1":null,"nsuHOST1":null,"idFormaPagamento2":null,"formaPagamento2":null,"valorPagamento2":0,"nsu2":null,"nsuHOST2":null,"idFormaPagamento3":null,"formaPagamento3":null,"valorPagamento3":0,"nsu3":null,"nsuHOST3":null,"tipoVenda":1,"empresa":10,"nomeCliente":"DEBORA ROSA","cpf":"30542621703","documento1":"403289440","documento2":"30542621703","tipoDocumento1":"RG","tipoDocumento2":"CPF","motivoCancelamento":0,"descCartao1":"","descCartao2":"","descCartao3":"","orgaoConcedente":"20 - DETRAN-CE","usuario":"DEBORARJ","coo":null,"autorizacao1":null,"autorizacao2":null,"autorizacao3":null,"qtdParcelas1":null,"qtdParcelas2":null,"qtdParcelas3":null,"dataOperacao":1619751600000,"loginBilheteiro":"DEBORARJ","clienteRequisicao":"DEBORA ROSA","numeroRequisicao":null,"codigoClienteRequisicao":null,"acertado":"S","fornecedor":"27175975000107","aidf":"","chbpe":"23210427175975009406630470000188151081847922","numProtocolo":"323210000002867","numerobpe":"18815","seriebpe":"47","tarifaTabela":"50","valorBrutobpe":"50.00","valorDescontobpe":"0.00","valorPagobpe":"50.00","tipoDescontobpe":"","descricaoDescontobpe":"","codigoCstbpe":"00","percReducaobpe":"","valorBcbpe":"50.00","aliquotaIcmsbpe":"16.00","valorIcmsbpe":"8.00","valorCreditobpe":"","valorIcmsDevidobpe":"","simplesNacionalbpe":"","valorTributosbpe":"","infoAdicionalbpe":"","chaveAcessoEmissorbpe":"081847922","dvChaveAcessoEmissorbpe":"2","modalidadeBpe":"1","tipoEmissaobpe":"1","tipoBpe":"","chSubstitutivabpe":"","tipoSubstituicaobpe":"","tipoViagembpe":"00","Indreimpresion":0,"statusRetornoBpe":"100"}]}'
		cXmlAuto    := '<?xml version="1.0" encoding="UTF-8"?><RJIntegra><ReceitaDespesa tagMainList="receitaDespesa"><ListOfFields><Field><tagName>idReceitaDespesa</tagName><fieldProtheus>GZT_CODIGO</fieldProtheus><onlyInsert>True</onlyInsert><overwrite>False</overwrite></Field><Field><tagName>dataMovimento</tagName><fieldProtheus>GZT_DTVEND</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>agenciaID</tagName><fieldProtheus>GZT_AGENCI</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite><DeParaXXF><Alias>GI6</Alias><XXF_Field>GI6_CODIGO</XXF_Field><ColumnNumber>3</ColumnNumber><IndiceOrder>1</IndiceOrder><ListOfSeekField><SeekField>GI6_FILIAL</SeekField><SeekField>GI6_CODIGO</SeekField></ListOfSeekField></DeParaXXF></Field><Field><tagName>usuario</tagName><fieldProtheus>GZT_COLAB</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>valor</tagName><fieldProtheus>GZT_VALOR</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>idTransacao</tagName><fieldProtheus>GZT_CODGIC</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite><DeParaXXF><Alias>GIC</Alias><XXF_Field>GIC_CODIGO</XXF_Field><ColumnNumber>3</ColumnNumber><IndiceOrder>1</IndiceOrder><ListOfSeekField><SeekField>GIC_FILIAL</SeekField><SeekField>GIC_CODIGO</SeekField></ListOfSeekField></DeParaXXF></Field><Field><tagName>numeroDocumento</tagName><fieldProtheus>GZT_NDOCTO</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>idEvento</tagName><fieldProtheus>GZT_CODGZC</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>nAutorizacao</tagName><fieldProtheus>GZP_AUT</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>nsuT</tagName><fieldProtheus>GZP_NSU</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName/><fieldProtheus>GZP_QNTPAR</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>valor1</tagName><fieldProtheus>GZP_VALOR</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>formaPagamento1</tagName><fieldProtheus>GZP_TPAGTO</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName/><fieldProtheus>GZP_ITEM</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>bandeira</tagName><fieldProtheus>GZP_DCART</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field></ListOfFields></ReceitaDespesa></RJIntegra>'
	EndIf

	If !lAuto
		oRJIntegra:SetServico("ReceitaDespesa")
	Else
		oRJIntegra:SetServico("ReceitaDespesa",,,cXmlAuto)
	EndIf

	//Deverá ser alterado depois para pegar os valores corretos
	oRJIntegra:SetParam('empresa'     , ALLTRIM(cEmpRJ)                                   )//'10'
	oRJIntegra:SetParam('dataInicial' , SUBSTR(DTOS(dDtIni),3,8) + STRTRAN(cHrIni,":","") )//'1903260000'
	oRJIntegra:SetParam('dataFinal'   , SUBSTR(DTOS(dDtFim),3,8) + STRTRAN(cHrFim,":","") )//'1903262359'

	If !Empty(cAgeIni)
		oRJIntegra:SetParam('agenciaInicio', AllTrim(cAgeIni))
	Endif
	If !Empty(cAgeFim)
		oRJIntegra:SetParam('agenciaFim', AllTrim(cAgeFim))
	Endif

	aFldDePara	:= oRJIntegra:GetFieldDePara()
	aDeParaXXF  := oRJIntegra:GetFldXXF()

	//DSERGTP-6567: Novo Log Rest RJ
	oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ427")

	If oRJIntegra:Get(cResultAuto)
		
		GZT->(DbSetOrder(1))	// GZC_FILIAL+GZC_CODIGO
		nTotReg := oRJIntegra:GetLenItens()	

		nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

		If ( nTotReg >= 0 )

			//nTotReg := IIf(nTotReg > 99, 99, nTotReg)	//TODO: Arrancar esta linha daqui

			For nX := 0 To nTotReg
				lContinua := .T.
				If lMessage .And. !lJob
					oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1})) //"Processando registros de Receitas e Despesas - #1/#2... Aguarde!"
					ProcessMessages()
				EndIf
				
				If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idReceitaDespesa' ,'C'))
					cCode := GTPxRetId("TotalBus", "GZT", "GZT_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
					If Empty(cIntID) 
						nOpc := MODEL_OPERATION_INSERT
					ElseIf lOk .And. GZT->(DbSeek(xFilial('GZT') + cCode))
						nOpc := MODEL_OPERATION_UPDATE
					Else
						lContinua := .F.
						oRJIntegra:oGTPLog:SetText(cErro)
					EndIf
					
					If lContinua
						oModel:SetOperation(nOpc)
						If oModel:Activate()
							oMdlGZT	:= oModel:GetModel("GZTMASTER")
							oMdlGZP	:= oModel:GetModel("GZPPAGT")

							For nY := 1 To Len(aFldDePara)
								// recuperando a TAG e o respectivo campo da tabela 
								cTagName    := aFldDePara[nY][1] 
								cCampo      := aFldDePara[nY][2]
								cTipoCpo    := aFldDePara[nY][3]
								lOnlyInsert := aFldDePara[nY][6]
								lOverWrite  := aFldDePara[nY][7]
								
								cFormPag  := oRJIntegra:GetJsonValue(nX, "formaPagamento1", "C")
								nValorGZT := oRJIntegra:GetJsonValue(nX, "valor", "N")
								If nValorGZT > 0
									// recuperando através da TAG o valor a ser inserido no campo 
									If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)))

										// verificando a necessidade de realizar o DePara XXF
										If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
											xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
										EndIf

										If !(cCampo $ 'GZP_DCART|GZP_ITEM|GZP_TPAGTO|GZP_VALOR|GZP_QNTPAR|GZP_NSU|GZP_AUT')	
											If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGZT:GetValue(cCampo)) 
												lContinua := oRJIntegra:SetValue(oMdlGZT, cCampo, xValor)
											ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
												lContinua := oRJIntegra:SetValue(oMdlGZT, cCampo, xValor)
											EndIf
										Else
											//Removido para validações futuras
											//If cFormPag $ 'CR|DE' 
											//	If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGZP:GetValue(cCampo)) 
											//		lContinua := oRJIntegra:SetValue(oMdlGZP, cCampo, xValor)
											//	ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
											//		lContinua := oRJIntegra:SetValue(oMdlGZP, cCampo, xValor)
											//	EndIf
											//EndIf
										EndIf
										If !lContinua 
											oRJIntegra:oGTPLog:SetText(I18N(STR0003, {cCampo, GTPXErro(oModel)})) //"Falha ao gravar o valor do campo #1 (#2)."
												
										EndIf
									EndIf
								Else
									lContinua := .F.
								EndIf
							Next nY
								
							If lContinua
								If (lContinua := oModel:VldData() )//.And. .F. ) //TODO: Arrancar isto daqui 
									oModel:CommitData()
									CFGA070MNT("TotalBus", "GZT", "GZT_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGZT:GetValue('GZT_CODIGO'), 'GZT')))
								EndIf

								If !lContinua
									oRJIntegra:oGTPLog:SetText(I18N(STR0004, {GTPXErro(oModel)})) //"Falha ao gravar os dados (#1)."
									//DSERGTP-6567: Novo Log Rest RJ
									//RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText())
								EndIf
							EndIf
							oModel:DeActivate()
						Else
							oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)})) //"Falha ao corregar modelos de dados (#1)."
							//DSERGTP-6567: Novo Log Rest RJ
							//RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText())
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
			lMonit := .F. 	//Precisará efetuar o disarmTransaction
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
			oMessage:SetText(STR0007) //"Processo finalizado."
			ProcessMessages()
		Else
			Alert(STR0007) //"Processo finalizado."
		EndIf	
	EndIf

	oRJIntegra:Destroy()
	GTPDestroy(oModel)
	GTPDestroy(oMdlGZT)
	GTPDestroy(aFldDePara)
	GTPDestroy(aDeParaXXF)

Return lRet

	//GI427Job('10','20190326','0000','20190326','2359')
Function GI427Job(aParam, lAuto)

	Local nPosEmp := 0
	Local nPosFil := 0

	Default lAuto := .F.

	nPosEmp := IF(Len(aParam) == 11, 8, IF(Len(aParam) == 9, 6, 1))
	nPosFil := IF(Len(aParam) == 11, 9, IF(Len(aParam) == 9, 7, 2))
	//---Inicio Ambiente
	RPCSetType(3)
	RpcSetEnv(aParam[nPosEmp],aParam[nPosFil])
	If Len(aParam) == 11
		GI427Receb(.T., Nil, aParam[1], STOD(aParam[2]), aParam[3], STOD(aParam[4]), aParam[5], aParam[6], aParam[7],,lAuto)
	ElseIf Len(aParam) == 9
		GI427Receb(.T., Nil, aParam[1], STOD(aParam[2]), aParam[3], STOD(aParam[4]), aParam[5],,,,lAuto)
	Else
		GTPIRJ427(.T.,,,lAuto)
	EndIf

	RpcClearEnv()

Return
