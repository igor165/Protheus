#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

/*/{Protheus.doc} UBAA110API
//Endpoint de tipo de parada
@author Christopher.miranda
@since 04/12/2018
@version 1.0
@type method
/*/
WSRESTFUL UBAA110API DESCRIPTION ('Endpoint de cadastro de Motivos de Parada');
FORMAT "application/json,text/html" 

	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL

	WSMETHOD GET CottonGinBreaks;
	DESCRIPTION ("Retorna informações dos Motivos de Parada cadastrados.");
	PATH "/api/agr/v1/CottonGinBreaks" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_CottonGinBreaks;
	DESCRIPTION ("Retorna informações do Motivo de Parada solicitado.");
	PATH "/api/agr/v1/CottonGinBreaks/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST CottonGinBreaks;
	DESCRIPTION ("Inclui um novo Motivo de Parada.");
	PATH "/api/agr/v1/CottonGinBreaks" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT CottonGinBreaks;
	DESCRIPTION ("Altera um Motivo de Parada.");
	PATH "/api/agr/v1/CottonGinBreaks/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE CottonGinBreaks;
	DESCRIPTION ("Exclui um Motivo de Parada.");
	PATH "/api/agr/v1/CottonGinBreaks/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	  
END WSRESTFUL

WSMETHOD GET CottonGinBreaks QUERYPARAM Page,PageSize,Order,Fields WSREST UBAA110API
	Local lRet    		     as LOGICAL
	Local oFWCottonGinBreaks as OBJECT
	Local oJsonfilter        as OBJECT
	Local aQryParam		     as ARRAY
	Local nX			     as NUMERIC 
	
	aQryParam 	:= {}	
	lRet 		:= .T. 
	
	oFWCottonGinBreaks := FWCottonGinBreaksAdapter():new()
	oFWCottonGinBreaks:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWCottonGinBreaks:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWCottonGinBreaks:oEaiObjRec:setPage(self:Page)
    Else
        oFWCottonGinBreaks:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWCottonGinBreaks:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWCottonGinBreaks:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWCottonGinBreaks:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWCottonGinBreaks:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonGinBreaks:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS') 
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWCottonGinBreaks:oEaiObjRec:Activate()
    
    oFWCottonGinBreaks:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWCottonGinBreaks:lApi := .T.
	oFWCottonGinBreaks:GetCottonGinBreaks()
	
	if oFWCottonGinBreaks:lOk
        if oFWCottonGinBreaks:cTipRet = '1'
            ::SetResponse(EncodeUtf8(oFWCottonGinBreaks:oEaiObjSnd:GetJson(,.T.)))
        Else
            ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinBreaks:oEaiObjSn2, .F., .F., .T.)))
        endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonGinBreaks:cError ))
        lRet := .F.
    EndIf
	
Return lRet

WSMETHOD GET ID_CottonGinBreaks QUERYPARAM Fields PATHPARAM InternalId WSREST UBAA110API
	Local lRet 			as LOGICAL
	Local oFWCottonGinBreaks as OBJECT
	Local oJsonfilter   as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWCottonGinBreaks := FWCottonGinBreaksAdapter():new()
    oFWCottonGinBreaks:oEaiObjRec  := fwEaiObj():new()
    
    oFWCottonGinBreaks:oEaiObjRec:setRestMethod('GET')  
    
     If !empty(Self:Fields)
        oFWCottonGinBreaks:cSelectedFields := Self:Fields
    endIf
      
    oFWCottonGinBreaks:oEaiObjRec:activate()    
    
    oFWCottonGinBreaks:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWCottonGinBreaks:cTipRet := '2' //Tipo de retorno não array
       
    oFWCottonGinBreaks:lApi := .T.
    oFWCottonGinBreaks:getCottonGinBreaks()
    
    if oFWCottonGinBreaks:lOk
    	lRet := oFWCottonGinBreaks:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinBreaks:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonGinBreaks:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonGinBreaks:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD POST CottonGinBreaks WSREST UBAA110API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodUni   as CHARACTER
	Local aQryParam	as ARRAY
	
	aQryParam := {}
	cBody   := ::GetContent()
	
    oFWCottonGinBreaks := FWCottonGinBreaksAdapter():new()
    oFWCottonGinBreaks:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonGinBreaks:oEaiObjRec:setRestMethod('POST')
    
    oFWCottonGinBreaks:oEaiObjRec:activate()

    oFWCottonGinBreaks:oEaiObjRec:loadJson(cBody)
    
    oFWCottonGinBreaks:cTipRet := '2' //Tipo de retorno não array

    oFWCottonGinBreaks:lApi := .T.
    cCodUni := oFWCottonGinBreaks:IncludeCottonGinBreaks()

    If oFWCottonGinBreaks:lOk
        lRet := .T.
        
        //Realizando o GET do fardão incluida para gerar a resposta
        oFWCottonGinBreaks:getCottonGinBreaks(cCodUni)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinBreaks:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonGinBreaks:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGinBreaks:cError))
    EndIf

Return lRet

WSMETHOD PUT CottonGinBreaks PATHPARAM InternalId WSREST UBAA110API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodUni   as CHARACTER
	Local aQryParam	as ARRAY
	
	aQryParam := {}
	cBody   := ::GetContent()
	
    oFWCottonGinBreaks := FWCottonGinBreaksAdapter():new()
    oFWCottonGinBreaks:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonGinBreaks:oEaiObjRec:setRestMethod('PUT')
    
    oFWCottonGinBreaks:oEaiObjRec:activate()
    oFWCottonGinBreaks:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWCottonGinBreaks:oEaiObjRec:loadJson(cBody)
    
    oFWCottonGinBreaks:cTipRet := '2' //Tipo de retorno array

    oFWCottonGinBreaks:lApi := .T.
    cCodUni := oFWCottonGinBreaks:AlteraCottonGinBreaks()

    If oFWCottonGinBreaks:lOk
        lRet := .T.
		//Realizando o GET do fardão incluida para gerar a resposta
		oFWCottonGinBreaks:getCottonGinBreaks()
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinBreaks:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonGinBreaks:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGinBreaks:cError))
    EndIf

Return lRet

WSMETHOD DELETE CottonGinBreaks PATHPARAM InternalId WSREST UBAA110API
	Local lRet		as LOGICAL
	Local cBody		as CHARACTER
	Local oFWCottonGinBreaks	as OBJECT
	
    oFWCottonGinBreaks := FWCottonGinBreaksAdapter():new()
    oFWCottonGinBreaks:oEaiObjRec := fwEaiObj():new()
    cBody   := Self:GetContent()
 
    oFWCottonGinBreaks:oEaiObjRec:setRestMethod('DELETE')
    oFWCottonGinBreaks:oEaiObjRec:activate()
    
    oFWCottonGinBreaks:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    
    oFWCottonGinBreaks:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonGinBreaks:lApi := .T.
	oFWCottonGinBreaks:getCottonGinBreaks()
    oFWCottonGinBreaks:DeleteCottonGinBreaks()
    If oFWCottonGinBreaks:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinBreaks:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonGinBreaks:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGinBreaks:cError))
    EndIf

Return lRet