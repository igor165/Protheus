#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM036.CH"

Static cVersEnvio	:= "2.4"
Static lMiddleware	:= If (cPaisLoc == 'BRA' .And. Findfunction("fVerMW"), fVerMW(), .F.)

/*/{Protheus.doc} GPEM036E
@Author   Alessandro Santos
@Since    18/03/2019
@Version  1.0
@Obs      Migrado do GPEM036 em 15/04/2019 para gerar o evento S-1295
/*/
Function GPEM036E()
Return()

/*/{Protheus.doc} fNew1295
Função responsável por gerar o evento S-1295 - Solicitação de Totalização para Pagamento em Contingência
@Author.....: Marcos Coutinho
@Since......: 06/10/2017
@Version....: 1.0
@Param......: (char) - cComp - Competencia desejada
@Param......: (char) - cFilEnv - Filial de envio
@Param......: (bool) -lIndic13 - Informa se é referente a 13º ou não
@Param......: (char) - cVersEnvio - Versão de envio
@Param......: (char) - cNome - Nome do Responsável
@Param......: (char) - cCPF - CPF do Responsavel
@Param......: (char) - cFone - Telefone do Responsável
@Param......: (char) - cEmail - Email do Responsável
@Param......: (array) - aLogs - Array de referencia para armazenamento de log
@Param......: (array) - aFil - Array de filiais
@Return.....: (bool) - lGravou - Retorno lógico se foi integrado com sucesso ou não
/*/
Function fNew1295(cComp, cFilEnv, lIndic13, cVersEnvio, cNome, cCPF, cFone, cEmail, aLogs, aFil)

	Local cXml			:= ""
	Local lGravou		:= .T.
	Local cPerApur		:= ""
	Local aErros		:= {}
	Local aInfoC		:= {}
	Local cChaveMid		:= ""
	Local cSta1000		:= ""
	Local cSta1295		:= ""
	Local nRecRJE		:= 0
	Local cOperNew		:= ""
	Local lNovoRJE		:= .T.
	Local cRetfRJE	 	:= ""
	Local cOperNew 	 	:= ""
	Local aDados		:= {}
	Local cTpInsc		:= ""
	Local cNRInsc		:= ""
	Local lAdmPubl		:= .F.
	Local cIdXml		:= ""
	Local cVersMW		:= ""
	Local lNT15			:= .F.
	Local cS1200		:= .F.
	Local cOperRJE	 	:= "I"
	Local lContinua		:= .F.
	Local nI			:= 0
	Local lS1000		:= .T.
	Local cStaS1000		:= "-1"
	Local lRet			:= .T.

	Default cComp		:= ""
	Default cFilEnv 	:= ""
	Default lIndic13 	:= .F.
	Default cVersEnvio	:= "2.2"
	Default cNome		:= ""
	Default cCPF		:= ""
	Default cFone		:= ""
	Default cEmail		:= ""

	//--------------------------------------------------
	//| Tratando o periodo de apuração: Anual ou Mensal
	//| Mensal(1).: Se lIndic13 == .F. | cPerApur = AAAA-MM
	//| Anual (2).: Se lIndic13 == .T. | cPerApur = AAAA
	//------------------------------------------------------
	If (lIndic13)
		cPerApur := SubStr(cComp, 1, 4)
	Else
		cPerApur := SubStr(cComp, 1, 4) + "-" + SubStr(cComp, 5, 2)
	EndIf

	If !Empty(cFilEnv)
		If lMiddleware
			fVersEsoc("S1295", .F., Nil, Nil, Nil, Nil, @cVersMW, @lNT15)
			aInfoC   := fXMLInfos()

			If Len(aInfoC) >= 4
				cTpInsc		:= aInfoC[1]
				cIdXml		:= aInfoC[3]
				lAdmPubl	:= aInfoC[4]
				cNrInsc		:= Padr(Iif(!lAdmPubl .And. cTpInsc == "1", SubStr(aInfoC[2], 1, 8), aInfoC[2]), 14)
			Else
				cTpInsc		:= ""
				lAdmPubl	:= .F.
				cNrInsc		:= Padr(Iif(!lAdmPubl .And. cTpInsc == "1", SubStr("0", 1, 8), "0"), 14)
				cId			:= ""
			EndIf

			cXml := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTotConting/v" + cVersMW + "'>"
			cXml += "	<evtTotConting  Id='" + cIdXml + "'>"
			fXMLIdEve( @cXML, { Nil, Nil, Iif(lIndic13, "2", "1"), cPerApur, "2", 1, "12" } )//<ideEvento>
			fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )//<ideEmpregador>
		Else
			cXml := '<eSocial>'
			cXml += '	<evtTotConting>'
			cXml += "		<ideEvento>"
			cXml += "			<indApuracao>" + Iif(lIndic13, "2", "1") + "</indApuracao>"
			cXml += "			<perApur>" + cPerApur + "</perApur>"
			cXml += "		</ideEvento>"
		EndIf
		cXml += "		<ideRespInf>"
		cXml += "			<nmResp>" + cNome + "</nmResp>"
		cXml += "			<cpfResp>" + cCPF + "</cpfResp>"
		cXml += "			<telefone>" + cFone + "</telefone>"
		cXml += "			<email>" + cEmail + "</email>"
		cXml += "		</ideRespInf>"
		cXml += "	</evtTotConting>"
		cXml += "</eSocial>"
	EndIf

	GrvTxtArq(cXml, "S1295")

	cPerApur := StrTran(cPerApur, "-", "")

	// REALIZA A INTEGRAÇÃO
	If !lMiddleware
		aErros := TafPrepInt(cEmpAnt, cFilEnv, cXml,, "1", "S1295")
	Else
		// VERIFICA SE JA EXISTE O EVENTO S1295 NA BASE DE DADOS (RJE_TPINSC + RJE_INSCR + RJE_EVENTO + RJE_KEY + RJE_INI + DTOS(RJE_DTG))
		cChave		:= cTpInsc + cNrInsc + "S1295" + Padr(cFilEnv + cPerApur + Iif(lIndic13, "2", "1"), fTamRJEKey(), " ") + cPerApur
		cSta1295	:= "-1"

		cS1200		:= fRegRJE(cFilEnv, cTpInsc, cNrInsc, "S1200", cComp + Iif(lIndic13, "2", "1"), @ aErros)
		lS1000		:= fVld1000(cPerApur, @cStaS1000)

		If !lS1000
			Do Case
				// NAO ENCONTRADO NA BASE DE DADOS
				Case cStaS1000 == "-1"
					aAdd(aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0161) )//"Registro do evento X-XXXX não localizado na base de dados"
					lGravou	:= .F.

				// NAO ENVIADO PARA O GOVERNO
				Case cStaS1000 == "1"
					aAdd(aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0162) )//"Registro do evento X-XXXX não transmitido para o governo"
					lGravou	:= .F.

				// ENVIADO E AGUARDANDO RETORNO DO GOVERNO
				Case cStaS1000 == "2"
					aAdd(aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0163) )//"Registro do evento X-XXXX aguardando retorno do governo"
					lGravou	:= .F.

				// ENVIADO E RETORNADO COM ERRO
				Case cStaS1000 == "3"
					aAdd(aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0164) )//"Registro do evento X-XXXX retornado com erro do governo"
					lGravou	:= .F.
			EndCase
		EndIf

		lRet		:= fRet1295(cFilEnv, @ aErros, cTpInsc, cNrInsc, Padr(cFilEnv + cPerApur + Iif(lIndic13, "2", "1"), 40, " "))
		lContinua	:= lS1000 .And. lRet .And. cS1200 == "S"

		// VALIDA SE SEGUE COM A GRAVAÇÃO DO REGISTRO NA RJE.
		If lContinua
			// BUSCA O STATUS DO EVENTO S-1295 NA TABELA RJE
			GetInfRJE(2, cChave, @cSta1295, @cOperRJE, @cRetfRJE, @nRecRJE)

			If cSta1295 == "2"
				lGravou := .F.
				aAdd(aErros, OemToAnsi(STR0173))//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"

			ElseIf cSta1295 == "4" .And. !lRet
				lGravou := .F.
				aAdd(aErros, OemToAnsi(STR0174) + cPerApur + OemToAnsi(STR0175))//"Operação não sera realizada pois  o evento de fechamento da competencia: "+cPerApur + " Ja foi transmitido anteriormente"

			ElseIf cSta1295 == "-1"
				cOperNew 	:= "I"
				cRetfNew	:= "1"
				cStatNew	:= "1"
				lNovoRJE	:= .T.

			ElseIf cSta1295 $ "1/3"
				cOperNew 	:= "I"
				cRetfNew	:= "1"
				cStatNew	:= "1"
				lNovoRJE	:= .F.
			Endif

			aAdd(aDados, {xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, cNrInsc, "S1295", cComp, cFilEnv + cPerApur + Iif(lIndic13, "2", "1"), cIdXml, "1", "12", "1", Date(), Time(), cOperNew, NIL, NIL})
			If !(fGravaRJE(aDados, cXML, lNovoRJE, nRecRJE))
				aAdd(aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na gravação do registro na tabela RJE"
			EndIf
		EndIf
	EndIf

	// VERIFICA SE ENCONTROU ALGUM ERRO
	If Len(aErros) > 0
		lGravou := .F.
		aAdd(aLogs, OemToAnsi(STR0046) + OemToAnsi(STR0170))
		aAdd(aLogs, "" )

		For nI := 1 To Len(aErros)
			cMsgErro := ""
			FeSoc2Err(aErros[nI], @cMsgErro, Iif(aErros[nI] != '000026', 1, 2))
			FormText(@cMsgErro)
			aErros[nI] := cMsgErro
			aAdd(aLogs, aErros[nI])
		Next nI
	Else
		lGravou := .T.
		aAdd(aLogs, OemToAnsi(STR0017)) //##"Evento gerado com sucesso."
		aAdd(aLogs, "" )
	Endif

Return lGravou

//------------------------------------------------------------------
/*/{Protheus.doc} fRet1295
Funcao que retorna a quantidade de registros para o evento S-1295
para o periodo na tabela RJE.

@author		Silvio C. Stecca
@since		19/11/2019
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fRet1295(cFilRJE, aErros, cTpIns, cInsc, cKeyRJE)

	Local lOk		:= .T.
	Local aArea		:= GetArea()
	Local cAliasRJE := GetNextAlias()
	Local cEvento	:= "S1295"
	Local nTamFil   := GetSx3Cache("RJE_FIL","X3_TAMANHO")
	Local nTamChave := nTamFil+7

	BeginSql Alias cAliasRJE
	     SELECT COUNT(*) AS QTD1295
	     FROM %TABLE:RJE% RJE
	     WHERE RJE_FIL= %Exp:cFilRJE%
	     AND RJE_TPINSC = %exp:cTpIns%
	     AND RJE_INSCR = %exp:cInsc%
	     AND RJE_EVENTO = %exp:cEvento%
	     AND RJE_FILIAL = %exp:xFilial("RJE", cFilAnt)%
	     And Substring(RJE_KEY,1,%exp:nTamChave%) = %exp:alltrim(cKeyRJE)%
	     AND RJE_STATUS = %exp:'4'%
	     AND RJE.%notDel%
	EndSql

	If (cAliasRJE)->(!Eof())
		If !(lOk := Iif((cAliasRJE)->QTD1295 < 3, .T., .F.))
			aAdd(aErros, OemToAnsi(STR0172) + Alltrim(SubStr(cKeyRJE, 9, 6)))
		EndIf
	EndIf

	If Select(cAliasRJE) > 0
		(cAliasRJE)->(dbCloseArea())
	EndIf

	RestArea(aArea)

Return lOk

//------------------------------------------------------------------
/*/{Protheus.doc} fNew1298
Funcao que gera o evento S-1298

@author		Silvio C. Stecca
@since		19/11/2019
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Function fNew1298(cComp, cFilEnv, lIndic13, cVersEnvio, cNome, cCPF, cFone, cEmail, aLogs, aFil)

	Local cXml			:= ""
	Local lGravou		:= .T.
	Local cPerApur		:= ""
	Local aErros		:= {}
	Local aInfoC		:= {}
	Local cChaveMid		:= ""
	Local cSta1000		:= ""
	Local cSta1298		:= ""
	Local nRecRJE		:= 0
	Local cOperNew		:= ""
	Local lNovoRJE		:= .T.
	Local cRetfRJE	 	:= ""
	Local cOperNew 	 	:= ""
	Local aDados		:= {}
	Local cTpInsc		:= ""
	Local cNRInsc		:= ""
	Local lAdmPubl		:= .F.
	Local cIdXml		:= ""
	Local cVersMW		:= ""
	Local lNT15			:= .F.
	Local cS1200		:= .F.
	Local cOperRJE	 	:= "I"
	Local lContinua		:= .F.
	Local nI			:= 0
	Local lS1000		:= .T.
	Local cStaS1000		:= "-1"
	Local cGpeAmbe		:= ""
	Local lPesFis		:= .F.

	Default cComp		:= ""
	Default cFilEnv 	:= ""
	Default lIndic13 	:= .F.
	Default cVersEnvio	:= "2.2"
	Default cNome		:= ""
	Default cCPF		:= ""
	Default cFone		:= ""
	Default cEmail		:= ""

	//--------------------------------------------------
	//| Tratando o periodo de apuração: Anual ou Mensal
	//| Mensal(1).: Se lIndic13 == .F. | cPerApur = AAAA-MM
	//| Anual (2).: Se lIndic13 == .T. | cPerApur = AAAA
	//------------------------------------------------------
	If (lIndic13)
		cPerApur := SubStr(cComp, 1, 4)
	Else
		cPerApur := SubStr(cComp, 1, 4) + "-" + SubStr(cComp, 5, 2)
	EndIf

	If lMiddleware
		If !Empty(cFilEnv)
			fVersEsoc("S1298", .F., Nil, Nil, Nil, Nil, @cVersMW, @lNT15, @cGpeAmbe)

			aInfoC   := fXMLInfos()

			If Len(aInfoC) >= 4
				cTpInsc		:= aInfoC[1]
				cIdXml		:= aInfoC[3]
				lAdmPubl	:= aInfoC[4]
				cNrInsc		:= Padr(Iif(!lAdmPubl .And. cTpInsc == "1", SubStr(aInfoC[2], 1, 8), aInfoC[2]), 14)
				lPesFis		:= If(Len(aInfoC)>=5, aInfoC[5] $ '21|22', .F.)
			Else
				cTpInsc		:= ""
				lAdmPubl	:= .F.
				cNrInsc		:= Padr(Iif(!lAdmPubl .And. cTpInsc == "1", SubStr("0", 1, 8), "0"), 14)
				cId			:= ""
			EndIf

			cXml := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtReabreEvPer/v" + cVersMW + "'>"
			cXml += "	<evtReabreEvPer Id='" + cIdXml + "'>"

			fXMLIdEve( @cXML, {Nil, Nil, Iif(lIndic13, "2", "1"), cPerApur, cGpeAmbe, 1, "12"},If(lPesFis,cVersEnvio,Nil) )
			fXMLIdEmp( @cXML, {cTpInsc, Alltrim(cNrInsc)})

			cXml += "	</evtReabreEvPer>"
			cXml += "</eSocial>"
		EndIf

		GrvTxtArq(cXml, "S1298")

		cPerApur := StrTran(cPerApur, "-", "")

		// VERIFICA SE JA EXISTE O EVENTO S1298 NA BASE DE DADOS (RJE_TPINSC + RJE_INSCR + RJE_EVENTO + RJE_KEY + RJE_INI + DTOS(RJE_DTG))
		cChave		:= cTpInsc + cNrInsc + "S1298" + Padr(cFilEnv + cPerApur + Iif(lIndic13, "2", "1"), fTamRJEKey(), " ") + cPerApur
		cSta1298	:= "-1"
		cS1299		:= fRegRJE(cFilEnv, cTpInsc, cNrInsc, "S1299", cFilEnv + cComp + Iif(lIndic13, "2", "1"), @ aErros)
		lS1000		:= fVld1000(cPerApur, @cSta1000)

		If !lS1000
			Do Case
				// NAO ENCONTRADO NA BASE DE DADOS
				Case cStaS1000 == "-1"
					aAdd(aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0161) )//"Registro do evento X-XXXX não localizado na base de dados"
					lGravou	:= .F.

				// NAO ENVIADO PARA O GOVERNO
				Case cStaS1000 == "1"
					aAdd(aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0162) )//"Registro do evento X-XXXX não transmitido para o governo"
					lGravou	:= .F.

				// ENVIADO E AGUARDANDO RETORNO DO GOVERNO
				Case cStaS1000 == "2"
					aAdd(aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0163) )//"Registro do evento X-XXXX aguardando retorno do governo"
					lGravou	:= .F.

				// ENVIADO E RETORNADO COM ERRO
				Case cStaS1000 == "3"
					aAdd(aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0164) )//"Registro do evento X-XXXX retornado com erro do governo"
					lGravou	:= .F.
			EndCase
		EndIf

		// DEVE-SE EXISTIR UM EVENTO S-1000 E S-1299 PARA QUE SEJA POSSIVEL ENVIAR UM NOVO REGISTRO DO S-1298
		lContinua	:= lS1000 .And. cS1299 == "S"

		// VALIDA SE SEGUE COM A GRAVAÇÃO DO REGISTRO NA RJE.
		If lContinua
			// BUSCA O STATUS DO EVENTO S-1298 NA TABELA RJE
			GetInfRJE(2, cChave, @cSta1298, @cOperRJE, @cRetfRJE, @nRecRJE)

			If cSta1298 == "2"
				lGravou := .F.
				aAdd(aErros, OemToAnsi(STR0173))//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"

			ElseIf cSta1298 == "4"
				lGravou := .F.
				aAdd(aErros, OemToAnsi(STR0174) + cPerApur + OemToAnsi(STR0175))//"Operação não sera realizada pois  o evento de fechamento da competencia: "+cPerApur + " Ja foi transmitido anteriormente"

			ElseIf cSta1298 == "-1"
				cOperNew 	:= "I"
				cRetfNew	:= "1"
				cStatNew	:= "1"
				lNovoRJE	:= .T.

			ElseIf cSta1298 $ "1/3"
				cOperNew 	:= "I"
				cRetfNew	:= "1"
				cStatNew	:= "1"
				lNovoRJE	:= .F.
			Endif

			aAdd(aDados, {xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, cNrInsc, "S1298", cComp, cFilEnv + cPerApur + Iif(lIndic13, "2", "1"), cIdXml, "1", "12", "1", Date(), Time(), cOperNew, NIL, NIL})
			If !(fGravaRJE(aDados, cXML, lNovoRJE, nRecRJE))
				aAdd(aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na gravação do registro na tabela RJE"
			EndIf
		EndIf
	EndIf

	// VERIFICA SE ENCONTROU ALGUM ERRO
	If Len(aErros) > 0
		lGravou := .F.
		aAdd(aLogs, OemToAnsi(STR0046) + OemToAnsi(STR0176))
		aAdd(aLogs, "" )

		For nI := 1 To Len(aErros)
			cMsgErro := ""
			FeSoc2Err(aErros[nI], @cMsgErro, Iif(aErros[nI] != '000026', 1, 2))
			FormText(@cMsgErro)
			aErros[nI] := cMsgErro
			aAdd(aLogs, aErros[nI])
		Next nI
	Else
		lGravou := .T.
		aAdd(aLogs, OemToAnsi(STR0017)) //##"Evento gerado com sucesso."
		aAdd(aLogs, "" )
	Endif

Return lGravou
