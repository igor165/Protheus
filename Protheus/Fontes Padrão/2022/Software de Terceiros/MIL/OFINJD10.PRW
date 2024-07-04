#include "OFINJD10.CH"
#include "PROTHEUS.CH"

#define lDebug .f.

#define PECAPED_LINENUMBER           01
#define PECAPED_PARTNUMBER           02
#define PECAPED_TIPOPEDIDO           03
#define PECAPED_VALORTOTAL           04
#define PECAPED_QUANTIDADE           05
#define PECAPED_QUANTIDADECANCELADA  06
#define PECAPED_STATUS               07
#define PECAPED_LINHAPROCESSADA      08
#define PECAPED_SPLITLINE            09
#define PECAPED_STATUS2              10
#define PECAPED_ITEFAB               11
#define PECAPED_USADO                12

Static oOktaCfg := NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFINJD10 ³ Autor ³ Thiago ³							  Data ³ 22/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importação/Exportação de pedido de pecas (WebService).                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Auto Pecas                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFINJD10()
PRIVATE aRotina  := MenuDef()
PRIVATE aRet     := {}

If lDebug
	MsgInfo("Rotina em modo debug.")
EndIf

Mata120(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Orcamento de Pecas e Servicos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Auto Pecas                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {;
	{ STR0001 	,"AxPesqui" 		, 0 , 1},;			// Pesquisar
	{ STR0002 	,"A120Pedido"   	, 0 , 2},;			// Visualizar
	{ STR0003 	,"A120Pedido"   	, 0 , 3},;			// Incluir
	{ STR0004 	,"ONJDPedido"   	, 0 , 4},;			// Alterar
	{ STR0037 	,"ONJDPedido"   	, 0 , 5},;			// Excluir
	{ STR0005 	,"OFJD10E"   		, 0 , 7},;			// Exportação
	{ STR0006 	,"OJD010INC"	 	, 0 , 3},;			// Importação
	{ STR0127 	,"OJD010LTOK"	 	, 0 , 2},;			// Limpar Token
	{ STR0028 	,"ONJDRel"	 		, 0 , 9},;			// Impr. ped. pendentes
	{ STR0025 	,"A120Legend"	 	, 0 , 2} }			// Leganda


If ( ExistBlock("ONJD10BT") ) // Ponto de entrada para adicionar botões na mbrowse na tela de orçamentos fases
	aRotina := ExecBlock("ONJD10BT",.f.,.f.,{aRotina})
EndIf

If .f. // Removendo warning
	OFJD10TEMPOPROC()
EndIf

Return aRotina

Function OJD010Sinc()

	If Empty(SC7->C7_PEDFAB)
		FMX_HELP("OJD010ERR001",STR0128) // "Pedido de compra não possui numero de pedido da fábrica."
		Return .f.
	EndIf
	cNrPed := SC7->C7_PEDFAB
	OFJD10SincItPed(cNrPed , .f. )
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFJD10E ³ Autor ³ Thiago ³							  Data ³ 05/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exportacao do pedido de compras.						                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Auto Pecas                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFJD10E()

	Local cDesc1  := STR0007
	Local cDesc2  := STR0008
	Local aSay:= {}
	Local aButton := {}

	Private cTitulo := STR0009
	Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
	Private cArquivo			// Nome do Arquivo a ser importado
	Private oNo      := LoadBitmap( GetResources(), "LBNO" )
	Private oTik     := LoadBitmap( GetResources(), "LBTIK" )

	aAdd( aSay, cDesc1 ) // Um para cada cDescN
	aAdd( aSay, cDesc2 ) // Um para cada cDescN
	//
	nOpc := 0
	aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
	aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
	//
	FormBatch( cTitulo, aSay, aButton )
	//
	If nOpc <> 1
		Return
	Endif

	RptStatus( {|lEnd| ExportArq(@lEnd)},"",STR0010)

return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ExportArq  | Autor | Thiago                | Data | 11/12/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exporta arquivo - PMLINK.							        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ExportArq()

Local cAliasSC7 := "SQLSC7"
Local i         := 0
Local aPecas    := {}
Local nQuantidade := 0
Local nSomQtd   := 0
Local cString   := ""
Local cStr      := ""
Local cNrPed    := ""
Local aAtivo    := {}
Local cCodFab   := ""
Local aCodFab   := {}

Local lPedPro    := SB1->(FieldPos("B1_PEDPRO")) > 0
Local lC7_TIPPED := SC7->(FieldPos("C7_TIPPED")) > 0

//
//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
aSize  := {}
cArquivo := "OFINJD10.XML"
//

cQuery := "SELECT SC7.C7_ITEM,SC7.C7_QUANT,SC7.C7_PRODUTO,SC7.C7_CODPRO,SC7.C7_PRECO,SB1.B1_QE,SB1.B1_GRUPO,SB1.B1_CODITE,SB1.B1_DESC,SB1.B1_CODFAB,"
If lC7_TIPPED
	cQuery += "SC7.C7_TIPPED,VEJ.VEJ_PEDEDI,"
Else
	cQuery += "' ' AS VEJ_PEDEDI,"
EndIf
if lPedPro
	cQuery += "SB1.B1_PEDPRO,"
Endif
cQuery += "SB1.R_E_C_N_O_ SB1RECNO, SB5.R_E_C_N_O_ SB5RECNO, SC7.R_E_C_N_O_ SC7RECNO , SE4.E4_DESCRI "
cQuery += "FROM "
cQuery += RetSqlName( "SC7" ) + " SC7 "
cQuery += "INNER JOIN "+RetSQLName("SB1")+" SB1 ON  SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND SB1.B1_COD = SC7.C7_PRODUTO AND SB1.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSQLName("SB5")+" SB5 ON  SB5.B5_FILIAL  = '"+xFilial("SB5")+"' AND SB5.B5_COD = SC7.C7_PRODUTO AND SB5.D_E_L_E_T_=' ' "
If lC7_TIPPED
	cQuery += "LEFT JOIN "+RetSQLName("VEJ")+" VEJ ON  VEJ.VEJ_FILIAL  = '"+xFilial("VEJ")+"' AND VEJ.VEJ_TIPPED  = SC7.C7_TIPPED AND VEJ.D_E_L_E_T_=' ' "
EndIf
cQuery += "LEFT JOIN "+RetSQLName("SE4")+" SE4 ON  SE4.E4_FILIAL  = '"+xFilial("SE4")+"' AND SE4.E4_CODIGO = SC7.C7_COND AND SE4.D_E_L_E_T_=' ' "
cQuery += "WHERE "
cQuery += "SC7.C7_FILIAL='"+ xFilial("SC7")+ "' AND SC7.C7_NUM = '"+SC7->C7_NUM+"' AND SC7.C7_PEDFAB = ' ' AND "
cQuery += "SC7.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSC7, .T., .T. )

if ( cAliasSC7 )->( Eof() )
	if isBlind()
		Help(,,"",,STR0073,1,0)
	else
		MsgStop(STR0073)
	endif
	( cAliasSC7 )->( dbCloseArea() )
	Return(.f.)
Endif

If oOktaCfg == NIL
	oOktaCfg := OFJDOktaConfig():New()
	oOktaCfg:GetConfig()
EndIf

If lDebug
	MsgInfo(cValToChar(oOktaCfg:pmLinkJDPoint()))
EndIf

If oOktaCfg:pmLinkJDPoint()
	oWS := WSJDPMLinkWS_2_3_Pedido_Compra():New()
Else
	oWS := WSJDPMLinkWS_1_2_Pedido_Compra():New()
EndIf
//oWS:SetDebug(lDebug)

oWS:oWSorderBean:caccountid :=  alltrim(GetMV("MV_MIL0005"))
oWS:oWSorderBean:cdealerordernumber := alltrim(SC7->C7_NUM)
oWS:oWSorderBean:creceivedBy := "P"
oWS:oWSorderBean:cwillCall := "S"

Do While !( cAliasSC7 )->( Eof() )

	cCodPro := ( cAliasSC7 )->( C7_PRODUTO)
	cCodFab := ( cAliasSC7 )->( B1_CODFAB )
	// Verifica se o item esta ativo para ser usado no pedido
	if lPedPro
		if ( cAliasSC7 )->B1_PEDPRO <> "1"
			nPosAt := aScan(aAtivo,{|x| x[1] == cCodPro } )
			if nPosAt == 0
				aAdd(aAtivo,{cCodPro})
				if Empty(cString)
					cString := STR0076+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Produto(s) abaixo relacionado(s) não foram exportado(s) pois encontram-se bloqueado(s) para realizar pedido de compra.
				Endif
				cString += cCodPro+" - "+( cAliasSC7 )->B1_DESC+CHR(13)+CHR(10)
			Endif
			dbSelectArea(cAliasSC7)
			( cAliasSC7 )->(dbSkip())
			Loop

		Endif
	Endif
	// Verifica se o campo B1_CODFAB esta preenchido
	if Empty(cCodFab)
		nPosAt := aScan(aCodFab,{|x| x[1] == cCodPro } )
		if nPosAt == 0
			aAdd(aCodFab,{cCodPro})
			if Empty(cStr)
				cStr := STR0085+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			Endif
			cStr += cCodPro+" - "+( cAliasSC7 )->B1_DESC+CHR(13)+CHR(10)
		Endif
		dbSelectArea(cAliasSC7)
		( cAliasSC7 )->(dbSkip())
		Loop
	Endif
	SB5->( DbGoto( ( cAliasSC7 )->(SB5RECNO) ) )

	aAdd(aPecas,{;
		( cAliasSC7 )->VEJ_PEDEDI,;
		Alltrim(( cAliasSC7 )->E4_DESCRI),;
		( cAliasSC7 )->C7_CODPRO,;
		( cAliasSC7 )->C7_QUANT,;
		( cAliasSC7 )->B1_CODFAB,;
		( cAliasSC7 )->B1_DESC,;
		( cAliasSC7 )->( C7_PRODUTO),;
		FM_PRODSBZ(cCodPro,"SB5->B5_LOCALI2"),;
		( cAliasSC7 )->(SB1RECNO);
	})

	dbSelectArea(cAliasSC7)
	( cAliasSC7 )->(dbSkip())
Enddo
( cAliasSC7 )->( dbCloseArea() )

aSort(aPecas,1,,{|x,y| x[7] < y[7]})
For i := 1 to Len(aPecas)

	If oOktaCfg:pmLinkJDPoint()
		AADD( oWS:oWSorderBean:oWSOrderLines, PMLinkWS_2_3Service_PMLinkOrderLineBean():New() )
	Else
		AADD( oWS:oWSorderBean:oWSOrderLines, JD_POINT_PEDC_PMLinkOrderLineBean():New() )
	EndIf
	nAuxPos := Len(oWS:oWSorderBean:oWSOrderLines)
	//	oWS:oWSorderBean:oWSOrderLines[nAuxPos]:clineNumber := ( cAliasSC7 )->

	dbSelectArea("SB1")
	dbGoTo(aPecas[i,9])
	oWS:oWSorderBean:corderType := aPecas[i,1]
	oWS:oWSorderBean:clineOfCreditId := aPecas[i,2]
	oWS:oWSorderBean:cprogramNumber := aPecas[i,3]
	nResto := (int(aPecas[i,4]/SB1->B1_QE)/(aPecas[i,4]/SB1->B1_QE ))

	if (SB1->B1_QE <> 0)
		if i+1 <= Len(aPecas)
			if aPecas[i,7] == aPecas[i+1,7]
				nSomQtd += aPecas[i,4]
			Endif
			if aPecas[i,7] <> aPecas[i+1,7] .and. nSomQtd > 0
				nSomQtd += aPecas[i,4]
				nQuantidade	:= nSomQtd
				nQtdE := int(nQuantidade / SB1->B1_QE)
				nQtdEmb := SB1->B1_QE - (nQuantidade - (SB1->B1_QE * nQtdE))
				nQTEmb  := nQtdEmb
				nSomQtd := 0
				nQuantidade := aPecas[i,4] + nQTEmb
			Endif
		Else
			if nSomQtd > 0
				nSomQtd += aPecas[i,4]
				nQuantidade	:= nSomQtd
				nQtdE := int(nQuantidade / SB1->B1_QE)
				nQtdEmb := SB1->B1_QE - (nQuantidade - (SB1->B1_QE * nQtdE))
				nQTEmb  := nQtdEmb
				nSomQtd := 0
				nQuantidade := aPecas[i,4] + nQTEmb
			Endif
		Endif
	Else
		nQuantidade := aPecas[i,4]
	Endif
	if nQuantidade > 0 .and. nQuantidade <> aPecas[i,4]
		If ! isBlind() .and. MsgYesNo(STR0074+CHR(13)+CHR(10)+STR0075+SB1->B1_COD+" - "+SB1->B1_DESC)
			oWS:oWSorderBean:oWSOrderLines[nAuxPos]:corderedquantity := Alltrim(str(nQuantidade))
		Endif
	Else
		if (SB1->B1_QE <> 0) .and. ((SB1->B1_QE > aPecas[i,4]) .or. ;
			(SB1->B1_QE < aPecas[i,4] .and. nResto <> 1)) .and. nSomQtd == 0
			If ! isBlind() .and. MsgYesNo(STR0074+CHR(13)+CHR(10)+STR0075+SB1->B1_COD+" - "+SB1->B1_DESC)
				if SB1->B1_QE > aPecas[i,4]
					oWS:oWSorderBean:oWSOrderLines[nAuxPos]:corderedquantity := Alltrim(str(SB1->B1_QE))
				Else
					nQtdE := int(aPecas[i,4] / SB1->B1_QE)
					nQtdEmb := SB1->B1_QE - (aPecas[i,4] - (SB1->B1_QE * nQtdE))
					nQTEmb  := aPecas[i,4]+nQtdEmb
					oWS:oWSorderBean:oWSOrderLines[nAuxPos]:corderedquantity := Alltrim(str(nQTEmb))
				Endif
			Else
				oWS:oWSorderBean:oWSOrderLines[nAuxPos]:corderedquantity := Alltrim(str(aPecas[i,4]))
			Endif
		Else
			oWS:oWSorderBean:oWSOrderLines[nAuxPos]:corderedquantity := Alltrim(str(aPecas[i,4]))
		Endif
	Endif
	nQuantidade := 0
	oWS:oWSorderBean:oWSOrderLines[nAuxPos]:cpartNumber := AllTrim(SB1->B1_CODFAB)
	oWS:oWSorderBean:oWSOrderLines[nAuxPos]:cpartname := AllTrim(SB1->B1_DESC)
	oWS:oWSorderBean:oWSOrderLines[nAuxPos]:cdealerBinLocation := aPecas[i,8]
Next

if !Empty(cString)
	if isBlind()
		conout(cString)
	else
		MsgInfo(cString)
	endif
Endif
if !Empty(cStr)
	if  isBlind()
		conout(cStr)
	else
		MsgInfo(cStr)
	endif
Endif

/////////////////////////////////////////////
// Gravacao do numero do pedido da fabrica //
/////////////////////////////////////////////
lProcessado := .f.

if isBlind()
	lProcessado := oWS:submitOrder()
else
	MsgRun(STR0011,STR0018,{|| lProcessado := oWS:submitOrder() })
endif

If !lProcessado
	oWS:ExibeErro()
	Return
EndIf

nQtdItens := 1

If oWS:oWSsubmitOrderReturn:creturnCode == "0"
	if isBlind()
		conout("OFINJD10 -> " + STR0013 + oWS:oWSsubmitOrderReturn:cresponseMessage)
	else
		MsgInfo(STR0013 + oWS:oWSsubmitOrderReturn:cresponseMessage )
	endif
Else
	cQuery := "SELECT SC7.C7_ITEM,SC7.C7_QUANT,SC7.C7_PRODUTO,SC7.C7_PRECO,"
	If lC7_TIPPED
		cQuery += "SC7.C7_TIPPED,VEJ.VEJ_PEDEDI,"
	Else
		cQuery += "' ' AS VEJ_PEDEDI,"
	EndIf
	if lPedPro
		cQuery += "SB1.B1_PEDPRO,"
	Endif
	cQuery += "SB1.B1_DESC,SB1.B1_CODFAB, SC7.R_E_C_N_O_ SC7RECNO "
	cQuery += "FROM "
	cQuery += RetSqlName( "SC7" ) + " SC7 "
	cQuery += "INNER JOIN "+RetSQLName("SB1")+" SB1 ON  SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND SB1.B1_COD = SC7.C7_PRODUTO AND "
	if lPedPro
		cQuery += "SB1.B1_PEDPRO = '1' AND "
	Endif
	cQuery += "SB1.D_E_L_E_T_=' ' "
	If lC7_TIPPED
		cQuery += "LEFT JOIN "+RetSQLName("VEJ")+" VEJ ON  VEJ.VEJ_FILIAL  = '"+xFilial("VEJ")+"' AND VEJ.VEJ_TIPPED  = SC7.C7_TIPPED AND VEJ.D_E_L_E_T_=' ' "
	EndIf
	cQuery += "WHERE "
	cQuery += "SC7.C7_FILIAL='"+ xFilial("SC7")+ "' AND SC7.C7_NUM = '"+SC7->C7_NUM+"' AND SC7.C7_PEDFAB = ' ' AND "
	cQuery += "SC7.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSC7, .T., .T. )

	Do While !( cAliasSC7 )->( Eof() )

		dbSelectArea("SC7")
		dbGoTo((cAliasSC7)->SC7RECNO)
		RecLock("SC7",.f.)
		SC7->C7_PEDFAB := oWS:oWSsubmitOrderReturn:corderNumber
		cNrPed := oWS:oWSsubmitOrderReturn:corderNumber
		MsUnlock()

		dbSelectArea(cAliasSC7)
		( cAliasSC7 )->(dbSkip())
	Enddo
	( cAliasSC7 )->( dbCloseArea() )

	MsgInfo(oWS:oWSsubmitOrderReturn:cresponseMessage+CHR(13)+CHR(10)+STR0012+oWS:oWSsubmitOrderReturn:corderNumber )

	/////////////////////////////////////////////////////////////////////////////////////////
	// Buscar o codigo sequencial do item no portal do JD e gravar no protheus (C7_ITEPED) //
	/////////////////////////////////////////////////////////////////////////////////////////
	if SC7->(FieldPos("C7_ITEPED")) > 0
		OFJD10SincItPed(cNrPed , .t. )
	Endif

	//////////////////////////
	//Impressao do relatorio//
	//////////////////////////
	ONJDRel(,,,"1",cNrPed , .F.)

EndIf
//


Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OJD010INC     ³ Autor ³ Thiago ³							    Data ³ 22/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importação do pedido de compra. (OrderStatus)				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Auto Pecas                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OJD010INC()


Local cDesc1  := STR0014
Local cDesc2  := STR0038
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0015
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
Private cBkpFilAnt := cFilAnt // salvar cFilAnt

cFilant := FWPesqSM0("M0_CODFIL",cEmpAnt)  // Escolher a filial que deseja trabalhar

If Empty(cFilAnt)
	cFilant := cBkpFilAnt
	Return
EndIf

aAdd( aSay, cDesc1 ) // Um para cada cDescN
aAdd( aSay, cDesc2 ) // Um para cada cDescN
//
FS_PergImp()

nOpc := 0
aAdd( aButton, { 5, .T., {|| FS_PergImp()    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	cFilant := cBkpFilAnt
	Return
Endif

Processa( {|| OFJD10I() }, "", STR0016,.F.)

cFilAnt := cBkpFilAnt

return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFJD10I    | Autor | Thiago                | Data | 11/12/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importar arquivo.									        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFJD10I( cPedJD , cFornece , cLoja , cCondicao , cCodMarca , lImpXml , aVetPed, oProcImpXML, cIntErr , lTelas )
	Local nx := 1
	Local nOpcao := 3
	Local aPecasPed
	Local cPedFab
	Local aPecasNaoEncontradas := {}
	Local lContImportacao := .f.
	//
	Local lB1_MSBLQL := SB1->(FieldPos("B1_MSBLQL")) > 0
	//
	Private aItem := {}
	Private aAtuManual := {}
	Private nOpca := 1
	Private lProcessado := .f.
	Private lProcExecAuto := .f. // Se for alteracao, controla se é necessário executar ExecAuto
	//
	Private aTempoProc := {}
	//
	Private nTamC7Preco := TamSX3("C7_PRECO")[2]
	Private nTamC7Total := TamSX3("C7_TOTAL")[2]
	//
	Private cC7Produto
	Private cC7UM
	Private nC7Quant
	Private nC7Preco
	Private nC7Total
	Private dC7DataPedido
	Private cC7Local
	Private cC7StatusPed
	Private cC7TpPed
	Private cC7Cond
	//
	Default cPedJD    := ""
	Default cFornece  := ""
	Default cLoja     := ""
	Default cCondicao := ""
	Default cCodMarca := ""
	Default lImpXml   := .f.
	Default aVetPed   := {}
	Default cIntErr   := ""
	Default lTelas    := !IsBlind()

	If lDebug
		MsgInfo(STR0111) // "Rotina em modo DEBUG"
	EndIf

	// Pedido de compra no WebService da John Deere
	if GetNewPar("MV_ALTPC",.F.)==.T.
		Help(,,"",,STR0089,1,0)
		Return(.f.)
	Endif
	//
	if SuperGetMv("MV_ALTPEDC") <> "S"
		Help(,,"",,STR0112,1,0)
		Return(.f.)
	Endif
	//
	cPedFab := IIf(!Empty(cPedJD),cPedJD,IIf(type("aRet[5]")<>"U",AllTrim(aRet[5]),""))
	If Empty(cPedFab)
		Help(,,"",,STR0113,1,0)
		Return(.f.)
	Endif	

	// Rubens
	// Implantacao do estoque encomendado - v2.0
	// Não será possível atualizar Pedido de Compra onde o campo de sublinha estiver sem conteúdo
	If OFJD10SemSubLinha( cPedFab )

		If OFJD10PedSemMovimentacao( cPedFab )
			lContImportacao := OFJD10SincItPed( cPedFab , .f. , lTelas)
		EndIf
		If lContImportacao == .f.  
			If !lImpXml .and. lTelas
				Aviso(STR0104,;
					STR0105 + chr(13) + chr(10) + ; // "Foi criado o campo Sublinha It. (C7_SLITPED) para conter a sub-linha do item do pedido de compra."
					STR0106 + chr(13) + chr(10) + ; // "Os pedidos de compra existentes no Protheus anteriores a criação deste campo não serão mais atualizados por esta rotina."
					STR0107,; //"Por este motivo, é mandatório que seja executada a rotina de eliminação de resíduos para este pedido."
					{ STR0108 } , 3 )
			EndIf
			Return .t.
		EndIf
	EndIf

	If oOktaCfg == NIL
		oOktaCfg := OFJDOktaConfig():New()
		oOktaCfg:GetConfig()
	EndIf

	If lDebug
		MsgInfo(cValToChar(oOktaCfg:orderStatusJDPoint()))
	EndIf

	If oOktaCfg:orderStatusJDPoint()
		//MsgInfo("Teste de Versao com o Okta - OrderStatus - 2.4")
		oWS := WSJohnDeereJDPoint_1_4_Pedido_Compra():New()
		ows:cUserId := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
	Else
		oWS := WSJohnDeereJDPoint_Pedido_Compra():New()
	EndIf
	//oWS:SetDebug(lDebug)
	If oWS:ERRO
		Return(.f.)
	EndIf

	oWS:corderNumber   := cPedFab
	oWS:caccountnumber := AllTrim(GetMV("MV_MIL0005"))
	//
	If !lImpXml .and. lTelas
		ProcRegua(5)
	EndIf
	If lTelas
		OFJD10BARRAPROGRESSO(AllTrim(oWS:corderNumber) + " " + STR0093, lImpXml) // Consultando Pedido de Compra
	EndIf
	//
	FWMsgRun(;
		,;
		{|| lProcessado := oWS:retrieveOrderStatus() } ,;
		STR0018,;
		STR0094 + " - " + AllTrim(oWS:corderNumber) ) // Consultando pedido de compra no JDPoint
	If !lProcessado
		oWS:ExibeErro()
		Return(.f.)
	EndIf
	if Upper(Alltrim(oWS:oOrderStatusReturn:cexceptionReport)) == "ORDER NOT FOUND" .or. oWS:oOrderStatusReturn:cexceptionReport == NIL
		Help(,,STR0021,,STR0088,1,0)
		Return(.f.)
	Endif
	//
	cPedFab       := oWS:oOrderStatusReturn:cordernumber
	dC7DataPedido := OFJD10DATAORDERED(oWS:oOrderStatusReturn:cdateOrdered)
	//
	cPedido := FM_SQL(;
		" SELECT SC7.C7_NUM " +;
		  " FROM " + RetSQLName("SC7") + " SC7 " +;
		 " WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "' " +;
		   " AND SC7.C7_PEDFAB = '" + oWS:oOrderStatusReturn:cordernumber + "' " +;
		   " AND SC7.D_E_L_E_T_=' '")
	nItem := 0
	If Alltrim(oWS:oOrderStatusReturn:corderstatus) $ "CANCELLED/CANC_STATUS"
		nOpcao := 5
	ElseIf Empty(cPedido)
		nOpcao := 3
	Else
		nItem := Val( FM_SQL(;
			"SELECT MAX(SC7.C7_ITEM) " +;
			 " FROM " + RetSQLName("SC7") + " SC7 " +;
			" WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'" +;
			  " AND SC7.C7_NUM = '" + cPedido + "'" +;
			  " AND SC7.D_E_L_E_T_=' '" ) )
		nOpcao := 4
	Endif
	// Pedido foi cancelado, mas nao foi encontrado no Protheus. Entao nao faz nada
	if nOpcao == 5 .and. Empty(cPedido)
		Return
	EndIf
	//
	If !lImpXml .and. lTelas
		cCodMarca := MV_PAR01
		cFornece  := aRet[2]
		cLoja     := aRet[3]
		cCondicao := aRet[4]
	EndIf
	//
	cC7TpPed := OFJD10TIPOPEDIDO(cCodMarca, oWS:oOrderStatusReturn:corderType)
	//
	cC7Cond:= OFJD10COND(oWS:oOrderStatusReturn:clineOfCredit)
	//
	aCab := {}
	If !Empty(cPedido)
		AADD(aCab , {"C7_NUM" ,cPedido  ,Nil} ) // Numero do Pedido
	EndIf
	AADD( aCab , {"C7_EMISSAO" ,dC7DataPedido     , Nil } ) // Data de Emissao
	AADD( aCab , {"C7_FORNECE" ,cFornece          , Nil } ) // Fornecedor
	AADD( aCab , {"C7_LOJA"    ,cLoja             , Nil } ) // Loja do Fornecedor
	AADD( aCab , {"C7_COND"    ,cCondicao         , Nil } ) // Condicao de pagamento
	AADD( aCab , {"C7_CONTATO" ,"               " , Nil } ) // Contato
	AADD( aCab , {"C7_FILENT"  ,""                , Nil } ) // Filial Entrega
	//
	if !lImpXml .and. !Empty(cPedido) .and. nOpcao <> 5
		if lTelas .and. !MsgYesNo(STR0019 + cPedFab + STR0020,STR0021)
			Return(.f.)
		Endif
	Endif

	nTamProduto := TamSX3("B1_COD")[1]
	If lTelas
		OFJD10BARRAPROGRESSO( AllTrim(oWS:corderNumber) + " " + STR0095 , lImpXml) // Proc. Retorno WebService
	EndIf
	aPecasPed := OFJD10WSPROC( oWS , lImpXml , aVetPed , cPedFab )
	If lTelas
		OFJD10BARRAPROGRESSO( AllTrim(oWS:corderNumber) + " " + STR0096, lImpXml) // Criando matriz de integração
	EndIf
	// Importacao de Pedido
	aPecasNaoEncontradas := {}
	If Empty(cPedido)
		OFJD10PEDNOVO( aPecasPed , cPedFab , , @aPecasNaoEncontradas , aVetPed )
	Else
		OFJD10PEDATU( aPecasPed , cPedido , cPedFab , @aPecasNaoEncontradas , aVetPed )
	EndIf
	If Len(aPecasNaoEncontradas) > 0 .and. OFJD10PECANAOENCONTRADA(aPecasNaoEncontradas)
		Return .f.
	EndIf
	If lTelas
		OFJD10BARRAPROGRESSO( AllTrim(oWS:corderNumber) + " " + STR0097 , lImpXml) // Integração com MATA120
	EndIf
	if Len(aItem) > 0 .and.	lProcExecAuto
		// Verificação dos Produtos Bloqueados
		If lB1_MSBLQL
			If !ON0100061_VerificacaoProdutosBloqueados(aItem,lTelas)
				Return .f.
			EndIf
		EndIf

		// Integração
		lMsErroAuto := .f.
		aBkpRotina := aClone(aRotina)
		aRotina := StaticCall(MATA120,MENUDEF)
		MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,nOpcao)
		aRotina := aClone(aBkpRotina)
		if lMsErroAuto
			if !lTelas
				oLogger := DMS_Logger():New()
				oLogger:LogSysErr("OFINJD10_MATA120_INTRES_"+FWTimeStamp(3)+".log", .f.)
				cIntErr := ""
				for nX := 1 to len(oLogger:aLines)
					cIntErr += 	oLogger:aLines[nX]  + chr(13) + chr(10)
				next
				conout(cIntErr)
			else
				MostraErro()
			endif
			RollBackSx8()
			DisarmTransaction()
			Break
		Endif
	Endif
	OFJD10ATUMANUAL( cPedido )
	If lTelas
		OFJD10BARRAPROGRESSO( AllTrim(oWS:corderNumber) + " " + STR0098, lImpXml) // Eliminando residuo de itens cancelados
	EndIf
	OFJD10RESIDUO( aPecasPed , cPedFab )

	if !lImpXml .and. lTelas
		ONJDRel(,,,"1",oWS:oOrderStatusReturn:cordernumber , .f.)
	Endif

	OFJD10CONOUT()

Return(.t.)


/*/{Protheus.doc} OFJD10PEDNOVO
Cria um novo pedido de compra
@author Rubens
@since 07/08/2017
@version undefined
@param aPecasPed, array, descricao
@param cPedFab, characters, descricao
@param cItem, characters, descricao
@param aPecasNaoEncontradas, array, descricao
@param aVetPed, array, descricao
@type function
/*/
Static Function OFJD10PEDNOVO( aPecasPed , cPedFab , cItem , aPecasNaoEncontradas , aVetPed )

	Local nCont
	Local lRetorno := .t.
	Default cItem := StrZero(0,TamSX3("C7_ITEM")[1])

	For nCont := 1 to Len(aPecasPed)
		//
		If aPecasPed[nCont,8]
			Loop
		EndIf
		aPecasPed[nCont,8] := .T.
		//
//		If aPecasPed[nCont,PECAPED_STATUS2] $ "CANCELLED/CANC_STATUS"
//			Loop
//		EndIf
		//
		If !OFJD10ATUVAR( aPecasPed[nCont] , @aPecasNaoEncontradas , aVetPed , cPedFab )
			lRetorno := .f.
			loop
		EndIf
		//
		If nC7Quant == 0
			loop
		Endif
		//lPrecisaAlterar := .t.
		lProcExecAuto := .t.
		//
		cItem := Soma1(cItem)
		// Inclusao de item
		AADD( aItem , {;
			{ "C7_ITEM"    , cItem                               , Nil } ,;  // Numero do Item
			{ "C7_PRODUTO" , cC7Produto                          , Nil } ,;  // Codigo do Produto
			{ "C7_UM"      , cC7UM                               , Nil } ,;  // Unidade de Medida
			{ "C7_QUANT"   , nC7Quant                            , Nil } ,;  // Quantidade
			{ "C7_PRECO"   , nC7Preco                            , Nil } ,;  // Preco
			{ "C7_DATPRF"  , dC7DataPedido                       , Nil } ,;  // Data De Entrega
			{ "C7_FLUXO"   , "S"                                 , Nil } ,;  // Fluxo de Caixa (S/N)
			{ "C7_LOCAL"   , cC7Local                            , Nil } ,;  // Localizacao
			{ "C7_STATUS"  , cC7StatusPed                        , Nil } ,;  // Status do Pedido
			{ "C7_TIPPED"  , cC7TpPed                            , Nil } ,;  // Tipo do Pedido
			{ "C7_COND"    , cC7Cond                             , Nil } ,;  // Condicao de pagamento
			{ "C7_PEDFAB"  , cPedFab                             , Nil } ,;  // Pedido
			{ "C7_ITEPED"  , aPecasPed[nCont,PECAPED_LINENUMBER] , Nil } ,;  // Item do pedido
			{ "C7_SLITPED" , aPecasPed[nCont,PECAPED_SPLITLINE]  , Nil } } ) // Sublinha do Item do pedido

	Next nCont

Return lRetorno


/*/{Protheus.doc} OFJD10PEDATU
Atualiza um pedido ja gravado
@author Rubens
@since 07/08/2017
@version undefined
@param aPecasPed, array, descricao
@param cPedNum, characters, descricao
@param cPedFab, characters, descricao
@param aPecasNaoEncontradas, array, descricao
@param aVetPed, array, descricao
@type function
/*/
Static Function OFJD10PEDATU( aPecasPed , cPedNum , cPedFab , aPecasNaoEncontradas , aVetPed )

	Local nPosPeca
	Local cItem := StrZero(0,TamSX3("C7_ITEM")[1])
	Local lJaEntregue := .f.
	Local lRetorno := .t.
	Local lC7_TIPPED := SC7->(FieldPos("C7_TIPPED")) > 0

	// nenhum peça retornada do webservice, talvez fora do ar, retornar sem fazer nada
	if empty(aPecasPed)
		return .f.
	endif

	SC7->(dbSetOrder(1))
	SC7->(dbSeek(xFilial("SC7") + cPedNum ))
	While !SC7->(Eof()) .and. SC7->C7_NUM == cPedNum .and. SC7->C7_FILIAL == xFilial("SC7")

		If Empty(SC7->C7_SLITPED) .and. Empty(SC7->C7_DLINORI)
			SC7->(dbSkip())
			Loop
		EndIf

		nPosPeca := aScan(aPecasPed, {|x| x[PECAPED_LINENUMBER] == Alltrim(SC7->C7_ITEPED) .and. x[PECAPED_SPLITLINE] == Alltrim(SC7->C7_SLITPED)})

		aAuxItem := {}
		If nPosPeca == 0
			If SC7->C7_QUJE == 0 .AND. SC7->C7_QTDACLA == 0
				// jdprism está ficando com iteped e sublinha em branco, normal pois nao tem os dados
				// aqui vou tentar encontrar a linha e sublinha para preencher ao inves de deletar os itens jdprism, se não encontrar deleta mesmo
				nPosPeca := aScan( aPecasPed , { |x| ! Empty(SC7->C7_DLINORI) .and. alltrim(x[PECAPED_PARTNUMBER]) == alltrim(SC7->C7_PRODUTO) .and. x[PECAPED_USADO] == .f.} )
				If nPosPeca == 0
					AADD( aAuxItem , { "LINPOS" , "C7_ITEM" , SC7->C7_ITEM } )
					AADD( aAuxItem , { "AUTDELETA" , "S" , NIL } )
					AADD( aAuxItem , { "C7_ITEM" , SC7->C7_ITEM , NIL } )
					AADD( aItem , aClone(aAuxItem))
				else
					AADD( aAuxItem , { "C7_ITEPED" , aPecasPed[nPosPeca, PECAPED_LINENUMBER] , NIL } ) // gravando linha
					AADD( aAuxItem , { "C7_SLITPED", aPecasPed[nPosPeca, PECAPED_SPLITLINE]  , NIL } ) // gravando sublinha
				endif
			// Else
			// 	AADD( aAuxItem , { "C7_QUANT" , SC7->C7_QUJE + SC7->C7_QTDACLA , NIL } )
			// 	AADD( aAuxItem , { "C7_PRECO" , SC7->C7_PRECO  , NIL } )
			// 	AADD( aAuxItem , { "C7_TOTAL" , (SC7->C7_QUJE + SC7->C7_QTDACLA) * SC7->C7_PRECO  , NIL } )
			EndIf
			
			lProcExecAuto := .t.
		Endif

		if nPosPeca > 0 // se encotrou no segundo filtro ou no primeiro
			aPecasPed[nPosPeca,8] := .t. // Marca item como processado ...
			aPecasPed[nPosPeca, PECAPED_USADO] := .t. // marca como encontrado no jdprism tambem
			lJaEntregue := .f.

			// If aPecasPed[nPosPeca,PECAPED_STATUS2] $ "CANCELLED/CANC_STATUS"
			// 	SC7->(dbSkip())
			// 	Loop
			// EndIf

			If SC7->C7_RESIDUO == 'S' .OR. SC7->C7_ENCER == 'E'
//				SC7->(dbSkip())
//				Loop
				lJaEntregue := .t.
			EndIf

			If SC7->C7_QUJE <> 0 .or. SC7->C7_QTDACLA <> 0
				lJaEntregue := .t.
			EndIf

			// Produto do pedido de compra esta diferente do produto retornado no WebService
			If ! OFJD10ATUVAR( aPecasPed[nPosPeca] , @aPecasNaoEncontradas, aVetPed , cPedFab)
				SC7->(dbSkip())
				lREtorno := .f.
				Loop
			EndIf
			//

			// Campos que so podem ser alterados se o item nao foi entregue pela John Deere
			If lJaEntregue == .f.
				If SC7->C7_PRODUTO <> cC7Produto
					AADD( aAuxItem , { "C7_PRODUTO" , cC7Produto    , NIL } ) //Produto
					lProcExecAuto := .t.
				EndIf

				If (SC7->C7_QUANT <> nC7Quant .or. SC7->C7_PRECO <> nC7Preco) .and. nC7Quant <> 0
					AADD( aAuxItem , { "C7_QUANT"  , nC7Quant       , NIL } ) // Quantidade
					AADD( aAuxItem , { "C7_PRECO"  , nC7Preco       , Nil } ) // Preco
					lProcExecAuto := .t.
				EndIf
				If SC7->C7_DATPRF <> dC7DataPedido
					AADD( aAuxItem , { "C7_DATPRF" , dC7DataPedido , Nil  } ) // Data De Entrega
					lProcExecAuto := .t.
				EndIf
				If SC7->C7_LOCAL <> cC7Local
					AADD( aAuxItem , { "C7_LOCAL"  , cC7Local      , Nil  } ) // Localizacao
					lProcExecAuto := .t.
				EndIf
			EndIf
			//

			// Campos que podem ser alterados mesmo se a peca ja foi entregue
			If lC7_TIPPED .And. Alltrim(SC7->C7_TIPPED) <> Alltrim(cC7TpPed)
				If lJaEntregue == .f.
					AADD( aAuxItem , {"C7_TIPPED"  , cC7TpPed      , Nil  } ) // Tipo do Pedido
				EndIf
				If lProcExecAuto == .f. .or. lJaEntregue
					OFJD10ALTMANUAL(SC7->(Recno()), "C7_TIPPED" , cC7TpPed , lJaEntregue )
				EndIf
			EndIf
			If Alltrim(SC7->C7_STATUS) <> Alltrim(cC7StatusPed)
				If lJaEntregue == .f.
					AADD( aAuxItem , { "C7_STATUS"  , cC7StatusPed , Nil } ) //Status do Pedido
				EndIf
				If lProcExecAuto == .f. .or. lJaEntregue
					OFJD10ALTMANUAL(SC7->(Recno()), "C7_STATUS" , cC7StatusPed , lJaEntregue )
				EndIf
			EndIf
			//

			If Len(aAuxItem) > 0
				AADD( aItem , {} )
				AADD( aItem[Len(aItem)] , { "LINPOS" , "C7_ITEM" , SC7->C7_ITEM } )
				AADD( aItem[Len(aItem)] , { "C7_ITEM" , SC7->C7_ITEM , NIL } )
				aEval( aAuxItem , { |x| AADD( aItem[Len(aItem)] , aClone(x) ) })
			EndIf

		EndIf

		SC7->(dbSkip())
	End

	// Se alguma linha nao foi processada é porque se trata de uma linha/sublinha nova
	If aScan( aPecasPed , { |x| x[8] == .f. }) <> 0
		cItem := FM_SQL(;
			"SELECT MAX(C7_ITEM) " + ;
			 " FROM " + RetSQLName("SC7") + ;
			" WHERE C7_FILIAL = '" + xFilial("SC7") + "'" + ;
			  " AND C7_NUM = '" + cPedNum + "' ")
		lRetorno := OFJD10PEDNOVO( aPecasPed , cPedFab , cItem , @aPecasNaoEncontradas , aVetPed )
	EndIf
	//

Return lRetorno

/*/{Protheus.doc} OFJD10RESIDUO
Elimina residuo de itens cancelados
@author Rubens
@since 07/08/2017
@version undefined
@param aPecasPed, array, descricao
@param cPedFab, characters, descricao
@type function
/*/
Static Function OFJD10RESIDUO( aPecasPed , cPedFab )

	Local nCont
	Local lC7_TIPPED := SC7->(FieldPos("C7_TIPPED")) > 0

	PRIVATE lMT235G1 := existblock("MT235G1") //Variavel declarada para uso da rotina MA235PC, nao utilizada no DMS.

	For nCont := 1 to Len(aPecasPed)

		If aPecasPed[nCont,PECAPED_STATUS2] $ "CANCELLED/CANC_STATUS"

			nRecSC7 := OFJD10SC7RECNO( cPedFab ,;
				aPecasPed[ nCont , PECAPED_LINENUMBER ] ,;
				aPecasPed[ nCont , PECAPED_SPLITLINE ] )

			If nRecSC7 == 0
				Loop
			EndIf

			SC7->(DbGoTo( nRecSC7 ))

			cC7StatusPed := OJD10GTSTS( aPecasPed[nCont, PECAPED_STATUS ] )
			If (lC7_TIPPED .And. Alltrim(SC7->C7_TIPPED) <> Alltrim(cC7TpPed)) .or. Alltrim(SC7->C7_STATUS) <> Alltrim(cC7StatusPed)
				RecLock("SC7",.f.)
				If lC7_TIPPED
					SC7->C7_TIPPED := cC7TpPed
				EndIf
				SC7->C7_STATUS := cC7StatusPed
				SC7->(MsUnlock())
			EndIf


			If SC7->C7_RESIDUO == "S" .or. SC7->C7_ENCER == 'E'
				Loop
			EndIf

			MA235PC(;
				100,;
				1,;         // cTipo2: 1-Pedido, 2-Autor.Entrega, 3-Ambos
				SC7->C7_EMISSAO,;  // dPar3 : Filtrar da Data de Emissao de
				SC7->C7_EMISSAO,;  // dPar4 : Filtrar da Data de Emissao Ate
				SC7->C7_NUM,;   // cPar5 : Filtrar da Solicitacao de
				SC7->C7_NUM,;   // cPar6 : Filtrar da Solicitacao Ate
				SC7->C7_PRODUTO,;  // cPar7 : Filtrar Produto de
				SC7->C7_PRODUTO,;  // cPar8 : Filtrar Produto Ate
				SC7->C7_FORNECE,;     // cPar9 : Filtrar Fornecedor de
				SC7->C7_FORNECE,;     // cPar10: Filtrar Fornecedor Ate
				,;          // dPar11: Filtrar Data Entrega de
				,;          // dPar12: Filtrar Data Entrega de
				SC7->C7_ITEM,;  // cPar13: Filtrar Item de
				SC7->C7_ITEM,;  // cPar14: Filtrar Item Ate
				.T.)        // lPar15: Filtra pedido de origem do EIC
/*
			// cTipo2: 1-Pedido, 2-Autor.Entrega, 3-Ambos
			// dPar3 : Filtrar da Data de Emissao de
			// dPar4 : Filtrar da Data de Emissao Ate
			// cPar5 : Filtrar da Solicitacao de
			// cPar6 : Filtrar da Solicitacao Ate
			// cPar7 : Filtrar Produto de
			// cPar8 : Filtrar Produto Ate
			// cPar9 : Filtrar Fornecedor de
			// cPar10: Filtrar Fornecedor Ate
			// dPar11: Filtrar Data Entrega de
			// dPar12: Filtrar Data Entrega de
			// cPar13: Filtrar Item de
			// cPar14: Filtrar Item Ate
			// lPar15: Filtra pedido de origem do EIC
			MA235PC(nPerc, cTipo, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatprfde, dDatPrfAte, cItemDe, cItemAte, lConsEIC)
*/
		EndIf

	Next nCont
Return

/*/{Protheus.doc} OFJD10PECANAOENCONTRADA
Verifica se as pecas estão cadastradas no sistema
@author Rubens
@since 07/08/2017
@version undefined
@param aPecasNaoEncontradas, array, descricao
@type function
/*/
Static Function OFJD10PECANAOENCONTRADA(aPecasNaoEncontradas)
	Local cMsg := ""
	Local nPos

	For nPos := 1 to Len(aPecasNaoEncontradas)
		cMsg += aPecasNaoEncontradas[nPos,1] + " - " + AllTrim(aPecasNaoEncontradas[nPos,2])+ CHR(13) + CHR(10)
	Next nPos

	nPos := AVISO(STR0099,;
		STR0100 + chr(13) + chr(10) + ; // "As peças listadas abaixo não existem no cadastro de produtos/peças."
		STR0101 + chr(13) + chr(10) + chr(13) + chr(10) + ; // "Por favor, verifique a situação cadastral das mesmas!"
		cMsg , { STR0102 , STR0103 } , 3) // "Peças não encontradas" # Continuar # Cancelar
Return ( nPos <> 1 )

/*/{Protheus.doc} OFJD10ALTMANUAL
Adiciona na matriz aAtuManual os campos que serao alterados atraves de Reclock
@author Rubens
@since 07/08/2017
@version undefined
@param nRecSC7, numeric, descricao
@param cSC7Campo, characters, descricao
@param cSC7Conteudo, characters, descricao
@param lJaEntregue, logical, descricao
@type function
/*/
Static Function OFJD10ALTMANUAL( nRecSC7 , cSC7Campo , cSC7Conteudo , lJaEntregue )
	Local nPos := aScan(aAtuManual, { |x| x[1] == nRecSC7 })
	If nPos == 0
		AADD( aAtuManual , { nRecSC7 , {} , lJaEntregue })
		nPos := Len(aAtuManual)
	EndIf
	AADD( aAtuManual[nPos,2] , { cSC7Campo , cSC7Conteudo } )
Return

/*/{Protheus.doc} OFJD10SemSubLinha
Verifica o pedido esta sem informacao de sublinha do item do pedido da fabrica
@author Rubens
@since 07/08/2017
@version undefined
@param _cPedFab, caracter, descricao
@type function
/*/
Static Function OFJD10SemSubLinha(_cPedFab)
	Local cQuery

	cQuery := "SELECT COUNT(*) " + ;
		" FROM "+RetSQLName("SC7")+" SC7 " + ;
		" WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'" + ;
		  " AND SC7.C7_PEDFAB = '" + _cPedFab + "'" + ;
		  " AND SC7.C7_ITEPED <> '    ' " + ;
		  " AND SC7.C7_SLITPED = '  ' " + ;
		  " AND SC7.D_E_L_E_T_=' '"

Return (FM_SQL(cQuery) > 0)

/*/{Protheus.doc} OFJD10PedSemMovimentacao
Verifica se ja houve alguma movimentacao de importacao de NF ou Eliminacao de residuo

@author Rubens
@since 20/12/2017
@version undefined
@param _cPedFab, caracter, descricao
@type function
/*/
Static Function OFJD10PedSemMovimentacao(_cPedFab)
	Local cQuery

	cQuery := "SELECT COUNT(*) " + ;
		" FROM "+RetSQLName("SC7")+" SC7 " + ;
		" WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'" + ;
		  " AND SC7.C7_PEDFAB = '" + _cPedFab + "'" + ;
		  " AND ( SC7.C7_QUJE <> 0 OR SC7.C7_QTDACLA <> 0 ) " + ;
		  " AND SC7.D_E_L_E_T_=' '"

Return (FM_SQL(cQuery) == 0)


/*/{Protheus.doc} OFJD10ATUMANUAL
Atualiza os campos manualmente
@author Rubens
@since 07/08/2017
@version undefined
@param cPedido, characters, descricao
@type function
/*/
Static Function OFJD10ATUMANUAL( cPedido )
	Local nPos
	Local nCampo

	dbSelectArea("SC7")
	For nPos := 1 to Len(aAtuManual)

		// Se ExecAuto do MATA120 foi executado, so processa os itens ja entregues
		If lProcExecAuto .and. aAtuManual[nPos,3] == .f.
			Loop
		EndIf

		SC7->(DbGoTo( aAtuManual[ nPos , 1 ]))
		RecLock("SC7",.f.)
		For nCampo := 1 to Len(aAtuManual[nPos,2])
			&(aAtuManual[nPos,2,nCampo,1]) := aAtuManual[nPos,2,nCampo,2]
		Next nCampo
		MsUnlock()
	Next nPos
Return .t.

/*/{Protheus.doc} OFJD10SC7RECNO
Retorna o RECNO do item do pedido de compra
@author Rubens
@since 07/08/2017
@version undefined
@param _cPedFab, , descricao
@param _cIteFab, , descricao
@param _cSliptIteFab, , descricao
@type function
/*/
Static Function OFJD10SC7RECNO(_cPedFab, _cIteFab, _cSliptIteFab)

	Default _cIteFab := ""
	Default _cSliptIteFab := ""

Return FM_SQL("SELECT SC7.R_E_C_N_O_ SC7RECNO " + ;
					" FROM " + RetSqlName( "SC7" ) + " SC7 " + ;
				" WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'" +;
					" AND SC7.C7_PEDFAB = '" + _cPedFab  + "'" +;
					IIf( _cIteFab == "" , "" , " AND SC7.C7_ITEPED  = '" + _cIteFab + "'" ) + ;
					IIf( _cSliptIteFab == "" , "" , " AND SC7.C7_SLITPED = '" + _cSliptIteFab + "'" ) + ;
					" AND SC7.D_E_L_E_T_=' '" )



/*/{Protheus.doc} OFJD10WSPROC
Processa o retorno do WebService
@author Rubens
@since 07/08/2017
@version undefined
@param oWS, object, descricao
@param lImpXml, logical, descricao
@param aVetPed, array, descricao
@param cPedFab, characters, descricao
@type function
/*/
Static Function OFJD10WSPROC( oWS, lImpXml, aVetPed , cPedFab )

	Local nCont
	Local lCancel
	Local nValorTotal
	Local oOrderLine

	aPecasPed := {}
	nPosPeca := 0

	If oOktaCfg:orderStatusJDPoint()

		if oWS:oOrderStatusReturn:OWSOrderLines:OWSOrderLine == Nil
			Return aPecasPed
		Else
			oOrderLine := oWS:oOrderStatusReturn:OWSOrderLines:OWSOrderLine:oWSOrderLineBean
		Endif

	else
		oOrderLine := oWS:oOrderStatusReturn:OWSOrderLines:OWSOrderLine
	endif

	For nCont := 1 to Len(oOrderLine)

		oAuxObj := oOrderLine[nCont]

		If .F. // lImpXml //.and. lDebug
			nAuxPos := aScan(aVetPed , { |x| x[1] == cPedFab .and. ;
											x[3] == oAuxObj:clineNumber .and. ;
											x[4] == oAuxObj:csplitLineNumber } )
			If nAuxPos == 0
				Loop
			EndIf
		EndIf
		//

		cSplitLine := PadL(AllTrim(oAuxObj:csplitLineNumber),2,"0")
		If Empty(cSplitLine)
			loop
		EndIf

		lCancel := (Alltrim(UPPER(oAuxObj:cstatus)) $ "CANCELLED/CANC_STATUS")
		nValorTotal := Val( StrTran( oAuxObj:cextendedPrice , "," , "." ))

//		If nValorTotal == 0 .and. ( !lCancel .or. ( lCancel .and. Empty(cPedido)) )
		If (nValorTotal == 0 .and. !lCancel) .or. (Val(oAuxObj:cquantity) < 0)
			Loop
		EndIf

		If (nPosPeca := aScan(aPecasPed , { |x| x[PECAPED_LINENUMBER] == oAuxObj:clineNumber .and. x[PECAPED_SPLITLINE] == cSplitLine } ) ) == 0
			AADD(aPecasPed, { ;
				oAuxObj:clineNumber ,;  			// 01 - PECAPED_LINENUMBER
				oAuxObj:cpartNumber ,;  			// 02 - PECAPED_PARTNUMBER
				""  ,; 								// 03 - PECAPED_TIPOPEDIDO
				0   ,; 								// 04 - PECAPED_VALORTOTAL
				0   ,; 								// 05 - PECAPED_QUANTIDADE
				0   ,; 								// 06 - PECAPED_QUANTIDADECANCELADA
				""  ,;								// 07 - PECAPED_STATUS
				.f. ,; 								// 08 - PECAPED_LINHAPROCESSADA - Controla se o registro foi processado
				cSplitLine ,; 						// 09 - PECAPED_SPLITLINE
				Alltrim(oAuxObj:cstatus) ,; 		// 10 - PECAPED_STATUS2
				oAuxObj:clineNumber + cSplitLine,;	// 11 - PECAPED_ITEFAB
				.f. })                              // 12 - PECAPED_USADO usado jdprism
			nPosPeca := Len(aPecasPed)
		EndIf

		aPecasPed[ nPosPeca , PECAPED_TIPOPEDIDO ] := oAuxObj:ctype
		aPecasPed[ nPosPeca , PECAPED_VALORTOTAL ] += nValorTotal
		aPecasPed[ nPosPeca , PECAPED_QUANTIDADE ] += Val( oAuxObj:cquantity )
		aPecasPed[ nPosPeca , PECAPED_STATUS ] := oAuxObj:cstatus

		If lCancel
			aPecasPed[ nPosPeca , PECAPED_QUANTIDADECANCELADA ] += Val( oAuxObj:cquantity )
		EndIf

	Next nCont

	OFJD10VLRZERO(@aPecasPed)
	OFJD10AJITEPED(cPedFab, aPecasPed)

Return aPecasPed

/*/{Protheus.doc} OFJD10AJITEPED
Ajusta o item do pedido e sublinha do item do pedido de compra
@author Rubens
@since 07/08/2017
@version undefined
@param cPedFab, characters, descricao
@param aPecasPed, array, descricao
@type function
/*/
Static Function OFJD10AJITEPED(cPedFab, aPecasPed)
	Local cQuery
	Local cAliasSC7 := "TAJSC7"
	Local nPosPeca

	cQuery := "SELECT COUNT(*) " + ;
		" FROM "+RetSQLName("SC7")+" SC7 " + ;
		" WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'" + ;
		  " AND SC7.C7_PEDFAB = '" + cPedFab + "'" + ;
		  " AND SC7.C7_ITEPED = '    ' " + ;
		  " AND SC7.C7_SLITPED = '  ' " + ;
		  " AND SC7.D_E_L_E_T_=' '"

	If FM_SQL(cQuery) == 0
		Return
	EndIf

	cQuery := "SELECT SC7.R_E_C_N_O_ RECNOSC7 , SB1.B1_CODFAB" + ;
		" FROM "+RetSQLName("SC7")+" SC7 " + ;
		" JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' " +;
										  " AND SB1.B1_COD = SC7.C7_PRODUTO " +;
										  " AND SB1.D_E_L_E_T_ = ' ' " +;
		" WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'" + ;
		  " AND SC7.C7_PEDFAB = '" + cPedFab + "'" + ;
		  " AND SC7.C7_ITEPED = '    ' " + ;
		  " AND SC7.C7_SLITPED = '  ' " + ;
		  " AND SC7.D_E_L_E_T_=' '" + ;
		" ORDER BY SB1.B1_CODFAB , SC7.C7_ITEM "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSC7, .T., .T. )
	dbSelectArea("SC7")
	While !(cAliasSC7)->(Eof())

		nPosPeca := aScan( aPecasPed , { |x| ;
			AllTrim(x[ PECAPED_PARTNUMBER ]) == ALlTrim((cAliasSC7)->B1_CODFAB) .and. ;
			x[ PECAPED_LINHAPROCESSADA ] == .F. } )

		If nPosPeca <> 0

			SC7->(dbGoTo( (cAliasSC7)->RECNOSC7 ))
			RecLock("SC7",.f.)
			SC7->C7_ITEPED  := aPecasPed[nPosPeca, PECAPED_ITEFAB ]
			SC7->C7_SLITPED := aPecasPed[nPosPeca, PECAPED_SPLITLINE ]
			SC7->(MsUnlock())

			aPecasPed[ nPosPeca, PECAPED_LINHAPROCESSADA ] := .T.
		EndIf
		(cAliasSC7)->(dbSkip())
	End
	(cAliasSC7)->(dbCloseArea())
	dbSelectArea("SC7")

	aEval( aPecasPed , { |x| x[PECAPED_LINHAPROCESSADA] := .F. })

Return


/*/{Protheus.doc} OFJD10VLRZERO
Verifica se peca esta com valor unitario zerado
@author Rubens
@since 07/08/2017
@version undefined
@param aPecasPed, array, descricao
@type function
/*/
Static Function OFJD10VLRZERO(aPecasPed)

	Local nCont
	Local nPos
	Local nRecSB1
	Local nVlrUnitario := 0
	Local oSqlHlp

	For nCont := 1 to Len(aPecasPed)

		If aPecasPed[nCont, PECAPED_VALORTOTAL] <> 0
			Loop
		EndIf

		nPos := aScan( aPecasPed , { |x| ;
			x[PECAPED_PARTNUMBER] == aPecasPed[nCont,PECAPED_PARTNUMBER ] .and. ;
			x[PECAPED_VALORTOTAL] <> 0 })

		If nPos <> 0
			nVlrUnitario := aPecasPed[nPos , PECAPED_VALORTOTAL] / aPecasPed[ nPos , PECAPED_QUANTIDADE ]
			aPecasPed[ nCont , PECAPED_VALORTOTAL ] := Round(aPecasPed[ nCont, PECAPED_QUANTIDADE ] * nVlrUnitario , 2)
			Loop
		EndIf
		nVlrUnitario := 0
		If (nRecSB1 := OFJD10SB1( aPecasPed[ nCont , PECAPED_PARTNUMBER ] )) > 0
			SB1->(dbGoTo(nRecSB1))
			oSqlHlp := DMS_SqlHelper():New()

			cQuery := "SELECT SC7.C7_PRECO " +;
				 " FROM " + RetSQLName("SC7") + " SC7 " +;
				" WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "' " +;
				  " AND SC7.C7_PRODUTO = '" + SB1->B1_COD + "'" +;
				  " AND SC7.C7_PEDFAB <> ' '"
			cQuery := oSqlHlp:TOPFunc(cQuery, 1)
			nVlrUnitario := FM_SQL(cQuery)

			If nVlrUnitario == 0
				nVlrUnitario := IIf( SB1->B1_UPRC <> 0 , SB1->B1_UPRC , SB1->B1_PRV1 * .5 )
			EndIf
		EndIf

		If nVlrUnitario == 0
			nVlrUnitario := 1
		EndIf
		aPecasPed[ nCont , PECAPED_VALORTOTAL ] := Round(aPecasPed[ nCont, PECAPED_QUANTIDADE ] * nVlrUnitario , 2)

	Next nCont

Return



/*/{Protheus.doc} OFJD10ATUVAR
Atualiza variaveis que serao utilizadas durante processamento
@author Rubens
@since 07/08/2017
@version undefined
@param aPecaAtu, array, descricao
@param aPecasNaoEncontradas, array, descricao
@param aVetPed, array, descricao
@param cPedFab, characters, descricao
@type function
/*/
Static Function OFJD10ATUVAR( aPecaAtu , aPecasNaoEncontradas , aVetPed , cPedFab )

	Local nPosSB1
	Local lMostraProduto := .f.

	If (nPosSB1 := OFJD10SB1(PadR(aPecaAtu[2], nTamProduto ))) == 0

		//Conout("Produto nao encontrado - " + aPecaAtu[2] )

		If lDebug
			If OFJD10INCSB1( ;
				AllTrim(aPecaAtu[PECAPED_PARTNUMBER]) ,;
				Round( aPecaAtu[ PECAPED_VALORTOTAL ] / aPecaAtu[ PECAPED_QUANTIDADE ] , nTamC7Preco ) )

				nPosSB1 := OFJD10SB1(PadR(aPecaAtu[2], nTamProduto ))
			Else
				Return .f.
			EndIf
		Else
			lMostraProduto := .t.
			If Len(aVetPed) > 0
				lMostraProduto := (aScan(aVetPed , { |x| x[1] == cPedFab .and. ;
												x[3] == aPecaAtu[ PECAPED_LINENUMBER ]  .and. ;
												x[4] == aPecaAtu[ PECAPED_SPLITLINE ]  } ) ) <> 0
			EndIf
			If lMostraProduto
				AADD( aPecasNaoEncontradas , { aPecaAtu[2] , OJD10GTSTS( aPecaAtu[ PECAPED_STATUS ] ) } )
			EndIf
			Return .f.
		EndIf

	EndIf
	SB1->(dbGoTo(nPosSB1))
	//
	cC7Produto := SB1->B1_COD
	cC7Local   := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	cC7UM      := SB1->B1_UM
	//
	cC7StatusPed := OJD10GTSTS( aPecaAtu[ PECAPED_STATUS ] )

	nC7Quant := aPecaAtu[ PECAPED_QUANTIDADE ]
	nC7Preco := Round( aPecaAtu[ PECAPED_VALORTOTAL ] / nC7Quant , nTamC7Preco )
	nC7Total := Round( aPecaAtu[ PECAPED_VALORTOTAL ] , nTamC7Total )

Return .t.


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FS_PergImp | Autor | Thiago                | Data | 18/02/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Criacao das perguntes.								        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_PergImp()
Private aParamBox := {}

aAdd(aParamBox,{1,STR0026,Space(TamSX3("VE4_PREFAB")[1]),"@!","ON0100063_ValidacaoMarca(MV_PAR01)","VE4PED","",0,.F.})
aAdd(aParamBox,{1,STR0086,Space(TamSX3("VE4_CODFOR")[1]),"@!","","SA2",".F.",0,.F.})
aAdd(aParamBox,{1,STR0087,Space(TamSX3("VE4_LOJFOR")[1]),"@!","","",".F.",0,.F.})
aAdd(aParamBox,{1,STR0027,Space(TamSX3("E4_CODIGO")[1]),"@!","ON0100064_ValidacaoCondicaoDePagamento(MV_PAR04)","SE4","",0,.F.})
aAdd(aParamBox,{1,STR0023,Space(TamSX3("C7_PEDFAB")[1]),"@!","","","",0,.F.})
If !(ParamBox(aParamBox,"",@aRet,,,,,,,,.t.,.t.))
	Return .f.
EndIf

return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ONJDPedido | Autor | Thiago                | Data | 05/09/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Inclusao/Alteracao do pedido de compras.				        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function ONJDPedido(cAlias,nReg,nOpcX)
//nOpcX := 4

if Empty(SC7->C7_PEDFAB) .OR. ALLTRIM(SC7->C7_PEDFAB) == 'JDPRISM'
	A120Pedido(cAlias,nReg,nOpcX)
Else
	if isBlind()
		Help(,,"",,STR0024,1,0)
	else
		MsgStop(STR0024)
	endif
Endif

Return(.t.)


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ONJDRel | Autor | Thiago                | Data | 29/01/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Relatorio de pedido de compras.				        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function ONJDRel(cAlias,nReg,nOpc,cOpcao,cNumPed,lPergFilial)

Local cDesc1		:= STR0030
Local cDesc2 		:=""
Local cDesc3 		:=""
Local aParamBox   := {}
Local aRet        := {}
Local cPedNum     := ""
Private nLin := 0
Private m_Pag:= 1
Private aPag := 1
Private cBkpFilAnt := cFilAnt // salvar cFilAnt
Private nIte := 1
Private cCabec1 := STR0031
Private cCabec2 := STR0032
Private aReturn := { STR0033, 1,STR0034, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cTamanho:= "M"           		// P/M/G
Private nCaracter:=15
Private Limite  := 132          		// 80/132/220
Private cTitulo := STR0035
Private cRetorno := ""
Private cNomeRel:= "OFINJD10"
Private nLastKey:= 0

Default cOpcao  := "0"
Default cNumPed := ""
Default lPergFilial := .t.

If lPergFilial
	cFilant := FWPesqSM0("M0_CODFIL",cEmpAnt)  // Escolher a filial que deseja trabalhar

	If Empty(cFilAnt)
		cFilant := cBkpFilAnt
		Return
	EndIf
EndIf

cPedNum := SC7->C7_PEDFAB

if Empty(cNumPed)
	aAdd(aParamBox,{1,STR0023,cPedNum,"@!","","","",0,.F.})
	If !(ParamBox(aParamBox,"",@aRet,,,,,,,,.f.,.f.))
		Return .f.
	EndIf
	cRetorno := aRet[1]
Endif

cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)

If nLastKey == 27

	cFilant := cBkpFilAnt
	Return

Endif

SetDefault(aReturn,cAlias)

RptStatus( { |lEnd| ImpONJD010(@lEnd,cNomeRel,cAlias,cOpcao,cNumPed) } , cTitulo )

cFilAnt := cBkpFilAnt

If aReturn[5] == 1

	OurSpool( cNomeRel )

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpJD010ºAutor  ³Fabio               º Data ³  06/13/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpONJD010(lEnd,cNomeRel,cAlias,cOpcao,cNumPed)
Local cAliasSC7 := "SQLSC7"
Local nQtd  := 0
Local nTot  := 0
Local nTotG := 0

if cOpcao == "1"
	cPedFab := cNumPed
Else
	cPedFab := cRetorno
Endif

nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomeRel, cTamanho,nCaracter)+1

cQuery := "SELECT  SC7.C7_FILIAL,SC7.C7_PRODUTO,SC7.C7_UM,SC7.C7_QUANT,SC7.C7_PRECO,SC7.C7_TOTAL,SC7.C7_EMISSAO,SC7.C7_FORNECE,SC7.C7_LOJA,SC7.C7_COND,SC7.C7_FILENT,SC7.C7_NUM,SC7.C7_DESCRI,SC7.C7_PEDFAB "
cQuery += "FROM "
cQuery += RetSqlName( "SC7" ) + " SC7 "
cQuery += "WHERE "
cQuery += "SC7.C7_FILIAL='"+ xFilial("SC7")+ "' AND SC7.C7_PEDFAB = '"+cPedFab+"' AND "
cQuery += "SC7.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSC7, .T., .T. )


nLin++

Do While !( cAliasSC7 )->( Eof() )

	@ nLin++, 001 pSay ;
		( cAliasSC7 )->C7_FILIAL +;
		space(10-len( ( cAliasSC7 )->C7_FILIAL))+;
		substr(( cAliasSC7 )->C7_PRODUTO,1,12)+" "+;
		substr(( cAliasSC7 )->C7_DESCRI,1,15)+" "+;
		( cAliasSC7 )->C7_NUM+" "+;
		( cAliasSC7 )->C7_UM+" "+;
		transform(( cAliasSC7 )->C7_QUANT,"99999")+" "+;
		transform(( cAliasSC7 )->C7_PRECO,"@E 9999,999.99")+" "+;
		transform(( cAliasSC7 )->C7_TOTAL,"@E 9999,999.99")+" "+;
		transform(stod(( cAliasSC7 )->C7_EMISSAO),"@D")+" "+;
		( cAliasSC7 )->C7_FORNECE+" "+;
		( cAliasSC7 )->C7_LOJA+" "+;
		( cAliasSC7 )->C7_COND+"    "+;
		( cAliasSC7 )->C7_FILENT+;
		space(10-len(( cAliasSC7 )->C7_FILENT))+;
		( cAliasSC7 )->C7_PEDFAB


	nQtd  += ( cAliasSC7 )->C7_QUANT
	nTot  += ( cAliasSC7 )->C7_PRECO
	nTotG += ( cAliasSC7 )->C7_TOTAL

	dbSelectArea(cAliasSC7)
	( cAliasSC7 )->(dbSkip())

Enddo
nLin++
@ nLin++, 000 pSay Repl("-",132)
@ nLin++, 027 pSay STR0072+transform(nQtd,"99999")+" "+transform(nTot,"@E 9999,999.99")+" "+transform(nTotG,"@E 9999,999.99")
@ nLin++, 000 pSay Repl("-",132)

( cAliasSC7 )->( dbCloseArea() )


Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OJD010VLD ³ Autor ³ Thiago 							³ Data ³ 22/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do campo C7_TIPPED.						                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OJD010VLD(cFornec,cLoja)
Local lC7_TIPPED := SC7->(FieldPos("C7_TIPPED")) > 0
Local i := 0
if isBlind() .or. FUNNAME() == "OFINJD10" // estava bugando jdprism
	dbSelectArea("SA2")
	dbSetOrder(1)
	If ! dbSeek(xFilial("SA2")+cFornec+cLoja)
		FMX_HELP( "OJD010VLDSA2", STR0126 + chr(13) + chr(10) + xFilial("SA2") + "-" + cFornec + "-" + cLoja ) // "Fornecedor não encontrado."
		Return(.f.)
	EndIf
	dbSelectArea("VE4")
	dbSetOrder(2)
	if dbSeek(xFilial("VE4")+SA2->A2_CGC)
		cMarca := VE4->VE4_PREFAB
	Else
		FMX_HELP( "OJD010VLDVE4", STR0039 + chr(13) + chr(10) + xFilial("VE4") + "-" + SA2->A2_CGC ) // "Não existe registro de parâmetros da marca para o fornecedor informado! Verifique!"
		Return(.f.)
	Endif
	If lC7_TIPPED
		dbSelectArea("VEJ")
		dbSetOrder(1)
		if !dbSeek(xFilial("VEJ")+cMarca+M->C7_TIPPED)
			FMX_HELP( "OJD010VLDVEJ", STR0040 ) // "O tipo de pedido informado não foi encontrado para este fornecedor/marca na tabela de tipos de pedido! Verifique!"
			Return(.f.)
		Endif
		if type("aCols") <> "U"
			For i := 1 to Len(aCols)
				aCols[i,fg_posvar("C7_TIPPED","aHeader")] := M->C7_TIPPED
			Next
		Endif
	EndIf
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OJD010TP  ³ Autor ³ Thiago 	    		      		³ Data ³ 22/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de mais de um tipo de pedido para o pedido de compra         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OJD010TP(nLin)
Local nTIPPED := 0

if isBlind() .or. FUNNAME() == "OFINJD10" // estava bugando jdprism
	nTIPPED := fg_posvar("C7_TIPPED","aHeader")
	if Len(aCols) > 1 .And. nTIPPED > 0
		if nLin <> 1
			if !aCols[nLin-1,Len(aCols[nLin-1])] .and. !Empty(aCols[nLin-1,nTIPPED])
				if aCols[nLin-1,nTIPPED] <> M->C7_TIPPED
					if isBlind()
						Help(,,"",,STR0041,1,0)
					else
						MsgStop(STR0041)
					endif
					Return(.f.)
				Endif
			EndIf
		Else
			If !aCols[nLin+1,Len(aCols[nLin+1])] .and. !Empty(aCols[nLin+1,nTIPPED])
				if aCols[nLin+1,nTIPPED] <> M->C7_TIPPED
					if isBlind()
						Help(,,"",,STR0041,1,0)
					else
						MsgStop(STR0041)
					endif
					Return(.f.)
				Endif
			EndIf
		Endif
	Endif
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OJD10K10    ³ Autor ³ Thiago 	    	       	 	    ³ Data ³ 12/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta de peças chamada pelo F10.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OJD10K10()

if readvar() == "M->C7_PRODUTO"
	DBSelectArea("SB1")
	SB1->(DBSetOrder(1))
	SB1->(MSSeek(xFilial("SB1")+M->C7_PRODUTO))

	lRetorno := OFIXC001(SB1->B1_COD)
	M->C7_PRODUTO := SB1->B1_COD
	aCols[n,fg_posvar("C7_PRODUTO","aHeader")] := M->C7_PRODUTO
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OJD10K11    ³ Autor ³ Thiago 	    	        	    ³ Data ³ 12/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Analise do item pelo F11.										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OJD10K11()

if readvar() == "M->C7_PRODUTO"
	DBSelectArea("SB1")
	DBSetOrder(1)
	MSSeek(xFilial("SB1")+M->C7_PRODUTO)
	OFIOC520(.t.)
Endif

Return(.t.)

/*/{Protheus.doc} OJD10GTSTS
Pega o status pro sistema protheus de um status da JD
@author Vinicius Gati
@since 15/10/2015
@version undefined
@param cStatusJD, characters, descricao
@type function
/*/
Function OJD10GTSTS(cStatusJD)
	Local cStaProt
	cStatusJD := AllTrim(cStatusJD)
	Do Case
		Case cStatusJD == "ACCEPTED"    ; cStaProt := STR0042 // "Aceito"
		Case cStatusJD == "AUTOSUB"     ; cStaProt := STR0043 // "Auto Submetido"
		Case cStatusJD == "AVAILABLE"   ; cStaProt := STR0044 // "Disponível"
		Case cStatusJD == "BACKORDD"    ; cStaProt := STR0045 // "Backordered"
		Case cStatusJD == "DLRAVAIL"    ; cStaProt := STR0046 // "Disponível para Revendedor"
		Case cStatusJD == "DLRRTD"      ; cStaProt := STR0047 // "Encaminhado ao Distribuidor"
		Case cStatusJD == "EDITBLE"     ; cStaProt := STR0048 // "Editável"
		Case cStatusJD == "INVSTN"      ; cStaProt := STR0049 // "Investigação"
		Case cStatusJD == "ONHOLD"      ; cStaProt := STR0050 // "Em espera"
		Case cStatusJD == "PICKED"      ; cStaProt := STR0051 // "Separado"
		Case cStatusJD == "PRTSHP_CD"   ; cStaProt := STR0052 // "Embarcado Parcial_CD"
		Case cStatusJD == "PRTSHP_CD1"  ; cStaProt := STR0053 // "Embarcado Parcial_CD1"
		Case cStatusJD == "PRTSHP_CD2"  ; cStaProt := STR0054 // "Embarcado Parcial_CD2"
		Case cStatusJD == "PRTSHP_CD3"  ; cStaProt := STR0055 // "Embarcado Parcial_CD3"
		Case cStatusJD == "PRTSHP_CD4"  ; cStaProt := STR0056 // "Embarcado Parcial_CD4"
		Case cStatusJD == "PRTSHP_CD5"  ; cStaProt := STR0057 // "Embarcado Parcial_CD5"
		Case cStatusJD == "RLSED"       ; cStaProt := STR0058 // "Liberado"
		Case cStatusJD == "ROUTED"      ; cStaProt := STR0059 // "Encaminhado"
		Case cStatusJD == "RTD_CGI"     ; cStaProt := STR0060 // "Encaminhado p/completar"
		Case cStatusJD == "RTD_FACT"    ; cStaProt := STR0061 // "Encaminhado p/fábrica"
		Case cStatusJD == "RTD_SUPP"    ; cStaProt := STR0062 // "Encaminhado p/fornecedor"
		Case cStatusJD == "SCHEDULED"   ; cStaProt := STR0063 // "Agendado"
		Case cStatusJD == "SENT_CGI"    ; cStaProt := STR0064 // "Enviado para CGI"
		Case cStatusJD == "SENT_FACT"   ; cStaProt := STR0065 // "Enviado p/ fábrica"
		Case cStatusJD == "SENT_SUPP"   ; cStaProt := STR0066 // "Enviado p/ fornecedor"
		Case cStatusJD == "SHIPPED"     ; cStaProt := STR0067 // "Enviado"
		Case cStatusJD == "SUBMITD"     ; cStaProt := STR0068 // "Recebido"
		Case cStatusJD == "SUSPENDED"   ; cStaProt := STR0069 // "Suspenso"
		Case cStatusJD == "TOBEPICKD"   ; cStaProt := STR0070 // "Em separação"
		Case cStatusJD == "UNSUB"       ; cStaProt := STR0071 // "Não enviado"
		Case cStatusJD == "CANCELLED"   ; cStaProt := STR0091 // "Cancelado"
		Case cStatusJD == "CANC_STATUS" ; cStaProt := STR0092 // "Item Cancelado"
		Case cStatusJD == "ORDERED"     ; cStaProt := STR0117 // "Pedido"
	End Case
Return cStaProt


/*/{Protheus.doc} OFJD10SB1
Retorna o RECNO do produto a partiro do código da fabrica
@author Rubens
@since 07/08/2017
@version undefined
@param cCodFab, characters, descricao
@type function
/*/
Static Function OFJD10SB1(cCodFab)
	cSQL := "SELECT R_E_C_N_O_ " +;
		" FROM " + RetSQLName("SB1") + ;
		" WHERE B1_FILIAL = '" + xFilial("SB1") + "'" + ;
		  " AND B1_CODFAB = '" + cCodFab + "'" +;
		  " AND D_E_L_E_T_ = ' '"
Return FM_SQL(cSQL)

/*/{Protheus.doc} OFJD10DATAORDERED
Retorna a data do pedido no formato dd/mm/aaaa
@author Rubens
@since 07/08/2017
@version undefined
@param cdateOrdered, characters, descricao
@type function
/*/
Static Function OFJD10DATAORDERED(cdateOrdered)
	Local cMes := substr(cdateOrdered,3,3)
	Do Case
		Case cMes == "Jan" ; cMes := "01"
		Case cMes == "Feb" ; cMes := "02"
		Case cMes == "Mar" ; cMes := "03"
		Case cMes == "Apr" ; cMes := "04"
		Case cMes == "May" ; cMes := "05"
		Case cMes == "Jun" ; cMes := "06"
		Case cMes == "Jul" ; cMes := "07"
		Case cMes == "Aug" ; cMes := "08"
		Case cMes == "Sep" ; cMes := "09"
		Case cMes == "Oct" ; cMes := "10"
		Case cMes == "Nov" ; cMes := "11"
		Otherwise ; cMes := "12"
	End Case
	cDia := substr(cdateOrdered,1,2)
	cAno := substr(cdateOrdered,6,4)
Return ctod(cDia+"/"+cMes+"/"+cAno)


/*/{Protheus.doc} OFJD10TIPOPEDIDO
Funcao para retornar o tipo de pedido de acordo com tipo retornado pela Fabrica
@author Rubens
@since 07/08/2017
@version undefined
@param cCodMarca, characters, descricao
@param corderType, characters, descricao
@type function
/*/
Static Function OFJD10TIPOPEDIDO(cCodMarca, corderType)

	Local cTPedVX5

	cSQL := "SELECT VX5_DESCRI "
	cSQL +=  " FROM " + RetSQLName("VX5")
	cSQL += " WHERE VX5_FILIAL = '" + xFilial("VX5") + "'"
	cSQL +=   " AND VX5_CHAVE = '036' AND VX5_CODIGO = '" + AllTrim(corderType) + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	cTPedVX5 := FM_SQL(cSQL)

	cSQL := "SELECT VEJ_TIPPED "
	cSQL +=  " FROM " + RetSQLName("VEJ")
	cSQL += " WHERE VEJ_FILIAL = '" + xFilial("VEJ") + "'"
	cSQL +=   " AND VEJ_CODMAR = '" + cCodMarca + "'"
	cSQL +=   " AND VEJ_PEDEDI = '" + AllTrim(cTPedVX5) + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"

Return FM_SQL(cSQL)

/*/{Protheus.doc} OFJD10COND
Funcao para retornar condicao de pagamento pre-configurada, conforme documentacao
@author Rubens
@since 07/08/2017
@version undefined
@param clineOfCredit, characters, descricao
@type function
/*/
Static Function OFJD10COND(clineOfCredit)
	Local lE4_MSBLQL := SE4->(FieldPos("E4_MSBLQL")) > 0

	cSQL := "SELECT E4_CODIGO "
	cSQL += " FROM " + RetSQLName("SE4")
	cSQL += " WHERE E4_FILIAL = '" + xFilial("SE4") + "'"
	cSQL += "  AND E4_DESCRI = '" + AllTrim(clineOfCredit) + "'"
	cSQL += Iif(lE4_MSBLQL, "  AND E4_MSBLQL <> '1'", "")
	cSQL += "  AND D_E_L_E_T_ = ' '"
Return FM_SQL(cSQL)

/*/{Protheus.doc} OFJD10TEMPOPROC
Função para registrar o tempo de processo
@author Rubens
@since 07/08/2017
@version undefined
@param cLogMsg, characters, descricao
@type function
/*/
Static Function OFJD10TEMPOPROC(cLogMsg)
	Local cTempo
	Local cTempoDecor := "        "
	Default cLogMsg := ""
	If lDebug
		cTempo := Time()
		If Empty(cLogMsg)
			AADD( aTempoProc , { cTempo ,  } )
		Else
			nPosLog := Len(aTempoProc)
			cTempoDecor := ElapTime( aTempoProc[ nPosLog ,1] , cTempo )
			aTempoProc[nPosLog,2] := aTempoProc[ nPosLog ,1] + " - " + cTempo + " - " + cTempoDecor + " - " + cLogMsg
		EndIf
	EndIf
Return

/*/{Protheus.doc} OFJD10BARRAPROGRESSO
Atualiza barra de progresso
@author Rubens
@since 07/08/2017
@version undefined
@param cMsg, characters, descricao
@param lImpXml, logical, descricao
@type function
/*/
Static Function OFJD10BARRAPROGRESSO(cMsg, lImpXml)
If !IsBlind()
	If lImpXml
		oProcImpXML:IncRegua2( cMsg )
	Else
		IncProc( cMsg )
	EndIf
EndIf
Return

/*/{Protheus.doc} OFJD10CONOUT
Exibe mensagens durante o processamento no console do servidor
@author Rubens
@since 07/08/2017
@version undefined

@type function
/*/
Static Function OFJD10CONOUT()
	Local nCont
	If lDebug
		Conout("")
		For nCont := 1 to Len(aTempoProc)
			Conout(aTempoProc[nCont,2])
		Next nCont
		Conout("")
	EndIf
Return


/*/{Protheus.doc} OFJD10INCSB1
Funcao utilizada para criação de um registro na SB1, só pode ser utilizado em ambiente de testes
@author Rubens
@since 07/08/2017
@version undefined
@param cCodSB1, characters, descricao
@param nPrcCompra, numeric, descricao
@type function
/*/
Static Function OFJD10INCSB1(cCodSB1, nPrcCompra)

	Local lRetorno

	If ! lDebug
		Return .f.
	EndIf

	// RDMake Interno - Nao pode ser publicado no TDN ...
	If ExistBlock("ProcIncPecaJD")
		lRetorno := ExecBlock("ProcIncPecaJD",.F.,.F., { cCodSB1 } )
		Return lRetorno
	EndIf
Return .t.


/*/{Protheus.doc} OFJD10SincItPed
Funcao criada para gravar os campos de item do pedido e sub-linha do item do pedido da Fabrica
@author Rubens
@since 19/12/2017
@version undefined
@param cNrPed, characters, Numero do pedido da Fábrica
@type function
/*/
Function OFJD10SincItPed(cNrPed, lPrimeiraSincro, lTelas)

	Local nTentativas := 1
	Local nPosPedFab
	Local cQuery := ""
	Local lAtuPed := .f.
	Local oOrderLine

	Private lConsulta := .f.
	Default lTelas := !IsBlind()

	If oOktaCfg == NIL
		oOktaCfg := OFJDOktaConfig():New()
		oOktaCfg:GetConfig()
	EndIf

	If lDebug
		MsgInfo(cValToChar(oOktaCfg:orderStatusJDPoint()))
	EndIf

	While nTentativas <= 10
		If lPrimeiraSincro
			FWMsgRun(, { || Sleep( 30000 ) }, STR0018, STR0109 )  // "Aguardando processamento do Portal de Pedido de Compra da John Deere."
		EndIf

		++nTentativas
		If oOktaCfg:orderStatusJDPoint()
			oWS := WSJohnDeereJDPoint_1_4_Pedido_Compra():New()
			ows:cUserId := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
		Else
			oWS := WSJohnDeereJDPoint_Pedido_Compra():New()
		EndIf
		//oWS:SetDebug(lDebug)
		
		oWS:corderNumber   := AllTrim(cNrPed)
		oWS:caccountnumber := alltrim(GetMV("MV_MIL0005"))
		FWMsgRun(,{|| lConsulta := oWS:retrieveOrderStatus() }, STR0018, STR0017)

		If lConsulta == .f.
			Loop
		EndIf

		If oWS:oOrderStatusReturn:cexceptionReport == NIL
			oWS:ExibeErro()
			Return .f.
		EndIf

		if Upper(Alltrim(oWS:oOrderStatusReturn:cexceptionReport)) == "ORDER NOT FOUND"
			FMX_HELP("OJD010ERR002",STR0129 + IIf( ! Empty(oWS:oOrderStatusReturn:cexceptionReport) , CHR(13) + CHR(10) + "Motivo: " + oWS:oOrderStatusReturn:cexceptionReport , "" ) ) // "Não foi possível processar consulta ao WebService da John Deere."
			Return(.f.)
		Endif

		If oOktaCfg:orderStatusJDPoint()
			if oWS:oOrderStatusReturn:OWSOrderLines:OWSOrderLine == Nil
				Return .f.
			EndIf
			oOrderLine := oWS:oOrderStatusReturn:OWSOrderLines:OWSOrderLine:oWSOrderLineBean
		else
			oOrderLine := oWS:oOrderStatusReturn:OWSOrderLines:OWSOrderLine
		endif

		// O Retorno so sera processado se todas as sublinhas retornarem na consulta 
		lConsulta := .t.
		For nPosPedFab := 1 to Len(oOrderLine)
			If Empty(oOrderLine[nPosPedFab]:csplitLineNumber)
				lConsulta := .f.
				Exit
			EndIf
		Next nPosPedFab
		If lConsulta == .f.
			Loop
		EndIf
		//

		For nPosPedFab := 1 to Len(oOrderLine)

			oAuxObj := oOrderLine[nPosPedFab]
			cProduto := FM_SQL("SELECT SB1.B1_COD FROM "+RetSQLName("SB1")+" SB1 WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_CODFAB='"+oAuxObj:cpartNumber+"' AND SB1.D_E_L_E_T_=' '")

			cQuery := ;
				"SELECT SC7.R_E_C_N_O_ SC7RECNO " + ;
				 " FROM " + RetSqlName( "SC7" ) + " SC7 " + ;
				"WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'" + ;
				 " AND SC7.C7_PEDFAB  = '" + cNrPed   + "'" + ;
				 " AND SC7.C7_PRODUTO = '" + cProduto + "'" + ;
				 " AND ( SC7.C7_ITEPED  = ' ' OR SC7.C7_ITEPED = '" + oAuxObj:clineNumber + "' )" + ;
				 " AND C7_SLITPED = ' ' " + ;
				 " AND SC7.D_E_L_E_T_ = ' '" 
			nAuxRecNO := FM_SQL(cQuery)

			If nAuxRecNO <> 0
				dbSelectArea("SC7")
				dbGoTo(nAuxRecNO)
				RecLock("SC7",.f.)
				SC7->C7_ITEPED := oAuxObj:clineNumber
				SC7->C7_SLITPED := oAuxObj:csplitLineNumber
				MsUnlock()
			Endif

		Next nPosPedFab

		lAtuPed := .t.

		Exit

	End

	If lAtuPed == .f.
		if !lTelas
			conout(STR0110, STR0104)
		else
			MsgInfo(STR0110, STR0104) // "Não foi possível sincronizar o pedido de compra, tente novamente mais tarde."
		endif
	EndIf

Return lAtuPed

/*/{Protheus.doc} OFJD10AtuPed
Funcao criada para atualizar campos do Pedido de Compras
@author Manoel
@since 21/02/2018
@version undefined
@param cNroPed, characters, Numero do Pedido de Compras
@param cItePed, characters, Item do Pedido de Compras
@param nRecPed, nemerics  , Posição (Recno) do Item do Pedido de Compras
@param aCpoAlt, Array     , Array bi-dimensional com campos e respectivos conteúdos a serem gravados na SC7
      // Posição x,1 -> Nome do Campo
			// Posição x,2 -> conteúdo a ser gravado
@type function
/*/
Function OFJD10AtuPed(cNroPed, cItePed, nRecPed, aCpoAlt)

Local nCont := 0

Default cNroPed := ""
Default cItePed := ""
Default nRecPed := 0
Default aCpoAlt := {}

If nRecPed > 0 
	DbSelectArea("SC7")
	DbGoTo(nRecPed)
	RecLock("SC7",.f.)
	For nCont := 1 to Len(aCpoAlt) 
		&(aCpoAlt[nCont,1]) := aCpoAlt[nCont,2]
	Next
	MsUnlock()
Endif

Return

/*/{Protheus.doc} ON0100061_VerificacaoProdutosBloqueados
Verificação dos Produtos Bloqueados na Integração com o MATA120
@author Fernando Vitor Cavani
@since 17/12/2019
@param  aItem    - Vetor  - Produtos
@return lRetorno - Lógico - Retorno .t. / .f.
@type function
/*/
Function ON0100061_VerificacaoProdutosBloqueados(aItem,lTelas)
Local nCont     := 0
Local nAuxRecNO := 0
Local cQuery    := ""
Local aItemBlq  := {}
Local lRetorno  := .t.
Default lTelas  := !IsBlind()
Default aItem := {}

If Len(aItem) > 0
	For nCont := 1 To Len(aItem)
		cQuery := "SELECT SB1.R_E_C_N_O_ SB1RECNO "
		cQuery += "FROM " + RetSqlName( "SB1" ) + " SB1 "
		cQuery += "WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += "  AND SB1.B1_COD  = '" + aItem[nCont, 2][2]   + "' "
		cQuery += "  AND SB1.B1_MSBLQL = '1' "
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
		nAuxRecNO := FM_SQL(cQuery)

		If nAuxRecNO <> 0
			// Produtos Bloqueados
			aAdd(aItemBlq, nAuxRecNO)
		EndIf
	Next

	If Len(aItemBlq) > 0
		lRetorno := .f.
		
		if !lTelas
			Help(,,STR0021,,STR0118 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0119,1,0)
		else
			If MsgYesNo(STR0118 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0119, STR0021) // Impossível continuar! / Existe(m) Produtos(s) bloqueado(s). Deseja visualizar? / Atenção
				// Chamada da Impressão dos Produtos Bloqueados
				ON0100062_ImpressaoProdutosBloqueados(aItemBlq)
			EndIf
		endif

	EndIf
EndIf
Return lRetorno

/*/{Protheus.doc} ON0100062_ImpressaoProdutosBloqueados
Impressão dos Produtos Bloqueados na Integração com o MATA120
@author Fernando Vitor Cavani
@since 17/12/2019
@param aItemBlq - Vetor - Produtos Bloqueados
@type function
/*/
Function ON0100062_ImpressaoProdutosBloqueados(aItemBlq)
Local oReport
Private aItemImp := aItemBlq
Private cTitulo  := STR0120 // Produtos Bloqueados

oReport := ReportDef() // Nesta função nós definimos a estrutura do relatório, por exemplo as seções, campos, totalizadores e etc.
oReport:PrintDialog()  // Essa função serve para disparar a impressão do TReport, ela que faz com que seja exibida a tela de configuração de impressora e os botões de parâmetros.
Return

/*/{Protheus.doc} ReportDef
Função de montagem do padrão de impressão das informações
@author Fernando Vitor Cavani
@since 18/12/2019
@type function
/*/
Static Function ReportDef()
Local cDesc := ""
Local oReport
Local oSection

// Descrição
cDesc := STR0121 // Este programa tem como objetivo imprimir os produtos bloqueados

// TReport
oReport := TReport():New(          ;
	"OFINJD10",                    ;
	cTitulo,                       ;
	,                              ;
	{|oReport| RunReport(oReport)},;
	cDesc)

// Cabeçalho
oSection := TRSection():New(oReport, "oCabecalho", {"SB1"})

oSection:SetLinesBefore(1) // Define a quantidade de linhas que serão saltadas antes da impressão da seção
oSection:SetHeaderPage()   // Define se imprime o cabeçalho da seção no topo da página
oSection:SetHeaderBreak()  // Define se imprime o cabeçalho da seção na quebra de impressão (TRBreak)
oSection:SetPageBreak()    // Define se quebra página após a impressão do totalizador

TRCell():New(oSection, "B1_GRUPO" , "SB1", RetTitle("B1_GRUPO") , "@!", 30) // Grupo
TRCell():New(oSection, "B1_CODITE", "SB1", RetTitle("B1_CODITE"), "@!", 50) // Cod Item
TRCell():New(oSection, "B1_DESC"  , "SB1", RetTitle("B1_DESC")  , "@!", 80) // Descricao
TRCell():New(oSection, "B1_COD"   , "SB1", RetTitle("B1_COD")   , "@!", 40) // Codigo
Return(oReport)

/*/{Protheus.doc} RunReport
Função de retorno das informações do banco de dados a serem impressas
@author Fernando Vitor Cavani
@since 18/12/2019
@type function
/*/
Static Function RunReport(oReport)
Local oSection := oReport:Section(1)
Local nCntFor

// Cabeçalho
oSection:Init()

dbSelectArea("SB1")

For nCntFor := 1 to Len(aItemImp)
	SB1->(dbGoTo(aItemImp[nCntFor]))
	oSection:PrintLine()
Next

oSection:Finish()
Return

/*/{Protheus.doc} ON0100063_ValidacaoMarca
Verificação de Marca Válida
@author Fernando Vitor Cavani
@since 17/01/2020
@param cMarcaAux - Caracter - Código da Marca
@type function
/*/
Function ON0100063_ValidacaoMarca(cMarcaAux)
Default cMarcaAux := ""

DbselectArea("VE4")
DbSetOrder(1)
If !Dbseek(xFilial("VE4") + cMarcaAux)
	if isBlind()
		Help(,,"",,STR0122,1,0)
	else
		MsgStop(STR0122) // Favor informar corretamente a Marca!
	endif
	Return .f.
EndIf
Return .t.

/*/{Protheus.doc} ON0100064_ValidacaoCondicaoDePagamento
Verificação de Condição de Pagamento Válida
@author Fernando Vitor Cavani
@since 17/01/2020
@param cCondAux - Caracter - Código da Condição de Pagamento
@type function
/*/
Function ON0100064_ValidacaoCondicaoDePagamento(cCondAux)
Local lE4_MSBLQL := SE4->(FieldPos("E4_MSBLQL")) > 0

Default cCondAux := ""

DbselectArea("SE4")
DbSetOrder(1)
If !Dbseek(xFilial("SE4") + cCondAux)
	if isBlind()
		Help(,,"",,STR0123,1,0) // Favor informar corretamente a Condição de Pagamento!
	else
		MsgStop(STR0123) // Favor informar corretamente a Condição de Pagamento!
	endif
	Return .f.
Else
	If lE4_MSBLQL .And. SE4->E4_MSBLQL == "1"
		If isBlind()
			Help(,, "",, STR0124, 1, 0) // Condição de Pagamento Bloqueada para uso!
		Else
			MsgStop(STR0124) // Condição de Pagamento Bloqueada para uso!
		EndIf

		Return .f.
	EndIf
EndIf
Return .t.


Function OJD010LTOK()
	Local oOkta := OFJDOkta():New()

	If ! oOkta:oConfig:pmLinkJDPoint() .and. ! oOkta:oConfig:orderStatusJDPoint()
		MsgInfo(STR0130) // "Sistema não está configurado para utilizar a autenticação via Okta."
	EndIf

	if oOkta:oConfig:pmLinkJDPoint()
		oOkta:SetPMLinkJDPoint()
		oOkta:cleanProfile()
	endIf

	If oOkta:oConfig:orderStatusJDPoint()
		oOkta:SetOrderStatusJDPoint()
		oOkta:cleanProfile()
	endIf
	
	If oOkta:oConfig:notaFiscalCompra()
		oOkta:SetNFCompra()
		oOkta:cleanProfile()
	EndIf

	MsgInfo(STR0131) // "Token removido."

Return
