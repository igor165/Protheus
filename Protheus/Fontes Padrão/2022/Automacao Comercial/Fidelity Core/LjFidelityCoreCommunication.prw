#include "TOTVS.CH"
#include "msobject.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjFidelityCoreCommunication
Classe responsavel pela comunicação com o FidelityCore

@type       Class
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return
/*/
//-------------------------------------------------------------------------------------
Class LjFidelityCoreCommunication

    Data oIntegrationConfiguration as Object
    Data oMessageError             as Object

    Data oRestClient               as Object

    Data jResultForms              as Object
    Data jResultIdentification     as Object
    Data jResultAuthentication     as Object
    Data jResultBonus              as Object
    Data jResultcampaign           as Object
    Data jResultfinalize           as Object
    Data jResultCancel             As Object
    Data jResultOrder              As Object

    Data cServiceCode              AS Character
    Data cEnvironment              As Character
    Data cUrl                      As Character

    Method New(oIntegrationConfiguration)
    
    Method Communication(cVerb,cPath,cPostParams,cVarResult) 
    Method GetURL() 
    
    Method Forms(cBusinessUnitId)
    Method ResultForms()

    Method Identification(cBusinessUnitId,cPartnerCode,oLjSaleFidelityCore)
    Method ResultIdentification()

    Method Authentication(cBusinessUnitId,cPartnerCode,oLjSaleFidelityCore,cStoreId)
    Method ResultAuthentication()

    Method Bonus(cBusinessUnitId,cPartnerCode,oLjSaleFidelityCore,cStoreId)
    Method ResultBonus()

    Method Campaign(cBusinessUnitId,cPartnerCode,oLjSaleFidelityCore,cStoreId)
    Method ResultCampaign()

    Method Finalize(cBusinessUnitId,cPartnerCode,oLjSaleFidelityCore,cStoreId)
    Method Resultfinalize()

    Method Cancel(cBusinessUnitId,oLjSaleFidelityCore)
    Method ResultCancel()

    Method Order(cBusinessUnitId,oLjSaleFidelityCore)
    Method ResultOrder()

    Method GetError()

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo contrutor

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param oIntegrationConfiguration, Objeto, Contem as informações pertinentes ao Produto/serviço
@return Objeto, Classe
/*/
//-------------------------------------------------------------------------------------
Method New(oIntegrationConfiguration) Class LjFidelityCoreCommunication
    
    Self:oIntegrationConfiguration := oIntegrationConfiguration
    Self:oMessageError             := LjMessageError():New()
    Self:cServiceCode              := "TFC"

Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Communication
Metodo responsavel por centralizar a comunicação com a API.

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cVerb, Caracter, Indica o verbo que será utilizado (Ex.: Post, Get.. etc.)
@param cPath, cPath, Caminho da API
@param cPostParams, cPostParams, Json contendo o corpo da mensagem.
@param cVarResult, Caracter, Nome da variavel em que será salvo o retorno da API

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Communication(cVerb,cPath,cPostParams,cVarResult) Class LjFidelityCoreCommunication
    Local aHeadStr      := {}
    Local cResult       := ""
    Local cToken        := Self:oIntegrationConfiguration:GetToken(Self:cServiceCode)
    Local oRestClient   := FWRest():New(Self:GetURL())
    Local oJson         := JsonObject():New()

    Default cVerb       := "Get"
    Default cPostParams := ""

    Self:oMessageError:ClearError()
    
    If Empty(cToken)
        Self:oMessageError:SetError(GetClassName(Self),Self:oIntegrationConfiguration:oMessageError:GetMessage(),2) 
    ElseIf Empty(cPath)
        Self:oMessageError:SetError(GetClassName(Self),"Parametro contendo o Path esta vazio, este é um parametro obrigatorio.",2) 
    ElseIf Empty(cPostParams) .And. Upper(Alltrim(cVerb)) == "POST"
        Self:oMessageError:SetError(GetClassName(Self),"Parametro contendo o cPostParams esta vazio, este é um parametro obrigatorio.",2)  
    EndIf 

    If Self:oMessageError:GetStatus()

        AAdd( aHeadStr, "Content-Type: application/json")
        AAdd( aHeadStr, "Authorization: Bearer " + cToken)

        oRestClient:setPath(cPath)
        oRestClient:SetPostParams(EncodeUTF8(cPostParams))

        LjGrvLog("LjFidelityCoreCommunication", "Comunicando com o serviço.", {Self:GetURL(), cPath, aHeadStr, cPostParams}, /*lCallStack*/)

        If &("oRestClient:" + cVerb + "(aHeadStr)")

            cResult := DecodeUTF8( oRestClient:GetResult() )

            LjGrvLog("LjFidelityCoreCommunication", "Retorno do serviço.", cResult, /*lCallStack*/)

            cResult := oJson:FromJson(cResult)

            If ValType(cResult) == "U"  
                &("Self:" + cVarResult) := oJson
            Else
                Self:oMessageError:SetError(GetClassName(Self),"Não foi possivel realizar o Parse do retorno da API, ERRO: " + cResult,2)
            EndIf

        Else
            Self:oMessageError:SetError(GetClassName(Self),"Retorno da API: " + Iif(Empty(oRestClient:cResult),"Sem retorno",oRestClient:cResult),2)
            Self:oMessageError:SetError(GetClassName(Self),"ERROR: " + oRestClient:GetLastError(),2)
        EndIf 

    EndIf 

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------
/*/{Protheus.doc} GetURL
Método que retorna a URL para acesso ao serviço

@type       method
@author     Rafael Tenorio da Costa
@return     Caractere, URL de acesso ao serviço
@version    12.1.33
/*/
//-------------------------------------------------------------------
Method GetURL() Class LjFidelityCoreCommunication

    If Empty(Self:cEnvironment)
        Self:cEnvironment := Self:oIntegrationConfiguration:GetEnvironment(Self:cServiceCode)
    EndIf 

    If Empty(Self:cUrl)
        Do Case
            // -- Staging
            Case Self:cEnvironment == "1"
                Self:cUrl := "https://staging.raas.varejo.totvs.com.br/api/fidelity/rewards"
            
            // -- Produção
            Case Self:cEnvironment == "2"
                Self:cUrl := "https://raas.varejo.totvs.com.br/api/fidelity/rewards"
            
            // -- DEV ou QA
            Case Self:cEnvironment == "3"
                Self:cUrl := "https://qa.raas.varejo.totvs.com.br/api/fidelity/rewards"
            
            // -- URL de produção
            Otherwise
                Self:cUrl := "https://raas.varejo.totvs.com.br/api/fidelity/rewards"
        EndCase
    EndIf 

Return Self:cUrl

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Forms
Metodo consome API de formulario, API inical, retorna os parametros para dar continuidade na comunicação com o cliente.

@type       Method
@author     Lucas Novais (lnovais@)
@since      06/05/2021
@version    12.1.33

@param cBusinessUnitId, Caracter, Codigo da unidade de negocio

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Forms(cBusinessUnitId) Class LjFidelityCoreCommunication

    Self:Communication("Get","/identification/forms/" + cBusinessUnitId,"","jResultForms")

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultForms
Metodo responsavel pelo retorno do metodo Forms

@type       Method
@author     Lucas Novais (lnovais@)
@since      06/05/2021
@version    12.1.33

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method ResultForms() Class LjFidelityCoreCommunication
Return Self:jResultForms

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Identification
Metodo responsavel por montar o corpo da que será enviado para aPI  de identificação

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cBusinessUnitId, Caracter, Codigo da unidade de negocio
@param cPartnerCode, Caracter, Codigo do parceiro (condeudo devolvido na API de Forms)
@param oLjSaleFidelityCore, Objeto, Objeto da venda, contem todos os dados necessarios para o consumo das API (Objeto montado em varias etapas.)

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Identification(cBusinessUnitId,cPartnerCode,oLjSaleFidelityCore) Class LjFidelityCoreCommunication
    Local cParams

    BeginContent var cParams
        {
            "externalBusinessUnitId":"%Exp:cBusinessUnitId%",
            "partnerCode":"%Exp:cPartnerCode%",
            "sale":{
                "netSaleValue":%Exp:oLjSaleFidelityCore:GetNetSaleValue()%
            },
            "identification":{
                "identificationCode": "%Exp:oLjSaleFidelityCore:GetCustomer():GetIdentificationCode()%",
                "document": "%Exp:oLjSaleFidelityCore:GetCustomer():GetDocument()%",
                "email": "%Exp:oLjSaleFidelityCore:GetCustomer():GetEmail()%",
                "name": "%Exp:oLjSaleFidelityCore:GetCustomer():GetName()%",
                "phone": "%Exp:oLjSaleFidelityCore:GetCustomer():GetPhone()%",
                "birthday": "%Exp:oLjSaleFidelityCore:GetCustomer():GetBirthday()%",
                "gender": "%Exp:oLjSaleFidelityCore:GetCustomer():GetGender()%"
            }
        }        
    EndContent

    Self:Communication("Post","/identification",cParams,"jResultIdentification")

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultIdentification
Metodo responsavel pelo retorno do metodo Identification

@type       Method
@author     Lucas Novais (lnovais@)
@since      06/05/2021
@version    12.1.33

@return Objeto, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method ResultIdentification() Class LjFidelityCoreCommunication
Return Self:jResultIdentification

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Authentication
Metodo responsavel por montar o corpo da que será enviado para aPI  de Authentication

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cBusinessUnitId, Caracter, Codigo da unidade de negocio
@param cPartnerCode, Caracter, Codigo do parceiro (condeudo devolvido na API de Forms)
@param oLjSaleFidelityCore, Objeto, Objeto da venda, contem todos os dados necessarios para o consumo das API (Objeto montado em varias etapas.)
@param cStoreId, Chacter, Codigo do Parceiro na plataforma de FidelityCore

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Authentication(cBusinessUnitId,cPartnerCode,oLjSaleFidelityCore,cStoreId) Class LjFidelityCoreCommunication
    Local cParams := ""

    BeginContent var cParams
        {
            "externalBusinessUnitId":"%Exp:cBusinessUnitId%",
            "partnerCode":"%Exp:cPartnerCode%",
            "sale":{
                "netSaleValue":%Exp:oLjSaleFidelityCore:GetNetSaleValue()%
            },
            "identification":{
                "identificationCode": "%Exp:oLjSaleFidelityCore:GetCustomer():GetIdentificationCode()%",
                "storeId": "%Exp:cStoreId%",
                "costumerId": "%Exp:oLjSaleFidelityCore:GetCustomer():GetCostumerId()%"
            },
            "authentication": {
                "code": "%Exp:oLjSaleFidelityCore:GetCustomer():GetTypedCodeAuthentication()%",
                "type": "%Exp:oLjSaleFidelityCore:GetCustomer():GetTypeAuthentication()%"
            }
        }        
    EndContent

    Self:Communication("Post","/identification/authentication",cParams,"jResultAuthentication")

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultAuthentication
Metodo responsavel pelo retorno do metodo Authentication

@type       Method
@author     Lucas Novais (lnovais@)
@since      06/05/2021
@version    12.1.33

@return Objeto, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method ResultAuthentication() Class LjFidelityCoreCommunication 
Return Self:jResultAuthentication

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Bonus
Metodo responsavel por montar o corpo da que será enviado para aPI  de Bonus

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cBusinessUnitId, Caracter, Codigo da unidade de negocio
@param cPartnerCode, Caracter, Codigo do parceiro (condeudo devolvido na API de Forms)
@param oLjSaleFidelityCore, Objeto, Objeto da venda, contem todos os dados necessarios para o consumo das API (Objeto montado em varias etapas.)
@param cStoreId, Chacter, Codigo do Parceiro na plataforma de FidelityCore

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Bonus(cBusinessUnitId,cPartnerCode,oLjSaleFidelityCore,cStoreId) Class LjFidelityCoreCommunication
    Local cParams := ""

    BeginContent var cParams
        {
            "externalBusinessUnitId":"%Exp:cBusinessUnitId%",
            "partnerCode":"%Exp:cPartnerCode%",
            "sale":{
                "netSaleValue":%Exp:oLjSaleFidelityCore:GetNetSaleValue()%
            },
            "identification":{
                "identificationCode": "%Exp:oLjSaleFidelityCore:GetCustomer():GetIdentificationCode()%",
                "storeId": "%Exp:cStoreId%",
                "costumerId": "%Exp:oLjSaleFidelityCore:GetCustomer():GetCostumerId()%"
            }
        }        
    EndContent

    Self:Communication("Post","/bonus",cParams,"jResultBonus")

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultBonus
Metodo responsavel pelo retorno do metodo Authentication

@type       Method
@author     Lucas Novais (lnovais@)
@since      06/05/2021
@version    12.1.33

@return Objeto, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method ResultBonus() Class LjFidelityCoreCommunication 
Return Self:jResultBonus

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Campaign
Metodo responsavel por montar o corpo da que será enviado para aPI  de Campaign

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cBusinessUnitId, Caracter, Codigo da unidade de negocio
@param cPartnerCode, Caracter, Codigo do parceiro (condeudo devolvido na API de Forms)
@param oLjSaleFidelityCore, Objeto, Objeto da venda, contem todos os dados necessarios para o consumo das API (Objeto montado em varias etapas.)
@param cStoreId, Chacter, Codigo do Parceiro na plataforma de FidelityCore

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Campaign(cBusinessUnitId,cPartnerCode,oLjSaleFidelityCore,cStoreId) Class LjFidelityCoreCommunication
    Local cParams := ""

    BeginContent var cParams
        {
            "externalBusinessUnitId":"%Exp:cBusinessUnitId%",
            "partnerCode":"%Exp:cPartnerCode%",
            "sale":{
                "netSaleValue":%Exp:oLjSaleFidelityCore:GetNetSaleValue()%
            },
            "identification":{
                "identificationCode": "%Exp:oLjSaleFidelityCore:GetCustomer():GetIdentificationCode()%",
                "storeId": "%Exp:cStoreId%",
                "costumerId": "%Exp:oLjSaleFidelityCore:GetCustomer():GetCostumerId()%"
            }
        }        
    EndContent

    Self:Communication("Post","/campaign",cParams,"jResultcampaign")

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Resultcampaign
Metodo responsavel pelo retorno do metodo campaign

@type       Method
@author     Lucas Novais (lnovais@)
@since      06/05/2021
@version    12.1.33

@return Objeto, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Resultcampaign() Class LjFidelityCoreCommunication 
Return Self:jResultcampaign

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Finalize
Metodo responsavel por montar o corpo da que será enviado para aPI  de Finalize

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cBusinessUnitId, Caracter, Codigo da unidade de negocio
@param cPartnerCode, Caracter, Codigo do parceiro (condeudo devolvido na API de Forms)
@param oLjSaleFidelityCore, Objeto, Objeto da venda, contem todos os dados necessarios para o consumo das API (Objeto montado em varias etapas.)
@param cStoreId, Chacter, Codigo do Parceiro na plataforma de FidelityCore

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Finalize(cBusinessUnitId,cPartnerCode,oLjSaleFidelityCore,cStoreId) Class LjFidelityCoreCommunication
    Local cParams       := ""
    Local cNetSaleValue := cValtochar(Val(oLjSaleFidelityCore:GetNetSaleValue())) 

    BeginContent var cParams
        {
            "externalBusinessUnitId":"%Exp:cBusinessUnitId%",
            "partnerCode":"%Exp:cPartnerCode%",
            "sale":{
                "netSaleValue":%Exp:cNetSaleValue%,
                "posCode":"%Exp:oLjSaleFidelityCore:GetPosCode()%",
                "sellerName":"%Exp:oLjSaleFidelityCore:GetSellerName()%",
                "externalSaleId":"%Exp:oLjSaleFidelityCore:GetSaleId()%",
                "fiscalId":"%Exp:oLjSaleFidelityCore:GetFiscalId()%",
                "custumerName":"%Exp:oLjSaleFidelityCore:GetCustomer():GetName()%",
                "totalQuantityItems":%Exp:oLjSaleFidelityCore:GetTotalQuantityItems()%
            },
            "identification":{
                "identificationCode": "%Exp:oLjSaleFidelityCore:GetCustomer():GetIdentificationCode()%",
                "storeId": "%Exp:cStoreId%",
                "costumerId": "%Exp:oLjSaleFidelityCore:GetCustomer():GetCostumerId()%"
            },
            "bonus":{
                "bonusId":"%Exp:oLjSaleFidelityCore:GetCustomer():GetBonusId()%",
                "bonusAmountUsed":%Exp:oLjSaleFidelityCore:GetCustomer():GetBonusAmount()%,
                "bonusReferenceValue":%Exp:oLjSaleFidelityCore:GetCustomer():GetBonusReferenceValue()%
            },
            "campaigns":[
                {
                    "id":"%Exp:oLjSaleFidelityCore:GetCustomer():oCampaign:GetIdCampaign()%"
                }
            ],
            "authentication":{
                "code":"%Exp:oLjSaleFidelityCore:GetCustomer():GetSentCodeAuthentication()%",
                "type":"%Exp:oLjSaleFidelityCore:GetCustomer():GetTypeAuthentication()%",
                "validatedByException":%Exp:oLjSaleFidelityCore:GetCustomer():GetValidatedByExceptionAuthentication()%
            }
        }                   
    EndContent
    
    Self:Communication("Post","/bonus/finalize",cParams,"jResultfinalize")

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Resultfinalize
Metodo responsavel pelo retorno do metodo finalize

@type       Method
@author     Lucas Novais (lnovais@)
@since      06/05/2021
@version    12.1.33

@return Objeto, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Resultfinalize() Class LjFidelityCoreCommunication 
Return Self:jResultfinalize

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Cancel
Metodo responsavel por montar o corpo da que será enviado para aPI  de Cancel

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cBusinessUnitId, Caracter, Codigo da unidade de negocio
@param oLjSaleFidelityCore, Objeto, Objeto da venda, contem todos os dados necessarios para o consumo das API (Objeto montado em varias etapas.)

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Cancel(cBusinessUnitId, oLjSaleFidelityCore, cCel) Class LjFidelityCoreCommunication
    Local cParams := ""

    Default cCel := ""

    BeginContent var cParams
        {
            "externalBusinessUnitId": "%Exp:cBusinessUnitId%",
            "externalSaleCode": "%Exp:oLjSaleFidelityCore:GetSaleId()%",      
            "posCode": "%Exp:oLjSaleFidelityCore:GetPosCode()%",
            "identification":{
                "identificationCode": "%Exp:cCel%"
            }
        }      
    EndContent

    Self:Communication("Post","/bonus/cancel",cParams,"jResultCancel")

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultCancel
Metodo responsavel pelo retorno do metodo Cancel

@type       Method
@author     Lucas Novais (lnovais@)
@since      06/05/2021
@version    12.1.33

@return Objeto, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method ResultCancel() Class LjFidelityCoreCommunication 
Return Self:jResultCancel

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Order
Metodo responsavel por montar o corpo da que será enviado para aPI  de Campaign

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cBusinessUnitId, Caracter, Codigo da unidade de negocio
@param oLjSaleFidelityCore, Objeto, Objeto da venda, contem todos os dados necessarios para o consumo das API (Objeto montado em varias etapas.)

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method Order(cBusinessUnitId,oLjSaleFidelityCore) Class LjFidelityCoreCommunication
    Local cParams := ""

    BeginContent var cParams
        {
            "externalBusinessUnitId":"%Exp:cBusinessUnitId%",
            "sale":{
                "netSaleValue":%Exp:oLjSaleFidelityCore:GetNetSaleValue()%,
                "posCode":"%Exp:oLjSaleFidelityCore:GetPosCode()%",
                "sellerName":"%Exp:oLjSaleFidelityCore:GetSellerName()%",
                "externalSaleId":"%Exp:oLjSaleFidelityCore:GetSaleId()%",
                "fiscalId":"%Exp:oLjSaleFidelityCore:GetFiscalId()%",
                "custumerName":"%Exp:oLjSaleFidelityCore:GetCustomer():GetName()%",
                "totalQuantityItems":%Exp:oLjSaleFidelityCore:GetTotalQuantityItems()%
            }
        }
    EndContent

    Self:Communication("Post","/order",cParams,"jResultOrder")

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultOrder
Metodo responsavel pelo retorno do metodo Order

@type       Method
@author     Lucas Novais (lnovais@)
@since      06/05/2021
@version    12.1.33

@return Objeto, resultado da classe
/*/
//-------------------------------------------------------------------------------------
Method ResultOrder() Class LjFidelityCoreCommunication 
Return Self:jResultOrder

//-------------------------------------------------------------------
/*/{Protheus.doc} GetError
Método que retorna a mensagem de erro

@type       method
@author     Rafael Tenorio da Costa
@return     Caractere, Descrição do erro
@version    12.1.33
/*/
//-------------------------------------------------------------------
Method GetError() Class LjFidelityCoreCommunication
Return AllTrim( Self:oMessageError:GetMessage() )
