#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJC080.CH"

#DEFINE P_SINAL			1
#DEFINE P_FILIAL		2
#DEFINE P_DESCFIL		3
#DEFINE P_EMISSAO		4	  	
#DEFINE P_UNIDADES		5
#DEFINE P_VALTOT 		6
#DEFINE P_VALDESC		7
#DEFINE P_PERDESC		8
#DEFINE P_VALLIQ		9
#DEFINE P_CUSTO			10
#DEFINE P_LUCRO			11
#DEFINE P_PERLUCRO		12

#DEFINE P_BRANCO		" "		// Branco
#DEFINE P_ABERTO		"-"		// Visualizacao analitica
#DEFINE P_FECHADO		"+"		// Visualizacao sintehtica

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LOJC080	³ Autor ³ Vendas Clientes       ³ Data ³ 13/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Financeira                     					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LOJC080()									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LOJC080()
Local cFunction    := "LOJC080"                            	//Funcao a ser executada
Local cPerg        := "LJC080"  							//Perguntas relacionadas ao CRDA030
Local cTitle       := STR0001								//Titulo da tela
Local cDescription := STR0001								//Decricao da rotina
Local bProcess     := { |ExpO1| LJ080Processa( ExpO1 ) }	//Processo a ser executado	
Local aInfoCustom  := {} 					
Local lCancel	   := .F.                  					//Verifica se a processa foi cancelada
Local lR1_1		   := GetRPORelease() >= "R1.1" // Verifica se o Release e superior ao R1.1  do Protheus 10
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_PAR01 De Filial ?         ³
//³ MV_PAR02 Ate Filial ?		 ³
//³ MV_PAR03 De Emissao ?        ³
//³ MV_PAR04 Ate Emissao ?   	 ³
//³ MV_PAR05 Agrega Unidades ?   ³
//³ MV_PAR06 Apurar Custo ?      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lR1_1
	tNewProcess():New(cFunction,cTitle,bProcess,cDescription,cPerg,aInfoCustom )
Else
	If !Pergunte( "LJC080", .T. )
		Return( NIL )                    
	Endif	
	Processa( { |ExpO1| LJ080Processa( @ExpO1, @lCancel ) }, , , .T. )
	If lCancel
		Return( NIL )
	Endif
EndIf

Return .T.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ080Processa ³ Autor ³ Vendas Clientes  ³ Data ³ 11/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca os dados que serao apresentados nos listbox de Vendas³±±
±±³          ³ e devolucoes.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto referente a tela de processamento           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ080Processa( ExpO1, lCancel )
Local aDevol	 := {}
Local aVendas	 := {}
Local aLojas	 := {}
Local nCusto	 := 0							// Custo do produto
Local nPos       := 0
Local cFilialSB1 := ""							// Filial do cadastro de produtos
Local cFilialSB2 := ""							// Filial da tabela de estoque/custo de produtos
Local cLoja		 := ""							// Codigo da loja nao encontrada
Local lQuery	 := .F.							// Informa se utiliza query
Local lR1_1		 := GetRPORelease() >= "R1.1" // Verifica se o Release e superior ao R1.1  do Protheus 10
Local lSB2Excl   := .F.                         // Verifica o modo de compartilhamento da Tabela de Estoque

#IFDEF TOP
Local cQuery     := ""		// Query para TopConnect
#Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica no SX2 o modo dos arquivos envolvidos na operacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lSB2Excl := If(FWModeAccess("SB2",3)== "E", .T., .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

SL2->( dbSetOrder( 1 ) )
SG1->( dbSetOrder( 1 ) )
SB1->( dbSetOrder( 1 ) )
SLJ->( dbSetOrder( 3 ) )

If lR1_1
	ExpO1:SetRegua1(5)
	ExpO1:IncRegua1(STR0027)		//"Consulta Financeira"
	ExpO1:SetRegua2(5)
	ExpO1:IncRegua2(STR0028)		//"Selecionando dados para a consulta"
EndIf
// Dependendo da base de dados utiliza um loop de selecao
#IFDEF TOP                            
	If TcSrvType() != "AS/400"                        
		lQuery := .T.
		ProcRegua( SL2->( LastRec() ) )

		cQuery := "SELECT SL2.L2_NUM, SL2.L2_PRODUTO, SL2.L2_QUANT, SL2.L2_STATUS, SL2.L2_VLRITEM, SL2.L2_DESCPRO,"
		cQuery += " SL2.L2_VALDESC, SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_CUSTD, SB1.B1_UPRC, SL1.L1_FILIAL, SL1.L1_EMISSAO,"
		cQuery += " SL1.L1_DOC, SL1.L1_NUM, SB2.B2_FILIAL, SB2.B2_COD, SB2.B2_LOCAL, SB2.B2_CM1"
		cQuery += " FROM " + RetSqlName( "SL1" ) + " SL1, " + RetSqlName( "SL2" ) + " SL2, " 
		cQuery += RetSqlName( "SB1" ) + " SB1, " + RetSqlName( "SB2" ) + " SB2"
		cQuery += " WHERE SL1.L1_FILIAL between '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
		cQuery += " AND SL1.L1_EMISSAO between '" + DtoS( MV_PAR03 ) + "' AND '" + DtoS( MV_PAR04 ) + "'"
		cQuery += " AND SL1.L1_DOC <> ''"
		cQuery += " AND SL1.D_E_L_E_T_ = ' '"
		cQuery += " AND SL2.L2_FILIAL = SL1.L1_FILIAL"
		cQuery += " AND SL2.L2_NUM = SL1.L1_NUM"
		cQuery += " AND SL2.D_E_L_E_T_ = ' '"
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial( "SB1" ) + "'"
		cQuery += " AND SB1.B1_COD = SL2.L2_PRODUTO"
		cQuery += " AND SB1.D_E_L_E_T_ = ' '"
        
		If lSB2Excl
			cQuery += " AND SB2.B2_FILIAL = SL1.L1_FILIAL "
		EndIf

		cQuery += " AND SB2.B2_COD = SL2.L2_PRODUTO"
		cQuery += " AND SB2.B2_LOCAL = SL2.L2_LOCAL"
		cQuery += " AND SB2.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery( cQuery )           
		CursorWait()
		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'LOJC080', .F., .T.)
		CursorArrow()
		TCSetField( 'LOJC080', 'L1_EMISSAO', 'D' )
    
		While LOJC080->( ! EoF() )
			If !lR1_1
				IncProc()
				If ExpO1
					Exit
				Endif
			EndIf
			// Busca o custo de acordo com o selecionado no pergunte.
			If MV_PAR06 == 1			// Custo Standard
				nCusto := LOJC080->( RetFldProd(LOJC080->B1_COD,"B1_CUSTD","LOJC080") * L2_QUANT )  		
			ElseIf MV_PAR06 == 2		// Ultimo preco de compra
				nCusto := LOJC080->( RetFldProd(LOJC080->B1_COD,"B1_UPRC","LOJC080") * L2_QUANT )
			Else						// Custo Medio
				nCusto := LOJC080->B2_CM1 * LOJC080->L2_QUANT 
			Endif

			LOJC080->( LJ080Itens( aVendas, nCusto, MV_PAR05, L1_FILIAL, L1_EMISSAO, L2_VLRITEM, ( L2_DESCPRO + L2_VALDESC ), L2_QUANT ) )

			// Se agrega unidades por vendas
			If MV_PAR05 == 3 
				nPos := aScan( aVendas, { |x| LOJC080->( x[P_FILIAL] == L1_FILIAL .and. x[P_EMISSAO] == L1_EMISSAO ) } )
				aVendas[ nPos, 5 ] ++
			Endif

			// Busca o nome das lojas para montar os listbox de Vendas e Devolucoes
			nPos := aScan( aLojas, { |x| x[1] == LOJC080->L1_FILIAL } )
			If nPos == 0
				If SLJ->( DBSeek( xFilial( "SLJ" ) + SM0->M0_CODIGO + LOJC080->L1_FILIAL ) )
					AAdd( aLojas, { LOJC080->L1_FILIAL, SLJ->LJ_NOME } )
				Else
				    AAdd( aLojas, { LOJC080->L1_FILIAL, "" } )	// Loja nao encontrada no cadastro de Identificacao de Lojas	    
				    cLoja := LOJC080->L1_FILIAL
				Endif
			Endif			
	    
			LOJC080->( dbSkip() )
		End
	Endif		

	LOJC080->( dbCloseArea() )

	dbSelectArea("SL1")
#Endif		

If !lQuery
	ProcRegua( SL1->( LastRec() ) )

	SL1->( dbSetOrder( 4 ) )
	SL1->( dbSeek( MV_PAR01 + DtoS( MV_PAR03 ), .T. ) )

	While SL1->( ! EoF() .and. L1_FILIAL <= MV_PAR02 .and. DtoS( L1_EMISSAO ) <= DtoS( MV_PAR04 ) )
		If !lR1_1
			IncProc()
			If ExpO1
				Exit
			Endif
		EndIf
		If Empty( SL1->L1_DOC )
			SL1->( dbSkip() )
			Loop
		Endif    

		If SL1->L1_EMISSAO < MV_PAR03
			SL1->( dbSkip() )
			Loop
		Endif	

		cFilialSB1 := xFilial( "SB1" )
		cFilialSB2 := xFilial( "SB2" )
	
		SL2->( dbSeek( SL1->( L1_FILIAL + L1_NUM ) ) )

		While SL2->( ! EoF() .and. L2_FILIAL == SL1->L1_FILIAL .and. L2_NUM == SL1->L1_NUM )
			// Busca custo do produto
			SB1->( dbSeek( cFilialSB1 + SL2->L2_PRODUTO ) )

			// Busca o custo de acordo com o selecionado no pergunte.
			If MV_PAR06 == 1		// Custo Standard
				nCusto := ( RetFldProd(SB1->B1_COD,"B1_CUSTD") * SL2->L2_QUANT )  		
			ElseIf MV_PAR06 == 2		// Ultimo preco de compra
				nCusto := ( RetFldProd(SB1->B1_COD,"B1_UPRC") * SL2->L2_QUANT )
			Else		// Custo Medio
				SB2->( dbSeek( cFilialSB2 + SL2->( L2_PRODUTO + L2_LOCAL ) ) )
				nCusto := SB2->B2_CM1
			Endif

			LJ080Itens( aVendas, nCusto, MV_PAR05, SL2->L2_FILIAL, SL2->L2_EMISSAO, SL2->L2_VLRITEM,;
						SL2->( L2_DESCPRO + L2_VALDESC ), SL2->L2_QUANT )

			SL2->( dbSkip() )
		End    

		// Se agrega unidades por vendas
		If MV_PAR05 == 3 
			nPos := aScan( aVendas, { |x| SL1->( x[P_FILIAL] == L1_FILIAL .and. x[P_EMISSAO] == L1_EMISSAO ) } )
			aVendas[ nPos, 5 ] ++
		Endif

		// Busca o nome das lojas para montar os listbox de Vendas e Devolucoes
		nPos := aScan( aLojas, { |x| x[1] == SL1->L1_FILIAL } )
		If nPos == 0
			If SLJ->( DBSeek( xFilial( "SLJ" ) + SM0->M0_CODIGO + SL1->L1_FILIAL ) )
				AAdd( aLojas, { SL1->L1_FILIAL, SLJ->LJ_NOME } )
			Else
			    AAdd( aLojas, { SL1->L1_FILIAL, "" } )	// Loja nao encontrada no cadastro de Identificacao de Lojas
			    cLoja := SL1->L1_FILIAL
			Endif
		Endif			

		SL1->( dbSkip() )
	End
Endif

If lR1_1
	ExpO1:IncRegua1(STR0027)		//"Consulta Financeira"
	ExpO1:IncRegua2(STR0029)		//"Fim da seleção dos dados"	
	Sleep(2000)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento das devolucoes                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lR1_1
	ProcRegua( SD1->( LastRec() ) )
EndIf

SD1->(dbSetOrder( 3 )) // D1_FILIAL+D1_EMISSAO+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA

If Empty(MV_PAR01)
	SD1->(DbGoTop())
	cFilSD1 := SD1->D1_FILIAL
Else
	cFilSD1 := xFilial("SD1", MV_PAR01)
EndIf

SD1->(DbSeek( cFilSD1 + DtoS( MV_PAR03 ), .T. ))

If lR1_1
	ExpO1:IncRegua1(STR0027)		//"Consulta Financeira"
	ExpO1:IncRegua2(STR0030)		//"Efetuando tratamento das devoluções"	
	Sleep(2000)
EndIf

While SD1->( !EoF() .And. D1_FILIAL <= MV_PAR02 .And. DtoS(D1_EMISSAO) <= DtoS(MV_PAR04) )
	
	If !lR1_1
		IncProc()
		If ExpO1
			Exit
		Endif
	EndIf
	
	If SD1->D1_TIPO <> "D"
		SD1->( dbSkip() )
		Loop
	Endif    

	cFilialSB1 := xFilial( "SB1" )
	cFilialSB2 := xFilial( "SB2" )

	// Busca custo do produto
	SB1->( dbSeek( cFilialSB1 + SD1->D1_DOC ) )

	// Busca o custo de acordo com o selecionado no pergunte.
	If MV_PAR06 == 1		// Custo Standard
		nCusto := ( RetFldProd(SB1->B1_COD,"B1_CUSTD") * SD1->D1_QUANT )
	ElseIf MV_PAR06 == 2		// Ultimo preco de compra
		nCusto := ( RetFldProd(SB1->B1_COD,"B1_UPRC") * SD1->D1_QUANT )
	Else		// Custo Medio
		SB2->( dbSeek( cFilialSB2 + SD1->( D1_COD + D1_LOCAL ) ) )
		nCusto := SB2->B2_CM1
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aqui neste ponto deve ser abatido o valor do desconto pois o SD1 nao ³
	//³ contem o valor liquido da devolucao                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LJ080Itens( aDevol, nCusto, MV_PAR05, SD1->D1_FILIAL, SD1->D1_EMISSAO, ( SD1->D1_TOTAL - SD1->D1_VALDESC ),;
			    SD1->( D1_DESC * D1_TOTAL ) / 100, SD1->D1_QUANT )

	// Se agrega unidades por vendas
	If MV_PAR05 == 3
		nPos := aScan( aDevol, { |x| SD1->( x[P_FILIAL] == D1_FILIAL .and. x[P_EMISSAO] == D1_EMISSAO ) } )
		aDevol[ nPos, 5 ] ++
	Endif

	// Busca o nome das lojas para montar os listbox de Vendas e Devolucoes
	nPos := aScan( aLojas, { |x| x[1] == SD1->D1_FILIAL } )
	If nPos == 0
		If SLJ->( DBSeek( xFilial( "SLJ" ) + SM0->M0_CODIGO + SD1->D1_FILIAL ) )
			AAdd( aLojas, { SD1->D1_FILIAL, SLJ->LJ_NOME } )
		Else
		    AAdd( aLojas, { SD1->D1_FILIAL, "" } )	// Loja nao encontrada no cadastro de Identificacao de Lojas
		    cLoja := SD1->D1_FILIAL
		Endif
	Endif			

	SD1->( dbSkip() )
End

If lR1_1
	ExpO1:IncRegua1(STR0027)		//"Consulta Financeira"
	ExpO1:IncRegua2(STR0031)		//"Fim do tratamento das devoluções"	
	Sleep(2000)
EndIf

// Se nao cancelou exibe mensagem da loja faltante no cadastro de identificacao de lojas.
If aScan( aLojas, { |x| x[2] == "" } ) <> 0
	MsgInfo( STR0023 + STR0024 + CRLF +;
			 STR0025 + cLoja )
Endif

SL1->( dbSetOrder( 1 ) )
SLJ->( dbSetOrder( 1 ) )

If lR1_1
	// Identifica se o processamento foi cancelado para nao abrir o dialogo           
	ExpO1:IncRegua1(STR0027)		//"Consulta Financeira"
	ExpO1:IncRegua2(STR0032)		//"Fim do processamento"	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a tela contendo as consultas financeiras³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LJ080Tela( aVendas, aDevol, aLojas )

If !lR1_1
	lCancel := ExpO1 
EndIf

Return NIL  
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJ080Tela	   ³ Autor ³ Vendas Clientes    ³ Data ³ 20/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela contendo os dados da consulta financeira              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com o as linhas sintehticas ou analiticas.   ³±±
±±³          ³ ExpA2 = Array                                              ³±±
±±³          ³ ExpA3 = Array                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJC080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ080Tela( aVendas, aDevol, aLojas )
Local oDlg
Local oFnt
Local oVendas
Local oDevol
Local oGroup
Local oFnt2
Local cTitUnidDev
Local cTitUnid
Local aTotDevol	 := {}
Local aTotVendas := {}
Local cTitLoja

// Define titulo da coluna "Unidades" de acordo com o parametro MV_PAR05
If MV_PAR05 == 1
	cTitUnid 	:= STR0005 		// Itens		
	cTitUnidDev	:= cTitUnid 	
ElseIf MV_PAR05 == 2	
	cTitUnid 	:= STR0020		// Quantidades
	cTitUnidDev := cTitUnid
Else					
	cTitUnid    := STR0021		// Vendas
	cTitUnidDev := STR0022		// Devolucoes
Endif

// Ordena por Filial e Data de Emissao
aSort( aVendas,,, {|x,y| x[P_FILIAL] + DtoS( x[P_EMISSAO] ) < y[P_FILIAL] + DtoS( y[P_EMISSAO] ) } )
aSort( aDevol ,,, {|x,y| x[P_FILIAL] + DtoS( x[P_EMISSAO] ) < y[P_FILIAL] + DtoS( y[P_EMISSAO] ) } )

// Gera vetores totalizados para montar os listbox de vendas e devolucoes
LJ080Total( aVendas, @aTotVendas, aLojas )
LJ080Total( aDevol , @aTotDevol, aLojas )

// Formata algumas colunas os vetores totalizados
LJ080FormaCol( aVendas, .T. )
LJ080FormaCol( aTotVendas, .F. )

LJ080FormaCol( aDevol, .T. )
LJ080FormaCol( aTotDevol, .F. )

// Define o titulo da coluna loja, se for exibir o codigo entao o titulo fica 
// como Filial, se for exibir a descricao entao o titulo fica Loja
If aScan( aLojas, { |x| x[2] == "" } ) <> 0
	cTitLoja := STR0026
Else
	cTitLoja := STR0003	
Endif
                                     
// Cria dialogo
DEFINE FONT oFnt NAME "Courier New"
DEFINE FONT oFnt2	NAME "Arial" BOLD

DEFINE MSDIALOG oDlg FROM 0.1,0.1 TO 400,630 ;
TITLE STR0001 PIXEL OF oMainWnd   // Consulta Financeira Consolidada

// Mostra parametros escolhidos para selecao
@ 003, 003 GROUP oGroup TO 032, 255 LABEL STR0014 OF oDlg PIXEL		// Parâmetros
oGroup:SetFont(oFnt2) 
                                 
@ 012, 009 SAY STR0015 SIZE 60, 10 OF oDlg PIXEL		// Loja De
@ 012, 035 SAY MV_PAR01 OF oDlg PIXEL

@ 022, 009 SAY STR0016 SIZE 60, 10 OF oDlg PIXEL		// Loja Ate
@ 022, 035 SAY MV_PAR02 OF oDlg PIXEL

@ 012, 115 SAY STR0017 SIZE 60, 10 OF oDlg PIXEL		// Data De
@ 012, 145 SAY MV_PAR03 OF oDlg PIXEL

@ 022, 115 SAY STR0018 SIZE 60, 10 OF oDlg PIXEL		// Data Ate
@ 022, 145 SAY MV_PAR04 OF oDlg PIXEL
                                                                        
// ListBox com as vendas nos parametros solicitados
@ 035, 003 GROUP oGroup TO 117, 312 LABEL STR0013 OF oDlg PIXEL		// Vendas
oGroup:SetFont(oFnt2)

// Loja, Emiss„o, Unidades, Valor Bruto, Desconto ($), Desconto (%), Valor L¡quido, Custo, Lucro Bruto, Margem Med. de Lucro
@ 042, 007 LISTBOX oVendas;
		   FIELDS HEADER "", cTitLoja, STR0004, cTitUnid,;
		   		  STR0006  , STR0007 , STR0008, STR0009,;
		   		  STR0010  , STR0011 , STR0012;
		   SIZE 300, 70 ;
		   ON DBLCLICK LJ080Nivel( @aTotVendas, aVendas, oVendas:nAt, oVendas,;
		   						   oDlg ); 
		   OF oDlg; 
		   PIXEL FONT oFnt

// ListBox com as devolucoes nos parametros solicitados
@ 119, 003 GROUP oGroup TO 199, 312 LABEL STR0019; 
						OF oDlg; 
						PIXEL		// Devolucoes
oGroup:SetFont(oFnt2)

// Loja, Emiss„o, Unidades, Valor Bruto, Desconto ($), Desconto (%), Valor L¡quido, Custo, Lucro Bruto, Margem Med. de Lucro
@ 125, 007 LISTBOX oDevol; 
		   FIELDS HEADER "", cTitLoja, STR0004, cTitUnidDev,;
		   		  STR0006  , STR0007 , STR0008, STR0009	   ,;
		   		  STR0010  , STR0011 , STR0012;
		   SIZE 300, 70 ;
		   ON DBLCLICK LJ080Nivel( @aTotDevol, aDevol, oDevol:nAt, oDevol,;
		   						   oDlg ); 
           OF oDlg; 
           PIXEL FONT oFnt

@ 002, 065 BUTTON STR0002; 
		   SIZE 51,11 FONT oDlg:oFont;
		   ACTION oDlg:End();
		   OF oDlg CANCEL	// Sair

LJ080AtivaBox( oVendas, aTotVendas )
LJ080AtivaBox( oDevol, aTotDevol )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT oVendas:Refresh()
Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJ080Nivel³ Autor ³ Vendas Clientes       ³ Data ³ 17/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para tratar opcoes disponiveis para Drill-Down      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com o total de vendas por filial             ³±±
±±³          ³ ExpA2 = Array com o total de vendas de uma filial por data ³±±
±±³          ³ ExpN3 = Numero da linha atual selecionada pelo usuario     ³±±
±±³          ³ ExpO4 = Objeto ListBox que apresenta os dados de venda     ³±±
±±³          ³ ExpO5 = Objeto do dialogo principal          			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJC080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ080Nivel( aTotal, aItens, nLin, oListBox,;
							oDlg )
Local nPos
Local nCont
Local nLenItens
Local nItens
Local cLoja
Local nLenTotal
Local aTempItens
Local aTempTotal := {}

If Empty(aTotal[nLin,1])
	Return(.T.)
Endif

// Verifica quantas vendas houveram da filial na linha selecionada
cLoja		:= aTotal[nLin, P_FILIAL]
nPos		:= aScan( aItens, { |x| x[P_FILIAL] == cLoja } )
nLenItens	:= Len( aItens )

For nCont := nPos to nLenItens
	If aItens[ nCont, P_FILIAL ] <> cLoja
		Exit
	Endif
Next nCont
    
// Calcula numero de vendas por filial e redimensiona arrays
nItens := nCont - nPos

// Muda o sinal 
If aTotal[nLin,P_SINAL] == P_ABERTO

	aTotal[nLin,P_SINAL] := P_FECHADO
	nLenTotal  := Len( aTotal )	
	aTempItens := {}

	// Apaga as linhas analiticas	
	For nCont := 1 to nItens
	    ADel(aTotal,(nLin+1))
	Next                      
                                 
	// Volta a linha de total
	For nCont := 1 to nLenTotal
		If aTotal[nCont] <> NIL
			AAdd( aTempItens, aTotal[nCont] )
		Endif
	Next

	aTotal := aTempItens
Else
	aTotal[ nLin, P_SINAL ] := P_ABERTO

	nLenTotal := Len( aTotal )

	// Redimensiona array de totais com o numero de itens a 
	// serem mostrados logo abaixo daquela linha de total
	ASize( aTotal, nLenTotal + nItens )
	
	// Dimensiona array temporaria de totais com o numero de linhas
	// de totais a partir da linha selecionada para abertura
	ASize( aTempTotal, ( nLenTotal - nLin ) )

	// Copia as linhas do array de totais a partir da linha selecionada
	// para uma array de totais temporaria
	ACopy( aTotal, aTempTotal, (nLin + 1), (nLenTotal-nLin), 1 )	
	                            
	// Copia os itens da linha selecionada para a posicao logo abaixo
	ACopy( aItens, aTotal, nPos, nItens, (nLin+1) )	
	                                                                 
	// Copia o restante do array de totais temporario para o 
	// array de totais original, logo apos o ultimo item analitico da linha
	// de total selecionada
	ACopy( aTempTotal, aTotal, 1, Len(aTempTotal), (nLin+nItens+1) )

Endif

LJ080AtivaBox( oListBox, aTotal )

oListBox:Refresh()
oDlg:Refresh()

Return(.T.)
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJ080FormaCol³ Autor ³ Vendas Clientes    ³ Data ³ 20/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Formata as colunas das linhas analiticas e sinteticas      ³±±
±±³          ³ para montar o Drill-Down.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com o as linhas sintehticas ou analiticas.   ³±±
±±³          ³ ExpL2 = Indica se o vetor eh analitico ou sintetico.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJC080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ080FormaCol( aLinhas, lAnalitico )
Local nLen      := Len( aLinhas )
Local nCont		:= 0
Local nDescPer  := 0	// Desconto em percentual
Local nPerLucro := 0	// Percentual de Lucro

For nCont := 1 to nLen
    If lAnalitico
    	aLinhas[nCont,P_DESCFIL]	:= ""
		aLinhas[nCont,P_EMISSAO]	:= DtoC( aLinhas[ nCont, P_EMISSAO] )
	Endif

   	// Calcula os percentuais de desconto e de custo	
	nDescPer  := ( aLinhas[nCont,P_VALDESC] * 100 ) / aLinhas[nCont,P_VALTOT]
	nPerLucro := ( aLinhas[nCont,P_LUCRO] * 100 ) / aLinhas[nCont,P_VALLIQ]
		
	aLinhas[nCont,P_UNIDADES] := Transform( aLinhas[nCont,P_UNIDADES], PesqPict("SL2","L2_QUANT") )
	aLinhas[nCont,P_VALTOT]   := Transform( aLinhas[nCont,P_VALTOT], PesqPict("SL1","L1_VLRTOT") )
	aLinhas[nCont,P_VALDESC]  := Transform( aLinhas[nCont,P_VALDESC], PesqPict("SL2","L2_VALDESC"))
	aLinhas[nCont,P_PERDESC]  := Transform( nDescPer, PesqPict("SL2","L2_DESC") )
	aLinhas[nCont,P_VALLIQ]   := Transform( aLinhas[nCont,P_VALLIQ], PesqPict("SL1","L1_VLRLIQ"))
	aLinhas[nCont,P_CUSTO]    := Transform( aLinhas[nCont,P_CUSTO], PesqPict("SD2","D2_CUSTO1") )
	aLinhas[nCont,P_LUCRO]    := Transform( aLinhas[nCont,P_LUCRO], PesqPict("SD2","D2_CUSTO1") )
	aLinhas[nCont,P_PERLUCRO] := Transform( nPerLucro, "@E 999,999.99" )
Next nCont

Return(.T.)
                                                     
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ080AtivaBox³ Autor ³ Vendas Clientes   ³ Data ³ 02/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o vetor com as colunas do ListBox.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto utilizado no listbox de Vendas    		  ³±±
±±³          ³ ExpA1 = Array com o as linhas sintehticas ou analiticas.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJC080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ080AtivaBox( oListBox, aTotal )

If Len( aTotal ) <> 0        

	oListBox:SetArray( aTotal )
	oListBox:bLine := { || { 	aTotal[oListBox:nAt,P_SINAL], aTotal[oListBox:nAt,P_DESCFIL],;
								aTotal[oListBox:nAt,P_EMISSAO], aTotal[oListBox:nAt,P_UNIDADES],;
								aTotal[oListBox:nAt,P_VALTOT], aTotal[oListBox:nAt,P_VALDESC],;
								aTotal[oListBox:nAt,P_PERDESC], aTotal[oListBox:nAt,P_VALLIQ],;
								aTotal[oListBox:nAt,P_CUSTO], aTotal[oListBox:nAt,P_LUCRO],;
								aTotal[oListBox:nAt,P_PERLUCRO] } }
Endif

Return( NIL )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ080Total   ³ Autor ³ Vendas Clientes   ³ Data ³ 09/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera vetores totalizados para montar os listbox de vendas  ³±±
±±³			 ³ e devolucoes.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com o as linhas sintehticas ou analiticas.   ³±±
±±³			 ³ ExpA2 = Array com a linha de total do listbox.			  ³±±
±±³			 ³ ExpA3 = Array com as lojas para montar os listbox.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJC080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ080Total( aItens, aTotal, aLojas )
Local cLoja
Local nLenItens
Local nCont
Local nPos   
Local nTotItens	 := 0		// Total geral de itens das vendas
Local nTotVlrTot := 0		// Total geral do valor total das vendas
Local nTotDesc	 := 0		// Total geral do valor de desconto das vendas
Local nTotPDesc	 := 0		// Percentual de desconto a partir do nTotDesc e nTotVlrTot
Local nTotVlrLiq := 0		// Total geral do valor liquido das vendas
Local nTotCMerc	 := 0		// Total geral do custo das mercadorias
Local nTotLucro	 := 0		// Total geral do lucro sobre as vendas
Local nTotPLucro := 0		// Percentual do lucro a partir do nTotLucro e nTotVlrLiq
Local nSemLoja   := 0		// Identifica se existe pelo menos uma loja sem descricao

// Transforma os dados analiticos em sinteticos
nLenItens := Len( aItens )
nSemLoja  := aScan( aLojas, { |x| x[2] == "" } )

For nCont := 1 to nLenItens

	// Verifica se a linha jah foi adicionada para somar os valores ou acrescentar
	// no vetor de totais de vendas/devolucoes.
	nPos := aScan( aTotal, { |x| x[P_FILIAL] == aItens[ nCont, P_FILIAL ] } )

	If nPos <> 0
		aTotal[ nPos, P_UNIDADES ] += aItens[ nCont, P_UNIDADES ]
		aTotal[ nPos, P_VALTOT   ] += aItens[ nCont, P_VALTOT   ]
		aTotal[ nPos, P_VALDESC  ] += aItens[ nCont, P_VALDESC  ]
		aTotal[ nPos, P_VALLIQ   ] += aItens[ nCont, P_VALLIQ   ]
		aTotal[ nPos, P_CUSTO    ] += aItens[ nCont, P_CUSTO    ]
		aTotal[ nPos, P_LUCRO    ] += aItens[ nCont, P_LUCRO    ]
	Else
		// Busca a descricao da loja no vetor da tabela de Identificacao de Lojas 
		// montado anteriormente.
		If nSemLoja == 0
			nPos  := aScan( aLojas, { |x| x[1] == aItens[ nCont, P_FILIAL ] } )
			cLoja := aLojas[ nPos, 2 ]
		Else
		    cLoja := aItens[ nCont, P_DESCFIL ]
		Endif
		
		// Cria linha totalizada para os listbox de devolucoes e vendas
		AAdd( aTotal, { P_FECHADO,;						// Abrir/Fechar
 						 aItens[ nCont, P_FILIAL   ],;		// Filial         
 						 cLoja,;							// Descricao da Filial
						 " ",;								// Data de Emissao
						 aItens[ nCont, P_UNIDADES ],;		// Unidades Vendidas / Devolvidas
						 aItens[ nCont, P_VALTOT   ],;		// Preco Orig.
						 aItens[ nCont, P_VALDESC  ],; 	// Desconto ($)      
						 aItens[ nCont, P_PERDESC  ],;		// Desconto (%)
						 aItens[ nCont, P_VALLIQ   ],;		// Valor total liquido de vendas/devolucoes
						 aItens[ nCont, P_CUSTO    ],;		// Custo total
						 aItens[ nCont, P_LUCRO    ],;		// Lucro Bruto
						 aItens[ nCont, P_PERLUCRO ] } )	// Margem Med. de Lucro
	Endif

Next nCont
          
// Apura total geral
nLenTotal := Len( aTotal )

For nCont := 1 to nLenTotal
	nTotItens  += aTotal[ nCont, P_UNIDADES ]
	nTotVlrTot += aTotal[ nCont, P_VALTOT   ]
	nTotDesc   += aTotal[ nCont, P_VALDESC  ]
	nTotVlrLiq += aTotal[ nCont, P_VALLIQ   ]
	nTotCMerc  += aTotal[ nCont, P_CUSTO    ]
	nTotLucro  += aTotal[ nCont, P_LUCRO    ]
Next nCont
             
// Calcula percentuais dos totais gerais de desconto e lucro.
nTotPDesc  := ( nTotDesc  * 100 ) / nTotVlrTot
nTotPLucro := ( nTotLucro * 100 ) / nTotVlrLiq
             
// Gera a linha de total.
AAdd( aTotal, { " ", " ", " ", " ", nTotItens, nTotVlrTot, nTotDesc, nTotPDesc, nTotVlrLiq,;
	  nTotCMerc, nTotLucro, nTotPLucro } )

Return( NIL )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ080Itens   ³ Autor ³ Vendas Clientes   ³ Data ³ 09/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera vetor com os dados das vendas analiticas por dia.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados analiticos das vendas por dia.  ³±±
±±³          ³ ExpN1 = Custo do produto.                                  ³±±
±±³          ³ ExpN2 = Tipo de unidade (Item/Quantidade/Vendas) escolhida ³±±
±±³          ³         no pergunte.										  ³±±
±±³          ³ ExpC1 = Filial da venda atualmente processada.             ³±±
±±³          ³ ExpD1 = Data da emissao do titulo.                         ³±±
±±³          ³ ExpN3 = Valor total do item vendido sem desconto.          ³±±
±±³          ³ ExpN4 = Desconto do item vendido.                          ³±±
±±³          ³ ExpN5 = Quantidade vendida do item.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJC080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ080Itens( aVetor	, nCusto  , nTipoUnid, cFil,;
							dEmissao, nVlrItem, nDesconto, nQuant )
Local nPos        
Local nUnidades

nPos := aScan( aVetor, { |x| x[P_FILIAL] == cFil .and. x[P_EMISSAO] == dEmissao } )
             
If nTipoUnid == 1
	nUnidades := 1
ElseIf nTipoUnid == 2
	nUnidades := nQuant
Else
	nUnidades := 0	
Endif		

If nPos <> 0
	aVetor[ nPos, P_UNIDADES ] += nUnidades
	aVetor[ nPos, P_VALTOT   ] += nVlrItem + nDesconto
	aVetor[ nPos, P_VALDESC  ] += nDesconto
	aVetor[ nPos, P_VALLIQ   ] += nVlrItem
	aVetor[ nPos, P_CUSTO    ] += nCusto
	aVetor[ nPos, P_LUCRO    ] += nVlrItem - nCusto
Else
	SL2->( AAdd( aVetor, { P_BRANCO,;					// Sinal
							 cFil,;						// Filial
							 cFil,;						// Descricao da Filial
							 dEmissao,;					// Data de Emissao
							 nUnidades,;				// Total de Unidades Vendidas por Filial
							 nVlrItem + nDesconto,;		// Valor total vendido por filial bruto
							 nDesconto,;				// Valor total do desconto
							 0,;						// Percentual de desconto
							 nVlrItem,;					// Valor total liquido
							 nCusto,;					// Custo da mercadoria
							 nVlrItem - nCusto,;		// Lucro Bruto
							 0 } ) )					// Margem Media de Lucro
Endif

Return( NIL )



