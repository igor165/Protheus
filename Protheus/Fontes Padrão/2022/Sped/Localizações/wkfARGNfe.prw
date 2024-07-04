//Bibliotecas
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"

/*/{Protheus.doc} DispMail
(long_description)
@type function
@author Rafael Falco
@since 14/04/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function DispMail( cMailPr, cMailCp, cMailBc, cHtml, cMaiAss )

	Local nErr		:= 0
	Local oServer	:= Nil
	Local oMessage	:= Nil

    Local cMailDe	:= Alltrim( GetMV("MV_RELACNT") )														/// EMAIL DE QUEM ESTÁ ENVIANDO
    Local cUser		:= SubStr( cMailDe, 1, At( '@', cMailDe ) -1 )											/// USUARIO QUE IRA REALIZAR A AUTENTICACAO
    Local cPass		:= Alltrim( GetMV("MV_RELPSW"))															/// SENHA DO USUARIO
    Local cSrvFull	:= Alltrim( GetMV("MV_RELSERV"))															/// ENDERECO DO SERVIDOR SMTP COMPLETO
    Local cSMTPAddr	:= iIf(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)				/// ENDERECO DO SERVIDOR SMTP
    Local cSMTPPort	:= iIf(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 465)	/// PORTA DO SERVIDOR SMTP
	Local cPopAddr  := "pop.gmail.com"																		/// ENDERECO DO SERVIDOR POP3
	Local cPOPPort  := 110																					/// PORTA DO SERVIDOR POP
    Local nSMTPTime	:= GetMV("MV_RELTIME")																	/// TIMEOUT SMTP
 
	// INSTANCIA UM NOVO TMAILMANAGER
	oServer := tMailManager():New()    
	
	// USA SSL NA CONEXAO
	oServer:setUseSSL(.T.)
	
	// Inicializa
	oServer:init(cPopAddr, cSMTPAddr, cUser, cPass, cPOPPort, cSMTPPort)
	
	// DEFINE O TIMEOUT SMTP
	If( oServer:SetSMTPTimeout(nSMTPTime) != 0 )
	  conout("[ERROR]Falha ao definir timeout")
	  Return .F.
	EndIf
	
	// CONECTA AO SERVIDOR
	nErr := oServer:smtpConnect()
	If( nErr <> 0 )
	  conOut("[ERROR]Falha ao conectar: " + oServer:getErrorString(nErr))
	  oServer:smtpDisconnect()
	  Return .F.
	EndIf
	                      
	// REALIZA AUTENTICACAO NO SERVIDOR
	nErr := oServer:smtpAuth(cUser, cPass)
	If( nErr <> 0 )
	  conOut("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))
	  oServer:smtpDisconnect()
	  Return .F.
	EndIf

	// CRIA UMA NOVA MENSAGEM (TMAILMESSAGE)
	oMessage := tMailMessage():new()
	oMessage:clear()
	oMessage:cFrom    := cMailDe
	oMessage:cTo      := cMailPr
	oMessage:cCC      := cMailCp
	oMessage:cBCC     := cMailBc
	oMessage:cSubject := cMaiAss
	oMessage:cBody    := cHtml
                                        
	// ENVIA A MENSAGEM
	nErr := oMessage:send(oServer)
	If nErr <> 0
	  conout("[ERROR]Falha ao enviar: " + oServer:getErrorString(nErr))
	  oServer:smtpDisconnect()
	  Return .F.
	EndIf
	
	// DISCONECTA DO SERVIDOR
	oServer:smtpDisconnect()

Return .T.

/*/{Protheus.doc} TstMail2
(long_description)
@type function
@author Rafael Falco
@since 14/04/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function TstMail2()

	Local cHtml 	:= ""
	Local cMaiAss 	:= "Workflow de transmissão de Remito"
	Local cMailPr	:= SubStr(Alltrim( GetMV("MV_WRKFLW" ) ), 1, At(';', Alltrim( GetMV("MV_WRKFLW" ) ))-1)	/// EMAIL PARA QUEM 
	Local cMailCp	:= SubStr(Alltrim( GetMV("MV_WRKFLW" ) ), At(';', Alltrim( GetMV("MV_WRKFLW" ) ))+1, Len(Alltrim( GetMV("MV_WRKFLW" ) )) )	/// EMAIL COM CÓPIA
	Local cMailBc	:= ""																					/// EMAIL COM CÓPIA OCULTA  

	
	cHtml := '<HTML><HEAD><TITLE></TITLE>'
	cHtml += '<META http-equiv=Content-Type content="text/html; charset=windows-1252">'
	cHtml += '<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'
	cHtml += '<BODY>'
	cHtml += '<H1><FONT color=#ff0000>Envio de informações confidenciais</FONT></H1>'
	cHtml += '<TABLE cellSpacing=0 cellPadding=0 width="100%" bgColor=#afeeee background="" '
	cHtml += 'border=1>'
	cHtml += '  <TBODY>'
	cHtml += '  <TR>'
	cHtml += '    <TD>Voce está participando</TD>'
	cHtml += '<TD>123</TD></TR>'
	cHtml += '  <TR>'
	cHtml += '    <TD>de um teste de envio</TD>'
	cHtml += '    <TD>' + DtoS( Date() ) + '</TD></TR>'
	cHtml += '  <TR>'
	cHtml += '    <TD>de email!!!</TD>'
	cHtml += '    <TD>' + Time() + '</TD></TR></TBODY></TABLE>'
	cHtml += '<P>&nbsp;</P>'
	cHtml += '<P><A href="https://www.terra.com.br/">Clique nesse '
	cHtml += 'link!!!</A></P></BODY></HTML>'
	
	// Envia o e-mail
	U_DispMail( cMailPr, cMailCp, cMailBc, cHtml, cMaiAss )

Return
