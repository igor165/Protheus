#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJI121.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJI121

Funcao de integracao com o adapter EAI para envio/recebimento do cadastro de
Cadastro de Estacao (SLG) utilizando o conceito de mensagem unica.
XSD da Mensagem = ListOfStationSalePoint

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans    Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Vendas Cliente      
@version P12
@since   08/10/2015
@return  lRet - (boolean)  Indica o resultado da execução da função
         cXmlRet - (caracter) Mensagem XML para envio         
/*/
//-------------------------------------------------------------------------------------------------

Function LOJI121(cXml, nTypeTrans, cTypeMsg)

Local cError 	:= ""  //Erros no XML
Local cWarning  := ""  //Avisos no XML
Local cVersao	:= ""  //Versao da Mensagem
Local cXmlRet	:= ""  //Mensagem de retorno da integracao
Local lRet		:= .T. //Retorno da integracao
Local oXmlLj121 := xmlParser(cXml, "_", @cError, @cWarning) //Objeto XML

//Validacoes de erro no XML
If oXmlLj121 <> Nil .And. Empty(cError) .And. Empty(cWarning)
	//Validacao de versao
	If XmlChildEx(oXmlLj121:_TOTVSMessage:_MessageInformation, "_VERSION") <> Nil .And.; 
		!Empty(oXmlLj121:_TOTVSMessage:_MessageInformation:_version:Text)
		
		cVersao := StrTokArr(oXmlLj121:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
		
		//Valida se versao implementada
		If cVersao == "1"																																	
			v1000(oXmlLj121, cTypeMsg, @lRet, @cXmlRet, nTypeTrans)													   						   		   			  																					   		   		     						
		Else
			lRet 	 := .F.
			cXmlRet := STR0001 //#"A versao da mensagem informada nao foi implementada!"	
		EndIf				
	Else
		lRet 	 := .F.
		cXmlRet := STR0002 //#"Versao da mensagem nao informada!"	
	EndIf
Else
	lRet 	 := .F.
	cXmlRet := STR0003 //#"Erro no parser!" 
EndIf

Return {lRet, cXmlRet, "LISTOFSTATIONSALEPOINT"}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Rotina para processar a mensagem tipo RECEIVE e BUSINESS
Efetua a gravacao da Estacao de Trabalho (SLG).

@param   oXmlLj121	Objeto contendo a mensagem (XML)
@param   cTypeMsg    	Tipo da mensagem 
@param   lRet  		Indica o resultado da execução da função
@param   cXmlRet  		Mensagem Xml para envio
@param   nTypeTrans   Tipo da transação

@author  Vendas Cliente      
@version P12
@since   08/10/2015
@return  Nil

/*/
//-------------------------------------------------------------------------------------------------

Static Function v1000(oXmlLj121, cTypeMsg, lRet, cXmlRet, nTypeTrans)

Local cEvent 	 	:= "" 				//Evento do Cadastro de Estacao
Local cMarca	 	:= ""				//Marca da mensagem
Local cValInt	 	:= "" 				//Codigo interno utilizado no De/Para de codigos - Tabela XXF
Local cValExt	 	:= "" 				//Codigo externo utilizada no De/Para de codigos - Tabela XXF
Local cXml		 	:= ""				//Xml de resposta	
Local cError 	 	:= "" 				//Erros no XML
Local cWarning 		:= "" 				//Avisos no XML
Local cCodeEst		:= ""				//Codigo da Estacao de Trabalho
Local cDesc			:= ""				//Descricao da Estacao de Trabalho
Local cSeriePdv		:= ""				//Serie da estação do PDV
Local cLocal		:= ""				//Local de Estoque
Local cLocalExt		:= ""				//Local de Estoque Externo
Local cContador		:= ""				//Contador de Reinicio de Operacao
Local cAliasTmp		:= "SLG" 			//Alias temporario
Local cFieldTmp 	:= "LG_CODIGO" 		//Campo temporario
Local nI		 	:= 0 				//Contador
Local nX		 	:= 0 				//Contador
Local nEvento		:= 0				//Evento da integracao
Local aAux		 	:= {}				//Array auxiliar no De-Para
Local aEstacoes		:= {}				//Array contendo as Estacoes de Trabalho
Local aErroAuto		:= {}				//Array que armazenara Erros do ExecAuto
Local oXmlContent	:= Nil 				//Objeto Xml com o conteudo da BusinessContent apenas
Local cSerSAT		:= ""				//Serie do equipamento SAT
Local cSerPDV		:= ""				//Serie do PDV
Local cPrefPDV		:= ""				//Prefixo do PDV

Private lMsErroAuto	  := .F.
Private lAutoErrNoFile := .T.
Private lMsHelpAuto    := .T.

//Mensagem de Recebimento
If nTypeTrans == TRANS_RECEIVE																																															   						   		   			  																					   		   		     			
	If cTypeMsg == EAI_MESSAGE_BUSINESS
		//Validacao do EAI                  		   		                                                           		
		If ExistFunc("CFGA070INT")	
			//Verifica Marca	
			If XmlChildEx(oXmlLj121:_TOTVSMessage:_MessageInformation:_Product, "_NAME") <> Nil .And.;
				!Empty(oXmlLj121:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			
				cMarca := oXmlLj121:_TotvsMessage:_MessageInformation:_Product:_Name:Text //Armazena marca
												         			         		
	         	//Efetua a carga do objeto Codigo de Estacao			     	
				oXmlContent := oXmlLj121:_TOTVSMessage:_BusinessMessage:_BusinessContent
				
				//Inclui/Altera/Exclui Codigo de Barras do Produto - SLK (SigaLoja)
      			If XmlChildEx(oXmlContent, "_LISTOFSTATIONSALEPOINT") <> Nil .And.;
      				XmlChildEx(oXmlContent:_ListOfStationSalePoint, "_STATIONSALEPOINT") <> Nil
      				      				 						
					If ValType(oXmlContent:_ListOfStationSalePoint:_StationSalePoint) <> "A"
          				//Transforma em array
         				XmlNode2Arr(oXmlContent:_ListOfStationSalePoint:_StationSalePoint, "_StationSalePoint")
         			EndIf																				
					
					//Percorre a lista adicionando informacoes para cadastro
					For nI := 1 to Len(oXmlContent:_ListOfStationSalePoint:_StationSalePoint)
						//limpa as variaveis
						cSerSAT := ""
						cSerPDV := ""
						
						If XmlChildEx(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI], "_EVENT") <> Nil .And.;         	
	         				!Empty(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Event:Text)	         		
						
							//Verifica Evento
							cEvent := AllTrim(Upper(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Event:Text)) //Armazena evento
						
							If XmlChildEx(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI], "_INTERNALID") <> Nil //InternalId do Codigo de Estacoes				
								cValExt := oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_InternalId:Text
							EndIf
					
							//------------------------------------------------------------
							//Tratamento utilizando a tabela XXF com um De/Para de codigos
							//------------------------------------------------------------ 			
							aAux := IntEstacInt(cValExt, cMarca, /*Versao*/)
							
							//Protheus nao possui tratamento para inativar Estacao de Trabalho, portanto,
			            	//quando evento Update e a tag logica <Active> conter o valor false, significa que 
							//esta inativa, sera efetuada a exclusao da Estacao no Protheus.	
							If cEvent == "UPSERT" .And. XmlChildEx(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI], "_ACTIVE") <> Nil .And.;
			            		AllTrim(Upper(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Active:Text)) == "FALSE"
			            		
			            		cEvent	:= "DELETE" //Altera o evento para delete
			            	EndIf
							
							//Se o evento Upsert
							If cEvent == "UPSERT"
								SLG->(dbSetOrder(1))
								
								//Verifica se o registro foi encontrado
			            		If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]  			            					            						            						            							            							            		
				            		cCodeEst := PadR(aAux[2][3], TamSX3("LG_CODIGO")[1]) //Codigo da Estacao
			            				            			
			            			//Monta o InternalId de produto que será gravado na table XXF (de/para)
			              	 		cValInt := IntEstacExt(/*Empresa*/, /*Filial*/, cCodeEst, /*Versão*/)[2] 	
			               		
			               			//Update
						          	nEvento := 4		               					               		
			               		Else
			               			If Empty(Posicione("SX3", 2, PadR("LG_CODIGO", 10), "X3_RELACAO"))				               						               							               		
				               			//Validacao do Codigo da Estacao
				               			If XmlChildEx(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI], "_CODE") <> Nil .And.;
				               				!Empty(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Code:Text)
				               			
					               			If TamSx3("LG_CODIGO")[1] >= Len(AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Code:Text))				               						               			                			               		
					               				cCodeEst := PadR(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Code:Text, TamSX3("LG_CODIGO")[1]) //Codigo da Estacao	
					               		
						               			//Necessario este tratamento para impedir erro quando ocorre Cadastro de Estacao manual e automatica
						               			If SLG->(dbSeek(xFilial("SLG") + cCodeEst))
						               				//Update
						            				nEvento := 4
							               		Else
							               			//Insert
						            				nEvento := 3 
						            			EndIf			            						            			
						            						            						                  		
							                  	//Monta o InternalId de produto que será gravado na table XXF (de/para)
							               		cValInt := IntEstacExt(/*Empresa*/, /*Filial*/, cCodeEst, /*Versão*/)[2]						               								               		
							              	Else
						    	           		lRet 	 := .F.
					            	   			cXmlRet := STR0004 + " " + AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Code:Text) //#"O codigo da Estacao de Trabalho:"
					               				cXmlRet += " " + STR0005 + STR0006 + " " + CValToChar(TamSx3("LG_CODIGO")[1]) + "," + STR0007 //#"possui tamanho maior que o permitido." ##"Maximo:" ###"enviado:"
					               				cXmlRet += " " + CValToChar(Len(AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Code:Text)))
					               				Exit 
							              	EndIf						              							              	
										Else
						              		lRet    := .F.
						              		cXmlRet := STR0008 + " " + AllTrim(cValExt) + "," + STR0009 //#"Codigo nao informado para o item:" ##"esta informacao é obrigatoria para inclusao!" 
						              		Exit
										EndIf						              						              						              						              						              						              
					      			Else
					               		//Insert
					            		nEvento := 3 
					           		EndIf               		               		
			               		EndIf
			               	
			               		//Tratamento Serie da Estacao de Trabalho
			               		If lRet				              	
									If XmlChildEx(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI], "_SERIES") <> Nil .And.;
			               				!Empty(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Series:Text)
			               				
			               				If TamSx3("LG_SERIE")[1] >= Len(AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Series:Text))				               						               			                			               		
					               			cSeriePdv := PadR(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Series:Text, TamSX3("LG_SERIE")[1]) //Serie da Estacao
					               		Else
					               			lRet 	 := .F.
				               				cXmlRet := STR0017 + " " + AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Series:Text) //#"A Serie da Estacao de Trabalho:" 
				               				cXmlRet += " " + STR0005 + STR0006 + " " + CValToChar(TamSx3("LG_CODIGO")[1]) + "," + STR0007 //"possui tamanho maior que o permitido."##"Maximo:" ###"enviado:" 
				               				cXmlRet += " " + CValToChar(Len(AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Series:Text)))
				               				Exit 
					               		EndIf							               									               					               				
			               			Else
			               				lRet 	:= .F.
			               				cXmlRet := STR0018 + " " + AllTrim(cValExt) + "," + STR0009 //#"Serie nao informada para o item:"##"esta informacao é obrigatoria!"
			               				Exit	
									EndIf 
								EndIf

								//Serie ECF
								If lRet .And. XmlChildEx(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI], "_FISCALSERIE") <> Nil .And.;
									!Empty(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_FiscalSerie:Text)
									
									If TamSx3("LG_SERPDV")[1] >= Len(AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_FiscalSerie:Text))				               						               			                			               		
					               		cSerPDV := PadR(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_FiscalSerie:Text, TamSX3("LG_SERPDV")[1])
					               	Else
					               		lRet	:= .F.
				               			cXmlRet	:= STR0021 + " " + AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_FiscalSerie:Text) //#"A série do PDV:" 
				               			cXmlRet	+= " " + STR0005 + STR0006 + " " + CValToChar(TamSx3("LG_SERPDV")[1]) + "," + STR0007 //"possui tamanho maior que o permitido."##"Maximo:" ###"enviado:" 
				               			cXmlRet	+= " " + CValToChar(Len(AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_FiscalSerie:Text)))
				               			Exit 
					               	EndIf
								EndIf

								//Série SAT
								If lRet .And. XmlChildEx(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI], "_SATSERIE") <> Nil .And.;
									!Empty(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_SATSerie:Text)

									If TamSx3("LG_SERSAT")[1] >= Len(AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_SATSerie:Text))				               						               			                			               		
					               		cSerSAT := PadR(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_SATSerie:Text, TamSX3("LG_SERSAT")[1])
                                          
                                        //Verifica se houve alteração no numero do equipamento SAT
                                        //se o Numero foi alterado será criado um nova estação para esse novo SAT com uma nova Serie
                                        If ExistFunc("LjINewEst") .And. ExistFunc("LjINewSer")  
                                            If nEvento == 4 .And. AllTrim(cSerSAT) <> AllTrim(SLG->LG_SERSAT)    
                                                CFGA070Mnt(cMarca, cAliasTmp, cFieldTmp, cValExt, IntEstacExt(,,cCodeEst)[2] , .T.)                                            
                                                cCodeEst  := LjINewEst(cCodeEst)
                                                cSeriePdv := LjINewSer(SLG->LG_SERIE)
                                                nEvento   := 3 //Troca o método para criar nova estacao para o novo SAT 
                                               
                                                cValInt := IntEstacExt(,,cCodeEst)[2] 
                                            EndIf    
                                        EndIf
					               	Else
					               		lRet	:= .F.
				               			cXmlRet	:= STR0022 + " " + AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_SATSerie:Text) //#"A série do equipamento SAT:" 
				               			cXmlRet	+= " " + STR0005 + STR0006 + " " + CValToChar(TamSx3("LG_SERSAT")[1]) + "," + STR0007 //"possui tamanho maior que o permitido."##"Maximo:" ###"enviado:" 
				               			cXmlRet	+= " " + CValToChar(Len(AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_SATSerie:Text)))
				               			Exit 
					               	EndIf

                                    //Valida se o SAT não Está em uso por outra Estação nessa filial
                                    If lRet .And. nEvento == 3
                                        If !Empty(LjiSerSLG("",cSerSAT))
                                            lRet	:= .F.
                                            cXmlRet := I18n(STR0023, { AllTrim(cSerSAT), AllTrim(xFilial("SLG")) }) //"A Série #1 do equipamento SAT já está em uso por outra Estação(SLG) na Filial: #2"
                                            Exit 
                                        EndIf    
                                    EndIf    

								EndIf

				               	If lRet
									//Tratamento Serie da Contador Reinicio de Operacao
									If XmlChildEx(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI], "_CRO") <> Nil .And.;
										!Empty(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Cro:Text)
					               					
					               		If TamSx3("LG_CRO")[1] >= Len(AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Cro:Text))				               						               			                			               		
							              	cContador := PadR(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Cro:Text, TamSX3("LG_CRO")[1]) //Contador de Reinicio de Operacao
							            Else
							              	lRet	:= .F.
					               			cXmlRet	:= STR0019 + " " + AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Cro:Text) 
					               			cXmlRet += " " + STR0005 + STR0006 + " " + CValToChar(TamSx3("LG_CRO")[1]) + "," + STR0007 //"possui tamanho maior que o permitido."##"Maximo:" ###"enviado:" 
					               			cXmlRet += " " + CValToChar(Len(AllTrim(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Cro:Text)))
					               			Exit 			
							           	EndIf
					               	Else
					               		lRet	:= .F.
					               		cXmlRet := STR0020 + " " + AllTrim(cValExt) + "," + STR0009 //#"Contador de Reinicio nao informada para o item:"##"esta informacao é obrigatoria!"
					               		Exit
					               	EndIf
								EndIf	
			               	
								If lRet
				               		//Descricao da Estacao
				               		If XmlChildEx(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI], "_DESCRIPTION") <> Nil .And.; 
				               			!Empty(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Description:Text)			               				               				               	
				               		
				               			cDesc := PadR(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_Description:Text, TamSX3("LG_NOME")[1]) 			               	
				               		Else
				               			cDesc := ""
					               	EndIf
			               				               																																										
									//Local de Estoque
									cLocal := ""
								
									If XmlChildEx(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI], "_WAREHOUSEINTERNALID") <> Nil .And.; 
					               		!Empty(oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_WareHouseInternalId:Text)

										cLocalExt := oXmlContent:_ListOfStationSalePoint:_StationSalePoint[nI]:_WareHouseInternalId:Text
										
										aAux := IntLocInt(cLocalExt, cMarca, /*Versão*/)																														
	                  				
	    	              				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
	        	          					cLocal := PadR(aAux[2][3], TamSx3("LG_LOCAL")[1])                  				
	            	      				EndIf																		
									EndIf
									
									aCab := {}
									//Armazena informacoes da Estacao
						            aAdd( aCab, {"LG_CODIGO"	, cCodeEst		, Nil} )
						            aAdd( aCab, {"LG_PDV"		, cCodeEst		, Nil} )
						            aAdd( aCab, {"LG_NOME"		, cDesc			, Nil} )
						            aAdd( aCab, {"LG_CRO"		, cContador		, Nil} )
						            aAdd( aCab, {"LG_SERPDV"	, cSerPDV		, Nil} )
						            aAdd( aCab, {"LG_SERSAT"	, cSerSAT		, Nil} )
						            If nEvento == 3 //Somente alimenta o campo LG_SERIE quando for inclusao
						            	aAdd( aCab, {"LG_SERIE"		, cSeriePdv		, Nil} )
						            EndIf
	                  				If !Empty(Alltrim(cLocal))
	                  					aAdd( aCab, {"LG_LOCAL"	, cLocal		, Nil} )
									Endif
									
									If SLG->(ColumnPos("LG_PREFIXO")) > 0
										cPrefPDV := Lj121Pref()
										aadd(aCab,{"LG_PREFIXO",cPrefPDV,Nil})
									EndIf 
									
                  					//Armazena informacoes nos arrays de controle
			            			aAdd(aEstacoes, {aCab, {cValExt, cValInt}, nEvento})
			            		EndIf 			            		
							ElseIf cEvent == "DELETE" //Se o evento Delete
								//Se o registro foi encontrado
			            		If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
			               			//Delete
			               			nEvento := 5 
			            		
			            			cCodeEst := PadR(aAux[2][3], TamSX3("LG_CODIGO")[1]) //Codigo da Estacao
			            
			            			//Monta o InternalId de produto que será gravado na table XXF (de/para)
			            			cValInt := IntEstacExt(/*Empresa*/, /*Filial*/, cCodeEst, /*Versão*/)[2]
			            			
			            			//Armazena informacoes da Estacao
			            			aCab := {{"LG_CODIGO", cCodeEst, Nil}}                  			
                  							            			
			            			//Armazena informacoes no array
			            			aAdd(aEstacoes, {aCab, {cValExt, cValInt}, nEvento}) //Codigo da Estacao			            		                
			            		EndIf 
							EndIf														
	         			Else
	         				lRet    := .F.
	          				cXmlRet := STR0010 //#"O evento e obrigatorio"
	          				Exit
	         			EndIf		         		
		         	Next nI
		         	
		         	//Efetua os cadastros
					If lRet
						BEGIN TRANSACTION
						
						For nI := 1 To Len(aEstacoes) 
							//Efetua o cadastro (Inclusao, Alteracao ou Exclusao)         				         					
         					MSExecAuto({|a,b,c,d| LOJA121(a,b,c,d)}, Nil, Nil, aEstacoes[nI][1], aEstacoes[nI][3])
							
							If lMsErroAuto
								aErroAuto := GetAutoGRLog()
	
	            				cXmlRet := "<![CDATA["            				
	            				For nX := 1 To Len(aErroAuto)
	               					cXmlRet += aErroAuto[nX] + Chr(10)
	            				Next nX            				
	            				cXmlRet += "]]>"
	
	            				DisarmTransaction()
	
	            				lRet := .F.  								
								Exit															 
							EndIf
						Next nI
						
						END TRANSACTION
					EndIf
					
					//Gera mensagem de retorno
					If lRet
						cXmlRet := "<ListOfInternalId>"
						
						For nI := 1 To Len(aEstacoes)
							If aEstacoes[nI][3] <> 5
		            			//Grava na Tabela XXF (de/para)
	                  			CFGA070Mnt(cMarca, cAliasTmp, cFieldTmp, aEstacoes[nI][2][1], aEstacoes[nI][2][2])
	                  		Else //Exclusao
	                  			//Exclui na Tabela XXF (de/para)
	               				CFGA070Mnt(cMarca, cAliasTmp, cFieldTmp, aEstacoes[nI][2][1], aEstacoes[nI][2][2], .T.)
	                  		EndIf
													            					
            				cXmlRet +=    "<InternalId>"
            				cXmlRet +=       "<Name>StationSalePointInternalId</Name>"
            				cXmlRet +=       "<Origin>" + aEstacoes[nI][2][1] + "</Origin>"
            				cXmlRet +=       "<Destination>" + aEstacoes[nI][2][2] + "</Destination>"
            				cXmlRet +=    "</InternalId>"             				            				           					            					  
						Next nI
						
						cXmlRet += "</ListOfInternalId>"
					EndIf 
		   		EndIf
			Else
				lRet 	 := .F.
				cXmlRet := STR0011 //#"Marca nao integrada ao Protheus, verificar a marca da integracao"
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0012 //#"Atualize EAI"
		EndIf		
	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
		cXmlRet := "<TAGX>RECEPCAO RESPONSE MESSAGE</TAGX>"					
	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS	
		cXmlRet := "1.000"
	EndIf		
EndIf

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntEstacInt

Recebe um InternalID e retorna o código de Estacao Protheus

@param   cInternalID	InternalID recebido na mensagem
@param   cRefer    	Produto que enviou a mensagem 
@param   cVersao  		Versão da mensagem única (Default 1.000)

@author  Vendas Cliente      
@version P12
@since   08/10/2015
@return  Array contendo no primeiro parâmetro uma variável logica
		  indicando se o registro foi encontrado no de/para
		  No segundo parâmetro uma variável array com empresa, filial
		  e o codigo da estacao.

/*/
//-------------------------------------------------------------------------------------------------

Function IntEstacInt	(cInternalID, cRefer, cVersao)
   
Local aResult   := {}
Local aTemp     := {}
Local cTemp     := ""
Local cAliasTmp := "SLG"
Local cFieldTmp := "LG_CODIGO"

Default cVersao  := "1.000"

cTemp := CFGA070Int(cRefer, cAliasTmp, cFieldTmp, cInternalID)

aEmpFil:= StrTokArr(cTemp,"|")
	
//Cerifica no cadastro de Estacao se realmente a entidade Existe.
If !Empty(cTemp)
	DbSelectArea("SLG")
	SLG->(DbSetOrder(1))
	If!(SLG->(DbSeek(Padr(aEmpFil[2],FWSizeFilial())+Padr(aEmpFil[3],3))))
		cTemp := ""
	Endif
Endif
   
If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, STR0013 + " " + AllTrim(cInternalID) + " " + STR0014) //#"Estacao" ##"nao encontrado no de/para!"
Else
	If cVersao == "1.000"
		aAdd(aResult, .T.)
       aTemp := Separa(cTemp, "|")
       aAdd(aResult, aTemp)	     
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0015 + Chr(10) + STR0016 + "1.000") //#"Versao nao suportada." ##"As versoes suportadas sao:"        
   EndIf
EndIf
  
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntEstacExt

Monta o InternalID da Estacao de acordo com codigo passado

@param   cEmpresa	Código da empresa (Default cEmpAnt)
@param   cFil    	Código da Filial (Default cFilAnt) 
@param   cEstacao Código da Estacao
@param   cVersao  Versao da Mensagem

@author  Vendas Cliente      
@version P12
@since   02/10/2015
@return  Array contendo no primeiro parâmetro uma variável logica
		  indicando se o registro foi encontrado
		  No segundo parâmetro uma variável string com o InternalID
		  montado              

/*/
//-------------------------------------------------------------------------------------------------

Function IntEstacExt(cEmpresa, cFil, cEstacao, cVersao)
   
Local aResult := {}

Default cEmpresa 	:= cEmpAnt
Default cFil     	:= xFilial("SLG")
Default cEstacao	:= ""
Default cVersao	:= "1.000"

If cVersao == "1.000"
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + "|" + RTrim(cFil) + "|" + PadR(cEstacao, TamSx3("LG_CODIGO")[1])) 					
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0015 + Chr(10) + STR0016 + "1.000") //#"Versao nao suportada." ##"As versoes suportadas sao:" 
EndIf
   
Return aResult