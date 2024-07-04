#include "PROTHEUS.CH"
#include "OFINJD47.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFINJD47 ³ Autor ³ Andre Luis Almeida				³ Data ³ 02/09/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualização do Pedido de Compras JD				 					  ³±±
±±³          ³ Copia do OFINJD22 porem sem utilizar o WebService. 					  ³±±
±±³			 ³ Agora utiliza somente o XML executado pelo IMPXML - Jonh Deere		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFINJD47(cNumNF, cSerNF, cForn, cLoja, aVetPed, lImpXML, cCondicao, cMarca , oProcImpXML, cErr , oXml , nPecas , lTelas )

Local aNFItens  := {}
Local lContinua
Local nPos
Local cUpd
Local cPedFab := ""
Local cNumIte := ""

Private cAliasSC7 := "SQLSC7"
Private lCriaPed  := GetNewPar("MV_MIL0125",.T.)
Private aPedProc := {}

Default cNumNF  := ""
Default cSerNF  := ""
Default aVetPed := {}
Default lImpXML := .f.
Default cErr    := ""
Default nPecas  := 0
Default lTelas  := !IsBlind() // Mostra telas 

if Empty(cNumNF)
	// NAO deixar executar via MENU //
	Help(,,STR0002,,STR0001,1,0) // Esta rotina é chamada de forma interna pelo processo de recebimento de nota fiscal de entrada de peças denominado IMPXML. Desta forma, esta rotina não pode ser executada diretamente pelo menu! / Atencao
	Return .f.
Endif

cNumNF := PADR(cNumNF, TamSX3("F1_DOC"  )[1])
cSerNF := PADR(cSerNF, TamSX3("F1_SERIE")[1])
cForn  := PADR(cForn , TamSX3("A2_COD"  )[1])
cLoja  := PADR(cLoja , tamsx3("A2_LOJA" )[1])

If nPecas == 0 //nota fiscal sem itens, provavelmente não existe a NF
	Help(,,STR0001,,STR0003 + chr(13) + chr(10) + STR0004 + cNumNF + " - " + cSerNF,1,0) // Atenção / Nota fiscal não encontrada. Por favor, verifique! / NF:
	Return(.f.)
EndIf

aPedidos := {}

If nPecas == 1
	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
	oXmlDetHlp := Mil_XmlHelper():New(oDet)
	cPedFab := oXmlDetHlp:GetValue('_PROD:_XPED:Text')
	cNumIte := oXmlDetHlp:GetValue('_PROD:_NITEMPED:Text')
	AADD( aNFItens , {	cPedFab ,; // 01 - Pedido Fabrica
						oXmlDetHlp:GetValue('_PROD:_CPROD:Text') ,; // 02 - Produto
						left(cNumIte,4) ,; // 03 - Item do Pedido
						right(cNumIte,2) ,; // 04 - Sublinha do Item do Pedido
						Val( oXmlDetHlp:GetValue('_PROD:_QCOM:Text'  , '0') ) }) // 05 - Quantidade
	If aScan( aPedidos , cPedFab ) == 0
		AADD( aPedidos , cPedFab )
	EndIf
Else
	for nPos := 1 to nPecas
		oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET[nPos]
		oXmlDetHlp := Mil_XmlHelper():New(oDet)
		cPedFab := oXmlDetHlp:GetValue('_PROD:_XPED:Text')
		cNumIte := oXmlDetHlp:GetValue('_PROD:_NITEMPED:Text')
		AADD( aNFItens , {	cPedFab ,; // 01 - Pedido Fabrica
							oXmlDetHlp:GetValue('_PROD:_CPROD:Text') ,; // 02 - Produto
							left(cNumIte,4) ,; // 03 - Item do Pedido
							right(cNumIte,2) ,; // 04 - Sublinha do Item do Pedido
							Val( oXmlDetHlp:GetValue('_PROD:_QCOM:Text'  , '0') ) }) // 05 - Quantidade
		If aScan( aPedidos , cPedFab ) == 0
			AADD( aPedidos , cPedFab )
		EndIf
	next
EndIf

// Quando chamada da rotina de importacao de NF
// Sincroniza todos os pedidos da Nota Fiscal
If lImpXML .or. !lTelas
	if lTelas
		oProcImpXML:SetRegua2( ( Len(aPedidos) * 5 ) + 1 + 1 )
	endif

	For nPos := 1 to Len(aPedidos)

		if ! lCriaPed // se não cria pedido preciso verificar se o pedfab existe na base antes de importar
			cPedFab := aPedidos[nPos]
			cQuery := " SELECT COUNT(*) QTD FROM " + RetSqlName('SC7')
			cQuery += " WHERE C7_FILIAL  =  '" + xFilial("SC7") + "' AND "
			cQuery += " C7_PEDFAB  =  '" + cPedFab     + "' AND "
			cQuery += " D_E_L_E_T_ = ' ' "

			if !lTelas
				ConOut( STR0005 + cPedFab) // Tentando encontrar pedido de fabrica número:
			endif

			if FM_SQL(cQuery) <= 0 // se nao existir na base retorna, alteracao feita para treviso
				Help(,,STR0001,,cPedFab+" - "+STR0006,1,0) // Atenção / Pedido de Fábrica não encontrado, talvez o pedido não esteja ainda adequado no JDPRISM.
				return .f.
			endif
		endif

		if !lTelas
			ConOut(STR0007 + cValToChar(len(aVetPed))) // Pré entrada no OFINJD10 com numero de itens
		endif

		lContinua := OFJD10I(	aPedidos[nPos] ,; // cPedJD
								cForn            ,; // cFornece
								cLoja            ,; // cLoja
								cCondicao        ,; // cCondicao
								cMarca           ,; // cCodMarca
								lImpXML          ,; // lImpXml
								aNFItens         ,; // aVetPed
								oProcImpXML 	 ,; // oProcImpXML
								@cErr            ,;
								lTelas )
		If lContinua == .f.
			Return(.f.)
		Endif
	Next
EndIf

For nPos := 1 to Len(aNFItens)

	cPedFab       := aNFItens[nPos,1]
	cProduto      := aNFItens[nPos,2]
	cItePed       := aNFItens[nPos,3]
	cSplitItePed  := aNFItens[nPos,4]
	nQtdeNF       := aNFItens[nPos,5]

	cUpd := " UPDATE " + RetSQLName("SC7") 
	cUpd += " SET C7_SLITPED = '01' "
	cUpd += " WHERE "
	cUpd += " C7_FILIAL  =  '" + xFilial("SC7") + "' AND "
	cUpd += " C7_PEDFAB  =  '" + cPedFab        + "' AND "
	cUpd += " C7_ITEPED  =  '" + cItePed        + "' AND "
	cUpd += " C7_SLITPED =  ' ' "
	if tcSqlExec(cUpd) < 0
		Help(,,STR0001,,TCSQLError(),1,0) // Atenção
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
			aAdd(aVetPed,{	( cAliasSC7 )->C7_PEDFAB,;
							( cAliasSC7 )->C7_PRODUTO,;
							( cAliasSC7 )->C7_ITEPED,;
							( cAliasSC7 )->C7_NUM,;
							( cAliasSC7 )->C7_ITEM,;
							nQtdeNF,;
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