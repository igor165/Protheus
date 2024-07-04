#INCLUDE "CTBA370.ch"
#Include "PROTHEUS.Ch"


// 17/08/2009 -- Filial com mais de 2 caracteres
Static lFWCodFil := FindFunction("FWCodFil")
STATIC __lBlind		:= IsBlind()

// TRADUÇÃO RELEASE P10 1.2 - 21/07/08
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTBA370  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 21.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recalcula o valor dos lancamentos em moedas fortes.        ³±±
±±³          ³ de acordo com os lancamentos contabeis                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA370(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA370(lBat)

Local nOpca	:= 0
Local aSays	:= {}, aButtons := {}	

DEFAULT lBat := IsBlind()
                      
Private cCadastro := STR0001 //"Atualizacao de Lancamentos em Moedas"
Private dDataLanc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // A partir da Data                                 ³
//³ mv_par02 // Ate a Data                                       ³
//³ mv_par03 // Moedas - Especificas ou Todas                    ³
//³ mv_par04 // Qual moeda ?                                     ³
//³ mv_par05 // Qual Tipo de Saldo - F3 - SLD                    ³
//³ mv_par06 // Considera criterio - Plano de Contas/Lancamento  ³
//³ mv_par07 // Reprocessa Saldos?                               ³
//³ mv_par08 // Filial De ?                                      ³
//³ mv_par09 // Filial Ate ?                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Pergunte("CTB370",.f.)

AADD(aSays, STR0002 ) //"Este programa tem como objetivo recalcular o valor dos  lancamentos contabeis dentro"
AADD(aSays,	STR0003 ) //"de um determinado periodo. Podera ser utilizado quando"
AADD(aSays,	STR0004 ) //"for alterado o criterio de conversao no plano de contas."
AADD(aSays,	STR0009 ) //"Rodar o Reprocessamento Contabil do periodo informado caso a atualizacao de saldos nao seja on line."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

AADD(aButtons, { 5,.T.,{|| Pergunte("CTB370",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(),FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

If ! lBat
	FormBatch( cCadastro, aSays, aButtons,, 200, 600 )
Else
	nOpca := 1
Endif		

IF nOpca == 1

	If !CtbValiDt(,dDataBASE,,,,{"FIN001","FIN002"},)
		Return
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("INICIO")

	If !CTBSerialI("CTBPROC","OFF")
		Return
	Endif

	If !lBat
		Processa({|lEnd| Ct370Proc()})
	Else
		Ct370Proc(lBat)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("FIM")

	CTBSerialF("CTBPROC","OFF")
Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ca370Proc ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 21.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recalculo valor lanc moeda forte                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ca370Proc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CONA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct370Proc(lBat)

Local nCont, cMoed, nVal
Local lAtSldBase	:= Iif(GetMv("MV_ATUSAL")== "S",.T.,.F.)
Local cCriter		:= ""   
Local cAlias		:= ""
Local cFiltro		:= ""
Local cOrder		:= ""
Local cIndex		:= ""
Local nIndex		:= ""
Local nValMoeda	    := 0                      
Local nRecnoAnt		:= 0
Local __lCusto		:= CtbMovSaldo("CTT")
Local __lItem	  	:= CtbMovSaldo("CTD")
Local __lCLVL	  	:= CtbMovSaldo("CTH")
Local dData			:= CTOD("  / /  ")
Local cLote			:= ""
Local cSubLote		:= ""
Local cDoc			:= ""
Local cLinha		:= ""
Local cTpSald		:= ""
Local cEmpOri		:= ""
Local cFilOri		:= ""
Local nRegCT2		:= 0
Local lGravaCT2		:= .T.
Local cStatusBlq	:= GetNewPar("MV_CTGBLOQ","")
Local cKeyCT2		:= ""
Local dDtCV3		:= CTOD("  /  /  ")
Local lDtTxUso		:= .F.
Local dDataAnt		:= CTOD("  /  /  ")
Local cLoteAnt		:= ""
Local cSbLoteAnt	:= ""
Local cDocAnt		:= ""
Local nDif			:= 0
Local nRecAlias		:= 0
Local cUltLin		:= ""
Local aRecnos		:= {}

//A variavel lReproc, sera utilizada na gravacao de saldos. Caso nao seja para atualizar
//os saldos no momento da grav. dos lanc. contab., ira atualizar o saldo somente da DATA.
//Analogo ao Reprocessamento.
Local lReproc		:= Iif(lAtSldBase,.F.,.T.)
Local aDecCols		:= {}
Local lPodeGrv		:= .F.
Local cCampo 		:= ""
Local cFilIni		:= ""
Local cFilFim		:= ""
Local cQuery		:= ""
Local lRetorno      := .T.
Local aProc 		:= {}
Local cProc         := ""
Local nX		    := 1
Local cArqTrb 		:= ""
Local cArq   		:= ""
Local cMoeda        := ""
Local nMoedas       := 0
Local aArea         := {}
Local nRet          := 0
Local cExec         := ""
Local cTpSaldo      :=""
Local lTpSaldo      := .T. 
Local nSoma         := GetMv("MV_SOMA")
Local cTDataBase    := ""
Local aDataBase     := {}
Local nPos          := 0
Local lTrbProc
                       
DEFAULT lBat := .F.

For nCont	:= 2 to __nQuantas
	If CtbUso("CT2_DTTX"+StrZero(nCont,2))			
		lDtTxUso		:= .T.
		Exit		
	EndIf
Next   

If Empty(cStatusBlq)
	cStatusBlq := "234"
Endif
aCols 		:= {}
aColsOri	:= {}

lRet := VlDtCal(mv_par01,mv_par02,mv_par03,mv_par04,cStatusBlq,!lBat,Trim(mv_par05))	/// VALIDA PERIODOS BLOQUEADOS NO CALENDARIO DENTRO DO INTERVALO DE DATAS 

If lRet

	cCampo := "SX5->(X5DESCRI())"
	// Verifica se existe apuracao na data, moeda e tipo de saldo informado.	
	dbSelectarea("SX5")
	dbSetOrder(1)
	If MsSeek(xFilial("SX5")+"LP"+cEmpAnt+cFilAnt, .F.)
		While SX5->(!Eof()) .and. SX5->X5_FILIAL = xFilial() .And. SubStr(SX5->X5_CHAVE,1,2) == cEmpAnt .And. SubStr(SX5->X5_CHAVE,3,2) == cFilAnt
  			If Substr(&cCampo, 1, 8) >= Dtos(mv_par01)
  				If Substr(&cCampo, 11, 1 ) = Trim(mv_par05)
  					If mv_par03 = 2 .or. (mv_par03 = 1 .and. Substr(&cCampo, 9, 2) = If(Empty(mv_par04),'00',Trim(mv_par04)))
  						If !lBat
	  						MsgAlert(STR0008) //"O Ajuste de Moedas nao deve ser executado para periodos que tiveram Apuracao de Resultados. Certifique-se de que nao existe apuracao de resultados na data, moeda e tipo de saldo informados "
	  					EndIf
  						lRet:= .f.
  						Exit
  					EndIf
  				EndIf
  			Endif
			SX5->(dbSkip())
		EndDo
	EndIf
Endif

If Empty(mv_par09)
	Help(NIL, NIL, STR0024 /*"Filial até"*/, NIL, STR0025/*"Parâmetro filial até, não foi informado"*/, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0026/*"Necessário informar o parâmetro filial até"*/})
	lRet := .F.	
EndIf

If !lRet
	Return
Endif

cFilIni := mv_par08	
cFilFim := mv_par09

aadd(aDatabase,{"MSSQL" })
aadd(aDatabase,{"MSSQL7" })
aadd(aDatabase,{"ORACLE" })
aadd(aDatabase,{"DB2" })
aadd(aDatabase,{"SYBASE" })
aadd(aDatabase,{"INFORMIX" })
If Trim(Upper(TcSrvType())) = "ISERIES"
	// Top 4 para AS400, instala procedures = DB2
	aadd(aDatabase,{"DB2/400"})
EndIf
cTDataBase = Trim(Upper(TcGetDb()))
nPos:= Ascan( aDataBase, {|z| z[1] == cTDataBase })

If nPos == 0
	lRetorno := .F.	
EndIf

If lRetorno
	//Reprocessa Saldos no periodo
	If mv_par07 = 1
		CTBA190(.T., mv_par01, mv_par02, cFilIni, cFilFim, mv_par05, If(mv_par03 = 2, .T., .F.), If(Empty(mv_par04), "00",mv_par04))
	EndIf
	aArea := GetArea()
	cMoeda   := ""
	If mv_par03 = 2  //moeda especifica
		cMoeda := Trim(mv_par04)
		If cMoeda != "01"
			nMoedas := 1
		EndIf
	else
		dbSelectArea("CTO")
		dbSetOrder(1)
		dbSeek(xFilial())
		While !Eof() .And. xFilial() == CTO->CTO_FILIAL
			If CTO->CTO_MOEDA != '01' .and. CTO->CTO_BLOQ = '2'
				nMoedas++
				cMoeda += CTO->CTO_MOEDA
			EndIf
			dbSkip()
		EndDo
	EndIf
	/* Ordem de chamada das procedures - NAO EXCLUIR OS COMENTARIOS
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Criacao de procedure de dinamica  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  1.  CTBA370Proc     - Pai - Chamador.................................... aProc[3]
          1.1 CTBA370A    - Retorna o valor convertido........................ aProc[2]
      0. CallXFilial - xfilial - Cria procedure xfilial Gestao Corporativa ... aProc[1]  */
		
	If nMoedas > 0
		If lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CallXFilial - Cria procedure xfilial Gestao Corporativa ........ aProc[1] ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aProc   :={}
			nX      := 1
			cArq    := CriaTrab(,.F.)
			cArqTrb := cArq+StrZero(nX,2)
			cProc   := cArqTrb+"_"+cEmpAnt
			AADD( aProc, cProc)
			lRetorno := CallXFilial(cProc)
		EndIf
		/*-*/
		If lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CTBA370A - Cria procedure q retorna vlr convertido  ...............Proc[2]³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nX := nX + 1
			cArqTrb := cArq+StrZero(nX,2)
			cProc   := cArqTrb+"_"+cEmpAnt
			AADD( aProc, cProc)
			lRetorno := CTBA370A(cProc, aProc)
		EndIf
		/* Criacao da procedure Chamadora - Proc[5]*/
		If lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CTBA370Proc - Cria procedure Pai ..................................Proc[3]³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nX := nX + 1
			cArqTrb := cArq+StrZero(nX,2)
			cProc   := cArqTrb+"_"+cEmpAnt
			AADD( aProc, cProc)
			lRetorno := CTBA370Proc(cProc, aProc, nMoedas, cMoeda, cFilIni, cFilFim)
		EndIf
		If lRetorno
			cProc := Trim(cArqTrb)
			If mv_par05 = '*'
				lTpSaldo := .F.
				cTpSaldo := Trim(mv_par05)
			Else
				lTpSaldo := .T.
				cTpSaldo := Trim(mv_par05)
			EndIf
			
			aResult := TCSPExec(xProcedures(cProc), cFilIni, cFilFim, Dtos(mv_par01), Dtos(mv_par02),;
					If( lTpSaldo, "1", "0" ), cTpSaldo,       cMoeda,         StrZero(mv_par06,1), If( nSoma = 1, "1", "2"))
					
			TcRefresh(RetSqlName("CT2"))
			If Empty(aResult) .Or. aResult[1] = "0"
				If !lBat
					MsgAlert(STR0010)  //"Erro na Atualizacao de moedas com procedures. O processo sera realizado pelo processo padrao."
				EndIf
				lRetorno := .F.
			Else
				CTBA190(.T.,mv_par01,mv_par02,cFilIni,cFilFim,mv_par05,.F.,"00")
			EndIf
		EndIf
		/* Exclusao de procedures */
		For nX = 1 to Len(aProc)
			If TCSPExist(aProc[nX])
				cExec := "Drop procedure "+aProc[nX]
				nRet := TcSqlExec(cExec)
				If nRet <> 0
					If !lBat
						MsgAlert(STR0011+aProc[nX]+STR0012)  //"Erro na exclusao da Procedure: ";". Excluir manualmente no banco"
					Endif
				Endif
			EndIf
		Next
		RestArea(aArea)
	Else
		lRetorno := .F.
	EndIf
Endif

If lRetorno
	Return
EndIf

CriaConv()

If 	(Ascan(aCols, { |x| x[1] = mv_par04 }) = 0) .Or.;
	(Len(aCols) = 1 .And. Empty(aCols[1][1]))
	If Len(aCols) = 1 .And. Empty(aCols[1][1])
		aCols := {}
	Endif
	DbSelectArea("CTO")
	dbSeek(xFilial()+"01",.T.)
	AADD(aCols, { "01", " ", 0.00, "2", "1", 0.00, CTO->CTO_DESC, .F. } )
	aSort(aCols,,,{|X,Y| x[1] < y[1]})
Endif

If mv_par03 = 2 .And. (nColMoeda := Ascan(aCols, { |x| x[1] = mv_par04 })) > 0
	aCols := { aCols[nColMoeda] }
Endif

dbSelectArea("CTO")
dbSetOrder(1)
For nCont := 1 to Len(aCols)
	If dbSeek(xFilial("CTO")+aCols[nCont][1])
		aAdd(aDecCols,CTO->CTO_DECIM)
	Else
		aAdd(aDecCols,2)	
	EndIf
Next
											
aColsOri := aClone(aCols)
											
dbSelectArea("CT2")
dbSetOrder(1)
cOrder := IndexKey()

cAlias := "CT2QRY"
cQuery	:= "SELECT CT2.R_E_C_N_O_ RECNO FROM " + RetSqlName("CT2") + " CT2 "
cQuery 	+= "WHERE CT2_FILIAL = '" + xFilial("CT2") + "' AND "
cQuery 	+= "CT2_DATA >= '" + Dtos(mv_par01) + "' AND CT2_DATA <= '" + Dtos(mv_par02) + "' "
cQuery	+= "AND CT2_MOEDLC = '01' AND D_E_L_E_T_=' ' "
If mv_par05 != "*"
	cQuery += " AND CT2_TPSALD = '"+ mv_par05 + "'"
EndIf
//BOPS 139805                                                            //
//PE C370MODQRY -> PARA CRIACAO DE CONDICOES PARA SER INCLUIDO NA QUERY. //
//RETORNO -> CARACTER.                                                   //
///////////////////////////////////////////////////////////////////////////
If ExistBlock("C370CODQRY")
	cQuery+= " AND "+ExecBlock("C370CODQRY",.F.,.F.)
EndIf
		
cQuery += "ORDER BY " +  SqlOrder(cOrder) + ",R_E_C_N_O_"
	
cQuery := ChangeQuery(cQuery)
		                     
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

While ! Eof() .And. CT2->CT2_DATA <= mv_par02
	
	dbSelectArea("CT2")
	dbGoto((cAlias)->RECNO)
	
	If CT2->CT2_MOEDLC <> '01'
		dbSkip()
		Loop
	EndIf
	aCols := aClone(aColsOri)

	MontaConv(	CT2->CT2_VALOR,CT2->CT2_DC,CT2->CT2_DATA,,;
		CT2->CT2_DEBITO,CT2->CT2_CREDIT,CT2->CT2_MOEDLC, mv_par06 = 2,,!lBat)
				
	BEGIN TRANSACTION

    //Guarda registro ref. a primeira moeda
		nRecnoAnt	:= CT2->(Recno())
	// Grava demais moedas -> a partir de aCols        
		For nCont 	 := 1 To Len(aCols)
			dbSelectArea("CT2")
			dbGoto(nRecnoAnt)
			cMoed	 := aCols[nCont][1]
			nVal 	 := NoRound(aCols[nCont][3], aDecCols[nCont])
		
			nValMoeda:=CtbVlrMoed(CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_LINHA,CT2->CT2_TPSALD,cMoed,CT2->CT2_EMPORI,CT2->CT2_FILORI)
			cCriter  := aCols[nCont][2]

			If Empty(cCriter)
				cCriter:= aCols[nCont][2]
			EndIf
			IF cCriter != "A"
				If Empty(cMoed) .Or. cMoed = CT2->CT2_MOEDLC .Or.	nValMoeda = nVal 	//Taxa informada
					Loop
				EndIf
		
				If mv_par03 == 2 //Se for moeda especifica
					If cMoed <> mv_par04
						Loop
					EndIf
				EndIf

		//Se o criterio de conversão atual é Informado (4) ou Nao possui criterio de Conversao (5) e 
		//o lancamento possui valor nessa moeda, deletar o lancamento existente nessa moeda.						
				If nValMoeda <> 0 .And. nVal == 0 .And. cCriter $ "45"
					cLote		:= CT2->CT2_LOTE
					cSubLote	:= CT2->CT2_SBLOTE
					cDoc		:= CT2->CT2_DOC
					cLinha		:= CT2->CT2_LINHA
					cTpSald		:= CT2->CT2_TPSALD
					cEmpOri		:= CT2->CT2_EMPORI
					cFilOri		:= CT2->CT2_FILORI
					dData		:= CT2->CT2_DATA

			// Desativa a atualização de saldos ( Sera executada por reprocessamento )
					If SuperGetMv("MV_CTA370S",.F.,"1") == "1"
						dbSelectArea("CT2")
						dbSetOrder(1)
						nRegCT2	:= Recno()
						If MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+cDoc+cLinha+cTpSald+cEmpOri+cFilOri+cMoed)
					//Se o criterio de conversao gravado no CT2 for "4", nao alterar valor. 
							If CT2->CT2_CRCONV <>  "4"
	
								aTravas := {}
			
								IF !Empty(CT2->CT2_DEBITO)
									AADD(aTravas,CT2->CT2_DEBITO)
								Endif
								IF !Empty(CT2->CT2_CREDIT)
									AADD(aTravas,CT2->CT2_CREDIT)
								Endif
							
						/// VERIFICA SE O SEMAFORO DE CONTAS PERMITE GRAVAÇÃO DOS LANÇAMENTOS/SALDOS
								If CtbCanGrv(aTravas,@lAtSldBase)
				
									RecLock("CT2",.F.,.T.)
									dbDelete()
									MsUnlocK()
									dbGoto(nRegCT2)
						    
							// DesGravacao de Saldos  --> cOperacao "-"
									CtbGravSaldo(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_DATA,;
										CT2->CT2_DC,cMoed,CT2->CT2_DEBITO,;
										CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
										CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nVal,CT2->CT2_TPSALD,;
										4,CT2->CT2_DEBITO,;
										CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
										CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nValMoeda,;
										CT2->CT2_DC,CT2->CT2_TPSALD,cMoed,;
										__lCusto,__lItem,__lClVL,,lAtSldBase,lReproc,CT2->CT2_DTLP,,,,,,,,,lTrbProc,"-"/*cOperacao*/)
								EndIf
							EndIf
						EndIf
						dbGoto(nRegCT2)
					EndIf
				Else

					cLote		:= CT2->CT2_LOTE
					cSubLote	:= CT2->CT2_SBLOTE
					cDoc		:= CT2->CT2_DOC
					cLinha		:= CT2->CT2_LINHA
					cTpSald		:= CT2->CT2_TPSALD
					cEmpOri		:= CT2->CT2_EMPORI
					cFilOri		:= CT2->CT2_FILORI
					dData		:= CT2->CT2_DATA
					cKeyCT2		:= CT2->CT2_KEY
					dDtCV3		:= CT2->CT2_DTCV3
                                         
					dbSelectArea("CT2")
					dbSetOrder(1)
					nRegCT2	:= Recno()
					If MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+cDoc+cLinha+cTpSald+cEmpOri+cFilOri+cMoed)
						If CT2->CT2_CRCONV ==  "4"
							lGravaCT2	:= .F.
						EndIf
					EndIf
					dbGoto(nRegCT2)

					If lGravaCT2

						aTravas := {}
	
						IF !Empty(CT2->CT2_DEBITO)
							AADD(aTravas,CT2->CT2_DEBITO)
						Endif
						IF !Empty(CT2->CT2_CREDIT)
							AADD(aTravas,CT2->CT2_CREDIT)
						Endif
				
				/// VERIFICA SE O SEMAFORO DE CONTAS PERMITE GRAVAÇÃO DOS LANÇAMENTOS/SALDOS
						If CtbCanGrv(aTravas,@lAtSldBase)
		
					// Desativa a atualização de saldos ( Sera executada por reprocessamento )
							If SuperGetMv("MV_CTA370S",.F.,"1") == "1"
						// DesGravacao de Saldos  --> cOperacao "-"
								CtbGravSaldo(	CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_DATA,;
									CT2->CT2_DC,cMoed,CT2->CT2_DEBITO,;
									CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
									CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nVal,CT2->CT2_TPSALD,;
									4,CT2->CT2_DEBITO,;
									CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
									CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nValMoeda,;
									CT2->CT2_DC,CT2->CT2_TPSALD,cMoed,;
									__lCusto,__lItem,__lClVL,,lAtSldBase,lReproc,CT2->CT2_DTLP,,,,,,,,,lTrbProc,"-"/*cOperacao*/)

						// Gravacao dos Saldos de Contas
								CtbGravSaldo(	CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_DATA,;
									CT2->CT2_DC,cMoed,CT2->CT2_DEBITO,;
									CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
									CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nVal,CT2->CT2_TPSALD,;
									4,CT2->CT2_DEBITO,;
									CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
									CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nValMoeda,;
									CT2->CT2_DC,CT2->CT2_TPSALD,cMoed,;
									__lCusto,__lItem,__lClVL,,lAtSldBase,lReproc,CT2->CT2_DTLP,,,,,,,,,,"+"/*cOperacao*/)
					  
							EndIf
		    
							CtGrVlMoed(CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_LINHA,CT2->CT2_TPSALD,;
								cMoed,CT2->CT2_EMPORI,CT2->CT2_FILORI,nVal,;
								CT2->CT2_DC,CT2->CT2_DEBITO,CT2->CT2_DCD,CT2->CT2_CREDIT,CT2->CT2_DCC,CT2->CT2_CCD,CT2->CT2_CCC,;
								CT2->CT2_ITEMD,CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,	CT2->CT2_LP,CT2->CT2_SEQUEN,;
								CT2->CT2_ORIGEM,CT2->CT2_AGLUT,cCriter,CT2->CT2_HP,CT2->CT2_HIST,CT2->CT2_SEQLAN,CT2->CT2_SEQHIS,;
								CT2->CT2_DTLP,CT2->CT2_SLBASE,cKeyCT2,dDtCV3)
						EndIf
					EndIf
					lGravaCT2	:= .T.
				EndIf
			EndIf
		Next nCont
	END TRANSACTION


	dDataAnt	:= CT2->CT2_DATA
	cLoteAnt	:= CT2->CT2_LOTE
	cSbLoteAnt	:= CT2->CT2_SBLOTE
	cDocAnt		:= CT2->CT2_DOC
	cUltLin		:= CT2->CT2_LINHA
	
	DbSelectArea(cAlias)
	DbSkip()

	dbSelectArea("CT2")
	dbGoto((cAlias)->RECNO)
	
	//Se mudar o documento, verificar o total debito/credito nas outras moedas.		

	nRecAlias		:= CT2->(Recno())
	
	If DTOS(dDataAnt) <> DTOS(CT2->CT2_DATA) .Or. cLoteAnt <> CT2->CT2_LOTE .Or. ;
			cSbLoteAnt	<> CT2->CT2_SBLOTE .Or. cDocAnt <> CT2->CT2_DOC
		
		For nCont := 1 to Len(aCols)
			If StrZero(nCont,2) == '01'
				Loop
			EndIf

			aRecnos 	:= {}
			//Se houver diferenca debito/credito em outra moeda, gera a diferença na ultima linha	
			nDif := Ctba370DIf(dDataAnt,cLoteAnt,cSbLoteant,cDocAnt,StrZero(nCont,2),@aRecnos)

			If nDif <> 0  .And. ( Abs( nDif ) <= 0.02 )	// Diferenca menor que 2 centavos.
				dbSelectArea("CT2")
				If nDif > 0 				//Alterar a diferenca a debito
					dbgoto(aRecnos[1][2])
				ElseIf nDif < 0
					dbgoto(aRecnos[2][2])
				EndIf

				RecLock( "CT2" , .F. )

				CT2->CT2_VALOR	+= Abs( nDif )

				MsUnlock()
			EndIf
			
		Next
		
	EndIf
	dbSelectArea("CT2")
	dbGoto(nRecAlias)
	
EndDo

dbSelectArea(cAlias)
dbCloseArea()

dbSelectArea("CT2")
dbSetOrder(1)

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctba370Dif³ Autor ³ Simone Mie Sato       ³ Data ³ 09.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o total debito/credito na outra moeda.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ca370VlDoc)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data                                               ³±±
±±³          ³ ExpC1 = Lote                                               ³±±
±±³          ³ ExpC2 = SubLote                                            ³±±
±±³          ³ ExpC3 = Documento                                          ³±±
±±³          ³ ExpC4 = Moeda                                              ³±±
±±³          ³ ExpA1 = Matriz com os ult. reg. debito e credito           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba370DIf(dDataLan,cLoteLan,cSbLoteLan,cDocLan,cMoedaLan,aRecnos)

Local aSaveArea	:= GetArea()
Local nDebito	:= 0
Local nCredito	:= 0 
Local nDif		:= 0 
Local nCont		:= 0

For nCont	:= 1 to 2
	AADD(aRecnos,{Str(ncont,1),0})
Next

dbSelectArea("CT2")
dbSetOrder(1)
If MsSeek(xFilial()+DTOS(dDataLan)+cLoteLan+cSbLoteLan+cDocLan)
	While !Eof() .And. xFilial() == CT2->CT2_FILIAL  .And. DTOS(dDataLan) == DTOS(CT2->CT2_DATA) .And. ;
		CT2->CT2_LOTE == cLoteLan .And. CT2->CT2_SBLOTE == cSbLoteLan .And. CT2->CT2_DOC == cDocLan 
		
		If CT2->CT2_MOEDLC <> cMoedaLan
			dbSkip()
			Loop
		EndIf		
	
		If CT2->CT2_DC $ "1/3"	
			nDebito	+= CT2->CT2_VALOR
			If CT2->CT2_DC == "1"
				aRecnos[1][2]	:= CT2->(Recno())
			EndIf				
		EndIf
		
		If CT2->CT2_DC $ "2/3"
			nCredito += CT2->CT2_VALOR
			If CT2->CT2_DC == "2"
				aRecnos[2][2]	:= CT2->(Recno())		
			EndIF
		EndIf				
		
       dbSkip()
	End
EndIf        

nDif := NoRound(Round(nCredito,3)) - NoRound(Round(nDebito,3)) 

RestArea(aSaveArea)

Return(nDif)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTBA370A   ³ Autor ³                       ³ Data ³20.10.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria a procedure de conversao de valores                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = cCubo - Codigo do Cubo a ser atualizado             ³±±
±±³          ³ ExpC2 = cArq  - Nome da procedure q sera criada no banco    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA370A(cProc, aProc)
Local lRet     := .T.
Local nRet     := 0
Local cQuery   := ""

cQuery:="Create Procedure "+cProc+CRLF
cQuery+="("+CRLF
cQuery+="   @IN_FILIAL Char( " + IIf( lFWCodFil, Str( FWGETTAMFILIAL ), "02" ) + " ),"+CRLF
cQuery+="   @IN_DATA   Char( 08 ),"+CRLF
cQuery+="   @IN_VALOR  Float,"+CRLF
cQuery+="   @IN_MOEDA  Char( 02 ),"+CRLF
cQuery+="   @IN_CRITER Char( 01 ),"+CRLF
cQuery+="   @OUT_VALOR Float OutPut"+CRLF
cQuery+=" )"+CRLF

cQuery+="as"+CRLF
/* -------------------------------------------------------------------------------------------------------------------------------- 
   Versão          - <v>  Protheus 9.12 </v>
   Assinatura      - <a>  001 </a>
   Fonte Microsiga - <s>  CTBA101.PRW </s>
   Descricao       - <d>  Conversao de Moedas </d>
   Procedure       -      Converter o valor da Moeda de acordo com o Criterio de conversao
   Funcao do Siga  -      CtbConv()
   Entrada         - <ri> @IN_FILIAL     - Filial Corrente
                          @IN_DATA       - Data       
                          @IN_VALOR      - Valor a Converter
                          @IN_MOEDA      - Moeda a converter
                          @IN_CRITER     - Criterio de conversao  </ri>
   Saida           - <o>  @OUT_VALOR     - Valor Convertido </ro>
   
   @IN_CRITER  IN ( '1','9') -> Diario
                  ( '2','8') -> Mensal
                  ( '3','7') -> Ultimo Dia
                        '4'  -> Informado    -> Retorna valor 0
                        '5'  -> Nao Converte -> Retorna valor 0
                        'A'  -> Nao Ajusta   -> Retorna valor 0
   -------------------------------------------------------------------------------------------------------------------------------- */
cQuery+="Declare @cFil_CTO Char( " + IIf( lFWCodFil, Str( FWGETTAMFILIAL ), "02" ) + " )"+CRLF
cQuery+="Declare @cFil_CTP Char( " + IIf( lFWCodFil, Str( FWGETTAMFILIAL ), "02" ) + " )"+CRLF
cQuery+="Declare @cFil_CTG Char( " + IIf( lFWCodFil, Str( FWGETTAMFILIAL ), "02" ) + " )"+CRLF
cQuery+="Declare @cAux     Char( 03 )"+CRLF
cQuery+="Declare @nTaxa    Float"+CRLF
cQuery+="Declare @nValor   Float"+CRLF
cQuery+="Declare @nDecimal Integer"+CRLF
cQuery+="Declare @cDataIni Char( 08 )"+CRLF
cQuery+="Declare @cDataFim Char( 08 )"+CRLF
cQuery+="Declare @iDias    Integer"+CRLF

cQuery+="begin"+CRLF
cQuery+="   select @OUT_VALOR = 0"+CRLF
cQuery+="   select @nValor = 0"+CRLF
cQuery+="   Select @nDecimal = 2"+CRLF
cQuery+="   Select @cDataIni = ' '"+CRLF
cQuery+="   Select @cDataFim = ' '"+CRLF
cQuery+="   Select @iDias  = 0"+CRLF
cQuery+="   Select @nTaxa  = 0"+CRLF
   
cQuery+="   Select @cAux = 'CTO'"+CRLF
cQuery+="   Exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CTO OutPut"+CRLF
cQuery+="   Select @cAux = 'CTP'"+CRLF
cQuery+="   Exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CTP OutPut"+CRLF
cQuery+="   Select @cAux = 'CTG'"+CRLF
cQuery+="   Exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CTG OutPut"+CRLF
cQuery+="   Select @nDecimal = IsNull(CTO_DECIM, 2 )"+CRLF
cQuery+="     From "+RetSqlName("CTO")+CRLF
cQuery+="    Where CTO_FILIAL = @cFil_CTO"+CRLF
cQuery+="      and CTO_MOEDA  = @IN_MOEDA"+CRLF
cQuery+="      and D_E_L_E_T_ = ' '"+CRLF
   
   /* ----------------------- Diario -----------------  */
cQuery+="   If ( @IN_CRITER = '1' OR @IN_CRITER = '9' ) begin"+CRLF
      
cQuery+="      Select @nTaxa = IsNull( CTP_TAXA, 0 )"+CRLF
cQuery+="        From "+RetSqlName("CTP")+CRLF
cQuery+="       Where CTP_FILIAL = @cFil_CTP"+CRLF
cQuery+="         and CTP_DATA   = @IN_DATA"+CRLF
cQuery+="         and CTP_MOEDA  = @IN_MOEDA"+CRLF
cQuery+="         and D_E_L_E_T_ = ' '"+CRLF
      
cQuery+="      If @nTaxa != 0 Select @nValor = Round(( @IN_VALOR/ @nTaxa ), @nDecimal )"+CRLF
      
cQuery+="   End"+CRLF
   /* ----------------------- media Mensal -----------------  */
cQuery+="   If ( @IN_CRITER = '2' OR @IN_CRITER = '8' ) begin"+CRLF
      
cQuery+="      Select @cDataIni = IsNull(CTG_DTINI, ' '), @cDataFim = IsNull(CTG_DTFIM, ' ')"+CRLF
cQuery+="        from "+RetSqlName("CTG")+CRLF
cQuery+="       where CTG_FILIAL = @cFil_CTG"+CRLF
cQuery+="         and @IN_DATA BETWEEN CTG_DTINI AND CTG_DTFIM"+CRLF
cQuery+="         and D_E_L_E_T_ = ' '"+CRLF
      
cQuery+="      Select @iDias = Count(*), @nTaxa = Sum( CTP_TAXA )"+CRLF
cQuery+="        From "+RetSqlName("CTP")+CRLF
cQuery+="       Where CTP_FILIAL = @cFil_CTP"+CRLF
cQuery+="         and CTP_MOEDA  = @IN_MOEDA"+CRLF
cQuery+="         and CTP_DATA   BETWEEN @cDataIni and @cDataFim"+CRLF
cQuery+="         and D_E_L_E_T_ = ' '"+CRLF
      
cQuery+="      If @iDias > 0 select @nTaxa = @nTaxa/@iDias"+CRLF
      
cQuery+="      If @nTaxa != 0 Select @nValor = Round(( @IN_VALOR/ @nTaxa ), @nDecimal )"+CRLF
cQuery+="   End"+CRLF
   /* ----------------------- Ultimo Dia do Periodo -----------------  */
cQuery+="   If ( @IN_CRITER = '3' OR @IN_CRITER = '7' ) begin"+CRLF
      
cQuery+="      Select @cDataFim = IsNull(CTG_DTFIM, ' ')"+CRLF
cQuery+="        from "+RetSqlName("CTG")+CRLF
cQuery+="       where CTG_FILIAL = @cFil_CTG"+CRLF
cQuery+="         and @IN_DATA BETWEEN CTG_DTINI AND CTG_DTFIM"+CRLF
cQuery+="         and D_E_L_E_T_ = ' '"+CRLF

cQuery+="      Select @nTaxa = IsNull(CTP_TAXA, 0 )"+CRLF
cQuery+="        From "+RetSqlName("CTP")+CRLF
cQuery+="       Where CTP_FILIAL = @cFil_CTP"+CRLF
cQuery+="         and CTP_MOEDA  = @IN_MOEDA"+CRLF
cQuery+="         and CTP_DATA   = @cDataFim"+CRLF
cQuery+="         and D_E_L_E_T_ = ' '"+CRLF
      
cQuery+="      If @nTaxa != 0 Select @nValor = Round(( @IN_VALOR/ @nTaxa ), @nDecimal )"+CRLF
cQuery+="   End"+CRLF
   
cQuery+="   select @OUT_VALOR = @nValor"+CRLF
cQuery+="End"+CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery)

If Empty( cQuery )
	If !__lBlind
		MsgAlert(STR0020+cProc+STR0014)  //"A query de Conversao de Valor: ";" nao passou pelo parser"
		lRet := .F.
	EndIf
Else
	If !TCSPExist( cProc )
		nRet := TcSqlExec(cQuery)
		If nRet <> 0 
			If !__lBlind
				MsgAlert(STR0021+cProc)  //"Erro na criacao da procedure de Conversao de Valor: "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTBA370Proc³ Autor ³                       ³ Data ³20.10.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as procedures de atualizacao Debitos do CT7,CT3,CT4,CTI ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = cProc - Nome da Procedure                           ³±±
±±³          ³ ExpC2 = aProc - Array de procedures criadas                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA370Proc(cProc, aProc, nMoedas, cMoeda, cFilIni, cFilFim )
Local lRet     := .T.
Local nRet     := 0
Local nPos     := 0
Local aCampos  := CT2->(DbStruct())
Local cTipo    := ""
Local cQuery   := ""
Local iX       := 1
Local nPTratRec  := 0
Local cQueryM := ""

cQuery:="Create Procedure "+cProc+CRLF
cQuery+="("+CRLF
cQuery+="   @IN_FILIAL   Char( " +  Str(FWGETTAMFILIAL) + " ),"+CRLF
cQuery+="   @IN_FILATE   Char( " +  Str(FWGETTAMFILIAL) + " ),"+CRLF
cQuery+="   @IN_DATAINI  Char( 08 ),"+CRLF
cQuery+="   @IN_DATAFIM  Char( 08 ),"+CRLF
cQuery+="   @IN_LTPSALDO Char( 01 ),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_TPSALD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_TPSALDO  "+cTipo+CRLF
cQuery+="   @IN_MOEDAS   Varchar( 200 ),"+CRLF
cQuery+="   @IN_CONVERTE Char( 01 ),"+CRLF
cQuery+="   @IN_MVSOMA   Char( 01 ),"+CRLF
cQuery+="   @OUT_RESULT  Char( 01 ) OutPut"+CRLF
cQuery+=")"+CRLF

cQuery+="as"+CRLF
/* ------------------------------------------------------------------------------------
   Versão          - <v>  Protheus 9.12 </v>
   Assinatura      - <a>  001 </a>
   Fonte Microsiga - <s>  CTBA370.PRW </s>
   Descricao       - <d>  Reprocessamento SigaCTB </d>
   Procedure       -      Atualizacao de Moedas - Qdo o criterio de conversao ou a taxa foi alterada
   Funcao do Siga  -      Ct370Proc()
   Entrada         - <ri> @IN_FILIAL     - Filial Corrente
                          @IN_DATAINI    - Data Inicial
                          @IN_DATAFIM    - Data Final
                          @IN_LTPSALDO   - Se '1' processa um tipo de saldo, se '0' todos os tipos de Saldos
                          @IN_TPSALDO    - Tipo de saldo q tera a moeda atualizada
                          @IN_MOEDAS     - Moedas que serao atualizadas
                          @IN_CONVERTE   - '1' Plano de Contas CT1, '2' Lancamentos -CT2  </ri>
   Saida           - <o>  @OUT_RESULT    - Indica o termino OK da procedure </ro>
   Responsavel :     <r>  Siga	</r>
   Data        :     06/10/2008
   Obs: 
   1 - Verificar se Moeda esta Bloqeada
   2 - Verificar se Calendario nao esta bloqueado
   3 - Atualizacao por Conta - CT1_CVD  -   
                  Lancamento - CT2_CRITER = '12345' -  1- Diario
                                                       2- Media
                                                       3- Mensal
                                                       4- Informado
                                                       5- Nao gera lancamento na moeda a converter
  aProc[3]- CTBA370 -> Chamador                               
  aProc[2]-        --> CTBA370A -> Retorna o valor convertido
  aProc[1]-        --> CallXfilial -> xfilial
   -------------------------------------------------------------------------------------- */
cQuery+="Declare @cAux        Char( 03 )"+CRLF
cQuery+="Declare @cFil_CT1    Char( " + IIf( lFWCodFil, Str( FWGETTAMFILIAL ), "02" ) + " )"+CRLF
cQuery+="Declare @cFil_CT2    Char( " + IIf( lFWCodFil, Str( FWGETTAMFILIAL ), "02" ) + " )"+CRLF
cQuery+="Declare @cFil_CTO    Char( " + IIf( lFWCodFil, Str( FWGETTAMFILIAL ), "02" ) + " )"+CRLF
cQuery+="Declare @lConverte   Char( 01 )"+CRLF
cQuery+="Declare @cData       Char( 08 )"+CRLF
cQuery+="Declare @cBloq       Char( 01 )"+CRLF
cQuery+="Declare @cCT2_FILIAL Char( " + IIf( lFWCodFil, Str( FWGETTAMFILIAL ), "02" ) + " )"+CRLF
cQuery+="Declare @cCT2_DATA   Char( 08 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_LOTE   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_SBLOTE "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_DOC    "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LINHA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_LINHA  "+cTipo+CRLF
cQuery+="Declare @cCT2_FILORI Char( " + IIf( lFWCodFil, Str( FWGETTAMFILIAL ), "02" ) + " )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_EMPORI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_EMPORI "+cTipo+CRLF
cQuery+="Declare @cCT2_DC     Char( 01 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DEBITO" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_DEBITO "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CREDIT" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_CREDIT "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CCD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_CCD    "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CCC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_CCC    "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_ITEMD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_ITEMD  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_ITEMC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_ITEMC  "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CLVLDB" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_CLVLDB "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CLVLCR" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_CLVLCR "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LP" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_LP     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_MOEDLC "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_TPSALD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_TPSALD "+cTipo+CRLF
cQuery+="Declare @cCT2_DTLP   Char( 08 )"+CRLF
cQuery+="Declare @cCT2_CRCONV Char( 01 )"+CRLF
cQuery+="Declare @cCT2_DATATX Char( 08 )"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_ROTINA" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_ROTINA "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MANUAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_MANUAL "+cTipo+CRLF
cQuery+="Declare @nCT2_VALOR  Float"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cMoeda      "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CRCONV" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCriterio   "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DCD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_DCD "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DCC" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_DCC "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQUEN" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_SEQUEN "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_ORIGEM" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_ORIGEM "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_AGLUT" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_AGLUT "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_HP" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_HP "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_HIST" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_HIST "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQLAN" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_SEQLAN "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQHIS" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_SEQHIS "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SLBASE" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_SLBASE "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_KEY" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_KEY "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DTCV3" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cCT2_DTCV3 "+cTipo+CRLF

cQuery+="Declare @nValor      Float"+CRLF
cQuery+="Declare @nValorConv  Float"+CRLF
cQuery+="Declare @nValorDif   Float"+CRLF
cQuery+="Declare @iX          Integer"+CRLF
cQuery+="Declare @iRecno      Integer"+CRLF
cQuery+="Declare @iRecnoCT1   Integer"+CRLF
cQuery+="Declare @iRecnoCT2   Integer"+CRLF
For iX := 1 to Len(cMoeda)
	cQuery+="Declare @cCT1_CVD"+SubString(cMoeda, iX, 2)+" Char(01)"+CRLF  //  -- Montar no AdvPL
	cQuery+="Declare @cCT1_CVC"+SubString(cMoeda, iX, 2)+" Char(01)"+CRLF  //  -- Montar no AdvPL
	
	//Criado Query intermediaria para incrementar na principal
	//Pois não se sabe quantas moedas poderiam estar ativas no ambiente, e para posteriormente
	//ser utilizada na verificação da forma de criterio nas moedas.
	If iX > 1
		cQueryM +=" Or "
	Endif

	cQueryM += "@cCT1_CVD"+SubString(cMoeda, iX, 2)+ " = '5'" + " Or " + "@cCT1_CVC" + SubString(cMoeda, iX, 2) + " = '5'"
	iX := iX + 1
Next 

cQuery+="Begin"+CRLF
cQuery+="   Select @OUT_RESULT = '0'"+CRLF
cQuery+="   Select @cAux = 'CT2'"+CRLF
cQuery+="   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_CT2 OutPut"+CRLF
cQuery+="   Select @cCT2_ROTINA = 'CTBA370'"+CRLF
cQuery+="   Select @cCT2_MANUAL = '1'"+CRLF
cQuery+="   Select @cMoeda = ' '"+CRLF
cQuery+="   Select @cCriterio = ' '"+CRLF
cQuery+="   Select @cData = ' '"+CRLF
For iX := 1 to Len(cMoeda)
	cQuery+="   Select @cCT1_CVD"+SubString(cMoeda, iX, 2)+" = ' '"+CRLF  //  -- Montar no AdvPL
	cQuery+="   Select @cCT1_CVC"+SubString(cMoeda, iX, 2)+" = ' '"+CRLF  //  -- Montar no AdvPL
	iX := iX + 1
Next 
   
cQuery+="   Declare CUR_CTB370 insensitive cursor for"+CRLF
cQuery+="    Select CT2_FILIAL, CT2_DATA,   CT2_LOTE,   CT2_SBLOTE, CT2_DOC,  CT2_LINHA,  CT2_FILORI, CT2_EMPORI, CT2_DC,     CT2_DEBITO,"+CRLF
cQuery+="           CT2_CREDIT, CT2_CCD,    CT2_CCC,    CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_LP,     CT2_MOEDLC, CT2_TPSALD,"+CRLF
cQuery+="           CT2_DTLP,   CT2_CRCONV, CT2_DATATX, CT2_VALOR, "+CRLF
cQuery+="           CT2_DCD, CT2_DCC, CT2_SEQUEN, CT2_ORIGEM, CT2_AGLUT, CT2_HP, CT2_HIST, CT2_SEQLAN, CT2_SEQHIS, CT2_SLBASE, CT2_KEY, CT2_DTCV3 "+CRLF
cQuery+="      From "+RetSqlName("CT2")+CRLF
cQuery+="     Where CT2_FILIAL between @cFil_CT2 and @IN_FILATE"+CRLF
cQuery+="       AND CT2_DATA Between @IN_DATAINI AND @IN_DATAFIM"+CRLF
cQuery+="       AND CT2_MOEDLC = '01'"+CRLF
cQuery+="       AND ( CT2_TPSALD = @IN_TPSALDO AND @IN_LTPSALDO  = '1' OR (@IN_TPSALDO    = '0'))"+CRLF
cQuery+="       AND CT2_DC     != '4'"+CRLF
cQuery+="       AND D_E_L_E_T_ = ' '"+CRLF
cQuery+="   for read only"+CRLF
cQuery+="   Open CUR_CTB370"+CRLF
cQuery+="   Fetch CUR_CTB370"+CRLF
cQuery+="    into @cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,   @cCT2_SBLOTE, @cCT2_DOC,   @cCT2_LINHA,  @cCT2_FILORI, @cCT2_EMPORI, @cCT2_DC,     @cCT2_DEBITO,"+CRLF
cQuery+="         @cCT2_CREDIT, @cCT2_CCD,    @cCT2_CCC,    @cCT2_ITEMD,  @cCT2_ITEMC, @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_LP,     @cCT2_MOEDLC, @cCT2_TPSALD,"+CRLF
cQuery+="         @cCT2_DTLP,   @cCT2_CRCONV, @cCT2_DATATX, @nCT2_VALOR, "+CRLF
cQuery+="         @cCT2_DCD, @cCT2_DCC, @cCT2_SEQUEN, @cCT2_ORIGEM, @cCT2_AGLUT, @cCT2_HP, @cCT2_HIST, @cCT2_SEQLAN, @cCT2_SEQHIS, @cCT2_SLBASE, @cCT2_KEY, @cCT2_DTCV3 "+CRLF
   
cQuery+="   While ( @@fetch_status = 0 ) begin"+CRLF
cQuery+="      Select @cAux = 'CT1'"+CRLF
cQuery+="      exec "+aProc[1]+" @cAux, @cCT2_FILIAL, @cFil_CT1 OutPut"+CRLF
cQuery+="      Select @cAux = 'CTO'"+CRLF
cQuery+="      exec "+aProc[1]+" @cAux, @cCT2_FILIAL, @cFil_CTO OutPut"+CRLF
//      -- Converte para varias moedas
cQuery+="      select @iX = 1"+CRLF
cQuery+="      While @iX < Len( @IN_MOEDAS ) begin"+CRLF
cQuery+="         Select @lConverte  = '1'"+CRLF
cQuery+="         select @iRecno     = 0"+CRLF
cQuery+="         select @iRecnoCT1  = 0"+CRLF
cQuery+="         select @iRecnoCT2  = 0"+CRLF
cQuery+="         select @nValorConv = 0"+CRLF
cQuery+="         select @nValorDif  = 0"+CRLF
cQuery+="         select @nValor     = 0"+CRLF
cQuery+="         select @cData      = @cCT2_DATA"+CRLF
cQuery+="         Select @cMoeda     = Substring( @IN_MOEDAS, @iX, 2 )"+CRLF
         /* -------------------------------------------------------------------------------------
            Verificar se a moeda esta bloqueada. @cBloq = '1' bloqueada
            ------------------------------------------------------------------------------------- */
cQuery+="         Select @cBloq = CTO_BLOQ"+CRLF
cQuery+="           From "+RetSqlName("CTO")+CRLF
cQuery+="          Where CTO_FILIAL = @cFil_CTO"+CRLF
cQuery+="            AND CTO_MOEDA  = @cMoeda"+CRLF
cQuery+="            AND D_E_L_E_T_ = ' '"+CRLF
         
cQuery+="         If @cBloq = '1' select @lConverte = '0'"+CRLF   
         
cQuery+="         If @lConverte = '1' begin"+CRLF
cQuery+="            Select @iRecnoCT2 = IsNull(R_E_C_N_O_, 0), @cCT2_DATATX = CT2_DATATX, @cCriterio = CT2_CRCONV, @nValor = CT2_VALOR"+CRLF
cQuery+="              From "+RetSqlName("CT2")+CRLF
cQuery+="             Where CT2_FILIAL = @cCT2_FILIAL"+CRLF
cQuery+="               and CT2_DATA   = @cCT2_DATA"+CRLF
cQuery+="               and CT2_LOTE   = @cCT2_LOTE"+CRLF
cQuery+="               and CT2_SBLOTE = @cCT2_SBLOTE"+CRLF
cQuery+="               and CT2_DOC    = @cCT2_DOC"+CRLF
cQuery+="               and CT2_LINHA  = @cCT2_LINHA"+CRLF
cQuery+="               and CT2_TPSALD = @cCT2_TPSALD"+CRLF
cQuery+="               and CT2_EMPORI = @cCT2_EMPORI"+CRLF
cQuery+="               and CT2_FILORI = @cCT2_FILORI"+CRLF
cQuery+="               and CT2_MOEDLC = @cMoeda"+CRLF
cQuery+="               and D_E_L_E_T_ = ' '"+CRLF

            /* ---------------------------------------------------------
               Pelo Lancamento Contabil
               --------------------------------------------------------- */
cQuery+="            If @IN_CONVERTE = '2' begin"+CRLF            
cQuery+="               If @iRecnoCT2 = 0 select @lConverte = '0'"+CRLF
cQuery+="            end else begin"+CRLF
               /* ---------------------------------------------------
                  Plano de Contas
                  --------------------------------------------------- */
cQuery+="               If @iRecnoCT2 = 0 begin "+CRLF
cQuery+="                  select @nValorConv = @nCT2_VALOR"+CRLF
cQuery+="               End"+CRLF
cQuery+="            End"+CRLF
cQuery+="         End"+CRLF

cQuery+="         If @lConverte = '1' begin"+CRLF
            /* ---------------------------------------------------------
               Pelo Lancamento Contabil
               --------------------------------------------------------- */
cQuery+="            If @IN_CONVERTE = '2' begin"+CRLF
               
cQuery+="               If @cCriterio = ' ' select @cCriterio = '1'"+CRLF
cQuery+="               If @cCriterio = '9' select @cData = @cCT2_DATATX"+CRLF
cQuery+="               If @cCriterio = '4' begin"+CRLF
cQuery+="                  select @nValorConv = @nValor"+CRLF
cQuery+="               End"+CRLF
               /* ---------------------------------------------------
                  converte valor
                  --------------------------------------------------- */
cQuery+="               If @cCriterio != '4' begin"+CRLF
cQuery+="                  Exec "+aProc[2]+" @cCT2_FILIAL, @cData, @nCT2_VALOR, @cMoeda, @cCriterio, @nValorConv OutPut"+CRLF
cQuery+="               End"+CRLF
cQuery+="            end else begin"+CRLF
               /* ---------------------------------------------------
                  Plano de Contas
                  --------------------------------------------------- */
cQuery+="               If @cCT2_DC IN ( '1',  '3') begin"+CRLF   //  --DEBITO montar no ADVpl
cQuery+="                  Select @iRecnoCT1 = IsNull(R_E_C_N_O_, 0)"// ,@cCT1_CVD02 = CT1_CVD02, @cCT1_CVD03 = CT1_CVD03, @cCT1_CVD04 = CT1_CVD04, @cCT1_CVD05 = CT1_CVD05"+CRLF
For iX := 1 to Len(cMoeda)
	cQuery+=", @cCT1_CVD"+SubStr(cMoeda, iX, 2)+" = CT1_CVD"+SubStr(cMoeda, iX, 2)
	iX := iX + 1
Next
cQuery+="                    From "+RetSqlName("CT1")+CRLF
cQuery+="                   Where CT1_FILIAL = @cFil_CT1"+CRLF
cQuery+="                     and CT1_CONTA  = @cCT2_DEBITO"+CRLF
cQuery+="                     and D_E_L_E_T_ = ' '"+CRLF
For iX := 1 to Len( cMoeda )
//cQuery+="                  If @cMoeda = '02' Select @cCriterio = @cCT1_CVD02"+CRLF   //   -- MONTAR NO ADVPL
	cQuery+="                  If @cMoeda = '"+Substr(cMoeda,iX, 2)+"' Select @cCriterio = @cCT1_CVD"+Substr(cMoeda, iX, 2)+CRLF
	iX := iX + 1
Next iX
cQuery+="               End"+CRLF
cQuery+="               If @cCT2_DC = '2' begin"+CRLF  //  -- CREDITO
cQuery+="                  Select @iRecnoCT1 = IsNull(R_E_C_N_O_, 0)" //, @cCT1_CVC02 = CT1_CVC02, @cCT1_CVC03 = CT1_CVC03, @cCT1_CVC04 = CT1_CVC04, @cCT1_CVC05 = CT1_CVC05"+CRLF
For iX := 1 to Len(cMoeda)
	cQuery+=", @cCT1_CVC"+SubStr(cMoeda, iX, 2)+" = CT1_CVC"+SubStr(cMoeda, iX, 2)
	iX := iX + 1
Next
cQuery+="                    From "+RetSqlName("CT1")+CRLF
cQuery+="                   Where CT1_FILIAL = @cFil_CT1"+CRLF
cQuery+="                     and CT1_CONTA  = @cCT2_CREDIT"+CRLF
cQuery+="                     and D_E_L_E_T_ = ' '"+CRLF
For iX := 1 to Len( cMoeda )
//cQuery+="                  If @cMoeda = '02' Select @cCriterio = @cCT1_CVC02"+CRLF   //   -- MONTAR NO ADVPL
	cQuery+="                  If @cMoeda = '"+Substr(cMoeda,iX, 2)+"' Select @cCriterio = @cCT1_CVC"+Substr(cMoeda, iX, 2)+CRLF
	iX := iX + 1
Next
cQuery+="               End"+CRLF
               
cQuery+="               If @cCriterio = '9' select @cData = @cCT2_DATATX"+CRLF
cQuery+="               If @cCriterio = '4' begin"+CRLF
cQuery+="                  select @nValorConv = @nValor"+CRLF
cQuery+="               End"+CRLF
               
cQuery+="               If @cCriterio != '4' begin"+CRLF
cQuery+="                  Exec "+aProc[2]+" @cCT2_FILIAL, @cData, @nCT2_VALOR, @cMoeda, @cCriterio, @nValorConv OutPut"+CRLF
cQuery+="               End"+CRLF
cQuery+="            End"+CRLF    //  -- @IN_CONVERTE

cQuery+="            If ( @iRecnoCT2 = 0 and Round(@nValorConv, 2) != 0.00 )  begin"+CRLF
cQuery+="                  select @nValorConv = Round( @nValorConv, 2)"+CRLF
							/*---------------------------------------------------------
							Insert na CT2
							--------------------------------------------------------- */
cQuery+="                   select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM "+RetSqlName("CT2") + CRLF
cQuery+="                   select @iRecno = @iRecno + 1"+CRLF
cQuery+="                   ##TRATARECNO @iRecno\"+CRLF 

cQuery+="                   begin tran"+CRLF
cQuery+="                   insert into "+RetSqlName("CT2")"
cQuery+="                   ("
cQuery+="      	              CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_FILORI, CT2_EMPORI, CT2_DC, CT2_DEBITO, CT2_DCD, CT2_CREDIT, CT2_DCC, "		
cQuery+="                     CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_LP, CT2_SEQUEN, CT2_ROTINA, CT2_ORIGEM, CT2_AGLUT, CT2_MOEDLC, "		
cQuery+="                     CT2_TPSALD, CT2_HP, CT2_HIST, CT2_SEQLAN, CT2_SEQHIS, CT2_MANUAL, CT2_DTLP, CT2_SLBASE, CT2_KEY, CT2_DTCV3, CT2_VALOR, CT2_CRCONV, "  
cQuery+="      	              R_E_C_N_O_ ) "
cQuery+="                  values(	"
cQuery+="                      @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_LINHA, @cCT2_FILORI, @cCT2_EMPORI, @cCT2_DC, @cCT2_DEBITO, @cCT2_DCD, @cCT2_CREDIT, @cCT2_DCC, "+CRLF
cQuery+="                      @cCT2_CCD, @cCT2_CCC, @cCT2_ITEMD, @cCT2_ITEMC, @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_LP, @cCT2_SEQUEN, @cCT2_ROTINA, @cCT2_ORIGEM, @cCT2_AGLUT, @cMoeda, "
cQuery+="                      @cCT2_TPSALD, @cCT2_HP, @cCT2_HIST, @cCT2_SEQLAN, @cCT2_SEQHIS, @cCT2_MANUAL, @cCT2_DTLP, @cCT2_SLBASE, @cCT2_KEY, @cCT2_DTCV3, @nValorConv, @cCT2_CRCONV, "+CRLF
cQuery+="                      @iRecno )"+CRLF
cQuery+="                  commit tran"+CRLF

cQuery +="                 ##FIMTRATARECNO"+CRLF

cQuery+="            end else begin"+CRLF
cQuery+="               If ( Round(@nValorConv, 2) != 0.00 ) and (Round(@nValorConv, 2) != Round(@nValor, 2) ) begin"+CRLF
cQuery+="                  select @nValorConv = Round( @nValorConv, 2)"+CRLF
cQuery+="                  Select @nValorDif  = round( (@nValorConv - @nValor), 2)"+CRLF
							/*---------------------------------------------------------
							Update no valor
							--------------------------------------------------------- */
cQuery+="                  begin tran"+CRLF
cQuery+="                  Update "+RetSqlName("CT2")+CRLF
cQuery+="                  Set CT2_VALOR  = @nValorConv"+CRLF
cQuery+="                  Where R_E_C_N_O_ = @iRecnoCT2"+CRLF
cQuery+="                  commit tran"+CRLF  
cQuery+="               end else begin"+CRLF
							/*---------------------------------------------------------
							Update no campo D_E_L_E_T_ se valor for zero
							--------------------------------------------------------- */
cQuery+="                  If ( Round(@nValorConv, 2) = 0.00 ) And " + "( " + cQueryM + " )" +" begin"+CRLF				
cQuery+="                     begin tran"+CRLF
cQuery+="                     Update "+RetSqlName("CT2")+CRLF
cQuery+="                     Set D_E_L_E_T_  = '*' , R_E_C_D_E_L_ = @iRecnoCT2 "+CRLF
cQuery+="                     Where R_E_C_N_O_ = @iRecnoCT2"+CRLF
cQuery+="                     commit tran"+CRLF
cQuery+="                  End"+CRLF
cQuery+="               End"+CRLF
cQuery+="            End"+CRLF
cQuery+="         End"+CRLF  //   -- fim @lConverte
         
cQuery+="         Select @iX = @iX + 2"+CRLF
cQuery+="      End"+CRLF

If TcGetDb() = "DB2"
	cQuery+="      select @fim_CUR = 0"+CRLF
EndIf
cQuery+="      Fetch CUR_CTB370"+CRLF
cQuery+="       into @cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,   @cCT2_SBLOTE, @cCT2_DOC,   @cCT2_LINHA,  @cCT2_FILORI, @cCT2_EMPORI, @cCT2_DC,     @cCT2_DEBITO,"+CRLF
cQuery+="            @cCT2_CREDIT, @cCT2_CCD,    @cCT2_CCC,    @cCT2_ITEMD,  @cCT2_ITEMC, @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_LP,     @cCT2_MOEDLC, @cCT2_TPSALD,"+CRLF
cQuery+="            @cCT2_DTLP,   @cCT2_CRCONV, @cCT2_DATATX, @nCT2_VALOR, "+CRLF
cQuery+="            @cCT2_DCD, @cCT2_DCC, @cCT2_SEQUEN, @cCT2_ORIGEM, @cCT2_AGLUT, @cCT2_HP, @cCT2_HIST, @cCT2_SEQLAN, @cCT2_SEQHIS, @cCT2_SLBASE, @cCT2_KEY, @cCT2_DTCV3 "+CRLF
cQuery+="   End"+CRLF
cQuery+="   close CUR_CTB370"+CRLF
cQuery+="   deallocate CUR_CTB370"+CRLF
   
cQuery+="   Select @OUT_RESULT = '1'"+CRLF
   
cQuery+="End"+CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If Empty(cQuery)
	If !__lBlind
		MsgAlert(STR0022+cProc+STR0014) //"A query de criacao da procedure Principal: ";" nao passou pelo parser"
		lRet := .F.
	EndIf
Else
	If !TCSPExist( cProc )
		nRet := TcSqlExec(cQuery)
		If nRet <> 0 
			If !__lBlind
				MsgAlert(STR0023+cProc) //"Erro na criacao da procedure Principal: "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CallXFilial³ Autor ³                       ³ Data ³20.10.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³                                                             ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function CallXFilial(cArq)
Local aSaveArea := GetArea()
Local cProc   := cArq
Local cQuery  := ""
Local lRet    := .T.
Local aCampos := CT2->(DbStruct())
Local nPos    := 0
Local cTipo   := ""

cQuery :="Create procedure "+cProc+CRLF
cQuery +="( "+CRLF
cQuery +="  @IN_ALIAS        Char(03),"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery +="  @IN_FILIALCOR    "+cTipo+","+CRLF
cQuery +="  @OUT_FILIAL      "+cTipo+" OutPut"+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF

/* -------------------------------------------------------------------
    Versão      -  <v> Genérica </v>
    Assinatura  -  <a> 010 </a>
    Descricao   -  <d> Retorno o modo de acesso da tabela em questao </d>

    Entrada     -  <ri> @IN_ALIAS        - Tabela a ser verificada
                        @IN_FILIALCOR    - Filial corrente </ri>

    Saida       -  <ro> @OUT_FILIAL      - retorna a filial a ser utilizada </ro>
                   <o> brancos para modo compartilhado @IN_FILIALCOR para modo exclusivo </o>

    Responsavel :  <r> Alice Yaeko </r>
    Data        :  <dt> 14/12/10 </dt>
   
   X2_CHAVE X2_MODO X2_MODOUN X2_MODOEMP X2_TAMFIL X2_TAMUN X2_TAMEMP
   -------- ------- --------- ---------- --------- -------- ---------
   CT2      E       E         E          3.0       3.0        2.0       
      X2_CHAVE   - Tabela
      X2_MODO    - Comparti/o da Filial, 'E' exclusivo e 'C' compartilhado
      X2_MODOUN  - Comparti/o da Unidade de Negócio, 'E' exclusivo e 'C' compartilhado
      X2_MODOEMP - Comparti/o da Empresa, 'E' exclusivo e 'C' compartilhado
      X2_TAMFIL  - Tamanho da Filial
      X2_TAMUN   - Tamanho da Unidade de Negocio
      X2_TAMEMP  - tamanho da Empresa
   
   Existe hierarquia no compartilhamento das entidades filial, uni// de negocio e empresa.
   Se a Empresa for compartilhada as demais entidades DEVEM ser compartilhadas
   Compartilhamentos e tamanhos possíveis
   compartilhaemnto         tamanho ( zero ou nao zero)
   EMP UNI FIL             EMP UNI FIL
   --- --- ---             --- --- ---
    C   C   C               0   0   X   -- 1 - somente filial
    E   C   C               0   X   X   -- 2 - filial e unidade de negocio
    E   E   C               X   0   X   -- 3 - empresa e filial
    E   E   E               X   X   X   -- 4 - empresa, unidade de negocio e filial
------------------------------------------------------------------- */

cQuery +="Declare @cModo    Char( 01 )"+CRLF
cQuery +="Declare @cModoUn  Char( 01 )"+CRLF
cQuery +="Declare @cModoEmp Char( 01 )"+CRLF
cQuery +="Declare @iTamFil  Integer"+CRLF
cQuery +="Declare @iTamUn   Integer"+CRLF
cQuery +="Declare @iTamEmp  Integer"+CRLF

cQuery +="begin"+CRLF
cQuery +="  Select @OUT_FILIAL = ' '"+CRLF
cQuery +="  Select @cModo = ' ', @cModoUn = ' ', @cModoEmp = ' '"+CRLF
cQuery +="  Select @iTamFil = 0, @iTamUn = 0, @iTamEmp = 0"+CRLF
  
cQuery +="  Select @cModo = X2_MODO,   @cModoUn = X2_MODOUN, @cModoEmp = X2_MODOEMP,"+CRLF
cQuery +="         @iTamFil = X2_TAMFIL, @iTamUn = X2_TAMUN, @iTamEmp = X2_TAMEMP"+CRLF
cQuery +="    From SX2"+cEmpAnt+"0 "+CRLF
cQuery +="   Where X2_CHAVE = @IN_ALIAS"+CRLF
cQuery +="     and D_E_L_E_T_ = ' '" + CRLF
/* --------------------------------------------------------------
     1 - somente FILIAL e de tamanho >= 2
-------------------------------------------------------------- */
cQuery +="  If ( @iTamEmp = 0 and @iTamUn = 0 and @iTamFil >= 2) begin"+CRLF
cQuery +="    If @cModo = 'C' select @OUT_FILIAL = '  '"+CRLF
cQuery +="    else select @OUT_FILIAL = @IN_FILIALCOR"+CRLF
cQuery +="  end else begin" + CRLF
/*-------------------------------------------------------------- 
SITUACAO -> 2 UNIDADE DE NEGOCIO e FILIAL
-------------------------------------------------------------- */
cQuery +="    If @iTamEmp = 0 begin"+CRLF
cQuery +="      If @cModoUn = 'E' begin"+CRLF
cQuery +="        If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamUn + 1, @iTamFil )"+CRLF
cQuery +="        else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end else begin" + CRLF
/*-------------------------------------------------------------- 
SITUACAO -> 4 EMPRESA, UNIDADE DE NEGOCIO e FILIAL
-------------------------------------------------------------- */
cQuery +="      If @iTamUn > 0 begin"+CRLF
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModoUn = 'E' begin"+CRLF
cQuery +="            If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamEmp+@iTamUn + 1, @iTamFil )"+CRLF
cQuery +="            else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)"+CRLF
cQuery +="          end else begin"+CRLF
cQuery +="            select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="          end"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end else begin" + CRLF
/*-------------------------------------------------------------- 
SITUACAO -> 3 EMPRESA e FILIAL
-------------------------------------------------------------- */
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring( @IN_FILIALCOR, @iTamEmp+1, @iTamFil )"+CRLF
cQuery +="          else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end"+CRLF
cQuery +="  end"+CRLF
cQuery +="end"+CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),'A query da filial nao passou pelo Parse '+cProc)
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da proc filial: "+cProc)
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ScheDef()

Definição de Static Function SchedDef para o novo Schedule

@author TOTVS
@since 03/06/2021
@version MP12
/*/
//-------------------------------------------------------------------

Static Function SchedDef()

Local aParam := {}

aParam := { "P",;            // Tipo R para relatório P para processo
			"CTB370",;       // Pergunte do relatório, caso não use, passar ParamDef
			,;               // Alias     
			,;               // Array de ordens
			STR0001 }        // Título 


Return aParam
