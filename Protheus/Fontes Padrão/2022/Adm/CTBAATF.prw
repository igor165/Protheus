#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'CTBAATF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBAATF
Rotina de contabiliza��o dos processos que foram executados com a
configura��o da contabiliza��o como Off-Line, com processamento
Multi-Thread.

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------

Function CTBAATF()
Local bProcess	:= {|oSelf| Iif(CtbValiDt(,dDataBase  ,,,,{"ATF001"},),CTATFMTR(oSelf),.F.) }    
Local cPerg		:= "CTBAATF"
Local aInfo		:= {}
Local oProcesso	:= Nil

Private lAutomato := IsBlind()

/*
 * Bot�o para visualiza��o do log de processamento da Contabiliza��o Off-Line
 */
Aadd(aInfo,{STR0001, { || ProcLogView(,FunName()) },"WATCH" }) //"Visualizar"

If !lAutomato

	oProcesso := tNewProcess():New("CTBAATF",;
										STR0026,; //"Contabiliza��o Off-Line do Ativo Fixo"
										bProcess,;
										STR0027,; //"Rotina para contabiliza��o dos registros do ambiente Ativo Fixo que foram contabilizados de forma off-line."
										cPerg,;
										aInfo,;
										.T.,;
										5,;
										STR0028,; //"Descri��o do painel Auxiliar"
										.T.)
Else
	CTATFMTR()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFMTR
Fun��o de controle e execu��o das tarefas de cada Thread, de acordo com
quantidade de threads definidas pelo usu�rio.

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function CTATFMTR(oProcesso)
Local lRet			:= .T.
Local nQtdProc		:= GetMv("MV_ATFCTHR", .F., 1 )
Local oIPC			:= Nil
Local nContProc		:= 0
Local cRotThread	:= FunName()
Local cChave		:= cRotThread + "_" + AllTrim(SM0->M0_CODIGO) + "_" + StrTran(AllTrim(xFilial("SN4")), " ", "_")
Local cMostraLanc	:= MV_PAR01
Local cAglutLanc	:= MV_PAR02
Local dDtInicial	:= MV_PAR03
Local dDtFinal		:= MV_PAR04
Local cRotATF		:= Iif(Len(Alltrim(MV_PAR05)) == 1, "0"+Alltrim(MV_PAR05), MV_PAR05)
Local cQuebraPrc	:= MV_PAR06
Local cConsidFil	:= MV_PAR07
Local nAtvJaClas	:= MV_PAR08
Local cAlsTabReg	:= cRotThread + "_" + AllTrim(SM0->M0_CODIGO) + "_" + StrTran(AllTrim(xFilial("SN4")), " ", "_")
Local nQtdTotal		:= 0
Local nQtdLote		:= 0
Local nIniLote		:= 0
Local nFinLote		:= 0
Local bProcCTB		:= { || }
Local lUsaFlag		:= GETMV("MV_CTBFLAG",.F.,.F.)
Local cIdCV8		:= ''
Local aSelFil		:= {}
Local aTmpFil		:= {}
Local lCtbInTran	:= .F.
Local aParam 		:= {}

Default oProcesso := Nil

dbSelectArea("SN4")
dbSetOrder(1) //Garantir que indice 1 da SN4 esteja aberto 

//Validacao para o bloqueio do processo
If !CtbValiDt(,dDataBase  ,,,,{"ATF001"},)
	lRet := .F.
EndIf

If lRet .And. nQtdProc > 30
	Help(" ",1,"CTBATFTRD",,STR0029,1,0) //"Quantidade de Thread n�o permitida. S�o permitidas at� 30 thread para o processamento da contabiliza��o off-line."
	lRet := .F.
EndIf

If lRet .AND. nQtdProc > 1
	lCtbInTran := CTBINTRAN(1,cMostraLanc == 1)
	
	If !lCtbInTran
		lRet := MsgYesNo(STR0030,STR0031)//"O processamento ser� feito sem multithread. Concorda com opera��o?" ##"Aten��o"
		nQtdProc := 1 // Definido para n�o processar com multiplas threads.
	EndIf
EndIf

If lRet .AND. cConsidFil == 1
	aSelFil := AdmGetFil(.T.,.F.,"SN4")
	If Empty(aSelFil)
		Help(" ",1,"CTBATFIL",,STR0032, 1, 0 ) //"Selecione uma filial para busca de dados." 
		lRet := .F.
	EndIf
EndIf

/*
 * Defini��o de Quais Processos do Ativo Fixo ser�o contabilizados na Execu��o desta Rotina
 * 01 = Aquisi��o
 * 02 = Deprecia��o
 * 03 = Outros Movimentos
 * 04 = Todas as Rotinas
 */
If lRet
	CTATFDADOS(cRotATF,@cAlsTabReg,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil,nAtvJaClas)
EndIf

bProcCTB := { || CTATFCTB( cRotATF, cAlsTabReg ,nIniLote, nFinLote, cQuebraPrc, cAglutLanc, cMostraLanc, lUsaFlag, cConsidFil) }

ProcLogIni( {},FunName(),,@cIdCV8 )
ProcLogAtu( "INICIO" , STR0033 ,,,.T. ) // "Contabiliza��o Off-Line dos Processos do Ambiente Ativo Fixo"

/*
 * Verifica se o processamento ser� Multi-Thread
 */
If lRet .AND. nQtdProc > 1
	
	/*
	 * Trava a rotina para n�o ter acesso concorrente
	 */
	If !LockByName( cChave, .F. , .F. )
		Help( " " ,1, cChave ,, STR0034 ,1, 0 ) //"Outro usu�rio est� usando a rotina. Tente novamente mais tarde."
	Else

		aParam := {dDataBase,cUsuario, cUsername}
		TcRefresh(cAlsTabReg)
	
		nQtdTotal	:= (cAlsTabReg)->(RecCount())
		nQtdLote	:= ROUND(ABS(nQtdTotal / nQtdProc),0)
		
 		//Defino uma quantidade m�nima por thread 
		//Pois o sistema estava travando ao abrir 
		//Muitas threads para poucos registros
		If nQtdLote < 30
			nQtdProc := ROUND(ABS(nQtdTotal / 30),0)		
			If nQtdProc < 1
				nQtdProc := 1
			EndIf	
			nQtdLote := ROUND(ABS(nQtdTotal / nQtdProc),0)
		EndIf 
		
		/*
		 * Objeto do Controlador de Threads (Instancia para Execu��o das Threads)
		 */
		oIPC := FWIPCWait():New( cRotThread + "_" + AllTrim(STR(SM0->(RECNO()))) , 10000 )
		
		/*
		 * Inicia as Threads
		 */
		oIPC:SetThreads( nQtdProc )
		
		/*
		 * Informa o Ambiente Para Execu��o da Thread
		 */
		oIPC:SetEnvironment( cEmpAnt , cFilAnt )
		
		/*
		 * Fun��o para ser executada na Thread
		 */
		oIPC:Start( "CTATFCTB" )
		
		Sleep( 600 )
		ProcRegua( nQtdTotal )
		
		/*
		 * Abertura de Threads
		 */
		For nContProc := 1 To nQtdProc

			If !lAutomato	
				oProcesso:IncRegua1(STR0035) //"Iniciando contabiliza��o dos registros off-line..."
				
				IncProc()
			EndIf
				
			/*
			 * Defini��o do �nicio do intervalo de registros que ser� processado em cada Thread
			 */
			If nContProc == 1
				nIniLote := 1
			Else
				nIniLote += nQtdLote
			EndIf
			
			/*
			 * Defini��o do final do intervalo de registros que ser� processado em cada Thread
			 */
			If nContProc == nQtdProc
				nFinLote := nQtdTotal
			Else
				nFinLote += nQtdLote
			EndIf
			
			/*
			 * Inicia a execu��o da fun��o na Threads
			 */				
			oIPC:Go( cRotATF, cAlsTabReg ,nIniLote, nFinLote, cQuebraPrc, cAglutLanc, cMostraLanc, lUsaFlag, cConsidFil, aParam)
		Next nContProc
				
		/*
		 * Fechamento das Threads Iniciadas (O m�todo aguarda o encerramentos de todas as Threads antes de retornar ao controle.
		 */
		oIPC:Stop()
		
		FreeObj(oIPC)
		oIPC := Nil
		
		/*
		 * Destrava rotina ap�s finalizar a execu��o das Threads
		 */
		UnLockByName( cChave, .F. , .F. )
		
		If !lAutomato	
			ProcLogAtu( "MENSAGEM",  STR0036 ,,,.T. )	//"Processo concluido sem ocorr�ncias"
		EndIf

	EndIf
ElseIf lRet .AND. nQtdProc == 1
	Eval(bProcCTB)
	
	If !lAutomato
		ProcLogAtu( "MENSAGEM",  STR0036 ,,,.T. )	//"Processo concluido sem ocorr�ncias"
	EndIf
Else
	If !lAutomato
		ProcLogAtu( "MENSAGEM",  STR0037 ,,,.T. )	//"Processo de contabiliza��o cancelado."
	EndIf
EndIf

If Select(cAlsTabReg) > 0
	/*
	 * Fecha �rea de trabalho
	 */
	(cAlsTabReg)->(DbCloseArea())
	
	/*
	 * Verifica se a tabela existe no banco de dados e exclui
	 */
	If TcCanOpen(cAlsTabReg)
		TcDelFile(cAlsTabReg)
	EndIf
EndIf

If !lAutomato
	ProcLogView(cFilAnt,FunName(),,cIdCV8)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFQSN4
Fun��o de busca dos dados da tabela SN4 das movimenta��es feita no
ambiente do Ativo Fixo (Aquisi��o/Baixa/Deprecia��o).

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function CTATFQSN4(cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil,nAtvJaClas, cIdMov)
Local cAlsSN4		:= GetNextAlias()
Local cQrySN4		:= ''
Local aArea		:= GetArea()
Local aSN4Area	:= {}
Local aValores	:= {}
Local cTmpSN4Fil	:= ''
Local lSGBD   := Iif(Upper(Alltrim(TCGetDB())) $ "MSSQL7|ORACLE|POSTGRES", .T., .F.)
Local lRet    := .F.
Local lTabTmp := TcCanOpen(cAlsTabReg)

Default nAtvJaClas := 1 
Default cIdMov     := ""

//Procedure para Gravar tmp
If lSGBD .and. lTabTmp
	/* Cria script/procedure para popular a temp  */
	lRet := CAtfPopTmp(cAlsTabReg, nAtvJaClas, cIdMov, dDtInicial, dDtFinal, cConsidFil, aSelFil)
EndIf

If !lRet

	DbSelectArea('SN4')
	aSN4Area := SN4->(GetArea())

	cQrySN4 := 'SELECT ' + CRLF
	cQrySN4 += 'SN4.R_E_C_N_O_  SN4RECNO ' + CRLF
	cQrySN4 += ',SN4.N4_FILIAL ' + CRLF
	cQrySN4 += ',SN4.N4_ORIGEM ' + CRLF
	cQrySN4 += ',SN4.N4_DCONTAB ' + CRLF
	cQrySN4 += ',SN4.N4_LP ' + CRLF

	If !Empty(cIdMov)
		cQrySN4 += ',SN4.N4_IDMOV  IDMOV' + CRLF
	Endif
	cQrySN4 += ' FROM ' + RetSqlName('SN4') + ' SN4 ' + CRLF

	If nAtvJaClas == 2 
		cQrySN4 += " INNER JOIN " + RetSqlName('SN1') + " SN1 " + CRLF
		cQrySN4 += " ON  N1_FILIAL = N4_FILIAL "
		cQrySN4 += " AND N1_CBASE  = N4_CBASE "
		cQrySN4 += " AND N1_ITEM   = N4_ITEM "
	Endif

	cQrySN4 += ' WHERE ' + CRLF
	cQrySN4 += " SN4.D_E_L_E_T_ = ' ' "

	If nAtvJaClas == 2 
		cQrySN4 += " AND N1_STATUS != '0' AND SN1.D_E_L_E_T_ = ' ' "
	Endif

	If cConsidFil == 2
		cQrySN4 += " AND SN4.N4_FILIAL = '" + xFilial("SN4",cFilAnt) + "' "
	ElseIf cConsidFil == 1
		cQrySN4 += " AND SN4.N4_FILIAL " + GetRngFil( aSelFil, "SN4", .T., @cTmpSN4Fil ) 
		aAdd(aTmpFil, cTmpSN4Fil)
	EndIf
	cQrySN4 += " AND SN4.N4_LA != 'S' "
	cQrySN4 += " AND SN4.N4_DATA BETWEEN '" + DTOS(dDtInicial) + "' AND '" + DTOS(dDtFinal) + "' ""
	If !Empty(cIdMov)
		cQrySN4 += " AND SN4.N4_IDMOV = '"+cIdMov+"'"
	Endif

	cQrySN4 := ChangeQuery(cQrySN4)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySN4), cAlsSN4 , .F., .T.)
	//IsIncallstack("ATFA050")
	While !(cAlsSN4)->(Eof())
		aAdd(aValores,{(cAlsSN4)->N4_FILIAL,;
						(cAlsSN4)->N4_ORIGEM,;
						(cAlsSN4)->SN4RECNO,;
						(cAlsSN4)->N4_LP,;
						'SN4',;
						'N4_LA',;
						'N4_DCONTAB',iF(!Empty(cIdMov), (cAlsSN4)->IDMOV, " ")})	
		(cAlsSN4)->(DbSkip())
	EndDo

	CTAFGRVTMP(@cAlsTabReg,aCampos,aValores)  // tirar gravar direto na tmpatfa050..

	(cAlsSN4)->(DbCloseArea())
	RestArea(aSN4Area)
Endif

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFQSNX
Fun��o de busca dos dados da tabela SNX das movimenta��es de rateio de 
despesa de deprecia��o feita no ambiente do Ativo Fixo (Deprecia��o).

@author marylly.araujo
@since 26/02/2014
@version MP12
//-------------------------------------------------------------------
Alterado por Jeferson Couto em 20/10/2021
Inclu�do o par�metro cIdMov para registrar no array aValores caso seja passado
/*/
//-------------------------------------------------------------------
Function CTATFQSNX(cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil, cIdMov)
Local lRet			:= .T.
Local cAlsSNX		:= GetNextAlias()
Local cQrySNX		:= ''
Local aArea		:= GetArea()
Local aSNXArea	:= {}
Local aValores	:= {}
Local cTmpSNXFil	:= ''

Default cIdMov     := ""

DbSelectArea('SNX')
aSNXArea := SNX->(GetArea())

cQrySNX := 'SELECT ' + CRLF
cQrySNX += 'SNX.R_E_C_N_O_  SNXRECNO ' + CRLF
cQrySNX += ',SNX.NX_FILIAL ' + CRLF
cQrySNX += ',SNX.NX_ORIGEM ' + CRLF
cQrySNX += ',SNX.NX_DCONTAB ' + CRLF
cQrySNX += ',SNX.NX_LP ' + CRLF
If !Empty(cIdMov)
	cQrySNX += ',SNX.NX_IDMOV  IDMOV' + CRLF
Endif
cQrySNX += ' FROM ' + RetSqlName('SNX') + ' SNX ' + CRLF
cQrySNX += ' WHERE ' + CRLF
cQrySNX += " SNX.D_E_L_E_T_ = ' ' "
If cConsidFil == 2
	cQrySNX += " AND SNX.NX_FILIAL = '" + xFilial("SNX",cFilAnt) + "' "
ElseIf cConsidFil == 1
	cQrySNX += " AND SNX.NX_FILIAL " + GetRngFil( aSelFil, "SNX", .T., @cTmpSNXFil ) 
	aAdd(aTmpFil, cTmpSNXFil)
EndIf
cQrySNX += " AND SNX.NX_LA <> 'S' "
cQrySNX += " AND SNX.NX_DTMOV BETWEEN '" + DTOS(dDtInicial) + "' AND '" + DTOS(dDtFinal) + "' "
If !Empty(cIdMov)
	cQrySNX += " AND SNX.NX_IDMOV = '"+cIdMov+"'"
Endif

cQrySNX := ChangeQuery(cQrySNX)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySNX), cAlsSNX , .F., .T.)

While !(cAlsSNX)->(Eof())
	aAdd(aValores,{(cAlsSNX)->NX_FILIAL,;
					 (cAlsSNX)->NX_ORIGEM,;
					 (cAlsSNX)->SNXRECNO,;
					 (cAlsSNX)->NX_LP,;
					 'SNX',;
					 'NX_LA',;
					 'NX_DCONTAB', iF(!Empty(cIdMov), (cAlsSNX)->IDMOV, " ")})
	(cAlsSNX)->(DbSkip())
EndDo

CTAFGRVTMP(@cAlsTabReg,aCampos,aValores)

(cAlsSNX)->(DbCloseArea())

RestArea(aSNXArea)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFDADOS
Defini��o de Quais Processos do Ativo Fixo ser�o contabilizados na Execu��o desta Rotina
01 = Aquisi��o
02 = Deprecia��o
03 = Outros Movimentos
04 = Todas as Rotinas

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------

Function CTATFDADOS(cRotATF,cAlsTabReg,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil,nAtvJaClas, cIdMov)

Local aCampos := {}

Default cRotATF := '04'
Default nAtvJaClas := 1
Default cIdMov     :="" 

/*
 * Verifica se a tabela existe no banco de dados e exclui
 */
If TcCanOpen(cAlsTabReg)
	TcDelFile(cAlsTabReg)
EndIf

/*
 * Cria��o da Tabela de Dados de Registros que ser�o contabilizados
 */
aAdd(aCampos, {"FILIAL"	,"C",FWSizeFilial()			,0})
aAdd(aCampos, {"ORIGEM"	,"C",TamSX3("N4_ORIGEM")[1]	,0})
aAdd(aCampos, {"RECNO"	,"N",14						,0})
aAdd(aCampos, {"LP"		,"C",TamSX3("N4_LP")[1]	    ,0})
aAdd(aCampos, {"TABELA"	,"C",3						,0})
aAdd(aCampos, {"CPOFLAG","C",10		     	 		,0})
aAdd(aCampos, {"CPODTCTB","C",10					,0})
aAdd(aCampos, {"IDMOV","C",TamSX3("N4_IDMOV")[1]    ,0})  // Id da movimenta��o recebe pelo ATFA050 , MOVIEMNTO DE C�CULO DE DEPRECIA��O
/*
 * Cria tabela tempor�ria no banco de dados
 */
DbCreate( cAlsTabReg ,aCampos,"TOPCONN") // criar 2 indices um por idmov

/*
 * Abertura da tabela no �rea de trabalho para utiliza��o
 */
DbUseArea(.T.,"TOPCONN", cAlsTabReg, cAlsTabReg,.T.,.F.)

If cRotATF == '01' .OR. cRotATF == '02' 
	CTATFQSN4(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil,nAtvJaClas, cIdMov)
	CTATFQSNX(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil, cIdMov)
ElseIf cRotATF == '03' .OR. cRotATF == '04'
	/*
	 * Movimentos do Ativo Fixo (Deprecia��o,Transfer�ncia, Amplia��o)
	 */
	CTATFQSN4(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil)
	/*
	 * Movimentos de Rateio de Despesa de Deprecia��o
	 */
	CTATFQSNX(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil)
	/*
	 * Movimentos de Putting Into Operation
	 */
	If cPaisLoc == "RUS"
		CTATFQF43(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil)
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFCTB
Fun��o de contabiliza��o dos registros pendentes de contabiliza��o do
ambiente Ativo Fixo.

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function CTATFCTB(cRotATF, cAlsTabReg ,nIniLote, nFinLote, cQuebraPrc, cAglutLanc, cMostraLanc, lUsaFlag, cConsidFil, aParam, cIdMov)   //passar cIdMov
Local lRet 		:= .T.
Local cQryRegs	:= ''
Local cAlsRegs	:= GetNextAlias()
Local aSN1Area	:= {}
Local aSN3Area	:= {}
Local aSN4Area	:= {}
Local nHdlPrv	:= 0
Local cArquivo	:= ''
Local cLoteATF	:= LoteCont("ATF")
Local cRotCont	:= FunName()
Local cUserCont	:= ""
Local nTotal		:= 0
Local aFlagCTB	:= {}
Local cWhere	:= ''
Local cLPAtual	:= ''
Local cFilAtua	:= ''
Local cFilAux	:= cFilAnt
Local aRegCTB   := {}
Local nValReg	:= 0		
Local aLPadrao  := {}
Local lProcessa := .F.
Local cPadrao   := ""

DEFAULT aParam  := {}
Default cIdMov  :=""

If Len(aParam) > 0	
	dDataBase := aParam[1]

	If Type("cUsuario") <> "U" .And. Empty(cUsuario)
		cUsuario := aParam[2]
	EndIf

	If Type("cUsername") <> "U" .And. Empty(cUsername)
		cUsername := aParam[3]
	EndIf
EndIf

cUserCont := Substr(cUsername,1,6)

//Utilizado para contabilizar na data correta - MultiThread

DbSelectArea('SN1')
aSN1Area := SN1->(GetArea())
SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM

DbSelectArea('SN3')
aSN3Area := SN3->(GetArea())
SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV

DbSelectArea('SN4')
aSN4Area := SN4->(GetArea())
//Begin Transaction

cQryRegs := "SELECT FILIAL, ORIGEM, RECNO, LP, TABELA, CPOFLAG, CPODTCTB, D_E_L_E_T_, R_E_C_N_O_ FROM " + cAlsTabReg + " "

If nIniLote != 0 .AND. nFinLote != 0
	cWhere += "WHERE R_E_C_N_O_ BETWEEN " + CVALTOCHAR(nIniLote) + " AND " + CVALTOCHAR(nFinLote) + " "
EndIf

If cRotATF == '01'
	cWhere += Iif(!EMPTY(cWhere)," AND "," WHERE ") + " ( ORIGEM = 'ATFA010 ' OR ORIGEM = 'ATFA012 ' ) " 			
ElseIf cRotATF == '02'// quado vem pela ATFA050
	cWhere += Iif(!EMPTY(cWhere)," AND "," WHERE ") + " ( ORIGEM = 'ATFA050 ' OR ORIGEM = 'ATFA036 ' AND LP = '820' ) "  //ATFA036 DEPRECIA��O NA BAIXA/TRANSFERENCIA
	If !Empty(cIdMov) 
		cWhere += " AND IDMOV = '"+cIdMov+"'"
	EndIf
ElseIf cRotATF == '03'
	cWhere += Iif(!EMPTY(cWhere)," AND "," WHERE ") + " ORIGEM != 'ATFA050 ' AND ORIGEM != 'ATFA010 ' AND ORIGEM != 'ATFA012 ' "
EndIf

cQryRegs += cWhere

/*
 * Tratamento na query da quebra por filial e por processo.
 */
If cQuebraPrc == 1
	cQryRegs += "ORDER BY FILIAL,LP "
/*
 * Tratamento na query da quebra por filial e por processo.
 */
ElseIf cConsidFil == 1
	cQryRegs += "ORDER BY FILIAL "
EndIf

cQryRegs := ChangeQuery(cQryRegs)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryRegs), cAlsRegs, .T., .T.)

If nIniLote > 0  
	(cAlsRegs)->(DbGoTo(nIniLote)) // s� quando tiver mais de uma thread 
Endif

nHdlPrv := HeadProva(cLoteAtf,cRotCont,cUserCont,@cArquivo)  

While !(cAlsRegs)->(Eof())
	cPadrao := Alltrim((cAlsRegs)->LP)
	If Ascan(aLPadrao, cPadrao) == 0
		If VerPadrao(cPadrao)
			Aadd(aLPadrao, cPadrao)
			lProcessa := .T.
		Else
			lProcessa := .F.
		Endif
	Else
		lProcessa := .T.
	Endif
	If lProcessa
		/*
 		 * Tratamento na contabiliza��o da quebra por filial e por processo para gera��o de um novo documento
 		 */
		If cQuebraPrc == 1
			If EMPTY(cLPAtual)
				cLPAtual := cPadrao
			ElseIf cLPAtual <> cPadrao
				cLPAtual := cPadrao
				
				If nTotal > 0
					RodaProva(nHdlPrv,nTotal)
					cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,cMostraLanc == 1,cAglutLanc == 1,,,,@aFlagCTB)
				EndIf
				
				nTotal := 0
			EndIf
		EndIf
		
		/*
 		 * Tratamento na contabiliza��o da quebra por filial para gera��o de um novo documento
 		 */
		If cConsidFil == 1
			If EMPTY(cFilAtua)
				cFilAtua := (cAlsRegs)->FILIAL
				cFilAnt	:= (cAlsRegs)->FILIAL
			ElseIf cFilAtua <> (cAlsRegs)->FILIAL
				cFilAtua 	:= (cAlsRegs)->FILIAL
				
				If nTotal > 0
					RodaProva(nHdlPrv,nTotal)
					cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,cMostraLanc == 1,cAglutLanc == 1,,,,@aFlagCTB)
				EndIf
				
				cFilAnt	:= (cAlsRegs)->FILIAL
				
				nTotal := 0
			EndIf
		EndIf
		
		/*
		 * Posiciona nas tabelas necess�rios para criar as linhas de detalhes da contabiliza��o.
		 */
		CTATFPOS(@cAlsRegs,.F.) 
		
		AAdd( aRegCTB,(cAlsRegs)->TABELA)
		AAdd( aRegCTB,(cAlsRegs)->RECNO)	

		If lUsaFlag
			aAdd(aFlagCTB,{(cAlsRegs)->CPOFLAG,"S",(cAlsRegs)->TABELA,(cAlsRegs)->RECNO,0,0,0})
		EndIf
		
		nValReg	:= 	DetProva(nHdlPrv,cPadrao,cRotCont ,cLoteAtf,,,,,,,,@aFlagCTB,aRegCTB) 
		
		nTotal		+=	nValReg 
		
		aRegCTB  := {} // Limpar para enviar novo posicionamento
		/*
		* Posiciona no registro que ser� contabilizado para atualizar a flag.
		*/
		If !lUsaFlag
			CTATFPOS(@cAlsRegs,nValReg > 0)
		EndIf
	EndIf
	(cAlsRegs)->(DbSkip())
EndDo

If nTotal > 0
	RodaProva(nHdlPrv,nTotal)
	cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,cMostraLanc == 1,cAglutLanc == 1,,,,@aFlagCTB)
EndIf

//End Transaction
aSize(aLPadrao, 0)
alPadrao := NIL
cFilAnt := cFilAux
RestArea(aSN4Area)
RestArea(aSN3Area)
RestArea(aSN1Area)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTAFGRVTMP
Fun��o que grava as informa��es dos registros de origem da contabiliza��o
numa tabela tempor�ria para montagem da contra-prova.

@author marylly.araujo
@since 14/01/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function CTAFGRVTMP(cAlsTabReg,aCampos,aValores)
Local nQtdCpo		:= Len(aCampos)
Local nContCpo	:= 0
Local nLinha		:= 0

For nLinha := 1 To Len(aValores)
	(cAlsTabReg)->(RecLock(cAlsTabReg,.T.))
	For nContCpo := 1 To nQtdCpo
		(cAlsTabReg)->&(aCampos[nContCpo][1]) := aValores[nLinha][nContCpo]
	Next nContCpo
	(cAlsTabReg)->(MsUnLock())
Next nLinha
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFPOS
Fun��o para posicionamento das tabelas necess�rios para montagem do
detalhe da contabiliza��o e para atualiza��o da flag dos registros
que foram contabilizados.

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function CTATFPOS(cAlsTabReg,lFlag)
Local lRet 		:= .T.
Local aSNWArea 	:= {}
Local aSNXArea 	:= {}
Local aSNYArea 	:= {}
Local aSNVArea 	:= {}
Local cTabOrig	:= (cAlsTabReg)->TABELA
Local cCpoFlag	:= (cAlsTabReg)->CPOFLAG
Local cCpoDtCtb	:= (cAlsTabReg)->CPODTCTB
Local aTabArea	:= (cAlsTabReg)->(GetArea())
Local aTabReg		:= {}
Local cChaveSN1	:= ""
Local cChaveSN3	:= ""
Local cFilSN3		:= xFILIAL("SN3")

Default lFlag := .F.

DbSelectArea(cTabOrig)
aTabReg := (cTabOrig)->(GetArea())
(cTabOrig)->(DbGoTo((cAlsTabReg)->RECNO))

If lFlag
	(cTabOrig)->(RecLock(cTabOrig,.F.))
	(cTabOrig)->&(cCpoFlag)	:= 'S'
	(cTabOrig)->&(cCpoDtCtb)	:= DDATABASE
	(cTabOrig)->(MsUnLock())
Else
	If cTabOrig == 'SN4'
		cChaveSN1 := cTabOrig + '->N4_CBASE + ' + cTabOrig + '->N4_ITEM '
		cChaveSN3 := cChaveSN1 + ' + ' + cTabOrig + "->N4_TIPO " //+ '0' + " + cTabOrig + '->N4_TPSALDO "
		
		SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
		SN3->(DbSeek(cFilSN3	+  &(cChaveSN3) ))
		
	ElseIf cTabOrig == 'SNX'
		SN3->(DbSetOrder(10)) // Filial + C�digo de Rateio de Despesa de Deprecia��o
		SN3->(DbSeek( cFilSN3 + SNX->NX_CODRAT ) )
		SN4->(DbSetOrder(1))             //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ                                                                                                
		SN4->(DbSeek(XFILIAL("SN4") + SN3->N3_CBASE + SN3->N3_ITEM + SN3->N3_TIPO + DTOS(SNX->NX_DTMOV) ) )
		
		cChaveSN1 := 'SN4->N4_CBASE + SN4->N4_ITEM '

	ElseIf cTabOrig == 'F43'
		SN3->(DbGoTo(F43->F43_SN3REC))
		
		cChaveSN1 := 'SN3->N3_CBASE + SN3->N3_ITEM '
	EndIf
		
	SN1->(DbSeek(XFILIAL('SN1') + &(cChaveSN1) ))
	
	/*
	 * Posicionamento das tabelas envolvidas no Rateio de Despesas de Deprecia��o
	 */
	If SN3->N3_RATEIO == "1" .and. !Empty(SN3->N3_CODRAT)
		cRevAtu := Af011GetRev(SN3->N3_CODRAT)
		
		DbSelectArea("SNV") // Crit�rio de Rateio de Despesa de Deprecia��o
		SNV->(DbSetOrder(1)) // Filial + C�digo de Rateio + Revis�o + Sequ�ncia
		SNV->(DbSeek( XFILIAL("SNV") +  SNX->NX_CODRAT + cRevAtu + SNX->NX_SEQUEN ) )
		
		DbSelectArea("SNW") // Saldo Di�rio de Rateio por Despesa de Deprecia��o
		SNW->(DbSetOrder(2)) // Filial + Conta Cont�bil + Centro de Custo + Item Cont�bil + Classe de Valor + Data do Saldo + Tipo de Saldo + Moeda
		SNW->(DbSeek( XFILIAL("SNW") + SNX->NX_NIV01 + SNX->NX_NIV02 + SNX->NX_NIV03 + SNX->NX_NIV04 + DTOS(SNX->NX_DTMOV) + SNX->NX_TPSALDO + SNX->NX_MOEDA ) )
		
		DbSelectArea("SNY") // Saldo Mensal de Rateio por Despesa de Deprecia��o
		SNY->(DbSetOrder(2)) // Filial + Conta Cont�bil + Centro de Custo + Item Cont�bil + Classe de Valor + Data �ltimo Dia M�s + Tipo de Saldo + Moeda
		SNY->(DbSeek( XFILIAL("SNY") + SNX->NX_NIV01 + SNX->NX_NIV02 + SNX->NX_NIV03 + SNX->NX_NIV04 + DTOS(LastDay(SNX->NX_DTMOV)) + SNX->NX_TPSALDO + SNX->NX_MOEDA ) )
	EndIf
EndIf

RestArea(aTabArea)

If cTabOrig == 'F43'
	DbSelectArea('F43')
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VlCpCtAtf
Fun��o para valida��o dos par�metros da tela de processamento da 
contabiliza��o Off-Line do Ativo Fixo.

@author marylly.araujo
@since 13/02/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function VlCpCtAtf()
Local lRet 		:= .T.
Local cCpo 		:= ReadVar()
Local nQtdProc := GetMv("MV_ATFCTHR", .F., 1 )


If UPPER(cCpo) == "MV_PAR01"	
	If MV_PAR01 == 1 .AND. nQtdProc > 1
		Help( " " ,1, "VLCPCTATF" ,, STR0038 ,1, 0 ) //"Os lan�amentos n�o podem ser exibidos quando o processamento ocorrer em multiplas threads. Verifique o par�metro MV_ATFCTHR."
		lRet := .F.
	EndIf
	
	If nQtdProc > 1 .AND. MV_PAR06 == 1
		Help( " " ,1, "QBPROCTATF" ,, STR0041,1, 0 ) //"N�o � poss�vel quebrar a contabiliza��o off-line por processo na contabiliza��o com m�ltiplas threads. Verifique os par�metros de processamento."
	EndIf
ElseIf UPPER(cCpo) == "MV_PAR03" .OR. UPPER(cCpo) == "MV_PAR04"
	If !EMPTY(MV_PAR03) .AND. !EMPTY(MV_PAR04) .AND. MV_PAR03 > MV_PAR04
		Help( " " ,1, "DTCPCTATF" ,, STR0039 ,1, 0 ) //"A data final do per�odo n�o pode ser maior que a data final para contabiliza��o. Verifique a data inicial e data final informadas."
		lRet := .F.
	EndIf
ElseIf UPPER(cCpo) == "MV_PAR05"
	If EMPTY(MV_PAR05)
		Help( " " ,1, "PRCPCTATF" ,, STR0040 ,1, 0 ) //"Informar os processos que deseja efetuar a contabiliza��o."
		lRet := .F.
	EndIf
ElseIf UPPER(cCpo) == "MV_PAR06"
	If nQtdProc > 1 .AND. MV_PAR06 == 1
		Help( " " ,1, "QBPROCTATF" ,, STR0041,1, 0 ) //"N�o � poss�vel quebrar a contabiliza��o off-line por processo na contabiliza��o com m�ltiplas threads. Verifique os par�metros de processamento."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFQF43
Fun��o de busca dos dados da tabela F43 das movimenta��es de Putting 
Into Operation feita no ambiente do Ativo Fixo (Deprecia��o).

@author felipe.morais
@since 22/05/2017
@version P12.1.16
/*/
//-------------------------------------------------------------------
Function CTATFQF43(cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil)
Local lRet			:= .T.
Local cAlsF43		:= GetNextAlias()
Local cQryF43		:= ''
Local aArea		:= GetArea()
Local aF43Area	:= {}
Local aValores	:= {}
Local cTmpF43Fil	:= ''

DbSelectArea('F43')
aF43Area := F43->(GetArea())

cQryF43 := "SELECT T0.R_E_C_N_O_ AS F43_RECNO," + CRLF
cQryF43 += "	T0.F43_FILIAL," + CRLF
cQryF43 += "	'RU01T01' AS ORIGEM," + CRLF
cQryF43 += "	T0.F43_DATA," + CRLF
cQryF43 += "	T0.F43_OPER" + CRLF
cQryF43 += "FROM " + RetSQLName("F43") + " T0" + CRLF
cQryF43 += "WHERE T0.D_E_L_E_T_ = ' '" + CRLF
If cConsidFil == 2
	cQryF43 += " AND T0.F43_FILIAL = '" + xFilial("F43",cFilAnt) + "' "
ElseIf cConsidFil == 1
	cQryF43 += " AND T0.F43_FILIAL " + GetRngFil( aSelFil, "F43", .T., @cTmpF43Fil ) 
	aAdd(aTmpFil, cTmpF43Fil)
EndIf
cQryF43 += "	AND T0.F43_LA <> 'S'" + CRLF
cQryF43 += "	AND T0.F43_DATA BETWEEN '" + DTOS(dDtInicial) + "'" + CRLF
cQryF43 += "		AND '" + DTOS(dDtFinal) + "'"

cQryF43 := ChangeQuery(cQryF43)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryF43), cAlsF43 , .F., .T.)

While !(cAlsF43)->(Eof())
	aAdd(aValores,{(cAlsF43)->F43_FILIAL,;
					 (cAlsF43)->ORIGEM,;
					 (cAlsF43)->F43_RECNO,;
					 Iif((cAlsF43)->F43_OPER == "P", "8A2", "8A3"),;
					 'F43',;
					 'F43_LA',;
					 'F43_DATA', " "})	
	(cAlsF43)->(DbSkip())
EndDo

CTAFGRVTMP(@cAlsTabReg,aCampos,aValores)

(cAlsF43)->(DbCloseArea())

RestArea(aF43Area)
RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CAtfPopTmp
Fun��o para popular a tabela tempor�ria por procedure

@author Totvs
@since 17/06/2021
@version P12
/*/
//-------------------------------------------------------------------
Function CAtfPopTmp(cAlsTabReg, nAtvJaClas, cIdMov, dDtInicial, dDtFinal, cConsidFil, aSelFil)
Local lRet		:= .T.
Local cAlsSN4	:= GetNextAlias()
Local cQrySN4	:= ''
Local aArea	    := GetArea()
Local aSN4Area	:= {}
Local cProcName := Criatrab(,.F.)+"_ATFA050"
Local cQry      := ""
Local nRet      := 0
Local cTmpSN4Fil:= '' 

Default nAtvJaClas := 1
Default cIdMov     := ""
Default dDtInicial := dDataBase
Default dDtFinal   := dDataBase
Default aSelFil    := {}

cQry:= "Create procedure "+cProcName+"_"+cEmpAnt+"("+ CRLF
cQry+= "   @OUT_RESULT Char( 01 ) OutPut"+ CRLF
cQry+= ")"+ CRLF
/* ------------------------------------------------------------------------------------
 Vers�o          - <v>  Protheus P.12 </v>
    Assinatura      - <a>   </a>
    Fonte Protheus  - <s>  ATFA050.PRX </s>
    Descricao       - <d>  C�lculo de deprecia��o </d>
    Procedure       -      Popula tabela tempor�ria ATFA050_T1_D_MG_01 com os ddos para Contabiliza��o
    Funcao do Siga  -      CTATFQSN4  - Query de selecao de dadose grava��o na ATFA050_T1_D_MG_01 
                           CTAFGRVTMP - Grava dados no temp ATFA050_T1_D_MG_01 ( tirada a gravacao no array aValores)
    Entrada         - <ri>
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>

    Obs: a vari�vel @iTranCount = 0 ser� trocada por 'commit tran' no CFGX051 pro SQLSERVER 
   -------------------------------------------------------------------------------------- */
cQry+= "as"+ CRLF
cQry+= "Declare @cN4_FILIAL  Char("+Str(TamSX3("N4_FILIAL")[1])+")"+ CRLF
cQry+= "Declare @cN4_ORIGEM  Char("+Str(TamSX3("N4_ORIGEM")[1])+")"+ CRLF
cQry+= "Declare @cN4_LP      Char("+Str(TamSX3("N4_LP")[1])+")"+ CRLF
cQry+= "Declare @cN4_DCONTAB Char( 10 )"+ CRLF
cQry+= "Declare @cN4_IDMOV   Char("+Str(TamSX3("N4_IDMOV")[1])+")"+ CRLF
cQry+= "Declare @cCPOFLAG    VarChar( 10 )"+ CRLF
cQry+= "Declare @cTabela     Char( 03 )"+ CRLF
cQry+= "Declare @iRecnoSN4   Integer"+ CRLF
cQry+= "Declare @iRecnoTMP   Integer"+ CRLF
cQry+= "Declare @iCont       Integer"+ CRLF
cQry+= "Declare @iTranCount  Integer "+ CRLF   //--Var.de ajuste para SQLServer e Sybase.-- Ser� trocada por Commit no CFGX051 ap�s passar pelo Pars
cQry+= "Begin "+ CRLF
   
cQry+= "   Select @OUT_RESULT  = '0'"+ CRLF
cQry+= "   Select @iRecnoTMP   = 0"+ CRLF
cQry+= "   Select @iCont       = 0"+ CRLF
cQry+= "   Select @cTabela     = 'SN4'"+ CRLF
cQry+= "   Select @cCPOFLAG    = 'N4_LA'"+ CRLF
cQry+= "   Select @iCont       = 0"+ CRLF

cQry+= "   Declare CUR_PopTmpAtf insensitive Cursor  for"+ CRLF
cQry+= "    SELECT SN4.N4_FILIAL, SN4.N4_ORIGEM,  SN4.N4_LP, SN4.N4_DCONTAB, SN4.N4_IDMOV,  SN4.R_E_C_N_O_"+ CRLF
cQry+= "      FROM "+RetSQLName("SN4")+" SN4 "+ CRLF
If nAtvJaClas == 2
	cQry+= " , "+RetSqlName("SN1")+" SN1 "+ CRLF
Endif

cQry+= "     WHERE SN4.N4_LA       != 'S' "+ CRLF
cQry+= "       and SN4.N4_DATA BETWEEN '" + DTOS(dDtInicial) + "' AND '" + DTOS(dDtFinal) + "' "
cQry+= "       and SN4.D_E_L_E_T_ = ' ' "+ CRLF
If nAtvJaClas == 2 
	cQry+= "       and SN1.N1_STATUS   !=  '0' "+ CRLF
	cQry+= "       and SN1.D_E_L_E_T_  = ' ' "+ CRLF
	cQry+= "       and SN1.N1_FILIAL   = SN4.N4_FILIAL "
	cQry+= "       and SN1.N1_CBASE    = SN4.N4_CBASE "
	cQry+= "       and SN1.N1_ITEM     = SN4.N4_ITEM "
EndIf
If cConsidFil == 2
	cQry+= "       and SN4.N4_FILIAL = '" + xFilial("SN4",cFilAnt) + "' "
ElseIf cConsidFil == 1
    If Len(aSelFil) > 0 
		cQry+= "       and SN4.N4_FILIAL " + GetRngFil( aSelFil, "SN4", .T., @cTmpSN4Fil ) 
	Endif
EndIf
If !Empty(cIdMov)
	cQry+= "       and SN4.N4_IDMOV    = '"+cIdMov+"'" +CRLF
EndIf

cQry+= "   For read only "+ CRLF
cQry+= "   Open CUR_PopTmpAtf "+ CRLF
cQry+= "   Fetch CUR_PopTmpAtf into  @cN4_FILIAL, @cN4_ORIGEM, @cN4_LP, @cN4_DCONTAB, @cN4_IDMOV, @iRecnoSN4 "+ CRLF
    
cQry+= "    While (@@Fetch_status = 0 ) begin "+ CRLF
cQry+= "      select @iRecnoTMP = @iRecnoTMP + 1 "+ CRLF
cQry+= "      select @iCont     = @iCont + 1 "+ CRLF

cQry+= "      if @iCont = 1 begin"+ CRLF
cQry+= "         Begin tran "+ CRLF
cQry+= "         select @iCont = @iCont "+ CRLF
cQry+= "      End "+ CRLF
cQry+= "      Select @cN4_DCONTAB = 'N4_DCONTAB'"+ CRLF
      /* --------------------------------------------------
         Insert na TMP
         -------------------------------------------------- */
cQry+= "      Insert into "+ cAlsTabReg+" ( FILIAL, ORIGEM,      RECNO,      LP,      TABELA,   CPOFLAG,   CPODTCTB,     IDMOV,      R_E_C_N_O_ ) "+ CRLF
cQry+= "                       Values (@cN4_FILIAL, @cN4_ORIGEM, @iRecnoSN4, @cN4_LP, @cTabela, @cCPOFLAG, @cN4_DCONTAB, @cN4_IDMOV, @iRecnoTMP ) "+ CRLF
       /* --------------------------------------------------
         COMMIT a cada 2000 linhas inseridas
         -------------------------------------------------- */
cQry+= "      if @iCont >= 2000 begin "+ CRLF
cQry+= "         commit tran  "+ CRLF
cQry+= "         select @iCont = 0 "+ CRLF
cQry+= "      End "+ CRLF
cQry+= "      Fetch CUR_PopTmpAtf into @cN4_FILIAL, @cN4_ORIGEM, @cN4_LP, @cN4_DCONTAB, @cN4_IDMOV, @iRecnoSN4 "+ CRLF
cQry+= "   End "+ CRLF
cQry+= "   if @iCont > 0 begin "+ CRLF
cQry+= "      commit tran "+ CRLF
cQry+= "      select @iTranCount = 0 "+ CRLF
cQry+= "   End "+ CRLF
cQry+= "   close CUR_PopTmpAtf "+ CRLF
cQry+= "   deallocate CUR_PopTmpAtf "+ CRLF
cQry+= "   Select @OUT_RESULT = '1' "+ CRLF
cQry+= "End "+ CRLF

cQry := MsParse( cQry, Alltrim(TcGetDB()))
cQry := CtbAjustaP(.F., cQry, 0)

If Empty( cQry )
	MsgAlert("Procedure para popular TMP nao passou pelo Parse. "+cProcName+CRLF+MsParseError(),"Erro")  //"A query da filial nao passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProcName+"_"+cEmpAnt )
		nRet := TcSqlExec(cQry)
		If nRet <> 0
			If !IsBlind()
				MsgAlert("Erro na criacao da procedure  : "+cProcName,"Erro")  //"Erro na criacao da proc filial: "
				lRet:= .F.
			EndIf
		Else 
			aResult := TCSPExec( xProcedures(cProcName) )
			If Empty(aResult) .Or. aResult[1] = "0"
				MsgAlert("Erro na Execucao da Procedure : "+cProcName+tcsqlerror(),"Erro")
				lRet := .F.
			Else
				If TCSPExist( cProcName+"_"+cEmpAnt )
					If TcSqlExec("DROP PROCEDURE "+ cProcName+"_"+cEmpAnt) <> 0
						UserException("Erro na exclus�o da Procedure" + cProcName+"_"+cEmpAnt + CRLF + TCSqlError() )
					EndIf
				Endif
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)
