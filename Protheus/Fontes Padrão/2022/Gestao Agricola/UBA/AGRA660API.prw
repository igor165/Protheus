#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL AGRA660API DESCRIPTION ('Endpoint de cadastro de unidades de beneficiamento');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET CottonGins;
	DESCRIPTION ("Retorna informações das unidades de beneficiamento cadastradas.");
	PATH "/api/agr/v1/CottonGins" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_CottonGins;
	DESCRIPTION ("Retorna informações da unidade de beneficiamento solicitadA.");
	PATH "/api/agr/v1/CottonGins/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST CottonGins;
	DESCRIPTION ("Inclui uma nova unidade de beneficiamento.");
	PATH "/api/agr/v1/CottonGins" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT CottonGins;
	DESCRIPTION ("Altera uma unidade de beneficiamento.");
	PATH "/api/agr/v1/CottonGins/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE CottonGins;
	DESCRIPTION ("Exclui uma unidade de beneficiamento.");
	PATH "/api/agr/v1/CottonGins/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET CottonGins QUERYPARAM Page,PageSize,Order,Fields  WSREST AGRA660API
	Local lRet    		as LOGICAL
	Local oFWCottonGin as OBJECT
	Local oJsonfilter   as OBJECT
	Local aQryParam		as ARRAY
	Local nX			as NUMERIC
	
	aQryParam 	:= {}	
	lRet 		:= .T. 
	
	oFWCottonGin := FWCottonGinsAdapter():new()
	oFWCottonGin:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWCottonGin:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWCottonGin:oEaiObjRec:setPage(self:Page)
    Else
        oFWCottonGin:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWCottonGin:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWCottonGin:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWCottonGin:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWCottonGin:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonGin:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWCottonGin:oEaiObjRec:Activate()
    
    oFWCottonGin:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWCottonGin:lApi := .T.
	oFWCottonGin:GetCottonGins()
	
	if oFWCottonGin:lOk
		if oFWCottonGin:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWCottonGin:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGin:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonGin:cError ))
        lRet := .F.
    EndIf
	
Return lRet


WSMETHOD GET ID_CottonGins QUERYPARAM Fields PATHPARAM InternalId WSREST AGRA660API
	Local lRet 			as LOGICAL
	Local oFWCottonGin  as OBJECT
	Local oJsonfilter   as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWCottonGin := FWCottonGinsAdapter():new()
    oFWCottonGin:oEaiObjRec  := fwEaiObj():new()
    
    oFWCottonGin:oEaiObjRec:setRestMethod('GET')  
    
    If !empty(Self:Fields)
        oFWCottonGin:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonGin:oEaiObjRec:activate()    
    
    oFWCottonGin:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWCottonGin:cTipRet := '2' //Tipo de retorno Não array
       
    oFWCottonGin:lApi := .T.
    oFWCottonGin:GetCottonGins()
    
    if oFWCottonGin:lOk
    	lRet := oFWCottonGin:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGin:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonGin:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonGin:cError ))
        lRet := .F.
    EndIf

Return lRet


WSMETHOD POST CottonGins WSREST AGRA660API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody     := ::GetContent()
	
    oFWCottonGin := FWCottonGinsAdapter():new()
    oFWCottonGin:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonGin:oEaiObjRec:setRestMethod('POST')
    
    oFWCottonGin:oEaiObjRec:activate()

    oFWCottonGin:oEaiObjRec:loadJson(cBody)
    
    oFWCottonGin:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonGin:lApi := .T.
    cCodId := oFWCottonGin:IncludeCottonGin()

    If oFWCottonGin:lOk
        lRet := .T.
        
        //Realizando o GET da UBA incluida para gerar a resposta
        oFWCottonGin:GetCottonGins(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGin:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonGin:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGin:cError))
    EndIf

Return lRet


WSMETHOD PUT CottonGins PATHPARAM InternalId WSREST AGRA660API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWCottonGin := FWCottonGinsAdapter():new()
    oFWCottonGin:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonGin:oEaiObjRec:setRestMethod('PUT')    
    oFWCottonGin:oEaiObjRec:activate()
    
    oFWCottonGin:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWCottonGin:oEaiObjRec:loadJson(cBody)
    
    oFWCottonGin:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonGin:lApi := .T.
    cCodId := oFWCottonGin:AlteraCottonGin()

    If oFWCottonGin:lOk
        lRet := .T.
		//Realizando o GET da UBA incluida para gerar a resposta
		oFWCottonGin:getCottonGins(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGin:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonGin:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGin:cError))
    EndIf

Return lRet


WSMETHOD DELETE CottonGins PATHPARAM InternalId WSREST AGRA660API
	Local lRet			as LOGICAL
	Local oFWCottonGin	as OBJECT
	
	lRet := .T.
	
    oFWCottonGin := FWCottonGinsAdapter():new()
    oFWCottonGin:oEaiObjRec := fwEaiObj():new()
 
    oFWCottonGin:oEaiObjRec:setRestMethod('DELETE')
    oFWCottonGin:oEaiObjRec:activate()
    
    oFWCottonGin:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    
    oFWCottonGin:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonGin:lApi := .T.
    oFWCottonGin:getCottonGins()
    oFWCottonGin:DeleteCottonGin()
    If oFWCottonGin:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGin:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonGin:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGin:cError))
    EndIf

Return lRet