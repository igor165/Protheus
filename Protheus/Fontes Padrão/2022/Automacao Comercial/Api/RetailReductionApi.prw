#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
//#INCLUDE "RETAILREDUCTIONAPI.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
    API para Inclusão/consulta de  Redução Z do Varejo
/*/
//-------------------------------------------------------------------
WSRESTFUL RetailReduction DESCRIPTION "API para Inclusão\Consulta\ de Redução Z do Varejo" FORMAT "application/json,text/html"   //"API para Inclusão\Consulta\ de Redução Z do Varejo"

    WSMETHOD POST Main ;
        DESCRIPTION "Inclui Redução Z Varejo"; //"Inclui Redução Z Varejo"
        WSSYNTAX "/api/retail/v1/RetailReduction/";
        PATH     "/api/retail/v1/RetailReduction";
        PRODUCES APPLICATION_JSON     

END WSRESTFUL



//-------------------------------------------------------------------
/*/{Protheus.doc}
Inclui uma nova redução Z do Varejo
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
@author  rafael.pessoa
@since   26/08/2019
@version 1.0
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
/*/
//-------------------------------------------------------------------
WSMETHOD POST Main WSREST RetailReduction

    Local lRet          as Logical
    Local oApiControl   as Object
         
    oApiControl := RetailReductionObj():New(self)
    oApiControl:Post()   

    If oApiControl:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oApiControl:GetReturn() ) )
    Else
        lRet := .F.        
        SetRestFault(oApiControl:GetStatus(), EncodeUtf8( oApiControl:GetError() ) )
    EndIf

    FwFreeObj(oApiControl)

Return lRet