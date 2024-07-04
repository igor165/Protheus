#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL TPESAGAPI DESCRIPTION ('Estrutura de tabelas');
FORMAT "application/json,text/html" 
	
	WSDATA Code As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
    WSDATA Expand  AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET v1;
	DESCRIPTION ("Retorna as entidades/tabelas.");
	WSSYNTAX "/api/agr/v1/entityHeader";
	PATH "/api/agr/v1/entityHeader" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET v1_ID;
	DESCRIPTION ("Retorna apenas uma entidade/tabela.");
	WSSYNTAX "/api/agr/v1/entityHeader/{code}";
	PATH "/api/agr/v1/entityHeader/{code}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj	
	
	WSMETHOD GET data_id;
	DESCRIPTION ("Retorna apenas uma entidade/tabela com os campos.");
	WSSYNTAX "/api/agr/v1/data/{code}";
	PATH "/api/agr/v1/data/{code}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET fields;
	DESCRIPTION ("Retorna os campos usados na integração.");
	WSSYNTAX "/api/agr/v1/composition/fields";
	PATH "/api/agr/v1/composition/fields" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET product;
	DESCRIPTION ("Retorna os campos usados na integração do produto.");
	WSSYNTAX "/api/agr/v1/product";
	PATH "/api/agr/v1/product" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET equipments;
	DESCRIPTION ("Retorna os campos usados na integração de equipamentos.");
	WSSYNTAX "/api/agr/v1/equipments";
	PATH "/api/agr/v1/equipments" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET employee;
	DESCRIPTION ("Retorna os campos usados na integração de funcionarios.");
	WSSYNTAX "/api/agr/v1/employee";
	PATH "/api/agr/v1/employee" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD POST composition;
	DESCRIPTION ("Realiza integração das pesagens");
	WSSYNTAX "/api/agr/v1/composition";
	PATH "/api/agr/v1/composition" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET analysis;
	DESCRIPTION ("Realiza integração das analises/Tabelas de Classificação");
	WSSYNTAX "/api/agr/v1/analysis";
	PATH "/api/agr/v1/analysis" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET discountRanges;
	DESCRIPTION ("Realiza integração das faixas de desconto");
	WSSYNTAX "/api/agr/v1/discountRangesHE";
	PATH "/api/agr/v1/discountRangesHE" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET v1 QUERYPARAM Page,PageSize,Order,Fields  WSREST TPESAGAPI
	Local lRet    				as LOGICAL
	Local oFWentityHeader 			as OBJECT
	Local oJsonfilter   		as OBJECT
	Local nX					as NUMERIC
	
	lRet 		:= .T. 

	oFWentityHeader := FWentityHeaderAdapter():new()
	oFWentityHeader:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWentityHeader:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWentityHeader:oEaiObjRec:setPage(self:Page)
    Else
        oFWentityHeader:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWentityHeader:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWentityHeader:oEaiObjRec:setPageSize(10)
    endIf
    
    If !empty(Self:Order)
        oFWentityHeader:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWentityHeader:cSelectedFields := Self:Fields
    endIf
    
    oFWentityHeader:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWentityHeader:oEaiObjRec:Activate()
    
    oFWentityHeader:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWentityHeader:lApi := .T.
	oFWentityHeader:GetentityHeader()
	
	if oFWentityHeader:lOk
		if oFWentityHeader:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWentityHeader:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWentityHeader:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWentityHeader:cError ))
        lRet := .F.
    EndIf
	
Return lRet

WSMETHOD GET v1_ID QUERYPARAM Fields PATHPARAM Code WSREST TPESAGAPI
	Local lRet 					as LOGICAL
	Local oFWentityHeader  	as OBJECT
	Local oJsonfilter   		as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWentityHeader := FWentityHeaderAdapter():new()
    oFWentityHeader:oEaiObjRec := FWEaiObj():new()
    
    oFWentityHeader:oEaiObjRec:setRestMethod('GET')  

    If !empty(Self:Fields)
        oFWentityHeader:cSelectedFields := Self:Fields
    endIf
    
    oFWentityHeader:oEaiObjRec:activate()    
    
    oFWentityHeader:oEaiObjRec:setPathParam('code',Self:Code)
    
    oFWentityHeader:cTipRet := '2' //Tipo de retorno Não array

    oFWentityHeader:lApi := .T.
    oFWentityHeader:GetentityHeader()
    
    if oFWentityHeader:lOk
    	lRet := oFWentityHeader:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWentityHeader:oEaiObjSn2, .F., .F., .T.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWentityHeader:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD GET data_ID QUERYPARAM Fields PATHPARAM Code WSREST TPESAGAPI
	Local lRet 					as LOGICAL
	Local oFWdata  				as OBJECT
	Local oJsonfilter   		as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWdata := FWdataAdapter():new()
    oFWdata:oEaiObjRec := FWEaiObj():new()
    
    oFWdata:oEaiObjRec:setRestMethod('GET')  

    If !empty(Self:Fields)
        oFWdata:cSelectedFields := Self:Fields
    endIf
    
    oFWdata:oEaiObjRec:activate()    
    
    oFWdata:oEaiObjRec:setPathParam('code',Self:Code)
    
    oFWdata:cTipRet := '2' //Tipo de retorno Não array

    oFWdata:lApi := .T.
    oFWdata:Getdata()
    
    if oFWdata:lOk
    	lRet := oFWdata:lOk
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWdata:oFieldsJson, .F., .F., .T.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWdata:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD GET fields QUERYPARAM Fields PATHPARAM Code WSREST TPESAGAPI
	Local lRet 					as LOGICAL
	Local oFWfields  			as OBJECT
	Local oJsonfilter   		as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWfields := FWfieldsAdapter():new()
    oFWfields:oEaiObjRec := FWEaiObj():new()
    
    oFWfields:oEaiObjRec:setRestMethod('GET')  

    If !empty(Self:Fields)
        oFWfields:cSelectedFields := Self:Fields
    endIf
    
    oFWfields:oEaiObjRec:activate()    
    
    oFWfields:oEaiObjRec:setPathParam('code',Self:Code)
    
    oFWfields:cTipRet := '2' //Tipo de retorno Não array

    oFWfields:lApi := .T.
    oFWfields:Getfields()
    
    if oFWfields:lOk
    	lRet := oFWfields:lOk
    	::SetResponse(oFWfields:oEaiObjSn2:ToJSON())
    Else
        SetRestFault(400,EncodeUtf8( oFWfields:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD GET product QUERYPARAM product PATHPARAM Code WSREST TPESAGAPI
	Local lRet    				as LOGICAL
	Local oFWproduct 			as OBJECT
	Local oJsonfilter   		as OBJECT
	Local nX					as NUMERIC
	
	lRet 		:= .T. 

	oFWproduct := FWproductAdapter():new()
	oFWproduct:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWproduct:oEaiObjRec:setRestMethod('GET')
    
    if !(EMPTY(self:Page))
        oFWproduct:oEaiObjRec:setPage(self:Page)
    Else
        oFWproduct:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWproduct:oEaiObjRec:setPageSize(Self:PageSize)
    else
    	oFWproduct:oEaiObjRec:setPageSize(999999)
    endIf
    
    If !empty(Self:Order)
        oFWproduct:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWproduct:cSelectedFields := Self:Fields
    endIf
    
    oFWproduct:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWproduct:oEaiObjRec:Activate()
    
    oFWproduct:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWproduct:lApi := .T.
	oFWproduct:Getproduct()
	
	if oFWproduct:lOk
		if oFWproduct:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWproduct:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWproduct:oEaiObjSn2, .F., .F., .T.)))
		endif
    Else
        SetRestFault(400,EncodeUtf8( oFWproduct:cError ))
        lRet := .F.
    EndIf
Return lRet

WSMETHOD GET equipments QUERYPARAM equipments PATHPARAM Code WSREST TPESAGAPI
	Local lRet    				as LOGICAL
	Local oFWequipments 			as OBJECT
	Local oJsonfilter   		as OBJECT
	Local nX					as NUMERIC
	
	lRet 		:= .T. 

	oFWequipments := FWequipmentsAdapter():new()
	oFWequipments:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWequipments:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWequipments:oEaiObjRec:setPage(self:Page)
    Else
        oFWequipments:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWequipments:oEaiObjRec:setPageSize(Self:PageSize)
    else
    	oFWequipments:oEaiObjRec:setPageSize(999999)
    endIf
    
    If !empty(Self:Order)
        oFWequipments:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWequipments:cSelectedFields := Self:Fields
    endIf
    
    oFWequipments:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWequipments:oEaiObjRec:Activate()
    
    oFWequipments:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWequipments:lApi := .T.
	oFWequipments:Getequipments()
	
	if oFWequipments:lOk
		::SetResponse(EncodeUTF8(oFWequipments:oEaiObjSnd:GetJson(,.T.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWequipments:cError ))
        lRet := .F.
    EndIf
Return lRet

WSMETHOD GET employee QUERYPARAM employee PATHPARAM Code WSREST TPESAGAPI
	Local lRet    				as LOGICAL
	Local oFWemployee 			as OBJECT
	Local oJsonfilter   		as OBJECT
	Local nX					as NUMERIC
	
	lRet 		:= .T. 

	oFWemployee := FWemployeeAdapter():new()
	oFWemployee:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWemployee:oEaiObjRec:setRestMethod('GET')
    
    if !(EMPTY(self:Page))
        oFWemployee:oEaiObjRec:setPage(self:Page)
    Else
        oFWemployee:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWemployee:oEaiObjRec:setPageSize(Self:PageSize)
    else
    	oFWemployee:oEaiObjRec:setPageSize(999999)
    endIf
    
    If !empty(Self:Order)
        oFWemployee:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWemployee:cSelectedFields := Self:Fields
    endIf
    
    oFWemployee:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWemployee:oEaiObjRec:Activate()
    
    oFWemployee:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWemployee:lApi := .T.
	oFWemployee:Getemployee()
	
	if oFWemployee:lOk
		::SetResponse(EncodeUTF8(oFWemployee:oEaiObjSnd:GetJson(,.T.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWemployee:cError ))
        lRet := .F.
    EndIf
Return lRet

WSMETHOD POST composition WSREST TPESAGAPI
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	
	lRet := .T.
	cBody     := ::GetContent()
	
    oFWcomposition := FWcompositionAdapter():new()
    oFWcomposition:oEaiObjRec := FWEaiObj():new()
    
    oFWcomposition:oEaiObjRec:setRestMethod('POST')
    
    oFWcomposition:oEaiObjRec:activate()

    oFWcomposition:oEaiObjRec:loadJson(cBody)
    
    oFWcomposition:cTipRet := '2' //Tipo de retorno Não array

    oFWcomposition:lApi := .T.
    oFWcomposition:Includecomposition()

    If oFWcomposition:lOk
        lRet := .T.
        
        ::SetResponse(oFWcomposition:oRest:GetResult())
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWcomposition:cError))
    EndIf

Return lRet

WSMETHOD GET analysis QUERYPARAM Page,PageSize,Order,Fields,Expand  WSREST TPESAGAPI
	Local lRet    				as LOGICAL
	Local oFWanalysis 		as OBJECT
	Local oJsonfilter   		as OBJECT
	Local nX					as NUMERIC
	
	lRet 		:= .T. 

	oFWanalysis := FWanalysisAdapter():new()
	oFWanalysis:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWanalysis:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWanalysis:oEaiObjRec:setPage(self:Page)
    Else
        oFWanalysis:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWanalysis:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWanalysis:oEaiObjRec:setPageSize(99999)
    endIf
    
    If !empty(Self:Order)
        oFWanalysis:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWanalysis:cSelectedFields := Self:Fields
    endIf
    
    oFWanalysis:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWanalysis:oEaiObjRec:Activate()
    
    oFWanalysis:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWanalysis:lApi := .T.
	oFWanalysis:Getanalysis()
	
	if oFWanalysis:lOk
		if oFWanalysis:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWanalysis:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWanalysis:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWanalysis:cError ))
        lRet := .F.
    EndIf
	
Return lRet

WSMETHOD GET discountRanges QUERYPARAM Page,PageSize,Order,Fields,Expand  WSREST TPESAGAPI
	Local lRet    				as LOGICAL
	Local oFWdiscountRanges 		as OBJECT
	Local oJsonfilter   		as OBJECT
	Local nX					as NUMERIC
	
	lRet 		:= .T. 

	oFWdiscountRanges := FWdiscountRangesAdapter():new()
	oFWdiscountRanges:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWdiscountRanges:oEaiObjRec:setRestMethod('GET')
	
	if !(EMPTY(self:Page))
        oFWdiscountRanges:oEaiObjRec:setPage(self:Page)
    Else
        oFWdiscountRanges:oEaiObjRec:setPage(1)
    endIf
	
	if !(EMPTY(Self:PageSize))
        oFWdiscountRanges:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWdiscountRanges:oEaiObjRec:setPageSize(99999)
    endIf
    
    If !empty(Self:Order)
        oFWdiscountRanges:oEaiObjRec:setOrder(Self:Order)
    endIf
    
    If !empty(Self:Fields)
        oFWdiscountRanges:cSelectedFields := Self:Fields
    endIf
    
    oFWdiscountRanges:cTipRet := '1' //Tipo de retorno array
    
    for nX := 1 to len(self:aQueryString)
        if !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    next nX
    
    oFWdiscountRanges:oEaiObjRec:Activate()
    
    oFWdiscountRanges:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWdiscountRanges:lApi := .T.
	oFWdiscountRanges:GetdiscountRanges()
	
	if oFWdiscountRanges:lOk
		if oFWdiscountRanges:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWdiscountRanges:oEaiObjSnd:GetJson(,.T.)))
		else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWdiscountRanges:oEaiObjSn2, .F., .F., .T.)))
		endIf
    Else
        SetRestFault(400,EncodeUtf8( oFWdiscountRanges:cError ))
        lRet := .F.
    EndIf
	
Return lRet