#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

/*/{Protheus.doc} AGRA601API
//Endpoint de fardoes
@author brunosilva
@since 23/09/2018
@version 1.0
@type method
/*/
WSRESTFUL AGRA601API DESCRIPTION ('Endpoint de cadastro de fardão');
FORMAT "application/json,text/html" 

	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL

	WSMETHOD GET CottonBales;
	DESCRIPTION ("Retorna informações dos fardões cadastrados.");
	PATH "/api/agr/v1/CottonBales" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_CottonBales;
	DESCRIPTION ("Retorna informações do fardão solicitado.");
	PATH "/api/agr/v1/CottonBales/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST CottonBales;
	DESCRIPTION ("Inclui um novo fardão.");
	PATH "/api/agr/v1/CottonBales" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT CottonBales;
	DESCRIPTION ("Altera um fardão.");
	PATH "/api/agr/v1/CottonBales/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE CottonBales;
	DESCRIPTION ("Exclui um fardão.");
	PATH "/api/agr/v1/CottonBales/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	  
END WSRESTFUL


WSMETHOD GET CottonBales QUERYPARAM Page,PageSize,Order,Fields WSREST AGRA601API
	Local lRet    		as LOGICAL
	Local oFWCottonBale as OBJECT
	Local oJsonfilter   as OBJECT
	Local aQryParam		as ARRAY
	Local nX			as NUMERIC 
	
	aQryParam 	:= {}	
	lRet 		:= .T. 
	
	oFWCottonBale := FWCottonBalesAdapter():new()
	oFWCottonBale:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWCottonBale:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWCottonBale:oEaiObjRec:setPage(self:Page)
    Else
        oFWCottonBale:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWCottonBale:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWCottonBale:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWCottonBale:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWCottonBale:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonBale:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS') 
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWCottonBale:oEaiObjRec:Activate()
    
    oFWCottonBale:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWCottonBale:lApi := .T.
	oFWCottonBale:GetCottonBales()
	
	if oFWCottonBale:lOk
        if oFWCottonBale:cTipRet = '1'
            ::SetResponse(EncodeUtf8(oFWCottonBale:oEaiObjSnd:GetJson(,.T.)))
        Else
            ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonBale:oEaiObjSn2, .F., .F., .T.)))
        endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonBale:cError ))
        lRet := .F.
    EndIf
	
Return lRet

WSMETHOD GET ID_CottonBales QUERYPARAM Fields PATHPARAM InternalId WSREST AGRA601API
	Local lRet 			as LOGICAL
	Local oFWCottonBale as OBJECT
	Local oJsonfilter   as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWCottonBale := FWCottonBalesAdapter():new()
    oFWCottonBale:oEaiObjRec  := fwEaiObj():new()
    
    oFWCottonBale:oEaiObjRec:setRestMethod('GET')  
    
     If !empty(Self:Fields)
        oFWCottonBale:cSelectedFields := Self:Fields
    endIf
      
    oFWCottonBale:oEaiObjRec:activate()    
    
    oFWCottonBale:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWCottonBale:cTipRet := '2' //Tipo de retorno não array
       
    oFWCottonBale:lApi := .T.
    oFWCottonBale:getCottonBale()
    
    if oFWCottonBale:lOk
    	lRet := oFWCottonBale:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonBale:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonBale:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonBale:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD POST CottonBales WSREST AGRA601API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodUni   as CHARACTER
	Local aQryParam	as ARRAY
	
	aQryParam := {}
	cBody   := ::GetContent()
	
    oFWCottonBale := FWCottonBalesAdapter():new()
    oFWCottonBale:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonBale:oEaiObjRec:setRestMethod('POST')
    
    oFWCottonBale:oEaiObjRec:activate()

    oFWCottonBale:oEaiObjRec:loadJson(cBody)
    
    oFWCottonBale:cTipRet := '2' //Tipo de retorno não array

    oFWCottonBale:lApi := .T.
    cCodUni := oFWCottonBale:IncludeCottonBale()

    If oFWCottonBale:lOk
        lRet := .T.
        
        //Realizando o GET do fardão incluida para gerar a resposta
        oFWCottonBale:getCottonBales(cCodUni)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonBale:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonBale:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonBale:cError))
    EndIf

Return lRet

WSMETHOD PUT CottonBales PATHPARAM InternalId WSREST AGRA601API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodUni   as CHARACTER
	Local aQryParam	as ARRAY
	
	aQryParam := {}
	cBody   := ::GetContent()
	
    oFWCottonBale := FWCottonBalesAdapter():new()
    oFWCottonBale:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonBale:oEaiObjRec:setRestMethod('PUT')
    
    oFWCottonBale:oEaiObjRec:activate()
    oFWCottonBale:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWCottonBale:oEaiObjRec:loadJson(cBody)
    
    oFWCottonBale:cTipRet := '2' //Tipo de retorno array

    oFWCottonBale:lApi := .T.
    cCodUni := oFWCottonBale:AlteraCottonBale()

    If oFWCottonBale:lOk
        lRet := .T.
		//Realizando o GET do fardão incluida para gerar a resposta
		oFWCottonBale:getCottonBales()
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonBale:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonBale:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonBale:cError))
    EndIf

Return lRet

WSMETHOD DELETE CottonBales PATHPARAM InternalId WSREST AGRA601API
	Local lRet		as LOGICAL
	Local cBody		as CHARACTER
	Local oFWCottonBale	as OBJECT
	
    oFWCottonBale := FWCottonBalesAdapter():new()
    oFWCottonBale:oEaiObjRec := fwEaiObj():new()
    cBody   := Self:GetContent()
 
    oFWCottonBale:oEaiObjRec:setRestMethod('DELETE')
    oFWCottonBale:oEaiObjRec:activate()
    
    oFWCottonBale:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWCottonBale:oEaiObjRec:loadJson(cBody)
    
    oFWCottonBale:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonBale:lApi := .T.
	oFWCottonBale:getCottonBales()
    oFWCottonBale:DeleteCottonBale()
    If oFWCottonBale:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonBale:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonBale:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonBale:cError))
    EndIf

Return lRet