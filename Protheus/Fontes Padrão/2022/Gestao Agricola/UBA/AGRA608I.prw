#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWCottonColorGradesAdapter
	
	DATA lApi        as LOGICAL
	DATA lOk		 as LOGICAL

	DATA cRecno 	        	as CHARACTER
	DATA cBranchId 	        	as CHARACTER
	DATA cCode	 	       	 	as CHARACTER
	DATA cDescription       	as CHARACTER
	DATA cShortDescription 		as CHARACTER
	DATA cStandardUniversalCode	as CHARACTER
	DATA cInternalId			as CHARACTER
	DATA cError             	as CHARACTER
	DATA cMsgName           	as CHARACTER
	DATA cTipRet	  			as CHARACTER
	DATA cSelectedFields		as CHARACTER
	
	DATA oModel		 as OBJECT
	DATA oFieldsJson as OBJECT
	DATA oFieldsJsw  as OBJECT
	DATA oEaiObjSnd  as OBJECT
	DATA oEaiObjSn2  as OBJECT
	DATA oEaiObjRec  as OBJECT

	METHOD NEW()
	
	METHOD GetCottonColorGrades()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeCottonColorGrades()
	METHOD AlteraCottonColorGrades()
	METHOD DeleteCottonColorGrades()
	
	METHOD CreateQuery()
	
EndClass

/*/{Protheus.doc} NEW
//Responsável instanciar um objeto e seus devidos atributos. 
@author Christopher.miranda
@since 30/11/2018
@version 1.0

@type function
/*/
Method NEW() CLASS FWCottonColorGradesAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	                 := ''
	Self:cBranchId	                 := ''
	Self:cCode	 	                 := ''
	Self:cDescription                := ''
	Self:cShortDescription           := ''
	Self:cStandardUniversalCode	     := ''
	Self:cInternalId	 			 := ''
	Self:cError                      := ''
	Self:cMsgName                    := 'CLASSIFICAÇÃO'
	Self:cSelectedFields             := ''
	Self:cTipRet					 := '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson  := self:GetNames()
	self:oFieldsJsw   := self:GetNmsW()
	
	self:oEaiObjSnd := FWEAIObj():NEW()
	self:oEaiObjSn2 := JsonObject():New()
	self:oEaiObjRec := Nil
	
Return

/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author Christopher.miranda
@since 30/11/2018
@version 1.0
@return oFieldsJson, Objeto JSON

@type function
/*/
Method GetNames() CLASS FWCottonColorGradesAdapter
	Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')

	oFieldsJson['BranchId']                 := 'DXA_FILIAL'
	oFieldsJson['Code']			            := 'DXA_CODIGO'
	oFieldsJson['Description']	            := 'DXA_DESCRI'
	oFieldsJson['ShortDescription']	        := 'DXA_DESABR'	
	oFieldsJson['StandardUniversalCode']	:= 'DXA_CODUNS'	
	oFieldsJson['InternalId']      			:= ''

return oFieldsJson

Method GetNmsW() CLASS FWCottonColorGradesAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')

	oFieldsJsw['BRANCHID']  				:= 'DXA_FILIAL'
	oFieldsJsw['CODE']						:= 'DXA_CODIGO'
	oFieldsJsw['DESCRIPTION']				:= 'DXA_DESCRI'
	oFieldsJsw['SHORTDESCRIPTION']			:= 'DXA_DESABR'
	oFieldsJsw['STANDARDUNIVERSALCODE']		:= 'DXA_CODUNS'
	oFieldsJsw['INTERNALID']				:= ''

return oFieldsJsw

/*/{Protheus.doc} GetCottonColorGrades
//Responsável por fazer a busca de classificações
@author Christopher.miranda
@since 30/11/2018
@version 1.0
@return lRet, retorno lógico.
@param cCod, characters, código do fardão a ser pesquisado
@type function
/*/
Method GetCottonColorGrades(cCodId) CLASS FWCottonColorGradesAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasDXA 	as CHARACTER
	Local cCodId 	    as CHARACTER
	Local cCod	 	    as CHARACTER
	Local cQuery 	    as CHARACTER
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
		
		cAliasDXA := 'DXA'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
				
		Self:oEaiObjSnd:Activate()		
		Self:oEaiObjSn2:Activate()
		
		lNext := .T.
		cAliasDXA := Self:CreateQuery(cCod)
		
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
			If !((cAliasDXA)->(Eof()))
				While !((cAliasDXA)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasDXA)->(dbskip())
						LOOP
					endIf
					for nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasDXA)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasDXA)->&(Self:oFieldsJson['Code']))
						else
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasDXA)->&(Self:oFieldsJson[cField]))
							if cValue != NIL
								IF VALTYPE(cValue) = "C"
									Self:oEaiObjSnd:setProp(cField, cValue)
								elseif VALTYPE(cValue) = "N"
									Self:oEaiObjSnd:setProp(cField, cValToChar(cValue))
								endif
							else
								Self:cError := 'O campo "' + cField + '" não é valido.' + CRLF
								Self:lOk := .F.
								Return()
							endIf
						endIf
					next nJ
					
					(cAliasDXA)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()
					
					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
			endIf	
			(cAliasDXA)->(DBCloseArea())

		else
			If !((cAliasDXA)->(Eof()))
				for nJ := 1 to Len(aSelFields)
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasDXA)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasDXA)->&(Self:oFieldsJson['Code'])
					else	
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasDXA)->&(Self:oFieldsJson[cField]))
						if cValue != NIL
							IF VALTYPE(cValue) = "C"
								self:oEaiObjSn2[cField]	:= cValue
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
		endif	
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author Christopher.miranda
@since 30/11/2018
@version 1.0
@return cAliasDXA, Tabela temporária gerada pela consulta no banco

@type function
/*/
Method CreateQuery(cCod) CLASS FWCottonColorGradesAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasDXA    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	aRet		:= {}
	lRet 		:= .T.
	cWhere 		:= "1=1"
	cAliasDXA 	:= GetNextAlias()
	cOrder		:= ""
	cQuery2		:= ""
	cQuery		:= ""
	
	if SELECT(cAliasDXA) > 0
		(cAliasDXA)->(dbCloseArea())
		cAliasDXA := GetNextAlias()
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
			if Empty(FWxFilial("DXA")) .AND. LEN(StrTokArr( cCod, "|" )) = 1//Significa que a filial é compartilhada
				aRet := {FWxFilial("DXA"),StrTokArr( cCod, "|" )[1]}
			else
				aRet := StrTokArr( cCod, "|" ) // veio do get 
			endIf		
			
			cWhere := " DXA_FILIAL = '" + aRet[1] + "' AND  DXA_CODIGO = '" + aRet[2] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " DXA_FILIAL = '" + aRet[1] + "' AND  DXA_CODIGO = '" + aRet[2] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "  
		cQuery2 := " FROM  " + RetSqlName("DXA") + " DXA"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += " AND D_E_L_E_T_ = ' '"
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
			
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasDXA,.F.,.T.)
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
	
Return cAliasDXA

METHOD IncludeCottonColorGrades() CLASS FWCottonColorGradesAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlDXA 		as OBJECT
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	Private lFilLog		as LOGICAL
	
	cUserBenf := ""
	cCodId 	:= ""
	lRet 	:= .T.
	
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('BranchId')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('BranchId'))
	
		oModel := FWLoadModel('AGRA608')
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		
		oMdlDXA := oModel:GetModel('MdFieldDXA')
		
		If lRet
			lRet := oMdlDXA:SetValue('DXA_FILIAL', FWxFilial("DXA_FILIAL"))
		else
			lRet := .F.
		EndIf	
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Code'))
			lRet := oMdlDXA:SetValue('DXA_CODIGO', Self:oEaiObjRec:getPropValue('Code'))
		else
			lRet := .F.
		EndIf
	    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('StandardUniversalCode'))
			lRet := oMdlDXA:SetValue('DXA_CODUNS', Self:oEaiObjRec:getPropValue('StandardUniversalCode'))
		else
			lRet := .F.
		EndIf
		If lRet
			lRet := oMdlDXA:SetValue('DXA_DESCRI' , Self:oEaiObjRec:getPropValue('Description'))
		EndIf
		If lRet
			lRet := oMdlDXA:SetValue('DXA_DESABR', Self:oEaiObjRec:getPropValue('ShortDescription'))
		EndIf
	    
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()	
			ConfirmSX8()	
			Self:lOk := .T.
			cCodId   := oMdlDXA:GETVALUE("DXA_FILIAL") + "|" + oMdlDXA:GETVALUE("DXA_CODIGO")
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

Method AlteraCottonColorGrades() CLASS FWCottonColorGradesAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlDXA 		as OBJECT
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	
	cUserBenf 	:= ""
	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		if Empty(FWxFilial("DXA")) .AND. LEN(StrTokArr( cCodId, "|" )) = 1//Significa que a filial é compartilhada
			aRet := {FWxFilial("DXA"),StrTokArr( cCodId, "|" )[1]}
		else
			aRet := StrTokArr( cCodId, "|" ) // veio do get 
		endIf
	endIf
	
	dbSelectArea( "DXA" )
	DXA->(dbSetOrder( 1 ))
	If DXA->(dbSeek( PADR(aRet[1],TamSX3("DXA_FILIAL")[1]) + aRet[2]) ) 
		oModel := FWLoadModel('AGRA608')
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		oMdlDXA := oModel:GetModel('MdFieldDXA')
		
		if !Empty(Self:oEaiObjRec:getPropValue('BranchId')) .AND. aRet[1] != Self:oEaiObjRec:getPropValue('BranchId')
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
		
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('StandardUniversalCode'))
			lRet := oMdlDXA:SetValue('DXA_CODUNS', Self:oEaiObjRec:getPropValue('StandardUniversalCode'))
		else
			lRet := .F.
		endIf
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('Description'))
			lRet := oMdlDXA:SetValue('DXA_DESCRI', Self:oEaiObjRec:getPropValue('Description'))
		else
			lRet := .F.
		endIf
				
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ShortDescription'))
			lRet := oMdlDXA:SetValue('DXA_DESABR', Self:oEaiObjRec:getPropValue('ShortDescription'))
		else
			lRet := .F.
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
		Self:oEaiObjRec:setError("Classificação não encontrada com a chave informada.")
		Self:lOk := .F.
		Self:cError := "Classificação não encontrada com a chave informada."
	EndIf
	
Return cCodId

Method DeleteCottonColorGrades() CLASS FWCottonColorGradesAdapter
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	
	cUserBenf 	:= ""	
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		if Empty(FWxFilial("DXA")) .AND. LEN(StrTokArr( cCodId, "|" )) = 1//Significa que a filial é compartilhada
			aRet := {FWxFilial("DXA"),StrTokArr( cCodId, "|" )[1]}
		else
			aRet := StrTokArr( cCodId, "|" ) // veio do get 
		endIf
	endIf
	
	dbSelectArea("DXA")
	DXA->(dbSetOrder( 1 ))
	If DXA->(dbSeek( PADR(aRet[1],TamSX3("DXA_FILIAL")[1]) + aRet[2]) ) 
		/*oModel := FWLoadModel('AGRA608')
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
		oModel:DeActivate()*/
		
		if RecLock("DXA", .F.)
			dbDelete()
			MsUnLock()
		endIf
	Else
		Self:oEaiObjRec:setError("Classificação não encontrado com o InternalId informado.")
		Self:lOk := .F.
		Self:cError := "Classificação não encontrado com o InternalId informado."
	EndIf  	
	
Return cCodId