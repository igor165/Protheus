#include "TOTVS.CH"
#include "msobject.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjRAASIntegration
Classe respons�vel por gerir todo os dados relacionados ao RASS e suas configura��es.

@type       Class
@author     Lucas Novais (lnovais@)
@since      09/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Class LjRAASIntegration
    
    Data oIntegrationConfiguration  as LjIntegrationConfiguration

    Data oServices                  as Object
    
    Data oFidelityCore              as FidelityCore
    
    Data oMessageError              as LjMessageError
    Data cProduct                   as Character
    Data cPos                       as Character
    Data cEnvironment               as Character

    Method New(cProduct,cPOS,cEnvironment)
    Method StartServices()
    Method GetFidelityCore()
    Method ServiceIsActive(cKey)
    Method GetComponent(cIdComponent,cServiceCode)

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@param      cProduct, Caractere, Sigla do produto da integra��o
@param      cPos, Caractere, C�digo da esta��o
@param      cEnvironment, Caractere, Ambiente que em que a integra��o esta sendo executada
@return     LjRAASIntegration, Objeto instanciado
@author     Lucas Novais (lnovais@)
@since      09/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method New(cProduct,cPos,cEnvironment) Class LjRAASIntegration
   
    Self:cProduct     := cProduct
    Self:cPos         := cPos
    Self:cEnvironment := cEnvironment
   
    Self:oMessageError              := LjMessageError():New()
    Self:oIntegrationConfiguration  := LjIntegrationConfiguration():New(Self:cProduct, Self:cPos)
    Self:oServices                  := THashMap():New()

    Self:StartServices()

Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} StartServices
Inicializa os servi�os ativos

@type       Method
@author     Rafael Tenorio da Costa
@since      09/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method StartServices() Class LjRAASIntegration

    Local aServices := Self:oIntegrationConfiguration:GetaServicesComponents()
    Local nServ     := 0

    For nServ:=1 To Len(aServices)

        //Carrega os servi�os e seus status
        Self:oServices:Set(aServices[nServ][1], aServices[nServ][3])

        //Verifica se esta ativo
        If aServices[nServ][3]

            // -- Inicia TOTVS Fidelity Core
            If aServices[nServ][1] == "TFC"
                Self:oFidelityCore :=  LjFidelityCore():New(Self:oIntegrationConfiguration,Self:cProduct,Self:cPos,Self:cEnvironment)
            EndIf
        EndIf

    Next nServ

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetFidelityCore
Retorna objeto LjFidelityCore

@type       Method
@return     LjFidelityCore, Objeto instanciado
@author     Lucas Novais (lnovais@)
@since      09/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetFidelityCore() Class LjRAASIntegration
return Self:oFidelityCore

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ServiceIsActive
Verifica se o servi�o esta ativo

@type       Method
@param      cKey, Caractere, Sigla do servi�o
@return     L�gico, Define se o servi�o esta ativo
@author     Rafael Tenorio da Costa
@since      09/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method ServiceIsActive(cKey) Class LjRAASIntegration
    
    Local lAtivo := .F.

    Self:oServices:Get(cKey, @lAtivo)

Return lAtivo

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetComponent
Retorna o conte�do de um componente de um servi�o

@type       Method
@param      cIdComponent, Caractere, Identifica��o do componente consultado
@param      cServiceCode, Caractere, Sigla do servi�o consultado
@return     LjFidelityCore, Objeto instanciado
@author     Lucas Novais (lnovais@)
@since      09/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetComponent(cIdComponent,cServiceCode) Class LjRAASIntegration
return Self:oIntegrationConfiguration:GetComponent(cIdComponent,cServiceCode)