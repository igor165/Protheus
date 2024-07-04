#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FWMVCDEF.CH'
#Include 'AGRI045.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRI045
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de locais de estoque (ANN) utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   17/07/2012
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function AGRI045(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
Local cError   := ""
Local cWarning := ""
Local cVersao  := ""
Local lRet     := .T. 
Local cRet     := ""
Local cXmlRet  := ""    
Local aRet     := { .T., "" }
Local aAux     := { .F., "" } 

Private nRelease  := 0
Private oXML   	  := Nil
Private lIntegPPI := .F.

//Verifica se está sendo executado para realizar a integração com o PPI.
//Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
//Variável é criada no fonte AGRA045.prw, na função AGRA045PPI().
If Type("lRunPPI") == "L" .And. lRunPPI
	lIntegPPI := .T.
EndIf

If !lEAIObj
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			oXml := xmlParser(xEnt, "_", @cError, @cWarning)

			If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
				If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
					cVersao	:= StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
					nRelease	:= Val(StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[2])
				Else
               lRet     := .F.
					aAux := { lRet , 	STR0033 } //"Versão do local de estoque não suportada."    
				EndIf
			Else
            lRet := .F.
				aAux := { lRet , 	STR0008 } //"Erro no parser!"
			EndIf

         If lRet
            If cVersao == "1"
               aAux := v1000(xEnt, nTypeTrans, cTypeMessage)
            Else
               aAux := { .F. , 	STR0033 } //"Versão do local de estoque não suportada."
            EndIf
         EndIf
         aRet := { aAux[1], aAux[2], 'WAREHOUSE' }

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			oXml := xmlParser(xEnt, "_", @cError, @cWarning)
			If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
				If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
					cVersao 	:= StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
					nRelease	:= Val(StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[2])
				EndIf
			Else
            lRet := .F.
            aAux := { lRet , STR0014 } //"Erro no parser do retorno!"
			EndIf

         If lRet
            If cVersao == "1"
               aAux := v1000(xEnt, nTypeTrans, cTypeMessage)
            Else
               aAux := { .F. , 	STR0033 }  
            EndIf
			EndIf
		
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := "1.000|1.001|1.002|1.003"
         aAux := { lRet , cXMLRet  }
		
      EndIf

      aRet := { aAux[ 1 ] , aAux[ 2 ], 'WAREHOUSE' }

	ElseIf nTypeTrans == TRANS_SEND
		If lIntegPPI
			aAux := v1000(xEnt, nTypeTrans, cTypeMessage)		
		Else
         cVersao := StrTokArr(cVersion, ".")[1]		
         If Empty(cVersao)
            lRet := .F.
            aAux := { lRet , STR0033  } //"Versão do local de estoque não suportada."	
         EndIf

         If lRet
            If cVersao == "1"
               aAux := v1000(xEnt, nTypeTrans, cTypeMessage)
            Else
               lRet := .F.
               aAux := { lRet , STR0033 } 	//"Versão do local de estoque não suportada."
            EndIf
         EndIf

		EndIf
      aRet := { aAux[ 1 ] , aAux[ 2 ], 'WAREHOUSE' }	

	EndIf
	
Else
    //FORMATO JSON
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
		    aAux := v1000J(xEnt, nTypeTrans, cTypeMessage)
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
				cRet := "1.000|1.001|1.002|1.003"    
				aAux := { lRet , cRet }
		EndIf
      aRet := { aAux[ 1 ] , aAux[ 2 ], 'WAREHOUSE' }

	ElseIf nTypeTrans == TRANS_SEND
		If lIntegPPI
			aAux := v1000J( xEnt, nTypeTrans, cTypeMessage ) 
		Else
         cVersao := StrTokArr(cVersion, ".")[1]	
         If Empty(cVersao)
            lRet := .F.
            aAux := { lRet , STR0033 } //"Versão do local de estoque não suportada."
         EndIf

         If lRet
            If cVersao == "1"
               aAux := v1000J(xEnt, nTypeTrans, cTypeMessage)
            Else
               lRet := .F.
               aAux := { lRet , STR0033 } //"Versão do local de estoque não suportada."
            EndIf
         EndIf
		EndIf
      aRet := { aAux[ 1 ] , aAux[ 2 ], 'WAREHOUSE' }

	EndIf
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} V1000
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de Local de Estoque utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author rodrigo.mpontes
@version P12
@since 21/10/2015
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function V1000(xEnt, nTypeTrans, cTypeMessage)

   Local cXmlRet   := ""
   Local cXML      := ""
   Local cEntity   := "Warehouse"
   Local cEvent    := ""
   Local lRet      := .T.
   Local nOpcx     := 0
   Local cAlias    := "NNR"
   Local cField    := "NNR_CODIGO"
   Local nCount    := 0
   Local cError    := ""
   Local cWarning  := ""
   Local cValInt   := ""
   Local cValExt   := ""
   Local cProduct  := ""
   Local cCode     := ""
   Local nI        := 0
   Local aLocalEst := {}
   Local aAux      := {}
   //Local oModel      := Nil
   //Local oModelNNR   := Nil
   Local aErro     := {}
   Local lInicPad  := .F.
   Local cWHECommer	:= GetNewPar("MV_LJECOMG","01")
   Local cWHDefault	:= GetNewPar("MV_LJECLPE","01")
   
   Private oXML      := Nil
   Private lIntegPPI := .F.

   //Verifica se está sendo executado para realizar a integração com o PPI.
   //Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
   //Variável é criada no fonte AGRA045.prw, na função AGRA045PPI().
   If Type("lRunPPI") == "L" .And. lRunPPI
      lIntegPPI := .T.
   EndIf

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         // Faz o parser do xml em um objeto
         oXML := xmlParser(xEnt, "_", @cError, @cWarning)

         // Se não houve erros no parser
         If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
            // Verifica se a marca foi informada
            If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
               cProduct := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet := .F.
               cXmlRet := STR0001 // "A marca é obrigatória"
               Return {lRet, cXmlRet}
            EndIf

            // Verifica se a filial atual é a mesma filial de inclusão do cadastro
            aAux := IntChcEmp(oXML, cAlias, cProduct)
            If !aAux[1]
               lRet := aAux[1]
               cXmlRet := aAux[2]
               Return {lRet, cXmlRet}
            EndIf

            // Verifica se o InternalId foi informado
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
               cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
            Else
               lRet := .F.
               cXmlRet := STR0002 // "O InternalId é obrigatório!"
               Return {lRet, cXmlRet}
            EndIf
            
            aAux := IntLocInt(cValExt,cProduct)
            
            If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
            	If !aAux[1]
            		nOpcx := 3
            	Else
            		nOpcx := 4
            		cCode := aAux[2,3]
            	Endif
            Elseif Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
            	If !aAux[1]
            		lRet := .F.
                  cXmlRet := STR0005 // "O registro a ser excluído não existe na base Protheus"
                  Return {lRet, cXmlRet}
              Else
              	nOpcx := 5
              	cCode := aAux[2,3]
            	Endif
            Endif
            
            If Empty(Posicione("SX3", 2, PADR("NNR_CODIGO", 10), "X3_RELACAO"))
            	lInicPad := .F.
            Else
            	lInicPad := .T.
            Endif
            
            If !lInicPad .And. nOpcx == 3
            	If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)
            		If Len(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)) > TamSX3('NNR_CODIGO')[1]
                     lRet := .F.
                  	cXMLRet := STR0038+ AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text) + STR0039  + Chr(10) //"O Codigo do Local de Estoque " ## " possui tamanho maior que o permitido."
							cXMLRet += STR0040 + CValToChar(TamSx3("NNR_CODIGO")[1]) + Chr(10) //"Maximo:"
							cXMLRet += STR0041 + CValToChar(Len(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text))) //"Enviado:"

                     Return {lRet, cXmlRet}
                  Else
                     cCode := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
                  EndIf
              Else
              	lRet := .F.
                  cXmlRet := STR0003 // "O Code é obrigatório!"
                  Return {lRet, cXmlRet}
              Endif
            Endif
            
            If !Empty(cCode) .And. (!lInicPad .And. nOpcx == 3)
            	aAdd(aLocalEst, {"NNR_CODIGO", cCode, Nil}) // Código do Local
            Endif
            
            If nOpcx <> 3
            	NNR->(DbSetOrder(1))
            	lRet := NNR->(dbSeek(xFilial("NNR") + PadR(cCode, TamSX3("NNR_CODIGO")[1])))
            	
            	If !lRet
            		cXMLRet := "Local de estoque: " + AllTrim(cCode) + " não encontrado para alteração ou exclusão"
            		Return {lRet,cXMLRet}
            	Endif
            Endif
            
            oModel := FWLoadModel('AGRA045')
            
            If nOpcx == 3
            	oModel:SetOperation(MODEL_OPERATION_INSERT)
            ElseIf nOpcx == 4
            	oModel:SetOperation(MODEL_OPERATION_UPDATE)
            Elseif nOpcx == 5
            	oModel:SetOperation(MODEL_OPERATION_DELETE)
            Endif
            
            If nOpcx <> 5
               // Verifica se a descrição do local foi informada
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text)
                  If Len(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text)) > TamSX3('NNR_DESCRI')[1]
                     lRet := .F.
                     cXmlRet := STR0021 // "A Descrição do Local não pode ser maior que 20 caracteres!"
                     Return {lRet, cXmlRet}
                  Else
                     aAdd(aLocalEst, {"NNR_DESCRI", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, Nil}) // Descricao do Local
                  EndIf
               Else
                  lRet := .F.
                  cXmlRet := STR0004 // "A Descrição do Local é obrigatória!"
                  Return {lRet, cXmlRet}
               EndIf

               // Obtém o Tipo do Local
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)
                  aAdd(aLocalEst, {"NNR_TIPO", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text, Nil}) // Tipo do Local
               EndIf
               
               If nOpcx == 4
                  If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Active:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Active:Text)
                     If AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Active:Text)) == "FALSE" .And. NNR->(FieldPos('NNR_MSBLQL')) > 0
                        aAdd(aLocalEst, {"NNR_MSBLQL", '1', Nil})
                     Endif
               	Endif
               EndIf
            Endif
            
            oModel:Activate()

            // Obtém a estrutura de dados
            aAux := oModel:GetModel('NNRMASTER'):GetStruct():GetFields()

            If oModel:nOperation != MODEL_OPERATION_DELETE
               For nI := 1 To Len(aLocalEst)
                  // Verifica se os campos passados existem na estrutura do modelo
                  // Não enviar a filial e o código ao alterar
                  If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aLocalEst[nI][1])}) > 0 .And. (aLocalEst[nI][1] != "NNR_CODIGO" .Or. (!lInicPad .And. nOpcx == 3)) 
                     // É feita a atribuição do dado ao campo do Model
                     If !oModel:SetValue('NNRMASTER', aLocalEst[nI][1], aLocalEst[nI][2])
                        lRet := .F.
                        cXmlRet := STR0022 /*"Não foi possível atribuir o valor "*/ + AllToChar(aLocalEst[nI][2]) + STR0023 /*" ao campo "*/ + aLocalEst[nI][1] + "."
                        Return {lRet, cXmlRet}
                     EndIf
                  EndIf
               Next nI
            EndIf

            // Se os dados não são válidos
            If !oModel:VldData()
               // Obtém o log de erros
               aErro := oModel:GetErrorMessage()

               cXmlRet := "<![CDATA["
               cXmlRet += STR0024 + AllToChar(aErro[6]) + CRLF // "Mensagem do erro: " 
               cXmlRet += STR0025 + AllToChar(aErro[7]) + CRLF // "Mensagem da solução: " 
               cXmlRet += STR0026 + AllToChar(aErro[8]) + CRLF // "Valor atribuído: " 
               cXmlRet += STR0027 + AllToChar(aErro[9]) + CRLF // "Valor anterior: " 
               cXmlRet += STR0028 + AllToChar(aErro[1]) + CRLF // "Id do formulário de origem: " 
               cXmlRet += STR0029 + AllToChar(aErro[2]) + CRLF // "Id do campo de origem: " 
               cXmlRet += STR0030 + AllToChar(aErro[3]) + CRLF // "Id do formulário de erro: " 
               cXmlRet += STR0031 + AllToChar(aErro[4]) + CRLF // "Id do campo de erro: " 
               cXmlRet += STR0032 + AllToChar(aErro[5])        // "Id do erro: " 
               cXmlRet += "]]>"

               lRet := .F.
            Else
               // Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
               oModel:CommitData()

               // Se o evento é diferente de DELETE
               If oModel:nOperation != MODEL_OPERATION_DELETE
                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, IntLocExt(, , NNR->NNR_CODIGO)[2], .F.)
               Else
                  // Exclui o registro na tabela XXF (de/para)
                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, IntLocExt(, , cCode)[2], .T.)
               EndIf

               // Monta o XML de Retorno
               cXmlRet := "<ListOfInternalId>"
               cXmlRet +=    "<InternalId>"
               cXmlRet +=       "<Name>" + cEntity + "</Name>"
               cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
               If oModel:nOperation != MODEL_OPERATION_DELETE
               	cXmlRet +=       "<Destination>" + IntLocExt(, , NNR->NNR_CODIGO)[2] + "</Destination>"
               Else
               	cXmlRet +=       "<Destination>" + IntLocExt(, , cCode)[2] + "</Destination>"
               Endif
               cXmlRet +=    "</InternalId>"
               cXmlRet += "</ListOfInternalId>"
            EndIf

            oModel:DeActivate()
         Else
            lRet := .F.
            cXmlRet := STR0008 // "Erro no parser!"
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         // Faz o parser do XML de retorno em um objeto
         oXML := xmlParser(xEnt, "_", @cError, @cWarning)

         // Se não houve erros na resposta
         If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
            // Verifica se a marca foi informada
            If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
               cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet    := .F.
               cXmlRet := STR0009 // "Erro no retorno. O Product é obrigatório!"
               AdpLogEAI(5, "AGRI045", cXMLRet, lRet)
               Return {lRet, cXmlRet}
            EndIf
			 
			 If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") <> "U"
	            // Verifica se o código interno foi informado
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)
	               cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0010 // "Erro no retorno. O OriginalInternalId é obrigatório!"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Verifica se o código externo foi informado
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)
	               cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0011 // "Erro no retorno. O DestinationInternalId é obrigatório"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Obtém a mensagem original enviada
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
	               cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0012 // "Conteúdo do MessageContent vazio!"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Faz o parse do XML em um objeto
	            oXML := XmlParser(cXML, "_", @cError, @cWarning)
	
	            // Se não houve erros no parse
	            If oXML <> Nil .And. Empty(cError) .And. Empty(cWarning)
	               If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
	                  // Insere / Atualiza o registro na tabela XXF (de/para)
					  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
	               ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
	                  // Exclui o registro na tabela XXF (de/para)
					  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
	               Else
	                  lRet := .F.
	                  cXmlRet := STR0013 // "Evento do retorno inválido!"
	               EndIf
	            Else
	               lRet := .F.
	               cXmlRet := STR0014 // "Erro no parser do retorno!"
	               Return {lRet, cXmlRet}
	            EndIf
	         Endif
         Else
            // Se não for array
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
               // Transforma em array
               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            EndIf

            // Percorre o array para obter os erros gerados
            For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
               cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
            Next nCount

            lRet := .F.
            cXmlRet := cError
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         cXMLRet := "1.000|1.001|1.002"
      Endif
   ElseIf nTypeTrans == TRANS_SEND
	  IF TYPE('OMODELNNR') == 'U'
	  	IF SUPERGETMV('MV_INTSFC',.F.,0) == 0
	    	oModel := FWMODELACTIVE()
	  	ELSE
	  		oModel := FWLOADMODEL('AGRA045')
			oModel:Activate()
	   	ENDIF 
	   	oModelNNR := oModel:GetModel('NNRMASTER')
	  ENDIF

      //Verifica operação realizada
      Do Case
         Case oModel:nOperation == MODEL_OPERATION_INSERT
            cEvent := 'upsert' //Inclusão
         Case oModel:nOperation == MODEL_OPERATION_UPDATE
            cEvent := 'upsert' //Alteração
         Case oModel:nOperation == MODEL_OPERATION_DELETE
            cEvent := 'delete' //Exclusão
            If !lIntegPPI
		    		CFGA070Mnt(,"NNR","NNR_CODIGO",,IntLocExt(,,RTrim(oModelNNR:GetValue('NNR_CODIGO')))[2],.T.)
	    		EndIf
      EndCase

      cXMLRet := '<BusinessEvent>'
      cXMLRet +=    '<Entity>' + cEntity + '</Entity>'
      cXMLRet +=    '<Event>' + cEvent + '</Event>'
      cXMLRet +=    '<Identification>'
      cXMLRet +=       '<key name="InternalID">' + IntLocExt(, , RTrim(oModelNNR:GetValue('NNR_CODIGO')))[2] + '</key>'
      cXMLRet +=    '</Identification>'
      cXMLRet += '</BusinessEvent>'
      cXMLRet += '<BusinessContent>'
      cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
      cXMLRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
      cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
      cXMLRet +=    '<Code>' + RTrim(oModelNNR:GetValue('NNR_CODIGO')) + '</Code>'
      cXMLRet +=    '<InternalId>' + IntLocExt(, , RTrim(oModelNNR:GetValue('NNR_CODIGO')))[2] + '</InternalId>'
      cXMLRet +=    '<Description>' + _NoTags(RTrim(oModelNNR:GetValue('NNR_DESCRI'))) + '</Description>'
      cXMLRet +=    '<Active>' + 'true' + '</Active>
      cXMLRet +=    '<WarehouseClassification>' + oModelNNR:GetValue('NNR_INTP') + '</WarehouseClassification>'
      cXMLRet +=    '<WorkCenterCode>' + oModelNNR:GetValue('NNR_CTRAB') + '</WorkCenterCode>'
      If NNR->(FieldPos("NNR_TIPO")) > 0
  		cXMLRet +=    '<Type>' + oModelNNR:GetValue('NNR_TIPO') + '</Type>'
  	  EndIf
  	  
  	  If !RTrim(oModelNNR:GetValue('NNR_CODIGO')) $ cWHECommer 
  	  	cXMLRet +=    '<Purpose>1</Purpose>'
  	  Else
  	  	cXMLRet +=    '<Purpose>2</Purpose>'
  	  EndIf
  	  
  	  If RTrim(oModelNNR:GetValue('NNR_CODIGO')) == cWHDefault
  	  	cXMLRet +=    '<StandardWarehouse>1</StandardWarehouse>'
  	  Else
  	  	cXMLRet +=    '<StandardWarehouse>2</StandardWarehouse>'
  	  EndIf
  	  
      cXMLRet +=    '<IsFinalItem/>'
      cXMLRet +=    '<IsQualityControl/>'
      cXMLRet +=    '<IsProcess/>'
      cXMLRet +=    '<IsWaste/>'
      cXMLRet +=    '<IsRecycled/>'
      cXMLRet +=    '<IsBalanceAvailable/>'
      cXMLRet += '</BusinessContent>'
      If lIntegPPI
         completXml(@cXMLRet)
      EndIf
   EndIf

   If !lIntegPPI
   	AdpLogEAI(5, "AGRI045", cXMLRet, lRet)
   EndIf

Return {lRet, cXMLRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntLocExt
Monta o InternalID do Local de Estoque de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cLocalEst  Código do Local de Estoque
@param   cVersao    Versão da mensagem única (Default 1.000)

@author  Leandro Luiz da Cruz
@version P11
@since   08/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntLocExt(,,'01') irá retornar {.T.,'01|01|01'}
/*/
//-------------------------------------------------------------------
Function IntLocExt(cEmpresa, cFil, cLocalEst, cVersao)
   Local aResult    := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('NNR')
   Default cVersao  := '1.000'

   If cVersao == '1.000' .Or. cVersao == '1.001'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cLocalEst))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0033 + Chr(10) + STR0035) // "Versão do local de estoque não suportada." "As versões suportadas são: 1.000"
   EndIf   
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntLocInt
Recebe um InternalID e retorna o código do Local de Estoque.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 1.000)

@author  Leandro Luiz da Cruz
@version P11
@since   08/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,
         filial e o Código do Local de Estoque.

@sample  IntLocInt('01|01|01') irá retornar {.T., {'01', '01', '01'}}
/*/
//-------------------------------------------------------------------
Function IntLocInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   aTemp    := {}
   Local   cTemp    := ''
   Local   cAlias   := 'NNR'
   Local   cField   := 'NNR_CODIGO'
   Default cVersao  := '1.000'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0034 + " -> " + cInternalID ) // "Local de Estoque não encontrado no de/para!"
   Else
      If cVersao == '1.000' .Or. cVersao == '1.001' .Or. cVersao == '1.002'
         aAdd(aResult, .T.)
         aTemp := Separa(cTemp, '|')
         aAdd(aResult, aTemp)
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, STR0033 + Chr(10) + STR0035) // "Versão do local de estoque não suportada." "As versões suportadas são: 1.000"
      EndIf   
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} completXml()
Adiciona o cabeçalho da mensagem quando utilizado integração com o PPI.

@param   cXML  - XML gerado pelo adapter. Parâmetro recebido por referência.

@author  Lucas Konrad França
@version P12
@since   17/08/2015
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function completXml(cXML)
   Local cCabec     := ""
   Local cCloseTags := ""
   Local cGenerated := ""

   cGenerated := SubStr(DTOS(Date()), 1, 4) + '-' + SubStr(DTOS(Date()), 5, 2) + '-' + SubStr(DTOS(Date()), 7, 2) + 'T' + Time()

   cCabec := '<?xml version="1.0" encoding="UTF-8" ?>'
   cCabec += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="xmlschema/general/events/Warehouse_1_001.xsd">'
   cCabec +=     '<MessageInformation version="1.001">'
   cCabec +=         '<UUID>1</UUID>'
   cCabec +=         '<Type>BusinessMessage</Type>'
   cCabec +=         '<Transaction>Warehouse</Transaction>'
   cCabec +=         '<StandardVersion>1.0</StandardVersion>'
   cCabec +=         '<SourceApplication>SIGAPCP</SourceApplication>'
   cCabec +=         '<CompanyId>'+cEmpAnt+'</CompanyId>'
   cCabec +=         '<BranchId>'+cFilAnt+'</BranchId>'
   cCabec +=         '<UserId>'+__cUserId+'</UserId>'
   cCabec +=         '<Product name="'+FunName()+'" version="'+GetRPORelease()+'"/>'
   cCabec +=         '<ContextName>PROTHEUS</ContextName>'
   cCabec +=         '<GeneratedOn>' + cGenerated +'</GeneratedOn>'
   cCabec +=         '<DeliveryType>Sync</DeliveryType>'
   cCabec +=     '</MessageInformation>'
   cCabec +=     '<BusinessMessage>'

   cCloseTags := '</BusinessMessage>'
   cCloseTags += '</TOTVSMessage>'
   
   cXML := cCabec + cXML + cCloseTags

Return Nil


//-------------------------------------------------------------------
//{Protheus.doc} V1000J
//-------------------------------------------------------------------
Static Function V1000J(xEnt, nTypeTrans, cTypeMessage)

	Local cRet   	    := ""
	Local cEntity       := "WAREHOUSE"
	Local cEvent        := ""
	Local lRet          := .T.
	Local cError        := ""
	Local cWarning      := ""
	Local oModel        := Nil
	Local oModelNNR     := Nil
	Local cWHECommer	:= GetNewPar("MV_LJECOMG","01")
	Local cWHDefault	:= GetNewPar("MV_LJECLPE","01")
	Local ofwEAIObj     := FWEAIobj():NEW()
	Local aRet			:= {}
    Local nX   			:= 0
    Local nI            := 0
    Local cProduct      := ""
    Local cValExt       := ""
    Local cMsgRet 	    := ""
    Local cValInt       := ""
    Local cCode         := ""
    Local cAlias        := "NNR"
    Local cField        := "NNR_CODIGO" 
    Local nOpcx         := 0
    Local aLocalEst     := {}
    Local aAux          := {}
    Local lInicPad      := .F.

	Private lIntegPPI 	:= .F.

	//Verifica se está sendo executado para realizar a integração com o PPI.
	//Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
	//Variável é criada no fonte AGRA045.prw, na função AGRA045PPI().
	If Type("lRunPPI") == "L" .And. lRunPPI
		lIntegPPI := .T.
	EndIf

	//Mensagem de Entrada
	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS

            // Verifica se a marca foi informada
            If xEnt:getHeaderValue("ProductName") != Nil .And. !Empty(xEnt:getHeaderValue("ProductName"))
                cProduct := AllTrim(xEnt:getHeaderValue("ProductName"))
            Else
                lRet := .F.
                cMsgRet += STR0001 // "A marca é obrigatória"
                Return {lRet, cMsgRet}
            EndIf

            If lRet .And. xEnt:getPropValue("InternalId")  != Nil
                cValExt := ( xEnt:getPropValue("InternalId") )
            Else
                lRet := .F.
                cMsgRet := STR0002 // "O InternalId é obrigatório!"
                Return {lRet, cMsgRet}
            EndIf
            
            aAux := IntLocInt(cValExt,cProduct)
            
            If lRet .And. xEnt:getPropValue("Event")  != Nil
                If AllTrim(Upper(xEnt:getPropValue("Event"))) ==  "UPSERT"
                    If !aAux[1]
                        nOpcx := 3
                    Else
                        nOpcx := 4
                        cCode := aAux[2,3]
                    Endif  
                ElseIf AllTrim(Upper(xEnt:getPropValue("Event"))) ==  "DELETE"
                    If !aAux[1]
            		    lRet := .F.
                        cMsgRet := STR0005 // "O registro a ser excluído não existe na base Protheus"
                        Return {lRet, cMsgRet}
                    Else
                        nOpcx := 5
                        cCode := aAux[2,3]
                    Endif
                Endif
            Else
                lRet := .F.
                cMsgRet := STR0002 // "O InternalId é obrigatório!"
                Return {lRet, cMsgRet}
            EndIf            

            lInicPad := !Empty(Posicione("SX3", 2, PADR("NNR_CODIGO", 10), "X3_RELACAO"))
            
            If !lInicPad .And. nOpcx == 3
                If lRet .And. xEnt:getPropValue("Code")  != Nil
                    If Len( AllTrim(xEnt:getPropValue("Code")) ) > TamSX3('NNR_CODIGO')[1]
                        lRet := .F.
                  	    cMsgRet := STR0038+ AllTrim(xEnt:getPropValue("Code")) + STR0039  + Chr(10) //"O Codigo do Local de Estoque " ## " possui tamanho maior que o permitido."
						cMsgRet += STR0040 + CValToChar(TamSx3("NNR_CODIGO")[1]) + Chr(10) //"Maximo:"
						cMsgRet += STR0041 + CValToChar(Len(AllTrim(xEnt:getPropValue("Code")))) //"Enviado:"
                        Return {lRet, cMsgRet}
                    Else
                        cCode := xEnt:getPropValue("Code")
                    EndIf
                Else
                    lRet := .F.
                    cMsgRet := STR0003 // "O Code é obrigatório!"
                    Return {lRet, cMsgRet}
                EndIf
            Endif
            
            If !Empty(cCode) .And. (!lInicPad .And. nOpcx == 3)
            	aAdd(aLocalEst, {"NNR_CODIGO", cCode, Nil}) // Código do Local
            Endif
            
            If nOpcx <> 3
            	NNR->(DbSetOrder(1))
            	lRet := NNR->(dbSeek(xFilial("NNR") + PadR(cCode, TamSX3("NNR_CODIGO")[1])))
            	
            	If !lRet
            		cMsgRet := "Local de estoque: " + AllTrim(cCode) + " não encontrado para alteração ou exclusão"
            		Return {lRet,cMsgRet}
            	Endif
            Endif
            
            oModel := FWLoadModel('AGRA045')
            
            If nOpcx == 3
            	oModel:SetOperation(MODEL_OPERATION_INSERT)
            ElseIf nOpcx == 4
            	oModel:SetOperation(MODEL_OPERATION_UPDATE)
            Elseif nOpcx == 5
            	oModel:SetOperation(MODEL_OPERATION_DELETE)
            Endif
            
            If nOpcx <> 5
                // Verifica se a descrição do local foi informada
                If lRet .And. xEnt:getPropValue("Description")  != Nil
                    If Len(AllTrim(xEnt:getPropValue("Description") )) > TamSX3('NNR_DESCRI')[1]
                        lRet := .F.
                        cMsgRet := STR0021 // "A Descrição do Local não pode ser maior que 20 caracteres!"
                        Return {lRet, cMsgRet}
                    Else
                        aAdd(aLocalEst, {"NNR_DESCRI", xEnt:getPropValue("Description"), Nil}) // Descricao do Local
                    EndIf
                Else
                    lRet := .F.
                    cMsgRet := STR0004 // "A Descrição do Local é obrigatória!"
                    Return {lRet, cMsgRet}
                EndIf
            
               // Obtém o Tipo do Local
               If lRet .And. xEnt:getPropValue("Type")  != Nil
                    aAdd(aLocalEst, {"NNR_TIPO", xEnt:getPropValue("Type"), Nil}) // Tipo do Local
               EndIf
               
               If lRet .And. nOpcx == 4 .And. xEnt:getPropValue("Active")  != Nil
                    If AllTrim(Upper(xEnt:getPropValue("Active") )) == "FALSE" .And. NNR->(FieldPos('NNR_MSBLQL')) > 0
                        aAdd(aLocalEst, {"NNR_MSBLQL", '1', Nil})
                    Endif
               Endif
            Endif
            
            oModel:Activate()

            // Obtém a estrutura de dados
            aAux := oModel:GetModel('NNRMASTER'):GetStruct():GetFields()

            If oModel:nOperation != MODEL_OPERATION_DELETE
               For nI := 1 To Len(aLocalEst)
                  // Verifica se os campos passados existem na estrutura do modelo
                  // Não enviar a filial e o código ao alterar
                  If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aLocalEst[nI][1])}) > 0 .And. (aLocalEst[nI][1] != "NNR_CODIGO" .Or. (!lInicPad .And. nOpcx == 3)) 
                     // É feita a atribuição do dado ao campo do Model
                     If !oModel:SetValue('NNRMASTER', aLocalEst[nI][1], aLocalEst[nI][2])
                        lRet := .F.
                        cMsgRet := STR0022 /*"Não foi possível atribuir o valor "*/ + AllToChar(aLocalEst[nI][2]) + STR0023 /*" ao campo "*/ + aLocalEst[nI][1] + "."
                        Return {lRet, cMsgRet}
                     EndIf
                  EndIf
               Next nI
            EndIf

            // Se os dados não são válidos
            lRet := oModel:VldData()
               
            If lRet
                // Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
                oModel:CommitData()

                // Se o evento é diferente de DELETE
                If oModel:nOperation != MODEL_OPERATION_DELETE
                    CFGA070Mnt(cProduct, cAlias, cField, cValExt, IntLocExt(, , NNR->NNR_CODIGO)[2], .F.)
                Else
                    // Exclui o registro na tabela XXF (de/para)
                    CFGA070Mnt(cProduct, cAlias, cField, cValExt, IntLocExt(, , cCode)[2], .T.)
                EndIf

                ofwEAIObj:Activate()
                ofwEAIObj:setProp("ReturnContent")
                If lRet

                    ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalId",{},'InternalId',,.T.)      
                    ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:setProp("Name",cEntity)
                    ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:setProp("Origin",      	cValExt)
                    ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:setProp("Destination",  IntLocExt(, , cCode)[2] )
                Else
                    ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgRet)	
                EndIf

                aAdd(aRet, lRet)
		        aAdd(aRet, ofwEAIObj)

            Else
                // Obtém o log de erros
                aErro := oModel:GetErrorMessage()

                cMsgRet += STR0024 + AllToChar(aErro[6]) + CRLF // "Mensagem do erro: " 
                cMsgRet += STR0025 + AllToChar(aErro[7]) + CRLF // "Mensagem da solução: " 
                cMsgRet += STR0026 + AllToChar(aErro[8]) + CRLF // "Valor atribuído: " 
                cMsgRet += STR0027 + AllToChar(aErro[9]) + CRLF // "Valor anterior: " 
                cMsgRet += STR0028 + AllToChar(aErro[1]) + CRLF // "Id do formulário de origem: " 
                cMsgRet += STR0029 + AllToChar(aErro[2]) + CRLF // "Id do campo de origem: " 
                cMsgRet += STR0030 + AllToChar(aErro[3]) + CRLF // "Id do formulário de erro: " 
                cMsgRet += STR0031 + AllToChar(aErro[4]) + CRLF // "Id do campo de erro: " 
                cMsgRet += STR0032 + AllToChar(aErro[5])        // "Id do erro: " 
               
                ofwEAIObj:Activate()
                ofwEAIObj:setProp("ReturnContent")
                ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgRet)	

            EndIf

            oModel:DeActivate()

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

            // Se não houve erros na resposta
			If xEnt:getPropValue("ProcessingInformation"):getPropValue("Status") <> Nil .And. Upper(xEnt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"  
	            
                // Verifica se a marca foi informada	            
				If xEnt:getHeaderValue("ProductName") !=  nil .And. !Empty( xEnt:getHeaderValue("ProductName") )
					cProduct := AllTrim(xEnt:getHeaderValue("ProductName"))
				Else
					lRet := .F.
					cRet += STR0001 // "A marca é obrigatória"
				EndIf
	
				If lRet .and. xEnt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId") !=  nil 
		            // Verifica se o código interno foi informado
					If xEnt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:getPropValue("Origin") != nil 
						cValInt := xEnt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:getPropValue("Origin")
					Else
						lRet := .F.
						cRet += STR0010 // "Erro no retorno. O OriginalInternalId é obrigatório!"
					EndIf
		
		            // Verifica se o código externo foi informado
					If xEnt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:getPropValue("Destination") != nil
						cValExt := xEnt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:getPropValue("Destination")
					Else
						lRet := .F.
						xEnt:Activate()
						cRet += STR0011 // "Erro no retorno. O DestinationInternalId é obrigatório"
					EndIf
					
					cEvent := xEnt:getPropValue("ReceivedMessage"):getPropValue("Event")
					
					If cEvent != NIL
						cEvent := Upper(cEvent)
					EndIf

					If RTrim(cEvent) $ "UPSERT|DELETE"
		          		//Atualiza o registro na tabela XXF (de/para)
						If !CFGA070Mnt(cProduct, "NNR", "NNR_CODIGO", cValExt, cValInt, (cEvent = "DELETE"))
							cRet += "Não foi possível gravar na tabela De/Para. Evento :" +cEvent + CRLF
							lRet := .F.
						EndIf
					Else
						lRet := .F.
						cRet += STR0025 + CRLF // "Evento do retorno inválido!"
					EndIf
				Endif
			Else
				cRet := ""
				If xEnt:getpropvalue('ProcessingInformation') != nil
					oMsgError := xEnt:getpropvalue('ProcessingInformation'):getpropvalue("Details")
					For nX := 1 To Len( oMsgError )
						cRet := oMsgError[nX]:getpropvalue('Message')
						If cRet != NiL .AND. ValType(cRet) == "C"
							cRet += cRet + CRLF
						EndIf
					Next nX
				Endif
	
				lRet := .F.
			EndIf
			If !lRet
				xEnt:Activate()
				xEnt:setProp("ReturnContent")
				xEnt:getPropValue("ReturnContent"):setProp("Error", cRet)

			EndIf
            aAdd(aRet, lRet)
		    aAdd(aRet, xEnt)
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS

			cRet := "1.000|1.001|1.002"
		    aAdd(aRet, .T.)
		    aAdd(aRet, ofwEAIObj)
		Endif



	ElseIf nTypeTrans == TRANS_SEND

		IF TYPE('OMODELNNR') == 'U'
			IF SUPERGETMV('MV_INTSFC',.F.,0) == 0
				oModel := FWMODELACTIVE()
			ELSE
				oModel := FWLOADMODEL('AGRA045')
				oModel:Activate()
			ENDIF 
			oModelNNR := oModel:GetModel('NNRMASTER')
		ENDIF

		//Verifica operação realizada
		Do Case
			Case oModel:nOperation == MODEL_OPERATION_INSERT
			cEvent := 'upsert' //Inclusão
			Case oModel:nOperation == MODEL_OPERATION_UPDATE
			cEvent := 'upsert' //Alteração
			Case oModel:nOperation == MODEL_OPERATION_DELETE
			cEvent := 'delete' //Exclusão
			If !lIntegPPI
			    CFGA070Mnt(,"NNR","NNR_CODIGO",,IntLocExt(,,RTrim(oModelNNR:GetValue('NNR_CODIGO')))[2],.T.)
			EndIf
		EndCase

		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)

		//	ofwEAIObj:setbatch(1) SÓ QUANDO USA LOTE

		ofwEAIObj:setProp("Entity"           		,cEntity)
		ofwEAIObj:setProp("Event"            		,cEvent)
		ofwEAIObj:setProp("InternalId"       		,IntLocExt(, , RTrim(oModelNNR:GetValue('NNR_CODIGO')))[2]  )
		ofwEAIObj:setProp("CompanyId"        		,cEmpAnt)
		ofwEAIObj:setProp("BranchId"         		,cFilAnt)
		ofwEAIObj:setProp("CompanyinternalId"		,cEmpAnt + '|' + cFilAnt )
		ofwEAIObj:setProp("Code"						,RTrim(oModelNNR:GetValue('NNR_CODIGO')) )
		ofwEAIObj:setProp("Description"				,_NoTags(RTrim(oModelNNR:GetValue('NNR_DESCRI'))) )
		ofwEAIObj:setProp("Active"		    		,'true'  )

		ofwEAIObj:setProp("WarehouseClassification"	,oModelNNR:GetValue('NNR_INTP')   )
		ofwEAIObj:setProp("WorkCenterCode"			,oModelNNR:GetValue('NNR_CTRAB')  )

		If NNR->(ColumnPos("NNR_TIPO") > 0)
			ofwEAIObj:setProp("Type"					,oModelNNR:GetValue('NNR_TIPO')   )
		EndIf

		If !RTrim(oModelNNR:GetValue('NNR_CODIGO')) $ cWHECommer 
			ofwEAIObj:setProp("Purpose"				,1       )
		Else
			ofwEAIObj:setProp("Purpose"				,2       )
		EndIf

		If RTrim(oModelNNR:GetValue('NNR_CODIGO')) == cWHDefault
			ofwEAIObj:setProp("StandardWarehouse"	,1       )
		Else
			ofwEAIObj:setProp("StandardWarehouse"	,2       )
		EndIf
		aAdd(aRet, .T.)
		aAdd(aRet, ofwEAIObj)

	EndIf

	
Return {aRet[1],aRet[2]}
