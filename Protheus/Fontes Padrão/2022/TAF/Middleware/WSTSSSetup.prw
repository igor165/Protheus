#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE TOKEN_JWT_TSS 'TokenAuthTSS'

//---------------------------------------------------------------------
/*/{Protheus.doc} WSTSSSetup
@type			method
@description	Servi�o para configura��o do certificado digital no TSS.
@author			Victor A. Barbosa
@since			18/06/2019
/*/
//---------------------------------------------------------------------
WSRESTFUL WSTSSSetup DESCRIPTION "Servi�o para configura��o do certificado digital no TSS" FORMAT APPLICATION_JSON

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
	DESCRIPTION "M�todo para configura��o do certificado digital";
	WSSYNTAX "/v1/";
	PATH "/v1/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET V1;
	DESCRIPTION "M�todo para obter o c�digo da entidade do TSS";
	WSSYNTAX "/v1/?{registrationType}&{registrationNumber}&{ie}&{uf}&{companyName}&{branchName}&{countyCode}&{grantNumber}&{url}";
	PATH "/v1/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST V1
@type			method
@description	M�todo para configura��o do certificado digital.
@author			Victor A. Barbosa
@since			18/06/2019
@return			lRet	-	Indica se o m�todo aceitou a execu��o do processo
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
	SetRestFault( 400, EncodeUTF8( "Requisi��o n�o possui par�metros no corpo da mensagem." ) )
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
@description	M�todo para obter o c�digo da entidade do TSS.
@author			Victor A. Barbosa
@since			18/06/2019
@return			lRet	-	Indica se o m�todo aceitou a execu��o do processo
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
		cMsgReturn += "Configura��es usadas: " + CRLF
		cMsgReturn += "Url Totvs Service SOA: " + AllTrim( self:url ) + CRLF + CRLF
		cMsgReturn += "Verifique as configura��es do servidor e se o mesmo est� ativo."

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
@param			oRequest	 -	Json com as informa��es da Empresa e Certificado
@param			cIDEnt		 -	Identificador da Entidade do TSS ( Refer�ncia )
@param			cMsgReturn	 -	Mensagem de retorno da solicita��o ( Refer�ncia )
@param 			cBearerToken -   Token Jwt para utiliza��o segura com o TSS
@return			lRet		 -	Indica se a configura��o da Entidade e Certificado foram executados com sucesso
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
		cMsgReturn += "Configura��es usadas: " + CRLF
		cMsgReturn += "Url Totvs Service SOA: " + AllTrim( cURL ) + CRLF + CRLF
		cMsgReturn += "Verifique as configura��es do servidor e se o mesmo est� ativo."
	EndIf
EndIf

Return( lSendCertif )

//---------------------------------------------------------------------
/*/{Protheus.doc} SendCertif
@type			function
@description	Executa o envio do Certificado Digital ao TSS.
@author			Victor A. Barbosa
@since			18/06/2019
@param			nRegType		-	Tipo de Inscri��o
@param			cRegNumber		-	N�mero da Inscri��o
@param			cIE				-	Inscri��o Estadual
@param			cUF				-	Unidade de Federa��o
@param			cCompanyName	-	Raz�o Social / Nome
@param			cBranchName		-	Nome Fantasia
@param			cCountyCode		-	C�digo do Munic�pio
@param			cCertificate	-	Certificado Digital (PFX) em BASE64
@param			cPassWord		-	Senha do Certificado Digital
@param			cGrantNumber	-	N�mero da Inscri��o do Transmissor
@param			cURL			-	URL do Servi�o do TSS
@param			cIDEnt			-	Identificador da Entidade do TSS ( Refer�ncia )
@param			cMsgReturn		-	Mensagem de retorno da solicita��o ( Refer�ncia )
@param 			cBearerToken 	-   Token Jwt para utiliza��o segura com o TSS
@return			lRet			-	Indica se a configura��o do Certificado foi executada com sucesso
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
			cMessage += "Configura��es usadas: " + CRLF
			cMessage += "Url Totvs Service SOA: " + AllTrim( cURL ) + CRLF + CRLF
			cMessage += "Verifique as configura��es do servidor e se o mesmo est� ativo."
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
			cMessage += "Configura��es usadas: " + CRLF
			cMessage += "Url Totvs Service SOA: " + AllTrim( cURL ) + CRLF + CRLF
			cMessage += "Verifique as configura��es do servidor e se o mesmo est� ativo."
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
@param			cType			-	M�todo de origem da chamada da valida��o
@param			nRegType		-	Tipo de Inscri��o
@param			cRegNumber		-	N�mero da Inscri��o
@param			cIE				-	Inscri��o Estadual
@param			cUF				-	Unidade de Federa��o
@param			cCompanyName	-	Raz�o Social / Nome
@param			cBranchName		-	Nome Fantasia
@param			cCountyCode		-	C�digo do Munic�pio
@param			cGrantNumber	-	N�mero da Inscri��o do Transmissor
@param			cURL			-	URL do Servi�o do TSS
@param			cMsgReturn		-	Mensagem de retorno da solicita��o ( Refer�ncia )
@param 			cBearerToken 	-   Token Jwt para utiliza��o segura com o TSS
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
			cMsgReturn += "Configura��es usadas: " + CRLF
			cMsgReturn += "Url Totvs Service SOA: " + AllTrim( cURL ) + CRLF + CRLF
			cMsgReturn += "Verifique as configura��es do servidor e se o mesmo est� ativo."
		EndIf
	EndIf

	oWS := Nil

	FreeObj( oWS )

Return( cIDEnt )

//---------------------------------------------------------------------
/*/{Protheus.doc} TSSOnAir
@type			function
@description	Verifica se o TSS est� ativo.
@author			Victor A. Barbosa
@since			18/06/2019
@param			cURL	-	URL do Servi�o do TSS
@return			lRet	-	Indica se o TSS est� ativo
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
@description	Executa a valida��o dos par�metros recebidos.
@author			Victor A. Barbosa
@since			19/06/2019
@param			cType			-	M�todo de origem da chamada da valida��o
@param			cMsgReturn		-	Mensagem de retorno da solicita��o ( Refer�ncia )
@param			nRegType		-	Tipo de Inscri��o
@param			cRegNumber		-	N�mero da Inscri��o
@param			cIE				-	Inscri��o Estadual
@param			cUF				-	Unidade de Federa��o
@param			cCompanyName	-	Raz�o Social / Nome
@param			cBranchName		-	Nome Fantasia
@param			cCountyCode		-	C�digo do Munic�pio
@param			cCertificate	-	Certificado Digital (PFX) em BASE64
@param			cPassWord		-	Senha do Certificado Digital
@param			cGrantNumber	-	N�mero da Inscri��o do Transmissor
@param			cURL			-	URL do Servi�o do TSS
@return			lRet			-	Indica se todas as informa��es s�o v�lidas
/*/
//---------------------------------------------------------------------
Static Function ValidStruct( cType, cMsgReturn, nRegType, cRegNumber, cIE, cUF, cCompanyName, cBranchName, cCountyCode, cCertificate, cPassWord, cGrantNumber, cUrl, cSlot, cLabel, cPathDLL, cIdHex, cTypeCert )

Local lRet	:=	.T.

If ValType( nRegType ) == "U" .or. ( ValType( nRegType ) == "N" .and. Empty( cValToChar( nRegType ) ) )
	lRet := .F.
	cMsgReturn := "Tipo de Inscri��o n�o informado no par�metro 'registrationType'."
ElseIf ValType( nRegType ) <> "N"
	lRet := .F.
	cMsgReturn := "Tipo de Inscri��o informado no par�metro 'registrationType' com formato diferente do esperado."
ElseIf nRegType < 1 .or. nRegType > 2
	lRet := .F.
	cMsgReturn := "O Tipo de Inscri��o '" + cValToChar( nRegType ) + "' informado no par�metro 'registrationType' � inv�lido."
ElseIf ValType( cRegNumber ) == "U" .or. ( ValType( cRegNumber ) == "C" .and. Empty( cRegNumber ) )
	lRet := .F.
	cMsgReturn := "N�mero de Inscri��o n�o informado no par�metro 'registrationNumber'."
ElseIf ValType( cRegNumber ) <> "C"
	lRet := .F.
	cMsgReturn := "N�mero de Inscri��o informado no par�metro 'registrationNumber' com formato diferente do esperado."
ElseIf nRegType == 1 .and. Len( AllTrim( cRegNumber ) ) <> 14
	lRet := .F.
	cMsgReturn := "O N�mero de Inscri��o '" + AllTrim( cRegNumber ) + "' informado no par�metro 'registrationNumber' � inv�lido. Deve possuir 14 caracteres."
ElseIf nRegType == 2 .and. Len( AllTrim( cRegNumber ) ) <> 11
	lRet := .F.
	cMsgReturn := "O N�mero de Inscri��o '" + AllTrim( cRegNumber ) + "' informado no par�metro 'registrationNumber' � inv�lido. Deve possuir 11 caracteres."
ElseIf !CGC( cRegNumber )
	lRet := .F.
	cMsgReturn := "O N�mero de Inscri��o '" + AllTrim( cRegNumber ) + "' informado no par�metro 'registrationNumber' � inv�lido. Deve ser um CNPJ/CPF v�lido."
ElseIf ValType( cIE ) <> "U" .and. ValType( cIE ) <> "C"
	lRet := .F.
	cMsgReturn := "Inscri��o Estadual informada no par�metro 'ie' com formato diferente do esperado."
ElseIf ValType( cUF ) == "U" .or. ( ValType( cUF ) == "C" .and. Empty( cUF ) )
	lRet := .F.
	cMsgReturn := "Unidade de Federa��o n�o informado no par�metro 'uf'."
ElseIf ValType( cUF ) <> "U" .and. ValType( cUF ) <> "C"
	lRet := .F.
	cMsgReturn := "Unidade de Federa��o informada no par�metro 'uf' com formato diferente do esperado."
ElseIf Len( AllTrim( cUF ) ) <> 2
	lRet := .F.
	cMsgReturn := "A Unidade de Federa��o '" + AllTrim( cUF ) + "' informada no par�metro 'uf' � inv�lida. Deve possuir 2 caracteres."
ElseIf ValType( cCompanyName ) == "U" .or. ( ValType( cCompanyName ) == "C" .and. Empty( cCompanyName ) )
	lRet := .F.
	cMsgReturn := "Raz�o Social n�o informada no par�metro 'companyName'."
ElseIf ValType( cCompanyName ) <> "U" .and. ValType( cCompanyName ) <> "C"
	lRet := .F.
	cMsgReturn := "Raz�o Social informada no par�metro 'companyName' com formato diferente do esperado."
ElseIf ValType( cBranchName ) <> "U" .and. ValType( cBranchName ) <> "C"
	lRet := .F.
	cMsgReturn := "Nome Fantasia informada no par�metro 'branchName' com formato diferente do esperado."
ElseIf ValType( cCountyCode ) == "U" .or. ( ValType( cCountyCode ) == "C" .and. Empty( cCountyCode ) )
	lRet := .F.
	cMsgReturn := "C�digo do Munic�pio n�o informado no par�metro 'countyCode'."
ElseIf ValType( cCountyCode ) <> "U" .and. ValType( cCountyCode ) <> "C"
	lRet := .F.
	cMsgReturn := "C�digo do Munic�pio informado no par�metro 'countyCode' com formato diferente do esperado."
ElseIf cType == "POST" .and. ( ValType( cCertificate ) == "U" .or. ( ValType( cCertificate ) == "C" .and. Empty( cCertificate ) ) ) .and. cTypeCert == "A1"
	lRet := .F.
	cMsgReturn := "Certificado Digital n�o informado no par�metro 'digitalCertificate'."
ElseIf cType == "POST" .and. ValType( cCertificate ) <> "U" .and. ValType( cCertificate ) <> "C" .And. cTypeCert == "A1"
	lRet := .F.
	cMsgReturn := "Certificado Digital informado no par�metro 'digitalCertificate' com formato diferente do esperado."
ElseIf cType == "POST" .and. ( ValType( cPassWord ) == "U" .or. ( ValType( cPassWord ) == "C" .and. Empty( cPassWord ) ) )
	lRet := .F.
	cMsgReturn := "Senha do Certificado Digital n�o informada no par�metro 'password'."
ElseIf cType == "POST" .and. ValType( cPassWord ) <> "U" .and. ValType( cPassWord ) <> "C"
	lRet := .F.
	cMsgReturn := "Senha do Certificado Digital informado no par�metro 'password' com formato diferente do esperado."
ElseIf ValType( cGrantNumber ) <> "U" .and. ValType( cGrantNumber ) <> "C"
	lRet := .F.
	cMsgReturn := "N�mero de Inscri��o de Outorga informado no par�metro 'grantNumber' com formato diferente do esperado."
ElseIf ValType( cUrl ) == "U" .or. ( ValType( cUrl ) == "C" .and. Empty( cUrl ) )
	lRet := .F.
	cMsgReturn := "URL do Servi�o do TSS n�o informado no par�metro 'url'."
ElseIf ValType( cUrl ) <> "U" .and. ValType( cUrl ) <> "C"
	lRet := .F.
	cMsgReturn := "URL do Servi�o do TSS informado no par�metro 'url' com formato diferente do esperado."
ElseIf ValType(cTypeCert) == "U" .And. cType == "POST"
	lRet := .F.
	cMsgReturn := "Tipo de Certificado n�o informado no par�metro 'typeCert'."
ElseIf (cTypeCert == "A3" .And. ( Empty(cPathDLL) .And. Empty(cIdHex) ) ) .And. cType == "POST"
	lRet := .F.
	cMsgReturn := "Para certificados A3 � obrigat�rio informar o par�metro 'module' ou o par�metro 'idHex'."
EndIf

Return( lRet )
