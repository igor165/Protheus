#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXENVMAIL.CH'

Function GTPXEnvMail(cFrom, cTo, cCc, cBcc, cSubject, cBody, aAnexos) 

Local oMailServer 	:= Nil
Local lRetorno    	:= .F.
Local nSMTPPort   	:= SuperGetMV("MV_PORSMTP", .F., 25 )  	// PORTA SMTP
Local cSMTPAddr   	:= SuperGetMV("MV_RELSERV", .F., "" )  	// ENDERECO SMTP
Local cUser       	:= SuperGetMV("MV_RELACNT", .F., "" )  	// USUARIO PARA AUTENTICACAO SMTP
Local cPass       	:= SuperGetMV("MV_RELPSW" , .F., "" )  	// ("MV_RELAPSW", .F., "" )SENHA PARA AUTENTICA SMTP
Local cUserAut    	:= SuperGetMV("MV_RELAUSR", .F., "" )
Local lAutentica  	:= SuperGetMV("MV_RELAUTH", .F., .F.) 	// VERIFICAR A NECESSIDADE DE AUTENTICACAO
Local nSMTPTime   	:= SuperGetMV("MV_RELTIME", .F., 120) 	// TIMEOUT PARA A CONEXAO
Local lSSL        	:= SuperGetMV("MV_RELSSL" , .F., .F.)  	// VERIFICA O USO DE SSL
Local lTLS        	:= SuperGetMV("MV_RELTLS" , .F., .F.)  	// VERIFICA O USO DE TLS
Local nError      	:= 0											//CONTROLE DE ERRO.
Local nAnexos     	:= 0
Local nPos			:= 0
Local nDomain		:= 0
Local cMsgErro      := ""
 	
Default cFrom     := ""
Default cTo       := ""
Default cCc       := "" 
Default cBcc      := ""
Default cSubject  := ""
Default cBody     := ""

If nSMTPPort == 0 .AND. !(EMPTY(cSMTPAddr))
	nSMTPPort := VAL(SUBSTR(ALLTRIM(cSMTPAddr),At(':',cSMTPAddr) + 1))
EndIf

If ( nPos := AT(":", cSMTPAddr) ) > 0
	cSMTPAddr := SubStr( cSMTPAddr,1,nPos-1 )	
EndIf

oMailServer := TMailManager():New()

// Usa SSL, TLS ou nenhum na inicializacao
oMailServer:SetUseSSL(lSSL)
oMailServer:SetUseTLS(lTLS)

// Inicializacao do objeto de Email
If nError == 0
	nError := oMailServer:Init("", cSMTPAddr, cUser, cPass, 0, nSMTPPort)
	If nError <> 0
		cMsgErro := STR0001 + oMailServer:getErrorString(nError) //"Falha ao conectar: "
	EndIf
Endif

// Define o Timeout SMTP
If (nError == 0 .AND. oMailServer:SetSMTPTimeout(nSMTPTime) <> 0)
	nError := 1
	cMsgErro := STR0002   //"Falha ao definir timeout"
EndIf

// Conecta ao servidor
If nError == 0
	nError := oMailServer:SmtpConnect()
	If nError <> 0
		cMsgErro := STR0001 + oMailServer:getErrorString(nError)   //"Falha ao conectar: "
		oMailServer:SMTPDisconnect()
	EndIf
EndIf

// Realiza autenticacao no servidor
If nError == 0 .AND. lAutentica
	If EMPTY(cUserAut)
		cUserAut := cUser
	EndIf
	nError := oMailServer:SmtpAuth(cUserAut,cPass)
	If nError != 0
		nDomain := At("@",cUserAut)
		If ( nDomain > 0 )
			nError := oMailServer:SmtpAuth(LTrim(Subs(cUserAut,1,nDomain-1)),cPass)
		EndIf
	EndIf
	
	If nError <> 0
		cMsgErro := STR0003 + oMailServer:getErrorString(nError)   //"Falha ao autenticar: "
		oMailServer:SMTPDisconnect()
	EndIf
EndIf

lRetorno := (nError == 0) 

If ( lRetorno )

	oMessage:= TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := cUser
	oMessage:cTo      := cTo
	oMessage:cCc      := cCc
	oMessage:cBcc     := cBcc
	oMessage:cSubject := cSubject
	oMessage:cBody    := cBody
       
	For nAnexos := 1 To Len(aAnexos)
		
		nError := oMessage:AttachFile(aAnexos[nAnexos])
		
		oMessage:AddAttHTag('Content-ID: <ID_conf_' + aAnexos[nAnexos] + '>')
		
		If ( nError < 0 )
			lRetorno := .f.
			cMsgErro := STR0004		//"Não foi possível anexar arquivo. O envio da mensagem será abortado."
			Exit
		Endif
		
    Next nAnexos
      
    If ( lRetorno )  
    	
    	nError := oMessage:Send(oMailServer)
    	
    	If nError <> 0
			cMsgErro := STR0005 + oMailServer:GetErrorString(nError)   //"Falha ao enviar o e-mail: "
		EndIf
		
		lRetorno := nError == 0
		
    Endif	
	
	oMailServer:SmtpDisconnect()     

EndIf

Return aClone({lRetorno, cMsgErro})

//-------------------------------------------------------------------
/*/{Protheus.doc} GxVldParEmail()

@author  henrique.toyada
@since   16/01/2020
@version 12
/*/
//-------------------------------------------------------------------
Function GxVldParEmail(cMV_Email)
Local lRet  := .T.

Default cMV_Email := ""

DO CASE

	CASE SuperGetMV("MV_RELAUTH",.F.,'F')
		
		If Empty(SuperGetMV("MV_RELAUSR",.F.,'')) .AND. Empty(SuperGetMV("MV_RELACNT",.F.,''))
			cMV_Email += "MV_RELAUSR"+CHR(13)+CHR(10)
		ElseIf Empty(SuperGetMV("MV_RELPSW",.F.,''))
			cMV_Email += "MV_RELPSW"+CHR(13)+CHR(10)
		EndIf

	CASE Empty(SuperGetMV("MV_RELTIME",.F.,''))
		cMV_Email += "MV_RELTIME"+CHR(13)+CHR(10)

	CASE Empty(SuperGetMV("MV_RELACNT",.F.,''))
		cMV_Email += "MV_RELACNT"+CHR(13)+CHR(10)

	CASE Empty(SuperGetMV("MV_RELSERV",.F.,''))
		cMV_Email += "MV_RELSERV"+CHR(13)+CHR(10)
		
	CASE AT(":", SuperGetMV("MV_RELSERV",.F.,'')) == 0 .AND. Empty(SuperGetMV("MV_PORSMTP",.F.,''))
		cMV_Email += "MV_PORSMTP"+CHR(13)+CHR(10)

ENDCASE

If !(EMPTY(cMV_Email))
	lRet  := .F.
EndIf

Return lRet
