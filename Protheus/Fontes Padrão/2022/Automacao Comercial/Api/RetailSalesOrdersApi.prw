#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RETAILSALESORDERSAPI.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
    API para consulta de Pedidos de Venda do Varejo
/*/
//-------------------------------------------------------------------
WSRESTFUL RetailSalesOrders DESCRIPTION STR0001 FORMAT "application/json,text/html"   //"API para consulta de Pedidos de Venda do Varejo"

    WSDATA internalId       as Character
    WSDATA Fields           as Charecter    Optional
    WSDATA Page             as Integer 	    Optional
    WSDATA PageSize         as Integer		Optional        
    WSDATA Order    	    as Character   	Optional

    WSMETHOD GET Headers;
        DESCRIPTION STR0002;    //"Retorna uma lista com o cabeçalho de todos os Pedidos de Venda"
        PATH "/api/retail/v1/retailSalesOrders";
        WSSYNTAX "/api/retail/v1/retailSalesOrders/{Order, Fields, Page, PageSize}";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET Items;
        DESCRIPTION STR0003;    //"Retorna todos os itens de um único Pedido de Venda a partir do internalId (identificador único do Pedido de Venda)"
        PATH "/api/retail/v1/retailSalesOrders/{internalId}/items";
        WSSYNTAX "/api/retail/v1/retailSalesOrders/{internalId}/items/{Order, Fields, Page, PageSize}";
        PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna uma lista com o cabeçalho de todos os Pedidos de Vendas

@author  Rafael Tenorio da Costa
@since   02/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET Headers QUERYPARAM Fields, Page, PageSize, Order WSREST RetailSalesOrders

    Local lRet                  As Logical
    Local oRetailSalesOrders    As Object

    oRetailSalesOrders := RetailSalesOrdersObj():New(self)
    oRetailSalesOrders:SetSelect("SC5")
    oRetailSalesOrders:Get()
    
    If oRetailSalesOrders:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRetailSalesOrders:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRetailSalesOrders:GetError() ) )
    EndIf

    FwFreeObj(oRetailSalesOrders)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna todos os itens de um único Pedido de Venda a partir do internalId (identificador único do Pedido de Venda)

@param InternalId - Identificador único do Pedido de Venda

@author  Rafael Tenorio da Costa
@since   02/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET Items PATHPARAM InternalId QUERYPARAM Fields, Page, PageSize, Order WSREST RetailSalesOrders

    Local lRet                  As Logical
    Local oRetailSalesOrders    As Object

    oRetailSalesOrders := RetailSalesOrdersObj():New(self)
    oRetailSalesOrders:SetSelect("SC6")
    oRetailSalesOrders:Get()
    
    If oRetailSalesOrders:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRetailSalesOrders:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRetailSalesOrders:GetError() ) )
    EndIf

    FwFreeObj(oRetailSalesOrders)

Return lRet