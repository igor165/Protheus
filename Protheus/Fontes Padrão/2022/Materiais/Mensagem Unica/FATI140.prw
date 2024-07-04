#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 	//Include para rotinas com MVC
#Include 'FATI140.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FATI140
Função para processamento de mensagem única do cadastro de categoria
Uso: FATA140

@sample 	FAT140( cXML, nTypeTrans, cTypeMessage)
@param xEnt, caracter/Object, Variavel com conteudo xml/obj para envio/recebimento.
@param nTypeTrans, numeric, Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage, caracter, Tipo de mensagem. (Business Type, WhoIs, etc)
@param cVersion, caracter, Versão da Mensagem Única TOTVS
@param cTransac, caracter, Nome da mensagem iniciada no adapter
@param lEAIObj, Logical Recebe XML ou Objeto EAI
@return	aRet - Array contendo o resultado da execução e o xml de retorno.
			aRet[1] - (boolean) Indica o resultado da execução da função.
			aRet[2] - (caracter/Objeto) Mensagem para envio
@author	Fábio S. dos Santos
@since		08/01/2018
@version	P12.1.17
/*/
//-------------------------------------------------------------------
Function FATI140( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Local lRet 			:= .T.				//Indica o resultado da execução da função
Local cXMLRet		:= ''				//Xml que será enviado pela função
Local cError		:= ''				//Mensagem de erro do parse no xml recebido como parâmetro
Local cWarning		:= ''				//Mensagem de alerta do parse no xml recebido como parâmetro
Local nI			:= 0				//Contador de uso geral	
Local oXML 			:= Nil				//Objeto com o conteúdo do arquivo Xml 
Local aRet			:= {.T.,"", "COMMERCIALFAMILY"} 		//Array de retorno da execucao


Default xEnt 		:= ""
Default nTypeTrans 	:= ""
Default cTypeMessage:= ""
Default cVersion 	:= ""
Default cTransac 	:= ""
Default lEAIObj 	:= .F.



If ( nTypeTrans == TRANS_RECEIVE )

	If ( cTypeMessage == EAI_MESSAGE_BUSINESS ) .Or. ( cTypeMessage == EAI_MESSAGE_RESPONSE )
	
		aRet := ValidVer(xEnt, lEAIObj, @oXML)
		
		If aRet[1]
			If !lEAIObj
				aRet := v2000(xEnt, nTypeTrans, cTypeMessage, oXML)
			Else
				aRet := v2000_O(xEnt, nTypeTrans, cTypeMessage )
			EndIf
		EndIf
		aRet := { aRet[1], aRet[2], "COMMERCIALFAMILY"}
	
	//Recebimento da WhoIs 
	ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )	
		cXMLRet := "2.000"
		aRet := { lRet , cXMLRet , "COMMERCIALFAMILY" }
		If lEAIObj		
			aSize(aRet, 4)
			aRet[4] := "JSON"
		EndIf
	EndIf								

//Trata o envio de mensagem                                    	
ElseIf ( nTypeTrans == TRANS_SEND )
	
	cVersao := StrTokArr(RTrim(PmsMsgUVer('COMMERCIALFAMILY','FATA140')), ".")[1]
		
    //Faz chamada da versão especifica   
   	If cVersao == "2"
   		If !lEAIObj
        	aRet := v2000(xEnt, nTypeTrans, cTypeMessage, oXML)
        Else
        	aRet := v2000_O(xEnt, nTypeTrans, cTypeMessage)
        EndIf
    Else
        lRet    := .F.
        cXmlRet := STR0011 //"A versão da mensagem não foi informada ou não foi implementada!" 
        aRet := { lRet , cXMLRet }
    EndIf

	aRet := { aRet[1], aRet[2], "COMMERCIALFAMILY"}
EndIf

If !lEAIObj	.AND. ValType(oXML) == "O"
	FreeObj(oXML)
EndIf


Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} V2000
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de categoria utilizando o conceito de mensagem unica.
@type function
@param Caracter/Objeto,xoEntr, Variavel com conteudo Xml ou objeto EAI
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
Static Function v2000(cXml, nTypeTrans, cTypeMessage, oXml)
Local aArea			:= GetArea()		//Salva contexto do alias atual  
Local aSaveLine		:= FWSaveRows()		//Salva contexto do model ativo
Local aRet 			:= {}				//Array de retorno da função
Local lRet 			:= .T.				//Indica o resultado da execução da função
Local oModel		:= Nil 				//Objeto com o model da categoria
Local oModelACU		:= Nil				//Objeto com o model da master apenas 
Local cVersao		:=	""				//Indica a versao da mensagem  
Local cEvent		:= 'upsert'			//Operação realizada na master e na detail ( upsert ou delete )
Local cXmlRet		:= "" 				//Texto de Retorno
Local cError		:= ""				//Mensagem de erro no parser XML
Local cWarning		:= ""       		//Mensagem de alerta no parser XML
Local nI			:= 0				//Contador
Local cValExt		:= ""			//Valor Externo  da Categoria
Local cValInt		:= ""			//Valor Interno da Categoria
Local cMarca		:= ""			//Marca
Local lACU_DESCC 	:= ACU->(ColumnPos("ACU_DESCC"))> 0
Local lACU_SEQ 		:= ACU->(ColumnPos("ACU_SEQ")) > 0


Default cXml 		:= ""
Default nTypeTrans 	:=  ""
Default cTypeMessage:= ""
Default oXml 		:= ""

// Trata o recebimento de mensagem 
If ( nTypeTrans == TRANS_RECEIVE )
	
	// Recebimento da Business Message
	If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
	
		lRet    := .F.
		cXmlRet := STR0004 //"Esta operação não é suportada por esta integração."
		aRet := { lRet , cXMLRet }	

	//Recebimento da Response Message 
	ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )
		
		//Gravacao do De/Para Codigo Interno X Codigo Externo  
		oXml := XmlParser(cXML, "_", @cError, @cWarning)
		
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
					If (!CFGA070Mnt(cMarca, "ACU", "ACU_COD", cValExt, cValInt),(lRet := .F.,cXmlRet := STR0006),)//"Não foi possível gravar na tabela De/Para."
				Else
					cXmlRet := STR0008 //"Valor Interno ou Externo em branco, não será possível gravar na tabela De/Para."
					lRet := .F.
				EndIf
			Else //Erro
				If oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message <> Nil
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
			EndIf
	   	EndIf	
	EndIf
// Trata o envio de mensagem             
ElseIf ( nTypeTrans == TRANS_SEND )
	oModel 		:= FWModelActive()					//Instancia objeto com o model completo da tabela de preços
	oModelACU	:= oModel:GetModel( 'ACUMASTER' )	//Instancia objeto com model da master apenas

	//Verifica se a tabela está sendo excluída
	IIF( ( oModel:GetOperation() == MODEL_OPERATION_DELETE ),cEvent := 'delete',)
	
	//Monta Business Event
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>CommercialFamily</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalID">' + IntCatExt(, , RTrim(oModelACU:GetValue('ACU_COD')))[2] + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	//Monta a msg do cadastro de categoria
	cXMLRet += '<BusinessContent>'
	
	cXMLRet +=		'<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLRet +=		'<BranchId>' + cFilAnt + '</BranchId>'
	cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
	cXMLRet +=		'<Code>' + oModelACU:GetValue('ACU_COD') + '</Code>'
	cXMLRet +=		'<InternalId>' + IntCatExt(, , RTrim(oModelACU:GetValue('ACU_COD')))[2] + '</InternalId>'
	cXMLRet +=		'<Description>' + _NoTags(AllTrim(oModelACU:GetValue('ACU_DESC'))) + '</Description>'
	cXMLRet +=		'<UnitOfMeasureCode/>' 
	cXMLRet +=		'<SuperiorCode>' + AllTrim(oModelACU:GetValue('ACU_CODPAI')) + '</SuperiorCode>'


	If lACU_DESCC
		cXMLRet +=		'<CompleteDescription>' + _NoTags(oModelACU:GetValue('ACU_DESCC')) + '</CompleteDescription>'
	EndIf
	If lACU_SEQ
		cXMLRet +=		'<SortOrder>' + AllTrim(Str(oModelACU:GetValue('ACU_SEQ'))) + '</SortOrder>' 
	EndIf
	cXMLRet +=		'<Situation>' +  oModelACU:GetValue('ACU_MSBLQL') + '</Situation>'
	
	If !Empty(oModelACU:GetValue('ACU_ECFLAG'))
		cXMLRet +=		'<HideSection>' + oModelACU:GetValue('ACU_ECFLAG')  + '</HideSection>'
	EndIf	

	cXMLRet += '</BusinessContent>'	
			
EndIf
//Restaura ambiente
FWRestRows( aSaveLine )     
RestArea(aArea)

aSaveLine := {}
aArea := {}

Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCatExt
Monta o InternalID da categoria de acordo com o código passado no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cLocalEst  Código da Categoria
@param   cVersao    Versão da mensagem única (Default 1.000)

@author  Fábio S. dos Santos
@version P12.1.17
@since   08/01/2017
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntCatExt(,,'01') irá retornar {.T.,'01|01|01'}
/*/
//-------------------------------------------------------------------
Static Function IntCatExt(cEmpresa, cFil, cCodCat, cVersao)
Local aResult		:= {}

Default cEmpresa	:= cEmpAnt
Default cFil		:= xFilial('ACU')
Default cCodCat		:= ""
Default cVersao		:= '2.000'

aAdd(aResult, .F.)
aAdd(aResult, STR0005 + Chr(10) + STR0001 + " " + STR0002) //"Versão não suportada."#"As versões suportadas são:" "STR0002" "1.000|2.000"

If cVersao == '2.000'
	aResult := {}
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cCodCat))
Endif
	   
Return aResult


//-------------------------------------------------------------------
//{Protheus.doc} V2000_O//Json
//-------------------------------------------------------------------
/*/{Protheus.doc} V2000_O
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de categoria utilizando o conceito de mensagem unica.
@type function
@param Caracter/Objeto,xoEntr, Variavel com conteudo Xml ou objeto EAI
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@author fabio.santos
@version P12
@since 14/03/2018
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (Objeto) Objeto EAI
/*/
//-------------------------------------------------------------------
Static Function v2000_O(oEntr, nTypeTrans, cTypeMessage)
Local aArea		:= GetArea()		//Salva contexto do alias atual  
Local aSaveLine	:= FWSaveRows()		//Salva contexto do model ativo
Local aRet 		:= {}				//Array de retorno da função
Local lRet 		:= .T.				//Indica o resultado da execução da função
Local oModel	:= Nil 				//Objeto com o model da categoria
Local oModelACU	:= Nil				//Objeto com o model da master apenas 
Local cVersao	:=	""				//Indica a versao da mensagem  
Local cEvent	:= 'upsert'			//Operação realizada na master e na detail ( upsert ou delete )
Local cRet		:= "" 				//Retorno da Rotina
Local ofwEAIObj     := FWEAIobj():NEW()	//Objeto EAI
Local cCode			:= ""			//Codigo da Categoria
local cValExt 		:= ""			//Valor externo de-para
local cValInt 		:= ""			//Valor interno de-para
Local cMarca		:= ""			//Marca
Local lACU_DESCC 	:= ACU->(ColumnPos("ACU_DESCC"))> 0
Local lACU_SEQ 		:= ACU->(ColumnPos("ACU_SEQ")) > 0
Local cStatus		:= "" 


Default oEntr		:= Nil
Default nTypeTrans 	:= ""
Default cTypeMessage:= ""

If ( nTypeTrans == TRANS_RECEIVE )				// Trata o recebimento de mensagem


	If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
	
		lRet    := .F.
		cRet := STR0004 //"Esta operação não é suportada por esta integração."
		
		ofwEAIObj:Activate()
		ofwEAIObj:SetProp("ReturnContent")
		ofwEAIObj:GetPropValue("ReturnContent"):SetProp("ERROR", cRet)

	ElseIf (cTypeMessage == EAI_MESSAGE_RESPONSE) 

		If  !Empty(oEntr)  .And. ;
			oEntr:getPropValue("ProcessingInformation") <> Nil .And. ;
			( cStatus := oEntr:getPropValue("ProcessingInformation"):getPropValue("Status") ) <> Nil  
			
			If Upper(RTrim(cStatus) ) == "OK"
				If (cMarca := oEntr:getHeaderValue("ProductName")) = Nil
					cMarca := ""
					lRet := .F.
				Else
		
					If ( cValInt :=  oEntr:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")) = Nil
						cValInt := ""
						lRet := .F.
					Else
			
						If (cValExt := oEntr:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") ) = Nil
							cValExt := ""
							lRet := .F.
						Endif
					EndIf
				EndIf
		
				lRet := lRet .And. Valtype(cMarca) == "C" .And. Valtype(cValInt) = "C" .And. Valtype(cValExt) <> "O"
				If lRet
					//Gravando o de/para quando recebe o resultado
					//deve ser verificada as informações passadas aqui
					
					lRet := CFGA070Mnt(cMarca,"ACU","ACU_COD",cValExt,cValInt)					
					If  !lRet
						cRet := STR0006 //"Não foi possível gravar na tabela De/Para."
					EndIf
				Else
					lRet    := .F. 
					cRet := STR0008 //"Valor Interno ou Externo em branco, não será possível gravar na tabela De/Para."
				Endif
			Else
				lRet := .F. 
				cRet := STR0013 + cStatus //"Mensagem de resposta retornou status: "
			EndIf
		Else
			lRet := .F. 
			cRet := STR0014
		EndIf
		
		If !lRet
			ofwEAIObj:Activate()
			ofwEAIObj:SetProp("ReturnContent")
			ofwEAIObj:GetPropValue("ReturnContent"):SetProp("ERROR", cRet)
		EndIf
		
	EndIf

ElseIf ( nTypeTrans == TRANS_SEND )				// Trata o envio de mensagem 
	oModel 		:= FWModelActive()					
	oModelACU	:= oModel:GetModel( 'ACUMASTER' )	

	If ( oModel:GetOperation() == MODEL_OPERATION_DELETE ) // Verifica se a tabela está sendo excluída
		cEvent := 'delete'
	EndIf

	ofwEAIObj:Activate()

	ofwEAIObj:SetEvent(cEvent)
	cCode := oModelACU:GetValue('ACU_COD')

	ofwEAIObj:SetProp("InternalID"       	, IntCatExt(,,cCode)[2]  )
	ofwEAIObj:SetProp("BranchId"         	,cFilAnt)
	ofwEAIObj:SetProp("CompanyInternalID"	,cEmpAnt + '|' + cFilAnt )
	ofwEAIObj:SetProp("Code"				,cCode )
	ofwEAIObj:SetProp("Description"			,_NoTags(AllTrim(oModelACU:GetValue('ACU_DESC'))) )
	ofwEAIObj:SetProp("SuperiorCode"		,AllTrim(oModelACU:GetValue('ACU_CODPAI'))  )
	ofwEAIObj:SetProp("Situation"			,oModelACU:GetValue('ACU_MSBLQL') )
	If lACU_DESCC
		ofwEAIObj:setProp("CompleteDescription"			, _NoTags(oModelACU:GetValue('ACU_DESCC'))       )
	EndIf
	If lACU_SEQ
		ofwEAIObj:setProp("SortOrder"			, oModelACU:GetValue('ACU_SEQ')       )
	EndIf
	If !Empty(oModelACU:GetValue('ACU_ECFLAG') )
		ofwEAIObj:setProp("HideSection"			, oModelACU:GetValue('ACU_ECFLAG')       )	
	EndIf
EndIf

FWRestRows( aSaveLine ) 				// Restaura ambiente     
RestArea(aArea)

aSaveLine := {}
aArea := {}

Return {lRet,ofwEAIObj}

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidVer
Funcao de validação da versão da mensagem
cadastro de categoria utilizando o conceito de mensagem unica.
@type function
@param Caracter/Objeto,xoEntr, Variavel com conteudo Xml ou objeto EAI
@param Logic, lEAIObj, Mensagem em Json ?
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author fabiana.silva
@version P12
@since 25/06/2018
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da validação da mensagem
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function ValidVer(xEnt, lEAIObj, oXML)
Local aRet 		:= {} //Retorno da Rotina
Local lRet 		:= .T. //Variavel de retorno da rotina
Local cXMLRet 	:= "" //XML de resposta
Local cVersao 	:= "" //Versao da Mensagem
Local cError 	:= ""	//Mensagem de Erro do parseamento do XML
Local cWarning 	:= ""	//Mensagem de alerta do parseamento do XML

Default xEnt 	:= ""
Default lEAIObj := .F.
Default oXML 	:= Nil

If !lEAIObj
		
	oXML := XmlParser( xEnt, '_', @cError, @cWarning )	
	
	If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )
			
		// Versão da mensagem
        If Type("oXML:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXML:_TOTVSMessage:_MessageInformation:_version:Text)
        	cVersao := StrTokArr(oXML:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
           
	    EndIf			
	Else
	    lRet := .F.
        cXmlRet := "Falha na estrutura do XML recebido"			
	EndIf
	
Else
   cVersao := StrTokArr(xEnt:getHeaderValue("Version"), ".")[1]
EndIf

If lRet
	If Empty(cVersao)
       lRet := .F.
       cXmlRet := STR0010 //"Versão da mensagem não informada!"

	ElseIf  !( AllTrim(cVersao) == "2")
		lRet    := .F.
        cXmlRet := STR0009 //"A versão da mensagem informada não foi implementada!" 				
	EndIf
	
EndIf
aRet := {lRet, cXMLRet}

Return aRet