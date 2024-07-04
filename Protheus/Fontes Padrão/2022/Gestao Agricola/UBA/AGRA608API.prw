#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL AGRA608API DESCRIPTION ('Cadastro de tipo de classificão do algodão.');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET CottonColorGrades;
	DESCRIPTION ("Retorna informações das classificações cadastradas.");
	PATH "/api/agr/v1/CottonColorGrades" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_CottonColorGrades;
	DESCRIPTION ("Retorna informações da classificação solicitado.");
	PATH "/api/agr/v1/CottonColorGrades/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST CottonColorGrades;
	DESCRIPTION ("Inclui uma nova classificação.");
	PATH "/api/agr/v1/CottonColorGrades" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT CottonColorGrades;
	DESCRIPTION ("Altera uma classificação.");
	PATH "/api/agr/v1/CottonColorGrades/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE CottonColorGrades;
	DESCRIPTION ("Exclui uma classificação.");
	PATH "/api/agr/v1/CottonColorGrades/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL

WSMETHOD GET CottonColorGrades QUERYPARAM Page,PageSize,Order,Fields  WSREST AGRA608API
	Local lRet    		        as LOGICAL
	Local oFWCottonColorGrades  as OBJECT
	Local oJsonfilter           as OBJECT
	Local aQryParam		        as ARRAY
	Local nX			        as NUMERIC
	
	aQryParam 	:= {}	
	lRet 		:= .T. 
	
	oFWCottonColorGrades := FWCottonColorGradesAdapter():new()
	oFWCottonColorGrades:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWCottonColorGrades:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWCottonColorGrades:oEaiObjRec:setPage(self:Page)
    Else
        oFWCottonColorGrades:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWCottonColorGrades:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWCottonColorGrades:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWCottonColorGrades:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWCottonColorGrades:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonColorGrades:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWCottonColorGrades:oEaiObjRec:Activate()
    
    oFWCottonColorGrades:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWCottonColorGrades:lApi := .T.
	oFWCottonColorGrades:GetCottonColorGrades()
	
	if oFWCottonColorGrades:lOk
        if oFWCottonColorGrades:cTipRet = '1'
            ::SetResponse(EncodeUtf8(oFWCottonColorGrades:oEaiObjSnd:GetJson(,.T.)))
        Else
            ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonColorGrades:oEaiObjSn2, .F., .F., .T.)))
        endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonColorGrades:cError ))
        lRet := .F.
    EndIf
	
Return lRet

WSMETHOD GET ID_CottonColorGrades QUERYPARAM Fields PATHPARAM InternalId WSREST AGRA608API
	Local lRet 			        as LOGICAL
	Local oFWCottonColorGrades  as OBJECT
	Local oJsonfilter           as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWCottonColorGrades := FWCottonColorGradesAdapter():new()
    oFWCottonColorGrades:oEaiObjRec  := fwEaiObj():new()
    
    oFWCottonColorGrades:oEaiObjRec:setRestMethod('GET')  
    
    If !empty(Self:Fields)
        oFWCottonColorGrades:cSelectedFields := Self:Fields
    endIf
      
    oFWCottonColorGrades:oEaiObjRec:activate()    
    
    oFWCottonColorGrades:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWCottonColorGrades:cTipRet := '2' //Tipo de retorno Não array
       
    oFWCottonColorGrades:lApi := .T.
    oFWCottonColorGrades:GetCottonColorGrades()
    
    if oFWCottonColorGrades:lOk
    	lRet := oFWCottonColorGrades:lOk
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonColorGrades:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonColorGrades:oEaiObjSnd:GetJson(,.T.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonColorGrades:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD POST CottonColorGrades WSREST AGRA608API
	Local lRet     as LOGICAL
	Local cBody    as CHARACTER
	Local cCodId   as CHARACTER
	
	cBody     := ::GetContent()
	
    oFWCottonColorGrades := FWCottonColorGradesAdapter():new()
    oFWCottonColorGrades:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonColorGrades:oEaiObjRec:setRestMethod('POST')
    
    oFWCottonColorGrades:oEaiObjRec:activate()

    oFWCottonColorGrades:oEaiObjRec:loadJson(cBody)
    
     oFWCottonColorGrades:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonColorGrades:lApi := .T.
    cCodId := oFWCottonColorGrades:IncludeCottonColorGrades()

    If oFWCottonColorGrades:lOk
        lRet := .T.
        
        //Realizando o GET da classificação incluida para gerar a resposta
        oFWCottonColorGrades:GetCottonColorGrades(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonColorGrades:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonColorGrades:oEaiObjSnd:getJson(,.T.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonColorGrades:cError))
    EndIf

Return lRet

WSMETHOD PUT CottonColorGrades PATHPARAM InternalId WSREST AGRA608API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWCottonColorGrades := FWCottonColorGradesAdapter():new()
    oFWCottonColorGrades:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonColorGrades:oEaiObjRec:setRestMethod('PUT')    
    oFWCottonColorGrades:oEaiObjRec:activate()
    
    oFWCottonColorGrades:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWCottonColorGrades:oEaiObjRec:loadJson(cBody)
    
    oFWCottonColorGrades:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonColorGrades:lApi := .T.
    cCodId := oFWCottonColorGrades:AlteraCottonColorGrades()

    If oFWCottonColorGrades:lOk
        lRet := .T.
		//Realizando o GET da classificação incluida para gerar a resposta
		oFWCottonColorGrades:GetCottonColorGrades(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonColorGrades:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonColorGrades:oEaiObjSnd:getJson(,.T.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonColorGrades:cError))
    EndIf

Return lRet

WSMETHOD DELETE CottonColorGrades PATHPARAM InternalId WSREST AGRA608API
	Local lRet			        as LOGICAL
	Local oFWCottonColorGrades	as OBJECT
	
	lRet := .T.
	
    oFWCottonColorGrades := FWCottonColorGradesAdapter():new()
    oFWCottonColorGrades:oEaiObjRec := fwEaiObj():new()
 
    oFWCottonColorGrades:oEaiObjRec:setRestMethod('DELETE')
    oFWCottonColorGrades:oEaiObjRec:activate()
    
    oFWCottonColorGrades:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    
    oFWCottonColorGrades:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonColorGrades:lApi := .T.
    oFWCottonColorGrades:GetCottonColorGrades()
    oFWCottonColorGrades:DeleteCottonColorGrades()
    If oFWCottonColorGrades:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonColorGrades:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonColorGrades:oEaiObjSnd:getJson(,.T.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonColorGrades:cError))
    EndIf

Return lRet