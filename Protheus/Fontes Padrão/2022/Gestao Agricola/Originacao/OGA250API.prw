#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL OGA250API DESCRIPTION ('Romaneio de Entrada');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET v1;
	DESCRIPTION ("Retorna os romaneios de entrada.");
	PATH "/api/oga/v1/PackingSlipEntry" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET v1_ID;
	DESCRIPTION ("Retorna apenas um romaneio de entrada.");
	PATH "/api/oga/v1/PackingSlipEntry/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj	
	
	WSMETHOD POST v1;
	DESCRIPTION ("Inclui um novo romaneio de entrada.");
	PATH "/api/oga/v1/PackingSlipEntry" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	/*WSMETHOD PUT v1;
	DESCRIPTION ("Altera ...");
	PATH "/api/oga/v1/PackingSlipEntry/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj */
	
//  WSMETHOD DELETE v1;
//	DESCRIPTION ("Exclui ...");
//	PATH "/api/oga/v1/PackingSlipEntry/{InternalId}" ;
//	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET v1 QUERYPARAM Page,PageSize,Order,Fields  WSREST OGA250API
	Local lRet    				as LOGICAL
	Local oFWPackingSlipEntry 	as OBJECT
	Local oJsonfilter   		as OBJECT
	Local nX					as NUMERIC
	
	lRet 		:= .T. 

	oFWPackingSlipEntry := FWPackingSlipEntryAdapter():new()
	oFWPackingSlipEntry:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWPackingSlipEntry:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWPackingSlipEntry:oEaiObjRec:setPage(self:Page)
    Else
        oFWPackingSlipEntry:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWPackingSlipEntry:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWPackingSlipEntry:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWPackingSlipEntry:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWPackingSlipEntry:cSelectedFields := Self:Fields
    endIf
    
    oFWPackingSlipEntry:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWPackingSlipEntry:oEaiObjRec:Activate()
    
    oFWPackingSlipEntry:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWPackingSlipEntry:lApi := .T.
	oFWPackingSlipEntry:GetPackingSlipEntry()
	
	if oFWPackingSlipEntry:lOk
		if oFWPackingSlipEntry:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWPackingSlipEntry:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWPackingSlipEntry:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWPackingSlipEntry:cError ))
        lRet := .F.
    EndIf
	
Return lRet

WSMETHOD GET v1_ID QUERYPARAM Fields PATHPARAM InternalId WSREST OGA250API
	Local lRet 					as LOGICAL
	Local oFWPackingSlipEntry  	as OBJECT
	Local oJsonfilter   		as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWPackingSlipEntry := FWPackingSlipEntryAdapter():new()
    oFWPackingSlipEntry:oEaiObjRec := FWEaiObj():new()
    
    oFWPackingSlipEntry:oEaiObjRec:setRestMethod('GET')  

    If !empty(Self:Fields)
        oFWPackingSlipEntry:cSelectedFields := Self:Fields
    endIf
    
    oFWPackingSlipEntry:oEaiObjRec:activate()    
    
    oFWPackingSlipEntry:oEaiObjRec:setPathParam('InternalId',Self:InternalId)
    
    oFWPackingSlipEntry:cTipRet := '2' //Tipo de retorno Não array

    oFWPackingSlipEntry:lApi := .T.
    oFWPackingSlipEntry:GetPackingSlipEntry()
    
    if oFWPackingSlipEntry:lOk
    	lRet := oFWPackingSlipEntry:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWPackingSlipEntry:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWPackingSlipEntry:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWPackingSlipEntry:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD POST V1 WSREST OGA250API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	//Local oRequest 	as OBJECT
	
	cBody := ::GetContent()
	
    oFWPackingSlipEntry := FWPackingSlipEntryAdapter():new()
    oFWPackingSlipEntry:oEaiObjRec := FWEaiObj():new()
    
    oFWPackingSlipEntry:oEaiObjRec:setRestMethod('POST')
    
    oFWPackingSlipEntry:oEaiObjRec:activate()

    oFWPackingSlipEntry:oEaiObjRec:loadJson(cBody)
    
    oFWPackingSlipEntry:cTipRet := '2' //Tipo de retorno Não array

    oFWPackingSlipEntry:lApi := .T.
    cCodId := oFWPackingSlipEntry:IncludePackingSlipEntry()

    If oFWPackingSlipEntry:lOk
        lRet := .T.
        
        //Realizando o GET do conjunto incluido para gerar a resposta
        oFWPackingSlipEntry:GetPackingSlipEntry(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWPackingSlipEntry:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWPackingSlipEntry:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWPackingSlipEntry:cError))
    EndIf

Return lRet


/*WSMETHOD PUT V1 PATHPARAM InternalId WSREST OGA250API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	Local oRequest 	as OBJECT
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.

	conout("WSMETHOD PUT V1 -- InternalId: "+Self:InternalId)	
    oFWPackingSlipEntry := FWPackingSlipEntryAdapter():new()
    oFWPackingSlipEntry:oEaiObjRec := FWEaiObj():new()
    
    oFWPackingSlipEntry:oEaiObjRec:setRestMethod('PUT')    
    oFWPackingSlipEntry:oEaiObjRec:activate()
    
    oFWPackingSlipEntry:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWPackingSlipEntry:oEaiObjRec:loadJson(cBody)
    
    oFWPackingSlipEntry:cTipRet := '2' //Tipo de retorno Não array

    oFWPackingSlipEntry:lApi := .T.
    cCodId := oFWPackingSlipEntry:UpdatePackingSlipEntry()

    If oFWPackingSlipEntry:lOk
        lRet := .T.
		//Realizando o GET do conjunto incluido para gerar a resposta
		oFWPackingSlipEntry:GetPackingSlipEntry(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWPackingSlipEntry:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWPackingSlipEntry:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWPackingSlipEntry:cError))
    EndIf
Return lRet
*/