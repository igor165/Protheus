#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWGrainQualityTestKindsAdapter
	
	DATA lApi        				as LOGICAL
	DATA lOk		 				as LOGICAL

	DATA cRecno 	  				as CHARACTER
	DATA cBranch 	  				as CHARACTER
	DATA cCode	 	  				as CHARACTER
	DATA cDescription 				as CHARACTER
	DATA cProductCode				as CHARACTER
	DATA cGrainQualityTestKind	  	as CHARACTER
	DATA cInternalId			  	as CHARACTER
	DATA cMeasurementUnit			as CHARACTER
	DATA cError       				as CHARACTER
	DATA cMsgName     				as CHARACTER
	DATA cTipRet	  				as CHARACTER
	DATA cSelectedFields			as CHARACTER
	
	DATA oModel		  				as OBJECT
	DATA oFieldsJson  				as OBJECT
	DATA oFieldsJsw   				as OBJECT
	DATA oEaiObjSnd   				as OBJECT
	DATA oEaiObjSn2   				as OBJECT
	DATA oEaiObjRec   				as OBJECT

	METHOD NEW()
	
	METHOD GetGrainQualityTestKinds()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeGrainQualityTestKind()
	METHOD AlteraGrainQualityTestKind()
	METHOD DeleteGrainQualityTestKind()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author brunosilva
@since 06/12/2018
@version 1.0

@type function
/*/
Method NEW() CLASS FWGrainQualityTestKindsAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  			:= ''
	Self:cBranch 	  			:= ''
	Self:cCode	 	  			:= ''
	Self:cDescription 			:= ''
	Self:cProductCode  			:= ''
	Self:cGrainQualityTestKind	:= ''
	Self:cMeasurementUnit		:= ''
	Self:cInternalId			:= ''
	Self:cError       			:= ''
	Self:cMsgName     			:= 'Tipo de Classificacao do Grão'
	Self:cSelectedFields 		:= ''
	Self:cTipRet		 		:= '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson  			:= self:GetNames()
	self:oFieldsJsw   			:= self:GetNmsW()
	
	self:oEaiObjSnd 			:= FWEAIObj():NEW()
	self:oEaiObjSn2 			:= JsonObject():New()
	self:oEaiObjRec 			:= Nil
	
Return


/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author brunosilva
@since 06/12/2018
@version 1.0
@return oFieldsJson, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWGrainQualityTestKindsAdapter
	Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')

	oFieldsJson['BranchId'] 		:= 'NNH_FILIAL'
	oFieldsJson['Code']				:= 'NNH_CODIGO'
	oFieldsJson['Description']		:= 'NNH_DESCRI'
	oFieldsJson['ProductCode']		:= 'NNH_CODPRO'
	oFieldsJson['MeasurementUnit']	:= 'NNH_UM1PRO'
	oFieldsJson['InternalId']		:= ''

return oFieldsJson

Method GetNmsW() CLASS FWGrainQualityTestKindsAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')

	oFieldsJsw['BRANCHID']  		:= 'NNH_FILIAL'
	oFieldsJsw['CODE']				:= 'NNH_CODIGO'
	oFieldsJsw['DESCRIPTION']		:= 'NNH_DESCRI'
	oFieldsJsw['PRODUCTCODE']		:= 'NNH_CODPRO'
	oFieldsJsw['MEASUREMENTUNIT']	:= 'NNH_UM1PRO'
	oFieldsJsw['INTERNALID']		:= ''

return oFieldsJsw


/*/{Protheus.doc} GetGrainQualityTestKinds
//Responsável por trazer a busca dos tipo de desconto
@author brunosilva
@since 06/12/2018
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, descricao
@type function
/*/
Method GetGrainQualityTestKinds(cCodId) CLASS FWGrainQualityTestKindsAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasNNH 	as CHARACTER
	Local cCodId 	    as CHARACTER
	Local cCod	 	    as CHARACTER
	Local cQuery 	    as CHARACTER
	Local cField		as CHARACTER
	Local cValue		as CHARACTER
	Local aArea      	as ARRAY
	Local aSelFields	as ARRAY
	Local oPage      	as OBJECT
	
	aSelFields 	:= NIL
	nJ		 	:= 1
	lRet     	:= .T.
	aArea    	:= getArea()
	cQuery 	 	:= ''
	cError   	:= ''		
	nCount   	:= 0
	
	if Self:lApi
		if !(EMPTY(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		cAliasNNH := 'NNH'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
				
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		cAliasNNH := Self:CreateQuery(cCod)
		
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
			If !((cAliasNNH)->(Eof()))
				While !((cAliasNNH)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasNNH)->(dbskip())
						LOOP
					endIf
					
					for nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasNNH)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNNH)->&(Self:oFieldsJson['Code']))
						else
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNNH)->&(Self:oFieldsJson[cField]))
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
					
					(cAliasNNH)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()
					
					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
			endIf	
			(cAliasNNH)->(DBCloseArea())	
			
		else			
			if !((cAliasNNH)->(EOF()))
				for nJ := 1 to Len(aSelFields)
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasNNH)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNNH)->&(Self:oFieldsJson['Code'])
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNNH)->&(Self:oFieldsJson[cField]))
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
@since 06/12/2018
@version 1.0
@return cAliasNNH, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWGrainQualityTestKindsAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasNNH    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasNNH 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	
	if SELECT(cAliasNNH) > 0
		(cAliasNNH)->(dbCloseArea())
		cAliasNNH 	:= GetNextAlias()
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
			cWhere := " NNH_FILIAL = '" + aRet[1] + "' AND  NNH_CODIGO = '" + aRet[2] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " NNH_FILIAL = '" + aRet[1] + "' AND  NNH_CODIGO = '" + aRet[2] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "
		cQuery2 := " FROM  " + RetSqlName("NNH") + " NNH"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += " AND D_E_L_E_T_ = ' '"
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNNH,.F.,.T.)
		
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
	
Return cAliasNNH


/*/{Protheus.doc} IncludeGrainQualityTestKind
//Responsável por incluir um tipo de desconto.
@author brunosilva
@since 06/12/2018
@version 1.0
@return cCodId, código do tipo de desconto inserida.

@type function
/*/
METHOD IncludeGrainQualityTestKind() CLASS FWGrainQualityTestKindsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlNNH 		as OBJECT
	Local cCodId		as CHARACTER
	Local lFilLog		as LOGICAL
	
	cCodId 	:= ""
	lRet 	:= .T.
	
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('BranchId')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('BranchId'))
	
		oModel := FWLoadModel('AGRA030')
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		
		oMdlNNH := oModel:GetModel('NNHUNICO')
		
		If lRet 
			lRet := oMdlNNH:SetValue('NNH_FILIAL', FWxFilial("NNH_FILIAL"))
		else
			lRet := .F.
		EndIf	
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Code'))
			lRet := oMdlNNH:SetValue('NNH_CODIGO', Self:oEaiObjRec:getPropValue('Code'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Description'))
			lRet := oMdlNNH:SetValue('NNH_DESCRI' , Self:oEaiObjRec:getPropValue('Description'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ProductCode'))
			lRet := oMdlNNH:SetValue('NNH_CODPRO' , Self:oEaiObjRec:getPropValue('ProductCode'))
		EndIf
		 
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()	
			ConfirmSX8()	
			Self:lOk := .T.
			cCodId   := oMdlNNH:GETVALUE("NNH_FILIAL") + "|" + oMdlNNH:GETVALUE("NNH_CODIGO")
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
	else
		Self:oEaiObjRec:setError("Filial(Branch) em branco ou inválida. Favor conferir")
		Self:cError := "Filial(Branch) em branco ou inválida. Favor conferir."
		Self:lOk := .F.
	endIf
	
Return cCodId


/*/{Protheus.doc} AlteraGrainQualityTestKind
//Responsável por alterar o registro passado por parametro.
@author brunosilva
@since 06/12/2018
@version 1.0
@return cCodId, código dos tipo de desconto alterado.

@type function
/*/
Method AlteraGrainQualityTestKind() CLASS FWGrainQualityTestKindsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlNNH 		as OBJECT
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	
	cUserBenf 	:= ""
	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	NNH->(dbSetOrder( 1 ))
	If NNH->(dbSeek( aRet[1] + aRet[2]) ) 
		oModel := FWLoadModel('AGRA030')
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		oMdlNNH := oModel:GetModel('NNHUNICO')
		
		if !Empty(Self:oEaiObjRec:getPropValue('BranchId')) .AND. aRet[1] != PADR(Self:oEaiObjRec:getPropValue('BranchId'),TAMSX3("NNH_FILIAL")[1])
			Self:oEaiObjRec:setError("Dados informados no corpo da mensagem não correspondem com o InternalId.")
			Self:lOk := .F.
			Self:cError := "Dados informados no corpo da mensagem não correspondem com o InternalId."
			lRet := .F.
			Return cCodId
		elseif !Empty(Self:oEaiObjRec:getPropValue('Code')) .AND. aRet[2] != Self:oEaiObjRec:getPropValue('Code')
			Self:oEaiObjRec:setError("Dados informados no corpo da mensagem não correspondem com o InternalId.")
			Self:lOk := .F.
			Self:cError := "Dados informados no corpo da mensagem não correspondem com o InternalId."
			lRet := .F.
			Return cCodId	
		endIf		
		
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('Description'))
			lRet := oMdlNNH:SetValue('NNH_DESCRI', Self:oEaiObjRec:getPropValue('Description'))
		endIf
		
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ProductCode'))
			lRet := oMdlNNH:SetValue('NNH_CODPRO', Self:oEaiObjRec:getPropValue('ProductCode'))
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
		Self:oEaiObjRec:setError("Tipo de desconto da classificação não encontrada com a chave informada.")
		Self:lOk := .F.
		Self:cError := "Tipo de desconto da classificação não encontrada com a chave informada."
	EndIf
	
Return cCodId

/*/{Protheus.doc} DeleteGrainQualityTestKind
//Responsável por excluir o registro passado por parâmetro.
@author brunosilva
@since 06/12/2018
@version 1.0
@return cCodId, código dos tipo de desconto deletado.

@type function
/*/
Method DeleteGrainQualityTestKind() CLASS FWGrainQualityTestKindsAdapter
	Local oModel 		as OBJECT
	Local cCodId		as CHARACTER
	
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do DELETE por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	NNH->(dbSetOrder( 1 ))
	If NNH->(dbSeek( PADR(aRet[1],TamSX3("NNH_FILIAL")[1]) + aRet[2]) ) 
		oModel := FWLoadModel('AGRA030')
		oModel:SetOperation( MODEL_OPERATION_DELETE )
		oModel:Activate()
		If oModel:VldData()		
			oModel:CommitData()		
			Self:lOk := .T.
		Else
			AGRGMSGERR(oModel:GetErrorMessage())
			Self:oEaiObjRec:setError(AGRGMSGERR(oModel:GetErrorMessage()))
			Self:cError := cValToChar(AGRGMSGERR(oModel:GetErrorMessage()))
			Self:lOk := .F.
		EndIf
		oModel:DeActivate()
	Else
		Self:oEaiObjRec:setError("Tipo de desconto da classificação não encontrado com o InternalId informado.")
		Self:cError := "Tipo de desconto da classificação não encontrado com o InternalId informado."
		Self:lOk := .F.
	EndIf  
	
Return cCodId