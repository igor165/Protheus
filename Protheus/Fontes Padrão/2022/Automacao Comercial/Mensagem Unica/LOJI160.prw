#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJI160.CH"
#INCLUDE "FWADAPTEREAI.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJI160

Rotina para integrar Reduzao Z via Mensagem Unica.
XSD da Mensagem = Reduction

@param   cXml           Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans    Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Vendas Cliente      
@version P12
@since   16/02/2016
@return  lRet - (boolean)  Indica o resultado da execução da função
         cXmlRet - (caracter) Mensagem XML para envio         
/*/
//-------------------------------------------------------------------------------------------------

Function LOJI160(cXml, nTypeTrans, cTypeMsg)

Local cError 	 := "" 	//Erros no XML
Local cWarning   := "" 	//Avisos no XML
Local cVersao	 := "" 	//Versao da Mensagem
Local cXmlRet	 := "" 	//Mensagem de retorno da integracao
Local cMarca	 := ""  	//Armazena a Marca que enviou o XML
Local cValExt	 := "" 	//Codigo externo utilizada no De/Para de codigos - Tabela XXF
Local cValInt	 := "" 	//Codigo interno utilizada no De/Para de codigos - Tabela XXF
Local cAlias     := "SFI" //Tabela De-Para
Local cCampo     := "FI_DTMOVTO" //Campo De-Para
Local lRet		 := .T. 	//Retorno da integracao
Local nCount	 := 0 		//Contador
Local oXmlL160   := Nil 	//Objeto XML

//Verifica tipo da mensagem
If cTypeMsg == EAI_MESSAGE_BUSINESS
	If nTypeTrans == TRANS_RECEIVE //Mensagem de Recebimento
		oXmlL160	:= xmlParser(cXml, "_", @cError, @cWarning) //Objeto XML

		//Validacoes iniciais do XML
		If oXmlL160 <> Nil .And. Empty(cError) .And. Empty(cWarning)				
			If !Empty(LjiVldTag(oXmlL160:_TOTVSMessage:_MessageInformation, "_VERSION"))															
				cVersao := oXmlL160:_TOTVSMessage:_MessageInformation:_version:Text							                 	               	
	
				//Valida versao do XML          
				If StrTokArr(cVersao, ".")[1] $ "1"
					v1000(oXmlL160, nTypeTrans, @lRet, @cXmlRet)
				Else
					lRet := .F.
					cXmlRet := STR0003 //"A versao da mensagem informada nao foi implementada!"						 																																																				   						   		   			  																					   		   		     							   														
				EndIf
			Else
				lRet := .F.
				cXmlRet := STR0002 //#"Versao da mensagem nao informada!"
			EndIf
		Else
			lRet := .F.
			cXmlRet := STR0001 //#"Erro no parser!" 
		EndIf
	ElseIf nTypeTrans == TRANS_SEND //Mensagem de Envio
		v1000(oXmlL160, nTypeTrans, @lRet, @cXmlRet)
	EndIf
ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
	//Gravacao do De/Para Codigo Interno X Codigo Externo  	
	oXmlL160 := xmlParser(cXml, "_", @cError, @cWarning) //Objeto XML

	//Validacoes de erro no XML
	If oXmlL160 <> Nil .And. Empty(cError) .And. Empty(cWarning)				
		If Upper(oXmlL160:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"			
			If oXmlL160:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And.; 
				!Empty(oXmlL160:_TotvsMessage:_MessageInformation:_Product:_Name:Text)			 					
				
				cMarca := oXmlL160:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			EndIf
						   	
			If oXmlL160:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text <> Nil .And.; 
				!Empty(oXmlL160:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text <> Nil)	
				
				cValInt := oXmlL160:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
			EndIf
			   	
			If oXmlL160:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text <> Nil .And.; 
				!Empty(oXmlL160:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text <> Nil)	
				
				cValExt := oXmlL160:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
			EndIf 
		   	  
			If !Empty(cValExt) .And. !Empty(cValInt)				  
				If CFGA070Mnt(cMarca, cAlias, cCampo, cValExt, cValInt) 					
					lRet := .T.										
				EndIf
	      	Else	      		
	       	lRet := .F.	       		       	
	       EndIf	       
		Else //Erro
	   		If oXmlL160:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message <> Nil 	   		
       		//Se não for array
       		If ValType(oXmlL160:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) <> "A"
              	//Transforma em array
              	XmlNode2Arr(oXmlL160:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            	EndIf
	
	          	//Percorre o array para obter os erros gerados
	          	For nCount := 1 To Len(oXmlL160:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
	          		cError := oXmlL160:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + CRLF
	          	Next nCount
	
	          	lRet 	 := .F.
	          	cXmlRet := cError	          		          	          		         	
			EndIf
	   	EndIf
	EndIf	
ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
	cXmlRet := "1.000|1.001"
EndIf

Return {lRet, cXmlRet, "REDUCTION"}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Rotina para processar a mensagem tipo RECEIVE e BUSINESS
Efetua a gravacao da Reducao Z - SFI.

@param   oXmlL160    	Objeto contendo a mensagem (XML)
@param   cTypeMsg 	Tipo da mensagem
@param   lRet  		Indica o resultado da execução da função
@param   cXmlRet  		Mensagem Xml para envio

@author  Vendas Cliente      
@version P12
@since   16/02/2016
@return  Nil
                  
/*/
//-------------------------------------------------------------------------------------------------

Static Function v1000(oXmlL160, nTypeTrans, lRet, cXmlRet)

Local aArea		:= GetArea()
Local cDataMovto	:= "" //Data da Reducao Z
Local cDataEmis	:= "" //Data de Emissao da Reducao Z
Local cTimeEmis	:= "" //Hora de Emissao da Reducao Z
Local cCOOIni  	:= "" //Numero inicial do cupom da data do movimento
Local cValInt		:= "" //Codigo interno utilizada no De/Para de codigos - Tabela XXF
Local cMarca		:= "" //Armazena a Marca que enviou o XML	
Local cEstacao	:= "" //Codigo da Estacao
Local cCodRed		:= "" //Codigo da Reducao
Local cCpoBase	:= "" //Campo Base ICMS da Tabela SFI
Local cIdExt		:= "" //Identificacao externa do registro
Local cEvent   	:= "" //Evento
Local cWhere		:= "" //Condicional da query
Local cEstInt		:= "" //InternalId da Estacao de Trabalho
Local cDateMovto	:= "" //Data do Movimento
Local cDateRedu	:= "" //Data da Reducao
Local cCampo		:= "" //Campos Base impostos
Local cAliasTmp 	:= GetNextAlias() //Alias temporario
Local nGTIni		:= 0  //Contador do Grande Total (ECF)
Local nOutrosR	:= 0  //Outros Recebimentos
Local nBas001		:= 0  //Base 001 
Local nImpDebt	:= 0  //Total de impostos (Tributo)
Local nI			:= 0  //Contador	
Local nBase		:= 0  //Base de ICMS
Local nAcres		:= 0  //Acrescimos
Local dDataBkp 	:= dDataBase //Backup de database
Local aReducao	:= {} //Array auxiliar para leitura dos dados da reducao e gravacao do SFI
Local aField		:= {} //Array de campos e valores de Impostos
Local aAreas		:= {} //Array com areas das tabelas
Local aInternal	:= {} //Array Auxiliar para armazenas InternalId gerado no Protheus
Local aAliqs		:= {} //Armazena aliquotas
Local oXmlContent	:= Nil //Objeto Xml com o conteudo da BusinessContent apenas

//Armazena areas das Tabelas
aAdd(aAreas, SLG->(GetArea()))
aAdd(aAreas, SFI->(GetArea()))

//Mensagem de Recebimento
If nTypeTrans == TRANS_RECEIVE									
	//------------------------------------------------------------
	//Tratamento utilizando a tabela XXF com um De/Para de codigos
	//------------------------------------------------------------                   		   		                                                           		
	If ExistFunc("CFGA070INT")
		//Marca
		If oXmlL160:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And. !Empty(oXmlL160:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			cMarca := oXmlL160:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		EndIf
			
		If Empty(cMarca)					
			lRet	 := .F.
			cXMLRet := STR0004 //#"Marca nao integrada ao Protheus, verificar a marca da integracao"		
		EndIf
			
		If lRet
			If oXmlL160:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text <> Nil .And.; 
				!Empty(oXmlL160:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
					
				If AllTrim(Upper(oXmlL160:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)) == "DELETE"
					lRet    := .F.
					cXMLRet := STR0030 //#"Evento incorreto, exclusao nao permitido para Reducao Z."									
				EndIf
			Else
				lRet    := .F.
				cXMLRet := STR0031 //#"Evento nao informado!" 
			EndIf
		EndIf	
				
		If lRet																						
			//Gera objeto para carga Redução      	
			oXmlContent := oXmlL160:_TOTVSMessage:_BusinessMessage:_BusinessContent
			
			//Armazena chave externa
			cIdExt := LjiVldTag(oXmlContent, "_INTERNALID")
																																														
			/* Carrega variaveis para integracao */						
		
			//Data do Movimento			
			cDataMovto := LjiVldTag(oXmlContent, "_MOVEMENTDATE", "D")	
																		                                     								
			If Empty(cDataMovto)
				lRet 	 := .F.	
				cXmlRet := STR0005 //#"Data da Reducao nao informada na integracao, verificar a tag: MovementDate"
			EndIf
		EndIf
					
		If lRet
			//Data em que a Reducao Z foi emitida
			cDataEmis := LjiVldTag(oXmlContent, "_ISSUEDATEREDUCTION", "D")
				
			//Horario em que a Reducao Z foi emitida
			cTimeEmis := LjiVldTag(oXmlContent, "_ISSUEDATEREDUCTION", "T")																			 											
				
			//Armazena Estacao
			cEstacao := Padr(LjiVldTag(oXmlContent, "_STATIONCODE",, "LG_CODIGO"), TamSx3("LG_CODIGO")[1])										
			
			//Valida Estacao
			If Empty(cEstacao)					
				lRet 	 := .F.	
				cXmlRet := STR0006 //#"Estacao nao informada na integracao, verifique a Tag StationCode"	
			EndIf
				
			If lRet				
				//Posiciona na Estacao do Protheus
				SLG->(dbSetOrder(1))
			
				If !SLG->(dbSeek(xFilial("SLG") + cEstacao)) 																								
					lRet 	 := .F.	
					cXmlRet := STR0011 + " " + cEstacao + " " + STR0014 //#"Estacao:" ##"nao encontrada no Protheus, verificar o cadastro ou integracao de Estacao." 																	
				EndIf
			EndIf																																														
		EndIf
			
		If lRet
			//Codigo da Reducao
			cCodRed := Padr(LjiVldTag(oXmlContent, "_REDUCTIONCODE"), TamSx3("FI_NUMREDZ")[1])
								
			If Empty(cCodRed) 																								
				lRet 	 := .F.	
				cXmlRet := STR0012 //#"Codigo da Reducao nao informada na integracao, verificar a tag: ReductionCode"																		
			EndIf
		EndIf	
			
		If lRet			 								
			//Verifica se Reducao Z ja foi integrada ao Protheus			
			aAux := IntRedZInt(cIdExt, cMarca)
	         		
	    	//Se encontrou o cliente no de-para
	      	If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
	 	 		lRet 	 := .F.									
				cXmlRet := STR0008 + " " + AllTrim(cIdExt) + " " + STR0009 //#"Reducao Z:" ##"ja integrada ao Protheus"   	
	      	EndIf
	    EndIf
         	
        If lRet
	      	//Verifica se Reducao foi integrada pelo Data do Movimento+PDV+Numero da Reducao
	      	SFI->(dbSetOrder(1))
	         	
	      	If SFI->(dbSeek(xFilial("SFI") + cDataMovto + SLG->LG_PDV + cCodRed))
	      		lRet 	 := .F.									
				cXmlRet := STR0008 + STR0013 + cDataMovto + "," + STR0015 + AllTrim(SLG->LG_PDV) + "," + STR0016 + AllTrim(cCodRed) + " " + STR0009 //#"Reducao Z:" ##"Data:" ###"PDV:" ####"Reducao:" #####"ja integrada no Protheus."  	
	       EndIf
	 	EndIf
			
		If lRet																										
			//Validacoes de outros campos obrigatorios			
			If Empty(cIdExt)
				lRet	 := .F.
				cXmlRet := STR0017 //#"Campo obrigatorio nao informado: Id Interno, verifique a tag: InternalId."
			ElseIf XmlChildEx(oXmlContent, "_INITIALCOUNTER") == Nil .Or. Empty(oXmlContent:_InitialCounter:Text) .Or.;
				Val(oXmlContent:_InitialCounter:Text) <= 0
				
				lRet 	 := .F.
				cXmlRet := STR0018 //#"Campo obrigatorio nao informado ou zerado: Cupom Inicial, verifique a tag: InitialCounter."
			ElseIf XmlChildEx(oXmlContent, "_INITIALVALUE") == Nil .Or. Empty(oXmlContent:_InitialValue:Text)	.Or.;
				Val(oXmlContent:_InitialValue:Text) <= 0
									
				lRet 	 := .F.
				cXmlRet := STR0019 //#"Campo obrigatorio nao informado ou zerado: Grande Total Final do Dia Anterior, verifique a tag: InitialValue."
			ElseIf XmlChildEx(oXmlContent, "_FINALVALUE") == Nil .Or. Empty(oXmlContent:_FinalValue:Text) .Or.;
				Val(oXmlContent:_FinalValue:Text) <= 0
												
				lRet 	 := .F.
				cXmlRet := STR0020 //#"Campo obrigatorio nao informado ou zerado: Grande Total Final do Dia, verifique a tag: FinalValue."
			ElseIf XmlChildEx(oXmlContent, "_FINALCOUNTER") == Nil .Or. Empty(oXmlContent:_FinalCounter:Text) .Or.;
				Val(oXmlContent:_FinalCounter:Text) <= 0
				
				lRet 	 := .F.
				cXmlRet := STR0021 //#"Campo obrigatorio nao informado ou zerado: Cupom Final do Dia, verifique a tag: FinalCounter."
			ElseIf XmlChildEx(oXmlContent, "_COUNTERCODE") == Nil .Or. Empty(oXmlContent:_CounterCode:Text) .Or.;
				Val(oXmlContent:_CounterCode:Text) <= 0
				
				lRet 	 := .F.
				cXmlRet := STR0022 //#"Campo obrigatorio nao informado ou zerado: Contador de Ordem de Operacao, verifique a tag: CounterCode."			
			ElseIf XmlChildEx(oXmlContent, "_COUNTERRESET") == Nil .Or. Empty(oXmlContent:_CounterReset:Text) .Or.;
				Val(oXmlContent:_CounterReset:Text) <= 0	
			
				lRet 	 := .F.
				cXmlRet := STR0023 //#"Campo obrigatorio nao informado ou zerado: Contador de Ordem de Reinicio, verifique a tag: CounterReset."									
			EndIf
		EndIf
			
		If lRet						
			//Armazena informacoes					
			cCOOIni	:= Padr(oXmlContent:_InitialCounter:Text, TamSx3("FI_NUMINI")[1])
			nGTIni		:= Val(StrTran(oXmlContent:_InitialValue:Text, ",", "."))
			nOutrosR	:= Val(LjiVldTag(oXmlContent, "_VALUEOFOTHERSRECEIVABLES", "N"))									
			nImpDebt	:= Val(LjiVldTag(oXmlContent, "_AMOUNTOFTAXDUE", "N"))
			
			//Adiciona aliquotas
				If	XmlChildEx(oXmlContent:_ListOfAliquot, "_ALIQUOT") <> Nil																												
					//Monta Array com Bases ICMS	            					
					If ValType(oXmlContent:_ListOfAliquot:_Aliquot) <> "A" 
						XmlNode2Arr(oXmlContent:_ListOfAliquot:_Aliquot, "_Aliquot")
					EndIf
			
					//Monta Bases
					For nI := 1 To Len(oXmlContent:_ListOfAliquot:_Aliquot)					
						nBase := Val(LjiVldTag(oXmlContent:_ListOfAliquot:_Aliquot[nI], "_ALIQUOTCODE", "N"))
					
						If nBase > 0												
							If nBase == 1
								cCpoBase := "FI_BAS00" + CValToChar(nBase) 
							ElseIf	nBase - Int(nBase) == 0 //Base Inteira																											
								cCpoBase := "FI_BAS" + CValToChar(nBase)																										
							Else //Base Decimal
								cCpoBase := "FI_BAS" + CValToChar(Int(nBase))							 							
								cCpoBase += StrTran(CValToChar(nBase - Int(nBase)), ".", "")
							EndIf
							
							//Adiciona Bases ICMS 												 					 
							If SFI->(FieldPos(cCpoBase)) > 0								
								If !Empty(LjiVldTag(oXmlContent:_ListOfAliquot:_Aliquot[nI], "_ALIQUOTBASE")) 
									If cCpoBase == "FI_BAS001" //Aliquota MG
										nBas001 := Val(StrTran(oXmlContent:_ListOfAliquot:_Aliquot[nI]:_AliquotBase:Text, ",", "."))									
									Else //Demais Aliquotas
										aAdd(aField, {cCpoBase, Val(StrTran(oXmlContent:_ListOfAliquot:_Aliquot[nI]:_AliquotBase:Text, ",", "."))})	
										
										//Valida se valor da base maior que zero
										If Val(oXmlContent:_ListOfAliquot:_Aliquot[nI]:_AliquotBase:Text) > 0
											aAdd(aAliqs, CValToChar(nBase)) //Adiciona aliquota	
										EndIf							
									EndIf
								EndIf
							Else
								lRet	 := .F.
								//Como o campo FI_BAS trabalha em conjunto com o campo F1_COD, faço uma verificação em conjunto.
								If !SFI->(FieldPos(STRTRAN(cCpoBase,"FI_BAS","FI_COD"))) > 0
									cCpoBase := cCpoBase +" / " + STRTRAN(cCpoBase,"FI_BAS","FI_COD")	
								Endif							
								
								cXmlRet := STR0024 + " " + cCpoBase + " " + STR0025 //#"Campo:" ##"nao existe no Protheus, necessário atualizar Dicionário de Dados Protheus."
								Exit
							EndIf
						Else
							//Verifica se a TAG de Imostos veio vazia, para os casos onde não há nenhuma venda no dia.
							//a redução será gravada sem nenhuma movimentação.
							If Empty(OXMLCONTENT:_LISTOFALIQUOT:_ALIQUOT[1]:_ALIQUOTBASE:TEXT)
								lRet := .T.
							Else
								lRet	 := .F.
								cXmlRet := STR0034 //#"Base de impostos zerada, verifique a tag AliquotCode"
								Exit
							Endif	
						EndIf							
					Next nI
				EndIf
			Endif

		If lRet							
			//Adiciona informacoes da Reducao
			aAdd(aReducao, "")
			aAdd(aReducao, SLG->LG_PDV)
			aAdd(aReducao, SLG->LG_SERPDV)
			aAdd(aReducao, cCodRed)
			aAdd(aReducao, oXmlContent:_FinalValue:Text)
			aAdd(aReducao, "")												
			aAdd(aReducao, Padr(oXmlContent:_FinalCounter:Text, TamSx3("FI_NUMFIM")[1]))
			aAdd(aReducao, LjiVldTag(oXmlContent, "_VALUECANCELLATIONS", "N"))										
			aAdd(aReducao, LjiVldTag(oXmlContent, "_SALESVALUENET", "N"))
			aAdd(aReducao, LjiVldTag(oXmlContent, "_DISCOUNTVALUE", "N"))
			aAdd(aReducao, LjiVldTag(oXmlContent, "_TAXREPLACEMENTVALUE", "N"))
			aAdd(aReducao, LjiVldTag(oXmlContent, "_FREEVALUE", "N"))
			aAdd(aReducao, LjiVldTag(oXmlContent, "_UNTAXEDVALUE", "N"))
			aAdd(aReducao, "")
			aAdd(aReducao, oXmlContent:_CounterCode:Text)
			aAdd(aReducao, LjiVldTag(oXmlContent, "_VALUEOFOTHERSRECEIVABLES", "N"))
			aAdd(aReducao, LjiVldTag(oXmlContent, "_ISSVALUE", "N"))
			aAdd(aReducao, Padr(oXmlContent:_CounterReset:Text, TamSx3("FI_CRO")[1]))
			aAdd(aReducao, aAliqs)
			aAdd(aReducao, "0")
			aAdd(aReducao, IIF(!Empty(cDataEmis), SToD(cDataEmis), Date()))
			aAdd(aReducao, IIF(!Empty(cTimeEmis), StrTran(cTimeEmis, ":", ""), StrTran(Time(), ":", "")))
			aAdd(aReducao, aAliqs)
			
			//Salva Database do sistema
			dDataBkp := dDataBase
			
			//Altera data base do sistema
			dDataBase := SToD(cDataEmis)
											
			//Realiza a gravacao da SFI	
			If Lj160Grv(SToD(cDataMovto) , cCOOIni, nGTIni	, aReducao,;
						  			nOutrosR, nBas001, aField	, nImpDebt)
														
				//Gera InternalId do Protheus
				If !Empty(SFI->FI_NUMERO)
					aInternal := IntRedZExt(/*cEmpAnt*/, /*cFilAnt*/, DToS(SFI->FI_DTMOVTO), SFI->FI_PDV, SFI->FI_NUMREDZ)
				EndIf
					
				//Valida se gerou a Reducao Z
				If Len(aInternal) > 0
					//Gera InternalId do Protheus
					If aInternal[1]
						cValInt := aInternal[2]
															
						//Adiciona item no De/Para - XXF								
						If CFGA070Mnt(cMarca, "SFI", "FI_DTMOVTO", cIdExt, cValInt)											   	
						   	//Monta o XML de Retorno
			              cXmlRet:="<ListOfInternalId>"
			              cXmlRet+=    "<InternalId>"
			              cXmlRet+=       "<Name>ReductionInternalId</Name>"
			              cXmlRet+=       "<Origin>" + cIdExt + "</Origin>"
			              cXmlRet+=       "<Destination>" + cValInt + "</Destination>"
			              cXmlRet+=    "</InternalId>"
			              cXmlRet+="</ListOfInternalId>" 	                               	
						EndIf
					Else
						lRet	 := .F.
						cXmlRet := STR0007 + " " + AllTrim(cIdExt) //#"Erro na inclusao da Reducao Z:"
					EndIf
				Else
					lRet	 := .F.
					cXmlRet := STR0007 + " " + AllTrim(cIdExt) //#"Erro na inclusao da Reducao Z:" 
				EndIf 					 	
			Else
				lRet	 := .F.
				cXmlRet := STR0032 + AllTrim(cIdExt) + "," + STR0033 //#"Nao foi possivel gravar a Reducao Z" //##"pois a mesma ja existe"								
			EndIf
			
			//Restaura data base do sistema
			dDataBase := dDataBkp 
		EndIf																																		
	Else
		lRet    := .F.
		cXmlRet := STR0010 //#"Atualize EAI"
	EndIf						
ElseIf nTypeTrans == TRANS_SEND //Envio								 
	cEvent := "upsert" //Evento
	
	//InternalId da Reducao Z
	aAux := IntRedZExt(/*cEmpAnt*/, /*cFilAnt*/, DToS(SFI->FI_DTMOVTO), SFI->FI_PDV, SFI->FI_NUMREDZ)	
	
	If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]	
		cValInt := aAux[2]	
	Else
		cValInt := ""
	EndIf
	
	//Data do Movimento
	If !Empty(SFI->FI_DTMOVTO)
		cDateMovto := SubStr(DToS(SFI->FI_DTMOVTO), 1, 4) + '-' + SubStr(DToS(SFI->FI_DTMOVTO), 5, 2) + '-' + SubStr(DToS(SFI->FI_DTMOVTO), 7, 2)
	
		//Hora do Movimento	
		cDateMovto += "T"
		cDateMovto += SubStr(SFI->FI_HRREDZ, 1, 2) + ":" + SubStr(SFI->FI_HRREDZ, 3, 2) + ":" + SubStr(SFI->FI_HRREDZ, 5, 2)
	EndIf
	
	//Data da Reducao
	If !Empty(SFI->FI_DTREDZ)
		cDateRedu := SubStr(DToS(SFI->FI_DTREDZ), 1, 4) + '-' + SubStr(DToS(SFI->FI_DTREDZ), 5, 2) + '-' + SubStr(DToS(SFI->FI_DTREDZ), 7, 2)
	
		//Hora do Movimento	
		cDateRedu += "T"
		cDateRedu += SubStr(SFI->FI_HRREDZ, 1, 2) + ":" + SubStr(SFI->FI_HRREDZ, 3, 2) + ":" + SubStr(SFI->FI_HRREDZ, 5, 2)
	EndIf
	
	//Condicional para a query		
	cWhere := "%"
	cWhere += " LG_FILIAL = '" + xFilial("SLG") + "'"
	cWhere += " AND LG_PDV = '" + SFI->FI_PDV + "'"			
	cWhere += " AND D_E_L_E_T_ = ''"   		   			
	cWhere += "%"
	
	//Executa a query
	BeginSql alias cAliasTmp
		SELECT 
			LG_CODIGO
		FROM %table:SLG%							
		WHERE %exp:cWhere% 			
	EndSql
	
	(cAliasTmp)->(dbGoTop()) //Posiciona no inicio do arquivo temporario
	
	//Busca informacoes da Estacao de Trabalho
	If (cAliasTmp)->(!EOF())
		cEstacao := (cAliasTmp)->LG_CODIGO				
	EndIf
	
	//Fecha arquivo temporario
	If (Select(cAliasTmp) > 0)
		(cAliasTmp)->(dbCloseArea())	
	EndIf
	
	//Acrescimos
	cAliasTmp 	:= GetNextAlias() //Alias temporario		
	
	//Condicional para a query		
	cWhere := "%"
	cWhere += " L1_FILIAL = '" + xFilial("SL1") + "'"
	cWhere += " AND L1_PDV = '" + SFI->FI_PDV + "'"	
	cWhere += " AND L1_DOC >= '" + SFI->FI_NUMINI + "'"
	cWhere += " AND L1_DOC <= '" + SFI->FI_NUMFIM + "'"		
	cWhere += " AND D_E_L_E_T_ = ''"   		   			
	cWhere += "%"
	
	//Executa a query
	BeginSql alias cAliasTmp
		SELECT 
			SUM(L1_FRETE+L1_SEGURO+L1_DESPESA) ACRESCIMO
		FROM %table:SL1%							
		WHERE %exp:cWhere% 			
	EndSql
	
	(cAliasTmp)->(dbGoTop()) //Posiciona no inicio do arquivo temporario	
	
	//Busca informacoes da Estacao de Trabalho
	If (cAliasTmp)->(!EOF())
		nAcres := (cAliasTmp)->ACRESCIMO				
	EndIf
	
	//Fecha arquivo temporario
	If (Select(cAliasTmp) > 0)
		(cAliasTmp)->(dbCloseArea())	
	EndIf
	
	//InternalId da Estacao de Trabalho
	aAux := IntEstacExt(/*Empresa*/, /*Filial*/, cEstacao, /*Versão*/)
	
	If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
		cEstInt := aAux[2]
	Else
		cEstInt := ""
	EndIf
	
	//Busca campos base de impostos no dicionario de dados
	SX3->(dbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
	
	SX3->(dbSeek("SFI", .T.))
		
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SFI"
		If ("FI_BAS" $ SX3->X3_CAMPO .And. AllTrim(SX3->X3_CAMPO) <> "FI_BAS001") .Or.; 
			"FI_BIS" $ SX3->X3_CAMPO 				 							
			
			aAdd(aField, SX3->X3_CAMPO)				
		EndIf
		
		SX3->(dbSkip())
	EndDo
	
	cXmlRet := '<BusinessEvent>'
	cXmlRet +=     '<Entity>REDUCTION</Entity>'
	cXmlRet +=     '<Event>' + cEvent + '</Event>'
	cXmlRet +=     '<Identification>'
	cXmlRet +=         '<key name="InternalId">' + cValInt + '</key>'
	cXmlRet +=     '</Identification>'
	cXmlRet += '</BusinessEvent>'
	
	cXmlRet += '<BusinessContent>'
	
	cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXmlRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
	cXmlRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
	cXmlRet +=    '<InternalId>' + cValInt + '</InternalId>'
	cXmlRet +=    '<MovementDate>' + cDateMovto + '</MovementDate>'
	cXmlRet +=    '<StationSalePointCode>' + RTrim(cEstacao) + '</StationSalePointCode>'
	cXmlRet +=    '<StationSalePointInternalId>' + cEstInt + '</StationSalePointInternalId>'
	cXmlRet +=    '<ReductionCode>' + RTrim(SFI->FI_NUMREDZ) + '</ReductionCode>'	
	cXmlRet +=    '<InitialValue>' + CValToChar(SFI->FI_GTINI) + '</InitialValue>'
	cXmlRet +=    '<FinalValue>' + CValToChar(SFI->FI_GTFINAL) + '</FinalValue>'			
	cXmlRet +=    '<InitialCounter>' + CValToChar(SFI->FI_NUMINI) + '</InitialCounter>'
	cXmlRet +=    '<FinalCounter>' + CValToChar(SFI->FI_NUMFIM) + '</FinalCounter>'			
	cXmlRet +=    '<ValueCancellations>' + CValToChar(SFI->FI_CANCEL) + '</ValueCancellations>'
	cXmlRet +=    '<SalesValueNet>' + CValToChar(SFI->FI_VALCON) + '</SalesValueNet>'
	cXmlRet +=    '<TaxReplacementValue>' + CValToChar(SFI->FI_SUBTRIB) + '</TaxReplacementValue>'
	cXmlRet +=    '<DiscountValue>' + CValToChar(SFI->FI_DESC) + '</DiscountValue>'
	cXmlRet +=    '<FreeValue>' + CValToChar(SFI->FI_ISENTO) + '</FreeValue>'
	cXmlRet +=    '<UntaxedValue>' + CValToChar(SFI->FI_NTRIB) + '</UntaxedValue>'
	cXmlRet +=    '<CounterCode>' + RTrim(SFI->FI_COO) + '</CounterCode>'
	cXmlRet +=    '<ValueOfOthersReceivables>' + CValToChar(SFI->FI_OUTROSR) + '</ValueOfOthersReceivables>'
	cXmlRet +=    '<AmountOfTaxDue>' + CValToChar(SFI->FI_IMPDEBT) + '</AmountOfTaxDue>'
	cXmlRet +=    '<IssValue>' + CValToChar(SFI->FI_ISS) + '</IssValue>'
	cXmlRet +=    '<CounterReset>' + RTrim(SFI->FI_CRO) + '</CounterReset>'
	cXmlRet +=    '<IssueDateReduction>' + cDateRedu + '</IssueDateReduction>'
	cXmlRet +=    '<IncreasesValue>' + CValToChar(nAcres) + '</IncreasesValue>'
	
	//Adiciona as bases para calculo dos impostos
	cXmlRet += 	'<ListOfAliquot>'		
		
	For nI := 1 To Len(aField)		
		If SubStr(aField[nI], 1, 6) == "FI_BAS"
			cCampo := "FI_COD" + AllTrim(SubStr(aField[nI], 7, Len(aField[nI])))			
			
			If &("SFI->" + aField[nI]) > 0
				cXmlRet += 		'<Aliquot>'		
				cXmlRet +=    		'<AliquotCode>' + &("SFI->" + cCampo) + '</AliquotCode>'
				cXmlRet +=    		'<AliquotBase>' + CValToChar(&("SFI->" + aField[nI])) + '</AliquotBase>'
				cXmlRet += 		'</Aliquot>'
			EndIf				
		Else
			cAliquot := "S" //ISS
			nBase := Val(SubStr(aField[nI], At("S", aField[nI])+1,2)) //Base do imposto
			
			//Trata Base					
			cAliquot += IIF(nBase <= 9, "0" + CValToChar(nBase), CValToChar(nBase))
			
			If &("SFI->" + aField[nI]) > 0
				cXmlRet += 		'<Aliquot>'		
				cXmlRet +=    		'<AliquotCode>' + PadR(cAliquot, 5, "0") + '</AliquotCode>'
				cXmlRet +=    		'<AliquotBase>' + CValToChar(&("SFI->" + aField[nI])) + '</AliquotBase>'
				cXmlRet += 		'</Aliquot>'
			EndIf	
		EndIf								
	Next nI
	
	cXmlRet += 	'</ListOfAliquot>'		
	
	cXmlRet += '</BusinessContent>'		
EndIf		

cXmlRet := EncodeUTF8(cXmlRet)

//Restaura areas
For nI := 1 To Len(aAreas)
	RestArea(aAreas[nI])
Next nI

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntRedZExt
Monta o InternalID da Reducao de acordo com código passado

@param cEmpresa, Código da empresa (Default cEmpAnt)
@param cFil, Código da Filial (Default cFilAnt)
@param cDataMov, Data da Reducao Z
@param cPdv, Codigo do Pdv   
@param cNumRed, Numero da Reducao Z
@param cVersao, Versao da Mensagem
@return aResult, Array contendo no primeiro parâmetro uma variável logica
		indicando se o registro foi encontrado.
		No segundo parâmetro uma variável string com o InternalID montado.

@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/		
//-------------------------------------------------------------------------------------------------

Function IntRedZExt(cEmpresa, cFil, cDataMov, cPdv, cNumRed, cVersao)
   
Local aResult  := {}
Local aAreaSFI := SFI->(GetArea())

Default cEmpresa 		:= cEmpAnt
Default cFil     		:= xFilial("SFI")
Default cDataMov  	:= DToS(SFI->FI_DTMOVTO)
Default cPdv			:= SFI->FI_PDV
Default cNumRed		:= SFI->FI_NUMERO
Default cVersao		:= "1.000"

If cVersao $ "1.000|1.001"
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + "|" + RTrim(cFil) + "|" + cDataMov + "|" +;
					RTrim(cPdv) + "|" + RTrim(cNumRed))
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0026 + Chr(10) + STR0027 + "1.000|1.001") //#"Versao nao suportada." ##"As versoes suportadas sao:"
EndIf

RestArea(aAreaSFI)  
   
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntRedZInt
Recebe um InternalID e retorna o código da Redução

@param cInternalID, InternalID recebido na mensagem
@param cRefer, Produto que enviou a mensagem	
@param cVersao, Versão da mensagem única (Default 1.000)
@return aResult, Array contendo no primeiro parâmetro uma variável logica
		indicando se o registro foi encontrado no de/para.
		No segundo parâmetro uma variável array com o empresa,
		filial, data do movto, pdv e reducao.

@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/
//-------------------------------------------------------------------------------------------------

Function IntRedZInt(cInternalID, cRefer, cVersao)
   
Local aResult  := {}
Local aTemp    := {}
Local cTemp    := ""
Local cAlias   := "SFI"
Local cField   := "FI_DTMOVTO"

Default cVersao  := "1.000"

cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, STR0028 + " " + AllTrim(cInternalID) + " " + STR0029) //#"Reducao Z:" ##"nao encontrado no de/para!" 
Else
	If cVersao $ "1.000|1.001"
		aAdd(aResult, .T.)
       aTemp := Separa(cTemp, "|")
       aAdd(aResult, aTemp)	     
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0026 + Chr(10) + STR0027 + "1.000|1.001") //#"Versao nao suportada." ##"As versoes suportadas sao:"       
   EndIf
EndIf
  
Return aResult