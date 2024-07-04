#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWEntitiesAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cEntity	  		as CHARACTER
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
	METHOD GetEntities()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeEntity()
	METHOD AlteraEntity()
	METHOD DeleteEntity()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author brunosilva
@since 10/12/2018
@version 1.0

@type function
/*/
Method NEW() CLASS FWEntitiesAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:cEntity	  		:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'Entidade'
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
Method GetNames() CLASS FWEntitiesAdapter
	Local oFieldsJson as OBJECT
	
	oArrayJson := &('JsonObject():New()')
	oFieldsJson := &('JsonObject():New()')

	oFieldsJson['InternalId']   		:= ''
	oFieldsJson['BranchId']				:= 'NJ0_FILIAL'
	oFieldsJson['EntityCode']			:= 'NJ0_CODENT'	
	oFieldsJson['EntityStoreCode']		:= 'NJ0_LOJENT'
	oFieldsJson['EntityName']			:= 'NJ0_NOME'
	oFieldsJson['EntityStoreName']		:= 'NJ0_NOMLOJ'
	oFieldsJson['CNPJEntity']			:= 'NJ0_CGC'
	oFieldsJson['StateRegistration']	:= 'NJ0_INSCR'
	oFieldsJson['Class']				:= 'NJ0_CLASSE'
	oFieldsJson['DAPIncentive']			:= 'NJ0_ITVDAP'
	oFieldsJson['DAPExpirationDate']	:= 'NJ0_DTVDAP'
	oFieldsJson['DAPRegisterNumber']	:= 'NJ0_NUMDAP'
	oFieldsJson['CompanyAndBranchCode']	:= 'NJ0_CODCRP'
	oFieldsJson['ActiveRegister']		:= 'NJ0_ATIVO'
	oFieldsJson['SupplierStoreCode']	:= 'NJ0_LOJFOR'
	oFieldsJson['CustomerCode']			:= 'NJ0_CODCLI'
	oFieldsJson['CustomerStoreCode']	:= 'NJ0_LOJCLI'
	oFieldsJson['CustomsWarehouse']		:= 'NJ0_DEPALF'
	oFieldsJson['IDIntegrationPIMS']	:= 'NJ0_ID'
	
	oArrayJson['BranchId']				:= 'NN0_FILIAL'
	oArrayJson['EntityCode']			:= 'NN0_CODENT'
	oArrayJson['Item']					:= 'NN0_ITEM'
	oArrayJson['BankCode']				:= 'NN0_CODBCO'
	oArrayJson['AgencyCode']			:= 'NN0_CODAGE'
	oArrayJson['AgencyVerifyingDigit'] 	:= 'NN0_DVAGE'
	oArrayJson['AccountCode']			:= 'NN0_CODCTA'
	oArrayJson['AccountVerifyingDigit']	:= 'NN0_DVCTA'
return {oFieldsJson, oArrayJson}


Method GetNmsW() CLASS FWEntitiesAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')

	oFieldsJsw['INTERNALID']   			:= ''
	oFieldsJsw['BRANCHID']				:= 'NJ0_FILIAL'
	oFieldsJsw['ENTITYCODE']			:= 'NJ0_CODENT'
	oFieldsJsw['ENTITYSTORECODE']		:= 'NJ0_LOJENT'
	oFieldsJsw['CNPJENTITY']			:= 'NJ0_CGC'
	oFieldsJsw['STATEREGISTRATION']		:= 'NJ0_INSCR'
	oFieldsJsw['ENTITYNAME']			:= 'NJ0_NOME'
	oFieldsJsw['CLASS']					:= 'NJ0_CLASSE'
	oFieldsJsw['DAPINCENTIVE']			:= 'NJ0_ITVDAP'
	oFieldsJsw['DAPEXPIRATIONDATE']		:= 'NJ0_DTVDAP'
	oFieldsJsw['DAPREGISTERNUMBER']		:= 'NJ0_NUMDAP'
	oFieldsJsw['COMPANYANDBRANCHCODE']	:= 'NJ0_CODCRP'
	oFieldsJsw['COMPANYNAME']			:= 'NJ0_EMPCRP'
	oFieldsJsw['BRANCHNAME']			:= 'NJ0_FILCRP'
	oFieldsJsw['ACTIVEREGISTER']		:= 'NJ0_ATIVO'
	oFieldsJsw['SUPPLIERSTORECODE']		:= 'NJ0_LOJFOR'
	oFieldsJsw['SUPPLIERNAME']			:= 'NJ0_NOMFOR'
	oFieldsJsw['SUPPLIERSTORENAME']		:= 'NJ0_NLJFOR'
	oFieldsJsw['CUSTOMERCODE']			:= 'NJ0_CODCLI'
	oFieldsJsw['CUSTOMERSTORECODE']		:= 'NJ0_LOJCLI'
	oFieldsJsw['CUSTOMERNAME']			:= 'NJ0_NOMCLI'
	oFieldsJsw['CUSTOMERSTORENAME']		:= 'NJ0_NLJCLI'
	oFieldsJsw['CUSTOMSWAREHOUSE']		:= 'NJ0_DEPALF'
	oFieldsJsw['IDINTEGRATIONPIMS']		:= 'NJ0_ID'
return oFieldsJsw


/*/{Protheus.doc} GetEntities
//Responsável por trazer a busca de Un. de beneficamento(s)
@author brunosilva
@since 10/12/2018
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, Código único da entidade
@type function
/*/
Method GetEntities(cCodId) CLASS FWEntitiesAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasNJ0 	as CHARACTER
	Local cAliasNN0 	as CHARACTER
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
		
		cAliasNJ0 := 'NJ0'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
				
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasNJ0 := aRetAlias[1]
		cAliasNN0 := aRetAlias[2]
		
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
			If !((cAliasNJ0)->(Eof()))
				While !((cAliasNJ0)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasNJ0)->(dbskip())
						LOOP
					endIf
					
					for nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasNJ0)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNJ0)->&(Self:oFieldsJson['EntityCode'])  + "|" +  (cAliasNJ0)->&(Self:oFieldsJson['EntityStoreCode']))
						else
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNJ0)->&(Self:oFieldsJson[cField]))
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
					WHILE ((cAliasNN0)->(!Eof())) .AND. (cAliasNN0)->NN0_FILIAL = (cAliasNJ0)->&(Self:oFieldsJson['BranchId']) .AND. (cAliasNN0)->NN0_CODENT = (cAliasNJ0)->&(Self:oFieldsJson['EntityCode'])
					 	Self:oEaiObjSnd:setProp('BankDatas', {})	 
					 		
				 		Self:oEaiObjSnd:getpropvalue('BankDatas')[nX]:setprop('BranchId',	(cAliasNN0)->(NN0_FILIAL))
				 		Self:oEaiObjSnd:getpropvalue('BankDatas')[nX]:setprop('EntityCode',	(cAliasNN0)->(NN0_CODENT))
				 		Self:oEaiObjSnd:getpropvalue('BankDatas')[nX]:setprop('Item',		(cAliasNN0)->(NN0_ITEM))
				 		Self:oEaiObjSnd:getpropvalue('BankDatas')[nX]:setprop('AgencyCode',	(cAliasNN0)->(NN0_CODBCO))
				 		Self:oEaiObjSnd:getpropvalue('BankDatas')[nX]:setprop('AgencyVerifyingDigit',	(cAliasNN0)->(NN0_DVAGE))
				 		Self:oEaiObjSnd:getpropvalue('BankDatas')[nX]:setprop('AccountCode',			(cAliasNN0)->(NN0_CODCTA))
				 		Self:oEaiObjSnd:getpropvalue('BankDatas')[nX]:setprop('AccountVerifyingDigit',	(cAliasNN0)->(NN0_DVCTA))
						
						(cAliasNN0)->(DbSkip())
						nX++							
					end
					
					RestArea(aArea)			
					(cAliasNJ0)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()

					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
			endIf	
			(cAliasNJ0)->(DBCloseArea())	
			(cAliasNN0)->(DBCloseArea())
		else			
			if !((cAliasNJ0)->(EOF()))
				for nJ := 1 to Len(aSelFields)
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasNJ0)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNJ0)->&(Self:oFieldsJson['EntityCode'])  + "|" +  (cAliasNJ0)->&(Self:oFieldsJson['EntityStoreCode'])
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNJ0)->&(Self:oFieldsJson[cField]))
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
				
				oTempJson['item'] := {}
				Aadd(oTempJson["item"], JsonObject():New())
				
				self:oEaiObjSn2['BankDatas'] := {}
				Aadd(self:oEaiObjSn2['BankDatas'], JsonObject():New())
							
				aArea := GetArea()	
				(cAliasNN0)->(dbGoTop())
				nX := 1
				WHILE ((cAliasNN0)->(!Eof())) .AND. (cAliasNN0)->NN0_FILIAL = (cAliasNJ0)->&(Self:oFieldsJson['BranchId']) .AND. (cAliasNN0)->NN0_CODENT = (cAliasNJ0)->&(Self:oFieldsJson['EntityCode'])
				 	if nX != 1
				 		Aadd(self:oEaiObjSn2['BankDatas'], JsonObject():New())
				 	endIf
				 	
				 	self:oEaiObjSn2['BankDatas'][nX]['BranchId']				:= (cAliasNN0)->(NN0_FILIAL)
			 		self:oEaiObjSn2['BankDatas'][nX]['EntityCode']				:= (cAliasNN0)->(NN0_CODENT)
			 		self:oEaiObjSn2['BankDatas'][nX]['Item']					:= (cAliasNN0)->(NN0_ITEM)
			 		self:oEaiObjSn2['BankDatas'][nX]['BankCode']				:= (cAliasNN0)->(NN0_CODBCO)
			 		self:oEaiObjSn2['BankDatas'][nX]['AgencyCode']				:= (cAliasNN0)->(NN0_CODAGE)
			 		self:oEaiObjSn2['BankDatas'][nX]['AgencyVerifyingDigit'] 	:= (cAliasNN0)->(NN0_DVAGE)
			 		self:oEaiObjSn2['BankDatas'][nX]['AccountCode']				:= (cAliasNN0)->(NN0_CODCTA)
			 		self:oEaiObjSn2['BankDatas'][nX]['AccountVerifyingDigit']	:= (cAliasNN0)->(NN0_DVCTA)
					
					(cAliasNN0)->(DbSkip())
					nX++							
				end
			else
				Self:cError := 'Não existe registro com este código.' + CRLF
			endIf
			(cAliasNJ0)->(DBCloseArea())	
			(cAliasNN0)->(DBCloseArea())	
		endIf			
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author brunosilva
@since 10/12/2018
@version 1.0
@return cAliasNJ0, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWEntitiesAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasNJ0    as CHARACTER
	Local cAliasNN0    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cQuery3	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasNJ0 	:= GetNextAlias()
	cAliasNN0 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	
	if SELECT(cAliasNJ0) > 0
		(cAliasNJ0)->(dbCloseArea())
		cAliasNJ0 	:= GetNextAlias()
		if SELECT(cAliasNN0) > 0 
			(cAliasNN0)->(dbCloseArea())
			cAliasNN0 	:= GetNextAlias()
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
			cWhere := " NJ0_FILIAL = '" + aRet[1] + "' AND NJ0_CODENT = '" + aRet[2] + "' AND NJ0_LOJENT = '" + aRet[3] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " NJ0_FILIAL = '" + aRet[1] + "' AND NJ0_CODENT = '" + aRet[2] + "' AND NJ0_LOJENT = '" + aRet[3] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "
		cQuery2 := " FROM  " + RetSqlName("NJ0") + " NJ0"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += "  AND NJ0.D_E_L_E_T_ = ' '"
		
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNJ0,.F.,.T.)
		
		if !EMPTY(cValWhe)
			if GETDATASQL("SELECT  COUNT(*)" + cQuery2) > 1
				self:cTipRet = '1'
			else
				self:cTipRet = '2'
			endIf
		endIf
		
	
		If !Empty(cCod)
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := " NN0_FILIAL = '" + aRet[1] + "' AND NN0_CODENT = '" + aRet[2] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " NN0_FILIAL = '" + aRet[1] + "' AND NN0_CODENT = '" + aRet[2] + "' "
		endIf
		
		cQuery3 := " SELECT  * "
		cQuery3 += " FROM  " + RetSqlName("NN0") + " NN0"
		if !EMPTY(cValWhe)
			cQuery3 += " WHERE NN0.D_E_L_E_T_ = ' '" 
		else
			cQuery3 += " WHERE " + cWhere 
			cQuery3 += " AND NN0.D_E_L_E_T_ = ' '"
		endIf
		
		cQuery3 := ChangeQuery(cQuery3)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery3),cAliasNN0,.F.,.T.)
		
	else
		Self:lOk := .F.
	EndIf
	
Return {cAliasNJ0,cAliasNN0}


/*/{Protheus.doc} IncludeEntity
//Responsável por incluir uma entidade.
@author brunosilva
@since 11/12/2018
@version 1.0
@return cCodId, código da UBA inserida.

@type function
/*/
METHOD IncludeEntity() CLASS FWEntitiesAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlNJ0 		as OBJECT
	Local oMdlNN0 		as OBJECT
	Local cCodId		as CHARACTER
	Local nX			as NUMERIC
	Private lFilLog		as LOGICAL
	
	cCodId 	:= ""
	lRet 	:= .T.
	
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('BranchId')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('BranchId'))
	
		oModel := FWLoadModel('OGA010')
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		
		oMdlNJ0 := oModel:GetModel('NJ0UNICO')
		oMdlNN0 := oModel:GetModel('NN0UNICO')
		
		If lRet //.And. (!Empty(Self:oEaiObjRec:getPropValue('BranchId')) .OR. PADR(Self:oEaiObjRec:getPropValue('BranchId'),TamSX3("NJ0_FILIAL")[1]) = FWxFilial("NJ0"))
			lRet := oMdlNJ0:SetValue('NJ0_FILIAL', FWxFilial("NJ0"))
		else
			lRet := .F.
		EndIf	
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('EntityCode'))
			lRet := oMdlNJ0:SetValue('NJ0_CODENT', Self:oEaiObjRec:getPropValue('EntityCode'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('EntityStoreCode'))
			lRet := oMdlNJ0:SetValue('NJ0_LOJENT', Self:oEaiObjRec:getPropValue('EntityStoreCode'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('EntityName'))
			lRet := oMdlNJ0:SetValue('NJ0_NOME' , Self:oEaiObjRec:getPropValue('EntityName'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('EntityStoreName'))
			lRet := oMdlNJ0:SetValue('NJ0_NOMLOJ' , Self:oEaiObjRec:getPropValue('EntityStoreName'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CNPJEntity'))
			lRet := oMdlNJ0:SetValue('NJ0_CGC' , Self:oEaiObjRec:getPropValue('CNPJEntity'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('StateRegistration'))
			lRet := oMdlNJ0:SetValue('NJ0_INSCR' , Self:oEaiObjRec:getPropValue('StateRegistration'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Class'))
			lRet := oMdlNJ0:SetValue('NJ0_CLASSE' , Self:oEaiObjRec:getPropValue('Class'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('DAPIncentive'))
			lRet := oMdlNJ0:SetValue('NJ0_ITVDAP' , Self:oEaiObjRec:getPropValue('DAPIncentive'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('DAPExpirationDate'))
			lRet := oMdlNJ0:SetValue('NJ0_DTVDAP' , Self:oEaiObjRec:getPropValue('DAPExpirationDate'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('DAPRegisterNumber'))
			lRet := oMdlNJ0:SetValue('NJ0_NUMDAP' , Self:oEaiObjRec:getPropValue('DAPRegisterNumber'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CompanyAndBranchCode'))
			lRet := oMdlNJ0:SetValue('NJ0_CODCRP' , Self:oEaiObjRec:getPropValue('CompanyAndBranchCode'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ActiveRegister'))
			lRet := oMdlNJ0:SetValue('NJ0_ATIVO' , Self:oEaiObjRec:getPropValue('ActiveRegister'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('SupplierStoreCode'))
			lRet := oMdlNJ0:SetValue('NJ0_LOJFOR' , Self:oEaiObjRec:getPropValue('SupplierStoreCode'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CustomerCode'))
			lRet := oMdlNJ0:SetValue('NJ0_CODCLI' , Self:oEaiObjRec:getPropValue('CustomerCode'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CustomerStoreCode'))
			lRet := oMdlNJ0:SetValue('NJ0_LOJCLI' , Self:oEaiObjRec:getPropValue('CustomerStoreCode'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CustomsWarehouse'))
			lRet := oMdlNJ0:SetValue('NJ0_LOJFOR' , Self:oEaiObjRec:getPropValue('CustomsWarehouse'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('SupplierStoreCode'))
			lRet := oMdlNJ0:SetValue('NJ0_DEPALF' , Self:oEaiObjRec:getPropValue('SupplierStoreCode'))
		EndIf
		
		if lRet .AND. !EMPTY(Self:oEaiObjRec:getPropValue('BankDatas'))
			
			Self:oEaiObjRec:GetJson(,.T.)
			For nX := 1 to LEN(Self:oEaiObjRec:getPropValue('BankDatas'))				
				
				if nX != 1
					oMdlNN0:AddLine()
					oMdlNN0:GoLine(oMdlNN0:LENGTH())
					
					lRet := oMdlNN0:LoadValue('NN0_ITEM', "0"+cValToChar(oMdlNN0:LENGTH()))				
				endIf	
				
				lRet := oMdlNN0:LoadValue('NN0_ITEM', "0"+cValToChar(oMdlNN0:LENGTH()))
				
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('BankCode'))
					lRet := oMdlNN0:SetValue('NN0_CODBCO', Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('BankCode'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AgencyCode'))
					lRet := oMdlNN0:SetValue('NN0_CODAGE', Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AgencyCode'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AgencyVerifyingDigit'))
					lRet := oMdlNN0:SetValue('NN0_DVAGE', Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AgencyVerifyingDigit'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AccountCode'))
					lRet := oMdlNN0:SetValue('NN0_CODCTA', Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AccountCode'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AccountVerifyingDigit'))
					lRet := oMdlNN0:SetValue('NN0_DVCTA', Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AccountVerifyingDigit'))
				endIf				
			next nX
		endIf
		 
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()	
			ConfirmSX8()	
			Self:lOk := .T.
			cCodId   := oMdlNJ0:GETVALUE("NJ0_FILIAL") + "|" + oMdlNJ0:GETVALUE("NJ0_CODENT") + "|" + oMdlNJ0:GETVALUE("NJ0_LOJENT")
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
	else
		Self:oEaiObjRec:setError("Filial(BranchId) em branco ou inválida. Favor conferir")
		Self:cError := "Filial(BranchId) em branco ou inválida. Favor conferir."
		Self:lOk := .F.
	endIf	
	
Return cCodId

/*/{Protheus.doc} AlteraEntity
//Responsável por alterar o registro passado por parametro.
@author brunosilva
@since 11/12/2018
@version 1.0
@return cCodId, código da entidade alterada.

@type function
/*/
Method AlteraEntity() CLASS FWEntitiesAdapter
	Local lRet 		 	as LOGICAL	
	Local nX		 	as NUMERIC
	Local oModel 		as OBJECT
	Local oMdlNJ0 		as OBJECT
	Local cCodId		as CHARACTER
	
	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	NJ0->(dbSetOrder( 1 ))
	If NJ0->(dbSeek( aRet[1] + aRet[2] + aRet[3]) ) 
		oModel := FWLoadModel('OGA010')
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		oMdlNJ0 := oModel:GetModel('NJ0UNICO')
		oMdlNN0 := oModel:GetModel('NN0UNICO')
		
		if !Empty(Self:oEaiObjRec:getPropValue('BranchId')) .AND. aRet[1] != Self:oEaiObjRec:getPropValue('BranchId')
			Self:oEaiObjRec:setError("Dados informados no corpo da mensagem não correspondem com o InternalId.")
			Self:lOk := .F.
			Self:cError := "Dados informados no corpo da mensagem não correspondem com o InternalId."
			lRet := .F.
			Return cCodId
		elseif !Empty(Self:oEaiObjRec:getPropValue('EntityCode')) .AND. aRet[2] != Self:oEaiObjRec:getPropValue('EntityCode')
			Self:oEaiObjRec:setError("Dados informados no corpo da mensagem não correspondem com o InternalId.")
			Self:lOk := .F.
			Self:cError := "Dados informados no corpo da mensagem não correspondem com o InternalId."
			lRet := .F.
			Return cCodId	
		endIf		
		
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('Class'))
			lRet := oMdlNJ0:SetValue('NJ0_CLASSE', Self:oEaiObjRec:getPropValue('Description'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('DAPIncentive'))
			lRet := oMdlNJ0:SetValue('NJ0_ITVDAP', Self:oEaiObjRec:getPropValue('DAPIncentive'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('DAPExpirationDate'))
			lRet := oMdlNJ0:SetValue('NJ0_DTVDAP', Self:oEaiObjRec:getPropValue('DAPExpirationDate'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('DAPRegisterNumber'))
			lRet := oMdlNJ0:SetValue('NJ0_NUMDAP', Self:oEaiObjRec:getPropValue('DAPRegisterNumber'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('CompanyAndBranchCode'))
			lRet := oMdlNJ0:SetValue('NJ0_CODCRP', Self:oEaiObjRec:getPropValue('CompanyAndBranchCode'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ActiveRegister'))
			lRet := oMdlNJ0:SetValue('NJ0_ATIVO', Self:oEaiObjRec:getPropValue('ActiveRegister'))
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('CustomsWarehouse'))
			lRet := oMdlNJ0:SetValue('NJ0_DEPALF', Self:oEaiObjRec:getPropValue('CustomsWarehouse'))
		endIf
		if lRet .AND. !EMPTY(Self:oEaiObjRec:getPropValue('BankDatas'))
			if !(EMPTY(Self:oEaiObjRec:getPropValue('BankDatas')[1]:getPropValue('BankCode')))
				For nX := 1 to LEN(Self:oEaiObjRec:getPropValue('BankDatas'))
					
					NN0->(dbSetOrder( 2 ))
					IF !(NN0->(dbSeek(aRet[1] + aRet[2]+ Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('BankCode'))))
						
						lRet := oMdlNN0:LoadValue('NN0_ITEM', "0"+cValToChar(oMdlNN0:LENGTH()))
						
						if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('BankCode'))
							lRet := oMdlNN0:SetValue('NN0_CODBCO', Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('BankCode'))
						endIf
					endIf				
						
					if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AgencyCode'))
						lRet := oMdlNN0:SetValue('NN0_CODAGE', Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AgencyCode'))
					endIf
					if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AgencyVerifyingDigit'))
						lRet := oMdlNN0:SetValue('NN0_DVAGE', Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AgencyVerifyingDigit'))
					endIf
					if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AccountCode'))
						lRet := oMdlNN0:SetValue('NN0_CODCTA', Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AccountCode'))
					endIf
					if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AccountVerifyingDigit'))
						lRet := oMdlNN0:SetValue('NN0_DVCTA', Self:oEaiObjRec:getPropValue('BankDatas')[nX]:getPropValue('AccountVerifyingDigit'))
					endIf				
				next nX
			endIf
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


/*/{Protheus.doc} DeleteCottonGin
//Responsável por excluir o registro passado por parâmetro.
@author brunosilva
@since 11/12/2018
@version 1.0
@return cCodId, código da entidade deletada.

@type function
/*/
Method DeleteEntity() CLASS FWEntitiesAdapter	
	Local oModel 		as OBJECT	
	Local cCodId		as CHARACTER
	
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do DELETE por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	NJ0->(dbSetOrder( 1 ))
	If NJ0->(dbSeek( PADR(aRet[1],TamSX3("NJ0_FILIAL")[1]) + aRet[2] + aRet[3]) ) 
		oModel := FWLoadModel('OGA010')
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
		Self:oEaiObjRec:setError("Entidade não encontrada com o InternalId informado.")
		Self:lOk := .F.
		Self:cError := "Entidade não encontrada com o InternalId informado."
	EndIf  
	
Return cCodId