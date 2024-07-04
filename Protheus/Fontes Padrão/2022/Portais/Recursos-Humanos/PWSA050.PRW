#INCLUDE "PWSA050PRW.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "Ap5Mail.ch"

#DEFINE CODUSUARIO		"MSALPHA"

/*******************************************************************
* Funcao: PWSA050 - Consulta de todos os participantes que estao 
*					abaixo do participante logado
* Autor:	Rogerio Augusto
* Data:		Novembro 2004
********************************************************************/
Web Function PWSA050()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHIDENTIFY"), WSRHIDENTIFY():New())
WsChgURL(@oObj,"RHIDENTIFY.APW")
	
    If (oObj:BRWSUBORTINATES(CODUSUARIO,HttpSession->cParticipantID))
    	HttpSession->BRWSUBORTINATES := {oObj:oWSBRWSUBORTINATESRESULT}
    	cHtml += ExecInPage( "PWSA050" )
    Else // Caso o usuario nao faca parte de alguma visao, direciona apenas para seus dados pessoais
    	cHtml += W_PWSA051()
	EndIf

WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA051 - Retorna os dados pessoais do participante a 
					partir do ID
  
* Autor:	Rogerio Augusto
* Data:		Novembro 2004
********************************************************************/
Web Function PWSA051()

Local cHtml := "" 
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHIDENTIFY"), WSRHIDENTIFY():New())
WsChgURL(@oObj,"RHIDENTIFY.APW")
	

    If oObj:BRWPERSONALDATA(CODUSUARIO, HttpSession->cPartAcesso[1] )//ParticipantID))
    	HttpSession->BRWPERSONALDATA := {oObj:oWSBRWPERSONALDATARESULT}
    	cHtml := ExecInPage( "PWSA051" )
    Else
    	HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf

WEB EXTENDED END

Return cHtml 

/*******************************************************************
* Funcao: PWSA052 - Atualiza dados pessoais na tabela RD0 e SRA

* Autor:	Rogerio Augusto
* Data:		Novembro 2004
********************************************************************/
Web Function PWSA052()
	Local cHtml := ""
	Local oObj
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHIDENTIFY"), WSRHIDENTIFY():New())
	WsChgURL(@oObj,"RHIDENTIFY.APW")                                        
	
	oObj:oWSPERSONALINFO := RHIDENTIFY_PERSONALDATA():New()
	
	oObj:oWSPERSONALINFO:cParticipantID := HttpPost->UserID
	oObj:oWSPERSONALINFO:cParticipantPhone := HttpPost->telefone
	oObj:oWSPERSONALINFO:cParticipantPhoCode := HttpPost->ddd
	oObj:oWSPERSONALINFO:cParticipantCel := HttpPost->celular
	oObj:oWSPERSONALINFO:cParticipantMail := Upper(HttpPost->email)
	oObj:oWSPERSONALINFO:cParticipantComPhone := HttpPost->telefoneCom
	oObj:oWSPERSONALINFO:cParticipantComPhoCode := HttpPost->DDDCom
	oObj:oWSPERSONALINFO:cParticipantComCel := HttpPost->celularCom
	oObj:oWSPERSONALINFO:cParticipantDisbSelected := HttpPost->dPCD	
	oObj:oWSPERSONALINFO:cParticipantTrvlSelected := HttpPost->dViagens
	oObj:oWSPERSONALINFO:cParticipantMatr := HttpSession->aUsuario[1]
	oObj:oWSPERSONALINFO:cParticipantFilial := HttpSession->aUsuario[3]
	
	If (oObj:PUTPERSONALDATA(CODUSUARIO,oObj:oWSPERSONALINFO))
		cHtml += W_PWSA051()
    Else
    	HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf

	WEB EXTENDED END

Return cHtml

/***********************************************************************
* Funcao: PWSA053 - Pop Up para solicitar modificacao nos dados pessoais

* Autor:	Rogerio Augusto
* Data:		Novembro 2004
***********************************************************************/
Web Function PWSA053()

Local cHtml := ""  

WEB EXTENDED INIT cHtml START "InSite"

	cHtml += ExecInPage("PWSAPopCadastro")

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Autor...: Rogério Augusto     Data: 24 de Outubro de 2004 */
/* Objetivo: Envia e-mail solicitando alteracao cadastral    */
/*************************************************************/
Web Function PWSARHMail()

Local cHtml 	:= ""
Local lOk 		:= .T.
Local cSMTP 	:= ""
Local cConta 	:= ""
Local cSenha 	:= ""
Local cFrom 	:= ""
Local cTo 		:= ""
Local cSubject 	:= ""
Local cNome		:= ""
Local cCPF		:= ""
Local cMatricula := ""
Local cBody		:= ""
Local cErro 	:= ""
Local cConteudo := ""
Local cMsg		:= ""
Local oParam	:= ""
Local oObj		:= ""                                                                       

WEB EXTENDED INIT cHtml

oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
oObj	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHIDENTIFY"), WSRHIDENTIFY():New())
WsChgURL(@oParam,"CFGDICTIONARY.APW") 
WsChgURL(@oObj,"RHIDENTIFY.APW")
	
    //PEGA EMAIL DO PART LOGADO
    If oObj:BRWPERSONALDATA(CODUSUARIO, HttpSession->cPartAcesso[1] )//ParticipantID))
    	cFrom := oObj:oWSBRWPERSONALDATARESULT:cParticipantMail
	EndIf    

cNome		:= HttpPost->nome
cCPF		:= HttpPost->CPF
cMatricula	:= HttpPost->matricula
cConteudo	:= HttpPost->texto     
cSubject	:= STR0002		//"Alteração de dados cadastrais" 

//SERVIDOR DE E-MAIL
If oParam:GETPARAM( CODUSUARIO, "MV_RELSERV" )
	cSMTP := oParam:cGETPARAMRESULT
EndIf

//CONTA
If oParam:GETPARAM( CODUSUARIO, "MV_EMCONTA" )
	cConta := oParam:cGETPARAMRESULT
EndIf

//SENHA
If oParam:GETPARAM( CODUSUARIO, "MV_EMSENHA" )
	cSenha := oParam:cGETPARAMRESULT
EndIf

//RESGATA PARAMETRO CONTENDO E-MAIL PARA ONDE SERAO ENVIADAS AS ALTERACOES
If oParam:GETPARAM( CODUSUARIO, "MV_CVMAIL" )
	If !Empty(oParam:cGETPARAMRESULT)
		If !Empty(cFrom)
			If !Empty(cSMTP) .And. !Empty(cConta) .And. !Empty(cSenha)
				cTo := oParam:cGETPARAMRESULT
				
				HttpSetPart( .F. )
				cBody := "<html><style type='text/css'><!-- .negrito {font-family: Arial, Helvetica, sans-serif;"
				cBody += "font-size: 12px; font-weight: bold; } .normal {font-family: Arial, Helvetica, sans-serif;"
				cBody += "font-size: 12px; } --> </style><body><p align='center'><span class='negrito'>"
				cBody += STR0002 + "</span></p><p><span class='negrito'>" + STR0003 + ":"	//"Alteração de dados cadastrais"##"Nome"
				cBody += "</span><span class='normal'> "+cNome+"</span><br><span class='negrito'>" + STR0004 + ":&nbsp;</span>" //"CPF"
				cBody += "<span class='normal'>"+cCPF+"</span><br><span class='negrito'>" + STR0005 + ":</span>"	//"Matr&iacute;cula"
				cBody += "<span class='normal'> "+cMatricula+"<br></span><span class='negrito'>"+ STR0006 +": </span>"	//Mensagem
				cBody += "<span class='normal'>"+cConteudo+"</span></p></body></html>"
				
				HttpSetPart( .T. )
				CONNECT SMTP SERVER cSMTP; 
				ACCOUNT cConta PASSWORD cSenha; 
				RESULT lOK
				
				If lOk
					SEND MAIL FROM cFrom ;                     
					TO cTo ;
					SUBJECT cSubject ;
					BODY cBody ;
					RESULT lOk
				
					If lOk
						cMsg := STR0007		//"Mensagem enviada com sucesso!"
					Else
						GET MAIL ERROR cErro
						cMsg := cErro
					EndIf
				
					DISCONNECT SMTP SERVER RESULT lOK
				
					If !lOk
						GET MAIL ERROR cErro
						cMsg := cErro
					EndIf
				Else
					GET MAIL ERROR cErro
						cMsg := cErro
				EndIf
			Else
				cMsg := STR0008 + "<br>" + STR0009	//"E-mail não pode ser enviado. Contate o administrador do sistema e informe a mensagem abaixo:"##"Não existe e-mail cadastrado e/ou servidor de e-mail. Verifique os parâmetros MV_RELSERV, MV_EMCONTA e MV_EMSENHA"				
			EndIf
		Else
			cMsg := STR0012	//"Solicitação não pode ser enviada. Preencha seu e-mail nos Dados Pessoais"
		EndIf
	Else
		cMsg := STR0008 + "<br>" + STR0011	//"E-mail não pode ser enviado. Contate o administrador do sistema e informe a mensagem abaixo:"##"Não existe e-mail cadastrado. Verifique o parâmetro MV_CVMAIL"
	EndIf
Else
	cMsg := PWSGetWSError()
EndIf  
                      
HttpSession->_HTMLERRO := { STR0002, cMsg, "javascript:window.close();" }	//"Alteração de dados cadastrais"
cHtml := ExecInPage("PWSAMSG" )


WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA055 - Retorna o historico salarial
  
* Autor:	Rogerio Augusto
* Data:		Novembro 2004
********************************************************************/
Web Function PWSA055()

Local cHtml := "" 
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHIDENTIFY"), WSRHIDENTIFY():New())
WsChgURL(@oObj,"RHIDENTIFY.APW")


    If oObj:BRWWAGEHISTORY(CODUSUARIO, HttpSession->cPartAcesso[1] )
    	HttpSession->BRWWAGEHISTORY := {oObj:oWSBRWWAGEHISTORYRESULT} 
    	
    	Asort(HttpSession->BRWWAGEHISTORY[1]:OWSWHHEADER:OWSWAGEHISTORYHEADER,,, {|x,y| x:DWHDATE > y:DWHDATE })
    	Asort(HttpSession->BRWWAGEHISTORY[1]:OWSWHDATA:OWSWAGEHISTORYARRAY,,, {|x,y| x:OWSWDITEM:OWSWAGEHISTORYVALUES[1]:DWDDATE > y:OWSWDITEM:OWSWAGEHISTORYVALUES[1]:DWDDATE })
	  	
    	cHtml += ExecInPage( "PWSAHistSalarial" )
    Else
    	HttpSession->_HTMLERRO := { STR0010, PWSGetWSError(), "W_PWSA001.APW" }	//"Não há Histórico Salarial registrado"
		Return ExecInPage("PWSAMSG" )
	EndIf

WEB EXTENDED END

Return cHtml 
