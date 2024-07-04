#Include "GTPIRJ115.ch"
#Include "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ115

Adapter REST da rotina de BILHETE 

@type 		function
@sample 	GTPIRJ115()
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		lRet, Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	henrique.toyada
@since 		31/07/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ115(lJob,aParams,lMonit,lAuto)

	Local aArea  := GetArea() 
	Local lRet   := .T.
	Local cEmpRJ  := nil
	Local dDtIni  := nil
	Local cHrIni  := nil
	Local dDtFim  := nil
	Local cHrFim  := nil
	Local cAgeIni := nil
	Local cAgeFim := nil

	Default lJob 	:= .F. 
	Default aParams	:= {}
	Default lAuto := .F.
	
	If ( Len(aParams) == 0 )
	
		If ( Pergunte('GTPIRJ115',!lJob) )

			cEmpRJ  := MV_PAR01
			dDtIni  := MV_PAR02
			cHrIni  := MV_PAR03
			dDtFim  := MV_PAR04
			cHrFim  := MV_PAR05
			cAgeIni := AllTrim(MV_PAR06)
			cAgeFim := AllTrim(MV_PAR07)
		Else
			lRet := .F.
		EndIf

	Else

		cEmpRJ  := aParams[1]
		dDtIni  := aParams[2]
		cHrIni  := aParams[3]
		dDtFim  := aParams[4]
		cHrFim  := aParams[5]
		cAgeIni := aParams[6]
		cAgeFim := aParams[7]

	EndIf

	If ( lRet )
		FwMsgRun( , {|oSelf| lRet := GI115Receb(lJob, oSelf, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim,@lMonit, lAuto)}, , STR0001) //"Processando registros de Bilhetes... Aguarde!"
	EndIF

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI115Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI115Receb(cRestResult, oMessage)
@param 		oRJIntegra, objeto - classe que trata da integração
			oMessage, objeto   - trata a mensagem apresentada em tela
@return 	lRet, logical      - resultado do processamento da rotina (.T. / .F.)
@author 	henrique.toyada
@since 		29/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI115Receb(lJob, oMessage, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim, lMonit, lAuto)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA115")
Local oMdlGIC	  := Nil
Local oMdlGZP     := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GIC_FILIAL", "GIC_CODIGO"}
Local cIntID	  := ""
Local cIntAux	  := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local cFormPag    := ""
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
Local cResultAuto := ''
Local cXmlAuto    := ''

Default cEmpRJ    := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt)
Default dDtIni    := dDataBase-1
Default cHrIni    := '0000'
Default dDtFim    := dDataBase-1
Default cHrFim    := '2359'
Default cAgeIni   := ''
Default cAgeFim   := ''

oRJIntegra:SetPath("/bilhete/venda2")
oRJIntegra:SetServico('Bilhete')

oRJIntegra:SetParam('empresa'		 , ALLTRIM(cEmpRJ))
oRJIntegra:SetParam('dataHoraInicial', SubStr(DtoS(dDtIni), 3,8) + STRTRAN(cHrIni,":",""))
oRJIntegra:SetParam('dataHoraFinal'	 , SubStr(DtoS(dDtFim), 3,8) + STRTRAN(cHrFim,":",""))

If !Empty(cAgeIni)
	oRJIntegra:SetParam('agenciaInicio', AllTrim(cAgeIni))
Endif
If !Empty(cAgeFim)
	oRJIntegra:SetParam('agenciaFim', AllTrim(cAgeFim))
Endif

If lAuto
	cResultAuto := '{"bilhete":[{"idTransacao":10000003808424,"idTransacaoAnterior":null,"idTransacaoOiginal":10000003808424,"idCategoria":1,"nomePassageiro":"DEBORA ROSA","telefonePassageiro":"","documentoUm":"403289440","documentoDois":"30542621703","dataHoraVendaT":"2021-04-30T09:3635-0300","dataHoraViagemT":"2021-04-30T21:0000-0300","dataHoraVenda":1619786195000,"dataHoraViagem":1619827200000,"dataHoraServico":"2021-04-30T17:0000-0300","dataHoraEmbarque":"2021-04-30T21:00:00-03:00","dataHoraAutorizado":"2021-04-30T09:36:34-03:00","idLinha":1488,"porcentagemDesconto":"0","serie":"BPe","subSerie":"","serieFiscal":"","subSerieFiscal":"","numeroImpresso":"49473","numeroSistema":"222578","contador":"","idOrigem":2201,"idOrigemA":0,"idDestino":2063,"idDestinoA":0,"idServico":1010710,"statusBilhete":"V","tarifa":"50","pedagio":"0","taxaEmbarque":"0","seguro":"0","seguroW2i":"","outros":"0","idAgencia":3967,"agenciaDigitador":"3967","idAgenciaFechaCaixa":"0705148005","descAgenciaFechaCaixa":"","ptoNumDigitador":"0705148005","idUsuario":9430,"idUsuarioFechaCaixa":0,"nomeUsuarioFechaCaixa":"","idUsuarioVenda":3967,"idEstacao":9549,"poltrona":"30","descTipoVenda":null,"codigoCategoria":"NO","codigoLinha":"10078","sentido":"V","valorDesconto":0,"origem":"SOL","destino":"FOR","ufOrigem":"CE","ufOrigemalias":"","ufDestino":"CE","ufDestinoalias":"","ufAgenciavenda":"CE","ibgeOrigem":"2312908","ibgeOrigemalias":"","ibgeDestino":"2304400","ibgeDestinoalias":"","ibgeAgenciaVenda":"5148","classeTransporte":"CONVENCIONAL","motivoBpe":"Autorizado o uso do BP-e","erroContingencia":"","aliquota":"15","agencia":"0705148005","idFormaPagamento1":1,"formaPagamento1":"DI","valorPagamento1":50,"nsu1":null,"nsuHOST1":null,"idFormaPagamento2":null,"formaPagamento2":null,"valorPagamento2":0,"nsu2":null,"nsuHOST2":null,"idFormaPagamento3":null,"formaPagamento3":null,"valorPagamento3":0,"nsu3":null,"nsuHOST3":null,"tipoVenda":1,"empresa":10,"nomeCliente":"DEBORA ROSA","cpf":"30542621703","documento1":"403289440","documento2":"30542621703","tipoDocumento1":"RG","tipoDocumento2":"CPF","motivoCancelamento":0,"descCartao1":"","descCartao2":"","descCartao3":"","orgaoConcedente":"20 - DETRAN-CE","usuario":"DEBORARJ","coo":null,"autorizacao1":null,"autorizacao2":null,"autorizacao3":null,"qtdParcelas1":null,"qtdParcelas2":null,"qtdParcelas3":null,"dataOperacao":1619751600000,"loginBilheteiro":"DEBORARJ","clienteRequisicao":"DEBORA ROSA","numeroRequisicao":null,"codigoClienteRequisicao":null,"acertado":"S","fornecedor":"27175975000107","aidf":"","chbpe":"23210427175975009406630470000188151081847922","numProtocolo":"323210000002867","numerobpe":"18815","seriebpe":"47","tarifaTabela":"50","valorBrutobpe":"50.00","valorDescontobpe":"0.00","valorPagobpe":"50.00","tipoDescontobpe":"","descricaoDescontobpe":"","codigoCstbpe":"00","percReducaobpe":"","valorBcbpe":"50.00","aliquotaIcmsbpe":"16.00","valorIcmsbpe":"8.00","valorCreditobpe":"","valorIcmsDevidobpe":"","simplesNacionalbpe":"","valorTributosbpe":"","infoAdicionalbpe":"","chaveAcessoEmissorbpe":"081847922","dvChaveAcessoEmissorbpe":"2","modalidadeBpe":"1","tipoEmissaobpe":"1","tipoBpe":"","chSubstitutivabpe":"","tipoSubstituicaobpe":"","tipoViagembpe":"00","Indreimpresion":0,"statusRetornoBpe":"100"}]}'
	cXmlAuto := '<?xml version="1.0" encoding="UTF-8"?>'
	cXmlAuto += '<RJIntegra>'
	cXmlAuto += '	<Bilhete tagMainList="bilhete">'
	cXmlAuto += '		<ListOfFields>'
	cXmlAuto += '			<Field>'
	cXmlAuto += '				<tagName>idTransacao</tagName>'
	cXmlAuto += '				<fieldProtheus>GIC_BILHET</fieldProtheus>'
	cXmlAuto += '				<onlyInsert>True</onlyInsert>'
	cXmlAuto += '				<overwrite>False</overwrite>'
	cXmlAuto += '			</Field>'
	cXmlAuto += '			<Field>'
	cXmlAuto += '				<tagName>idTransacaoAnterior</tagName>'
	cXmlAuto += '				<fieldProtheus>GIC_BILREF</fieldProtheus>'
	cXmlAuto += '				<onlyInsert>False</onlyInsert>'
	cXmlAuto += '				<overwrite>True</overwrite>'
	cXmlAuto += '				<DeParaXXF>'
	cXmlAuto += '					<Alias>GIC</Alias>'
	cXmlAuto += '					<XXF_Field>GIC_CODIGO</XXF_Field>'
	cXmlAuto += '					<ColumnNumber>3</ColumnNumber>'
	cXmlAuto += '					<IndiceOrder>1</IndiceOrder>'
	cXmlAuto += '					<ListOfSeekField>'
	cXmlAuto += '						<SeekField>GIC_FILIAL</SeekField>'
	cXmlAuto += '						<SeekField>GIC_CODIGO</SeekField>'
	cXmlAuto += '					</ListOfSeekField>'
	cXmlAuto += '				</DeParaXXF>'
	cXmlAuto += '			</Field>'
	cXmlAuto += '			<Field>'
	cXmlAuto += '				<tagName>idCategoria</tagName>'
	cXmlAuto += '				<fieldProtheus>GIC_CODG9B</fieldProtheus>'
	cXmlAuto += '				<onlyInsert>False</onlyInsert>'
	cXmlAuto += '				<overwrite>True</overwrite>'
	cXmlAuto += '				<DeParaXXF>'
	cXmlAuto += '					<Alias>G9B</Alias>'
	cXmlAuto += '					<XXF_Field>G9B_CODIGO</XXF_Field>'
	cXmlAuto += '					<ColumnNumber>3</ColumnNumber>'
	cXmlAuto += '					<IndiceOrder>1</IndiceOrder>'
	cXmlAuto += '					<ListOfSeekField>'
	cXmlAuto += '						<SeekField>G9B_FILIAL</SeekField>'
	cXmlAuto += '						<SeekField>G9B_CODIGO</SeekField>'
	cXmlAuto += '					</ListOfSeekField>'
	cXmlAuto += '				</DeParaXXF>'
	cXmlAuto += '			</Field>'
	cXmlAuto += '			<Field>'
	cXmlAuto += '				<tagName>dataHoraVendaT</tagName>'
	cXmlAuto += '				<fieldProtheus>GIC_DTVEND</fieldProtheus>'
	cXmlAuto += '				<onlyInsert>False</onlyInsert>'
	cXmlAuto += '				<overwrite>True</overwrite>'
	cXmlAuto += '			</Field>'
	cXmlAuto += '			<Field>'
	cXmlAuto += '				<tagName>dataHoraVendaT</tagName>'
	cXmlAuto += '				<fieldProtheus>GIC_HRVEND</fieldProtheus>'
	cXmlAuto += '				<onlyInsert>False</onlyInsert>'
	cXmlAuto += '				<overwrite>True</overwrite>'
	cXmlAuto += '			</Field>'
	cXmlAuto += '			<Field>'
	cXmlAuto += '				<tagName>dataHoraViagemT</tagName>'
	cXmlAuto += '				<fieldProtheus>GIC_DTVIAG</fieldProtheus>'
	cXmlAuto += '				<onlyInsert>False</onlyInsert>'
	cXmlAuto += '				<overwrite>True</overwrite>'
	cXmlAuto += '			</Field>-<Field>'
	cXmlAuto += '				<tagName>dataHoraViagemT</tagName>'
	cXmlAuto += '				<fieldProtheus>GIC_HORA</fieldProtheus>'
	cXmlAuto += '				<onlyInsert>False/onlyInsert><overwrite>True</overwrite>'
	cXmlAuto += '				</Field>'
	cXmlAuto += '				<Field>'
	cXmlAuto += '					<tagName>dataHoraViagemT</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_HORA</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>idLinha</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_LINHA</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>-<DeParaXXF>'
	cXmlAuto += '						<Alias>GI2</Alias>'
	cXmlAuto += '						<XXF_Field>GI2_COD</XXF_Field>'
	cXmlAuto += '						<ColumnNumber>3</ColumnNumber>'
	cXmlAuto += '						<IndiceOrder>1</IndiceOrder>-<ListOfSeekField>'
	cXmlAuto += '							<SeekField>GI2_FILIAL</SeekField>'
	cXmlAuto += '							<SeekField>GI2_COD</SeekField>'
	cXmlAuto += '						</ListOfSeekField>'
	cXmlAuto += '					</DeParaXXF>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>idOrigem</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_LOCORI</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>-<DeParaXXF>'
	cXmlAuto += '						<Alias>GI1</Alias>'
	cXmlAuto += '						<XXF_Field>GI1_COD</XXF_Field>'
	cXmlAuto += '						<ColumnNumber>3</ColumnNumber>'
	cXmlAuto += '						<IndiceOrder>1</IndiceOrder>-<ListOfSeekField>'
	cXmlAuto += '							<SeekField>GI1_FILIAL</SeekField>'
	cXmlAuto += '							<SeekField>GI1_COD</SeekField>'
	cXmlAuto += '						</ListOfSeekField>'
	cXmlAuto += '					</DeParaXXF>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>idDestino</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_LOCDES</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>-<DeParaXXF>'
	cXmlAuto += '						<Alias>GI1</Alias>'
	cXmlAuto += '						<XXF_Field>GI1_COD</XXF_Field>'
	cXmlAuto += '						<ColumnNumber>3</ColumnNumber>'
	cXmlAuto += '						<IndiceOrder>1</IndiceOrder>-<ListOfSeekField>'
	cXmlAuto += '							<SeekField>GI1_FILIAL</SeekField>'
	cXmlAuto += '							<SeekField>GI1_COD</SeekField>'
	cXmlAuto += '						</ListOfSeekField>'
	cXmlAuto += '					</DeParaXXF>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>idServico</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_CODGID</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>-<DeParaXXF>'
	cXmlAuto += '						<Alias>GID</Alias>'
	cXmlAuto += '						<XXF_Field>GID_COD</XXF_Field>'
	cXmlAuto += '						<ColumnNumber>3</ColumnNumber>'
	cXmlAuto += '						<IndiceOrder>1</IndiceOrder>-<ListOfSeekField>'
	cXmlAuto += '							<SeekField>GID_FILIAL</SeekField>'
	cXmlAuto += '							<SeekField>GID_COD</SeekField>'
	cXmlAuto += '						</ListOfSeekField>'
	cXmlAuto += '					</DeParaXXF>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>statusBilhete</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_STATUS</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>tarifa</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_TAR</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>pedagio</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_PED</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>taxaEmbarque</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_TAX</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>seguro</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_SGFACU</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>outros</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_OUTTOT</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>idAgencia</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_AGENCI</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>-<DeParaXXF>'
	cXmlAuto += '						<Alias>GI6</Alias>'
	cXmlAuto += '						<XXF_Field>GI6_CODIGO</XXF_Field>'
	cXmlAuto += '						<ColumnNumber>3</ColumnNumber>'
	cXmlAuto += '						<IndiceOrder>1</IndiceOrder>-<ListOfSeekField>'
	cXmlAuto += '							<SeekField>GI6_FILIAL</SeekField>'
	cXmlAuto += '							<SeekField>GI6_CODIGO</SeekField>'
	cXmlAuto += '						</ListOfSeekField>'
	cXmlAuto += '					</DeParaXXF>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>idUsuario</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_COLAB</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>-<DeParaXXF>'
	cXmlAuto += '						<Alias>GYG</Alias>'
	cXmlAuto += '						<XXF_Field>GYG_CODIGO</XXF_Field>'
	cXmlAuto += '						<ColumnNumber>3</ColumnNumber>'
	cXmlAuto += '						<IndiceOrder>1</IndiceOrder>-<ListOfSeekField>'
	cXmlAuto += '							<SeekField>GYG_FILIAL</SeekField>'
	cXmlAuto += '							<SeekField>GYG_CODIGO</SeekField>'
	cXmlAuto += '						</ListOfSeekField>'
	cXmlAuto += '					</DeParaXXF>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>idEstacao</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_ECF</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>-<DeParaXXF>'
	cXmlAuto += '						<Alias>SL1</Alias>'
	cXmlAuto += '						<XXF_Field>L1_NUM</XXF_Field>'
	cXmlAuto += '						<ColumnNumber>3</ColumnNumber>'
	cXmlAuto += '						<IndiceOrder>1</IndiceOrder>-<ListOfSeekField>'
	cXmlAuto += '							<SeekField>L1_FILIAL</SeekField>'
	cXmlAuto += '							<SeekField>L1_NUM</SeekField>'
	cXmlAuto += '						</ListOfSeekField>'
	cXmlAuto += '					</DeParaXXF>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>sentido</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_SENTID</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>chbpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_CHVBPE</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>numProtocolo</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_NUMPRO</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>numerobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_NUMBPE</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>seriebpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_SERBPE</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>tarifaTabela</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_TABBPE</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>valorBrutobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_VLRBPE</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>valorDescontobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_VLRDSC</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>valorPagobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_VLRPGT</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>tipoDescontobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_TIPDSC</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>descricaoDescontobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_DESDSC</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>codigoCstbpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_CODCST</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>percReducaobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_PREDBP</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>valorBcbpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_VLRBCB</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>aliquotaIcmsbpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_ALIBPE</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>valorIcmsbpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_VLIBPE</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>valorCreditobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_VLCRIC</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>valorIcmsDevidobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_VLICDV</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>simplesNacionalbpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_SIMPNA</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>valorTributosbpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_VLTRIC</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>infoAdicionalbpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_INFADC</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>chaveAcessoEmissorbpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_CHVACE</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>modalidadeBpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_MODALI</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>tipoEmissaobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_TPEMIS</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>tipoBpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_TPBPE:</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>chSubstitutivabpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_CHVSUB</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>tipoSubstituicaobpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_TPSUBS</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>tipoViagembpe</tagName>'
	cXmlAuto += '					<fieldProtheus>GIC_TPVIAG</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>autorizacao1</tagName>'
	cXmlAuto += '					<fieldProtheus>GZP_AUT</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>nsu1</tagName>'
	cXmlAuto += '					<fieldProtheus>GZP_NSU</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>qtdParcelas1</tagName>'
	cXmlAuto += '					<fieldProtheus>GZP_QNTPAR</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>valorPagamento1</tagName>'
	cXmlAuto += '					<fieldProtheus>GZP_VALOR</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>formaPagamento1</tagName>'
	cXmlAuto += '					<fieldProtheus>GZP_TPAGTO</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>idFormaPagamento1</tagName>'
	cXmlAuto += '					<fieldProtheus>GZP_FPAGTO</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>-<Field>'
	cXmlAuto += '					<tagName>descCartao1</tagName>'
	cXmlAuto += '					<fieldProtheus>GZP_DCART</fieldProtheus>'
	cXmlAuto += '					<onlyInsert>False</onlyInsert>'
	cXmlAuto += '					<overwrite>True</overwrite>'
	cXmlAuto += '				</Field>'
	cXmlAuto += '		</ListOfFields>'
	cXmlAuto += '	</Bilhete>'
	cXmlAuto += '</RJIntegra>'
EndIf

If !lAuto
	oRJIntegra:SetServico("Bilhete")
Else
	oRJIntegra:SetServico("Bilhete",,,cXmlAuto)
EndIf

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

//DSERGTP-6567: Novo Log Rest RJ
oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ115")

If oRJIntegra:Get()

	GIC->(DbSetOrder(1))	// GIC_FILIAL+GIC_CODIGO
	nTotReg := oRJIntegra:GetLenItens()
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )

		//nTotReg := IIf(nTotReg > 99, 99, nTotReg)	//TODO: Arrancar esta linha daqui
		
		For nX := 0 To nTotReg

			lContinua := .T.
		
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))  //"Processando registros de Bilhetes - #1/#2... Aguarde!"
				ProcessMessages()
			EndIf
			
			If !Empty(cExtID	:= oRJIntegra:GetJsonValue(nX, 'idTransacao', 'C'))
				cCode := GTPxRetId("TotalBus", "GIC", "GIC_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GIC->(DbSeek(xFilial('GIC') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					oRJIntegra:oGTPLog:SetText(cErro)
				EndIf
				
				If lContinua
					
					oModel:SetOperation(nOpc)
					If oModel:Activate()
						oMdlGIC := oModel:GetModel("GICMASTER")
						oMdlGZP	:= oModel:GetModel("GZPPAGTO")

						For nY := 1 To Len(aFldDePara)
							// recuperando a TAG e o respectivo campo da tabela 
							cTagName    := aFldDePara[nY][1] 
							cCampo      := aFldDePara[nY][2]
							cTipoCpo    := aFldDePara[nY][3]
							lOnlyInsert := aFldDePara[nY][6]
							lOverWrite  := aFldDePara[nY][7]
							cFormPag := oRJIntegra:GetJsonValue(nX, "formaPagamento1", "C")
							// recuperando através da TAG o valor a ser inserido no campo 
							If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)))
									
								If cTagName == "dataHoraVendaT" .and. cCampo = "GIC_HRVEND"
									xValor := substr(xValor,12,5)
								ElseIf cTagName == "dataHoraViagemT"  .and. cCampo = "GIC_HORA"
									xValor := STRTRAN(substr(xValor,12,5),":","")
								ElseIf cTagName == "sentido"  .and. cCampo = "GIC_SENTID"
									xValor := IIF(xValor == "V",'1','2')
								ENDIF
								// verificando a necessidade de realizar o DePara XXF
								If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
									xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
								EndIf
								If !(cCampo $ 'GZP_DCART|GZP_ITEM|GZP_TPAGTO|GZP_VALOR|GZP_QNTPAR|GZP_NSU|GZP_AUT')	
									If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGIC:GetValue(cCampo)) 
										lContinua := oRJIntegra:SetValue(oMdlGIC, cCampo, xValor)
									ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
										lContinua := oRJIntegra:SetValue(oMdlGIC, cCampo, xValor)
									EndIf
								Else
									If cFormPag $ 'CR|DE' 
										If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGZP:GetValue(cCampo)) 
											lContinua := oRJIntegra:SetValue(oMdlGZP, cCampo, xValor)
										ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
											lContinua := oRJIntegra:SetValue(oMdlGZP, cCampo, xValor)
										EndIf
										If lContinua
											lContinua := oRJIntegra:SetValue(oMdlGZP, "GZP_BILREF", oMdlGIC:GetValue("GIC_BILHET"))
											lContinua := oRJIntegra:SetValue(oMdlGZP, "GZP_STAPRO", "0")
											lContinua := oRJIntegra:SetValue(oMdlGZP, "GZP_ITEM", "001")
											lContinua := oRJIntegra:SetValue(oMdlGZP, "GZP_DTVEND", oMdlGIC:GetValue("GIC_DTVEND"))
										EndIf
									EndIf
								EndIf

								If !lContinua 
									oRJIntegra:oGTPLog:SetText(I18N(STR0003 , {cCampo, GTPXErro(oModel)})) //"Falha ao gravar o valor do campo #1 (#2)."										
								EndIf
							EndIf
						Next nY
						
						If lContinua
							lContinua := oRJIntegra:SetValue(oMdlGIC, "GIC_INTEGR", '1', .T.)						
						EndIf
						
						If lContinua
							lContinua := oRJIntegra:SetValue(oMdlGIC, "GIC_TIPO", 'I', .T.)
						EndIf
						
						If lContinua 
							If (lContinua := oModel:VldData() )
								oModel:CommitData()
								CFGA070MNT("TotalBus", "GIC", "GIC_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGIC:GetValue('GIC_CODIGO'), 'GIC')))
							Else
								oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)})) //"Falha ao carregar modelos de dados (#1)."
							EndIf
						Else
							oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)})) //"Falha ao carregar modelos de dados (#1)."
						EndIf
						oModel:DeActivate()
					Else
						oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)})) //"Falha ao carregar modelos de dados (#1)."
						//DSERGTP-6567: Novo Log Rest RJ
						RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText())
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
		lMonit := .F.	//Precisará efetuar o disarmTransaction
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
GTPDestroy(oMdlGIC)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI115Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI115Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	henrique.toyada
@since 		28/03/2019
@version 	1.0
/*/
//GI115Job('10','20200326','0000','20200326','2359','000000','999999')
//------------------------------------------------------------------------------------------
Function GI115Job(aParam, lAuto)
Local nPosEmp := 0
Local nPosFil := 0

Default lAuto := .F.

nPosEmp := IF(Len(aParam) == 11, 8, IF(Len(aParam) == 9, 6, 1))
nPosFil := IF(Len(aParam) == 11, 9, IF(Len(aParam) == 9, 7, 2))
//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[nPosEmp],aParam[nPosFil])
If Len(aParam) == 11
	GI115Receb(.F., Nil, aParam[1], STOD(aParam[2]), aParam[3], STOD(aParam[4]), aParam[5], aParam[6], aParam[7],,lAuto)
ElseIf Len(aParam) == 9
	GI115Receb(.F., Nil, aParam[1], STOD(aParam[2]), aParam[3], STOD(aParam[4]), aParam[5],,,,lAuto)
Else
	GTPIRJ115(.F.,,,lAuto)
EndIf

RpcClearEnv()

Return
