#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RETAILSTOCKLEVEL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}

@author  Danilo Santos
@since   
/*/
//-------------------------------------------------------------------
WSRESTFUL RetailStockLevel DESCRIPTION STR0001 FORMAT "application/json,text/html"

    WSDATA Fields           as Charecter    Optional
    WSDATA Page             as Integer 	    Optional
    WSDATA PageSize         as Integer		Optional        
    WSDATA Order    	    as Character   	Optional

    WSMETHOD GET Headers;
        DESCRIPTION STR0002;
        PATH "/api/retail/v1/RetailStockLevel";
        WSSYNTAX "/api/retail/v1/RetailStockLevel/{Order, Fields, Page, PageSize}";
        PRODUCES APPLICATION_JSON
        //PRODUCES APPLICATION_JSON RESPONSE EaiObj   //"Retorna todos os Produtos disponiveis de acordo com os par�metros Page, PageSize e Order. Por default Page = 1 e PageSize = 10"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc}

@author  Danilo Santos
@since   
/*/
//-------------------------------------------------------------------
WSMETHOD GET Headers QUERYPARAM Fields, Page, PageSize, Order WSREST RetailStockLevel

    Local lRet              As Logical
    Local oRetailStockLevel  As Object

    oRetailStockLevel := RetailStockLevelObj():New(self)
    oRetailStockLevel:SetSelect("SB2")
    oRetailStockLevel:Get()
    
    If oRetailStockLevel:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRetailStockLevel:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRetailStockLevel:GetError() ) )
    EndIf

    FwFreeObj(oRetailStockLevel)

Return lRet