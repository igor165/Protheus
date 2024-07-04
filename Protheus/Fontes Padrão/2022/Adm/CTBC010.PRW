#INCLUDE "CTBC010.CH"
#INCLUDE "PROTHEUS.CH"

STATIC lCTxTABORI
STATIC lCTxRECORI
STATIC lCTxRECDES


// 17/08/2009 -- Filial com mais de 2 caracteres

// TRADUCAO DE CH'S PARA PORTUGAL
// TRADUÇÃO RELEASE P10 1.2 - 21/07/08

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ CTBC010  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Rastreamento de Lancamento Contabil            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBC010()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION CtbC010()

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0004) //"Rastrear Lan‡amentos Contabeis"
Private cFunName := "CTBC010" //Declarada para não dar erro na função LocxDlgNF (LOCXNF), ao rastrear documentos de entrada

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

mBrowse( 6, 1,22,75,"CT2",,,,,, { 	{ "Deleted()", "BR_VERMELHO" },{"Substr(CT2_ORIGEM,1,9)=='__CTBLC__'","BR_MARROM"},;
									{ ".T.", "BR_VERDE" } })

Set(_SET_DELETED, .T.)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBC010Rot³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina utilizada para Rastrear Lancamento Contabil         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbC010Rot(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  : Alias do arquivo                                  ³±±
±±³          ³ ExpN1  : Numero do Registro                                ³±±
±±³          ³ ExpN2  : Numero da opcao selecionada                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBC010ROT( cAlias, nReg, nOpc, nRecDes)
Local lRet		:= .T.
Local cSequenc	:= CT2->CT2_SEQUEN
Local dDtCV3	:= CT2->CT2_DTCV3
Local lDel		:= Set(_SET_DELETED)
Local nRecno  := 0
Local aArea   := GetArea()
Local aAreaCT2:= {}
Local cTabOri := cAlias
Local nRecOri := nReg
Local dDatCT2 := CT2->CT2_DATA
Local cLote   := CT2->CT2_LOTE
Local cSbLote := CT2->CT2_SBLOTE
Local cDocto  := CT2->CT2_DOC

DEFAULT nRecDes := 0

If FunName()== "CTBC020"
	PRIVATE cCadastro := OemToAnsi(STR0004) //"Rastrear Lan‡amentos Contabeis"
	DbSelectArea("CT2")
	If Val(nRecDes) > 0   //protecao para quando vier em branco nao carregar as variaveis novamente
		DbGoto(Val(nRecDes))
		cSequenc:= CT2->CT2_SEQUEN
		dDtCV3	:= CT2->CT2_DTCV3
		dDatCT2 := CT2->CT2_DATA
		cLote   := CT2->CT2_LOTE
		cSbLote := CT2->CT2_SBLOTE
		cDocto  := CT2->CT2_DOC
	EndIf
	lDel	:= Set(_SET_DELETED)
	SaveInter()
EndIf

If FwIsInCallStack("CTBA102") .And.  cAlias == "CT2"
	aArea   := CT2->(GetArea())
EndIf 

//Rastreio pela CTBA102 é realizado apenas pela CT2
If FWIsInCallStack("CTBA102") .And.  cAlias == "CTC"
	lRet := .F.

	If !IsBlind()
		Help(" ",1,"NORASCTC",, STR0020 + CRLF + CRLF + STR0021 ,1,0) //"Não é possível realizar o rastreio pela tabela CTC." // "Selecione a opção 'Rastrear' na tela de visualização ou altere o parâmetro 'Modo de exibição' da rotina para 'Detalhe Lançamento Contábil'."
	EndIf

Else
	
	lRet := Ctc010Val( cSequenc, dDtCV3, dDatCT2, cLote, cSbLote, cDocto )
	RestArea(aArea)

EndIf

If lRet

	// Se for um lançamento aglutinado, exibe todos os lançamentos aglutinados para que o
	// usuário escolha qual quer rastrear.
	If Ct2->CT2_AGLUT == "1"
		CtbAglut(cSequenc,dDtCV3,cTabOri,nRecOri)
	ElseIf CT2->CT2_AGLUT == "2"				// Lancamento nao Aglutinado
			If FunName() == "CTBC020"
				aAreaCT2:= GetArea()
				DbSelectArea("CV3")
				CV3->(DbSetOrder(2))
  				If DbSeek(xFilial("CV3")+nRecDes,.F.)
		  			nRecno:= CV3->(RECNO())
	  				CtbRastrear(nRecno)
		  		EndIf
		  		RestArea(aAreaCT2)
		  	Else
				CtbRastrear()
			Endif
	ElseIf CT2->CT2_AGLUT == "3"				// Lancamento importado
		Help(" ",1,"CTB010IMP")
	EndIf

EndIf
RestArea(aArea)
Set(_SET_DELETED, lDel)
RestInter()
Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTC010VAL ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se o lancamento contabil podera ser rastreado        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTC010Val(cSequenc,cPadrao)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  : Sequencia                                         ³±±
±±³          ³ ExpC2  : Codigo do lancamento padrao                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctc010Val(cSequenc,dDtCV3,dDatCT2,cLote,cSbLote,cDocto)

Local aSaveArea:= GetArea()
Local lRet		:= .T.
Local aBindCT2 
Static _oQryCT2LP

Default cSequenc := CT2->CT2_SEQUEN
Default dDtCV3	 := CT2->CT2_DTCV3
Default dDatCT2  := CT2->CT2_DATA
Default cLote    := CT2->CT2_LOTE
Default cSbLote  := CT2->CT2_SBLOTE
Default cDocto   := CT2->CT2_DOC

If _oQryCT2LP == NIL
	_oQryCT2LP := "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_SEQUEN, CT2_DTCV3, CT2_ROTINA, CT2_LP FROM "
	_oQryCT2LP += RetSqlName("CT2")
	_oQryCT2LP += " WHERE CT2_FILIAL = ? "
	_oQryCT2LP += " AND CT2_DATA     = ? "
	_oQryCT2LP += " AND CT2_LOTE     = ? "
	_oQryCT2LP += " AND CT2_SBLOTE   = ? "
	_oQryCT2LP += " AND CT2_DOC      = ? "
	_oQryCT2LP += " AND CT2_SEQUEN   = ? "
	_oQryCT2LP += " AND CT2_DTCV3    = ? "
	_oQryCT2LP += " AND D_E_L_E_T_   = ? "
	_oQryCT2LP += " AND ( CT2_ROTINA IN ('WFNFIN','WFNCASH','WFNLEAS','CTBA101','CTBA102','CTBA500') OR CT2_SEQUEN = ' ' OR CT2_LP = ' ' )"
	_oQryCT2LP += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_SEQUEN, CT2_DTCV3, CT2_ROTINA, CT2_LP"
	_oQryCT2LP += " ORDER BY CT2_SEQUEN, CT2_LP, CT2_ROTINA "
	_oQryCT2LP := ChangeQuery(_oQryCT2LP) 
EndIf 
aBindCT2 := {}
AADD(aBindCT2, xFilial("CT2") )
AADD(aBindCT2, DTOS(dDatCT2) )
AADD(aBindCT2, cLote )
AADD(aBindCT2, cSbLote )
AADD(aBindCT2, cDocto )
AADD(aBindCT2, cSequenc )
AADD(aBindCT2, DTOS(dDtCV3) )
AADD(aBindCT2, Space(1) )
dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_oQryCT2LP,aBindCT2),'QCT2RAST')
aSize(aBindCT2,0)
aBindCT2 := nil 
If QCT2RAST->(!Eof())

	If ALLTRIM(QCT2RAST->CT2_ROTINA) $ "WFNFIN/WFNCASH/WFNLEAS"
		Help(" ",1,"GESPLAN",,STR0022,1,0) //"Lançamento gerado por Integração Gesplan"
		lRet := .F.
	ElseIf ALLTRIM(QCT2RAST->CT2_ROTINA) $ "CTBA101/CTBA102"
		Help(" ",1,"LancMan")
		lRet := .F.
	ElseIf ALLTRIM(QCT2RAST->CT2_ROTINA) == "CTBA500"
		Help(" ",1,"CONTABTXT",,STR0019,1,0)  //"Gerado por Contabilizacao TXT"
		lRet := .F.
	ElseIf Empty(QCT2RAST->CT2_SEQUEN) .Or. Empty(QCT2RAST->CT2_LP)
		Help(" ",1,"NODRILL")
		lRet := .F.
	EndIf

EndIf
QCT2RAST->( dbCloseArea() )	

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBAglut  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica os lanc. a serem rasterados,caso sejam aglutinados.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbAglut(cSequenc,cPadrao)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1  : Sequencia                                         ³±±
±±³          ³ ExpC2  : Codigo do Lancamento Padrao                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION CtbAglut(cSequenc,dDtCV3,cTabOri, nRecOri)

Local cFilCV3	:= ""
Local aSize		:= MsAdvSize(,.F.,430)
Local nRecno    := 0
Local aAreaCT2  := GetArea()

PRIVATE aRotina := {	{OemToAnsi(STR0001)	,"AxPesqui"  	, 0, 1},;	// "Pesquisar"
							{OemToAnsi(STR0003)	,"CtbRastrear"	, 0, 2},;	// "Rastrear"
							{OemToAnsi(STR0018)	,"FiltraCV3"	, 0, 3}}		// "Filtro"

lCTxTABORI := Iif( lCTxTABORI == NIL, .T. , lCTxTABORI )
lCTxRECORI := Iif( lCTxRECORI == NIL, .T., lCTxRECORI )
lCTxRECDES := Iif( lCTxRECDES == NIL, .T.,  lCTxRECDES )

If !Empty(CT2->CT2_KEY) .or. (lCTxTABORI .and. lCTxRECORI .and. lCTxRECDES )	/// SE TIVER RASTREAMENTO OU RASTREAMENTO SEM CONFIGURAÇÃO ESTIVER HABILITADO
	dbSelectArea("CV3")
	DbSetOrder(1)
	cFilCV3 := xFilial("CV3")
  	Set Filter to CV3->CV3_FILIAL == cFilCV3 .AND. CV3->CV3_DTSEQ == dDtCV3 .AND. CV3->CV3_SEQUEN == cSequenc
  	// Quando for chamada pela Consulta CTBC020 não aparecer esta tela.
    If FunName() != "CTBC020"
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],OemToAnsi(STR0004),"CV3",,aRotina,,;	//"Rastrear Lan‡amentos Contabeis"
   	         "'"+cFilCV3+DTOS(dDtCV3)+cSequenc+"'",;
      	      "'"+cFilCV3+DTOS(dDtCV3)+cSequenc+"'",.F.,,,,xFilial('CV3')+DTOS(CV3_DTSEQ)+CV3_SEQUEN,,,.F.,.F.)
  	Else
		aAreaCT2:= GetArea()
		DbSelectArea("CV3")
		CV3->(DbSetOrder(3))
		If DbSeek(xFilial("CV3")+cTabOri+nRecOri,.F.)
  			nRecno:= CV3->(RECNO())
			CtbRastrear(nRecno)
  		EndIf
    EndIf
	dbSelectArea("CV3")
	Set Filter to
	RestArea(aAreaCT2)
Else
	ApMsgAlert(STR0006) //"Verifique as chaves de relacionamento"
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FiltraCV3 ³Autor  ³Eduardo Nunes       ³ Data ³  30/06/06   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para Filtrar (atraves do botao Filtro) Lancamentos  ³±±
±±³          ³ Rastreados                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FiltraCV3{)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FiltraCV3()
Local cFilCV3 := ""

Set Filter to
cFilCV3 := BuildExpr("CV3")	//	Exibe a tela do filtro e retorna o filtro informado pelo usuario
Set Filter to &cFilCV3

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbRastrea³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina utilizada para Rastrear Lancamento Contabil         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbRastrear()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

FUNCTION CtbRastrear(nRecno)
Local cArq		:= ""
Local cChave	:= ""
Local nOrdem	:= 1
Local cSequenc	:= CT2->CT2_SEQUEN
Local cPadrao  	:= CT2->CT2_LP
Local dDtCV3	:= CT2->CT2_DTCV3
Local cCad		:= cCadastro
Local cFilOrig
Local cFilTab	:= cFilAnt
Local lCTL		:= .F.			/// indica se efetua rastreamento pelo CTL.
Local lAchou 	:= .T.
Local cRecCT2	:= ""
Local cRotina	:= ""
Local aAreaOri  := GetArea()
Local aPosCT2	:= CT2->(GetArea())
Local cChaveCT2 := ""
Local aAcho	:= {}
Local nCv3		:= TamSX3("CV3_FILIAL")[1] 



If FunName() == "CTBC020"

	DbSelectArea("CV3")
	DbGoto(nRecno)
EndIf


lCTxTABORI := Iif( lCTxTABORI == NIL, .T., lCTxTABORI )
lCTxRECORI := Iif( lCTxRECORI == NIL, .T. , lCTxRECORI )
lCTxRECDES := Iif( lCTxRECDES == NIL, .T. , lCTxRECDES )

If (lCTxTABORI .and. lCTxRECORI .and. lCTxRECDES )	/// SE RASTREAMENTO SEM CONFIGURAÇÃO ESTIVER HABILITADO

	If CT2->CT2_MOEDLC <> "01"		/// SE FOR LANÇAMENTO EM OUTRA MOEDA POSICIONA NO REGISTRO DA MOEDA 01
		cChaveCT2 := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+"01")
		dbSelectArea("CT2")
		dbSetOrder(1)
		If !dbSeek(cChaveCT2,.F.)		/// SE NÃO ENCONTROU REG. DA MOEDA 01
			RestArea(aPosCT2)			/// RESTAURA POSICIONAMENTO NO CT2
			lAchou := .F. 				/// INDICA QUE NÃO ACHOU PARA TENTAR RASTREAMENTO PELO CTL
		EndIf
	EndIf

	If lAchou			/// INDICA QUE ACHO REGISTRO DA MOEDA 01 NO CT2 (POR ENQUANTO).
		cRecCT2 := ALLTRIM(STR(INT(CT2->(Recno()))))
		If CT2->CT2_AGLUT <> "1"    /// SE NÃO ESTIVER AGLUTINADO JÁ ESTA POSICIONADO NO CV3 (FUNCAO CTBAGLUT() USANDO CT2_SEQUEN )
			/// SE NÃO ESTIVER AGLUTINADO LOCALIZA POSICIONA NO CV3 PELO RECNO DO CT2
			dbSelectArea("CV3")
			If dBOrdRecDes()	// SE NÃO ACHOU O ÍNDICE PELO CV3_RECDES (NICKNAME CV3RECDES) JÁ SETOU O ÍNDICE
				If !dbSeek(xFilial("CV3")+cRecCT2,.F.)
					lAchou := .F.
				EndIf
			Else
				lAchou := .F.
			EndIf
		EndIf
	EndIf

	If lAchou			/// INDICA QUE ACHOU REGISTRO NO CV3 (POR ENQUANTO).
		If !Empty(CV3->CV3_TABORI) .and. !Empty(CV3->CV3_RECORI)
			/// PROCURA NO CT5 OU NO CTL PARA VER A ROTINA A EXECUTAR NA VISUALIZAÇÃO
			dbSelectArea("CTL")
			dbSetOrder(1)
			dbSelectArea("CT5")
			dbSetOrder(1)
			If CT5->(dbSeek(xFilial("CT5")+CV3->CV3_LP,.F.)) .and. !Empty(CT5->CT5_ROTRAS)
				/// 1º ROTINA DE RASTREAMENTO SE HOUVER O CAMPO NO CT5
				cRotina := CT5->CT5_ROTRAS
			ElseIf CTL->(dbSeek(xFilial("CTL")+CV3->CV3_LP)) .AND. !Empty(CTL->CTL_EXECUT) /// SE HOUVER CTL CONFIGURADO PARA O LANÇAMENTO...
				/// 2º ROTINA DE RASTREAMENTO SE HOUVER NO CTL
				cRotina := CTL->CTL_EXECUT
			Else
				/// SE NÃO TIVER EXECUTA ROTINA PADRAO AXVISUAL
				cRotina := "AxVisual(CV3->CV3_TABORI,Recno(),2)"
			EndIf

			dbSelectArea("SX2")
			dbSetOrder(1)
			If dbSeek(CV3->CV3_TABORI)

					cCadastro := alltrim(X2Nome())

				cCadastro += STR0016+alltrim(CV3->CV3_RECORI) //" - Registro: "

				dbSelectArea(CV3->CV3_TABORI)          /// SELECIONA A TABELA DE ORIGEM
				nRecOri := int(val(CV3->CV3_RECORI))   /// CONVERTE RECNO ORIGEM PARA NUMERICO
				dbGoTo(nRecOri)						   /// POSICIONA NO REGISTRO DE ORIGEM

				If CV3->CV3_TABORI $ 'SD1|SD2'
					If CV3->CV3_TABORI == 'SD1'
						dbSelectArea("SF1")
						dbSetOrder(1)
						dbSeek(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_TIPO))
						dbSelectArea("SD1")
					Else
						dbSelectArea("SF2")
						dbSetOrder(2)
						dbSeek(SD2->(D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_DOC+D2_SERIE))
						dbSelectArea("SD2")
					EndIf
				Endif

				If (CV3->CV3_TABORI)->(!Eof()) .and. (CV3->CV3_TABORI)->(Recno()) == nRecOri	/// SE LOCALIZOU
					dbSetOrder(1)
					If Deleted()
						cCadastro := STR0017+cCadastro //" já excluido."
					EndIf
					cFilOrig := cFilAnt
					If !Empty( CV3->CV3_TABORI )
						cFilAnt := &( PrefixoCpo(CV3->CV3_TABORI)+"_FILIAL" )
					EndIf
					If FunName() == "CTBC020"
						aRotina := { {OemToAnsi(STR0001),"AxPesqui"	, 0 , 1},;	// "Pesquisar"
									{OemToAnsi(STR0002),"AxVisual"	, 0 , 2}} 	// "Visualizar"
					End
					If cPaisLoc == "ARG" .And. Alltrim(cRotina) == "CTBRECIBO()"
						cFilAnt := cFilOrig
						&(cRotina)
					Else
						&(cRotina)
						cFilAnt := cFilOrig
					EndIf
				Else
					lAchou := .F.		/// /// SE NÃO LOCALIZOU PELO RECNO DE ORIGEM TENTA RASTREAR PELO CTL
				EndIf
			Else
				lAchou := .F.
			EndIf
		Else
			lAchou := .F.
		EndIf
	EndIf

	If !lAchou 		// INDICA QUE NÃO ENCONTROU NA ORIGEM.
		/// Se houver inconsistencia no rastreamento sem configuração, rastrear pelo CTL
		If !Empty(CT2->CT2_KEY)		/// SE A CHAVE DE RASTREAMENTO ESTIVER PREENCHIDA
			lCTL   	:= .T.			/// EXECUTA RASTREAMENTO PELO CTL
		Else
			ApMsgAlert(STR0006) //"Verifique as chaves de relacionamento"
		EndIf
	EndIf
Else
	If !Empty(CT2->CT2_KEY)		/// SE A CHAVE DE RASTREAMENTO ESTIVER PREENCHIDA
		lCTL   	:= .T.			/// EXECUTA RASTREAMENTO PELO CTL
	Else
		ApMsgAlert(STR0006) //"Verifique as chaves de relacionamento"
	EndIf
EndIf



If lCTL   /// EFETUA RASTREAMENTO PELO CTL
	// Esta rotina podera ser chamada da CtbAglut ou de Ctba010Rot. Se for chamada de
	// CtbAglut, existirá um arq. de trabalho o qual conterá a posição do CV3, senão
	// será necessário pesquisar no CTK pela chave do CT2.
	If CT2->CT2_AGLUT == "1"
		//Caso seja lancamento aglutinado, considerar o LP do CV3, pois o lancamento poder ter sido aglutinado por LP
		//diferentes pela contabilizacao off-line
		cPadrao	:= CV3->CV3_LP

		dbSelectArea("CTL")
		DbSetOrder( 1 )
		If dbSeek( xFilial() + cPadrao )
			cArq		:= CTL->CTL_ALIAS
			nOrdem 		:= Val( CTL->CTL_ORDER )
			cChave 		:= RTrim(CV3->CV3_KEY)
			If	ChkFile( cArq )
				dbSelectArea(cArq)
				dbSetOrder(nOrdem)
				If dbSeek(cChave)
					If !Empty(CTL->CTL_EXECUT)
						&(CTL->CTL_EXECUT)
					Else
						cFilOrig := cFilAnt
						if !Empty( xFilial(cArq) )
							cFilAnt := &( PrefixoCpo(cArq)+"_FILIAL" )
						EndIf
						cCadastro := Alltrim(CTL->CTL_DESC)
						If !MaMakeView( cArq )
							dbSelectArea("SX2")
							dbSetOrder(1)
							dbSeek(cArq)
							cCadastro := AllTrim(X2NOME())+" - "+STR0002 // Visualizar
							dbSelectArea("SX3")
							dbSetOrder(1)
							dbSeek(cArq)
							While !Eof() .And. cArq==SX3->X3_ARQUIVO
								aAdd(aAcho,SX3->X3_CAMPO)
								dbSkip()
							End
							dbSelectArea(cArq)
							axVisual(cArq,(cArq)->(RecNo()),2,aAcho)
						EndIf
						cFilAnt := cFilOrig
					EndIf
				ElseIF ! Empty(cChave)
					ApMsgAlert(STR0007) //"Movimento correspondente nao encontrado !"
				Else
					ApMsgAlert(STR0008) //"Este lancamento foi gerado sem chave de relacionamento !"
				EndIf
			EndIf
		Else
			ApMsgAlert(STR0009) //"Verifique as chaves de relacionamento !"
		EndIf
	Else
		cPadrao	:= CT2->CT2_LP

		dbSelectArea("CTL")
		DbSetOrder( 1 )
		If dbSeek( xFilial("CTL") + cPadrao )
			cArq		:= CTL->CTL_ALIAS
			nOrdem 		:= Val( CTL->CTL_ORDER )
			cChave 		:= RTrim(CT2->CT2_KEY)
	  		If	ChkFile( cArq )
				dbSelectArea(cArq)
				dbSetOrder(nOrdem)
				If dbSeek(cChave)
					If !Empty(CTL->CTL_EXECUT)
						cFilOrig := cFilAnt
						if !Empty( xFilial(cArq) )
							cFilAnt := &( PrefixoCpo(cArq)+"_FILIAL" )
						EndIf
						&(CTL->CTL_EXECUT)
						cFilAnt := cFilOrig
					Else
						cFilOrig := cFilAnt
						if !Empty( xFilial(cArq) )
							cFilAnt := &( PrefixoCpo(cArq)+"_FILIAL" )
						EndIf
						cCadastro := Alltrim(CTL->CTL_DESC)
						AxVisual(cARQ,Recno(),2)
						cFilAnt := cFilOrig
					EndIf
				ElseIF !Empty(cChave)
					ApMsgAlert(STR0007) //"Movimento correspondente nao encontrado !"
				Else
					ApMsgAlert(STR0008) //"Este lancamento foi gerado sem chave de relacionamento !"
				EndIf
			EndIf
		Else
			ApMsgAlert(STR0009) //"Verifique as chaves de relacionamento !"
		EndIf
	Endif
EndIf

cCadastro := cCad
RestArea(aPosCT2)
RestArea(aAreaOri)

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBC010Del³ Autor ³ Wagner Mobile Costa   ³ Data ³ 13.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ativa/Desativa registro deletados                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbC010Del                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBC010Del

Local aRet := {}

If 	ParamBox( {	{3,STR0011,If(Set(_SET_DELETED), 2, 1),; //"Mostra deletados"
	{ STR0012, STR0013 },50,"",.F.}}, STR0010,@aRet) //"Sim"###"Nao"###"Status consulta"
	If aRet[1] = 1
		Set(_SET_DELETED, .F.)
	 Else
		Set(_SET_DELETED, .T.)
	Endif
Endif

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBC010   ºAutor  ³Microsiga           º Data ³  01/30/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function dBOrdRecDes()

Local lRetorno := .T.

If dbNickOrder("CV3","CV3RECDES") == 0
	If !IsBlind()
		nAviso := 4
			MsgInfo(STR0014+CRLF+;
					"CV3_FILIAL+CV3_RECDES - NickName CV3RECDES ",;
					STR0015)//"ATENCAO ! Administrador."
					//STR0014="Verifique criacao de indices: "
					//STR0015="ATENCAO ! Administrador."
    EndIf
   	lRetorno := .F.
EndIf

Return lRetorno



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³06/12/06 ³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
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
Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"	, 0 , 1},;	// "Pesquisar"
                     {OemToAnsi(STR0002),"AxVisual"	, 0 , 2},; 	// "Visualizar"
                     {OemToAnsi(STR0003),"CtbC010Rot"	, 0 , 2},;
                     {STR0010	,"CtbC010Del"	, 0 , 0}} //"Status consulta"
Return(aRotina)
