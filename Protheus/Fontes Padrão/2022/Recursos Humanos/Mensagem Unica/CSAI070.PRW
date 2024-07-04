#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"  
#INCLUDE "TBICONN.CH"
#INCLUDE "CSAI070.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função      ³ CSAI070     ³ Autor ³ Emerson Campos   ³ Data ³ 13/02/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição   ³ Funcao de integracao com o adapter EAI para recebimento e  ³±±
±±³            ³ envio de informações do cadastro de tabelas salariais      ³±±
±±³            ³ (RBR e RB6) utilizando o conceito de mensagem unica.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³ CSAI070                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros  ³ cXML        - Mensagem XML, quando for uma recepção		³±±
±±³            ³ nTypeTrans  - Indica o tipo de transação, que pode ser:  	³±±
±±³            ³     * TRANS_RECEIVE	Quando for recepção de uma mensagem,³±± 
±±³            ³                        seja uma BusinessMessage,           ³±±  
±±³            ³                        ResponseMessage ou WhoIsMessage     ³±±
±±³            ³     * TRANS_SEND   	Quando for um envio de mensagem     ³±±
±±³            ³ cTypeMessage - Indica o tipo da mens recebida, podendo ser:³±±
±±³            ³     * EAI_MESSAGE_PROTHEUS	Mensagem Protheus               ³±± 
±±³            ³     * EAI_MESSAGE_MVC	    Mensagem Protheus com MVC       ³±±
±±³            ³     * EAI_MESSAGE_BUSINESS	Mensagem Única BusinessMessage  ³±±
±±³            ³     * EAI_MESSAGE_RESPONSE	Mensagem Única ResponseMessage  ³±±
±±³            ³     * EAI_MESSAGE_RECEIPT	Mensagem Única ReceiptMessage   ³±±
±±³            ³     * EAI_MESSAGE_WHOIS	Mensagem Única WhoIsMessage     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data     ³ FNC/REQ ³  Motivo da Alteracao  	 	 	 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³         ³                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAI070 ( cXML, nTypeTrans, cTypeMessage )

Local lRet       	:= .T.
Local lEndList		:= .F.
Local lEndDelList 	:= .F.
Local cAlias		:= "" 
Local cField		:= ""
Local cXMLRet  		:= ""
Local cXmlErro		:= ""
Local cXmlWarn		:= ""
Local cTabela		:= ""
LOcal cDescTabela	:= ""
Local cNivel		:= ""
Local cFaixa		:= ""
Local cValExt		:= ""
Local cValInt		:= ""
Local cMarca		:= ""
Local cEvento		:= "upsert"
Local cEventSon		:= ""
Local cKeyFull		:= cEmpAnt+xFilial("RBR")
Local cAliasRB6 	:= GetNextAlias()
Local aArea			:= GetArea()
Local aCab        	:= {}
Local aItem			:= {}
Local aTotItem		:= {}
Local nOrdRB6		:= RetOrdem("RB6", "RB6_FILIAL+RB6_TABELA+DTOS(RB6_DTREF)+RB6_NIVEl+RB6_FAIXA")
Local nOrdXXF		:= RetOrdem("XXF", "XXF_ALIAS+XXF_FIELD+XXF_INTVAL")
Local nI			:= 0
Local nX			:= 0
Local nTamItem		:= 0
Local nTamFaixa     := 0
Local nValorRef		:= 0 
Local nVlrItem		:= 0
Local nCoefic		:= 0
Local nOpc			:= 0
Local nTamRet		:= 0
Local oXml
Local oXmlBusin
Local aRet			:= {}
Local cValName		:= ""

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS		//TESTE DE RECEPCAO BUSINESS MESSAGE
  
  		// Transforma a mensagem recebida em objeto XML
  		oXmlMvInt := XmlParser( cXml, "_", @cXmlErro, @cXmlWarn )
       
	  	// Verfica se houve erro na Transformacao
	  	If oXmlMvInt <> Nil .And. Empty( cXmlErro ) .AND. Empty( cXmlWarn )   		 
			oXmlBusin 	:= oXmlMvInt:_TotvsMessage:_BusinessMessage
			
			cMarca := oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name:Text
						
			If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil
									
				If XmlChildEx(oXmlBusin:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent:_Identification, '_KEY') <> Nil
						
					cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key:Text
					
				EndIf
				
				If FindFunction("CFGA070INT")
					
					cValInt := CFGA070INT( cMarca, 'RBR', 'RBR_TABELA', cValExt )
					
					//Validacoes das tags XML
					If XmlChildEx(oXmlBusin:_BusinessContent, '_TABLECODE') <> NIL
						lRet := .F.
						cXMLRet := '<Return>' + STR0001 + '</Return>' //Não existe a tag com o Código da Tabela Salarial
					EndIf 
					If XmlChildEx(oXmlBusin:_BusinessContent, '_TABLENAME') <> NIL
						lRet := .F.
						cXMLRet := '<Return>' + STR0002 + '</Return>' //Não existe a tag com a Descrição da Tabela Salarial
					EndIf
					
					If lRet == .T.
						cTabela		:= oXmlBusin:_BusinessContentType:_TableCode:Text
						cDescTabela	:= oXmlBusin:_BusinessContentType:_TableName:Text
				        // Se não for array
			            If Type("oXmlBusin:_BusinessContentType:_ListOfLevel:_LevelType") != "A"
			               // Transforma em array
			               XmlNode2Arr(oXmlBusin:_BusinessContentType:_ListOfLevel:_LevelType, "_LevelType")
			            EndIf
						nTamItem	:= Len(oXmlBusin:_BusinessContentType:_ListOfLevel:_LevelType)
									
						If nTamItem > 0
							If Type("oXmlBusin:_BusinessContentType:_ListOfLevel:LevelType[1]:_ListOfLevelRange:_LevelRangeType") <> Nil 
								nTamFaixa	:= Len(oXmlBusin:_BusinessContentType:_ListOfLevel:LevelType[1]:_ListOfLevelRange:_LevelRangeType)  
								If Type("oXmlBusin:_BusinessContentType:_ListOfLevel:LevelType[1]:_ListOfLevelRange:_LevelRangeType[1]:_TableLevelValue") <> Nil
									If nTamFaixa > 0
										nValorRef	:= Val(oXmlBusin:_BusinessContentType:_ListOfLevel:LevelType[1]:_ListOfLevelRange:_LevelRangeType[1]:_TableLevelValue:Text)
									EndIf
								Else
									lRet := .F.
									cXMLRet := '<Return>' + STR0003 + '</Return>' //Não existe a tag com o valor da primeira faixa do primeiro nível.
								EndIf
							Else
								lRet := .F.
								cXMLRet := '<Return>' + STR0004 + '</Return>' //Não existe a tag com o array contendo a lista de níveis da tabela salarial.
							EndIf
						EndIf
						
						If lRet 
							aCab :={  	{"RBR_FILIAL"    ,xFilial("RBR")	,NIL},;//Tam-2a12 / Filial do cadastro
										{"RBR_TABELA"    ,cTabela  			,NIL},;//Tam-03 / Código da Tabela	    	
									   	{"RBR_DESCTA"		,cDescTabela		,NIL},;//Tam-40 / Descrição da Tabela
									   	{"RBR_DTREF"		,dDate				,Nil},;//Data de referencia da tabela (utilizar database do sistema)
									   	{"RBR_VLREF"		,nValorRef			,NIl},;//Formato 999999999,99 (utilizar 1o.valor da Tabela RB6)
									   	{"RBR_USAPTO"		,2					,Nil},;//Neste campo deve ser informada a utilização de pontos mínimos e máximos na tabela salarial: 1- Sim ou 2- Não (colocar como default 2-Não)
									   	{"RBR_APLIC"		,"2"				,Nil},;//Neste campo deve ser informado se a tabela salarial é utilizada ou não para o reajuste salarial de funcionários: 1-Sim ou 2- Não (colocar como default 2-Não)
									   	{"RBR_TIPOVL"		,1					,Nil} ;//Neste campo deve ser informado o tipo da Tabela Salarial: 1- Por valores exatos ou 2- Por valores com Intervalos (colocar como default 1-Por Valores Exatos)
							         } 
							         
							For nI	:= 1 To nTamItem
								If Type("oXmlBusin:_BusinessContentType:_ListOfLevel:_LevelType[nI]:_TableLevel") <> Nil 
						        	cNivel	:= oXmlBusin:_BusinessContentType:_ListOfLevel:_LevelType[nI]:_TableLevel:Text
						  		Else
						  			lRet := .F.
									cXMLRet := '<Return>' + STR0005 + '</Return>' //Não existe a tag com o nível da tabela salarial.
									Exit	
								EndIf
						        
						        If lRet
						        	If Type("oXmlBusin:_BusinessContentType:_ListOfLevel:LevelType["+Str(nY)+"]:_ListOfLevelRange:_LevelRangeType") <> Nil
								        For nX := 1 To nTamFaixa        
											aItem		:= {}
											If Type("oXmlBusin:_BusinessContentType:_ListOfLevel:LevelType["+str(nI)+"]:_ListOfLevelRange:_LevelRangeType["+str(nX)+"]:_TableLevelRange") == Nil
												lRet := .F.
												cXMLRet := '<Return>' + STR0006 + '</Return>' //Não existe a tag com a faixa.
											EndIf
											
											If Type("oXmlBusin:_BusinessContentType:_ListOfLevel:LevelType["+str(nI)+"]:_ListOfLevelRange:_LevelRangeType["+str(nX)+"]:_TableLevelValue") == Nil								
												lRet := .F.
												cXMLRet := '<Return>' + STR0007 + '</Return>' //Não existe a tag com o valor da faixa.
											EndIf
											
								        	If lRet
									        	cFaixa		:= oXmlBusin:_BusinessContentType:_ListOfLevel:LevelType[nI]:_ListOfLevelRange:_LevelRangeType[nX]:_TableLevelRange:Text
									        	nVlrItem	:= oXmlBusin:_BusinessContentType:_ListOfLevel:LevelType[nI]:_ListOfLevelRange:_LevelRangeType[nX]:_TableLevelValue:Text
									        	nCoefic		:= nVlrItem/nValorRef 
										        aItem:={	{"RB6_FILIAL" ,aCab[1,1,2]				,NIL},;//Tam-2a12 / Filial do cadastro (gravar o campo RBR_FILIAL)
															{"RB6_TABELA"	,aCab[1,2,2]			   ,NIL},;//Tam-03 / Código da Tabela (gravar o campo RBR_TABELA)
															{"RB6_DESCTA"	,aCab[1,3,2]			   ,NIL},;//Tam-30 / Descrição da Tabela (gravar o campo RBR_DESCTA)
															{"RB6_TIPOVL"	,aCab[1,8,2]			   ,NIL},;//Tam-01 / Gravar conteudo do RBR_TIPOVL ou 1 se RBR_TIPOVL estiver vázio		
															{"RB6_NIVEL" 	,cNivel			   		,NIL},;//Tam-02 / Define o nivel da tabela salarial	   
														  	{"RB6_FAIXA" 	,cFaixa					,NIL},;//Tam-02 / Define a faixa salarial     	        
													      	{"RB6_VALOR"	,nVlrItem             	,NIL},;//Tam-12 / Define o valor da faixa salarial no formato 999999999,99    	        
														  	{"RB6_PTOMIN"	,0	             		,NIL},;    	        
														  	{"RB6_PTOMAX"	,0	             		,NIL},;    	        
														  	{"RB6_CLASSE"	,""             		,NIL},;
														  	{"RB6_DESCLA"	,""             		,NIL},;    	        
														  	{"RB6_DTREF"	,dDate          		   ,NIL},;    	        
														  	{"RB6_COEFIC"	,nCoefic			 	   ,NIL},;//Define o coeficiente das faixas (Deverá ser calculado o coeficiente com base nos valores)    	        
														  	{"RB6_REGIAO"	,""             		,NIL},;     
													      	{"RB6_ATUAL" 	,""        				,NIL} ;
													    }            
										
												aadd(aTotItem,aItem)
											EndIf
										Next nX
									Else
										lRet := .F.
										cXMLRet := '<Return>' + STR0008 + '</Return>' //Não existe a tag com o array contendo a lista de faixas do nivel da tabela salarial.
									EndIf
								EndIf						
							Next nI	
						EndIf
						
						If lRet
							// Exclusao
				   			If Upper( oXmlBusin:_BusinessEvent:_Event:Text ) == "DELETE"
				   				nOpc	:= 5
				   				// Se For preciso dar uma resposta este será o que o EAI usara como retorno para criar a ResponseMessage
					    		cMsg	:= "<Return>" + STR0009 + "</Return>" //Tabela salarial excluída com sucesso!
				   			Else
				   				If Empty(cValInt) //DbSeek(xFilial("RBR")+cTabela)
				   					nOpc	:= 3
				   				Else		   					
				   					nOpc	:= 4
				   				EndIf		   				
				   			EndIf
				   				
							MSExecAuto({|x,y,z,e| CSAA070(x,y,z,e)},aCab,aTotItem,nOpc,.T.)
					
							If lMsErroAuto
								cXMLRet :=	'<Return>' + STR0010 + '</Return>' //Erro durante o processo de execução da rotina automática!
								Mostraerro()	
								DisarmTransaction()	
								break
							Else						    	
						    	//------------------------------------------------------------------------------------------------
								//  CFGA070Mnt - Procura a Marca,Alias,Codigo na Tabela XXF de De/Para para ver se existe o Codigo
								//------------------------------------------------------------------------------------------------
						    	If Upper( oXmlBusin:_BusinessEvent:_Event:Text ) == "UPSERT"
							    	If FindFunction('CFGA070Mnt')
								    	If nOpc == 3
											cValInt := xFilial("RBR")+RBR->TABELA
											CFGA070Mnt( cMarca, "RBR", "RBR->TABELA", cValExt, cValInt )
										Else
											CFGA070Mnt( , "RBR", "RBR->TABELA", , cValInt, .T. )
										EndIf
									
										//----------------------------------------------------------------
										//  Dados ok para gravação
										cXMLRet := 	'<ListOfInternalId>'
										cXMLRet += 		'<MovementsInternal>'
										cXMLRet += 			'<Origin>'+ cValExt +'</Origin>'
										cXMLRet += 			'<Destination>'+ cValInt +'</Destination>'
										cXMLRet += 		'</MovementsInternal>'
										cXMLRet += '</ListOfInternalId>'
										
										//----------------------------------------------------------------
									EndIf
								Else
									If !Empty( cValInt )             
						  		   		RBR->(dbSeek(cValInt))
					  		    		If FindFunction('CFGA070Mnt')  
									   		//Exclui quando vem de outro ERP
								   			CFGA070Mnt(, "RBR", "RBR->TABELA",, cValInt, .T. )  // Deleta o XXF
								    	Endif
									EndIf
				  					nOpcExec:= 5
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					lRet   := .F.
					cXMLRet := STR0011 //"Atualize EAI"
				EndIf
			EndIf
		Else
			lRet := .F.
			cXMLRet := 	'<Return>' + STR0012 + cXmlErro + STR0013 + cXmlWarn + '</Return>' //Xml mal formatado  ##### ou
		EndIf
		
     ElseIf	cTypeMessage == EAI_MESSAGE_RESPONSE	//TESTE DE RECEPCAO RESPONSE MESSAGE          
        If FindFunction("CFGA070Mnt")			
			oXmlMvInt := XmlParser(cXml, "_", @cXmlErro, @cXmlWarn)
			
			If oXmlMvInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
			
				If AllTrim(oXmlMvInt:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:TEXT) == "OK" 
					If Type("oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name") <> "U"
						cMarca := oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name:Text 
					EndIf
					If Type("oXmlMvInt:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID") <> "U"
						If ValType(oXmlMvInt:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID) == "A"
						
							nTamRet	:= Len(oXmlMvInt:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID)
							For nI := 1 To nTamRet					
								
								cValInt := oXmlMvInt:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID[nI]:_ORIGIN:TEXT					
								cValExt := oXmlMvInt:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID[nI]:_DESTINATION:TEXT
								cValName := AllTrim(oXmlMvInt:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID[nI]:_NAME:TEXT)								   		
								Aadd(aRet,{cValInt,cValExt,cValName})
								 
							Next nI
						Else
							cValInt := oXmlMvInt:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID:_ORIGIN:TEXT					
							cValExt := oXmlMvInt:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID:_DESTINATION:TEXT
							cValName := AllTrim(oXmlMvInt:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_LISTOFINTERNALID:_INTERNALID:_NAME:TEXT)								   		
						
							Aadd(aRet,{cValInt,cValExt,cValName})
						EndIf
						
						For nI := 1 To Len(aRet)
							cValInt := aRet[nI][1]					
							cValExt := aRet[nI][2]
							cValName := aRet[nI][3]								   		
						
							If !Empty(cValExt) .And.!Empty(cValInt)
								If cValName == 'WageTable'
									cAlias	:= "RBR"
									cField	:= "RBR_TABELA"	
								ElseIf cValName == 'LevelInternalId'
									cAlias	:= "RB6"
									cField	:= "RB6_NIVEL"	
								ElseIf cValName == 'LevelRangeInternalId'
									cAlias	:= "RB6"
									cField	:= "RB6_FAIXA"
								EndIf
								//----------------------------------------------------------------------------------------
								//-- procura a Marca,Alias,Codigo na Tabela XXF de De/Para para ver se Existe o Código
								//----------------------------------------------------------------------------------------
					   			If FindFunction("CFGA070Int")
					   			    //Apenas verifica se existe o Registro no XXF para saber se é Inclusão, Alteração ou Exclusão	
						   			If !Empty(CFGA070Int( cMarca,  cAlias , cField, cValExt )) .AND. (!Inclui .AND. !Altera)
								   		CFGA070Mnt(  cMarca, cAlias , cField, /* cValExt */ , cValInt, .T. )
								   	Else
								   		DbSelectArea(cAlias)
								   		If CFGA070Mnt( cMarca, cAlias , cField, cValExt, cValInt )
											lRet    := .T.
										EndIf
									EndIf
								EndIf
							Else
								cMsgStatus :='<Message type="ERROR" code="c2">' + STR0014 + cValInt + STR0015 + cValExt +'</Message>'// A chave interna ou externa não foi informada. Chave interna:    #### Chave Externa: 
								lRet    := .F.
							EndIf
						Next nI
					EndIf
					
					//Verifica necessidade de excluir alguma faixa/nivel
					oXmlAux := XmlParser(oXmlMvInt:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text, "_", @cXmlErro, @cXmlWarn)
				
		            If Type("oXmlAux:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFLEVEL") != "A"
		               // Transforma em array
		               XmlNode2Arr(oXmlAux:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFLEVEL, "_LISTOFLEVEL")
		            EndIf					
					
					nTamRet	:= Len(oXmlAux:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFLEVEL)
					
					For nI := 1 to nTamRet
						If Type("oXmlAux:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFLEVEL["+AllTrim(STR(nI))+"]:_LEVEL:_EVENT") <> "U"
							If oXmlAux:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFLEVEL[nI]:_LEVEL:_EVENT:TEXT == "delete"
								cValInt := oXmlAux:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFLEVEL[nI]:_LEVEL:_LEVELINTERNALID:TEXT
								CFGA070Mnt( , "RB6", "RB6_NIVEL", , cValInt, .T. )
								nTamFaixa := Len(oXmlAux:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFLEVEL[nI]:_LEVEL:_LISTOFLEVELRANGE) 

								For nX := 1 to nTamFaixa
									cValInt := oXmlAux:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_LISTOFLEVEL[nI]:_LEVEL:_LISTOFLEVELRANGE[nX]:_LEVELRANGE:_RANGEINTERNALID:TEXT
									CFGA070Mnt( , "RB6", "RB6_FAIXA", , cValInt, .T. )
								Next nX
							EndIf
						EndIf
					Next nI
				Else
					lRet    := .F.
					cMsgStatus :='<Message type="ERROR" code="c2">' + STR0016 + '</Message>'// 'Houve um erro na mensagem e este não pôde ser identificado.'
				EndIf				
			Else
				lRet := .F.
				cXMLRet := 	'<Return>' + STR0012 + cXmlErro + STR0013 + cXmlWarn + '</Return>' //Xml mal formatado ### ou ###
			EndIf
		EndIf
	ElseIf	cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000'
    Endif

ElseIf nTypeTrans == TRANS_SEND
	
	If !Inclui .AND. !Altera
		cEvento	:=	"delete"
	EndIf
	
	//Monta XML de envio de mensagem unica
	cXMLRet := '<BusinessEvent>'
	cXMLRet += 	'<Entity>WAGETABLE</Entity>'
	cXMLRet += 	'<Event>'+cEvento+'</Event>'
	cXMLRet += 	'<Identification>'
	cXMLRet += 		'<key name="InternalId">' + cEmpAnt+ '|' +xFilial("RBR") + '|' + RBR->RBR_TABELA+ '</key>'
	cXMLRet += 	'</Identification>'
	cXMLRet += '</BusinessEvent>'
	cXMLRet += '<BusinessContent>'
	cXMLRet += 	'<CompanyId>'+cEmpAnt+'</CompanyId>'				//Codigo da empresa
	//cXMLRet += 	'<BranchId>'+xFilial("RBR")+'</BranchId>'			//RBR_FILIAL	Codigo da Filial	
	cXMLRet += 	'<BranchId>'+cFilAnt+'</BranchId>'			//RBR_FILIAL	Codigo da Filial	
	cXMLRet += 	'<CompanyInternalId>' + cEmpAnt+ '|' + xFilial("RBR") + '</CompanyInternalId>'	
	cXMLRet += 	'<TableCode>'+RBR->RBR_TABELA+'</TableCode>'			//RBR_TABELA	Codigo da Tabela	
	cXMLRet += 	'<TableCodeInternalId>'  + cEmpAnt+ '|' +xFilial("RBR") + '|' + RBR->RBR_TABELA+ '</TableCodeInternalId>'
	cXMLRet += 	'<TableName>'+RBR->RBR_DESCTA+'</TableName>'			//RBR_DESCTA	Descrição da Tabela
				   
	dbSelectArea("RB6")	
	RB6->(dbSetOrder(nOrdRB6))	//RB6_FILIAL + RB6_TABELA + DTOS(RB6_DTREF)
	
	If RB6->( dbSeek(xFilial("RB6")+RBR->RBR_TABELA+DTOS(RBR->RBR_DTREF)) )
			
		While !RB6->(EOF()) .And. RB6->RB6_FILIAL+RB6->RB6_TABELA+DTOS(RB6->RB6_DTREF) == ;
									xFilial("RB6")+RBR->RBR_TABELA+DTOS(RBR->RBR_DTREF)
			 
			If cNivel <> RB6->RB6_NIVEL
				If !Empty(cNivel)
					cXMLRet += 	'</Level>'
					cXMLRet += 	'</ListOfLevel>'			
				EndIf
				lEndList	:= .T.
				cXMLRet += 	'<ListOfLevel>'														//Lista de Niveis Salariais
				cXMLRet += 		'<Level>'		
				cXMLRet += 			'<TableLevel>'+RB6->RB6_NIVEL+'</TableLevel>'            	//RB6_NIVEL	Nivel da Tabela Salarial
				cXMLRet += 			'<LevelInternalId>'+ cEmpAnt+ '|' + xFilial("RB6") + '|' + RB6->RB6_TABELA + RB6->RB6_NIVEL +'</LevelInternalId>'
				cNivel := RB6->RB6_NIVEL
			EndIf				
				cXMLRet += 			'<ListOfLevelRange>'												//Lista de Faixas Salariais
				cXMLRet += 				'<LevelRange>'
				cXMLRet += 					'<TableLevelRange>'+RB6->RB6_FAIXA+'</TableLevelRange>'  //RB6_FAIXA	Faixa da Tabela Salarial
				cXMLRet += 					'<RangeInternalId>'+ cEmpAnt+ '|' + xFilial("RB6") + '|' + RB6->RB6_TABELA + RB6->RB6_NIVEL + RB6->RB6_FAIXA +'</RangeInternalId>'
				cXMLRet += 					'<TableLevelValue>'+AllTrim(Str(RB6->RB6_VALOR))+'</TableLevelValue>'  	//RB6_VALOR	Valor da Faixa Salarial
				cXMLRet += 				'</LevelRange>'
				cXMLRet += 			'</ListOfLevelRange>'
			RB6->(dbSkip())
		EndDo
		
		//Finaliza a ultima tag xml do ultimo nivel 
	    If lEndList	    
			cXMLRet += 	'</Level>'
			cXMLRet += 	'</ListOfLevel>'
		EndIf
		
		//Verifica a existência de arquivos deletados, e se ainda assim existir no XXF o comando de deleção é executado
		If cEvento	== "upsert"
			
			//-- Query para obter as tabelas apagadas
			BeginSql alias cAliasRB6
				SELECT RB6_FILIAL
				     , RB6_TABELA
				     , RB6_NIVEL
				     , RB6_FAIXA
				     , RB6_VALOR
				FROM %table:RB6% RB6
				WHERE RB6_FILIAL = %exp:xFilial("RB6")% 
				  AND RB6_TABELA = %exp:RBR->RBR_TABELA%
				  AND RB6.D_E_L_E_T_ = '*'
			EndSql
			
			cNivel	:= ""
			While !(cAliasRB6)->(Eof())
				dbSelectArea("XXF")
				XXF->(dbSetOrder(nOrdXXF))	//XXF_ALIAS+XXF_FIELD+XXF_INTVAL
				If !XXF->( dbSeek( "RB6"+"RB6_FAIXA"+ cEmpAnt+ '|' + (cAliasRB6)->RB6_FILIAL + '|' + (cAliasRB6)->RB6_TABELA + (cAliasRB6)->RB6_NIVEL + (cAliasRB6)->RB6_FAIXA  ) )	
					
					If cNivel <> (cAliasRB6)->RB6_NIVEL
						If !Empty(cNivel)
							cXMLRet += 	'</Level>'
							cXMLRet += 	'</ListOfLevel>'			
						EndIf
						lEndDelList	:= .T.
						cXMLRet += 	'<ListOfLevel>'														//Lista de Niveis Salariais
						cXMLRet += 		'<Level>'		
						cXMLRet +=			'<Event>delete</Event>'
						cXMLRet += 			'<TableLevel>'+(cAliasRB6)->RB6_NIVEL+'</TableLevel>'            	//RB6_NIVEL	Nivel da Tabela Salarial
						cXMLRet += 			'<LevelInternalId>'+ cEmpAnt+ '|' + (cAliasRB6)->RB6_FILIAL + '|' + (cAliasRB6)->RB6_TABELA + (cAliasRB6)->RB6_NIVEL +'</LevelInternalId>'
						cNivel := (cAliasRB6)->RB6_NIVEL
					EndIf				
						cXMLRet += 			'<ListOfLevelRange>'												//Lista de Faixas Salariais
						cXMLRet += 				'<LevelRange>'
						cXMLRet +=					'<Event>delete</Event>'
						cXMLRet += 					'<TableLevelRange>'+(cAliasRB6)->RB6_FAIXA+'</TableLevelRange>'  //RB6_FAIXA	Faixa da Tabela Salarial
						cXMLRet += 					'<RangeInternalId>'+ cEmpAnt+ '|' + (cAliasRB6)->RB6_FILIAL + '|' + (cAliasRB6)->RB6_TABELA + (cAliasRB6)->RB6_NIVEL + (cAliasRB6)->RB6_FAIXA +'</RangeInternalId>'
						cXMLRet += 					'<TableLevelValue>'+AllTrim(Str((cAliasRB6)->RB6_VALOR))+'</TableLevelValue>'  	//RB6_VALOR	Valor da Faixa Salarial
						cXMLRet += 				'</LevelRange>'
						cXMLRet += 			'</ListOfLevelRange>'
				EndIf
				(cAliasRB6)->(dbskip())
			EndDo 
		EndIf                                                             
		
		//Finaliza a ultima tag xml do ultimo nivel 
	    If lEndDelList	    
			cXMLRet += 	'</Level>'
			cXMLRet += 	'</ListOfLevel>'
		EndIf
	
	EndIf
		
	cXMLRet += '</BusinessContent>'
	
EndIf

RestArea(aArea)

cXMLRet := Encodeutf8(cXMLRet)

Return { lRet, cXMLRet }