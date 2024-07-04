#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM026.CH"

Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM026D
@Author   Christiane Vieira
@Since    13/11/2015
@Version  1.0
@Obs      Migrado do GPEM026A em 29/04/2020 para gerar os eventos S-2300 e S-2306
/*/
Function GPEM026D()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  fInt2300NewºAutor  ³Marcos Coutinho Araujoº Data ³  09/05/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Registro Admissao Trab sem Vinculo                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM026-                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fInt2300New(cAliasSRA, lAltCad, nOpca, cReg, cTFilial, aDadosXml, cVersEnvio, lCadEst, oMdlRFS, aErros, aFilial, oMdlRFZ, cFilDe, lNovoCpf, lMostraHlp, cEmpP, cGeraMat, cCodUn, cNovoCodUn)

Local aArea			:= GetArea()
Local aAreaRBW		:= RBW->(GetArea())
Local cTpAmb		:= "1"
Local cFilEnv		:= ""
Local aErros 		:= {}
Local cEstCivi		:= GpeEstCivi("2")
Local aEstCivi		:= GpeEstCivi("1")
Local nPosEC 		:= 0
Local aRacaCor		:= {{'2','1'},{'4','2'},{'8','3'},{'6','4'},{'1','5'},{'9','6'}}
Local nRacaCor 		:= 0
Local aInstrucao	:= {{'10','01'},{'20','02'},{'25','03'},{'30','04'},{'35','05'},{'40','06'},{'45','07'},;
						{'50','08'},{'55','09'},{'65','11'},{'75','12'},{'85','10'},{'95','12'}}
Local nPosInstr		:= 0
Local aTpRegTrab	:= {{'30'},{'31'}, {'35'}}
Local nTpRegTrab	:= 0
Local aPagoFixo		:= GpeUndSalFixo ()
Local nPagoFixo		:= 0
Local aCatCNH		:= {{'1','A'},{'2','B'},{'3','C'},{'4','D'},{'5','E'},{'6','AB'},{'7','AC'},{'8','AD'},{'9','AE'}}
Local nPosCCNH		:= 0
Local aCargo		:= {}
Local nPosSQ3CC		:= 0
Local nPosSQ3sCC	:= 0
Local aDependent	:= {}
Local aVinculoT		:= {}
Local aEstagio		:= {}
Local aInstit		:= {}
Local aCoord		:= {}
Local aAgente		:= {}
Local aAso			:= {}
Local nI			:= 0
Local aSind			:= {}
Local aCC			:= {}
Local nPosLot		:= 0
Local nPosSind		:= 0
Local nTotVinc		:= 0
Local lDataDBF		:= .F.
Local dOpcao
Local dAdmissao
Local nPosEstb		:= 0
Local aEstb			:= {}
Local aRet			:= {}
Local aFilInTaf 	:= {}
Local aArrayFil 	:= {}
Local aAfastam 		:= {}
Local nPosAfast		:= 0
Local lMemo			:= .F.
Local aTurno		:= {}
Local nPosTurno		:= 0
Local cTpInscr		:= ""
Local cInscr		:= ""
Local cNomTrab		:= ""
Local cNomAux		:= ""
Local cXml			:= ""
Local cObsDef		:= ""
Local cObsVinc		:= ""
Local cFonePrinc	:= ""
Local cFoneAltern	:= ""
Local cMotSubs		:= ""
Local cCPFSubs		:= ""
Local cMatrSubs		:= ""
Local cCCSubs		:= ""
Local cTpJorn		:= ""
Local lFilFuncao 	:= .T.
Local lFilCargo		:= .T.
Local dDataRefP 	:= CTOD("")
Local cDia 			:= ""
Local cSalario		:= ""
Local cIntegra		:= ""
Local aAreaRFS		:= RFS->(GetArea())
Local aAreaRA0		:= RA0->(GetArea())
Local aAreaQuery	:= ""
Local cCatEFD		:= ""
Local cOrigem		:= ""
Local lGravou 		:= .T.
Local cFilTrab		:= If(Empty((cAliasSRA)->RA_FILIAL) , cFilAnt, (cAliasSRA)->RA_FILIAL )
Local lPriHab		:= SRA->(ColumnPos("RA_DTINCON")) > 0
Local lDesRem		:= SRA->(ColumnPos("RA_DESEPS")) > 0
Local lTAGFGTS		:= .F.
Local lGravaOpc		:= .T.
Local cTurno		:= ""
Local lTpJorn		:= .T.
Local lCBOCargo		:= .F.
Local lCBOFuncao	:= .F.
Local lEstag		:= .F.
Local cMsgEstag1	:= ""
Local cMsgEstag2	:= ""
Local cDescJorn		:= ""
Local cCatAux		:= "201|202|305|721|722|731|734|738|761|"
Local cPgtoTrab		:= ""
Local dDtCorte		:= SuperGetMV("MV_DTCGINI",nil,DDATABASE)
Local cEFDAviso		:= Alltrim(FSubst(If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")))) //Integracao com TAF)
Local lMsgHlp		:= !IsInCallStack("GPEM023")
Local lGpa180		:= IsInCallStack("GPEA180MAT") .Or. IsInCallStack("fEnvTaf180")

Local cBkpFil	 	:= cFilAnt
Local cVersMw	 	:= ""
Local cXml		 	:= ""
Local cMsg		 	:= ""
Local cMsgErro	 	:= ""
Local cVersMid	 	:= ""
Local cChave	 	:= ""
Local cChaveS1030	:= ""
Local cChaveS1040	:= ""
Local cChaveS2300	:= ""
Local cStatus	 	:= "-1"
Local cStat1030	 	:= "-1"
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
Local cOper2300	 	:= "I"
Local cRecib2300 	:= ""
Local cRecibAnt  	:= ""
Local cRecibXML  	:= ""
Local cRetf2300	 	:= "1"
Local cStat2300	 	:= "-1"
Local nRec2300   	:= 0
Local cStatNew	 	:= ""
Local lNovoRJE	 	:= .F.
Local lS1000 	 	:= .T.
Local lS1005 	 	:= .T.
Local lS1030 	 	:= .T.
Local lS1040 	 	:= .T.
Local lPredess 	 	:= .T.
Local nOpcAx	 	:= 0
Local lNT15			:= .F.

Local cTpInsc  		:= ""
Local lAdmPubl 		:= .F.
Local cNrInsc  		:= ""
Local cId  	 		:= ""
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0
Local lNewCTPS		:= !CpoObrigat( "RA_NUMCP" )
Local cFilEstag		:= ""
Local lCargSQ3		:= SuperGetMv("MV_CARGSQ3",,.F.) //Define se o envio do evento S-1030 serão feito pela tabela SQ3 e não pela SRJ (Padrão .F. -> SRJ).
Local cDescFC		:= ""
Local cCboFC		:= ""
Local lTAFTransf	:= .F.

Default oMdlRFS		:= Nil
Default lAltCad		:= .F.
Default nOpca		:= 0
Default cReg		:= "S2300"
Default cTFilial	:= ""
Default aDadosXml	:= {}
Default cVersEnvio	:= "2.2"
Default lCadEst		:= .F.
Default aFilial		:= {}
Default cFilDe		:= ""
Default lNovoCPF	:= .F.
Default lMostraHlp	:= .T.
Default cEmpP		:= Nil
Default cGeraMat	:= If( lGeraMat, (cAliasSRA)->RA_DESCEP, "" ) //"0"//Campo controle geração mat
Default cCodUn		:= (cAliasSRA)->RA_CODUNIC
Default cNovoCodUn	:= ""

// RECEBE O VALOR VINDO COMO PARAMETRO.
nOpcAx := nOpca

If !lMiddleware
	If Len(aFilial) > 0
		aFilInTaf := aFilial[1,1]
		aArrayFil := aFilial[1,2]
		cFilEnv	  := aFilial[1,3]
	Else
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
	EndIf
	fVersEsoc( "S2300", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, , , @lNT15 )
Else

	If FunName()=="GPEM023"
		RegToMemory("SRA",,,.F.)
	EndIf

	fVersEsoc( "S2300", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw, @lNT15, @cTpAmb )
	If !lGpa180
		fPosFil( cEmpAnt, cFilAnt )
	EndIf
	lS1000 := fVld1000( If( lMsgHlp, AnoMes(M->RA_ADMISSA),), @cStatus, Nil, cEmpP )
	If !lS1000 .And. cEFDAviso != "2"
		Do Case
			Case cStatus == "-1" // nao encontrado na base de dados
				If cEFDAviso == "1"
					aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX não localizado na base de dados"
					lGravou	:= .F.
				ElseIf lMsgHlp .And. lMostraHlp
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX não localizado na base de dados"
				EndIf
			Case cStatus == "1" // nao enviado para o governo
				If cEFDAviso == "1"
					aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX não transmitido para o governo"
					lGravou	:= .F.
				ElseIf lMsgHlp .And. lMostraHlp
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX não transmitido para o governo"
				EndIf
			Case cStatus == "2" // enviado e aguardando retorno do governo
				If cEFDAviso == "1"
					aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
					lGravou	:= .F.
				ElseIf lMsgHlp .And. lMostraHlp
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
				EndIf
			Case cStatus == "3" // enviado e retornado com erro
				If cEFDAviso == "1"
					aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
					lGravou	:= .F.
				ElseIf lMsgHlp .And. lMostraHlp
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
				EndIf
		EndCase
	EndIf
EndIf

If Empty(cFilEnv)
	cFilEnv:= cFilAnt
EndIf
if FunName()=="GPEM023"
	//Responsavel por alimentar a tag <CadIni>
	cOrigem := "S" //Vinda da Carga Inicial

	RegToMemory("SRA",,,.F.)

	//Verificar os dados de afastamento (somente para carga inicial)
	aAfastam 	:= fGM23Afast(cFilTrab, M->RA_MAT, dDataRefP)
	nPosAfast	:= aScan(aAfastam,{|x| Alltrim(x[2]) == "32"})

	If( nPosAfast > 0 )
		aAdd( aErros, "AFAST" )
		lGravou	:= .F.
	EndIf
	dAdmissao := M->RA_ADMISSA
	If dAdmissao < dDtCorte
	    cOrigem := "S" //Vinda da Carga Inicial
	Else
	    cOrigem := "N" //Vindo da Admissao
	EndIf
Else
	If M->RA_ADMISSA < dDtCorte //Admissão anterior a data de início no eSocial
		cOrigem := "S"
	Else
		cOrigem := "N" //Vindo da Admissao
	EndIf
EndIf

dDataRefP := Date()

lFilFuncao	:= fGM23Func()
lFilCargo	:= fGM23Func("SQ3")
aSind		:= fGM23Sind()
aCC			:= fGM23CTT()
aEstb		:= fGM23SM0(.T.,.T.)

lMemo		:= .F.

Begin Transaction

	//Atribui os registro do Funcionario/Autonomo a variavel de memoria
	If IsInCallStack("GPEA020") .or. IsInCallStack("fNew1200")
		RegToMemory("SRA",,,.F.)
	EndIf

	//CATEGORIA DO FUNCIONARIO
	cCatEFD := M->RA_CATEFD

	//TRABALHADOR
	cNomAux  := IIF(!EMPTY(ALLTRIM(M->RA_NOMECMP)),SUBSTR(M->RA_NOMECMP,1,60),ALLTRIM(M->RA_NOME) )
	cNomTrab := FSubst(cNomAux)
	nPosEC	  := aScan(aEstCivi,{|x| Alltrim(x[1]) == M->RA_ESTCIVI})
	nPosInstr := aScan(aInstrucao,{|x| Alltrim(x[1]) == M->RA_GRINRAI})
	nPosRacaCor	  := aScan(aRacaCor,{|x| Alltrim(x[1]) == M->RA_RACACOR})

	//NASCIMENTO
	cPais	  := fM23Pais(ALLTRIM(M->RA_CPAISOR))

	//DOCUMENTOS
	nPosCCNH  := aScan(aCatCNH,{|x| Alltrim(x[1]) == M->RA_CATCNH})

	//INFO DEFICIÊNCIA
	If !EMPTY(M->RA_OBSDEFI)
		lMemo 	:= .T.
		cObsDef	:= ALLTRIM(M->RA_OBSDEFI)
	EndIf

	//DEPENDENTES
	aDependent:= {}
	If IsInCallStack("GPEA020")
		aDependent := aDadosXml
	Else
		aDependent:= fGM23Dep(cFilTrab, M->RA_MAT)
	EndIf

	//CONTATO
	If !Empty(M->RA_DDDFONE)
		cFonePrinc := ALLTRIM(M->RA_DDDFONE) + SUBSTR(M->RA_TELEFON,1,11)
	Else
		If !Empty( M->RA_TELEFON )
			cFonePrinc := SUBSTR(M->RA_TELEFON,1,13)
		EndIf
	EndIf
	cFonePrinc := AllTrim(StrTran(StrTran(cFonePrinc, "-",""), ".",""))

	If !Empty(M->RA_DDDCELU)
		cFoneAltern := ALLTRIM(M->RA_DDDCELU) + SUBSTR(M->RA_NUMCELU,1,11)
	Else
		If !Empty( M->RA_NUMCELU )
			cFoneAltern := SUBSTR(M->RA_NUMCELU,1,13)
		EndIf
	EndIf
	cFoneAltern := AllTrim(StrTran(StrTran(cFoneAltern, "-",""), ".",""))

	//VINCULO
	dAdmissao   := M->RA_ADMISSA
	nTpRegTrab	:= aScan(aTpRegTrab,{|x| Alltrim(x[1]) == M->RA_VIEMRAI})
	aVinculoT 	:= fGM23Vinc(cFilTrab, M->RA_MAT, cVersEnvio,oMdlRFZ)
	fGM23Estag(cFilTrab,M->RA_MAT, dDataRefP, @aEstagio, @aInstit, @aAgente, @aCoord, lCadEst, oMdlRFS )
	nTotVinc 	:= LEN(aVinculoT)


	//Verifica se deve gerar as TAGS do FGTS
	If !empty(M->RA_OPCAO) .And. M->RA_CATEFD == '721'
		dOpcao := M->RA_OPCAO
		lTAGFGTS := .T.

		If dOpcao >= STOD('19881004')
			lGravaOpc := .T.
		Endif

		//Optante pelo FGTS
		If 	dOpcao >= STOD('19881004')
			nOptante:= '1'
		Else
			nOptante := IIf(M->RA_ALTOPC=='S','1','2')
		EndIf
	EndIf

	//----------------------------
	//| REMUNERACAO
	//| Realizando a lógica do Cálculo de Salário
	//--------------------------------------------
	cPgtoTrab := fGetTpPagto(M->RA_TIPOPGT, M->RA_CATFUNC, fGetValCpo( "RA_SALARIO" ) )

	//LOCAL DE TRABALHO - conforme leiaute sempre levar do estabalecimento que esta vinculado
	//por isso retirado o controle por cento vamos sempre gerar pela Filial
	cTpInscr	:= ""
	cInscr		:= ""

	If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
		if empty(cTFilial)
			nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cFilTrab)})
		else
			nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cTFilial)})
		Endif
		If nPosEstb > 0
			cTpInscr	:= aEstb[nPosEstb,3]
			cInscr		:= aEstb[nPosEstb,2]
		EndIf
	EndIf

	//TIPO DE JORNADA - HORÁRIO CONTRATUAL
	if Empty((cAliasSRA)->RA_TNOTRAB)
        aTurno    := fGM23Tur("SRA",M->RA_TNOTRAB,M->RA_REGRA, M->RA_SEQTURN, IIF(Empty(cTFilial), cFilTrab,cTFilial), cVersEnvio)
    Else
        aTurno    := fGM23Tur("SRA",,,, IIF(Empty(cTFilial), cFilTrab, cTFilial), cVersEnvio )
    EndIf
	If  cVersEnvio <= "2.5"
		fGrvHorTAF("SRA", IIF(Empty(cTFilial), cFilTrab, cTFilial), Nil, Nil, Nil, Nil, cEmpP)
	Endif

	//Procura Turno
	cTpJorn := ""
	cDescJorn := ""
	cTurno	:= M->RA_TNOTRAB
	lTpJorn:= fTpJorn(cTurno,@cTpJorn,@cDescJorn,cVersEnvio,cFilTrab)

	//HORARIO CONTRATUAL
	nPosTurno := 0
	If M->RA_TPJORNA $ "1|2|4" .AND. Len(aTurno) > 0 .AND. ;
		(!(EMPTY(M->RA_TNOTRAB)) .AND.  !(EMPTY(M->RA_REGRA)))

		nPosTurno := 1
	EndIf

	//Início da Geração do XML
	If !(EMPTY(cFilEnv))

	 	If Len(aErros) == 0
			//Geração do registro S-2300
			If !Empty( cCatEFD )
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
					If cVersEnvio >= "9.0" .And. lGeraMat .And. M->RA_DESCEP == "1"
						cChaveS2300	:= cCodUn
					Else
						cChaveS2300	:= AllTrim( M->RA_CIC ) + AllTrim( M->RA_CATEFD ) + DTOS( M->RA_ADMISSA )
					EndIf
					cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cChaveS2300, fTamRJEKey(), " ")
					cStat2300 	:= "-1"
					GetInfRJE( 2, cChaveBus, @cStat2300, @cOper2300, @cRetf2300, @nRec2300, @cRecib2300, @cRecibAnt )

					//Alteração
					If nOpcAx == 4

						//Retorno pendente impede o cadastro
						If cStat2300 == "2" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
						EndIf

						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2300 == "E" .And. cStat2300 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						//Não existe na fila, será tratado como inclusão
						ElseIf cStat2300 == "-1"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
							If cVersEnvio >= "9.0" .And. cGeraMat == "1" //Nova chave
								cChaveS2300	:= cCodUn
							EndIf
						//Evento sem transmissão, irá sobrescrever o registro na fila
						ElseIf cStat2300 $ "1/3"
							cOperNew 	:= cOper2300
							cRetfNew	:= cRetf2300
							cStatNew	:= "1"
							lNovoRJE	:= .F.
							If cVersEnvio >= "9.0" .And. cGeraMat == "1" //Nova chave
								cChaveS2300	:= cCodUn
							EndIf
						//Evento diferente de exclusão transmitido, irá gerar uma retificação
						ElseIf cOper2300 != "E" .And. cStat2300 == "4"
							cOperNew 	:= "A"
							cRetfNew	:= "2"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento de exclusão transmitido, será tratado como inclusão
						ElseIf cOper2300 == "E" .And. cStat2300 == "4"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
							If cVersEnvio >= "9.0" .And. cGeraMat == "1" //Nova chave
								cChaveS2300	:= cCodUn
							EndIf
						EndIf
					//Exclusão
					ElseIf nOpcAx == 5
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2300 == "E" .And. cStat2300 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						//Evento diferente de exclusão transmitido irá gerar uma exclusão
						ElseIf cOper2300 != "E" .And. cStat2300 == "4"
							cOperNew 	:= "E"
							cRetfNew	:= cRetf2300
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					ElseIf nOpcAx == 2 .Or. nOpcAx == 3 .Or. nOpcAx == 7//Inclusão
						If cVersEnvio >= "9.0" .And. cGeraMat == "1" //Nova chave
							cChaveS2300	:= cCodUn
						EndIf
						//Retorno pendente impede o cadastro
						If cStat2300 == "2" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
						//Evento de exclusão sem transmissão impede o cadastro
						ElseIf cOper2300 == "E" .And. cStat2300 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						//Evento sem transmissão, irá sobrescrever o registro na fila
						ElseIf cStat2300 $ "1/3"
							cOperNew 	:= cOper2300
							cRetfNew	:= cRetf2300
							cStatNew	:= "1"
							lNovoRJE	:= .F.
						//Evento diferente de exclusão transmitido, irá gerar uma retificação
						ElseIf cOper2300 != "E" .And. cStat2300 == "4"
							cOperNew 	:= "A"
							cRetfNew	:= "2"
							cStatNew	:=  "1"
							lNovoRJE	:= .T.
						//Será tratado como inclusão
						Else
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					EndIf
					If !Empty(cMsgRJE)
						If lMsgHlp
							Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0035) + M->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgRJE, 1, 0 )//" não enviado(a) ao Middleware. Erro: "
						Else
							aAdd( aErros, cMsgRJE )
						EndIf
							DisarmTransaction()
						Return .F.
					EndIf
					If cRetfNew == "2"
						If cStat2300 == "4"
							cRecibXML 	:= cRecib2300
							cRecibAnt	:= cRecib2300
							cRecib2300	:= ""
						Else
							cRecibXML 	:= cRecibAnt
						EndIf
					EndIf
					aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2300", Space(6), cChaveS2300, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew, cRecib2300, cRecibAnt } )
					cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTSVInicio/v" + cVersMw + "'>"
					cXML += 	"<evtTSVInicio Id='" + cId + "'>"
					fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cTpAmb, 1, "12" } )
					fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
				Else
					cXml += '<eSocial>'
					cXml += '	<evtTSVInicio>'
				EndIf

				//------------------------
				//| Dados do Trabalhador
				//------------------------
				cXml += '		<trabalhador>'

				If lNovoCPF
					cXml += '			<cpfTrab>' + ALLTRIM(RJI->RJI_CPF)	+ '</cpfTrab>'
				Else
					cXml += '			<cpfTrab>' + Alltrim( M->RA_CIC ) + '</cpfTrab>'
				EndIf

				If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(M->RA_PIS))
					cXml += '			<nisTrab>' + ALLTRIM(M->RA_PIS)	+ '</nisTrab>'
				EndIf
				cXml += '			<nmTrab>' + AllTrim(cNomTrab) + '</nmTrab>'
				cXml += '			<sexo>' + AllTrim( M->RA_SEXO ) + '</sexo>'
				cXml += '			<racaCor>' + IIf( nPosRacaCor > 0, aRacaCor[nPosRacaCor,2], "") + '</racaCor>'

				If ( nPosEC > 0 )
					cXml += '<estCiv>' 		+ aEstCivi[nPosEC,2] + '</estCiv>'
				ElseIf !lMiddleware
					cXml += '<estCiv>' 		+ '' + '</estCiv>'
				EndIf

				cXml += '			<grauInstr>' + IIf( nPosInstr > 0, aInstrucao[nPosInstr,2], "") + '</grauInstr>'
				If !lMiddleware .Or. !Empty(M->RA_NSOCIAL)
					cXml += '			<nmSoc>'	+ ALLTRIM(M->RA_NSOCIAL) + '</nmSoc>'
				EndIf

				//----------------------------
				//| Nascimento do Trabalhador
				//----------------------------
				cXml += '			<nascimento>'
				If !lMiddleware
					cXml += '				<dtNascto>' + DtoS( M->RA_NASC ) + '</dtNascto>'
				Else
					cXml += '<dtNascto>' + SubStr( dToS(M->RA_NASC), 1, 4 ) + "-" + SubStr( dToS(M->RA_NASC), 5, 2 ) + "-" + SubStr( dToS(M->RA_NASC), 7, 2 ) + '</dtNascto>'
				EndIf
				If cVersEnvio < "9.0" .And. M->RA_CPAISOR=="01058" .AND. M->RA_NATURAL != "EX"
					If !Empty(M->RA_CODMUNN)
						cXml += '				<codMunic>' + Iif(lMiddleware, fEstIBGE(M->RA_NATURAL), "") + ALLTRIM(M->RA_CODMUNN)+ '</codMunic>'
					EndIf
					If !lMiddleware .Or. !Empty(M->RA_NATURAL)
						cXml += '				<uf>'	+ M->RA_NATURAL + '</uf>'
					EndIf
				Endif
				cXml += '				<paisNascto>' + fM23Pais( AllTrim( M->RA_CPAISOR ) ) + '</paisNascto>'
				cXml += '				<paisNac>' + fM23Pais( AllTrim( M->RA_NACIONC ) ) + '</paisNac>'
				If cVersEnvio < "9.0"
					If !lMiddleware .Or. !Empty(M->RA_MAE)
						cXml += '				<nmMae>'	+ M->RA_MAE			+ '</nmMae>'
					EndIf
					If !lMiddleware .Or. !Empty(M->RA_PAI)
						cXml += '				<nmPai>'	+ M->RA_PAI			+ '</nmPai>'
					EndIf
				EndIf
				cXml += '			</nascimento>'

				//----------------------------
				//| Documentos do Trabalhador
				//----------------------------
				If cVersEnvio < "9.0"
					cXml += '			<documentos>'

					//CTPS
					If (!lMiddleware .and. !lNT15) .or. (!Empty(M->RA_NUMCP) .and. !Empty(M->RA_SERCP) .and. !Empty(M->RA_UFCP)) .Or. lNewCTPS
						cXml += '				<CTPS>'
						If lNewCTPS .And. Empty(M->RA_NUMCP)
							cXml += '					<nrCtps>' + AllTrim( M->RA_CIC ) + '</nrCtps>'
							cXml += '					<serieCtps>' + "00000" + '</serieCtps>'
							cXml += '					<ufCtps>' + If(Empty(M->RA_UFCP), SM0->M0_ESTENT ,AllTrim( M->RA_UFCP )) + '</ufCtps>'
						Else
							cXml += '					<nrCtps>' + AllTrim( M->RA_NUMCP ) + '</nrCtps>'
							cXml += '					<serieCtps>' + AllTrim( M->RA_SERCP ) + '</serieCtps>'
							cXml += '					<ufCtps>' + AllTrim( M->RA_UFCP ) + '</ufCtps>'
						EndIf
						cXml += '				</CTPS>'
					EndIf

					//RIC
					If (!lMiddleware .and. !lNT15) .Or. (!Empty(M->RA_NUMRIC) .and. !empty(M->RA_EMISRIC))
						cXml += '				<RIC>'
						cXml += '					<nrRic>' + M->RA_NUMRIC + '</nrRic>'
						cXml += '					<orgaoEmissor>' + M->RA_EMISRIC + '</orgaoEmissor>'
						If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_DEXPRIC)
							If !lMiddleware
								cXml += '					<dtExped>' + DtoS(M->RA_DEXPRIC) + '</dtExped>'
							Else
								cXml += '<dtExped>' + SubStr( dToS(M->RA_DEXPRIC), 1, 4 ) + "-" + SubStr( dToS(M->RA_DEXPRIC), 5, 2 ) + "-" + SubStr( dToS(M->RA_DEXPRIC), 7, 2 ) + '</dtExped>'
							EndIf
						EndIf
						cXml += '				</RIC>'
					EndIf

					//RG
					If (!lMiddleware .and. !lNT15) .Or. (!Empty(M->RA_RG) .and. !empty(M->RA_RGEXP))
						cXml += '				<RG>'
						cXml += '					<nrRg>'  	  + Substr(ALLTRIM(M->RA_RG),1,14) + '</nrRg>'
						cXml += '					<orgaoEmissor>'+ M->RA_RGEXP		+ '</orgaoEmissor>'
						If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_DTRGEXP)
							If !lMiddleware
								cXml += '					<dtExped>'	  + DtoS(M->RA_DTRGEXP)+ '</dtExped>'
							Else
								cXml += '<dtExped>' + SubStr( dToS(M->RA_DTRGEXP), 1, 4 ) + "-" + SubStr( dToS(M->RA_DTRGEXP), 5, 2 ) + "-" + SubStr( dToS(M->RA_DTRGEXP), 7, 2 ) + '</dtExped>'
							EndIf
						EndIf
						cXml += '				</RG>'
					EndIf

					//RNE
					If (!lMiddleware .and. !lNT15) .Or. (!Empty(M->RA_RNE) .and. !empty(M->RA_RNEORG))
						cXml += '				<RNE>'
						cXml += '					<nrRne>' + M->RA_RNE	+ '</nrRne>'
						cXml += '					<orgaoEmissor>' + M->RA_RNEORG + '</orgaoEmissor>'
						If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_RNEDEXP)
							If !lMiddleware
								cXml += '					<dtExped>' + DtoS(M->RA_RNEDEXP) + '</dtExped>'
							Else
								cXml += '<dtExped>' + SubStr( dToS(M->RA_RNEDEXP), 1, 4 ) + "-" + SubStr( dToS(M->RA_RNEDEXP), 5, 2 ) + "-" + SubStr( dToS(M->RA_RNEDEXP), 7, 2 ) + '</dtExped>'
							EndIf
						EndIf
						cXml += '				</RNE>'
					EndIf

					//OC
					If (!lMiddleware .and. !lNT15) .Or. (!empty(M->RA_CODIGO) .and. !empty(M->RA_OCEMIS))
						cXml += '				<OC>'
						cXml += '					<nrOc>' + M->RA_CODIGO + '</nrOc>'
						cXml += '					<orgaoEmissor>' + M->RA_OCEMIS + '</orgaoEmissor>'
						If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_OCDTEXP)
							If !lMiddleware
								cXml += '					<dtExped>' + DtoS(M->RA_OCDTEXP) + '</dtExped>'
							Else
								cXml += '<dtExped>' + SubStr( dToS(M->RA_OCDTEXP), 1, 4 ) + "-" + SubStr( dToS(M->RA_OCDTEXP), 5, 2 ) + "-" + SubStr( dToS(M->RA_OCDTEXP), 7, 2 ) + '</dtExped>'
							EndIf
						EndIf
						If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_OCDTVAL)
							If !lMiddleware
								cXml += '					<dtValid>' + DtoS(M->RA_OCDTVAL) + '</dtValid>'
							Else
								cXml += '<dtValid>' + SubStr( dToS(M->RA_OCDTVAL), 1, 4 ) + "-" + SubStr( dToS(M->RA_OCDTVAL), 5, 2 ) + "-" + SubStr( dToS(M->RA_OCDTVAL), 7, 2 ) + '</dtValid>'
							EndIf
						EndIf
						cXml += '				</OC>'
					EndIf

					//CNH
					If (!lMiddleware .and. !lNT15) .Or. (!Empty(M->RA_HABILIT) .And. !Empty(M->RA_UFCNH) .And. !Empty(M->RA_DTVCCNH) .And. nPosCCNH > 0)
						cXml += '				<CNH>'
						cXml += '					<nrRegCnh>' + AllTrim( M->RA_HABILIT ) + '</nrRegCnh>'
						If (!lMiddleware .and. !lNT15) .Or. !Empty(M->RA_DTEMCNH)
							If !lMiddleware
								cXml += '					<dtExped>' + DtoS(M->RA_DTEMCNH)	+ '</dtExped>'
							Else
								cXml += '<dtExped>' + SubStr( dToS(M->RA_DTEMCNH), 1, 4 ) + "-" + SubStr( dToS(M->RA_DTEMCNH), 5, 2 ) + "-" + SubStr( dToS(M->RA_DTEMCNH), 7, 2 ) + '</dtExped>'
							EndIf
						EndIf
						cXml += '					<ufCnh>' + AllTrim( M->RA_UFCNH ) + '</ufCnh>'
						If !lMiddleware
							cXml += '					<dtValid>' + DtoS(M->RA_DTVCCNH) + '</dtValid>'
						Else
							cXml += '<dtValid>' + SubStr( dToS(M->RA_DTVCCNH), 1, 4 ) + "-" + SubStr( dToS(M->RA_DTVCCNH), 5, 2 ) + "-" + SubStr( dToS(M->RA_DTVCCNH), 7, 2 ) + '</dtValid>'
						EndIf
						If cVersEnvio >= "2.3" .And. lPriHab .And. !Empty(DtoS(M->RA_DTINCON))
							If !lMiddleware
								cXml += '					<dtPriHab>'	+ DtoS(M->RA_DTINCON) + '</dtPriHab>'
							Else
								cXml += '<dtPriHab>' + SubStr( dToS(M->RA_DTINCON), 1, 4 ) + "-" + SubStr( dToS(M->RA_DTINCON), 5, 2 ) + "-" + SubStr( dToS(M->RA_DTINCON), 7, 2 ) + '</dtPriHab>'
							EndIf
						ElseIf (!lMiddleware .and. !lNT15)
							cXml += '					<dtPriHab>'	+ "" + '</dtPriHab>'
						EndIf
						cXml += '					<categoriaCnh>' + IIf(nPosCCNH > 0 , aCatCNH[nPosCCNH, 2], "") + '</categoriaCnh>'
						cXml += '				</CNH>'
					EndIf
					cXml += '			</documentos>'
				EndIf
				//---------------------------
				//| Endereco do Trabalhador
				//---------------------------
				cXml += '			<endereco>'
				If Empty( M->RA_RESEXT ) .OR. M->RA_RESEXT == '2'
					//Nacional
					cXml += '				<brasil>'
					if (lNT15 .and. !empty(M->RA_LOGRTP )) .or. !lNT15
						cXml += '					<tpLograd>' + AllTrim( M->RA_LOGRTP ) + '</tpLograd>'
					endif
					cXml += '					<dscLograd>' + AllTrim( M->RA_LOGRDSC ) + '</dscLograd>'
					cXml += '					<nrLograd>' + Iif( !Empty( M->RA_LOGRNUM ), M->RA_LOGRNUM, "S/N") + '</nrLograd>'
					If !lMiddleware .Or. !Empty(M->RA_COMPLEM)
						cXml += '					<complemento>'	+ M->RA_COMPLEM + '</complemento>'
					EndIf
					If !lMiddleware .Or. !Empty(M->RA_BAIRRO)
						cXml += '					<bairro>' + M->RA_BAIRRO + '</bairro>'
					EndIf
					cXml += '					<cep>' + M->RA_CEP + '</cep>'
					cXml += '					<codMunic>' + Iif(lMiddleware, fEstIBGE(M->RA_ESTADO), "") + AllTrim( M->RA_CODMUN ) + '</codMunic>'
					cXml += '					<uf>' + M->RA_ESTADO + '</uf>'
					cXml += '				</brasil>'
				Else
					//Internacional
					cXml += '				<exterior>'
					cXml += '					<paisResid>' + fM23Pais(ALLTRIM(M->RA_PAISEXT)) + '</paisResid>'
					cXml += '					<dscLograd>' + AllTrim( M->RA_LOGRDSC ) + '</dscLograd>'
					cXml += '					<nrLograd>' + Iif( !Empty( M->RA_LOGRNUM ), M->RA_LOGRNUM, "S/N" ) + '</nrLograd>'
					If !lMiddleware .Or. !Empty(M->RA_COMPLEM)
						cXml += '					<complemento>'	+ M->RA_COMPLEM + '</complemento>'
					EndIf
					If !lMiddleware .Or. !Empty(M->RA_BAIRRO)
						cXml += '					<bairro>' + M->RA_BAIRRO + '</bairro>'
					EndIf
					cXml += '					<nmCid>' + AllTrim( M->RA_MUNICIP ) + '</nmCid>'
					If !lMiddleware .Or. !Empty(M->RA_CPOSTAL)
						cXml += '					<codPostal>' + M->RA_CPOSTAL + '</codPostal>'
					EndIf
					cXml += '				</exterior>'
				EndIf
				cXml += '			</endereco>'

				//----------------------------
				//| Estrangeiro (Trabalhador)
				//----------------------------
				If( M->RA_CPAISOR <> "01058" .AND. !Empty( M->RA_CPAISOR ) )
					If cVersEnvio >= "9.0"
						cXml += '			<trabImig>'
						cXml += '				<tmpResid>' + M->RA_TIPOVIA + '</tmpResid>'
						cXml += '				<condIng>' + AllTrim(M->RA_CLASEST) + '</condIng>'
						cXml += '			</trabImig>'
					Else
						cXml += '			<trabEstrangeiro>'
						If !lMiddleware .Or. !Empty(M->RA_DATCHEG)
							If !lMiddleware
								cXml += '				<dtChegada>' + DtoS(M->RA_DATCHEG) + '</dtChegada>'
							Else
								cXml += '<dtChegada>' + SubStr( dToS(M->RA_DATCHEG), 1, 4 ) + "-" + SubStr( dToS(M->RA_DATCHEG), 5, 2 ) + "-" + SubStr( dToS(M->RA_DATCHEG), 7, 2 ) + '</dtChegada>'
							EndIf
						EndIf

						If Val(M->RA_CLASEST) == 0
							cXml += '<classTrabEstrang> </classTrabEstrang>'
						Else
							cXml += '<classTrabEstrang>'+Alltrim(Str(Val(M->RA_CLASEST))) + '</classTrabEstrang>'
						Endif

						If( !Empty( M->RA_CASADBR ) )
							cXml += '				<casadoBr>' + Iif( M->RA_CASADBR == "1" , "S", "N") + '</casadoBr>'
						EndIf

						If( !Empty( M->RA_FILHOBR ) )
							cXml += '				<filhosBr>' + Iif( M->RA_FILHOBR == "1" , "S", "N") + '</filhosBr>'
						EndIf
						cXml += '			</trabEstrangeiro>'
					EndIf
				EndIf
				//----------------------------
				//| Deficiencia Trabalhador
				//----------------------------
				If lMemo .OR. (M->RA_PORTDEF <> "******" .AND. !EMPTY(M->RA_PORTDEF))
					cXml += '			<infoDeficiencia>'
					cXml += '				<defFisica>'		+ IIf (AT("1",M->RA_PORTDEF) > 0 , "S" , "N") + '</defFisica>'
					cXml += '				<defVisual>'		+ IIf (AT("3",M->RA_PORTDEF) > 0 , "S" , "N") + '</defVisual>'
					cXml += '				<defAuditiva>'		+ IIf (AT("2",M->RA_PORTDEF) > 0 , "S" , "N") + '</defAuditiva>'
					cXml += '				<defMental>'		+ IIf (AT("4",M->RA_PORTDEF) > 0 , "S" , "N") + '</defMental>'
					cXml += '				<defIntelectual>'	+ IIf (AT("5",M->RA_PORTDEF) > 0 , "S" , "N") + '</defIntelectual>'
					cXml += '				<reabReadap>'		+ IIf (AT("6",M->RA_PORTDEF) > 0 , "S" , "N") + '</reabReadap>'
					If !lMiddleware .Or. !Empty(cObsDef)
						cXml += '				<observacao>'		+ cObsDef									  + '</observacao>'
					EndIf
					cXml += '			</infoDeficiencia>'
				Endif

				//----------------------------
				//| Dependentes Trabalhador
				//----------------------------
				If Len(aDependent) > 0
					For nI:= 1 To Len(aDependent)
						cXml += '			<dependente>'
						cXml += fTpDep(aDependent[nI],cVersEnvio)
						cXml += '				<nmDep>' + aDependent[nI,2] + '</nmDep>'
						cDtDep := iif (valtype(aDependent[nI,3]) == "D",DTOS(aDependent[nI,3]),aDependent[nI,3])
						If !lMiddleware
							cXml += '				<dtNascto>' +  cDtDep      + '</dtNascto>'
						Else
							cXml += '<dtNascto>' + SubStr( cDtDep, 1, 4 ) + "-" + SubStr( cDtDep, 5, 2 ) + "-" + SubStr( cDtDep, 7, 2 ) 	+ '</dtNascto>'
						EndIf
						If !lMiddleware .Or. !Empty(aDependent[nI,4])
							cXml += '				<cpfDep>' + aDependent[nI,4] + '</cpfDep>'
						EndIf
						cXml += '				<depIRRF>' + aDependent[nI,5] + '</depIRRF>'
						cXml += '				<depSF>' + aDependent[nI,6] + '</depSF>'
						//Dependente Incapaz
						//Se RB_TPDEP for igual a 5 ou 11 = <incTrab> S </incTrab>
						//Se RB_INCT  for igual a 1 = <incTrab> S </incTrab>
						if (aDependent[nI,1] $ "05|11") .OR. (aDependent[nI,9] == "S" )
							cXml += '				<incTrab>S</incTrab>'
						else
							cXml += '				<incTrab>N</incTrab>'
						Endif
						cXml += '			</dependente>'
					Next nI
				Endif

				//----------------------------
				//| Contatos trabalhador
				//----------------------------
				If !lMiddleware .Or. (!Empty(cFonePrinc) .Or. !Empty(cFoneAltern) .Or. !Empty(M->RA_EMAIL) .Or. !Empty(M->RA_EMAIL2))
					cXml += '			<contato>'
					If !lMiddleware .Or. !Empty(cFonePrinc)
						cXml += '				<fonePrinc>' + AllTrim( cFonePrinc ) + '</fonePrinc>'
					EndIf
					If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(cFoneAltern))
						cXml += '				<foneAlternat>' + Alltrim( cFoneAltern ) + '</foneAlternat>'
					EndIf
					If !lMiddleware .Or. !Empty(M->RA_EMAIL)
						cXml += '				<emailPrinc>' + AllTrim( M->RA_EMAIL ) + '</emailPrinc>'
					EndIf
					If cVersEnvio < "9.0" .And. (!lMiddleware .Or. !Empty(M->RA_EMAIL2))
						cXml += '				<emailAlternat>' + AllTrim( M->RA_EMAIL2 ) + '</emailAlternat>'
					EndIf
					cXml += '			</contato>'
				EndIf
				cXml += '		</trabalhador>'

				//----------------------------
				//| Dados TSV Inicio
				//----------------------------
				cXml += '		<infoTSVInicio>'
				If cVersEnvio >= "2.4"
					//Define de onde vem o registro: Carga ou Admissão
					cXml += '			<cadIni>'+ AllTrim( cOrigem ) +'</cadIni>'
				EndIf
				If cVersEnvio >= "9.0" .And. cGeraMat == "1"//Receber codunico e campo se gera ou não por param
					If lNovoCPF
						cXml += '			<matricula>' + Iif(lMiddleware, Alltrim(cNovoCodUn), cNovoCodUn) + '</matricula>'
					elseIf !Empty(cCodUn)
						cXml += '			<matricula>' + Iif(lMiddleware, Alltrim(cCodUn), cCodUn) + '</matricula>'
					endif
				EndIf

				cXml += '			<codCateg>' + M->RA_CATEFD + '</codCateg>'
				If !lMiddleware
					cXml += '			<dtInicio>' + DtoS( M->RA_ADMISSA ) + '</dtInicio>'
				Else
					cXml += '<dtInicio>' + SubStr( dToS(M->RA_ADMISSA), 1, 4 ) + "-" + SubStr( dToS(M->RA_ADMISSA), 5, 2 ) + "-" + SubStr( dToS(M->RA_ADMISSA), 7, 2 ) + '</dtInicio>'
				EndIf

				If cVersEnvio >= "9.0" .And. Len(aVinculoT) > 0	.And. !Empty(aVinculoT[1][11])
					cXml += '			<nrProcTrab>'+ aVinculoT[1][11] + '</nrProcTrab>'
				Endif

				If !( M->RA_CATEFD $ '901|771|305|722|721' )
					cXml += '			<natAtividade>'+IIf(M->RA_VIEMRAI $ ('20|25|70|75'),'2','1') + '</natAtividade>'
				EndIf

				If cVersEnvio >= "2.6.00" .And. cVersEnvio < "9.0"
					cXml += '			<indProcTrab>'+IIf(M->RA_TIPOAFP == "1",'S','N') + '</indProcTrab>'
					If !Empty(M->RA_DECRLEI)
						cXml += '			<infoProcTrab>'
						cXml += '				<nrProcTrab>'+ M->RA_DECRLEI + '</nrProcTrab>'
						cXml += '			</infoProcTrab>'
					Endif
				Endif

				cXml += '			<infoComplementares>'

				lEstag := M->RA_CATEFD $ '901/903/904/905/906'
				If lEstag .And. cVersEnvio < "9.0"
					cFilEstag  := IIF(Empty(cTFilial), cFilTrab,cTFilial)
					fEstagCBO(cFilEstag, fGetValCpo( "RA_CARGO" ), fGetValCpo( "RA_CODFUNC" ), @lCBOCargo, @lCBOFuncao)
				ElseIf cVersEnvio >= "9.0"
					fVerifCBO(Iif(Empty(cTFilial), cFilTrab,cTFilial), fGetValCpo( "RA_CARGO" ), fGetValCpo( "RA_CODFUNC" ), @lCBOCargo, @lCBOFuncao, @cDescFC, @cCboFC)
				EndIf

				If (cVersEnvio < "2.4.02" .And. M->RA_CATEFD $ cCatAux) .Or. (cVersEnvio >= "2.4.02" .And. !lEstag .Or. (lEstag .And. (lCBOCargo .Or. lCBOFuncao)))
					//Cargo e Funcao
					cXml += '				<cargoFuncao>'

					If cVersEnvio >= "9.0"
						If (lCBOFuncao .Or. lCBOCargo) .And. M->RA_CATEFD <> '410'
							cXml += '					<nmCargo>' + cDescFC + '</nmCargo>'
							cXml += '					<CBOCargo>' + cCboFC + '</CBOCargo>'
						ElseIf M->RA_CATEFD $ '410' .And. lCBOFuncao
							cXml += '					<nmFuncao>' + cDescFC + '</nmFuncao>'
							cXml += '					<CBOFuncao>' + cCboFC + '</CBOFuncao>'
						EndIf
					Else
						If lCargSQ3
							If lFilCargo .And. ( !lEstag .Or. (lEstag .And. lCBOCargo) )  // Possui filial no cadastro de cargos
								If !lMiddleware .Or. !Empty(xFilial("SQ3",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CARGO" ))
									cXml += '					<codCargo>' + xFilial("SQ3",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CARGO" ) + '</codCargo>'
								EndIf
							ElseIf (!lEstag .Or. (lEstag .And. lCBOCargo))
								If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CARGO" ))
									cXml += '					<codCargo>' + fGetValCpo( "RA_CARGO" ) + '</codCargo>'
								EndIf
							Endif
							cChaveS1030 := xFilial("SQ3",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CARGO" )
							If lFilFuncao .And. ( !lEstag .Or. (lEstag .And. lCBOFuncao )) // Possui filial no cadastro de funções
								If !lMiddleware .Or. !Empty(xFilial("SRJ",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CODFUNC" ))
									cXml += '					<codFuncao>' + xFilial("SRJ",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CODFUNC" ) + '</codFuncao>' //No registro do cargo informamos a função, conforme carga da tabela S-1030.
								EndIf
							ElseIf !lEstag .Or. (lEstag .And. lCBOFuncao )
								If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CODFUNC" ))
									cXml += '					<codFuncao>' + fGetValCpo( "RA_CODFUNC" ) + '</codFuncao>' //No registro do cargo informamos a função, conforme carga da tabela S-1030.
								EndIf
							Endif
							cChaveS1040 := xFilial("SRJ",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CODFUNC" )
						ElseIf !lEstag .Or. (lEstag .And. lCBOFuncao )
							If lFilFuncao // tem filial no cad funcao
								If !lMiddleware .Or. !Empty(xFilial("SRJ",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CODFUNC" ))
									cXml += '					<codCargo>' + xFilial("SRJ",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CODFUNC" ) + '</codCargo>' //No registro do cargo informamos a função, conforme carga da tabela S-1030.
								EndIf
							Else
								If !lMiddleware .Or. !Empty(fGetValCpo( "RA_CODFUNC" ))
									cXml += '					<codCargo>' + fGetValCpo( "RA_CODFUNC" ) + '</codCargo>' //No registro do cargo informamos a função, conforme carga da tabela S-1030.
								EndIf
							Endif
							cChaveS1030 := xFilial("SRJ",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CODFUNC" )
						EndIf
					EndIf

					//cXml += '					<codFuncao>' + AllTrim( fGetValCpo( "RA_CODFUNC" ) ) + '</codFuncao>'
					cXml += '				</cargoFuncao>'

					If !lEstag .Or. (lEstag .And. !Empty(fGetValCpo( "RA_SALARIO" )) )
						//Remuneracao
						cSalario	:= fGetValCpo( "RA_SALARIO" )
						cXml += '				<remuneracao>'
						If !lMiddleware
							cXml += '					<vrSalFx>' + transform( cSalario, "@E 999999999.99" ) + '</vrSalFx>'
						Else
							cXml += '<vrSalFx>' 	+ AllTrim(Str(cSalario))	+ '</vrSalFx>'
						EndIf
						cXml += '					<undSalFixo>' + cPgtoTrab + '</undSalFixo>'
						If cVersEnvio >= "2.3" .And. lDesRem .And. !Empty(Alltrim(M->RA_DESEPS))
							cXml += '				<dscSalVar>'+ Alltrim(M->RA_DESEPS) + '</dscSalVar>'
						ElseIf !lMiddleware
							cXml += '				<dscSalVar>'+ "" + '</dscSalVar>'
						EndIf
						cXml += '				</remuneracao>'
					Endif
				EndIf

				//Mensagem quando as tags de salário, cargo e função não foram geradas
				If lEstag .And. !IsBlind()
					If fGetValCpo( "RA_SALARIO" ) = 0
						cMsgEstag2 :=  OemToAnsi(STR0120) + CRLF + CRLF // "'remuneracao' - O salário no cadastro está zerado."
					Endif
					If lCargSQ3
						If !lCBOCargo
							cMsgEstag2 += OemToAnsi(STR0121) + CRLF + CRLF //"'codCargo' - O cargo informado não possui um número de CBO."
						EndIF
						If !lCBOFuncao
							cMsgEstag2 += OemToAnsi(STR0122) + CRLF + CRLF //"'codFuncao' - A função informada não possui um número de CBO."
						Endif
					Else
						If !lCBOFuncao
							cMsgEstag2 := OemToAnsi(STR0123) + CRLF + CRLF //"'codCargo' - A função informada não possui um número de CBO."
						Endif
					Endif
					If !Empty(cMsgEstag2)
						cMsgEstag1 := OemToAnsi(STR0119) + CRLF + CRLF // "Algumas tags do evento não serão geradas, pois alguns campos não foram preenchidos, são elas:"
						cMsgEstag1 += cMsgEstag2
						cMsgEstag1 += CRLF + CRLF + OemToAnsi(STR0124) //"Entretanto a falta dessas tags não irá impactar no envio e na transmissão do evento."
						Help( ,, OemToAnsi(STR0001) ,, cMsgEstag1, 1, 0 )
					EndIf
				Endif

				//FGTS
				If lTAGFGTS
					If cVersEnvio < "9.0"
						cXml += '				<fgts>'
						cXml += '					<opcFGTS>' + nOptante + '</opcFGTS>'
					Else
						cXml += '				<FGTS>'
					EndIf
					If !lMiddleware .Or. lGravaOpc
						If !lMiddleware
							cXml += '					<dtOpcFGTS>' + IIF(lGravaOpc, dTOS(dOpcao), "") + '</dtOpcFGTS>'
						Else
							cXml += '<dtOpcFGTS>' + SubStr( dToS(dOpcao), 1, 4 ) + "-" + SubStr( dToS(dOpcao), 5, 2 ) + "-" + SubStr( dToS(dOpcao), 7, 2 ) + '</dtOpcFGTS>'
						EndIf
					EndIf
					If cVersEnvio < "9.0"
						cXml += '				</fgts>'
					Else
						cXml += '				</FGTS>'
					EndIf
				Endif

				/*//Infos Sindicais - Não realizaremos a tratativa do Dirigente sindical
				If( M->RA_CATEFD <> '401' .AND. ( LEN(aVinculoT) > 0 ) )
					cXml += '				<infoDirigenteSindical>'
					cXml += '					<categOrig>' + AllTrim( aVinculoT[1,12] ) + '</categOrig>'
					cXml += '				</infoDirigenteSindical>'
				EndIf*/

				//Infos Trabalho Cedido
				If( M->RA_CATEFD $ '410' .AND. LEN(aVinculoT) > 0 )
					//aVinculoT baseado na tabela RFZ
					//|(1)RFZ_TPADM |(2)RFZ_INDADM|(3)RFZ_INDPEM|(4)RFZ_CNPJAN |(5)RFZ_MATANT |(6)RFZ_DTADAN
					//|(7)RFZ_OBSVAN|(8)RFZ_DTTRA|(9)RFZ_ONUS|(10)RFZ_CATEG
					cXml += '				<infoTrabCedido>'
					cXml += '					<categOrig>' + AllTrim( aVinculoT[1,10])		+ '</categOrig>'
					cXml += '					<cnpjCednt>' + AllTrim( aVinculoT[1,4] )		+ '</cnpjCednt>'
					cXml += '					<matricCed>' + AllTrim( aVinculoT[1,5] )		+ '</matricCed>'
					If !lMiddleware
						cXml += '					<dtAdmCed>' +  AllTrim( DtoS(aVinculoT[1,6]) )	+ '</dtAdmCed>'
					Else
						cXml += '					<dtAdmCed>' +  SubStr( dToS(aVinculoT[1,6]), 1, 4 ) + "-" + SubStr( dToS(aVinculoT[1,6]), 5, 2 ) + "-" + SubStr( dToS(aVinculoT[1,6]), 7, 2 )	+ '</dtAdmCed>'
					EndIf
					If nTpRegTrab > 0
						cXml += '<tpRegTrab>' + '2' + '</tpRegTrab>'
					Else
						cXml += '<tpRegTrab>' + '1' + '</tpRegTrab>'
					Endif
					cXml += '					<tpRegPrev>' + AllTrim( M->RA_TPPREVI )			+ '</tpRegPrev>'
					If cVersEnvio < "9.0"
						cXml += '					<infOnus>' +   AllTrim( aVinculoT[1,9] )		+ '</infOnus>'
					EndIf
					cXml += '				</infoTrabCedido>'
				EndIf

				//Informações complementares - Afastamento para exercício de mandato eletivo
				If ( M->RA_CATEFD $ '304*305*308' .And. cVersEnvio >= "9.0" .And. RS9->( ColumnPos( "RS9_INDREM")) > 0 )
					cIndRem		:= If(FunName() == "GPEA931", M->RS9_INDREM, Posicione('RS9',1,cFilTrab + M->RA_MAT,'RS9_INDREM'))
					cXml += '				<infoMandElet>'
					cXml += '					<indRemunCargo>' + IIf(cIndRem == "1",'S','N') + '</indRemunCargo>'
					cXml += '					<tpRegTrab>' + IIf(M->RA_VIEMRAI $ ('20|25|70|75'),'2','1') + '</tpRegTrab>'
					cXml += '					<tpRegPrev>' + AllTrim( M->RA_TPPREVI )	 + '</tpRegPrev>'
					cXml += '				</infoMandElet>'
				EndIf

				//Info Estagio //Se Tiver estagio, instituição é obrigatório
				If( M->RA_CATEFD $ '901*906' .AND. ( LEN(aEstagio) > 0 .AND. LEN(aInstit) > 0 ) )
					cSalario := fGetValCpo( "RA_SALARIO" )
					cXml += '				<infoEstagiario>'
					cXml += '					<natEstagio>' + AllTrim( aEstagio[1,1] ) + '</natEstagio>'
					cXml += '					<nivEstagio>' + AllTrim( aEstagio[1,2] ) + '</nivEstagio>'
					If !lMiddleware .Or. !Empty(aEstagio[1,3])
						cXml += '					<areaAtuacao>'+ AllTrim( aEstagio[1,3] ) +'</areaAtuacao>'
					EndIf
					If !lMiddleware .Or. !Empty(aEstagio[1,4])
						cXml += '					<nrApol>'     + AllTrim( aEstagio[1,4] ) +'</nrApol>'
					EndIf
					If cVersEnvio < "9.0" .And. Alltrim(cSalario) <> "0,00"
						If !lMiddleware
							cXml += '					<vlrBolsa>'   + Transform( cSalario, "@E 999999999.99" ) +'</vlrBolsa>'
						Else
							cXml += '					<vlrBolsa>'   + AllTrim(Str(cSalario)) +'</vlrBolsa>'
						EndIf
					EndIf
					If !lMiddleware
						cXml += '					<dtPrevTerm>' + DtoS( aEstagio[1,5] ) + '</dtPrevTerm>'
					Else
						cXml += '					<dtPrevTerm>' + SubStr( dToS(aEstagio[1,5]), 1, 4 ) + "-" + SubStr( dToS(aEstagio[1,5]), 5, 2 ) + "-" + SubStr( dToS(aEstagio[1,5]), 7, 2 ) + '</dtPrevTerm>'
					EndIf
					cXml += '					<instEnsino>'
					If !lMiddleware .Or. !Empty(aInstit[1,1])
						cXml += '						<cnpjInstEnsino>' + AllTrim( aInstit[1,1] ) + '</cnpjInstEnsino>'
					EndIf
					If cVersEnvio < "9.0" .Or. (cVersEnvio >= "9.0" .And. Empty(aInstit[1,1]))
						cXml += '						<nmRazao>' +        AllTrim( aInstit[1,2] ) + '</nmRazao>'
						If !lMiddleware .Or. !Empty(aInstit[1,3])
							cXml += '						<dscLograd>'+       AllTrim( aInstit[1,3] )+'</dscLograd>'
						EndIf
						If !lMiddleware .Or. !Empty(aInstit[1,8])
							cXml += '						<nrLograd>'+        AllTrim( aInstit[1,8] )+'</nrLograd>'
						ElseIf cVersEnvio >= "9.0" .And. Empty(aInstit[1,8])
							cXml += '						<nrLograd>S/N</nrLograd>'
						EndIf
						If !lMiddleware .Or. !Empty(aInstit[1,4])
							cXml += '						<bairro>'+          AllTrim( aInstit[1,4] )+'</bairro>'
						EndIf
						If !lMiddleware .Or. !Empty(aInstit[1,5])
							cXml += '						<cep>'+             AllTrim( aInstit[1,5] )+'</cep>'
						EndIf
						If !lMiddleware .Or. !Empty(aInstit[1,6])
							cXml += '						<codMunic>' + Iif(lMiddleware, fEstIBGE(aInstit[1,7]), "") + AllTrim( aInstit[1,6] )+'</codMunic>'
						EndIf
						If !lMiddleware .Or. !Empty(aInstit[1,7])
							cXml += '						<uf>'+              AllTrim( aInstit[1,7] )+'</uf>'
						EndIf
					EndIf
					cXml += '					</instEnsino>'

					If ( Len(aAgente) > 0 ) .And. M->RA_CATEFD <> '906'
						cXml += '					<ageIntegracao>'
						cXml += '						<cnpjAgntInteg>'+   AllTrim( aAgente[1,1] ) +'</cnpjAgntInteg>'
						If cVersEnvio < "9.0"
							cXml += '						<nmRazao>'+ 		AllTrim( aAgente[1,2] ) +'</nmRazao>'
							cXml += '						<dscLograd>'+ 		AllTrim( aAgente[1,3] ) +'</dscLograd>'
							cXml += '						<nrLograd>'+ 		AllTrim( aAgente[1,4] ) +'</nrLograd>'
							If !lMiddleware .Or. !Empty(aAgente[1,5])
								cXml += '						<bairro>'+ 			AllTrim( aAgente[1,5] ) +'</bairro>'
							EndIf
							cXml += '						<cep>'+ 			AllTrim( aAgente[1,6] ) +'</cep>'
							If !lMiddleware .Or. !Empty(aAgente[1,7])
								cXml += '						<codMunic>'+ Iif(lMiddleware, fEstIBGE(aAgente[1,8]), "") + AllTrim( aAgente[1,7] ) +'</codMunic>'
							EndIf
							cXml += '						<uf>'+ 				AllTrim( aAgente[1,8] ) +'</uf>'
						EndIf
						cXml += '					</ageIntegracao>'
					EndIf

					If ( Len(aCoord) > 0 ) .And. M->RA_CATEFD <> '906'

						cXml += '					<supervisorEstagio>'
						cXml += '						<cpfSupervisor>' + AllTrim( aCoord[1,1] ) + '</cpfSupervisor>'
						If cVersEnvio < "9.0"
							cXml += '						<nmSuperv>' +      AllTrim( aCoord[1,2] ) + '</nmSuperv>'
						EndIf
						cXml += '					</supervisorEstagio>'
					EndIf
					cXml += '				</infoEstagiario>'
				EndIf
				cXml += '				</infoComplementares>'

				If lNovoCPF
					cXml += '			<mudancaCPF>'
					cXml += '				<cpfAnt>'	+ RJI->RJI_CPFA + '</cpfAnt>'
					If cVersEnvio >= "9.0" .And. cGeraMat == "1"
						cXml += '				<matricAnt>'	+ M->RA_CODUNIC + '</matricAnt>'
					EndIf
					cXml += '				<dtAltCPF>'	+ DtoS(RJI->RJI_DTEF) + '</dtAltCPF>'
					If !Empty(RJI->RJI_OBS)
						cXml += '				<observacao>'+ RJI->RJI_OBS+ '</observacao>'
					EndIf
					cXml += '			</mudancaCPF>'
				EndIf

				If ( cVersEnvio >= "2.4" )
					//AFASTAMENTO
					If Len(aAfastam) > 0
						cXml += '			<afastamento>'
						If !lMiddleware
							cXml += '				<dtIniAfast>'	+ aAfastam[1,1]	+ '</dtIniAfast>'
						Else
							cXml += '				<dtIniAfast>' + SubStr( aAfastam[1,1], 1, 4 ) + "-" + SubStr( aAfastam[1,1], 5, 2 ) + "-" + SubStr( aAfastam[1,1], 7, 2 ) + '</dtIniAfast>'
						EndIf
						cXml += '				<codMotAfast>'	+ aAfastam[1,2]	+ '</codMotAfast>'
						cXml += '			</afastamento>'
					Endif

					//TERMINO
					If !Empty(M->RA_DEMISSA) .And. !lGpa180
						cXml += '			<termino>'
						If !lMiddleware
							cXml += '				<dtTerm>'	+ AllTrim( DtoS(M->RA_DEMISSA) ) + '</dtTerm>'
						Else
							cXml += '				<dtTerm>'	+ SubStr( dToS(M->RA_DEMISSA), 1, 4 ) + "-" + SubStr( dToS(M->RA_DEMISSA), 5, 2 ) + "-" + SubStr( dToS(M->RA_DEMISSA), 7, 2 ) + '</dtTerm>'
						EndIf
						cXml += '			</termino>'
					EndIf
				EndIf
				cXml += '			</infoTSVInicio>'
				cXml += '		</evtTSVInicio>'
				cXml += '</eSocial>'
			Else
				lGravou := .F.
				// "Atencao""Categoria não pode ser branca"
				Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0064), 1, 0 )
			EndIf
			//Fim do XML

			//Realiza geração de XML na System
			GrvTxtArq(alltrim(cXml), cReg)
		EndIf

		If Len(GetAPOInfo("TafTransfTrab.prw")) > 0
			lTAFTransf := .T. //Indica que o TAF está atualizado com a refatoração da transferência.
		EndIf

		if lGravou .Or. lMiddleware
			If !lMiddleware
				//Enviar como parametro a filial do Protheus na posição 1 e o XML na posição 2
				If !Empty(cEmpP)
					aErros := TafPrepInt(cEmpAnt, cFilEnv, cXml,, "1", cReg,,,,,, "GPE", cTFilial,,, Iif(cEmpP <> cEmpAnt .And. lTAFTransf, cEmpP, Nil))
				ElseIf lTAFTransf
					aErros := TafPrepInt(cEmpAnt, cFilEnv, cXml,, "1", cReg,,,,,,"GPE", If(lGpa180, cTFilial, cFilDe),,, If(lGpa180,cEmpAnt,""))
				Else
					aErros := TafPrepInt(cEmpAnt, If(lGpa180, cTFilial, cFilEnv), cXml,, "1", cReg,,,,,,"GPE", cFilDe)
				Endif

			ElseIf Len(aErros) == 0
				If cEFDAviso != "2"
					//S-1005
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1005" + Padr(cFilAnt+cInscr, 40, " ")
					cStatus 	:= "-1"
					//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
					fVldPred( If( lMsgHlp, AnoMes(M->RA_ADMISSA),), @cStatus, cChaveMid )
					If cStatus != "4"
						lS1005 := .F.
						Do Case
							Case cStatus == "-1" // nao encontrado na base de dados
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX não localizado na base de dados"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0130)//"Registro do evento X-XXXX não localizado na base de dados"
								EndIf
							Case cStatus == "1" // nao enviado para o governo
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX não transmitido para o governo"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0131)//"Registro do evento X-XXXX não transmitido para o governo"
								EndIf
							Case cStatus == "2" // enviado e aguardando retorno do governo
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
								EndIf
							Case cStatus == "3" // enviado e retornado com erro
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp := OemToAnsi(STR0129) + "S-1005" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
								EndIf
						EndCase
					EndIf
					//S-1030/S-1040
					If lCargSQ3
						If !Empty(cChaveS1030)
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(cChaveS1030, 40, " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							fVldPred( If( lMsgHlp, AnoMes(M->RA_ADMISSA),), @cStat1030, cChaveMid )
							If cStat1030 != "4"
								lS1030 := .F.
							EndIf
						EndIf
						If !Empty(cChaveS1040)
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1040" + Padr(cChaveS1040, 40, " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							fVldPred( If( lMsgHlp, AnoMes(M->RA_ADMISSA),), @cStatus, cChaveMid )
							If cStatus != "4"
								lS1040 := .F.
							EndIf
						EndIf
					Else
						If !Empty(cChaveS1030)
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(cChaveS1030, 40, " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							fVldPred( If( lMsgHlp, AnoMes(M->RA_ADMISSA),), @cStat1030, cChaveMid )
							If cStat1030 != "4"
								lS1030 := .F.
							EndIf
						EndIf
					EndIf
					If !lS1030
						Do Case
							Case cStat1030 == "-1" // nao encontrado na base de dados
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX não localizado na base de dados"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0130)//"Registro do evento X-XXXX não localizado na base de dados"
								EndIf
							Case cStat1030 == "1" // nao enviado para o governo
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX não transmitido para o governo"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0131)//"Registro do evento X-XXXX não transmitido para o governo"
								EndIf
							Case cStat1030 == "2" // enviado e aguardando retorno do governo
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
								EndIf
							Case cStat1030 == "3" // enviado e retornado com erro
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
								EndIf
						EndCase
					EndIf
					If !lS1040
						Do Case
							Case cStatus == "-1" // nao encontrado na base de dados
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX não localizado na base de dados"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0130)//"Registro do evento X-XXXX não localizado na base de dados"
								EndIf
							Case cStatus == "1" // nao enviado para o governo
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX não transmitido para o governo"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0131)//"Registro do evento X-XXXX não transmitido para o governo"
								EndIf
							Case cStatus == "2" // enviado e aguardando retorno do governo
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
								EndIf
							Case cStatus == "3" // enviado e retornado com erro
								If cEFDAviso == "1"
									aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
								ElseIf lMsgHlp .And. lMostraHlp
									cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
								EndIf
						EndCase
					EndIf
				EndIf
				If cEFDAviso $ "0/2" .Or. (lS1005 .And. lS1030 .And. lS1040)
					If !Empty(cMsgHlp)
						Help( ,, OemToAnsi(STR0001) ,, cMsgHlp, 1, 0 )
					EndIf
					If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2300 ))
						aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravação do registro na tabela RJE"
					EndIf
				ElseIf cEFDAviso == "1"
					If Len(aErros) > 0
						For nI := 1 To Len(aErros)
							cMsgHlp += aErros[nI] + CRLF
						Next
						aErros[1] := cMsgHlp
						aSize(aErros, 1)
					EndIf
				EndIf
			EndIf
			If Len( aErros ) > 0
				IF lMsgHlp .And. lMostraHlp
					If !lMiddleware
						Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + aErros[1], 1, 0 )//" não enviado(a) ao TAF. Erro: "
					Else
						Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + aErros[1], 1, 0 )//" não enviado(a) ao Middleware. Erro: "
					EndIf
				ENDIF
				//"ATENCAO"##"""Funcionário: "##" não enviado(a) ao TAF. Erro: "
				lGravou := .F.
			EndIf
		EndIf
	EndIf

End Transaction

If lMiddleware .And. !lGpa180
	fPosFil( cEmpAnt, cBkpFil )
EndIf

RestArea(aArea)

Return lGravou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    fCar2300New³ Autor ³ Eduardo Vicnete       ³ Data ³13/04/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga S-2300- Trabalhadores sem Vinculo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fCargVI()                                             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fCar2300New(nPar1, aLogProc, nPar2, aDados, aPar3, nPar4, cVersEnvio, nRetifica)

Local aArea		 	:= GetArea()
Local cAliasSRA 	:= GetNextAlias()

Local nPosInstr	:= 0
Local nTpRegTrab	:= 0
Local nI			:= 0
Local nK			:= 0
Local nHrInicio
Local nContador	:= 0
Local nContErr	:= 0
Local nIni		:= 1
Local nX 			:= 0
Local nHrFim

Local cAliasfun 	:= "SRA"
Local aAreaQuery 	:= ""
Local nOpcaP 		:= ""
Local dDataRefP 	:= ""
Local cDadosFunc
Local cFilEnv    	:= ""
Local cTrabSVinc	:= "201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903"
Local cSitQuery		:= "%"
Local cVerbQry		:= ""
Local lGeraTAF		:= .T.
Local lDataDBF		:= .F.
Local lGravaOpc		:= .T.
Local lOk				:= .F.
Local lFilFuncao 		:= .T.
Local aErros 		:= {}
Local aAuxDados := {}
Local aConcat		:= {}
Local aFilial		:= {}
Local aArrayFil 	:= {}
Local cCatTSV		:= "701|711|712|741|"
Local cStatTAF		:= ""
Local lValidInt		:= .F.
Local cBkpFil		:= cFilAnt
Local cFuncTSV		:= SuperGetMV("MV_NTSV",nil,"")
Local cQryTSV		:= ""
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0
Local cGeraMat		:= If( lGeraMat, '%, RA_DESCEP %', '%%')
Local cTpInsc		:= ""
Local lAdmPubl      := .F.
Local cNrInsc		:= ""
Local cChaveMid		:= ""
Local cChv2300		:= ""
Local cRetf2300		:= "1"
Local cStatus 		:= "-1"
Local aInfoC		:= {}

Default cSituacao 	:= " ADFT"
Default nPar1 		:= ""
Default nPar2 		:= date()
Default aPar3 		:= {}
Default nPar4 		:= 1
Default cVersEnvio 	:= "2.2"
Default nRetifica	:= 2

nOpcaP := nPar1
dDataRefP := nPar2
aFilTAF := fGM23Fil(aPar3,nPar4)
cFilEnv := aPar3[nPar4,2]

Aadd(aFilial,{aPar3,aArrayFil,cFilEnv})

//-- Modifica variaveis para a Query
If Len(cSit2300) > 0
    cSitQuery:= fSqlIN( cSit2300, 1 )
    cSitQuery:="%"+cSitQuery+"%"
Else
    cSitQuery += "'*'%"
EndIf

if Empty(cCatEfd2300)
    cCatEfd2300:= StrTran(cTrabSVinc,"|","")
EndIF

//-- Modifica variaveis para a Query
If Len(cCatEfd2300) > 0
    cVerbQry:= fSqlIN( cCatEfd2300, 3 )
Else
    cVerbQry += "'*'"
EndIf

IF !EMPTY(cfuncTSV)
	cQryTSV := "AND SRA.RA_CATEFD NOT IN (" + fSqlIN( StrTran(cfuncTSV,"/",""), 3 ) + ")"
ENDIF

nI  := 0
lOk := .T.
cVerbQry:= "%"+cVerbQry+"%"
cQryTSV:= "%"+cQryTSV+"%"

If  lOk
	//Pre-Cargas
	nHrInicio := Seconds()

	#IFDEF TOP
		//Query para buscar informacoes Trabalhadores
		BeginSql alias cAliasSRA
			SELECT
				RA_FILIAL, RA_MAT, RA_CIC, RA_PIS, RA_NOMECMP, RA_NOME, RA_SEXO,
				RA_RACACOR, RA_ESTCIVI, RA_GRINRAI,
				RA_NASC, RA_CODMUNN, RA_NATURAL, RA_CPAISOR, RA_NACIONC,
				RA_MAE, RA_PAI, RA_NUMCP, RA_SERCP, RA_UFCP,
				RA_NUMRIC,RA_EMISRIC , RA_DEXPRIC, RA_RG, RA_RGEXP,RA_DTRGEXP,
				RA_RNE, RA_RNEORG, RA_RNEDEXP, RA_CODIGO, RA_OCEMIS, RA_OCDTEXP, RA_OCDTVAL,
				RA_HABILIT, RA_CNHORG, RA_CATCNH, RA_UFCNH, RA_DTEMCNH, RA_DTVCCNH, RA_RESEXT,
				RA_LOGRTP, RA_LOGRDSC, RA_LOGRNUM,RA_COMPLEM, RA_BAIRRO, RA_CEP, RA_CEPCXPO,
				RA_PAISEXT, RA_CODMUN, RA_ESTADO, RA_MUNICIP,RA_CPOSTAL,
				RA_TELEFON, RA_DDDFONE, RA_NUMCELU, RA_DDDCELU,
				RA_DATCHEG, RA_DATNATU, RA_CASADBR, RA_FILHOBR,
				RA_PORTDEF, RA_EAPOSEN, RA_TPDEFFI, RA_CLASEST, RA_EMAIL, RA_EMAIL2,
				RA_ADMISSA, RA_DEMISSA, RA_VIEMRAI,RA_TPPREVI,
				RA_TPJORNA, RA_TNOTRAB, RA_REGRA, RA_SEQTURN,
				RA_CATEFD, RA_TIPOADM, RA_SITFOLH, RA_HOPARC,
				RA_CODFUNC, RA_CARGO, RA_SALARIO, RA_CATFUNC, RA_TPCONTR, RA_DTFIMCT, RA_CTPCD,
				RA_CC, RA_HRSEMAN, RA_NJUD14, RA_ALTOPC, RA_OPCAO, RA_SINDICA, RA_CODUNIC,RA_NSOCIAL %exp:cGeraMat%
			FROM
				%table:SRA% SRA
			WHERE
				SRA.RA_FILIAL IN(%exp:aFilTAF[1]%) AND
				SRA.RA_FILIAL >= (%exp: cFilDe2300%) AND SRA.RA_FILIAL <= (%exp: cFilAte2300%)
				AND SRA.RA_MAT >= (%exp: cMatDe2300%) AND SRA.RA_MAT <= (%exp: cMatAte2300%)
				AND SRA.RA_CC >= (%exp: cCCDe2300%) AND SRA.RA_CC <= (%exp: cCCAte2300%)
				AND SRA.RA_SITFOLH IN ( %exp:cSitQuery% )
				AND SRA.RA_CATEFD IN ( %exp:cVerbQry% )
				%exp:cQryTSV%
				AND SRA.%notDel%
			ORDER BY
	   			SRA.RA_FILIAL, SRA.RA_MAT
		EndSql

		dbSelectArea(cAliasSRA)
		lPosVarAux    := .T.
	#ELSE
		cAliasSRA := "SRA"
		dbSelectArea(cAliasSRA)
		lDataDBF := .T.
	#ENDIF

	//Posiciona no inicio do arquivo
	(cAliasSRA)->(dbGoTop())
	nK := 0

	While (cAliasSRA)->(!EOF())
		ProcRegua(nK++)
		lGeraTAF := .F.
		If  Alltrim((cAliasSRA)->RA_FILIAL) $ aFilTAF[2] .AND. ;
			(!(Empty((cAliasSRA)->RA_CIC)) .AND. !(Empty((cAliasSRA)->RA_PIS)) .AND.;
			(!(Empty((cAliasSRA)->RA_NOMECMP)) .OR. !(EMPTY((cAliasSRA)->RA_NOME))) .AND.;
			!(Empty((cAliasSRA)->RA_SEXO)) .AND. !(Empty((cAliasSRA)->RA_RACACOR)) .AND. ;
			!(Empty((cAliasSRA)->RA_GRINRAI)) .AND.;
			!(Empty((cAliasSRA)->RA_NASC)) .AND. !(Empty((cAliasSRA)->RA_CPAISOR)) .AND. ;
			!(Empty((cAliasSRA)->RA_NACIONC)) .AND. ;
			!(Empty((cAliasSRA)->RA_ADMISSA)) .AND. !(Empty((cAliasSRA)->RA_VIEMRAI)) .AND. ;
			!(Empty((cAliasSRA)->RA_TPPREVI)) .AND. ;
			!(Empty((cAliasSRA)->RA_TPJORNA)) .AND. ;
			!(Empty((cAliasSRA)->RA_CODFUNC)) .AND. ;
			!(Empty((cAliasSRA)->RA_CATFUNC)) .AND. !(Empty((cAliasSRA)->RA_TPCONTR)) .AND. ;
			!(Empty((cAliasSRA)->RA_CC)) .AND. ;
			!(Empty((cAliasSRA)->RA_ESTCIVI)) .AND. ;
			!(Empty((cAliasSRA)->RA_OPCAO)) .AND. ;
			(cAliasSRA)->RA_ESTCIVI $ GpeEstCivi("3") .AND. (cAliasSRA)->RA_CATEFD $ cVerbQry)
			If nOpcAP == 1
				lGeraTAF := .T.
			EndIf
		EndIf

		If lPosVarAux
			//na funcao fG17VSRA sistema carrega o conteúdo do ponteiro SRA para a memória, mas no caso da query ter sido aberta com um Alias Auxiliar, o SRA oficial não estara posicionado
			dbselectArea(cAliasFun)
			DbSetOrder( 1 )
			DbSeek((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT)
		EndIf

		//Consistir os parâmetros informados
		If !Empty(cCCAte2300)
			If (cAliasSRA)->RA_CC < cCCDe2300	 .Or. (cAliasSRA)->RA_CC > cCCAte2300
				(cAliasSRA)->(DBSKIP())
				Loop
			Endif
		Endif
		If !Empty(cNomeAte2300)
			If (cAliasSRA)->RA_NOME < cNomeDe2300 .Or. (cAliasSRA)->RA_NOME > cNomeAte2300
				(cAliasSRA)->(DBSKIP())
				Loop
			Endif
		Endif
		If !Empty(cMatAte2300)
			If (cAliasSRA)->RA_MAT < cMatDe2300 .Or. (cAliasSRA)->RA_MAT > cMatAte2300
				(cAliasSRA)->(DBSKIP())
				Loop
			Endif
		Endif
		If !Empty(cFilAte)
			If (cAliasSRA)->RA_FILIAL < cFilDe2300 .Or. (cAliasSRA)->RA_FILIAL > cFilAte2300
				(cAliasSRA)->(DBSKIP())
				Loop
			Endif
		Endif

		lValidInt:= .T.
		aAuxDados:= {}
		lGeraTAF := fG17VSRA(cAliasSRA, 2,/*nopc*/,@aAuxDados, cVersEnvio)

		cFilAnt   := (cAliasSRA)->RA_FILIAL

		cGeraMat := If(lGeraMat, (cAliasSRA)->RA_DESCEP, "0")

		If lMiddleware
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

			cChv2300	:= If( cVersEnvio >= "9.0" .And. cGeraMat == "1", SRA->RA_CODUNIC, AllTrim(SRA->RA_CIC) + AllTrim(SRA->RA_CATEFD) + DTOS(SRA->RA_ADMISSA) )
			cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cChv2300, fTamRJEKey(), " ")
			cStatus 	:= "-1"
			cStat1 		:= "-1"
			cRetf2300	:= "1"
			GetInfRJE( 2, cChaveMid, @cStatus, ,@cRetf2300 )
			cStatTAF := cStatus
		Else
			If cVersEnvio >= "9.0"
				cChv2300 := AllTrim( SRA->RA_CIC ) + ";" + If(cGeraMat == "1", SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
			Else
				cChv2300 := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
			EndIf
			cStatTAF  := TAFGetStat( "S-2300", cChv2300 )
			cFilAnt   := cBkpFil
		EndIf

		If lGeraTaf .And. (cStatTAF != "4" .Or. (cStatTAF == "4" .And. nRetifica == 1))
			If cVersEnvio >= "9.0"
				If cStatTAF != "4" .And. ( (lMiddleware .And. cRetf2300 <>"2") .Or. (!lMiddleware .And. Empty(C9V->C9V_VERANT)) )
					cGeraMat := "1"
				ElseIf Empty(cGeraMat)
					cGeraMat := "0"
				EndIf
			EndIf
			lRet := fInt2300New(cAliasSRA,,3,,,,cVersEnvio,,,@aErros,aFilial,,,,,,cGeraMat)
			If lRet .And. cVersEnvio >= "9.0" .And. lGeraMat .And. SRA->RA_DESCEP <> cGeraMat
				Reclock("SRA",.F.)
					SRA->RA_DESCEP := cGeraMat
				SRA->(MsUnLock())
			EndIf
		EndIf

		cDadosFunc := OemToAnsi(STR0065) + " " + (cAliasSRA)->RA_FILIAL + "/" + (cAliasSRA)->RA_MAT + " - " + OemToAnsi(STR0066) +": " + Alltrim((cAliasSRA)->RA_CIC) + " - " + Alltrim((cAliasSRA)->RA_NOMECMP) //"Filial/Mat:"#"CPF"

		If cStatTAF == "4" .And. nRetifica == 2
			nContErr++
			cDadosFunc := PADR(OemToAnsi(STR0076), 15)+ PADR(cDadosFunc, 77)+" "+PADR(OemToAnsi(STR0094), 33) //"Trabalhador"##"Não foi retificado."
			aAdd(aDados,cDadosFunc)
		ElseIf cStatTAF $ "2/6"
			nContErr++
			cDadosFunc := PADR(OemToAnsi(STR0076), 15)+ PADR(cDadosFunc, 77)+" "+PADR(OemToAnsi(STR0173), 33) //"Trabalhador"##"Está em trânsido ao RET."
			aAdd(aDados,cDadosFunc)
		ElseIf lGeraTaf
			if Len(aErros)==0
				If !lMiddleware
					cDadosFunc:= PADR(OemToAnsi(STR0076), 15)+ PADR(cDadosFunc, 77)+" "+PADR(OemToAnsi(STR0074), 33) //"Trabalhador"#"Enviada ao TAF com sucesso."
				Else
					cDadosFunc:= PADR(OemToAnsi(STR0076), 15)+ PADR(cDadosFunc, 77)+" "+PADR(OemToAnsi(STR0162), 33) //"Trabalhador"#"Enviada ao Middleware com sucesso."
				EndIf
				nContador++
			Else
			//Le o erro e quebra num array de acordo com a quantidade de enter
				If !lMiddleware
					cDadosFunc:= PADR(OemToAnsi(STR0076), 15)+ PADR(cDadosFunc, 77)+" "+PADR(OemToAnsi(STR0075), 33) //"Trabalhador"#"Não enviado ao TAF."
				Else
					cDadosFunc:= PADR(OemToAnsi(STR0076), 15)+ PADR(cDadosFunc, 77)+" "+PADR(OemToAnsi(STR0163), 33) //"Trabalhador"#"Não enviado ao Middleware."
				EndIf

				aConcat := StrTokArr(aErros[1], chr(13)+chr(10))
				nContErr++
			EndIf
			aAdd(aDados,cDadosFunc)
			if Len(aConcat)>0
				For nX := 1 To len(aConcat)
					aAdd(aDados, aConcat[nX] )
				Next
			EndIf
		Else
			nContErr++
			If !lMiddleware
				cDadosFunc := PADR(OemToAnsi(STR0076), 15)+ PADR(cDadosFunc, 77)+" "+PADR(OemToAnsi(STR0075), 33) //"Trabalhador"#"Não enviado ao TAF."
			Else
				cDadosFunc := PADR(OemToAnsi(STR0076), 15)+ PADR(cDadosFunc, 77)+" "+PADR(OemToAnsi(STR0163), 33) //"Trabalhador"#"Não enviado ao Middleware."
			EndIf

			If (AllTrim( SRA->RA_CATEFD ) $ cCatTSV)
				cDadosFunc := Alltrim(cDadosFunc) + STR0093 // ". Não impede a geração do S-1200/S-1210"
			Endif

			aAdd( aDados,cDadosFunc)

   			//Atribui o erro no aDados para impressão em tela
   			For nX := 1 To len(aAuxDados)
	   			aAdd(aDados, aAuxDados[nX] )
	   		Next
	   		aAdd(aDados, "" )
		EndIF

		//Incrementa regua
		IncProc(OemToAnsi(STR0067) + " " +(cAliasSRA)->RA_FILIAL+ "-" +(cAliasSRA)->RA_MAT) //##"Gerando o registro de: "

		(cAliasSRA)->(DBSKIP())
	EndDo

	If nK > 0 .And. lValidInt
		aAdd(aDados,"")
		aAdd(aDados,(OemToAnsi(STR0068)+" "+ OemToAnsi(STR0069) + " " + OemToAnsi(STR0070) ))	//"Resumo" ###"Carga Inicial" "Trabalhador"
		aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))							//Inicio Processamento: A
		nHrFim := SecsToTime(Seconds())
		aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim)											//Fim Processamento:    A
		aAdd(aDados,"")
		aAdd(aDados,OemToAnsi(STR0071)+": " + SecsToTime(Seconds() - nHrInicio))		//Duracao do Processamento

		If !lMiddleware
			aAdd(aDados,OemToAnsi(STR0072)+": "+ ALLTRIM(STR(nContador)))						//Quantidade Registro(s) enviado(s) ao TAF
			aAdd(aDados,OemToAnsi(STR0073)+": "+ ALLTRIM(STR(nContErr)))						//Quantidade Registros Não Enviados ao TAF
		Else
			aAdd(aDados,OemToAnsi(STR0160)+": "+ ALLTRIM(STR(nContador)))						// "Quantidade Registro(s) enviado(s) ao Middleware"
			aAdd(aDados,OemToAnsi(STR0161)+": "+ ALLTRIM(STR(nContErr)))						// "Quantidade Registros Não Enviados ao Middleware"
		EndIf

		aAdd(aDados,"")
		aAdd(aDados,"")
	EndIf
EndIf

RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  fInt2306New ºAutor  ³Marcos Coutinho      º Data ³  12/05/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Registro Alteracao Contratal do evento S-2306              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fInt2306New(cAliasSRA, lAltCad, nOpca,cReg,cTFilial,dtEf,cVersEnvio,lCadEst, oMdlRFS, lTransf, dDtAlt, lDataAlt, aErros, lMsgHlp)
Local aArea		 	:= GetArea()
Local aAreaRBW		:= RBW->(GetArea())
Local aAreaSR6
Local cFilEnv    	:= ""
Local aErros 		:= {}
Local cEstCivi		:= GpeEstCivi("2")
Local aEstCivi		:= GpeEstCivi("1")
Local nPosEC 		:= 0
Local aRacaCor		:= {{'2','1'},{'4','2'},{'8','3'},{'6','4'},{'1','5'},{'9','6'}}
Local nRacaCor 		:= 0
Local aInstrucao	:= {{'10','01'},{'20','02'},{'25','03'},{'30','04'},{'35','05'},{'40','06'},{'45','07'},;
							 {'50','08'},{'55','09'},{'65','11'},{'75','12'},{'85','10'},{'95','12'}}
Local nPosInstr		:= 0
Local aTpRegTrab	:= {{'30'},{'31'}, {'35'}}
Local nTpRegTrab	:= 0
Local aPagoFixo		:= GpeUndSalFixo ()
Local nPagoFixo		:= 0
Local aCatCNH		:= {{'1','A'},{'2','B'},{'3','C'},{'4','D'},{'5','E'},{'6','AB'},{'7','AC'},{'8','AD'},{'9','AE'}}
Local nPosCCNH		:= 0
Local aCargo		:= {}
Local nPosSQ3CC		:= 0
Local nPosSQ3sCC	:= 0
Local aVinculoT		:= {}
Local aEstagio		:= {}
Local aInstit		:= {}
Local aCoord		:= {}
Local aAgente		:= {}
Local aAso			:= {}
Local nI			:= 0
Local aSind			:= {}
Local aCC			:= {}
Local nPosLot		:= 0
Local nPosSind		:= 0
Local nTotVinc		:= 0
Local lDataDBF		:= .F.
Local dOpcao
Local dAdmissao
Local lGravaOpc		:= .T.
Local nPosEstb		:= 0
Local aEstb			:= {}
Local aRet			:= {}
Local aFilInTaf 	:= {}
Local aArrayFil 	:= {}
Local lMemo			:= .F.
Local aTurno		:= {}
Local nPosTurno		:= 0
Local cTpInscr		:= ""
Local cInscr		:= ""
Local cNomTrab		:= ""
Local cNomAux		:= ""
Local cXml			:= ""
Local cObsDef		:= ""
Local cObsVinc		:= ""
Local cFonePrinc	:= ""
Local cFoneAltern	:= ""
Local cMotSubs		:= ""
Local cCPFSubs		:= ""
Local cMatrSubs		:= ""
Local cCCSubs		:= ""
Local cTurno		:= ""
Local lTpJorn		:= .T.
Local cDescJorn		:= ""
Local cTpJorn		:= ""
Local lFilFuncao 	:= .T.
Local lFilCargo 	:= .T.
Local CodUnico		:= ""
Local dDataRefP 	:= CTOD("")
Local cDia 			:= ""
Local cSalario		:= ""
Local cIntegra		:= ""
Local aAreaRFS		:= RFS->(GetArea())
Local aAreaRA0		:= RA0->(GetArea())
Local aAreaQuery	:= ""
Local cCatEFD		:= ""
Local lGravou		:= .T.
Local cMsgErro		:= ""
Local cFilTrab		:= If(Empty((cAliasSRA)->RA_FILIAL) , cFilAnt, (cAliasSRA)->RA_FILIAL )
Local lDesRem     	:= SRA->(ColumnPos("RA_DESEPS")) > 0
Local cCatAux		:= "201|202|305|721|722|731|734|738|761|"
Local cPgtoTrab		:= ""
Local cDataAlt		:= ""
Local lCBOCargo		:= .F.
Local lCBOFuncao	:= .F.
Local lEstag		:= .F.
Local cMsgEstag1	:= ""
Local cMsgEstag2	:= ""

Local cEFDAviso		:= Alltrim(FSubst(If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")))) //Integracao com TAF)
Local cBkpFil	 	:= cFilAnt
Local cVersMw	 	:= ""
Local cXml		 	:= ""
Local cMsg		 	:= ""
Local cMsgErro	 	:= ""
Local cChave		:= ""
Local cChaveS1030	:= ""
Local cChaveS1040	:= ""
Local cStatus	 	:= "-1"
Local cStat1030	 	:= "-1"
Local cMsgHlp	 	:= ""
Local cMsgRJE	 	:= ""
Local lAdmPubl	 	:= .F.
Local aInfos	 	:= {}
Local aDados	 	:= {}
Local cFilEmp	 	:= ""
Local cHrGer	 	:= Time()
Local lRet		 	:= .T.
Local cRetfNew	 	:= ""
Local cOperNew 	 	:= ""
Local cStatRJE	 	:= "-1"
Local cOper2306	 	:= "I"
Local cRecib2306 	:= ""
Local cRecibAnt  	:= ""
Local cRecibXML  	:= ""
Local cRetf2306	 	:= "1"
Local cStat2306	 	:= "-1"
Local nRec2306   	:= 0
Local cRetfNew	 	:= ""
Local cStatNew	 	:= ""
Local lNovoRJE	 	:= .F.
Local lS1000 	 	:= .T.
Local lS1030 	 	:= .T.
Local lS1040 	 	:= .T.
Local nOpcAx	 	:= 0
Local cFilEstag		:= ""
Local lCargSQ3		:= SuperGetMv("MV_CARGSQ3",,.F.) //Define se o envio do evento S-1030 serão feito pela tabela SQ3 e não pela SRJ (Padrão .F. -> SRJ).
Local cDescFC		:= ""
Local cCboFC		:= ""
Local cGeraMat		:= If( SRA->(ColumnPos("RA_DESCEP")) > 0, (cAliasSRA)->RA_DESCEP, "" )

Default lAltCad		:= .F.
Default nOpca		:= 0
Default cReg		:= "S2306"
Default cTFilial	:= ""
Default cVersEnvio	:= "2.2"
Default lCadEst		:= .F.
Default oMdlRFS		:= Nil
Default lTransf		:= .F.
Default dDtAlt		:= Nil
Default lDataAlt	:= .F.
Default aErros		:= {}
Default lMsgHlp		:= .T.

cDataAlt	:= DTOS( IIF(dDtAlt != NIL .And. lDataAlt, dDtAlt, IIF(M->RA_SITFOLH == "D" .And. dDataBase > (cAliasSRA)->RA_DEMISSA, (cAliasSRA)->RA_DEMISSA, dDataBase )))

// RECEBE O VALOR VINDO COMO PARAMETRO.
nOpcAx		:= nOpca

If !lMiddleware
	fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
EndIf

If Empty(cFilEnv)
	cFilEnv:= cFilAnt
EndIf

If lMiddleware
	fVersEsoc( "S2306", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw )
	fPosFil( cEmpAnt, cFilEnv )
	lS1000 := fVld1000( SubStr(cDataAlt, 1, 6), @cStatus )
	If !lS1000 .And. cEFDAviso != "2"
		Do Case
			Case cStatus == "-1" // nao encontrado na base de dados
				If cEFDAviso == "1"
					aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX não localizado na base de dados"
				ElseIf lMsgHlp
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX não localizado na base de dados"
				EndIf
			Case cStatus == "1" // nao enviado para o governo
				If cEFDAviso == "1"
					aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX não transmitido para o governo"
				ElseIf lMsgHlp
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX não transmitido para o governo"
				EndIf
			Case cStatus == "2" // enviado e aguardando retorno do governo
				If cEFDAviso == "1"
					aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
				ElseIf lMsgHlp
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
				EndIf
			Case cStatus == "3" // enviado e retornado com erro
				If cEFDAviso == "1"
					aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
				ElseIf lMsgHlp
					Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
				EndIf
		EndCase
	EndIf
EndIf

dDataRefP := Date()

lFilFuncao	:= fGM23Func()
lFilCargo	:= fGM23Func("SQ3")
aSind		:= fGM23Sind()
aCC			:= fGM23CTT()
aEstb		:= fGM23SM0(.T.,.T.)

lMemo		:= .F.

Begin Transaction

	//CATEGORIA DO FUNCIONARIO
	If(FunName() == "GPEA020")
		RegToMemory("SRA",,,.F.)
	EndIf

	cCatEFD := M->RA_CATEFD

	//TRABALHADOR
	cNomAux  := IIF(!EMPTY(ALLTRIM(M->RA_NOMECMP)),SUBSTR(M->RA_NOMECMP,1,60),ALLTRIM(M->RA_NOME) )
	cNomTrab := FSubst(cNomAux)
	nPosEC	  := aScan(aEstCivi,{|x| Alltrim(x[1]) == M->RA_ESTCIVI})
	nPosInstr := aScan(aInstrucao,{|x| Alltrim(x[1]) == M->RA_GRINRAI})
	nPosRacaCor	  := aScan(aRacaCor,{|x| Alltrim(x[1]) == M->RA_RACACOR})

	//NASCIMENTO
	cPais	  := fM23Pais(ALLTRIM(M->RA_CPAISOR))

	//DOCUMENTOS
	nPosCCNH  := aScan(aCatCNH,{|x| Alltrim(x[1]) == M->RA_CATCNH})

	//INFO DEFICIÊNCIA
	If !EMPTY(M->RA_OBSDEFI)
		lMemo 	:= .T.
		cObsDef	:= ALLTRIM(M->RA_OBSDEFI)
	EndIf

	//CONTATO
	If !Empty(M->RA_DDDFONE)
		cFonePrinc := ALLTRIM(M->RA_DDDFONE) + SUBSTR(M->RA_TELEFON,1,11)
		Else
			If !Empty( M->RA_TELEFON )
				cFonePrinc := SUBSTR(M->RA_TELEFON,1,13)
			EndIf
		EndIf
		cFonePrinc := AllTrim(StrTran(StrTran(cFonePrinc, "-",""), ".",""))

		If !Empty(M->RA_DDDCELU)
			cFoneAltern := ALLTRIM(M->RA_DDDCELU) + SUBSTR(M->RA_NUMCELU,1,11)
		Else
			If !Empty( M->RA_NUMCELU )
				cFoneAltern := SUBSTR(M->RA_NUMCELU,1,13)
			EndIf
		EndIf
		cFoneAltern := AllTrim(StrTran(StrTran(cFoneAltern, "-",""), ".",""))

	//VINCULO
	dAdmissao   := M->RA_ADMISSA
	nTpRegTrab	:= aScan(aTpRegTrab,{|x| Alltrim(x[1]) == M->RA_VIEMRAI})
	fGM23Estag(cFilTrab,M->RA_MAT, dDataRefP, @aEstagio, @aInstit, @aAgente, @aCoord, lCadEst, oMdlRFS )
	aVinculoT 	:= fGM23Vinc(cFilTrab, M->RA_MAT, cVersEnvio)

	//FGTS
	If !empty(M->RA_OPCAO)
		lGravaOpc := .T.
		dOpcao := M->RA_OPCAO

		If dAdmissao >= STOD('19881004') .AND. (dAdmissao <> dOpcao)
			dOpcao := dAdmissao
			lGravaOpc := .T.
		EndIf

		If M->RA_CATEFD == '105' .AND. dOpcao < STOD('19980122')
			lGravaOpc := .F.
		EndIf

		If M->RA_CATEFD == '104' .AND. dOpcao < STOD('20000301')
			lGravaOpc := .F.
		EndIf

		If M->RA_CATEFD == '103' .AND. dOpcao < STOD('20001220')
			lGravaOpc := .F.
		EndIf

		If dOpcao < STOD('19670101')
			lGravaOpc := .F.
		EndIf

		//Optante pelo FGTS
		If 	dOpcao >= STOD('19881004')
			nOptante:= '1'
		Else
			nOptante := IIf(M->RA_ALTOPC=='S','1','2')
		EndIf
	EndIf

	//TRABALHO TEMPORARIO

	//----------------------------
	//| REMUNERACAO
	//| Realizando a lógica do Cálculo de Salário
	//--------------------------------------------
	cPgtoTrab := fGetTpPagto(M->RA_TIPOPGT, M->RA_CATFUNC, fGetValCpo( "RA_SALARIO" ) )

	//LOCAL DE TRABALHO - conforme leiaute sempre levar do estabalecimento que esta vinculado
	//por isso retirado o controle por cento vamos sempre gerar pela Filial
	cTpInscr	:= ""
	cInscr		:= ""

	If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
		if empty(cTFilial)
			nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cFilTrab)})
		else
			nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cTFilial)})
		Endif
		If nPosEstb > 0
			cTpInscr	:= aEstb[nPosEstb,3]
			cInscr		:= aEstb[nPosEstb,2]
		EndIf
	EndIf

	//TIPO DE JORNADA - HORÁRIO CONTRATUAL
	if Empty((cAliasSRA)->RA_TNOTRAB)
        aTurno    := fGM23Tur("SRA",M->RA_TNOTRAB,M->RA_REGRA, M->RA_SEQTURN, IIF(Empty(cTFilial), cFilTrab,cTFilial), cVersEnvio)

    Else
        aTurno    := fGM23Tur("SRA",,, ,IIF(Empty(cTFilial), cFilTrab,cTFilial), cVersEnvio)
    EndIf
	If  cVersEnvio <= "2.5"
		fGrvHorTAF("SRA",cFilTrab)
	Endif

	//Procura Turno
	cTpJorn := ""
	cDescJorn := ""
	cTurno	:= M->RA_TNOTRAB
	lTpJorn:= fTpJorn(cTurno,@cTpJorn,@cDescJorn,cVersEnvio,cFilTrab)

	//HORARIO CONTRATUAL
	nPosTurno := 0
	If M->RA_TPJORNA $ "1|2|4" .AND. Len(aTurno) > 0 .AND. ;
		(!(EMPTY(M->RA_TNOTRAB)) .AND.  !(EMPTY(M->RA_REGRA)))

		nPosTurno := 1
	EndIf

	If !(EMPTY(cFilEnv))
		//Geração do registro S-2300
		//Início da Geração do XML
		If(cCatEFD $ '201*202*304*305*308*401*410*701*711*712*721*722*723*731*734*738*741*751*761*771*781*901*902*903*906')
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
				If cVersEnvio >= "9.0" .And. cGeraMat == "1"
					cChave := M->RA_CODUNIC
				Else
					cChave := AllTrim( M->RA_CIC ) + AllTrim( M->RA_CATEFD ) + DTOS( M->RA_ADMISSA )
				EndIf
				cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2306" + Padr(cChave, fTamRJEKey(), " ") + Space(6) + cDataAlt
				cStat2306 	:= "-1"
				GetInfRJE( 2, cChaveBus, @cStat2306, @cOper2306, @cRetf2306, @nRec2306, @cRecib2306, @cRecibAnt )

				//Alteração ou exclusão
				If nOpcAx == 4 .Or. nOpcAx == 5
					//Retorno pendente impede o cadastro
					If cStat2306 == "2" .And. cEFDAviso != "2"
						cMsgRJE 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
					EndIf
					//Alteração
					If nOpcAx == 4
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2306 == "E" .And. cStat2306 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						//Não existe na fila, será tratado como inclusão
						ElseIf cStat2306 == "-1"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento sem transmissão, irá sobrescrever o registro na fila
						ElseIf cStat2306 $ "1/3"
							cOperNew 	:= cOper2306
							cRetfNew	:= cRetf2306
							cStatNew	:= "1"
							lNovoRJE	:= .F.
						//Evento diferente de exclusão transmitido, irá gerar uma retificação
						ElseIf cOper2306 != "E" .And. cStat2306 == "4"
							cOperNew 	:= "A"
							cRetfNew	:= "2"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						//Evento de exclusão transmitido, será tratado como inclusão
						ElseIf cOper2306 == "E" .And. cStat2306 == "4"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					//Exclusão
					ElseIf nOpcAx == 5
						//Evento de exclusão sem transmissão impede o cadastro
						If cOper2306 == "E" .And. cStat2306 != "4" .And. cEFDAviso != "2"
							cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
						//Evento diferente de exclusão transmitido irá gerar uma exclusão
						ElseIf cOper2306 != "E" .And. cStat2306 == "4"
							cOperNew 	:= "E"
							cRetfNew	:= cRetf2306
							cStatNew	:= "1"
							lNovoRJE	:= .T.
						EndIf
					EndIf
				ElseIf nOpcAx == 3
					//Retorno pendente impede o cadastro
					If cStat2306 == "2" .And. cEFDAviso != "2"
						cMsgRJE 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
					//Evento de exclusão sem transmissão impede o cadastro
					ElseIf cOper2306 == "E" .And. cStat2306 != "4" .And. cEFDAviso != "2"
						cMsgRJE 	:= STR0135//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
					//Evento sem transmissão, irá sobrescrever o registro na fila
					ElseIf cStat2306 $ "1/3"
						cOperNew 	:= cOper2306
						cRetfNew	:= cRetf2306
						cStatNew	:= "1"
						lNovoRJE	:= .F.
					//Evento diferente de exclusão transmitido, irá gerar uma retificação
					ElseIf cOper2306 != "E" .And. cStat2306 == "4"
						cOperNew 	:= "A"
						cRetfNew	:= "2"
						cStatNew	:=  "1"
						lNovoRJE	:= .T.
					//Será tratado como inclusão
					Else
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						cStatNew	:= "1"
						lNovoRJE	:= .T.
					EndIf
				EndIf
				If !Empty(cMsgRJE)
					If lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0035) + M->RA_MAT + OemToAnsi(STR0137) + CRLF + cMsgRJE, 1, 0 )//" não enviado(a) ao Middleware. Erro: "
					Else
						aAdd( aErros, cMsgRJE )
					EndIf
					DisarmTransaction()
					Return .F.
				EndIf
				If cRetfNew == "2"
					If cStat2306 == "4"
						cRecibXML 	:= cRecib2306
						cRecibAnt	:= cRecib2306
						cRecib2306	:= ""
					Else
						cRecibXML 	:= cRecibAnt
					EndIf
				EndIf
				aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2306", Space(6), cChave, cId, cRetfNew, "12", cStatNew, sToD(cDataAlt), cHrGer, cOperNew, cRecib2306, cRecibAnt } )
				cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTSVAltContr/v" + cVersMw + "'>"
				cXML += 	"<evtTSVAltContr Id='" + cId + "'>"
				fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, 1, 1, "12" } )
				fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
			Else
				cXml += '<eSocial>'
				cXml += '	<evtTSVAltContr>'
			EndIf
			cXml += '		<ideTrabSemVinculo>'
			cXml += '			<cpfTrab>'+ Alltrim( M->RA_CIC ) +'</cpfTrab>'
			If cVersEnvio < "9.0"
				cXml += '			<nisTrab>'+ ALLTRIM(M->RA_PIS) +'</nisTrab>'
			elseIf cGeraMat == "1"
				cXml += '			<matricula>' + Alltrim(M->RA_CODUNIC) + '</matricula>' //matricula só informar se mandou matricula no 2300
			EndIf
			If cVersEnvio < "9.0" .Or. cGeraMat <> "1"
				cXml += '			<codCateg>'+ M->RA_CATEFD +'</codCateg>' //só informar se não mandou matricula no 2300
			EndIf
			cXml += '		</ideTrabSemVinculo>'
			cXml += '		<infoTSVAlteracao>'
			If !lMiddleware
				cXml += '			<dtAlteracao>'+ cDataAlt +'</dtAlteracao>'
			Else
				cXml += '			<dtAlteracao>'+ SubStr( cDataAlt, 1, 4 ) + "-" + SubStr( cDataAlt, 5, 2 ) + "-" + SubStr( cDataAlt, 7, 2 ) +'</dtAlteracao>'
			EndIf
			IF !(cCatEFD $ "305|721|722|771|901")
				cXml += '			<natAtividade>'+IIf(M->RA_VIEMRAI $ ('20|25|70|75'),'2','1') + '</natAtividade>'
			ENDIF
			cXml += '			<infoComplementares>'

			lEstag := M->RA_CATEFD $ '901/903/904/905/906'
			If cVersEnvio >= "9.0"
				fVerifCBO(Iif(Empty(cTFilial), cFilTrab,cTFilial), fGetValCpo( "RA_CARGO" ), fGetValCpo( "RA_CODFUNC" ), @lCBOCargo, @lCBOFuncao, @cDescFC, @cCboFC)
			ElseIf lEstag
				cFilEstag  := IIF(Empty(cTFilial), cFilTrab, cTFilial)
				fEstagCBO(cFilEstag, fGetValCpo( "RA_CARGO" ), fGetValCpo( "RA_CODFUNC" ), @lCBOCargo, @lCBOFuncao)
			Endif

			If (cVersEnvio < "2.4.02" .And. M->RA_CATEFD $ cCatAux) .Or. (cVersEnvio >= "2.4.02" .And. !lEstag .Or. (lEstag .And. (lCBOCargo .Or. lCBOFuncao)))

				cXml += '				<cargoFuncao>'

				If cVersEnvio >= "9.0"
					If (lCBOFuncao .Or. lCBOCargo) .And. M->RA_CATEFD <> '410'
						cXml += '<nmCargo>' + cDescFC + '</nmCargo>'
						cXml += '<CBOCargo>' + cCboFC + '</CBOCargo>'
					ElseIf M->RA_CATEFD $ '410' .And. lCBOFuncao
						cXml += '<nmFuncao>' + cDescFC + '</nmFuncao>'
						cXml += '<CBOFuncao>' + cCboFC + '</CBOFuncao>'
					EndIf
				Else
					If lCargSQ3
						If lFilCargo  .And. ( !lEstag .Or. (lEstag .And. lCBOCargo) )
							cXml += '<codCargo>'  		+ xFilial("SQ3",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CARGO" ) + '</codCargo>'
						ElseIf !lEstag .Or. (lEstag .And. lCBOCargo)
							cXml += '<codCargo>'  		+ fGetValCpo( "RA_CARGO" ) + '</codCargo>'
						Endif
						cChaveS1030 := xFilial("SQ3",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CARGO" )
						If lFilFuncao .And. ( !lEstag .Or. (lEstag .And. lCBOFuncao ))
							cXml += '<codFuncao>'  		+ xFilial("SRJ",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CODFUNC" ) + '</codFuncao>'
						ElseIf !lEstag .Or. (lEstag .And. lCBOFuncao )
							cXml += '<codFuncao>'  		+ fGetValCpo( "RA_CODFUNC" ) + '</codFuncao>'
						Endif
						cChaveS1040 := xFilial("SRJ",IIF(Empty(cTFilial), cFilTrab,cTFilial))+ fGetValCpo( "RA_CODFUNC" )
					ElseIf !lEstag .Or. (lEstag .And. lCBOFuncao )
						If lFilFuncao // tem filial no cad funcao
							cXml += '					<codCargo>' + xFilial("SRJ",IIF(Empty(cTFilial), cFilAnt,cTFilial))+ fGetValCpo( "RA_CODFUNC" ) + '</codCargo>' //No registro do cargo informamos a função, conforme carga da tabela S-1030.
						Else
							cXml += '					<codCargo>' + fGetValCpo( "RA_CODFUNC" ) + '</codCargo>' //No registro do cargo informamos a função, conforme carga da tabela S-1030.
						Endif
						cChaveS1030 := xFilial("SRJ",IIF(Empty(cTFilial), cFilAnt,cTFilial))+ fGetValCpo( "RA_CODFUNC" )
					Endif
					If !lMiddleware
						cXml += '					<codFuncao>'+ "" +'</codFuncao>'
					EndIf
				EndIf
				cXml += '				</cargoFuncao>'

				If !lEstag .Or. (lEstag .And. !Empty(fGetValCpo( "RA_SALARIO" )) )
					cXml += '				<remuneracao>'
					cSalario	:= fGetValCpo( "RA_SALARIO" )
					If !lMiddleware
						cXml += '					<vrSalFx>'+ transform( cSalario, "@E 999999999.99" ) +'</vrSalFx>'
					Else
						cXml += '					<vrSalFx>'+ AllTrim(Str(cSalario)) +'</vrSalFx>'
					EndIf
					cXml += '					<undSalFixo>'+ cPgtoTrab +'</undSalFixo>'
					If cVersEnvio >= "2.3"  .And. lDesRem .And. !Empty(Alltrim(M->RA_DESEPS))
						cXml += '				<dscSalVar>'+ Alltrim(M->RA_DESEPS) + '</dscSalVar>'
					ElseIf !lMiddleware
						cXml += '				<dscSalVar>'+ ""						+ '</dscSalVar>'
					EndIf
					cXml += '				</remuneracao>'
				Endif

			EndIf

			//Mensagem quando as tags de salário, cargo e função não foram geradas
			If lEstag .And. !IsBlind()
				If fGetValCpo( "RA_SALARIO" ) = 0
					cMsgEstag2 :=  OemToAnsi(STR0120) + CRLF + CRLF // "'remuneracao' - O salário no cadastro está zerado."
				Endif
				If lCargSQ3
					If !lCBOCargo
						cMsgEstag2 += OemToAnsi(STR0121) + CRLF + CRLF //"'codCargo' - O cargo informado não possui um número de CBO."
					EndIF
					If !lCBOFuncao
						cMsgEstag2 += OemToAnsi(STR0122) + CRLF + CRLF //"'codFuncao' - A função informada não possui um número de CBO."
					Endif
				Else
					If !lCBOFuncao
						cMsgEstag2 := OemToAnsi(STR0123) + CRLF + CRLF //"'codCargo' - A função informada não possui um número de CBO."
					Endif
				Endif
				If !Empty(cMsgEstag2)
					cMsgEstag1 := OemToAnsi(STR0119) + CRLF + CRLF // "Algumas tags do evento não serão geradas, pois alguns campos não foram preenchidos, são elas:"
					cMsgEstag1 += cMsgEstag2
					cMsgEstag1 += CRLF + CRLF + OemToAnsi(STR0124) //"Entretanto a falta dessas tags não irá impactar no envio e na transmissão do evento."
					Help( ,, OemToAnsi(STR0001) ,, cMsgEstag1, 1, 0 )
				EndIf
			Endif

			//Info Trabalho Cedido
			If cVersEnvio >= "9.0" .And. M->RA_CATEFD $ '410' .AND. LEN(aVinculoT) > 0	//aVinculoT baseado na tabela RFZ
				cXml += '<infoTrabCedido>'
				If nTpRegTrab > 0
					cXml += '<tpRegTrab>2</tpRegTrab>'
				Else
					cXml += '<tpRegTrab>1</tpRegTrab>'
				Endif
				cXml += '</infoTrabCedido>'
			EndIf

			//Informações complementares - Afastamento para exercício de mandato eletivo
			If ( M->RA_CATEFD $ '304*305*308' .And. cVersEnvio >= "9.0" .And. RS9->( ColumnPos( "RS9_INDREM")) > 0 )
				cIndRem		:= If(FunName() == "GPEA931", M->RS9_INDREM, Posicione('RS9',1,cFilTrab + M->RA_MAT,'RS9_INDREM'))
				cXml += '				<infoMandElet>'
				cXml += '					<indRemunCargo>' + IIf(cIndRem == "1",'S','N') + '</indRemunCargo>'
				cXml += '					<tpRegPrev>' + AllTrim( M->RA_TPPREVI )	 + '</tpRegPrev>'
				cXml += '				</infoMandElet>'
			EndIf

			//Dados do Estagiários
			//Info Estagio //Se Tiver estagio, instituição é obrigatório
			If( M->RA_CATEFD $ '901*906' .AND. ( LEN(aEstagio) > 0 .AND. LEN(aInstit) > 0 ) )
				cSalario    := fGetValCpo( "RA_SALARIO" )
				cXml += '				<infoEstagiario>'
				cXml += '					<natEstagio>' + AllTrim( aEstagio[1,1] ) + '</natEstagio>'
				cXml += '					<nivEstagio>' + AllTrim( aEstagio[1,2] ) + '</nivEstagio>'
				If !lMiddleware .Or. !Empty(aEstagio[1,3])
					cXml += '				<areaAtuacao>'+ AllTrim( aEstagio[1,3] ) +'</areaAtuacao>'
				EndIf
				If !lMiddleware .Or. !Empty(aEstagio[1,4])
					cXml += '				<nrApol>'     + AllTrim( aEstagio[1,4] ) +'</nrApol>'
				EndIf
				If cVersEnvio < "9.0" .And. Alltrim(cSalario) <> "0,00"
					If !lMiddleware
						cXml += '					<vlrBolsa>'   + Transform( cSalario, "@E 999999999.99" ) +'</vlrBolsa>'
					Else
						cXml += '					<vlrBolsa>'   + AllTrim(Str(cSalario)) +'</vlrBolsa>'
					EndIf
				EndIf
				If !lMiddleware
					cXml += '					<dtPrevTerm>' + DtoS( aEstagio[1,5] ) + '</dtPrevTerm>'
				Else
					cXml += '					<dtPrevTerm>' + SubStr( dToS(aEstagio[1,5]), 1, 4 ) + "-" + SubStr( dToS(aEstagio[1,5]), 5, 2 ) + "-" + SubStr( dToS(aEstagio[1,5]), 7, 2 ) + '</dtPrevTerm>'
				EndIf

				cXml += '					<instEnsino>'
				If !lMiddleware .Or. !Empty(aInstit[1,1])
					cXml += '						<cnpjInstEnsino>' + AllTrim( aInstit[1,1] ) + '</cnpjInstEnsino>'
				EndIf
				If cVersEnvio < "9.0" .Or. Empty(aInstit[1,1])
					cXml += '							<nmRazao>' +        AllTrim( aInstit[1,2] ) + '</nmRazao>'
					If !lMiddleware .Or. !Empty(aInstit[1,3])
						cXml += '						<dscLograd>'+       AllTrim( aInstit[1,3] )+'</dscLograd>'
					EndIf
					If !lMiddleware
						cXml += '					<nrLograd>'+            AllTrim( aInstit[1,8] )+'</nrLograd>'
					EndIf
					If !lMiddleware .Or. !Empty(aInstit[1,4])
						cXml += '						<bairro>'+          AllTrim( aInstit[1,4] )+'</bairro>'
					EndIf
					If !lMiddleware .Or. !Empty(aInstit[1,5])
						cXml += '						<cep>'+             AllTrim( aInstit[1,5] )+'</cep>'
					EndIf
					If !lMiddleware .Or. !Empty(aInstit[1,6])
						cXml += '						<codMunic>'+        AllTrim( aInstit[1,6] )+'</codMunic>'
					EndIf
					If !lMiddleware .Or. !Empty(aInstit[1,7])
						cXml += '						<uf>'+              AllTrim( aInstit[1,7] )+'</uf>'
					EndIf
				EndIf
				cXml += '					</instEnsino>'

				If ( Len(aAgente) > 0 ) .And. M->RA_CATEFD <> '906'
					cXml += '					<ageIntegracao>'
					cXml += '						<cnpjAgntInteg>'+   AllTrim( aAgente[1,1] ) +'</cnpjAgntInteg>'
					If cVersEnvio < "9.0"
						cXml += '						<nmRazao>'+ 		AllTrim( aAgente[1,2] ) +'</nmRazao>'
						cXml += '						<dscLograd>'+ 		AllTrim( aAgente[1,3] ) +'</dscLograd>'
						cXml += '						<nrLograd>'+ 		AllTrim( aAgente[1,4] ) +'</nrLograd>'
						If !lMiddleware .Or. !Empty(aAgente[1,5])
							cXml += '						<bairro>'+ 			AllTrim( aAgente[1,5] ) +'</bairro>'
						EndIf
						cXml += '						<cep>'+ 			AllTrim( aAgente[1,6] ) +'</cep>'
						If !lMiddleware .Or. !Empty(aAgente[1,7])
							cXml += '						<codMunic>'+ 		AllTrim( aAgente[1,7] ) +'</codMunic>'
						EndIf
						cXml += '						<uf>'+ 				AllTrim( aAgente[1,8] ) +'</uf>'
					EndIf
					cXml += '					</ageIntegracao>'
				EndIf

				If ( Len(aCoord) > 0 ) .And. M->RA_CATEFD <> '906'
					cXml += '					<supervisorEstagio>'
					cXml += '						<cpfSupervisor>' + AllTrim( aCoord[1,1] ) + '</cpfSupervisor>'
					If cVersEnvio < "9.0"
						cXml += '						<nmSuperv>' +      AllTrim( aCoord[1,2] ) + '</nmSuperv>'
					EndIf
					cXml += '					</supervisorEstagio>'
				EndIf
				cXml += '				</infoEstagiario>'
			EndIf

			cXml += '			</infoComplementares>'
			cXml += '		</infoTSVAlteracao>'
			cXml += '	</evtTSVAltContr>'
			cXml += '</eSocial>'

			//Realiza geração de XML na System
			GrvTxtArq(alltrim(cXml), cReg)
		Else
			if (cVersEnvio >= "2.3"  .And. !lTpJorn)
				//##"Atenção"##"Tipo de Jornada no Turno de Horas escolhido está descontinuada, favor verificar o campo R6_TPJORN."
				Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0063), 1, 0 )
			Else
				//##"Atenção"##""Categoria não pode ser branca"
				Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0064), 1, 0 )
			EndIf
			lGravou := .F.
		EndIf
		//Fim do XML

		If !lMiddleware
			//Enviar como parametro a filial do Protheus na posição 1 e o XML na posição 2
			aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", cReg)
		Else
			If cEFDAviso != "2"
				//S-1030/S-1040
				If lCargSQ3
					If !Empty(cChaveS1030)
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(cChaveS1030, 40, " ")
						cStatus 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						fVldPred( AnoMes(sTod(cDataAlt)), @cStat1030, cChaveMid )
						If cStat1030 != "4"
							lS1030 := .F.
						EndIf
					EndIf
					If !Empty(cChaveS1040)
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1040" + Padr(cChaveS1040, 40, " ")
						cStatus 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						fVldPred( AnoMes(sTod(cDataAlt)), @cStatus, cChaveMid )
						If cStatus != "4"
							lS1040 := .F.
						EndIf
					EndIf
				ElseIf !lEstag .Or. (lEstag .And. lCBOFuncao )
					If !Empty(cChaveS1030)
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(cChaveS1030, 40, " ")
						cStatus 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						fVldPred( AnoMes(sTod(cDataAlt)), @cStat1030, cChaveMid )
						If cStat1030 != "4"
							lS1030 := .F.
						EndIf
					EndIf
				EndIf
				If !lS1030
					Do Case
						Case cStat1030 == "-1" // nao encontrado na base de dados
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX não localizado na base de dados"
							ElseIf lMsgHlp
								cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0130)//"Registro do evento X-XXXX não localizado na base de dados"
							EndIf
						Case cStat1030 == "1" // nao enviado para o governo
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX não transmitido para o governo"
							ElseIf lMsgHlp
								cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0131)//"Registro do evento X-XXXX não transmitido para o governo"
							EndIf
						Case cStat1030 == "2" // enviado e aguardando retorno do governo
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
							ElseIf lMsgHlp
								cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
							EndIf
						Case cStat1030 == "3" // enviado e retornado com erro
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
							ElseIf lMsgHlp
								cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1030" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
							EndIf
					EndCase
				EndIf
				If !lS1040
					Do Case
						Case cStatus == "-1" // nao encontrado na base de dados
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX não localizado na base de dados"
							ElseIf lMsgHlp
								cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0130)//"Registro do evento X-XXXX não localizado na base de dados"
							EndIf
						Case cStatus == "1" // nao enviado para o governo
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX não transmitido para o governo"
							ElseIf lMsgHlp
								cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0131)//"Registro do evento X-XXXX não transmitido para o governo"
							EndIf
						Case cStatus == "2" // enviado e aguardando retorno do governo
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
							ElseIf lMsgHlp
								cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0132)//"Registro do evento X-XXXX aguardando retorno do governo"
							EndIf
						Case cStatus == "3" // enviado e retornado com erro
							If cEFDAviso == "1"
								aAdd( aErros, OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
							ElseIf lMsgHlp
								cMsgHlp += CRLF + OemToAnsi(STR0129) + "S-1040" + OemToAnsi(STR0133)//"Registro do evento X-XXXX retornado com erro do governo"
							EndIf
					EndCase
				EndIf
			EndIf
			If Len( aErros ) == 0 .And. (cEFDAviso $ "0/2" .Or. (lS1030 .And. lS1040))
				If !Empty(cMsgHlp)
					Help( ,, OemToAnsi(STR0001) ,, cMsgHlp, 1, 0 )
				EndIf
				If !(lRetorno := fGravaRJE( aDados, cXML, lNovoRJE, nRec2306 ))
					aAdd( aErros, OemToAnsi(STR0136) )//"Ocorreu um erro na gravação do registro na tabela RJE"
				EndIf
			ElseIf cEFDAviso == "1"
				If Len(aErros) > 0
					For nI := 1 To Len(aErros)
						cMsgHlp += aErros[nI] + CRLF
					Next
					aErros[1] := cMsgHlp
					aSize(aErros, 1)
				EndIf
			EndIf
		EndIf
		If Len( aErros ) > 0
			If lMsgHlp
				If !lMiddleware
					FeSoc2Err( aErros[1], @cMsgErro , Iif( aErros[1]!='000026',1,2 ) )
					Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + cMsgErro, 1, 0 )//" não enviado(a) ao TAF. Erro: "
				Else
					Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + aErros[1] , 1, 0 )//" não enviado(a) ao Middleware. Erro: "
				EndIf
			EndIf
			lGravou := .F.
		EndIf
	EndIf

End Transaction

RestArea(aArea)
Return lGravou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Func   ºAutor  ³Glaucia Messina     º Data ³  28/03/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga de Funcao e CBO                                      º±±
±±º          ³ devolve em formato de Logica                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargVI                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGM23Func(cAliasTAB)

	Local lTemFilial	:= .T.
	Local aAreaSRJ		:= {}

	Default cAliasTAB	:= "SRJ"

	aAreaSRJ := GetArea()

	IF !EMPTY(xFilial(cAliasTAB))
		lTemFilial := .T.
	ELSE
		lTemFilial := .F.
	ENDIF

	RestArea(aAreaSRJ)
Return(lTemFilial)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Estag  ºAutor  ³Glaucia Messina     º Data ³  01/04/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se ha cadastro de estagio, para trab sem vinculo  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargTSV                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGM23Estag(cFil,cMat, dDataRef, aEstagio, aInstit, aAgente, aCoord, lCadEst, oMdl )
Local aArea 	:= GetArea()
Local lAchou	:= .T.
Local cRFSEntid
Local cRFSAgent
Local cRFSCoord
Local cRFSDtFim
Local cRFSNatur
Local cRFSApoli
Local cRFSNivel
Local cRFSAtuac
Local lNrLogr	:= RA0->(ColumnPos("RA0_NUMEND")) > 0

Default lCadEst	:= .F.
Default oMdl := Nil

	If !lCadEst
		//---------------------------------------------
		//| Se vier da persistência ou carga inicial
		//| Posiciona no banco e da carga para memória
		//---------------------------------------------
		DbSelectArea("RFS")
		DbSetOrder(1)
		lAchou := DbSeek( cFil + cMat )

		If lAchou
			RegToMemory("RFS",,,.F.)
			cRFSEntid := M->RFS_ENTIDA
			cRFSAgent := M->RFS_AGENTE
			cRFSCoord := M->RFS_COORD
			cRFSDtFim := M->RFS_DTFIM
			cRFSNatur := M->RFS_NATUR
			cRFSApoli := M->RFS_APOLIC
			cRFSNivel := M->RFS_NIVEL
			cRFSAtuac := M->RFS_ATUA
		EndIf

	Else
		cRFSEntid := oMdl:GetValue("RFS_ENTIDA")
		cRFSAgent := oMdl:GetValue("RFS_AGENTE")
		cRFSCoord := oMdl:GetValue("RFS_COORD")
		cRFSDtFim := oMdl:GetValue("RFS_DTFIM")
		cRFSNatur := oMdl:GetValue("RFS_NATUR")
		cRFSApoli := oMdl:GetValue("RFS_APOLIC")
		cRFSNivel := oMdl:GetValue("RFS_NIVEL")
		cRFSAtuac := oMdl:GetValue("RFS_ATUA")
	EndIf

	If lAchou
		Aadd(aEstagio,{;
			Iif( cRFSNatur == '1','O','N'),;
			AllTrim(cRFSNivel)	,;
			AllTrim(cRFSAtuac)	,;
			AllTrim(cRFSApoli)	,;
			M->RFS_DTFIM	})

		If !Empty(cRFSEntid)
			dbSelectArea("RA0")
			RA0->(DbSetOrder(1))
			If RA0->(DbSeek(FwxFilial("RA0",cFil) + cRFSEntid))
				Aadd(aInstit,{;
					RA0->RA0_CGC,;
					AllTrim(RA0->RA0_DESC),;
					AllTrim(RA0->RA0_ENDERE),;
					AllTrim(RA0->RA0_BAIRRO),;
					RA0->RA0_CEP,;
					RA0->RA0_CODMUN,;
					RA0->RA0_ESTADO,;
					Iif( lNrLogr, RA0->RA0_NUMEND, "" ) })
			EndIf
		EndIf

		If !Empty(cRFSAgent)
			dbSelectArea("RFR")
			RFR->(DbSetOrder(1))
			If RFR->(MsSeek(FwxFilial("RFR",cFil) + cRFSAgent))
				Aadd(aAgente,{;
					RFR->RFR_CNPJ,;
					AllTrim(RFR->RFR_NOME),;
					AllTrim(RFR->RFR_END),;
					AllTrim(RFR->RFR_NREND),;
					AllTrim(RFR->RFR_BAIRRO),;
					RFR->RFR_CEP,;
					RFR->RFR_CODMUN,;
					RFR->RFR_UF})
			EndIf
		EndIf

		If !Empty(cRFSCoord)
			dbSelectArea("RD0")
			RD0->(DbSetOrder(1))
			If RD0->(MsSeek(FwxFilial("RD0",cFil) + cRFSCoord))
				Aadd(aCoord,{RD0->RD0_CIC,RD0->RD0_NOME})
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FSubst        ³ Autor ³ Cristina Ogura   ³ Data ³ 17/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que substitui os caracteres especiais por espacos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FSubst()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM610                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FSubst(cTexto)

Local aAcentos	:={}
Local aAcSubst	:={}
Local cImpCar	:= Space(01)
Local cImpLin	:=""
Local cAux		:=""
Local cAux1		:=""
Local nTamTxt	:= Len(cTexto)
Local j
Local nPos

// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho
// maximo possivel para visualizacao dos mesmos.
// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).

aAcentos :=	{;
			Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
			Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
			Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
			Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
			Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
			Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
			Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
			Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
			Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
			Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
			Chr(213),Chr(245),Chr(227),Chr(252),Chr(045),Chr(047),Chr(061),Chr(060),Chr(062);
			}

aAcSubst :=	{;
			"C","c","A","A","a","a","a","a","a",;
			"E","e","e","i","o","o","o","o","o",;
			"u","a","b","c","d","e","f","g","h",;
			"i","j","k","l","m","n","o","p","q",;
			"r","s","t","u","v","x","z","w","y",;
			"A","B","C","D","E","F","G","H","I",;
			"J","K","L","M","N","O","P","Q","R",;
			"S","T","U","V","X","Z","W","Y","0",;
			"1","2","3","4","5","6","7","8","9",;
			"E","A","O","O","I","A","A","U","U",;
			"O","o","a","u","","","","","";
			}

For j:=1 TO Len(AllTrim(cTexto))
	cImpCar	:=SubStr(cTexto,j,1)
	//-- Nao pode sair com 2 espacos em branco.
	cAux	:=Space(01)
    nPos 	:= 0
	nPos 	:= Ascan(aAcentos,cImpCar)
	If nPos > 0
		cAux := aAcSubst[nPos]
	Elseif (cAux1 == Space(1) .And. cAux == space(1)) .Or. Len(cAux1) == 0
		cAux :=	""
	EndIf
    cAux1 	:= 	cAux
	cImpCar	:=	cAux
	cImpLin	:=	cImpLin+cImpCar

Next j

//--Volta o texto no tamanho original
cImpLin := Left(cImpLin+Space(nTamTxt),nTamTxt)

Return cImpLin

/*/{Protheus.doc} fVerifCBO
Função para verificar Descrição e CBO do cargo ou função
@author isabel.noguti
@since 01/03/2021
@version 1.0
@param cFilCons,	Caracter, Filial consultada
@param cCargo,		Caracter, Código do cargo na tabela SRA
@param cFuncao,		Caracter, Código da função na tabela SRA
@param lCBOCargo,	Logic, se o cargo tem CBO informado
@param lCBOFuncao,	Logic, se a função tem CBO informado
@param cDescFC,		Caracter, Descrição do cargo/função
@param cCboFC,		Caracter, CBO do cargo/função
@return Nil
/*/
Static Function fVerifCBO(cFilCons, cCargo, cFuncao, lCBOCargo, lCBOFuncao, cDescFC, cCboFC)

Local aArea			:= GetArea()
Local lCargSQ3		:= SuperGetMv("MV_CARGSQ3",,.F.)

Default cFilCons	:= ""
Default cCargo		:= ""
Default cFuncao		:= ""
Default lCBOCargo 	:= .F.
Default lCBOFuncao	:= .F.
Default cDescFC		:= ""
Default cCboFC		:= ""

If lCargSQ3 .And. !Empty(cCargo)
	DbSelectArea("SQ3")
	DbSetOrder(1)
	If SQ3->(DbSeek(xFilial("SQ3", cFilCons)+cCargo)) .And. ( SQ3->(ColumnPos("Q3_CBO")) > 0 .And. !Empty(SQ3->Q3_CBO))
		lCBOCargo	:= .T.
		cDescFC		:= AllTrim(SQ3->Q3_DESCSUM)
		cCboFC		:= SQ3->Q3_CBO
	Else
		lCBOCargo := .F.
	Endif
Endif

If !lCBOCargo .And. !Empty (cFuncao)
	DbSelectArea("SRJ")
	DbSetOrder(1)
	If SRJ->(DbSeek(xFilial("SRJ", cFilCons)+cFuncao)) .And. !Empty(SRJ->RJ_CODCBO)
		lCBOFuncao := .T.
		cDescFC		:= AllTrim(SRJ->RJ_DESC)
		cCboFC		:= SRJ->RJ_CODCBO
	Else
		lCBOFuncao := .F.
	Endif
Endif

RestArea(aArea)

Return
