#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RETAILITEMAPI.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
    API para consulta de Produtos do Varejo
/*/
//-------------------------------------------------------------------
WSRESTFUL RetailItem DESCRIPTION STR0001 FORMAT "application/json,text/html"    //"API para consulta de Produtos do Varejo"

    WSDATA Fields       as Charecter    Optional
    WSDATA Page         as Integer 	    Optional
    WSDATA PageSize     as Integer		Optional
    WSDATA Order    	as Character   	Optional

    WSMETHOD GET Items;
        DESCRIPTION STR0002;    //"Retorna uma lista com todos os Produtos"
        PATH "/api/retail/v1/RetailItem";
        WSSYNTAX "/api/retail/v1/RetailItem/{Order, Page, PageSize, Fields}";
        PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna uma lista com todos os Produtos

@author  Rafael Tenorio da Costa
@since   17/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET Items QUERYPARAM Fields, Page, PageSize, Order WSREST RetailItem

    Local lRet         As Logical
    Local oRetailItem  As Object

    oRetailItem := RetailItemObj():New(self)
    oRetailItem:Get()
    
    If oRetailItem:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRetailItem:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRetailItem:GetError() ) )
    EndIf

    FwFreeObj(oRetailItem)

Return lRet