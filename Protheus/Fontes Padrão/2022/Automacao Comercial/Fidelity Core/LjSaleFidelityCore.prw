#include "TOTVS.CH"
#include "msobject.ch"

Function LjSaleFidelityCore ; Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjSaleFidelityCore
Classe responsavel pelas particularidades da venda para o FidelityCore

@type       Class
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Class LjSaleFidelityCore From LjSale
    
    Method New(cSaleId,nNetSaleValue,cPosCode,cSellerName,nTotalQuantityItems,cFiscalId)
    Method GetNetSaleValue()
    Method GetTotalQuantityItems()

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@param      cSaleId, Caractere, Identificador da venda
@param      nNetSaleValue, Num�rico, Valor l�quido da venda
@param      cPosCode, Caractere, C�digo da esta��o
@param      cSellerName, Caractere, Nome do vendedor
@param      nTotalQuantityItems, Num�rico, Quantidade total de itens da venda
@param      cFiscalId, Caractere, Identificador fiscal da venda
@return     LjSaleFidelityCore, Objeto inst�nciado
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method New(cSaleId,nNetSaleValue,cPosCode,cSellerName,nTotalQuantityItems,cFiscalId) Class LjSaleFidelityCore

    _Super:New(cSaleId,nNetSaleValue,cPosCode,cSellerName,nTotalQuantityItems,cFiscalId)
   
Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetNetSaleValue
Retorna o valor liqu�do da venda como caractere

@type       Method
@return     Caractere, Valor l�quido da venda
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetNetSaleValue() Class LjSaleFidelityCore
Return Alltrim(STR(_Super:GetNetSaleValue()))

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetNetSaleValue
Retorna a quantidade total de itens da venda como caractere

@type       Method
@return     Caractere, Quantidade total de itens da venda
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetTotalQuantityItems() Class LjSaleFidelityCore
Return cValToChar(_Super:GetTotalQuantityItems())