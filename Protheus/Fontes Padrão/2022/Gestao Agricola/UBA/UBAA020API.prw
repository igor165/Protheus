#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL UBAA020API DESCRIPTION ('Endpoint de cadastro de Vínculo Esteira x Fardão.');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET CottonBalesOnTreadmills;
	DESCRIPTION ("Retorna informações de fardões vinculados à esteiras.");
	PATH "/api/agr/v1/CottonBalesOnTreadmills" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_CottonBalesOnTreadmills;
	DESCRIPTION ("Retorna informações do vínculo do fardão solicitado.");
	PATH "/api/agr/v1/CottonBalesOnTreadmills/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST CottonBalesOnTreadmills;
	DESCRIPTION ("Método não dísponível.");
	PATH "/api/agr/v1/CottonBalesOnTreadmills";
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
	WSMETHOD PUT CottonBalesOnTreadmills;
	DESCRIPTION ("Altera um vínculo do fardão solicitado.");
	PATH "/api/agr/v1/CottonBalesOnTreadmills/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE CottonBalesOnTreadmills;
	DESCRIPTION ("Exclui o vínculo do fardão solicitado.");
	PATH "/api/agr/v1/CottonBalesOnTreadmills/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL

WSMETHOD GET CottonBalesOnTreadmills QUERYPARAM Page,PageSize,Order,Fields  WSREST  UBAA020API
	Local lRet    					as LOGICAL
	Local oFWCottonBalesOnTreadmill as OBJECT
	Local oJsonfilter   			as OBJECT
	Local nX						as NUMERIC
	
	lRet := .T. 
	
	oFWCottonBalesOnTreadmill := FWCottonBalesOnTreadmillsAdapter():new()
	oFWCottonBalesOnTreadmill:oEaiObjRec := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWCottonBalesOnTreadmill:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWCottonBalesOnTreadmill:oEaiObjRec:setPage(self:Page)
    Else
        oFWCottonBalesOnTreadmill:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWCottonBalesOnTreadmill:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWCottonBalesOnTreadmill:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWCottonBalesOnTreadmill:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWCottonBalesOnTreadmill:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonBalesOnTreadmill:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWCottonBalesOnTreadmill:oEaiObjRec:Activate()
    
    oFWCottonBalesOnTreadmill:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWCottonBalesOnTreadmill:lApi := .T.
	oFWCottonBalesOnTreadmill:GetCottonBalesOnTreadmills()
	
	if oFWCottonBalesOnTreadmill:lOk
		if oFWCottonBalesOnTreadmill:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWCottonBalesOnTreadmill:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonBalesOnTreadmill:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonBalesOnTreadmill:cError ))
        lRet := .F.
    EndIf
	
Return lRet


WSMETHOD GET ID_CottonBalesOnTreadmills QUERYPARAM Fields PATHPARAM InternalId WSREST  UBAA020API
	Local lRet 						as LOGICAL
	Local oFWCottonBalesOnTreadmill as OBJECT
	Local oJsonfilter   			as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWCottonBalesOnTreadmill := FWCottonBalesOnTreadmillsAdapter():new()
    oFWCottonBalesOnTreadmill:oEaiObjRec  := fwEaiObj():new()
    
    oFWCottonBalesOnTreadmill:oEaiObjRec:setRestMethod('GET')  
    
    If !empty(Self:Fields)
        oFWCottonBalesOnTreadmill:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonBalesOnTreadmill:oEaiObjRec:activate()    
    
    oFWCottonBalesOnTreadmill:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWCottonBalesOnTreadmill:cTipRet := '2' //Tipo de retorno Não array
       
    oFWCottonBalesOnTreadmill:lApi := .T.
    oFWCottonBalesOnTreadmill:GetCottonBalesOnTreadmills()
    
    if oFWCottonBalesOnTreadmill:lOk
    	lRet := oFWCottonBalesOnTreadmill:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonBalesOnTreadmill:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonBalesOnTreadmill:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonBalesOnTreadmill:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD POST CottonBalesOnTreadmills WSREST UBAA020API
	Local lRet as LOGICAL

	lRet := .F.
	SetRestFault(405,"Nao disponivel.")
Return lRet


WSMETHOD PUT CottonBalesOnTreadmills PATHPARAM InternalId WSREST  UBAA020API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWCottonBalesOnTreadmill := FWCottonBalesOnTreadmillsAdapter():new()
    oFWCottonBalesOnTreadmill:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonBalesOnTreadmill:oEaiObjRec:setRestMethod('PUT')    
    oFWCottonBalesOnTreadmill:oEaiObjRec:activate()
    
    oFWCottonBalesOnTreadmill:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWCottonBalesOnTreadmill:oEaiObjRec:loadJson(cBody)
    
    oFWCottonBalesOnTreadmill:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonBalesOnTreadmill:lApi := .T.
    cCodId := oFWCottonBalesOnTreadmill:AlteraCottonBalesOnTreadmill()

    If oFWCottonBalesOnTreadmill:lOk
        lRet := .T.
		//Realizando o GET da UBA incluida para gerar a resposta
		oFWCottonBalesOnTreadmill:getCottonBalesOnTreadmills(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonBalesOnTreadmill:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonBalesOnTreadmill:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonBalesOnTreadmill:cError))
    EndIf

Return lRet


WSMETHOD DELETE CottonBalesOnTreadmills PATHPARAM InternalId WSREST UBAA020API
	Local lRet						as LOGICAL
	Local oFWCottonBalesOnTreadmill	as OBJECT
	
	lRet := .T.
	
    oFWCottonBalesOnTreadmill := FWCottonBalesOnTreadmillsAdapter():new()
    oFWCottonBalesOnTreadmill:oEaiObjRec := FWEaiObj():new()
 
    oFWCottonBalesOnTreadmill:oEaiObjRec:setRestMethod('DELETE')
    oFWCottonBalesOnTreadmill:oEaiObjRec:activate()
    
    oFWCottonBalesOnTreadmill:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    
    oFWCottonBalesOnTreadmill:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonBalesOnTreadmill:lApi := .T.
    oFWCottonBalesOnTreadmill:getCottonBalesOnTreadmills()
    oFWCottonBalesOnTreadmill:DeleteCottonBalesOnTreadmill()
    If oFWCottonBalesOnTreadmill:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonBalesOnTreadmill:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonBalesOnTreadmill:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonBalesOnTreadmill:cError))
    EndIf

Return lRet