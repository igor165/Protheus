#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWCottonGinMachinesAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cCottonGinMachine	as CHARACTER
	DATA cError       		as CHARACTER
	DATA cInternalId		as CHARACTER
	DATA cMsgName     		as CHARACTER
	DATA cTipRet	  		as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		  		as OBJECT
	DATA oFieldsJson  		as OBJECT
	DATA oArrayJson  		as OBJECT
	DATA oArr2Json  		as OBJECT
	DATA oFieldsJsw   		as OBJECT
	DATA oEaiObjSnd   		as OBJECT
	DATA oEaiObjSn2   		as OBJECT
	DATA oEaiObjRec   		as OBJECT

	METHOD NEW()	
	METHOD GetCottonGinMachines()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludeCottonGinMachine()
	METHOD AlteraCottonGinMachine()
	METHOD DeleteCottonGinMachine()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author brunosilva
@since 13/12/2018
@version 1.0

@type function
/*/
Method NEW() CLASS FWCottonGinMachinesAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:cCottonGinMachine	  		:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'Conjuntos'
	Self:cSelectedFields 	:= ''
	Self:cTipRet		 	:= '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson  		:= self:GetNames()[1]
	self:oArrayJson	  		:= self:GetNames()[2]
	self:oArr2Json	  		:= self:GetNames()[3]
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
Method GetNames() CLASS FWCottonGinMachinesAdapter
	Local oFieldsJson as OBJECT
	
	oArrayJson 	:= &('JsonObject():New()')
	oFieldsJson := &('JsonObject():New()')
	oArr2Json 	:= &('JsonObject():New()')

	oFieldsJson['InternalId']   				:= ''
	oFieldsJson['BranchId']						:= 'DXE_FILIAL'
	oFieldsJson['CottonGinMachineCode']			:= 'DXE_CODIGO'	
	oFieldsJson['Description']					:= 'DXE_DESCRI'
	oFieldsJson['SAICode']						:= 'DXE_CODSAI'
	oFieldsJson['CottonGinCode']				:= 'DXE_UBA'
	//oFieldsJson['CottonGinName']				:= 'DXE_NMUBA'
	oFieldsJson['AdditionalBalanceWeight']		:= 'DXE_PSBAL'
	oFieldsJson['MinimumWeight']				:= 'DXE_PSMIN'
	oFieldsJson['MaximumWeight']				:= 'DXE_PSMAX'
	oFieldsJson['MinimumYield']					:= 'DXE_RDMIN'
	oFieldsJson['MaximumYield']					:= 'DXE_RDMAX'
	oFieldsJson['AverageYield']					:= 'DXE_RDMED'
	oFieldsJson['ExpectedStartDate']			:= 'DXE_DTINIB'
	oFieldsJson['ExpectedEndDate']				:= 'DXE_DTFINB'
	oFieldsJson['NumberSaws']					:= 'DXE_NUMSER'
	oFieldsJson['KilosPerHour']					:= 'DXE_KGPHR'
	oFieldsJson['ProductiveHours']				:= 'DXE_HRPROD'
	oFieldsJson['CottonBalesPerDay']			:= 'DXE_FRDDIA'
	oFieldsJson['ExceedIncome']					:= 'DXE_ULTREN'
	
	oArrayJson['BranchId']						:= 'DXF_FILIAL'
	oArrayJson['CottonGinMachineCode']			:= 'DXF_CODIGO'
	oArrayJson['ItemCode']						:= 'DXF_ITEM'
	oArrayJson['ProductCode']					:= 'DXF_CODPRO'
	//oArrayJson['ProductDescription']			:= 'DXF_DESPRO'
	oArrayJson['ProductAmount']					:= 'DXF_QTDPRO'
	oArrayJson['UnitWeight'] 					:= 'DXF_PSUNIT'
	oArrayJson['WarehouseCode']					:= 'DXF_LOCAL'
	oArrayJson['WeightScale']					:= 'DXF_CPBAL'	
	oArrayJson['MoveStock']						:= 'DXF_MOVEST'
	oArrayJson['TransactionType']				:= 'DXF_TM'
	oArrayJson['ProductLot']					:= 'DXF_LOTCTL'
	oArrayJson['ProductSubLot']					:= 'DXF_NMLOT'
	oArrayJson['ProductAdress']					:= 'DXF_LOCLIZ'
	
	oArr2Json['BranchId']						:= 'DXC_FILIAL'
	oArr2Json['CottonGinMachineCode']			:= 'DXC_CODIGO'
	oArr2Json['ItemCode']						:= 'DXC_ITEM'
	oArr2Json['Productcode']					:= 'DXC_CODPRO'
	//oArr2Json['ProductDescription']				:= 'DXC_DESPRO'
	oArr2Json['WarehouseCode']					:= 'DXC_LOCAL'
	oArr2Json['CottonFeather']					:= 'DXC_PLUMA'
	oArr2Json['SeparationType']					:= 'DXC_TIPO'
	oArr2Json['SeparationPercentual']			:= 'DXC_PERC'
	oArr2Json['CostSharing']					:= 'DXC_RATEIO'
	oArr2Json['GenerateProduction']				:= 'DXC_GRPROD'
	oArr2Json['ProductionProductCode']			:= 'DXC_PRDPRO'
	//oArr2Json['ProductionProductDescription']	:= 'DXC_PRDDES'
	oArr2Json['ProductionWarehouse']			:= 'DXC_LOCPRD'
	oArr2Json['TransactionType']				:= 'DXC_TM'
	oArr2Json['ProductLot']						:= 'DXC_LOTCTL'
	oArr2Json['ProductSubLot']					:= 'DXC_NMLOT'
	oArr2Json['ProductAdress']					:= 'DXC_LOCLIZ'
	oArr2Json['ProductionProductLot']			:= 'DXC_LOTPRD'
	//oArr2Json['ProductionProductSubLot']		:= 'DXC_NMPRD'
	oArr2Json['ProductionProductAdress']		:= 'DXC_LCLPRD'
	oArr2Json['ProductType']					:= 'DXC_SITLAV'
return {oFieldsJson, oArrayJson,oArr2Json}


Method GetNmsW() CLASS FWCottonGinMachinesAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')
	
	oFieldsJsw['INTERNALID']   					:= ''
	oFieldsJsw['BRANCHID']						:= 'DXE_FILIAL'
	oFieldsJsw['COTTONGINMACHINECODE']			:= 'DXE_CODIGO'	
	oFieldsJsw['DESCRIPTION']					:= 'DXE_DESCRI'
	oFieldsJsw['SAICODE']						:= 'DXE_CODSAI'
	oFieldsJsw['COTTONGINCODE']					:= 'DXE_UBA'
	//oFieldsJsw['COTTONGINNAME']					:= 'DXE_NMUBA'
	oFieldsJsw['ADDITIONALBALANCEWEIGHT']		:= 'DXE_PSBAL'
	oFieldsJsw['MINIMUMWEIGHT']					:= 'DXE_PSMIN'
	oFieldsJsw['MAXIMUMWEIGHT']					:= 'DXE_PSMAX'
	oFieldsJsw['MINIMUMYIELD']					:= 'DXE_RDMIN'
	oFieldsJsw['MAXIMUMYIELD']					:= 'DXE_RDMAX'
	oFieldsJsw['AVERAGEYIELD']					:= 'DXE_RDMED'
	oFieldsJsw['EXPECTEDSTARTDATE']				:= 'DXE_DTINIB'
	oFieldsJsw['EXPECTEDENDDATE']				:= 'DXE_DTFINB'
	oFieldsJsw['NUMBERSAWS']					:= 'DXE_NUMSER'
	oFieldsJsw['KILOSPERHOUR']					:= 'DXE_KGPHR'
	oFieldsJsw['PRODUCTIVEHOURS']				:= 'DXE_HRPROD'
	oFieldsJsw['COTTONBALESPERDAY']				:= 'DXE_FRDDIA'
	oFieldsJsw['EXCEEDINCOME']					:= 'DXE_ULTREN'
return oFieldsJsw

/*/{Protheus.doc} GetCottonGinMachines
//Responsável por trazer a busca de Un. de beneficamento(s)
@author brunosilva
@since 10/12/2018
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, Código único do conjunto
@type function
/*/
Method GetCottonGinMachines(cCodId) CLASS FWCottonGinMachinesAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local lFields		as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasDXE 	as CHARACTER
	Local cAliasDXF 	as CHARACTER
	Local cAliasDXC		as CHARACTER
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
	lFields		:= .F.
	cQuery 	 	:= ''
	cError   	:= ''		
	nCount   	:= 0
	oTempJson	:= &('JsonObject():New()')
	
	if Self:lApi
		if !(EMPTY(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		cAliasDXE := 'DXE'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
				
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasDXE := aRetAlias[1]
		cAliasDXF := aRetAlias[2]
		cAliasDXC := aRetAlias[3]
		
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
				lFields := .T. //ele mandou na URL os campos que quer exibir.
			else
				aSelFields := Self:oFieldsJson:getProperties()
			endIf
		endIf
	endIf
		
	if Self:lOk	
		if self:cTipRet = '1'
			If !((cAliasDXE)->(Eof()))
				While !((cAliasDXE)->(EOF()))
					nCount++
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						(cAliasDXE)->(dbskip())
						LOOP
					endIf
					
					for nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasDXE)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasDXE)->&(Self:oFieldsJson['CottonGinMachineCode'])) 
						else
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasDXE)->&(Self:oFieldsJson[cField]))
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
					
					//Se os campos a serem exibidos foram mandados na URL, os filhos não devem aparecer na requisição.
					if !lFields
						nX := 1
						WHILE ((cAliasDXF)->(!Eof())) .AND. (cAliasDXF)->DXF_FILIAL = (cAliasDXE)->&(Self:oFieldsJson['BranchId']) .AND. (cAliasDXF)->DXF_CODIGO = (cAliasDXE)->&(Self:oFieldsJson['CottonGinMachineCode'])
						 	Self:oEaiObjSnd:setProp('AdditionalItems', {})	 
						 		
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('BranchId',				(cAliasDXF)->(DXF_FILIAL))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('CottonGinMachineCode',	(cAliasDXF)->(DXF_CODIGO))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('ItemCode',				(cAliasDXF)->(DXF_ITEM))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('ProductCode',			(cAliasDXF)->(DXF_CODPRO))
					 		//Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('ProductDescription',	(cAliasDXF)->(DXF_DESPRO))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('ProductAmount',		(cAliasDXF)->(DXF_QTDPRO))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('UnitWeight',			(cAliasDXF)->(DXF_PSUNIT))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('WarehouseCode',		(cAliasDXF)->(DXF_LOCAL))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('WeightScale',			(cAliasDXF)->(DXF_CPBAL))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('MoveStock',			(cAliasDXF)->(DXF_MOVEST))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('TransactionType',		(cAliasDXF)->(DXF_TM))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('ProductLot',			(cAliasDXF)->(DXF_LOTCTL))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('ProductSubLot',		(cAliasDXF)->(DXF_PSUNIT))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('ProductAdress',		(cAliasDXF)->(DXF_NMLOT))
					 		Self:oEaiObjSnd:getpropvalue('AdditionalItems')[nX]:setprop('UnitWeight',			(cAliasDXF)->(DXF_LOCLIZ))
							
							(cAliasDXF)->(DbSkip())
							nX++							
						end
						
						nX := 1
						WHILE ((cAliasDXC)->(!Eof())) .AND. (cAliasDXC)->DXC_FILIAL = (cAliasDXE)->&(Self:oFieldsJson['BranchId']) .AND. (cAliasDXC)->DXC_CODIGO = (cAliasDXE)->&(Self:oFieldsJson['CottonGinMachineCode'])
						 	Self:oEaiObjSnd:setProp('ItemsPercentualSeparation', {})	 
						 		
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('BranchId',						(cAliasDXC)->(DXC_FILIAL))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('CottonGinMachineCode',			(cAliasDXC)->(DXC_CODIGO))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ItemCode',						(cAliasDXC)->(DXC_ITEM))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductCode',					(cAliasDXC)->(DXC_CODPRO))
					 		//Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductDescription',				(cAliasDXC)->(DXC_DESPRO))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('WarehouseCode',					(cAliasDXC)->(DXC_LOCAL))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('CottonFeather',					(cAliasDXC)->(DXC_PLUMA))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('SeparationType',					(cAliasDXC)->(DXC_TIPO))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('SeparationPercentual',			(cAliasDXC)->(DXC_PERC))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('CostSharing',					(cAliasDXC)->(DXC_RATEIO))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('GenerateProduction',				(cAliasDXC)->(DXC_GRPROD))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductionProductCode',			(cAliasDXC)->(DXC_PRDPRO))
					 		//Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductionProductDescription',	(cAliasDXC)->(DXC_PRDDES))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductionWarehouse',			(cAliasDXC)->(DXC_LOCPRD))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('TransactionType',				(cAliasDXC)->(DXC_TM))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductLot',						(cAliasDXC)->(DXC_LOTCTL))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductSubLot',					(cAliasDXC)->(DXC_NMLOT))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductAdress',					(cAliasDXC)->(DXC_LOCLIZ))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductionProductLot',			(cAliasDXC)->(DXC_LOTPRD))
					 		//Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductionProductSubLot',		(cAliasDXC)->(DXC_NMPRD))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductionProductAdress',		(cAliasDXC)->(DXC_LCLPRD))
					 		Self:oEaiObjSnd:getpropvalue('ItemsPercentualSeparation')[nX]:setprop('ProductType',					(cAliasDXC)->(DXC_SITLAV))
							
							(cAliasDXC)->(DbSkip())
							nX++							
						end
					endIf
					
					RestArea(aArea)			
					(cAliasDXE)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()

					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
			endIf	
			(cAliasDXE)->(DBCloseArea())	
			(cAliasDXF)->(DBCloseArea())
		else			
			if !((cAliasDXE)->(EOF()))
				for nJ := 1 to Len(aSelFields)
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasDXE)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasDXE)->&(Self:oFieldsJson['CottonGinMachineCode'])
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasDXE)->&(Self:oFieldsJson[cField]))
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
				
				self:oEaiObjSn2['AdditionalItems'] := {}
				Aadd(self:oEaiObjSn2['AdditionalItems'], JsonObject():New())
							
				aArea := GetArea()
				(cAliasDXF)->(dbGoTop())	
				nX := 1
				WHILE ((cAliasDXF)->(!Eof())) .AND. (cAliasDXF)->DXF_FILIAL = (cAliasDXE)->&(Self:oFieldsJson['BranchId']) .AND. (cAliasDXF)->DXF_CODIGO = (cAliasDXE)->&(Self:oFieldsJson['CottonGinMachineCode'])
				 	if nX != 1
				 		Aadd(self:oEaiObjSn2['AdditionalItems'], JsonObject():New())
				 	endIf
				 	
				 	self:oEaiObjSn2['AdditionalItems'][nX]['BranchId']				:= (cAliasDXF)->(DXF_FILIAL)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['CottonGinMachineCode']	:= (cAliasDXF)->(DXF_CODIGO)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['ItemCode']				:= (cAliasDXF)->(DXF_ITEM)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['ProductCode']			:= (cAliasDXF)->(DXF_CODPRO)
			 		//self:oEaiObjSn2['AdditionalItems'][nX]['ProductDescription']	:= (cAliasDXF)->(DXF_DESPRO)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['ProductAmount'] 		:= (cAliasDXF)->(DXF_QTDPRO)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['UnitWeight']			:= (cAliasDXF)->(DXF_PSUNIT)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['WarehouseCode']			:= (cAliasDXF)->(DXF_LOCAL)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['WeightScale']			:= (cAliasDXF)->(DXF_CPBAL)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['MoveStock']				:= (cAliasDXF)->(DXF_MOVEST)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['TransactionType']		:= (cAliasDXF)->(DXF_TM)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['ProductLot']			:= (cAliasDXF)->(DXF_LOTCTL)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['ProductSubLot']			:= (cAliasDXF)->(DXF_NMLOT)
			 		self:oEaiObjSn2['AdditionalItems'][nX]['ProductAdress']			:= (cAliasDXF)->(DXF_LOCLIZ)
					
					(cAliasDXF)->(DbSkip())
					nX++							
				end
				
				self:oEaiObjSn2['ItemsPercentualSeparation'] := {}
				Aadd(self:oEaiObjSn2['ItemsPercentualSeparation'], JsonObject():New())
				
				(cAliasDXC)->(dbGoTop())
				nX := 1
				WHILE ((cAliasDXC)->(!Eof())) .AND. (cAliasDXC)->DXC_FILIAL = (cAliasDXE)->&(Self:oFieldsJson['BranchId']) .AND. (cAliasDXC)->DXC_CODIGO = (cAliasDXE)->&(Self:oFieldsJson['CottonGinMachineCode'])
				 	if nX != 1
				 		Aadd(self:oEaiObjSn2['ItemsPercentualSeparation'], JsonObject():New())
				 	endIf
				 	
				 	self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['BranchId']						:= (cAliasDXC)->(DXC_FILIAL)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['CottonGinMachineCode']			:= (cAliasDXC)->(DXC_CODIGO)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['Item']							:= (cAliasDXC)->(DXC_ITEM)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductCode']						:= (cAliasDXC)->(DXC_CODPRO)
			 		//self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductDescription']				:= (cAliasDXC)->(DXC_DESPRO)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['WarehouseCode'] 					:= (cAliasDXC)->(DXC_LOCAL)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['CottonFeather']					:= (cAliasDXC)->(DXC_PLUMA)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['SeparationType']					:= (cAliasDXC)->(DXC_TIPO)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['SeparationPercentual']			:= (cAliasDXC)->(DXC_PERC)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['CostSharing']						:= (cAliasDXC)->(DXC_RATEIO)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['GenerateProduction']				:= (cAliasDXC)->(DXC_GRPROD)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductionProductCode']			:= (cAliasDXC)->(DXC_PRDPRO)
			 		//self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductionProductDescription']	:= (cAliasDXC)->(DXC_PRDDES)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductionWarehouse']				:= (cAliasDXC)->(DXC_LOCPRD)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['TransactionType']					:= (cAliasDXC)->(DXC_TM)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductLot']						:= (cAliasDXC)->(DXC_LOTCTL)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductSubLot']					:= (cAliasDXC)->(DXC_NMLOT)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductAdress']					:= (cAliasDXC)->(DXC_LOCLIZ)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductionProductLot']			:= (cAliasDXC)->(DXC_LOTPRD)
			 		//self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductionProductSubLot']			:= (cAliasDXC)->(DXC_NMPRD)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductionProductAdress']			:= (cAliasDXC)->(DXC_LCLPRD)
			 		self:oEaiObjSn2['ItemsPercentualSeparation'][nX]['ProductType']						:= (cAliasDXC)->(DXC_SITLAV)
					
					(cAliasDXC)->(DbSkip())
					nX++							
				end
			else
				Self:cError := 'Não existe registro com este código.' + CRLF
			endIf
			(cAliasDXC)->(DBCloseArea())
			(cAliasDXE)->(DBCloseArea())	
			(cAliasDXF)->(DBCloseArea())	
		endIf			
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author brunosilva
@since 10/12/2018
@version 1.0
@return cAliasDXE, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWCottonGinMachinesAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasDXE    as CHARACTER
	Local cAliasDXF    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cQuery3	   as CHARACTER
	Local cQuery4	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasDXC 	:= GetNextAlias()
	cAliasDXE 	:= GetNextAlias()
	cAliasDXF 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	
	if SELECT(cAliasDXE) > 0
		(cAliasDXE)->(dbCloseArea())
		cAliasDXE := GetNextAlias()
		if SELECT(cAliasDXF) > 0 
			(cAliasDXF)->(dbCloseArea())
			cAliasDXF := GetNextAlias()
		endIf
		if SELECT(cAliasDXC) > 0 
			(cAliasDXC)->(dbCloseArea())
			cAliasDXC := GetNextAlias()
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
			cWhere := " DXE_FILIAL = '" + aRet[1] + "' AND DXE_CODIGO = '" + aRet[2] + "'"
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " DXE_FILIAL = '" + aRet[1] + "' AND DXE_CODIGO = '" + aRet[2] + "'"
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "
		cQuery2 := " FROM  " + RetSqlName("DXE") + " DXE"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += "  AND DXE.D_E_L_E_T_ = ' '"
		
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasDXE,.F.,.T.)
		
		if !EMPTY(cValWhe)
			if GETDATASQL("SELECT  COUNT(*)" + cQuery2) > 1
				self:cTipRet = '1'
			else
				self:cTipRet = '2'
				cCod := (cAliasDXE)->DXE_FILIAL + "|" + (cAliasDXE)->DXE_CODIGO
			endIf
		endIf
		
		//ITENS ADICIONAIS
		If !Empty(cCod)
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := " DXF_FILIAL = '" + aRet[1] + "' AND DXF_CODIGO = '" + aRet[2] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " DXF_FILIAL = '" + aRet[1] + "' AND DXF_CODIGO = '" + aRet[2] + "' "
		endIf
		
		cQuery3 := " SELECT  * "
		cQuery3 += " FROM  " + RetSqlName("DXF") + " DXF"
		cQuery3 += " WHERE " + cWhere 
		cQuery3 += " AND DXF.D_E_L_E_T_ = ' '"
		
		cQuery3 := ChangeQuery(cQuery3)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery3),cAliasDXF,.F.,.T.)
		
		//PERCENTUAL DE SEPRAÇÃO DOS INTENS
		If !Empty(cCod)
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := " DXC_FILIAL = '" + aRet[1] + "' AND DXC_CODIGO = '" + aRet[2] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('InternalId')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalId'), "|" )
			cWhere := " DXC_FILIAL = '" + aRet[1] + "' AND DXC_CODIGO = '" + aRet[2] + "' "
		endIf
		
		cQuery4 := " SELECT  * "
		cQuery4 += " FROM  " + RetSqlName("DXC") + " DXC"
		cQuery4 += " WHERE " + cWhere 
		cQuery4 += " AND DXC.D_E_L_E_T_ = ' '"
		
		cQuery4 := ChangeQuery(cQuery4)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery4),cAliasDXC,.F.,.T.)
		
	else
		Self:lOk := .F.
	EndIf
	
Return {cAliasDXE,cAliasDXF,cAliasDXC}


/*/{Protheus.doc} IncludeCottonGinMachine
//Responsável por incluir um conjunto.
@author brunosilva
@since 13/12/2018
@version 1.0
@return cCodId, código do conjunto inserido.

@type function
/*/
METHOD IncludeCottonGinMachine() CLASS FWCottonGinMachinesAdapter
	Local lRet 		as LOGICAL
	Local oModel 	as OBJECT
	Local oMdlDXC 	as OBJECT
	Local oMdlDXE 	as OBJECT
	Local oMdlDXF 	as OBJECT
	Local cCodId	as CHARACTER
	Local nX		as NUMERIC
	Private lFilLog		as LOGICAL
	
	cCodId 	:= ""
	lRet 	:= .T.
	
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('BranchId')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('BranchId'))
	
		oModel := FWLoadModel('AGRA611')
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		
		oMdlDXE := oModel:GetModel('MdFieldDXE')
		oMdlDXF := oModel:GetModel('MdGridDXF')
		oMdlDXC := oModel:GetModel('MdGridDes')
		
		//Para tratar o formato das datas
		Set(_SET_DATEFORMAT, 'mm/dd/yyyy')
		
		If lRet
			lRet := oMdlDXE:LoadValue('DXE_FILIAL', FWxFilial("DXE"))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonGinMachineCode'))
			lRet := oMdlDXE:SetValue('DXE_CODIGO', Self:oEaiObjRec:getPropValue('CottonGinMachineCode'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Description'))
			lRet := oMdlDXE:SetValue('DXE_DESCRI', Self:oEaiObjRec:getPropValue('Description'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('SAICode'))
			lRet := oMdlDXE:SetValue('DXE_CODSAI', Self:oEaiObjRec:getPropValue('SAICode'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonGinCode'))
			lRet := oMdlDXE:SetValue('DXE_UBA', Self:oEaiObjRec:getPropValue('CottonGinCode'))
		else
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('AdditionalBalanceWeight'))
			lRet := oMdlDXE:SetValue('DXE_PSBAL' , VAL(Self:oEaiObjRec:getPropValue('AdditionalBalanceWeight')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('MinimumWeight'))
			lRet := oMdlDXE:SetValue('DXE_PSMIN' , VAL(Self:oEaiObjRec:getPropValue('MinimumWeight')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('MaximumWeight'))
			lRet := oMdlDXE:SetValue('DXE_PSMAX' , VAL(Self:oEaiObjRec:getPropValue('MaximumWeight')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('MinimumYield'))
			lRet := oMdlDXE:SetValue('DXE_RDMIN' , VAL(Self:oEaiObjRec:getPropValue('MinimumYield')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('MaximumYield'))
			lRet := oMdlDXE:SetValue('DXE_RDMAX' , VAL(Self:oEaiObjRec:getPropValue('MaximumYield')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('AverageYield'))
			lRet := oMdlDXE:SetValue('DXE_RDMED' , VAL(Self:oEaiObjRec:getPropValue('AverageYield')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ExpectedStartDate'))
			lRet := oMdlDXE:SetValue('DXE_DTINIB' , SToD(Self:oEaiObjRec:getPropValue('ExpectedStartDate')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ExpectedEndDate'))
			lRet := oMdlDXE:SetValue('DXE_DTFINB' , SToD(Self:oEaiObjRec:getPropValue('ExpectedEndDate')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('NumberSaws'))
			lRet := oMdlDXE:SetValue('DXE_NUMSER' , VAL(Self:oEaiObjRec:getPropValue('NumberSaws')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('KilosPerHour'))
			lRet := oMdlDXE:SetValue('DXE_KGPHR' , VAL(Self:oEaiObjRec:getPropValue('KilosPerHour')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ProductiveHours'))
			lRet := oMdlDXE:SetValue('DXE_HRPROD' , VAL(Self:oEaiObjRec:getPropValue('ProductiveHours')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonBalesPerDay'))
			lRet := oMdlDXE:SetValue('DXE_FRDDIA' , VAL(Self:oEaiObjRec:getPropValue('CottonBalesPerDay')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ExceedIncome'))
			lRet := oMdlDXE:SetValue('DXE_ULTREN' , Self:oEaiObjRec:getPropValue('ExceedIncome'))
		EndIf
		//FIM DA DXE
		
		//INICIO DA DXF
		if lRet .AND. !EMPTY(Self:oEaiObjRec:getPropValue('AdditionalItems'))
			
			Self:oEaiObjRec:GetJson(,.T.)
			For nX := 1 to LEN(Self:oEaiObjRec:getPropValue('AdditionalItems'))				
				
				if nX != 1
					oMdlDXF:AddLine()
					oMdlDXF:GoLine(oMdlDXF:LENGTH())
					
					//lRet := oMdlDXF:LoadValue('DXF_ITEM', IIF(empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ItemCode'),"00"+cValToChar(oMdlDXF:LENGTH()),Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ItemCode'))))			
				endIf	
				
				lRet := oMdlDXF:LoadValue('DXF_ITEM', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ItemCode'))
				
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('BranchId'))
					lRet := oMdlDXF:SetValue('DXF_FILIAL', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('BranchId'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('CottonGinMachineCode'))
					lRet := oMdlDXF:SetValue('DXF_CODIGO', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('CottonGinMachineCode'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ProductCode'))
					lRet := oMdlDXF:SetValue('DXF_CODPRO', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ProductCode'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ProductAmount'))
					lRet := oMdlDXF:SetValue('DXF_QTDPRO', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ProductAmount'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('UnitWeight'))
					lRet := oMdlDXF:SetValue('DXF_PSUNIT', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('UnitWeight'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('WarehouseCode'))
					lRet := oMdlDXF:SetValue('DXF_LOCAL', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('WarehouseCode'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('WeightScale'))
					lRet := oMdlDXF:SetValue('DXF_CPBAL', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('WeightScale'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('MoveStock'))
					lRet := oMdlDXF:SetValue('DXF_MOVEST', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('MoveStock'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('TransactionType'))
					lRet := oMdlDXF:SetValue('DXF_TM', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('TransactionType'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ProductLot'))
					lRet := oMdlDXF:SetValue('DXF_LOTCTL', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ProductLot'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ProductSubLot'))
					lRet := oMdlDXF:SetValue('DXF_NMLOT', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ProductSubLot'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ProductAdress'))
					lRet := oMdlDXF:SetValue('DXF_LOCLIZ', Self:oEaiObjRec:getPropValue('AdditionalItems')[nX]:getPropValue('ProductAdress'))
				endIf			
			next nX
		endIf
		
		if lRet .AND. !EMPTY(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation'))
		
			Self:oEaiObjRec:GetJson(,.T.)
			For nX := 1 to LEN(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation'))				
				
				//if nX != 1
					oMdlDXC:AddLine()
					oMdlDXC:GoLine(oMdlDXC:LENGTH())			
					
					//lRet := oMdlDXC:LoadValue('DXF_ITEM', IIF(empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('Item'),"00"+cValToChar(oMdlDXC:LENGTH()),Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('Item'))))
				//endIf	
				
				lRet := oMdlDXC:LoadValue('DXC_ITEM', IIF(empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('Item')),"00"+cValToChar(oMdlDXC:LENGTH()),Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('Item')))
				
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('BranchId'))
					lRet := oMdlDXC:SetValue('DXC_FILIAL', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('BranchId'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CottonGinMachineCode'))
					//lRet := oMdlDXC:LoadValue('DXC_CODIGO', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CottonGinMachineCode'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductCode'))
					lRet := oMdlDXC:SetValue('DXC_CODPRO', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductCode'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('WarehouseCode'))
					lRet := oMdlDXC:SetValue('DXC_LOCAL', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('WarehouseCode'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CottonFeather'))
					lRet := oMdlDXC:SetValue('DXC_PLUMA', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CottonFeather'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('SeparationType'))
					lRet := oMdlDXC:SetValue('DXC_TIPO', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('SeparationType'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('SeparationPercentual'))
					lRet := oMdlDXC:SetValue('DXC_PERC', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('SeparationPercentual'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CostSharing'))
					lRet := oMdlDXC:SetValue('DXC_RATEIO', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CostSharing'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('GenerateProduction'))
					lRet := oMdlDXC:SetValue('DXC_GRPROD', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('GenerateProduction'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductCode'))
					lRet := oMdlDXC:SetValue('DXC_PRDPRO', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductCode'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionWarehouse'))
					lRet := oMdlDXC:SetValue('DXC_LOCPRD', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionWarehouse'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('TransactionType'))
					lRet := oMdlDXC:SetValue('DXC_TM', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('TransactionType'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductLot'))
					lRet := oMdlDXC:SetValue('DXC_LOTCTL', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductLot'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductSubLot'))
					lRet := oMdlDXC:SetValue('DXC_NMLOT', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductSubLot'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductAdress'))
					lRet := oMdlDXC:SetValue('DXC_LOCLIZ', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductAdress'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductLot'))
					lRet := oMdlDXC:SetValue('DXC_LOTPRD', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductLot'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductAdress'))
					lRet := oMdlDXC:SetValue('DXC_LCLPRD', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductAdress'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductType'))
					lRet := oMdlDXC:SetValue('DXC_SITLAV', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductType'))
				endIf		
			next nX
		endIf
		 
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()	
			ConfirmSX8()	
			Self:lOk := .T.
			cCodId   := oMdlDXE:GETVALUE("DXE_FILIAL") + "|" + oMdlDXE:GETVALUE("DXE_CODIGO") 
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
		Self:oEaiObjRec:setError("Filial(Branch) em branco ou inválida. Favor conferir")
		Self:cError := "Filial(Branch) em branco ou inválida. Favor conferir."
		Self:lOk := .F.
	endIf
	
	
Return cCodId

/*/{Protheus.doc} AlteraCottonGinMachine
//Responsável por alterar o registro passado por parametro.
@author brunosilva
@since 11/12/2018
@version 1.0
@return cCodId, código da entidade alterada.

@type function
/*/
Method AlteraCottonGinMachine() CLASS FWCottonGinMachinesAdapter
	Local lRet 		as LOGICAL
	Local oModel 	as OBJECT
	Local oMdlDXC 	as OBJECT
	Local oMdlDXE 	as OBJECT
	Local oMdlDXF 	as OBJECT
	Local cCodId	as CHARACTER
	
	lRet		:= .T.
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do ALTERA por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	DXE->(dbSetOrder( 1 ))
	If DXE->(dbSeek( aRet[1] + aRet[2])) 
	
		oModel := FWLoadModel('AGRA611')
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
		
		oMdlDXE := oModel:GetModel('MdFieldDXE')
		oMdlDXF := oModel:GetModel('MdGridDXF')
		oMdlDXC := oModel:GetModel('MdGridDes')
		
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('Description'))
			lRet := oMdlDXE:SetValue('DXE_DESCRI', Self:oEaiObjRec:getPropValue('Description'))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('MinimumWeight'))
			lRet := oMdlDXE:SetValue('DXE_PSMIN' , VAL(Self:oEaiObjRec:getPropValue('MinimumWeight')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('MaximumWeight'))
			lRet := oMdlDXE:SetValue('DXE_PSMAX' , VAL(Self:oEaiObjRec:getPropValue('MaximumWeight')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('MinimumYield'))
			lRet := oMdlDXE:SetValue('DXE_RDMIN' , VAL(Self:oEaiObjRec:getPropValue('MinimumYield')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('MaximumYield'))
			lRet := oMdlDXE:SetValue('DXE_RDMAX' , VAL(Self:oEaiObjRec:getPropValue('MaximumYield')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('AverageYield'))
			lRet := oMdlDXE:SetValue('DXE_RDMED' , VAL(Self:oEaiObjRec:getPropValue('AverageYield')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ExpectedStartDate'))
			lRet := oMdlDXE:SetValue('DXE_DTINIB' , SToD(Self:oEaiObjRec:getPropValue('ExpectedStartDate')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ExpectedEndDate'))
			lRet := oMdlDXE:SetValue('DXE_DTFINB' , SToD(Self:oEaiObjRec:getPropValue('ExpectedEndDate')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('NumberSaws'))
			lRet := oMdlDXE:SetValue('DXE_NUMSER' , VAL(Self:oEaiObjRec:getPropValue('NumberSaws')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('KilosPerHour'))
			lRet := oMdlDXE:SetValue('DXE_KGPHR' , VAL(Self:oEaiObjRec:getPropValue('KilosPerHour')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ProductiveHours'))
			lRet := oMdlDXE:SetValue('DXE_HRPROD' , VAL(Self:oEaiObjRec:getPropValue('ProductiveHours')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('CottonBalesPerDay'))
			lRet := oMdlDXE:SetValue('DXE_FRDDIA' , VAL(Self:oEaiObjRec:getPropValue('CottonBalesPerDay')))
		EndIf
		If lRet .And. !Empty(Self:oEaiObjRec:getPropValue('ExceedIncome'))
			lRet := oMdlDXE:SetValue('DXE_ULTREN' , Self:oEaiObjRec:getPropValue('ExceedIncome'))
		EndIf
		//FIM DA DXE
		
		//INICIO DA DXF
		/*if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems'))
			
			self:oeaiobjrec:getjson(,.t.)
			for nx := 1 to len(self:oeaiobjrec:getpropvalue('additionalitems'))				
				
				if !(dxf->(dbseek(aret[1] + aret[2] + self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('itemcode'))))
					omdldxf:addline()
					omdldxf:goline(omdldxf:length())
					
					//lret := omdldxf:loadvalue('dxf_item', iif(empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('itemcode'),"00"+cvaltochar(omdldxf:length()),self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('itemcode'))))			
				endif	
				
				lret := omdldxf:loadvalue('dxf_item', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('itemcode'))
				
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('branchid'))
					lret := omdldxf:setvalue('dxf_filial', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('branchid'))
				endif	
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('cottonginmachinecode'))
					lret := omdldxf:setvalue('dxf_codigo', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('cottonginmachinecode'))
				endif
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('productcode'))
					lret := omdldxf:setvalue('dxf_codpro', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('productcode'))
				endif
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('productamount'))
					lret := omdldxf:setvalue('dxf_qtdpro', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('productamount'))
				endif
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('unitweight'))
					lret := omdldxf:setvalue('dxf_psunit', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('unitweight'))
				endif
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('warehousecode'))
					lret := omdldxf:setvalue('dxf_local', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('warehousecode'))
				endif	
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('weightscale'))
					lret := omdldxf:setvalue('dxf_cpbal', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('weightscale'))
				endif	
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('movestock'))
					lret := omdldxf:setvalue('dxf_movest', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('movestock'))
				endif	
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('transactiontype'))
					lret := omdldxf:setvalue('dxf_tm', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('transactiontype'))
				endif	
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('productlot'))
					lret := omdldxf:setvalue('dxf_lotctl', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('productlot'))
				endif	
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('productsublot'))
					lret := omdldxf:setvalue('dxf_nmlot', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('productsublot'))
				endif	
				if lret .and. !empty(self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('productadress'))
					lret := omdldxf:setvalue('dxf_locliz', self:oeaiobjrec:getpropvalue('additionalitems')[nx]:getpropvalue('productadress'))
				endif			
			next nx
		endif*/
		
		/*if lRet .AND. !EMPTY(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation'))
		
			Self:oEaiObjRec:GetJson(,.T.)
			For nX := 1 to LEN(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation'))				
				
				IF !(DXC->(dbSeek(aRet[1] + aRet[2] + Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('Item'))))
					oMdlDXC:AddLine()
					oMdlDXC:GoLine(oMdlDXC:LENGTH())			
					
					//lRet := oMdlDXC:LoadValue('DXF_ITEM', IIF(empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('Item'),"00"+cValToChar(oMdlDXC:LENGTH()),Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('Item'))))
				endIf	
				
				lRet := oMdlDXC:LoadValue('DXC_ITEM', IIF(empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('Item')),"00"+cValToChar(oMdlDXC:LENGTH()),Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('Item')))
				
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('BranchId'))
					lRet := oMdlDXC:SetValue('DXC_FILIAL', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('BranchId'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CottonGinMachineCode'))
					//lRet := oMdlDXC:LoadValue('DXC_CODIGO', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CottonGinMachineCode'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductCode'))
					lRet := oMdlDXC:SetValue('DXC_CODPRO', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductCode'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('WarehouseCode'))
					lRet := oMdlDXC:SetValue('DXC_LOCAL', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('WarehouseCode'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CottonFeather'))
					lRet := oMdlDXC:SetValue('DXC_PLUMA', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CottonFeather'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('SeparationType'))
					lRet := oMdlDXC:SetValue('DXC_TIPO', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('SeparationType'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('SeparationPercentual'))
					lRet := oMdlDXC:SetValue('DXC_PERC', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('SeparationPercentual'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CostSharing'))
					lRet := oMdlDXC:SetValue('DXC_RATEIO', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('CostSharing'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('GenerateProduction'))
					lRet := oMdlDXC:SetValue('DXC_GRPROD', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('GenerateProduction'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductCode'))
					lRet := oMdlDXC:SetValue('DXC_PRDPRO', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductCode'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionWarehouse'))
					lRet := oMdlDXC:SetValue('DXC_LOCPRD', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionWarehouse'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('TransactionType'))
					lRet := oMdlDXC:SetValue('DXC_TM', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('TransactionType'))
				endIf
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductLot'))
					lRet := oMdlDXC:SetValue('DXC_LOTCTL', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductLot'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductSubLot'))
					lRet := oMdlDXC:SetValue('DXC_NMLOT', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductSubLot'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductAdress'))
					lRet := oMdlDXC:SetValue('DXC_LOCLIZ', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductAdress'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductLot'))
					lRet := oMdlDXC:SetValue('DXC_LOTPRD', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductLot'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductAdress'))
					lRet := oMdlDXC:SetValue('DXC_LCLPRD', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductionProductAdress'))
				endIf	
				if lRet .AND. !Empty(Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductType'))
					lRet := oMdlDXC:SetValue('DXC_SITLAV', Self:oEaiObjRec:getPropValue('ItemsPercentualSeparation')[nX]:getPropValue('ProductType'))
				endIf		
			next nX
		endIf*/
		 
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
		Self:oEaiObjRec:setError("Conjunto não encontrado com a chave informada.")
		Self:lOk := .F.
		Self:cError := "Conjunto não encontrado com a chave informada."
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
Method DeleteCottonGinMachine() CLASS FWCottonGinMachinesAdapter
	Local oModel 		as OBJECT
	Local cCodId		as CHARACTER
	
	cCodId 	    := Self:oEaiObjRec:getPathParam('InternalId')
	
	if !EMPTY(cCodId) //veio do DELETE por ID
		aRet := StrTokArr( cCodId, "|" )
	endIf
	
	DXE->(dbSetOrder( 1 ))
	If DXE->(dbSeek( PADR(aRet[1],TamSX3("DXE_FILIAL")[1]) + aRet[2]) ) 
		oModel := FWLoadModel('AGRA611')
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
		Self:oEaiObjRec:setError("Conjunto não encontrado com o InternalId informado.")
		Self:cError := "Conjunto não encontrado com o InternalId informado."
		Self:lOk := .F.
	EndIf  
	
Return cCodId