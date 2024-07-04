#INCLUDE "WEBDESKINTEGRATION.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "ECMCONST.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIWSECMIntegration
Webservice de integração do produto TOTVS ECM com o Microsiga Protheus. Será utilizado para chamadas a Tarefas (atividades) do Workflow do ECM

@author  Paulo R. Vieira
@version P10 R1.3
@since   15/04/2009
/*/
//-------------------------------------------------------------------
WSService BIWsECMIntegration DESCRIPTION STR0001 namespace "http://webservices.totvs.com.br/biwsecmintegration.apw" //"WebService de Integração entre o TOTVS ECM e o Microsiga Protheus"
	
	WSData UserLogin			As String
	WSData Password			As String
	WSData SecurityToken		As String

	WSData TpProcess			As String
	WSData IdEcm				As String

	WSData RetData				As String
	WSData Params				As String
	
	WSMethod Login				description STR0002 //###"Realiza a identificação e login do usuário no WebService do Protheus"
	WSMethod ExecTask			description STR0003 //###"Requisita a execução de uma função no microsiga protheus"

EndWSService

//-------------------------------------------------------------------
/*/{Protheus.doc} Login
Realiza a identificação e login do usuário no WebService do Protheus

@param UserLogin string de identificação do usuário
@param Password string com a senha do usuário
@author  Paulo R. Vieira
@version P10 R1.3
@since   15/04/2009
@return  string contendo o SecurityToken que será utiliziado em todas as chamadas desse WebService
/*/
//-------------------------------------------------------------------
WSMethod Login WSReceive UserLogin, Password WSSend SecurityToken WSService BIWSECMIntegration
	
	Local lRetOK := .T.
 
	::UserLogin := allTrim(::UserLogin)
	::Password := allTrim(::Password)

	BISetLogEvent(ECM_EV_LEVEL_INFO, "BIWSECMIntegration:Login", STR0002, {::UserLogin, ::Password})
	
	If empty(::UserLogin) .OR. empty(::Password)
		BISetLogEvent(ECM_EV_LEVEL_ERROR, "BIWSECMIntegration:Login", STR0004)

		SetSOAPFault(STR0004, "BIWSECMIntegration:Login - UserLogin:" + DwStr(::UserLogin) + " Password:" + DwStr(::Password)) //### "Passagem de parâmetros incorreta."
		lRetOK := .F.
	// realiza o login no Protheus
	ElseIf !BIECMLogin( ::UserLogin, ::Password )
		BISetLogEvent(ECM_EV_LEVEL_ERROR, "BIWSECMIntegration:Login", STR0007)

		SetSOAPFault(STR0007, "BIWSECMIntegration:Login - UserLogin:" + DwStr(::UserLogin) + " Password:" + DwStr(::Password)) //### "Usuário ou senha incorretos. Por favor, verifique novamente."
		lRetOK := .F.
	EndIf

	if lRetOK
		::SecurityToken := generateSecurityToken(::UserLogin, ::Password)
	endif

Return lRetOK

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecTask
Requisita a execução de uma tarefa no microsiga protheus

@param SecurityToken string de identificação da sessão de trabalho
@param TpProcess string identificadora do processo
@param IdEcm string com o id da instância do processo no TOTVS ECM
@param Params string com parâmetros
@author  Paulo R. Vieira
@version P10 R1.3
@since   15/04/2009
@return  possível retorno da função iniciada no start
/*/
//-------------------------------------------------------------------
WSMethod ExecTask WSReceive SecurityToken, TpProcess, IdEcm, Params WSSend RetData WSService BIWSECMIntegration

	Local lRet := .F.
	Local xData:= NIL

	BISetLogEvent(ECM_EV_LEVEL_INFO, "BIWSECMIntegration:ExecTask", STR0003, {SecurityToken, TpProcess, IdEcm, Params})

	lRet := BIExecUserFunction(::TpProcess, ::IdEcm, ::Params, ::SecurityToken, @xData)

	::RetData := xData

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} generateSecurityToken
Gera um SecurityToken a partir de um usuário e senha

@protected
@param acUserLogin string com o login do usuário
@param acPassword string com a senha do usuário
@author  Paulo R. Vieira
@version P10 R1.3
@since   15/04/2009
@return  RetOK booleano confirmando se o envio foi com sucesso
/*/
//-------------------------------------------------------------------
static function generateSecurityToken(acUserLogin, acPassword)
	
return DwEncodeParm("", DWConcatWSep("!", { acPassword, Date(), acUserLogin }))

//-------------------------------------------------------------------
/*/{Protheus.doc} securityTokenInfo
Recupera informações de um SecurityToken, como usuário, senha e etc.

@protected
@param acSecurityToken string contendo o Security Token de onde serão extraídas as informações 
@author  Paulo R. Vieira
@version P10 R1.3
@since   15/04/2009
@return  Array de String contendo os valores nos índices: [0]=EmpFil, [1]=Password, [2]=DateGeração, [3]=acUserLogin
/*/
//-------------------------------------------------------------------
static function securityTokenInfo(acSecurityToken)
	
return DwToken(DwDecodeParm(acSecurityToken), "!", .F.)

//-------------------------------------------------------------------
/*/{Protheus.doc} validSecurityToken
Realiza a validação de um SecurityToken

@protected
@param acUserLogin string com o login do usuário a ser validado
@param acPassword string com a senha do usuário a ser validado
@param acTokenToValided string contendo o Security Token que será validado
@author  Paulo R. Vieira
@version P10 R1.3
@since   15/04/2009
@return  booleano sendo .T. caso seja um Security Token válido e .F. caso contrário
/*/
//-------------------------------------------------------------------
static function validSecurityToken(acUserLogin, acPassword, acTokenToValided)
	Local bValid := .F.
	
	If acTokenToValided == generateSecurityToken(acUserLogin, acPassword)
		bValid := .T.
	EndIf
	
return bValid

//-------------------------------------------------------------------
/*/{Protheus.doc} BIExecUserFunction
Executa uma User Function que foi definido no parâmetro acFunction

@protected
@param cTpProcess string com a identificação do processo (prefixo "MVC:" indica rotinas que possuem tratamentos padrões)
@param cIdEcm string com a identificação da instância do processo no TOTVS ECM
@param xParams parâmetros
@param cSecurityToken string contendo o Security Token utilizado na operação
@param xRetParams parâmetros que foram retornados pela função executada
@author  Paulo R. Vieira
@version P10 R1.3
@since   15/04/2009
@return  booleano sendo .T. caso execução com sucesso e .F. caso contrário

@obs	Se for informado um processo com tratamento padrão será executada a função "biEcmInteg" 
		parâmetros de biEcmInteg: <cTpProcess (sem prefixo)>, <código protheus>, <cIdEcm>, <xParams>
		a rotina biEcmInteg deve retornar uma string

/*/
//-------------------------------------------------------------------
static function BIExecUserFunction(cTpProcess, cIdEcm, xParams, cSecurityToken, xRetParams)
	Local aUserInfo	:= securityTokenInfo(cSecurityToken)
	Local cIdPrt		:= ""
	Local lRetOK		:= .F.

	default xRetParams := ""

	If !validSecurityToken(aUserInfo[3], aUserInfo[1], cSecurityToken)
		SetSOAPFault("BIWSECMIntegration:BIExecUserFunction", STR0005) //###"Security Token INVÁLIDO"
	Else
		//Verifica se é tratamento automático (rotina MVC)
		If Upper( left( cTpProcess, 4 ) ) == "MVC:"
			Begin Sequence
				cIdPrt := Alltrim( biECM2Prt( substr( cTpProcess, 5 ), cIdEcm ) )
				xRetParams := biEcmInteg( substr( cTpProcess, 5 ), cIdPrt, cIdEcm, xParams )

				lRetOK := .T.

				BISetLogEvent(ECM_EV_LEVEL_INFO, "BIWSECMIntegration:BIExecUserFunction", "Param returned", {xRetParams})
			Recover
				SetSOAPFault("BIWSECMIntegration:BIExecUserFunction", STR0006) //###"Erro na execução da rotina"
			End Sequence
		ElseIf Upper( left( cTpProcess, 7 ) ) == "FINISH:"
			Begin Sequence
				cIdPrt := Alltrim( biECM2Prt( substr( cTpProcess, 8 ), cIdEcm ) )
				xRetParams := biEcmFinish( substr( cTpProcess, 8 ), cIdPrt, cIdEcm )

				lRetOK := .T.

				BISetLogEvent(ECM_EV_LEVEL_INFO, "BIWSECMIntegration:BIExecUserFunction", "Param returned", {xRetParams})
			Recover
				SetSOAPFault("BIWSECMIntegration:BIExecUserFunction", STR0006) //###"Erro na execução da rotina"
			End Sequence
		Else
			If Existblock( "ECMINTEG" )
				Begin Sequence
					cIdPrt := Alltrim( biECM2Prt( cTpProcess, cIdEcm ) )

					xRetParams := ExecBlock( "ECMINTEG", .F., .F., {cTpProcess, cIdPrt, cIdEcm, xParams} )

					lRetOK := .T.

					BISetLogEvent(ECM_EV_LEVEL_INFO, "BIWSECMIntegration:BIExecUserFunction", "Param returned", {xRetParams})
				Recover
					SetSOAPFault("BIWSECMIntegration:BIExecUserFunction", STR0006) //###"Erro na Rotina da Tarefa/Task"
				End Sequence
			Else
				lRetOK := .T.
			EndIf
		EndIf
	EndIf

return lRetOK

//-------------------------------------------------------------------
/*/{Protheus.doc} BIECMLogin
Realiza/valida o login do usuário de integração com o Portal Protheus

@protected
@param acUserLogin string com o login do usuário
@param acPassword string com a senha do usuário
@author  Paulo R. Vieira
@version P10 R1.3
@since   15/04/2009
@return  booleano sendo .T. caso o login seja executado com sucesso e .F. caso contrário
@todo Unificar login com o Portal Protheus
/*/
//-------------------------------------------------------------------
static function BIECMLogin(acUserLogin, acPassword)
	local cPwdEcm	:= ""	
	local cUsrEcm	:= ""
	local aUsrPrt	:= {}
	local nPos		:= 0
	local lRet		:= .F.
	
	local cTmpPwd	:= ""

	cUsrEcm	:= Alltrim( acUserLogin )
	cPwdEcm := Alltrim( acPassword )

	if ( len( cPwdEcm ) == 36 ) .and. ( left( cPwdEcm, 4 ) == "MD5:" )
		cPwdEcm := substr( cPwdEcm, 5 )
	else
		cPwdEcm := md5( cPwdEcm )
	endif

	//TODO: Autenticar com rotina no framework
	__ap5nomv( .T. )
	aUsrPrt := allUsers()
	__ap5nomv( .F. )

	nPos := aScan( aUsrPrt, {|x| Alltrim( x[1][2] ) == cUsrEcm} )
	if nPos > 0

		cTmpPwd := PswMD5GetPass( aUsrPrt[nPos][1][1] )

		if !Empty( cTmpPwd ) .and. valtype( cTmpPwd ) == "C"
			lRet := ( cTmpPwd == cPwdEcm )
		else
			lRet := .F.
		endif

	endif

return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} biEcmFinish
Finaliza processo

@protected
@param cTpProc Tipo de Processo
@param cCodPrt Código do Processo Protheus
@param cCodECM Código do Processo ECM
@author  Gilmar P. Santos
@version P10 R1.3
@since   03/03/2010
/*/
//-------------------------------------------------------------------
static function biEcmFinish( cTpProc, cCodPrt, cCodECM )
	local aArea		:= GetArea()
	local lOk		:= .F.
	local cFilPrt	:= xFilial(ECM_TABLE_NAME)

	cTpProc	:= padr( cTpProc, 10 )
	cCodPrt	:= padr( cCodPrt, 240 )
	cCodECM	:= padr( cCodECM, 240 )

	chkfile( ECM_TABLE_NAME )
	dbSelectArea( ECM_TABLE_NAME )
   
	(ECM_TABLE_NAME)->( dbSetOrder( ECM_ORDER_PRT ) )
	(ECM_TABLE_NAME)->( dbSeek( cFilPrt + cTpProc + cCodPrt ) )

	if ! ( (ECM_TABLE_NAME)->( EoF() ) )
		RecLock( ECM_TABLE_NAME, .F. )

		(ECM_TABLE_NAME)->(&(ECM_FIELD_PREFIX + "_DTFIM")) := date()

		MsUnLock()
	endif
	
	RestArea( aArea )

return
