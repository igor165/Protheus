#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

/*/{Protheus.doc} FWBalesAdapter
@author brunosilva
@since 18/07/2018
@version 1.0

@type class
/*/
CLASS FWBalesAdapter

	DATA lApi        as LOGICAL
	DATA lOk		 as LOGICAL
	
	DATA cError      as CHARACTER	
	DATA cRecno 	 as CHARACTER
	DATA cBranch 	 as CHARACTER
	DATA cBarCode 	 as CHARACTER
	DATA cPack 		 as CHARACTER
	DATA cwarehouse  as CHARACTER
	DATA cMsgName    as CHARACTER
	
	DATA oModel		 as OBJECT
	DATA oBranch     as OBJECT
	DATA oGroup		 as OBJECT
	DATA oFieldsJson as OBJECT
	DATA oEaiObjSnd  as OBJECT
	DATA oEaiObjRec  as OBJECT
	
	METHOD NEW()
	
	METHOD GetBale()
	METHOD GetFieldsNames()
	
	METHOD CreateQuery()

EndClass

/*/{Protheus.doc} GetBale
//Responsável por retornar paginados os registros encontrados.
@author brunosilva
@since 18/07/2018
@version 1.0
@param aQryParam, array, descricao
@type function
/*/
Method GetBale(aQryParam) CLASS FWBalesAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasDXI 	as CHARACTER
	Local cQuery 	    as CHARACTER	
	Local aAreaDXI     	as ARRAY
	Local aArea      	as ARRAY
	Local oPage      	as OBJECT
	
	lRet     := .T.
	aAreaDXI := DXI->(getArea())
	aArea    := getArea()
	cQuery 	 := ''
	cError   := ''	
	nCount   := 0	
	
	if Self:lApi
		if !(EMPTY(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		cAliasDXI := 'DXI'
		
		Self:oEaiObjSnd:Activate()
		
		lNext := .T.
		cAliasDXI:=Self:CreateQuery(aQryParam)
		
		if Self:lOk
			Self:oEaiobjSnd:setBatch(1)
		Endif
	endIf	
	
	If !((cAliasDXI)->(Eof()))
		While !((cAliasDXI)->(EOF()))
			nCount++
			If !(oPage:CanAddLine())
				nMaxRec := nCount
				(cAliasDXI)->(dbskip())
				LOOP
			EndIf
			
			Self:oEaiObjSnd:setProp('id'        	,nCount)
			Self:oEaiObjSnd:setProp('recno'     	,R_E_C_N_O_)
			Self:oEaiObjSnd:setProp('sourcebranch'  ,AllTrim((cAliasDXI)->DXI_FILIAL))
			Self:oEaiObjSnd:setProp('barCode'   	,AllTrim((cAliasDXI)->DXI_ETIQ  ))
			Self:oEaiObjSnd:setProp('pack'      	,AllTrim((cAliasDXI)->DXI_BLOCO ))
			Self:oEaiObjSnd:setProp('warehouse' 	,AllTrim((cAliasDXI)->DXI_LOCAL ))
			Self:oEaiObjSnd:setProp('crop' 			,AllTrim((cAliasDXI)->DXI_SAFRA ))
			
			(cAliasDXI)->(DbSkip())		
			
			Self:oEaiobjSnd:nextItem()
			
			nLastRec := nCount
		endDo
		
		if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
			Self:oEaiobjSnd:setHasNext(.T.)			
		EndIf
		
		Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
		Self:oEaiObjSnd:setProp('maxRecno'  ,nMaxRec)
	endIf
		
	(cAliasDXI)->(DBCloseArea())
Return lRet


/*/{Protheus.doc} CreateQuery
//Responsável por criar a query. Neste momento a query está estática, mas está estruturada e
// poderá ser alterada para receber vários parâmetros.
@author brunosilva
@since 18/07/2018
@version 1.0
@param aQryParam, array, descricao
@type function
/*/
Method CreateQuery(aQryParam) CLASS FWBalesAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere       as CHARACTER
	Local cFields	   as CHARACTER
	Local cFilFard	   as CHARACTER	
	Local aTemp		   as ARRAY

	lRet := .T.

	cAliasDXI 	:= "BaleTmp"

	cFilFard := aQryParam[1]

	cWhere := " DXI_FILIAL = '" + cFilFard + "' AND DXI_BLOCO <> '' AND DXI_EMBFIS = '' AND D_E_L_E_T_ <> '*' " 

	if lRet
		Self:lOk := .T.
		cFields:= '1'
		aTemp := Self:oFieldsJson:getProperties()
		for nX := 1 to len(aTemp)
			cFields += ','
			cFields += Self:oFieldsJson[aTemp[nX]]
		next nX

		cWhere  := '%'+cWhere+'%'
		cFields := '%'+cFields+'%'
		BeginSql alias cAliasDXI
			SELECT %exp:cFields%
			FROM   %table:DXI%
			WHERE %exp:cWhere%
		EndSql
	EndIf
	
Return cAliasDXI


/*/{Protheus.doc} NEW
//Reponsável por instanciar o objeto.
@author brunosilva
@since 18/07/2018
@version 1.0

@type function
/*/
Method NEW() CLASS FWBalesAdapter
	
	Self:lApi	:= .F.
	Self:lOk	:= .F.

	Self:cRecno 	:= ''
	Self:cBranch 	:= ''
	Self:cBarCode 	:= ''
	Self:cPack 		:= ''
	Self:cwarehouse := ''
	Self:cError     := ''
	Self:cMsgName   := 'BALES'

	self:oFieldsJson:= self:GetFieldsNames()
	
	self:oEaiObjSnd := FWEAIObj():NEW()
	self:oEaiObjRec := Nil

return


/*/{Protheus.doc} GetFieldsNames
//Responsável por atribuir os nomes dos cmapos para os atributos JSON
@author brunosilva
@since 18/07/2018
@version 1.0

@type function
/*/
Method GetFieldsNames() CLASS FWBalesAdapter
	Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')

	oFieldsJson['EMBFIS'] 		:= 'DXI_EMBFIS'
	oFieldsJson['SOURCEBRANCH'] := 'DXI_FILIAL'
	oFieldsJson['PACK']			:= 'DXI_BLOCO'
	oFieldsJson['RECNO']		:= 'R_E_C_N_O_'
	oFieldsJson['BARCODE']		:= 'DXI_ETIQ'
	oFieldsJson['WAREHOUSE']	:= 'DXI_LOCAL'	
	oFieldsJson['CROP']			:= 'DXI_SAFRA'

return oFieldsJson