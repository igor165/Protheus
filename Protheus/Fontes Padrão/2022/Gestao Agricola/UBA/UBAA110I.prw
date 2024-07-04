#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWCottonGinBreaksAdapter

	DATA lApi        as LOGICAL
	DATA lOk		 as LOGICAL
	
	DATA cRecno   	    as CHARACTER	
	DATA cBranchId 	    as CHARACTER
	DATA cCode	 	    as CHARACTER
	DATA cDescription	as CHARACTER
	DATA cInternalId	as CHARACTER
	DATA cError    	    as CHARACTER
	DATA cMsgName  	    as CHARACTER
	DATA cTipRet	    as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		 as OBJECT
	DATA oFieldsJson as OBJECT
	DATA oFieldsJsw   as OBJECT
	DATA oEaiObjSnd  as OBJECT
	DATA oEaiObjSn2  as OBJECT
	DATA oEaiObjRec  as OBJECT
	
	METHOD NEW()
	
	METHOD GetCottonGinBreaks()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeCottonGinBreaks()
	METHOD AlteraCottonGinBreaks()
	METHOD DeleteCottonGinBreaks()
	
	METHOD CreateQuery()

EndClass

/*/{Protheus.doc} NEW
//Responsável instanciar um objeto e seus devidos atributos. 
@author Christopher.miranda
@since 04/12/2018
@version 1.0

@type method
/*/
Method NEW() CLASS FWCottonGinBreaksAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .T.
	
	Self:cRecno 	     := ''
	Self:cBranchId 	     := ''
	Self:cCode	 	     := ''
	Self:cDescription 	 := ''
	Self:cInternalId	 := ''
	Self:cError          := ''
	Self:cMsgName        := 'FARDOS'
	Self:cSelectedFields := ''
	Self:cTipRet		 := '' //Tipo de retorno -> 1=Array;2=NãoArray 

	self:oFieldsJson     := self:GetNames()
	self:oFieldsJsw   := self:GetNmsW()
	
	self:oEaiObjSnd := FWEAIObj():NEW()
	self:oEaiObjSn2 := JsonObject():New()
	self:oEaiObjRec := Nil
	
Return

/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author Christopher.miranda
@since 04/12/2018
@version 1.0
@return oFieldsJson, Objeto JSON

@type method
/*/
Method GetNames() CLASS FWCottonGinBreaksAdapter
	 Local oFieldsJson as OBJECT
	 
	 oFieldsJson := &('JsonObject():New()')
	
	 oFieldsJson['BranchId']                := 'NBP_FILIAL'
	 oFieldsJson['Code']      		        := 'NBP_CODIGO'
	 oFieldsJson['Description']      		:= 'NBP_DESCRI'
	 oFieldsJson['InternalId']      		:= ''
 
return oFieldsJson

Method GetNmsW() CLASS FWCottonGinBreaksAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')

	oFieldsJsw['BRANCHID']  	:= 'NBP_FILIAL'
	oFieldsJsw['CODE']			:= 'NBP_CODIGO'
	oFieldsJsw['DESCRIPTION']	:= 'NBP_DESCRI'
	oFieldsJsw['INTERNALID']	:= ''

return oFieldsJsw

/*/{Protheus.doc} GetCottonGinBreaks
//Responsável por fazer a busca de tipos de paradas
@author Christopher.miranda
@since 04/12/2018
@version 1.0
@return lRet, retorno lógico.
@param aQryParam, array, descricao

@type function
/*/
Method GetCottonGinBreaks(cParCodUni) CLASS FWCottonGinBreaksAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local nJ			as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasNBP 	as CHARACTER
	Local cQuery 	    as CHARACTER
	Local cField		as CHARACTER
	Local aArea      	as ARRAY
	Local aSelFields	as ARRAY
	Local oPage      	as OBJECT
	
	
	aSelFields := NIL
	nJ		 := 1
	lRet     := .T.
	aArea    := getArea()
	cQuery 	 := ''
	cError   := ''		
	nCount   := 0
	
	if Self:lApi
		if !(EMPTY(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		cAliasNBP := 'NBP'
		If Empty(cParCodUni)
			cUniqueCode := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cUniqueCode := cParCodUni
		EndIf
				
		Self:oEaiObjSnd:Activate()	
		self:oEaiObjSn2:Activate()		
		
		lNext := .T.
		cAliasNBP := Self:CreateQuery(cParCodUni)
		
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
			If !((cAliasNBP)->(Eof()))
				While !((cAliasNBP)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasNBP)->(dbskip())
						LOOP
					endIf
				
					for nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasNBP)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNBP)->&(Self:oFieldsJson['Code']))
						else						
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNBP)->&(Self:oFieldsJson[cField]))
							if cValue != NIL
								IF VALTYPE(cValue) = "C"
									Self:oEaiObjSnd:setProp(cField, cValue)
								elseif VALTYPE(cValue) = "N"
									Self:oEaiObjSnd:setProp(cField, cValToChar(cValue))
								endIf
							else
								Self:cError := 'A propriedade do ' + cField + ' fields  não é valida.' + CRLF
								Self:lOk := .F.
								Return()
							endIf
						endIf
					next nJ
					
					(cAliasNBP)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()
					
					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec, ) )
			endIf	
			(cAliasNBP)->(DBCloseArea())	
			
		else	
			if !((cAliasNBP)->(EOF()))		
				for nJ := 1 to Len(aSelFields) 
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasNBP)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNBP)->&(Self:oFieldsJson['Code'])
					else	
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNBP)->&(Self:oFieldsJson[cField]))
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
			endif
		endIf
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author Christopher.miranda
@since 04/12/2018
@version 1.0
@return cAliasNBP, Tabela temporária gerada pela consulta no banco

@type function
/*/
Method CreateQuery(cCod) CLASS FWCottonGinBreaksAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasNBP    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasNBP 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	cQuery		:= ""
	cQuery1		:= ""
	cQuery2		:= ""

    if SELECT(cAliasNBP) > 0
        (cAliasNBP)->(dbCloseArea())
        cAliasNBP 	:= GetNextAlias()
    endIf
	
	//Pega os atributos que foram passado para o filtro
	oJsonFilter  := Self:oEaiObjRec:getFilter()
	
	if oJsonFilter != Nil
		aTemp := oJsonFilter:getProperties()
		for nX := 1 to len(aTemp)
			if !Empty(Self:oFieldsJsw[aTemp[nX]])
				cWhere += ' AND '
				if ValType(oJsonFilter[aTemp[nX]]) != "C"
					oJsonFilter[aTemp[nX]] :=  str(oJsonFilter[aTemp[nX]]) 
				EndIf
				cWhere += Self:oFieldsJsw[aTemp[nX]] + '=' + "'" + oJsonFilter[aTemp[nX]]  + "'"
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
			if Empty(FWxFilial("NBP")) .AND. LEN(StrTokArr( cCod, "|" )) = 1//Significa que a filial é compartilhada
                aRet := {FWxFilial("NBP"),StrTokArr( cCod, "|" )[1]}
            else
                aRet := StrTokArr( cCod, "|" ) // veio do get 
            endIf
            cWhere := " NBP_FILIAL = '" + aRet[1] + "' AND  NBP_CODIGO = '" + aRet[2] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " NBP_FILIAL = '" + aRet[1] + "' AND  NBP_CODIGO = '" + aRet[2] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "  
		cQuery2 := " FROM  " + RetSqlName("NBP") + " NBP"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += " AND D_E_L_E_T_ = ' '"
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
			
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNBP,.F.,.T.)

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
	
Return cAliasNBP

METHOD IncludeCottonGinBreaks() CLASS FWCottonGinBreaksAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlNBP 		as OBJECT
	Local cCodId		as CHARACTER
	Local lFilLog		as LOGICAL
	Private cUserBenf   as CHARACTER
	
	cUserBenf := ""
	cCodId 	:= ""
	lRet 	:= .T.
	
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('BranchId')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('BranchId'))
		
		oModel := FWLoadModel('UBAA110')
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		
		oMdlNBP := oModel:GetModel('UBAA110_NBP')
		
		If lRet .And. PADR(Self:oEaiObjRec:getPropValue('BranchId'),TamSX3("NBP_FILIAL")[1]) = FWxFilial('NBP')
			lRet := oMdlNBP:SetValue('NBP_FILIAL', Self:oEaiObjRec:getPropValue('BranchId'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Code'))
			lRet := oMdlNBP:SetValue('NBP_CODIGO', Self:oEaiObjRec:getPropValue('Code'))
		else
			lRet := .F.
		EndIf
	    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Description'))
			lRet := oMdlNBP:SetValue('NBP_DESCRI', Self:oEaiObjRec:getPropValue('Description'))
		else
			lRet := .F.
		EndIf
	    
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()	
			ConfirmSX8()	
			Self:lOk := .T.
			cCodId   := oMdlNBP:GETVALUE("NBP_FILIAL") + "|" + oMdlNBP:GETVALUE("NBP_CODIGO")
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

Method AlteraCottonGinBreaks() CLASS FWCottonGinBreaksAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlNBP 		as OBJECT
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	
	cUserBenf 	:= ""
	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	dbSelectArea( "NBP" )
	NBP->(dbSetOrder( 1 ))
	If NBP->(dbSeek( PADR(aRet[1],TamSX3("NBP_FILIAL")[1]) + aRet[2]) ) 
		oModel := FWLoadModel('UBAA110')
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		oMdlNBP := oModel:GetModel('UBAA110_NBP')
		
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
		if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('Description'))
			lRet := oMdlNBP:SetValue('NBP_DESCRI', Self:oEaiObjRec:getPropValue('Description'))
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
		Self:oEaiObjRec:setError("Ponto de Parada não encontrado com a chave informada.")
		Self:lOk := .F.
		Self:cError := "Ponto de Parada não encontrado com a chave informada."
	EndIf
	
Return cCodId

Method DeleteCottonGinBreaks() CLASS FWCottonGinBreaksAdapter
	Local oModel 		as OBJECT
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	
	cUserBenf 	:= ""	
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do DELETE por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	NBP->(dbSetOrder( 1 ))
	If NBP->(dbSeek( PADR(aRet[1],TamSX3("NBP_FILIAL")[1]) + aRet[2]) ) 
		oModel := FWLoadModel('UBAA110')
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
		Self:oEaiObjRec:setError("Ponto de Parada não encontrado com o InternalId informado.")
		Self:lOk := .F.
		Self:cError := "Ponto de Parada não encontrado com o InternalId informado."
	EndIf  
	
Return cCodId