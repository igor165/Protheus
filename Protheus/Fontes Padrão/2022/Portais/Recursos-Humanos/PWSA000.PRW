#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PWSA000.CH"

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    13/04/2015        ³  295663   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/
/**************************************/
Web Function PWSA000()
	Local cHtml := ""
	Local oObj
	Local oOrg      
    Local oParam
	Local oWSFunc
	Local oRequest
	Local cEnrolmentID :=""
	Local nPos := If (ValType(HttpPost->SelMat) == "U" , IF (ValType(HttpSession->aMats) <> "U" .And. Len(HttpSession->aMats) == 1, 1 ,0 )  , Val(HttpPost->SelMat))
	Local cPart := If (nPos > 0 .And. ValType(HttpSession->aMats) <> "U" .And. Len(HttpSession->aMats) > 0, HttpSession->aMats[nPos]:cParticipantID , "")

	Private cFilAnt
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
		WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
		
		HttpSession->lGSP      := .F.
		HttpSession->c530Solic := "0"
		HttpSession->aUser 		:= nil
		httpPost->aAgenda := {}
		HttpSession->cPaisLoc	:= cPaisLoc
	    HttpSession->cChave := ""
		
		If !Empty( HttpSession->Login )
			If oObj:GETPARTICIPANT( cPart , HttpSession->Login, HttpSession->cAcessoPP )
				HttpSession->cParticipantID		:= oObj:oWSGETPARTICIPANTRESULT:CPARTICIPANTID
				HttpSession->cParticipantName	:= AllTrim(oObj:oWSGETPARTICIPANTRESULT:CPARTICIPANTNAME)
				HttpSession->Participant		:= oObj:oWSGETPARTICIPANTRESULT

                //Avalia Gestao Publica
				oParam := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMENU"), WSMENU():New())
                WsChgURL(@oParam, "MENU.APW")
                If oParam:GETRHPARAM( "MSALPHA", "MV_SIGAGFP" )
                 If cPaisLoc == "BRA"
                	HttpSession->cMVGPEGFP := oParam:cGETRHPARAMRESULT 
                 Else
                 	HttpSession->cMVGPEGFP := "1"
                 EndIf
                    If oParam:cGETRHPARAMRESULT >= "2" // Gestao Publica                  
                            If oParam:cGETRHPARAMRESULT <> "#"
                                HttpSession->lGSP := .T.
								oRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
								WsChgURL(@oRequest,"RHREQUEST.APW")
								
								If ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
									cEnrolmentID	:= HttpSession->RHMat
								EndIf		
								
								If Empty(HttpSession->cChave) .And.  oRequest:RetChaveFuncionario(cEnrolmentID,HttpSession->cParticipantID)
									HttpSession->cChave := oRequest:cRETCHAVEFUNCIONARIORESULT
								EndIf
							EndIf
                    Else
                        HttpSession->lGSP         := .F.
                    EndIf     
                EndIf      
                
                GetUser()
                
				oRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTRAININGTEST"), WSRHTRAININGTEST():New())
				WsChgURL(@oRequest,"RHTRAININGTEST.APW")
			
				oRequest:cFILIALFUNC    := HttpSession->aUser[2]
				oRequest:cTIPO		    := "2" //1=pagina de avaliação/2=mural de avisos
				oRequest:cMATRICULA     := HttpSession->aUser[3]
			   
			   	If oRequest:BRWAGENDA()
					httpPost->aAgenda := oRequest:oWSBRWAGENDARESULT:OWSTAGENDA
				EndIf
				
				hTtpSession->mvRefTrab := "FSR"
				oParam := nil
				oParam := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
				WsChgUrl(@oParam,"CFGDICTIONARY.apw")
								
				If oParam:GETPARAM("MSALPHA", "MV_REFTRAB")
					If Alltrim(oParam:cGETPARAMRESULT) <> ".F."
						hTtpSession->mvRefTrab := oParam:cGETPARAMRESULT
					EndIf
				EndIf     
			Else
				conout( PWSGetWSError() )
			EndIf
		EndIf	
		cHtml += ExecInPage( "PWSA000" )
	WEB EXTENDED END
Return cHtml

/*************************************************************/
Web Function PWSA00A()
Local cHtml := ""

WEB EXTENDED INIT cHtml
	cHtml += ExecInPage( "PWSA00A" )
WEB EXTENDED END

Return cHtml

/*************************************************************/
Web Function PWSA00B()
Local cHtml := ""

WEB EXTENDED INIT cHtml
	IF HTTPSession->RHSit == "D" 
	   cHtml += ExecInPage( "PWSA00E" )
	Else
	   cHtml += ExecInPage( "PWSA00B" )
	EndIf
WEB EXTENDED END

Return cHtml

Static Function GetUser()
Local oOrg

If Valtype(HttpSession->aUser) == "U"
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())

	WsChgURL(@oOrg, "ORGSTRUCTURE.APW")
	If !Empty(HTTPSession->Login)
		oOrg:cParticipantID	:= HTTPSession->Login
	Else
		oOrg:cParticipantID	:= HttpSession->cParticipantID
	EndIf
	oOrg:cVision				:= ""
	If ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
		oOrg:cRegistration	:= HttpSession->RHMat
		oOrg:cEmployeeFil    := HttpSession->RhFilMat
	EndIf

	If oOrg:GetEmployee()
		If len(oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee) > 0
			HttpSession->aUser := {	HttpSession->cParticipantID,;
			oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[1]:cEmployeeFilial,;
			oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[1]:cRegistration,;
			oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[1]:cEmployeeEmp}    
		Else
			HttpSession->aUser := {HttpSession->cParticipantID, "", "",""}
		Endif												
	Else
		HttpSession->aUser := {HttpSession->cParticipantID, "", "",""}  
	Endif
EndIf
Return


/*************************************************************/
Web Function PWSA00C()
Local cHtml	:= ""
Local aMenu	:= f_VldMenu(HttpSession->cMVGPEGFP) //IIf(HttpSession->lGSP, GetPrtMenu( "000011" ), GetPrtMenu( "000006" ))
Local cPag	:= ""
Local nTam	:= 0
Local nPos	:= 0
Local lHtm	:= .F.
Local oOrg
Local cIdiom:= FWRetIdiom()        //Retorna Idioma Atual

Private oMsg

If Len(aMenu) > 0
	cPag := AllTrim(aMenu[1][1]:cProcedureCall)
	nTam := Len(cPag)
	nPos := At("=",cPag)
	cPag := Subst(cPag, nPos+1 , nTam - nPos)
	lHtm := Upper(Right(cPag,3)) == "HTM"
EndIf

WEB EXTENDED INIT cHtml

		//Pega filial e matricula do participante
		HttpSession->aInfRotina := {}
	  	GetUser()
			
			//Verifica e Busca mensagens para o funcionario
			oWSFunc := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRHEMPLOYEEREGISTRATION"), WsRHEMPLOYEEREGISTRATION():New())

			WsChgURL(@oWSFunc, "RHEMPLOYEEREGISTRATION.apw")
    		oWSFunc:cEmployeeFil 	:= HttpSession->aUser[2] //Filial
			oWSFunc:cRegistration	:= HttpSession->aUser[3] //matricula
			If oWSFunc:GetMessage()
					oMsg := oWSFunc:oWSGetMessageResult
			EndIf
		 
			//Caso exista, carrega mensagens ao funcionario
			//Caso nao exista, carrega diretamente tela de abertura
			If ValType(oMsg) == "O" .AND. ((!Empty(oMsg:cEmployeeMessage)) .or. (!Empty(oMsg:cCompanyMessage)))
				cHtml := ExecInPage( "PWSA00D" )					
			Else
				If lHtm
					cHtml := "<script>window.location='"+cPag+"';</script>"
				Else
					If cIdiom == 'es'       
						cHtml := "<script>window.location='htmls-rh/Abertura_esp.htm';</script>"
					ElseIf cIdiom == 'en' 
						cHtml := "<script>window.location='htmls-rh/Abertura_eng.htm';</script>"
					Else
						cHtml := "<script>window.location='htmls-rh/Abertura.htm';</script>"		
					Endif
				EndIf
			EndIf			
WEB EXTENDED END
Return cHtml

/*************************************************************/
Web Function PWSA00D()
Local cHtml := ""
Local cPag  := ""
Local nTam  := 0
Local nPos  := 0
Local lHtm  := .F.
Local aMenu := f_VldMenu(HttpSession->cMVGPEGFP)
Local cIdiom:= FWRetIdiom()        //Retorna Idioma Atual

If Len(aMenu) > 0
	cPag := AllTrim(aMenu[1][1]:cProcedureCall)
	nTam := Len(cPag)
	nPos := At("=",cPag)
	cPag := Subst(cPag, nPos+1 , nTam - nPos)
	lHtm := Upper(Right(cPag,3)) == "HTM"
EndIf

WEB EXTENDED INIT cHtml

		If lHtm
			cHtml := "<script>window.location='"+cPag+"';</script>"
		Else
			If cIdiom == 'es'       
				cHtml := "<script>window.location='htmls-rh/Abertura_esp.htm';</script>"			
			ElseIf cIdiom == 'en' 
				cHtml := "<script>window.location='htmls-rh/Abertura_eng.htm';</script>"			
			Else
				cHtml := "<script>window.location='htmls-rh/Abertura.htm';</script>"
			endif
		EndIf			
WEB EXTENDED END
Return cHtml

/*************************************************************
* Sair do Site apagando todas as sessions
*************************************************************/
Web Function PWSAOUT()
Local cHtml := ""

WEB EXTENDED INIT cHtml
	HttpFreeSession()	
	cHtml += "<script>top.location='W_PWSX010.APW?cLoginRH=1';</script>"	
WEB EXTENDED END

Return cHtml

/*************************************************************
* PWSASENHA()
* Juliana Barros Mariano - 11/01/2005
* Tela de Consulta de Ajuda para logar com a Senha
*************************************************************/
Web Function PWSASENHA()

Local cHtml := ""

Private cMsg := ""

WEB EXTENDED INIT cHtml
	cMsg := STR0001 + "<br>"			//'Para acessar o Portal RH é necessário utilizar uma senha de 6 dígitos (a mesma senha utilizada no RH Online).'
	cMsg += STR0002 + "<br><br>"		//'Siga os passos para obter a senha inicial:'
	cMsg += STR0003 + " 19<b>84</b> " + STR0007 + "<br>" //'I) Dois dígitos finais do seu ano de nascimento: 19<b>84</b> (exemplo)<br>'
	cMsg += STR0004 + " <b>10</b>/02/2004 " + STR0007 + "<br>" //'II) Dia da admissão: ' + <b>10</b>/02/2004 + '(exemplo)' <br>
	cMsg += STR0005 + " 398168745-<b>51</b> " + STR0007 + "<br><br>" //'III) Dois últimos dígitos do CPF: 398168745-<b>51</b> (exemplo)<br><br>'
	cMsg += STR0006	+ "<br><br>"		 //'Seguindo o exemplo acima a senha será: 841051. <br><br>'
	cHtml += ExecInPage("PWSASENHA")
WEB EXTENDED END

Return cHtml


/*************************************************************
* PWSAESQSENHA()
* Juliana Barros Mariano - 06/05/2005
* Esqueci minha senha
*************************************************************/
Web Function PWSAESQSENHA()
Local cHtml := ""

WEB EXTENDED INIT cHtml
	cHtml += ExecInPage("PWSAESQSENHA")
WEB EXTENDED END
Return cHtml

/*************************************************************
* PWSAENVIASENHA()
* Juliana Barros Mariano - 06/05/2005
* Valida dados e envia senha por e-mail
*************************************************************/
Web Function PWSAENVIASENHA()
	Local cHtml	  	:= ""
	Local cMailAuth	:= ""
	Local cMsg	  	:= ""
	Local cBody		:= ""
	Local cServer	:= ""
	Local nPos	  	:= 0
	Local oObj		:= ""
	Local oParam	:= Nil
	Local lMailAuth	:= .F.
	Local lAutentic	:= .T.
	Local lResult	:= .T.  
	Local lSSL		:= .F.
	Local lTLS		:= .F.
	Local oServer  	:= Nil
	Local oMessage 	:= Nil
	Local nErr     	:= 0
	Local cSMTPAddr := "" 
	Local nSMTPPort := ""
	Local cUser     := "" 
	Local cPass     := "" 
	Local nSMTPTime := 60 
	Local cErro	  	:= ""
	Local cRelFrom  := ""	 
	
	WEB EXTENDED INIT cHtml
		oEmail := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgURL(@oEmail,"RHCURRICULUM.APW")
		
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
		WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
		
		If (If (HttpSession->cAcessoPP <> "1",!Empty( HttpPost->cCPF ), !Empty( HttpPost->cEmail )))
			
			If oObj:GETPARTICIPANT( "", If( HttpSession->cAcessoPP <>"1",HttpPost->cCPF, UPPER(AllTrim(HttpPost->cEmail)) ), HttpSession->cAcessoPP)
				If Empty(oObj:oWSGETPARTICIPANTRESULT:CPARTICIPANTEMAIL)
					HttpSession->_HTMLERRO := { STR0008, STR0009 + '<br>' + STR0010 + '<br>' + STR0011, "W_PWSAESQSENHA.APW" } //"E-mail não enviado"###"E-mail não cadastrado.<br>Entrar em contato com a sua<br>unidade para o cadastramento."
					cHtml := ExecInPage("PWSAMSG2" )
				ElseIf UPPER(AllTrim(HttpPost->cEmail)) == UPPER(AllTrim(oObj:oWSGETPARTICIPANTRESULT:CPARTICIPANTEMAIL))
					If !Empty(oObj:oWSGETPARTICIPANTRESULT:CPARTICIPANTPASS)
			
						cBody := "<html><style type='text/css'><!-- .texto {font-family: Arial, Helvetica, sans-serif;font-size: 12px;"
						cBody += "color: #333333;text-decoration: none;font-weight: normal;}"
						cBody += ".titulo {	font-family: Arial, Helvetica, sans-serif;font-size: 16px;"
						cBody += "color: #19167D;text-decoration: none;font-weight: bold;} --> </style><body>"
						cBody += "<table width='550' border='0' cellpadding='0' cellspacing='0'><tr>"
						cBody += "<td height='263' align='left' valign='top' class='texto'><p class='titulo'><strong><font size='4'>"
						If HttpSession->lGSP
							If HttpSession->cMVGPEGFP == '2'
							cBody += STR0030 //"Senha para acesso ao Portal DGP Vida Funcional
						Else 
								cBody += STR0032 //"Senha para acesso ao Portal RH - Gestão Publica
							EndIf
						Else 
							cBody += STR0012 //"Senha para acesso ao Portal Gestão do Capital Humano
						EndIf	
						cBody += "</font></strong></p>"
						cBody += "<table  width='550' border='1' cellpadding='2' cellspacing='2' bordercolor='#D2DCDF'>"
						cBody += "<tr bordercolor='#D2DCDF' bgcolor='F2F3F5'>"
						cBody += "<td><span class='texto'>"
						cBody += STR0013 //Nome:
						cBody += "<strong>" + oObj:oWSGETPARTICIPANTRESULT:CPARTICIPANTNAME + "</strong><br>"
						cBody += STR0014 + oObj:oWSGETPARTICIPANTRESULT:CPARTICIPANTPASS + "</strong></span></td>" //"Senha: <strong>"
						cBody += "</tr></table></td></tr></table></body></html>"
			
						//CONSULTA E-MAIL CADASTRADO
						If oEmail:GETEMAIL2( "MSALPHA" )
							//Verifica Autenticacoes
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
									
							If oParam:GETPARAM( "MSALPHA", "MV_PORSMTP" )
								nSMTPPort	:= Val(ALLTRIM(oParam:cGETPARAMRESULT))
							EndIf
							
							If oParam:GETPARAM( "MSALPHA", "MV_RELFROM" )
								cRelFrom	:= ALLTRIM(oParam:cGETPARAMRESULT)
							EndIf
									
							// Instancia um novo TMailManager
							oServer := tMailManager():New()
							
							// Usa SSL, TLS ou nenhum na inicializacao
							If lSSL
								oServer:SetUseSSL(lSSL)
							EndIf
							If lTLS
								oServer:SetUseTLS(lTLS)
							Endif
									
							If lMailAuth
								If oParam:GETPARAM( "MSALPHA", "MV_RELAUSR" )
									cUser	:= ALLTRIM(oParam:cGETPARAMRESULT)
								EndIf
							
								If oParam:GETPARAM( "MSALPHA", "MV_RELAPSW" )
									cPass	:= ALLTRIM(oParam:cGETPARAMRESULT)
								EndIf
							Else
								cUser 		:= oEmail:oWSGETEMAIL2RESULT:cEmailAccount
								cPass 		:= oEmail:oWSGETEMAIL2RESULT:cEmailPass
							EndIf
							
							cSMTPAddr	:= oEmail:oWSGETEMAIL2RESULT:cEmailServ
									
							// Inicializa
							nErr := oServer:init("", cSMTPAddr, cUser, cPass, 0, nSMTPPort)
							If nErr <> 0
								cErro := oServer:getErrorString(nErr)
							EndIf
									
							// Define o Timeout SMTP
							If nErr == 0
								nErr := oServer:SetSMTPTimeout(nSMTPTime)
								If nErr <> 0
									cErro := oServer:getErrorString(nErr)
								EndIf
							EndIf
									
							// Conecta ao servidor
							If nErr == 0
								nErr := oServer:smtpConnect()
								If nErr <> 0
									cErro := oServer:getErrorString(nErr)
								EndIf
							EndIf   		

							// Realiza autenticacao no servidor
							If nErr == 0 .And. lMailAuth 
								nErr := oServer:smtpAuth(cUser, cPass)
								If nErr <> 0
									cErro := oServer:getErrorString(nErr)
								Else
									lAutentic := .T.
								Endif
							EndIf                          

							If nErr == 0  .and. lAutentic
								// Cria uma nova mensagem (TMailMessage)
								oMessage := tMailMessage():new()
								oMessage:clear()
								oMessage:cFrom    := cRelFrom
								oMessage:cTo      := AllTrim(HttpPost->cEmail)
								oMessage:cCC      := ""
								oMessage:cBCC     := ""
								oMessage:cSubject := STR0028
								oMessage:cBody    := cBody
								
								// Envia a mensagem
								nErr := oMessage:send(oServer)
								If nErr <> 0
									cErro := oServer:getErrorString(nErr)
								Endif
					
								// Disconecta do Servidor   				
								If nErr == 0
									oServer:smtpDisconnect()
									cMsg := STR0016 //"Senha enviada com sucesso!"
								Else
									cMsg := cErro
								EndIf
								
							Else
								cMsg := cErro
							EndIf
								
							HttpSession->_HTMLERRO := { STR0017, cMsg, "W_PWSAESQSENHA.APW" } //"E-mail"
							cHtml := ExecInPage("PWSAMSG2" )

						EndIf
					Else
						HttpSession->_HTMLERRO := { STR0008, STR0018 + '<br>' + STR0019 + '<br>' + STR0020, "W_PWSAESQSENHA.APW" } //"E-mail não enviado"###"Senha não cadastrada.<br>Entrar em contato com a sua<br>unidade para o cadastramento."
						cHtml := ExecInPage("PWSAMSG2" )
					EndIf
				Else
					HttpSession->_HTMLERRO := { STR0008, STR0021 + '<br>' + STR0019 + '<br>' + STR0020, "W_PWSAESQSENHA.APW" } //"E-mail não enviado"###"E-mail informado está incorreto.<br>Entrar em contato com a sua<br>unidade para o cadastramento."
					cHtml := ExecInPage("PWSAMSG2" )
				EndIf
			Else
				If( HttpSession->cAcessoPP <>"1")
					If (HttpSession->lR7)
							HttpSession->_HTMLERRO := { STR0008, STR0029 +' ' + STR0022 + '<br>' + STR0019 + '<br>' + STR0020, "W_PWSAESQSENHA.APW" } //"E-mail não enviado"###"CPF não cadastrado. <br>Entrar em contato com a sua<br>unidade para o cadastramento."
					Else		
							HttpSession->_HTMLERRO := { STR0008, STR0027 + '<br>' + STR0019 + '<br>' + STR0020, "W_PWSAESQSENHA.APW" } //"E-mail não enviado"###"Documento não cadastrado. <br>Entrar em contato com a sua<br>unidade para o cadastramento."
					EndIf
					cHtml := ExecInPage("PWSAMSG2" )
				Else
					HttpSession->_HTMLERRO := { STR0008, STR0021 + '<br>' + STR0019 + '<br>' + STR0020, "W_PWSAESQSENHA.APW" } //"E-mail não enviado"###"E-mail informado está incorreto.<br>Entrar em contato com a sua<br>unidade para o cadastramento."
					cHtml := ExecInPage("PWSAMSG2" )
				EndIf
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0008, STR0023 + '<br>' + STR0019 + '<br>' + STR0020, "W_PWSAESQSENHA.APW" } //"E-mail não enviado"###"CPF inválido"
			cHtml := ExecInPage("PWSAMSG2" )
		EndIf
	WEB EXTENDED END
Return cHtml

Web Function PWSAALTSENHA()
Local cHtml     := ""
Local cNovaSenha:= "" 
Local oObj	
Local oParam
Local cTipo := ""

	WEB EXTENDED INIT cHtml
		If	Empty(HttpPost->cSenhaAtual) .OR.;
			Empty(HttpPost->cNovaSenha)  .OR.;
			Empty(HttpPost->cConfirmacao)
			cHtml += ExecInPage("PWSAALTSENHA")
		Else 
			If HttpPost->cNovaSenha == HttpPost->cConfirmacao	
				oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSUserPortal"), WSUserPortal():New())			
				WsChgUrl(@oObj, "USERPORTAL.APW")
	
				//----------------------
				oParam := nil
				oParam := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
				WsChgUrl(@oParam,"CFGDICTIONARY.apw")
				If oParam:GETPARAM("MSALPHA", "MV_POLSEG")
					If Alltrim(oParam:cGETPARAMRESULT) <> ".F."
						hTtpSession->nPolSeg := oParam:cGETPARAMRESULT
					Else
						hTtpSession->nPolSeg := ""
					EndIf
				Else
					hTtpSession->nPolSeg := ""		
				EndIf     
				
				cNovaSenha := Upper(AllTrim(HttpPost->cNovaSenha))
				If  Val(hTtpSession->nPolSeg) == 2
					cTipo := "22"
				Else
					cTipo := "2"
					cNovaSenha := Padr(cNovaSenha,6)
					cNovaSenha := Embaralha(cNovaSenha, 0)
				EndIf	
					
				If oObj:PrtPswUser(HttpPost->cCPF, HttpPost->cSenhaAtual , cNovaSenha, cTipo)
					HttpSession->Participant:cParticipantPass:= HttpPost->cNovaSenha
	
					HttpSession->_HTMLERRO := {STR0025, STR0026, "W_PWSA00C.APW"} //"Senha alterada com sucesso!"
					cHtml := ExecInPage("PWSAMSG")
				Else
					HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA00C.APW"}
					cHtml := ExecInPage("PWSAMSG")
				EndIf
				
			Else
				HttpSession->_HTMLERRO := {"Erro", STR0031, "W_PWSAALTSENHA.APW"}//As senhas digitadas não coincidem.<br/>Digite novamente as senhas.
				cHtml := ExecInPage("PWSAMSG")
			EndIf
		EndIf
	WEB EXTENDED END
Return cHtml

/*/{Protheus.doc} f_VldMenu
Função de Validação de qual menu será aberto para o usuário de 
acordo com o parâmetro de folha pública.
@type function
@author Eduardo
@since 23/10/2018
@version 1.0
@param cMVGPEGFP, character, valor do parametro MV_SIGAGFP
@return aMenu, array,array de menu do portal.
/*/
Function f_VldMenu(cMVGPEGFP)

Local aMenu		:= {}

Default cMVGPEGFP	:= "1"
Do Case
	Case ( cMVGPEGFP == "1" ) ; ( aMenu := GetPrtMenu( "000006" ))	//"Gestão de Capital Humano"
	Case ( cMVGPEGFP == "2" ) ; ( aMenu := GetPrtMenu( "000011" ) )	//"Vida Funcional "
	Case ( cMVGPEGFP == "3" ) ; ( aMenu := GetPrtMenu( "000012" )  )//"Portal RH - Gestão Publica" 
End Case
Return aMenu
