#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

/*/{Protheus.doc} UBAA120API
//Endpoint de Apontamento do tipo de parada
@author Christopher.miranda
@since 04/12/2018
@version 1.0
@type method
/*/
WSRESTFUL UBAA120API DESCRIPTION ('Endpoint de Apontamentos dos motivos de parada da beneficiadora');
FORMAT "application/json,text/html" 

	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL

	WSMETHOD GET CottonGinBreakPointings;
	DESCRIPTION ("Retorna informações dos Apontamentos dos Tipos de Parada cadastrados.");
	PATH "/api/agr/v1/CottonGinBreakPointings" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET ID_CottonGinBreakPointings;
	DESCRIPTION ("Retorna informações do Apontamento do Tipo de Parada solicitado.");
	PATH "/api/agr/v1/CottonGinBreakPointings/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST CottonGinBreakPointings;
	DESCRIPTION ("Inclui um novo Apontamento do Tipo de Parada.");
	PATH "/api/agr/v1/CottonGinBreakPointings" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT CottonGinBreakPointings;
	DESCRIPTION ("Altera um Apontamento do Tipo de Parada.");
	PATH "/api/agr/v1/CottonGinBreakPointings/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
    WSMETHOD DELETE CottonGinBreakPointings;
	DESCRIPTION ("Exclui um Apontamento do Tipo de Parada.");
	PATH "/api/agr/v1/CottonGinBreakPointings/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	  
END WSRESTFUL

WSMETHOD GET CottonGinBreakPointings QUERYPARAM Page,PageSize,Order,Fields WSREST UBAA120API
	Local lRet    		                as LOGICAL
	Local oFWCottonGinBreakPointings    as OBJECT
	Local oJsonfilter                   as OBJECT
	Local aQryParam		                as ARRAY
	Local nX			                as NUMERIC 
	
	aQryParam 	:= {}	
	lRet 		:= .T. 
	
	oFWCottonGinBreakPointings := FWCottonGinBreakPointingsAdapter():new()
	oFWCottonGinBreakPointings:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWCottonGinBreakPointings:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWCottonGinBreakPointings:oEaiObjRec:setPage(self:Page)
    Else
        oFWCottonGinBreakPointings:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWCottonGinBreakPointings:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWCottonGinBreakPointings:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWCottonGinBreakPointings:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWCottonGinBreakPointings:cSelectedFields := Self:Fields
    endIf
    
    oFWCottonGinBreakPointings:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS') 
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWCottonGinBreakPointings:oEaiObjRec:Activate()
    
    oFWCottonGinBreakPointings:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWCottonGinBreakPointings:lApi := .T.
	oFWCottonGinBreakPointings:GetCottonGinBreakPointings()
    
    if oFWCottonGinBreakPointings:lOk
		if oFWCottonGinBreakPointings:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWCottonGinBreakPointings:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinBreakPointings:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonGinBreakPointings:cError ))
        lRet := .F.
    EndIf
	
Return lRet

WSMETHOD GET ID_CottonGinBreakPointings QUERYPARAM Fields PATHPARAM InternalId WSREST UBAA120API
	Local lRet 			                as LOGICAL
	Local oFWCottonGinBreakPointings    as OBJECT
	Local oJsonfilter                   as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWCottonGinBreakPointings := FWCottonGinBreakPointingsAdapter():new()
    oFWCottonGinBreakPointings:oEaiObjRec  := fwEaiObj():new()
    
    oFWCottonGinBreakPointings:oEaiObjRec:setRestMethod('GET')  
    
     If !empty(Self:Fields)
        oFWCottonGinBreakPointings:cSelectedFields := Self:Fields
    endIf
      
    oFWCottonGinBreakPointings:oEaiObjRec:activate()    
    
    oFWCottonGinBreakPointings:oEaiObjRec:setPathParam('InternalId',Self:InternalId) 
    
    oFWCottonGinBreakPointings:cTipRet := '2' //Tipo de retorno não array
       
    oFWCottonGinBreakPointings:lApi := .T.
    oFWCottonGinBreakPointings:getCottonGinBreakPointings()
    
    if oFWCottonGinBreakPointings:lOk
    	lRet := oFWCottonGinBreakPointings:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinBreakPointings:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonGinBreakPointings:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWCottonGinBreakPointings:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD POST CottonGinBreakPointings WSREST UBAA120API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodUni   as CHARACTER
	Local aQryParam	as ARRAY
	
	aQryParam := {}
	cBody   := ::GetContent()
	
    oFWCottonGinBreakPointings := FWCottonGinBreakPointingsAdapter():new()
    oFWCottonGinBreakPointings:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonGinBreakPointings:oEaiObjRec:setRestMethod('POST')
    
    oFWCottonGinBreakPointings:oEaiObjRec:activate()

    oFWCottonGinBreakPointings:oEaiObjRec:loadJson(cBody)
    
    oFWCottonGinBreakPointings:cTipRet := '2' //Tipo de retorno não array

    oFWCottonGinBreakPointings:lApi := .T.
    cCodUni := oFWCottonGinBreakPointings:IncludeCottonGinBreakPointings()

    If oFWCottonGinBreakPointings:lOk
        lRet := .T.
        
        //Realizando o GET do fardão incluida para gerar a resposta
        oFWCottonGinBreakPointings:getCottonGinBreakPointings(cCodUni)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinBreakPointings:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWCottonGinBreakPointings:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGinBreakPointings:cError))
    EndIf

Return lRet

WSMETHOD PUT CottonGinBreakPointings PATHPARAM InternalId WSREST UBAA120API
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodUni   as CHARACTER
	Local aQryParam	as ARRAY
	
	aQryParam := {}
	cBody   := ::GetContent()
	
    oFWCottonGinBreakPointings := FWCottonGinBreakPointingsAdapter():new()
    oFWCottonGinBreakPointings:oEaiObjRec := fwEaiObj():new()
    
    oFWCottonGinBreakPointings:oEaiObjRec:setRestMethod('PUT')
    
    oFWCottonGinBreakPointings:oEaiObjRec:activate()
    oFWCottonGinBreakPointings:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWCottonGinBreakPointings:oEaiObjRec:loadJson(cBody)
    
    oFWCottonGinBreakPointings:cTipRet := '2' //Tipo de retorno array

    oFWCottonGinBreakPointings:lApi := .T.
    cCodUni := oFWCottonGinBreakPointings:AlteraCottonGinBreakPointings()

    If oFWCottonGinBreakPointings:lOk
        lRet := .T.
		//Realizando o GET do fardão incluida para gerar a resposta
		oFWCottonGinBreakPointings:getCottonGinBreakPointings()
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinBreakPointings:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonGinBreakPointings:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGinBreakPointings:cError))
    EndIf

Return lRet

WSMETHOD DELETE CottonGinBreakPointings PATHPARAM InternalId WSREST UBAA120API
	Local lRet		                    as LOGICAL
	Local cBody		                    as CHARACTER
	Local oFWCottonGinBreakPointings	as OBJECT
	
    oFWCottonGinBreakPointings := FWCottonGinBreakPointingsAdapter():new()
    oFWCottonGinBreakPointings:oEaiObjRec := fwEaiObj():new()
    cBody   := Self:GetContent()
 
    oFWCottonGinBreakPointings:oEaiObjRec:setRestMethod('DELETE')
    oFWCottonGinBreakPointings:oEaiObjRec:activate()
    
    oFWCottonGinBreakPointings:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    
    oFWCottonGinBreakPointings:cTipRet := '2' //Tipo de retorno Não array

    oFWCottonGinBreakPointings:lApi := .T.
	oFWCottonGinBreakPointings:getCottonGinBreakPointings()
    oFWCottonGinBreakPointings:DeleteCottonGinBreakPointings()
    If oFWCottonGinBreakPointings:lOk
        lRet := .T.
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWCottonGinBreakPointings:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWCottonGinBreakPointings:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWCottonGinBreakPointings:cError))
    EndIf

Return lRet