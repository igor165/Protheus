#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PWSR000PRW.CH"

/*************************************************************/
Web Function PWSR000()	//Login - CPF / SENHA / Confirmacao
	Local cHtml := ""
	Local oObj 
	Local oObjCfg
	      
	Public	cPaisLoc	   

	WEB EXTENDED INIT cHtml
		If Empty(HttpSession->cCurricCpf) 
			oObjCfg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New()) 
			WsChgUrl(@oObjCfg,"CFGDICTIONARY.apw")

			oObjCfg:GETPARAM( "MSALPHA", "MV_PAISLOC" )
			cPaisLoc:=oObjCfg:cGETPARAMRESULT
			
			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New()) 
			WsChgURL(@oObj,"RHCURRICULUM.APW")      

			oObj:ValidFieldPos("SQG", "QG_QTDEFIL")
			
			
			If !oObj:LVALIDFIELDPOSRESULT			
				RHALERT( PWSGetWSError(), STR0018, STR0020, "W_PWSR00C.APW" )	//"Atenção"###"Campo QG_QTDEFIL inexistente, favor aplicar o compatibilizador: <br> SIGARSP - 06- Geração das tabelas RS0 e RS1 para configuração de campos do Portal"			
			Else
				oObj:ValidFieldPos("SQG", "QG_TPCURRI")
				If !oObj:LVALIDFIELDPOSRESULT			
					RHALERT( PWSGetWSError(), STR0018, STR0019, "W_PWSR00C.APW" )	//"Atenção"###"Campo QG_TPCURRI inexistente, favor aplicar o compatibilizador: <br> SIGARSP - 07-Atualizacoes na tabela SQG - Curriculo (novo campo Tipo de Currículo)"
				Else
					cHtml += ExecInPage( "PWSR000" ) 
				EndIf
			EndIf
		Else
			W_PWSR010B()
		EndIf		
	WEB EXTENDED END
Return cHtml
   
/*************************************************************/
Web Function PWSR001()  //Tela Principal
	Local oParam						:= Nil
	Local cHtml 						:= ""
	HttpSession->cTipoPortal	:= '9'
	
	WEB EXTENDED INIT cHtml
			oParam := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
			WsChgURL(@oParam,"CFGDICTIONARY.APW")                                
			cHtml += ExecInPage( "PWSR001" )
	WEB EXTENDED END
Return cHtml

/*************************************************************/
//	Juliana Barros - 28/01/2005
//   Envio de senha pelo CPF Digitado
Web Function PWSR002() 
	Local cHtml 		:= ""     
	Local cMailAuth		:= ""
	Local cMailConta	:= ""
	Local cMailServer	:= ""
	Local cMailSenha	:= ""
	Local cServer		:= ""
	Local cSubject  	:= STR0006  
	Local lMailAuth		:= .F.
	Local lAutentic		:= .T.
	Local lOk			:= .F.
	Local lResult		:= .T.  
	Local lSSL			:= .F.
	Local lTLS			:= .F.
	Local nPos			:= 0    
	Local oEmail 		:= NIL
	Local oParam        := Nil
	Local oMServer		:= Nil	 
 	local nSMTPPort		:= 0
	local oMessage 		:= Nil
	Local nErr			:= 0
	Local cMsgErr		:= ""

	WEB EXTENDED INIT cHtml
		oEmail := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgURL(@oEmail,"RHCURRICULUM.APW")
		 
		oParam := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgUrl(@oParam,"CFGDICTIONARY.apw")
		
		If oParam:GETPARAM( "MSALPHA", "MV_RHAUTEN" )
			lMailAuth	:= Iif(Valtype(oParam:cGETPARAMRESULT)== "C",&(oParam:cGETPARAMRESULT) ,oParam:cGETPARAMRESULT)
		EndIf  
	
		If oParam:GETPARAM( "MSALPHA", "MV_RELSSL" )
			lSSL	:= Iif(Valtype(oParam:cGETPARAMRESULT)== "C",&(oParam:cGETPARAMRESULT) ,oParam:cGETPARAMRESULT)
		EndIf  
		
		If oParam:GETPARAM( "MSALPHA", "MV_RELTLS" )
			lTLS	:= Iif(Valtype(oParam:cGETPARAMRESULT)== "C",&(oParam:cGETPARAMRESULT) ,oParam:cGETPARAMRESULT)
		EndIf  	
		
		HttpPost->cCurricCpf := strTran(strTran(HttpPost->cCurricCpf,".",""),"-","")
		
		//CONSULTA E-MAIL CADASTRADO
		If oEmail:GETEMAIL( "MSALPHA", HttpPost->cCurricCpf )
			If Empty(oEmail:oWSGETEMAILRESULT:cEmail) //SE NAO EXISTIR E-MAIL
				RHALERT( "", STR0001, STR0002, "W_PWSR00D.APW" )	//"Erro"###"E-mail não cadastrado."		
			ElseIf Empty(oEmail:oWSGETEMAILRESULT:cEmailServ) .Or. Empty(oEmail:oWSGETEMAILRESULT:cEmailAccount);
		 		.Or. Empty(oEmail:oWSGETEMAILRESULT:cEmailPass)
				RHALERT( "", STR0001, STR0011, "W_PWSR00D.APW" )	//"Erro"###"Servidor, Conta ou Senha de e-mail nao configurados."
			Else //SE EXISTIR MANDA E-MAIL COM A SENHA DE ACESSO   
				cMailConta	:= oEmail:oWSGETEMAILRESULT:cEmailAccount
				cMailSenha  := oEmail:oWSGETEMAILRESULT:cEmailPass
				cMailServer := oEmail:oWSGETEMAILRESULT:cEmailServ
		
				oMServer := tMailManager():New() 
			
				If ( nAt := At(":", cMailServer) ) > 0
					nSMTPPort := Val(Substr(cMailServer, nAt+1, nAt + 2))
					cMailServer := Substr(cMailServer, 1, nAt - 1)
				Endif			
	
				oMServer:setUseSSL(lSSL)
				oMServer:setUseTLS(lTLS)
	
				oMServer:INIT("", cMailServer, cMailConta, cMailSenha, , nSMTPPort)
			
				nErr:= oMServer:smtpConnect(cMailAuth, cMailSenha)
 				if nErr <> 0
					Alert("[ERROR]Falha ao conectar: " + oMServer:getErrorString(nErr))
					oMServer:smtpDisconnect()
				Endif
				If lMailAuth
					nErr := oMServer:smtpAuth(cMailConta, cMailSenha)
					If nErr <> 0
						If ( nAt := At("@", cMailConta) ) > 0
							cMailAuth	:= Substr(cMailConta, 1, nAt - 1)
							nErr	:= oMServer:smtpAuth( cMailAuth, cMailSenha )
						Endif					
					EndIf
				EndIf
					
				If nErr == 0							
					cBody := "<body><table width=100% border=0 cellspacing=1 cellpadding=1>"
		  			cBody += "<tr><td colspan=2><font color=#000000 size=2 face='Verdana, Arial, Helvetica, sans-serif'><strong>"+STR0003+"</strong></font></td>" //"Senha de Acesso ao Currículo Pessoal"
		  			cBody += "<tr><td colspan=2>&nbsp;</td></tr>"  			
		  			cBody += "<tr><td width=12%><font color=#000000 size=2 face='Verdana, Arial, Helvetica, sans-serif'><strong>"+STR0004+"</strong></font></td>"	//"Senha:"
		    		cBody += "<td width=88%><font color=#000000 size=2 face='Verdana, Arial, Helvetica, sans-serif'>" + oEmail:oWSGETEMAILRESULT:cPass + "</font></td>"
		  			cBody += "</tr></table></body>"
		      
					//Apos a conexão, crio o objeto da mensagem
			      	oMessage := TMailMessage():New()
			      	//Limpo o objeto
			      	oMessage:Clear()
			      	//Populo com os dados de envio
					oMessage:cFrom		:= cMailConta
					oMessage:cTo		:= oEmail:oWSGETEMAILRESULT:cEmail
					oMessage:cSubject	:= cSubject
					oMessage:cBody		:= cBody
			      	
			      	//Envio o e-mail
			      	nErr := oMessage:send( oMServer )
			      	If nErr == 0
						HttpPost->cMsg := STR0007
			      	Else
						// Desconecta do Servidor e Informa erro se não conseguir desconectar SMTP
				      	If oMServer:SmtpDisconnect() != 0
				      		Conout( "Erro ao disconectar do servidor SMTP" )
				      	EndIf
						cMsgErr:= oMServer:GetErrorString( nErr )
						HttpPost->cMsg := "<br>"+STR0008+ cMsgErr //"Não foi possível enviar o e-mail: "
			      		Conout( "Erro ao enviar o e-mail"+ cMsgErr )
				    EndIf
				Else   
					oMServer:smtpDisconnect()
					cMsgErr:= oMServer:GetErrorString( nErr )
	      			Conout( "Erro ao enviar o e-mail"+ cMsgErr )
					HttpPost->cMsg := "<br>"+STR0008 + cMsgErr //"Não foi possível enviar o e-mail: "		
				//fim do envio de email 
				EndIf
				oMServer:smtpDisconnect()	
				
				RHALERT( STR0009, STR0010, HttpPost->cMsg, "W_PWSR00D.APW" ) //"Interno"###"Mensagem"	*/			
			EndIf
		Else
			RHALERT( PWSGetWSError(), STR0001, "cMsg", "W_PWSR00D.APW" )	//"Erro"
		EndIf 
	WEB EXTENDED END
Return cHtml


/*************************************************************/
Web Function PWSR00A()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml	
		cHtml += ExecInPage( "PWSR00A" )	
	WEB EXTENDED END	
Return cHtml

/*************************************************************/
Web Function PWSR00B()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml
		cHtml += ExecInPage( "PWSR00B" )
	WEB EXTENDED END
Return cHtml

/*************************************************************/
Web Function PWSR00C()
	Local cHtml := ""
	Local cIdiom:= FWRetIdiom()        //Retorna Idioma Atual
	Public lLanguageFile
	Default lLanguageFile := .F.	


	// Cria o arquivo PpLanguage.JS
	If !lLanguageFile
		lLanguageFile := CriaJsLang()
	EndIf	
	              
	WEB EXTENDED INIT cHtml

		If cIdiom == 'es'       
			cHtml := "<script>window.location='htmls-rh/PwsrAbertura-esp.htm';</script>"				
		ElseIf cIdiom == 'en' 
			cHtml := "<script>window.location='htmls-rh/PwsrAbertura-ing.htm';</script>"		
		Else
			cHtml := "<script>window.location='htmls-rh/pwsrabertura.htm';</script>"				
		Endif

	WEB EXTENDED END
Return cHtml

/*************************************************************/
Web Function PWSR00D()	//Login - CPF / SENHA
	Local cHtml := ""
	Local oObj   
	Local oObjCfg   
	Public	cPaisLoc	   
		
	WEB EXTENDED INIT cHtml 
		If Empty(HttpSession->GetCurriculum)
			oObjCfg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
			WsChgUrl(@oObjCfg,"CFGDICTIONARY.apw")
			oObjCfg:GETPARAM( "MSALPHA", "MV_PAISLOC" )
			cPaisLoc:=oObjCfg:cGETPARAMRESULT
			
			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
			WsChgURL(@oObj,"RHCURRICULUM.APW")
			
			oObj:ValidFieldPos("SQG", "QG_QTDEFIL")
			     
			If !oObj:LVALIDFIELDPOSRESULT			
				RHALERT( PWSGetWSError(), STR0018, STR0020, "W_PWSR00C.APW" )	//"Campo QG_QTDEFIL inexistente, favor aplicar o compatibilizador: <br> SIGARSP - 06- Geração das tabelas RS0 e RS1 para configuração de campos do Portal"			
			Else
				oObj:ValidFieldPos("SQG", "QG_TPCURRI")
				If !oObj:LVALIDFIELDPOSRESULT			
					RHALERT( PWSGetWSError(), STR0018, STR0019, "W_PWSR00C.APW" )	//"Atenção"###"Campo QG_TPCURRI inexistente, favor aplicar o compatibilizador: <br> SIGARSP - 07-Atualizacoes na tabela SQG - Curriculo (novo campo Tipo de Currículo)"
				Else
					cHtml += ExecInPage( "PWSR00D" )
				EndIf
			EndIf
		Else
			W_PWSR010B()
		EndIf
	WEB EXTENDED END	
Return cHtml

/*************************************************************/
Web Function PWSR00E()	//Confirma Logout ?
	Local cHtml := ""

	WEB EXTENDED INIT cHtml 
			cHtml += ExecInPage( "PWSR00E" )
	WEB EXTENDED END						
Return cHtml

/*************************************************************/
Web Function PWSR00EConfirm()	//Logout - CPF / SENHA
	Local cHtml := ""
	HttpSession->cCurricCpf		:= ''
	HttpSession->cCurricPass	:= ''
	HttpSession->GetCurriculum	:= {}
	HttpSession->ShowVacancy	:= {}
	HttpSession->oRequests 		:= {}
	
	cHtml := W_PWSR00C()
Return cHtml


/***************************************************************************/
// Funcao identica a PWSHTMLALERT() Porem nao utiliza (Start "Insite")
Function RHALERT( cMsgInternal, cTopo, cMsg, cPagVolta )
	Local cMsgError := PWSGetWSError( cMsgInternal )
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml //START "InSite"
		If Empty( HttpSession->_HTMLERRO )
			HttpSession->_HTMLERRO := { NIL, NIL, NIL }
		EndIf
		
		If !Empty( cMsgError )
			cMsg := cMsgError
		EndIf
		
		HttpSession->_HTMLERRO[1] := cTopo
		HttpSession->_HTMLERRO[2] := cMsg
		HttpSession->_HTMLERRO[3] := cPagVolta
		
		cHtml += ExecInPage( "PWSRHERR" )`	
	WEB EXTENDED END
Return cHtml
         

/************************************************************/
// Juliana Barros - 02/02/2005
// Modulo que chama tela de fale conosco
Web Function PWSRFALE()                    
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml //START "InSite"
		cHtml := ExecInPage("PWSRFALE")	
	WEB EXTENDED END
Return cHtml


/************************************************************/
// Juliana Barros - 02/02/2005
// Modulo que chama tela de fale conosco
Web Function PWSREMAIL()                    
	Local cHtml 		:= ""
	Local oEmail 		:= ""
	Local cMailAuth		:= ""
	Local cMailConta	:= ""
	Local cMailDest		:= ""
	Local cMailSenha	:= ""
	Local cMailServer	:= ""
	Local nAt			:= 0  	
	Local lAutentic		:= .T.
	Local lMailAuth		:= .F.   
	Local lSSL			:= .F.
	Local lTLS			:= .F.
	Local oParam		      
	Local oMServer		:= Nil	 
 	local nSMTPPort		:= 0
	local oMessage 		:= Nil
	Local nErr			:= 0
	Local cMsgErr		:= ""

	
	WEB EXTENDED INIT cHtml
	
	oEmail := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oEmail,"RHCURRICULUM.APW") 
	
	oParam := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
	WsChgUrl(@oParam,"CFGDICTIONARY.apw")
	
	If oParam:GETPARAM( "MSALPHA", "MV_RHAUTEN" )
		lMailAuth	:= Iif(Valtype(oParam:cGETPARAMRESULT)== "C",&(oParam:cGETPARAMRESULT) ,oParam:cGETPARAMRESULT)
	EndIf  

	If oParam:GETPARAM( "MSALPHA", "MV_RELSSL" )
		lSSL	:= Iif(Valtype(oParam:cGETPARAMRESULT)== "C",&(oParam:cGETPARAMRESULT) ,oParam:cGETPARAMRESULT)
	EndIf  
	
	If oParam:GETPARAM( "MSALPHA", "MV_RELTLS" )
		lTLS	:= Iif(Valtype(oParam:cGETPARAMRESULT)== "C",&(oParam:cGETPARAMRESULT) ,oParam:cGETPARAMRESULT)
	EndIf  	
    
	//CONSULTA E-MAIL CADASTRADO
	If oEmail:GETEMAIL2( "MSALPHA" )
		If Empty(oEmail:oWSGETEMAIL2RESULT:cEmailServ) .Or. Empty(oEmail:oWSGETEMAIL2RESULT:cEmailAccount);
		 	.Or. Empty(oEmail:oWSGETEMAIL2RESULT:cEmailPass)
			RHALERT( "", STR0001, STR0011, "W_PWSR00D.APW" )	//"Erro"###"Servidor, Conta ou Senha de e-mail nao configurados."
		Else       
			cMailConta	:= oEmail:oWSGETEMAIL2RESULT:cEmailAccount
			cMailDest	:= If( !Empty(oEmail:oWSGETEMAIL2RESULT:cEmail), oEmail:oWSGETEMAIL2RESULT:cEmail, oEmail:oWSGETEMAIL2RESULT:cEmailAccount)
			cMailSenha  := oEmail:oWSGETEMAIL2RESULT:cEmailPass
			cMailServer := oEmail:oWSGETEMAIL2RESULT:cEmailServ
			
			oMServer := tMailManager():New() 
			
			If ( nAt := At(":", cMailServer) ) > 0
				nSMTPPort := Val(Substr(cMailServer, nAt+1, nAt + 2))
				cMailServer := Substr(cMailServer, 1, nAt - 1)
			Endif			

			// Usa SSL na conexao
			oMServer:setUseSSL(lSSL)
			
			// Usa TSL na conexao
			oMServer:setUseTLS(lTLS)

			oMServer:INIT("", cMailServer, cMailConta, cMailSenha, 0, nSMTPPort)

			nErr:= oMServer:smtpConnect(cMailConta, cMailSenha)
			if nErr <> 0
				Alert("[ERROR]Falha ao conectar: " + oMServer:getErrorString(nErr))
				oMServer:smtpDisconnect()
			Endif
			If lMailAuth
				nErr := oMServer:smtpAuth(cMailConta, cMailSenha)
				If nErr <> 0
					If ( nAt := At("@", cMailConta) ) > 0
						cMailAuth	:= Substr(cMailConta, 1, nAt - 1)
						nErr	:= oMServer:smtpAuth( cMailAuth, cMailSenha )
					Endif					
				EndIf
			EndIf
			
			If nErr == 0								
				
				cBody := "<body><table width=100% border=0 cellspacing=1 cellpadding=1>"
	  			cBody += "<tr><td colspan=2><font color=#000000 size=2 face='Verdana, Arial, Helvetica, sans-serif'><strong>"+STR0012+"</strong></font></td>" //"Fale Conosco"
	  			cBody += "<tr><td colspan=2>&nbsp;</td></tr>"  			
	  			cBody += "<tr><td width=13%><font color=#000000 size=2 face='Verdana, Arial, Helvetica, sans-serif'><strong>"+STR0013+"</strong></font></td>" //"De:"
	    		cBody += "<td width=87%><font color=#000000 size=2 face='Verdana, Arial, Helvetica, sans-serif'>" + HttpPost->cNome + "</font></td></tr>"
	  			cBody += "<tr><td valign='top'><font color=#000000 size=2 face='Verdana, Arial, Helvetica, sans-serif'><strong>"+STR0017+"</strong></font></td>" //"E-mail:"
	    		cBody += "<td><font color=#000000 size=2 face='Verdana, Arial, Helvetica, sans-serif'>" + HttpPost->cEmail + "</font></td></tr>"    		
	  			cBody += "<tr><td valign='top'><font color=#000000 size=2 face='Verdana, Arial, Helvetica, sans-serif'><strong>"+STR0014+"</strong></font></td>" //"Assunto:"
	    		cBody += "<td><font color=#000000 size=2 face='Verdana, Arial, Helvetica, sans-serif'>" + HttpPost->cComentario + "</font></td></tr>"    		
	  			cBody += "</table></body>"
	            
	          	//Apos a conexão, crio o objeto da mensagem
		      	oMessage := TMailMessage():New()
		      	//Limpo o objeto
		      	oMessage:Clear()
		      	//Populo com os dados de envio
				oMessage:cFrom		:= cMailConta
				oMessage:cTo		:= cMailDest
				oMessage:cSubject	:= STR0012
				oMessage:cBody		:= cBody
		      	
		      	nErr := oMessage:send( oMServer )
		      	If nErr == 0
				    //Envio o e-mail
		      		HttpPost->cMsg := STR0015
		      	Else
					// Desconecta do Servidor e Informa erro se não conseguir desconectar SMTP
			      	If oMServer:SmtpDisconnect() != 0
			      		Conout( "Erro ao disconectar do servidor SMTP" )
			      	EndIf
					cMsgErr:= oMServer:GetErrorString( nErr )
					HttpPost->cMsg := "<br>"+STR0008+ cMsgErr //"Não foi possível enviar o e-mail: "
		      		Conout( "Erro ao enviar o e-mail"+ cMsgErr )
			    EndIf
			Else
				// Desconecta do Servidor e Informa erro da desconexao
				oMServer:smtpDisconnect()
				cMsgErr:= oMServer:GetErrorString( nErr )
				HttpPost->cMsg := "<br>"+STR0008+ cMsgErr //"Não foi possível enviar o e-mail: "
	      		Conout( "Erro ao enviar o e-mail"+ cMsgErr )
	      	EndIf
	      	
	      	RHALERT( STR0009, STR0010, HttpPost->cMsg, "W_PWSRFALE.APW" ) //"Interno"###"Mensagem"	
		EndIf
	
		oMServer:smtpDisconnect()		
	EndIf							
	
	WEB EXTENDED END
Return cHtml


//Monta o Menu
Function GetMnuCandidato( cPrtCode )
	Local nI 	:= 0
	Local nTam 	:= 0
	Local nPos 	:= 0
	Local aTemp := {}
	Local oTemp := NIL
	
	If !Empty( cPrtCode )
		HttpSession->PRT_CODE := cPrtCode
	Endif
	
	HttpSession->_aMENU 	:= {}
	oObj 					:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRhMenu"), WSRhMenu():New())
	
	WsChgUrl( @oObj, "RhMenu.apw" )
	
	If oObj:PRTHEADER( "LOGINMENU" )
		HttpSession->_MENU_HEADER := oObj:oWSPRTHEADERRESULT:oWSBRWHEADER
	Endif
	
	If !Empty( HttpSession->PRT_CODE )
		oObj:cPORTALCODE := cPrtCode
		
		If oObj:PRTLISTMENU()
			oTemp := oObj:oWSPRTLISTMENURESULT:oWSLOGINMENU
			
			nTam := Len( oTemp )
			aSort( oTemp,,, { |x1, x2| x1:cSUPERIORCODE + str(x1:nOrder) < x2:cSUPERIORCODE + str(x2:nOrder) } )
			
			For nI := 1 To nTam
				If Empty( oTemp[nI]:cSUPERIORCODE )
					If !oTemp[nI]:lMENUISBLOCKED	 //AI8_MSBLQL
						oTemp[nI]:cDESCRIPTION	 := AllTrim( oTemp[nI]:cDESCRIPTION )
						oTemp[nI]:cWEBSERVICE	 := AllTrim( oTemp[nI]:cWEBSERVICE )
						
						AAdd( HttpSession->_aMENU, { oTemp[nI],{} } )
					EndIf
					AAdd( aTemp, {oTemp[nI]:cCODE, oTemp[nI]:lMENUISBLOCKED} )
				ElseIf ( nPos := AScan( aTemp, {|x| x[1] == oTemp[nI]:cSUPERIORCODE} ) ) > 0   //PAI / FILHO
					If !aTemp[nPos,2] .And. !oTemp[nI]:lMENUISBLOCKED
						oTemp[nI]:cPROCEDURECALL 	:= IIF( Empty( oTemp[nI]:cPROCEDURECALL ), "#", AllTrim( oTemp[nI]:CPROCEDURECALL ) )
						oTemp[nI]:cDESCRIPTION		:= AllTrim( oTemp[nI]:cDESCRIPTION )
						oTemp[nI]:cWEBSERVICE		:= AllTrim( oTemp[nI]:cWEBSERVICE )
						
						nPosMenu := AScan(HttpSession->_aMENU, {|x| x[1]:CCODE == oTemp[nI]:cSUPERIORCODE})
						AAdd( HttpSession->_aMENU[nPosMenu][2], oTemp[nI] )
					EndIf
				Else
					conout( STR0016 ) //"Erro: Retorno de WebService invalido"
					Return {}
				Endif
			Next
		Else
			Return {}
		Endif
	Endif
Return HttpSession->_aMENU

/*************************************************************/
Web Function PWSRF3()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml
		HttpSession->USR_INFO := {	"MSALPHA", "MSALPHA", "MSALPHA"}
		W_PWSXF3000()	
	WEB EXTENDED END
Return cHtml

/*************************************************************/
Web Function PWSRPWD()	//Login - Alterar Senha
Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml
	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	HttpSession->cCurricCpf 	:= DECODE64(HttpPost->cCurricCpf)
	HttpSession->cCurricPass 	:= DECODE64(HttpPost->cCurricPass)

	If !Empty( HttpSession->cCurricCpf ) //.And. !Empty( HttpSession->cCurricPass ) //Vem do PWSR000
		If oObj:GetCurriculum( "MSALPHA", HttpSession->cCurricCpf, HttpSession->cCurricPass, 2 )

			HttpSession->GetCurriculum 	:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC1}
			HttpSession->GETTABLES 		:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC2}

			If oObj:GetConfigField('SQG')
				/*  
					Cada objeto contem 2 caracteres S ou N 
					Primeiro caractere se e ou não obrigatorio S ou N
					Segundo caracter se e ou não visual na tela S ou N     
				*/
            	HttpSession->oConfig	:= oObj:OWSGETCONFIGFIELDRESULT
			EndIf
			
			If AllTrim(HttpPost->cCurricPass) == "654321"
	           HttpPost->cScript := "<script>alert('STR0001')</script>" //"Troque sua senha de acesso."
    	    EndIf

			cHtml += ExecInPage( "PWSRALTSENHA" )

		Else
			Return RHALERT( "", STR0018, STR0003, "W_PWSR00C.APW" ) //"Portal Candidato"###"CPF ou Senha invalido."

		EndIf
	Else
		Return RHALERT( "", STR0018, STR0004, "W_PWSR00C.APW" ) //"Portal Candidato"###"CPF deve ser informado."

	EndIf

WEB EXTENDED END

Return cHtml

/*************************************************************/
Web Function PWSRALTSENHA()
Local cHtml     := ""
Local cNovaSenha := "" 
Local oObj	
Local oObjCfg   
Public	cPaisLoc	   
		
	WEB EXTENDED INIT cHtml 
		If Empty(HttpSession->GetCurriculum)
			oObjCfg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New()) 
			WsChgUrl(@oObjCfg,"CFGDICTIONARY.apw")
			oObjCfg:GETPARAM( "MSALPHA", "MV_PAISLOC" )
			cPaisLoc:=oObjCfg:cGETPARAMRESULT
			
			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
			WsChgURL(@oObj,"RHCURRICULUM.APW")
			
			oObj:ValidFieldPos("SQG", "QG_QTDEFIL")
			     
			If !oObj:LVALIDFIELDPOSRESULT			
				RHALERT( PWSGetWSError(), STR0018, STR0020, "W_PWSR00C.APW" )	//"Campo QG_QTDEFIL inexistente, favor aplicar o compatibilizador: <br> SIGARSP - 06- Geração das tabelas RS0 e RS1 para configuração de campos do Portal"			
			Else
				oObj:ValidFieldPos("SQG", "QG_TPCURRI")
				If !oObj:LVALIDFIELDPOSRESULT			
					RHALERT( PWSGetWSError(), STR0018, STR0019, "W_PWSR00C.APW" )	//"Atenção"###"Campo QG_TPCURRI inexistente, favor aplicar o compatibilizador: <br> SIGARSP - 07-Atualizacoes na tabela SQG - Curriculo (novo campo Tipo de Currículo)"
				Else
					cHtml += ExecInPage( "PWSRPWD" )
				EndIf
			EndIf
		Else
			If	Empty(HttpPost->cSenhaAtual) .OR.;
				Empty(HttpPost->cNovaSenha)
					cHtml += ExecInPage("PWSRALTSENHA")
			Else 
				If HttpPost->cNovaSenha == HttpPost->cConfirmacao	
					oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
					WsChgURL(@oObj,"RHCURRICULUM.APW")
					If oObj:GetCurriculum( "MSALPHA", HttpSession->cCurricCpf, HttpPost->cSenhaAtual, 4, HttpPost->cNovaSenha )
						HttpSession->cCurricPass := HttpPost->cNovaSenha
		
						HttpSession->_HTMLERRO := {STR0022, "Senha alterada com sucesso!", "W_PWSRALTSENHA.APW"} //"Senha alterada com sucesso!"
						cHtml := ExecInPage("PWSAMSG")
					Else
						HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSRALTSENHA.APW"}
						cHtml := ExecInPage("PWSAMSG")
					EndIf
				Else
					HttpSession->_HTMLERRO := {"Erro", STR0023, "W_PWSRALTSENHA.APW"}//As senhas digitadas não coincidem.<br/>Digite novamente as senhas.
					cHtml := ExecInPage("PWSAMSG")
				EndIf
			EndIf
		EndIf
	WEB EXTENDED END
Return cHtml
