#Include "CTBA400.Ch"
#Include "PROTHEUS.Ch"
#Include  "FONT.CH"
#Include  "COLORS.CH"

Static __lEAIC010 := NIL //Adapter de Calendário Contábil
Static lEntidad05 := Nil


// 17/08/2009 -- Filial com mais de 2 caracteres

// TRADUÇÃO RELEASE P10 1.2 - 21/07/08
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Ctba400  ³ Autor  ³ Simone Mie Sato         ³ Data 06.06.02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Encerramento do Exercicio Contabil                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctba400()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ N„o h                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba400 ()

Local aMoedCalen	:= {}					// Matriz com todas as moeda/calendario
Local cMensagem		:= ""
Local aUser		:={}
Local aUserFil	:={}
Local Cfiload		:= cFilAnt
Local nx			:= 0
Local aSM0 := FWLoadSM0()

Private aRotina := MenuDef()


If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

LoadVar400()

For nx := 1 To Len(aSM0)
	If aSM0[nx][1] == cEmpAnt
		AADD(aUserFil, xFilial("CTG",aSM0[nx][2]))
    EndIf
Next nx

cFilAnt := cFiload

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena todas as moedas/calendarios      					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CTG")
dbSetOrder(1)
dbGoTop()
While !Eof()
	nPosCalen := ASCAN(aMoedCalen,{|x| x[2] + x[3] == CTG->CTG_FILIAL + CTG->CTG_CALEND })
	If nPosCalen == 0 .AND. ASCAN(AUserFil,{|x| x== CTG->CTG_FILIAL  }) > 0
		AADD(aMoedCalen,{.F.,CTG->CTG_FILIAL,CTG->CTG_CALEND,CTG->CTG_EXERC})
	EndIf
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Não há moedas/celendarios selecionados                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aMoedCalen) == 0
	Aviso(STR0008,STR0019,{'OK'})  //"Atencao"###"Não há Moedas/Calendários amarrado a uma moeda."
	Return
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra tela de aviso - processar exclusivo					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMensagem := OemToAnsi(STR0002)+chr(13)  		//"E' MELHOR QUE OS ARQUIVOS ASSOCIADOS A ESTA ROTINA "
cMensagem += OemToAnsi(STR0003)+chr(13)  		//"NAO ESTEJA EM USO POR OUTRAS ESTACOES. "
cMensagem += OemToAnsi(STR0004)+chr(13)  		//"FACA COM QUE OS OUTROS USUARIOS SAIAM DO SISTEMA "
cMensagem += Space(40)+CHR(13)
cMensagem += OemToAnsi(STR0005)+chr(13)  		//"VERIFIQUE SE EXISTE ALGUM PRE-LANCAMENTO NO PERIODO "
cMensagem += OemToAnsi(STR0006)+chr(13)  		//"A SER ENCERRADO. APOS RODAR O ENCERRAMENTO DO EXER- "
cMensagem += OemToAnsi(STR0007)+chr(13)  		//"CICIO NAO PODERA MAIS EFETIVA-LOS!!!! "

IF !MsgYesNo(cMensagem,OemToAnsi(STR0008))	//"ATEN€O"
	Return
Endif

Ctb400Cal(aMoedCalen)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ctb400Cal ³ Autor ³ Simone Mie Sato       ³ Data ³ 06.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe na tela o calendario e a getdados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb400Cal(aMoedcalend)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aCalend = Array contendo todas as moedas/calendarios       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb400Cal(aMoedCalen)

Local aMostrar	:= {}

Local cCalend

Local nOpca 	:= 0

Local oDlg
Local oGet
Local oMoedCalen
Local oOk	  	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo	  	:= LoadBitmap( GetResources(), "LBNO" )

Private aTELA[0][0],aGETS[0],aHeader[0]
Private aCols	:= {}

Private nUsado := 0
Private nPosDtIni, nPosDtFim, nPosStatus

CTG->(dbGoTop())
aMostrar	:= {CTG->CTG_FILIAL,CTG->CTG_CALEND,CTG->CTG_EXERC}

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 9,0 TO 25,85 OF oMainWnd //"Encerramento do Exercicio"
DEFINE FONT oFnt1	NAME "Arial" 			Size 10,12 BOLD

@ 0.3,.5 Say OemToAnsi(STR0001) FONT oFnt1 COLOR CLR_RED	  //"Encerramento do Exercicio"
@ 13,04 BUTTON STR0015 PIXEL OF oDlg SIZE 50,11; //"Inverte Selecao"
		ACTION (	aEval(oMoedCalen:aArray, {|e| 	e[1] := ! e[1] }),;
						oMoedCalen:Refresh())

@ 2,1 LISTBOX oMoedCalen VAR cCalend Fields HEADER "",OemToAnsi("FILIAL"),OemToAnsi(STR0009),OemToAnsi(STR0010);
		  SIZE 145,70 ;
		  ON CHANGE	(Ct400Chang(aMoedCalen[oMoedCalen:nAt,2],aMoedCalen[oMoedCalen:nAt,3],aMoedCalen[oMoedCalen:nAt,4],@aMostrar,@oGet));
		  ON DBLCLICK(aMoedCalen:=CT240Troca(oMoedCalen:nAt,aMoedCalen),oMoedCalen:Refresh());
		  NOSCROLL
oMoedCalen:SetArray(aMoedCalen)
oMoedCalen:bLine := { || {if(aMoedCalen[oMoedCalen:nAt,1],oOk,oNo),aMoedCalen[oMoedCalen:nAt,2],aMoedCalen[oMoedCalen:nAt,3],aMoedCalen[oMoedCalen:nAt,4]}}

CTB010Ahead()
Ctb010Acols(2,aMostrar[3],aMostrar[2],aMostrar[1])

//GetDados
oGet := MSGetDados():New(028,160,098,330,1,,,,.T.)
DEFINE SBUTTON FROM 100, 275 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE Of oDlg

DEFINE SBUTTON FROM 100, 305 TYPE 2 ACTION oDlg:End() ENABLE Of oDlg

ACTIVATE MSDIALOG oDlg CENTERED

IF nOpca == 1
	Processa({|lEnd| Ct400Proc(aMoedCalen)})
	DeleteObject(oOk)
	DeleteObject(oNo)
Endif


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct400Chang³ Autor  ³ Simone Mie Sato         ³ Data 17.06.02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Acao para quando mudar de linha na ListBox                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³Ct400Chang                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³                                                            ³±±
±±³           ³ 														   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function Ct400Chang(cFilCal,cCodCalend,cExerc,aMostrar,oGet)

Local aSaveArea := GetArea()

aMostrar[1]		:= cFilCal
aMostrar[2]		:=	cCodCalend
aMostrar[3]		:=	cExerc

CTB010Ahead()
Ctb010Acols(2,aMostrar[3],aMostrar[2],aMostrar[1])

oGet:Refresh()

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Ct400Proc³ Autor  ³ Simone Mie Sato         ³ Data 17.06.02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Inicia o processamento do encerramento do exercicio        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct400Proc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ aMoedCalen = Array contendo as moedas/calendarios          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function Ct400Proc(aMoedCalen)

Local aSaveArea	:= GetArea()
Local dDataIni	:= CTOD("  /  /  ")
Local dDataFim	:= CTOD("  /  /  ")
Local nCalend
Local nMoedas
Local aMoedas	:= {}

For nCalend := 1 to len(aMoedCalen)

	If aMoedCalen[nCalend][1]//Se o calendario foi selecionado
		dbSelectArea("CTE")
		dbSetOrder(1)
		MsSeek(aMoedCalen[nCalend][2])
		While !Eof() .And. CTE->CTE_FILIAL == aMoedCalen[nCalend][2]

			If CTE->CTE_CALEND <> aMoedCalend[nCalend][3]
				dbSkip()
				Loop
			EndIf
			AADD(aMoedas,{aMoedCalen[nCalend][3],aMoedCalend[nCalend][4],CTE->CTE_MOEDA,aMoedCalen[nCalend][2]})
			dbSkip()
		End

		If Len(aMoedas) > 0
			For nMoedas := 1 to Len(aMoedas)
				//Verificar qual a data inicial e a data final
				Ct400Data(aMoedas[nMoedas][1],@dDataIni,@dDataFim,aMoedas[nMoedas][4])

				//Atualizar flag de saldo encerrado nos arquivos de saldos
				Ct400Saldo(aMoedas[nMoedas][4],dDataIni,dDataFim,aMoedas[nMoedas][3])

				//Atualizar flag do calendario contabil (CTG)
				Ct400CTG(aMoedas[nMoedas][1],aMoedas[nMoedas][2],aMoedas[nMoedas][4])
			Next

		Else
			Aviso(STR0008,STR0018,{'OK'})  //"Atencao"###"O seu calendário não será fechado pois não está amarrado a uma moeda."	//-- JRJ
		EndIf

		aMoedas	:= {}

	EndIf
Next

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Ct400Data³ Autor  ³ Simone Mie Sato         ³ Data 17.06.02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Data Inicial e Final a serem processadas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct400Data()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ cCodCalend = Codigo do Calendario                          ³±±
±±³           ³ dDataIni   = Data Inicial a ser processada                 ³±±
±±³           ³ dDataFim   = Data Final a ser processada                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function Ct400Data(cCodCalend,dDataIni,dDataFim,cFilCal)

Local aSaveArea	:= GetArea()
Local cFilCTG		:= xFilial("CTG",cFilCal)
dbSelectArea("CTG")
dbSetOrder(2)
//Pega a data inicial a ser processada
If MsSeek(cFilCTG+cCodCalend)
	dDataIni	:= CTG->CTG_DTINI
EndIf

//Pega a data final a ser processada
dbSetorder(3)
MsSeek(cFilCTG+StrZero((Val(cCodCalend)+1),3),.T.)
dbSkip(-1)
If cFilCTG == CTG->CTG_FILIAL .And. cCodCalend == CTG->CTG_CALEND
	dDataFim	:= CTG->CTG_DTFIM
EndIf

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct400Saldo| Autor  ³ Simone Mie Sato         ³ Data 17.06.02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Atualiza flag dos arquivos de saldos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct400Saldo(cFilDe,cFilAte,dDataIni,dDataFim)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ cFilCal  = Codigo da Filial                                ³±±
±±³           ³ dDataIni = Data Inicial a ser encerrada                    ³±±
±±³           ³ dDataFim = Data Final a ser encerrada                      ³±±
±±³           ³ cMoeda   = Moeda a ser encerrada                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function Ct400Saldo(cFilCal,dDataIni,dDataFim,cMoeda)

Local aSaveArea		:= GetArea()
Local aSaldos		:= {"CQ0","CQ1","CQ2","CQ3","CQ4","CQ5","CQ6","CQ7","CTC"}
Local cInicial		:= ""
Local cChave		:= ""
Local nArqs

Local cQuery		:= ""
Local cQueryFlg		:= ""
Local cSaldos		:= ""
Local nMin			:= 0
Local nMax			:= 0

If lEntidad05
	aAdd( aSaldos , "QL6" )
	aAdd( aSaldos , "QL7" )
EndIf

For nArqs	:= 1 to Len(aSaldos)

	ProcRegua((aSaldos[nArqs])->(RecCount()))
	cInicial := aSaldos[nArqs] + "_"
	cSaldos  := "cSaldos"
	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery += "FROM "+RetSqlName(aSaldos[nArqs])+ " ARQ "
	cQuery += "WHERE "
	If !Empty(xFilial("CTG"))
		cQuery += "ARQ."+cInicial+ "FILIAL = '"+xFilial(aSaldos[nArqs],cFilCal)+"'  AND "
	EndIf
	If lEntidad05
		If aSaldos[nArqs] $ 'CQ0/CQ2/CQ4/CQ6/QL6'
			cQuery += "ARQ."+cInicial+"DATA BETWEEN '"+DTOS(FirstDay(dDataIni))+"' AND '"+DTOS(LastDay(dDataFim))+"' AND "
		EndIf
	ElseIf aSaldos[nArqs] $ 'CQ0/CQ2/CQ4/CQ6'
		cQuery += "ARQ."+cInicial+"DATA BETWEEN '"+DTOS(FirstDay(dDataIni))+"' AND '"+DTOS(LastDay(dDataFim))+"' AND "
	Else
		cQuery += "ARQ."+cInicial+"DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "
	Endif
	cQuery += "ARQ."+cInicial+"MOEDA = '" + cMoeda + "'"
	cQuery += " ORDER BY RECNO "
	cQuery := ChangeQuery(cQuery)

	If ( Select ( "cSaldos" ) <> 0 )
		dbSelectArea ( "cSaldos" )
		dbCloseArea ()
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSaldos,.T.,.F.)


	cQueryFlg 	:= "UPDATE "
	cQueryFlg 	+= RetSqlName(aSaldos[nArqs])+" "
	cQueryFlg 	+= "SET "+cInicial+"STATUS = '2' "
	cQueryFlg   += " WHERE "
	If !Empty(xFilial("CTG"))
		cQueryFlg	+= " " +cInicial+ "FILIAL = '"+xFilial(aSaldos[nArqs],cFilCal)+"' AND "
	EndIf
	If lEntidad05
		If aSaldos[nArqs] $ 'CQ0/CQ2/CQ4/CQ6/QL6'
			cQueryFlg	+= cInicial+"DATA BETWEEN '"+DTOS(FirstDay(dDataIni))+"' AND '"+DTOS(LastDay(dDataFim))+"' AND "
		EndIf
	ElseIf aSaldos[nArqs] $ 'CQ0/CQ2/CQ4/CQ6'
		cQueryFlg	+= cInicial+"DATA BETWEEN '"+DTOS(FirstDay(dDataIni))+"' AND '"+DTOS(LastDay(dDataFim))+"' AND "
	Else
		cQueryFlg	+= cInicial+"DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "
	Endif
	cQueryFlg	+= cInicial+"MOEDA = '" + cMoeda + "' "

	While cSaldos->(!Eof())

		nMin := (cSaldos)->RECNO

		nCountReg := 0

		While cSaldos->(!EOF()) .and. nCountReg <= 4096

			nMax := (cSaldos)->RECNO
			nCountReg++
			cSaldos->(DbSkip())

		End

		cChave := " AND R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
		TcSqlExec(cQueryFlg+cChave)

	End

Next
RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct400CTG  | Autor  ³ Simone Mie Sato         ³ Data 17.06.02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Atualiza flag do calendario contabil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct400CTG()               								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function Ct400CTG(cCalend,cExerc,cFilCal)

Local aSaveArea	:= GetArea()
Local cFIlCTG	:= xFilial("CTG",cFilCal)

Local nCont      := 0
Local nContMax   := 12  // Envia 12 períodos por vez.
Local aEaiRet    := {}
Local aLotes     := {}
Local aPeriodos  := {}
Local nX

Private INCLUI := .F.
Private ALTERA := .T.

dbSelectArea("CTG")
dbSetOrder(1)
If MsSeek( cFIlCTG +cCalend+cExerc)
	Begin Transaction
		While CTG->CTG_FILIAL == cFIlCTG .And. CTG->CTG_CALEND == cCalend .And. ;
				CTG->CTG_EXERC == cExerc .And. CTG->(!Eof())
			Reclock("CTG",.F.)
			CTG->CTG_STATUS := '2'
			MsUnlock()
			CTG->(dbSkip())
		End
		//Atuialisa status da CQD-Bloquei de processos para contabilidade
		CTBA012FEC(cCalend,cExerc)

		//Adapter de Calendário Contábil
		If (__lEAIC010) .AND. MsSeek( cFIlCTG +cCalend+cExerc)
			// Monta lotes de envio.
			nCont := nContMax
			Do While CTG->(!EOF() .And. CTG_FILIAL + CTG_CALEND + CTG_EXERC == FWxFilial("CTG") + cCalend + cExerc)
				If nCont = nContMax
					aAdd(aLotes, {CTG->CTG_PERIOD, ""})
					aPeriodos := aTail(aLotes)
					nCont := 1
				Else
					nCont ++
				Endif
				aPeriodos[2] := CTG->CTG_PERIOD

				CTG->(dbSkip())
			EndDo

			// Envia os lotes.
			CTG->(dbSetOrder(1))  // CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD.
			CTG->(dbSeek(xFilial("CTG") + cCalend + cExerc, .F.))
			For nX := 1 to len(aLotes)
				aPeriodos := aLotes[nX]
				CTI010Ini(aPeriodos[1])
				CTI010Fim(aPeriodos[2])

				aEaiRet := FWIntegDef('CTBA010',,,, 'CTBA010')
				If !aEaiRet[1]
					Help(" ", 1, "HELP", "Erro EAI", "Problemas na integração EAI. Transação não executada." + CRLF + aEaiRet[2], 3, 1)
					DisarmTransaction()
					lRet := .F.
				Endif
			Next nX
			CTI010Ini("")
			CTI010Fim("")
		EndIf
	End Transaction
EndIf

RestArea(aSaveArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {	{ OemToAnsi(STR0016),"Ctb400Cal", 0 , 2}}  //"Visualizar"
Return(aRotina)

Function LoadVar400()

If __lEAIC010 == NIL
	__lEAIC010   := FWHasEAI("CTBA010",.T.,,.T.)
EndIf

If lEntidad05 == NIL
	lEntidad05 := (cPaisLoc $ "COL|PER" .And. CtbMovSaldo("CT0",,"05") .And. FWAliasInDic("QL6") .And. FWAliasInDic("QL7")) // Manejo de entidad 05
Endif

Return