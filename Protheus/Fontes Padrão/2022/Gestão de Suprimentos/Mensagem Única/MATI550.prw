#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'MATI550.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI550
Função para processamento de mensagem única do cadastro de grade de produtos
Uso: MATA550

@sample 	 MATI550( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
@param		cXML - Variavel com conteudo xml para envio/recebimento.
			nTypeTrans - Tipo de transacao. (Envio/Recebimento)
			cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, Request)
@return	aRet - Array contendo o resultado da execução e o xml de retorno.
			aRet[1] - (boolean) Indica o resultado da execução da função.
			aRet[2] - (caracter) Mensagem Xml para envio.
@author	Fábio S. dos Santos
@since		08/01/2018
@version	P12.1.17
@Alterado por Roberto R. Mezzalira - incluso tratamento para Json
@data :  13/07/18 
/*/
//-------------------------------------------------------------------
Function MATI550( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Local aArea		:= GetArea()		//Salva contexto do alias atual  
Local aRet		:= {.T.,"","ITEMGRID"} 	//Array de retorno da função
Local lRet 		:= .T.				//Indica o resultado da execução da função
Local cXMLRet		:= ''				//Xml que será enviado pela função
Local cError		:= ''				//Mensagem de erro do parse no xml recebido como parâmetro
Local cWarning	:= ''				//Mensagem de alerta do parse no xml recebido como parâmetro
Local cVersao		:=	""				//Indica a versao da mensagem 
Local nI			:= 0				//Contador de uso geral			
Local oXML 		:= Nil				//Objeto com o conteúdo do arquivo Xml


Default xEnt			:= ""            
Default nTypeTrans		:= 3
Default cTypeMessage	:= ""
Default cVersion		:= ""
Default cTransac		:= ""
Default lEAIObj			:= .F.

If ( nTypeTrans == TRANS_RECEIVE )

	If ( cTypeMessage == EAI_MESSAGE_BUSINESS ) .Or. ( cTypeMessage == EAI_MESSAGE_RESPONSE )
	   		If !lEAIObj //xml
				oXML := XmlParser( xEnt, '_', @cError, @cWarning )	
			
				If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )
					// Versão da mensagem
					If Type("oXML:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXML:_TOTVSMessage:_MessageInformation:_version:Text)
						cVersao := StrTokArr(oXML:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
						
						//Faz chamada da versão especifica   
						If cVersao == "1"
							aRet := v1000(xEnt, nTypeTrans, cTypeMessage, oXML)
						Else
							lRet    := .F.
							cXmlRet := STR0001 //-- Não foi implementado adapter para esta versão de mensagem.  
							aRet := { lRet , cXMLRet ,"ITEMGRID" }
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0002 //-- Versão da mensagem não informada! 
						aRet := { lRet , cXMLRet,"ITEMGRID" }
					EndIf			
				Else
					//Tratamento no erro do parse Xml
					lRet := .F.
					cXMLRet := STR0003  //-- Erro no parser da mensagem recebida:	
					cXMLRet += IIf ( !Empty(cError), cError, cWarning )		
					cXMLRet := EncodeUTF8(cXMLRet)		
					aRet := { lRet , cXMLRet ,"ITEMGRID"}
				EndIf
			Else
				cVersao := StrTokArr(xEnt:getHeaderValue("Version"), ".")[1]
				If Empty(cVersao)
			       lRet := .F.
			       cXmlRet := STR0002 //-- Versão da mensagem não informada
			
				ElseIf  !( AllTrim(cVersao) == "1")
					lRet    := .F.
			        cXmlRet := STR0001 //-- Não foi implementado adapter para esta versão de mensagem.  				
				EndIf	
				
				If !lRet
					aRet := { lRet , cXMLRet,"ITEMGRID" }
				Else
					aRet := v1000_O(xEnt, nTypeTrans, cTypeMessage)
				EndIf	
			EndIf
	//Recebimento da WhoIs 
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS		
			cXMLRet := '1.000'
			aRet := { lRet , cXMLRet ,"ITEMGRID" }
	EndIf								
    
//Trata o envio de mensagem                                    	
ElseIf ( nTypeTrans == TRANS_SEND )
    
	If !lEAIObj //xml
		cVersao := StrTokArr(RTrim(PmsMsgUVer('ITEMGRID','MATA550')), ".")[1]
		//Faz chamada da versão especifica   
		If cVersao == "1"
			aRet := v1000(xEnt, nTypeTrans, cTypeMessage, oXML)
		Else
			lRet    := .F.
			cXmlRet := STR0004 //-- Não foi implementado adapter para esta versão de mensagem. 
			aRet := { lRet , cXMLRet ,"ITEMGRID"}
		EndIf
	Else //json
		cVersao := StrTokArr(RTrim(PmsMsgUVer('ITEMGRID','MATA550')), ".")[1]
		
		//Faz chamada da versão especifica   
		If cVersao == "1"
	    	aRet := v1000_O(xEnt, nTypeTrans, cTypeMessage)
		Else
	   		cRet := STR0004 // "A versão da mensagem não foi informada ou não foi implementada!"  //STR0011    	 
	   		aRet := { lRet , cRet ,"ITEMGRID"}
		EndIf

   Endif

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} V1000
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de categoria utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author fabio.santos
@version P12
@since 14/03/2018
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function v1000(xEnt, nTypeTrans, cTypeMessage, oXml)
Local aArea		:= GetArea()		//Salva contexto do alias atual  
Local aRet 		:= {}				//Array de retorno da função
Local lRet 		:= .T.				//Indica o resultado da execução da função
Local cVersao		:=	""				//Indica a versao da mensagem  
Local cEvent		:= 'upsert'		//Operação realizada na master e na detail ( upsert ou delete )  
Local cXmlRet		:= "" 
Local cError		:= ""
Local cWarning	:= ""  
Local nI			:= 0
Local cVarTab		:= ''				//Codigo da tabela da variante

Default xEnt 			:= ""
Default nTypeTrans 		:= 3
Default cTypeMessage 	:= ""
Default oXml			:= XmlParser(xEnt, "_", @cError, @cWarning)

// Trata o recebimento de mensagem 
If ( nTypeTrans == TRANS_RECEIVE )
	// Recebimento da Business Message
	If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
		lRet    := .F.
		cXmlRet := STR0005 //-- Recebimento não implementado para esta versão e adapter. 
		aRet := { lRet , cXMLRet }	
	//Recebimento da Response Message 
	ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )
		//Gravacao do De/Para Codigo Interno X Codigo Externo
		If oXml <> Nil .And. Empty(cError) .And. Empty(cWarning)
			If Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
				If oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And.	!Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				EndIf
			   	
				If oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text <> Nil .And.;
						!Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)
					cValInt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
				EndIf
			   	
				If oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text <> Nil .And.;
						!Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)
					cValExt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
				EndIf
	
				If !Empty(cValExt) .And. !Empty(cValInt)
					If !CFGA070Mnt(cMarca, "SB4", "B4_COD", cValExt, cValInt)
						lRet := .F.
						cXmlRet := STR0006 //-- Não foi possível gravar na tabela De/Para. 
					EndIf
				Else
					cXmlRet := STR0007 //-- Valor interno ou externo em branco não sendo possível gravar na tabela De/Para. 
					lRet := .F.
				EndIf
			ElseIf oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message <> Nil //-- Erro
   				//Se não for array
				If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) <> "A"
          		//Transforma em array
					XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf

          		//Percorre o array para obter os erros gerados
				For nI := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cError := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + CRLF
				Next nI

				lRet 	 := .F.
				cXmlRet := cError
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0003 + cError + ' | ' + cWarning //-- Erro no parser da mensagem recebida:	
	   	EndIf	
	EndIf
// Trata o envio de mensagem             
ElseIf ( nTypeTrans == TRANS_SEND )
	cVersao := StrTokArr(RTrim(PmsMsgUVer('ITEMGRID','MATA550')), ".")[1]
	If !Inclui .And. !Altera
		cEvent := 'delete'
		CFGA070Mnt(,"SB4","B4_COD",,IntGrdExt(,,SB4->B4_COD,cVersao)[2],.T.)
	Else
		cEvent := 'upsert'
	EndIf
	
	If cEvent == 'upsert'
		cB4_COD     := M->B4_COD
		cB4_DESC    := M->B4_DESC
	Else
		cB4_COD     := SB4->B4_COD
		cB4_DESC    := SB4->B4_DESC
	EndIf
	
	//Monta Business Event
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>CommercialFamily</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalID">' + IntGrdExt(/*Empresa*/, /*Filial*/, cB4_COD, cVersao)[2] + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	//Monta a msg do cadastro de grade de produtos
	cXMLRet += '<BusinessContent>'
	
	cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
	cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
	cXMLRet +=		'<Code>' + cB4_COD + '</Code>'
	cXMLRet +=		'<InternalId>' + IntGrdExt(/*Empresa*/, /*Filial*/, cB4_COD, cVersao)[2] + '</InternalId>'
	cXMLRet +=		'<Description>' + _NoTags(AllTrim(cB4_DESC)) + '</Description>'
	cXMLRet +=		'<ListOfGridVariants>' 
	
	//Query para listar as variantes de acordo com o código do produto da grade
	IF Select( "TMPSBV" ) > 0
		dbSelectArea( "TMPSBV" )
		dbCloseArea()
	EndIf
	BeginSql Alias "TMPSBV"
	
		SELECT BV_TABELA, BV_DESCTAB, BV_DESCRI
		FROM %table:SBV% SBV
		INNER JOIN %table:SB4% SB4 ON
		SB4.B4_FILIAL = %exp:xFilial("SB4")% AND
		SB4.B4_COD = %exp:cB4_COD% AND
		((SB4.B4_LINHA = SBV.BV_TABELA) OR (SB4.B4_COLUNA = SBV.BV_TABELA)) AND
		SB4.%notDel%
		WHERE SBV.BV_FILIAL = %exp:xFilial("SBV")% AND SBV.%notDel%
		
	EndSql
		
	TMPSBV->(DbGoTop())	
	
	Do While TMPSBV->(!EOF())
		If TMPSBV->BV_TABELA != cVarTab
			cVarTab := TMPSBV->BV_TABELA
			
			cXMLRet +=	'<GridVariant>'
			cXMLRet +=	'<VariantName>' + AllTrim(TMPSBV->BV_DESCTAB) + '</VariantName>'
			cXMLRet +=	'<ListOfVariantValues>'
		EndIf
		
		While TMPSBV->BV_TABELA == cVarTab
			cXMLRet +=		'<VariantValue>' + AllTrim(TMPSBV->BV_DESCRI) + '</VariantValue>'
					
			TMPSBV->(DbSkip())
		End
		cXMLRet +=	'</ListOfVariantValues>'
		cXMLRet +=	'</GridVariant>'
	EndDo
	IF Select( "TMPSBV" ) > 0
		dbSelectArea( "TMPSBV" )
		dbCloseArea()
	EndIf
	
	cXMLRet += '</ListOfGridVariants>'
	cXMLRet += '</BusinessContent>'			
EndIf
     
RestArea(aArea)

Return {lRet, cXmlRet,"ITEMGRID"}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntGrdExt
Monta o InternalID da grade de produtos de acordo com o código passado no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cCodGrd    Código da grade de produtos
@param   cVersao    Versão da mensagem única (Default 1.000)

@author  Fábio S. dos Santos
@version P12.1.17
@since   08/01/2017
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntGrdExt(,,'01') irá retornar {.T.,'01|01|01'}
/*/
//-------------------------------------------------------------------
Static Function IntGrdExt(cEmpresa, cFil, cCodGrd, cVersao)

Local aResult    := {}

Default cEmpresa := cEmpAnt
Default cFil     := xFilial('SB4')
Default cVersao  := '1'

If cVersao == '1'
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cCodGrd))
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0001) //-- Não foi implementado adapter para esta versão de mensagem.
EndIf

Return aResult

//-------------------------------------------------------------------
/*/ V1000_O
Funcao de integracao com o adapter EAI para envio e recebimento do cadastro de categoria utilizando o conceito de mensagem unica.
/*/
//-------------------------------------------------------------------
Static Function v1000_O(ofwEAIObjEntr, nTypeTrans, cTypeMessage)
Local aArea		:= GetArea()		//Salva contexto do alias atual  
Local aRet 		:= {}				//Array de retorno da função
Local lRet 		:= .T.				//Indica o resultado da execução da função
Local cVersao	:=	""				//Indica a versao da mensagem  
Local cEvent	:= 'upsert'			//Operação realizada na master e na detail ( upsert ou delete )  
Local cRet  	:= "" 
Local nx		:= 1
Local ny        := 1
Local cVarTab	:= ''				//Codigo da tabela da variante
Local cAlias	:= GetNextAlias()	//Alias temporario da query
Local ofwEAIObj := FWEAIobj():NEW()
Local cMarca := ""
Local cValInt := ""
Local cValExt := ""
Local cStatus := ""
Local cJson     := ''

//Default cXml 			:= ""
Default nTypeTrans 		:= 3
Default cTypeMessage 	:= ""

// Trata o recebimento de mensagem 
If ( nTypeTrans == TRANS_RECEIVE )
	
      If  cTypeMessage == EAI_MESSAGE_RESPONSE 
  
  
		If  !Empty(ofwEAIObjEntr)  .AND. ;
			ofwEAIObjEntr:getPropValue("ProcessingInformation") <> NIL .AND. ;
			( cStatus := ofwEAIObjEntr:getPropValue("ProcessingInformation"):getPropValue("Status") ) <> NIl  
			
			ConOut("cStatus", cStatus)
			If Upper(RTrim(cStatus) ) == "OK"   
			//Grava o de-para do cadastro de Produtos
				If (cMarca := ofwEAIObjEntr:getHeaderValue("ProductName")) = nil
					cMarca := ""
					lRet := .F.
				Else
		
					If ( cValInt :=  ofwEAIObjEntr:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")) = nil
						cValInt := ""
						lRet := .F.
					Else
		
						If (cValExt := ofwEAIObjEntr:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") ) = nil
							cValExt := ""
							lRet    := .F.
						Else
							//Trata o Evento de recepção: Delete
							cEvent :=  RTrim(Upper(ofwEAIObjEntr:getPropValue("ReceivedMessage"):getPropValue("Event")))
	
							If cEvent <> "DELETE"
	
								cEvent := "UPSERT"
							EndIf
						EndIf
					Endif
				EndIf

				lRet := lRet .AND. Valtype(cMarca) == "C" .AND. Valtype(cValInt) = "C" .AND. Valtype(cValExt) <> "O"
				
				If lRet
				//Gravando o de/para quando recebe o resultado
				//deve ser verificada as informações passadas aqui
					If cEvent <> "DELETE"
						lRet := CFGA070Mnt(cMarca, "SB4", "B4_COD", cValExt, cValInt)				
					EndIf				
					If  !lRet
						cRet := STR0006 //-- Não foi possível gravar na tabela De/Para.
					EndIf
				Else
					lRet    := .F. 
					cRet 	:=  STR0007 //-- Valor interno ou externo em branco não sendo possível gravar na tabela De/Para. 
			    Endif
			Else
				lRet := .F. 
				cRet := "Mensagem de resposta retornou status " + cStatus
			EndIf

		Else    
			lRet    := .F.
			cRet := STR0003 //Erro ao processar mensagem recebida
	
		EndIf
		
	 	If !lRet
			ofwEAIObj:Activate()
			ofwEAIObj:SetProp("ReturnContent")
			ofwEAIObj:GetPropValue("ReturnContent"):SetProp("ERROR", cRet)
		EndIf
	
	EndIf

// Trata o envio de mensagem             
ElseIf ( nTypeTrans == TRANS_SEND )

	cVersao := StrTokArr(RTrim(PmsMsgUVer('ITEMGRID','MATA550')), ".")[1]
	If !Inclui .And. !Altera
		cEvent := 'delete'
		CFGA070Mnt(,"SB4","B4_COD",,IntGrdExt(,,SB4->B4_COD,cVersao)[2],.T.)
	Else
		cEvent := 'upsert'
	EndIf
	
	If cEvent == 'upsert'
		cB4_COD     := M->B4_COD
		cB4_DESC    := M->B4_DESC
	Else
		cB4_COD     := SB4->B4_COD
		cB4_DESC    := SB4->B4_DESC
	EndIf
	
	ofwEAIObj:Activate()
	ofwEAIObj:setEvent(cEvent)
	
	ofwEAIObj:setProp("Entity"           		,'ITEMGRID')
	ofwEAIObj:setProp("Event"            		,cEvent)
	ofwEAIObj:setProp("CompanyId"        		,cEmpAnt)
	ofwEAIObj:setProp("BranchId"         		,cFilAnt)
	ofwEAIObj:setProp("CompanyinternalId"		,cEmpAnt + '|' + cFilAnt )
	ofwEAIObj:setProp("Code"						,cB4_COD )
	ofwEAIObj:setProp("InternalId"				,IntGrdExt(/*Empresa*/, /*Filial*/, cB4_COD, cVersao)[2] )
	ofwEAIObj:setProp("Description"				,_NoTags(AllTrim(cB4_DESC) ) )
	ofwEAIObj:setProp("Active"		    		,'true'  )

	//Query para listar as variantes de acordo com o código do produto da grade
	BeginSql Alias cAlias
	
		SELECT BV_TABELA, BV_DESCTAB, BV_DESCRI
		FROM %table:SBV% SBV
		INNER JOIN %table:SB4% SB4 ON
		SB4.B4_FILIAL = %exp:xFilial("SB4")% AND
		SB4.B4_COD = %exp:cB4_COD% AND
		((SB4.B4_LINHA = SBV.BV_TABELA) OR (SB4.B4_COLUNA = SBV.BV_TABELA)) AND
		SB4.%notDel%
		WHERE 
		SBV.BV_FILIAL = %exp:xFilial("SBV")% AND 
		SBV.%notDel%
		
	EndSql

	(cAlias)->(DbGoTop())	
	
	While !(cAlias)->(Eof())
		If (cAlias)->BV_TABELA != cVarTab
			cVarTab := (cAlias)->BV_TABELA
		EndIf
		
		
		ny:=1
	
		ofwEAIObj:setProp("ListOfGridVariants",{})
		ofwEAIObj:getPropValue("ListOfGridVariants")[nx]:setProp("GridVariant")
		ofwEAIObj:getPropValue("ListOfGridVariants")[nx]:getPropValue("GridVariant"):setProp("VariantName",AllTrim((cAlias)->BV_DESCTAB))
		
		While (cAlias)->BV_TABELA = cVarTab
			
			ofwEAIObj:getPropValue("ListOfGridVariants")[nx]:getPropValue("GridVariant"):setProp("ListOfVariantValues",{})

			ofwEAIObj:getPropValue("ListOfGridVariants")[nx]:getPropValue("GridVariant"):getPropValue("ListOfVariantValues")[ny]:setProp("VariantValue",AllTrim((cAlias)->BV_DESCRI))
			ny++			
			(cAlias)->(DbSkip())	
		EndDo
		nx++
	EndDo
	

	If ExistBlock("MT550EAI")
		cJson := ofwEAIObj:getJSON()
		cJson := ExecBlock("MT550EAI",.F.,.F.,{"Json",cJson })
		If !Empty(cJson)
			ofwEAIObj:loadJson(cJson)
		Endif
	EndIf

EndIf
     

RestArea(aArea)

Return {lRet,ofwEAIObj}
