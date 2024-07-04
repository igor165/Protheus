// ######################################################################################
// Projeto: BI Library
// Fonte  : TBIMailSender.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 24.09.04 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "TBIMailSender.ch"

/*--------------------------------------------------------------------------------------
@class TBIMailSender
@entity Mensagem
Envio de Mensagens e avisos do sistemas.
@table TBIMailSender
--------------------------------------------------------------------------------------*/
class TBIMailSender from TBIEvtObject
	data conta		//Conta de email
	data servidor	//Servidor SMTP
	data portaSmtp	//Porta SMTP
	data usuario	//Nome do Usuario para autenticacao
	data senha		//Senha de autenticacao
	data lMsgOut	//exibe msg no console do servidor?
	data lSSL		//Utilização de SSL
	data lTLS		//Utilização de TLS
	data oLogger	//ponteiro para logar as ocorrencias
	
	method New() constructor
	method NewMailSender()
	method setServidor( cServidor, cPorta )
	method setConta(cConta)
	method setUsuario( cUsuario, cSenha)
	method setSSL( lSSL ) 
	method setTLS( lTLS )
	method SendMessage(serverSMTP, conta, autUsuario, autSenha, cto, assunto,corpo,anexos)
endclass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New

@author    Aline Correa do Vale
@version   P10
@since     24.09.04
/*/
//-------------------------------------------------------------------------------------
method New() class TBIMailSender
	::NewMailSender()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewMailSender

@author    Aline Correa do Vale
@version   P10
@since     24.09.04
/*/
//-------------------------------------------------------------------------------------
method NewMailSender() class TBIMailSender
	::NewEvtObject()

	::conta		:= ""	//Conta de email
	::servidor	:= ""	//Servidor SMTP
	::portaSmtp	:= ""	//Porta SMTP
	::usuario	:= ""	//Nome do Usuario para autenticacao
	::senha		:= ""	//Senha de autenticacao
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} setConta

@author    Aline Correa do Vale
@version   P10
@since     24.09.04
/*/
//-------------------------------------------------------------------------------------
method setConta( cConta ) class TBIMailSender
	default cConta := ""
	
	::conta := cConta
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} setServidor

@author    Aline Correa do Vale
@version   P10
@since     24.09.04
/*/
//-------------------------------------------------------------------------------------
method setServidor( cServidor, cPorta) class TBIMailSender
	default cServidor := ""
	default cPorta := ""
	
	::servidor		:= cServidor			//Servidor SMTP
	::portaSmtp	:= nBIVal( cPorta )	//Porta SMTP
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} setUsuario

@author    Aline Correa do Vale
@version   P10
@since     24.09.04
/*/
//-------------------------------------------------------------------------------------
method setUsuario( cUsuario, cSenha) class TBIMailSender
	default cUsuario := ""
	default cSenha := ""
	
	::usuario	:= cUsuario	//Usuario para autenticacao
	::senha		:= cSenha	//Senha para autenticacao
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} setSSL

@author    Valdiney V GOMES
@version   P10
@since     20/05/2011
/*/
//-------------------------------------------------------------------------------------
method setSSL( lSSL ) class TBIMailSender
 	Default lSSL := .F. 
 	
 	::lSSL := lSSL
return       

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} setTLS

@author    Pedro Imai Gomes
@version   P10
@since     24/10/2011
/*/
//-------------------------------------------------------------------------------------
method setTLS( lTLS ) class TBIMailSender
 	Default lTLS := .F. 
 	
 	::lTLS := lTLS
return  

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SendMessage

@author    Aline Correa do Vale
@version   P10
@since     24.09.04
/*/
//-------------------------------------------------------------------------------------
method SendMessage(pcPara, pcAssunto, pcHTML, pcAnexos, pcDe, pcCopia, pcOculto) class TBIMailSender  
	Default pcPara	:= ""
	Default pcAssunto	:= ""
	Default pcHTML	:= ""
	Default pcAnexos	:= ""
	Default pcDe		:= ""
	Default pcCopia	:= ""
	Default pcOculto	:= "" 
                                              
	pcPara  	:= StrTran(pcPara	, ",", ";")
	pcCopia    := StrTran(pcCopia	, ",", ";")
	pcOculto	:= StrTran(pcOculto	, ",", ";")
	
	
	
return Send( ::servidor, ::portaSMTP, ::usuario, ::senha, ::lSSL, pcDe, pcPara, pcCopia, pcOculto, pcAssunto, pcHTML, pcAnexos,::lTLS )    

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lSendingEngine

@author    Valdiney V GOMES
@version   P10
@since     21/10/2011
/*/
//-------------------------------------------------------------------------------------
Static Function Send( pcServidor, pnPorta, pcUsuario, pcSenha, plSSL, pcDe, pcPara, pcCopia, pcOculto, pcAssunto, pcHTML, pcAnexos,plTLS ) 
    Local oServer  		:= TMailManager():New()  	//Objeto do gerenciador de email. 
    Local oMessage 		:= TMailMessage():new()  	//Objeto da mensagem. 
    Local nRet			:= 0       
    Local aAnexos       	:= {} 
    Local nContador     	:= 0

    Default pcServidor	:= ""
    Default pnPorta		:= ""
    Default pcUsuario  	:= ""
    Default pcSenha    	:= ""
    Default plSSL			:= .F.
    Default plTLS       	:= .F.	  
    
    if ( Empty( alltrim( pcPara + pcCopia + pcOculto) ) )     
        BIConOut(STR0011) //"Ocorreu erro no envio da mensagem: " 
        BIConOut(pcAssunto) 
        BIConOut(STR0012) //"O(s) destinatário(s) para o envio de e-mail não foi(ram) informado(s)."
		Return .F.    
	EndIf
         
    BIConOut( STR0001 + cBIStr( pcServidor ) + ":" + cBIStr( pnPorta ) ) //"Conectando no servidor SMTP: "

	//Define se será usado SSL.
    oServer:SetUseSSL( plSSL )
    
    //Define se será usado TLS. 
    oServer:SetUseTLS( plTLS )
    
    //Inicializa o serviço de email.
	 oServer:init(pcServidor, pcServidor, pcUsuario, pcSenha,, pnPorta)

    //Conecta no servidor SMTP.
	If !( ( nRet := oServer:SMTPConnect() ) == 0 )
      	oServer:SMTPDisconnect()
      	BIConOut(STR0002 + oServer:getErrorString(nRet)) //"Ocorreu o seguinte erro na conexão: "
		Return .F.
	EndIf
	
    //Autentica no servidor SMTP.  
	If ( ! Empty(pcUsuario) .And. ! Empty(pcSenha) )
		If ! ( ( nRet := oServer:SMTPAuth( AllTrim( pcUsuario ) , AllTrim( pcSenha ) ) ) == 0 )
	      	oServer:SMTPDisconnect()	      	
	      	BIConOut(STR0003 + oServer:getErrorString(nRet)) //"Ocorreu o seguinte erro na autenticação: "
			Return .F. 
		Else
		 	BIConOut(STR0004 + cBIStr( pcUsuario ) ) //"Autenticação realizada com sucesso para o usuário: "		
		EndIf  	   
	EndIf
      
    //Monta a mensagem a ser enviada.   
    oMessage:Clear()  
    oMessage:cFrom    	:= pcDe
    oMessage:cTo      	:= pcPara 
    oMessage:cCC   		:= pcCopia	
    oMessage:cBCC       	:= pcOculto
    oMessage:cSubject 	:= pcAssunto
    oMessage:cBody    	:= pcHTML 
    
    //Adiciona anexos no email
    if(pcAnexos!="") 

	    aAnexos := aBIToken(pcAnexos,";",.T.)
	       
	    For nContador:= 1 to Len(aAnexos)
	     	If oMessage:AttachFile(aAnexos[nContador] ) >= 0
			   	oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cRemoveFilePath(aAnexos[nContador]))
			EndIf 
		Next	
		
    endif
 
    //Envia a mensagem. 
    If ! ( ( nRet := oMessage:Send(oServer) ) == 0 )
	    oServer:SMTPDisconnect() 
	    BIConOut(STR0005 + oServer:getErrorString(nRet)) //"Ocorreu o seguinte erro no envio da mensagem: "
	    Return .F.  
	else
	  	BIConOut(STR0006 + cBIStr( pcPara ) ) //"Mensagem enviada com sucesso para: "	
	  	BIConOut(STR0007 + cBIStr( pcDe ) ) //"Remetente: "	  
	  	BIConOut(STR0008 + cBIStr( pcAssunto ) ) //"Assunto: "		 
	Endif

    //Encerra a conexão com o servidor SMTP. 
    If ! ( ( nRet := oServer:SmtpDisconnect() ) == 0 )
     	BIConOut(STR0009 + oServer:getErrorString(nRet)) //"Ocorreu o seguinte erro no encerramento da conexão com o servidor SMTP: "
    	Return .F. 
    else
		BIConOut( STR0010 + cBIStr( pcServidor ) + ":" + cBIStr( pnPorta ) ) //"Desconectado do servidor SMTP: "
	EndIf
Return .T.