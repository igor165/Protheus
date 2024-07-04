#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWCottonBalesOnTreadmillsAdapter
	
	DATA lApi        as LOGICAL
	DATA lOk		 as LOGICAL
	
	DATA oModel		  as OBJECT
	DATA oFieldsJson  as OBJECT
	DATA oFieldsJsw   as OBJECT
	DATA oEaiObjSnd   as OBJECT
	DATA oEaiObjSn2   as OBJECT
	DATA oEaiObjRec   as OBJECT

	DATA cError       				as CHARACTER
	DATA cMsgName     				as CHARACTER
	DATA cTipRet	  				as CHARACTER
	DATA cSelectedFields			as CHARACTER

	METHOD NEW()
	
	METHOD GetCottonBalesOnTreadmills()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeCottonBalesOnTreadmill()
	METHOD AlteraCottonBalesOnTreadmill()
	METHOD DeleteCottonBalesOnTreadmill()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author brunosilva
@since 07/12/2018
@version 1.0

@type function
/*/
Method NEW() CLASS FWCottonBalesOnTreadmillsAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cError       := ''
	Self:cMsgName     := 'Vínculo fardão com a esteira'
	Self:cSelectedFields := ''
	Self:cTipRet		 := '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson  := self:GetNames()
	self:oFieldsJsw   := self:GetNmsW()
	
	self:oEaiObjSnd := FWEAIObj():NEW()
	self:oEaiObjSn2 := JsonObject():New()
	self:oEaiObjRec := Nil
	
Return


/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author brunosilva
@since 07/12/2018
@version 1.0
@return oFieldsJson, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWCottonBalesOnTreadmillsAdapter
	Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')

	oFieldsJson['InternalId'] 					:= ''
	oFieldsJson['BranchId'] 					:= 'N71_FILIAL'
	oFieldsJson['Code']							:= 'N71_CODEST'
	oFieldsJson['Crop']							:= 'N71_SAFRA'
	oFieldsJson['AgriculturalOwnerCode']   		:= 'N71_PRODUT'
	oFieldsJson['AgriculturalOwnerStoreCode']	:= 'N71_LOJA'
	oFieldsJson['FarmCode']						:= 'N71_FAZEN'
	oFieldsJson['Order']						:= 'N71_ORDEM'
	oFieldsJson['CottonBaleCode']				:= 'N71_FARDAO'
	oFieldsJson['ProductCode']					:= 'N71_CODPRO'
	oFieldsJson['PartOfLand']					:= 'N71_TALHAO'
	oFieldsJson['Variety']						:= 'N71_VAR'
	oFieldsJson['NetWeight']					:= 'N71_PSLIQU'

return oFieldsJson

Method GetNmsW() CLASS FWCottonBalesOnTreadmillsAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')

	oFieldsJsw['INTERNALID'] 					:= ''
	oFieldsJsw['BRANCHID'] 						:= 'N71_FILIAL'
	oFieldsJsw['CODE']							:= 'N71_CODEST'
	oFieldsJsw['CROP']							:= 'N71_SAFRA'
	oFieldsJsw['AGRICULTURALOWNERCODE']   		:= 'N71_PRODUT'
	oFieldsJsw['AGRICULTURALOWNERSTORECODE']	:= 'N71_LOJA'
	oFieldsJsw['FARMCODE']						:= 'N71_FAZEN'
	oFieldsJsw['ORDER']							:= 'N71_ORDEM'
	oFieldsJsw['COTTONBALECODE']				:= 'N71_FARDAO'
	oFieldsJsw['PRODUCTCODE']					:= 'N71_CODPRO'
	oFieldsJsw['PARTOFLAND']					:= 'N71_TALHAO'
	oFieldsJsw['VARIETY']						:= 'N71_VAR'
	oFieldsJsw['NETWEIGHT']						:= 'N71_PSLIQU'

return oFieldsJsw


/*/{Protheus.doc} GetCottonBalesOnTreadmills
//Responsável por trazer a busca de Un. de beneficamento(s)
@author brunosilva
@since 07/12/2018
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, descricao
@type function
/*/
Method GetCottonBalesOnTreadmills(cCodId) CLASS FWCottonBalesOnTreadmillsAdapter
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasN71 	as CHARACTER
	Local cCodId 	    as CHARACTER
	Local cCod	 	    as CHARACTER
	Local cField		as CHARACTER
	Local cValue		as CHARACTER
	Local aSelFields	as ARRAY
	Local oPage      	as OBJECT
	
	aSelFields 	:= NIL
	nJ		 	:= 1
	lRet     	:= .T.
	cError   	:= ''		
	nCount   	:= 0
	
	if Self:lApi
		if !(EMPTY(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		cAliasN71 := 'N71'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
				
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		cAliasN71 := Self:CreateQuery(cCod)
		
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
			If !((cAliasN71)->(Eof()))
				While !((cAliasN71)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasN71)->(dbskip())
						LOOP
					endIf
					
					for nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'  
							Self:oEaiObjSnd:setProp('InternalId', (cAliasN71)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['Code']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['CottonBaleCode']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['Crop']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['AgriculturalOwnerCode']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['AgriculturalOwnerStoreCode']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['FarmCode']))
						else
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasN71)->&(Self:oFieldsJson[cField]))
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
					
					(cAliasN71)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()
					
					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
			endIf	
			(cAliasN71)->(DBCloseArea())	
			
		else			
			if !((cAliasN71)->(EOF()))
				for nJ := 1 to Len(aSelFields)
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasN71)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['Code']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['CottonBaleCode']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['Crop']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['AgriculturalOwnerCode']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['AgriculturalOwnerStoreCode']) + "|" +  (cAliasN71)->&(Self:oFieldsJson['FarmCode'])
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasN71)->&(Self:oFieldsJson[cField]))
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
			else
				Self:cError := 'Não existe registro com este código.' + CRLF
			endIf
			
		endIf
	
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author brunosilva
@since 07/12/2018
@version 1.0
@return cAliasN71, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWCottonBalesOnTreadmillsAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasN71    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasN71 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	
	if SELECT(cAliasN71) > 0
		(cAliasN71)->(dbCloseArea())
		cAliasN71 	:= GetNextAlias()
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
			cWhere := " N71_FILIAL = '" + aRet[1] + "' AND  N71_CODEST = '" + aRet[2] + "' " + " AND  N71_FARDAO = '" + aRet[3] + "'" + " AND  N71_SAFRA = '" + aRet[4] + "'" + " AND  N71_PRODUT = '" + aRet[5] + "'" + " AND  N71_LOJA = '" + aRet[6] + "'" + " AND  N71_FAZEN = '" + aRet[7] + "'"
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " N71_FILIAL = '" + aRet[1] + "' AND  N71_CODEST = '" + aRet[2] + "' " + " AND  N71_FARDAO = '" + aRet[3] + "'" + " AND  N71_SAFRA = '" + aRet[4] + "'" + " AND  N71_PRODUT = '" + aRet[5] + "'" + " AND  N71_LOJA = '" + aRet[6] + "'" + " AND  N71_FAZEN = '" + aRet[7] + "'"
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "
		
		cQuery2 := " FROM  " + RetSqlName("N71") + " N71"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += " AND D_E_L_E_T_ = ' '  "
		cQuery2 += " AND EXISTS (SELECT * FROM " + RetSqlName("DXL") + " DXL "
		cQuery2 += " WHERE D_E_L_E_T_ = ' ' "
		cQuery2 += " AND DXL_FILIAL = '"+ FWXFILIAL('DXL')+"' "
		cQuery2 += " AND DXL_CODIGO = N71_FARDAO "
		cQuery2 += " AND DXL_SAFRA = N71_SAFRA "
		cQuery2 += " AND DXL_PRDTOR = N71_PRODUT "
		cQuery2 += " AND DXL_LJPRO = N71_LOJA "
		cQuery2 += " AND DXL_FAZ = N71_FAZEN "
		cQuery2 += " AND DXL_RDMTO = 0 "
		cQuery2 += " AND (DXL_STATUS = '3' OR DXL_STATUS = '4' )) "
		
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN71,.F.,.T.)
		
		if !EMPTY(cValWhe)
			if GETDATASQL("SELECT  COUNT(*)" + cQuery2) > 1
				self:cTipRet = '1'
			else
				self:cTipRet = '2'
			endIf
		endIf
	else
		Self:lOk := .F.
	EndIf
	
Return cAliasN71


/*/{Protheus.doc} AlteraCottonBalesOnTreadmill
//Responsável por alterar o registro passado por parametro.
@author brunosilva
@since 07/12/2018
@version 1.0
@return cCodId, código da UBA alterada.

@type function
/*/
Method AlteraCottonBalesOnTreadmill() CLASS FWCottonBalesOnTreadmillsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlN71 		as OBJECT
	Local cCodId		as CHARACTER
	Local cCodFar		as CHARACTER
	Local cCodSaf		as CHARACTER
	Local cProd			as CHARACTER
	Local cPrdLj		as CHARACTER
	Local cFaz			as CHARACTER
	Private lSetOrd		as Logical
	
	lSetOrd		:= .T.
	lRet		:= .T.
	
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	cCodFar		:= iif(EMPTY(Self:oEaiObjRec:getPropValue('CottonBaleCode'))," ",Self:oEaiObjRec:getPropValue('CottonBaleCode'))
	cCodSaf		:= iif(EMPTY(Self:oEaiObjRec:getPropValue('Crop'))," ",Self:oEaiObjRec:getPropValue('Crop'))
	cProd		:= iif(EMPTY(Self:oEaiObjRec:getPropValue('AgriculturalOwnerCode'))," ",Self:oEaiObjRec:getPropValue('AgriculturalOwnerCode'))
	cPrdLj		:= iif(EMPTY(Self:oEaiObjRec:getPropValue('AgriculturalOwnerStoreCode'))," ",Self:oEaiObjRec:getPropValue('AgriculturalOwnerStoreCode'))
	cFaz		:= iif(EMPTY(Self:oEaiObjRec:getPropValue('FarmCode'))," ",Self:oEaiObjRec:getPropValue('FarmCode'))
	
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	DbSelectArea("N70")
	N70->(dbSetOrder( 1 )) //Filial + Codigo
	If N70->(dbSeek( PADR(aRet[1],TamSX3("N71_FILIAL")[1]) + aRet[2]))
		DbSelectArea("N71")
		oModel := FWLoadModel('UBAW020')
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		
		oMdlN71 := oModel:GetModel('N71UBAA020')
		
		/*oMdlN71:AddLine()
		oMdlN71:GoLine(oMdlN71:LENGTH())   */
		
		if lRet
			lRet := oMdlN71:SetValue('N71_FILIAL', PADR(aRet[1],TamSX3("N71_FILIAL")[1]))
		endIf
		
		if lRet
			lRet := oMdlN71:SetValue('N71_CODEST', aRet[2])
		endIf
		
		if lRet 
			lRet := oMdlN71:SetValue('N71_SAFRA', cCodSaf)
		endIf
		
		if lRet 
			lRet := oMdlN71:SetValue('N71_PRODUT', cProd)
		endIf
		
		if lRet 
			lRet := oMdlN71:SetValue('N71_LOJA', cPrdLj)
		endIf
		
		if lRet
			lRet := oMdlN71:SetValue('N71_FAZEN', cFaz)
		endIf
		
		if lRet 
			lRet := oMdlN71:SetValue('N71_FARDAO', cCodFar)
		endIf			
		
		if lRet
			lRet := oMdlN71:SetValue('N71_FILIAL', PADR(aRet[1],TamSX3("N71_FILIAL")[1]))
		endIf
		
		if lRet .and. !EMPTY(Self:oEaiObjRec:getPropValue('ProductCode'))
			lRet := oMdlN71:SetValue('N71_CODPRO', Self:oEaiObjRec:getPropValue('ProductCode'))
		endIf
		
		if lRet .and. !EMPTY(Self:oEaiObjRec:getPropValue('PartOfLand'))
			lRet := oMdlN71:SetValue('N71_TALHAO', Self:oEaiObjRec:getPropValue('PartOfLand'))
		endIf
		
		if lRet .and. !EMPTY(Self:oEaiObjRec:getPropValue('Variety'))
			lRet := oMdlN71:SetValue('N71_VAR', Self:oEaiObjRec:getPropValue('Variety'))
		endIf
		
		if lRet .and. !EMPTY(Self:oEaiObjRec:getPropValue('NetWeight'))
			lRet := oMdlN71:SetValue('N71_PSLIQU', iif(valtype(Self:oEaiObjRec:getPropValue('NetWeight')) != "N",VAL(Self:oEaiObjRec:getPropValue('NetWeight')) , ))
		endIf
				
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()		
			Self:lOk := .T.
			cCodId := cCodId + "|"+ cCodFar
		EndIf
		
		If !oModel:VldData()
			RollBackSX8()
			Self:oEaiObjRec:setError(AGRGMSGERR(oModel:GetErrorMessage()))
			Self:lOk := .F.
			Self:cError := cValToChar(AGRGMSGERR(oModel:GetErrorMessage()))		
		endIf	
		oModel:DeActivate()
	else
		Self:oEaiObjRec:setError("Esteira não encontrada com a chave informada.")
		Self:cError := "Esteira não encontrada com a chave informada."
		Self:lOk := .F.			
	endIf
	
Return cCodId

/*/{Protheus.doc} DeleteCottonBalesOnTreadmill
//Responsável por excluir o registro passado por parâmetro.
@author brunosilva
@since 07/12/2018
@version 1.0
@return cCodId, código da UBA deletada.

@type function
/*/
Method DeleteCottonBalesOnTreadmill() CLASS FWCottonBalesOnTreadmillsAdapter
	Local oModel 		as OBJECT
	Local cCodId		as CHARACTER
	Local cDadFar		as CHARACTER	
	
	cCodId := Self:oEaiObjRec:getPathParam('InternalId')
	
	aRet   := StrTokArr( cCodId, "|" )
	
	cDadFar := Self:CreateQuery(cCodId)

	if !EMPTY(aRet[3])
	dbSelectArea("N71")
		N71->(dbSetOrder( 1 ))
		If N71->(dbSeek( PADR(aRet[1],TamSX3("N71_FILIAL")[1]) + aRet[2] + aRet[3] +  aRet[4] + aRet[5] + aRet[6] + aRet[7]))
			oModel := FWLoadModel('UBAW020')
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
			Self:oEaiObjRec:setError("Fardão nao encontrado não encontrado com o InternalId informado.")
			Self:lOk := .F.
			Self:cError := "Fardão não encontrado com o InternalId informado."
		EndIf
	else
		Self:oEaiObjRec:setError("Parametro incompleto.")
		Self:cError := "Parametro incompleto."
		Self:lOk := .F.
	endIf 
	
Return cCodId
