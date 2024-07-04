#INCLUDE "WEBDESKINTEGRATION.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "ECMCONST.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} biECMWorkflow
Definição da classe para definição para obtenção de URL de um fluxo no totvs ECM

@author  3510 - Gilmar P. Santos
@version P10
@since   26/02/2010

/*/
//-------------------------------------------------------------------------------------
class biECMWorkflow from LongClassName

	method new() constructor

	method buildToken()
	method buildUrl()

	method getToken()
	method getUrl()
	method getErrors()

	data FToken
	data FUrl  
	data FErrors

endclass


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} new
Construtor

@author  3510 - Gilmar P. Santos
@version	P10
@since	26/02/2010
/*/
//-------------------------------------------------------------------------------------
method new() class biECMWorkflow
	::FErrors := {}
	::FToken := ""
	::FUrl := ""
return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getToken
Retorna o token gerado pelo método buildToken()

@author  3510 - Gilmar P. Santos
@version	P10
@since	26/02/2010
/*/
//-------------------------------------------------------------------------------------
method getToken() class biECMWorkflow

return ::FToken
                        
             
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getUrl
Retorna a URL gerado pelo método buildURL()

@author  3510 - Gilmar P. Santos
@version	P10
@since	26/02/2010
/*/
//-------------------------------------------------------------------------------------
method getUrl() class biECMWorkflow

return ::FUrl


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getErrors
Retorna uma array com os erros encontrados nos processamentos

@author  3510 - Gilmar P. Santos
@version	P10
@since	26/02/2010
/*/
//-------------------------------------------------------------------------------------
method getErrors() class biECMWorkflow

return aClone( ::FErrors )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildToken
Gera um token baseado no usuário e senha informados

@author  3510 - Gilmar P. Santos
@version	P10
@since	26/02/2010
/*/
//-------------------------------------------------------------------------------------
method buildToken( cUser, cPwd ) class biECMWorkflow
	local obj		:= WSTokenServiceService():new()
	local cUrlWS	:= ""
	local cToken	:= ""
	local lRet		:= .T.
	
	local cTmpPwd	:= ""
	
	::FErrors := {}
	::FToken := ""

	if ( valtype( cUser ) == "U" ) .and. ( valtype( cPwd ) == "U" )
		cUser := usrRetName( __cUserID )

		cTmpPwd := PswMD5GetPass( __cUserID )

		if !Empty( cTmpPwd ) .and. valtype( cTmpPwd ) == "C"
			cPwd := "MD5:" + cTmpPwd
		else
			cPwd := ""
		endif
	else
		if !Empty( cPwd )
			if !( ( len( cPwd ) == 36 ) .and. ( left( cPwd, 4 ) == "MD5:" ) )
				cPwd := "MD5:" + md5( cPwd )
			endif
		endif
	endif

	if !Empty( cPwd )
		cUrlWS := getMv( "MV_ECMWS", .F., "" )
		if len( alltrim( cUrlWS ) ) > 0
			cUrlWS := cUrlWS + "/TokenService"
			obj:_URL := cUrlWS
	    	BISetLogEvent( ECM_EV_LEVEL_INFO, "TokenService", STR0008 + ": " + cUrlWS ) //###"Conectando no WS"
	
			if ECM_DEBUG
				wsdldbglevel(2)
			endif
	
			if obj:GetToken( allTrim( cUser ), Alltrim( cPwd ) )
				cToken := obj:cResult
				
				if !Empty( cToken )
					if obj:validateToken( Alltrim( cToken ) )
						if !( upper( Alltrim( obj:cResult ) ) == upper( Alltrim( cUser ) ) )
							lRet := .F.
							BISetLogEvent( ECM_EV_LEVEL_ERROR, "TokenService", STR0007 )
							aAdd( ::FErrors, STR0007 )//###"Usuário ou senha incorreto"
						endif
					else
						lRet := .F.
						BISetLogEvent( ECM_EV_LEVEL_ERROR, "TokenService", getWscError() )
						aAdd( ::FErrors, getWscError() )
					endif
				else
					lRet := .F.
					BISetLogEvent( ECM_EV_LEVEL_ERROR, "TokenService", STR0007 )
					aAdd( ::FErrors, STR0007 )//###"Usuário ou senha incorreto"
				endif
			else
				lRet := .F.
				BISetLogEvent( ECM_EV_LEVEL_ERROR, "TokenService", getWscError() )
				aAdd( ::FErrors, getWscError() )
			endif
		else
			lRet := .F.
			BISetLogEvent( ECM_EV_LEVEL_ERROR, "TokenService", STR0011 ) //###"Parametro (MV) MV_ECMWS nao configurado"
			aAdd( ::FErrors, STR0011 ) //###"Parametro (MV) MV_ECMWS nao configurado"
		endif
	else
		lRet := .F.
		BISetLogEvent(ECM_EV_LEVEL_ERROR, "TokenService", STR0013 + CRLF + STR0014) //###"Usuário não pode inicializar tarefas." "Usuários administradores não podem realizar esta operação"
		aAdd( ::FErrors, STR0013 + CRLF + STR0014 )
	endif

	if lRet
		::FToken := cToken
	endif

return lRet
               

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildUrl
Constrói uma URL a partir do código de uma instância ECM

@author  3510 - Gilmar P. Santos
@version	P10
@since	26/02/2010
/*/
//-------------------------------------------------------------------------------------
method buildUrl( xIdProc ) class biECMWorkflow
	local cUrlWS	:= ""
	local cUrl		:= ""
	local lRet		:= .T.
	local nPos		:= 0
	local cTo		:= ""
	local cIdProc	:= ""

	::FErrors := {}

	if valtype( xIdProc ) == "N"
		cIdProc := str( xIdProc )
	else 
		cIdProc := xIdProc
	endif

	cIdProc := Alltrim( cIdProc )

	cUrlWS := getMv( "MV_ECMWS", .F., "" )
	if len( alltrim( cUrlWS ) ) > 0

		if right(cUrlWS, 1) == "/"
			cUrlWS := substr( cUrlWS, 1, len( cUrlWS ) - 1 )
		endif

		nPos := rat( "/", cUrlWS )

		cTo := "&josso_cmd=true&josso_back_to=" + substr( cUrlWS, nPos ) + "/workflowstate?pi=" + cIdProc

		cUrl := substr( cUrlWS, 1, nPos ) + "josso/signon/ExternalLogin.do?t=" + ::FToken + cTo
	else
		lRet := .F.
		BISetLogEvent( ECM_EV_LEVEL_ERROR, "URLECMWorkFlow", STR0011 ) //###"Parametro (MV) MV_ECMWS nao configurado"
		aAdd( ::FErrors, STR0011 ) //###"Parametro (MV) MV_ECMWS nao configurado"
	endif

	if lRet
		::FUrl := cUrl
	endif

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} biPrtECMwf
Abre uma dialog com o fluxo do processo do TOTVS ECM posicionado na posição atual (via código protheus)

@param cTpProc Tipo de Processo
@param cIdProc Código protheus do processo
@param nWidth Largura da janela (opcional, padrão = 750)
@param nHeight Altura da janela (opcional, padrão = 550)
@param cCaption Título da janela (opcional, padrão = "TOTVS ECM")
@param cUsr Usuário (opcional, padrão = usuário logado no Protheus)
@param cPwd Senha (opcional, padrão = senha MD5 do usuário logado no Protheus)
@author Gilmar P. Santos
@version P11
@since 26/02/2010
/*/
//-------------------------------------------------------------------
Function biPrtECMWF(cTpProc, cIdProc, nWidth, nHeight, cCaption, cUsr, cPwd)
	local xIdProc := biPrt2Ecm( cTpProc, cIdProc )
	
	if !Empty( xIdProc )
		biECMWF(xIdProc, nWidth, nHeight, cCaption, cUsr, cPwd)
	else
		msgStop( STR0020 )	//###"Processo não localizado
	endif

return               


//-------------------------------------------------------------------
/*/{Protheus.doc} biECMWF
Abre uma dialog com o fluxo do processo do TOTVS ECM posicionado na posição atual (via código da instância)

@param xIdProc Código da instância ECM
@param nWidth Largura da janela (opcional, padrão = 750)
@param nHeight Altura da janela (opcional, padrão = 550)
@param cCaption Título da janela (opcional, padrão = "TOTVS ECM")
@param cUsr Usuário (opcional, padrão = usuário logado no Protheus)
@param cPwd Senha (opcional, padrão = senha MD5 do usuário logado no Protheus)
@author Gilmar P. Santos
@version P11
@since 26/02/2010
/*/
//-------------------------------------------------------------------
Function biECMWF(xIdProc, nWidth, nHeight, cCaption, cUsr, cPwd)
	local lOk			:= .F.
	local cUrl			:= ""
	local oECMwf		:= nil
	local oDlg			:= nil
	local oBtn1			:= nil
	local oBtn2			:= nil
	local oTIBrowser	:= nil 
	local cErrMsg		:= ""
	
	default nWidth		:= 750
	default nHeight	:= 550
	default cCaption	:= "TOTVS ECM"

	oECMwf := biECMWorkflow():new()

	lOk := oECMwf:buildToken( cUsr, cPwd )
	lOk := lOk .and. oECMwf:buildUrl( xIdProc )

	if lOk
		cUrl := oECMwf:getUrl()

		oDlg := TDialog():New( , , , , , , , , nil, , , , , .T. )

		oDlg:nWidth    := nWidth
		oDlg:nHeight   := nHeight
		oDlg:cCaption  := cCaption

		oTIBrowser := TIBrowser():New( 0, 0, 0, 0, "", oDlg )	
		oTIBrowser:nLeft := 5
		oTIBrowser:nTop := 5
		oTIBrowser:nWidth := oDlg:nWidth - 15
		oTIBrowser:nHeight := oDlg:nHeight - 65

		oTIBrowser:Navigate( cUrl )

		oBtn1 := TButton():Create(oDlg)
		oBtn1:nLeft := oDlg:nWidth - 95
		oBtn1:nTop := oDlg:nHeight - 50
		oBtn1:nWidth := 80
		oBtn1:nHeight := 20
		oBtn1:cCaption := STR0018	//###"Fechar"
		oBtn1:bAction := {||oDlg:end()}

		oBtn2 := TButton():Create(oDlg)
		oBtn2:nLeft := oBtn1:nLeft - oBtn1:nWidth - 10
		oBtn2:nTop := oBtn1:nTop
		oBtn2:nWidth := oBtn1:nWidth
		oBtn2:nHeight := oBtn1:nHeight
		oBtn2:cCaption := STR0019	//###"Atualizar"
		oBtn2:bAction := {||oTIBrowser:Navigate( cUrl )}

		oDlg:activate(/*[ uParam1]*/, /*[ uParam2]*/, /*[ uParam3]*/, .T. )
	else
		cErrMsg := ""
		aEval( oECMwf:getErrors(), {|x| cErrMsg += ( x + CRLF )} )

		msgStop( cErrMsg )
	endif

return