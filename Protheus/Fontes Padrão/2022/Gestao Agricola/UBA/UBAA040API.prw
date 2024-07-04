#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL UBAA040API DESCRIPTION ('Endpoint de cadastro de contaminantes');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET Contaminants;
	DESCRIPTION ("Retorna informações dos contaminantes cadastrados.");
	PATH "/api/agr/v1/Contaminants" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_Contaminants;
	DESCRIPTION ("Retorna informações do contaminante solicitado.");
	PATH "/api/agr/v1/Contaminants/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST Contaminants;
	DESCRIPTION ("Inclui um novo contaminante.");
	PATH "/api/agr/v1/Contaminants" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT Contaminants;
	DESCRIPTION ("Altera um contaminante.");
	PATH "/api/agr/v1/Contaminants/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE Contaminants;
	DESCRIPTION ("Exclui um contaminante.");
	PATH "/api/agr/v1/Contaminants/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET Contaminants QUERYPARAM Page,PageSize,Order,Fields  WSREST UBAA040API
	Local lRet    		as LOGICAL
	Local oFWContaminant  as OBJECT
	Local oJsonfilter   as OBJECT
	Local aQryParam		as ARRAY
	Local nX			as NUMERIC
	
	aQryParam 	:= {}	
	lRet 		:= .T. 
	
	oFWContaminant := FWContaminantsAdapter():new()
	oFWContaminant:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWContaminant:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWContaminant:oEaiObjRec:setPage(self:Page)
    Else
        oFWContaminant:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWContaminant:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWContaminant:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWContaminant:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWContaminant:cSelectedFields := Self:Fields
    endIf
    
    oFWContaminant:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWContaminant:oEaiObjRec:Activate()
    
    oFWContaminant:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWContaminant:lApi := .T.
	oFWContaminant:GetContaminants()
	
	if oFWContaminant:lOk
		if oFWContaminant:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWContaminant:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWContaminant:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWContaminant:cError ))
        lRet := .F.
    EndIf
	
Return lRet


WSMETHOD GET ID_Contaminants QUERYPARAM Fields PATHPARAM InternalId WSREST UBAA040API
	Local lRet 			  as LOGICAL
	Local oFWContaminant  as OBJECT
	Local oJsonfilter     as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWContaminant := FWContaminantsAdapter():new()
    oFWContaminant:oEaiObjRec  := fwEaiObj():new()
    
    oFWContaminant:oEaiObjRec:setRestMethod('GET')  
    
    If !empty(Self:Fields)
        oFWContaminant:cSelectedFields := Self:Fields
    endIf
    
    oFWContaminant:oEaiObjRec:activate()    
    
    oFWContaminant:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWContaminant:cTipRet := '2' //Tipo de retorno Não array
       
    oFWContaminant:lApi := .T.
    oFWContaminant:GetContaminants()
    
    if oFWContaminant:lOk
    	lRet := oFWContaminant:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWContaminant:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWContaminant:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWContaminant:cError ))
        lRet := .F.
    EndIf

Return lRet


WSMETHOD POST Contaminants WSREST UBAA040API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody := ::GetContent()
	
    oFWContaminant := FWContaminantsAdapter():new()
    oFWContaminant:oEaiObjRec := fwEaiObj():new()
    
    oFWContaminant:oEaiObjRec:setRestMethod('POST')
    
    oFWContaminant:oEaiObjRec:activate()

    oFWContaminant:oEaiObjRec:loadJson(cBody)
    
    oFWContaminant:cTipRet := '2' //Tipo de retorno Não array

    oFWContaminant:lApi := .T.
    cCodId := oFWContaminant:IncludeContaminant()

    If oFWContaminant:lOk
        lRet := .T.
        
        //Realizando o GET da UBA incluida para gerar a resposta
        oFWContaminant:GetContaminants(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWContaminant:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWContaminant:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWContaminant:cError))
    EndIf

Return lRet


WSMETHOD PUT Contaminants PATHPARAM InternalId WSREST UBAA040API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWContaminant := FWContaminantsAdapter():new()
    oFWContaminant:oEaiObjRec := FWEaiObj():new()
    
    oFWContaminant:oEaiObjRec:setRestMethod('PUT')    
    oFWContaminant:oEaiObjRec:activate()
    
    oFWContaminant:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWContaminant:oEaiObjRec:loadJson(cBody)
    
    oFWContaminant:cTipRet := '2' //Tipo de retorno Não array

    oFWContaminant:lApi := .T.
    cCodId := oFWContaminant:AlteraContaminant()

    If oFWContaminant:lOk
        lRet := .T.
		oFWContaminant:getContaminants(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWContaminant:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWContaminant:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWContaminant:cError))
    EndIf

Return lRet


WSMETHOD DELETE Contaminants PATHPARAM InternalId WSREST UBAA040API
	Local lRet				as LOGICAL
	Local oFWContaminant	as OBJECT
	
	lRet := .T.
	
    oFWContaminant := FWContaminantsAdapter():new()
    oFWContaminant:oEaiObjRec := fwEaiObj():new()
 
    oFWContaminant:oEaiObjRec:setRestMethod('DELETE')
    oFWContaminant:oEaiObjRec:activate()
    
    oFWContaminant:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    
    oFWContaminant:cTipRet := '2' //Tipo de retorno Não array

    oFWContaminant:lApi := .T.
    oFWContaminant:getContaminants()
    oFWContaminant:DeleteContaminant()
    If oFWContaminant:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWContaminant:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWContaminant:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWContaminant:cError))
    EndIf

Return lRet