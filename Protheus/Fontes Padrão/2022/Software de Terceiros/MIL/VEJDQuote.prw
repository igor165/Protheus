#include "Totvs.ch"
#include "VEJDQUOTE.CH"

Function VEJDQuote()
Return

Class VEJDQuote

	Data oWSDLManager AS OBJECT
	Data oXMLManager AS OBJECT

	Data cXMLResponse

	Data cToken
	Data cUser
	Data cPassword
	Data cUserVAI
	Data cPasswdVAI
	Data cDealerAccount

	Data lOkta
	Data lParamCheck

	Data oOkta as OBJECT

	Data aResponse

	Data cWSDL
	Data cURLWebService
	Data cNameHeaderToken

	Data lInitProp

	Method New() CONSTRUCTOR
	Method Clear()
	Method setAuthentication()

	Method initOkta()

	Method Send()
	Method _LogConsole()

EndClass

/*/{Protheus.doc} New
		Construtor Simples

	@type function
	@author Rubens Takahashi
	@since 01/04/2019
/*/
Method New() Class VEJDQuote

	::lInitProp := .t.
	::lParamCheck := .f.
	::aResponse := {}

	::oWSDLManager := TWsdlManager():New()
	::oXMLManager := TXMLManager():New()

	//::oWSDLManager:cLocation := GetNewPar("MV_MIL0127","")// "https://jdquote2qual.tal.deere.com/services/MaintainQuote_Version6_6Impl"
	::oWSDLManager:cLocation := ::cURLWebService
	::oWSDLManager:bNoCheckPeerCert := .T. // Desabilita o check de CAs

	VAI->(DbSetOrder(4))
	VAI->(MsSeek(xFilial("VAI") + __cUserID))
	VAI->(DbSetOrder(1))
	If VAI->(Found())
		::cUserVAI := Upper(AllTrim(VAI->VAI_FABUSR))
		::cPasswdVAI := AllTrim(VAI->VAI_FABPWD)
	Else
		::cUserVAI := ""
		::cPasswdVAI := ""
	EndIf

	::cDealerAccount := AllTrim(GetMV("MV_MIL0133"))

	::oWSDLManager:lVerbose := .t.

	If ::oOkta == NIL
		::oOkta := OFJDOkta():New()
		::oOkta:SetUserPasswd(::cUserVAI, ::cPasswdVAI)
	EndIf

	//::cWSDL := "https://jdquote2ws.deere.com/services/MaintainQuote_Version6_6Impl?wsdl"
	//::oWSDLManager:AddHttpHeader( "Authorization", "Basic "+Encode64(::cUser + ":" + ::cPassword) )

 	xRet := ::oWSDLManager:ParseURL( ::cWSDL )
 	//xRet := ::oWSDLManager:ParseFile( ::cWSDL )
	if xRet == .F.
		//Conout(" ")
		//conout( "Erro: " + ::oWSDLManager:cError )
		//Conout(" ")
		MsgStop(STR0005 + CRLF + CRLF + ::oWSDLManager:cError) // "Problema ao carregar arquivo wsdl."
		::lInitProp := .f.
	endif
	::oWSDLManager:lVerbose := .t.

	//Conout(" ")
	//Conout(" ----------------------------------------- ")
	//Conout(" ")
	//Conout(" ::oWSDLManager:lSSLInsecure -> " + cValToChar(::oWSDLManager:lSSLInsecure))
	//Conout(" ::oWSDLManager:cLocation -> " + ::oWSDLManager:cLocation)
	//Conout(" ::oWSDLManager:lVerbose -> " + cValToChar(::oWSDLManager:lVerbose))
	//Conout(" ::cToken -> " + ::cToken)
	//Conout(" ::cUser -> " + ::cUser)
	//Conout(" ::cPassword -> " + ::cPassword)
	//Conout(" ::cUserVAI -> " + ::cUserVAI)
	//Conout(" ::cDealerAccount -> " + ::cDealerAccount)
	//Conout(" ")
	//Conout(" ----------------------------------------- ")
	//Conout(" ")


Return SELF

Method Clear() class VEJDQuote
	::aResponse := {}
Return

/*/{Protheus.doc} _LogConsole
Gera conout no console
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method _LogConsole() class VEJDQuote

	Conout(::oXMLManager:cName)
	Conout(::oXMLManager:cPath)
	Conout("DOMChildCount - " + cValToChar(::oXMLManager:DOMChildCount()))
	Conout("-----------------------------------------")

Return


/*/{Protheus.doc} send

Metodo interno responsavel por executar a consulta webservice

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cMsgSend, characters, descricao
@type function
/*/
Method send(cMsgSend) class VEJDQuote
	Local xRet

	If ! ::setAuthentication()
		Return .f.
	EndIf
	::oWSDLManager:cLocation := ::cURLWebService

	::oWSDLManager:lVerbose := .t.
	//Conout(" ::oWSDLManager:lSSLInsecure -> " + cValToChar(::oWSDLManager:lSSLInsecure))
	//Conout(" ::oWSDLManager:cLocation -> " + ::oWSDLManager:cLocation)
	//Conout(" ::oWSDLManager:lVerbose -> " + cValToChar(::oWSDLManager:lVerbose))

	xRet := ::oWSDLManager:SendSoapMsg( cMsgSend )

	//conout(" ")
	//conout("SendSoapMsg ")
	//conout(" ")
	//conout(cMsgSend)
	//conout(" ")


	If xRet == .f.
		//conout( STR0006 + ": " + ::oWSDLManager:cError ) // "Erro"
		Return xRet
	EndIf

	::cXMLResponse := ::oWSDLManager:GetSoapResponse()
	If xRet == .F.
		//conout( STR0006 + ": " + ::oWSDLManager:cError ) // "Erro"
		Return xRet
	EndIf

	If "ACCESS DENIED" $ UPPER(SELF:cXMLResponse)
		Return .f.
	EndIf

	If ! ::oXMLManager:Read( ::cXMLResponse ,, 'UTF-8' )
		//Conout(" ")
		//Conout(" ___  __   __   __           __      __        __   __   ___  __           __   __               __  ")
		//Conout("|__  |__) |__) /  \     /\  /  \    |__)  /\  |__) /__` |__  |__)     /\  |__) /  \ |  | | \  / /  \ ")
		//Conout("|___ |  \ |  \ \__/    /~~\ \__/    |    /~~\ |  \ .__/ |___ |  \    /~~\ |  \ \__X \__/ |  \/  \__/ ")
		//Conout("                                                                                                     ")
	EndIf
	//conout(" ")
	//conout(::cXMLResponse)
	//conout(" ")

Return xRet

/*/{Protheus.doc} setAuthentication
Configura informacoes de conexao
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method setAuthentication() class VEJDQuote
	Local cToken

	If ::lOkta
		cToken := ::oOkta:getToken()
		If Empty(cToken)
			MsgStop(STR0007,STR0006) // "Falha na obtenção do Token de Acesso."
			Return .f.
		EndIf
		::oWSDLManager:AddHttpHeader( "Authorization", "Bearer " + cToken )
	Else

		If ::lParamCheck == .f. 
			::lParamCheck := .t.
			If ! FWSX6Util():ExistsParam("MV_MIL0143") .or. ! FWSX6Util():ExistsParam("MV_MIL0144")
				MsgStop(STR0001 + CRLF + STR0002) // "Parâmetros para conexão com o WebService não encontrado." // "Aplicar o pacote de implementação da melhoria."
				::cUser := ""
				::cPassword := ""
			Else
				::cUser := AllTrim(GetMV("MV_MIL0143"))
				::cPassword := AllTrim(GetMV("MV_MIL0144"))
			EndIf
			::cToken := GetNewPar("MV_MIL0128","")
		EndIf

		If Empty(::cUser) .or. Empty(::cPassword)
			MsgStop(STR0003 + CRLF + STR0004) // "Parâmetros para conexão com o WebService não preenchidos." // "Verificar o conteúdo dos parametros MV_MIL0143 e MV_MIL0144."
		EndIf

		::oWSDLManager:AddHttpHeader( ::cNameHeaderToken , ::cToken )
		::oWSDLManager:AddHttpHeader( "Authorization", "Basic "+Encode64(::cUser + ":" + ::cPassword) )
	EndIf

	::oWSDLManager:lSSLInsecure := .T.
	::oWSDLManager:lProcResp := .f.

Return .t.