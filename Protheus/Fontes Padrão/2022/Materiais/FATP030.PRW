#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATP030.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FATP030   ³ Autor ³ Marco Bianchi         ³ Data ³ 22/01/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 2 Padrao 1: Carteira de³±±
±±³          ³Pedidos de Venda (Mensal ou Diario).                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FATP030()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = {{cCombo1,{cText1,cValor,nColorValor,cClick},..},..} ³±±
±±³          ³ cCombo1     = Detalhes                                       ³±±
±±³          ³ cText1      = Texto da Coluna                         		³±±
±±³          ³ cValor      = Valor a ser exibido (string)                   ³±±
±±³          ³ nColorValor = Cor do Valor no formato RGB (opcional)         ³±±
±±³          ³ cClick      = Funcao executada no click do valor (opcional)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMDI                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function FATP030()

Local aArea       := GetArea()
Local aAreaSC5    := SC6->(GetArea())
Local cAliasSC5   := "SC5"
Local aRet        := {} 
Local cMes        := StrZero(Month(dDataBase),2)
Local cAno        := Substr(DTOC(dDataBase),7,4)
Local dDataIni    := CTOD("01/"+cMes+"/"+cAno)
Local dDataFim    := CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Local nPedDia     := 0
Local nPedMes     := 0
Local nCliDia     := 0
Local nCliMes     := 0
Local nValDia     := 0
Local nValMes     := 0
Local nDescDia    := 0
Local nDescMes    := 0
Local aCliDia     := {}
Local aCliMes     := {}


#IFDEF TOP  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                                        ³
	//³                              D I A R I O                               ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Numero de pedidos no dia                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSC5 := GetNextAlias()
	BeginSql Alias cAliasSC5
	SELECT count(*) NPEDIDOS 
		FROM %Table:SC5% SC5 
		WHERE C5_FILIAL = %xFilial:SC5% AND C5_EMISSAO = %Exp:Dtos(dDataBase)% AND C5_TIPO NOT IN ('B','D') AND SC5.%NotDel% 
	EndSql
	nPedDia := (cAliasSC5)->NPEDIDOS
	(cAliasSC5)->(DbCloseArea())

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Numero de Clientes no dia                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSC5 := GetNextAlias()
	BeginSql Alias cAliasSC5 
	SELECT COUNT(*) NCLIENTES 
	FROM %Table:SA1% SA1 
	WHERE EXISTS(SELECT 1 FROM %Table:SC5% SC5 
					WHERE C5_FILIAL = %xFilial:SC5% AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND C5_EMISSAO = %Exp:Dtos(dDataBase)% 
					AND C5_TIPO NOT IN ('B','D') AND SC5.%NotDel%)
	
	EndSql
	nCliDia := (cAliasSC5)->NCLIENTES
	(cAliasSC5)->(DbCloseArea())
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor Total e desconto no dia                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSC5 := GetNextAlias()
	BeginSql Alias cAliasSC5
		SELECT SUM(C6_VALOR) NVALDIA, SUM(C6_VALDESC) NDESCDIA
		FROM  %Table:SC6% SC6,%Table:SC5% SC5
		WHERE C5_FILIAL = %xFilial:SC5% AND C5_FILIAL = C6_FILIAL 
		AND C5_NUM = C6_NUM AND C5_EMISSAO = %Exp:Dtos(dDataBase)% AND C5_TIPO NOT IN ('B','D') AND SC5.%NotDel% AND SC6.%NotDel%
	EndSql
	nValDia  := (cAliasSC5)->NVALDIA
	nDescDia := (cAliasSC5)->NDESCDIA
	(cAliasSC5)->(DbCloseArea())
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                                        ³
	//³                              M E N S A L                               ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Numero de pedidos no mes                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSC5 := GetNextAlias()
	BeginSql Alias cAliasSC5
	SELECT Count(*) NPEDIDOS 
		FROM %Table:SC5% SC5 
		WHERE C5_FILIAL = %xFilial:SC5% AND C5_EMISSAO >= %Exp:Dtos(dDataIni)% AND C5_EMISSAO <= %Exp:Dtos(dDataFim)% 
		AND C5_TIPO NOT IN ('B','D') AND SC5.%NotDel% 
	EndSql
	nPedMes := (cAliasSC5)->NPEDIDOS
	(cAliasSC5)->(DbCloseArea())
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Numero de Clientes no mes                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSC5 := GetNextAlias()
	BeginSql Alias cAliasSC5 
	SELECT Count(*) NCLIENTES 
	FROM %Table:SA1% SA1 
	WHERE EXISTS(SELECT 1 FROM %Table:SC5% SC5 
					WHERE C5_FILIAL = %xFilial:SC5% AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND C5_EMISSAO >= %Exp:Dtos(dDataIni)% 
					AND C5_EMISSAO <= %Exp:Dtos(dDataFim)% AND C5_TIPO NOT IN ('B','D') AND SC5.%NotDel%)
	EndSql
	nCliMes := (cAliasSC5)->NCLIENTES
	(cAliasSC5)->(DbCloseArea())
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor Total e desconto no mes                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSC5 := GetNextAlias()
	BeginSql Alias cAliasSC5
		SELECT SUM(C6_VALOR) NVALMES, SUM(C6_VALDESC) NDESCMES 
		FROM %Table:SC5% SC5, %Table:SC6% SC6 
		WHERE C5_FILIAL = %xFilial:SC5% AND C5_FILIAL = C6_FILIAL  
		AND C5_NUM = C6_NUM AND C5_EMISSAO >= %Exp:Dtos(dDataIni)% AND C5_EMISSAO <= %Exp:Dtos(dDataFim)% 
		AND C5_TIPO NOT IN ('B','D') AND SC5.%NotDel% AND SC6.%NotDel%  
	EndSql
	nValMes  := (cAliasSC5)->NVALMES
	nDescMes := (cAliasSC5)->NDESCMES
	(cAliasSC5)->(DbCloseArea())

	
#ELSE 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Numero de pedidos,numero de clientes, valor total e desconto total      ³
	//³no dia e no mes.                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC5")		// Pedidos de Vendas
	dbSetOrder(2)				// Emissao
	dbSeek(xFilial("SC5")+DTOS(dDataIni),.T.)
	While !Eof() .And. C5_EMISSAO <= dDataFim
		
		If C5_TIPO $ ("B/D")
			dbSkip()
			Loop
		EndIf
		
		// Numero de Pedidos
		If C5_EMISSAO == dDataBase
			nPedDia++
		EndIf
		nPedMes++
		
		// Numero de Clientes no Dia
		If (AScan(aCliDia,C5_CLIENTE+C5_LOJACLI) == 0) .And. (C5_EMISSAO == dDataBase)
			AADD(aCliDia,C5_CLIENTE+C5_LOJACLI)			
			nCliDia++
		EndIf
		
		// Numero de Clientes no Mes
		If AScan(aCliMes,C5_CLIENTE+C5_LOJACLI) == 0     
			AADD(aCliMes,C5_CLIENTE+C5_LOJACLI)
			nCliMes++
		EndIf
		
		
		// Valor total e Desconto
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+SC5->C5_NUM)
		While !Eof() .And. C6_NUM == SC5->C5_NUM
		    
		    If SC5->C5_EMISSAO == dDataBase
			    nValDia  += C6_VALOR
			    nDescDia += C6_VALDESC
		    EndIf
		    nValMes  += C6_VALOR
		    nDescMes += C6_VALDESC
			dbSkip()
			
		EndDo
		
		dbSelectArea("SC5")		
		dbSkip()
	EndDo
	
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aRet, { STR0001, { ;																	// "Diario"
			{ STR0002, Transform(nPedDia  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;		// "No. Pedidos"
			{ STR0003, Transform(nCliDia  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;		// "No. Clientes"
			{ STR0004, Transform(nValDia  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;		// "Valor Pedidos"
			{ STR0005, Transform(nDescDia ,"@R 999,999,999.99"),CLR_BLUE,{ || } } } } )	// "Desconto Pedidos"
	
Aadd( aRet, { STR0006, { ;																	// "Mensal"
			{ STR0002, Transform(nPedMes  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;		// "No. Pedidos"
			{ STR0003, Transform(nCliMes  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;		// "No. Clientes"
			{ STR0004, Transform(nValMes  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;		// "Valor Pedidos"
			{ STR0005, Transform(nDescMes ,"@R 999,999,999.99"),CLR_BLUE,{ || } } } } )	// "Desconto Pedidos"

                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura areas                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSC5)
RestArea(aArea)


Return aRet
                   