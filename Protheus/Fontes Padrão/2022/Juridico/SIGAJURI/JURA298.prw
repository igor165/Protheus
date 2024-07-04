#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'JURA298.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA298(aCabec)
Cadastro automático de NIPs

@param  aCabec
		aCabec[1] - Empresa
		aCabec[2] - Filial
		aCabec[3] - Cód Usuário Protheus
		aCabec[4] - usuário para login na solucionari
		aCabec[5] - senha para login na solucionari
		aCabec[6] - Resposta da requisição, caso seja teste (PROCESSO)
		aCabec[7] - Resposta da requisição, caso seja teste (ANDAMENTO)
@param  lTeste    - Indica se a execução é um teste
@return lConfirm  - .T.
@since 22/09/2021
/*/
//-------------------------------------------------------------------
Function JURA298(aCabec, lTeste)

Local cEmp        := ''
Local cFil        := ''
Local cLogin      := ''
Local cPwd        := ''
Local cUser       := ''
Local cEndPoint   := 'https://clientenips.azurewebsites.net/api'
Local aHeader     := {}
Local lContinua   := .T.
Local oResponse   := JsonObject():New()
Local oAndamento  := NIL
Local lAutomato   := Len(aCabec) > 6

Default lTeste    := .F.
Default lAltera   := .F.

public cTipoAsJ   := "013"
public c162TipoAs := "013"
Private __CUSERID := ""


	If Len(aCabec) > 2
		cEmp   := aCabec[1]
		cFil   := aCabec[2]
		cUser  := aCabec[3]

		If !lAutomato
			RpcSetType(3)
			RPCSetEnv( cEmp, cFil, cUser,,,"JURA298")
		EndIf

		If Len(aCabec) > 3
			cLogin := aCabec[4]
			cPwd   := aCabec[5]
		Else
			cLogin := SuperGetMV('MV_JINDUSR',, '')
			cPwd   := SuperGetMV('MV_JINDPSW',, '')
		EndIf
		
		__CUSERID := cUser

		If !Empty(cLogin) .AND. !Empty(cPwd)
			Aadd(aHeader,"authorization: " + Encode64(cLogin + ":!!:" + cPwd))
			
			While( lContinua )
				If lTeste .AND. lAutomato
					oAndamento := JsonObject():New()
					oResponse  := aCabec[6]
					oAndamento := aCabec[7]
					lContinua := IncluiNip(cEndPoint,aHeader, cUser, lTeste, oResponse, oAndamento)
				Else
					oResponse := ColetaNips(cEndPoint, aHeader)
					lContinua := IncluiNip(cEndPoint,aHeader, cUser, lTeste, oResponse)
				EndIf
			End
		Else
			JURCONOUT(STR0004) // 'Não foram preenchidos os paramaetros MV_JINDUSR e MV_JINDPSW'
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} IncluiNip(cEndPoint, aHeader, cCodUser)
Responsável por incluir / Alterar uma NIP

@param  cEndPoint - Endpoint da requisição
@param  aHeader   - Cabeçalho da requisição
@param  cCodUser  - Código de usuário
@param  lTeste    - Indica se a execução é um teste
@return lConfirm  - .T.
@since 22/09/2021
/*/
//-------------------------------------------------------------------
Static Function IncluiNip(cEndPoint, aHeader, cCodUser, lTeste, oResponse, oResposta)
Local oRest      := Nil 
Local aBody      := {}
Local aRet       := {}
Local aRetH      := {}
Local cCodProc   := ''
Local lConfirm   := .F.
Local nI         := 0
Local lAutomato  := Len(FWJsonSerialize(oResposta, .F., .F., .T.)) < 4 //Valida se foi passado o oReposta

Default oResponse  := JsonObject():New()
Default oResposta  := JsonObject():New()

	If Len(oResponse) > 0
		For nI := 1 to Len(oResponse)
			lConfirm := IIF( lTeste, .F., .T. )
			cCodProc := cValToChar(oResponse[nI]["codProcesso"])
			JurConOut('codProcesso: ' + cCodProc)

			If lAutomato .OR. GetAndbyCodProc(cEndPoint, aHeader, cCodProc, @oResposta)

				If lAutomato
					Aadd(aRetH, .F.)
					Aadd(aRetH, "")
				Else
					// Verifica se ira realizar inclusão ou alteração de uma NIP
					aRetH := GetHproc(cEndPoint, cCodProc)
				EndIf

				If aRetH[1] .AND. !Empty(aRetH[2]) // Alteração de NIP

					JurConOut('cajuri: ' + aRetH[2])
					aRet := J298SetNIP(oResponse[nI], oResposta, cCodUser, 4, aRetH[2])

					If aRet[1]
						J298IncAnd(oResposta, aRet[3], aHeader, cEndPoint, cCodUser, lTeste)
						Aadd( aBody, { oResponse[nI]["codProcesso"] } )
					EndIf

				Else  // Inclusão de NIP
					aRet := J298SetNIP(oResponse[nI], oResposta, cCodUser, 3)
					
					If aRet[1]
						J298IncAnd(oResposta, aRet[3], aHeader, cEndPoint, cCodUser, lTeste)
						Aadd( aBody, { cCodProc, aRet[3] } )
					EndIf
				EndIf
			EndIf
		Next nI

		// Remove a NIP do container
		If Len(aBody) > 0 .AND. !lTeste
			oRest:SetPath("/apipostprocessos")
			oRest:SetPostParams(FWJsonSerialize(aBody, .F., .F., .T.))

			If oRest:Post(aHeader)
				oResponse:fromJson(oRest:GetResult())
			EndIf
		EndIf
	EndIf

	FwFreeObj(aBody)
	FwFreeObj(oRest)
	FwFreeObj(oResponse)
	FwFreeObj(oResposta)

Return lConfirm

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAndbyCodProc(cEndPoint,aHeader,cCodProc,oEnvolv)
Função que realiza o get para busca dos andamentos de uma determinada
NIP a partir do codProcesso

@param  cEndPoint - Endpoint da requisição
@param  aHeader   - Cabeçalho da requisição
@param  cCodProc  - Codigo de processo da NIP
@param  oResposta - Objeto com os dados de envolvidos
@return .T.
@since 22/09/2021
/*/
//-------------------------------------------------------------------
Static Function GetAndbyCodProc(cEndPoint, aHeader, cCodProc, oResposta)
Local oAndProc   := Nil 
Local aCabProc   :=  AClone(aHeader)
Local lRetorno   := .F.

	oAndProc := FWRest():New(cEndPoint)
	Aadd(aCabProc,"codProcesso: " + cCodProc)
	oAndProc:SetPath('/apigetandamentos')

	If oAndProc:Get(aCabProc)

		oResposta := JsonObject():New()
		oResposta:fromJson(oAndProc:GetResult())

		If Len(oResposta) > 0
			aSize(aCabProc,0)
			lRetorno   := .T.
		EndIf
	EndIf

	aSize(aCabProc,0)
	FwFreeObj(oAndProc)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J298SetNIP(oNSZ, oResposta, cCodUser)
Função que realiza a inclusão da NIP na JURA095

@param oNSZ       - Dados do processo
@param oResposta  - Dados de envolvidos dos andamentos
@param cCodUser   - Código de usuário
@param nOperacao  - 3 - Inclusão / 4 - Alteração
@param cCajuri    - Codigo da NIP (em caso de alteração)
@return lRetorno  - Indica se a NIP foi incluída
		cMsgError - Guarda a mensagem de erro, se houver
		cCajuri   - Numero da nip cadastrada
@since 22/09/2021
/*/
//-------------------------------------------------------------------
Static Function J298SetNIP(oNSZ, oResposta, cCodUser, nOperacao, cCajuri)

Local oModel     := FWLoadModel('JURA095')
Local cCfgNIPAut := J293CfgQry("2", "true")
Local aCfgNIP    := STRTOKARR(cCfgNIPAut, ",")
Local oNT9       := JsonObject():New()
Local cCPFCNPJ   := '00000000000'
Local oMdlNT9    := NIL
Local lIguais    := .F.
Local lRetorno   := .T.
Local nX         := 0
Local cNome      := ""
Local cEmail     := ""
Local cCodTpenv  := ""
Local cCodCli    := ""
Local cLojaCli   := ""
Local cCodPlano  := ""
Local cMsgError  := ""
Local cCodEnt    := ""
Local cEntPolo   := ""
Local cCGC       := ""
Local aDadosNZ2  := {}
Local aDadosSA1  := {}
Local lAltera    := .F.
Local nI         := 0
Local lAlterou   := .F.
Local lEntid     := .T.

Default cCajuri  := ""

	If VALTYPE(oResposta[1]['infoAndamento']) <> 'U'
		oNT9 := oResposta[1]['infoAndamento']
	EndIf

	// Busca operadora / plano
	
	cCodPlano := StrTran(oNT9['operadora_plano']['codigo_campo'], "-", "")
	aDadosSA1 := J298OperSA1(cCodPlano)

	If Len(aDadosSA1) > 0
		cCodCli   := IIF( Len(aDadosSA1[1]) > 0, aDadosSA1[1][1], "" )
		cLojaCli  := IIF( Len(aDadosSA1[1]) > 1, aDadosSA1[1][2], "" )
		cCGC      := IIF( Len(aDadosSA1[1]) > 2, aDadosSA1[1][3], "" )
		cCGC      := IIF( cCGC == 'J', '2', '1' )
	EndIf

	If Empty(cCodCli) .OR. Empty(cLojaCli)
		lRetorno := .F.
		cMsgError := STR0001 // "Não foi possível localizar a operadora / plano na tabela SA1."
		JURCONOUT(STR0001)
	EndIf
	
	If lRetorno .AND. VALTYPE(aCfgNIP) == "A" .AND. Len(aCfgNIP) > 0
		If Empty(aCfgNIP[1]) .OR. Empty(aCfgNIP[2]) .OR. Empty(aCfgNIP[3])
			lRetorno := .F.
			cMsgError := STR0002 // "Não foi possível localizar as configurações para cadastro automático de NIPs."
			JURCONOUT(STR0002)
		EndIf
	Else
		lRetorno := .F.
		cMsgError := STR0002 // "Não foi possível localizar as configurações para cadastro automático de NIPs."
		JURCONOUT(STR0002)
	EndIf

	If lRetorno
		If nOperacao == 4
			dbSelectArea("NSZ")
			NSZ->( dbSetOrder(1) )
			lAltera := NSZ->( dbSeek( xFilial( 'NSZ' ) + cCajuri) )
			lRetorno := lAltera
		EndIf

		If lAltera .OR. nOperacao == 3
			oModel := FWLoadModel("JURA095")
			oModel:SetOperation( nOperacao )
			oModel:Activate()

			oModel:SetValue("NSZMASTER", "NSZ_CCLIEN", cCodCli ) // Cod cliente
			oModel:SetValue("NSZMASTER", "NSZ_LCLIEN", cLojaCli ) // loja cliente
			oModel:SetValue("NSZMASTER", "NSZ_TIPOAS", '013' ) // tipo de assunto - 013
			oModel:SetValue("NSZMASTER", "NSZ_OBJSOC", J298DcdUTF8(oNSZ['assunto']) ) // Natureza
			oModel:SetValue("NSZMASTER", "NSZ_CAREAJ", aCfgNIP[3] ) // Área Jurídica
			oModel:SetValue("NSZMASTER", "NSZ_SIGLA1", aCfgNIP[2]) // Sigla Gestor
			oModel:SetValue("NSZMASTER", "NSZ_CPART1", aCfgNIP[1] ) // Cod participante gestor
			//oModel:SetValue("NSZMASTER", "NSZ_DTCONC", cValor ) // data Prazo
			oModel:SetValue("NSZMASTER", "NSZ_TOMBO" , J298DcdUTF8(oNT9['detalhes_da_solicitacao']['assunto']) ) // Assunto
			oModel:SetValue("NSZMASTER", "NSZ_DETALH", J298DcdUTF8(oNT9['descricao_da_demanda']['situacao'])) // reclamação / solicitação
			oModel:SetValue("NSZMASTER", "NSZ_NUMREG", J298DcdUTF8(oNT9['operadora_plano']['o_plano_foi_contratado'])) // plano
			oModel:SetValue("NSZMASTER", "NSZ_DTCERT", STOD( StrTran(SUBSTR(oNSZ['dataDistribuicao'], 1, 10), "-", "") ) ) // Data notificação
			oModel:SetValue("NSZMASTER", "NSZ_IDENTI", oNSZ['numProcesso']) // Demanda
			oModel:SetValue("NSZMASTER", "NSZ_NIRE"  , oNSZ['vara']) // Protocolo
			//oModel:SetValue("NSZMASTER", "NSZ_NUMPED", cValor) // Prazo texto
			oModel:SetValue("NSZMASTER", "NSZ_ULTCON", J298DcdUTF8(oNSZ['tribunal'])) // Status da NIP
			oModel:SetValue("NSZMASTER", "NSZ_USUINC", UsrRetName(cCodUser) ) // Cod cliente

			If Valtype( oNT9['beneficiario']) <> 'U'
				cNome    := J298DcdUTF8(oNT9['beneficiario']["nome_completo"])
				cEmail   := IIF( VALTYPE(oNT9['beneficiario']["e-mail"]) <> "U", oNT9['beneficiario']["e-mail"], "")

				If !Empty(oNT9['beneficiario']["cpf"])
					cCPFCNPJ := Strtran(StrTran(oNT9['beneficiario']["cpf"], "."), "-", "")
				EndIf
				Aadd(aDadosNZ2, {cCPFCNPJ,cNome,cEmail,'Beneficiário'})
			EndIf

			If Valtype( oNT9['interlocutor']) <> 'U'
				cNome     := J298DcdUTF8(oNT9['interlocutor']["nome_completo"])
				cCPFCNPJ  := '00000000000'
				cEmail    := oNT9['interlocutor']["e-mail"]
				Aadd(aDadosNZ2, {cCPFCNPJ,cNome,cEmail,'Interlocutor'})
			EndIf

			If Valtype( oNT9['operadora_plano']) <> 'U'
				cEntPolo := "SA1"
			EndIf

			// Verifica se interlocutor e beneficiário sao a mesma pessoa
			If Len(aDadosNZ2) > 1
				If AdadosNZ2[1][2] == AdadosNZ2[2][2]
					AdadosNZ2[1][3] := oNT9['interlocutor']["e-mail"]
					AdadosNZ2[2][1] := AdadosNZ2[1][1]
					lIguais := .T.
				EndIf
			EndIf

			oMdlNT9 := oModel:GetModel('NT9DETAIL')
			
			For nX := 1 to Len(aDadosNZ2)
				cCodTpenv := vldTpEnvNip( aDadosNZ2[nX][4] )
				lAlterou := .F.
				For nI := 1 To oMdlNT9:GetQtdLine()
					//Validação para ver se o CPF e TIPO DE ENVOLVIMENTO, FOREM IGUAIS ATUALIZA A NZ2
					If !Empty(aDadosNZ2[nX][1]) .AND. ;
						oMdlNT9:GetValue('NT9_CGC', nI) == aDadosNZ2[nX][1] .AND. ;
						oMdlNT9:GetValue('NT9_CTPENV', nI) == cCodTpenv

						cCodEnt := J268GrvNZ2(.F., aDadosNZ2[nX], .T.)
						lAlterou := .T.
					EndIf
				Next nI

				If !lAlterou
					cCodEnt := J268GrvNZ2(.F., aDadosNZ2[nX], .T.)

					If !Empty(cCodEnt)

						oMdlNT9:Goline(oMdlNT9:GetQtdLine())
						oMdlNT9:AddLine()

						J105SetDados("NZ2",cCodEnt)
						oMdlNT9:SetValue("NT9_ENTIDA", "NZ2")
						oMdlNT9:SetValue("NT9_CODENT", cCodEnt)
						oMdlNT9:SetValue("NT9_PRINCI", "1")
						oMdlNT9:SetValue("NT9_TIPOP", "1")

						If aDadosNZ2[nX][4] == "Beneficiário"
							oMdlNT9:SetValue("NT9_TIPOEN", "1" )
						Else
							oMdlNT9:SetValue("NT9_TIPOEN","3" )
						EndIf
						oMdlNT9:SetValue('NT9_CTPENV', cCodTpenv)
						
					EndIf
				EndIf
			Next nX

			// Adiciona Operadora / plano
			If cEntPolo == "SA1" 
				lEntid := .T.
				For nI := 1 To oMdlNT9:GetQtdLine()
					If oMdlNT9:GetValue('NT9_ENTIDA', nI) == 'SA1' .AND. oMdlNT9:GetValue("NT9_PRINCI",nI) == "1"
						If oMdlNT9:GetValue("NT9_CODENT", nI) == cCodCli + cLojaCli
							lEntid := .F.
						Else
							oMdlNT9:Goline(nI)
							oMdlNT9:SetValue("NT9_PRINCI", "2")
							lEntid := .T.
						EndIf
					EndIf
				Next
				If lEntid
					oMdlNT9:Goline(oMdlNT9:GetQtdLine())
					oMdlNT9:AddLine()
					oMdlNT9:SetValue("NT9_ENTIDA", 'SA1')
					oMdlNT9:SetValue("NT9_CODENT", cCodCli + cLojaCli)
					oMdlNT9:SetValue("NT9_PRINCI", "1")
					oMdlNT9:SetValue("NT9_TIPOEN", '2')
					cCodTpenv := vldTpEnvNip('Operadora')
					oMdlNT9:SetValue('NT9_CTPENV', cCodTpenv)
				EndIf
			EndIf

			// Validação do modelo e commit dos dados
			If !( oModel:VldData() ) .Or. !( oModel:CommitData() )
				cMsgError := "Erro: " + CRLF  // "Erro: "
				cMsgError += "Campo: " + oModel:aErrorMessage[4] + CRLF + ; // "Campo: "
							"Razao: " + oModel:aErrorMessage[5] + CRLF + ; // "Razao: "
									CRLF + oModel:aErrorMessage[6] + CRLF   // Mensagem
				JurConOut( cMsgError )
				lRetorno := .F.
			Else
				cCajuri := oModel:GetValue("NSZMASTER","NSZ_COD")
			EndIf

			oModel:DeActivate()
		EndIf
		
	EndIf

Return { lRetorno, cMsgError, cCajuri }

//-------------------------------------------------------------------
/*/{Protheus.doc} J298OperSA1(cCodPlano)
Função que busca código e loja da operadora na SA1 de acordo com o 
código da operadora da NIP

@param  cCodPlano - Código da operadora / plano
@return aDados - Dados da operadora
		aDados[1] - Código (A1_COD)
		aDados[2] - Loja (A1_LOJA)
@since 22/09/2021
/*/
//-------------------------------------------------------------------
Static Function J298OperSA1(cCodPlano)
Local aArea   := GetArea()
Local cAlias  := GetNextAlias()
Local aDados  := {}
Local cQuery  := ""

	If !Empty(cCodPlano)
		cQuery := " SELECT A1_COD COD, "
		cQuery +=        " A1_LOJA LOJA, "
		cQuery +=        " A1_NOME NOME, "
		cQuery +=        " A1_PESSOA CGC "
		cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
		cQuery += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery +=        " AND SA1.A1_IDHIST = '" + StrZero(Val(cCodPlano), 12) + "' "
		cQuery +=        " AND SA1.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .F.)

		If !(cAlias)->(Eof())
			aAdd( aDados, { (cAlias)->COD, (cAlias)->LOJA ,(cAlias)->CGC } )
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	RestArea(aArea)

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} J298DcdUTF8(cValor, cEncoding)
Função que realiza decode UTF8

@param  cValor    - String a ser decodada
@param  cEncoding - Encoding a ser utilizado
@return cResult   - String decodada
@since 22/09/2021
/*/
//-------------------------------------------------------------------
Function J298DcdUTF8( cValor, cEncoding )

Local cResult := ""
Default cEncoding := 'cp1252'

	If !Empty(cValor)
		cResult := DecodeUtf8(cValor, cEncoding)
	EndIf

	If cResult == Nil
		cResult := cValor
	EndIf

Return cResult
//-------------------------------------------------------------------
/*/{Protheus.doc} J298IncAnd(oAndamentos, cCajuri, aHeader, cEndPoint, cCodUser)
Função que insere os andamentos no Protheus

@param oAndamentos - Json com todos os andamentos
@param cCajuri     - Código do Cajuri
@param aHeader     - Header
@param cEndPoint   - Url da API Azure
@param cCodUser    - Código do usuário
@param  lTeste     - Indica se a execução é um teste
@return { aSucess, aError } - Mensagem de erro e sucesso
@since 23/09/2021
/*/
//-------------------------------------------------------------------
Static Function J298IncAnd(oAndamentos, cCajuri, aHeader, cEndPoint, cCodUser, lTeste)

Local oModel     := NIL
Local aError     := {}
Local aSucess    := {}
Local aBodyAnd   := {}
Local aArquivos  := {}
Local aAndamento := {}
Local nX         := 0
Local nI         := 0
Local cNomeLink  := ""
Local cCodAnd    := ""
Local cCodDoc    := ""
Local cNomeDoc   := ""
Local cTxt       := ""
Local cData      := ""
Local cResumo    := ""

	For nX := 1 to len(oAndamentos)

		aAndamento := GetAndamentos(cCajuri)

		For nI := 1 To Len(oAndamentos[nX]['infoAndamento']['documentos'])

			cCodDoc := oAndamentos[nX]['infoAndamento']['documentos'][nI]['num_documento']
			If !Empty( cCodDoc )
				cCodDoc := '(' + cCodDoc + ') - '
			EndIf

			cNomeDoc := J298DcdUTF8(oAndamentos[nX]['infoAndamento']['documentos'][nI]['tipo_documento'])
			cNomeLink := oAndamentos[nX]['infoAndamento']['documentos'][nI]['link']
			aAdd( aArquivos, { cNomeDoc, cNomeLink } )

			// Transforma conteúdo do pdf em txt
			cTxt := J298PdfToText( cNomeDoc, cNomeLink )

			If Empty(cTxt) .OR. VALTYPE(cTxt) <> "C" .Or. VALTYPE(cCoddoc) <> "C" .Or. VALTYPE(cNomeDoc) <> "C"
				If VALTYPE(J298DcdUTF8(cCodDoc + cNomeDoc)) <> "U"
					cTxt := J298DcdUTF8(cCodDoc + cNomeDoc)
				Else
					cTxt := cCodDoc + cNomeDoc
				EndIf
			EndIf

			If !Empty(oAndamentos[nX]['infoAndamento']['documentos'][nI]['data_documento'])
				cData := oAndamentos[nX]['infoAndamento']['documentos'][nI]['data_documento']
			Else
				cData := StrTran(SUBSTR(oAndamentos[nX]['dataAndamento'], 1, 10), "-", "")
			EndIf

			If VALTYPE(J298DcdUTF8(cCodDoc + cNomeDoc)) <> "U"
				cResumo := J298DcdUTF8( cCodDoc + cNomeDoc )
			Else
				cResumo := cCodDoc + cNomeDoc
			EndIf

			If aScan(aAndamento,{|x| alltrim(x[1]) == cResumo}) == 0
				
				cCodAnd := GetSX8Num("NT4","NT4_COD")
				oModel  := FWLoadModel('JURA100')
				oModel:SetOperation( 3 )  //Inclusao
				oModel:Activate()

				oModel:SetValue("NT4MASTER", "NT4_FILIAL", xFilial("NT4") )
				oModel:SetValue("NT4MASTER", "NT4_COD",    cCodAnd )
				oModel:LoadValue("NT4MASTER","NT4_CAJURI", cCajuri )
				oModel:LoadValue("NT4MASTER", "NT4_DESC",  IIF( !Empty(Alltrim(cTxt)), cTxt, cResumo) )
				oModel:SetValue("NT4MASTER", "NT4_DTINCL", Date() )
				oModel:SetValue("NT4MASTER", "NT4_USUINC", UsrRetName(cCodUser) )
				oModel:SetValue("NT4MASTER", "NT4_DTALTE", Date() )
				oModel:SetValue("NT4MASTER", "NT4_USUALT", UsrRetName(cCodUser) )
				oModel:SetValue("NT4MASTER", "NT4_PCLIEN", "1" )
				oModel:SetValue("NT4MASTER", "NT4_DTANDA", STOD(cData) )
				oModel:SetValue("NT4MASTER", "NT4_RESUMO", SubStr( cResumo, 1, TamSX3("NT4_RESUMO")[1]) )
				// Marcação se veio do serviço
				oModel:SetValue("NT4MASTER", "NT4_ANDAUT", "1" )

				If !(oModel:VldData()) .Or. !(oModel:CommitData())
					cMsgError := "Erro: " + CRLF  // "Erro: "
					cMsgError += "Campo: " + oModel:aErrorMessage[4] + CRLF + ; // "Campo: "
								"Razao: " + oModel:aErrorMessage[5] + CRLF + ; // "Razao: "
								CRLF + oModel:aErrorMessage[6] + CRLF   // Mensagem
					JurConOut( cMsgError )
					Aadd(aError, { cMsgError,  oAndamentos[nX]['codAndamento'] } )

				Else
					// Inclui anexo
					J298IncAnx(cCodAnd, aArquivos, cCajuri)
					aSize(aArquivos, 0)
				EndIf

				oModel:DeActivate()
				oModel := NIL
			EndIf
		Next nI

		If Len(aError) == 0
			Aadd(aSucess, { "Sucesso",  oAndamentos[nX]['codAndamento'] } )
			Aadd(aBodyAnd, { oAndamentos[nX]['codAndamento'], oAndamentos[nX]['codProcesso'] })
		EndIf
	Next nX

	// Remove o andamento do container
	If Len(aBodyAnd) > 0 .AND. !lTeste
		PostAndSucess(aBodyAnd, aHeader, cEndPoint)
	EndIf

Return { aSucess, aError }

//-------------------------------------------------------------------
/*/{Protheus.doc} PostAndSucess(aBodyAnd, aHeader, cEndPoint)
Função que faz o Post dos andmaentos que foram adicionados no Protheus

@parama BodyAnd  - Body do post do andamentos { codAndamento, codProcesso }
@param aHeader   - Header do post
@param cEndPoint - Url do post
@return lRet     - Retorna boolean
@since 23/09/2021
/*/
//-------------------------------------------------------------------
Static Function PostAndSucess(aBodyAnd, aHeader, cEndPoint)

Local oRest      := Nil 
Local oResponse  := JsonObject():New()
Local lRet       := .F.
	
	oRest := FWRest():New(cEndPoint)
	oRest:SetPath("/apipostandamentos")
	oRest:SetPostParams(FWJsonSerialize(aBodyAnd, .F., .F., .T.))

	If oRest:Post(aHeader)
		oResponse:fromJson(oRest:GetResult())
		lRet := .T.
	EndIf

	FwFreeObj(oRest)
	FwFreeObj(oResponse)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetHproc(cEndPoint, cCodProc)
Função faz o GET da marcação dos processo já incluidos (H)

@param cEndPoint - Url do inicio do GET
@param cCodProc  - Código do processo para a busca do h na Azure
@return { lRet, oResp['codCajuri']}, Array com o boolean + o código do cajuri
@since 23/09/2021
/*/
//-------------------------------------------------------------------
Static Function GetHproc(cEndPoint, cCodProc)

Local oRestProc  := Nil
Local oResp      := JsonObject():New()
Local aHeader    := {}
Local lRet       := .F.

	Aadd(aHeader,"codProcesso: " + cCodProc)
	oRestProc := FWRest():New(cEndPoint)
	oRestProc:SetPath('/apigethprocess')

	If oRestProc:Get(aHeader)
		oResp:fromJson(oRestProc:GetResult())
		If Len(oResp) > 0
			aSize(aHeader,0)
			lRet := .T.
			Return { lRet, oResp[1]['codCajuri']}
		EndIf
	EndIf

	aSize(aHeader,0)
	FwFreeObj(oResp)
	FwFreeObj(oRestProc)

Return { lRet, "" }

//-------------------------------------------------------------------
/*/{Protheus.doc} J298IncAnx(cCodAnd, aArquivos, cCajuri)
Função que realiza a inclusão do arquivo do andamento
na rotina de anexos (NUM)

@param oNSZ       - Dados do processo
@param oResposta  - Dados de envolvidos dos andamentos
@param cCodUser   - Código de usuário
@return lRetorno  - Indica se a NIP foi incluída
		cMsgError - Guarda a mensagem de erro, se houver
@since 22/09/2021
/*/
//-------------------------------------------------------------------
Static Function J298IncAnx(cCodAnd, aArquivos, cCajuri)

Local oRest     := Nil
Local aHeader   := {}
Local nArq      := 0
Local nQtdArqs  := 0
Local cPath     := ""
Local cNomeArq  := ""
Local cDownload := ""
Local nHandle   := ""
Local cErros    := ""
Local lErro     := .F.
Local cTemp     := MsDocPath() + "\andamentos\"

	If Len(aArquivos) > 0
		nQtdArqs  := Len(aArquivos)

		If nQtdArqs > 0
			//Não é necessario passar o host porque o SetPath tera o caminha absoluto
			oRest := FWRest():New("")
		EndIf

		For nArq := 1 To nQtdArqs
			Conout( I18n(STR0003, {cValToChar(nArq) + "/" + cValToChar(nQtdArqs), cCodAnd}) ) //"Baixando arquivos #1 - Andamento: #2"
			lErro    := .F.
			cNomeArq := AllTrim( aArquivos[nArq][1] )
			cPath    := FWURIEncode( aArquivos[nArq][2] )

			//Verifica se já existe o arquivos
			If !J26aExiNum("NT4", xFilial("NT4"), cCodAnd, cNomeArq)

				oRest:SetPath(cPath)
				If oRest:Get(aHeader)

					// Download do arquivo
					cDownload := oRest:GetResult()

					// Verifica se diretorio temporario existe
					If !JurMkDir(cTemp)
						lErro := .T.
					EndIf

					// Grava arquivo no servidor
					If !lErro .And. ( nHandle := FCreate(cTemp + cNomeArq, FC_NORMAL) ) < 0
						lErro := .T.
					EndIf

					If !lErro
						If FWrite(nHandle, cDownload) < Len(cDownload)
							lErro := .T.
						EndIf

						If !lErro .And. !FClose(nHandle)
							lErro := .T.
						EndIf
					EndIf

					If lErro
						cErros += " - " + J026aErrAr( FError() ) + " - " + cPath + CRLF
					Else

						//Anexa documento ao processo
						aRetAnx := J026Anexar("NT4", xFilial("NT4"), cCodAnd, cCajuri, cTemp + cNomeArq)

						If aRetAnx[1]
							FErase(cTemp + cNomeArq)
						Else
							cErros += " - " + aRetAnx[2] + " - " + cPath + CRLF
						EndIf
					EndIf

				Else
					If VALTYPE(oRest:CINTERNALERROR) <> "U"
						lErro := .T.
						cErros := I18n(STR0005 + cNomeArq + CRLF) // 'Não foi possível fazer o download do arquivo: '
						cErros += I18n(STR0006 + oRest:CINTERNALERROR + CRLF) // 'Erro: ' 
						cErros += I18n(STR0007 + cCajuri + ' / ' + STR0008 + cCodAnd + CRLF) // 'Cajuri: '  // 'Cód. andamento: '
						JurConout( cErros )
					EndIf
				EndIf

			Endif
		Next nArq
	EndIf

	FwFreeObj(oRest)

Return { lErro, cErros }

//-------------------------------------------------------------------
/*/{Protheus.doc} J298PdfToText( cFileName, cPath )
Prepara os dados para transformar um arquivo pdf em txt

@param  cFileName - Nome do arquivo
@param  cPath     - Link do arquivo
@return cBody     - Conteúdo em txt
@since 23/09/2021
/*/
//-------------------------------------------------------------------
Static Function J298PdfToText( cFileName, cPath )

Local oRest       := Nil
Local aHeader     := {}
Local nTamArquivo := 0
Local nHDestino   := 0
Local cFile       := ""
Local cArquivo    := ""
Local cBody       := ""
Local cSpool      := "\spool\"

	// Tratamento para S.O Linux
	If "Linux" $ GetSrvInfo()[2]
		cSpool := StrTran(cSpool,"\","/")
	EndIf

	oRest := FWRest():New("")
	oRest:SetPath(cPath)

	If oRest:Get(aHeader)

		cFile := oRest:GetResult()
		nTamArquivo := Len(cFile)
		cArquivo    := cSpool + cFileName
		nHDestino   := FCREATE(cArquivo)
		FWRITE(nHDestino, cFile, nTamArquivo)
		FCLOSE(nHDestino)

		cBody := J268PdfTxt(cFileName, .T.)
		FErase(cArquivo)
	EndIf

	FwFreeObj(oRest)

Return IIF( VALTYPE(cBody) <> "C", "", cBody )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAndamentos(cCajuri)
Função que faz a busca de andamentos já cadastrados na NIP

@param cCajuri - Código na NIP
@return aRet   - Array com a resumo de cada andamento
@since 01/10/2021
/*/
//-------------------------------------------------------------------
Static Function GetAndamentos(cCajuri)
Local aRet   := {}
Local cQuery := ""

	cQuery := " SELECT NT4_RESUMO FROM " + RetSQLName("NT4") + " NT4 "
	cQuery += " WHERE NT4.NT4_FILIAL = '" + xFilial("NT4") + "' "
	cQuery +=      " AND NT4.NT4_CAJURI = '" + cCajuri + "' "
	cQuery +=      " AND NT4.D_E_L_E_T_ = ' ' "

	aRet := JURSQL(cQuery, "*")

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ColetaNips(cEndPoint, aHeader)
Função que retorna as NIPS

@param cEndPoint    - https://clientenips.azurewebsites.net/api
	   aHeader      - Header com a authorization
@return oResponse   - Resposta com o json
@since 28/10/2021
/*/
//-------------------------------------------------------------------
Static Function ColetaNips(cEndPoint, aHeader)
Local oRest      := Nil
Local oResponse  := JsonObject():New()

	oRest := FWRest():New(cEndPoint)
	oRest:SetPath('/apigetprocessos')
	If oRest:Get(aHeader)
		oResponse:fromJson(oRest:GetResult())
	EndIf

Return oResponse
