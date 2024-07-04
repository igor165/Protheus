#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RETAILPRICELISTAPI.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
    API para consulta de Pre�os dos Produtos do Varejo
/*/
//-------------------------------------------------------------------
WSRESTFUL RetailPriceList DESCRIPTION STR0001 FORMAT "application/json,text/html"   //"API para consulta de Pre�os dos Produtos do Varejo"

    WSDATA internalId       as Character
    WSDATA Fields           as Charecter    Optional
    WSDATA Page             as Integer 	    Optional
    WSDATA PageSize         as Integer		Optional        
    WSDATA Order    	    as Character   	Optional

    WSMETHOD GET Headers;
        DESCRIPTION STR0002;    //"Retorna uma lista com o cabe�alho de todas as Tabelas de Pre�o"
        PATH "/api/retail/v1/retailPriceList";
        WSSYNTAX "/api/retail/v1/retailPriceList/{Order, Fields, Page, PageSize}";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET InternalIdHeader;
        DESCRIPTION STR0003;    //"Retorna o cabe�alho de uma �nica Tabela de Pre�o a partir do internalId (identificador �nico da Tabela de Pre�o)"
        PATH "/api/retail/v1/retailPriceList/{internalId}";
        WSSYNTAX "/api/retail/v1/retailPriceList/{internalId, Fields}";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET TableInternalIdItems;
        DESCRIPTION STR0004;    //"Retorna todos os itens de uma �nica Tabela de Pre�o a partir do internalId (identificador �nico da Tabela de Pre�o)"
        PATH "/api/retail/v1/retailPriceList/{internalId}/itensTablePrice";
        WSSYNTAX "/api/retail/v1/retailPriceList/{internalId}/itensTablePrice/{Order, Fields, Page, PageSize}";
        PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna uma lista com o cabe�alho de todas as Tabelas de Pre�o

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET Headers QUERYPARAM Fields, Page, PageSize, Order WSREST RetailPriceList

    Local lRet              As Logical
    Local oRetailPriceList  As Object

    oRetailPriceList := RetailPriceListObj():New(self)
    oRetailPriceList:SetSelect("DA0")
    oRetailPriceList:Get()
    
    If oRetailPriceList:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRetailPriceList:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRetailPriceList:GetError() ) )
    EndIf

    FwFreeObj(oRetailPriceList)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna o cabe�alho de uma �nica Tabela de Pre�o a partir do internalId (identificador �nico da Tabela de Pre�o)

@param InternalId - Identificador �nico da Tabela de Pre�o

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET InternalIdHeader PATHPARAM InternalId QUERYPARAM Fields WSREST RetailPriceList

    Local lRet              As Logical
    Local oRetailPriceList  As Object

    oRetailPriceList := RetailPriceListObj():New(self)
    oRetailPriceList:SetSelect("DA0")
    oRetailPriceList:Get()
    
    If oRetailPriceList:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRetailPriceList:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRetailPriceList:GetError() ) )
    EndIf

    FwFreeObj(oRetailPriceList)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna todos os itens de uma �nica Tabela de Pre�o a partir do internalId (identificador �nico da Tabela de Pre�o)

@param internalId - Identificador �nico da Tabela de Pre�o

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET TableInternalIdItems PATHPARAM internalId QUERYPARAM Fields, Page, PageSize, Order WSREST RetailPriceList

    Local lRet              As Logical
    Local oRetailPriceList  As Object

    oRetailPriceList := RetailPriceListObj():New(self)
    oRetailPriceList:SetSelect("DA1")
    oRetailPriceList:Get()
    
    If oRetailPriceList:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRetailPriceList:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRetailPriceList:GetError() ) )
    EndIf
    
    FwFreeObj(oRetailPriceList)

Return lRet