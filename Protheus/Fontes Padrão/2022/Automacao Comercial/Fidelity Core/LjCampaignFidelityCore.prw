#include "TOTVS.CH"
#include "msobject.ch"

Function LjCampaignFidelityCore ; Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjCampaignFidelityCore
Classe que representa uma campanha para o FidelityCore

@type       Class
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.23

@return
/*/
//-------------------------------------------------------------------------------------
Class LjCampaignFidelityCore 
    Data cId as Character

    Method New(cId)
    Method GetIdCampaign() 
    Method SetIdCampaign(cId)
EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo contrutor

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cId, Caracter, Id da campanha

@return Objeto, Classe
/*/
//-------------------------------------------------------------------------------------
Method New(cId) Class LjCampaignFidelityCore
    Self:cId := cId
return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetIdCampaign
Metodo responsavel por retornar o conteudo da propriedade cId

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cId
/*/
//-------------------------------------------------------------------------------------
Method GetIdCampaign() Class LjCampaignFidelityCore
return Alltrim(Self:cId)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetIdCampaign
Metodo responsavel por atualizar o conteudo da propriedade cId

@type       Method
@oaram      cId, Caracter, Identificador da empresa
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetIdCampaign(cId) Class LjCampaignFidelityCore
    Self:cId := cId
return 