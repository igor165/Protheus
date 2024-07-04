#INCLUDE "Protheus.ch"
#INCLUDE "EXCHANGE_MANUAL.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "XMLXFUN.CH"

#DEFINE END_BUSINESS_CONT 	1
#DEFINE END_HOME_CONT		2
#DEFINE END_OTHER_CONT		3

#DEFINE TEL_COM				1
#DEFINE TEL_RES				2
#DEFINE TEL_FAXCOM			3
#DEFINE TEL_FAXRES			4
#DEFINE TEL_CELULAR			5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEX07_Task1บ Autor ณ Vendas e CRM        บ Data ณ  01/08/09  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de envio de tarefas ao Exchange Server               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EX07_Task1(cUserExchange	, cPassExchange	, cTitulo		, cMensagem		,;
					dDataIni		, dDataFim		, cHora1		, cHora2		,;
					cStatus			, cPriority		, cPercentagem	, dDataLembrete	,;
					cHoraLembrete	)			
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/CreateItem"
	Local cURL          := ExcGetUrl(cUserExchange,cPassExchange)
	Local cIDTask       := ""
	Local cChangeKeyTask:= ""    
	Local aRetPost		:= Array(3)
	Local cDataIni		:= ""
	Local cDataFim		:= ""
	Local cSoapTag		:= ""
	
	If Empty(cURL)
		Return {.F.,STR0001,"",""} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
	EndIf
	
	cDataIni := ExLocalToUTC( dDataIni, cHora1 )
	cDataFim := ExLocalToUTC( dDataFim, cHora2 )
	
	//Formata o XML de inclusao de TAREFA                       
	cSoapSend := '<?xml version="1.0" encoding="utf-8"?>'
	cSoapSend += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"' 
	cSoapSend += '               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
	cSoapSend += '<soap:Header>'
	cSoapSend += '</soap:Header>'   
	cSoapSend += '<soap:Body>'
	cSoapSend += '<CreateItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages" MessageDisposition="SaveOnly">'
	cSoapSend += '    <Items xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">'
	cSoapSend += '        <t:Task>'
	cSoapSend += '          <t:Subject>' + _NOTags(EncodeUtf8(Alltrim(cTitulo))) + '</t:Subject>'
	cSoapSend += '          <t:Body BodyType="Text">' + _NOTags(EncodeUtf8(Alltrim(cMensagem))) + '</t:Body>'
	Do Case
		Case cPriority == "1" // Baixa	                             
			cSoapSend += '			<t:Importance>Low</t:Importance>'
		Case cPriority == "2" // M้dia
			cSoapsend += '			<t:Importance>Normal</t:Importance>'
		Case cPriority == "3" // Alta
			cSoapSend += '			<t:Importance>High</t:Importance>'
	EndCase
	If dDataLembrete >= dDataBase .And. !Empty(cHoraLembrete)
		cSoapSend += '		<t:ReminderDueBy>' + ExLocalToUTC( dDataLembrete, cHoraLembrete ) + '</t:ReminderDueBy>'
		cSoapSend += '		<t:ReminderIsSet>true</t:ReminderIsSet>'
		cSoapSend += '		<t:ReminderMinutesBeforeStart>1</t:ReminderMinutesBeforeStart>'
	EndIf
	cSoapSend += '			<t:DueDate>' + cDataFim + '</t:DueDate>'
	cSoapSend += '			<t:PercentComplete>' + cPercentagem + '</t:PercentComplete>'	
	cSoapSend += '          <t:StartDate>' + cDataIni +  '</t:StartDate>'
	Do Case
		Case cStatus == "1"	// Nใo iniciado
			cSoapSend += '			<t:Status>NotStarted</t:Status>'
		Case cStatus == "2" // Em andamento
			cSoapSend += '			<t:Status>InProgress</t:Status>'	
		Case cStatus == "3" // Completada
			cSoapSend += '			<t:Status>Completed</t:Status>'	
		Case cStatus == "4" // Suspensa
			cSoapSend += '			<t:Status>WaitingOnOthers</t:Status>'	
		Case cStatus == "5" .OR. cStatus == "9"// Encerrada
			cSoapSend += '			<t:Status>Deferred</t:Status>'	
	EndCase	
	cSoapSend += '        </t:Task>'
	cSoapSend += '    </Items>'
	cSoapSend += '</CreateItem>'
	cSoapSend += '</soap:Body>'
	cSoapSend += '</soap:Envelope>'
	
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)  
	
	If aRetPost[1]
		If SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_CREATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_CREATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_TASK:_T_ITEMID" ) != Nil
			cIDTask        	:= WSAdvValue( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_CREATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_CREATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_TASK:_T_ITEMID:_ID:TEXT" ,"string",NIL,NIL,NIL,NIL,NIL,NIL)
			cChangeKeyTask 	:= WSAdvValue( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_CREATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_CREATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_TASK:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
		Else
			aRetPost[1] := .F.
			aRetPost[2] := STR0002 + Chr(13) + Chr(10) + aRetPost[2] // "Protheus: A estrutura retornada pelo Exchange ้ diferente da estrutura esperada."
		EndIf
	EndIf
Return {aRetPost[1], aRetPost[2], cIDTask, cChangeKeyTask}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEX07_Task2บ Autor ณ Vendas e CRM       บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de exclusao de tarefas do Exchange Server            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EX07_Task2(cUserExchange,cPassExchange,cIDTarefa,cChageKey)
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/DeleteItem"
	Local cURL          := ExcGetUrl(cUserExchange,cPassExchange)
	Local aRetPost		:= Array(3)
	Local cSoapTag		:= ""
	
	//Formata o XML de exclusใo de TAREFA      
	cSoapSend += '<?xml version="1.0" encoding="utf-8"?>'
	cSoapSend += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
	cSoapSend += '               xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages"  '
	cSoapSend += '               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types" '
	cSoapSend += '               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
	cSoapSend += '   <soap:Header>'
	cSoapSend += '   </soap:Header>'   
	cSoapSend += '  <soap:Body>'
	cSoapSend += '   <m:DeleteItem DeleteType="HardDelete" ' 
	cSoapSend += '                 AffectedTaskOccurrences="AllOccurrences">'
	cSoapSend += '     <m:ItemIds xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">'
	cSoapSend += '       <t:ItemId Id="' + cIDTarefa + '" '
	cSoapSend += '             ChangeKey="' + cChageKey + '" '
	cSoapSend += '             xmlns="http://schemas.microsoft.com/exchange/services/2006/types" />'
	cSoapSend += '     </m:ItemIds>'
	cSoapSend += '   </m:DeleteItem>'
	cSoapSend += '  </soap:Body>'
	cSoapSend += '</soap:Envelope>'
	
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost :=  Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)	
Return aRetPost

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEX07_Task3บ Autor ณ Vendas e CRM       บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de alteracao de tarefas do Exchange Server           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EX07_Task3(cUserExchange	, cPassExchange	, cTitulo		, cMensagem	,;
					dDataIni		, dDataFim		, cHora1		, cHora2	,;
					cIdTarefa		, cChangeKey	, cStatus		, cPriority	,;
					cPercentagem	, dDataLembrete	, cHoraLembrete	)
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/UpdateItem"
	Local cURL          := ExcGetUrl(cUserExchange,cPassExchange)
	Local cChgKeyTask	:= ""
	Local cIDTask		:= ""
	Local aRetPost		:= Array(3)
	Local cDataIni		:= ""
	Local cdataFim		:= ""
	Local cSoapTag		:= ""
	
	cDataIni := ExLocalToUTC( dDataIni, cHora1 )
	cDataFim := ExLocalToUTC( dDataFim, cHora2 )
	
	If Empty(cURL)
		Return {.F.,STR0001,"",""} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
	EndIf
	
	//Formata o XML de alteracao de TAREFA
	cSoapSend += '<?xml version="1.0" encoding="utf-8"?>'      
	cSoapSend += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"' 
	cSoapSend += '               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
	cSoapSend += '  <soap:Header>'
	cSoapSend += '  </soap:Header>'   
	cSoapSend += '  <soap:Body>'
	cSoapSend += '<UpdateItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages"'
	cSoapSend += '            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
	cSoapSend += '            xmlns:xsd="http://www.w3.org/2001/XMLSchema" '
	cSoapSend += '            ConflictResolution="AlwaysOverwrite">'
	cSoapSend += '  <ItemChanges xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">'
	cSoapSend += '    <ItemChange xmlns="http://schemas.microsoft.com/exchange/services/2006/types">'
	cSoapSend += '      <ItemId Id="' + cIdTarefa + '" ChangeKey="' + cChangeKey + '" />'
	cSoapSend += '      <Updates>'         
	cSoapSend += '        <SetItemField>'
	cSoapSend += '          <FieldURI FieldURI="item:Subject" />'
	cSoapSend += '          <Task>'
	cSoapSend += '            <Subject>' + _NOTags(EncodeUtf8(Alltrim(cTitulo))) + '</Subject>'
	cSoapSend += '          </Task>'
	cSoapSend += '        </SetItemField>'
	cSoapSend += '        <SetItemField>'
	cSoapSend += '          <FieldURI FieldURI="item:Body" />'
	cSoapSend += '          <Task>'
	cSoapSend += '            <Body BodyType="Text">' + _NoTags(EncodeUtf8(Alltrim(cMensagem))) + '</Body>'
	cSoapSend += '          </Task>'
	cSoapSend += '        </SetItemField>'
	Do Case
		Case cPriority == "1" // Baixa	                             
			cSoapSend += '        <SetItemField>'
			cSoapSend += '          <FieldURI FieldURI="item:Importance" />'
			cSoapSend += '          <Task>'
			cSoapSend += '            <Importance>Low</Importance>'
			cSoapSend += '          </Task>'
			cSoapSend += '        </SetItemField>'	
		Case cPriority == "2" // M้dia
			cSoapSend += '        <SetItemField>'
			cSoapSend += '          <FieldURI FieldURI="item:Importance" />'
			cSoapSend += '          <Task>'
			cSoapSend += '            <Importance>Normal</Importance>'
			cSoapSend += '          </Task>'
			cSoapSend += '        </SetItemField>'		
		Case cPriority == "3" // Alta
			cSoapSend += '        <SetItemField>'
			cSoapSend += '          <FieldURI FieldURI="item:Importance" />'
			cSoapSend += '          <Task>'
			cSoapSend += '            <Importance>High</Importance>'
			cSoapSend += '          </Task>'
			cSoapSend += '        </SetItemField>'			
	EndCase
	If dDataLembrete >= dDataBase .And. IsDigit(cHoraLembrete)
		cSoapSend += '        <SetItemField>'
		cSoapSend += '          <FieldURI FieldURI="item:ReminderDueBy" />'
		cSoapSend += '          <Task>'
		cSoapSend += '            <ReminderDueBy>' + ExLocalToUTC( dDataLembrete, cHoraLembrete ) + '</ReminderDueBy>'
		cSoapSend += '          </Task>'
		cSoapSend += '        </SetItemField>'			
		cSoapSend += '        <SetItemField>'
		cSoapSend += '          <FieldURI FieldURI="item:ReminderIsSet" />'
		cSoapSend += '          <Task>'
		cSoapSend += '            <ReminderIsSet>true</ReminderIsSet>'
		cSoapSend += '          </Task>'
		cSoapSend += '        </SetItemField>'
		cSoapSend += '        <SetItemField>'
		cSoapSend += '          <FieldURI FieldURI="item:ReminderMinutesBeforeStart" />'
		cSoapSend += '          <Task>'
		cSoapSend += '            <ReminderMinutesBeforeStart>1</ReminderMinutesBeforeStart>'
		cSoapSend += '          </Task>'
		cSoapSend += '        </SetItemField>'	
	Else
		cSoapSend += '        <SetItemField>'
		cSoapSend += '          <FieldURI FieldURI="item:ReminderIsSet" />'
		cSoapSend += '          <Task>'
		cSoapSend += '            <ReminderIsSet>false</ReminderIsSet>'
		cSoapSend += '          </Task>'
		cSoapSend += '        </SetItemField>'
	EndIf
	cSoapSend += '        <SetItemField>'
	cSoapSend += '          <FieldURI FieldURI="task:DueDate" />'
	cSoapSend += '          <Task>'
	cSoapSend += '            <DueDate>' + cDataFim + '</DueDate>'
	cSoapSend += '          </Task>'
	cSoapSend += '        </SetItemField>'
	cSoapSend += '        <SetItemField>'
	cSoapSend += '          <FieldURI FieldURI="task:PercentComplete" />'
	cSoapSend += '          <Task>'
	cSoapSend += '            <PercentComplete>' + cPercentagem + '</PercentComplete>'
	cSoapSend += '          </Task>'
	cSoapSend += '        </SetItemField>'
	cSoapSend += '        <SetItemField>'   
	cSoapSend += '          <FieldURI FieldURI="task:StartDate" />'
	cSoapSend += '          <Task>'
	cSoapSend += '            <StartDate>' + cDataIni + '</StartDate>'
	cSoapSend += '          </Task>'
	cSoapSend += '        </SetItemField>'
	Do Case
		Case cStatus == "1"	// Nใo iniciado
			cSoapSend += '        <SetItemField>'   
			cSoapSend += '          <FieldURI FieldURI="task:Status" />'
			cSoapSend += '          <Task>'
			cSoapSend += '            <Status>NotStarted</Status>'
			cSoapSend += '          </Task>'
			cSoapSend += '        </SetItemField>'	
		Case cStatus == "2" // Em andamento
			cSoapSend += '        <SetItemField>'   
			cSoapSend += '          <FieldURI FieldURI="task:Status" />'
			cSoapSend += '          <Task>'
			cSoapSend += '            <Status>InProgress</Status>'
			cSoapSend += '          </Task>'
			cSoapSend += '        </SetItemField>'		
		Case cStatus == "3" // Completada
			cSoapSend += '        <SetItemField>'   
			cSoapSend += '          <FieldURI FieldURI="task:Status" />'
			cSoapSend += '          <Task>'
			cSoapSend += '            <Status>Completed</Status>'
			cSoapSend += '          </Task>'
			cSoapSend += '        </SetItemField>'			
		Case cStatus == "4" // Suspensa
			cSoapSend += '        <SetItemField>'   
			cSoapSend += '          <FieldURI FieldURI="task:Status" />'
			cSoapSend += '          <Task>'
			cSoapSend += '            <Status>WaitingOnOthers</Status>'
			cSoapSend += '          </Task>'
			cSoapSend += '        </SetItemField>'				
		Case cStatus == "5" .OR. cStatus == "9" // Encerrada
			cSoapSend += '        <SetItemField>'   
			cSoapSend += '          <FieldURI FieldURI="task:Status" />'
			cSoapSend += '          <Task>'
			cSoapSend += '            <Status>Deferred</Status>'
			cSoapSend += '          </Task>'
			cSoapSend += '        </SetItemField>'					
	EndCase	
	cSoapSend += '      </Updates>'
	cSoapSend += '    </ItemChange>'
	cSoapSend += '  </ItemChanges>'
	cSoapSend += '</UpdateItem>'
	cSoapSend += '  </soap:Body>'
	cSoapSend += '</soap:Envelope>'
	
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
	
	If aRetPost[1]
		If 	SoapGetCampo(aRetPost[3] ,cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_UPDATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_UPDATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_TASK:_T_ITEMID" ) != Nil	
			cIDTask       := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_UPDATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_UPDATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_TASK:_T_ITEMID:_ID:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
			cChgKeyTask 	:= WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_UPDATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_UPDATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_TASK:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
		Else
			aRetPost[1] := .F.
			aRetPost[2] :=STR0002 + Chr(13) + Chr(10) + aRetPost[2] // "Protheus: A estrutura retornada pelo Exchange ้ diferente da estrutura esperada."
		EndIf
	EndIf
Return {aRetPost[1],aRetPost[2],cIDTask, cChgKeyTask}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEX07_Task4บ Autor ณ Vendas e CRM       บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de consulta das TAREFAS do Exchange Server           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EX07_Task4(cUserExchange,cPassExchange)
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/FindItem"
	Local cURL          := ExcGetUrl(cUserExchange,cPassExchange)
	Local aTarefas      := {}  
	Local aRetPost		:= Array(3)
	Local aRetorno      := {}
	Local i
	Local lItemErro		:= .F.
	Local cSoapTag		:= ""

		
	If Empty(cURL)
		Return {.F.,STR0001,} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
	EndIf
	
	cSoapSend := ' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'
	cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
	cSoapSend += '   <soap:Body>'
	cSoapSend += '     <FindItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages"'
	cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types"'
	cSoapSend += '               Traversal="Shallow">'
	cSoapSend += '       <ItemShape>'
	cSoapSend += '         <t:BaseShape>IdOnly</t:BaseShape>'
	cSoapSend += '       </ItemShape>'
	cSoapSend += '       <ParentFolderIds>'
	cSoapSend += '         <t:DistinguishedFolderId Id="tasks"/>'
	cSoapSend += '       </ParentFolderIds>'
	cSoapSend += '     </FindItem>'
	cSoapSend += '   </soap:Body>'
	cSoapSend += ' </soap:Envelope>'
	
	
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
	
	If aRetPost[1]
		//Verifica se o web-service foi executado com sucesso e se existem itens no retorno
		If 	AllTrim(Upper(WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_RESPONSECODE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) )) == "NOERROR" .AND.;
			XmlChildCount(WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS","string",NIL,NIL,NIL,NIL,NIL,NIL)) > 0
			               
			If ValType( SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_TASK") ) == "O"
				XmlNode2Arr( WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_TASK","string",NIL,NIL,NIL,NIL,NIL,NIL), "_T_TASK" )
			EndIf
			
			If ValType( SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_TASK") ) == "A"
				For i := 1 To Len(WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_TASK","string",NIL,NIL,NIL,NIL,NIL,NIL))
					AAdd(aTarefas,{	AllTrim(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_TASK[" + cValtoChar(i) + "]:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) ),;
									AllTrim(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_TASK[" + cValtoChar(i) + "]:_T_ITEMID:_ID:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) ) })
				Next i
			EndIf	
			
			//Consulta os detalhes de cada tarefa
			cAction := "http://schemas.microsoft.com/exchange/services/2006/messages/GetItem"
			
			cSoapSend := ' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'
			cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
			cSoapSend += '  <soap:Header>'
			cSoapSend += '  </soap:Header>'   
			cSoapSend += '  <soap:Body>'
			cSoapSend += '    <GetItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">'
			cSoapSend += '      <ItemShape>'
			cSoapSend += '			<t:BaseShape>AllProperties</t:BaseShape>'
			cSoapSend += '			<t:BodyType>Text</t:BodyType>'			
			cSoapSend += '      </ItemShape>'
			cSoapSend += '      <ItemIds>'     
			For i := 1 To Len(aTarefas)
				cSoapSend += '        <t:ItemId Id="' + AllTrim(aTarefas[i,2]) + '"/>'
			Next i
			cSoapSend += '      </ItemIds>'
			cSoapSend += '    </GetItem>'
			cSoapSend += '  </soap:Body>'
			cSoapSend += '</soap:Envelope>'
			
			//Funcao que faz o post e formata o retorno do XML de resposta
			aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
			If aRetPost[1]
				If ValType( SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE") ) == "O"
					XmlNode2Arr( WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE","string",NIL,NIL,NIL,NIL,NIL,NIL), "_M_GETITEMRESPONSEMESSAGE" )
				EndIf
				
				If  ValType( SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE") ) == "A"				
					For i := 1 To Len(WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE","string",NIL,NIL,NIL,NIL,NIL,NIL))
						If !("NOERROR" $ Upper(AllTrim(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_RESPONSECODE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) )))
							lItemErro := .T.
							Exit
						EndIf	
						
						aAdd( aRetorno, Array(12) )
						aRetorno[Len(aRetorno)][1] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_ITEMID:_ID:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
						aRetorno[Len(aRetorno)][2] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
						aRetorno[Len(aRetorno)][3] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_SUBJECT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
						aRetorno[Len(aRetorno)][4] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_BODY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
						aRetorno[Len(aRetorno)][5] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_IMPORTANCE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)					
						If SoapGetCampo( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + AllTrim(Str(i)) + "]:_M_ITEMS:_T_TASK:_T_REMINDERDUEBY:TEXT" ) != Nil
							aRetorno[Len(aRetorno)][6] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_REMINDERDUEBY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
						EndIf
						If SoapGetCampo( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + AllTrim(Str(i)) + "]:_M_ITEMS:_T_TASK:_T_REMINDERISSET:TEXT" ) != Nil
							aRetorno[Len(aRetorno)][7] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_REMINDERISSET:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
						EndIf
						If SoapGetCampo( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + AllTrim(Str(i)) + "]:_M_ITEMS:_T_TASK:_T_REMINDERMINUTESBEFORESTART:TEXT" ) != Nil
							aRetorno[Len(aRetorno)][8] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_REMINDERMINUTESBEFORESTART:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
						EndIf
						aRetorno[Len(aRetorno)][9] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_DUEDATE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
						aRetorno[Len(aRetorno)][10] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_PERCENTCOMPLETE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
						aRetorno[Len(aRetorno)][11] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_STARTDATE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
						aRetorno[Len(aRetorno)][12] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_TASK:_T_STATUS:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
					Next i			
				EndIf
			EndIf
		EndIf
		
		If lItemErro
			aRetPost[1]	:= .F.
			aRetPost[2] := STR0003 + Chr(13) + Chr(10) + aRetPost[2] // "Protheus: Item da tarefa retornou erro."
		EndIf
	EndIf
Return {aRetPost[1], aRetPost[2], aRetorno}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEX07_Meet1บ Autor ณ Vendas e CRM       บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de inclusa de agendas/reunioes no Exchange Server    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EX07_Meet1(cUserExchange,cPassExchange,cAssunto,cMensagem,dDataIni,cHrIni,dDataFim,cHrFim,cDescLocal,;
						aEmails,cTipo,nIDAgenda,nMinReminder)
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/CreateItem"
	Local cURL          := ExcGetUrl(cUserExchange,cPassExchange)
	Local i
	Local cDtHrIni      := ""
	Local cDtHrFim      := ""
	Local aRetPost		:= Array(3)
	Local cID			:= ""
	Local cChangeKey	:= ""
	Local cSoapTag		:= ""
	
	Default nMinReminder := 0
	
	If Empty(cURL)
		Return {.F.,STR0001,"",""} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
	EndIf
	
	cDtHrIni := ExLocalToUTC( dDataIni, cHrIni + ":00" )
	cDtHrFim := ExLocalToUTC( dDataFim, cHrFim + ":00" )
	
	//Formata o XML de inclusao de CONVITE DE REUNIAO
	cSoapSend += '<?xml version="1.0" encoding="utf-8"?>'
	cSoapSend += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
	cSoapSend += '               xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages"       '
	cSoapSend += '               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types"       '
	cSoapSend += '               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
	cSoapSend += '   <soap:Header>'
	cSoapSend += '     <t:RequestServerVersion Version="Exchange2007" />'
	cSoapSend += '   </soap:Header>'
	cSoapSend += '   <soap:Body>'
	If cTipo == "R"		// Reuniใo
		cSoapSend += '      <m:CreateItem MessageDisposition="SaveOnly" SendMeetingInvitations="SendToAllAndSaveCopy">'
	Else				// Agenda
		cSoapSend += '      <m:CreateItem MessageDisposition="SaveOnly" SendMeetingInvitations="SendToNone">'
	EndIf
	cSoapSend += '         <m:Items>'
	cSoapSend += '            <t:CalendarItem>'   
	cSoapSend += '               <t:Subject>' + _NoTags(EncodeUtf8(Alltrim(cAssunto))) + '</t:Subject>'
	cSoapSend += '               <t:Body BodyType="Text">' + _NoTags(EncodeUtf8(Alltrim(cMensagem))) + '</t:Body>'
	cSoapSend += '               <t:ReminderIsSet>true</t:ReminderIsSet>'
	cSoapSend += '               <t:ReminderMinutesBeforeStart>' + cValToChar(nMinReminder) + '</t:ReminderMinutesBeforeStart>'  
	cSoapSend += '               <t:Start>' + cDtHrIni + '</t:Start>'
	cSoapSend += '               <t:End>' + cDtHrFim + '</t:End> '     
	cSoapSend += '               <t:Location>' + EncodeUtf8(Alltrim(cDescLocal)) + '</t:Location>'
	If cTipo == "R" //Reuniao	
		cSoapSend += '               <t:RequiredAttendees>' 
	
		//Adiciona os destinatarios do convite de reuniao
		For i := 1 To Len(aEmails)
			If Empty(aEmails[i])
				Loop
			EndIf
			cSoapSend += '                  <t:Attendee>'
			cSoapSend += '                     <t:Mailbox>'
			cSoapSend += '                        <t:EmailAddress>' + AllTrim(aEmails[i]) + '</t:EmailAddress>'
			cSoapSend += '                     </t:Mailbox>'
			cSoapSend += '                  </t:Attendee>'
		Next i
		cSoapSend += '               </t:RequiredAttendees>'
	EndIf
	
	cSoapSend += '            </t:CalendarItem>'
	cSoapSend += '         </m:Items>'
	cSoapSend += '      </m:CreateItem>'
	cSoapSend += '   </soap:Body>'
	cSoapSend += '</soap:Envelope>'
	      
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost :=  Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
	
	If aRetPost[1]
		If SoapGetCampo(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_CREATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_CREATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CALENDARITEM:_T_ITEMID:_ID:TEXT") != Nil
			cID := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_CREATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_CREATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CALENDARITEM:_T_ITEMID:_ID:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
			cChangeKey := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_CREATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_CREATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CALENDARITEM:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
		Else
			aRetPost[1] := .F.
			aRetPost[2] := STR0002 + Chr(13) + Chr(10) + aRetPost[2] // "Protheus: A estrutura retornada pelo Exchange ้ diferente da estrutura esperada."
		EndIf
	EndIf
Return { aRetPost[1], aRetPost[2], cID, cChangeKey }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEX07_Meet2บ Autor ณ Vendas e CRM       บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de alteracao de agendas/reunioes no Exchange Server  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EX07_Meet2(cUserExchange,cPassExchange,cAssunto,cMensagem,dDataIni,cHrIni,dDataFim,cHrFim,cDescLocal,aEmails,cTipo,cID,cChangeKey,nMinReminder)
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/UpdateItem "
	Local cURL          := ExcGetUrl(cUserExchange,cPassExchange)
	Local cDtHrIni      := ""
	Local cDtHrFim      := ""
	Local aRetPost		:= Array(3)
	Local i				:= 0
	Local cSoapTag		:= ""
	
	Default nMinReminder := 0
	
	If Empty(cURL)
		Return {.F.,STR0001,} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
	EndIf
	          
	cDtHrIni := ExLocalToUTC( dDataIni, cHrIni + ":00" )                     
	cDtHrFim := ExLocalToUTC( dDataFim, cHrFim + ":00" )                     
	
	//Formata o XML de alteracao de CONVITE DE REUNIAO
	cSoapSend += '<?xml version="1.0" encoding="utf-8"?>'
	cSoapSend += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages" '
	cSoapSend += '               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
	cSoapSend += '   <soap:Header>'
	cSoapSend += '   </soap:Header>'
	cSoapSend += '   <soap:Body>'
	If cTipo == "R"		// Reuniใo
		cSoapSend += '      <m:UpdateItem ConflictResolution="AlwaysOverwrite" SendMeetingInvitationsOrCancellations="SendToAllAndSaveCopy">'	
	Else				// Agenda
		cSoapSend += '      <m:UpdateItem ConflictResolution="AlwaysOverwrite" SendMeetingInvitationsOrCancellations="SendToNone">'	
	EndIf
	cSoapSend += '         <m:ItemChanges>'
	cSoapSend += '            <t:ItemChange>'
	cSoapSend += '               <t:ItemId Id="' + AllTrim(cID) + '" ChangeKey="' + cChangeKey + '" />'
	cSoapSend += '                  <t:Updates>'
	cSoapSend += '                     <t:SetItemField>'
	cSoapSend += '                        <t:FieldURI FieldURI="item:Subject" />'
	cSoapSend += '                        <t:CalendarItem>'
	cSoapSend += '                           <t:Subject>'+ _NoTags(EncodeUtf8(Alltrim(cAssunto))) + '</t:Subject>'
	cSoapSend += '                        </t:CalendarItem>'
	cSoapSend += '                     </t:SetItemField>' 
	cSoapSend += '                     <t:SetItemField>'
	cSoapSend += '                        <t:FieldURI FieldURI="item:ReminderMinutesBeforeStart" />'
	cSoapSend += '                        <t:CalendarItem>'
	cSoapSend += '                           <t:ReminderMinutesBeforeStart>' + cValToChar(nMinReminder) + '</t:ReminderMinutesBeforeStart>'
	cSoapSend += '                        </t:CalendarItem>'
	cSoapSend += '                     </t:SetItemField>' 	
	cSoapSend += '                     <t:SetItemField>'
	cSoapSend += '                        <t:FieldURI FieldURI="item:Body" />'
	cSoapSend += '                        <t:CalendarItem>'
	cSoapSend += '                           <t:Body BodyType="Text">'+ _NoTags(EncodeUtf8(Alltrim(cMensagem))) + '</t:Body>'
	cSoapSend += '                        </t:CalendarItem>'
	cSoapSend += '                     </t:SetItemField>'
	cSoapSend += '                     <t:SetItemField>'
	cSoapSend += '                       <t:FieldURI FieldURI="calendar:Start" />'
	cSoapSend += '                       <t:CalendarItem>'
	cSoapSend += '                         <t:Start>' + cDtHrIni + '</t:Start>'
	cSoapSend += '                       </t:CalendarItem>'
	cSoapSend += '                     </t:SetItemField>'
	cSoapSend += '                     <t:SetItemField>'
	cSoapSend += '                       <t:FieldURI FieldURI="calendar:End" />'
	cSoapSend += '                       <t:CalendarItem>'
	cSoapSend += '                         <t:End>' + cDtHrFim + '</t:End>'
	cSoapSend += '                       </t:CalendarItem>'
	cSoapSend += '                     </t:SetItemField>'
	cSoapSend += '                     <t:SetItemField>'
	cSoapSend += '                       <t:FieldURI FieldURI="calendar:Location" />'
	cSoapSend += '                       <t:CalendarItem>'
	cSoapSend += '                          <t:Location>' + _NoTags(EncodeUtf8(Alltrim(cDescLocal))) + '</t:Location>'
	cSoapSend += '                       </t:CalendarItem>'
	cSoapSend += '                     </t:SetItemField>'
	If cTipo == "R"		// Reuniใo	
		cSoapSend += '<t:SetItemField>'
		cSoapSend += '	<t:FieldURI FieldURI="calendar:RequiredAttendees" />'
		cSoapSend += '	<t:CalendarItem>'
		cSoapSend += '		<t:RequiredAttendees>'
		For i := 1 To Len(aEmails)
			If Empty(aEmails[i])
				Loop
			EndIf            
			cSoapSend += '			<t:Attendee>'
			cSoapSend += '				<t:Mailbox>'
			cSoapSend += '					<t:EmailAddress>' + AllTrim(aEmails[i]) + '</t:EmailAddress>'
			cSoapSend += '				</t:Mailbox>'
			cSoapSend += '			</t:Attendee>'
		Next i              
		cSoapSend += '		</t:RequiredAttendees>'
		cSoapSend += '	</t:CalendarItem>'
		cSoapSend += '</t:SetItemField>'
	EndIf	
	cSoapSend += '               </t:Updates>'
	cSoapSend += '            </t:ItemChange>'
	cSoapSend += '         </m:ItemChanges>'
	cSoapSend += '      </m:UpdateItem>'
	cSoapSend += '   </soap:Body>'
	cSoapSend += '</soap:Envelope>'
	
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost :=  Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
Return { aRetPost[1], aRetPost[2], aRetPost[3] }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEX07_Meet3บAutor  ณ Vendas e CRM       บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de exclusao de agendas/reunioes no Exchange Server   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EX07_Meet3(cUserExchange,cPassExchange,cID,cChangeKey)
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/DeleteItem"
	Local cURL          := ExcGetUrl(cUserExchange,cPassExchange)
	Local aRetPost		:= Array(3)
	Local cSoapTag		:= ""
	                               
	If Empty(cURL)
		Return {.F.,STR0001,} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
	EndIf
	
	//Formata o XML de alteracao de CONVITE DE REUNIAO
	cSoapSend := '<?xml version="1.0" encoding="utf-8"?>'
	cSoapSend += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
	cSoapSend += '                   xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages" '
	cSoapSend += '                   xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types" '
	cSoapSend += '                   xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
	cSoapSend += '   <soap:Header>'
	cSoapSend += '   </soap:Header>'
	cSoapSend += '   <soap:Body>'
	cSoapSend += '      <m:DeleteItem DeleteType="MoveToDeletedItems" SendMeetingCancellations="SendToAllAndSaveCopy">'
	cSoapSend += '         <m:ItemIds>'
	cSoapSend += '            <t:ItemId Id="' + AllTrim(cID) + '" ChangeKey="' + AllTrim(cChangeKey) + '" />'
	cSoapSend += '         </m:ItemIds>'
	cSoapSend += '      </m:DeleteItem>'
	cSoapSend += '   </soap:Body>'
	cSoapSend += '</soap:Envelope>'
	
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost :=  Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
Return { aRetPost[1], aRetPost[2], aRetPost[3] }   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEX07_Meet4บ Autor ณ Vendas e CRM       บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de consulta das AGENDAS do Exchange Server           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EX07_Meet4(cUserExchange,cPassExchange, dDataIni, dDataFim)
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/FindItem"
	Local cURL          := ExcGetUrl(cUserExchange,cPassExchange)
	Local aAgendas      := {}  
	Local i				:= 1
	Local aRetPost		:= Array(3)
	Local aRetorno		:= {}
	Local cSoapTag		:= ""
	
	
	dDataIni := ExLocalToUTC( dDataIni, "00:00:00" )
	dDataFim := ExLocalToUTC( dDataFim, "23:59:59" )
	
	If Empty(cURL)
		Return {.F.,STR0001,} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
	EndIf
	
	cSoapSend := ' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'
	cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
	cSoapSend += '   <soap:Body>'
	cSoapSend += '     <FindItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages"'
	cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types"'
	cSoapSend += '               Traversal="Shallow">'
	cSoapSend += '       <ItemShape>'
	cSoapSend += '         <t:BaseShape>IdOnly</t:BaseShape>'
	cSoapSend += '       </ItemShape>'
	cSoapSend += '		<CalendarView MaxEntriesReturned="9999" StartDate="' + dDataIni + '" EndDate="' + dDataFim + '"/>'
	cSoapSend += '       <ParentFolderIds>'
	cSoapSend += '         <t:DistinguishedFolderId Id="calendar"/>'
	cSoapSend += '       </ParentFolderIds>'
	cSoapSend += '     </FindItem>'
	cSoapSend += '   </soap:Body>'
	cSoapSend += ' </soap:Envelope>'
	
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
	
	If aRetPost[1]
		//Verifica se o web-service foi executado com sucesso e se existem itens no retorno
		If 	AllTrim(Upper(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_RESPONSECODE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) )) == "NOERROR" .AND.;
			XmlChildCount(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS","string",NIL,NIL,NIL,NIL,NIL,NIL)) > 0
					
			If ValType( SoapGetCamp( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CALENDARITEM" ) ) == "O"
				XmlNode2Arr( WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CALENDARITEM","string",NIL,NIL,NIL,NIL,NIL,NIL), "_T_CALENDARITEM" )
			EndIf
			
			If ValType( SoapGetCamp( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CALENDARITEM" ) ) == "A"
				For i := 1 To Len( WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CALENDARITEM","string",NIL,NIL,NIL,NIL,NIL,NIL) )
					aAdd( aAgendas,	{ ;              
										WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CALENDARITEM[" + cValtoChar(i) + "]:_T_ITEMID:_ID:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) ,;
										WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CALENDARITEM[" + cValtoChar(i) + "]:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) ;
									} )
				Next
	
				aRetPost := EX07_Meet5( cUserExchange,cPassExchange, aAgendas )
				If aRetPost[1]
					aRetorno := aRetPost[3]
				EndIf
			EndIf
		EndIf
	EndIf
Return { aRetPost[1], aRetPost[2], aRetorno }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEX07_Meet5บ Autor ณ Vendas e CRM       บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de consulta da AGENDA e suas informac๕es             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EX07_Meet5( cUserExchange,cPassExchange, aIDs )
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/FindItem"
	Local cURL          := ExcGetUrl(cUserExchange,cPassExchange)
	Local aRetPost		:= Array(3)	
	Local i				:= 1
	Local aRetorno		:= {}
	Local aEmails		:= {}
	Local nCount		:= 0
	Local cSoapTag		:= ""
		
	If Empty(cURL)
		Return {.F.,STR0001,} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
	EndIf	
	
	//Consulta os detalhes de cada agenda
	cAction := "http://schemas.microsoft.com/exchange/services/2006/messages/GetItem"		
	cSoapSend := ' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'
	cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
	cSoapSend += '  <soap:Header>'
	cSoapSend += '  </soap:Header>'   
	cSoapSend += '  <soap:Body>'
	cSoapSend += '    <GetItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">'
	cSoapSend += '      <ItemShape>'
	cSoapSend += '			<t:BaseShape>AllProperties</t:BaseShape>'
	cSoapSend += '			<t:BodyType>Text</t:BodyType>'			
	cSoapSend += '      </ItemShape>'
	cSoapSend += '      <ItemIds>'     
	For i := 1 To Len(aIDs)
		cSoapSend += '        <t:ItemId Id="' + AllTrim(aIDs[i,1]) + '"/>'
	Next i
	cSoapSend += '      </ItemIds>'
	cSoapSend += '    </GetItem>'
	cSoapSend += '  </soap:Body>'
	cSoapSend += '</soap:Envelope>'
				
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
	
	If aRetPost[1]
		If ValType( SoapGetCamp( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE") ) == "O"
			XmlNode2Arr(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE","string",NIL,NIL,NIL,NIL,NIL,NIL), "_M_GETITEMRESPONSEMESSAGE")
		EndIf
	
		If ValType( SoapGetCamp( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE") ) == "A"
			For i := 1 To Len(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE","string",NIL,NIL,NIL,NIL,NIL,NIL))
				
				If !("NOERROR" $ Upper(AllTrim(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_RESPONSECODE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) )))
					Loop
				EndIf	
				
				aAdd( aRetorno, Array(10) )				
				aRetorno[Len(aRetorno)][1] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_ITEMID:_ID:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
				aRetorno[Len(aRetorno)][2] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
				aRetorno[Len(aRetorno)][3] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_SUBJECT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
				aRetorno[Len(aRetorno)][4] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_BODY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
				aRetorno[Len(aRetorno)][5] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_START:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
				aRetorno[Len(aRetorno)][6] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_END:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
				aRetorno[Len(aRetorno)][7] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_ISMEETING:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
				If SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + AllTrim(Str(i)) + "]:_M_ITEMS:_T_CALENDARITEM:_T_LOCATION:TEXT") != Nil
					aRetorno[Len(aRetorno)][8] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_LOCATION:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
				EndIf 
				
				If ValType( SoapGetCamp( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + AllTrim(Str(i)) + "]:_M_ITEMS:_T_CALENDARITEM:_T_REQUIREDATTENDEES:_T_ATTENDEE") ) == "O"
					XmlNode2Arr(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_REQUIREDATTENDEES:_T_ATTENDEE","string",NIL,NIL,NIL,NIL,NIL,NIL), "_T_ATTENDEE")
				EndIf
				
				If ValType(SoapGetCampo( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + AllTrim(Str(i)) + "]:_M_ITEMS:_T_CALENDARITEM:_T_REQUIREDATTENDEES:_T_ATTENDEE") ) == "A"
					aEmails := {}
					For nCount := 1 To Len( WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_REQUIREDATTENDEES:_T_ATTENDEE","string",NIL,NIL,NIL,NIL,NIL,NIL) )
						aAdd( aEmails, AllTrim(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_REQUIREDATTENDEES:_T_ATTENDEE[nCount]:_T_MAILBOX:_T_EMAILADDRESS:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)) )
					Next
					aRetorno[Len(aRetorno)][9] := aEmails
				EndIf
				
				aRetorno[Len(aRetorno)][10] := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CALENDARITEM:_T_REMINDERMINUTESBEFORESTART:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
				
				
	   		Next i
		EndIf			
	EndIf
Return { aRetPost[1], aRetPost[2], aRetorno }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPost_Exchange_2007บ Autor ณ Vendas e CRM       บ Data ณ  18/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que faz o POST na URL do Exchange Webservices e retorna o XMLบฑฑ
ฑฑบ          ณcomo objeto a funcao de origem                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Post_Exchange_2007(cSoapAction,cSoapSend,cUrl,cUserExchange,cPassExchange, cSoapTag)
	Local aHeadOut 		:= {}
	Local cXMLHeadRet 	:= ""
	Local cXMLPostRet	:= ""
	Local cWarning		:= ""
	Local cError		:= ""
	Local nTimeOut		:= 30
	Local aRet			:= Array(3)
	Local cAuth		:= SuperGetMV("MV_EXGAUT",,"1")	//1 = NTLM | 2 = Basic Authentication
	
	//---------------
	// Logs
	//---------------
	Local nHandleLog		:= -1
	Local cLog			:= ""
	Local cFileLogName		:=  "LOG_EXCHANGE_" + __cUserID + ".txt"
	Local nCount 			:= 0
	Local aCallStack		:= {}
	
	
	Default cUserExchange       := ""
	Default cPassExchange       := ""
	Default cSoapTag				:= ""
	
	// Acrescenta Informa็๕es adicionais no Header da requisi็ใo
	aadd(aHeadOut,'SOAPAction: '+cSoapAction)
	aadd(aHeadOut,'Content-Type: text/xml; charset=UTF-8')
	 
	// Acrescenta o UserAgent na requisi็ใo ...
	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	
	// Configura usuแrio e senha
	If (Empty(cAuth) .OR. cAuth == '1') //1 = NTLM | 2 = Basic Authentication
		If !Empty(cUserExchange) .And. !Empty(cPassExchange)
			HttpSetPass(AllTrim(cUserExchange),AllTrim(cPassExchange))
		EndIf	
	ElseIf cAuth == '2'
		aadd(aHeadOut,'Authorization: Basic ' + Encode64(AllTrim(cUserExchange) + ':' + AllTrim(cPassExchange)) )
	EndIf
		
	//POST-HTTPS 
	If Upper( SubStr( cUrl, 1, 5) ) == "HTTPS"
		cXMLPostRet := HTTPQuote(cUrl, "POST", "", cSoapSend, nTimeOut, aHeadOut, @cXMLHeadRet)	
	Else
		cXMLPostRet := HTTPPost(cUrl, "", cSoapSend, nTimeOut, aHeadOut, @cXMLHeadRet)
	EndIf
	
	// Verifica o status da requisi็ใo http
	If HttpGetStatus() == 200
		aRet := { .T., '200 - ' + STR0006, Nil }  // "Protheus: Exchange enviou a resposta"
	ElseIf HttpGetStatus() == 401
		aRet := { .F., '401 - ' + STR0007, Nil } // "Protheus: Usuแrio e/ou senha invแlidos"
	ElseIf HttpGetStatus() == 500
		aRet := { .F., '500 - ' + STR0008 + Chr(13) + Chr(10) + STR0009 + " " + cXMLPostRet + Chr(13) + Chr(10) + STR0010 + " " + cUrl + " " + STR0011 + " " + cXMLHeadRet, Nil } // "Protheus: Nใo foi possํvel conectar no servidor exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!" "XML Reponse: " "HTTP: Endere็o: " " Mensagem: "
	Else
		aRet := { .F., STR0008 + Chr(13) + Chr(10) + STR0010 + " " + cUrl + Chr(10) + STR0011 + cXMLHeadRet, Nil } // "Protheus: Nใo foi possํvel conectar no servidor exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!" "HTTP: Endere็o: " " Mensagem: "
	EndIf
	
	If aRet[1] .And. !Empty(cXMLPostRet)
		// Efetua o parser do XML recebido para verificar se houve erros
		aRet[3] := XmlParser(cXMLPostRet, "_", @cError, @cWarning)	
	
		If !Empty(cError)
			aRet[1] := .F.
			aRet[2] := STR0008 + Chr(13) + Chr(10) + STR0012 + " " + cError + Chr(13) + Chr(10) + aRet[2] // "Protheus: Nใo foi possํvel conectar no servidor exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!" "Protheus XML Parser: "
		EndIf
	EndIf
	
	//Debug - Log
	If ExcDebug()
		If File(cFileLogName)
			nHandleLog := FOpen(cFileLogName,FO_READWRITE) //abre o arquivo
			FSeek(nHandleLog, 0, FS_END) //posiciona no final 
		Else
			nHandleLog := nLogFile := FCreate(cFileLogName)
		EndIf
		
		nCount := 0
		While !Empty(ProcName(nCount))
      		aAdd( aCallStack, {ProcName(nCount), ProcLine(nCount)}  )
      		nCount++
    	End 		
		
		cLog := Chr(13) + Chr(10) + Chr(13) + Chr(10)
		cLog += "====================================================" + Chr(13) + Chr(10) 
		cLog += "Inicio do log - " + DtoC(Date()) + " - " + Time()+ Chr(13) + Chr(10) 
		cLog += "Url: " + cUrl + Chr(13) + Chr(10) 
		cLog += "Usuario: " + cUserExchange + Chr(13) + Chr(10) 
		cLog += "Status: " + Str(HttpGetStatus()) + Chr(13) + Chr(10) 
		cLog += "XML Enviado: " + cSoapsend + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		cLog += "Head Ret: " + cXMLHeadRet + Chr(13) + Chr(10) 
		If !Empty(cXMLPostRet)
			cLog += "Post Ret: " + cXMLPostRet + Chr(13) + Chr(10)
		EndIf
		cLog += "Post Ret Erro: " + cError + Chr(13) + Chr(10)
		cLog += "Post Ret Warning: " + cWarning + Chr(13) + Chr(10)   
		cLog += "-----------------CALL STACK-----------------------" + Chr(13) + Chr(10) 
		For nCount := 1 to Len(aCallStack)
			cLog += aCallStack[nCount][1] + " (" + CValtoChar(aCallStack[nCount][2]) + ")" + Chr(13) + Chr(10) 
		Next nCount
		cLog += "--------------------------------------------------" + Chr(13) + Chr(10) 
		cLog += "Fim do log - " + DtoC(Date()) + " - " + Time()+ Chr(13) + Chr(10) 
		cLog += "====================================================" + Chr(13) + Chr(10) 
		
		FWrite(nHandleLog,cLog)
		FClose(nHandleLog)
		
	EndIf 
	
	
	//tratamento pq dependendo do namespace pode retornar as tags diferentes
	//retorno por referencia da variavel cSoapTag
	If SoapGetCampo(aRet[3],"_SOAP_ENVELOPE") != Nil
	 cSoapTag := '_SOAP'
	ElseIf SoapGetCampo(aRet[3],"_S_ENVELOPE") != Nil
	 cSoapTag := '_S'
	EndIf
	
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSoapGetCampo      บ Autor ณ Vendas e CRM       บ Data ณ  18/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pega o dado de um no especํfico no XML e converte para o formato   บฑฑ
ฑฑบ          ณdo ADVPL.                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SoapGetCampo( oXml ,cObjCpoInfo , cConvType )
	Local bOldError := Errorblock({|e| Break(e) })
	Local bEval
	Local xRetInfo
	 
	bEval := &('{ |x| x:' + cObjCpoInfo +' } ')
	 
	Begin Sequence
		xRetInfo := eval(bEval , oXml)
	Recover
		xRetInfo := NIL
	End Sequence
	
	ErrorBlock(bOldError)
	
	If cConvType != NIL .And.  xRetInfo != NIL
		xRetInfo := SoapConvType(xRetInfo,cConvType)
	Endif
Return xRetInfo
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSoapConvType      บ Autor ณ Vendas e CRM       บ Data ณ  18/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConverte formato especํfico do Exchange para o ADVPL.               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SoapConvType(cStrCpo,cTipo)
	If cTipo=="STRING"
		Return cStrCpo
	ElseIf cTipo=="INTEGER" .or. cTipo=="FLOAT"
		Return Val(cStrCpo)
	ElseIf cTipo=="DATE"
		If cStrCpo == '0001-01-01' ;  Return CToD('') ; Endif
	 	Return SToD( Left( cStrCpo, 4 ) + SubStr( cStrCpo, 6, 2) + SubStr( cStrCpo, 9, 2 ) )
	ElseIf cTipo=="BOOLEAN"
		Return Upper(cStrCpo)=="TRUE"
	ElseIf cTipo=="BASE64BINARY"
		Return Decode64(cStrCpo)
	Endif
Return
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExLocalToUTC      บ Autor ณ Vendas e CRM       บ Data ณ  18/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTransforma uma data e hora do formato local para o universal.       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExLocalToUTC( dData, cHora )	
	Local aUTC	:= {}
	Local cRet	:= ""
	Local cLocalToUTC := "LocalToUTC"
	
	If Len( cHora ) == 5
		cHora += ":00"
	EndIf
	
	aUTC := &cLocalToUTC.( DToS(dData), cHora, If(ExIsDaylightSave(),1,0) )	
	cRet := SubStr(aUTC[1], 1, 4) + "-" + SubStr(aUTC[1], 5,2) + "-" + SubStr(aUTC[1],7,2) + "T" + aUTC[2] + "Z"
Return cRet
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExUTCToLocal      บ Autor ณ Vendas e CRM       บ Data ณ  18/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTransforma uma data e hora universal para o formato local.          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExUTCToLocal( cUTC )
	Local dData	:= CTOD("//")
	Local cHora := "00:00"
	Local cUTCToLocal := "UTCToLocal"
	Local aLocal := {}
	
	
	aLocal := &cUTCToLocal.( StrTran(SubStr(cUTC,1,10),"-",""),SubStr(cUTC,12,8) )
	dData := SToD( aLocal[1])
	cHora := AtSomaHoras( aLocal[2], If(ExIsDaylightSave(),1,0))
	If cHora == "24:00"
		cHora := "00:00"
		dData += 1
	EndIf
Return { dData, cHora }
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ExIsDaylightSave บ Autor ณ Vendas e CRM       บ Data ณ  18/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se o Exchange estแ em horแrio de verใo ou nใo.              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExIsDaylightSave()
Return GetNewPar("MV_FATEXDS", .T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ArrayToStr       บ Autor ณ Vendas e CRM       บ Data ณ  14/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Converte uma array de string em uma string separada por caracter.  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ArrayToStr( aArray, cSplitter )
	Local cRet		:= ""
	Local nCount	:= 0
	
	If ValType( aArray ) == "A"	
		For nCount := 1 To Len( aArray )
			If ValType( aArray[nCount] ) == "C"
				cRet += aArray[nCount] + If(Len(aArray) == nCount, "", ";")
			EndIf
		Next
	EndIf
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ExcDebug       บ Autor ณ Vendas e CRM       บ Data ณ  14/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDetermina se o modo debug esta habilitado (para geracao de logs).  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExcDebug()
Local lRet := .F.

lRet :=  GetPvProfString("Exchange","Debug","",GetAdv97()) == '1'

Return lRet

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EX07_Cont1()
Faz a inclusใo do contato no outlook com os dados do protheus.

@return aRetPost[1] Retorno logico, se .T. o exchange conseguiu enviar a resposta. Caso .F. houve alguma falha.
@return aRetPost[2] Cont้m uma mensagem informando se obteve sucesso no envio da resposta.
@return cIDContact Id gerado para o contato no exchange.
@return cChangeKeyContact Id de aletara็ใo gerado no contato do exchange.
@return aRetorno Array que cont้m informa็๕es dos contatos no exchange.
@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------

Function EX07_Cont1(cUserExchange,cPassExchange,cNomeContato,cEmail,;
					       aEndereco, aTelefone    ,       cCargo,cTratamento, cCodContato)

Local cSoapSend 	:= ""
Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/CreateItem"
Local cURL          :=  ExcGetUrl(cUserExchange,cPassExchange)
Local cIDContact      := ""
Local cChangeKeyContact:= "" 
Local aRetPost		:= Array(3)
Local cDataIni		:= ""
Local cDataFim		:= ""
Local cSoapTag		:= ""
Local nX			:= 1
Local cTipoEnderco := ""
Local cTipoTelefone := ""

Default aEndereco := {}
Default aTelefone := {}
	
	
If Empty(cURL)
	Return {.F.,STR0001,"",""} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
EndIf

// envio
cSoapSend += ' <soap:Envelope '
cSoapSend += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
cSoapSend += ' xmlns:xsd="http://www.w3.org/2001/XMLSchema"'
cSoapSend += ' xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'
cSoapSend += ' xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
cSoapSend += '   <soap:Body>'
cSoapSend += '     <CreateItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages" >'
cSoapSend += '       <SavedItemFolderId>'
cSoapSend += '         <t:DistinguishedFolderId Id="contacts"/>'
cSoapSend += '       </SavedItemFolderId>'
cSoapSend += '       <Items>'
cSoapSend += '         <t:Contact>'
cSoapSend += '           <t:FileAs>'+cNomeContato+'</t:FileAs>'
cSoapSend += '           <t:GivenName>'+cNomeContato+'</t:GivenName>'
cSoapSend += '           <t:EmailAddresses>'
cSoapSend += '             <t:Entry Key="EmailAddress1">'+cEmail+'</t:Entry>'
cSoapSend += '           </t:EmailAddresses>

If !Empty(aEndereco)                                  '
	cSoapSend += '           <t:PhysicalAddresses>'
	
	For nX := 1 to Len(aEndereco)
	
		If aEndereco[nX,1] == "1" //END_BUSINESS_CONT
			cTipoEnderco := "Business"
		ElseIf aEndereco[nX,1] == "2" //END_HOME_CONT
			cTipoEnderco := "Home"
		EndIf
			
		cSoapSend += '             <t:Entry Key="'+cTipoEnderco+'">'
		cSoapSend += '               <t:Street>'+aEndereco[nX,2]+'</t:Street>'
		cSoapSend += '               <t:City>'+aEndereco[nX,3]+'</t:City>'
		cSoapSend += '               <t:State>'+aEndereco[nX,4]+'</t:State>'
		cSoapSend += '               <t:CountryOrRegion>'+aEndereco[nX,5]+'</t:CountryOrRegion>'
		cSoapSend += '             </t:Entry>'
				
	Next nX
	                                                     '
	cSoapSend += '           </t:PhysicalAddresses>'
EndIf

If !Empty(aTelefone)

	cSoapSend += '           <t:PhoneNumbers>
		
	For nX := 1 to Len(aTelefone)
		                                                                                         
		If aTelefone[nX,1] == "1"
			cTipoTelefone := "BusinessPhone"
		ElseIf 	aTelefone[nX,1] == "2"
			cTipoTelefone := "HomePhone"
		ElseIf 	aTelefone[nX,1] == "3"
			cTipoTelefone := "BusinessFax"
		ElseIf 	aTelefone[nX,1] == "4"
			cTipoTelefone := "HomeFax"
		ElseIf 	aTelefone[nX,1] == "5"
			cTipoTelefone := "MobilePhone"
		EndIf
		                                                                                                                                                                '
		cSoapSend += '             <t:Entry Key="'+cTipoTelefone+'">'+aTelefone[nX,2]+'</t:Entry>'                                                                                                                                                                  '

	Next
	
	cSoapSend += '           </t:PhoneNumbers>			
EndIf

cSoapSend += '           <t:JobTitle>'+cCargo+'</t:JobTitle>'
cSoapSend += '           <t:Surname>'+cTratamento+'</t:Surname>'
cSoapSend += '         </t:Contact>'
cSoapSend += '       </Items>'
cSoapSend += '     </CreateItem>'
cSoapSend += '   </soap:Body>'
cSoapSend += ' </soap:Envelope>'

// retorno

//Funcao que faz o post e formata o retorno do XML de resposta
aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)  
	
If aRetPost[1]
	If SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_CREATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_CREATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CONTACT:_T_ITEMID" ) != Nil
		cIDContact        	:= WSAdvValue( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_CREATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_CREATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CONTACT:_T_ITEMID:_ID:TEXT" ,"string",NIL,NIL,NIL,NIL,NIL,NIL)
		cChangeKeyContact 	:= WSAdvValue( aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_CREATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_CREATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CONTACT:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
	Else
		aRetPost[1] := .F.
		aRetPost[2] := STR0002 + Chr(13) + Chr(10) + aRetPost[2] // "Protheus: A estrutura retornada pelo Exchange ้ diferente da estrutura esperada."
	EndIf
EndIf

Ft321GIdCon(cIDContact, cChangeKeyContact, cCodContato)

Return {aRetPost[1], aRetPost[2], cIDContact, cChangeKeyContact} 

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EX07_Cont2()
Faz a altera็ใo do contato no outlook com os dados do protheus.

@return aRetPost[1] Retorno logico, se .T. o exchange conseguiu enviar a resposta. Caso .F. houve alguma falha.
@return aRetPost[2] Cont้m uma mensagem informando se obteve sucesso no envio da resposta.
@return cIDCont Id gerado para o contato no exchange.
@return cChgKeyCont Id de aletara็ใo gerado no contato do exchange.
@return aRetorno Array que cont้m informa็๕es dos contatos no exchange.
@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------

Function EX07_Cont2(cUserExchange	, cPassExchange	, cIDContact		, cChageKey	,;
					   cNomeContato	, cEmail		   	, aEndereco	,;
					   aTelefone		, cCargo			, cTratamento, cCodContato)
					   
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/UpdateItem"
	Local cURL          :=  ExcGetUrl(cUserExchange,cPassExchange)
	Local cChgKeyCont	:= ""
	Local cIDCont		:= ""
	Local aRetPost		:= Array(3)
	Local cDataIni		:= ""
	Local cdataFim		:= ""
	Local cSoapTag		:= ""
	Local cTipoEnderco  := ""
	Local cTipoTelefone := ""
	Local aEndDel := {"Business","Home","Other"}
	Local aTelDel := {"BusinessPhone","HomePhone","BusinessFax","HomeFax","MobilePhone"}
	Local nX

	If Empty(cURL)
		Return {.F.,STR0001,"",""} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
	EndIf
	
	cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/UpdateItem"
	        
	cSoapSend += '<?xml version="1.0" encoding="utf-8"?>'      
	cSoapSend += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"' 
	cSoapSend += '               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
	cSoapSend += '  <soap:Header>'
	cSoapSend += '  </soap:Header>'   
	cSoapSend += '  <soap:Body>'
	cSoapSend += '<UpdateItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages"'
	cSoapSend += '            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
	cSoapSend += '            xmlns:xsd="http://www.w3.org/2001/XMLSchema" '
	cSoapSend += '            ConflictResolution="AlwaysOverwrite">'
	cSoapSend += '  <ItemChanges xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">'
	cSoapSend += '    <ItemChange xmlns="http://schemas.microsoft.com/exchange/services/2006/types">'
	cSoapSend += '	          <t:ItemId Id="'+cIDContact+'" ChangeKey="'+cChageKey+'"/>'
	cSoapSend += '	          <t:Updates>'

		For nX := 1 to Len(aEndDel)
		
			cSoapSend += '	<t:DeleteItemField>'
			cSoapSend += ' 		<t:IndexedFieldURI FieldURI="contacts:PhysicalAddress:Street" FieldIndex="'+aEndDel[nX]+'"/>'
			cSoapSend += '  </t:DeleteItemField>'
			cSoapSend += '	<t:DeleteItemField>'
			cSoapSend += ' 		<t:IndexedFieldURI FieldURI="contacts:PhysicalAddress:City" FieldIndex="'+aEndDel[nX]+'"/>'
			cSoapSend += '  </t:DeleteItemField>'
			cSoapSend += '	<t:DeleteItemField>'
			cSoapSend += ' 		<t:IndexedFieldURI FieldURI="contacts:PhysicalAddress:State" FieldIndex="'+aEndDel[nX]+'"/>'
			cSoapSend += '  </t:DeleteItemField>'
			cSoapSend += '	<t:DeleteItemField>'
			cSoapSend += ' 		<t:IndexedFieldURI FieldURI="contacts:PhysicalAddress:CountryOrRegion" FieldIndex="'+aEndDel[nX]+'"/>'
			cSoapSend += '  </t:DeleteItemField>'

	    Next nX			    
				
		For nX := 1 to Len(aTelDel)
	
			cSoapSend += '	<t:DeleteItemField>'
			cSoapSend += '  	<t:IndexedFieldURI FieldURI="contacts:PhoneNumber" FieldIndex="'+aTelDel[nX]+'"/>'
			cSoapSend += '  </t:DeleteItemField>'
				
		Next nX

	cSoapSend += '            </t:Updates>'
	cSoapSend += '    </ItemChange>'
	cSoapSend += '  </ItemChanges>'
	cSoapSend += '</UpdateItem>'
	cSoapSend += '</soap:Body>'
	cSoapSend += '</soap:Envelope>'	

	aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
	cSoapSend := "" 
	
	If aRetPost[1]
		If 	SoapGetCampo(aRetPost[3] ,cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_UPDATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_UPDATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CONTACT:_T_ITEMID" ) != Nil	
			cChgKeyCont	  := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_UPDATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_UPDATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CONTACT:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
		Else
			aRetPost[1] := .F.
			aRetPost[2] :=STR0002 + Chr(13) + Chr(10) + aRetPost[2] // "Protheus: A estrutura retornada pelo Exchange ้ diferente da estrutura esperada."
		EndIf
	
		//Formata o XML de alteracao do CONTATO
		cSoapSend += '<?xml version="1.0" encoding="utf-8"?>'      
		cSoapSend += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"' 
		cSoapSend += '               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
		cSoapSend += '  <soap:Header>'
		cSoapSend += '  </soap:Header>'   
		cSoapSend += '  <soap:Body>'
		cSoapSend += '<UpdateItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages"'
		cSoapSend += '            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
		cSoapSend += '            xmlns:xsd="http://www.w3.org/2001/XMLSchema" '
		cSoapSend += '            ConflictResolution="AlwaysOverwrite">'
		cSoapSend += '  <ItemChanges xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">'
		cSoapSend += '    <ItemChange xmlns="http://schemas.microsoft.com/exchange/services/2006/types">'
		cSoapSend += '	          <t:ItemId Id="'+cIDContact+'" ChangeKey="'+cChgKeyCont+'"/>'
		cSoapSend += '	          <t:Updates>'
		cSoapSend += '	            <t:SetItemField>'
		cSoapSend += '	              <t:FieldURI FieldURI="item:Sensitivity"/>'
		cSoapSend += '	              <t:Message>'
		cSoapSend += '	                <t:Sensitivity>Normal</t:Sensitivity>'
		cSoapSend += '	              </t:Message>'
		cSoapSend += '	            </t:SetItemField>'	
		cSoapSend += '        <SetItemField>'
		cSoapSend += '          <FieldURI FieldURI="contacts:FileAs" />'
		cSoapSend += '          <Contact>'
		cSoapSend += '            <FileAs>'+cNomeContato+'</FileAs>'
		cSoapSend += '          </Contact>'
		cSoapSend += '        </SetItemField>'	
		cSoapSend += '        <SetItemField>'
		cSoapSend += '          <FieldURI FieldURI="contacts:GivenName" />'
		cSoapSend += '          <Contact>'
		cSoapSend += '            <GivenName>'+cNomeContato+'</GivenName>'
		cSoapSend += '          </Contact>'
		cSoapSend += '        </SetItemField>'
		cSoapSend += '        <t:SetItemField>'
	    cSoapSend += '          <t:IndexedFieldURI FieldURI="contacts:EmailAddress" FieldIndex="EmailAddress1"/>'
	    cSoapSend += '          <t:Contact>'
	    cSoapSend += '            <t:EmailAddresses>'
	    cSoapSend += '              <t:Entry Key="EmailAddress1">'+cEmail+'</t:Entry>'
	    cSoapSend += '            </t:EmailAddresses>'
	    cSoapSend += '          </t:Contact>'
	    cSoapSend += '        </t:SetItemField>'
	
		If !Empty(aEndereco)
	
			For nX := 1 to Len(aEndereco)
			
				If aEndereco[nX,1] == "1"
					cTipoEnderco := "Business"			
				ElseIf aEndereco[nX,1] == "2"
					cTipoEnderco := "Home"							
				ElseIf aEndereco[nX,1] == "3"
					cTipoEnderco := "Other"
				EndIf
					
			 	cSoapSend += ' <t:SetItemField>'
			    cSoapSend += ' 	<t:IndexedFieldURI FieldURI="contacts:PhysicalAddress:Street" FieldIndex="'+cTipoEnderco+'"/>'
			    cSoapSend += '    <t:Contact>'   
			    cSoapSend += '          <t:PhysicalAddresses>'   
				cSoapSend += '            <t:Entry Key="'+cTipoEnderco+'">'
				cSoapSend += '              <t:Street>'+aEndereco[nX,2]+'</t:Street>'
				cSoapSend += '            </t:Entry>'
				cSoapSend += '          </t:PhysicalAddresses>'   
				cSoapSend += '    </t:Contact>'
				cSoapSend += ' </t:SetItemField>'
				cSoapSend += ' <t:SetItemField>'
				cSoapSend += ' 	<t:IndexedFieldURI FieldURI="contacts:PhysicalAddress:City" FieldIndex="'+cTipoEnderco+'"/>'
				cSoapSend += '    <t:Contact>'   
				cSoapSend += '          <t:PhysicalAddresses>'
				cSoapSend += '            <t:Entry Key="'+cTipoEnderco+'">'
				cSoapSend += '              <t:City>'+aEndereco[nX,3]+'</t:City>'
				cSoapSend += '            </t:Entry>'
				cSoapSend += '          </t:PhysicalAddresses>'   
				cSoapSend += '    </t:Contact>'
				cSoapSend += ' </t:SetItemField>'						
				cSoapSend += ' <t:SetItemField>'
				cSoapSend += ' 	<t:IndexedFieldURI FieldURI="contacts:PhysicalAddress:State" FieldIndex="'+cTipoEnderco+'"/>'
				cSoapSend += '    <t:Contact>'   
				cSoapSend += '          <t:PhysicalAddresses>'
				cSoapSend += '            <t:Entry Key="'+cTipoEnderco+'">'
				cSoapSend += '              <t:State>'+aEndereco[nX,4]+'</t:State>'
				cSoapSend += '            </t:Entry>'
				cSoapSend += '          </t:PhysicalAddresses>'   
				cSoapSend += '    </t:Contact>'
				cSoapSend += ' </t:SetItemField>'		
				cSoapSend += ' <t:SetItemField>'
				cSoapSend += ' 	<t:IndexedFieldURI FieldURI="contacts:PhysicalAddress:CountryOrRegion" FieldIndex="'+cTipoEnderco+'"/>'
				cSoapSend += '    <t:Contact>'   
				cSoapSend += '          <t:PhysicalAddresses>'
				cSoapSend += '            <t:Entry Key="'+cTipoEnderco+'">'
				cSoapSend += '              <t:CountryOrRegion>'+aEndereco[nX,5]+'</t:CountryOrRegion>'
				cSoapSend += '            </t:Entry>'
				cSoapSend += '         </t:PhysicalAddresses>'
			    cSoapSend += '    </t:Contact>'
			    cSoapSend += ' </t:SetItemField>'    
						    
	    	Next nX
			    
	    EndIf       
	    
		If !Empty(aTelefone)
				
			For nX := 1 to Len(aTelefone)
	
				If aTelefone[nX,1] == "1"
					cTipoTelefone := "BusinessPhone"
				ElseIf 	aTelefone[nX,1] == "2"
					cTipoTelefone := "HomePhone"
				ElseIf 	aTelefone[nX,1] == "3"
					cTipoTelefone := "BusinessFax"
				ElseIf 	aTelefone[nX,1] == "4"
					cTipoTelefone := "HomeFax"
				ElseIf 	aTelefone[nX,1] == "5"
					cTipoTelefone := "MobilePhone"
				EndIf
	
				cSoapSend += ' <t:SetItemField>'
				cSoapSend += ' 	<t:IndexedFieldURI FieldURI="contacts:PhoneNumber" FieldIndex="'+cTipoTelefone+'"/>'
				cSoapSend += '    <t:Contact>'
				cSoapSend += '           <t:PhoneNumbers>'
				cSoapSend += '             <t:Entry Key="'+cTipoTelefone+'">'+aTelefone[nX,2]+'</t:Entry>'  
				cSoapSend += '           </t:PhoneNumbers>'   
				cSoapSend += '    </t:Contact>'
				cSoapSend += ' </t:SetItemField>'
				
			Next nX
			
		 EndIf
		 					
		cSoapSend += '        <SetItemField>'
		cSoapSend += '          <FieldURI FieldURI="contacts:JobTitle" />'
		cSoapSend += '          <Contact>'
		cSoapSend += '            <JobTitle>'+cCargo+'</JobTitle>'
		cSoapSend += '          </Contact>'
		cSoapSend += '        </SetItemField>'			
		cSoapSend += '        <SetItemField>'
		cSoapSend += '          <FieldURI FieldURI="contacts:Surname" />'
		cSoapSend += '          <Contact>'
		cSoapSend += '            <Surname>'+cTratamento+'</Surname>'
		cSoapSend += '          </Contact>'
		cSoapSend += '        </SetItemField>'			
		cSoapSend += '      </t:Updates>'
		cSoapSend += '    </ItemChange>'
		cSoapSend += '  </ItemChanges>'
		cSoapSend += '</UpdateItem>'
		cSoapSend += '  </soap:Body>'
		cSoapSend += '</soap:Envelope>'
	
		
		//Funcao que faz o post e formata o retorno do XML de resposta
	 	aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
		
		If aRetPost[1]
			If 	SoapGetCampo(aRetPost[3] ,cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_UPDATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_UPDATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CONTACT:_T_ITEMID" ) != Nil	
				cIDCont       := WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_UPDATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_UPDATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CONTACT:_T_ITEMID:_ID:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
				cChgKeyCont 	:= WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_UPDATEITEMRESPONSE:_M_RESPONSEMESSAGES:_M_UPDATEITEMRESPONSEMESSAGE:_M_ITEMS:_T_CONTACT:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
			Else
				aRetPost[1] := .F.
				aRetPost[2] :=STR0002 + Chr(13) + Chr(10) + aRetPost[2] // "Protheus: A estrutura retornada pelo Exchange ้ diferente da estrutura esperada."
			EndIf
		EndIf
		
	EndIf // Fecha o bloco de retorno da exclusใo. If aRetPost[1]

Ft321GIdCon(cIDCont, cChgKeyCont, cCodContato)

Return {aRetPost[1],aRetPost[2],cIDCont, cChgKeyCont}

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EX07_Cont3()
Faz a exclusใo do contato no outlook com os dados do protheus.

@return aRetPost Cont้m o retorno do XML com os contatos que estใo no exchange.
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------

Function EX07_Cont3(cUserExchange,cPassExchange,cIDContact,cChageKey)

Local cSoapSend 	:= ""
Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/DeleteItem"
Local cURL          :=  ExcGetUrl(cUserExchange,cPassExchange)
Local aRetPost		:= Array(3)
Local cSoapTag		:= ""

	cSoapSend += '<?xml version="1.0" encoding="utf-8"?>'
	cSoapSend += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
	cSoapSend += '               xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages"  '
	cSoapSend += '               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types" '
	cSoapSend += '               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
	cSoapSend += '   <soap:Header>'
	cSoapSend += '   </soap:Header>'   
	cSoapSend += '  <soap:Body>'
	cSoapSend += '   <m:DeleteItem DeleteType="HardDelete" >' 
	cSoapSend += '     <m:ItemIds xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">'
	cSoapSend += '       <t:ItemId Id="' + cIDContact + '" '
	cSoapSend += '             ChangeKey="' + cChageKey + '" '
	cSoapSend += '             xmlns="http://schemas.microsoft.com/exchange/services/2006/types" />'
	cSoapSend += '     </m:ItemIds>'
	cSoapSend += '   </m:DeleteItem>'
	cSoapSend += '  </soap:Body>'
	cSoapSend += '</soap:Envelope>'

	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost :=  Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
		
Return aRetPost

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EX07_Cont4()
Faz a consulta do contato no outlook com os dados do protheus.

@return aRetPost[1] Retorno logico, se .T. o exchange conseguiu enviar a resposta. Caso .F. houve alguma falha.
@return aRetPost[2] Cont้m uma mensagem informando se obteve sucesso no envio da resposta.
@return aRetorno Array que cont้m informa็๕es dos contatos no exchange.
@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------

Function EX07_Cont4(cUserExchange, cPassExchange)

	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/FindItem"
	Local cURL          :=  ExcGetUrl(cUserExchange,cPassExchange)
	Local aRetPost		:= Array(3)
	Local aContatos     := {}
	Local aRetorno      := {}
	Local aEndereco     := {}
	Local aEndTemp		:= {}
	Local aTelefone		:= {}
	Local aTelTemp		:= {}
	Local i
	Local nX  
	Local nY
	Local lItemErro		:= .F.
	Local cSoapTag		:= "" 
	
	If Empty(cURL)
		Return {.F.,STR0001,} // "Protheus: Parโmetro MV_URLEWS nใo configurado corretamente."
	EndIf
	
	cSoapSend := ' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'
	cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
	cSoapSend += '   <soap:Body>'
	cSoapSend += '     <FindItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages"'
	cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types"'
	cSoapSend += '               Traversal="Shallow">'
	cSoapSend += '       <ItemShape>'
	cSoapSend += '         <t:BaseShape>IdOnly</t:BaseShape>'
	cSoapSend += '       </ItemShape>'
	cSoapSend += '       <ParentFolderIds>'
	cSoapSend += '         <t:DistinguishedFolderId Id="contacts"/>'
	cSoapSend += '       </ParentFolderIds>'
	cSoapSend += '     </FindItem>'
	cSoapSend += '   </soap:Body>'
	cSoapSend += ' </soap:Envelope>'
	
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
		
	If aRetPost[1]
		//Verifica se o web-service foi executado com sucesso e se existem itens no retorno
		If 	AllTrim(Upper(WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_RESPONSECODE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) )) == "NOERROR" .AND.;
			XmlChildCount(WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS","string",NIL,NIL,NIL,NIL,NIL,NIL)) > 0
			               
			If ValType( SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CONTACT") ) == "O"
				XmlNode2Arr( WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CONTACT","string",NIL,NIL,NIL,NIL,NIL,NIL), "_T_CONTACT" )
			EndIf
			
			If ValType( SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CONTACT") ) == "A"
				For i := 1 To Len(WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CONTACT","string",NIL,NIL,NIL,NIL,NIL,NIL))
					AAdd(aContatos,{	AllTrim(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CONTACT[" + cValtoChar(i) + "]:_T_ITEMID:_CHANGEKEY:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) ),;
									AllTrim(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_ROOTFOLDER:_T_ITEMS:_T_CONTACT[" + cValtoChar(i) + "]:_T_ITEMID:_ID:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) ) })
				Next i
			EndIf	
			
			//Consulta os detalhes de cada contato
			cAction := "http://schemas.microsoft.com/exchange/services/2006/messages/GetItem"
			
			cSoapSend := ' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'
			cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
			cSoapSend += '  <soap:Header>'
			cSoapSend += '  </soap:Header>'   
			cSoapSend += '  <soap:Body>'
			cSoapSend += '    <GetItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">'
			cSoapSend += '      <ItemShape>'
			cSoapSend += '			<t:BaseShape>AllProperties</t:BaseShape>'
			cSoapSend += '			<t:BodyType>Text</t:BodyType>'			
			cSoapSend += '      </ItemShape>'
			cSoapSend += '      <ItemIds>'     
			For i := 1 To Len(aContatos)
				cSoapSend += '        <t:ItemId Id="' + AllTrim(aContatos[i,2]) + '"/>'
			Next i
			cSoapSend += '      </ItemIds>'
			cSoapSend += '    </GetItem>'
			cSoapSend += '  </soap:Body>'
			cSoapSend += '</soap:Envelope>'
			
			//Funcao que faz o post e formata o retorno do XML de resposta
			aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)
			If aRetPost[1]
				If ValType( SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE") ) == "O"
					XmlNode2Arr( WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE","string",NIL,NIL,NIL,NIL,NIL,NIL), "_M_GETITEMRESPONSEMESSAGE" )
				EndIf
				
				If  ValType( SoapGetCampo(aRetPost[3], cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE") ) == "A"				
					For i := 1 To Len(WSAdvValue(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE","string",NIL,NIL,NIL,NIL,NIL,NIL))
						If !("NOERROR" $ Upper(AllTrim(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_RESPONSECODE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) )))
							lItemErro := .T.
							Exit
						EndIf	

						aAdd( aRetorno, Array(9) )
						
					 	aRetorno[Len(aRetorno)][1] := TrataTag( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_ITEMID:_ID:TEXT")
						aRetorno[Len(aRetorno)][2] := TrataTag( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_ITEMID:_CHANGEKEY:TEXT")						
						aRetorno[Len(aRetorno)][3] := TrataTag( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_GIVENNAME:TEXT")                        
						aRetorno[Len(aRetorno)][4] := TrataTag( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_COMPANYNAME:TEXT")						
						aRetorno[Len(aRetorno)][5] := TrataTag( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_JOBTITLE:TEXT")											
						aRetorno[Len(aRetorno)][6] := TrataTag( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_SURNAME:TEXT")						
						aRetorno[Len(aRetorno)][7] := TrataTag( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_EMAILADDRESSES:_T_ENTRY:TEXT")
                     If Empty(aRetorno[Len(aRetorno)][7]) //qdo o contato vem com + de 1 email o outlook manda um array
                     	aRetorno[Len(aRetorno)][7] := TrataTag( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_EMAILADDRESSES:_T_ENTRY[1]:TEXT")
                     EndIf
                     
                     aEndereco := {}   
					    If ValType(SoapGetCampo(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_PHYSICALADDRESSES:_T_ENTRY")) == "A"
					  		aEndereco := SoapGetCampo(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_PHYSICALADDRESSES:_T_ENTRY")
						Else
							Aadd(aEndereco,SoapGetCampo(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_PHYSICALADDRESSES:_T_ENTRY")) 
						EndIf						    
					    					   
					   //Enderecos
                     aRetorno[Len(aRetorno)][8]:= {}
                    	For nX := 1 To Len(aEndereco)   
                    	
							Aadd(aRetorno[Len(aRetorno)][8], TrataTag( aEndereco[nX] ,"_KEY:TEXT"))
							Aadd(aRetorno[Len(aRetorno)][8], TrataTag( aEndereco[nX] ,"_T_CITY:TEXT"))
							Aadd(aRetorno[Len(aRetorno)][8], TrataTag( aEndereco[nX] ,"_T_COUNTRYORREGION:TEXT"))
							Aadd(aRetorno[Len(aRetorno)][8], TrataTag( aEndereco[nX] ,"_T_STATE:TEXT"))
							Aadd(aRetorno[Len(aRetorno)][8], TrataTag( aEndereco[nX] ,"_T_STREET:TEXT"))
                    	                        	              	    
 						Next nX
 
  						aTelefone := {}
				  		If ValType(SoapGetCampo(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_PHONENUMBERS:_T_ENTRY")) == "A"
					  		aTelefone := SoapGetCampo(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_PHONENUMBERS:_T_ENTRY")						
         				Else
         				    Aadd(aTelefone,SoapGetCampo(aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_GETITEMRESPONSE:_M_RESPONSEMESSAGES:_M_GETITEMRESPONSEMESSAGE[" + cValtoChar(i) + "]:_M_ITEMS:_T_CONTACT:_T_PHONENUMBERS:_T_ENTRY"))
         				EndIf
         				
					    //Telefones
					   	aRetorno[Len(aRetorno)][9]:= {}
						For nY := 1 To Len(aTelefone)
							Aadd(aRetorno[Len(aRetorno)][9], TrataTag(aTelefone[nY] ,"_KEY:TEXT"))
							Aadd(aRetorno[Len(aRetorno)][9], TrataTag(aTelefone[nY] ,"TEXT"))
							
						Next nY
							
					Next i			
				EndIf
			EndIf
		EndIf
		
		If lItemErro
			aRetPost[1]	:= .F.
			aRetPost[2] := STR0003 + Chr(13) + Chr(10) + aRetPost[2] // "Protheus: Item da tarefa retornou erro."
		EndIf
	EndIf

Return {aRetPost[1], aRetPost[2], aRetorno}   

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TrataTag()
Faz tratamento da tag XML para deixar o codigo mais limpo na fun็ใo EX07_Cont4

@return cRet Caminho na tag xml.
@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------

Function TrataTag(aXml,cNo)   

Local cRet := ""

If SoapGetCampo(aXml,cNo) != Nil
	cRet := WSAdvValue( aXml,cNo,"string",NIL,NIL,NIL,NIL,NIL,NIL)
EndIf

Return (cRet)



//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExcGetUrl()
Busca url pra conexao com exchange. Avalia se o usuแrio deve utilizar a url para conexao com exchange 2007 ou 2010

@param cUserExchange usuario para conexao com exchange
@param cPassExchange senha para conexao com exchange
@return cUrlRet url
@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------
Function ExcGetUrl(cUserExchange,cPassExchange)

Local cUrl2007 := 	GetMv("MV_EWS2007",,"")
Local cUrl2010 := 	GetMv("MV_EWS2010",,"")
Local cUrlRet := ""


If !Empty(cUrl2010) .AND. EX07_Dummy(cUrl2010, cUserExchange, cPassExchange)
	cUrlRet := cUrl2010
ElseIf !Empty(cUrl2007) .AND.  EX07_Dummy(cUrl2007, cUserExchange, cPassExchange)
	cUrlRet := cUrl2007
Else
	cUrlRet := GetMv("MV_URLEWS",,"")	
EndIf

Return cUrlRet



//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EX07_Dummy()
Tenta realizar uma conexao com uma determinada url. Apenas para validar se a conta do usuario esta na versao correta

@param cUrl url para conexao com exchange
@param cUserExchange usuario para conexao com exchange
@param cPassExchange senha para conexao com exchange
@return lRet .T. se conseguiu conectar
@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------
Function EX07_Dummy(cUrl, cUserExchange, cPassExchange)
	Local cSoapSend 	:= ""
	Local cAction       := "http://schemas.microsoft.com/exchange/services/2006/messages/FindItem"
	Local aAgendas      := {}  
	Local i				:= 1
	Local aRetPost		:= Array(3)
	Local aRetorno		:= {}
	Local cSoapTag		:= ""
	Local dDataIni		:= ExLocalToUTC( dDatabase, "00:00:00" )
	Local dDataFim		:= ExLocalToUTC( dDatabase, "23:59:59" )
	Local lRet				:= .T. //retorna se conseguiu conecta no servidor exchange informado na cURL
	
	
	cSoapSend := ' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'
	cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">'
	cSoapSend += '   <soap:Body>'
	cSoapSend += '     <FindItem xmlns="http://schemas.microsoft.com/exchange/services/2006/messages"'
	cSoapSend += '                xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types"'
	cSoapSend += '               Traversal="Shallow">'
	cSoapSend += '       <ItemShape>'
	cSoapSend += '         <t:BaseShape>IdOnly</t:BaseShape>'
	cSoapSend += '       </ItemShape>'
	cSoapSend += '		<CalendarView MaxEntriesReturned="9999" StartDate="' + dDataIni + '" EndDate="' + dDataFim + '"/>'
	cSoapSend += '       <ParentFolderIds>'
	cSoapSend += '         <t:DistinguishedFolderId Id="calendar"/>'
	cSoapSend += '       </ParentFolderIds>'
	cSoapSend += '     </FindItem>'
	cSoapSend += '   </soap:Body>'
	cSoapSend += ' </soap:Envelope>'
	
	//Funcao que faz o post e formata o retorno do XML de resposta
	aRetPost := Post_Exchange_2007(cAction,cSoapSend,cUrl,cUserExchange,cPassExchange,@cSoapTag)

	If SoapGetCamp( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_MESSAGEXML:_T_VALUE[2]:TEXT") <> Nil
		If ("ERRORWRONGSERVERVERSION" $ Upper(WSAdvValue( aRetPost[3],cSoapTag+"_ENVELOPE:"+cSoapTag+"_BODY:_M_FINDITEMRESPONSE:_M_RESPONSEMESSAGES:_M_FINDITEMRESPONSEMESSAGE:_M_MESSAGEXML:_T_VALUE[2]:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)) ) 
			lRet := .F.
		EndIf
	EndIf
	
Return lRet