#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE TOKEN_JWT_TSS 'TokenAuthTSS'

//---------------------------------------------------------------------
/*/{Protheus.doc} WSTSSSetup
@type			method
@description	Serviço para configuração do certificado digital no TSS.
@author			Victor A. Barbosa
@since			18/06/2019
/*/
//---------------------------------------------------------------------
WSRESTFUL WSTSSSetup DESCRIPTION "Serviço para configuração do certificado digital no TSS" FORMAT APPLICATION_JSON

WSDATA registrationType   as INTEGER
WSDATA registrationNumber as STRING
WSDATA ie                 as STRING OPTIONAL
WSDATA uf                 as STRING
WSDATA companyName        as STRING
WSDATA branchName         as STRING OPTIONAL
WSDATA countyCode         as STRING
WSDATA grantNumber        as STRING OPTIONAL
WSDATA url                as STRING
WSDATA idempresa          as STRING OPTIONAL
WSDATA slot               as STRING OPTIONAL
WSDATA label              as STRING OPTIONAL
WSDATA module             as STRING OPTIONAL
WSDATA idHex              as STRING OPTIONAL
WSDATA typeCert           as STRING

WSMETHOD POST V1;
	DESCRIPTION "Método para configuração do certificado digital";
	WSSYNTAX "/v1/";
	PATH "/v1/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET V1;
	DESCRIPTION "Método para obter o código da entidade do TSS";
	WSSYNTAX "/v1/?{registrationType}&{registrationNumber}&{ie}&{uf}&{companyName}&{branchName}&{countyCode}&{grantNumber}&{url}";
	PATH "/v1/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST V1
@type			method
@description	Método para configuração do certificado digital.
@author			Victor A. Barbosa
@since			18/06/2019
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST V1 WSRESTFUL WSTSSSetup

Local oRequest		:=	Nil
Local oResponse		:=	Nil
Local cBody			:=	self:GetContent()
Local cIDEnt		:=	""
Local cMsgReturn	:=	""
Local lRet			:=	.T.

If Empty( cBody )
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Requisição não possui parâmetros no corpo da mensagem." ) )
Else
	oRequest := JsonObject():New()

	cMsgReturn := oRequest:FromJSON( cBody )

	If Empty( cMsgReturn )
		lRet := ConfigTSS( oRequest, @cIDEnt, @cMsgReturn, Self:GetHeader(TOKEN_JWT_TSS) )
	Else
		lRet := .F.
	EndIf

	If !lRet
		SetRestFault( 400, EncodeUTF8( cMsgReturn ) )
	Else
		oResponse := JsonObject():New()
		oResponse["idCompany"]		:=	cIDEnt
		oResponse["returnMessage"]	:=	EncodeUTF8( cMsgReturn )
		self:SetResponse( oResponse:ToJson() )
	EndIf
EndIf

oRequest	:= Nil
oResponse	:= Nil

FreeObj( oRequest )
FreeObj( oResponse )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GET V1
@type			method
@description	Método para obter o código da entidade do TSS.
@author			Victor A. Barbosa
@since			18/06/2019
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET V1 QUERYPARAM registrationType, registrationNumber, ie, uf, companyName, branchName, countyCode, grantNumber, url, idempresa WSRESTFUL WSTSSSetup

Local oResponse		:= Nil
Local cIDEnt		:= ""
Local cMsgReturn	:= ""
Local cBearerToken  := ""
Local lRet			:= .T.

If ValidStruct( "GET", @cMsgReturn, self:registrationType, self:registrationNumber, self:ie, self:uf, self:companyName, self:branchName, self:countyCode,,, self:grantNumber, self:url, self:idempresa )
	If TSSOnAir( self:url )

		cBearerToken := Self:GetHeader(TOKEN_JWT_TSS)

		cIDEnt := GetIDEnt( "GET", self:registrationType, self:registrationNumber, self:ie, self:uf, self:companyName, self:branchName, self:countyCode, self:grantNumber, self:url, self:idempresa, @cMsgReturn, cBearerToken)

		oResponse := JsonObject():New()
		oResponse["idCompany"]		:=	cIDEnt
		oResponse["returnMessage"]	:=	EncodeUTF8( cMsgReturn )
		self:SetResponse( oResponse:ToJson() )
	Else
		lRet := .F.

		cMsgReturn := "Falha ao tentar se conectar ao TSS." + CRLF + CRLF
		cMsgReturn += "Configurações usadas: " + CRLF
		cMsgReturn += "Url Totvs Service SOA: " + AllTrim( self:url ) + CRLF + CRLF
		cMsgReturn += "Verifique as configurações do servidor e se o mesmo está ativo."

		SetRestFault( 400, EncodeUTF8( cMsgReturn ) )
	EndIf
Else
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( cMsgReturn ) )
EndIf

oResponse := Nil

FreeObj( oResponse )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConfigTSS
@type			function
@description	Encapsula o cadastro da Entidade o envio do Certificado Digital ao TSS.
@author			Victor A. Barbosa
@since			18/06/2019
@param			oRequest	 -	Json com as informações da Empresa e Certificado
@param			cIDEnt		 -	Identificador da Entidade do TSS ( Referência )
@param			cMsgReturn	 -	Mensagem de retorno da solicitação ( Referência )
@param 			cBearerToken -   Token Jwt para utilização segura com o TSS
@return			lRet		 -	Indica se a configuração da Entidade e Certificado foram executados com sucesso
/*/
//---------------------------------------------------------------------
Static Function ConfigTSS( oRequest, cIDEnt, cMsgReturn, cBearerToken )

Local cRegNumber		:=	""
Local cIE				:=	""
Local cUF				:=	""
Local cCompanyName		:=	""
Local cBranchName		:=	""
Local cCountyCode		:=	""
Local cCertificate		:=	""
Local cPassWord			:=	""
Local cURL				:=	""
Local cSlot				:= ""
Local cLabel			:= ""
Local cPathDLL			:= ""
Local cIdHex			:= ""
Local cTypeCert 		:= ""
Local nRegType			:=	0
Local lSendCertif		:=	.F.

Default cBearerToken 	:= ""

nRegType		:=	oRequest["registrationType"]
cRegNumber		:=	oRequest["registrationNumber"]
cIE				:=	oRequest["ie"]
cUF				:=	oRequest["uf"]
cCompanyName	:=	oRequest["companyName"]
cBranchName		:=	oRequest["branchName"]
cCountyCode		:=	oRequest["countyCode"]
cCertificate	:=	oRequest["digitalCertificate"]
cPassWord		:=	oRequest["password"]
cGrantNumber	:=	oRequest["grantNumber"]
cURL			:=	oRequest["url"]
cSlot			:=	oRequest["slot"]
cLabel			:=	oRequest["label"]
cPathDLL		:=	oRequest["module"]
cIdHex			:=	oRequest["idHex"]
cTypeCert 		:=	oRequest["typeCert"]

If Empty(cTypeCert)
	cTypeCert := "A1"
EndIf

If ValidStruct( "POST", @cMsgReturn, nRegType, cRegNumber, cIE, cUF, cCompanyName, cBranchName, cCountyCode, cCertificate, cPassWord, cGrantNumber, cUrl, cSlot, cLabel, cPathDLL, cIdHex, cTypeCert )
	If TSSOnAir( cUrl )
		lSendCertif  := SendCertif( nRegType, cRegNumber, cIE, cUF, cCompanyName, cBranchName, cCountyCode, cCertificate, cPassWord, cGrantNumber, cURL, @cIDEnt, @cMsgReturn, cSlot, cLabel, cPathDLL, cIdHex, cTypeCert, cBearerToken )
	Else
		cMsgReturn := "Falha ao tentar se conectar ao TSS." + CRLF + CRLF
		cMsgReturn += "Configurações usadas: " + CRLF
		cMsgReturn += "Url Totvs Service SOA: " + AllTrim( cURL ) + CRLF + CRLF
		cMsgReturn += "Verifique as configurações do servidor e se o mesmo está ativo."
	EndIf
EndIf

Return( lSendCertif )

//---------------------------------------------------------------------
/*/{Protheus.doc} SendCertif
@type			function
@description	Executa o envio do Certificado Digital ao TSS.
@author			Victor A. Barbosa
@since			18/06/2019
@param			nRegType		-	Tipo de Inscrição
@param			cRegNumber		-	Número da Inscrição
@param			cIE				-	Inscrição Estadual
@param			cUF				-	Unidade de Federação
@param			cCompanyName	-	Razão Social / Nome
@param			cBranchName		-	Nome Fantasia
@param			cCountyCode		-	Código do Município
@param			cCertificate	-	Certificado Digital (PFX) em BASE64
@param			cPassWord		-	Senha do Certificado Digital
@param			cGrantNumber	-	Número da Inscrição do Transmissor
@param			cURL			-	URL do Serviço do TSS
@param			cIDEnt			-	Identificador da Entidade do TSS ( Referência )
@param			cMsgReturn		-	Mensagem de retorno da solicitação ( Referência )
@param 			cBearerToken 	-   Token Jwt para utilização segura com o TSS
@return			lRet			-	Indica se a configuração do Certificado foi executada com sucesso
/*/
//---------------------------------------------------------------------
Static Function SendCertif( nRegType, cRegNumber, cIE, cUF, cCompanyName, cBranchName, cCountyCode, cCertificate, cPassWord, cGrantNumber, cURL, cIDEnt, cMsgReturn, cSlot, cLabel, cPathDLL, cIdHex, cTypeCert, cBearerToken )

Local oWS		:=	Nil
Local cMessage	:=	""
Local lRet		:=	.T.

cIDEnt := GetIDEnt( "POST", nRegType, cRegNumber, cIE, cUF, cCompanyName, cBranchName, cCountyCode, cGrantNumber, cURL,, @cMsgReturn, cBearerToken)

If !Empty( cIDEnt ) .And. AllTrim(cTypeCert) == "A1"
	oWs := WSSpedCfgNFe():New(cBearerToken)
	oWs:cUserToken		:=	"TOTVS"
	oWs:cID_Ent			:=	cIDEnt
	oWs:cCertificate	:=	Decode64( cCertificate )
	oWs:cPassword		:=	AllTrim( cPassWord )
	oWS:_URL			:=	AllTrim( cURL ) + "/SPEDCFGNFe.apw"

	If oWs:CfgCertificatePFX()
		cMessage := oWS:cCfgCertificatePFXResult
	Else
		lRet := .F.
		cMessage := Iif( Empty( GetWscError( 3 ) ), GetWscError( 1 ), GetWscError( 3 ) )

		If "WSCERR044" $ cMessage
			cMessage := "Falha ao tentar se conectar ao TSS." + CRLF + CRLF
			cMessage += "Configurações usadas: " + CRLF
			cMessage += "Url Totvs Service SOA: " + AllTrim( cURL ) + CRLF + CRLF
			cMessage += "Verifique as configurações do servidor e se o mesmo está ativo."
		EndIf
	EndIf
ElseIf !Empty( cIDEnt ) .And. AllTrim(cTypeCert) == "A3"
	oWs:= WsSpedCfgNFe():New(cBearerToken)
	oWs:cUSERTOKEN   	:= "TOTVS"
	oWs:cID_ENT      	:= cIdEnt
	oWs:cSlot        	:= cSlot
	oWs:cModule      	:= AllTrim(cPathDLL)
	oWs:cPASSWORD    	:= AllTrim(cPassWord)
	If !Empty( cIdHex )
		oWs:cIDHEX      := AllTrim(cIdHex)
		oWs:cLabel      := ""
	Else
		oWs:cIDHEX      := ""
		oWs:cLabel     	:= cLabel
	EndIf
	oWs:cPASSWORD    	:= AllTrim(cPassWord)
	oWS:_URL         	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
	If oWs:CfgHSM()
		cMessage := oWS:cCfgHSMResult
	Else
		lRetorno := .F.
		cMessage := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))

		If "WSCERR044" $ cMessage
			cMessage := "Falha ao tentar se conectar ao TSS." + CRLF + CRLF
			cMessage += "Configurações usadas: " + CRLF
			cMessage += "Url Totvs Service SOA: " + AllTrim( cURL ) + CRLF + CRLF
			cMessage += "Verifique as configurações do servidor e se o mesmo está ativo."
		EndIf
	EndIf
EndIf

If !Empty( cMsgReturn )
	cMsgReturn += " "
	cMsgReturn += cMessage
Else
	cMsgReturn := cMessage
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIDEnt
@type			function
@description	Executa o envio/consulta da Entidade no TSS.
@author			Victor A. Barbosa
@since			18/06/2019
@param			cType			-	Método de origem da chamada da validação
@param			nRegType		-	Tipo de Inscrição
@param			cRegNumber		-	Número da Inscrição
@param			cIE				-	Inscrição Estadual
@param			cUF				-	Unidade de Federação
@param			cCompanyName	-	Razão Social / Nome
@param			cBranchName		-	Nome Fantasia
@param			cCountyCode		-	Código do Município
@param			cGrantNumber	-	Número da Inscrição do Transmissor
@param			cURL			-	URL do Serviço do TSS
@param			cMsgReturn		-	Mensagem de retorno da solicitação ( Referência )
@param 			cBearerToken 	-   Token Jwt para utilização segura com o TSS
@return			lRet			-	Indica se o envio/consulta da Entidade foi executada com sucesso
/*/
//---------------------------------------------------------------------
Static Function GetIDEnt( cType, nRegType, cRegNumber, cIE, cUF, cCompanyName, cBranchName, cCountyCode, cGrantNumber, cURL, cIdEmpresa, cMsgReturn, cBearerToken )

	Local oWs          := Nil
	Local cIDEnt       := ""
	Local lUsaGesEmp   := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)

	Default cMsgReturn := ""

	oWS := WSSpedAdm():New(cBearerToken)
	oWS:cUserToken				:=	"TOTVS"
	oWS:_URL					:=	IIF(SUBSTR(AllTrim(cURL), -1) <> "/", AllTrim( cURL ) + "/SPEDADM.apw", AllTrim( cURL ) + "SPEDADM.apw")
	oWS:oWSEmpresa:cCNPJ		:=	Iif( nRegType == 1, AllTrim( cRegNumber ), "" )
	oWS:oWSEmpresa:cCPF			:=	Iif( nRegType == 2, AllTrim( cRegNumber ), "" )
	oWS:oWSEmpresa:cIE			:=	cIE
	oWS:oWSEmpresa:cIM			:=	""
	oWS:oWSEmpresa:cNome		:=	cCompanyName
	oWS:oWSEmpresa:cFantasia	:=	cBranchName
	oWS:oWSEmpresa:cEndereco	:=	""
	oWS:oWSEmpresa:cNum			:=	""
	oWS:oWSEmpresa:cCompl		:=	""
	oWS:oWSEmpresa:cUF			:=	cUF
	oWS:oWSEmpresa:cCEP			:=	""
	oWS:oWSEmpresa:cCod_Mun		:=	cCountyCode
	oWS:oWSEmpresa:cCod_Pais	:=	"1058"
	oWS:oWSEmpresa:cBairro		:=	""
	oWS:oWSEmpresa:cMun			:=	""
	oWS:oWSEmpresa:cCEP_CP		:=	Nil
	oWS:oWSEmpresa:cCP			:=	Nil
	oWS:oWSEmpresa:cDDD			:=	""
	oWS:oWSEmpresa:cFone		:=	""
	oWS:oWSEmpresa:cFax			:=	""
	oWS:oWSEmpresa:cEmail		:=	""
	oWS:oWSEmpresa:cNIRE		:=	""
	oWS:oWSEmpresa:dDTRE		:=	SToD( "" )
	oWS:oWSEmpresa:cNIT			:=	""
	oWS:oWSEmpresa:cIndSiteSP	:=	""
	oWS:oWSEmpresa:cID_Matriz	:=	""

	If lUsaGesEmp 
		oWS:oWSEmpresa:cIdEmpresa:= cIdEmpresa//FwGrpCompany()+FwCodFil()
	EndIf

	If ValType( cGrantNumber ) <> "U"
		If cType == "POST"
			oWS:oWSEmpresa:cUPDINSCRTR	:=	"S"
			oWS:oWSEmpresa:cINSCRTRA	:=	AllTrim( cGrantNumber )
		ElseIf cType == "GET"
			oWS:oWSEmpresa:cUPDINSCRTR	:=	"N"
			oWS:oWSEmpresa:cINSCRTRA	:=	AllTrim( cGrantNumber )
		EndIf
	EndIf

	If oWs:AdmEmpresas()
		cIDEnt := AllTrim( oWs:cAdmEmpresasResult )
	Else
		cMsgReturn := Iif( Empty( GetWscError( 3 ) ), GetWscError( 1 ), GetWscError( 3 ) )

		If "WSCERR044" $ cMsgReturn
			cMsgReturn := "Falha ao tentar se conectar ao TSS." + CRLF + CRLF
			cMsgReturn += "Configurações usadas: " + CRLF
			cMsgReturn += "Url Totvs Service SOA: " + AllTrim( cURL ) + CRLF + CRLF
			cMsgReturn += "Verifique as configurações do servidor e se o mesmo está ativo."
		EndIf
	EndIf

	oWS := Nil

	FreeObj( oWS )

Return( cIDEnt )

//---------------------------------------------------------------------
/*/{Protheus.doc} TSSOnAir
@type			function
@description	Verifica se o TSS está ativo.
@author			Victor A. Barbosa
@since			18/06/2019
@param			cURL	-	URL do Serviço do TSS
@return			lRet	-	Indica se o TSS está ativo
/*/
//---------------------------------------------------------------------
Function TSSOnAir( cURL )

Local oWs	:=	WSSpedCfgNFe():New()
Local nI	:=	0
Local lRet	:=	.T.

oWs:cUserToken	:=	"TOTVS"
oWS:_URL		:=	AllTrim( cURL ) + "/SPEDCFGNFe.apw"

For nI := 1 to 3
	If !( oWs:CFGCONNECT() )
		lRet := .F.
	Else
		lRet := .T.
		Exit
	EndIf

	Sleep( 1000 )
Next nI

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidStruct
@type			function
@description	Executa a validação dos parâmetros recebidos.
@author			Victor A. Barbosa
@since			19/06/2019
@param			cType			-	Método de origem da chamada da validação
@param			cMsgReturn		-	Mensagem de retorno da solicitação ( Referência )
@param			nRegType		-	Tipo de Inscrição
@param			cRegNumber		-	Número da Inscrição
@param			cIE				-	Inscrição Estadual
@param			cUF				-	Unidade de Federação
@param			cCompanyName	-	Razão Social / Nome
@param			cBranchName		-	Nome Fantasia
@param			cCountyCode		-	Código do Município
@param			cCertificate	-	Certificado Digital (PFX) em BASE64
@param			cPassWord		-	Senha do Certificado Digital
@param			cGrantNumber	-	Número da Inscrição do Transmissor
@param			cURL			-	URL do Serviço do TSS
@return			lRet			-	Indica se todas as informações são válidas
/*/
//---------------------------------------------------------------------
Static Function ValidStruct( cType, cMsgReturn, nRegType, cRegNumber, cIE, cUF, cCompanyName, cBranchName, cCountyCode, cCertificate, cPassWord, cGrantNumber, cUrl, cSlot, cLabel, cPathDLL, cIdHex, cTypeCert )

Local lRet	:=	.T.

If ValType( nRegType ) == "U" .or. ( ValType( nRegType ) == "N" .and. Empty( cValToChar( nRegType ) ) )
	lRet := .F.
	cMsgReturn := "Tipo de Inscrição não informado no parâmetro 'registrationType'."
ElseIf ValType( nRegType ) <> "N"
	lRet := .F.
	cMsgReturn := "Tipo de Inscrição informado no parâmetro 'registrationType' com formato diferente do esperado."
ElseIf nRegType < 1 .or. nRegType > 2
	lRet := .F.
	cMsgReturn := "O Tipo de Inscrição '" + cValToChar( nRegType ) + "' informado no parâmetro 'registrationType' é inválido."
ElseIf ValType( cRegNumber ) == "U" .or. ( ValType( cRegNumber ) == "C" .and. Empty( cRegNumber ) )
	lRet := .F.
	cMsgReturn := "Número de Inscrição não informado no parâmetro 'registrationNumber'."
ElseIf ValType( cRegNumber ) <> "C"
	lRet := .F.
	cMsgReturn := "Número de Inscrição informado no parâmetro 'registrationNumber' com formato diferente do esperado."
ElseIf nRegType == 1 .and. Len( AllTrim( cRegNumber ) ) <> 14
	lRet := .F.
	cMsgReturn := "O Número de Inscrição '" + AllTrim( cRegNumber ) + "' informado no parâmetro 'registrationNumber' é inválido. Deve possuir 14 caracteres."
ElseIf nRegType == 2 .and. Len( AllTrim( cRegNumber ) ) <> 11
	lRet := .F.
	cMsgReturn := "O Número de Inscrição '" + AllTrim( cRegNumber ) + "' informado no parâmetro 'registrationNumber' é inválido. Deve possuir 11 caracteres."
ElseIf !CGC( cRegNumber )
	lRet := .F.
	cMsgReturn := "O Número de Inscrição '" + AllTrim( cRegNumber ) + "' informado no parâmetro 'registrationNumber' é inválido. Deve ser um CNPJ/CPF válido."
ElseIf ValType( cIE ) <> "U" .and. ValType( cIE ) <> "C"
	lRet := .F.
	cMsgReturn := "Inscrição Estadual informada no parâmetro 'ie' com formato diferente do esperado."
ElseIf ValType( cUF ) == "U" .or. ( ValType( cUF ) == "C" .and. Empty( cUF ) )
	lRet := .F.
	cMsgReturn := "Unidade de Federação não informado no parâmetro 'uf'."
ElseIf ValType( cUF ) <> "U" .and. ValType( cUF ) <> "C"
	lRet := .F.
	cMsgReturn := "Unidade de Federação informada no parâmetro 'uf' com formato diferente do esperado."
ElseIf Len( AllTrim( cUF ) ) <> 2
	lRet := .F.
	cMsgReturn := "A Unidade de Federação '" + AllTrim( cUF ) + "' informada no parâmetro 'uf' é inválida. Deve possuir 2 caracteres."
ElseIf ValType( cCompanyName ) == "U" .or. ( ValType( cCompanyName ) == "C" .and. Empty( cCompanyName ) )
	lRet := .F.
	cMsgReturn := "Razão Social não informada no parâmetro 'companyName'."
ElseIf ValType( cCompanyName ) <> "U" .and. ValType( cCompanyName ) <> "C"
	lRet := .F.
	cMsgReturn := "Razão Social informada no parâmetro 'companyName' com formato diferente do esperado."
ElseIf ValType( cBranchName ) <> "U" .and. ValType( cBranchName ) <> "C"
	lRet := .F.
	cMsgReturn := "Nome Fantasia informada no parâmetro 'branchName' com formato diferente do esperado."
ElseIf ValType( cCountyCode ) == "U" .or. ( ValType( cCountyCode ) == "C" .and. Empty( cCountyCode ) )
	lRet := .F.
	cMsgReturn := "Código do Município não informado no parâmetro 'countyCode'."
ElseIf ValType( cCountyCode ) <> "U" .and. ValType( cCountyCode ) <> "C"
	lRet := .F.
	cMsgReturn := "Código do Município informado no parâmetro 'countyCode' com formato diferente do esperado."
ElseIf cType == "POST" .and. ( ValType( cCertificate ) == "U" .or. ( ValType( cCertificate ) == "C" .and. Empty( cCertificate ) ) ) .and. cTypeCert == "A1"
	lRet := .F.
	cMsgReturn := "Certificado Digital não informado no parâmetro 'digitalCertificate'."
ElseIf cType == "POST" .and. ValType( cCertificate ) <> "U" .and. ValType( cCertificate ) <> "C" .And. cTypeCert == "A1"
	lRet := .F.
	cMsgReturn := "Certificado Digital informado no parâmetro 'digitalCertificate' com formato diferente do esperado."
ElseIf cType == "POST" .and. ( ValType( cPassWord ) == "U" .or. ( ValType( cPassWord ) == "C" .and. Empty( cPassWord ) ) )
	lRet := .F.
	cMsgReturn := "Senha do Certificado Digital não informada no parâmetro 'password'."
ElseIf cType == "POST" .and. ValType( cPassWord ) <> "U" .and. ValType( cPassWord ) <> "C"
	lRet := .F.
	cMsgReturn := "Senha do Certificado Digital informado no parâmetro 'password' com formato diferente do esperado."
ElseIf ValType( cGrantNumber ) <> "U" .and. ValType( cGrantNumber ) <> "C"
	lRet := .F.
	cMsgReturn := "Número de Inscrição de Outorga informado no parâmetro 'grantNumber' com formato diferente do esperado."
ElseIf ValType( cUrl ) == "U" .or. ( ValType( cUrl ) == "C" .and. Empty( cUrl ) )
	lRet := .F.
	cMsgReturn := "URL do Serviço do TSS não informado no parâmetro 'url'."
ElseIf ValType( cUrl ) <> "U" .and. ValType( cUrl ) <> "C"
	lRet := .F.
	cMsgReturn := "URL do Serviço do TSS informado no parâmetro 'url' com formato diferente do esperado."
ElseIf ValType(cTypeCert) == "U" .And. cType == "POST"
	lRet := .F.
	cMsgReturn := "Tipo de Certificado não informado no parâmetro 'typeCert'."
ElseIf (cTypeCert == "A3" .And. ( Empty(cPathDLL) .And. Empty(cIdHex) ) ) .And. cType == "POST"
	lRet := .F.
	cMsgReturn := "Para certificados A3 é obrigatório informar o parâmetro 'module' ou o parâmetro 'idHex'."
EndIf

Return( lRet )
