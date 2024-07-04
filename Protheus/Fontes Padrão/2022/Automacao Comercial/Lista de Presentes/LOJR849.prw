#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "LOJR849.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LOJR849  ºAutor  ³Vendas Cliente		 º Data ³  17/02/11   		º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Relatorio de Ranking de Vendas e de Cadastro     		º±±
±±º          ³ Das Listas de Presentes                                    		º±±
±±º          ³ Ranking de Cadastro - Filial que mais teve cadastro        		º±±
±±º          ³ Ranking de Vendas   - Filial que mais Vendeu Produtos de Lista	º±±
±±º          ³                     - Vendedor que mais Vendeu Produtos de Lista º±±
±±º          ³                     - Produtos que mais Venderam em Litas        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA		                                                  	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJR849() 

Local oReport                  	// Variável para Impressão
Local cPerg	  := "LOJR849"     	// Variável para localizar o cadastro de pergunta que será passado para o TReport
Local lLstPre := SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Lista de Presentes já está Ativa               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lLstPre
   MsgAlert(STR0001)	//"O recurso de lista de presente não está ativo ou não foi devidamente aplicado e/ou configurado, impossível continuar!"
   Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//³ CriaSx1 - Cria o Cadastro de Perguntas						 ³
//³ Habilita Pergunte antes dos parâmetros e impressão			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.T.)        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=LJR849Rpt(cPerg)        //// Função para impressão do relatório onde se define Celulas e Funcões
oReport:PrintDialog()	       ///  do TReport

return 
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJR849Rpt()  ºAutor  ³Vendas Cliente		 º Data ³  17/02/11   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que define os itens que serao apresentados				º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cPerg - Variável com o Nome do Cadastro de Perguntas	      		º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA		                                                  	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJR849Rpt(cPerg)

Local oReport	:= NIL				// Objeto relatorio TReport (Release 4)
Local oSection1	:= NIL				// Filial
Local oSection2	:= NIL				// Produtos / Vendedores
Local oSection3	:= NIL				// Produtos / Vendedores
Local cTitulo   := "" 		    	// Titulo do Relatorio  "Relatorio de Vendas x Midia - Sintetico"	
Local oBreak1                   	// Breca a Seção 1 do relatório - Quebra por Filial
Local cAlias1 	:= GetNextAlias()	//Alias do Select para Seção 1
Local cAlias2 	:= GetNextAlias()	//Alias do Select para Seção 2
Local cAlias3 	:= GetNextAlias()	//Alias do Select para Seção 3

Default cPerg 	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ MV_PAR01          // Ranking de ?   Vendas / Cadastro        ³
//³ MV_PAR02          // Filial De  ?                            ³
//³ MV_PAR03          // Filial Ate ?                            ³
//³ MV_PAR04          // Periodo de Venda De ?		             ³
//³ MV_PAR05          // Periodo de Venda ate ?		             ³
//³ MV_PAR06          // Cadastro de Lista - Vendedor De ?       ³
//³ MV_PAR07          // Cadastro de Lista - Vendedor ate ?      ³
//³ MV_PAR08          // Venda Produtos Lista - Vendedor De ?    ³
//³ MV_PAR09          // Venda Produtos Lista - Vendedor ate ?   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Define o Relatório - TReport
If MV_PAR01 = 1
	cTitulo:= STR0002				// "Ranking de Cadastro de Listas de Presentes" 
Else
  	cTitulo := STR0003		//"Ranking de Vendas de Produtos sobre Listas de Presentes"
EndIf
cTitulo:= cTitulo+Space(02)+" -  "+Iif(MV_PAR02=1,STR0038,;
							        Iif(MV_PAR02=2,STR0039,;
							        Iif(MV_PAR02=3,STR0040,STR0041)))

oReport:= TReport():New("LOJR849",cTitulo,"",{|oReport| LJR849Imp( oReport, cPerg, cAlias1, cAlias2,;
																	 cAlias3 )} ) 
oReport:SetPortrait()		//Escolher o padrão de Impressao como Retrato
oReport:nFontBody   := 9
oReport:nLineHeight := 50
oReport:cFontBody   := "Arial"

oReport:EndReport(.T.)     //Define se o totalizador será impresso no final do relatório

If MV_PAR01 = 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
	//³Secao 1 - Ranking de Cadastro / Vendas Lista de Presentes     ³
	//³Define a Seção que irá Imprimir o Relatorio                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
	oSection1:= TRSection():New( oReport,cTitulo,{ "ME1", "SA3", "ME3" })
	oSection1:SetLineStyle()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
		//³Celulas - Pai - Define Celulas Impressas no Relatório		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
		If MV_PAR02 > 1
			TRCell():New(oSection1,"ME1_FILORI"	,"ME1",STR0004)						//Filial do Cadastro	-- "Filial"
			TRCell():New(oSection1,"M0_FILIAL"	,"SM0","",,70)			           	//Nome Da Filial do Cadastro
			TRCell():New(oSection1,"TOTALFIL"	,"ME1","",,35)				   		//Total da Filial do Cadastro
			oSection1:Cell('TOTALFIL'):hide()
        Else
			TRCell():New(oSection1,"ME1_FILORI"	,"ME1",STR0004)						//Filial do Cadastro	-- "Filial"
			TRCell():New(oSection1,"M0_FILIAL"	,"SM0","",,35)			           	//Nome Da Filial do Cadastro
			TRCell():New(oSection1,"TOTALFIL"	,"ME1",STR0055,,4)				   	//Total da Filial do Cadastro
		EndIf

		oSection2:= TRSection():New(oSection1,cTitulo,{ "SL2", "SA3", "SD2" })
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
			//³Celulas - Pai - Define Celulas Impressas no Relatório		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe		

			If MV_PAR02 = 1           	///// Ranking Produto
				TRCell():New(oSection2,"ME2_PRODUT"   ,"ME2",STR0014)			    	       			//"Produto"
				TRCell():New(oSection2,"ME2_DESCRI"   ,"ME2",STR0015)				    	       		//"Descricao"
			ElseIf MV_PAR02 = 2			///// Ranking Vendedor
		   		TRCell():New(oSection2,"ME1_VEND"   ,"ME1",STR0005)           							//"Cod Vendedor"
		   		TRCell():New(oSection2,"A3_NOME"    ,"SA3",STR0006,,50)       							//"Nome do Vendedor"
			ElseIf MV_PAR02 = 3			///// Ranking Tipo Evento
				TRCell():New(oSection2,"ME1_TPEVEN"   ,"ME1",STR0018)             						//"Evento"
				TRCell():New(oSection2,"ME3_DESCRI"   ,"ME3",STR0019)			         				//"Nome"
			ElseIf MV_PAR02 = 4			///// Ranking Tipo Lista    1 = Crédito, 2 = Entrega, 3 = Entrega programada
				TRCell():New(oSection2,"ME1_TIPO"     ,"ME1",STR0020)	             					//"Tipo Lista"
				TRCell():New(oSection2,"DESCRI"       ,"ME1"," ") 				        	   			//"Descricao"
			EndIF	
           	If MV_PAR02 = 2			///// Ranking Vendedor
           			    //////  TI4501 - Estouro da picture 
				TRCell():New(oSection2,"TOTALCAD"   ,"SA3" ,"Vlr Cadastro","@e 9,999,999,999.99",,,,'RIGHT',,'RIGHT')      
				TRCell():New(oSection2,"TOTALVEND"   ,"SA3","Valor  Venda",STR0010,,,,'RIGHT',,'RIGHT')      
	        Else
				TRCell():New(oSection2,"TOTALVEND"   ,"SA3",STR0013,STR0009,,,,'RIGHT',,'RIGHT')      //"Total do Vendedor"  "999999"
            EndIf

			oBreak1 := TRBreak():New(oSection1,oSection1:Cell("ME1_FILORI"),STR0012,.F.) 				//"TOTAL DA FILIAL : "
			If MV_PAR02=2
				TRFunction():New(oSection2:Cell("TOTALCAD"),NIL,"SUM",oBreak1,,"@e 9,999,999,999.99",,.F.,.F.,.F.)		//"@e 99,999,999.99"
				TRFunction():New(oSection2:Cell("TOTALVEND"),NIL,"SUM",oBreak1,,STR0010,,.F.,.F.,.F.)		//"@e 999,999.99"
			Else
				TRFunction():New(oSection2:Cell("TOTALVEND"),NIL,"SUM",oBreak1,,STR0022,,.F.,.F.,.F.)		//"99999"
			Endif	
Else  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
	//³Secao 1 - Ranking de Cadastro / Vendas Lista de Presentes     ³
	//³Define a Seção que irá Imprimir o Relatorio                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
	oSection1:= TRSection():New( oReport,cTitulo,{ "SL2", "SA3", "SD2" })
	oSection1:SetLineStyle()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
		//³Celulas - Pai - Define Celulas Impressas no Relatório		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
		TRCell():New(oSection1,"L2_FILIAL" ,"SL2",STR0004)            	       			//Filial da Venda
		TRCell():New(oSection1,"M0_FILIAL"	,"SM0","  ",,45) 			    	        //Filial do Cadastro		
		
		oSection2:= TRSection():New(oSection1,cTitulo,{ "SL2", "SA3", "SD2" })
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
			//³Celulas - Pai - Define Celulas Impressas no Relatório		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe		
			If MV_PAR02 = 1           	///// Ranking Produto
				TRCell():New(oSection2,"L2_PRODUTO"   ,"SL2",STR0014)			           			//"Produto"
				TRCell():New(oSection2,"L2_DESCRI"    ,"SL2",STR0015)				           		//"Descricao"
			ElseIf MV_PAR02 = 2			///// Ranking Vendedor
				TRCell():New(oSection2,"L2_VEND"      ,"SL2",STR0016)             		   			//"Cod Vendedor"
				TRCell():New(oSection2,"A3_NOME"      ,"SA3",STR0017)     		 					//"Nome do Vendedor"
			ElseIf MV_PAR02 = 3			///// Ranking Tipo Evento
				TRCell():New(oSection2,"ME1_TPEVEN"   ,"ME1",STR0018)             					//"Evento"
				TRCell():New(oSection2,"ME3_DESCRI"   ,"ME3",STR0019)			         			//"Nome"
			ElseIf MV_PAR02 = 4			///// Ranking Tipo Lista    1 = Crédito, 2 = Entrega, 3 = Entrega programada
				TRCell():New(oSection2,"ME1_TIPO"     ,"ME1",STR0020)	             				//"Tipo Lista"
				TRCell():New(oSection2,"DESCRI"       ,"ME1"," ") 				        			//"Descricao"
			EndIF	
			
			TRCell():New(oSection2,"TOTALQTD","SL2",STR0013,STR0022,,,,'RIGHT',,'RIGHT') 	   		//"Quantidade"
			If MV_PAR02 = 1           	///// Ranking Produto
		   		TRCell():New(oSection2,"PRECOMED","SL2","Vlr Unit Medio",STR0010,,,,'RIGHT',,'RIGHT')			//Valor Medio
		   	Endif	
			TRCell():New(oSection2,"TOTALVAL","SL2",STR0021,STR0010,,,,'RIGHT',,'RIGHT') 			//"Valor Da Venda"

		oBreak1 := TRBreak():New(oSection1,oSection1:Cell("L2_FILIAL"),STR0012,.F.) 				//"TOTAL DA FILIAL : "
		TRFunction():New(oSection2:Cell("TOTALQTD"),NIL,"SUM",oBreak1,,STR0022,,.F.,.F.,.F.)		//"99999"
		TRFunction():New(oSection2:Cell("TOTALVAL"),NIL,"SUM",oBreak1,,STR0010,,.F.,.F.,.F.)		//"@e 999,999.99"

Endif	

Return(oReport) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJR849Imp()  ºAutor  ³Vendas Cliente		 º Data ³  17/02/11   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina responsavel pela impressao do relatorio					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oReport - Objeto do Relatório									º±±
±±º			   cPerg   - Cadastro de Perguntas para o Filtro do Relatório		º±±
±±º			   cAlias1 - Area para o Select da Primeira Seção - Cabeçalho		º±±
±±º			   cAlias2 - Area para o Select da Segunda  Seção - Participante	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA		                                                  	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJR849Imp(oReport, cPerg, cAlias1, cAlias2,;
						  cAlias3)
Local oSection1	 := oReport:Section(1)           	    			/// Seção do Cabeçalho
Local oSection2	 := oReport:Section(1):Section(1) 	    			/// Seção do Cabeçalho
Local oSection3	 := oReport:Section(1):Section(1):Section(1)  	    /// Seção do Cabeçalho
Local cNomFil 	 := ""												//// Variavel para imprimir nome da loja
Local cFiltro    := ""     						  				 	/// Variável que Filtrará o Select Principal - Seção 1 
Local cFiltroC   := ""  				   						   	/// Variável que Filtrará o Select Principal - Seção 1 
Local cL1_NumOrig := Space(TamSx3("L1_NUMORIG")[1])				///Numero origem do orçamento
Local cL1_OrcRes  := Space(TamSx3("L1_ORCRES")[1])					///numero do orcamento
Local nColV															/// coluna do vendedora no treport
Local cME1_VEND														///vendedor da lista
Local nValVend 														///valor da venda
Local nContArray :=0												///contagem do vendedor
Local aSomVend   := {}												/// soma da venda
Local nTotQGeral :=0												/// total qtde geral
Local nTotVGeral :=0												/// total valor geral
Local nTotalList :=0												/// total da lista
Local nCol															/// coluna do treport
Local nRow															/// linha do treport
Local nCont															/// contador de vendedores
Local nValList														/// valor da lista
Local cPict1														/// pict para o treport
Local cPict2														/// pict para o treport 
Local cSpace := ""

Default oReport	:= NIL
Default cPerg	:= ""
Default cAlias1	:= ""
Default cAlias2	:= ""
Default cAlias3	:= ""

MakeSqlExpr(cPerg)

if TRepInUse() 
	If MV_PAR01 = 1
		// Filtro por FILIAL de Cadastro de Lista - De Ate
		If !Empty(MV_PAR03) .OR. !Empty(MV_PAR04)
			cFiltro += 	" AND (ME2_FILORI BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') "
			cFiltroC += " AND (ME2_FILORI BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') "
		Endif

		//Filtro por DATA De Cadastro De Ate
		If !Empty(MV_PAR05) .OR. !Empty(MV_PAR06)
			cFiltro += 	" AND (ME1_EMISSA BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "') "
			cFiltroC += " AND (L1_EMISNF BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "') "
		Endif

		//Filtro por Vendedor De Cadastro - De Ate
		If !Empty(MV_PAR07) .OR. !Empty(MV_PAR08)
			cFiltro += 	" AND (ME1_VEND BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "') "
			cFiltroC += " AND (ME1_VEND BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "') "
		Endif

		cFiltro := "%"+cFiltro+"%"    
		cFiltroC := "%"+cFiltroC+"%"    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query secao 1 - 						 ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		BEGIN REPORT QUERY oSection1
			BeginSQL alias cAlias1
					SELECT DISTINCT    
					   ME1_FILORI,
					   " " M0_FILIAL,
					   COUNT(*) TOTALFIL 
				FROM   %table:ME2% ME2 INNER JOIN %table:ME1% ME1 
				ON	   ME1.ME1_FILIAL=ME2.ME2_FILIAL AND 
					   ME1.ME1_CODIGO=ME2.ME2_CODIGO 
				WHERE  ME1.D_E_L_E_T_= ' ' 
				GROUP BY ME1_FILORI
				ORDER BY TOTALFIL DESC
			EndSql 
		END REPORT QUERY oSection1	
        
		If MV_PAR02 = 1   ///// Ranking de Produto
			BEGIN REPORT QUERY oSection2
				BeginSQL alias cAlias2
					SELECT 	ME2_FILORI ME1_FILORI,
							ME2_PRODUT,
							ME2_DESCRI,
							COUNT(*) TOTALVEND
					FROM %table:ME2% ME2
					INNER JOIN
					    (SELECT DISTINCT ME2_CODIGO MEX_CODIGO,ME2_FILIAL MEX_FILIAL
					     FROM 	%table:ME2% ME2
					     INNER JOIN %table:ME1% ME1 ON ME1.ME1_FILIAL=ME2.ME2_FILIAL AND ME1.ME1_CODIGO=ME2.ME2_CODIGO
					     WHERE ME2.%notDel% AND ME2_FILORI =%report_param:(cAlias1)->ME1_FILORI% %Exp:cFiltro%) MEX
				    ON MEX.MEX_CODIGO=ME2.ME2_CODIGO AND MEX.MEX_FILIAL=ME2.ME2_FILIAL					
					WHERE ME2.%notDel% AND ME2_FILORI =%report_param:(cAlias1)->ME1_FILORI%
					GROUP BY ME2_PRODUT,ME2_FILORI,ME2_DESCRI
			     	ORDER BY ME2_FILORI,TOTALVEND Desc
				EndSql 
			END REPORT QUERY oSection2			
	 	ElseIf MV_PAR02 = 2     ///// Ranking de Vendedor
			BEGIN REPORT QUERY oSection2
				BeginSQL alias cAlias2
					SELECT ME1_FILORI,ME1_VEND,A3_NOME,TOTALCAD,TOTALVEND,(TOTALVEND*-1) ORDEM					
					FROM (	SELECT ME2_VEND ME1_VEND,ME2_FILORI ME1_FILORI,SUM(ME2_QTDSOL*SB0.B0_PRV1) TOTALCAD
						    FROM %table:ME2% ME2
						    JOIN %table:SB0% SB0 ON SB0.B0_COD=ME2.ME2_PRODUT AND SB0.B0_FILIAL=ME2.ME2_FILORI AND SB0.%notDel%
						    JOIN %table:ME1% ME1 ON ME1.ME1_FILIAL=ME2.ME2_FILIAL AND ME1.ME1_CODIGO=ME2.ME2_CODIGO
						    WHERE ME2.%notDel% AND ME2_FILORI = %report_param:(cAlias1)->ME1_FILORI% %Exp:cFiltro%
							GROUP BY ME2_VEND,ME2_FILORI) AUX1 
					LEFT JOIN 
						(SELECT ME2_VEND,	   
					       ME2_FILORI,
					       SUM(L2_VLRITEM) TOTALVEND
						FROM %table:ME1% ME1
					    JOIN %table:ME2% ME2 ON ME2.ME2_CODIGO = ME1.ME1_CODIGO AND ME2.ME2_FILIAL = ME1.ME1_FILIAL AND ME2_FILORI = %report_param:(cAlias1)->ME1_FILORI% AND ME2.%notDel%
					    JOIN %table:ME4% ME4 ON ME2_CODIGO = ME4_CODIGO AND ME2.ME2_ITEM = ME4.ME4_ITLST AND ME2.ME2_PRODUT = ME4.ME4_COD AND ME4_TIPO = 1 AND ME4_TIPREG <> 2 AND ME4.%notDel%
					    INNER JOIN %table:SL2% SL2 ON SL2.L2_FILIAL=ME4_FILMOV AND SL2.L2_NUM = ME4_NUMORC AND SL2.L2_ITEM = ME4_ITORC AND SL2.%notDel%
					    INNER JOIN %table:SL1% SL1 ON SL1.L1_NUM = SL2.L2_NUM AND SL1.L1_FILIAL = SL2.L2_FILIAL  AND SL1.%notDel% %Exp:cFiltroC%
					WHERE ME1.%notDel%
					GROUP BY ME2_FILORI,ME2_VEND
					) AUX2 ON AUX1.ME1_FILORI=AUX2.ME2_FILORI AND AUX1.ME1_VEND=AUX2.ME2_VEND
					LEFT JOIN %table:SA3% SA3 ON SA3.A3_COD = ME1_VEND AND SA3.%notDel%
					ORDER BY ORDEM
				EndSql 
			END REPORT QUERY oSection2 

	   ElseIf MV_PAR02 = 3  /// Tipo de Evento
			BEGIN REPORT QUERY oSection2
				BeginSQL alias cAlias2
					SELECT 	ME2_FILORI ME1_FILORI,
							ME1_TPEVEN,
							ME3_DESCRI,
							COUNT(*) TOTALVEND
					FROM %table:ME1% ME1 
					INNER JOIN
					    (SELECT DISTINCT ME2_CODIGO,ME2_FILIAL,ME2_FILORI
					    FROM %table:ME2% ME2
					    INNER JOIN %table:ME1% ME1 ON ME1.ME1_FILIAL=ME2.ME2_FILIAL AND ME1.ME1_CODIGO=ME2.ME2_CODIGO
					    WHERE ME2.%notDel% AND ME2_FILORI =%report_param:(cAlias1)->ME1_FILORI% %Exp:cFiltro%) AUX3
					ON ME1_CODIGO=AUX3.ME2_CODIGO AND ME1_FILIAL=AUX3.ME2_FILIAL
					LEFT JOIN %table:ME3% ME3 ON ME3.ME3_CODIGO = ME1.ME1_TPEVEN AND ME3.%notDel%					
					WHERE ME1.%notDel% %Exp:cFiltro% 
					GROUP BY ME1_TPEVEN,ME2_FILORI,ME3_DESCRI
			     	ORDER BY ME2_FILORI,TOTALVEND Desc
				EndSql 
			END REPORT QUERY oSection2 
		ElseIf MV_PAR02 = 4			///// Ranking Tipo Lista    1 = Crédito, 2 = Entrega, 3 = Entrega programada
			BEGIN REPORT QUERY oSection2
				BeginSQL alias cAlias2
					SELECT 	ME2_FILORI ME1_FILORI,
							ME1_TIPO,
							%Exp:cSpace% DESCRI,
							COUNT(*) TOTALVEND
					FROM %table:ME1% ME1
					INNER JOIN
					    (SELECT DISTINCT ME2_CODIGO,ME2_FILIAL,ME2_FILORI
					    FROM %table:ME2% ME2
					    INNER JOIN %table:ME1% ME1 ON ME1.ME1_FILIAL=ME2.ME2_FILIAL AND ME1.ME1_CODIGO=ME2.ME2_CODIGO
					    WHERE ME2.%notDel% AND ME2_FILORI =%report_param:(cAlias1)->ME1_FILORI% %Exp:cFiltro%) AUX4
					ON ME1_CODIGO=AUX4.ME2_CODIGO AND ME1_FILIAL=AUX4.ME2_FILIAL
					LEFT JOIN %table:ME3% ME3 ON ME3.ME3_CODIGO = ME1.ME1_TPEVEN AND ME3.%notDel%					
					GROUP BY ME1_TIPO,ME2_FILORI
			     	ORDER BY ME2_FILORI,TOTALVEND Desc
				EndSql 
			END REPORT QUERY oSection2 
		EndIf			
	Else
		// Filtro por FILIAL de Venda de Produto da Lista - De Ate
		If !Empty(MV_PAR03) .OR. !Empty(MV_PAR04)
			cFiltro += 	" AND (L2_FILIAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') "
		Endif
		//Filtro por DATA De Venda de Produto da Lista De Ate
		If !Empty(MV_PAR05) .OR. !Empty(MV_PAR06)
			cFiltro += 	" AND (L1_EMISNF BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "') "
		Endif

		//Filtro por Vendedor De Produto da  - De Ate
		If !Empty(MV_PAR07) .OR. !Empty(MV_PAR08)
			cFiltro += 	" AND (L2_VEND BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "') "
		Endif

		cFiltro := "%"+cFiltro+"%"    

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query secao 1 - 						 ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		BEGIN REPORT QUERY oSection1
			BeginSQL alias cAlias1
				SELECT 	L2_FILIAL,
						" " M0_FILIAL,					
						L2_FILIAL ME1_FILORI,
						//////  TI4501 - Valor diferente do relatório de vendas analitico
						SUM(ME4_VALOR) TOTALVAL,
						SUM(ME4_QUANT) TOTALQTD
		        FROM %table:ME4% ME4
		        INNER JOIN %table:ME2% ME2 ON ME2.ME2_CODIGO = ME4.ME4_CODIGO AND ME2.ME2_FILIAL = ME4.ME4_FILIAL AND ME2.ME2_PRODUT = ME4.ME4_COD AND ME2.%notDel%
				INNER JOIN %table:SL2% SL2 ON SL2.L2_FILIAL=ME4_FILMOV AND SL2.L2_NUM = ME4_NUMORC AND SL2.%notDel%
			    INNER JOIN %table:SL1% SL1 ON SL1.L1_NUM = SL2.L2_NUM AND SL1.L1_FILIAL = SL2.L2_FILIAL AND SL1.%notDel%
				WHERE ME4.%notDel% AND ME4_TIPO = 1 AND ME4_TIPREG <> 2 %Exp:cFiltro% 					
				GROUP BY L2_FILIAL
		     	ORDER BY TOTALVAL Desc
			EndSql 
		END REPORT QUERY oSection1
		If MV_PAR02 = 1   ///// Ranking de Produto
			BEGIN REPORT QUERY oSection2
				BeginSQL alias cAlias2
			        SELECT
			            L2_FILIAL,
						L2_PRODUTO,
						L2_DESCRI,
						//////  TI4501 - Valor diferente do relatório de vendas analitico
						SUM(ME4.ME4_VALOR) TOTALVAL,
						SUM(ME4.ME4_QUANT) TOTALQTD,
			            (SUM(ME4.ME4_VALOR)/SUM(ME4.ME4_QUANT)) PRECOMED
			        FROM %table:ME4% ME4
			        INNER JOIN %table:ME1% ME1 ON ME1.ME1_CODIGO = ME4.ME4_CODIGO AND ME1.ME1_FILIAL = ME4.ME4_FILIAL AND ME1.%notDel%	
					Left  JOIN %table:ME2% ME2 ON ME2.ME2_CODIGO = ME4.ME4_CODIGO AND ME2.ME2_FILIAL = ME4.ME4_FILIAL AND ME2.ME2_PRODUT = ME4.ME4_COD AND ME2.%notDel%
					INNER JOIN %table:SL2% SL2 ON SL2.L2_FILIAL=ME4_FILMOV AND SL2.L2_NUM = ME4_NUMORC AND SL2.L2_ITEM = ME4_ITORC AND SL2.%notDel%
				    INNER JOIN %table:SL1% SL1 ON SL1.L1_NUM = SL2.L2_NUM AND SL1.L1_FILIAL = SL2.L2_FILIAL AND SL1.%notDel%
					WHERE ME4.%notDel% AND ME4_TIPO = 1 AND ME4_TIPREG <> 2 AND L2_FILIAL =%report_param:(cAlias1)->L2_FILIAL% %Exp:cFiltro%  
					GROUP BY L2_PRODUTO,L2_FILIAL,L2_DESCRI
			     	ORDER BY L2_FILIAL,TOTALVAL Desc
				EndSql 
			END REPORT QUERY oSection2
	 	ElseIf MV_PAR02 = 2
			BEGIN REPORT QUERY oSection2
				BeginSQL alias cAlias2
					SELECT 	L2_FILIAL,
							L2_VEND,
							A3_NOME,
							//////  TI4501 - Valor diferente do relatório de vendas analitico
							SUM(ME4.ME4_VALOR) TOTALVAL,
							SUM(ME4.ME4_QUANT) TOTALQTD
					        FROM %table:ME4% ME4	
			        INNER JOIN %table:ME1% ME1 ON ME1.ME1_CODIGO = ME4.ME4_CODIGO AND ME1.ME1_FILIAL = ME4.ME4_FILIAL AND ME1.%notDel%	
					Left  JOIN %table:ME2% ME2 ON ME2.ME2_CODIGO = ME4.ME4_CODIGO AND ME2.ME2_FILIAL = ME4.ME4_FILIAL AND ME2.ME2_PRODUT = ME4.ME4_COD AND ME2.%notDel%
					INNER JOIN %table:SL2% SL2 ON SL2.L2_FILIAL=ME4_FILMOV AND SL2.L2_NUM = ME4_NUMORC AND SL2.L2_ITEM = ME4_ITORC AND SL2.%notDel%
				    INNER JOIN %table:SL1% SL1 ON SL1.L1_NUM = SL2.L2_NUM AND SL1.L1_FILIAL = SL2.L2_FILIAL AND SL1.%notDel%
					LEFT JOIN %table:SA3% SA3 ON SA3.A3_COD = SL2.L2_VEND AND SA3.%notDel%
					WHERE ME4.%notDel% AND ME4_TIPO = 1 AND ME4_TIPREG <> 2 AND L2_FILIAL =%report_param:(cAlias1)->L2_FILIAL% %Exp:cFiltro% 							
					GROUP BY L2_VEND,L2_FILIAL,A3_NOME
			     	ORDER BY L2_FILIAL,TOTALVAL Desc
				EndSql 
			END REPORT QUERY oSection2 
	 	ElseIf MV_PAR02 = 3
			BEGIN REPORT QUERY oSection2
				BeginSQL alias cAlias2
					SELECT 	L2_FILIAL,
							ME1_TPEVEN,
							ME3_DESCRI,
							//////  TI4501 - Valor diferente do relatório de vendas analitico
							SUM(ME4.ME4_VALOR) TOTALVAL,
							SUM(ME4.ME4_QUANT) TOTALQTD							
			        FROM %table:ME4% ME4	
			        INNER JOIN %table:ME1% ME1 ON ME1.ME1_CODIGO = ME4.ME4_CODIGO AND ME1.ME1_FILIAL = ME4.ME4_FILIAL AND ME1.%notDel%	
					Left  JOIN %table:ME2% ME2 ON ME2.ME2_CODIGO = ME4.ME4_CODIGO AND ME2.ME2_FILIAL = ME4.ME4_FILIAL AND ME2.ME2_PRODUT = ME4.ME4_COD AND ME2.%notDel%
 					INNER JOIN %table:SL2% SL2 ON SL2.L2_FILIAL=ME4_FILMOV AND SL2.L2_NUM = ME4_NUMORC AND SL2.L2_ITEM = ME4_ITORC AND SL2.%notDel%
				    INNER JOIN %table:SL1% SL1 ON SL1.L1_NUM = SL2.L2_NUM AND SL1.L1_FILIAL = SL2.L2_FILIAL AND SL1.%notDel%
					LEFT JOIN %table:ME3% ME3 ON ME3.ME3_CODIGO = ME1.ME1_TPEVEN AND ME3.%notDel%
					WHERE ME4.%notDel% AND ME4_TIPO = 1 AND ME4_TIPREG <> 2 AND L2_FILIAL =%report_param:(cAlias1)->L2_FILIAL% %Exp:cFiltro% 							
					GROUP BY ME1_TPEVEN,L2_FILIAL,ME3_DESCRI
			     	ORDER BY L2_FILIAL,TOTALVAL Desc
				EndSql 
			END REPORT QUERY oSection2 
		ElseIf MV_PAR02 = 4			///// Ranking Tipo Lista    1 = Crédito, 2 = Entrega, 3 = Entrega programada
			BEGIN REPORT QUERY oSection2
				BeginSQL alias cAlias2
					SELECT 	L2_FILIAL,
							ME1_TIPO,
							Space(10) AS DESCRI,
							//////  TI4501 - Valor diferente do relatório de vendas analitico
							SUM(ME4.ME4_VALOR) TOTALVAL,
							SUM(ME4.ME4_QUANT) TOTALQTD
							
			        FROM %table:ME4% ME4	
			        INNER JOIN %table:ME1% ME1 ON ME1.ME1_CODIGO = ME4.ME4_CODIGO AND ME1.ME1_FILIAL = ME4.ME4_FILIAL AND ME1.%notDel%	
					Left  JOIN %table:ME2% ME2 ON ME2.ME2_CODIGO = ME4.ME4_CODIGO AND ME2.ME2_FILIAL = ME4.ME4_FILIAL AND ME2.ME2_ITEM = ME4.ME4_ITLST AND ME2.ME2_PRODUT = ME4.ME4_COD AND ME2.%notDel%
 					INNER JOIN %table:SL2% SL2 ON SL2.L2_FILIAL=ME4_FILMOV AND SL2.L2_NUM = ME4_NUMORC AND SL2.L2_ITEM = ME4_ITORC AND SL2.%notDel%
				    INNER JOIN %table:SL1% SL1 ON SL1.L1_NUM = SL2.L2_NUM AND SL1.L1_FILIAL = SL2.L2_FILIAL AND SL1.%notDel%
					WHERE ME4.%notDel% AND ME4_TIPO = 1 AND ME4_TIPREG <> 2 AND L2_FILIAL =%report_param:(cAlias1)->L2_FILIAL% %Exp:cFiltro%							
					GROUP BY ME1_TIPO,L2_FILIAL
			     	ORDER BY L2_FILIAL,TOTALVAL Desc
				EndSql 
			END REPORT QUERY oSection2 
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³ Impressão do Relatório enquanto não for FIM de Arquivo - cAlias1³
	//³ e não for cancelada a impressão									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !oReport:Cancel() .AND. (cAlias1)->(!Eof())   //Regra de impressao 

		oSection1:Init() 
		oSection1:SetHeaderSection(.T.)

		DbSelectArea("SM0")
		DbSetOrder(1)
		SM0->(Dbseek(cEmpAnt+(cAlias1)->ME1_FILORI))
		cNomFil:=Alltrim(SM0->M0_NOME)+"/"+Alltrim(SM0->M0_FILIAL)
		oSection1:Cell('M0_FILIAL'):SetValue(cNomFil)
		oSection1:Cell('M0_FILIAL'):lBold = .t.

		oSection2:ExecSql()
		If  !(cAlias2)->(Eof())
			oSection1:PrintLine()
			If MV_PAR01 =1 
				nCol2:=oSection1:Cell('TOTALFIL'):ColPos()+350
				If MV_PAR02 == 1
					nTotalList+=(cAlias1)->TOTALFIL
				EndIf
			EndIf

		EndIf		
		oSection2:Init()
		oSection2:SetHeaderSection(.T.)
			  		
		//IMPRESSAO SECAO 2
		While !oReport:Cancel() .And. !(cAlias2)->(Eof())
			If MV_PAR01 = 1
				If MV_PAR02 = 2			///// Ranking Vendedor
					If Empty((cAlias2)->ME1_VEND)
					   oSection2:Cell('ME1_VEND'):SetValue(STR0058)    /// "Sem Vendedor"
					Else
					   oSection2:Cell('ME1_VEND'):SetValue((cAlias2)->ME1_VEND)    /// "Sem Vendedor"
					Endif
		  		EndIf
		 	EndIf
			oSection2:PrintLine()
			If MV_PAR01 = 1
				nTotQGeral +=(cAlias2)->TOTALVEND
				If MV_PAR02 = 2
					nTotalList +=(cAlias2)->TOTALCAD
					nTotVGeral +=(cAlias2)->TOTALVEND
					If (cAlias2)->TOTALVEND>0
						AADD(aSomVend , {ME1_VEND, TOTALVEND} )
					EndIf
				Endif	
			Else
				nTotQGeral +=(cAlias2)->TOTALQTD
				nTotVGeral +=(cAlias2)->TOTALVAL
			Endif
			(cAlias2)->(DbSkip())
		End
		If MV_PAR01 = 1
			nCol1:=oSection2:Cell('TOTALVEND'):ColPos()
			cPict1:=STR0023
			If MV_PAR02 == 2 && Vendedor
			    nColV:=oSection2:Cell('ME1_VEND'):ColPos()
				nCol1:=oSection2:Cell('TOTALCAD'):ColPos()
				cPict1:=STR0026
				nCol2:=oSection2:Cell('TOTALVEND'):ColPos()
			   cPict2:=STR0026
			Endif
			//cPict2:=STR0024
		ElseIf MV_PAR01 = 2
			nCol1:=oSection2:Cell('TOTALQTD'):ColPos()+2
			cPict1:=STR0025
		    nCol2:=oSection2:Cell('TOTALVAL'):ColPos()+3
		    cPict2:=STR0026
		EndIf		
		oSection2:Finish()
		oReport:IncMeter()
		(cAlias1)->(DbSkip())
	End
	oSection1:Finish()
	If !Empty(cPict1)
		oReport:PrintText(STR0027)
		oReport:FatLine()
		nRow := oReport:Row()
		If  MV_PAR01 ==1 .AND. MV_PAR02 == 2
		    oReport:PrintText(transform(nTotalList,cPict1),nRow,nCol1)	    
		    oReport:PrintText(transform(nTotVGeral,cPict2),nRow,nCol2)
		    oReport:FatLine()
		    //////  TI4501 - Soma o total por vendedor
	    	ASort(aSomVend,,,{|x,y| x[1]< y[1]})
	    	oReport:SkipLine() 
	    	If Len (aSomVend) > 0      
		    	cME1_VEND = aSomVend[1,1]   
		    Else
		    	cME1_VEND := ""        
		    EndIf
		    nValVend := 0
		    For nContArray=1 to Len(aSomVend)
		    	If cME1_VEND <> aSomVend[nContArray,1]
			    	oReport:SkipLine()
					nRow := oReport:Row()		    	
			    	oReport:PrintText(cME1_VEND,nRow+20,nColV)
			    	oReport:PrintText(TransForm(nValVend,cPict2),nRow,nCol2)
			    	cME1_VEND = aSomVend[nContArray,1]
			    	nValVend := 0
		        EndIf
		        nValVend+=aSomVend[nContArray,2]		        
			Next
	    	oReport:SkipLine()
			nRow := oReport:Row()		    	
	    	oReport:PrintText(cME1_VEND,nRow+20,nColV)
	    	oReport:PrintText(TransForm(nValVend,cPict2),nRow,nCol2)
		    //////  TI4501 - Soma o total por vendedor
        Else
			oReport:PrintText(transform(nTotQGeral,cPict1),nRow,nCol1)
			If MV_PAR01 ==1 
				If MV_PAR02 == 1
					oReport:PrintText(transform(nTotalList,cPict1),nRow,nCol2)
				EndIf
		    Else
				oReport:PrintText(transform(nTotVGeral,cPict2),nRow,nCol2)	    
			EndIf
		Endif		
	EndIf
EndIf
Return