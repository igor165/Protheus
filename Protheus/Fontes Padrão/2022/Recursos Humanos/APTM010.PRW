#INCLUDE "PROTHEUS.CH"
#INCLUDE "APTM010.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ APTM010  ³ Autor ³ Tania Bronzeri            ³ Data ³ 18/05/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Integra APT com GPE, gravando da REP na SRC/SRK.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³12/08/2014³TQEQCC³Incluido o fonte da 11 para a 12 e efetuada a ³±±
±±³            ³          ³      ³limpeza.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APTM010()
Local oDlg
Local nOpca 	:= 0
Local aSays 	:= {}
Local aButtons	:= {} //<== arrays locais de preferencia
Local aFilterExp:= {} //Expressao de filtro
Local cPerg		:= "APTM10"
Local cFunction		:= "APTM010"
Local bProcess	  	:= {|oSelf| APTM10Proc(oSelf)}
Local cDescription	:=	OemToAnsi(STR0004) +" "+;//"Este programa gera lancamentos para a Folha de Pagamento."
						OemToAnsi(STR0002) +" "+;//"Sera iniciado o processo de lancamentos com a Folha de Pagamento."
						OemToAnsi(STR0005) +" "+;//"Apos este processo, os lancamentos serao apresentados como LIBERADOS"
						OemToAnsi(STR0006) +" "+;//"(Lancamentos Integrados), ou INCONSISTENTES (Lancamentos com problemas"
						OemToAnsi(STR0007) +" "+;//"na integracao). A manutencao dos lancamentos LIBERADOS, somente podera"
						OemToAnsi(STR0008)		  //"ser efetuada atraves do modulo Folha de Pagamento SIGAGPE."

Private mv_par01 := ""
Private mv_par02 := ""
Private mv_par03 := ""
Private mv_par04 := ""
Private mv_par05 := ""
Private mv_par06 := ""
Private mv_par07 := ""
Private mv_par08 := ""
Private mv_par09 := ""
Private mv_par10 := ""
Private mv_par11 := ""
Private mv_par12 := ""
Private mv_par13 := ""
Private mv_par14 := ""
Private mv_par15 := ""


Private lAbortPrint :=	.F.
Private cCadastro   :=	OemtoAnsi(STR0003)		//"Gera‡„o dos Lancamentos para a Folha de Pagamento."

tNewProcess():New(cFunction,cCadastro,bProcess,cDescription,cPerg)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³APTM10Proc³ Autor ³ Tania Bronzeri        ³ Data ³18/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os lancamentos do Processo na Folha de Pagamento.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ APTM10Proc    			                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 							                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function APTM10Proc(oSelf)
Local cAlias    	:= ALIAS()
Local nContErro 	:= 0
Local nOpc
Local cFilAux  		:= cFilAnt
Local cOrigem  		:= "APTA100"
Local cTipo1		:=	""
Local cProcesso		:=	""
Local cRepMat		:=	""
Local cRepPd		:=	""
Local cRepCc		:=	""
Local cRepPer		:=	""
Local cAuxPer		:=	""
Local cLog			:= 	""
Local aLog			:= {}
Local aTitle		:= {}
Local nTotRegs		:= 0
Local nQtLanc		:= 0
Local cRepFil		:= Space(FWGETTAMFILIAL)
Local cSetenc		:= ""
Local lRecLock		:= .T.
Local cProcFol  := "" //RA_PROCES

// Definicao das variaveis para o SX1
Local cFilDe		:= Space(FWGETTAMFILIAL)  //	Filial De
Local cFilAte		:= Space(FWGETTAMFILIAL)  // 	Filial Ate
Local cProcDe		:= ""		//	Processo De
Local cProcAte		:= ""		// 	Processo Ate
Local cSentDe		:= ""		//	Data de Sentenca De
Local cSentAte		:= ""		//	Data de Sentenca Ate
Local cMatDe		:= ""		//	Matricula De
Local cMatAte		:= ""		//  Matricula Ate
Local cVerbaDe		:= ""		//	Verba De
Local cVerbaAte		:= ""		//	Verba Ate
Local cCcDe			:= ""		//	Centro de Custo De
Local cCcAte 		:= ""		// 	Centro de Custo Ate
Local cPeriod		:= ""		//	Periodo da Folha (RCF)
Local cSemana		:= ""		//	Semana da Folha (RCF)
Local cOpcLcto		:= ""		//?-Sobrepor Lancamentos (Sim/Nao/Nova Seq.)
Local cData			:= ""
Local cHora			:= ""
Local cChaveRgb		:= ""
Local cSeq			:= " "
Local lGrava		:= .T.
Local l2Grav		:= .F.	//?-Confirma gravacao (Opc 3)
Local cSituacao		:= ""	//?-Situacao do Funcionario
Local cUltDia		:= ""	//?-Ultimo Dia dp Mes
Local cFil 			:= Space(FWGETTAMFILIAL)
Local cInicio		:= ""
Local cFim			:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01  - Filial De										 ³
//³	mv_par02  - Filial Ate										 ³
//³	mv_par03  - Processo De 									 ³
//³ mv_par04  - Processo Ate									 ³
//³ mv_par05  - Data da Sentenca De 							 ³
//³ mv_par06  - Data de Sentenca Para 							 ³
//³ mv_par07  - Matricula De 	 								 ³
//³ mv_par08  - Matricula Ate		 							 ³
//³ mv_par09  - Verba De 		    							 ³
//³ mv_par10  - Verba Ate 		    	 						 ³
//³ mv_par11  - Centro de Custo De     	 						 ³
//³ mv_par12  - Cetro de Custo Ate     							 ³
//³ mv_par13  - Período para Lancamento (MM/AAAA) 				 ³
//³ mv_par14  - Semana para Lancamento em Folha                  ³
//³ mv_par15  - Sobrepor Lancamentos (Sim/Nao/Nova Seq.)         ³
//³                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando as Perguntas                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//--Paramentros Selecionados para geracao dos lancamentos para a Folha de Pagamento

cFilDe 		:= mv_par01				// Filial De
cFilAte     := mv_par02           	// Filial Ate
cProcDe		:= mv_par03				//	Processo De
cProcAte	:= mv_par04				// 	Processo Ate
cSentDe		:= DtoS(mv_par05)		//	Data de Sentenca De
cSentAte	:= DtoS(mv_par06)		//	Data de Sentenca Ate
cMatDe		:= mv_par07				//	Matricula De
cMatAte		:= mv_par08				//  Matricula Ate
cVerbaDe	:= mv_par09				//	Verba De
cVerbaAte	:= mv_par10				//	Verba Ate
cCcDe		:= mv_par11				//	Centro de Custo De
cCcAte 		:= mv_par12				// 	Centro de Custo Ate
cPeriod		:= mv_par13				//	Periodo da Folha (RCF)
cSemana		:= mv_par14				//	Semana da Folha (RCF)
cOpcLcto	:= mv_par15				//?-Sobrepor Lancamentos (Sim/Nao/Nova Seq.)

cAuxPer		:= substr(cPeriod,3,4)+substr(cPeriod,1,2)

If fRetPerFol(xFilial("RCH"), cAuxPer)
	dbSelectArea( "REP" )
	dbSetOrder(1)
	dbGoTop()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Regua Processamento	                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSelf:SetRegua1(REP->(RecCount()))
	oSelf:SaveLog(STR0001 + " - " + STR0027)	//"Inicio do Processamento"

   cFil := xFilial("REP", cFilDe)

   REP->( dbSeek(cFil , .T.) )

   While REP->(!Eof())

		IF lAbortPrint
			Exit
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste parametrizacao										 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cProcesso	:=	REP->REP_PRONUM
		cRepMat		:=	REP->REP_MAT
		cRepPd		:=	REP->REP_PD
		cRepCc		:=	REP->REP_CC
		cRepPer		:=	REP->REP_PERIOD
        cRepFil		:=  REP->REP_FILIAL
        cSetenc		:= 	DTOS(REP_DTSTCA)

        If !((cRepFil >= xFilial("REP",cFilDe)) .AND. (cRepFil <= xFilial("REP",cFilAte) ) .AND.;
	   		(cProcesso >= cProcDe) .AND. (cProcesso <= cProcAte ) .AND.;
	   		(cSetenc >= cSentDe) .AND. (cSetenc <= cSentAte ) .AND.;
	   		(cRepMat >= cMatDe) .AND. (cRepMat <= cMatAte ) .AND.;
	   		(cRepPd >= cVerbaDe) .AND. (cRepPd <= cVerbaAte ) .AND.;
	   		(cRepCc >= cCcDe) .AND. (cRepCc <= cCcAte ) .AND.;
	   		(cRepPer == cPeriod))

		   	dbSkip()
		   	Loop
		EndIf


 		cProcFol := Posicione("SRA", 1, REP->REP_FILFUN+cRepMat, "RA_PROCES")

 		IF REP->REP_INTEGR == "1"
			If nTotRegs == 0
				//123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				//" Filial   Processo  Sentenca   Lancado   Matricula  Verba  C.Custo     Valor           Ocorrencia"
				// 	123456   123456    99/99/9999   99/99/9999  123456     123    1234567890  999,999,999.99
				cLog := (OemToAnsi(STR0029) + OemToAnsi(STR0016) + OemToAnsi(STR0021) + OemToAnsi(STR0022) + OemToAnsi(STR0010) + OemToAnsi(STR0009) + OemToAnsi(STR0023) + OemToAnsi(STR0024) + OemToAnsi(STR0025) )
				Aadd(aTitle,cLog)
				Aadd(aLog,{})
				nTotRegs := len(aLog)
			EndIf
			Aadd(aLog[nTotRegs],(cRepFil + space(5) + cProcesso + space(4) + DtoC(REP->REP_DTSTCA) + space(3) + DtoC(REP->REP_DTLCTO) + ;
				space(6) + cRepMat + space(5) + cRepPd + space(4) + cRepCC + space(2) + ;
				Transform(REP->REP_VALOR,"@E 999,999,999.99") + space(2) + OemToAnsi(STR0020) ) )
					//"Filial" ### " - " + "Processo " ### " - " + "Sentenca de " ### " - " ;
					//+ "Lancado em " ### " - " + "Matricula " ### "Verba " ### " - " ;
					//+ "C.Custo " ### " - " + "Valor " ###.## " - " + "Lancamento nao pode ser integrado novamente."
	   	   	dbSelectArea( "REP" )
			nContErro ++
	   	   	dbSkip()
	   	   	IF cRepFil <> REP->REP_FILIAL
		        Aadd(aLog[nTotRegs],{replicate("-",255)})
   				cRepFil := REP->REP_FILIAL
			Endif
	   	   	Loop
		EndIF

		IF SRV->(DBSEEK(xFilial("SRV")+cRepPd))
			cTipo1	:=	SRV->RV_TIPO
			nQtLanc	:=	Val(SRV->RV_QTDLANC)
		Else
			If nTotRegs == 0
				cLog := (OemToAnsi(STR0029) + OemtoAnsi(STR0016) + OemtoAnsi(STR0021) + OemtoAnsi(STR0022) + OemtoAnsi(STR0010) + OemtoAnsi(STR0009) + OemtoAnsi(STR0023) + OemtoAnsi(STR0024) + OemtoAnsi(STR0025) )
				Aadd(aTitle,cLog)
				Aadd(aLog,{})
				nTotRegs := len(aLog)
			EndIf
			Aadd(aLog[nTotRegs],(cRepFil + space(5) + cProcesso + space(4) + DtoC(REP->REP_DTSTCA) + space(3) + DtoC(REP->REP_DTLCTO) + ;
				space(6) + cRepMat + space(5) + cRepPd + space(4) + cRepCC + space(2) + ;
				Transform(REP->REP_VALOR,"@E 999,999,999.99") + space(2) + OemToAnsi(STR0017) ) )
					//"Filial " ### " - " + "Processo " ### " - " + "Sentenca de " ### " - " ;
					//+ "Lancado em " ### " - " + "Matricula " ### "Verba " ### " - " ;
					//+ "C.Custo " ### " - " + "Valor " ###.## " - " + "Verba não encontrada."
	   	   	dbSelectArea( "REP" )
			nContErro ++
			RecLock("REP",.F.,.F.)
			REP->REP_INTEGR := "2"
			MsUnlock()
			FkCommit()
	   	   	dbSkip()
	   	   	IF cRepFil <> REP->REP_FILIAL
		   		Aadd(aLog[nTotRegs],{replicate("-",255)})
   				cRepFil := REP->REP_FILIAL
			Endif
	   	   	Loop
		EndIF

		IF cRepPer # cPeriod
			If nTotRegs == 0
				cLog := (OemToAnsi(STR0029) + OemToAnsi(STR0016) + OemToAnsi(STR0021) + OemToAnsi(STR0022) + OemToAnsi(STR0010) + OemToAnsi(STR0009) + OemToAnsi(STR0023) + OemToAnsi(STR0024) + OemToAnsi(STR0025) )
				Aadd(aTitle,cLog)
				Aadd(aLog,{})
				nTotRegs := len(aLog)
			EndIf
			Aadd(aLog[nTotRegs],(cRepFil + space(5) + cProcesso + space(4) + DtoC(REP->REP_DTSTCA) + space(3) + DtoC(REP->REP_DTLCTO) + ;
				space(6) + cRepMat + space(5) + cRepPd + space(4) + cRepCC + space(2) + ;
				Transform(REP->REP_VALOR,"@E 999,999,999.99") + space(2) + OemToAnsi(STR0019) ) )
					//"Filial " ### " - " + "Processo " ### " - " + "Sentenca de " ### " - " ;
					//+ "Lancado em " ### " - " + "Matricula " ### "Verba " ### " - " ;
					//+ "C.Custo " ### " - " + "Valor " ###.## " - " + "Periodo de Lancamento nao e o Atual."
	   	   	dbSelectArea( "REP" )
			nContErro ++
			RecLock("REP",.F.,.F.)
			REP->REP_INTEGR := "2"
			MsUnlock()
			FkCommit()
	   	   	dbSkip()
	   	   	IF cRepFil <> REP->REP_FILIAL
		   		Aadd(aLog[nTotRegs],{replicate("-",255)})
   				cRepFil := REP->REP_FILIAL
			Endif
	   	   	Loop
		EndIF


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mostra o Lancamento que esta sendo processado                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSelf:IncRegua1(OemToAnsi(STR0010) + cRepMat + " - " + OemToAnsi(STR0009) + cRepPd) 		//"Matricula: "###" - Verba: "
		Begin Transaction

			//?-Verifica se o funcionario esta Demitido
			//?-Se Sim, Grava Valores Futuros
			//?-Se Nao, Grava Movimento Mensal
			cSituacao := Posicione("SRA", 1, REP->REP_FILFUN+cRepMat, "RA_SITFOLH")

			If cSituacao == "D"
				cUltDia := StrZero(F_ULTDIA(CTOD("01/"+SubStr(cRepPer,1,2)+"/"+SubStr(cRepPer,3,4))),2)

				dbSelectArea("SRK")
				dbSetOrder(1)	//?-RK_FILIAL+RK_MAT+RK_PD

				cChaveSrk := xFilial("SRK")+cRepMat+cRepPd
				dbSeek(cChaveSrk,.F.)

				If cOpcLcto == 1	//?-Sim, sobrepor lancto
					If Found()
						RecLock("SRK",.F.)
					Else
						RecLock("SRK",.T.)
					EndIf
				ElseIf cOpcLcto == 2	//?-Nao sobrepor Lancto
					If Found()
						//?-Gravar no Log ***********************
						lGrava := .F.
					Else
						RecLock("SRK",.T.)
					EndIf
				ElseIf cOpcLcto == 3	//?-Nova Sequencia
					If Found()
						//?-Gravar no Log ***********************
						lGrava := .F.
					Else
						RecLock("SRK",.T.)
					EndIf
				EndIf

				If lGrava
					SRK->RK_FILIAL 	:= REP->REP_FILFUN
					SRK->RK_MAT		:= cRepMat
					SRK->RK_PD		:= cRepPd
					SRK->RK_VALORTO	:= REP->REP_VALOR
					SRK->RK_PARCELA	:= 1
					SRK->RK_VALORPA	:= REP->REP_VALOR
					SRK->RK_DTVENC	:= CTOD(cUltDia+"/"+SubStr(cRepPer,1,2)+"/"+SubStr(cRepPer,3,4))
					SRK->RK_DOCUMEN	:= ""	//?cDocument
					SRK->RK_CC		:= cRepCc
					SRK->RK_DTMOVI	:= CTOD("01/"+SubStr(cRepPer,1,2)+"/"+SubStr(cRepPer,3,4))
					SRK->RK_VALORAR	:= 0
					MsUnlock()
					FkCommit()
				EndIf
			Else

				dbSelectArea("RGB")
				dbSetOrder(7)	//?-RGB_FILIAL+RGB_MAT+RGB_PD+RGB_CC+RGB_SEMANA+RGB_SEQ

				cChaveRgb := REP->REP_FILFUN+cRepMat+cRepPd+cRepCc+cSemana+cSeq

				//Tratamento para RC_SEQ, de acordo com numero de lanctos do SRV
				If dbSeek(cChaveRgb,.F.)
					If cOpcLcto == 2	//?-Nao sobrepor Lancto
						//?-Gravar no Log ***********************
						lGrava	:= .F.

					ElseIf cOpcLcto == 3	//?-Nova Sequencia
						If nQtLanc < 2
							//?-Gravar no Log ***********************
							lGrava	:= .F.
						EndIf
						While !Eof() .And. lGrava .And. ;
							RGB_FILIAL+RGB_MAT+RGB_PD+RFB_CC+RGB_SEMANA+RGB_SEQ == REP->REP_FILFUN+cRepMat+cRepPd+cRepCc+cSemana+cSeq

							cSeq := Iif(RGB->RGB_SEQ > cSeq, RGB->RGB_SEQ, cSeq)
							dbSkip()
						EndDo
						lGrava := If(lGrava .And. (nQtLanc > Val(cSeq)),.T. ,.F.)
						l2Grav := lGrava

						dbSeek(cChaveRgb,.F.)
				    EndIf
			    EndIf

				If lGrava
					If cOpcLcto == 1	//?-Sim, sobrepor lancto
						If Found()
							lRecLock := .F.
						Else
							lRecLock := .T.
						EndIf
					ElseIf cOpcLcto == 2	//?-Nao sobrepor Lancto
						If Found()
							//?-Gravar no Log ***********************
							lGrava := .F.
						Else
							lRecLock := .T.
						EndIf
					ElseIf cOpcLcto == 3	//?-Nova Sequencia
						If Found() .And. !l2Grav
							//?-Gravar no Log ***********************
							lGrava := .F.
						Else
							lRecLock := .T.
						EndIf
					EndIf
				EndIf
				If RGB->(dbSeek(REP->REP_FILFUN+cRepMat+cRepPd+cRepCc+cSemana+cSeq)) //indice 7
			       RecLock("RGB",lRecLock)
					If lGrava
						Replace RGB->RGB_FILIAL 	With REP->REP_FILFUN
						Replace RGB->RGB_PROCES		With cProcFol
						Replace RGB->RGB_PERIOD		With cAuxPer
						Replace RGB->RGB_SEMANA		With cSemana
						Replace RGB->RGB_ROTEIR		With fGetRotOrdinar()
						Replace RGB->RGB_MAT		With cRepMat
						Replace RGB->RGB_PD		With cRepPd
						Replace RGB->RGB_TIPO1	With cTipo1
						Replace RGB->RGB_VALOR	With REP->REP_VALOR
						Replace RGB->RGB_SEMANA	With cSemana
						Replace RGB->RGB_CC		With cRepCc
						Replace RGB->RGB_TIPO2	With "G"
						Replace RGB->RGB_SEQ		With Iif(Empty(cSeq) .And. !l2Grav," ",Soma1(cSeq))
						MsUnlock()
						FkCommit()
					EndIf
				Else
					RecLock("RGB",lRecLock)
					If lGrava
						Replace RGB->RGB_FILIAL 	With REP->REP_FILFUN
						Replace RGB->RGB_PROCES		With cProcFol
						Replace RGB->RGB_PERIOD		With cAuxPer
						Replace RGB->RGB_SEMANA		With cSemana
						Replace RGB->RGB_ROTEIR		With fGetRotOrdinar()
						Replace RGB->RGB_MAT		With cRepMat
						Replace RGB->RGB_PD		With cRepPd
						Replace RGB->RGB_TIPO1	With cTipo1
						Replace RGB->RGB_VALOR	With REP->REP_VALOR
						Replace RGB->RGB_SEMANA	With cSemana
						Replace RGB->RGB_CC		With cRepCc
						Replace RGB->RGB_TIPO2	With "G"
						Replace RGB->RGB_SEQ		With Iif(Empty(cSeq) .And. !l2Grav," ",Soma1(cSeq))
						MsUnlock()
						FkCommit()
					EndIf
				EndIf
			EndIf

			If lGrava
			    //?-Atualiza o registro no APT com Sim
			    dbSelectArea( "REP" )
				RecLock("REP",.F.,.F.)
				REP->REP_INTEGR := "1"
				MsUnLock()
				FkCommit()
			Else
				If nTotRegs == 0
					cLog := (OemToAnsi(STR0029) + OemToAnsi(STR0016) + OemToAnsi(STR0021) + OemToAnsi(STR0022) + OemToAnsi(STR0010) + OemToAnsi(STR0009) + OemToAnsi(STR0023) + OemToAnsi(STR0024) + OemToAnsi(STR0025) )
					Aadd(aTitle,cLog)
					Aadd(aLog,{})
					nTotRegs := len(aLog)
				EndIf
				Aadd(aLog[nTotRegs],(cRepFil + space(4) + cProcesso + space(5) + DtoC(REP->REP_DTSTCA) + space(3) + DtoC(REP->REP_DTLCTO) + ;
									space(6) + cRepMat + space(5) + cRepPd + space(4) + cRepCC + space(2) + ;
									Transform(REP->REP_VALOR,"@E 999,999,999.99") + space(2) + OemToAnsi(STR0026) ) )
									//"Filial " ### " - " + "Processo " ### " - " + "Sentenca de " ### " - " ;
									//+ "Lancado em " ### " - " + "Matricula " ### "Verba " ### " - " ;
									//+ "C.Custo " ### " - " + "Valor " ###.## " - " + "Quantidade de lancamentos excedido para a verba."

			    //?-Atualiza o registro no APT com Sim
		   	   	dbSelectArea( "REP" )
				nContErro ++
				RecLock("REP",.F.,.F.)
				REP->REP_INTEGR := "2"
				MsUnlock()
				FkCommit()
			EndIf
		End Transaction

		dbSkip()
   EndDo

	oSelf:SaveLog(STR0001 + " - " + STR0028)	//"Término do Processamento"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se gerou novo arquivo de erro, apaga o anterior e gera novo  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nContErro > 0
		If MsgYesNo(OemToAnsi(STR0012 + "  ( " + lTrim(Str(nContErro,5)) + " )  " + OemToAnsi(STR0013)),;
				    OemToAnsi(STR0011))
				    //"Ocorreram problemas com " ### " lancamentos durante o processo de integracao.
				    // Deseja visualiza-los agora?" ### "Aten‡„o!"
			cData	:=	DtoS(DDATABASE)
			cHora	:=	Time()
			fMakeLog (aLog,aTitle,Nil,.T.,"APTI" + Substr(cData,3,6) + substr(cHora,1,2) + substr(cHora,4,2) ;
				     ,OemToAnsi(STR0018)+cPeriod,"M","P",,.T.)	//	"Log de Ocorrencias da Integracao com a Folha"
		EndIf
	EndIf

	dbSelectArea( cAlias )
	dbGoTop()

Else
	Aviso( OemToAnsi(STR0011), OemToAnsi(STR0015), { "OK" } )		// "Atencao!"###"Periodo selecionado diferente do Periodo corrente. Nenhum lancamento sera integrado."
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna filial original para o cFilAnt                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cFilAux

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³APTM10OOk³ Autor ³ Emerson Rosa de Souza ³ Data ³ 13.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Confirma parametros             							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ APTM10OK()    			                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 							                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function APTM10OK()
Return (MsgYesNo(OemToAnsi(STR0014),OemToAnsi(STR0011))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"
