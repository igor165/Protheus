#include 'protheus.ch' 
#include 'EXGXFUNCS.ch'


//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Function ExgCrtMeeting(cUsuario, cSenha, cUrl, cTo, cCC, cBCC, dDtStart, dDtEnd, cHorStart, cHorEnd, cSubject, cDescription, cLocation, cEmlName, cRespRequest, cBusyStatus, cAllDayEvent, cReqOffSet, cMeetingStatus, cCodLang, cTipoCalendario )

Local lRet				:= .T.
Local cMsgRet			:= STR0001 //"Reuniao agendada com sucesso."
Local cDtTimeStart		:= ""
Local cDtTimeEnd		:= ""
Local cPOSTParam		:= ""
Local cEmlNameItem 		:= 'request'+cEmlName  
Local cError	  		:= ""
Local cWarning     	:= ""   
Local aHeadOut		:= {}
Local aHeadMov		:= {}
Local XMLHeadRet		:= ""  
Local XMLRet        	:= NIL
Local cURLComp			:= "" 
Local cLastMod			:= ""  
Local cUID				:= ""
Local aRetTime			:= {}
Local cCalendarString	:= "Calendar" 

Public  oObj	 	:= NIL

Default cRespRequest	:= "0"
Default cBusyStatus		:= "BUSY"
Default cAllDayEvent	:= "0"
Default cReqOffSet		:= "600"	
Default cMeetingStatus	:= "CONFIRMED"
Default cCodLang		:= "en_US"

If Lower(cCodLang) == Lower("pt_BR")
	cCalendarString	:= "Calend%C3%A1rio/"
ElseIf Empty(cCodLang) .Or. Lower(cCodLang) == Lower("en_US")
	cCalendarString	:= "Calendar"
EndIf

If 	Empty(cUsuario) 	.or.;
	Empty(cSenha) 		.or.;
	Empty(cUrl) 		.or.;
	Empty(dDtStart) 	.or.;
	Empty(dDtEnd) 		.or.;
	Empty(cHorStart) 	.or.;
	Empty(cHorEnd) 		.or.;
	Empty(cSubject) 	.or.;
	Empty(cEmlName)     

	cMsgRet	:= STR0002  //"Existem campos obrigatorios que não foram preenchidos."
	lRet	:= .F.
	Return({lRet,cMsgRet})

EndIf                    
                           
cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/"
	                                                         
// Convertendo data	
//cDtTimeStart	:= ConvDateTime(dDtStart, cHorStart, 1)
//cDtTimeEnd 		:= ConvDateTime(dDtEnd, cHorEnd, 1)   

// Convertendo data	
aRetTime		:= LocalToUTC ( DTOS(dDtStart), cHorStart )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtStart), cHorStart} )
cDtTimeStart	:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 1)                              

aRetTime		:= LocalToUTC ( DTOS(dDtEnd), cHorEnd )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtEnd), cHorEnd} )
cDtTimeEnd 		:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 1)  

//Exchange 2003 e inferiores
//Montando Header do PROPPATCH e MOVE
aadd(aHeadOut,'Content-Type: text/xml')
aadd(aHeadMov,'Content-Type: message/rfc822')
aadd(aHeadMov,'Destination: '+ Alltrim(cURLComp)+"##DavMailSubmissionURI##/")

cPOSTParam += '<?xml version="1.0"?>'
cPOSTParam += '<g:propertyupdate xmlns:g="DAV:"'
cPOSTParam += ' xmlns:e="http://schemas.microsoft.com/exchange/"' 
cPOSTParam += ' xmlns:mapi="http://schemas.microsoft.com/mapi/"' 
cPOSTParam += ' xmlns:mapit="http://schemas.microsoft.com/mapi/proptag/"' 
cPOSTParam += ' xmlns:x="xml:" xmlns:cal="urn:schemas:calendar:"' 
cPOSTParam += ' xmlns:dt="urn:uuid:c2f41010-65b3-11d1-a29f-00aa00c14882/"'
cPOSTParam += ' xmlns:header="urn:schemas:mailheader:"'
cPOSTParam += ' xmlns:mail="urn:schemas:httpmail:">'
cPOSTParam += '<g:set><g:prop>'
cPOSTParam += '<g:contentclass>urn:content-classes:appointment</g:contentclass>'
cPOSTParam += '<e:outlookmessageclass>IPM.Appointment</e:outlookmessageclass>'
cPOSTParam += '<mail:subject>'+EncodeUtf8(Alltrim(cSubject))+'</mail:subject>'
cPOSTParam += '<mail:htmldescription>'+EncodeUtf8(Alltrim(cDescription))+'</mail:htmldescription>'    
cPOSTParam += '<cal:location>'+EncodeUtf8(Alltrim(cLocation))+'</cal:location>'
cPOSTParam += '<cal:dtstart dt:dt="dateTime.tz">'+cDtTimeStart+'</cal:dtstart>'
cPOSTParam += '<cal:dtend dt:dt="dateTime.tz">'+cDtTimeEnd+'</cal:dtend>'
cPOSTParam += '<cal:instancetype dt:dt="int">0</cal:instancetype>'
cPOSTParam += '<cal:timezoneid dt:dt="int">8</cal:timezoneid>'
cPOSTParam += '<cal:busystatus>'+Upper(Alltrim(cBusyStatus))+'</cal:busystatus>'
cPOSTParam += '<cal:meetingstatus>'+Alltrim(cMeetingStatus)+'</cal:meetingstatus>'
cPOSTParam += '<cal:alldayevent dt:dt="boolean">'+ALltrim(cAllDayEvent)+'</cal:alldayevent>'
cPOSTParam += '<cal:responserequested dt:dt="boolean">'+cRespRequest+'</cal:responserequested>'
cPOSTParam += '<header:to>'+ cTo +'</header:to>'
cPOSTParam += '<header:cc>'+ cCC +'</header:cc>'
cPOSTParam += '<header:bcc>'+ cBCC +'</header:bcc>'
cPOSTParam += '<mapi:finvited dt:dt="boolean">1</mapi:finvited>'
cPOSTParam += '</g:prop></g:set>'
cPOSTParam += '</g:propertyupdate>'

HttpSetPass(Alltrim(cUsuario),Alltrim(cSenha))

XMLRet := Httpquote(cURLComp+cCalendarString+"/"+Alltrim(cEmlName),"PROPPATCH","",cPOSTParam,,aHeadOut,@XMLHeadRet)   

If XMLRet == NIL
	cMsgRet	:= STR0003 //"Não foi possivel encontrado servidor Exchange."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf	
	
oObj := XmlParser(XMLRet, "_", @cError, @cWarning)
If !Empty(cError)
	cMsgRet	:= cError
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf

//Valida login no Exchange
If Type("oObj:_A_MULTISTATUS") == "U" 
	cMsgRet	:= STR0004 //"Usuário ou senha do exchange está incorreto."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf
                                                                                                                          
cPOSTParam	:= ''
XMLHeadRet	:= ""		  
XMLRet		:= NIL  

cPOSTParam += "<?xml version='1.0'?>"
cPOSTParam += "<a:propfind xmlns:a='DAV:'>"
cPOSTParam += "<a:prop>"
cPOSTParam += "<a:displayname/>"
cPOSTParam += "<a:getlastmodified/>"
cPOSTParam += "</a:prop>"
cPOSTParam += "<a:prop xmlns:uid='urn:schemas:calendar:'><uid:uid/>"
cPOSTParam += "</a:prop>"
cPOSTParam += "</a:propfind>" 

HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
XMLRet := Httpquote(cURLComp+cCalendarString+"/"+Alltrim(cEmlName),"PROPFIND","",cPOSTParam,,aHeadOut,@XMLHeadRet) 

oObj 		:= XmlParser(XMLRet, "_", @cError, @cWarning)
If !Empty(cError)
	cMsgRet	:= cError
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf
cLastMod 		:= oObj:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_A_GETLASTMODIFIED:TEXT  
CUID			:= oObj:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_D_UID:TEXT  

cPOSTParam	:= ''
XMLHeadRet	:= ""		  
XMLRet		:= NIL  

cPOSTParam += '<?xml version="1.0"?>'
cPOSTParam += '<g:propertyupdate xmlns:g="DAV:"'
cPOSTParam += ' xmlns:e="http://schemas.microsoft.com/exchange/"'
cPOSTParam += ' xmlns:mapi="http://schemas.microsoft.com/mapi/"'
cPOSTParam += ' xmlns:mapit="http://schemas.microsoft.com/mapi/proptag/"'
cPOSTParam += ' xmlns:x="xml:" xmlns:cal="urn:schemas:calendar:"'
cPOSTParam += ' xmlns:dt="urn:uuid:c2f41010-65b3-11d1-a29f-00aa00c14882/"'
cPOSTParam += ' xmlns:header="urn:schemas:mailheader:"'
cPOSTParam += ' xmlns:mail="urn:schemas:httpmail:">'
cPOSTParam += '<g:set><g:prop>'
cPOSTParam += '<g:contentclass>urn:content-classes:calendarmessage</g:contentclass>'
cPOSTParam += '<e:outlookmessageclass>IPM.Schedule.Meeting.Request</e:outlookmessageclass>'
cPOSTParam += '<mail:subject>'+EncodeUtf8(Alltrim(cSubject))+'</mail:subject>'
cPOSTParam += '<mail:htmldescription>'+EncodeUtf8(Alltrim(cDescription))+'</mail:htmldescription>'
cPOSTParam += '<cal:location>'+EncodeUtf8(Alltrim(cLocation))+'</cal:location>'
cPOSTParam += '<cal:dtstart dt:dt="dateTime.tz">'+cDtTimeStart+'</cal:dtstart>'
cPOSTParam += '<cal:dtend dt:dt="dateTime.tz">'+cDtTimeEnd+'</cal:dtend>'
cPOSTParam += '<cal:instancetype dt:dt="int">0</cal:instancetype>'
cPOSTParam += '<cal:busystatus>BUSY</cal:busystatus>'
cPOSTParam += '<cal:meetingstatus>CONFIRMED</cal:meetingstatus>'
cPOSTParam += '<cal:alldayevent dt:dt="boolean">0</cal:alldayevent>'
cPOSTParam += '<cal:responserequested dt:dt="boolean">1</cal:responserequested>'
cPOSTParam += '<cal:uid>'+cUID+'</cal:uid>'
cPOSTParam += '<header:to>'+ cTo +'</header:to>'
cPOSTParam += '<header:cc>'+ cCC +'</header:cc>'
cPOSTParam += '<header:bcc>'+ cBCC +'</header:bcc>'
cPOSTParam += '<mapi:finvited dt:dt="boolean">1</mapi:finvited>'
cPOSTParam += '<mapi:responsestatus dt:dt="int">1</mapi:responsestatus>'
cPOSTParam += '<mapi:responsestate dt:dt="int">0</mapi:responsestate>'
cPOSTParam += '<mapi:response_requested dt:dt="boolean">'+cRespRequest+'</mapi:response_requested>'
cPOSTParam += '<mapi:apptstateflags dt:dt="int">3</mapi:apptstateflags>'
cPOSTParam += '<mapi:busystatus dt:dt="int">'+cBusyStatus+'</mapi:busystatus>'
cPOSTParam += '<mapi:intendedbusystatus dt:dt="int">2</mapi:intendedbusystatus>'
cPOSTParam += '</g:prop></g:set>'
cPOSTParam += '</g:propertyupdate>' 
                                    
HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
XMLRet := Httpquote(cURLComp+cCalendarString+"/"+Alltrim(cEmlNameItem),"PROPPATCH","",cPOSTParam,,aHeadOut,@XMLHeadRet) 

cPOSTParam	:= ''
XMLHeadRet	:= ""		  
XMLRet		:= NIL  

HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
XMLRet := Httpquote(cURLComp+cCalendarString+"/"+Alltrim(cEmlNameItem),"MOVE","",cPOSTParam,,aHeadMov,@XMLHeadRet) 			

Return({lRet,cMsgRet,cLastMod})


//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Function ExgCancMeetingFunction(cUsuario, cSenha, cUrl, cTo, cCC, cBCC, cSubject, cDescription, cEmlName, cCodLang)

Local lRet				:= .T.
Local cMsgRet			:= STR0005 //"Reuniao cancelada com sucesso."
Local cUID 				:= "" 
Local cLocation			:= ""
Local cDtStart			:= ""
Local cDtEnd 			:= ""
Local cURLComp			:= ""
Local cPOSTParam 		:= ""
Local aHeadOut		:= {}
Local aHeadMov		:= {}
Local XMLHeadRet    	:= ""
Local XMLRet        	:= NIL
Local cError			:= ""
Local cWarning   		:= ""
Local ErrorRet			:= "HTTP/1.1 404 Resource Not Found"
Local cCalendarString	:= "Calendar"
                               
Public  oObj	 	:= NIL

Default cCodLang	:= "en_US"

If Lower(cCodLang) == Lower("pt_BR")
	cCalendarString	:= "Calend%C3%A1rio"
ElseIf Empty(cCodLang) .Or. Lower(cCodLang) == Lower("en_US")
	cCalendarString	:= "Calendar"
EndIf

If 	Empty(cUsuario) 	.or.;
	Empty(cSenha) 		.or.;
	Empty(cUrl) 		.or.;
	Empty(cSubject) 	.or.;
	Empty(cEmlName)     
	cMsgRet	:= STR0002 //"Existem campos obrigatorios que não foram preenchidos."
	lRet	:= .F.
	Return({lRet,cMsgRet})

EndIf                    

cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/"

aadd(aHeadOut,'Content-Type: text/xml')
aadd(aHeadMov,'Content-Type: message/rfc822')
aadd(aHeadMov,'Destination: '+ Alltrim(cURLComp)+"##DavMailSubmissionURI##/")

HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))

cPOSTParam += "<?xml version='1.0'?>"
cPOSTParam += "<a:propfind xmlns:a='DAV:'>"
cPOSTParam += "<a:prop xmlns:uid='urn:schemas:calendar:'><uid:uid/>"
cPOSTParam += "<a:prop xmlns:dtstart='urn:schemas:calendar:'><dtstart:dtstart/>"
cPOSTParam += "<a:prop xmlns:dtend='urn:schemas:calendar:'><dtend:dtend/>"
cPOSTParam += "</a:prop>"
cPOSTParam += "</a:propfind>"  

//XMLPostRet := Httppost(cUrl,cGetParam,"",,aHeadOut,@XMLHeadRet)
XMLRet := Httpquote(cURLComp+cCalendarString+"/"+cEmlName,"PROPFIND","","",,aHeadOut,@XMLHeadRet) 

If XMLRet == NIL
	cMsgRet	:= STR0003  //"Não foi possivel encontrado servidor Exchange."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf	
      
//Reuniao nao encontrada
If ErrorRet$(XMLHeadRet)
	cMsgRet	:= XMLHeadRet
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf

oObj := XmlParser(XMLRet, "_", @cError, @cWarning)
If !Empty(cError)
	cMsgRet	:= cError
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf

cUID 		:= oObj:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_D_UID:TEXT
cDtStart	:= oObj:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_D_DTSTART:TEXT	
cDtEnd		:= oObj:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_D_DTEND:TEXT	
cLocation	:= oObj:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_D_LOCATION:TEXT

cPOSTParam	:= ''
XMLHeadRet	:= ""		  
XMLRet		:= NIL  

cPOSTParam += "<?xml version='1.0'?>"
cPOSTParam += '<g:propertyupdate xmlns:g="DAV:" xmlns:o="urn:schemas:calendar:"'
cPOSTParam +=         ' xmlns:p="urn:schemas:httpmail:"'
cPOSTParam +=         ' xmlns:q="urn:schemas:mailheader:"'
cPOSTParam +=         ' xmlns:e="http://schemas.microsoft.com/exchange/"'
cPOSTParam +=         ' xmlns:dt="urn:uuid:c2f41010-65b3-11d1-a29f-00aa00c14882/">'
cPOSTParam += '<g:set><g:prop>'
cPOSTParam += '<p:subject>'+EncodeUtf8(Alltrim(cSubject))+'</p:subject>'
cPOSTParam += '<p:textdescription>'+EncodeUtf8(Alltrim(cDescription))+'</p:textdescription>'
cPOSTParam += '<o:dtstart dt:dt="dateTime.tz">'+cDtStart+'</o:dtstart>'
cPOSTParam += '<o:dtend dt:dt="dateTime.tz">'+cDtEnd+'</o:dtend>'
cPOSTParam += '<o:location>'+EncodeUtf8(Alltrim(cLocation))+'</o:location>'
cPOSTParam += '<o:uid>'+cUID+'</o:uid>'
cPOSTParam += '<q:to>'+ cTo +'</q:to>'
cPOSTParam += '<q:cc>'+ cCC +'</q:cc>'
cPOSTParam += '<q:bcc>'+ cBCC +'</q:bcc>'
cPOSTParam += '<e:outlookmessageclass>IPM.Schedule.Meeting.Canceled</e:outlookmessageclass>'
cPOSTParam += '<g:contentclass>urn:content-classes:calendarmessage</g:contentclass>'
cPOSTParam += '<o:method>CANCEL</o:method>'
cPOSTParam += '</g:prop></g:set>'
cPOSTParam += '</g:propertyupdate>'

HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))

XMLRet := Httpquote(cURLComp+cCalendarString+"/"+cEmlName,"PROPPATCH","",cPOSTParam,,aHeadOut,@XMLHeadRet)     

cPOSTParam	:= ''
XMLHeadRet	:= ""		  
XMLRet		:= NIL  
	
HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
XMLRet := Httpquote(cURLComp+cCalendarString+"/"+cEmlName,"MOVE","",cPOSTParam,,aHeadMov,@XMLHeadRet) 

Return({lRet,cMsgRet})


//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Function ExgConsFreeCalendar(cUsuario, cSenha, cUrl, dDtStart, dDtEnd, cHorStart, cHorEnd, cCodLang)

Local nRet			:= 1
Local aHeadOut		:= {}
Local XMLHeadRet	:= ""  
Local XMLRet  		:= NIL
Local cError		:= ""
Local cWarning   	:= ""
Local cPOSTParam 	:= ''
Local cURLComp		:= "" 
Local cDtTimeStart	:= ""
Local cDtTimeEnd	:= ""
Local ErrorRet		:= "HTTP/1.1 404 Resource Not Found"
Local cMsgRet 		:= STR0006 //"Agenda Livre."
Local aRetTime		:= {}

Public  oObject	 	:= NIL  

Default cCodLang	:= "en_US"

If Empty(cCodLang)
	cCodLang := "en_US"
EndIf

If 	Empty(cUsuario) 	.or.;
	Empty(cSenha) 		.or.;
	Empty(dDtStart) 	.or.;
	Empty(dDtEnd) 		.or.;
	Empty(cHorStart) 	.or.;
	Empty(cHorEnd) 

	cMsgRet := STR0002 //"Existem campos obrigatorios que não foram preenchidos."
	nRet	:= 9
	Return({nRet,cMsgRet})

EndIf                    

If dDtStart > dDtEnd
	cMsgRet := STR0007  //"Data de inicio da agenda maior que a data final"
	nRet	:= 9
	Return({nRet,cMsgRet})
EndIf

If Lower(cCodLang) == Lower("pt_BR")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Calend%C3%A1rio/"
ElseIf Lower(cCodLang) == Lower("en_US")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Calendar/"
EndIf
	                                                         
// Convertendo data	
//cDtTimeStart	:= ConvDateTime(dDtStart, cHorStart, 2)
//cDtTimeEnd 		:= ConvDateTime(dDtEnd, cHorEnd, 2) 
aRetTime		:= LocalToUTC ( DTOS(dDtStart), cHorStart )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtStart), cHorStart} )
cDtTimeStart	:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 2)                              

aRetTime		:= LocalToUTC ( DTOS(dDtEnd), cHorEnd )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtEnd), cHorEnd} )
cDtTimeEnd 		:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 2)  

cPOSTParam 	+= 	'<?xml version="1.0"?>'
cPOSTParam 	+= 	'<g:searchrequest xmlns:g="DAV:">'
cPOSTParam 	+= 	'<g:sql>SELECT "DAV:href",'
cPOSTParam 	+= 	' "urn:schemas:calendar:lastmodified",'
cPOSTParam 	+= 	' "urn:schemas:calendar:busystatus",'
cPOSTParam 	+= 	' "urn:schemas:calendar:uid",'
cPOSTParam 	+= 	' "urn:schemas:httpmail:subject",'
cPOSTParam 	+= 	' "urn:schemas:calendar:dtstart",'
cPOSTParam 	+= 	' "urn:schemas:calendar:dtend" '
cPOSTParam 	+= 	' FROM Scope(' + "'SHALLOW TRAVERSAL OF " + '"'+ Alltrim(cURLComp) + '"' + "'" +')'
cPOSTParam 	+= 	' WHERE ("DAV:ishidden" = false) AND'
cPOSTParam 	+= 	' ("urn:schemas:calendar:dtstart" &gt; ' + "'"+Alltrim(cDtTimeStart)+"'" 
cPOSTParam 	+= 	' AND "urn:schemas:calendar:dtend" &lt; '+ "'"+Alltrim(cDtTimeEnd)+"') OR" 
cPOSTParam 	+= 	' ("urn:schemas:calendar:dtstart" &gt; ' + "'"+Alltrim(cDtTimeStart)+"'" 
cPOSTParam 	+= 	' AND "urn:schemas:calendar:dtstart" &lt; '+ "'"+Alltrim(cDtTimeEnd)+"') OR" 
cPOSTParam 	+= 	' ("urn:schemas:calendar:dtend" &gt; ' + "'"+Alltrim(cDtTimeStart)+"'" 
cPOSTParam 	+= 	' AND "urn:schemas:calendar:dtend" &lt; '+ "'"+Alltrim(cDtTimeEnd)+"')" 
cPOSTParam 	+= 	' ORDER BY "urn:schemas:calendar:dtstart"'
cPOSTParam 	+= 	' ASC </g:sql></g:searchrequest>'					

aadd(aHeadOut,'Content-Type: text/xml')
HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
XMLRet := Httpquote(cURLComp,"SEARCH","",cPOSTParam,,aHeadOut,@XMLHeadRet)

If ErrorRet$(XMLHeadRet)
	cMsgRet := STR0003 //"Não foi possivel encontrado servidor Exchange."
 	nRet	:= 9
	Return({nRet,cMsgRet})
EndIF

If XMLRet <> NIL
	//Apontamento nao encontrado
	oObject := XmlParser(XMLRet, "_", @cError, @cWarning)
	If Empty(cError) 
		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE") != "U"   
			cMsgRet := STR0008  //"Agenda Ocupada."
			nRet := 0
		EndIf
	Else
		cMsgRet := STR0009 + Alltrim(cError)  //"Erro no XML: "
		nRet := 9
	EndIF
Else
	cMsgRet := STR0010 + Alltrim(XMLHeadRet)  //"Erro na pesquisa: "
	nRet := 9
Endif   

Return({nRet,cMsgRet})


//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Function ExgCrtTasks(cUsuario, cSenha, cUrl, dDtStart, dDtEnd, cHorStart, cHorEnd, cSubject, cDescription, nPorcentagem, cStateTask, cReminder, cComplete, cEmlName, dDtReminder, cHorReminder, cCodLang) 

Local cURLComp		:= ""
Local cPOSTParam 	:= ""   
Local aHeadOut		:= {}     
Local XMLHeadRet    := ""
Local XMLRet        := NIL
Local lRet			:= .T.
Local cMsgRet		:= STR0011  //"Tarefa criada com sucesso."
Local cDtTimeStart	:= ""
Local cDtTimeEnd	:= ""
Local cDtTimeRem	:= ""
Local cPorc			:= ""
Local ErrorRet		:= "HTTP/1.1 404 Resource Not Found"     
Local cVersaoExchange   := GetMv("MV_VEREXCH",,"")


Public  oObj	 	:= NIL

Default nPorcentagem	:=  0
Default cStateTask      := "0"
Default cReminder       := "0"
Default cComplete       := "0"
Default cCodLang		:= "en_US"

If Empty(cCodLang)
	cCodLang := "en_US"
EndIf

If 	Empty(cUsuario) 	.or.;
	Empty(cSenha) 		.or.;
	Empty(cUrl) 		.or.;
	Empty(dDtStart) 	.or.;
	Empty(dDtEnd) 		.or.;
	Empty(cHorStart) 	.or.;
	Empty(cHorEnd) 		.or.;
	Empty(cSubject) 	.or.;
	Empty(cEmlName)     

	cMsgRet	:= STR0002 //"Existem campos obrigatorios que não foram preenchidos."
	lRet	:= .F.
	Return({lRet,cMsgRet})

EndIf  
        
cPorc := IIF(nPorcentagem==0,"0",Alltrim(Str(nPorcentagem/100)))

If  (cReminder == "1") .AND. (Empty(dDtReminder) .OR. Empty(cHorReminder))
	cMsgRet	:= STR0012 //"Para utilizar a opção de lembrete é necessário informar data e hora para que execução do lembrete."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf

If Lower(cCodLang) == Lower("pt_BR")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Tarefas/"
ElseIf Lower(cCodLang) == Lower("en_US")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Tasks/"
EndIf
	                                                         
// Convertendo data	
//cDtTimeStart	:= ConvDateTime(dDtStart, cHorStart, 1)
//cDtTimeEnd 	:= ConvDateTime(dDtEnd, cHorEnd, 1)
aRetTime		:= LocalToUTC ( DTOS(dDtStart), cHorStart )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtStart), cHorStart} )
cDtTimeStart	:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 1)                              

aRetTime		:= LocalToUTC ( DTOS(dDtEnd), cHorEnd )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtEnd), cHorEnd} )
cDtTimeEnd 		:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 1)  

  
If !Empty(dDtReminder) .and. !Empty(cHorReminder)
	//cDtTimeRem		:= ConvDateTime(dDtReminder, cHorReminder, 1)
	aRetTime		:= LocalToUTC ( DTOS(dDtReminder), cHorReminder )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtReminder), cHorReminder} )
	cDtTimeRem 		:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 1)  
EndIf

//
// CREATE TASK
//
                           
//Exchange anterior a 2007
If cVersaoExchange <> "2007"
	cPOSTParam += '<?xml version="1.0"?>'
	cPOSTParam += '<d:propertyupdate xmlns:d="DAV:" xmlns:e="http://schemas.microsoft.com/exchange/" '
	cPOSTParam += 'xmlns:b="urn:uuid:c2f41010-65b3-11d1-a29f-00aa00c14882/" '
	cPOSTParam += 'xmlns:f="urn:schemas:mailheader:" '
	cPOSTParam += 'xmlns:g="urn:schemas:httpmail:" '
	cPOSTParam += 'xmlns:j="http://schemas.microsoft.com/mapi/id/{00062003-0000-0000-C000-000000000046}/" '
	cPOSTParam += 'xmlns:i="http://schemas.microsoft.com/mapi/id/{00062008-0000-0000-C000-000000000046}/" '
	cPOSTParam += 'xmlns:h="http://schemas.microsoft.com/mapi/id/{00062003-0000-0000-C000-000000000046}/">'
	cPOSTParam += '<d:set><d:prop>'
	cPOSTParam += '<d:contentclass>urn:content-classes:task</d:contentclass>'
	cPOSTParam += '<e:outlookmessageclass>IPM.Task</e:outlookmessageclass>'
	cPOSTParam += '<f:subject>'+EncodeUtf8(Alltrim(cSubject))+'</f:subject>'
	cPOSTParam += '<g:textdescription>'+EncodeUtf8(Alltrim(cDescription))+'</g:textdescription>'
	cPOSTParam += '<h:0x0000811c b:dt="boolean">'+cComplete+'</h:0x0000811c>' //Complete True=Complete;False=No Complete
	cPOSTParam += '<h:0x00008102 b:dt="float">'+cPorc+'</h:0x00008102>' //PercentComplete
	cPOSTParam += '<h:0x00008101 b:dt="int">'+cStateTask+'</h:0x00008101>' //Status  0=Open;1=In Progress;2=Completed;3=Waiting for Someone Else;4=Deferred
	cPOSTParam += '<i:0x8516 b:dt="dateTime.tz">'+cDtTimeStart+'</i:0x8516>' //CommonStart  
	cPOSTParam += '<i:0x8517 b:dt="dateTime.tz">'+cDtTimeEnd+'</i:0x8517>' //CommonEnd   
	If !Empty(cDtTimeRem)
		cPOSTParam += '<i:0x8502 b:dt="dateTime.tz">'+cDtTimeRem+'</i:0x8502>' //Reminder Set  
	EndIf
	cPOSTParam += '<i:0x8503 b:dt="boolean">'+cReminder+'</i:0x8503>' //Reminder Set  
	cPOSTParam += '</d:prop></d:set>'
	cPOSTParam += '</d:propertyupdate>'
	
	aadd(aHeadOut,'Content-Type: text/xml')
	HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
	XMLRet := Httpquote(cURLComp+cEmlName,"PROPPATCH","",cPOSTParam,,aHeadOut,@XMLHeadRet) 
	
	If XMLRet == NIL
		cMsgRet	:= STR0003 //"Não foi possivel encontrar o servidor Exchange."
		lRet	:= .F.
		Return({lRet,cMsgRet})
	EndIf	
	                                                                                       
	If ErrorRet$(XMLHeadRet)
		cMsgRet	:= XMLHeadRet
		lRet	:= .F.
		Return({lRet,cMsgRet})
	EndIf
//Else 
//	lRet := EX07_Task1(	Alltrim(cUsuario),;
//						ALltrim(cSenha),;
//						EncodeUtf8(Alltrim(cSubject)),;
//						EncodeUtf8(Alltrim(cDescription)),;
//						cDtTimeStart,;
//						cDtTimeStart)
//	If lRet 
//		cMsgRet := "Tarefa sincronizada com sucesso." 
//	Else
//		cMsgRet := "Falha na sincronizacao com Exchange Server." 
//	EndIf

EndIf

Return({lRet,cMsgRet})   

//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Function ExgDelTasks(cUsuario, cSenha, cUrl, cEmlName, cCodLang) 

Local cURLComp		:= ""
Local aHeadOut		:= {}     
Local XMLHeadRet    := ""
Local XMLRet        := NIL
Local lRet			:= .T.
Local cMsgRet		:= STR0013 //"Tarefa excluida com sucesso."
Local ErrorRet		:= "HTTP/1.1 404 Resource Not Found"

Default cCodLang := "en_US"

If Empty(cCodLang)
	cCodLang := "en_US"
EndIf

If 	Empty(cUsuario) 	.or.;
	Empty(cSenha) 		.or.;
	Empty(cUrl) 		.or.;
	Empty(cEmlName)     

	cMsgRet	:= STR0002  //"Existem campos obrigatorios que não foram preenchidos."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf  

If Lower(cCodLang) == Lower("pt_BR")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Tarefas/"+Alltrim(cEmlName)
ElseIf Lower(cCodLang) == Lower("en_US")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Tasks/"+Alltrim(cEmlName)
EndIf

HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
XMLRet := Httpquote(cURLComp,"DELETE","","",,aHeadOut,@XMLHeadRet)     

If XMLRet == NIL
	cMsgRet	:= STR0003 //"Não foi possivel encontrado servidor Exchange."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf	
      
If ErrorRet$(XMLHeadRet)
	cMsgRet	:= STR0014 + Alltrim(cEmlName) + STR0015  //"Tarefa " ###"não foi encontrada."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf   

Return({lRet,cMsgRet})                                                
       
          
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Function ExgConsTasks(cUsuario, cSenha, cUrl, dDtStart, dDtEnd, cHorStart, cHorEnd,cEMLName, cCodLang)

Local aRet			:= {}
Local aHeadOut		:= {}
Local XMLHeadRet	:= ""  
Local XMLRet  		:= NIL
Local cError		:= ""
Local cWarning   	:= ""
Local cPOSTParam 	:= ''
Local cURLComp		:= "" 
Local cDtTimeStart	:= ""
Local cDtTimeEnd	:= ""
Local ErrorRet		:= "HTTP/1.1 404 Resource Not Found" 
Local nY			:= 0
Local nX			:= 0
Local cMsgRet		:= "OK."   
Local lRet			:= .T.
Local nPos			:= 0
Local nTam 			:= 0
Local cDisplayName 	:= ""
Local cVersaoExchange   := GetMv("MV_VEREXCH",,"")

Public  oObject	 	:= NIL 

Default cEMLName	:= "" 
Default cCodLang	:= "en_US"

If Empty(cCodLang)
	cCodLang := "en_US"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   
//Posições da Array                  ³
//1- Subject                         ³
//2- Description                     ³
//3- Complete/InProgress             ³
//4- Porcentagem                     ³
//5- Status                          ³
//6- DataTime Star                   ³
//7- Datatime Duetime                ³
//8- Datatime Reminder               ³
//9- Href      				         ³
//10- Name             				 ³
//11- Last Modified             	 ³
//12- ID            				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   

If Empty(cEMLName)
	If 	Empty(cUsuario) 	.or.;
		Empty(cSenha) 		.or.;
		Empty(dDtStart) 	.or.;
		Empty(dDtEnd) 		.or.;
		Empty(cHorStart) 	.or.;
		Empty(cHorEnd) 
	
		cMsgRet := STR0002 //"Existem campos obrigatorios que não foram preenchidos."
		lRet	:= .F.
		Return({lRet,cMsgRet,aRet})
	EndIf	
Else
	If 	Empty(cUsuario) 	.or.;
		Empty(cSenha)
	
		cMsgRet := STR0002 //"Existem campos obrigatorios que não foram preenchidos."
		lRet	:= .F.
		Return({lRet,cMsgRet,aRet})
	EndIf	
EndIf                    

If dDtStart > dDtEnd
	cMsgRet := STR0007 //"Data de inicio da agenda maior que a data final"
	lRet	:= .F.
	Return({lRet,cMsgRet,aRet})
EndIf

If Lower(cCodLang) == Lower("pt_BR")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Tarefas/"
ElseIf Lower(cCodLang) == Lower("en_US")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Tasks/"
EndIf

aadd(aHeadOut,'Content-Type: text/xml')
	                                                         
// Convertendo data	
//cDtTimeStart	:= ConvDateTime(dDtStart, cHorStart, 3)
//cDtTimeEnd 		:= ConvDateTime(dDtEnd, cHorEnd, 3)   

If Empty(cEMLName)
	//aRetTime		:= ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtStart), cHorStart} )
	//cDtTimeStart	:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 3)                              
	cDtTimeStart	:= ConvDateTime(dDtStart, cHorStart, 3)                              
	
	//aRetTime		:= ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtEnd), cHorEnd} )
	//cDtTimeEnd 		:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 3)  
	cDtTimeEnd 		:= ConvDateTime(dDtEnd, cHorEnd, 3)  
EndIf

If cVersaoExchange <> "2007"
	cPOSTParam 	+= 	'<?xml version="1.0"?>'
	cPOSTParam 	+= 	'<g:searchrequest xmlns:g="DAV:">'
	cPOSTParam 	+= 	'<g:sql>SELECT "DAV:href","DAV:getlastmodified","DAV:id","DAV:displayname",'
	//cPOSTParam 	+= 	' "http://schemas.microsoft.com/mapi/id/{00062008-0000-0000-C000-000000000046}/0x8516" '
	cPOSTParam 	+= 	' "http://schemas.microsoft.com/mapi/id/{00062008-0000-0000-C000-000000000046}/0x8516", '
	cPOSTParam 	+= 	' "http://schemas.microsoft.com/mapi/id/{00062008-0000-0000-C000-000000000046}/0x8517", '
	cPOSTParam 	+= 	' "http://schemas.microsoft.com/mapi/id/{00062008-0000-0000-C000-000000000046}/0x8502", '
	cPOSTParam 	+= 	' "http://schemas.microsoft.com/mapi/id/{00062003-0000-0000-C000-000000000046}/0x00008101", '
	cPOSTParam 	+= 	' "http://schemas.microsoft.com/mapi/id/{00062003-0000-0000-C000-000000000046}/0x00008102", '
	cPOSTParam 	+= 	' "http://schemas.microsoft.com/mapi/id/{00062003-0000-0000-C000-000000000046}/0x0000811c", '  
	cPOSTParam 	+= 	' "urn:schemas:httpmail:textdescription", '
	cPOSTParam 	+= 	' "urn:schemas:mailheader:subject"
	cPOSTParam 	+= 	' FROM Scope(' + "'SHALLOW TRAVERSAL OF " + '"'+ Alltrim(cURLComp) + '"' + "'" +')'
	cPOSTParam 	+= 	' WHERE ("DAV:ishidden" = false) AND'
	//cPOSTParam 	+= 	' "http://schemas.microsoft.com/mapi/id/{00062008-0000-0000-C000-000000000046}/0x8516" &gt; '+ "'" + cDtTimeStart + "' "  
	If Empty(cEMLName)
		cPOSTParam 	+= 	' ("http://schemas.microsoft.com/mapi/id/{00062008-0000-0000-C000-000000000046}/0x8516" &gt; '+ "'" + cDtTimeStart + "') AND"  
		cPOSTParam 	+= 	' ("http://schemas.microsoft.com/mapi/id/{00062008-0000-0000-C000-000000000046}/0x8517" &lt; '+ "'" + cDtTimeEnd + "')"  
	Else
		cPOSTParam 	+= 	' ("DAV:displayname" = ' +"'"+Alltrim(cEMLName)+"'"+')'
	EndIF
	cPOSTParam 	+= 	' </g:sql></g:searchrequest>'					
	
	HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
	
	//XMLPostRet := Httppost(cUrl,cGetParam,"",,aHeadOut,@XMLHeadRet)
	XMLRet := Httpquote(cURLComp,"SEARCH","",cPOSTParam,,aHeadOut,@XMLHeadRet) 
	
	If ErrorRet$(XMLHeadRet)
		cMsgRet := STR0003 //"Não foi possivel encontrado servidor Exchange."
		lRet	:= .F.
		Return({lRet,cMsgRet,aRet})
	EndIF
	
	If XMLRet <> NIL
		//Apontamento nao encontrado
		oObject := XmlParser(XMLRet, "_", @cError, @cWarning)
		If Empty(cError) 
			If Type("oObject:_A_MULTISTATUS:_A_RESPONSE") != "U" 
				If Valtype(oObject:_A_MULTISTATUS:_A_RESPONSE)=="A"
					For nY:=1 to Len(oObject:_A_MULTISTATUS:_A_RESPONSE)
					
						If (Valtype(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT)=="A") 
							AADD(aRet,Array(12))
							For nX:=1 to Len(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT)
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_G_SUBJECT")=="O"		
									aRet[Len(aRet),1] := oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[nX]:_A_PROP:_G_SUBJECT:TEXT
								EndIf
		
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_F_TEXTDESCRIPTION")=="O"		
									aRet[Len(aRet),2] := oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[nX]:_A_PROP:_F_TEXTDESCRIPTION:TEXT
								EndIf
		
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_E_0X0000811C")=="O"		
									aRet[Len(aRet),3] := oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[nX]:_A_PROP:_E_0X0000811C:TEXT
								EndIf
		
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_E_0X00008102")=="O"		
									aRet[Len(aRet),4] := oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[nX]:_A_PROP:_E_0X00008102:TEXT
								EndIf
		
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_E_0X00008101")=="O"		
									aRet[Len(aRet),5] := oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[nX]:_A_PROP:_E_0X00008101:TEXT
								EndIf
		
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_D_0X8516")=="O"		
									aRet[Len(aRet),6] := oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[nX]:_A_PROP:_D_0X8516:TEXT
								EndIf
		
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_D_0X8517")=="O"		
									aRet[Len(aRet),7] := oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[nX]:_A_PROP:_D_0X8517:TEXT
								EndIf
		
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_D_0X8502")=="O"		
									aRet[Len(aRet),8] := oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[nX]:_A_PROP:_D_0X8502:TEXT
								EndIf
		
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nX))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_A_HREF")=="O"		
									aRet[Len(aRet),9] := oObject:_A_MULTISTATUS:_A_RESPONSE[nX]:_A_PROPSTAT[nX]:_A_PROP:_A_HREF:TEXT
								EndIf
		
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_A_GETLASTMODIFIED")=="O"		
									aRet[Len(aRet),11] := oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[nX]:_A_PROP:_A_GETLASTMODIFIED:TEXT
								EndIf
		
						   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT["+Alltrim(Str(nX))+"]:_A_PROP:_A_ID")=="O"		
									aRet[Len(aRet),12] := oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[nX]:_A_PROP:_A_ID:TEXT
								EndIf
		
						    Next nX  
						    
						    If !Empty(aRet[Len(aRet),9])
								nPos			:= RAT('/',aRet[Len(aRet),9])
								nTam 			:= Len(Alltrim(aRet[Len(aRet),9]))-nPos
								cDisplayName 	:= Substr(aRet[Len(aRet),9],nPos+1,nTam)	
								aRet[Len(aRet),10] := cDisplayName
						    EndIf
						    
						Else
						
							nPos			:= RAT('/',oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_A_HREF:TEXT)+1
							nTam 			:= Len(Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_A_HREF:TEXT))-nPos
							cDisplayName 	:= Substr(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_A_HREF:TEXT,nPos,nTam)	
							AADD(aRet,{oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_G_SUBJECT:TEXT,;
			   						   oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_F_TEXTDESCRIPTION:TEXT,;			
			   						   oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_E_0X0000811C:TEXT,;			
			   						   oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_E_0X00008102:TEXT,;			
			   						   oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_E_0X00008101:TEXT,;			
			   						   oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_D_0X8516:TEXT,;			
			   						   oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_D_0X8517:TEXT,;			
			   						   oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_D_0X8502:TEXT,;
			   						   oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_A_HREF:TEXT,;
			   						   cDisplayName,;
			   						   oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_A_GETLASTMODIFIED:TEXT,;
			   						   oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT:_A_PROP:_A_ID:TEXT})
					    
						EndIF
					Next nY
				Else   
				
					If (Valtype(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT)=="A") 
						AADD(aRet,Array(12))
						For nY:=1 to Len(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT)
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_G_SUBJECT")=="O"		
								aRet[Len(aRet),1] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_G_SUBJECT:TEXT
							EndIf
	
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_F_TEXTDESCRIPTION")=="O"		
								aRet[Len(aRet),2] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_F_TEXTDESCRIPTION:TEXT
							EndIf
	
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_E_0X0000811C")=="O"		
								aRet[Len(aRet),3] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_E_0X0000811C:TEXT
							EndIf
	
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_E_0X00008102")=="O"		
								aRet[Len(aRet),4] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_E_0X00008102:TEXT
							EndIf
	
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_E_0X00008101")=="O"		
								aRet[Len(aRet),5] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_E_0X00008101:TEXT
							EndIf
	
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_D_0X8516")=="O"		
								aRet[Len(aRet),6] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_D_0X8516:TEXT
							EndIf
	
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_D_0X8517")=="O"		
								aRet[Len(aRet),7] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_D_0X8517:TEXT
							EndIf
	
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_D_0X8502")=="O"		
								aRet[Len(aRet),8] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_D_0X8502:TEXT
							EndIf
	
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_A_HREF")=="O"		
								aRet[Len(aRet),9] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_A_HREF:TEXT
							EndIf
	
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_A_GETLASTMODIFIED")=="O"		
								aRet[Len(aRet),11] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_A_GETLASTMODIFIED:TEXT
							EndIf
	
					   		If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT["+Alltrim(Str(nY))+"]:_A_PROP:_A_ID")=="O"		
								aRet[Len(aRet),12] := oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[nY]:_A_PROP:_A_ID:TEXT
							EndIf
	
					    Next nY  
					    
					    If !Empty(aRet[Len(aRet),9])
							nPos			:= RAT('/',aRet[Len(aRet),9])
							nTam 			:= Len(Alltrim(aRet[Len(aRet),9]))-nPos
							cDisplayName 	:= Substr(aRet[Len(aRet),9],nPos+1,nTam)	
							aRet[Len(aRet),10] := cDisplayName
					    EndIf
					    
					Else
						nPos			:= RAT('/',oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_A_HREF:TEXT)
						nTam 			:= Len(Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_A_HREF:TEXT))-nPos
						cDisplayName 	:= Substr(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_A_HREF:TEXT,nPos+1,nTam)	
						AADD(aRet,{oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_G_SUBJECT:TEXT,;
		   						   oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_F_TEXTDESCRIPTION:TEXT,;			
		   						   oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_E_0X0000811C:TEXT,;			
		   						   oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_E_0X00008102:TEXT,;			
		   						   oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_E_0X00008101:TEXT,;			
		   						   oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_D_0X8516:TEXT,;			
		   						   oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_D_0X8517:TEXT,;			
		   						   oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_D_0X8502:TEXT,;
		   						   oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_A_HREF:TEXT,;
		   						   cDisplayName,;
		   						   oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_A_GETLASTMODIFIED:TEXT,;
		   						   oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_A_ID:TEXT})
					EndIf
				EndIF  
			EndIf
		Else
			cMsgRet := STR0009 + Alltrim(cError)
			lRet	:= .F.
		EndIF
	Else
		cMsgRet :=STR0010 + Alltrim(XMLHeadRet) //"Erro na pesquisa: "
		lRet	:= .F.
	Endif 
Else
	lRet    := .T.
	cMsgRet := STR0020 //"Tarefas incluidas com sucesso no Exchange Server 2007"
EndIf  
	

Return ({lRet,cMsgRet,aRet})  



//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Function ExgCrtAppointment(cUsuario, cSenha, cUrl, dDtStart, dDtEnd, cHorStart, cHorEnd, cSubject, cDescription, cLocation, cEmlName, cBusyStatus, cAllDayEvent, cReqOffSet, cRespRequest, cMeetingStatus, cCodLang )

Local lRet				:= .T.
Local cMsgRet			:= STR0016 //"Apontamento gerado com sucesso."
Local cDtTimeStart		:= ""
Local cDtTimeEnd		:= ""
Local cPOSTParam		:= ""
Local cError	  		:= ""
Local cWarning     		:= ""   
Local aHeadOut			:= {}
Local XMLHeadRet   		:= ""  
Local XMLRet        	:= NIL
Local cURLComp			:= "" 
Local cLastMod			:= ""   
Local aRetTime			:= {}
Local cCalendarString	:= "Calendar"

Public  oObj	 	:= NIL

Default cCodLang	:= "en_US"

If Empty(cCodLang)
	cCodLang := "en_US"
EndIf

If Lower(cCodLang) == Lower("pt_BR")
	cCalendarString := "Calend%C3%A1rio"
ElseIf Lower(cCodLang) == Lower("en_US")
	cCalendarString := "Calendar"
EndIf

If 	Empty(cUsuario) 	.or.;
	Empty(cSenha) 		.or.;
	Empty(cUrl) 		.or.;
	Empty(dDtStart) 	.or.;
	Empty(dDtEnd) 		.or.;
	Empty(cHorStart) 	.or.;
	Empty(cHorEnd) 		.or.;
	Empty(cSubject) 	.or.;
	Empty(cEmlName)     

	cMsgRet	:= STR0002 //"Existem campos obrigatorios que não foram preenchidos."
	lRet	:= .F.
	Return({lRet,cMsgRet})

EndIf  

Default cBusyStatus		:= "BUSY"
Default cAllDayEvent	:= "0"
Default cReqOffSet		:= "600" 
Default cRespRequest	:= "0"
Default cMeetingStatus	:= "CONFIRMED"
	

cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/"
	                                                         
// Convertendo data	
aRetTime		:= LocalToUTC ( DTOS(dDtStart), cHorStart )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtStart), cHorStart} )
cDtTimeStart	:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 1)                              

aRetTime		:= LocalToUTC ( DTOS(dDtEnd), cHorEnd )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtEnd), cHorEnd} )
cDtTimeEnd 		:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 1)  

//Montando Header do PROPPATCH e MOVE
aadd(aHeadOut,'Content-Type: text/xml')

cPOSTParam += '<?xml version="1.0"?>'
cPOSTParam += '<g:propertyupdate xmlns:g="DAV:"'
cPOSTParam += ' xmlns:e="http://schemas.microsoft.com/exchange/"' 
cPOSTParam += ' xmlns:mapi="http://schemas.microsoft.com/mapi/"' 
cPOSTParam += ' xmlns:mapit="http://schemas.microsoft.com/mapi/proptag/"' 
cPOSTParam += ' xmlns:x="xml:" xmlns:cal="urn:schemas:calendar:"' 
cPOSTParam += ' xmlns:dt="urn:uuid:c2f41010-65b3-11d1-a29f-00aa00c14882/"'
cPOSTParam += ' xmlns:header="urn:schemas:mailheader:"'
cPOSTParam += ' xmlns:mail="urn:schemas:httpmail:">'
cPOSTParam += '<g:set><g:prop>'
cPOSTParam += '<g:contentclass>urn:content-classes:appointment</g:contentclass>'
cPOSTParam += '<e:outlookmessageclass>IPM.Appointment</e:outlookmessageclass>'
cPOSTParam += '<mail:subject>'+EncodeUtf8(Alltrim(cSubject))+'</mail:subject>'
cPOSTParam += '<mail:htmldescription>'+EncodeUtf8(Alltrim(cDescription))+'</mail:htmldescription>'    
cPOSTParam += '<cal:location>'+EncodeUtf8(Alltrim(cLocation))+'</cal:location>'
cPOSTParam += '<cal:dtstart dt:dt="dateTime.tz">'+cDtTimeStart+'</cal:dtstart>'
cPOSTParam += '<cal:dtend dt:dt="dateTime.tz">'+cDtTimeEnd+'</cal:dtend>'
cPOSTParam += '<cal:instancetype dt:dt="int">0</cal:instancetype>'
cPOSTParam += '<cal:busystatus>'+Upper(Alltrim(cBusyStatus))+'</cal:busystatus>'
cPOSTParam += '<cal:meetingstatus>'+Alltrim(cMeetingStatus)+'</cal:meetingstatus>'
cPOSTParam += '<cal:alldayevent dt:dt="boolean">'+ALltrim(cAllDayEvent)+'</cal:alldayevent>'
cPOSTParam += '<cal:responserequested dt:dt="boolean">'+cRespRequest+'</cal:responserequested>'
cPOSTParam += '<mapi:finvited dt:dt="boolean">0</mapi:finvited>'
cPOSTParam += '</g:prop></g:set>'
cPOSTParam += '</g:propertyupdate>'

HttpSetPass(Alltrim(cUsuario),Alltrim(cSenha))

XMLRet := Httpquote(cURLComp+cCalendarString+"/"+Alltrim(cEmlName),"PROPPATCH","",cPOSTParam,,aHeadOut,@XMLHeadRet)   

If XMLRet == NIL
	cMsgRet	:= STR0003 //"Não foi possivel encontrado servidor Exchange."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf	
	
oObj := XmlParser(XMLRet, "_", @cError, @cWarning)
If !Empty(cError)
	cMsgRet	:= cError
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf

//Valida login no Exchange
If Type("oObj:_A_MULTISTATUS") == "U" 
	cMsgRet	:= STR0004 //"Usuário ou senha do exchange está incorreto."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf
                                                                                                                          
cPOSTParam	:= ''
XMLHeadRet	:= ""		  
XMLRet		:= NIL  

cPOSTParam += "<?xml version='1.0'?>"
cPOSTParam += "<a:propfind xmlns:a='DAV:'>"
cPOSTParam += "<a:prop>"
cPOSTParam += "<a:displayname/>"
cPOSTParam += "<a:getlastmodified/>"
cPOSTParam += "</a:prop>"
cPOSTParam += "</a:propfind>"  

HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
XMLRet := Httpquote(cURLComp+cCalendarString+"/"+Alltrim(cEmlName),"PROPFIND","",cPOSTParam,,aHeadOut,@XMLHeadRet) 

oObj 		:= XmlParser(XMLRet, "_", @cError, @cWarning)
If !Empty(cError)
	cMsgRet	:= cError
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf
cLastMod 		:= oObj:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT:_A_PROP:_A_GETLASTMODIFIED:TEXT

Return({lRet,cMsgRet,cLastMod})

//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Function ExgConsAppointment(cUsuario, cSenha, cUrl, dDtStart, dDtEnd, cHorStart, cHorEnd, cEMLName, cCodLang)

Local lRet			:= .T.
Local aHeadOut		:= {}
Local XMLHeadRet	:= ""  
Local XMLRet  		:= NIL
Local cError		:= ""
Local cWarning   	:= ""
Local cPOSTParam 	:= ''
Local cURLComp		:= "" 
Local cDtTimeStart	:= ""
Local cDtTimeEnd	:= ""
Local ErrorRet		:= "HTTP/1.1 404 Resource Not Found"
Local cMsgRet 		:= "" 
Local aRet			:= {} 
Local nY			:= 0 
Local cTO			:= ""    
Local cCC			:= ""
Local cBCC			:= ""
Local cVersaoExchange   := GetMv("MV_VEREXCH",,"")

Public  oObject	 	:= NIL  

Default cEMLName	:= ""
Default cCodLang	:= "en_US"

If Empty(cCodLang)
	cCodLang := "en_US"
EndIf

If Empty(cEMLName)
	If 	Empty(cUsuario) 	.or.;
		Empty(cSenha) 		.or.;
		Empty(dDtStart) 	.or.;
		Empty(dDtEnd) 		.or.;
		Empty(cHorStart) 	.or.;
		Empty(cHorEnd) 
	
		cMsgRet := STR0002 //"Existem campos obrigatorios que não foram preenchidos."
		lRet	:= .F.
		Return({lRet,cMsgRet,aRet})
	EndIf
EndIf                    

If dDtStart > dDtEnd
	cMsgRet := STR0007 //"Data de inicio da agenda maior que a data final"
	lRet	:= .F.
	Return({lRet,cMsgRet,aRet})
EndIf

If Lower(cCodLang) == Lower("pt_BR")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Calend%C3%A1rio/"
ElseIf Lower(cCodLang) == Lower("en_US")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Calendar/"
EndIf
	                                                         
// Convertendo data	
If Empty(cEMLName)
	//cDtTimeStart	:= ConvDateTime(dDtStart, cHorStart, 2)
	//cDtTimeEnd 		:= ConvDateTime(dDtEnd, cHorEnd, 2)  

	aRetTime		:= LocalToUTC ( DTOS(dDtStart), cHorStart )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtStart), cHorStart} )
	cDtTimeStart	:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 2)                              
	
	aRetTime		:= LocalToUTC ( DTOS(dDtEnd), cHorEnd )//ExecInClient( 400, {"LocalTimetoUTC", DTOS(dDtEnd), cHorEnd} )
	cDtTimeEnd 		:= ConvDateTime(STOD(aRetTime[1]), aRetTime[2], 2)  
EndIf 

If cVersaoExchange <> "2007" 
	cPOSTParam 	+= 	'<?xml version="1.0"?>'
	cPOSTParam 	+= 	'<g:searchrequest xmlns:g="DAV:">'
	cPOSTParam 	+= 	'<g:sql>SELECT "DAV:href",'
	cPOSTParam 	+= 	' "DAV:displayname",'
	cPOSTParam 	+= 	' "urn:schemas:calendar:lastmodified",'
	cPOSTParam 	+= 	' "urn:schemas:calendar:busystatus",'
	cPOSTParam 	+= 	' "urn:schemas:calendar:uid",'
	cPOSTParam 	+= 	' "urn:schemas:calendar:timezone",'
	cPOSTParam 	+= 	' "urn:schemas:calendar:timezoneid",'
	cPOSTParam 	+= 	' "urn:schemas:httpmail:subject",'
	cPOSTParam 	+= 	' "urn:schemas:calendar:dtstart",'
	cPOSTParam 	+= 	' "urn:schemas:calendar:dtend", ' 
	cPOSTParam 	+= 	' "urn:schemas:httpmail:textdescription",'
	cPOSTParam 	+= 	' "urn:schemas:calendar:location",'
	cPOSTParam 	+= 	' "urn:schemas:httpmail:to",'
	cPOSTParam 	+= 	' "urn:schemas:httpmail:cc",'
	cPOSTParam 	+= 	' "urn:schemas:httpmail:bcc" '
	cPOSTParam 	+= 	' FROM Scope(' + "'SHALLOW TRAVERSAL OF " + '"'+ Alltrim(cURLComp) + '"' + "'" +')'
	cPOSTParam 	+= 	' WHERE ("DAV:ishidden" = false) AND'
	If Empty(cEMLName)
		cPOSTParam 	+= 	' ("urn:schemas:calendar:dtstart" &gt; ' + "'"+Alltrim(cDtTimeStart)+"'" 
		cPOSTParam 	+= 	' AND "urn:schemas:calendar:dtend" &lt; '+ "'"+Alltrim(cDtTimeEnd)+"') OR" 
		cPOSTParam 	+= 	' ("urn:schemas:calendar:dtstart" &gt; ' + "'"+Alltrim(cDtTimeStart)+"'" 
		cPOSTParam 	+= 	' AND "urn:schemas:calendar:dtstart" &lt; '+ "'"+Alltrim(cDtTimeEnd)+"') OR" 
		cPOSTParam 	+= 	' ("urn:schemas:calendar:dtend" &gt; ' + "'"+Alltrim(cDtTimeStart)+"'" 
		cPOSTParam 	+= 	' AND "urn:schemas:calendar:dtend" &lt; '+ "'"+Alltrim(cDtTimeEnd)+"')" 
	Else
		cPOSTParam 	+= 	' ("DAV:displayname" = ' +"'"+Alltrim(cEMLName)+"'"+')'
	EndIf
	cPOSTParam 	+= 	' ORDER BY "urn:schemas:calendar:dtstart"'
	cPOSTParam 	+= 	' ASC </g:sql></g:searchrequest>'
	
	aadd(aHeadOut,'Content-Type: text/xml')
	HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
	XMLRet := Httpquote(cURLComp,"SEARCH","",cPOSTParam,,aHeadOut,@XMLHeadRet)
	
	If ErrorRet$(XMLHeadRet)
		cMsgRet := STR0003 //"Não foi possivel encontrado servidor Exchange."
	 	lRet	:= .F.
		Return({lRet,cMsgRet,aRet})
	EndIF
	
	If XMLRet <> NIL
		//Apontamento nao encontrado
		oObject := XmlParser(XMLRet, "_", @cError, @cWarning)
		If Empty(cError) 
			If Type("oObject:_A_MULTISTATUS:_A_RESPONSE") != "U"   
				If Valtype(oObject:_A_MULTISTATUS:_A_RESPONSE)=="A"
					For nY:=1 to Len(oObject:_A_MULTISTATUS:_A_RESPONSE)	
		   			   If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT[1]:_A_PROP:_E_TO") != "U"
			   			   cTO := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_E_TO:TEXT) 
					   Else
			   			   cTO := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[2]:_A_PROP:_E_TO:TEXT) 
					   EndIF
	
		   			   If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT[1]:_A_PROP:_E_CC") != "U"
			   			   cCC := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_E_CC:TEXT) 
					   Else
			   			   cCC := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[2]:_A_PROP:_E_CC:TEXT) 
					   EndIF
	
		   			   If Type("oObject:_A_MULTISTATUS:_A_RESPONSE["+Alltrim(Str(nY))+"]:_A_PROPSTAT[1]:_A_PROP:_E_BCC") != "U"
			   			   cBCC := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_E_BCC:TEXT) 
					   Else
			   			   cBCC := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[2]:_A_PROP:_E_BCC:TEXT) 
					   EndIF
	                            
						AADD(aRet,{Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_A_HREF:TEXT),;
					   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_A_DISPLAYNAME:TEXT),;
					   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_D_DTEND:TEXT),;
					   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_D_DTSTART:TEXT),;
					   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_D_BUSYSTATUS:TEXT),;
					   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_D_LASTMODIFIED:TEXT),;
					   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_D_LOCATION:TEXT),;
					   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_D_UID:TEXT),;
					   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_E_TEXTDESCRIPTION:TEXT),;
					   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE[nY]:_A_PROPSTAT[1]:_A_PROP:_E_SUBJECT:TEXT),;
								   cTo,;	
					   			   cCC,;
					   			   cBCC})	
					Next nY
				Else
	
	   			   If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_E_TO") != "U"
		   			   cTO := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_E_TO:TEXT) 
				   Else
		   			   cTO := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[2]:_A_PROP:_E_TO:TEXT) 
				   EndIF
	
	   			   If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_E_CC") != "U"
		   			   cCC := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_E_CC:TEXT) 
				   Else
		   			   cCC := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[2]:_A_PROP:_E_CC:TEXT) 
				   EndIF
	
	   			   If Type("oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_E_BCC") != "U"
		   			   cBCC := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_E_BCC:TEXT) 
				   Else
		   			   cBCC := Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[2]:_A_PROP:_E_BCC:TEXT) 
				   EndIF
	
					AADD(aRet,{Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_A_HREF:TEXT),;
				   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_A_DISPLAYNAME:TEXT),;
				   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_D_DTEND:TEXT),;
				   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_D_DTSTART:TEXT),;
				   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_D_BUSYSTATUS:TEXT),;
				   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_D_LASTMODIFIED:TEXT),;
				   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_D_LOCATION:TEXT),;
				   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_D_UID:TEXT),;
				   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_E_TEXTDESCRIPTION:TEXT),;
				   			   Alltrim(oObject:_A_MULTISTATUS:_A_RESPONSE:_A_PROPSTAT[1]:_A_PROP:_E_SUBJECT:TEXT),;
				   			   cTO,; 
				   			   cCC,;
				   			   cBCC})	
				EndIf
			EndIf
		Else
			cMsgRet := STR0009 + Alltrim(cError) //"Erro no XML: "
			lRet := .F.
		EndIF
	Else
		cMsgRet := STR0010 + Alltrim(XMLHeadRet)  //"Erro na pesquisa: "
		lRet := .F.
	Endif
Else
	EX07_Task3(cUsuario,cSenha)
	cMsgRet := STR0021 //"Agendas enviadas com sucesso ao Exchange"
 	lRet	:= .T.
	Return({lRet,cMsgRet,aRet})
EndIf

Return({lRet,cMsgRet,aRet})    

//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Function ExgDelAppointment(cUsuario, cSenha, cUrl, cEmlName, cCodLang) 

Local cURLComp		:= ""
Local aHeadOut		:= {}     
Local XMLHeadRet    := ""
Local XMLRet        := NIL
Local lRet			:= .T.
Local cMsgRet		:= STR0017 //"Agenda excluida com sucesso."
Local ErrorRet		:= "HTTP/1.1 404 Resource Not Found"

Default cCodLang	:= "en_US"

If Empty(cCodLang)
	cCodLang := "en_US"
EndIf

If 	Empty(cUsuario) 	.or.;
	Empty(cSenha) 		.or.;
	Empty(cUrl) 		.or.;
	Empty(cEmlName)     

	cMsgRet	:= STR0002 //"Existem campos obrigatorios que não foram preenchidos."
	lRet	:= .F.
	Return({lRet,cMsgRet})

EndIf  

If Lower(cCodLang) == Lower("pt_BR")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Calend%C3%A1rio/"+Alltrim(cEmlName)
ElseIf Lower(cCodLang) == Lower("en_US")
	cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Calendar/"+Alltrim(cEmlName)
EndIf

HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
XMLRet := Httpquote(cURLComp,"DELETE","","",,aHeadOut,@XMLHeadRet)     

If XMLRet == NIL
	cMsgRet	:= STR0003 //"Não foi possivel encontrado servidor Exchange."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf	
      
If ErrorRet$(XMLHeadRet)
	cMsgRet	:= STR0018 + Alltrim(cEmlName) + STR0019   //"Item de agenda "###"não foi encontrada."
	lRet	:= .F.
	Return({lRet,cMsgRet})
EndIf   

Return({lRet,cMsgRet})  
    

//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Function ExgValUser(cUsuario, cSenha, cUrl, cCodLang) 

Local lRet			:= .T.
Local aHeadOut		:= {}
Local XMLHeadRet	:= ""  
Local XMLRet  		:= NIL
Local cPOSTParam 	:= ''
Local cURLComp		:= ""  
Local cMensRet		:= ""
Local cVersaoExchange := GetMv("MV_VEREXCH",,"")

Default cCodLang := "en_US"

If Empty(cCodLang)
	cCodLang := "en_US"
EndIf

If cVersaoExchange <> "2007" 
	
	If Lower(cCodLang) == Lower("pt_BR")
		cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Calend%C3%A1rio/"
	ElseIf Lower(cCodLang) == Lower("en_US")
		cURLComp	:= "http://"+ALltrim(cUrl)+"/exchange/"+Alltrim(cUsuario)+"/Calendar/"
	EndIf
		                                                         
	cPOSTParam 	+= 	'<?xml version="1.0"?>'
	cPOSTParam 	+= 	'<g:searchrequest xmlns:g="DAV:">'
	cPOSTParam 	+= 	'<g:sql>SELECT "DAV:href" '
	cPOSTParam 	+= 	' FROM Scope(' + "'SHALLOW TRAVERSAL OF " + '"'+ Alltrim(cURLComp) + '"' + "'" +')'
	cPOSTParam 	+= 	' WHERE ("DAV:ishidden" = false) AND '
	cPOSTParam 	+= 	' ("DAV:displayname" = ' +"'"+"teste.eml"+"'"+')'
	cPOSTParam 	+= 	' </g:sql></g:searchrequest>'
	
	aadd(aHeadOut,'Content-Type: text/xml')
	HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
	XMLRet := Httpquote(cURLComp,"SEARCH","",cPOSTParam,,aHeadOut,@XMLHeadRet)  
	
	If XMLRet==NIL
		lRet	:= .F.
		cMensRet	:= STR0004
	ElseIf "401 Unauthorized"$XMLHeadRet
		lRet	:= .F.
		cMensRet	:= STR0004
	EndIF	

Else
	HttpSetPass(Alltrim(cUsuario),ALltrim(cSenha))
	cMensRet := ""
EndIf

Return({lRet,cMensRet})
    
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
Static Function ConvDateTime(dDate, cTime, cType)

Local cRet	:= ""

If cType == 1		//DateTime.tz
	cRet	:= Strzero(Year(dDate),4)+"-"+Strzero(Month(dDate),2)+"-"+Strzero(Day(dDate),2)+"T"+cTime+".000Z"                               
ElseIf cType == 2	//DateTIme Search
	cRet	:= Strzero(Year(dDate),4)+"/"+Strzero(Month(dDate),2)+"/"+Strzero(Day(dDate),2)+" " + cTime                               
ElseIf cType == 3	//DateTIme Search Task
	cRet	:= Strzero(Year(dDate),4)+"-"+Strzero(Month(dDate),2)+"-"+Strzero(Day(dDate),2)+" " + cTime                               
EndIf

Return cRet
