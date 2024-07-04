#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL UBAA050API DESCRIPTION ('Endpoint de lançamento de contaminantes para algodao');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET CottonPoisoningPointings;
	DESCRIPTION ("Retorna informações dos lançamento de contaminantes para algodao cadastradaos.");
	PATH "/api/agr/v1/CottonPoisoningPointings" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_CottonPoisoningPointings;
	DESCRIPTION ("Retorna informações da lançamento de contaminantes para algodao solicitado.");
	PATH "/api/agr/v1/CottonPoisoningPointings/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST CottonPoisoningPointings;
	DESCRIPTION ("Inclui um novo lançamento de contaminantes para algodao.");
	PATH "/api/agr/v1/CottonPoisoningPointings" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT CottonPoisoningPointings;
	DESCRIPTION ("Altera um lançamento de contaminantes para algodao.");
	PATH "/api/agr/v1/CottonPoisoningPointings/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE CottonPoisoningPointings;
	DESCRIPTION ("Exclui um lançamento de contaminantes para algodao.");
	PATH "/api/agr/v1/CottonPoisoningPointings/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET CottonPoisoningPointings QUERYPARAM Page,PageSize,Order,Fields  WSREST UBAA050API
	Local lRet    						as LOGICAL
	Local oFWCottonPoisoningPointing 	as OBJECT
	Local oJsonfilter   				as OBJECT
	Local nX							as NUMERIC
	
	lRet 		:= .T. 
	
	oFWCottonPoisoningPointing := FWCottonPoisoningPointingsAdapter():new()
	oFWCottonPoisoningPointing:oEaiObjRec := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWCottonPoisoningPointing:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWCottonPoisoningPointing:oEaiObjRec:setPage(self:Page)
    Else
        oFWCottonPoisoningPointing:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWCottonPoisoningPointing:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWCottonPoisoningPointing:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWCottonPoisoningPointing:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWCottonPoisoningPointing:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonPoisoningPointing:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWCottonPoisoningPointing:oEaiObjRec:Activate()
    
    oFWCottonPoisoningPointing:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWCottonPoisoningPointing:lApi := .T.
	oFWCottonPoisoningPointing:GetCottonPoisoningPointings()
	
	if oFWCottonPoisoningPointing:lOk
		if oFWCottonPoisoningPointing:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWCottonPoisoningPointing:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonPoisoningPointing:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonPoisoningPointing:cError ))
        lRet := .F.
    EndIf
	
Return lRet


WSMETHOD GET ID_CottonPoisoningPointings QUERYPARAM Fields PATHPARAM InternalId WSREST UBAA050API
	Local lRet 							as LOGICAL
	Local oFWCottonPoisoningPointing  	as OBJECT
	Local oJsonfilter   				as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWCottonPoisoningPointing := FWCottonPoisoningPointingsAdapter():new()
    oFWCottonPoisoningPointing:oEaiObjRec  := fwEaiObj():new()
    
    oFWCottonPoisoningPointing:oEaiObjRec:setRestMethod('GET')  
    
    If !empty(Self:Fields)
        oFWCottonPoisoningPointing:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonPoisoningPointing:oEaiObjRec:activate()    
    
    oFWCottonPoisoningPointing:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWCottonPoisoningPointing:cTipRet := '2' //Tipo de retorno Não array
       
    oFWCottonPoisoningPointing:lApi := .T.
    oFWCottonPoisoningPointing:GetCottonPoisoningPointings()
    
    if oFWCottonPoisoningPointing:lOk
    	lRet := oFWCottonPoisoningPointing:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonPoisoningPointing:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonPoisoningPointing:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonPoisoningPointing:cError ))
        lRet := .F.
    EndIf

Return lRet


WSMETHOD POST CottonPoisoningPointings WSREST UBAA050API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody     := ::GetContent()
	
    oFWCottonPoisoningPointing := FWCottonPoisoningPointingsAdapter():new()
    oFWCottonPoisoningPointing:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonPoisoningPointing:oEaiObjRec:setRestMethod('POST')
    
    oFWCottonPoisoningPointing:oEaiObjRec:activate()

    oFWCottonPoisoningPointing:oEaiObjRec:loadJson(cBody)
    
    oFWCottonPoisoningPointing:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonPoisoningPointing:lApi := .T.
    cCodId := oFWCottonPoisoningPointing:IncludeCottonPoisoningPointing()

    If oFWCottonPoisoningPointing:lOk
        lRet := .T.
        
        //Realizando o GET do lancamento incluido para gerar a resposta
        oFWCottonPoisoningPointing:GetCottonPoisoningPointings(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonPoisoningPointing:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonPoisoningPointing:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonPoisoningPointing:cError))
    EndIf

Return lRet


WSMETHOD PUT CottonPoisoningPointings PATHPARAM InternalId WSREST UBAA050API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWCottonPoisoningPointing := FWCottonPoisoningPointingsAdapter():new()
    oFWCottonPoisoningPointing:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonPoisoningPointing:oEaiObjRec:setRestMethod('PUT')    
    oFWCottonPoisoningPointing:oEaiObjRec:activate()
    
    oFWCottonPoisoningPointing:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWCottonPoisoningPointing:oEaiObjRec:loadJson(cBody)
    
    oFWCottonPoisoningPointing:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonPoisoningPointing:lApi := .T.
    cCodId := oFWCottonPoisoningPointing:AlteraCottonPoisoningPointing()

    If oFWCottonPoisoningPointing:lOk
        lRet := .T.
		//Realizando o GET do lancamento incluido para gerar a resposta
		oFWCottonPoisoningPointing:getCottonPoisoningPointings(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonPoisoningPointing:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonPoisoningPointing:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonPoisoningPointing:cError))
    EndIf

Return lRet


WSMETHOD DELETE CottonPoisoningPointings PATHPARAM InternalId WSREST UBAA050API
	Local lRet							as LOGICAL
	Local oFWCottonPoisoningPointing	as OBJECT
	
	lRet := .T.
	
    oFWCottonPoisoningPointing := FWCottonPoisoningPointingsAdapter():new()
    oFWCottonPoisoningPointing:oEaiObjRec := fwEaiObj():new()
 
    oFWCottonPoisoningPointing:oEaiObjRec:setRestMethod('DELETE')
    oFWCottonPoisoningPointing:oEaiObjRec:activate()
    
    oFWCottonPoisoningPointing:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    
    oFWCottonPoisoningPointing:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonPoisoningPointing:lApi := .T.
    oFWCottonPoisoningPointing:getCottonPoisoningPointings()
    oFWCottonPoisoningPointing:DeleteCottonPoisoningPointing()
    If oFWCottonPoisoningPointing:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonPoisoningPointing:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonPoisoningPointing:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonPoisoningPointing:cError))
    EndIf

Return lRet