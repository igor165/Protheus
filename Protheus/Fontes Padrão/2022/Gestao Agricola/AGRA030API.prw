#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL AGRA030API DESCRIPTION ('Endpoint de cadastro de tipo de desconto da classificação de grãos');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET GrainQualityTestKinds;
	DESCRIPTION ("Retorna informações dos tipos de desconto da classificação de grãos cadastradas.");
	PATH "/api/agr/v1/GrainQualityTestKinds" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_GrainQualityTestKind;
	DESCRIPTION ("Retorna informações do tipo de desconto da classificação solicitado.");
	PATH "/api/agr/v1/GrainQualityTestKinds/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST GrainQualityTestKinds;
	DESCRIPTION ("Inclui um novo tipo de desconto da classificação.");
	PATH "/api/agr/v1/GrainQualityTestKinds" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT GrainQualityTestKinds;
	DESCRIPTION ("Altera um novo tipo de desconto da classificação.");
	PATH "/api/agr/v1/GrainQualityTestKinds/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE GrainQualityTestKinds;
	DESCRIPTION ("Exclui um novo tipo de desconto da classificação.");
	PATH "/api/agr/v1/GrainQualityTestKinds/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET GrainQualityTestKinds QUERYPARAM Page,PageSize,Order,Fields  WSREST AGRA030API
	Local lRet    					as LOGICAL
	Local oFWGrainQualityTestKind 	as OBJECT
	Local oJsonfilter   			as OBJECT
	Local aQryParam					as ARRAY
	Local nX						as NUMERIC
	
	aQryParam 	:= {}	
	lRet 		:= .T. 
	
	oFWGrainQualityTestKind := FWGrainQualityTestKindsAdapter():new()
	oFWGrainQualityTestKind:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWGrainQualityTestKind:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWGrainQualityTestKind:oEaiObjRec:setPage(self:Page)
    Else
        oFWGrainQualityTestKind:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWGrainQualityTestKind:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWGrainQualityTestKind:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWGrainQualityTestKind:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWGrainQualityTestKind:cSelectedFields := Self:Fields
    endIf
    
    oFWGrainQualityTestKind:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWGrainQualityTestKind:oEaiObjRec:Activate()
    
    oFWGrainQualityTestKind:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWGrainQualityTestKind:lApi := .T.
	oFWGrainQualityTestKind:GetGrainQualityTestKinds()
	
	if oFWGrainQualityTestKind:lOk
		if oFWGrainQualityTestKind:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWGrainQualityTestKind:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWGrainQualityTestKind:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWGrainQualityTestKind:cError ))
        lRet := .F.
    EndIf
	
Return lRet


WSMETHOD GET ID_GrainQualityTestKind QUERYPARAM Fields PATHPARAM InternalId WSREST AGRA030API
	Local lRet 						as LOGICAL
	Local oFWGrainQualityTestKind  	as OBJECT
	Local oJsonfilter   			as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWGrainQualityTestKind := FWGrainQualityTestKindsAdapter():new()
    oFWGrainQualityTestKind:oEaiObjRec  := fwEaiObj():new()
    
    oFWGrainQualityTestKind:oEaiObjRec:setRestMethod('GET')  
    
    If !empty(Self:Fields)
        oFWGrainQualityTestKind:cSelectedFields := Self:Fields
    endIf
    
    oFWGrainQualityTestKind:oEaiObjRec:activate()    
    
    oFWGrainQualityTestKind:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWGrainQualityTestKind:cTipRet := '2' //Tipo de retorno Não array
       
    oFWGrainQualityTestKind:lApi := .T.
    oFWGrainQualityTestKind:GetGrainQualityTestKinds()
    
    if oFWGrainQualityTestKind:lOk
    	lRet := oFWGrainQualityTestKind:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWGrainQualityTestKind:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWGrainQualityTestKind:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWGrainQualityTestKind:cError ))
        lRet := .F.
    EndIf

Return lRet


WSMETHOD POST GrainQualityTestKinds WSREST AGRA030API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	Local oRequest 	as OBJECT
	
	cBody     := ::GetContent()
	
    oFWGrainQualityTestKind := FWGrainQualityTestKindsAdapter():new()
    oFWGrainQualityTestKind:oEaiObjRec := fwEaiObj():new()
    
    oFWGrainQualityTestKind:oEaiObjRec:setRestMethod('POST')
    
    oFWGrainQualityTestKind:oEaiObjRec:activate()

    oFWGrainQualityTestKind:oEaiObjRec:loadJson(cBody)
    
    oFWGrainQualityTestKind:cTipRet := '2' //Tipo de retorno Não array

    oFWGrainQualityTestKind:lApi := .T.
    cCodId := oFWGrainQualityTestKind:IncludeGrainQualityTestKind()

    If oFWGrainQualityTestKind:lOk
        lRet := .T.
        
        //Realizando o GET da UBA incluida para gerar a resposta
        oFWGrainQualityTestKind:GetGrainQualityTestKinds(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWGrainQualityTestKind:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWGrainQualityTestKind:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWGrainQualityTestKind:cError))
    EndIf

Return lRet


WSMETHOD PUT GrainQualityTestKinds PATHPARAM InternalId WSREST AGRA030API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	Local oRequest 	as OBJECT
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWGrainQualityTestKind := FWGrainQualityTestKindsAdapter():new()
    oFWGrainQualityTestKind:oEaiObjRec := fwEaiObj():new()
    
    oFWGrainQualityTestKind:oEaiObjRec:setRestMethod('PUT')    
    oFWGrainQualityTestKind:oEaiObjRec:activate()
    
    oFWGrainQualityTestKind:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWGrainQualityTestKind:oEaiObjRec:loadJson(cBody)
    
    oFWGrainQualityTestKind:cTipRet := '2' //Tipo de retorno Não array

    oFWGrainQualityTestKind:lApi := .T.
    cCodId := oFWGrainQualityTestKind:AlteraGrainQualityTestKind()

    If oFWGrainQualityTestKind:lOk
        lRet := .T.
		//Realizando o GET da UBA incluida para gerar a resposta
		oFWGrainQualityTestKind:getGrainQualityTestKinds(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWGrainQualityTestKind:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWGrainQualityTestKind:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWGrainQualityTestKind:cError))
    EndIf

Return lRet


WSMETHOD DELETE GrainQualityTestKinds PATHPARAM InternalId WSREST AGRA030API
	Local lRet						as LOGICAL
	Local cBody						as CHARACTER
	Local oFWGrainQualityTestKind	as OBJECT
	
	lRet := .T.
	
    oFWGrainQualityTestKind := FWGrainQualityTestKindsAdapter():new()
    oFWGrainQualityTestKind:oEaiObjRec := fwEaiObj():new()
 
    oFWGrainQualityTestKind:oEaiObjRec:setRestMethod('DELETE')
    oFWGrainQualityTestKind:oEaiObjRec:activate()
    
    oFWGrainQualityTestKind:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    
    oFWGrainQualityTestKind:cTipRet := '2' //Tipo de retorno Não array

    oFWGrainQualityTestKind:lApi := .T.
    oFWGrainQualityTestKind:getGrainQualityTestKinds()
    oFWGrainQualityTestKind:DeleteGrainQualityTestKind()
    If oFWGrainQualityTestKind:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWGrainQualityTestKind:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWGrainQualityTestKind:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWGrainQualityTestKind:cError))
    EndIf

Return lRet