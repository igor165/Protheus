#Include "CTBA400.Ch"
#Include "PROTHEUS.Ch"
#Include  "FONT.CH"
#Include  "COLORS.CH"

Static __lEAIC010 := NIL //Adapter de Calend�rio Cont�bil
Static lEntidad05 := Nil


// 17/08/2009 -- Filial com mais de 2 caracteres

// TRADU��O RELEASE P10 1.2 - 21/07/08
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � Ctba400  � Autor  � Simone Mie Sato         � Data 06.06.02���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Encerramento do Exercicio Contabil                         ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    � Ctba400()                                                  ���
��������������������������������������������������������������������������Ĵ��
���Retorno    � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaCTB                                                    ���
��������������������������������������������������������������������������Ĵ��
��� Par�metros� N�o h�                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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

//��������������������������������������������������������������Ŀ
//� Armazena todas as moedas/calendarios      					 �
//����������������������������������������������������������������
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

//��������������������������������������������������������������Ŀ
//� N�o h� moedas/celendarios selecionados                       �
//����������������������������������������������������������������
If Len(aMoedCalen) == 0
	Aviso(STR0008,STR0019,{'OK'})  //"Atencao"###"N�o h� Moedas/Calend�rios amarrado a uma moeda."
	Return
EndIF

//��������������������������������������������������������������Ŀ
//� Mostra tela de aviso - processar exclusivo					 �
//����������������������������������������������������������������
cMensagem := OemToAnsi(STR0002)+chr(13)  		//"E' MELHOR QUE OS ARQUIVOS ASSOCIADOS A ESTA ROTINA "
cMensagem += OemToAnsi(STR0003)+chr(13)  		//"NAO ESTEJA EM USO POR OUTRAS ESTACOES. "
cMensagem += OemToAnsi(STR0004)+chr(13)  		//"FACA COM QUE OS OUTROS USUARIOS SAIAM DO SISTEMA "
cMensagem += Space(40)+CHR(13)
cMensagem += OemToAnsi(STR0005)+chr(13)  		//"VERIFIQUE SE EXISTE ALGUM PRE-LANCAMENTO NO PERIODO "
cMensagem += OemToAnsi(STR0006)+chr(13)  		//"A SER ENCERRADO. APOS RODAR O ENCERRAMENTO DO EXER- "
cMensagem += OemToAnsi(STR0007)+chr(13)  		//"CICIO NAO PODERA MAIS EFETIVA-LOS!!!! "

IF !MsgYesNo(cMensagem,OemToAnsi(STR0008))	//"ATEN��O"
	Return
Endif

Ctb400Cal(aMoedCalen)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Ctb400Cal � Autor � Simone Mie Sato       � Data � 06.06.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe na tela o calendario e a getdados                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctb400Cal(aMoedcalend)                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aCalend = Array contendo todas as moedas/calendarios       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �Ct400Chang� Autor  � Simone Mie Sato         � Data 17.06.02���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Acao para quando mudar de linha na ListBox                  ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �Ct400Chang                                                  ���
��������������������������������������������������������������������������Ĵ��
���Retorno    � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaCTB                                                    ���
��������������������������������������������������������������������������Ĵ��
��� Par�metros�                                                            ���
���           � 														   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � Ct400Proc� Autor  � Simone Mie Sato         � Data 17.06.02���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Inicia o processamento do encerramento do exercicio        ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    � Ct400Proc()                                                ���
��������������������������������������������������������������������������Ĵ��
���Retorno    � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaCTB                                                    ���
��������������������������������������������������������������������������Ĵ��
��� Par�metros� aMoedCalen = Array contendo as moedas/calendarios          ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
			Aviso(STR0008,STR0018,{'OK'})  //"Atencao"###"O seu calend�rio n�o ser� fechado pois n�o est� amarrado a uma moeda."	//-- JRJ
		EndIf

		aMoedas	:= {}

	EndIf
Next

RestArea(aSaveArea)

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � Ct400Data� Autor  � Simone Mie Sato         � Data 17.06.02���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Data Inicial e Final a serem processadas                   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    � Ct400Data()                                                ���
��������������������������������������������������������������������������Ĵ��
���Retorno    � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaCTB                                                    ���
��������������������������������������������������������������������������Ĵ��
��� Par�metros� cCodCalend = Codigo do Calendario                          ���
���           � dDataIni   = Data Inicial a ser processada                 ���
���           � dDataFim   = Data Final a ser processada                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �Ct400Saldo| Autor  � Simone Mie Sato         � Data 17.06.02���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Atualiza flag dos arquivos de saldos                        ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    � Ct400Saldo(cFilDe,cFilAte,dDataIni,dDataFim)               ���
��������������������������������������������������������������������������Ĵ��
���Retorno    � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaCTB                                                    ���
��������������������������������������������������������������������������Ĵ��
��� Par�metros� cFilCal  = Codigo da Filial                                ���
���           � dDataIni = Data Inicial a ser encerrada                    ���
���           � dDataFim = Data Final a ser encerrada                      ���
���           � cMoeda   = Moeda a ser encerrada                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �Ct400CTG  | Autor  � Simone Mie Sato         � Data 17.06.02���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Atualiza flag do calendario contabil                        ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    � Ct400CTG()               								   ���
��������������������������������������������������������������������������Ĵ��
���Retorno    � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaCTB                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
STATIC Function Ct400CTG(cCalend,cExerc,cFilCal)

Local aSaveArea	:= GetArea()
Local cFIlCTG	:= xFilial("CTG",cFilCal)

Local nCont      := 0
Local nContMax   := 12  // Envia 12 per�odos por vez.
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

		//Adapter de Calend�rio Cont�bil
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
					Help(" ", 1, "HELP", "Erro EAI", "Problemas na integra��o EAI. Transa��o n�o executada." + CRLF + aEaiRet[2], 3, 1)
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
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �01/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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