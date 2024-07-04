#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL OGA010API DESCRIPTION ('Endpoint de cadastro de entidades');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET Entities;
	DESCRIPTION ("Retorna informações das entidades cadastradas.");
	PATH "/api/agr/v1/Entities" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_Entities;
	DESCRIPTION ("Retorna informações da entidade solicitada.");
	PATH "/api/agr/v1/Entities/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST Entities;
	DESCRIPTION ("Inclui uma nova entidade.");
	PATH "/api/agr/v1/Entities" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT Entities;
	DESCRIPTION ("Altera uma entidade.");
	PATH "/api/agr/v1/Entities/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE Entities;
	DESCRIPTION ("Exclui uma entidade.");
	PATH "/api/agr/v1/Entities/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET Entities QUERYPARAM Page,PageSize,Order,Fields  WSREST OGA010API
	Local lRet    		as LOGICAL
	Local oFWEntity 	as OBJECT
	Local oJsonfilter   as OBJECT
	Local nX			as NUMERIC
	
	lRet 		:= .T. 
	
	oFWEntity := FWEntitiesAdapter():new()
	oFWEntity:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWEntity:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWEntity:oEaiObjRec:setPage(self:Page)
    Else
        oFWEntity:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWEntity:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWEntity:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWEntity:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWEntity:cSelectedFields := Self:Fields
    endIf
    
    oFWEntity:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWEntity:oEaiObjRec:Activate()
    
    oFWEntity:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWEntity:lApi := .T.
	oFWEntity:GetEntities()
	
	if oFWEntity:lOk
		if oFWEntity:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWEntity:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWEntity:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWEntity:cError ))
        lRet := .F.
    EndIf
	
Return lRet


WSMETHOD GET ID_Entities QUERYPARAM Fields PATHPARAM InternalId WSREST OGA010API
	Local lRet 			as LOGICAL
	Local oFWEntity  as OBJECT
	Local oJsonfilter   as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWEntity := FWEntitiesAdapter():new()
    oFWEntity:oEaiObjRec  := FWEaiObj():new()
    
    oFWEntity:oEaiObjRec:setRestMethod('GET')  
    
    If !empty(Self:Fields)
        oFWEntity:cSelectedFields := Self:Fields
    endIf
    
    oFWEntity:oEaiObjRec:activate()    
    
    oFWEntity:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWEntity:cTipRet := '2' //Tipo de retorno Não array
       
    oFWEntity:lApi := .T.
    oFWEntity:GetEntities()
    
    if oFWEntity:lOk
    	lRet := oFWEntity:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWEntity:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWEntity:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWEntity:cError ))
        lRet := .F.
    EndIf

Return lRet


WSMETHOD POST Entities WSREST OGA010API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	Local oRequest 	as OBJECT
	
	cBody     := ::GetContent()
	
    oFWEntity := FWEntitiesAdapter():new()
    oFWEntity:oEaiObjRec := FWEaiObj():new()
    
    oFWEntity:oEaiObjRec:setRestMethod('POST')
    
    oFWEntity:oEaiObjRec:activate()

    oFWEntity:oEaiObjRec:loadJson(cBody)
    
    oFWEntity:cTipRet := '2' //Tipo de retorno Não array

    oFWEntity:lApi := .T.
    cCodId := oFWEntity:IncludeEntity()

    If oFWEntity:lOk
        lRet := .T.
        
        //Realizando o GET da UBA incluida para gerar a resposta
        oFWEntity:GetEntities(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWEntity:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWEntity:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWEntity:cError))
    EndIf

Return lRet


WSMETHOD PUT Entities PATHPARAM InternalId WSREST OGA010API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	Local oRequest 	as OBJECT
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWEntity := FWEntitiesAdapter():new()
    oFWEntity:oEaiObjRec := FWEaiObj():new()
    
    oFWEntity:oEaiObjRec:setRestMethod('PUT')    
    oFWEntity:oEaiObjRec:activate()
    
    oFWEntity:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWEntity:oEaiObjRec:loadJson(cBody)
    
    oFWEntity:cTipRet := '2' //Tipo de retorno Não array

    oFWEntity:lApi := .T.
    cCodId := oFWEntity:AlteraEntity()

    If oFWEntity:lOk
        lRet := .T.
		//Realizando o GET da UBA incluida para gerar a resposta
		oFWEntity:getEntities(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWEntity:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWEntity:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWEntity:cError))
    EndIf

Return lRet


WSMETHOD DELETE Entities PATHPARAM InternalId WSREST OGA010API
	Local lRet			as LOGICAL
	Local cBody			as CHARACTER
	Local oFWEntity		as OBJECT
	
	lRet := .T.
	
    oFWEntity := FWEntitiesAdapter():new()
    oFWEntity:oEaiObjRec := FWEaiObj():new()
 
    oFWEntity:oEaiObjRec:setRestMethod('DELETE')
    oFWEntity:oEaiObjRec:activate()
    
    oFWEntity:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    
    oFWEntity:cTipRet := '2' //Tipo de retorno Não array

    oFWEntity:lApi := .T.
    oFWEntity:getEntities()
    oFWEntity:DeleteEntity()
    If oFWEntity:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWEntity:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWEntity:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWEntity:cError))
    EndIf

Return lRet