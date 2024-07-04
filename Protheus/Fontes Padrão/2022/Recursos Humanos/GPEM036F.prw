#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM036.CH"

Static cVersEnvio:= "2.4"
Static lMiddleware  := If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM036F
@Author   Alessandro Santos 
@Since    18/03/2019 
@Version  1.0 
@Obs      Migrado do GPEM036 em 15/04/2019 para gerar o evento S-1299
/*/
Function GPEM036F()
Return()

/*/{Protheus.doc} fNew1299
Função responsável por gerar o evento S-1299 - Fechamento dos Eventos Periódicos
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
Function fNew1299(cComp, cFilEnv, lIndic13, cVersEnvio, cNome, cCPF, cFone, cEmail, aLogs, aFil)
Local aArea			:= GetArea()
Local cXml			:= ""
Local lGravou		:= .T.
Local cPerApur		:= ""
Local aErros		:= {}
Local nI 			:= 1

Local cEvtRemun		:= "N" //<evtRemun>        | S-1200 | C91
Local cEvtPgtos		:= "N" //<evtPgtos>        | S-1210 | T3P
Local cEvtAqProd	:= "N" //<evtAqProd>       | S-1250 | CMR
Local cEvtComPro	:= "N" //<evtComProd>      | S-1260 | T1M
Local cEvtContra	:= "N" //<evtContratAvNP>  | S-1270 | T2A
Local cEvtInfoCo	:= "N" //<evtInfoComplPer> | S-1280 | T3V
Local cCompSemMo	:= "N"

Local lEvtRemun		:= .F. //<evtRemun>        | S-1200 | C91
Local lEvtPgtos		:= .F. //<evtPgtos>        | S-1210 | T3P
Local lEvtAqProd	:= .F. //<evtAqProd>       | S-1250 | CMR
Local lEvtComPro	:= .F. //<evtComProd>      | S-1260 | T1M
Local lEvtContra	:= .F. //<evtContratAvNP>  | S-1270 | T2A
Local lEvtInfoCo	:= .F. //<evtInfoComplPer> | S-1280 | T3V
Local lCompSemMo	:= .F.
Local cAuxPer		:= ""

Local lAdmPubl	 	:= .F.
Local aInfos	 	:= {}
Local aDados	 	:= {}
Local cTpInsc		:= ""
Local cNrInsc		:= ""
Local cChaveMid	 	:= ""	
Local cStat1299   	:= "-1"
Local cChave1299    := ""
Local cStat1280   	:= "-1"
Local cChave1280    := ""
Local cVersMw	 	:= ""
Local lNT15			:= .F.
Local cId			:= ""
Local cOperNew 		:= "I"
Local cRetfNew		:= "1"
Local cStatNew		:= "1"
Local lNovoRJE		:= .T.
Local dDtGer	 	:= Date()
Local cHrGer	 	:= Time()
Local lS1000 	 	:= .T.
Local cStatus	 	:= "-1"
Local nRecRJE  	 	:= 0
Local cChave		:= ""
Local cGpeAmbe		:= ""
Local cStat1298		:= "-1"
Local cChave1298    := ""
Local nRec1298 	 	:= 0
Local lPesFisica	:= .F.

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
If ( lIndic13 )
	cPerApur := SubStr(cComp, 1, 4)
	cAuxPer := cPerApur
Else
	cPerApur := SubStr(cComp, 1, 4) + "-" + SubStr(cComp, 5, 2)
	cAuxPer := cComp
EndIf

If !lMiddleware
	//---------------------------------------
	//| Tratando o <evtRemun> | S-1200 | C91
	//---------------------------------------
	DbSelectArea("C91")
	C91->(DbSetOrder(2)) //Filial + IndApu (Se folha ou 13º) + PerApu
	
	DbSelectArea("T3P")
	T3P->(DbSetOrder(2)) //Filial + IndApu (Se folha ou 13º) + PerApu
	
	DbSelectArea("CMR")
	CMR->(DbSetOrder(2)) //Filial + IndApu (Se folha ou 13º) + PerApu
	
	DbSelectArea("T1M")
	T1M->(DbSetOrder(2)) //Filial + IndApu (Se folha ou 13º) + PerApu
	
	DbSelectArea("T2A")
	T2A->(DbSetOrder(2)) //Filial + IndApu (Se folha ou 13º) + PerApu
	
	DbSelectArea("T3V")
	T3V->(DbSetOrder(4)) //Filial + IndApu (Se folha ou 13º) + PerApu
Else
	DbSelectArea("RJE")
	RJE->(DbSetOrder(2)) //RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
Endif	

For nI := 1 to Len(aFil)
	lGravou := .T.
	aDados	:= {}
	cEvtRemun		:= "N" //<evtRemun>        | S-1200 | C91
	cEvtPgtos		:= "N" //<evtPgtos>        | S-1210 | T3P
	cEvtInfoCo		:= "N" //<evtInfoComplPer> | S-1280 | T3V

	cCompSemMo		:= "N"
	cFilEnv := aFil[nI][1]

	If !Empty(cFilEnv)
		lPesFisica	:= fGM36PFisica(cFilEnv)
	Endif	
	
	If !lMiddleware 
		cEvtAqProd		:= "N" //<evtAqProd>       | S-1250 | CMR
		cEvtComPro		:= "N" //<evtComProd>      | S-1260 | T1M
		cEvtContra		:= "N" //<evtContratAvNP>  | S-1270 | T2A
	
		//Procurando o registro nas tabelas do TAF
		lEvtRemun := fTemReg(aFil[nI][3],"C91",Iif( lIndic13, "2", "1" ) + cAuxPer)
		
		//Verifica se encontrou. Verifica o Status do registro. Define Valor
		If ( lEvtRemun )
			fExstReg("C91", @cEvtRemun, @lEvtRemun, cAuxPer )
		EndIf
		
		//---------------------------------------
		//| Tratando o <evtPgtos> | S-1210 | T3P
		//---------------------------------------
		
		//Procurando o registro nas tabelas do TAF
		lEvtPgtos := fTemReg(aFil[nI][3],"T3P",Iif( lIndic13, "2", "1" ) + cAuxPer)
		
		//Alimentando a variavel baseado no retorno do banco
		If ( lEvtPgtos )
			fExstReg("T3P", @cEvtPgtos, @lEvtPgtos, cAuxPer)
		EndIf
	
		//-----------------------------------------
		//| Tratando o <evtAqProd> | S-1250 | CMR
		//----------------------------------------
		
		//Procurando o registro nas tabelas do TAF
		lEvtAqProd :=fTemReg(aFil[nI][3],"CMR",Iif( lIndic13, "2", "1" ) + cAuxPer)
		
		//Alimentando a variavel baseado no retorno do banco
		If ( lEvtAqProd )
			fExstReg("CMR", @cEvtAqProd, @lEvtAqProd, cAuxPer)
		EndIf
		
		//-----------------------------------------
		//| Tratando o <evtComProd> | S-1260 | T1M
		//-----------------------------------------
		
		//Procurando o registro nas tabelas do TAF
		lEvtComPro :=fTemReg(aFil[nI][3],"T1M",Iif( lIndic13, "2", "1" ) + cAuxPer)
		
		//Alimentando a variavel baseado no retorno do banco
		If ( lEvtComPro )
			fExstReg("T1M", @cEvtComPro, @lEvtComPro, cAuxPer)
		EndIf
		
		//---------------------------------------------
		//| Tratando o <evtContratAvNP> | S-1270 | T2A
		//---------------------------------------------
	
		//Procurando o registro nas tabelas do TAF
		lEvtContra := fTemReg(aFil[nI][3],"T2A",Iif( lIndic13, "2", "1" ) + cAuxPer)
		
		//Alimentando a variavel baseado no retorno do banco
		If ( lEvtContra )
			fExstReg("T2A", @cEvtContra, @lEvtContra, cAuxPer)
		EndIf
		
		//----------------------------------------------
		//| Tratando o <evtInfoComplPer> | S-1280 | T3V
		//----------------------------------------------
		
		//Procurando o registro nas tabelas do TAF
		lEvtInfoCo := fTemReg(aFil[nI][3],"T3V",Iif( lIndic13, "2", "1" ) + cAuxPer)
		
		//Alimentando a variavel baseado no retorno do banco
		If ( lEvtInfoCo )
			fExstReg("T3V", @cEvtInfoCo, @lEvtInfoCo, cAuxPer)
		EndIf
		//-------------------------------------------------
		//| Tratando o <compSemMovto> | Caso todos sejam N //Leiaute anterior a S-1.0
		//-------------------------------------------------
		If cVersEnvio < "9.0.00"
			lCompSemMo := (cEvtRemun == "N" .AND. cEvtPgtos == "N" .AND. cEvtAqProd == "N" .AND.  cEvtComPro == "N" .AND. cEvtContra == "N" .AND. cEvtInfoCo == "N")
		EndIf
	Else
		fVersEsoc("S1299", .F., Nil, Nil, Nil, Nil, @cVersMW, @lNT15, @cGpeAmbe)
		fPosFil( cEmpAnt, cFilEnv )
		lS1000 := fVld1000( cAuxPer, @cStatus )

		If !lS1000 
			Do Case 
				Case cStatus == "-1" // nao encontrado na base de dados
					aAdd( aLogs, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0161) )//"Registro do evento X-XXXX não localizado na base de dados"
					lGravou	:= .F.
				Case cStatus == "1" // nao enviado para o governo
					aAdd( aLogs, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0162) )//"Registro do evento X-XXXX não transmitido para o governo"
					lGravou	:= .F.
				Case cStatus == "2" // enviado e aguardando retorno do governo
					aAdd( aLogs, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0163) )//"Registro do evento X-XXXX aguardando retorno do governo"
					lGravou	:= .F.
				Case cStatus == "3" // enviado e retornado com erro 
					aAdd( aLogs, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0164) )//"Registro do evento X-XXXX retornado com erro do governo"
					lGravou	:= .F.
			EndCase
		EndIf
		
		aInfos   := fXMLInfos()
									
		IF Len(aInfos) >= 4
			cTpInsc		:= aInfos[1]
			lAdmPubl	:= aInfos[4]
			cNrInsc		:= Padr(Iif(!lAdmPubl .And. cTpInsc == "1", SubStr(aInfos[2], 1, 8), aInfos[2]), 14)
			cId			:= aInfos[3]
		Else
			cTpInsc		:= ""
			lAdmPubl	:= .F.
			cNrInsc		:= Padr(Iif(!lAdmPubl .And. cTpInsc == "1", SubStr("0", 1, 8), "0"), 14)
			cId			:= ""
		EndIf
		
		cChaveMid	:= (cComp +  Iif(lIndic13, "2", "1"))
		cChave		:= (cAuxPer +  Iif(lIndic13, "2", "1"))
		cEvtRemun	:= fRegRJE(cFilEnv, cTpInsc, cNrInsc, "S1200", cChaveMid )
		cEvtPgtos	:= fRegRJE(cFilEnv, cTpInsc, cNrInsc, "S1210", cChaveMid )
		cChave1280	:= cTpInsc + cNrInsc + "S1280" + Padr(cFilEnv + cChaveMid, 40, " ")
		cStat1280 	:= "-1"
				
		GetInfRJE(2, cChave1280, @cStat1280)
		
		If cStat1280 == "4"
			cEvtInfoCo := "S"
		Endif
						
		cChave1299	:= cTpInsc + cNrInsc + "S1299" + Padr(cFilEnv + cChave, 40, " ")
		cStat1299 	:= "-1"
				
		GetInfRJE(2, cChave1299, @cStat1299,,, @nRecRJE)		
		
		If cStat1299 == "4"
			// Verifica existência de evento S-1298 posterior ao S-1299 encontrado
			cChave1298	:= cTpInsc + cNrInsc + "S1298" + Padr(cFilEnv + cChave, 40, " ")
			cStat1298 := "-1"
			GetInfRJE(2, cChave1298, @cStat1298,,, @nRec1298)
			If cStat1298 == "4" .And. nRec1298 > nRecRJE
				set1299Exc(nRecRJE) //Atualiza o evento S-1299: RJE_EXC = 1-Sim (Excluído)
				cStat1299 := "-1"
				nRecRJE := 0
			EndIf  
		EndIf

		If cStat1299 == "2" 
			lGravou := .F.
			aAdd( aLogs, OemToAnsi(STR0158 ) )//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
		ElseIf cStat1299 == "4"
			lGravou := .F.
			aAdd( aLogs, OemToAnsi(STR0168 ) + cPerApur + OemToAnsi(STR0169 )  )//"Operação não sera realizada pois  o evento de fechamento da competencia: "+cPerApur + " Ja foi transmitido anteriormente"
		ElseIf cStat1299 == "-1"
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		ElseIf cStat1299 $ "1/3"
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .F.
		Endif

		If lGravou
			aAdd(aDados, {xFilial("RJE", cFilAnt), cFilEnv, cTpInsc, cNrInsc, "S1299", cAuxPer, (cFilEnv + cChave), cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew})
		Endif

		//-------------------------------------------------
		//| Tratando o <compSemMovto> | Caso todos sejam N //Leiaute anterior a S-1.0
		//-------------------------------------------------
		If cVersEnvio < "9.0.00"
			lCompSemMo := (cEvtRemun == "N" .AND. cEvtPgtos == "N" .AND. cEvtInfoCo == "N")
		EndIf
	Endif
	
	If ( lCompSemMo )
		cCompSemMO:= fDlgPer()
		If Len(AllTrim(cCompSemMO)) < 7
			lGravou:= .F.
			aAdd(aLogs , "Filial : " + cFilEnv +  "Se faz necessário informar a primeira competência a partir da qual não houve movimento, cuja situação perdura até a competência atual.")
		EndIf
	EndIf
	
	If !Empty(cFilEnv) .And. lGravou
		If lMiddleware
			cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtFechaEvPer/v" + cVersMw + "'>"
			cXML += 	"<evtFechaEvPer Id='" + cId + "'>"

			fXMLIdEve(@cXML, {Nil, Nil, Iif(lIndic13, "2", "1"), cPerApur, cGpeAmbe, 1, "12"}, If(Len(aInfos) >= 5 .And. aInfos[5] $ "21*22", cVersEnvio,"") )
			fXMLIdEmp(@cXML, {cTpInsc, Alltrim(cNrInsc)})	
			If cVersEnvio < "9.0.00"
				cXml += "		<ideRespInf>"
				cXml += "			<nmResp>" + cNome + "</nmResp>"
				cXml += "			<cpfResp>" + cCPF + "</cpfResp>"
				cXml += "			<telefone>" + cFone + "</telefone>"
				cXml += "			<email>" + cEmail + "</email>"
				cXml += "		</ideRespInf>"
			EndIf
			cXml += "		<infoFech>
			cXml += "			<evtRemun>" + cEvtRemun + "</evtRemun>
			If cVersEnvio < "9.0.00"
				cXml += "		<evtPgtos>" + cEvtPgtos + "</evtPgtos>
				cXml += "		<evtAqProd>" + cEvtAqProd + "</evtAqProd>
			EndIf
			cXml += "			<evtComProd>" + cEvtComPro + "</evtComProd>
			cXml += "			<evtContratAvNP>" + cEvtContra + "</evtContratAvNP>
			cXml += "			<evtInfoComplPer>" + cEvtInfoCo + "</evtInfoComplPer>

			If lCompSemMo .And. cVersEnvio < "9.0.00"
				cXml += "			<compSemMovto>" + cCompSemMo + "</compSemMovto>
			EndIf
			If cVersEnvio >= "9.0.00" .And. cComp >= "202110" .And. If(Len(aInfos) >= 5 .And. aInfos[5] $ "21*22*04" ,.T.,.F.)
				cXml += "			<transDCTFWeb>" + "S" + "</transDCTFWeb>
			Endif	

			cXml += "		</infoFech>
			cXml += "	</evtFechaEvPer>"
			cXml += "</eSocial>"
		Else
			cXml := "<eSocial>"
			cXml += "	<evtFechaEvPer>"
			//cXml += "		<id></id>"
			cXml += "		<ideEvento>"
			cXml += "			<indApuracao>" + Iif(lIndic13, "2", "1") + "</indApuracao>"
			cXml += "			<perApur>" + cPerApur + "</perApur>"
			If cVersEnvio >= "9.0.00" .And. lPesFisica
				cXml += "			<indGuia>" + "1" + "</indGuia>"
			EndIf
			
			//cXml += "			<tpAmb></tpAmb>" 		//TAF responsável por enviar isto
			//cXml += "			<procEmi></procEmi>"	//TAF responsável por enviar isto
			//cXml += "			<verProc></verProc>"	//TAF responsável por enviar isto
			cXml += "		</ideEvento>"
			//cXml += "		<ideEmpregador>"
			//cXml += "			<tpInsc></tpInsc>"
			//cXml += "			<nrInsc></nrInsc>"
			//cXml += "		</ideEmpregador>"

			If cVersEnvio < "9.0.00"
				cXml += "		<ideRespInf>"
				cXml += "			<nmResp>" + cNome + "</nmResp>"
				cXml += "			<cpfResp>" + cCPF + "</cpfResp>"
				cXml += "			<telefone>" + cFone + "</telefone>"
				cXml += "			<email>" + cEmail + "</email>"
				cXml += "		</ideRespInf>"
			EndIf
			cXml += "		<infoFech>
			cXml += "			<evtRemun>" + cEvtRemun + "</evtRemun>
			If cVersEnvio < "9.0.00"
				cXml += "		<evtPgtos>" + cEvtPgtos + "</evtPgtos>
				cXml += "		<evtAqProd>" + cEvtAqProd + "</evtAqProd>
			EndIf
			cXml += "			<evtComProd>" + cEvtComPro + "</evtComProd>
			cXml += "			<evtContratAvNP>" + cEvtContra + "</evtContratAvNP>
			cXml += "			<evtInfoComplPer>" + cEvtInfoCo + "</evtInfoComplPer>
			If lCompSemMo .And. cVersEnvio < "9.0.00"
				cXml += "			<compSemMovto>" + cCompSemMo + "</compSemMovto>     
			EndIf
			If cVersEnvio >= "9.0.00" .And. cComp >= "202110" .And. lPesFisica
				cXml += "			<transDCTFWeb>" + "S" + "</transDCTFWeb>
			Endif	
			cXml += "		</infoFech>
			cXml += "	</evtFechaEvPer>"
			cXml += "</eSocial>"
		Endif	
	
		//Realiza a integração
		GrvTxtArq(alltrim(cXml), "S1299")
		
		If !lMiddleware
			aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S1299")
		Else
			If !( lGravou := fGravaRJE( aDados, cXml, lNovoRJE , nRecRJE) )
				cMsgLog := STR0155 //"Ocorreu um erro na gravação do registro na tabela RJE"
				Aadd(aErros, cMsgLog )
			Endif
		Endif
		//Verifica se encontrou algum erro
		If Len( aErros ) > 0
			lGravou := .F.
			aAdd(aLogs,  "Filial : " + cFilEnv + aErros[1] )
		Else
			lGravou := .T.
			aAdd(aLogs,  "Filial : " + cFilEnv + OemToAnsi(STR0017)) //##"Evento gerado com sucesso."
		Endif
	EndIf
Next nI

aAdd(aLogs, "") //Pular linha
RestArea(aArea)

Return lGravou

/*/{Protheus.doc} fTemReg
//Busca dados de acordo com tabela e chave
@author flavio.scorrea
@since 25/04/2019
/*/
Static Function fTemReg(aFilTmp,cTabela,cChave)
Local nI 	:= 1
Local nTam	:= Len(aFilTmp)
Local lRet	:= .F.
For nI := 1 To nTam	
	lRet := (cTabela)->(DbSeek( xFilial(cTabela,aFilTmp[nI]) + cChave ))
	If lRet
		Exit
	EndIf
Next nI
Return lRet

/*/{Protheus.doc} fExstReg(cTabela, cAchou, lAchou, cComp)
Função genérica que pesquisa ao menos um resultado com status "4"
@type  Static
@author Marcos Coutinho
@since 12/10/2017
@version 1.0
@param cTabela - Informa a tabela que será feita a pesquisa
@param cAchou - String alimentada por referência
@param lAchou - Boolean alimentado por referência
@param cComp - String com o periodo util para pesquisa
@return
/*/
Static Function fExstReg(cTabela, cAchou, lAchou, cComp)
Default cTabela	:= ""
Default cAchou		:= "N"
Default lAchou		:= .F.

dbSelectArea(cTabela)
//------------------------------------------
//| Confirma ao menos recebimento de tabela
//------------------------------------------
If( !Empty( cTabela ) )
	//------------------------------------------------------------
	//|Varre banco buscando ao menos 1 registro com status == "4"
	//|enquanto estiver no mesmo periodo de competencia
	//--------------------------------------------------
	While ALLTRIM(&(cTabela + "_PERAPU")) == cComp
		If &(cTabela + "_STATUS") == "4"
			cAchou := "S"
			Exit
		EndIf
		dbSkip()
	EndDo

	//Se não encontrou nada, lAchou atualiza para .F.
	Iif(cAchou == "N", lAchou := .F., lAchou := .T.)

Else
	cAchou := "N"
	lAchou := .F.
EndIf

Return

/*/{Protheus.doc} fDlgPer
Função para coletar competência a ser colocada no xml
@author Eduardo
@since 19/06/2018
@version 1.0
/*/
Function fDlgPer()
Local cCompet:= ""
Local aArea		:= GetArea()
Local cCompete	:= Space(7)
Local cTitle  	:= OemToAnsi("Competencia")
Local aObjCoords	:= {}
Local oFont
Local bFecha		:= {||nOpcA := 2, oDlg:End()}
Local bSet15		:= { ||Iif( fGpTdOk1(Alltrim(cCompete)),  oDlg:End() ,Nil ) }
Local bSet24		:= { || oDlg:End() }

Private oDlg	:= ""

aAdvSize		:= MsAdvSize( .F.,.F.,570)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }

aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize			:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO 150,370 PIXEL

@ aObjSize[1,1]*2.2, aObjSize[1,2]       SAY OemToAnsi(STR0030+CRLF+STR0031) SIZE 500,020 OF oDlg PIXEL //Competência (MMAAAA)
@ (aObjSize[1,1]*3.5), aObjSize[1,2]  MSGET cCompete SIZE 030,010	OF oDlg PIXEL WHEN .T. PICTURE "@R 9999-99"

ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )
cCompete := AllTrim(cCompete)
cCompete:= left(cCompete,4)+"-"+right(cCompete,2)

RestArea(aArea)

Return cCompete

/*/{Protheus.doc} fGpTdOk1
Validação de campo de competencia se é data válida
@author Eduardo
@since 19/06/2018
@version 1.0
@param cCompete, String, Competencia a ser validada
@return lRet, Lógico - .T. competência válida
/*/
Static Function fGpTdOk1(cCompete)
Local aArea			:= GetArea()
Local nErro			:= 0
Local nI			:= 0
Local lRet			:= .T.

lTela := .F.
If !fGp39MAno( Alltrim(cCompete), 2)
	Help( ,, OemToAnsi(STR0033) ,,OemToAnsi(STR0032), 1, 0 )//"Competencia inconsistente"
	lRet := .F.
	nErro := 1
Endif

RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} set1299Exc
Atualiza o registro como excluido (RJE_EXC = 1)
@author martins.marcio
@since 02/07/2021
@version 1.0
@param nRec1299, numeric, recno do registro a ser atualizado
/*/
Static Function set1299Exc(nRec1299)
Local aArea	:= GetArea()

RJE->(DbGoTo(nRec1299))
Reclock("RJE" , .F.)
RJE->RJE_EXC := "1"
RJE->(MsUnlock())

RestArea(aArea)
Return()

/*/{Protheus.doc} fGM36PFisica()
Função que verifica se a filial esta cadastrada como pessoa fisica e Segurado Especial
@type function
@author staguti
@since 10/08/2021
@version 1.0
@param cFilEnv= Filial Centralizadora
/*/
Static Function fGM36PFisica(cFilEnv)
	Local aArea			:= GetArea()
	Local lPFisica		:= .F.
	Local aInfo	 	 	:= {}

	Default cFilEnv	    := cFilAnt

	fInfo(@aInfo,cFilEnv)

	If Len(aInfo) > 0
		If aInfo[28] == 3 .And. Alltrim(aInfo[12]) == "3"  //M0_TPINSC //M0_PRODRUR
			lPFisica := .T.
		Endif	
	Endif
	
	RestArea(aArea)

Return lPFisica

