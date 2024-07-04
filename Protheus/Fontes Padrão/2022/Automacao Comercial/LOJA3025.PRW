#INCLUDE 'PROTHEUS.CH'

Static lCenVenda 	:= SuperGetMv("MV_LJCNVDA",,.F.)                       // Cenarios de vendas
Static lNovRegDesc	:= SuperGetMv("MV_LJRGDES",,.F.) .And. RGVldTable()	// Validacao da Nova Regra de Desconto Ativa
Static lTabEspCli	:= SuperGetMv("MV_CONFCLI",,"N")=="S"	// Indica se utiliza a tabela do cliente

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RGDesIte  ºAutor  ³ Luiz Strele        º Data ³  13/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a verificao de regra de desconto por item.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ RGDesIte()                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ExpC1 - Codigo do produto                                   º±±
±±º          ³ExpC2 - Codigo do cliente                                   º±±
±±º          ³ExpC3 - Tipo do produto no ato da venda (Saldao ou Mostr.)  º±±
±±º          ³ExpC4 - Identificao da loja, para calculo o preco do item.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpN1 - Percentual de desconto a ser aplicada no item       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Sigaloja                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function RGDesIte(cProduto, cCliente, cTipoProd, cLoja, dDataIni, nQtd, lPainel, lPrdRegDes)
Local nDescPer		:= 0		//Retorno da funcao com percentual de desconto
Local cTipoVd  		:= ""		//Guarda o tipo de peca de cada item M=Mostruario|S=Saldao
Local lAcumu   		:= .T.		//Controla se a regra e acumulativa    
Local nCount   		:= 0		//Contador do total de registro da select    
Local cQuery   		:= ""		//Armazena a select
Local aHora    		:= {}		//Vai armanezar a hora de inicio e fim do dia atual da Tabela MB7  
Local nReg     		:= 1		//Contador do registro atual no while dos dados da select  
Local nA       		:= 0		//Contador para laco For
Local aMB8     		:= {}		//Array onde vai armazenar as informacoes da table MB8     
Local nValProd 		:= 0		//Valor Original do produto
Local nValProdA		:= 0		//Valor Alterado do produto     
Local cGrpCli  		:= ""		//Armazena o grupo que o cliente faz parte
Local lValid   		:= .T.		//Controla se a funcao vai ser aplicada, apatir da validacao de desconto
Local lAplReg  		:= .T.		//Controla se a regra vai ser aplicada apartir das validacoes  
Local cCatego  		:= ""		//Armazena a categoria do produto quando existente   
Local lCatego   	:= .F.		//Informa se existe categoria de produto
Local cAliasB1	 	:= "SB1"	// Alias usado na pesquisa da categoria de produto 		               
Local cCampoB1 		:= "SB1->B1_GRUPO" 
Local lAchouRDVld 	:= .F. 									//Indica se achou alguma regra de desconto valida para aplicar
Local lA1_CLIFUN	:= SA1->(ColumnPos("A1_CLIFUN")) > 0 	//Importante: esta validação deve ser mantida, pois este campo existe no compatibilizador da 11.80 e não existe no dicionário da 12
Local cCliFun		:= ""		//Cliente Funcionario
Local lAI0_CLIFU	:= AI0->(ColumnPos("AI0_CLIFUN")) > 0 	//Foi protegido este campo pois este programa vai subir na release 12.1.16 e campo na posterior
Local lFindRegra	:= .F. 									//Verifica se adiciona Regra de Desconto no array aMB8
Local cTabPreco		:= LjXETabPre(cCliente,cLoja)			//Busca tabela de preços utilizada na venda

Default cProduto	:= ""			//Variavel vazia para utilizacao da chamada do painel de gesta                                                                    
Default cCliente	:= ""			//Variavel vazia para utilizacao da chamada do painel de gesta
Default cTipoProd	:= ""			//Variavel vazia para utilizacao da chamada do painel de gesta
Default cLoja		:= ""			//Variavel vazia para utilizacao da chamada do painel de gesta      
Default dDataIni	:= CTOD(" ") 	//Data para validar periodo pelo Painel de Gestao                 
Default nQtd		:= 0			//Quantidade vendida do produto
Default lPainel 	:= .F.			//Saber quando for painel de gestao
Default lPrdRegDes	:= .F.			// Indica se o produto possui alguma Regra de Desconto, independente da quantidade

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for painel de gestao e nao existir as tabelas da regra³
//³ o retorno de desconto sera zerado.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                          
If lPainel .And. !RGVldTable()
	Return(nDescPer)   
EndIf

If nModulo == 23
	cAliasB1 := "SBI" 
	cCampoB1 := "SBI->BI_GRUPO" 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se existir categoria no produto, vai ser salvo nesta var.³
//³para pesquisar nas regras por categoria                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
//Busca se o Produto contem Categoria x Grupo ou Produto

DbSelectArea("ACV")                              
DbSetOrder(5) //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO
If DbSeek(xFilial("ACV")+cProduto)
	cCatego := ACV->ACV_CATEGO 
	lCatego	:= .T.
Else
	DbSelectArea(cAliasB1)        // SBI e SB1                      
	DbSetOrder(1)
	If DbSeek(xFilial(cAliasB1)+cProduto)
		cGrpProduto := &(cCampoB1)   // alias->B?_Grupo
		DbSelectArea("ACV")                              
		DbSetOrder(2)
		If DbSeek(xFilial("ACV")+cGrpProduto)
			cCatego := ACV->ACV_CATEGO 
			lCatego	:= .T.
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena no array todas as informacoes do item:          ³
//³  Produto, categoria, valor e percentual Desc., Cod Regra³
//³Filtro: Codigo do produto                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// MB8 – Produtos/Categ. – Regra Desconto
DbSelectArea("MB8")
DbSetOrder(2) // MB8_FILIAL+MB8_CODPRO
If DbSeek(xFilial("MB8")+cProduto)
	While !MB8->(Eof()) .And. MB8->MB8_FILIAL+AllTrim(MB8->MB8_CODPRO) == xFilial("MB8")+AllTrim(cProduto)
   		If MB8->MB8_TPREGR == "1"				
		   	// MEI – Cabeçalho Regra de Desconto
			DbSelectArea("MEI")
			DbSetOrder(1)//MEI_FILIAL+MEI_CODREG
			If DbSeek(xFilial("MEI")+MB8->MB8_CODREG) .And. (MEI->MEI_ATIVA == "1" .AND.  IIF(!Empty(MEI->MEI_CODTAB), MEI->MEI_CODTAB == cTabPreco, .T.))
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida o dia e horario da regra                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValidPer(MEI->MEI_DATDE, MEI->MEI_DATATE, MEI->MEI_CODREG, dDataIni) //Data Inicial, Data Final, Codigo Regra 

					// Indica que existe Regra de Desconto para o produto, não importando a quantidade
					lPrdRegDes := .T.

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Adiciona ao array as informacoes da tabela MEJ para ser  ³
					//³ ordenado pelo campo MEJ->MEJ_PRINUM (ORDE. DA REGRA)    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					// MEJ – Prioridade da Regra Desconto
					DbSelectArea("MEJ")
					DbSetOrder(2)//MEJ_FILIAL+MEJ_CODREG
					If DbSeek(xFilial("MEJ") + MB8->MB8_CODREG) 

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se a regra e para a filial atual                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
						// MB3 - Filiais/Grupos cadastrados nas Regras
						DbSelectArea("MB3")
						DbSetOrder(1) //MB3_FILIAL+MB3_CODREG+MB3_CODEMP+MB3_CODFIL
						If DbSeek(xFilial("MB3") + MB8->MB8_CODREG + cEmpAnt)

							Do While !MB3->(Eof()) .AND. MB3->MB3_FILIAL+MB3->MB3_CODREG+MB3->MB3_CODEMP == xFilial("MB3")+MB8->MB8_CODREG+cEmpAnt 
								// 1. Tipo Filial
								// 2. Tipo Grupo de Filiais								

								IF MB3->MB3_TIPO == "1"
									If MB3_CODFIL == cFilAnt
										lFindRegra := .T.
									EndIf

								ElseIF MB3->MB3_TIPO == "2"								
									// SAU – Grupo de Filiais
									DbSelectArea("SAU")
									SAU->(dbSetOrder(1))
									IF SAU->( dbSeek( xFilial("SAU") + MB3->MB3_CODGRU ) )             									

										Do While SAU->( !EOF() .And. SAU->AU_FILIAL+AllTrim(SAU->AU_CODGRUP) == xFilial("SAU")+AllTrim(MB3->MB3_CODGRU) )
											If SAU->AU_CODFIL == cFilAnt
												lFindRegra := .T.
												Exit
											EndIf					
											SAU->(DbSkip())
										EndDo

									Endif
								EndIf

								If lFindRegra
									AADD(aMB8,{	MB8->MB8_CODREG	, MEJ->MEJ_PRINUM, MB8->MB8_CODPRO	, MB8->MB8_CATEGO, ;
												MB8->MB8_DESCPR	, MB8->MB8_DESCVL, MEI->MEI_GRPVEN	, MEI->MEI_DESFUN, ;
												MEI->MEI_PRDMOS	, MEI->MEI_PRDSLD, MEI->MEI_ACUMUL	, MEI->MEI_CODCLI, ;
												MEI->MEI_LOJA  	, 0				 , 0				, MB8->MB8_QTDPRO }) 
									lFindRegra := .F.												
								EndIf				

								MB3->(DbSkip())
							EndDo	
						EndIf				
					EndIf
				EndIf
			EndIf
		EndIf
		
		MB8->(DbSkip())
	EndDo
EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena no array todas as informacoes do item:          ³
//³  Produto, categoria, valor e percentual Desc., Cod Regra³   
//³Filtro: Codigo da categoria                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCatego
	// MB8 – Produtos/Categ. – Regra Desconto
	DbSelectArea("MB8")
	DbSetOrder(3)	// MB8_FILIAL+MB8_CATEGO
	If DbSeek(xFilial("MB8")+cCatego)
		While !MB8->(Eof()) .And. AllTrim(MB8->MB8_CATEGO) == AllTrim(cCatego)
			If MB8->MB8_TPREGR == "1"
				// MEI – Cabeçalho regra de desconto
				DbSelectArea("MEI")
				DbSetOrder(1)//MEI_FILIAL+MEI_CODREG
				If DbSeek(xFilial("MEI")+MB8->MB8_CODREG) .And. (MEI->MEI_ATIVA == "1")
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida o dia e horario da regra                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ValidPer(MEI->MEI_DATDE, MEI->MEI_DATATE, MEI->MEI_CODREG, dDataIni) //Data Inicial, Data Final, Codigo Regra
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Adciona ao array as informacoes da tabela MEJ para ser   ³
						//³ ordenado pelo campo MEJ->MEJ_PRINUM (ORDE. DA REGRA)    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						// MEJ – Prioridade da regra desconto
						DbSelectArea("MEJ")
						DbSetOrder(2)//MEJ_FILIAL+MEJ_CODREG
						If DbSeek(xFilial("MEJ")+MB8->MB8_CODREG)
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se a regra e para a filial atual                ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							// MB3 - Filiais/Grupos cadastrados nas Regras
							DbSelectArea("MB3")
							DbSetOrder(1) //MB3_FILIAL+MB3_CODREG+MB3_CODEMP+MB3_CODFIL
							If DbSeek(xFilial("MB3") + MB8->MB8_CODREG + cEmpAnt)
								Do While !MB3->(Eof()) .AND. MB3->MB3_FILIAL+MB3->MB3_CODREG+MB3->MB3_CODEMP == xFilial("MB3")+MB8->MB8_CODREG+cEmpAnt 
									// 1. Tipo Filial
									// 2. Tipo Grupo de Filiais
									
									IF MB3->MB3_TIPO == "1"
										If MB3->MB3_CODFIL == cFilAnt
											lFindRegra := .T.
										EndIf
									ElseIf MB3->MB3_TIPO == "2"
										// SAU – Grupo de Filiais
										DbSelectArea("SAU")
										SAU->(dbSetOrder(1))
										IF SAU->( dbSeek( xFilial("SAU") + MB3->MB3_CODGRU ) )

											Do While SAU->( !EOF() .And. SAU->AU_FILIAL+AllTrim(SAU->AU_CODGRUP) == xFilial("SAU")+AllTrim(MB3->MB3_CODGRU) )
												If SAU->AU_CODFIL == cFilAnt
													lFindRegra := .T.
													Exit			
												EndIf					
												SAU->( DbSkip() )														
											EndDo													

										Endif
									EndIf
									If lFindRegra
										AADD(aMB8,{	MB8->MB8_CODREG	, MEJ->MEJ_PRINUM, MB8->MB8_CODPRO, MB8->MB8_CATEGO, ;
													MB8->MB8_DESCPR	, MB8->MB8_DESCVL, MEI->MEI_GRPVEN, MEI->MEI_DESFUN, ;
													MEI->MEI_PRDMOS	, MEI->MEI_PRDSLD, MEI->MEI_ACUMUL, MEI->MEI_CODCLI, ;
													MEI->MEI_LOJA  	, 0				 , 0			  , MB8->MB8_QTDPRO })
										lFindRegra := .F.
									EndIf
									MB3->( DbSkip() )
								EndDo	
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			
			MB8->(DbSkip())
		EndDo
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena no array todas as informacoes do item:          ³
//³  Produto, categoria, valor e percentual Desc., Cod Regra³   
//³Filtro: Por todas regras por item com range de valores.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MEI")
DbSetOrder(3) //MEI_FILIAL+MEI_TPIMPD
If DbSeek(xFilial("MEI") + "I")
	While !MEI->(Eof()) .And. (MEI->MEI_TPIMPD == "I")
		If !(MEI->MEI_ATIVA == "1")   
			MEI->(DbSkip())
			Loop
		EndIf
	    DbSelectArea("MB2")
	    DbSetOrder(1) //MB2_FILIAL+MB2_CODREG+MB2_REFGRD
	    If DbSeek(xFilial("MB2") + MEI->MEI_CODREG) 
			While MB2->(!EOF()) .And. MB2->MB2_FILIAL + MB2->MB2_CODREG == xFilial("MB2") + MEI->MEI_CODREG
				If MB2->MB2_VLRINI == 0 .And. MB2->MB2_VLRFIM == 0 //Valida se range foi informado para considerar registro
					MB2->(DbSkip())
					Loop
				EndIf
				 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida o dia e horario da regra                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValidPer(MEI->MEI_DATDE, MEI->MEI_DATATE, MEI->MEI_CODREG, dDataIni) //Data Inicial, Data Final, Codigo Regra 
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Adciona ao array as informacoes da tabela MEJ para ser   ³
					//³ ordenado pelo campo MEJ->MEJ_PRINUM (ORDE. DA REGRA)    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					DbSelectArea("MEJ")
					DbSetOrder(2) ////MEJ_FILIAL+MEJ_CODREG
					If DbSeek(xFilial("MEJ")+MEI->MEI_CODREG)
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se a regra e para a filial atual                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
						DbSelectArea("MB3")
						DbSetOrder(1) //MB3_FILIAL+MB3_CODREG+MB3_CODEMP+MB3_CODFIL
						If DbSeek(xFilial("MB3") + MEI->MEI_CODREG + cEmpAnt + cFilAnt)
							AADD(aMB8,{	MEI->MEI_CODREG	, MEJ->MEJ_PRINUM , ""/*CODPROD*/   	, ""/*CODCAT*/		, ;
									   	MB2->MB2_PDESC	, MB2->MB2_VLRFX  , MEI->MEI_GRPVEN		, MEI->MEI_DESFUN	, ;
									   	MEI->MEI_PRDMOS	, MEI->MEI_PRDSLD , MEI->MEI_ACUMUL 	, MEI->MEI_CODCLI	, ;
									   	MEI->MEI_LOJA	, MB2->MB2_VLRINI , MB2->MB2_VLRFIM		, 0 				})  
						EndIf					
					EndIf
				EndIf			
				MB2->(dbSkip())
			EndDo    
	    EndIf
		MEI->(DbSkip())
	EndDo
EndIf		


If Len(aMB8) > 0
	//----------------------------------------------------------------------------
	// Ordena o array pela ordem de priorizacao no qual serao aplicadas as regras
	//----------------------------------------------------------------------------
	aMB8 := LjOrdRegra(aMB8)
	
	For nA := 1 To Len(aMB8)
		
		lAcumu := IIF(aMB8[nA][11] == "N",.F.,.T.) //Verifica se a regra eh acumulativa
		
		//Quando identificar uma regra que nao eh acumulativa e ja tiver encontrado alguma outra regra valida, 
		//entao desconsidera a regra de nao eh acumulativa
		If lAchouRDVld .And. !lAcumu
			Loop
		EndIf
		
   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Passará para a variável de referência                          ³
		//³Se lRgAcumul = .F., não prosseguirá as próximas regras.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
		If FindFunction( "LJSETRACUMUL" )
			LjSetRAcumul( lAcumu )
		EndIf	
		
	   	lAplReg := .T.	
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a regra estiver cadastrada com cliente compara com o cliente³
	    //³ da venda atual. 											  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If !Empty(AllTrim(aMB8[nA][12]) + AllTrim(aMB8[nA][13])) .And. !((AllTrim(aMB8[nA][12]) + AllTrim(aMB8[nA][13])) == (AllTrim(cCliente) + AllTrim(cLoja)))
			lAplReg := .F.
		EndIf       

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a regra estiver cadastrada com grupo de cliente compara com ³
    	//³ o grupo que o cliente da venda atual.         				  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	             
		If !Empty(AllTrim(aMB8[nA][7])) .And. !(AllTrim(GetAdvFVal("SA1","A1_GRPVEN",xFilial("SA1")+cCliente,1,"")) == aMB8[nA][7])
			lAplReg := .F.
		EndIf 
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a regra for por desconto de funcionario, porem no cad de cli³
	    //³ nao estiver como desconto de funcionario nao se aplica a regra³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aMB8[nA][8] == "S") 
			If lAI0_CLIFU	
				cCliFun := GetAdvFVal("AI0","AI0_CLIFUN",xFilial("AI0")+cCliente+cLoja,1,"2")
			EndIf
			
			If Empty(cCliFun) 
				If  lA1_CLIFUN 
					 cCliFun := GetAdvFVal("SA1","A1_CLIFUN",xFilial("SA1")+cCliente+cLoja,1,"2")
				EndIf		
			EndIf
			
			If !(cCliFun == "1")
				lAplReg := .F.
			EndIf 
		EndIf	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a regra for por desconto de saldao ou mostruario, porem o   ³
		//³	tipo de produto no ato da venda for diferente ele nao executa ³
		//³	a regra 													  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		// 9 = Mostruario ; 10 = Saldao
		If	( cTipoProd == "N" .And. !(aMB8[nA][09] == "N" .And. aMB8[nA][10] == "N") ) .Or.;
			( Empty(cTipoProd) .And. (aMB8[nA][09] == "S" .Or. aMB8[nA][10] == "S") ) .Or.;
			( cTipoProd == "M" .And. aMB8[nA][09] <> "S" ) .Or.;
			( cTipoProd == "S" .And. aMB8[nA][10] <> "S" )					

			lAplReg := .F.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se atinge a quantidade minima para aplicar a regra.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aMB8[nA][16] > 0 .And. nQtd < aMB8[nA][16]
			lAplReg := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Depois de verificar todas as valicoes sera aplicada a regra.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lAplReg    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Add na var. o valor total do item, para calcular o percentual  ³	
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
			If nValProdA == 0
				nValProd  	:= RGDesIteVlProd(cProduto, dDataIni, lPainel, cCliente, cLoja )  
				nValProd	:= (nValProd * nQtd)
				nValProdA 	:= nValProd
			EndIf	
	        
   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Aplica o desconto de acordo com tipo (R$ ou %)                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If (aMB8[nA][14] > 0 .Or. aMB8[nA][15] > 0)
				If (aMB8[nA][14] > nValProdA) .Or. (aMB8[nA][15] < nValProdA) 
					lAplReg := .F.
				EndIf
			EndIf 
			
			If lAplReg
				lAchouRDVld := .T.
			
				If aMB8[nA][5] > 0  //Percentual                                                                
					If !(aMB8[nA][5] > 99.99) .And. !((nValProdA - (nValProdA * (aMB8[nA][5] / 100 ))) < 0.01)
						nValProdA := nValProdA - (nValProdA * (aMB8[nA][5] / 100 ))
					Else
						lValid := .F.	
					EndIf
				Else   					//Valor
					If (!aMB8[nA][6] > nValProdA) .And. !((nValProdA - aMB8[nA][6]) < 0.01)
           		    	nValProdA := (nValProdA - aMB8[nA][6])	
					Else
						lValid := .F.	                		
					EndIf              
				EndIf
			
	   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando o desconto for maior que o valor do produto, ja vai sair³
				//³ da aplicacao da regra e calcula o produto com valor de 0.01   ³			
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	       	    If !lValid	       	    	
    	   	    	nDescPer := CalPerc(nValProd, 0.01)
					Return(nDescPer)		
				EndIf 	    
			EndIf	    
		EndIf
	Next nA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ja calculou o valor total de desconto, entao vai retornar qual ³
	//³ sera o percentual.                                            ³			
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDescPer := CalPerc(nValProd, nValProdA)	
	
EndIf

Return(nDescPer)

/*/{Protheus.doc} RGDesIteVlProd
Retorna o valor do item, apartir da tab. de preco.
@type  Function
@author Luiz Strele
@since	17/05/11
@version V12.27
@param	ExpC1 - Codigo do produto 
		ExpD1 - Data de pesquisa da tabela de preco
@return nPrecoTab, numeric, Valor do item
@example RGDesIteVlProd()  
/*/
Function RGDesIteVlProd( cCodProd, dDataIni, lPainel, cCodCli, cLoja)      

Local nPrecoTab 	:= 0  							//Retorno da Funcao com valor do produto
Local dDataAtu		:= Date()						//Data atual para validacao da regra  
Local cTime    		:= Time()						//Horario atual da chamada da funcao para validar com horario da regra
Local aDA0			:= {}							//Array para armazenar dados da DA0 quando dDataIni estiver preenchido
Local cRefGrd		:= ""							//Codigo fixo do produto, utilizado na Grade de Produto
Local cTabPad  		:= LjXETabPre(cCodCli,cLoja)	// Tabela de preco a ser utilizada
Local cTabela		:= ""           				//Tabela de Preço
Local dMinDataVig	:= CtoD(" / / ")				// Dara de vigência mais recente
Local cGrupoProd	:= ""							// Grupo do Produto
Local lFindProd		:= .F.							// Indica se achou o produto na tabela de preço (DA1)
Local lBuscaGrp		:= .F.							// Indica busca feita pelo grupo de produto na DA1

Default cCodProd 	:= ""							//Codigo do produto para validacao
Default dDataIni 	:= CTOD(" ")  					//Data de verificao da tabela de preco  
Default lPainel 	:= .F.    						//Data de verificao da tabela de preco 
Default cCodCli     := "" 							//Codigo do Cliente
Default cLoja		:= "" 							//Codigo da Loja

LjGrvLog("RGDesIteVlProd", "Busca preço do item na tabela - Chamado por: " , ProcName(1) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida a existencia do produto, mais utilizando na funcao ³
//³ do painel de gestao. 				     				 	  ³
	//³Validacao: Venda Assistida								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo <> 23
	If !Empty(AllTrim(cCodProd))
		DbSelectArea("SB1")
		DbSetOrder(1) //B1_FILIAL+B1_COD
		If !DbSeek(xFilial("SB1") + cCodProd)
			Return(nPrecoTab)
		EndIf
	EndIf
Endif

If lCenVenda .And. lNovRegDesc  	
	If (dDataIni == CTOD(" ")) .And. !(Empty(cCodProd)) .And. !lPainel
	
		If lTabEspCli .AND. !Empty(cCodCli) .AND. !Empty(cLoja) .AND. SA1->(DbSeek(xFilial("SA1")+cCodCli+cLoja)) .AND. !Empty(SA1->A1_TABELA)
			cTabPad := SA1->A1_TABELA
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Localiza as tabelas de preco pelo produto, e utiliza      ³
		//³ as que a data de vigencia esta dentro do periodo atual.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Busca a tabela de preço e verifica a validade
		DbSelectArea("DA0")
		DA0->( DbSetOrder(1) )	//DA0_FILIAL+DA0_CODTAB
		If DA0->( DbSeek(xFilial("DA0") + cTabPad) ) .AND. VldDateTabPreco()
			
			DbSelectArea("DA1")
			// Busca pelo código do produto
			DA1->( DbSetOrder(2) )			//DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM
			If DA1->( DbSeek(xFilial("DA1") + PadR( cCodProd, TamSX3("DA1_CODPRO")[1] ) + cTabPad ) )
				lFindProd := .T.
			Else
				// Busca pelo grupo do produto
				cGrupoProd := GetAdvFVal("SB1","B1_GRUPO",xFilial('SB1') + cCodProd,1)	

				If !Empty(cGrupoProd)
					DA1->( DbSetOrder(4) )	// DA1_FILIAL+DA1_CODTAB+DA1_GRUPO+DA1_INDLOT+DA1_ITEM                                                                                                             
					If DA1->( DbSeek(xFilial("DA1") + PadR( cTabPad, TamSX3("DA1_CODTAB")[1] ) + PadR( cGrupoProd, TamSX3("DA1_GRUPO")[1] ) ) )
						lFindProd := .T.
						lBuscaGrp := .T.
					EndIf
				EndIf

			EndIf

			If lFindProd

				dMinDataVig := DA1->DA1_DATVIG
				
				While	!DA1->( Eof() ) .AND. ( (AlLTrim(DA1->DA1_CODPRO) == AlLTrim(cCodProd)) .OR. ;
						( lBuscaGrp .AND. Empty(DA1->DA1_CODPRO) .AND. AlLTrim(DA1->DA1_GRUPO) == AlLTrim(cGrupoProd) ) ) .AND. ;
						( AlLTrim(DA1->DA1_CODTAB) == AlLTrim(cTabPad) )

					If dDataBase >= DA1->DA1_DATVIG .AND. ( dMinDataVig <= DA1->DA1_DATVIG .OR. Empty(DA1->DA1_DATVIG) ) .AND. AllTrim(DA1->DA1_ATIVO) == "1"
						nPrecoTab 	:= DA1->DA1_PRCVEN
						dMinDataVig := DA1->DA1_DATVIG 
					EndIf

					DA1->( DbSkip() )
				EndDo

			Else

				//-----------------------------------------------------
				// verifica se existe desconto para a Grade de Produtos
				//-----------------------------------------------------

				cRefGrd := LjRetRfGrd(cCodProd)
				If !Empty(cRefGrd)

					DbSelectArea("DA0")
					DA0->( DbSetOrder(1) )	//DA0_FILIAL+DA0_CODTAB
					If DA0->( DbSeek(xFilial("DA0") + cTabPad) ) .AND. VldDateTabPreco()

						If cPaisLoc == "BRA"
							DA1->( DbSetOrder(6) )	//DA1_FILIAL, DA1_REFGRD, DA1_CODTAB, DA1_ITEM
						Else
							// Se não for ambiente Brasil, o índice 4 fica desabilitado,
							// assim, a ordem de índices abertos ficará 1, 2, 3, 5, 6
							// e será o quinto da ordem
							DA1->( DbSetOrder(5) )	//DA1_FILIAL, DA1_REFGRD, DA1_CODTAB, DA1_ITEM
						EndIf

						If DA1->( DbSeek(xFilial("DA1") + PadR( cRefGrd, TamSX3("DA1_CODPRO")[1] ) + cTabPad ) )

							dMinDataVig := DA1->DA1_DATVIG
				
							While !DA1->( Eof() ) .AND. ( AlLTrim(DA1->DA1_REFGRD) == AlLTrim(cRefGrd) ) .AND. ( AlLTrim(DA1->DA1_CODTAB) == AlLTrim(cTabPad) )

								If dDataBase >= DA1->DA1_DATVIG .AND. ( dMinDataVig <= DA1->DA1_DATVIG .OR. Empty(DA1->DA1_DATVIG) ) .AND. AllTrim(DA1->DA1_ATIVO) == "1"
									nPrecoTab 	:= DA1->DA1_PRCVEN
									dMinDataVig := DA1->DA1_DATVIG 
								EndIf

								DA1->( DbSkip() )	
							EndDo

						EndIf

					EndIf

				EndIf							

			EndIf

		EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Identifica todas as tabelas de preco com data informada e ³
		//³ add. no array para ser validada depois.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTabela := ""
		If lTabEspCli .AND. !Empty(cCodCli) .AND. !Empty(cLoja) .AND. SA1->(DbSeek(xFilial("SA1")+cCodCli+cLoja)) .AND. !Empty(SA1->A1_TABELA)
			cTabela := SA1->A1_TABELA
		EndIf		
		DbSelectArea("DA1")
		DbSetOrder(2)//DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM
		If DbSeek(xFilial("DA1") + cCodProd)
			While !DA1->(Eof()) .And. (DA1->DA1_CODPRO == cCodProd)
				DbSelectArea("DA0")
				DbSetOrder(1)//DA0_FILIAL+DA0_CODTAB
				If Empty(cTabela)
					cTabela := DA1->DA1_CODTAB
				EndIf
				If DbSeek(xFilial("DA0") + cTabela)
					While !DA0->(Eof()) .And. (cTabela == DA0->DA0_CODTAB)
    	                If (DA0->DA0_DATDE>=dDataIni) .And. ((DA0->DA0_DATATE<=dDataIni) .Or. (DA0->DA0_DATATE == CTOD(" ")))   ///// inverter
        	            	AADD(aDA0,{"DA0",DA0->DA0_CODTAB, DA0->DA0_DATDE,cCodProd})
            	        EndIf
						DA0->(DbSkip())
					EndDo						
				EndIf
				DA1->(DbSkip())
			EndDo
		EndIf  
		
		DbSelectArea("SAY")
		DbSetOrder(2) // AY_FILIAL+AY_PRODUTO
		If DbSeek(xFilial("SAY") + cCodProd)
			While !SAY->(Eof()) .And. (SAY->AY_PRODUTO == cCodProd)
				DbSelectArea("SAX")
				DbSetOrder(1) //AX_FILIAL+AX_CODIGO
				If DbSeek(xFilial("SAX") + SAY->AY_CODIGO)
					While !SAX->(Eof()) .And. (SAX->AX_CODIGO == SAY->AY_CODIGO)
    	                If (dDataIni <= SAX->AX_DATAINI)                           
        	            	AADD(aDA0,{"SAX",SAX->AX_CODIGO, SAX->AX_DATAINI,cCodProd})        //// campo produto.
            	        EndIf
						SAX->(DbSkip())
					EndDo						
				EndIf
				SAY->(DbSkip())
			EndDo
		EndIf  		
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ordena todas as tabelas de preco por data de, e utiliza a ³                                                 
		//³ primeira com data mais proxima de ser aplicada.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aDA0) > 0 	
			aDA0 := aSort(aDA0,,,{|x,y| x[2] < y[2]})
			
			If aDA0[1][1] == "DA0"
				DbSelectArea("DA1")
				DbSetOrder(2)//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
				If DbSeek(xFilial("DA1") + aDA0[1][2] + aDA0[1][4])     
					nPrecoTab := DA1->DA1_PRCVEN 		
				EndIf
			ElseIf aDA0[1][1] == "SAX"        
				DbSelectArea("SAY")
				DbSetOrder(1)//AY_FILIAL+AY_CODIGO+AY_PRODUTO     ////// INDICE MUDAR PARA (um)
				If DbSeek(xFilial("SAY") + aDA0[1][2] + aDA0[1][4])   ///// CORRIGIR TEM VIRGURLA ---EH O SINAL DE MAIS.
					nPrecoTab := SAY->AY_PRCSUG		
				EndIf			
			EndIf	
		EndIf
	EndIf	
Endif

If nModulo == 23 .And. !lNovRegDesc	
	If !Empty(AllTrim(cCodProd))
		DbSelectArea("SBI")
		DbSetOrder(1)//BI_FILIAL+BI_COD
		If DbSeek(xFilial("SBI") + cCodProd)
			nPrecoTab := SBI->BI_PRV
		EndIf
	EndIf     
Endif

Return(nPrecoTab)

//-------------------------------------------------------------------
/*{Protheus.doc} VldDateTabPreco
Avalia se a tabela de preco eh valida de acordo com a data e hora especificadas.

@author Leandro F. Dourado
@since 21/08/2012
@version P11.7
*/
//-------------------------------------------------------------------

Static Function VldDateTabPreco()
Local lRet 		:= .F.
Local cHoraAtual	:= SUBSTR(Time(), 1, 5) // Pego apenas as horas e minutos atuais.

//Caso o tipo de horario seja unico (Regra eh valida da hora inicial do primeiro dia até a hora final do último dia)	
	If DA0->DA0_TPHORA == "1" 	
	
	// Caso a data atual esteja entre a Data Inicial e a Data Final
	If dDataBase > DA0->DA0_DATDE .And. (dDataBase < DA0->DA0_DATATE .Or. Empty(DA0->DA0_DATATE)) 	
		lRet := .T.
	
	//Caso a data atual seja maior que a data inicial e a data final esteja em branco.
	ElseIf dDataBase > DA0->DA0_DATDE .AND. Empty(DA0->DA0_DATATE) 				
		lRet := .T.
	
	// Caso a Data atual seja igual a Data Inicial	
	ElseIf dDataBase == DA0->DA0_DATDE 
	
		//Se a hora atual for maior ou igual que a hora inicial
		If cHoraAtual >= DA0->DA0_HORADE 	
			lRet := .T.
		EndIf
		
	// Caso a Data atual seja igual a Data Final
	ElseIf dDataBase == DA0->DA0_DATATE 	
	
		//Se a hora atual for menor ou igual que a hora final
		If cHoraAtual <= DA0->DA0_HORATE 	
			lRet := .T.
		EndIf	
	EndIf

/* 
	Caso o tipo de horario seja recorrente (Regra valida do dia inicial ao final, somente durante os horarios
	que estiverem entre o horario inicial e o horario final).
*/	
ElseIf DA0->DA0_TPHORA == "2"
			
	// Caso a data atual seja maior ou igual a data inicial
	If dDataBase >= DA0->DA0_DATDE 
											
		// Caso a data atual seja menor ou igual a data final, ou caso a data final esteja vazia
		If dDataBase <= DA0->DA0_DATATE .OR. Empty(DA0->DA0_DATATE)	
													
			// Caso a hora atual seja maior ou igual que a hora inicial E menor ou igual que a hora final
			If cHoraAtual >= DA0->DA0_HORADE .AND. cHoraAtual <= DA0->DA0_HORATE																				
				lRet := .T.
			EndIf				
		EndIf
	EndIf													
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RGVldTableºAutor  ³ Luiz Strele        º Data ³  21/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao das tabelas da regra de desconto.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ RGVldTable()                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL1 - Existencia de todas as tabelas da regra de desc.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja701                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    
Function RGVldTable()   

Local lRet 		:= .T.  	// Retorno
Local aTable 	:= {"MB8","MB7","MB6","MB5","MB4","MB3","MB2","MEI","MEJ"}  // Array de Tabelas
Local nA		:= 0		// Contador

For nA := 1 To Len(aTable) 
	If (SELECT(aTable[nA]) == 0) .And. lRet
		lRet := CHKFILE(aTable[nA])	
	EndIf
Next nA         

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJRETRFGRDºAutor  ³ Vendas e DL        º Data ³  03/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o codigo fixo da Grade de Produtos                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjRetRfGrd( cCodProd )									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC1 - Codigo fixo da Grade de Produtos					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³RGDesIteVlProd											  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Function LjRetRfGrd( cCodProd )

Local cMaskProd 	:= SuperGetMV("MV_MASCGRD",,"")
Local nPos			:= 0
Local nTamCodFixo	:= 0
Local cRefGrd		:= ""

//posicao da virgula que separa os valores da mascara de grade
nPos := At(",", cMaskProd)
//obtemos a quantidade de digitos do codigo do produto fixo
nTamCodFixo	:= Val( SubStr(cMaskProd, 1, nPos) )
//obtemos o codigo do produto fixo
cRefGrd := SubStr(cCodProd, 1, nTamCodFixo)
cRefGrd := PadR( cRefGrd, TamSX3("DA1_REFGRD")[1] )

Return cRefGrd

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} LjOrdRegra
Ordena no array as regras de desconto por item.
Faz a ordenacao na sequencia em que serao analisadas cada regra.

@type 		function
@author  	Alberto Deviciente (albertod)
@since   	08/12/2018
@version 	P12.1.17

@param aRegraItem, Array, Relacao de Regras de Desconto disponiveis/ativas para aplicacao

@return Array, 	Relacao de Regras de Desconto disponiveis/ativas para aplicacao ordenada 
				na sequencia em que serao analisadas cada regra.
/*/
//-----------------------------------------------------------------------------------
Static Function LjOrdRegra(aRegraItem)
Local nX 		:= 0
Local nY 		:= 0
Local cCodRegra := ""
Local nCount 	:= 0
Local nPosIni 	:= 0

//Primeiro ordena por Prioridade de Regra (MEJ_PRINUM)
aSort(aRegraItem,,,{|x,y| x[2]+[1] < y[2]+[1]})

//Agora, ordena por ordem decrescente, a quantidade minima de compra (MB8_QTDPRO) para aplicacao de desconto
For nX:=1 To Len(aRegraItem)
	cCodRegra := aRegraItem[nX][1]
	nCount := 0
	nPosIni := nX

	For nY := nX To Len(aRegraItem)
		If aRegraItem[nY][1] <> cCodRegra
			nY := nY-1
			Exit
		EndIf
		nCount++
	Next nY

	//Ordena por ordem decrescente a quantidade minima de compra para aplicacao de desconto de um determinado produto
	//Isso eh necessario para que seja comparada primeiramente se a maior quantidade vendida eh atingida, pois normalmente eh a que possui maior valor de desconto
	aSort( aRegraItem, nPosIni, nCount, { |x,y| x[16] > y[16] } )

	nX := nY

Next nX

Return aRegraItem
