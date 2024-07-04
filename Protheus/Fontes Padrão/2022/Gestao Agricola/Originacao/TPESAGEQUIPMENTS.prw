#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWequipmentsAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cfields			as CHARACTER
	DATA cError       		as CHARACTER
	DATA cInternalId		as CHARACTER
	DATA cMsgName     		as CHARACTER
	DATA cTipRet	  		as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		  		as OBJECT
	DATA oFieldsJson  		as OBJECT
	DATA oFieldsJsw   		as OBJECT
	DATA oEaiObjSnd   		as OBJECT
	DATA oEaiObjSn2   		as OBJECT
	DATA oEaiObjRec   		as OBJECT

	METHOD NEW()	
	METHOD Getequipments()
	METHOD GetNames()
	METHOD GetNmsW()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Respons�vel instanciar um objeto FWEAIObj e seus devidos atributos. 
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@type function

/*/
Method NEW() CLASS FWequipmentsAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:cfields		   	:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'TPESAG'
	Self:cSelectedFields 	:= ''
	Self:cTipRet		 	:= '' //Tipo de retorno -> 1=Array;2=N�oArray 
	
	self:oFieldsJson  		:= self:GetNames()[1]
	
	self:oEaiObjSnd 		:= FWEAIObj():NEW()
	self:oEaiObjSn2 		:= JsonObject():New()
	self:oEaiObjRec 		:= Nil
	
Return


/*/{Protheus.doc} GetNames
//Respons�vel por setar os atributos ao objeto JSON que ser� retornado na busca.
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@return oFieldsJson, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWequipmentsAdapter
	Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')
	
	oFieldsJson['id']				 := ''
	oFieldsJson['equipmentCode']	 := 'DA3_COD' 
	oFieldsJson['plateNumber']		 := 'DA3_PLACA'  
//	oFieldsJson['resourceType']		 := ??
	oFieldsJson['standardTareWeight']:= 'DA3_TARA'  
	oFieldsJson['typeEquipmentFlag'] := 'DA3_TYPEEQUIPMENT'   // 1 - proprio / 2 - terceiros / 3 - fornecedor / 4 - alugado
	oFieldsJson['availabilityFlag']	 := 'DA3_AVAILABILITY' 	// 1 - disponivel / 2 - n�o dispon�vel / 3 - vendido
	oFieldsJson['operatingVolume']	 := 'DA3_VOLMAX'		

  
return {oFieldsJson}

/*/{Protheus.doc} Getequipments
//Respons�vel por trazer a busca das safras
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@return lRet, l�gico de valida��o
@param cCodId, characters, C�digo �nico do conjunto
@type function
/*/
Method Getequipments(cCodId) CLASS FWequipmentsAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local lFields		as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local nLastRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasDA3 	as CHARACTER
	Local cCodId 	    as CHARACTER
	Local cCod	 	    as CHARACTER
	Local cQuery 	    as CHARACTER
	Local cField		as CHARACTER
	Local cValue		as CHARACTER
	Local aSelFields	as ARRAY
	Local oPage      	as OBJECT
	Local oTempJson    	as OBJECT
	
	aSelFields 	:= NIL
	nJ		 	:= 1
	nX			:= 1
	lRet     	:= .T.
	lFields		:= .F.
	cQuery 	 	:= ''
	cError   	:= ''		
	nCount   	:= 0
	oTempJson	:= &('JsonObject():New()')
	
	if Self:lApi
		if !(EMPTY(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		cAliasDA3 := 'DA3'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('code')
		Else
			cCod := cCodId
		EndIf
		
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasDA3 := aRetAlias[1]
		
		if Self:lOk 
			if self:cTipRet = '1'
				Self:oEaiobjSnd:setBatch(1) //Retorna array
			else
				Self:oEaiobjSnd:setBatch(2) //Retorna um item s�!
			endIf
		endif
		
		if Self:lOk 
			if !EMPTY(self:cSelectedFields)
				aSelFields := StrTokArr( self:cSelectedFields, ",")
				lFields := .T. //ele mandou na URL os campos que quer exibir.
			else
				aSelFields := Self:oFieldsJson:getProperties()
			endIf
		endIf
	endIf
	
	if Self:lOk	
		if self:cTipRet = '1'
			If !(cAliasDA3->(Eof()))					
				While !(cAliasDA3->(EOF()))
					nCount++
					
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						cAliasDA3->(dbskip())
						LOOP
					endIf
					
					For nJ := 1 to Len(aSelFields)
						cField := aSelFields[nJ]
						if cField == 'id'
							cValue := ''
						else
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, cAliasDA3->&(Self:oFieldsJson[cField]))
						endif
						if cValue != NIL
							IF VALTYPE(cValue) = "C"
								Self:oEaiObjSnd:setProp(cField, AllTrim(cValue))
							elseif VALTYPE(cValue) = "N"
								Self:oEaiObjSnd:setProp(cField, cValToChar(cValue))
							EndIf
						Else
							Self:cError := 'O campo "' + cField + '" n�o � valido.' + CRLF
							Self:lOk := .F.
							Return()
						EndIf
					Next nJ			
	
					nLastRec := nCount
					cAliasDA3->(DbSkip())
					
					if !(nCount >= (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())) .AND. !(cAliasDA3->(EOF()))
						Self:oEaiobjSnd:nextItem()
					endif
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
			endIf	
		else		
			if !(cAliasDA3->(EOF()))
				for nJ := 1 to Len(aSelFields)
				
					if aSelFields[nJ] = 'code'
						Self:oEaiObjSn2['code'] := cAliasDA3->&(Self:oFieldsJson['code'])
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, cAliasDA3->&(Self:oFieldsJson[cField]))
						
						if cValue != NIL
							IF VALTYPE(cValue) = "C"
								self:oEaiObjSn2[cField]	:= AllTrim(cValue)
							elseif VALTYPE(cValue) = "N"
								self:oEaiObjSn2[cField]	:= cValToChar(cValue)
							endIf
						else
							Self:cError := 'A propriedade do ' + cField + ' fields  n�o � valida.' + CRLF
							Self:lOk := .F.
							cAliasDA3->(DBCloseArea())
							Return()
						endIf
					endIf
				next nJ				
			else
				Self:cError := 'N�o existe registro com este c�digo.' + CRLF
				Self:lOk	:= .F.
			endIf	
		endIf	
		cAliasDA3->(DBCloseArea())		
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Repons�vel por montar a query de busca no banco de dados
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@return TPESAGSX3, tabela tempor�ria com o resultado da consulta efetuada no BD.
@param cCod, characters, c�digo do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWequipmentsAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasDA3    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasDA3 	:= GetNextAlias()
	cWhere 		:= ""
	cOrder		:= ""
	cValWhe		:= ""
	
	if SELECT(cAliasDA3) > 0
		cAliasDA3->(dbCloseArea())
		cAliasDA3 	:= GetNextAlias()
	endIf
	
	//Pega os atributos que foram passado para o filtro
	oJsonFilter  := Self:oEaiObjRec:getFilter()
	
	if oJsonFilter != Nil
		aTemp := oJsonFilter:getProperties()
		for nX := 1 to len(aTemp)
			cValWhe := aTemp[nX]
			if !Empty(Self:oFieldsJsw[aTemp[nX]])
				cWhere += ' AND '
				if ValType(oJsonFilter[aTemp[nX]]) != "C"
					oJsonFilter[aTemp[nX]] := str(oJsonFilter[aTemp[nX]])
				EndIf
				cWhere += Self:oFieldsJsw[aTemp[nX]] + '=' + "'" + oJsonFilter[aTemp[nX]] + "'"
			Else
				Self:cError += 'A propriedade ' + aTemp[nX] + ' n�o � v�lida para filtro' + CRLF
				lRet := .F.
			EndIf
		next nX		
	
		aTemp := Self:oEaiObjRec:getOrder()
		cOrder := ''
		for nX := 1 to len(aTemp)
			if nX != 1
				cOrder += ','
			Endif
			
			cValOrd := aTemp[nX]
	
			if substr(aTemp[nX],1,1) == '-'
				if !empty(Self:oFieldsJson[substr(aTemp[nX],2)])
					cOrder += Self:oFieldsJson[substr(aTemp[nX],2)] + ' desc'
				Else
					Self:cError += 'A propriedade ' + aTemp[nX] + ' n�o � v�lida para Ordena��o' + CRLF
					lRet := .F.
				EndIf
			Else
				if !Empty(Self:oFieldsJson[cValOrd])
					cOrder += Self:oFieldsJson[aTemp[nX]]
				Else
					Self:cError += 'A propriedade ' + aTemp[nX] + ' n�o � v�lida para Ordena��o' + CRLF
					lRet := .F.
				EndIf
			EndIf
		next nX
	else
		If !Empty(cCod)
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := "and DA3_COD = '" + aRet[1] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('code')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('code'), "|" )
			cWhere := "and DA3_COD = '" + aRet[1] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.

		cQuery1 := "SELECT DA3_COD, DA3_PLACA, DA3_TARA, DA3_VOLMAX, 1 as DA3_TYPEEQUIPMENT, 1 as DA3_AVAILABILITY   "
		cQuery2 := " FROM " + RetSqlName("DA3") + " DA3 "
		cQuery2 += " WHERE D_E_L_E_T_ = ' ' "
		cQuery2 += " " + cWhere + " "
		
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder
		else
			cQuery2 += " ORDER BY DA3_FILIAL, DA3_COD "
		endif
		
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"cAliasDA3",.F.,.T.)
		
		if !EMPTY(cValWhe)
			if GETDATASQL("SELECT  COUNT(*)" + cQuery2) > 1
				self:cTipRet = '1'
			else
				self:cTipRet = '2'
			endIf
		endIf
		
		If !Empty(cCod)
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := "and DA3_COD = '" + aRet[1]
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('code')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('code'), "|" )
			cWhere := "and DA3_COD = '" + aRet[1]
		endIf
		
	else
		Self:lOk := .F.
	EndIf
Return {cAliasDA3}