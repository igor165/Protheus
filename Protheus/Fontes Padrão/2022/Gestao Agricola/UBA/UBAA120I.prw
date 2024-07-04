#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWCottonGinBreakPointingsAdapter

	DATA lApi        as LOGICAL
	DATA lOk		 as LOGICAL
	
	DATA cRecno   	            as CHARACTER	
	DATA cBranchId 	            as CHARACTER
	DATA cCode	 	            as CHARACTER
	DATA cCottonGinCode         as CHARACTER
	DATA cCottonGinBreakCode    as CHARACTER
	DATA cShiftCode             as CHARACTER
	DATA cStartDate             as CHARACTER
	DATA cStartTime             as CHARACTER
	DATA cEndDate               as CHARACTER
	DATA cEndTime               as CHARACTER
	DATA cStatus                as CHARACTER
	DATA cUserCode              as CHARACTER
	DATA cNote                  as CHARACTER
	DATA cInternalId			as CHARACTER
	DATA cError    	            as CHARACTER
	DATA cMsgName  	            as CHARACTER
	DATA cTipRet	            as CHARACTER
	DATA cSelectedFields	    as CHARACTER
	
	DATA oModel		 as OBJECT
	DATA oFieldsJson as OBJECT
	DATA oFieldsJsw  as OBJECT
	DATA oEaiObjSnd  as OBJECT
	DATA oEaiObjSn2  as OBJECT
	DATA oEaiObjRec  as OBJECT
	
	METHOD NEW()
	
	METHOD GetCottonGinBreakPointings()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeCottonGinBreakPointings()
	METHOD AlteraCottonGinBreakPointings()
	METHOD DeleteCottonGinBreakPointings()
	
	METHOD CreateQuery()

EndClass

/*/{Protheus.doc} NEW
//Responsável instanciar um objeto e seus devidos atributos. 
@author Christopher.miranda
@since 04/12/2018
@version 1.0

@type method
/*/
Method NEW() CLASS FWCottonGinBreakPointingsAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .T.
	
	Self:cRecno 	            := ''
	Self:cBranchId 	            := ''
	Self:cCode	 	            := ''
	Self:cCottonGinBreakCode    := ''
	Self:cShiftCode	 	        := ''
	Self:cStartDate	 	        := ''
	Self:cStartTime	 	        := ''
	Self:cEndDate	 	        := ''
	Self:cEndTime	 	        := ''
	Self:cStatus	 	        := ''
	Self:cUserCode	 	        := ''
	Self:cNote	 	            := ''
	Self:cInternalId	 		:= ''
	Self:cError                 := ''
	Self:cMsgName               := 'FARDOS'	
	Self:cSelectedFields        := ''
	Self:cTipRet		        := '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson  	:= self:GetNames()
	self:oFieldsJsw   	:= self:GetNmsW()
	
	self:oEaiObjSnd 	:= FWEAIObj():NEW()
	self:oEaiObjSn2 	:= JsonObject():New()
	self:oEaiObjRec 	:= Nil
	
Return

/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author Christopher.miranda
@since 04/12/2018
@version 1.0
@return oFieldsJson, Objeto JSON

@type method
/*/
Method GetNames() CLASS FWCottonGinBreakPointingsAdapter
	 Local oFieldsJson as OBJECT
	 
	 oFieldsJson := &('JsonObject():New()')
	
	 oFieldsJson['BranchId']                := 'NC5_FILIAL'
	 oFieldsJson['Code']      		        := 'NC5_CODIGO'
	 oFieldsJson['CottonGinCode']      		:= 'NC5_CONJTO'
	 oFieldsJson['CottonGinBreakCode']      := 'NC5_CODMOT'
	 oFieldsJson['ShiftCode']      		    := 'NC5_TURNO'
	 oFieldsJson['StartDate']      		    := 'NC5_DTINI'
	 oFieldsJson['StartTime']      		    := 'NC5_HRINI'
	 oFieldsJson['EndDate']      		    := 'NC5_DTTER'
	 oFieldsJson['EndTime']      	    	:= 'NC5_HRTER'
	 oFieldsJson['Status']      		    := 'NC5_STATUS'
	 oFieldsJson['UserCode']      		    := 'NC5_CODUSU'
	 oFieldsJson['Note']      		        := 'NC5_OBSPAR'
	 oFieldsJson['InternalId']      		:= ''
 
return oFieldsJson


Method GetNmsW() CLASS FWCottonGinBreakPointingsAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')

	oFieldsJsw['BRANCHID']  			:= 'NC5_FILIAL' 
	oFieldsJsw['CODE']					:= 'NC5_CODIGO' 
	oFieldsJsw['COTTONGINCODE']			:= 'NC5_CONJTO' 
	oFieldsJsw['COTTONGINBREAKCODE']	:= 'NC5_CODMOT' 
	oFieldsJsw['SHIFTCODE']				:= 'NC5_TURNO' 
	oFieldsJsw['STARTDATE']				:= 'NC5_DTINI' 
	oFieldsJsw['STARTTIME']				:= 'NC5_HRINI' 
	oFieldsJsw['ENDDATE']				:= 'NC5_DTTER' 
	oFieldsJsw['ENDTIME']				:= 'NC5_HRTER' 
	oFieldsJsw['STATUS']				:= 'NC5_STATUS' 
	oFieldsJsw['USERCODE']				:= 'NC5_CODUSU' 
	oFieldsJsw['NOTE']					:= 'NC5_OBSPAR' 
	oFieldsJsw['INTERNALID']			:= ''

return oFieldsJsw


/*/{Protheus.doc} GetCottonGinBreakPointings
//Responsável por fazer a busca de tipos de paradas
@author Christopher.miranda
@since 04/12/2018
@version 1.0
@return lRet, retorno lógico.
@param aQryParam, array, descricao
@type function
/*/
Method GetCottonGinBreakPointings(cParCodUni) CLASS FWCottonGinBreakPointingsAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local nJ			as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasNC5 	as CHARACTER
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
		
		cAliasNC5 := 'NC5'
		If Empty(cParCodUni)
			cUniqueCode := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cUniqueCode := cParCodUni
		EndIf
				
		Self:oEaiObjSnd:Activate()	
		self:oEaiObjSn2:Activate()		
		
		lNext := .T.
		cAliasNC5 := Self:CreateQuery(cParCodUni)
		
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
			If !((cAliasNC5)->(Eof()))
				While !((cAliasNC5)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasNC5)->(dbskip())
						LOOP
					endIf
				
					for nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasNC5)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNC5)->&(Self:oFieldsJson['Code']))
						else	
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNC5)->&(Self:oFieldsJson[cField]))
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
					
					(cAliasNC5)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()
					
					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec, ) )
			endIf	
			(cAliasNC5)->(DBCloseArea())	
			
		else
			if !((cAliasNC5)->(EOF()))
				for nJ := 1 to Len(aSelFields)
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasNC5)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNC5)->&(Self:oFieldsJson['Code'])
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNC5)->&(Self:oFieldsJson[cField]))
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
		endIf
	
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author Christopher.miranda
@since 04/12/2018
@version 1.0
@return cAliasNC5, Tabela temporária gerada pela consulta no banco

@type function
/*/
Method CreateQuery(cCod) CLASS FWCottonGinBreakPointingsAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cAliasNC5    as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasNC5 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""

    if SELECT(cAliasNC5) > 0
        (cAliasNC5)->(dbCloseArea())
        cAliasNC5 	:= GetNextAlias()
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
			if Empty(FWxFilial("NC5")) .AND. LEN(StrTokArr( cCod, "|" )) = 1//Significa que a filial é compartilhada
                aRet := {FWxFilial("NC5"),StrTokArr( cCod, "|" )[1]}
            else
                aRet := StrTokArr( cCod, "|" ) // veio do get 
            endIf
            cWhere := " NC5_FILIAL = '" + aRet[1] + "' AND  NC5_CODIGO = '" + aRet[2] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " NC5_FILIAL = '" + aRet[1] + "' AND  NC5_CODIGO = '" + aRet[2] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "
		cQuery2 := " FROM  " + RetSqlName("NC5") + " NC5"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += " AND D_E_L_E_T_ = ' '"
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
			
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNC5,.F.,.T.)
		
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
	
Return cAliasNC5

METHOD IncludeCottonGinBreakPointings() CLASS FWCottonGinBreakPointingsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlNC5 		as OBJECT
	Local lFilLog		as LOGICAL
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	
	cUserBenf := ""
	cCodId 	:= ""
	lRet 	:= .T.
	
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('BranchId')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('BranchId'))
	
		DbSelectArea("DXE")
		DXE->(dbSetOrder( 1 )) //Filial + Codigo
		If DXE->(dbSeek( PADR(Self:oEaiObjRec:getPropValue('BranchId'),TamSX3("NC5_FILIAL")[1]) + iif(!Empty(Self:oEaiObjRec:getPropValue('CottonGinCode')),Self:oEaiObjRec:getPropValue('CottonGinCode'),"" )))
			
			oModel := FWLoadModel('UBAA120')
			oModel:SetOperation( MODEL_OPERATION_UPDATE)
			oModel:Activate()
			
			oMdlNC5 := oModel:GetModel('MdFieldNC5')
			
			oMdlNC5:AddLine()
			oMdlNC5:GoLine(oMdlNC5:LENGTH())
			
			If lRet .And. PADR(Self:oEaiObjRec:getPropValue('BranchId'),TamSX3("NC5_FILIAL")[1]) = FWxFilial('NC5')
				lRet := oMdlNC5:SetValue('NC5_FILIAL', Self:oEaiObjRec:getPropValue('BranchId'))
			else
				lRet := .F.
			EndIf	
			If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Code'))
				lRet := oMdlNC5:SetValue('NC5_CODIGO', Self:oEaiObjRec:getPropValue('Code'))
			else
				lRet := .F.
			EndIf
		    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonGinCode'))
				lRet := oMdlNC5:SetValue('NC5_CONJTO', Self:oEaiObjRec:getPropValue('CottonGinCode'))
			else
				lRet := .F.
			EndIf
		    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonGinBreakCode'))
				lRet := oMdlNC5:SetValue('NC5_CODMOT', Self:oEaiObjRec:getPropValue('CottonGinBreakCode'))
			else
				lRet := .F.
			EndIf
		    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ShiftCode'))
				lRet := oMdlNC5:SetValue('NC5_TURNO', Self:oEaiObjRec:getPropValue('ShiftCode'))
			else
				lRet := .F.
			EndIf
		    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('StartDate'))
				lRet := oMdlNC5:SetValue('NC5_DTINI', SToD(Self:oEaiObjRec:getPropValue('StartDate')))
			else
				lRet := .F.
			EndIf
		    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('StartTime'))
				lRet := oMdlNC5:SetValue('NC5_HRINI', Self:oEaiObjRec:getPropValue('StartTime'))
			else
				lRet := .F.
			EndIf
		    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('EndDate'))
				lRet := oMdlNC5:SetValue('NC5_DTTER', SToD(Self:oEaiObjRec:getPropValue('EndDate')))
			else
				lRet := .F.
			EndIf
		    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('EndTime'))
				lRet := oMdlNC5:SetValue('NC5_HRTER', Self:oEaiObjRec:getPropValue('EndTime'))
			else
				lRet := .F.
			EndIf
		    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('UserCode'))
				lRet := oMdlNC5:SetValue('NC5_CODUSU', Self:oEaiObjRec:getPropValue('UserCode'))
			else
				lRet := .F.
			EndIf
		    If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Note'))
				lRet := oMdlNC5:SetValue('NC5_OBSPAR', Self:oEaiObjRec:getPropValue('Note'))
			else
				lRet := .F.
			EndIf
		    If lRet
				lRet := oMdlNC5:SetValue('NC5_STATUS' , Self:oEaiObjRec:getPropValue('Status'))
			EndIf
		else
			RollBackSX8()
			Self:oEaiObjRec:setError("Beneficiadora não encontrada.")
			Self:cError := "Beneficiadora não encontrada."
			lRet := .F.	
			Self:lOk := .F.
	    endIf
	    
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()	
			ConfirmSX8()	
			Self:lOk := .T.
			cCodId   := oMdlNC5:GETVALUE("NC5_FILIAL") + "|" + oMdlNC5:GETVALUE("NC5_CODIGO")
		EndIf
		If !EMPTY(oModel) .AND. !oModel:VldData()
			RollBackSX8()
			Self:oEaiObjRec:setError(AGRGMSGERR(oModel:GetErrorMessage()))
			Self:lOk := .F.
			Self:cError := cValToChar(AGRGMSGERR(oModel:GetErrorMessage()))
		Elseif !lRet .and. (!EMPTY(oModel) .AND. oModel:VldData() )
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

Method AlteraCottonGinBreakPointings() CLASS FWCottonGinBreakPointingsAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oMdlNC5 		as OBJECT
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	
	cUserBenf 	:= ""
	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	DbSelectArea("DXE")
	DXE->(dbSetOrder( 1 )) //Filial + Codigo
	If DXE->(dbSeek( PADR(Self:oEaiObjRec:getPropValue('BranchId'),TamSX3("NC5_FILIAL")[1]) + iif(!Empty(Self:oEaiObjRec:getPropValue('CottonGinCode')),Self:oEaiObjRec:getPropValue('CottonGinCode'),"" )))
		NC5->(dbSetOrder( 1 ))
		If !EMPTY(cCodId) .AND. NC5->(dbSeek(PADR(aRet[1],TamSX3("NC5_FILIAL")[1]) + aRet[2]))
			oModel := FWLoadModel('UBAA120')
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			oModel:Activate()
			
			oMdlNC5 := oModel:GetModel('MdFieldNC5')
		
			if !Empty(Self:oEaiObjRec:getPropValue('BranchId')) .AND. PADR(aRet[1],TamSX3("NC5_FILIAL")[1]) != Self:oEaiObjRec:getPropValue('BranchId')
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
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('CottonGinCode'))
				lRet := oMdlNC5:SetValue('NC5_CONJTO', Self:oEaiObjRec:getPropValue('CottonGinCode'))
			else
				lRet := .F.
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('CottonGinBreakCode'))
				lRet := oMdlNC5:SetValue('NC5_CODMOT', Self:oEaiObjRec:getPropValue('CottonGinBreakCode'))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ShiftCode'))
				lRet := oMdlNC5:SetValue('NC5_TURNO', Self:oEaiObjRec:getPropValue('ShiftCode'))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('StartDate'))
				lRet := oMdlNC5:SetValue('NC5_DTINI', SToD(Self:oEaiObjRec:getPropValue('StartDate')))
			endif
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('StartTime'))
				lRet := oMdlNC5:SetValue('NC5_HRINI', Self:oEaiObjRec:getPropValue('StartTime'))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('EndDate'))
				lRet := oMdlNC5:SetValue('NC5_DTTER', SToD(Self:oEaiObjRec:getPropValue('EndDate')))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('EndTime'))
				lRet := oMdlNC5:SetValue('NC5_HRTER', Self:oEaiObjRec:getPropValue('EndTime'))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('Status'))
				lRet := oMdlNC5:SetValue('NC5_STATUS', Self:oEaiObjRec:getPropValue('Status'))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('UserCode'))
				lRet := oMdlNC5:SetValue('NC5_CODUSU', Self:oEaiObjRec:getPropValue('UserCode'))
			endIf
			if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('Note'))
				lRet := oMdlNC5:SetValue('NC5_OBSPAR', Self:oEaiObjRec:getPropValue('Note'))
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
				Self:oEaiObjRec:setError("Verifique se todos os campos obrigatórios estão preenchidos.")
				Self:lOk := .F.
				Self:cError := "Verifique se todos os campos obrigatórios estão preenchidos."
			endIf	
			oModel:DeActivate()
		else
			Self:oEaiObjRec:setError("Motivo de parada não encontrado com a chave informada.")
			Self:cError := "Motivo de parada não encontrado com a chave informada."
			Self:lOk := .F.
			lRet := .F.
		endIf
	Else
		Self:oEaiObjRec:setError("Beneficiadora não encontrado com a chave informada.")
		Self:cError := "Beneficiadora não encontrado com a chave informada."
		Self:lOk := .F.
		lRet := .F.
	EndIf
	
Return cCodId

Method DeleteCottonGinBreakPointings() CLASS FWCottonGinBreakPointingsAdapter
	Local cCodId		as CHARACTER
	Private cUserBenf   as CHARACTER
	
	cUserBenf 	:= ""	
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do DELETE por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	NC5->(dbSetOrder( 1 ))
	If NC5->(dbSeek( aRet[1] + aRet[2]) ) 
		
		/*oModel := FWLoadModel('UBAA120')
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
		
		if RecLock("NC5", .F.)
			dbDelete()
			MsUnlock()
		endIf
	Else
		Self:oEaiObjRec:setError("Apontamento não encontrado com o InternalId informado.")
		Self:lOk := .F.
		Self:cError := "Apontamento não encontrado com o InternalId informado."
	EndIf  
	
Return cCodId