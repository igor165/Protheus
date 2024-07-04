// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º  11    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "OFINJD22.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Rubens Takahashi
    @since  25/07/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007622_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFINJD22 ³ Autor ³ Thiago 							³ Data ³ 16/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Criacao do Processo de envio e retorno de dados da Nota fiscal de      ³±±
±±³			 ³ Entrada JD para atualização do Pedido de Compras. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Auto Pecas                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFINJD22(cNumNF, cSerNF, cForn, cLoja, aVetPed, lImpXML, cCondicao, cMarca , oProcImpXML, cErr)

Local i         := 0
Local aNFItens  := {}
Local aRetWS    := {}
Local lAchou    := .t.
Local lAchouPed := .f.
// Local cAuxFunName := FunName()
Local lContinua
Local nPos
Local cUpd
Local aPecasNaoEncontradas
Local cNumPedFab := ""
Local nLenSeqNumber

Private cAliasSC7 := "SQLSC7"
Private lCriaPed  := GetNewPar("MV_MIL0125",.T.)

Default cNumNF  := ""
Default cSerNF  := ""
Default aVetPed := {}
Default lImpXML := .f.
Default cErr    := ""

Private aPedProc := {}

if Empty(cNumNF)
	// NAO deixar executar via MENU //
	if IsBlind()
		Help(,,STR0021,,STR0018,1,0)
	else
		MsgStop(STR0021,STR0018) // Esta rotina é chamada de forma interna pelo processo de recebimento de nota fiscal de entrada de peças denominado IMPXML. Desta forma, esta rotina não pode ser executada diretamente por menu de módulo! / Atencao
	endif
	Return .f.
Endif

cNumNF := PADR(cNumNF, TamSX3("F1_DOC"  )[1])
cSerNF := PADR(cSerNF, TamSX3("F1_SERIE")[1])
cForn  := PADR(cForn , TamSX3("A2_COD"  )[1])
cLoja  := PADR(cLoja , tamsx3("A2_LOJA" )[1])

// Conecta no Web Service
oWS := WSJohnDeereJDPointNF():New()
If oWS:ERRO
	Return(.f.)
EndIf
//oWS:SetDebug()
nLenSeqNumber := Len(AllTrim(Str(val(cNumNF),9)))
nLenSeqNumber := IIF( nLenSeqNumber > 6 , nLenSeqNumber , 6 )

oWS:oWSInput:cinvSequenceNumber := AllTrim(strzero(val(cNumNF),nLenSeqNumber))
oWS:oWSInput:csoldByUnitCode := "2003"
oWS:oWSInput:caccountID := alltrim(GetNewPar("MV_MIL0005",""))
lProcessado := .f.

if IsBlind()
	lProcessado := oWS:getAdvanceShipNotice()
else
	FWMsgRun(;
			,;
			{|| lProcessado := oWS:getAdvanceShipNotice() } ,;
			STR0007,;
			STR0006 + " - " + AllTrim(oWS:oWSInput:cinvSequenceNumber) )
endif

If ! lProcessado
	oWS:ExibeErro()
	Return(.f.)
EndIf

If oWS:oWSgetAdvanceShipNoticeReturn:creturnCode == "0"
	if IsBlind()
		Help(,,STR0024,,oWS:oWSgetAdvanceShipNoticeReturn:cresponseMessage,1,0)
	else
		MsgStop(STR0024 + ": "+ oWS:oWSgetAdvanceShipNoticeReturn:cresponseMessage ) // Erro
	endif
	Return(.f.)
EndIf

If Len(oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem) == 0 //nota fiscal sem itens, provavelmente não existe a NF
	if IsBlind()
		Help(,,STR0018,,STR0019 + chr(13) + chr(10) + STR0020 + cNumNF + " - " + cSerNF,1,0)
	else
		MsgStop(STR0019 + chr(13) + chr(10) + STR0020 + cNumNF + " - " + cSerNF,STR0018) // A nota fiscal não foi encontrada pelo Webservice da John Deere. Por favor, verifique!  // Número da nota fiscal e série:  // Atenção!
	endif
	Return(.f.)
EndIf

// Processa Itens da Nota Fiscal
For i := 1 to Len(oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem)

	AADD( aNFItens , {;
		oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:corderID ,; // 01 - Pedido Fabrica
		oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:cpartNumber ,; // 02 - Produto
		SubStr(oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:cMoveOrderID,11,4) ,; // 03 - Item do Pedido
		SubStr(oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:cMoveOrderID,15,2) ,; // 04 - Sublinha do Item do Pedido
		Val(oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:cquantity) }) // 05 - Quantidade

	If aScan( aPedidos , oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:corderID ) == 0
		AADD( aPedidos , oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:corderID )
	EndIf

Next i

// Quando chamada da rotina de importacao de NF
// Sincroniza todos os pedidos da Nota Fiscal
If lImpXML .or. IsBlind()
	if IsBlind()
		oProcImpXML:SetRegua2( ( Len(aPedidos) * 5 ) + 1 + 1 )
	endif

	For nPos := 1 to Len(aPedidos)

		if ! lCriaPed // se não cria pedido preciso verificar se o pedfab existe na base antes de importar
			cNumPedFab := aPedidos[nPos]
			cQuery := " SELECT COUNT(*) QTD FROM " + RetSqlName('SC7')
			cQuery += " WHERE C7_FILIAL  =  '" + xFilial("SC7") + "' AND "
			cQuery += " C7_PEDFAB  =  '" + cNumPedFab     + "' AND "
			cQuery += " D_E_L_E_T_ = ' ' "

			if IsBlind()
				ConOut( "Tentando encontrar pedido de fabrica número: " + cNumPedFab)
			endif

			if FM_SQL(cQuery) <= 0 // se nao existir na base retorna, alteracao feita para treviso
				if IsBlind()
					Help(,,STR0018,,STR0022 /* "Pedido de fábrica: " */ + cNumPedFab + STR0023,1,0)
				else
					MSGSTOP(STR0022 /* "Pedido de fábrica: " */ + cNumPedFab + STR0023) /* " não encontrado na base, talvez o pedido não esteja ainda adequado no jdprism." */
				endif
				return .f.
			endif
		endif

		if IsBlind()
			ConOut("Pré entrada no OFINJD10 com numero de itens " + cValToChar(len(aVetPed)))
		endif

		lContinua := OFJD10I( ;
			aPedidos[nPos] ,; // cPedJD
			cForn            ,; // cFornece
			cLoja            ,; // cLoja
			cCondicao        ,; // cCondicao
			cMarca           ,; // cCodMarca
			.t.              ,; // lImpXml
			aNFItens         ,; // aVetPed
			oProcImpXML 	 ,; // oProcImpXML
			@cErr)
		If lContinua == .f.
			Return(.f.)
		Endif
	Next nPos
EndIf

For nPos := 1 to Len(aNFItens)

	cPedFab       := aNFItens[nPos,1]
	cProduto      := aNFItens[nPos,2]
	cItePed       := aNFItens[nPos,3]
	cSplitItePed  := aNFItens[nPos,4]
	nQtdeNF       := aNFItens[nPos,5]
	cQuant        := Transform(nQtdeNF,"@E 99999999.99")

	lAchou        := .t.

	cUpd := " UPDATE " + RetSQLName("SC7") 
	cUpd += " SET C7_SLITPED = '01' "
	cUpd += " WHERE "
	cUpd += " C7_FILIAL  =  '" + xFilial("SC7") + "' AND "
	cUpd += " C7_PEDFAB  =  '" + cPedFab        + "' AND "
	cUpd += " C7_ITEPED  =  '" + cItePed        + "' AND "
	cUpd += " C7_SLITPED =  ' ' "
	if tcSqlExec(cUpd) < 0
		if IsBlind()
			Help(,,STR0018,,TCSQLError(),1,0)
		else
			MSGSTOP("Erro de sql detectado: " + TCSQLError())
		endif
	endif

	cQuery := "SELECT SC7.R_E_C_N_O_ SC7RECNO , SC7.C7_NUM , SC7.C7_ITEM , SC7.C7_PRODUTO, SC7.C7_PEDFAB, "
	cQuery += 	" SC7.C7_ITEPED ,SC7.C7_QUANT , SC7.C7_QUJE , SC7.C7_QTDACLA "
	cQuery +=   " , SC7.C7_SLITPED , SC7.C7_RESIDUO, SC7.C7_ENCER "
	cQuery += 	" , (SC7.C7_QUANT - SC7.C7_QUJE - SC7.C7_QTDACLA) SALDOPED "
	cQuery += " FROM " + RetSqlName( "SC7" ) + " SC7 "
	cQuery += 		" JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += 											" AND SB1.B1_COD = SC7.C7_PRODUTO "
	cQuery += 											" AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE "
	cQuery += 	" SC7.C7_FILIAL  = '" + xFilial("SC7") + "' AND "
	cQuery += 	" SC7.C7_PEDFAB  = '" + cPedFab        + "' AND "
	cQuery += 	" SC7.C7_ITEPED  = '" + cItePed        + "' AND "
	cQuery +=   " ( SC7.C7_SLITPED = '" + cSplitItePed   + "' OR SC7.C7_SLITPED = '  ' )AND "
	cQuery += 	" SC7.D_E_L_E_T_ = ' ' AND"
	cQuery += 	" SB1.B1_CODFAB = '" + cProduto + "'"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSC7, .T., .T. )
	If !( cAliasSC7 )->( Eof() )

		nPosPed := aScan(aVetPed,{|x| x[7] == ( cAliasSC7 )->SC7RECNO } )
		if nPosPed > 0
			( cAliasSC7 )->(dbSkip())
		Endif

		cNumPedC7 := ( cAliasSC7 )->C7_NUM

		nQuant := nQtdeNF // Val(oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:cquantity)

		aAdd(aVetPed,{;
			( cAliasSC7 )->C7_PEDFAB,;
			( cAliasSC7 )->C7_PRODUTO,;
			( cAliasSC7 )->C7_ITEPED,;
			( cAliasSC7 )->C7_NUM,;
			( cAliasSC7 )->C7_ITEM,;
			nQuant,;
			( cAliasSC7 )->SC7RECNO,;
			IIf( OFJD20001_PedidoComProblema() , "residuo" , "naousado" ) })

	EndIf
	(cAliasSC7)->(dbCloseArea())

Next

Return(.t.)


/*/{Protheus.doc} OFJD20001_PedidoComProblema
Retorna se o pedido esta com problema
@author Rubens
@since 08/08/2017
@version undefined

@type function
/*/
Static Function OFJD20001_PedidoComProblema()

	If Empty( ( cAliasSC7 )->C7_SLITPED) .or. ;
		( cAliasSC7 )->C7_RESIDUO == 'S' .or. ;
		( cAliasSC7 )->C7_ENCER == 'E' .or. ;
		( cAliasSC7 )->C7_QUJE <> 0 .or. ;
		( cAliasSC7 )->C7_QTDACLA <> 0
		Return .t.
	EndIf

Return .f.
