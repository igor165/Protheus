#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE TOKEN_JWT_TSS 'TokenAuthTSS'
Static __lLogLS := .F. 
Static __lSecurity := Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} WSESOCIAL
@type			method
@description	Serviço para transmissão e consulta de dados no eSocial para o Middleware.
@author			Felipe C. Seolin
@since			18/06/2019
/*/
//---------------------------------------------------------------------
WSRESTFUL WSESOCIAL	DESCRIPTION "Serviço para transmissão e consulta de dados no eSocial para o Middleware"	

WSDATA ticketCode	AS STRING
WSDATA sourceBranch	AS STRING
WSDATA tpAmb		AS STRING
WSDATA urlTSS		AS STRING
WSDATA lote			AS STRING

WSMETHOD POST send	DESCRIPTION "Método para transmitir eventos ao eSocial"	WSSYNTAX "/v1/send?{ticketCode}&{sourceBranch}&{tpAmb}&{urlTSS}&{lote}" PATH "/v1/send" TTALK "v1" PRODUCES APPLICATION_JSON

WSMETHOD POST get	DESCRIPTION "Método para consultar eventos do eSocial"	WSSYNTAX "/v1/get?{sourceBranch}&{tpAmb}&{urlTSS}&{lote}" 				PATH "/v1/get" 	TTALK "v1" PRODUCES APPLICATION_JSON
//Verificar se precisa de controle de segurança, e inclusive se será permitido uso por qualquer software. Pssível utilizar cSecurity para controle.

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} send
@type			method
@description	Método para transmitir eventos ao eSocial.
@author			Robson Santos
@since			18/06/2019
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST send QUERYPARAM ticketCode, sourceBranch, tpAmb, urlTSS WSSERVICE WSESOCIAL

Local cBody		:= ::GetContent()
Local lRet		:= .T.
Local oJSSend	:= JsonObject():New()
Local oResponse	:= JsonObject():New()
Local cBearerToken := ""

If Empty( cBody ) 
	SetRestFault( 400, EncodeUTF8( "Método post: Requisição não possui parâmetros no corpo da mensagem." ) )
Else
	//-- Cria o objeto com o body enviado
	If (oJSSend:fromJSON( cBody ) == Nil)
		
		//-- Valida se o tss está no ar
		If TSSOnAir(oJSSend["urlTSS"])

			//-- Valida a quatidade do lote
			If (ValType(oJSSend["lote"]) == 'A') .AND. (Len(oJSSend["lote"]) <= 50)

				cBearerToken := Self:GetHeader(TOKEN_JWT_TSS)
				
				If Send(@oJSSend, @oResponse,cBearerToken)
					
					lRet := .T.
					::SetResponse( oResponse:ToJson() )

				Else
					lRet := .F.
					If Empty( GetWScError( 3 ) )
						SetRestFault( 400, EncodeUTF8( "Não foi possível obter a resposta do TSS. Detalhe:" + GetWScError( 1 ) ) )
					Else
						SetRestFault( 400, EncodeUTF8( "Não foi possível obter a resposta do TSS. Detalhe:" + GetWScError( 3 ) ) )
					EndIf	
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Método post: A quantidade de registros do lote não pode ser maior que 50." ) )	
			EndIf
		Else

			lRet := .F.
			If Empty( GetWScError( 3 ) )
				SetRestFault( 400, EncodeUTF8( "Não foi possível obter a resposta do TSS. Detalhe:" + GetWScError( 1 ) ) )
			Else
				SetRestFault( 400, EncodeUTF8( "Não foi possível obter a resposta do TSS. Detalhe:" + GetWScError( 3 ) ) )
			EndIf
		
		EndIf
	Else
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Método post: Parametros inválidos, verifique as informações enviadas" ) )
	EndIf

EndIf

oJSSend 	:= Nil
oResponse	:= Nil
FreeObj( oResponse )
FreeObj( oJSSend )
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} Send
@type			function
@description	Faz a conexão com o TSS e envia (SOAP) os dados recebidos (REST) na api.
@author			Robson Santos
@since			18/06/2019
@param			oJSSend		 -	Objeto json com os dados recebidos pela API
@param			oResponse	 -	Objeto responsável pela resposta da requisição
@param 			cBearerToken -  Token Jwt para utilização segura com o TSS
@return			lRet		 -	Indica se a transmissão foi executada com sucesso
/*/
//---------------------------------------------------------------------
Static Function Send(oJSSend, oResponse, cBearerToken)

Local oSocial		:=	Nil
Local cURL			:=	""
Local cUserTk		:=	"TOTVS"
Local cIDEnt		:=	""

Local nI			:=	0
Local nQtdLote		:=	0
Local nLote			:=	1
Local lBuildWS		:=	.T.
Local lRetTransm	:=	.F.
Local lRet			:=	.F.

Local oRetTSS		:= Nil

regMiddLS()

cURL		:=	oJSSend["urlTSS"]
cUserTk		:=	"TOTVS"
cIDEnt		:=	oJSSend["sourceBranch"]
cAmbES		:=	oJSSend["tpAmb"]

If !( "TSSWSSOCIAL.APW" $ Upper( cURL ) )
	cURL += "/TSSWSSOCIAL.apw"
EndIf

For nI := 1 to Len( oJSSend["lote"] )
	
	If lBuildWS

		oSocial := WSTSSWSSOCIAL():New(cBearerToken)
		oSocial:_Url := cURL
		oSocial:oWSENTENVDADOS:cUSERTOKEN := cUserTk
		oSocial:oWSENTENVDADOS:cID_ENT := cIDEnt
		oSocial:oWSENTENVDADOS:cAMBIENTE := cAmbES
		oSocial:oWSENTENVDADOS:oWSENTENVDOCS := WsClassNew( "TSSWSSOCIAL_ARRAYOFENTENVDOC" )
		oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC := {}

		lBuildWS := .F.

	EndIf

	aAdd( oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC, WsClassNew( "TSSWSSOCIAL_ENTENVDOC" ) )
	aTail( oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC ):CCODIGO 	:= oJSSend["lote"][nI]["registryType"]
	aTail( oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC ):CID 		:= oJSSend["ticketCode"] + oJSSend["lote"][nI]["registryKey"]
	aTail( oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC ):CXML 	:= Decode64(oJSSend["lote"][nI]["integrationMessage"])
	aTail( oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC ):CVERSAO 	:= oJSSend["lote"][nI]["schemaVersion"]

	nQtdLote ++

	If nQtdLote == 50 .or. nI == Len( oJSSend["lote"] )

		lRetTransm := oSocial:EnviarDocumentos()

		If ValType( lRetTransm ) == "L"
			If lRetTransm
				If ValType( oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS ) <> "U"
					
					oRetTSS := oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC

					If ValType( oRetTSS ) <> "U"
						//-- Chama a função que monta o retorno da api baseado no retorno do TSS
						SetResponse(@oRetTSS, @oResponse, @oJSSend)

						lRet := .T.
					Else
						lRet := .F.	
					EndIf
				Else
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf

		nQtdLote := 0
		lBuildWS := .T.
		nLote++

	EndIf

Next nI

oRetTSS := Nil 
oSocial := Nil
FreeObj(oRetTSS)
FreeObj(oSocial)
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} Send
@type			function
@description	Cria a resposta da API, baseado no retorno do TSS.
@author			Robson Santos
@since			19/06/2019
@param			oJSSend		-	Objeto json com os dados recebidos pela API
@param			oResponse	-	Objeto responsável pela resposta da requisição
@param			oRetTSS		-	Objeto com o retorno do TSS
/*/
//---------------------------------------------------------------------
Static Function SetResponse( oRetTSS, oResponse, oJSSend )

Local oRegKey	:=	JsonObject():New()
Local oError	:=	Nil
Local nI		:=	0
Local nJ		:=	0
Local nRegsInc	:=	0
Local aRegKey	:=	{}
Local aErrRet	:=	{}

aError := {}

oResponse["ticketCode"] := oJSSend["ticketCode"]

For nI := 1 to Len( oJSSend["lote"] )
	oRegKey := JsonObject():New()

	oRegKey["key"] := Alltrim(oRetTSS[nI]:cID)

	If oRetTSS[nI]:lSucesso
		oRegKey["success"] := .T.
	Else
		oRegKey["success"] := .F.

		If Len( aError ) > 0
			For nJ := 1 to Len( aError )
				oError := JsonObject():New()
				oError["coderr"]		:=	aError[nJ][1]
				oError["description"]	:=	EncodeUTF8( StrTran( aError[nJ][2], '"', "'" ) )

				aAdd( aErrRet, oError )
			Next nJ
		Else
			oError := JsonObject():New()
			oError["coderr"]		:=	"99"
			oError["description"]	:=	EncodeUTF8( StrTran( oRetTSS[nI]:cDescricao, '"', "'" ) )

			aAdd( aErrRet, oError )
		EndIf

		oRegKey["error"] := aErrRet

		aErrRet	:=	{}
		aError	:=	{}
	EndIf

	aAdd( aRegKey, oRegKey )

	oRegKey := Nil
Next nI

oResponse["registryKey"] := aRegKey

nRegsInc := nI - 1
oResponse["keyAmount"] := AllTrim( Str( nRegsInc ) )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} get
@type			method
@description	Método para consultar eventos do eSocial.
@author			Felipe C. Seolin
@since			18/06/2019
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST get QUERYPARAM sourceBranch,tpAmb,urlTSS WSRESTFUL WSESOCIAL

Local oRequest	   := Nil
Local cBody		   := self:GetContent()
Local cEntidade	   := ""
Local cAmbiente	   := ""
Local cURL		   := ""
Local cBearerToken := ""
Local aXmls		:=	{}
Local lRet		:=	.T.

If Empty( cBody )
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Método get: Requisição não possui parâmetros no corpo da mensagem." ) )
Else
	oRequest := JsonObject():New()
	oRequest:fromJSON( cBody )

	cEntidade	:=	oRequest["sourceBranch"]
	cAmbiente	:=	oRequest["tpAmb"]
	cURL		:=	oRequest["urlTSS"]
	aXmls		:=	oRequest["lote"]

	If Empty( cEntidade )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Entidade do TSS não informada no parâmetro 'sourceBranch'." ) )
	ElseIf Empty( cAmbiente )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Ambiente de transmissão do eSocial não informado no parâmetro 'tpAmb'." ) )
	ElseIf Empty( cURL )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "URL do serviço do TSS não informado no parâmetro 'urlTSS'." ) )
	ElseIf Empty( aXmls )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Lote de consulta não informado no parâmetro 'lote'." ) )
	Else
		cBearerToken := Self:GetHeader(TOKEN_JWT_TSS)
		lRet := FConsult( self, cEntidade, cAmbiente, cURL, @aXmls, cBearerToken )
	EndIf
EndIf

TAFEncArr( @aXmls )

oRequest := Nil
FreeObj( oRequest )
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FConsult
@type			function
@description	Realiza a consulta dos registros de afastamentos pendentes que não possuem predecessor pendente.
@author			Felipe C. Seolin
@since			14/11/2018
@param			oJson		 -	Json com as informações dos Trabalhadores
@param 			cBearerToken -  Token Jwt para utilização segura com o TSS
@return			lRet		 -	Indica se a consulta foi executada com sucesso
/*/
//---------------------------------------------------------------------
Static Function FConsult( oRest, cEntidade, cAmbiente, cURL, aXmls, cBearerToken )

Local oSocial		:=	Nil
Local oResponse		:=	Nil
Local cEvent		:=	""
Local cTicket		:=	""
Local cKey			:=	""
Local cStatusCode	:=	""
Local cStatusDesc	:=	""
Local cReceipt		:=	""
Local cXmlRet		:=	""
Local cErrorCode	:=	""
Local cErrorDesc	:=	""
Local cDesErroRet	:= 	""
Local cCodErroRet	:= 	""
Local nI			:=	0
Local nPos			:=	0
Local aTSSRet		:=	{}
Local aResponse		:=	{}
Local lSuccess		:=	.F.
Local lProcessed	:=	.F.
Local lXmlRet		:=	.F.
Local lConsRet		:=	.F. 
Local lRet			:=	.F.
Local cError		:= 	""
Local cWarning		:= 	"" 
Local oStreamErr	:= Nil
Local aStreamErr	:= {}
Local nZ			:= 0

oSocial := WSTSSWSSOCIAL():New(cBearerToken)
oSocial:_URL := cURL + "/TSSWSSOCIAL.apw"
oSocial:oWSENTCONSDADOS:cAMBIENTE := cAmbiente
oSocial:oWSENTCONSDADOS:cID_ENT := cEntidade
oSocial:oWSENTCONSDADOS:cUSERTOKEN := "TOTVS"
oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS := WsClassNew( "TSSWSSOCIAL_ARRAYOFENTCONSDOC" )
oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC := {}

For nI := 1 to Len( aXmls )
	cEvent	:=	aXmls[nI]["registryType"]
	cTicket	:=	aXmls[nI]["ticketCode"]
	cKey	:=	aXmls[nI]["registryKey"]
	lXmlRet	:=	aXmls[nI]["returnRetResponse"]

	aAdd( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC, WsClassNew( "TSSWSSOCIAL_ENTCONSDOC" ) )
	aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):CCODIGO := cEvent
	aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):CID := cTicket + cKey
	aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):LRETORNAXML := lXmlRet
	aTail( oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC ):LHISTPROC := .F.
Next nI

lConsRet := oSocial:consultarDocumentos()

If ValType( lConsRet ) == "L" .and. lConsRet .and. ValType( oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS ) <> "U"
	lRet := .T.

	aTSSRet := oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS:oWSSAIDACONSDOC

	For nI := 1 to Len( aXmls )
		cEvent	:=	aXmls[nI]["registryType"]
		cTicket	:=	aXmls[nI]["ticketCode"]
		cKey	:=	aXmls[nI]["registryKey"]

		If ( nPos := aScan( aTSSRet, { |x| AllTrim( x:CID ) == AllTrim(cTicket + cKey) } ) ) > 0
			lSuccess	:=	.T.
			cStatusCode	:=	TAFStsXTSS( aTSSRet[nPos]:CSTATUS )

			If cStatusCode $ "234"
				lProcessed := .T.
			Else
				lProcessed := .F.
			EndIf

			//-- Parseia os erros retornados pelo RET
			If ValType(aTSSRet[nPos]:CXMLERRORET) <> "U" .AND. !Empty(aTSSRet[nPos]:CXMLERRORET)

				oErroRet  := XmlParser( EncodeUTF8(aTSSRet[nPos]:CXMLERRORET), "_", @cError, @cWarning )
				If Empty(cError) .And. ValType(oErroRet) == "O" 
					If Valtype(XmlChildEx(oErroRet,"_OCORRENCIAS")) == "O" 
					
						If Valtype(XmlChildEx(oErroRet:_OCORRENCIAS,"_OCORRENCIA")) == "O" .And. Valtype(XmlChildEx(oErroRet:_OCORRENCIAS:_OCORRENCIA,"_CODIGO")) == "O"
							cCodErroRet := oErroRet:_OCORRENCIAS:_OCORRENCIA:_CODIGO:Text
							cDesErroRet := AllTrim( oErroRet:_OCORRENCIAS:_OCORRENCIA:_DESCRICAO:Text )

							If ValType(XmlChildEx(oErroRet:_OCORRENCIAS:_OCORRENCIA, "_LOCALIZACAO" )) <> "U" .and. !Empty( oErroRet:_OCORRENCIAS:_OCORRENCIA:_LOCALIZACAO:Text )
								cDesErroRet += Chr( 13 ) + Chr( 10 )
								cDesErroRet += "Localização: "
								cDesErroRet += AllTrim( oErroRet:_OCORRENCIAS:_OCORRENCIA:_LOCALIZACAO:Text )
							EndIf

							oStreamErr := JsonObject():New()
							oStreamErr["streamingErrorCode"] := cCodErroRet
							oStreamErr["streamingErrorDetail"] := EncodeUTF8(cDesErroRet)

							AAdd(aStreamErr, oStreamErr)

						ElseIf  Valtype(XmlChildEx(oErroRet:_OCORRENCIAS,"_OCORRENCIA")) == "A"

							For nZ := 1 To Len(oErroRet:_OCORRENCIAS:_OCORRENCIA)
								cCodErroRet := oErroRet:_OCORRENCIAS:_OCORRENCIA[nZ]:_CODIGO:Text
								cDesErroRet := AllTrim( oErroRet:_OCORRENCIAS:_OCORRENCIA[nZ]:_DESCRICAO:Text )

								If ValType( XmlChildEx( oErroRet:_OCORRENCIAS:_OCORRENCIA[nZ],"_LOCALIZACAO") ) <> "U" .and. !Empty( oErroRet:_OCORRENCIAS:_OCORRENCIA[nZ]:_LOCALIZACAO:Text )
									cDesErroRet += Chr( 13 ) + Chr( 10 )
									cDesErroRet += "Localização: "
									cDesErroRet += AllTrim( oErroRet:_OCORRENCIAS:_OCORRENCIA[nZ]:_LOCALIZACAO:Text )
								EndIf

								oStreamErr := JsonObject():New()
								oStreamErr["streamingErrorCode"] := cCodErroRet
								oStreamErr["streamingErrorDetail"] := EncodeUTF8(cDesErroRet)
								
								AAdd(aStreamErr, oStreamErr)

							Next nZ

						EndIf
					Else
					
						If Valtype(XmlChildEx(oErroRet,"_RETORNOPROCESSAMENTOLOTEEVENTOS")) == "O"
							
							cCodErroRet := oErroRet:_RETORNOPROCESSAMENTOLOTEEVENTOS:_STATUS:_CDRESPOSTA:Text
							cDesErroRet := oErroRet:_RETORNOPROCESSAMENTOLOTEEVENTOS:_STATUS:_DESCRESPOSTA:Text

						EndIf

						oStreamErr := JsonObject():New()
						oStreamErr["streamingErrorCode"] := cCodErroRet
						oStreamErr["streamingErrorDetail"] := EncodeUTF8(cDesErroRet)

						AAdd(aStreamErr, oStreamErr)
					EndIf
				EndIf
			EndIf

			cStatusDesc	:=	aTSSRet[nPos]:CDETSTATUS

			cReceipt	:=	aTSSRet[nPos]:CRECIBO
			cXmlRet		:=	Encode64( aTSSRet[nPos]:CXMLEVENTO )
		Else
			lSuccess	:=	.F.
			lProcessed	:=	.F.
			cStatusCode	:=	""
			cStatusDesc	:=	""
			cErrorCode	:=	""
			cErrorDesc	:=	""
			cReceipt	:=	""
			cXmlRet		:=	""
		EndIf

		aAdd( aResponse, JsonObject():New() )
		aResponse[nI]["success"]			:=	lSuccess
		aResponse[nI]["processed"]			:=	lProcessed
		aResponse[nI]["registryType"]		:=	cEvent
		aResponse[nI]["registryKey"]		:=	cKey
		aResponse[nI]["ticketCode"]			:=	cTicket
		aResponse[nI]["statusCode"]			:=	cStatusCode
		aResponse[nI]["statusDescription"]	:=	cStatusDesc
		aResponse[nI]["streamingErrors"]	:=	aStreamErr
		aResponse[nI]["receiptNumber"]		:=	cReceipt
		aResponse[nI]["xmlRetResponse"]		:=	cXmlRet

		aStreamErr := {}
		
	Next nI

	oResponse := JsonObject():New()
	oResponse["items"] := aResponse

	oRest:SetResponse( oResponse:ToJson() )
Else
	lRet := .F.

	If Empty( GetWScError( 3 ) )
		SetRestFault( 502, EncodeUTF8( "Não foi possível obter a resposta do TSS. Detalhe:" + GetWScError( 1 ) ) )
	Else
		SetRestFault( 502, EncodeUTF8( "Não foi possível obter a resposta do TSS. Detalhe:" + GetWScError( 3 ) ) )
	EndIf
EndIf

TAFEncArr( @aTSSRet )
TAFEncArr( @aResponse )

oSocial 	:= Nil 
oResponse	:= Nil
oStreamErr  := Nil

FreeObj( oStreamErr )
FreeObj( oSocial )
FreeObj( oResponse )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} regMiddLS
@type			function
@description	Registra o Uso da Rotina no License Server
@author			Evandro dos Santos Oliveira
@since			17/09/2021
@param			Nil 
@return			Nil 
/*/
//---------------------------------------------------------------------
Static Function regMiddLS()

	Local cCode		:= ""
	Local cUser		:= ""
	Local cModule	:= ""
	Local cRoutine  := "" 

	If !__lLogLS 
		cCode 		:= "LS006"
		cModule		:= "84"
		cRoutine  	:= ProcName(-1)

		If __lSecurity == Nil 
			__lSecurity := ( GetPvProfString("HTTPREST","Security","0",getAdv97()) == "1" )
		EndIf		

		If __lSecurity
			cUser := RetCodUsr()
		Else 
			cUser := '000000'
		EndIf 		

		//Função para gravar o uso de rotinas e enviar ao LS (License Server)
		Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)
		__lLogLS := .T.
	EndIf

Return Nil 


