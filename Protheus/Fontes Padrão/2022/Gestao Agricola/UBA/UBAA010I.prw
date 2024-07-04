#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWTreadmillsAdapter
	
	DATA lApi        as LOGICAL
	DATA lOk		 as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cCottonGin	  		as CHARACTER
	DATA cInternalId		as CHARACTER
	DATA cError       		as CHARACTER
	DATA cMsgName     		as CHARACTER
	DATA cTipRet	  		as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		 as OBJECT
	DATA oFieldsJson as OBJECT
	DATA oFieldsJsw   as OBJECT
	DATA oEaiObjSnd  as OBJECT
	DATA oEaiObjSn2  as OBJECT
	DATA oEaiObjRec  as OBJECT

	METHOD NEW()
	
	METHOD GetTreadmills()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeTreadmill()
	METHOD AlteraTreadmill()
	METHOD DeleteTreadmill()
	
	METHOD CreateQuery()
	
EndClass

/*/{Protheus.doc} NEW
//Responsável instanciar um objeto e seus devidos atributos. 
@author brunosilva
@since 15/11/2018
@version 1.0

@type function
/*/
Method NEW() CLASS FWTreadmillsAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  := ''
	Self:cBranch 	  := ''
	Self:cCode	 	  := ''
	Self:cDescription := ''
	Self:cCottonGin	  := ''
	Self:cInternalId  := ''
	Self:cError       := ''
	Self:cMsgName     := 'ESTEIRAS'
	Self:cSelectedFields := ''
	Self:cTipRet		 := '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson:= self:GetNames()
	self:oFieldsJsw   := self:GetNmsW()
	
	self:oEaiObjSnd := FWEAIObj():NEW()
	self:oEaiObjSn2 := JsonObject():New()
	self:oEaiObjRec := Nil
	
Return

/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author brunosilva
@since 15/11/2018
@version 1.0
@return oFieldsJson, Objeto JSON

@type function
/*/
Method GetNames() CLASS FWTreadmillsAdapter
	Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')

	oFieldsJson['SourceBranch'] := 'N70_FILIAL'
	oFieldsJson['Code']			:= 'N70_CODIGO'
	oFieldsJson['Description']	:= 'N70_DESCRI'
	oFieldsJson['CottonGin']	:= 'N70_CODUNB'	
	oFieldsJson['InternalId']   := ''

return oFieldsJson

Method GetNmsW() CLASS FWTreadmillsAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')

	oFieldsJsw['SOURCEBRANCH']  := 'N70_FILIAL'
	oFieldsJsw['CODE']			:= 'N70_CODIGO'
	oFieldsJsw['DESCRIPTION']	:= 'N70_DESCRI'
	oFieldsJsw['COTTONGIN']		:= 'N70_CODUNB'
	oFieldsJsw['INTERNALID']	:= ''

return oFieldsJsw

/*/{Protheus.doc} GetTreadmills
//Responsável por fazer a busca de esteiras(s)
@author brunosilva
@since 15/11/2018
@version 1.0
@return lRet, retorno lógico.
@param cCod, characters, código do fardão a ser pesquisado
@type function
/*/
Method GetTreadmills(cCodId) CLASS FWTreadmillsAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasN70 	as CHARACTER
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
		
		cAliasN70 := 'N70'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
				
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		cAliasN70 := Self:CreateQuery(cCod)
		
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
			If !((cAliasN70)->(Eof()))
				While !((cAliasN70)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasN70)->(dbskip())
						LOOP
					endIf
					
					for nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasN70)->&(Self:oFieldsJson['SourceBranch']) + "|" +  (cAliasN70)->&(Self:oFieldsJson['Code']))
						else
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasN70)->&(Self:oFieldsJson[cField]))
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
					
					(cAliasN70)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()
					
					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
	
			endif
			(cAliasN70)->(DBCloseArea())
		else
			If !((cAliasN70)->(Eof()))
				for nJ := 1 to Len(aSelFields)
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasN70)->&(Self:oFieldsJson['SourceBranch']) + "|" +  (cAliasN70)->&(Self:oFieldsJson['Code'])
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasN70)->&(Self:oFieldsJson[cField]))
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
			endif
		endIf
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author brunosilva
@since 15/11/2018
@version 1.0
@return cAliasN70, Tabela temporária gerada pela consulta no banco
@type function
/*/
Method CreateQuery(cCod) CLASS FWTreadmillsAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasN70    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasN70 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cOrder		:= ""
	cQuery2		:= ""
	cQuery		:= ""

	if SELECT(cAliasN70) > 0
		(cAliasN70)->(dbCloseArea())
		cAliasN70 	:= GetNextAlias()
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
	
			if substr(aTemp[nX],1,1) == '-'
				if !empty(Self:oFieldsJson[substr(aTemp[nX],2)])
					cOrder += Self:oFieldsJson[substr(aTemp[nX],2)] + ' desc'
				Else
					Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
					lRet := .F.
				EndIf
			Else
				if !Empty(Self:oFieldsJson[aTemp[nX]])
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
			cWhere := " N70_FILIAL = '" + aRet[1] + "' AND  N70_CODIGO = '" + aRet[2] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " N70_FILIAL = '" + aRet[1] + "' AND  N70_CODIGO = '" + aRet[2] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "  //+ cFields + " "
		cQuery2 := " FROM  " + RetSqlName("N70") + " N70"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += " AND D_E_L_E_T_ = ' '"
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
			
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN70,.F.,.T.)
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
	
Return cAliasN70


METHOD IncludeTreadmill() CLASS FWTreadmillsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlN70 		as OBJECT
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	Private _cUserBenf 	:= A655GETUNB()// Busca a unidade de beneficiamento
	
	cUserBenf := ""
	cCodId 	:= ""
	lRet 	:= .T.
	
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('SourceBranch')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('SourceBranch'))
		oModel := FWLoadModel('UBAA010')
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		
		oMdlN70 := oModel:GetModel('N70UBAA010')
		
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('SourceBranch'))
			lRet := oMdlN70:SetValue('N70_FILIAL', Self:oEaiObjRec:getPropValue('SourceBranch'))
		else
			lRet := .F.
		EndIf	
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Code'))
			lRet := oMdlN70:SetValue('N70_CODIGO', Self:oEaiObjRec:getPropValue('Code'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Description'))
			lRet := oMdlN70:SetValue('N70_DESCRI' , Self:oEaiObjRec:getPropValue('Description'))
		EndIf
		If lRet
			lRet := oMdlN70:SetValue('N70_CODUNB', Self:oEaiObjRec:getPropValue('CottonGin'))
		EndIf	
		 
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()	
			ConfirmSX8()	
			Self:lOk := .T.
			cCodId   := oMdlN70:GETVALUE("N70_FILIAL") + "|" + oMdlN70:GETVALUE("N70_CODIGO")
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
		Self:oEaiObjRec:setError("Filial(SourceBranch) em branco ou inválida. Favor conferir")
		Self:cError := "Filial(SourceBranch) em branco ou inválida. Favor conferir."
		Self:lOk := .F.	
	endIf
	
Return cCodId


Method AlteraTreadmill() CLASS FWTreadmillsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlN70 		as OBJECT
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	Private _cUserBenf 	:= A655GETUNB()// Busca a unidade de beneficiamento
	
	cUserBenf 	:= ""
	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	dbSelectArea( "N70" )
	N70->(dbSetOrder( 1 ))
	If N70->(dbSeek( PADR(aRet[1],TamSX3("N70_FILIAL")[1]) + aRet[2]) ) 
		oModel := FWLoadModel('UBAA010')
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		oMdlN70 := oModel:GetModel('N70UBAA010')
		
		//Se atentar ao tamanho da filial
		if !Empty(Self:oEaiObjRec:getPropValue('SourceBranch')) .AND. aRet[1] != Self:oEaiObjRec:getPropValue('SourceBranch')
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
			lRet := oMdlN70:SetValue('N70_DESCRI', Self:oEaiObjRec:getPropValue('Description'))
		else
			lRet := .F.
		endIf
				
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonGin'))
			lRet := oMdlN70:SetValue('N70_CODUNB', Self:oEaiObjRec:getPropValue('CottonGin'))
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
		Self:oEaiObjRec:setError("Esteira não encontrada com a chave informada.")
		Self:lOk := .F.
		Self:cError := "Esteira não encontrada com a chave informada."
	EndIf
	
Return cCodId

Method DeleteTreadmill() CLASS FWTreadmillsAdapter
	Local oModel 		as OBJECT
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	Private _cUserBenf 	:= A655GETUNB()// Busca a unidade de beneficiamento
	
	cUserBenf 	:= ""	
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do DELETE por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	N70->(dbSetOrder( 1 ))
	If N70->(dbSeek( PADR(aRet[1],TamSX3("N70_FILIAL")[1]) + aRet[2]) ) 
		oModel := FWLoadModel('UBAA010')
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
		Self:oEaiObjRec:setError("Esteira não encontrado com o InternalId informado.")
		Self:lOk := .F.
		Self:cError := "Esteira não encontrado com o InternalId informado."
	EndIf  
	
Return cCodId