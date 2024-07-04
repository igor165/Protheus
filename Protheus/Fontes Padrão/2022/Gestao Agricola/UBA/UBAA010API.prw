#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL UBAA010API DESCRIPTION ('Endpoint de cadastro de esteiras');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET Treadmills;
	DESCRIPTION ("Retorna informações das esteiras cadastradas.");
	PATH "/api/agr/v1/Treadmills" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_Treadmills;
	DESCRIPTION ("Retorna informações da esteira solicitado.");
	PATH "/api/agr/v1/Treadmills/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST Treadmills;
	DESCRIPTION ("Inclui uma nova esteira.");
	PATH "/api/agr/v1/Treadmills" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT Treadmills;
	DESCRIPTION ("Altera uma esteira.");
	PATH "/api/agr/v1/Treadmills/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE Treadmills;
	DESCRIPTION ("Exclui uma esteira.");
	PATH "/api/agr/v1/Treadmills/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET Treadmills QUERYPARAM Page,PageSize,Order,Fields  WSREST UBAA010API
	Local lRet    		as LOGICAL
	Local oFWTreadmill as OBJECT
	Local oJsonfilter   as OBJECT
	Local aQryParam		as ARRAY
	Local nX			as NUMERIC
	
	aQryParam 	:= {}	
	lRet 		:= .T. 
	
	oFWTreadmill := FWTreadmillsAdapter():new()
	oFWTreadmill:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWTreadmill:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWTreadmill:oEaiObjRec:setPage(self:Page)
    Else
        oFWTreadmill:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWTreadmill:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWTreadmill:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWTreadmill:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWTreadmill:cSelectedFields := Self:Fields
    endIf

    oFWTreadmill:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWTreadmill:oEaiObjRec:Activate()
    
    oFWTreadmill:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWTreadmill:lApi := .T.
	oFWTreadmill:GetTreadmills()
	
	if oFWTreadmill:lOk
        if oFWTreadmill:cTipRet = '1'
            ::SetResponse(EncodeUtf8(oFWTreadmill:oEaiObjSnd:GetJson(,.T.)))
        else
            ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWTreadmill:oEaiObjSn2, .F., .F., .T.)))
        endif 
    Else
        SetRestFault(400,EncodeUtf8( oFWTreadmill:cError ))
        lRet := .F.
    EndIf
	
Return lRet


WSMETHOD GET ID_Treadmills QUERYPARAM Fields PATHPARAM InternalId WSREST UBAA010API
	Local lRet 			as LOGICAL
	Local oFWTreadmill  as OBJECT
	Local oJsonfilter   as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWTreadmill := FWTreadmillsAdapter():new()
    oFWTreadmill:oEaiObjRec  := fwEaiObj():new()
    
    oFWTreadmill:oEaiObjRec:setRestMethod('GET')  
    
    If !empty(Self:Fields)
        oFWTreadmill:cSelectedFields := Self:Fields
    endIf
      
    oFWTreadmill:oEaiObjRec:activate()    
    
    oFWTreadmill:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 

    oFWTreadmill:cTipRet := '2' //Tipo de retorno não array
       
    oFWTreadmill:lApi := .T.
    oFWTreadmill:GetTreadmills()
    
    if oFWTreadmill:lOk
    	lRet := oFWTreadmill:lOk
    
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWTreadmill:oEaiObjSn2, .F., .F., .T.)))
        // ::SetResponse(EncodeUtf8(oFWTreadmill:oEaiObjSnd:GetJson(,.T.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWTreadmill:cError ))
        lRet := .F.
    EndIf

Return lRet


WSMETHOD POST Treadmills WSREST UBAA010API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER

	cBody     := ::GetContent()
	
    oFWTreadmill := FWTreadmillsAdapter():new()
    oFWTreadmill:oEaiObjRec := fwEaiObj():new()
    
    oFWTreadmill:oEaiObjRec:setRestMethod('POST')
    
    oFWTreadmill:oEaiObjRec:activate()

    oFWTreadmill:oEaiObjRec:loadJson(cBody)

    oFWTreadmill:lApi := .T.
    cCodId := oFWTreadmill:IncludeTreadmill()

    If oFWTreadmill:lOk
        lRet := .T.
        
        //Realizando o GET da esteira incluida para gerar a resposta
        oFWTreadmill:GetTreadmills(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWTreadmill:oEaiObjSn2, .F., .F., .T.)))
        // ::SetResponse(EncodeUtf8(oFWTreadmill:oEaiObjSnd:getJson(,.T.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWTreadmill:cError))
    EndIf

Return lRet


WSMETHOD PUT Treadmills PATHPARAM InternalId WSREST UBAA010API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWTreadmill := FWTreadmillsAdapter():new()
    oFWTreadmill:oEaiObjRec := fwEaiObj():new()
    
    oFWTreadmill:oEaiObjRec:setRestMethod('PUT')    
    oFWTreadmill:oEaiObjRec:activate()
    
    oFWTreadmill:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWTreadmill:oEaiObjRec:loadJson(cBody)

    oFWTreadmill:lApi := .T.
    cCodId := oFWTreadmill:AlteraTreadmill()

    If oFWTreadmill:lOk
        lRet := .T.

		//Realizando o GET da esteira incluida para gerar a resposta
		oFWTreadmill:getTreadmills(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWTreadmill:oEaiObjSn2, .F., .F., .T.)))
		// ::SetResponse(EncodeUtf8(oFWTreadmill:oEaiObjSnd:getJson(,.T.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWTreadmill:cError))
    EndIf

Return lRet


WSMETHOD DELETE Treadmills PATHPARAM InternalId WSREST UBAA010API
	Local lRet			as LOGICAL
	Local oFWTreadmill	as OBJECT
	
	lRet := .T.
	
    oFWTreadmill := FWTreadmillsAdapter():new()
    oFWTreadmill:oEaiObjRec := fwEaiObj():new()
 
    oFWTreadmill:oEaiObjRec:setRestMethod('DELETE')
    oFWTreadmill:oEaiObjRec:activate()
    
    oFWTreadmill:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)

    oFWTreadmill:lApi := .T.
    oFWTreadmill:getTreadmills()
    oFWTreadmill:DeleteTreadmill()
    If oFWTreadmill:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWTreadmill:oEaiObjSn2, .F., .F., .T.)))
		// ::SetResponse(EncodeUtf8(oFWTreadmill:oEaiObjSnd:getJson(,.T.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWTreadmill:cError))
    EndIf

Return lRet