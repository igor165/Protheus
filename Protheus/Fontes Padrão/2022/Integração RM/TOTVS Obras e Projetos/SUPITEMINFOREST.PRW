#Include "RESTFUL.CH"
#Include "TOTVS.CH"     
#Include "PROTHEUS.CH"                                                                                               
#Include "TBICONN.CH"       
#Include "SUPITEMINFOREST.CH"

//-------------------------------------------------------------------
/*/
    Criado com base na documentação em: https://tdn.totvs.com/display/framework/09.+FWAdapterBaseV2
/*/
//-------------------------------------------------------------------
WSRESTFUL getitemsinformation DESCRIPTION STR0009 FORMAT "application/json,text/html"

	WSDATA Page 					AS INTEGER OPTIONAL
	WSDATA PageSize					AS INTEGER OPTIONAL
    WSDATA Order                    AS CHARACTER OPTIONAL
    WSDATA Fields                   AS CHARACTER OPTIONAL
    WSDATA SourceApp 				AS STRING
	WSDATA CompanyId 				AS STRING
	WSDATA BranchId 				AS STRING
	WSDATA InitialItemInternalId 	AS STRING
	WSDATA FinishItemInternalId 	AS STRING
	WSDATA CurrencyId			    AS STRING OPTIONAL

    // WSDATA aQueryString             AS ARRAY OPTIONAL

    WSMETHOD GET ItemList;
        DESCRIPTION STR0010;
        WSSYNTAX "/getitemsinformation" ;
        PATH "/getitemsinformation" ;
        PRODUCES APPLICATION_JSON
     
END WSRESTFUL


WSMETHOD GET ItemList QUERYPARAM Page, PageSize, Order, Fields, SourceApp, CompanyId, BranchId, InitialItemInternalId, FinishItemInternalId, CurrencyId  WSREST getitemsinformation
Return getItemList(self)

Static Function getItemList( oWS )
    Local lRet  as logical
    Local oProd as object
    Local cMarca    := ""
    Local cEmpre	:= {}
    Local cBranc	:= ""
    Local cIPrd	    := {}
    Local cFPrd	    := {}
    Local cMoeda    := ""
    Local iCampoMoeda  := 0
    Local oJson As object
    Local nContItem    := 0

    DEFAULT oWS:Page      := 1 
    DEFAULT oWS:PageSize  := 10
    DEFAULT oWS:Fields    := "code,description,group,unitofmeasure,groupdescription,priceone,pricetwo,costaverage,costunit"
    DEFAULT oWS:sourceApp				:= ""
    DEFAULT oWS:companyId				:= ""
    DEFAULT oWS:branchId				:= "" 
    DEFAULT oWS:InitialItemInternalId   := ""
    DEFAULT oWS:FinishItemInternalId	:= ""
    DEFAULT oWS:CurrencyId	            := ""

    lRet     := .T.

    cMarca   := oWS:sourceApp
    cEmpre   := oWS:companyId
    cBranc   := oWS:branchId 
    cMoeda   := RTrim(oWS:CurrencyId)

    if !ValidaInformacoesEntrada(cMarca, cEmpre, cBranc)
       Return .F.
	EndIf

	aEmpre := FWEAIEMPFIL(cEmpre, cBranc, cMarca)

	If Len (aEmpre) < 2
		SetRestFault(400, STR0001 + cEmpre + STR0002 + cBranc + "' !")
        lRet := .F.
		Return lRet
	EndIf 

	If Len (aEmpre) > 1
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA aEmpre[1] FILIAL aEmpre[2] TABLES "SB1", "SB2", "SBM", "SBZ" MODULO "EST" 
	EndIf

    iCampoMoeda := BuscarCampoMoeda(cMoeda)

    cIPrd := IntProInt(RTrim(oWS:InitialItemInternalId), cMarca, /*Versão*/)
    cFPrd := IntProInt(RTrim(oWS:FinishItemInternalId), cMarca, /*Versão*/)

	If !ValidaInternalIdProduto(cIPrd, cFPrd)
       Return .F.
	EndIf

    oProd := ItemAdapter():new( 'GET' ) 
    oProd:setPage(oWS:Page)
    oProd:setPageSize(oWS:PageSize)
    oProd:SetOrderQuery(oWS:Order)
 
    // setUrlFilter indica o filtro querystring recebido (pode se utilizar um filtro oData)
    // oProd:SetUrlFilter(oWS:aQueryString)
    oProd:SetFields( oWS:Fields )  
    oProd:GetListItem(cIPrd[2][3], cFPrd[2][3], iCampoMoeda)
  
    If oProd:lOk
        cJasonResponse = oProd:getJSONResponse()
        oJson := JsonObject():New()
        ret := oJson:FromJson(cJasonResponse)
       
        IF ret == Nil .And. iCampoMoeda > 1
            FOR nContItem := 1 to Len(oJson["items"]) 
                 oJson["items"][nContItem]["priceone"] = xMoeda(oJson["items"][nContItem]["priceone"], 1, iCampoMoeda, dDataBase )
                 oJson["items"][nContItem]["pricetwo"] = xMoeda(oJson["items"][nContItem]["pricetwo"], 1, iCampoMoeda, dDataBase )
                 oJson["items"][nContItem]["costunit"] = xMoeda(oJson["items"][nContItem]["costunit"], 1, iCampoMoeda, dDataBase )
            NEXT
        endif

        oWS:SetResponse(oJson:toJson())
    Else
        SetRestFault(oProd:GetCode(),oProd:GetMessage())
        lRet := .F.
    EndIf
  
    oProd:DeActivate()
    oProd := nil  
Return lRet

Static Function ValidaInformacoesEntrada(cMarca, cEmpre, cBranc)				

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
Return lRet

static Function ValidaInternalIdProduto(cIPrd, cFPrd)				

    Local lRet := .T.

    Local aIntId := {}
    aIntId := cIPrd[2]
    
    If cIPrd[1] = .F.
        SetRestFault(404, cIPrd[2])
        lRet := .F.
    EndIf
    
    aIntId  := cFPrd[2]
    If cFPrd[1] = .F.
         SetRestFault(404, cFPrd[2])
        lRet := .F.
    EndIf
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
