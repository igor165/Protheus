#Include "Protheus.ch"
#Include "TMSrepom.ch"
#Include 'FWMVCDef.ch'
#Include "XMLXFUN.CH"

Static lTM310XML  := ExistBlock('TM310XML')
Static lTM240XML  := ExistBlock('TM240XML'  )
Static lTM251XML  := ExistBlock('TM251XML')
Static lOM100XML  := ExistBlock('OM100XML')
Static lTM251Ope  := ExistBlock('TM251Ope')
Static lTM250NfOp := ExistBlock('TM250NfOp')
Static lRepTrace  := SuperGetMv("MV_REPTRAC",,.T.) .And.  GetMV( 'MV_TMSXML',, .F. )
Static lRestRepom := SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'
Static cTmsErp    := SuperGetMV("MV_TMSERP",,'0') //  Verifica se o TMS está integrado com o Protheus ou Outro ERP

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAtualOp³ Autor ³ Vitor Raspa                               ³ Data ³ 28.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza dados da Operadora (Motorista, Veiculo e Fornec.)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAtualOp(cExpC1,ExpC2,ExpA1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da Operadora de Frotas/Vale-Pedagio                             ³±±
±±³          ³                                                                                ³±±
±±³          ³ ExpC2 - Tipo da Atualizacao:                                                   ³±±
±±³          ³         1-Fornecedores/2-Motoristas/3-Veiculos/4-Carretas/5-Todos              ³±±
±±³          ³                                                                                ³±±
±±³          ³ ExpA1 - Array Com os Codigos Correspondentes:                                  ³±±
±±³          ³         ExpA2[1] - Codigo/Loja do Fornecedor                                   ³±±
±±³          ³         ExpA2[2] - Codigo do Motorista                                         ³±±
±±³          ³         ExpA2[3] - Codigo do Veiculo                                           ³±±
±±³          ³         ExpA2[4] - Codigo da Carreta                                           ³±±
±±³          ³ ExpL1 - .T. para exibir a mensagem de OK quanto a atualizacao dos dados        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RepAtualOp( cCodOpe, cTpAtualiz, aCodigos, lMsgOk )

Local lRet       := .T.
Local aArea      := GetArea()
Local aMsgErr    := {}
Local aVisErr    := {}
Local oObj
Local nAux

Local cCGC := cTpPessoa := cNome := cNReduz := ''
Local cEnd := cBairro := cCidade := cCEP := ''
Local cEstado := cTel := cTel2 := cEMail := cContato := cCodINSS := ''
Local nNumDep    := 0
Local cVeiRas    := ''
Local cDtNasc    := ''
Local cRgDt      := ''
Local cDtECNH    := ''
Local cDtVCNH    := ''
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Local cXMLFornec := ''
Local cXMLMotor  := ''
Local cXMLVeicul := ''
Local cXMLCarret := ''

Local lLogForn    := .F.
Local lLogMotor   := .F.
Local lLogVeic    := .F.
Local lLogCarreta := .F.
Local lHired	:= .F.
Local lDriver	:= .F.
Local lVei1		:= .F.
Local lVei2		:= .F.

Local cCNPJEmprMt := SuperGetMv( "MV_EMPRMOT", .F., AllTrim(SM0->M0_CGC) ) //-- Parametro para retornar o CNPJ do empregador do Motorista Proprio
Default lMsgOk   := .F.

TmsRepTrac("Inicio de Função")
//-- Seta definicao de variaveis com ate 255 caracteres
SetVarNameLen( 255 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³POSICIONA NO CADASTRO DA OPERADORA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEG->( DbSetOrder(1) )
If DEG->( MsSeek(xFilial('DEG')+cCodOpe) )

	For nAux := 1 To Len(aCodigos)
		If lRestRepom
			SA2->( DbSetOrder(1) )
			If (cTpAtualiz == '1' .Or. cTpAtualiz == '5') .And. !Empty(aCodigos[nAux][1]) .And. aCodigos[nAux][1] <> 'SM0' .And. SA2->( MsSeek(xFilial('SA2')+aCodigos[nAux][1]) )
				lHired := TMSHired( Left(Alltrim(aCodigos[nAux][1]),TamSx3("A2_COD")[1]), Right(Alltrim(aCodigos[nAux][1]),TamSx3("A2_LOJA")[1]) )
			EndIf
			//-- Posiciona no cadastro do Motorista
			DA4->( DbSetOrder(1) )
			If (cTpAtualiz == '2' .Or. cTpAtualiz == '5') .And. !Empty(aCodigos[nAux][2]) .And.	DA4->( MsSeek(xFilial('DA4')+aCodigos[nAux][2]) )
				lDriver := TMSDriver( aCodigos[nAux][2] )
			EndIf
			//-- Posiciona no cadastro do Veiculo
			DA3->( DbSetOrder(1) )
			If (cTpAtualiz == '3' .Or. cTpAtualiz == '5') .And. !Empty(aCodigos[nAux][3]) .And.	DA3->( MsSeek(xFilial('DA3')+aCodigos[nAux][3]) )
				lVei1 := TMSVehic( aCodigos[nAux][3] )
			EndIf
			//-- Posiciona no cadastro do Veiculo
			DA3->( DbSetOrder(1) )
			If (cTpAtualiz == '4' .Or. cTpAtualiz == '5') .And. !Empty(aCodigos[nAux][4]) .And. DA3->( MsSeek(xFilial('DA3')+aCodigos[nAux][4]) )
				lVei2 := TMSVehic( aCodigos[nAux][4] )
			EndIf

			If lHired .OR. lDriver .OR. lVei1 .OR. lVei2
				Aviso(	STR0001,;	//-- 'Aviso'
						STR0002,;	//-- 'Dados da Operadora Atualizados com Sucesso!'
						{STR0003})	//-- 'Ok'
			EndIf
		Else
			//-- Posiciona no Cadastro do Fornecedor
			SA2->( DbSetOrder(1) )
			If (cTpAtualiz == '1' .Or. cTpAtualiz == '5') .And. !Empty(aCodigos[nAux][1]) .And. aCodigos[nAux][1] <> 'SM0' .And. SA2->( MsSeek(xFilial('SA2')+aCodigos[nAux][1]) )
				cCGC       := AllTrim(SA2->A2_CGC)
				cTpPessoa  := IIF(SA2->A2_TIPO == 'F', '0', '1')
				cNome      := AllTrim(SA2->A2_NOME)
				cNReduz    := AllTrim(SA2->A2_NREDUZ)
				cEnd       := AllTrim(SA2->A2_END)
				cBairro    := AllTrim(SA2->A2_BAIRRO)
				cCidade    := AllTrim(SA2->A2_MUN)
				cCEP       := AllTrim(SA2->A2_CEP)
				cEstado    := AllTrim(SA2->A2_EST)
				cTel       := AllTrim(SA2->A2_DDD) + AllTrim(SA2->A2_TEL)
				cTel2      := AllTrim(SA2->A2_DDD) + AllTrim(SA2->A2_FAX)
				cEMail     := AllTrim(SA2->A2_EMAIL)
				cContato   := AllTrim(SA2->A2_CONTATO)
				cCodINSS   := AllTrim(SA2->A2_CODINSS)
				nNumDep    := SA2->A2_NUMDEP

				cXMLFornec := ''
				cXMLFornec += '<contratado>'
				cXMLFornec += 	'<contratado_cnpj_cpf>' 	+ AllTrim(cCGC)		+ '</contratado_cnpj_cpf>'
				cXMLFornec += 	'<pessoa_tipo>' 			+ cTpPessoa + '</pessoa_tipo>'
				cXMLFornec += 	'<nome_contratado>' 		+ cNome		+ '</nome_contratado>'
				cXMLFornec += 	'<nome_fantasia>' 			+ cNReduz	+ '</nome_fantasia>'
				cXMLFornec += 	'<endereco>' 				+ cEnd		+ '</endereco>'
				cXMLFornec += 	'<bairro>' 					+ cBairro	+ '</bairro>'
				cXMLFornec += 	'<cidade>' 					+ cCidade	+ '</cidade>'
				cXMLFornec += 	'<cep>' 					+ AllTrim(cCEP)		+ '</cep>'
				cXMLFornec += 	'<estado>'					+ cEstado	+ '</estado>'
				cXMLFornec += 	'<telefone1>'				+ cTel		+ '</telefone1>'
				cXMLFornec += 	'<telefone2>' 				+ cTel2		+ '</telefone2>'
				cXMLFornec += 	'<celular></celular>'
				cXMLFornec += 	'<email>' 					+ cEMail	+ '</email>'
				cXMLFornec += 	'<contato>' 				+ cContato	+ '</contato>'
				cXMLFornec += 	'<dependentes>' + If(!Empty(cCodINSS), AllTrim(Str(nNumDep,2)), '') + '</dependentes>'
				cXMLFornec += 	'<inss_codigo>' + cCodINSS + '</inss_codigo>'
				cXMLFornec += 	'<inss_simplificado>'+ If(Empty(cCodINSS), '0', '1') + '</inss_simplificado>'	//-- 0-Nao Exige o Cod. INSS

				cXMLFornec += 	'<rntrc_codigo>' 				+ Alltrim(SA2->A2_RNTRC) + '</rntrc_codigo>' //Novo
				cXMLFornec += 	'<dados_bancarios>'
				cXMLFornec += 		'<banco>'					+ AllTrim(SA2->A2_BANCO) 			+ '</banco>'
				cXMLFornec += 		'<agencia>'					+ SubStr(SA2->A2_AGENCIA,1,IIF(At('-',SA2->A2_AGENCIA) > 0, At('-',SA2->A2_AGENCIA)-1, Len(SA2->A2_AGENCIA) ) )	+ '</agencia>'
				cXMLFornec += 		'<agencia_dv>' 				+ IIF(At('-',SA2->A2_AGENCIA) > 0, SubStr(SA2->A2_AGENCIA,At('-',SA2->A2_AGENCIA)+1,1),'')	+ '</agencia_dv>'
				cXMLFornec += 		'<conta_corrente>' 			+ SubStr(SA2->A2_NUMCON,1,IIF(At('-',SA2->A2_NUMCON) > 0, At('-',SA2->A2_NUMCON)-1, Len(SA2->A2_NUMCON))) + '</conta_corrente>'
				cXMLFornec += 		'<conta_corrente_dv>' 		+ IIF(At('-',SA2->A2_NUMCON) > 0, SubStr(SA2->A2_NUMCON,At('-',SA2->A2_NUMCON)+1,1),'')	+ '</conta_corrente_dv>'
				cXMLFornec += 		'<titular_conta_corrente>' + AllTrim(Left(SA2->A2_NOME,40))											+ '</titular_conta_corrente>'
				cXMLFornec += 		'<titular_cnpj_cpf_conta_corrente>' + AllTrim(SA2->A2_CGC)											+ '</titular_cnpj_cpf_conta_corrente>'
				cXMLFornec += 	'</dados_bancarios>'
				cXMLFornec += '</contratado>'

				lLogForn := .T.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³CADASTRO DE MOTORISTAS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//-- Posiciona no cadastro do Motorista
			DA4->( DbSetOrder(1) )
			If (cTpAtualiz == '2' .Or. cTpAtualiz == '5') .And. !Empty(aCodigos[nAux][2]) .And.	DA4->( MsSeek(xFilial('DA4')+aCodigos[nAux][2]) )

				cDtNasc := SubStr(DtoS(DA4->DA4_DATNAS),7,2) + '/' + SubStr(DtoS(DA4->DA4_DATNAS),5,2) + '/' + SubStr(DtoS(DA4->DA4_DATNAS),1,4)
				cRgDt   := SubStr(DtoS(DA4->DA4_RGDT),7,2) + '/' + SubStr(DtoS(DA4->DA4_RGDT),5,2) + '/' + SubStr(DtoS(DA4->DA4_RGDT),1,4)
				cDtECNH := SubStr(DtoS(DA4->DA4_DTECNH),7,2) + '/' + SubStr(DtoS(DA4->DA4_DTECNH),5,2) + '/' + SubStr(DtoS(DA4->DA4_DTECNH),1,4)
				cDtVCNH := SubStr(DtoS(DA4->DA4_DTVCNH),7,2) + '/' + SubStr(DtoS(DA4->DA4_DTVCNH),5,2) + '/' + SubStr(DtoS(DA4->DA4_DTVCNH),1,4)

				cXMLMotor := ''
				cXMLMotor += '<motorista>'
				cXMLMotor += 	'<cpf>'						+ AllTrim(DA4->DA4_CGC)		+ '</cpf>'
				SA2->(DbSetOrder(1))
				If DA4->DA4_TIPMOT <> '1' .And. SA2->(MsSeek(xFilial('SA2')+DA4->DA4_FORNEC+DA4->DA4_LOJA))
					cXMLMotor += 	'<contratado_cnpj_cpf>' 	+ AllTrim(SA2->A2_CGC) 		+ '</contratado_cnpj_cpf>'
				Else
					cXMLMotor +=  	'<contratado_cnpj_cpf>' +  AllTrim(cCNPJEmprMt) 				+ '</contratado_cnpj_cpf>'
				EndIf
				cXMLMotor += 	'<nome>' 					+ Left(DA4->DA4_NOME,40)	+ '</nome>'
				cXMLMotor += 	'<endereco>' 				+ Left(DA4->DA4_END,40)		+ '</endereco>'
				cXMLMotor += 	'<bairro>' 					+ Left(DA4->DA4_BAIRRO,20)	+ '</bairro>'
				cXMLMotor += 	'<cidade>' 					+ Left(DA4->DA4_MUN,30)		+ '</cidade>'
				cXMLMotor += 	'<cep>' 					+ AllTrim(DA4->DA4_CEP)				+ '</cep>'
				cXMLMotor += 	'<estado>' 					+ DA4->DA4_EST				+ '</estado>'
				cXMLMotor += 	'<telefone>'				+ DA4->DA4_TEL				+ '</telefone>'
				cXMLMotor += 	'<celular></celular>'
				cXMLMotor += 	'<email></email>'
				cXMLMotor += 	'<naturalidade></naturalidade>'
				cXMLMotor += 	'<naturalidade_estado></naturalidade_estado>'
				cXMLMotor += 	'<data_nascimento>' 		+ cDtNasc		+ '</data_nascimento>'
				cXMLMotor += 	'<nome_pai>' 				+ Left(DA4->DA4_PAI,40)		+ '</nome_pai>'
				cXMLMotor += 	'<nome_mae>' 				+ Left(DA4->DA4_MAE,40)		+ '</nome_mae>'
				cXMLMotor += 	'<rg>' 						+ DA4->DA4_RG 					+ '</rg>'
				cXMLMotor += 	'<rg_data_emissao>'			+ cRgDt		+ '</rg_data_emissao>'
				cXMLMotor += 	'<rg_orgao_emissor>' 		+ DA4->DA4_RGORG				+ '</rg_orgao_emissor>'
				cXMLMotor += 	'<rg_estado_emissor>' 		+ DA4->DA4_RGEST 				+ '</rg_estado_emissor>'
				cXMLMotor += 	'<carteira_habilitacao>'	+ AllTrim(DA4->DA4_NUMCNH) + '</carteira_habilitacao>'
				cXMLMotor += 	'<carteira_habilitacao_data_emissao>' 		+ cDtECNH	+ '</carteira_habilitacao_data_emissao>'
				cXMLMotor += 	'<carteira_habilitacao_categoria>' 			+ DA4->DA4_CATCNH		+ '</carteira_habilitacao_categoria>'
				cXMLMotor += 	'<carteira_habilitacao_data_validade>' 		+ cDtVCNH	+ '</carteira_habilitacao_data_validade>'
				cXMLMotor += 	'<carteira_habilitacao_data_habilitacao>' 	+ cDtECNH	+ '</carteira_habilitacao_data_habilitacao>'
				cXMLMotor += '</motorista>'

				lLogMotor := .T.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³CADASTRO DE VEICULOS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//-- Posiciona no cadastro do Veiculo
			DA3->( DbSetOrder(1) )
			If (cTpAtualiz == '3' .Or. cTpAtualiz == '5') .And. !Empty(aCodigos[nAux][3]) .And.	DA3->( MsSeek(xFilial('DA3')+aCodigos[nAux][3]) )

				//Tag: Rastreador:
				// 0 = Nao Considera o Cod. do Rastreador
				// 1 = Codigo do Rastreador Obrigatorio
				// 2 = Rastreador da REPOM

				If DA3->DA3_VEIRAS == '1' //-- Sim
					cVeiRas := '1'
				ElseIf DA3->DA3_VEIRAS == '2' //-- Nao
					cVeiRas := '0'
				ElseIf DA3->DA3_VEIRAS == '3' // Rast. p/ REPOM
					cVeiRas := '2'
				EndIf

				cXMLVeicul := ''
				cXMLVeicul += '<veiculo>'

				SA2->( DbSetOrder(1) )
				If DA3->DA3_FROVEI <> '1' .And. SA2->( MsSeek(xFilial('SA2')+DA3->DA3_CODFOR+DA3->DA3_LOJFOR) )
					cXMLVeicul += 	'<contratado_cnpj_cpf>' 	+ AllTrim(SA2->A2_CGC) 		+ '</contratado_cnpj_cpf>'
				Else
					cXMLVeicul +=  '<contratado_cnpj_cpf>' +  AllTrim(cCNPJEmprMt) 				+ '</contratado_cnpj_cpf>'
				EndIf

				cXMLVeicul += 	'<placa>' 				+ DA3->DA3_PLACA 					+ '</placa>'
				cXMLVeicul += 	'<marca>'				+ Tabela("M6",DA3->DA3_MARVEI,.F.)  + '</marca>'
				cXMLVeicul += 	'<modelo>' 				+ Left(DA3->DA3_DESC,30)			+ '</modelo>'
				cXMLVeicul += 	'<numero_eixos>'		+ AllTrim(Str(DA3->DA3_QTDEIX,1))			+ '</numero_eixos>'
				cXMLVeicul += 	'<ano>' 				+ DA3->DA3_ANOMOD					+ '</ano>'
				cXMLVeicul += 	'<cor>' 				+ Tabela("M7",DA3->DA3_CORVEI,.F.)	+ '</cor>'
				cXMLVeicul += 	'<numero_chassis>'		+ DA3->DA3_CHASSI 					+ '</numero_chassis>'
				cXMLVeicul += 	'<renavam>'				+ AllTrim(DA3->DA3_RENAVA)					+'</renavam>'
				cXMLVeicul += 	'<cidade>' 				+ Left(DA3->DA3_MUNPLA,40)			+ '</cidade>'
				cXMLVeicul += 	'<estado>' 				+ DA3->DA3_ESTPLA					+ '</estado>'
				cXMLVeicul += 	'<rastreador>'			+ cVeiRas							+ '</rastreador>'
				cXMLVeicul += 	'<rastreador_codigo></rastreador_codigo>'
				cXMLVeicul += 	'<semi_reboque></semi_reboque>'
				cXMLVeicul += 	'<peso></peso>'
				cXMLVeicul += 	'<volume></volume>'
				cXMLVeicul += 	'<tipo_veiculo>0</tipo_veiculo>'    //0-Indefinido (Novo)
				cXMLVeicul += '</veiculo>'

				lLogVeic := .T.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³CADASTRO DE VEICULOS - CARRETA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//-- Posiciona no cadastro do Veiculo
			DA3->( DbSetOrder(1) )
			If (cTpAtualiz == '4' .Or. cTpAtualiz == '5') .And. !Empty(aCodigos[nAux][4]) .And. DA3->( MsSeek(xFilial('DA3')+aCodigos[nAux][4]) )

				cXMLCarret := ''
				cXMLCarret += '<carreta>'

				SA2->( DbSetOrder(1) )
				If DA3->DA3_FROVEI <> '1' .And. SA2->( MsSeek(xFilial('SA2')+DA3->DA3_CODFOR+DA3->DA3_LOJFOR) )
					cXMLCarret += 	'<contratado_cnpj_cpf>' 	+ AllTrim(SA2->A2_CGC) 		+ '</contratado_cnpj_cpf>'
				Else
					cXMLCarret += 	'<contratado_cnpj_cpf>' +  cCNPJEmprMt 				+ '</contratado_cnpj_cpf>'
				EndIf

				cXMLCarret += 	'<placa>' 				+ DA3->DA3_PLACA					+ '</placa>'
				cXMLCarret += 	'<numero_eixos>' 		+ Str(DA3->DA3_QTDEIX,1) 			+ '</numero_eixos>'
				cXMLCarret += 	'<ano>' 				+ DA3->DA3_ANOMOD					+ '</ano>'
				cXMLCarret += 	'<cor>' 				+ Tabela('M7',DA3->DA3_CORVEI,.F.)	+ '</cor>'
				cXMLCarret += 	'<numero_chassis>'		+ DA3->DA3_CHASSI					+ '</numero_chassis>'
				cXMLCarret += 	'<renavam>'				+ DA3->DA3_RENAVA					+ '</renavam>'
				cXMLCarret += 	'<cidade>' 				+ Left(DA3->DA3_MUNPLA,40)			+ '</cidade>'
				cXMLCarret += 	'<estado>' 				+ DA3->DA3_ESTPLA					+ '</estado>'
				cXMLCarret += '</carreta>'

				lLogCarreta := .T.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PREPARACAO PARA CONECTAR AO WS - REPOM³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			TmsRepTrac("IntegraDadosCadastroNacionalANTT - Instanciando")
			oObj := WSIntegracao():New()
			TmsRepTrac("IntegraDadosCadastroNacionalANTT - Instanciado")
			oObj:cStrCliente           := DEG->DEG_IDOPE
			oObj:cStrAssinaturaDigital := DEG->DEG_CODACE
			oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora

			If cTpAtualiz == '1' .Or. cTpAtualiz == '5'
				cXMLFornec := TMSNoAcento( cXMLFornec )
				//-- Gera XM em disco
				If lTMSXML
					TMSLogXML( cXMLFornec, 'IntegraDadosCadastroNacionalANTT-Fornec.XML' )
				EndIf
				oObj:cStrXMLInContratado	:= cXMLFornec
			EndIf

			If cTpAtualiz == '2' .Or. cTpAtualiz == '5'
				cXMLMotor := TMSNoAcento( cXMLMotor )
				//-- Gera XM em disco
				If lTMSXML
					TMSLogXML( cXMLMotor, 'IntegraDadosCadastroNacionalANTT-Motor.XML' )
				EndIf
				oObj:cStrXMLInMotorista		:= cXMLMotor
			EndIf

			If cTpAtualiz == '3' .Or. cTpAtualiz == '5'
				cXMLVeicul := TMSNoAcento( cXMLVeicul )
				//-- Gera XM em disco
				If lTMSXML
					TMSLogXML( cXMLVeicul, 'IntegraDadosCadastroNacionalANTT-Veicul.XML' )
				EndIf
				oObj:cStrXMLInVeiculo		:= cXMLVeicul
			EndIf

			If cTpAtualiz == '4' .Or. cTpAtualiz == '5'
				cXMLCarret := TMSNoAcento( cXMLCarret )
				//-- Gera XM em disco
				If lTMSXML
					TMSLogXML( cXMLCarret, 'IntegraDadosCadastroNacional-Carreta.XML' )
				EndIf
				oObj:cStrXMLInCarreta		:= cXMLCarret
			EndIf

			TmsRepTrac("IntegraDadosCadastroNacionalANTT - Consumindo")
			If oObj:IntegraDadosCadastroNacionalANTT()
				TmsRepTrac("IntegraDadosCadastroNacionalANTT - Consumido OK " + AllToChar(oObj:lIntegraDadosCadastroNacionalANTTResult))
				If oObj:lIntegraDadosCadastroNacionalANTTResult
					If lMsgOk
						Aviso(	STR0001,;	//-- 'Aviso'
								STR0002,;	//-- 'Dados da Operadora Atualizados com Sucesso!'
								{STR0003})	//-- 'Ok'
					EndIf

					//-- Atualiza o LOG de Transacoes
					If lLogForn
						TMSGerLog( 	cCodOpe,;
									'FR',;
									'E',;
									xFilial('SA2')+aCodigos[nAux][1],;
									'SA2',;
									'0' )
					EndIf
					If lLogMotor
						TMSGerLog( 	cCodOpe,;
									'MT',;
									'E',;
									xFilial('DA4')+aCodigos[nAux][2],;
									'DA4',;
									'0' )
					EndIf
					If lLogVeic
						TMSGerLog( 	cCodOpe,;
									'VE',;
									'E',;
									xFilial('DA3')+aCodigos[nAux][3],;
									'DA3',;
									'0' )
					EndIf
					If lLogCarreta
						TMSGerLog( 	cCodOpe,;
									'VE',;
									'E',;
									xFilial('DA3')+aCodigos[nAux][4],;
									'DA3',;
									'0' )
					EndIF
				Else
					aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
					TmsRepTrac("IntegraDadosCadastroNacionalANTT - Consumido OK - Error Oper: "+ AllToChar(oObj:cStrXMLErr) )
					lRet := .F.
				EndIf
			Else
				TmsRepTrac("IntegraDadosCadastroNacionalANTT - Consumido NOK " )
				aMsgErr := TMSErrOper(cCodOpe,'','2')
				lRet := .F.
			EndIf
		EndIf
		If !lRet
			Exit
		EndIf

	Next
EndIf
SetVarNameLen( 10 )

If !Empty(aMsgErr)
	TmsRepTrac("IntegraDadosCadastroNacionalANTT - Erro: "+ AllToChar(VarInfo("aMsgErr",aMsgErr)) )
	AaddMsgErr( aMsgErr, aVisErr )
	TmsMsgErr( aVisErr )
EndIf
TmsRepTrac("Fim de Função")
RestArea(aArea)
Return(lRet)


//----------------------------------------------------------------------------------------------------
Function RepSolicRt( cRota, cCdrOri, cCdrDes, aVias, cEstOri, cCdMunOri, cEstDes, cCdMunDes)

Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local oDlgEsp
Local aHeadEsp  := {}
Local aColEsp   := { { "UP", "DOWN", Space( 100 ), .F. } }
Local cMunOri   := CriaVar( "CC2_MUN", .T. )
Local cMunDes   := CriaVar( "CC2_MUN", .T. )
Local lIdaEVolta:= .F.
Local nOpcao    := 0
Local cXML      := ""
Local nI
Local aViasDig	:= {}
Local oRepom	:= Nil

Default cRota     := ""
Default cCdrOri   := ""
Default cCdrDes   := ""
Default aVias     := {}
Default cEstOri   := CriaVar( "CC2_EST", .T. )
Default cCdMunOri := CriaVar( "CC2_CODMUN", .T. )
Default cEstDes   := CriaVar( "CC2_EST", .T. )
Default cCdMunDes := CriaVar( "CC2_CODMUN", .T. )

TmsRepTrac("Inicio de Função")

//-- Monta aHeader Manual
Aadd( aHeadEsp, { "", "UP", "@BMP", 1, 0, "", "", "", "", "", "", "'UP'" } )
Aadd( aHeadEsp, { "", "DOWN", "@BMP", 1, 0, "", "", "", "", "", "", "'DOWN'" } )
Aadd( aHeadEsp, { STR0005, "VIA", "@!", 100, 0, , , "C", , "V", , , , "A", , , } ) //-- "Via"

//-- Dimensoes padroes
aSize   := MsAdvSize(.T.)

//-- Reduz a tela em aproximadamente 15%
aEval( aSize, { | nSize, y | If( nSize > 0, aSize[y] := Int( nSize / 1.13 ), Nil ) } )

//-- Dimensiona os objetos
AAdd( aObjects, { 100, 002, .T., .T. } )
AAdd( aObjects, { 100, 018, .T., .T. } )
AAdd( aObjects, { 100, 080, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

//-- Inicializa Região de Origem
If !Empty(cCdrOri)
	cEstOri   := Posicione( "DUY", 1, xFilial("DUY") + cCdrOri, "DUY_EST" )
	cCdMunOri := Posicione( "DUY", 1, xFilial("DUY") + cCdrOri, "DUY_CODMUN" )
EndIf
If !Empty(cCdMunOri)
	cMunOri := Posicione( "CC2", 1, xFilial("CC2") + cEstOri + cCdMunOri, "CC2_MUN" )
EndIf

If !Empty(cCdMunDes)
	cMunDes := Posicione( "CC2", 1, xFilial("CC2") + cEstDes + cCdMunDes, "CC2_MUN" )
EndIf

DEFINE MSDIALOG oDlgEsp TITLE STR0004 FROM aSize[7], 00 TO aSize[6], aSize[5] PIXEL //-- 'Solicitação de Roteiro Repom'

	@ aPosObj[2,1]   ,aPosObj[2,2]     SAY STR0009 Of oDlgEsp PIXEL  SIZE 010,009 //-- 'UF'
	@ aPosObj[2,1]+10,aPosObj[2,2]     MsGet cEstOri F3 "12" Valid Empty(cEstOri) .OR. ExistCpo("SX5","12"+cEstOri);
											PICTURE PesqPict('CC2','CC2_EST')    SIZE 020,007 OF oDlgEsp PIXEL

	@ aPosObj[2,1]   ,aPosObj[2,2]+030 SAY STR0007 Of oDlgEsp PIXEL  SIZE 020,009 //-- 'Origem'
	@ aPosObj[2,1]+10,aPosObj[2,2]+030 MsGet cCdMunOri F3 "CC2" Valid Eval({|| Iif(Empty(cCdMunOri) .Or. ExistCpo("CC2",cEstOri+cCdMunOri),;
																(cMunOri := Posicione("CC2",1, xFilial("CC2")+cEstOri+cCdMunOri,"CC2_MUN"), .T.),;
																.F.) });
											PICTURE PesqPict('CC2','CC2_CODMUN') SIZE 035,007 OF oDlgEsp PIXEL

	@ aPosObj[2,1]   ,aPosObj[2,2]+070 SAY STR0010 Of oDlgEsp PIXEL  SIZE 060,009 //-- 'Des.Origem''
	@ aPosObj[2,1]+10,aPosObj[2,2]+070 MsGet cMunOri ;
											PICTURE PesqPict('CC2','CC2_MUN') WHEN .F. SIZE 110,007 OF oDlgEsp PIXEL

	@ aPosObj[2,1]   ,aPosObj[2,2]+210 SAY STR0009 Of oDlgEsp PIXEL  SIZE 010,009 //-- 'UF'
	@ aPosObj[2,1]+10,aPosObj[2,2]+210 MsGet cEstDes F3 "12" Valid Empty(cEstDes) .Or. ExistCpo("SX5","12"+cEstDes);
											PICTURE PesqPict('CC2','CC2_EST')    SIZE 020,007 OF oDlgEsp PIXEL

	@ aPosObj[2,1]   ,aPosObj[2,2]+240 SAY STR0008 Of oDlgEsp PIXEL  SIZE 020,009 //-- 'Destino'
	@ aPosObj[2,1]+10,aPosObj[2,2]+240 MsGet cCdMunDes F3 "CC2" Valid Eval({|| Iif(Empty(cCdMunDes) .Or. ExistCpo("CC2",cEstDes+cCdMunDes),;
																(cMunDes := Posicione("CC2",1, xFilial("CC2")+cEstDes+cCdMunDes,"CC2_MUN"), .T.),;
																.F.) });
											PICTURE PesqPict('CC2','CC2_CODMUN') SIZE 035,007 OF oDlgEsp PIXEL

	@ aPosObj[2,1]   ,aPosObj[2,2]+280 SAY STR0011 Of oDlgEsp PIXEL  SIZE 060,009 //-- 'Des.Destino''
	@ aPosObj[2,1]+10,aPosObj[2,2]+280 MsGet cMunDes PICTURE PesqPict('CC2','CC2_MUN') WHEN .F. SIZE 110,007 OF oDlgEsp PIXEL

	@ aPosObj[2,1]   ,aPosObj[2,2]+400 SAY STR0036  Of oDlgEsp PIXEL  SIZE 060,009 //-- "Pedágio Ida e Volta?"
	@ aPosObj[2,1]+10,aPosObj[2,2]+400 CHECKBOX oChk VAR lIdaEVolta  PROMPT STR0036  SIZE 060,007 OF oDlgEsp PIXEL //-- "Pedágio Ida e Volta?"


	@ aPosObj[3,1],aPosObj[2,2] SAY STR0006 Of oDlgEsp PIXEL  SIZE 100,009  //-- 'Trajeto (opcional)'

	//MSNewGetDados():New(                     nTop,        nLeft,      nBottom,       nRight,                        nStyle ,      uLinhaOk,       uTudoOk, cIniCpos, aAlter, nFreeze, nMax, cFieldOk, uSuperDel ,  uDelOk, oWnd   , aParHeader, aParCols)
	oGetSub := MSNewGetDados():New( aPosObj[3,1]+10, aPosObj[3,2], aPosObj[3,3], aPosObj[3,4],  GD_INSERT+GD_UPDATE+GD_DELETE, "AllWaysTrue", "AllWaysTrue",       ,       ,        0, 9999,         ,           ,      "AllWaysTrue", oDlgEsp, aHeadEsp, aColEsp)
	oGetSub:oBrowse:bLDblClick := { |a,nCol| If( nCol==1, If( oGetSub:oBrowse:nAt > 1, ;
															(aAux := aClone(oGetSub:aCols[oGetSub:oBrowse:nAt]),;
															oGetSub:aCols[oGetSub:oBrowse:nAt]   := aClone(oGetSub:aCols[oGetSub:oBrowse:nAt-1]),;
															oGetSub:aCols[oGetSub:oBrowse:nAt-1] := aClone(aAux),;
															oGetSub:oBrowse:nAt-- ,;
															oGetSub:oBrowse:Refresh(.T.) ), Nil ), ;
														  If( nCol == 2, If(oGetSub:oBrowse:nAt < Len(oGetSub:aCols),;
																(aAux := aClone(oGetSub:aCols[oGetSub:oBrowse:nAt]),;
																oGetSub:aCols[oGetSub:oBrowse:nAt] := aClone(oGetSub:aCols[oGetSub:oBrowse:nAt+1]),;
																oGetSub:aCols[oGetSub:oBrowse:nAt+1] := aClone(aAux),;
																oGetSub:oBrowse:nAt++,;
																oGetSub:oBrowse:Refresh(.T.) ), Nil ), Nil ) ) }

ACTIVATE MSDIALOG oDlgEsp  CENTERED ON INIT EnchoiceBar( oDlgEsp, { || If( oGetSub:TudoOk(), ( nOpcao := 1, oDlgEsp:End() ), .F. ) }, { || oDlgEsp:End() }, , )

If nOpcao == 1
	If lRestRepom
		For nI := 1 To Len(oGetSub:aCols)
			If !GdDeleted( nI, oGetSub:aHeader, oGetSub:aCols ) .And. !Empty( GdFieldGet( "VIA", nI, , oGetSub:aHeader, oGetSub:aCols ) )
				AAdd( aViasDig, AllTrim( GdFieldGet( "VIA", nI, , oGetSub:aHeader, oGetSub:aCols ) ) )
			EndIf
		Next nI
		
		oRepom := TMSBCARepomFrete():New()
    	oRepom:Auth()

	Else
		//-- Monta o XML
		cXML := ""
		cXML += "<solicita_roteiros>                                                "
		cXML += "  <roteiro>                                                        "
		cXML += "    <roteiro_codigo_cliente>"+AllTrim(cRota)+"</roteiro_codigo_cliente>     "
		cXML += "    <cidade_origem_ibge>"+AllTrim(Str(Val(cCdMunOri)))+"</cidade_origem_ibge>         "
		cXML += "    <cidade_origem_cep />                                          "
		cXML += "    <estado_origem>"+cEstOri+"</estado_origem>                     "
		cXML += "    <cidade_destino_ibge>"+AllTrim(Str(Val(cCdMunDes)))+"</cidade_destino_ibge>       "
		cXML += "    <cidade_destino_cep />                                         "
		cXML += "    <estado_destino>"+cEstDes+"</estado_destino>                   "
		cXML += "    <tipo_processo_transporte>0</tipo_processo_transporte>         "
		cXML += "    <tempo_previsto_viagem />                                      "
		cXML += "    <tipo_local_quitacao />                                        "
		cXML += "    <codigo_local_quitacao />                                      "
		cXML += "    <ida_volta>"+IIf(!lIdaEVolta,"0","1")+"</ida_volta>            "
		cXML += "    <altera_roteiro />                                             "
		cXML += "    <observacao />                                                 "

		lVias := .F.
		aEval(oGetSub:aCols,{|x,y| lVias := lVias .Or. (!aTail(x) .And. !Empty(GdFieldGet("VIA",y,,oGetSub:aHeader,oGetSub:aCols)))} )

		If lVias
			cXML += "    <vias>                                                         "
			cXML += "      <via>                                                        "
			For nI := 1 To Len(oGetSub:aCols)
				If !GdDeleted(nI,oGetSub:aHeader,oGetSub:aCols) .And. !Empty(GdFieldGet("VIA",nI,,oGetSub:aHeader,oGetSub:aCols))
					cXML += "			<via_descricao>"+AllTrim(GdFieldGet("VIA",nI,,oGetSub:aHeader,oGetSub:aCols))+"</via_descricao> "
				EndIf
			Next nI
			cXML += "      </via>                                                       "
			cXML += "    </vias>                                                        "
		Else
			cXML += "    <vias />                                                       "
		EndIf

		cXML += "  </roteiro>                                                       "
		cXML += "</solicita_roteiros>                                               "

		If lOM100XML // RAP Faremos um Ponto de Entrada parecido para Rest? https://tdn.totvs.com/display/PROT/Ponto_de_Entrada_OM100XML
			cXmlNew := Execblock("OM100XML",.F.,.F.,{cXML})
			If ValType( cXmlNew ) == 'C'
				cXML := cXmlNew
			EndIf
		EndIf

		cXML := TMSNoAcento( cXML )
	EndIf
	
	MsgRun( STR0012, STR0013, { || CursorWait(), If( lRestRepom, ;
														( oRepom:RouteCreate( cRota, cEstOri, cCdMunOri,  cEstDes, cCdMunDes, lIdaEVolta, aViasDig ), oRepom:Destroy(), FwFreeObj(oRepom) ),;
														RepSoliMth( cXML ) ), ;
														CursorArrow() } ) //"Realizando comunicação com a Operadora..." ### "Aguarde..."
	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RepSoliMth
Chama o Método  SolicitaRoteiro da Repom
@author	Daniel Leme
@version	1.0
@since		13/12/2016
@sample    Solicita Roteiro à Repom (Apenas envia a solicitação, não há retorno)
		   A inclusão do roteiro na Repom é manual, com SLA de 15min a partir da recepção deste método
/*/
//-------------------------------------------------------------------
Static Function RepSoliMth(cXML)
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )
Local cCodOpe    := StrZero(1,Len(DEG->DEG_CODOPE))
Local aMsgErr    := {}
Local aVisErr    := {}
Local lRet       := .F.
Local oObj

TmsRepTrac("Inicio de Função")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³POSICIONA NO CADASTRO DA OPERADORA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEG->( DbSetOrder(1) )
If DEG->( MsSeek(xFilial('DEG')+cCodOpe) )

	//-- Seta definicao de variaveis com ate 255 caracteres
	SetVarNameLen( 255 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PREPARACAO PARA CONECTAR AO WS - REPOM³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TmsRepTrac("SolicitaRoteiro - Instanciando")
	oObj := WSIntegracao():New()
	TmsRepTrac("SolicitaRoteiro - Instanciado")
	oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
	oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
	oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora
	oObj:cstrXmlIn             := cXml

	//-- Gera XM em disco
	If lTMSXML
		TMSLogXML( cXML, 'SolicitaRoteiro.XML' )
	EndIf

	If oObj:SolicitaRoteiro()
		TmsRepTrac("SolicitaRoteiro - Consumido OK "+AllToChar(oObj:lSolicitaRoteiroResult))
		If oObj:lSolicitaRoteiroResult
			lRet := .T.
			Aviso(	STR0001,;	//-- 'Aviso'
					STR0002,;	//-- 'Dados da Operadora Atualizados com Sucesso!'
					{STR0003})	//-- 'Ok'
		Else
			aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
			lRet := .F.
		EndIf
	Else
		aMsgErr := TMSErrOper(cCodOpe,'','2')
		lRet := .F.
	EndIf

	SetVarNameLen( 10 )

	If !Empty(aMsgErr)
		TmsRepTrac("SolicitaRoteiro - Erro: "+ AllToChar(VarInfo("aMsgErr",aMsgErr)) )
		AaddMsgErr( aMsgErr, aVisErr )
		TmsMsgErr( aVisErr )
	EndIf
EndIf
TmsRepTrac("Fim de Função")
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RepContrat³ Autor ³Vitor Raspa                 ³ Data ³04.Jul.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera Contrato de Carreteiro na base de dados da Operadora de     ³±±
±±³          ³Frotas                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA250Oper(cExpC1,cExpC2,cExpC3,cExpC4,cExpC5,nExpN1,nEpxN2,;   ³±±
±±³          ³            @aExpA1,nExpN3,@aExpA2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1: Codigo da Operadora                                     ³±±
±±³          ³ cExpC2: Filial de Origem                                        ³±±
±±³          ³ cExpC3: Numero da Viagem                                        ³±±
±±³          ³ cExpC4: Codigo do Fornecedor                                    ³±±
±±³          ³ cExpC5: Loja do Fornecedor                                      ³±±
±±³          ³ nExpN1: Valor do Frete                                          ³±±
±±³          ³ nExpN2: Valor dos Adiantamentos                                 ³±±
±±³          ³ aExpA1: Array com os dados da Operadora (Por Referencia)        ³±±
±±³          ³ nExpN3: Opcao Selecionada                                       ³±±
±±³          ³ aExpA2: Array com as Mensagens de Erro (Por Referencia)         ³±±
±±³          ³ cExpc6: Numero do Contrato de Carreteiro que Iniciou o Processo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico: .T. Contrato Gerado                                     ³±±
±±³          ³         .F. Falha na Geracao do Contrato                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMS                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RepContrat(	cCodOpe, cFilOri, cViagem, cCodForn, cLojForn, nValFrete,;
							nTotValAdi, aDadOperad, nOpcx, aMsgErr, cContrat, cCodVei, cNumIdOpe )
Local aArea     := GetArea()
Local aAreaSA2  := SA2->(GetArea())
Local aAreaSIX  := SIX->(GetArea())
Local lRet      := .T.
Local cError    := ''
Local cWarning  := ''
Local nPeso     := 0
Local nValMerc  := 0
Local cQuebra   := ''
Local cXML      := ''
Local cXmlNew   := ''
Local nAux      := 0
Local oObj
Local oXML
Local aNFs      := {}
Local lTMSXML   := GetMV( 'MV_TMSXML',, .F. )
Local nDocsOpe  := Max(1,GetMV( 'MV_DOCSOPE',,999999)) //-- Qtde. de Documentos que devem compor o XML de envio para a Operadora
Local nCntCTRCs := 0
Local nCntNFs   := 0
Local cRoteir   := ''
Local cPercur   := ''
Local lRepom	:= SuperGetMV( 'MV_VSREPOM',, '1' ) $ '2|2.2' .And. SuperGetMV( 'MV_TMSOPDG',, '1' ) == '2'
Local lTipCrg   := DTR->(FieldPos("DTR_TIPCRG")) > 0
Local aDadosQuit := {}
Local aItensQuit := {}
Local aPassagens := {}
Local nQtdEixo   := 0 // Qtde de Eixos da Carreta.
Local nTotEixo   := 0 // Qtde de Eixos total da composição
Local cTipo      := ''
Local cPosIPI    := ''
Local cNatCarga  := ''
Local cLocQuit   := ''
Local cOperac    := ''
Local cTipVei    := ''
Local cPlaca     := ''
Local cRNTRC     := ''
Local lFailPdg   := .F.
Local cFroVei    := ''
Local nValPdg    := 0
Local cSeek      := ''
Local cDocTMS    := ''
Local nQtEixVeic := 0
Local aCEPeDist	 := {}
Local lUltDest   := SuperGetMv('MV_ULTDEST',,.F.) // Define se utiliza o ultimo destino da coleta/entrega.
Local lPagaRet   := .F.
Local cCepRet    := ""
Local nKMRet     := 0
Local aDocVgeLot := {}
Local lCanCont   := .F.  //Cancelamento do Contrato 
Local lIncCont   := .F.  //Inclusao do Contrato
Local lExistShip := .F.
Local lTabDM5    := AliasIndic("DM5")

Default cContrat := ''
Default cNumIdOpe:= ''

TmsRepTrac("Inicio de Função")

//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 255 )

DEG->(DbSetOrder(1))
DEG->(MsSeek(xFilial('DEG')+cCodOpe))
If cCodOpe == '01' //-- REPOM Tecnologia	
	If !lRestRepom	
		If nOpcx <> 5
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³XML - EMISSAO DO CONTRATO ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cXML += '<processo_transporte>'
			cXML += 	'<dados_operacionais>'
			cXML += 		'<cliente_codigo>' + AllTrim(DEG->DEG_IDOPE) + '</cliente_codigo>'
			cXML += 		'<os_codigo></os_codigo>'
			cXML += 		'<os_trecho></os_trecho>'

			DA3->(dbSetOrder(1))
			If DA3->(MsSeek(xFilial('DA3')+ cCodVei ))
				cTipVei := DA3->DA3_TIPVEI
			EndIf

			cOperac := TmsGetOp(cFilOri, cViagem, cCodVei, cCodForn, cLojForn)
			If !Empty(cOperac)
				cXML += 		'<operacao_codigo>' + AllTrim(cOperac) + '</operacao_codigo>'
			Else
				cXML += 		'<operacao_codigo></operacao_codigo>'
			EndIf

			//-- Verifica a amarracao Rota X Roteiro/Percurso
			cFroVei := Posicione('DA3',1,xFilial('DA3') + cCodVei,'DA3_FROVEI')
			SIX->(DbSetOrder(1))
			If SIX->( MsSeek( 'DEK' + '3' ) )
				DEK->(DbSetOrder(3))
				If DEK->(MsSeek(xFilial('DEK')+DTQ->DTQ_ROTA+cFroVei+cCodOpe))
					cRoteir := AllTrim(DEK->DEK_ROTEIR)
					cPercur := AllTrim(DEK->DEK_CODPER)
				ElseIf DEK->( MsSeek(xFilial('DEK')+DTQ->DTQ_ROTA+'0'+cCodOpe) )
					cRoteir := AllTrim(DEK->DEK_ROTEIR)
					cPercur := AllTrim(DEK->DEK_CODPER)
				ElseIf DEK->( MsSeek(xFilial('DEK')+DTQ->DTQ_ROTA+' '+cCodOpe) )
					cRoteir := AllTrim(DEK->DEK_ROTEIR)
					cPercur := AllTrim(DEK->DEK_CODPER)
				EndIf
			Else
				DEK->(DbSetOrder(2))
				If DEK->( MsSeek(xFilial('DEK') + DTQ->DTQ_ROTA + cCodOpe) )
					cRoteir := AllTrim(DEK->DEK_ROTEIR)
					cPercur := AllTrim(DEK->DEK_CODPER)
				EndIf
			EndIf

			cXML +=	'<roteiro_cliente_codigo></roteiro_cliente_codigo>'  //novo
			If ExistFunc('TMSCEOrDes') .And. Len(aCEPeDist:= TMSCEOrDes(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_SERTMS)) > 0
				cXML += '<cep_origem>'				+	aCEPeDist[1] 				+		'</cep_origem>'		
				cXML += '<cep_destino>'				+	aCEPeDist[2] 				+		'</cep_destino>'		
				If Len(aCEPeDist) > 2
					cXML += '<distancia_percorrida>'	+	AllTrim(Str(aCEPeDist[3]))	+		'</distancia_percorrida>'					
				EndIf
			EndIf
			If !Empty(cRoteir) .And. !Empty(cPercur)
				cXML += 		'<roteiro_codigo>' + Alltrim(cRoteir) + '</roteiro_codigo>'
				cXML += 		'<percurso_codigo>' + Alltrim(cPercur) + '</percurso_codigo>'
			Else
				cXML += 		'<roteiro_codigo/>'
				cXML += 		'<percurso_codigo/>'
			EndIf

			If  lRepom .And. !TMSA250PGR(cFilOri, cViagem, cCodVei,cCodOpe)      // repom 2 e se nao pagar pedagio
				cXML += 		'<roteiro_pagamento_pedagio>' + '2' + '</roteiro_pagamento_pedagio>' // 0 = paga ida, padrao() / 2 = nao paga
			Endif

			cXML += 		'<filial_codigo></filial_codigo>'
			cXML += 		'<filial_codigo_cliente>' + AllTrim(DTR->DTR_FILORI) + '</filial_codigo_cliente>'
			cXML += 		'<processo_cliente_codigo>' + AllTrim(cFilOri) + AllTrim(cViagem) + '</processo_cliente_codigo>'

			DUP->(DbSetOrder(1))
			If DUP->(MsSeek(xFilial('DUP')+DTR->DTR_FILORI+DTR->DTR_VIAGEM))

				If DUP->( ColumnPos('DUP_CONDUT') ) > 0
					WHILE DUP->(!EOF()) .and. xFilial('DUP')+DTR->DTR_FILORI+DTR->DTR_VIAGEM ==;
						DUP->DUP_FILIAL+DUP->DUP_FILORI+DUP->DUP_VIAGEM
							IF DUP->DUP_CONDUT == '1'
								Exit
							EndIF
						DUP->(DbSkip())
					EndDO
				EndIf

				cXML += 		'<cartao_codigo>' + AllTrim(DUP->DUP_IDOPE) + '</cartao_codigo>'
			Else
				cXML += 		'<cartao_codigo></cartao_codigo>'
			EndIf

			cXML += 		'<usuario></usuario>'

			//-- 23/08/2017: Conforme a orientação da Repom, não indicar esta TAG
			cLocQuit := StrZero( 0, Len( SA2->A2_LOCQUIT ) ) 	//Filial

			cXML += 	'<quitacao_liberada>' + Alltrim(cLocQuit) + '</quitacao_liberada>' 

			aDocVgeLot:= aClone(RepRetDoc(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM))

			cXML +=  '<alto_desempenho>0</alto_desempenho>' 
			cXML +=  '<destinacao_comercial>1</destinacao_comercial>'   

			If DTQ->DTQ_SERTMS <> StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. !lUltDest //--Se não for considerado o ultimo documento da viagem , a origem e destino será a Filial...
				lPagaRet:= .T.	
			EndIf

			cXML += 	'<frete_retorno>' + Iif (lPagaRet, '1', '0') + '</frete_retorno>' 
			If lPagaRet
				aCEPeDist:={}
				If ExistFunc('TMSCEOrDes') .And. Len(aCEPeDist:= TMSCEOrDes(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_SERTMS, DTQ->DTQ_ROTA, aDocVgeLot, .T. )) > 0
					If Len(aCEPeDist) > 1
						cCepRet := aCEPeDist[2]
						nKMRet  := Iif(Len(aCEPeDist)>2,aCEPeDist[3],0)
						nKMRet  := Iif(!lUltDest,(nKMRet/2),nKMRet)
					EndIf	
				EndIf
			EndIf		
			cXML += 	'<cep_retorno>' + Iif(lPagaRet,cCepRet,'') + '</cep_retorno>' 
			cXML += 	'<distancia_retorno> ' +  Iif(lPagaRet,cValToChar(nKMRet),'') + '</distancia_retorno>' 
	
			cXML += 	'</dados_operacionais>'
			cXML += 	'<configuracoes_viagem>'
			cXML += 		'<data_saida>' + SubStr(DtoS(Date()),7,2) + '/' + SubStr(DtoS(Date()),5,2) + '/' + SubStr(DtoS(Date()),1,4) + '</data_saida>'
			cXML += 		'<hora_saida>' + Substr(Time(),1,2)+':'+Substr(Time(),4,2) + '</hora_saida>'
			cXML += 		'<coleta_tempo_previsto></coleta_tempo_previsto>'  //nao tem
			cXML += 		'<observacao></observacao>'                        //nao tem
			cXML += 	'</configuracoes_viagem>'

			cXML += 	'<documentos_integrados>'
			cXML += 		'<conhecimentos>'

			DUD->(DbSetOrder(2))
			If DUD->(DbSeek(xFilial('DUD')+DTR->DTR_FILORI+DTR->DTR_VIAGEM))
				While DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == xFilial('DTR')+DTR->(DTR_FILORI+DTR_VIAGEM)
					If nCntCTRCs < nDocsOpe
						cTipo := RetRepomType(DUD->DUD_SERTMS, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE)

						cXML += 		'<conhecimento>'
						cXML += 			'<ctrc_codigo>' + AllTrim(DUD->DUD_DOC) + '</ctrc_codigo>'
						cXML += 			'<ctrc_serie>' + AllTrim(DUD->DUD_SERIE) + '</ctrc_serie>'
						cXML += 			'<ctrc_filial></ctrc_filial>'
						cXML += 			'<ctrc_filial_codigo_cliente>' + AllTrim(DUD->DUD_FILORI) + '</ctrc_filial_codigo_cliente>'
						cXML += 			'<manifesto_codigo>' + AllTrim(DUD->DUD_MANIFE) + '</manifesto_codigo>' 
						cXML += 			'<documento_tipo>' + Alltrim(cTipo) + '</documento_tipo>'
						cXML += 			'<nfs>'

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Ponto de Entrada para determinar quais documentos irao³
						//³compor o XML de envio para a Operadora de Frotas      ³
						//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
						//³Formato do vetor aNFs:                                ³
						//³aNFs[1] - Numero do Documento                         ³
						//³aNFs[2] - Serie do Documento                          ³
						//³aNFs[3] - Codigo do Cliente Remetente                 ³
						//³aNFs[4] - Loja do Cliente Remetente                   ³
						//³aNFs[5] - Codigo do Cliente Destinatario              ³
						//³aNFs[6] - Loja do Cliente Destinatario                ³
						//³aNFs[7] - Peso                                        ³
						//³aNFs[8] - Valor da Mercadoria                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lTM250NfOp
							aNFs := ExecBlock('TM250NfOp',.F.,.F.,{DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE})
							If ValType(aNFs) <> 'A'
								aNFs := {}
							EndIf
						EndIf

							aNFs := {} //-- Limpa o array de documentos para nao repeti-los na emissao
							If DUD->DUD_SERTMS <> StrZero(1,Len(DTQ->DTQ_SERTMS))
								DT6->(DbSetOrder(1)) //--DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
								If DT6->(MsSeek(xFilial('DT6') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE))
									cDocTMS := DT6->DT6_DOCTMS
									If cDocTMS == '6' .Or. cDocTMS == '7' // Reentrega ou Devolução pesquisa pelo Original
										cSeek := xFilial('DTC') + DT6->(DT6_DOCDCO + DT6_SERDCO + DT6_FILDCO)
									Else
										cSeek := xFilial('DTC') + DT6->(DT6_DOC + DT6_SERIE + DT6_FILDOC)
									EndIf
								EndIf

								DTC->(DbSetOrder(7))
								DTC->(DbSeek( cSeek ))
								While DTC->(DTC_FILIAL+DTC_DOC+DTC_SERIE+DTC_FILDOC) == cSeek
									AAdd( aNFs, {	DTC->DTC_NUMNFC,;
													DTC->DTC_SERNFC,;
													DTC->DTC_CLIREM,;
													DTC->DTC_LOJREM,;
													DTC->DTC_CLIDES,;
													DTC->DTC_LOJDES,;
													DTC->DTC_PESO,;
													DTC->DTC_VALOR } )

									//Guarda o primeiro registro que tiver o codigo B1_POSIPI informado, conforme REPOM
									If Empty(cPosIPI)
										cPosIpi:= Posicione('SB1',1,xFilial('SB1')+DTC->DTC_CODPRO,'B1_POSIPI')
									EndIf

									DTC->(DbSkip())
								EndDo
							Else
								DUM->(DbSetOrder(1))
								DUM->(MsSeek(xFilial('DUM')+DUD->(DUD_FILORI+DUD_DOC)))
								While DUM->(DUM_FILIAL+DUM_FILORI+DUM_NUMSOL) == xFilial('DUM') + DUD->(DUD_FILORI+DUD_DOC)
									AAdd( aNFs, {,,,,,,DUM->DUM_PESO, DUM->DUM_VALMER} )

									//Guarda o primeiro registro que tiver o codigo B1_POSIPI informado, conforme REPOM
									If Empty(cPosIPI)
										cPosIpi:= Posicione('SB1',1,xFilial('SB1')+DUM->DUM_CODPRO,'B1_POSIPI')
									EndIf

									DUM->(DbSkip())
								EndDo
							EndIf

						If DUD->DUD_SERTMS <> StrZero(1,Len(DTQ->DTQ_SERTMS))
							ASort(aNFs,,,{|x,y| x[1] < y[1] })
							cQuebra := ''
							nCntNFs := If( nDocsOpe > Len(aNFs), Len(aNFs), nDocsOpe )
							For nAux := 1 To nCntNFs
								If cQuebra <> aNFs[nAux,1]
									cXML += 	'<nf>'
									cXML += 		'<nf_codigo>' + AllTrim( aNFs[nAux,1] ) + '</nf_codigo>'
									cXML += 		'<nf_serie>' + AllTrim( aNFs[nAux,2] ) + '</nf_serie>'
									//-- Remetente
									SA1->(DbSetOrder(1))
									SA1->(MsSeek(xFilial('SA1') + aNFs[nAux,3] + aNFs[nAux,4]))
									cXML +=			'<nf_remetente_cnpj>' + AllTrim(SA1->A1_CGC) + '</nf_remetente_cnpj>'
									cXML +=			'<nf_remetente_razao>' + AllTrim(SA1->A1_NOME) + '</nf_remetente_razao>'
									//-- Destinatario
									SA1->(DbSetOrder(1))
									SA1->(MsSeek(xFilial('SA1') + aNFs[nAux,5] + aNFs[nAux,6]))
									cXML += 		'<nf_destinatario_cnpj>' + AllTrim(SA1->A1_CGC) + '</nf_destinatario_cnpj>'
									cXML += 		'<nf_destinatario_razao>' + AllTrim(SA1->A1_NOME) + '</nf_destinatario_razao>'
									cXML += 	'</nf>'
								EndIf
								cQuebra  := aNFs[nAux,1]
								nPeso    += aNFs[nAux,7]
								nValMerc += aNFs[nAux,8]
							Next
						Else
							For nAux := 1 To Len(aNFs)
								nPeso    += aNFs[nAux,7]
								nValMerc += aNFs[nAux,8]
							Next
						EndIf

						cXML += 			'</nfs>'
						cXML += 		'</conhecimento>'
					EndIf
					DUD->(DbSkip())
					nCntCTRCs++
				EndDo
			EndIf
			cXML += 		'</conhecimentos>'
			cXML += 	'</documentos_integrados>'

			SA2->(DbSetOrder(1))
			SA2->(MsSeek(xFilial('SA2')+cCodForn+cLojForn))
			cXML += 	'<dados_contratado>'
			cXML += 		'<contratado_cnpj_cpf>' + AllTrim(SA2->A2_CGC) + '</contratado_cnpj_cpf>'

			DA4->(DbSetOrder(1))
			DA4->(MsSeek(xFilial('DA4')+DUP->DUP_CODMOT))
			cXML += 		'<motorista_cpf>' + AllTrim(DA4->DA4_CGC) + '</motorista_cpf>'

			DA3->(DbSetOrder(1))
			DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODVEI))
			cXML += 		'<cavalo_placa>' + AllTrim(DA3->DA3_PLACA) + '</cavalo_placa>'
			cXML += 		'<rastreador_codigo></rastreador_codigo>'

			//-- Inicializa Variáveis para contagem dos eixos (total e Carretas)
			cFroVei   := DA3->DA3_FROVEI
			nTotEixo  := DA3->DA3_QTDEIX // Inicializa o total de eixo com a Qtde de eixo do veiculo Tracionador		
			nQtdEixo  := 0
			nQtEixVeic:= DA3->DA3_QTDEIX //Qtde de Eixos (Cavalo + Carreta) 

			If !Empty(DTR->DTR_CODRB1)
				//-- Posiciona no Cadastro de Veiculos (Reboque 1)
				DA3->(DbSetOrder(1))
				If DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB1))
					nQtdEixo   += DA3->DA3_QTDEIX
					cPlaca     := AllTrim(DA3->DA3_PLACA)
					cRNTRC     := AllTrim(RetRntrVei(DA3->DA3_COD))
					nQtEixVeic += DA3->DA3_QTDEIX //Qtde de Eixos (Cavalo + Carreta)
				EndIf

				//-- Posiciona no Cadastro de Veiculos (Reboque 2), enviar a ultima placa e RNTRC da carreta
				If !Empty(DTR->DTR_CODRB2)
					DA3->(DbSetOrder(1))
					If DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB2))
						nQtdEixo   += DA3->DA3_QTDEIX
						cPlaca     := AllTrim(DA3->DA3_PLACA)
						cRNTRC     := AllTrim(RetRntrVei(DA3->DA3_COD))
						nQtEixVeic += DA3->DA3_QTDEIX //Qtde de Eixos (Cavalo + Carreta)
					EndIf
				EndIf
				//-- Posiciona no Cadastro de Veiculos (Reboque 2), enviar a ultima placa e RNTRC da carreta
				If DTR->(ColumnPos("DTR_CODRB3")) > 0 .And. !Empty(DTR->DTR_CODRB3)
					DA3->(DbSetOrder(1))
					If DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB3))
						nQtdEixo   += DA3->DA3_QTDEIX
						cPlaca     := AllTrim(DA3->DA3_PLACA)
						cRNTRC     := AllTrim(RetRntrVei(DA3->DA3_COD))
						nQtEixVeic += DA3->DA3_QTDEIX //Qtde de Eixos (Cavalo + Carreta)
					EndIf
				EndIf
				cXML += 		'<carreta_placa>' + cPlaca	+ '</carreta_placa>'                                 //Ultimo Reboque  
				cXML += 		'<carreta_rntrc>' + cRNTRC + '</carreta_rntrc>'                                  //Ultimo Reboque
				cXML += 		'<carreta_numero_eixos>' + AllTrim(Str(nQtdEixo,2))	+ '</carreta_numero_eixos>'  //Somente Quantidade de Eixos dos Reboques
			Else
				cXML += 		'<carreta_placa></carreta_placa>'
				cXML += 		'<carreta_rntrc></carreta_rntrc>' 
				cXML += 		'<carreta_numero_eixos></carreta_numero_eixos>'
			EndIf
			cXML += 	'<eixos_suspensos_ida>' + AllTrim(Str(nQtEixVeic - DTR->DTR_QTDEIX,2))	+'</eixos_suspensos_ida>'        //Qtde Eixos Ida
			cXML += 	'<eixos_suspensos_volta>' + AllTrim(Str(nQtEixVeic - DTR->DTR_QTEIXV,2))	+'</eixos_suspensos_volta>'  //Qtde Eixos Volta

			cXML += 	'</dados_contratado>'
			cXML += 	'<dados_carga>'

			//-- Valida valor do pedágio antes da emissão do contrato
			nTotEixo += nQtdEixo // Soma a qtde de eixos da carreta ao total da composição
			If DEG->DEG_CALPDG == "1" // Cálculo do pedágio pela REPOM
				//nValPdg := TMSOperPdg( DTR->DTR_CODOPE, DTQ->DTQ_ROTA, nTotEixo, nTotEixo, nTotEixo, 0, @lFailPdg, cFroVei )
				nValPdg := TMSOperPdg( DTR->DTR_CODOPE, DTQ->DTQ_ROTA, DTR->DTR_QTDEIX, DTR->DTR_QTEIXV, nTotEixo, nTotEixo, @lFailPdg, cFroVei )
				If lFailPdg .Or. nValPdg <> DTR->DTR_VALPDG
					If !lFailPdg
						aAdd(aMsgErr,{ STR0037 + " ("+AllTrim(Str(DTR->DTR_VALPDG))+")"+; //-- "O valor do pedágio na Viagem "
									" "+ STR0038 + " ("+AllTrim(Str(nValPdg))+"). ",'',''}) //-- " difere do valor calculado pela Operadora neste momento"
						aAdd(aMsgErr,{STR0039+" "+STR0040,'',''}) //-- "É necessário revisar a quantidade de eixos na viagem e " ## "atualizar o valor do pedágio com a Operadora no Complemento de Viagem."
					EndIf
					lFailPdg := .T.
					lRet := .F.
				EndIf
			EndIF
			If DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS))
				cXML += 	'<carga_destinatario_cpf_cnpj>' + AllTrim(SM0->M0_CGC) + '</carga_destinatario_cpf_cnpj>'
				cXML += 	'<carga_destinatario_nome_razao_social>' + AllTrim(SM0->M0_NOME) + '</carga_destinatario_nome_razao_social>'
			EndIf

			If lTipCrg .AND. lRepom
				If DTR->DTR_TIPCRG == '1'
					cNatCarga := TmsTpCrg(cFilOri, cViagem)
					cXML += 	'<antt_ncm_codigo_classificacao_mercadoria>' + cNatCarga + '</antt_ncm_codigo_classificacao_mercadoria>'
				Else
					cXML += 	'<antt_ncm_codigo_classificacao_mercadoria>0001</antt_ncm_codigo_classificacao_mercadoria>'
				EndIf
			Else
				cXML += 	'<antt_ncm_codigo_classificacao_mercadoria>0001</antt_ncm_codigo_classificacao_mercadoria>'
			EndIf

			cXML += 		'<liberador_codigo></liberador_codigo>'
			cXML += 		'<liberacao_codigo></liberacao_codigo>'
			cXML += 		'<carga_tipo_codigo></carga_tipo_codigo>'
			cXML += 		'<carga_peso>' + AllTrim(Str(nPeso,11,2)) + '</carga_peso>'
			cXML += 		'<carga_valor>' + AllTrim(Str(nValMerc,14,2)) + '</carga_valor>'
			cXML += 		'<carga_volume></carga_volume>'
			cXML += 		'<carga_unidade_codigo></carga_unidade_codigo>'
			If DTQ->(ColumnPos('DTQ_TPOPVG')) > 0 .And. DLO->(ColumnPos('DLO_CODTPC')) > 0			
				cXml += 		'<codigo_tipo_carga>' + Posicione('DLO',1,FwxFilial('DLO')+DTQ->DTQ_TPOPVG,'DLO_CODTPC') + '</codigo_tipo_carga>'
			EndIf
			cXML += 	'</dados_carga>'
			cXML += 	'<dados_frete>'
			cXML += 		'<valor_frete>' + AllTrim(Str(nValFrete,14,2)) + '</valor_frete>'
			cXML += 		'<valor_adiantamento>' + AllTrim(Str(nTotValAdi,14,2)) + '</valor_adiantamento>'
			cXML += 		'<valor_vale_combustivel/>'
			cXML += 		'<relacao_quitacao>2</relacao_quitacao>'
			cXML += 		'<relacao_adiantamento>2</relacao_adiantamento>'
			SA2->(DbSetOrder(1))
			If  SA2->(DbSeek(xFilial("SA2")+cCodForn+cLojForn))
				cLocQuit := SA2->A2_LOCQUIT
			EndIf
			//-- Viagem Vazia, o local de quitacao sera sempre em Filial, por nao haver baixa antecipada
			If DTQ->DTQ_TIPVIA == StrZero( 2, Len( DTQ->DTQ_TIPVIA ) )
				cLocQuit := StrZero( 0, Len( SA2->A2_LOCQUIT ) ) 	//Filial
			EndIf
			cXML += 		'<local_quitacao_tipo>'+AllTrim(cLocQuit)+'</local_quitacao_tipo>'
			cXML += 		'<local_quitacao_codigo/>'
			cXML += 		'<local_quitacao_codigo_cliente/>'
			cXML += 	'</dados_frete>'
			cXML += 	'<movimentos>'   //novo
			cXML += 	'</movimentos>'
			cXML += '</processo_transporte>'

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³XML - CANCELAMENTO DO CONTRATO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DTR->(DbSetOrder(1))
			DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
			cXML := ''
			cXML += '<contrato>'
			cXML += 	'<cliente_codigo>'             + AllTrim(DEG->DEG_IDOPE) + '</cliente_codigo>'
			cXML += 	'<processo_transporte_codigo>' + AllTrim(DTR->DTR_PRCTRA) + '</processo_transporte_codigo>'
			cXML += 	'<processo_cliente_codigo>'    + AllTrim(cFilOri) + AllTrim(cViagem) + '</processo_cliente_codigo>'
			cXML += 	'<filial_codigo_cliente>'      + AllTrim(cFilAnt) + '</filial_codigo_cliente>'
			cXML +=		'<login/>'
			cXML += '</contrato>'
		EndIf

		If ExistBlock('TM250XML')
			cXmlNew := Execblock("TM250XML",.F.,.F.,{cXML})
			If ValType( cXmlNew ) == 'C'
				cXML := cXmlNew
			EndIf
		EndIf

		//-- Remove Caracteres especiais no cXML
		cXML := TMSNoAcento( cXML )

		//-- Gera XML em Disco
		If lRet .And. lTMSXML
			If nOpcx <> 5
				TMSLogXML( cXML, 'EmiteContrato.XML' )
			Else
				TMSLogXML( cXML, 'CancelaContrato.XML' )
			EndIf
		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ACIONA O WEBSERVICE ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TmsRepTrac("EmiteContrato - Instanciando "+AllToChar(nOpcx))
			oObj := WSIntegracao():New()
			TmsRepTrac("EmiteContrato - Instanciado")
			oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
			oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
			oObj:cStrXMLIn             := cXML
			oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora
		EndIf
		If lRet .And. nOpcx <> 5
			//-- Emissao do Contrato
			If oObj:EmiteContrato()
				TmsRepTrac("EmiteContrato - Consumido OK "+AllToChar(oObj:lEmiteContratoResult))
				If oObj:lEmiteContratoResult

					//-- Gera LOG de Atualizacao:
					//TMSGerLog( cCodOpe, 'CC', 'E', xFilial('DTY')+cContrat, 'DTY', '0' )

					//-- Remove os acentos do XML de Retorno
					oObj:cStrXMLOut := TMSNoAcento( oObj:cStrXMLOut )

					//-- Grava XML em disco
					If lTMSXML
						TMSLogXML( oObj:cStrXMLOut, 'EmiteContratoResult.XML' )
					EndIf
					TmsRepTrac("EmiteContrato - Gravou XML ")

					//-- Coverte em Objeto o XML de retorno enviado pela Operadora
					oXML := XMLParser( oObj:cStrXMLOut, '_', @cError, @cWarning )

					TmsRepTrac("EmiteContrato - Parseou XML " + AllToChar(cError))

					If Empty(cError)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Dados para Quitacao                                   ³
						//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
						//³ [01]     - Dados para Quitacao                        ³
						//³ [01][01] - Local de Quitacao (0-Postol/1-Filial)      ³
						//³ [01][02] - CNPJ do Posto / Cod. da Filial             ³
						//³ [01][03] - Razao Social                               ³
						//³ [01][04] - Endereco                                   ³
						//³ [01][05] - Municipio                                  ³
						//³ [01][06] - Estado                                     ³
						//³ [01][07] - Telefone                                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDadosQuit := 	{	oXML:_Processo_Transporte:_Quitacao:_Quitacao_Local_Tipo:Text,;
											IF(oXML:_Processo_Transporte:_Quitacao:_Quitacao_Local_Tipo:Text = '0', oXML:_Processo_Transporte:_Quitacao:_CNPJ:Text,oXML:_Processo_Transporte:_Quitacao:_Quitacao_Local:Text),;
											oXML:_Processo_Transporte:_Quitacao:_Quitacao_Local_Descricao:Text,;
											oXML:_Processo_Transporte:_Quitacao:_Endereco:Text,;
											oXML:_Processo_Transporte:_Quitacao:_Cidade:Text,;
											oXML:_Processo_Transporte:_Quitacao:_Estado:Text,;
											oXML:_Processo_Transporte:_Quitacao:_Telefone:Text	}

						TmsRepTrac("EmiteContrato - Montou aDadosQuit " )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Itens para Quitacao                                   ³
						//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
						//³ [01]    - Itens para Quitacao                         ³
						//³ [01][01] - Descricao Itens para Quitacao              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If XMLChildCount( oXML:_Processo_Transporte:_Itens_Quitacao ) > 0
							If ValType( oXML:_Processo_Transporte:_Itens_Quitacao:_Item_Quitacao) == 'A'
								For nAux := 1 To Len(oXML:_Processo_Transporte:_Itens_Quitacao:_Item_Quitacao)
									AAdd( aItensQuit, oXML:_Processo_Transporte:_Itens_Quitacao:_Item_Quitacao[nAux]:_Item_Descricao:Text )
								Next
							Else
								AAdd( aItensQuit, oXML:_Processo_Transporte:_Itens_Quitacao:_Item_Quitacao:_Item_Descricao:Text )
							EndIf
						EndIf

						TmsRepTrac("EmiteContrato - Montou aItensQuit " )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Array aDadOperad, recebido por Referencia              ³
						//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
						//³ [01] - Codigo da Operadora de Frotas                  ³
						//³ [02] - Numero do Contrato                             ³
						//³ [03] - Numero do Processo de Transporte (Operadora)   ³
						//³ [04] - Relacao de Abastecimento                       ³
						//³ [05] - Relacao de Quitacao                            ³
						//³ [06] - Array c/ Dados para Quitacao                   ³
						//³ [07] - Array c/ Itens para Quitacao                   ³
						//³ [08] - CIOT                                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDadOperad := {	cCodOpe, oXML:_Processo_Transporte:_Processo_Cliente_Codigo:Text,;
										oXML:_Processo_Transporte:_Processo_Transporte_Codigo:Text,;
										oXML:_Processo_Transporte:_Dados_Viagem:_Relacao_Abastecimento:Text,;
										oXML:_Processo_Transporte:_Dados_Viagem:_Relacao_Quitacao:Text,;
										aDadosQuit,;
										aItensQuit,;
										oXML:_Processo_Transporte:_Dados_Viagem:_CIOT:Text}

						TmsRepTrac("EmiteContrato - Montou aDadOperad " )

						//-- Grava o N.o do Contrato da Operadora
						If Len(aDadOperad) >= 8
							cNumCiot:= aDadOperad[8]
						EndIf

						RecLock("DTR",.F.)
						DTR->DTR_PRCTRA := cNumIdOpe := aDadOperad[3]
						If Len(aDadOperad) >= 8
							DTR->DTR_CIOT   := aDadOperad[8]
						EndIf
						DTR->(MsUnLock())

						//-- Atualizada dados da viagem Modelo 3
						If lTabDM5 .And. FindFunction('TM15AtuDM5') .And. !Empty(aDadOperad[3])
    						TM15AtuDM5(cFilOri,cViagem,aDadOperad[3])
						EndIf

						TmsRepTrac("EmiteContrato - Gravou DTR (PRCTRA/CIOT) " + DTR->DTR_PRCTRA +"/"+ DTR->DTR_CIOT )

						//-- Grava as informacoes preliminares sobre a Quitacao:
						TMSGrvDES(cFilOri,cViagem,aDadOperad)
	
						TmsRepTrac("EmiteContrato - Gravou DES " + AllToChar(DES->(Recno())) )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Estrutura do Array aPassagens                         ³
						//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
						//³ [01] - N.o do Processo de Transporte                  ³
						//³ [02] - Dt. de Previsao da Passagem                    ³
						//³ [03] - Hr. de Previsao da Passagem                    ³
						//³ [04][01] - CNPJ do Posto                              ³
						//³ [04][02] - Razao Social do Posto                      ³
						//³ [04][03] - Endereco                                   ³
						//³ [04][04] - Cidade                                     ³
						//³ [04][05] - Estado                                     ³
						//³ [04][06] - Telefone                                   ³
						//³ [05] - Vlr. do Combustivel                            ³
						//³ [06] - Dt. Real da Passagem                           ³
						//³ [07] - Hr. Real da Passagem                           ³
						//³ [08] - Vlr. Referente ao Consumo                      ³
						//³ [09] - Vlr. Referente ao Saque                        ³
						//³ [10] - Dt. Previsao de Pagto. do Consumo              ³
						//³ [11] - Dt. Previsao de Pagto. do Saque                ³
						//³ [12] - N.o do Documento relacionado a Passagem        ³
						//³ [13] - Indice do Lancto. (Ordem da Passagem)          ³
						//³ [14] - Operacao: 0=Baixa da Passagem                  ³
						//³                  1=Estorno da Baixa                   ³
						//³                  2=Nova Passagem em Aberto            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If XMLChildCount( oXML:_Processo_Transporte:_Passagens ) > 0
							If ValType( oXML:_Processo_Transporte:_Passagens:_Passagem ) == 'A'
								For nAux := 1 To Len( oXML:_Processo_Transporte:_Passagens:_Passagem)
									AAdd( aPassagens, {	oXML:_Processo_Transporte:_Processo_Transporte_Codigo:Text,;
														Left(oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Data_Prevista:Text, 10),;
														Right(oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Data_Prevista:Text, 4),;
														{oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Posto_CNPJ:Text,;
														oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Nome_Fantasia:Text,;
														oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Endereco:Text,;
														oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Cidade:Text,;
														oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Estado:Text,;
														oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Telefone:Text},;
														oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Preco_Diesel:Text,;
														'',;
														'',;
														'',;
														'',;
														'',;
														'',;
														'',;
														Str(nAux),;
														'2'} )
								Next
							Else
								nAux := 1   //Somente uma passagem
								AAdd( aPassagens, {	oXML:_Processo_Transporte:_Processo_Transporte_Codigo:Text,;
													Left(oXML:_Processo_Transporte:_Passagens:_Passagem:_Data_Prevista:Text, 10),;
													Right(oXML:_Processo_Transporte:_Passagens:_Passagem:_Data_Prevista:Text, 4),;
													{oXML:_Processo_Transporte:_Passagens:_Passagem:_Posto_CNPJ:Text,;
													oXML:_Processo_Transporte:_Passagens:_Passagem:_Nome_Fantasia:Text,;
													oXML:_Processo_Transporte:_Passagens:_Passagem:_Endereco:Text,;
													oXML:_Processo_Transporte:_Passagens:_Passagem:_Cidade:Text,;
													oXML:_Processo_Transporte:_Passagens:_Passagem:_Estado:Text,;
													oXML:_Processo_Transporte:_Passagens:_Passagem:_Telefone:Text},;
													oXML:_Processo_Transporte:_Passagens:_Passagem:_Preco_Diesel:Text,;
													'',;
													'',;
													'',;
													'',;
													'',;
													'',;
													'',;
													Str(nAux),;
													'2'} )
							EndIf
							TmsRepTrac("EmiteContrato - Montou aPassagens ")

							//-- Atualiza os dados da Passagem no Posto
							TMSPassag( cCodOpe, cFilOri, cViagem, aPassagens)

							TmsRepTrac("EmiteContrato - Voltou TMSPassag ")
						EndIf
					Else
						aMsgErr := TMSErrOper(cCodOpe, cError, '1')
						lRet := .F.
					EndIf
				Else
					aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
					lRet := .F.
				EndIf
			Else
				aMsgErr := TMSErrOper(cCodOpe,, '2')
				lRet := .F.
			EndIf
		ElseIf lRet .And. nOpcx == 5
			//-- Cancelamento do Contrato
			If oObj:CancelaContrato()
				TmsRepTrac("CancelaContrato - Consumido OK "+AllToChar(oObj:lCancelaContratoResult))
				If oObj:lCancelaContratoResult
					lCanCont:= .T.  //Cancelamento do Contrato OK
				Else
					aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
					lRet := .F.
				EndIf
			Else
				aMsgErr := TMSErrOper(cCodOpe,, '2')
				lRet := .F.
			EndIf
		EndIf
	Else
		//---- Nova Integração  Versao 2.2	 
		If lRet
			If nOpcx <> 5			
				//Valida se o contrato já existe na REPOM
				lExistShip:= TM15VlShip(cFilOri,cViagem,nOpcx,.T.)  

				If !lExistShip
					lRet:= TMSC15ARep( 1, cFilOri , cViagem, .F. )	//ShippingCreate
				
					If lRet //-- Verifica Retorno do Status e Grava o N.o do Contrato da Operadora 					
						lRet:= RepRetShip(cFilOri,cViagem,cCodOpe,@lIncCont,@aMsgErr)  
					EndIf					
				Else
					DES->(DbSetOrder(1))
					If !DES->(MsSeek(xFilial('DES') + cFilOri + cViagem))
						lIncCont:= .T.
					EndIf
				EndIf

				If lIncCont
					//-- Inclui os Movimentos gerados apos a emissão do Contrato de Carreteiro e sem
					//-- o contrato na REPOM (Impostos calculados pelo Protheus --- DTR_PRCTRA = '')
					lRet:= RepIncMov(cFilOri,cViagem,.T.)

					If lRet
						//-- Grava as informacoes preliminares sobre a Quitacao:
						TMSGrvDES(cFilOri,cViagem,aDadOperad)  
					EndIf

					//-- Pendente (fase2) Atualiza os dados da Passagem no Posto (nao vai ter na nova integracao Posto)
					//TMSPassag( cCodOpe, cFilOri, cViagem, aPassagens)
				EndIf
			Else
				DTR->(DbSetOrder(1))
				If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
					
					lRet:= TMSC15ARep( 7 , DTR->DTR_FILORI , DTR->DTR_VIAGEM, .F., , .T. )  //ShippingCancel
					If lRet
						lCanCont:= .T.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//Cancelamento do Contrato	para todas as versoes REPOM
	If lCanCont   
		//-- Exclui as passagens referentes ao contrato...
		TMSExcDEP(cFilOri,cViagem)

		//-- Exclui os dados referente a Quitacao
		TMSExcDES(cFilOri,cViagem)
	EndIf
EndIf
//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 10 )

If !Empty(aMsgErr)
	TmsRepTrac("EmiteContrato - Erro ("+AllToChar(nOpcx)+")"+VarInfo("aMsgErr",aMsgErr))
EndIf

RestArea(aAreaSA2)
RestArea(aArea)
RestArea(aAreaSIX)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RepCtlVg   ³ Autor ³ Vitor Raspa          ³ Data ³ 15.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza integração com controle de viagem Repom            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA310    												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RepCtlVg(cFilOri,cViagem,cCodVei,cCodOpe,nOpcx)
Local cXML       := ''
Local lRet       := .F.
Local nPeso      := 0

Local cXmlNew    := ''
Local nAux       := 0
Local nKmIni     := 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )
Local lContVei   := GetMV( 'MV_CONTVEI',,.T.) // Verifica se o sistema Controla Motoristas / Veiculos
Local nDocsOpe   := GetMV( 'MV_DOCSOPE',,999999) //-- Qtde. de Documentos que devem compor o XML de envio para a Operadora
Local nCount     := 0
Local cFroVei    := ''
Local cRoteir    := ''
Local cPercur    := ''
Local nQtdEixo   := 0 // Qtde de Eixos por Veiculo + Reboque
Local cPlaca     := ''

Local oObj
Local oXML
Local cError     := ''
Local cWarning   := ''
Local aMovtos    := {}
Local aPassagens := {}
Local nRetPe     := 0
Local lTM310ODE  := ExistBlock('TM310ODE')
Local cAtivPsg   := GetMv( 'MV_ATIVPSG',, '' )

TmsRepTrac("Inicio de Função")

If nOpcx == 3 //-- Fechamento
	cXML += '<processo_transporte>'
	cXML += 	'<processo_cliente_codigo>' + cFilOri + cViagem + '</processo_cliente_codigo>'
	cXML += 	'<processo_cliente_filial_codigo_cliente>' + PadL(cFilOri, 3, '0') + '</processo_cliente_filial_codigo_cliente>'

	DEJ->(DbSetOrder(2))
	If DEJ->(MsSeek(xFilial('DEJ')+cCodOpe+DTQ->(DTQ_SERTMS + DTQ_TIPTRA)))
		cXML += 	'<operacao_codigo>' + DEJ->DEJ_OPERAC + '</operacao_codigo>'
	Else
		cXML += 	'<operacao_codigo></operacao_codigo>'
	EndIf

	//-- Verifica a amarracao Rota X Roteiro/Percurso
	cFroVei := Posicione('DA3',1,xFilial('DA3') + cCodVei,'DA3_FROVEI')
	SIX->(DbSetOrder(1))
	If SIX->( MsSeek( 'DEK' + '3' ) )
		DEK->(DbSetOrder(3))
		If DEK->(MsSeek(xFilial('DEK')+DTQ->DTQ_ROTA+cFroVei+cCodOpe))
			cRoteir := AllTrim(DEK->DEK_ROTEIR)
			cPercur := AllTrim(DEK->DEK_CODPER)
		ElseIf DEK->( MsSeek(xFilial('DEK')+DTQ->DTQ_ROTA+'0'+cCodOpe) )
			cRoteir := AllTrim(DEK->DEK_ROTEIR)
			cPercur := AllTrim(DEK->DEK_CODPER)
		ElseIf DEK->( MsSeek(xFilial('DEK')+DTQ->DTQ_ROTA+' '+cCodOpe) )
			cRoteir := AllTrim(DEK->DEK_ROTEIR)
			cPercur := AllTrim(DEK->DEK_CODPER)
		EndIf
	Else
		DEK->(DbSetOrder(2))
		If DEK->( MsSeek(xFilial('DEK') + DTQ->DTQ_ROTA + cCodOpe) )
			cRoteir := AllTrim(DEK->DEK_ROTEIR)
			cPercur := AllTrim(DEK->DEK_CODPER)
		EndIf
	EndIf

	If !Empty(cRoteir) .And. !Empty(cPercur)
		cXML += 	'<roteiro_codigo>' + cRoteir + '</roteiro_codigo>'
		cXML += 	'<percurso_codigo>' + cPercur + '</percurso_codigo>'
	Else
		cXML += 	'<roteiro_codigo/>'
		cXML += 	'<percurso_codigo/>'
	EndIf
	cXML += 	'<roteiro_codigo_cliente/>'
	cXML += 	'<filial_codigo_cliente>' + PadL(cFilOri, 3, '0') + '</filial_codigo_cliente>'

	DTR->(DbSetOrder(1))
	If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
		DUP->(DbSetOrder(1))
		If DUP->(MsSeek(xFilial('DUP')+cFilOri + cViagem))

			If DUP->( FieldPos('DUP_CONDUT') ) > 0
				WHILE DUP->(!EOF()) .And. xFilial('DUP')+DTR->DTR_FILORI+DTR->DTR_VIAGEM ==;
			    	  DUP->DUP_FILIAL+DUP->DUP_FILORI+DUP->DUP_VIAGEM
						If DUP->DUP_CONDUT == '1'
							Exit
						EndIf
					DUP->(DbSkip())
				EndDo
			EndIf

			DA4->(DbSetOrder(1))
			If DA4->(MsSeek(xFilial('DA4')+DUP->DUP_CODMOT))
				cXML += 	'<motorista>' + AllTrim(DA4->DA4_CGC) + '</motorista>'
				DA3->(DbSetOrder(1))
				If DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODVEI))
				    nQtdEixo += DA3->DA3_QTDEIX
					cXML += 	'<veiculo>' + AllTrim(DA3->DA3_PLACA) + '</veiculo>'
					cXML += 	'<rastreador_tipo></rastreador_tipo>'
					cXML += 	'<rastreador_codigo></rastreador_codigo>'

					If !Empty(DTR->DTR_CODRB1)  
						//-- Posiciona no Cadastro de Veiculos (Reboque)
						DA3->(DbSetOrder(1))
						If DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB1))
							nQtdEixo += DA3->DA3_QTDEIX
							cPlaca:= AllTrim(DA3->DA3_PLACA)
						EndIf	
						
						//-- Posiciona no Cadastro de Veiculos (Reboque 2), enviar a ultima placa e RNTRC da carreta
						If !Empty(DTR->DTR_CODRB2)
							DA3->(DbSetOrder(1))
							If DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB2))
								nQtdEixo += DA3->DA3_QTDEIX
								cPlaca:= AllTrim(DA3->DA3_PLACA)
							EndIf
						EndIf
						//-- Posiciona no Cadastro de Veiculos (Reboque 2), enviar a ultima placa e RNTRC da carreta
						If !Empty(DTR->DTR_CODRB3)
							DA3->(DbSetOrder(1))
							If DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODRB3))
								nQtdEixo += DA3->DA3_QTDEIX
								cPlaca:= AllTrim(DA3->DA3_PLACA)
							EndIf
						EndIf
						cXML += 	'<carreta>' + cPlaca + '</carreta>'
					Else
						cXML += 	'<carreta/>'
					EndIf
					cXML += 	'<cartao>' + AllTrim(DUP->DUP_IDOPE) + '</cartao>'
					cXML += 	'<produto_codigo>1</produto_codigo>'
					cXML += 	'<observacao>' + AllTrim(Left(MSMM( DTQ->DTQ_CODOBS ),400)) + '</observacao>'
					cXML += 	'<data_saida_efetiva>' + SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4) + '</data_saida_efetiva>'
					cXML += 	'<eixos_suspensos_ida>' + AllTrim(Str((nQtdEixo - DTR->DTR_QTDEIX),2)) + '</eixos_suspensos_ida>'
					cXML += 	'<eixos_suspensos_volta>' + AllTrim(Str((nQtdEixo - DTR->DTR_QTEIXV),2)) + '</eixos_suspensos_volta>'
				EndIf
			EndIf
		EndIf

		cXML += 	'<documentos>'
		DUD->(DbSetOrder(2))
		If DUD->(MsSeek(xFilial('DUD')+ cFilOri + cViagem))
			While DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == xFilial('DTR')+DTR->(DTR_FILORI+DTR_VIAGEM)
				If nCount < nDocsOpe
					cXML += 		'<documento>'
					cXML += 			'<documento_codigo>' + AllTrim(DUD->DUD_DOC) + '</documento_codigo>'
					cXML += 			'<serie>' +AllTrim(DUD->DUD_SERIE) + '</serie>'
					cXML += 			'<filial_codigo_cliente>' + PadL(Trim(DUD->DUD_FILORI),3,'0') + '</filial_codigo_cliente>'
					cXML += 		'</documento>'
					DT6->(DbSetOrder(1)) //--DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
					If DT6->(MsSeek(xFilial('DT6') + DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
						nPeso := nPeso + DT6->DT6_PESO
					EndIf
				EndIf
				DUD->(DbSkip())
				nCount++
			EndDo
		EndIf
		cXML += 	'</documentos>'

		cXML += 	'<peso>' + AllTrim(Str(nPeso,10,2)) + '</peso>'

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o controle de veiculos estiver ativo, sera utilizada a funcao      ³
		//³ TMSOdoSai para obter a ultima quilometragem de entrada do veiculo e   ³
		//³ se o controle de veiculos NAO estiver ativo, sera utilizada a funcao  ³
		//³ TMSOdoEnt para obter a quilometragem atual de saida do veiculo.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	    If !lContVei
			//Forcamos o commit neste ponto da rotina pois como estamos em uma transacao, em alguns
			//casos este select nao lia todos as informacoes o que causava divergencia nos valores,
			//como este comando apenas forca um Flush, nao grava informacoes no banco a nao ser
			//quando a transacao e efetivada (End Transaction), nao tem nenhum problema utilizar este comando
			//no meio de uma transacao, caso a transacao seja abortada os dados nao serao gravados.
			DUV->(dbCommit())

			//-- Obtem a quilometragem de Entrada
			If lTM310ODE
				nRetPE := ExecBlock( "TM310ODE", .F., .F.,{cFilOri,cViagem,DTR->DTR_CODVEI})
				If ValType(nRetPE)=="N"
					nKmIni:=nRetPE
				EndIf
			Else
				TMSVOdoEnt(DTR->DTR_CODVEI,,0,.F.,@nKmIni)
			EndIf

		Else

			//-- Obtem a quilometragem de Saida
			If lTM310ODE
				nRetPE := ExecBlock( "TM310ODE", .F., .F.,{cFilOri,cViagem,DTR->DTR_CODVEI})
				If ValType(nRetPE)=="N"
					nKmIni:=nRetPE
				EndIf
			Else
				TMSVOdoSai(DTR->DTR_CODVEI,,0,.F.,@nKmIni)
			EndIf

		EndIf

		cXML += 	'<km_inicial>'+ AllTrim( Str( nKmIni ) ) +'</km_inicial>'
		cXML += 	'<movimentos/>'
		cXML += '</processo_transporte>'
	EndIf

ElseIf nOpcx == 5 //-- Estorno

	DTR->(DbSetOrder(1))
	If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
		cXML += '<processo_transporte>'
		cXML += 	'<processo_transporte_codigo>' + AllTrim(DTR->DTR_PRCTRA) + '</processo_transporte_codigo>'
		cXML += 	'<processo_cliente_codigo>' + cFilOri + cViagem + '</processo_cliente_codigo>'
		cXML += 	'<processo_cliente_filial_codigo_cliente>' + PadL(cFilOri, 3, '0') + '</processo_cliente_filial_codigo_cliente>'
		cXML += '</processo_transporte>'
	EndIf
EndIf

If lTM310XML
	cXmlNew := Execblock("TM310XML",.F.,.F.,{cXML})
	If ValType( cXmlNew ) == 'C'
		cXML := cXmlNew
	EndIf
EndIf

cXML := TMSNoAcento( cXML )

//-- Gera XML em Disco
If lTMSXML
	If nOpcx == 3
		TMSLogXML( cXML, 'EmiteControleViagem.XML' )
	Else
		TMSLogXML( cXML, 'CancelaControleViagem.XML' )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ACIONA O WEBSERVICE PARA CONTROLE DE VIAGEM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TmsRepTrac("EmiteControleViagem - Instanciando "+AllToChar(nOpcx))
oObj := WSIntegracao():New()
TmsRepTrac("EmiteControleViagem - Instanciado ")
oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
oObj:cStrXMLIn             := cXML
oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora

If nOpcx == 3
	If oObj:EmiteControleViagem()
		TmsRepTrac("EmiteControleViagem - Consumido " + AllToChar(oObj:lEmiteControleViagemResult))

		If oObj:lEmiteControleViagemResult

			lRet := .T.

			//-- Gera Log referente a transacao
			TMSGerLog( cCodOpe, 'CV', 'E', xFilial('DTQ') + cViagem, 'DTQ', '0' )

			//-- Remove acentos e caracteres especiais
			oObj:cStrXMLOut := TMSNoAcento( oObj:cStrXMLOut )

			//-- Gera XML em Disco
			If lTMSXML
				TMSLogXML( oObj:cStrXMLOut, 'EmiteControleViagemResult.XML' )
			EndIf

			//-- Coverte em Objeto o XML de retorno enviado pela Operadora
			oXML := XMLParser( oObj:cStrXMLOut, '_', @cError, @cWarning )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dados da Movimentacao de Valores                      ³
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//³ [01]     - Dados da Movimentacao de Valores           ³
			//³ [01][01] - Numero do Contrato                         ³
			//³ [01][02] - Numero do Processo de Transp. (Operadora)  ³
			//³ [01][03] - Codigo do Movimento                        ³
			//³ [01][04] - Valor do Movimento                         ³
			//³ [01][05] - Tipo do Movimento (Debito/Credito/Pedagio) ³
			//³ [01][06] - Operacao (0=Inclusao/1=Exclusao)           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If XMLChildCount( oXML:_Processo_Transporte:_Movimentos ) > 0
				If ValType ( oXML:_Processo_Transporte:_Movimentos ) == 'A'
					For nAux := 1 To Len(oXML:_Processo_Transporte:_Movimentos:_Movimento)
						AAdd(aMovtos, {	oXML:_Processo_Transporte:_Processo_Cliente_Codigo:Text,;
										oXML:_Processo_Transporte:_Processo_Transporte_Codigo:Text,;
										oXML:_Processo_Transporte:_Movimentos:_Movimento[nAux]:_Movimento_Codigo_Cliente:Text,;
										oXML:_Processo_Transporte:_Movimentos:_Movimento[nAux]:_Valor:Text,;
										oXML:_Processo_Transporte:_Movimentos:_Movimento[nAux]:_Tipo:Text} )
					Next
				Else
					AAdd(aMovtos, {	oXML:_Processo_Transporte:_Processo_Cliente_Codigo:Text,;
									oXML:_Processo_Transporte:_Processo_Transporte_Codigo:Text,;
									oXML:_Processo_Transporte:_Movimentos:_Movimento:_Movimento_Codigo_Cliente:Text,;
									oXML:_Processo_Transporte:_Movimentos:_Movimento:_Valor:Text,;
									oXML:_Processo_Transporte:_Movimentos:_Movimento:_Tipo:Text} )
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Envia os Movimentos para a Operadora³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(aMovtos)
					CursorWait()
					MsgRun( STR0012,; //-- 'Realizando comunicacao com a Operadora...'
							STR0013,; //-- 'Aguarde...'
							{|| TMSMovVal( cCodOpe, cFilOri, cViagem, aMovtos, nOpcx, cCodVei ) })
					CursorArrow()
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estrutura do Array aPassagens                         ³
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//³ [01] - N.o do Processo de Transporte                  ³
			//³ [02] - Dt. de Previsao da Passagem                    ³
			//³ [03] - Hr. de Previsao da Passagem                    ³
			//³ [04][01] - CNPJ do Posto                              ³
			//³ [04][02] - Razao Social do Posto                      ³
			//³ [04][03] - Endereco                                   ³
			//³ [04][04] - Cidade                                     ³
			//³ [04][05] - Estado                                     ³
			//³ [04][06] - Telefone                                   ³
			//³ [05] - Vlr. do Combustivel                            ³
			//³ [06] - Dt. Real da Passagem                           ³
			//³ [07] - Hr. Real da Passagem                           ³
			//³ [08] - Vlr. Referente ao Consumo                      ³
			//³ [09] - Vlr. Referente ao Saque                        ³
			//³ [10] - Dt. Previsao de Pagto. do Consumo              ³
			//³ [11] - Dt. Previsao de Pagto. do Saque                ³
			//³ [12] - N.o do Documento relacionado a Passagem        ³
			//³ [13] - Indice do Lancto. (Ordem da Passagem)          ³
			//³ [14] - Operacao: 0=Baixa da Passagem                  ³
			//³                  1=Estorno da Baixa                   ³
			//³                  2=Nova Passagem em Aberto            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If XMLChildCount( oXML:_Processo_Transporte:_Passagens ) > 0
				If ValType( oXML:_Processo_Transporte:_Passagens:_Passagem ) == 'A'
					For nAux := 1 To Len( oXML:_Processo_Transporte:_Passagens:_Passagem)
						AAdd( aPassagens, {	oXML:_Processo_Transporte:_Processo_Transporte_Codigo:Text,;
											Left(oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Data_Prevista:Text, 10),;
											Right(oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Data_Prevista:Text, 4),;
											{oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_CNPJ:Text,;
											oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Nome_Fantasia:Text,;
											oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Endereco:Text,;
											oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Cidade:Text,;
											oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Estado:Text,;
											oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Telefone:Text},;
											oXML:_Processo_Transporte:_Passagens:_Passagem[nAux]:_Preco_Diesel:Text,;
											'',;
											'',;
											'',;
											'',;
											'',;
											'',;
											'',;
											Str(nAux),;
											'2'} )
					Next
				Else
					AAdd( aPassagens, {	oXML:_Processo_Transporte:_Processo_Transporte_Codigo:Text,;
										Left(oXML:_Processo_Transporte:_Passagens:_Passagem:_Data_Prevista:Text, 10),;
										Right(oXML:_Processo_Transporte:_Passagens:_Passagem:_Data_Prevista:Text, 4),;
										{oXML:_Processo_Transporte:_Passagens:_Passagem:_CNPJ:Text,;
										oXML:_Processo_Transporte:_Passagens:_Passagem:_Nome_Fantasia:Text,;
										oXML:_Processo_Transporte:_Passagens:_Passagem:_Endereco:Text,;
										oXML:_Processo_Transporte:_Passagens:_Passagem:_Cidade:Text,;
										oXML:_Processo_Transporte:_Passagens:_Passagem:_Estado:Text,;
										oXML:_Processo_Transporte:_Passagens:_Passagem:_Telefone:Text},;
										oXML:_Processo_Transporte:_Passagens:_Passagem:_Preco_Diesel:Text,;
										'',;
										'',;
										'',;
										'',;
										'',;
										'',;
										'',;
										Str(nAux),;
										'2'} )
				EndIf
				//-- Atualiza os dados da Passagem no Posto
				TMSPassag( cCodOpe, cFilOri, cViagem, aPassagens)
		    EndIf
			//ATUALIZA O COMPLEMENTO DE VIAGEM (DTR)
			DTR->(DbSetOrder(1))
			If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
				RecLock('DTR',.F.)
				DTR->DTR_PRCTRA := AllTrim(oXML:_Processo_Transporte:_Processo_Transporte_Codigo:Text)
				MsUnLock()
			EndIf
		Else
			aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
			lRet := .F.
		EndIf
	Else
		aMsgErr := TMSErrOper(cCodOpe,, '2')
		lRet := .F.
	EndIf

ElseIf nOpcx == 5
	If oObj:CancelaControleViagem()
		TmsRepTrac("CancelaControleViagem - Consumido " + AllToChar(oObj:lEmiteControleViagemResult))
		If oObj:lCancelaControleViagemResult
			lRet := .T.

			//-- Atualiza o Log de Transacoes
			TMSGerLog(cCodOpe, 'CV', 'E', DTQ->(DTQ_FILIAL+DTQ_VIAGEM), 'DEN', '0' )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Elimina as Passagens em Postos referente ao Processo de Transporte³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEP->(DbSetOrder(1)) //-- DEP_FILIAL+DEP_FILORI+DEP_VIAGEM+DEP_ORDEM
			If DEP->(MsSeek(xFilial('DEP') + cFilOri + cViagem))
				While DEP->(MsSeek(xFilial('DEP') + cFilOri + cViagem))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³EXCLUI A OPERACAO DE TRANSPORTE³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(cAtivPsg)
						DTW->(DbSetOrder(1))
						DTW->(MsSeek(xFilial('DTW') + cFilOri + cViagem ))
						While DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM) == xFilial('DTW') + cFilOri + cViagem
							If DTW->DTW_ATIVID = cAtivPsg
								RecLock('DTW',.F.)
								DTW->(DbDelete())
								MsUnLock()
							EndIf
							DTW->(DbSkip())
						EndDo
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³EXCLUI A PASSAGEM³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock('DEP',.F.)
					DEP->(DbDelete())
					MsUnLock()
				EndDo
			EndIf
		Else
			aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
			lRet := .F.
		EndIf
	Else
		aMsgErr := TMSErrOper(cCodOpe,, '2')
		lRet := .F.
	EndIf

EndIf
TmsRepTrac("EmiteControleViagem - Consumido " + AllToChar(oObj:lEmiteControleViagemResult))

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RepVldId   ³ Autor ³ Vitor Raspa          ³ Data ³ 15.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza validação do CArtão na operadora  Repom            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA240    												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RepVldId( cTipMot, cIdOpe, cCodMot )
Local lRet		:= .T.
Local cError	:= ""
Local cWarning	:= ""
Local oObj
Local oXML, nXMLStatus
Local cSvcError, cSoapFCode, cSoapFDescr
Local cRetErr

Default cIdOpe	:= '01'

TmsRepTrac("Inicio de Função")

//- Tipo de Motorista para a REPOM:
//- 1- Proprio
//- 2- Terceiro
cTipMot := If( cTipMot == '1', '1', '2')

If lRestRepom
	lRet := TMSVCard(cCodMot) // RAP
Else
	oObj := WSIntegracao():New()
	TmsRepTrac("ValidaCartaoExpress - Instanciado ")
	//--Seta a URL conforme cadastro da Operadora
	oObj:_URL                  := DEG->DEG_URLWS
	oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
	oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
	oObj:cStrTipoEmissao       := cTipMot
	oObj:cStrCartao            := cIdOpe

	If oObj:ValidaCartaoExpress()
		TmsRepTrac("ValidaCartaoExpress - Consumido "+AllToChar(oObj:lValidaCartaoExpressResult))
		If !oObj:lValidaCartaoExpressResult
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³TRATA O XML DE RETORNO COM A MENSAGEM DE ERRO ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//-- Remove acentos do XML de retorno
			oObj:cStrXMLErr := NoAcento( OemToAnsi(oObj:cStrXMLErr) )
			//-- Cria Objeto XML
			oXML := XMLParser( oObj:cStrXMLErr , "_", @cError, @cWarning )
			nXMLStatus := XMLError()
			If !( nXMLStatus == XERROR_SUCCESS )
				//-- Problema na geracao do XML
				Aviso(STR0001, If(!Empty(cError), cError, cWarning) , {STR0003} ) //"AVISO"###"OK"
			Else
				//-- Objeto XML gerado com sucesso! - Exibindo a mensagem de erro...
				cRetErr := oXML:_ERROS:_ERRO:_ERRO_CODIGO:Text + ' - ' + oXML:_ERROS:_ERRO:_ERRO_DESCRICAO:Text
				Help('',1,'TMSA24045',,cRetErr,03,01) //--'Ocorreu um Problema na Validação do Id do Motorista.'
			EndIf
			lRet := .F.
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³NAO FOI POSSIVEL EXECUTAR O METODO!³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aviso(STR0001, STR0030, {STR0003} ) //"AVISO" "Problemas na Comunicação com a Operadora!" "OK"
		cSvcError  	:= GetWSCError()		// Resumo do erro
		cSoapFCode  := GetWSCError(2)		// Soap Fault Code
		cSoapFDescr := GetWSCError(3)		// Soap Fault Description

		If !Empty(cSoapFCode)
			// Caso a ocorrência de erro esteja com o fault_code preenchido ,
			// a mesma teve relação com a chamada do serviço .
			Aviso(STR0001 + ' - ' + cSoapFCode, cSoapFDescr , {STR0003} ) //"AVISO"###"OK"
		Else
			// Caso a ocorrência não tenha o soap_code preenchido
			// Ela está relacionada a uma outra falha ,
			// provavelmente local ou interna.
			Aviso(STR0001, cSvcError, {STR0003}) //"AVISO"###"OK"
		Endif
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RepVldAber ³ Autor ³ Vitor Raspa          ³ Data ³ 15.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza validação da abertura de viagem na operadora Repom ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA240    												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RepVldAber(cCodOpe, cIdOpe,  cTipMot, cCodVei, cCodMot, cCodReb, nValFre, nValAdi, cTipCarga)
Local oObj
Local aArea		:= GetArea()
Local cError    := ""
Local cWarning  := ""
Local  nXMLStatus
Local cSvcError, cSoapFCode, cSoapFDescr
Local cRetErr
Local lRet 		:= .T.
Local lValida   := .T.
Local cXML	    := ''
Local lTMSXML   := GetMV( 'MV_TMSXML',, .F. )
Local aRegRot   := {}
Local nAux      := 0
Local cRoteir	:= ''
Local cPercur	:= ''
Local cOperac	:= SuperGetMv('MV_OPREPOM',,"")
Local cTipVei	:= ''
Local cMotForn	:= ''
Local cMotLoj	:= ''
Local cTipVia   := ''
Local cRNTRC    := ""

Default cCodReb   := ''
Default nValFre   := 0
Default nValAdi   := 0
Default cTipCarga := ''

TmsRepTrac("Inicio de Função")
//- Tipo de Motorista para a REPOM:
//- 1- Proprio
//- 2- Terceiro
cTipMot := If( cTipMot == '1', '1', '2')


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³XML - VALIDA ABERTURA CONTRATO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cXML += '<valida_abertura_contrato>'
cXML += 	'<cartao>' + AllTrim(cIdOpe) + '</cartao>'

DA3->(dbSetOrder(1))
If DA3->(MsSeek(xFilial('DA3')+ cCodVei  ))
	cTipVei := DA3->DA3_TIPVEI
	SA2->(DbSetOrder(1))
	SA2->(MsSeek(xFilial('SA2')+DA3->DA3_CODFOR+DA3->DA3_LOJFOR))
EndIf
cXML += 	'<contratado_cnpj_cpf>' + AllTrim(SA2->A2_CGC) + '</contratado_cnpj_cpf>'
cXML += 	'<contratado_rntrc>' + AllTrim(SA2->A2_RNTRC) + '</contratado_rntrc>'

DA4->(DbSetOrder(1))
DA4->(MsSeek(xFilial('DA4')+cCodMot))
cMotForn	:= DA4->DA4_FORNEC
cMotLoj		:= DA4->DA4_LOJA
cXML += 	'<motorista_cpf>' + AllTrim(DA4->DA4_CGC) + '</motorista_cpf>'
//--
DA3->(dbSetOrder(1))
If DA3->(MsSeek(xFilial('DA3')+ cCodVei ))
	cXML += 	'<cavalo_placa>' + AllTrim(DA3->DA3_PLACA) + '</cavalo_placa>'
	If DA3->(FieldPos("DA3_RNTC")) > 0
		cXML += 	'<cavalo_rntrc>' + AllTrim(DA3->DA3_RNTC) + '</cavalo_rntrc>'
	Else
		cXML += 	'<cavalo_rntrc>' + AllTrim(SA2->A2_RNTRC) + '</cavalo_rntrc>'
	EndIf
EndIf

DA3->(dbSetOrder(1))
If DA3->(MsSeek(xFilial('DA3')+ cCodReb )) 
	cXML += 	'<carreta_placa>' + AllTrim(DA3->DA3_PLACA) + '</carreta_placa>'
	cRNTRC := RetRntrVei(DA3->DA3_COD)
	If DA3->(FieldPos("DA3_RNTC")) > 0
		cXML += 	'<carreta_rntrc>' + AllTrim(DA3->DA3_RNTC) + '</carreta_rntrc>'
	Else
		cXML += 	'<carreta_rntrc>' + AllTrim(cRNTRC) + '</carreta_rntrc>' 
	EndIf
	SA2->(DbSetOrder(1))
	If SA2->(MsSeek(xFilial('SA2')+DA3->DA3_CODFOR+DA3->DA3_LOJFOR))
		cXML += 	'<carreta_rntrc_cnpj_cpf>' + AllTrim(SA2->A2_CGC) +  '</carreta_rntrc_cnpj_cpf>'  
	Else
		cXML += 	'<carreta_rntrc_cnpj_cpf></carreta_rntrc_cnpj_cpf>'	
	EndIf	
Else
	cXML += 	'<carreta_placa></carreta_placa>'
	cXML += 	'<carreta_rntrc></carreta_rntrc>'
EndIf

cXML += 	'<valor_frete>' + AllTrim(Str(nValFre)) + '</valor_frete>'
cXML += 	'<valor_adiantamento>' + AllTrim(Str(nValAdi)) + '</valor_adiantamento>'

If cTipCarga == '1' .And. !Empty(cNatuCarg)
	cXML +=  '<antt_ncm_codigo_classificacao_mercadoria>'+cNatuCarg+'</antt_ncm_codigo_classificacao_mercadoria>' // Codigo da lotacao
Else
	cXML +=  '<antt_ncm_codigo_classificacao_mercadoria>0001</antt_ncm_codigo_classificacao_mercadoria>' //Carga Fracionada / Padrao 0001
EndIf

If cTipVia == StrZero( 2, Len( DTQ->DTQ_TIPVIA ) )  //Vazia
	cXML += 	'<operacao>' + AllTrim(cOperac) + '</operacao>'
Else
	DEJ->(DbSetOrder(2))
	If DEJ->(MsSeek(xFilial('DEJ')+cCodOpe+Iif((Upper(AllTrim(FunName())) == "TMSA240" .Or. Upper(AllTrim(FunName())) == "TMSA190"),DTQ->(DTQ_SERTMS + DTQ_TIPTRA),M->(DTQ_SERTMS + DTQ_TIPTRA) )))
		cXML += 	'<operacao>' + AllTrim(DEJ->DEJ_OPERAC) + '</operacao>'
	Else
		cXML += 	'<operacao></operacao>'
	EndIf
EndIf
cXML += 	'<filial_codigo_cliente>' + M->DTR_FILORI + '</filial_codigo_cliente>'
cXML += 	'<usuario>' + UsrFullName() + '</usuario>'
cXML += 	'<usuario_telefone></usuario_telefone>'
cXML += 	'<roteiro_tipo>' +  '0' + '</roteiro_tipo>'
cXML += 	'<roteiro_linear>' + '0' + '</roteiro_linear>'
cXML += 	'<carta_frete_complementar></carta_frete_complementar>'
cXML += 	'<trechos />'

//-- Verifica a amarracao Rota X Roteiro/Percurso
cFroVei := Posicione('DA3',1,xFilial('DA3') + cCodVei,'DA3_FROVEI')
SIX->(DbSetOrder(1))
If SIX->( MsSeek( 'DEK' + '3' ) )
	DEK->(DbSetOrder(3))
	If DEK->(MsSeek(xFilial('DEK')+cRota+cFroVei+cCodOpe))
		cRoteir := AllTrim(DEK->DEK_ROTEIR)
		cPercur := AllTrim(DEK->DEK_CODPER)
	ElseIf DEK->( MsSeek(xFilial('DEK')+cRota+'0'+cCodOpe) )
		cRoteir := AllTrim(DEK->DEK_ROTEIR)
		cPercur := AllTrim(DEK->DEK_CODPER)
	ElseIf DEK->( MsSeek(xFilial('DEK')+cRota+' '+cCodOpe) )
		cRoteir := AllTrim(DEK->DEK_ROTEIR)
		cPercur := AllTrim(DEK->DEK_CODPER)
	EndIf
Else
	DEK->(DbSetOrder(2))
	If DEK->( MsSeek(xFilial('DEK') + cRota + cCodOpe) )
		cRoteir := AllTrim(DEK->DEK_ROTEIR)
		cPercur := AllTrim(DEK->DEK_CODPER)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna as Filiais / Regioes de Descarga da Rota                      ³
//³ Elementos contidos por dimensao:                                      ³
//³ 1. Regiao Origem da Rota                                              ³
//³ 2. Regioes de Descarga da Rota                                        ³
//³ 3. Filiais de Descarga da Rota                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRegRot := TMSRegDca(cRota)
	
cXML += '</valida_abertura_contrato>'

If lTM240XML
	cXmlNew := Execblock("TM240XML",.F.,.F.,{cXML})
	If ValType( cXmlNew ) == 'C'
		cXML := cXmlNew
	EndIf
EndIf

//-- Remove Caracteres especiais no cXML
cXML := TMSNoAcento( cXML )

//-- Gera XML em Disco
If lTMSXML
	TMSLogXML( cXML, 'ValidaAberturaContrato.XML' )
EndIf

TmsRepTrac("ValidaAberturaContrato - Instanciando ")
oObj := WSIntegracao():New()
TmsRepTrac("ValidaAberturaContrato - Instanciado ")
//-- Aciona o WEBSERVICE
oObj:_URL                  := DEG->DEG_URLWS
oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
oObj:cStrXMLIn             := cXML

If oObj:ValidaAberturaContrato()
	TmsRepTrac("ValidaAberturaContrato - Consumido "+ AllToChar(oObj:lValidaAberturaContratoResult))
	If !oObj:lValidaAberturaContratoResult
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³TRATA O XML DE RETORNO COM A MENSAGEM DE ERRO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//-- Remove acentos do XML de retorno
		oObj:cStrXMLErr := NoAcento( OemToAnsi(oObj:cStrXMLErr) )
		//-- Cria Objeto XML
		oXML := XMLParser( oObj:cStrXMLErr , "_", @cError, @cWarning )
		nXMLStatus := XMLError()
		If !( nXMLStatus == XERROR_SUCCESS )
		//-- Problema na geracao do XML
			Aviso(STR0001, If(!Empty(cError), cError, cWarning) , {STR0003} ) //"AVISO"###"OK"
		Else
			If Type("oXML:_ERROS:_ERRO") <> 'U'
				If Type("oXML:_ERROS:_ERRO") == 'A'
					For nAux := 1 To Len(oXML:_ERROS:_ERRO)
						//-- Objeto XML gerado com sucesso! - Exibindo a mensagem de erro...
						cRetErr := oXML:_ERROS:_ERRO[nAux]:_ERRO_CODIGO:Text + ' - ' + oXML:_ERROS:_ERRO[nAux]:_ERRO_DESCRICAO:Text
							Aviso(STR0001, cRetErr, {STR0003} ) //"AVISO" 'Ocorreu um Problema na Validação da Abertura do Contrato.' "OK"
					Next
				Else
					//-- Objeto XML gerado com sucesso! - Exibindo a mensagem de erro...
					cRetErr := oXML:_ERROS:_ERRO:_ERRO_CODIGO:Text + ' - ' + oXML:_ERROS:_ERRO:_ERRO_DESCRICAO:Text
					Aviso(STR0001, cRetErr, {STR0003} ) //"AVISO" 'Ocorreu um Problema na Validação da Abertura do Contrato.' "OK"
				EndIf
			Else
				//-- Problema na geracao do XML
				Aviso(STR0001, STR0030, {STR0003} ) //"AVISO" "Problemas na Comunicação com a Operadora!" "OK"
			EndIf
		EndIf
		lRet := .F.
	Else
		AAdd( aVldId, {cCodOpe, cTipMot, cIdOpe} )
	EndIf
Else
	lValida:=.F.
EndIf

If !lValida
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³NAO FOI POSSIVEL EXECUTAR O METODO!³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aviso(STR0001, STR0030, {STR0003} ) //"AVISO" "Problemas na Comunicação com a Operadora!" "OK"
	cSvcError  	:= GetWSCError()		// Resumo do erro
	cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	cSoapFDescr := GetWSCError(3)		// Soap Fault Description

	If !Empty(cSoapFCode)
		TmsRepTrac("ValidaAberturaContrato - Erro: "+ AllToChar(cSoapFCode) + AllToChar(cSoapFCode) )
		// Caso a ocorrência de erro esteja com o fault_code preenchido ,
		// a mesma teve relação com a chamada do serviço .
		Aviso(STR0001 + ' - ' + cSoapFCode, cSoapFDescr , {STR0003} ) //"AVISO"###"OK"

	Else
		TmsRepTrac("ValidaAberturaContrato - Erro: "+ AllToChar(cSvcError) )
		// Caso a ocorrência não tenha o soap_code preenchido
		// Ela está relacionada a uma outra falha ,
		// provavelmente local ou interna.
		Aviso(STR0001, cSvcError, {STR0003}) //"AVISO"###"OK"
	Endif
	lRet := .F.
EndIf

RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RepQuitMet³ Autor ³ Vitor Raspa           ³ Data ³ 15.Nov.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a Quitacao do Contrato junto a Operadora de Frota   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lRet := TMA310Oper(cExpC1, cExpC2, cExpC3, @aExpA1 )        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1 - Codigo da Operadora de Frotas                      ³±±
±±³          ³cExpC2 - Filial de Origem                                   ³±±
±±³          ³cExpC3 - Numero da Viagem                                   ³±±
±±³          ³aExpA1 - Array com as Mensagens de Erro (Por Referencia)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico - .T. indica sucesso no processamento do metodo      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RepQuitMet( cCodOpe, cFilOri, cViagem, aMsgErr, aDadosQuit, cContrat, cCodVei, lQuitacao, nValFre)
Local lRet     := .T.
Local cXML     := ''
Local cXmlNew  := ''
Local oObj     := NIL
Local cError   := ''
Local cWarning := ''
Local nValSaq  := 0
Local nValCon  := 0
Local nSalPag  := 0
Local nFrePag  := 0
Local cDesAdf  := SuperGetMV('MV_DESADF',,'') //-- Despesa para lancamento de Adto. de Frete
Local aArea    := GetArea()
Local aAreaDTR := DTR->(GetArea())
Local lTMSXML  := GetMV( 'MV_TMSXML',, .F. )
Local oXML     := NIL
Local cVsRepom := SuperGetMV( 'MV_VSREPOM',, '1' )  //-- Versao 2- Contempla nova Legislacao (Encerramento viagem no Posto)
Local cValFret := 0
Local cPeso	 := 0
Local cData	 := ''
Local cDia	   	 := ''
Local cMes	   := ''
Local cAno	   := ''
Local cCodFor  := ''
Local cLojFor  := ''
Local cCond	   := ''
Local aData	   := {}
Local aMov
Local cLocQui   := ''
Local lRepom    := SuperGetMV( 'MV_VSREPOM',, '1' ) $ '2|2.2'
Local cDesAbast	:= SuperGetMV( 'MV_ABAST',, '' )
Local cDesSaq	:= SuperGetMV( 'MV_DESSAQ',, '' )
Local cTipPess  := ""
Local lAtuQuit  := .F.
Local cImpCTC   := SuperGetMv("MV_IMPCTC",,"0") 
Local lQuitaCont:= .F.
Local aMovRep   := {}
Local cSeek		:= ""
Local aRet		:= {}
Local cAux		:= ""

TmsRepTrac("Inicio de Função")
//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 255 )

Default lQuitacao := .T.
Default cCodVei   := ''
Default nValFre   := 0

TmsRepTrac("DTY_LOCQUI")
DTY->(DbSetOrder(2))
If DTY->(DbSeek(xFilial('DTY') + cFilOri + cViagem))
	TmsRepTrac("Seek DTY OK:"+xFilial('DTY') + cFilOri + cViagem)
	cPeso    := DTY->DTY_PESO
	cValFret := DTY->DTY_VALFRE
	cCodFor  := DTY->DTY_CODFOR
	cLojFor  := DTY->DTY_LOJFOR
	cLocQui  := DTY->DTY_LOCQUI
	If  Empty(cCodVei)
   		cCodVei := DTY->DTY_CODVEI
   	Endif
Else
	TmsRepTrac("Seek DTY NOK:"+xFilial('DTY') + cFilOri + cViagem)
EndIf

If !Empty(cCodFor) .And.!Empty(cLojFor)      //-- Conseguir a condicao de pagto do Fornecedor
	SA2->(DbSetOrder(1))
	If SA2->(MsSeek(xFilial('SA2')+cCodFor+cLojFor))
		TmsRepTrac("Seek SA2 OK:"+xFilial('SA2')+cCodFor+cLojFor)
	     cCond	:= SA2->A2_COND
	Else
		TmsRepTrac("Seek SA2 NOK:"+xFilial('SA2')+cCodFor+cLojFor)
	EndIf
EndIf

DEG->(DbSetOrder(1))
lRet := DEG->(MsSeek(xFilial('DEG')+cCodOpe))

If lRet 
	TmsRepTrac("Seek DEG OK:"+AllToChar(lQuitacao))
	If lQuitacao
		If !lRestRepom
			aData := Condicao(cValFret,cCond,0,dDatabase)   //-- Conseguir a data Prevista
			cData := Iif(Len(aData)>0, DTOC(aData[1][1]), '')

			If  cData == DTOC(dDatabase) .Or. Empty(cData)   //-- Repom nao aceita data prevista para o mesmo dia (a vista)
				cData := DTOC(dDatabase+1)
			EndIf
			If !Empty(cData)
				cDia := Substring(cData,1,2)
				cMes := Substring(cData,4,2)
				cAno := Substring(cData,7,4)    //-- necessario informar ano com 4 chars
				cData := ''
				cData := cDia+'/'+cMes+'/'+cAno
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³XML para processamento da Quitacao do Contrato³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cXML += '<processo_transporte>'
			cXML += 	'<cliente_codigo>' + AllTrim(DEG->DEG_IDOPE) + '</cliente_codigo>'
			cXML += 	'<processo_cliente_codigo>' + cFilOri + cViagem + '</processo_cliente_codigo>'
			cXML += 	'<processo_cliente_filial_codigo_cliente/>'
			cXML += 	'<processo_transporte_codigo>' + AllTrim(Posicione('DTR',1,xFilial('DTR') + cFilOri + cViagem, 'DTR_PRCTRA')) + '</processo_transporte_codigo>'
			cXML += 	'<filial_codigo_cliente>' + cFilOri + '</filial_codigo_cliente>'
			if cVsRepom == '2'
				cXML +=		'<peso_entrega>'+ Alltrim(Str(cPeso)) +'</peso_entrega>'
			else
				cXML +=		'<peso_entrega/>'
			endif
			cXML +=		'<avarias/>'
			cXML +=		'<ocorrencias/>'
			cXML +=		'<quitacao_tipo>'+ '0' +'</quitacao_tipo>'                    //novo
			If cVsRepom == '2'
				cXML +=		'<data_prevista_pagamento>'+cData+'</data_prevista_pagamento>'               //novo
			Else
				cXML +=		'<data_prevista_pagamento></data_prevista_pagamento>'
			EndIf
			cXML +=		'<novo_processo_cliente_codigo></novo_processo_cliente_codigo>'     //novo
			cXML +=		'<novo_processo_cliente_filial_codigo_cliente></novo_processo_cliente_filial_codigo_cliente>'   //novo
			cXML += '</processo_transporte>'

			//-- Gera XML em Disco
			If lTMSXML
				TMSLogXML( cXML, 'QuitaContrato.XML' )
			EndIf
		
			If lTM251XML
				cXmlNew := Execblock("TM251XML",.F.,.F.,{cXML})
				If ValType( cXmlNew ) == 'C'
					cXML := cXmlNew
				EndIf
			EndIf

			//-- Remove acentos e caracteres especiais
			cXML := TMSNoAcento( cXML )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ACIONA O WEBSERVICE ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TmsRepTrac("QuitaContrato Instanciando "+AllToChar(lQuitacao))
			oObj := WSIntegracao():New()
			TmsRepTrac("QuitaContrato Instanciado ")
			oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
			oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
			oObj:cStrXMLIn             := cXML
			oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora

			If lQuitacao
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REALIZACAO DA QUITACAO DO CONTRATO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oObj:QuitaContrato()
					TmsRepTrac("QuitaContrato Consumido "+AllToChar(oObj:lQuitaContratoResult))
					If oObj:lQuitaContratoResult
						//-- Remove os acentos do XML de Retorno
						oObj:cStrXMLOut := TMSNoAcento( oObj:cStrXMLOut )

						//-- Gera XML em Disco
						If lTMSXML
							TMSLogXML( oObj:cStrXMLOut, 'QuitaContratoResult.XML' )
						EndIf
						TmsRepTrac("QuitaContrato Gravou XML ")
						//-- Coverte em Objeto o XML de retorno enviado pela Operadora
						oXML := XMLParser( oObj:cStrXMLOut, '_', @cError, @cWarning )

						TmsRepTrac("QuitaContrato Parseou XML ")

						//-- Grava os dados da quitacao
						nValSaq := StrTran( oXML:_Recibo_Quitacao:_Processo_Transporte:_Movimentacao_Financeira:_Total_Saque:Text, ',', '' )
						nValCon := StrTran( oXML:_Recibo_Quitacao:_Processo_Transporte:_Movimentacao_Financeira:_Total_Consumo:Text, ',', '' )
						nSalPag := StrTran( oXML:_Recibo_Quitacao:_Processo_Transporte:_Valor_Final:Text, ',', '')
						nFrePag := StrTran( oXML:_Recibo_Quitacao:_Processo_Transporte:_Movimentacao_Financeira:_Valor_Frete:Text, ',', '' )

						nValSaq := Val( nValSaq )
						nValCon := Val( nValCon )
						nSalPag := Val( nSalPag )
						nFrePag := Val( nFrePag )

						lQuitaCont := .T.  //Contrato Quitado (controle para atualizar os dados)

						//Parte 1
						//Parte 2
					Else
						aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
						lRet := .F.
					EndIf
				Else
					aMsgErr := TMSErrOper(cCodOpe,, '2')
					lRet := .F.
				EndIf
			EndIf

			If lRet .And. lTM251Ope
				ExecBlock('TM251Ope',.F.,.F.,{cCodOpe, cFilOri, cViagem, cContrat, cCodVei, oXML, lQuitacao})
			EndIf	

		Else  //lRestRepom -- Nova versao 2.2
			
			If cImpCTC == '1' .And. cTmsErp == '0' //Valida se os impostos foram calculados na REPOM
				lRet:= RepVldImp(cFilOri , cViagem, cCodVei, @aMsgErr)  
			EndIf
			If lRet
				//--- Valida se o contrato ja foi quitado no Posto. Se quitado, nao envia o Metodo de quitação novamente.
				//--- somente a geração das Tabelas			
				lQuitaCont:= TMSC15ARep( 10 , cFilOri , cViagem, .F.  )  
				If !lQuitaCont
					//-- Adiciona valores 
					TM15AddTax( cFilOri , cViagem  )
					
					lRet:= TMSC15ARep( 8 , cFilOri , cViagem, .F.  )  //PaymentCreate
					If lRet
						cLocQui		:= "0" //-- Filial
						lQuitaCont	:= .T.
					EndIf
				Else 
					cLocQui		:= "1"	//-- Posto
				EndIf
				
				//-- Atualiza local de quitação
				If lRet
					
					DTY->(DbSetOrder(2))
					If DTY->(DbSeek( cSeek := xFilial('DTY') + cFilOri + cViagem))
						If !Empty(DTY->DTY_CODOBS)
							cAux := AllTrim(MSMM(DTY->DTY_CODOBS,80)) + chr(10) + chr(13)
						EndIf

						aRet	:= TM15GtById(cFilOri, cViagem)  

						If Len(aRet) > 3 
							cAux	+= "CIOTINCONTINGENCY : " + aRet[4] + chr(10) + chr(13)
							cAux	+= "CIOT : " + aRet[3]
						EndIf 					

						While DTY->(!Eof()) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM) == cSeek
						
							RecLock("DTY",.F.)

							If !Empty(cAux)
								MSMM(DTY->DTY_CODOBS,,,cAux,1,,,"DTY","DTY_CODOBS")
							EndIf 

							DTY->DTY_LOCQUI		:= cLocQui //-- 0=Filial;1=Posto
							DTY->(MsUnLock())

							DTY->( dbSkip() )
						EndDo 
					EndIf
				EndIf 
			EndIf
		EndIf

		//--- Quitado o Contrato (Atualiza os dados) -- Unificado para versao 2 e 2.2
		If lQuitaCont 
			//--- Atualiza Status da DTY, se o Local de Quitacao igual a 1- Posto
			TmsGravDTY(cFilOri,cViagem)  
						
			//--- Atualiza DES para as quitações em aberto
			lAtuQuit:= TmsAtuQuit(cFilOri,cViagem,nValSaq,nValCon,nSalPag,cDesSaq,cDesAbast,cDesAdf,lRepom,cCodVei)
			If lAtuQuit
				TmsRepTrac("QuitaContrato cDesAdf/lRepom:"+cDesAdf+"/"+AllToChar(lRepom))
						
				//-- Gera Movto. de Custo de transporte referente aos valores de Saques e Consumos										
				TmsMovQuit(cFilOri,cViagem,nValSaq,nValCon,cDesSaq,cDesAbast,cDesAdf,lRepom,cCodVei)

				//-- Se pessoa fisica, aguarda consultacontrato para conseguir os valores do impostos e jogar na dty
				//-- se pessoa jurica, nao calcula impostos, deixa para libera o contrato direto
				//--------------
				//** aMov[1] =  codigo Repom do Imposto
				//** aMov[2] =  valor do desconto
				//** aMov[3] =  data e hora do mov
				cTipPess :=	TmsXPess(cFilOri, cViagem, cCodVei)
				TmsRepTrac("QuitaContrato TmsXPess: "+cTipPess+"/"+ cImpCTC )

				If Alltrim(cTipPess) == 'F' .And. AllTrim(cImpCTC) == "1" //-- 0-Impostos ERP;1-Impostos pela operadora
					If !lRestRepom
						aMov := oXML:_Recibo_Quitacao:_Processo_Transporte:_Movimentacao_Financeira:_Movimentacoes:_Movimentacao
						TmsRepTrac("QuitaContrato TmsxInImp: "+VarInfo("aMov",aMov))
						//-- Funcao com o result dos impostos <movimentacao>
						If Len(aMov) > 0
							TmsxInImp(cFilOri, cViagem, aMov)
						EndIf
					Else						
						aMovRep:= TmsIncImp( cFilOri,cViagem ) //Pesquisa os Movimentos Impostos REpom
						//--- Impostos Repom versao 2.2.
						If Len(aMovRep) > 0
							TmsImpRep(cFilOri,cViagem,aMovRep,.F.)
						EndIf
					EndIf							
				EndIf

			Else
				TmsRepTrac("QuitaContrato Seek DES NOK:"+xFilial('DES') + cFilOri + cViagem+"/DES_STATUS:"+DES->DES_STATUS)
			EndIf
			//Parte 2
			//-- Gera Movto. de Custo de transporte referente aos valores de Saques e Consumos (Adtos.)
			If nValSaq > 0 .Or. nValCon > 0
				//-- Ajusta o Valor do Adto. no Contrato
				TmsAdiFre(cFilOri,cViagem,nValSaq,nValCon)  
			EndIf

			//-- Atualiza Log de Transacoes
			TMSGerLog( cCodOpe, 'QT', 'E', xFilial('DES') + cFilOri + cViagem, 'DES', '0' )
			TmsRepTrac("QuitaContrato TMSGerLog")						
		EndIf

	EndIf
EndIf


TmsRepTrac("QuitaContrato TMSGerLog FIM :"+AllToChar(lRet)+"/"+VarInfo("aMsgErr",aMsgErr))

//-- Configura o tamanho do nome das Variaveis
FWFreeArray(aMovRep)
SetVarNameLen( 10 )
RestArea(aArea)
RestArea(aAreaDTR)
Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RepQuitaCt³ Autor ³ Vitor Raspa           ³ Data ³ 15.Nov.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Baixa a Viagem (Propria) ou Autoriza a Quitacao do Contrato ³±±
±±³          ³(Terceiro) junto a Operadora de Frotas                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lRet := TMA340Oper(cExpC1, cExpC2, cExpC3, @aExpA1, nExpN1) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1 - Codigo da Operadora de Frotas                      ³±±
±±³          ³cExpC2 - Filial de Origem                                   ³±±
±±³          ³cExpC3 - Numero da Viagem                                   ³±±
±±³          ³aExpA1 - Array com as Mensagens de Erro (Por Referencia)    ³±±
±±³          ³lExpL1 - Indicador de Frota Propria (.T.)                   ³±±
±±³          ³nExpN1 - Opcao Selecionada (3-Encerramento / 5-Estorno      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico - .T. indica sucesso no processamento do metodo      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RepQuitaCt( cCodOpe, cFilOri, cViagem, aMsgErr, lFrotaProp, nOpcx, lFilial, nValFre )
Local oObj
Local cXML      := ''
Local cXmlNew   := ''
Local lRet      := .F.
Local aArea     := GetArea()
Local aAreaDTR  := DTR->(GetArea())
Local aAreaDT6  := DT6->(GetArea())
Local cTipo     := ''
Local lTMSXML   := GetMV( 'MV_TMSXML',, .F. )
Local nDocsOpe  := GetMV( 'MV_DOCSOPE',,999999) //-- Qtde. de Documentos que devem compor o XML de envio para a Operadora
Local nCount    := 0
Local lGerPdgPc := SuperGetMv("MV_TMSPDGP",,.F.) // Gera Pedido de Compra referente a Prestacao de servicos da Operadora
Local lTM340XML := ExistBlock('TM340XML')
Local cVsRepom  := SuperGetMV( 'MV_VSREPOM',, '1' )
Local aDocs		:= {}
Local lAutQuitOk:= .F.
Local lEstQuitOK:= .F.
Local cSeek		:= ""

Default lFilial   := .T.  //-- Identificacao para Local de quitacao
Default nValFre   := 0

TmsRepTrac("Inicio de Função")

//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 255 )

DEG->(DbSetOrder(1))
lRet := DEG->(MsSeek(xFilial('DEG')+cCodOpe))

IF lRet .And. !lFilial .And. cVsRepom == '2' // Baixa antecipada --> Recebe documentos na filial porem irá quitar no posto
	If cCodOpe == '01' .And. nOpcx == 3		 // REPOM Tecnologia ## Encerramento da Viagem
		DUA->(DbSetOrder( 2 ))
		If DUA->( DbSeek( xFilial( 'DUA' ) + cFilOri + cViagem ) )
			//-- Documentos da viagem para a Baixa Antecipada
			While DUA->( !Eof() .And. DUA_FILIAL = xFilial('DUA') .And. DUA_FILORI = cFilOri .And. DUA_VIAGEM = cViagem )
				DUD->(DbSetOrder(1))
				If DUD->(MsSeek(xFilial('DUD')+ DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE))
                    cTipo := RetRepomType(DUD->DUD_SERTMS, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE)
				EndIf
				Aadd( aDocs , {DUA->DUA_DOC,DUA->DUA_SERIE,DUA->DUA_FILDOC,cTipo} )
				DUA->( DbSkip() )
			EndDo
		EndIf

		// Metodo de envio dos documentos para a operadora
		If !Empty(aDocs)
			lRet := EnvDocOper( DEG->DEG_IDOPE, DEG->DEG_CODACE, DEG->DEG_URLWS, cFilOri+cViagem, , cFilOri, .F., , aDocs )
		Else
			If DTQ->DTQ_TIPVIA == StrZero( 2, Len( DTQ->DTQ_TIPVIA ) ) 	//Vazia
				lRet:= .T.
			EndIf
		EndIf
	Endif

ElseIf lRet .And. lFilial
	If cCodOpe == '01' .And. !lRestRepom //-- REPOM Tecnologia
		If nOpcx == 3 //-- Encerramento da Viagem
			If !lFrotaProp
				//-- XML para Autorizacao da Quitacao do contrato
				cXML += '<processo_transporte>'
				cXML += 	'<cliente_codigo>' + AllTrim(DEG->DEG_IDOPE) + '</cliente_codigo>'
				cXML += 	'<processo_cliente_codigo>' + cFilOri + cViagem + '</processo_cliente_codigo>'
				cXML += 	'<filial_codigo_cliente>' + cFilOri + '</filial_codigo_cliente>'
				cXML += 	'<processo_transporte_codigo>' + AllTrim(DTR->DTR_PRCTRA) + '</processo_transporte_codigo>'
				cXML += '</processo_transporte>'
			Else
				//-- XML para Baixa do Controle de Viagem
				cXML += '<processo_transporte>'
				cXML += 	'<processo_transporte_codigo>' + AllTrim(DTR->DTR_PRCTRA) + '</processo_transporte_codigo>'
				cXML += 	'<processo_cliente_codigo>' + cFilOri + cViagem + '</processo_cliente_codigo>
				cXML += 	'<processo_cliente_filial_codigo_cliente>' + cFilOri + '</processo_cliente_filial_codigo_cliente>
				cXML += 	'<filial_codigo_cliente/>'
				cXML +=		'<documentos>'
				DUD->(DbSetOrder(2))
				If DUD->(MsSeek(xFilial('DUD')+ cFilOri + cViagem))
					While DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == xFilial('DTR')+DTR->(DTR_FILORI+DTR_VIAGEM)
						If nCount < nDocsOpe
							cXML += 		'<documento>'
							cXML += 			'<documento_codigo>' + AllTrim(DUD->DUD_DOC) + '</documento_codigo>'
							cXML += 			'<serie>' +AllTrim(DUD->DUD_SERIE) + '</serie>'
							cXML += 			'<filial_codigo_cliente>' + DUD->DUD_FILORI + '</filial_codigo_cliente>'

                            cTipo := RetRepomType(DUD->DUD_SERTMS, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE)

							cXML +=				'<tipo>' + cTipo + '</tipo>'
							cXML +=				'<data>' + DtoC(DT6->DT6_DATEMI) + '</data>'
							cXML +=				'<ocorrencia_data/>'
							cXML +=				'<ocorrencia_codigo/>'
							cXML += 		'</documento>'
						EndIf
						DUD->(DbSkip())
						nCount++
					EndDo
				EndIf
				cXML +=		'</documentos>'
				cXML += '</processo_transporte>'
			EndIf

		Else //-- Estorno do Encerramento
			If !lFrotaProp
				//-- XML para estorno da Quitação
				cXML += '<estorna_quitacao>'
				cXML += 	'<processo_transporte_codigo>' + AllTrim(DTR->DTR_PRCTRA) + '</processo_transporte_codigo>'
				cXML += 	'<processo_cliente_codigo>' + cFilOri + cViagem + '</processo_cliente_codigo>'
				cXML +=		'<processo_cliente_filial_codigo_cliente/>'
				cXML +=		'<estorno_tipo>1</estorno_tipo>' //-- 0 - O contrato retornará ao status "Em Transito";      1 - O contrato retornará ao status "Pendente"
				cXML += '</estorna_quitacao>'
			Else
				//-- XML para estorno da Baixa de Controle de Viagem
				cXML += '<processo_transporte>'
				cXML += 	'<processo_transporte_codigo>' + AllTrim(DTR->DTR_PRCTRA) + '</processo_transporte_codigo>'
				cXML += 	'<processo_cliente_codigo>' + cFilOri + cViagem + '</processo_cliente_codigo>'
				cXML +=		'<processo_cliente_filial_codigo_cliente/>'
				cXML += '</processo_transporte>'
			EndIf
		EndIf

		If lTM340XML
			cXmlNew := Execblock("TM340XML",.F.,.F.,{cXML})
			If ValType( cXmlNew ) == 'C'
				cXML := cXmlNew
			EndIf
		EndIf

		//-- Remove os Acentos e Caracteres especiais
		cXML := TMSNoAcento( cXML )

		//-- Gera XML em disco
		If lTMSXML
			If nOpcx == 3
				If !lFrotaProp
					TMSLogXML( cXML, 'AutorizaQuitacao.XML' )
				Else
					TMSLogXML( cXML, 'BaixaControleViagem.XML' )
				EndIf
			Else
            	If !lFrotaProp
            		TMSLogXML( cXML, 'EstornoQuitacao.XML' )
            	Else
            		TMSLogXML( cXML, 'EstornoBaixaControleViagem.XML' )
            	EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ACIONA O WEBSERVICE PARA CANCELAR O CONTROLE DE VIAGEM³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TmsRepTrac("AutorizaQuitacao - Instanciando :"+AllToChar(nOpcx)+"/"+AllToChar(lFrotaProp))
		oObj := WSIntegracao():New()
		TmsRepTrac("AutorizaQuitacao - Instanciado")
		oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
		oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
		oObj:cStrXMLIn             := cXML
		oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora

		If nOpcx == 3
			If !lFrotaProp
				If oObj:AutorizaQuitacao()
					TmsRepTrac("AutorizaQuitacao - Consumido :"+AllToChar(oObj:lAutorizaQuitacaoResult))
					If oObj:lAutorizaQuitacaoResult
						//Parte 1
						lAutQuitOk:= .T.
						lRet:= .T.				
	        		Else
						aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
						lRet := .F.
					EndIf
				Else
					aMsgErr := TMSErrOper(cCodOpe,, '2')
					lRet := .F.
				EndIf
			Else  //Frota Propria
				If oObj:BaixaControleViagem()
					TmsRepTrac("BaixaControleViagem - Consumido :"+AllToChar(oObj:lBaixaControleViagemResult))
					If oObj:lBaixaControleViagemResult
						//-- Atualiza Log de Transacoes
						TMSGerLog( cCodOpe, 'BX', 'E', DTQ->(DTQ_FILIAL+DTQ_VIAGEM), 'DTQ', '0' )
						
						//-- Gera Pedido de Compra referente a Prestacao de servicos da Operadora
						If lGerPdgPc
							TmsGerPed(cCodOpe,cFilOri,cViagem,lFrotaProp)	
						EndIf
						lRet := .T.
	        		Else
						aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
						lRet := .F.
					EndIf
				Else
					aMsgErr := TMSErrOper(cCodOpe,, '2')
					lRet := .F.
				EndIf
			EndIf

		Else
			If lFrotaProp
				If oObj:EstornoBaixaControleViagem()
					TmsRepTrac("EstornoBaixaControleViagem - Consumido "+AllToChar(oObj:lEstornoBaixaControleViagemResult))
					If oObj:lEstornoBaixaControleViagemResult
						//-- Atualiza Log de Transacoes
						TMSGerLog( cCodOpe, 'BX', 'E', DTQ->(DTQ_FILIAL+DTQ_VIAGEM), 'DTQ', '1' )

						//-- Exclui o Pedido de compra
						If lGerPdgPc
							TmsExcPed(cCodOpe,cFilOri,cViagem,lFrotaProp)
						EndIf
						lRet := .T.
					Else
						aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
						lRet := .F.
					EndIf
				Else
					aMsgErr := TMSErrOper(cCodOpe,, '2')
					lRet := .F.
				EndIf
			Else
				//-- Estorna a Quitacao
				If oObj:EstornoQuitacao()
					TmsRepTrac("EstornoQuitacao - Consumido "+AllToChar(oObj:lEstornoQuitacaoResult))
					If oObj:lEstornoQuitacaoResult
						//-- Parte 2
						lEstQuitOK:= .T.					
						lRet := .T.
					Else
						aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
						lRet := .F.
					EndIf
				Else
					aMsgErr := TMSErrOper(cCodOpe,, '2')
					lRet := .F.
				EndIf
			EndIf
		EndIf
	
	ElseIf cCodOpe == '01' .And. lRestRepom //-- REPOM Tecnologia	
		If !lFrotaProp	
			If nOpcx == 3	//Encerramento da Viagem		
				lAutQuitOk:= .T.  //Não existe API para autorização de Quitação
				lRet:= .T.
			Else //Estorno do Encerramento
				lRet:= TMSC15ARep( 9 , cFilOri , cViagem, .F.  )  //PaymentCancel
				If lRet
					lEstQuitOK:= .T.
					
					DTY->(DbSetOrder(2)) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
					If DTY->(MsSeek( cSeek := xFilial("DTY") + cFilOri + cViagem ))
						While DTY->(!Eof() ) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM) == cSeek							
							RecLock('DTY',.F.)
							DTY->DTY_LOCQUI := ""
							MsUnLock()							
							DTY->(DbSkip())
						EndDo
					EndIf 
				EndIF
			EndIf
		EndIf
	EndIf

	//----- Atualiza Dados todas as versoes Repom (2.2 e Anteriores)
	If lRet
		If nOpcx == 3 
			If lAutQuitOk   //Autorizado Quitacação
				//-- Parte 1
				//-- Atualiza Log de Transacoes
				TMSGerLog( cCodOpe, 'AT', 'E', DTQ->(DTQ_FILIAL+DTQ_VIAGEM), 'DTQ', '0' )	
				lRet:= TmProcQuit(cCodOpe,cFilOri,cViagem,@aMsgErr,nValFre,lGerPdgPc,lFrotaProp)
			EndIf
		Else
			If lEstQuitOK //Estorno da Quitação 
				//-- Parte 2
				//-- Atualiza Log de Transacoes
				TMSGerLog( cCodOpe, 'QT', 'E', xFilial('DES') + cFilOri + cViagem, 'DES', '1' )
				TmsRepTrac("EstornoQuitacao - GerLog")
				//-- Exclui o Pedido de compra
				If lGerPdgPc
					TmsRepTrac("EstornoQuitacao - lGerPdgPc ")
					TmsExcPed(cCodOpe,cFilOri,cViagem,lFrotaProp)							
				EndIf

				//-- Elimina as informacoes processadas pela quitacao do contrato na Operadora
				TmsEstDES(cFilOri,cViagem) 	
			EndIf
		EndIf
	EndIf

EndIf

TmsRepTrac("Quitacao - FINAL "+AllToChar(lRet) + "/" + VarInfo("aMsgErr",aMsgErr))

//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 10 )

RestArea(aArea)
RestArea(aAreaDTR)
RestArea(aAreaDT6)
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RepAutPgto³ Autor ³ Guilherme Gaiofatto   ³ Data ³ 16.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a Autorizacao do pagamento na a Operadora de Frota  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1 - Codigo da Operadora de Frotas                      ³±±
±±³          ³cExpC2 - Filial de Origem                                   ³±±
±±³          ³cExpC3 - Numero da Viagem                                   ³±±
±±³          ³aExpA1 - Array com as Mensagens de Erro (Por Referencia)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico - .T. indica sucesso no processamento do metodo      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RepAutPgto( cCodOpe, cFilOri, cViagem, aMsgErr, aDadosQuit, cContrat, cCodVei, lQuitacao, cCond, cCodFor, cLojFor )
Local lRet     := .F.
Local cXML     := ''
Local cXmlNew  := ''
Local oObj     := NIL
Local cError   := ''
Local cWarning := ''
Local aArea    := GetArea()
Local aAreaDTR := DTR->(GetArea())
Local aAreaDTY := {}
Local lTMSXML  := GetMV( 'MV_TMSXML',, .F. )
Local oXML     := NIL
Local cValFret := ''
Local cLocQui  := ''
Local cBanco   := ''
Local cAgencia := ''
Local cNumCon  := ''
Local cDesSald  := SuperGetMV( 'MV_DESSALD',, '')
Local nDias	   := 0
Local aData	   := {}
Local nSalPag  := 0

TmsRepTrac("Inicio de Função")

//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 255 )

Default lQuitacao := .T.
Default cCond    := ''
Default cCodFor  := ''
Default cLojFor  := ''
Default cCodVei  := ''

// tento localizar na DTY se nao passar os dados via parametro
IF Empty( cCond )
	IF ( Empty( cCodFor ) .And. Empty( cLojFor ) )
		aAreaDTY := DTY->( getArea() )
		If DTY->(FieldPos("DTY_LOCQUI")) > 0
			TmsRepTrac("Autoriz DTY_LOCQUI ")
			DTY->(DbSetOrder(2))
			If DTY->(DbSeek(xFilial('DTY') + cFilOri + cViagem))
				TmsRepTrac("Autoriz seek OK DTY: "+xFilial('DTY') + cFilOri + cViagem)
				cPeso    := DTY->DTY_PESO
				cValFret := DTY->DTY_VALFRE
				cCodFor  := DTY->DTY_CODFOR
				cLojFor  := DTY->DTY_LOJFOR
				cLocQui  := DTY->DTY_LOCQUI
				If  Empty(cCodVei)
   		   			cCodVei := DTY->DTY_CODVEI
   	  			Endif
			Else
				TmsRepTrac("Autoriz seek NOK DTY: "+xFilial('DTY') + cFilOri + cViagem)
			EndIf
		EndIf
		RestArea( aAreaDTY )
	Endif

	// Localiza a a condicao de pagto do Fornecedor
	If !Empty(cCodFor) .And.!Empty(cLojFor)
		SA2->(DbSetOrder(1))
		If SA2->(MsSeek(xFilial('SA2')+cCodFor+cLojFor))
			TmsRepTrac("Autoriz seek OK SA2: "+xFilial('SA2')+cCodFor+cLojFor)
			cCond	:= SA2->A2_COND
		EndIf
	EndIf
EndIf

If !Empty(cCodFor) .And.!Empty(cLojFor)
	SA2->(DbSetOrder(1))
	If SA2->(MsSeek(xFilial('SA2')+cCodFor+cLojFor))
		TmsRepTrac("Autoriz 2º seek OK SA2: "+xFilial('SA2')+cCodFor+cLojFor)
	     cCond	:= SA2->A2_COND
	EndIf
EndIf

DEG->(DbSetOrder(1))
If DEG->(MsSeek(xFilial('DEG')+cCodOpe))
	TmsRepTrac("Autoriz seek OK DEG")
	If cCodOpe == '01'  //-- REPOM Tecnologia
		cBanco    := DEG->DEG_BANCO
		cAgencia  := DEG->DEG_AGENCI
		cNumCon   := DEG->DEG_NUMCON

		If !lRestRepom
			aData := Condicao(1,cCond,0,dDatabase)   //-- Conseguir a data Prevista para o pagamento, nao é necessario passar o valor exato.
			nDias := Abs( Iif(Len(aData)>0,aData[1][1],dDatabase+1) - dDatabase )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³XML para processamento da Autorizacao de Pagamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cXML += '<autoriza_contratos>'
			cXML += 	'<autoriza_contrato>'
			cXML += 		'<dias>' + StrZero( nDias , 4) + '</dias>'
			cXML += 		'<usuario/>'
			cXML += 		'<contrato_codigo>' + AllTrim(Posicione('DTR',1,xFilial('DTR') + cFilOri + cViagem, 'DTR_PRCTRA')) + '</contrato_codigo>'
			cXML += 		'<processo_transporte_codigo_cliente>' + cFilOri + cViagem + '</processo_transporte_codigo_cliente>'
			cXML += 		'<processo_cliente_filial_codigo_cliente>' + cFilOri + '</processo_cliente_filial_codigo_cliente>'
			cXML += 	'</autoriza_contrato>'
			cXML += '</autoriza_contratos>'

			//-- Gera XML em Disco
			If lTMSXML
				TMSLogXML( cXML, 'AutorizaPagamento.XML' )
			EndIf
			TmsRepTrac("Autoriz Gravou XML")

			If lTM251XML
				cXmlNew := Execblock("TM251XML",.F.,.F.,{cXML})
				If ValType( cXmlNew ) == 'C'
					cXML := cXmlNew
				EndIf
			EndIf

			//-- Remove acentos e caracteres especiais
			cXML := TMSNoAcento( cXML )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ACIONA O WEBSERVICE ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TmsRepTrac("AutorizaPagamento - Instanciando")
			oObj := WSIntegracao():New()
			TmsRepTrac("AutorizaPagamento - Instanciado")
			oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
			oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
			oObj:cStrXMLIn             := cXML
			oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REALIZACAO DA AUTORIZACAO DE PAGAMENTO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oObj:AutorizaPagamento()
				TmsRepTrac("AutorizaPagamento - Consumido :"+AllToChar(oObj:lAutorizaPagamentoResult))
				If oObj:lAutorizaPagamentoResult
					TmsRepTrac("AutorizaPagamento - XMLOUT Empty :"+AllToChar(Empty( oObj:cStrXMLOut )))
					If !Empty( oObj:cStrXMLOut )
						//-- Remove os acentos do XML de Retorno
						oObj:cStrXMLOut := TMSNoAcento( oObj:cStrXMLOut )
						//-- Gera XML em Disco
						If lTMSXML
							TMSLogXML( oObj:cStrXMLOut, 'AutorizaPagamentoResult.XML' )
						EndIf
						TmsRepTrac("AutorizaPagamento - Gravou XML Result")
						//-- Coverte em Objeto o XML de retorno enviado pela Operadora
						oXML := XMLParser( oObj:cStrXMLOut, '_', @cError, @cWarning )
						TmsRepTrac("AutorizaPagamento - Parseou XML Result")

						//-- Se houverem 7 tags de retorno no XMLOUT da Repom, significa que houveram ocorrencias
						//-- que impediram a autorizacao do pagamento do contrato
						If XMLChildCount( oXML:_Autoriza_Contratos:_Autoriza_Contrato ) == 7
							TmsRepTrac("AutorizaPagamento - childcount == 7")
							lRet := .F.
							AAdd( aMsgErr, { oXML:_Autoriza_Contratos:_Autoriza_Contrato:_Ocorrencia_Codigo:Text + ' -  ' + oXML:_Autoriza_Contratos:_Autoriza_Contrato:_Ocorrencia_Descricao:Text} )
						Else
							TmsRepTrac("AutorizaPagamento - childcount <> 7")
							lRet := .T.

							//Grava Saldo do Pagamento.
							nSalPag := StrTran( oXML:_Autoriza_Contratos:_Autoriza_Contrato:_Valor_Final:Text, ',', '')
							nSalPag := Val( nSalPag )

							//Atualiza Saldo DES
							TMSAtuDES(cFilOri,cViagem,nSalPag)  
																	
							// baixa SDG do saldo
							// Verifica se será gravado a despesa da SDG
							If !Empty(cDesSald) .And. nSalPag > 0
								TMSAtuSDG(cFilOri, cViagem, cCodVei, cDesSald, nSalPag, cBanco, cAgencia, cNumCon)
							EndIf

						EndIf
					Else
						lRet := .T.
					EndIf
				Else
					aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
					lRet := .F.
				EndIf
			Else
				aMsgErr := TMSErrOper(cCodOpe,, '2')
				lRet := .F.
			EndIf
		
		Else  //!lRestRepom
			
			lRet:= TMSC15ARep( 11 , cFilOri , cViagem, .F., cCodVei  )  //AuthorizationCreate

		EndIf
	EndIf
	
	If !lRestRepom .And. lRet .And. lTM251Ope 
		ExecBlock('TM251Ope',.F.,.F.,{cCodOpe, cFilOri, cViagem, cContrat, cCodVei, oXML, lQuitacao})
	EndIf	

EndIf
//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 10 )
							
TmsRepTrac("AutorizaPagto - FINAL "+AllToChar(lRet) + "/" + VarInfo("aMsgErr",aMsgErr))

RestArea(aArea)
RestArea(aAreaDTR)
Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RepMovVal ³ Autor ³ Vitor Raspa           ³ Data ³ 15.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata a Movimentacao de Valores retornada pela Operadora   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RepMovVal()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Operadora                                ³±±
±±³          ³ ExpC2 = Filial de Origem                                   ³±±
±±³          ³ ExpC3 = Numero da Viagem                                   ³±±
±±³          ³ ExpA4 = Array com os Movimentos                            ³±±
±±³          ³      [01] - Processo de Transporte                         ³±±
±±³          ³      [02] - Numero do Proc. Transp. (Operadora)            ³±±
±±³          ³      [03] - Codigo do Movimento                            ³±±
±±³          ³      [04] - Valor do Movimento                             ³±±
±±³          ³      [05] - Tipo do Movimento (Debito/Credito/Pedagio)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RepMovVal( cCodOpe, cFilOri, cViagem, aMovtos, nOpcx, cCodVei )
local aAreaDTQ := DTQ->(GetArea())
Local aAreaDTY := DTY->(GetArea())
Local aArea    := GetArea()
Local lRet     := .F.
Local nAux     := 0
Local cCodMov  := ''
Local cOcorCod := ''
Local aOcorCb  := {}
Local aOcorIt  := {}
Local cDespCod := ''

Local cArqErro := ''
Local cErro    := ''
Local lMovExec := .F.
Local cIdreg   := ''

Private lWserver := .T. //-- apenas para 250proc

TmsRepTrac("Inicio de Função")

If cCodOpe == '01' //-- REPOM Tecnologia
	If nOpcx <> 5
		//--Posiciona na Viagem para obter o Servico/Tipo de Transporte
		DTQ->(DbSetOrder(2))
		If DTQ->(MsSeek(xFilial('DTQ')+cFilOri + cViagem))
			For nAux := 1 To Len(aMovtos)

				cCodMov := PadR(aMovtos[nAux][03],Len(DEM->DEM_CODMOV),'')
				lProcMov := .F.

				DEM->(DbSetOrder(2)) //--DEM_FILIAL+DEM_CODOPE+DEM_CODMOV+DEM_SERTMS+DEM_TIPTRA
				If DEM->(MsSeek(xFilial('DEM')+cCodOpe+cCodMov+DTQ->DTQ_SERTMS+DTQ->DTQ_TIPTRA))

					While DEM->(DEM_FILIAL+DEM_CODOPE+DEM_CODMOV+DEM_SERTMS+DEM_TIPTRA) == xFilial('DEM')+cCodOpe+cCodMov+DTQ->DTQ_SERTMS+DTQ->DTQ_TIPTRA
						If DEM->DEM_TIPMOV == 'R'

							lProcMov := .T.

							If DEM->DEM_ACAO == '01'
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ACAO: GERACAO DE REG. DE OCORRENCIA³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cOcorCod := &(DEM->DEM_FORMUL)
								If ValType(cOcorCod) <> 'C'
									Help('',1,'TMSXFUNC11',,DEM->DEM_CODMOV + '-' + DEM->DEM_DESMOV,4,11) //-- 'O conteudo da Formula do Movimento e Invalido! Movimento: ### - #####'
			    	                cErro    := STR0031 //-- 'O conteudo da formula do Movimento e Invalido! Verifique o cadastro de Operadoras X Acoes'
			    	                lMovExec := .F.
								Else
									//-- Cabecalho da Ocorrencia
									Aadd(aOcorCb,{"DUA_FILORI"	, cFilOri	, NIL})
									Aadd(aOcorCb,{"DUA_VIAGEM"	, cViagem	, NIL})
									//-- Itens da Ocorrencia
									aAdd(aOcorIt,{	{"DUA_SEQOCO", StrZero(1,Len(DUA->DUA_SEQOCO)) , NIL},;
													{"DUA_DATOCO", dDataBase                        , NIL},;
													{"DUA_HOROCO", PadL(StrTran(Left(Time(),5),':',''),4,'0') , NIL},;
													{"DUA_CODOCO", cOcorCod                         , NIL}})
										//-- Inclusao da Ocorrencia
									lMsErroAuto := .F.
									MsExecAuto({|x,y,z|Tmsa360(x,y,z)},aOcorCb,aOcorIt,{},3)
									If lMsErroAuto
										lMovExec := .F.
										cArqErro  := NomeAutoLog()
										cErro     := Memoread( cArqErro )
										MostraErro()
									Else
										//--Guarda os dados do Registro incluido
										cIdReg := DUA->(DUA_FILIAL+DUA_FILOCO+DUA_NUMOCO+DUA_FILORI+DUA_VIAGEM+DUA_SEQOCO)
										lMovExec := .T.
									EndIf
							    EndIf


							ElseIf DEM->DEM_ACAO == '02'
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ACAO: GERACAO DE MOVTO. DE CUSTO DE TRANSPORTE³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cDespCod := &(DEM->DEM_FORMUL)
								If ValType(cDespCod) <> 'C'
									Help('',1,'TMSXFUNC14') //--'O conteudo da formula do Movimento e Invalido! Verifique o cadastro de Operadoras X Acoes"
									cErro    := STR0031 //-- 'O conteudo da formula do Movimento e Invalido! Verifique o cadastro de Operadoras X Acoes"
									lMovExec := .F.
								Else
									DT7->(DbSetOrder(1))
									If !DT7->(MsSeek(xFilial('DT2')+cDespCod))
										Help('',1,'TMSXFUNC12',,cDespCod,4,11) //-- 'Despesa nao Cadastrada'
										cErro    := STR0032 //-- 'Depesa nao cadastrada. Verifique o cadastro de Operadoras X Acoes'
										lMovExec := .F.
				    	            Else
										If DT7->DT7_CONEST == '1' .Or. DT7->DT7_MOVBCO == '1'
											Help('',1,'TMSXFUNC13')
											cErro    := STR0033 //-- 'A Despesa vinculada ao Movimento movimenta Banco ou existe controle de Estoque'
											cErro    += Chr(13) + Chr(10)
											cErro    += STR0034 //-- 'Vincule o Movimento à uma Despesa que nao movimente Banco e nao realize o controle de Estoque'
											lMovExec := .F.
										Else
											DbSelectArea('SDG') //-- NAO RETIRAR
											TMA250GrvSDG('SDG', cFilOri, cViagem, cDespCod, Val(aMovtos[nAux][4]),,cCodVei,,,,,,,,.T.,,,,,,,"TMSREPOM","2")
											cIdReg := SDG->(DG_FILIAL+DG_DOC+DG_CODDES+DG_ITEM)
											lMovExec := .T.
										EndIF
									EndIF
								EndIf

							ElseIf DEM->DEM_ACAO == '03'
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ACAO: GERACAO DE CONTRATO DE CARRET. COMPLEMENTAR³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								DTY->(DbSetOrder(2)) //DTY_FILIAL+DTY_FILORI+DTY_VIAGEM
								If DTY->(MsSeek(xFilial('DTY')+cFilOri+cViagem))
									TMSA250Com('DTY', DTY->(RecNo()),5,,Val(aMovtos[nAux][4]))
									cIdReg := DTY->(DTY_FILIAL+DTY_NUMCTC)
									lMovExec := .T.
								Else
									cErro := 'Contrato nao encontrato para a viagem em questao'
									lMovExec := .F.
								EndIf
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³GRAVA O MOVIMENTO NA TABELA DE MOVIMENTOS³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       					RecLock('DEN',.T.)
							DEN->DEN_FILIAL := xFilial('DEN')
							DEN->DEN_IDREG  := cIdReg
							DEN->DEN_CODOPE := cCodOpe
							DEN->DEN_FILORI := cFilOri
							DEN->DEN_VIAGEM := cViagem
							DEN->DEN_DTMOV  := dDataBase
							DEN->DEN_HRMOV  := PadL(StrTran(Left(Time(),5),':',''),4,'0')
							DEN->DEN_CODMOV := aMovtos[nAux][3]
							DEN->DEN_VALOR  := Val(aMovtos[nAux][4])
							DEN->DEN_TIPMOV := aMovtos[nAux][5]
							DEN->DEN_STATUS := IF(lMovExec, '1', '0')
							DEN->DEN_RECENV := 'R'
							DEN->DEN_ACAO   := DEM->DEM_ACAO
		    				MsUnLock()
							//-- Grava campo de Observacoes...
							MSMM(DEN->DEN_CODOBS,,,cErro,1,,,"DEN","DEN_CODOBS")

							//-- Atualiza o Log de Transacoes
							TMSGerLog( cCodOpe, 'MV', 'R', xFilial('DEN')+cFilOri+cViagem+DtoS(dDataBase)+PadL(StrTran(Left(Time(),5),':',''),4,'0'), 'DEN', '0' )
						EndIf
						DEM->(DbSkip())
					EndDo

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³GRAVA O MOVIMENTO NA TABELA DE MOVIMENTOS³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lProcMov
						RecLock('DEN',.T.)
						DEN->DEN_FILIAL := xFilial('DEN')
						DEN->DEN_IDREG  := cIdReg
						DEN->DEN_CODOPE := cCodOpe
						DEN->DEN_FILORI := cFilOri
						DEN->DEN_VIAGEM := cViagem
						DEN->DEN_DTMOV  := dDataBase
						DEN->DEN_HRMOV  := PadL(StrTran(Left(Time(),5),':',''),4,'0')
						DEN->DEN_CODMOV := aMovtos[nAux][3]
						DEN->DEN_VALOR  := Val(aMovtos[nAux][4])
						DEN->DEN_TIPMOV := aMovtos[nAux][5]
						DEN->DEN_STATUS := '0'
						DEN->DEN_RECENV := 'R'
		   				MsUnLock()
						//-- Grava campo de Observacoes...
						cErro := STR0035 //-- 'Nao foram encontradas Acoes para o Movimento. Nenhuma Acao foi executada.'
						MSMM(DEN->DEN_CODOBS,,,cErro,1,,,"DEN","DEN_CODOBS")

						//-- Atualiza Log de Transacoes
						TMSGerLog( cCodOpe, 'MV', 'R', xFilial('DEN')+cFilOri+cViagem+DtoS(dDataBase)+PadL(StrTran(Left(Time(),5),':',''),4,'0'), 'DEN', '0' )

					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³GRAVA O MOVIMENTO NA TABELA DE MOVIMENTOS³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock('DEN',.T.)
					DEN->DEN_FILIAL := xFilial('DEN')
					DEN->DEN_IDREG  := cIdReg
					DEN->DEN_CODOPE := cCodOpe
					DEN->DEN_FILORI := cFilOri
					DEN->DEN_VIAGEM := cViagem
					DEN->DEN_DTMOV  := dDataBase
					DEN->DEN_HRMOV  := PadL(StrTran(Left(Time(),5),':',''),4,'0')
					DEN->DEN_CODMOV := aMovtos[nAux][3]
					DEN->DEN_VALOR  := Val(aMovtos[nAux][4])
					DEN->DEN_TIPMOV := aMovtos[nAux][5]
					DEN->DEN_STATUS := '0'
					DEN->DEN_RECENV := 'R'
		   			MsUnLock()
					//-- Grava campo de Observacoes...
					cErro := STR0035 //-- 'Nao foram encontradas Acoes para o Movimento. Nenhuma Acao foi executada.'
					MSMM(DEN->DEN_CODOBS,,,cErro,1,,,"DEN","DEN_CODOBS")

					//-- Atualiza Log de Transacoes
					TMSGerLog( cCodOpe, 'MV', 'R', xFilial('DEN')+cFilOri+cViagem+DtoS(dDataBase)+PadL(StrTran(Left(Time(),5),':',''),4,'0'), 'DEN', '0' )

	            EndIf
	        Next
	    EndIf
	Else
		DEN->(DbSetOrder(1))
		If DEN->(MsSeek(xFilial('DEN')+cFilOri+cViagem))
			While DEN->(DEN_FILIAL+DEN_FILORI+DEN_VIAGEM) == xFilial('DEN')+cFilOri+cViagem
				If DEN->DEN_STATUS == '1' //-- A ACAO FOI EXECUTADA!
					//--Localiza a Acao...
					If DEN->DEN_ACAO == '01' //-- Reg. de Ocorrencia
						DUA->(DbSetOrder(1))
						DUA->(MsSeek(DEN->DEN_IDREG))

						//-- Cabecalho da Ocorrencia
						Aadd(aOcorCb,{"DUA_FILOCO",DUA->DUA_FILOCO,NIL})
						Aadd(aOcorCb,{"DUA_NUMOCO",DUA->DUA_NUMOCO,NIL})
						Aadd(aOcorCb,{"DUA_FILORI",DUA->DUA_FILORI,NIL})
						Aadd(aOcorCb,{"DUA_VIAGEM",DUA->DUA_VIAGEM,NIL})
						//-- Itens da Ocorrencia
						aAdd(aOcorIt,{	{"DUA_SEQOCO", DUA->DUA_SEQOCO , NIL},;
										{"DUA_ESTOCO", StrZero( 1, Len(DUA->DUA_ESTOCO)), NIL},;
										{"DUA_DATOCO", DUA->DUA_DATOCO , NIL},;
										{"DUA_HOROCO", DUA->DUA_HOROCO , NIL},;
										{"DUA_CODOCO", DUA->DUA_CODOCO , NIL},;
										{"DUA_SERTMS", DUA->DUA_SERTMS , NIL},;
										{"DUA_FILDOC", DUA->DUA_FILDOC , NIL},;
										{"DUA_DOC"   , DUA->DUA_DOC    , NIL},;
										{"DUA_SERIE" , DUA->DUA_SERIE  , NIL},;
										{"DUA_QTDOCO", DUA->DUA_QTDOCO , NIL},;
										{"DUA_PESOCO", DUA->DUA_PESOCO , NIL}})
						//-- Estorno da Ocorrencia
						lMsErroAuto := .F.
						MsExecAuto({|w,x,y,z|Tmsa360(w,x,y,z)},aOcorCb,aOcorIt,{},6)
						If lMsErroAuto
							MostraErro()
						EndIf

    			    ElseIf DEN->DEN_ACAO == '02' //-- Movto. de Custo de Transporte
	    		    	SDG->(DbSetOrder(1))
    			    	If SDG->(MsSeek(DEN->DEN_IDREG))
							AtuTabSDG(,5)
						EndIf

    			    ElseIf DEN->DEN_ACAO == '03' //-- Contrato de Carreteiro Complementar
						DTY->(DbSetOrder(1))
						If DTY->(MsSeek(DEN->DEN_IDREG))
							TMSA250Mnt('DTY',DTY->(RecNo()),5,,.F.)
						EndIf

		   	    	EndIf
				EndIF


				//-- Atualiza Log de Transacoes
				TMSGerLog( cCodOpe, 'MV', 'R', DEN->(DEN_FILIAL+DEN_FILORI+DEN_VIAGEM+DtoS(DEN_DTMOV)+DEN_HRMOV), 'DEN', '1' )

				RecLock('DEN',.F.)
				DEN->(DbDelete())
				MsUnLock()

				DEN->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf

lWserver := Nil
RestArea(aAreaDTQ)
RestArea(aAreaDTY)
RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} RepConsRt
Chama o Método  ConsultaRoteiro da Repom
@author	Daniel Leme
@version	1.0
@since		13/12/2016
@sample    Solicita Roteiro à Repom (Apenas envia a solicitação, não há retorno)
		   A inclusão do roteiro na Repom é manual, com SLA de 15min a partir da recepção deste método
/*/
//-------------------------------------------------------------------
Function RepConsRt(cCodOpe, cCdrOri, aRotPerc01, lFalha, lF3, nTmsItem)
Local oObj
Local cError	:= ""
Local cWarning	:= ""
Local oXML
Local cMunic	:= ""
Local nAux
Local lTMSXML	:= GetMV( 'MV_TMSXML',, .F. )
Local cFroVei	:= ''

Default lFalha := .F.
Default lF3    := .F.

TmsRepTrac("Inicio de Função")

// POSICIONA NO CADASTRO DA OPERADORA
DEG->( DbSetOrder(1) )
DEG->( MsSeek(xFilial('DEG') + cCodOpe) )

// VERIFICANDO O ESTADO DE ORIGEM
DUY->( DbSetOrder(1) )
DUY->( MsSeek(xFilial('DUY') + cCdrOri) )

// VERIFICANDO A CIDADE DE ORIGEM
DEI->( DbSetOrder(2) )
If DEI->( MsSeek(xFilial('DEI') + DEG->DEG_CODOPE + cCdrOri) )
	cMunic := DEI->DEI_MUN
Else
	cMunic := DUY->DUY_DESCRI
EndIf

If lRestRepom
	If lF3
		RepGetRot(M->DA8_COD,cCdrOri,@aRotPerc01)
	Else
		RepGetId(M->DA8_COD,@aRotPerc01)
	EndIf
Else
	// PREPARACAO PARA CONECTAR AO WS - REPOM
	oObj := WSIntegracao():New()
	oObj:cStrCliente           := DEG->DEG_IDOPE
	oObj:cStrAssinaturaDigital := DEG->DEG_CODACE
	oObj:cStrEstadoOrigem      := DUY->DUY_EST
	oObj:cStrCidadeOrigem      := cMunic
	oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora

	aRotPerc01 := {}

	If oObj:ConsultaRoteiros()
		If oObj:lConsultaRoteirosResult

			//-- Remove os Acentos e caracteres especiais
			oObj:cStrXMLOut := TMSNoAcento( oObj:cStrXMLOut )

			//-- Gera o XML de Retorno em Disco
			If lTMSXML
				TMSLogXML( oObj:cStrXMLOut, 'ConsultaRoteirosResult.XML' )
			EndIf

			oXML := XmlParser( oObj:cStrXMLOut, "_", @cError, @cWarning )
			If !Empty(cError) .Or. !Empty(cWarning)
				Aviso(STR0001, If(!Empty(cError), cError, cWarning) , {STR0003} ) //"AVISO"###"OK"
			Else
				If XMLChildCount(oXML:_ROTEIROS) > 0
					If ValType(oXML:_ROTEIROS:_ROTEIRO) == 'A' .Or. ValType(oXML:_ROTEIROS:_ROTEIRO) == 'O'
						If ValType(oXML:_ROTEIROS:_ROTEIRO) == 'A'
							For nAux := 1 To Len(oXML:_ROTEIROS:_ROTEIRO)
								If AllTrim(oXML:_ROTEIROS:_ROTEIRO[nAux]:_PROCESSO_TRANSPORTE_TIPO:Text) == '0'
									cFroVei := STR0014 //-- "Terceiro/Agregado"
								ElseIf AllTrim(oXML:_ROTEIROS:_ROTEIRO[nAux]:_PROCESSO_TRANSPORTE_TIPO:Text) == '1'
									cFroVei := STR0015 //-- "Propria"
								Else
									cFroVei := STR0016 //-- "Ambos"
								EndIf
								AAdd( aRotPerc01, {	oXML:_ROTEIROS:_ROTEIRO[nAux]:_ROTEIRO_CODIGO:Text,;
													oXML:_ROTEIROS:_ROTEIRO[nAux]:_PERCURSO_CODIGO:Text,;
													oXML:_ROTEIROS:_ROTEIRO[nAux]:_PERCURSO_DESCRICAO:Text,;
													oXML:_ROTEIROS:_ROTEIRO[nAux]:_CIDADE_ORIGEM:Text,;
													oXML:_ROTEIROS:_ROTEIRO[nAux]:_ESTADO_ORIGEM:Text,;
													oXML:_ROTEIROS:_ROTEIRO[nAux]:_CIDADE_DESTINO:Text,;
													oXML:_ROTEIROS:_ROTEIRO[nAux]:_ESTADO_DESTINO:Text,;
													cFroVei } )
							Next
							ASort( aRotPerc01, , , { |x, y| Val(x[1]) < Val(y[1]) } )
						Else
							If AllTrim(oXML:_ROTEIROS:_ROTEIRO:_PROCESSO_TRANSPORTE_TIPO:Text) == '0'
								cFroVei := STR0014 //-- "Terceiro/Agregado"
							ElseIf AllTrim(oXML:_ROTEIROS:_ROTEIRO:_PROCESSO_TRANSPORTE_TIPO:Text) == '1'
								cFroVei := STR0015 //-- "Propria"
							Else
								cFroVei := STR0016 //-- "Ambos"
							EndIf
							AAdd( aRotPerc01, {	oXML:_ROTEIROS:_ROTEIRO:_ROTEIRO_CODIGO:Text,;
												oXML:_ROTEIROS:_ROTEIRO:_PERCURSO_CODIGO:Text,;
												oXML:_ROTEIROS:_ROTEIRO:_PERCURSO_DESCRICAO:Text,;
												oXML:_ROTEIROS:_ROTEIRO:_CIDADE_ORIGEM:Text,;
												oXML:_ROTEIROS:_ROTEIRO:_ESTADO_ORIGEM:Text,;
												oXML:_ROTEIROS:_ROTEIRO:_CIDADE_DESTINO:Text,;
												oXML:_ROTEIROS:_ROTEIRO:_ESTADO_DESTINO:Text,;
												cFroVei} )
						EndIf
					Else
						Aviso( STR0017, {"Ok"}) //-- "Atenção,  Roteiro não enviado pela operadora de frete pedágio. Verifique o arquivo XML."
					EndIf
				Else
					Help('',1,'OMSA10009',,cMunic,3,01) // 'Nao existem Roteiros para a Cidade de Origem Informada'
					AAdd( aRotPerc01, {'','','','','','',''} )
				EndIf
			EndIf
		Else
			aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
		EndIf
		lFalha := .F. //-- Nao houve falha no WS
	EndIf
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} 	RepInteRup
Chama o método  	Interrompe_Contrato
@author				Daniel Leme
@version			1.0
@since				04/07/2017
@sample    			Solicita a Interrupção do contrato junto a REPOM
/*/
//-------------------------------------------------------------------

Function RepInteRup(cFIlOri, cViagem, cCodOpe)

Local cError     := ""
Local cWarning   := ""
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )
Local lRet 		 := .T.
Local oXML		 := Nil
Local oObj		 := Nil
Local cXML		 := ''
Local nValRecupe := 0
Local aAreas   	 := {DTR->(GetArea()),DEG->(GetArea()),DEP->(GetArea()),DTW->(GetArea()),DES->(GetArea()),DTQ->(GetArea()),GetArea()}
Local aMsgErr	 := {}

Default cFilOri  := ''
Default cViagem  := ''
Default cCodOpe  := ''

TmsRepTrac("Inicio de Função")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³POSICIONA NO CADASTRO DA OPERADORA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEG->( DbSetOrder(1) )
DEG->( MsSeek(xFilial('DEG')+cCodOpe) )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta XML para Interrupção    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTR->(DbSetOrder(1))
If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
	cXML := ''
	cXML += '<interrompe_contrato>'
	cXML += 	'<processo_transporte_codigo>' 				+ AllTrim(DTR->DTR_PRCTRA) 				+ '</processo_transporte_codigo>'
	cXML += 	'<processo_cliente_codigo>'    				+ AllTrim(cFilOri) + AllTrim(cViagem) 	+ '</processo_cliente_codigo>'
	cXML += 	'<processo_cliente_filial_codigo_cliente>'  + AllTrim(cFilAnt) 						+ '</processo_cliente_filial_codigo_cliente>'
	cXML += 	'<motivo>'									+ '105'									+ '</motivo>
	cXML += 	'<observacao>'								+ 'Contrato Interrompido atraves da solicititacao SIGATMS'	+ '</observacao>
	cXML += '</interrompe_contrato>'
EndIf

//-- Remove Caracteres especiais no cXML
cXML := TMSNoAcento( cXML )

//-- Gera XML em Disco
If lTMSXML
	TMSLogXML( cXML, 'InterrompeContrato.XML' )
EndIf
TmsRepTrac("Gravou XML")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ACIONA O WEBSERVICE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TmsRepTrac("InterrompeContrato - Instanciando")
oObj := WSIntegracao():New()
TmsRepTrac("InterrompeContrato - Instanciado")
oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
oObj:cStrXMLIn             := cXML
oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora


//-- Interrupção do Contrato
If oObj:InterrompeContrato()
	TmsRepTrac("InterrompeContrato - Consumido " + AllToChar(oObj:lInterrompeContratoResult))
	If oObj:lInterrompeContratoResult

		//-- Remove os acentos do XML de Retorno
		oObj:cStrXMLOut := TMSNoAcento( oObj:cStrXMLOut )

		//-- Gera XML em Disco
		If lTMSXML
			TMSLogXML( oObj:cStrXMLOut, 'InterrompeContratoResult.XML' )
		EndIf

		TmsRepTrac("InterrompeContrato - Gravou XML Result " )

		//-- Coverte em Objeto o XML de retorno enviado pela Operadora
		oXML := XMLParser( oObj:cStrXMLOut, '_', @cError, @cWarning )
		TmsRepTrac("InterrompeContrato - Parseou XML Result " )

		//-- Grava os dados da quitacao
		nValRecupe := StrTran( oXML:_Interrompe_Contrato:_valor_recuperado:Text, ',', '' )

		TmsRepTrac("InterrompeContrato - nValRecupe  " + AllToChar(nValRecupe) )

		nValRecupe := Val( nValRecupe )

		//-- Exclui as passagens referentes ao contrato...
		DEP->(DbSetOrder(1)) //-- DEP_FILIAL+DEP_FILORI+DEP_VIAGEM+DEP_ORDEM
		If DEP->(MsSeek(xFilial('DEP') + cFilOri + cViagem))
			TmsRepTrac("InterrompeContrato - Seek OK DEP  " + xFilial('DEP') + cFilOri + cViagem )
			While DEP->(MsSeek(xFilial('DEP') + cFilOri + cViagem))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³EXCLUI A OPERACAO DE TRANSPORTE³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DTW->(DbSetOrder(1))
				If DTW->(MsSeek(xFilial('DTW') + cFilOri + cViagem + DEP->DEP_SEQDTW ))
					TmsRepTrac("InterrompeContrato - Seek OK DTW  " + xFilial('DTW') + cFilOri + cViagem + DEP->DEP_SEQDTW )
					RecLock('DTW',.F.)
					DTW->(DbDelete())
					MsUnLock()
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³EXCLUI A PASSAGEM³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TmsRepTrac("InterrompeContrato - Loop DEP  " + AllToChar(DEP->(Recno())) )
				RecLock('DEP',.F.)
				DEP->(DbDelete())
				MsUnLock()
			EndDo
		Else
			TmsRepTrac("InterrompeContrato - Seek NOK DEP  " + xFilial('DEP') + cFilOri + cViagem )
		EndIf
		//-- Exclui os dados referente a Quitacao
		DES->(DbSetOrder(1))
		If DES->(MsSeek(xFilial('DES') + cFilOri + cViagem))
			TmsRepTrac("InterrompeContrato - Seek OK DES  " + xFilial('DES') + cFilOri + cViagem )
			RecLock('DES',.F.)
			DES->(DbDelete())
			MsUnLock()
		Else
			TmsRepTrac("InterrompeContrato - Seek NOK DES  " + xFilial('DES') + cFilOri + cViagem )
		EndIf

		//--Grava o valor que a quitação do contrato conseguiu recuperar na tabela de viagens.
		DTQ->(dbSetOrder(1))
		If DTQ->(MsSeek(FwxFilial('DTQ')+cFilori+cViagem))
			TmsRepTrac("InterrompeContrato - Seek OK DTQ  " + FwxFilial('DTQ')+cFilori+cViagem )
			RecLock('DES',.F.)
			DTQ->DTQ_OBS := 'Contrato Interrompido na REPOM. Valor Recuperado: ' + AllTrim(Str(nValRecupe))
			MsUnLock()
		Else
			TmsRepTrac("InterrompeContrato - Seek NOK DTQ  " + FwxFilial('DTQ')+cFilori+cViagem )
		EndIf

	Else
		aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
		lRet := .F.
	EndIf

Else
	aMsgErr := TMSErrOper(cCodOpe,, '2')
	lRet := .F.

EndIf

AEval(aAreas,{|x,y| RestArea(x) })

TmsRepTrac("InterrompeContrato - FINAL  " + AllToChar(lRet) + "/" + VarInfo("aMsgErr",aMsgErr))

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} 	TmsRepTrac
Chama o método  	Grava Trace para obter log das Integrações na REPOM
@author				Daniel Leme
@version			1.0
@since				04/10/2017
@sample
/*/
//----------------------------------------------------------------------
Function TmsRepTrac(cLog,lForceLog,cPath)
Local nHandle   := 0

Default cLog 	  := ''
Default lForceLog := .F.
Default cPath	  := ''

If lForceLog .Or. lRepTrace
	If Empty(cPath) .And. !lForceLog
		If IsSrvUnix()
			cPath := CurDir() + "/" + 'TMSXML' + "/"+"LOG_REPOM"
		Else
			cPath := CurDir() + 'TMSXML' + "\" +"LOG_REPOM"
		EndIf
	ElseIf Empty(cPath) .And. lForceLog
		If IsSrvUnix()
			cPath := CurDir() + "/" + "LOG_TMS_"
		Else
			cPath := CurDir() + "LOG_TMS_"
		EndIf
	EndIf

	If !File(cPath+DtoS(dDataBase)+".LOG")
		nHandle := MsfCreate(cPath+DtoS(dDataBase)+".LOG",0)
	Else
		nHandle := FOpen(cPath+DtoS(dDataBase)+".LOG",2)
		If nHandle > 0
			fSeek(nHandle,0,2)
		EndIf
	EndIf
	If nHandle > 0
		FWrite(nHandle, DtoS(dDataBase)             + ";" + ;
						StrTran(Time(),":","")      + ";" + ;
						AllTrim(Str(ThreadId()))    + ";" + ;
						AllTrim(ProcName(1)) + "("+ AllTrim(AllToChar(ProcLine(1))) +")"       + ";" + ;
						AllTrim(AllToChar(cLog))    + ";" + ;
						AllTrim(ProcName(2))        + ";" + ;
						AllTrim(ProcName(3))        + ";" + ;
						AllTrim(cUsername)         + Chr(13)+Chr(10))
	    FClose(nHandle)
	Else
		TMSLogMsg("INFO", "**************** REPOM: ERRO GERANDO LOG *********************")
		TMSLogMsg("INFO", DtoS(dDataBase)             + ";" + ;
					      StrTran(Time(),":","")      + ";" + ;
						  AllTrim(Str(ThreadId()))    + ";" + ;
						  AllTrim(ProcName(1)) + "("+ AllTrim(AllToChar(ProcLine(1))) +")"       + ";" + ;
						  AllTrim(AllToChar(cLog))    + ";" + ;
						  AllTrim(ProcName(2))        + ";" + ;
						  AllTrim(ProcName(3))        + ";" + ;
						  AllTrim(cUsername)    + Chr(13)+Chr(10))
		TMSLogMsg("INFO", "**************** REPOM: FIM DO LOG *********************")
	EndIf
EndIf

Return

/*/{Protheus.doc} 	RetRepomType
Retorna o tipo de documento utilizado na Repom
@author		Izac Silvério Ciszevski
@version	1.0
@since		03/09/2018
/*/
Static Function RetRepomType(cSerTMS, cFilDoc, cDoc, cSerie)

    Local aAreas    := { DT6->(GetArea(), GetArea() )}
    Local cType     := ""
    Local cDocTMS     := ""

    If cSerTMS == StrZero(1, Len(DTQ->DTQ_SERTMS))
        cType:= '6' // Ordem de Coleta
    Else
        DT6->(DbSetOrder(1)) //--DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
        If DT6->(MsSeek(xFilial('DT6') + cFilDoc + cDoc + cSerie ))
            cDocTMS := DT6->DT6_DOCTMS
            If cDocTMS == '6' .Or. cDocTMS == '7' // Reentrega ou Devolução pesquisa pelo Original
                cType := RetRepomType(DT6->DT6_SERTMS, DT6->DT6_FILDCO, DT6->DT6_DOCDCO, DT6->DT6_SERDCO)
            Else
                If cDocTMS $ ( '5', 'D', 'F', 'G')
                    cType:= '3'  //Nota Fiscal
                Else
                    cType:= '0'  //CTRC
                EndIf
            EndIf
        EndIf
    EndIf

    AEval( aAreas, { | aArea | RestArea(aArea) } )

Return cType

/*/{Protheus.doc} 	RetRntrVei
Retorna o RNTRC do Veículo
@author		Rafael Souza
@version	1.0
@since		03/01/2019
/*/
Static Function RetRntrVei(cCodVei)

Local cQuery 	:= ""
Local cAliasQry	:= ""
Local cRNTRC 	:= ""
Local aArea	 	:= GetArea()

Default cCodVei := ""

cQuery := "SELECT DA3_CODFOR, DA3_LOJFOR, DA3_COD, SA2.A2_RNTRC "
cQuery += "FROM " + RetSqlName("DA3") + " DA3 "
cQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 "
cQuery += "	ON A2_FILIAL = '" + xFilial("SA2") + "' "
cQuery += "	AND SA2.A2_COD = DA3_CODFOR "
cQuery += "	AND SA2.A2_LOJA = DA3_LOJFOR "
cQuery += "WHERE DA3_FILIAL = '" + xFilial("DA3") + "' "
cQuery += " AND DA3_COD = '" + cCodVei + "' "
cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
cQuery += " AND DA3.D_E_L_E_T_ = ' ' "

cQuery	:= ChangeQuery(cQuery)
cAliasQry 	:= GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
	cRNTRC := (cAliasQry)->A2_RNTRC 
EndIf 

(cAliasQry)->(DbCloseArea())

RestArea(aArea)
Return (cRNTRC) 

/*/{Protheus.doc} 	RepRetCod
Retorna array aCodigos com dados do Veiculo da viagem 
Utilizado nas rotinas tmsa140,tmsa141,tmsa144,tmsa240
@author		Katia
@version	1.0
@since		24/01/2019
/*/
Function RepRetCod(cCodVei, cCodRbq1, cCodRbq2, cCodRbq3, cCodMot, aCodigos)
Local cFornVei := ""
Local cCodRbq  := ""
Local cFornRbq := ""
Local aArea    := GetArea()

Default cCodVei  := ""
Default cCodRbq1 := ""
Default cCodRbq2 := ""
Default cCodRbq3 := ""
Default cCodMot  := ""
Default aCodigos := {}   

//----- Vetor aCodigos -----
// aCodigos[1] - Fornecedor do Veiculo
// aCodigos[2] - Codigo do Motorista
// aCodigos[3] - Codigo do Veiculo
// aCodigos[4] - Codigo do Ultimo Reboque -- REPOM atua somente com o controle de 1 reboque
//----------------------

If !Empty(cCodVei)
	DA3->(DbSetOrder(1))
	If DA3->(MsSeek( xFilial('DA3')+cCodVei))

		cFornVei:= Iif(DA3->DA3_FROVEI <> '1', DA3->(DA3_CODFOR+DA3_LOJFOR), 'SM0') 

		AAdd(aCodigos, { cFornVei ,;                    //Fornecedor Veiculo
			     	    cCodMot   ,;                    //Motorista  
				        cCodVei   ,;                    //Veiculo
					    ''        })                     //Reboque

		//-- Enviar sempre a ultima carreta, pois a Repom trabalha somente com uma carreta
		If !Empty(cCodRbq3) 
			cCodRbq:= cCodRbq3
		ElseIf !Empty(cCodRbq2) 
			cCodRbq:= cCodRbq2
		ElseIf !Empty(cCodRbq1) 
			cCodRbq:= cCodRbq1
		EndIf				

		//-- Se o Fornecedor do Reboque for diferente do Fornecedor do Veiculo, deve-ser gerar mais de um xml
		If !Empty(cCodRbq)
			cFornRbq:=  Posicione('DA3',1,xFilial('DA3')+cCodRbq,"DA3_CODFOR+DA3_LOJFOR")	
			If cFornVei == cFornRbq 	
				aCodigos[Len(aCodigos)][4]:= cCodRbq
			Else
				AAdd(aCodigos, { cFornRbq ,;                    //Fornecedor Veiculo
					     	    ''        ,;                    //Motorista  
						        ''        ,;                    //Veiculo
							    cCodRbq })                      //Reboque
			EndIf
		EndIf
	EndIf	
EndIf
RestArea(aArea)
Return Nil


/*/{Protheus.doc} 	RepRetDoc
Retorna array com os Documentos da Viagem
@author		Katia
@version	1.0
@since		31/03/2020
/*/
Function RepRetDoc(cFilVge,cViagem)
Local cQuery 	:= ""
Local aArea 	:= GetArea()
Local cAliasDUD := ""
Local aRet      := {}

Default cFilVge := ""
Default cViagem	:= ""

If !Empty(cFilVge) .And. !Empty(cViagem)
	//Verifica a quantidade de documentos da viagem
	cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE  "
	cQuery += "   FROM " + RetSqlName("DUD")
	cQuery += " Where DUD_FILIAL = '"+xFilial("DUD")+"'"
	cQuery += " AND DUD_FILORI = '" + cFilVge + "'"
	cQuery += " AND DUD_VIAGEM = '" + cViagem + "'"
	cQuery += " AND DUD_STATUS <> '9' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += "	ORDER BY DUD_FILORI, DUD_VIAGEM, DUD_SEQUEN "
	cQuery := ChangeQuery(cQuery)
	cAliasDUD := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.F.,.T.)
	While (cAliasDUD)->(!Eof())	
		AAdd (aRet, {(cAliasDUD)->DUD_FILDOC, (cAliasDUD)->DUD_DOC, (cAliasDUD)->DUD_SERIE, 0 })
		(cAliasDUD)->(DbSkip())
	EndDo	
	(cAliasDUD)->(DbCloseArea())
EndIf

RestArea(aArea)
Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} TMSGrvDES
Grava as informacoes preliminares sobre a Quitacao
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------------
Static Function	TMSGrvDES(cFilOri,cViagem,aDadOperad)
Default cFilOri   := ""
Default cViagem   := ""
Default aDadOperad:= {}

	RecLock('DES',.T.)
	DES->DES_FILIAL := xFilial('DES')
	DES->DES_FILORI := cFilOri
	DES->DES_VIAGEM := cViagem
	If Len(aDadOperad) > 0
		DES->DES_RELABA := IF(ValType(aDadOperad[4]) <> 'N', Val(aDadOperad[4]), aDadOperad[4])
		DES->DES_RELQTC := IF(ValType(aDadOperad[5]) <> 'N', Val(aDadOperad[5]), aDadOperad[5])
		DES->DES_LOCQTC := aDadOperad[6][1]
		//-- Quitacao na Filial. Grava a Filial de Quitacao
		DES->DES_FILQTC := Right(aDadOperad[6][2],2)
	EndIf
	DES->DES_STATUS := '1' //-- Quitacao nao Realizada
	MsUnLock()

Return

//--------------------------------------------------------
/*/{Protheus.doc} TMSExcDEP
Exclui as passagens referentes ao contrato
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------------
Static Function TMSExcDEP(cFilOri,cViagem)
Default cFilOri:= ""
Default cViagem:= ""

	DEP->(DbSetOrder(1)) //-- DEP_FILIAL+DEP_FILORI+DEP_VIAGEM+DEP_ORDEM
	If DEP->(MsSeek(xFilial('DEP') + cFilOri + cViagem))
		TmsRepTrac("CancelaContrato - Voltou TMSPassag ")
		While DEP->(MsSeek(xFilial('DEP') + cFilOri + cViagem))
			//EXCLUI A OPERACAO DE TRANSPORTE
			DTW->(DbSetOrder(1))
			If DTW->(MsSeek(xFilial('DTW') + cFilOri + cViagem + DEP->DEP_SEQDTW ))
				RecLock('DTW',.F.)
				DTW->(DbDelete())
				MsUnLock()
				TmsRepTrac("CancelaContrato - Del DTW " + xFilial('DTW') + cFilOri + cViagem + DEP->DEP_SEQDTW )
			EndIf
			//EXCLUI A PASSAGEM
			TmsRepTrac("CancelaContrato - Del INI DEP "+AllToChar(DEP->(Recno())) )
			RecLock('DEP',.F.)
			DEP->(DbDelete())
			MsUnLock()
			TmsRepTrac("CancelaContrato - Del FIM DEP ")
		EndDo
	EndIf

Return

//--------------------------------------------------------
/*/{Protheus.doc} TMSExcDES
Exclui os dados referente a Quitacao
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------------	
Static Function TMSExcDES(cFilOri,cViagem)
Default cFilOri:= ""
Default cViagem:= ""

	DES->(DbSetOrder(1))
	If DES->(MsSeek(xFilial('DES') + cFilOri + cViagem))
		RecLock('DES',.F.)
		DES->(DbDelete())
		MsUnLock()
		TmsRepTrac("CancelaContrato - Del DES " + xFilial('DES') + cFilOri + cViagem )
	EndIf

Return

//--------------------------------------------------------
/*/{Protheus.doc} TMSGravDTY
Atualiza o Status do Contrato conforme o Local da quitacao
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------------	
Static Function  TMSGravDTY(cFilOri,cViagem)
			
DTY->(DbSetOrder(2))
If DTY->(MsSeek(xFilial('DTY') + cFilOri + cViagem))
	TmsRepTrac("QuitaContrato Seek DTY OK:"+xFilial('DTY') + cFilOri + cViagem)
	RecLock('DTY',.F.)
	If DTY->DTY_LOCQUI == '1'
		DTY->DTY_STATUS := '1'
	EndIf
	MsUnLock()
Else
	TmsRepTrac("QuitaContrato Seek DTY OK:"+xFilial('DTY') + cFilOri + cViagem)
EndIf

Return

//--------------------------------------------------------
/*/{Protheus.doc} TmsAtuQuit
Atualiza Quitacoes em Aberto - Dados da tabela DES
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------------	
Static Function TmsAtuQuit(cFilOri,cViagem,nValSaq,nValCon,nSalPag)
Local lRet    := .F.

Default cFilOri:= ""
Default cViagem:= ""
Default nValSaq:= 0
Default nValCon:= 0
Default nSalPag:= 0

DES->(DbSetOrder(1))
If DES->(MsSeek(xFilial('DES') + cFilOri + cViagem))  .AND. DES->DES_STATUS <> '2'
	TmsRepTrac("QuitaContrato Seek DES OK:"+xFilial('DES') + cFilOri + cViagem)
	RecLock('DES',.F.)
	DES->DES_DATQTC := dDataBase
	DES->DES_HORQTC := StrTran(Left(Time(),5),':','')
	DES->DES_VALSAQ := nValSaq
	DES->DES_VALCON := nValCon
	DES->DES_SALPAG := nSalPag
	DES->DES_STATUS := '2' //-- Quitacao Realizada
	MsUnLock()
	lRet:= .T.   //Atualizado
EndIf

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} TmsMovQuit
Gera Movto. de Custo de transporte referente aos valores de Saques e Consumos
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//-----------------------------------------------------------------------------	
Static Function TmsMovQuit(cFilOri,cViagem,nValSaq,nValCon,cDesSaq,cDesAbast,cDesAdf,lRepom,cCodVei)

Local cQuery    := ""
Local cAliasQry := ""

Default cFilOri  := ""
Default cViagem  := ""
Default cDesAdf  := SuperGetMV('MV_DESADF',,'') //-- Despesa para lancamento de Adto. de Frete
Default cCodVei  := ""
Default lRepom   := SuperGetMV( 'MV_VSREPOM',, '1' ) $ '2|2.2' .And. SuperGetMV( 'MV_TMSOPDG',, '1' ) == '2'

	If !Empty(cDesAdf) .And. lRepom
		cQuery :=  ""
		cQuery += "SELECT DG_FILIAL, DG_FILORI, DG_VIAGEM, DG_CODVEI, DG_CODDES, DG_IDENT, DG_NUMSEQ, DG_SALDO  "
		cQuery += " FROM " + RetSqlName("SDG")
		cQuery += " WHERE DG_FILIAL = '" + xFilial('SDG') + "'"
		cQuery += " AND DG_FILORI = '"   + cFilOri  + "'"
		cQuery += " AND DG_VIAGEM = '"   + cViagem + "'"
		cQuery += " AND DG_CODVEI = '"   + cCodVei + "'"
		cQuery += " AND DG_CODDES = '"   + cDesAdf + "'"
		cQuery += " AND D_E_L_E_T_ = ' '  "
		cAliasQry := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		TmsRepTrac("QuitaContrato Qry tmsa070Bx chamada")
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		TmsRepTrac("QuitaContrato Qry tmsa070Bx Execução")
		While !(cAliasQry)->(EoF())
			TmsRepTrac("QuitaContrato Qry tmsa070Bx INI "+ (cAliasQry)->DG_NUMSEQ+"/"+cDesAbast+"/"+cDesSaq+"/"+AllToChar(nValCon)+"/"+AllToChar(nValSaq))
	
			If !Empty(cDesAbast) .And. nValCon > 0
		   		TMSA070Bx("1",(cAliasQry)->DG_NUMSEQ,cFilOri,cViagem,cCodVei,,,nValCon,,(cAliasQry)->DG_IDENT,cDesAbast)
			EndIf
	
			If !Empty(cDesSaq) .And. nValSaq > 0
		   		TMSA070Bx("1",(cAliasQry)->DG_NUMSEQ,cFilOri,cViagem,cCodVei,,,nValSaq,,(cAliasQry)->DG_IDENT,cDesSaq)
			EndIf
		
			TmsRepTrac("QuitaContrato Qry tmsa070Bx FIM ")
		    (cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		TmsRepTrac("QuitaContrato Qry tmsa070Bx CloseArea ")
		
		//-- baixando SDG de Adiantamento
		cAliasQry := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		TmsRepTrac("QuitaContrato Qry tmsa070Bx(2ª vez) chamada")
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		TmsRepTrac("QuitaContrato Qry tmsa070Bx(2ª vez) Execução")
		
		While !(cAliasQry)->(EoF()) .And. (cAliasQry)->DG_SALDO > 0
			TmsRepTrac("QuitaContrato Qry tmsa070Bx (2ª) INI "+ (cAliasQry)->DG_NUMSEQ+"/"+AllToChar((cAliasQry)->DG_SALDO))
		
			TMSA070Bx("1",(cAliasQry)->DG_NUMSEQ,cFilOri,cViagem,cCodVei,,,(cAliasQry)->DG_SALDO,,(cAliasQry)->DG_IDENT)
			TmsRepTrac("QuitaContrato Qry tmsa070Bx (2ª) FIM ")
		
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		TmsRepTrac("QuitaContrato Qry tmsa070Bx (2ª) CloseArea ")
	EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} TmsAdiFre
Gera Movto. de Custo de transporte referente aos valores de Saques e Consumos
(Adto do Contrato)
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//-----------------------------------------------------------------------------	
Static Function TmsAdiFre(cFilOri,cViagem,nValSaq,nValCon)

Default cFilOri:= ""
Default cViagem:= ""

Default nValSaq:= 0
Default nValCon:= 0

If nValSaq > 0 .Or. nValCon > 0
	//-- Ajusta o Valor do Adto. no Contrato
	DTY->(DbSetOrder(2))
	If DTY->(MsSeek(xFilial('DTY') + cFilOri + cViagem))
		TmsRepTrac("QuitaContrato seek OK DTY: "+xFilial('DTY') + cFilOri + cViagem)
		RecLock('DTY',.F.)
		DTY->DTY_ADIFRE := nValSaq + nValCon
		MsUnLock()
	Else
		TmsRepTrac("QuitaContrato seek NOK DTY: "+xFilial('DTY') + cFilOri + cViagem)
	EndIf
EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} TMSAtuDES
Atualiza Saldo DES
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//-----------------------------------------------------------------------------	
Static Function TMSAtuDES(cFilOri,cViagem,nSalPag)  

Default nSalPag:= 0

DES->(DbSetOrder(1))
If DES->(DbSeek(xFilial('DES') + cFilOri + cViagem))
	TmsRepTrac("AutorizaPagamento - Seek OK DES:"+xFilial('DES') + cFilOri + cViagem)
	RecLock('DES',.F.)
	DES->DES_SALPAG := nSalPag
	MsUnLock()
Else
	TmsRepTrac("AutorizaPagamento - Seek NOK DES:"+xFilial('DES') + cFilOri + cViagem)
EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} TMSAtuSDG
// Verifica se será gravado a  Despesa (Saldo) 
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//-----------------------------------------------------------------------------	
Static Function TMSAtuSDG(cFilOri, cViagem, cCodVei, cDesSald, nSalPag, cBanco, cAgencia, cNumCon)	
Local aAreaDg := SDG->( GetArea() )
// Seta a gravacao do saldos do pagamento como verdadeiro. Ira verificar na validacao
Local lGravaDg := .T.

Default nSalPag:= 0

// Verifica se existe ja o DG salvo na base. Se existir nao efetuo a gravacao
SDG->( DbSetOrder( 5 ) )
SDG->( DbSeek( xFilial('SDG') + cFilOri + cViagem + cCodVei) )
TmsRepTrac("AutorizaPagamento - Seek SDG:"+xFilial('SDG') + cFilOri + cViagem + cCodVei)

While SDG->(!Eof()) .And. SDG->DG_FILIAL == xFilial('SDG') .And. SDG->DG_FILORI == cFilOri .And. SDG->DG_VIAGEM == cViagem .And.  SDG->DG_CODVEI == cCodVei
TmsRepTrac("AutorizaPagamento - loop SDG "+AllToChar(SDG->(Recno())))
	If AllTrim(SDG->DG_CODDES) == AllTrim(cDesSald)
		lGravaDg := .F.
		EXIT
	EndIF
	SDG->(dbSkip())
Enddo

SDG->( RestArea( aAreaDG ) )
TmsRepTrac("AutorizaPagamento - Restarea SDG "+AllToChar(lGravaDg))

If lGravaDg
	TMA250GrvSDG('SDG', cFilOri, cViagem, cDesSald,  nSalPag,,cCodVei,,,,,,,,.T.,cBanco, cAgencia, cNumCon,,,,"TMSREPOM","2")
	TmsRepTrac("AutorizaPagamento - TMA250GrvSDG "+ cDesSald + "/" + AllToChar(nSalPag))
Endif

Return

//---------------------------------------------------
/*/{Protheus.doc} TmProcQuit
Processa a Quitação, caso a Quitação for autorizada 
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------	
Static Function TmProcQuit(cCodOpe,cFilOri,cViagem,aMsgErr,nValFre,lGerPdgPc,lFrotaProp)
Local lRet  := .F.

Default nValFre   := 0
Default lGerPdgPc := .F.
Default lFrotaProp:= .F.

//-- Caso a quitacao seja autorizada, processa a quitacao:
lRet := RepQuitMet( cCodOpe, cFilOri, cViagem, @aMsgErr,,,,.T.,nValFre)
If lRet .And. lGerPdgPc
	TmsRepTrac("AutorizaQuitacao - lGerPdgPc")

	//-- Gera Pedido de Compra referente a Prestacao de servicos da Operadora
	TmsGerPed(cCodOpe,cFilOri,cViagem,lFrotaProp)	
EndIf

Return lRet


//---------------------------------------------------
/*/{Protheus.doc} TmsGerPed
Gera o Pedido de Compra
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------	
Static Function TmsGerPed(cCodOpe,cFilOri,cViagem,lFrotaProp)

Local cNumPc:= ""
Local lRet  := .T.

Default lFrotaProp:= .F.

//-- Gera Pedido de Compra referente a Prestacao de servicos da Operadora
cNumPc := TMSOPdgPC( cCodOpe, cFilOri, cViagem, 3 )
If !lFrotaProp
	TmsRepTrac("AutorizaQuitacao - lGerPdgPc"+cNumPc)
Else
	TmsRepTrac("BaixaControleViagem - lGerPdgPc"+cNumPc)
EndIf

If !Empty(cNumPc)
	DTR->(DbSetOrder(1))
	If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
		If !lFrotaProp
			TmsRepTrac("AutorizaQuitacao - Seek OK DTR"+xFilial('DTR') + cFilOri + cViagem)
		Else
			TmsRepTrac("BaixaControleViagem - Seek OK DTR"+xFilial('DTR') + cFilOri + cViagem)
		EndIf
		RecLock('DTR',.F.)
		DTR->DTR_OPERPC := cNumPc
		MsUnLock()
	Else
		If !lFrotaProp
			TmsRepTrac("AutorizaQuitacao - Seek NOK DTR"+xFilial('DTR') + cFilOri + cViagem)
		Else
			TmsRepTrac("BaixaControleViagem - Seek NOK DTR"+xFilial('DTR') + cFilOri + cViagem)
		EndIf
	EndIf
EndIf	

Return lRet

//---------------------------------------------------
/*/{Protheus.doc} TmsExcPed
Exclui o Pedido de Compra
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------	
Static Function TmsExcPed(cCodOpe,cFilOri,cViagem,lFrotaProp)
Local lRet:= .T.

Default lFrotaProp:= .F.

TMSOPdgPC( cCodOpe, cFilOri, cViagem, 5 )
DTR->(DbSetOrder(1))
If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
	If !lFrotaProp
		TmsRepTrac("EstornoQuitacao - seek OK DTR:"+xFilial('DTR') + cFilOri + cViagem)
	EndIf
	RecLock('DTR',.F.)
	DTR->DTR_OPERPC := Space(Len(DTR->DTR_OPERPC))
	MsUnLock()
Else
	If !lFrotaProp
		TmsRepTrac("EstornoQuitacao - seek NOK DTR:"+xFilial('DTR') + cFilOri + cViagem)
	EndIf
EndIf

Return lRet

//---------------------------------------------------
/*/{Protheus.doc} TmsEstDES
Estorna dados da Tabela DES 
@type static function
@author Katia
@version 12.1.31
@since 20/10/2020
@return lRet
/*/
//---------------------------------------------------	
Static Function TmsEstDES(cFilOri,cViagem) 

//-- Elimina as informacoes processadas pela quitacao do contrato na Operadora
DES->(DbSetOrder(1))
If DES->(MsSeek(xFilial('DES') + cFilOri + cViagem))
	TmsRepTrac("EstornoQuitacao - seek OK DES:"+xFilial('DES') + cFilOri + cViagem)
	RecLock('DES',.F.)
	DES->DES_DATQTC := CtoD(Space(08))
	DES->DES_HORQTC := ''
	DES->DES_VALSAQ := 0
	DES->DES_VALCON := 0
	DES->DES_SALPAG := 0
	DES->DES_STATUS := '1' //-- Quitacao em Aberto
	MsUnLock()
Else
	TmsRepTrac("EstornoQuitacao - seek NOK DES:"+xFilial('DES') + cFilOri + cViagem)
EndIf

Return
//---------------------------------------------------
/*/{Protheus.doc} TmsRepDoc
Adiciona Documentos
@type static function
@author Caio
@version 12.1.31
@since 13/11/2020
@return lRet
/*/
//---------------------------------------------------
Function TmsRepDoc( cFilOri , cViagem , cFilDoc, cDoc , cSerie ) 
Local aArea		:= GetArea()
Local lRet		:= .T. 
Local oRepom	:= Nil

Default cFilOri	:= ""
Default cViagem	:= ""
Default cFilDoc	:= ""
Default cDoc	:= ""
Default cSerie	:= ""

If lRestRepom
	oRepom	:= TMSBCARepomFrete():New()
	If oRepom:Auth()
		lRet := oRepom:ShippingDocAdd( cFilOri, cViagem ,, cFilDoc, cDoc , cSerie ) 
	EndIf 

	FwFreeObj( oRepom )
EndIF 

RestArea(aArea)
Return lRet 
//---------------------------------------------------
/*/{Protheus.doc} RepRetShip
Trata o Retorno do ShippingCreate, com a atualização
dos dados do Nro do processo e CIOT 
@type static function
@author Katia
@version 12.1.31
@since 09/11/2020
@return lRet
/*/
//---------------------------------------------------	
Static Function RepRetShip(cFilOri,cViagem,cCodOpe,lIncCont,aMsgErr)
Local lRet	:= .F.
Local aRet	:= {}
Local nSeg	:= 0

Default cFilOri:= ""
Default cViagem:= ""
Default cCodOpe:= ""

//-- Verifica Status e Grava o N.o do Contrato da Operadora 
aRet:= TMS15IdShip(cFilOri,cViagem,.T. , @nSeg) //.T. - Atualiza DTR_PRCTRA 
If Len(aRet) > 1 
	lRet:= aRet[1]
	If !lRet
		aMsgErr := TMSErrOper(cCodOpe, aRet[2], '4')
	EndIf
EndIf

If lRet
	aRet:= TMS15CIOT(cFilOri,cViagem,.T. , nSeg) //.T. - Atualiza DTR_CIOT
	If Len(aRet) > 1 
		lRet:= aRet[1]
		If lRet
			lIncCont:= .T.  
		Else
			aMsgErr := TMSErrOper(cCodOpe, aRet[2], '4')
		EndIf
	Else
		lRet:= .F.
	EndIf
EndIf


Return lRet

//---------------------------------------------------
/*/{Protheus.doc} RepCanPgto
Efetua o Cancelamento da Autorização de Pagamento
@type Function
@author Katia
@version 12.1.31
@since 12/11/2020
@return lRet
/*/
//---------------------------------------------------	
Function RepCanPgto(cFilOri,cViagem,cNumCTC)
Local lRet:= .F.
Local oRepom:= Nil

Default cFilOri:= ""
Default cViagem:= ""
Default cNumCTC:= ""

//--- Valida o Evento de Pagto de Transporte
lRet:= TMSVldDLI(cFilOri,cViagem,cNumCTC,1)  //Validar

If lRet
	oRepom := TMSBCARepomFrete():New()
	oRepom:Auth()

	lRet:= oRepom:AuthCancel(cFilOri,cViagem)

	oRepom:Destroy()
	FwFreeObj(oRepom)

	If lRet
		TMSVldDLI(cFilOri,cViagem,cNumCTC,2)  //Excluir
	EndIf
EndIf

Return lRet

//---------------------------------------------------
/*/{Protheus.doc} TMSVldDLI
Valida o Status do Evento do Pagamento de Transporte
@type Function
@author Katia
@version 12.1.31
@since 17/11/2020
@return lRet
/*/
//---------------------------------------------------	
Function TMSVldDLI(cFilOri, cViagem, cNumCTC, nAcao)
Local lRet      := .T.
Local cSeek     := ""
Local aAreaDTX 	:= DTX->(GetArea())
Local aAreaDLI 	:= DLI->(GetArea())

Default cFilOri := ""
Default cViagem := ""
Default cNumCTC := ""
Default nAcao   := 1  //1- Validar, 2-Excluir

If !Empty(cFilOri) .And. !Empty(cViagem) .And. !Empty(cNumCTC)
	DTX->(dbSetOrder(3))
	DLI->(DbSetOrder(1))
	DTX->(DBSeek(cSeek:=xFilial('DTX')+cFilOri+cViagem)) 
	Do While !DTX->(Eof()) .And. DTX->DTX_FILIAL+DTX->DTX_FILORI+DTX->DTX_VIAGEM == cSeek
		If !Empty(DTX->DTX_NUMCTC) .And. DTX->DTX_NUMCTC == cNumCTC
			If DLI->(MsSeek(xFilial("DLI") + DTX->DTX_FILMAN + DTX->DTX_MANIFE + DTX->DTX_SERMAN + '116' ))
				//0=Preparado para Transmissão;1=Envio Evento realizado;2=Evento vinculado com sucesso;3=Evento rejeitado
				If nAcao == 1  //Validar
					If DLI->DLI_SEQEVE $ "1|2|3" 
						lRet:= .F.
					EndIf
				ElseIf nAcao == 2  //Excluir
					If DLI->DLI_SEQEVE == "0" 
						RecLock('DLI',.F.)
						DLI->(DbDelete())
						MsUnLock()
					EndIf
				EndIf
			EndIf
		EndIf
		DTX->(dbSkip())
	EndDo	
EndIf

RestArea(aAreaDTX)
RestArea(aAreaDLI)
Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} TmsImpRep(cFilOri,cViagem,aMovtos)
Funcao que importa os Impostos calculados pela REPOM
@author Katia
@since 06/11/2020
@version 2.2
@param cFilOri, cViagem, aMovtos
/*/
//---------------------------------------------------------------------------
Function TmsImpRep(cFilOri, cViagem, aMovtos, lValida)
Local nX       := 1
Local nVlr_IRRF:= 0
Local nVlr_INSS:= 0
Local nVlr_SEST:= 0
Local nVlr_VLSEST:= 0
Local nVlr_VLSENA:= 0
Local nTxAtivDeb := 0 
Local aAreaDTY   := DTY->(GetArea())
Local lRet       := .T.

Default cFilOri:= ""
Default cViagem:= ""
Default aMovtos:= {}
Default lValida:= .F.

If Len(aMovtos) > 0
	For nX:= 1 To Len(aMovtos[2])
		cCodMov:= aMovtos[2][nX][1]
		nVlrMov:= aMovtos[2][nX][2] 
       
		Do Case
		Case cCodMov  == '1'    //--  IRRF
			nVlr_IRRF	  += nVlrMov 
		Case cCodMov  == '34'  //--  INSS
			nVlr_INSS     += nVlrMov 
		Case cCodMov  == '2'    //--  SEST
			nVlr_SEST	  += nVlrMov 
			If DTY->(ColumnPOs('DTY_VLSEST')) > 0  //ERP Datasul
				nVlr_VLSEST += nVlrMov
			EndIf
		Case cCodMov  == '3'    //--  SENAT
			nVlr_SEST	  += nVlrMov 
			If DTY->(ColumnPOs('DTY_VLSENA')) > 0  //ERP Datasul
				nVlr_VLSENA += nVlrMov 
			EndIf
		Case cCodMov == "119"
			nTxAtivDeb	+= nVlrMov
		EndCase
	Next nX

	If lValida
		If nVlr_IRRF == 0 .And. nVlr_INSS == 0 .And. nVlr_SEST == 0 .And. nVlr_VLSENA
			lRet:= .F.
		EndIf
	Else
		//--- Atualiza valores na DTY (Trecho movido para a nova função)	
		TMSAtuDTY(cFilOri,cViagem,nVlr_IRRF,nVlr_INSS,nVlr_SEST,nVlr_VLSEST,nVlr_VLSENA , nTxAtivDeb )
	EndIf
EndIf

RestArea(aAreaDTY)
Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} RepIncMov(cFilOri,cViagem)
Funcao que inclui os Movimentos na Repom no Momento do Fechamento da Viagem
quando os impostos sao calculados pelo Protheus e neste caso o Contrato de 
Carreteiro foi gerado antes do contrato ser gerado na REPOM.
@author Katia
@since 06/11/2020
@version 2.2
@param cFilOri, cViagem
/*/
//---------------------------------------------------------------------------
Function RepIncMov(cFilOri,cViagem,lFechto)
Local lAddMovRep:= .F.
Local aAreaSDG  := SDG->(GetArea())
Local aArea     := GetArea()
Local aMovtos   := {}
Local lRet      := .T.
Local cIdReg    := ""
Local aMsgErr   := {}
Local lMovRep   := .F.

Default cFilOri := ""
Default cViagem := ""
Default lFechto := .T.   //T-Fechamento da Vaigem ou F- Estorno do Fechamento

//--- Inclui Movimentos no Fechamento da viagem quando as despesas foram incluidas apos o Contrato de Carreteiro
//--- Mv_impctc = 0, Quitação no Encerramento, Contrato de Carreteiro com status 'em aberto'
If FindFunction("TMSA070REP")
	lIncMov:= TMSA070REP(cFilOri,cViagem)
EndIf
If lIncMov
	SDG->(dbSetOrder(5))
	If SDG->(MsSeek(xFilial("SDG")+cFilOri+cViagem))
		Do While !SDG->(Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == xFilial("SDG")+cFilOri+cViagem
			If SDG->DG_ORIGEM == 'SDG' .Or. SDG->DG_ORIGEM == 'COM'
				cIdReg:= SDG->(DG_FILIAL + DG_DOC + DG_CODDES + DG_ITEM) //-- Formula do TMSA070 
				If !Empty(cIdReg)

					If lFechto
						lAddMovRep:= TMSVldDEN(SDG->DG_FILORI,SDG->DG_VIAGEM,cIdReg)
						If !lAddMovRep  //Se não adicionou ainda os Movimentos na REPOM, inclui os pendentes 
							TM70Movtos(SDG->DG_FILORI,SDG->DG_VIAGEM,@aMovtos)	
						EndIf
					
					Else  //Estorno do Fechamento
						lMovRep:= TMSVldDEN(SDG->DG_FILORI,SDG->DG_VIAGEM,cIdReg)
						If lMovRep
							If Empty(aMsgErr)
							   Aadd( aMsgErr,{"Existem Despesas para essa Viagem integradas com a Repom. Efetue o estorno da Despesa pelo Movto de Custo de Transporte.","01",""})
							EndIf
							Aadd( aMsgErr,{"Despesa: " + AllTrim(SDG->DG_DOC) +" - Cod.Despesa: "+ AllTrim(SDG->DG_CODDES) +" - Item: "+ AllTrim(SDG->DG_ITEM) +" - Total: "+ cValToChar(SDG->DG_TOTAL)  ,"01",""})
							lRet := .F.
						EndIf
					EndIf

				EndIf
			EndIf	
			SDG->(dbSkip())
		EndDo
	EndIf

	If lFechto .And. Len(aMovtos) > 0
		lRet:= TM70IncMov('01', cFilOri, cViagem, aMovtos)
	EndIf

	If !Empty(aMsgErr) .And. !lRet
		TmsMsgErr( aMsgErr )
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaSDG)
Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} TMSVldDEN(cFilOri,cViagem,cIdReg)
Funcao que valida se os Movimentos foram enviados para a REPOM para não serem
processados no Fechamento da Viagem em duplicidade.
@author Katia
@since 06/11/2020
@version 2.2
@param cFilOri, cViagem,cIdreg
/*/
//---------------------------------------------------------------------------
Function TMSVldDEN(cFilOri,cViagem,cIdReg)
Local cQuery   := ""
Local cAliasQry:= GetNextAlias()
Local lRet     := .F.

Default cFilOri:= ""
Default cViagem:= ""
Default cIdReg := ""

cQuery := "SELECT COUNT(*) QTDREG FROM " + RetSqlName("DEN") + " DEN "
cQuery += "WHERE DEN.DEN_FILIAL = '" + xFilial("DEN") + "' "
cQuery += " AND DEN.DEN_FILORI = '" + cFilOri + "' "
cQuery += " AND DEN.DEN_VIAGEM = '" + cViagem + "' "
cQuery += " AND DEN.DEN_IDREG = '" + cIdReg + "' "
cQuery += " AND DEN.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof()) .And. (cAliasQry)->QTDREG > 0
	lRet:= .T.
EndIf
(cAliasQry)->(DbCloseArea())

Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} RepVldImp()
Valida se os Impostos foram calculados na REPOM (MV_IMPCTC = 1)
Se nao calculado, não permite a geracao do contrato de carreteiro.

@author Katia
@since 24/12/2021
@version 2.2
@param cFilOri, cViagem, aMsgErr
/*/
//---------------------------------------------------------------------------
Static Function RepVldImp(cFilOri , cViagem, cCodVei, aMsgErr)
Local lRet    := .T.
Local aMovRep := {}
Local cTipPess:= ""

Default cFilOri:= ""
Default cViagem:= ""
Default cCodVei:= ""

cTipPess :=	TmsXPess(cFilOri, cViagem, cCodVei)
If Alltrim(cTipPess) == 'F'
	lRet:= .F.
	aMovRep:= TmsIncImp( cFilOri,cViagem ) //Pesquisa os Movimentos Impostos REpom
	If Len(aMovRep) > 0
		lRet:= TmsImpRep(cFilOri,cViagem,aMovRep,.T.)
	EndIf

	If !lRet
		AAdd( aMsgErr, { STR0041, '01', } ) //"Valores de Impostos zerados. Os impostos não foram calculados pela REPOM."
	EndIf
EndIf

FwFreeArray(aMovRep)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} AtuTabSDG
Atualiza SDG
@type Function
@author CAio Murakami
@since 10/06/2021
@version 12.1.30
@param
@return lRet
*/
//------------------------------------------------------------------
Static Function AtuTabSDG( aCab , nOpc )
Local nCount	:= 1 
Local lExclui	:= .F. 
Local aArea		:= GetArea()

Default aCab	:= {}
Default nOpc	:= 3 

If FindFunction("TMSA070Aut")
	TMSA070Aut( aCab , nOpc )
Else 

	If nOpc == 3 
		RecLock("SDG",.T.)
	ElseIf nOpc == 4 .Or. nOpc == 5 
		RecLock("SDG",.F.)
		If nOpc == 5 
			lExclui	:= .T. 
		EndIf 
	EndIf 

	If lExclui
		SDG->(DbDelete())
	Else	
		For nCount := 1 To Len(aCab )
			SDG->&(aCab[nCount,1])	:= aCab[nCount,2]
		Next nCount 
	EndIf 

	SDG->(MsUnlock())
EndIf 

RestArea(aArea)
Return 
