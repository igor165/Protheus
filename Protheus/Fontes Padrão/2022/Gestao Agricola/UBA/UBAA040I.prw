#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWContaminantsAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cContaminant	  	as CHARACTER
	DATA cError       		as CHARACTER
	DATA cInternalId		as CHARACTER
	DATA cMsgName     		as CHARACTER
	DATA cTipRet	  		as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		  		as OBJECT
	DATA oFieldsJson  		as OBJECT
	DATA oArrayJson  		as OBJECT
	DATA oFieldsJsw   		as OBJECT
	DATA oEaiObjSnd   		as OBJECT
	DATA oEaiObjSn2   		as OBJECT
	DATA oEaiObjRec   		as OBJECT

	METHOD NEW()	
	METHOD GetContaminants()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeContaminant()
	METHOD AlteraContaminant()
	METHOD DeleteContaminant()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author brunosilva
@since 10/12/2018
@version 1.0

@type function
/*/
Method NEW() CLASS FWContaminantsAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:cContaminant	  	:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'Contaminantes'
	Self:cSelectedFields 	:= ''
	Self:cTipRet		 	:= '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson  		:= self:GetNames()[1]
	self:oArrayJson	  		:= self:GetNames()[2]
	self:oFieldsJsw   		:= self:GetNmsW()
	
	self:oEaiObjSnd 		:= FWEAIObj():NEW()
	self:oEaiObjSn2 		:= JsonObject():New()
	self:oEaiObjRec 		:= Nil
	
Return


/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author brunosilva
@since 10/12/2018
@version 1.0
@return oFieldsJson, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWContaminantsAdapter
	Local oFieldsJson as OBJECT
	
	oArrayJson := &('JsonObject():New()')
	oFieldsJson := &('JsonObject():New()')

	oFieldsJson['InternalId']   		:= ''
	oFieldsJson['BranchId']				:= 'N76_FILIAL'
	oFieldsJson['Code']					:= 'N76_CODIGO'
	oFieldsJson['Name']					:= 'N76_NMCON'
	oFieldsJson['Description']			:= 'N76_DESCON'
	oFieldsJson['Status']				:= 'N76_SITCON'
	oFieldsJson['ResultType']			:= 'N76_TPCON'
	oFieldsJson['ResultSize']			:= 'N76_TMCON'
	oFieldsJson['ResultPrecision']		:= 'N76_VLPRC'
	oFieldsJson['WSAvailable']			:= 'N76_DISPWS'
	oFieldsJson['PropagationLevel']		:= 'N76_NIVPRO'
	oFieldsJson['InclusionDate']		:= 'N76_DATINC'
	oFieldsJson['InclusionHour']		:= 'N76_HORINC'
	oFieldsJson['UpdateDate']			:= 'N76_DATATU'
	oFieldsJson['UpdateHour']			:= 'N76_HORATU'
	
	oArrayJson['BranchId']				:= 'N77_FILIAL'	
	oArrayJson['Code']					:= 'N77_CODCTM'
	oArrayJson['Sequence']				:= 'N77_SEQ'
	oArrayJson['Result']				:= 'N77_RESULT'
	oArrayJson['StartRange']			:= 'N77_FAIINI'
	oArrayJson['EndRange']				:= 'N77_FAIFIM'
	oArrayJson['InclusionDateValue']	:= 'N77_DATINC'
	oArrayJson['InclusionHourValue']	:= 'N77_HORINC'
	oArrayJson['UpdateDateValue']		:= 'N77_DATATU' 
	oArrayJson['UpdateHourValue']		:= 'N77_HORATU' 
return {oFieldsJson, oArrayJson}


Method GetNmsW() CLASS FWContaminantsAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')

	oFieldsJsw['INTERNALID']   		:= ''
	oFieldsJsw['BRANCHID']			:= 'N76_FILIAL'
	oFieldsJsw['CODE']				:= 'N76_CODIGO'
	oFieldsJsw['NAME']				:= 'N76_NMCON'
	oFieldsJsw['DESCRIPTION']		:= 'N76_DESCON'
	oFieldsJsw['STATUS']			:= 'N76_SITCON'
	oFieldsJsw['RESULTTYPE']		:= 'N76_TPCON'
	oFieldsJsw['RESULTSIZE']		:= 'N76_TMCON'
	oFieldsJsw['RESULTPRECISION']	:= 'N76_VLPRC'
	oFieldsJsw['WSAVAILABLE']		:= 'N76_DISPWS'
	oFieldsJsw['PROPAGATIONLEVEL']	:= 'N76_NIVPRO'
	oFieldsJsw['INCLUSIONDATE']		:= 'N76_DATINC'
	oFieldsJsw['INCLUSIONHOUR']		:= 'N76_HORINC'
	oFieldsJsw['UPDATEDATE']		:= 'N76_DATATU'
	oFieldsJsw['UPDATEHOUR']		:= 'N76_HORATU'
return oFieldsJsw


/*/{Protheus.doc} GetContaminants
//Responsável por buscar os contaminantes
@author brunosilva
@since 10/12/2018
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, Código único do contaminante
@type function
/*/
Method GetContaminants(cCodId) CLASS FWContaminantsAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasN76 	as CHARACTER
	Local cAliasN77 	as CHARACTER
	Local cCodId 	    as CHARACTER
	Local cCod	 	    as CHARACTER
	Local cQuery 	    as CHARACTER
	Local cField		as CHARACTER
	Local cValue		as CHARACTER
	Local aArea      	as ARRAY
	Local aSelFields	as ARRAY
	Local oPage      	as OBJECT
	Local oTempJson    	as OBJECT
	
	aSelFields 	:= NIL
	nJ		 	:= 1
	nX			:= 1
	lRet     	:= .T.
	cQuery 	 	:= ''
	cError   	:= ''		
	nCount   	:= 0
	oTempJson	:= &('JsonObject():New()')
	
	if Self:lApi
		if !(EMPTY(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		cAliasN76 := 'N76'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
				
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasN76 := aRetAlias[1]
		cAliasN77 := aRetAlias[2]
		
		if Self:lOk 
			if self:cTipRet = '1'
				Self:oEaiobjSnd:setBatch(1) //Retorna array
			else
				Self:oEaiobjSnd:setBatch(2) //Retorna um item só!
			endIf
		endif
		
		if Self:lOk 
			if !EMPTY(self:cSelectedFields)
				aSelFields := StrTokArr( self:cSelectedFields, ",")
			else
				aSelFields := Self:oFieldsJson:getProperties()
			endIf
		endIf
	endIf
		
	if Self:lOk	
		if self:cTipRet = '1'
			If !((cAliasN76)->(Eof()))
				While !((cAliasN76)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasN76)->(dbskip())
						LOOP
					endIf
					
					for nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasN76)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasN76)->&(Self:oFieldsJson['Code']))
						else
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasN76)->&(Self:oFieldsJson[cField]))
							if cValue != NIL
								IF VALTYPE(cValue) = "C"
									Self:oEaiObjSnd:setProp(cField, AllTrim(cValue))
								elseif VALTYPE(cValue) = "N"
									Self:oEaiObjSnd:setProp(cField, cValToChar(cValue))
								endIf
							else
								Self:cError := 'O campo "' + cField + '" não é valido.' + CRLF
								Self:lOk := .F.
								Return()
							endIf
						endIf
					next nJ		
					
					aArea := GetArea()	
						
					nX := 1
					WHILE ((cAliasN77)->(!Eof())) .AND. (cAliasN77)->N77_FILIAL = (cAliasN76)->&(Self:oFieldsJson['BranchId']) .AND. (cAliasN77)->N77_CODCTM = (cAliasN76)->&(Self:oFieldsJson['Code'])
					 	Self:oEaiObjSnd:setProp('ListOfContaminantValues', {})	 
					 		
				 		Self:oEaiObjSnd:getpropvalue('ListOfContaminantValues')[nX]:setprop('BranchId',				(cAliasN77)->(N77_FILIAL))
				 		Self:oEaiObjSnd:getpropvalue('ListOfContaminantValues')[nX]:setprop('Code',					(cAliasN77)->(N77_CODCTM))
				 		Self:oEaiObjSnd:getpropvalue('ListOfContaminantValues')[nX]:setprop('Sequence',				(cAliasN77)->(N77_SEQ))
				 		Self:oEaiObjSnd:getpropvalue('ListOfContaminantValues')[nX]:setprop('Result',				(cAliasN77)->(N77_RESULT))
				 		Self:oEaiObjSnd:getpropvalue('ListOfContaminantValues')[nX]:setprop('StartRange',			(cAliasN77)->(N77_FAIINI))
				 		Self:oEaiObjSnd:getpropvalue('ListOfContaminantValues')[nX]:setprop('EndRange',				(cAliasN77)->(N77_FAIFIM))
				 		Self:oEaiObjSnd:getpropvalue('ListOfContaminantValues')[nX]:setprop('InclusionDateValue',	(cAliasN77)->(N77_DATINC))
				 		Self:oEaiObjSnd:getpropvalue('ListOfContaminantValues')[nX]:setprop('InclusionHourValue',	(cAliasN77)->(N77_HORINC))
				 		Self:oEaiObjSnd:getpropvalue('ListOfContaminantValues')[nX]:setprop('UpdateDateValue',		(cAliasN77)->(N77_DATATU))
				 		Self:oEaiObjSnd:getpropvalue('ListOfContaminantValues')[nX]:setprop('UpdateHourValue',		(cAliasN77)->(N77_HORATU))
				 		
						
						(cAliasN77)->(DbSkip())
						nX++							
					end
					
					RestArea(aArea)			
					(cAliasN76)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()

					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
			endIf	
			(cAliasN76)->(DBCloseArea())	
			(cAliasN77)->(DBCloseArea())
		else			
			if !((cAliasN76)->(EOF()))
				for nJ := 1 to Len(aSelFields)
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasN76)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasN76)->&(Self:oFieldsJson['Code']) 
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasN76)->&(Self:oFieldsJson[cField]))
						if cValue != NIL
							IF VALTYPE(cValue) = "C"
								self:oEaiObjSn2[cField]	:= AllTrim(cValue)
							elseif VALTYPE(cValue) = "N"
								self:oEaiObjSn2[cField]	:= cValToChar(cValue)
							endIf
						else
							Self:cError := 'A propriedade do ' + cField + ' fields  não é valida.' + CRLF
							Self:lOk := .F.
							Return()
						endIf
					endIf
				next nJ
				
				self:oEaiObjSn2['ListOfContaminantValues'] := {}
				Aadd(self:oEaiObjSn2['ListOfContaminantValues'], JsonObject():New())
							
				aArea := GetArea()	
				(cAliasN77)->(dbGoTop())
				nX := 1
				WHILE ((cAliasN77)->(!Eof())) .AND. (cAliasN77)->N77_FILIAL = (cAliasN76)->&(Self:oFieldsJson['BranchId']) .AND. (cAliasN77)->N77_CODCTM = (cAliasN76)->&(Self:oFieldsJson['Code'])
				 	if nX != 1
				 		Aadd(self:oEaiObjSn2['ListOfContaminantValues'], JsonObject():New())
				 	endIf
				 	
				 	self:oEaiObjSn2['ListOfContaminantValues'][nX]['BranchId']				:= (cAliasN77)->(N77_FILIAL)
			 		self:oEaiObjSn2['ListOfContaminantValues'][nX]['Code']					:= (cAliasN77)->(N77_CODCTM)
			 		self:oEaiObjSn2['ListOfContaminantValues'][nX]['Sequence']				:= (cAliasN77)->(N77_SEQ)
			 		self:oEaiObjSn2['ListOfContaminantValues'][nX]['Result']				:= (cAliasN77)->(N77_RESULT)
			 		self:oEaiObjSn2['ListOfContaminantValues'][nX]['StartRange']			:= (cAliasN77)->(N77_FAIINI)
			 		self:oEaiObjSn2['ListOfContaminantValues'][nX]['EndRange'] 				:= (cAliasN77)->(N77_FAIFIM)
			 		self:oEaiObjSn2['ListOfContaminantValues'][nX]['InclusionDateValue']	:= (cAliasN77)->(N77_DATINC)
			 		self:oEaiObjSn2['ListOfContaminantValues'][nX]['InclusionHourValue']	:= (cAliasN77)->(N77_HORINC)
			 		self:oEaiObjSn2['ListOfContaminantValues'][nX]['UpdateDateValue']		:= (cAliasN77)->(N77_DATATU)
			 		self:oEaiObjSn2['ListOfContaminantValues'][nX]['UpdateHourValue']		:= (cAliasN77)->(N77_HORATU)
					
					(cAliasN77)->(DbSkip())
					nX++							
				end
			else
				Self:cError := 'Não existe registro com este código.' + CRLF
			endIf
			(cAliasN76)->(DBCloseArea())	
			(cAliasN77)->(DBCloseArea())	
		endIf			
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author brunosilva
@since 12/12/2018
@version 1.0
@return cAliasN76, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWContaminantsAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasN76    as CHARACTER
	Local cAliasN77    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cQuery3	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasN76 	:= GetNextAlias()
	cAliasN77 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	
	if SELECT(cAliasN76) > 0
		(cAliasN76)->(dbCloseArea())
		cAliasN76 	:= GetNextAlias()
		if SELECT(cAliasN77) > 0 
			(cAliasN77)->(dbCloseArea())
			cAliasN77 	:= GetNextAlias()
		endIf
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
				Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para filtro' + CRLF
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
					Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
					lRet := .F.
				EndIf
			Else
				if !Empty(Self:oFieldsJson[cValOrd])
					cOrder += Self:oFieldsJson[aTemp[nX]]
				Else
					Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
					lRet := .F.
				EndIf
			EndIf
		next nX
	else
		If !Empty(cCod)
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := " N76_FILIAL = '" + aRet[1] + "' AND N76_CODIGO = '" + aRet[2] + "'"
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " N76_FILIAL = '" + aRet[1] + "' AND N76_CODIGO = '" + aRet[2] + "'"
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "
		cQuery2 := " FROM  " + RetSqlName("N76") + " N76"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += "  AND N76.D_E_L_E_T_ = ' '"
		
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN76,.F.,.T.)
		
		if !EMPTY(cValWhe)
			if GETDATASQL("SELECT  COUNT(*)" + cQuery2) > 1
				self:cTipRet = '1'
			else
				self:cTipRet = '2'
			endIf
		endIf
		
	
		If !Empty(cCod)
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := " N77_FILIAL = '" + aRet[1] + "' AND N77_CODCTM = '" + aRet[2] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " N77_FILIAL = '" + aRet[1] + "' AND N77_CODCTM = '" + aRet[2] + "' "
		endIf
		
		cQuery3 := " SELECT  * "
		cQuery3 += " FROM  " + RetSqlName("N77") + " N77"
		if !EMPTY(cValWhe)
			cQuery3 += " WHERE N77.D_E_L_E_T_ = ' '" 
		else
			cQuery3 += " WHERE " + cWhere 
			cQuery3 += " AND N77.D_E_L_E_T_ = ' '"
		endIf
		
		cQuery3 := ChangeQuery(cQuery3)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery3),cAliasN77,.F.,.T.)
		
	else
		Self:lOk := .F.
	EndIf
	
Return {cAliasN76,cAliasN77}


/*/{Protheus.doc} IncludeContaminant
//Responsável por incluir um contaminante.
@author brunosilva
@since 12/12/2018
@version 1.0
@return cCodId, código do contaminante inserido.

@type function
/*/
METHOD IncludeContaminant() CLASS FWContaminantsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlN76 		as OBJECT
	Local oMdlN77 		as OBJECT
	Local cCodId		as CHARACTER
	Local nX			as NUMERIC
    Private _nTamTemp	as Logical
    Private _nPrecTemp	as Logical
	
	_nTamTemp	:= Nil
	_nPrecTemp	:= Nil
	
	cCodId 	:= ""
	lRet 	:= .T.
	
	oModel := FWLoadModel('UBAA040')
	oModel:SetOperation( MODEL_OPERATION_INSERT )
	oModel:Activate()
	
	oMdlN76 := oModel:GetModel('MdFieldN76')
	oMdlN77 := oModel:GetModel('MdGrdN77Lt')
	
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('BranchId')) 
		lRet := oMdlN76:SetValue('N76_FILIAL', Self:oEaiObjRec:getPropValue('BranchId'))
	else
		lRet := .F.
	EndIf	
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Code'))
		lRet := oMdlN76:SetValue('N76_CODIGO', Self:oEaiObjRec:getPropValue('Code'))
	else
		lRet := .F.
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Name'))
		lRet := oMdlN76:SetValue('N76_NMCON', Self:oEaiObjRec:getPropValue('Name'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Description'))
		lRet := oMdlN76:SetValue('N76_DESCON' , Self:oEaiObjRec:getPropValue('Description'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Status'))
		lRet := oMdlN76:SetValue('N76_SITCON' , Self:oEaiObjRec:getPropValue('Status'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ResultType'))
		lRet := oMdlN76:SetValue('N76_TPCON' , Self:oEaiObjRec:getPropValue('ResultType'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ResultSize'))
		lRet := oMdlN76:SetValue('N76_TMCON' , Self:oEaiObjRec:getPropValue('ResultSize'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ResultPrecision'))
		lRet := oMdlN76:SetValue('N76_VLPRC' , Self:oEaiObjRec:getPropValue('ResultPrecision'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('WSAvailable'))
		lRet := oMdlN76:SetValue('N76_DISPWS' , Self:oEaiObjRec:getPropValue('WSAvailable'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('PropagationLevel'))
		lRet := oMdlN76:SetValue('N76_NIVPRO' , Self:oEaiObjRec:getPropValue('PropagationLevel'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('InclusionDate'))
		lRet := oMdlN76:SetValue('N76_DATINC' , Self:oEaiObjRec:getPropValue('InclusionDate'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('InclusionHour'))
		lRet := oMdlN76:SetValue('N76_HORINC' , Self:oEaiObjRec:getPropValue('InclusionHour'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('UpdateDate'))
		lRet := oMdlN76:SetValue('N76_DATATU' , Self:oEaiObjRec:getPropValue('UpdateDate'))
	EndIf
	If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('UpdateHour'))
		lRet := oMdlN76:SetValue('N76_HORATU' , Self:oEaiObjRec:getPropValue('UpdateHour'))
	EndIf
	
	if lRet .AND. !EMPTY(Self:oEaiObjRec:getPropValue('ListOfContaminantValues'))
		
		Self:oEaiObjRec:GetJson(,.T.)
		For nX := 1 to LEN(Self:oEaiObjRec:getPropValue('ListOfContaminantValues'))				
			
			if nX != 1
				oMdlN77:AddLine()
				oMdlN77:GoLine(oMdlN77:LENGTH())
				
				lRet := oMdlN77:LoadValue('N77_SEQ', "0"+cValToChar(oMdlN77:LENGTH()))				
			endIf	
			
			lRet := oMdlN77:LoadValue('N77_SEQ', "0"+cValToChar(oMdlN77:LENGTH()))
			
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('BranchId'))
				lRet := oMdlN77:SetValue('N77_FILIAL', Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('BranchId'))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('Result'))
				lRet := oMdlN77:SetValue('N77_RESULT', Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('Result'))
			endIf	
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('StartRange'))
				lRet := oMdlN77:SetValue('N77_FAIINI', Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('StartRange'))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('EndRange'))
				lRet := oMdlN77:SetValue('N77_FAIFIM', Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('EndRange'))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('InclusionDateValue'))
				lRet := oMdlN77:SetValue('N77_DATINC', Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('InclusionDateValue'))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('InclusionHourValue'))
				lRet := oMdlN77:SetValue('N77_HORINC', Self:oEaiObjRec:getPropValue('ListOfContaminantValues')[nX]:getPropValue('InclusionHourValue'))
			endIf				
		next nX
	endIf
	 
	If lRet .And. oModel:VldData()		
		lRet := oModel:CommitData()	
		ConfirmSX8()	
		Self:lOk := .T.
		cCodId   := oMdlN76:GETVALUE("N76_FILIAL") + "|" + oMdlN76:GETVALUE("N76_CODIGO")
	EndIf
	If !oModel:VldData()
		RollBackSX8()
		Self:oEaiObjRec:setError(AGRGMSGERR(oModel:GetErrorMessage()))
		Self:cError := cValToChar(AGRGMSGERR(oModel:GetErrorMessage()))
		Self:lOk := .F.
	Elseif !lRet .and. oModel:VldData() 
		RollBackSX8()
		Self:oEaiObjRec:setError("Verifique se todos os campos obrigatórios estão preenchidos.")
		Self:cError := "Verifique se todos os campos obrigatórios estão preenchidos."
		Self:lOk := .F.
	endIf	
	
Return cCodId

/*/{Protheus.doc} AlteraContaminant
//Responsável por alterar o registro passado por parametro.
@author brunosilva
@since 12/12/2018
@version 1.0
@return cCodId, código do contaminante alterada.

@type function
/*/
Method AlteraContaminant() CLASS FWContaminantsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlN76 		as OBJECT
	Local cCodId		as CHARACTER
	
	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	N76->(dbSetOrder( 1 ))
	If N76->(dbSeek( aRet[1] + aRet[2])) 
		oModel := FWLoadModel('UBAA040')
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		
		oMdlN76 := oModel:GetModel('MdFieldN76')		
		
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('Name'))
			lRet := oMdlN76:SetValue('N76_NMCON', Self:oEaiObjRec:getPropValue('Name'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('Description'))
			lRet := oMdlN76:SetValue('N76_DESCON', Self:oEaiObjRec:getPropValue('Description'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('Status'))
			lRet := oMdlN76:SetValue('N76_SITCON', Self:oEaiObjRec:getPropValue('Status'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('WSAvailable'))
			lRet := oMdlN76:SetValue('N76_DISPWS', Self:oEaiObjRec:getPropValue('WSAvailable'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('PropagationLevel'))
			lRet := oMdlN76:SetValue('N76_NIVPRO', Self:oEaiObjRec:getPropValue('PropagationLevel'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('UpdateDate'))
			lRet := oMdlN76:SetValue('N76_DATATU', Self:oEaiObjRec:getPropValue('UpdateDate'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('UpdateHour'))
			lRet := oMdlN76:SetValue('N76_HORATU', Self:oEaiObjRec:getPropValue('UpdateHour'))
		endIf				
				
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()		
			Self:lOk := .T.
		EndIf
		
		If !oModel:VldData()
			RollBackSX8()
			Self:oEaiObjRec:setError(AGRGMSGERR(oModel:GetErrorMessage()))
			Self:lOk := .F.
			Self:cError := cValToChar(AGRGMSGERR(oModel:GetErrorMessage()))
		Elseif !lRet .and. oModel:VldData() 
			RollBackSX8()
			Self:oEaiObjRec:setError("Verifique se todos os campos estão preenchidos.")
			Self:lOk := .F.
			Self:cError := "Verifique se todos os campos estão preenchidos."
		endIf	
		oModel:DeActivate()
	Else
		Self:oEaiObjRec:setError("Entidade não encontrada com a chave informada.")
		Self:lOk := .F.
		Self:cError := "Entidade de beneficiamento não encontrada com a chave informada."
	EndIf
	
Return cCodId


/*/{Protheus.doc} DeleteContaminant
//Responsável por excluir o registro passado por parâmetro.
@author brunosilva
@since 12/12/2018
@version 1.0
@return cCodId, código do contaminante deletada.

@type function
/*/
Method DeleteContaminant() CLASS FWContaminantsAdapter
	Local oModel 		as OBJECT
	Local cCodId		as CHARACTER
	
	cCodId := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do DELETE por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	N76->(dbSetOrder( 1 ))
	If N76->(dbSeek( PADR(aRet[1],TamSX3("N76_FILIAL")[1]) + aRet[2] )) 
		oModel := FWLoadModel('UBAA040')
		oModel:SetOperation( MODEL_OPERATION_DELETE )
		oModel:Activate()
		If oModel:VldData()		
			oModel:CommitData()		
			Self:lOk := .T.
		Else
			AGRGMSGERR(oModel:GetErrorMessage())
			Self:oEaiObjRec:setError(AGRGMSGERR(oModel:GetErrorMessage()))
			Self:lOk := .F.
			Self:cError := cValToChar(AGRGMSGERR(oModel:GetErrorMessage()))
		EndIf
		oModel:DeActivate()
	Else
		Self:oEaiObjRec:setError("Contaminante não encontrado com o InternalId informado.")
		Self:lOk := .F.
		Self:cError := "Contaminante não encontrado com o InternalId informado."
	EndIf  
	
Return cCodId