#Include 'Protheus.ch'
#INCLUDE 'RestFul.ch'

WSRESTFUL TotalSales DESCRIPTION ("Api de retorna Quantidade e Valor de Venda do varejo no sistema Protheus.");
FORMAT "application/json,text/html" 

WSDATA Page       		AS INTEGER 	    OPTIONAL 
WSDATA PageSize    		AS INTEGER		OPTIONAL
WSDATA FIELDS           AS OBJECT       OPTIONAL
WSDATA Branches         AS CHARACTER    OPTIONAL
WSDATA Order    		AS CHARACTER   	OPTIONAL

WSMETHOD GET totalSales;
DESCRIPTION ("Retorna informações das vendas no Protheus.");
PATH "api/retail/v1/totalSales" ;
PRODUCES APPLICATION_JSON RESPONSE EaiObj

WSMETHOD GET canceled;
DESCRIPTION ("Retorna informações das vendas no Protheus.");
PATH "api/retail/v1/totalSales/canceled" ;
PRODUCES APPLICATION_JSON RESPONSE EaiObj

END WSRESTFUL
//-------------------------------------------------------------------
/*/{Protheus.doc} TotalSales
Método que ira buscar e retornar Totais das Vendas

@param Fields, Page,PageSize,Order

@return Vazio

@author Everson S P Junior
@since 28/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------

WSMETHOD GET totalSales QUERYPARAM Fields, Page,PageSize,Order WSREST TotalSales
Local oTotalSales   as OBJECT
Local nX			as INTEGER
Local cTODATE		as CHARACTER
Local cFROMDATE		as CHARACTER

    oTotalSales := TotalSales():new()
    oTotalSales:oEaiObjRec := fwEaiObj():new()
    oJsonfilter := &('JsonObject():New()')    
    oTotalSales:oEaiObjRec:setRestMethod('GET')
    
    if !empty(self:Page)
        oTotalSales:oEaiObjRec:setPage(self:Page)
    Else
        oTotalSales:oEaiObjRec:setPage(1)
    endIf

    if !empty(Self:PageSize)
        oTotalSales:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oTotalSales:oEaiObjRec:setPageSize(10)
    endIf

    If !empty(Self:Order)
        oTotalSales:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
      oTotalSales:oFields := Self:Fields
    endIf
    for nX := 1 to len(self:aQueryString)
        If !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
        	UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
        	UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
            UPPER(self:aQueryString[nX][1]) == 'FIELDS')     	        
        		If UPPER(self:aQueryString[nX][1]) == 'FROMDATE'
        			cFROMDATE:= Self:aQueryString[nX][2]
        			If At("T",cFROMDATE) > 0 //Sepera data e horario
        				cFROMDATE := Substr(cFROMDATE, 1, At("T", cFROMDATE) - 1)
        				cFROMDATE := AllTrim(StrTran(cFROMDATE, "-", ""))
        			EndIf	
        			oJsonfilter["FROMDATE"] := cFROMDATE
        		ElseIf UPPER(self:aQueryString[nX][1]) == 'TODATE'
        			cTODATE := self:aQueryString[nX][2]
        			If At("T",cTODATE) > 0 //Sepera data e horario
        				cTODATE := Substr(cTODATE, 1, At("T", cTODATE) - 1)
        				cTODATE := AllTrim(StrTran(cTODATE, "-", ""))
        			EndIf
        			oJsonfilter["TODATE"] 	:= cTODATE
        		ElseIf UPPER(self:aQueryString[nX][1]) == 'BRANCHES'
        			oJsonfilter["BRANCHES"] := Upper(self:aQueryString[nX][2])
        		EndIf	
        EndIf
    next nX    
    oJsonfilter["CANCELED"] := .F.
    oTotalSales:oEaiObjRec:activate()
    oTotalSales:oEaiObjRec:setFilter(oJsonfilter) 
    oTotalSales:GetTotalSales()
    Self:SetResponse(EncodeUtf8(oTotalSales:oEaiObjSnd:getJson(,.T.)))
    
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} Canceled
Método que ira buscar e retornar Totais das Vendas Canceladas

@param Fields, Page,PageSize,Order

@return Vazio

@author Everson S P Junior
@since 28/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET canceled QUERYPARAM Fields, Page,PageSize,Order WSREST TotalSales
Local oTotalSales   as OBJECT
Local nX			as INTEGER
Local cTODATE		as CHARACTER
Local cFROMDATE		as CHARACTER

    oTotalSales := TotalSales():new()
    oTotalSales:oEaiObjRec := fwEaiObj():new()
    oJsonfilter := &('JsonObject():New()')    
    oTotalSales:oEaiObjRec:setRestMethod('GET')
    
    if !empty(self:Page)
        oTotalSales:oEaiObjRec:setPage(self:Page)
    Else
        oTotalSales:oEaiObjRec:setPage(1)
    endIf

    if !empty(Self:PageSize)
        oTotalSales:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oTotalSales:oEaiObjRec:setPageSize(10)
    endIf

    If !empty(Self:Order)
        oTotalSales:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
      oTotalSales:oFields := Self:Fields
    endIf
    for nX := 1 to len(self:aQueryString)
        If !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
        	UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
        	UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
            UPPER(self:aQueryString[nX][1]) == 'FIELDS')     	        
        		If UPPER(self:aQueryString[nX][1]) == 'FROMDATE'
        			cFROMDATE:= Self:aQueryString[nX][2]
        			If At("T",cFROMDATE) > 0 //Sepera data e horario
        				cFROMDATE := Substr(cFROMDATE, 1, At("T", cFROMDATE) - 1)
        				cFROMDATE := AllTrim(StrTran(cFROMDATE, "-", ""))
        			EndIf	
        			oJsonfilter["FROMDATE"] := cFROMDATE
        		ElseIf UPPER(self:aQueryString[nX][1]) == 'TODATE'
        			cTODATE := self:aQueryString[nX][2]
        			If At("T",cTODATE) > 0 //Sepera data e horario
        				cTODATE := Substr(cTODATE, 1, At("T", cTODATE) - 1)
        				cTODATE := AllTrim(StrTran(cTODATE, "-", ""))
        			EndIf
        			oJsonfilter["TODATE"] 	:= cTODATE
        		ElseIf UPPER(self:aQueryString[nX][1]) == 'BRANCHES'
        			oJsonfilter["BRANCHES"] := Upper(self:aQueryString[nX][2])
        		EndIf	
        EndIf
    next nX    
    oTotalSales:oEaiObjRec:activate()
    oTotalSales:oEaiObjRec:setFilter(oJsonfilter) 
    oTotalSales:GetCanceledSales()
    Self:SetResponse(EncodeUtf8(oTotalSales:oEaiObjSnd:getJson(,.T.)))
    
Return .T.