#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWPackingSlipEntryAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cPackingSlipEntry	as CHARACTER
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
	METHOD GetPackingSlipEntry()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD IncludePackingSlipEntry()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author Silvana Vieira Torres Streit
@since 16/12/2019
@version 1.0

@type function
/*/
Method NEW() CLASS FWPackingSlipEntryAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:cPackingSlipEntry	:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'Romaneio de Entrada'
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
@author Silvana Vieira Torres Streit
@since 16/12/2019
@version 1.0
@return oFieldsJson, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWPackingSlipEntryAdapter
	Local oFieldsJson as OBJECT
	
	oArrayJson 	:= &('JsonObject():New()')
	oFieldsJson := &('JsonObject():New()')

	oFieldsJson['InternalId']   				:= 'NJJ_FILIAL + NJJ_CODROM'
	oFieldsJson['BranchId']						:= 'NJJ_FILIAL'
	oFieldsJson['PackingSlipCode']			    := 'NJJ_CODROM'
	oFieldsJson['Weight1Date']			    	:= 'NJJ_DATPS1'
		
	oArrayJson['BranchId']						:= 'NJK_FILIAL + NJK_CODROM + NJK_ITEM + NJK_TPCLAS'
	oArrayJson['SequenceItem']					:= 'NJK_ITEM'
	oArrayJson['ClassificationType']			:= 'NJK_TPCLAS'
	oArrayJson['DiscountCode']					:= 'NJK_CODDES'
	//oArrayJson['DiscountDescription']			:= 'NJK_DESDES2'
	oArrayJson['BaseWeightForClassific']		:= 'NJK_BASDES'
	oArrayJson['MandatoryDiscount']				:= 'NJK_OBRGT'
	oArrayJson['ClassificationResult']			:= 'NJK_PERDES'
	oArrayJson['DiscountPercentage']			:= 'NJK_READES'
	oArrayJson['Discountity']					:= 'NJK_QTDDES'
	oArrayJson['ResultDescription']				:= 'NJK_DESRES'
	oArrayJson['InformedResult']				:= 'NJK_RESINF'
	
return {oFieldsJson, oArrayJson}


Method GetNmsW() CLASS FWPackingSlipEntryAdapter
	Local oFieldsJsw as OBJECT
	
	oFieldsJsw := &('JsonObject():New()')
	
	oFieldsJsw['INTERNALID']   				:= 'NJJ_FILIAL + NJJ_CODROM'
	oFieldsJsw['BRANCHID']					:= 'NJJ_FILIAL'
	oFieldsJsw['PACKINGSLIPCODE']			:= 'NJJ_CODROM'

return oFieldsJsw

/*/{Protheus.doc} GetPackingSlipEntry
//Responsável por trazer a busca dos romaneios de entrada
@author Silvana Vieira Torres Streit
@since 16/12/2019
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, Código único do conjunto
@type function
/*/
Method GetPackingSlipEntry(cCodId) CLASS FWPackingSlipEntryAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local lFields		as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasNJJ 	as CHARACTER
	Local cAliasNJK 	as CHARACTER
	Local cCodId 	    as CHARACTER
	Local iTp 	        as Numeric
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
		
		cAliasNJJ := 'NJJ'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('InternalId')
		Else
			cCod := cCodId
		EndIf
		
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasNJJ := aRetAlias[1]
		cAliasNJK := aRetAlias[2]
		
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
			If !((cAliasNJJ)->(Eof()))					
				While !((cAliasNJJ)->(EOF()))
					nCount++
					
					For nJ := 1 to Len(aSelFields)
						if aSelFields[nJ] = 'InternalId'
							Self:oEaiObjSnd:setProp('InternalId', (cAliasNJJ)->&(Self:oFieldsJson['BranchId']) + "|" +  (cAliasNJJ)->&(Self:oFieldsJson['PackingSlipCode']) ) 
						else
						
							cField := aSelFields[nJ]
							cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNJJ)->&(Self:oFieldsJson[cField]))
							if cValue != NIL
								IF VALTYPE(cValue) = "C"
									Self:oEaiObjSnd:setProp(cField, AllTrim(cValue))
								elseif VALTYPE(cValue) = "N"
									Self:oEaiObjSnd:setProp(cField, cValToChar(cValue))
								EndIf
							Else
								Self:cError := 'O campo "' + cField + '" não é valido.' + CRLF
								Self:lOk := .F.
								Return()
							EndIf
						EndIf
					Next nJ		
					
					aArea := GetArea()						
					
					//Se os campos a serem exibidos foram mandados na URL, os filhos não devem aparecer na requisição.
					if !lFields
					
						nX := 1
						
						(cAliasNJK)->(dbGotop())
						WHILE ((cAliasNJK)->(!Eof())) 
											
							IF (cAliasNJK)->NJK_FILIAL == (cAliasNJJ)->&(Self:oFieldsJson['BranchId']) .AND. ;
							   (cAliasNJK)->NJK_CODROM == (cAliasNJJ)->&(Self:oFieldsJson['PackingSlipCode'])								
							
						 	Self:oEaiObjSnd:setProp('PackingSlipRating', {})	 
						 	
					 		Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('BranchId'			,(cAliasNJK)->(NJK_FILIAL))
					 		Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('SequenceItem'		,(cAliasNJK)->(NJK_ITEM))
					 		Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('ClassificationType'	,(cAliasNJK)->(NJK_TPCLAS))
					 		Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('DiscountCode'		,(cAliasNJK)->(NJK_CODDES))
					 		//Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('DiscountDescription'	,(cAliasNJK)->(NJK_DESDES2))
					 		Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('BaseWeightForClassific',(cAliasNJK)->(NJK_BASDES))
					 		Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('ClassificationResult',(cAliasNJK)->(NJK_PERDES))
					 		Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('DiscountPercentage'	,(cAliasNJK)->(NJK_READES))
					 		Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('Discountity'			,(cAliasNJK)->(NJK_QTDDES))
					 		Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('ResultDescription'	,(cAliasNJK)->(NJK_DESRES))
					 		Self:oEaiObjSnd:getpropvalue('PackingSlipRating')[nX]:setprop('InformedResult'		,(cAliasNJK)->(NJK_RESINF))
							
							nX++	
							ENDIF
							(cAliasNJK)->(DbSkip())
													
						end
						
					endIf
					
					RestArea(aArea)			
					(cAliasNJJ)->(DbSkip())		
					
					Self:oEaiobjSnd:nextItem()

					nLastRec := nCount
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
				
				Self:oEaiObjSnd:setProp('lastRecno' ,nLastRec)
				Self:oEaiObjSnd:setProp('maxRecno'  ,IIF(EMPTY(nMaxRec),nLastRec,nMaxRec) )
			endIf	
			(cAliasNJJ)->(DBCloseArea())	
			(cAliasNJK)->(DBCloseArea())
		else		
			if !((cAliasNJJ)->(EOF()))
				for nJ := 1 to Len(aSelFields)
				
					if aSelFields[nJ] = 'InternalId'
						Self:oEaiObjSn2['InternalId'] := (cAliasNJJ)->&(Self:oFieldsJson['BranchId']) + "|" + (cAliasNJJ)->&(Self:oFieldsJson['PackingSlipCode'])
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, (cAliasNJJ)->&(Self:oFieldsJson[cField]))
						
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
				
				self:oEaiObjSn2['PackingSlipRating'] := {}
				Aadd(self:oEaiObjSn2['PackingSlipRating'], JsonObject():New())
							
				aArea := GetArea()
				
				(cAliasNJK)->(dbGoTop())	
				nX := 1
				
				WHILE ((cAliasNJK)->(!Eof())) 	
					
					IF (cAliasNJK)->NJK_FILIAL == (cAliasNJJ)->&(Self:oFieldsJson['BranchId']) .AND. ;
					   (cAliasNJK)->NJK_CODROM == (cAliasNJJ)->&(Self:oFieldsJson['PackingSlipCode'])			
				
					 	if nX != 1
					 		Aadd(self:oEaiObjSn2['PackingSlipRating'], JsonObject():New())
					 	endIf
					 	
					 	self:oEaiObjSn2['PackingSlipRating'][nX]['BranchId']				:= (cAliasNJK)->(NJK_FILIAL) 
				 		self:oEaiObjSn2['PackingSlipRating'][nX]['SequenceItem']			:= (cAliasNJK)->(NJK_ITEM) 
				 		self:oEaiObjSn2['PackingSlipRating'][nX]['ClassificationType']		:= (cAliasNJK)->(NJK_TPCLAS)
				 		self:oEaiObjSn2['PackingSlipRating'][nX]['DiscountCode']			:= (cAliasNJK)->(NJK_CODDES)
				 		//self:oEaiObjSn2['PackingSlipRating'][nX]['DiscountDescription']		:= (cAliasNJK)->(NJK_DESDES2)
				 		self:oEaiObjSn2['PackingSlipRating'][nX]['BaseWeightForClassific']	:= (cAliasNJK)->(NJK_BASDES)
				 		self:oEaiObjSn2['PackingSlipRating'][nX]['ClassificationResult']	:= (cAliasNJK)->(NJK_PERDES)
				 		self:oEaiObjSn2['PackingSlipRating'][nX]['DiscountPercentage']		:= (cAliasNJK)->(NJK_READES)
				 		self:oEaiObjSn2['PackingSlipRating'][nX]['Discountity']				:= (cAliasNJK)->(NJK_QTDDES)
				 		self:oEaiObjSn2['PackingSlipRating'][nX]['ResultDescription']		:= (cAliasNJK)->(NJK_DESRES)
				 		self:oEaiObjSn2['PackingSlipRating'][nX]['InformedResult']			:= (cAliasNJK)->(NJK_RESINF)
							
					 				 					 					 		
					Endif
					(cAliasNJK)->(DbSkip())
					nX++							
				end
				
			else
				Self:cError := 'Não existe registro com este código.' + CRLF
			endIf
			(cAliasNJJ)->(DBCloseArea())	
			(cAliasNJK)->(DBCloseArea())
		endIf		
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author Silvana Vieira Torres Streit
@since 16/12/2019
@version 1.0
@return cAliasNJJ, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWPackingSlipEntryAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local nY 		   as NUMERIC
	Local cBranch	   as CHARACTER	
	Local cWhere	   as CHARACTER
	Local cWhereNJK	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasNJJ    as CHARACTER
	Local cAliasNJK    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cQuery3	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	Local lPrimeiro    
	Local lSit  := .F.
	
	lRet 		:= .T.
	cAliasNJJ 	:= GetNextAlias()
	cAliasNJK 	:= GetNextAlias()
	cWhere 		:= "1=1"
	cWhereNJK 	:= "1=1"
	cOrder		:= ""
	cValWhe		:= ""
	
	if SELECT(cAliasNJJ) > 0
		dbCloseArea(cAliasNJJ)
		cAliasNJJ := GetNextAlias()
		if SELECT(cAliasNJK) > 0 
			dbCloseArea(cAliasNJK)
			cAliasNJK := GetNextAlias()
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
				aRet := StrTokArr( oJsonFilter[aTemp[nX]], "|" )
				
				if ValType(oJsonFilter[aTemp[nX]]) != "C"
					oJsonFilter[aTemp[nX]] := str(oJsonFilter[aTemp[nX]])
				EndIf
				
				if len(aRet) == 1
					cWhere += Self:oFieldsJsw[aTemp[nX]] + '=' + "'" + oJsonFilter[aTemp[nX]] + "'"
				Else 
					// Quando houver mais de um parâmetro para o mesmo filtro
					// Ex: OGA250API/api/oga/v1/PackingSlipEntry/?Status=2|5
					If Len(aRet) >= 2
						For nY := 1 to len(aRet)						
							If nY >= 2
								cWhere += ' OR '
							Endif
							cWhere += Self:oFieldsJsw[aTemp[nX]] + '=' + "'" + aRet[nY] + "'"
						Next nY				
					Endif	
				Endif								
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
	Else 
		If !Empty(cCod)		//
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := " NJJ_FILIAL = '" + aRet[1] + "' AND NJJ_CODROM = '" + aRet[2] + "' "		
		ElseIf !EMPTY(Self:oEaiObjRec:getPathParam('InternalID')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('InternalID'), "|" )	
			cWhere := " NJJ_FILIAL = '" + aRet[1] + "' AND NJJ_CODROM = '" + aRet[2] + "' "			
		EndIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := " SELECT  * "
				
		cQuery2 := " FROM  " + RetSqlName("NJJ") + " NJJ"
		cQuery2 += " WHERE " + cWhere + " "
		cQuery2 += "  AND NJJ.D_E_L_E_T_ = ' '" 
		
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " "
		endIf
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNJJ,.F.,.T.)
		
		if !EMPTY(cValWhe)
			if GETDATASQL("SELECT  COUNT(*) " + cQuery2) > 1
				self:cTipRet = '1'
			else
				self:cTipRet = '2'
				cCod := (cAliasNJJ)->NJJ_FILIAL + "|" + (cAliasNJJ)->NJJ_CODROM
			endIf
		endIf
		
		cQuery3 := " SELECT  *  "
		//cQuery3 += " 		 , ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), NJK_DESDES)),'') AS NJK_DESDES2 " 
		cQuery3 += " FROM  " + RetSqlName("NJK") + " NJK"
		cQuery3 += " INNER JOIN " + RetSqlName("NJJ") + " NJJ"
		cQuery3 += " ON   NJK.NJK_FILIAL = NJJ.NJJ_FILIAL "
		cQuery3 += " AND  NJK.NJK_CODROM = NJJ.NJJ_CODROM "
		cQuery3 += " AND  " + cWhere  		
		cQuery3 += " WHERE " + cWhereNJK 
		cQuery3 += " AND NJK.D_E_L_E_T_ = ' '"			
				
		cQuery3 := ChangeQuery(cQuery3)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery3),cAliasNJK,.F.,.T.)
		
	else
		Self:lOk := .F.
	EndIf
Return {cAliasNJJ,cAliasNJK}

/*/{Protheus.doc} IncludePackingSlipEntry
//Responsável por incluir o registro passado por parametro.
@author Silvana Vieira Torres Streit
@since 16/12/2019
@version 1.0
@return cCodId, código do romaneio incluído.

@type function
/*/
METHOD IncludePackingSlipEntry() CLASS FWPackingSlipEntryAdapter
	Local lRet 		 	as LOGICAL
	Local oModel, oStruct
	Local oMldNJJ		as Object 
	Local oMldNJM 		as OBJECT 
	Local oMldNJK 		as OBJECT 
	Local cCodId		as CHARACTER
	Local nX, nJ, nI	as NUMERIC
	Local aArea      	as ARRAY
	Local aAux			:= {}	//Auxiliar
	Local aCposDet 		:= {}	//Vetor para receber dados dos itens do romaneio
	Local aCposNJK		:= {}
	Local oStruct
	Local nItErro 		:= 0 
	Local aNJK			:= {}
	Local cNumOP		:= ""
	Private lFilLog		as LOGICAL
	
	aArea := GetArea()
	
	cCodId 	:= ""
	lRet 	:= .T.
	
	lFilLog := iif(!Empty(Self:oEaiObjRec:getPropValue('BranchId')),.T.,.F. )
	
	if lFilLog .And. AGRLOGAAPI(Self:oEaiObjRec:getPropValue('BranchId'))
	
		oModel 	:= FWLoadModel('OGA250')
		oMldNJJ := oModel:GetModel('NJJUNICO')
		oMldNJM := oModel:GetModel('NJMUNICO')
		oMldNJK := oModel:GetModel('NJKUNICO')
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		
		oModel:LoadValue( "NJJUNICO",  'NJJ_FILIAL'	, PADR(Self:oEaiObjRec:getPropValue('BranchId'),TamSX3('NJJ_FILIAL')[1]) ) //entrada por produção
		oModel:LoadValue( "NJJUNICO",  'NJJ_TIPO'	, "1" ) //entrada por produção
		oModel:LoadValue( "NJJUNICO",  'NJJ_CODENT'	, PADR(Self:oEaiObjRec:getPropValue('EntityCode'),TamSX3('NJJ_CODENT')[1]) )
		oModel:LoadValue( "NJJUNICO",  'NJJ_LOJENT'	, PADR(Self:oEaiObjRec:getPropValue('EntityStore'),TamSX3('NJJ_LOJENT')[1]) )
		oModel:LoadValue( "NJJUNICO",  'NJJ_CODSAF'	, PADR(Self:oEaiObjRec:getPropValue('PackingListCrop'),TamSX3('NJJ_CODSAF')[1]) )
		oModel:LoadValue( "NJJUNICO",  'NJJ_CODPRO'	, PADR(Self:oEaiObjRec:getPropValue('ProductCode'),TamSX3('NJJ_CODPRO')[1]) )
		oModel:LoadValue( "NJJUNICO",  'NJJ_UM1PRO'	, PADR(Self:oEaiObjRec:getPropValue('ProdMeasureUnit'),TamSX3('NJJ_UM1PRO')[1]) )
		oModel:LoadValue( "NJJUNICO",  'NJJ_LOCAL'	, PADR(Self:oEaiObjRec:getPropValue('LocationCode'),TamSX3('NJJ_LOCAL')[1]) )
		oModel:LoadValue( "NJJUNICO",  'NJJ_TABELA'	, PADR(Self:oEaiObjRec:getPropValue('DiscountsTable'),TamSX3('NJJ_TABELA')[1]) )
	
		oModel:LoadValue( "NJJUNICO",  'NJJ_DATPS1'	, SToD(Self:oEaiObjRec:getPropValue('Weight1Date')))
		oModel:LoadValue( "NJJUNICO",  'NJJ_HORPS1'	, PADR(Self:oEaiObjRec:getPropValue('WeightTime1'),TamSX3('NJJ_HORPS1')[1]) )
		oModel:LoadValue( "NJJUNICO",  'NJJ_PESO1'	, Self:oEaiObjRec:getPropValue('FirstWeight'))
		oModel:LoadValue( "NJJUNICO",  'NJJ_MODPS1'	, PADR(Self:oEaiObjRec:getPropValue('WeightModel1'),TamSX3('NJJ_MODPS1')[1]) )
		
		oModel:LoadValue( "NJJUNICO",  'NJJ_DATPS2'	, SToD(Self:oEaiObjRec:getPropValue('Weight2Date')))
		oModel:LoadValue( "NJJUNICO",  'NJJ_HORPS2'	, PADR(Self:oEaiObjRec:getPropValue('WeightTime2'),TamSX3('NJJ_HORPS2')[1]) )
		oModel:LoadValue( "NJJUNICO",  'NJJ_PESO2'	, Self:oEaiObjRec:getPropValue('SecondWeight'))
		oModel:LoadValue( "NJJUNICO",  'NJJ_MODPS2'	, PADR(Self:oEaiObjRec:getPropValue('WeightModel2'),TamSX3('NJJ_MODPS2')[1]) )
		
		oModel:LoadValue( "NJJUNICO",  'NJJ_PSSUBT'	, Abs( oModel:GETVALUE("NJJUNICO","NJJ_PESO1") - oModel:GETVALUE("NJJUNICO","NJJ_PESO2") )  )
		oModel:LoadValue( "NJJUNICO",  'NJJ_PSLIQU'	, oModel:GETVALUE("NJJUNICO","NJJ_PSSUBT") )
		
		oModel:LoadValue( "NJJUNICO",  'NJJ_PLACA'	, PADR(Self:oEaiObjRec:getPropValue('VehiclePlate'),TamSX3('NJJ_PLACA')[1]) )
		oModel:LoadValue( "NJJUNICO",  'NJJ_CODTRA'	, PADR(Self:oEaiObjRec:getPropValue('CarrierCode'),TamSX3('NJJ_CODTRA')[1]) )
		//oModel:LoadValue( "NJJUNICO",  'NJJ_CGC'	, PADR(Self:oEaiObjRec:getPropValue('CNPJ/CPF'),TamSX3('NJJ_CGC')[1]) )
		oModel:LoadValue( "NJJUNICO",  'NJJ_CODMOT'	, PADR(Self:oEaiObjRec:getPropValue('DriverCode'),TamSX3('NJJ_CODMOT')[1]) )
		
		If lRet
		
			aAdd( aAux, { 'NJM_ITEROM' 	, StrZero( 1, TamSX3( "NJM_ITEROM" )[1] )	} )
			aAdd( aAux, { 'NJM_CODENT'	, PADR(Self:oEaiObjRec:getPropValue('EntityCode'),TamSX3('NJJ_CODENT')[1])  	} )
			aAdd( aAux, { 'NJM_LOJENT'	, PADR(Self:oEaiObjRec:getPropValue('EntityStore'),TamSX3('NJJ_LOJENT')[1]) 	} )
			aAdd( aAux, { 'NJM_CODSAF'	, Self:oEaiObjRec:getPropValue('PackingListCrop') 					} )
			aAdd( aAux, { 'NJM_CODPRO'	, Self:oEaiObjRec:getPropValue('ProductCode')					} )
			aAdd( aAux, { 'NJM_LOCAL'	, Self:oEaiObjRec:getPropValue('LocationCode')		} )		
	
			aAdd( aCposDet, aAux )	
		
			// parte do modelo referente aos dados do item
			oAux := oModel:GetModel( "NJMUNICO" )
	
			oStruct := oAux:GetStruct()
			aAux    := oStruct:GetFields()
			nItErro := 0
			For nI := 1 To Len( aCposDet )
				// Incluímos uma linha nova
				// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
				//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
				If nI > 1
					// Incluímos uma nova linha de item
					If ( nItErro := oAux:AddLine() ) <> nI
						// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
						lRet := .F.
						Exit
					EndIf
				EndIf
				For nJ := 1 To Len( aCposDet[nI] )
					// Verifica se os campos passados existem na estrutura de item
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCposDet[nI][nJ][1] ) } ) ) > 0
						lAux := oModel:setValue( "NJMUNICO", aCposDet[nI][nJ][1], aCposDet[nI][nJ][2] ) 
						
						If !lAux
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							lRet := .F.
							nItErro := nI
							Exit
						EndIf					
					EndIf
				Next
				If !lRet
					Exit
				EndIf
			Next
		EndIf
		
		If lRet
		
			if !EMPTY(Self:oEaiObjRec:getPropValue('PackingSlipRating'))
				
				Self:oEaiObjRec:GetJson(,.T.)
				For nX := 1 to LEN(Self:oEaiObjRec:getPropValue('PackingSlipRating'))					
					aNJK:= {}
					aAdd(aNJK, {'NJK_FILIAL', PADR(Self:oEaiObjRec:getPropValue('BranchId'),TamSX3('NJJ_FILIAL')[1]) })
					aAdd(aNJK, {'NJK_ITEM'  , StrZero( Self:oEaiObjRec:getPropValue('PackingSlipRating')[nX]:getPropValue('SequenceItem'), TamSX3( "NJK_ITEM" )[1])  })
					aAdd(aNJK, {'NJK_TPCLAS', PADR(Self:oEaiObjRec:getPropValue('PackingSlipRating')[nX]:getPropValue('ClassificationType'),TamSX3('NJK_TPCLAS')[1]) })
					aAdd(aNJK, {'NJK_CODDES', PADR(Self:oEaiObjRec:getPropValue('PackingSlipRating')[nX]:getPropValue('DiscountCode'),TamSX3('NJK_CODDES')[1]) })
					aAdd(aNJK, {'NJK_BASDES', Self:oEaiObjRec:getPropValue('PackingSlipRating')[nX]:getPropValue('BaseWeightForClassific')})
					aAdd(aNJK, {'NJK_OBRGT' , PADR(Self:oEaiObjRec:getPropValue('PackingSlipRating')[nX]:getPropValue('MandatoryDiscount'),TamSX3('NJK_OBRGT')[1]) })
					aAdd(aNJK, {'NJK_PERDES', Self:oEaiObjRec:getPropValue('PackingSlipRating')[nX]:getPropValue('ClassificationResult')})
					//aAdd(aNJK, {'NJK_READES', Self:oEaiObjRec:getPropValue('PackingSlipRating')[nX]:getPropValue('DiscountPercentage')})
					aAdd(aNJK, {'NJK_QTDDES', Self:oEaiObjRec:getPropValue('PackingSlipRating')[nX]:getPropValue('Discountity')})
					aAdd(aNJK, {'NJK_DESRES', PADR(Self:oEaiObjRec:getPropValue('PackingSlipRating')[nX]:getPropValue('ResultDescription'),TamSX3('NJK_DESRES')[1]) })
					
					aAdd( aCposNJK, aNJK )		
				next nX
			endIf
			
			oModel:GetModel("NJKUNICO"):SetNoInsert( .f. )
			oAux     := oModel:GetModel("NJKUNICO")
			oStruct  := oAux:GetStruct()
			aAux     := oStruct:GetFields()
			nItErro := 0
			
			For nI := 1 To Len( aCposNJK )
				// Incluímos uma linha nova
				// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
				//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
				If nI > 1
					// Incluímos uma nova linha de item
					If ( nItErro := oAux:AddLine() ) <> nI
						// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
						lRet := .F.
						Exit
					EndIf
					
					oAux:GoLine(oAux:LENGTH())
				EndIf
				For nJ := 1 To Len( aCposNJK[nI] )
					// Verifica se os campos passados existem na estrutura de item
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCposNJK[nI][nJ][1] ) } ) ) > 0
						If !( lAux := oModel:SetValue( "NJKUNICO", aCposNJK[nI][nJ][1], aCposNJK[nI][nJ][2] ) )
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							lRet := .F.
							nItErro  := nI
							Exit
						EndIf
					EndIf
				Next
				If !lRet
					Exit
				EndIf
			NExt
		EndIf
	
		If lRet .And. oModel:VldData()		
			lRet := oModel:CommitData()	
			ConfirmSX8()	
			Self:lOk := .T.
			cCodId   := oModel:GETVALUE("NJJUNICO","NJJ_FILIAL") + "|" + oModel:GETVALUE("NJJUNICO","NJJ_CODROM")
			
			IF .NOT. Empty(oModel:GETVALUE("NJJUNICO","NJJ_CODPRO")) .AND. .NOT. Empty(oModel:GETVALUE("NJJUNICO","NJJ_PSLIQU")) .AND. .NOT. Empty(oModel:GETVALUE("NJJUNICO","NJJ_LOCAL"))
			
				//-- Gera ordem de produção
				Processa({|| lRet := A500GERAOP(@cNumOP, oModel:GETVALUE("NJJUNICO","NJJ_CODPRO"), oModel:GETVALUE("NJJUNICO","NJJ_PSLIQU"), oModel:GETVALUE("NJJUNICO","NJJ_LOCAL"), 3) }, "Gerando Ordem de Produção..." , "Aguarde" )
					
				//-- Realiza o apontamento da OP 
				If lRet
					Processa({|| lRet := OGA250IAPROD(cNumOP, oModel:GETVALUE("NJJUNICO","NJJ_CODROM"), oModel:GETVALUE("NJJUNICO","NJJ_CODPRO"), oModel:GETVALUE("NJJUNICO","NJJ_PSLIQU"), oModel:GETVALUE("NJJUNICO","NJJ_LOCAL"), 3) }, "Movimentando Ordem de Produção...", "Aguarde" ) //###
				EndIf
			endIf
			
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
		RestArea(aArea)
	else
		Self:oEaiObjRec:setError("Filial(Branch) em branco ou inválida. Favor conferir")
		Self:cError := "Filial(Branch) em branco ou inválida. Favor conferir."
		Self:lOk := .F.
	endIf
	
Return cCodId


/*/{Protheus.doc} OGA250IAPROD
//Função MsExecAuto de apontamento de produção 
@author silvana.torres
@since 20/12/2019
@version 1.0
@param 	 cNumApon		, characters, Numero da Ordem de Produção
@param 	 cRomaneio		, characters, Romaneio
@param 	 cProduto		, characters, Produto
@param 	 nPsLiqu		, numeric, Peso líquido do produto
@param 	 cLocal			, characters, Local do produto
@param 	 nOperac		, numeric, Operação (Inclusão/Alteração/Exclusão)
@return  !lMsErroAuto	, Retorna verdadeiro ou falso
@type function
/*/
Function OGA250IAPROD(cNumOP, cRomaneio, cProduto, nPsLiqu, cLocal, nOperac )
	Local aArea 	 := GetArea()
	Local aMata      := {}
	Local aVetor	 := {}
	Local cNumApon   := CriaVar("NJJ_APONOP")
	Local cTM        := SuperGetMV("MV_AGRTMPR",.F.,"")
	Local nModuloAGR := nModulo
	Local cLote		 := ""			

	//-- Variaveis privadas das rotinas MATA250 e MATA650 - não podem ser modificadas.
	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .F.

	//-- Busca o numero da ordem de producao MATA650
	If nOperac == 3	//Inclusão
		cNumApon  := NextNumDoc()
	EndIf

	cUMProdt := Posicione("SB1",1,FwXFilial("SB1")+cProduto,"B1_UM")
	nPRVALID := Posicione("SB1",1,FwXFilial("SB1")+cProduto,"B1_PRVALID")

	//-- Campos para enviar ao MSExecAuto
	AADD(aMata, {"D3_TM"     , cTM           		,Nil})
	AADD(aMata, {"D3_COD"    , cProduto		  		,Nil})
	AADD(aMata, {"D3_UM"     , cUMProdt	    		,Nil})
	AADD(aMata, {"D3_QUANT"  , nPsLiqu		 		,Nil})	//-- Peso Liquido 
	AADD(aMata, {"D3_LOCAL"  , cLocal				,Nil})		
	AADD(aMata, {"D3_DOC"    , cNumApon				,Nil})
	AADD(aMata, {"D3_OP"     , cNumOP	        	,Nil})
	AADD(aMata, {"D3_EMISSAO", dDataBase     		,Nil})
	AADD(aMata, {"AUTPRTOTAL", "S"           		,Nil})

	//-- Quando produto controlar rastro
	If Rastro(cProduto)
		
		DbSelectArea("NJM")
		DbSetOrder(1) //FILIAL+ROMANEIO
		
		If NJM->(MsSeek(NJJ->NJJ_FILIAL + cRomaneio))
			cLote := NJM->NJM_LOTCTL
		EndIf
		
		NJM->(dbCloseArea())
		
		AADD(aMata, {"D3_LOTECTL", cLote ,Nil})
		If nOperac == 3
			AADD(aMata, {"D3_DTVALID", dDataBase+nPRVALID   , Nil})
		EndIf
	EndIf	

	//-- Seta para o modulo de PCP
	nModulo := 10

	//-- Operação igual a uma exclusão
	If  nOperac = 5
		DbSelectArea("SD3")
		DbSetOrder(1) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
		MsSeek(FwXFilial("SD3") + cNumOP + cProduto + cLocal ) 
	Endif

	//-- Executa rotina a automatica - Apontamento de Produção
	MsExecAuto( { |x,y| MATA250(x,y)},aMata,nOperac )	//-- 3=Inclusao, 5=Exclusao

	//-- Operação igual a uma exclusão 
	If nOperac == 5 .And. !lMsErroAuto
		AADD(aVetor,{"C2_NUM" 		, Substr(cNumOP,1 ,TamSx3("C2_NUM")[1]), NIL}) //Numero da OP
		AADD(aVetor,{"C2_ITEM"		, SubStr(cNumOP,TamSx3("C2_NUM")[1]+1,TamSx3("C2_ITEM")[1]), NIL}) //Item da OP
		AADD(aVetor,{"C2_SEQUEN"	, SubStr(cNumOP,TamSx3("C2_ITEM")[1]+1,TamSx3("C2_SEQUEN")[1]), NIL}) //Sequencia da OP

		//-- Executa rotina a automatica - Ordem de Produção
		MSExecAuto({|x,y| mata650(x,y)},aVetor,nOperac)
	Endif

	If lMsErroAuto
		//MostraErro()
		Return .F.
	ElseIf 	nOperac == 3
		//-- Não foi possivel ler o modelo do OGA250, mesmo setando o Activate ele se perde. 
		//-- Validado com a PO - que por se tratando do OGA250 ser um fonte todo customizado, 
		//-- será utilizado o RecLock para gravar as informações de ordem de produção e status.
		If !IsInCallStack("AGRX500") 
			If RecLock( "NJJ", .F. )
				NJJ->NJJ_NUMOP	:= cNumOP  			//Relaciona o numero da ordem de produção ao romaneio
				NJJ->NJJ_APONOP	:= cNumApon			//Relaciona o numero do apontamento de produção ao romaneio

				If !IsInCallStack("AX500PSVen")
					NJJ->NJJ_STATUS := '3'
				EndIf
				
				NJJ->( msUnLock() )
			EndIf
		endIf
	EndIf

	//-- Operação igual a uma exclusão
	If  nOperac = 5
		SD3->(dbCloseArea())
	EndIf	

	//-- Retorna ao modulo do Agroindustria
	nModulo := nModuloAGR
	RestArea(aArea)
	
Return(!lMsErroAuto)

/*/{Protheus.doc} NextNumDoc
//Retorna o proximo numero de documento disponivel
@author silvana.torres
@since 20/12/2019
@version P12
/*/
Static Function NextNumDoc()
	Local aAreaAtu 	:= GetArea()
	Local cNumDoc 	:= ""
	Local cMay		:= ""

	//----------------------------------------------------
	//Inicializa o numero do Documento com o ultimo + 1 
	//----------------------------------------------------
	dbSelectArea("SD3")
	cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)
	cNumDoc := A261RetINV(cNumDoc)
	dbSetOrder(2)
	MsSeek(cFilAnt+cNumDoc)
	cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
	While SD3->(D3_FILIAL+D3_DOC) == cFilAnt + cNumDoc .Or. !MayIUseCode(cMay)
		If SD3->D3_ESTORNO # "S"
			cNumDoc := Soma1(cNumDoc)
			cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
		EndIf
		dbSkip()
	EndDo
	SD3->(dbCloseArea())

	RestArea( aAreaAtu )
Return( cNumDoc )