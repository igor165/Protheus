Function EECAT141()
Return

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: 
* Data: 01/12/2011 - 15:12 hs 
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("SYE")
	oEasyIntEAI:SetModule("EEC",29)

	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AT141ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
    //oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AT141ARESR") //RESPOSTA SOBRE O ENVIO DA BUSINESS  (->Response)	

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()


Function AT141ASENB(oEasyMessage) 
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oEvent    := ENode():New()
Local oRec      := ENode():New()
Local oPeriod   := ENode():New() 
Local oListOfQuotation := ENode():New()
Local oQuotation
Local sData
Local oIdent    := ENode():New()
Local oKeyNode
   
   sData := DtoS(SYE->YE_DATA) // 20100130
   cAno := SubStr(sData,1,4)
   cMes := SubStr(sData,5,2)
   cDia := SubStr(sData,7,2)

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","CurrencyCode"))
   oKeyNode:SetField(ETag():New("" ,SYF->YF_CODFERP))
   oIdent:SetField(ETag():New("key",oKeyNode))
   
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Year"))
   oKeyNode:SetField(ETag():New("" ,cAno))
   oIdent:SetField(ETag():New("key",oKeyNode))
 
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","Month"))
   oKeyNode:SetField(ETag():New("" ,cMes))
   oIdent:SetField(ETag():New("key",oKeyNode))

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name",'Day'))
   oKeyNode:SetField(ETag():New("" ,cDia))
   oIdent:SetField(ETag():New("key",oKeyNode))

   oEvent:SetField("Entity", "EECAT141")
    
   If Type("nEAIEvent") <> "U"  
      If nEAIEvent == 3
         oEvent:SetField("Event" ,"upsert" )
      ElseIf nEAIEvent == 5
         oEvent:SetField("Event" ,"delete" )
      EndIf
   Else
      oEvent:SetField("Event" , "error")
   EndIf
   oEvent:SetField("Identification",oIdent)

   oBusiness:SetField("CurrencyCode",SYF->YF_CODFERP)
   oPeriod:SetField("Year",cAno)
   oPeriod:SetField("Month",cMes)
   oBusiness:SetField("Period",oPeriod)

   oListOfQuotation := ENode():New()
      oQuotation := ENode():New()
      oQuotation:SetField('Day'  ,cDia)
      oQuotation:SetField('Value',SYE->YE_VLFISCA)
      oListOfQuotation:SetField("Quotation",oQuotation)      
   oBusiness:SetField("ListOfQuotation",oListOfQuotation)
  
   oRec:SetField('BusinessEvent',oEvent)
   oRec:SetField('BusinessContent',oBusiness) 
   oXml:AddRec(oRec)

Return oXml

//Function AT141ARESR(oEasyMessage) 
//Return oEasyMessage