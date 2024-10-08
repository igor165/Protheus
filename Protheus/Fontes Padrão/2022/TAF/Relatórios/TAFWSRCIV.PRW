#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFWSRCIV
@type			method
@description	Servi�o de Relat�rio de Confer�ncia de Incid�ncias de Verbas
@author			Felipe C. Seolin
@since			16/04/2019
/*/
//---------------------------------------------------------------------
WSRESTFUL TAFWSRCIV DESCRIPTION "Servi�o de Relat�rio de Confer�ncia de Incid�ncias de Verbas" FORMAT APPLICATION_JSON

WSDATA sourceBranch	AS STRING
WSDATA period		AS STRING

/* Como deve ser recebido as rubricas
rubricas
	filial
	codigo
	descricao
	tipo
	referencia
	calculaINSS
	calculaIRRF
	calculaFGTS
	calculaSind
	idCalculo
	natureza
	incidINSS
	incidIRRF
	incidFGTS
	incidSind
*/

WSMETHOD GET	DESCRIPTION "M�todo para consultar o resultado do processamento do relat�rio de confer�ncia de incid�ncias de verbas"	WSSYNTAX "/getResult/"	PATH "/getResult/"
WSMETHOD POST	DESCRIPTION "M�todo para executar o relat�rio de confer�ncia de incid�ncias de verbas"

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	M�todo para executar o Relat�rio de Confer�ncia de Incid�ncias de Verbas.
@author			Felipe C. Seolin
@since			16/04/2019
@return			lRet	-	Indica se o m�todo aceitou a execu��o do relat�rio
/*/
//---------------------------------------------------------------------
WSMETHOD POST WSSERVICE TAFWSRCIV

Local oJSON			:=	Nil
Local cErroJSON		:=	""
Local cFuncIPC		:=	""
Local cFuncREST		:=	"TAFRCIV"
Local cCodErr		:=	""
Local cDescErr		:=	""
Local cCodFilERP	:=	""
Local cEmpTAF		:=	""
Local cFilTAF		:=	""
Local cTicket		:=	""
Local cBody			:=	::GetContent()
Local lRet			:=	.T.

If Empty( cBody )
	lRet := .F.
	::Self:SetResponse( SetMsgResp( lRet, "Requisi��o n�o possui par�metros no corpo da mensagem." ) )
Else
	cCodFilERP := WSGetPostFil( cBody )

	If Empty( cCodFilERP )
		lRet := .F.
		::Self:SetResponse( SetMsgResp( lRet, "N�o foi poss�vel identificar o par�metro sourceBranch no corpo da mensagem." ) )
	Else
		oJSON := JSONObject():New()
		cErroJSON := oJSON:FromJSON( cBody )
		If Empty( cErroJSON )
			If ValType( oJSON["period"] ) == "U"
				lRet := .F.
				::Self:SetResponse( SetMsgResp( lRet, "N�o foi poss�vel identificar o par�metro period no corpo da mensagem." ) )
			ElseIf ValType( oJSON["rubricas"] ) == "U"
				lRet := .F.
				::Self:SetResponse( SetMsgResp( lRet, "N�o foi poss�vel identificar o par�metro rubricas no corpo da mensagem." ) )
			Else
				If WSST2ValFil( cCodFilERP, @cFuncIPC, @cCodErr, @cDescErr, .T., @cFilTAF, @cEmpTAF )
					::Self:SetContentType( "application/json" )

					RpcSetType( 3 )
					RpcSetEnv( cEmpTAF, cFilTAF,,,"TAF","TAFWSRCIV")

					If TAFAlsInDic( "V3J" )
						DBSelectArea( "V3J" )
						V3J->( DBSetOrder( 2 ) )

						If V3J->( MsSeek( xFilial( "V3J" ) + PadR( "TAFWSRCIV", TamSX3( "V3J_SERVIC" )[1] ) + PadR( "POST", TamSX3( "V3J_METODO" )[1] ) + "1" ) )
							lRet := .F.
							::Self:SetResponse( SetMsgResp( lRet, "Existe um processamento em andamento. Aguarde o t�rmino para uma nova requisi��o." ) )
						Else
							cTicket := GeraTicket()

							If TAFSCALLIPC( cFuncIPC, cFuncREST,,,, {}, cBody, cFilTAF, cTicket )//a partir daqui reavaliar
								lRet := .T.
								::Self:SetResponse( SetMsgResp( lRet, "Requisi��o atendida, opera��o em processamento", cTicket ) )
							Else
								lRet := .F.
								::Self:SetResponse( SetMsgResp( lRet, "Time Out." ) )
							EndIf
						EndIf
					Else
						lRet := .F.
						::Self:SetResponse( SetMsgResp( lRet, "Estrutura de dicion�rio do TAF desatualizada. Necess�rio a compatibiliza��o da estrutura para cria��o da tabela V3J." ) )
					EndIf
				Else
					lRet := .F.
					::Self:SetResponse( SetMsgResp( lRet, cDescErr ) )
				EndIf
			EndIf
		Else
			lRet := .F.
			::Self:SetResponse( SetMsgResp( lRet, "Falha na recep��o dos dados: " + AllTrim( cErroJSON ) ) )
		EndIf
	EndIf
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	M�todo para consultar o status do processamento da exclus�o dos registros do evento de afastamento do eSocial ( S-2230 ).
@author			Felipe C. Seolin
@since			06/11/2018
@return			lRet	-	Indica se o m�todo aceitou a execu��o do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET WSSERVICE TAFWSRCIV

Local lRet	:= .T.

/* Verificar qual empresa/filial subir
RpcSetType( 3 )
RpcSetEnv( cEmpTAF, cFilTAF )
*/

/*

		REAVALIAR O GET

*/

If TAFAlsInDic( "V3J" )
	::SetContentType( "application/json" )

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )

	If Len( ::aURLParms ) == 1
		If ::aURLParms[1] == "getResult"
			If !Empty( ::aURLParms[2] )
				If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cTicket, TamSX3( "V3J_ID" )[1] ) ) )
					If V3J->V3J_STATUS == 1
						lRet := .T.
						::Self:SetResponse( SetMsgResp( "Execu��o do relat�rio de confer�ncia de incid�ncias de verbas em andamento.", "2" ) )
					ElseIf V3J->V3J_STATUS == 2
						lRet := .T.
						::Self:SetResponse( SetMsgResp( "Execu��o do relat�rio de confer�ncia de incid�ncias de verbas finalizado.", "0" ) )
					EndIf
				Else
					lRet := .T.
					::Self:SetResponse( SetMsgResp( "N�o h� registro de execu��o do relat�rio de confer�ncia de incid�ncias de verbas para este ticket.", "9" ) )
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Par�metro inv�lido." ) )
			EndIf
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "N�o foi encontrado o ." ) )
		EndIf
	Else
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Par�metros incompletos." ) )
	EndIf
Else
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Estrutura de dicion�rio do TAF desatualizada. Necess�rio a compatibiliza��o da estrutura para cria��o da tabela V3J." ) )
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFRCIV
@type			function
@description	Rotina para gerar o relat�rio de confer�ncia de incid�ncias de verbas.
@author			Felipe C. Seolin
@since			18/04/2019
@param			cUID		-	OBSOLETO. Identificador da sess�o de vari�veis globais
@param			cChave		-	OBSOLETO. Identificador da chave ( Tabela X ) HashMap
@param			cValorR		-	OBSOLETO. Vari�vel onde ser� armazenado o valor da chave ( Tabela A )
@param			aQryParam	-	OBSOLETO. Par�metros de entrada do m�todo
@param			cBody		-	Mensagem enviada no corpo da mensagem
@param			cFilTAF		-	Filial do TAF
@param			cTicket		-	Ticket da requisi��o
/*/
//---------------------------------------------------------------------
Function TAFRCIV( cUID, cChave, cValorR, aQryParam, cBody, cFilTAF, cTicket )

Local oJSON	:=	Nil

cFilAnt := cFilTAF

// Criar/chamar rotina para o relat�rio de confer�ncia de incid�ncias de verbas.
Sleep( 10000 )

If UpdTicket( cTicket )
	//Indica sucesso
Else
	//Tratamento para insucesso
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GeraTicket
@type			function
@description	Cria e armazena ticket para a requisi��o.
@author			Felipe C. Seolin
@since			18/04/2019
@param			cTicket		-	Ticket da requisi��o
/*/
//---------------------------------------------------------------------
Static Function GeraTicket()

Local oModelV3J	:=	FWLoadModel( "TAFA531" )
Local cTicket	:=	FWuuId( "TAFWSRCIV" )

oModelV3J:SetOperation( MODEL_OPERATION_INSERT )
oModelV3J:Activate()

oModelV3J:LoadValue( "MODEL_V3J", "V3J_ID", cTicket )
oModelV3J:LoadValue( "MODEL_V3J", "V3J_SERVIC", "TAFWSRCIV" )
oModelV3J:LoadValue( "MODEL_V3J", "V3J_METODO", "POST" )
oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTREQ", Date() )
oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRREQ", StrTran( Time(), ":", "" ) )
oModelV3J:LoadValue( "MODEL_V3J", "V3J_STATUS", "1" )

FWFormCommit( oModelV3J )

oModelV3J:DeActivate()

oModelV3J:Destroy()

Return( cTicket )

//---------------------------------------------------------------------
/*/{Protheus.doc} UpdTicket
@type			function
@description	Atualiza a resposta para a requisi��o de um determinado ticket.
@author			Felipe C. Seolin
@since			18/04/2019
@param			cTicket		-	Ticket da requisi��o
@param			cResponse	-	Resposta da requisi��o
@return			lRet		-	Indica se armazenou o resultado da requisi��o
/*/
//---------------------------------------------------------------------
Static Function UpdTicket( cTicket, cResponse )

Local oModelV3J	:=	FWLoadModel( "TAFA531" )
Local lRet		:=	.F.

If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cTicket, TamSX3( "V3J_ID" )[1] ) ) )
	oModelV3J:SetOperation( MODEL_OPERATION_UPDATE )
	oModelV3J:Activate()

	oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTRESP", Date() )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRRESP", Time() )
	//oModelV3J:LoadValue( "MODEL_V3J", "V3J_RESP", cResponse )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_RESP", "Teste" ) //Remover quando mecanismo de resposta estiver pronto

	FWFormCommit( oModelV3J )

	oModelV3J:DeActivate()

	lRet := .T.
EndIf

oModelV3J:Destroy()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} SetMsgResp
@type			function
@description	Formata a mensagem no padr�o Json.
@author			Felipe C. Seolin
@since			18/04/2019
@param			lStatus		-	Indica se a opera��o foi conclu�da com sucesso
@param			cMessage	-	Descri��o da execu��o
@param			cTicket		-	Ticket da requisi��o
@return			cResponse	-	Resposta formatada no padr�o Json
/*/
//---------------------------------------------------------------------
Static Function SetMsgResp( lStatus, cMessage, cTicket )

Local cResponse	:=	""

Default cTicket	:=	""

cResponse := '{'

cResponse += '"status" : "' + Iif( lStatus, "true", "false" ) + '"'
cResponse += ','

If !Empty( cTicket )
	cResponse += '"ticket" : "' + cTicket + '"'
	cResponse += ','
EndIf

cResponse += '"description" : "' + EncodeUTF8( cMessage ) + '"'

cResponse += '}'

Return( cResponse )
