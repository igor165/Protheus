#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LJFIDELITYCORE.CH"

Function LjFidelityCore ; Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjFidelityCore
Classe responsavel por centralizar o processo do FidelityCore

@type       Class
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Class LjFidelityCore
    
    Data oIntegrationConfiguration    as Object
    
    Data oLjFidelityCoreInterface     as Object
    Data oLjFidelityCoreCommunication as Object

    Data lChoseToUse                  as Logical
    
    Data oMessageError                as Object

    Method New(oIntegrationConfiguration)
    Method Initiation(cId,nNetSaleValue,oLjCustomerFidelityCore)
    Method Finalization(cPos, cSellerName,cFiscalId,nQtyItens)
    Method Clean()
    Method SendSale(oLjSaleFidelityCore)
    Method CancelBonus(cBusinessUnitId,cSaleId)
    Method ChoseToUse()

    Method GetBonus()

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor

@type       Method
@param      oIntegrationConfiguration, LjIntegrationConfiguration, Objeto com informações das configurações de integração
@return     LjFidelityCore, Objeto instânciado
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method New(oIntegrationConfiguration) Class LjFidelityCore
    
    Self:oMessageError := LjMessageError():New()
    Self:oLjFidelityCoreCommunication := LjFidelityCoreCommunication():New(oIntegrationConfiguration)
    Self:lChoseToUse := .F.
    
Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Initiation
Inicializa o fluxo de aplicação e resgate de bônus

@type       Method
@param      cId, Caractere, Identificador da venda 
@param      nNetSaleValue, Numérico, Valor líquido utilizado para o cálculo de bônus
@param      oLjCustomerFidelityCore, LjCustomerFidelityCore, Objeto com os dados do cliente
@return     Lógico, Define se o processo de inicialização foi confirmado
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method Initiation(cId,nNetSaleValue,oLjCustomerFidelityCore) Class LjFidelityCore

    Self:lChoseToUse := MsgYesNo("O Cliente gostaria de utilizar o programa de bonificação ?"/*STR0001 Atualizar esta com erro de portugues*/, STR0002)  //"O Cliente gostaria de utilizar o programa de bonificação ?"    //"TOTVS Bonificações"

    If Self:lChoseToUse
        Self:oLjFidelityCoreInterface     := LjFidelityCoreInterface():New(Self:oLjFidelityCoreCommunication, cId, nNetSaleValue, oLjCustomerFidelityCore)
        Self:lChoseToUse := Self:oLjFidelityCoreInterface:Initiation()
        
    EndIf

Return Self:lChoseToUse

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Finalization
Finaliza o fluxo de aplicação e resgate de bônus

@type       Method
@param      cPos, Caractere, Código da estação
@param      cSellerName, Caractere, Nome do vendedor
@param      cFiscalId, Caractere, Identificador da venda
@param      nQtyItens, Numérico, Quantidade de itens vendidos
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method Finalization(cPos, cSellerName,cFiscalId,nQtyItens,nNetSaleValue) Class LjFidelityCore
    Self:oLjFidelityCoreInterface:Finalization(cPos,cSellerName,cFiscalId,nQtyItens,nNetSaleValue)
    Self:lChoseToUse := .F.
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Clean
Limpa o fluxo de aplicação e resgate de bônus para preparar para a próxima venda

@type       Method
@author     Rafael Tenorio da Costa
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method Clean() Class LjFidelityCore

    self:oLjFidelityCoreInterface:oLjFidelityCoreCommunication := Nil
    self:lChoseToUse := .F.
    FwFreeObj(self:oLjFidelityCoreInterface)

Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonus
Retorna o valor do bônus

@type       Method
@return     Numérico, Valor do bônus
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetBonus() Class LjFidelityCore
    Local nResult := 0
    If ValType(Self:oLjFidelityCoreInterface) == "O"
        nResult := Self:oLjFidelityCoreInterface:GetBonus()
    EndIf 
return nResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SendSale
Envia a venda para o FidelityCore

@type       Method
@param      cBusinessUnitId, Caractere, Código da empresa e filial
@param      cCustumerName, Caractere, Nome do cliente
@param      cSellerName, Caractere, Nome do vendedor
@param      cSaleId, Caractere, Código da venda
@param      nNetSaleValue, Numérico, Valor líquido utilizado para o cálculo de bônus
@param      cPosCode, Caractere, Código da estação
@param      nTotalQuantityItems, Numérico, Quantidade de itens
@param      cFiscalId, Caractere, Identificador da venda
@return     Array, {Lógico, JsonObject}
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SendSale(cBusinessUnitId,cCustumerName,cSellerName,cSaleId,nNetSaleValue,cPosCode,nTotalQuantityItems,cFiscalId) Class LjFidelityCore
    
    Local lResult               := .F.
    Local jResult               := Nil
    Local oLjCustomer           := LjCustomerFidelityCore():New(cCustumerName)    
    Local oLjSaleFidelityCore   := LjSaleFidelityCore():New(cSaleId,nNetSaleValue,cPosCode,cSellerName,nTotalQuantityItems,cFiscalId)
    
    Default cBusinessUnitId     := FWArrFilAtu(,cFilAnt)[18]

    oLjSaleFidelityCore:SetCustomer(oLjCustomer)
    
    If Self:oLjFidelityCoreCommunication:Order(cBusinessUnitId,oLjSaleFidelityCore)
        
        If ExistFunc("Lj7GrvPhone")
            Lj7GrvPhone()
        EndIf

        jResult := Self:oLjFidelityCoreCommunication:ResultOrder()
        lResult := ValType(jResult) == "J"
    Else
        Self:oMessageError:SetError(GetClassName(Self),Self:oLjFidelityCoreCommunication:oMessageError:GetMessage()) 
    Endif 

return {lResult,jResult,Self:oMessageError:GetMessage()}

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CancelBonus
Efetua o cancelamento do bônus de uma determinada venda

@type       Method
@param      cBusinessUnitId, Caractere, Código da empresa e filial
@param      cSaleId, Caractere, Código da venda
@return     Array, {Lógico, JsonObject}
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method CancelBonus(cBusinessUnitId, cSaleId, cPosCode, cCel) Class LjFidelityCore

    Local jResult             := Nil
    Local lResult             := .F.
    Local oLjSaleFidelityCore := LjSaleFidelityCore():New(cSaleId,,cPosCode)

    Default cBusinessUnitId   := FWArrFilAtu(,cFilAnt)[18]
    Default cCel              := ""
    
    If Self:oLjFidelityCoreCommunication:Cancel(cBusinessUnitId, oLjSaleFidelityCore, cCel)
        jResult := Self:oLjFidelityCoreCommunication:ResultCancel()
        lResult := ValType(jResult) == "J"
    Else
        Self:oMessageError:SetError(GetClassName(Self),Self:oLjFidelityCoreCommunication:oMessageError:GetMessage()) 
    Endif 

return {lResult,jResult,Self:oMessageError:GetMessage()}

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ChoseToUse
Retonar o conteúdo da propriedade ChoseToUse

@type       Method
@return     Lógico, Define se o processo de bonificação esta sendo utilizado
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method ChoseToUse() Class LjFidelityCore
return Self:lChoseToUse
