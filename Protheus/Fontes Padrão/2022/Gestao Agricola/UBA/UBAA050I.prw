#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWCottonPoisoningPointingsAdapter
	
	DATA lApi        					as LOGICAL
	DATA lOk		 					as LOGICAL

	DATA cRecno 	  					as CHARACTER
	DATA cBranch 	  					as CHARACTER
	DATA cCode	 	  					as CHARACTER
	DATA cDescription 					as CHARACTER
	DATA cCottonPoisoningPointings	  	as CHARACTER
	DATA cError       					as CHARACTER
	DATA cInternalId					as CHARACTER
	DATA cMsgName     					as CHARACTER
	DATA cTipRet	  					as CHARACTER
	DATA cSelectedFields				as CHARACTER
	
	DATA oModel		  as OBJECT
	DATA oFieldsJson  as OBJECT
	DATA oFieldsJsw   as OBJECT
	DATA oEaiObjSnd   as OBJECT
	DATA oEaiObjSn2   as OBJECT
	DATA oEaiObjRec   as OBJECT

	METHOD NEW()
	
	METHOD GetCottonPoisoningPointings()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeCottonPoisoningPointing()
	METHOD AlteraCottonPoisoningPointing()
	METHOD DeleteCottonPoisoningPointing()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author brunosilva
@since 12/12/2018
@version 1.0

@type function
/*/
Method NEW() CLASS FWCottonPoisoningPointingsAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  				:= ''
	Self:cBranch 	  				:= ''
	Self:cCode	 	  				:= ''
	Self:cDescription 				:= ''
	Self:cCottonPoisoningPointings	:= ''
	Self:cInternalId  				:= ''
	Self:cError       				:= ''
	Self:cMsgName    				:= 'Apontamento de contaminantes para algodao'
	Self:cSelectedFields 			:= ''
	Self:cTipRet		 			:= '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson  	:= self:GetNames()
	self:oFieldsJsw   	:= self:GetNmsW()
	
	self:oEaiObjSnd 	:= FWEAIObj():NEW()
	self:oEaiObjSn2 	:= JsonObject():New()
	self:oEaiObjRec 	:= Nil
	
Return


/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author brunosilva
@since 12/12/2018
@version 1.0
@return oFieldsJson, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWCottonPoisoningPointingsAdapter
	Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')

	oFieldsJson['InternalId']   				:= ''
	oFieldsJson['BranchId'] 					:= 'NPX_FILIAL'
	oFieldsJson['CropCode'] 					:= 'NPX_CODSAF'
	oFieldsJson['ProductCode'] 					:= 'NPX_CODPRO'
	oFieldsJson['Lot'] 							:= 'NPX_LOTE'
	oFieldsJson['AnalysisType'] 				:= 'NPX_CODTA'
	oFieldsJson['Sequence'] 					:= 'NPX_SEQ'
	oFieldsJson['AnalysisVariable'] 			:= 'NPX_CODVA'
	oFieldsJson['VariableDescription'] 			:= 'NPX_DESVA'
	oFieldsJson['VariableType'] 				:= 'NPX_TIPOVA'
	oFieldsJson['ResultValue'] 					:= 'NPX_RESNUM'
	oFieldsJson['ResultText'] 					:= 'NPX_RESTXT'
	oFieldsJson['ResultDate'] 					:= 'NPX_RESDTA'
	oFieldsJson['IncomeTax'] 					:= 'NPX_IR'
	oFieldsJson['Active'] 						:= 'NPX_ATIVO'
	oFieldsJson['UpdateDate'] 					:= 'NPX_DTATU'
	oFieldsJson['UpdateUser'] 					:= 'NPX_USUATU'
	oFieldsJson['CaseUniqueCode'] 				:= 'NPX_CDUMAL'
	oFieldsJson['BlockUniqueCode'] 				:= 'NPX_CDUBLC'
	oFieldsJson['CottonWrapUniqueCode'] 		:= 'NPX_ETIQ'
	oFieldsJson['CottonBaleUniqueCode'] 		:= 'NPX_CDUFRD'
	oFieldsJson['CottonBaleCode'] 				:= 'NPX_FARDAO'
	oFieldsJson['BlockCode'] 					:= 'NPX_BLOCO'
	oFieldsJson['ClassificationPackingList'] 	:= 'NPX_ROMCLA'
	oFieldsJson['EntityCode'] 					:= 'NPX_PRDTOR'
	oFieldsJson['EntityStoreCode'] 				:= 'NPX_LJPRO'
	oFieldsJson['EntityFarm'] 					:= 'NPX_FAZ'
	oFieldsJson['CottonWrapCode'] 				:= 'NPX_FARDO'
	oFieldsJson['ClassificationPackingListType']:= 'NPX_TPMALA'

return oFieldsJson

Method GetNmsW() CLASS FWCottonPoisoningPointingsAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')

	oFieldsJsw['INTERNALID']					:= ''
	oFieldsJsw['BRANCHID'] 						:= 'NPX_FILIAL'
	oFieldsJsw['CROPCODE'] 						:= 'NPX_CODSAF'
	oFieldsJsw['PRODUCTCODE'] 					:= 'NPX_CODPRO'
	oFieldsJsw['LOT'] 							:= 'NPX_LOTE'
	oFieldsJsw['ANALYSISTYPE'] 					:= 'NPX_CODVA'
	oFieldsJsw['VARIABLEDESCRIPTION'] 			:= 'NPX_DESVA'
	oFieldsJsw['SEQUENCE'] 						:= 'NPX_SEQ'
	oFieldsJsw['ANALYSISVARIABLE'] 				:= 'NPX_CODVA'
	oFieldsJsw['VARIABLETYPE'] 					:= 'NPX_TIPOVA'
	oFieldsJsw['RESULTVALUE'] 					:= 'NPX_RESNUM'
	oFieldsJsw['RESULTTEXT'] 					:= 'NPX_RESTXT'
	oFieldsJsw['RESULTDATE'] 					:= 'NPX_RESDTA'
	oFieldsJsw['INCOMETAX'] 					:= 'NPX_IR'
	oFieldsJsw['ACTIVE'] 						:= 'NPX_ATIVO'
	oFieldsJsw['UPDATEDATE'] 					:= 'NPX_DTATU'
	oFieldsJsw['UPDATEUSER'] 					:= 'NPX_USUATU'
	oFieldsJsw['CASEUNIQUECODE'] 				:= 'NPX_CDUMAL'
	oFieldsJsw['BLOCKUNIQUECODE'] 				:= 'NPX_CDUBLC'
	oFieldsJsw['COTTONWRAPUNIQUECODE'] 			:= 'NPX_ETIQ'
	oFieldsJsw['COTTONBALEUNIQUECODE'] 			:= 'NPX_CDUFRD'
	oFieldsJsw['COTTONBALECODE'] 				:= 'NPX_FARDAO'
	oFieldsJsw['BLOCKCODE'] 					:= 'NPX_BLOCO'
	oFieldsJsw['CLASSIFICATIONPACKINGLIST'] 	:= 'NPX_ROMCLA'
	oFieldsJsw['ENTITYCODE'] 					:= 'NPX_PRDTOR'
	oFieldsJsw['ENTITYSTORECODE'] 				:= 'NPX_LJPRO'
	oFieldsJsw['ENTITYFARM'] 					:= 'NPX_FAZ'
	oFieldsJsw['COTTONWRAPCODE'] 				:= 'NPX_FARDO'
	oFieldsJsw['CLASSIFICATIONPACKINGLISTTYPE']	:= 'NPX_TPMALA'

return oFieldsJsw


/*/{Protheus.doc} GetCottonPoisoningPointings
//Responsável por trazer a busca de Un. de beneficamento(s)
@author brunosilva
@since 29/11/2018
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, descricao
@type function
/*/
Method GetCottonPoisoningPointings(cCodId) CLASS FWCottonPoisoningPointingsAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasNPX 	as CHARACTER
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
		
		cAliasNPX := 'NPX'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
				
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		cAliasNPX := Self:CreateQuery(cCod)
		
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
			If !((cAliasNPX)->(Eof()))
				While !((cAliasNPX)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasNPX)->(dbskip())
						LOOP
					endIf
					
					for nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'		
							Self:oEaiObjSnd:setProp('InternalId', (cAliasNPX)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['CropCode']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['ProductCode']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['Lot']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['AnalysisType']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['AnalysisVariable']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['Sequence']))
						else
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNPX)->&(Self:oFieldsJson[cField]))
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
					
					(cAliasNPX)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()
					
					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
			endIf	
			(cAliasNPX)->(DBCloseArea())	
			
		else			
			if !((cAliasNPX)->(EOF()))
				for nJ := 1 to Len(aSelFields)
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasNPX)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['CropCode']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['ProductCode']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['Lot']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['AnalysisType']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['AnalysisVariable']) + "|" +  (cAliasNPX)->&(Self:oFieldsJson['Sequence'])
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNPX)->&(Self:oFieldsJson[cField]))
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
@since 29/11/2018
@version 1.0
@return cAliasNPX, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWCottonPoisoningPointingsAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasNPX    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasNPX 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	
	if SELECT(cAliasNPX) > 0
		(cAliasNPX)->(dbCloseArea())
		cAliasNPX 	:= GetNextAlias()
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
			aRet := StrTokArr( cCod, "|" ) // veio do get 	NPX_FILIAL+NPX_CODSAF+NPX_CODPRO+NPX_LOTE+NPX_CODTA+NPX_CODVA+NPX_SEQ
			cWhere := " NPX_FILIAL = '" + aRet[1] + "' AND  NPX_CODSAF = '" + aRet[2]  + "' AND  NPX_CODPRO = '" + aRet[3] + "' AND  NPX_LOTE = '" + aRet[4] + "' AND  NPX_CODTA = '" + aRet[5] + "' AND  NPX_CODVA = '" + aRet[6] + "' AND  NPX_SEQ = '" + aRet[7] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " NPX_FILIAL = '" + aRet[1] + "' AND  NPX_CODSAF = '" + aRet[2]  + "' AND  NPX_CODPRO = '" + aRet[3] + "' AND  NPX_LOTE = '" + aRet[4] + "' AND  NPX_CODTA = '" + aRet[5] + "' AND  NPX_CODVA = '" + aRet[6] + "' AND  NPX_SEQ = '" + aRet[7] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "
		cQuery2 := " FROM  " + RetSqlName("NPX") + " NPX"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += " AND D_E_L_E_T_ = ' '"
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNPX,.F.,.T.)
		
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
	
Return cAliasNPX


/*/{Protheus.doc} IncludeCottonPoisoningPointing
//Responsável por incluir um lançamento de contaminante pro algodão.
@author brunosilva
@since 13/12/2018
@version 1.0
@return cCodId, código do lançamento inserido.

@type function
/*/
METHOD IncludeCottonPoisoningPointing() CLASS FWCottonPoisoningPointingsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlNPX 		as OBJECT
	Local cCodId		as CHARACTER
	Private lFilLog		as LOGICAL
	
	cCodId 	:= ""
	lRet 	:= .T.
	
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('BranchId')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('BranchId'))
	
		oModel := FWLoadModel('UBAW050')
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		
		oMdlNPX := oModel:GetModel('RESTNPX')
		
		If lRet
			lRet := oMdlNPX:SetValue('NPX_FILIAL', FWxFilial("NPX"))
		else
			lRet := .F.
		EndIf	
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CropCode'))
			lRet := oMdlNPX:SetValue('NPX_CODSAF', Self:oEaiObjRec:getPropValue('CropCode'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ProductCode'))
			lRet := oMdlNPX:SetValue('NPX_CODPRO' , Self:oEaiObjRec:getPropValue('ProductCode'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Lot'))
			lRet := oMdlNPX:SetValue('NPX_LOTE' , Self:oEaiObjRec:getPropValue('Lot'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('AnalysisType'))
			lRet := oMdlNPX:SetValue('NPX_CODTA' , Self:oEaiObjRec:getPropValue('AnalysisType'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Sequence'))
			lRet := oMdlNPX:SetValue('NPX_SEQ' , Self:oEaiObjRec:getPropValue('Sequence'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('AnalysisVariable'))
			lRet := oMdlNPX:SetValue('NPX_CODVA' , Self:oEaiObjRec:getPropValue('AnalysisVariable'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('VariableDescription'))
			lRet := oMdlNPX:SetValue('NPX_DESVA' , Self:oEaiObjRec:getPropValue('VariableDescription'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('VariableType'))
			lRet := oMdlNPX:SetValue('NPX_TIPOVA' , Self:oEaiObjRec:getPropValue('VariableType'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ResultValue'))
			lRet := oMdlNPX:SetValue('NPX_RESNUM' , Val(Self:oEaiObjRec:getPropValue('ResultValue')))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ResultText'))
			lRet := oMdlNPX:SetValue('NPX_RESTXT' , Self:oEaiObjRec:getPropValue('ResultText'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ResultDate'))
			lRet := oMdlNPX:SetValue('NPX_RESDTA' , SToD(Self:oEaiObjRec:getPropValue('ResultDate')))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('IncomeTax'))
			lRet := oMdlNPX:SetValue('NPX_IR' , Self:oEaiObjRec:getPropValue('IncomeTax'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Active'))
			lRet := oMdlNPX:SetValue('NPX_ATIVO' , Self:oEaiObjRec:getPropValue('Active'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('UpdateDate'))
			lRet := oMdlNPX:SetValue('NPX_DTATU' , Self:oEaiObjRec:getPropValue('UpdateDate'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('UpdateUser'))
			lRet := oMdlNPX:SetValue('NPX_USUATU' , Self:oEaiObjRec:getPropValue('UpdateUser'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CaseUniqueCode'))
			lRet := oMdlNPX:SetValue('NPX_CDUMAL' , Self:oEaiObjRec:getPropValue('CaseUniqueCode'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('BlockUniqueCode'))
			lRet := oMdlNPX:SetValue('NPX_CDUBLC' , Self:oEaiObjRec:getPropValue('BlockUniqueCode'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonWrapUniqueCode'))
			lRet := oMdlNPX:SetValue('NPX_ETIQ' , Self:oEaiObjRec:getPropValue('CottonWrapUniqueCode'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonBaleUniqueCode'))
			lRet := oMdlNPX:SetValue('NPX_CDUFRD' , Self:oEaiObjRec:getPropValue('CottonBaleUniqueCode'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonBaleCode'))
			lRet := oMdlNPX:SetValue('NPX_FARDAO' , Self:oEaiObjRec:getPropValue('CottonBaleCode'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('BlockCode'))
			lRet := oMdlNPX:SetValue('NPX_BLOCO' , Self:oEaiObjRec:getPropValue('BlockCode'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ClassificationPackingList'))
			lRet := oMdlNPX:SetValue('NPX_ROMCLA' , Self:oEaiObjRec:getPropValue('ClassificationPackingList'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('EntityCode'))
			lRet := oMdlNPX:SetValue('NPX_PRDTOR' , Self:oEaiObjRec:getPropValue('EntityCode'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('EntityStoreCode'))
			lRet := oMdlNPX:SetValue('NPX_FAZ' , Self:oEaiObjRec:getPropValue('EntityStoreCode'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonWrapCode'))
			lRet := oMdlNPX:SetValue('NPX_FARDO' , Self:oEaiObjRec:getPropValue('CottonWrapCode'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ClassificationPackingListType'))
			lRet := oMdlNPX:SetValue('NPX_TPMALA' , Self:oEaiObjRec:getPropValue('ClassificationPackingListType'))
		endIf
			 
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()	
			ConfirmSX8()	
			Self:lOk := .T.
			cCodId   := oMdlNPX:GETVALUE("NPX_FILIAL") + "|" + oMdlNPX:GETVALUE("NPX_CODSAF")  + "|" + oMdlNPX:GETVALUE("NPX_CODPRO")  + "|" + oMdlNPX:GETVALUE("NPX_LOTE")  + "|" + oMdlNPX:GETVALUE("NPX_CODTA")  + "|" + oMdlNPX:GETVALUE("NPX_CODVA")  + "|" + oMdlNPX:GETVALUE("NPX_SEQ")  
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


/*/{Protheus.doc} AlteraCottonPoisoningPointing
//Responsável por alterar o registro passado por parametro.
@author brunosilva
@since 29/11/2018
@version 1.0
@return cCodId, código da UBA alterada.

@type function
/*/
Method AlteraCottonPoisoningPointing() CLASS FWCottonPoisoningPointingsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlNPX 		as OBJECT
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	
	cUserBenf 	:= ""
	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	 
	NPX->(dbSetOrder( 1 )) 
	If NPX->(dbSeek( aRet[1] + aRet[2]  + aRet[3]  + aRet[4]  + aRet[5]  + aRet[6]  + aRet[7] ) )
		oModel := FWLoadModel('UBAW050')
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		oMdlNPX := oModel:GetModel('RESTNPX')
		
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('VariableType'))
			lRet := oMdlNPX:SetValue('NPX_TIPOVA' , Self:oEaiObjRec:getPropValue('VariableType'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ResultValue'))
			lRet := oMdlNPX:SetValue('NPX_RESNUM' , Val(Self:oEaiObjRec:getPropValue('ResultValue')))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ResultText'))
			lRet := oMdlNPX:SetValue('NPX_RESTXT' , Self:oEaiObjRec:getPropValue('ResultText'))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ResultDate'))
			lRet := oMdlNPX:SetValue('NPX_RESDTA' , SToD(Self:oEaiObjRec:getPropValue('ResultDate')))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('UpdateDate'))
			lRet := oMdlNPX:SetValue('NPX_DTATU' , SToD(Self:oEaiObjRec:getPropValue('UpdateDate')))
		endIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('UpdateUser'))
			lRet := oMdlNPX:SetValue('NPX_USUATU' , Self:oEaiObjRec:getPropValue('UpdateUser'))
		endIf
				
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()		
			Self:lOk := .T.
		EndIf
		
		If !oModel:VldData()
			Self:cError := cValToChar(AGRGMSGERR(oModel:GetErrorMessage()))
			Self:oEaiObjRec:setError(AGRGMSGERR(oModel:GetErrorMessage()))
			Self:lOk := .F.
			RollBackSX8()
		Elseif !lRet .and. oModel:VldData() 
			Self:oEaiObjRec:setError("Verifique se todos os campos estão preenchidos.")
			Self:cError := "Verifique se todos os campos estão preenchidos."
			RollBackSX8()
			Self:lOk := .F.			
		endIf	
		oModel:DeActivate()
	Else
		Self:oEaiObjRec:setError("Lançamento não encontrada com a chave informada.")
		Self:cError := "Lançamento não encontrado com a chave informada."
		Self:lOk := .F.		
	EndIf
	
Return cCodId

/*/{Protheus.doc} DeleteCottonPoisoningPointing
//Responsável por excluir o registro passado por parâmetro.
@author brunosilva
@since 29/11/2018
@version 1.0
@return cCodId, código do lançamento deletado.

@type function
/*/
Method DeleteCottonPoisoningPointing() CLASS FWCottonPoisoningPointingsAdapter
	Local oModel 		as OBJECT
	Local cCodId		as CHARACTER
	
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do DELETE por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	NPX->(dbSetOrder( 1 ))
	If NPX->(dbSeek( aRet[1] + aRet[2]  + aRet[3]  + aRet[4]  + aRet[5]  + aRet[6]  + aRet[7]))
		oModel := FWLoadModel('UBAW050')
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
		Self:oEaiObjRec:setError("Lançamento não encontrado com o InternalId informado.")
		Self:lOk := .F.
		Self:cError := "Lançamento não encontrado com o InternalId informado."
	EndIf  
	
Return cCodId