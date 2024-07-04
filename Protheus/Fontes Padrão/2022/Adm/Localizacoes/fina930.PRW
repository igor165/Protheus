#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA930.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINA930    ³ Autor ³Wellington A Santos    ³ Data ³ 18/11/09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que avalia a gravacao do imposto ITF anual ( Peru ) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Localizacao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Fina930()
// MV_PAR01 = Data inicial
// MV_PAR02 = Data final
// MV_PAR03 = Percentual base determinante para gravar o titulo, ou nao
// MV_PAR04 = Vencimento para o titulo que sera gerado
// MV_PAR05 = Fornecedor sugerido para gerar o título a pagar
// MV_PAR06 = Loja do Fornecedor sugerido para gerar o título a pagar
// MV_PAR07 = Prefixo do titulo
// MV_PAR08 = Numero do titulo
// MV_PAR09 = Tipo do titulo
// MV_PAR10 = Natureza
// MV_PAR11 = percentual de multa aplicada como base para compor o valor do título a ser gerado

If Pergunte("FINA930",.T.)
	Processa({|| GravaTit() },STR0001,(STR0002),.F.) //"Apuracao Anual de ITF "  " Processando ..."
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaTit   ³ Autor ³Wellington A Santos    ³ Data ³ 18/11/09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaTit()
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local nValcart  := 0
Local nValMov   := 0
Local nValPag   := 0
Local aSE2      := {}
Local cUniao    := SuperGetMV("MV_UNIAO")
Local cNaturez  := SuperGetMv("MV_NATITF",.F.,"")
Local cLojaFor  := Padr( "00", Len( SE2->E2_LOJA ) )
Local nPerc     := 0
Local cCalcITF  := SuperGetMv("MV_CALCITF",.F.,"2")

SED->( DbSetOrder(1) )
If cPaisLoc == "PER" .And. AllTrim(cCalcITF) == "1" .And. !Empty(cNaturez) ;
		.And. SED->( MsSeek( xFilial("SED") + cNaturez ) )  .And. ;
	cPaisLoc == "PER"

	cQuery := " SELECT SUM(E5_VALOR) VAL_CART FROM " + RetSqlName("SE5")  + " SE5 "
	cQuery += " JOIN " + RetSqlName("SED") + " SED ON "
	cQuery += " ED_FILIAL          = '" + xFilial("SED") + "' "
	cQuery += " AND ED_CODIGO      = E5_NATUREZ "
	cQuery += " AND ED_CALCITF     = '1' " //verifico aqui somente as naturezas que controlam ITF
	cQuery += " AND SED.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE E5_FILIAL    = '" + xFilial("SE5") + "' "
	cQuery += " AND E5_RECPAG      = 'P' "
	cQuery += " AND E5_MOTBX = 'CEC' "
	cQuery += " AND SE5.D_E_L_E_T_ = ' ' "
	cQuery += " AND E5_DATA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	nValCart := (cAliasQry)->VAL_CART

	(cAliasQry)->( DbCloseArea() )

	cQuery := " SELECT SUM(E2_VLCRUZ) VAL_MOV FROM " + RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
	cQuery += " AND E2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	nValMov := (cAliasQry)->VAL_MOV

	(cAliasQry)->( DbCloseArea() )

	nPerc := ( nValCart * 100 ) / nValMov
	If nPerc > MV_PAR03

		cHistorico := STR0003
		nValPag    := nValCart * ( mv_par11 / 100 )

		aSE2 := {}
		If !Empty(MV_PAR05)
			cUniao := MV_PAR05
		EndIf
		If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
			cLojaFor := MV_PAR06
		EndIf
		If !Empty(MV_PAR10)
			cNaturez := MV_PAR10
		EndIf
		cQuery := " SELECT E2_NUM FROM " + RetSqlName("SE2") + " SE2 "
		cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
		cQuery += " AND E2_TIPO    = '" + MV_PAR09 + "' "
		cQuery += " AND E2_NATUREZ = '" + cNaturez + "' "
		cQuery += " AND SUBSTRING(E2_VENCTO,1,6) = '" + AllTrim(Str(Year(MV_PAR04))) + AllTrim(StrZero(Month(MV_PAR04),2 )) + "' "
		cQuery += " AND E2_FORNECE = '" + padr(cUniao,TamSX3("A2_COD")[1])   + "' "
		cQuery += " AND E2_LOJA    = '" + cLojaFor + "' "
		cQuery += " AND SE2.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->( Eof() )

			SA2->( DbSetOrder(1) )
			If SA2->( MsSeek(xFilial("SA2") + padr(cUniao,TamSX3("A2_COD")[1]) + cLojaFor ) )

				aSE2	:=	{	{ "E2_FILIAL"	, xFilial("SE2")											   , Nil },;
									{ "E2_PREFIXO"	, MV_PAR07                                      , Nil },;
									{ "E2_NUM"		, MV_PAR08													, Nil },;
									{ "E2_TIPO"		, MV_PAR09													, Nil },;
									{ "E2_NATUREZ"	, cNaturez													, Nil },;
									{ "E2_PORTADO"	, SA2->A2_BANCO				   						, Nil },;
									{ "E2_FORNECE"	, padr(cUniao,TamSX3("A2_COD")[1])							, Nil },;
									{ "E2_LOJA"   	, cLojaFor													, Nil },;
									{ "E2_NOMFOR"	, SA2->A2_NREDUZ 											, Nil },;
									{ "E2_EMISSAO"	, dDatabase													, Nil },;
									{ "E2_VENCTO"	, MV_PAR04	   											, Nil },;
									{ "E2_VENCORI"	, MV_PAR04					   							, Nil },;
									{ "E2_VENCREA"	, DataValida(MV_PAR04)  								, Nil },;
									{ "E2_VALOR"  	, nValPag   												, Nil },;
									{ "E2_SALDO"  	, nValPag   												, Nil },;
									{ "E2_BCOPAG" 	, SA2->A2_BANCO					     					, Nil },;
									{ "E2_EMIS1"  	, dDataBase													, Nil },;
									{ "E2_MOEDA"	, 1	                                          , Nil },;
									{ "E2_VLCRUZ" 	, nValPag                                    	, Nil },;
									{ "E2_HIST"   	, cHistorico												, Nil },;
									{ "E2_PARCELA"	, StrZero(1, Len(SE2->E2_PARCELA))	 			   , Nil },;
									{ "E2_ORIGEM" 	, FunName()											  		, Nil }	}

				lMsErroAuto := .F.
				MsExecAuto({ | a,b,c | Fina050(a,b,c) },aSe2,,3)
				If lMsErroAuto
					Help(" ", 1, "ERROGERACP")
				Endif
		   Else
		   	Help("",1,"FINA930001")//fornecedor nao existe
			EndIf
		Else
			Help("",1,"FINA930002")//ja existe titulo de pagamento de ITF para este período
		EndIf
		(cAliasQry)->( DbCloseArea() )
	EndIf
Else
	Help("",1,"FINA930003")//sistema nao esta configurado para utilizar ITF

EndIf


Return
