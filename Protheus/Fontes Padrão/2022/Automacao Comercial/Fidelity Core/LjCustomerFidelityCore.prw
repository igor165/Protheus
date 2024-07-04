#include "TOTVS.CH"
#include "msobject.ch"

Function LjCustomerFidelityCore ; Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjCustomerFidelityCore
Classe que representa um cliente para o FidelityCore

@type       Class
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.23

@return
/*/
//-------------------------------------------------------------------------------------
Class LjCustomerFidelityCore From LjCustomer

    Data oMessageError      as Object

    Data cCostumerId        as Character

    Data oBonus             as Object
    Data oCampaign          as Object
    Data oAuthentication    as Object

    Method New(cName,cDocument,cEmail,oPhone,dBirthday,cGender)
    Method GetPhone()
    Method GetIdentificationCode()
    Method GetBirthday()

    // -- CostumerId
    Method SetCostumerId(cCostumerId)
    Method GetCostumerId()

    // -- Bonus
    Method SetBonus(oBonus,cBonusId,nBonusAmount,cPartnerCode,cPartner,nBonusReferenceValue)
    Method GetBonusId()
    Method GetBonusAmount()
    Method GetBonusReferenceValue()
    Method GetBonus()

    // -- CampaignId
    Method SetCampaign(oCampaign,cId)
    Method GetIdCampaign()
    Method SetIdCampaign(cId)

    // -- Authentication
    Method SetAuthentication(oAuthentication,cType,cSentCode,lValidatedByException)
    Method GetTypedCodeAuthentication()
    Method GetSentCodeAuthentication()
    Method GetTypeAuthentication()
    Method GetValidatedByExceptionAuthentication()
    
    Method SetValidatedByExceptionAuthentication(lValidExc)
    Method SetTypedCode(cTypedCode)

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo contrutor

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cName, Caracter, Nome do cliente
@param cDocument, Caracter, documento de identificação do cliente
@param cEmail, Caracter, Email do cliente
@param oPhone, Objeto, Objeto responsavel por representar um telefone
@param dBirthday, Data, Data de aniversario do cliente
@param cGender, Caracter, Gênero do cliente

@return Objeto, Classe
/*/
//-------------------------------------------------------------------------------------
Method New(cName,cDocument,cEmail,oPhone,dBirthday,cGender) Class LjCustomerFidelityCore
    
    _Super:New(cName,cDocument,cEmail,oPhone,dBirthday,cGender)

    Self:oMessageError := LjMessageError():New()
    
Return Self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPhone
Metodo responsavel por retornar o numero de telefone no padrão que o FidelityCore necessita.

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cPhone
/*/
//-------------------------------------------------------------------------------------
Method GetPhone() Class LjCustomerFidelityCore
    Local oPhone := _Super:GetPhone() 
    Local cPhone := Alltrim(oPhone:cDDD) + Alltrim(oPhone:cPhone)
Return cPhone

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetIdentificationCode
Metodo responsavel por retornar a chave de busca para o parceirocadastrado no FidelityCore
Obs: Evoluir para esperar o tipo, hoje esta fixo para o telefone (crm&Bonus)
@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cPhone
/*/
//-------------------------------------------------------------------------------------
Method GetIdentificationCode() Class LjCustomerFidelityCore
Return Self:GetPhone()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBirthday
Metodo responsavel por retornar a data de nascimento no formato necessario para o FidelityCore

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade dBirthday
/*/
//-------------------------------------------------------------------------------------
Method GetBirthday() Class LjCustomerFidelityCore

    Local cBirthday := ""

    If !Empty( _Super:GetBirthday() )
        cBirthday := Substr(DTOS(_Super:GetBirthday()),1,4) + "-" + Substr(DTOS(_Super:GetBirthday()),5,2) + "-" + Substr(DTOS(_Super:GetBirthday()),7,2)
    EndIf

Return cBirthday

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetCostumerId
Metodo responsavel setar a propriedade cCostumerId

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cCostumerId, Caracter, codigo do cliente

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method SetCostumerId(cCostumerId) Class LjCustomerFidelityCore
    Self:cCostumerId := cCostumerId
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBirthday
Metodo responsavel por retornar o codigo do cliente retornado pelo fidelityCore

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cCostumerId
/*/
//-------------------------------------------------------------------------------------
Method GetCostumerId() Class LjCustomerFidelityCore
Return Alltrim(Self:cCostumerId)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetBonus
Metodo responsavel setar a propriedade oBonus

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cCostumerId, Obejto, Objeto Bonus ja instanciado
@param cCostumerId, Caracter, Id do bonus
@param cCostumerId, Caracter, Valor do Bonus

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method SetBonus(oBonus,cBonusId,nBonusAmount,cPartnerCode,cPartner,nBonusReferenceValue) Class LjCustomerFidelityCore
    If oBonus <> Nil
        Self:oBonus := oBonus 
    Else
        Self:oBonus := LjBonusFidelityCore():New(cBonusId,nBonusAmount,cPartnerCode,cPartner,nBonusReferenceValue)
    EndIf 
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetCampaign
Metodo responsavel setar a propriedade oCampaign

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param oCampaign, Obejto, Objeto campanha ja instanciado
@param cCostumerId, Caracter, Id da campanha

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method SetCampaign(oCampaign,cId) Class LjCustomerFidelityCore
    If oCampaign <> Nil
        Self:oCampaign := oCampaign 
    Else
        Self:oCampaign := LjCampaignFidelityCore():New(cId)
    EndIf 
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetAuthentication
Metodo responsavel setar a propriedade oBonus

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param oAuthentication, Obejto, Objeto Authentication ja instanciado
@param cType, Caracter, tipo de autenticação 
@param cSentCode, Caracter, Codigo informado pelo usuario
@param lValidatedByException, Logico, indica se foi feita uma validação por exceção

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method SetAuthentication(oAuthentication,cType,cSentCode,lValidatedByException) Class LjCustomerFidelityCore
    If oAuthentication <> Nil
        Self:oAuthentication := oAuthentication 
    Else
        Self:oAuthentication := LjAuthenticationFidelityCore():New(cType,cSentCode,lValidatedByException)
    EndIf 
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonusId
Metodo responsavel devolver o GetBonusId
@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, GetBonusId
/*/
//-------------------------------------------------------------------------------------
Method GetBonusId() Class LjCustomerFidelityCore
return iif(Self:oBonus == Nil,"",Self:oBonus:GetBonusId())

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonusAmount
Metodo responsavel devolver o GetBonusAmount da classe LjBonusFidelityCore

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, GetBonusAmount
/*/
//-------------------------------------------------------------------------------------
Method GetBonusAmount() Class LjCustomerFidelityCore
return iif(Self:oBonus == Nil,"0",cValTochar(Self:oBonus:GetBonusAmount()))

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonusReferenceValue
Metodo responsavel devolver o GetBonusReferenceValue da classe LjBonusFidelityCore

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, GetBonusReferenceValue
/*/
//-------------------------------------------------------------------------------------
Method GetBonusReferenceValue() Class LjCustomerFidelityCore
return iif(Self:oBonus == Nil,"0",cValTochar(Self:oBonus:GetBonusReferenceValue()))

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonus
Metodo responsavel devolver o GetBonusAmount da classe LjBonusFidelityCore

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Numerico, GetBonusAmount
/*/
//-------------------------------------------------------------------------------------
Method GetBonus() Class LjCustomerFidelityCore
return iif(Self:oBonus == Nil,0,Self:oBonus:GetBonusAmount())

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetIdCampaign
Metodo responsavel devolver o GetIdCampaign da classe LjCampaignFidelityCore

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caractere, GetIdCampaign
/*/
//-------------------------------------------------------------------------------------
Method GetIdCampaign() Class LjCustomerFidelityCore
return iif(Self:oCampaign == Nil,Nil,Self:oCampaign:GetIdCampaign())

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetIdCampaign
Metodo responsavel por atualizar a propriedade cId da classe LjCampaignFidelityCore

@type       Method
@oaram      cId, Caracter, Identificador da empresa
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetIdCampaign(cId) Class LjCustomerFidelityCore
    If Self:oCampaign <> Nil
        Self:oCampaign:SetIdCampaign(cId)
    EndIf 
return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTypedCodeAuthentication
Metodo responsavel devolver o GetTypedCodeAuthentication da classe LjAuthenticationFidelityCore

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cTypedCode
/*/
//-------------------------------------------------------------------------------------
Method GetTypedCodeAuthentication() Class LjCustomerFidelityCore
return iif(Self:oAuthentication == Nil,Nil,Self:oAuthentication:GetTypedCodeAuthentication())

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSentCodeAuthentication
Metodo responsavel devolver o GetSentCodeAuthentication da classe LjAuthenticationFidelityCore

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cSentCode sem CR/LF/TAB e sem acentos
/*/
//-------------------------------------------------------------------------------------
Method GetSentCodeAuthentication() Class LjCustomerFidelityCore
return iif(Self:oAuthentication == Nil,"",FwCutOff(Self:oAuthentication:GetSentCodeAuthentication()) + "\n\n")

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTypeAuthentication
Metodo responsavel devolver o GetTypeAuthentication da classe LjAuthenticationFidelityCore

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cType
/*/
//-------------------------------------------------------------------------------------
Method GetTypeAuthentication() Class LjCustomerFidelityCore
return iif(Self:oAuthentication == Nil,"",Self:oAuthentication:GetTypeAuthentication())

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetValidatedByExceptionAuthentication
Metodo responsavel devolver o GetValidatedByExceptionAuthentication da classe LjAuthenticationFidelityCore com tratamento para retornar como caractere.

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, true\false
/*/
//-------------------------------------------------------------------------------------
Method GetValidatedByExceptionAuthentication() Class LjCustomerFidelityCore
    Local lResult := iif(Self:oAuthentication == Nil,.F.,Self:oAuthentication:GetValidatedByExceptionAuthentication())
    Local cResult := ""
   
    If lResult
        cResult := "true"
    Else
        cResult := "false"
    EndIf 

return cResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetValidatedByExceptionAuthentication
Metodo responsavel por atualizar o conteudo da propriedade lValidatedByException da classe LjAuthenticationFidelityCore

@type       Method
@param      lValidExc, Lógico, Define se deverá validar a exceção
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetValidatedByExceptionAuthentication(lValidExc) Class LjCustomerFidelityCore
    Self:oAuthentication:SetValidatedByExceptionAuthentication(lValidExc)
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetValidatedByExceptionAuthentication
Metodo responsavel por atualizar o conteudo da propriedade lValidatedByException da classe LjAuthenticationFidelityCore

@type       Method
@param      lValidExc, Lógico, Define se deverá validar a exceção
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetTypedCode(cTypedCode) Class LjCustomerFidelityCore
    Self:oAuthentication:SetTypedCode(cTypedCode)
Return