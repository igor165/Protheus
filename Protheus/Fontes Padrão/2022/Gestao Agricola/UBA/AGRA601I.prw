#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWCottonBalesAdapter

	DATA lApi        as LOGICAL
	DATA lOk		 as LOGICAL
	
	DATA cRecno   	 as CHARACTER	
	DATA cBranch 	 as CHARACTER
	DATA cCode	 	 as CHARACTER
	DATA cProduct	 as CHARACTER
	DATA cCrop	 	 as CHARACTER
	DATA cUniqueCode as CHARACTER
	DATA cError    	 as CHARACTER
	DATA cMsgName  	 as CHARACTER
	DATA cTipRet	 as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		 as OBJECT
	DATA oBranch     as OBJECT
	DATA oGroup		 as OBJECT
	DATA oFieldsJson as OBJECT
	DATA oFieldsJsw	 as OBJECT
	DATA oEaiObjSnd  as OBJECT
	DATA oEaiObjSn2  as OBJECT
	DATA oEaiObjRec  as OBJECT
	
	METHOD NEW()
	
	METHOD GetCottonBales()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeCottonBale()
	METHOD AlteraCottonBale()
	METHOD DeleteCottonBale()
	
	METHOD CreateQuery()

EndClass

/*/{Protheus.doc} NEW
//Responsável instanciar um objeto e seus devidos atributos. 
@author brunosilva
@since 18/09/2018
@version 1.0

@type method
/*/
Method NEW() CLASS FWCottonBalesAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .T.
	
	Self:cRecno 	 := ''
	Self:cBranch 	 := ''
	Self:cCode	 	 := ''
	Self:cProduct 	 := ''
	Self:cCrop	 	 := ''
	Self:cUniqueCode := ''
	Self:cError      := ''
	Self:cMsgName    := 'FARDOS'	
	Self:cSelectedFields := ''
	Self:cTipRet		 := '' //Tipo de retorno -> 1=Array;2=NãoArray 

	self:oFieldsJson := self:GetNames()
	self:oFieldsJsw   := self:GetNmsW()
	
	self:oEaiObjSnd := FWEAIObj():NEW()
	self:oEaiObjSn2 := JsonObject():New()
	self:oEaiObjRec := Nil
	
	
	
Return

/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author brunosilva
@since 18/09/2018
@version 1.0
@return oFieldsJson, Objeto JSON

@type method
/*/
Method GetNames() CLASS FWCottonBalesAdapter
	 Local oFieldsJson as OBJECT
	 
	 oFieldsJson := &('JsonObject():New()')
	
	 oFieldsJson['InternalId']    	        := 'DXL_CODUNI'
	 oFieldsJson['SourceBranch']            := 'DXL_FILIAL'
	 oFieldsJson['Code']      		        := 'DXL_CODIGO'
	 oFieldsJson['ProductCode']    	        := 'DXL_CODPRO'
	 oFieldsJson['DateOfTyping']            := 'DXL_DTDIGI'
	 oFieldsJson['WareHouse']    	        := 'DXL_LOCAL' 
	 oFieldsJson['Crop']      		        := 'DXL_SAFRA'
	 oFieldsJson['Entity']     		        := 'DXL_PRDTOR'
	 oFieldsJson['EntityStore']    	        := 'DXL_LJPRO'
	 oFieldsJson['Farm']      		        := 'DXL_FAZ'
	 oFieldsJson['EstimatedWeight']         := 'DXL_PSESTI'
	 oFieldsJson['TypeOfPress']    	        := 'DXL_TPRENS'
	 oFieldsJson['Margin']    	 	        := 'DXL_BORDA'
	 oFieldsJson['Unb']      		        := 'DXL_CODUNB'
	 oFieldsJson['PartOfLand']    	        := 'DXL_TALHAO'
	 oFieldsJson['AgriculturalVariety']  	:= 'DXL_CODVAR'
	 oFieldsJson['IntendedIncome']   		:= 'DXL_RDMTOP'
	 // oFieldsJson['Annotation']    		:= 'DXL_OBS'
	 oFieldsJson['HarvestOrder']    		:= 'DXL_ORDCLT'
	 oFieldsJson['IdQCotton']    			:= 'DXL_CODID'
	 oFieldsJson['TagQCotton']    			:= 'DXL_CODETQ'
	 oFieldsJson['XCoordinate']    			:= 'DXL_CORDX'
	 oFieldsJson['YCoordinate']    			:= 'DXL_CORDY'
	 oFieldsJson['ZCoordinate']    			:= 'DXL_CORDZ'
	 oFieldsJson['LotNumber']    			:= 'DXL_LOTCTL'
	 oFieldsJson['SubLotNumber']    		:= 'DXL_NMLOT'
	 oFieldsJson['LotAddress']    			:= 'DXL_LOCLIZ'
	 oFieldsJson['StartHarvestForecast']  	:= 'DXL_INICOL'
	 oFieldsJson['ClosingHarvestForecast'] 	:= 'DXL_ENCCOL'
	 oFieldsJson['ProductionOrder']   		:= 'DXL_OP'
	 oFieldsJson['TareWeight']    			:= 'DXL_PSTARA'
 
return oFieldsJson

Method GetNmsW() CLASS FWCottonBalesAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')

	oFieldsJsw['INTERNALID']    			:= 'DXL_CODUNI'
	oFieldsJsw['SOURCEBRANCH']  			:= 'DXL_FILIAL'
	oFieldsJsw['CODE']						:= 'DXL_CODIGO'
	oFieldsJsw['PRODUCTCODE']				:= 'DXL_CODPRO'
	oFieldsJsw['DATEOFTYPING']				:= 'DXL_DTDIGI'
	oFieldsJsw['WAREHOUSE']					:= 'DXL_LOCAL'
	oFieldsJsw['CROP']						:= 'DXL_SAFRA'
	oFieldsJsw['ENTITY']					:= 'DXL_PRDTOR'
	oFieldsJsw['ENTITYSTORE']				:= 'DXL_LJPRO'
	oFieldsJsw['FARM']						:= 'DXL_FAZ'
	oFieldsJsw['ESTIMATEDWEIGHT']			:= 'DXL_PSESTI'
	oFieldsJsw['TYPEOFPRESS']				:= 'DXL_TPRENS'
	oFieldsJsw['MARGIN']					:= 'DXL_BORDA'
	oFieldsJsw['UNB']						:= 'DXL_CODUNB'
	oFieldsJsw['PARTOFLAND']				:= 'DXL_TALHAO'
	oFieldsJsw['AGRICULTURALVARIETY']		:= 'DXL_CODVAR'
	oFieldsJsw['INTENDEDINCOME']			:= 'DXL_RDMTOP'
	//oFieldsJsw['ANNOTATION']				:= 'DXL_OBS'
	oFieldsJsw['HARVESTORDER']				:= 'DXL_ORDCLT'
	oFieldsJsw['IDQCOTTON']					:= 'DXL_CODID'
	oFieldsJsw['TAGQCOTTON']				:= 'DXL_CODETQ'
	oFieldsJsw['XCOORDINATE']				:= 'DXL_CORDX'
	oFieldsJsw['YCOORDINATE']				:= 'DXL_CORDY'
	oFieldsJsw['ZCOORDINATE']				:= 'DXL_CORDZ'
	oFieldsJsw['LOTNUMBER']					:= 'DXL_LOTCTL'
	oFieldsJsw['SUBLOTNUMBER']				:= 'DXL_NMLOT'
	oFieldsJsw['LOTADDRESS']				:= 'DXL_LOCLIZ'
	oFieldsJsw['STARTHARVESTFORECAST']		:= 'DXL_INICOL'
	oFieldsJsw['CLOSINGHARVESTFORECAST']	:= 'DXL_ENCCOL'
	oFieldsJsw['PRODUCTIONORDER']			:= 'DXL_OP'
	oFieldsJsw['TAREWEIGHT']				:= 'DXL_PSTARA'

return oFieldsJsw

/*/{Protheus.doc} GetCottonBales
//Responsável por fazer a busca de fardões/fardão
@author brunosilva
@since 18/09/2018
@version 1.0
@return lRet, retorno lógico.
@param aQryParam, array, descricao
@type function
/*/
Method GetCottonBales(cParCodUni) CLASS FWCottonBalesAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local nCount     	as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local nJ			as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasDXL 	as CHARACTER
	Local cQuery 	    as CHARACTER
	Local cUniqueCode   as CHARACTER
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
		
		cAliasDXL := 'DXL'
		If Empty(cParCodUni)
			cUniqueCode := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cUniqueCode := cParCodUni
		EndIf
				
		Self:oEaiObjSnd:Activate()	
		self:oEaiObjSn2:Activate()		
		
		lNext := .T.
		cAliasDXL := Self:CreateQuery(cParCodUni)
		
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
			If !((cAliasDXL)->(Eof()))
				While !((cAliasDXL)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasDXL)->(dbskip())
						LOOP
					endIf
				
					for nJ := 1 to Len(aSelFields)
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasDXL)->&(Self:oFieldsJson[cField]))
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
					next nJ
					
					(cAliasDXL)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()
					
					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec, ) )
			endIf	
			(cAliasDXL)->(DBCloseArea())	
		else 
			if !((cAliasDXL)->(EOF()))
				for nJ := 1 to Len(aSelFields)
					cField := aSelFields[nJ]
					cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasDXL)->&(Self:oFieldsJson[cField]))
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
@since 19/09/2018
@version 1.0
@return cAliasDXL, Tabela temporária gerada pela consulta no banco
@param aQryParam, array, Parametros para filtro da busca
@type function
/*/
Method CreateQuery(cParCodUni) CLASS FWCottonBalesAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasDXL    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	
	lRet 		:= .T.
	cAliasDXL 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cOrder		:= ""
	cQuery2		:= ""
	cQuery		:= ""
	
	if SELECT(cAliasDXL) > 0
		(cAliasDXL)->(dbCloseArea())
		cAliasDXL 	:= GetNextAlias()
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
		If .Not. Empty(cParCodUni)
			cWhere := " DXL_CODUNI = '" + cParCodUni + "'"
		Else
			cWhere := " DXL_CODUNI = '" + Self:oEaiObjRec:getPathParam('InternalId') + "'"
		EndIf
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "
		cQuery2 := " FROM  " + RetSqlName("DXL") + " DXL"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += " AND D_E_L_E_T_ = ' '"
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
			
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasDXL,.F.,.T.)
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
	
Return cAliasDXL

/*/{Protheus.doc} IncludeCottonBale
// Reponsável por incluir um registro de fardão no banco
@author brunosilva
@since 19/09/2018
@version 1.0
@return cCodUni, Código unico do fardão inserido

@type function
/*/
Method IncludeCottonBale() CLASS FWCottonBalesAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oDXLMASTER 	as OBJECT
	Local cCodUni		as CHARACTER
	Local lFilLog		as LOGICAL
	
	Private _lNovSafra 	as LOGICAL
	
	_lNovSafra 	:= .T.
	lRet := .T.
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('SourceBranch')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('SourceBranch'))
	
		oModel := FWLoadModel('AGRA601')
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		
		oDXLMASTER := oModel:GetModel('DXLMASTER')
		
		// -----------------------------------------------------------------------------------------------
		// -----------------------------------------------------------------------------------------------
		/* PRENSA, TURNO, DT. BENEFICIAMENTO, HR BENEF.,  SÓ GRAVA QUANDO BENEFICIADO
		 * PSLIQU, TIPO PRENSA, CODIGO DO ROMANEIO, PESO FISCAL, COD. CONJUNTO SÓ GRAVA NO ROMANEIO
		 * RENDIMENTO DE PLUMA, OP DO ENCERRAMENTO, DOCRQ, DOCPR SÓ GRAVA NO ENCERRAMENTO
		 * NUM. DOC SÓ GRAVA AO GERAR OP
		 * STATUS: NO CADASTRO O PADRÃO É PREVISTO.(SISTEMA PREENCHE AUTOMÁTICO)
		 * CODIGO UNICO: É GERADO AUTOMÁTICO.
		 */
		 // -----------------------------------------------------------------------------------------------
		// -----------------------------------------------------------------------------------------------
		
		/* Inicio dos campos obrigatórios */
		If lRet
			lRet := oDXLMASTER:SetValue('DXL_FILIAL', FWxFilial( "DXL" ))
		EndIf
		// Caso o código não seja informado, ele busca o próximo número da tabela.
		If !Empty(Self:oEaiObjRec:getPropValue('Code'))
			oDXLMASTER:SetValue('DXL_CODIGO', Self:oEaiObjRec:getPropValue('Code'))
		ElseIf Empty(oDXLMASTER:GetValue('DXL_CODIGO'))
			oDXLMASTER:SetValue('DXL_CODIGO', GETSXENUM("DXL","DXL_CODIGO"))
		EndIf
		If lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('Crop'))
			lRet := oDXLMASTER:SetValue('DXL_SAFRA' , Self:oEaiObjRec:getPropValue('Crop'))
		else
			lRet := .F.
		EndIf
		If lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ProductCode'))
			lRet := oDXLMASTER:SetValue('DXL_CODPRO', Self:oEaiObjRec:getPropValue('ProductCode'))
		else
			lRet := .F.
		EndIf
		If lRet.AND. !Empty(Self:oEaiObjRec:getPropValue('Entity'))
			lRet := oDXLMASTER:SetValue('DXL_PRDTOR', Self:oEaiObjRec:getPropValue('Entity'))
		else
			lRet := .F.
		EndIf 
		If lRet.AND. !Empty(Self:oEaiObjRec:getPropValue('EntityStore'))
			lRet := oDXLMASTER:SetValue('DXL_LJPRO' , Self:oEaiObjRec:getPropValue('EntityStore'))
		else
			lRet := .F.
		EndIf
		If lRet.AND. !Empty(Self:oEaiObjRec:getPropValue('Farm'))
			lRet := oDXLMASTER:SetValue('DXL_FAZ'   , Self:oEaiObjRec:getPropValue('Farm'))
		else
			lRet := .F.
		EndIf
		If lRet.AND. !Empty(Self:oEaiObjRec:getPropValue('WareHouse'))
			lRet := oDXLMASTER:SetValue('DXL_LOCAL' , Self:oEaiObjRec:getPropValue('WareHouse'))
		else
			lRet := .F.
		EndIf
		If lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('EstimatedWeight'))
			lRet := oDXLMASTER:SetValue('DXL_PSESTI', Self:oEaiObjRec:getPropValue('EstimatedWeight'))
		EndIf
		/* Fim dos campos obrigatórios */
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Margin'))
			lRet := oDXLMASTER:SetValue('DXL_BORDA' , Self:oEaiObjRec:getPropValue('Margin'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Unb'))
			lRet := oDXLMASTER:SetValue('DXL_CODUNB', Self:oEaiObjRec:getPropValue('Unb'))
		endIf
	
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('PartOfLand'))
			lRet := oDXLMASTER:SetValue('DXL_TALHAO', Self:oEaiObjRec:getPropValue('PartOfLand'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('AgriculturalVariety'))
			lRet := oDXLMASTER:SetValue('DXL_CODVAR', Self:oEaiObjRec:getPropValue('AgriculturalVariety'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('IntendedIncome'))
			lRet := oDXLMASTER:SetValue('DXL_RDMTOP', Self:oEaiObjRec:getPropValue('IntendedIncome'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Annotation'))
			lRet := oDXLMASTER:SetValue('DXL_OBS'   , Self:oEaiObjRec:getPropValue('Annotation'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('HarvestOrder'))
			lRet := oDXLMASTER:SetValue('DXL_ORDCLT', Self:oEaiObjRec:getPropValue('HarvestOrder'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('IdQCotton'))
			lRet := oDXLMASTER:SetValue('DXL_CODID' , Self:oEaiObjRec:getPropValue('IdQCotton'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('TagQCotton'))
			lRet := oDXLMASTER:SetValue('DXL_CODETQ', Self:oEaiObjRec:getPropValue('TagQCotton'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('XCoordinate'))
			lRet := oDXLMASTER:SetValue('DXL_CORDX' , Self:oEaiObjRec:getPropValue('XCoordinate'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('YCoordinate'))
			lRet := oDXLMASTER:SetValue('DXL_CORDY' , Self:oEaiObjRec:getPropValue('YCoordinate'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ZCoordinate'))
			lRet := oDXLMASTER:SetValue('DXL_CORDZ' , Self:oEaiObjRec:getPropValue('ZCoordinate'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('LotNumber'))
			lRet := oDXLMASTER:SetValue('DXL_LOTCTL', Self:oEaiObjRec:getPropValue('LotNumber'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('SubLotNumber'))
			lRet := oDXLMASTER:SetValue('DXL_NMLOT' , Self:oEaiObjRec:getPropValue('SubLotNumber'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('LotAddress'))
			lRet := oDXLMASTER:SetValue('DXL_LOCLIZ', Self:oEaiObjRec:getPropValue('LotAddress'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('StartHarvestForecast'))
			lRet := oDXLMASTER:SetValue('DXL_INICOL', Self:oEaiObjRec:getPropValue('StartHarvestForecast'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ClosingHarvestForecast'))
			lRet := oDXLMASTER:SetValue('DXL_ENCCOL', Self:oEaiObjRec:getPropValue('ClosingHarvestForecast'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ProductionOrder'))
			lRet := oDXLMASTER:SetValue('DXL_OP'    , Self:oEaiObjRec:getPropValue('ProductionOrder'))
		endIf
		
		if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('TareWeight'))
			lRet := oDXLMASTER:SetValue('DXL_PSTARA', Self:oEaiObjRec:getPropValue('TareWeight'))
		endIf	
		
		oModel:LoadValue('DXLMASTER','DXL_CODUNI', AGRCdgFrd( PADR(oDXLMASTER:GetValue('DXL_CODIGO'),TamSx3("DXL_CODIGO")[1] ," "), PADR(Self:oEaiObjRec:getPropValue('Crop'),TamSx3("DXL_SAFRA")[1] ," "), PADR(Self:oEaiObjRec:getPropValue('Entity'),TamSx3("DXL_PRDTOR")[1] ," "), PADR(Self:oEaiObjRec:getPropValue('EntityStore'),TamSx3("DXL_LJPRO")[1] ," "), PADR(Self:oEaiObjRec:getPropValue('Farm'),TamSx3("DXL_FAZ")[1] ," ")) )
		 
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()	
			ConfirmSX8()	
			Self:lOk := .T.
			cCodUni := oDXLMASTER:GETVALUE("DXL_CODUNI")
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
	
Return cCodUni


/*/{Protheus.doc} AlteraCottonBale
// Reponsável por incluir um registro de fardão no banco
@author brunosilva
@since 19/09/2018
@version 1.0
@return cCodUni, Código unico do fardão inserido

@type function
/*/
Method AlteraCottonBale() CLASS FWCottonBalesAdapter
	Local lRet 		 	as LOGICAL
	Local oModel 		as OBJECT
	Local oDXLMASTER 	as OBJECT
	Local cCodUni		as CHARACTER
	Local cDateTmp		as CHARACTER
	Local lFilLog		as LOGICAL
	
	Private _lNovSafra 	as LOGICAL	
	
	_lNovSafra 	:= .T.
	lRet	:= .T.
	cCodUni := Self:oEaiObjRec:getPathParam('InternalId')	
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('SourceBranch')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('SourceBranch'))
	
		/* PRENSA, TURNO, DT. BENEFICIAMENTO, HR BENEF.,  SÓ GRAVA QUANDO BENEFICIADO
		 * PSLIQU, TIPO PRENSA, CODIGO DO ROMANEIO, PESO FISCAL, COD. CONJUNTO SÓ GRAVA NO ROMANEIO
		 * RENDIMENTO DE PLUMA, OP DO ENCERRAMENTO, DOCRQ, DOCPR SÓ GRAVA NO ENCERRAMENTO
		 * NUM. DOC SÓ GRAVA AO GERAR OP
		 * STATUS: NO CADASTRO O PADRÃO É PREVISTO.(SISTEMA PREENCHE AUTOMÁTICO)
		 * CODIGO UNICO: É GERADO AUTOMÁTICO.
		 */
		
		dbSelectArea( "DXL" )
		DXL->(dbSetOrder( 2 ))
		If DXL->(dbSeek( fwxFilial( "DXL" ) + PADR(cCodUni,TamSx3("DXL_CODUNI")[1] ," ") ) )
			oModel := FWLoadModel('AGRA601')
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			oModel:Activate()
			oDXLMASTER := oModel:GetModel('DXLMASTER')
			
			if DXL->DXL_STATUS = '1'
			
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('DATEOFTYPING'))
					cDateTmp := Self:oEaiObjRec:getPropValue('DATEOFTYPING')
					cDateTmp := STOD(STRTRAN(cDateTmp, '-', '')) 
					If !Empty(cDateTmp)
						lRet := oDXLMASTER:SetValue('DXL_DTDIGI', cDateTmp)
					Else
						oModel:SetErrorMessage( , , oModel:GetId() , "", "", "A Data de Digitação está inválida.", "Verifique o campo DATEOFTYPING.", "", "")
						lRet := .F.
					EndIf
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ProductCode'))
					lRet := oDXLMASTER:SetValue('DXL_CODPRO', Self:oEaiObjRec:getPropValue('ProductCode'))
				endIf
						
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('PartOfLand'))
					lRet := oDXLMASTER:SetValue('DXL_TALHAO', Self:oEaiObjRec:getPropValue('PartOfLand'))
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('AgriculturalVariety'))
					lRet := oDXLMASTER:SetValue('DXL_CODVAR', Self:oEaiObjRec:getPropValue('AgriculturalVariety'))
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('WareHouse'))
					lRet := oDXLMASTER:SetValue('DXL_LOCAL', Self:oEaiObjRec:getPropValue('WareHouse'))
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('EstimatedWeight'))
					lRet := oDXLMASTER:SetValue('DXL_PSESTI', Self:oEaiObjRec:getPropValue('EstimatedWeight'))
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Margin'))
					lRet := oDXLMASTER:SetValue('DXL_BORDA', Self:oEaiObjRec:getPropValue('Margin'))
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('IntendedIncome'))
					lRet := oDXLMASTER:SetValue('DXL_RDMTOP', Self:oEaiObjRec:getPropValue('IntendedIncome'))
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('TYPEOFPRESS'))
					lRet := oDXLMASTER:SetValue('DXL_TPRENS' , Self:oEaiObjRec:getPropValue('TYPEOFPRESS'))
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Annotation'))
					lRet := oDXLMASTER:SetValue('DXL_OBS' , Self:oEaiObjRec:getPropValue('Annotation'))
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('LotNumber'))
					lRet := oDXLMASTER:SetValue('DXL_LOTCTL' , Self:oEaiObjRec:getPropValue('LotNumber'))
				endIf
		
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('SubLotNumber'))
					lRet := oDXLMASTER:SetValue('DXL_NMLOT' , Self:oEaiObjRec:getPropValue('SubLotNumber'))
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('LotAddress'))
					lRet := oDXLMASTER:SetValue('DXL_LOCLIZ' , Self:oEaiObjRec:getPropValue('LotAddress'))
				endIf
				
				if lRet .And. !Empty(Self:oEaiObjRec:getPropValue('TareWeight'))
					lRet := oDXLMASTER:SetValue('DXL_PSTARA', Self:oEaiObjRec:getPropValue('TareWeight'))
				endIf
						
				If lRet .And. oModel:VldData()		
					lRet := oModel:CommitData()		
					Self:lOk := .T.
				EndIf
				If !lRet
					Self:oEaiObjRec:setError(AGRGMSGERR(oModel:GetErrorMessage()))
					Self:lOk := .F.
					Self:cError := cValToChar(AGRGMSGERR(oModel:GetErrorMessage()))
				EndIf
				oModel:DeActivate()
			else
				Self:cError := "O regisro deste fardão já sofreu movimentações e não pode ser manipulado."
				Self:oEaiObjRec:setError("O registro deste fardão já sofreu movimentações e não pode ser manipulado.")
				Self:lOk := .F.
			endIF
		Else
			Self:oEaiObjRec:setError("Fardão não encontrado com o UniqueCode informado.")
			Self:lOk := .F.
			Self:cError := "Fardão não encontrado com o UniqueCode informado."
		EndIf
	else
		Self:oEaiObjRec:setError("Filial(Branch) em branco ou inválida. Favor conferir")
		Self:cError := "Filial(Branch) em branco ou inválida. Favor conferir."
		Self:lOk := .F.
	endIf
	
Return cCodUni


/*/{Protheus.doc} DeleteCottonBale
// Reponsável por delete um registro de fardão no banco
@author brunosilva
@since 19/09/2018
@version 1.0
@return cCodUni, Código unico do fardão inserido

@type function
/*/
Method DeleteCottonBale() CLASS FWCottonBalesAdapter
	Local oModel 		as OBJECT
	Local cCodUni		as CHARACTER
	Private _lNovSafra 	as LOGICAL	
	
	_lNovSafra 	:= .T.
	cCodUni := Self:oEaiObjRec:getPathParam('InternalId')	
		
	dbSelectArea( "DXL" )
	DXL->(dbSetOrder( 2 ))
	If DXL->(dbSeek( FWxFilial( "DXL" ) + PADR(cCodUni,TamSx3("DXL_CODUNI")[1] ," ") ) )
		oModel := FWLoadModel('AGRA601')
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
		Self:oEaiObjRec:setError("Fardão não encontrado com o UniqueCode informado.")
		Self:lOk := .F.
		Self:cError := "Fardão não encontrado com o UniqueCode informado."
	EndIf  	
	
Return cCodUni
