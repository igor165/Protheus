#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFWSEXC2230
@type			method
@description	Serviço de eliminação dos registros do evento de afastamento ( S-2230 ) do eSocial.
@author			Felipe C. Seolin
@since			06/11/2018
/*/
//---------------------------------------------------------------------
WSRESTFUL TAFWSEXC2230 DESCRIPTION "Serviço de eliminação dos registros do evento de afastamento ( S-2230 ) do eSocial" FORMAT APPLICATION_JSON

WSDATA sourceBranch AS STRING
WSDATA verifStatus3 AS BOOLEAN OPTIONAL

WSMETHOD GET	DESCRIPTION "Método para consultar o status do processamento da exclusão dos registros do evento de afastamento do eSocial ( S-2230 )"	WSSYNTAX "/post/getStatus/"	PATH "/post/getStatus/"
WSMETHOD POST	DESCRIPTION "Método para executar a exclusão dos registros do evento de afastamento do eSocial ( S-2230 )"

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Método para executar a exclusão dos registros do evento de afastamento do eSocial ( S-2230 ).
@author			Felipe C. Seolin
@since			06/11/2018
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST WSSERVICE TAFWSEXC2230

Local cFuncIPC		:=	""
Local cFuncREST		:=	"TAFDEL2230"
Local cChave		:=	"PROCDEL2230"
Local cUID			:=	"UIDPROCDEL2230"
Local cValorR		:=	"RESPPROCDEL2230"
Local cCodErr		:=	""
Local cDescErr		:=	""
Local cCodFilERP	:=	""
Local cFilTAF		:=	""
Local cBody			:=	::GetContent()
Local nVal			:=	0
Local lRet			:=	.T.

VarGetXD( cUID, cChave, @nVal )

If nVal == 1
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Existe um processamento em andamento. Aguarde o término para uma nova requisição." ) )
Else
	VarSetUID( cUID, .T. )

	If Empty( cBody )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Requisição não possui parâmetros no corpo da mensagem." ) )
	Else
		cCodFilERP := WSGetPostFil( cBody )

		If Empty( cCodFilERP )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Não foi possível identificar o parâmetro sourceBranch no corpo da mensagem." ) )
		Else
			If WSST2ValFil( cCodFilERP, @cFuncIPC, @cCodErr, @cDescErr, .T., @cFilTAF )
				::Self:SetContentType( "application/json" )

				If TAFSCALLIPC( cFuncIPC, cFuncREST, cUID, cChave, cValorR, {}, cBody, cFilTAF )
					lRet := .T.
					::Self:SetResponse( SetMsgResp( "Requisição atendida, operação em processamento" ) )
				Else
					lRet := .F.
					SetRestFault( 408, EncodeUTF8( "Time Out." ) )
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( cDescErr ) )
			EndIf
		EndIf
	EndIf
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Método para consultar o status do processamento da exclusão dos registros do evento de afastamento do eSocial ( S-2230 ).
@author			Felipe C. Seolin
@since			06/11/2018
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET WSSERVICE TAFWSEXC2230

Local cUID		:=	"UIDPROCDEL2230"
Local cChave	:=	"PROCDEL2230"
Local nVal 		:=	0
Local lRet		:= .T.

::SetContentType( "application/json" )

If Len( ::aURLParms ) > 1
	If ::aURLParms[2] == "getStatus"
		If VarGetXD( cUID, cChave, @nVal )
			If nVal == 1
				lRet := .T.
				::Self:SetResponse( SetMsgResp( "Processo de exclusão em execução.", "2" ) )
			ElseIf nVal == 9
				lRet := .T.
				::Self:SetResponse( SetMsgResp( "Para que o processo seja executado, é necessário que o parâmetro MV_TAF2230 esteja definido com valor .T.", "9" ) )
			Else
				lRet := .T.
				::Self:SetResponse( SetMsgResp( "Processo de exclusão finalizado.", "0" ) )
			EndIf
		Else
			lRet := .T.
			::Self:SetResponse( SetMsgResp( "Não ocorreu nenhuma execução do processo de exclusão após a inicialização do ambiente.", "9" ) )
		EndIf
	Else
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Parâmetro inválido." ) )
	EndIf
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDEL2230
@type			function
@description	Rotina para gerar registros do evento S-3000 a partir dos registros do evento S-2230.
@author			Felipe C. Seolin
@since			02/10/2018
@param			cUID		-	Identificador da sessão de variáveis globais
@param			cChave		-	Identificador da chave ( Tabela X ) HashMap
@param			cValorR		-	Variável onde será armazenado o valor da chave ( Tabela A )
@param			aQryParam	-	Parâmetros de entrada do método
@param			cBody		-	Mensagem enviada no corpo da mensagem
@param			cFilTAF		-	Filial do TAF
/*/
//---------------------------------------------------------------------
Function TAFDEL2230( cUID, cChave, cValorR, aQryParam, cBody, cFilTAF )

Local a3000			:=	{}
Local aDelete		:=	{}
Local aPendency		:=	{}
Local lVerifSts3	:=	.T.
Local lTrans2230	:=	.F.

Private oJson		:=	Nil

cFilAnt := cFilTAF

lTrans2230 := GetMV( "MV_TAF2230",, .F. )

If lTrans2230
	VarSetXD( cUID, cChave, 1 )

	If FWJsonDeserialize( cBody, @oJson )
		If Type( "oJson:verifStatus3" ) <> "U"
			lVerifSts3 := oJson:verifStatus3
		EndIf
	EndIf

	CheckTrans( @aPendency, lVerifSts3 )

	If !Empty( aPendency )
		MontaMsg( cUID, cChave, cValorR,,, aPendency )
	Else
		Begin Transaction
			CriaS3000( @a3000, @aDelete )
			MontaMsg( cUID, cChave, cValorR, a3000, aDelete )
		End Transaction
	EndIf
Else
	VarSetXD( cUID, cChave, 9 )
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} CheckTrans
@type			function
@description	Verifica se há registros do evento S-2230 aguardando retorno de transmissão ou inconsistentes.
@author			Felipe C. Seolin
@since			24/10/2018
@param			aPendency	-	Array com os eventos Inconsistentes ou Aguardando Retorno de Transmissão
@param			lVerifSts3	-	Indica se deve verificar existência de registros do evento de afastamento ( S-2230 ) com status de inconsistência ( 3 )
/*/
//---------------------------------------------------------------------
Static Function CheckTrans( aPendency, lVerifSts3 )

Local cAliasQry	:=	GetNextAlias()
Local cQuery	:=	""

cQuery := "SELECT CM6.CM6_FILIAL, CM6.CM6_ID, CM6.CM6_VERSAO, CM6.CM6_DTAFAS, CM6.CM6_DTFAFA, CM6.CM6_FUNC, C9V.C9V_CPF, C9V.C9V_NIS, CM6.CM6_STATUS "
cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
cQuery += "LEFT JOIN " + RetSqlName( "C9V" ) + " C9V "
cQuery += "  ON C9V.C9V_FILIAL = CM6.CM6_FILIAL "
cQuery += " AND C9V.C9V_ID = CM6.CM6_FUNC "
cQuery += " AND C9V.C9V_ATIVO = '1' "
cQuery += " AND C9V.D_E_L_E_T_ = '' "
cQuery += "WHERE CM6.CM6_FILIAL = '" + xFilial( "CM6" ) + "' "
cQuery += "  AND ( CM6.CM6_STATUS = '2' "

If lVerifSts3
	cQuery += "        OR ( CM6.CM6_STATUS = '3' AND CM6.CM6_ATIVO = '1' ) "
EndIf

cQuery += "        OR ( CM6.CM6_STATUS = '4' AND CM6.CM6_PROTUL = '' ) "
cQuery += "      ) "
cQuery += "  AND CM6.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

TCSetField( cAliasQry, "CM6_DTAFAS", "D" )
TCSetField( cAliasQry, "CM6_DTFAFA", "D" )

While ( cAliasQry )->( !Eof() )
	aAdd( aPendency, { ( cAliasQry )->CM6_FILIAL, ( cAliasQry )->CM6_ID, ( cAliasQry )->CM6_VERSAO, DToC( ( cAliasQry )->CM6_DTAFAS ), DToC( ( cAliasQry )->CM6_DTFAFA ), ( cAliasQry )->CM6_FUNC, ( cAliasQry )->C9V_CPF, ( cAliasQry )->C9V_NIS, ( cAliasQry )->CM6_STATUS } )

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaS3000
@type			function
@description	Cria registros do evento S-3000 para os registros do evento S-2230 encontrados.
@author			Felipe C. Seolin
@since			02/10/2018
@param			a3000	-	Array com registros do evento S-3000 ( Referência )
@param			aDelete	-	Array com registros do evento S-2230 apagados ( Referência )
/*/
//---------------------------------------------------------------------
Static Function CriaS3000( a3000, aDelete )

Local oModelCM6		:=	Nil
Local oModelCMJ		:=	Nil
Local cAliasQry		:=	GetNextAlias()
Local cQuery		:=	""
Local lDeslig		:=	.F.
Local lRetif		:=	.F.

CM6->( DBSetOrder( 1 ) )

oModelCM6 := FWLoadModel( "TAFA261" )
oModelCMJ := FWLoadModel( "TAFA269" )

cQuery := "SELECT CM6.R_E_C_N_O_ CM6_RECONHECIMENTO, CMJ.CMJ_NRRECI "
cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
cQuery += "LEFT JOIN " + RetSqlName( "CMJ" ) + " CMJ "
cQuery += "  ON CMJ.CMJ_FILIAL = CM6.CM6_FILIAL "
cQuery += " AND CMJ.CMJ_TPEVEN = '" + Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2230", "C8E_ID" ) + "' "
cQuery += " AND CMJ.CMJ_NRRECI = CM6.CM6_PROTUL "
cQuery += " AND CMJ.D_E_L_E_T_ = '' "
cQuery += "WHERE CM6.CM6_FILIAL = '" + xFilial( "CM6" ) + "' "
cQuery += "  AND CM6.D_E_L_E_T_ = '' "
cQuery += "ORDER BY CM6.R_E_C_N_O_ "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

( cAliasQry )->( DBGoTop() )

While ( cAliasQry )->( !Eof() )
	CM6->( DBGoTo( ( cAliasQry )->CM6_RECONHECIMENTO ) )

	If TAFChkDesl( CM6->CM6_FUNC )
		lDeslig := .T.
	Else
		lDeslig := .F.
	EndIf

	If TAFChkRetif( CM6->CM6_FUNC, CM6->CM6_PROTUL )
		lRetif := .T.
	Else
		lRetif := .F.
	EndIf

	If !lDeslig .and. !lRetif
		C9V->( DBSetOrder( 2 ) )
		C9V->( MsSeek( xFilial( "C9V" ) + CM6->CM6_FUNC + "1" ) )

		If CM6->CM6_STATUS == "4" .and. Empty( ( cAliasQry )->CMJ_NRRECI ) .and. CM6->CM6_EVENTO <> "E"
			GeraCMJ( @oModelCMJ, @a3000 )
		EndIf

		aAdd( aDelete, { CM6->CM6_FILIAL, CM6->CM6_ID, CM6->CM6_VERSAO, DToC( CM6->CM6_DTAFAS ), DToC( CM6->CM6_DTFAFA ), CM6->CM6_FUNC, C9V->C9V_CPF, C9V->C9V_NIS } )

		oModelCM6:SetOperation( MODEL_OPERATION_DELETE )
		oModelCM6:Activate()
		FWFormCommit( oModelCM6 )
		oModelCM6:DeActivate()
	EndIf

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

oModelCM6:Destroy()
oModelCMJ:Destroy()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GeraCMJ
@type			function
@description	Gera o registro no modelo da tabela CMJ, referente ao Evento S-3000.
@author			Felipe C. Seolin
@since			02/10/2018
@param			oModelCMJ	-	Objeto do modelo da tabela CMJ - Evento S-3000 ( Referência )
@param			a3000		-	Array com registros do evento S-3000 ( Referência )
/*/
//---------------------------------------------------------------------
Static Function GeraCMJ( oModelCMJ, a3000 )

Local cNIS		:=	""
Local cDTAfast	:=	DToS( CM6->CM6_DTAFAS )

oModelCMJ:SetOperation( MODEL_OPERATION_INSERT )
oModelCMJ:Activate()

cNIS := TAF250Nis( C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS, SubStr( cDTAfast, 1, 4 ) + "/" + SubStr( cDTAfast, 5, 2 ), C9V->C9V_NOMEVE )

oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_VERSAO", xFunGetVer() )
oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_TPEVEN", Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2230", "C8E_ID" ) )
oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_CPF", C9V->C9V_CPF )
oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_NIS", cNIS )
oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_REGREF", CM6->( Recno() ) )
oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_NRRECI", CM6->CM6_PROTUL )

FWFormCommit( oModelCMJ )

aAdd( a3000, { cFilAnt, oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_ID" ), oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_VERSAO" ), oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_TPEVEN" ), oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_CPF" ), oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_NIS" ) ,oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_NRRECI" ) } )

oModelCMJ:DeActivate()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TafChkDesl
@type			function
@description	Verifica se o trabalhador está desligado.
@author			Diego Rodolfo dos Santos
@since			09/10/2018
@param			cIDFunc	-	ID do Trabalhador
@return			lRet	-	Indica se o trabalhador está desligado
/*/
//---------------------------------------------------------------------
Static Function TAFChkDesl( cIDFunc )

Local cAliasQry	:=	GetNextAlias()
Local cQuery	:=	""
Local aArea		:=	GetArea()
Local lRet		:=	.F.

cQuery := "SELECT CMD.CMD_STATUS "
cQuery += "FROM " + RetSqlName( "CMD" ) + " CMD "
cQuery += "WHERE CMD.CMD_FILIAL = '" + xFilial( "CMD" ) + "' "
cQuery += "  AND CMD.CMD_FUNC = '" + cIDFunc + "' "
cQuery += "  AND CMD.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY CMD.R_E_C_N_O_ "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

While ( cAliasQry )->( !Eof() )
	If AllTrim( ( cAliasQry )->CMD_STATUS ) == "4"
		lRet := .T.
	ElseIf AllTrim( ( cAliasQry )->CMD_STATUS ) == "7"
		lRet := .F.
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

RestArea( aArea )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFChkRetif
@type			function
@description	Verifica se o registro do evento de afastamento do eSocial ( S-2230 ) sofreu retificação.
@author			Felipe C. Seolin
@since			28/11/2018
@param			cIDFunc	-	ID do Trabalhador
@param			cRecibo	-	Recibo do registro do evento de afastamento
@return			lRet	-	Indica se o registro do evento de afastamento sofreu retificação
/*/
//---------------------------------------------------------------------
Static Function TAFChkRetif( cIDFunc, cRecibo )

Local cAliasQry	:=	GetNextAlias()
Local cQuery	:=	""
Local lRet		:=	.F.

cQuery := "SELECT CM6.CM6_ID "
cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
cQuery += "WHERE CM6.CM6_FILIAL = '" + xFilial( "CM6" ) + "' "
cQuery += "  AND CM6.CM6_FUNC = '" + cIDFunc + "' "
cQuery += "  AND CM6.CM6_PROTPN = '" + cRecibo + "' "
cQuery += "  AND CM6.CM6_STATUS = '4' "
cQuery += "  AND CM6.CM6_EVENTO = 'R' "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

If ( cAliasQry )->( !Eof() )
	lRet := .T.
EndIf

( cAliasQry )->( DBCloseArea() )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} MontaMsg
@type			function
@description	Monta mensagem de divergências encontradas.
@author			Felipe C. Seolin
@since			02/10/2018
@param			cUID		-	Identificador da sessão de variáveis globais
@param			cChave		-	Identificador da chave ( Tabela X ) HashMap
@param			cValorR		-	Variável onde será armazenado o valor da chave ( Tabela A )
@param			a3000		-	Array com registros do evento S-3000
@param			aDelete		-	Array com registros do evento S-2230 apagados
@param			aPendency	-	Array com os eventos Inconsistentes ou Aguardando Retorno de Transmissão
@return			aMessage	-	Array com a mensagem formatada para exibição dos registros do evento S-3000 gerados
/*/
//---------------------------------------------------------------------
Static Function MontaMsg( cUID, cChave, cValorR, a3000, aDelete, aPendency )

Local cStatus		:=	""
Local cEncode		:=	""
Local aMessage		:=	{}
Local aEncode		:=	{}
Local lCabecSts2	:=	.T.
Local lCabecSts3	:=	.T.
Local lCabecSts4	:=	.T.
Local nI			:=	0

Default a3000		:=	{}
Default aDelete		:=	{}
Default aPendency	:=	{}

If !Empty( a3000 ) .or. !Empty( aDelete )
	aAdd( aMessage, '"status": "0"' )
ElseIf Empty( a3000 ) .and. Empty( aDelete ) .and. Empty( aPendency )
	aAdd( aMessage, '"status": "3"' )
Else
	aAdd( aMessage, '"status": "1"' )
EndIf

aAdd( aMessage, '"lastExecution" : "' )

If !Empty( a3000 )
	aAdd( aEncode, "Eventos S-3000 criados automaticamente:" )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )

	For nI := 1 to Len( a3000 )
		aAdd( aEncode, "Filial: '" + AllTrim( a3000[nI,1] ) + "' - " )
		aAdd( aEncode, "ID: '" + AllTrim( a3000[nI,2] ) + "' - " )
		aAdd( aEncode, "Versão: '" + AllTrim( a3000[nI,3] ) + "' - " )
		aAdd( aEncode, "Tipo Evento: '" + AllTrim( a3000[nI,4] ) + "' - " )
		aAdd( aEncode, "CPF: '" + AllTrim( a3000[nI,5] ) + "' - " )
		aAdd( aEncode, "NIS: '" + AllTrim( a3000[nI,6] ) + "' - " )
		aAdd( aEncode, "Recibo: '" + AllTrim( a3000[nI,7] ) + "' " )
		aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	Next nI

	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
EndIf

If !Empty( aDelete )
	aAdd( aEncode, "Eventos S-2230 apagados logicamente devido a não existir transmissão do registro ao governo:" )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )

	For nI := 1 to Len( aDelete )
		aAdd( aEncode, "Filial: '" + AllTrim( aDelete[nI,1] ) + "' - " )
		aAdd( aEncode, "ID: '" + AllTrim( aDelete[nI,2] ) + "' - " )
		aAdd( aEncode, "Versão: '" + AllTrim( aDelete[nI,3] ) + "' - " )
		aAdd( aEncode, "Data do Afastamento: '" + AllTrim( aDelete[nI,4] ) + "' - " )
		aAdd( aEncode, "Data do Fim do Afastamento: '" + AllTrim( aDelete[nI,5] ) + "' - " )
		aAdd( aEncode, "ID Trabalhador: '" + AllTrim( aDelete[nI,6] ) + "' - " )
		aAdd( aEncode, "CPF: '" + AllTrim( aDelete[nI,7] ) + "' - " )
		aAdd( aEncode, "NIS: '" + AllTrim( aDelete[nI,8] ) + "' " )
		aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	Next nI
EndIf

If !Empty( aPendency )
	aSort( aPendency,,, { |x,y| x[9] < y[9] } )

	For nI := 1 to Len( aPendency )
		If nI > 1 .and. cStatus <> aPendency[nI,9]
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
		EndIf

		cStatus := aPendency[nI,9]

		If cStatus == "2"
			If lCabecSts2
				aAdd( aEncode, "Eventos aguardando retorno de transmissão ( Necessário reconsultar por meio do Monitor de Transmissão do eSocial ):" )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )

				lCabecSts2 := .F.
			EndIf

			aAdd( aEncode, "Filial: '" + AllTrim( aPendency[nI,1] ) + "' - " )
			aAdd( aEncode, "ID: '" + AllTrim( aPendency[nI,2] ) + "' - " )
			aAdd( aEncode, "Versão: '" + AllTrim( aPendency[nI,3] ) + "' - " )
			aAdd( aEncode, "Data do Afastamento: '" + AllTrim( aPendency[nI,4] ) + "' - " )
			aAdd( aEncode, "Data do Fim do Afastamento: '" + AllTrim( aPendency[nI,5] ) + "' - " )
			aAdd( aEncode, "ID Trabalhador: '" + AllTrim( aPendency[nI,6] ) + "' - " )
			aAdd( aEncode, "CPF: '" + AllTrim( aPendency[nI,7] ) + "' - " )
			aAdd( aEncode, "NIS: '" + AllTrim( aPendency[nI,8] ) + "' " )
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
		ElseIf cStatus = "3"
			If lCabecSts3
				aAdd( aEncode, "Eventos com inconsistências a serem avaliadas ( Necessário avaliar e sanar a inconsistência ):" )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )

				lCabecSts3 := .F.
			EndIf

			aAdd( aEncode, "Filial: '" + AllTrim( aPendency[nI,1] ) + "' - " )
			aAdd( aEncode, "ID: '" + AllTrim( aPendency[nI,2] ) + "' - " )
			aAdd( aEncode, "Versão: '" + AllTrim( aPendency[nI,3] ) + "' - " )
			aAdd( aEncode, "Data do Afastamento: '" + AllTrim( aPendency[nI,4] ) + "' - " )
			aAdd( aEncode, "Data do Fim do Afastamento: '" + AllTrim( aPendency[nI,5] ) + "' - " )
			aAdd( aEncode, "ID Trabalhador: '" + AllTrim( aPendency[nI,6] ) + "' - " )
			aAdd( aEncode, "CPF: '" + AllTrim( aPendency[nI,7] ) + "' - " )
			aAdd( aEncode, "NIS: '" + AllTrim( aPendency[nI,8] ) + "' " )
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
		ElseIf cStatus = "4"
			If lCabecSts4
				aAdd( aEncode, "Eventos consistentes mas que não possuem o recibo gravado ( Necessário aplicar o Ajuste de Recibo ):" )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )

				lCabecSts4 := .F.
			EndIf

			aAdd( aEncode, "Filial: '" + AllTrim( aPendency[nI,1] ) + "' - " )
			aAdd( aEncode, "ID: '" + AllTrim( aPendency[nI,2] ) + "' - " )
			aAdd( aEncode, "Versão: '" + AllTrim( aPendency[nI,3] ) + "' - " )
			aAdd( aEncode, "Data do Afastamento: '" + AllTrim( aPendency[nI,4] ) + "' - " )
			aAdd( aEncode, "Data do Fim do Afastamento: '" + AllTrim( aPendency[nI,5] ) + "' - " )
			aAdd( aEncode, "ID Trabalhador: '" + AllTrim( aPendency[nI,6] ) + "' - " )
			aAdd( aEncode, "CPF: '" + AllTrim( aPendency[nI,7] ) + "' - " )
			aAdd( aEncode, "NIS: '" + AllTrim( aPendency[nI,8] ) + "' " )
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
		EndIf
	Next nI
EndIf

If Empty( a3000 ) .and. Empty( aDelete ) .and. Empty( aPendency )
	aAdd( aEncode, "Não foram localizados eventos para exclusão" )
EndIf

For nI := 1 to Len( aEncode )
	cEncode += aEncode[nI]
Next nI

aAdd( aMessage, Encode64( EncodeUTF8( cEncode ) ) )
aAdd( aMessage, '"' )
aAdd( aMessage, ',' )
aAdd( aMessage, Chr( 13 ) + Chr( 10 ) )
aAdd( aMessage, '"date" : "' + DToC( Date() ) + '"' )
aAdd( aMessage, ',' )
aAdd( aMessage, Chr( 13 ) + Chr( 10 ) )
aAdd( aMessage, '"time" : "' + Time() + '"' )

VarInfo( "aMessage", aMessage )

TAFFinishWS( cChave, cUID, cValorR, aMessage, 3 )

Return( aMessage )

//---------------------------------------------------------------------
/*/{Protheus.doc} SetMsgResp
@type			function
@description	Formata a mensagem no padrão Json.
@author			Felipe C. Seolin
@since			06/11/2018
@param			cMessage	-	Descrição da execução
@param			cStatus		-	Status da operação:
									0 - Exclusão Finalizada
									1 - Exclusão em Andamento
									9 - Exclusão não executada nenhuma vez antes da chamada do método GET
@return			cResponse	-	Resposta formatada no padrão Json
/*/
//---------------------------------------------------------------------
Static Function SetMsgResp( cMessage, cStatus )

Local cResponse	:=	""
Local cUID		:=	"UIDPROCDEL2230"
Local cValorR	:=	"RESPPROCDEL2230"
Local cComp		:=	""
Local nI		:=	0
Local aRetorno	:=	{}
Local lVirgula	:=	.F.

Default cMessage	:=	""
Default cStatus		:=	""

If cStatus == "0"
	If VarGetAD( cUID, cValorR, @aRetorno )
		If !Empty( aRetorno )
			cComp += ','
			For nI := 1 to Len( aRetorno )
				If nI == 1
					If aRetorno[nI] == '"status": "0"'
						cStatus := "0"
					ElseIf aRetorno[nI] == '"status": "1"'
						cStatus := "1"
					ElseIf aRetorno[nI] == '"status": "3"'
						cStatus := "3"
					EndIf
				Else
					cComp += aRetorno[nI]
				EndIf
			Next nI
			aSize( aRetorno, 0 )
		EndIf
	EndIf
EndIf

cResponse := '{'

If !Empty( cStatus )
	cResponse += '"status" : "' + cStatus + '"'
	lVirgula := .T.
EndIf

If lVirgula
	cResponse += ','
EndIf
cResponse += '"description" : "' + EncodeUTF8( cMessage ) + '"'

If !Empty( cComp )
	cResponse += cComp
EndIf

cResponse += '}'

Return( cResponse )