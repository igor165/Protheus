#Include 'Protheus.ch'
#INCLUDE 'RestFul.ch'

WSRESTFUL ItemReserves DESCRIPTION ("Api de reservas de produtos do varejo no sistema Protheus.");
FORMAT "application/json,text/html" 

WSDATA Internal_ID      AS CHARACTER    OPTIONAL
WSDATA Page       		AS INTEGER 	    OPTIONAL
WSDATA PageSize    		AS INTEGER		OPTIONAL
WSDATA Fields           AS OBJECT       OPTIONAL
WSDATA Order    		AS CHARACTER   	OPTIONAL

WSMETHOD GET ItemReserves;
DESCRIPTION ("Busca todas as reservas disponiveis no sistema de acordo com a quantidade especificada em 'Page' e 'PageSize'. Por default 'Page' = 1 e 'PageSize' = 10 ");
PATH "api/retail/v1/ItemReserves";
WSSYNTAX "Busca todas as reservas disponiveis no sistema Protheus";
PRODUCES APPLICATION_JSON RESPONSE EaiObj

WSMETHOD GET ID_Internal;
DESCRIPTION ("Retorna uma reserva especifica");
PATH "api/retail/v1/ItemReserves/{Internal_ID}" ;
WSSYNTAX "Retorna dados da reserva de acordo com os paramentros informados (Filial e Documento da Reserva)";
PRODUCES APPLICATION_JSON RESPONSE EaiObj

WSMETHOD POST ItemReserves;
DESCRIPTION ("Insere uma reserva de produto");
PATH "api/retail/v1/ItemReserves" ;
WSSYNTAX "Inclui ou Atualiza uma reserva.";
PRODUCES APPLICATION_JSON RESPONSE EaiObj

WSMETHOD PUT ID_Internal;
DESCRIPTION ("Atualiza uma reserva");
PATH "api/retail/v1/ItemReserves/{Internal_ID}";
WSSYNTAX "Atualiza uma reserva.";
PRODUCES APPLICATION_JSON RESPONSE EaiObj

WSMETHOD DELETE ID_Internal;
DESCRIPTION ("Deleta uma reserva");
PATH "api/retail/v1/ItemReserves/{Internal_ID}" ;
WSSYNTAX "Deleta uma reserva.";
PRODUCES APPLICATION_JSON RESPONSE EaiObj

END WSRESTFUL

WSMETHOD POST ItemReserves WSREST ItemReserves
local lRet      as LOGICAL
local cBody     as CHARACTER
    
    oReserve:= ItemReserveAdapter():new()
    oReserve:oEaiObjRec := fwEaiObj():new()
       
    cBody   := Self:GetContent() 
    oReserve:oEaiObjRec:activate()

    oReserve:oEaiObjRec:setRestMethod('POST')
    oReserve:oEaiObjRec:loadJson(cBody)
    oReserve:lApi := .T.     
    oReserve:IncludeReserve()
	If oReserve:lOk
        lRet := .T.       
        oReserve:GetItemReserve()
        Self:SetResponse(EncodeUtf8(oReserve:oEaiobjSnd:getJson(,.T.)))
    Else
    	lRet := .F.      
    	SetRestFault(400,EncodeUtf8(cValToChar( oReserve:cError)))
    EndIf
    
Return lRet



WSMETHOD GET ID_Internal PATHPARAM Internal_ID WSREST ItemReserves
Local lRet      as LOGICAL
Local oReserve   as OBJECT

    oReserve := ItemReserveAdapter():new()
    oReserve:oEaiObjRec := fwEaiObj():new()    
    oReserve:oEaiObjRec:setRestMethod('GET')    
    oReserve:oEaiObjRec:activate()
    oReserve:oEaiObjRec:setPathParam('Internal_ID',Self:Internal_ID)    
    oReserve:lApi := .T.
    oReserve:GetItemReserves()

    If oReserve:lOk
        lRet := .T.
        Self:SetResponse(EncodeUtf8(oReserve:oEaiObjSnd:getJson(,.T.)))
    Else
        lRet := .F.
        SetRestFault(404,EncodeUtf8(oReserve:cError))
    EndIf

Return lRet

WSMETHOD GET ItemReserves QUERYPARAM Fields, Page,PageSize,Order WSREST ItemReserves
Local lRet          as LOGICAL
Local nX            as NUMERIC
Local oReserve      as OBJECT

    lRet := .T.
    oReserve := ItemReserveAdapter():new()
    oReserve:oEaiObjRec := fwEaiObj():new()
     oJsonfilter := &('JsonObject():New()')    
    oReserve:oEaiObjRec:setRestMethod('GET')
    
    if !empty(self:Page)
        oReserve:oEaiObjRec:setPage(self:Page)
    Else
        oReserve:oEaiObjRec:setPage(1)
    endIf

    if !empty(Self:PageSize)
        oReserve:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oReserve:oEaiObjRec:setPageSize(10)
    endIf    

    If !empty(Self:Order)
        oReserve:oEaiObjRec:setOrder(Self:Order)
    endIf
    
     If !empty(Self:Fields)
      oReserve:oFields := Self:Fields    
    endIf

       for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
        	UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
        	UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
            UPPER(self:aQueryString[nX][1]) == 'FIELDS')     	        
        		oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oReserve:oEaiObjRec:activate()    
    oReserve:oEaiObjRec:setFilter(oJsonfilter)    
    oReserve:lApi := .T.
    oReserve:GetItemReserves()

    if oReserve:lOk
        ::SetResponse(EncodeUtf8(oReserve:oEaiObjSnd:GetJson(,.T.)))
    Else
        SetRestFault(400,EncodeUtf8(oReserve:cError))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD PUT ID_Internal PATHPARAM Internal_ID WSREST ItemReserves
local lRet      as LOGICAL
local cBody     as CHARACTER
 
 
     
    oReserve:= ItemReserveAdapter():new()    
    oReserve:oEaiObjRec := fwEaiObj():new()
    cBody   := Self:GetContent()    
    
    oReserve:oEaiObjRec:activate()   
     oReserve:oEaiObjRec:setPathParam('Internal_ID',Self:Internal_ID)  
    oReserve:lApi := .T.    
 	oReserve:oEaiObjRec:setRestMethod('PUT')    	    
	oReserve:oEaiObjRec:loadJson(cBody)
	oReserve:UpdateReserve()       
    If oReserve:lOk
    	lRet := .T.       
    	Self:SetResponse(EncodeUtf8(oReserve:oEaiObjRec:getJson(,.T.)))
    Else
    	lRet := .F.      
    	SetRestFault(400,EncodeUtf8(cValToChar( oReserve:cError)))
	EndIf

Return lRet


WSMETHOD DELETE ID_Internal PATHPARAM Internal_ID WSREST ItemReserves
    oReserve := ItemReserveAdapter():new()
    oReserve:oEaiObjRec := fwEaiObj():new()  
    oReserve:oEaiObjRec:activate() 
    oReserve:oEaiObjRec:setPathParam('Internal_ID',Self:Internal_ID)  
    oReserve:lApi := .T.  
    oReserve:oEaiobjSnd:setRestMethod('DELETE')  	
    oReserve:DeleteReserve()
    If oReserve:lOk
     	lRet := .T.       
       	Self:SetResponse(EncodeUtf8(oReserve:oEaiObjSnd:getJson(,.T.)))
    Else
       	lRet := .F.      
       	SetRestFault(400,EncodeUtf8(cValToChar( oReserve:cError)))
    EndIf  
    
Return lRet


