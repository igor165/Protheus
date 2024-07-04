#INCLUDE 'Protheus.ch'
#INCLUDE 'RestFul.ch' 
 
WSRESTFUL TotalOutputDocument DESCRIPTION ("Api de retorna Quantidade e Valor de Venda do varejo no sistema Protheus.");
FORMAT "application/json,text/html" 

WSDATA Page       		AS INTEGER 	    OPTIONAL
WSDATA PageSize    		AS INTEGER		OPTIONAL
WSDATA FIELDS           AS OBJECT       OPTIONAL
WSDATA Branches         AS CHARACTER    OPTIONAL
WSDATA Order    		AS CHARACTER   	OPTIONAL

WSMETHOD GET totalOutputDocument;
DESCRIPTION ("Retorna informações das vendas no Protheus.");
PATH "api/retail/v1/totalOutputDocument" ;
PRODUCES APPLICATION_JSON RESPONSE EaiObj

WSMETHOD GET canceled;
DESCRIPTION ("Retorna informações das vendas no Protheus.");
PATH "api/retail/v1/totalOutputDocument/canceled" ;
PRODUCES APPLICATION_JSON RESPONSE EaiObj

END WSRESTFUL
//-------------------------------------------------------------------
/*/{Protheus.doc} outputDocument
Método que ira buscar e retornar Totais das Vendas

@param Fields, Page,PageSize,Order

@return Vazio

@author Everson S P Junior
@since 28/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------

WSMETHOD GET totalOutputDocument QUERYPARAM Fields, Page,PageSize,Order WSREST TotalOutputDocument
Local oOutputDocument   as OBJECT
Local nX			as INTEGER
Local cTODATE		as CHARACTER
Local cFROMDATE		as CHARACTER

    oOutputDocument := TotalOutputDocument():new()
    oOutputDocument:oEaiObjRec := fwEaiObj():new()
    oJsonfilter := &('JsonObject():New()')    
    oOutputDocument:oEaiObjRec:setRestMethod('GET')
    
    if !empty(self:Page)
        oOutputDocument:oEaiObjRec:setPage(self:Page)
    Else
        oOutputDocument:oEaiObjRec:setPage(1)
    endIf

    if !empty(Self:PageSize)
        oOutputDocument:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oOutputDocument:oEaiObjRec:setPageSize(10)
    endIf

    If !empty(Self:Order)
        oOutputDocument:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
      oOutputDocument:oFields := Self:Fields
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
    oOutputDocument:oEaiObjRec:activate()
    oOutputDocument:oEaiObjRec:setFilter(oJsonfilter) 
    oOutputDocument:GetoutputDocument()
    Self:SetResponse(EncodeUtf8(oOutputDocument:oEaiObjSnd:getJson(,.T.)))
    
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} canceled
Método que ira buscar e retornar Totais das Vendas Canceladas

@param Fields, Page,PageSize,Order

@return Vazio

@author Everson S P Junior
@since 28/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET canceled QUERYPARAM Fields, Page,PageSize,Order WSREST TotalOutputDocument
Local oOutputDocument   as OBJECT
Local nX			as INTEGER
Local cTODATE		as CHARACTER
Local cFROMDATE		as CHARACTER

    oOutputDocument := TotalOutputDocument():new()
    oOutputDocument:oEaiObjRec := fwEaiObj():new()
    oJsonfilter := &('JsonObject():New()')    
    oOutputDocument:oEaiObjRec:setRestMethod('GET')
    
    if !empty(self:Page)
        oOutputDocument:oEaiObjRec:setPage(self:Page)
    Else
        oOutputDocument:oEaiObjRec:setPage(1)
    endIf

    if !empty(Self:PageSize)
        oOutputDocument:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oOutputDocument:oEaiObjRec:setPageSize(10)
    endIf

    If !empty(Self:Order)
        oOutputDocument:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
      oOutputDocument:oFields := Self:Fields
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
    oOutputDocument:oEaiObjRec:activate()
    oOutputDocument:oEaiObjRec:setFilter(oJsonfilter) 
    oOutputDocument:GetcanceledOutputDocument()
    Self:SetResponse(EncodeUtf8(oOutputDocument:oEaiObjSnd:getJson(,.T.)))
    
Return .T.



