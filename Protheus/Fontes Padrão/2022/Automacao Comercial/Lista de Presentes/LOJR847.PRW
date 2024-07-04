#INCLUDE "Protheus.CH"
#INCLUDE "REPORT.CH" 
#INCLUDE "LOJR847.CH"

Static cSimb  := "("+AllTrim(SuperGetMV("MV_SIMB1",.F., "R$"))+")"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LOJR847  ºAutor  ³Vendas Cliente	     º Data ³  17/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Relatório Acompanhamento das Listas de Eventos   º±±
±±º          ³ Tanto para o Convidado quanto para o Organizador poderem   º±±
±±º          ³ Visualizar os Produtos selecionados                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cCodList - Código da Lista 							      º±±
±±º          ³ Parametro para imprimir a lista direto do Cadastro de      º±±
±±º          ³ Lista - LOJA847                                            º±±
±±º          ³ cFilList - Filial da Lista								  º±±
±±º          ³ Parametro para imprimir a lista direto do Cadastro de      º±±
±±º          ³ Lista - LOJA847                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJR847(cFilList,cCodList)
Local cPerg		:= "LOJR847" // Variável para localizar o cadastro de pergunta que será passado para o TReport
Local lLstPre	:= SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)
Local lImprime	:= .T. 

Default cCodList := ""
Default cFilList := Space(TamSx3("ME1_FILIAL")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Lista de Presentes já está Ativa               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lLstPre
   MsgAlert(STR0001)		//"O recurso de lista de presente não está ativo ou não foi devidamente aplicado e/ou configurado, impossível continuar!"
   Return .F.
Endif


If empty(cCodList)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//³ CriaSx1 - Cria o Cadastro de Perguntas						 ³
	//³ Habilita Pergunte antes dos parâmetros e impressão			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lImprime := Pergunte(cPerg,.T.)        
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lImprime
	LJR847Rpt(cPerg,cFilList,cCodList)     	 //// Função para impressão do relatório onde se define Celulas e Funcões
EndIf

Return  Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJR847Rpt()ºAutor  ³Vendas Cliente      º Data ³  17/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Rotina que define os itens que serao apresentados		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ oReport - Objeto Relatorio								   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cPerg    - grupo de pergunte para o filtro dos dados		   º±±
±±º          ³ cCodList - Código da Lista 							       º±±
±±º          ³ cFilList - Filial da Lista								   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJR847Rpt(cPerg,cFilList,cCodList)
Local oReport	:= NIL				// Objeto relatorio TReport (Release 4)
Local oSection1	:= NIL	   			// (Dados da Lista - Cabeçalho)
Local oSection2	:= NIL	   			// Objeto secao 1 do relatorio (Participantes da Lista) 
Local oSection3 := NIL 	   			// Objeto secao 2 do relatorio (Categoria)  
Local oSection4 := NIL 	   			// Objeto secao 3 do relatorio (Produtos)
Local oSection5 := NIL 				// Dados da Lista - Cabeçalho

Local nSize    				 		// Variavel para tamanho de impressao no cabçalho
Local cTitulo   := ""	 	 	  	// Titulo do Relatorio  "Acompanhamento da Lista de Evento"	
Local lOrg		:= .F.		 		// Variável para definir se o Solicitante do Relatório é o Organizador ou Convidado
Local lMsg		:= .F.       	    // Variável para definir se será impressa a Mensagem do Convidado no Relatório do Organizador
Local lAssin 	:= .F.		 		// Variavel para impressão das Assinaturas
Local lImprList := .F.				// Variável para impressão da lista cadastrada para o Organizador
Local lPageBreak:= .T.

Local oSumCatSol  					// Soma por Categoria o Valor dos Produtos Solicitados
Local oSumQtCatSol					// Soma por Categoria a Quantidade de Produtos Solicitados 
Local oSumCatComp					// Soma por Categoria o Valor dos Produtos Comprados - Só  para o Organizador
Local oSumQtCatComp		   			// Soma por Categoria a Quantidade de Produtos Comprados - Só para o Organizador

Local oSumLstSol			 		// Soma na Lista o Valor dos Produtos Solicitados
Local oSumQtLstSol			   		// Soma na Lista a Quantidade de Produtos Solicitados 
Local oSumLstComp					// Soma na Lista o Valor dos Produtos Compradas - Só para o Organizador
Local oSumQtLstComp			   		// Soma na Lista a Quantidade de Produtos Compradas - Só para o Organizador

Local oBreak1                   	// Breca a Seção 1 do relatório - Quebra por Código da Lista
Local oBreak3   					// Breca a Seção 3 do relatório - Quebra por Categoria
Local oBreak4   					// Breca a Seção 1 do relatório - Final do Relatório

Local cAlias1 	 := GetNextAlias()	///Dados da Lista	- Alias do Select para Seção 1 - Cabeçalho
Local cAlias2  	 := GetNextAlias()	///Participantes	- Alias do Select para Seção 2
Local cAlias3  	 := GetNextAlias()	///Categoria		- Alias do Select para Seção 3
Local cAlias4  	 := GetNextAlias()	///Produtos			- Alias do Select para Seção 4
Local cAlias5  	 := GetNextAlias()	///Produtos			- Alias do Select para Seção 5

Public INCLUI	 := .F.				// Variavel para checagem de remetente de Mensagens

Default cPerg    := ""
Default cFilList := ""
Default cCodList := ""

If Empty(cCodList)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ MV_PAR01          // Organizador /  Convidado                ³
	//³ MV_PAR02          // Filial De  ?                            ³
	//³ MV_PAR03          // Filial Ate ?                            ³
	//³ MV_PAR04          // Codigo Lista Protheus De ?              ³
	//³ MV_PAR05          // Codigo Lista Protheus ate ?             ³
	//³ MV_PAR06          // Cliente de ?                            ³
	//³ MV_PAR07          // Cliente ate ?                           ³
	//³ MV_PAR08          // Data do Evento de ?                     ³
	//³ MV_PAR09          // Data do Evento ate ?                    ³
	//³ MV_PAR10          // Data de Abertura da Lista de ?          ³
	//³ MV_PAR11          // Data de Abertura da Lista ate ?         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR01 == 1				// Parâmetro que Define se o relatório é para o Convidado ou para o Organizador
		cTitulo := STR0002			//"Lista de Presentes - Convidado"
		lOrg	:= .F.
		nSize   := 25
	ElseIf MV_PAR01 == 2
		cTitulo := STR0003			//"Lista de Presentes - Organizador"
		lOrg	:= .T. 
		nSize   := 40
		If MsgYesNo(STR0004)		// Pergunta para Define se Imprime Mensagem para o Organizador  -- "Deseja imprimir as mensagens dos convidados ?"
			lMsg := .T.
			If MsgYesNo(STR0064)	// Pergunta para Define se Imprime Assinaturas
				lAssin := .T.
			EndIf
		EndIf
	Endif
Else
	cTitulo := STR0003				//"Lista de Presentes - Organizador"
	lOrg	:= .T. 
	nSize   := 40
    lImprList := .T.
EndIf
//Define o Relatorio - TReport
		 									
oReport:= TReport():New("LOJR847",cTitulo,"",{|oReport| LJR847Imp(oReport, cPerg, cAlias1,cAlias2,;
	 									  							cAlias3,cAlias4,cAlias5,;
							 										lOrg,lMsg,lAssin,cFilList,;
							 										cCodList,lImprList)})
If lOrg
	oReport:SetLandscape()		//Escolher o padrão de Impressao como Paisagem 
EndIf
oReport:cFontBody   := "Verdana"

oReport:EndReport (.F.)     //Define se o totalizador será impresso no final do relatório
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
//³Secao 1 - Pai - Cabecalho da lista de presentes               ³
//³Define a Secao que ira Imprimir o Cabecalho da Lista          ³
//³Relatorio de Convidade e de Organizador						 ³
//³Com os dados Principais do Evento                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
oSection1:= TRSection():New(oReport,cTitulo,{ "ME1", "SA1" })
oSection1:SetLineStyle()
oSection1:PageBreak(lPageBreak)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
	//³Celulas - Pai - Define Celulas Impressas no Cabecalho da lista³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
	TRCell():New(oSection1,"ME1_CODIGO","ME1" ,STR0005+Space(12-Len(STR0005))+".",,nSize,,,,,)//Numero da Lista  --  "Codigo Lista"+Space(02)+"."
	TRCell():New(oSection1,"ME3_DESCRI","ME1" ,STR0006+Space(14-Len(STR0006))+".",,nSize,,,,,)//"Nome do Evento."
	TRCell():New(oSection1,"ME1_TIPO"  ,"ME1" ,STR0007+Space(12-Len(STR0007))+".",,nSize,,{|| LJR847X3Bx((cAlias1)->ME1_TIPO,"ME1_TIPO")},,,)//"Tipo Lista"+Space(05)+"."
	TRCell():New(oSection1,"ME1_DTEVEN","ME1" ,STR0008+Space(14-Len(STR0008))+".",,nSize,,,,,)//"Data Evento" +Space(03)+"."
	TRCell():New(oSection1,"ME1_STATUS","ME1" ,STR0009+Space(12-Len(STR0009))+".",,nSize,,{|| LJR847X3Bx((cAlias1)->ME1_STATUS,"ME1_STATUS")},,,)//"Status Lista"+Space(02)+"."
	TRCell():New(oSection1,"ME1_EMISSA","ME1" ,STR0010+Space(14-Len(STR0010))+".",,nSize,,,,,)//"Data Abertura"+Space(01)+"."
	TRCell():New(oSection1,"A1_NOME"   ,"ME1" ,STR0011+Space(12-Len(STR0011))+".",,nSize,,,,,)//"Organizador"+Space(03)+"."
	TRCell():New(oSection1,"ME1_LOCAL" ,"ME1" ,STR0012+Space(14-Len(STR0012))+".",,nSize,,,,,)//"Local Evento" +Space(02)+"."

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 2 - Filha - Participantes                                                        ³
	//³Imprime os Participantes do Evento                                                     ³
	//³é uma seção diferente pois o arquivo pode ter mais de 1 registro para o mesmo evento   ³
	//³Com o Nome dos Participantes                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oSection2:= TRSection():New(oSection1,cTitulo,{ "ME5", "MEE" })
    oSection2:SetLinesBefore(0)
    oSection2:SetLineStyle()
    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
		//³Celulas - Filha - Define Celulas Impressas na Seção de Participantes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe 
		TRCell():New(oSection2,"ME5_DESCRI","ME5" ,STR0013,,35,,,,,)//"Participante"+Space(02)+"."
    	TRCell():New(oSection2,"MEE_NOME"  ,"MEE" ,STR0014,,35,,,,,)//"Nome Particip"+Space(02)+"."
    	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Secao 3 - Neta - Categoria		                                                     ³
		//³Imprime as Categorias dos Produtos                                                    ³
		//³Seção para quebra e Ordem do relatório                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection3:= TRSection():New(oSection2,cTitulo,{ "ACU" })
		oSection3 :SetLineStyle() 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
			//³Celulas - Neta - Define Celulas Impressas na Seção Categoria		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
			TRCell():New(oSection3,"ACU_DESC","ACU" ,STR0015,,,,,,,)//"Categoria"
			TRCell():New(oSection3,"ACU_COD" ,"ACU" ,,,,,,,,)//Codigo Categoria
			oSection3:Cell("ACU_COD"):Hide()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Secao 4 - BisNeta - Produtos                                                          ³
			//³Imprime os Produtos da Lista                                                          ³
			//³Para o Convidado Imprime os Produtos Selecionados pelo Organizador com os 			 ³
			//³Valores do Produto vigente na Loja de Emissao										 ³
			//³Para o Organizador Imprime os Produtos Selecionados e os as vendas 		 			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSection4:= TRSection():New(oSection3,cTitulo,{ "ME2", "SL2", "SA1" })
			If !lOrg				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Celulas - BisNeta- Define Celulas Impressas na Seção Produtos	   ³
				//³Celulas para o Relatório do CONVIDADO							   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TRCell():New(oSection4,"ME2_ITEM"  ,"ME2",STR0016,,06,,,,,)//"Item"produto 
				TRCell():New(oSection4,"ME2_PRODUT","ME2",STR0017,,17,,,,,)//"Produto"
				TRCell():New(oSection4,"ME2_DESCRI","ME2",STR0018,,35,,,,,)//"Descricao Produto"
				TRCell():New(oSection4,"ME2_VALUNI","ME2",STR0019+cSimb,,30,,{||Lj843PrcV((cAlias4)->ME2_PRODUT)},'RIGHT',,'RIGHT')//"Vlr Venda"
				TRCell():New(oSection4,"ME2_QTDSOL","ME2",STR0020,STR0061,23,,,'RIGHT',,'RIGHT')//"Qtde Cadastro"
				TRCell():New(oSection4,"ME2_QTDATE","ME2",STR0021,STR0061,26,,,'RIGHT',,'RIGHT')//"Qtde Presenteada"
				TRCell():New(oSection4,"SALDO"     ,"ME2",STR0022,STR0062,10,,,'RIGHT',,'RIGHT')//"Saldo"
				
				oSection5:= TRSection():New(oSection4,cTitulo,{ "SL2" })

					TRCell():New(oSection3,"L1_CLIENTE","SL1",STR0023,,08,,,,,)//"Saldo"

	     	Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Celulas - BisNeta- Define Celulas Impressas na Seção Produtos	   ³
				//³Celulas para o Relatório do ORGANIZADOR							   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lImprList
					TRCell():New(oSection4,"ME2_ITEM"   ,"ME2",STR0016,,07,,,,,)//"Item"
					TRCell():New(oSection4,"ME2_PRODUT" ,"ME2",STR0017,,15,,,,,)//"Produto"
					TRCell():New(oSection4,"ME2_DESCRI" ,"ME2",STR0018,,35,,,,,)//"Descricao Produto"
					TRCell():New(oSection4,"ME2_QTDSOL" ,"SL2",STR0025,STR0060,21,,,'RIGHT',,'RIGHT')//"Qtd Solicitada"
					TRCell():New(oSection4,"ME2_VALUNI" ,"ME2",STR0024+cSimb,,37,,{|| Lj843PrcV((cAlias4)->ME2_PRODUT)},'RIGHT',,'RIGHT')////"Vlr Produto Lista"	
	                //Totalizador por quebra de categoria
					oBreak3 := TRBreak():New(oSection3,oSection3:Cell("ACU_COD"),STR0027+cSimb,.F.)			//"TOTAL DA CATEGORIA"
					TRFunction():New(oSection4:Cell("ME2_VALUNI"),NIL,"SUM",oBreak3,,,,.F.,.F.,.F.)
					TRFunction():New(oSection4:Cell("ME2_QTDSOL"),NIL,"SUM",oBreak3,,,,.F.,.F.,.F.)

				Else
					TRCell():New(oSection4,"ME2_ITEM"  ,"ME2",STR0016,,07,,,,,)//"Item"
					TRCell():New(oSection4,"ME2_PRODUT","ME2",STR0017,,15,,,,,)//"Produto"
					TRCell():New(oSection4,"ME2_DESCRI","ME2",STR0018,,35,,,,,)//"Descricao Produto"
					TRCell():New(oSection4,"ME2_VALUNI","ME2",STR0024+cSimb,,43,,{|| Lj843PrcV((cAlias4)->ME2_PRODUT)},'RIGHT',,'RIGHT')////"Vlr Produto Lista"
					TRCell():New(oSection4,"L2_QUANT"  ,"SL2",STR0025,STR0060,27,,,'RIGHT',,'RIGHT')//"Qtd da Venda"
					TRCell():New(oSection4,"L2_VLRITEM","SL2",STR0019+cSimb,,30,,,'RIGHT',,'RIGHT')//"Vlr da Venda"
					TRCell():New(oSection4,"L2_VRUNIT" ,"SL2",STR0026+cSimb,,35,,,'RIGHT',,'RIGHT')//"Vlr do Bonus"
					TRCell():New(oSection4,"A1_NOME"   ,"SA1",STR0023,,49,,,,,)//"Cliente"
					//TRCell():New(oSection4,"L2_ENTREGA","SL2","Status",,16,,{|| fTrazTipo((cAlias4)->L2_ENTREGA)},,,)//"Tipo"
					TRCell():New(oSection4,"ME4_TIPREG","ME4","Status",,16,,{|| fTrazTipo((cAlias4)->ME4_TIPREG,(cAlias4)->L2_DOC,(cAlias1)->ME1_TIPO)},,,)//"Tipo"
	
	                //Totalizador por quebra de categoria
					oBreak3 := TRBreak():New(oSection3,oSection3:Cell("ACU_COD"),STR0027+cSimb,.F.)			//"TOTAL DA CATEGORIA"
					TRFunction():New(oSection4:Cell("L2_VLRITEM"),NIL,"SUM",oBreak3,,,,.F.,.F.,.F.)
					TRFunction():New(oSection4:Cell("L2_QUANT"),NIL,"SUM",oBreak3,,,,.F.,.F.,.F.)
					TRFunction():New(oSection4:Cell("L2_VRUNIT"),NIL,"SUM",oBreak3,,,,.F.,.F.,.F.)
	    		EndIf
		    EndIf		
			/////////   Novo Relatório
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
			//³Secao 5 - Pai - Mensagens dos Convidados - Cabeçalho          ³
			//³Define a Seção que irá Imprimir o Cabeçalho da Lista          ³
			//³Com os dados Principais do Evento                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
			//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
			oSection5:= TRSection():New(oSection1,cTitulo,{ "SL2" })
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
			//³Secao 5 - Neta - Mensagens dos Convidados - Mensagens         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
				TRCell():New(oSection5,"ME2_ITEM"  ,"ME2",STR0016,,005,,,,,)//Item
				TRCell():New(oSection5,"ME2_DESCRI","ME2",STR0017,,030,,,,,)//Produto
				If lAssin
					TRCell():New(oSection5,"L2_REMLPRE","SL2",STR0028,,030,,{|| Lj843RtSYP(SL2->L2_REMLPRE)},,,)//"Assinatura" 
				EndIf																
				TRCell():New(oSection5,"YP_TEXTO"  ,"SL2",STR0029,,100,,,,,)//"Mensagem"

		oReport:PrintDialog()	      	    	 ///  do TReport
			    
Return(oReport) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LP847PReport()     ºAutor  ³Vendas Cliente	     º Data ³  17/02/11                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³ LP847PReport(oReport, cPerg, cAlias1,cAlias2,;				                        º±±
±±º							cAlias3,cAlias4,cAlias5,lOrg,lMsg,lAssin)			  					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oReport  - Objeto do Relatório													 	º±±
±±º			   cPerg    - Cadastro de Perguntas para o Filtro do Relatório							º±±
±±º			   cAlias1  - Area que será usada para o Select da Primeira Seção - Cabeçalho			º±±
±±º			   cAlias2  - Area que será usada para o Select da Segunda  Seção - Participante		º±±
±±º			   cAlias3  - Area que será usada para o Select da Terceira Seção - Categoria			º±±
±±º			   cAlias4  - Area que será usada para o Select da Quarta   Seção - Produtos			º±±
±±º			   cAlias5  - Novo Relatório para as Mensagens dos Convidados     - Cabeçalho			º±±
±±º			   cAlias6  - Area que será usada para o Select da Sexta    Seção - Participante		º±±
±±º			   cAlias7  - Area que será usada para o Select da Setima   Seção - Mensagens			º±±
±±º			   lOrg     - Verifica se o relatório é do Convidado ou Organizador                     º±±
±±º			   lMsg     - Verifica se o Organizador deseja imprimir as Mensagens dos Convidados		º±±
±±º			   lAssin   - Verifica se Imprime Assinatura											º±±
±±º			   cCodList - Variável para impressão de determinada lista								º±±
±±º			   cFilList - Variável para impressão de determinada lista								º±±
±±º			   lImprList- Variável para imprimir a lista cadastrada para o cCodList					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina responsavel pela impressao do relatorio  										º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                          									º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function LJR847Imp(oReport, cPerg  , cAlias1, cAlias2,;
						  cAlias3, cAlias4, cAlias5, lOrg   ,;
						  lMsg   , lAssin ,cFilList, cCodList,;
						  lImprList)

Local oSection1	  	:= oReport:Section(1)                    							/// Seção do Cabeçalho
Local oSection2	  	:= oReport:Section(1):Section(1)									/// Seção do Participante
Local oSection3   	:= oReport:Section(1):Section(1):Section(1)						/// Seção do Categoria
Local oSection4   	:= oReport:Section(1):Section(1):Section(1):Section(1)				/// Seção do Produtos
Local oSection5   	:= oReport:Section(1):Section(2)  /// Seção do Cabeçalho Mensagens

Local cFiltro     	:= ""     	// Variável que Filtrará o Select Principal - Seção 1 
						 		// e a partir deste Select serão feitos os das outras seções
Local cCampo      	:= ""		// Variável que Controla o Alias5
Local cCodigo     	:= ""		// Variável que Controla o Alias5    
Local aCampo      	:= {}		// Variável que Controla a Impressao no array
Local cMensCab    	:= ""		// Variável que Concatena as mensagem
Local aMensCab    	:= {}		// Array que divide a mensagem em linhas
Local nCont						// Contador para o Array
Local nRow                      // Linha para PrintText
Local lFooter	  	:= .T.  	// Variavel para pular a pg

Local nPosMens					// Variavel da posição da procura no array
Local nPBonus            		// Porcentagem de Bonus do Organizador para calcular o Valor de Credito
Local nVlBonus			  		// Valor do Credito gerado do Bonus para Organizador
Local cRemetent  	:= ""

Local nValorItem 	:= 0		// Variavel Soma Total Lista 
Local nValorQtde 	:= 0		// Variavel Soma Total Lista 
Local nValorUnit 	:= 0		// Variavel Soma Total Lista 

Local cL1_NumOrig 	:= Space(TamSx3("L1_NUMORIG")[1])
Local cL1_OrcRes  	:= Space(TamSx3("L1_ORCRES")[1])
Local cYP_Filial  	:= xFilial("SYP")
Local cQuerySel		:= ""               
Local cAliasTMP		:= GetNextAlias()  /// Alias temporario para o select 

Default oReport		:= NIL
Default cPerg		:= ""
Default cAlias1		:= ""
Default cAlias2		:= ""
Default cAlias3		:= ""
Default cAlias4		:= ""
Default cAlias5		:= ""
Default lOrg		:= .T.
Default lMsg		:= .T.
Default lAssin		:= .T.
Default cFilList	:= "" 
Default cCodList	:= ""
Default lImprList	:= .F.


MakeSqlExpr(cPerg)

cFilList := IIf(SX2Modo("ME1") == "C",xFilial("ME1"),cFilList)

	
	If !empty(cCodList)
	   cFiltro += " AND (ME1_FILIAL = '" + cFilList + "') "	
	   cFiltro += " AND (ME1_CODIGO = '" + cCodList + "') "
	Else	
		// Filtro por FILIAL De Ate
		If !Empty(MV_PAR02) .OR. !Empty(MV_PAR03)
			cFiltro += 	" AND (ME1_FILIAL BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "') "
		Endif
		// Filtro por CODIGO LISTA PROTHEUS De Ate
		If !Empty(MV_PAR04) .OR. !Empty(MV_PAR05)
			cFiltro += 	" AND (ME1_CODIGO BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "') "           
		Endif
		//Filtro por CODIGO DO CLIENTE De Ate
		If !Empty(MV_PAR06) .OR. !Empty(MV_PAR07)
			cFiltro += 	" AND (ME1_CODCLI BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "') "           
		Endif
		//Filtro por DATA DO EVENTO De Ate
		If !Empty(MV_PAR08) .OR. !Empty(MV_PAR09)
			cFiltro += 	" AND (ME1_DTEVEN BETWEEN '" + DTOS(MV_PAR08) + "' AND '" + DTOS(MV_PAR09) + "') "
		Endif
		//Filtro por DATA DE ABERTURA De Ate
		If !Empty(MV_PAR10) .OR. !Empty(MV_PAR11)
			cFiltro += 	" AND (ME1_EMISSA BETWEEN '" + DTOS(MV_PAR10) + "' AND '" + DTOS(MV_PAR11) + "') "
		Endif
	EndIf

	cFiltro := "%"+cFiltro+"%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query secao 1 - Cabeçalho 			 ³ 
	//³Igual para o Convidado e Organizador	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection1
		BeginSQL alias cAlias1    
			SELECT ME1_FILIAL,
				ME1_CODIGO,
				ME1_LOCAL,
				ME1_DTEVEN,
				ME1_CODCLI,
				ME1_STATUS,
				ME1_EMISSA,
				ME1_TIPO,
				ME1_PBONUS,
	     		ME1_TPEVEN,
	     		ME3_DESCRI,
	     		A1_COD,
	     		A1_NOME
	     	FROM %table:ME1% ME1
	     		LEFT JOIN %table:ME3% ME3 ON ME1.ME1_TPEVEN = ME3.ME3_CODIGO AND ME3.%notDel%
	     		LEFT JOIN %table:SA1% SA1 ON ME1.ME1_CODCLI = SA1.A1_COD AND ME1.ME1_LOJCLI = SA1.A1_LOJA AND SA1.%notDel%
				WHERE ME1.%notDel%  %Exp:cFiltro% 	    	     
	     	ORDER BY ME1_FILIAL,ME1_CODIGO
		EndSql 
	END REPORT QUERY oSection1 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query secao 2 - participantes         ³
	//³Igual para o Convidado e Organizador	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection2	
		BeginSQL alias cAlias2 		
			SELECT MEE_NOME,ME5_DESCRI
		  	FROM %table:MEE% MEE
	  			INNER JOIN %table:ME5% ME5 ON ME5.ME5_CODIGO = MEE.MEE_CODATO AND ME5.%notDel% 
			WHERE 
				MEE.%notDel% AND 
				MEE_CODLIS = %report_param: (cAlias1)-> ME1_CODIGO% 	    	     
		    ORDER BY MEE_NOME
		EndSql 	
	END REPORT QUERY oSection2    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o produto nao esteja categorizado, ³
	//³o relatorio nao sera exibido            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuerySel	:= "SELECT ACV_CODPRO, ME2_CODIGO,ME2_PRODUT FROM " +RetSQLName("ACV") + " RIGHT JOIN  "+ RetSQLName("ME2") +  " ON ACV_CODPRO = ME2_PRODUT " 	
 	
 	If !Empty(MV_PAR04) .OR. !Empty(MV_PAR05)
 		cQuerySel	+= " WHERE ME2_CODIGO BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' AND "+RetSQLName("ME2")+".D_E_L_E_T_ = '' AND " + RetSQLName("ME2") + ".D_E_L_E_T_ = ''" 
 	ElseIf !Empty(cCodList)
 		cQuerySel	+= " WHERE "+RetSQLName("ME2")+".D_E_L_E_T_ = ' ' AND " + RetSQLName("ACV") + ".D_E_L_E_T_ = ' ' AND ME2_CODIGO = '" + cCodList + "'"
 	Else
 	  	cQuerySel	+= " WHERE "+RetSQLName("ME2")+".D_E_L_E_T_ = ' ' AND " + RetSQLName("ACV") + ".D_E_L_E_T_ = ' '"         
 	EndIf
	cQuerySel   += " ORDER BY ACV_CODPRO "
	cQuerySel	:= ChangeQuery(cQuerySel)
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySel),cAliasTMP,.F.,.T.)
	
	If (cAliasTMP) ->(EOF())
		MsgAlert (STR0069 + STR0070 + (cAliasTMP) -> (ME2_CODIGO) + ".") //STR0069 - Para imprimir este Relatorio e necessario que os produtos das Listas de Presente estejam categorizados. //STR0070 - Verifique a Lista de Presentes 
		Return .T. 				
	Else	
		While !(cAliasTMP) ->(EOF()) 		
			If Empty((cAliasTMP)->(ACV_CODPRO))
				MsgAlert (STR0069 + STR0070 + (cAliasTMP) -> (ME2_CODIGO) + ".") //STR0069 - Para imprimir este Relatorio e necessario que os produtos das Listas de Presente estejam categorizados. //STR0070 - Verifique a Lista de Presentes 
				Return .T. 				
			Else
				(cAliasTMP) ->(DbSkip()) 			
			EndIf
		End
	EndIf
	(cAliasTMP) ->(dbCloseArea())                                              
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query secao 3 - categorias   		 ³
	//³Igual para o Convidado e Organizador	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection3	
		BeginSQL alias cAlias3 		
			SELECT DISTINCT
				ACU.ACU_COD,
				ACU.ACU_DESC,
				ME2.ME2_CODIGO	     		
 	     	FROM %table:ME2% ME2	 	     	 	    	 	
 	    	 	INNER JOIN %table:ACV% ACV ON ACV.ACV_CODPRO = ME2.ME2_PRODUT AND ACV.%notDel%
 	    	 	INNER JOIN %table:ACU% ACU ON ACU.ACU_COD = ACV.ACV_CATEGO AND ACU.%notDel%
				WHERE 
					ME2.%notDel% AND 
					ME2_CODIGO = %report_param: (cAlias1)-> ME1_CODIGO% 
	     	ORDER BY ACU_DESC
		EndSql 	
	END REPORT QUERY oSection3                        
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query secao 4 - produtos       		 	 ³
	//³Diferente para o Convidado e Organizador	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If !lOrg //convidado
		BEGIN REPORT QUERY oSection4	
			BeginSQL alias cAlias4 		
				SELECT  ME2_PRODUT,
						ME2_DESCRI,
						ME2_VALUNI,
						ME2_QTDSOL,
						ME2_QTDATE,
						ME2_STATUS,
						ME2_QTDSOL-ME2_QTDATE AS SALDO						     		
	 	     	FROM %table:ME2% ME2	 	     	 	    	 	
	 	    	 	INNER JOIN %table:ACV% ACV ON ACV.ACV_CODPRO = ME2.ME2_PRODUT AND ACV.%notDel%
					WHERE ME2.%notDel% AND 
						  ME2_CODIGO = %report_param: (cAlias1)-> ME1_CODIGO% AND
                          ME2_FILIAL = %report_param:(cAlias1)->ME1_FILIAL% AND
						  ACV_CATEGO = %report_param: (cAlias3)-> ACU_COD% 
		     	ORDER BY ME2_PRODUT
			EndSql 	
		END REPORT QUERY oSection4
	Else //Organizador 
		If !lImprList
			BEGIN REPORT QUERY oSection4	
				BeginSQL alias cAlias4 
				SELECT	DISTINCT
						'Sele4' AS ITEM,
						ME2_PRODUT,
						ME2_CODIGO,					
						ME2_ITEM,
						ME2_DESCRI,					
						ME2_VALUNI,
						ME2_QTDSOL,
						ME2_QTDATE,
						L2_QUANT,
						L2_VLRITEM,
						L1_DOC,
						L1_SERIE,
						L1_CLIENTE,
						A1_NOME,
						L2_VRUNIT,
						ME2_ORIGEM,
						ME2_STATUS,
						L2_ENTREGA,
						L2_DOC,
						ME4_TIPREG
			 	FROM %table:ME2% ME2
				 	 LEFT JOIN %table:ACV% ACV ON ACV.ACV_CODPRO = ME2.ME2_PRODUT AND ACV.%notDel% 
			 	 	 LEFT JOIN %table:ME4% ME4 ON ME2_CODIGO = ME4_CODIGO AND ME2.ME2_ITEM = ME4.ME4_ITLST AND ME2.ME2_PRODUT = ME4.ME4_COD AND ME4_TIPO = '1' AND ME4.%notDel% 
			 	 	 LEFT JOIN %table:SL2% SL2 ON SL2.L2_FILIAL=ME4_FILMOV AND SL2.L2_NUM = ME4_NUMORC AND SL2.L2_ITEM = ME4_ITORC AND SL2.%notDel% 
					 LEFT JOIN %table:SL1% SL1 ON SL1.L1_NUM = SL2.L2_NUM AND SL1.L1_FILIAL = SL2.L2_FILIAL  AND SL1.%notDel%
					 							  //SL1.L1_NUMORIG = %Exp:cL1_NumOrig% AND
					 							  //SL1.L1_ORCRES  = %Exp:cL1_OrcRes%
					 LEFT JOIN %table:SA1% SA1 ON SL1.L1_CLIENTE = SA1.A1_COD AND SL1.L1_LOJA = SA1.A1_LOJA AND SA1.%notDel%
				WHERE ME2.%notDel% AND ME2_CODIGO = %report_param:(cAlias1)->ME1_CODIGO% AND
				                       ME2_FILIAL = %report_param:(cAlias1)->ME1_FILIAL% AND
									   ACV_CATEGO = %report_param:(cAlias3)->ACU_COD%									   
				ORDER BY ME2_PRODUT,ITEM
				EndSql 												
			END REPORT QUERY oSection4
		Else
			BEGIN REPORT QUERY oSection4	
				BeginSQL alias cAlias4 
				SELECT	'Sele4' AS ITEM,
						ME2_PRODUT,
						ME2_CODIGO,					
						ME2_ITEM,
						ME2_DESCRI,					
						ME2_VALUNI,
						ME2_QTDSOL,
						ME2_QTDATE
			 	FROM %table:ME2% ME2
				 	 LEFT JOIN %table:ACV% ACV ON ACV.ACV_CODPRO = ME2.ME2_PRODUT AND ACV.%notDel% 
				WHERE ME2.%notDel% AND ME2_CODIGO = %report_param:(cAlias1)-> ME1_CODIGO% AND
				                       ME2_FILIAL = %report_param:(cAlias1)->ME1_FILIAL% AND
									   ACV_CATEGO = %report_param:(cAlias3)-> ACU_COD%  
				ORDER BY ME2_PRODUT,ME2_ITEM
				EndSql 												
			END REPORT QUERY oSection4

		EndIf			
		If lMsg
			BEGIN REPORT QUERY oSection5
				BeginSQL alias cAlias5
				SELECT	'Sele5' AS ITEM,
						L2_CODLPRE,
						L2_MSMLPRE,
						L1_CLIENTE,
						ME2_ITEM,
						ME2_DESCRI,
						A1_NOME,
						YP_TEXTO,
						L2_REMLPRE
			 	FROM %table:ME2% ME2
			 	 	 INNER JOIN %table:ME4% ME4 ON ME2_CODIGO = ME4_CODIGO AND ME2.ME2_ITEM = ME4.ME4_ITLST AND ME2.ME2_PRODUT = ME4.ME4_COD AND ME4_TIPO = '1' AND ME4.%notDel% 
			 	 	 INNER JOIN %table:SL2% SL2 ON SL2.L2_FILIAL=ME4_FILMOV AND SL2.L2_NUM = ME4_NUMORC AND SL2.L2_ITEM = ME4_ITORC AND SL2.%notDel% 
					 INNER JOIN %table:SL1% SL1 ON SL1.L1_NUM = SL2.L2_NUM AND SL1.L1_FILIAL = SL2.L2_FILIAL AND SL1.%notDel%			 	
					 INNER JOIN %table:SA1% SA1 ON SL1.L1_CLIENTE = SA1.A1_COD AND SL1.L1_LOJA = SA1.A1_LOJA AND SA1.%notDel%
	 		 		 INNER JOIN %table:SYP% SYP ON SL2.L2_MSMLPRE  = SYP.YP_CHAVE AND SYP.YP_FILIAL = %Exp:cYP_Filial% AND SYP.%notDel% 					 
				WHERE ME2.ME2_CODIGO = %report_param:(cAlias1)->ME1_CODIGO% AND
                      ME2.ME2_FILIAL = %report_param:(cAlias1)->ME1_FILIAL%
		  		ORDER BY ME2_CODIGO,ME2_ITEM 
				EndSql 												
			END REPORT QUERY oSection5
         Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³ Impressão do Relatorio enquanto nao for FIM de Arquivo - cAlias1	³
	//³ e nao for cancelada a impressao										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !oReport:Cancel() .AND. (cAlias1)->(!Eof())   //Regra de impressao 
		nValorItem := 0
		nValorQtde := 0
		nValorUnit := 0
		oSection1:Init()
		oSection1:SetHeaderSection(.T.)	
		/// Executa a Select da Seção 2
		nPBonus := (cAlias1)->ME1_PBONUS
		oSection2:ExecSql()			
		
		If  !(cAlias2)->(Eof()) 
			oSection1:PrintLine()
		EndIf
		
		//IMPRESSAO SECAO 2
		While !oReport:Cancel() .And. !(cAlias2)->(Eof())
			nRow := oReport:ROW()
			oReport:PrintText(STR0030+".:"+alltrim((calias2)->ME5_DESCRI),,oSection1:Cell('ME1_CODIGO'):ColPos())	//'Participante'+Space(02)+'.:'
			oReport:PrintText(STR0031+Space(14-Len(STR0031))+".:"+(calias2)->MEE_NOME,nRow,oSection1:Cell('ME3_DESCRI'):ColPos()-2)		//'Nome'+Space(10)+'.:'
			(cAlias2)->(DbSkip())
			oReport:SkipLine()
		End
		///oSection2:Finish()
		oReport:FatLine()
		oReport:IncMeter()
		
		/// Executa a Select da Seção 3			                    			
		oSection3:ExecSql() 	
		
		//IMPRESSAO SECAO 3
		While !oReport:Cancel() .And. !(cAlias3)->(Eof())
			If (cAlias1)-> ME1_CODIGO == (cAlias3)-> ME2_CODIGO			
				oSection3:Init()		
				oSection3:PrintLine()
				/// Executa a Select da Seção 4			
				oSection4:ExecSql()			
				//IMPRESSAO SECAO 4
				//(cAlias4)->(TCSetField(cAlias4,"ME2_VALUNI","N",12,2))
				While !oReport:Cancel() .And. !(cAlias4)->(Eof())
					oSection4:Init()
					If lOrg
						If !lImprList
							If !Empty((cAlias4)->A1_NOME)
								oSection4:Cell('A1_NOME'):SetValue((cAlias4)->L1_CLIENTE+"  - "+(cAlias4)->A1_NOME)
							Else
		 						oSection4:Cell('A1_NOME'):SetValue(Space(40))
							Endif
							If Empty((cAlias4)->L1_DOC)
								nVlBonus :=  (((cAlias4)->L2_VLRITEM*nPBonus)/100)
							Else
								nVlBonus := 0
							EndIf
							oSection4:Cell('L2_VRUNIT'):SetValue(nVlBonus)
							nValorItem += (cAlias4)->L2_VLRITEM
							nValorQtde += (cAlias4)->L2_QUANT
							nValorUnit += nVlBonus
						Else

							nVlBonus := ((cAlias4)->ME2_VALUNI * (cAlias4)->ME2_QTDSOL)
							oSection4:Cell('ME2_VALUNI'):SetValue(nVlBonus)
							nValorItem += ((cAlias4)->ME2_VALUNI * (cAlias4)->ME2_QTDSOL)
							nValorQtde += (cAlias4)->ME2_QTDSOL
						EndIf
					Endif
					oSection4:PrintLine()
					(cAlias4)->(DbSkip())
				End      
				oSection4:Finish()
				(cAlias3)->(DbSkip())
				oReport:SkipLine()
				oReport:SkipLine()
			EndIf
		End
		oSection3:Finish()
		If !lImprList
			If lOrg .And. nPBonus > 0.00 
				oReport:PrintText(STR0032 + cSimb )		//"TOTAL DA LISTA"+space(02)+":"
				oReport:FatLine()
				nRow := oReport:Row()
				oReport:PrintText(transform(nValorQtde,STR0033),nRow,oSection4:Cell('L2_QUANT'):ColPos())			//"999999999999999"
				oReport:PrintText(transform(nValorItem,STR0063),nRow,oSection4:Cell('L2_VLRITEM'):ColPos())		//"@e 9,99,999,999.99"
				oReport:PrintText(transform(nValorUnit,STR0063),nRow,oSection4:Cell('L2_VRUNIT'):ColPos())        //"@e 9,99,999,999.99"
			EndIf
		Else
			oReport:PrintText(STR0032 + cSimb)		//"TOTAL DA LISTA"+space(02)+":"
			oReport:FatLine()
			nRow := oReport:Row()
			oReport:PrintText(transform(nValorQtde,STR0066),nRow,oSection4:Cell('ME2_QTDSOL'):ColPos())			//"999999999999999"
			oReport:PrintText(transform(nValorItem,STR0034),nRow,oSection4:Cell('ME2_VALUNI'):ColPos())		//"@e 9,99,999,999.99"
	    Endif
		oSection1:Finish()
        oReport:EndPage(lFooter)
		(cAlias1)->(DbSkip())
	End
	
	If lMsg 
		cTitulo := STR0035				///"Lista de Presentes - Organizador - Mensagens"
		oReport:SetTitle(cTitulo)
		oSection1:ExecSql()
		oReport:EndReport (.F.)
		While !oReport:Cancel() .AND. (cAlias1)->(!Eof())   //Regra de impressao 
			oSection1:Init()
			oSection1:SetHeaderSection(.T.)	
			/// Executa a Select da Seção 2
			oSection2:ExecSql()
			
			oSection5:ExecSql()
			
			If  !(cAlias5)->(Eof())
				oSection1:PrintLine()
				//IMPRESSAO SECAO 2
				While !oReport:Cancel() .And. !(cAlias2)->(Eof())
					nRow := oReport:ROW()
					oReport:PrintText(STR0030+".:"+alltrim((calias2)->ME5_DESCRI),,oSection1:Cell('ME1_CODIGO'):ColPos())	//'Participante'+Space(02)+'.:'
					oReport:PrintText(STR0031+Space(14-Len(STR0031))+".:"+(calias2)->MEE_NOME,nRow,oSection1:Cell('ME3_DESCRI'):ColPos()-2)		//'Nome'+Space(10)+'.:'
					(cAlias2)->(DbSkip())
					oReport:SkipLine()
				End
				oReport:FatLine()
				oReport:IncMeter()
			   	/// Executa a Select da Seção 5
			   	
			   	If (cAlias5)->(!Eof())
					While !oReport:Cancel() .And. !(cAlias5)->(Eof())
						oSection5:Init()
						cCodigo := (cAlias5)->L2_CODLPRE
						cCampo:=""
						While (cAlias5)->L2_CODLPRE== cCodigo .And. !(cAlias5)->(Eof())
							If (cAlias5)->L2_CODLPRE+(cAlias5)->L2_MSMLPRE+(cAlias5)->L1_CLIENTE+(cAlias5)->ME2_ITEM==cCampo
							   oSection5:Cell('ME2_ITEM'):SetValue(Space(5))	
							   oSection5:Cell('ME2_DESCRI'):SetValue(Space(30))
							   If lAssin
								   oSection5:Cell('L2_REMLPRE'):SetValue(Space(30))
							   EndIf
							Else
							   cCampo := (cAlias5)->L2_CODLPRE+(cAlias5)->L2_MSMLPRE+(cAlias5)->L1_CLIENTE+(cAlias5)->ME2_ITEM
							   oSection5:Cell('ME2_ITEM'):SetValue((cAlias5)->ME2_ITEM)
							   oSection5:Cell('ME2_DESCRI'):SetValue((cAlias5)->ME2_DESCRI)
							   If lAssin
								   cRemetent:=(cAlias5)->L2_REMLPRE
								   cRemetent:=Lj843RtSYP(cRemetent)
							       If !Empty(cRemetent)
									   oSection5:Cell('L2_REMLPRE'):SetValue(cRemetent)
								   Else
								      oSection5:Cell('L2_REMLPRE'):SetValue((cAlias5)->A1_NOME)
							       EndIF
							   EndIf
							   oReport:SkipLine()
							EndIf
							oSection5:PrintLine()
							(cAlias5)->(DbSkip())
						End
					End	
					oSection5:Finish()		   
				EndIf
				oSection1:Finish()
				oReport:EndPage(lFooter)
			EndIf
			(cAlias1)->(DbSkip())
		End
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJR847X3BxºAutor  ³Vendas Cliente	     º Data ³  28/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a descrição do combo box do campo no SX3            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cCodigo	- Codigo do combo								  º±±
±±º          ³ cCamp	- campo a ser exibido							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJR843                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJR847X3Bx (cCodigo,cCampo)

Local aSX3Box	:= {}	//Array de Opcoes do Combo Box
Local cRet  	:= ""  	//Retorno
Local nPos		:= 0   	//Posicao do array    

Default cCodigo	:= ""
Default cCampo	:= ""

If !Empty(Posicione("SX3", 2, cCampo, "X3CBox()" ))
	aSX3Box	:= RetSx3Box( Posicione("SX3", 2, cCampo, "X3CBox()" ),,, 1 )
	
	nPos := Ascan(aSX3BOX,{|x| x[2]== cCodigo})
	If nPos > 0 
		cRet:= aSX3Box[nPos,3]
	Endif
Endif

If Empty(cRet)
	cRet := cCodigo
Endif

Return Rtrim(cRet)   

Static Function fTrazTipo(pEntr,cDoc,cTipoList)
Local cRet := Iif(Empty(pEntr),Space(10),Iif(pEntr="4".Or. (pEntr=="1" .And. !Empty(cDoc)),STR0067,STR0068))      ///"Retirado"  //"Credito"

If !Empty(pEntr) .And. AllTrim(cTipoList) $ "2/3" .And. Empty(cDoc)  //Entrega ou Entrega programada
	cRet := "Entrega"  
EndIf 

Return cRet
