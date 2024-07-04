#INCLUDE "REPORT.CH"   
#INCLUDE "LOJR810.CH"        

#IFDEF TOP
	Static	cAlias1	:= GetNextAlias()// Pega o proximo Alias Disponivel
#ENDIF	

Static lLGPD := Iif(ExistFunc("LjPDUse"),LjPDUse(),.F.) //Verifica se a funcionalidade de Dados Protegidos está sendo utilizada no sistema.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LOJR810	³ Autor ³ Vendas Crm            ³ Data ³ 23/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio de Vendas x Midia                                ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LOJR810()										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil                         		      		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß    
*/                                                          
Function LOJR810()
Local oReport   := Nil                         // Objeto relatorio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("LOJR810",.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ MV_PAR01          // Filial De ?                             ³
//³ MV_PAR02          // Filial Ate ?                            ³
//³ MV_PAR03          // Loja de ?                               ³
//³ MV_PAR04          // Loja ate ?                              ³
//³ MV_PAR05          // Cliente de ?                            ³
//³ MV_PAR06          // Cliente ate ?                           ³
//³ MV_PAR07          // Midia de ?                              ³
//³ MV_PAR08          // Midia ate ?                             ³
//³ MV_PAR09          // Data venda de ?                         ³
//³ MV_PAR10          // Data venda ate ?                        ³
//³ MV_PAR11          // Tipo de Venda ?                         ³
//³ MV_PAR12          // Analitico/Sintetico ?                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=LOJR810Def() 
oReport:PrintDialog() 	

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOJR810Def   ³ Autor ³ Vendas Crm         ³ Data ³23/11/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que define os itens que serao apresentados          ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Sintaxe	 ³ LOJR810Def()										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ oReport - Objeto Relatorio  		      		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                       
Static Function LOJR810Def()
Local oReport	:= Nil				// Objeto relatorio TReport (Release 4)
Local oSection1 := Nil				// Objeto secao 1 do relatorio (Lista, campos das tabelas) 
Local cTitulo   := ""				// Titulo do relatorio   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TITULO DA IMPRESSAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR12 == 1
	cTitulo := STR0001 //"Relatorio de Vendas x Midia - Analitico"	
Else
	cTitulo := STR0002 //"Relatorio de Vendas x Midia - Sintetico"	
EndIf
oReport := TReport():New("LOJR810",cTitulo,"LOJR810",{|oReport| LOJR810RPT( oReport )}, STR0010 ) // "Midia"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TIPO ANALITICO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR12 == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define a secao1 do relatorio, informando que o arquivo principal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New( oReport,STR0010,{ "SL1","SUH","SA1" } )	//"Midia"   
	                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define as celulas que irao aparecer na secao1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	
	TRCell():New(oSection1,"L1_FILIAL"	,"SL1")  
	TRCell():New(oSection1,"L1_LOJA"	,"SL1",STR0003) //"Loja"
	TRCell():New(oSection1,"L1_NUM"	    ,"SL1",STR0004) //"Numero"	
	TRCell():New(oSection1,"L1_DOC"    ,"SL1",STR0005)	//"Cup. Fiscal"
	TRCell():New(oSection1,"L1_SERIE"  ,"SL1",STR0006)	//"Serie"
	TRCell():New(oSection1,"L1_DOCPED" ,"SL1",STR0007)	//"Pedido"
	TRCell():New(oSection1,"L1_SERPED" ,"SL1",STR0008)	//"Serie Ped."
	
	#IFDEF TOP
		TRCell():New(oSection1,"CLIENTE"	,""   ,STR0009,,,,{|| (cAlias1)->L1_CLIENTE + " - " + (cAlias1)->A1_NOME})//"Cliente"
		TRCell():New(oSection1,"MIDIA"	    ,""   ,STR0010,,,,{|| (cAlias1)->L1_MIDIA   + " - " + (cAlias1)->UH_DESC})//"Midia"
	#ELSE		 
	 	TRCell():New(oSection1,"CLIENTE"	,""   ,STR0009,,,,{|| ("SL1")->L1_CLIENTE + " - " + ("SA1")->A1_NOME})//"Cliente"
		TRCell():New(oSection1,"MIDIA"	    ,""   ,STR0010,,,,{|| ("SL1")->L1_MIDIA   + " - " + ("SUH")->UH_DESC})//"Midia" 
	#ENDIF  		     
		
	TRCell():New(oSection1,"L1_EMISSAO"	,"SL1")		    //"Data Emissao Orcamento"
	
	oSection1:Cell("L1_FILIAL"):SetAlign ("LEFT")
	oSection1:Cell("L1_FILIAL"):SetSize (05)
	
	oSection1:Cell("L1_LOJA"):SetAlign ("LEFT")
	oSection1:Cell("L1_LOJA"):SetSize (05)	
	
	oSection1:Cell("L1_NUM"):SetAlign ("LEFT")
	oSection1:Cell("L1_NUM"):SetSize (10)  
	
	oSection1:Cell("L1_DOC"):SetAlign ("LEFT")
	oSection1:Cell("L1_DOC"):SetSize (10)
	
	oSection1:Cell("L1_SERIE"):SetAlign ("LEFT")
	oSection1:Cell("L1_SERIE"):SetSize (10)
	
	oSection1:Cell("L1_DOCPED"):SetAlign ("LEFT")
	oSection1:Cell("L1_DOCPED"):SetSize (10)
	
	oSection1:Cell("L1_SERPED"):SetAlign ("LEFT")
	oSection1:Cell("L1_SERPED"):SetSize (10)
	
	oSection1:Cell("CLIENTE"):SetAlign ("LEFT")
	oSection1:Cell("CLIENTE"):SetSize (40)
	If lLGPD .And. LjPDCmpPrt("LQ_NOMCLI")
		oSection1:Cell("CLIENTE"):SetObfuscate(.T.)
	EndIf
		
	oSection1:Cell("MIDIA"):SetAlign ("LEFT")
	oSection1:Cell("MIDIA"):SetSize (40)

	oSection1:Cell("L1_EMISSAO"):SetAlign ("LEFT")
	oSection1:Cell("L1_EMISSAO"):SetSize (10)	
   	
Else  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TIPO SINTETICO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define a secao1 do relatorio, informando que o arquivo principal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New( oReport,STR0010,{ "SL1","SUH"} )	// "Midia"   
		                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define as celulas que irao aparecer na secao1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		TRCell():New(oSection1,"MIDIA" ,"",STR0010,,,,{|| (cAlias1)->L1_MIDIA   + " - " + (cAlias1)->UH_DESC})//"Midia" 
		TRCell():New(oSection1,"TOTAL"	,"",STR0011) //"Total de movimentos no periodo"
		oSection1:Cell("TOTAL"):SetSize (15)		
	   
		TRFunction():New(oSection1:Cell("TOTAL"),NIL,"SUM",,STR0012,,,.F.)        //"TOTAL DE VENDAS" 		
	#ELSE		 		
		TRCell():New(oSection1,"MIDIA" ,"",STR0010,,,,{|| ("SL1")->L1_MIDIA   + " - " + ("SUH")->UH_DESC})//"Midia" 
		 
	    DEFINE BREAK oBreak OF oSection1 WHEN oSection1:Cell("MIDIA")
	    oBreak:SetTotalInLine(.F.)		// Imprime total em linha ou coluna (.T. - linha .F. - Coluna )
	    oReport:SetLandscape()
	
		DEFINE FUNCTION FROM oSection1:Cell("MIDIA") FUNCTION COUNT BREAK oBreak NO END SECTION NO END REPORT //TITLE "Total:"	
	#ENDIF
	
	oSection1:Cell("MIDIA"):SetSize (90)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
	
Endif
                    
Return(oReport) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOJR810RPT   ³ Autor ³ Vendas Crm         ³ Data ³23/11/2010³±±
±±³          ³             ³       ³                    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel pela impressao do relatorio              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Sintaxe	 ³ LOJR810RPT (ExpO1)  		   	    				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto relatorio     							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil						  		      		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LOJR810RPT (oReport) 

Local oSection1 := oReport:Section(1) 		// Objeto secao 1 do relatorio (Lista, campos das tabelas)
Local cFiltro	:= ""   					// String contendo o filtro de busca a ser utilizado com DBF   

#IFDEF TOP      

	MakeSqlExpr("LOJR810")
	
	// FILIAL
	If !Empty(MV_PAR01)
		cFiltro += 	" AND L1_FILIAL >= '" + MV_PAR01 + "'"           
	Endif
	
	If !Empty(MV_PAR02)
		cFiltro += 	" AND L1_FILIAL <= '" + MV_PAR02 + "'"           
	Endif
	
	//LOJA
	If !Empty(MV_PAR03)
		cFiltro += 	" AND L1_LOJA >= '" + MV_PAR03 + "'"           
	Endif  
	
	If !Empty(MV_PAR04)
		cFiltro += 	" AND L1_LOJA <= '" + MV_PAR04 + "'"           
	Endif
	
	//CLIENTE
	If !Empty(MV_PAR05)
		cFiltro += 	" AND L1_CLIENTE >= '" + MV_PAR05 + "'"           
	Endif 
	
	If !Empty(MV_PAR06)
		cFiltro += 	" AND L1_CLIENTE <= '" + MV_PAR06 + "'"           
	Endif
	
	//MIDIA
	If !Empty(MV_PAR07) 
		cFiltro += 	" AND L1_MIDIA >= '" + MV_PAR07 + "'"           
	Endif

	If !Empty(MV_PAR08)
		cFiltro += 	" AND L1_MIDIA <= '" + MV_PAR08 + "'"           
	Endif
	
	//DATA
	If !Empty(MV_PAR09)
		cFiltro += 	" AND L1_EMISSAO >= '" + DTOS(MV_PAR09) + "'"           
	Endif

	If !Empty(MV_PAR10)
		cFiltro += 	" AND L1_EMISSAO <= '" + DTOS(MV_PAR10) + "'"           
	Endif
	
	// TIPO DE VENDA
	If !Empty(MV_PAR11)
	
		Do Case
   			Case MV_PAR11 == 2
   				cFiltro += 	" AND L1_DOCPED = '' AND L1_DOC = ''" 
   			Case MV_PAR11 == 3                                                                                 
   				cFiltro += 	" AND L1_DOC <> ''" 
   			Case MV_PAR11 == 4                                                                                 
   				cFiltro += 	" AND L1_DOCPED <> ''" 
		EndCase
		          
	Endif
	
	cFiltro := "%"+cFiltro+"%"    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a secao 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:BeginQuery()	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TIPO ANALITICO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR12 == 1	
	
		BeginSQL alias cAlias1                          	
			SELECT 	L1_FILIAL, 
					L1_LOJA,
					L1_NUM,
					L1_CLIENTE,
					A1_NOME,
					L1_MIDIA,
					UH_DESC,					
					L1_EMISSAO,
					L1_DOC,
					L1_SERIE,
					L1_DOCPED,				
					L1_SERPED
		    FROM %table:SL1% SL1
				INNER JOIN %table:SA1% SA1 ON SL1.L1_CLIENTE = SA1.A1_COD    
				INNER JOIN %table:SUH% SUH ON SL1.L1_MIDIA = SUH.UH_MIDIA AND
				SA1.%notDel% AND      
				SUH.%notDel%    
		   	WHERE SL1.%notDel% %Exp:cFiltro%
				     
		     ORDER BY L1_FILIAL, L1_LOJA, L1_EMISSAO
		EndSql   	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TIPO SINTETICO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else 
		BeginSQL alias cAlias1                          	
	   		SELECT 	
	   			L1_MIDIA,
	   			UH_DESC,
	   			COUNT(L1_MIDIA) AS TOTAL   			
		    FROM %table:SL1% SL1   
				INNER JOIN %table:SUH% SUH ON SL1.L1_MIDIA = SUH.UH_MIDIA AND		         
				SUH.%notDel%
		   	WHERE SL1.%notDel% %Exp:cFiltro%
		   	GROUP BY L1_MIDIA, UH_DESC 	   			     
		    ORDER BY TOTAL DESC, L1_MIDIA
		EndSql  
	EndIf    
	
	oSection1:EndQuery() 	
	
#ELSE
        
    MakeAdvplExpr("LOJR810")     
	
	cFiltro := "!Empty(L1_MIDIA)" 	
   
    // FILIAL
	If !Empty(MV_PAR01) 
		cFiltro += " .AND. SL1->L1_FILIAL >= '" + MV_PAR01 + "'"  			         
	Endif 
	
	If !Empty(MV_PAR02)
		cFiltro += " .AND. SL1->L1_FILIAL <= '" + MV_PAR02 + "'"           
	Endif
	
	//LOJA
	If !Empty(MV_PAR03) 
		cFiltro += " .AND. SL1->L1_LOJA >= '" + MV_PAR03 + "'"           
	Endif 
	
	If !Empty(MV_PAR04)
		cFiltro += " .AND. SL1->L1_LOJA <= '" + MV_PAR04 + "'"           
	Endif
	
	//CLIENTE
	If !Empty(MV_PAR05) 
		cFiltro += " .AND. SL1->L1_CLIENTE >= '" + MV_PAR05 + "'"            
	Endif  
	
	If !Empty(MV_PAR06)
		cFiltro += " .AND. SL1->L1_CLIENTE <= '" + MV_PAR06 + "'"            
	Endif
	
	//MIDIA
	If !Empty(MV_PAR07) 
		cFiltro += " .AND. SL1->L1_MIDIA >= '" + MV_PAR07 + "'"           
	Endif
	
	If !Empty(MV_PAR08)
		cFiltro += " .AND. SL1->L1_MIDIA <= '" + MV_PAR08 + "'"           
	Endif
	
	//DATA
	If !Empty(MV_PAR09) 
		cFiltro += " .AND. DTOS(SL1->L1_EMISSAO) >= '" + DTOS(MV_PAR09) + "'"           
	Endif      
	
	If !Empty(MV_PAR10)
		cFiltro += " .AND. DTOS(SL1->L1_EMISSAO) <= '" + DTOS(MV_PAR10) + "'"           
	Endif
	
	// TIPO DE VENDA
	If !Empty(MV_PAR11)
	
		Do Case
   			Case MV_PAR11 == 2
   				cFiltro += 	" .AND. Empty(SL1->L1_DOCPED) .AND. Empty(SL1->L1_DOC)" 
   			Case MV_PAR11 == 3                                                                                 
   				cFiltro += 	" .AND. !Empty(SL1->L1_DOC)" 
   			Case MV_PAR11 == 4                                                                                 
   				cFiltro += 	" .AND. !Empty(SL1->L1_DOCPED)" 
		EndCase
		          
	Endif   	
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o filtro e Ordem de acordo com a expressao (somente do SL1)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	oSection1:SetFilter( cFiltro, "L1_FILIAL + L1_MIDIA" )    
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TIPO ANALITICO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR12 == 1	 
	
		DbSelectArea("SL1")
		DbSetOrder(1) 
		
	   	TRPosition():New(oSection1,"SA1", 1, {|| xFilial("SA1") + SL1->L1_CLIENTE } ) 
		TRPosition():New(oSection1,"SUH", 1, {|| xFilial("SUH") + SL1->L1_MIDIA } )
		oSection1:SetLineCondition( {|| !SL1->(EOF()) } ) 		
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TIPO SINTETICO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else 
	
		DbSelectArea("SL1")
		DbSetOrder(1)
			
		TRPosition():New(oSection1,"SUH", 1, {|| xFilial("SUH") + SL1->L1_MIDIA } ) 
		oSection1:SetLineCondition( {|| !SL1->(EOF()) } )	
	EndIf 
	
#ENDIF
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quebra a linha, caso existam muitas colunas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:SetLineBreak()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a impressao dos dados, de acordo com o filtro ou query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Print()    

Return (Nil)