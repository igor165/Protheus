#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "LOJR600.CH"

/**
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LOJR600	³ Autor ³ Vendas Crm            ³ Data ³ 16/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio de Garantia estendida                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LOJR600()
Local oReport

If !GetRpoRelease ("R5")
	Return nil
EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte("LOJR600",.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ MV_PAR01          // Filial De ?                             ³
	//³ MV_PAR02          // Filial Até ?                            ³
	//³ MV_PAR03          // Data de?					             ³
	//³ MV_PAR04          // Data até?                 				 ³
	//³ MV_PAR05          // Tipo de relatório                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oReport:=LOJR600Def()
	oReport:PrintDialog()
	

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOJR600Def   ³ Autor ³Vendas Crm          ³ Data ³16/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que define os itens que serao apresentados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LOJR600Def()

Local	oReport		:= NIL				   	// Objeto relatorio TReport
Local	oSection1	:= NIL					// Objeto secao 1 do relatorio (Lista, campos das tabelas SB1)
Local	cAlias1		:= GetNextAlias()		// Pega o proximo Alias Disponivel
Local	cTitulo		:= ""					// Titulo do relatorio

cAlias1		:= GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TITULO DA IMPRESSAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DO CASE
	CASE MV_PAR05 == 1       				//Produto
		cTitulo := STR0001
	CASE MV_PAR05 == 2       				//Administradora
		cTitulo := STR0002
	OTHERWISE                				//Cliente
		cTitulo := STR0003
ENDCASE

oReport := TReport():New("LOJR600",cTitulo,"LOJR600",{|oReport| LOJR600RPT(oReport)}, STR0004 ) // Garantia Estendida

DO CASE
	CASE MV_PAR05 == 1      				//Produto
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define a secao1 do relatorio, informando que o arquivo principal ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oSection1 := TRSection():New(oReport,STR0004,{"MBJ"} )
		oSection1 :SetLineStyle()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define as celulas que irao aparecer na secao1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		TRCell():New(oSection1,"MBJ_FILIAL" 	,"MBJ")
		
		TRCell():New(oSection1,"MBJ_DOC" 		,"MBJ")
		
		TRCell():New(oSection1,"MBJ_SERIE" 		,"MBJ")
		
		TRCell():New(oSection1,"MBJ_PROD" 		,"MBJ")
		
		TRCell():New(oSection1,"MBJ_TIPO" 		,"MBJ")
		
		TRCell():New(oSection1,"MBJ_DATA" 		,"MBJ")
		
		TRCell():New(oSection1,"MBJ_VALUNI" 	,"MBJ")
		                                             
		TRCell():New(oSection1,"MBJ_NUMTIT" 	,"MBJ")

		TRCell():New(oSection1,"MBJ_NSERIE" 	,"MBJ")

		TRCell():New(oSection1,"MBJ_SERTIT" 	,"MBJ")		
		
		oSection1:Cell("MBJ_FILIAL"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_FILIAL"):SetSize (07)
		
		oSection1:Cell("MBJ_DOC"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_DOC"):SetSize (10)
		
		oSection1:Cell("MBJ_SERIE"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_SERIE"):SetSize (10)
		
		oSection1:Cell("MBJ_PROD"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_PROD"):SetSize (07)
		
		oSection1:Cell("MBJ_TIPO"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_TIPO"):SetSize (15)
		
		oSection1:Cell("MBJ_DATA"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_DATA"):SetSize (15)
		
		oSection1:Cell("MBJ_VALUNI"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_VALUNI"):SetSize (10)


		oSection1:Cell("MBJ_NUMTIT"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_NUMTIT"):SetSize (10)


		oSection1:Cell("MBJ_NSERIE"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_NSERIE"):SetSize (07)


		oSection1:Cell("MBJ_SERTIT"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_SERTIT"):SetSize (10)
		
	CASE MV_PAR05 == 2       //Administradora
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define a secao1 do relatorio, informando que o arquivo principal ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oSection1 := TRSection():New(oReport,STR0004,{"MBJ","SAE","SB1"} )
		oSection1 :SetLineStyle()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define as celulas que irao aparecer na secao1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		TRCell():New(oSection1,"AE_DESC"		,"SAE")
		
		TRCell():New(oSection1,"MBJ_FILIAL" 	,"MBJ")
		
		TRCell():New(oSection1,"MBJ_DOC" 		,"MBJ")
		
		TRCell():New(oSection1,"MBJ_PROD" 		,"MBJ")
		
		TRCell():New(oSection1,"MBJ_NSERIE" 	,"MBJ")

		TRCell():New(oSection1,"MBJ_GARANT" 	,"MBJ")		

		TRCell():New(oSection1,"MBJ_TIPO" 		,"MBJ")
		
		oSection1:Cell("AE_DESC"):SetAlign ("LEFT")
		oSection1:Cell("AE_DESC"):SetSize (30)
		
		oSection1:Cell("MBJ_FILIAL"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_FILIAL"):SetSize (07)
		
		oSection1:Cell("MBJ_DOC"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_DOC"):SetSize (10)
		
		oSection1:Cell("MBJ_PROD"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_PROD"):SetSize (07)
		
		oSection1:Cell("MBJ_NSERIE"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_NSERIE"):SetSize (15)
		
		oSection1:Cell("MBJ_GARANT"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_GARANT"):SetSize (15)
		
		oSection1:Cell("MBJ_TIPO"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_TIPO"):SetSize (10)
		
		
	OTHERWISE
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define a secao1 do relatorio, informando que o arquivo principal ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oSection1 := TRSection():New(oReport,STR0004,{"MBJ","SE1"} )
		oSection1 :SetLineStyle()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define as celulas que irao aparecer na secao1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		TRCell():New(oSection1,"E1_CLIENTE" ,"SE1")
		TRCell():New(oSection1,"E1_NOMCLI" ,"SE1")
		TRCell():New(oSection1,"MBJ_DATA" ,"MBJ")
		TRCell():New(oSection1,"MBJ_TIPO" ,"MBJ")
		TRCell():New(oSection1,"MBJ_PROD" ,"MBJ")
		TRCell():New(oSection1,"MBJ_NSERIE" ,"MBJ")
		TRCell():New(oSection1,"TOTAL" ,"MBJ")
		
		
		
		oSection1:Cell("E1_CLIENTE"):SetAlign ("LEFT")
		oSection1:Cell("E1_CLIENTE"):SetSize (07)
		
		oSection1:Cell("E1_NOMCLI"):SetAlign ("LEFT")
		oSection1:Cell("E1_NOMCLI"):SetSize (20)
		
		oSection1:Cell("MBJ_DATA"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_DATA"):SetSize (15)
		
		oSection1:Cell("MBJ_TIPO"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_TIPO"):SetSize (15)
		
		oSection1:Cell("MBJ_PROD"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_PROD"):SetSize (15)
		
		oSection1:Cell("MBJ_NSERIE"):SetAlign ("LEFT")
		oSection1:Cell("MBJ_NSERIE"):SetSize (15)
		
		oSection1:Cell("TOTAL"):SetAlign ("LEFT")
		oSection1:Cell("TOTAL"):SetSize (10)
		
		
ENDCASE

Return(oReport)
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOJR600RPT   ³ Autor ³Leandro Nogueira    ³ Data ³16/10/2010³±±
±±³          ³             ³       ³                    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel pela impressao do relatorio              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LOJR600RPT (oReport)
Local oSection1 := oReport:Section(1) 		//Objeto secao 1 do relatorio (Lista, campos das tabelas SB1)
Local cFiltro	:= ""   					//String contendo o filtro de busca a ser utilizado com DBF
Local cFiltro2	:= ""   					//String contendo o filtro de busca a ser utilizado com DBF
Local cFiltro3	:= ""   					//String contendo o filtro de busca a ser utilizado com DBF
Local cAlias1	:= GetNextAlias()			// Pega o proximo Alias Disponivel


#IFDEF TOP
	MakeSqlExpr("LOJR600")
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtro caso 1           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltro += 	"WHERE (MBJ_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') AND  MBJ_DATA BETWEEN '" + Dtos(MV_PAR03) + "' AND '" + Dtos(MV_PAR04) +"'"
	
	cFiltro := "%"+cFiltro+"%"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtro caso 2           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltro2 += "WHERE  MBJ_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND  MBJ_DATA BETWEEN '" + Dtos(MV_PAR03) + "' AND '" + Dtos(MV_PAR04) +"' ORDER BY MBJ_ADMIN"
	
	cFiltro2 := "%"+cFiltro2+"%"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtro caso 3           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltro3 += "WHERE E1_NUM = MBJ_DOC AND (MBJ_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') AND  MBJ_DATA BETWEEN '" + Dtos(MV_PAR03) + "' AND '" + Dtos(MV_PAR04) +"' 	group by e1_cliente,e1_nomcli,mbj_data, mbj_tipo,mbj_prod order by E1_CLIENTE , MBJ_DATA"
	
	
	cFiltro3 := "%"+cFiltro3+"%"
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a secao 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oSection1:BeginQuery()
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SELECIONA O SELECT QUE RETORNA OS RESULTADOS POR ROTINA SELECIONADA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DO CASE
		CASE MV_PAR05 == 1       //Produto
			
			BeginSQL alias cAlias1
				SELECT MBJ_DOC, MBJ_FILIAL,	MBJ_PROD, MBJ_DATA, MBJ_VALUNI,MBJ_SERIE FROM %table:MBJ% MBJ %Exp:cFiltro%
			EndSql
			
		CASE MV_PAR05 == 2       //Administradora
			
			BeginSQL alias cAlias1
				SELECT MBJ_ADMIN, MBJ_FILIAL,MBJ_DOC, MBJ_PROD, MBJ_NSERIE , MBJ_GARANT , MBJ_TIPO FROM %table:MBJ% MBJ %Exp:cFiltro2%
			EndSql
			
		OTHERWISE                //Cliente
			BeginSQL alias cAlias1
				select E1_CLIENTE, E1_NOMCLI, MBJ_DATA, MBJ_TIPO, MBJ_PROD, sum(MBJ_VALUNI) total from %table:SE1% SE1, %table:MBJ% MBJ %Exp:cFiltro3%
			EndSql
	ENDCASE
	
	oSection1:EndQuery()
	
#ELSE
	
	MakeAdvplExpr("LOJR600")
	
	cFiltro := "!Empty(SL2->L2_GARANT)"
	
	// FILIAL
	If !Empty(MV_PAR01)
		cFiltro += " .AND. SL2->L2_FILIAL >= '" + MV_PAR01 + "'"
	Endif
	
	If !Empty(MV_PAR02)
		cFiltro += " .AND. SL2->L2_FILIAL <= '" + MV_PAR02 + "'"
	Endif
	
	//DATA VENDA
	If !Empty(MV_PAR03)
		cFiltro += " .AND. DTOS(SL2->L2_EMISSAO) >= '" + DTOS(MV_PAR03) + "'"
	Endif
	
	If !Empty(MV_PAR04)
		cFiltro += " .AND. DTOS(SL2->L2_EMISSAO) <= '" + DTOS(MV_PAR04) + "'"
	Endif
	
	// TIPO DO RELATÒRIO
	If !Empty(MV_PAR05)
		
		DO CASE
			CASE MV_PAR05 == 1       				//Produto
				cFiltro += 	" .AND. !Empty(SL2_L2_GARANT)"
			CASE MV_PAR05 == 2       				//Administradora
				cFiltro += 	" .AND. SAE->AE_SEGURAD = 1 .AND. SB1->B1_ADMIN = SAE->AE_COD"
			OTHERWISE                				//Cliente
				cFiltro += 	" .AND. !Empty(SL1->L1_CLIENTE)"
		ENDCASE
		
	Endif
	
	DbSelectArea("SL2")
	DbSetOrder(6) // L2_FILIAL+L2_SOLCOM
	
	
	TRPosition():New(oSection1,"SL1", 1, {|| xFilial("SL1") + SL2->L2_NUM } )
	TRPosition():New(oSection1,"SB1", 1, {|| xFilial("SB1") + SL2->L2_GARANT } )
	TRPosition():New(oSection1,"SAE", 1, {|| xFilial("SAE") + SL1->B1_ADMIN } )
	TRPosition():New(oSection1,"MBJ", 2, {|| xFilial("MBJ") + SL2->L2_PRODUTO } )
	TRPosition():New(oSection1,"SB1", 1, {|| xFilial("SB1") + SL2->L2_PRODUTO } )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o filtro de acordo com a expressao (somente do SL2)		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:SetFilter( "!SL2->(EOF())")
	
	oSection1:SetLineCondition({|| &(cFiltro) })
	
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quebra a linha, caso existam muitas colunas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:SetLineBreak()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a impressao dos dados, de query						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Print()


Return
