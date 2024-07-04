#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM026.CH"

Static lXmlVerbas	:= Val(SuperGetMv("MV_FASESOC",,'2')) == 2
Static nContRes		:= 0
Static lParcial		:= .F.
Static lGeraRat  	:= SuperGetMv("MV_RATESOC",, .T.)
Static lVerRJ5		:= FindFunction("fVldObraRJ") .And. (fVldObraRJ(@lParcial, .F.) .And. !lParcial)
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static dDtcgini		:= SuperGetMv("MV_DTCGINI", , cToD("//"))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM026C ³ Autor ³ Gabriel de Souza Almeida                    ³ Data ³ 04/01/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funções para envio de Aviso Prévio... ao TAF                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                       ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³Chamado³Motivo da Alteracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Gabriel A.   ³04/01/2016³                ³TUCT15 ³Criação da função inclusão e alteração de avi³±±
±±³             ³          ³                ³       ³so Prévio                                    ³±±
±±³Marcia Moura ³08/09/2016³                ³TVZVHZa ³Alteracao do evento, para que gere o codigo ³±±
±±³             ³          ³                ³        ³unico ao inves da matricula para identificar³±±
±±³             ³          ³                ³        ³o funcionario no TAF                        ³±±
±±³Marcos Cout. ³17/05/2017³ DRHESOCP-278   ³        ³Criação do evento S-2298 do eSocial - Reint ³±±
±±³Marcos Cout. ³26/05/2017³ DRHESOCP-282   ³        ³Criação do evento S-2299 do eSocial - Deslig³±±
±±³Marcos Cout. ³01/06/2017³ DRHESOCP-320   ³        ³Criação do evento S-2299 do eSocial         ³±±
±±³             ³          ³                ³        ³S-2299 - Desligamento Coletivo              ³±±
±±³Marcos Cout. ³02/06/2017³DRHESOCP-331    ³        ³Ajustes para geração de LOG. Evento         ³±±
±±³             ³          ³                ³        ³S-2299 - Desligamento Coletivo.             ³±±
±±³Eduardo Vice ³02/08/2017³DRHESOCP-744    ³        ³ Ajustes na chamada da Função fGp23Cons	  ³±±
±±³Eduardo V    ³11/08/2017³DRHESOCP-781    ³        ³Correções de erros apontadas a issue 592    ³±±
±±³Eduardo V    ³14/08/2017³DRHESOCP-866    ³        ³Declaração de Variaveis                     ³±±
±±³Marcos Cout  ³24/08/2017³DRHESOCP-868    ³        ³Realizado ajustes para gerar rescisão cor_  ³±±
±±³             ³          ³                ³        ³_retamente. Problema ao ponteirar a filial  ³±±
±±³Marcos Cout  ³25/08/2017³DRHESOCP-791    ³        ³Realizando ajustes para que o Aviso Previo  ³±±
±±³             ³          ³DRHESOCP-949    ³        ³seja gerado corretamente para funcionarios  ³±±
±±³             ³          ³                ³        ³de outras filiais que não sejam a matriz    ³±±
±±³Eduardo Vic  ³28/08/2017³DRHESOCP-871    ³        ³inclusão de tratativa quando exclusão 000026³±±
±±³Cecília C.   ³21/08/2017³DRHESOCP-736    ³        ³Gravação do campo RG_INDAV no registro      ³±±
±±³             ³          ³                ³        ³S-2299 - Desligamento.                      ³±±
±±³Eduardo Vic  ³30/08/2017³DRHESOCP-848    ³        ³Tratativa de quando é feito a exclusão da   ³±±
±±³Eduardo Vic  ³		   ³			    ³        ³linha com a ação de alteração				  ³±±
±±³Cecília C.   ³08/09/2017³DRHESOCP-1015   ³        ³Inclusão da TAG tpDep na geração do evento  ³±±
±±³             ³          ³                ³        ³S-2299 - Desligamento.                      ³±±
±±³Marcos Cout  ³04/09/2017³DRHESOCP-950    ³        ³Realizando a tratativa do FwModelPos do MVC ³±±
±±³             ³		   ³			    ³        ³da tela de Cadastro de Aviso Previo         ³±±
±±³Eduardo Vic  ³12/09/2017³DRHESOCP-963    ³        ³Tratada array aDadosRAZ corrigindo erro.    ³±±
±±³Marcos Cout  ³28/09/2017³DRHESOCP-1362   ³        ³Realizando ajustes necessários para integrar³±±
±±³             ³          ³                ³        ³a tag <indCumprParc> com o valor correto    ³±±
±±³             ³          ³                ³        ³Ajustes para layout 2.2 e 2.3               ³±±
±±³Cecília C.   ³05/10/2017³DRHESOCP-1327   ³        ³Ajuste na geração dos valores do plano de   ³±±
±±³             ³          ³                ³        ³saúde do dependente para o evento S-2299.   ³±±
±±³Cecília Carv ³08/01/2018³DRHESOCP-2682   ³        ³Ajuste para geração de contrato intermitente³±±
±±³             ³          ³                ³        ³ - evento S-2200.                           ³±±
±±³Cecília Carv ³31/01/2018³DRHESOCP-2687   ³        ³Ajuste na gravação das tag's <ideTabRubr>   ³±±
±±³             ³          ³DRHESOCP-2220   ³        ³(DRHESOCP-2687) e <ideDmDev> (DRHESOCP-2220)³±±
±±³             ³          ³                ³        ³do evento S-2299.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fAvsPrvEso    ³ Autor ³ Gabriel A.      ³ Data ³ 05/01/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que gera o XML de aviso prévio para integração com o³±±
±±³          ³ TAF                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fAvsPrvEso(nOpca,lCanc,aDados)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM026B                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fAvsPrvEso(nOpca,aDados,oGridAvPrv)

	Local aFilInTaf := {}
	Local aArrayFil := {}
	Local cFilEnv := ""
	Local cXml := ""
	Local nI := 0
	Local cMsgErro:= ""
	Private aErros := []

	fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	nI := oGridAvPrv:Length()
	oGridAvPrv:GoLine(nI) //Posiciona objeto na linha corrente
	If nOpca <> 5 .And. !oGridAvPrv:IsDeleted()
		cXml +=	'<eSocial>'
		cXml +=		'<evtAvPrevio>'
		cXml +=			'<ideVinculo>'
		cXml +=				'<cpfTrab>' + AllTrim(SRA->RA_CIC) + '</cpfTrab>'
		cXml +=				'<nisTrab>' + AllTrim(SRA->RA_PIS) + '</nisTrab>'
		cXml +=				'<matricula>' + SRA->RA_CODUNIC + '</matricula>'
		cXml +=			'</ideVinculo>'
		cXml +=			'<infoAvPrevio>'
		If Empty(oGridAvPrv:GetValue("RFY_DTCAP"))
			cXml +=			'<detAvPrevio>'
			cXml +=				'<dtAvPrv>' + Dtos(oGridAvPrv:GetValue("RFY_DTASVP")) + '</dtAvPrv>'
			cXml +=				'<dtPrevDeslig>' + Dtos(oGridAvPrv:GetValue("RFY_DTPJAV")) + '</dtPrevDeslig>'
			cXml +=				'<tpAvPrevio>' + oGridAvPrv:GetValue("RFY_TPAVIS") + '</tpAvPrevio>'
			cXml +=				'<observacao>' + FwNoAccent(oGridAvPrv:GetValue("RFY_OBSAV")) + '</observacao>'
			cXml +=			'</detAvPrevio>'
		Else
			cXml +=			'<cancAvPrevio>'
			cXml +=				'<dtCancAvPrv>' + Dtos(oGridAvPrv:GetValue("RFY_DTCAP")) + '</dtCancAvPrv>'
			cXml +=				'<observacao>' + FwNoAccent(oGridAvPrv:GetValue("RFY_OBSCAP")) + '</observacao>'
			cXml +=				'<mtvCancAvPrevio>' + oGridAvPrv:GetValue("RFY_TPCAP") + '</mtvCancAvPrevio>'
			cXml +=			'</cancAvPrevio>'
		EndIf
		cXml +=			'</infoAvPrevio>'
		cXml +=		'</evtAvPrevio>'
		cXml +=	'</eSocial>'
	Else //Exclusão
		//InExc3000(cXml,ctpEvento,cRecibo,cCpf,cPis,lFol,cIndApur,cPerApur)
		InExc3000(@cXml,'S-2250',(SRA->RA_CIC+SRA->RA_CODUNIC+Dtos(oGridAvPrv:GetValue("RFY_DTASVP"))),SRA->RA_CIC,SRA->RA_PIS,,)
	EndIf

	If !Empty(cXml)
		//Realiza geração de XML na System
		GrvTxtArq(alltrim(cXml), If(nOpca <> 5 .And. !oGridAvPrv:IsDeleted(nI), "S2250", "S3000"), SRA->RA_CIC)
	Endif

	If nOpca <> 5 .And. !oGridAvPrv:IsDeleted(nI)
		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2250")
		lRet:= IIF(Len(aErros) > 0,.F.,.T.)
	Else
		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3000")
		lRet:= IIF(Len(aErros) > 0,.F.,.T.)
	EndIf

	If Len( aErros ) > 0
		FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
		//Anula a mensagem de erro devido ao MVC da tela original
		//fEFDMsgErro(cMsgErro)
		If aErros[1]!='000026'
			aAdd(aDados, cMsgErro)
		EndIf
	EndIf
	If !Empty(cXml) .And. lRet
		fEFDMsg()
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fInt2298 ³ Autor ³ Alessandro Santos     ³ Data ³ 14/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao responsavel por integrar as acoes realizadas na roti³±±
±±³          ³ na de Reintegracao GPEA810 com o ambiente TAF.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±³          ³ Na rotina GPEA810 - Reintegracao de Funcionarios - S2820   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aInfoTaf - Array com informacoes de reintegracao.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fInt2298(aInfoTaf,aErros,cReg)

	Local aArea			:= GetArea()
	Local aFilInTaf		:= {}
	Local aArrayFil		:= {}
	Local cFilEnv		:= ""
	Local cXml			:= ""
	Local cTipoReint	:= ""
	Local lGravou		:= .T.
	Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
	Local cCatEFD
	Local cVersEnvio	:= ""
	Local lNDE			:= .F.

	Local cEFDAviso  	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")//Se nao encontrar este parametro apenas emitira alertas
	Local cVersMw	 	:= ""
	Local cChave	 	:= ""
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cOper2298	 	:= "I"
	Local cRecib2298 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2298	 	:= "1"
	Local cStat2298	 	:= "-1"
	Local nRec2298   	:= 0
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local lS1000 	 	:= .T.
	Local cStat1000	 	:= "-1"

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2298",,,, @cVersEnvio , , @cVersMw )
		lNDE := cVersEnvio >= "2.6"
	EndIf

	Default cReg		:= "S2298"

	If !lMiddleware
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
	Endif

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	//Geracao do evento S2298
	If !Empty(cFilEnv)

		If( Len(aInfoTaf[4]) == 2 )
			cTipoReint := SubStr(aInfoTaf[4], 1,1) //Recupera só a 1a posicao
		Else
			cTipoReint := aInfoTaf[4]
		EndIf

		cCatEFD := AllTrim(SRA->RA_CATEFD)

		If (cCatEFD $ '101*102*103*104*105*106*111*301*302*303*306*307*309')
			If lMiddleware
				fPosFil( cEmpAnt, SRA->RA_FILIAL )
				lS1000 := fVld1000( AnoMes(SRA->RA_ADMISSA), @cStat1000 )

				If !lS1000 .And. cEFDAviso != "2"
					Do Case
						Case cStat1000 == "-1" // nao encontrado na base de dados
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX não localizado na base de dados"
								lGravou	:= .F.
							ElseIf lMsgHlp
								Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX não localizado na base de dados"
							EndIf
						Case cStat1000 == "1" // nao enviado para o governo
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX não transmitido para o governo"
								lGravou	:= .F.
							ElseIf lMsgHlp
								Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX não transmitido para o governo"
							EndIf
						Case cStat1000 == "2" // enviado e aguardando retorno do governo
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
								lGravou	:= .F.
							ElseIf lMsgHlp
								Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
							EndIf
						Case cStat1000 == "3" // enviado e retornado com erro
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
								lGravou	:= .F.
							ElseIf lMsgHlp
								Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
							EndIf
					EndCase
				Endif

				If lGravou
					aInfos   := fXMLInfos()
					IF Len(aInfos) >= 4
						cTpInsc  := aInfos[1]
						lAdmPubl := aInfos[4]
						cNrInsc  := aInfos[2]
						cId  	 := aInfos[3]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf

					cChave	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2298" + Padr(SRA->RA_CODUNIC, 40, " ")
					cStat2298 	:= "-1"
					GetInfRJE( 2, cChave, @cStat2298, @cOper2298, @cRetf2298, @nRec2298, @cRecib2298, @cRecibAnt )

					If cStat2298 == "-1"
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					ElseIf cStat2298 $ "1/3"
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .F.
					//Será gerado uma retificação
					ElseIf cStat2298 == "4"
						cOperNew 	:= "A"
						cRetfNew	:= "2"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					Endif

					If cRetfNew == "2"
						If cStat2298 == "4"
							cRecibXML 	:= cRecib2298
							cRecibAnt	:= cRecib2298
							cRecib2298	:= ""
						Else
							cRecibXML 	:= cRecibAnt
						EndIf
					EndIf

					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2298", Space(6), SRA->RA_CODUNIC, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2298, cRecibAnt } )
					cXml := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtReintegr/v" + cVersMw + "'>"
					cXml +=		"<evtReintegr Id='" + cId + "'>"
					fXMLIdEve( @cXml, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, 1, 1, "12" } )
					fXMLIdEmp( @cXml, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
				Endif
			Endif

			If lGravou
				If !lMiddleware
					cXml +=	'<eSocial>'
					cXml +=		'<evtReintegr>'
				Endif

				cXml +=			'<ideVinculo>'
				cXml +=				'<cpfTrab>' + AllTrim(SRA->RA_CIC) + '</cpfTrab>'
				If cVersEnvio < "9.0.00"
					cXml +=				'<nisTrab>' + AllTrim(SRA->RA_PIS) + '</nisTrab>'
				EndIf
				cXml +=				'<matricula>' + SRA->RA_CODUNIC + '</matricula>'
				cXml +=			'</ideVinculo>'
				cXml +=			'<infoReintegr>'
				cXml +=				'<tpReint>' + cTipoReint + '</tpReint>'
				If !lMiddleware .Or. !Empty(aInfoTaf[5])
					cXml +=				'<nrProcJud>' + aInfoTaf[5] + '</nrProcJud>'
				EndIf
				If !Empty(aInfoTaf[6])
					cXml +=				'<nrLeiAnistia>' + aInfoTaf[6] + '</nrLeiAnistia>'
				Endif
				If !lMiddleware
					cXml +=				'<dtEfetRetorno>' + Dtos(aInfoTaf[7]) + '</dtEfetRetorno>'
				Else
					cXml +=				'<dtEfetRetorno>' + SubStr( dToS(aInfoTaf[7]), 1, 4 ) + "-" + SubStr( dToS(aInfoTaf[7]), 5, 2 ) + "-" + SubStr( dToS(aInfoTaf[7]), 7, 2 ) + '</dtEfetRetorno>'
				EndIf
				If !lMiddleware
					cXml +=				'<dtEfeito>' + Dtos(aInfoTaf[8]) + '</dtEfeito>'
				Else
					cXml +=				'<dtEfeito>' + SubStr( dToS(aInfoTaf[8]), 1, 4 ) + "-" + SubStr( dToS(aInfoTaf[8]), 5, 2 ) + "-" + SubStr( dToS(aInfoTaf[8]), 7, 2 ) + '</dtEfeito>'
				EndIf
				If !( lNDE .And. aInfoTaf[7] >= StoD("01/01/2020") ) .And. cVersEnvio < "9.0.00"
					cXml +=			'<indPagtoJuizo>' + IIf(SubStr(aInfoTaf[4],2,1) == "A","S","N") + '</indPagtoJuizo>'
				EndIf
				cXml +=			'</infoReintegr>'
				cXml +=		'</evtReintegr>'
				cXml +=	'</eSocial>'

				GrvTxtArq(alltrim(cXml), "S2298")
			Endif

			If !lMiddleware
				aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2298")
				If Len(aErros) > 0
					MsgAlert(OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + aErros[1], OemToAnsi(STR0001) ) //  "Atencao"
					lGravou := .F.
				Endif
			Else
				If Len(aDados) > 0
					If !(lGravou := fGravaRJE( aDados, cXML, lNovoRJE, nRec2298 ))
						aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravação do registro na tabela RJE"
					EndIf
				Endif
			Endif
		EndIf

	EndIf

	RestArea(aArea)

Return lGravou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fInt2299   ³ Autor ³ Marcos Coutinho      ³ Data ³ 20/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao responsavel por realizar a integracao de dados gera_³±±
±±³          ³ dos na rescicao com o TAF. Evento S-2299 - Desligamento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±³          ³ Na rotina GPEM040 - Rescisao de Funcionario S-2299         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oModel   - Array com informacoes de rescisao.              ³±±
±±³          ³ aErros   - Variavel responsavel por armazenar os erros     ³±±
±±³          ³ cReg     - Codigo do evento em questao                     ³±±
±±³          ³ cCodDslg - Codigo do eSocial de Desligamento               ³±±
±±³          ³ cTpRes   - 1 = Rescisao Simples / 2 = Rescisao Coletiva    ³±±
±±³          ³ aPd      - Array com as verbas do desligamento coletivo    ³±±
±±³          ³ dDataRes - Data do Aviso Previo do funcionario (Coletivo)  ³±±
±±³          ³ cDiaInde - Dias de Aviso indenizado (Coletivo)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fInt2299( oModel, aErros, cReg, cCodDslg, cTpRes, aPd, dDataRes, cDiaInde, cVersaoEnv, cIndAvPrv, lResComp, lRetif, nOpca, lNT15 )

	Local aArea 		:= GetArea()
	Local aAreaCTT 		:= {} //Centro de Custo
	Local aAreaRJ5 		:= {}
	Local aAreaRJ3		:= {}
	Local aAreaRHR 		:= {} //Plano de Saude
	Local aAreaSRV 		:= {} //Verbas
	Local aAreaRAZ 		:= {} //Multiplos Vinculos
	Local aAreaRCH 		:= {} //Periodos
	Local aFilInTaf 	:= {}
	Local aArrayFil 	:= {}
	Local cFilEnv 		:= ""
	Local cXml 			:= ""
	Local cTipoReint 	:= ""
	Local lGravou 		:= .T.
	Local cTrabVincu 	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
	Local cCodConvoc	:= ""
	Local cDiaSV7		:= "0"
	Local lIntermit		:= .F.
	Local cCatEFD
	Local oGrid
	Local oModelSRG

	Local nI 			:= 0
	Local nY 			:= 0
	Local aErros 		:= {}
	Local aCodBenef 	:= {}
	Local nPerPens		:= 0
	Local cMtvDeslig 	:= ""
	Local aCC 			:= fGM23CTT()
	Local cTpInscr		:= ""
	Local cInscr 		:= ""
	Local cCEIObra		:= ""
	Local cCAEPF		:= ""
	Local nPosEstb		:= 0
	Local lSemFilCTT 	:= .F.
	Local lSemFilSRV 	:= .F.
	Local nPosPd 		:= 0
	Local nPosValor 	:= 0
	Local nPosHoras 	:= 0
	Local cVerba		:= ""
	Local aVerba 		:= {}
	Local aColsAux 		:= {}
	Local cIntegra 		:= ""
	Local aASO 			:= {}
	Local cSimples 		:= ""
	Local cIndSimp 		:= ""
	Local nValor 		:= 0
	Local nPensao		:= 0
	Local dDtProj 		:= ""
	Local cStatus 		:= ""
	Local cStat   		:= ""
	Local cCpf			:= ""
	Local cPrcRubr		:= ""
	Local cTpLot		:= ""
	Local lRet 			:= .T.
	Local aCols 		:= {}
	Local nPosPd
	Local nPosValor
	Local nPosHoras
	Local cLogRub 		:= ""
	Local aDadosRAZ 	:= {}
	Local aDadosCCT 	:= {}
	Local aDadosSRV 	:= {}
	Local aDadosTRHR 	:= {}
	Local aDadosDRHR 	:= {}
	Local aDadosRHH 	:= {}
	Local cInfoDiss		:= ""
	Local cMsgDiss		:= ""
	Local cVBDiss		:= ""
	Local cVbPla		:= ""
	Local cPerAtu		:= ""
	Local cCodLot 		:= ""
	Local cCodRubr		:= ""
	Local cIdeRubr		:= ""
	Local cIdTabRub		:= ""
	Local lGeraCod		:= .F.
	Local lGerPla		:= .F.
	Local lPrimIdT		:= .T.
	Local nQtd 			:= 1
	Local nZ 			:= 0
	Local nX 			:= 0
	Local nW 			:= 0
	Local nD          	:= 0
	Local nContDev     	:= 0
	Local nOperation 	:= 0
	Local cFilPlaS 		:= ""
	Local cMatPlaS 		:= ""
	Local cCFOPlaS 		:= ""
	Local cCDEPlaS 		:= ""
	Local cPDPlaS  		:= ""
	Local cVLRPlaS 		:= ""
	Local cIdDmDev   	:= ""
	Local aIdDmDev   	:= {}
	Local lVer2_3	    := .F.
	Local cProcess    	:= ""
	Local cRoteiro    	:= fGetCalcRot("C")  // Plano de Saude
	Local cPeriodo    	:= ""
	Local cNumPag     	:= ""
	Local cTabRH      	:= ""
	Local cComprovou	:= ""
	Local cMsg			:= ""
	Local lCarrDep		:= .F.
	Local aTabS037      := {} // Tabela S037.
	Local nCntS037      := 0 // Contador Tabela S037
	Local aAdiCC		:= {}
	Local aAdiCols		:= {}
	Local a131CC		:= {}
	Local a131Cols		:= {}
	Local a132CC		:= {}
	Local a132Cols		:= {}
	Local aFolCC		:= {}
	Local aFolCols		:= {}
	Local cCompete		:= ""
	Local cDataCor		:= ""
	Local lCPFDepOk		:= .T.
	Local aDepAgreg		:= {}
	Local cTafKey		:= Nil
	Local lRJ5Ok		:= .T.
	Local aErrosRJ5		:= {}

	Local lParcial, lNovoCTT, lRJs := .F.
	Local cTipoPLA		:= fGetCalcRot('C')

	Local cBkpFil	 	:= cFilAnt
	Local cEFDAviso  	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")//Se nao encontrar este parametro apenas emitira alertas
	Local cVersMw	 	:= ""
	Local cXml		 	:= ""
	Local cMsg		 	:= ""
	Local cMsgErro	 	:= ""
	Local cVersMid	 	:= ""
	Local cChave	 	:= ""
	Local cChaveS1005	:= ""
	Local cChaveS1010	:= ""
	Local cChaveS1020	:= ""
	Local cStatus	 	:= "-1"
	Local cMsgHlp	 	:= ""
	Local cMsgRJE	 	:= ""
	Local cIni 		 	:= Space(6)
	Local lAdmPubl	 	:= .F.
	Local cTpInsc       := ""
	Local cNrInsc       := ""
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local cFilEmp	 	:= ""
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local lRet		 	:= .T.
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cStatRJE	 	:= "-1"
	Local cOper2299	 	:= "I"
	Local cRecib2299 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2299	 	:= "1"
	Local cStat2299	 	:= "-1"
	Local nRec2299   	:= 0
	Local cRetfNew	 	:= ""
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local lS1000 	 	:= .T.
	Local lS1005 	 	:= .T.
	Local lS1010 	 	:= .T.
	Local lS1020 	 	:= .T.
	Local lPredess 	 	:= .T.
	Local nCont			:= 0
	Local aErrosExc		:= {}
	Local cPdAnt		:= ""
	Local cCCAnt		:= ""
	Local lCMesAtual	:= .T.
	Local lRJ5FilT 		:= RJ5->(ColumnPos("RJ5_FILT")) > 0
	Local lTemReg		:= .F.
	Local lAltCC		:= .F.
	Local aTpRegTrab	:= {{'30'},{'31'}, {'35'}}
	Local nTpRegTrab	:= 0
	Local aDiasConv		:= {}
	Local nC			:= 0
	Local dDtIniInt		:= CTOD("//")
	Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0 .And. cVersaoEnv >= "9.0"
	Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0 .And. cVersaoEnv >= "9.0"
	Local cFilRCA 		:= xFilial( "RCA", cFilAnt )
	Local dDataHom		:= CTOD("//")
	Local cMatricula    := ""

	Private aEstb 		:= fGM23SM0(, .T.)
	Private bEstab 		:= {|| aScan(aEstb, {|x| x[1] == ALLTRIM(SRA->RA_FILIAL)})}
	Private nDecHor		:= TamSX3("RD_HORAS")[2]
	Private nDecVal		:= TamSX3("RD_VALOR")[2]
	Private nTamHor		:= TamSX3("RD_HORAS")[1]
	Private nTamMat		:= TamSX3("RD_MAT")[1]
	Private nTamVb		:= TamSX3("RD_PD")[1]
	Private nTamCC		:= TamSX3("RD_CC")[1]
	Private nTamVal		:= TamSX3("RD_VALOR")[1]
	Private cGpeAmbe	:= ""
	Private lAglut		:= .F.

	Default cReg 		:= "S2299"
	Default aPd			:= {}
	Default dDataRes 	:= CTOD("//")
	Default cDiaInde	:= ""
	Default cVersaoEnv 	:= '2.2'
	Default lResComp	:= .F.
	Default lRetif		:= .F.
	Default nOpca		:= 3
	Default lNT15		:= .F.

	RCA->( dbSetOrder(1) )
	If RCA->( dbSeek( cFilRCA + "P_ESOCMV" ) )
		lAglut := (AllTrim(RCA->RCA_CONTEU) == ".T.")
	EndIf

	lVer2_3 	:= (cVersaoEnv >= '2.3')
	nOperation 	:= Iif(cTpRes == "1", oModel:GetOperation(), nOpca)

	If Len(aEstb) > 0 .And. Len(aEstb[1]) > 4
		bEstab := {|| aScan(aEstb, {|x| x[5]+x[1] == FWGrpCompany() + ALLTRIM(SRA->RA_FILIAL)})}
	EndIf

	//Se trabalhador por contrato intermitente busca informações da tabela SV7 para a tag <infoTrabInterm>
	If SRA->RA_CATEFD == '111'
		lIntermit := .T.
		fBuscaSV7(SRA->RA_FILIAL, SRA->RA_MAT, dDataRes, @cCodConvoc, @lCMesAtual)
		If !Empty(cCodConvoc) .And. lCMesAtual
			cDiaSV7 := AllTrim(STR(Day(dDataRes),2))
		EndIf
		If cVersaoEnv >= "9.0.00"
			dDtIniInt := FirstDate( dDataRes )
			aDiasConv := fDiasConv(dDtIniInt, dDataRes)
		Endif
	Endif

	nTpRegTrab	:= aScan(aTpRegTrab,{|x| Alltrim(x[1]) == SRA->RA_VIEMRAI})//Retorno: 0-CLT | >0-Estatutario

	Begin Transaction
		//------------------------
		//| Tipo Rescisao Simples
		//| Caso a chamada da funcao tenha vindo da GPEM040()
		//----------------------------------------------------
		If( cTpRes == "1" ) .And. nOperation != 5
			oGrid 		:= oModel:GetModel('GPEM040_MGET')
			oModelSRG	:= oModel:GetModel('GPEM040_MSRG')

			If !lMiddleware
				fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				cStat2299 := TAFGetStat( "S-2299", AllTrim(SRA->RA_CIC) + ";" + AllTrim(SRA->RA_CODUNIC), , SRA->RA_FILIAL)
				If cStat2299 == "6"
					//"Atenção"##"Operação não será realizada pois há evento de exclusão pendente para transmissão"
					//"Verifique o status do evento S-3000 e tente novamente."
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0146), 1, 0, , , , , , {OemToAnsi(STR0326)})
					DisarmTransaction()
					Return .F.
				EndIf
			EndIf

			cComprovou := If( Type("cNewEmpAvP") == "U", "" , cNewEmpAvP)

			If Empty(cFilEnv)
				cFilEnv:= cFilAnt
			EndIf

			//----------------
			//| Evento S-2299
			//| Inicio da geracao do evento de desligamento
			//----------------------------------------------
			If !Empty(cFilEnv)

				//------------------------
				//| Verificacao de Filial
				//| Verificar o compartilhamento das tabelas CTT/RJ5 e SRV
				//--------------------------------------------------------------
				lNovoCTT:= FindFunction("fVldObraRJ") .And. fVldObraRJ(@lParcial, .T.)
				lRJs 	:= lNovoCTT .And. !lParcial

				If lRJs
					If Empty(xFilial("RJ5")) //RJ5 compartilhada
						lSemFilCTT := .T.
					EndIf
				Else
					If Empty(xFilial("CTT")) //CTT compartilhada
						lSemFilCTT := .T.
					EndIf
				Endif

				If !lMiddleware
					cTafKey := "S2299" + oModelSRG:GetValue("RG_PERIODO") + SRA->RA_CIC + SRA->RA_CODUNIC
				Else
					fVersEsoc( "S2299", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw, ,@cGpeAmbe  )
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
					lS1000 := fVld1000( AnoMes(M->RG_DATADEM), @cStatus )
					If !lS1000 .And. cEFDAviso != "2"
						Do Case
							Case cStatus == "-1" // nao encontrado na base de dados
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX não localizado na base de dados"
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX não localizado na base de dados"
								EndIf
							Case cStatus == "1" // nao enviado para o governo
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX não transmitido para o governo"
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX não transmitido para o governo"
								EndIf
							Case cStatus == "2" // enviado e aguardando retorno do governo
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX aguardando retorno do governo"
								EndIf
							Case cStatus == "3" // enviado e retornado com erro
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX retornado com erro do governo"
								EndIf
						EndCase
					EndIf
				EndIf

				//-----------------------------
				//| Varrendo o grid das verbas
				//| Looping para centralizar dentro do aCols as rubricas iguais
				//--------------------------------------------------------------
				For nI := 1 To oGrid:Length()
					If !oGrid:isDeleted(nI)
						oGrid:GoLine(nI)
					Else
						Loop
					EndIf

					lAltCC 	:= .F.

					// CASO O PARAMETRO MV_RATESOC ESTEJA COMO .F., VAI CONSIDERAR O CENTRO DO CUSTO DO FUNCIONARIO PARA TOTALIZAÇÃO
					// DAS VERBAS DESCONSIDERANDO OS DEMAIS CENTROS DE CUSTOS.
					If !lGeraRat .And. (cCCAnt <> oGrid:GetValue("RR_CC") .Or. (Empty(cPdAnt) .Or. cPdAnt <> oGrid:GetValue("RR_PD")))
						cPdAnt	:= oGrid:GetValue("RR_PD")
						cCCAnt	:= oGrid:GetValue("RR_CC")
						lAltCC 	:= .T.
						oGrid:SetValue("RR_CC", SRA->RA_CC)
					EndIf

					//--------------------------------
					//| Montagem da chave de pesquisa
					//| Realiza a montagem da chave de auxilio para localizar registro
					//-----------------------------------------------------------------
					cChaveCCPD	:= oGrid:GetValue("RR_CC") + oGrid:GetValue("RR_PD")
					cChaveCC	:= oGrid:GetValue("RR_CC")

					nPosCCPD	:= Ascan( @aCols,{|X| X[1] == cChaveCCPD })
					nPosCC		:= Ascan( @aCols,{|X| X[12] == cChaveCC })

					aAreaCTT := GetArea()
					aAreaRJ5 := GetArea()
					aAreaRJ3 := GetArea()
					lTemReg := .F.

					//----------------------------------
					//| Centro de Custo x Verba/Rubrica
					//| Realiza o filtro para saber se a verba incide IRRF
					//| Seleciona a Verba dentro do SRA e pega seus respectivos dados
					//| Seleciona o CC    dentro da CTT e pega seus respectivos dados
					//----------------------------------------------------------------
					If ( ( (cVersaoEnv < "2.6.00" ) .And. !(SubStr(RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" ), 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .Or.;
						 ( (cVersaoEnv >= "9.0.00") .And. (!RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_NATUREZ" ) $ "1801|9220" ))) .And.;
						!(RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_CODFOL" ) $ "0126|0303")
						//--------------------
						//| Verbas / Rubricas
						//| Guarda a area atual, entra na SRV e recupera os dados da verba
						//------------------------------------------------------------------
						aAreaSRV := GetArea()
						DBSelectArea("SRV")
						SRV->(DbSetOrder(1))
						If( SRV->( dbSeek( xFilial("SRV") + oGrid:GetValue("RR_PD")  ) ) )

							//Tratamento de compartilhamento da tabela SRV
							If !Empty(SRV->RV_FILIAL)
								lGeraCod := .T.
							Else
								lSemFilSRV := .T.
							EndIf

							//------------------
							//| Lógica lGeraCod
							//| .T. -> Exclusiva | .F. -> Compartilhada
							//------------------------------------------
							If lGeraCod
								cIdeRubr := Iif(!Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, (xFilial("SRV"),SRV->RV_FILIAL) )
							Else
								If cVersaoEnv >= "2.3"
									cIdeRubr := cEmpAnt
								Else
									cIdeRubr := ""
								EndIf
							Endif

							If lMiddleware
								If lPrimIdT
									lPrimIdT  := .F.
									cIdTabRub := fGetIdRJF( Iif(!Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, (xFilial("SRV"), SRV->RV_FILIAL) ), cIdeRubr )
									If Empty(cIdTabRub)
										Help(,,,OemToAnsi(STR0001), OemToAnsi(STR0140) + cIdeRubr + OemToAnsi(STR0141),1,0) //"Atenção"##"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
										Return .F.
									EndIf
								EndIf
								cIdeRubr := cIdTabRub
							EndIf

							cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
							If (SRV->RV_PERC - 100) < 0
								cPrcRubr :=	0	//Percent da Rubrica
							Else
								cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
							EndIf
							//----------------------------------------
							//| Recuperar a natureza da verba
							//| Se estiverem vazias, vão para a geração do log
							//-------------------------------------------------
							If Empty( SRV->RV_NATUREZ )
								If( Len(aErros) == 0 )
									aAdd(aErros, OemToAnsi( STR0054 ))
								Else
									aAdd(aErros, SRV->RV_COD + " - " + AllTrim( SRV->RV_DESC )+ " " )
								EndIf
							ElseIf ((cVersaoEnv < '2.6.00' .And. SRV->RV_NATUREZ == "9219") .Or. cVersaoEnv >= '2.6.00') .And. !lCarrDep
								//-----------------
								//| Plano de Saude
								//| Se a verba corrente tiver natureza de rubrica '9219' de plano de saude
								//| Entra na tabela RHR - Plano de Saude, localiza o registro do funcionário
								//| Verifica se o registro foi integrado com a folha, se sim: alimenta array
								//---------------------------------------------------------------------------
								//se o cálculo do plano de saúde estiver fechado, ler RHS, senão RHR
								aAreaRCH := GetArea()
								DbSelectArea("RCH")
								RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" ) ) )
								cProces  := oGrid:GetValue("RR_PROCES")
								cPeriodo := oModelSRG:GetValue("RG_PERIODO")
								cNumPag  := oModelSRG:GetValue("RG_SEMANA")
								RCH->( dbSeek( xFilial("RCH") + cProces + cTipoPLA + cPeriodo + cNumPag ) )
								If Empty(RCH->RCH_DTFECH)
									cTabRH := "RHR"
								Else
									cTabRH := "RHS"
								EndIf
								RestArea(aAreaRCH)
								GetRAssMed( xFilial("SRG"), oModelSRG:GetValue("RG_MAT"), "S016", cVersaoEnv, cPeriodo, @aDadosTRHR, @aDadosDRHR, cTabRH, @lCPFDepOk, @aDepAgreg )
								lCarrDep := .T.
								cVbPla 	 += SRV->RV_COD + "/"
							EndIf

						EndIf
						RestArea(aAreaSRV)

						if lRJs // usa controle na RJ5
						//------------------------------------------------
							//| Lotação
							//| Guarda a area atual, entra na RJ5 e recupera os dados do cc
							//---------------------------------------------------------------

							aAreaCTT := GetArea()
							aAreaRJ5 := GetArea()
							aAreaRJ3 := GetArea()

							DBSelectArea("CTT")
							CTT->(DbSetOrder(1))
							If( CTT->( dbSeek( xFilial("CTT") + oGrid:GetValue("RR_CC") ) ) )
								DBSelectArea("RJ5")
								RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
								If( RJ5->( dbSeek( xFilial("RJ5") + oGrid:GetValue("RR_CC") ) ) )
									//Se o campo RJ5_FILT existe pesquisa por este registro preenchido
									If lRJ5FilT
										RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
										RJ5->(dbGoTop())
										If RJ5->( dbSeek( xFilial("RJ5") + oGrid:GetValue("RR_CC")  + oGrid:GetValue("RR_FILIAL") ) )
											lTemReg := .T.
										EndIf
															//Se não encontrou um registro com código preenchido reposiciona a tabela e executa o dbseek novamente.
										If !lTemReg
											RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
											RJ5->(dbGoTop())
											RJ5->( dbSeek( xFilial("RJ5") + oGrid:GetValue("RR_CC") ) )
										EndiF
									EndIf
									if EMPTY(RJ5->RJ5_TPIO) .AND. EMPTY(RJ5->RJ5_NIO) // LOTACAO
										DBSelectArea("RJ3")
										RJ3->(DbSetOrder(2)) //RJ3_FILIAL+RJ3_COD+RJ3_INI+RJ3_TPLOT
										If( RJ3->( dbSeek( xFilial("RJ3") + RJ5->RJ5_COD ) ) )
											cCodLot  := IIf(lSemFilCTT, RJ3->RJ3_COD, RJ3->RJ3_FILIAL + RJ3->RJ3_COD )
											cTpInscr := ""
											cInscr 	 := ""
										ENDIF
									elseif !EMPTY(RJ5->RJ5_TPIO) .AND. !EMPTY(RJ5->RJ5_NIO) // OBRA PROPRIA
										cCodLot := IIf(lSemFilCTT, RJ5->RJ5_COD, RJ5->RJ5_FILIAL + RJ5->RJ5_COD )
										If RJ5->RJ5_TPIO == "4"
											cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
											cInscr 		:= RJ5->RJ5_NIO // Codigo da inscricao
											cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
										Endif
									ENDIF
								else
									MsgAlert(OemToAnsi(STR0116) + alltrim(oGrid:GetValue("RR_CC")) + OemToAnsi(STR0117) + alltrim(SRA->RA_MAT) + OemToAnsi(STR0118), OemToAnsi(STR0001) ) //  "Atencao"
									Return .F.
								Endif

								//Verifica na tabela F0F se a Filial eh uma obra
								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									cCEIObra := ""
									If fBuscaOBRA( cFilEnv, @cCEIObra )
										cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
										cInscr 		:= cCEIObra // Codigo da inscricao
										cChaveS1005	:= cFilEnv+cInscr
									Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
										cTpInscr 	:= "3"
										cInscr	 	:= cCAEPF
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									nPosEstb := eVal(bEstab)
									If nPosEstb > 0
										cTpInscr	:= aEstb[nPosEstb,3]
										cInscr		:= aEstb[nPosEstb,2]
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If nPosCC == 0 .And. If(Len(aDadosCCT) > 0, Ascan( aDadosCCT,{|X| X[4] == cCodLot }) == 0 , .T. )
									aAdd(aDadosCCT, {RJ5->RJ5_CC, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
								EndIf

								RestArea(aAreaRJ5)
								RestArea(aAreaCTT)
								RestArea(aAreaRJ3)
							EndIf
						else // usa o controle na CTT

							//------------------------------------------------
							//| Centro de Custo
							//| Guarda a area atual, entra na CTT e recupera os dados do cc
							//---------------------------------------------------------------
							aAreaCTT := GetArea()
							DBSelectArea("CTT")
							CTT->(DbSetOrder(1))
							If( CTT->( dbSeek( xFilial("CTT") + oGrid:GetValue("RR_CC") ) ) )
								cCodLot := IIf(lSemFilCTT, CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
								cTpLot  := CTT->CTT_TPLOT	// Tipo de Lotação (?!?)
								//Verifica se eh uma obra por meio do campo CTT_TIPO2
								If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
									cTpInscr 	:= CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
									cInscr 		:= CTT->CTT_CEI2 // Codigo da inscricao
									cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
								Endif

								//Verifica na tabela F0F se a Filial eh uma obra
								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									cCEIObra := ""
									If fBuscaOBRA( cFilEnv, @cCEIObra )
										cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
										cInscr 		:= cCEIObra // Codigo da inscricao
										cChaveS1005	:= cFilEnv+cInscr
									Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
										cTpInscr 	:= "3"
										cInscr		:= cCAEPF
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									nPosEstb := eVal(bEstab)
									If nPosEstb > 0
										cTpInscr	:= aEstb[nPosEstb,3]
										cInscr		:= aEstb[nPosEstb,2]
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If(nPosCC == 0)
									aAdd(aDadosCCT, {CTT->CTT_CUSTO, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
								EndIf

								RestArea(aAreaCTT)
							EndIf
						Endif

						//------------------------------------------------
						//| Array de Dados
						//| Montagem do array com os dados a utilizar para o XML
						//-------------------------------------------------------
						If( nPosCCPD > 0 )
							aCols[nPosCCPD, 15] += oGrid:GetValue("RR_HORAS")	//Incrementa Horas
							aCols[nPosCCPD, 17] += oGrid:GetValue("RR_VALOR")	//Incrementa Valor
							aCols[nPosCCPD, 18] := aCols[nPosCCPD, 18] + 1	  	//Incrementa Contador
						Else
							aAdd(aCols, { 	oGrid:GetValue("RR_CC")+ oGrid:GetValue("RR_PD"),;	    //01 - Chave para pesquisa (CC+PD)
												"Dados da Verba",;									//02 - Separador - Verbas/Rubricas
												cCodRubr,;											//03 - Codigo da Rubrica
												cIdeRubr,;											//04 - Ident   da Rubrica
												cPrcRubr,;											//05 - Percent da Rubrica
												"Dados do CC",;										//06 - Separador - Centro de Custo
												cCodLot,;											//07 - Codigo da Lotação
												cTpInscr,;											//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
												cInscr,;											//09 - Codigo da inscricao
												cTpLot,;											//10 - Tipo de Lotação (?!?)
												"Dados da Grid",;									//11 - Separador - Centro de Custo
												oGrid:GetValue("RR_CC"),;							//12 - Centro de Custo
												oGrid:GetValue("RR_PD"),;							//13 - Verba da rescisão
												oGrid:GetValue("RR_DESCPD"),;						//14 - Descricao da verba
												oGrid:GetValue("RR_HORAS"),;						//15 - Horas da verba
												oGrid:GetValue("RR_VALOR"),;						//16 - Valor da verba
												oGrid:GetValue("RR_VALOR"),;						//17 - Acumulado da verba (valor inicial para soma)
												1,; 												//18 - Numero de registro repetidos (CC + PD)
												SRV->RV_NATUREZ,;									//19 - Natureza da verba
												SRV->RV_INCCP,;										//20 - Incidência CP da verba
												SRV->RV_INCFGTS,;									//21 - Incidência FGTS da verba
												SRV->RV_INCIRF,;									//22 - Incidência IRRF da verba
												SRV->RV_TIPOCOD,;									//23 - Tipo da verba
												If(lRVIncop, SRV->RV_INCOP,""),;					//24 - Incid RPPS
												If(lRVTetop, SRV->RV_TETOP,"") })					//25 - Teto Remun

						EndIf
					EndIf

					//----------------------
					//| Liquido da Rescisão
					//| Se a verba corrente tiver o ID de Calculo igual
					//| a 0126 O Sistema receberá o valor líquido da rescisão
					//--------------------------------------------------------
					If RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_CODFOL" ) $ "0126"
						nValor := oGrid:GetValue("RR_VALOR")
					EndIf

					//---------------------
					//| Pensão Alimenticia
					//| Se a verba corrente tiver valor de DIRF igual aos informados
					//| Realizará a soma do montante pago de pensão Alimenticia
					//-----------------------------------------------------------
					If ( ( cVersaoEnv < "2.6.00" .And. SubStr(RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" ), 1, 2) $ "51|52|53|54|55" ) .Or.;
						( cVersaoEnv >= "2.6.00" .And. RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_INCIRF" ) $ "51  |52  |53  |54  |55  " ) )
						nPensao += oGrid:GetValue("RR_VALOR")
					EndIf

					//------------------------------
					//| Verba de Multiplos Vinculos
					//| Se a verba corrente, tiver seu ID de Calculo igual a 0318
					//| realizará a procura dos multiplos vínculos do funcionário
					//------------------------------------------------------------
					If RetValSrv( oGrid:GetValue("RR_PD"), SRA->RA_FILIAL, "RV_CODFOL" ) $ "0318"
						aAreaRAZ := GetArea()
						DBSelectArea("RAZ")
						RAZ->(DbSetOrder(1))
						If( RAZ->( dbSeek( xFilial("RAZ") + oGrid:GetValue("RR_MAT") ) ) )
							aDadosRAZ := GetMulVin(oGrid:GetValue("RR_FILIAL") , oGrid:GetValue("RR_MAT"), oModelSRG:GetValue("RG_PERIODO") )
						EndIf
						RestArea(aAreaRJ5)
						RestArea(aAreaCTT)
						RestArea(aAreaRJ3)
					EndIf

					//Restaura o centro de custo no grid
					If lAltCC
						oGrid:SetValue("RR_CC", cCCAnt)
					EndIf

				Next nI

				//Tratando o Log
				cMsg:= ""
				If( Len(aErros) > 1 ) //Maior que 1 pois sempre vai existir o cabeçalho do log de erros
					aAdd(aErros, OemToAnsi( STR0055 ) + " " + OemToAnsi( STR0056 ) ) //"estão sem código de rubrica cadastrada (RV_NATUREZ)." "Não será possível integração com o TAF e a efetivação da rescisão."
					For nx:=1 to Len(aErros)
						cMsg+= aErros[Nx]
					Next
					MsgAlert( OemToAnsi(cMsg) , OemToAnsi(STR0001))
					Return .F.
				EndIf

				//Ordena o Array separando por centro de custo
				//ASORT(aCols, , , { | x,y | x[2] < y[2] } )

				If !Empty(SRA->RA_CC) .AND. Len(aCC) > 0
					nPosLot := aScan(aCC, {|x| x[1] == FWxFilial("CTT") .AND. x[2] == SRA->RA_CC} )
					If nPosLot > 0
						cTpInscr := aCC[nPosLot,3]
						cInscr := aCC[nPosLot,4]
					EndIf
				EndIf

				If Empty(cTpInscr) .OR. Empty(cInscr)
					nPosEstb := eVal(bEstab)
					If nPosEstb > 0
						cTpInscr := aEstb[nPosEstb,3]
						cInscr := aEstb[nPosEstb,2]
					EndIf
				EndIf

				If !lMiddleware
					fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				EndIf

				If Empty(cFilEnv)
					cFilEnv:= cFilAnt
				EndIf

				fBusCadBenef(@aCodBenef,"FOL")
				For nI := 1 to len(aCodBenef)
					If ( aCodBenef[nI,15] == "S" ) //Apenas se Imprime % no Termo de Rescisao.
						nPerPens += aCodBenef[nI,2]
					EndIf
				Next nI

				nI := 0

				//Carrega Dados da Tabela S037, passando a data da Demissão como parâmetro.
				fCarrTab( @aTabS037, "S037", dDataRes, .T. , , , SRA->RA_FILIAL)
				nCntS037 := aScan( aTabS037, {|x| x[2] == cFilAnt .And. x[3] == AnoMes(M->RG_DATADEM) } )
				If nCntS037 == 0
					nCntS037 := aScan( aTabS037, {|x| x[2] == cFilAnt .And. Empty(Alltrim(x[3])) } )
					If nCntS037 == 0
						nCntS037 := aScan( aTabS037, {|x| Empty(Alltrim(x[2])) .And. x[3] == AnoMes(M->RG_DATADEM) } )
						If nCntS037 == 0
							nCntS037 := aScan( aTabS037, {|x| Empty(Alltrim(x[2])) .And. Empty(Alltrim(x[3])) } )
						EndIf
					EndIf
				EndIf
				If nCntS037 > 0
					cSimples := aTabS037[nCntS037,11] // Simples Nacional
					If cSimples == "1"
						cIndSimp := aTabS037[nCntS037,18] // Indicador do Tipo de Simples Nacional.
					EndIf
				EndIf

				If AllTrim(aIncRes[02]) $ "I/A" .Or. (aIncRes[02] == "T" .And. oModelSRG:GetValue("RG_DAVIND") > 0)
					dDtProj := oModelSRG:GetValue("RG_DTPROAV")
				EndIf

				If lMiddleware
					aInfos   := fXMLInfos()
					IF Len(aInfos) >= 4
						cTpInsc  := aInfos[1]
						lAdmPubl := aInfos[4]
						cNrInsc  := aInfos[2]
						cId  	 := aInfos[3]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf

					cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(SRA->RA_CODUNIC, 40, " ")
					cStat2299 	:= "-1"
					GetInfRJE( 2, cChaveBus, @cStat2299, @cOper2299, @cRetf2299, @nRec2299, @cRecib2299, @cRecibAnt, Nil, Nil, .T. )

					//Retorno pendente impede o cadastro
					If cStat2299 == "2" .And. cEFDAviso != "2"
						cMsgRJE 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
					EndIf
					//Inclusão
					If nOperation != 5
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2299 == "E" .And. cStat2299 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						ElseIf cStat2299 == "99"
							cMsgRJE 	:= STR0146//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
						//Não existe na fila, será tratado como inclusão
						ElseIf cStat2299 == "-1"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento sem transmissão, irá sobrescrever o registro na fila
						ElseIf cStat2299 $ "1/3"
							cOperNew 	:= cOper2299
							cRetfNew	:= cRetf2299
							cStatNew	:= "1"
							lNovoRJE	:= .F.
						//Evento diferente de exclusão transmitido, irá gerar uma retificação
						ElseIf cOper2299 != "E" .And. cStat2299 == "4"
							cOperNew 	:= "A"
							cRetfNew	:= "2"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento de exclusão transmitido, será tratado como inclusão
						ElseIf cOper2299 == "E" .And. cStat2299 == "4"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					//Exclusão
					Else
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2299 == "E" .And. cStat2299 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						//Evento diferente de exclusão transmitido irá gerar uma exclusão
						ElseIf cOper2299 != "E" .And. cStat2299 == "4"
							cOperNew 	:= "E"
							cRetfNew	:= cRetf2299
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					EndIf
					If !Empty(cMsgRJE)
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgRJE, 1, 0 )//" não enviado(a) ao Middleware. Erro: "
						Return .F.
					EndIf
					If cRetfNew == "2"
						If cStat2299 == "4"
							cRecibXML 	:= cRecib2299
							cRecibAnt	:= cRecib2299
							cRecib2299	:= ""
						Else
							cRecibXML 	:= cRecibAnt
						EndIf
					EndIf
					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2299", Space(6), SRA->RA_CODUNIC, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2299, cRecibAnt } )
					cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtDeslig/v" + cVersMw + "'>"
					cXML += 	"<evtDeslig Id='" + cId + "'>"
					fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cGpeAmbe, 1, "12" }, IIf(Len(aInfos) == 5 .And. aInfos[5] $ "21*22",cVersaoEnv,Nil) )
					fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
				Else
					//-------------------
					//| Inicio do XML
					//-------------------
					cXml := "<eSocial>"
					cXml += "	<evtDeslig>"
				EndIf

				//Dados do Trabalhador
				cXml += "		<ideVinculo>"
				cXml += "			<cpfTrab>" + AllTrim(SRA->RA_CIC) + "</cpfTrab>"
				If cVersaoEnv < "9.0.00"
					cXml += "			<nisTrab>" + AllTrim(SRA->RA_PIS) + "</nisTrab>"
				Endif

				If !Empty(SRA->RA_CODUNIC)
					cMatricula := If(!lMiddleware, StrTran(SRA->RA_CODUNIC, "&","&#38;" ),SRA->RA_CODUNIC )
				EndIf

				cXml += "			<matricula>" + AllTrim(cMatricula) + "</matricula>"
				cXml += "		</ideVinculo>"

				//Dados do Desligamento
				cXml += "		<infoDeslig>"
				cXml += "			<mtvDeslig>" + cCodDslg + "</mtvDeslig>"
				If !lMiddleware
					cXml += "			<dtDeslig>" + Dtos(M->RG_DATADEM) + "</dtDeslig>"
				Else
					cXml += "			<dtDeslig>" + SubStr( dToS(M->RG_DATADEM), 1, 4 ) + "-" + SubStr( dToS(M->RG_DATADEM), 5, 2 ) + "-" + SubStr( dToS(M->RG_DATADEM), 7, 2 ) + "</dtDeslig>"
				EndIf

				If cVersaoEnv >= "9.0.00"
					If !lMiddleware
						cXml += "			<dtAvPrv>" + Dtos(M->RG_DTAVISO) + "</dtAvPrv>"
					Else
						cXml += "			<dtAvPrv>" + SubStr( dToS(M->RG_DTAVISO), 1, 4 ) + "-" + SubStr( dToS(M->RG_DTAVISO), 5, 2 ) + "-" + SubStr( dToS(M->RG_DTAVISO), 7, 2 ) + "</dtAvPrv>"
					Endif
				Endif

				cXml += "			<indPagtoAPI>" + IIf(AllTrim(aIncRes[02]) $ "I/A" .Or. (aIncRes[02] == "T" .And. oModelSRG:GetValue("RG_DAVIND") > 0),"S","N") + "</indPagtoAPI>"
				If !Empty(dDtProj) .And. (AllTrim(aIncRes[02]) $ "I/A" .Or. aIncRes[02] == "T" .And. oModelSRG:GetValue("RG_DAVIND") > 0)
					If !lMiddleware
						cXml +=			'<dtProjFimAPI>' + Dtos(dDtProj) + '</dtProjFimAPI>'
					Else
						cXml +=			'<dtProjFimAPI>' + SubStr( dToS(dDtProj), 1, 4 ) + "-" + SubStr( dToS(dDtProj), 5, 2 ) + "-" + SubStr( dToS(dDtProj), 7, 2 ) + '</dtProjFimAPI>'
					EndIf
				EndIf
				If cVersaoEnv < "9.0.00" .Or. (cVersaoEnv >= "9.0.00" .And. nTpRegTrab == 0 )
					//Pensao Alimenticia
					if nPerPens <> 0 .and. nPensao <> 0
						cXml +=				'<pensAlim>3</pensAlim>'
					elseif nPerPens == 0 .and. nPensao == 0
						cXml +=				'<pensAlim>0</pensAlim>'
					elseif nPerPens <> 0 .and. nPensao == 0
						cXml +=				'<pensAlim>1</pensAlim>'
					elseif nPerPens == 0 .and. nPensao <> 0
						cXml +=				'<pensAlim>2</pensAlim>'
					Endif
				Endif
				//Percentual Alimenticio
				if nPerPens <> 0
					cXml +=				'<percAliment>' + Str(nPerPens) + '</percAliment>'
				endif

				//VR Alimentacao
				if nPensao <> 0
					cXml +=				'<vrAlim>' + If(lMiddleware, Alltrim(Str(nPensao)), Str(nPensao)) + '</vrAlim>'
				endif

				If cVersaoEnv < "9.0.00"
					//Numero Certidao Obito
					If Iif(cVersaoEnv >= '2.5.00', cCodDslg $ "10", cCodDslg $ "09*10") .And. !Empty(AllTrim(M->RG_OBITO))
						cXml +=			'<nrCertObito>' + AllTrim(M->RG_OBITO) + '</nrCertObito>'
					EndIf
				Endif
				//Numero Processo Trabalhista
				If !Empty(AllTrim(M->RG_NPROC))
					cXml +=			'<nrProcTrab>' + AllTrim(M->RG_NPROC) + '</nrProcTrab>'
				EndIf

				If cVersaoEnv < "9.0.00"
					//Detalhes Indicador Cumprimento Aviso Previo Parcial
					If cVersaoEnv >= '2.3'
						If !lNT15 .Or. !Empty(M->RG_INDAV)
							cXml += "		<indCumprParc>" + AllTrim(M->RG_INDAV) + "</indCumprParc>"
						EndIf
					Else
						cXml += "			<indCumprParc>" + If(Alltrim(cComprovou) == "Sim","1","0") + "</indCumprParc>"
					EndIf

					If lIntermit
						cXml += "			<qtdDiasInterm>" + cDiaSV7 + "</qtdDiasInterm>"
					EndIF
				Endif
				If cVersaoEnv >= "9.0.00" .And. lIntermit
					If Len(aDiasConv) > 0
						For nC := 1 to Len(aDiasConv)
							cXml +=         '<infoInterm>'
							cXml +=         '<dia>' + AllTrim(aDiasConv[nC]) + '</dia>'
							cXml +=         '</infoInterm>'
						Next nC
					Endif
				Endif

				If !Empty(AllTrim(M->RG_OBS))
					If cVersaoEnv >= "2.4.02"
						cXml +=         '<observacoes>'
							cXml +=         '<observacao>' + AllTrim(M->RG_OBS) + '</observacao>'
						cXml +=          '</observacoes>'
					Else
					cXml +=         '<observacao>' + AllTrim(M->RG_OBS) + '</observacao>'
					EndIf
				EndIf

				//Sucessao Vinculos
				If !Empty(AllTrim(M->RG_SUCES))
					cXml +=			'<sucessaoVinc>'
					If cVersaoEnv >= "9.0.00"
						cXml +=				'<nrInsc>' + AllTrim(M->RG_SUCES) +'</nrInsc>'
						IF SRG->(ColumnPos("RG_TPSU")) > 0 .AND. AllTrim(M->RG_TPSU) $ "1|2"
							cXml +=				'<tpInsc>' + AllTrim(M->RG_TPSU) +'</tpInsc>'
						ENDIF
					Else
						cXml +=				'<cnpjSucessora>' + AllTrim(M->RG_SUCES) +'</cnpjSucessora>'
						IF cVersaoEnv >= "2.5.00" .AND. SRG->(ColumnPos("RG_TPSU")) > 0 .AND. AllTrim(M->RG_TPSU) $ "1|2"
							cXml +=				'<tpInscSuc>' + AllTrim(M->RG_TPSU) +'</tpInscSuc>'
						ENDIF
					Endif
					cXml +=			'</sucessaoVinc>'
				Endif

				//Só gera as verbas caso o MV_FASESOC esteja igual a 2 (Manutenção, Não Periódicos e Periódicos)
				//ou em casos de funcionário de contrato intermitente, se há pagamento ou convocação no período de cálculo da rescisão
				//Não gera para servidor publico e Leiaute 1.0
				If lXmlVerbas .And. (!lIntermit .Or. (lIntermit .And. (lCMesAtual .Or. len(aCols) > 0 .And. !Empty(aCols[1,13])))) .And.;
					(cVersaoEnv < "9.0" .Or. nTpRegTrab == 0 )
					If lMiddleware
						fExcRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, "S-2299" )
					EndIf

					//Verbas de Rescisao
					cXml += "			<verbasResc>"

					//Validação para verificar se gera o dmDev do Dissidio
					fDis2299( dDataRes, @cVBDiss, aDadosCCT, cIndSimp, @cInfoDiss, @cMsgDiss, @lRJ5Ok, @aErrosRJ5, cTpRes )
					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						Help( ,, OemToAnsi(STR0001) ,, cMsgErro, 1, 0 )//"Atenção"
						DisarmTransaction()
						Return .F.
					EndIf

					//Busca a data de pagamento da rescisão original
					If lResComp
						fGetDtHomol(SRG->RG_FILIAL, SRG->RG_MAT, @dDataHom)
					EndIf

					// Se for envio de rescisão complementar e não calculada no mesmo dia da original, busca os valores pagos nas rescisões anteriores
					If (lResComp .And. !(dDataHom == M->RG_DATAHOM)) .Or. lRetif
						fResCom(@cXml, oModel, aDadosCCT, cVBDiss, cIndSimp, lRetif, @aCols)
					EndIf
					If cVersaoEnv >= '2.3'
						cIdDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRG")) +  SRA->RA_MAT + If(lRetif, "C", "") + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
					EndIf

					//Looping para varrer as verbas
					cXml += "				<dmDev>"
					If !lMiddleware
						cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
					Else
						cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
					Endif
					cXml += "					<infoPerApur>"

					If !Empty(cMsgDiss)
						aAdd(aErros, OemToAnsi( STR0100 ) + " " + OemToAnsi( STR0056 ) ) //"Preenchimento incorreto das tabelas S050/S126. As informações de dissídio não foram geradas."#"Não será possível integração com o TAF e a efetivação da rescisão."
						Help(,,,OemToAnsi(STR0001),OemToAnsi(STR0100),1,0) //"Atenção"#"Preenchimento incorreto das tabelas S050/S126. As informações de dissídio não foram geradas."#
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para detalhar os Centros de Custos que o Trab Atuou
					For nZ := 1 To Len( aDadosCCT )
						cXml += "						<ideEstabLot>"
						cXml += "							<tpInsc>" + aDadosCCT[nZ,2] + "</tpInsc>"
						cXml += "							<nrInsc>" + aDadosCCT[nZ,3] + "</nrInsc>"
						If !lMiddleware
							cXml += "							<codLotacao>" + StrTran( aDadosCCT[nZ,4], "&", "&amp;") + "</codLotacao>"
						Else
							cXml += "							<codLotacao>" + Alltrim(StrTran( aDadosCCT[nZ,4], "&", "&amp;")) + "</codLotacao>"
						Endif

						//Looping nas verbas vindas
						For nX := 1 To Len( aCols )
							//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
							If Empty(cVBDiss) .Or. !( aCols[nX,3] $ cVBDiss ) //Nao leva verbas do dissidio
								If (If(!lRJs, aCols[nX, 12] == aDadosCCT[nZ,1], aCols[nX, 7 ] == aDadosCCT[nZ, 4] ) .And. aCols[nX,17] > 0  )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + aCols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + aCols[nX,4] + "</ideTabRubr>"
									If !lMiddleware
										cXml += "							<qtdRubr>" + Str(aCols[nX,15]) + "</qtdRubr>"
									ElseIf lMiddleware .And. !Empty(aCols[nX,15])
										cXml += "							<qtdRubr>" + Alltrim(Str(round(aCols[nX,15],2))) + "</qtdRubr>"
									Endif
									If !lMiddleware
										cXml += "							<fatorRubr>" + AllTrim( Transform(aCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									ElseIf lMiddleware .And. !Empty(aCols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( StrTran(Transform(aCols[nX,5],"@E 999999999.99"), ",", "." )) + "</fatorRubr>"
									EndIf
									If (!lMiddleware .Or. !Empty(aCols[nX,16]) ) .And. cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(aCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(aCols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(aCols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(aCols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If aCols[nX,3] $ cVbPla
										lGerPla := .T.
									EndIf
									If lMiddleware .And. ( (aCols[nX, 19] == "9901" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9201" .And. aCols[nX, 20] $ "31/32") .Or. (aCols[nX, 19] == "1409" .And. aCols[nX, 20] == "51") .Or. (aCols[nX, 19] == "4050" .And. aCols[nX, 20] == "21") .Or. (aCols[nX, 19] == "4051" .And. aCols[nX, 20] == "22") .Or. (aCols[nX, 19] == "9902" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9904" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9908" .And. aCols[nX, 23] == "3") )
										fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nZ, 2], aDadosCCT[nZ, 3], aDadosCCT[nZ, 4], aCols[nX, 19], aCols[nX, 23], aCols[nX, 20], aCols[nX, 21], aCols[nX, 22], aCols[nX, 17], "S-2299", , , ,aCols[nX, 24], aCols[nX, 25] )
									EndIf
								EndIf
							EndIf
						Next

						//Plano de Saude
						If Len(aDadosTRHR) > 0 .And. lGerPla .And. cVersaoEnv < "9.0.00"
							cXml += "							<infoSaudeColet>"
							For nW := 1 To Len(aDadosTRHR)
								cXml += "								<detOper>"
								cXml += "									<cnpjOper>" + aDadosTRHR[nW,6] + "</cnpjOper>"
								cXml += "									<regANS>" + aDadosTRHR[nW,7] + "</regANS>"
								If !lMiddleware
									cXml += "									<vrPgTit>" + AllTrim( Transform(aDadosTRHR[nW,8],"@E 999999999.99") ) + "</vrPgTit>"
								Else
									cXml += "									<vrPgTit>" + AllTrim( Str(aDadosTRHR[nW,8]) ) + "</vrPgTit>"
								EndIf
								If lVer2_3 .And. Len(aDadosDRHR) > 0
									For nD := 1 To Len(aDadosDRHR)
										If ( aDadosTRHR[nW][6] + aDadosTRHR[nW][7] == aDadosDRHR[nD][7] + aDadosDRHR[nD][8] ) // Chave CNPJ Fornecedor + ANS
											cXml += "						<detPlano>"
											cXml += "					        <tpDep>"+aDadosDRHR[nD,5]+"</tpDep>"
											If !lMiddleware .Or. !Empty(aDadosDRHR[nD,1])
												cXml += "						<cpfDep>" + aDadosDRHR[nD,1] + "</cpfDep>"
											EndIf
											cXml += "							<nmDep>" + aDadosDRHR[nD,2] + "</nmDep>"
											If !lMiddleware
												cXml += "							<dtNascto>" + aDadosDRHR[nD,3] + "</dtNascto>"
											Else
												cXml += "							<dtNascto>" + SubStr( aDadosDRHR[nD,3], 1, 4 ) + "-" + SubStr( aDadosDRHR[nD,3], 5, 2 ) + "-" + SubStr( aDadosDRHR[nD,3], 7, 2 ) + "</dtNascto>"
											EndIf
											If !lMiddleware
												cXml += "							<vlrPgDep>" + AllTrim( Transform(aDadosDRHR[nD,4],"@E 999999999.99") ) + "</vlrPgDep>"
											Else
												cXml += "							<vlrPgDep>" + AllTrim( Str(aDadosDRHR[nD,4]) ) + "</vlrPgDep>"
											EndIf
											cXml += "						</detPlano>"
										Endif
									Next
								EndIf
								cXml += "								</detOper>"
							Next
							cXml += "							</infoSaudeColet>"
							aDadosTRHR := {}
						EndIf

						If SRA->RA_TPPREVI == "1"
							S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
						EndIf
						If !Empty(cIndSimp)
							cXml += "						<infoSimples>"
							cXml += "							<indSimples>" + cIndSimp + "</indSimples>"
							cXml += "						</infoSimples>"
						Endif
						cXml += "						</ideEstabLot>"
					Next

					cXml += "					</infoPerApur>"

					//Transfere para o XML as informações do Dissidio calculado na rescisao
					If !Empty( cInfoDiss )
						cXml += cInfoDiss
					EndIf

					If lIntermit .And. !Empty(cCodConvoc) .And. cVersaoEnv < "9.0.00"
						cXml += "				<infoTrabInterm>"
						cXml += "					<codConv>" + cCodConvoc + "</codConv>"
						cXml += "				</infoTrabInterm>"
					Endif

					cXml += "				</dmDev>"
					//Validação para verificar se gera o dmDev do PLR pago antes da rescisão no mesmo período
					fPLR2299( @cXml, oModel, aDadosCCT, cIndSimp, dDataRes)
					//Validação para verificar se gera o dmDev do ADI
					fADI2299( @aAdiCC, @aAdiCols, cFilEnv, @cIdDmDev, cVersaoEnv, lRetif, @aErrosRJ5)

					If !Empty(aErrosRJ5)
						aAdd( aErros, OemToAnsi(STR0114) )//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							aAdd( aErros, aErrosRJ5[nI] )
						Next
						aAdd( aErros, OemToAnsi(STR0115) ) //" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para varrer as verbas
					If Len(aAdiCols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( aAdiCC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + aAdiCC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + aAdiCC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( aAdiCC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( aAdiCC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif
							//Looping nas verbas vindas
							For nX := 1 To Len( aAdiCols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( aAdiCols[nX, 12] == aAdiCC[nZ,1] .AND. aAdiCols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + aAdiCols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + aAdiCols[nX,4] + "</ideTabRubr>"
									If !lMiddleware
										cXml += "							<qtdRubr>" + Str(aAdiCols[nX,15]) + "</qtdRubr>"
									ElseIf lMiddleware .And. !Empty(aAdiCols[nX,15])
										cXml += "							<qtdRubr>" + AllTrim(Str(aAdiCols[nX,15])) + "</qtdRubr>"
									EndIf
									If !lMiddleware .Or. !Empty(aAdiCols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( Transform(aAdiCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									EndIf
									If (!lMiddleware .Or. !Empty(aAdiCols[nX,16])) .And. cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(aAdiCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(aAdiCols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(aAdiCols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(aAdiCols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If lMiddleware .And. ( (aAdiCols[nX, 21] == "9901" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9201" .And. aAdiCols[nX, 22] $ "31/32") .Or. (aAdiCols[nX, 21] == "1409" .And. aAdiCols[nX, 22] == "51") .Or. (aAdiCols[nX, 21] == "4050" .And. aAdiCols[nX, 22] == "21") .Or. (aAdiCols[nX, 21] == "4051" .And. aAdiCols[nX, 22] == "22") .Or. (aAdiCols[nX, 21] == "9902" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9904" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9908" .And. aAdiCols[nX, 25] == "3") )
										fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aAdiCC[nZ, 2], aAdiCC[nZ, 3], aAdiCC[nZ, 4], aAdiCols[nX, 21], aAdiCols[nX, 25], aAdiCols[nX, 22], aAdiCols[nX, 23], aAdiCols[nX, 24], aAdiCols[nX, 17], "S-2299" , , , , aAdiCols[nX, 26], aAdiCols[nX, 27])
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next

						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf

					//Validação para verificar se gera o dmDev do 131
					f1312299( @a131CC, @a131Cols, cFilEnv, @cIdDmDev, lRetif, @aErrosRJ5,cVersaoEnv)

					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						Help(,,,OemToAnsi(STR0001),cMsgErro,1,0) //"Atenção"
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para varrer as verbas
					If Len(a131Cols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( a131CC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + a131CC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + a131CC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( a131CC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( a131CC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif

							//Looping nas verbas vindas
							For nX := 1 To Len( a131Cols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( a131Cols[nX, 12] == a131CC[nZ,1]  .And. a131Cols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + a131Cols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + a131Cols[nX,4] + "</ideTabRubr>"
									If !lMiddleware .Or. !Empty(a131Cols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( Transform(a131Cols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									EndIf
									If (!lMiddleware .Or. !Empty(a131Cols[nX,16]) ) .And. cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(a131Cols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(a131Cols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(a131Cols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(a131Cols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If lMiddleware .And. ( (a131Cols[nX, 21] == "9901" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9201" .And. a131Cols[nX, 22] $ "31/32") .Or. (a131Cols[nX, 21] == "1409" .And. a131Cols[nX, 22] == "51") .Or. (a131Cols[nX, 21] == "4050" .And. a131Cols[nX, 22] == "21") .Or. (a131Cols[nX, 21] == "4051" .And. a131Cols[nX, 22] == "22") .Or. (a131Cols[nX, 21] == "9902" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9904" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9908" .And. a131Cols[nX, 25] == "3") )
										fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, a131CC[nZ, 2], a131CC[nZ, 3], a131CC[nZ, 4], a131Cols[nX, 21], a131Cols[nX, 25], a131Cols[nX, 22], a131Cols[nX, 23], a131Cols[nX, 24], a131Cols[nX, 17], "S-2299" , , , ,a131Cols[nX, 26], a131Cols[nX, 27] )
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next
						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf

					//Validação para verificar se gera o dmDev do 132
					f1322299( @a132CC, @a132Cols, cFilEnv, @cIdDmDev, lRetif, @aErrosRJ5,cVersaoEnv,aFilInTaf, lAdmPubl, cTpInsc, cNrInsc )

					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						Help(,,,OemToAnsi(STR0001),cMsgErro,1,0) //"Atenção"
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para varrer as verbas
					If Len(a132Cols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( a132CC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + a132CC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + a132CC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( a132CC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( a132CC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif

							//Looping nas verbas vindas
							For nX := 1 To Len( a132Cols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( a132Cols[nX, 12] == a132CC[nZ,1]  .And. a132Cols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + a132Cols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + a132Cols[nX,4] + "</ideTabRubr>"
									If !lMiddleware .Or. !Empty(a132Cols[nX,5])
										cXml += "							<fatorRubr>" + AllTrim( Transform(a132Cols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									EndIf
									If (!lMiddleware .Or. !Empty(a132Cols[nX,16])) .And. cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "							<vrUnit>" + AllTrim( Transform(a132Cols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "							<vrUnit>" + AllTrim( Str(a132Cols[nX,16]) ) + "</vrUnit>"
										EndIf
									EndIf
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(a132Cols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(a132Cols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If lMiddleware .And. ( (a132Cols[nX, 21] == "9901" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9201" .And. a132Cols[nX, 22] $ "31/32") .Or. (a132Cols[nX, 21] == "1409" .And. a132Cols[nX, 22] == "51") .Or. (a132Cols[nX, 21] == "4050" .And. a132Cols[nX, 22] == "21") .Or. (a132Cols[nX, 21] == "4051" .And. a132Cols[nX, 22] == "22") .Or. (a132Cols[nX, 21] == "9902" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9904" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9908" .And. a132Cols[nX, 25] == "3") )
										fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, a132CC[nZ, 2], a132CC[nZ, 3], a132CC[nZ, 4], a132Cols[nX, 21], a132Cols[nX, 25], a132Cols[nX, 22], a132Cols[nX, 23], a132Cols[nX, 24], a132Cols[nX, 17], "S-2299" , , , ,a132Cols[nX, 26], a132Cols[nX, 27] )
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next
						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf

					If M->RG_SEMANA > "01"
						//Validação para verificar se gera o dmDev do FOL
						fFOL2299( @aFolCC, @aFolCols, cFilEnv, @aIdDmDev, cVersaoEnv, lRetif, M->RG_SEMANA )
						For nContDev := 1 To Len(aIdDmDev)
							//Looping para varrer as verbas
							If Len(aFolCols[nContDev]) > 0
								cXml += "				<dmDev>"
								If !lMiddleware
									cXml += "					<ideDmDev>" + aIdDmDev[nContDev] +  "</ideDmDev>"
								Else
									cXml += "					<ideDmDev>" + Alltrim(aIdDmDev[nContDev] ) +  "</ideDmDev>"
								Endif
								cXml += "					<infoPerApur>"

								//Looping para detalhar os Centros de Custos que o Trab Atuou
								For nZ := 1 To Len( aFolCC[nContDev] )
									cXml += "						<ideEstabLot>"
									cXml += "							<tpInsc>" + aFolCC[nContDev,nZ,2] + "</tpInsc>"
									cXml += "							<nrInsc>" + aFolCC[nContDev,nZ,3] + "</nrInsc>"
									If !lMiddleware
										cXml += "							<codLotacao>" + StrTran( aFolCC[nContDev,nZ,4], "&", "&amp;") + "</codLotacao>"
									Else
										cXml += "							<codLotacao>" + Alltrim(StrTran( aFolCC[nContDev,nZ,4], "&", "&amp;")) + "</codLotacao>"
									Endif
									//Looping nas verbas vindas
									For nX := 1 To Len( aFolCols[nContDev] )
										//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
										If( aFolCols[nContDev,nX, 12] == aFolCC[nContDev,nZ,1] .AND. aFolCols[nContDev,nX,17] > 0 )
											cXml += "							<detVerbas>"
											cXml += "								<codRubr>" + aFolCols[nContDev,nX,3] + "</codRubr>"
											cXml += "								<ideTabRubr>" + aFolCols[nContDev,nX,4] + "</ideTabRubr>"
											If !lMiddleware .Or. !Empty(aFolCols[nContDev,nX,15])
												cXml += "							<qtdRubr>" + Str(aFolCols[nContDev,nX,15]) + "</qtdRubr>"
											EndIf
											If !lMiddleware .Or. !Empty(aFolCols[nContDev,nX,5])
												cXml += "							<fatorRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,5],"@E 999999999.99") ) + "</fatorRubr>"
											EndIf
											If (!lMiddleware .Or. !Empty(aFolCols[nContDev,nX,16])) .And. cVersaoEnv < "9.0.00"
												If !lMiddleware
													cXml += "							<vrUnit>" + AllTrim( Transform(aFolCols[nContDev,nX,16],"@E 999999999.99") ) + "</vrUnit>"
												Else
													cXml += "							<vrUnit>" + AllTrim( Str(aFolCols[nContDev,nX,16]) ) + "</vrUnit>"
												EndIf
											EndIf
											If !lMiddleware
												cXml += "								<vrRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,17],"@E 999999999.99") ) + "</vrRubr>"
											Else
												cXml += "								<vrRubr>" + AllTrim( Str(aFolCols[nContDev,nX,17]) ) + "</vrRubr>"
											EndIf
											If cVersaoEnv >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
												cXml +=         '<indApurIR>0</indApurIR>'
											Endif
											cXml += "							</detVerbas>"
											If lMiddleware .And. ( (aFolCols[nContDev, nX, 21] == "9901" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9201" .And. aFolCols[nContDev, nX, 22] $ "31/32") .Or. (aFolCols[nContDev, nX, 21] == "1409" .And. aFolCols[nContDev, nX, 22] == "51") .Or. (aFolCols[nContDev, nX, 21] == "4050" .And. aFolCols[nContDev, nX, 22] == "21") .Or. (aFolCols[nContDev, nX, 21] == "4051" .And. aFolCols[nContDev, nX, 22] == "22") .Or. (aFolCols[nContDev, nX, 21] == "9902" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9904" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9908" .And. aFolCols[nContDev, nX, 25] == "3") )
												fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aFolCC[nContDev, nZ, 2], aFolCC[nContDev, nZ, 3], aFolCC[nContDev, nZ, 4], aFolCols[nContDev, nX, 21], aFolCols[nContDev, nX, 25], aFolCols[nContDev, nX, 22], aFolCols[nContDev, nX, 23], aFolCols[nContDev, nX, 24], aFolCols[nContDev, nX, 17], "S-2299" , , , ,aFolCols[nContDev, nX, 26], aFolCols[nContDev, nX, 27] )
											EndIf
										EndIf
									Next

									If SRA->RA_TPPREVI == "1"
										S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
									EndIf
									If !Empty(cIndSimp)
										cXml += "							<infoSimples>"
										cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
										cXml += "							</infoSimples>"
									Endif
									cXml += "						</ideEstabLot>"
								Next

								cXml += "					</infoPerApur>"
								cXml += "				</dmDev>"
							EndIf
						Next nContDev
					EndIf

					//Informações Multiplos Vinculos
					If ( Len( aDadosRAZ ) > 0 )
						cXml += "				<infoMV>"
						cXml += "					<indMV>" + aDadosRAZ[1,5] + "</indMV>"

						For nX := 1 To Len( aDadosRAZ )
							cXml += "					<remunOutrEmpr>"
							cXml += "						<tpInsc>" + aDadosRAZ[nX,9] + "</tpInsc>"
							cXml += "						<nrInsc>" + aDadosRAZ[nX,10] + "</nrInsc>"
							cXml += "						<codCateg>" + aDadosRAZ[nX,12] + "</codCateg>"
							cXml += "						<vlrRemunOE>" + AllTrim( Transform(aDadosRAZ[nX,11],"@E 999999999.99") ) + "</vlrRemunOE>"
							cXml += "					</remunOutrEmpr>"
						Next
						cXml += "				</infoMV>"
					EndIf

					If cVersaoEnv >= "2.4.02" .And. SRG->(ColumnPos("RG_NPROCS")) > 0 .And. !Empty(oModelSRG:GetValue("RG_NPROCS"))
						cXml += "<procCS>"
						cXml += "   <nrProcJud>"+oModelSRG:GetValue("RG_NPROCS")+"</nrProcJud>"
						cXml += "</procCS>"
					EndIf
					cXml += "			</verbasResc>"
				Endif
				If cVersaoEnv >= '2.4' .And. (Len(aPd_Aux) > 0 .Or. (cVersaoEnv < "2.4.02"  .And. Len(aPd_Aux) == 0 ))
					cXml += "			<consigFGTS>"
					IF Len(aPd_Aux) > 0
						If fBuscConsig(aPd_Aux)
							If cVersaoEnv <= "2.4
								cXml += "             <idConsig>S</idConsig>"
							EndIf
							cXml += "				<insConsig>" + Alltrim(SRK->RK_BCOCONS )+ "</insConsig>"
							cXml += "				<nrContr>" + Alltrim(SRK->RK_NRCONTR) + "</nrContr>"
						EndIf
					EndIf
					If cVersaoEnv < "2.4.02"  .And. (Len(aPd_Aux) == 0 .Or. !("idConsig" $ cXml))
						cXml += "               <idConsig>N</idConsig>"
					EndIf
					cXml += "			</consigFGTS>"
				EndIf

				//Fechamentos de Tags
				cXml += "		</infoDeslig>"
				cXml += "	</evtDeslig>"
				cXml += "</eSocial>"
				//-------------------
				//| Final do XML
				//-------------------
			EndIf
		ElseIf (cTpRes == "2" .AND. nOperation != 5)
			//------------------------
			//| Tipo Rescisao Coletiva
			//| Caso a chamada da funcao tenha vindo da GPEM630()
			//----------------------------------------------------
			if !lMiddleware
				fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				cStat2299 := TAFGetStat( "S-2299", AllTrim(SRA->RA_CIC) + ";" + AllTrim(SRA->RA_CODUNIC), , SRA->RA_FILIAL)
				If cStat2299 == "6"
					//"Atenção"##"Operação não será realizada pois há evento de exclusão pendente para transmissão"
					//"Verifique o status do evento S-3000 e tente novamente."
					aAdd(aErros, OemToAnsi(STR0146)+". "+ OemToAnsi(STR0326))//"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
					DisarmTransaction()
					Return .F.
				EndIf
			endif

			If Empty(cFilEnv)
				cFilEnv:= cFilAnt
			EndIf

			If cVersaoEnv >= '2.3'
				cIdDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRA")) + SRA->RA_MAT
			EndIf


			//----------------
			//| Evento S-2299
			//| Inicio da geracao do evento de desligamento
			//----------------------------------------------
			If !Empty(cFilEnv)

				//------------------------
				//| Verificacao de Filial
				//| Verificar o compartilhamento das tabelas CTT/RJ5 e SRV
				//--------------------------------------------------------------
				lNovoCTT:= FindFunction("fVldObraRJ") .And. fVldObraRJ(@lParcial, .T.)
				lRJs 	:= lNovoCTT .And. !lParcial

				If lRJs
					If Empty(xFilial("RJ5")) //RJ5 compartilhada
						lSemFilCTT := .T.
					EndIf
				Else
					If Empty(xFilial("CTT")) //CTT compartilhada
						lSemFilCTT := .T.
					EndIf
				Endif

				If !lMiddleware
					cTafKey := "S2299" + AnoMes(M->RG_DATADEM) + SRA->RA_CIC + SRA->RA_CODUNIC
				else
					fVersEsoc( "S2299", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw )
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
					lS1000 := fVld1000( AnoMes(M->RG_DATADEM), @cStatus )
					If !lS1000 .And. cEFDAviso != "2"
						Do Case
							Case cStatus == "-1" // nao encontrado na base de dados
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX não localizado na base de dados"
									DisarmTransaction()
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX não localizado na base de dados"
								EndIf
							Case cStatus == "1" // nao enviado para o governo
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX não transmitido para o governo"
									DisarmTransaction()
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX não transmitido para o governo"
								EndIf
							Case cStatus == "2" // enviado e aguardando retorno do governo
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
									DisarmTransaction()
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX aguardando retorno do governo"
								EndIf
							Case cStatus == "3" // enviado e retornado com erro
								If cEFDAviso == "1"
									Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
									DisarmTransaction()
									Return .F.
								Else
									MsgInfo( OemToAnsi(OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133)), OemToAnsi(STR0001))//"Atenção""Registro do evento X-XXXX retornado com erro do governo"
								EndIf
						EndCase
					EndIf
				EndIf

				//-----------------------------
				//| Varrendo o grid das verbas
				//| Looping para centralizar dentro do aCols as rubricas iguais
				//--------------------------------------------------------------
				For nI := 1 To Len( aPd )

					lAltCC := .F.

					// CASO O PARAMETRO MV_RATESOC ESTEJA COMO .F., VAI CONSIDERAR O CENTRO DO CUSTO DO FUNCIONARIO PARA TOTALIZAÇÃO
					// DAS VERBAS DESCONSIDERANDO OS DEMAIS CENTROS DE CUSTOS.
					If !lGeraRat .And. (cCCAnt <> aPd[nI,2] .Or. (Empty(cPdAnt) .Or. cPdAnt <> aPd[nI,1]))
						cPdAnt	:= aPd[nI, 1]
						cCCAnt	:= aPd[nI, 2]
						lAltCC	:= .T.
						aPd[nI, 2] := SRA->RA_CC
					EndIf

					//--------------------------------
					//| Montagem da chave de pesquisa
					//| Realiza a montagem da chave de auxilio para localizar registro
					//-----------------------------------------------------------------
					cChaveCCPD	:= aPd[nI,2] + aPd[nI,1]
					cChaveCC	:= aPd[nI,2]
					lTemReg		:= .F.

					nPosCCPD	:= Ascan( @aCols,{|X| X[1] == cChaveCCPD })
					nPosCC		:= Ascan( @aCols,{|X| X[12] == cChaveCC })

					aAreaCTT := GetArea()
					aAreaRJ5 := GetArea()
					aAreaRJ3 := GetArea()

					//----------------------------------
					//| Centro de Custo x Verba/Rubrica
					//| Realiza o filtro para saber se a verba incide IRRF
					//| Seleciona a Verba dentro do SRA e pega seus respectivos dados
					//| Seleciona o CC    dentro da CTT e pega seus respectivos dados
					//----------------------------------------------------------------
					If ( ( (cVersaoEnv < "2.6.00" ) .And. !(SubStr(RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_INCIRF" ), 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .Or.;
						( (cVersaoEnv >= "9.0.00") .And. (!RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_NATUREZ" ) $ "1801|9220" ))) .And.;
						!(RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_CODFOL" ) $ "0126|0303")
						//--------------------
						//| Verbas / Rubricas
						//| Guarda a area atual, entra na SRV e recupera os dados da verba
						//------------------------------------------------------------------
						aAreaSRV := GetArea()
						DBSelectArea("SRV")
						SRV->(DbSetOrder(1))
						If( SRV->( dbSeek( xFilial("SRV") + aPd[nI,1]  ) ) )
							//Tratamento de compartilhamento da tabela SRV
							If !Empty(SRV->RV_FILIAL)
								lGeraCod := .T.
							Else
								lSemFilSRV := .T.
							EndIf

							//------------------
							//| Lógica lGeraCod
							//| .T. -> Exclusiva | .F. -> Compartilhada
							//------------------------------------------
							If lGeraCod
								cIdeRubr := Iif(!Empty(SRV->RV_FILIAL),SRV->RV_FILIAL , (xFilial("SRV"),SRV->RV_FILIAL) )
							Else
								If cVersaoEnv >= "2.3"
									cIdeRubr := cEmpAnt
								Else
									cIdeRubr := ""
								EndIf
							Endif

							If lMiddleware
								If lPrimIdT
									lPrimIdT  := .F.
									cIdTabRub := fGetIdRJF( Iif(!Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, (xFilial("SRV"), SRV->RV_FILIAL) ), cIdeRubr )
									If Empty(cIdTabRub)
										aAdd(aErros, OemToAnsi(STR0140) + cIdeRubr + OemToAnsi(STR0141))//"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
										DisarmTransaction()
										Return .F.
									EndIf
								EndIf
								cIdeRubr := cIdTabRub
							EndIf

							cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
							If (SRV->RV_PERC - 100) < 0
								cPrcRubr :=	0	//Percent da Rubrica
							Else
								cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
							EndIf

							//----------------------------------------
							//| Recuperar a natureza da verba
							//| Se estiverem vazias, vão para a geração do log
							//-------------------------------------------------
							If Empty( SRV->RV_NATUREZ )
								If( Len(aErros) == 0 )
									aAdd(aErros, OemToAnsi( STR0054 ))
									aAdd(aErros, SRV->RV_COD + " - " + AllTrim( SRV->RV_DESC ) + " ")
								Else
									aAdd(aErros, SRV->RV_COD + " - " + AllTrim( SRV->RV_DESC ) + " ")
								EndIf
							ElseIf ((cVersaoEnv < '2.6.00' .And. SRV->RV_NATUREZ == "9219") .Or. cVersaoEnv >= '2.6.00') .And. !lCarrDep
								//-----------------
								//| Plano de Saude
								//| Se a verba corrente tiver natureza de rubrica '9219' de plano de saude
								//| Entra na tabela RHR - Plano de Saude, localiza o registro do funcionário
								//| Verifica se o registro foi integrado com a folha, se sim: alimenta array
								//---------------------------------------------------------------------------
								//se o cálculo do plano de saúde estiver fechado, ler RHS, senão RHR
								aAreaRCH := GetArea()
								DbSelectArea("RCH")
								RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" ) ) )
								cProces  := SRA->RA_PROCES
								cPeriodo := ANoMes(M->RG_DATADEM)
								cNumPag  := M->RG_SEMANA
								RCH->( dbSeek( xFilial("RCH") + cProces + cTipoPLA + cPeriodo + cNumPag ) )
								If Empty(RCH->RCH_DTFECH)
									cTabRH := "RHR"
								Else
									cTabRH := "RHS"
								EndIf
								RestArea(aAreaRCH)
								GetRAssMed( SRA->RA_FILIAL, SRA->RA_MAT, "S016", cVersaoEnv, ANoMes(M->RG_DATADEM), @aDadosTRHR, @aDadosDRHR, cTabRH, @lCPFDepOk, @aDepAgreg )
								lCarrDep := .T.
								cVbPla 	 += SRV->RV_COD + "/"
							EndIf

						EndIf
						RestArea(aAreaSRV)

						if lRJs // usa controle na RJ5
						//------------------------------------------------
							//| Lotação
							//| Guarda a area atual, entra na RJ5 e recupera os dados do cc
							//---------------------------------------------------------------

							aAreaCTT := GetArea()
							aAreaRJ5 := GetArea()
							aAreaRJ3 := GetArea()

							DBSelectArea("CTT")
							CTT->(DbSetOrder(1))
							If( CTT->( dbSeek( xFilial("CTT", SRA->RA_FILIAL) + aPd[nI,2]  ) ) )
								DBSelectArea("RJ5")
								RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
								If( RJ5->( dbSeek( xFilial("RJ5") + aPd[nI,2] ) ) )
									//Se o campo RJ5_FILT existe pesquisa por este registro preenchido
									If lRJ5FilT
										RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
										RJ5->(dbGoTop())
										If RJ5->( dbSeek( xFilial("RJ5") + aPd[nI,2]  + SRA->RA_FILIAL ) )
											lTemReg := .T.
										EndIf
										//Se não encontrou um registro com código preenchido reposiciona a tabela e executa o dbseek novamente.
										If !lTemReg
											RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
											RJ5->(dbGoTop())
											RJ5->( dbSeek( xFilial("RJ5") + aPd[nI,2] ) )
										EndiF
									EndIf
									if EMPTY(RJ5->RJ5_TPIO) .AND. EMPTY(RJ5->RJ5_NIO) // LOTACAO
										DBSelectArea("RJ3")
										RJ3->(DbSetOrder(2)) //RJ3_FILIAL+RJ3_COD+RJ3_INI+RJ3_TPLOT
										If( RJ3->( dbSeek( xFilial("RJ3") + RJ5->RJ5_COD ) ) )
											cCodLot  := IIf(lSemFilCTT, RJ3->RJ3_COD, RJ3->RJ3_FILIAL + RJ3->RJ3_COD )
											cTpInscr := ""
											cInscr 	 := ""
										ENDIF
									elseif !EMPTY(RJ5->RJ5_TPIO) .AND. !EMPTY(RJ5->RJ5_NIO) // OBRA PROPRIA
										cCodLot := IIf(lSemFilCTT, RJ5->RJ5_COD, RJ5->RJ5_FILIAL + RJ5->RJ5_COD )
										If RJ5->RJ5_TPIO == "4"
											cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
											cInscr 		:= RJ5->RJ5_NIO // Codigo da inscricao
											cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
										Endif
									ENDIF
								else
									MsgAlert(OemToAnsi(STR0116) + alltrim(aPd[nI,2]) + OemToAnsi(STR0117) + alltrim(SRA->RA_MAT) + OemToAnsi(STR0118), OemToAnsi(STR0001) ) //  "Atencao"
									Return .F.
								Endif

								//Verifica na tabela F0F se a Filial eh uma obra
								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									cCEIObra := ""
									If fBuscaOBRA( cFilEnv, @cCEIObra )
										cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
										cInscr 		:= cCEIObra // Codigo da inscricao
										cChaveS1005	:= cFilEnv+cInscr
									Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
										cTpInscr 	:= "3"
										cInscr	 	:= cCAEPF
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									nPosEstb := eVal(bEstab)
									If nPosEstb > 0
										cTpInscr	:= aEstb[nPosEstb,3]
										cInscr		:= aEstb[nPosEstb,2]
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If(nPosCC == 0)
									aAdd(aDadosCCT, {RJ5->RJ5_CC, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
								EndIf

								RestArea(aAreaRJ5)
								RestArea(aAreaCTT)
								RestArea(aAreaRJ3)
							EndIf

						else
							//------------------------------------------------
							//| Centro de Custo
							//| Guarda a area atual, entra na CTT e recupera os dados do cc
							//---------------------------------------------------------------
							aAreaCTT := GetArea()
							DBSelectArea("CTT")
							CTT->(DbSetOrder(1))
							If( CTT->( dbSeek( xFilial("CTT", SRA->RA_FILIAL) + aPd[nI,2]  ) ) )
								cCodLot := IIf(lSemFilCTT, CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
								cTpLot  := CTT->CTT_TPLOT	// Tipo de Lotação (?!?)
								//Verifica se eh uma obra por meio do campo CTT_TIPO2
								If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
								cTpInscr := CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
								cInscr := CTT->CTT_CEI2 // Codigo da inscricao
									cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
								Endif
								//Verifica na tabela F0F se a Filial eh uma obra
								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									cCEIObra := ""
									If fBuscaOBRA( cFilEnv, @cCEIObra )
										cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
										cInscr 		:= cCEIObra // Codigo da inscricao
										cChaveS1005	:= cFilEnv+cInscr
									Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
										cTpInscr 	:= "3"
										cInscr		:= cCAEPF
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
									nPosEstb := eVal(bEstab)
									If nPosEstb > 0
										cTpInscr	:= aEstb[nPosEstb,3]
										cInscr		:= aEstb[nPosEstb,2]
										cChaveS1005	:= cFilEnv+cInscr
									EndIf
								EndIf

								If(nPosCC == 0)
									aAdd(aDadosCCT, {CTT->CTT_CUSTO, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
								EndIf

								RestArea(aAreaCTT)
							EndIf
						Endif

						RestArea(aAreaCTT)

						//------------------------------------------------
						//| Array de Dados
						//| Montagem do array com os dados a utilizar para o XML
						//-------------------------------------------------------
						If( nPosCCPD > 0 )
							aCols[nPosCCPD, 15] += aPd[nI,4]	//Incrementa Horas
							aCols[nPosCCPD, 17] += aPd[nI,5]	//Incrementa Valor
							aCols[nPosCCPD, 18] := aCols[nPosCCPD, 18] + 1	  	//Incrementa Contador
						Else
							aAdd(aCols, { 	aPd[nI,2]+ aPd[nI,1],;	//01 - Chave para pesquisa (CC+PD)
												"Dados da Verba",;			//02 - Separador - Verbas/Rubricas
												cCodRubr,;					//03 - Codigo da Rubrica
												cIdeRubr,;					//04 - Ident   da Rubrica
												cPrcRubr,;					//05 - Percent da Rubrica
												"Dados do CC",;				//06 - Separador - Centro de Custo
												cCodLot,;					//07 - Codigo da Lotação
												cTpInscr,;					//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
												cInscr,;					//09 - Codigo da inscricao
												cTpLot,;					//10 - Tipo de Lotação (?!?)
												"Dados da Grid",;			//11 - Separador - Centro de Custo
												aPd[nI,2],;					//12 - Centro de Custo
												aPd[nI,1],;					//13 - Verba da rescisão
												"",;						//14 - Descricao da verba
												aPd[nI,4],;					//15 - Horas da verba
												aPd[nI,5],;					//16 - Valor da verba
												aPd[nI,5],;					//17 - Acumulado da verba (valor inicial para soma)
												1,;							//18 - Numero de registro repetidos (CC + PD)
												SRV->RV_NATUREZ,;			//19 - Natureza da verba
												SRV->RV_INCCP,;				//20 - Incidência CP da verba
												SRV->RV_INCFGTS,;			//21 - Incidência FGTS da verba
												SRV->RV_INCIRF,;			//22 - Incidência IRRF da verba
												SRV->RV_TIPOCOD,;			//23 - Tipo da verba
												If(lRVIncop,SRV->RV_INCOP,""),;	 //24 - Incid RPPS
												If(lRVTetop,SRV->RV_TETOP,"")})  //25 - Teto Remun


						EndIf
					EndIf
					//----------------------
					//| Liquido da Rescisão
					//| Se a verba corrente tiver o ID de Calculo igual
					//| a 0126 O Sistema receberá o valor líquido da rescisão
					//--------------------------------------------------------
					If RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_CODFOL" ) $ "0126"
						nValor := aPd[nI,5]
					EndIf

					//---------------------
					//| Pensão Alimenticia
					//| Se a verba corrente tiver valor de DIRF igual aos informados
					//| Realizará a soma do montante pago de pensão Alimenticia
					//-----------------------------------------------------------
					If ( ( cVersaoEnv < "2.6.00" .And. SubStr(RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_INCIRF" ), 1, 2) $ "51|52|53|54|55" ) .Or.;
						( cVersaoEnv >= "2.6.00" .And. RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_INCIRF" ) $ "51  |52  |53  |54  |55  " ) )
						nPensao += aPd[nI,5]
					EndIf

					//------------------------------
					//| Verba de Multiplos Vinculos
					//| Se a verba corrente, tiver seu ID de Calculo igual a 0318
					//| realizará a procura dos multiplos vínculos do funcionário
					//------------------------------------------------------------
					If RetValSrv( aPd[nI,1], SRA->RA_FILIAL, "RV_CODFOL" ) $ "0318"
						aAreaRAZ := GetArea()
						DBSelectArea("RAZ")
						RAZ->(DbSetOrder(1))
						If( RAZ->( dbSeek( SRA->RA_FILIAL + SRA->RA_MAT ) ) )
							aDadosRAZ := GetMulVin( SRA->RA_FILIAL , SRA->RA_MAT, M->RG_PERIODO)
						EndIf
						RestArea(aAreaCTT)
					EndIf

					//Restaura o centro de custo
					If lAltCC
						aPd[nI, 2] := cCCAnt
					EndIf

				Next nI

				//Tratando o Log
				If( Len(aErros) > 1 ) //Maior que 1 pois sempre vai existir o cabeçalho do log de erros
					aAdd(aErros, OemToAnsi( STR0055 ) + " " + OemToAnsi( STR0056 ) ) //"estão sem código de rubrica cadastrada (RV_NATUREZ)." "Não será possível integração com o TAF e a efetivação da rescisão."
					DisarmTransaction()
					Return !lGravou
				EndIf

				//Ordena o Array separando por centro de custo
				//ASORT(aCols, , , { | x,y | x[2] < y[2] } )
				If !Empty(SRA->RA_CC) .AND. Len(aCC) > 0
					nPosLot := aScan(aCC, {|x| x[1] == FWxFilial("CTT") .AND. x[2] == SRA->RA_CC} )
					If nPosLot > 0
						cTpInscr := aCC[nPosLot,3]
						cInscr := aCC[nPosLot,4]
					EndIf
				EndIf

				If Empty(cTpInscr) .OR. Empty(cInscr)
					nPosEstb := eVal(bEstab)
					If nPosEstb > 0
						cTpInscr := aEstb[nPosEstb,3]
						cInscr := aEstb[nPosEstb,2]
					EndIf
				EndIf

				if !lMiddleware
					fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
				endif

				If Empty(cFilEnv)
					cFilEnv:= cFilAnt
				EndIf

				fBusCadBenef(@aCodBenef,"FOL")
				For nI := 1 to len(aCodBenef)
					If ( aCodBenef[nI,15] == "S" ) //Apenas se Imprime % no Termo de Rescisao.
						nPerPens += aCodBenef[nI,2]
					EndIf
				Next nI

				nI := 0

				//Carregad Dados do Tabela S037, passando a data da Demissão como parâmetro.
				fCarrTab( @aTabS037, "S037", dDataRes, .T. , , , SRA->RA_FILIAL)
				For nCntS037 :=1 to Len(aTabS037)
					cSimples := aTabS037[nCntS037,11] // Simples Nacional
					If cSimples == "1"
						cIndSimp := aTabS037[nCntS037,18] // Indicador do Tipo de Simples Nacional.
					EndIf
				Next nCntS037

				If AllTrim(aIncRes[02]) $ "I/A"
					dDtProj := dDataRes + cDiaInde + 1
				EndIf

				//-------------------
				//| Inicio do XML
				//-------------------

				If lMiddleware
					aInfos   := fXMLInfos()
					IF Len(aInfos) >= 4
						cTpInsc  := aInfos[1]
						lAdmPubl := aInfos[4]
						cNrInsc  := aInfos[2]
						cId  	 := aInfos[3]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf

					cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(SRA->RA_CODUNIC, 40, " ")
					cStat2299 	:= "-1"
					GetInfRJE( 2, cChaveBus, @cStat2299, @cOper2299, @cRetf2299, @nRec2299, @cRecib2299, @cRecibAnt, Nil, Nil, .T. )

					//Retorno pendente impede o cadastro
					If cStat2299 == "2" .And. cEFDAviso != "2"
						cMsgRJE 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
					EndIf
					//Inclusão
					If nOperation != 5
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2299 == "E" .And. cStat2299 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						ElseIf cStat2299 == "99"
							cMsgRJE 	:= STR0146//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
						//Não existe na fila, será tratado como inclusão
						ElseIf cStat2299 == "-1"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento sem transmissão, irá sobrescrever o registro na fila
						ElseIf cStat2299 $ "1/3"
							cOperNew 	:= cOper2299
							cRetfNew	:= cRetf2299
							cStatNew	:= "1"
							lNovoRJE	:= .F.
						//Evento diferente de exclusão transmitido, irá gerar uma retificação
						ElseIf cOper2299 != "E" .And. cStat2299 == "4"
							cOperNew 	:= "A"
							cRetfNew	:= "2"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento de exclusão transmitido, será tratado como inclusão
						ElseIf cOper2299 == "E" .And. cStat2299 == "4"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					//Exclusão
					Else
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2299 == "E" .And. cStat2299 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						//Evento diferente de exclusão transmitido irá gerar uma exclusão
						ElseIf cOper2299 != "E" .And. cStat2299 == "4"
							cOperNew 	:= "E"
							cRetfNew	:= cRetf2299
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					EndIf
					If !Empty(cMsgRJE)
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgRJE, 1, 0 )//" não enviado(a) ao Middleware. Erro: "
						DisarmTransaction()
						Return .F.
					EndIf
					If cRetfNew == "2"
						If cStat2299 == "4"
							cRecibXML 	:= cRecib2299
							cRecibAnt	:= cRecib2299
							cRecib2299	:= ""
						Else
							cRecibXML 	:= cRecibAnt
						EndIf
					EndIf
					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2299", Space(6), SRA->RA_CODUNIC, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2299, cRecibAnt } )
					cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtDeslig/v" + cVersMw + "'>"
					cXML += 	"<evtDeslig Id='" + cId + "'>"
					fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cGpeAmbe, 1, "12" }, cVersaoEnv, aInfos)
					fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )

				else

					cXml := "<eSocial>"
					cXml += "	<evtDeslig>"
				endif

				//Dados do Trabalhador
				cXml += "		<ideVinculo>"
				cXml += "			<cpfTrab>" + AllTrim(SRA->RA_CIC) + "</cpfTrab>"
				If cVersaoEnv < "9.0.00"
					cXml += "			<nisTrab>" + AllTrim(SRA->RA_PIS) + "</nisTrab>"
				Endif
				If !Empty(SRA->RA_CODUNIC)
					cMatricula := If(!lMiddleware, StrTran(SRA->RA_CODUNIC, "&","&#38;" ),SRA->RA_CODUNIC )
				EndIf

				cXml += "			<matricula>" + AllTrim(cMatricula) + "</matricula>"
				cXml += "		</ideVinculo>"

				//Dados do Desligamento
				cXml += "		<infoDeslig>"
				cXml += "			<mtvDeslig>" + cCodDslg + "</mtvDeslig>"
				If !lMiddleware
					cXml += "			<dtDeslig>" + Dtos(M->RG_DATADEM) + "</dtDeslig>"
				Else
					cXml += "			<dtDeslig>" + SubStr( dToS(M->RG_DATADEM), 1, 4 ) + "-" + SubStr( dToS(M->RG_DATADEM), 5, 2 ) + "-" + SubStr( dToS(M->RG_DATADEM), 7, 2 ) + "</dtDeslig>"
				EndIf
				If cVersaoEnv >= "9.0.00"
					If !lMiddleware
						cXml += "			<dtAvPrv>" + Dtos(M->RG_DTAVISO) + "</dtAvPrv>"
					Else
						cXml += "			<dtAvPrv>" + SubStr( dToS(M->RG_DTAVISO), 1, 4 ) + "-" + SubStr( dToS(M->RG_DTAVISO), 5, 2 ) + "-" + SubStr( dToS(M->RG_DTAVISO), 7, 2 ) + "</dtAvPrv>"
					Endif
				Endif
				cXml += "			<indPagtoAPI>" + IIf(AllTrim(aIncRes[02]) $ "I/A","S","N") + "</indPagtoAPI>"
				If !Empty(dDtProj) .And. AllTrim(aIncRes[02]) $ "I/A"
					If !lMiddleware
						cXml +=			'<dtProjFimAPI>' + Dtos(dDtProj) + '</dtProjFimAPI>'
					Else
						cXml +=			'<dtProjFimAPI>' + SubStr( dToS(dDtProj), 1, 4 ) + "-" + SubStr( dToS(dDtProj), 5, 2 ) + "-" + SubStr( dToS(dDtProj), 7, 2 ) + '</dtProjFimAPI>'
					EndIf
				EndIf

				If cVersaoEnv < "9.0.00" .Or. (cVersaoEnv >= "9.0.00" .And. nTpRegTrab == 0 )
					//Pensao Alimenticia
					if nPerPens <> 0 .and. nPensao <> 0
						cXml +=				'<pensAlim>3</pensAlim>'
					elseif nPerPens == 0 .and. nPensao == 0
						cXml +=				'<pensAlim>0</pensAlim>'
					elseif nPerPens <> 0 .and. nPensao == 0
						cXml +=				'<pensAlim>1</pensAlim>'
					elseif nPerPens == 0 .and. nPensao <> 0
						cXml +=				'<pensAlim>2</pensAlim>'
					Endif
				Endif
				//Percentual Alimenticio
				if nPerPens <>0
					cXml +=				'<percAliment>' + Str(nPerPens) + '</percAliment>'
				endif

				//VR Alimentacao
				if nPensao <>0
					cXml +=				'<vrAlim>' + If(lMiddleware, Alltrim(Str(nPensao)), Str(nPensao)) + '</vrAlim>'
				endif

				If cVersaoEnv < "9.0.00"
					//Numero Certidao Obito
					If Iif(cVersaoEnv >= '2.5.00', cCodDslg $ "10", cCodDslg $ "09*10") .And. !Empty(AllTrim(M->RG_OBITO))
						cXml +=			'<nrCertObito>' + AllTrim(M->RG_OBITO) + '</nrCertObito>'
					EndIf
				Endif

				//Numero Processo Trabalhista
				If !Empty(AllTrim(M->RG_NPROC))
					cXml +=			'<nrProcTrab>' + AllTrim(M->RG_NPROC) + '</nrProcTrab>'
				EndIf
				If cVersaoEnv < "9.0.00"
					//Detalhes Indicador Cumprimento Aviso Previo Parcial
					If !lNT15 .Or. !Empty(cIndAvPrv)
						cXml += "			<indCumprParc>" + AllTrim(cIndAvPrv) + "</indCumprParc>"
					EndIf
					If lIntermit
						cXml += "			<qtdDiasInterm>" + cDiaSV7 + "</qtdDiasInterm>"
					EndIF
				Endif
				If cVersaoEnv >= "9.0.00" .And. lIntermit
					If Len(aDiasConv) > 0
						cXml +=         '<infoInterm>'
						For nC := 1 to Len(aDiasConv)
							cXml +=         '<dia>' + AllTrim(aDiasConv[nC]) + '</dia>'
						Next nC
						cXml +=         '</infoInterm>'
					Endif
				Endif

				If !Empty(AllTrim(M->RG_OBS))
					cXml +=        '<observacoes>'
					cXml +=				'<observacao>' + AllTrim(M->RG_OBS) + '</observacao>'
					cXml +=			'</observacoes>'
				EndIf

				//Sucessao Vinculos
				If !Empty(AllTrim(M->RG_SUCES))
					cXml +=			'<sucessaoVinc>'
					If cVersaoEnv >= "9.0.00"
						cXml +=				'<nrInsc>' + AllTrim(M->RG_SUCES) +'</nrInsc>'
						IF SRG->(ColumnPos("RG_TPSU")) > 0 .AND. AllTrim(M->RG_TPSU) $ "1|2"
							cXml +=				'<tpInsc>' + AllTrim(M->RG_TPSU) +'</tpInsc>'
						ENDIF
					Else
						cXml +=				'<cnpjSucessora>' + AllTrim(M->RG_SUCES) +'</cnpjSucessora>'
						IF cVersaoEnv >= "2.5.00" .AND. SRG->(ColumnPos("RG_TPSU")) > 0 .AND. AllTrim(M->RG_TPSU) $ "1|2"
							cXml +=				'<tpInscSuc>' + AllTrim(M->RG_TPSU) +'</tpInscSuc>'
						ENDIF
					Endif
					cXml +=			'</sucessaoVinc>'
				Endif

				//Só gera as verbas caso o MV_FASESOC esteja igual a 2 (Manutenção, Não Periódicos e Periódicos)
				//Para Servidor Publico e Leiaute 1.0 nao gera
				If lXmlVerbas .And. (cVersaoEnv < "9.0" .Or. nTpRegTrab == 0 )
					If lMiddleware
						fExcRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, "S-2299" )
					EndIf

					//Verbas de Rescisao
					cXml += "			<verbasResc>"

					//Looping para varrer as verbas
					cXml += "				<dmDev>"
					If !lMiddleware
						cXml += "					<ideDmDev>" + cIdDmDev + "</ideDmDev>"
					Else
						cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) + "</ideDmDev>"
					Endif
					cXml += "					<infoPerApur>"

					//Validação para verificar se gera o dmDev do Dissidio
					fDis2299( dDataRes, @cVBDiss, aDadosCCT, cIndSimp, @cInfoDiss, @cMsgDiss, @lRJ5Ok, @aErrosRJ5, cTpRes, aPd)
					If !Empty(aErrosRJ5)
						cMsgErro := OemToAnsi(STR0114) + CRLF//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							cMsgErro += aErrosRJ5[nI] + CRLF
						Next
						cMsgErro += OemToAnsi(STR0115)//" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						Help( ,, OemToAnsi(STR0001) ,, cMsgErro, 1, 0 )//"Atenção"
						DisarmTransaction()
						Return .F.
					EndIf

					If !Empty(cMsgDiss)
						aAdd(aErros, OemToAnsi( STR0100 ) + " " + OemToAnsi( STR0056 ) ) //"Preenchimento incorreto das tabelas S050/S126. As informações de dissídio não foram geradas."#"Não será possível integração com o TAF e a efetivação da rescisão."
						Help(,,,OemToAnsi(STR0001),OemToAnsi(STR0100),1,0) //"Atenção"#"Preenchimento incorreto das tabelas S050/S126. As informações de dissídio não foram geradas."#
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para detalhar os Centros de Custos que o Trab Atuou
					For nZ := 1 To Len( aDadosCCT )
						cXml += "						<ideEstabLot>"
						cXml += "							<tpInsc>" + aDadosCCT[nZ,2] + "</tpInsc>"
						cXml += "							<nrInsc>" + aDadosCCT[nZ,3] + "</nrInsc>"
						If !lMiddleware
							cXml += "							<codLotacao>" + StrTran( aDadosCCT[nZ,4], "&", "&amp;") + "</codLotacao>"
						Else
							cXml += "							<codLotacao>" + Alltrim(StrTran( aDadosCCT[nZ,4], "&", "&amp;")) + "</codLotacao>"
						Endif
						//Looping nas verbas vindas
						For nX := 1 To Len( aCols )
							//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
							If Empty(cVBDiss) .Or. !( aCols[nX,3] $ cVBDiss ) //Nao leva verbas do dissidio
								If( aCols[nX, 12] == aDadosCCT[nZ,1] .AND. aCols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + aCols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + aCols[nX,4] + "</ideTabRubr>"
									cXml += "								<qtdRubr>" + Str(aCols[nX,15]) + "</qtdRubr>"
									cXml += "								<fatorRubr>" + AllTrim( Transform(aCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									If cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "								<vrUnit>" + AllTrim( Transform(aCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "								<vrUnit>" + AllTrim( Str(aCols[nX,16]) ) + "</vrUnit>"
										EndIf
									Endif
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(aCols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(aCols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If aCols[nX,3] $ cVbPla
										lGerPla := .T.
									EndIf
									If lMiddleware .And. ( (aCols[nX, 19] == "9901" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9201" .And. aCols[nX, 20] $ "31/32") .Or. (aCols[nX, 19] == "1409" .And. aCols[nX, 20] == "51") .Or. (aCols[nX, 19] == "4050" .And. aCols[nX, 20] == "21") .Or. (aCols[nX, 19] == "4051" .And. aCols[nX, 20] == "22") .Or. (aCols[nX, 19] == "9902" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9904" .And. aCols[nX, 23] == "3") .Or. (aCols[nX, 19] == "9908" .And. aCols[nX, 23] == "3") )
										fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nZ, 2], aDadosCCT[nZ, 3], aDadosCCT[nZ, 4], aCols[nX, 19], aCols[nX, 23], aCols[nX, 20], aCols[nX, 21], aCols[nX, 22], aCols[nX, 17], "S-2299" , , , ,aCols[nX, 24], aCols[nX, 25] )
 									EndIf
								EndIf
							EndIf
						Next

						//Plano de Saude
						If Len(aDadosTRHR) > 0 .And. lGerPla .And. cVersaoEnv < "9.0.00"
							cXml += "							<infoSaudeColet>"
							For nW := 1 To Len(aDadosTRHR)
								cXml += "								<detOper>"
								cXml += "									<cnpjOper>" + aDadosTRHR[nW,6] + "</cnpjOper>"
								cXml += "									<regANS>" + aDadosTRHR[nW,7] + "</regANS>"
								If !lMiddleware
									cXml += "									<vrPgTit>" + AllTrim( Transform(aDadosTRHR[nW,8],"@E 999999999.99") ) + "</vrPgTit>"
								Else
									cXml += "									<vrPgTit>" + AllTrim( Str(aDadosTRHR[nW,8]) ) + "</vrPgTit>"
								EndIf
								If lVer2_3 .And. Len(aDadosDRHR) > 0
									For nD := 1 To Len(aDadosDRHR)
										If ( aDadosTRHR[nW][6] + aDadosTRHR[nW][7] == aDadosDRHR[nD][7] + aDadosDRHR[nD][8] ) // Chave CNPJ Fornecedor + ANS
											cXml += "								<detPlano>"
											cXml += "				                 <tpDep>"+aDadosDRHR[nD,5]+"</tpDep>"
											cXml += "									<cpfDep>" + aDadosDRHR[nD,1] + "</cpfDep>"
											cXml += "									<nmDep>" + aDadosDRHR[nD,2] + "</nmDep>"
											If !lMiddleware
												cXml += "									<dtNascto>" + aDadosDRHR[nD,3] + "</dtNascto>"
											Else
												cXml += "									<dtNascto>" + SubStr( aDadosDRHR[nD,3], 1, 4 ) + "-" + SubStr( aDadosDRHR[nD,3], 5, 2 ) + "-" + SubStr( aDadosDRHR[nD,3], 7, 2 ) + "</dtNascto>"
											EndIf
											If !lMiddleware
												cXml += "									<vlrPgDep>" + AllTrim( Transform(aDadosDRHR[nD,4],"@E 999999999.99") ) + "</vlrPgDep>"
											Else
												cXml += "									<vlrPgDep>" + AllTrim( Str(aDadosDRHR[nD,4]) ) + "</vlrPgDep>"
											EndIf
											cXml += "								</detPlano>"
										Endif
									Next
								EndIf

								cXml += "								</detOper>"
							Next
							cXml += "							</infoSaudeColet>"
							aDadosTRHR := {}
						EndIf

						If SRA->RA_TPPREVI == "1"
							S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
						EndIf
						If !Empty(cIndSimp)
							cXml += "							<infoSimples>"
							cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
							cXml += "							</infoSimples>"
						Endif
						cXml += "						</ideEstabLot>"
					Next

					cXml += "					</infoPerApur>"

					//Transfere para o XML as informações do Dissidio calculado na rescisao
					If !Empty( cInfoDiss )
						cXml += cInfoDiss
					EndIf

					cXml += "				</dmDev>"

					//Validação para verificar se gera o dmDev do PLR pago antes da rescisão no mesmo período
					fPLR2299( @cXml, oModel, aDadosCCT, cIndSimp, dDataRes)

					//Validação para verificar se gera o dmDev do ADI
					fADI2299( @aAdiCC, @aAdiCols, cFilEnv, @cIdDmDev, cVersaoEnv, lRetif, @aErrosRJ5)

					If !Empty(aErrosRJ5)
						aAdd( aErros, OemToAnsi(STR0114) )//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							aAdd( aErros, aErrosRJ5[nI] )
						Next
						aAdd( aErros, OemToAnsi(STR0115) ) //" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para varrer as verbas
					If Len(aAdiCols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( aAdiCC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + aAdiCC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + aAdiCC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( aAdiCC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( aAdiCC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif

							//Looping nas verbas vindas
							For nX := 1 To Len( aAdiCols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( aAdiCols[nX, 12] == aAdiCC[nZ,1] .AND. aAdiCols[nX, 17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + aAdiCols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + aAdiCols[nX,4] + "</ideTabRubr>"
									cXml += "								<qtdRubr>" + Str(aAdiCols[nX,15]) + "</qtdRubr>"
									cXml += "								<fatorRubr>" + AllTrim( Transform(aAdiCols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									If cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "								<vrUnit>" + AllTrim( Transform(aAdiCols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "								<vrUnit>" + AllTrim( Str(aAdiCols[nX,16]) ) + "</vrUnit>"
										EndIf
									Endif
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(aAdiCols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(aAdiCols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If lMiddleware .And. ( (aAdiCols[nX, 21] == "9901" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9201" .And. aAdiCols[nX, 22] $ "31/32") .Or. (aAdiCols[nX, 21] == "1409" .And. aAdiCols[nX, 22] == "51") .Or. (aAdiCols[nX, 21] == "4050" .And. aAdiCols[nX, 22] == "21") .Or. (aAdiCols[nX, 21] == "4051" .And. aAdiCols[nX, 22] == "22") .Or. (aAdiCols[nX, 21] == "9902" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9904" .And. aAdiCols[nX, 25] == "3") .Or. (aAdiCols[nX, 21] == "9908" .And. aAdiCols[nX, 25] == "3") )
										fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aAdiCC[nZ, 2], aAdiCC[nZ, 3], aAdiCC[nZ, 4], aAdiCols[nX, 21], aAdiCols[nX, 25], aAdiCols[nX, 22], aAdiCols[nX, 23], aAdiCols[nX, 24], aAdiCols[nX, 17], "S-2299" , , , ,aAdiCols[nX, 26], aAdiCols[nX, 27] )
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next

						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf

					//Validação para verificar se gera o dmDev do 131
					f1312299( @a131CC, @a131Cols, cFilEnv, @cIdDmDev, lRetif, @aErrosRJ5,cVersaoEnv)

					If !Empty(aErrosRJ5)
						aAdd( aErros, OemToAnsi(STR0114) )//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							aAdd( aErros, aErrosRJ5[nI] )
						Next
						aAdd( aErros, OemToAnsi(STR0115) ) //" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para varrer as verbas
					If Len(a131Cols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( a131CC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + a131CC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + a131CC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( a131CC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( a131CC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif

							//Looping nas verbas vindas
							For nX := 1 To Len( a131Cols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( a131Cols[nX, 12] == a131CC[nZ,1] .And. a131Cols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + a131Cols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + a131Cols[nX,4] + "</ideTabRubr>"
									cXml += "								<fatorRubr>" + AllTrim( Transform(a131Cols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									If cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "								<vrUnit>" + AllTrim( Transform(a131Cols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "								<vrUnit>" + AllTrim( Str(a131Cols[nX,16]) ) + "</vrUnit>"
										EndIf
									Endif
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(a131Cols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(a131Cols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If lMiddleware .And. ( (a131Cols[nX, 21] == "9901" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9201" .And. a131Cols[nX, 22] $ "31/32") .Or. (a131Cols[nX, 21] == "1409" .And. a131Cols[nX, 22] == "51") .Or. (a131Cols[nX, 21] == "4050" .And. a131Cols[nX, 22] == "21") .Or. (a131Cols[nX, 21] == "4051" .And. a131Cols[nX, 22] == "22") .Or. (a131Cols[nX, 21] == "9902" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9904" .And. a131Cols[nX, 25] == "3") .Or. (a131Cols[nX, 21] == "9908" .And. a131Cols[nX, 25] == "3") )
										fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, a131CC[nZ, 2], a131CC[nZ, 3], a131CC[nZ, 4], a131Cols[nX, 21], a131Cols[nX, 25], a131Cols[nX, 22], a131Cols[nX, 23], a131Cols[nX, 24], a131Cols[nX, 17], "S-2299" , , , ,a131Cols[nX, 26], a131Cols[nX, 27] )
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next

						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf

					//Validação para verificar se gera o dmDev do 132
					f1322299( @a132CC, @a132Cols, cFilEnv, @cIdDmDev, lRetif, @aErrosRJ5,cVersaoEnv, aFilInTaf,lAdmPubl, cTpInsc, cNrInsc )

					If !Empty(aErrosRJ5)
						aAdd( aErros, OemToAnsi(STR0114) )//"Não será possível efetuar a integração. O(s) centro(s) de custo: "
						For nI := 1 To Len(aErrosRJ5)
							aAdd( aErros, aErrosRJ5[nI] )
						Next
						aAdd( aErros, OemToAnsi(STR0115) ) //" não está(ão) cadastrado(s) na tabela RJ5 - Relacionamentos CTT."
						DisarmTransaction()
						Return .F.
					EndIf

					//Looping para varrer as verbas
					If Len(a132Cols) > 0
						cXml += "				<dmDev>"
						If !lMiddleware
							cXml += "					<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
						Else
							cXml += "					<ideDmDev>" + Alltrim(cIdDmDev) +  "</ideDmDev>"
						Endif
						cXml += "					<infoPerApur>"

						//Looping para detalhar os Centros de Custos que o Trab Atuou
						For nZ := 1 To Len( a132CC )
							cXml += "						<ideEstabLot>"
							cXml += "							<tpInsc>" + a132CC[nZ,2] + "</tpInsc>"
							cXml += "							<nrInsc>" + a132CC[nZ,3] + "</nrInsc>"
							If !lMiddleware
								cXml += "							<codLotacao>" + StrTran( a132CC[nZ,4], "&", "&amp;") + "</codLotacao>"
							Else
								cXml += "							<codLotacao>" + Alltrim(StrTran( a132CC[nZ,4], "&", "&amp;")) + "</codLotacao>"
							Endif

							//Looping nas verbas vindas
							For nX := 1 To Len( a132Cols )
								//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
								If( a132Cols[nX, 12] == a132CC[nZ,1] .And. a132Cols[nX,17] > 0 )
									cXml += "							<detVerbas>"
									cXml += "								<codRubr>" + a132Cols[nX,3] + "</codRubr>"
									cXml += "								<ideTabRubr>" + a132Cols[nX,4] + "</ideTabRubr>"
									cXml += "								<fatorRubr>" + AllTrim( Transform(a132Cols[nX,5],"@E 999999999.99") ) + "</fatorRubr>"
									If cVersaoEnv < "9.0.00"
										If !lMiddleware
											cXml += "								<vrUnit>" + AllTrim( Transform(a132Cols[nX,16],"@E 999999999.99") ) + "</vrUnit>"
										Else
											cXml += "								<vrUnit>" + AllTrim( Str(a132Cols[nX,16]) ) + "</vrUnit>"
										EndIf
									Endif
									If !lMiddleware
										cXml += "								<vrRubr>" + AllTrim( Transform(a132Cols[nX,17],"@E 999999999.99") ) + "</vrRubr>"
									Else
										cXml += "								<vrRubr>" + AllTrim( Str(a132Cols[nX,17]) ) + "</vrRubr>"
									EndIf
									If cVersaoEnv >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
										cXml +=         '<indApurIR>0</indApurIR>'
									Endif
									cXml += "							</detVerbas>"
									If lMiddleware .And. ( (a132Cols[nX, 21] == "9901" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9201" .And. a132Cols[nX, 22] $ "31/32") .Or. (a132Cols[nX, 21] == "1409" .And. a132Cols[nX, 22] == "51") .Or. (a132Cols[nX, 21] == "4050" .And. a132Cols[nX, 22] == "21") .Or. (a132Cols[nX, 21] == "4051" .And. a132Cols[nX, 22] == "22") .Or. (a132Cols[nX, 21] == "9902" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9904" .And. a132Cols[nX, 25] == "3") .Or. (a132Cols[nX, 21] == "9908" .And. a132Cols[nX, 25] == "3") )
										fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, a132CC[nZ, 2], a132CC[nZ, 3], a132CC[nZ, 4], a132Cols[nX, 21], a132Cols[nX, 25], a132Cols[nX, 22], a132Cols[nX, 23], a132Cols[nX, 24], a132Cols[nX, 17], "S-2299" , , , ,a132Cols[nX, 26], a132Cols[nX, 27] )
									EndIf
								EndIf
							Next

							If SRA->RA_TPPREVI == "1"
								S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
							EndIf
							If !Empty(cIndSimp)
								cXml += "							<infoSimples>"
								cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
								cXml += "							</infoSimples>"
							Endif
							cXml += "						</ideEstabLot>"
						Next

						cXml += "					</infoPerApur>"
						cXml += "				</dmDev>"
					EndIf

					If M->RG_SEMANA > "01"
						//Validação para verificar se gera o dmDev do FOL
						fFOL2299( @aFolCC, @aFolCols, cFilEnv, @aIdDmDev, cVersaoEnv, lRetif, M->RG_SEMANA )
						For nContDev := 1 To Len(aIdDmDev)
							//Looping para varrer as verbas
							If Len(aFolCols[nContDev]) > 0
								cXml += "				<dmDev>"
								If !lMiddleware
									cXml += "					<ideDmDev>" + aIdDmDev[nContDev] +  "</ideDmDev>"
								Else
									cXml += "					<ideDmDev>" + Alltrim(aIdDmDev[nContDev] ) +  "</ideDmDev>"
								Endif
								cXml += "					<infoPerApur>"

								//Looping para detalhar os Centros de Custos que o Trab Atuou
								For nZ := 1 To Len( aFolCC[nContDev] )
									cXml += "						<ideEstabLot>"
									cXml += "							<tpInsc>" + aFolCC[nContDev,nZ,2] + "</tpInsc>"
									cXml += "							<nrInsc>" + aFolCC[nContDev,nZ,3] + "</nrInsc>"
									If !lMiddleware
										cXml += "							<codLotacao>" + StrTran( aFolCC[nContDev,nZ,4], "&", "&amp;") + "</codLotacao>"
									Else
										cXml += "							<codLotacao>" + Alltrim(StrTran( aFolCC[nContDev,nZ,4], "&", "&amp;")) + "</codLotacao>"
									Endif
									//Looping nas verbas vindas
									For nX := 1 To Len( aFolCols[nContDev] )
										//Se a verba corrente, tiver o mesmo centro custo do CTT corrente
										If( aFolCols[nContDev,nX, 12] == aFolCC[nContDev,nZ,1] .AND. aFolCols[nContDev,nX,17] > 0 )
											cXml += "							<detVerbas>"
											cXml += "								<codRubr>" + aFolCols[nContDev,nX,3] + "</codRubr>"
											cXml += "								<ideTabRubr>" + aFolCols[nContDev,nX,4] + "</ideTabRubr>"
											cXml += "								<qtdRubr>" + Str(aFolCols[nContDev,nX,15]) + "</qtdRubr>"
											cXml += "								<fatorRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,5],"@E 999999999.99") ) + "</fatorRubr>"
											If cVersaoEnv < "9.0.00"
												If !lMiddleware
													cXml += "								<vrUnit>" + AllTrim( Transform(aFolCols[nContDev,nX,16],"@E 999999999.99") ) + "</vrUnit>"
												Else
													cXml += "								<vrUnit>" + AllTrim( Str(aFolCols[nContDev,nX,16]) ) + "</vrUnit>"
												EndIf
											Endif
											If !lMiddleware
												cXml += "								<vrRubr>" + AllTrim( Transform(aFolCols[nContDev,nX,17],"@E 999999999.99") ) + "</vrRubr>"
											Else
												cXml += "								<vrRubr>" + AllTrim( Str(aFolCols[nContDev,nX,17]) ) + "</vrRubr>"
											EndIf
											If cVersaoEnv >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
												cXml +=         '<indApurIR>0</indApurIR>'
											Endif
											cXml += "							</detVerbas>"
											If lMiddleware .And. ( (aFolCols[nContDev, nX, 21] == "9901" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9201" .And. aFolCols[nContDev, nX, 22] $ "31/32") .Or. (aFolCols[nContDev, nX, 21] == "1409" .And. aFolCols[nContDev, nX, 22] == "51") .Or. (aFolCols[nContDev, nX, 21] == "4050" .And. aFolCols[nContDev, nX, 22] == "21") .Or. (aFolCols[nContDev, nX, 21] == "4051" .And. aFolCols[nContDev, nX, 22] == "22") .Or. (aFolCols[nContDev, nX, 21] == "9902" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9904" .And. aFolCols[nContDev, nX, 25] == "3") .Or. (aFolCols[nContDev, nX, 21] == "9908" .And. aFolCols[nContDev, nX, 25] == "3") )
												fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aFolCC[nContDev, nZ, 2], aFolCC[nContDev, nZ, 3], aFolCC[nContDev, nZ, 4], aFolCols[nContDev, nX, 21], aFolCols[nContDev, nX, 25], aFolCols[nContDev, nX, 22], aFolCols[nContDev, nX, 23], aFolCols[nContDev, nX, 24], aFolCols[nContDev, nX, 17], "S-2299" , , , ,aFolCols[nContDev, nX, 26], aFolCols[nContDev, nX, 27] )
											EndIf
										EndIf
									Next

									If SRA->RA_TPPREVI == "1"
										S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
									EndIf
									If !Empty(cIndSimp)
										cXml += "							<infoSimples>"
										cXml += "								<indSimples>" + cIndSimp + "</indSimples>"
										cXml += "							</infoSimples>"
									Endif
									cXml += "						</ideEstabLot>"
								Next

								cXml += "					</infoPerApur>"
								cXml += "				</dmDev>"
							EndIf
						Next nContDev
					EndIf

					//Informações Multiplos Vinculos
					If ( Len( aDadosRAZ ) > 0 )
						cXml += "				<infoMV>"
						cXml += "					<indMV>" + aDadosRAZ[1,5] + "</indMV>"

						For nX := 1 To Len( aDadosRAZ )
							cXml += "					<remunOutrEmpr>"
							cXml += "						<tpInsc>" + aDadosRAZ[nX,9] + "</tpInsc>"
							cXml += "						<nrInsc>" + aDadosRAZ[nX,10] + "</nrInsc>"
							cXml += "						<codCateg>" + aDadosRAZ[nX,12] + "</codCateg>"
							cXml += "						<vlrRemunOE>" + AllTrim( Transform(aDadosRAZ[nX,11],"@E 999999999.99") ) + "</vlrRemunOE>"
							cXml += "					</remunOutrEmpr>"
						Next
						cXml += "				</infoMV>"
					EndIf
					If cVersaoEnv >= "2.4.02" .And. SRG->(ColumnPos("RG_NPROCS")) > 0 .And. !Empty(M->RG_NPROCS)
						cXml += "<procCS>"
						cXml += "   <nrProcJud>"+M->RG_NPROCS+"</nrProcJud>"
						cXml += "</procCS>"
					EndIf
					cXml += "			</verbasResc>"
				Endif
				If cVersaoEnv >= '2.4' .And. (Len(aPd_Aux) > 0 .Or. (cVersaoEnv < "2.4.02"  .And. Len(aPd_Aux) == 0 ))
					cXml += "           <consigFGTS>"
					IF Len(aPd_Aux) > 0
						If fBuscConsig(aPd_Aux)
							If cVersaoEnv <= "2.4
								cXml += "             <idConsig>S</idConsig>"
							EndIf
							cXml += "               <insConsig>" + Alltrim(SRK->RK_BCOCONS )+ "</insConsig>"
							cXml += "               <nrContr>" + Alltrim(SRK->RK_NRCONTR) + "</nrContr>"
						EndIf
					EndIf
					If cVersaoEnv < "2.4.02"  .And. (Len(aPd_Aux) == 0 .Or. !("idConsig" $ cXml))
						cXml += "               <idConsig>N</idConsig>"
					EndIf
					cXml += "           </consigFGTS>"
				EndIf

				//Fechamentos de Tags
				cXml += "		</infoDeslig>"
				cXml += "	</evtDeslig>"
				cXml += "</eSocial>"
				//-------------------
				//| Final do XML
				//-------------------
			EndIf
		Else
			If !lMiddleware
				If !Empty(SRA->RA_CODUNIC)
					cMatricula := StrTran(SRA->RA_CODUNIC, "&","&#38;" )
				EndIf
				InExc3000(@cXml,'S-2299',(SRA->RA_CIC+cMatricula),SRA->RA_CIC,SRA->RA_PIS,,)
			Else
				cStatNew := ""
				cOperNew := ""
				cRetfNew := ""
				cRecibAnt:= ""
				cKeyMid	 := ""
				nRecEvt	 := 0
				lNovoRJE := .T.
				aDados	 := {}
				aInfos   := fXMLInfos()
				If Len(aInfos) >= 4
					cTpInsc  := aInfos[1]
					lAdmPubl := aInfos[4]
					cNrInsc  := aInfos[2]
					cId  	 := aInfos[3]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(SRA->RA_CODUNIC, 40, " ")
				cStat2299 	:= "-1"
				GetInfRJE( 2, cChaveBus, @cStat2299, @cOper2299, @cRetf2299, @nRec2299, @cRecib2299, @cRecibAnt, Nil, Nil, .T. )
				If cStat2299 == "2"
					aAdd(aErrosExc, STR0134)//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
				ElseIf cStat2299 == "99"
					aAdd(aErrosExc, STR0146)//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
				Else
					InExc3000(@cXml,'S-2299',cRecib2299,SRA->RA_CIC,SRA->RA_PIS, Nil, Nil, Nil, Nil, cFilAnt, lAdmPubl, cTpInsc, cNrInsc, cId, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)
					fExcRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, "S-2299" )
				EndIf
			EndIf
		EndIf

		GrvTxtArq(alltrim(cXml), If(nOperation <> 5, "S2299", "S3000"), SRA->RA_CIC)

		If !lMiddleware
			fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
		EndIf

		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf
		aErros := {} //Limpa o campo de erro que foi utilizado acima na validação das verbas
		If lMiddleware .And. nOperation == 5
			aErros := aClone(aErrosExc)
		EndIf
		if nOperation <> 5
			If !lMiddleware
				If ValType(cTafKey) == "C"
					aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S2299", , "", , , , "GPE", , "" )
				Else
					aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2299")
				EndIf
			Else
				//Validação de predecessores
				If cEFDAviso != "2"
					//S-1005
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, aDadosCCT, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, aAdiCC, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, a131CC, lAdmPubl, cTpInsc, cNrInsc)
					For nCont := 1 To Len(aFolCC)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1005", @lS1005, aFolCC[nCont], lAdmPubl, cTpInsc, cNrInsc)
					Next nCont

					//S-1010
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, aCols, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, aAdiCols, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, a131Cols, lAdmPubl, cTpInsc, cNrInsc)
					For nCont := 1 To Len(aFolCols)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1010", @lS1010, aFolCols[nCont], lAdmPubl, cTpInsc, cNrInsc)
					Next nCont

					//S-1020
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, aDadosCCT, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, aAdiCC, lAdmPubl, cTpInsc, cNrInsc)
					fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, a131CC, lAdmPubl, cTpInsc, cNrInsc)
					For nCont := 1 To Len(aFolCC)
						fPred2299(AnoMes(M->RG_DATADEM), @aErros, "S1020", @lS1020, aFolCC[nCont], lAdmPubl, cTpInsc, cNrInsc)
					Next nCont
				EndIf
				If cEFDAviso $ "0/2" .Or. (lS1005 .And. lS1010 .And. lS1020)
					For nI := 1 To Len(aErros)
						cMsgHlp += aErros[nI] + CRLF
					Next
					If !Empty(cMsgHlp) .And. cEFDAviso == "0"
						Help( ,, OemToAnsi(STR0001) ,, cMsgHlp, 1, 0 )
					EndIf
					If !( nOperation == 5 .And. ((cOper2299 == "E" .And. cStat2299 == "4") .Or. cStat2299 $ "-1/1/3") )
						If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2299 ))
							aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravação do registro na tabela RJE"
							DisarmTransaction()
						EndIf
					//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
					ElseIf nOperation == 5 .And. cStat2299 != "-1" .And. !(cOper2299 == "E" .And. cStat2299 == "4")
						If !( lRet := fExcluiRJE( nRecRJE ) )
							aAdd( aErros, OemToAnsi(STR0138) )//"Ocorreu um erro na exclusão do registro na tabela RJE"
							DisarmTransaction()
						EndIf
					EndIf
				ElseIf cEFDAviso == "1"
					For nI := 1 To Len(aErros)
						cMsgHlp += aErros[nI] + CRLF
					Next
					aErros[1] := cMsgHlp
					aSize(aErros, 1)
					DisarmTransaction()
				EndIf
			EndIf
		Else
			If !lMiddleware
				aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3000")
			ElseIf Len(aErros) == 0
				If cStat2299 != "4"
					If !( lRet := fExcluiRJE( nRec2299 ) )
						aAdd( aErros, STR0138 )//"Ocorreu um erro na exclusão do registro na tabela RJE"
						DisarmTransaction()
					EndIf
				Else
					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3000", Space(6), cRecib2299, cId, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
					If !( lRet := fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
						aAdd( aErros, STR0138 )//"Ocorreu um erro na gravação do registro na tabela RJE"
						DisarmTransaction()
					EndIf
				EndIf
			EndIf
		EndIf
	End Transaction
	If Len(aErros) > 0
		FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
		lGravou:= IIF(aErros[1]!='000026',.F.,.T.)

		if aErros[1]=='000026'
			ADEL(aErros, 1)
			ASIZE(aErros,0)
			fEFDMsgErro(cMsgErro)
		Else
			aErros[1]:= cMsgErro
		EndIf

		//Só exibe a mensagem se for Rescisão Simples
		If( cTpRes == "1"  .And. Len(aErros) > 0)
			If !lMiddleware
				Help(,,,OemToAnsi(STR0001),OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + CRLF + cMsgErro,1,0)//" não enviado(a) ao TAF. Erro: "
			Else
				Help(,,OemToAnsi(STR0001), ,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgErro,1,0)//" não enviado(a) ao Middleware. Erro: "
			EndIf
		EndIf
	ElseIf nOperation <> 5 .And. !lCPFDepOk
		cMsgErro := STR0106//"O(s) dependente(s)/agregado(s) de plano de saúde abaixo não tem CPF cadastrado:"
		For nX := 1 To Len(aDepAgreg)
			cMsgErro += CRLF + aDepAgreg[nX]
		Next nX
		If cTpRes == "1"
			Aviso( OemtoAnsi(STR0001) , cMsgErro,	{ STR0038 } )
		Else
			aAdd(aErros, cMsgErro)
		EndIf
	Endif

	RestArea(aArea)

	// Reinicializa a variável Estática nContRes
	nContRes := 0

Return lGravou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetAssMed       ºAutor ³Marcos Coutinho³ Data ³  25/05/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem os valores de Assistencia Medica                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM026C                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GetAssMed( cFil, cMat, cTab, cFilRCC, cQual, cComp, cTabR )
Local cGetAlias  := ""
Local cRHSAlias  := GetNextAlias()
Local cChave     := ""
Local nSomaTotal := 0
Local nBusca     := 0
Local aDados     := {}

Default cFilRCC := "        "
Default cQual   := " "

cGetAlias  := GetNextAlias()

If cQual == "T"

    If cTabR == "RHR" //cálculo do plano de saúde aberto
		BeginSql Alias cGetAlias
				SELECT
					RHR_FILIAL,
					RHR_MAT,
					RHR_CODFOR,
					RHR_PD,
					RHR_CODIGO,
					RHR_ORIGEM,
					RHR_TPLAN,
					RHR_TPFORN,
					RHR_VLRFUN,
					RHR_COMPPG,
					RCC_CONTEU,
					RCC_FIL,
					RCC_FILIAL
				 FROM
					%Table:RHR% RHR
				JOIN
					%Table:RCC% RCC
				ON
					RHR_CODFOR = SUBSTRING(RCC_CONTEU,1,3)
				WHERE
					RHR_FILIAL = %Exp:( cFil )% AND
					RHR_MAT = %Exp:( cMat )% AND
					RHR_COMPPG = %Exp:( cComp )% AND
					RCC.RCC_CODIGO = ( CASE WHEN RHR.RHR_TPFORN = '1' THEN 'S016' WHEN RHR.RHR_TPFORN = '2' THEN 'S017' END ) AND
					(RCC.RCC_FIL = ' ' OR RCC_FILIAL = %Exp:( cFilRCC )% ) AND
					RHR_ORIGEM = '1' AND //titular
					RHR_TPLAN = '1' OR RHR_TPLAN = '2'  AND //plano ou co-paticipacao
					RCC.%NotDel% AND
					RHR.%NotDel%
				GROUP BY
					RHR_FILIAL, RHR_MAT, RHR_CODFOR, RHR_PD, RHR_CODIGO, RHR_ORIGEM, RHR_TPLAN, RHR_TPFORN, RHR_VLRFUN, RHR_COMPPG, RCC_CONTEU, RCC_FIL, RCC_FILIAL
		EndSql

		While (cGetAlias)->(!Eof())
		   cChave := (cGetAlias)->RHR_FILIAL + (cGetAlias)->RHR_MAT + Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ) + Substr( (cGetAlias)->RCC_CONTEU, 168,6 )
		   nBusca := Ascan( @aDados,{|X| X[1]+X[2]+X[3]+X[4] == cChave })
	  	   If nBusca > 0
	  	       aDados[nBusca, 5] += (cGetAlias)->RHR_VLRFUN
	  	   Else
	  	       aAdd(aDados, { (cGetAlias)->RHR_FILIAL ,;	//Filial da RHR - Plano de Saude
				    		     (cGetAlias)->RHR_MAT		,; //Matric da RHR - Plano de ADMSaude
						  	     Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),; //CNPJ Fornecedor
							     Substr( (cGetAlias)->RCC_CONTEU, 168,6 )  ,; // ANS Fornecedor
							     (cGetAlias)->RHR_VLRFUN	 })
			EndIf
		   ( cGetAlias )->(DbSkip())
	   End
   Else //cálculo do plano de saúde fechado
		BeginSql Alias cGetAlias
				SELECT
					RHS_FILIAL,
					RHS_MAT,
					RHS_CODFOR,
					RHS_PD,
					RHS_CODIGO,
					RHS_ORIGEM,
					RHS_TPLAN,
					RHS_TPFORN,
					RHS_VLRFUN,
					RHS_COMPPG,
					RCC_CONTEU,
					RCC_FIL,
					RCC_FILIAL
				 FROM
					%Table:RHS% RHS
				JOIN
					%Table:RCC% RCC
				ON
					RHS_CODFOR = SUBSTRING(RCC_CONTEU,1,3)
				WHERE
					RHS_FILIAL = %Exp:( cFil )% AND
					RHS_MAT = %Exp:( cMat )% AND
					RCC.RCC_CODIGO = ( CASE WHEN RHS.RHS_TPFORN = '1' THEN 'S016' WHEN RHS.RHS_TPFORN = '2' THEN 'S017' END ) AND
					(RCC.RCC_FIL = ' ' OR RCC_FILIAL = %Exp:( cFilRCC )% ) AND
					RHS_COMPPG = %Exp:( cComp )% AND
					RHS_ORIGEM = '1' AND //titular
					RHS_TPLAN = '1' OR RHS_TPLAN = '2'  AND //plano ou co-paticipacao
					RCC.%NotDel% AND
					RHS.%NotDel%
				GROUP BY
					RHS_FILIAL, RHS_MAT, RHS_CODFOR, RHS_PD, RHS_CODIGO, RHS_ORIGEM, RHS_TPLAN, RHS_TPFORN, RHS_VLRFUN, RHS_COMPPG, RCC_CONTEU, RCC_FIL, RCC_FILIAL
		EndSql

		While (cGetAlias)->(!Eof())
		   cChave := (cGetAlias)->RHS_FILIAL + (cGetAlias)->RHS_MAT + Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ) + Substr( (cGetAlias)->RCC_CONTEU, 168,6 )
		   nBusca := Ascan( @aDados,{|X| X[1]+X[2]+X[3]+X[4] == cChave })
	  	   If nBusca > 0
	  	       aDados[nBusca, 5] += (cGetAlias)->RHS_VLRFUN
	  	   Else
	  	       aAdd(aDados, { (cGetAlias)->RHS_FILIAL ,;	//Filial da RHS - Plano de Saude
				    		     (cGetAlias)->RHS_MAT		,; //Matric da RHS - Plano de ADMSaude
						  	     Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),; //CNPJ Fornecedor
							     Substr( (cGetAlias)->RCC_CONTEU, 168,6 )  ,; // ANS Fornecedor
							     (cGetAlias)->RHS_VLRFUN	 })
			EndIf
		   ( cGetAlias )->(DbSkip())
	   End
    EndIf
Else
    If cTabR == "RHR" //cálculo do plano de saúde aberto
		BeginSql Alias cGetAlias
				SELECT
					SRB.RB_NOME,
					SRB.RB_DTNASC,
					SRB.RB_CIC,
					SRB.RB_TPDEP,
					RHR.RHR_FILIAL,
					RHR.RHR_MAT,
					RHR.RHR_CODIGO,
					RHR.RHR_ORIGEM,
					RHR.RHR_TPLAN,
					RHR.RHR_COMPPG,
					RHR.RHR_VLRFUN
			    FROM
					%Table:RHR% RHR
				JOIN
					%Table:SRB% SRB
				ON
					RHR.RHR_FILIAL = SRB.RB_FILIAL AND
					RHR.RHR_MAT    = SRB.RB_MAT    AND
					RHR.RHR_CODIGO = SRB.RB_COD //sequencia do dependente
				WHERE
					RHR.RHR_FILIAL     = %Exp:( cFil )% AND
					RHR.RHR_MAT        = %Exp:( cMat )% AND
					RHR.RHR_COMPPG     = %Exp:( cComp )% AND
					RHR.RHR_ORIGEM     IN ('2', '3')	AND //apenas dependentes e agregados
					RHR.RHR_TPLAN = '1' OR RHR.RHR_TPLAN = '2'  AND //plano ou co-paticipacao
					RHR.%NotDel%  AND
					SRB.%NotDel%
		EndSql

		While (cGetAlias)->(!Eof())
		   cChave := (cGetAlias)->RB_CIC
		   nBusca := Ascan( @aDados,{|X| X[1] == cChave })
	  	   If nBusca > 0
	  	       aDados[nBusca, 4] += (cGetAlias)->RHR_VLRFUN
	      Else
	  	       aAdd(aDados, { (cGetAlias)->RB_CIC ,;
				    		     (cGetAlias)->RB_NOME,;
				    		     (cGetAlias)->RB_DTNASC,;
				    		     (cGetAlias)->RHR_VLRFUN,;
							     (cGetAlias)->RB_TPDEP})
			EndIf
		   ( cGetAlias )->(DbSkip())
	   End
    Else //cálculo do plano de saúde fechado
		BeginSql Alias cGetAlias
				SELECT
					SRB.RB_NOME,
					SRB.RB_DTNASC,
					SRB.RB_CIC,
					SRB.RB_TPDEP,
					RHS.RHS_FILIAL,
					RHS.RHS_MAT,
					RHS.RHS_CODIGO,
					RHS.RHS_ORIGEM,
					RHS.RHS_TPLAN,
					RHS.RHS_COMPPG,
					RHS.RHS_VLRFUN
			    FROM
					%Table:RHS% RHS
				JOIN
					%Table:SRB% SRB
				ON
					RHS.RHS_FILIAL = SRB.RB_FILIAL AND
					RHS.RHS_MAT    = SRB.RB_MAT    AND
					RHS.RHS_CODIGO = SRB.RB_COD //sequencia do dependente
				WHERE
					RHS.RHS_FILIAL     = %Exp:( cFil )% AND
					RHS.RHS_MAT        = %Exp:( cMat )% AND
					RHS.RHS_COMPPG     = %Exp:( cComp )% AND
					RHS.RHS_ORIGEM     IN ('2','3')     AND //apenas dependentes e agregados
					RHS.RHS_TPLAN = '1' OR RHS.RHS_TPLAN = '2'  AND //plano ou co-paticipacao
					RHS.%NotDel%             AND
					SRB.%NotDel%
		EndSql

		While (cGetAlias)->(!Eof())
		   cChave := (cGetAlias)->RB_CIC
		   nBusca := Ascan( @aDados,{|X| X[1] == cChave })
	  	   If nBusca > 0
	  	       aDados[nBusca, 4] += (cGetAlias)->RHS_VLRFUN
	      Else
	  	       aAdd(aDados, { (cGetAlias)->RB_CIC ,;
				    		     (cGetAlias)->RB_NOME,;
				    		     (cGetAlias)->RB_DTNASC,;
				    		     (cGetAlias)->RHS_VLRFUN,;
							     (cGetAlias)->RB_TPDEP})
			EndIf
		   ( cGetAlias )->(DbSkip())
	   End
    EndIf
EndIf
( cGetAlias )->( dbCloseArea() )

Return aDados

Function GetRAssMed( cFil, cMat, cTab, cVersao, cPer, aDadosTRHR, aDadosDRHR, cTabRH, lCPFDepOk, aDepAgreg )
Local cGetAlias  := ""
Local cRHRAlias  := GetNextAlias()
Local nSomaTotal := 0
Local nPos			:= 0
Local nX			:= 0
Local cCposSel		:= ""
Local cCposRHP		:= ""
Local cCposWhere	:= ""
Local cWhereRHP		:= ""
Local cCposGroup	:= ""
Local cGroupRHP		:= ""
Local cCposJoin		:= ""
Local cJoinRHP		:= ""
Local cTableFrom	:= ""
Local cTableRHP		:= ""
Local aTRHRBkp		:= {}

Default cTabRH		:= "RHR"
Default lCPFDepOk	:= .T.
Default aDepAgreg	:= {}

cTableFrom := "%" + RetFullName(cTabRH, cEmpAnt) + "%"
cTableRHP  := "%" + RetFullName("RHP", cEmpAnt) + "%"

cGetAlias := GetNextAlias()

cCposSel := "%"
cCposSel += cTabRH + "_FILIAL RHR_FILIAL, "
cCposSel += cTabRH + "_MAT RHR_MAT, "
cCposSel += cTabRH + "_CODFOR RHR_CODFOR, "
cCposSel += cTabRH + "_PD RHR_PD, "
cCposSel += cTabRH + "_CODIGO RHR_CODIGO, "
cCposSel += cTabRH + "_TPLAN RHR_TPLAN, "
cCposSel += cTabRH + "_ORIGEM RHR_ORIGEM, "
cCposSel += cTabRH + "_COMPPG RHR_COMPPG, "
cCposSel += cTabRH + "_TPFORN RHR_TPFORN, "
cCposSel += "SUM(" + cTabRH + "_VLRFUN) TOTAL, "
cCposSel += "RCC_CONTEU"
cCposSel += "%"

cCposWhere := "%"
cCposWhere += cTabRH + "_FILIAL = '" + xFilial(cTabRH, cFil) + "' AND "
cCposWhere += cTabRH + "_MAT = '" + cMat + "' AND "
cCposWhere += cTabRH + "_TPLAN IN ('1', '2') AND "
cCposWhere += cTabRH + "_COMPPG = '" + cPer + "' AND "
cCposWhere += "RCC.RCC_FILIAL = '" + xFilial('RCC', cFil) + "' AND "
cCposWhere += "(RCC.RCC_FIL = '' OR RCC.RCC_FIL = " + cTabRH + "_FILIAL) AND "
cCposWhere += "RCC.RCC_CODIGO = ( CASE WHEN RHR."+cTabRH+"_TPFORN = '1' THEN 'S016' WHEN RHR."+cTabRH+"_TPFORN = '2' THEN 'S017' END )"
cCposWhere += "%"

cCposGroup := "%"
cCposGroup += cTabRH + "_FILIAL, " + cTabRH + "_MAT, " + cTabRH + "_CODFOR, " + cTabRH + "_PD, "
cCposGroup += cTabRH + "_CODIGO, " + cTabRH + "_TPLAN, " + cTabRH + "_ORIGEM, " + cTabRH + "_COMPPG, "
cCposGroup += cTabRH + "_TPFORN, RCC_CONTEU "
cCposGroup += "%"

cCposJoin := "%"
cCposJoin += cTabRH + "_CODFOR = SUBSTRING(RCC_CONTEU,1,3)"
cCposJoin += "%"

cCposRHP := "%"
cCposRHP += "RHP_FILIAL RHR_FILIAL, "
cCposRHP += "RHP_MAT RHR_MAT, "
cCposRHP += "RHP_CODFOR RHR_CODFOR, "
cCposRHP += "RHP_PD RHR_PD, "
cCposRHP += "RHP_CODIGO RHR_CODIGO, "
cCposRHP += "RHP_TPLAN RHR_TPLAN, "
cCposRHP += "RHP_ORIGEM RHR_ORIGEM, "
cCposRHP += "RHP_COMPPG RHR_COMPPG, "
cCposRHP += "RHP_TPFORN RHR_TPFORN, "
cCposRHP += "SUM(RHP_VLRFUN) TOTAL, "
cCposRHP += "RCC_CONTEU"
cCposRHP += "%"

cWhereRHP := "%"
cWhereRHP += "RHP_FILIAL = '" + xFilial('RHP', cFil) + "' AND "
cWhereRHP += "RHP_MAT = '" + cMat + "' AND "
cWhereRHP += "RHP_TPLAN IN ('1', '2') AND "
cWhereRHP += "RHP_COMPPG = '" + cPer + "' AND "
cWhereRHP += "RCC.RCC_FILIAL = '" + xFilial('RCC', cFil) + "' AND "
cWhereRHP += "(RCC.RCC_FIL = '' OR RCC.RCC_FIL = RHP_FILIAL) AND "
cWhereRHP += "RCC.RCC_CODIGO = ( CASE WHEN RHP.RHP_TPFORN = '1' THEN 'S016' WHEN RHP.RHP_TPFORN = '2' THEN 'S017' END )"
cWhereRHP += "%"

cGroupRHP := "%"
cGroupRHP += "RHP_FILIAL, RHP_MAT, RHP_CODFOR, RHP_PD, "
cGroupRHP += "RHP_CODIGO, RHP_TPLAN, RHP_ORIGEM, RHP_COMPPG, "
cGroupRHP += "RHP_TPFORN, RCC_CONTEU "
cGroupRHP += "%"

cJoinRHP := "%"
cJoinRHP += "RHP_CODFOR = SUBSTRING(RCC_CONTEU,1,3)"
cJoinRHP += "%"

If cTabRH == "RHR"
	BeginSql Alias cGetAlias
		SELECT
			%exp:cCposSel%
		 FROM
			%exp:cTableFrom% RHR
		JOIN
			%Table:RCC% RCC
		ON
			%exp:cCposJoin%
		WHERE
			%exp:cCposWhere% AND
			RCC.%NotDel% AND
			RHR.%NotDel%
		GROUP BY
			%exp:cCposGroup%
	EndSql
Else
	BeginSql Alias cGetAlias
				SELECT
			%exp:cCposSel%
			    FROM
			%exp:cTableFrom% RHR
				JOIN
			%Table:RCC% RCC
				ON
			%exp:cCposJoin%
				WHERE
			%exp:cCposWhere% AND
			RCC.%NotDel% AND
			RHR.%NotDel%
		GROUP BY
			%exp:cCposGroup%
		UNION ALL
		SELECT
			%exp:cCposRHP%
		 FROM
			%exp:cTableRHP% RHP
		JOIN
			%Table:RCC% RCC
		ON
			%exp:cJoinRHP%
		WHERE
			%exp:cWhereRHP% AND
			RCC.%NotDel% AND
			RHP.%NotDel%
		GROUP BY
			%exp:cGroupRHP%
	EndSql
EndIf

	While ( (cGetAlias)->( !Eof() ) )

	//TITULAR
	if (cGetAlias)->RHR_ORIGEM == "1"
		nPos := ascan(aDadosTRHR,{|X| X[6]+x[7] == Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ) + Substr( (cGetAlias)->RCC_CONTEU, 168,6 ) })
		  If nPos == 0
			aAdd(aDadosTRHR, { 	(cGetAlias)->RHR_FILIAL ,;	// 1 - Filial da RHR - Plano de Saude
										(cGetAlias)->RHR_MAT		,; // 2 - Matric da RHR - Plano de Saude
										(cGetAlias)->RHR_CODFOR	,; // 3 - CodFor da RHR - Plano de Saude
										(cGetAlias)->RHR_PD		,; // 4 - Verba  da RHR - Plano de Saude
										(cGetAlias)->RHR_CODIGO	,; // 5 - Depend da RHR - Plano de Saude
										Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),; //6 - CNPJ Fornecedor
										Substr( (cGetAlias)->RCC_CONTEU, 168,6 )  ,; // 7 - ANS Fornecedor
										(cGetAlias)->TOTAL	})
		  Else
			If Empty((cGetAlias)->RHR_CODIGO)
				aDadosTRHR[nPos,8] += (cGetAlias)->TOTAL
			EndIf
		  EndIf
	//DEPENDENTE
	Elseif (cGetAlias)->RHR_ORIGEM == "2"
		DbSelectArea('SRB')
		If (cGetAlias)->TOTAL > 0 .And. SRB->(DBSeek((cGetAlias)->RHR_FILIAL + (cGetAlias)->RHR_MAT + (cGetAlias)->RHR_CODIGO))
			nPos := ascan(aDadosDRHR,{|X| X[6]+x[7]+x[8]+x[9]  == SRB->(RB_COD) + Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ) + Substr( (cGetAlias)->RCC_CONTEU, 168,6 ) + (cGetAlias)->RHR_ORIGEM })
			If cVersao >= "2.5.00" .And. Empty(SRB->RB_CIC)
				lCPFDepOk := .F.
				If aScan(aDepAgreg, { |x| x == SRB->RB_NOME }) == 0
					aAdd( aDepAgreg, SRB->RB_NOME )
				EndIf
			EndIf
	   		If nPos == 0
				AAdd ( aDadosDRHR, { SRB->(RB_CIC),;
										SRB->(RB_NOME),;
										DtoS(SRB->(RB_DTNASC)), ;
										(cGetAlias)->TOTAL,;
										fTpDep(Alltrim(SRB->(RB_TPDEP)),cVersao),;
										SRB->(RB_COD),;
									Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),; //CNPJ Fornecedor
										Substr( (cGetAlias)->RCC_CONTEU, 168,6 ),; //ANS Fornecedor
										(cGetAlias)->RHR_ORIGEM  } )  //Origem (1-Titular,2-Dependente,3-Agregado)
	  		Else
				aDadosDRHR[nPos,4] += (cGetAlias)->TOTAL
		  	EndIf
		Endif
	//AGREGADO
	Elseif (cGetAlias)->RHR_ORIGEM == "3"
		DbSelectArea('RHM')
		If (cGetAlias)->TOTAL > 0 .And. RHM->(DBSeek((cGetAlias)->RHR_FILIAL + (cGetAlias)->RHR_MAT + (cGetAlias)->RHR_TPFORN + (cGetAlias)->RHR_CODFOR + (cGetAlias)->RHR_CODIGO ))
			nPos := ascan(aDadosDRHR,{|X| X[6]+x[7]+x[8]+x[9]  == RHM->(RHM_CODIGO) + Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ) + Substr( (cGetAlias)->RCC_CONTEU, 168,6 ) + (cGetAlias)->RHR_ORIGEM })
			If cVersao >= "2.5.00" .And. Empty(RHM->RHM_CPF)
				lCPFDepOk := .F.
				If aScan(aDepAgreg, { |x| x == RHM->RHM_NOME }) == 0
					aAdd( aDepAgreg, RHM->RHM_NOME )
				EndIf
			EndIf
			If nPos == 0
				AAdd ( aDadosDRHR, { RHM->(RHM_CPF),;
										RHM->(RHM_NOME),;
										DtoS(RHM->(RHM_DTNASC)), ;
										(cGetAlias)->TOTAL,;
										fTpDep("13",cVersao),;
										RHM->(RHM_CODIGO),;
										Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),; //CNPJ Fornecedor
										Substr( (cGetAlias)->RCC_CONTEU, 168,6 ),; //ANS Fornecedor
										(cGetAlias)->RHR_ORIGEM  } ) //Origem (1-Titular,2-Dependente,3-Agregado)
			Else
				aDadosDRHR[nPos,4] += (cGetAlias)->TOTAL
	  		EndIf
		Endif
	Endif

	  ( cGetAlias )->(DbSkip())
  EndDo
  ( cGetAlias )->( dbCloseArea() )

For nX := 1 To Len( aDadosTRHR )
	If aDadosTRHR[nX, 8] > 0 .Or. aDadosTRHR[nX, 8] == 0 .And. aScan( aDadosDRHR, { |x| x[7]+x[8] == aDadosTRHR[nX, 6]+aDadosTRHR[nX, 7] } ) > 0
		aAdd( aTRHRBkp, aClone(aDadosTRHR[nX]) )
	EndIf
Next nX

aDadosTRHR := aClone(aTRHRBkp)

Return





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetMulVin       ºAutor ³Marcos Coutinho³ Data ³  25/05/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem os Valores de Multiplos Vinculos do Funcionario       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM026C                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GetMulVin( cFil, cMat, cPer )

Local cGetAlias  := ""
Local nSomaTotal := 0
Local aDados := {}

	cGetAlias  := GetNextAlias()

	BeginSql Alias cGetAlias
		SELECT
			RAW_FILIAL,
			RAW_MAT,
			RAW_FOLMES,
			RAW_TPFOL,
			RAW_TPREC,
			RAW_PROCES,
			RAW_SEMANA,
			RAW_ROTEIR,
			RAZ_TPINS,
			RAZ_INSCR,
			RAZ_VALOR,
			RAZ_CATEG
		FROM
			%Table:RAW% AW
		JOIN
			%Table:RAZ% AZ
		ON
			AW.RAW_FILIAL = AZ.RAZ_FILIAL AND
			AW.RAW_MAT = AZ.RAZ_MAT AND
			AW.RAW_FOLMES = AZ.RAZ_FOLMES AND
			AW.RAW_TPFOL = AZ.RAZ_TPFOL
		WHERE
			AW.RAW_FILIAL = %Exp:( cFil )% AND
			AW.RAW_MAT = %Exp:( cMat )% AND
			AW.RAW_FOLMES = %Exp:( cPer )% AND
			AW.%NotDel% AND
			AZ.%NotDel%
	EndSql



	While ( (cGetAlias)->( !Eof() ) )


		aAdd(aDados, { 	(cGetAlias)->RAW_FILIAL ,;	//Filial Funcionario
								(cGetAlias)->RAW_MAT		,; //Matricula Funcionario
								(cGetAlias)->RAW_FOLMES	,; //Periodo de Apuracao
								(cGetAlias)->RAW_TPFOL	,; //Tipo da Folha
								(cGetAlias)->RAW_TPREC	,; //Tipo de Recolhimento
								(cGetAlias)->RAW_PROCES	,; //Codigo do Processo
								(cGetAlias)->RAW_SEMANA	,; //Numero de pagemento
								(cGetAlias)->RAW_ROTEIR	,; //Roteiro
								(cGetAlias)->RAZ_TPINS	,; //Tipo de Inscricao (CNPJ / CPF)
								(cGetAlias)->RAZ_INSCR	,; //Valor da Inscricao (N CPF ou CNPJ)
								(cGetAlias)->RAZ_VALOR	,; //Valor Pago
								(cGetAlias)->RAZ_CATEG	}) //Categoria eSocial
		DbSkip()
	EndDo

	( cGetAlias )->( dbCloseArea() )

Return aDados

/*/{Protheus.doc} fTpDep(aDependent,lVer23)
Função que retorna a string xml do tipo de dependente
@type  Function
@author Eduardo
@since 08/09/2017
@version 1.0
@param aDependent, array, array com o dependente
@param lVer23, boolean, Checagem da versão do esocial
@return cXml,String, retorno do tipo de dependente tratando as duas versões do eSocial.
/*/
static function fTpDep(cDependent,cVersEnvio)
Local cDep:= ""

Default cVersEnvio := "2.2"

If cVersEnvio >= "2.3"
	if val(cDependent)<03
		cDep := cDependent
	elseif val(cDependent)==03 .or. val(cDependent) ==05
		cDep := '03'
	elseif val(cDependent)==04
		cDep := '04'
	elseif val(cDependent)>=06 .and. val(cDependent) <=08
		cDep := '06'
	elseif val(cDependent)==09
		cDep := '09'
	elseif val(cDependent)==10
		cDep := '10'
	elseif val(cDependent)==11
		cDep := '11'
	elseif val(cDependent)==12
		cDep := '12'
	elseif val(cDependent)==13
		cDep := '99'
	Endif
Else
	if val(cDependent)<03
		cDep := cDependent
	elseif val(cDependent)==03 .or. val(cDependent) ==05
		cDep := '03'
	elseif val(cDependent)==04
		cDep := '08'
	elseif val(cDependent)>=06 .and. val(cDependent) <=08
		cDep := '04'
	elseif val(cDependent)==09
		cDep := '05'
	elseif val(cDependent)==10
		cDep := '06'
	elseif val(cDependent)==11
		cDep := '07'
	elseif val(cDependent)==12
		cDep := '15'
	elseif val(cDependent)==13
		cDep := '99'
	Endif
EndIF
Return cDep


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fBuscConsig     ºAutor ³Renan Borges   ³ Data ³  06/11/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Procura o registro da SRK com consig. com fgts.	          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM026C                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function fBuscConsig(aVerbas)
Local lRet	:= .F.
Local nX	:= 0
Local aArea := GetArea()

DbSelectArea("SRK")
DbSetOrder(1)
For nx := 1 to Len(aVerbas)
	If SRK->( DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+aVerbas[nx,1]))
		If SRK->RK_CONSFGT == '1'
			lRet := .T.
			Exit
		EndIf
	EndIf
Next

RestArea(aArea)
Return lRet

/*/{Protheus.doc} fTrf2299
Funcao responsavel por realizar a integracao com o TAF na transferencia entre Grupo/Empresas diferentes
@author jose.silveira
@since 28/03/2018
@version 12.1.17
/*/
Function fTrf2299( cCodDslg, cFilEnv, cCgcPara, dDataTRF, cVersaoEnv, cMsgRet, cTpInsc )

	Local aArea 		:= GetArea()
	Local lGravou		:= .T.
	Local cMsgErro    	:= ""
	Local cTafKey    	:= ""
	Local aErros		:= {}

	Local cBkpFil	 	:= cFilAnt
	Local cEFDAviso  	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")//Se nao encontrar este parametro apenas emitira alertas
	Local cVersMw	 	:= ""
	Local cXml		 	:= ""
	Local cMsg		 	:= ""
	Local cMsgErro	 	:= ""
	Local cVersMid	 	:= ""
	Local cChave	 	:= ""
	Local cStatus	 	:= "-1"
	Local cMsgHlp	 	:= ""
	Local cMsgRJE	 	:= ""
	Local cIni 		 	:= Space(6)
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDados	 	:= {}
	Local cFilEmp	 	:= ""
	Local dDtGer	 	:= Date()
	Local cHrGer	 	:= Time()
	Local lRet		 	:= .T.
	Local cRetfNew	 	:= ""
	Local cOperNew 	 	:= ""
	Local cStatRJE	 	:= "-1"
	Local cOper2299	 	:= "I"
	Local cRecib2299 	:= ""
	Local cRecibAnt  	:= ""
	Local cRecibXML  	:= ""
	Local cRetf2299	 	:= "1"
	Local cStat2299	 	:= "-1"
	Local nRec2299   	:= 0
	Local cRetfNew	 	:= ""
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local nCont			:= 0
	Local aTpRegTrab	:= {{'30'},{'31'}, {'35'}}
	Local nTpRegTrab	:= 0
	Local cMatricula    := ""

	Default cVersaoEnv 	:= '2.2'
	Default cCgcPara	:= ""
	Default cTpInsc		:= If( Len(cCgcPara) == 11, "2", "1" )

	nTpRegTrab	:= aScan(aTpRegTrab,{|x| Alltrim(x[1]) == SRA->RA_VIEMRAI})//Retorno: 0-CLT | >0-Estatutario

	//----------------
	//| Evento S-2299
	//| Inicio da geracao do evento de desligamento
	//----------------------------------------------
	If lMiddleware
		fVersEsoc( "S2299", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw )
		fPosFil( cEmpAnt, SRA->RA_FILIAL )
		lS1000 := fVld1000( AnoMes(dDataTRF), @cStatus )
		If !lS1000 .And. cEFDAviso != "2"
			Do Case
				Case cStatus == "-1" // nao encontrado na base de dados
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130)//"Registro do evento X-XXXX não localizado na base de dados"
					Return .F.
				Case cStatus == "1" // nao enviado para o governo
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131)//"Registro do evento X-XXXX não transmitido para o governo"
					Return .F.
				Case cStatus == "2" // enviado e aguardando retorno do governo
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
					Return .F.
				Case cStatus == "3" // enviado e retornado com erro
					cMsgRet := OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"3
					Return .F.
			EndCase
		EndIf
	EndIf

	//-------------------
	//| Inicio do XML
	//-------------------
	If lMiddleware
		aInfos   := fXMLInfos()
		IF Len(aInfos) >= 4
			cTpInsc  := aInfos[1]
			lAdmPubl := aInfos[4]
			cNrInsc  := aInfos[2]
			cId  	 := aInfos[3]
		Else
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
		EndIf

		cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(SRA->RA_CODUNIC, fTamRJEKey(), " ")
		cStat2299 	:= "-1"
		GetInfRJE( 2, cChaveBus, @cStat2299, @cOper2299, @cRetf2299, @nRec2299, @cRecib2299, @cRecibAnt )

		//Retorno pendente impede o cadastro
		If cStat2299 == "2" .And. cEFDAviso != "2"
			cMsgRJE 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
		EndIf
		//Evento de exclusão sem transmissão impede o cadastro
		If cOper2299 == "E" .And. cStat2299 != "4" .And. cEFDAviso != "2"
			cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
		//Não existe na fila, será tratado como inclusão
		ElseIf cStat2299 == "-1"
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		//Evento sem transmissão, irá sobrescrever o registro na fila
		ElseIf cStat2299 $ "1/3"
			cOperNew 	:= cOper2299
			cRetfNew	:= cRetf2299
			cStatNew	:= "1"
			lNovoRJE	:= .F.
		//Evento diferente de exclusão transmitido, irá gerar uma retificação
		ElseIf cOper2299 != "E" .And. cStat2299 == "4"
			cOperNew 	:= "A"
			cRetfNew	:= "2"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		//Evento de exclusão transmitido, será tratado como inclusão
		ElseIf cOper2299 == "E" .And. cStat2299 == "4"
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		EndIf
		If !Empty(cMsgRJE)
			cMsgRet := cMsgRJE
			Return .F.
		EndIf
		If cRetfNew == "2"
			If cStat2299 == "4"
				cRecibXML 	:= cRecib2299
				cRecibAnt	:= cRecib2299
				cRecib2299	:= ""
			Else
				cRecibXML 	:= cRecibAnt
			EndIf
		EndIf
		aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2299", Space(6), SRA->RA_CODUNIC, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2299, cRecibAnt } )
		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtDeslig/v" + cVersMw + "'>"
		cXML += 	"<evtDeslig Id='" + cId + "'>"
		fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, 1, 1, "12" }, cVersaoEnv, aInfos)
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Else
		//-------------------
		//| Inicio do XML
		//-------------------
		cXml :=	'<eSocial>'
		cXml += 	'<evtDeslig>'
	EndIf

	//Dados do Trabalhador
	cXml +=			'<ideVinculo>'
	cXml +=				'<cpfTrab>' + AllTrim(SRA->RA_CIC) + '</cpfTrab>'
	If cVersaoEnv < "9.0.00"
		cXml +=				'<nisTrab>' + AllTrim(SRA->RA_PIS) + '</nisTrab>'
	Endif

	If !Empty(SRA->RA_CODUNIC)
		cMatricula := If(!lMiddleware, StrTran(SRA->RA_CODUNIC, "&","&#38;" ), SRA->RA_CODUNIC )
	EndIf
	cXml +=				'<matricula>' + AllTrim(cMatricula) + '</matricula>'
	cXml +=			'</ideVinculo>'

	//Dados do Desligamento
	cXml += 		'<infoDeslig>'
	cXml += 			'<mtvDeslig>' + cCodDslg + '</mtvDeslig>'
	If !lMiddleware
		cXml += 			'<dtDeslig>' + Dtos(dDataTRF) + '</dtDeslig>'
	Else
		cXml += "			<dtDeslig>" + SubStr( dToS(dDataTRF), 1, 4 ) + "-" + SubStr( dToS(dDataTRF), 5, 2 ) + "-" + SubStr( dToS(dDataTRF), 7, 2 ) + "</dtDeslig>"
	EndIf

	cXml += 			'<indPagtoAPI>N</indPagtoAPI>'

	//Pensao Alimenticia => 0 - Não existe pensão alimentícia;
	If cVersaoEnv < "9.0.00" .Or. (cVersaoEnv >= "9.0.00" .And. nTpRegTrab == 0 )
		cXml +=				'<pensAlim>0</pensAlim>'
	Endif
	If cVersaoEnv < "9.0.00"
		//Indicador de cumprimento de aviso prévio => 4 - Aviso prévio indenizado ou não exigível.
		cXml += 			'<indCumprParc>4</indCumprParc>'
	Endif
	//Sucessao Vinculos
	If !Empty(AllTrim(cCgcPara))
		cXml +=			'<sucessaoVinc>'

		If cVersaoEnv < "9.0.00"
			cXml +=				'<tpInscSuc>' + cTpInsc +'</tpInscSuc>'
			cXml +=				'<cnpjSucessora>' + AllTrim(cCgcPara) +'</cnpjSucessora>'
		Else
			cXml +=				'<tpInsc>' + cTpInsc +'</tpInsc>'
			cXml +=				'<nrInsc>' + AllTrim(cCgcPara) +'</nrInsc>'
		Endif
		cXml +=			'</sucessaoVinc>'
	Endif

	If cVersaoEnv >= '2.4' .And. cVersaoEnv < "2.4.02"
		cXml += 		'<consigFGTS>'
		cXml += 			'<idConsig>N</idConsig>'
		cXml += 		'</consigFGTS>'
	EndIf

	//Fechamentos de Tags
	cXml += 		'</infoDeslig>'
	cXml +=		'</evtDeslig>'
	cXml +=	'</eSocial>'
	//-------------------
	//| Final do XML
	//-------------------
	GrvTxtArq(alltrim(cXml), "S2299", SRA->RA_CIC)

	If !lMiddleware
		cTafKey := "S2299" + AnoMes(dDataTRF) + SRA->RA_CIC + SRA->RA_CODUNIC
		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S2299", , "", , , , "GPE", , "" )
	Else
		If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2299 ))
			aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravação do registro na tabela RJE"
		EndIf
	EndIf

	If Len(aErros) > 0
		lGravou := .F.
		cMsgRet := aErros[1]
	Endif

	RestArea(aArea)

Return lGravou

/*/{Protheus.doc} fVADI2299
Função que verifica se houve o pagamento do roteiro ADI no calculo de rescisao
@author Allyson
@since 19/07/2018
@version 1.0
@param aCC 	 	- Array com os centros de custo
@param aPds	 	- Array com as verbas
@param cFilEnv	- Filial de integração no TAF
@param cIdDmDev	- Identificador do dmDev
@param lRetif	- Identifica se é complementar por retificação
@param aErrosRJ5- Array com centros de custo sem relacionamento na RJ5
/*/
Function fADI2299( aCC, aPds, cFilEnv, cIdDmDev, cVersaoEnv, lRetif, aErrosRJ5 )

Local aAreaCTT  := CTT->( GetArea() )
Local aAreaSRV 	:= SRV->( GetArea() )
Local cPerSeek	:= ""
Local cRotAdi	:= fGetCalcRot("2")//ADI
Local cSRCSeek	:= ""
Local cSRDSeek	:= ""

Default cVersaoEnv := "2.4"
Default lRetif 	   := .F.
Default aErrosRJ5  := {}

DbSelectArea("SRC")
DbSetOrder(RetOrder("SRC", "RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))

If lRetif
	cPerSeek := AnoMes(M->RG_DATADEM)
Else
	cPerSeek := M->RG_PERIODO
EndIf

cSRCSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRotAdi + cPerSeek + M->RG_SEMANA
If DbSeek( cSRCSeek )
	While SRC->(!Eof() .And. RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA == cSRCSeek )
		fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRC->RC_PD, SRC->RC_CC, SRC->RC_HORAS, SRC->RC_VALOR, SRC->RC_DATA, SRC->RC_PERIODO, SRC->RC_ROTEIR, cVersaoEnv, @aErrosRJ5, .T. )
		SRC->(DbSkip())
	EndDo
EndIf

//Procura o roteiro do adiantamento que ja foi fechado referente ao periodo de calculo da rescisao
DbSelectArea("SRD")
DbSetOrder(RetOrder("SRD", "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRotAdi + cPerSeek + M->RG_SEMANA
If DbSeek( cSRDSeek )
	While SRD->(!Eof() .And. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA == cSRDSeek )
		fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRD->RD_PD, SRD->RD_CC, SRD->RD_HORAS, SRD->RD_VALOR, SRD->RD_DATPGT, SRD->RD_PERIODO, SRD->RD_ROTEIR, cVersaoEnv, @aErrosRJ5, .T. )
		SRD->(DbSkip())
	EndDo
EndIf

RestArea(aAreaCTT)
RestArea(aAreaSRV)

Return

/*/{Protheus.doc} fADI2299Pd
Função que verifica as verbas pagas do roteiro ADI no calculo de rescisao
@author Allyson
@since 19/07/2018
@version 1.0
@param aCC 	 		- Array com os centros de custo
@param aPds	 		- Array com as verbas
@param cFilEnv		- Filial de integração no TAF
@param cIdDmDev		- Identificador do dmDev
@param cCodPd		- Código da verba
@param cCodCC		- Código do centro de custo
@param nHoras		- Horas da verba
@param nValor		- Valor da verba
@param dDtPgto		- Data de pagamento da verba
@param cPeriodo		- Periodo da verba
@param cRoteiro		- Roteiro da verba
@param cVersaoEnv	- Versão de envio
@param aErrosRJ5	- Array com centros de custo sem relacionamento na RJ5
/*/
Function fADI2299Pd( aCC, aPds, cFilEnv, cIdDmDev, cCodPd, cCodCC, nHoras, nValor, dDtPgto, cPeriodo, cRoteiro, cVersaoEnv, aErrosRJ5, lRotADI )

Local cCEIObra		:= ""
Local cCAEPF		:= ""
Local cChaveCC		:= ""
Local cChaveCCPD	:= ""
Local cChaveS1005	:= ""
Local cCodLot		:= ""
Local cCodRubr		:= ""
Local cIdeRubr		:= ""
Local cInscr		:= ""
Local cPrcRubr		:= ""
Local cTpInscr		:= ""
Local cTpLot		:= ""
Local cVerbIRF		:= ""
Local cIncIrf		:= ""
Local lGeraCod		:= .F.
Local lSemFilSRV	:= .F.
Local nPosCC		:= 0
Local nPosCCPD		:= 0
Local nPosEstb		:= 0
Local lPrimIdT		:= .T.
Local cIdTabRub		:= ""
Local lRJ5FilT 		:= RJ5->(ColumnPos("RJ5_FILT")) > 0
Local lTemReg		:= .F.
Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0 .And. cVersaoEnv >= "9.0"
Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0 .And. cVersaoEnv >= "9.0"

Default cVersaoEnv	:= "2.4"
Default aErrosRJ5	:= {}
Default lRotADI		:= .F.

cChaveCCPD	:= cCodCC + cCodPd
cChaveCC	:= cCodCC

nPosCCPD	:= Ascan( @aPds, {|X| X[1] == cChaveCCPD })
nPosCC		:= Ascan( @aPds, {|X| X[12] == cChaveCC })

SRV->(DbSetOrder(1))
If( SRV->( dbSeek( xFilial("SRV", SRA->RA_FILIAL) + cCodPd  ) ) )

	If ( cVersaoEnv < "2.6.00" .And. Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83" )
		Return()
	Endif

	//Tratamento de compartilhamento da tabela SRV
	If !Empty(SRV->RV_FILIAL)
		lGeraCod := .T.
	Else
		lSemFilSRV := .T.
	EndIf
	//------------------
	//| Lógica lGeraCod
	//| .T. -> Exclusiva | .F. -> Compartilhada
	//------------------------------------------
	If lGeraCod
		cIdeRubr := SRV->RV_FILIAL
	Else
		If cVersaoEnv >= "2.3"
			cIdeRubr := cEmpAnt
		Else
			cIdeRubr := ""
		EndIf
	EndIf

	//Pesquisa identificador de tabela de rubrica para o Middleware
	If lMiddleware
		If lPrimIdT
			lPrimIdT  := .F.
			cIdTabRub := fGetIdRJF( Iif(!Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, (xFilial("SRV"), SRV->RV_FILIAL) ), cIdeRubr )
			If Empty(cIdTabRub)
				Help(,,,OemToAnsi(STR0001), OemToAnsi(STR0140) + cIdeRubr + OemToAnsi(STR0141),1,0) //"Atenção"##"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
				Return .F.
			EndIf
		EndIf
		cIdeRubr := cIdTabRub
	EndIf

	cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
	If (SRV->RV_PERC - 100) < 0
		cPrcRubr :=	0	//Percent da Rubrica
	Else
		cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
	EndIf
	If !lRotADI .Or. lRotADI .And. SRV->RV_CODFOL $ "0006*0546"//Adiantamento
		cIdDmDev := SRA->RA_FILIAL + dToS(dDtPgto) + cPeriodo + cRoteiro
	EndIf
EndIf

If !lVerRJ5
	CTT->(DbSetOrder(1))
	If( CTT->( dbSeek( xFilial("CTT", SRA->RA_FILIAL) + cCodCC ) ) )
		cCodLot := IIf(Empty(xFilial("CTT", SRA->RA_FILIAL)), CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
		cTpLot  := CTT->CTT_TPLOT	// Tipo de Lotação (?!?)

		//Verifica se eh uma obra por meio do campo CTT_TIPO2
		If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
			cTpInscr 	:= CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
			cInscr   	:= CTT->CTT_CEI2  // Codigo da inscricao
			cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
		Endif
	EndIf
Else
	RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
	If RJ5->( !dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC ) )
		If aScan(aErrosRJ5, { |x| x == cCodCC }) == 0
			aAdd( aErrosRJ5, cCodCC )
		EndIf
	Else
		If lRJ5FilT
			RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
			RJ5->(dbGoTop())
			RJ5->( dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC + SRA->RA_FILIAL) )
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC .And. RJ5->RJ5_FILT == SRA->RA_FILIAL
				If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
					cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
					lTemReg		:= .T.
				EndIf
				RJ5->( dbSkip() )
			EndDo
			//Se não encontrou um registro com código preenchido reposiciona a tabela e executa o dbseek novamente.
			If !lTemReg
				RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
				RJ5->(dbGoTop())
				RJ5->( dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC ) )
				While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC .And. Empty(RJ5->RJ5_FILT)
					If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
						cTpInscr	:= RJ5->RJ5_TPIO
						cInscr  	:= RJ5->RJ5_NIO
						cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
						cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
					EndIf
					RJ5->( dbSkip() )
				EndDo
			EndiF
		Else
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC
				If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
					cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
				EndIf
				RJ5->( dbSkip() )
			EndDo
		EndIf
		If Empty(cCodLot)
			If aScan(aErrosRJ5, { |x| x == cCodCC }) == 0
				aAdd( aErrosRJ5, cCodCC )
			EndIf
		EndIf
		nPosCCPD	:= Ascan( @aPds,{|X| X[20] == cCodLot + cCodPd })
		nPosCC		:= Ascan( @aPds,{|X| X[19] == cCodLot })
	EndIf
EndIf

//Verifica na tabela F0F se a Filial eh uma obra
If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
	cCEIObra := ""
	If fBuscaOBRA( cFilEnv, @cCEIObra )
		cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
		cInscr 	 	:= cCEIObra // Codigo da inscricao
		cChaveS1005	:= cFilEnv + cInscr
	Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
		cTpInscr 	:= "3"
		cInscr	 	:= cCAEPF
		cChaveS1005	:= cFilEnv + cInscr
	EndIf
EndIf

If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
	nPosEstb := eVal(bEstab)
	If nPosEstb > 0
		cTpInscr	:= aEstb[nPosEstb,3]
		cInscr		:= aEstb[nPosEstb,2]
		cChaveS1005	:= cFilEnv + cInscr
	EndIf
EndIf

If(nPosCC == 0)
	aAdd(aCC, {cCodCC, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
EndIf

//------------------------------------------------
//| Array de Dados
//| Montagem do array com os dados a utilizar para o XML
//-------------------------------------------------------
If( nPosCCPD > 0 )
	aPds[nPosCCPD, 15] += nHoras	//Incrementa Valor
	aPds[nPosCCPD, 17] += nValor	//Incrementa Valor
	aPds[nPosCCPD, 18] += 1	  		//Incrementa Contador
Else
	aAdd(aPds, { 	cCodCC + cCodPd,;	    			//01 - Chave para pesquisa (CC+PD)
					"Dados da Verba",;					//02 - Separador - Verbas/Rubricas
					cCodRubr,;							//03 - Codigo da Rubrica
					cIdeRubr,;							//04 - Ident   da Rubrica
					cPrcRubr,;							//05 - Percent da Rubrica
					"Dados do CC",;						//06 - Separador - Centro de Custo
					cCodLot,;							//07 - Codigo da Lotação
					cTpInscr,;							//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
					cInscr,;							//09 - Codigo da inscricao
					cTpLot,;							//10 - Tipo de Lotação (?!?)
					"Dados da Grid",;					//11 - Separador - Centro de Custo
					cCodCC,;							//12 - Centro de Custo
					cCodPd,;							//13 - Verba da rescisão
					SRV->RV_DESC,;						//14 - Descricao da verba
					nHoras,;							//15 - Horas da verba
					nValor,;							//16 - Valor da verba
					nValor,;							//17 - Acumulado da verba (valor inicial para soma)
					1,;									//18 - Numero de registro repetidos (CC + PD)
					cCodLot,;							//19 - Código de lotação
					cCodLot + cCodPd,;					//20 - Chave para pesquisa (Código Lotação+PD)
					SRV->RV_NATUREZ,;					//21 - Natureza da verba
					SRV->RV_INCCP,;						//22 - Incidência CP da verba
					SRV->RV_INCFGTS,;					//23 - Incidência FGTS da verba
					SRV->RV_INCIRF,;					//24 - Incidência IRRF da verba
					SRV->RV_TIPOCOD,;					//25 - Tipo da verba
					If(lRVIncop, SRV->RV_INCOP,""),;	//26 - Incid RPPS
					If(lRVTetop, SRV->RV_TETOP,"") })	//27 - Teto Remun
EndIf

Return

/*/{Protheus.doc} fBuscaSV7()
Função responsável por buscar o código de convocação ativo mediante uma data de referência
Caso não encontre irá buscar a última data de convocação.
@type function
@author Claudinei Soares
@since 21/09/2018
@version 1.0
@param cFilFun, Caracter, Filial a ser pesquisada na tabela SV7
@param cMatFun, Caracter, Matrícula a ser pesquisada na tabela SV7
@param dDtBusca, Date,  Data para busca
@param cCodConv, Caracter, Código de Convocação (Passada como referência)
@param lCMesAtual, Lógico, Retorna se tem convocação no mês atual (Passada como referência)
@return cCodconv
/*/

Function fBuscaSV7(cFilFun, cMatFun, dDtBusca, cCodConv, lCMesAtual)

Local aArea			:= GetArea()
Local cCodBkp		:= ""
Local dDtcgini		:= SuperGetMv("MV_DTCGINI", , cToD("//"))

Default cFilFun		:= ""
Default cMatFun		:= ""
Default dDtBusca	:= cTod("//")
Default cCodConv	:= ""
Default lCMesAtual	:= .T.

If !ChkFile("SV7")
	Help(,,,OemToAnsi(STR0001),OemToAnsi(STR0095),1,0) //"Tabela SV7 não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
	Return
Else
	dbSelectArea("SV7")
	SV7->( dbSetOrder(1) )
	SV7->(dbGoTop())

	If SV7->( dbSeek( cFilFun + cMatFun ) )
		While SV7->( !Eof() .And. SV7->V7_FILIAL == cFilFun .And. SV7->V7_MAT == cMatFun )
			If SV7->V7_DTFIM == dDtBusca
				cCodConv := SV7->V7_CONVC
				Exit
			ElseIf SV7->V7_DTINI <= dDtBusca .And. SV7->V7_DTFIM >= dDtBusca
				cCodConv := SV7->V7_CONVC
				Exit
			//Se a data de demissão estiver fora do período da rescisão percorre os registros para gravar o último código de convocação
			ElseIf SV7->V7_DTINI <= dDtBusca  .And. SV7->V7_DTINI >=  dDtcgini
				cCodBkp		:= SV7->V7_CONVC
				lCMesAtual	:= .F.
			Endif
			SV7->(dbSkip())
		EndDo
		If Empty(cCodConv)
			cCodConv := cCodBkp
		EndIF
	EndIf

	RestArea(aArea)
Endif

Return( cCodconv )

/*/{Protheus.doc} fDis2299
Função que verifica se existe calculo do dissidio no mes da rescisao
@author Marcelo Silveira
@since 05/10/2018
@version 1.0
@param dDataRes		- Data da demissao
@param cVBDiss 		- Verbas com as diferencas do dissidio
@param aDadosCCT	- Array com dados dos centros de custos
@param cIndSimp		- Indicador do Tipo de Simples Nacional.
@param cXmlAux		- XML gerado com as informacoes do dissidio
@param cMsgErro		- Mensagem de erro na validacao das tabelas S-050 e S-126
/*/
Function fDis2299( dDataRes, cVBDiss, aDadosCCT, cIndSimp, cXmlAux, cMsgErro, lRJ5Ok, aErrosRJ5, cTpRes, aPd )

Local cCompete	:= ""
Local cDscAc	:= ""
Local cData		:= ""
Local cDataCor	:= ""
Local cXmlAux	:= ""
Local cPerAnt	:= ""
Local cVersEnvio:= ""

Local cMes			:= StrZero( Month(dDataRes),2 )
Local cAno			:= cValToChar( Year(dDataRes) )
Local cRHHAlias		:= GetNextAlias()
Local cSRDTabRH		:= GetNextAlias()
Local lFirst		:= .T.
Local lTemVerbas	:= .F.
Local lPrimIdT		:= .T.
Local cIdeRubr		:= ""
Local cIdTbRub		:= ""
Local aTabInss		:= {}
Local cBusca 		:= ""
Local cCCAnt		:= ""
Local lAbriu19 		:= .F.
Local lAbriu20 		:= .F.
Local lFechPer 		:= .F.
Local lFechEstLot 	:= .F.
Local lFechou20 	:= .F.
Local lFirstAnt 	:= .T.
Local lGeraRes 		:= .F.
Local lGerouAnt 	:= .F.
Local lVerDINSS		:= .T.
Local aVbDiss		:= {}
Local cPerDiss		:= ""
Local nC			:= 0
Local nParDiss 		:= 1
Local nParPag		:= 0
Local nValor		:= 0
Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0
Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0

Private cAnoBase	:= cAno
Private aCC			:= fGM23CTT()//extrai lista de c.custo da filial conectada "xfilial(CTT)" ...
Private oTmpTabl2	:= Nil
Private oTmpTabRH	:= Nil

Default cXmlAux		:= ""
Default cMsgErro	:= ""
Default	cVBDiss		:= ""
Default lRJ5Ok		:= .T.
Default	aErrosRJ5	:= {}
Default cTpRes		:= ""
Default aPd			:= {}

fBuscaDiss(@aVbDiss, cTpRes, aPd )

If Len(aVbDiss) > 0
	For nC := 1 To Len(aVbDiss)
		SRK->( dbSetOrder(1) )
		If SRK->( dbSeek( SRA->RA_FILIAL + SRA->RA_MAT ) )
			While SRK->( !EoF() .And. SRK->RK_FILIAL+SRK->RK_MAT == SRA->RA_FILIAL+SRA->RA_MAT  )
				If ( (Empty(SRK->RK_NUMID) .And. SRK->RK_MESDISS == SubStr(aVbDiss[nC, 2], 5, 2 ) + SubStr(aVbDiss[nC, 2], 1, 4 )) .Or. (!Empty(SRK->RK_NUMID) .And. AllTrim(SRK->RK_NUMID) == AllTrim(aVbDiss[nC, 2])) )
					cPerDiss := SRK->RK_PERINI
					nParDiss := SRK->RK_PARCELA
					nParPag  := SRK->RK_PARCPAG
					Exit
				EndIf
				SRK->( dbSkip() )
			EndDo
		EndIf
		If !Empty(cPerDiss)
			Exit
		EndIf
	Next nC
	cAno := Substr(cPerDiss,1,4)
	cMes := Substr(cPerDiss,5,2)
	cAnoBase:= cAno
EndIf

fVersEsoc( "S2299",,,, @cVersEnvio )

If cVersEnvio < "9.0"
	lRVIncop := .F.
	lRVTetop := .F.
Endif

BeginSql alias cRHHAlias
	SELECT 	 RHH.RHH_FILIAL,RHH.RHH_MAT,RHH.RHH_MESANO,RHH.RHH_DATA,RHH.RHH_VB,RHH.RHH_CC,RHH.RHH_VERBA,RHH.RHH_DTACOR,SUM(RHH.RHH_VALOR) AS RHH_VALOR,SUM(RHH.RHH_HORAS) AS RHH_HORAS
	FROM	 %table:RHH% RHH
	WHERE 	 RHH.RHH_FILIAL =	%exp:SRA->RA_FILIAL%
	AND 	 RHH.RHH_MAT    =	%exp:SRA->RA_MAT   %
	AND 	 RHH.RHH_MESANO =	%exp:cAno+cMes%
	AND		 RHH.RHH_INTEGR = 	%exp:'S'%
	AND      RHH.%notDel%
	GROUP BY RHH_FILIAL, RHH_MAT, RHH_MESANO, RHH_DATA, RHH_VB, RHH_CC, RHH_VERBA, RHH_DTACOR
	ORDER BY 1, 2, 3, 4, 6, 5
EndSql

If lVerRJ5
	fVerRJ5B(cRHHAlias, cSRDTabRH, AnoMes(dDataRes), @lRJ5Ok, @aErrosRJ5)
EndIf

While (cRHHAlias)->(!Eof() .And. (cRHHAlias)->RHH_FILIAL+(cRHHAlias)->RHH_MAT+(cRHHAlias)->RHH_MESANO == SRA->RA_FILIAL+SRA->RA_MAT+cAno+cMes )

	If lFirst .And. FindFunction("fTpAco") .And. FindFunction("fDscAc") //As funcoes mudaram o escopo no arquivo GPEM036. Retirar essa verificacao no proximo release.
		cDtAco := (cRHHAlias)->RHH_DTACOR
		cTpAco := fTpAco(.T., "1", cMes+cAno, , , .T.)
		cDscAc := fDscAc(.T., "1", cMes+cAno, @cDataCor, .T.)
		lFirst := .F.
		If Empty( cDscAc ) .Or. Empty( cTpAco )
			cMsgErro := OemToAnsi( STR0100 ) //"Preenchimento incorreto das tabelas S050/S126. As informações de dissídio não foram geradas."
			Exit
		EndIf
	EndIf

	If cPerAnt <> (cRHHAlias)->RHH_DATA

		lTemVerbas	:= .F.
		cPerAnt		:= (cRHHAlias)->RHH_DATA
		cCCAnt		:= ""
		nPosCC		:= Ascan( aDadosCCT, {|X| X[1] == (cRHHAlias)->RHH_CC })

		If lFechPer
			lFechPer 	:= .F.
			S1200F21 ( @cXmlAux)//idePeriodo
		EndIf
		lGeraPer 	:= .T.
		lTemVerbas	:= .F.
		lVerDINSS	:= .T.
		lGerDINSS	:= .F.
	EndIf

	If cCCAnt <> (cRHHAlias)->RHH_CC
		cTpInscr	:= ""
		cInscr		:= ""
		cCCAnt 		:= (cRHHAlias)->RHH_CC
		lFechEstLot	:= .F.
		lGeraEstLot	:= .T.
		lTemVerbas	:= .F.
		lVerDINSS	:= .T.
		lGerDINSS	:= .F.

		fEstabELot((cRHHAlias)->RHH_FILIAL, (cRHHAlias)->RHH_CC, @cTpInscr, @cInscr, @cBusca, Iif(lVerRJ5, (cRHHAlias)->RHH_CCBKP, ""), AnoMes(dDataRes))

		dbselectarea('CTT')
		DbsetOrder(1)
		CTT->(DBSeek( xFilial("CTT", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC )  )

		cVerIndSimples := ''
		If fOptSimp() == "1" .And. fInssEmp( (cRHHAlias)->RHH_FILIAL, @aTabInss, Nil, cAno+cMes )
			cVerIndSimples := aTabInss[31, 1]
		EndIf

	Endif

	If !((cRHHAlias)->RHH_VB == "000" .Or. (cRHHAlias)->RHH_VALOR <= 0.00)

		lTemVerbas	:= .T.
		If lFirstAnt
			lFirstAnt	:= .F.
			lGerouAnt	:= .T.
			If !lAbriu19
				S1200A19(@cXmlAux,.F.)//infoPerAnt
				lAbriu19 := .T.
			Endif
			If !lAbriu20
				cXmlAux += "					<ideADC>"
				If cVersEnvio < "9.0.00" .Or. (cTpAco $ "A|B|C|D|E")
					If !lMiddleware
						cXmlAux += "						<dtAcConv>" + cDtAco + "</dtAcConv>"
					Else
						cXmlAux += "						<dtAcConv>" + SubStr( cDtAco, 1, 4 ) + "-" + SubStr( cDtAco, 5, 2 ) + "-" + SubStr( cDtAco, 7, 2 ) + "</dtAcConv>"
					EndIf
				Endif
				cXmlAux += "						<tpAcConv>" + cTpAco + "</tpAcConv>"

				If cVersEnvio < "9.0.00"
					If !lMiddleware .Or. (!Empty(cAno) .And. !Empty(cMes))
						cXmlAux += "					<compAcConv>" + cAno +"-"+ cMes + "</compAcConv>"
					EndIf
					If !lMiddleware
						cXmlAux += "						<dtEfAcConv>" + dToS(cDataCor) + "</dtEfAcConv>"
					Else
						cXmlAux += "						<dtEfAcConv>" + SubStr( dToS(cDataCor), 1, 4 ) + "-" + SubStr( dToS(cDataCor), 5, 2 ) + "-" + SubStr( dToS(cDataCor), 7, 2 ) + "</dtEfAcConv>"
					EndIf
				Endif
				cXmlAux += "						<dsc>" + cDscAc + "</dsc>"
				cXmlAux += "						<remunSuc>N</remunSuc>"
				lAbriu20 := .T.
			Endif
		EndIf
		If lGeraPer
			lFechPer	:= .T.
			lGeraPer 	:= .F.
			S1200A21(@cXmlAux, { SubStr((cRHHAlias)->RHH_DATA,1,4) + "-" + SubStr((cRHHAlias)->RHH_DATA,5,2) })//idePeriodo
		EndIf
		If lGeraEstLot
			lFechEstLot := .T.
			lGeraEstLot	:= .F.
			S1200A12 ( @cXmlAux, {cTpInscr,cInscr,cBusca, /*vazio nao enviar mesmo*/ }, .F.) //IdeEstabLot
		EndIf

		cVBDiss	+= If( (cRHHAlias)->RHH_VERBA $ cVBDiss, "", (cRHHAlias)->RHH_VERBA + "/" )

		//Posiciona na verba
		PosSrv( (cRHHAlias)->RHH_VB, SRA->RA_FILIAL )

		If SRV->RV_CODFOL $ "0064/0065" .And. lVerDINSS
			lVerDINSS := .F.
			aAreaSRV := SRV->( GetArea() )
			cVerbBus := ""
			SRV->( dbSetOrder(2) )
			If SRV->RV_CODFOL == "0064"
				If SRV->( dbSeek( xFilial("SRV", (cRHHAlias)->RHH_FILIAL ) + "0065" ) )
					cVerbBus := SRV->RV_COD
				EndIf
			ElseIf SRV->RV_CODFOL == "0065"
				If SRV->( dbSeek( xFilial("SRV", (cRHHAlias)->RHH_FILIAL ) + "0064" ) )
					cVerbBus := SRV->RV_COD
				EndIf
			EndIf
			RHH->( dbSetOrder(1) )
			If !Empty(cVerbBus) .And. RHH->( dbSeek( (cRHHAlias)->RHH_FILIAL + (cRHHAlias)->RHH_MAT + (cRHHAlias)->RHH_MESANO + (cRHHAlias)->RHH_DATA + cVerbBus + (cRHHAlias)->RHH_CC ) )
				If (cRHHAlias)->RHH_VALOR + RHH->RHH_VALOR > 0
					lGerDINSS := .T.
				EndIf
			Else
				If (cRHHAlias)->RHH_VALOR > 0
					lGerDINSS := .T.
				Endif
			EndIf
			RestArea(aAreaSRV)
		Endif

		nValor :=  (cRHHAlias)->RHH_VALOR

		If !(SRV->RV_CODFOL $ "0064/0065") .Or. (SRV->RV_CODFOL $ "0064/0065" .And. lGerDINSS)
			If nParDiss > 0
				nValor := NoRound( (nValor / nParDiss) * (nParDiss - nParPag) , 2 )
			Endif
		EndIf

		cIdTbRub := If( ! Empty(SRV->RV_FILIAL), SRV->RV_FILIAL, cEmpAnt )
		nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )

		If lMiddleware
			If lPrimIdT
				lPrimIdT  := .F.
				cIdeRubr := fGetIdRJF( SRV->RV_FILIAL, cIdTbRub )
			EndIf
			cIdTbRub := cIdeRubr
		EndIf

		If  ( ( (cVersEnvio < "2.6.00" .And. !(Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83")) .Or. cVersEnvio >= "9.0" ) ) .And.;
			(!(SRV->RV_CODFOL $ "0064/0065") .Or. (SRV->RV_CODFOL $ "0064/0065" .And. lGerDINSS)) .And. nValor > 0
			cXmlAux += "								<detVerbas>"
			cXmlAux += "									<codRubr>" + (cRHHAlias)->RHH_VB + "</codRubr>"
			cXmlAux += "									<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
			If !lMiddleware .Or. !Empty((cRHHAlias)->RHH_HORAS)
				cXmlAux += "								<qtdRubr>" + Str((cRHHAlias)->RHH_HORAS) + "</qtdRubr>"
			EndIf
			If !lMiddleware .Or. !Empty(nPercRub)
				cXmlAux += "								<fatorRubr>" + Transform(nPercRub,"@E 999.99") + "</fatorRubr>"
			EndIf
			If (!lMiddleware .Or. !Empty(nValor)) .And. cVersEnvio < "9.0.00"
				If !lMiddleware
					cXmlAux += "								<vrUnit>" + AllTrim( Transform(nValor,"@E 999999999.99") ) + "</vrUnit>"
				Else
					cXmlAux += "								<vrUnit>" + AllTrim( Str(nValor ) ) + "</vrUnit>"
				EndIf
			EndIf
			If !lMiddleware
				cXmlAux += "									<vrRubr>" + AllTrim( Transform(nValor,"@E 999999999.99") ) + "</vrRubr>"
			Else
				cXmlAux += "									<vrRubr>" + AllTrim( Str(nValor ) ) + "</vrRubr>"
			EndIf
			If cVersEnvio >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
				cXmlAux +=         '<indApurIR>0</indApurIR>'
			Endif
			cXmlAux += "								</detVerbas>"
			If lMiddleware .And. ( (SRV->RV_NATUREZ == "9901" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9201" .And. SRV->RV_INCCP $ "31/32") .Or. (SRV->RV_NATUREZ == "1409" .And. SRV->RV_INCCP == "51") .Or. (SRV->RV_NATUREZ == "4050" .And. SRV->RV_INCCP == "21") .Or. (SRV->RV_NATUREZ == "4051" .And. SRV->RV_INCCP == "22") .Or. (SRV->RV_NATUREZ == "9902" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9904" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9908" .And. SRV->RV_TIPOCOD == "3") )
				fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, cTpInscr, cInscr, cBusca, SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, nValor, "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""))
			EndIf
		EndIf
	EndIf

	(cRHHAlias)->(dbSkip())

	If (cRHHAlias)->(!Eof()) .And. lTemVerbas .And. (cRHHAlias)->RHH_FILIAL+(cRHHAlias)->RHH_MAT == SRA->RA_FILIAL+SRA->RA_MAT .And. cPerAnt <> (cRHHAlias)->RHH_DATA .And. lFechPer
		If SRA->RA_TPPREVI == "1" //SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
			cOcorren := fGrauExp()
			S1200A18 ( @cXmlAux, {cOcorren},.F.) //infoAgNocivo
			S1200F18 ( @cXmlAux)
		EndIf
		lFechPer := .F.
		S1200F12 ( @cXmlAux )//ideEstabLot
		S1200F21 ( @cXmlAux)//idePeriodo
		Loop
	EndIf
	If (cRHHAlias)->(!Eof()) .And. lTemVerbas .And. (cRHHAlias)->RHH_FILIAL+(cRHHAlias)->RHH_MAT == SRA->RA_FILIAL+SRA->RA_MAT .And. cCCAnt <> (cRHHAlias)->RHH_CC .And. cPerAnt == (cRHHAlias)->RHH_DATA .And. lFechEstLot
		If SRA->RA_TPPREVI == "1" //SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
			cOcorren := fGrauExp()
			S1200A18 ( @cXmlAux, {cOcorren},.F.) //infoAgNocivo
			S1200F18 ( @cXmlAux)
		EndIf
		lFechEstLot := .F.
		S1200F12 ( @cXmlAux )//ideEstabLot
	Endif
End

If !lVerRJ5
	(cRHHAlias)->( dbCloseArea() )
Else
	oTmpTabl2:Delete()
	oTmpTabRH:Delete()
	oTmpTabl2 := Nil
	oTmpTabRH := Nil
EndIf

If lTemVerbas
	If SRA->RA_TPPREVI == "1" //SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
		cOcorren := fGrauExp()
		S1200A18 ( @cXmlAux, {cOcorren},.F.) //infoAgNocivo
		S1200F18 ( @cXmlAux)
	EndIf
	If lFechPer .And. lFechEstLot
		S1200F12 ( @cXmlAux )//ideEstabLot
		S1200F21 ( @cXmlAux)//idePeriodo
	ElseIf lFechPer
		S1200F21 ( @cXmlAux)//idePeriodo
	EndIf
EndIf
If lGerouAnt .Or. (!lGerouAnt .And. !lTemVerbas .And. lGeraRes .And. lAbriu20 .And. !lFechou20)
	S1200F20(@cXmlAux)//ideADC
	S1200F19(@cXmlAux)//infoPerAnt
EndIf

Return

/*/{Protheus.doc} fPLR2299
Crias as Tags no XML do Evento S-2299 com as verbas pagas no Roteiro de PLR
@author Cícero Alves
@since 11/10/2018
@version 12.1.17
@Param cXml, Caracter, String com o XML que será enviado para o TAF - Deve ser passada por referência
@param oModel, Object, Objeto com as informações da rescisão
@Param aDadosCTT, Array, Informações dos estabelecimentos / lotações
@Param cIndSimp, Caracter, Indicador do Tipo de Simples Nacional.
/*/
Function fPLR2299( cXml, oModel, aDadosCCT, cIndSimp, dDataRes)

	Local cAliasPLR	:= GetNextAlias()
	Local dLastDate	:= ""
	Local cIdTbRub	:= If(! Empty(xFilial("SRV", SRA->(RA_FILIAL))), xFilial("SRV", SRA->(RA_FILIAL)), cEmpAnt)
	Local cVersEnvio:= ""
	Local nPosCC	:= 0
	Local nPercRub	:= 0
	Local aArea		:= GetArea()
	Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0
	Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0

	fVersEsoc( "S2299",,,, @cVersEnvio )

	If cVersEnvio < "9.0"
		lRVIncop := .F.
		lRVTetop := .F.
	Endif
	If lMiddleware
		cIdTbRub := fGetIdRJF( xFilial("SRV", SRA->RA_FILIAL), cIdTbRub )
	EndIf

	dDataRes		:= If(! Empty(oModel), oModel:GetModel("GPEM040_MSRG"):GetValue("RG_DATADEM"), dDataRes)
	cProcess		:= If(! Empty(oModel), oModel:GetModel("GPEM040_MSRG"):GetValue("RG_PROCES"), SRA->RA_PROCES)

	BeginSQL Alias cAliasPLR
		SELECT 	 SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_DATARQ, SRD.RD_CC, SRD.RD_PD, SRD.RD_PERIODO, SRD.RD_ROTEIR, SUM(SRD.RD_HORAS) RD_HORAS, SUM(SRD.RD_VALOR) RD_VALOR, MAX(SRD.RD_DATPGT) RD_DATPGT, MAX(SRD.R_E_C_N_O_) RECNO, 'SRD' AS TAB
		FROM	 %table:SRD% SRD
		WHERE 	 SRD.RD_FILIAL =	%exp:SRA->RA_FILIAL%
		AND 	 SRD.RD_MAT    =	%exp:SRA->RA_MAT%
		AND 	 SRD.RD_DATARQ =	%exp:AnoMes(dDataRes)%
		AND 	 SRD.RD_ROTEIR =	'PLR'
		AND      SRD.%notDel%
		GROUP BY RD_FILIAL, RD_MAT, RD_DATARQ, RD_CC, RD_PD, RD_PERIODO, RD_ROTEIR
		UNION ALL
		SELECT 	 SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_PERIODO, SRC.RC_CC, SRC.RC_PD, SRC.RC_PERIODO, SRC.RC_ROTEIR, SUM(SRC.RC_HORAS) RD_HORAS, SUM(SRC.RC_VALOR) RD_VALOR, MAX(SRC.RC_DATA) RD_DATPGT, MAX(SRC.R_E_C_N_O_) RECNO, 'SRC' AS TAB
		FROM	 %table:SRC% SRC
		WHERE 	 SRC.RC_FILIAL 	=	%exp:SRA->RA_FILIAL%
		AND 	 SRC.RC_MAT		=	%exp:SRA->RA_MAT%
		AND 	 SRC.RC_PERIODO =	%exp:AnoMes(dDataRes)%
		AND 	 SRC.RC_ROTEIR 	=	'PLR'
		AND      SRC.%notDel%
		GROUP BY RC_FILIAL, RC_MAT, RC_PERIODO, RC_CC, RC_PD, RC_PERIODO, RC_ROTEIR
		ORDER BY 1, 2, 3, 4, 5
	EndSQL

	While ! (cAliasPLR)->(Eof())

		// Verifica se a data houve integração do período de PLR
		// Se foi integrado não gera o pagamento separado
		If ! Empty(Posicione("RCH", 1, (cAliasPLR)->(xFilial("RCH", RD_FILIAL) + cProcess + RD_PERIODO + "01" + "PLR"), "RCH_DTINTE" ))
			EXIT
		EndIf

		If dLastDate != (cAliasPLR)->RD_DATPGT

			dLastDate := (cAliasPLR)->RD_DATPGT
			cIdDmDev := SRA->RA_FILIAL + (cAliasPLR)->RD_DATPGT + (cAliasPLR)->RD_PERIODO + (cAliasPLR)->RD_ROTEIR
			nPosCC := Ascan( aDadosCCT, { |X| X[1] == (cAliasPLR)->RD_CC })

			cXml += "<dmDev>"
			cXml += "<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
			cXml += "<infoPerApur>"
			cXml += "<ideEstabLot>"
			cXml += "<tpInsc>" + aDadosCCT[nPosCC, 2] + "</tpInsc>"
			If !lMiddleware
				cXml += "<nrInsc>"+ aDadosCCT[nPosCC,3] + " </nrInsc>"
			Else
				cXml += "<nrInsc>"+ Alltrim(aDadosCCT[nPosCC,3]) + " </nrInsc>"
			Endif
			cXml += "<codLotacao>" + StrTran( aDadosCCT[nPosCC,4], "&", "&amp;") + "</codLotacao>"

		EndIf

		PosSrv( (cAliasPLR)->RD_PD, (cAliasPLR)->RD_FILIAL )
		nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )
		//Não leva as verbas de IR
		If ( ( cVersEnvio < "2.6.00" .And. !(Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .Or. cVersEnvio >= "9.0" ) .And. (cAliasPLR)->RD_VALOR > 0
			cXml += "<detVerbas>"
			cXml += 	"<codRubr>" + (cAliasPLR)->RD_PD + "</codRubr>"
			cXml += 	"<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
			If !lMiddleware .Or. !Empty((cAliasPLR)->RD_HORAS)
				cXml += "<qtdRubr>" + Str((cAliasPLR)->RD_HORAS) + "</qtdRubr>"
			EndIf
			If !lMiddleware .Or. !Empty(nPercRub)
				cXml += "<fatorRubr>" + Transform(nPercRub,"@E 999.99") + "</fatorRubr>"
			EndIf
			If (!lMiddleware .Or. !Empty((cAliasPLR)->RD_VALOR) ) .And. cVersEnvio < "9.0.00"
				If !lMiddleware
					cXml += "<vrUnit>" + AllTrim( Transform((cAliasPLR)->RD_VALOR, "@E 999999999.99") ) + "</vrUnit>"
				Else
					cXml += "<vrUnit>" + AllTrim( Str((cAliasPLR)->RD_VALOR) ) + "</vrUnit>"
				EndIf
			EndIf
			If !lMiddleware
				cXml += 	"<vrRubr>" + AllTrim( Transform((cAliasPLR)->RD_VALOR, "@E 999999999.99") ) + "</vrRubr>"
			Else
				cXml += 	"<vrRubr>" + AllTrim( Str((cAliasPLR)->RD_VALOR) ) + "</vrRubr>"
			EndIf
			If cVersEnvio >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
				cXml +=         '<indApurIR>0</indApurIR>'
			Endif
			cXml += "</detVerbas>"
			If lMiddleware .And. ( (SRV->RV_NATUREZ == "9901" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9201" .And. SRV->RV_INCCP $ "31/32") .Or. (SRV->RV_NATUREZ == "1409" .And. SRV->RV_INCCP == "51") .Or. (SRV->RV_NATUREZ == "4050" .And. SRV->RV_INCCP == "21") .Or. (SRV->RV_NATUREZ == "4051" .And. SRV->RV_INCCP == "22") .Or. (SRV->RV_NATUREZ == "9902" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9904" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9908" .And. SRV->RV_TIPOCOD == "3") )
				fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, aDadosCCT[nPosCC, 2], aDadosCCT[nPosCC, 3], aDadosCCT[nPosCC, 4], SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, (cAliasPLR)->RD_VALOR, "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""))
			EndIf
		EndIf

		(cAliasPLR)->(dbSkip())

		If dLastDate != (cAliasPLR)->RD_DATPGT .Or. (cAliasPLR)->(Eof())
			If SRA->RA_TPPREVI == "1"
				S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
			EndIf
			If ! Empty(cIndSimp)
				cXml += "<infoSimples>"
				cXml += "<indSimples>" + cIndSimp + "</indSimples>"
				cXml += "</infoSimples>"
			EndIf
			cXml += "</ideEstabLot>"
			cXml += "</infoPerApur>"
			cXml += "</dmDev>"
		EndIf

	EndDo

	(cAliasPLR)->(dbCloseArea())

	RestArea(aArea)

Return

/*/{Protheus.doc} function
description
@author Cícero Alves
@since 16/10/2018
@version 12.1.17
@param cXml, Caracter, String com as informações que serão enviadas para o TAF - Deve ser passada por referência
@param oModel, Object, Modelo de dados com as informações da rescsão (GPEM040)
@param aDadosCCT, Array, Informações dos estabelecimentos / Lotações
@param cVBDiss, Caracter, Verbas que foram pagas no dissídio
@Param cIndSimp, Caracter, Indicador do Tipo de Simples Nacional.
@param lRetif, Logico, Indica se é retificação
@param aColsRes, Array, Informações das verbas geradas nas rescisão atual
/*/
Static Function fResCom(cXml, oModel, aDadosCCT, cVBDiss, cIndSimp, lRetif, aColsRes)

	Local aPdResCom	:= {}
	Local cAliasSRR := GetNextAlias()
	Local dLastDate	:= ""
	Local cIdTbRub	:= If( ! Empty(xFilial("SRV", SRA->(RA_FILIAL))), xFilial("SRV", SRA->(RA_FILIAL)), cEmpAnt)
	Local cVersEnvio:= ""
	Local nContCols	:= 0
	Local nContPd	:= 0
	Local nPosCC	:= 0
	Local nPosPD	:= 0
	Local nPercRub	:= 0
	Local oModelSRG	:= oModel:GetModel("GPEM040_MSRG")
	Local cCCAnt	:= ""
	Local cTpInscr	:= ""
	Local cInscr	:= ""
	Local cBusca	:= ""
	Local nValorRub := 0
	Local aRubAux 	:= {}
	Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0
	Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0

	Private aCC			:= fGM23CTT()//extrai lista de c.custo da filial conectada "xfilial(CTT)" ...

	Default lRetif  := .F.

	fVersEsoc( "S2299",,,, @cVersEnvio )

	If cVersEnvio < "9.0"
		lRVIncop := .F.
	 	lRVTetop := .F.
	Endif
	If lMiddleware
		cIdTbRub := fGetIdRJF( xFilial("SRV", SRA->RA_FILIAL), cIdTbRub )
	EndIf

	BeginSQL Alias cAliasSRR
		SELECT SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_CC, SRR.RR_PD, SUM(SRR.RR_HORAS) RR_HORAS, SUM(SRR.RR_VALOR) RR_VALOR, MAX(SRR.RR_DATA) RR_DATA, SRR.RR_PERIODO, SRR.RR_ROTEIR, MAX(SRR.R_E_C_N_O_) RECNO
		FROM %Table:SRR% SRR
		WHERE SRR.RR_FILIAL = %Exp: oModelSRG:GetValue("RG_FILIAL")% AND
		SRR.RR_MAT = %Exp: oModelSRG:GetValue("RG_MAT")% AND
		SRR.RR_TIPO3 = 'R' AND
		SRR.RR_DATA < %Exp:dToS(oModelSRG:GetValue("RG_DTGERAR"))% AND
		SRR.%NotDel%
		GROUP BY RR_FILIAL, RR_MAT, RR_DATA, RR_CC, RR_PD, RR_PERIODO, RR_ROTEIR
		ORDER BY 1, 2, 7, 3, 4
	EndSQL

	While ! (cAliasSRR)->(Eof())

		If dLastDate != (cAliasSRR)->RR_DATA
			dLastDate 	:= (cAliasSRR)->RR_DATA
			cCCAnt 		:= ""
			cIdDmDev 	:= "R" + cEmpAnt + AllTrim(oModelSRG:GetValue("RG_FILIAL")) + (cAliasSRR)->RR_MAT + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
			nPosCC 		:= Ascan( aDadosCCT, { |X| X[1] == (cAliasSRR)->RR_CC })

			cXml += "<dmDev>"
			cXml += "<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
			cXml += "<infoPerApur>"
		EndIf

		If dLastDate != (cAliasSRR)->RR_DATA .Or. cCCAnt <> (cAliasSRR)->RR_CC
			cTpInscr	:= ""
			cInscr		:= ""
			cCCAnt 		:= (cAliasSRR)->RR_CC

			fEstabELot((cAliasSRR)->RR_FILIAL, (cAliasSRR)->RR_CC, @cTpInscr, @cInscr, @cBusca, "", AnoMes((cAliasSRR)->RR_DATA))

			nPosCC := Ascan( aDadosCCT, { |X| X[1] == (cAliasSRR)->RR_CC })
			cBusca := aDadosCCT[nPosCC,4]

			cXml += "<ideEstabLot>"
			cXml += "<tpInsc>" + cTpInscr + "</tpInsc>"
			cXml += "<nrInsc>"+ cInscr + " </nrInsc>"
			cXml += "<codLotacao>" + StrTran( cBusca, "&", "&amp;") + "</codLotacao>"
		EndIf

		PosSrv( (cAliasSRR)->RR_PD, (cAliasSRR)->RR_FILIAL )
		nPercRub := If( (SRV->RV_PERC - 100) <= 0, 0, SRV->RV_PERC - 100 )

		// Não leva as verbas de desconto de IR pois serão informadas no evento S-1210
		// As  do roteriro de PLR devem ser levadas em um pagamento (DmDev) diferente
		If (cAliasSRR)->RR_ROTEIR != "PLR" .And. (cAliasSRR)->RR_VALOR > 0 .And.;
			 ( (cVersEnvio < "2.6.00" .Or. cVersEnvio >= "9.0.00") .And. !(Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83") ) .And.;
			!(SRV->RV_CODFOL $ "0126|0303")

			nValorRub	:= (cAliasSRR)->RR_VALOR
			If ( nPosPd := aScan( aPdResCom, { |x| x[1] + x[2] == (cAliasSRR)->RR_CC + (cAliasSRR)->RR_PD } ) ) == 0
				aAdd( aPdResCom, { (cAliasSRR)->RR_CC, (cAliasSRR)->RR_PD, (cAliasSRR)->RR_HORAS, (cAliasSRR)->RR_VALOR } )
			Else
				nValorRub			 := ( (cAliasSRR)->RR_VALOR - aPdResCom[nPosPD, 4])
				aPdResCom[nPosPD, 3] += (cAliasSRR)->RR_HORAS
				aPdResCom[nPosPD, 4] += (cAliasSRR)->RR_VALOR
			EndIf
			If nValorRub > 0
				cXml += "<detVerbas>"
				cXml += 	"<codRubr>" + (cAliasSRR)->RR_PD + "</codRubr>"
				cXml += 	"<ideTabRubr>" + cIdTbRub + "</ideTabRubr>"
				If !lMiddleware .Or. !Empty((cAliasSRR)->RR_HORAS)
					cXml += "<qtdRubr>" + Str((cAliasSRR)->RR_HORAS) + "</qtdRubr>"
				EndIf
				If !lMiddleware .Or. !Empty(nPercRub)
					cXml += "<fatorRubr>" + Transform(nPercRub,"@E 999.99") + "</fatorRubr>"
				EndIf
				If (!lMiddleware .Or. !Empty((cAliasSRR)->RR_VALOR)) .And. cVersEnvio < "9.0.00"
					If !lMiddleware
						cXml += "<vrUnit>" + AllTrim( Transform(nValorRub, "@E 999999999.99") ) + "</vrUnit>"
					Else
						cXml += "<vrUnit>" + AllTrim( Str(nValorRub) ) + "</vrUnit>"
					EndIf
				EndIf
				If !lMiddleware
					cXml += 	"<vrRubr>" + AllTrim( Transform(nValorRub, "@E 999999999.99") ) + "</vrRubr>"
				Else
					cXml += 	"<vrRubr>" + AllTrim( Str(nValorRub) ) + "</vrRubr>"
				EndIf
				If cVersEnvio >= "9.0.00" .And. cValToChar( Year(M->RG_DATADEM) ) >= "2021"
					cXml +=         '<indApurIR>0</indApurIR>'
				Endif
				cXml += "</detVerbas>"
				If lMiddleware .And. ( (SRV->RV_NATUREZ == "9901" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9201" .And. SRV->RV_INCCP $ "31/32") .Or. (SRV->RV_NATUREZ == "1409" .And. SRV->RV_INCCP == "51") .Or. (SRV->RV_NATUREZ == "4050" .And. SRV->RV_INCCP == "21") .Or. (SRV->RV_NATUREZ == "4051" .And. SRV->RV_INCCP == "22") .Or. (SRV->RV_NATUREZ == "9902" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9904" .And. SRV->RV_TIPOCOD == "3") .Or. (SRV->RV_NATUREZ == "9908" .And. SRV->RV_TIPOCOD == "3") )
					fGrvRJO( SRA->RA_FILIAL, "1", AnoMes(M->RG_DATADEM), SRA->RA_CIC, SRA->RA_NOME, SRA->RA_CODUNIC, SRA->RA_CATEFD, cTpInscr, cInscr, cBusca, SRV->RV_NATUREZ, SRV->RV_TIPOCOD, SRV->RV_INCCP, SRV->RV_INCFGTS, SRV->RV_INCIRF, nValorRub, "S-2299" , , , , If(lRVIncop, SRV->RV_INCOP,""), If(lRVTetop, SRV->RV_TETOP, ""))
				EndIf
			EndIf
		EndIf

		(cAliasSRR)->(dbSkip())

		If dLastDate != (cAliasSRR)->RR_DATA .Or. (cAliasSRR)->(Eof())
			If SRA->RA_TPPREVI == "1"
				S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
			EndIf
			If ! Empty(cIndSimp)
				cXml += "<infoSimples>"
				cXml += "<indSimples>" + cIndSimp + "</indSimples>"
				cXml += "</infoSimples>"
			EndIf
			cXml += "</ideEstabLot>"
			cXml += "</infoPerApur>"
			cXml += "</dmDev>"
		EndIf
		If dLastDate == (cAliasSRR)->RR_DATA .And. cCCAnt <> (cAliasSRR)->RR_CC
			If SRA->RA_TPPREVI == "1"
				S1200A18(@cXml, {fGrauExp()}, .T.) //infoAgNocivo
			EndIf
			If ! Empty(cIndSimp)
				cXml += "<infoSimples>"
				cXml += "<indSimples>" + cIndSimp + "</indSimples>"
				cXml += "</infoSimples>"
			EndIf
			cXml += "</ideEstabLot>"
			lFirst := .F.
		EndIf

	EndDo

	(cAliasSRR)->(dbCloseArea())

	If !lRetif
		For nContPd := 1 To Len(aColsRes)
			For nContCols := 1 To Len(aPdResCom)
				If aColsRes[nContPd, 12] + aColsRes[nContPd, 3] == aPdResCom[nContCols, 1] + aPdResCom[nContCols, 2]
					aColsRes[nContPd, 15] -= aPdResCom[nContCols, 3]
					aColsRes[nContPd, 16] -= aPdResCom[nContCols, 4]
					aColsRes[nContPd, 17] -= aPdResCom[nContCols, 4]
				EndIf
			Next nContCols
		Next nContPd
	EndIf

Return

/*/{Protheus.doc} f1312299
Função que verifica se houve o pagamento do roteiro 131 no calculo de rescisao
@author Allyson
@since 06/12/2018
@version 1.0
@param aCC 	 	- Array com os centros de custo
@param aPds	 	- Array com as verbas
@param cFilEnv	- Filial de integração no TAF
@param cIdDmDev	- Identificador do dmDev
@param lRetif	- Identifica se é complementar por retificação
@param aErrosRJ5- Array com centros de custo sem relacionamento na RJ5
/*/
Function f1312299( aCC, aPds, cFilEnv, cIdDmDev, lRetif, aErrosRJ5,cVersaoEnv )

Local aAreaCTT  := CTT->( GetArea() )
Local aAreaSRV 	:= SRV->( GetArea() )
Local cPerSeek	:= ""
Local cRot131	:= fGetCalcRot("5")//131
Local cSRCSeek	:= ""
Local cSRDSeek	:= ""

Default lRetif		:= .F.
Default aErrosRJ5	:= {}
Default cVersaoEnv  := "2.4"

DbSelectArea("SRC")
DbSetOrder(RetOrder("SRC", "RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))

If lRetif
	cPerSeek := AnoMes(M->RG_DATADEM)
Else
	cPerSeek := M->RG_PERIODO
EndIf

cSRCSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRot131 + cPerSeek + M->RG_SEMANA
cIdDmDev := ""
If DbSeek( cSRCSeek )
	While SRC->(!Eof() .And. RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA == cSRCSeek )
		fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRC->RC_PD, SRC->RC_CC, SRC->RC_HORAS, SRC->RC_VALOR, SRC->RC_DATA, SRC->RC_PERIODO, SRC->RC_ROTEIR, cVersaoEnv, @aErrosRJ5 )
		SRC->(DbSkip())
	EndDo
EndIf

//Procura o roteiro do adiantamento que ja foi fechado referente ao periodo de calculo da rescisao
DbSelectArea("SRD")
DbSetOrder(RetOrder("SRD", "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRot131 + cPerSeek + M->RG_SEMANA
If DbSeek( cSRDSeek )
	While SRD->(!Eof() .And. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA == cSRDSeek )
		fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRD->RD_PD, SRD->RD_CC, SRD->RD_HORAS, SRD->RD_VALOR, SRD->RD_DATPGT, SRD->RD_PERIODO, SRD->RD_ROTEIR, Nil, @aErrosRJ5 )
		SRD->(DbSkip())
	EndDo
EndIf

RestArea(aAreaCTT)
RestArea(aAreaSRV)

Return

/*/{Protheus.doc} f1322299
Função que verifica se houve o pagamento do roteiro 132 no calculo de rescisao
@author Allyson
@since 24/04/2020
@version 1.0
@param aCC 	 	- Array com os centros de custo
@param aPds	 	- Array com as verbas
@param cFilEnv	- Filial de integração no TAF
@param cIdDmDev	- Identificador do dmDev
@param lRetif	- Identifica se é complementar por retificação
@param aErrosRJ5- Array com centros de custo sem relacionamento na RJ5
/*/
Function f1322299( aCC, aPds, cFilEnv, cIdDmDev, lRetif, aErrosRJ5,cVersaoEnv ,aFilInTaf, lAdmPubl, cTpInsc, cNrInsc )

Local aAreaCTT  := CTT->( GetArea() )
Local aAreaSRV 	:= SRV->( GetArea() )
Local aAreaRCH	:= RCH->( GetArea() )
Local cPerSeek	:= ""
Local cRot132	:= fGetCalcRot("6")//132
Local cSRCSeek	:= ""
Local cSRDSeek	:= ""
Local dDtPgto	:= cToD("//")
Local nRchIndex	:= RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" )
Local aStatC91      := {}
Local cStatC91      := "-1"

Private nQtdeFol	:= 1
Private lTemEmp		:= !Empty(FWSM0Layout(cEmpAnt, 1))
Private lTemGC		:= fIsCorpManage( FWGrpCompany() )
Private cLayoutGC	:= FWSM0Layout(cEmpAnt)
Private nIniEmp 	:= At("E", cLayoutGC)
Private nTamEmp		:= Len(FWSM0Layout(cEmpAnt, 1))

Default lRetif		:= .F.
Default aErrosRJ5	:= {}
Default cVersaoEnv  := "2.4"
Default aFilInTaf   := {}
Default lAdmPubl	:= .F.
Default cTpInsc		:= ""
Default cNrInsc     := ""

aStatC91 := fVerStat( 1, @cFilEnv, M->RG_PERIODO, aClone(aFilInTaf), "2",,,,,,,,lAdmPubl, cTpInsc, cNrInsc  )
cStatC91 := aStatC91[1]

RCH->( dbSetOrder(nRchIndex) )

If RCH->( dbSeek( xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES + iF(lRetif, AnoMes(M->RG_DATADEM), M->RG_PERIODO) + M->RG_SEMANA + cRot132 ) )
	dDtPgto := RCH->RCH_DTPAGO
EndIf

//Somente gera os dados de 13º na rescisão se a rescisão NÃO for em dezembro com data de demissão maior ou igual ao pagamento do 13º (roteiro 132)
If !(SUBSTR(DTOS(M->RG_DATADEM),5,2) == "12" .And. (M->RG_DATADEM >= dDtPgto .Or. (M->RG_DATADEM < dDtPgto .And. cStatC91 <> "-1") ) )
	DbSelectArea("SRC")
	DbSetOrder(RetOrder("SRC", "RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))

	If lRetif
		cPerSeek := AnoMes(M->RG_DATADEM)
	Else
		cPerSeek := M->RG_PERIODO
	EndIf

	cSRCSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRot132 + cPerSeek + M->RG_SEMANA
	cIdDmDev := ""
	If DbSeek( cSRCSeek )
		While SRC->(!Eof() .And. RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA == cSRCSeek )
			fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRC->RC_PD, SRC->RC_CC, SRC->RC_HORAS, SRC->RC_VALOR, SRC->RC_DATA, SRC->RC_PERIODO, SRC->RC_ROTEIR, cVersaoEnv, @aErrosRJ5 )
			SRC->(DbSkip())
		EndDo
	EndIf

	//Procura o roteiro do adiantamento que ja foi fechado referente ao periodo de calculo da rescisao
	DbSelectArea("SRD")
	DbSetOrder(RetOrder("SRD", "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

	cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRot132 + cPerSeek + M->RG_SEMANA
	If DbSeek( cSRDSeek )
		While SRD->(!Eof() .And. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA == cSRDSeek )
			fADI2299Pd( @aCC, @aPds, cFilEnv, @cIdDmDev, SRD->RD_PD, SRD->RD_CC, SRD->RD_HORAS, SRD->RD_VALOR, SRD->RD_DATPGT, SRD->RD_PERIODO, SRD->RD_ROTEIR, cVersaoEnv, @aErrosRJ5 )
			SRD->(DbSkip())
		EndDo
	EndIf
EndIf

RestArea(aAreaCTT)
RestArea(aAreaSRV)
RestArea(aAreaRCH)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEstabELot
Função responsável por buscar identifcação do estabelecimento e
lotação, retornando nos parâmetros passados por referência ( cTpInscr
, cInscr e codLotacao)
@author  Rafael Reis
@since   17/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function fEstabELot(cFil, cCentroC, cTpInscr, cInscr, codLotacao, cCCOrig, cCompete)
Local cFilLocCTT := FWxFilial("CTT", cFil)
Local cFilLocRJ5 := ""
Local cFilTrb	 := ""
Local nPosLot 	 := 0
Local nPosEstb 	 := 0
Local cCEIObra 	 := ""
Local cCAEPF 	 := ""
Local lRJ5FilT	 := RJ5->(ColumnPos("RJ5_FILT")) > 0
Local lTemReg	 := .F.

//Variáveis private aEstb e aCC declaradas no início da Faz1200

If !lVerRJ5
	If !Empty(cCentroC) .AND. Len(aCC) > 0
		nPosLot := aScan(aCC,{|x| x[1] == cFilLocCTT .AND. x[2] == cCentroC })
		If nPosLot > 0
			//CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
			If aCC[nPosLot,6] == "01" .And. aCC[nPosLot,3] == "4" .And. aCC[nPosLot,8] == "2"
				cTpInscr	:= aCC[nPosLot,3]
				cInscr		:= aCC[nPosLot,4]
			EndIf
		EndIf
	Endif
Else
	If lRJ5FilT
		//Pesquisa utilizando o novo campo RJ5_FILT
		RJ5->( dbSetOrder(5) )//RJ5_FILIAL+RJ5_COD+RJ5_CC+RJ5_INI
		RJ5->(dbGoTop())
		If RJ5->( dbSeek( xFilial("RJ5", cFil) + cCentroC + cCCOrig ) )
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", cFil) .And. RJ5->RJ5_COD == cCentroC .And. RJ5->RJ5_CC == cCCOrig .And. RJ5->RJ5_FILT == cFil
				If SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					lTemReg		:= .T.
				EndIf
				RJ5->( dbSkip() )
			EndDo
		EndIf
		If !lTemReg
			RJ5->( dbSetOrder(5) )//RJ5_FILIAL+RJ5_COD+RJ5_CC+RJ5_INI
			RJ5->(dbGoTop())
			If RJ5->( dbSeek( xFilial("RJ5", cFil) + cCentroC + cCCOrig ) )
				While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", cFil) .And. RJ5->RJ5_COD == cCentroC .And. RJ5->RJ5_CC == cCCOrig .And. EMPTY(RJ5->RJ5_FILT)
					If SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= RJ5->RJ5_INI
						cTpInscr	:= RJ5->RJ5_TPIO
						cInscr  	:= RJ5->RJ5_NIO
					EndIf
					RJ5->( dbSkip() )
				EndDo
			EndIf
		EndIf
	Else
		RJ5->( dbSetOrder(5) )//RJ5_FILIAL+RJ5_COD+RJ5_CC+RJ5_INI
		If RJ5->( dbSeek( xFilial("RJ5", cFil) + cCentroC + cCCOrig ) )
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", cFil) .And. RJ5->RJ5_COD == cCentroC .And. RJ5->RJ5_CC == cCCOrig
				If SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
				EndIf
				RJ5->( dbSkip() )
			EndDo
		EndIf
	EndIf
EndIf

If Empty(cTpInscr) .OR. Empty(cInscr)
	If fBuscaOBRA( cFil, @cCEIObra )
		cTpInscr := "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
		cInscr 	 := cCEIObra // Codigo da inscricao
	Elseif fBuscaCAEPF( cFil, @cCAEPF )
		cTpInscr := "3"
		cInscr	 := cCAEPF
	Else
		nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cFil)})
		If nPosEstb > 0
			cTpInscr	:= aEstb[nPosEstb,3]
			cInscr		:= aEstb[nPosEstb,2]
		EndIf
	EndIf
Endif


cCentroC := StrTran(cCentroC, "&", "&amp;")

If !lVerRJ5
	cFilTrb		:= cFilLocCTT
Else
	cFilLocRJ5 	:= FWxFilial("RJ5", cFil)
	cFilTrb		:= cFilLocRJ5
EndIf
If !Empty(cFilTrb)
	codLotacao := ( cFilTrb + cCentroC )
Else
	codLotacao	:= cCentroC
EndIf

Return

/*/{Protheus.doc} fGrauExp
Função que retorna valor para a tag <grauExp>
@author Allyson
@since 14/09/2018
@version 1.0
@return cCod  - Código de grau de exposição
/*/
Static Function fGrauExp()

Local cCod := "1"

If AllTrim(SRA->RA_OCORREN) $ "02#03#04#06#07#08"
	If AllTrim(SRA->RA_OCORREN) $ "02#06"
		cCod := "2"
	ElseIf AllTrim(SRA->RA_OCORREN) $ "03#07"
		cCod := "3"
	Else
		cCod := "4"
	EndIf
EndIf

Return cCod

/*/{Protheus.doc} fFol2299
Função que verifica se houve o pagamento do roteiro FOL no calculo de rescisao
@author Allyson
@since 31/07/2019
@version 1.0
@param aCC 	 	- Array com os centros de custo
@param aPds	 	- Array com as verbas
@param cFilEnv	- Filial de integração no TAF
@param aIdDmDev	- Identificador do dmDev
@param lRetif	- Identifica se é complementar por retificação
@param aErrosRJ5- Array com centros de custo sem relacionamento na RJ5
/*/
Function fFOL2299( aCC, aPds, cFilEnv, aIdDmDev, cVersaoEnv, lRetif, cSemana )

Local aAreaCTT  := CTT->( GetArea() )
Local aAreaSRV 	:= SRV->( GetArea() )
Local cDmDev	:= ""
Local cPerSeek	:= ""
Local cRotFol	:= Iif(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"), fGetRotOrdinar())
Local cSRDSeek	:= ""
Local aCCAux	:= {}
Local aPDsAux	:= {}
Local dDtPgto	:= cToD("//")
Local nRchIndex	:= RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" )

Default cVersaoEnv := "2.4"
Default lRetif 	   := .F.
Default aErrosRJ5  := {}
Default cSemana    := "02"

If lRetif
	cPerSeek := AnoMes(M->RG_DATADEM)
Else
	cPerSeek := M->RG_PERIODO
EndIf

RCH->( dbSetOrder(nRchIndex) )

//Procura o roteiro da folha que ja foi fechado referente ao periodo de calculo da rescisao
DbSelectArea("SRD")
DbSetOrder(RetOrder("SRD", "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

cSemana := StrZero( Val( cSemana ) - 1, 2 )

While Val(cSemana) > 0
	cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRotFol + cPerSeek + cSemana
	If SRD->( DbSeek( cSRDSeek ) )
		While SRD->(!Eof() .And. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA == cSRDSeek )
			fFOL2299Pd( @aCCAux, @aPDsAux, cFilEnv, SRD->RD_PD, SRD->RD_CC, SRD->RD_HORAS, SRD->RD_VALOR, SRD->RD_DATPGT, SRD->RD_PERIODO, SRD->RD_ROTEIR, cVersaoEnv, @aErrosRJ5 )
			SRD->(DbSkip())
		EndDo
	EndIf
	If !Empty(aPDsAux)
		If RCH->( dbSeek( xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES + cPerSeek + cSemana + cRotFol ) )
			dDtPgto := RCH->RCH_DTPAGO
		EndIf
		cDmDev := SRA->RA_FILIAL + dToS(dDtPgto) + cPerSeek + cRotFol
		aAdd( aIdDmDev, cDmDev )
		aAdd( aCC, aClone(aCCAux) )
		aAdd( aPds, aClone(aPDsAux) )
	EndIf
	cSemana := StrZero( Val( cSemana ) - 1, 2 )
	aCCAux  := {}
	aPDsAux := {}
EndDo

RestArea(aAreaCTT)
RestArea(aAreaSRV)

Return

/*/{Protheus.doc} fFOL2299Pd
Função que verifica as verbas pagas do roteiro FOL no calculo de rescisao
@author Allyson
@since 31/07/2019
@version 1.0
@param aCC 	 		- Array com os centros de custo
@param aPds	 		- Array com as verbas
@param cFilEnv		- Filial de integração no TAF
@param aIdDmDev		- Identificador do dmDev
@param cCodPd		- Código da verba
@param cCodCC		- Código do centro de custo
@param nHoras		- Horas da verba
@param nValor		- Valor da verba
@param dDtPgto		- Data de pagamento da verba
@param cPeriodo		- Periodo da verba
@param cRoteiro		- Roteiro da verba
@param cVersaoEnv	- Versão de envio
@param aErrosRJ5	- Array com centros de custo sem relacionamento na RJ5
/*/
Function fFOL2299Pd( aCC, aPds, cFilEnv, cCodPd, cCodCC, nHoras, nValor, dDtPgto, cPeriodo, cRoteiro, cVersaoEnv, aErrosRJ5 )

Local cCEIObra		:= ""
Local cCAEPF		:= ""
Local cChaveCC		:= ""
Local cChaveCCPD	:= ""
Local cChaveS1005	:= ""
Local cCodLot		:= ""
Local cCodRubr		:= ""
Local cIdeRubr		:= ""
Local cInscr		:= ""
Local cPrcRubr		:= ""
Local cTpInscr		:= ""
Local cTpLot		:= ""
Local cVerbIRF		:= ""
Local cIncIrf		:= ""
Local lGeraCod		:= .F.
Local lSemFilSRV	:= .F.
Local nPosCC		:= 0
Local nPosCCPD		:= 0
Local nPosEstb		:= 0
Local lRJ5FilT 		:= RJ5->(ColumnPos("RJ5_FILT")) > 0
Local lTemReg		:= .F.
Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0 .And. cVersaoEnv >= "9.0"
Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0 .And. cVersaoEnv >= "9.0"


Default cVersaoEnv	:= "2.4"
Default aErrosRJ5	:= {}

cChaveCCPD	:= cCodCC + cCodPd
cChaveCC	:= cCodCC

nPosCCPD	:= Ascan( @aPds, {|X| X[1] == cChaveCCPD })
nPosCC		:= Ascan( @aPds, {|X| X[12] == cChaveCC })

SRV->(DbSetOrder(1))
If( SRV->( dbSeek( xFilial("SRV", SRA->RA_FILIAL) + cCodPd  ) ) )

	If ( cVersaoEnv < "2.6.00" .And. Substr(SRV->RV_INCIRF, 1, 2) $ "31*32*33*34*35*51*52*53*54*55*81*82*83" )
		Return()
	Endif

	//Tratamento de compartilhamento da tabela SRV
	If !Empty(SRV->RV_FILIAL)
		lGeraCod := .T.
	Else
		lSemFilSRV := .T.
	EndIf
	//------------------
	//| Lógica lGeraCod
	//| .T. -> Exclusiva | .F. -> Compartilhada
	//------------------------------------------
	If lGeraCod
		cIdeRubr := SRV->RV_FILIAL
	Else
		If cVersaoEnv >= "2.3"
			cIdeRubr := cEmpAnt
		Else
			cIdeRubr := ""
		EndIf
	EndIf
	If lMiddleware
		cIdeRubr := fGetIdRJF( SRV->RV_FILIAL, cIdeRubr )
	EndIf
	cCodRubr := SRV->RV_COD		//Codigo  da Rubrica
	If (SRV->RV_PERC - 100) < 0
		cPrcRubr :=	0	//Percent da Rubrica
	Else
		cPrcRubr := SRV->RV_PERC - 100//Percent da Rubrica
	EndIf
EndIf

If !lVerRJ5
	CTT->(DbSetOrder(1))
	If( CTT->( dbSeek( xFilial("CTT", SRA->RA_FILIAL) + cCodCC ) ) )
		cCodLot := IIf(Empty(xFilial("CTT", SRA->RA_FILIAL)), CTT->CTT_CUSTO, CTT->CTT_FILIAL+CTT->CTT_CUSTO )
		cTpLot  := CTT->CTT_TPLOT	// Tipo de Lotação (?!?)

		//Verifica se eh uma obra por meio do campo CTT_TIPO2
		If CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
			cTpInscr 	:= CTT->CTT_TIPO2 // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
			cInscr   	:= CTT->CTT_CEI2  // Codigo da inscricao
			cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
		Endif
	EndIf
Else
	RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
	If RJ5->( !dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC ) )
		If aScan(aErrosRJ5, { |x| x == cCodCC }) == 0
			aAdd( aErrosRJ5, cCodCC )
		EndIf
	Else
		If lRJ5FilT
			RJ5->(DbSetOrder(7)) //RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
			RJ5->(dbGoTop())
			RJ5->( dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC + SRA->RA_FILIAL) )
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC .And. RJ5->RJ5_FILT == SRA->RA_FILIAL
				If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
					cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
					lTemReg		:= .T.
				EndIf
				RJ5->( dbSkip() )
			EndDo
			//Se não encontrou um registro com código preenchido reposiciona a tabela e executa o dbseek novamente.
			If !lTemReg
				RJ5->(DbSetOrder(4)) //RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
				RJ5->(dbGoTop())
				RJ5->( dbSeek( xFilial("RJ5", SRA->RA_FILIAL) + cCodCC ) )
				While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC .And. EMPTY(RJ5->RJ5_FILIAL)
					If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
						cTpInscr	:= RJ5->RJ5_TPIO
						cInscr  	:= RJ5->RJ5_NIO
						cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
						cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
					EndIf
					RJ5->( dbSkip() )
				EndDo
			EndiF
		Else
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRA->RA_FILIAL) .And. RJ5->RJ5_CC == cCodCC
				If AnoMes( dDtPgto ) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					cCodLot		:= IIf(Empty(xFilial("RJ5", SRA->RA_FILIAL)), RJ5->RJ5_COD, RJ5->RJ5_FILIAL+RJ5->RJ5_COD )
					cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
				EndIf
				RJ5->( dbSkip() )
			EndDo
		EndIf
		If Empty(cCodLot)
			If aScan(aErrosRJ5, { |x| x == cCodCC }) == 0
				aAdd( aErrosRJ5, cCodCC )
			EndIf
		EndIf
		nPosCCPD	:= Ascan( @aPds,{|X| X[20] == cCodLot + cCodPd })
		nPosCC		:= Ascan( @aPds,{|X| X[19] == cCodLot })
	EndIf
EndIf

//Verifica na tabela F0F se a Filial eh uma obra
If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
	cCEIObra := ""
	If fBuscaOBRA( cFilEnv, @cCEIObra )
		cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
		cInscr 	 	:= cCEIObra // Codigo da inscricao
		cChaveS1005 := cFilEnv+cInscr
	Elseif fBuscaCAEPF( cFilEnv, @cCAEPF )
		cTpInscr 	:= "3"
		cInscr	 	:= cCAEPF
		cChaveS1005 := cFilEnv+cInscr
	EndIf
EndIf

If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
	nPosEstb := eVal(bEstab)
	If nPosEstb > 0
		cTpInscr	:= aEstb[nPosEstb,3]
		cInscr		:= aEstb[nPosEstb,2]
		cChaveS1005 := SRA->RA_FILIAL+cInscr
	EndIf
EndIf

If(nPosCC == 0)
	aAdd(aCC, {cCodCC, cTpInscr, cInscr, cCodLot, cChaveS1005 } )
EndIf

//------------------------------------------------
//| Array de Dados
//| Montagem do array com os dados a utilizar para o XML
//-------------------------------------------------------
If( nPosCCPD > 0 )
	aPds[nPosCCPD, 15] += nHoras	//Incrementa Valor
	aPds[nPosCCPD, 17] += nValor	//Incrementa Valor
	aPds[nPosCCPD, 18] += 1	  		//Incrementa Contador
Else
	aAdd(aPds, { 	cCodCC + cCodPd,;	    			//01 - Chave para pesquisa (CC+PD)
					"Dados da Verba",;					//02 - Separador - Verbas/Rubricas
					cCodRubr,;							//03 - Codigo da Rubrica
					cIdeRubr,;							//04 - Ident   da Rubrica
					cPrcRubr,;							//05 - Percent da Rubrica
					"Dados do CC",;						//06 - Separador - Centro de Custo
					cCodLot,;							//07 - Codigo da Lotação
					cTpInscr,;							//08 - Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
					cInscr,;							//09 - Codigo da inscricao
					cTpLot,;							//10 - Tipo de Lotação (?!?)
					"Dados da Grid",;					//11 - Separador - Centro de Custo
					cCodCC,;							//12 - Centro de Custo
					cCodPd,;							//13 - Verba da rescisão
					SRV->RV_DESC,;						//14 - Descricao da verba
					nHoras,;							//15 - Horas da verba
					nValor,;							//16 - Valor da verba
					nValor,;							//17 - Acumulado da verba (valor inicial para soma)
					1,;									//18 - Numero de registro repetidos (CC + PD)
					cCodLot,;							//19 - Código de lotação
					cCodLot + cCodPd,;					//20 - Chave para pesquisa (Código Lotação+PD)
					SRV->RV_NATUREZ,;					//21 - Natureza da verba
					SRV->RV_INCCP,;						//22 - Incidência CP da verba
					SRV->RV_INCFGTS,;					//23 - Incidência FGTS da verba
					SRV->RV_INCIRF,;					//24 - Incidência IRRF da verba
					SRV->RV_TIPOCOD,;					//25 - Tipo da verba
					If(lRVIncop, SRV->RV_INCOP,""),;	//26 - Incid RPPS
					If(lRVTetop, SRV->RV_TETOP,"") })	//27 - Teto Remun


EndIf

Return

/*/{Protheus.doc} fVerRJ5B()
Função que verifica o relacionamento da tabela RJ5 e utiliza o centro de custo informado em RJ5_COD
A troca é efetuada manualmente pois cada centro de custo pode ter um relacionamento diferente, com
início de validade diferente, o que impossibilita o "Inner Join" na query dos lançamentos
@type function
@author allyson.mesashi
@since 03/04/2019
@version 1.0
@param cRHHAlias	= Alias da tabela temporária principal
@param cRHHRJ5		= Alias da tabela temporária auxiliar
@param cPeriod		= Período para verificação da validade
@param lRJ5Ok		= Flag de cadastro do relacionamento na RJ5
@param aErrosRJ5	= Array com os centros de custo que não foram encontrados
/*/
Static Function fVerRJ5B(cRHHAlias, cRHHRJ5, cPeriod, lRJ5Ok, aErrosRJ5)
	Local aColumns	 := {}
	Local cKeyAux	 := ""
	Local cCCAnt	 := ""
	Local cCCRJ5	 := ""
	Local lNovo		 := .F.
	Local lRJ5FilT	 := RJ5->(ColumnPos("RJ5_FILT")) > 0
	Local lTemReg    := .F.

	aAdd( aColumns, { "RHH_FILIAL"	,"C",FwGetTamFilial,0 })
	aAdd( aColumns, { "RHH_MAT"		,"C",nTamMat,0})
	aAdd( aColumns, { "RHH_MESANO"	,"C",6,0})
	aAdd( aColumns, { "RHH_DATA"	,"C",6,})
	aAdd( aColumns, { "RHH_VB"		,"C",nTamVb,0})
	aAdd( aColumns, { "RHH_CC"		,"C",nTamCC,0})
	aAdd( aColumns, { "RHH_VERBA"	,"C",nTamVb,0})
	aAdd( aColumns, { "RHH_DTACOR"	,"C",8,0})
	aAdd( aColumns, { "RHH_VALOR"	,"N",nTamVal,nDecVal})
	aAdd( aColumns, { "RHH_HORAS"	,"N",nTamHor,nDecHor})
	aAdd( aColumns, { "RHH_CCBKP"	,"C",nTamCC,0})

	//Cria uma tabela temporária auxiliar
	oTmpTabRH := FWTemporaryTable():New(cRHHRJ5)
	oTmpTabRH:SetFields( aColumns )
	oTmpTabRH:AddIndex( "IND", { "RHH_FILIAL", "RHH_MAT", "RHH_MESANO", "RHH_DATA", "RHH_CC", "RHH_VB" } )
	oTmpTabRH:Create()

	//Percorre o resultado da query da SRD/SRC e verifica o relacionamento na RJ5, efetuando troca do RD_CC por RJ5_COD
	//gravando o resultado na tabela temporária auxiliar
	While (cRHHAlias)->(!Eof())
		lNovo	:= (cRHHRJ5)->( !dbSeek( (cRHHAlias)->RHH_FILIAL+(cRHHAlias)->RHH_MAT+(cRHHAlias)->RHH_MESANO+(cRHHAlias)->RHH_DATA+(cRHHAlias)->RHH_CC+(cRHHAlias)->RHH_VB ) )
		lTemReg	:= .F.
		If RecLock(cRHHRJ5, lNovo)
			If lNovo
				(cRHHRJ5)->RHH_FILIAL 	:= (cRHHAlias)->RHH_FILIAL
				(cRHHRJ5)->RHH_MAT 		:= (cRHHAlias)->RHH_MAT
				(cRHHRJ5)->RHH_MESANO 	:= (cRHHAlias)->RHH_MESANO
				(cRHHRJ5)->RHH_DATA 	:= (cRHHAlias)->RHH_DATA
				(cRHHRJ5)->RHH_VB 		:= (cRHHAlias)->RHH_VB

				If cCCAnt != (cRHHAlias)->RHH_CC
					cCCAnt := (cRHHAlias)->RHH_CC
					cCCRJ5 := ""
					//Se possui o campo RJ5_FILT pesquisa na RJ5 com este campo preenchido
					If lRJ5FilT
						RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
						If RJ5->( dbSeek( xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC + (cRHHAlias)->RHH_FILIAL) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) .And. RJ5->RJ5_CC == (cRHHAlias)->RHH_CC .And. RJ5->RJ5_FILT == (cRHHAlias)->RHH_FILIAL
								If cPeriod >= RJ5->RJ5_INI
									cCCRJ5 	:= RJ5->RJ5_COD
									lTemReg	:= .T.
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
						//Se não encontrou registro refaz a pesquisa da forma antiga
						If !lTemReg
							RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
							RJ5->(dbGoTop())
							If RJ5->( dbSeek( xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC) )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) .And. RJ5->RJ5_CC == (cRHHAlias)->RHH_CC .And. EMPTY(RJ5->RJ5_FILT)
									If cPeriod >= RJ5->RJ5_INI
										cCCRJ5 := RJ5->RJ5_COD
									EndIf
									RJ5->( dbSkip() )
								EndDo
							EndIf
						EndIf
						If Empty(cCCRJ5)
							lRJ5Ok 	:= .F.
							If aScan(aErrosRJ5, { |x| x == cCCAnt }) == 0
								aAdd( aErrosRJ5, cCCAnt )
							EndIf
						EndIf
					Else
						RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
						If RJ5->( dbSeek( xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) .And. RJ5->RJ5_CC == (cRHHAlias)->RHH_CC
								If cPeriod >= RJ5->RJ5_INI
									cCCRJ5 := RJ5->RJ5_COD
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
						If Empty(cCCRJ5)
							lRJ5Ok 	:= .F.
							If aScan(aErrosRJ5, { |x| x == cCCAnt }) == 0
								aAdd( aErrosRJ5, cCCAnt )
							EndIf
						EndIf
					EndiF
				EndIf

				(cRHHRJ5)->RHH_CC 		:= cCCRJ5
				(cRHHRJ5)->RHH_VERBA 	:= (cRHHAlias)->RHH_VERBA
				(cRHHRJ5)->RHH_DTACOR 	:= (cRHHAlias)->RHH_DTACOR
				(cRHHRJ5)->RHH_CCBKP	:= cCCAnt
			EndIf
			(cRHHRJ5)->RHH_VALOR	+= (cRHHAlias)->RHH_VALOR
			(cRHHRJ5)->RHH_HORAS	+= (cRHHAlias)->RHH_HORAS

			(cRHHRJ5)->(MsUnlock())
		EndIf
		(cRHHAlias)->(DbSkip())
	EndDo

	(cRHHAlias)->( dbCloseArea() )
	(cRHHRJ5)->( dbGoTop() )

	//Cria uma tabela temporária com o mesmo alias da query da SRD/SRC
	oTmpTabl2 := FWTemporaryTable():New(cRHHAlias)
	oTmpTabl2:SetFields( aColumns )
	oTmpTabl2:AddIndex( "IND", { "RHH_FILIAL", "RHH_MAT", "RHH_MESANO", "RHH_DATA", "RHH_CC", "RHH_VB" } )
	oTmpTabl2:Create()

	//Percorre a tabela temporário auxiliar gravando o resultado na tabela temporária com o mesmo alias da query da SRD/SRC
	While (cRHHRJ5)->(!Eof())
		lNovo	:= (cRHHAlias)->( !dbSeek( (cRHHRJ5)->RHH_FILIAL+(cRHHRJ5)->RHH_MAT+(cRHHRJ5)->RHH_MESANO+(cRHHRJ5)->RHH_DATA+(cRHHRJ5)->RHH_CC+(cRHHRJ5)->RHH_VB ) )
		If RecLock(cRHHAlias, lNovo)
			If lNovo
				(cRHHAlias)->RHH_FILIAL := (cRHHRJ5)->RHH_FILIAL
				(cRHHAlias)->RHH_MAT 	:= (cRHHRJ5)->RHH_MAT
				(cRHHAlias)->RHH_MESANO := (cRHHRJ5)->RHH_MESANO
				(cRHHAlias)->RHH_DATA	:= (cRHHRJ5)->RHH_DATA
				(cRHHAlias)->RHH_VB		:= (cRHHRJ5)->RHH_VB
				(cRHHAlias)->RHH_CC		:= (cRHHRJ5)->RHH_CC
				(cRHHAlias)->RHH_CCBKP	:= (cRHHRJ5)->RHH_CCBKP
			EndIf
			(cRHHAlias)->RHH_VALOR	+= (cRHHRJ5)->RHH_VALOR

			(cRHHAlias)->(MsUnlock())
		EndIf
		(cRHHRJ5)->(DbSkip())
	EndDo

	(cRHHAlias)->( dbGoTop() )

Return

/*/{Protheus.doc} fIntResLot()
Cria um browse que permite a seleção dos funcionários para a integração em lote do desligamento para eSocial
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Function fIntResLot()

Local aArea			:= GetArea()
Local aAreaSRA		:= SRA->( GetArea() )
Local aAreaSRG		:= SRG->( GetArea() )
Local aAreaSX3		:= SX3->( GetArea() )
Local aFieldFilt	:= {}
Local aSeek			:= {}
Local oTmpTable		:= Nil
Local lLibAtu		:= (GetApoInfo("FWFORMBROWSE.PRW")[4] > sToD("20200401"))

Private aMarcSRG	:= {}
Private _MarcReg	:= {}
Private aGpm040Log	:= {}
Private cAliasMark 	:= "TABAUX"
Private aSrgStruct	:= SRG->(DBSTRUCT())

Static _Marcados	:= {}

fCriaTmp(@oTmpTable, @aSrgStruct, @aFieldFilt)
aColsMark:= fMntColsMark(aSrgStruct)

aAdd(aSeek, {STR0213,{{"", "C", FwGetTamFilial+TamSX3("RG_MAT")[1]+8, 0, "RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)", "@!"}} } )//"Filial + Matricula + Data Geracao"

oBrowse := FWMarkBrowse():New()
oBrowse:SetAlias((cAliasMark))
oBrowse:SetFields(aColsMark)
oBrowse:SetFieldMark("RG_OKTRANS")
oBrowse:SetMenuDef('')
oBrowse:AddButton(STR0196, {|| ProcGpe( {|lEnd| fEnvLote()}, "" )},,,, .F., 2 ) //"Integrar"
oBrowse:SetDescription(OemToAnsi(STR0197)) //"Rescisões"

//Se a lib estiver atualizada libera a utilização de filtro padrão na MarkBrowse
If lLibAtu
	oBrowse:SetFieldFilter(aFieldFilt)
Else
	Aviso(OemToAnsi(STR0001), OemToAnsi(STR0243), {OemToAnsi(STR0038)})
EndIf

oBrowse:SetSeek(.T., aSeek)
oBrowse:SetAfterMark({|| fMarca() })
oBrowse:SetAllMark({|| fMarkAll() })
oBrowse:Activate()

If ValType(oTmpTable) == "O"
	oTmpTable:Delete()
EndIf
_Marcados := {}
RestArea(aArea)
RestArea(aAreaSRA)
RestArea(aAreaSRG)
RestArea(aAreaSX3)

Return

/*/{Protheus.doc} fCriaTmp()
Efetua filtro dos registros da tabela SRG aptos a serem integrados
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fCriaTmp(oTmpTable, aColumns, aFldFilter)

Local cAliasSRG	:= GetNextAlias()
Local cValidFil	:= ""
Local nCont		:= 0
Local nPos		:= 0

// Filtro das filiais que o usuário tem acesso
If Len(fValidFil()) <= 2000
	cValidFil := "(AllTrim(SRG->RG_FILIAL) $ '" + fValidFil() + "')"
Else
	cValidFil := "(!AllTrim(SRG->RG_FILIAL) $ '" + fValidFil(, .T.) + "')"
EndIf

aAdd( aColumns, { "RG_OKTRANS","C",02,00 })

If (nPos := aScan( aColumns, { |x| x[1] == "RG_MAT" } )) > 0
	aAdd( aColumns )
	aIns( aColumns, nPos+1 )
	aColumns[nPos+1] := { "RG_NOME","C",TamSx3("RG_NOME")[1],00 }
	aAdd( aColumns )
	aIns( aColumns, nPos+2 )
	aColumns[nPos+2] := { "RA_CATEFD","C",3,00 }
EndIf
If (nPos := aScan( aColumns, { |x| x[1] == "RG_TIPORES" } )) > 0
	aAdd( aColumns )
	aIns( aColumns, nPos+1 )
	aColumns[nPos+1] := { "RG_DESCTPR","C",TamSx3("RG_DESCTPR")[1],00 }
EndIf
If (nPos := aScan( aColumns, { |x| x[1] == "RA_NOME" } )) > 0
	aDel( aColumns, nPos )
	aSize( aColumns, Len(aColumns)-1)
EndIf

//Efetua a criacao do arquivo temporario
oTmpTable := FWTemporaryTable():New(cAliasMark)
oTmpTable:SetFields( aColumns )
oTmpTable:AddIndex( "TABAUX1", {"RG_FILIAL","RG_MAT", "RG_DTGERAR"} )
oTmpTable:Create()

cWhere := "SRG.RG_EFETIVA = 'S' "
cWhere += "AND SRG.D_E_L_E_T_ = ' '"
cWhere := "% " + cWhere + " %"

BeginSql alias cAliasSRG
	SELECT  R_E_C_N_O_ AS RECNOSRG
	FROM %table:SRG% SRG
	WHERE %exp:cWhere%
	ORDER BY SRG.RG_FILIAL, SRG.RG_MAT, SRG.RG_DTGERAR
EndSql

SRA->(dbSetOrder(1))
While (cAliasSRG)->(!Eof())
	SRG->( dbGoto( (cAliasSRG)->RECNOSRG ) )
	If !( &( cValidFil ) )
		(cAliasSRG)->(dbSkip())
		Loop
	EndIf
	If SRA->( dbSeek( SRG->RG_FILIAL+SRG->RG_MAT ) )
		If RecLock(cAliasMark,.T.)
			(cAliasMark)->RG_FILIAL 	:= SRG->RG_FILIAL
			(cAliasMark)->RG_MAT 		:= SRG->RG_MAT
			(cAliasMark)->RG_NOME	 	:= SRA->RA_NOME
			(cAliasMark)->RA_CATEFD	 	:= SRA->RA_CATEFD
			(cAliasMark)->RG_EFETIVA	:= SRG->RG_EFETIVA
			(cAliasMark)->RG_SABDOM 	:= SRG->RG_SABDOM
			(cAliasMark)->RG_TIPORES	:= SRG->RG_TIPORES
			(cAliasMark)->RG_DESCTPR	:= fDescRCC("S043",SRG->RG_TIPORES,1,2,3,30)
			(cAliasMark)->RG_DTAVISO 	:= SRG->RG_DTAVISO
			(cAliasMark)->RG_DAVISO  	:= SRG->RG_DAVISO
			(cAliasMark)->RG_DAVCUM 	:= SRG->RG_DAVCUM
			(cAliasMark)->RG_DAVIND 	:= SRG->RG_DAVIND
			(cAliasMark)->RG_DATADEM 	:= SRG->RG_DATADEM
			(cAliasMark)->RG_DATAHOM	:= SRG->RG_DATAHOM
			(cAliasMark)->RG_DTGERAR	:= SRG->RG_DTGERAR
			(cAliasMark)->RG_DTPROAV	:= SRG->RG_DTPROAV
			(cAliasMark)->RG_MEDATU 	:= SRG->RG_MEDATU
			(cAliasMark)->RG_DFERVEN	:= SRG->RG_DFERVEN
			(cAliasMark)->RG_DFERPRO 	:= SRG->RG_DFERPRO
			(cAliasMark)->RG_DFERAVI  	:= SRG->RG_DFERAVI
			(cAliasMark)->RG_NORMAL  	:= SRG->RG_NORMAL
			(cAliasMark)->RG_DESCANS 	:= SRG->RG_DESCANS
			(cAliasMark)->RG_SALMES  	:= SRG->RG_SALMES
			(cAliasMark)->RG_SALDIA 	:= SRG->RG_SALDIA
			(cAliasMark)->RG_SALHORA	:= SRG->RG_SALHORA
			(cAliasMark)->RG_PROCES 	:= SRG->RG_PROCES
			(cAliasMark)->RG_COMPRAV 	:= SRG->RG_COMPRAV
			(cAliasMark)->RG_JTCUMPR	:= SRG->RG_JTCUMPR
			(cAliasMark)->RG_IDCMPL  	:= SRG->RG_IDCMPL
			(cAliasMark)->RG_RESCDIS	:= SRG->RG_RESCDIS
			(cAliasMark)->RG_RRA    	:= SRG->RG_RRA
			(cAliasMark)->RG_TPAVISO 	:= SRG->RG_TPAVISO
			(cAliasMark)->RG_RHEXP    	:= SRG->RG_RHEXP
			(cAliasMark)->RG_NPROC   	:= SRG->RG_NPROC
			(cAliasMark)->RG_OBITO   	:= SRG->RG_OBITO
			(cAliasMark)->RG_PERIODO 	:= SRG->RG_PERIODO
			(cAliasMark)->RG_ROTEIR 	:= SRG->RG_ROTEIR
			(cAliasMark)->RG_SUCES  	:= SRG->RG_SUCES
			(cAliasMark)->RG_OBS    	:= SRG->RG_OBS
			(cAliasMark)->RG_SEMANA  	:= SRG->RG_SEMANA
			(cAliasMark)->RG_TPDIR  	:= SRG->RG_TPDIR
			(cAliasMark)->RG_INDAV   	:= SRG->RG_INDAV
			(cAliasMark)->RG_NPROCS   	:= SRG->RG_NPROCS
			(cAliasMark)->RG_TPSU     	:= SRG->RG_TPSU
			(cAliasMark)->RG_PDRESC  	:= SRG->RG_PDRESC
			If SRG->(ColumnPos("RG_NOVSUBS")) > 0
				(cAliasMark)->RG_NOVSUBS  	:= SRG->RG_NOVSUBS
			EndIf
			If SRG->(ColumnPos("RG_CTOBRA")) > 0
				(cAliasMark)->RG_CTOBRA  	:= SRG->RG_CTOBRA
			EndIf
			(cAliasMark)->(MsUnlock())
		EndIf
	EndIf
	(cAliasSRG)->( dbSkip() )
EndDo
(cAliasSRG)->( dbCloseArea() )

For nCont := 1 To Len(aColumns)
	aAdd( aFldFilter, { aColumns[nCont, 1], FWX3Titulo( aColumns[nCont, 1] ), aColumns[nCont, 2], aColumns[nCont, 3], aColumns[nCont, 4], X3Picture( aColumns[nCont, 1] ) } )
Next nCont

Return

/*/{Protheus.doc} FMntColsMark
Carrega tabela temporária com dados para exibição na MarkBrowse
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fMntColsMark(aCampos)

Local aArea		:= GetArea()
Local aColsAux 	:=`{}
Local aColsSX3	:= {}
Local nX		:= 0

DbSelectArea("SX3")
DbSetOrder(2)

For nX := 1 to Len(aCampos)
	If SX3->( dbSeek(aCampos[nX,1]) )
		aColsSX3 := {X3Titulo(), &("{||(cAliasMark)->"+(aCampos[nX,1])+"}"), SX3->X3_TIPO, SX3->X3_PICTURE,1,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,,,,,,,,1}
		aAdd(aColsAux,aColsSX3)
		aColsSX3 := {}
	EndIf
Next nX

RestArea(aArea)

Return aColsAux

/*/{Protheus.doc} fMarca
Realiza a marcação de um registro no browse
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fMarca()

Local cKey := (cAliasMark)->RG_FILIAL + (cAliasMark)->RG_MAT + dToS((cAliasMark)->RG_DTGERAR)
Local nPos := aScan( aMarcSRG, { |x| ( x[1] == cKey )})

If oBrowse:IsMark()
	Aadd( aMarcSRG, { (cAliasMark)->RG_FILIAL + (cAliasMark)->RG_MAT + dToS((cAliasMark)->RG_DTGERAR) } )
	Aadd(_Marcados, oBrowse:At())
Else
	If ( nPos > 0 )
		nLastSize := Len( aMarcSRG )
		aDel( aMarcSRG, nPos )
		aDel(_Marcados, nPos)
		aSize( aMarcSRG, ( nLastSize - 1 ))
		aSize(_Marcados, ( nLastSize - 1 ))
	EndIF
EndIf

Return

/*/{Protheus.doc} fMarkAll
Faz a marcação de todos os registros do browse
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fMarkAll()

Local nUltimo

oBrowse:GoBottom(.F.)
nUltimo := oBrowse:At()
oBrowse:GoTop()

While .T.
	oBrowse:MarkRec()
	If nUltimo == oBrowse:At()
		oBrowse:GoTop()
		Exit
	EndIf
	oBrowse:GoDown()
EndDo

Return

/*/{Protheus.doc} fClear
Limpa as marcações do browse
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fClear()

While Len(_Marcados) >= 1
	oBrowse:GoTo(_Marcados[1])
	oBrowse:MarkRec()
EndDo

oBrowse:Refresh(.T.)

Return

/*/{Protheus.doc} fEnvLote()
Efetua validação e envio do desligamento ao eSocial
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fEnvLote()

Local aErros	:= {}
Local aLogTitle	:= { STR0198 }//"Rescisões Processadas:"
Local aLogFile	:= {}
Local aTpAlt 	:= {.F.,.F.,.F.}
Local cBkpFil	:= cFilAnt
Local cTrabVincu:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
Local cStatus0 	:= "-1"
Local cVersEnvio:= ""
Local lGravou	:= .T.
Local lResComp	:= .F.
Local lRetif	:= .F.
Local lGeraMat	:= .F.
Local lTemMat	:= SRA->(ColumnPos("RA_DESCEP")) > 0
Local nCont		:= 0
Local nX		:= 0
Local nI		:= 0
Local oModel	:= Nil
Local oModelSRG	:= Nil
Local oGrid		:= Nil
Local cBkpTpRes	:= ""

Private aIncRes		:= {}
Private aPd_Aux		:= {}
Private dDataDem1	:= cToD("//")
Private aInfoC		:= {}
Private cTpInsc  	:= ""
Private lAdmPubl 	:= .F.
Private cNrInsc  	:= "0"
Private cChaveMid	:= ""
Private cErro		:= "0"

If Len(aMarcSRG) < 1
	Help(' ', 1, STR0020, , STR0199, 1, 0) //"Atenção"##"Nenhuma rescisão foi selecionada."
	Return
EndIf
GPProcRegua( Len(aMarcSRG) )
oBrowse:Refresh(.T.)
fVersEsoc( "S2299", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME
(cAliasMark)->( dbSetOrder(1) )//RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)
SRG->( dbSetOrder(1) )//RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)
For nCont := 1 To Len(aMarcSRG)
	(cAliasMark)->( dbSeek( aMarcSRG[nCont, 1] ) )
	SRG->( dbSeek( aMarcSRG[nCont, 1] ) )
	SRA->( dbSeek( (cAliasMark)->RG_FILIAL+(cAliasMark)->RG_MAT ) )
	GPIncProc(STR0009 + SRA->RA_FILIAL + SRA->RA_MAT )//"Matrícula: "
	aErros		:= {}
	aErroRes	:= {}
	aTpAlt 		:= {.F.,.F.,.F.}
	cFilAnt		:= SRA->RA_FILIAL
	lGravou 	:= .T.
	lResComp 	:= .F.
	lRet		:= .T.
	lRetif		:= .F.
	lGeraMat	:= Iif(lTemMat, SRA->RA_DESCEP == "1", .F.)
	nI			:= 0

	oModel 		:= FWLoadModel("GPEM040")
	oModelSRG	:= oModel:GetModel('GPEM040_MSRG')
	oGrid 		:= oModel:GetModel('GPEM040_MGET')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	fUpdAtBrw(.F.)
	oModel:Activate()

	If fResCompl(Nil ,.T., Nil, @lResComp, @lRetif)
		cCdEFD := fM40TPRES( oModelSRG:GetValue("RG_TIPORES"), , oModelSRG:GetValue("RG_TIPORES") <> cBkpTpRes,oModelSRG:GetValue("RG_DATADEM") )
		cBkpTpRes :=  oModelSRG:GetValue("RG_TIPORES")
		lRet := fM40VLRES( 	AllTrim( oModelSRG:GetValue("RG_TPAVISO") ),;	//Tipo Aviso
								cCdEFD,;									//Tipo Rescisao eSocial
								oModelSRG:GetValue("RG_DATADEM"),;				//Data de Demissao
								oModelSRG:GetValue("RG_OBITO"),;				//Certidao Obito (não tem esse codigo)
								"1",;										//Rescisao Coletiva (1=Rescisao Simples / 2=Rescisao Coletiva)
								oModelSRG:GetValue("RG_INDAV"),;				//
								@aErroRes,;									//Erro na persistência dos dados da rescisao
								.F.,;
								cVersEnvio,;
								Nil,;
								.T.)
		If !lRet
			lGravou := .F.
		EndIf
		If lGravou
			If SRA->RA_CATEFD $ cTrabVincu
				cCPF := AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
			Else
				If !lMiddleware
					If cVersEnvio >= "9.0"
						cCPF := AllTrim( SRA->RA_CIC ) + ";" + Iif(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
					Else
						cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
					EndIf
				Else
					cCPF := Iif( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
				EndIf
			EndIf
			If SRA->RA_CATEFD $ cTrabVincu
				If !lMiddleware
					cStatus1 := TAFGetStat( "S-2200", cCPF)
				Else
					cStatus1 := "-1"
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
					aInfoC   := fXMLInfos()
					If LEN(aInfoC) >= 4
						cTpInsc  := aInfoC[1]
						lAdmPubl := aInfoC[4]
						cNrInsc  := aInfoC[2]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
					cStatus1 	:= "-1"
					//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
					GetInfRJE( 2, cChaveMid, @cStatus1 )
				EndIf
			Else
				If !lMiddleware
					cStatus1 := TAFGetStat( "S-2300", cCPF)
				Else
					fPosFil( cEmpAnt, cFilAnt )
					aInfoC   := fXMLInfos()
					If LEN(aInfoC) >= 4
						cTpInsc  := aInfoC[1]
						lAdmPubl := aInfoC[4]
						cNrInsc  := aInfoC[2]
					Else
						cTpInsc  := ""
						lAdmPubl := .F.
						cNrInsc  := "0"
					EndIf
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
					cStatus1 	:= "-1"
					//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
					GetInfRJE( 2, cChaveMid, @cStatus1 )
				EndIf
			EndIf
			If cStatus0 == '2' .OR. cStatus1 == '2'
				cErro := "2"
			ElseIf cStatus0 == '3' .OR. cStatus1 == '3' .OR. cStatus0 == ' ' .OR. cStatus1 == ' ' .OR. cStatus0 == '1' .OR. cStatus1 == '1'
				cErro := " |1|3"
			ElseIf cStatus0 == '-1' .AND. cStatus1 == '-1'
				cErro := "-1"
			ElseIf cStatus0 == '-1' .AND. cStatus1 == '6'
				cErro := "6"
			ElseIf cStatus0 == '-1' .AND. cStatus1 == '7'
				cErro := "7"
			Else
				fStatusTAF(@aTpAlt,cStatus0,cStatus1,/*cFuncaoPai*/, /*aContainer*/)
			EndIf
			If aTpAlt[3]
				If SRA->RA_CATEFD $ cTrabVincu
					If !lMiddleware
						cStatus1 := TAFGetStat( "S-2299", cCPF)
					Else
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(SRA->RA_CODUNIC, fTamRJEKey(), " ")
						cStatus1 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStatus1 )
					EndIf
				Else
					If !lMiddleware
						cStatus1 := TAFGetStat( "S-2399", SubStr(cCPF, 1, 11)+";;")
					Else
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2399" + Padr( AllTrim(SRA->RA_CIC)+AllTrim(SRA->RA_CATEFD)+dToS(SRA->RA_ADMISSA), fTamRJEKey(), " ")
						cStatus1 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStatus1 )
					EndIf
				EndIf
				If cStatus1 != "2"
					RegToMemory(cAliasMark, .F., .F., .F., "fEnvLote")
					If SRA->RA_CATEFD $ cTrabVincu
						lRet := fInt2299( oModel, @aErros, "S2299", cCdEFD, "1", Nil, oModelSRG:GetValue("RG_DATADEM"), Nil, cVersEnvio, Nil, lResComp, lRetif, Nil, .T. )
					Else
						dDataDem1 := (cAliasMark)->RG_DATADEM
						lRet := fInt2399New( oModel, @aErros, "S2399", cCdEFD, "1", Nil, oModelSRG:GetValue("RG_DATADEM"), Nil, cVersEnvio, Nil, lResComp, lRetif )
					EndIf
					If lRet
						If SRA->RA_CATEFD $ cTrabVincu
							aAdd( aLogfile, OemToAnsi(STR0200) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2299 - Desligamento foi gerado com sucesso para o funcionário: "
						Else
							aAdd( aLogfile, OemToAnsi(STR0201) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2399 - Desligamento foi gerado com sucesso para o funcionário: "
						EndIf
						For nX := 1 To Len( aErros )
							aAdd( aLogfile, STR0204 + "#" + cValToChar(nX) + ": " + aErros[ nX ] )//"Aviso"
							nI++
						Next
						If Len( aErroRes ) > 0
							aAdd( aLogfile, STR0204 + "#" + cValToChar(nI + 1) + ": " + aErroRes[1] )//"Aviso"
						EndIf
						aAdd( aLogfile, "" ) //Quebra de Linha
					Else
						If SRA->RA_CATEFD $ cTrabVincu
							aAdd( aLogfile, OemToAnsi(STR0202) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2299 - Desligamento não foi gerado para o funcionário: "
						Else
							aAdd( aLogfile, OemToAnsi(STR0203) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2399 - Desligamento não foi gerado para o funcionário: "
						EndIf
						For nX := 1 To Len( aErros )
							aAdd( aLogfile, STR0205 + "#" + cValToChar(nX) + ": " + aErros[ nX ] )//"Erro"
							nI++
						Next
						If Len( aErroRes ) > 0
							aAdd( aLogfile, STR0205 + "#" + cValToChar(nI + 1) + ": " + aErroRes[1] )//"Aviso"
						EndIf
						aAdd( aLogfile, "" ) //Quebra de Linha
					EndIf
				Else
					If SRA->RA_CATEFD $ cTrabVincu
						aAdd( aLogfile, OemToAnsi(STR0202) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2299 - Desligamento não foi gerado para o funcionário: "
					Else
						aAdd( aLogfile, OemToAnsi(STR0203) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2399 - Desligamento não foi gerado para o funcionário: "
					EndIf
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0214)  ) //"Erro"##"Registro de Desligamento do Funcionário está em trânsito TAF x RET. Verifique no sistema TAF."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0215)  ) //"Erro"##"Registro de Desligamento do Funcionário está em trânsito ao RET. Verifique no Middleware."
					EndIf
					aAdd( aLogfile, "" ) //Quebra de Linha
				EndIf
			Else
				If SRA->RA_CATEFD $ cTrabVincu
					aAdd( aLogfile, OemToAnsi(STR0202) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2299 - Desligamento não foi gerado para o funcionário: "
				Else
					aAdd( aLogfile, OemToAnsi(STR0203) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) ) //"O evento S-2399 - Desligamento não foi gerado para o funcionário: "
				EndIf
				If cErro $ "2"
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0216)  ) //"Erro"##"Registro de Admissão do Funcionário está em trânsito TAF x RET. Verifique no sistema TAF. A rescisão não será efetivada."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0219)  ) //"Erro"##"Registro de Admissão do Funcionário está em trânsito ao RET. Verifique no Middleware. A rescisão não será efetivada."
					EndIf
				ElseIf cErro $ " |1|3"
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0217)  ) //"Erro"##"Registro de Admissão do Funcionário ainda não foi transmitido ao RET ou consta inconsistências. Verifique no sistema TAF. A rescisão não será efetivada."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0220)  ) //"Erro"##"Registro de Admissão do Funcionário ainda não foi transmitido ao RET ou consta inconsistências. Verifique no Middleware. A rescisão não será efetivada."
					EndIf
				ElseIf cErro $ "-1"
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0218)  ) //"Erro"##"O funcionário ainda não possui integração com o TAF. Realize a sua integração para poder gerar a rescisão. A rescisão não será efetivada."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0221)  ) //"Erro"##"O funcionário ainda não possui integração com o Middleware. Realize a sua integração para poder gerar a rescisão. A rescisão não será efetivada."
					EndIf
				ElseIf cErro == "6"
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0256)  ) //"Erro"##"Registro de Exclusão da Admissão do Funcionário está em trânsito TAF x RET. Verifique no sistema TAF. A rescisão não será efetivada."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0257)  ) //"Erro"##"Registro de Exclusão da Admissão do Funcionário está em trânsito ao RET. Verifique no Middleware. A rescisão não será efetivada."
					EndIf
				ElseIf cErro == "7"
					If !lMiddleware
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0258)  ) //"Erro"##"O funcionário teve seu registro excluido no TAF. Necessário integrar o trabalhador(S-2200) antes de integrar a rescisão. A rescisão não será efetivada."
					Else
						aAdd( aLogfile, STR0205 + ": " + OemToAnsi(STR0259)  ) //"Erro"##"O funcionário teve seu registro excluido no Middleware. Necessário integrar o trabalhador(S-2200) antes de integrar a rescisão. A rescisão não será efetivada."
					EndIf
				EndIf
				aAdd( aLogfile, "" ) //Quebra de Linha
			EndIf
		Else
			aAdd( aLogfile, STR0206 + SRA->RA_FILIAL + " - " + SRA->RA_MAT )//"Foram encontrados inconsistências para o funcionário: "
			For nX := 1 To Len( aErroRes )
				aAdd( aLogfile, STR0205 + "#" + cValToChar(nX) + ": " + aErroRes[ nX ] )//"Erro"
				aAdd( aLogfile, "" ) //Quebra de Linha
			Next
		EndIf
	Else
		If SRG->RG_DATADEM < dDtcgini
			aAdd( aLogFile, STR0254 + SRA->RA_FILIAL + STR0208 + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) )//"Rescisão não enviada por ser anterior ao período informado no parâmetro MV_DTCGINI -> Filial: "##" Matrícula: "##" Data de Geração: "
			aAdd( aLogFile, "" )
		Else
			aAdd( aLogFile, STR0207 + SRA->RA_FILIAL + STR0208 + SRA->RA_MAT + " |" + STR0209 + dToC((cAliasMark)->RG_DTGERAR) )//"Rescisão não foi enviada por ser complementar em período seguinte -> Filial: "##" Matrícula: "##" Data de Geração: "
			aAdd( aLogFile, "" )
		EndIf
	EndIf
	oModel:DeActivate()
	fUpdAtBrw(.T.)
Next nCont

fMakeLog( {aLogFile}, aLogTitle, NIL, NIL, STR0211, STR0212, NIL, NIL, NIL, .F. ) //"Lote"##"Log de Ocorrências"

fClear()

cFilAnt := cBkpFil

Return()

/*/{Protheus.doc} fGeraPD()
Guarda os registros da tabela SRR no array aPd
@author allyson.mesashi
@since 25/03/2020
@version 1.0
/*/
Static Function fGeraPD()

Private aPD			:= {}
Private aPDV		:= {}
Private aSalBase	:= {}
Private cTipoRot	:= "4"
Private nOrdGrPd	:= 0

SRR->( dbSetOrder(1) )//RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC+RR_PROCES
If SRR->( dbSeek( (cAliasMark)->RG_FILIAL+(cAliasMark)->RG_MAT+"R"+dToS((cAliasMark)->RG_DTGERAR) ) )
	While SRR->( !EoF() ) .And. SRR->RR_FILIAL+SRR->RR_MAT+SRR->RR_TIPO3+dToS(SRR->RR_DATA) == (cAliasMark)->RG_FILIAL+(cAliasMark)->RG_MAT+"R"+dToS((cAliasMark)->RG_DTGERAR)
		SRR->( fMatriz(RR_PD, RR_VALOR, Iif(SRR->RR_TIPO1 == "H", fConvHoras(SRR->RR_HORAS, "1") ,SRR->RR_HORAS), RR_SEMANA, RR_CC, RR_TIPO1, RR_TIPO2, 0, "", (cAliasMark)->RG_DATAHOM, NIL, RR_SEQ,,,,Iif(RR_TIPO2 <> "G", RR_NUMID, Nil),,, (cAliasMark)->RG_DTGERAR ) )
		SRR->( dbSkip() )
	EndDo
EndIf

Return aPd

/*/{Protheus.doc} fIntegraTAF
Função chamada ao clicar no botão de integração com o TAF dentro do visualizar
@type class
@author marcos.coutinho
@since 15/03/2018
@version 1.0
/*/
Function fIntegraTAF( lIntegra, oModelSRG, oGrid, oModel, lResComp, lRetif, aPd_SRK )
Local aErros 		:= {}
Local oModel		:= Nil
Local oModelSRG		:= Nil
Local oGrid			:= Nil

Private aPd_Aux		:= aPd_SRK

Default lIntegra 	:= .F.
Default lResComp	:= .F.
Default lRetif		:= .F.

If lIntegra
	oModel 		:= FWLoadModel("GPEM040")
	oModelSRG	:= oModel:GetModel('GPEM040_MSRG')
	oGrid 		:= oModel:GetModel('GPEM040_MGET')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	fUpdAtBrw(.F.)
	oModel:Activate()

	//------------------------------------------------------------
	//| Caso esteja vindo do botão de integração manual com o TAF
	//------------------------------------------------------------
	fIncRes(SRA->RA_FILIAL,oModelSRG:GetValue("RG_TIPORES"),@aIncRes,@nPercFgts,@cRescrais,@cAfasfgts,@Cod_Am) //Carrega "aIncRes"
	fGeraIntegracao( oModelSRG, oGrid, .T., @aErros, oModel, lResComp, lRetif )
Else
	//"Atenção" ## "Para que seja possivel realizar a integração com o TAF, é necessário que os parâmetros MV_RHTAF esteja definido como verdadeiro (.T.) e MV_FASESOC esteja configurado para eventos Não Periódicos ou Periódicos (1 ou 2)"
	Help( ,,OemToAnsi(STR0001),, OemToAnsi(STR0222), 1, 0 )//"Atenção"##"Para que seja possivel realizar a integração com o TAF, é necessário que os parâmetros MV_RHTAF esteja definido como verdadeiro (.T.) e MV_FASESOC esteja configurado para eventos Não Periódicos ou Periódicos (1 ou 2)"
EndIf

Return

/*/{Protheus.doc} fGeraIntegracao
Função centralizadora para gerar o evento de Rescisão S-2299
@type class
@author marcos.coutinho
@since 15/03/2018
@param lResComp, Logical, Indica se é o envio de uma rescisão complementar calculada no mesmo mês da rescisão original
@param lRetif, Logical, Indica se é o envio de uma rescisão complementar de retificação
@version 1.0
/*/
Function fGeraIntegracao( oModelSRG, oGrid, lRet, aErros, oModel, lResComp, lRetif )

Local cStatus0		:= ""
Local cStatus1		:= ""
Local aTpAlt		:= { .F., .F., .F., .F., .F.}
Local aFilInTaf 	:= {}
Local aArrayFil 	:= {}
Local cFilEnv 		:= ""
Local cCPF			:= ""
Local lFVerESoc		:= FindFunction("fVersEsoc")
Local lExbAlert		:= .T.
Local aRet			:= array(2)
Local cVersEnvio	:= ""
Local cVersGPE		:= ""
Local cTrabVinc 	:= fCatTrabEFD("TCV") //Retorna todos os Trab. Com Vínculo
Local cTrabSVinc	:= fCatTrabEFD("TSV") //Retorna todos os Trab. Sem Vínculo
Local lTrabVinc		:= .F.
Local lTrabSVinc	:= .F.
Local cCdEFD		:= ""
Local cCatTSV		:= SuperGetMv( "MV_NTSV", .F., "701|711|712|741|" )
Local lNT15
Local cEFDAviso  	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas
Local cFasEsoc		:= SuperGetMv("MV_FASESOC", Nil, " ")
Local lTemResc		:= ".F."
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"

Default lResComp 	:= .F.
Default lRetif 		:= .F.

lTrabVinc 	:= SRA->RA_CATEFD $ cTrabVinc
lTrabSVinc	:= SRA->RA_CATEFD $ cTrabSVinc

//Validação TAFXERP e TAFST2
If FindFunction("fVldTaf") .And. !fVldTaf()
	lRet := .F.
	Return lRet
EndIf

If lFVerESoc
	If lTrabSVinc
		lRet := fVersEsoc( 'S2399', lExbAlert, , @aRet, @cVersEnvio, @cVersGPE, Nil, @lNT15 )
	Else
		lRet := fVersEsoc( 'S2299', lExbAlert, , @aRet, @cVersEnvio, @cVersGPE, Nil, @lNT15 )
	EndIf
	If Empty(cVersGPE)
		cVersGPE := cVersEnvio
	EndIf
Else
	lRet := .T.
EndIf

If lRet .And. !lTrabVinc .And. !lTrabSVinc
	Help(/*1*/,/*2*/,OemToAnsi(STR0001),,OemToAnsi(STR0223),1,0)//"Atenção"##"O campo RA_CATEFD não está preenchido. Efetue o preenchimento antes de efetuar o cálculo da rescisão"
	lRet := .F.
EndIf

If lRet .And. ANOMES(oModelSRG:GetValue("RG_DTGERAR")) > oModelSRG:GetValue("RG_PERIODO") .And. oModelSRG:GetValue("RG_RESCDIS") == "0"
	//A data de geração da rescisão é maior que o período de cálculo (Data de demissão), desta forma serão apresentadas inconsistências na geração dos eventos S-2299/S-2399 e S-1200 e na apuração das bases de INSS e FGTS.
	Help(/*1*/,/*2*/,OemToAnsi(STR0001),,OemToAnsi(STR0269),1,0,Nil, Nil, Nil, Nil, Nil, {OemToAnsi(STR0270)})//
	lRet := .F.
EndIf

If lRet

	//Verifica se o registro do funcionario existe e esta integrado com TAF com sucesso
	If lTrabVinc .OR.  lTrabSVinc
		If !lMiddleware
			fGp23Cons(@aFilInTaf, {SRA->RA_FILIAL}, @cFilEnv)
		EndIf
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf

		If lTrabSVinc
			If !lMiddleware
				If cVersEnvio >= "9.0"
					cCPF := AllTrim( SRA->RA_CIC ) + ";" + Iif(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
				Else
					cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
				EndIf
				cStatus0 := cStatus1 := TAFGetStat( "S-2300", cCPF, cEmpAnt, cFilEnv )
			Else
				cCPF := Iif( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
				fPosFil( cEmpAnt, cFilAnt )
				aInfoC   := fXMLInfos()
				If LEN(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
				cStatus0 	:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatus0 )
				cStatus1	:= cStatus0
			EndIf
		Else
			cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CODUNIC )
			If !lMiddleware
				cStatus0 := cStatus1 := TAFGetStat( "S-2200", cCPF, cEmpAnt, cFilEnv )
			Else
				fPosFil( cEmpAnt, SRA->RA_FILIAL )
				aInfoC   := fXMLInfos()
				If LEN(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
				cStatus0 	:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatus0 )
				cStatus1	:= cStatus0
			EndIf
		EndIf
	EndIf

	If SRA->RA_CATEFD $ cCatTSV .And. cStatus1 == "-1"
		Return .T.
	EndIf
	//--------------------------------------
	//| Recupera o tipo de rescisao eSocial
	//| Realiza o De/Para do Tipo de Rescisao informada no
	//| sistema para o tipo de rescisao que o eSocial reconhece
	//-----------------------------------------------------------
	cCdEFD := fM40TPRES( oModelSRG:GetValue("RG_TIPORES"),,,oModelSRG:GetValue("RG_DATADEM") )

		//------------------------------------
		//| Validacoes diversas para Rescisao
		//| Realiza a validacao dos dados de Aviso Previo, Cert Óbito,
		//-----------------------------------------------------------
		lRet := fM40VLRES( 	AllTrim(oModelSRG:GetValue("RG_TPAVISO")),;	//Tipo Aviso
									cCdEFD,;													//Tipo Rescisao eSocial
									oModelSRG:GetValue("RG_DATADEM"),;				//Data de Demissao
									oModelSRG:GetValue("RG_OBITO"),;					//Certidao Obito
									"1",; 												  //Rescisao Simples
									Iif(lIndAv,oModelSRG:GetValue("RG_INDAV"),""),; //Indicador de cunprimento de aviso prévio
									@aErros,;
									.T.,;
									cVersGPE,;
									oModel:GetOperation(),;
									lNT15)

		If( !lRet )
			Help(/*1*/,/*2*/,OemToAnsi(STR0001),,aErros[1],1,0)//"Atenção"
			If cEFDAviso == "1"
				Return()
			EndIf
		EndIf

	//Verifica dados complementares do eSocial
	If lTrabVinc .OR.  lTrabSVinc
		If !lFVerESoc
			If lTrabSVinc
				//Validacao se TAF esta instalado
				aRet:= TafExisEsc('S2399')
			Else
				//Validacao se TAF esta instalado
				aRet:= TafExisEsc('S2299')
			EndIf

			If aRet[2] <= '2.2'
				Help(,,,OemToAnsi(STR0001),OemToAnsi(STR0224) + " " + OemToAnsi(STR0225)+" "+ OemToAnsi(STR0226),1,0) //##"Ambiente TAF desatualizado."##"Assim esta rotina não poderá ser utilizada."##"Entre em contato com o Administrador do Sistema."##"Atencao"
				lRet := .F.
				Return( lRet )
			Endif
		Endif

		//Fixa valor para .F. e aguarda verificação real
		lRet := .F.

		IF ( cStatus0 == "0" .OR. cStatus1 == "0")
			Help(,,OemToAnsi(STR0001),,OemToAnsi(STR0126),1,0)//"O registro de admissão está pendente de transmissão para o RET. Verifique no sistema TAF. A rescisão não será efetivada."
		ELSEIF ( cStatus0 == "2" .OR. cStatus1 == "2")
			If !lMiddleware
				Help(,,OemToAnsi(STR0228),,OemToAnsi(STR0187),1,0)//"Registro de Admissão do Funcionário está em trânsito TAF x RET. Verifique no sistema TAF. A rescisão não será efetivada."
			Else
				Help(,,OemToAnsi(STR0228),,OemToAnsi(STR0219),1,0)//"Registro de Admissão do Funcionário está em trânsito ao RET. Verifique no Middleware. A rescisão não será efetivada."
			EndIf
		ELSEIF (cStatus0 == "6" .OR. cStatus1 == "6")
			Help(,,OemToAnsi(STR0228),,OemToAnsi(STR0108),1,0)//"Registro de exclusão do Funcionário está em trânsito TAF x RET. Verifique no sistema TAF. A rescisão não será efetivada."
		ElseIf ((cStatus0 == '3') .OR. (cStatus1 == '3') .OR. (cStatus0 == ' ') .OR. (cStatus1 == ' ') .OR. (cStatus0 == '1') .OR. (cStatus1 == '1') )
			If !lMiddleware
				Help(,,OemToAnsi(STR0229),,OemToAnsi(STR0217),1,0)//"Registro de Admissão do Funcionário ainda não foi transmitido ao RET ou consta inconsistências. Verifique no sistema TAF. A rescisão não será efetivada."
			Else
				Help(,,OemToAnsi(STR0229),,OemToAnsi(STR0227),1,0)//"Registro de Admissão do Funcionário possui inconsistências. Verifique no Middleware. A rescisão não será efetivada."
			EndIf
		ElseIf( (cStatus0 == '-1') .AND. (cStatus1 == '-1') )
			If !lMiddleware
				Help(,,OemToAnsi(STR0001),,OemToAnsi(STR0218),1,0)//"O funcionário ainda não possui integração com o TAF. Realize a sua integração para poder gerar a rescisão. A rescisão não será efetivada.
			Else
				Help(,,OemToAnsi(STR0001),,OemToAnsi(STR0221),1,0)//"O funcionário ainda não possui integração com o Middleware. Realize a sua integração para poder gerar a rescisão. A rescisão não será efetivada."
			EndIf
		Else
			//Força a valida do Tipo de Alteração
			aTpAlt := {.F., .F., .F., .F., .F.}
			fStatusTAF(@aTpAlt,cStatus0,cStatus1,/*cFuncaoPai*/, /*aContainer*/)
		EndIf

		//Verifica se pode ou não gerar Rescisão
		If ( aTpAlt[3] )
			lRet := .T.
		EndIf

		//Verifica se há rescisão integrada com alteração na data de demissão
		IF !lMiddleware .And. cCompl == "N" .And. !Empty(SRG->RG_DATADEM) .And. SRG->RG_DATADEM <> M->RG_DATADEM .And. oModel:GetOperation() == 3
			//Pesquisa no TAF se tem rescisão calculada no período
			lTemResc := fPesCMD(cFilEnv, SRA->RA_CIC, SRA->RA_CODUNIC, SRG->RG_DATADEM)
			If lTemResc
				If cEFDAviso == "1"
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0242), 1, 0 )//Operação de recálculo não integrada ao TAF pois houve alteração na data de demissão, para este cenário é preciso excluir a rescisão e realizar novo cálculo"
					Return .F.
				Else
					MsgInfo( OemToAnsi(STR0242), OemToAnsi(STR0001))//Operação de recálculo não integrada ao TAF pois houve alteração na data de demissão, para este cenário é preciso excluir a rescisão e realizar novo cálculo
				EndIf
			EndIf
		EndIf

		If lRet .And. (!lRetif .Or. cFasEsoc == "1" .Or. (lRetif .And. cFasEsoc == "2" .And. AnoMes(oModelSRG:GetValue("RG_DATADEM")) >= MesAno( MonthSum(dDtcgini, IIF(AnoMes(dDtcgini) == "201803", 2, 3) ) ) ) )
			If !lTrabSVinc
				//Realiza por fim a geracao do evento S-2299
				lRet := fInt2299( oModel,; 	//Dados vindo da tela de rescisao (SRG e SRR)
										aErros,;							// Variável de erros para alimentacao
										"S2299",;							// Evento desejado - Desligamento
										cCdEFD,;							// Categoria de Rescisao do eSocial
										"1" ,;								// Tipo de Rescisao (1 = Simples / 2 = Coletiva)
										,;									// aPd
										oModelSRG:GetValue("RG_DATADEM"),;	// Data da rescisão
										,;									// Dias de aviso indenizado
										cVersEnvio,;						// Versão eSocial para envio
										,;
										lResComp,;							// Rescisão complementar
										lRetif,;							// Rescisão complementar por retificação
										Nil,;
										lNT15)
			Else
				//Realiza por fim a geracao do evento S-2299
				lRet := fInt2399New( oModel,; 	//Dados vindo da tela de rescisao (SRG e SRR)
										aErros,;							// Variavel de erros para alimentacao
										"S2399",;							// Evento desejado - Desligamento
										cCdEFD,;							// Categoria de Rescisao do eSocial
										"1" ,;								// Tipo de Rescisao (1 = Simples / 2 = Coletiva)
										,;									// aPd
										,;									// Data da rescisão
										,;									// Dias de aviso indenizado
										cVersEnvio,;
										,;
										lResComp,;							// Rescisão complementar
										lRetif)								// Rescisão complementar por retificação
			EndIf
			If( lRet )
				fEFDMsg()
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} fResCompl
Função responsável pela definição se a rescisão complementar será ou não enviada
@author Eduardo
@since 22/03/2018
@version 1.0
/*/
Function fResCompl(lGera, lOffline, nOperacao, lResComp, lRetif, lLote, cOpcCompl)

	Local aAreaSRG		:= SRG->( GetArea() )
	Local aCabSRG		:= {}
	Local lRet      	:= .F.
	Local lPLR			:= .F.
	Local lGer2299		:= .F.
	Local lPLRoutrPD	:= .F. // na rescisão complementar a verba de PLR está sendo paga junto com outras verbas
	Local lTemComp		:= .F.
	Local dDtCarga  	:= SuperGetMv("MV_DTCGINI",, StoD("//"))
	Local dDemiss   	:= IIF(lLote .Or. Empty(dDataDem1),SRG->RG_DATADEM,dDataDem1)
	Local dDtGer		:= Iif(lOffline .Or. nOperacao == 5, SRG->RG_DTGERAR, M->RG_DTGERAR )
	Local nCont			:= 0

	Default lGera		:= .T.
	Default lOffline	:= .F.
	Default nOperacao	:= 3
	Default lResComp	:= .F.
	Default lRetif		:= .F.
	Default lLote		:= .F.
	Default cOpcCompl	:= ""

	If cPaisLoc == "BRA" .And. (lOffline .Or. nOperacao == 5)
		cCompl 	  	:= Iif(SRG->RG_RESCDIS $ " /0", "N", "S")
		lProxMes  	:= AnoMes(SRG->RG_DATADEM) != AnoMes(SRG->RG_DTGERAR)
		lRescDis  	:= (SRG->RG_RESCDIS == "2")
		lRetif    	:= (SRG->RG_RESCDIS == "3")
		aPdResc		:= {}
		aSrgRecnos	:= {}
		If SRG->( dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
			While SRG->( !Eof() .And. SRG->RG_FILIAL+SRG->RG_MAT == SRA->RA_FILIAL+SRA->RA_MAT )
				nRegSrg := SRG->( Recno() )
				nPos	:= aScan( aSrgRecnos, { |x| MesAno( x[2] ) == MesAno( SRG->RG_DTGERAR ) } )
				If MesAno( SRG->RG_DTGERAR ) == MesAno( SRG->RG_DATADEM ) .and. nPos > 0.00
					aSrgRecnos[ nPos , 01 ] := nRegSrg
					aSrgRecnos[ nPos , 02 ] := SRG->RG_DTGERAR
					aSrgRecnos[ nPos , 03 ] := SRG->RG_DATADEM
				Else
					aAdd( aSrgRecnos, { nRegSrg, SRG->RG_DTGERAR, SRG->RG_DATADEM } )
				EndIf
				SRG->( dbSkip() )
			EndDo
		EndIf
	EndIf

	If cCompl == "S"
		lResComp := .T.
		If !lOffline .And. nOperacao != 5
			lRetif	 := (cOpcCompl == "3")
		EndIf
	EndIf

	If dDemiss >= dDtCarga
		//Se não for retificação, o mês diferente, não for Res. complementar e for integração offline
		IF !lRetif .AND. lOffline .AND. lProxMes .AND. cCompl == "N"
			lRet := .T.
		ElseIf !lRetif .And. (lProxMes .Or. cCompl == "S")
			For nCont := 2 To Len(aSrgRecnos)
				If AnoMes(aSrgRecnos[nCont, 2]) > AnoMes(aSrgRecnos[nCont, 3]) .And. aSrgRecnos[nCont, 2] != dDtGer
					SRG->( dbGoTo(aSrgRecnos[nCont, 1]) )
					aAdd( aCabSRG, { SRG->RG_DTGERAR, SRG->RG_RESCDIS } )
					lTemComp	:= .T.
				EndIf
			Next nCont
			If !lTemComp
				//Verifica se é complementar com pagamento de PLR, e se existem outras verbas sendo pagas.
				If !lRescDis
					lPLRoutrPD := fBuscaPLR(@lPLR)
				EndIf

				//Se for complementar para pagamento de PLR não gera o evento S-2299/S-2399.
				If lPLR
					lRet := .F.
					//Se for complementar com pagamento de PLR e outras verbas, pergunta se irá gerar o evento S-2299/S-2399.
					If lPLRoutrPd
						If !IsBlind() .And. !lLote
							lGera := MsgYesNo( OemToAnsi( STR0230 ) + CRLF + OemToAnsi( STR0231 ) , OemToAnsi( STR0232) ) //Integração com o TAF. Será gerado um evento S-2299 retificador com todas as verbas incluídas, porém, alertamos que, de acordo com as regras do eSocial, seria necessário gerar uma rescisão complementar para o PLR e outra Rescisão complementar para as demais verbas, confirma a geração?
							lRet := lGera
						Else
							lRet := .T.
						Endif
					Endif
				//Se não for complementar com PLR e for em período seguinte não gera o evento S-2299/S-2399.
				ElseIf lProxMes
					lRet := .F.

				// Se for rescisão complementar no mesmo período da rescisão original deve gerar o evento S-2299/S-2399
				Else
					lRet := lGera := .T.
				Endif
			Else
				lGer2299 := (aCabSRG[Len(aCabSRG), 2] == "3")//Retificar
				If !lGer2299
					lRet := .F.
				Else
					lRet := lGera := .T.
				EndIf
			EndIf
		Else
			//Se não for complementar ou for complementar de retificação, gera o evento S-2299/S-2399
			lRet := .T.
		EndIf
	EndIf

	RestArea( aAreaSRG )

Return lRet

/*/{Protheus.doc} fBuscaPLR
Verifica se a verba de PLR foi lançada na rescisão complementar
e se existe outra verba além dela na Rescisão.
@author claudinei.soares
@since 14/05/2018
/*/
Static Function fBuscaPLR(lPLR)
Local oModel	:= FWModelActive()
Local oGrid		:= oModel:GetModel("GPEM040_MGET")
Local nG		:= 0
Local lPLRePD	:= .F.
Local lRet		:= .F.
Local lRvCpoPlr		:= SRV->(Columnpos("RV_REFPLR") > 0)
Local nValor	:= 0

Default lPLR	:= .F.

For nG := 1 To oGrid:Length()
	oGrid:GoLine(nG)
	cVerba := oGrid:GetValue("RR_PD")
	cNumId := oGrid:GetValue("RR_NUMID")
	nValor := oGrid:GetValue("RR_VALOR")
	//Verifica se possui a verba de PLR lançada na Rescisão
	If (cVerba $ ( aCodFol[151,1] + "/" + aCodFol[152,1] + "/" + aCodFol[835,1] + "/" + aCodFol[836,1] + "/" + aCodFol[300,1] + "/" + aCodFol[1328,1] ) .Or. RetValSrv( cVerba, SRA->RA_FILIAL, 'RV_INCIRF', 1 ) == "54") .And. nValor > 0
		lPLR := .T.
	ElseIf !Empty(cVerba) .And. !(cVerba $ aCodFol[318,1] + "/" + aCodFol[126,1] + "/" + aCodFol[303,1] + "/" + aCodFol[120,1] + "/" + aCodFol[297,1]) .And. Empty(cNumId) .and. (!lRvCpoPlr .Or. (lRvCpoPlr .And. !(RetValSRV(cVerba, SRA->RA_FILIAL, 'RV_REFPLR') == "S"))) .And. nValor > 0
		lPLRePD := .T.
	EndIf
Next nG

//Possui a verba de PLR e alguma outra no mesmo cálculo
lRet := lPLR .And. lPLRePD

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fValEfdM040ºAutor  ³ Emerson Campos    º Data ³  20/09/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para validar todos os campos do eSocial			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cObs Campo observação da aba eSocial			  			  º±±
±±º          ³ cAtOb Campo Atestado de obito da aba eSocial			      º±±
±±º          ³ cTpRes Campo Tipo de rescisao da aba eSocial			      º±±
±±º          ³ cNrProc Campo nro do processo trabalhista da aba eSocial	  º±±
±±º          ³ cCnpj Campo CNPJ da sucessora da aba eSocial			  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM040 			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fValEfdM040(cObs, cAtOb, cTpRes, cNrProc, cNroCnpj, cTpSuc, cMsg)
Local lRet		:= .T.

Default cMsg	:= ""

	/*
	 * Descricao:
	 * 	Numero que identifica o registro do atestado de obito.
	 * 	Campo preenchido no caso de desligamento por morte.
	 * Validacao:
	 * 	Deve ser preenchido se o motivo de desligamento for igual a [09|10]
	 * 	Motivo de dsligamento e o item X32_MOTDES da tabela X32 que e
	 *  selecionado atravês do campo de tela cTipRes
	 */
	If lRet
		lRet := fObtVldM040(AllTrim(cAtOb), cTpRes)
	EndIf

	/*
	 * Descricao:
	 *  Preencher com o CNPJ/CPF da empresa sucessora.
	 * Validacao:
	 *  Deve ser um CNPJ/CPF valido, com raiz diferente do CNPJ do declarante.
	 */
	If lRet
		lRet := fVldInsM040(AllTrim(cNroCnpj), cTpRes, cTpSuc, @cMsg)
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fObtVldM040ºAutor ³ Emerson Campos     º Data ³  20/09/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para validar o ca				  					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM040 			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fObtVldM040(cAtObito, cTipR)

Local lRet		:= .T.
Local nPos		:= 0
Local cMotEF	:= ""
Local cEFDAviso := If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas

	If cEFDAviso <> "2"
		nPos := fPosTab("S043", cTipR , "=", 4 )
		If nPos > 0
			 cMotEF := FTabela("S043", nPos, 26)
		EndIf
		If !Empty(AllTrim(cAtObito)) .And. !(cMotEF $ ("A"))
			// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
			// "Atencao" ### "O campo 'Atestado de obito' so devera ser preenchido se o motivo de desligamento for igual a 10. Selecione um tipo de rescisao que o motivo seja diferente de desligamento devido a morte."
			If cEFDAviso == "1"
				Help( , ,OemToAnsi(STR0001), , OemToAnsi(STR0233), 1, 0 )//"O campo 'Atestado de Óbito' só deverá ser preenchido se o motivo de desligamento for igual a A. Selecione um tipo de rescisão que o motivo seja diferente de desligamento devido a morte."
				lRet	:= .F.
			ElseIf cEFDAviso == "0"
				Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0233)+ CRLF + OemToAnsi(STR0234),,1,0 )//"O campo 'Atestado de Óbito' só deverá ser preenchido se o motivo de desligamento for igual a A. Selecione um tipo de rescisão que o motivo seja diferente de desligamento devido a morte."##
			EndIf
		EndIf

	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fVldInsM040 ºAutor ³ Emerson Campos    º Data ³  26/09/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para limitar em 255 caractreres no campo memo		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM040 			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fVldInsM040(cCnpj, cTipR, cTpSuc, cMsg)
Local 	aArea		:= GetArea()
Local 	aAreaSM0	:= SM0->( GetArea() )
Local 	cMotEF		:= ""
Local 	lRet		:= .T.
Local	nPos		:= 0
Local 	lTpSuces	:= SRG->(ColumnPos("RG_TPSU")) > 0
Local	cVersEnvio	:= ""
Local   cEFDAviso 	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas

Default cMsg 	:= ""

	fVersEsoc("S2299", .F.,,,@cVersEnvio)
	If !lMiddleware .And. Right(cVersEnvio,1) == "."
		cMsg :=  OemToAnsi(STR0253) //"Revise o preenchimento do parâmetro MV_TAFVLES certificando que ele esteja conforme o padrão. Ex: 02_05_00."
		lRet := .F.
	EndIf

	nPos := fPosTab("S043", cTipR , "=", 4 )
	If nPos > 0
		 cMotEF := FTabela("S043", nPos, 26)
	EndIf

	//Valida se foi preenchido o novo campo RG_TPSU
	If cVersEnvio >= '2.5.00' .And. lTpSuces
		//Valida se o tipo de desligamento for B ou C e não preencheu o tipo de inscrição
		If (cMotEF $ ("B|C|T")) .And. Empty(cTpSuc)
			If cEFDAviso == "1"
				cMsg :=  OemToAnsi(STR0235) //"O campo 'Tp.Inscrição' é de preenchimento obrigatório se o motivo de desligamento for igual a B, C ou T."
				lRet := .F.
			Endif
		Endif

		//Valida se o tipo de desligamento NÃO for B ou C e preencheu o tipo de inscrição
		If !Empty(cCnpj) .And. !(cMotEF $ ("B|C|T"))
			If cEFDAviso == "1"
				cMsg :=  OemToAnsi(STR0236) //"O campo 'Tp.Inscrição' só deverá ser preenchido se o tipo de rescisão for relacionado a Transferência de empregado para outra empresa do mesmo grupo ou por sucessão ou por redistribuição, opções B, C ou T de motivos de desligamentos."
				lRet := .F.
			Endif
		Endif
	Endif

	// Obtem o CGC da Empresa de Origem
	If lRet .And. !Empty(cCnpj) .And. (cMotEF $ ("B|C|T"))
		//Caso se o campo Motido de Afastamento - S056 for igual a 11, 12 ou 29 nao pode ser vazio, tem que ser um número de inscrição válido.
		If ( lRet := SM0->( dbSeek( cEmpAnt + SRA->RA_FILIAL ) ) )
			If cEFDAviso <> "2"
				If SM0->M0_CGC == cCnpj
					//"O número de inscrição informado deve ser diferente do número de inscrição da filial de cadastro do participante."
					// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
					If cEFDAviso == "1"
						Help( , , 'HELP', , OemToAnsi(STR0237), 1, 0 ) //"O número de inscrição informado deve ser diferente do número de inscrição da filial de cadastro do participante."
						cMsg :=  OemToAnsi(STR0237)//"O número de inscrição informado deve ser diferente do número de inscrição da filial de cadastro do participante."
						lRet	:= .F.
					ElseIf cEFDAviso == "0"
						Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0237)+ CRLF + OemToAnsi(STR0234),,1,0 )//"O número de inscrição informado deve ser diferente do número de inscrição da filial de cadastro do participante."##"Entretanto não será impeditivo para gravação conforme configuração do parâmetro MV_EFDAVIS."
					EndIf
				EndIf
				If lRet .And. cCnpj == "00000000000000"
					 //"O número de Inscrição informado não é válido!"
					// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
					If cEFDAviso == "1"
						Help( , , 'HELP', , OemToAnsi(STR0238), 1, 0 )//"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "
						If Empty(cMsg)
							cMsg :=  OemToAnsi(STR0238)//"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "
						Else
							cMsg += CRLF + OemToAnsi(STR0238)//"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "
						Endif
						lRet	:= .F.
					ElseIf cEFDAviso == "0"
						Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0238)+ CRLF + OemToAnsi(STR0234),,1,0 )//"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##"Entretanto não será impeditivo para gravação conforme configuração do parâmetro MV_EFDAVIS."
					EndIf
				EndIf
				If lRet
					// Valida se o número de inscrição é válido
					lRet :=  If( (cTpSuc == "2" .And. cVersEnvio >= '2.5.00' ), ChkCPF( Alltrim(cCnpj) ) , CGC( Alltrim(cCnpj) ) )
					If cEFDAviso == "0" .And. !lRet
						lRet	:= .T.
					ElseIf cEFDAviso == "1" .And. !lRet
						cMsg += CRLF + OemToAnsi(STR0239) //"O número de inscrição da empresa sucessora informado é inválido"
					EndIf
				EndIf
			EndIf
		EndIF
	EndIf

	If lRet .And. cEFDAviso <> "2"
		If  !Empty(cCnpj) .And. !(cMotEF $ ("B|C|T"))
			//"O campo 'Insc.Emp.Suc' só deverá ser preenchido se o tipo de rescisão for relacionado a Transferência de empregado para outra empresa do mesmo grupo ou por sucessão. Opções 11 ou 12 de motivos de desligamentos."
			// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
			If cEFDAviso == "1"
				Help( , , 'HELP', , OemToAnsi(STR0240), 1, 0 )//"O campo 'Insc.Emp.Suc' só deverá ser preenchido se o tipo de rescisão for relacionado a Transferência de empregado para outra empresa do mesmo grupo ou por sucessão ou por Redistribuição. Opções 11, 12 ou 29 de motivos de desligamentos."
				lRet	:= .F.
				If Empty(cMsg)
					cMsg :=  OemToAnsi(STR0240)//"O campo 'Insc.Emp.Suc' só deverá ser preenchido se o tipo de rescisão for relacionado a Transferência de empregado para outra empresa do mesmo grupo ou por sucessão ou por Redistribuição. Opções 11, 12 ou 29 de motivos de desligamentos."
				Else
					cMsg += CRLF + OemToAnsi(STR0240)//"O campo 'Insc.Emp.Suc' só deverá ser preenchido se o tipo de rescisão for relacionado a Transferência de empregado para outra empresa do mesmo grupo ou por sucessão ou por Redistribuição. Opções 11, 12 ou 29 de motivos de desligamentos."
				Endif
			ElseIf cEFDAviso == "0"
				Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0240)+ CRLF + OemToAnsi(STR0234),,1,0 )
				//"O campo 'Insc.Emp.Suc' só deverá ser preenchido se o tipo de rescisão for relacionado a Transferência de empregado para outra empresa do mesmo grupo ou por sucessão ou por Redistribuição. Opções 11, 12 ou 29 de motivos de desligamentos."//"Entretanto não será impeditivo para gravação conforme configuração do parâmetro MV_EFDAVIS."
			EndIf
		EndIf

		If  lRet .And. Empty(cCnpj) .And. (cMotEF $ ("B|C|T"))
			//"O campo 'Insc.Emp.Suc' é um campo obrigatório se o motivo de desligamento for igual a B ou C. Informe uma número de Inscrição válido e diferente do número de inscrição do declarante."
			// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
			If cEFDAviso == "1"
				Help( , , 'HELP', , OemToAnsi(STR0241), 1, 0 )//"O campo 'Insc.Emp.Suc' é um campo obrigatório se o motivo de desligamento for igual a B, C ou T. Informe uma número de Inscrição válido e diferente do número de inscrição do declarante."
				lRet	:= .F.
				If Empty(cMsg)
					cMsg :=  OemToAnsi(STR0241)//"O campo 'Insc.Emp.Suc' é um campo obrigatório se o motivo de desligamento for igual a B, C ou T. Informe uma número de Inscrição válido e diferente do número de inscrição do declarante."
				Else
					cMsg += CRLF + OemToAnsi(STR0241)//"O campo 'Insc.Emp.Suc' é um campo obrigatório se o motivo de desligamento for igual a B, C ou T. Informe uma número de Inscrição válido e diferente do número de inscrição do declarante."
				Endif
			ElseIf cEFDAviso == "0"
				Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0241)+ CRLF + OemToAnsi(STR0234),,1,0 )//"O campo 'Insc.Emp.Suc' é um campo obrigatório se o motivo de desligamento for igual a B, C ou T. Informe uma número de Inscrição válido e diferente do número de inscrição do declarante."##"Entretanto não será impeditivo para gravação conforme configuração do parâmetro MV_EFDAVIS."
			EndIf
		EndIf
	EndIf

	// Restaura os Dados de Entrada
	RestArea( aAreaSM0 )
	RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fM40TPRES   ºAutor  ³Rh Manutenção      º Data ³  31/05/17  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Baseado no tipo de rescisao informado, realiza um de/para naº±±
±±º          ³ tabela do eSocial e retorna a opcao selecionada            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Rescisao Simples e Rescisao Coletiva                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fM40TPRES( cCodTpRes, cTpAvs, laIncRes, dDtDemissa)
Local cTab56	:= "S056"
Local cTpEFD	:= ""
Local cCdEFD	:= ""
Local aAreaRCC	:= GetArea()
Local dDtValid	:= CTOD("//")
Local nPos		:= 0
Local nPos1 	:= 0
Local cDtValid  := ""
Local lRet 		:= .F.

Default cTpAvs 		:= ""
Default laIncRes	:= .F.
Default dDtDemissa  := CTOD("//")

If Empty(dDtDemissa) .And. type("dDataRes") == "D" .And. !Empty(dDataRes)
   dDtDemissa := dDataRes
Endif

If Empty(aIncRes) .Or. laIncRes
	fIncRes(SRA->RA_FILIAL, cCodTpRes, @aIncRes)
EndIf
If Len(aIncRes) > 1
	cTpEFD	:= aIncRes[16]
	cTpAvs	:= aIncRes[02]
EndIf

//Valida se a data de validade ja foi criada
dbSelectArea( "RCC" )
dbSetOrder(1)
dbSeek(xFilial("RCC",SRA->RA_FILIAL) + cTab56)
While !Eof() .and. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC",SRA->RA_FILIAL)+cTab56
	If RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC",SRA->RA_FILIAL)+cTab56
		cDtValid := Substr(RCC->RCC_CONTEU,202,8)
		If !Empty(cDtValid)
			lRet := .T.
		Endif
	EndIf
	RCC->(dBSkip())
EndDo

If !Empty(dDtDemissa) .And. lRet
	//Verifica se a data de demissao é menor/igual a data de validade
	nPos:= FPOSTAB("S056",cTpEFD,"=", 4 , dDtDemissa, "<= ", 6  )
	If nPos > 0
		cCdEFD := FTABELA("S056",nPos,5)
		cCdEFD := Alltrim(Substr(cCdEFD,1,2))
	Else
		//Busca o motivo de desligamento  sem data de validade
		nPos1:= FPOSTAB("S056",cTpEFD,"=", 4 , dDtValid, "= ", 6  )
		If nPos1 > 0
			cCdEFD := FTABELA("S056",nPos1,5)
			cCdEFD := Alltrim(Substr(cCdEFD,1,2))
		Endif
	Endif
Else
	nPos1:= FPOSTAB("S056",cTpEFD,"=", 4 )
	If nPos1 > 0
		cCdEFD := FTABELA("S056",nPos1,5)
		cCdEFD := Alltrim(Substr(cCdEFD,1,2))
	Endif
Endif

RestArea(aAreaRCC)
Return cCdEFD

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fM40VLRES   ºAutor  ³Rh Manutenção      º Data ³  31/05/17  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a validacoes dos dados enviados para rescisao do    º±±
±±º          ³ funcionario corrente                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Realiza a validacao dos registros setados em memoria       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam     ³ cTpAviso   : Tipo de Aviso do funcionário                  º±±
±±º          ³ cCdEFD     : Tipo Rescisao do eSocial                      º±±
±±º          ³ dDtDemissa : Data de demissao do desligamento              º±±
±±º          ³ cCodObito  : Numero de certidao de obito do funcionario    º±±
±±º          ³ cTpRes     : 1 = Rescisao Simples / 2 = Rescisao Coletiva  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fM40VLRES( cTpAviso, cCdEFD, dDtDemissa, cCodObito, cTpRes, cIndAv, aErroRes, lAviso, cVersEnvio, nOper, lNT15)
Local lRet			:= .T.
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
Local lNewMotDes	:= If(dDtDemissa >= Ctod("19/07/2021"),.T.,.F.)

Default cTpRes		:= "1"
Default aErroRes	:= {}
Default lAviso		:= .T.
Default cVersEnvio	:= "2.2"
Default nOper		:= 3
Default lNT15		:= .F.

If cPaisLoc == "BRA" .And. nOper != 5
	//Se o tipo de aviso for trabalhado ou termino de contrato
	If ( ( AllTrim( cTpAviso ) $ "T*B" .AND. ( cCdEFD $ '03*04*06' ) ) .AND. ( dDtDemissa + 1 < dDataBase ) .And. SRA->RA_CATEFD $ cTrabVincu )
		If lAviso
			Aviso(OemToAnsi(STR0001), OemToAnsi(STR0041)) //##"Atencao."##"O prazo de envio deste evento foi ultrapassado. Passível de multa"
		Else
			aAdd(aErroRes,  OemToAnsi(STR0041) )
		EndIf
	ElseIf ( dDtDemissa + 10 < dDataBase ) .And. (SRA->RA_CATEFD $ cTrabVincu .Or. cVersEnvio >= "9.0")
		If lAviso
			Aviso(OemToAnsi(STR0001), OemToAnsi(STR0041)) //##"Atencao."##"O prazo de envio deste evento foi ultrapassado. Passível de multa"
		Else
			aAdd(aErroRes,  OemToAnsi(STR0041) )
		EndIf
	EndIf

	If Empty(cCdEFD) .AND. (SRA->RA_CATEFD $ cTrabVincu .Or. SRA->RA_CATEFD == "721")
		aAdd(aErroRes,  OemToAnsi(STR0248) )	//##"Atencao."##"Verifique o preenchimento ou a data de vigencia do Motivo de desligamento do eSocial. Informação obrigatória "
		lRet := .F.
	Endif

	If !lNewMotDes
		//Validação para o tipo de Rescisão e Categoria eSocial do Funcionário
		If ( ( cCdEFD $ "18*19*20*21*22*23*24*25" ) .AND. ( SRA->RA_CATEFD < "301" .OR. SRA->RA_CATEFD > "309" ) )
			lRet := .F.
			aAdd(aErroRes,  OemToAnsi(STR0249) )	//"Motivos de desligamento válidos apenas para Agentes Públicos."
		EndIf
	Else
		If cCdEFD $ "21*22*32" .And.  SRA->RA_CATEFD <> "307"
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento não é valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD $ "23*24" .And.  !(SRA->RA_CATEFD  $ "301*302*303*306*307*309*310*312")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento não é valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "25" .And.  !(SRA->RA_CATEFD  $ "301*307")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento não é valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "29" .And. !(SRA->RA_CATEFD  $ "301*303*306*307*309")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento não é valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "37" .And. !(SRA->RA_CATEFD  $ "301*306*307*309")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento não é valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "38" .And. !(SRA->RA_CATEFD  $ "101*301*302*312")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento não é valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "39" .And. !(SRA->RA_CATEFD  $ "301*306*309")
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento não é valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD == "40" .And. SRA->RA_CATEFD  <> "303"
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento não é valido para essa categoria do eSocial"
			lRet := .F.
		Endif

		If cCdEFD $ "41*42" .And. SRA->RA_CATEFD  <> "103"
			aAdd(aErroRes,  OemToAnsi(STR0250) )	//"O motivo de desligamento não é valido para essa categoria do eSocial"
			lRet := .F.
		Endif
	Endif

	//Se o tipo de aviso for trabalhado ou termino de contrato
	If lIndAv
		If !lNT15 .And. ( ( ( cCdEFD $ "02*03*04*07" ) .And. Empty(cIndAv) .And. SRA->RA_CATEFD $ cTrabVincu  ) .Or. ( Empty(cIndAv) .And. cVersEnvio > "2.3" .And. SRA->RA_CATEFD $ cTrabVincu ) )
			lRet := .F.
			aAdd(aErroRes,  If(cVersEnvio > "2.3", OemToAnsi(STR0252) ,OemToAnsi(STR0196)) )	//"Quando o tipo de rescisão for 02, 03, 04 ou 07, é obrigatório o preenchimento do campo 'Ind.Cum.Av.P'."
		EndIf
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} fPesCMD
Função responsável por pesquisar se há um registro na tabela CMD em determinada data.
@author lidio.oliveira
@since 29/05/2020
@version 1.0
/*/
Static Function fPesCMD(cFilEnv, cCPF, cCodUnic, dDtDem)

Local aArea 	:= GetArea()
Local lRet		:= .F.
Local cIdFunc	:= ""

Default cStatus 	:= "-1"
Default cCPF		:= ""
Default cCodUnic	:= ""
Default dDtDem 		:= CTOD("//")

	//A pesquisa será realizada apenas se os parâmetros foram informados
	If !Empty(dDtDem) .And. !Empty(cCPF) .And. !Empty(cCodUnic) .And. !Empty(dDtDem)

		//Encontra o Id do funcionário na tabela C9V
		DBSelectArea("C9V")
		C9V->(DBSetOrder(10)) //C9V_FILIAL + C9V_CPF + C9V_MATRIC + C9V_NOMEVE + C9V_ATIVO
		If C9V->(DBSEEK(cFilEnv + cCPF + cCodUnic + "S2200"))
			cIdFunc := C9V->C9V_ID
		EndIf

		//Pesquisa na CMD se há registro de demissão na data solicitada
		If !Empty(cIdFunc)
			dDtDem := DTOS(dDtDem)
			DBSelectArea("CMD")
			CMD->(DBSetOrder(2)) //CMD_FILIAL + CMD_FUNC + DTOS(CMD_DTDESL) + CMD_ATIVO
			If CMD->(DBSEEK(cFilEnv + cIdFunc + dDtDem))
				lRet := .T.
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} fBuscaDiss
Verifica se existem verbas de dissidio
@author staguti
@since 03/12/2020
/*/
Static Function fBuscaDiss(aVbDiss, cTpRes, aPd)
Local aArea		:= GetArea()
Local oModelDis	AS Object
Local oGridDis	:= Nil
Local nG		:= 0
Local lDissPD	:= .F.
Local lRet		:= .T.
Local cFilDis	:= ""
Local cMatDis	:= ""
Local cVerba	:= ""
Local cNumId	:= ""
Local aVbDiss	:= {}

Default cTpRes	:= ""
Default aPd		:= {}

If cTpRes == "1"
 	oModelDis	:= FWModelActive()
 	oGridDis	:= oModelDis:GetModel("GPEM040_MGET")

	For nG := 1 To oGridDis:Length()
		oGridDis:GoLine(nG)
		cFilDis := oGridDis:GetValue("RR_FILIAL")
		cMatDis := oGridDis:GetValue("RR_MAT")
		cVerba 	:= oGridDis:GetValue("RR_PD")
		cNumId 	:= oGridDis:GetValue("RR_NUMID")

 		If oGridDis:GetValue("RR_TIPO3") == "R" .And. (Empty(cNumId) .Or. (" - " $ cNumId))
			//Caso o Número de Id esteja em branco e a verba tenha origem G pesquisa na tabela SRK para validar se trata-se de dissídio.
			If oGridDis:GetValue("RR_TIPO2") == "G"
				cNumId := fNumId(cFilDis + cMatDis + cVerba)
				If !Empty(cNumId)
					aAdd( aVbDiss, { cVerba, cNumId } )
				Else
					lGeraVbDis	:= .T.
				EndIf
			Else
				lGeraVbDis	:= .T.
			EndIf
		EndIf
		If !Empty(oGridDis:GetValue("RR_NUMID")) .And. !(" - " $ cNumId) .And. !("RG1" $ cNumId)
			aAdd( aVbDiss, { cVerba, oGridDis:GetValue("RR_NUMID") } )
		EndIf
	Next nG
Else

	For nG := 1 To Len(aPd)
		cFilDis := xFilial("SRR")
		cMatDis := SRR->RR_MAT
		cVerba := aPd[nG, 1]
		cNumId := aPd[nG, 15]

		If Empty(cNumId)
			//Caso o Número de Id esteja em branco e a verba tenha origem G pesquisa na tabela SRK para validar se trata-se de dissídio.
			If aPd[nG, 7] == "G"
				cNumId := fNumId(cFilDis + cMatDis + cVerba)
				If !Empty(cNumId)
					aAdd( aVbDiss, { cVerba, cNumId } )
				Else
					lGeraVbDis	:= .T.
				EndIf
			Else
				lGeraVbDis	:= .T.
			EndIf
		EndIf
		If !Empty(cNumId) .And. !(" - " $ cNumId) .And. !("RG1" $ cNumId)
			aAdd( aVbDiss, { cVerba, cNumId} )
		EndIf
	Next nG

Endif

RestArea(aArea)

Return lRet


/*/{Protheus.doc} fNumId()
Função que busca NumID na SRK
@type function
@author staguti
@since 04/12/2020
@version 1.0
@param cChave		= Filial + Matrícula + Verba
@param cDataMin		= Data de mínima de pesquisa
@return cNumId		= Retorna NumID
/*/
Static Function fNumId( cChave)

Local cNumId	:= ""
Local aArea		:= GetArea()

DEFAULT cChave		:= ""

dbSelectArea( "SRK" )
SRK->(dbSetOrder(1))
If SRK->( Dbseek( cChave ) )
	If !Empty(SRK->RK_NUMID) .And. !Empty(SRK->RK_MESDISS) .And. SRK->RK_STATUS <> "3"
		cNumId := SRK->RK_NUMID
	EndIf
EndIf

RestArea(aArea)

Return cNumId


/*/{Protheus.doc} fDiasConv()
Função que retorna os dias de convocação no mes da rescisao
@type function
@author staguti
@since 26/04/2021
@version 1.0
@param dDataDe		= Data Inicial do Periodo
@param dDataMin		= Data Final do Periodo/Data Rescisão
@return aDiasConv	= Retorna array com todos os dias de convocação
/*/

Function fDiasConv(dDataDe, dDataAte)

Local aConvoc 		:= {}
Local nDiaConv 		:= 0
Local aDiasConv 	:= {}
Local nC			:= 0
Local nInt 			:= 0
Default dDataDe 	:= Ctod("")
Default dDataAte 	:= Ctod("")

	aConvoc := BuscaConv(dDataDe, dDataAte)

	If Len(aConvoc) > 0
		For nC := 1 to Len(aConvoc)
			nDiaConv := Day(aConvoc[nC,2])
			aAdd( aDiasConv, StrZero(nDiaConv,2) )
			If aConvoc[nC,5] > 0
				For nInt:= 1 to aConvoc[nC,5]
					If nDiaConv+1 <= Day(aConvoc[nC,3])
						nDiaConv := nDiaConv+1
						aAdd( aDiasConv, StrZero(nDiaConv,2) )
					Endif
				Next nInt
			Endif
		Next nC
	Endif

Return aDiasConv

/*/{Protheus.doc} fGetDtHomol
Função responsável por retornar a data de pagamento da rescisão original
@author lidio.oliveira
@since 15/01/2021
@version 1.0
/*/
Static Function fGetDtHomol(cFilSRG, cMatSRG, dDtHomol)

Local aAreaSRG	:= SRG->(GetArea())

Default cFilSRG := ""
Default cMatSRG	:= ""
Default dDtHomol:= CTOD("//")

	//A pesquisa será realizada apenas se os parâmetros foram informados
	If !Empty(cFilSRG) .And. !Empty(cMatSRG)

		//Retorna data da rescisão original
		DBSelectArea("SRG")
		SRG->(DBSetOrder(1))
		If SRG->(DBSEEK(cFilSRG + cMatSRG))
			dDtHomol := SRG->RG_DATAHOM
		EndIf

	EndIf

	RestArea(aAreaSRG)

Return
