#Include "RESTFUL.CH"
#Include "TOTVS.CH"     
#Include "PROTHEUS.CH"                                                                                               
#Include "TBICONN.CH"       
#Include "SUPPEDINFORREST.CH"

//-------------------------------------------------------------------
/*/
    Baseado na documentação em: https://tdn.totvs.com/display/framework/09.+FWAdapterBaseV2
/*/
//-------------------------------------------------------------------
WSRESTFUL OrderInformation DESCRIPTION STR0009 FORMAT "application/json"
	
    WSDATA Page 					AS INTEGER OPTIONAL
	WSDATA PageSize					AS INTEGER OPTIONAL
    WSDATA Order                    AS CHARACTER OPTIONAL
    WSDATA OrderPurpose             AS CHARACTER OPTIONAL
    WSDATA Fields                   AS CHARACTER OPTIONAL

    WSMETHOD POST DESCRIPTION STR0010;
             WSSYNTAX "/OrderInformation" ;
             PATH "/OrderInformation" ;
             PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD POST WSREST OrderInformation
Return getOrderList(self)

Static Function getOrderList(oWS)
    Local lRet  as logical 
    Local oProd as object
    Local cMarca    := ""
    Local cEmpre	:= ""
    Local cBranc	:= ""
    Local oJson As object
    Local oBody As Object
    Local cFilter   := ""
    Local cNum      := []
    Local cType     := ""
    Local cMoeda    := ""
    Local nContItem    := 0
    
    lRet := .T.
    
    DEFAULT oWS:Page      := 1 
    DEFAULT oWS:PageSize  := 10
    DEFAULT oWS:Fields    :="ordernumber,orderitem,itemcode,itemunitofmeasure,registerdate,orderquantity,orderunitprice,ordertotalprice,quantitydelivered,closed,wasteeliminated,invoicenumber,invoiceitem,invoicequantity,invoiceunitprice,invoicetotalprice"
    
    oBody := JsonObject():New()
    cCatch := oBody:FromJSON( oWS:GetContent() )   

    If cCatch == Nil 
      cMarca   := oBody["SourceApp"]
      cEmpre   := oBody["CompanyId"]
      cBranc   := oBody["BranchId"]
      cNum     := oBody["OrderList"] 
      
      // cType => Objetivo do pedido / 1 - Compra / 2 - Venda
      cType    := oBody["OrderPurpose"]
      cMoeda   := oBody["CurrencyId"]
    EndIf

    If !ValidaInformacoesEntrada(cMarca, cEmpre, cBranc, cType)
       Return .F.
	EndIf

	aEmpre := FWEAIEMPFIL(cEmpre, cBranc, cMarca)

	If Len (aEmpre) < 2
       SetRestFault(400, STR0001 + STR0002 + "' !")
       Return .F.
    EndIf 

	If Len (aEmpre) > 1
		RESET ENVIRONMENT
		RPCSetType(3)
        if cType == "1"
		    PREPARE ENVIRONMENT EMPRESA aEmpre[1] FILIAL aEmpre[2] TABLES "SD1","SC7" MODULO "COM" 
        Else
            PREPARE ENVIRONMENT EMPRESA aEmpre[1] FILIAL aEmpre[2] TABLES "SC5","SC6","SD2" MODULO "FAT" 
        EndIf    
	EndIf
    
    iCampoMoeda := BuscarCampoMoeda(cMoeda)

    cFilter := BuscarFiltro(cNum, cMarca, cType)
    if EMPTY(cFilter)
        SetRestFault(400,STR0012 + cFilter)
        lRet := .F.
        Return lRet
    EndIf

    oProd := OrderAdapter():new('GET') 
    oProd:setPage(oWS:Page)
    oProd:setPageSize(oWS:PageSize)
    oProd:SetOrderQuery(oWS:Order)
    oProd:SetFields(oWS:Fields)  
    oProd:GetListOrders(cFilter, cType)
  
    If oProd:lOk
        cJasonResponse = oProd:getJSONResponse()
        oJson := JsonObject():New()
        ret := oJson:FromJson(cJasonResponse)
        
        IF ret == Nil .And. iCampoMoeda > 1
            FOR nContItem := 1 to Len(oJson["items"]) 
                 oJson["items"][nContItem]["orderunitprice"] = xMoeda(oJson["items"][nContItem]["orderunitprice"], 1, iCampoMoeda, dDataBase )
                 oJson["items"][nContItem]["ordertotalprice"] = xMoeda(oJson["items"][nContItem]["ordertotalprice"], 1, iCampoMoeda, dDataBase )
                 oJson["items"][nContItem]["invoiceunitprice"] = xMoeda(oJson["items"][nContItem]["invoiceunitprice"], 1, iCampoMoeda, dDataBase )
                 oJson["items"][nContItem]["invoicetotalprice"] = xMoeda(oJson["items"][nContItem]["invoicetotalprice"], 1, iCampoMoeda, dDataBase )
                 oJson["items"][nContItem]["orderinternalid"] = BuscarIntPdCExt(oJson["items"][nContItem]["ordernumber"], cMarca, cType )
                 oJson["items"][nContItem]["orderexternalid"] = BuscarIntToExt(oJson["items"][nContItem]["orderinternalid"], cMarca, cType)
            NEXT
        else
            FOR nContItem := 1 to Len(oJson["items"]) 
                 oJson["items"][nContItem]["orderinternalid"] = BuscarIntPdCExt(oJson["items"][nContItem]["ordernumber"], cMarca, cType )
                 oJson["items"][nContItem]["orderexternalid"] = BuscarIntToExt(oJson["items"][nContItem]["orderinternalid"], cMarca, cType)
            NEXT   
        endif

        oWS:SetResponse(oJson:toJson())
    EndIf
  
    oProd:DeActivate()
    oProd := nil  
Return lRet

static Function BuscarCampoMoeda(cMoeda)
	Local iCampoMoeda := 1
    
    If Empty(cMoeda) 
       return iCampoMoeda
    endif   

    if Upper(SuperGetMv("MV_SIMB2",,"")) == Upper(cMoeda)
		iCampoMoeda := 2 
	elseif Upper(SuperGetMv("MV_SIMB3",,"")) == Upper(cMoeda)
		iCampoMoeda := 3 
	elseif Upper(SuperGetMv("MV_SIMB4",,"")) == Upper(cMoeda)
		iCampoMoeda := 4 
	elseif Upper(SuperGetMv("MV_SIMB5",,"")) == Upper(cMoeda)
		iCampoMoeda := 5 
	endif
return iCampoMoeda

static Function BuscarFiltro(cNum, cMarca, cType )
    Local filter    := ""
    Local nContItem := 0
    Local separador := ""
    Local cOrders   := {}
    Local cCampo    := "C5_NUM"

    If cType == "1"
        cCampo = "C7_NUM"
    EndIf

    FOR nContItem := 1 to Len(cNum) 
        cOrders := BuscarIntId(RTrim(cNum[nContItem]), cMarca, cType)
        if cOrders[1]
            filter := filter + separador + "'" + SUBSTR(cOrders[2][3],1,TamSX3( cCampo )[1]) + "'"
            separador = ","
        EndIf   
    NEXT
    
return filter

Static Function ValidaInformacoesEntrada(cMarca, cEmpre, cBranc, cType)				

    Local lRet := .T.

    If Empty(cMarca) 
        SetRestFault(400, STR0003 + "sourceApp" + STR0004)
        lRet := .F.
    EndIf

    If Empty(cEmpre) 
        SetRestFault(400, STR0003 + "companyId" + STR0004)
        lRet := .F.
    EndIf

    If Empty(cBranc) 
        SetRestFault(400, STR0003 + "branchId" + STR0004)
        lRet := .F.
    EndIf

    If Empty(cType) 
        SetRestFault(400, STR0003 + "OrderPurpose" + STR0004)
        lRet := .F.
    EndIf
Return lRet

Function BuscarIntId(cInternalID, cRefer, cType)
	Local   aResult  := {}
	Local   aTemp    := {}
	Local   cTemp    := ''
	Local   cAlias   := 'SC5'
	Local   cField   := 'C5_NUM'
    
    If cType == "1"
	    cAlias   := 'SC7'
	    cField   := 'C7_NUM'
    EndIf

	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

	If Empty(cTemp)
		aAdd(aResult, .F.)
		aAdd(aResult, STR0013 + " -> " + cInternalID) 
	Else
        aAdd(aResult, .T.)
		aTemp := Separa(cTemp, '|')
		aAdd(aResult, aTemp)
	EndIf
Return aResult

Function BuscarIntToExt(cInternalID, cRefer, cType)
	Local   aResult  := ""
	Local   cAlias   := 'SC5'
	Local   cField   := 'C5_NUM'
    
    If cType == "1"
	    cAlias   := 'SC7'
	    cField   := 'C7_NUM'
    EndIf

	aResult := RTrim(CFGA070Ext(cRefer, cAlias, cField, cInternalID))

Return aResult


Function BuscarIntPdCExt(cValorInterno, cRefer, cType)
	Local   aResult  := ""
	Local   cAlias   := 'SC5'
	Local   cField   := 'C5_NUM'
    Local   cPdCVer := RTrim(PmsMsgUVer('ORDER', 'MATA410'))

    If cType == "1"
	    cAlias   := 'SC7'
	    cField   := 'C7_NUM'
        cPdCVer := RTrim(PmsMsgUVer('ORDER', 'MATA120'))
        aResult := IntPdCExt(/*Empresa*/, /*Filial*/,cValorInterno, Nil, cPdCVer)[2]
    Else
        aResult := IntPdVExt(/*Empresa*/, /*Filial*/, cValorInterno, Nil, cPdCVer)[2]
    EndIf

Return aResult
