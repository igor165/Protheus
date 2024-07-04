#Include "Average.ch"
#Include "totvs.ch"
#include "FWADAPTEREAI.CH"
#include "XMLXFUN.CH"

Function EasyMsgBusiness()
Return Nil

CLASS EasyMsgBusiness FROM EasyMessage

	//Construtor da Classe
	METHOD New(cXML, nTypeTrans, cTypeMessage) CONSTRUCTOR

	//Carrega o XML (string) da mensagem única a ser tratada
	METHOD SetXML()
	
	//Define o tipo de transação (SEND ou RECEIVE)
	METHOD SetTypeTrans(nTypeTrans)
	
	//Define o nome da Transação (Nome da Mensagem Única)
	METHOD SetTransaction()
	
	//Define o tipo da mensagem única (Business Message, Response Message)
	METHOD SetTypeMessage(cTypeMessage)
	
	//Define a operação de Transação (INCLUIR/ALTERAR/EXCLUIR)
	METHOD SetOperation()
	
	//Define o Tipo de Operação de Mensagem única (Upsert/Delete)
	METHOD SetBsnEvent()
	METHOD GetBsnEvent()
	
	//Retorna o conteudo da Mensagem
	METHOD GetMsgContent()
	
	//Retorna informações da Mensagem
	METHOD GetMsgInfo()
	//METHOD HasUniqueKey()

	Method GetEvtContent() 
	Method GetRetContent()
	Method GetBsnContent()
	Method GetReqContent()

    Method isErrorMessage()
    Method getProcErrors()
    
	Data oXML
	Data oXMLMessage
	Data cBSNEvent
	
EndClass

METHOD New(cXML, nTypeTrans, cTypeMessage) CLASS EasyMsgBusiness
_Super:New()

	Self:xMessage := cXML
	Self:SetTypeTrans(nTypeTrans)
	Self:SetTypeMessage(cTypeMessage)
	
	If Self:IsReceive() .And. !Self:IsWhois()
		If Self:SetXML()
		   Self:SetTransaction()
		   Self:SetBsnEvent()
		EndIf
		
		If Self:IsResponse() .AND. Self:isErrorMessage()
		   Self:getProcErrors()
		EndIf
	EndIf

Return Self

Method isErrorMessage() Class EasyMsgBusiness
Return Upper("<Status>error</Status>") $ Upper(Self:xMessage )

Method getProcErrors() Class EasyMsgBusiness
Local oProcInfo := Self:oXML:_TOTVSMESSAGE:_RESPONSEMESSAGE:_ProcessingInformation
Local i

if IsCpoInXML(oProcInfo, "_ListOfMessages")
    If ValType(oProcInfo:_ListOfMessages:_Message) == "A"
       aMessages := oProcInfo:_ListOfMessages:_Message
    Else
       aMessages := {oProcInfo:_ListOfMessages:_Message} 
    EndIf 
    
    For i := 1 To Len(aMessages)
       Self:Error(aMessages[i]:Text)
    Next i
Else
    Self:Error("Erro não especificado pelo sistema externo.")
EndIf

Return Nil

*-------------------------------*
METHOD SetXML() CLASS EasyMsgBusiness 
*-------------------------------*
Local lRet
Local oXML, oXMLMessage
Local cError := "", cWarning := ""

	oXML := XmlParser(Self:xMessage, "_", @cError, @cWarning)
	
	If !(lRet := ValType(oXML) == "O")
	    Self:Error("Problema ao interpretar mensagem XML recebida: "+cError)
	Else
		Self:oXML := oXML
	EndIf
	
	If !(lRet := !Empty(Self:xMessage))
	   Self:Error("Problema ao interpretar mensagem XML recebida: Mensagem Vazia.")
	ElseIf !(lRet := ( VALTYPE(Self:oXML) == "O" .and. ValType(XmlChildEx(Self:oXML, "_TOTVSMESSAGE")) <> "U"))
	   Self:Error("Problema ao interpretar mensagem XML recebida: Mensagem não está no formato TOTVSMessage.")
	EndIf
	
    If lRet .AND. Self:IsResponse()
	
	  If !(lRet := ValType(XmlChildEx(Self:oXML:_TOTVSMESSAGE, "_RESPONSEMESSAGE")) <> "U")
	    Self:Error("Problema ao interpretar mensagem XML de resposta recebida: Mensagem não possui a tag ResponseMessage.")
	  ElseIf !(lRet := ValType(XmlChildEx(Self:oXML:_TOTVSMESSAGE:_RESPONSEMESSAGE, "_RECEIVEDMESSAGE")) <> "U")
	    Self:Error("Problema ao interpretar mensagem XML de resposta recebida: Mensagem não possui a tag ReceivedMessage.")
	  ElseIf !(lRet := ValType(XmlChildEx(Self:oXML:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RECEIVEDMESSAGE, "_MESSAGECONTENT")) <> "U")
	    Self:Error("Problema ao interpretar mensagem XML de resposta recebida: Mensagem não possui a tag MessageContent.")
	  ElseIf !(lRet := ValType(Self:oXML:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RECEIVEDMESSAGE:_MESSAGECONTENT:Text) == 'C')
	    Self:Error("Problema ao interpretar mensagem XML de resposta recebida: Mensagem não possui a tag CDATA com a mensagem original enviada na forma literal.")
	  Else
        cXMLMsg := Self:oXML:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RECEIVEDMESSAGE:_MESSAGECONTENT:Text
        //AAF 19/08/2014 - Tratar respostas com caracteres especiais UTF8. Como o primeiro parser ja converteu para ansi, é necessário voltar para UTF8 para fazer o segundo parser.
        cXMLMsg := EncodeUTF8(cXMLMsg)//cXMLMsg := SubStr(cXMLMsg,At("<TOTVSMessage>",cXMLMsg))
      
        oXMLMessage := XmlParser(AllTrim(cXMLMsg), "_", @cError, @cWarning)
      	  
   	    If !(lRet := ValType(oXMLMessage) == "O")
	       Self:Error("Problema ao interpretar mensagem de negócio do XML recebido: "+cError)
        Else
	       Self:oXMLMessage := oXMLMessage
	    EndIf
	  EndIf
	  
    EndIf
	
Return lRet

*-----------------------------------------------*
METHOD SetTypeTrans(nTypeTrans) CLASS EasyMsgBusiness 
*-----------------------------------------------*

	If ValType(nTypeTrans) == ValType(TRANS_RECEIVE)
		If nTypeTrans == TRANS_RECEIVE
			Self:cTypeTrans := "RECEIVE"
		ElseIf nTypeTrans == TRANS_SEND
      		Self:cTypeTrans := "SEND"
		Else
			Self:Error("Método SetTypeTrans: Tipo de Transação Inválido.")
		EndIf
	Else
		Self:Error("Método SetTypeTrans: Tipo de Transação Inválido.")	
	EndIf

Return Nil

METHOD SetTransaction() CLASS EasyMsgBusiness

	Self:cTransaction := Self:oXML:_TOTVSMessage:_MessageInformation:_Transaction:TEXT

Return Nil

*-----------------------------------------------*
METHOD SetTypeMessage(cTypeMessage) CLASS EasyMsgBusiness
*-----------------------------------------------*

	If ValType(cTypeMessage) == "C"
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			Self:cTypeMessage := "MESSAGE"
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			Self:cTypeMessage := "RESPONSE"
		ElseIf cTypeMessage == "23"//EAI_WHOIS_MESSAGE
		    Self:cTypeMessage := "WHOIS"
		Else
			//Error
		EndIf
	Else
		//Error
	EndIf

Return Nil

*----------------------------------------*
METHOD SetOperation() Class EasyMsgBusiness
*----------------------------------------*
Local cEvent := Self:GetBsnEvent()
Local nParamPos := Self:GetExecParam("NOPC")

   If !Empty(nParamPos)
      Self:nOperation := nParamPos   
   Else
      Do Case
         Case "UPSERT" $ UPPER(cEvent)
            If Self:HasUniqueKey()
			   Self:nOperation := 4
			Else
			   Self:nOperation := 3
			EndIf
      
	     Case "DELETE" $ UPPER(cEvent)
			Self:nOperation := 5
						
	EndCase
EndIf

Return   

METHOD SetBsnEvent() Class EasyMsgBusiness

	If Self:IsMessage()
	   If IsCpoInXML(Self:oXML:_TOTVSMessage:_BusinessMessage,"_BusinessEvent")
	      Self:cBSNEvent := Self:oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text
	   Else
	      Self:cBSNEvent := "REQUEST"
	   EndIf
	ElseIf Self:IsResponse()
	   If IsCpoInXML(Self:oXMLMessage:_TOTVSMessage:_BusinessMessage,"_BusinessEvent")
		  Self:cBSNEvent := Self:oXMLMessage:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSEVENT:_EVENT:TEXT
	   Else
	      Self:cBSNEvent := "REQUEST"
	   EndIf
	EndIf

Return Nil

METHOD GetBsnEvent() Class EasyMsgBusiness
Return Self:cBsnEvent

Method GetBsnContent() Class EasyMsgBusiness
Local oRet

         If Self:GetTypeMessage() == "MESSAGE"
            oRet := Self:oXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT
         ElseIf Self:GetTypeMessage() == "RESPONSE"
            oRet := Self:oXMLMessage:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT
         ElseIf Self:GetTypeMessage() == "WHOIS"
            //
         EndIf

Return oRet

Method GetRetContent() Class EasyMsgBusiness

Local oRet

         If Self:GetTypeMessage() == "MESSAGE"
            //
         ElseIf Self:GetTypeMessage() == "RESPONSE"
            oRet := Self:oXML:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT
         ElseIf Self:GetTypeMessage() == "WHOIS"
            //
         EndIf

Return oRet

Method GetEvtContent() Class EasyMsgBusiness
Local oRet

	If Self:IsMessage()
	   oRet := Self:oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
	ElseIf Self:IsResponse()
	   oRet := Self:oXMLMessage:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSEVENT
	EndIf

Return oRet  

Method GetReqContent() Class EasyMsgBusiness
Local oRet

	If Self:IsMessage()
	   oRet := Self:oXML:_TOTVSMessage:_BusinessMessage:_BusinessRequest
	ElseIf Self:IsResponse()
	   oRet := Self:oXMLMessage:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSREQUEST
	EndIf

Return oRet



*-------------------------------------------*
METHOD GetMsgContent() Class EasyMsgBusiness
*-------------------------------------------*
Local oRet := NIL
   If Self:oXML <> NIL
      IF Self:IsReceive()
         If Self:GetTypeMessage() == "MESSAGE"
            oRet := Self:oXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT
         ElseIf Self:GetTypeMessage() == "RESPONSE"
            oRet := Self:oXML:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT
         ElseIf Self:GetTypeMessage() == "WHOIS"
            //
         EndIf
      EndIf 
   EndIf   
Return oRet 

*-------------------------------------------*
METHOD GetMsgInfo() Class EasyMsgBusiness
*-------------------------------------------*
Local oRet := NIL
   If Self:oXML <> NIL
      oRet := Self:oXML:_TOTVSMESSAGE:_MESSAGEINFORMATION
   EndIf   
Return oRet 
