#Include "PROTHEUS.CH"
#Include "CTBA351.CH"

#DEFINE D_PRELAN	"9"

STATIC __lBlind  := IsBlind()
STATIC __nThread := Nil

STATIC cSayCusto := Nil
STATIC cSayItem	 := Nil
STATIC cSayClVL	 := Nil
STATIC lAtSldBase
STATIC lCusto
STATIC lItem
STATIC lClVl
STATIC lCtb350Ef
STATIC lEfeLanc
STATIC lCT350TSL
Static lPE351Qry 	:= ExistBlock("CT351QRY")
Static _cQry351EFT	:= NIL

/*-------------------------------------------------------------------------
Funcao		  : CTB351PROC
Autor         : Renato Campos / Alexandre TOSTA
Data          : 12/09/2016
Uso           : Efetua a validação dos dados do lançamento
-------------------------------------------------------------------------*/

Function CTB351PROC(lEnd)

Local cAliasTrb
Local lSimula := (mv_par12==2)
Local cCTB240	:= IIF(FindFunction("GetSPName"), GetSPName("CTB240","07"), "CTB240")

Default lEnd	:= .F.

ProcRegua(1000)

//-- Verifica a quantidade de threads para o processamento.
__nThread   := GetNewPar( "MV_CT350TH", 1 )

lAtSldBase	:= ( GetMv("MV_ATUSAL") == "S" )
lCusto		:= CtbMovSaldo("CTT")
lItem 		:= CtbMovSaldo("CTD")
lClVl		:= CtbMovSaldo("CTH")
lCtb350Ef	:= ExistBlock("CTB350EF")
lEfeLanc 	:= ExistBlock("EFELANC")
lCT350TSL	:= GetNewPar( "MV_CT350SL", .T.)			///PARAMETRO NÃO PUBLICADO NA CRIAÇÃO (15/03/07-BOPS120975)

If !LockByName("CTB350ATHR1"+cEmpAnt+Alltrim(StrTran(cFilAnt," ", "_")),.F.,.F.)
	Help(" ",1,"CTB350ATHR1",,STR0001,1,0) //"Outro usuario está usando a rotina." 
	Return(.F.)
EndIf

//----------------------------------------------------------------------------------------------
// Nao processsa caso o parametro MV_CT350SL seja .T. e a procedure CTB240 nao esteja instalada
//----------------------------------------------------------------------------------------------
If lCT350TSL .And. !ExistProc(cCTB240,VerIDProc())
	Help(" ",1,"CTB351PROC",,STR0013,1,0) //"Para o processo de efetivação multithread (MV_CT350TH) com atualização de saldo (MV_CT350L), é necessária a instalação da Stored Procedure CTB240.SQL, presente no pacote p12_07.sps."
	Return(.F.)
EndIf

cAliasTrb := Ctb351Qry("cTrb1")

If !Empty(cAliasTrb) //Verificar
	// chama o processo de validação
	IncProc(STR0002) //"Iniciando validação dos dados via multi-thread."

	If CTBA351VLD(cAliasTrb) .And. !lSimula

		// chama o processo de efetivação
		IncProc(STR0003) //"Iniciando efetivação dos dados via multi-thread."
		CTBA351EFT(cAliasTrb)
	EndIf
Endif


If Select(cAliasTrb) > 0
	DbSelectArea(cAliasTrb)
	DbCloseArea()
Endif

//Destrava rotina após finalizar a execução das Threads
UnLockByName( "CTB350ATHR1"+cEmpAnt+Alltrim(StrTran(cFilAnt," ", "_")), .F. , .F. )

Return

/*-------------------------------------------------------------------------
Funcao		  : CTBA351VLD
Autor         : Renato Campos / Alexandre TOSTA
Data          : 12/09/2016
Uso           : Efetua a validação dos dados do lançamento
-------------------------------------------------------------------------*/
Static Function CTBA351VLD(cAliasTrb1)
Local lErro		:= .F.
Local oGrid		:= Nil
Local lSimula	:= (mv_par12==2)

//Objeto do Controlador de Threads (Instancia para Execução das Threads)
oGrid := FWIPCWait():New("CTBA350"+cEmpAnt,10000)

//Inicia as Threads
oGrid:SetThreads(__nThread)

//Informa o Ambiente Para Execução da Thread
oGrid:SetEnvironment( cEmpAnt , cFilAnt )

//Função para ser executada na Thread
oGrid:Start("CT351VALID")
Sleep(1000)

//Se der erro em alguma Thread sai imediatamente.	
oGrid:SetNoErrorStop(.T.)

DbSelectArea(cAliasTrb1)
DbGoTop()

DbSelectArea("CT2")
CT2->(DbSetOrder(1))

If CT2->(dbSeek( (cAliasTrb1)->(CT2_FILIAL+Dtos(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC), .T.))
	oGrid:Go(CT2->(Recno()))
EndIf
	
//Fechamento das Threads Iniciadas (O método aguarda o encerramentos de todas as Threads antes de retornar ao controle.
oGrid:Stop()

cError := oGrid:GetError()
FreeObj(oGrid)
oGrid := Nil

If !Empty(cError)
	Help(,,"Error",,cError,1,0)
	lErro := .T.
Else
	If Select("TRB350REL") <= 0
		dbUseArea( .T., "TOPCONN", "TRB350REL", "TRB350REL", .F., .F. )
		TcRefresh("TRB350REL")
	Endif
		
	DbSelectArea("TRB350REL")
	DbSetOrder(1)
	DbGoTop()
	
	If !Eof()
		//------------------------------------
		// Imprime relatorio de consistencias
		//------------------------------------
		lErro := .T.
	ElseIf lSimula 
		lErro := .F.
		CT350GrInc(,,,,,,STR0004) //"Não foram encontrados erros."
	Endif

	If lSimula .OR. lErro
		If lSimula
			titulo+=" - " +STR0005 //"Modo Simulação."
		EndIf
		C350ImpRel()		
	EndIf
Endif
		
Return !lErro


/*-------------------------------------------------------------------------
Funcao		  : CTBA351EFT
Autor         : Renato Campos / Alexandre TOSTA
Data          : 12/09/2016
Uso           : Efetua a efetivação dos dados do lançamento
-------------------------------------------------------------------------*/
Static Function CTBA351EFT(cAliasTrb)
Local oGrid	:= Nil
Local lJobs := IsCtbJob()
Local aDadosCQA := {}
Local cAliasAntr
Local aBind := {}

//Objeto do Controlador de Threads (Instancia para Execução das Threads)
oGrid := FWIPCWait():New("CTBA350"+cEmpAnt,10000)

//Inicia as Threads
oGrid:SetThreads(__nThread)

//Informa o Ambiente Para Execução da Thread
oGrid:SetEnvironment( cEmpAnt , cFilAnt )

//Função para ser executada na Thread
oGrid:Start("CT351GRAVA")

//Se der erro em alguma Thread sai imediatamente.	
oGrid:SetNoErrorStop(.T.)

If Select(cAliasTrb) > 0
	
	(cAliasTrb)->(DbGoTop())
	BEGIN TRANSACTION
	While (cAliasTrb)->(!Eof())
	
		oGrid:Go( (cAliasTrb)->CT2_FILIAL, (cAliasTrb)->CT2_DATA, (cAliasTrb)->CT2_LOTE, (cAliasTrb)->CT2_SBLOTE, (cAliasTrb)->CT2_DOC, (cAliasTrb)->CT2_MOEDLC)

		/*cFilAux	:= aLinhas[nX,01]
		cLote	:= aLinhas[nX,02]
		cSublote:= aLinhas[nX,03]
		cDoc	:= aLinhas[nX,04]
		dData	:= aLinhas[nX,05]
		cLinha	:= aLinhas[nX,06]
		cTpSald	:= aLinhas[nX,07]
		cEmpOri	:= aLinhas[nX,08]
		cFilOri	:= aLinhas[nX,09]
		cMoeda 	:= aLinhas[nX,10]*/

		If lJobs
			cAliasAntr := Alias()
			If _cQry351EFT == nil
				_cQry351EFT := "SELECT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_TPSALD,CT2_EMPORI,CT2_FILORI,CT2_MOEDLC "
				_cQry351EFT += " FROM "+RetSqlName("CT2")
				_cQry351EFT += " WHERE CT2_FILIAL = ? "
				_cQry351EFT += " AND CT2_DATA     = ? "
				_cQry351EFT += " AND CT2_LOTE     = ? "
				_cQry351EFT += " AND CT2_SBLOTE   = ? "
				_cQry351EFT += " AND CT2_DOC      = ? "
				_cQry351EFT += " AND CT2_MOEDLC   = ? "
				_cQry351EFT += " AND D_E_L_E_T_   = ? "
				_cQry351EFT += " ORDER BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_TPSALD,CT2_EMPORI,CT2_FILORI,CT2_MOEDLC"
			EndIf 
			aBind :={}
			AADD(aBind,(cAliasTrb)->CT2_FILIAL)
			AADD(aBind,DTOS((cAliasTrb)->CT2_DATA))
			AADD(aBind,(cAliasTrb)->CT2_LOTE)
			AADD(aBind,(cAliasTrb)->CT2_SBLOTE)
			AADD(aBind,(cAliasTrb)->CT2_DOC)
			AADD(aBind,(cAliasTrb)->CT2_MOEDLC)
			AADD(aBind,Space(1))
			dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_cQry351EFT,aBind),'Q351EFT')
			TcSetField('Q351EFT',"CT2_DATA","D",8,0)

			
			While Q351EFT->(!EOF()) 
				aADD(aDadosCQA, {;
				Q351EFT->CT2_FILIAL, ;
				Q351EFT->CT2_LOTE, ;
				Q351EFT->CT2_SBLOTE, ;
				Q351EFT->CT2_DOC, ;
				Q351EFT->CT2_DATA, ;
				Q351EFT->CT2_LINHA, ;
				Q351EFT->CT2_TPSALD, ;
				Q351EFT->CT2_EMPORI, ;
				Q351EFT->CT2_FILORI, ;
				Q351EFT->CT2_MOEDLC})

				Q351EFT->(DbSkip())
			EndDo
			Q351EFT->(dbCloseArea())

			DbSelectArea(cAliasAntr)
			CTBGrvCQA(aDadosCQA)
			aDadosCQA:={}
		EndIf

		(cAliasTrb)->(DbSkip())
	EndDo
	END TRANSACTION
Endif

//Fechamento das Threads Iniciadas (O método aguarda o encerramentos de todas as Threads antes de retornar ao controle.
oGrid:Stop()

cError := oGrid:GetError()
FreeObj(oGrid)
oGrid := Nil

If !Empty(cError)
	Help(,,"Error",,cError,1,0)
Elseif lCT350TSL .and. !lJobs // Efetua a atualização dos saldos contabeis via multithread 
	// Efetua o reprocessamento dos saldos pela rotina de multithread
	/*
	CTBA192 - Parametros
	01 Informe a data inicial a ser Considerada. 			- Da data / Ultimo Fecham.	
	02 Informe a data inicial a re- processar  				- Data Inicial  	
	03 Informe a data final a reprocessar.					- Ate a Data    
	04 Informe a Filial Inicial 							- Filial De
	05 Informe a filial final								- Filial Ate
	06 Tipo de saldo a Reprocessar - 01234					- Tipo de Saldo 
	07 Informe se deseja reprocessar todas as moedas ou uma moeda especifica. - Todas / Específica
	08 Caso tenha escolhido reprocessar uma moeda especifica na pergunta anterior, informe o código da moeda a reprocessar. Utilize <F3> para  escolher. - Qual Moeda     01
	09 Informe a Conta Inicial a reprocessar				- Da Conta
	10 Informe a Conta Final a reprocessar					- Ate a Conta 
	11 Informe os tipos de logs que devem ser registrados.	- Inicio e fim / Erros / Alertas / Mensagens
	*/
	
	
	//Inicio Saldos por conta
	CTBA192({1,MV_PAR03,MV_PAR04,cFilAnt,cFilAnt,MV_PAR07,1,'','','zzzzzzzzzzzzzzz',1})

Endif
aSize(aDadosCQA,0)
aDadosCQA := nil 

aSize(aBind,0)
aBind := nil
				
Return

/*-------------------------------------------------------------------------
Funcao		  : Ctb351Qry
Data          : 12/09/2016
Uso           : Monta e executa a criação do temporario de processamento.
-------------------------------------------------------------------------*/
Static Function Ctb351Qry(cTrb)
Local cAliasQry := Criatrab(,.F.)
Local cQuery 	:= ""
Local cQryUser := ""

cQuery := " SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE" + iif(cTrb == "cTrb1", ", CT2_DOC" , "")
cQuery += "      , CT2_MOEDLC"
cQuery += "      , SUM( CT2_VALOR * CASE WHEN CT2_DC = '1' OR CT2_DC = '3' THEN 1 ELSE 0 END) VALORDEB"
cQuery += "      , SUM( CT2_VALOR * CASE WHEN CT2_DC = '2' OR CT2_DC = '3' THEN 1 ELSE 0 END) VALORCRD"
cQuery += "   FROM " + RetSqlName("CT2") + " CT2"
cQuery += "  WHERE CT2_FILIAL = '" + xFilial("CT2") + "'"
	
// Data
If mv_par03 == mv_par04
	cQuery += " AND CT2_DATA = '" + DTOS(mv_par03) + "' "
Else
	cQuery += " AND CT2_DATA >= '" + DTOS(mv_par03) + "' "
	cQuery += " AND CT2_DATA <= '" + DTOS(mv_par04) + "' "
Endif
	
// Lote
If ! Empty( mv_par01 ) .Or. ! Empty( mv_par02 )
	If ( mv_par01 == mv_par02 )
		cQuery += " AND CT2_LOTE = '" + mv_par01 + "' "
	Else
		If ! Empty( mv_par01 )
			cQuery += " AND CT2_LOTE >= '" + mv_par01 + "' "
		Endif
		
		If ! Empty( mv_par02 )
			cQuery += " AND CT2_LOTE <= '" + mv_par02 + "' "
		Endif
	Endif
Endif

// Sublote
If ! Empty( mv_par09 ) .Or. ! Empty( mv_par10 )
	If ( mv_par09 == mv_par10 )
		cQuery += " AND CT2_SBLOTE = '" + mv_par09 + "' "
	Else
		If ! Empty( mv_par09 )
			cQuery += " AND CT2_SBLOTE >= '" + mv_par09 + "' "
		Endif
		
		If ! Empty( mv_par10 )
			cQuery += " AND CT2_SBLOTE <= '" + mv_par10 + "' "
		Endif
	Endif
Endif
	
// Documento
If ! Empty( mv_par13 ) .Or. ! Empty( mv_par14 )
	If ( mv_par13 == mv_par14 )
		cQuery += " AND CT2_DOC = '" + mv_par13 + "' "
	Else
		If ! Empty( mv_par13 )
			cQuery += " AND CT2_DOC >= '" + mv_par13 + "' "
		Endif
		
		If ! Empty( mv_par14 )
			cQuery += " AND CT2_DOC <= '" + mv_par14 + "' "
		Endif
	Endif
Endif

cQuery += " AND CT2_TPSALD = '" + D_PRELAN + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "
	
cQuery += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_MOEDLC" + Iif(cTrb == "cTrb1", ", CT2_DOC" , "")
cQuery += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_MOEDLC" + Iif(cTrb == "cTrb1", ", CT2_DOC" , "")

If lPE351Qry
	cQryUser := ExecBlock("CT351QRY",.F.,.F.,{cQuery})
	If !Empty(cQryUser) //se ponto de entrada retornou string query preenchida
		cQuery := cQryUser	
	EndIf 	
EndIf

cQuery := ChangeQuery(cQuery)
	
If Select(cAliasQry) > 0
	dbSelectArea(cAliasQry)
	dbCloseArea()
Endif
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)

If Select(cAliasQry) <= 0
	cAliasQry := ""
Else
	TcSetField(cAliasQry,"CT2_DATA","D",8,0)
	TcSetField(cAliasQry,"VALORDEB","N",17,2)
	TcSetField(cAliasQry,"VALORCRD","N",17,2)
Endif

Return cAliasQry

/*-------------------------------------------------------------------------
Funcao		  : CT351GRAVA
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Efetua a troca do tipo de saldo do documento inteiro
-------------------------------------------------------------------------*/

Function CT351GRAVA( cFilCT2, dData, cLote, cSbLote, cDoc, cMoeda )
Local cQuery := ""
Local lRet	 := .T.
Local cTpSald := MV_PAR07

If Empty(cTpSald)
	cTpSald := '1'
Endif

cQuery := "UPDATE " + RetSqlName("CT2")  + " SET CT2_TPSALD = '" + cTpSald + "'"
cQuery += " WHERE CT2_FILIAL = '" + cFilCT2 + "'"
cQuery += "   AND CT2_DATA = '" + dtos(dData) + "'"
cQuery += "   AND CT2_LOTE = '" + cLote + "'"
cQuery += "   AND CT2_SBLOTE = '" + cSbLote + "'"
cQuery += "   AND CT2_DOC = '" + cDoc + "'"
cQuery += "   AND CT2_MOEDLC = '" + cMoeda + "'"
cQuery += "   AND CT2_TPSALD = '" + D_PRELAN + "'"
cQuery += "   AND D_E_L_E_T_ = ' '"

lRet := CtbSqlExec( cQuery )

Return lRet

/*-------------------------------------------------------------------------
Funcao		  : Ct351Valid
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Efetua a validação das linhas dos lançamentos via multithread
-------------------------------------------------------------------------*/
Function CT351VALID( nRecCT2 )

Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local lEnd := .F.
Local aErroTexto 	:= {}
Local aErro:= {}
Local cTpSldAtu 	:= ""
Local lEfLote		:= .F.
Local lEfDoc		:= .F.
Local lMostraLct	:= .F.
Local lSimula		:= .F.

//variaveis utilizada no CTBA350
Private cFilCT2 := xFilial("CT2")
Private OPCAO	:= 3

Default nRecCT2 = 0

If Empty(mv_par05)
	Pergunte( "CTB350" , .F. )
EndIf

cTpSldAtu 	:= mv_par07
lEfLote		:= Iif(mv_par05 == 1,.T.,.F.)//.T. ->Efetiva sem bater Lote / .F. ->Nao efetiva sem bater Lote
lEfDoc		:= Iif(mv_par06 == 1,.T.,.F.)//.T. ->Efetiva sem bater Doc / .F. ->Nao efetiva sem bater Doc
lMostraLct	:= ( mv_par11 == 1 )
lSimula		:= ( mv_par12 == 2 )

If cSayCusto == Nil 
	cSayCusto := CtbSayApro("CTT")
Endif

If cSayItem == Nil
	cSayItem	:= CtbSayApro("CTD")
Endif

IF cSayClVL == Nil
	cSayClVL	:= CtbSayApro("CTH")
Endif

aErroTexto := ct350aerro()

If nRecCT2 > 0
	DbSelectArea("CT2")
	CT2->( dbGoTo(nRecCT2) )
		
	ct350roda(@lEnd,aErro,aErroTexto,cTpSldAtu,lEfLote,lEfDoc,lMostraLct,lSimula)

	lRet := lEnd

EndIF

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea:= nil

Return lRet

/*-------------------------------------------------------------------------
Funcao		  : CtbSqlExec
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Executa a instrução de banco via TCSQLExec
-------------------------------------------------------------------------*/
Static Function CtbSqlExec( cStatement )
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno := .T.

BEGIN SEQUENCE
	IF TcSqlExec(cStatement) <> 0
		UserException( STR0011 + CRLF + TCSqlError()  + CRLF + ProcName(1) + CRLF + cStatement ) //"Erro na instrução de execução do SQL"
		lRetorno := .F.
	Endif
RECOVER
	lRetorno := .F.
END SEQUENCE
ErrorBlock(bBlock)

Return lRetorno

//--------------------------------------------------
/*/{Protheus.doc} VerIDProc
Controle de versao da procedure CTB240.

@author Totvs
@since 27/12/2017
@version P12.1.17

@return caracter, versao da procedure CTB240
/*/
//--------------------------------------------------
Static Function VerIDProc()
Return "010"
