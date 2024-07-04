#include "TOTVS.CH"
#include "msobject.ch"

Function LjBonusFidelityCore ; Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjBonusFidelityCore
Classe que representa o bonus para o FidelityCore

@type       Class
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.23

@return
/*/
//-------------------------------------------------------------------------------------
Class LjBonusFidelityCore 
    
    Data cPartnerCode         as Character
    Data cPartner             as Character
    
    Data cBonusId             as Character
    Data nBonusAmount         as Numeric
    Data nBonusReferenceValue as Numeric

    Method New(cBonusId,nBonusAmount,cPartnerCode,cPartner,nBonusReferenceValue)
    Method GetBonusId()
    Method GetBonusAmount()
    Method GetIdPartner()
    Method GetPartner()
    Method GetBonusReferenceValue() 
EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo contrutor

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cBonusId, Caracter, codigo do bonus
@param nBonusAmount, Numerico, valor do bonus
@param cPartnerCode, Caractere, Código do parceiro
@param cPartner, Caractere, Nome do parceiro
@param nBonusReferenceValue, Numerico, Valor de referencia do bonus

@return Objeto, Classe
/*/
//-------------------------------------------------------------------------------------
Method New(cBonusId,nBonusAmount,cPartnerCode,cPartner,nBonusReferenceValue) Class LjBonusFidelityCore
    
    Default cBonusId             := ""
    Default nBonusAmount         := 0
    Default cPartnerCode         := ""
    Default cPartner             := ""
    Default nBonusReferenceValue := 0
    
    Self:cBonusId                := cBonusId
    Self:nBonusAmount            := nBonusAmount
    Self:cPartnerCode            := cPartnerCode
    Self:cPartner                := cPartner
    Self:nBonusReferenceValue    := nBonusReferenceValue

return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonusId
Metodo responsavel por retornar o conteudo da propriedade cBonusId

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cBonusId
/*/
//-------------------------------------------------------------------------------------
Method GetBonusId() Class LjBonusFidelityCore
return Alltrim(Self:cBonusId)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonusAmount
Metodo responsavel por retornar o conteudo da propriedade nBonusAmount

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Numérico, propriedade nBonusAmount
/*/
//-------------------------------------------------------------------------------------
Method GetBonusAmount() Class LjBonusFidelityCore
return Self:nBonusAmount

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonusId
Metodo responsavel por retornar o conteudo da propriedade cPartnerCode

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cPartnerCode
/*/
//-------------------------------------------------------------------------------------
Method GetIdPartner() Class LjBonusFidelityCore
return Alltrim(Self:cPartnerCode)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonusAmount
Metodo responsavel por retornar o conteudo da propriedade cPartner

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cPartner
/*/
//-------------------------------------------------------------------------------------
Method GetPartner() Class LjBonusFidelityCore
return Alltrim(Self:cPartner)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonusReferenceValue
Metodo responsavel por retornar o conteudo da propriedade nBonusReferenceValue

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade nBonusReferenceValue
/*/
//-------------------------------------------------------------------------------------
Method GetBonusReferenceValue() Class LjBonusFidelityCore
return Self:nBonusReferenceValue