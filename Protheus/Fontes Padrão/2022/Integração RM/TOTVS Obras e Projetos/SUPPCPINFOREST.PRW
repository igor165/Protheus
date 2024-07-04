#Include "RESTFUL.CH"
#Include "TOTVS.CH"     
#Include "PROTHEUS.CH"                                                                                               
#Include "TBICONN.CH"       
#Include "SUPITEMINFOREST.CH"

//-------------------------------------------------------------------
/*/
    Baseado na documentação em: https://tdn.totvs.com/display/framework/09.+FWAdapterBaseV2
/*/
//-------------------------------------------------------------------
WSRESTFUL ProductionOrderInformation DESCRIPTION "Serviço para busca de informações de Ordem de Produção utilizado na integração TCOP X PCP no EAI 2.0" FORMAT "application/json"
	
    WSDATA Page 					AS INTEGER OPTIONAL
	WSDATA PageSize					AS INTEGER OPTIONAL
    WSDATA Order                    AS CHARACTER OPTIONAL
    WSDATA Fields                   AS CHARACTER OPTIONAL

    WSMETHOD POST DESCRIPTION "Retorna informações do status da Ordem de Produção e data de previsão para conclusão";
             WSSYNTAX "/ProductionOrderInformation" ;
             PATH "/ProductionOrderInformation" ;
             PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD POST WSREST ProductionOrderInformation
Return getProductionOrderList(self)

Static Function getProductionOrderList(oWS)
    Local lRet  as logical 
    Local oProd as object
    Local cMarca    := ""
    Local cEmpre	:= {}
    Local cBranc	:= ""
    Local oJson As object
    Local oBody As Object
    Local cFilter   := ""
    Local cNum      := []
    
    lRet := .T.
    DEFAULT oWS:Page      := 1 
    DEFAULT oWS:PageSize  := 10
    DEFAULT oWS:Fields    :="ordernumber,orderitem,sequence,productcode,warehouse,expectedstartdate,intendeddeliverydate,priority,actualenddate,status,initialadjusteddate,finaladjusteddate,ok,productionordertype,productiontype"
    
    oBody := JsonObject():New()
    cCatch := oBody:FromJSON( oWS:GetContent() )   

    if cCatch == Nil 
      cMarca   := oBody["SourceApp"]
      cEmpre   := oBody["CompanyId"]
      cBranc   := oBody["BranchId"]
      cNum     := oBody["OrderList"] 
    EndIf

    if !ValidaInformacoesEntrada(cMarca, cEmpre, cBranc)
       Return .F.
	EndIf

	aEmpre := FWEAIEMPFIL(cEmpre, cBranc, cMarca)

	if Len (aEmpre) < 2
		SetRestFault(400, STR0001 + cEmpre + STR0002 + cBranc + "' !")
        lRet := .F.
		Return lRet
	EndIf 

	if Len (aEmpre) > 1
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA aEmpre[1] FILIAL aEmpre[2] TABLES "SC2" MODULO "PCP" 
	EndIf

    cFilter := BuscarFiltro(cNum, cMarca)
    if EMPTY(cFilter)
        SetRestFault(400,"Nenhuma Ordem de Produção encontrada!")
        lRet := .F.
        Return lRet
    EndIf

    oProd := ProductionOrderAdapter():new('GET') 
    oProd:setPage(oWS:Page)
    oProd:setPageSize(oWS:PageSize)
    oProd:SetOrderQuery(oWS:Order)
    oProd:SetFields(oWS:Fields)  
    oProd:GetListProductionOrders(cFilter)
  
    If oProd:lOk
        cJasonResponse = oProd:getJSONResponse()
        oJson := JsonObject():New()
        ret := oJson:FromJson(cJasonResponse)
        oWS:SetResponse(oJson:toJson())
    Else
        SetRestFault(oProd:GetCode(),oProd:GetMessage())
        lRet := .F.
    EndIf
  
    oProd:DeActivate()
    oProd := nil  
Return lRet

static Function BuscarFiltro(cNum, cMarca )
    Local filter    := ""
    Local nContItem := 0
    Local separador := ""
    Local cOrders   := {}
    
        FOR nContItem := 1 to Len(cNum) 
        cOrders := IntOPInt(RTrim(cNum[nContItem]), cMarca, /*Versão*/)
        if cOrders[1]
            filter := filter + separador + "'" + SUBSTR(cOrders[2][3],1,TamSX3( 'C2_NUM' )[1]) + "'"
            separador = ","
        EndIf   
        NEXT
    
return filter

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

Function IntOPInt(cInternalID, cRefer, cVersao)
	Local   aResult  := {}
	Local   aTemp    := {}
	Local   cTemp    := ''
	Local   cAlias   := 'SC2'
	Local   cField   := 'C2_NUM'
	Default cVersao  := '2.006'

	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

	If Empty(cTemp)
		aAdd(aResult, .F.)
		aAdd(aResult, "Ordem de Produção não encontrado no de/para!" + " -> " + cInternalID) 
	Else
        aAdd(aResult, .T.)
		aTemp := Separa(cTemp, '|')
		aAdd(aResult, aTemp)
	EndIf
Return aResult
