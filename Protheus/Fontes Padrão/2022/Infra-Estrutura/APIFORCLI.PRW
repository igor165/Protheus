#include "totvs.ch"
#include "tbiconn.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} APIFORCLI
	TOTVS API CAROL - Função para conexão e busca dos dados do Fornecedor e Cliente de acordo com o CNPJ informado. 
	pela função APIFORCLI
	@type  Function
	@author Fabiano Dantas
	@since 29/12/2020
	@param 
	@return Array{lRet - Controle de erro, cTextJson - JSON de retorno, oRest - Objeto completo}
	@example
	(examples)
	@see (links_or_references)
/*/
Function APIFORCLI(cCnpj)

Local cURI      := "https://app.carol.ai/api"
Local cResource := "/v3/queries/named/findCompany"
Local oRest     := FwRest():New(cURI)
Local aHeader   := {}
Local cTextJson := ""
Local oJson     := Nil

AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
AAdd(aHeader, "Accept: application/json")
AAdd(aHeader, "X-Auth-Key: 535088c9ddfa49fd857fee91b08f76ba")
AAdd(aHeader, "X-Auth-ConnectorId: f9953f6645f449baaccd16ab462f9b64")
AAdd(aHeader, "indexType: MASTER")
AAdd(aHeader, "pageSize: 10")
AAdd(aHeader, "sortOrder: ASC")
AAdd(aHeader, "scrollable: false")

oJson := JsonObject():New()
cTextJson := '{"cnpj": "' + cCnpj +'"}'
//Realiza o post de acordo com o cURI e cResource
oRest:SetPath(cResource)
oRest:SetPostParams(cTextJson)

If (oRest:Post(aHeader))
    cTextJson := oRest:GetResult()
    FWLogMsg('WARN',, 'APIFORCLI', funName(), '', '01', "JSON: " + cTextJson , 0, 0, {})
    lRet := .T.
Else
    lRet := .F.
    cTextJson := oRest:GetLastError()
    FWLogMsg('WARN',, 'APIFORCLI', funName(), '', '01', "JSON: " + cTextJson , 0, 0, {})
EndIf

Return {lRet, cTextJson, oRest}