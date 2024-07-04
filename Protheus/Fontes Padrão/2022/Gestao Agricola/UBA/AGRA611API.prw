#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL AGRA611API DESCRIPTION ('Endpoint de cadastro de conjuntos');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET CottonGinMachines;
	DESCRIPTION ("Retorna informações dos conjuntos cadastrados.");
	PATH "/api/agr/v1/CottonGinMachines" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_CottonGinMachines;
	DESCRIPTION ("Retorna informações do conjunto solicitado.");
	PATH "/api/agr/v1/CottonGinMachines/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST CottonGinMachines;
	DESCRIPTION ("Inclui um novo conjunto.");
	PATH "/api/agr/v1/CottonGinMachines" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT CottonGinMachines;
	DESCRIPTION ("Altera um conjunto.");
	PATH "/api/agr/v1/CottonGinMachines/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE CottonGinMachines;
	DESCRIPTION ("Exclui um conjunto.");
	PATH "/api/agr/v1/CottonGinMachines/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET CottonGinMachines QUERYPARAM Page,PageSize,Order,Fields  WSREST AGRA611API
	Local lRet    				as LOGICAL
	Local oFWCottonGinMachine 	as OBJECT
	Local oJsonfilter   		as OBJECT
	Local aQryParam				as ARRAY
	Local nX					as NUMERIC
	
	aQryParam 	:= {}	
	lRet 		:= .T. 
	
	oFWCottonGinMachine := FWCottonGinMachinesAdapter():new()
	oFWCottonGinMachine:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWCottonGinMachine:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWCottonGinMachine:oEaiObjRec:setPage(self:Page)
    Else
        oFWCottonGinMachine:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWCottonGinMachine:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWCottonGinMachine:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWCottonGinMachine:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWCottonGinMachine:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonGinMachine:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWCottonGinMachine:oEaiObjRec:Activate()
    
    oFWCottonGinMachine:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWCottonGinMachine:lApi := .T.
	oFWCottonGinMachine:GetCottonGinMachines()
	
	if oFWCottonGinMachine:lOk
		if oFWCottonGinMachine:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWCottonGinMachine:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinMachine:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonGinMachine:cError ))
        lRet := .F.
    EndIf
	
Return lRet


WSMETHOD GET ID_CottonGinMachines QUERYPARAM Fields PATHPARAM InternalId WSREST AGRA611API
	Local lRet 					as LOGICAL
	Local oFWCottonGinMachine  	as OBJECT
	Local oJsonfilter   		as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWCottonGinMachine := FWCottonGinMachinesAdapter():new()
    oFWCottonGinMachine:oEaiObjRec := FWEaiObj():new()
    
    oFWCottonGinMachine:oEaiObjRec:setRestMethod('GET')  
    
    If !empty(Self:Fields)
        oFWCottonGinMachine:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonGinMachine:oEaiObjRec:activate()    
    
    oFWCottonGinMachine:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWCottonGinMachine:cTipRet := '2' //Tipo de retorno Não array
       
    oFWCottonGinMachine:lApi := .T.
    oFWCottonGinMachine:GetCottonGinMachines()
    
    if oFWCottonGinMachine:lOk
    	lRet := oFWCottonGinMachine:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinMachine:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonGinMachine:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonGinMachine:cError ))
        lRet := .F.
    EndIf

Return lRet


WSMETHOD POST CottonGinMachines WSREST AGRA611API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody := ::GetContent()
	
    oFWCottonGinMachine := FWCottonGinMachinesAdapter():new()
    oFWCottonGinMachine:oEaiObjRec := FWEaiObj():new()
    
    oFWCottonGinMachine:oEaiObjRec:setRestMethod('POST')
    
    oFWCottonGinMachine:oEaiObjRec:activate()

    oFWCottonGinMachine:oEaiObjRec:loadJson(cBody)
    
    oFWCottonGinMachine:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonGinMachine:lApi := .T.
    cCodId := oFWCottonGinMachine:IncludeCottonGinMachine()

    If oFWCottonGinMachine:lOk
        lRet := .T.
        
        //Realizando o GET do conjunto incluido para gerar a resposta
        oFWCottonGinMachine:GetCottonGinMachines(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinMachine:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonGinMachine:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGinMachine:cError))
    EndIf

Return lRet


WSMETHOD PUT CottonGinMachines PATHPARAM InternalId WSREST AGRA611API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWCottonGinMachine := FWCottonGinMachinesAdapter():new()
    oFWCottonGinMachine:oEaiObjRec := FWEaiObj():new()
    
    oFWCottonGinMachine:oEaiObjRec:setRestMethod('PUT')    
    oFWCottonGinMachine:oEaiObjRec:activate()
    
    oFWCottonGinMachine:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWCottonGinMachine:oEaiObjRec:loadJson(cBody)
    
    oFWCottonGinMachine:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonGinMachine:lApi := .T.
    cCodId := oFWCottonGinMachine:AlteraCottonGinMachine()

    If oFWCottonGinMachine:lOk
        lRet := .T.
		//Realizando o GET do conjunto incluido para gerar a resposta
		oFWCottonGinMachine:getCottonGinMachines(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinMachine:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonGinMachine:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGinMachine:cError))
    EndIf
Return lRet


WSMETHOD DELETE CottonGinMachines PATHPARAM InternalId WSREST AGRA611API
	Local lRet					as LOGICAL
	Local oFWCottonGinMachine	as OBJECT
	
	lRet := .T.
	
    oFWCottonGinMachine := FWCottonGinMachinesAdapter():new()
    oFWCottonGinMachine:oEaiObjRec := FWEaiObj():new()
 
    oFWCottonGinMachine:oEaiObjRec:setRestMethod('DELETE')
    oFWCottonGinMachine:oEaiObjRec:activate()
    
    oFWCottonGinMachine:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    
    oFWCottonGinMachine:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonGinMachine:lApi := .T.
    oFWCottonGinMachine:getCottonGinMachines()
    oFWCottonGinMachine:DeleteCottonGinMachine()
    If oFWCottonGinMachine:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinMachine:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonGinMachine:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGinMachine:cError))
    EndIf

Return lRet