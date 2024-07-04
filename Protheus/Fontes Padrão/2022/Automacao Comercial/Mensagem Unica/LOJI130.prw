#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJI130.CH"
#INCLUDE "FWADAPTEREAI.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJI130
Rotina para processar gravacao de NF sobre Cupons via integracao Mensagem Unica.

@author alessandrosantos
@since 03/07/2017
@version P12.1.17

@param cXml, XML recebido pelo EAI Protheus
@param nType, Tipo de transação ("0" = TRANS_RECEIVE, "1" = TRANS_SEND)
@param cTypeMsg, Tipo da mensagem do EAI ("20" = EAI_MESSAGE_BUSINESS, "21" = EAI_MESSAGE_RESPONSE
        "22" = EAI_MESSAGE_RECEIPT, "23" = EAI_MESSAGE_WHOIS)

@return  Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
          aRet[1] - (boolean) Indica o resultado da execução da função
          aRet[2] - (caractere) Mensagem Xml para envio
          aRet[3] - (caractere) Nome da mensagem para retorno no WHOIS
/*/
//-------------------------------------------------------------------------------------------------

Function LOJI130(cXml, nType, cTypeMsg)

Local cError 		:= "" //Erros no XML
Local cWarning 	    := "" //Avisos no XML
Local cVersao		:= "" //Versao da Mensagem
Local cXmlRet		:= "" //Mensagem de retorno da integracao
Local lRet			:= .T. //Retorno da integracao
Local oXmlL130	:= xmlParser(cXml, "_", @cError, @cWarning) //Objeto XML

//Validacoes iniciais do XML
If oXmlL130 == Nil .Or. !Empty(cError)
	lRet := .F.
	cXmlRet := STR0001 //#"Erro no parser!" 
ElseIf Empty(LjiVldTag(oXmlL130:_TOTVSMessage:_MessageInformation, "_VERSION"))	
	lRet := .F.
	cXmlRet := STR0002 //#"Versao da mensagem nao informada!"
Else
	cVersao := StrTokArr(oXmlL130:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]							                 	               	

	//Valida versao do XML          
	If cVersao <> "1"
		lRet := .F.
		cXmlRet := STR0003 //#"A versao da mensagem informada nao foi implementada!"		
	Else 
		If nType == TRANS_RECEIVE																														
			v1000(oXmlL130, cTypeMsg, @lRet, @cXmlRet)													   						   		   			  																					   		   		     			
		EndIf   														
	EndIf
EndIf

Return {lRet, cXmlRet, "DOCUMENTONCOUPON"}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000
Função para tratar o XML recebido na mensagem de Business

@param oXmlL130, Objeto contendo XML recebido
@param cTypeMsg, Tipo da mensagem
@param cXml, XML recebido
@param cXMLRet, Tipo da mensagem do EAI ("20" = EAI_MESSAGE_BUSINESS, 
		"21" = EAI_MESSAGE_RESPONSE, "22" = EAI_MESSAGE_RECEIPT, "23" = EAI_MESSAGE_WHOIS)
@return lRet, Indica se processou a mensagem recebida com sucesso
@return cXmlRet, Mensagem Xml para envio

@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------

Static Function v1000(oXmlL130, cTypeMsg, lRet, cXmlRet)

Local aArea		:= GetArea() //Armazena areas
Local aAreaSA1	:= SA1->(GetArea()) //Armazena area SA1
Local aAreaSL1	:= SL1->(GetArea()) //Armazena area SL1
Local cMarca		:= "" //Armazena a Marca que enviou o XML
Local cValExt		:= "" //Codigo externo utilizada no De/Para de codigos - Tabela XXF
Local cValInt		:= "" //Codigo interno utilizada no De/Para de codigos - Tabela XXF
Local cCodCli		:= "" //Codigo de Cliente
Local cLojCli		:= "" //Loja do Cliente
Local cIdExt		:= "" //Identificacao externa do registro
Local cCupExt		:= "" //InternalId do Cupom Fiscal
Local cEmissao	:= "" //Data de Emissao do Documento
Local cCliPad 	:= Padr(SuperGetMv("MV_CLIPAD",, "000001"), TamSX3("A1_COD")[1]) //Cliente Padrao	
Local cLojaPad	:= Padr(SuperGetMv("MV_LOJAPAD",, "01"), TamSX3("A1_LOJA")[1]) //Loja do Cliente Padrao	
Local nI			:= 0 //Contador
Local nTamCup		:= TamSx3("L1_DOC")[1] //Tamanho do campo Cupom Fiscal
Local nTamSer		:= TamSx3("L1_SERIE")[1] //Tamanho da Serie do Cupom Fiscal
Local nTamPdv		:= TamSx3("L1_PDV")[1] //Tamanho do PDV
Local dDataBkp 	:= dDataBase //Backup de database
Local aCupons		:= {} //Array de Cupons para geracao da NF
Local aAux			:= {} //Array Auxiliar para armazenar Internald
Local aInternal	:= {} //Array Auxiliar para armazenas InternalId gerado no Protheus
Local aErroAuto	:= {} //Logs de erro do ExecAuto
Local aIntCupons	:= {} //Array com InternalIds dos Cupons Fiscais
Local oXmlContent	:= Nil //Objeto Xml com o conteudo da BusinessContent apenas

Private lMsHelpAuto 		:= .T. //Variavel de controle interno do ExecAuto
Private lMsErroAuto 		:= .F. //Variavel que informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile 	:= .T. //força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário

//Recebimento de Mensagem Business
If cTypeMsg == EAI_MESSAGE_BUSINESS	
	//------------------------------------------------------------
	//Tratamento utilizando a tabela XXF com um De/Para de codigos
	//------------------------------------------------------------                   		   		                                                           		
   	If FindFunction("CFGA070INT")    		
   		//Marca
		If oXmlL130:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And. !Empty(oXmlL130:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			cMarca := oXmlL130:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		EndIf
		
		If Empty(cMarca)		
			lRet    := .F.
			cXMLRet := STR0004 //#"Marca nao integrada ao Protheus, verificar a marca da integracao."						
		EndIf
			
		If lRet
			//Data de Emissao do Documento
			cEmissao := LjiVldTag(oXmlL130:_TOTVSMessage:_MessageInformation, "_GENERATEDON", "D")
									
			//Gera objeto para carga de Vendas    	
			oXmlContent := oXmlL130:_TOTVSMessage:_BusinessMessage:_BusinessContent
						    		    			
			//Armazena chave externa
			cIdExt := LjiVldTag(oXmlContent, "_INTERNALID")
												
			If Empty(cIdExt)
				lRet	 := .F.
				cXmlRet := STR0005 //#"Campo obrigatorio nao informado: Id Interno, verifique a tag: InternalId."					
			EndIf
		EndIf
			
		If lRet
			//Verifica se cupom já foi integrado
			aAux := IntNFCupInt(cIdExt, cMarca)
          		
          	//Se encontrou a Nota no de-para
          If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
          		lRet 	 := .F.									
				cXmlRet := STR0006 + " " + AllTrim(cIdExt) + " " + STR0007 //#"Nota sobre Cupom" ##"ja integrado no Protheus!" 					 	
         	EndIf
    	EndIf
			
		If lRet
			//De-Para Cliente
			cValExt := LjiVldTag(oXmlContent, "_CUSTOMERVENDORINTERNALID")
		
			If !Empty(cValExt)			          		          		
          		aAux := IntCliInt(cValExt, cMarca)
          		
          		//Se encontrou o cliente no de-para
              If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
              	cCodCli := PadR(aAux[2][3], TamSX3("A1_COD")[1])
              	cLojCli := PadR(aAux[2][4], TamSX3("A1_LOJA")[1])                                                                             
         		Else
              	lRet := .F. 
              	cXmlRet := STR0008 + " " + AllTrim(cValExt) + " " + STR0009 //#"Cliente:" ##"nao integrado ao Protheus, verifique a integracao de clientes."	              	
             	EndIf          		          		
          	Else 
          		lRet := .F. 
              cXmlRet := STR0006 + " " + AllTrim(cIdExt) + "," + STR0023 //#"Nota sobre Cupom" ##"necessario informar o cliente, verifique a tag: CustomerInternalId"	                        		          		
          	EndIf 
    	EndIf
          	
      	If lRet
          	//Posiciona no cliente do Protheus
	   		SA1->(dbSetOrder(1))	
          	
          	If !SA1->(dbSeek(xFilial("SA1") + cCodCli + cLojCli)) 
          		lRet := .F. 
              cXmlRet := STR0008 + " " + cCodCli + "/" + STR0018 + " " + cLojCli + " " + STR0010 //#"Cliente:" ##"Loja:" ###"nao cadastrado no Protheus, verifique o cadastro de clientes."	                        	
          	EndIf
              
      		If lRet      	  			
				//Valida se os cupons foram enviados																
				If	XmlChildEx(oXmlContent, "_LISTOFRETAILSALES") == Nil
					lRet 	 := .F.	
					cXmlRet := STR0011 //#"Lista de cupons vazia, verifique a Lista ListOfRetailSales."						
				EndIf
				
				If lRet				
					//Valida se lista foi enviada
					If XmlChildEx(oXmlContent:_ListOfRetailSales, "_RETAILSALES") == Nil								
						lRet 	 := .F.	
						cXmlRet := STR0011 //#"Lista de cupons vazia, verifique a Lista ListOfRetailSales." 							
					EndIf
				EndIf
			EndIf
		EndIf
								
		If lRet
			//Monta Array com Cupons	            					
			If ValType(oXmlContent:_ListOfRetailSales:_RetailSales) <> "A" 
				XmlNode2Arr(oXmlContent:_ListOfRetailSales:_RetailSales, "_RetailSales")
			EndIf
			
			//Valida se conteudo lista esta vazia
			If Len(oXmlContent:_ListOfRetailSales:_RetailSales) == 0
				lRet 	 := .F.	
				cXmlRet := STR0011 //#"Lista de cupons vazia, verifique a Lista ListOfRetailSales." 					
			EndIf
		EndIf
					 			 						
		If lRet						
			//Monta Cupons
			For nI := 1 To Len(oXmlContent:_ListOfRetailSales:_RetailSales)
				cCupExt := oXmlContent:_ListOfRetailSales:_RetailSales[nI]:_RetailSalesInternalId:Text
				
				//Verifica se o InternalId do Cupom foi informado
				If Empty(cCupExt)
					lRet 	 := .F.	
					cXmlRet := STR0019 + " " + CValToChar(nI) + ":" + STR0020 //#"Inconsistencia no Item" ##"InternalId vazio, informacao obrigatoria, verifique a tag RetailSalesInternalId." 
					Exit
				Else
					//Pega o valor interno do Cupom informado
					aIntCupons := IntVendInt(cCupExt, cMarca)
						
					If ValType(aIntCupons) == "A" .And. Len(aIntCupons) > 0 .And. aIntCupons[1]				
						//Posiciona no Cupom Fiscal
						SL1->(dbSetOrder(2))
						SL1->(dbSeek(xFilial("SL1") + Padr(aIntCupons[2][3], nTamSer) + Padr(aIntCupons[2][4], nTamCup) + Padr(aIntCupons[2][5], nTamPdv)))
																		
						//Validacao para nao gerar Nota sobre Cupom para Cliente Padrao
				    	If AllTrim(cCodCli + cLojCli) == AllTrim(cCliPad + cLojaPad)
				       	lRet 	 := .F. 
				      		cXmlRet := STR0019 + " " + CValToChar(nI) + "," + STR0024 //##"Inconsistencia no Item" ##"nao e possivel gerar Nota sobre Cupom para Cliente Padrao."
				      		Exit	
				      	ElseIf AllTrim(SL1->L1_CLIENTE + SL1->L1_LOJA) <> AllTrim(cCodCli + cLojCli) .And.; 				      		
				      		AllTrim(SL1->L1_CLIENTE + SL1->L1_LOJA) <> AllTrim(cCliPad + cLojaPad) //Valida se o cliente da Nota igual aos clientes dos cupons fiscais
				      			
				      		lRet 	 := .F. 
				      		cXmlRet := STR0019 + " " + CValToChar(nI) + "," + STR0025 //##"Inconsistencia no Item" ##"Cliente da Nota sobre Cupom diferente do Cliente no Cupom Fiscal."
				      		Exit				      						      	
				      	ElseIf AllTrim(SL1->L1_ESPECIE) == "RPS" //Valida se venda é Cupom Fiscal diferente de RPS
				      		lRet 	 := .F.
				      		cXmlRet := STR0019 + " " + CValToChar(nI) + "," + STR0026 //##"Inconsistencia no Item" ##"não é permitido gerar nota para Venda do tipo RPS"
				      		Exit
				      	Else 						
							//Adiciona Cupom Fiscal
							aAdd(aCupons, {SL1->L1_DOC,;									 	 
										 	 SL1->L1_SERIE,;
										 	 SL1->L1_CLIENTE,;
										 	 SL1->L1_LOJA})
						EndIf																
					Else
						lRet 	 := .F.	
						cXmlRet := STR0019 + " " + CValToChar(nI) + ":" + STR0021 + " " + cCupExt + " " + STR0022 //#"Inconsistencia no Item" ##"InternalId" ###"nao encontrado no Protheus, verifique a tag RetailSalesInternalId."	 
						Exit	
					EndIf	
				EndIf												
			Next nI
		EndIf
			
		//Gera NF sobre Cupons
		If Len(aCupons) > 0 .And. lRet
			//Salva Database do sistema
			dDataBkp := dDataBase
			
			//Altera data base do sistema
			dDataBase := SToD(cEmissao)
						
			SetFunName("LOJR130")
			MSExecAuto({|a,b,c,d,e| LojR130(a,b,c,d,e)}, aCupons,, cCodCli, cLojCli, .T. )				
				
			//Verifica se encontrou erros na gravacao da Nota			
			If lMsErroAuto
				aErroAuto := GetAutoGrLog()
													             	
             	//Armazena mensagens de erro	             	
             	cXMLRet := "<![CDATA["	              	              
              	For nI := 1 To Len(aErroAuto)
              		cXMLRet += AllTrim(aErroAuto[nI]) + Chr(10)
              	Next nI	              	              	              
              cXMLRet += "]]>"					
				
				If Len(aErroAuto) == 0
					cXmlRet := STR0012 + " " + cCodCli + "/" + cLojCli + "." //#"Erro na geracao da NF sobre Cupom para o cliente:"
				EndIf
				
          		//Monta XML de Erro de execução da rotina automatica
              lRet := .F.	              	              																										          			              	                            	             
	
             	//Desfaz a transacao
            	DisarmTransaction()							 								
				
				//Libera sequencial 
				RollBackSx8()
				
				MsUnLockAll()
			Else										
				//Gera InternalId do Protheus
				aInternal := IntNFCupExt(cEmpAnt, SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, cCodCli, cLojCli)
					
				//Valida se gerou a nota
				If Len(aInternal) > 0	
					If aInternal[1]
						cValInt := aInternal[2]
					
						//Adiciona item no De/Para - XXF								
						If CFGA070Mnt(cMarca, "SF2", "F2_DOC", cIdExt, cValInt)																
							//Monta o XML de Retorno				              				              				              
			              cXmlRet := "<InvoiceNumber>" + cValInt + "</InvoiceNumber>"				              				             
						EndIf
					Else
						lRet 	 := .F.
			   			cXmlRet := STR0035 //#"Nao foi possivel gerar InternalId para a Nota sobre cupons"
					EndIf
				Else
					lRet 	 := .F.
			   		cXmlRet := STR0036 //#"Nao foi possivel a geracao na Nota sobre cupons"
				EndIf														
			EndIf
				
			//Restaura data base do sistema
			dDataBase := dDataBkp  
		EndIf			   		
   	Else
   		lRet    := .F.
  		cXmlRet := STR0013 //#"Atualize EAI!"
   	EndIf
ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE	 	
	cXmlRet := '<TAGX>RECEPCAO RESPONSE MESSAGE</TAGX>'
ElseIf cTypeMsg == EAI_MESSAGE_WHOIS						 
	cXmlRet := "1.000"	
EndIf

//Tratamento para evitar retorno incorreto
If Empty(cXMLRet)
	lRet 	 := .F.
	cXMLRet := STR0012 + " " + cLojCli + "/" + cLojCli + "." //"#Erro na geracao da NF sobre Cupom para o cliente:"	
EndIf

//Restaura areas
RestArea(aAreaSA1)
RestArea(aAreaSL1)	
RestArea(aArea)	   	

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntNFCupExt
Monta o InternalID da Venda de acordo com código passado

@param cEmpresa, Código da empresa (Default cEmpAnt)
@param cFil, Código da Filial (Default cFilAnt)
@param cDocumento, Código do Documento (Cupom Fiscal)
@param cSerie, Serie do Documento (Serie Fiscal)		
@param cCliente, Código do Cliente
@param cLoja, Loja do Cliente
@param cVersao, Versao da Mensagem
@return aResult, Array contendo no primeiro parâmetro uma variável logica
		indicando se o registro foi encontrado.
		No segundo parâmetro uma variável string com o InternalID montado.

@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------

Function IntNFCupExt(cEmpresa, cFil, cDocumento, cSerie, cCliente, cLoja, cVersao)
   
Local aResult  := {}

Default cEmpresa 		:= cEmpAnt
Default cFil     		:= xFilial("SF2")
Default cDocumento  	:= SF2->F2_DOC
Default cSerie		:= SF2->F2_SERIE
Default cCliente		:= SF2->F2_CLIENTE
Default cLoja			:= SF2->F2_LOJA
Default cVersao		:= "1.000"

If cVersao == "1.000"
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + "|" + RTrim(cFil) + "|" + RTrim(cDocumento) + "|" +;
					RTrim(cSerie) + "|" + RTrim(cCliente) + "|" +;
					RTrim(cLoja))
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0014 + Chr(10) + STR0015 + "1.000") //#"Versao nao suportada." ##"As versoes suportadas sao:"
EndIf
   
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntNFCupInt
Recebe um InternalID e retorna o código da Venda.

@param cInternalID, InternalID recebido na mensagem
@param cRefer, Produto que enviou a mensagem	
@param cVersao, Versão da mensagem única (Default 1.000)
@return aResult, Array contendo no primeiro parâmetro uma variável logica
		indicando se o registro foi encontrado no de/para.
		No segundo parâmetro uma variável array com o empresa,
		filial, documento, serie, cliente e loja.

@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------

Function IntNFCupInt(cInternalID, cRefer, cVersao)
   
Local aResult  := {}
Local aTemp    := {}
Local cTemp    := ""
Local cAlias   := "SF2"
Local cField   := "F2_DOC"

Default cVersao  := "1.000"

cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, STR0016 + " " + AllTrim(cInternalID) + " " + STR0017) //#"Documento:" ##"nao encontrado no de/para!" 
Else
	If cVersao == "1.000"
		aAdd(aResult, .T.)
       aTemp := Separa(cTemp, "|")
       aAdd(aResult, aTemp)	      
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0014 + Chr(10) + STR0015 + "1.000") //#"Versao nao suportada." ##"As versoes suportadas sao:"       
   EndIf
EndIf
  
Return aResult


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjI130NSC
Faz gravação da nota sobre Cupom já emitida
@param oXmlContent	   	- Obj com Xml
@param cMsgRet	    	- Obj com Xml
@param cMarca           - Marca para gravar/buscar de/para
@return lRet	        - Logico Definindo se executou corretamente
@author  rafael.pessoa
@since 	 28/03/2019
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------
Function LjI130NSC( oXmlContent, cMsgRet, cMarca )

Local nI                := 0
Local cDocument         := ""
Local cSerie            := "" 
Local cDocItem          := ""
Local cDocOri           := ""
Local cSerieOri         := ""
Local cDocItemOri       := ""
Local cKeyNF            := ""
Local cDataNF           := ""
Local lRet              := .T.
Local dDataBkp 	        := dDataBase //Backup de database
Local aCupons           := {}
Local cCodCli		    := "" //Codigo de Cliente
Local cLojCli		    := "" //Loja do Cliente
Local aErroAuto	        := {} //Logs de erro do ExecAuto
Local aInternal	        := {} //Array Auxiliar para armazenas InternalId gerado no Protheus
Local cValExt		    := "" //Codigo externo utilizada no De/Para de codigos - Tabela XXF
Local cValInt		    := "" //Codigo interno utilizada no De/Para de codigos - Tabela XXF
Local cIdExt		    := "" //Identificacao externa do registro recebido
Local cIntIdCli         := ""
Local nTamCup           := TamSX3("L1_DOC")[1]  
Local nTamSer		    := TamSx3("L1_SERIE")[1] //Tamanho da Serie do Cupom Fiscal

Private lMsErroAuto 	:= .F. //Variavel que informa a ocorrência de erros no ExecAuto

Default oXmlContent     := Nil
Default cMsgRet         := ""
Default cMarca          := ""

//Busca as Informações de cabeçalho
cIntIdCli  := LjiVldTag(oXmlContent, "_CUSTOMERVENDORINTERNALID")
cIdExt     := LjiVldTag(oXmlContent, "_INTERNALID")
cDocument  := AllTrim(LjiVldTag(oXmlContent, "_DOCUMENTCODE"))
cSerie     := AllTrim(LjiVldTag(oXmlContent, "_SERIECODE"))
cKeyNF     := AllTrim(LjiVldTag(oXmlContent, "_KEYACESSNFE"))
cDataNF    := AllTrim(LjiVldTag(oXmlContent, "_ISSUEDATEDOCUMENT", "D"))

//Valida campos obrigatorios do cabecalho
IIF( Empty(cIntIdCli), {lRet := .F. , cMsgRet += STR0006 + " " + AllTrim(cIdExt) + "," + STR0023  },)  // "Nota sobre Cupom" ##"necessario informar o cliente, verifique a tag: CustomerInternalId"
IIF( Empty(cIdExt   ), {lRet := .F. , cMsgRet += I18n(STR0037, {"InternalId"})          },) //"Número da Nota não informado TAG: #1"
IIF( Empty(cDocument), {lRet := .F. , cMsgRet += I18n(STR0038, {"DocumentCode"})        },) //"Número do documento não informado TAG: #1"
IIF( Empty(cSerie   ), {lRet := .F. , cMsgRet += I18n(STR0039, {"SerieCode"})           },) //"Número de série não informado TAG: #1"
IIF( Empty(cKeyNF   ), {lRet := .F. , cMsgRet += I18n(STR0040, {"KeyAcessNFe"})         },) //"Chave da nota não informada TAG: #1" 
IIF( Empty(cDataNF  ), {lRet := .F. , cMsgRet += I18n(STR0041, {"IssueDateDocument"})   },) //"Data de emissão não informado TAG: #1"


If lRet			          		          		
    aAux := IntCliInt(cIntIdCli, cMarca)    
    //Se encontrou o cliente no de-para
    If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
        cCodCli := PadR(aAux[2][3], TamSX3("A1_COD")[1])
        cLojCli := PadR(aAux[2][4], TamSX3("A1_LOJA")[1])                                                                             
    Else
        lRet := .F. 
        cMsgRet := STR0008 + " " + AllTrim(cIntIdCli) + " " + STR0009 //#"Cliente:" ##"nao integrado ao Protheus, verifique a integracao de clientes."	              	
    EndIf          		          		
EndIf


//Valida se produtos foram enviados
If	lRet .And. XmlChildEx(oXmlContent:_ListOfSaleItem, "_SALEITEM") == Nil
    lRet 	 := .F.
    cMsgRet := I18n(STR0042, {"SaleItem"})  //"Lista de produtos vazia, verifique a TAGLIST: #1 "    
EndIf

If lRet
    //Monta Array com Itens da Venda	            					
    If ValType(oXmlContent:_ListOfSaleItem:_SaleItem) <> "A"
        XmlNode2Arr(oXmlContent:_ListOfSaleItem:_SaleItem, "_SaleItem")
    EndIf

    //Valida se lista esta vazia
    If Len(oXmlContent:_ListOfSaleItem:_SaleItem) == 0
        lRet 	    := .F.
        cMsgRet := I18n(STR0042, {"SaleItem"})  //"Lista de produtos vazia, verifique a TAGLIST: #1 " 
    EndIf
EndIf

If lRet
    For nI := 1 To Len(oXmlContent:_ListOfSaleItem:_SaleItem)

        cDocOri           := PadR( AllTrim(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_SOURCEDOCUMENT")), nTamCup )    
        cSerieOri         := PadR( AllTrim(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_SOURCEDOCUMENTSERIE")), nTamSer )   
        cDocItemOri       := AllTrim(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_SOURCEDOCUMENTITEM"))


        If  Ascan(aCupons, {  |x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(cDocOri) + AllTrim(cSerieOri) }) == 0 
		
            //Adiciona Cupom Fiscal
            aAdd(aCupons,{	cDocOri		    ,;									 	 
                            cSerieOri	    ,;
                            cCodCli	        ,;
                            cLojCli	        })
        EndIf
    Next nI

    //Permite gerar uma nota para múltiplos cupons
    If Len(aCupons) > 1 .And. !SuperGetMV("MV_LJ130MN",,.F.) 
        lRet 	    := .F.
        cMsgRet     := I18n(STR0043, {"MV_LJ130MN"}) //"Não é possível emitir uma nota para vários cupons pois o Parâmetro #1 não está Ativo." 
    EndIf

EndIf    

//Gera NF sobre Cupons
If lRet .And. Len(aCupons) > 0 

    Begin Transaction

        dDataBase := SToD(cDataNF) //Altera data base do sistema
                    
        SetFunName("LOJR130")
        MSExecAuto({|a,b,c,d,e,f| lRet := LojR130(a,b,c,d,e,f)}, aCupons,, cCodCli, cLojCli, .T. , { cSerie, cDocument, cKeyNF } )				

        //Verifica se encontrou erros na gravacao da Nota			
        If lMsErroAuto .Or. !lRet
            aErroAuto := GetAutoGrLog()
                                                                
            //Armazena mensagens de erro	             	                    	              
            For nI := 1 To Len(aErroAuto)
                cMsgRet += AllTrim(aErroAuto[nI]) + Chr(10)
            Next nI		
            
            If Len(aErroAuto) == 0
                cMsgRet += STR0012 + " " + cCodCli + "/" + cLojCli + "." //#"Erro na geracao da NF sobre Cupom para o cliente:"
            EndIf
            
            lRet := .F.	              	              																										          			              	                            	             

            //Desfaz a transacao
            DisarmTransaction()							 								
            
            //Libera sequencial 
            RollBackSx8()
            
            MsUnLockAll()
        Else										
            //Gera InternalId do Protheus
            aInternal := IntNFCupExt(cEmpAnt, SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, cCodCli, cLojCli)
                
            //Valida se gerou a nota
            If Len(aInternal) > 0	
                If aInternal[1]
                    cValInt := aInternal[2]
                
                    //Adiciona item no De/Para - XXF								
                    If CFGA070Mnt(cMarca, "SF2", "F2_DOC", cIdExt, cValInt)																
                        //Monta o Retorno				              				              				                                   
                        cMsgRet := "<ListOfInternalId>"
                        cMsgRet +=    "<InternalId>"
                        cMsgRet +=       "<Name>RetailSalesInternalId</Name>"
                        cMsgRet +=       "<Origin>" + cIdExt + "</Origin>"
                        cMsgRet +=       "<Destination>" + cValInt + "</Destination>"
                        cMsgRet +=    "</InternalId>"
                        cMsgRet += "</ListOfInternalId>"
                    EndIf

                Else
                    lRet 	 := .F.
                    cMsgRet := STR0035 //#"Nao foi possivel gerar InternalId para a Nota sobre cupons"
                EndIf
            Else
                lRet 	 := .F.
                cMsgRet  := STR0036 //#"Nao foi possivel a geracao na Nota sobre cupons"
            EndIf														
        EndIf
            
        //Restaura data base do sistema
        dDataBase := dDataBkp  

    End Transaction	

EndIf

Return lRet