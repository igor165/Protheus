#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RETAILSALESAPI.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
    API para Inclusão/consulta de Vendas do Varejo
/*/
//-------------------------------------------------------------------
WSRESTFUL RetailSales DESCRIPTION STR0002 FORMAT "application/json,text/html"   //"API para Inclusão\Consulta\Cancelamento de Vendas do Varejo"

    WSDATA InternalId       as Character    Optional
    WSDATA Fields           as Charecter    Optional
    WSDATA Page             as Integer 	    Optional
    WSDATA PageSize         as Integer		Optional
    WSDATA Order    	    as Character   	Optional 

    WSMETHOD GET Headers;
        DESCRIPTION STR0003;    //"Retorna uma lista com o cabeçalho de todas as Vendas"
        PATH "/api/retail/v1/RetailSales";
        WSSYNTAX "/api/retail/v1/RetailSales/{Order, Fields, Page, PageSize}";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET Items;
        DESCRIPTION STR0004;    //"Retorna todos os itens de uma única Venda a partir do internalId (identificador único da Venda)"
        PATH "/api/retail/v1/RetailSales/{internalId}/items";
        WSSYNTAX "/api/retail/v1/RetailSales/{internalId}/items/{Order, Fields, Page, PageSize}";
        PRODUCES APPLICATION_JSON

    WSMETHOD POST Main ;
        DESCRIPTION STR0005; //"Inclui Venda Varejo"
        WSSYNTAX "/api/retail/v1/RetailSales/";
        PATH     "/api/retail/v1/RetailSales";
        PRODUCES APPLICATION_JSON     

    WSMETHOD POST Exec ;
        DESCRIPTION STR0011; //"Inclui Venda Varejo utilizando o ExecAuto LOJA701"
        WSSYNTAX "/api/retail/v2/RetailSales/";
        PATH     "/api/retail/v2/RetailSales";
        PRODUCES APPLICATION_JSON

    WSMETHOD POST InternalId;
        DESCRIPTION STR0006; //"Realiza o cancelamento de uma venda"
        PATH "/api/retail/v1/RetailSales/{InternalId}/Cancelation";
        WSSYNTAX "/api/retail/v1/RetailSales/{InternalId}/Cancelation";
        PRODUCES APPLICATION_JSON RESPONSE EaiObj    

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna uma lista com o cabeçalho de todos os Vendas

@author  rafael.pessoa
@since   02/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET Headers QUERYPARAM Fields, Page, PageSize, Order WSREST RetailSales

    Local lRet            As Logical
    Local oRetailSales    As Object

    oRetailSales := RetailSalesObj():New(self)
    oRetailSales:SetSelect("SL1")
    oRetailSales:Get()
    
    If oRetailSales:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRetailSales:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRetailSales:GetError() ) )
    EndIf

    FwFreeObj(oRetailSales)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna todos os itens de uma única Venda a partir do internalId (identificador único da Venda)

@param InternalId - Identificador único da Venda

@author  rafael.pessoa
@since   02/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET Items PATHPARAM InternalId QUERYPARAM Fields, Page, PageSize, Order WSREST RetailSales

    Local lRet            As Logical
    Local oRetailSales    As Object

    oRetailSales := RetailSalesObj():New(self)
    oRetailSales:SetSelect("SL2")
    oRetailSales:Get()
    
    If oRetailSales:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRetailSales:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRetailSales:GetError() ) )
    EndIf

    FwFreeObj(oRetailSales)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Inclui uma nova Venda Varejo
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
@author  rafael.pessoa
@since   09/08/2019
@version 1.0
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
/*/
//-------------------------------------------------------------------
WSMETHOD POST Main WSREST RetailSales

    Local lRet          as Logical
    Local oApiControl   as Object
         
    oApiControl := RetailSalesObj():New(self)
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

//-------------------------------------------------------------------
/*/{Protheus.doc}
Inclui uma nova Venda Varejo via ExecAuto do LOJA701

@author  Bruno Almeida
@since   08/06/2021
@version 1.0
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
/*/
//-------------------------------------------------------------------
WSMETHOD POST Exec WSREST RetailSales

    Local lRet          as Logical
    Local oApiControl   as Object
         
    oApiControl := RetailSalesObj():New(Self)
    oApiControl:PostLoja701()   

    If oApiControl:Success()
        lRet := .T.
        Self:SetResponse( EncodeUtf8( oApiControl:GetReturn() ) )
    Else
        lRet := .F.        
        SetRestFault(oApiControl:GetStatus(), EncodeUtf8( oApiControl:GetError() ) )
    EndIf

    FwFreeObj(oApiControl)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Cancela uma nova Venda Varejo
@param InternalId - ID da venda para realizar o cancelamento
@author  fabricio.panhan
@since   01/11/2018
@version 1.0
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
/*/
//-------------------------------------------------------------------
WSMETHOD POST InternalId PATHPARAM InternalId WSREST RetailSales

    Local lRet AS LOGICAL
    Local aChaveCancelamento := {}
    Local cBranchId AS STRING
    Local cRetailSalesInternalId AS STRING
    Local cNumCancDoc AS STRING
    Local cOperatorCode AS STRING
    Local oRetailSales AS OBJECT

    Self:SetContentType("application/json")
    lRet := .F.
    cNumCancDoc := ""
    oRetailSales := RetailSalesCancelationAdapter():new()
    oRetailSales:oEaiObjRec := fwEaiObj():new()
    oRetailSales:oEaiObjRec:setRestMethod("GET")
    oRetailSales:oEaiObjRec:activate()

    If empty(self:InternalId)
        SetRestFault(400, EncodeUtf8(STR0007))//"Para cancelar uma venda é necessário informar a Filial, o Número do Orçamento de Venda, o Número do Operador de Caixa e Número do Documento de Cancelamento SAT, caso exista ('DMG01|0001|C06|12345')."
    EndIf

    aChaveCancelamento := strtokarr2(self:InternalId, "|")

    If Len(aChaveCancelamento) < 3
        SetRestFault(400, EncodeUtf8(STR0007))
    EndIf

    cBranchId := aChaveCancelamento[1]
    cRetailSalesInternalId := aChaveCancelamento[2]
    If Len(aChaveCancelamento) >= 3
        cOperatorCode := aChaveCancelamento[3]
    Else
        SetRestFault(400, EncodeUtf8(STR0008))//"Para cancelar uma venda é necessário informar Número do Operador de Caixa na posição três ('FILIAL|NÚMERO VENDA|NÚMERO OPERADOR|DOC CANCELAMENTO SAT' - Ex. 'DMG01|0001|C06|12345')."
    EndIf

    If Len(aChaveCancelamento) == 4
        cNumCancDoc := aChaveCancelamento[4]
    EndIf

    oRetailSales:oEaiObjRec:setPathParam("InternalId", cBranchId +"|"+ cRetailSalesInternalId)
    oRetailSales:GetRetailSales()

    oRetailSales:oEaiObjRec:setRestMethod("DELETE")
    oRetailSales:oEaiObjRec:setProp("CompanyId", cEmpAnt)
    oRetailSales:oEaiObjRec:setProp("BranchId", cBranchId)
    oRetailSales:oEaiObjRec:setProp("InternalId", cBranchId +"|"+ cRetailSalesInternalId)
    oRetailSales:oEaiObjRec:setProp("RetailSalesInternalId", cRetailSalesInternalId)
    oRetailSales:oEaiObjRec:setProp("OperatorCode", cOperatorCode)
    oRetailSales:oEaiObjRec:setProp("CancelDate", Date())
    oRetailSales:oEaiObjRec:setProp("NfceCancelProtocol", "")
    oRetailSales:oEaiObjRec:setProp("CancellationDocument", cNumCancDoc)

    If oRetailSales:lOk
        oRetailSales:DeleteRetailSales()
        If Len(oRetailSales:cError) > 0
            SetRestFault(400, EncodeUtf8(oRetailSales:cError))
            lRet := .F.
        Else
            Self:SetResponse( EncodeUtf8( oRetailSales:oEaiobjSnd:getJson(,.T.) ) )
            lRet := .T.
        EndIf
    Else
        SetRestFault(404, EncodeUtf8(oRetailSales:cError))
        lRet := .F.
    EndIf

Return lRet
