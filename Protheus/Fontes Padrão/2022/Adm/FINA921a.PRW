#include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FINA921.CH"

/*/{Protheus.doc} FINReceiveHubTPD
Classe responsavel pela comunicação com o TOTVS Pagamentos Digitais

@type       Class
@author     TOTVS SA
@since      16/07/2021
@version    12.1.33

@Return
/*/
Class FINReceiveHubTPD

DATA oConfig            AS Object
Data cTenant            As Character
Data cUserName          As Character
Data cPassword          As Character
Data cCliId             As Character
Data cCliSecret         As Character
Data cMethod            As Character
Data cEnvHmlg           As Character
Data cURL               As Character
Data cURLRAC            As Character
Data cToken             As Character
Data cCodeComp          As Character

Method New()            CONSTRUCTOR
Method GetConfig()
Method GetEnvHmlg()
Method GetURL()
Method GetURLRac()
Method GetCliSecret()
Method SaveParam()
Method SetConfig()

//Geração/Manutenção do Token.
Method GetToken()           //Busca o Token

//Validação da conexão com o TOTVS PAGAMENTOS DIGITAIS
Method ValidConn()

EndClass

/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@author     TOTVS SA
@since      22/01/2021
@version    12.1.27
@Return     FINReceiveHubTPD, Objeto, Objeto construido.
/*/
Method New() Class FINReceiveHubTPD

Self:oConfig      := FWTFConfig()

Self:cTenant      := Self:GetConfig("fin_tenant_PagamentosDigitais")
Self:cUserName    := Self:GetConfig("fin_user_PagamentosDigitais")
Self:cPassword    := Self:GetConfig("fin_password_PagamentosDigitais")
Self:cCodeComp    := StrTran(AllTrim(Self:GetConfig("fin_extBusId_PagamentosDigitais" + cEmpAnt + Alltrim(cFilAnt)))," ","%20")
Self:cCliId       := "totvs_pagamento_digital_protheus_ro"
Self:cMethod      := "shipaypagador"
Self:cEnvHmlg     := Self:GetEnvHmlg()
Self:cURL         := Self:GetURL()
Self:cURLRac      := Self:GetURLRAC()
Self:cCliSecret   := Self:GetCliSecret()
Self:cToken       := ""

Return

/*/{Protheus.doc} ValidConn
Valida conexão

@type       Method
@author     TOTVS SA
@since      16/07/2021
@version    12.1.27
@Return     Logico, .T. se conseguiu gerar token, senão .F.
/*/
Method ValidConn() Class FINReceiveHubTPD
Return !Empty(Self:GetToken())

/*/{Protheus.doc} GetConfig
Lê e retorna valores de chaves da seção atual do arquivo.ini

@type       Method
@author     Norberto M de Melo
@since      19/11/2021
@version    1.0
@Return     NIL
/*/ 
METHOD GetConfig(cKey) Class FINReceiveHubTPD
LOCAL cResult AS CHARACTER

DEFAULT cKey := ""

IF !EMPTY(cKey)

    cResult := ""

    IF VALTYPE(Self:oConfig[cKey]) == "C"
        cResult := Self:oConfig[cKey]
    ENDIF
    
ENDIF

RETURN cResult

/*/{Protheus.doc} GetEnvHmlg
Método de acesso ao appserver.ini para verificar se irá executar em base de homologação

@type       Method
@author     Sidney Silva
@since      19/11/2021
@version    1.0
@Return     Self:cEnvHmlg, Character, variável que verifica o ambiente
/*/ 
METHOD GetEnvHmlg() Class FINReceiveHubTPD

    Self:cEnvHmlg := GetSrvProfString("TpdTpiHomologacao", "")

RETURN Self:cEnvHmlg

/*/{Protheus.doc} GetSetURL
Método de acesso à propriedade de classe cURL

@type       Method
@author     Norberto M de Melo
@since      19/11/2021
@version    1.0
@Return     NIL
/*/ 
METHOD GetURL() Class FINReceiveHubTPD

    If Self:cEnvHmlg == "1"
        Self:cURL := "https://staging.raas.varejo.totvs.com.br/pay-hub/reporting/api/v1/settlement"
    Else
        Self:cURL := "https://raas.varejo.totvs.com.br/pay-hub/reporting/api/v1/settlement"
    EndIf

RETURN Self:cURL

/*/{Protheus.doc} GetSetURLRac
Método de acesso à propriedade de classe cURLRac

@type       Method
@author     Norberto M de Melo
@since      19/11/2021
@version    1.0
@Return     NIL
/*/ 
METHOD GetURLRac() Class FINReceiveHubTPD

    If Self:cEnvHmlg == "1"
        Self:cURLRAC := "https://" + ALLTRIM(Self:cTenant) + ".rac.staging.totvs.app"
    Else
        Self:cURLRAC := "https://" + ALLTRIM(Self:cTenant) + ".rac.totvs.app"
    EndIf

RETURN Self:cURLRAC

/*/{Protheus.doc} GetSetURLRac
Método de acesso à propriedade de classe cURLRac

@type       Method
@author     Norberto M de Melo
@since      19/11/2021
@version    1.0
@Return     NIL
/*/ 
METHOD GetCliSecret() Class FINReceiveHubTPD

    If Self:cEnvHmlg == "1"
        Self:cCliSecret := "39f56c0d-1a0d-48e9-94de-eb32f4e8877c"
    Else
        Self:cCliSecret := "2fbdf0a3-8777-4045-8503-031bcae6af1e"
    EndIf   

RETURN Self:cCliSecret

/*/{Protheus.doc} SaveParam
Atualiza Tabela Interna SYS_APP_PARAM

@type       Method
@author     Norberto M de Melo
@since      19/11/2021
@version    1.0
@Return     NIL
/*/
METHOD SaveParam() Class FINReceiveHubTPD

Self:SetConfig({;       
    { "fin_user_PagamentosDigitais",        Self:cUserName},;
    { "fin_password_PagamentosDigitais",    Self:cPassword},;
    { "fin_tenant_PagamentosDigitais",      Self:cTenant},;
    { "fin_extBusId_PagamentosDigitais" + cEmpAnt + Alltrim(cFilAnt), Self:cCodeComp};
})

// Recarrega
Self:oConfig := FWTFConfig()

Self:cCodeComp   := Self:GetConfig("fin_extBusId_PagamentosDigitais" + cEmpAnt + Alltrim(cFilAnt))
Self:cTenant     := Self:GetConfig("fin_tenant_PagamentosDigitais")
Self:cUserName   := Self:GetConfig("fin_user_PagamentosDigitais")
Self:cPassword   := Self:GetConfig("fin_password_PagamentosDigitais")
Self:cCliSecret  := Self:GetCliSecret()
Self:cURLRAC     := Self:GetUrlRAC()

RETURN NIL

/*/{Protheus.doc} SetConfig
Atualiza dados no arquivo INI

@type       Method
@author     Norberto M de Melo
@since      19/11/2021
@version    1.0
@Return     NIL
/*/
METHOD SetConfig(aProperty) Class FINReceiveHubTPD
LOCAL nI AS NUMERIC
LOCAL oConfig AS OBJECT
LOCAL lResult AS LOGICAL

DEFAULT aProperty := {}

lResult := .F.

IF !EMPTY(aProperty)
    oConfig := JsonObject():New()

    FOR nI := 1 TO LEN(aProperty)
        oConfig[aProperty[nI][1]] := aProperty[nI][2]
    NEXT nI

    lResult := FwTFSetConfig(oConfig)

    FreeObj(oConfig)
ENDIF

RETURN lResult

/*/{Protheus.doc} GetToken
Metodo responsavel por pegar o token de acesso ao RAC

@type       Method
@author     TOTVS SA
@since      16/07/2021
@version    12.1.27
@Return     Objeto, Resultado do metodo.
/*/
Method GetToken() Class FINReceiveHubTPD

Local cParams      As Character
Local aHeadStr     As Array
Local cResult      As Character
Local oRestClient  As Object
Local oJson        As Object

cParams         := ""
aHeadStr        := {}
cResult         := ""
oRestClient     := FWRest():New(Self:cURLRAC)
oJson           := JsonObject():new()

    AAdd( aHeadStr, "Content-Type: application/x-www-form-urlencoded" )
    AAdd( aHeadStr, "charset: UTF-8" )
    AAdd( aHeadStr, "User-Agent: Protheus " + GetBuild() )

    cParams := "grant_type=password"
    cParams += "&username=" + Self:cUserName
    cParams += "&password=" + Self:cPassword
    cParams += "&scope=authorization_api"
    cParams += "&client_id=" + Self:cCliId
    cParams += "&client_secret="+ Self:cCliSecret

    oRestClient:setPath("/totvs.rac/connect/token")
    oRestClient:SetPostParams(cParams)

    If oRestClient:Post(aHeadStr)
        cResult := oJson:FromJson(oRestClient:GetResult())
        IIf(ValType(cResult) == "U", Self:cToken := oJson["access_token"], Self:cToken := "")   
    EndIf

FreeObj(oRestClient)
FreeObj(oJson)
FwFreeArray(aHeadStr)

Return Self:cToken

/*/{Protheus.doc} FINA921a
    Função dummy para uso da função FindFunction()
    @type  Function
    @author user
    @since 03/12/2021   
/*/
Function FINA921a()
    
Return Nil
